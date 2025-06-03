local ffi = require("ffi")

local fvector3 = ffi.typeof("fvector3")
ffi.metatype("fvector3", {
	__add = function (a, b)
		local result = fvector3()
		result.x = a.x + b.x
		result.y = a.y + b.y
		result.z = a.z + b.z
		return result
	end,
	__sub = function (a, b)
		local result = fvector3()
		result.x = a.x - b.x
		result.y = a.y - b.y
		result.z = a.z - b.z
		return result
	end,
	__mul = function (a, b)
		local result = fvector3()
		if isnumber(b) then
			result.x = a.x * b
			result.y = a.y * b
			result.z = a.z * b
		else
			result.x = a.x * b.x
			result.y = a.y * b.y
			result.z = a.z * b.z
		end
		return result
	end,
	__div = function (a, b)
		local result = fvector3()
		if isnumber(b) then
			result.x = a.x / b
			result.y = a.y / b
			result.z = a.z / b
		else
			result.x = a.x / b.x
			result.y = a.y / b.y
			result.z = a.z / b.z
		end
		return result
	end,
})


local address
if menu_exports.is_enhanced() then
	-- multiple results, but all point to the same function
	address = ffi.cast("void* (*)(void* _this, enum eHandlingType handling_type)", rip(menu_exports.scan_pattern("BA 08 00 00 00 E8 ? ? ? ? F6 40 ? 80 74 56", "") + 6))
else
	address = ffi.cast("void* (*)(void* _this, enum eHandlingType handling_type)", rip(menu_exports.scan_pattern("BA 08 00 00 00 E8 ? ? ? ? F7 40 ? ? 00 80 00 74 6F", "") + 6))
end
ffi.metatype("struct CHandlingData", {
	__index = {
		get_sub_handling = function(_self, hanling_type)
			return address(_self, hanling_type)
		end
	}
})

