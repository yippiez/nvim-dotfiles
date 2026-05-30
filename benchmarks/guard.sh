#!/usr/bin/env bash
# Regression guard. Fails (exit 1) if the known WSL PATH-scan traps creep back
# in, or if startup / file-open blow past sane thresholds. Safe to wire into CI.
#
# Background: on WSL, $PATH includes the Windows dirs over the 9p filesystem, so
# any PATH probe is catastrophically slow:
#   vim.fn.executable("win32yank.exe")  ~500ms
#   vim.fn.exepath("<missing>")         ~116ms each
#   vim.fn.has("python3")               ~685ms
# These once made startup ~480ms and `.py` open ~1.2s. The fixes: disable unused
# providers, configure clipboard without probing, give LSP servers absolute cmds.
#
# Thresholds are overridable: STARTUP_MAX_MS, OPEN_MAX_MS.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

STARTUP_MAX_MS="${STARTUP_MAX_MS:-60}"
OPEN_MAX_MS="${OPEN_MAX_MS:-120}"
fail=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=1; }

# under_threshold <value> <max> -> 0 if value <= max
under() { awk "BEGIN{exit !($1 <= $2)}"; }

echo "== Regression guards =="

# 1. Unused remote-plugin providers must be disabled (else has() probes PATH).
for p in python3 ruby perl node; do
  v="$(eval_g "loaded_${p}_provider")"
  if [ "$v" = "0" ]; then
    pass "vim.g.loaded_${p}_provider disabled"
  else
    bad "vim.g.loaded_${p}_provider = $v (should be 0)"
  fi
done

# 2. The config source itself must not call the slow PATH-probing builtins.
#    Blank out Lua comments (everything from `--`) first so mentions in NOTE
#    comments don't trip the check — only real calls count. `sed` is 1 line in /
#    1 line out, so `grep -n` line numbers still match the original file.
src="$DIR/../init.lua"
hits="$(sed 's/--.*//' "$src" | grep -nE 'fn\.executable\(|fn\.exepath\(|fn\.has\(["'"'"']python3')"
if [ -n "$hits" ]; then
  bad "init.lua calls executable()/exepath()/has('python3') — these scan PATH on WSL"
  printf '%s\n' "$hits" | sed 's/^/        /'
else
  pass "init.lua has no executable()/exepath()/has('python3') calls"
fi

# 3. Startup under threshold.
bench_startup "startup" >/dev/null
if [ -n "${BENCH_RESULT:-}" ] && under "$BENCH_RESULT" "$STARTUP_MAX_MS"; then
  pass "startup ${BENCH_RESULT}ms <= ${STARTUP_MAX_MS}ms"
else
  bad "startup ${BENCH_RESULT:-ERR}ms > ${STARTUP_MAX_MS}ms"
fi

# 4. Opening a python file under threshold (the old 1.2s worst case).
printf 'import os\nprint(os.getcwd())\n' > "$BENCH_TMP/g.py"
bench_startup "open .py" "$BENCH_TMP/g.py" >/dev/null
if [ -n "${BENCH_RESULT:-}" ] && under "$BENCH_RESULT" "$OPEN_MAX_MS"; then
  pass "open .py ${BENCH_RESULT}ms <= ${OPEN_MAX_MS}ms"
else
  bad "open .py ${BENCH_RESULT:-ERR}ms > ${OPEN_MAX_MS}ms"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "All guards passed."
else
  echo "Regression detected." >&2
fi
exit "$fail"
