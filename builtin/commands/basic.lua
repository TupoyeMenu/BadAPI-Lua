command.add("lua_openscript", function(player_id, args)
	dofile(args[2])
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

local messages = log.get_log_messages()
command.add("dump_log_info", function(player_id, args)
	log.info(tostring(#messages))
	log_table(messages)
end)

local spawn_in_vehicle = convar.add("spawn_in_vehicle", "1", "Teleports you into the vehicle that was spawned with `spawn`", {ARCHIVE=true, LOCAL_ONLY=true})

command.add("spawn", function(player_id, args)
	script.run_in_fiber(function ()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local pos = ENTITY.GET_ENTITY_COORDS(player_ped, false) -- FIXME player_ped may not be loaded

		local veh = vehicle.spawn{name=args[2], location=pos, is_networked=true}

		if spawn_in_vehicle and tobool(spawn_in_vehicle.value) and veh then
			PED.SET_PED_INTO_VEHICLE(player_ped, veh, -1)
		end
	end)
end)

command.add("upgrade_veh", function(player_id, args)
	script.run_in_fiber(function ()
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player_id)
		if not ENTITY.DOES_ENTITY_EXIST(player_ped) then return end

		local veh = PED.GET_VEHICLE_PED_IS_USING(player_ped)
		if not ENTITY.DOES_ENTITY_EXIST(veh) then return end

		if entity.take_control_of(veh) then
			vehicle.upgrade(veh, tonumber(args[2]))
		end
	end)
end)

command.add("downgrade_veh", function(player_id, args)
	script.run_in_fiber(function ()
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
	script.run_in_fiber(function ()
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

