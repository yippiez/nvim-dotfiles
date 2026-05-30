#!/usr/bin/env bash
# Opening many files at once, and re-opening a file whose view (folds/cursor) was
# already saved. Lazy-loading means N files shouldn't cost N× a single open, and
# the loadview on BufWinEnter shouldn't make a warm reopen slower.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

for i in $(seq 1 20); do printf 'local m%s = %s\nreturn m%s\n' "$i" "$i" "$i" > "$BENCH_TMP/f$i.lua"; done

echo "== Multi-file / warm reopen (min of $RUNS runs) =="
bench_startup "open 1 file"      "$BENCH_TMP/f1.lua"
bench_startup "open 10 files"    "$BENCH_TMP"/f{1,2,3,4,5,6,7,8,9,10}.lua
bench_startup "open 20 files"    "$BENCH_TMP"/f*.lua

# Warm reopen: prime the view file once, then measure reopening.
"$NVIM" --headless "$BENCH_TMP/f1.lua" "+normal! zfj" +wq >/dev/null 2>&1 || true
bench_startup "warm reopen (view cached)" "$BENCH_TMP/f1.lua"
