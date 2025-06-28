local ffi = require("ffi")

---@class Ped: Entity
Ped = Entity:new()

local real_new = Ped.new

---Creates a ped object for an existing ped.
---@param p integer|ffi.cdata*|nil Pointer to CPed or entity index, nil is only allowed for inheritance.
---@return Ped
function Ped:new(p)
	return real_new(self, p)
end

---@param args table
function Ped.Spawn(args)
		if isstring(args.name) then
		args.hash = joaat(args.name)
	end

	if args.location == nil or not isnumber(args.location.x) or not isnumber(args.location.y) or not isnumber(args.location.z) then
		args.location = vec3:new(args.x, args.y, args.z)
	end

	if not Entity.RequestModel(args.hash) then
		return
	end

	if args.is_networked and not network.is_session_started() then
		args.is_networked = false
	end

	local ped_handle = PED.CREATE_PED(0, args.hash, args.location.x, args.location.y, args.location.z, args.heading, args.is_networked, args.is_script_ent)
	local ped = Ped:new(ped_handle)
	if not ped:IsValid() then return nil end

	if args.no_longer_needed == true or args.no_longer_needed == nil then
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(args.hash)
	end

	ped:SetPosition(args.location)

	return ped
end

---@return Vehicle?
function Ped:GetVehicle()
	if not PED.IS_PED_IN_ANY_VEHICLE(self.m_Handle, true) then
		return nil
	end

	return Vehicle:new(PED.GET_VEHICLE_PED_IS_USING(self.m_Handle))
end

---only returns a valid handle if the ped isn't already in a vehicle
---@return Vehicle?
function Ped:GetLastVehicle()
	if PED.IS_PED_IN_ANY_VEHICLE(self.m_Handle, true) then
		return nil
	end

	return Vehicle:new(PED.GET_VEHICLE_PED_IS_USING(self.m_Handle))
end

---@param veh Vehicle
---@param seat integer
function Ped:SetIntoVehicle(veh, seat)
	seat = seat or -1

	PED.SET_PED_INTO_VEHICLE(self.m_Handle, veh:GetHandle(), seat)
end

---@return boolean
function Ped:CanRagdoll()
	return PED.CAN_PED_RAGDOLL(self.m_Handle)
end

---@param enabled boolean
function Ped:SetCanRagdoll(enabled)
	PED.SET_PED_CAN_RAGDOLL(self.m_Handle, enabled)
	PED.SET_PED_CAN_BE_KNOCKED_OFF_VEHICLE(self.m_Handle, enabled and 1 or 0)
end

---@param bone integer
---@return vec3
function Ped:GetBonePosition(bone)
	return PED.GET_PED_BONE_COORDS(self.m_Handle, bone, 0, 0, 0)
end

---@param flag integer
---@return boolean
function Ped:GetConfigFlag(flag)
	return PED.GET_PED_CONFIG_FLAG(self.m_Handle, flag, false)
end

---@param flag integer
---@param value boolean
function Ped:SetConfigFlag(flag, value)
	PED.SET_PED_CONFIG_FLAG(self.m_Handle, flag, value)
end

---@return boolean
function Ped:IsEnemy()
	local r1 = PED.GET_RELATIONSHIP_BETWEEN_PEDS(self.m_Handle, PLAYER.PLAYER_PED_ID())
	local r2 = PED.GET_RELATIONSHIP_BETWEEN_PEDS(PLAYER.PLAYER_PED_ID(), self.m_Handle)
	local r3 = PED.IS_PED_IN_COMBAT(self.m_Handle, PLAYER.PLAYER_PED_ID()) and 5 or 0

	if (r1 == 3 or r2 == 3) then
		return true
	end
	if (r1 == 4 or r2 == 4) then
		return true
	end
	if (r1 == 5 or r2 == 5 or r3 == 5) then
		return true
	end
	return false
end

---@return integer
function Ped:GetAccuracy()
	return PED.GET_PED_ACCURACY(self.m_Handle)
end

---@param accuracy integer
function Ped:SetAccuracy(accuracy)
	PED.SET_PED_ACCURACY(self.m_Handle, accuracy)
end

---@return PlayerHandle
function Ped:GetPlayerHandle()
	return NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(self.m_Handle)
end

---@param enabled boolean
function Ped:SetInfiniteAmmo(enabled)
	WEAPON.SET_PED_INFINITE_AMMO(self.m_Handle, enabled, 0)
end

---@param enabled boolean
function Ped:SetInfiniteClip(enabled)
	WEAPON.SET_PED_INFINITE_AMMO_CLIP(self.m_Handle, enabled)
end

---@param hash integer
---@param equip boolean
function Ped:GiveWeapon(hash, equip)
	equip = equip or false

	WEAPON.GIVE_WEAPON_TO_PED(self.m_Handle, hash, 9999, false, equip)
end

---@param hash integer
function Ped:RemoveWeapon(hash)
	WEAPON.REMOVE_WEAPON_FROM_PED(self.m_Handle, hash)
end

---@return integer
function Ped:GetCurrentWeapon()
	local _, hash = WEAPON.GET_CURRENT_PED_WEAPON(self.m_Handle, 0, false)
	return hash
end

---@param hash integer
---@return boolean
function Ped:HasWeapon(hash)
	return WEAPON.HAS_PED_GOT_WEAPON(self.m_Handle, hash, false)
end

---@return integer
function Ped:GetArmour()
	return PED.GET_PED_ARMOUR(self.m_Handle)
end

---@param amount integer
function Ped:SetArmour(amount)
	PED.SET_PED_ARMOUR(self.m_Handle, amount)
end

function Ped:ClearDecals()
	PED.CLEAR_PED_BLOOD_DAMAGE(self.m_Handle)
	PED.CLEAR_PED_WETNESS(self.m_Handle)
	PED.CLEAR_PED_ENV_DIRT(self.m_Handle)
	PED.RESET_PED_VISIBLE_DAMAGE(self.m_Handle)
end

---@param time number
function Ped:SetMaxTimeUnderwater(time)
	PED.SET_PED_MAX_TIME_UNDERWATER(self.m_Handle, time)
end

---@param hash integer
function Ped:SetMaxAmmoForWeapon(hash)
	local _, maxAmmo = WEAPON.GET_MAX_AMMO(self.m_Handle, hash, 0)
	WEAPON.SET_PED_AMMO(self.m_Handle, hash, maxAmmo, false)
end
