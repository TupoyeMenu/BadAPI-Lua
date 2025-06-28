-- This file is loaded first

json = require("thirdparty.includes.json")

require("includes.extensions.math")
require("includes.extensions.string")
require("includes.extensions.table")
require("includes.extensions.vector")

require("includes.common")
require("includes.ffi_init")
require("includes.detour_hook")
require("includes.packet")
require("includes.player")
require("includes.notify")

require("includes.enums.wndproc")
require("includes.enums.pad")
require("includes.enums.blips")

-- ~~Actual modules~~
-- Not anymore
require("includes.bytepatch")
require("includes.command")
require("includes.entity")
require("includes.vehicle")
require("includes.ped")
require("includes.control")
require("includes.blip")
require("includes.teleport")
