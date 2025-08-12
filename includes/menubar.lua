local ffi = require("ffi")

MenuBar = 
{
	---@class GuiWindow
	---@field RenderCallback fun(window: GuiWindow)
	---@field IsOpen fun(window: GuiWindow): boolean
	---@field SetOpen fun(window: GuiWindow, open: boolean)
	---@field Description string?

	---@type table<string, GuiWindow>
	m_windows = {}
}

---@param name string
---@param window GuiWindow
function MenuBar.RegisterWindow(name, window)
	assert(istable(window), "bad argument 'window' for 'MenuBar.RegisterWindow'.\nExpected table got " .. type(window) .. "\nIn:")
	assert(isfunction(window.RenderCallback), "bad argument 'RenderCallback' for 'MenuBar.RegisterWindow'.\nExpected function got " .. type(window.RenderCallback) .. "\nIn:")
	assert(isstring(name), "bad argument 'name' for 'MenuBar.RegisterWindow'.\nExpected string got " .. type(name) .. "\nIn:")
	assert(isfunction(window.IsOpen), "bad argument 'IsOpen' for 'MenuBar.RegisterWindow'.\nExpected function got " .. type(window.IsOpen) .. "\nIn:")
	assert(isfunction(window.SetOpen), "bad argument 'SetOpen' for 'MenuBar.RegisterWindow'.\nExpected function got " .. type(window.SetOpen) .. "\nIn:")

	MenuBar.m_windows[name] = window
end

event.register_handler("Draw", "MenuBar", function ()
	if not Gui.IsOpen() then return end

	if ImGui.BeginMainMenuBar() then
		if ImGui.BeginMenu("File") then
			if ImGui.MenuItem("Unload") then
				Command.Call(Self.Id, "unload", true)
			end
			if ImGui.MenuItem("Rage Quit (hard crash)") then
				os.exit()
			end
			ImGui.EndMenu()
		end

		if ImGui.BeginMenu("Windows") then
			for name, window in pairs(MenuBar.m_windows) do
				local open,_ = ImGui.MenuItem(name, "", window:IsOpen())
				window:SetOpen(open)
			end
			ImGui.EndMenu()
		end

		ImGui.EndMainMenuBar()
	end


	for name, window in pairs(MenuBar.m_windows) do
		if window:IsOpen() then
			pcall(window.RenderCallback, window)
		end
	end
end)
