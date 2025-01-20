return {
    "folke/tokyonight.nvim",
    lazy = false, -- Impedisce il caricamento pigro, il tema viene caricato immediatamente
    priority = 1000, -- Assegna alta priorità per garantire che venga caricato per primo
    opts = {
        style = "night", -- Scegli lo stile preferito (storm, night, moon, day)
        transparent = false, 
        terminal_colors = true,
    },
    config = function(_, opts)
        require("tokyonight").setup(opts) -- Applica le opzioni
        vim.cmd([[colorscheme tokyonight]]) -- Imposta il tema
    end,
}
