#!/usr/bin/env bash
# Run every benchmark + the regression guard. Exit code reflects the guard.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Neovim config benchmarks  (NVIM=${NVIM:-nvim}, RUNS=${RUNS:-8})"
echo "nvim: $("${NVIM:-nvim}" --version | head -1)"
echo

bash "$DIR/startup.sh";   echo
bash "$DIR/fileopen.sh";  echo
bash "$DIR/filetypes.sh"; echo
bash "$DIR/bigfiles.sh";  echo
bash "$DIR/lazyload.sh";  echo
bash "$DIR/insert.sh";    echo
bash "$DIR/editops.sh";   echo
bash "$DIR/clipboard.sh"; echo
bash "$DIR/bufswitch.sh"; echo
bash "$DIR/lsp.sh";       echo
bash "$DIR/largefile.sh"; echo
bash "$DIR/redraw.sh";    echo
bash "$DIR/pickers.sh";   echo
bash "$DIR/telescope.sh"; echo
bash "$DIR/guard.sh"
