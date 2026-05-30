#!/usr/bin/env bash
# Open files of increasing size. Tests how open time scales with line count and
# whether the 100KB large-file guard (which disables treesitter highlight/indent
# and folds) kicks in to keep huge files snappy.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

gen() { yes 'local f = function(a, b) return a + b end  -- code line' | head -"$1"; }

gen 1000   > "$BENCH_TMP/n1k.lua"
gen 10000  > "$BENCH_TMP/n10k.lua"
gen 50000  > "$BENCH_TMP/n50k.lua"

kb() { du -k "$1" | awk '{print $1"KB"}'; }

echo "== Open by size (min of $RUNS runs) =="
bench_startup "1k lines  ($(kb "$BENCH_TMP/n1k.lua"))"   "$BENCH_TMP/n1k.lua"
bench_startup "10k lines ($(kb "$BENCH_TMP/n10k.lua"))"  "$BENCH_TMP/n10k.lua"
bench_startup "50k lines ($(kb "$BENCH_TMP/n50k.lua"), guard)" "$BENCH_TMP/n50k.lua"
