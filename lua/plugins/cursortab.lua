-- cursortab.nvim: Cursor-style "Tab" completions, served by a LOCAL llama.cpp
-- llama-server on :8000 -- no cloud, no API key. Run `sweep-server` to back it.
-- <Tab> accepts (the cmp block above falls through to a literal <Tab> when its
-- menu is closed), <S-Tab> partial-accepts. :CursortabStatus / :CursortabRestart.
-- The Qwen/FIM backend is parked until the fim_tokens validator fix lands on
-- the fork's main (yippiez/cursortab.nvim#3); then re-add the "fim" provider.
return {
  -- Your fork (not upstream). Edit/commit/PR via the cursortab/ submodule;
  -- `:Lazy update` pulls the fork's main into lazy's own clone.
  "yippiez/cursortab.nvim",
  lazy = false,
  -- The daemon needs Go 1.25+; system Go is 1.22, so build with the user-local
  -- 1.26 toolchain in ~/.local/go. We inject it onto PATH only for this build
  -- shell rather than touching nvim's environment. Bump if that Go dir changes.
  build = "cd server && PATH=" .. os.getenv("HOME") .. "/.local/go/bin:$PATH go build",
  config = function()
    require("cursortab").setup({
      provider = { type = "sweep", url = "http://localhost:8000" },
    })
  end,
}
