local map = vim.keymap.set

-- Basic
map("n", "<Esc>", ":noh<CR>", { silent = true })
map({ "n", "i" }, "<C-s>", "<cmd>w<CR>")
map("n", "<leader>cr", "<cmd>belowright Compile<CR>", { desc = "Run compile mode" })
map("n", "<leader>cq", function()
  require("compile-mode").close_buffer()
end, { desc = "Close compile window" })
map("n", "<leader>i", function()
  require("config.open-image").open_under_cursor()
end, { desc = "Open image under cursor" })
map("n", "<leader>bq", ":bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })

-- Git change navigation
map("n", "]c", function()
  require("gitsigns").next_hunk()
end, { desc = "Next git hunk" })
map("n", "[c", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous git hunk" })

-- LSP
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>le", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>la", vim.lsp.buf.hover, { desc = "Hover" })
map({ "n", "v" }, "<leader>lf", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map({ "n", "v" }, "<leader>ls", function()
  vim.lsp.buf.code_action({
    filter = function(action)
      local kind = action.kind or ""
      return kind:find("^refactor") ~= nil
    end,
  })
end, { desc = "Refactor (split/join)" })
map("n", "<leader>lc", function()
  local d = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if #d > 0 then
    vim.fn.setreg("+", d[1].message)
    print("Copied: " .. d[1].message)
  end
end, { desc = "Copy diagnostic" })

-- Move lines
map("n", "<M-Up>", ":m .-2<CR>==", { silent = true })
map("n", "<M-Down>", ":m .+1<CR>==", { silent = true })
map("i", "<M-Up>", "<Esc>:m .-2<CR>==gi", { silent = true })
map("i", "<M-Down>", "<Esc>:m .+1<CR>==gi", { silent = true })
map("v", "<M-Up>", ":m '<-2<CR>gv=gv", { silent = true })
map("v", "<M-Down>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<M-Left>", "<gv", { silent = true })
map("v", "<M-Right>", ">gv", { silent = true })

-- Command aliases
vim.cmd("command! Wq wq")
vim.cmd("command! W w")
vim.cmd("command! Q q!")
vim.cmd("cnoreabbrev Q! q!")
vim.cmd("command! -nargs=1 Rg terminal rg <args>")
vim.cmd("cnoreabbrev rg Rg")

-- Quickeys: insert comment line with language-appropriate syntax
map("n", "<leader>qc", function()
  local cs = vim.bo.commentstring
  if not cs or cs == "" then
    local ft_leaders = {
      python = "#", sh = "#", bash = "#", zsh = "#",
      lua = "--", sql = "--", haskell = "--",
      javascript = "//", typescript = "//", javascriptreact = "//",
      typescriptreact = "//", c = "//", cpp = "//", rust = "//",
      go = "//", java = "//", dart = "//", kotlin = "//", swift = "//",
      yaml = "#", ruby = "#", elixir = "#", toml = "#", conf = "#",
      make = "#", vim = '"', fennel = ";", clojure = ";", lisp = ";",
      tex = "%", matlab = "%", erlang = "%",
      css = "/*", html = "<!--", xml = "<!--",
    }
    cs = (ft_leaders[vim.bo.filetype] or "#") .. " %s"
  end

  local c_leader = cs:match("^(.-)%%s")
  c_leader = c_leader and vim.trim(c_leader) or "#"

  local indent = vim.fn.getline("."):match("^(%s*)") or ""
  local comment_line = indent .. c_leader .. " ... "

  local lnum = vim.fn.line(".")
  vim.fn.append(lnum - 1, comment_line)
  vim.fn.cursor(lnum, #comment_line + 1)
end, { desc = "Comment before cursor" })

map("n", "<leader>qt", function()
  local cs = vim.bo.commentstring
  if not cs or cs == "" then
    local ft_leaders = {
      python = "#", sh = "#", bash = "#", zsh = "#",
      lua = "--", sql = "--", haskell = "--",
      javascript = "//", typescript = "//", javascriptreact = "//",
      typescriptreact = "//", c = "//", cpp = "//", rust = "//",
      go = "//", java = "//", dart = "//", kotlin = "//", swift = "//",
      yaml = "#", ruby = "#", elixir = "#", toml = "#", conf = "#",
      make = "#", vim = '"', fennel = ";", clojure = ";", lisp = ";",
      tex = "%", matlab = "%", erlang = "%",
      css = "/*", html = "<!--", xml = "<!--",
    }
    cs = (ft_leaders[vim.bo.filetype] or "#") .. " %s"
  end

  local c_leader = cs:match("^(.-)%%s")
  c_leader = c_leader and vim.trim(c_leader) or "#"

  local indent = vim.fn.getline("."):match("^(%s*)") or ""
  local comment_line = indent .. c_leader .. " TODO: "

  local lnum = vim.fn.line(".")
  vim.fn.append(lnum - 1, comment_line)
  vim.fn.cursor(lnum, #comment_line + 1)
  vim.cmd("startinsert!")
end, { desc = "Todo comment before cursor" })

map("n", "<leader>qo", function()
  local indent = vim.fn.getline("."):match("^(%s*)") or ""
  local lnum = vim.fn.line(".")
  vim.fn.append(lnum - 1, indent)
end, { desc = "New line before cursor" })
