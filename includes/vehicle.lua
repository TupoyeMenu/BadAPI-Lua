local ffi = require("ffi")

---@class Vehicle: Entity
Vehicle = Entity:new()
SpawnedVehicles = {}

local real_new = Vehicle.new

---Creates a vehicle object for an existing vehicle.
---@param p integer|ffi.cdata*|nil Pointer to CVehicle or entity index, nil is only allowed for inheritance.
---@return Vehicle
function Vehicle:new(p)
	return real_new(self, p)
end

---@param is_stolen boolean Should set vehicle as stolen.
function Vehicle:SetMPBitset(is_stolen)
	DECORATOR.DECOR_SET_INT(self.m_Handle, "MPBitset", 0)
	local net_id = NETWORK.VEH_TO_NET(self.m_Handle)
	SpawnedVehicles[#SpawnedVehicles+1] = net_id
	if NETWORK.NETWORK_GET_ENTITY_IS_NETWORKED(self.m_Handle) then
		NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(net_id, true)
	end
	VEHICLE.SET_VEHICLE_IS_STOLEN(self.m_Handle, is_stolen)
end

---@class VehicleSpawn
---@field name string? Model name, either this or `hash` has to be set.
---@field hash integer? Model hash, either this or `name` has to be set.
---@field location vec3? Spawn position, either this or `x`, `y`, `z` has to be set.
---@field x number? Spawn position, either this or `location` has to be set.
---@field y number? Spawn position, either this or `location` has to be set.
---@field z number? Spawn position, either this or `location` has to be set.
---@field is_networked boolean?
---@field is_stolen boolean?
---@field is_script_ent boolean?
---@field heading number?
---@field no_longer_needed boolean? Set the **model** as no longer needed.

---Spawns a vehicle
---@param args VehicleSpawn
---@return Vehicle|nil vehicle_handle
function Vehicle.Spawn(args)
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

	if args.is_stolen == nil then
		args.is_stolen = false
	end

	local veh_handle = VEHICLE.CREATE_VEHICLE(args.hash, args.location.x, args.location.y, args.location.z, args.heading, args.is_networked, args.is_script_ent, false)
	local veh = Vehicle:new(veh_handle)
	if not veh:IsValid() then return nil end

	if args.no_longer_needed == true or args.no_longer_needed == nil then
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(args.hash)
	end

	if args.is_networked then
		veh:SetMPBitset(args.is_stolen)
	end

	veh:SetPosition(args.location)

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

HORN_STOCK = -1
HORN_TRUCK = 0
HORN_POLICE = 1
HORN_CLOWN = 2
HORN_MUSICAL1 = 3
HORN_MUSICAL2 = 4
HORN_MUSICAL3 = 5
HORN_MUSICAL4 = 6
HORN_MUSICAL5 = 7
HORN_SADTROMBONE = 8
HORN_CALSSICAL1 = 9
HORN_CALSSICAL2 = 10
HORN_CALSSICAL3 = 11
HORN_CALSSICAL4 = 12
HORN_CALSSICAL5 = 13
HORN_CALSSICAL6 = 14
HORN_CALSSICAL7 = 15
HORN_SCALEDO = 16
HORN_SCALERE = 17
HORN_SCALEMI = 18
HORN_SCALEFA = 19
HORN_SCALESOL = 20
HORN_SCALELA = 21
HORN_SCALETI = 22
HORN_SCALEDO_HIGH = 23
HORN_JAZZ1 = 24
HORN_JAZZ2 = 25
HORN_JAZZ3 = 26
HORN_JAZZLOOP = 27
HORN_STARSPANGBAN1 = 28
HORN_STARSPANGBAN2 = 29
HORN_STARSPANGBAN3 = 30
HORN_STARSPANGBAN4 = 31
HORN_CLASSICALLOOP1 = 32
HORN_CLASSICAL8 = 33
HORN_CLASSICALLOOP = 34

VehicleClassNames = {
	"Compact",
	"Sedan",
	"SUV",
	"Coupe",
	"Muscle",
	"Sport Classic",
	"Sport",
	"Super",
	"Motorcycle",
	"Off-road",
	"Industrial",
	"Utility",
	"Van",
	"Cycle",
	"Boat",
	"Helicopter",
	"Plane",
	"Service",
	"Emergency",
	"Military",
	"Commercial",
	"Rail",
	"Open Wheel"
}

---Upgrades the vehicle to max
---@param performance_only boolean
function Vehicle:Upgrade(performance_only)
	local veh = self.m_Handle
	VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
	if not performance_only then
		VEHICLE.TOGGLE_VEHICLE_MOD(veh, MOD_TURBO, true);
		VEHICLE.TOGGLE_VEHICLE_MOD(veh, MOD_TYRE_SMOKE, true);
		VEHICLE.TOGGLE_VEHICLE_MOD(veh, MOD_XENON_LIGHTS, true);
		VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 1);
		VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false);

		for slot = MOD_SPOILERS, MOD_LIGHTBAR do
			if slot == MOD_LIVERY then
				goto continue
			end
			local count = VEHICLE.GET_NUM_VEHICLE_MODS(veh, slot)
			if count > 0 then
				local selected_mod = -1
				for mod = count-1, -1, -1 do
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

	local perfomance_mods = {MOD_ENGINE, MOD_BRAKES, MOD_TRANSMISSION, MOD_SUSPENSION, MOD_ARMOR, MOD_NITROUS, MOD_TURBO}
	for _, mod_slot in ipairs(perfomance_mods) do
		if mod_slot ~= MOD_NITROUS and mod_slot ~= MOD_TURBO then
			VEHICLE.SET_VEHICLE_MOD(veh, mod_slot, VEHICLE.GET_NUM_VEHICLE_MODS(veh, mod_slot) - 1, true)
		else
			VEHICLE.TOGGLE_VEHICLE_MOD(veh, mod_slot, true)
		end
	end
end

---Removes all upgrades from the vehicle
function Vehicle:Downgrade()
	VEHICLE.SET_VEHICLE_MOD_KIT(self.m_Handle, 0);
	for i = 0, 50-1 do
		VEHICLE.REMOVE_VEHICLE_MOD(self.m_Handle, i)
	end
end

function Vehicle:Fix()
	VEHICLE.SET_VEHICLE_FIXED(self.m_Handle)
	VEHICLE.SET_VEHICLE_DIRT_LEVEL(self.m_Handle, 0)
	local veh_ptr = ffi.cast("struct CVehicle*", self.m_Pointer)
	if veh_ptr then -- Fix water damage
		veh_ptr.m_DynamicFlags.m_Unk0 = 0
		veh_ptr.m_DynamicFlags.m_Unk1 = 0
		veh_ptr.m_DynamicFlags.m_Unk2 = 0
	end
end

---@return integer
function Vehicle:GetGear()
	return VEHICLE.GET_VEHICLE_CURRENT_DRIVE_GEAR_(self.m_Handle)
end

---@return number
function Vehicle:GetRevRatio()
	return VEHICLE.GET_VEHICLE_CURRENT_REV_RATIO_(self.m_Handle)
end

---@return number
function Vehicle:GetMaxSpeed()
	return VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(self.m_Handle)
end

---@param text string Number plate text, must be 8 or less characters long.
function Vehicle:SetPlateText(text)
	if #text > 8 then
		return
	end

	VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(self.m_Handle, text)
end

---@param seat integer
---@return boolean
function Vehicle:IsSeatFree(seat)
	return VEHICLE.IS_VEHICLE_SEAT_FREE(self.m_Handle, seat, true)
end

---@return boolean
function Vehicle:SupportsBoost()
	return VEHICLE.GET_HAS_ROCKET_BOOST(self.m_Handle)
end

---@return boolean
function Vehicle:IsBoostActive()
	return VEHICLE.IS_ROCKET_BOOST_ACTIVE(self.m_Handle)
end


---@param percentage number
function Vehicle:SetBoostCharge(percentage)
	if not self:SupportsBoost() then
		return
	end

	VEHICLE.SET_ROCKET_BOOST_FILL(self.m_Handle, percentage)
end

---@param lower boolean
function Vehicle:LowerStance(lower)
	VEHICLE.SET_REDUCED_SUSPENSION_FORCE(self.m_Handle, lower)
end

---@return number
function Vehicle:GetBodyHealth()
	return VEHICLE.GET_VEHICLE_BODY_HEALTH(self.m_Handle)
end

---@param value number
function Vehicle:SetBodyHealth(value)
	VEHICLE.SET_VEHICLE_BODY_HEALTH(self.m_Handle, value)
end

---@return number
function Vehicle:GetPetrolTankHealth()
	return VEHICLE.GET_VEHICLE_PETROL_TANK_HEALTH(self.m_Handle)
end

---@param value number
function Vehicle:SetPetrolTankHealth(value)
	VEHICLE.SET_VEHICLE_PETROL_TANK_HEALTH(self.m_Handle, value)
end

---@return number
function Vehicle:GetEngineHealth()
	return VEHICLE.GET_VEHICLE_ENGINE_HEALTH(self.m_Handle)
end

---@param value number
function Vehicle:SetEngineHealth(value)
	VEHICLE.SET_VEHICLE_ENGINE_HEALTH(self.m_Handle, value)
end

---@param value number
function Vehicle:SetPlaneEngineHealth(value)
	VEHICLE.SET_PLANE_ENGINE_HEALTH(self.m_Handle, value)
end

---@return boolean
function Vehicle:GetVehicleHasLangingGear()
	return VEHICLE.GET_VEHICLE_HAS_LANDING_GEAR(self.m_Handle)
end

---@return integer state
function Vehicle:GetLangingGearState()
	return VEHICLE.GET_LANDING_GEAR_STATE(self.m_Handle)
end

---@param state integer
function Vehicle:SetLangingGearState(state)
	VEHICLE.CONTROL_LANDING_GEAR(self.m_Handle, state)
end

function Vehicle:GetDisplayName()
	return VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(self:GetModel())
end

function Vehicle.GetFullNameFromModel(model)
	if not STREAMING.IS_MODEL_VALID(model) then
		return "Invalid model"
	end

	local gxt = VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(model)
	local display = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(gxt)

	local final_name = display == "NULL" and gxt or display

	local maker = HUD.GET_FILENAME_FOR_AUDIO_CONVERSATION(VEHICLE.GET_MAKE_NAME_FROM_VEHICLE_MODEL(model))
	if maker ~= "NULL" then
		final_name = maker .. " " .. final_name
	end

	local id = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(model)
	final_name = VehicleClassNames[id+1] .. " " .. final_name

	return final_name
end

function Vehicle:GetFullName()
	return Vehicle.GetFullNameFromModel(self:GetModel())
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
function Vehicle.GetDataForAllVehicles(include_missing_vehicles)
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
function Vehicle.GetAllVehicleModels(include_missing_vehicles)
	local all_vehicles = Vehicle.GetDataForAllVehicles(include_missing_vehicles)
	if all_vehicles == nil then return end

	local result_table = {}
	for key, value in ipairs(all_vehicles) do
		result_table[#result_table+1] = value.Name
	end

	return result_table
end