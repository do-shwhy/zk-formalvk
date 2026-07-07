/-!
期望失败 5：题目给定格保持关系的蕴含方向写反。

这个文件尝试从错误方向的保持关系推出正确方向的保持关系，
但少了“solution 该格非零”的前提，所以 Lean 应该拒绝该 theorem 证明。
-/

abbrev Grid := Nat -> Nat -> Nat

def GivenPreserved (puzzle solution : Grid) : Prop :=
  ∀ row col,
    row < 9 ->
    col < 9 ->
    puzzle row col ≠ 0 ->
    solution row col = puzzle row col

def BadGivenPreservedWrongDirection (puzzle solution : Grid) : Prop :=
  ∀ row col,
    row < 9 ->
    col < 9 ->
    solution row col ≠ 0 ->
    solution row col = puzzle row col

-- 这个 theorem 应该失败：错误方向不能推出正确方向。
theorem cannotRecoverCorrectGivenPreserved
    (puzzle solution : Grid) :
    BadGivenPreservedWrongDirection puzzle solution ->
    GivenPreserved puzzle solution := by
  intro h row col hRow hCol hPuzzleNonzero
  exact h row col hRow hCol hPuzzleNonzero
