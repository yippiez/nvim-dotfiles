#!/usr/bin/env bash
# Oil file-explorer cost: opening a small directory vs a large one. Oil is lazy
# (cmd/keys), so the first :Oil also pays the plugin load. Listing a big dir is
# the practical worry.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

small="$BENCH_TMP/small"; big="$BENCH_TMP/big"
mkdir -p "$small" "$big"
for i in $(seq 1 5);   do : > "$small/f$i.txt"; done
for i in $(seq 1 1000); do : > "$big/f$i.txt"; done

echo "== Oil (min of $RUNS runs) =="
bench_lua "open small dir (5 entries, cold)" \
  "local t=vim.uv.hrtime(); vim.cmd('Oil $small'); vim.wait(500, function() return vim.bo.filetype=='oil' end, 5)"
bench_lua "open big dir (1000 entries)" \
  "vim.cmd('Oil $small'); vim.cmd('Oil $big'); vim.wait(2000, function() return vim.api.nvim_buf_line_count(0) > 500 end, 10)"
