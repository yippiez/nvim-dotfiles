#!/usr/bin/env bash
# Clipboard copy cost. With clipboard=unnamedplus, EVERY yank/delete/change
# writes the + register, invoking the clipboard provider's copy. If that copy
# shells out to win32yank.exe it blocks ~200ms each time; OSC52 copy is a
# terminal escape with no spawn. This times one copy via the configured provider
# and shows the raw win32yank spawn cost for reference.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

echo "== Clipboard (min of $RUNS runs) =="
# One copy through whatever vim.g.clipboard.copy['+'] is configured to be.
bench_lua "copy 1 line via provider" \
  "local c = vim.g.clipboard and vim.g.clipboard.copy and vim.g.clipboard.copy['+']; if type(c)=='function' then c({'hello world'}, 'v') elseif type(c)=='table' then vim.fn.system(c, 'hello world') end"

# Reference: the cost of a single win32yank.exe spawn (the OLD per-yank penalty).
if command -v win32yank.exe >/dev/null 2>&1; then
  vals=()
  for i in $(seq 1 "$RUNS"); do
    t0=$(date +%s%N); echo "hello world" | win32yank.exe -i --crlf 2>/dev/null; t1=$(date +%s%N)
    vals+=("$(awk "BEGIN{printf \"%.3f\", ($t1-$t0)/1e6}")")
  done
  best="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "win32yank.exe spawn (reference)" "${best:-ERR}"
fi
