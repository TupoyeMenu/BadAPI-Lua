-- This is an external script. It should not be run from BadAPI.
-- It is used to preprocess the gta.c file.
-- You need gcc in PATH to run this script!

local function get_lua_code(is_enhanced)
	local lua_file =
[[
local ffi = require("ffi")
ffi.cdef[[

]]
	local cmd = io.popen("gcc -E gta.c")
	if cmd ~= nil then
		local code = cmd:read("*a")
		lua_file = lua_file .. code .. "\n]]"
	else
		print("io.popen is gcc in your path?")
		return nil
	end
	return lua_file
end

local legacy_file = io.open("gta_legacy.lua", "w")
local legacy_code = get_lua_code(false)
if legacy_file and legacy_code then
	legacy_file:write(legacy_code)
	legacy_file:close() -- Not closed when legacy_code is nil, but I don't care.
end
local enhanced_file = io.open("gta_enhaced.lua", "w")
local enhanced_code = get_lua_code(false)
if enhanced_file and enhanced_code then
	enhanced_file:write(enhanced_code)
	enhanced_file:close() -- Not closed when legacy_code is nil, but I don't care.
end
