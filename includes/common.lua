local ffi = require("ffi")

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
				type(key) == "string"  and '["' .. key .. '"]' or '[' .. tostring(key) .. ']',
				type(value) == "string"  and '= "' .. value .. '",' or '= ' .. tostring(value) .. ','
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
		if type(value) == "table" then
			log.info(tab_string .. "	" .. tostring(key) .. ' =')
			print_table(value, depth and depth + 1 or 1)
		else
			local key_string = type(key) == "string"  and '["' .. key .. '"]' or '[' .. tostring(key) .. ']'
			local value_string = type(value) == "string"  and '"' .. value .. '",' or tostring(value) .. ','
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

