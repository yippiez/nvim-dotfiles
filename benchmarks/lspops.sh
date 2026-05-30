#!/usr/bin/env bash
# LSP request round-trips on a python buffer with pyright attached: hover,
# definition, document symbols. These are the <leader>l* / gd actions. Measures
# wall-clock for a synchronous request once the server is ready.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

if [ ! -x "$HOME/.local/bin/pyright-langserver" ]; then
  echo "== LSP ops =="; echo "  pyright not installed — skipping"; exit 0
fi

cat > "$BENCH_TMP/l.py" <<'EOF'
import os

def greet(name):
    return "hello " + name

result = greet(os.getcwd())
print(result)
EOF

# Open, wait for attach, then time a synchronous request via buf_request_sync.
bench_req() {
  local label="$1" method="$2"
  local vals=() i out
  for i in $(seq 1 "$RUNS"); do
    out="$("$NVIM" --headless "$BENCH_TMP/l.py" \
      "+lua vim.wait(8000, function() return #vim.lsp.get_clients({bufnr=0})>0 end, 25); vim.wait(1500); vim.api.nvim_win_set_cursor(0,{4,12}); local p=vim.lsp.util.make_position_params(0,'utf-16'); local t=vim.uv.hrtime(); vim.lsp.buf_request_sync(0,'$method',p,5000); io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
      "+qa!" 2>/dev/null)" || true
    vals+=("$out")
  done
  BENCH_RESULT="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "$label" "${BENCH_RESULT:-ERR}"
}

echo "== LSP request round-trip (min of $RUNS runs) =="
bench_req "hover (textDocument/hover)"        "textDocument/hover"
bench_req "definition (textDocument/definition)" "textDocument/definition"
bench_req "document symbols"                  "textDocument/documentSymbol"
