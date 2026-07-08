-- LSP Lens
return {
  "VidocqH/lsp-lens.nvim",
  event = "LspAttach",
  config = function()
    require("lsp-lens").setup({
      -- implements is off too: it added a second project-wide search
      -- (textDocument/implementation) per function per refresh, doubling the
      -- server load for a count that's rarely useful. Re-enable if missed.
      sections = { definition = false, references = true, implements = false, git_authors = false },
      ignore_filetype = { "prisma" },
    })

    -- The plugin refreshes on BufEnter and EVERY TextChanged (any normal-mode
    -- edit), and each refresh sends a references request for every function in
    -- the file — a project-wide search storm that pegs the language server on
    -- large codebases and queues gd/completion behind it.
    -- Replace its autocmds: refresh only when a file is first opened
    -- (LspAttach) or saved, debounced so navigation bursts through files only
    -- refresh the one you land on. Counts go stale between saves — acceptable.
    local lens = require("lsp-lens.lens-util")
    vim.api.nvim_create_augroup("lsp_lens", { clear = true }) -- drop plugin's autocmds
    local timer = assert(vim.uv.new_timer())
    vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost" }, {
      group = vim.api.nvim_create_augroup("lsp_lens_debounced", { clear = true }),
      callback = function()
        timer:stop()
        timer:start(1000, 0, vim.schedule_wrap(function()
          if not require("util").is_large_file(0) then
            lens:procedure()
          end
        end))
      end,
    })
  end,
}
