return {
  "nwiizo/marp.nvim",
  ft = { "markdown" },
  config = function()
    require("marp").setup({
      -- marp-cli is installed via nix (home.nix)
      marp_command = "marp",
      debug = false,
      server_mode = false,
    })
  end,
}
