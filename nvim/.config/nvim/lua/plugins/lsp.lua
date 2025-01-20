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
            "--fallback-style=none" 
          },
          on_attach = function(client, bufnr)
            -- Add a command for formatting
            local function lsp_format()
              vim.lsp.buf.format({
                async = true,
                filter = function(client)
                  return client.name == "clangd"
                end,
              })
            end
            vim.keymap.set("n", "<Leader>cf", lsp_format, { buffer = bufnr, desc = "Format code" })
          end,
        },
      },
    },
  }