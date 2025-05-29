-- Add this to your NormalNvim configuration
-- You can either put this in init.lua or create a separate file like lua/config/diagnostics.lua

-- Method 1: Add directly to your init.lua or a configuration file
local function setup_zotcite_diagnostics()
  -- Load the diagnostic module (assuming you saved the previous code as lua/diagnostics/zotcite.lua)
  local diagnostics = require("diagnostics.zotcite")

  -- Create user commands that you can run from the command palette
  vim.api.nvim_create_user_command(
    "ZotciteDiagnostics",
    function() diagnostics.run_full_diagnostics() end,
    {
      desc = "Run comprehensive zotcite diagnostics",
    }
  )

  vim.api.nvim_create_user_command(
    "ZotciteQuickTest",
    function() diagnostics.run_quick_test() end,
    {
      desc = "Run quick zotcite test",
    }
  )

  vim.api.nvim_create_user_command(
    "ZotciteLuarocksTest",
    function() diagnostics.test_luarocks_fix() end,
    {
      desc = "Test luarocks integration fix",
    }
  )

  -- Individual diagnostic commands
  vim.api.nvim_create_user_command(
    "ZotciteTestSQLite",
    function() print(diagnostics.test_sqlite_bindings()) end,
    {
      desc = "Test SQLite bindings availability",
    }
  )

  -- Individual diagnostic commands
  vim.api.nvim_create_user_command(
    "ZotciteTestDetailedSQLite",
    function() print(diagnostics.test_detailed_sqlite_bindings()) end,
    {
      desc = "Test SQLite bindings availability",
    }
  )
  vim.api.nvim_create_user_command(
    "ZotciteTestDatabase",
    function() print(diagnostics.test_database_access()) end,
    {
      desc = "Test Zotero database access",
    }
  )

  vim.api.nvim_create_user_command(
    "ZotciteTestLoading",
    function() print(diagnostics.test_zotcite_loading()) end,
    {
      desc = "Test zotcite plugin loading",
    }
  )

  -- Add keybindings to your existing mappings
  vim.keymap.set(
    "n",
    "<leader>zd",
    function() diagnostics.run_full_diagnostics() end,
    { desc = "Zotcite diagnostics" }
  )

  vim.keymap.set(
    "n",
    "<leader>zt",
    function() diagnostics.run_quick_test() end,
    { desc = "Zotcite quick test" }
  )
end

-- Call the setup function
setup_zotcite_diagnostics()

