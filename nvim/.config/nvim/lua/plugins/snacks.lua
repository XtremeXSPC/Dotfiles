-- File: lua/plugins/snacks.lua (DA MODIFICARE)

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Abilita tutti i moduli utili, TRANNE il dashboard
    dashboard = { enabled = false },

    -- Tutti gli altri snack che vuoi usare
    bigfile = { enabled = true },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true, timeout = 3000 },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
  },
  -- Manteniamo tutte le scorciatoie di Snacks che hai definito
  keys = {
    {
      "<leader><space>",
      function() require("snacks").picker.smart() end,
      desc = "Smart Find Files",
    },
    { "<leader>e", function() require("snacks").explorer() end, desc = "File Explorer" },
    { "<leader>ff", function() require("snacks").picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() require("snacks").picker.grep() end, desc = "Grep" },
    { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Buffers" },
    { "<leader>z", function() require("snacks").zen() end, desc = "Toggle Zen Mode" },
    { "<leader>bd", function() require("snacks").bufdelete() end, desc = "Delete Buffer" },
    { "<leader>gg", function() require("snacks").lazygit() end, desc = "Lazygit" },
  },
  -- La funzione 'config' non è più necessaria qui
}
