---@type table<integer, ScriptedWeapon>
local ScriptedWeapons = {}

---@class ScriptedWeapon
---@field m_Hash integer
---@field m_OwnerPed PedHandle
---@field m_WeaponObject EntityHandle
ScriptedWeapon = {}


---@param hash integer Hash of the weapon we will override
function ScriptedWeapon:new(hash)
	assert(isnumber(hash))

	local o = {}
	o.m_Hash = hash
	o.m_OwnerPed = PLAYER.PLAYER_PED_ID()

	setmetatable(o, self)
	self.__index = self

	ScriptedWeapons[hash] = o

	return o
end

---Called when the weapon should fire
function ScriptedWeapon:Fire()
end

---Called when we should reload the weapon
---You may want to call TASK_RELOAD_WEAPON
function ScriptedWeapon:Reload()
end

---Called every frame when the weapon is out
---Do not sleep in this function
function ScriptedWeapon:Think()
end

function ScriptedWeapon:IsAiming()
	return PED.GET_PED_CONFIG_FLAG(self.m_OwnerPed, 78, false)
end

---Called when the player switches to this weapon
function ScriptedWeapon:OnSwitchTo()
end

---Called when the player switches to another weapon
function ScriptedWeapon:OnSwitchOff()
end

local last_weapon_hash = 0
local just_switched = false
script.register_looped("ScriptedWeaponsThink", function ()
	local ped = Ped:new(self.get_ped())

	if last_weapon_hash ~= ped:GetCurrentWeapon() then
		just_switched = true
	else
		just_switched = false
	end

	for _, weapon in pairs(ScriptedWeapons) do
		weapon.m_OwnerPed = ped.m_Handle
		weapon.m_WeaponObject = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(weapon.m_OwnerPed)
		pcall(function ()
			if weapon:IsSelected() then
				weapon:Think()

				if just_switched then
					weapon:OnSwitchTo()
				end

				PAD.DISABLE_CONTROL_ACTION(0, INPUT_ATTACK, true)
				PAD.DISABLE_CONTROL_ACTION(0, INPUT_ATTACK2, true)
				PAD.DISABLE_CONTROL_ACTION(0, INPUT_RELOAD, true)

				if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, INPUT_RELOAD) then
					weapon:Reload()
				end
				if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, INPUT_ATTACK) then
					weapon:Fire()
				end
			end
		end)

		pcall(function()
			if just_switched and weapon.m_Hash == last_weapon_hash and not weapon:IsSelected() then
				weapon:OnSwitchOff()
			end
		end)
	end

	if last_weapon_hash ~= ped:GetCurrentWeapon() then
		last_weapon_hash = ped:GetCurrentWeapon()
	end
end)


-- TODO: Move to a non scripted class

---@return integer ammo
function ScriptedWeapon:GetAmmo(ammo)
	return WEAPON.GET_AMMO_IN_PED_WEAPON(self.m_OwnerPed, self.m_Hash)
end

---@param ammo integer
function ScriptedWeapon:SetAmmo(ammo)
	WEAPON.SET_PED_AMMO(self.m_OwnerPed, self.m_Hash, ammo, false)
end

---@return integer ammo
function ScriptedWeapon:GetClip()
	local res, ammo = WEAPON.GET_AMMO_IN_CLIP(self.m_OwnerPed, self.m_Hash, 0)
	return ammo
end

---@param ammo integer
function ScriptedWeapon:SetClip(ammo)
	WEAPON.SET_AMMO_IN_CLIP(self.m_OwnerPed, self.m_Hash, ammo)
end

---@return boolean
function ScriptedWeapon:IsReloading()
	return PED.IS_PED_RELOADING(self.m_OwnerPed)
end

---Is the owner ped holding this weapon right now
---@return boolean
function ScriptedWeapon:IsSelected()
	return WEAPON.GET_SELECTED_PED_WEAPON(self.m_OwnerPed) == self.m_Hash
end

---@return vec3
function ScriptedWeapon:GetMuzzlePos()
	local bone_idx = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(self.m_WeaponObject, "gun_muzzle")
	return ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(self.m_WeaponObject, bone_idx)
end
