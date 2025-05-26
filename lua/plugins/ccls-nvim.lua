return {
  {
    "ranjithshegde/ccls.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter", -- For better syntax highlighting in the NodeTree
    },
    -- Only load for C/C++ files
    ft = { "c", "cpp", "objc", "objcpp" },
    config = function()
      -- Get the proper cache directory path
      local cache_dir = vim.fn.expand("~/.cache/ccls/")
      -- Use fs.normalize if you're on nvim 0.8 or higher
      -- local cache_dir = vim.fs.normalize("~/.cache/ccls/")

      -- Set up ccls with all features enabled
      require("ccls").setup({
        -- Window configuration for the tree views
        win_config = {
          -- Sidebar configuration
          sidebar = {
            size = 50,
            position = "topleft",
            split = "vnew",
            width = 50,
            height = 20,
          },
          -- Floating window configuration
          float = {
            style = "minimal",
            relative = "cursor",
            width = 50,
            height = 20,
            row = 0,
            col = 0,
            border = "rounded",
          },
        },
        -- Set the filetypes for which ccls will be active
        filetypes = { "c", "cpp", "objc", "objcpp" },
        -- Configure the LSP
        lsp = {
          -- Use lspconfig to set up ccls
          lspconfig = {
            -- Standard lspconfig options
            cmd = { "ccls" },
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_dir = function(fname)
              return require("lspconfig.util").root_pattern(
                "compile_commands.json",
                "compile_flags.txt",
                ".git"
              )(fname) or require("lspconfig.util").find_git_ancestor(fname)
            end,
            -- Initialize options for ccls
            init_options = {
              -- Use a proper cache directory
              cache = { directory = cache_dir },
              -- Enable clang features
              clang = {
                excludeArgs = { "-frounding-math" },
                extraArgs = { "--gcc-toolchain=/usr" },
              },
              -- Index options
              index = {
                threads = 0, -- Auto-detect number of threads
                comments = 2, -- Index comments (2 = parse commands in comments)
              },
              -- Improve completion
              completion = {
                placeholder = true,
                detailedLabel = true,
                spellChecking = true,
              },
              -- Enable cross-references
              cross = {
                kind = true,
                hierarchy = true,
              },
              -- Enable code lens
              codeLens = {
                localVariables = true,
              }
            },
            -- Custom capabilities if needed
            capabilities = vim.lsp.protocol.make_client_capabilities(),
            flags = { debounce_text_changes = 150 },
          },
          -- Enable code lens support
          codelens = {
            enable = true,
            events = { "BufEnter", "CursorHold", "InsertLeave" }
          }
        }
      })

      -- Set up custom mappings for ccls features
      local opts = { noremap = true, silent = true }

      -- Basic mappings
      vim.api.nvim_set_keymap("n", "<leader>xh", ":CclsBaseHierarchy<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xd", ":CclsDerivedHierarchy<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xc", ":CclsCallHierarchy<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xm", ":CclsMemberHierarchy<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xv", ":CclsVars<CR>", opts)

      -- Function to open hierarchies in float windows
      vim.api.nvim_set_keymap("n", "<leader>xhf", ":CclsBaseHierarchy float<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xdf", ":CclsDerivedHierarchy float<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xcf", ":CclsCallHierarchy float<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xmf", ":CclsMemberHierarchy float<CR>", opts)

      -- Function-specific mappings
      vim.api.nvim_set_keymap("n", "<leader>xf", ":CclsMemberFunctionHierarchy<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xt", ":CclsMemberTypeHierarchy<CR>", opts)

      -- Call direction mappings
      vim.api.nvim_set_keymap("n", "<leader>xi", ":CclsIncomingCallsHierarchy<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xo", ":CclsOutgoingCallsHierarchy<CR>", opts)

      -- Quickfix list versions
      vim.api.nvim_set_keymap("n", "<leader>xqb", ":CclsBase<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xqd", ":CclsDerived<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xqi", ":CclsIncomingCalls<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xqo", ":CclsOutgoingCalls<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xqm", ":CclsMember<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xqf", ":CclsMemberFunction<CR>", opts)
      vim.api.nvim_set_keymap("n", "<leader>xqt", ":CclsMemberType<CR>", opts)

      -- Auto-close NodeTree windows on jump (set this to false if you want to keep the tree open)
      vim.g.ccls_close_on_jump = true

      -- Set the maximum depth for hierarchies (default is 3)
      vim.g.ccls_levels = 5

      -- Set up highlighting for NodeTree
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "NodeTree",
        callback = function()
          -- Set up custom highlighting if desired
          vim.api.nvim_set_hl(0, "NodeTreeMarkLeaf", { link = "Special" })
          vim.api.nvim_set_hl(0, "NodeTreeMarkExpanded", { link = "Directory" })
          vim.api.nvim_set_hl(0, "NodeTreeMarkCollapsed", { link = "Statement" })
        end
      })
    end
  }
}
