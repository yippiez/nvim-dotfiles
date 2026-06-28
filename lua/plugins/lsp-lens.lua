-- LSP Lens
return {
  "VidocqH/lsp-lens.nvim",
  event = "LspAttach",
  config = function()
    require("lsp-lens").setup({
      sections = { definition = false, references = true, implements = true, git_authors = false },
      ignore_filetype = { "prisma" },
    })
  end,
}
