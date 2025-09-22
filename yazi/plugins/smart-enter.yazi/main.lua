return {
  entry = function()
    -- enters directory but does nothing on file
    ya.emit("enter", {})
    ya.emit("quit", {})
  end,
}
