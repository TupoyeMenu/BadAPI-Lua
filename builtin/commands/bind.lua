
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
	["shift"] = VK_SHIFT,
	["rshift"] = VK_SHIFT,
	["ctrl"] = VK_CONTROL,
	["rctrl"] = VK_CONTROL,
	["alt"] = VK_MENU,
	["ralt"] = VK_MENU,
	["space"] = VK_SPACE,
	["backspace"] = VK_BACK,
	["enter"] = VK_RETURN,
	["semicolon"] = VK_OEM_1,
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

	--FIXME Almost everything here is completely wrong, we can't get these keys through wndproc.
	["kp_end"] = VK_NUMPAD1,
	["kp_downarrow"] = VK_NUMPAD2,
	["kp_pgdn"] = VK_NUMPAD3,
	["kp_leftarrow"] = VK_NUMPAD4,
	["kp_5"] = VK_NUMPAD5,
	["kp_rightarrow"] = VK_NUMPAD6,
	["kp_home"] = VK_NUMPAD7,
	["kp_uparrow"] = VK_NUMPAD8,
	["kp_pgup"] = VK_NUMPAD9,
	["kp_enter"] = VK_RETURN,
	["kp_ins"] = VK_INSERT,
	["kp_del"] = VK_OEM_PERIOD, -- Is there a VK_ for this?
	["kp_slash"] = VK_DIVIDE, -- Is there a VK_ for this?
	["kp_multiply"] = VK_MULTIPLY, -- Is there a VK_ for this?
	["kp_minus"] = VK_SUBTRACT, -- Is there a VK_ for this?
	["kp_plus"] = VK_ADD, -- Is there a VK_ for this?

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
		local wndproc_keys = {}
		for key in key_name:gmatch('([^+]+)') do
			local wndproc_key = key_name_to_wndproc[key]
			if wndproc_key == nil and #key == 1 then
				wndproc_keys[#wndproc_keys+1] = string.byte(string.upper(key))
			else
				wndproc_keys[#wndproc_keys+1] = wndproc_key
			end
		end

		local up_command
		if string.startswith(command, "+") then
			up_command = "-" .. string.sub(command, 2)
		end
		bind_table[#bind_table+1] = {keys=wndproc_keys, down_command=command, up_command=up_command}
	else
		log.warning("Usage: bind <key> <command>")
	end
end, nil, nil, {LOCAL_ONLY=true}) --TODO Add ARCHIVE

command.add("unbindall", function (player_id, args)
	bind_table = {}
end, nil, "Removes all binds", {LOCAL_ONLY=true})

function bind.get_table()
	return bind_table
end

local keys_down = {}
local function are_all_bind_keys_down(bind)
	local failed = false
	for _, key in ipairs(bind.keys) do
		if not keys_down[key] then
			failed = true
			break
		end
	end
	return not failed
end

local function is_key_in_bind(bind, key)
	local found = false
	for _, key_ in ipairs(bind.keys) do
		if key_ == key then
			return true
		end
	end
	return false
end

local function check_bind_keys(key_just_pressed, is_down)
	for _, bind in ipairs(bind_table) do
		if are_all_bind_keys_down(bind) then
			if is_down and bind.down_command then
				command.call(self.get_id(), bind.down_command, true)
			elseif not is_down and bind.up_command and is_key_in_bind(bind, key_just_pressed) then
				command.call(self.get_id(), bind.up_command, true)
			end
		end
	end
end

event.register_handler(menu_event.Wndproc, "BindWndprocHook", function (hwnd, msg, wparam, lparam)
	if msg == WM_KEYDOWN and not keys_down[wparam] then
		keys_down[wparam] = true
		check_bind_keys(wparam, true)
	elseif msg == WM_KEYUP then
		check_bind_keys(wparam, false)
		keys_down[wparam] = false
	end
end)
