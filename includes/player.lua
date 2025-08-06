
local players = {}

---@class player
Player = {}

---Creates a new player object
---@param p integer|ffi.cdata* Pointer to CNetGamePlayer or player index
---@return player?
function Player:new(p)
	local o = {}
	local net_player
	if type(p) == "number" and p <= 32 then
		net_player = Player.GetNetPlayerFromPid(p)
	elseif type(p) == "cdata" then
		net_player = p
	else
		PrintStacktrace("bad argument 'p' for 'player:new'.\nExpected number or cdata got " .. type(p) .. "\nIn:")
		return nil
	end

	o.m_handle = net_player

	setmetatable(o, self)
	self.__index = self
	return o
end

---Gets CNetGamePlayer* from player id
---@param pid number player_id
---@return ffi.cdata*?
function Player.GetNetPlayerFromPid(pid)
	return players[pid]
end

---Gets player from message id
---@param id number
---@return player?
function Player.GetByMessageId(id)
	for _, ply in pairs(players) do
		if ply and ply.m_MessageId == id then
			return Player:new(ply)
		end
	end
	return nil
end

---@return integer player_id -1 if not found
function Player:GetId()
	for index, ply in pairs(players) do
		if ply == self.m_handle then
			return index
		end
	end
	return -1
end

event.register_handler("PlayerJoin", "MaintainPlayerListJoin", function (name, index, net_player)
	players[index] = ffi.cast("struct CNetGamePlayer*", net_player)
end)
event.register_handler("PlayerLeave", "MaintainPlayerListLeave", function (name, net_player)
	net_player = ffi.cast("struct CNetGamePlayer*", net_player)
	for key, value in pairs(players) do
		if value == net_player then
			value = nil
		end
	end
end)
