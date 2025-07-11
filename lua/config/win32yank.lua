vim.opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "win32yank-wsl",
  copy = {
    ["+"] = "/mnt/c/dev/custom_commands/win32yank.exe -i --crlf",
    ["*"] = "/mnt/c/dev/custom_commands/win32yank.exe -i --crlf",
  },
  paste = {
    ["+"] = "/mnt/c/dev/custom_commands/win32yank.exe -o --lf",
    ["*"] = "/mnt/c/dev/custom_commands/win32yank.exe -o --lf",
  },
  cache_enabled = false,
}
