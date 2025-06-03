---@diagnostic disable: undefined-doc-param
local ffi = require("ffi")

local send_network_damage_ptr

if menu_exports.is_enhanced() then
	send_network_damage_ptr = menu_exports.scan_pattern("E8 ? ? ? ? E9 E9 01 00 00 48 8B CB", "") - 0x51
else
	send_network_damage_ptr = rip(menu_exports.scan_pattern("E8 ? ? ? ? E9 E9 01 00 00 48 8B CB", "") + 1)
end

---@param source ffi.cdata*
---@param target ffi.cdata*
---@param position ffi.cdata*
---@param hit_component integer
---@param override_default_damage boolean
---@param weapon_type integer
---@param override_damage number
---@param tire_index integer
---@param suspension_index integer
---@param flags integer
---@param action_result_hash integer
---@param action_result_id integer
---@param action_unk integer
---@param hit_weapon boolean
---@param hit_weapon_ammo_attachment boolean
---@param silenced boolean
---@param unk boolean
---@param impact_direction ffi.cdata*
--function send_network_damage(source, target, position, hit_component, override_default_damage, weapon_type, override_damage, tire_index, suspension_index, flags, action_result_hash, action_result_id, action_unk, hit_weapon, hit_weapon_ammo_attachment, silenced, unk, impact_direction)
--end

send_network_damage = ffi.cast("void (*)(struct fwEntity* source, struct fwEntity* target, fvector3* position, int hit_component, bool override_default_damage, int weapon_type, float override_damage, int tire_index, int suspension_index, int flags, uint32_t action_result_hash, int16_t action_result_id, int action_unk, bool hit_weapon, bool hit_weapon_ammo_attachment, bool silenced, bool unk, fvector3* impact_direction)", send_network_damage_ptr)
--send_network_damage(nil, nil, nil, 0, true, 0, 10000, 2, 0, bit.bor(bit.lshift(1, 4), 0x80000), 0, 0, 0, false, false, true, true, nil)
