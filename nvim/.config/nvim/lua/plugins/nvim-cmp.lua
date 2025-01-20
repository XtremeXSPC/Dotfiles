return {
    {
        "nvim-cmp",
        opts = function(_, opts)
            opts.completion = {
                autocomplete = false,
            }
        end,
    },
}
