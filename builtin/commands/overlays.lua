
local cl_showpos = ConVar.Add("cl_showpos", "0")
local cl_showfps = ConVar.Add("cl_showfps", "0")
local TEXT_COLOR = ImGui.GetColorU32(1,1,1,1)

local function draw_showpos()
	local pos = Self.Pos
	local ang = Self.Rot
	local pos_text = string.format("pos: %.02f %.02f %.02f", pos.x, pos.y, pos.z)
	local ang_text = string.format("ang: %.02f %.02f %.02f", ang.x, ang.y, ang.z)

	local res_x = menu_exports.get_screen_resolution_x()
	local res_y = menu_exports.get_screen_resolution_y()
	local dl = ImGui.GetBackgroundDrawList()

	local pos_w, pos_h = ImGui.CalcTextSize(pos_text)
	local ang_w, ang_h = ImGui.CalcTextSize(ang_text)
	ImGui.ImDrawListAddText(dl, res_x-pos_w, pos_h, TEXT_COLOR, pos_text)
	ImGui.ImDrawListAddText(dl, res_x-ang_w, pos_h*2, TEXT_COLOR, ang_text)
end

local function draw_showfps()
	local io = ImGui.GetIO()
	local text = string.format("%3i fps %.1f ms", io.Framerate, 1000 / io.Framerate)

	local res_x = menu_exports.get_screen_resolution_x()
	local res_y = menu_exports.get_screen_resolution_y()
	local dl = ImGui.GetBackgroundDrawList()

	local w, h = ImGui.CalcTextSize(text)
	ImGui.ImDrawListAddText(dl, res_x-w, 0, TEXT_COLOR, text)
end

event.register_handler("Draw", "draw_cl_overlays", function ()
	-- Push monospace font
	ImGui.PushFont(Gui.m_fonts["Default"], 0)

	if cl_showpos:GetBool() then
		draw_showpos()
	end

	if cl_showfps:GetBool() then
		draw_showfps()
	end

	ImGui.PopFont()
end)
