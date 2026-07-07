# ZK 形式化验证速览

目标读者：熟悉 TLA+ / TLC 等等传统形式化验证工具，但不熟悉 ZK 电路、SNARK/STARK、AIR/R1CS 的形式化验证。

---

## 1. 要解决的目标问题

TLA+ 常问：

> 所有可能执行里，系统是否会进入预期外的状态？

ZK 形式化验证常问 （soundness 属性是否满足）：

> verifier 接受 proof 时，被证明的 statement 是否真的成立？

核心安全目标可以粗略写成：

```text
Verifier(proof, public_input) = accept
  =>
知晓合法 witness，使得 Relation(public_input, witness) 为真
```

---

## 2. 从 TLA+ 到 ZK：对应关系

| TLA+ | ZK |
|---|---|
| Spec | statement / relation / AIR 语义 / circuit 规格 |
| Implementation | ZK DSL / trace generator / witness generator / verifier code |
| Invariant | range、boolean、memory consistency、state transition invariant |
| Refinement | 高层语义 refined by constraints / AIR / R1CS |
| TLC 找反例 | fuzzing / SMT / finite-field solver 找恶意 witness |
| TLAPS / theorem prover | Lean / Coq / ACL2 / EasyCrypt 机器证明 |

最重要的迁移：

```text
TLA+: implementation behaviors ⊆ spec behaviors
ZK:  satisfying witnesses/traces ⊆ intended semantics
```

---

## 3. ZK 为什么特别容易出错

普通程序 bug 往往会崩溃、报错、输出异常。但 ZK bug 可能表现为：

```text
proof 生成成功
verifier 接受成功
但证明的语义是错的
```

原因是 verifier 检查的是：

```text
约束系统是否被满足
```

不是直接检查：

```text
业务逻辑是否成立
```

---

## 4. ZK 的验证链条

ZK 形式化验证不是单点问题，而是一条链：

```text
业务语义 / VM 语义
  -> ZK DSL / trace generator / witness generator
  -> AIR / R1CS / PLONKish constraints
  -> SNARK / STARK / PCS / FRI / Fiat-Shamir
  -> verifier 实现
  -> rollup / zkVM / application 集成
```

任何一层错了，都可能得到：

```text
数学上 valid，但业务上 false 的 proof
```

---

## 5. ZK 形式化验证一般分为几层

| 层 | 验证对象 | 主要问题 | 代表工具/工作 | 示例 | 关键性 |
|---|---|---|---|---|---|
| L1 规格层 | statement / VM 语义 / 业务规则 | 规格是否写对 | TLA+、Lean/Coq 规格 | [数独 Lean 规格](examples/l1-sudoku-spec) | 写业务规格，证明 theorem |
| L2 程序/DSL 层 | Circom / Noir / Leo / trace generator | 程序语义是否 refinement 到规格 | CODA、NAVe、Circomspect、[clean](https://github.com/Verified-zkEVM/clean) | [Circomspect 示例](examples/l2-circomspect) | ZK DSL 层的轻量静态分析；clean 是“写 circuit 时同步证明”的路线 |
| **L3 约束/AIR 层** | R1CS / PLONKish / Halo2 / AIR | constraints/AIR 是否漏约束等 | **Picus、CIVER、halo2-analyzer、CertiPlonk** | [Picus under-constrained 示例](examples/l3-picus) | **工程上最关键** 直接对约束层进行静态分析 |
| L4 编译/IR 层 | DSL -> constraints / AIR | lowering 是否保持 refinement | [clean](https://github.com/Verified-zkEVM/clean)、[CirC](https://eprint.iacr.org/2020/1586)、[finite-field-blasting verification](https://eprint.iacr.org/2023/778)、[SMT over finite fields](https://eprint.iacr.org/2023/091) | [clean 数独 demo](examples/l4-clean-sudoku) | 重要但工具化较弱，clean 是较新的实用方向 |
| L5 证明协议层 | Groth16 / PLONK / STARK / FRI / PCS | 协议 soundness / completeness / ZK 是否成立 | Groth16/PLONK/STARK/FRI 原论文、[Lean SNARK soundness](https://www.usenix.org/conference/usenixsecurity24/presentation/bailey)、[EasyCrypt ZKP](https://arxiv.org/abs/2104.05516) | 无 demo，依赖论文证明/机器检查证明 | 基础可信根 |
| L6 verifier/实现层 | Rust/Solidity verifier、transcript、序列化 | verifier 是否验对对象、绑对 proof / vk / public input / statement | fuzzing、审计、符号执行、实现级形式化验证 | [verifier 绑定示例](examples/l6-verifier-binding) | 部署安全层 |
| L7 系统集成层 | zkVM / rollup / recursion / bridge | 多组件语义是否一致 | RISC Zero spec、zkVM FV | --- | 大系统关键 |

这里的 refinement 不是单独一层，而是贯穿 L2-L4：证明程序、约束/AIR、编译产物都没有偏离 L1 手写规格。[clean](https://github.com/Verified-zkEVM/clean) 正是这条线上的代表：在 Lean 里写 circuit，同时写 `Assumptions` / `Spec`，并证明 `soundness` / `completeness`；它不是事后扫描器，而是把规格、约束和部分 AIR/后端导出放进同一个可证明框架。

一个现实参照：2026 年 Zcash Orchard soundness vulnerability 的根因在 **L3 约束/AIR 层**。公开说明中提到，问题出在 Orchard zero-knowledge proof circuit 的 `halo2_gadgets` 实现里：`ecc::chip::mul` 的 incomplete double-and-add loop 允许 per-iteration base 变成未正确绑定的自由常量，导致 gadget 可证明的语义偏离预期 scalar multiplication。

最容易出资金级事故的是 **L3 约束/AIR 层**：

```text
约束少一条，恶意 prover 就可能构造错误 witness/trace。
```

但最容易让证明“正确但没意义”的是 **L1 规格层**：

```text
规格没表达真实业务语义，后面证明再强也只是证明了错问题。
```

---

## 6. 当前薄弱点：跨层 refinement 没闭环

ZK FV 已经有很多单点工具；真正缺的是把每一层连成同一个 statement。

| 边界 | 主要风险 |
|---|---|
| L1 -> L2 | 规格没有覆盖真实业务语义 |
| L2 -> L3 | DSL / trace generator lowering 后语义漂移 |
| L3 内部 | advice、lookup、range、boundary 少约束 |
| L3 -> L5 | 协议证明假设和实际 circuit / 参数不匹配 |
| L5 -> L6 | transcript、vk、public input、version 没绑紧 |
| L6 -> L7 | rollup / bridge / zkVM 多组件状态不一致 |

核心问题：

```text
局部工具能证明局部性质，但端到端 refinement 证据仍然稀缺。
```

---

## 7. L3：约束正确性是主战场

L3 的典型 bug 不是“代码崩了”，而是：

```text
恶意 witness/trace 满足约束，但不满足真实语义。
```

常见形态：advice 没绑定、range 漏检、lookup 边界不完整、public input 没绑定最终状态、trace generator 只生成好 trace 但 AIR 允许坏 trace。

Zcash Orchard 事件属于这一类：根因在 Orchard zero-knowledge proof circuit / `halo2_gadgets`，不是 verifier API 写错，也不是 L5 证明协议论文错。

前沿方向：under-constrained 自动分析、finite-field SMT、proof-producing analyzer、gadget-level contract、compositional circuit verification。

---

## 8. 没有 under-constrained 也不等于正确

under-constrained checker 主要问：

```text
是否存在不该被接受的 witness/trace？
```

functional correctness 还要问：

```text
所有被接受的 witness/trace，是否都满足 intended spec？
```

例如本来要证明 `out = a + b`，但约束写成 `out = (a + b) % 1000000`。这个 circuit 可能没有未约束变量，但语义仍然错。

前沿方向：verified lowering、translation validation、从 DSL/AIR/R1CS 自动生成 proof obligation，并把 L1 spec 连接到实际 circuit artifact。clean 属于这条路线：`FormalCircuit` 把 circuit、precondition、postcondition 和 soundness/completeness proof 打包成可复用 gadget。

---

## 9. L5-L7：数学证明和部署系统之间有距离

L5 soundness 证明通常活在理想模型里；部署系统还要处理 byte encoding、transcript、版本、vk、recursion、系统状态绑定。

关键问题：

- transcript 是否吸收 circuit id / vk / public input / chain id / version？
- verifying key 是否和当前 circuit 版本一致？
- verifier 是否拒绝 non-canonical proof encoding？
- recursion / aggregation 是否保留完整 statement 上下文？
- rollup / bridge / zkVM 是否把 proof 映射到正确状态转移？

前沿方向：机器化协议证明、typed transcript、verified verifier、canonical serialization、zkVM semantic conformance、跨组件 invariant。

---

## 10. 对 Plonky3 / STARK / AIR 的实际路线

不要一上来追求“证明 Plonky3 绝对正确”。更实际的是按风险闭环：

1. L1：写清状态机语义和 public input 绑定。
2. L3：检查 transition、boundary、lookup、memory consistency。
3. L4：验证 trace generator 和 AIR 表达同一个状态机；可关注 clean 这类 Lean DSL + AIR backend 路线。
4. L5：复核 FRI/PCS 参数、安全假设和 transcript 规则。
5. L6：绑定 proof / vk / statement / version。
6. L7：验证 rollup / zkVM / bridge 的跨组件不变量。

研究主线：

```text
从“局部找 bug”走向“跨层证明同一个 statement”。
```

---

## 11. TODO：横向调研

后续调研需要把几类路线都纳入：

| 路线 | 代表工作 | 关注点 |
|---|---|---|
| Proof-carrying DSL | clean、zkLean、CLAP | 写 circuit 时同步证明规格、约束和 witness |
| Existing-code verification | Garden/Rocq、CertiPlonk、SP1 Lean | 验证已有 Rust/Plonky3/zkVM 约束实现 |
| Common IR / translation validation | LLZK、CirC、MLIR sidekick | 多 DSL 到 AIR/R1CS/Plonkish 的语义保持 |
| Analyzer / bug finding | Picus、CIVER、halo2-analyzer、AVAZAR | 自动找 under-constrained / weak-safety 反例 |
| zkVM semantics | Sail RISC-V、OpenVM、SP1、Jolt、EthProofs | 指令、lookup bus、memory、trace 全局一致性 |
| Protocol FV | ArkLib、VCV-io、EasyCrypt、SSProve | FRI、sumcheck、Fiat-Shamir、SNARK soundness |
| AI + FV | zk.golf、zkao、Aristotle/Claude + Lean | AI 写/优化/审计，proof checker 负责验收 |
