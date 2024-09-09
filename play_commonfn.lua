local fns = {}

--------------------------------------------------------------------------------
local function bird_arrive(inst, bird_property, bird_castname)
	local stageactingprop = inst.components.stageactingprop
	if stageactingprop and stageactingprop.cast then
		local stageactor = stageactingprop[bird_property]
		stageactingprop.cast[bird_castname] = {castmember = stageactor}
		stageactor:PushEvent("arrive")
	end
end

fns.callbirds = function(inst, line, cast)
	bird_arrive(inst, "bird1", "BIRD1")
	inst:DoTaskInTime(0.3, bird_arrive, "bird2", "BIRD2")

    if cast ~= nil then
        cast["NARRATOR"] = {castmember = inst}
    end
end
--------------------------------------------------------------------------------

local function bird_exit(bird)
	bird.exit = true
end

fns.exitbirds = function(inst, line, cast)
	if cast ~= nil then
		local bird1_castdata = cast["BIRD1"]
		if bird1_castdata ~= nil and bird1_castdata.castmember ~= nil then
			bird1_castdata.castmember:DoTaskInTime(0.1, bird_exit)
		end

		local bird2_castdata = cast["BIRD2"]
		if bird2_castdata ~= nil and bird2_castdata.castmember ~= nil then
			bird2_castdata.castmember:DoTaskInTime(0.3, bird_exit)
		end
	end
end
--------------------------------------------------------------------------------

local function push_acting(castmember, act_data)
	castmember:PushEvent("acting", act_data)
end

local CURTSY_DATA = {act = "curtsy"}
fns.actorscurtsey = function(inst, line, cast)
    if cast == nil then return end
	for costume, data in pairs(cast) do
		data.castmember:DoTaskInTime(0.1 + 0.4*math.random(), push_acting, CURTSY_DATA)
	end
end

local BOW_DATA = {act = "bow"}
fns.actorsbow = function(inst, line, cast)
    if cast == nil then return end
	for costume, data in pairs(cast) do
		data.castmember:DoTaskInTime(0.1 + 0.4*math.random(), push_acting, BOW_DATA)
	end
end
--------------------------------------------------------------------------------

local function spawn_timed_fx_onme(inst, fxname, time)
	if not inst:IsValid() then
		return
	end
    local fx = SpawnPrefab(fxname)
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetTime(time or FRAMES)
end

fns.marionetteon = function(inst, line, cast)
    if cast == nil then return end

    local duration = line.time or line.duration
    for costume, data in pairs(cast) do
        if costume ~= "BIRD1" and costume ~= "BIRD2" and costume ~= "NARRATOR" then
            data.castmember:DoTaskInTime(0.1 + 0.4*math.random(), spawn_timed_fx_onme, "marionette_appear_fx", duration)
        end
    end
end

fns.marionetteoff = function(inst, line, cast)
    if cast == nil then return end

    local duration = line.time or line.duration
    for costume, data in pairs(cast) do
        if costume ~= "BIRD1" and costume ~= "BIRD2" and costume ~= "NARRATOR" then
            data.castmember:DoTaskInTime(0.1 + 0.4*math.random(), spawn_timed_fx_onme, "marionette_disappear_fx", duration)
        end
    end
end
--------------------------------------------------------------------------------

fns.startbgmusic = function(inst, line, cast)
    if inst.SetMusicType ~= nil then
        inst:SetMusicType(line.musictype or 1)
    end
end

fns.stopbgmusic = function(inst, line, cast)
    if inst.SetMusicType ~= nil then
        inst:SetMusicType(0)
    end
end

--------------------------------------------------------------------------------

fns.stageon = function(inst)
	inst.sg:GoToState("narrator_on")
end

fns.stageoff = function(inst)
	inst.sg:GoToState("narrator_off")
end

fns.stinger = function(inst, line)
	inst.sg:GoToState("stinger", line.sound)
end

fns.findlucy = function(player)
	local lucys = player.components.inventory:GetItemByName("lucy",1, true)	
	
	local lucy = next(lucys)

	local handitem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
	if not lucy and handitem and handitem.prefab == "lucy" then
		lucy = handitem
	end
	return lucy
end

fns.lucytalk = function(inst, line, cast)
	if line.lucytest ~= nil and cast ~= nil then
		local castmember = cast[line.lucytest].castmember
		local lucy = fns.findlucy(castmember)
		if lucy then
			lucy.components.talker:Say(line.line)
		end
	end
end

fns.maskflash = function(inst, line, cast)
    if cast == nil then return end

	for costume, data in pairs(cast) do
		local player = data.castmember
		local light = 0
		local inc = 1/(30*line.time)

		player.AnimState:SetSymbolBloom("swap_hat")
		player.masktask = player:DoPeriodicTask(FRAMES, function()
			local mult = 0.7 * math.sin(light*PI)
			player.AnimState:SetSymbolAddColour("swap_hat", mult, mult, mult, 1)
			light = math.min(light + inc, 1)
			if light == 1 then
				player.AnimState:ClearSymbolBloom("swap_hat")
				if player.masktask then
					player.masktask:Cancel()
					player.masktask = nil
				end
			end
		end)
	end
end

local function cleanup_waxwell_dancer(inst, dancer)
	if dancer ~= nil and dancer:IsValid() then
		if dancer.sg ~= nil then
			dancer.sg:GoToState("quickdespawn")
		else
			dancer:Remove()
		end
	end
end

fns.waxwelldancer = function(inst, line, cast)
    if cast == nil then return end

	local caster_data = cast[line.caster]
    if caster_data == nil then return end

	local dancer = SpawnPrefab("shadowdancer")
	local x,y,z = inst.Transform:GetWorldPosition()
	local offset = Vector3FromTheta(line.theta, line.radius)
	dancer.Transform:SetPosition(x + offset.x, 0, z + offset.z)

	dancer.components.skinner:CopySkinsFromPlayer(caster_data.castmember)
	if dancer.sg ~= nil then
		dancer.sg:GoToState("quickspawn")
	end
	dancer:PushEvent("dance")

	inst:DoTaskInTime(line.time, cleanup_waxwell_dancer, dancer)
end

local COMMENTER_MUST = {"player"}
fns.crowdcomment = function(inst, line, cast)
    if cast == nil then return end

	local x,y,z = inst.Transform:GetWorldPosition()
	local actors = TheSim:FindEntities(x,y,z, 20, COMMENTER_MUST)

    -- Remove any nearby actors that are actually performing in the current play.
	for i=#actors,1,-1 do
		for costume, data in pairs(cast) do
			if data.castmember == actors[i] then
				table.remove(actors, i)
				break
			end
		end
	end

    -- Collect any nearby actors that are a prefab in the line's prefab list.
	local candidates = {}
	for _, actor in ipairs(actors) do
		for __, prefab in ipairs(line.prefabs) do
			if actor.prefab == prefab then
				table.insert(candidates, actor)
                break
			end
		end
	end

    -- If we found any candidates, pick one at random to perform a line.
	if #candidates > 0 then
		local chosen_actor = candidates[math.random(1,#candidates)]
		chosen_actor:PushEvent("perform_do_next_line", {anim = line.anim})
		if line.line then
			chosen_actor.components.talker:Say(line.line, line.duration)
		end
	else
		line.nopause = true
	end
end

fns.isplayercostume = function(costume)
	return costume ~= "BIRD1" and costume ~= "BIRD2" and costume ~= "NARRATOR"
end

fns.swapmask = function(inst, line, cast)
    if cast == nil then return end
	for _, costume in ipairs(line.roles) do
		local player = cast[costume].castmember
		if line.mask then
			local mask = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
			mask:Remove()
			local newmask = SpawnPrefab(line.mask)
			player.components.inventory:Equip(newmask)
		end
		if line.body then
			local body = player.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
			body:Remove()
			local newbody = SpawnPrefab(line.body)
			player.components.inventory:Equip(newbody)
		end
	end
end

local POSITIONS = {
	[1] = {theta = -PI/4,		radius = 1.5},	-- FRONT
	[2] = {theta = 0,			radius = 2},	-- LEFT
	[3] = {theta = 1.5*PI,		radius = 2.2},	-- RIGHT
	[4] = {theta = PI/2,		radius = 2},	-- BACK LEFT
	[5] = {theta = PI,			radius = 2},	-- BACK RIGHT
	[6] = {theta = -PI/4,		radius = 2.3},	-- FORE
	[7] = {theta = 0,			radius = 0},	-- CENTER
	[8] = {theta = (3/4)*PI,	radius = 3},	-- BACK
}

local function on_findposition_timeout(castmember)
    castmember.components.locomotor:SetReachDestinationCallback(nil)
    castmember.components.locomotor:Stop()
end

local function on_reached_findposition(inst)
    if inst._play_findposition_timeouttask ~= nil then
        inst._play_findposition_timeouttask:Cancel()
        inst._play_findposition_timeouttask = nil
    end
end

local function teleport_to_position(inst, new_pos)
    local current_pos = inst:GetPosition()
    SpawnPrefab("shadow_puff_solid").Transform:SetPosition(current_pos:Get())

    if current_pos:DistSq(new_pos) > 0.01 then
        SpawnPrefab("shadow_puff_solid").Transform:SetPosition(new_pos:Get())
    end

    if inst.Physics ~= nil then
        inst.Physics:Teleport(new_pos:Get())
    else
        inst.Transform:SetPosition(new_pos:Get())
    end
end

fns.findpositions = function(inst, line, cast)
    if cast == nil then return end

	local inst_pos = inst:GetPosition()
	for costume, position in pairs(line.positions) do
		local offset = Vector3FromTheta(POSITIONS[position].theta, POSITIONS[position].radius)
		cast[costume].target = inst_pos + offset
		cast[costume].position = inst_pos + offset

        local castmember = cast[costume].castmember
        if castmember ~= nil then
            if castmember.components.locomotor ~= nil then
                castmember.components.locomotor:SetReachDestinationCallback(on_reached_findposition)
                castmember.components.locomotor:GoToPoint(inst_pos + offset, nil, true)
                castmember._play_findposition_timeouttask = castmember:DoTaskInTime(line.duration or 0, on_findposition_timeout)
            else
                local line_length = 
                castmember:DoTaskInTime((line.duration or (2*FRAMES))/2, teleport_to_position, inst_pos+offset)
            end
        end
	end
end

return fns