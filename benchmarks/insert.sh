#!/usr/bin/env bash
# Insert-mode entry latency. The first time you press `i`, the InsertEnter event
# lazy-loads nvim-cmp (completion). This is felt as a hitch before the cursor is
# usable, so it's worth measuring directly.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

printf 'local x = 1\nprint(x)\n' > "$BENCH_TMP/buf.lua"

echo "== Insert-mode entry (min of $RUNS runs) =="
bench_event "first InsertEnter (cmp)" "InsertEnter" "$BENCH_TMP/buf.lua"
