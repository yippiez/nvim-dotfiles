#!/usr/bin/env bash
# Insert-mode entry latency. cmp is preloaded at VeryLazy, so the first `i` should
# NOT pay a cmp-load hitch — this benchmark verifies that stays true (a regression
# that moved cmp back onto InsertEnter would show up here as ~25ms).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

printf 'local x = 1\nprint(x)\n' > "$BENCH_TMP/buf.lua"

echo "== Insert-mode entry (min of $RUNS runs) =="
bench_event "first InsertEnter (cmp)" "InsertEnter" "$BENCH_TMP/buf.lua"
