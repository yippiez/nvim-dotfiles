#!/usr/bin/env bash
# Bulk edit throughput: repeated normal-mode edits (the kind a macro replays) and
# undo of a large change. Catches per-edit overhead from autocmds/plugins.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

yes 'local x = function(a,b) return a+b end' | head -1000 > "$BENCH_TMP/m.lua"

echo "== Bulk edits / undo (min of $RUNS runs) =="
bench_file_op "500x append+delete edit" "$BENCH_TMP/m.lua" \
  "for _=1,500 do vim.cmd('silent! normal! A;'); vim.cmd('silent! normal! \$x') end"
bench_file_op "1000x j (cursor move)" "$BENCH_TMP/m.lua" \
  "for _=1,1000 do vim.cmd('silent! normal! j') end"
bench_file_op "undo 1000-line delete" "$BENCH_TMP/m.lua" \
  "vim.cmd('normal! ggdG'); vim.cmd('silent! undo')"
