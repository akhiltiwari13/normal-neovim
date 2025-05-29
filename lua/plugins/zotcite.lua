return {
  {
    "jalvesaq/zotcite",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    -- ft = { "markdown", "tex", "pandoc" }, -- Only load for document formats
    -- cmd = { "ZotCite", "ZotOpen", "ZotNote", "ZotBib", "ZotSearch" }, -- Load when any of these commands are used
    event = "VeryLazy",
    config = function()
      require("zotcite").setup({
        -- Path to your Zotero database (this is crucial)
        zotero_db_path = vim.fn.expand("~/Zotero/zotero.sqlite"),

        -- Citation format preferences
        citation_format = "pandoc", -- Options: "pandoc", "latex", "org"

        -- Default citation style
        csl_path = vim.fn.expand("~/Zotero/styles/apa.csl"), -- Adjust path as needed

        -- Integration with your file system
        attachment_dir = vim.fn.expand("~/Zotero/storage/"), -- Where Zotero stores PDFs

        -- Customize the citation picker
        picker = {
          -- Show preview of citation information
          preview = true,
          -- Maximum number of results to show
          max_results = 100,
          -- Search fields (title, author, year, etc.)
          search_fields = { "title", "author", "year", "journal" },
        },

        -- Bibliography management
        bibliography = {
          -- Automatically create/update bibliography sections
          auto_update = true,
          -- Where to place the bibliography in your documents
          placement = "end", -- Options: "end", "cursor", "after_heading"
        },

        -- Integration with your Zettelkasten workflow
        note_integration = {
          -- Create backlinks to source materials
          create_backlinks = true,
          -- Template for new literature notes
          literature_note_template =
          "# {title}\n\n**Authors:** {author}\n**Year:** {year}\n**DOI:** {doi}\n\n## Summary\n\n## Key Insights\n\n## Connections\n\n## Questions\n\n---\n**Source:** {citation}\n",
        },
      })

      -- Set up keymaps for zotcite functionality
      vim.keymap.set(
        "n",
        "<leader>zc",
        ":ZotCite<CR>",
        { desc = "Insert citation" }
      )
      vim.keymap.set(
        "n",
        "<leader>zo",
        ":ZotOpen<CR>",
        { desc = "Open attachment" }
      )
      vim.keymap.set(
        "n",
        "<leader>zn",
        ":ZotNote<CR>",
        { desc = "Create literature note" }
      )
      vim.keymap.set(
        "n",
        "<leader>zb",
        ":ZotBib<CR>",
        { desc = "Insert bibliography" }
      )
      vim.keymap.set(
        "n",
        "<leader>zs",
        ":ZotSearch<CR>",
        { desc = "Search Zotero library" }
      )
    end,
  },
}
