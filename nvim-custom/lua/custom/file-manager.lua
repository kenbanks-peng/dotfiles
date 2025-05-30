local treeMode

local function is_sidebar()
  return treeMode == 'sidebar'
end

local function is_float()
  return treeMode == 'float'
end

local function neotree_float()
  treeMode = 'float'
  vim.cmd("Neotree float toggle")
end

local function neotree_left()
  treeMode = 'sidebar'
  vim.cmd("Neotree left toggle")
end

local function count_non_ui_windows()
  local count = 0
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local win_config = vim.api.nvim_win_get_config(win)
    if not win_config.relative or win_config.relative == '' then
      count = count + 1
    end
  end
  return count
end

local function close()
  local buf = vim.api.nvim_get_current_buf()
  local num_buffers = #vim.fn.getbufinfo({ buflisted = 1 })
  local num_windows = count_non_ui_windows() -- Count only non-UI windows

  -- close window if the buffer is displayed in another window
  local current_window_id = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == buf and win ~= current_window_id then
      vim.api.nvim_win_close(current_window_id, true)
      return
    end
  end

  -- if more buffers than windows
  if num_buffers > num_windows then
    local current_window_count = 0
    local buffers = vim.fn.getbufinfo({ buflisted = 1 })

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local win_buf = vim.api.nvim_win_get_buf(win)
      if win_buf == buf then
        current_window_count = current_window_count + 1
      end
    end

    -- if buffer in multiple windows
    if current_window_count > 1 then
      -- place inactive buffer in the current window
      for _, buffer in ipairs(buffers) do
        if buffer.bufnr ~= buf and vim.fn.buflisted(buffer.bufnr) == 1 then
          local is_in_window = false
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_buf(win) == buffer.bufnr then
              is_in_window = true
              break
            end
          end
          if not is_in_window then
            vim.api.nvim_set_current_buf(buffer.bufnr)
            return
          end
        end
      end
    else
      -- if buffer is only in the current window
      for _, buffer in ipairs(buffers) do
        if buffer.bufnr ~= buf and vim.fn.buflisted(buffer.bufnr) == 1 then
          local is_in_window = false
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_buf(win) == buffer.bufnr then
              is_in_window = true
              break
            end
          end
          if not is_in_window then
            -- switch to inactive buffer
            vim.api.nvim_set_current_buf(buffer.bufnr)
            -- delete current buffer
            vim.api.nvim_buf_delete(buf, { force = true }) -- Use force to avoid errors
            return
          end
        end
      end
    end
  else
    -- if not more buffers than windows
    if num_windows == 1 and num_buffers == 1 then
      -- if last window and buffer, check if buffer is empty
      local buffer_lines = vim.fn.getbufline('%', 1, '$')
      if #buffer_lines == 1 and buffer_lines[1] == '' then
        vim.cmd('q')
      else
        vim.cmd('bdelete')
      end
      return
    end

    local current_window_count = 0
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local win_buf = vim.api.nvim_win_get_buf(win)
      if win_buf == buf then
        current_window_count = current_window_count + 1
      end
    end

    -- if buffer in more than one window, close current window
    if current_window_count > 1 then
      vim.api.nvim_win_close(0, true)
    else
      -- close current window and delete buffer
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(buf, { force = true }) -- Use force to avoid errors
    end
  end
end


return {
  close = close,
  is_float = is_float,
  is_sidebar = is_sidebar,
  neotree_float = neotree_float,
  neotree_left = neotree_left,
}
