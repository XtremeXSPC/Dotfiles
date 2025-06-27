return {
    "LazyVim/LazyVim",
    opts = {
        format = {
            enabled = false, -- Disabilita la formattazione globale
            formatters_by_ft = {
                c = { "clang_format_custom" },
                cpp = { "clang_format_custom" },
            },
        },
    },
}
