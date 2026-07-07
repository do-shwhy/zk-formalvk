# L6 verifier/实现层：proof 与 statement 绑定

这个例子展示 verifier 实现层常见错误：底层 proof 看起来有效，但 verifier 没有检查它是否绑定到当前 statement / public input。

它不是一个真实 ZK proof system，而是一个最小可运行模型：

- `proof_blob` 代表底层 proof cryptographically valid；
- `vk_id` 代表 verifying key；
- `statement_hash` 代表 proof 应该绑定的 statement；
- `public_input` 代表 verifier 当前要验证的公开输入。

## 运行

```bash
python3 examples/l6-verifier-binding/verifier_binding_demo.py
```

预期输出：

```text
proof was created for: puzzle_hash=PUZZLE_A
attacker replays it for: puzzle_hash=PUZZLE_B

bad verifier accepts replay: True
good verifier accepts replay: False

good verifier accepts original: True
```

## 说明

错误 verifier 只检查：

```text
proof_blob 有效
vk_id 正确
```

但没有检查：

```text
proof.statement_hash == H(app_id, circuit_id, public_input)
```

因此 proof 可以被 replay 到另一个 public input。

正确 verifier 额外检查 statement hash，把 proof 绑定到：

- app id；
- circuit id；
- verifying key；
- public input。

这类问题不是 L1 规格层问题，也不是 L3 约束层问题，而是部署 verifier 是否验对对象的问题。

## 和 ZK 的关系

真实系统里类似风险包括：

- public input 顺序或长度没检查；
- verifying key / circuit id 没绑定；
- Fiat-Shamir transcript 少吸收字段；
- domain separator 缺失；
- 递归证明没有绑定 inner proof 的 statement；
- malformed proof 没有被正确拒绝。

如果只是 fuzzing / 审计，这属于实现安全 assurance；如果用 K / SMT / Lean / Coq / Solidity formal tools 证明 verifier 实现满足 verifier spec，才是严格意义上的实现级形式化验证。
