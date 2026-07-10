# L3 约束层：CIVER weak-safety 与 functional specification

这个例子使用 [CIVER](https://github.com/costa-group/circom_civer) 对 Circom circuit 做模块化 SMT 验证。它同时展示两个不同问题：

```text
weak-safety:      给定输入，输出是否唯一？
postcondition:    唯一的输出是否满足 intended spec？
```

## 运行

从仓库根目录执行：

```bash
bash examples/l3-civer/run-civer.sh
```

脚本会将 CIVER 的源码缓存在 `~/.cache/zk-formalvk/circom_civer`，固定到已验证的 commit，并执行上游 CI 使用的 `cargo build --release --locked` 后运行。第一次构建需要 Rust/Cargo、C/C++ 构建工具、CMake 和 Clang；后续会复用 Cargo build cache。

## 三个 circuit

### `safe_double.circom`

在不发生有限域回绕的输入范围内，约束和规格都是 `b = a + a`：

```circom
spec_precondition a <= 100;
b <== a + a;
spec_postcondition b == a + a;
```

CIVER 应同时证明 weak-safety 和 postcondition。

### `unsafe_double.circom`

`<--` 只给 honest witness generator 赋值，不生成 verifier constraint：

```circom
b <-- a + a;
```

因此同一个 `a` 可以对应多个满足约束的 `b`，CIVER 应无法证明 weak-safety。

### `wrong_double.circom`

这个 circuit 把输出完整约束成了 `b = a + a + 1`，所以输出是唯一的；但规格要求 `b = a + a`：

```circom
spec_precondition a <= 100;
b <== a + a + 1;
spec_postcondition b == a + a;
```

CIVER 应证明 weak-safety，却无法证明 postcondition。这说明：

```text
没有 under-constrained
不等于
实现满足业务规格
```

## 预期结果

脚本检查以下五个 verdict：

| Circuit | 检查 | 预期 |
|---|---|---|
| safe double | weak-safety | 通过 |
| safe double | postcondition | 通过 |
| unsafe double | weak-safety | 失败 |
| wrong double | weak-safety | 通过 |
| wrong double | postcondition | 失败 |

只有五个结果都符合预期，脚本才输出：

```text
[CIVER] all expected verdicts observed
```

## 和 Picus / clean 的关系

- Picus 从 Circom/R1CS 约束检查 uniqueness，并能给出具体 counterexample；
- CIVER 利用 Circom 模块结构检查 weak-safety，还能验证源码中的 tag 和 pre/postcondition；
- clean 把 circuit、规格与 Lean soundness/completeness proof 放进同一个 proof-carrying DSL。

CIVER 的 postcondition 补上了纯 under-constrained 检查的一个关键盲点：确定但错误的 circuit。

## 局限

- CIVER 当前是 Circom 2.1.6 的分叉，还没有正式 release；本 demo 因此固定上游 commit。
- CIVER 将这里的规格表达式交给整数 SMT 编码；`a <= 100` 前置条件用于排除有限域加法回绕，使整数规格与 circuit 语义对齐。
- 验证结果依赖 CIVER 编码、Z3 和有限域模型的正确性，不是 Lean/Coq proof checker 检查的证明对象。
- SMT 对大型非线性电路可能超时；CIVER 通过模块化分析缓解，但不能消除这个限制。