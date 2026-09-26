return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "bashls", "pylsp", "pyright", "ansiblels"},
      })
    end
  },
  {
"neovim/nvim-lspconfig",
    config = function()
    local lspconfig = vim.lsp.config()
      lspconfig.lua_ls.setup({})
      lspconfig.bashls.setup({})
      --lspconfig.pylsp.setup({})
      lspconfig.pyright.setup({})
      lspconfig.ansiblels.setup({})
      
      vim.keymap.set('n', 'K', vim.lsp.buf.hover,{})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
    end
  }
}
