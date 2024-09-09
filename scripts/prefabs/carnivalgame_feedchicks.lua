
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"

local assets =
{
    Asset("ANIM", "anim/carnivalgame_feedchicks_bird.zip"),
    Asset("ANIM", "anim/carnivalgame_feedchicks_station.zip"),
    Asset("ANIM", "anim/carnivalgame_feedchicks_floor.zip"),
    Asset("SCRIPT", "scripts/prefabs/carnivalgame_common.lua"),
}

local kit_assets =
{
    Asset("ANIM", "anim/carnivalgame_feedchicks_station.zip"),
}

local food_assets =
{
    Asset("ANIM", "anim/carnivalgame_feedchicks_food.zip"),
}

local prefabs =
{
	"carnivalgame_feedchicks_nest",
	"carnivalgame_feedchicks_food",
	"carnival_prizeticket",
}

local NEST_POINTS = {}
local function create_nest_points()
	local num_outer_nests = 12
    local rot = (360/num_outer_nests) * DEGREES
	local rot_offset = 45 * DEGREES + rot / 2
    for i = 1, num_outer_nests do
		local sin_rot = math.sin(rot_offset + rot * i)
		local cos_rot = math.cos(rot_offset + rot * i)
		local r = 2.75 + 1
		table.insert(NEST_POINTS, Vector3(r * cos_rot - r * sin_rot, 0, r * cos_rot + r * sin_rot))
    end

    rot = (360/(num_outer_nests/2)) * DEGREES
	rot_offset = 45 * DEGREES + rot / 2
    for i = 1, (num_outer_nests/2) do
		local sin_rot = math.sin(rot_offset + rot * i)
		local cos_rot = math.cos(rot_offset + rot * i)
		local r = 2.75
		table.insert(NEST_POINTS, Vector3(r * cos_rot - r * sin_rot, 0, r * cos_rot + r * sin_rot))
    end
end
create_nest_points()

local function CreateFloor(parent)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carnivalgame_feedchicks_floor")
	inst.AnimState:SetBuild("carnivalgame_feedchicks_floor")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.entity:SetParent(parent.entity)
	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation("place") inst.AnimState:PushAnimation("idle", false) end, parent)

	return inst
end

local function OnBuilt(inst, data)
	local rot = data ~= nil and data.rot or 0
	inst.Transform:SetRotation(rot)

    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(NEST_POINTS) do
        local nest = inst.components.objectspawner:SpawnObject("carnivalgame_feedchicks_nest")
		local _x, _z = VecUtil_RotateDir(v.x, v.z, -rot*DEGREES)
        nest.Transform:SetPosition(x + _x, 0, z + _z)
		nest.sg:GoToState("place")
    end

	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("idle_off", false)

	inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/place")
end


local function DoActivateRandomNest(inst, delay)
	local function activate_nest(nest)
		nest:PushEvent("carnivalgame_feedchicks_hungry")--, {duration = TUNING.CARNIVALGAME_FEEDCHICKS_HUNGRY_DURATION + math.random() * TUNING.CARNIVALGAME_FEEDCHICKS_HUNGRY_DURATION_VAR})
	end

	if next(inst._avaiablenests) ~= nil then
		local nest = GetRandomKey(inst._avaiablenests)
		inst._avaiablenests[nest] = nil
		inst._num_avaiablenests = inst._num_avaiablenests - 1

		nest:DoTaskInTime(delay, activate_nest)
	end
end

local function nest_turnon(nest)
	nest:PushEvent("carnivalgame_turnon")
end

local function OnActivateGame(inst)
	inst.AnimState:PlayAnimation("turn_on")
	inst.AnimState:PushAnimation("idle_on", true)
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/turnon")
	--inst:DoTaskInTime(26*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/turnon", "turnon_loop") end)

	inst._avaiablenests = {}
	inst._num_avaiablenests = 0
	for i, nest in ipairs(inst.components.objectspawner.objects) do
		nest:DoTaskInTime(math.random() * 0.5, nest_turnon)

		inst._avaiablenests[nest] = true
		inst._num_avaiablenests = inst._num_avaiablenests + 1
		nest._shouldturnoff = false
		nest:RemoveComponent("inspectable")
	end

	for i = 1, TUNING.CARNIVALGAME_FEEDCHICKS_NUM_FOOD do
		local food = SpawnPrefab("carnivalgame_feedchicks_food")
		table.insert(inst.fooditems, food)
		inst.components.lootdropper:FlingItem(food)
	end
end

local function OnStartPlaying(inst)
	for i = 1, TUNING.CARNIVALGAME_FEEDCHICKS_NUM_ACTIVE do
		DoActivateRandomNest(inst, i/4 + math.random() * 0.3)
	end
end

local function OnUpdateGame(inst)
	local num_active_nests = #inst.components.objectspawner.objects - inst._num_avaiablenests
	if num_active_nests < TUNING.CARNIVALGAME_FEEDCHICKS_NUM_ACTIVE then
		local delay = 0.25 + math.random()*2
		DoActivateRandomNest(inst, delay)
		
	end
end

local function RemoveGameItems(inst)
	if inst.fooditems ~= nil then
		for i = 1, #inst.fooditems do
			local food = inst.fooditems[i]
			if food:IsValid() then
				if not food:IsInLimbo() then
					SpawnPrefab("dirt_puff").Transform:SetPosition(food.Transform:GetWorldPosition())
				end
				food:Remove()
			end
		end
	end

	inst.fooditems = {}
end

local function OnStopPlaying(inst)
	inst.AnimState:PlayAnimation("spawn_rewards_pre")
	inst.AnimState:PushAnimation("spawn_rewards_loop", true)
	inst:DoTaskInTime(15*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/spawnrewards") end)
	inst:DoTaskInTime(25*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/endbell") end)
	inst:DoTaskInTime(35*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/endbell") end)
	inst:DoTaskInTime(45*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/endbell") end)
	inst:DoTaskInTime(55*FRAMES, function(i) i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/endbell") end)

	local function turnoff_nest(nest)
		nest:PushEvent("carnivalgame_turnoff")
	end

	shuffleArray(inst.components.objectspawner.objects)
	for i, nest in ipairs(inst.components.objectspawner.objects) do
		nest._shouldturnoff = true
		nest:DoTaskInTime(math.random() * 0.25, turnoff_nest)
	end

	return 0.5 -- delay before spawning rewards
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

	--inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/spawnrewards_pst")
	inst:DoTaskInTime(10*FRAMES, function(i) if i:IsValid() then i.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/turnoff") end end)

	for i, nest in ipairs(inst.components.objectspawner.objects) do
		nest._shouldturnoff = true
		if nest.components.inspectable == nil then
			nest:AddComponent("inspectable")
		end
	end

	for i, nest in ipairs(inst.components.objectspawner.objects) do
		nest.sg:GoToState("idle_off")
	end
end

local function NewObject(inst, obj)
	local function onfeed(nest)
		inst:ScorePoints(inst)
	end
	local function onnestavailable(nest)
		inst._avaiablenests[nest] = true
		inst._num_avaiablenests = inst._num_avaiablenests + 1
	end
    inst:ListenForEvent("carnivalgame_feedchicks_feed", onfeed, obj)
    inst:ListenForEvent("carnivalgame_feedchicks_available", onnestavailable, obj)
end

local function OnRemoveGame(inst)
	for i, nest in ipairs(inst.components.objectspawner.objects) do
        nest:Remove()
    end
end

local function station_common_postinit(inst)
	inst.MiniMapEntity:SetIcon("carnivalgame_feedchicks_station.png")

	inst.AnimState:SetBank("carnivalgame_feedchicks_station")
	inst.AnimState:SetBuild("carnivalgame_feedchicks_station")
	inst.AnimState:PlayAnimation("idle_off")

	if not TheNet:IsDedicated() then
		CreateFloor(inst)
	end
end

local function station_master_postinit(inst)
	inst._avaiablenests = {}
	inst._num_avaiablenests = 0

	inst.components.minigame.spectator_dist =		TUNING.CARNIVALGAME_FEEDCHICKS_ARENA_RADIUS + 8
	inst.components.minigame.participator_dist =	TUNING.CARNIVALGAME_FEEDCHICKS_ARENA_RADIUS + 8
	inst.components.minigame.watchdist_min =		TUNING.CARNIVALGAME_FEEDCHICKS_ARENA_RADIUS + 0
	inst.components.minigame.watchdist_target =		TUNING.CARNIVALGAME_FEEDCHICKS_ARENA_RADIUS + 3
	inst.components.minigame.watchdist_max =		TUNING.CARNIVALGAME_FEEDCHICKS_ARENA_RADIUS + 6

    inst:AddComponent("objectspawner")
    inst.components.objectspawner.onnewobjectfn = NewObject

	-- template carnival game setup
	--inst._game_duration = 10
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
		for i = 1, #NEST_POINTS do
			local _x, _y, _z = NEST_POINTS[i]:Get()
			local sin_rot = math.sin(-rot * DEGREES)
			local cos_rot = math.cos(-rot * DEGREES)
			if not TheWorld.Map:IsAboveGroundAtPoint(x + _x * cos_rot - _z * sin_rot, 0, z + _z * cos_rot + _x * sin_rot, false) then
				return false
			end
		end

		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 8.5, CARNIVALGAMEPART_TAG) == 0
	end,
}

local function createplacernest()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

	inst.AnimState:SetBuild("carnivalgame_feedchicks_bird")
    inst.AnimState:SetBank("carnivalgame_feedchicks_bird")
    inst.AnimState:PlayAnimation("off")

    return inst
end

local function placerdecor(inst)
	for i = 1, #NEST_POINTS do
        local nest = createplacernest()
        nest.Transform:SetPosition(NEST_POINTS[i]:Get())
        nest.entity:SetParent(inst.entity)
        inst.components.placer:LinkEntity(nest)
	end

	CreateFloor(inst)
end

local function onfeed_nest(inst)
	inst:PushEvent("carnivalgame_feedchicks_feed")
	return true
end

local function displaynamefn_nest(inst)
    return inst.AnimState:IsCurrentAnimation("off") and STRINGS.NAMES.CARNIVALGAME_FEEDCHICKS_NEST_OFF or STRINGS.NAMES.CARNIVALGAME_FEEDCHICKS_NEST
end

local function nestfn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBuild("carnivalgame_feedchicks_bird")
    inst.AnimState:SetBank("carnivalgame_feedchicks_bird")
    inst.AnimState:PlayAnimation("idle")


	MakeSnowCoveredPristine(inst)

	inst:AddTag("birdblocker")
	inst:AddTag("carnivalgame_part")

	inst.displaynamefn = displaynamefn_nest
	inst:SetPhysicsRadiusOverride(0.75)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst._shouldturnoff = true

	inst:AddComponent("inspectable")

	inst:AddComponent("carnivalgamefeedable")
	inst.components.carnivalgamefeedable.OnFeed = onfeed_nest

	MakeSnowCovered(inst)

    inst:SetStateGraph("SGcarnivalgame_feedchicks_nest")

    return inst
end

local function food_onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_item", inst.GUID, "swap_item")
    else
        owner.AnimState:OverrideSymbol("swap_object", "carnivalgame_feedchicks_food", "swap_item")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function food_onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function fooditem_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("carnivalgame_feedchicks_food")
    inst.AnimState:SetBuild("carnivalgame_feedchicks_food")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, {1.1, 0.5, 1.1}, true, -9)

	inst:AddTag("nopunch")
	inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst:AddComponent("inspectable")

	inst:AddComponent("carnivalgameitem")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(food_onequip)
    inst.components.equippable:SetOnUnequip(food_onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("carnivalgame_feedchicks_food", fooditem_fn, food_assets),
		Prefab("carnivalgame_feedchicks_nest", nestfn, assets),
		Prefab("carnivalgame_feedchicks_station", station_fn, assets, prefabs),
		MakeDeployableKitItem("carnivalgame_feedchicks_kit", "carnivalgame_feedchicks_station", "carnivalgame_feedchicks_station", "carnivalgame_feedchicks_station", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, deployable_data),
		MakePlacer("carnivalgame_feedchicks_kit_placer", "carnivalgame_feedchicks_station", "carnivalgame_feedchicks_station", "idle_off", nil, nil, nil, nil, 90, nil, placerdecor)
