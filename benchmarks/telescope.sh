#!/usr/bin/env bash
# Cost of bringing Telescope up. The dominant first-`<leader>ff` latency is the
# cold require of the telescope module tree; this is what fzf-native + the
# VeryLazy preload + vim.loader were meant to cut down.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

echo "== Telescope (min of $RUNS runs) =="
bench_lua "cold require (telescope tree)" \
  "require('telescope'); require('telescope.builtin'); require('telescope.actions')"

# Confirm the compiled fzf-native sorter is present and loadable — without it,
# ranking falls back to the slow pure-Lua sorter.
so="$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim/build/libfzf.so"
if [ -f "$so" ]; then
  echo "  fzf-native libfzf.so                 BUILT"
else
  echo "  fzf-native libfzf.so                 MISSING (run :Lazy build telescope-fzf-native.nvim)"
fi

ext="$("$NVIM" --headless \
  "+lua pcall(function() vim.cmd('doautocmd User VeryLazy') end)" \
  "+lua local ok,ts=pcall(require,'telescope'); io.write((ok and ts.extensions and ts.extensions.fzf) and 'LOADED' or 'not loaded')" \
  +qa 2>/dev/null)"
echo "  fzf extension                        ${ext:-?}"
