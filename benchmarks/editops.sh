#!/usr/bin/env bash
# Common editing operations on a ~500-line buffer: treesitter reindent, search,
# global substitute, and paste. These are the things you actually do all day.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

# ~500 lines of indentable python-ish code.
{ for i in $(seq 1 500); do
    printf 'def func_%s(a, b):\n    x = a + b  # comment\n    return x\n' "$i"
  done; } > "$BENCH_TMP/ops.py"

# ~5000 line file for search.
yes 'local x = function(a,b) return a+b end' | head -5000 > "$BENCH_TMP/grep.lua"

echo "== Editing operations (min of $RUNS runs) =="
bench_file_op "reindent gg=G (treesitter, ~1500 ln)" "$BENCH_TMP/ops.py" \
  "vim.cmd('silent! normal! gg=G')"
bench_file_op "search 100x n (5000 ln)" "$BENCH_TMP/grep.lua" \
  "vim.fn.search('return'); for _=1,100 do vim.cmd('silent! normal! n') end"
bench_file_op "substitute %s/a/b/g (5000 ln)" "$BENCH_TMP/grep.lua" \
  "vim.cmd('silent! %s/return/RET/g')"
bench_file_op "paste 100x p" "$BENCH_TMP/ops.py" \
  "vim.cmd('normal! yy'); for _=1,100 do vim.cmd('silent! normal! p') end"
