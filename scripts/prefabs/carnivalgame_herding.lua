
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"

local assets =
{
    Asset("ANIM", "anim/carnivalgame_herding_station.zip"),
    Asset("ANIM", "anim/carnivalgame_herding_floor.zip"),
    Asset("SCRIPT", "scripts/prefabs/carnivalgame_common.lua"),
}

local kit_assets =
{
    Asset("ANIM", "anim/carnivalgame_herding_station.zip"),
}

local chick_assets =
{
    Asset("ANIM", "anim/carnivalgame_herding_chick.zip"),
}

local prefabs =
{
	"carnivalgame_herding_chick",
	"carnival_prizeticket",
	"carnivalgame_placementblocker",
}

local chick_prefabs =
{
	"carnival_confetti_fx",
}

local NUM_CHICKS = 12

local function CreateFloorPart(parent, bank, anim, deploy_anim, offset, rot)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")
	inst:AddTag("carnivalgame_part")

	inst.AnimState:SetBank(bank)
	inst.AnimState:SetBuild(bank)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.AnimState:PlayAnimation(anim)

	inst.entity:SetParent(parent.entity)

	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	if offset ~= nil then
		inst.Transform:SetPosition(offset:Get())
	end
	if rot ~= nil then
		inst.Transform:SetRotation(rot)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation(deploy_anim) inst.AnimState:PushAnimation(anim, false) end, parent)

	return inst
end

local function CreateFlooring(parent)
	CreateFloorPart(parent, "carnivalgame_herding_floor", "idle", "place")

	local r = 8
	for i = 0, 7 do
		CreateFloorPart(parent, "carnivalgame_herding_floor", "ring", "place_ring", Vector3(r * math.sin(i * 45*DEGREES), 0, r * math.cos(i * 45*DEGREES)), 180 + 45 * i)
	end
end

local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("idle_off", true)
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/place")
end

local function SpawnNewChick(inst, launch_angle)
	local function chick_ongothome(chick)
		inst:ScorePoints(inst)
		inst:DoTaskInTime(math.random() * 0.5 + 0.5, function() SpawnNewChick(inst) end)
	end
	local function chick_onremoved(chick)
		inst.chicks[chick] = nil
	end

	inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/launch")

	if inst.components.minigame:GetIsOutro() then
		return -- the game is shutting down, so don't spawn more
	end

	local home_pt = inst:GetPosition()

	local chick = SpawnPrefab("carnivalgame_herding_chick")
	chick.Transform:SetPosition(home_pt:Get())
	chick.components.knownlocations:RememberLocation("home", home_pt)

	chick.sg:GoToState("launched")

	--local launched_angle = Launch2(chick, inst, 7, 3, 2, 1, 10)
	local launched_angle = Launch2(chick, inst, 4, 5, 2, 1, 15 + math.random(), launch_angle)
	chick.Transform:SetRotation(launched_angle * RADIANS)

	inst.chicks[chick] = true

	inst:ListenForEvent("carnivalgame_herding_gothome", chick_ongothome, chick)
	inst:ListenForEvent("onremove", chick_onremoved, chick)
end

local function OnActivateGame(inst)
	inst.AnimState:PlayAnimation("turn_on", false)
	inst.AnimState:PushAnimation("on", true)
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/turn_on")
	inst:DoTaskInTime(18*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/LP", "on_loop") end)
end

local function OnStartPlaying(inst)
	for i = 1, NUM_CHICKS do
		inst:DoTaskInTime(i * 1 / NUM_CHICKS, SpawnNewChick)
	end

end

local function OnUpdateGame(inst)

end

local function OnStopPlaying(inst)
	inst.AnimState:PlayAnimation("spawn_rewards_pre")
	inst.AnimState:PushAnimation("spawn_rewards_loop", true)

	inst.SoundEmitter:KillSound("on_loop")
	inst:DoTaskInTime(15*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/rewards_LP", "rewards_loop") end)

	local function turnoff_chick(chick)
		chick:PushEvent("carnivalgame_turnoff")
	end

	for chick, _ in pairs(inst.chicks) do
		chick._shouldturnoff = true
		chick:DoTaskInTime(math.random() * 1, turnoff_chick)
	end

	return 2
end

local function spawnticket(inst)
	inst.components.lootdropper:SpawnLootPrefab("carnival_prizeticket")
	inst:ActivateRandomCannon()
end

local function SpawnRewards(inst)
	for i = 1, inst._minigame_score do
		inst:DoTaskInTime(0.25 * i, spawnticket)
	end

	return 0.25 * inst._minigame_score
end

local function OnDeactivateGame(inst)
	inst.AnimState:PlayAnimation("spawn_rewards_pst", false)
	inst.AnimState:PushAnimation("turn_off", false)
	inst.AnimState:PushAnimation("idle_off", true)

	inst.SoundEmitter:KillSound("rewards_loop")
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/endbell")
	inst:DoTaskInTime(10*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/turn_off") end)

	for chick, _ in pairs(inst.chicks) do
		if not chick.sg:HasStateTag("death") then
			chick.sg:GoToState("turn_off")
		end
	end
	inst.chicks = {}
end

local function RemoveGameItems(inst)
	if inst._round_delay ~= nil then
		inst._round_delay:Cancel()
		inst._round_delay = nil
	end
end

local function OnRemoveGame(inst)

end

local function station_common_postinit(inst)
	inst.MiniMapEntity:SetIcon("carnivalgame_herding_station.png")

	inst.AnimState:SetBank("carnivalgame_herding_station")
	inst.AnimState:SetBuild("carnivalgame_herding_station")
	inst.AnimState:PlayAnimation("idle_off")

	inst:AddTag("carnivalgame_herding_station")

	inst._camerafocus_dist_min = nil
	inst._camerafocus_dist_max = nil

	if not TheNet:IsDedicated() then
		CreateFlooring(inst, true)
	end
end

local function station_master_postinit(inst)
	inst.components.minigame.spectator_dist =		TUNING.CARNIVALGAME_HERDING_ARENA_RADIUS + 8
	inst.components.minigame.participator_dist =	TUNING.CARNIVALGAME_HERDING_ARENA_RADIUS + 8
	inst.components.minigame.watchdist_min =		TUNING.CARNIVALGAME_HERDING_ARENA_RADIUS + 0
	inst.components.minigame.watchdist_target =		TUNING.CARNIVALGAME_HERDING_ARENA_RADIUS + 3
	inst.components.minigame.watchdist_max =		TUNING.CARNIVALGAME_HERDING_ARENA_RADIUS + 6

	-- template carnival game setup
	--inst._game_duration = 5
	inst._spawn_rewards_delay = 1
	inst.lightdelay_turnon = 5 * FRAMES
	inst.lightdelay_turnoff = 6 * FRAMES

	inst.chicks = {}

	inst.OnActivateGame = OnActivateGame
	inst.OnStartPlaying = OnStartPlaying
	inst.OnUpdateGame = OnUpdateGame
	inst.OnStopPlaying = OnStopPlaying
	inst.SpawnRewards = SpawnRewards
	inst.OnDeactivateGame = OnDeactivateGame
	inst.RemoveGameItems = RemoveGameItems
	inst.OnRemoveGame = OnRemoveGame


	local r = 6.5
	for i = 0, 7 do
		CARNIVALGAME_COMMON.CreateGameBlocker(inst, r * math.sin(i * 45*DEGREES), r * math.cos(i * 45*DEGREES))
	end

	inst:ListenForEvent("onbuilt", OnBuilt)
end

local function station_fn()
	return CARNIVALGAME_COMMON.CarnivalStationFn(station_common_postinit, station_master_postinit)
end

local CARNIVALGAMEPART_TAG = {"carnivalgame_part"}
local deployable_data =
{
	deploymode = DEPLOYMODE.CUSTOM,
	custom_candeploy_fn = function(inst, pt, mouseover, deployer)
		local x, y, z = pt:Get()
		local r = 7
		for i = 0, 7 do
			if not TheWorld.Map:IsAboveGroundAtPoint(x + r * math.sin(i * 45*DEGREES), 0, z + r * math.cos(i * 45*DEGREES), false) then
				return false
			end
		end

		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 10, CARNIVALGAMEPART_TAG) == 0
	end,
}

-------------------------------------------------------------------------------
local chick_brain = require("brains/carnivalgame_herding_chick_brain")

local function update_chick(inst)
	if inst.components.locomotor ~= nil and inst:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("home")) < 2*2 then
		inst:PushEvent("carnivalgame_herding_arivedhome")
	end
end

local function OnLaunchLanded(inst)
	local x, y, z = inst.Transform:GetWorldPosition()

	if not TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
		SinkEntity(inst)
		return
	end

	ChangeToCharacterPhysics(inst)

	inst.Transform:SetPosition(x, 0, z)

	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = 4
	inst.components.locomotor.runspeed = 7
end

local function chick_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	MakeProjectilePhysics(inst, 1, 0.5)

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("carnivalgame_herding_chick")
    inst.AnimState:SetBuild("carnivalgame_herding_chick")
    inst.AnimState:PlayAnimation("idle", true)

	inst.DynamicShadow:SetSize(.8, .5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    MakeHauntable(inst)

    inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/LP", "active_loop") -- this will be on until it dies, the stategraph will handling turning it off

	inst:SetStateGraph("SGcarnivalgame_herding_chick")
	inst:SetBrain(chick_brain)

	inst:DoPeriodicTask(0.1, update_chick)
	inst.OnLaunchLanded = OnLaunchLanded

    return inst
end

return Prefab("carnivalgame_herding_station", station_fn, assets, prefabs),
		Prefab("carnivalgame_herding_chick", chick_fn, chick_assets, chick_prefabs),
		MakeDeployableKitItem("carnivalgame_herding_kit", "carnivalgame_herding_station", "carnivalgame_herding_station", "carnivalgame_herding_station", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.MED_FUEL}, deployable_data),
		MakePlacer("carnivalgame_herding_kit_placer", "carnivalgame_herding_station", "carnivalgame_herding_station", "idle_off", nil, nil, nil, nil, 90, nil, CreateFlooring)
