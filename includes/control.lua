local ffi = require("ffi")
control = {}


local get_player_control
local get_action_interal
local get_input_from_action_internal
if menu_exports.is_enhanced() then
	-- multiple results but all point to the same functions
	local ptr = menu_exports.scan_pattern("48 89 C1 89 F2 E8 ? ? ? ? F3", "")
	get_player_control = ffi.cast("void* (*)(bool)", rip(ptr - 13))
	get_action_interal = ffi.cast("struct CControlAction* (*)(void* control, uint32_t action)", rip(ptr + 6))
	get_input_from_action_internal = ffi.cast("struct CInput* (*)(void* control, struct CInput* result, uint32_t action, int unk, uint8_t unk2, bool unk3)", rip(menu_exports.scan_pattern("41 B9 FC FF FF FF E8 ? ? ? ? 83 7C 24 64 14", "") + 7))
else
	-- multiple results but all point to the same functions
	local ptr = menu_exports.scan_pattern("8B D3 48 8B C8 E8 ? ? ? ? 4C 8D 05", "")
	get_player_control = ffi.cast("void* (*)(bool)", rip(ptr - 18))
	get_action_interal = ffi.cast("struct CControlAction* (*)(void* control, uint32_t action)", rip(ptr + 6))
	get_input_from_action_internal = ffi.cast("struct CInput* (*)(void* control, struct CInput* result, uint32_t action, int unk, uint8_t unk2, bool unk3)", rip(menu_exports.scan_pattern("88 44 24 20 E8 ? ? ? ? B9 03", "") + 5))
end

---@param action number
---@return ffi.cdata*?
function control.action_to_ptr(action)
	if get_player_control and get_action_interal then
		local control = get_player_control(true)
		local action_ptr = get_action_interal(control, action)
		return action_ptr
	end
	return nil
end


---Returns CInput from control action, this is useful if you want to see what key an action is bound to.
---@param action number
---@return ffi.cdata*? cinput
function control.get_input_from_action(action)
	if get_player_control and get_input_from_action_internal then
		local control = get_player_control(true)
		if control == nil then return nil end

		local input = ffi.new("struct CInput")
		get_input_from_action_internal(control, input, action, -4, 0, true)
		return input
	end
	return nil
end
