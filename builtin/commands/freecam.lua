local controls = { INPUT_LOOK_LR, INPUT_LOOK_UD, INPUT_LOOK_UP_ONLY, INPUT_LOOK_DOWN_ONLY, INPUT_LOOK_LEFT_ONLY, INPUT_LOOK_RIGHT_ONLY, INPUT_LOOK_LEFT, INPUT_LOOK_RIGHT, INPUT_LOOK_UP, INPUT_LOOK_DOWN }


freecam = {}

freecam.camera = -1
freecam.position = vec3:new(0,0,0)
freecam.rotation = vec3:new(0,0,0)
freecam.speed = 0.25
freecam.mult = 0
freecam.uses_pitch = true
freecam.moves_streaming = true
freecam.moves_player = false
freecam.entity = 0
freecam.enabled = false

function freecam.on_enable()
	freecam.camera = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", false)
	freecam.position = CAM.GET_GAMEPLAY_CAM_COORD()
	freecam.rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)

	CAM.SET_CAM_COORD(freecam.camera, freecam.position.x, freecam.position.y, freecam.position.z)
	CAM.SET_CAM_ROT(freecam.camera, freecam.rotation.x, freecam.rotation.y, freecam.rotation.z, 2)
	CAM.SET_CAM_ACTIVE(freecam.camera, true)
	CAM.RENDER_SCRIPT_CAMS(true, true, 500, true, true, 0);
	freecam.enabled = true
end
function freecam.on_disable()
	CAM.SET_CAM_ACTIVE(freecam.camera, false)
	CAM.RENDER_SCRIPT_CAMS(false, true, 500, true, false, 0)
	CAM.DESTROY_CAM(freecam.camera, false)
	STREAMING.CLEAR_FOCUS()
	freecam.enabled = false

	if freecam.moves_player then
		ENTITY.FREEZE_ENTITY_POSITION(freecam.entity, false)
		ENTITY.SET_ENTITY_COLLISION(freecam.entity, true, true)
		ENTITY.SET_ENTITY_VISIBLE(freecam.entity, true, false)
	end
end
function freecam.toggle()
	if freecam.enabled then
		freecam.on_disable()
	else
		freecam.on_enable()
	end
end

function freecam.on_tick()
	if not freecam.enabled then return end
	PAD.DISABLE_ALL_CONTROL_ACTIONS(0)

	for _,control in pairs(controls) do
		PAD.ENABLE_CONTROL_ACTION(0, control, true)
	end

	local vecChange = vec3:new(0, 0, 0);

	-- Left Shift
	if PAD.IS_DISABLED_CONTROL_PRESSED(0, INPUT_SPRINT) then
		vecChange.z = vecChange.z + freecam.speed / 2
	end
	-- Left Control
	if PAD.IS_DISABLED_CONTROL_PRESSED(0, INPUT_DUCK) then
		vecChange.z = vecChange.z - freecam.speed / 2
	end
	-- Left
	vecChange.x = vecChange.x - freecam.speed * PAD.GET_DISABLED_CONTROL_NORMAL(0, INPUT_MOVE_LEFT_ONLY)
	-- Right
	vecChange.x = vecChange.x + freecam.speed * PAD.GET_DISABLED_CONTROL_NORMAL(0, INPUT_MOVE_RIGHT_ONLY)

	if vecChange.x == 0 and vecChange.y == 0 and vecChange.z == 0 and PAD.GET_DISABLED_CONTROL_NORMAL(0, INPUT_MOVE_UP) == 0 then
		freecam.mult = 0
	elseif freecam.mult < 10 then
		freecam.mult = freecam.mult + 0.15
	end

	local rot   = CAM.GET_CAM_ROT(freecam.camera, 0)
	local forward = math.rotation_to_direction(rot)*PAD.GET_DISABLED_CONTROL_NORMAL(0, INPUT_MOVE_UP)*-1*freecam.speed
	local yaw = math.rad(rot.z) -- horizontal

	if forward then
		freecam.position.x = freecam.position.x + (forward.x * freecam.mult)
		freecam.position.y = freecam.position.y + (forward.y * freecam.mult)
		freecam.position.z = freecam.position.z + (forward.z * freecam.mult)
	end
	freecam.position.x = freecam.position.x + (vecChange.x * math.cos(yaw) - vecChange.y * math.sin(yaw)) * freecam.mult
	freecam.position.y = freecam.position.y + (vecChange.x * math.sin(yaw) + vecChange.y * math.cos(yaw)) * freecam.mult

	CAM.SET_CAM_COORD(freecam.camera, freecam.position.x, freecam.position.y, freecam.position.z)
	if freecam.moves_streaming then
		STREAMING.SET_FOCUS_POS_AND_VEL(freecam.position.x, freecam.position.y, freecam.position.z, 0.0, 0.0, 0.0)
	end

	freecam.rotation = CAM.GET_GAMEPLAY_CAM_ROT(2)
	CAM.SET_CAM_ROT(freecam.camera, freecam.rotation.x, freecam.rotation.y, freecam.rotation.z, 2)


	if freecam.moves_player then
		local ped = self.get_ped()
		local veh = PED.GET_VEHICLE_PED_IS_IN(ped, true)
		freecam.entity = PED.IS_PED_IN_ANY_VEHICLE(ped, true) and veh or ped
		ENTITY.FREEZE_ENTITY_POSITION(freecam.entity, true)
		ENTITY.SET_ENTITY_COLLISION(freecam.entity, false, false)
		ENTITY.SET_ENTITY_VISIBLE(freecam.entity, false, false)
		ENTITY.SET_ENTITY_ROTATION(freecam.entity, 0, freecam.rotation.y, freecam.rotation.z, 2, false)
		ENTITY.SET_ENTITY_COORDS(freecam.entity, freecam.position.x, freecam.position.y, freecam.position.z, false, false, false, false)
	end
end

script.register_looped("FreecamTick", function (script)
	freecam.on_tick()
end)

Command.Add("freecam", function (player_id, args)
	script.run_in_fiber(function ()
		freecam.moves_player = false
		freecam.toggle()
	end)
end, nil, nil, {LOCAL_ONLY=true})

Command.Add("noclip", function (player_id, args)
	script.run_in_fiber(function ()
		freecam.moves_player = true
		freecam.toggle()
	end)
end, nil, nil, {LOCAL_ONLY=true})
