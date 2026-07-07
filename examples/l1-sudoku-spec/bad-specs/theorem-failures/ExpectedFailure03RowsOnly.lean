/-!
期望失败 3：坏规格只检查行，不检查列和 3x3 宫。

这个文件尝试从只检查行的坏规格中取出列约束，
但坏规格根本没有列约束，所以 Lean 应该拒绝该 theorem 证明。
-/

abbrev Grid := Nat -> Nat -> Nat

def PuzzleCellsAreValid (_ : Grid) : Prop := True
def SolutionCellsAreDigits (_ : Grid) : Prop := True
def GivenPreserved (_ _ : Grid) : Prop := True
def RowsValid (_ : Grid) : Prop := True
def ColsValid (solution : Grid) : Prop :=
  ∀ col, col < 9 -> solution 0 col = solution 1 col

def BadSudokuSolutionRowsOnly (puzzle solution : Grid) : Prop :=
  PuzzleCellsAreValid puzzle ∧
  SolutionCellsAreDigits solution ∧
  GivenPreserved puzzle solution ∧
  RowsValid solution

-- 这个 theorem 应该失败：坏规格没有提供 `ColsValid solution`。
theorem cannotRecoverColumnValidity
    (puzzle solution : Grid) :
    BadSudokuSolutionRowsOnly puzzle solution ->
    ColsValid solution := by
  intro h
  rcases h with ⟨_, _, _, hRows⟩
  exact hRows
