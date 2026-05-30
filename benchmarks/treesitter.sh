#!/usr/bin/env bash
# Treesitter parse cost as a file grows. This is what backs syntax highlighting;
# it runs incrementally on edits, but a full parse happens on open. Confirms the
# 100KB large-file guard (which disables the parser) keeps huge files cheap.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

gen() { yes 'local function foo(a, b) return a + b end' | head -"$1"; }
gen 200   > "$BENCH_TMP/p200.lua"
gen 2000  > "$BENCH_TMP/p2000.lua"
gen 20000 > "$BENCH_TMP/p20000.lua"

echo "== Treesitter full parse (min of $RUNS runs) =="
bench_file_op "parse 200 lines"   "$BENCH_TMP/p200.lua" \
  "local p=vim.treesitter.get_parser(0,'lua'); p:parse(true)"
bench_file_op "parse 2000 lines"  "$BENCH_TMP/p2000.lua" \
  "local p=vim.treesitter.get_parser(0,'lua'); p:parse(true)"
bench_file_op "parse 20000 lines" "$BENCH_TMP/p20000.lua" \
  "local ok,p=pcall(vim.treesitter.get_parser,0,'lua'); if ok and p then p:parse(true) end"
