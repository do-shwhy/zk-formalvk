#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CLEAN_DIR=${CLEAN_DIR:-/tmp/zk-formalvk/clean}
CLEAN_REPO=https://github.com/Verified-zkEVM/clean.git

if [[ ! -d "$CLEAN_DIR/.git" ]]; then
  mkdir -p "$(dirname "$CLEAN_DIR")"
  git clone --depth 1 "$CLEAN_REPO" "$CLEAN_DIR"
fi

cd "$CLEAN_DIR"

echo "[clean] building Lean project"
lake build

echo "[clean] running official WitnessExport demo"
lake env lean Clean/Examples/WitnessExport.lean

echo "[clean] running zk-formalvk mini Sudoku demo"
lake env lean "$SCRIPT_DIR/SudokuClean.lean"

echo "[clean] running zk-formalvk split 9x9 Sudoku demo"
lake env lean "$SCRIPT_DIR/Sudoku9x9Clean.lean"

echo "[clean] ok"
