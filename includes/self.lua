
Self =
{
	Id = 0,

	---@type Ped
	Ped = nil,
	PedId = 0,

	---@type Vehicle
	Veh = nil,
	VehId = 0,

	CharIndex = 0,

	Pos = vec3.zero(),
	Rot = vec3.zero(),
}

local MPPLY_LAST_MP_CHAR = joaat("MPPLY_LAST_MP_CHAR")
script.register_looped("MaintainSelf", function ()
	local player_id = PLAYER.PLAYER_ID()
	Self.Id = player_id

	local ped_id = PLAYER.PLAYER_PED_ID()
	Self.PedId = ped_id

	if Self.Ped == nil then
		if Ped then -- In theory the `Ped` table may not have loaded yet.
			Self.Ped = Ped:new(ped_id)
		end
	else
		Self.Ped.m_Handle = ped_id
		Self.Ped:PopulatePointer()
	end

	local _, char_index = STATS.STAT_GET_INT(MPPLY_LAST_MP_CHAR, 0, 1)
	Self.CharIndex = char_index

	local veh_id
	if PED.IS_PED_IN_ANY_VEHICLE(ped_id, false) then
		veh_id = PED.GET_VEHICLE_PED_IS_IN(ped_id, false)
	else
		veh_id = 0
	end
	Self.VehId = veh_id

	if Self.Veh == nil then
		if Vehicle then -- In theory the `Vehicle` table may not have loaded yet.
			Self.Veh = Vehicle:new(veh_id)
		end
	else
		Self.Veh.m_Handle = veh_id
		Self.Veh:PopulatePointer()
	end

	Self.Pos = ENTITY.GET_ENTITY_COORDS(ped_id, false)
	Self.Rot = ENTITY.GET_ENTITY_ROTATION(ped_id, 2)
end)
