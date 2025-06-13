--Not actually a main file, actually it's more of a test file.

local ffi = require("ffi")

event.register_handler("ReceiveNetMessage", "ReceiveNetMessageTest", function (a1, net_cxn_mgr, event_ptr, msgType, buffer)
	buffer = ffi.cast("struct datBitBuffer*", buffer)
	local fr_event = ffi.cast("struct netEventFrameReceived*", event_ptr)
	if msgType == 0x24 then
		local msg = ffi.new("char[256]")
		menu_exports.bitbuffer_ReadString(buffer, msg, 256)
		log.warning(ffi.string(msg, 256))
		return true
	end
	if msgType == 0x4F then

		local ply = player.get_by_message_id(fr_event.m_MsgId)
		if ply == nil then
			return
		end

		local count = buffer:Read("uint32_t", 5)
		local buffer_size = buffer:Read("uint32_t", 15)

		if buffer_size > 7296 then
			buffer_size = 7296
		end

		local remaining = buffer_size
		while remaining >= 39 do
			local bits_read = buffer.m_bitsRead

			local event_id = buffer:Read("uint16_t", 7);
			local event_index  = buffer:Read("uint32_t", 9);
			local event_handled_bits = buffer:Read("uint32_t", 8);
			local event_data_size = buffer:Read("uint32_t", 15);

			if buffer:Read("bool", 1) == true then
				buffer:Read("uint32_t", 16)
				log.debug("Extra read")
			end

			local event_data = ffi.new("char[4096 + 1]")
			if (event_data_size) then
				menu_exports.bitbuffer_ReadArray(buffer, event_data, event_data_size)
			end

			local event_buffer = ffi.new("struct datBitBuffer")
			event_buffer.m_data = event_data
			event_buffer.m_flagBits = 1
			event_buffer.m_maxBit = event_data_size + 1;

			event.trigger("ReceiveNetGameEvent", ply, event_id, event_index, event_handled_bits, event_buffer)

			remaining = remaining - ffi.cast("int", buffer.m_bitsRead) - bits_read;
		end
	end
end)


command.add("status", function (player_id, args)
	local mgr = menu_exports.get_network_player_mgr()
	if mgr == nil then return end

	script.run_in_fiber(function ()
		log.info("PlayerID	PlayerName	Ping	Loss	RID	GOD")

		for i = 0, 31, 1 do
			local player = mgr.m_Players[i]
			if player ~= nil then
				local player_handle = player.vtable.GetGamerInfo(player).m_GamerHandle
				local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i)
				log.info(tostring(i) .. "	" .. ffi.string(player.vtable.GetName(player)) .. "	" .. NETWORK.NETWORK_GET_AVERAGE_PING(i) .. "	" .. NETWORK.NETWORK_GET_AVERAGE_PACKET_LOSS(i) .. "	" .. tostring(player_handle.m_RockstarId) .. "	" .. (ENTITY.GET_ENTITY_CAN_BE_DAMAGED(player_ped) and "OFF" or "ON"))
			end
		end
	end)
end)

command.add("msg", function (player_id, args)
	if args[2] == nil then return end

	log.info(args[2])
	local guid_str = "a88961c7-b4c8-4a16-a648-ac2d8c9300db"

	local pkt = packet:new()
	pkt:write_message_header(0x24) -- TextMessage
	local buf = pkt:get_buffer()
	menu_exports.bitbuffer_WriteString(buf, args[2], 256)
	menu_exports.bitbuffer_WriteString(buf, guid_str, 40)

	local player = menu_exports.get_network_player_mgr().m_LocalPlayer
	-- TODO: Move this
	local player_handle = player.vtable.GetGamerInfo(player).m_GamerHandle
	buf:Write(player_handle.m_Platform, 8)
	menu_exports.bitbuffer_WriteInt64(buf, player_handle.m_RockstarId, 64)
	buf:Write(player_handle.m_ProfileIndex, 8)
	-- END Move this
	buf:Write(0, 1) -- is team

	local mgr = menu_exports.get_network_player_mgr()
	for i = 0, 31, 1 do
		local player = mgr.m_Players[i]
		if player ~= nil and player.vtable.IsPhysical(player) then
			log.debug("sending to " .. ffi.string(player.vtable.GetName(player)))
			pkt:send(player.m_MessageId, true)
		end
	end
end, nil, nil, {LOCAL_ONLY=true})

local log_damage_events = convar.add("log_damage_events", "0", nil, {LOCAL_ONLY=true})

event.register_handler("ReceiveNetGameEvent", "ReceiveNetGameEventTest", function (ply, event_id, event_index, event_handled_bits, event_buffer)
	if tobool(log_damage_events.value) and event_id == 6 then
		log.debug("Weapon damage event triggered")
	end
end)


--[[
local ffi = require("ffi")

local action = 0
event.register_handler(menu_event.Draw, "main", function ()
	if not gui.is_open() then return end

	if ImGui.Begin("test") then
		action, _ = ImGui.InputInt("action", action)
		local action_ptr = control.action_to_ptr(action)
		if action_ptr ~= nil then
			ImGui.Text("m_unk = " .. tostring(action_ptr.m_Unk))
			ImGui.Text("m_Value = " .. tostring(action_ptr.m_Value))
			ImGui.Text("m_Value2 = " .. tostring(action_ptr.m_Value2))
			ImGui.Text("m_unk2 = " .. tostring(action_ptr.m_Unk2))
			ImGui.Text("m_InputMethod = " .. tostring(action_ptr.m_Input.m_InputMethod))
			ImGui.Text("m_Key = " .. tostring(action_ptr.m_Input.m_Key))
			ImGui.Text("N00000054 = " .. tostring(action_ptr.N00000054))
			ImGui.Text("N00000087 = " .. tostring(action_ptr.N00000087))
			ImGui.Text("N0000008A = " .. tostring(action_ptr.N0000008A))
			ImGui.Text("N00000056 = " .. tostring(action_ptr.N00000056))
		else
			ImGui.Text("action_ptr == nil")
		end

		ImGui.Separator()

		local input_ptr = control.get_input_from_action(action)
		if input_ptr ~= nil then
			ImGui.Text("m_InputMethod: " .. tostring(input_ptr.m_InputMethod))
			ImGui.Text("m_Key: " .. tostring(input_ptr.m_Key))
			ImGui.Text("m_Unk: " .. tostring(input_ptr.m_Unk))
		else
			ImGui.Text("input_ptr == nil")
		end

	end
	ImGui.End()
end)

]]