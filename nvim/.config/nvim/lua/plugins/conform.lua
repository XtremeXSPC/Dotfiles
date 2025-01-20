return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      clang_format_custom = {
        command = "clang-format",
        args = function(ctx)
          local config_path = vim.loop.os_getenv("CLANG_FORMAT_CONFIG") or "/Users/lcs-dev/.config/clang-format/.clang-format"
          return {
            "-style=file:" .. config_path,
            "--assume-filename", ctx.filename or vim.api.nvim_buf_get_name(ctx.bufnr) or "untitled.c",
          }
        end,
        stdin = true,
      },
    },
  },
}