return {
  entry = function()
    -- Use the correct "enter" command which navigates into directories
    -- but does nothing on files (just like pressing 'l' or right arrow)
    ya.emit("enter", {})

    -- Use the same quit command as the Q key binding to avoid confirmation
    ya.emit("quit", { "--no-cwd-file" })
  end,
}
