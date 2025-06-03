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
function print_stacktrace(error_before_stacktrace)
	if error_before_stacktrace ~= nil then
		log.warning(error_before_stacktrace .. "\n" .. debug.traceback())
	else
		log.warning(debug.traceback())
	end
end

---@param address any An FFI pointer.
---@return any result An FFI pointer.
function rip(address)
	-- We cast address to int64_t here, because if it's unsigned and the offset is negative
	-- it will set the first bit of uint64_t
	local result = ffi.cast("int64_t", address) + ffi.cast("int32_t*", address)[0] + 4
	return result
end


---@param table_to_print table Table to print
---@param depth integer|nil How many tab characters to insert before values.
---Prints a table to stdout, uses the print function internally
function print_table(table_to_print, depth)
	local tab_string = ""
	if depth then
		for i = 1, depth do
			tab_string = tab_string .. "	"
		end
	end

	print(tab_string .. "{")
	for key, value in pairs(table_to_print) do
		if type(value) == "table" then
			print(tab_string, tostring(key) .. ' =')
			print_table(value, depth and depth + 1 or 1)
		else
			print(
				tab_string,
				isstring(key) and '["' .. key .. '"]' or '[' .. tostring(key) .. ']',
				isstring(value) and '= "' .. value .. '",' or '= ' .. tostring(value) .. ','
			)
		end
	end
	print(tab_string .. "}" .. (depth == nil and "" or ","))
end

---@param table_to_print table Table to print
---@param depth integer|nil How many tab characters to insert before values.
---Prints a table to the log, uses the log.info function internally
function log_table(table_to_print, depth)
	local tab_string = ""
	if depth then
		for _ = 1, depth do
			tab_string = tab_string .. "	"
		end
	end

	log.info(tab_string .. "{")
	for key, value in pairs(table_to_print) do
		if istable(value) then
			log.info(tab_string .. "	" .. tostring(key) .. ' =')
			print_table(value, depth and depth + 1 or 1)
		else
			local key_string = isstring(key)  and '["' .. key .. '"]' or '[' .. tostring(key) .. ']'
			local value_string = isstring(value)  and '"' .. value .. '",' or tostring(value) .. ','
			log.info(
				tab_string
				.. "	"
				.. key_string
				.. "	= "
				.. value_string
			)
		end
	end
	log.info(tab_string .. "}" .. (depth == nil and "" or ","))
end

