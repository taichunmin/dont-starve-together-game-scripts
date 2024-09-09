
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"
local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/carnivalgame_puckdrop_station.zip"),
    Asset("ANIM", "anim/carnivalgame_puckdrop_floor.zip"),
    Asset("SCRIPT", "scripts/prefabs/carnivalgame_common.lua"),
}

local kit_assets =
{
    Asset("ANIM", "anim/carnivalgame_puckdrop_station.zip"),
}

local prefabs =
{
	"carnival_prizeticket",
}

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
	CreateFloorPart(parent, "carnivalgame_puckdrop_floor", "idle", "place")
end

local function OnBuilt(inst)
	inst.sg:GoToState("place")
end

local function PickCurrentDoor(inst)
	if inst._inactive_timeout ~= nil then
		inst._inactive_timeout:Cancel()
		inst._inactive_timeout = nil
	end
end

local function OnActivateGame(inst)
	inst.sg:GoToState("turn_on")
end

local MAX_SPIN_SPEED = 10

local function OnStartPlaying(inst)
	-- how long the player has to pick a door
	inst._inactive_timeout = inst:DoTaskInTime(TUNING.CARNIVALGAME_PUCKDROP_INACTIVE_TIMEOUT_MIN + math.random() * TUNING.CARNIVALGAME_PUCKDROP_INACTIVE_TIMEOUT_VAR, PickCurrentDoor)

	inst.sg:GoToState("cycle_doors")
	inst.components.activatable.inactive = true
	inst._current_game = math.random(5)

end

local function OnUpdateGame(inst)
	inst.components.minigame:RecordExcitement()
end

local function OnStopPlaying(inst)
	inst.components.activatable.inactive = false

	if inst._inactive_timeout ~= nil then
		inst._inactive_timeout:Cancel()
		inst._inactive_timeout = nil
	end

	return 0.5
end

local function spawnticket(inst)
	inst.components.lootdropper:SpawnLootPrefab("carnival_prizeticket")
	inst:ActivateRandomCannon()
end

local function SpawnRewards(inst)
	inst.sg:GoToState("gameover") 

	local delay = inst.AnimState:GetCurrentAnimationLength() + 0.1

	for i = 1, inst._minigame_score do
		inst:DoTaskInTime(delay + 0.25 * i, spawnticket)
	end

	return inst._minigame_score == 0 and delay or (delay + 0.25 * inst._minigame_score)
end

local function OnDeactivateGame(inst)
	inst.sg:GoToState("turn_off") 
	
	inst.components.activatable.inactive = false

	if inst._inactive_timeout ~= nil then
		inst._inactive_timeout:Cancel()
		inst._inactive_timeout = nil
	end
end

local function RemoveGameItems(inst)

end

local function OnRemoveGame(inst)

end

local function station_onhit(inst, worker)
	if inst._minigametask == nil then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle_off", false) -- todo: handle doors
	end
end

local function station_OnPress(inst, doer)
	if inst.components.minigame:GetIsPlaying() then 
		PickCurrentDoor(inst)
	end

	return true
end

function GetActivateVerb(inst)
	return "WHEELSPIN_STOP"
end

local function station_common_postinit(inst)
	inst.MiniMapEntity:SetIcon("carnivalgame_puckdrop_station.png")

	inst.AnimState:SetBank("carnivalgame_puckdrop_station")
	inst.AnimState:SetBuild("carnivalgame_puckdrop_station")
	inst.AnimState:PlayAnimation("idle_off")

	inst.GetActivateVerb = GetActivateVerb

	inst._camerafocus_dist_min = nil
	inst._camerafocus_dist_max = nil

	if not TheNet:IsDedicated() then
		CreateFlooring(inst, true)
	end
end

local function station_master_postinit(inst)
	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = station_OnPress
	inst.components.activatable.inactive = false
    inst.components.activatable.quickaction = true

	inst.components.minigame._spectator_rewards_score = 14

	inst.components.minigame.spectator_dist =		TUNING.CARNIVALGAME_PUCKDROP_ARENA_RADIUS + 6
	inst.components.minigame.participator_dist =	TUNING.CARNIVALGAME_PUCKDROP_ARENA_RADIUS + 6
	inst.components.minigame.watchdist_min =		TUNING.CARNIVALGAME_PUCKDROP_ARENA_RADIUS + 0
	inst.components.minigame.watchdist_target =		TUNING.CARNIVALGAME_PUCKDROP_ARENA_RADIUS + 1
	inst.components.minigame.watchdist_max =		TUNING.CARNIVALGAME_PUCKDROP_ARENA_RADIUS + 3

	inst.components.workable:SetOnWorkCallback(station_onhit)

	inst._current_door = 1

	-- template carnival game setup
	--inst._game_duration = 5
	inst._spawn_rewards_delay = 1
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

    inst:SetStateGraph("SGcarnivalgame_puckdrop_station")

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
		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 4.25, CARNIVALGAMEPART_TAG) == 0
	end,
}

return Prefab("carnivalgame_puckdrop_station", station_fn, assets, prefabs),
		MakeDeployableKitItem("carnivalgame_puckdrop_kit", "carnivalgame_puckdrop_station", "carnivalgame_puckdrop_station", "carnivalgame_puckdrop_station", "kit_item", kit_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.MED_FUEL}, deployable_data),
		MakePlacer("carnivalgame_puckdrop_kit_placer", "carnivalgame_puckdrop_station", "carnivalgame_puckdrop_station", "idle_off", nil, nil, nil, nil, 90, nil, CreateFlooring)
