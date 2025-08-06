local ffi = require("ffi")

local player_join_msg = ConVar.Add("player_join_msg", "1",
	"Shows a '{} joined.' message above the minimap when a player joines.", { LOCAL_ONLY = true })

event.register_handler("PlayerJoin", "MinimapJoinMessage", function(name, id, net_player)
	net_player = ffi.cast("struct CNetGamePlayer*", net_player)
	local player_handle = net_player.vtable.GetGamerInfo(net_player).m_GamerHandle

	log.info("Player joined '" .. name .. "' allocating slot #" .. tostring(id)
		.. " with Rockstar ID: " .. tostring(player_handle.m_RockstarId))


	if player_join_msg:GetBool() then
		script.run_in_fiber(function()
			Notify.AboveMap("<C>" .. name .. "</C> joined.")
		end)
	end
end)

event.register_handler("PlayerLeave", "LogPlayerLeave", function(name, net_player)
	net_player = ffi.cast("struct CNetGamePlayer*", net_player)
	local player_handle = net_player.vtable.GetGamerInfo(net_player).m_GamerHandle

	log.info("Player left '" ..
	name .. "' freeing slot #" .. net_player.m_PlayerIndex .. " with Rockstar ID: " .. tostring(player_handle.m_RockstarId))
end)
