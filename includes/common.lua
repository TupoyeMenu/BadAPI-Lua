local ffi = require("ffi")

---Converts the input into a bool.
---@param input any
---@return boolean
function tobool(input)
	if input == false or input == nil or input == 0 or input == "0" or input == "false" then
		return false
	end
	return true
end

function isbool(input)
	return type(input) == "boolean"
end
function isnumber(input)
	return type(input) == "number"
end
function isstring(input)
	return type(input) == "string"
end
function istable(input)
	return type(input) == "table"
end
function isfunction(input)
	return type(input) == "function"
end
function isvector(input)
	if type(input.x) == "number" and type(input.y) == "number" and type(input.z) == "number" then
		return true
	end
	return false
end


---Prints the stacktrace
---@param error_before_stacktrace string|nil Placed before the actual stacktrace
function PrintStacktrace(error_before_stacktrace)
	if error_before_stacktrace ~= nil then
		log.warning(error_before_stacktrace .. "\n" .. debug.traceback())
	else
		log.warning(debug.traceback())
	end
end

---@param address any An FFI pointer.
---@return any result An FFI pointer.
function Rip(address)
	-- We cast address to int64_t here, because if it's unsigned and the offset is negative
	-- it will set the first bit of uint64_t
	local result = ffi.cast("int64_t", address) + ffi.cast("int32_t*", address)[0] + 4
	return result
end


---@param table_to_print table Table to print
---@param depth integer|nil How many tab characters to insert before values.
---Prints a table to stdout, uses the print function internally
function PrintTable(table_to_print, depth)
	assert(istable(table_to_print), "bad argument 'table_to_print' for 'PrintTable'.\nExpected table got " .. type(table_to_print) .. "\nIn:")

	local tab_string = ""
	if depth then
		for i = 1, depth do
			tab_string = tab_string .. "	"
		end
	end

	print(tab_string .. "{")
	for key, value in pairs(table_to_print) do
		local value_string = " = "
		if isstring(value) then
			value_string = value_string .. '"' .. value .. '",'
		elseif not istable(value) then
			value_string = value_string .. tostring(value) .. ","
		end
		print(
			tab_string,
			isstring(key) and '["' .. key .. '"]' or '[' .. tostring(key) .. ']',
			value_string
		)


		if istable(value) then
			PrintTable(value, depth and depth + 1 or 1)
		end
	end
	print(tab_string .. "}" .. (depth == nil and "" or ","))
end

