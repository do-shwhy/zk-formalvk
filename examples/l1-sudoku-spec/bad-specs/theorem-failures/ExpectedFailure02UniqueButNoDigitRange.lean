/-!
期望失败 2：坏规格只检查互异，不检查数字范围。

这个文件尝试从“行内互异”推出“每个格子都是 1..9”，
但坏规格没有范围检查，所以 Lean 应该拒绝该 theorem 证明。
-/

abbrev Grid := Nat -> Nat -> Nat

def Digit (n : Nat) : Prop :=
  1 <= n ∧ n <= 9

def PairwiseDifferentRow (solution : Grid) (row : Nat) : Prop :=
  row < 9 ->
  ∀ left right,
    left < 9 ->
    right < 9 ->
    left ≠ right ->
    solution row left ≠ solution row right

def BadRowsValidUniqueButNoDigitRange (solution : Grid) : Prop :=
  ∀ row, PairwiseDifferentRow solution row

def SolutionCellsAreDigits (solution : Grid) : Prop :=
  ∀ row col,
    row < 9 ∧ col < 9 ->
    Digit (solution row col)

-- 这个 theorem 应该失败：互异性不能推出 `1..9` 范围。
theorem cannotRecoverDigitRange
    (solution : Grid) :
    BadRowsValidUniqueButNoDigitRange solution ->
    SolutionCellsAreDigits solution := by
  intro h
  exact h
