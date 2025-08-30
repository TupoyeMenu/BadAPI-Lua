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
require("includes.self")
require("includes.player")
require("includes.notify")
require("includes.raycast")

require("includes.enums.wndproc")
require("includes.enums.pad")
require("includes.enums.blips")

require("includes.pattern")
require("includes.bytepatch")
require("includes.command")
require("includes.gui")
require("includes.menubar")
require("includes.entity")
require("includes.vehicle")
require("includes.ped")
require("includes.control")
require("includes.blip")
require("includes.teleport")
require("includes.globals")
require("includes.locals")

--require("includes.scripted_entity")
require("includes.scripted_weapon")

require("includes.console")
