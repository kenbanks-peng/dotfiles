# fzf-lua or telescope

- FZF-LUA -- ui seems better than telescope
- TELESCOPE -- See `:help telescope.builtin`

```
?:                   <Cmd>Telescope command_history<CR>       Command History
map("<leader>sh",    builtin.help_tags, "search help")
map("<leader>sk",    builtin.keymaps, "search keymaps")
map("<leader>sw",    builtin.grep_string, "search current word")
map("<leader>sg",    builtin.live_grep, "search by grep")
map("<leader>sd",    builtin.diagnostics, "search diagnostics")
<leader>sR           <Cmd>Telescope resume<CR> Resume
map("<leader>fb",    builtin.buffers, "find in buffers")
gD                   vim.lsp.buf.declaration declaration
gd                   telescope lsp_definitions                definition
gr                   telescope lsp_references                 references
gI                   telescope lsp_implementations            implementation
<leader>sS           No command                               Goto Symbol (Workspace)
<leader>ds(ss)       telescope lsp_document_symbols           document symbols
<leader>ws           telescope lsp_dynamic_workspace_symbols  workspace symbols
<leader>,            <Cmd>Telescope buffers sort...<CR>       Switch Buffer
<leader>so           <Cmd>Telescope vim_options<CR>           Options
<leader>sm           <Cmd>Telescope marks<CR>                 Jump to Mark
<leader>sM           <Cmd>Telescope man_pages<CR>             Man Pages
<leader>sl           <Cmd>Telescope loclist<CR>               Location List
<leader>sj           <Cmd>Telescope jumplist<CR>              Jumplist
<leader>sH           <Cmd>Telescope highlights<CR>            Search Highlight Groups
<leader>sD           <Cmd>Telescope diagnostics<CR>           Workspace Diagnostics
<leader>sC           <Cmd>Telescope commands<CR>              Commands
<leader>sc           <Cmd>Telescope command_history<CR>       Command History
<leader>sb           <Cmd>Telescope current_buffer_ff<CR>     Buffer
<leader>sa           <Cmd>Telescope autocommands<CR>          Auto Commands
<leader>s"           <Cmd>Telescope registers<CR>             Registers
<leader>sq           <Cmd>Telescope quickfix<CR>              Quickfix List
<leader>gs           <Cmd>Telescope git_status<CR>            Status
<leader>gc           <Cmd>Telescope git_commits<CR>           Commits
<leader>fr    **     <Cmd>Telescope oldfiles<CR>              Recent
<leader>fR           No command                               Recent (cwd)
<leader>fg           <Cmd>Telescope git_files<CR>      Find Files (git-files)
<leader>sW           No command                        Word (cwd)
<leader>sG           No command                        Grep (cwd)
<leader>uC           No command                        Colorscheme with Preview
<leader>fF           No command                        Find Files (cwd)
<leader>ff           No command                        Find Files (Root Dir)
<leader>fc           No command                        Find Config File
<leader>sna          search neovim files ??
<leader>snd          search neovim files ??
<leader>snh          search neovim files ??
<leader>snl          search neovim files ??
<leader>snt          search neovim files ??
```
