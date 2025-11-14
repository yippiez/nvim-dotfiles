-- https://github.com/VidocqH/lsp-lens.nvim
return {
  'VidocqH/lsp-lens.nvim',
  event = 'LspAttach',
  config = function()
    require('lsp-lens').setup({
      enable = true,
      include_declaration = false,
      sections = {
        definition = false,
        references = true,
        implements = true,
        git_authors = false,
      },
      ignore_filetype = {
        "prisma",
      },
    })
  end
}