return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- Our plugin version
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image"
      vim.g.molten_output_win_max_height = 20
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Molten initialize" },
      { "<leader>me", "<cmd>MoltenEvaluateOperator<cr>", mode = "n", desc = "Molten evaluate operator" },
      { "<leader>me", "<cmd>MoltenEvaluateVisual<cr>", mode = "v", desc = "Molten evaluate visual" },
      { "<leader>mr", "<cmd>MoltenRestart<cr>", desc = "Molten restart" },
      { "<leader>mR", "<cmd>MoltenReconnect<cr>", desc = "Molten reconnect" },
      { "<leader>md", "<cmd>MoltenDelete<cr>", desc = "Molten delete" },
      { "<leader>mo", "<cmd>MoltenOutput<cr>", desc = "Molten output" },
    },
  },
  {
    "3rd/image.nvim",
  },
}
