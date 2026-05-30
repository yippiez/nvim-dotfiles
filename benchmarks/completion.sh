#!/usr/bin/env bash
# Completion engine cost: loading + setting up nvim-cmp, and triggering a
# completion menu. With cmp preloaded at VeryLazy this should be near-instant on
# first insert; the trigger cost is what you feel as you type.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

printf 'local mymodule = {}\nfunction mymodule.foo() end\nmy\n' > "$BENCH_TMP/c.lua"

echo "== Completion (min of $RUNS runs) =="
bench_lua "cmp cold load + setup" \
  "require('cmp')"
# NOTE: the popup itself only renders under a real UI, so we measure the cost of
# dispatching a completion request (the synchronous part you feel as you type),
# not the time to a visible menu — that can't be observed headless.
bench_file_op "cmp.complete() dispatch" "$BENCH_TMP/c.lua" \
  "local cmp=require('cmp'); vim.cmd('normal! G\$'); vim.cmd('startinsert!'); cmp.complete()"
