return {
  entry = function()
    -- Use the correct "enter" command which navigates into directories
    -- but does nothing on files (just like pressing 'l' or right arrow)
    ya.emit("enter", {})

    -- Quit without cwd-file to avoid task conflicts
    ya.emit("quit", {})
  end,
}
