local map = vim.keymap.set

-- Telescope
local tb = require("telescope.builtin")
map("n", "<leader>ff", tb.find_files, { desc = "Find files" })
map("n", "<leader>fg", tb.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", tb.buffers, { desc = "Buffers" })
map("n", "<leader>fh", tb.help_tags, { desc = "Help tags" })

-- Quality of life
map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
