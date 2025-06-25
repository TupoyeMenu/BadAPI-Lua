function math.clamp(x, min, max)
	if x < min then return min end
	if x > max then return max end
	return x
end

function math.rotation_to_direction(rotation)
	local x = math.rad(rotation.x)
	local z = math.rad(rotation.z)
	local num = math.abs(math.cos(x))
	return vec3:new(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end
