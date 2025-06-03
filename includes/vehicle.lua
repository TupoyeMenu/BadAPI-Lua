local ffi = require("ffi")
local STREAMING = STREAMING
local ENTITY = ENTITY
local VEHICLE = VEHICLE

vehicle = {}
spawned_vehicles = {}

---@param veh number vehicle index
---@param is_stolen boolean
function vehicle.set_mp_bitset(veh, is_stolen)
	DECORATOR.DECOR_SET_INT(veh, "MPBitset", 0)
	local net_id = NETWORK.VEH_TO_NET(veh)
	spawned_vehicles[#spawned_vehicles+1] = net_id
	if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(veh) then
		NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
	end
	VEHICLE.SET_VEHICLE_IS_STOLEN(veh, is_stolen)
end

---Spawns a vehicle
---@param args table
---@return integer|nil vehicle_handle
function vehicle.spawn(args)
	if isstring(args.name) then
		args.hash = joaat(args.name)
	end

	if args.location == nil or not isnumber(args.location.x) or not isnumber(args.location.y) or not isnumber(args.location.z) then
		args.location = vec3:new(args.x, args.y, args.z)
	end

	if not entity.request_model(args.hash) then
		return
	end

	if args.is_networked and not network.is_session_started() then
		args.is_networked = false
	end

	if args.is_stolen == nil then
		args.is_stolen = false
	end

	local veh = VEHICLE.CREATE_VEHICLE(args.hash, args.location.x, args.location.y, args.location.z, args.heading, args.is_networked, args.is_script_veh, false)

	if args.no_longer_needed == true or args.no_longer_needed == nil then
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(args.hash)
	end

	if args.is_networked then
		vehicle.set_mp_bitset(veh, args.is_stolen)
	end

	return veh
end

MOD_SPOILERS = 0
MOD_FRONTBUMPER = 1
MOD_REARBUMPER = 2
MOD_SIDESKIRT = 3
MOD_EXHAUST = 4
MOD_FRAME = 5
MOD_GRILLE = 6
MOD_HOOD = 7
MOD_FENDER = 8
MOD_RIGHTFENDER = 9
MOD_ROOF = 10
MOD_ENGINE = 11
MOD_BRAKES = 12
MOD_TRANSMISSION = 13
MOD_HORNS = 14
MOD_SUSPENSION = 15
MOD_ARMOR = 16
MOD_NITROUS = 17
MOD_TURBO = 18
MOD_SUBWOOFER = 19
MOD_TYRE_SMOKE = 20
MOD_HYDRAULICS = 21
MOD_XENON_LIGHTS = 22
MOD_FRONTWHEEL = 23
MOD_REARWHEEL = 24
MOD_PLATEHOLDER = 25
MOD_VANITYPLATES = 26
MOD_TRIMDESIGN = 27
MOD_ORNAMENTS = 28
MOD_DASHBOARD = 29
MOD_DIALDESIGN = 30
MOD_DOORSPEAKERS = 31
MOD_SEATS = 32
MOD_STEERINGWHEELS = 33
MOD_COLUMNSHIFTERLEVERS = 34
MOD_PLAQUES = 35
MOD_SPEAKERS = 36
MOD_TRUNK = 37
MOD_HYDRO = 38
MOD_ENGINEBLOCK = 39
MOD_AIRFILTER = 40
MOD_STRUTS = 41
MOD_ARCHCOVER = 42
MOD_AERIALS = 43
MOD_TRIM = 44
MOD_TANK = 45
MOD_WINDOWS = 46
MOD_DOORS = 47
MOD_LIVERY = 48
MOD_LIGHTBAR = 49

---Upgrades the vehicle to max
---@param veh number
---@param performance_only boolean
function vehicle.upgrade(veh, performance_only)
	VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
	if performance_only then
		local perfomance_mods = {MOD_ENGINE, MOD_BRAKES, MOD_TRANSMISSION, MOD_SUSPENSION, MOD_ARMOR, MOD_NITROUS, MOD_TURBO}

		for _, mod_slot in ipairs(perfomance_mods) do
			if mod_slot ~= MOD_NITROUS and mod_slot ~= MOD_TURBO then
				VEHICLE.SET_VEHICLE_MOD(veh, mod_slot, VEHICLE.GET_NUM_VEHICLE_MODS(veh, mod_slot) - 1, true)
			else
				VEHICLE.TOGGLE_VEHICLE_MOD(veh, mod_slot, true)
			end
		end
	else
		VEHICLE.TOGGLE_VEHICLE_MOD(veh, MOD_TURBO, true);
		VEHICLE.TOGGLE_VEHICLE_MOD(veh, MOD_TYRE_SMOKE, true);
		VEHICLE.TOGGLE_VEHICLE_MOD(veh, MOD_XENON_LIGHTS, true);
		VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 1);
		VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false);

		for slot = MOD_SPOILERS, MOD_LIGHTBAR, MOD_SPOILERS do
			if slot == MOD_LIVERY then
				goto continue
			end
			local count = VEHICLE.GET_NUM_VEHICLE_MODS(veh, slot)
			if count > 0 then
				local selected_mod = -1
				for mod = count-1, -1, count-1 do
					if VEHICLE.IS_VEHICLE_MOD_GEN9_EXCLUSIVE(veh, slot, mod) and not menu_exports.is_enhanced() then
						goto continue
					end

					selected_mod = mod
					::continue::
				end

				if selected_mod ~= -1 then
					VEHICLE.SET_VEHICLE_MOD(veh, slot, selected_mod, true)
				end
			end
			::continue::
		end
	end
end

---Removes all upgrades from the vehicle
---@param veh number
function vehicle.downgrade(veh)
	VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0);
	for i = 0, 50, 0 do
		VEHICLE.REMOVE_VEHICLE_MOD(veh, i)
	end
end

function vehicle.fix(veh)
	VEHICLE.SET_VEHICLE_FIXED(veh)
	VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0)
	local veh_ptr = ffi.cast("struct CVehicle*", menu_exports.handle_to_ptr(veh))
	if veh_ptr then -- Fix water damage
		veh_ptr.m_DynamicFlags.unk0 = 0
		veh_ptr.m_DynamicFlags.unk1 = 0
		veh_ptr.m_DynamicFlags.unk2 = 0
	end
end

local vehicles_table
event.register_handler(menu_event.LuaInitFinished, "LoadVehiclesJson", function()
	local vehicles_file = io.open("vehicles.json", "r")
	local vehicles_json
	if vehicles_file then
		vehicles_json = vehicles_file:read("*a")
		vehicles_file:close()
		vehicles_table = json.decode(vehicles_json)
	else
		log.fatal("vehicles.json not found")
	end
end)

local is_dlc_present
if menu_exports.is_enhanced() then
	is_dlc_present = ffi.cast("bool(*)(uint32_t dlcHash)", menu_exports.scan_pattern("81 F9 E6 2E F0 96", "") - 5)
else
	is_dlc_present = ffi.cast("bool(*)(uint32_t dlcHash)", menu_exports.scan_pattern("81 F9 6D 9F 11 0B", "") - 10)
end


---@param include_missing_vehicles boolean?
---@return table?
function vehicle.get_data_for_all_vehicles(include_missing_vehicles)
	if vehicles_table == nil then return end
	local result_table = {}
	for key, value in ipairs(vehicles_table) do
		if (include_missing_vehicles or value.DlcName == "TitleUpdate" or is_dlc_present(menu_exports.joaat(value.DlcName))) then
			result_table[#result_table+1] = value
		end
	end
	return result_table
end

---@param include_missing_vehicles boolean?
---@return table?
function vehicle.get_all_vehicle_models(include_missing_vehicles)
	local all_vehicles = vehicle.get_data_for_all_vehicles(include_missing_vehicles)
	if all_vehicles == nil then return end

	local result_table = {}
	for key, value in ipairs(all_vehicles) do
		result_table[#result_table+1] = value.Name
	end

	return result_table
end