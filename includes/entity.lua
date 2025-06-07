local STREAMING = STREAMING
local ENTITY = ENTITY
local entities = entities

entity = {}

function entity.take_control_of(entity_index, timeout)
	if timeout == nil then
		timeout = 300
	end
	--TODO: Port to lua
	return entities.take_control_of(entity_index, timeout)
end

---Loads the model into memory so you can spawn it later
---@param hash number Joaat hash of the model name
---@return boolean has_loaded
function entity.request_model(hash)
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
function entity.get_entities(vehicles, peds, props)
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

---Deletes the entity
---@param entity_index integer
---@return boolean success
function entity.delete(entity_index)
	if not ENTITY.DOES_ENTITY_EXIST(entity_index) then
		return false
	end

	if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity_index) then
		return false
	end

	for _, value in ipairs(entity.get_entities(true, true, true)) do
		if ENTITY.IS_ENTITY_A_VEHICLE(entity_index) and ENTITY.IS_ENTITY_A_PED(value) and PED.IS_PED_IN_VEHICLE(value, entity_index, true) then
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(value)
			goto continue
		end
		if ENTITY.GET_ENTITY_ATTACHED_TO(value) == entity_index then
			entity.delete(value)
		end
		::continue::
	end

	if ENTITY.IS_ENTITY_ATTACHED(entity_index) then
		ENTITY.DETACH_ENTITY(entity_index, false, false)
	end
	ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity_index, 7000, 7000, 0, false, false, false)
	if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity_index) then
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity_index, true, true)
	end
	ENTITY.DELETE_ENTITY(entity_index) -- This will almost always fail
	ENTITY.SET_PED_AS_NO_LONGER_NEEDED(entity_index)
	return true
end


---Loads terrain at location
---@param location vec3
---@return boolean found_ground
function entity.load_ground_at_3dcoords(location)
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
