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
