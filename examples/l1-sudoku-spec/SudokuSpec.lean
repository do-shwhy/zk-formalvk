/-!
这是一个 L1 规格层示例。

验证元信息：
- Lean 版本：Lean 4.31.0；
- Lean commit：68218e876d2a38b1985b8590fff244a83c321783；
- 运行结果：exit code 0，无输出；
- 说明：包含规格定义检查，以及几个具体坏 witness 不满足规格的证明。

目标不是写电路、AIR、R1CS、witness generator 或 verifier，
而是先用 Lean 把“数独证明到底想证明什么”定义清楚。

业务语义：
- public puzzle 可以直接公开，也可以只公开 puzzle hash；
- private solution 是证明者隐藏的答案；
- 如果只公开 hash，则 private puzzle / solution 必须和公开 hash 绑定；
- solution 必须保留 puzzle 中所有非零给定格；
- solution 的每个格子都必须是 1..9；
- 每一行、每一列、每个 3x3 宫都必须包含且只包含 1..9。

后续 DSL、电路、AIR、verifier 层都应该 refinement 到这里定义的 relation。
-/

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

def SudokuSolution (puzzle solution : Grid) : Prop :=
  PuzzleCellsAreValid puzzle ∧
  SolutionCellsAreDigits solution ∧
  GivenPreserved puzzle solution ∧
  RowsValid solution ∧
  ColsValid solution ∧
  BoxesValid solution

def SudokuWitness (puzzle solution : Grid) : Prop :=
  SudokuSolution puzzle solution

def SudokuStatement
    (publicPuzzleHash publicSolutionHash : Hash)
    (privatePuzzle privateSolution : Grid) : Prop :=
  GridHash privatePuzzle = publicPuzzleHash ∧
  GridHash privateSolution = publicSolutionHash ∧
  SudokuWitness privatePuzzle privateSolution

/-!
下面几个 theorem 展示这个 L1 规格不是“摆设”。

它们分别证明：
- 如果答案篡改了题目中的非零给定格，则不可能满足 `SudokuSolution`；
- 如果答案里出现 `10`，则不可能满足 `SudokuSolution`；
- 如果某一行全是 `1`，则不可能满足 `SudokuSolution`。

这些证明仍然只是 L1 规格层证明：
它们没有证明任何电路实现正确，只说明当前业务规格确实能排除这些坏 witness。
-/

def EmptyPuzzle : Grid :=
  fun _ _ => 0

def PuzzleWithGivenFive : Grid :=
  fun row col =>
    if row = 0 ∧ col = 0 then 5 else 0

def PuzzleWithInvalidGiven : Grid :=
  fun row col =>
    if row = 0 ∧ col = 0 then 42 else 0

def SolutionChangesGiven : Grid :=
  fun row col =>
    if row = 0 ∧ col = 0 then 6 else 1

def SolutionWithTen : Grid :=
  fun row col =>
    if row = 0 ∧ col = 0 then 10 else 1

def ConstantOneSolution : Grid :=
  fun _ _ => 1

theorem changedGivenRejected :
    ¬ SudokuSolution PuzzleWithGivenFive SolutionChangesGiven := by
  intro h
  rcases h with ⟨_, _, hGiven, _, _, _⟩
  have hPuzzleNonzero : PuzzleWithGivenFive 0 0 ≠ 0 := by
    decide
  have hEq := hGiven 0 0 (by decide) (by decide) hPuzzleNonzero
  simp [PuzzleWithGivenFive, SolutionChangesGiven] at hEq

theorem answerDigitRangeRejected :
    ¬ SudokuSolution EmptyPuzzle SolutionWithTen := by
  intro h
  rcases h with ⟨_, hDigits, _, _, _, _⟩
  have hDigit := hDigits 0 0 ⟨by decide, by decide⟩
  have hNotDigit : ¬ Digit 10 := by
    intro h
    exact (Nat.not_succ_le_self 9) h.2
  apply hNotDigit
  simpa [SolutionWithTen] using hDigit

theorem invalidPuzzleDigitRejected :
    ¬ SudokuSolution PuzzleWithInvalidGiven ConstantOneSolution := by
  intro h
  rcases h with ⟨hPuzzle, _, _, _, _, _⟩
  have hCell := hPuzzle 0 0 ⟨by decide, by decide⟩
  have hInvalid : ¬ (42 = 0 ∨ Digit 42) := by
    intro h
    cases h with
    | inl hZero => cases hZero
    | inr hDigit =>
        exact (Nat.not_succ_le_self 41) (Nat.le_trans hDigit.2 (by decide))
  apply hInvalid
  simpa [PuzzleWithInvalidGiven] using hCell

theorem repeatedRowRejected :
    ¬ SudokuSolution EmptyPuzzle ConstantOneSolution := by
  intro h
  rcases h with ⟨_, _, _, hRows, _, _⟩
  have hTwoIsDigit : Digit 2 := by
    unfold Digit
    exact ⟨by decide, by decide⟩
  have hRow := hRows 0 (by decide) 2 hTwoIsDigit
  rcases hRow with ⟨_, hCol, _⟩
  have hBad : (1 : Nat) = 2 := by
    simpa [ConstantOneSolution] using hCol.2
  cases hBad
