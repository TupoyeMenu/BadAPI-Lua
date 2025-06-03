local ffi = require("ffi")

require("includes.ffi.minhook")
require("includes.ffi.menu")

if menu_exports.is_enhanced() then -- ffi.menu must be loaded here.
	require("includes.ffi.gta_enhaced")
else
	require("includes.ffi.gta_legacy")
end

require("includes.ffi.meta")
