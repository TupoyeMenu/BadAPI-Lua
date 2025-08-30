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
local fvector4 = ffi.typeof("fvector4")
ffi.metatype("fvector4", {
	__add = function (a, b)
		local result = fvector4()
		result.x = a.x + b.x
		result.y = a.y + b.y
		result.z = a.z + b.z
		result.w = a.w + b.w
		return result
	end,
	__sub = function (a, b)
		local result = fvector4()
		result.x = a.x - b.x
		result.y = a.y - b.y
		result.z = a.z - b.z
		result.w = a.w - b.w
		return result
	end,
	__mul = function (a, b)
		local result = fvector4()
		if isnumber(b) then
			result.x = a.x * b
			result.y = a.y * b
			result.z = a.z * b
			result.w = a.w * b
		else
			result.x = a.x * b.x
			result.y = a.y * b.y
			result.z = a.z * b.z
			result.w = a.w * b.w
		end
		return result
	end,
	__div = function (a, b)
		local result = fvector4()
		if isnumber(b) then
			result.x = a.x / b
			result.y = a.y / b
			result.z = a.z / b
			result.w = a.w / b
		else
			result.x = a.x / b.x
			result.y = a.y / b.y
			result.z = a.z / b.z
			result.w = a.w / b.w
		end
		return result
	end,
})


local address
if menu_exports.is_enhanced() then
	-- multiple results, but all point to the same function
	address = ffi.cast("void* (*)(void* _this, enum eHandlingType handling_type)", Rip(menu_exports.scan_pattern("BA 08 00 00 00 E8 ? ? ? ? F6 40 ? 80 74 56", "") + 6))
else
	address = ffi.cast("void* (*)(void* _this, enum eHandlingType handling_type)", Rip(menu_exports.scan_pattern("BA 08 00 00 00 E8 ? ? ? ? F7 40 ? ? 00 80 00 74 6F", "") + 6))
end
ffi.metatype("struct CHandlingData", {
	__index = {
		GetSubHandling = function(_self, hanling_type)
			return address(_self, hanling_type)
		end
	}
})

ffi.metatype("struct Obf32", {
	__index = {
		getData = function (_self)
			local v105 = _self.m_unk4
			local v28 = bit.band(_self.m_unk1, v105)
			local v94 = bit.band(_self.m_unk2, bit.bnot(v105))
			return bit.bor(v28, v94);
		end,

		setData = function(_self, val)
			local seed = os.time()
			_self.m_unk3 = seed
			seed = os.time()
			_self.m_unk4 = seed

			local v48 = bit.band(val, bit.bnot(seed))
			_self.m_unk1 = bit.band(seed, val)
			_self.m_unk2 = v48
		end
	}
})


ffi.metatype("struct datBitBuffer", {
	__index = {
		Read = function (_self, type, size, signed)
			signed = signed or false

			local res = ffi.new("uint64_t[1]")
			local res_signed = ffi.new("int64_t[1]")
			if signed then
				menu_exports.bitbuffer_ReadInt64(_self, res_signed, size)
			else
				menu_exports.bitbuffer_ReadQword(_self, res, size)
			end

			if signed then
				return ffi.cast(type, res_signed[0])
			else
				return ffi.cast(type, res[0])
			end
		end,
		Write = function (_self, data, size, signed)
			signed = signed or false

			if signed then
				menu_exports.bitbuffer_WriteInt64(_self, ffi.cast("int64_t", data), size)
			else
				menu_exports.bitbuffer_WriteQword(_self, ffi.cast("uint64_t", data), size)
			end
		end
	}
})

ffi.metatype("struct scrProgram", {
	__index = {
		IsValid = function (self)
			return self.m_CodeSize ~= 0
		end,
		GetNumCodePages = function (self)
			return bit.rshift(self.m_CodeSize + 0x3FFF, 14)
		end,
		GetCodePageSize = function (self, page)
			local num = bit.rshift(self.m_CodeSize + 0x3FFF, 14)
			if page < num then
				if (page == num - 1) then
					return bit.band(self.m_CodeSize, 0x3FFF)
				end
				return 0x4000
			end
			return 0
		end,
		GetFullCodeSize = function (self)
			return self.m_CodeSize
		end,
		GetCodePage = function (self, page)
			return self.m_CodeBlocks[page]
		end,
		GetCodeAddress = function (self, index)
			if (index < self.m_CodeSize) then
				return self.m_CodeBlocks[bit.rshift(index, 14)]+bit.band(index, 0x3FFF)
			end

			return nil
		end,
		GetString = function (self, index)
			if (index < self.m_StringsCount) then
				return ffi.string(self.m_StringsData[bit.rshift(index, 14)]+bit.band(index, 0x3FFF))
			end

			return nil
		end,
		GetAddressOfNativeEntrypoint = function (self, entrypoint)
			for i = 0, self.m_NativeCount-1 do
				if (self.m_NativeEntrypoints[i] == entrypoint) then
					return self.m_NativeEntrypoints + i;
				end
			end

			return nil
		end
	}
})

ffi.metatype("struct scrProgramTable", {
	__index = {
		FindScript = function (self, hash)
			for i = 0, self.m_Size-1 do
				if self.m_Data[i].m_Hash == hash then
					return self.m_Data[i].m_Program
				end
			end

			return nil
		end,
	},
	__len = function (self)
		return self.m_Size
	end
})