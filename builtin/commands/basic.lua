local ffi = require("ffi")

Command.Add("lua_openscript", function(player_id, args)
	local file, error = loadfile("BadAPI/scripts/" .. args[2])
	if file then
		file()
		log.info("Loaded: " .. args[2])
	else
		log.warning(tostring(error))
	end
end)
Command.Add("lua_run", function(player_id, args)
	assert(loadstring(args[2]))()
end)
Command.Add("lua_eval", function(player_id, args)
	local func, err = loadstring("return " .. args[2])
	if func then
		local res = func()
		log.info(tostring(res))
	elseif err then
		log.fatal(err)
	end
end)

Command.Add("unload", function(player_id, args)
	event.trigger(menu_event.MenuUnloaded)
	menu_exports.unload()
end)

Command.Add("print", function(player_id, args)
	local string_to_print = ""
	for i = 2, #args do
		if(i == 2) then
			string_to_print = args[i]
		else
			string_to_print = string_to_print .. "	" .. args[i]
		end
	end

	log.info(string_to_print)
end)
Command.Add("clear", function(player_id, args)
	log.clear_log_messages()
end)

Command.Add("help", function(player_id, args)
	if args[2] then
		local commands = Command.GetTable()
		local command = commands[args[2]]
		if command then
			log.info(tostring(command.help_text))
		else
			log.warning("Command " .. tostring(args[2]) .. " not found")
		end
	else
		log.warning("Usage: help <command_name>")
	end
end)

Command.Add("alias", function(player_id, args)
	local alias_name = args[2]
	local aliesed_command = args[3]
	if alias_name and aliesed_command then
		Command.Add(alias_name, function (player_id, _)
			Command.Call(player_id, aliesed_command, true)
		end)
	else
		log.warning("Usage: alias <alias_name> <command>")
	end
end)

local messages = log.get_log_messages()
Command.Add("dump_log_info", function(player_id, args)
	log.info(tostring(#messages))
	LogTable(messages)
end)

local spawn_in_vehicle = ConVar.Add("spawn_in_vehicle", "1", "Teleports you into the vehicle that was spawned with `spawn`", {ARCHIVE=true, LOCAL_ONLY=true})

local function spawn_complition(args)
	local vehicle_models = Vehicle.GetAllVehicleModels()
	if vehicle_models == nil then return {} end

	local results = {}
	for key, value in ipairs(vehicle_models) do
		if string.startswith(value, args[2]) then
			results[#results+1] = value
		end
	end
	return results
end

Command.Add("spawn", function(player_id, args)
	script.run_in_fiber(function()
		local ped_handle = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		local ped = Ped:new(ped_handle)
		if not ped:IsValid() then return end

		local veh = Vehicle.Spawn{name=args[2], location=ped:GetPosition(), is_networked=true}

		if spawn_in_vehicle and tobool(spawn_in_vehicle.value) and veh then
			ped:SetIntoVehicle(veh, -1)
		end
	end)
end, spawn_complition, "Spawns a vehicle")
Command.Add("repair", function(player_id, args)
	script.run_in_fiber(function()
		local ped_handle = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		local ped = Ped:new(ped_handle)
		if not ped:IsValid() then return end

		local veh = ped:GetVehicle()
		if veh == nil then return end

		if veh:TakeControlOf() then
			veh:Fix()
		end
	end)
end, spawn_complition, "Spawns a vehicle")

Command.Add("upgrade_veh", function(player_id, args)
	script.run_in_fiber(function()
		local ped_handle = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		local ped = Ped:new(ped_handle)
		if not ped:IsValid() then return end

		local veh = ped:GetVehicle()
		if veh == nil then return end

		if veh:TakeControlOf() then
			veh:Upgrade(tobool(args[2]))
		end
	end)
end)

Command.Add("downgrade_veh", function(player_id, args)
	script.run_in_fiber(function()
		local ped_handle = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		local ped = Ped:new(ped_handle)
		if not ped:IsValid() then return end

		local veh = ped:GetVehicle()
		if veh == nil then return end

		if veh:TakeControlOf() then
			veh:Downgrade()
		end
	end)
end)
Command.Add("delete_veh", function(player_id, args)
	script.run_in_fiber(function()
		local ped_handle = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		local ped = Ped:new(ped_handle)
		if not ped:IsValid() then return end

		local veh = ped:GetVehicle()
		if veh == nil then return end

		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped_handle)
		
		if veh:TakeControlOf() then
			veh:Delete()
		end
	end)
end, nil, "Deletes the vehicle you are currently in")
Command.Add("delete_all_vehicles", function(player_id, args)
	script.run_in_fiber(function()
		for index, veh_handle in ipairs(entities.get_all_vehicles_as_handles()) do
			local veh = Vehicle:new(veh_handle)
			if veh:TakeControlOf() then
				veh:Delete()
			end
		end
	end)
end, nil, "Deletes all vehicles on the map.")


Command.Add("god", function(player_id, args)
	local player_ped_handle = self.get_ped()
	local ped = Ped:new(player_ped_handle)
	if ped:IsValid() then
		if not ped:IsInvincible() then
			ped:SetInvincible(true)
			log.info("God ON")
		else
			ped:SetInvincible(false)
			log.info("God OFF")
		end
	end
end, nil, "Makes you invincible", {LOCAL_ONLY=true})

Command.Add("kill", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		if player_ped == self.get_ped() then
			ENTITY.SET_ENTITY_HEALTH(player_ped, 0, 0, 0)
		end
	end)
end, nil, "Kills you instantly", {LOCAL_ONLY=true})

Command.Add("toggle_black_screen", function(player_id, args)
	script.run_in_fiber(function()
		if CAM.IS_SCREEN_FADED_OUT() then
			CAM.DO_SCREEN_FADE_IN(0)
		else
			CAM.DO_SCREEN_FADE_OUT(0)
		end
	end)
end, nil, "Blacks out your screen and stops the game from rendering the world", {LOCAL_ONLY=true})
