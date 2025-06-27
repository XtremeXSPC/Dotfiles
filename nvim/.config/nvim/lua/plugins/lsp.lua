local on_attach = function(client, bufnr)
    -- Format Settings
    local function lsp_format()
        vim.lsp.buf.format({
            async = true,
            filter = function(c)
                return c.name == "clangd"
            end,
        })
    end
    vim.keymap.set("n", "<Leader>cf", lsp_format, { buffer = bufnr, desc = "Format (LSP)" })

    -- Enable completion via <c-x><c-o>
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Common mapping
    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, noremap = true, silent = true, desc = desc })
    end

    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
    nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
end

return {
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
            clangd = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                    "--fallback-style=none",
                },
                on_attach = on_attach,
            },
        },
    },
}
