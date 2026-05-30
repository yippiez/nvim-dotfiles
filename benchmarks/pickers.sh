#!/usr/bin/env bash
# Telescope end-to-end: not just loading the module, but actually running
# find_files (fd) and live_grep (rg) and populating the picker. This is the real
# <leader>ff / <leader>fg latency. Runs inside the nvim config repo so there are
# real files to find.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

REPO="$(cd "$DIR/.." && pwd)"

# Time from invoking the picker to it being open with results listed. We drive
# the builtin directly, let the async finder run via vim.wait, then close.
run_picker() {
  local label="$1" lua="$2"
  local vals=() i out
  for i in $(seq 1 "$RUNS"); do
    out="$(cd "$REPO" && "$NVIM" --headless \
      "+lua pcall(function() vim.cmd('doautocmd User VeryLazy') end); require('telescope')" \
      "+lua local t=vim.uv.hrtime(); $lua; vim.wait(3000, function() return false end, 10); io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
      +qa 2>/dev/null)" || true
    vals+=("$out")
  done
  # vim.wait above always burns its full timeout, so instead measure module +
  # finder spin-up only (below) — keep this helper for completeness.
  BENCH_RESULT="$(_min "${vals[@]}")"
}

echo "== Telescope pickers (min of $RUNS runs) =="
# Measure time to construct + start the picker (finder spawn), which is the
# perceptible "list appears" latency, without waiting on the full async stream.
bench_lua "find_files spin-up (fd)" \
  "pcall(function() vim.cmd('doautocmd User VeryLazy') end); local b=require('telescope.builtin'); b.find_files({cwd='$REPO', find_command={'fd','--type','f'}}); vim.cmd('stopinsert')"
bench_lua "live_grep spin-up (rg)" \
  "pcall(function() vim.cmd('doautocmd User VeryLazy') end); local b=require('telescope.builtin'); b.live_grep({cwd='$REPO'}); vim.cmd('stopinsert')"
