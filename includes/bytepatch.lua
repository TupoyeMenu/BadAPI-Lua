local ffi = require("ffi")
local type = type

BytePatch = {}

local patches = {}

---Writes bytes at address, removes the previous bytepatch with the same name.
---Note that your pattern needs to skip the bytes that you patch, or else you won't be able find the pattern when you reload your script
---@param name string Name of the patch
---@param address integer|ffi.cdata*
---@param bytes table Table of bytes. Ex: `{0x90, 0x90}`
function BytePatch.Add(name, address, bytes)
	assert(istable(bytes), "bad argument 'bytes' for 'bytepatch.add'.\nExpected table got " .. type(bytes) .. "\nIn:")

	-- Revert the old patch
	BytePatch.Remove(name)

	address = ffi.cast("uint8_t*", address)

	-- Backup the patch so we can remove it later
	local og_bytes = {}
	for i = 1, #bytes do
		og_bytes[i] = (address + i-1)[0]
	end
	patches[name] = {m_address=address, m_og_bytes=og_bytes}

	for i = 1, #bytes do
		(address + i-1)[0] = bytes[i]
	end
end

---@param name string Name of the patch
---@return boolean found Returns true if the requested patch existed end was removed.
function BytePatch.Remove(name)
	local patch = patches[name]
	if patch then
		for i = 1, #patch.m_og_bytes do
			(patch.m_address + i-1)[0] = patch.m_og_bytes[i]
		end
		patches[name] = nil
		return true
	else
		return false
	end
end

---Turns everything from address to address + num_instructions into nop(0x90) instructions.
---@param name string Name of the patch
---@param address integer|ffi.cdata*
---@param num_instructions integer How many instructions you want to nop.
function BytePatch.Nop(name, address, num_instructions)
	local patch_array = {}
	for i = 1, num_instructions do
		patch_array[i] = 0x90
	end
	BytePatch.Add(name, address, patch_array)
end

function BytePatch.GetTable()
	return patches
end