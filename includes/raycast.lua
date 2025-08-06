local ffi = require("ffi")

Raycast = {}

local empty_vec3 = vec3.zero()

---@param cam_coords vec3
---@param direction vec3
---@param ignore_ent_handle number
---@return boolean hit
---@return vec3 end_coords
---@return vec3 normal
---@return integer entity_hit_handle
function Raycast.Raycast(cam_coords, direction, ignore_ent_handle)
	local far_coords = vec3:new(
		cam_coords.x + direction.x * 1000,
		cam_coords.y + direction.y * 1000,
		cam_coords.z + direction.z * 1000
	)

	local ray = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(cam_coords.x, cam_coords.y, cam_coords.z, far_coords.x, far_coords.y, far_coords.z, -1, ignore_ent_handle, 7)
	local result, hit, end_coords, normal, ent_result = SHAPETEST.GET_SHAPE_TEST_RESULT(ray, false, empty_vec3, empty_vec3, 0)

	return hit, end_coords, normal, ent_result
end
