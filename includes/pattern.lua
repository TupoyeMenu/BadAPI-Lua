
---A library for parsing patterns.
Pattern = {}

---This must match any byte
Pattern.WildCard = -1

function Pattern.BytesFromIDASig(ida_sig)
	local result = {}
	for byte in string.gmatch(ida_sig, "%S+") do
		if byte == "?" or byte == "??" then
			result[#result+1] = Pattern.WildCard
		else
			result[#result+1] = tonumber(byte, 16)
		end
	end
	return result
end
