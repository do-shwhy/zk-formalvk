/-!
期望失败 1：坏规格漏掉题目绑定。

这个文件尝试从坏规格里取出 `GivenPreserved` 证据，
但坏规格根本没有这个字段，所以 Lean 应该拒绝该 theorem 证明。
-/

abbrev Grid := Nat -> Nat -> Nat

def PuzzleCellsAreValid (_ : Grid) : Prop := True
def SolutionCellsAreDigits (_ : Grid) : Prop := True
def RowsValid (_ : Grid) : Prop := True
def ColsValid (_ : Grid) : Prop := True
def BoxesValid (_ : Grid) : Prop := True

def BadSudokuSolutionMissingGivenPreserved (puzzle solution : Grid) : Prop :=
  PuzzleCellsAreValid puzzle ∧
  SolutionCellsAreDigits solution ∧
  RowsValid solution ∧
  ColsValid solution ∧
  BoxesValid solution

def GivenPreserved (puzzle solution : Grid) : Prop :=
  ∀ row col,
    row < 9 ->
    col < 9 ->
    puzzle row col ≠ 0 ->
    solution row col = puzzle row col

-- 这个 theorem 应该失败：坏规格没有提供 `GivenPreserved puzzle solution`。
theorem cannotRecoverGivenPreserved
    (puzzle solution : Grid) :
    BadSudokuSolutionMissingGivenPreserved puzzle solution ->
    GivenPreserved puzzle solution := by
  intro h
  rcases h with ⟨_, _, hGiven, _, _, _⟩
  exact hGiven
