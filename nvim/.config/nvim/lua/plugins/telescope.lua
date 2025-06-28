return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
      },
    },
    -- Qui e' possibile aggiungere anche i keymap
    keys = {
      -- Esempio: keymap per cercare nei file di configurazione di LazyVim
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files { cwd = require("lazy.core.config").options.root }
        end,
        desc = "Find Plugin File",
      },
    },
  },
}
