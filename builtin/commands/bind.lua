
-- Source engine compatible key names
key_name_to_wndproc =
{
	["f1"] = VK_F1,
	["f2"] = VK_F2,
	["f3"] = VK_F3,
	["f4"] = VK_F4,
	["f5"] = VK_F5,
	["f6"] = VK_F6,
	["f7"] = VK_F7,
	["f8"] = VK_F8,
	["f9"] = VK_F9,
	["f10"] = VK_F10,
	["f11"] = VK_F11,
	["f12"] = VK_F12,
	["f13"] = VK_F13,
	["f14"] = VK_F14,
	["f15"] = VK_F15,
	["f16"] = VK_F16,
	["f17"] = VK_F17,
	["f18"] = VK_F18,
	["f19"] = VK_F19,
	["f20"] = VK_F20,
	["f21"] = VK_F21,
	["f22"] = VK_F22,
	["f23"] = VK_F23,
	["f24"] = VK_F24,

	["escape"] = VK_ESCAPE,
	["tab"] = VK_TAB,
	["capslock"] = VK_CAPITAL,
	["shift"] = VK_LSHIFT,
	["rshift"] = VK_RSHIFT,
	["ctrl"] = VK_LCONTROL,
	["rctrl"] = VK_RCONTROL,
	["alt"] = VK_LMENU,
	["ralt"] = VK_RMENU,
	["space"] = VK_SPACE,
	["backspace"] = VK_BACK,
	["enter"] = VK_RETURN,
	["semicolon"] = VK_OEM_1, -- Is this correct?
	["lwin"] = VK_LWIN,
	["rwin"] = VK_RWIN,
	["apps"] = 0, -- What the hell are you?
	["numlock"] = VK_NUMLOCK,
	["scrolllock"] = VK_SCROLL,

	["uparrow"] = VK_UP,
	["downarrow"] = VK_DOWN,
	["leftarrow"] = VK_LEFT,
	["rightarrow"] = VK_RIGHT,
	["ins"] = VK_INSERT,
	["del"] = VK_DELETE,
	["pgdn"] = VK_PRIOR,
	["pgup"] = VK_NEXT,
	["home"] = VK_HOME,
	["end"] = VK_END,
	["pause"] = VK_PAUSE,

	["kp_end"] = VK_NUMPAD1,
	["kp_downarrow"] = VK_NUMPAD2,
	["kp_pgdn"] = VK_NUMPAD3,
	["kp_leftarrow"] = VK_NUMPAD4,
	["kp_5"] = VK_NUMPAD5,
	["kp_rightarrow"] = VK_NUMPAD6,
	["kp_home"] = VK_NUMPAD7,
	["kp_uparrow"] = VK_NUMPAD8,
	["kp_pgup"] = VK_NUMPAD9,
	["kp_enter"] = VK_PA1,
	["kp_ins"] = VK_NUMPAD0,
	["kp_del"] = VK_OEM_PERIOD, -- Is there a VK_ for this?
	["kp_slash"] = VK_OEM_2, -- Is there a VK_ for this?
	["kp_multiply"] = 0, -- Is there a VK_ for this?
	["kp_minus"] = VK_OEM_MINUS, -- Is there a VK_ for this?
	["kp_plus"] = VK_OEM_PLUS, -- Is there a VK_ for this?

	-- mwheeldown -- Need to handle this separatly
	-- mwheelup -- Need to handle this separatly
	["mouse1"] = VK_LBUTTON,
	["mouse2"] = VK_RBUTTON,
	["mouse3"] = VK_MBUTTON,
	["mouse4"] = VK_XBUTTON1,
	["mouse5"] = VK_XBUTTON2,
}

bind = {}
local bind_table = {}

command.add("bind", function(player_id, args)
	local key_name = args[2]
	local command = args[3]
	if key_name and command then
		local wndproc_key = key_name_to_wndproc[key_name]
		if wndproc_key == nil and #key_name == 1 then
			wndproc_key = string.byte(string.upper(key_name))
		end
		local up_command
		if string.startswith(command, "+") then
			up_command = "-" .. string.sub(command, 2)
		end
		bind_table[#bind_table+1] = {key=wndproc_key, down_command=command, up_command=up_command}
	else
		log.warning("Usage: bind <key> <command>")
	end
end, nil, nil, {LOCAL_ONLY=true}) --TODO Add ARCHIVE

function bind.get_table()
	return bind_table
end

event.register_handler(menu_event.Wndproc, "BindWndprocHook", function (hwnd, msg, wparam, lparam)
	if msg == WM_KEYDOWN then
		for index, value in ipairs(bind_table) do
			if value.key == wparam then
				command.call(self.get_id(), value.down_command, true)
			end
		end
	elseif msg == WM_KEYUP then
		for index, value in ipairs(bind_table) do
			if value.key == wparam and value.up_command then
				command.call(self.get_id(), value.up_command, true)
			end
		end
	end
end)
