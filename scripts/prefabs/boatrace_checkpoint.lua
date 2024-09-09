require "prefabutil"
local boatrace_common = require("prefabs/boatrace_common")

local assets =
{
    Asset("ANIM", "anim/boatrace_checkpoint.zip"),
    Asset("ANIM", "anim/boatrace_checkpoint_ribbon.zip"),
    Asset("SCRIPT", "scripts/prefabs/boatrace_common.lua"),
    Asset("MINIMAP_IMAGE", "boatrace_checkpoint"),

    Asset("ANIM", "anim/yotc_carrat_race_checkpoint_colour_swaps.zip"),
}

local ribbon_assets =
{
    Asset("ANIM", "anim/yotb_post_ribbons.zip"),
}

local prefabs =
{
    "boatrace_checkpoint_flag",
}

local function ToggleLight(inst, turn_on)
    if turn_on then
        inst.SoundEmitter:PlaySound("yotd2024/checkpoint/idle","fireloop")
    else
        inst.SoundEmitter:KillSound("fireloop")
    end

    if inst._lights_on ~= turn_on then
        inst._lights_on = turn_on
        inst.Light:Enable(turn_on)
        inst.AnimState:SetLightOverride((turn_on and 0.8) or 0)
        inst.AnimState:PushAnimation((turn_on and "idle_on") or "idle_off", true)
    end
end

-- Work callbacks
local function OnWork(inst)
    if not inst.AnimState:IsCurrentAnimation("place") then
        inst.AnimState:PlayAnimation((inst._lights_on and "hit_on") or "hit_off")
        inst.AnimState:PushAnimation((inst._lights_on and "idle_on") or "idle_off", true)
    end
end

local function OnWorkFinished(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

--
local function SetStartPoint(inst, startpoint)
    local entitytracker = inst.components.entitytracker
    entitytracker:ForgetEntity("startpoint")
    if startpoint then
        entitytracker:TrackEntity("startpoint", startpoint)
    end
end

--
local function OnBuilt(inst, data)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_off", true)
    inst.SoundEmitter:PlaySound("yotd2024/checkpoint/place")
    inst:ToggleLight(false)
end

--
local function setflag(inst, id)
    local rand = math.random(1,#inst.flag_positions)
    local position = inst.flag_positions[rand]
    table.remove(inst.flag_positions,rand)

    inst.SoundEmitter:PlaySound("yotd2024/checkpoint/checkpoint_medal_place")

    if not inst.flags then
        inst.flags = {}
    end

    local flag = SpawnPrefab("boatrace_checkpoint_flag")
    flag.AnimState:OverrideSymbol("ribbon1", "boatrace_checkpoint_ribbon", "ribbon"..id)
    flag.AnimState:PlayAnimation("ribbon_pre",false)
    flag.AnimState:PushAnimation("ribbon_loop",true)
    flag.entity:SetParent(inst.entity)
    flag.Follower:FollowSymbol(inst.GUID, "ribbon_marker"..position, nil, nil, nil, true)
    flag.components.highlightchild:SetOwner(inst)

    return flag
end

-- Race callbacks
local function OnBeaconAtCheckpoint(inst, beacon)
    local startpoint = inst.components.entitytracker:GetEntity("startpoint")
    if not beacon or inst._found_beacons[beacon] or not startpoint or not startpoint._beacons then
        return
    end

    inst._found_beacons[beacon] = setflag(inst, beacon._index)
    inst.AnimState:PlayAnimation((inst._lights_on and "hit_on") or "hit_off")
    inst.AnimState:PushAnimation((inst._lights_on and "idle_on") or "idle_off", true)

    beacon:PushEvent("checkpoint_found")
        
    startpoint:PushEvent("beacon_reached_checkpoint", {
        beacon = beacon,
        checkpoint = inst,
    })

end

local function OnRaceStartTimerEnd(inst)
    inst.components.boatrace_proximitychecker:OnStartRace()
end

local function OnRaceStarted(inst)
    inst.components.workable:SetWorkable(false)
    inst:ToggleLight(true)
end

local function ResetCheckpoint(inst)
    inst.AnimState:PlayAnimation((inst._lights_on and "hit_on") or "hit_off")
    inst.AnimState:PushAnimation((inst._lights_on and "idle_on") or "idle_off", true)

    if GetTableSize(inst._found_beacons) > 0 then
        for _, flag in pairs(inst._found_beacons) do
            flag.AnimState:PlayAnimation("ribbon_pst")
        end
    end

    inst.components.workable:SetWorkable(true)

    inst:ToggleLight(false)

    inst._found_beacons = {}

    inst.flag_positions = {1,2,3,4,5,6,7,8}
end


local function OnRaceOver(inst)
    SetStartPoint(inst, nil)
    inst:DoTaskInTime(1 + math.random(), ResetCheckpoint)
end
local function registercheckpoint(inst)
    local manager = TheWorld.components.yotd_raceprizemanager
    if manager then
        manager:RegisterCheckpoint(inst)
    end
end

local function Onremoved(inst)
    local manager = TheWorld.components.yotd_raceprizemanager
    if manager then
        manager:UnregisterCheckpoint(inst)
    end
end

--
local DEPLOYHELPER_KEYFILTERS = {"boatrace_start", "boatrace_checkpoint"}
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("boatrace_checkpoint.png")

    MakeWaterObstaclePhysics(inst, 0.4, 2, 0.75)

    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("boatracecheckpoint")
    inst:AddTag("boatrace_proximitychecker")
    inst:AddTag("structure")

    inst.AnimState:SetBank("boatrace_checkpoint")
    inst.AnimState:SetBuild("boatrace_checkpoint")
    inst.AnimState:PlayAnimation("idle_off", true)

    inst.AnimState:OverrideSymbol("flames", "boatrace_start", "flames")
    inst.AnimState:OverrideSymbol("water_fx_ripple", "boatrace_start", "water_fx_ripple")
    inst.AnimState:OverrideSymbol("water_shadow", "boatrace_start", "water_shadow")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetRadius(1.5)
    inst.Light:SetColour(200/255, 100/255, 170/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    boatrace_common.AddDeployHelper(inst, DEPLOYHELPER_KEYFILTERS)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.flag_positions = {1,2,3,4,5,6,7,8}

    --
    inst.ToggleLight = ToggleLight

    --
    inst._lights_on = false
    inst._found_beacons = {}

    --
    local boatrace_proximitychecker = inst:AddComponent("boatrace_proximitychecker")
    boatrace_proximitychecker.on_found_beacon = OnBeaconAtCheckpoint

    --
    inst:AddComponent("entitytracker")

    --
    inst:AddComponent("inspectable")

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetLoot({"boatrace_checkpoint_throwable_deploykit"})

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnWorkCallback(OnWork)
    workable:SetOnFinishCallback(OnWorkFinished)
    --
    MakeHauntableWork(inst)

    --
    inst:ListenForEvent("onbuilt", OnBuilt)
    inst:ListenForEvent("boatrace_start", OnRaceStarted)
    inst:ListenForEvent("boatrace_starttimerended", OnRaceStartTimerEnd)
    inst:ListenForEvent("boatrace_finish", OnRaceOver)
    inst:ListenForEvent("onremove", Onremoved)

    inst.SetStartPoint = SetStartPoint

    registercheckpoint(inst)

    return inst
end

local function flagfn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst:AddTag("FX")

    inst.AnimState:SetBank("boatrace_checkpoint")
    inst.AnimState:SetBuild("boatrace_checkpoint")
    inst.AnimState:PlayAnimation("ribbon_loop", true)

    inst:AddComponent("highlightchild")

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("ribbon_pst") then
            inst:Remove()
        end
    end)

    inst.persists = false

    return inst
end

--
local function throwable_kit_validityfn(inst, doer, pos)
	return boatrace_common.CheckpointSpawnCheck(pos)
end
local THROWABLE_KIT_DATA = {
    bank = "boatrace_checkpoint",
    anim = "kit_ground",
    prefab_to_deploy = "boatrace_checkpoint",

    extradeploytest = throwable_kit_validityfn,

    do_reticule_ring = true,
    reticule_ring_scale = 0.3,
}

local ThrowableKit, ThrowableKitReticule = boatrace_common.MakeThrowableBoatRaceKitPrefabs(THROWABLE_KIT_DATA)
return Prefab("boatrace_checkpoint", fn, assets, prefabs),
    ThrowableKit,
    ThrowableKitReticule,
    Prefab("boatrace_checkpoint_flag", flagfn, assets)