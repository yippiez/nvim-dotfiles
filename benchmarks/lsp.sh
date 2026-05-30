#!/usr/bin/env bash
# LSP attach latency: wall-clock from opening a file to the language server
# client actually attaching to the buffer. This is when go-to-definition,
# diagnostics, hover, etc. become available.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

printf 'import os\nprint(os.getcwd())\n' > "$BENCH_TMP/attach.py"

# Opens the file, then waits (polling) until a client is attached, timing it.
bench_attach() {
  local label="$1" file="$2" server="$3"
  local vals=() i out
  for i in $(seq 1 "$RUNS"); do
    out="$("$NVIM" --headless "$file" \
      "+lua local t=vim.uv.hrtime(); local ok=vim.wait(8000, function() return #vim.lsp.get_clients({bufnr=0})>0 end, 25); io.write(ok and string.format('%.3f',(vim.uv.hrtime()-t)/1e6) or 'TIMEOUT')" \
      +qa 2>/dev/null)" || true
    vals+=("$out")
  done
  BENCH_RESULT="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "$label" "${BENCH_RESULT:-ERR}"
}

echo "== LSP attach (min of $RUNS runs) =="
if [ -x "$HOME/.local/bin/pyright-langserver" ]; then
  bench_attach "pyright attach (.py)" "$BENCH_TMP/attach.py" pyright
else
  echo "  pyright not installed — skipping"
fi
