-- Compile Mode
return {
  "ej-shafran/compile-mode.nvim",
  version = "^5.0.0",
  cmd = { "Compile", "Recompile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    vim.g.compile_mode = {
      default_command = {
        rust = "cargo run",
        python = "uv run %",
        dart = "flutter analyze",
        ["*"] = "make -k ",
      },
      bang_expansion = true,
      use_diagnostics = false,
      focus_compilation_buffer = true,
    }
  end,
}
