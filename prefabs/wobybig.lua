local assets =
{
    Asset("ANIM", "anim/woby_big_build.zip"),
    Asset("ANIM", "anim/woby_big_transform.zip"),
    Asset("ANIM", "anim/woby_big_travel.zip"),
    Asset("ANIM", "anim/woby_big_mount_travel.zip"),
    Asset("ANIM", "anim/woby_big_mount_basic.zip"),
    Asset("ANIM", "anim/woby_big_actions.zip"),
    Asset("ANIM", "anim/woby_big_basic.zip"),
    Asset("ANIM", "anim/woby_big_boat_jump.zip"),

    Asset("ANIM", "anim/ui_woby_3x3.zip"),

    Asset("ANIM", "anim/pupington_woby_build.zip"),
    Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
    "wobysmall",
}

local brain = require("brains/wobybigbrain")

local function ClearBuildOverrides(inst, animstate)
    local basebuild = "woby_big_build"
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild(basebuild)
    end
    -- this presumes that all the face builds have the same symbols
    animstate:ClearOverrideBuild(basebuild)
end

-- This takes an anim state so that it can apply to itself, or to its rider
local function ApplyBuildOverrides(inst, animstate)
    local basebuild = "woby_big_build"
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end
end

local function TriggerTransformation(inst)
    if inst.sg.currentstate.name ~= "transform" and not inst.transforming then
        inst.persists = false
        inst:AddTag("NOCLICK")
        inst.transforming = true

        inst.components.rideable.canride = false

        if inst.components.container:IsOpen() then
            inst.components.container:Close()
        end

        if inst.components.rideable:IsBeingRidden() then
            --SG won't handle "transformation" event while we're being ridden
            --SG is forced into transformation state AFTER dismounting (OnRiderChanged)
            inst.components.rideable:Buck(true)
        else
            inst:PushEvent("transform")
        end
    end
end

local function SetRunSpeed(inst, speed)
    if speed == nil then
        return
    end

    inst.components.locomotor.runspeed = speed
    local rider = inst.components.rideable:GetRider()
    if rider and rider.player_classified ~= nil then
        rider.player_classified.riderrunspeed:set(speed)
    end
end

local function OnHungerDelta(inst, data)
    if data.newpercent >= 0.7 then
        SetRunSpeed(inst, TUNING.WOBY_BIG_SPEED.FAST)
    elseif data.newpercent >= 0.33 then
        SetRunSpeed(inst, TUNING.WOBY_BIG_SPEED.MEDIUM)
    else
        SetRunSpeed(inst, TUNING.WOBY_BIG_SPEED.SLOW)
    end
end

local function OnStarving(inst)
    TriggerTransformation(inst)
end

local function DoRiderSleep(inst, sleepiness, sleeptime)
    inst._ridersleeptask = nil
end

local function OnRiderChanged(inst, data)

    if inst._ridersleeptask ~= nil then
        inst._ridersleeptask:Cancel()
        inst._ridersleeptask = nil
    end

    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end

    if inst.components.hunger:GetPercent() <= 0 then
        if inst.sg.currentstate.name ~= "transform" then
            -- The SG won't listen for the event right now, so we wait a frame
            inst:DoTaskInTime(0, function() inst:PushEvent("transform") end)
        end
    end
end

local function OnRiderSleep(inst, data)
    inst._ridersleep = inst.components.rideable:IsBeingRidden() and {
        time = GetTime(),
        sleepiness = data.sleepiness,
        sleeptime = data.sleeptime,
    } or nil
end

local function LinkToPlayer(inst, player)
    inst._playerlink = player
    inst.components.follower:SetLeader(player)

    inst:ListenForEvent("onremove", inst._onlostplayerlink, player)
end

local function OnPlayerLinkDespawn(inst)
	if inst.components.container ~= nil then
		inst.components.container:Close()
		inst.components.container.canbeopened = false

		if GetGameModeProperty("drop_everything_on_despawn") then
			inst.components.container:DropEverything()
		else
			inst.components.container:DropEverythingWithTag("irreplaceable")
		end
	end

	if inst.components.drownable ~= nil then
		inst.components.drownable.enabled = false
	end

	local fx = SpawnPrefab(inst.spawnfx)
	fx.entity:SetParent(inst.entity)

	inst.components.colourtweener:StartTween({ 0, 0, 0, 1 }, 13 * FRAMES, inst.Remove)

	if not inst.sg:HasStateTag("busy") then
		inst.sg:GoToState("despawn")
	end
end

local function FinishTransformation(inst)
    local items = inst.components.container:RemoveAllItems()
	local player = inst._playerlink
    local new_woby = ReplacePrefab(inst, "wobysmall")

    for i,v in ipairs(items) do
        new_woby.components.container:GiveItem(v)
    end

	if player ~= nil then
		new_woby:LinkToPlayer(player)
	    player:OnWobyTransformed(new_woby)
	end
end

local WAKE_TO_FOLLOW_DISTANCE = 6
local SLEEP_NEAR_LEADER_DISTANCE = 5

local function IsLeaderSleeping(inst)
    return inst.components.follower.leader and inst.components.follower.leader:HasTag("sleeping")
end

local function IsLeaderTellingStory(inst)
    local leader = inst.components.follower.leader
    return leader and leader.components.storyteller and leader.components.storyteller:IsTellingStory()
end

local function ShouldWakeUp(inst)
    return not (IsLeaderSleeping(inst) or IsLeaderTellingStory(inst)) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return (IsLeaderSleeping(inst) or IsLeaderTellingStory(inst)) and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("wobybig")
    inst.AnimState:SetBuild("woby_big_build")

    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("HEAT")

    inst:AddTag("animal")
    inst:AddTag("largecreature")
    inst:AddTag("woby")
    inst:AddTag("handfed")
    inst:AddTag("fedbyall")
    inst:AddTag("dogrider_only")
    inst:AddTag("peacefulmount")

    inst:AddTag("companion")

    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MONSTER }, { FOODTYPE.MONSTER })
    inst.components.eater:SetAbsorptionModifiers(4,1,1)

    inst:AddComponent("inspectable")

    inst:AddComponent("follower")
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true

    inst:AddComponent("rideable")
    inst.components.rideable:SetShouldSave(false)
    inst.components.rideable.canride = true

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = ShouldSleep
    inst.components.sleeper.waketestfn = ShouldWakeUp

    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.WOBY_BIG_HUNGER)
    inst.components.hunger:SetRate(TUNING.WOBY_BIG_HUNGER_RATE)
    inst.components.hunger:SetOverrideStarveFn(OnStarving)

    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.WOBY_BIG_WALK_SPEED
    SetRunSpeed(inst, TUNING.WOBY_BIG_SPEED.FAST)
    inst.components.locomotor:SetAllowPlatformHopping(true)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("wobybig")

    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

	inst:AddComponent("colourtweener")

    MakeHauntablePanic(inst)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwobybig")

    inst.persists = false

	inst.spawnfx = "spawn_fx_medium"

    inst:ListenForEvent("riderchanged", OnRiderChanged)
    inst:ListenForEvent("hungerdelta", OnHungerDelta)
    inst:ListenForEvent("ridersleep", OnRiderSleep)

    inst.LinkToPlayer = LinkToPlayer
	inst.OnPlayerLinkDespawn = OnPlayerLinkDespawn
	inst._onlostplayerlink = function(player) inst._playerlink = nil end


    inst.FinishTransformation = FinishTransformation

    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides

    return inst
end

return Prefab("wobybig", fn, assets, prefabs)