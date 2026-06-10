return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  keys = {
    { "<leader>e", "<Cmd>Neotree toggle<CR>", desc = "Toggle Neo-tree" },
  },
  opts = {
    sources = { "filesystem", "git_status", "buffers" },
    source_selector = {
      winbar = true,
      sources = {
        { source = "filesystem", display_name = " 󰉓 Files " },
        { source = "git_status", display_name = " 󰊢 Git " },
        { source = "buffers", display_name = " 󰈚 Buffers " },
      },
    },
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    window = {
      mappings = {
        ["Y"] = function(state)
          local path = state.tree:get_node():get_id()
          vim.fn.setreg("+", path)
          vim.notify("Copied: " .. path)
        end,
        ["gy"] = function(state)
          local path = vim.fn.fnamemodify(state.tree:get_node():get_id(), ":.")
          vim.fn.setreg("+", path)
          vim.notify("Copied: " .. path)
        end,
      },
    },
  },
}
