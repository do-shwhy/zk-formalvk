# L4 clean 数独 demo

这个例子用 [clean](https://github.com/Verified-zkEVM/clean) 跑一个最小 ZK circuit formal verification demo。

clean 是一个 Lean 4 embedded DSL：在 Lean 里写 circuit，同时写 `Assumptions` / `Spec`，并证明 `soundness` / `completeness`。它更像 proof-carrying circuit framework，不是 Picus 那种事后 under-constrained scanner。

## 运行

```bash
cd examples/l4-clean-sudoku
./run.sh
```

脚本会：

1. clone clean 到 `/tmp/zk-formalvk/clean`，如果已经存在则复用；
2. 执行 `lake build`；
3. 跑 clean 官方 `Clean/Examples/WitnessExport.lean` demo；
4. 跑本目录的 `SudokuClean.lean` 和 `Sudoku9x9Clean.lean`。

成功时最后输出：

```text
[clean] ok
```

第一次运行需要下载 Lean 4.30.0 和 mathlib，时间会比较长；后续会复用本地 Lake build cache。

## SudokuClean.lean 做了什么

这个文件实现的是一个 **2x2 mini Sudoku** 教学版本，不是完整 9x9 数独。

输入是 4 个 field 元素：

```text
x0 x1
x2 x3
```

语义规格：

- 每个格子是 `1` 或 `2`；
- 给定格子满足 `x0 = 1`、`x3 = 1`；
- 每一行的和是 `3`；
- 每一列的和是 `3`。

clean circuit 约束是 6 条 `assert`：

```text
x0 - 1 = 0
x3 - 1 = 0
x0 + x1 - 3 = 0
x2 + x3 - 3 = 0
x0 + x2 - 3 = 0
x1 + x3 - 3 = 0
```

`FormalAssertion` 证明两件事：

```text
soundness:    Assumptions ∧ constraints hold => SudokuSpec
completeness: Assumptions ∧ SudokuSpec => constraints hold
```

## Sudoku9x9Clean.lean 做了什么

这个文件实现的是一个 **分层 9x9 Sudoku-like checker**。它不是把 9x9 的所有约束平铺成一个大电路，而是按 clean 更推荐的方式拆成小 gadget：

```text
Group9.circuit
	-> Rows.circuit / Cols.circuit / Boxes.circuit
	-> Sudoku.circuit
```

`Group9.circuit` 对 9 个格子检查三个 arithmetic fingerprint：

```text
sum     = 45
sqSum   = 285
product = 362880
```

顶层 `Sudoku.circuit` 组合 27 个 group：

```text
9 rows + 9 columns + 9 boxes
```

这个版本能跑通，说明当时 4x4 失败的根因不是 clean 表达不了，而是我一开始把所有约束一次性展开，导致 `circuit_norm` 和 metadata proof 太重。分层以后，Lean 只需要复用 `Group9.circuit` 的 `Spec`，不会反复展开所有底层约束。

注意：这里的 `GroupOk` 是 arithmetic fingerprint，不是直接写 pairwise all-different。`Digit` 仍作为顶层 `Assumptions`。在 1..9 范围内，`sum/sqSum/product` 能唯一刻画 1..9 的 multiset；但本 demo 目前证明的是：

```text
constraints hold <=> GroupOk fingerprint holds
```

并没有额外在 Lean 中证明：

```text
Digit assumptions + GroupOk fingerprint <=> pairwise all-different
```

要做完整 Sudoku 语义，下一步应该把 pairwise inequality 或 permutation lemma 也形式化。

## soundness / completeness 是自动的吗？

不是完全自动。

开发者要自己写：

- `Assumptions`
- `Spec`
- `soundness`
- `completeness`

clean 提供的是证明框架和开场自动化：`circuit_proof_start` 会展开 clean 的 DSL、引入标准变量、把约束转成 Lean 目标。简单 gadget 可以很短，复杂电路仍需要手写 proof script。

所以 clean 当前更像：

```text
FV 工程师 / Lean 用户 / AI agent + proof checker 的工具
```

还不是普通 ZK 开发者点一下就能得到完整证明的工具。它的可维护性来自“先证明小 gadget，再组合”，不是来自一次性自动证明大电路。

## 为什么是 L4 / refinement demo

这个例子展示的不是“扫描已有约束是否 under-constrained”，而是另一条路线：

```text
spec、circuit、constraints、proof obligations 写在同一个 Lean 框架里。
```

这对应 PPT 里的 L1-L4 refinement 问题：如何让高层规格和实际约束之间有可检查的证明证据。

## 局限

- `Digit` 目前放在 `Assumptions`，表示这个 demo 假设 digit/range check 已由外层 gadget 或 lookup 处理。
- 9x9 版本使用 arithmetic fingerprint，还没有证明它等价于 pairwise all-different。
- clean 当前仍在快速发展中，proof automation 对大电路还需要手工拆分和显式 metadata。
