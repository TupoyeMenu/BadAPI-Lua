Teleport = {}

---Teleports local ped to coords.
---@param location vec3 Coords to teleport to.
function Teleport.ToCoords(location)
	PED.SET_PED_COORDS_KEEP_VEHICLE(PLAYER.PLAYER_PED_ID(), location.x, location.y, location.z)
end

---Teleports local ped into vehicle.
---@param veh integer Vehicle to teleport into.
---@return boolean success True if teleport is successful.
function Teleport.IntoVehicle(veh)
	if not ENTITY.IS_ENTITY_A_VEHICLE(veh) then
		log.warning("Teleport: Invalid Vehicle")
		return false
	end

	local seat_index = 255
	if VEHICLE.IS_VEHICLE_SEAT_FREE(veh, -1, true) then
		seat_index = -1
	elseif VEHICLE.IS_VEHICLE_SEAT_FREE(veh, -2, true) then
		seat_index = -2
	end

	if seat_index == 255 then
		log.warning("Teleport: There are no seats available in this vehicle for you.")
		return false
	end

	local location = ENTITY.GET_ENTITY_COORDS(veh, true)
	Entity.LoadGroundAt3dcoords(location)

	ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), location.x, location.y, location.z, false, false, false, false)

	script:yield()

	PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, seat_index)

	return true
end

---Teleports local ped to blip.
---@param sprite integer Blip sprite to search for.
---@param color integer Blip color to search for, set to -1 to ignore.
---@return boolean success
function Teleport.ToBlip(sprite, color)
	local result, location = blip.get_location(sprite, color)
	
	if result then
		Entity.LoadGroundAt3dcoords(location)
		Teleport.ToCoords(location)
	end

	return result
end

---Teleports local ped to entity.
---@param entity integer Entity id to teleport to.
function Teleport.ToEntity(entity)
	local coords = ENTITY.GET_ENTITY_COORDS(entity, true)
	Teleport.ToCoords(coords)
end

---Teleports local ped to player.
---@param player_id integer Player id to teleport to.
function Teleport.ToPlayer(player_id)
	Teleport.ToEntity(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id))
end

---Teleport local ped to map waypoint.
---@return boolean success
function Teleport.ToWaypoint()
	if not Teleport.ToBlip(BlipIcons.RADAR_WAYPOINT, -1) then
		return false
	end
	
	return true
end

local empty_vec3 = vec3:new(0,0,0)

---Teleports local ped on top of ent.
---@param ent integer Entity id to teleport to
---@param match_velocity boolean|nil Match the speed of the entity
---@return boolean success
function Teleport.TpOnTop(ent, match_velocity)
	if ENTITY.DOES_ENTITY_EXIST(ent) then
		return false
	end
	local min, max = MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(ent), empty_vec3, empty_vec3)
	local ent_pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0,0,max.z)
	ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), ent_pos.x, ent_pos.y, ent_pos.z, false, false, false)

	if match_velocity then
		local ent_velocity = ENTITY.GET_ENTITY_VELOCITY(ent)
		ENTITY.SET_ENTITY_VELOCITY(PLAYER.PLAYER_PED_ID(), ent_velocity.x, ent_velocity.y, ent_velocity.z)
	end

	return true
end
