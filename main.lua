--[[
local lines = {}
local num_messages

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

event.register_handler(menu_event.Draw, "ConsoleTest", function()
	if(ImGui.Begin("Console2", ImGuiWindowFlags.NoScrollbar)) then
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

		ImGui.BeginChild("##logs", 0, 0, 0, ImGuiWindowFlags.NoMove)
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

		ImGui.EndChild()
	end
	ImGui.End()
end)

--]]