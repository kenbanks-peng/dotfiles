-- setup package paths
require('config.path')
local merge = require('config.util').merge

local config = {}
merge(config, require('config.keymaps'))
merge(config, require('config.ui'))
merge(config, require('config.font'))
merge(config, require('config.general'))
merge(config, require('config.gpu.gpu'))
merge(config, require('config.domains'))
-- merge(config, require('config.startup'))

return config
