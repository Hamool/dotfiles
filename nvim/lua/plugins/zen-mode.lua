return {
  "folke/zen-mode.nvim",
  opts = {
    plugins = {
      options = {
        enabled = true,
      },
      kitty = {
        enabled = true,
        font = "+10", -- font size increment

      },
    },
  },
  config = function() 
    vim.keymap.set('n', '<leader>z', ':ZenMode<CR>', {})
  end
}
