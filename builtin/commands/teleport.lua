
Command.Add("tp_to_waypoint", function (args, player_id)
	script.run_in_fiber(function ()
		Teleport.ToWaypoint()
	end)
end, nil, "Teleports you to the waypoint", {LOCAL_ONLY=true})
