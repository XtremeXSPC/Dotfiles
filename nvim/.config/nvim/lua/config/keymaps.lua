-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>sx", function()
    local status, builtin = pcall(require, "telescope.builtin")
    if status then
        builtin.resume()
    else
        vim.notify("Telescope is not available", vim.log.levels.ERROR)
    end
end, { noremap = true, silent = true, desc = "Resume" })
