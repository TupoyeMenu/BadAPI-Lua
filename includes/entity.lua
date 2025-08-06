local ffi = require("ffi")
local STREAMING = STREAMING
local ENTITY = ENTITY
local entities = entities

---@class Entity
---@field m_Pointer ffi.cdata*
---@field m_Handle EntityHandle
Entity = {}

---Creates an entity object for an existing entity.
---@param p integer|ffi.cdata*|nil Pointer to fwEntity or entity index, nil is only allowed for inheritance.
---@return Entity
function Entity:new(p)
	assert(type(p) == "number" or type(p) == "cdata" or p == nil, "bad argument 'p' for 'Entity:new'.\nExpected number or cdata got " .. type(p))

	---@type Entity
	---@diagnostic disable-next-line: missing-fields
	o = {}

	if type(p) == "number" then
		o.m_Handle = p
		Entity.PopulatePointer(o)
	elseif type(p) == "cdata" then
		o.m_Pointer = p
		Entity.PopulateHandle(o)
	end

	setmetatable(o, self)
	self.__index = self

	return o
end

---@protected
function Entity:AssertValid()
	assert(self:IsValid(), "Entity is invalid")
end

function Entity:PopulatePointer()
	self.m_Pointer = menu_exports.handle_to_ptr(self.m_Handle)
end
function Entity:PopulateHandle()
	if (self.m_Pointer) then
		self.m_Handle = menu_exports.ptr_to_handle(self.m_Pointer)
	end
end

---@return EntityHandle
function Entity:GetHandle()
	self:AssertValid()
	return self.m_Handle
end

---@return ffi.cdata*
function Entity:GetPointer()
	return self.m_Pointer
end

function Entity:TakeControlOf(timeout)
	self:AssertValid()
	if timeout == nil then
		timeout = 300
	end
	--TODO: Port to lua
	return entities.take_control_of(self:GetHandle(), timeout)
end

---@return boolean
function Entity:HasControl()
	self:AssertValid()
	return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(self.m_Handle)
end

---@return boolean
function Entity:IsValid()
	return ENTITY.DOES_ENTITY_EXIST(self.m_Handle)
end

---@return boolean
function Entity:IsPed()
	self:AssertValid()
	return ENTITY.IS_ENTITY_A_PED(self.m_Handle)
end

---@return boolean
function Entity:IsVehicle()
	self:AssertValid()
	return ENTITY.IS_ENTITY_A_VEHICLE(self.m_Handle)
end

---@return boolean
function Entity:IsObject()
	self:AssertValid()
	return ENTITY.IS_ENTITY_AN_OBJECT(self.m_Handle)
end

---TODO Move to Ped class
---@return boolean
function Entity:IsPlayer()
	self:AssertValid()
	return PED.IS_PED_A_PLAYER(self.m_Handle)
end

---@return boolean
function Entity:IsMissionEntity()
	self:AssertValid()
	return ENTITY.IS_ENTITY_A_MISSION_ENTITY(self.m_Handle)
end

---@param script_ent boolean?
---@param steal_from_other_script boolean?
function Entity:SetAsMissionEntity(script_ent, steal_from_other_script)
	script_ent = script_ent or true
	steal_from_other_script = steal_from_other_script or false

	ENTITY.SET_ENTITY_AS_MISSION_ENTITY(self.m_Handle, script_ent, steal_from_other_script)
end

function Entity:SetAsNoLongerNeeded()
	ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(self.m_Handle)
end

---@return integer
function Entity:GetModel()
	self:AssertValid()
	return ENTITY.GET_ENTITY_MODEL(self.m_Handle)
end

---@return vec3
function Entity:GetPosition()
	self:AssertValid()
	if not ENTITY.DOES_ENTITY_EXIST(self.m_Handle) and self.m_Pointer then
		local pos = self.m_Pointer.m_Transform.rows[3]
		return vec3:new(pos.x, pos.y, pos.z)
	end
	return ENTITY.GET_ENTITY_COORDS(self.m_Handle, false)
end

---@param position vec3
function Entity:SetPosition(position)
	self:AssertValid()
	ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self.m_Handle, position.x, position.y, position.z, true, true, false)
end

---@param order integer
---@return vec3
function Entity:GetRotation(order)
	self:AssertValid()
	return ENTITY.GET_ENTITY_ROTATION(self.m_Handle, order)
end

---@return vec3
function Entity:GetDirection()
	self:AssertValid()
	return math.rotation_to_direction(self:GetRotation(0))
end

---@param order integer
---@param rotation vec3
function Entity:SetRotation(rotation, order)
	self:AssertValid()
	return ENTITY.SET_ENTITY_ROTATION(self.m_Handle, rotation.x, rotation.y, rotation.z, order, false)
end

---@return vec3
function Entity:GetVelocity()
	self:AssertValid()
	return ENTITY.GET_ENTITY_VELOCITY(self.m_Handle)
end

---@param vel vec3
function Entity:SetVelocity(vel)
	self:AssertValid()
	ENTITY.SET_ENTITY_VELOCITY(self.m_Handle, vel.x, vel.y, vel.z)
end

---@return number
function Entity:GetHeading()
	self:AssertValid()
	return ENTITY.GET_ENTITY_HEADING(self.m_Handle)
end

---@param heading number
function Entity:SetHeading(heading)
	self:AssertValid()
	ENTITY.SET_ENTITY_HEADING(self.m_Handle, heading)
end

---@return number
function Entity:GetSpeed()
	self:AssertValid()
	return ENTITY.GET_ENTITY_SPEED(self.m_Handle)
end

---@param enabled boolean
function Entity:SetCollision(enabled)
	self:AssertValid()
	ENTITY.SET_ENTITY_COLLISION(self.m_Handle, enabled, true)
end

---@return boolean
function Entity:GetCollision()
	return self.m_Pointer.m_CollisionFlags.m_HasCollision
end

---@param enabled boolean
function Entity:SetFrozen(enabled)
	self:AssertValid()
	ENTITY.FREEZE_ENTITY_POSITION(self.m_Handle, enabled)
end

---@return boolean
function Entity:IsFrozen()
	return self.m_Pointer.m_Flags.m_Frozen
end

---@param enabled boolean
function Entity:SetDynamic(enabled)
	self:AssertValid()
	ENTITY.SET_ENTITY_DYNAMIC(self.m_Handle, enabled)
end

function Entity:ActivatePhysics()
	PHYSICS.ACTIVATE_PHYSICS(self.m_Handle)
end

---@return boolean
function Entity:HasPhysics()
	return ENTITY.DOES_ENTITY_HAVE_PHYSICS(self.m_Handle)
end

---@return ffi.cdata*?
function Entity:GetNetworkObject()
	self:AssertValid()

	return ffi.cast("struct CDynamicEntity*", self.m_Pointer).m_NetObject
end

---@return boolean
function Entity:IsNetworked()
	return self:GetNetworkObject() ~= nil
end

---Deletes the entity
---@return boolean success
function Entity:Delete()
	self:AssertValid()

	if self:IsNetworked() and not self:HasControl() then
		-- This may cause issues anyway, since players can be in the vehicle.
		log.fatal("Deleting networked entities without control is not implemented!")
		return false
	else
		if not self:IsMissionEntity() then
			self:SetAsMissionEntity(true, true)
		end
		ENTITY.DELETE_ENTITY(self.m_Handle) -- FIXME, this may not work if the entity does not belong to our script
		return true
	end
end

function Entity:PreventMigration()
	self:AssertValid()
	if not network.is_session_started() then return end

	if not self:IsNetworked() or not NETWORK.NETWORK_HAS_ENTITY_BEEN_REGISTERED_WITH_THIS_THREAD(self.m_Handle) then
		return
	end

	NETWORK.NETWORK_DISABLE_PROXIMITY_MIGRATION(NETWORK.OBJ_TO_NET(self.m_Handle))
end

---@return boolean
function Entity:IsInvincible()
	self:AssertValid()

	return ffi.cast("struct CPhysical*", self.m_Pointer).m_damage_bits.m_IsInvincible
end

---@param status boolean
function Entity:SetInvincible(status)
	self:AssertValid()
	ENTITY.SET_ENTITY_INVINCIBLE(self.m_Handle, status, true)
end

---@return boolean
function Entity:IsDead()
	self:AssertValid()
	return ENTITY.IS_ENTITY_DEAD(self.m_Handle, true)
end

function Entity:Kill()
	self:AssertValid()
	if self:HasControl() then
		ENTITY.SET_ENTITY_HEALTH(self.m_Handle, 0, PLAYER.PLAYER_PED_ID(), 0)
	else
		log.fatal("Killing entities without control is not implemented!")
	end
end

---@return integer
function Entity:GetHealth()
	self:AssertValid()
	return ENTITY.GET_ENTITY_HEALTH(self.m_Handle)
end

---@param health number
function Entity:SetHealth(health)
	self:AssertValid()
	ENTITY.SET_ENTITY_HEALTH(self.m_Handle, health, 0, 0)
end

---@return integer
function Entity:GetMaxHealth()
	self:AssertValid()
	return ENTITY.GET_ENTITY_MAX_HEALTH(self.m_Handle)
end

---@param health number
function Entity:SetMaxHealth(health)
	self:AssertValid()
	ENTITY.SET_ENTITY_MAX_HEALTH(self.m_Handle, health)
end

---@return boolean
function Entity:IsVisible()
	self:AssertValid()
	return ENTITY.IS_ENTITY_VISIBLE(self.m_Handle)
end

---@param status boolean
function Entity:SetVisible(status)
	self:AssertValid()
	ENTITY.SET_ENTITY_VISIBLE(self.m_Handle, status, true)
end

---@return integer
function Entity:GetAlpha()
	self:AssertValid()
	return ENTITY.GET_ENTITY_ALPHA(self.m_Handle)
end

---Alpha is not networked
---@param alpha integer
function Entity:SetAlpha(alpha)
	self:AssertValid()
	ENTITY.SET_ENTITY_ALPHA(self.m_Handle, alpha, false)
end

function Entity:ResetAlpha()
	self:AssertValid()
	ENTITY.RESET_ENTITY_ALPHA(self.m_Handle)
end

---@return boolean
function Entity:HasInterior()
	self:AssertValid()
	return INTERIOR.GET_ROOM_KEY_FROM_ENTITY(self.m_Handle) ~= 0
end

---@param explosion integer
---@param damage number
---@param is_visible boolean
---@param is_audible boolean
---@param camera_shake number
---@param no_damage boolean?
function Entity:Explode(explosion, damage, is_visible, is_audible, camera_shake, no_damage)
	self:AssertValid()
	no_damage = no_damage or false

	local pos = self:GetPosition()
	FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, explosion, damage, is_audible, is_visible, camera_shake, no_damage)
end

---@param other Entity
---@return boolean
function Entity:__eq(other)
	if self.m_Handle ~= 0 and other.m_Handle ~= 0 then
		return self.m_Handle == other.m_Handle
	end

	if self.m_Pointer ~= nil and other.m_Pointer ~= nil then
		return self.m_Pointer == other.m_Pointer
	end

	return false
end

---Loads the model into memory so you can spawn it later
---@param hash number Joaat hash of the model name
---@return boolean has_loaded
function Entity.RequestModel(hash)
	if STREAMING.HAS_MODEL_LOADED(hash) then
		return true
	end

	if STREAMING.IS_MODEL_VALID(hash) and STREAMING.IS_MODEL_IN_CDIMAGE(hash) then
		while not STREAMING.HAS_MODEL_LOADED(hash) do
			STREAMING.REQUEST_MODEL(hash)
			script.yield()
		end
		return true
	end
	return false
end

---@param vehicles boolean Inlcude vehicles
---@param peds boolean Inlcude peds
---@param props boolean Inlcude props
---@return table entity_array
function Entity.GetEntities(vehicles, peds, props)
	local result = {}

	if vehicles then
		for _, value in ipairs(entities.get_all_vehicles_as_handles()) do
			result[#result+1] = value
		end
	end
	if peds then
		for _, value in ipairs(entities.get_all_peds_as_handles()) do
			result[#result+1] = value
		end
	end
	if props then
		for _, value in ipairs(entities.get_all_objects_as_handles()) do
			result[#result+1] = value
		end
	end

	return result
end


---Loads terrain at location
---@param location vec3
---@return boolean found_ground
function Entity.LoadGroundAt3dcoords(location)
	local max_ground_check --[[<const>]] = 1000.0
	local max_attempts --[[ <const>]] = 300
	local ground_z = location.z
	local current_attempts = 0
	local found_ground = false

	while not found_ground and current_attempts < max_attempts do
		found_ground, ground_z = MISC.GET_GROUND_Z_FOR_3D_COORD(location.x, location.y, max_ground_check, ground_z, false, false)
		STREAMING.REQUEST_COLLISION_AT_COORD(location.x, location.y, location.z)

		if current_attempts % 10 == 0 then
			location.z = location.z + 25.0
		end

		current_attempts = current_attempts + 1
		script:yield()
	end

	if not found_ground then
		return false
	end

	local in_water, height = WATER.GET_WATER_HEIGHT(location.x, location.y, location.z, 0)

	if in_water then
		location.z = height
	else
		location.z = ground_z + 1
	end

	return true
end
