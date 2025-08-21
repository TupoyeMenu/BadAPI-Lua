
Command.Add("lua_openscript", function(player_id, args)
	local filename = args[2]
	if filename == nil then
		log.warning("Invalid file")
	end

	local file, error = loadfile("BadAPI/scripts/" .. filename)
	if file then
		file()
		log.info("Loaded: " .. filename)
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


---@class LuaConsoleInput: DefaultConsoleInput
LuaConsoleInput = setmetatable(
{
	m_history = {},
	m_suggestions_cache = {},
	m_active_suggestion = 0
},
{
	__index = DefaultConsoleInput
}
)

function LuaConsoleInput:OnInputClassChanged()
	self.m_history = {}
	self.m_suggestions_cache = {}
	self.m_active_suggestion = 0
end

function LuaConsoleInput:OnEnter(text)
	if string.startswith(text, "/exit") then
		Console.ResetInputClass()
		return
	end

	self:AddToHistory(text)

	local func, err = loadstring(text)
	if func then
		local success, err = pcall(func)
		if not success then
			log.fatal(err)
		end
	elseif err then
		log.fatal(err)
	end
end

function LuaConsoleInput:GetSuggestionsInternal(text)
	local args = Command.Parse(text, false)
	local results = {}

	if #args == 1 then
		for name, cmd in pairs(_G) do
			if string.startswith(name, args[1]) then
				results[#results+1] = name
			end
		end
	end

	-- Display history
	if #results == 0 and #args == 0 then
		results = table.reverse(self.m_history)
	end
	return results
end

Command.Add("lua", function (player_id, args)
	log.info("Type: /exit to return to normal input mode.")
	Console.SetInputClass(LuaConsoleInput)
end, nil, "Switch the console into a lua interpreter", {LOCAL_ONLY=true})
