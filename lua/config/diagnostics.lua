vim.diagnostic.config({
  virtual_text = {
    source = "always",
    prefix = "●",
    format = function(d)
      local msg = d.message:gsub("\n", " ")
      return #msg > 50 and msg:sub(1, 47) .. "..." or msg
    end,
  },
  float = { source = "always", wrap = true, border = "rounded" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
