return {
  "catppuccin/nvim",
  lazy = true,
  name = "catppuccin",
  config = function()
    require('catppuccin').setup({
      flavour = 'mocha',
      custom_highlights = function(colors)
        return {
          CursorLineNr = { fg = colors.peach},
        }
      end
    })
  end
}
