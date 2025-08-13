
function table.size(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end

function table.reverse(table)
	local new_table = {}
	local size = #table
	for k, v in ipairs(table) do
		new_table[size + 1 - k] = v
	end
	return new_table
end
