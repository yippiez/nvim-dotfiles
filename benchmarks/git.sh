#!/usr/bin/env bash
# gitsigns cost: attaching to a tracked buffer (runs git to compute the diff) and
# navigating hunks (]c / [c). Runs inside the nvim config repo, which is a real
# git repo with history.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

REPO="$(cd "$DIR/.." && pwd)"
TARGET="$REPO/init.lua"

if ! git -C "$REPO" rev-parse >/dev/null 2>&1; then
  echo "== gitsigns =="; echo "  not a git repo — skipping"; exit 0
fi

bench_git() {
  local label="$1" body="$2"
  local vals=() i out
  for i in $(seq 1 "$RUNS"); do
    out="$(cd "$REPO" && "$NVIM" --headless "$TARGET" \
      "+lua vim.wait(2000, function() local ok,c=pcall(require,'gitsigns.cache'); return ok and c.cache[vim.api.nvim_get_current_buf()]~=nil end, 20); local t=vim.uv.hrtime(); $body; io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
      "+qa!" 2>/dev/null)" || true
    vals+=("$out")
  done
  BENCH_RESULT="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "$label" "${BENCH_RESULT:-ERR}"
}

echo "== gitsigns (min of $RUNS runs) =="
# Attach latency: open -> diff computed (cache populated).
vals=()
for i in $(seq 1 "$RUNS"); do
  out="$(cd "$REPO" && "$NVIM" --headless "$TARGET" \
    "+lua local t=vim.uv.hrtime(); require('gitsigns'); vim.wait(2000, function() local ok,c=pcall(require,'gitsigns.cache'); return ok and c.cache[vim.api.nvim_get_current_buf()]~=nil end, 20); io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
    "+qa!" 2>/dev/null)" || true
  vals+=("$out")
done
printf '  %-42s %8s ms\n' "attach (open -> diff ready)" "$(_min "${vals[@]}")"

bench_git "100x next/prev hunk" \
  "for _=1,50 do pcall(function() require('gitsigns').next_hunk() end); pcall(function() require('gitsigns').prev_hunk() end) end"
