--Not actually a main file, actually it's more of a test file.


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