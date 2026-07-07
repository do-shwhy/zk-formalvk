(**
这是一个 L1 规格层的 Coq/Rocq 版本示例。

验证元信息：
- Coq/Rocq 版本：The Rocq Prover 9.1.1；
- OCaml 版本：4.14.2；
- 运行命令：coqc examples/l1-sudoku-spec/SudokuSpec.v；
- 说明：本文件模仿 SudokuSpec.lean，定义同一个数独业务 relation，
  并证明几个具体坏 witness 不满足该 relation。
*)

From Stdlib Require Import Arith.Arith.
From Stdlib Require Import Lia.

Definition Grid := nat -> nat -> nat.
Definition Hash := nat.

Parameter GridHash : Grid -> Hash.

Definition Digit (n : nat) : Prop :=
  1 <= n /\ n <= 9.

Definition ExistsUniqueNat (p : nat -> Prop) : Prop :=
  exists value, p value /\ forall other, p other -> other = value.

Definition ExistsUniquePair (p : nat * nat -> Prop) : Prop :=
  exists value, p value /\ forall other, p other -> other = value.

Definition CellIndex (row col : nat) : Prop :=
  row < 9 /\ col < 9.

Definition PuzzleCellsAreValid (puzzle : Grid) : Prop :=
  forall row col,
    CellIndex row col ->
    puzzle row col = 0 \/ Digit (puzzle row col).

Definition SolutionCellsAreDigits (solution : Grid) : Prop :=
  forall row col,
    CellIndex row col ->
    Digit (solution row col).

Definition GivenPreserved (puzzle solution : Grid) : Prop :=
  forall row col,
    row < 9 ->
    col < 9 ->
    puzzle row col <> 0 ->
    solution row col = puzzle row col.

Definition RowsValid (solution : Grid) : Prop :=
  forall row,
    row < 9 ->
    forall digit,
      Digit digit ->
      ExistsUniqueNat (fun col => col < 9 /\ solution row col = digit).

Definition ColsValid (solution : Grid) : Prop :=
  forall col,
    col < 9 ->
    forall digit,
      Digit digit ->
      ExistsUniqueNat (fun row => row < 9 /\ solution row col = digit).

Definition BoxesValid (solution : Grid) : Prop :=
  forall boxRow boxCol,
    boxRow < 3 ->
    boxCol < 3 ->
    forall digit,
      Digit digit ->
      ExistsUniquePair (fun offset : nat * nat =>
        fst offset < 3 /\
        snd offset < 3 /\
        solution (3 * boxRow + fst offset) (3 * boxCol + snd offset) = digit).

Definition SudokuSolution (puzzle solution : Grid) : Prop :=
  PuzzleCellsAreValid puzzle /\
  SolutionCellsAreDigits solution /\
  GivenPreserved puzzle solution /\
  RowsValid solution /\
  ColsValid solution /\
  BoxesValid solution.

Definition SudokuWitness (puzzle solution : Grid) : Prop :=
  SudokuSolution puzzle solution.

Definition SudokuStatement
    (publicPuzzleHash publicSolutionHash : Hash)
    (privatePuzzle privateSolution : Grid) : Prop :=
  GridHash privatePuzzle = publicPuzzleHash /\
  GridHash privateSolution = publicSolutionHash /\
  SudokuWitness privatePuzzle privateSolution.

Definition EmptyPuzzle : Grid :=
  fun _ _ => 0.

Definition PuzzleWithGivenFive : Grid :=
  fun row col =>
    if Nat.eqb row 0 then if Nat.eqb col 0 then 5 else 0 else 0.

Definition PuzzleWithInvalidGiven : Grid :=
  fun row col =>
    if Nat.eqb row 0 then if Nat.eqb col 0 then 42 else 0 else 0.

Definition SolutionChangesGiven : Grid :=
  fun row col =>
    if Nat.eqb row 0 then if Nat.eqb col 0 then 6 else 1 else 1.

Definition SolutionWithTen : Grid :=
  fun row col =>
    if Nat.eqb row 0 then if Nat.eqb col 0 then 10 else 1 else 1.

Definition ConstantOneSolution : Grid :=
  fun _ _ => 1.

Theorem changedGivenRejected :
  ~ SudokuSolution PuzzleWithGivenFive SolutionChangesGiven.
Proof.
  intros H.
  destruct H as [_ [_ [HGiven _]]].
  specialize (HGiven 0 0 ltac:(lia) ltac:(lia)).
  assert (PuzzleWithGivenFive 0 0 <> 0) by (unfold PuzzleWithGivenFive; simpl; lia).
  specialize (HGiven H).
  unfold PuzzleWithGivenFive, SolutionChangesGiven in HGiven.
  simpl in HGiven.
  discriminate HGiven.
Qed.

Theorem answerDigitRangeRejected :
  ~ SudokuSolution EmptyPuzzle SolutionWithTen.
Proof.
  intros H.
  destruct H as [_ [HDigits _]].
  specialize (HDigits 0 0 ltac:(split; lia)).
  unfold SolutionWithTen in HDigits.
  simpl in HDigits.
  unfold Digit in HDigits.
  lia.
Qed.

Theorem invalidPuzzleDigitRejected :
  ~ SudokuSolution PuzzleWithInvalidGiven ConstantOneSolution.
Proof.
  intros H.
  destruct H as [HPuzzle _].
  specialize (HPuzzle 0 0 ltac:(split; lia)).
  unfold PuzzleWithInvalidGiven in HPuzzle.
  simpl in HPuzzle.
  destruct HPuzzle as [HZero | HDigit].
  - discriminate HZero.
  - unfold Digit in HDigit; lia.
Qed.

Theorem repeatedRowRejected :
  ~ SudokuSolution EmptyPuzzle ConstantOneSolution.
Proof.
  intros H.
  destruct H as [_ [_ [_ [HRows _]]]].
  assert (HTwoDigit : Digit 2) by (unfold Digit; lia).
  specialize (HRows 0 ltac:(lia) 2 HTwoDigit).
  destruct HRows as [col [[_ HCol] _]].
  unfold ConstantOneSolution in HCol.
  discriminate HCol.
Qed.
