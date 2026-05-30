#!/usr/bin/env bash
# Diagnostic rendering cost: publishing many diagnostics to a buffer (virtual
# text + signs + underline, as configured) and jumping between them. A file with
# lots of errors shouldn't make the editor crawl.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

yes 'local x = undefined_symbol + 1' | head -500 > "$BENCH_TMP/diag.lua"

echo "== Diagnostics (min of $RUNS runs) =="
bench_file_op "publish 200 diagnostics" "$BENCH_TMP/diag.lua" \
  "local ns=vim.api.nvim_create_namespace('bench'); local d={}; for i=1,200 do d[i]={lnum=i-1,col=0,end_col=5,message='error number '..i,severity=vim.diagnostic.severity.ERROR} end; vim.diagnostic.set(ns,0,d)"
bench_file_op "jump 100x next diagnostic" "$BENCH_TMP/diag.lua" \
  "local ns=vim.api.nvim_create_namespace('bench'); local d={}; for i=1,200 do d[i]={lnum=i-1,col=0,message='e'..i,severity=1} end; vim.diagnostic.set(ns,0,d); for _=1,100 do pcall(vim.diagnostic.goto_next, {float=false}) end"
