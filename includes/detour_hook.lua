
local ffi = require("ffi")
local menu_exports = menu_exports

local detourHooks = {}

---@class detour_hook
---@field public m_name string
---@field public m_original ffi.cdata*|nil
---@field public m_target ffi.cdata*|nil
---@field public m_detour ffi.cdata*|nil
DetourHook = {
	m_name = "",
	m_original = nil,
	m_target = nil,
	m_detour = nil
}

---@param name string Name of the hook, must be unique.
---@param target ffi.cdata* Addres of the function to hook.
---@param detour ffi.cdata* Your callback function.
function DetourHook:new(name, target, detour)
	if not isstring(name) then PrintStacktrace("bad argument 'name' for 'detour_hook:new'.\nExpected string got " .. type(name) .. "\nIn:") return end
	if type(target) ~= "cdata" then PrintStacktrace("bad argument 'name' for 'detour_hook:new'.\nExpected cdata got " .. type(target) .. "\nIn:") return end
	if type(detour) ~= "cdata" then PrintStacktrace("bad argument 'name' for 'detour_hook:new'.\nExpected cdata got " .. type(detour) .. "\nIn:") return end

	o = {}
	setmetatable(o, self)
	self.__index = self
	o.m_name = name
	o.m_target = ffi.cast("void*", target)
	o.m_detour = detour

	detourHooks[name] = o

	return o
end

---Removes the hook
function DetourHook:__gc()
	if self.m_target ~= nil then
		menu_exports.MH_RemoveHook(self.m_target)
	end

	log.info("Removed lua hook '" .. self.m_name .. "'.")
end

---@private
function DetourHook:FixHookAddress()
	local ptr = ffi.cast("uint8_t*", self.m_target)
	while ffi.cast("uint8_t", ptr[0]) == 0xE9 do
		ptr = Rip(ptr + 1)
	end
	self.m_target = ffi.cast("void*", ptr)
end

function DetourHook:CreateHook()
	self:FixHookAddress()

	local original = ffi.new("void*[1]")
	local status = menu_exports.MH_CreateHook(self.m_target, self.m_detour, original)
	self.m_original = original[0]
	if status == ffi.C.MH_OK then
		log.info("Created lua hook '" .. self.m_name .. "'.")
	else
		log.fatal(string.format("Failed to create lua hook '%s' at %s (error: %s)", self.m_name, tostring(self.m_target), ffi.string(menu_exports.MH_StatusToString(status))))
	end
end

---@param apply boolean|nil Apply the hook after enabling it
function DetourHook:Enable(apply)
	local status = menu_exports.MH_QueueEnableHook(self.m_target)
	if status ~= ffi.C.MH_OK then
		log.fatal(string.format("Failed to enable lua hook '%s' at %s (error: %s)", self.m_name, tostring(self.m_target), ffi.string(menu_exports.MH_StatusToString(status))))
	end
	if apply then
		menu_exports.MH_ApplyQueued()
	end
end

function DetourHook:Disable()
	local status = menu_exports.MH_QueueDisableHook(self.m_target)
	if status ~= ffi.C.MH_OK then
		log.fatal(string.format("Failed to disable lua hook '%s' (error: %s)", self.m_name, ffi.string(menu_exports.MH_StatusToString(status))))
	end
end

function DetourHook:GetOriginal()
	return self.m_original
end

function DetourHook.GetHookByName(name)
	return detourHooks[name]
end



---Registers a C detour hook.
---@param name string Name of the hook, must be unique.
---@param address ffi.cdata* Addres of the function to hook.
---@param function_declaration ffi.cdecl* C style declaration for the function you want to hook, example: `"uint64_t (*)(uint64_t*, int)"`.
---@param callback function Your callback function.
---@param apply boolean|nil Applies the all hooks register without this argument, as well as this one.
---@return ffi.cdata*|nil original Original function, you may want to call this in your callback.
---@return table|nil detour Table for the detour_hook you just registered.
function DetourHook.register(name, address, function_declaration, callback, apply)
	local detour = DetourHook.GetHookByName(name)
	if detour ~= nil then -- Remove the old hook
		detour:__gc()
	end

	detour = DetourHook:new(name, address, ffi.cast(function_declaration, callback))
	if detour == nil then return nil, nil end

	detour:create_hook()
	local original = ffi.cast(function_declaration, detour:get_original())
	detour:enable(apply)

	return original, detour
end

---Registers a C detour hook.
---Does not support offsets, meant for pattens directly at the start of the function that break when the hook is enabled, preventing reloading.
---@param name string Name of the hook, must be unique.
---@param pattern string Pattern at the begining of the function you want to hook.
---@param module string Name of the module your function is in, leave empty for GTA5.exe.
---@param function_declaration string C style declaration for the function you want to hook, example: `"uint64_t (*)(uint64_t*, int)"`.
---@param callback function Your callback function.
---@param apply boolean|nil Applies the all hooks register without this argument, as well as this one.
---@return ffi.cdata*|nil original Original function, you may want to call this in your callback.
---@return table|nil detour Table for the detour_hook you just registered.
function DetourHook.register_by_pattern(name, pattern, module, function_declaration, callback, apply)

	local detour = DetourHook.GetHookByName(name)
	if detour ~= nil then -- Remove the old hook
		detour:__gc()
	end

	local address = menu_exports.scan_pattern(pattern, module)

	detour = DetourHook:new(name, address, ffi.cast(function_declaration, callback))
	if detour == nil then return nil, nil end

	detour:create_hook()
	local original = ffi.cast(function_declaration, detour:get_original())
	detour:enable(apply)

	return original, detour
end

