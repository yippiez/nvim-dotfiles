#!/usr/bin/env bash
# Buffer switching cost. The config saves/restores folds via mkview/loadview on
# BufWinLeave/BufWinEnter for code filetypes, which does file I/O on every
# switch. This measures repeated :bnext across a handful of code buffers.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

files=()
for i in 1 2 3 4 5; do
  printf 'local m%s = {}\nfunction m%s.f() return %s end\nreturn m%s\n' "$i" "$i" "$i" "$i" \
    > "$BENCH_TMP/mod$i.lua"
  files+=("$BENCH_TMP/mod$i.lua")
done

vals=()
for i in $(seq 1 "$RUNS"); do
  out="$("$NVIM" --headless "${files[@]}" \
    "+lua pcall(function() vim.cmd('doautocmd User VeryLazy') end); local t=vim.uv.hrtime(); for _=1,50 do vim.cmd('silent! bnext') end; io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
    +qa 2>/dev/null)" || true
  vals+=("$out")
done
echo "== Buffer switching (min of $RUNS runs) =="
printf '  %-42s %8s ms\n' "50x :bnext (mkview/loadview)" "$(_min "${vals[@]}")"
