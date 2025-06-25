
---@param input string
---@param start string
---@return boolean
function string.startswith(input, start)
	return string.sub(input, 1, #start) == start
end
---@param input string
---@param _end string
---@return boolean
function string.endswith(input, _end)
	return string.sub(input, -#_end) == _end
end

