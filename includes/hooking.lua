local ffi = require("ffi")

hook = {}
local hooks_table = {}

function hook.add(event, identifier, func)
	if event == nil or not isstring(event) then print_stacktrace("bad argument 'event' for 'hook.add'. In:") end
	if identifier == nil or not isstring(identifier) then print_stacktrace("bad argument 'identifier' for 'hook.add'. In:") end

	if not hooks_table[event] then
		hooks_table[event] = {}
	end

	hooks_table[event][identifier] = func
end

function hook.remove(event, identifier)
	if not isstring(event) then print_stacktrace("bad argument 'event' for 'hook.remove'.\nExpected string got " .. type(event) .. "\nIn:") return end
	if not isstring(identifier) then print_stacktrace("bad argument 'identifier' for 'hook.remove'.\nExpected string got " .. type(identifier) .. "\nIn:") return end

	if table[event] then
		table[event][identifier] = nil
	end
end

function hook.call(event, ...)
	if not isstring(event) then print_stacktrace("bad argument 'event' for 'hook.call'.\nExpected string got " .. type(event) .. "\nIn:") return end

	local table_of_this_event = hooks_table[event]
	if table_of_this_event == nil then return end

	for key, value in pairs(table_of_this_event) do
		local result = value(...)
		if result then return result end
	end
end

function hook.get_table()
	return hooks_table
end


-- This should probably be done by scripts themselves.
-- They can put `hook.call` into their detour and we can't call `hook.call` from here.
--[[
function hook.create_c_hook(event, address)
	local function detour()

	end
	ffi.C.ffi_detour_hook_ctor(event, address, detour)
end
]]




-- Compatablity layer for C++ events

event.register_handler(menu_event.Draw, "hook_lib_draw", function()
	hook.call("Draw")
end)
event.register_handler(menu_event.Wndproc, "hook_lib_wndproc", function(hwnd, msg, wparam, lparam)
	hook.call("Wndproc", hwnd, msg, wparam, lparam)
end)
event.register_handler(menu_event.PlayerJoin, "hook_lib_player_join", function(player_name, player_id, net_player_ptr)
	hook.call("PlayerJoin", player_name, player_id, net_player_ptr)
end)
event.register_handler(menu_event.PlayerLeave, "hook_lib_player_leave", function(player_name, net_player_ptr)
	hook.call("PlayerLeave", player_name, net_player_ptr)
end)
event.register_handler(menu_event.PlayerMgrInit, "hook_lib_player_mgr_init", function(net_player_mgr_ptr)
	hook.call("PlayerMgrInit", net_player_mgr_ptr)
end)
event.register_handler(menu_event.PlayerMgrShutdown, "hook_lib_player_mgr_shutdown", function(net_player_mgr_ptr)
	hook.call("PlayerMgrShutdown", net_player_mgr_ptr)
end)
event.register_handler(menu_event.MenuUnloaded, "hook_lib_menu_unloaded", function()
	hook.call("MenuUnloaded")
end)
