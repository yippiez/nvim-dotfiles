#!/usr/bin/env bash
# Time to open files of different types. This exercises the BufReadPre/Post
# lazy-load chain (gitsigns, lspconfig, treesitter, guess-indent, todo-comments)
# and, for matching filetypes, LSP server attach.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

printf 'hello world\nsecond line\n'        > "$BENCH_TMP/sample.txt"
printf 'local x = 1\nprint(x)\n'           > "$BENCH_TMP/sample.lua"
printf 'import os\nprint(os.getcwd())\n'   > "$BENCH_TMP/sample.py"
printf 'fn main() { println!("hi"); }\n'   > "$BENCH_TMP/sample.rs"

echo "== File open (min of $RUNS runs) =="
bench_startup "open .txt  (no LSP, no parser)" "$BENCH_TMP/sample.txt"
bench_startup "open .lua  (treesitter)"        "$BENCH_TMP/sample.lua"
bench_startup "open .py   (pyright + ts)"      "$BENCH_TMP/sample.py"
bench_startup "open .rs   (rust-analyzer + ts)" "$BENCH_TMP/sample.rs"
