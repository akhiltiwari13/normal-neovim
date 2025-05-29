-- Zotcite Diagnostic Suite
-- Add this to your Neovim configuration (e.g., ~/.config/nvim/lua/diagnostics/zotcite.lua)

local M = {}

-- Helper function to safely execute and capture results
local function safe_exec(desc, func)
  print("=== " .. desc .. " ===")
  local ok, result = pcall(func)
  if ok then
    if result then print(result) end
  else
    print("ERROR: " .. tostring(result))
  end
  print("") -- Add spacing between tests
end

-- Individual diagnostic functions
function M.test_neovim_version()
  return string.format("Neovim version: %d.%d.%d",
    vim.version().major, vim.version().minor, vim.version().patch)
end

function M.test_detailed_sqlite_bindings()
  print("=== Detailed SQLite Binding Check ===")
  local bindings = {
    {name = 'lsqlite3', desc = 'LuaSQLite3 (what zotcite expects)'},
    {name = 'sqlite3', desc = 'SQLite3 binding'},
    {name = 'sqlite', desc = 'Basic SQLite binding'},
    {name = 'luasql.sqlite3', desc = 'LuaSQL SQLite3'},
  }

  for _, binding in ipairs(bindings) do
    local ok, mod = pcall(require, binding.name)
    local status = ok and "✓ AVAILABLE" or "✗ Missing"
    print(string.format("%s: %s (%s)", binding.name, status, binding.desc))
    if ok and type(mod) == 'table' then
      print("  Functions available:", table.concat(vim.tbl_keys(mod), ", "))
    end
  end
end

function M.test_sqlite_bindings()
  local results = {}
  local variants = {'sqlite', 'sqlite3', 'lsqlite3', 'luasql.sqlite3'}

  for _, name in ipairs(variants) do
    local ok, mod = pcall(require, name)
    table.insert(results, string.format("%s: %s %s", name, tostring(ok), type(mod)))
  end

  return table.concat(results, "\n")
end

function M.test_lua_paths()
  local results = {"Package path:"}
  for path in string.gmatch(package.path, "[^;]+") do
    table.insert(results, "  " .. path)
  end

  table.insert(results, "\nPackage cpath:")
  for path in string.gmatch(package.cpath, "[^;]+") do
    table.insert(results, "  " .. path)
  end

  return table.concat(results, "\n")
end

function M.test_luarocks_integration()
  local results = {}
  table.insert(results, "LUA_PATH: " .. (os.getenv("LUA_PATH") or "nil"))
  table.insert(results, "LUA_CPATH: " .. (os.getenv("LUA_CPATH") or "nil"))

  return table.concat(results, "\n")
end

function M.test_database_access()
  local db_path = vim.fn.expand("~/Zotero/zotero.sqlite")
  local results = {}

  table.insert(results, "Database path: " .. db_path)
  table.insert(results, "Database exists: " .. tostring(vim.fn.filereadable(db_path) == 1))

  local size = vim.fn.getfsize(db_path)
  if size >= 0 then
    table.insert(results, "Database size: " .. size .. " bytes")
  else
    table.insert(results, "Database size: Cannot read")
  end

  return table.concat(results, "\n")
end

function M.test_direct_sqlite_access()
  local db_path = vim.fn.expand("~/Zotero/zotero.sqlite")
  local bindings = {'lsqlite3', 'sqlite3', 'sqlite'}
  local results = {}

  for _, binding in ipairs(bindings) do
    local ok, sqlite = pcall(require, binding)
    if ok then
      table.insert(results, "Testing " .. binding .. ":")

      local db_ok, db = pcall(sqlite.open, db_path)
      if db_ok and db then
        table.insert(results, "  ✓ Successfully opened database")

        local query_ok, stmt = pcall(db.prepare, db, "SELECT name FROM sqlite_master WHERE type='table' LIMIT 5")
        if query_ok and stmt then
          table.insert(results, "  ✓ Can execute queries")
          stmt:finalize()
        else
          table.insert(results, "  ✗ Cannot execute queries: " .. tostring(stmt))
        end
        db:close()
      else
        table.insert(results, "  ✗ Cannot open database: " .. tostring(db))
      end
    else
      table.insert(results, binding .. ": Not available")
    end
  end

  return table.concat(results, "\n")
end

function M.test_zotcite_loading()
  local results = {}
  local ok, zotcite = pcall(require, 'zotcite')

  if ok then
    table.insert(results, "✓ Zotcite loaded successfully")
    table.insert(results, "Type: " .. type(zotcite))

    if type(zotcite) == 'table' then
      table.insert(results, "Available functions:")
      for k, v in pairs(zotcite) do
        table.insert(results, "  " .. k .. ": " .. type(v))
      end
    end
  else
    table.insert(results, "✗ Zotcite failed to load: " .. tostring(zotcite))
  end

  return table.concat(results, "\n")
end

function M.test_zotcite_setup()
  local results = {}
  local ok, zotcite = pcall(require, 'zotcite')

  if ok then
    table.insert(results, "Attempting zotcite setup...")
    local setup_ok, setup_error = pcall(zotcite.setup, {
      zotero_db_path = vim.fn.expand("~/Zotero/zotero.sqlite")
    })

    if setup_ok then
      table.insert(results, "✓ Setup completed successfully")
    else
      table.insert(results, "✗ Setup failed: " .. vim.inspect(setup_error))
    end
  else
    table.insert(results, "✗ Cannot test setup - zotcite not loaded")
  end

  return table.concat(results, "\n")
end

function M.test_command_registration()
  local commands = {'ZotCite', 'ZotOpen', 'ZotNote', 'ZotBib', 'ZotSearch'}
  local results = {}

  for _, cmd in ipairs(commands) do
    local exists = vim.fn.exists(':' .. cmd) > 0
    local status = exists and "✓" or "✗"
    table.insert(results, status .. " " .. cmd .. " command: " .. tostring(exists))
  end

  return table.concat(results, "\n")
end

function M.test_system_info()
  local results = {}

  -- Neovim compilation info
  table.insert(results, "LuaJIT: " .. (jit and jit.version or "Not available"))
  table.insert(results, "Lua version: " .. _VERSION)

  -- System SQLite version
  local handle = io.popen("sqlite3 --version 2>/dev/null")
  if handle then
    local sqlite_version = handle:read("*a")
    handle:close()
    table.insert(results, "System SQLite: " .. sqlite_version:gsub("\n", ""))
  else
    table.insert(results, "System SQLite: Not found or not accessible")
  end

  -- Luarocks packages
  local luarocks_handle = io.popen("luarocks list 2>/dev/null | grep sqlite")
  if luarocks_handle then
    local luarocks_sqlite = luarocks_handle:read("*a")
    luarocks_handle:close()
    if luarocks_sqlite and luarocks_sqlite ~= "" then
      table.insert(results, "Luarocks SQLite packages:")
      -- table.insert(results, luarocks_sqlite:gsub("\n", "\n  "))
      results[#results + 1] = luarocks_sqlite:gsub("\n", "\n  ")
    else
      table.insert(results, "Luarocks SQLite packages: None found")
    end
  end

  return table.concat(results, "\n")
end

-- Main diagnostic function that runs all tests
function M.run_full_diagnostics()
  print("🔍 ZOTCITE COMPREHENSIVE DIAGNOSTICS")
  print("=====================================")
  print("")

  safe_exec("Neovim Version", M.test_neovim_version)
  safe_exec("SQLite Bindings", M.test_sqlite_bindings)
  safe_exec("SQLite Detailed Bindings", M.test_detailed_sqlite_bindings)
  safe_exec("Lua Package Paths", M.test_lua_paths)
  safe_exec("Luarocks Integration", M.test_luarocks_integration)
  safe_exec("Database Access", M.test_database_access)
  safe_exec("Direct SQLite Access", M.test_direct_sqlite_access)
  safe_exec("Zotcite Loading", M.test_zotcite_loading)
  safe_exec("Zotcite Setup", M.test_zotcite_setup)
  safe_exec("Command Registration", M.test_command_registration)
  safe_exec("System Information", M.test_system_info)

  print("=====================================")
  print("🏁 DIAGNOSTICS COMPLETE")
  print("Review the output above to identify any issues.")
  print("Look for ✗ marks indicating problems that need attention.")
end

-- Quick test for just the essential components
function M.run_quick_test()
  print("⚡ ZOTCITE QUICK TEST")
  print("===================")

  safe_exec("SQLite Bindings", M.test_sqlite_bindings)
  safe_exec("Detailed SQLite Bindings", M.test_detailed_sqlite_bindings)
  safe_exec("Database Access", M.test_database_access)
  safe_exec("Zotcite Loading", M.test_zotcite_loading)
  safe_exec("Command Registration", M.test_command_registration)

  print("===================")
  print("⚡ QUICK TEST COMPLETE")
end

-- Test just the luarocks integration
function M.test_luarocks_fix()
  print("🔧 LUAROCKS INTEGRATION TEST")
  print("============================")

  local before_lua_path = os.getenv("LUA_PATH")
  local before_lua_cpath = os.getenv("LUA_CPATH")

  print("Before fix:")
  print("  LUA_PATH: " .. (before_lua_path or "nil"))
  print("  LUA_CPATH: " .. (before_lua_cpath or "nil"))

  -- Test if lsqlite3 works now
  local sqlite_ok, sqlite_mod = pcall(require, 'lsqlite3')
  print("  lsqlite3 available: " .. tostring(sqlite_ok))

  if sqlite_ok then
    -- Test database access
    local db_path = vim.fn.expand("~/Zotero/zotero.sqlite")
    local db = sqlite_mod.open(db_path)
    if db then
      local stmt = db:prepare("SELECT COUNT(*) FROM items")
      if stmt then
        local result = stmt:step()
        local count = result and stmt:get_value(0) or "unknown"
        print("  Zotero items count: " .. tostring(count))
        stmt:finalize()
      end
      db:close()
      print("  ✓ Full database access working!")
    else
      print("  ✗ Cannot access database")
    end
  end

  print("============================")
end

return M
