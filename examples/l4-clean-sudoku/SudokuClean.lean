import Clean.Circuit
import Clean.Utils.Primes

namespace ZkFormalVk.CleanSudoku

variable {p : Nat} [Fact p.Prime]

abbrev Grid (alpha : Type) := Vector alpha 4

def Digit (x : F p) : Prop :=
  x = 1 ∨ x = 2

def AllDigits (grid : Grid (F p)) : Prop :=
  ∀ i (_ : i < 4), Digit grid[i]

def GivenCells (grid : Grid (F p)) : Prop :=
  grid[0] = 1 ∧ grid[3] = 1

def PairOk (a b : F p) : Prop :=
  a + b = 3

def RowsOk (grid : Grid (F p)) : Prop :=
  PairOk grid[0] grid[1] ∧ PairOk grid[2] grid[3]

def ColsOk (grid : Grid (F p)) : Prop :=
  PairOk grid[0] grid[2] ∧ PairOk grid[1] grid[3]

def SudokuSpec (grid : Grid (F p)) : Prop :=
  AllDigits grid ∧ GivenCells grid ∧ RowsOk grid ∧ ColsOk grid

def pairExpr (a b : Expression (F p)) : Expression (F p) :=
  a + b - 3

def constraints (grid : Grid (Expression (F p))) : Operations (F p) := [
  .assert (grid[0] - 1),
  .assert (grid[3] - 1),
  .assert (pairExpr grid[0] grid[1]),
  .assert (pairExpr grid[2] grid[3]),
  .assert (pairExpr grid[0] grid[2]),
  .assert (pairExpr grid[1] grid[3])
]

def main (grid : Grid (Expression (F p))) : Circuit (F p) Unit :=
  fun _ => ((), constraints grid)

def circuit : FormalAssertion (F p) (fields 4) where
  main
  elaborated := {
    localLength _ := 0
    localLength_eq := by
      intro input offset
      simp [main, constraints, circuit_norm]
    output _ _ := ()
    output_eq := by
      intro input offset
      simp [main, constraints, circuit_norm]
    subcircuitsConsistent := by
      intro input offset
      simp [main, constraints, circuit_norm]
    channelsLawful := by
      intro input offset
      simp [main, constraints, circuit_norm]
  }
  requirementsChannelsLawful := by
    intro input offset
    simp [main, constraints, circuit_norm]
  Assumptions := AllDigits
  Spec := SudokuSpec
  soundness := by
    circuit_proof_start
    simp [SudokuSpec, AllDigits, GivenCells, RowsOk, ColsOk, PairOk,
      main, constraints, pairExpr, sub_eq_zero, circuit_norm] at h_holds ⊢
    subst input
    rcases h_holds with ⟨h0, h3, h01, h23, h02, h13⟩
    exact ⟨h_assumptions,
      ⟨by simpa [Vector.getElem_map] using h0, by simpa [Vector.getElem_map] using h3⟩,
      ⟨by simpa [Vector.getElem_map] using h01, by simpa [Vector.getElem_map] using h23⟩,
      ⟨by simpa [Vector.getElem_map] using h02, by simpa [Vector.getElem_map] using h13⟩⟩
  completeness := by
    circuit_proof_start
    simp [SudokuSpec, AllDigits, GivenCells, RowsOk, ColsOk, PairOk,
      main, constraints, pairExpr, sub_eq_zero, circuit_norm] at h_spec ⊢
    subst input
    rcases h_spec with ⟨_, ⟨h0, h3⟩, ⟨h01, h23⟩, ⟨h02, h13⟩⟩
    exact ⟨by simpa [Vector.getElem_map] using h0,
      by simpa [Vector.getElem_map] using h3,
      by simpa [Vector.getElem_map] using h01,
      by simpa [Vector.getElem_map] using h23,
      by simpa [Vector.getElem_map] using h02,
      by simpa [Vector.getElem_map] using h13⟩

example : FormalAssertion (F pBabybear) (fields 4) := circuit

end ZkFormalVk.CleanSudoku
