--[[
event.register_handler(menu_event.Wndproc, function (hwnd, msg, wparam, lparam)
	if msg == 132 then return end
	log.debug("hwnd = " .. tostring(hwnd) .. ", msg = " .. tostring(msg) .. ", wparam = " .. tostring(wparam) .. ", lparam = " .. tostring(lparam))
end)

event.trigger(menu_event.Wndproc, 0,0,0,0)
]]

--local migration_error_patch = scr_patch:new("maintransition", "migration_error_patch", "2D 01 04 00 00 61 ? ? ? 47 ? ? 72 ", 5, { 0x72, 0x2E, 0x01, 0x01 })

_G["!module_name"] = "Dota 3"

local ffi = require("ffi")

function SAVEMIGRATION_IS_MP_ENABLED_hook(ctx)
	--log.debug("We are here! In" .. SCRIPT.GET_THIS_SCRIPT_NAME())
end

--function NETWORK_IS_CLOUD_AVAILABLE_hook(ctx)
--	--log.debug("We are here! In" .. SCRIPT.GET_THIS_SCRIPT_NAME())
--end

function FORCE_CLOUD_MP_STATS_DOWNLOAD_AND_OVERWRITE_LOCAL_SAVE_hook(ctx)
	log.debug("We are at FORCE_CLOUD_MP_STATS_DOWNLOAD_AND_OVERWRITE_LOCAL_SAVE. In " .. SCRIPT.GET_THIS_SCRIPT_NAME())
end

--local menu = ffi.load("scripts/BadAPI.dll")

--menu_exports.ffi_add_native_detour(joaat("maintransition"), 0x84b418e93894ac1cULL, ffi.cast("scrNativeHandler", SAVEMIGRATION_IS_MP_ENABLED_hook))
--menu_exports.ffi_add_native_detour(joaat("maintransition"), 0x6F361B8889A792A3ULL, ffi.cast("scrNativeHandler", FORCE_CLOUD_MP_STATS_DOWNLOAD_AND_OVERWRITE_LOCAL_SAVE_hook))

-- ! Script patches are broken for now !
--scr_patch:new("maintransition", "Skip transaction init", "2D 02 07 00 00 71 38 01 ", 5, { 0x72, 0x2E, 0x02, 0x01 }):enable_patch()
--local skip_stats = scr_patch:new("maintransition", "Skip stats", "71 2E 01 01 72 5D", 0, { 0x00, 0x00, 0x00, 0x00 })
--skip_stats:enable_patch()
--local skip_junk = scr_patch:new("maintransition", "Skip junk", "71 2E 01 01 38 0E ", 0, { 0x00, 0x00, 0x00, 0x00 })
--skip_junk:enable_patch()


--menu.ffi_hook_native(joaat("maintransition"), 0x9A4CF4F48AD77302ULL, ffi.cast("scrNativeHandler", NETWORK_IS_CLOUD_AVAILABLE_hook))

--local native_hash = ffi.new()
--[[
native_hooks.hook_native(joaat("maintransition"), 0x84b418e93894ac1cULL, function(stx)
	--log.debug("We are here! In" .. SCRIPT.GET_THIS_SCRIPT_NAME())
	
end)
]]


local can_access_multiplayer_ptr = memory.scan_pattern("45 33 C0 84 C0 74 14"):sub(4):rip():get_address()
local verify_access_ptr = memory.scan_pattern("84 C0 74 E6 33"):sub(4):rip():get_address()
local can_access_features_ptr = memory.scan_pattern("84 C0 74 E6 33"):sub(4):rip():get_address()
local can_host_ptr = memory.scan_pattern("74 1C 83 F9 02"):sub(16):get_address()
ffi.cdef[[
typedef bool can_access_multiplayer();
typedef bool verify_access(uint64_t, const char*, bool);
typedef bool can_access_features(int, uint64_t);
typedef bool can_host(int);
]]
local can_access_multiplayer = ffi.cast("can_access_multiplayer*", can_access_multiplayer_ptr)
local verify_access = ffi.cast("verify_access*", verify_access_ptr)
local can_access_features = ffi.cast("can_access_features*", can_access_features_ptr)
local can_host = ffi.cast("can_host*", can_host_ptr)


local network_ptr_ptr = memory.scan_pattern("48 8B 0D ? ? ? ? 45 33 C9 48 8B D7"):add(3):rip()

event.register_handler(menu_event.Draw, "debug_menu", function()
	if not gui.is_open() then return end
	if ImGui.Begin("Debug") then
		if ImGui.Button("KYS") then
			script.run_in_fiber(function()
				ENTITY.SET_ENTITY_HEALTH(self.get_ped(), 0, 0, 0)
			end)
		end
		ImGui.SameLine()
		if ImGui.Button("IAmAlive") then
			script.run_in_fiber(function()
				--ENTITY.SET_ENTITY_HEALTH(self.get_ped(), 0, 0, 0)
				NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(self.get_pos().x, self.get_pos().y, self.get_pos().z, 0.0, 2000, 1, 1, -1, -1)
			end)
		end
		ImGui.SameLine()
		if ImGui.Button("Fast run") then
			script.run_in_fiber(function()
				PLAYER.SET_RUN_SPRINT_MULTIPLIER_FOR_PLAYER(self.get_id(), 1.49)
			end)
		end
		if ImGui.Button("Host") then
			script.run_in_fiber(function()
				NETWORK.NETWORK_SESSION_HOST(1, 32, false)
			end)
		end
		if ImGui.Button("Dump save pending info") then
			script.run_in_fiber(function()
				local result, p1 =  NETSHOPPING.NET_GAMESERVER_RETRIEVE_INIT_SESSION_STATUS(0)
				log.debug("\n"
					.. "STAT_LOAD_PENDING: " .. tostring(STATS.STAT_LOAD_PENDING(-1)) .. "\n"
					.. "STAT_SAVE_PENDING: " .. tostring(STATS.STAT_SAVE_PENDING()) .. "\n"
					.. "STAT_SAVE_PENDING_OR_REQUESTED: " .. tostring(STATS.STAT_SAVE_PENDING_OR_REQUESTED()) .. "\n"
					.. "STAT_CLOUD_SLOT_SAVE_FAILED: " .. tostring(STATS.STAT_CLOUD_SLOT_SAVE_FAILED(-1)) .. "\n"
					.. "NETWORK_IS_CLOUD_BACKGROUND_SCRIPT_REQUEST_PENDING: " .. tostring(NETWORK.NETWORK_IS_CLOUD_BACKGROUND_SCRIPT_REQUEST_PENDING()) .. "\n"
					.. "NETWORK_IS_TUNABLE_CLOUD_REQUEST_PENDING: " .. tostring(NETWORK.NETWORK_IS_TUNABLE_CLOUD_REQUEST_PENDING()) .. "\n"
					.. "NETWORK_IS_CLOUD_AVAILABLE: " .. tostring(NETWORK.NETWORK_IS_CLOUD_AVAILABLE()) .. "\n"
					.. "STAT_CLOUD_SLOT_LOAD_FAILED: " .. tostring(STATS.STAT_CLOUD_SLOT_LOAD_FAILED(0)) .. "\n"
					.. "STAT_CLOUD_SLOT_LOAD_FAILED_CODE: " .. tostring(STATS.STAT_CLOUD_SLOT_LOAD_FAILED_CODE(0)) .. "\n"
					.. "STAT_SLOT_IS_LOADED: " .. tostring(STATS.STAT_SLOT_IS_LOADED(0)) .. "\n"
					.. "ARE_PROFILE_SETTINGS_VALID: " .. tostring(MISC.ARE_PROFILE_SETTINGS_VALID()) .. "\n"
					.. "UGC_HAS_GET_FINISHED: " .. tostring(NETWORK.UGC_HAS_GET_FINISHED()) .. "\n"
					.. "UGC_DID_GET_SUCCEED: " .. tostring(NETWORK.UGC_DID_GET_SUCCEED()) .. "\n"
					.. "UGC_IS_GETTING: " .. tostring(NETWORK.UGC_IS_GETTING()) .. "\n"
					.. "GET_SCREENBLUR_FADE_CURRENT_TIME: " .. tostring(GRAPHICS.GET_SCREENBLUR_FADE_CURRENT_TIME()) .. "\n"
					.. "IS_THREAD_ACTIVE(g_tiTransitionThread): " .. tostring(SCRIPT.IS_THREAD_ACTIVE(globals.get_int(1643882))) .. "\n"
					.. "GET_NAME_OF_SCRIPT_WITH_THIS_ID(g_tiTransitionThread): " .. tostring(SCRIPT.GET_NAME_OF_SCRIPT_WITH_THIS_ID(globals.get_int(1643882))) .. "\n"
					.. "NET_GAMESERVER_RETRIEVE_INIT_SESSION_STATUS(" .. p1 ..  ") : " .. tostring(result) .. "\n"
				)
			end)
		end
		if ImGui.Button("Magic MP") then
			globals.set_int(1575072, 1)
		end
		--[[
		if ImGui.Button("UGC Loaded") then
			globals.set_int(1574546, 1)
		end
		]]
		if ImGui.Button("Offline UGC") then
			globals.set_int(1835431 + 4, 1)
			--globals.set_int(1835437 + 5, 1)
		end
		if ImGui.Button("Stats loaded") then
			globals.set_int(1574538 + 8, 1)
			globals.set_int(1574538 + 16, 1)
		end
		if ImGui.Button("Don't wait") then
			globals.set_int(262145 + 89, 7000) -- Normal value is 140000
		end
		if ImGui.Button("HasValidRosCredentials") then
			log.debug("HasValidRosCredentials: " .. tostring(NETWORK.NETWORK_HAS_VALID_ROS_CREDENTIALS()))
		end
		if ImGui.Button("CanEnterMultiplayer") then
			log.debug("CanEnterMultiplayer: " .. tostring(NETWORK.NETWORK_CAN_ENTER_MULTIPLAYER()))
		end
		if ImGui.Button("can_access_multiplayer_ptr") then
			log.debug("can_access_multiplayer_ptr: " .. tostring(can_access_multiplayer()))
		end
		if ImGui.Button("verify_access") then
			log.debug("verify_access: " .. tostring(verify_access(0, "", true)))
		end
		if ImGui.Button("can_access_features_ptr") then
			log.debug("can_access_features_ptr: " .. tostring(can_access_features(1, 0)))
		end
		if ImGui.Button("can_host_ptr") then
			log.debug("can_host_ptr: " .. tostring(can_host(1)))
		end
		ImGui.Text("network IsInitialised: " .. tostring(ffi.cast("uint8_t*", network_ptr_ptr:deref():get_address() + 0xb3e4)[0]))
	end
	ImGui.End()
end)

--[[
local skip_patch = memory.scan_pattern("84 C0 ? ? 49 8B 06 48 8B 1E"):add(2):patch_word(0x73EB)

skip_patch:apply()

local skip_patch_0 = memory.scan_pattern("33 F6 84 C0 ? ? ? ? ? ? 83 C8"):add(4):patch_dword(0x008ae948)

skip_patch_0:apply()

local skip_patch__1 = memory.scan_pattern("33 D2 41 8B CE E8 ? ? ? ? 84 C0"):add(12):patch_dword(0x00a0e948)

skip_patch__1:apply()
]]

local bit = require("bit")
local time_step = memory.scan_pattern("83 7A 10 01 75 24"):add(11+4):rip()
local game_time_ptr = memory.scan_pattern("8B 05 ? ? ? ? F3 0F 11 ? ? ? ? ? 0F 57"):add(2):rip():get_address()
ffi.cdef[[
typedef struct
{
	uint32_t m_Time;
	uint32_t m_frameCount;
	uint32_t m_TimePrevious;
	float m_StepInSeconds;
	uint32_t m_StepInMs;
	float m_InvStep;
	float m_TimeRemainderMs;
} fwTimeSet;
]]
local game_time = ffi.cast("fwTimeSet*", game_time_ptr)

--[[
local time_step_setter = memory.scan_pattern("E8 ? ? ? ? C6 ? ? ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? E8 ? ? ? ? 48 8B"):sub(8)
log.info(tostring(time_step_setter:get_dword()))
time_step_setter:patch_dword(0x90909090):apply()
time_step_setter:add(4):patch_dword(0x90909090):apply()
log.info(tostring(time_step_setter:get_dword()))
--]]

---@param altitude number Altitude in meters
---@return number pressure Pressure at the given altitude in pascal
function get_pressure_from_altitude(altitude)
	local p = 1013.25 * (1-altitude/44307.694)^5.25530
	return p * 100
end

local air_mollar_mass = 0.0289652
local gas_const = 8.31446261815324

---@param altitude number Altitude in meters
---@param temperature number Temperature in kelvin
---@return number air_density Air Density in kg/m3
function get_air_density_at_altitude(altitude, temperature)
	local pressure = get_pressure_from_altitude(altitude)
	local air_density = (pressure*air_mollar_mass)/(gas_const*temperature)
	return air_density
end

function get_lift(velocity, wing_area, altitude, temperature)
	local air_density = get_air_density_at_altitude(altitude, temperature)
	return 0.5*air_density*velocity^2*wing_area
end

local overlay_window_flags = bit.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoDecoration, ImGuiWindowFlags.NoBackground, ImGuiWindowFlags.NoNav, ImGuiWindowFlags.AlwaysAutoResize)

event.register_handler(menu_event.Draw, "debug_overlay", function()
	--time_step:set_float(game_time.m_StepInSeconds)
	if(ImGui.Begin("overlay", overlay_window_flags)) then
		--local result, click = ImGui.InputFloat("Script Timestep", time_step:get_float() * 1000)
		--if(click) then
		--	time_step:set_float(result / 1000)
		--end

		--ImGui.Text("Script Timestep: " .. time_step:get_float() * 1000)
		ImGui.Text("Game Timestep: " .. tostring(game_time.m_StepInSeconds * 1000))
		ImGui.Text("FrameCount: " .. tostring(game_time.m_frameCount))

		--Debug globals
		--ImGui.Text("g_bLocalPlayerActive: " .. tostring(globals.get_int(2703809+2)))
		--ImGui.Text("g_iLocalPlayerID: " .. tostring(globals.get_int(2703809+3)))
		--ImGui.Text("g_tiTransitionThread: " .. tostring(globals.get_int(1643882)))
		--[[
		ImGui.Text("Transiotion State: " .. tostring(globals.get_int(1575012)))
		ImGui.Text("Blocked MP Access: " .. tostring(globals.get_int(33088)))
		ImGui.Text("MP offline: " .. tostring(globals.get_int(1575072)))
		ImGui.Text("UGC Loaded: " .. tostring(globals.get_int(1574546)))
		ImGui.Text("Offline UGC: " .. tostring(globals.get_int(1835437 + 5)))
		ImGui.Text("4 Timeout: " .. tostring(globals.get_int(262145 + 89)))
		ImGui.Text("Transiotion Track: " .. tostring(globals.get_int(2699021)))
		ImGui.Text("Return TO SP PRELOAD: " .. tostring(globals.get_int(2696433)))
		ImGui.Text("Stats loaded: " .. tostring(globals.get_int(1574538+16)))
		--]]
		
		--ImGui.Text(string.format("%.2f, %.2f, %.2f", self.get_pos().x, self.get_pos().y, self.get_pos().z))
		--ImGui.Text(string.format("Pressure: %.3f", get_pressure_from_altitude(self.get_pos().z)))
		
		-- Don't do this.
		-- ImGui.Text(string.format("In water: %s", ENTITY.IS_ENTITY_IN_WATER(self.get_ped())))
	end
	ImGui.End()
end)











local original_task_jump_ctor = nil
local function task_jump_ctor(a1, a2)
	local args = {a1, a2} -- Args are in a table, that way hook.call can override them.
	local hook_result = hook.call("FFITaskJumpCtor", original_task_jump_ctor, args)
	if hook_result == nil and original_task_jump_ctor then -- If hook.call returns something we don't call the original.
		return original_task_jump_ctor(args[1], args[2])
	end
end
original_task_jump_ctor = detour_hook.register_by_pattern("TaskJumpConstructor", "48 89 5C 24 ? 89 54 24 10 57 48 83 EC 30 0F 29 74 24", "", "uint64_t (*)(uint64_t*, int)", task_jump_ctor, false)

local original_task_fall_ctor = nil
local function task_fall_ctor(a1, a2)
	local args = {a1, a2} -- Args are in a table, that way hook.call can override them.
	local hook_result = hook.call("FFITaskFallCtor", original_task_fall_ctor, args)
	if hook_result == nil and original_task_fall_ctor then -- If hook.call returns something we don't call the original.
		return original_task_fall_ctor(args[1], args[2])
	else
		return hook_result
	end
end
local taskfall_constructor_ptr = rip(menu_exports.ffi_scan_pattern("E8 ? ? ? ? B3 04 08 98 A0", "") + 1)
original_task_fall_ctor = detour_hook.register("TaskFallConstructor", taskfall_constructor_ptr, "uint64_t (*)(uint64_t*, int)", task_fall_ctor, true)


hook.add("FFITaskFallCtor", "argument_testing", function (original, args)
	local NoFallAnimation = bit.lshift(1, 10)
	local NoSlowFall = bit.lshift(1, 11)
	local Unk12 = bit.lshift(1, 12)
	local LandOnJump = bit.lshift(1, 16)
	local GracefulLanding = bit.bor(NoFallAnimation, NoSlowFall, Unk12, LandOnJump)

	args[2] = bit.bor(args[2], GracefulLanding)
end)

--[[
hook.add("FFITaskFallCtor", "argument_testing2", function (original, args)
	print_table(args)
	local og_result = original(args[1], args[2])
	print(og_result)
	return og_result
end)
--]]
hook.add("FFITaskJumpCtor", "superjump", function (original, args)
	args[2] = bit.bor(args[2], bit.lshift(1, 15))
end)



--[[
local original_http_request = nil
local function http_request(a1, uri)
	log.debug("HTTP Request: " .. ffi.string(uri))

	-- We don't care about calling this, we are on goldberg emulator.
	if original_http_request then
		return original_http_request(a1, uri)
	end
	return false
end
original_http_request = detour_hook.register_by_pattern("HTTPRequest", "48 89 5C 24 ? 48 89 74 24 ? 57 48 83 EC 20 48 8B D9 48 81 C1 ? ? ? ? 48 8B F2 33 FF E8", "", "bool (*)(void*, const char*)", http_request, true)
]]

--[[
local profile_stats_skip = menu_exports.ffi_scan_pattern("84 C0 ? ? ? ? ? ? 41 8A D4", "") + 2
bytepatch.add("ProfileStatsSkip", profile_stats_skip, {0x48, 0xE9})

local ptr = menu_exports.ffi_scan_pattern("48 85 C0 74 52 40 88", "")
--bytepatch.add("ForceLoadStage", ptr + 15, {0x3})
--bytepatch.nop("SkipFail", ptr - 11, 2)
bytepatch.nop("AlwaysFileNotFound", ptr + 35, 2)


local skip_money_check1 = menu_exports.ffi_scan_pattern("84 C0 ? ? 93 01 00 00 48", "") + 2
bytepatch.add("SkipMoneyCheck1", skip_money_check1, {0x48, 0xE9})
local skip_money_check2 = menu_exports.ffi_scan_pattern("84 C0 ? ? AD 01 00 00 48 8B 8D", "") + 2
bytepatch.add("SkipMoneyCheck2", skip_money_check2, {0x48, 0xE9})
local skip_money_check3 = menu_exports.ffi_scan_pattern("84 C0 ? ? 83 C9 FF E8 ? ? ? ? 48 85", "") + 2
bytepatch.nop("SkipMoneyCheck3", skip_money_check3, 2)
bytepatch.nop("SkipMoneyCheck4", skip_money_check3+115, 2)
local skip_money_check5 = menu_exports.ffi_scan_pattern("84 C0 ? ? 8B CB E8 ? ? ? ? 48 85 C0 7E", "") + 2
bytepatch.nop("SkipMoneyCheck5", skip_money_check5, 2)
local skip_money_check6 = menu_exports.ffi_scan_pattern("84 C0 ? ? 8B CF E8 ? ? ? ? 41", "") + 2
bytepatch.nop("SkipMoneyCheck6", skip_money_check6, 2)
]]


--[[
log.info(tostring(menu_exports.ffi_logf_no_level))

local print_script_stack_trace = ffi.cast("bool (*)(struct scrThread*, void*)", rip(menu_exports.ffi_scan_pattern("48 89 0D ? ? ? ? 48 8B C8 E8", "") + 11))
log.info(tostring(print_script_stack_trace))
menu_exports.ffi_logf_no_level("Hello")
local original_gta_thread_kill = nil
local function gta_thread_kill(thread)
	ffi.C.printf("\n\n\nScript terminating callstack\n")
	print_script_stack_trace(ffi.cast("struct scrThread*", thread), ffi.cast("void*", ffi.C.printf))
	ffi.C.printf("\n\n\n")
	local result
	if original_gta_thread_kill then
		result = original_gta_thread_kill(thread)
	end
	log.debug("Script Thread '" .. ffi.string(thread.m_name) .. "' terminated (" .. ffi.string(thread.m_exit_message) .. ").")
	return result
end
original_gta_thread_kill = detour_hook.register_by_pattern("gta_thread_kill", "48 89 5C 24 ? 57 48 83 EC 20 48 83 B9 ? ? ? ? ? 48 8B D9 74 14", "", "int (*)(struct GtaThread*)", gta_thread_kill, true)
]]
