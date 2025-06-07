
local console_open = false

-- Console UI
local lines = {}
local num_messages
local console_text
local command_buffer = ""
local should_set_focus = false
local command_history = {}
local history_index = 0

---@param text string
---@param missing_only boolean? Results will only contain the part of the string that is missing
---@return table
local function get_suggestions(text, missing_only)
	local command_table = command.get_table()
	local args = command.parse(text, false)
	local results = {}
	local has_complitions = false

	if #args == 1 then
		for key, value in pairs(command_table) do
			if string.startswith(key, args[1]) then
				results[#results+1] = key
			end
		end
	elseif #args > 1 then
		local command = command_table[args[1]]
		if command and command.complition_callback then
			results = command.complition_callback(args)
			has_complitions = true
		end
	end

	-- Display history
	if #results == 0 and #args == 0 then
		results = command_history
	end

	if missing_only and #results > 0 and #args > 0 then
		local new_results = {}
		for index, value in ipairs(results) do
			new_results[index] = string.sub(value, #args[#args]+1)
		end
		results = new_results
	end
	return results
end

local function add_to_history(text)
	local already_in_history = false
	for index, value in ipairs(command_history) do
		if value == text then
			already_in_history = true
			break
		end
	end
	if not already_in_history then
		command_history[#command_history+1] = text
		history_index = #command_history+1
	end
end

local function draw_suggestions()
	--[[
	if command_buffer == "" then
		ImGui.CloseCurrentPopup()
		return
	end
	]]
	local suggestions = get_suggestions(command_buffer)
	for key, value in ipairs(suggestions) do
		ImGui.Selectable(value, false)
	end
end

function toggle_console()
	console_open = not console_open
	if console_open then
		should_set_focus = true
		if not gui.is_open() then
			gui.override_mouse(true)
		end
	else
		if gui.mouse_override() then
			gui.override_mouse(false)
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
	if data.EventKey == keyup and #command_history and history_index > 1 then
		history_index = history_index - 1
		data:DeleteChars(0, data.BufTextLen)
		data:InsertChars(0, command_history[history_index])
	end
	if data.EventKey == keydown and #command_history and history_index <= #command_history then
		history_index = history_index + 1
		data:DeleteChars(0, data.BufTextLen)
		data:InsertChars(0, command_history[history_index])
	end

	if data.EventKey == keytab and data.Buf then
		local suggestions = get_suggestions(data.Buf, true)
		if #suggestions == 1 then
			data:InsertChars(data.BufTextLen, suggestions[1])
		end
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
		--ImGui.InputTextMultiline("##ConsoleLog", console_text, #console_text, -1, log_height, ImGuiInputTextFlags.ReadOnly)
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
		command_buffer, result = ImGui.InputTextWithHint("##ConsoleInput", "Command", command_buffer, 128, bit.bor(ImGuiInputTextFlags.EnterReturnsTrue, ImGuiInputTextFlags.CallbackHistory, ImGuiInputTextFlags.CallbackCompletion), callback_func)
		if(result) then
			if #command_buffer > 0 then -- Don't insert empty strings to history
				add_to_history(command_buffer)
			end
			command.call(self.get_id(), command_buffer)
			command_buffer = ""
			should_set_focus = true
		end

		local input_text_active = ImGui.IsItemActive()
		if input_text_active then
			ImGui.OpenPopup("##autocomplete")
		end

		local x,_ = ImGui.GetItemRectMin()
		local _,y = ImGui.GetItemRectMax()
		ImGui.SetNextWindowPos(x,y)
		if ImGui.BeginPopup("##autocomplete", bit.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoMove, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoDocking, ImGuiWindowFlags.ChildWindow)) then
			draw_suggestions()
			ImGui.EndPopup()
		end
	end
	ImGui.End()
end)


local console_hotkey = VK_OEM_3
event.register_handler(menu_event.Wndproc, "ConoleHotkey", function (hwnd, msg, wparam, lparam)
	-- Opening is handled in ConsoleInputLock unless we can't tick yet
	if(msg == WM_KEYDOWN and wparam == console_hotkey) then
		toggle_console()
	end

	if console_open and msg == WM_KEYDOWN and wparam == VK_ESCAPE then -- Close with ESC
		toggle_console()
	end
end)

script.register_looped("ConsoleInputLock", function (script)
	local actions = control.get_actions_using_this_key(console_hotkey)
	for _, value in ipairs(actions) do
		PAD.DISABLE_CONTROL_ACTION(0, value, false)
	end

	if console_open then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end
end)

command.add("clear_history", function (player_id, args)
	command_history = {}
	history_index = 0
end, nil, "Clears the command history", {LOCAL_ONLY=true})
