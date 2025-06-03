
function string.startswith(input, start)
	return string.sub(input, 1, #start) == start
end
function string.endswith(input, _end)
	return string.sub(input, -#_end) == _end
end

