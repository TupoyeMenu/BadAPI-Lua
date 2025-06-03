local STREAMING = STREAMING
local ENTITY = ENTITY
local entities = entities

entity = {}

function entity.take_control_of(entity_index, timeout)
	if timeout == nil then
		timeout = 300
	end
	--TODO: Port to lua
	entities.take_control_of(entity_index, timeout)
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
	local result

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
---@param entity_index number
---@return boolean success
function entity.delete(entity_index)
	if not ENTITY.DOES_ENTITY_EXIST(entity_index) then
		return false
	end

	for _, value in ipairs(entity.get_entities(true, true, true)) do
		if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(value, entity_index) then
			entity.delete(value)
		end
	end

	ENTITY.DETACH_ENTITY(entity_index, false, false)
	ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity_index, 7000, 7000, 0, false, false, false)
	if not ENTITY.IS_ENTITY_A_MISSION_ENTITY(entity_index) then
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity_index, true, true)
	end
	ENTITY.DELETE_ENTITY(entity_index)
	return true
end