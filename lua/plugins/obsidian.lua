return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      -- "hrsh7th/nvim-cmp",
      -- "nvim-telescope/telescope.nvim",

      -- see above for full list of optional dependencies ☝️
    },
    ---@module 'obsidian'
    ---@type obsidian.config.ClientOpts
    opts = {
      dir = vim.env.HOME .. "/files/notes", -- specify the vault location. no need to call 'vim.fn.expand' here
      use_advanced_uri = true,
      finder = "telescope.nvim",
      log_level = vim.log.levels.DEBUG,

      templates = {
        subdir = "obsidian-templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },
      daily_notes = {
        folder = "daily-notes",
        date_format = "%Y-%m-%d",
        -- Optional, if you want to change the date format of the default alias of daily notes.
        -- alias_format = "%B %-d, %Y",
        alias_format = nil,
        default_tags = nil,
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = nil,
      },
    },
  },
}
