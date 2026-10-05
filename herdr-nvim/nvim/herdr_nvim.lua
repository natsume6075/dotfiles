-- herdr-nvim companion: reload buffers the agent changed on disk, and open files on request.
-- Loaded by bin/hn-nvim via `-c "lua ... dofile(...)"`; it never touches your own config.
local uv = vim.uv or vim.loop
local M = {}

local watchers = {} -- bufnr -> { handle, timer }
local augroup

local function stop(bufnr)
  local w = watchers[bufnr]
  if not w then
    return
  end
  watchers[bufnr] = nil
  for _, h in ipairs({ w.handle, w.timer }) do
    if not h:is_closing() then
      h:close()
    end
  end
end

local function start(bufnr)
  stop(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
    return
  end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" or not uv.fs_stat(path) then
    return
  end
  vim.bo[bufnr].autoread = true

  local handle, timer = uv.new_fs_event(), uv.new_timer()
  local renamed = false
  local ok = handle:start(path, {}, function(err, _, events)
    if err then
      return
    end
    renamed = renamed or (events and events.rename) or false
    -- Debounce bursts of writes (editors/agents often write twice).
    timer:stop()
    timer:start(100, 0, vim.schedule_wrap(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return stop(bufnr)
      end
      vim.cmd("silent! checktime " .. bufnr)
      if renamed then
        -- Atomic replace swaps the inode: re-arm on the new file.
        start(bufnr)
      end
    end))
  end)
  if ok == nil or ok == false then
    handle:close()
    timer:close()
    return
  end
  watchers[bufnr] = { handle = handle, timer = timer }
end

function M.setup()
  augroup = vim.api.nvim_create_augroup("HerdrNvim", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
    group = augroup,
    callback = function(a)
      start(a.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = augroup,
    callback = function(a)
      stop(a.buf)
    end,
  })
  -- Files passed on the command line are read before `-c` runs.
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      start(b)
    end
  end
end

--- Open `path` (optionally at line/col). Called via --remote-expr from bin/hn-open.
function M.open(path, line, col)
  vim.schedule(function()
    local cmd = vim.bo.modified and "split" or "edit"
    local ok, err = pcall(vim.cmd, cmd .. " " .. vim.fn.fnameescape(path))
    if not ok then
      vim.notify("herdr-nvim: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if line and line > 0 then
      pcall(vim.api.nvim_win_set_cursor, 0, { line, math.max((col or 1) - 1, 0) })
      vim.cmd("normal! zz")
    end
  end)
  return 1
end

return M
