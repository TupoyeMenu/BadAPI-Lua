
local script_name = ""

---@type GuiWindow
local script_loader_window =
{
	RenderCallback = function (window)
		local open, res = ImGui.Begin("Script loader", true)
		window:SetOpen(open)
		if res then
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
	end,

	is_open = false,
	IsOpen = function (window)
		return window.is_open
	end,
	SetOpen = function (window, open)
		window.is_open = open
	end

}

MenuBar.RegisterWindow("Script Loader", script_loader_window)

