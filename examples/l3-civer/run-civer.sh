#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CIVER_CACHE_ROOT="${XDG_CACHE_HOME:-${HOME:-$REPO_ROOT}/.cache}"
CIVER_DIR="${CIVER_DIR:-$CIVER_CACHE_ROOT/zk-formalvk/circom_civer}"
CIVER_REF="${CIVER_REF:-af7d4ed0325e6f7743d8a1ac0e415d0c69b8aae8}"
DEMO_DIR="$REPO_ROOT/examples/l3-civer"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

if [[ ! -d "$CIVER_DIR/.git" ]]; then
  mkdir -p "$(dirname "$CIVER_DIR")"
  git clone https://github.com/costa-group/circom_civer.git "$CIVER_DIR"
fi

if ! git -C "$CIVER_DIR" cat-file -e "$CIVER_REF^{commit}" 2>/dev/null; then
  git -C "$CIVER_DIR" fetch --depth 1 origin "$CIVER_REF"
fi
git -C "$CIVER_DIR" checkout --detach --quiet "$CIVER_REF"

echo "[CIVER] building pinned upstream commit"
cargo build --manifest-path "$CIVER_DIR/Cargo.toml" --release --locked
CIVER_BIN="$CIVER_DIR/target/release/civer_circom"

run_check() {
  local label=$1
  local circuit=$2
  local mode=$3
  local expected=$4
  local output
  local status

  echo
  echo "[CIVER] $label"
  set +e
  output=$(cd "$WORK_DIR" && "$CIVER_BIN" "$DEMO_DIR/$circuit" "$mode" 2>&1)
  status=$?
  set -e
  printf '%s\n' "$output"

  if [[ "$status" -ne 0 ]]; then
    echo "[CIVER] command failed with exit code $status" >&2
    return "$status"
  fi
  if [[ "$output" != *"$expected"* ]]; then
    echo "[CIVER] expected verdict not found: $expected" >&2
    return 1
  fi
}

run_check "safe circuit is deterministic" \
  safe_double.circom --check_safety \
  "All components satisfy weak safety"
run_check "safe circuit satisfies its specification" \
  safe_double.circom --check_postconditions \
  "All postconditions were verified"
run_check "unconstrained output is rejected" \
  unsafe_double.circom --check_safety \
  "could not verify weak safety"
run_check "wrong circuit is still deterministic" \
  wrong_double.circom --check_safety \
  "All components satisfy weak safety"
run_check "functional specification catches the wrong circuit" \
  wrong_double.circom --check_postconditions \
  "could not verify all postconditions"

echo
echo "[CIVER] all expected verdicts observed"