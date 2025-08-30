local ffi = require("ffi")

---@class ScriptLocal
---@field m_name string
---@field m_pattern table<integer, integer>
---@field m_script_name string
---@field m_offset integer
---@field m_index integer|nil Will be nil if we didn't find the local yet.
---@field m_is_invalid boolean
---@field m_is_manual boolean
---@field m_length integer
---@field m_thread ffi.cdata*? Pointer to the script thread, or nil if it's not running.
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
local ScriptLocal = {}

---@param o table
---@return ScriptLocal
function ScriptLocal:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function ScriptLocal:GetInt()
	if self.m_index == nil then return nil end
	if self.m_thread == nil then return nil end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return nil end

	return ffi.cast("int*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index))[0]
end

---@param value integer
function ScriptLocal:SetInt(value)
	if self.m_index == nil then return end
	if self.m_thread == nil then return end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return end

	ffi.cast("int*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index))[0] = value
end

function ScriptLocal:GetFloat()
	if self.m_index == nil then return nil end
	if self.m_thread == nil then return nil end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return nil end

	return ffi.cast("float*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index))[0]
end

---@param value number
function ScriptLocal:SetFloat(value)
	if self.m_index == nil then return end
	if self.m_thread == nil then return end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return end

	ffi.cast("float*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index))[0] = value
end

---@return boolean? # Value of the global, or nil if the index is not set.
function ScriptLocal:GetBool()
	if self.m_index == nil then return nil end
	if self.m_thread == nil then return nil end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return nil end

	return ffi.cast("bool*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index))[0]
end

---@param value boolean
function ScriptLocal:SetBool(value)
	if self.m_index == nil then return end
	if self.m_thread == nil then return end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return end

	ffi.cast("bool*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index))[0] = value
end

---@param len integer? Manually specify the lenght of the string.
---@return boolean? # Value of the global, or nil if the index is not set.
function ScriptLocal:GetString(len)
	if self.m_index == nil then return nil end
	if self.m_thread == nil then return nil end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return nil end

	return ffi.string(ffi.cast("const char*", Locals.GetPtr(self.m_thread.m_Stack, self.m_index)), len)
end

---@param value string
function ScriptLocal:SetString(value)
	if self.m_index == nil then return end
	if self.m_thread == nil then return end
	local ptr = Locals.GetPtr(self.m_thread.m_Stack, self.m_index)
	if ptr == nil then return end

	ffi.copy(Locals.GetPtr(self.m_thread.m_Stack, self.m_index), value)
end

---@return boolean
function ScriptLocal:IsFound()
	return self.m_index ~= nil
end

---Is the global invalid. (Could not be found)
---@return boolean
function ScriptLocal:IsInvalid()
	return self.m_is_invalid
end

---Was this global created from an index
---@return boolean
function ScriptLocal:IsManual()
	return self.m_is_manual
end

---Library for interacting with ysc script globals
Locals =
{
	---@type table<integer, ScriptLocal>
	m_local_cache = {}
}

---@param stack ffi.cdata* Pointer to the stack containing the local.
---@param index integer The index of the local.
---@return ffi.cdata* global_ptr An ffi pointer to the local at index
function Locals.GetPtr(stack, index)
	return ffi.cast("uint64_t", stack) + (index * 8)
end

function Locals.Get(index)
	local global = {
		m_name = nil,
		m_script_name = nil,
		m_pattern = nil,
		m_offset = nil,
		m_length = nil,
		m_index = index,
		m_is_manual = true,
		m_thread = nil
	}

	return ScriptLocal:new(global)
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

local function FindThreadByHash(hash)
	local script_threads = menu_exports.get_script_threads()
	local thread_ptr
	for i = 0, script_threads.m_size-1 do
		local data = ffi.cast("struct GtaThread**", script_threads.m_data)[i]
		if data ~= nil and data.m_ScriptHash == hash then
			thread_ptr = data
		end
	end
	return thread_ptr
end

local function FindThreadById(thread_id)
	local script_threads = menu_exports.get_script_threads()
	local thread_ptr
	for i = 0, script_threads.m_size-1 do
		local data = ffi.cast("struct GtaThread**", script_threads.m_data)[i]
		if data ~= nil and data.m_Context.m_ThreadId == thread_id then
			thread_ptr = data
		end
	end
	return thread_ptr
end

---Registers a local to be found.
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
---@return ScriptLocal # The global structure. You can use `IsFound` in this class to check if the global was found.
function Locals.FindByPattern(global_name, script_name, pattern, offset, num_bytes)
	local _local = ScriptLocal:new
	{
		m_name = global_name,
		m_script_name = script_name,
		m_length = num_bytes,
		m_pattern = Pattern.BytesFromIDASig(pattern),
		m_offset = offset,
		m_is_manual = false,
		m_thread = FindThreadByHash(joaat(script_name))
	}

	local program = menu_exports.get_script_program_table():FindScript(joaat(_local.m_script_name))
	if program ~= nil then
		_local.m_index = read_bytes_from_pattern(program, _local.m_pattern, _local.m_offset, _local.m_length)
		if _local.m_index == nil then
			_local.m_is_invalid = true
			log.warning('Failed to find local: "' .. _local.m_name .. '" in script: "' .. _local.m_script_name .. '"')
		end
	end

	Locals.m_local_cache[#Locals.m_local_cache+1] = _local
	return _local
end

event.register_handler("GTAThreadCreate", "AssignThreadToLocals", function (thread_id)
	local thread_ptr = FindThreadById(thread_id)
	if thread_ptr == nil then return end

	for _, value in ipairs(Locals.m_local_cache) do
		if joaat(value.m_script_name) == thread_ptr.m_ScriptHash then
			value.m_thread = thread_ptr
		end
	end
end)

event.register_handler("GTAThreadKill", "RemoveKilledThreadsFromLocals", function (thread_ptr)
	thread_ptr = ffi.cast("struct GtaThread*", thread_ptr)

	for _, value in ipairs(Locals.m_local_cache) do
		if joaat(value.m_script_name) == thread_ptr.m_ScriptHash then
			value.m_thread = nil
		end
	end
end)

event.register_handler("InitNativeTables", "ProgramStartTest", function (program)
	program = ffi.cast("struct scrProgram*", program)
	if program == nil then return end

	for _, _local in ipairs(Globals.m_global_cache) do
		if joaat(_local.m_script_name) == program.m_NameHash and _local.m_index == nil and not _local.m_is_invalid and not _local.m_is_manual then
			_local.m_index = read_bytes_from_pattern(program, _local.m_pattern, _local.m_offset, 3)
			if _local.m_index == nil then
				_local.m_is_invalid = true
				log.warning('Failed to find global: "' .. _local.m_name .. '" in script: "' .. _local.m_script_name .. '"')
			end
		end
	end
end)

