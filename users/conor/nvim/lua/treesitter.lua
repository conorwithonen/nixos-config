-- Parsers are installed by Nix; just start highlighting when one exists
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})
