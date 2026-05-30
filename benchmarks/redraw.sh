#!/usr/bin/env bash
# Statusline render cost. lualine re-evaluates its components on every redraw
# (cursor move, mode change, etc.), so a component that does real work each call
# is a hot-path cost. This times many statusline evaluations after lualine loads.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

# Load lualine (VeryLazy), open a few buffers so the buffer-count component has
# something to count, then evaluate the statusline N times.
LUA="pcall(function() vim.cmd('doautocmd User VeryLazy') end);
for i=1,5 do vim.cmd('badd /tmp/bench_sl_'..i..'.txt') end;
local sl = vim.o.statusline;
for _=1,2000 do vim.api.nvim_eval_statusline(sl, {}) end"

echo "== Statusline render (min of $RUNS runs) =="
bench_lua "2000x statusline eval" "$LUA"
