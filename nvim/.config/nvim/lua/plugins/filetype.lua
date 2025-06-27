return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- Assicura che il parser C++ sia installato
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "cpp" })
            end

            -- Aggiungi l'associazione del filetype
            vim.filetype.add({
                extension = {
                    tpp = "cpp",
                },
            })
        end,
    },
}
