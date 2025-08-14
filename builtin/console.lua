
local console_open = false

-- Console UI
local lines = {}
local num_messages
local command_buffer = ""
local should_set_focus = false
local history_index = 0


--#region DefaultConsoleInput

---@class ConsoleInput
---@field GetSuggestions fun(self, text, missing_only): table<integer, string>
---@field OnEnter fun(input)
---@field OnInputChanged fun(input)
---@field GetHistory fun(): table<integer, string>
---@field AddToHistory fun(text)
---@field GetCurrentSuggestion fun(): string? Returns the suggestion string, or nil if there is no current selection.
---@field SetCurrentSuggestion fun(index) Sets the current suggestion by index from `GetSuggestions`.
---@field NextSuggestion fun()
---@field PrevSuggestion fun()

---@class DefaultConsoleInput: ConsoleInput
---@field m_history table<integer, string>
---@field m_suggestions_cache table<integer, string>
---@field m_active_suggestion integer Index to the `m_suggestions_cache` array.
DefaultConsoleInput =
{
	m_history = {},
	m_suggestions_cache = {},
	m_active_suggestion = 0
}

---Returns the suggestions the console window will display.
---@param text string
---@return table<integer, string>
function DefaultConsoleInput:GetSuggestionsInternal(text)
	local command_table = Command.GetTable()
	local args = Command.Parse(text, false)
	local results = {}

	if #args == 1 then
		for name, cmd in pairs(command_table) do
			if string.startswith(name, args[1]) then
				results[#results+1] = name
			end
		end
	elseif #args > 1 then
		local command = command_table[args[1]]
		if command and command.m_complition_callback then
			results = command.m_complition_callback(args)
		end
	end

	-- Display history
	if #results == 0 and #args == 0 then
		results = table.reverse(self.m_history)
	end
	return results
end

function DefaultConsoleInput:GetSuggestions(text)
	return self.m_suggestions_cache
end

---Runs when you press enter in the console window.
---@param input string Text that was in the input box when enter was pressed.
function DefaultConsoleInput:OnEnter(input)
	if #input > 0 then -- Don't insert empty strings to history
		self:AddToHistory(input)
	end
	Command.Call(Self.Id, input)
end

function DefaultConsoleInput:OnInputChanged(input)
	self.m_suggestions_cache = self:GetSuggestionsInternal(input)
end


function DefaultConsoleInput:GetHistory()
	return self.m_history
end

function DefaultConsoleInput:AddToHistory(text)
	for index, value in ipairs(self.m_history) do
		if value == text then
			already_in_history = true
			table.remove(self.m_history,index) -- Move value to the end
			self.m_history[#self.m_history+1] = value
			return
		end
	end

	self.m_history[#self.m_history+1] = text
end

function DefaultConsoleInput:NextSuggestion()
	self.m_active_suggestion = math.clamp(self.m_active_suggestion+1, 1, #self.m_suggestions_cache)
end

function DefaultConsoleInput:PrevSuggestion()
	self.m_active_suggestion = math.clamp(self.m_active_suggestion-1, 1, #self.m_suggestions_cache)
end

function DefaultConsoleInput:GetCurrentSuggestion()
	return self.m_suggestions_cache[self.m_active_suggestion]
end

function DefaultConsoleInput:SetCurrentSuggestion(index)
	assert(self.m_suggestions_cache[index], "The index you privided is out of bounds")

	self.m_active_suggestion = index
end

local current_input = DefaultConsoleInput

--#endregion DefaultConsoleInput


local function draw_suggestions()
	local input_text_active = ImGui.IsItemActive()
	if not input_text_active then return end

	local suggestions = current_input:GetSuggestions(command_buffer)
	if #suggestions == 0 then return end

	ImGui.OpenPopup("##autocomplete")

	local x,_ = ImGui.GetItemRectMin()
	local _,y = ImGui.GetItemRectMax()
	ImGui.SetNextWindowPos(x,y)
	ImGui.SetNextWindowSizeConstraints(0,0, 300, 400)

	if ImGui.BeginPopup("##autocomplete", bit.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.ChildWindow)) then
		local current_suggestion = current_input:GetCurrentSuggestion()
		for key, suggestion in ipairs(suggestions) do
			local selected = suggestion == current_suggestion
			ImGui.Selectable(suggestion, selected)
			if selected then
				ImGui.SetScrollHereY()
			end
		end
		ImGui.EndPopup()
	end
end

function toggle_console()
	console_open = not console_open
	if console_open then
		should_set_focus = true
		if not Gui.IsOpen() then
			Gui.OverrideMouse(true)
		end
	else
		if Gui.MouseOverride() then
			Gui.OverrideMouse(false)
		end
	end
end

local function get_line_at_idx(idx)
	local msg = lines[idx+1][1]
	return msg
end
local function get_num_lines()
	return #lines
end
local text_select = text_select:new(get_line_at_idx, get_num_lines, false)

local function set_color_from_level(level)
	if level == 0 then -- VERBOSE
		ImGui.PushStyleColor(ImGuiCol.Text, 0.72, 0.72, 1.0, 1.0)
	elseif level == 1 then -- INFO
		ImGui.PushStyleColor(ImGuiCol.Text, 1, 1.0, 1.0, 1.0)
	elseif level == 2 then -- WARNING
		ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.56, 0.0, 1.0)
	elseif level == 3 then -- FATAL
		ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.0, 0.0, 1.0)
	end
end


local keyup = 515
local keydown = 516
local keytab = 512

---@param data ImGuiInputTextCallbackData
local function callback_func(data)
	if data.EventKey == keyup then
		current_input:PrevSuggestion()
	end
	if data.EventKey == keydown then
		current_input:NextSuggestion()
	end

	if data.EventKey == keytab and data.Buf then
		local suggestions = current_input:GetSuggestions(data.Buf)
		local suggestion = #suggestions == 1 and suggestions[1] or current_input:GetCurrentSuggestion()
		if suggestion == nil then return 0 end

		local args = Command.Parse(data.Buf, false)

		local missing
		if #args > 0 then
			missing = string.sub(suggestion, #args[#args]+1)
		else -- Special case, when we only have whitespace in the input box.
			data:DeleteChars(0, data.BufTextLen)
			missing = suggestion
		end
		data:InsertChars(data.BufTextLen, missing)
		current_input:OnInputChanged(data.Buf)
	end

	if data.EventFlag == ImGuiInputTextFlags.CallbackEdit then
		current_input:OnInputChanged(data.Buf)
	end

	return 0
end


event.register_handler(menu_event.Draw, "Console", function()
	if not console_open then return end

	local x = menu_exports.get_screen_resolution_x() * 0.4
	local y = menu_exports.get_screen_resolution_y() * 0.6
	ImGui.SetNextWindowSize(x,y, ImGuiCond.FirstUseEver)
	if(ImGui.Begin("Console", ImGuiWindowFlags.NoScrollbar)) then
		local messages = log.get_log_messages()
		if num_messages ~= #messages then
			num_messages = #messages
			for i = 0, #lines do
				lines[i] = nil
			end
			for index, value in ipairs(messages) do
				local msg = value:Message()
				for line in msg:gmatch("([^\n]*)\n?") do
					lines[#lines+1] = {line, value:Level()}
				end
				lines[#lines] = nil
			end
		end

		local width, height = ImGui.GetContentRegionAvail()
		local log_height = height - ImGui.GetFrameHeightWithSpacing()
		ImGui.BeginChild("##logs", width, log_height, ImGuiChildFlags.FrameStyle, ImGuiWindowFlags.NoMove)
		for index, value in ipairs(lines) do
			set_color_from_level(value[2])
			ImGui.Text(value[1])
			ImGui.PopStyleColor()
		end

		text_select:update()

		if ImGui.BeginPopupContextWindow() then
			ImGui.BeginDisabled(not text_select:hasSelection())
			if ImGui.MenuItem("Copy", "Ctrl+C") then
				text_select:copy()
			end
			ImGui.EndDisabled()

			if ImGui.MenuItem("Select all", "Ctrl+A") then
				text_select:selectAll()
			end

			ImGui.EndPopup()
		end

		if ImGui.GetScrollY() == ImGui.GetScrollMaxY() then
			ImGui.SetScrollHereY(1)
		end

		ImGui.EndChild()

		ImGui.SetNextItemWidth(-1)
		if should_set_focus then
			should_set_focus = false
			ImGui.SetKeyboardFocusHere()
		end
		local result
		command_buffer, result = ImGui.InputTextWithHint("##ConsoleInput", "Command", command_buffer, 1024, bit.bor(ImGuiInputTextFlags.EnterReturnsTrue, ImGuiInputTextFlags.CallbackHistory, ImGuiInputTextFlags.CallbackCompletion, ImGuiInputTextFlags.CallbackEdit), callback_func)
		if(result) then
			current_input:OnEnter(command_buffer)
			history_index = #current_input:GetHistory() + 1
			command_buffer = ""
			should_set_focus = true
			current_input:OnInputChanged(command_buffer)
		end

		draw_suggestions()
	end
	ImGui.End()
end)

--The pause menu really hates anything that uses escape, block it for 10 frames after we closed
local function block_pause_menu()
	script.run_in_fiber(function (script)
		for i = 1, 10, 1 do
			PAD.DISABLE_CONTROL_ACTION(0, INPUT_FRONTEND_PAUSE, false)
			PAD.DISABLE_CONTROL_ACTION(0, INPUT_FRONTEND_PAUSE_ALTERNATE, false)
			script:yield()
		end
	end)
end

local console_hotkey = VK_OEM_3
event.register_handler(menu_event.Wndproc, "ConoleHotkey", function (hwnd, msg, wparam, lparam)
	-- Opening is handled in ConsoleInputLock unless we can't tick yet
	if(msg == WM_KEYDOWN and wparam == console_hotkey) then
		toggle_console()
	end

	if console_open and msg == WM_KEYDOWN and wparam == VK_ESCAPE then -- Close with ESC
		block_pause_menu()
		toggle_console()
	end
end)

script.register_looped("ConsoleInputLock", function (script)
	local actions = Control.GetActionsUsingThisKey(console_hotkey)
	for _, value in ipairs(actions) do
		PAD.DISABLE_CONTROL_ACTION(0, value, false)
	end

	if console_open then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end
end)

Command.Add("clear_history", function (player_id, args)
	log.warning("FIXME: Not implemented!")
	history_index = 0
end, nil, "Clears the command history", {LOCAL_ONLY=true})
