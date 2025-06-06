-- This file is loaded first

json = require("thirdparty.includes.json")

require("includes.extentions.math")
require("includes.extentions.string")

require("includes.common")
require("includes.ffi_init")
require("includes.hooking")
require("includes.detour_hook")

require("includes.enums.wndproc")
require("includes.enums.pad")

-- ~~Actual modules~~
-- Not anymore
require("includes.bytebatch")
require("includes.command")
require("includes.entity")
require("includes.vehicle")
require("includes.control")
