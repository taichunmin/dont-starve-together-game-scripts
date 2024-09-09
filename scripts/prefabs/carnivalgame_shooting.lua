
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"

local assets =
{
    Asset("ANIM", "anim/carnivalgame_shooting_target.zip"),
    Asset("ANIM", "anim/carnivalgame_shooting_station.zip"),
    Asset("ANIM", "anim/carnivalgame_shooting_floor.zip"),
    Asset("ANIM", "anim/carnivalgame_shooting_arrow.zip"),

    Asset("SCRIPT", "scripts/prefabs/carnivalgame_common.lua"),
}

local button_assets =
{
	Asset("ANIM", "anim/carnivalgame_shooting_button.zip"),
}

local projectile_assets =
{
    Asset("ANIM", "anim/carnivalgame_shooting_projectile.zip"),
}

local projectile_prefabs =
{
    "carnivalgame_shooting_projectile_fx",
}

local kit_assets =
{
    Asset("ANIM", "anim/carnivalgame_shooting_station.zip"),
}

local prefabs =
{
	"carnivalgame_shooting_target",
	"carnivalgame_shooting_button",
	"carnivalgame_shooting_projectile",
	"carnival_prizeticket",
}

local TARGET_POINTS = {}
local function create_target_points()
	local rot = 5.5 * DEGREES
	local r = TUNING.CARNIVALGAME_SHOOTING_TARGET_ARC_R
	for i = -3, 3 do
		local sin_rot = math.sin(rot * i) * TUNING.CARNIVALGAME_SHOOTING_TARGET_ARC_X
		local cos_rot = math.cos(rot * i)
		table.insert(TARGET_POINTS, Vector3(r * cos_rot, 0, r * sin_rot))
	end
end
create_target_points()

local BUTTON_OFFSET = Vector3(-2, 0, 0)

local function CreateStationFloor(parent)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carnivalgame_shooting_floor")
	inst.AnimState:SetBuild("carnivalgame_shooting_floor")
	inst.AnimState:PlayAnimation("station_idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.Transform:SetRotation(-90)

	inst.entity:SetParent(parent.entity)
	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation("station_place") inst.AnimState:PushAnimation("station_idle", false) end, parent)
end

local function CreateTargetFloor(parent)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carnivalgame_shooting_floor")
	inst.AnimState:SetBuild("carnivalgame_shooting_floor")
	inst.AnimState:PlayAnimation("targets_idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.entity:SetParent(parent.entity)
	inst.Transform:SetPosition(9.9, 0, 0)
	inst.Transform:SetRotation(-90)
	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation("targets_place") inst.AnimState:PushAnimation("targets_idle", false) end, parent)
end

local function CreateTargetingArrow(parent)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carnivalgame_shooting_arrow")
	inst.AnimState:SetBuild("carnivalgame_shooting_arrow")
	inst.AnimState:PlayAnimation("idle_off")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-1)

	inst.entity:SetParent(parent.entity)
	inst.Transform:SetPosition(0, 0, 0)

	inst.cur_state = 0

	parent:ListenForEvent("onremove", function(i) i.targeting_arrow = nil end, inst)

	return inst
end

local function CreateShootingContollerPlacer(parent)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carnivalgame_shooting_button")
	inst.AnimState:SetBuild("carnivalgame_shooting_button")
	inst.AnimState:PlayAnimation("off")

	local x, y, z = inst.Transform:GetWorldPosition()
	local _x, _z = VecUtil_RotateDir(BUTTON_OFFSET.x, BUTTON_OFFSET.z, inst.Transform:GetRotation() * DEGREES)
	inst.Transform:SetPosition(x + _x, y, z + _z)

	inst.entity:SetParent(parent.entity)
	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation("place") end, parent)

	return inst
end

local function OnBuilt(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
	local rot = data ~= nil and data.rot or 0
	inst.Transform:SetRotation(rot)

	-- Spawn target points
    for i, v in ipairs(TARGET_POINTS) do
        local target = inst.components.objectspawner:SpawnObject("carnivalgame_shooting_target")
		local _x, _z = VecUtil_RotateDir(v.x, v.z, -rot*DEGREES)
        target.Transform:SetPosition(x + _x, 0, z + _z)
		target.sg:GoToState("place")
    end

	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_off", false)

	inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/place")
end

local function target_turnon(target)
	target:PushEvent("carnivalgame_turnon")
end

local function OnActivateGame(inst)
	inst.AnimState:PlayAnimation("turn_on")
	inst.AnimState:ClearOverrideSymbol("carnivalgame_ms_number")

	inst.SoundEmitter:PlaySound("turn_on")
	inst:DoTaskInTime(26*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/memory/LP", "loop") end)

	for i, target in ipairs(inst.components.objectspawner.objects) do
		target:DoTaskInTime(math.random() * 0.5, target_turnon)
		target._shouldturnoff = false
	end

	if inst.button:IsValid() then
		inst.button._shouldturnoff = false
		target_turnon(inst.button)
	end

	inst.components.carnivalgameshooter:Initialize()
	inst._arrow_state:set(1)
	if inst.targeting_arrow ~= nil then
		-- local host
		inst.targeting_arrow.AnimState:PlayAnimation("turn_on")
		inst.targeting_arrow.AnimState:PushAnimation("idle_on", true)
		inst.targeting_arrow.Transform:SetRotation((TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN + TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX)/2)
	end
end

local function DoNextRound(inst)
	inst._round_delay = nil

	inst._round_num = inst._round_num + 1

	inst.add_friendly_target = inst._round_num >= 3
	if inst.add_friendly_target then
		local friendly_target_index = math.random(#inst.components.objectspawner.objects)
		for i, target in ipairs(inst.components.objectspawner.objects) do
			if i == friendly_target_index then
				inst._picked_friendlies[target] = true
				target:PushEvent("carnivalgame_target_startround", {isactivated = true, isfriendlytarget = true})
			elseif not (i + 1 == friendly_target_index or i - 1 == friendly_target_index) then
				inst._picked_enemies[target] = true
				target:PushEvent("carnivalgame_target_startround", {isactivated = true, isfriendlytarget = false})
			end
		end
	else
		local randomized_targets = {}
		for i = 1, #inst.components.objectspawner.objects do
			randomized_targets[i] = inst.components.objectspawner.objects[i]
		end
		shuffleArray(randomized_targets)
		local num_enemies_to_pick = math.ceil(#randomized_targets / 2)
		for i = 1, num_enemies_to_pick do
			local target = randomized_targets[i]
			inst._picked_enemies[target] = true
			target:PushEvent("carnivalgame_target_startround", {isactivated = true, isfriendlytarget = false})
		end
	end
end

local function DoEndOfRound(inst, success)
	for target in pairs(inst._picked_enemies) do
		target:PushEvent("carnivalgame_endofround")
	end
	for target in pairs(inst._picked_friendlies) do
		target:PushEvent("carnivalgame_endofround")
	end
	inst:PushEvent("carnivalgame_endofround")

	inst._picked_enemies = {}
	inst._picked_friendlies = {}
	
	local delay = success and 1 or 3
	if not success then
		inst:DoTaskInTime(0*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/caw_single") end)
		inst:DoTaskInTime(13*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/caw_single") end)
		inst:DoTaskInTime(26*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/caw_single") end)
		inst:DoTaskInTime(39*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/caw_single") end)
		inst:DoTaskInTime(52*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/caw_single") end)
		inst:DoTaskInTime(65*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/caw_single") end)
		inst.AnimState:PlayAnimation("hit_wrong_target")
		inst.AnimState:PushAnimation("hit_wrong_target", false)
		inst.AnimState:PushAnimation("hit_wrong_target", false)
		inst.AnimState:PushAnimation("idle_on")
	end
	
	inst.SoundEmitter:KillSound("caw_loop")

	inst._round_delay = inst:DoTaskInTime(delay, DoNextRound)
end

local function Server_OnUpdateAiming(inst, dt)
	local angle, meterdirection = inst.components.carnivalgameshooter:UpdateAiming(dt)

	inst._arrow_state:set(meterdirection == 1 and 2 or 3)

	if inst.targeting_arrow ~= nil then
		inst.targeting_arrow.Transform:SetRotation(angle)
	end
end

local function OnStartPlaying(inst)
	inst.AnimState:PushAnimation("turn_on", false)
	inst.AnimState:PushAnimation("idle_on", true)

	inst._round_num = 0
	inst.add_friendly_target = false
	inst._picked_enemies = {}
	inst._picked_friendlies = {}
	DoNextRound(inst)

	inst.components.updatelooper:AddOnWallUpdateFn(Server_OnUpdateAiming)
	Server_OnUpdateAiming(inst, 0)
end

local function OnUpdateGame(inst)

end

local function RemoveGameItems(inst)
end

local function spawnticket(inst)
	inst.components.lootdropper:SpawnLootPrefab("carnival_prizeticket")
	inst:ActivateRandomCannon()

end

local function SpawnRewards(inst)
	for i = 1, inst._minigame_score do
		inst:DoTaskInTime(0.25 * i, spawnticket)
	end

	inst.AnimState:PlayAnimation("spawn_rewards", true)
	--inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/spawn_rewards", "rewards_loop")
           

	return 0.25 * inst._minigame_score
end

local function OnStopPlaying(inst)
	inst.AnimState:PlayAnimation("spawn_rewards", true)
		inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/spawn_rewards", "rewards_loop")

	inst.SoundEmitter:KillSound("loop")

	inst._picked_enemies = {}
	inst._picked_friendlies = {}

	if inst._round_delay ~= nil then
		inst._round_delay:Cancel()
		inst._round_delay = nil
	end

	local function turnoff_target(target)
		target:PushEvent("carnivalgame_turnoff")
	end

	for i, target in ipairs(inst.components.objectspawner.objects) do
		target._shouldturnoff = true
		target:DoTaskInTime(math.random() * 0.25, turnoff_target)
	end

	if inst.button:IsValid() then
		inst.button._shouldturnoff = true
		turnoff_target(inst.button)
	end

	inst.components.updatelooper:RemoveOnWallUpdateFn(Server_OnUpdateAiming)
	inst._arrow_state:set(0)
	if inst.targeting_arrow ~= nil then
		inst.targeting_arrow.AnimState:PlayAnimation("turn_off")
		inst.targeting_arrow.AnimState:PushAnimation("idle_off", false)
	end

	return 1 -- delay before spawning rewards
end

local function OnDeactivateGame(inst)
	inst.AnimState:PlayAnimation("turn_off")
	inst.AnimState:PushAnimation("idle_off", false)

	inst._picked_enemies = {}
	inst._picked_friendlies = {}

	inst.SoundEmitter:KillSound("rewards_loop")
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/spawn_rewards_endbell")

	for i, target in ipairs(inst.components.objectspawner.objects) do
		target._shouldturnoff = true
		target.sg:GoToState("idle_off")
	end

	if inst.button:IsValid() then
		inst.button._shouldturnoff = true
		inst.button.sg:GoToState("idle_off")
	end

	inst.components.updatelooper:RemoveOnWallUpdateFn(Server_OnUpdateAiming)
	inst._arrow_state:set(0)
	if inst.targeting_arrow ~= nil then
		inst.targeting_arrow.AnimState:PlayAnimation("idle_off", false)
	end

	if inst._round_delay ~= nil then
		inst._round_delay:Cancel()
		inst._round_delay = nil
	end

end

local function OnRemoveGame(inst)
	for i, target in ipairs(inst.components.objectspawner.objects) do
        target:Remove()
    end
end

-------------------------------------------------------------------------------
-- STATION

local PROJECTILE_HIT_MUSTTAGS = {"carnivalgame_target"}

local function OnShotHit(inst, projectile)
	-- Look for targets at the point of impact
	local x, y, z = projectile.Transform:GetWorldPosition()
	local radius = 2
	local ents = TheSim:FindEntities(x, y, z, radius, PROJECTILE_HIT_MUSTTAGS)
    for i, target in ipairs(ents) do
		if inst._picked_enemies[target] or inst._picked_friendlies[target] then
			target:PushEvent("carnivalgame_shooting_target_hit")
		end
	end
end

local function station_NewObject(inst, obj)
	local function on_target_hit(target)
		if inst._picked_enemies[target] then
			inst._picked_enemies[target] = nil

			inst:ScorePoints()

			if next(inst._picked_enemies) == nil then
				DoEndOfRound(inst, true)
			end
		elseif inst._picked_friendlies[target] then
			inst._picked_friendlies[target] = nil

			DoEndOfRound(inst, false)
		end
	end

	inst:ListenForEvent("carnivalgame_shooting_target_hit", on_target_hit, obj)
end


local function Client_OnUpdateAiming(inst, dt)
	if inst.targeting_arrow ~= nil and inst._arrow_state:value() >= 2  then
		local angle = inst.targeting_arrow.Transform:GetRotation()

		angle = angle + dt * TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_SPEED * inst.targeting_arrow._meterdirection
		if angle <= TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN then
			angle = TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN
		elseif angle >= TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX then
			angle = TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX
		end

		inst.targeting_arrow.Transform:SetRotation(angle)
	end
end

local function OnArrowStateDirty(inst)
	if inst.targeting_arrow ~= nil then
		local prev_state = inst.targeting_arrow.cur_state
		local state = inst._arrow_state:value()
		inst.targeting_arrow.cur_state = state

		if state == 0 then -- turn off
			if prev_state ~= 0 then
				inst.targeting_arrow.AnimState:PlayAnimation("turn_off")
				inst.targeting_arrow.AnimState:PushAnimation("idle_off", false)
				inst.components.updatelooper:RemoveOnWallUpdateFn(Client_OnUpdateAiming)
			end
		elseif state == 1 then
			if prev_state == 0 then -- turn on
				inst.targeting_arrow.AnimState:PlayAnimation("turn_on")
				inst.targeting_arrow.AnimState:PushAnimation("idle_on", true)
				inst.targeting_arrow.Transform:SetRotation((TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN + TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX)/2)
				inst.targeting_arrow._meterdirection = 1
				inst.components.updatelooper:AddOnWallUpdateFn(Client_OnUpdateAiming)
			end
		else
			inst.targeting_arrow._meterdirection = state == 2 and 1 or -1
		end

	end
end

local function station_common_postinit(inst)
	inst.MiniMapEntity:SetIcon("carnivalgame_shooting_station.png")

	inst.AnimState:SetBank("carnivalgame_shooting_station")
	inst.AnimState:SetBuild("carnivalgame_shooting_station")
	inst.AnimState:PlayAnimation("idle_off")

	inst.Transform:SetEightFaced()

	if not TheNet:IsDedicated() then
		CreateStationFloor(inst)
		CreateTargetFloor(inst)

		inst.targeting_arrow = CreateTargetingArrow(inst)
	end

	if not TheWorld.ismastersim then
        inst:ListenForEvent("_arrow_state_dirty", OnArrowStateDirty)
	end

    inst:AddComponent("updatelooper") -- used by client and server

    inst._arrow_state = net_tinybyte(inst.GUID, "carnivalgame_shooting._arrow_state", "_arrow_state_dirty")
    inst._arrow_state:set(0) 
	-- 0 = off
	-- 1 = on - at 0 degrees
	-- 2 = move +1	
	-- 3 = move -1
end

local function station_master_postinit(inst)
	inst.components.minigame.spectator_dist =		TUNING.CARNIVALGAME_SHOOTING_ARENA_RADIUS + 8
	inst.components.minigame.participator_dist =	TUNING.CARNIVALGAME_SHOOTING_ARENA_RADIUS + 3
	inst.components.minigame.watchdist_min =		TUNING.CARNIVALGAME_SHOOTING_ARENA_RADIUS + 0
	inst.components.minigame.watchdist_target =		TUNING.CARNIVALGAME_SHOOTING_ARENA_RADIUS + 3
	inst.components.minigame.watchdist_max =		TUNING.CARNIVALGAME_SHOOTING_ARENA_RADIUS + 6

    inst:AddComponent("objectspawner")
    inst.components.objectspawner.onnewobjectfn = station_NewObject

	inst:AddComponent("carnivalgameshooter")
	inst.components.carnivalgameshooter:Initialize()

	-- spawn the button
    local button = SpawnPrefab("carnivalgame_shooting_button")
	button.entity:SetParent(inst.entity)
    button.Transform:SetPosition(BUTTON_OFFSET:Get())
	button:ListenForEvent("onbuilt", function() button.AnimState:PlayAnimation("place") end, inst)
	inst:ListenForEvent("carnivalgame_shooting_shoot", function(b) 
		if inst._round_delay == nil and inst.components.minigame:GetIsPlaying() then 
			inst.components.carnivalgameshooter:Shoot() 
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/shoot")
			--inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/spawn_rewards_endbell")
			inst.AnimState:PlayAnimation("shoot")
			inst.AnimState:PushAnimation("idle_on", true)

			b.AnimState:PlayAnimation("press")
			b.AnimState:PushAnimation("idle_on", true)
		else
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/button_press")
		end 
	end, button)
	inst.button = button

	-- template carnival game setup
	--inst._game_duration = 5
	inst._turnon_time = 1
	inst.lightdelay_turnon = 5 * FRAMES
	inst.lightdelay_turnoff = 6 * FRAMES

	inst.OnActivateGame = OnActivateGame
	inst.OnStartPlaying = OnStartPlaying
	inst.OnUpdateGame = OnUpdateGame
	inst.OnStopPlaying = OnStopPlaying
	inst.SpawnRewards = SpawnRewards
	inst.OnDeactivateGame = OnDeactivateGame
	inst.RemoveGameItems = RemoveGameItems
	inst.OnRemoveGame = OnRemoveGame

	inst:ListenForEvent("onbuilt", OnBuilt)
	inst:ListenForEvent("onshothit", OnShotHit, inst)
end

local function station_fn()
	return CARNIVALGAME_COMMON.CarnivalStationFn(station_common_postinit, station_master_postinit)
end

local CARNIVALGAMEPART_TAG = {"carnivalgame_part"}
local deployable_data =
{
	deploymode = DEPLOYMODE.CUSTOM,
	custom_candeploy_fn = function(inst, pt, mouseover, deployer, rot)
		local x, y, z = pt:Get()
		local sin_rot = math.sin(-rot * DEGREES)
		local cos_rot = math.cos(-rot * DEGREES)
		for i = 1, #TARGET_POINTS do
			local _x, _y, _z = TARGET_POINTS[i]:Get()
			local __x, __z = x + _x * cos_rot - _z * sin_rot, z + _z * cos_rot + _x * sin_rot
			if not TheWorld.Map:IsAboveGroundAtPoint(__x, 0, __z, false) or TheSim:CountEntities(__x, 0, __z, 3, CARNIVALGAMEPART_TAG) > 0 then
				return false
			end
		end

		local _x, _y, _z = BUTTON_OFFSET:Get()
		if not TheWorld.Map:IsAboveGroundAtPoint(x + _x * cos_rot - _z * sin_rot, 0, z + _z * cos_rot + _x * sin_rot, false) or TheSim:CountEntities(x + _x * cos_rot - _z * sin_rot, 0, z + _z * cos_rot + _x * sin_rot, 3, CARNIVALGAMEPART_TAG) > 0 then
			return false
		end

		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 4, CARNIVALGAMEPART_TAG) == 0
	end,
}

local function createplacertarget()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

	inst.AnimState:SetBuild("carnivalgame_shooting_target")
    inst.AnimState:SetBank("carnivalgame_shooting_target")
    inst.AnimState:PlayAnimation("off")

    return inst
end

local function placerdecor(inst)
	for i = 1, #TARGET_POINTS do
        local target = createplacertarget()
        target.Transform:SetPosition(TARGET_POINTS[i]:Get())
        target.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(target)
	end

	CreateStationFloor(inst)
	CreateTargetFloor(inst)
	CreateShootingContollerPlacer(inst)
end

-------------------------------------------------------------------------------
-- button

local function button_GetStatus(inst)
	return not inst._shouldturnoff and "PLAYING" or nil
end

local function GetActivateVerb()
    return "BUTTON"
end

local function displaynamefn_button(inst)
    return inst.AnimState:IsCurrentAnimation("off") and STRINGS.NAMES.CARNIVALGAME_SHOOTING_BUTTON_OFF or STRINGS.NAMES.CARNIVALGAME_SHOOTING_BUTTON
end

local function button_OnPress(inst)
	inst:PushEvent("carnivalgame_shooting_shoot")
	inst.components.activatable.inactive = true
	return true
end

local function button_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBuild("carnivalgame_shooting_button")
    inst.AnimState:SetBank("carnivalgame_shooting_button")
    inst.AnimState:PlayAnimation("off")


	MakeSnowCoveredPristine(inst)

	inst:SetPhysicsRadiusOverride(0.5)

	inst:AddTag("birdblocker")
	inst:AddTag("scarytoprey")

	inst.GetActivateVerb = GetActivateVerb
	inst.displaynamefn = displaynamefn_button

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst._shouldturnoff = true

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = button_GetStatus

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = button_OnPress
	inst.components.activatable.inactive = false
    inst.components.activatable.quickaction = true

	MakeSnowCovered(inst)

    inst:SetStateGraph("SGcarnivalgame_shooting_button")

	inst.persists = false

    return inst
end

-------------------------------------------------------------------------------
-- TARGET

local function target_GetStatus(inst)
	return not inst._shouldturnoff and "PLAYING" or nil
end

local function displaynamefn_target(inst)
    return inst.AnimState:IsCurrentAnimation("off") and STRINGS.NAMES.CARNIVALGAME_SHOOTING_TARGET_OFF or STRINGS.NAMES.CARNIVALGAME_SHOOTING_TARGET
end

local function targetfn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBuild("carnivalgame_shooting_target")
    inst.AnimState:SetBank("carnivalgame_shooting_target")
    inst.AnimState:PlayAnimation("off")

	MakeSnowCoveredPristine(inst)

	inst:SetPhysicsRadiusOverride(0.5)

	inst:AddTag("birdblocker")
	inst:AddTag("scarytoprey")
	inst:AddTag("carnivalgame_part")
	inst:AddTag("carnivalgame_target")

	inst.GetActivateVerb = GetActivateVerb
	inst.displaynamefn = displaynamefn_target

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst._shouldturnoff = true

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = target_GetStatus

	MakeSnowCovered(inst)

    inst:SetStateGraph("SGcarnivalgame_shooting_target")

    return inst
end

-------------------------------------------------------------------------------
-- PROJECTILE

local function self_destruct(inst)
	SpawnPrefab("carnivalgame_shooting_projectile_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end

local function onthrown(inst)
	inst:ListenForEvent("carnivalgame_endofround", function() inst:DoTaskInTime(0.2 + math.random() * 0.6, self_destruct) end, inst.shooter)
end

local function projectile_OnHit(inst, attacker, target)
	if inst.shooter ~= nil and inst.shooter:IsValid() then
		inst.shooter:PushEvent("onshothit", inst)
	end

	SpawnPrefab("carnivalgame_shooting_projectile_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function projectilefn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
	inst.Physics:SetMass(1)
	inst.Physics:SetFriction(0)
	inst.Physics:SetDamping(0)
	inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
	inst.Physics:SetCapsule(0.2, 0.2)

	--projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")
    --inst:AddTag("weapon")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("carnivalgame_shooting_projectile")
    inst.AnimState:SetBuild("carnivalgame_shooting_projectile")
    inst.AnimState:PlayAnimation("spin_loop", true)

    if not TheNet:IsDedicated() then
        inst:AddComponent("groundshadowhandler")
        inst.components.groundshadowhandler:SetSize(1.5, 0.75)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    --inst:AddComponent("locomotor")

	--inst:AddComponent("weapon")
	--inst.components.weapon:SetDamage(0)
    --inst.components.weapon:SetRange(8, 10)

    inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(projectile_OnHit)


    return inst
end

return Prefab("carnivalgame_shooting_target", targetfn, assets),
		Prefab("carnivalgame_shooting_projectile", projectilefn, projectile_assets, projectile_prefabs),
		Prefab("carnivalgame_shooting_station", station_fn, assets, prefabs),
		Prefab("carnivalgame_shooting_button", button_fn, button_assets),
		MakeDeployableKitItem("carnivalgame_shooting_kit", "carnivalgame_shooting_station", "carnivalgame_shooting_station", "carnivalgame_shooting_station", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, deployable_data),
		MakePlacer("carnivalgame_shooting_kit_placer", "carnivalgame_shooting_station", "carnivalgame_shooting_station", "placer", nil, nil, nil, nil, 180, "eight", placerdecor, 2)
