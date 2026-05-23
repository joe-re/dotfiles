require("config.options")
require("config.lazy")

local local_config = vim.fn.stdpath("config") .. "/init.local.lua"
if vim.fn.filereadable(local_config) == 1 then
  dofile(local_config)
end
