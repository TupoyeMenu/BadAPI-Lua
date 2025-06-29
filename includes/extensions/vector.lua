
-- Adds basic math operations for vec3
--#region vec3
vec3.__add = function (a, b)
	return vec3:new(
		a.x + b.x,
		a.y + b.y,
		a.z + b.z
	)
end

vec3.__sub = function (a, b)
	return vec3:new(
		a.x - b.x,
		a.y - b.y,
		a.z - b.z
	)
end

vec3.__mul = function (a, b)
	if type(b) == "number" then
		return vec3:new(
			a.x * b,
			a.y * b,
			a.z * b
		)
	else
		return vec3:new(
			a.x * b.x,
			a.y * b.y,
			a.z * b.z
		)
	end
end

vec3.__div = function (a, b)
	if type(b) == "number" then
		return vec3:new(
			a.x / b,
			a.y / b,
			a.z / b
		)
	else
		return vec3:new(
			a.x / b.x,
			a.y / b.y,
			a.z / b.z
		)
	end
end

vec3.__eq = function (a, b)
	return a.x == b.x and
		   a.y == b.y and
		   a.z == b.z
end

vec3.cross_product = function (a,b)
	return vec3:new(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

vec3.dot_product = function (a,b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

vec3.length = function (a)
	return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
end

vec3.normalize = function (a)
	local len = a:length()
	if len ~= 0 then
		return a * (1/len)
	end
	return a
end

vec3.distance = function (a,b)
	return (a - b):length()
end

--#endregion vec3

--#region vec2

---@class vec2
---@field x number
---@field y number
vec2 = {}

---@param x number?
---@param y number?
---@return vec2
function vec2:new(x,y)
	assert(type(x) == "number" and type(y) == "number")

	---@type vec2
	---@diagnostic disable-next-line: missing-fields
	o = {}

	o.x = x or 0
	o.y = x or 0

	setmetatable(o, self)
	self.__index = self

	return o
end

vec2.__add = function (a, b)
	return vec2:new(
		a.x + b.x,
		a.y + b.y
	)
end

vec2.__sub = function (a, b)
	return vec2:new(
		a.x - b.x,
		a.y - b.y
	)
end

vec2.__mul = function (a, b)
	if type(b) == "number" then
		return vec2:new(
			a.x * b,
			a.y * b
		)
	else
		return vec2:new(
			a.x * b.x,
			a.y * b.y
		)
	end
end

vec2.__div = function (a, b)
	if type(b) == "number" then
		return vec2:new(
			a.x / b,
			a.y / b
		)
	else
		return vec2:new(
			a.x / b.x,
			a.y / b.y
		)
	end
end

vec2.__eq = function (a, b)
	return a.x == b.x and
		   a.y == b.y
end

---@param a vec2
---@param b vec2
vec2.cross_product = function (a,b)
	return a.x * b.y - a.y * b.x
end


---@param a vec2
---@param b vec2
---@return number
vec2.dot_product = function (a,b)
	return a.x * b.x + a.y * b.y
end

---@param a vec2
---@return number
vec2.length = function (a)
	return math.sqrt(a.x * a.x + a.y * a.y)
end

vec2.normalize = function (a)
	local len = a:length()
	if len ~= 0 then
		return a * (1/len)
	end
	return a
end

vec2.distance = function (a,b)
	return (a - b):length()
end

--#endregion
