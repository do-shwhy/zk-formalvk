import Clean.Circuit
import Clean.Utils.Primes

set_option maxHeartbeats 2000000
set_option linter.unusedSimpArgs false

namespace ZkFormalVk.CleanSudoku9x9

variable {p : Nat} [Fact p.Prime]

abbrev Grid (alpha : Type) := Vector alpha 81
abbrev Group (alpha : Type) := Vector alpha 9

def Digit (x : F p) : Prop :=
  x = 1 ∨ x = 2 ∨ x = 3 ∨ x = 4 ∨ x = 5 ∨ x = 6 ∨ x = 7 ∨ x = 8 ∨ x = 9

def AllDigits (grid : Grid (F p)) : Prop :=
  ∀ i (_ : i < 81), Digit grid[i]

def sum9 (group : Group (F p)) : F p :=
  group[0] + group[1] + group[2] + group[3] + group[4] + group[5] + group[6] + group[7] + group[8]

def sqSum9 (group : Group (F p)) : F p :=
  group[0]*group[0] + group[1]*group[1] + group[2]*group[2] +
  group[3]*group[3] + group[4]*group[4] + group[5]*group[5] +
  group[6]*group[6] + group[7]*group[7] + group[8]*group[8]

def prod9 (group : Group (F p)) : F p :=
  group[0] * group[1] * group[2] * group[3] * group[4] * group[5] * group[6] * group[7] * group[8]

def GroupOk (group : Group (F p)) : Prop :=
  sum9 group = 45 ∧ sqSum9 group = 285 ∧ prod9 group = 362880

def row0 (g : Grid alpha) : Group alpha := #v[g[0], g[1], g[2], g[3], g[4], g[5], g[6], g[7], g[8]]
def row1 (g : Grid alpha) : Group alpha := #v[g[9], g[10], g[11], g[12], g[13], g[14], g[15], g[16], g[17]]
def row2 (g : Grid alpha) : Group alpha := #v[g[18], g[19], g[20], g[21], g[22], g[23], g[24], g[25], g[26]]
def row3 (g : Grid alpha) : Group alpha := #v[g[27], g[28], g[29], g[30], g[31], g[32], g[33], g[34], g[35]]
def row4 (g : Grid alpha) : Group alpha := #v[g[36], g[37], g[38], g[39], g[40], g[41], g[42], g[43], g[44]]
def row5 (g : Grid alpha) : Group alpha := #v[g[45], g[46], g[47], g[48], g[49], g[50], g[51], g[52], g[53]]
def row6 (g : Grid alpha) : Group alpha := #v[g[54], g[55], g[56], g[57], g[58], g[59], g[60], g[61], g[62]]
def row7 (g : Grid alpha) : Group alpha := #v[g[63], g[64], g[65], g[66], g[67], g[68], g[69], g[70], g[71]]
def row8 (g : Grid alpha) : Group alpha := #v[g[72], g[73], g[74], g[75], g[76], g[77], g[78], g[79], g[80]]

def col0 (g : Grid alpha) : Group alpha := #v[g[0], g[9], g[18], g[27], g[36], g[45], g[54], g[63], g[72]]
def col1 (g : Grid alpha) : Group alpha := #v[g[1], g[10], g[19], g[28], g[37], g[46], g[55], g[64], g[73]]
def col2 (g : Grid alpha) : Group alpha := #v[g[2], g[11], g[20], g[29], g[38], g[47], g[56], g[65], g[74]]
def col3 (g : Grid alpha) : Group alpha := #v[g[3], g[12], g[21], g[30], g[39], g[48], g[57], g[66], g[75]]
def col4 (g : Grid alpha) : Group alpha := #v[g[4], g[13], g[22], g[31], g[40], g[49], g[58], g[67], g[76]]
def col5 (g : Grid alpha) : Group alpha := #v[g[5], g[14], g[23], g[32], g[41], g[50], g[59], g[68], g[77]]
def col6 (g : Grid alpha) : Group alpha := #v[g[6], g[15], g[24], g[33], g[42], g[51], g[60], g[69], g[78]]
def col7 (g : Grid alpha) : Group alpha := #v[g[7], g[16], g[25], g[34], g[43], g[52], g[61], g[70], g[79]]
def col8 (g : Grid alpha) : Group alpha := #v[g[8], g[17], g[26], g[35], g[44], g[53], g[62], g[71], g[80]]

def box0 (g : Grid alpha) : Group alpha := #v[g[0], g[1], g[2], g[9], g[10], g[11], g[18], g[19], g[20]]
def box1 (g : Grid alpha) : Group alpha := #v[g[3], g[4], g[5], g[12], g[13], g[14], g[21], g[22], g[23]]
def box2 (g : Grid alpha) : Group alpha := #v[g[6], g[7], g[8], g[15], g[16], g[17], g[24], g[25], g[26]]
def box3 (g : Grid alpha) : Group alpha := #v[g[27], g[28], g[29], g[36], g[37], g[38], g[45], g[46], g[47]]
def box4 (g : Grid alpha) : Group alpha := #v[g[30], g[31], g[32], g[39], g[40], g[41], g[48], g[49], g[50]]
def box5 (g : Grid alpha) : Group alpha := #v[g[33], g[34], g[35], g[42], g[43], g[44], g[51], g[52], g[53]]
def box6 (g : Grid alpha) : Group alpha := #v[g[54], g[55], g[56], g[63], g[64], g[65], g[72], g[73], g[74]]
def box7 (g : Grid alpha) : Group alpha := #v[g[57], g[58], g[59], g[66], g[67], g[68], g[75], g[76], g[77]]
def box8 (g : Grid alpha) : Group alpha := #v[g[60], g[61], g[62], g[69], g[70], g[71], g[78], g[79], g[80]]

def RowsOk (g : Grid (F p)) : Prop :=
  GroupOk (row0 g) ∧ GroupOk (row1 g) ∧ GroupOk (row2 g) ∧
  GroupOk (row3 g) ∧ GroupOk (row4 g) ∧ GroupOk (row5 g) ∧
  GroupOk (row6 g) ∧ GroupOk (row7 g) ∧ GroupOk (row8 g)

def ColsOk (g : Grid (F p)) : Prop :=
  GroupOk (col0 g) ∧ GroupOk (col1 g) ∧ GroupOk (col2 g) ∧
  GroupOk (col3 g) ∧ GroupOk (col4 g) ∧ GroupOk (col5 g) ∧
  GroupOk (col6 g) ∧ GroupOk (col7 g) ∧ GroupOk (col8 g)

def BoxesOk (g : Grid (F p)) : Prop :=
  GroupOk (box0 g) ∧ GroupOk (box1 g) ∧ GroupOk (box2 g) ∧
  GroupOk (box3 g) ∧ GroupOk (box4 g) ∧ GroupOk (box5 g) ∧
  GroupOk (box6 g) ∧ GroupOk (box7 g) ∧ GroupOk (box8 g)

def SudokuSpec (g : Grid (F p)) : Prop :=
  AllDigits g ∧ RowsOk g ∧ ColsOk g ∧ BoxesOk g

namespace Group9

def sumExpr (group : Group (Expression (F p))) : Expression (F p) :=
  group[0] + group[1] + group[2] + group[3] + group[4] + group[5] + group[6] + group[7] + group[8]

def sqSumExpr (group : Group (Expression (F p))) : Expression (F p) :=
  group[0]*group[0] + group[1]*group[1] + group[2]*group[2] +
  group[3]*group[3] + group[4]*group[4] + group[5]*group[5] +
  group[6]*group[6] + group[7]*group[7] + group[8]*group[8]

def prodExpr (group : Group (Expression (F p))) : Expression (F p) :=
  group[0] * group[1] * group[2] * group[3] * group[4] * group[5] * group[6] * group[7] * group[8]

def main (group : Group (Expression (F p))) : Circuit (F p) Unit := do
  sumExpr group - 45 === 0
  sqSumExpr group - 285 === 0
  prodExpr group - 362880 === 0

def circuit : FormalAssertion (F p) (fields 9) where
  main
  Spec := GroupOk
  soundness := by
    circuit_proof_start
    simp [GroupOk, sum9, sqSum9, prod9, main, sumExpr, sqSumExpr, prodExpr, sub_eq_zero, circuit_norm] at h_holds ⊢
    subst input
    exact ⟨by simpa [Vector.getElem_map] using h_holds.1,
      by simpa [Vector.getElem_map] using h_holds.2.1,
      by simpa [Vector.getElem_map] using h_holds.2.2⟩
  completeness := by
    circuit_proof_start
    simp [GroupOk, sum9, sqSum9, prod9, main, sumExpr, sqSumExpr, prodExpr, sub_eq_zero, circuit_norm] at h_spec ⊢
    subst input
    exact ⟨by simpa [Vector.getElem_map] using h_spec.1,
      by simpa [Vector.getElem_map] using h_spec.2.1,
      by simpa [Vector.getElem_map] using h_spec.2.2⟩

end Group9

namespace Rows

def main (grid : Grid (Expression (F p))) : Circuit (F p) Unit := do
  Group9.circuit (row0 grid); Group9.circuit (row1 grid); Group9.circuit (row2 grid)
  Group9.circuit (row3 grid); Group9.circuit (row4 grid); Group9.circuit (row5 grid)
  Group9.circuit (row6 grid); Group9.circuit (row7 grid); Group9.circuit (row8 grid)

def circuit : FormalAssertion (F p) (fields 81) where
  main
  Assumptions := AllDigits
  Spec := RowsOk
  soundness := by
    circuit_proof_start [Group9.circuit]
    simp [AllDigits, RowsOk,
      row0, row1, row2, row3, row4, row5, row6, row7, row8,
      main, Group9.circuit, Group9.main, GroupOk, sum9, sqSum9, prod9,
      Group9.sumExpr, Group9.sqSumExpr, Group9.prodExpr, sub_eq_zero, Vector.getElem_map, circuit_norm] at h_assumptions h_holds ⊢
    subst input
    aesop
  completeness := by
    circuit_proof_start [Group9.circuit]
    simp [AllDigits, RowsOk,
      row0, row1, row2, row3, row4, row5, row6, row7, row8,
      main, Group9.circuit, Group9.main, GroupOk, sum9, sqSum9, prod9,
      Group9.sumExpr, Group9.sqSumExpr, Group9.prodExpr, sub_eq_zero, Vector.getElem_map, circuit_norm] at h_assumptions h_spec ⊢
    subst input
    aesop

end Rows

namespace Cols

def main (grid : Grid (Expression (F p))) : Circuit (F p) Unit := do
  Group9.circuit (col0 grid); Group9.circuit (col1 grid); Group9.circuit (col2 grid)
  Group9.circuit (col3 grid); Group9.circuit (col4 grid); Group9.circuit (col5 grid)
  Group9.circuit (col6 grid); Group9.circuit (col7 grid); Group9.circuit (col8 grid)

def circuit : FormalAssertion (F p) (fields 81) where
  main
  Assumptions := AllDigits
  Spec := ColsOk
  soundness := by
    circuit_proof_start [Group9.circuit]
    simp [AllDigits, ColsOk,
      col0, col1, col2, col3, col4, col5, col6, col7, col8,
      main, Group9.circuit, Group9.main, GroupOk, sum9, sqSum9, prod9,
      Group9.sumExpr, Group9.sqSumExpr, Group9.prodExpr, sub_eq_zero, Vector.getElem_map, circuit_norm] at h_holds ⊢
    subst input
    aesop
  completeness := by
    circuit_proof_start [Group9.circuit]
    simp [AllDigits, ColsOk,
      col0, col1, col2, col3, col4, col5, col6, col7, col8,
      main, Group9.circuit, Group9.main, GroupOk, sum9, sqSum9, prod9,
      Group9.sumExpr, Group9.sqSumExpr, Group9.prodExpr, sub_eq_zero, Vector.getElem_map, circuit_norm] at h_spec ⊢
    subst input
    aesop

end Cols

namespace Boxes

def main (grid : Grid (Expression (F p))) : Circuit (F p) Unit := do
  Group9.circuit (box0 grid); Group9.circuit (box1 grid); Group9.circuit (box2 grid)
  Group9.circuit (box3 grid); Group9.circuit (box4 grid); Group9.circuit (box5 grid)
  Group9.circuit (box6 grid); Group9.circuit (box7 grid); Group9.circuit (box8 grid)

def circuit : FormalAssertion (F p) (fields 81) where
  main
  Assumptions := AllDigits
  Spec := BoxesOk
  soundness := by
    circuit_proof_start [Group9.circuit]
    simp [AllDigits, BoxesOk,
      box0, box1, box2, box3, box4, box5, box6, box7, box8,
      main, Group9.circuit, Group9.main, GroupOk, sum9, sqSum9, prod9,
      Group9.sumExpr, Group9.sqSumExpr, Group9.prodExpr, sub_eq_zero, Vector.getElem_map, circuit_norm] at h_holds ⊢
    subst input
    aesop
  completeness := by
    circuit_proof_start [Group9.circuit]
    simp [AllDigits, BoxesOk,
      box0, box1, box2, box3, box4, box5, box6, box7, box8,
      main, Group9.circuit, Group9.main, GroupOk, sum9, sqSum9, prod9,
      Group9.sumExpr, Group9.sqSumExpr, Group9.prodExpr, sub_eq_zero, Vector.getElem_map, circuit_norm] at h_spec ⊢
    subst input
    aesop

end Boxes

namespace Sudoku

def main (grid : Grid (Expression (F p))) : Circuit (F p) Unit := do
  Rows.circuit grid
  Cols.circuit grid
  Boxes.circuit grid

def circuit : FormalAssertion (F p) (fields 81) where
  main
  Assumptions := AllDigits
  Spec := SudokuSpec
  soundness := by
    circuit_proof_start [Rows.circuit, Cols.circuit, Boxes.circuit]
    simp [SudokuSpec, main, Rows.circuit, Cols.circuit, Boxes.circuit, circuit_norm] at h_holds ⊢
    subst input
    aesop
  completeness := by
    circuit_proof_start [Rows.circuit, Cols.circuit, Boxes.circuit]
    simp [SudokuSpec, main, Rows.circuit, Cols.circuit, Boxes.circuit, circuit_norm] at h_spec ⊢
    subst input
    aesop

example : FormalAssertion (F pBabybear) (fields 9) := Group9.circuit
example : FormalAssertion (F pBabybear) (fields 81) := Rows.circuit
example : FormalAssertion (F pBabybear) (fields 81) := Cols.circuit
example : FormalAssertion (F pBabybear) (fields 81) := Boxes.circuit
example : FormalAssertion (F pBabybear) (fields 81) := circuit

end Sudoku

end ZkFormalVk.CleanSudoku9x9
