blip = {}

---@param sprite integer
---@param color integer
---@return boolean success
---@return vec3 location
function blip.get_location(sprite, color)
	local blip = HUD.GET_CLOSEST_BLIP_INFO_ID(sprite)
	while HUD.DOES_BLIP_EXIST(blip) and color ~= -1 and HUD.GET_BLIP_COLOUR(blip) ~= color do
		HUD.GET_NEXT_BLIP_INFO_ID(sprite)
	end

	if not HUD.DOES_BLIP_EXIST(blip) or (color ~= -1 and HUD.GET_BLIP_COLOUR(blip) ~= color) then
		return false, vec3:new(0,0,0)
	end

	return true, HUD.GET_BLIP_COORDS(blip)
end

