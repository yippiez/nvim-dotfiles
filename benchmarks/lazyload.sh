#!/usr/bin/env bash
# Cold lazy-load cost of each deferred plugin: how long the first require() takes
# (which is what you pay the first time its trigger fires). Lower = snappier first
# use. vim.loader's byte-cache makes these much cheaper once warm.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

echo "== Per-plugin cold require (min of $RUNS runs) =="
bench_lua "gitsigns"               "require('gitsigns')"
bench_lua "nvim-cmp"               "require('cmp')"
bench_lua "nvim-treesitter"        "require('nvim-treesitter.configs')"
bench_lua "flash"                  "require('flash')"
bench_lua "which-key"              "require('which-key')"
bench_lua "oil"                    "require('oil')"
bench_lua "Comment"                "require('Comment')"
bench_lua "treesj"                 "require('treesj')"
bench_lua "lualine"                "require('lualine')"
bench_lua "lsp-lens"               "require('lsp-lens')"
bench_lua "todo-comments"          "require('todo-comments')"
