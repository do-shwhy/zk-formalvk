/-! 公共定义：让本文件可以独立用 `lean Bad05WrongImplicationDirection.lean` 检查。 -/

abbrev Grid := Nat -> Nat -> Nat
abbrev Hash := Nat

opaque GridHash : Grid -> Hash

def Digit (n : Nat) : Prop :=
  1 <= n ∧ n <= 9

def ExistsUniqueNat (p : Nat -> Prop) : Prop :=
  ∃ value, p value ∧ ∀ other, p other -> other = value

def ExistsUniquePair (p : Nat × Nat -> Prop) : Prop :=
  ∃ value, p value ∧ ∀ other, p other -> other = value

def CellIndex (row col : Nat) : Prop :=
  row < 9 ∧ col < 9

def PuzzleCellsAreValid (puzzle : Grid) : Prop :=
  ∀ row col,
    CellIndex row col ->
    puzzle row col = 0 ∨ Digit (puzzle row col)

def SolutionCellsAreDigits (solution : Grid) : Prop :=
  ∀ row col,
    CellIndex row col ->
    Digit (solution row col)

def GivenPreserved (puzzle solution : Grid) : Prop :=
  ∀ row col,
    row < 9 ->
    col < 9 ->
    puzzle row col ≠ 0 ->
    solution row col = puzzle row col

def RowsValid (solution : Grid) : Prop :=
  ∀ row,
    row < 9 ->
    ∀ digit,
      Digit digit ->
      ExistsUniqueNat (fun col => col < 9 ∧ solution row col = digit)

def ColsValid (solution : Grid) : Prop :=
  ∀ col,
    col < 9 ->
    ∀ digit,
      Digit digit ->
      ExistsUniqueNat (fun row => row < 9 ∧ solution row col = digit)

def BoxesValid (solution : Grid) : Prop :=
  ∀ boxRow boxCol,
    boxRow < 3 ->
    boxCol < 3 ->
    ∀ digit,
      Digit digit ->
      ExistsUniquePair (fun offset : Nat × Nat =>
        offset.1 < 3 ∧
        offset.2 < 3 ∧
        solution (3 * boxRow + offset.1) (3 * boxCol + offset.2) = digit)

/-!
错误 5：题目给定格保持关系的蕴含方向写反。

正确方向：如果 puzzle[row][col] 非零，则 solution 必须等于 puzzle。
错误方向：如果 solution[row][col] 非零，则 solution 必须等于 puzzle。
由于合法 solution 每格都非零，这会把 puzzle 也强制成完整答案，
更像 over-constrained / completeness 问题。
-/

def BadGivenPreservedWrongDirection (puzzle solution : Grid) : Prop :=
  ∀ row col,
    row < 9 ->
    col < 9 ->
    solution row col ≠ 0 ->
    solution row col = puzzle row col

def BadSudokuSolutionWrongImplicationDirection (puzzle solution : Grid) : Prop :=
  PuzzleCellsAreValid puzzle ∧
  SolutionCellsAreDigits solution ∧
  BadGivenPreservedWrongDirection puzzle solution ∧
  RowsValid solution ∧
  ColsValid solution ∧
  BoxesValid solution
