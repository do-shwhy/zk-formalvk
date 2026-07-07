/-! 公共定义：让本文件可以独立用 `lean Bad02UniqueButNoDigitRange.lean` 检查。 -/

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
错误 2：只检查每行互不相同，不检查 1..9 范围。

如果其它行/列/宫规则也照这个思路写，
那么 10、11、12 这类值也可能通过“互不相同”检查。
-/

def PairwiseDifferentRow (solution : Grid) (row : Nat) : Prop :=
  row < 9 ->
  ∀ left right,
    left < 9 ->
    right < 9 ->
    left ≠ right ->
    solution row left ≠ solution row right

def BadRowsValidUniqueButNoDigitRange (solution : Grid) : Prop :=
  ∀ row, PairwiseDifferentRow solution row
