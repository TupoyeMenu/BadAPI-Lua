local type = type
local string_gmatch = string.gmatch
local log_info = log.info
local log_warning = log.warning
local tostring = tostring

--#region Command

---@class Command
---@field m_name string
---@field m_flags command_flags
---@field m_help_text string
---@field m_callback function
---@field m_complition_callback function
Command = {}

local initial_config_loaded = false

---@return table<string, Command>
local commands = {}

---@private
function Command:new(name, callback, complition_callback, help_text, flags)
	assert(isstring(name), "bad argument 'name' for 'Command.Add'.\nExpected string got " .. type(name) .. "\nIn:")
	assert(isfunction(callback), "bad argument 'callback' for 'command.Add'.\nExpected function got " .. type(callback) .. "\nIn:")
	if complition_callback ~= nil then
		assert(isfunction(complition_callback), "bad argument 'complition_callback' for 'Command.Add'.\nExpected function got " .. type(complition_callback) .. "\nIn:")
	end
	if help_text ~= nil then
		assert(isstring(help_text), "bad argument 'help_text' for 'Command.Add'.\nExpected string got " .. type(help_text) .. "\nIn:")
	end
	if flags ~= nil then
		assert(istable(flags), "bad argument 'flags' for 'Command.Add'.\nExpected table got " .. type(flags) .. "\nIn:")
	end

	flags = flags or {}

	local command = {}

	setmetatable(command, self)
	self.__index = self

	command.m_name = name
	command.m_callback = callback
	command.m_complition_callback = complition_callback
	command.m_help_text = help_text
	command.m_flags = flags

	return command
end

---@param name string
---@param callback function Arguments are: (player_id, args)
---@param complition_callback function?
---@param help_text string?
---@param flags command_flags?
---@return Command command
function Command.Add(name, callback, complition_callback, help_text, flags)
	local command = Command:new(name, callback, complition_callback, help_text, flags)

	commands[name] = command

	return commands[name]
end


---@return string
function Command:GetName()
	return self.m_name
end

---@return string
function Command:GetHelpText()
	return self.m_help_text
end

---@return command_flags
function Command:GetFlags()
	return self.m_flags
end



---Turns command_string to command table
---@param command_string string
---@param allow_warnings boolean?
---@return table command_args
function Command.Parse(command_string, allow_warnings)
	-- Pasted from: https://stackoverflow.com/a/28664691
	local args = {}
	local spat, epat = [=[^(['"])]=], [=[(['"])$]=]
	local buf, quoted
	for str in string_gmatch(command_string,"%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then
			args[#args+1] = str:gsub(spat, ""):gsub(epat, "")
		end
	end
	if buf and allow_warnings then
		log_warning("Missing matching quote for "..buf)
	end

	return args
end

---@param player_id number Player that called this command
---@param cmd string The command as a string
---@param hide_input? boolean Don't show that we ran the command in the console. Default: false
---@return boolean success
function Command.Call(player_id, cmd, hide_input)
	assert(isnumber(player_id), "bad argument 'player_id' for 'Command.Call'.\nExpected number got " .. type(player_id) .. "\nIn:")
	assert(isstring(cmd), "bad argument 'command' for 'Command.Call'.\nExpected string got " .. type(cmd) .. "\nIn:")

	if not hide_input then
		log_info("> " .. cmd)
	end

	local args = Command.Parse(cmd, true)
	local name = args[1]
	if name then
		if commands[name] then
			commands[name].m_callback(player_id, args)
			return true
		end
		log_warning("Command: " .. tostring(name) .. " not found")
	end
	return false
end

---@return table<string, Command>
function Command.GetTable()
	return commands
end


local function LoadConfig(filename)
	local cfg_file = io.open(filename, "r")
	if cfg_file == nil then return end

	for line in cfg_file:lines() do
		if not string.startswith(line, "//") and not string.startswith(line, "#") then
			Command.Call(Self.Id, line)
		end
	end

	cfg_file:close()
end

event.register_handler(menu_event.LuaInitFinished, "LoadCommands", function()
	LoadConfig("convars.cfg")
	LoadConfig("autoexec.cfg")

	initial_config_loaded = true
end)

--#endregion Command

--#region ConVar

---@class command_flags
---@field ARCHIVE? boolean Should save the value
---@field LOCAL_ONLY? boolean Only the local player can run this command
---@field SP_ONLY? boolean This command can only be used in SP
---@field MP_ONLY? boolean This command can only be used in MP
local default_convar_flags =
{
	ARCHIVE = true,
	LOCAL_ONLY = true,
	SP_ONLY = false,
	MP_ONLY = false
}

---@class ConVar: Command
---@field m_name string
---@field m_value string
---@field m_default_value string
---@field m_flags command_flags
---@field m_help_text string
---@field m_callback function internal
ConVar = {}

setmetatable(ConVar, Command)

local last_save_time = 0
local function SaveConvars()
	local cvar_file = "# This file is automatically generated\n"
	for key, value in pairs(commands) do
		if value.m_flags.ARCHIVE then
			cvar_file = cvar_file .. key .. " \"" .. value.m_value .. "\"\n"
		end
	end

	local cfg_file = io.open("convars.cfg", "w")
	if cfg_file then
		cfg_file:write(cvar_file)
		last_save_time = os.time()
		cfg_file:close()
	end
end

local function ConVarCallback(player_id, args)
	local convar_name = args[1]

	local command = commands[convar_name]

	if args[2] == nil then
		log_info(command.m_value)
		return
	end

	if command.m_change_callback then
		command.m_change_callback(args)
	end

	command.m_value = args[2]

	-- Don't save if we have already saved in the last 5 seconds
	if initial_config_loaded and os.time() - last_save_time > 5 then
		SaveConvars()
	end
end

---@private
function ConVar:new(name, default_value, help_text, flags, change_callback)
	assert(isstring(name), "bad argument 'name' for 'ConVar.Add'.\nExpected string got " .. type(name) .. "\nIn:")
	assert(isstring(default_value), "bad argument 'default_value' for 'ConVar.Add'.\nExpected string got " .. type(default_value) .. "\nIn:")
	if help_text ~= nil then
		assert(isstring(help_text), "bad argument 'help_text' for 'ConVar.Add'.\nExpected string got " .. type(help_text) .. "\nIn:")
	end
	if flags ~= nil then
		assert(istable(flags), "bad argument 'flags' for 'ConVar.Add'.\nExpected table got " .. type(flags) .. "\nIn:")
	end
	if change_callback ~= nil then
		assert(isfunction(change_callback), "bad argument 'change_callback' for 'ConVar.Add'.\nExpected function got " .. type(change_callback) .. "\nIn:")
	end

	flags = flags or default_convar_flags

	local convar = {}

	setmetatable(convar, self)
	self.__index = self

	convar.m_callback = ConVarCallback
	convar.m_change_callback = change_callback
	convar.m_name = name
	convar.m_help_text = help_text
	convar.m_flags = flags
	convar.m_value = default_value
	convar.m_default_value = default_value

	return convar
end

---@return string
function ConVar:GetDefault()
	return self.m_default_value
end

---Reverts the ConVar to it's default value.
function ConVar:Revert()
	self.m_value = self.m_default_value
end

---@return boolean
function ConVar:GetBool()
	return tobool(self.m_value)
end

---@param value boolean
function ConVar:SetBool(value)
	self.m_value = value and "1" or "0"
end

---@return number
function ConVar:GetNumber()
	return tonumber(self.m_value) or 0
end

---@param value number
function ConVar:SetNumber(value)
	self.m_value = tostring(value)
end

---@return string
function ConVar:GetString()
	return self.m_value
end

---@param value string
function ConVar:SetString(value)
	self.m_value = value
end

---@param name string
---@param default_value string
---@param help_text string?
---@param flags command_flags?
---@param change_callback fun(args: table<integer, string>)? This will not be called when the value is modified through `SetBool`, `SetNumber`, `SetString`.
---@return ConVar convar
function ConVar.Add(name, default_value, help_text, flags, change_callback)
	local convar = ConVar:new(name, default_value, help_text, flags, change_callback)

	commands[name] = convar
	return commands[name]
end

--#endregion ConVar
