# L1 规格层：数独 Relation

这个例子展示 ZK statement 的 L1 规格层。

先点明边界：**Lean / Coq 只能检查你写下来的 statement / theorem 是否良构，并检查你给出的证明是否真的证明了这些 theorem。**

Lean / Coq 也可以帮你证明一些关键性质，例如“某个坏 witness 不可能满足 `SudokuSolution`”。但这些关键性质必须由你自己明确写成 theorem；如果你没有写，或者业务规格本身写错了，证明器不会自动知道你的真实意图。

业务 statement 是：

```text
公开输入：一个数独题目，或者绑定到私有题目的 hash
私有 witness：如果只公开 hash，则包含私有题目；以及一个候选答案
要证明的 claim：候选答案是该题目的合法解
```

Lean / Coq 文件只定义业务 relation 和 public binding 形状：

```text
SudokuSolution(puzzle, solution)
SudokuStatement(publicPuzzleHash, publicSolutionHash, privatePuzzle, privateSolution)
```

`SudokuSolution` 检查：

- 题目格子要么为空格 `0`，要么是 `1..9`；
- 答案格子必须是 `1..9`；
- 题目中的非零给定格必须在答案中保持一致；
- 每一行、每一列、每个 3x3 宫都必须恰好包含一次 `1..9` 中的每个数字。

`SudokuStatement` 额外把私有题目和私有答案绑定到公开 hash。

它不定义 circuit、AIR、R1CS、witness generator、prover 或 verifier。后续层应该证明自己的实现 refinement 到这个 relation。

`SudokuSpec.lean` 和 `SudokuSpec.v` 还包含几个具体的拒绝证明，用来说明好规格确实能排除坏 witness：

- `changedGivenRejected`：答案篡改题目中的非零给定格时，不能满足 `SudokuSolution`；
- `answerDigitRangeRejected`：答案中出现 `10` 时，不能满足 `SudokuSolution`；
- `invalidPuzzleDigitRejected`：题目中出现非法给定值 `42` 时，不能满足 `SudokuSolution`；
- `repeatedRowRejected`：某一行全是 `1` 时，不能满足 `SudokuSolution`。

## 文件

- `SudokuSpec.lean`：数独 relation 的 Lean 形式化规格。
- `SudokuSpec.v`：同一数独 relation 的 Coq/Rocq 形式化规格。
- `bad-specs/Bad*.lean`：故意写错的 L1 规格，展示 Lean 仍会把这些错误规格当作良构定义接受。
- `bad-specs/theorem-failures/`：尝试用坏规格证明关键性质的 Lean 文件；这些文件预期无法通过 Lean 检查。

## 验证环境

- Lean 版本：Lean 4.31.0
- Lean 提交：68218e876d2a38b1985b8590fff244a83c321783
- Coq/Rocq 版本：The Rocq Prover 9.1.1
- OCaml 版本：4.14.2

## 运行 Lean 版本

安装 Lean 4 后执行：

```bash
lean SudokuSpec.lean
```

预期结果：无输出，exit code 为 0。

验证结果：无输出，exit code 为 0。

## 运行 Coq/Rocq 版本

安装 Coq/Rocq 后执行：

```bash
coqc SudokuSpec.v
```

预期结果：无输出，exit code 为 0。

验证结果：无输出，exit code 为 0。

## Lean 和 Coq/Rocq 的简单对比

| 维度 | Lean 4 | Coq/Rocq |
|---|---|---|
| 核心思路 | dependent type theory，命题是类型，证明是 term | dependent type theory / Calculus of Inductive Constructions，命题是类型，证明是 term |
| 验证方式 | kernel 检查 tactic 生成的 proof term 是否具有目标类型 | kernel 检查 tactic script 生成的 proof term 是否具有目标类型 |
| 自动化风格 | `simp`、`rcases`、`decide` 等较现代，语法更接近函数式编程 | `intros`、`destruct`、`specialize`、`lia` 等 tactic 生态成熟 |
| 和 TLC 的区别 | 不是遍历状态空间找反例 | 同样不是遍历状态空间找反例 |
| 在本例中的角色 | 定义 `SudokuSolution`，并证明几个坏 witness 被拒绝 | 用 Coq/Rocq 复刻同一 relation 和同类拒绝证明 |

## 错误规格对照

下面这张表同时展示两件事：

- 坏规格定义本身可能通过 Lean，因为它们是良构定义；
- 但当我们尝试用坏规格证明真正需要的关键性质时，Lean 会失败。

| 错误类型 | 坏规格文件 | 坏规格定义检查 | 关键 theorem 文件 | theorem 检查 | 结论 |
|---|---|---|---|---|---|
| 漏掉题目绑定 | `bad-specs/Bad01MissingGivenPreserved.lean` | 通过 | `bad-specs/theorem-failures/ExpectedFailure01MissingGivenPreserved.lean` | 失败 | 无法从坏规格推出 `GivenPreserved puzzle solution`，存在 soundness 风险 |
| 只查互异，不查范围 | `bad-specs/Bad02UniqueButNoDigitRange.lean` | 通过 | `bad-specs/theorem-failures/ExpectedFailure02UniqueButNoDigitRange.lean` | 失败 | 行内互异不能推出答案每格是 `1..9` |
| 只检查行 | `bad-specs/Bad03RowsOnly.lean` | 通过 | `bad-specs/theorem-failures/ExpectedFailure03RowsOnly.lean` | 失败 | 无法从只检查行的坏规格推出 `ColsValid solution` |
| public input 绑定错对象 | `bad-specs/Bad04WrongHashBinding.lean` | 通过 | `bad-specs/theorem-failures/ExpectedFailure04WrongHashBinding.lean` | 失败 | 实际绑定的是 `privateSolution`，不是 `privatePuzzle` |
| 蕴含方向写反 | `bad-specs/Bad05WrongImplicationDirection.lean` | 通过 | `bad-specs/theorem-failures/ExpectedFailure05WrongImplicationDirection.lean` | 失败 | 错误方向无法推出正确的给定格保持关系 |

一次性运行：

```bash
cd examples/l1-sudoku-spec/bad-specs
for file in Bad*.lean; do
	echo "== $file =="
	lean "$file"
done
```

预期结果：所有文件都通过 Lean 检查。

一次性运行：

```bash
cd examples/l1-sudoku-spec/bad-specs/theorem-failures
for file in ExpectedFailure*.lean; do
	echo "== $file =="
	lean "$file"
done
```

预期结果：所有文件都无法通过 Lean 检查。

## 这个例子想表达什么

```text
Lean 验证通过
	=> 形式化定义是良构的
	≠> 业务规格一定写对了

好规格 + theorem 通过
	=> 该规格确实能排除某些坏 witness

坏规格 + theorem 失败
	=> 坏规格无法支撑我们真正需要的安全性质
```
