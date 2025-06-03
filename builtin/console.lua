
local console_open = false

-- Console UI
local lines = {}
local num_messages
local console_text
local command_input = ""
local should_set_focus = false

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
local command_history = {}
local history_index = 0
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

	if data.EventKey == keytab then

	end
end

event.register_handler(menu_event.Draw, "Console", function()
	if not console_open then return end

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
		command_input, result = ImGui.InputTextWithHint("##ConsoleInput", "Command", command_input, 128, bit.bor(ImGuiInputTextFlags.EnterReturnsTrue, ImGuiInputTextFlags.CallbackHistory, ImGuiInputTextFlags.CallbackCompletion), callback_func)
		if(result) then
			command.call(0, command_input)
			command_history[#command_history+1] = command_input
			history_index = #command_history+1
			command_input = ""
			should_set_focus = true
		end
	end
	ImGui.End()
end)

event.register_handler(menu_event.Wndproc, "ConoleHotkey", function (hwnd, msg, wparam, lparam)
	-- Opening is handled in ConsoleInputLock unless we can't tick yet
	if(not menu_exports.script_can_tick() and msg == 0x0101 and wparam == 0xC0) then
		toggle_console()
	end

	if console_open and msg == 0x0101 and wparam == 0x1B then -- Close with ESC
		toggle_console()
	end
end)

script.register_looped("ConsoleInputLock", function (script)
	PAD.DISABLE_CONTROL_ACTION(0, 243, false)
	if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 243) then
		toggle_console()
	end

	if console_open then
		PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
	end
end)
