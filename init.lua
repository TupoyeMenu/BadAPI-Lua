-- This file is loaded first

json = require("thirdparty.includes.json")

require("includes.extentions.math")
require("includes.extentions.string")
require("includes.extentions.vector")

require("includes.common")
require("includes.ffi_init")
require("includes.hooking")
require("includes.detour_hook")

require("includes.enums.wndproc")
require("includes.enums.pad")
require("includes.enums.blips")

-- ~~Actual modules~~
-- Not anymore
require("includes.bytepatch")
require("includes.command")
require("includes.entity")
require("includes.vehicle")
require("includes.control")
require("includes.blip")
require("includes.teleport")
