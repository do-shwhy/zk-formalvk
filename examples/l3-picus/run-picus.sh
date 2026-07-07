#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PICUS_CACHE_ROOT="${XDG_CACHE_HOME:-${HOME:-$REPO_ROOT}/.cache}"
PICUS_DIR="${PICUS_DIR:-$PICUS_CACHE_ROOT/zk-formalvk/Picus}"
PICUS_IMAGE="${PICUS_IMAGE:-picus:zk-formalvk}"

if [[ ! -d "$PICUS_DIR/.git" ]]; then
  mkdir -p "$(dirname "$PICUS_DIR")"
  git clone --depth 1 https://github.com/Veridise/Picus.git "$PICUS_DIR"
fi

docker build -t "$PICUS_IMAGE" "$PICUS_DIR"

set +e
docker run --rm --memory=10g \
  -v "$REPO_ROOT:/workspace" \
  "$PICUS_IMAGE" \
  sh -lc './run-picus /workspace/examples/l3-picus/unsafe_square.circom'
status=$?
set -e

if [[ "$status" -eq 9 ]]; then
  echo "Picus found the expected under-constrained counterexample (exit code 9)."
  exit 0
fi

exit "$status"
