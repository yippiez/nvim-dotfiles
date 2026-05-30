#!/usr/bin/env bash
# Cold startup time with no file argument.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

echo "== Startup (min of $RUNS runs) =="
bench_startup "nvim (no file)"

# How many plugins actually load at startup — the lower the better. Everything
# except the colorscheme and lazy.nvim itself should be deferred.
loaded="$("$NVIM" --headless \
  "+lua local s=require('lazy').stats(); io.write(s.loaded..'/'..s.count)" +qa 2>/dev/null)"
echo "  plugins loaded at startup           ${loaded:-?}"
