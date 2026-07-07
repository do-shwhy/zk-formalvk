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
4. 跑本目录的 `SudokuClean.lean`。

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

## 为什么是 L4 / refinement demo

这个例子展示的不是“扫描已有约束是否 under-constrained”，而是另一条路线：

```text
spec、circuit、constraints、proof obligations 写在同一个 Lean 框架里。
```

这对应 PPT 里的 L1-L4 refinement 问题：如何让高层规格和实际约束之间有可检查的证明证据。

## 局限

- `Digit` 目前放在 `Assumptions`，表示这个 demo 假设 digit/range check 已由外层 gadget 或 lookup 处理。
- 完整 4x4/9x9 数独需要把 digit check 和 all-different gadget 做成可复用 clean 子电路。
- clean 当前仍在快速发展中，proof automation 对大电路还需要手工拆分和显式 metadata。
