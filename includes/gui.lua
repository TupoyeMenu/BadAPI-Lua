
_GUI_FONTS = _GUI_FONTS or {}

Gui =
{
	m_is_open = false,
	m_override_mouse = false,
	m_fonts = _GUI_FONTS,
}

local cursor_coords = vec2.zero()

Command.Add("toggle_gui", function ()
	Gui.Toggle(not Gui.m_is_open)
end, nil, "Toggles the GUI", {LOCAL_ONLY=true})

function Gui.IsOpen()
	return Gui.m_is_open
end

function Gui.Toggle(toggle)
	Gui.m_is_open = toggle
	Gui.UpdateMouseVisability()
end

---Forces the mouse to draw and disable camera controls of the game
---This function works for now but might start causing issues when more features start relying on it.
function Gui.OverrideMouse(toggle)
	Gui.m_override_mouse = toggle
	Gui.UpdateMouseVisability()
end

function Gui.MouseOverride()
	return Gui.m_override_mouse
end

function Gui.UpdateMouseVisability()
	if not Gui.m_is_open and not Gui.m_override_mouse then
		local x,y = ImGui.GetMousePos()
		cursor_coords.x = x
		cursor_coords.y = y
	elseif cursor_coords.x + cursor_coords.y ~= 0 then
		ImGui.TeleportMousePos(cursor_coords.x, cursor_coords.y)
	end

	local io = ImGui.GetIO()
	if Gui.m_is_open or Gui.m_override_mouse then
		io.MouseDrawCursor = true
		io.ConfigFlags = bit.band(io.ConfigFlags, bit.bnot(ImGuiConfigFlags.NoMouse))
	else
		io.MouseDrawCursor = false
		io.ConfigFlags = bit.bor(io.ConfigFlags, ImGuiConfigFlags.NoMouse)
	end
end

function Gui.SetDefaultStyle()
	local style = ImGui.GetStyle()

	style.WindowPadding.x          = 10
	style.WindowPadding.y          = 10
	style.PopupRounding            = 0
	style.FramePadding.x           = 8
	style.FramePadding.y           = 4
	style.ItemSpacing.x            = 10
	style.ItemSpacing.y            = 8
	style.ItemInnerSpacing.x       = 6
	style.ItemInnerSpacing.y       = 6
	style.TouchExtraPadding.x      = 0
	style.TouchExtraPadding.y      = 0
	style.IndentSpacing            = 21
	style.ScrollbarSize            = 15
	style.GrabMinSize              = 8
	style.WindowBorderSize         = 1
	style.ChildBorderSize          = 0
	style.PopupBorderSize          = 1
	style.FrameBorderSize          = 0
	style.TabBorderSize            = 0
	style.WindowRounding           = 0
	style.ChildRounding            = 0
	style.FrameRounding            = 0
	style.ScrollbarRounding        = 0
	style.GrabRounding             = 0
	style.TabRounding              = 0
	style.WindowTitleAlign.x       = 0.5
	style.WindowTitleAlign.y       = 0.5
	style.ButtonTextAlign.x        = 0.5
	style.ButtonTextAlign.y        = 0.5
	style.DisplaySafeAreaPadding.x = 3
	style.DisplaySafeAreaPadding.y = 3

	local colors = style.Colors

	colors[ImGuiCol.Text]                  = ImVec4:new(1.00, 1.00, 1.00, 1.00);
	colors[ImGuiCol.TextDisabled]          = ImVec4:new(1.00, 0.90, 0.19, 1.00);
	colors[ImGuiCol.WindowBg]              = ImVec4:new(0.06, 0.06, 0.06, 1.00);
	colors[ImGuiCol.ChildBg]               = ImVec4:new(0.00, 0.00, 0.00, 0.00);
	colors[ImGuiCol.PopupBg]               = ImVec4:new(0.08, 0.08, 0.08, 0.94);
	colors[ImGuiCol.Border]                = ImVec4:new(0.30, 0.30, 0.30, 0.50);
	colors[ImGuiCol.BorderShadow]          = ImVec4:new(0.00, 0.00, 0.00, 0.00);
	colors[ImGuiCol.FrameBg]               = ImVec4:new(0.21, 0.21, 0.21, 0.54);
	colors[ImGuiCol.FrameBgHovered]        = ImVec4:new(0.21, 0.21, 0.21, 0.78);
	colors[ImGuiCol.FrameBgActive]         = ImVec4:new(0.28, 0.27, 0.27, 0.54);
	colors[ImGuiCol.TitleBg]               = ImVec4:new(0.17, 0.17, 0.17, 1.00);
	colors[ImGuiCol.TitleBgActive]         = ImVec4:new(0.19, 0.19, 0.19, 1.00);
	colors[ImGuiCol.TitleBgCollapsed]      = ImVec4:new(0.00, 0.00, 0.00, 0.51);
	colors[ImGuiCol.MenuBarBg]             = ImVec4:new(0.14, 0.14, 0.14, 1.00);
	colors[ImGuiCol.ScrollbarBg]           = ImVec4:new(0.02, 0.02, 0.02, 0.53);
	colors[ImGuiCol.ScrollbarGrab]         = ImVec4:new(0.31, 0.31, 0.31, 1.00);
	colors[ImGuiCol.ScrollbarGrabHovered]  = ImVec4:new(0.41, 0.41, 0.41, 1.00);
	colors[ImGuiCol.ScrollbarGrabActive]   = ImVec4:new(0.51, 0.51, 0.51, 1.00);
	colors[ImGuiCol.CheckMark]             = ImVec4:new(1.00, 1.00, 1.00, 1.00);
	colors[ImGuiCol.SliderGrab]            = ImVec4:new(0.34, 0.34, 0.34, 1.00);
	colors[ImGuiCol.SliderGrabActive]      = ImVec4:new(0.39, 0.38, 0.38, 1.00);
	colors[ImGuiCol.Button]                = ImVec4:new(0.41, 0.41, 0.41, 0.74);
	colors[ImGuiCol.ButtonHovered]         = ImVec4:new(0.41, 0.41, 0.41, 0.78);
	colors[ImGuiCol.ButtonActive]          = ImVec4:new(0.41, 0.41, 0.41, 0.87);
	colors[ImGuiCol.Header]                = ImVec4:new(0.37, 0.37, 0.37, 0.31);
	colors[ImGuiCol.HeaderHovered]         = ImVec4:new(0.38, 0.38, 0.38, 0.37);
	colors[ImGuiCol.HeaderActive]          = ImVec4:new(0.37, 0.37, 0.37, 0.51);
	colors[ImGuiCol.Separator]             = ImVec4:new(0.38, 0.38, 0.38, 0.50);
	colors[ImGuiCol.SeparatorHovered]      = ImVec4:new(0.46, 0.46, 0.46, 0.50);
	colors[ImGuiCol.SeparatorActive]       = ImVec4:new(0.46, 0.46, 0.46, 0.64);
	colors[ImGuiCol.ResizeGrip]            = ImVec4:new(0.26, 0.26, 0.26, 1.00);
	colors[ImGuiCol.ResizeGripHovered]     = ImVec4:new(0.31, 0.31, 0.31, 1.00);
	colors[ImGuiCol.ResizeGripActive]      = ImVec4:new(0.35, 0.35, 0.35, 1.00);
	colors[ImGuiCol.Tab]                   = ImVec4:new(0.21, 0.21, 0.21, 0.86);
	colors[ImGuiCol.TabHovered]            = ImVec4:new(0.27, 0.27, 0.27, 0.86);
	colors[ImGuiCol.TabSelected]           = ImVec4:new(0.34, 0.34, 0.34, 0.86);
	colors[ImGuiCol.TabDimmed]             = ImVec4:new(0.10, 0.10, 0.10, 0.97);
	colors[ImGuiCol.TabDimmedSelected]     = ImVec4:new(0.15, 0.15, 0.15, 1.00);
	colors[ImGuiCol.PlotLines]             = ImVec4:new(0.61, 0.61, 0.61, 1.00);
	colors[ImGuiCol.PlotLinesHovered]      = ImVec4:new(1.00, 0.43, 0.35, 1.00);
	colors[ImGuiCol.PlotHistogram]         = ImVec4:new(0.90, 0.70, 0.00, 1.00);
	colors[ImGuiCol.PlotHistogramHovered]  = ImVec4:new(1.00, 0.60, 0.00, 1.00);
	colors[ImGuiCol.TextSelectedBg]        = ImVec4:new(0.26, 0.59, 0.98, 0.35);
	colors[ImGuiCol.DragDropTarget]        = ImVec4:new(1.00, 1.00, 0.00, 0.90);
	colors[ImGuiCol.NavCursor]             = ImVec4:new(0.26, 0.59, 0.98, 1.00);
	colors[ImGuiCol.NavWindowingHighlight] = ImVec4:new(1.00, 1.00, 1.00, 0.70);
	colors[ImGuiCol.NavWindowingDimBg]     = ImVec4:new(0.80, 0.80, 0.80, 0.20);
	colors[ImGuiCol.ModalWindowDimBg]      = ImVec4:new(0.80, 0.80, 0.80, 0.35);
end

function Gui.Init()
	Gui.SetDefaultStyle()

	local io = ImGui.GetIO()
	local cfg = ImFontConfig:new()

	_GUI_FONTS["Default"] = io.Fonts:AddFontDefault(cfg)
end

Gui.Init()

event.register_handler("EarlyDraw", "MaintainInternalGui", function ()
	ImGui.DockSpaceOverViewport(0, nil, ImGuiDockNodeFlags.PassthruCentralNode)
end)

script.register_looped("GUIInputBlocker", function ()
	if Gui.m_is_open or Gui.m_override_mouse then
		for i = 0, 6 do
			PAD.DISABLE_CONTROL_ACTION(2, i, true)
		end
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_DRIVE_LOOK, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_DRIVE_LOOK2, true)

		PAD.DISABLE_CONTROL_ACTION(2, INPUT_WEAPON_WHEEL_NEXT, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_WEAPON_WHEEL_PREV, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_SELECT_NEXT_WEAPON, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_SELECT_PREV_WEAPON, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_ATTACK, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_ATTACK2, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_ATTACK, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_ATTACK2, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_RADIO_WHEEL, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_PREV_RADIO_TRACK, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_SELECT_NEXT_WEAPON, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_PASSENGER_ATTACK, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_SELECT_PREV_WEAPON, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_FLY_ATTACK, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_FLY_ATTACK2, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_FLY_ATTACK_CAMERA, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_VEH_FLY_SELECT_NEXT_WEAPON, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_MELEE_ATTACK_ALTERNATE, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_CURSOR_SCROLL_UP, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_PREV_WEAPON, true)
		PAD.DISABLE_CONTROL_ACTION(2, INPUT_NEXT_WEAPON, true)
	end
end)
