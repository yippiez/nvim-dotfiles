#!/usr/bin/env bash
# Open a spread of real file types. Each exercises filetype detection, the
# treesitter parser for that language, and (where a server is configured) LSP
# attach. Surfaces any language whose parser isn't pre-installed (auto_install
# would otherwise compile it on first open, ~475ms).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

d="$BENCH_TMP"
printf '{"a":1,"b":[1,2,3],"c":{"d":true}}\n'                 > "$d/s.json"
printf 'const x: number = 1;\nexport function f() { return x; }\n' > "$d/s.ts"
printf 'package main\nimport "fmt"\nfunc main(){ fmt.Println(1) }\n' > "$d/s.go"
printf 'fn main() { let x = 1; println!("{}", x); }\n'        > "$d/s.rs"
printf '#include <stdio.h>\nint main(){ printf("hi"); return 0; }\n' > "$d/s.c"
printf '<!doctype html><html><body><h1>hi</h1></body></html>\n' > "$d/s.html"
printf 'body { color: red; margin: 0; }\n.foo { display: flex; }\n' > "$d/s.css"
printf 'name: ci\non: [push]\njobs:\n  a:\n    runs-on: x\n'  > "$d/s.yaml"
printf '#!/usr/bin/env bash\nset -e\necho hi\n'               > "$d/s.sh"
printf '# Title\n\n- a\n- b\n\n```lua\nx=1\n```\n'            > "$d/s.md"
printf 'x = 1\nprint(x)\n'                                    > "$d/s.lua"

echo "== Open by filetype (min of $RUNS runs) =="
# Settle LSP servers between filetypes so a heavy indexer (rust-analyzer) doesn't
# inflate the next filetype's measurement. This benchmark is about parser/open
# cost per filetype; LSP attach latency is measured separately in lsp.sh.
for f in json ts go rs c html css yaml sh md lua; do
  bench_startup "open .$f" "$d/s.$f"
  _settle_lsp
done
