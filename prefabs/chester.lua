local assets =
{
    Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),

    Asset("ANIM", "anim/chester.zip"),
    Asset("ANIM", "anim/chester_build.zip"),
    Asset("ANIM", "anim/chester_shadow_build.zip"),
    Asset("ANIM", "anim/chester_snow_build.zip"),

    Asset("SOUND", "sound/chester.fsb"),

    Asset("MINIMAP_IMAGE", "chester"),
    Asset("MINIMAP_IMAGE", "chestershadow"),
    Asset("MINIMAP_IMAGE", "chestersnow"),
}

local prefabs =
{
    "chester_eyebone",
    "chesterlight",
    "chester_transform_fx",
    "globalmapiconunderfog",
}

local brain = require "brains/chesterbrain"

local sounds =
{
    hurt = "dontstarve/creatures/chester/hurt",
    pant = "dontstarve/creatures/chester/pant",
    death = "dontstarve/creatures/chester/death",
    open = "dontstarve/creatures/chester/open",
    close = "dontstarve/creatures/chester/close",
    pop = "dontstarve/creatures/chester/pop",
    boing = "dontstarve/creatures/chester/boing",
    lick = "dontstarve/creatures/chester/lick",
}

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function ShouldKeepTarget()
    return false -- chester can't attack, and won't sleep if he has a target
end

local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end

local function OnClose(inst)
    if not inst.components.health:IsDead() and inst.sg.currentstate.name ~= "transition" then
        inst.sg:GoToState("close")
    end
end

-- eye bone was killed/destroyed
local function OnStopFollowing(inst)
    --print("chester - OnStopFollowing")
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    --print("chester - OnStartFollowing")
    inst:AddTag("companion")
end

local function SetBuild(inst)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        local state = ""
        if inst.ChesterState == "SHADOW" then
            state = "_shadow"
        elseif inst.ChesterState == "SNOW" then
            state = "_snow"
        end

        inst.AnimState:OverrideItemSkinSymbol("chester_body", skin_build, "chester_body" .. state, inst.GUID, "chester_build")
        inst.AnimState:OverrideItemSkinSymbol("chester_foot", skin_build, "chester_foot" .. state, inst.GUID, "chester_build")
        inst.AnimState:OverrideItemSkinSymbol("chester_lid", skin_build, "chester_lid" .. state, inst.GUID, "chester_build")
        inst.AnimState:OverrideItemSkinSymbol("chester_tongue", skin_build, "chester_tongue" .. state, inst.GUID, "chester_build")
    else
        inst.AnimState:ClearAllOverrideSymbols()

        if inst.ChesterState == "SHADOW" then
            inst.AnimState:SetBuild("chester_shadow_build")
        elseif inst.ChesterState == "SNOW" then
            inst.AnimState:SetBuild("chester_snow_build")
        else
            inst.AnimState:SetBuild("chester_build")
        end
    end
end

local function MorphShadowChester(inst)
    inst:AddTag("spoiler")
    inst.MiniMapEntity:SetIcon("chestershadow.png")
    inst.components.maprevealable:SetIcon("chestershadow.png")

    inst.components.container:WidgetSetup("shadowchester")

    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphShadowEyebone()
    end

    inst.ChesterState = "SHADOW"
    inst._isshadowchester:set(true)
    SetBuild(inst)
end

local function MorphSnowChester(inst)
    inst:AddTag("fridge")
    inst.MiniMapEntity:SetIcon("chestersnow.png")
    inst.components.maprevealable:SetIcon("chestersnow.png")

    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphSnowEyebone()
    end

    inst.ChesterState = "SNOW"
    inst._isshadowchester:set(false)
    SetBuild(inst)
end

--[[
local function MorphNormalChester(inst)
    inst.AnimState:SetBuild("chester_build")
    inst:RemoveTag("fridge")
    inst:RemoveTag("spoiler")
    inst.MiniMapEntity:SetIcon("chester.png")
    inst.components.maprevealable:SetIcon("chester.png")

    inst.components.container:WidgetSetup("chester")

    local leader = inst.components.follower.leader
    if leader ~= nil then
        inst.components.follower.leader:MorphNormalEyebone()
    end

    inst.ChesterState = "NORMAL"
    inst._isshadowchester:set(false)
end
--]]

local function CanMorph(inst)
    if inst.ChesterState ~= "NORMAL" or not TheWorld.state.isfullmoon then
        return false, false
    end

    local container = inst.components.container
    if container:IsOpen() then
        return false, false
    end

    local canShadow = true
    local canSnow = true

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item == nil then
            return false, false
        end

        canShadow = canShadow and item.prefab == "nightmarefuel"
        canSnow = canSnow and item.prefab == "bluegem"

        if not (canShadow or canSnow) then
            return false, false
        end
    end

    return canShadow, canSnow
end

local function CheckForMorph(inst)
    local canShadow, canSnow = CanMorph(inst)
    if canShadow or canSnow then
        inst.sg:GoToState("transition")
    end
end

local function DoMorph(inst, fn)
    inst.MorphChester = nil
    inst:StopWatchingWorldState("isfullmoon", CheckForMorph)
    inst:RemoveEventCallback("onclose", CheckForMorph)
    fn(inst)
end

local function MorphChester(inst)
    local canShadow, canSnow = CanMorph(inst)
    if not (canShadow or canSnow) then
        return
    end

    local container = inst.components.container
    for i = 1, container:GetNumSlots() do
        container:RemoveItem(container:GetItemInSlot(i)):Remove()
    end

    DoMorph(inst, canShadow and MorphShadowChester or MorphSnowChester)
end

local function OnSave(inst, data)
    data.ChesterState = inst.ChesterState
end

local function OnPreLoad(inst, data)
    if data == nil then
        return
    elseif data.ChesterState == "SHADOW" then
        DoMorph(inst, MorphShadowChester)
    elseif data.ChesterState == "SNOW" then
        DoMorph(inst, MorphSnowChester)
    end
end

local function OnIsShadowChesterDirty(inst)
    if inst._isshadowchester:value() ~= inst._clientshadowmorphed then
        inst._clientshadowmorphed = inst._isshadowchester:value()
        inst.replica.container:WidgetSetup(inst._clientshadowmorphed and "shadowchester" or nil)
    end
end

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        inst.components.hauntable.panic = true
        inst.components.hauntable.panictimer = TUNING.HAUNT_PANIC_TIME_SMALL
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function create_chester()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 75, .5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("chester")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")

    inst.MiniMapEntity:SetIcon("chester.png")
    inst.MiniMapEntity:SetCanUseCache(false)

    inst.AnimState:SetBank("chester")
    inst.AnimState:SetBuild("chester_build")

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

    inst._isshadowchester = net_bool(inst.GUID, "_isshadowchester", "onisshadowchesterdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst._clientshadowmorphed = false
        inst:ListenForEvent("onisshadowchesterdirty", OnIsShadowChesterDirty)
        return inst
    end

    ------------------------------------------
    inst:AddComponent("maprevealable")
    inst.components.maprevealable:SetIconPrefab("globalmapiconunderfog")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "chester_body")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("chester")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    MakeHauntableDropFirstItem(inst)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst.sounds = sounds

    inst:SetStateGraph("SGchester")
    inst.sg:GoToState("idle")

    inst:SetBrain(brain)

    inst.ChesterState = "NORMAL"
    inst.MorphChester = MorphChester
    inst:WatchWorldState("isfullmoon", CheckForMorph)
    inst:ListenForEvent("onclose", CheckForMorph)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.SetBuild = SetBuild

    return inst
end

return Prefab("chester", create_chester, assets, prefabs)
