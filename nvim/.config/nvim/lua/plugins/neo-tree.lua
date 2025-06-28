-- File: lua/plugins/neo-tree.lua (Versione Corretta e Verificata)

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    close_if_last_window = true, -- Chiude neo-tree se è l'ultima finestra
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,

    -- Opzioni di default per tutti i comandi
    default_component_configs = {
      -- Configurazione per il componente git_status
      git_status = {
        symbols = {
          -- usati da 'git status'
          added = "", -- "", "", ""
          deleted = "", -- "", "", ""
          modified = "", -- "", ""
          renamed = "", -- ""
          -- usati da 'git diff'
          unmerged = "",
          untracked = "",
          ignored = "◌",
          staged = "✓",
          unstaged = "✗",
          conflict = "",
        },
      },
    },

    -- Definisce le finestre e come sono composte
    window = {
      -- Le mappature dei tasti all'interno di neo-tree
      mappings = {
        ["<space>"] = "none",
        ["A"] = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_pull",
      },
    },

    -- Configurazione specifica per il filesystem
    filesystem = {
      -- Ordine in cui vengono renderizzati i componenti per ogni riga
      renderers = {
        name = {
          { "git_status", "icon", "name" },
        },
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          ".git",
          ".DS_Store",
          "thumbs.db",
        },
      },
    },
  },
}
