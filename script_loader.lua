
local script_name = ""


hook.add("Draw", "draw_script_loader", function()
	if gui.is_open() then
		if ImGui.Begin("Script loader") then
			local active
			script_name, pressed = ImGui.InputText("Script name", script_name, 128, ImGuiInputTextFlags.EnterReturnsTrue)
			if pressed then
				include(script_name)
			end
			if ImGui.IsItemActive() then
				script.run_in_fiber(function()
					PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
				end)
			end
		end
		ImGui.End()
	end
end)
