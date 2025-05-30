## -- HARPOON --

```
local harpoon = require("harpoon")
map("<leader>ha", function() harpoon:list():add() end, "harpoon add")
map("<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, "harpoon list")
map("<leader>h1", function() harpoon:list():select(1) end, "harpoon select1")
map("<leader>h2", function() harpoon:list():select(2) end, "harpoon select2")
map("<leader>h3", function() harpoon:list():select(3) end, "harpoon select")
map("<leader>h4", function() harpoon:list():select(4) end, "harpoon select")
map("<leader>hp", function() harpoon:list():prev() end, "harpoon prev")
map("<leader>hn", function() harpoon:list():next() end, "harpoon next")
```
