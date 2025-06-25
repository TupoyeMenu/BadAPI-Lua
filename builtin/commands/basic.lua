local ffi = require("ffi")

command.add("lua_openscript", function(player_id, args)
	local file, error = loadfile("BadAPI/scripts/" .. args[2])
	if file then
		file()
		log.info("Loaded: " .. args[2])
	else
		log.warning(tostring(error))
	end
end)
command.add("lua_run", function(player_id, args)
	assert(loadstring(args[2]))()
end)
command.add("lua_eval", function(player_id, args)
	local func, err = loadstring("return " .. args[2])
	if func then
		local res = func()
		log.info(tostring(res))
	elseif err then
		log.fatal(err)
	end
end)

command.add("unload", function(player_id, args)
	event.trigger(menu_event.MenuUnloaded)
	menu_exports.unload()
end)

command.add("print", function(player_id, args)
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
command.add("clear", function(player_id, args)
	log.clear_log_messages()
end)

command.add("help", function(player_id, args)
	if args[2] then
		local commands = command.get_table()
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

command.add("alias", function(player_id, args)
	local alias_name = args[2]
	local aliesed_command = args[3]
	if alias_name and aliesed_command then
		command.add(alias_name, function (player_id, _)
			command.call(player_id, aliesed_command, true)
		end)
	else
		log.warning("Usage: alias <alias_name> <command>")
	end
end)

local messages = log.get_log_messages()
command.add("dump_log_info", function(player_id, args)
	log.info(tostring(#messages))
	log_table(messages)
end)

local spawn_in_vehicle = convar.add("spawn_in_vehicle", "1", "Teleports you into the vehicle that was spawned with `spawn`", {ARCHIVE=true, LOCAL_ONLY=true})

local function spawn_complition(args)
	local vehicle_models = vehicle.get_all_vehicle_models()
	if vehicle_models == nil then return {} end

	local results = {}
	for key, value in ipairs(vehicle_models) do
		if string.startswith(value, args[2]) then
			results[#results+1] = value
		end
	end
	return results
end

command.add("spawn", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local pos = ENTITY.GET_ENTITY_COORDS(player_ped, false) -- FIXME player_ped may not be loaded

		local veh = vehicle.spawn{name=args[2], location=pos, is_networked=true}

		if spawn_in_vehicle and tobool(spawn_in_vehicle.value) and veh then
			PED.SET_PED_INTO_VEHICLE(player_ped, veh, -1)
		end
	end)
end, spawn_complition, "Spawns a vehicle")
command.add("repair", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local veh = PED.GET_VEHICLE_PED_IS_USING(player_ped)
		if not ENTITY.DOES_ENTITY_EXIST(veh) then return end

		if entity.take_control_of(veh) then
			vehicle.fix(veh)
		end
	end)
end, spawn_complition, "Spawns a vehicle")

command.add("upgrade_veh", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local veh = PED.GET_VEHICLE_PED_IS_USING(player_ped)
		if not ENTITY.DOES_ENTITY_EXIST(veh) then return end

		if entity.take_control_of(veh) then
			vehicle.upgrade(veh, tobool(args[2]))
		end
	end)
end)

command.add("downgrade_veh", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local veh = PED.GET_VEHICLE_PED_IS_USING(player_ped)
		if not ENTITY.DOES_ENTITY_EXIST(veh) then return end

		if entity.take_control_of(veh) then
			vehicle.downgrade(veh)
		end
	end)
end)
command.add("delete_veh", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local veh = PED.GET_VEHICLE_PED_IS_USING(player_ped)
		if not ENTITY.DOES_ENTITY_EXIST(veh) then return end

		TASK.CLEAR_PED_TASKS_IMMEDIATELY(player_ped)

		if entity.take_control_of(veh) then
			entity.delete(veh)
		end
	end)
end, nil, "Deletes the vehicle you are currently in")
command.add("delete_all_vehicles", function(player_id, args)
	script.run_in_fiber(function()
		for index, veh in ipairs(entities.get_all_vehicles_as_handles()) do
			if entity.take_control_of(veh) then
				entity.delete(veh)
			end
		end
	end)
end, nil, "Deletes all vehicles on the map.")


command.add("god", function(player_id, args)
	local player_ped = self.get_ped()
	local player_ped_ptr = ffi.cast("struct CPed*", menu_exports.handle_to_ptr(player_ped))
	if player_ped_ptr then
		if player_ped_ptr.m_damage_bits.isInvincible == 0 then
			player_ped_ptr.m_damage_bits.isInvincible = 1
			log.info("God ON")
		else
			player_ped_ptr.m_damage_bits.isInvincible = 0
			log.info("God OFF")
		end
	end
end, nil, "Makes you invincible", {LOCAL_ONLY=true})

command.add("kill", function(player_id, args)
	script.run_in_fiber(function()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		if player_ped == self.get_ped() then
			ENTITY.SET_ENTITY_HEALTH(player_ped, 0, 0, 0)
		end
	end)
end, nil, "Kills you instantly", {LOCAL_ONLY=true})

command.add("toggle_black_screen", function(player_id, args)
	script.run_in_fiber(function()
		if CAM.IS_SCREEN_FADED_OUT() then
			CAM.DO_SCREEN_FADE_IN(0)
		else
			CAM.DO_SCREEN_FADE_OUT(0)
		end
	end)
end, nil, "Blacks out your screen and stops the game from rendering the world", {LOCAL_ONLY=true})
