
packet = {}

function packet:new()
	local buf = ffi.new("struct datBitBuffer")
	local data = ffi.new("char[0x400]")
	buf.m_data = data
	buf.m_maxBit = 0x400*8
	o = {
		m_Data = data,
		m_Buffer = buf
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function packet:send(msg_id, reliable)
	local flags = 0
	if reliable then
		flags = bit.bor(flags, 1)
	end

	menu_exports.queue_packet(menu_exports.get_network_player_mgr().m_NetConnectionMgr, msg_id, self.m_Data, bit.rshift(self.m_Buffer.m_curBit + 7, 3), flags, nil)
end

function packet:get_buffer()
	return self.m_Buffer
end

function packet:write_message_header(message)
	local buf = self:get_buffer()
	menu_exports.bitbuffer_WriteQword(buf, 0x3246, 14)
	if message > 0xFF then
		menu_exports.bitbuffer_WriteQword(buf, 1, 1)
		menu_exports.bitbuffer_WriteQword(buf, message, 16)
	else
		menu_exports.bitbuffer_WriteQword(buf, 0, 1)
		menu_exports.bitbuffer_WriteQword(buf, message, 8)
	end
end



