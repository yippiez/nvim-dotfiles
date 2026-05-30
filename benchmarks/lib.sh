#!/usr/bin/env bash
# Shared helpers for the nvim config benchmarks.
#
# Every benchmark measures the *active* Neovim config (whatever `nvim` resolves
# to, i.e. ~/.config/nvim). Override the binary with NVIM=/path/to/nvim and the
# sample count with RUNS=N.
#
# We report the MINIMUM across N runs on purpose: startup time is dominated by
# OS/filesystem noise (especially on WSL's 9p mount), and the min is the closest
# estimate of the true cost with noise stripped out.

set -uo pipefail

NVIM="${NVIM:-nvim}"
RUNS="${RUNS:-8}"

if ! command -v "$NVIM" >/dev/null 2>&1; then
  echo "error: nvim binary '$NVIM' not found (set NVIM=...)" >&2
  exit 127
fi

BENCH_TMP="$(mktemp -d)"
trap 'rm -rf "$BENCH_TMP"' EXIT

# Total startup time (ms) = the largest cumulative timestamp in a --startuptime
# log (the "--- NVIM STARTED ---" line).
_log_total() {
  grep -E '^[0-9]' "$1" | sort -n | tail -1 | awk '{print $1}'
}

# _min <values...> -> smallest numeric value (handles leading zeros / decimals)
_min() {
  printf '%s\n' "$@" | grep -E '^[0-9]' | sort -n | head -1
}

# bench_startup "<label>" [file args...]
# Launches `nvim --headless` RUNS times (optionally opening files) and prints the
# minimum total startup time. Sets BENCH_RESULT to the numeric min (or empty).
bench_startup() {
  local label="$1"; shift
  local vals=() i log
  for i in $(seq 1 "$RUNS"); do
    log="$BENCH_TMP/start.log"
    "$NVIM" --headless --startuptime "$log" "$@" +q >/dev/null 2>&1 || true
    vals+=("$(_log_total "$log")")
  done
  BENCH_RESULT="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "$label" "${BENCH_RESULT:-ERR}"
}

# bench_lua "<label>" "<lua statement>"
# Times a lua statement with vim.uv.hrtime() inside a fresh nvim, RUNS times.
# Useful for measuring the cost of lazy-loading a module (e.g. telescope).
# Sets BENCH_RESULT to the numeric min (or empty).
bench_lua() {
  local label="$1" lua="$2"
  local vals=() i out
  for i in $(seq 1 "$RUNS"); do
    out="$("$NVIM" --headless \
      "+lua local t=vim.uv.hrtime(); $lua; io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
      +qa 2>/dev/null)" || true
    vals+=("$out")
  done
  BENCH_RESULT="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "$label" "${BENCH_RESULT:-ERR}"
}

# eval_g "<varname>" -> prints the value of vim.g.<varname> as a string
eval_g() {
  "$NVIM" --headless "+lua io.write(tostring(vim.g.$1))" +qa 2>/dev/null
}

# bench_event "<label>" "<EventName>" [file]
# Opens an optional file, then fires an autocmd event and times how long it takes
# to settle — i.e. the cost of whatever lazy-loads on that event (e.g. cmp +
# copilot on InsertEnter). Sets BENCH_RESULT.
bench_event() {
  local label="$1" event="$2" file="${3:-}"
  local vals=() i out args=()
  [ -n "$file" ] && args+=("$file")
  for i in $(seq 1 "$RUNS"); do
    out="$("$NVIM" --headless "${args[@]}" \
      "+lua local t=vim.uv.hrtime(); vim.api.nvim_exec_autocmds('$event', {}); io.write(string.format('%.3f',(vim.uv.hrtime()-t)/1e6))" \
      +qa 2>/dev/null)" || true
    vals+=("$out")
  done
  BENCH_RESULT="$(_min "${vals[@]}")"
  printf '  %-42s %8s ms\n' "$label" "${BENCH_RESULT:-ERR}"
}
