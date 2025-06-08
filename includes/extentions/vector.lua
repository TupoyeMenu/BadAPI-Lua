-- Adds basic math operations for vec3

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
