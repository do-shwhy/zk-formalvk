/-!
期望失败 4：public puzzle hash 绑定错对象。

这个文件尝试从坏 statement 推出 `privatePuzzle` 被绑定到 `publicPuzzleHash`，
但坏 statement 实际绑定的是 `privateSolution`，所以 Lean 应该拒绝该 theorem 证明。
-/

abbrev Grid := Nat -> Nat -> Nat
abbrev Hash := Nat

opaque GridHash : Grid -> Hash

def GoodSudokuSolution (_ _ : Grid) : Prop := True

def BadSudokuStatementWrongHashBinding
    (publicPuzzleHash : Hash)
    (privatePuzzle privateSolution : Grid) : Prop :=
  GridHash privateSolution = publicPuzzleHash ∧
  GoodSudokuSolution privatePuzzle privateSolution

-- 这个 theorem 应该失败：已有等式绑定的是 solution，不是 puzzle。
theorem cannotRecoverPuzzleHashBinding
    (publicPuzzleHash : Hash)
    (privatePuzzle privateSolution : Grid) :
    BadSudokuStatementWrongHashBinding publicPuzzleHash privatePuzzle privateSolution ->
    GridHash privatePuzzle = publicPuzzleHash := by
  intro h
  rcases h with ⟨hPuzzleHash, _⟩
  exact hPuzzleHash
