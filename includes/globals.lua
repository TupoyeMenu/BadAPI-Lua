local ffi = require("ffi")

---@class ScriptGlobal
---@field m_name string
---@field m_pattern table<integer, integer>
---@field m_script_name string
---@field m_offset integer
---@field m_index integer|nil Will be nil if we didn't find the global yet.
---@field m_is_invalid boolean
---@field m_is_manual boolean
---@field m_length integer
---@field GetInt fun(self): integer? Value of the global, or nil if the index is not set.
---@field SetInt fun(self, value: integer)
---@field GetFloat fun(self): number? Value of the global, or nil if the index is not set.
---@field SetFloat fun(self, value: number)
---@field GetBool fun(self): boolean? Value of the global, or nil if the index is not set.
---@field SetBool fun(self, value: boolean)
---@field GetString fun(self, len: integer?): string?
---@field SetString fun(self, value: string, len: integer?)
---@field IsFound fun(self): boolean Has the global been found
---@field IsInvalid fun(self): boolean Is the global invalid. (Could not be found)
---@field IsManual fun(self): boolean Was this global created from an index
local ScriptGlobal = {}

---@param o table
---@return ScriptGlobal
function ScriptGlobal:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function ScriptGlobal:GetInt()
	if self.m_index == nil then return nil end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return nil end

	return ffi.cast("int*", Globals.GetPtr(self.m_index))[0]
end

---@param value integer
function ScriptGlobal:SetInt(value)
	if self.m_index == nil then return end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return end

	ffi.cast("int*", Globals.GetPtr(self.m_index))[0] = value
end

function ScriptGlobal:GetFloat()
	if self.m_index == nil then return nil end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return nil end

	return ffi.cast("float*", Globals.GetPtr(self.m_index))[0]
end

---@param value number
function ScriptGlobal:SetFloat(value)
	if self.m_index == nil then return end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return end

	ffi.cast("float*", Globals.GetPtr(self.m_index))[0] = value
end

---@return boolean? # Value of the global, or nil if the index is not set.
function ScriptGlobal:GetBool()
	if self.m_index == nil then return nil end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return nil end

	return ffi.cast("bool*", Globals.GetPtr(self.m_index))[0]
end

---@param value boolean
function ScriptGlobal:SetBool(value)
	if self.m_index == nil then return end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return end

	ffi.cast("bool*", Globals.GetPtr(self.m_index))[0] = value
end

---@param len integer? Manually specify the lenght of the string.
---@return boolean? # Value of the global, or nil if the index is not set.
function ScriptGlobal:GetString(len)
	if self.m_index == nil then return nil end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return nil end

	return ffi.string(ffi.cast("const char*", Globals.GetPtr(self.m_index)), len)
end

---@param value string
function ScriptGlobal:SetString(value)
	if self.m_index == nil then return end
	local ptr = Globals.GetPtr(self.m_index)
	if ptr == nil then return end

	ffi.copy(Globals.GetPtr(self.m_index), value)
end

---@return boolean
function ScriptGlobal:IsFound()
	return self.m_index ~= nil
end

---Is the global invalid. (Could not be found)
---@return boolean
function ScriptGlobal:IsInvalid()
	return self.m_is_invalid
end

---Was this global created from an index
---@return boolean
function ScriptGlobal:IsManual()
	return self.m_is_manual
end

---Library for interacting with ysc script globals
Globals =
{
	---@type table<integer, ScriptGlobal>
	m_global_cache = {}
}

---@param index integer The index of the global.
---@return ffi.cdata* global_ptr An ffi pointer to the global at index
function Globals.GetPtr(index)
	return menu_exports.get_script_globals()[bit.band(bit.rshift(index, 0x12), 0x3F)] + (bit.band(index, 0x3FFFF))
end

function Globals.Get(index)
	local global = {
		m_name = nil,
		m_script_name = nil,
		m_pattern = nil,
		m_offset = nil,
		m_length = nil,
		m_index = index,
		m_is_manual = true
	}

	return ScriptGlobal:new(global)
end

---Internal
local function get_code_location_by_pattern(program, pattern)
	local code_size = program.m_CodeSize
	for i = 0, code_size - #pattern do
		for j = 1, #pattern do
			if pattern[j] ~= -1 then
				if pattern[j] ~= program:GetCodeAddress(i+j-1)[0] then
					goto incorrect
				end
			end
		end
		do return i end
		::incorrect::
	end
	return nil
end

---Internal
local function read_bytes_from_pattern(program, pattern, offset, num_bytes)
	local location = get_code_location_by_pattern(program, pattern)
	if location == nil then return nil end

	local code_address = program:GetCodeAddress(location+offset)
	local arr = ffi.cast("uint8_t*", code_address)
	local result = 0
	for i = 0, num_bytes-1 do
		result = result + bit.lshift(arr[i], i*8)
	end
	return result
end


---Registers a global to be found.
---You can use [ScrUpdate](https://github.com/maybegreat48/ScrUpdate) to generate the pattern and offset.
---It will generate a result like this:
---```
---P"5E ? ? ? 34 ? 41 ? 25 ? 7F 1F 56 ? ? 6E" +1 A ="global" +4 B ="global size"
---```
---Where `5E ? ? ? 34 ? 41 ? 25 ? 7F 1F 56 ? ? 6E` is the pattern, and `+1` is the offset
---@param global_name string Name of the global, can be anything unique.
---@param script_name string Name of the ysc script to find the pattern in.
---@param pattern string IDA style pattern for the global
---@param offset integer Offset from the pattern
---@param num_bytes integer Length of the global index in bytes, must be <= 4
---@return ScriptGlobal # The global structure. You can use `IsFound` in this class to check if the global was found.
function Globals.FindByPattern(global_name, script_name, pattern, offset, num_bytes)
	local global = ScriptGlobal:new
	{
		m_name = global_name,
		m_script_name = script_name,
		m_length = num_bytes,
		m_pattern = Pattern.BytesFromIDASig(pattern),
		m_offset = offset,
		m_is_manual = false
	}

	local program = menu_exports.get_script_program_table():FindScript(joaat(global.m_script_name))
	if program ~= nil then
		global.m_index = read_bytes_from_pattern(program, global.m_pattern, global.m_offset, global.m_length)
		if global.m_index == nil then
			global.m_is_invalid = true
			log.warning('Failed to find global: "' .. global.m_name .. '" in script: "' .. global.m_script_name .. '"')
		end
	end

	Globals.m_global_cache[#Globals.m_global_cache+1] = global
	return global
end


event.register_handler("InitNativeTables", "ProgramStartTest", function (program)
	program = ffi.cast("struct scrProgram*", program)
	if program == nil then return end

	for _, global in ipairs(Globals.m_global_cache) do
		if joaat(global.m_script_name) == program.m_NameHash and global.m_index == nil and not global.m_is_invalid and not global.m_is_manual then
			global.m_index = read_bytes_from_pattern(program, global.m_pattern, global.m_offset, global.m_length)
			if global.m_index == nil then
				global.m_is_invalid = true
				log.warning('Failed to find global: "' .. global.m_name .. '" in script: "' .. global.m_script_name .. '"')
			end
		end
	end
end)


