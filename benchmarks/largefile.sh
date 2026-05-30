#!/usr/bin/env bash
# Large-file open. The config has a 100KB guard (is_large_file) that disables
# treesitter highlight/indent and folds for big files, falling back to regex
# syntax. This checks both sides of that guard and a genuinely huge file.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

# ~60KB lua file (under the 100KB guard -> treesitter ON)
yes 'local x = function(a, b) return a + b end  -- line of code' 2>/dev/null \
  | head -1200 > "$BENCH_TMP/medium.lua"
# ~600KB lua file (over the guard -> treesitter OFF, regex fallback)
yes 'local x = function(a, b) return a + b end  -- line of code' 2>/dev/null \
  | head -12000 > "$BENCH_TMP/big.lua"

mkb() { du -k "$1" | awk '{print $1"KB"}'; }

echo "== Large-file open (min of $RUNS runs) =="
bench_startup "medium .lua ($(mkb "$BENCH_TMP/medium.lua"), ts ON)"  "$BENCH_TMP/medium.lua"
bench_startup "big .lua ($(mkb "$BENCH_TMP/big.lua"), ts OFF guard)" "$BENCH_TMP/big.lua"
