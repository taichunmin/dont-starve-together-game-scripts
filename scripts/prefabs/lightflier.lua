local assets =
{
    Asset("ANIM", "anim/lightflier.zip"),
}

local prefabs =
{
    "formationleader",
}

local brain = require "brains/lightflierbrain"

SetSharedLootTable( "lightflier",
{
    {"lightbulb",    1},
})

local FORMATION_ROTATION_SPEED = 0.9
local FORMATION_RADIUS = 4.1
local FORMATION_SEARCH_RADIUS = 8
local FORMATION_MAX_SPEED = 10.5
local FORMATION_MAX_OFFSET = 0.4
local FORMATION_OFFSET_LERP = 0.2
local FORMATION_MAX_DELTA_SQ = 16*16

local VALIDATE_FORMATION_FREQ = 1

-- Used for testing distance to home when leaving formation.
-- If not within the threshold the lightflier is detached
-- from the childspawner.
local RETURN_HOME_MAX_DIST_SQ = 28*28

local FIND_TARGET_RADIUS = 9
local FIND_TARGET_FREQUENCY = 1
local FIND_TARGET_MUSTTAGS = { "player" }
local FIND_TARGET_NOTAGS = { "playerghost" }--, "FX", "NOCLICK", "DECOR", "INLIMBO" }

local FORMATION_TAGS = { "formationleader_lightflier" }

local MakeFormation

local function is_lightflier(item)
    return item.prefab == "lightflier"
end

local function LeaderOnUpdate(inst)
    local leader = inst.components.formationleader
    if leader.target ~= nil and leader.target:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local tx, ty, tz = leader.target.Transform:GetWorldPosition()

        if VecUtil_LengthSq(tx - x, tz - z) > FORMATION_MAX_DELTA_SQ then
            leader:DisbandFormation()
            return
        end

        local r = -(leader.target.Transform:GetRotation() / RADIANS)

        local targetoffsetdistance = leader.target.components.locomotor.walkspeed * (leader.target.components.locomotor.wantstomoveforward and FORMATION_MAX_OFFSET or 0)
        local targetoffset_x = tx + math.cos(r) * targetoffsetdistance
        local targetoffset_z = tz + math.sin(r) * targetoffsetdistance

        -- inst._offset is initialized in MakeFormation()
        inst._offset.x = Lerp(inst._offset.x, targetoffset_x, FORMATION_OFFSET_LERP)
        inst._offset.z = Lerp(inst._offset.z, targetoffset_z, FORMATION_OFFSET_LERP)

        inst.Transform:SetPosition(inst._offset.x, ty, inst._offset.z)
    end
end

local function findtargettest(target)
    return target.components.inventory ~= nil
        and target.components.inventory:FindItem(is_lightflier) ~= nil
        and target._lightflier_formation == nil
end

local function LeaderValidateFormation(inst)
    local target = inst.components.formationleader.target
    if not (target ~= nil and target:IsValid() and target.components.inventory ~= nil and target.components.inventory:FindItem(is_lightflier)) then
        inst.components.formationleader:DisbandFormation()
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local leaders = TheSim:FindEntities(x, y, z, FORMATION_SEARCH_RADIUS + FORMATION_RADIUS, inst.components.formationleader.formationleadersearchtags)

    local formationsize = GetTableSize(inst.components.formationleader.formation)
    if formationsize > 1 then
        if inst._formation_distribution_toggle then
            inst._formation_distribution_toggle = false

            for i, v in ipairs(leaders) do
                if v ~= inst and formationsize - 1 > GetTableSize(v.components.formationleader.formation) then
                    local distributed_member = next(inst.components.formationleader.formation)
                    inst.components.formationleader:OnLostFormationMember(distributed_member)
                    v.components.formationleader:NewFormationMember(distributed_member)
                end
            end
        else
            inst._formation_distribution_toggle = true

            local players = TheSim:FindEntities(x, y, z, FORMATION_SEARCH_RADIUS + FORMATION_RADIUS, FIND_TARGET_MUSTTAGS, FIND_TARGET_NOTAGS)
            for _, player in ipairs(players) do
                if findtargettest(player) then
                    local is_followed = false

                    for _, leader in ipairs(leaders) do
                        if leader.components.formationleader.target == player then
                            is_followed = true
                            break
                        end
                    end

                    if not is_followed then
                        local distributed_member = next(inst.components.formationleader.formation)
                        inst.components.formationleader:OnLostFormationMember(distributed_member)
                        MakeFormation(distributed_member, player)
                        return
                    end
                end
            end
        end
    end
end

local function FollowerOnUpdate(inst, targetpos)
    if not inst.brain.stopped then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dist = VecUtil_Length(targetpos.x - x, targetpos.z - z)

        inst.components.locomotor.walkspeed = math.min(dist * 8, FORMATION_MAX_SPEED)
        inst:FacePoint(targetpos.x, 0, targetpos.z)
        if inst.updatecomponents[inst.components.locomotor] == nil then
            inst.components.locomotor:WalkForward(true)
        end
    end
end

local function MakeCurrentPositionHome(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function OnLeaveFormation(inst, leader)
    if inst.components.homeseeker ~= nil then
        local homepos = inst.components.homeseeker:GetHomePos() or inst.components.knownlocations:GetLocation("home") or nil

        if homepos ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            if VecUtil_LengthSq(homepos.x - x, homepos.z - z) > RETURN_HOME_MAX_DIST_SQ then
                inst:PushEvent("detachchild")
                MakeCurrentPositionHome(inst)
                inst:RemoveComponent("homeseeker")
            end
        end
    end

    inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED

    inst:RemoveTag("NOBLOCK")
end

local function OnEnterFormation(inst, leader)
    inst.components.locomotor:Stop()

    inst:AddTag("NOBLOCK")
end

local function EnableBuzz(inst, enable)
    if enable then
        if not inst.buzzing then
            inst.buzzing = true
            if not (inst.components.inventoryitem:IsHeld() or inst:IsAsleep() or inst.SoundEmitter:PlayingSound("loop")) then
                inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/fly_LP", "loop")
            end
        end
    elseif inst.buzzing then
        inst.buzzing = false
        inst.SoundEmitter:KillSound("loop")
    end
end

local function OnWorked(inst, worker)
    local owner = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if owner ~= nil and owner.components.childspawner ~= nil then
        owner.components.childspawner:OnChildKilled(inst)
    end
    if worker.components.inventory ~= nil then
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
    end
end

local function onformationdisband(inst)
    if inst.components.formationleader.target ~= nil then
        inst.components.formationleader.target._lightflier_formation = nil
    end
end

MakeFormation = function(inst, target)
    local leader = SpawnPrefab("formationleader")
    local x, y, z = inst.Transform:GetWorldPosition()
    leader.Transform:SetPosition(x, y, z)
    leader._offset = leader:GetPosition()

    leader.components.formationleader:SetUp(target, inst)

    target._lightflier_formation = leader
    leader.components.formationleader.ondisbandfn = onformationdisband

    leader.components.formationleader.min_formation_size = 1
    leader.components.formationleader.max_formation_size = 3

    leader.components.formationleader.radius = FORMATION_RADIUS
    leader.components.formationleader.thetaincrement = FORMATION_ROTATION_SPEED

    leader.components.formationleader.onupdatefn = LeaderOnUpdate

    leader:DoPeriodicTask(VALIDATE_FORMATION_FREQ, LeaderValidateFormation)
end

local function FindTarget(inst)
    if GetTime() - inst._time_since_formation_attacked < TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION then
        -- Don't make a new formation if fly is still alert (has recently
        -- been attacked, or was part of a formation that was attacked).
        return
    end

    local formationfollower = inst.components.formationfollower
    local x, y, z = inst.Transform:GetWorldPosition()
    local leaders = TheSim:FindEntities(x, y, z, formationfollower.searchradius, formationfollower.formationsearchtags)

    if formationfollower:SearchForFormation(leaders) then
        return
    end

    local target = FindEntity(inst, FIND_TARGET_RADIUS, findtargettest, FIND_TARGET_MUSTTAGS, FIND_TARGET_NOTAGS, nil)
    if target ~= nil then
        MakeFormation(inst, target)
    end
end

local function StopLookingForTarget(inst)
    if inst._find_target_task ~= nil then
        inst._find_target_task:Cancel()
        inst._find_target_task = nil
    end
end

local function StartLookingForTarget(inst)
    StopLookingForTarget(inst)

    inst._find_target_task = inst:DoPeriodicTask(FIND_TARGET_FREQUENCY, FindTarget)
end

local function OnPutInInventory(inst)
    StopLookingForTarget(inst)
    inst.components.formationfollower:StopUpdating()
    inst:RemoveComponent("homeseeker")
    inst:EnableBuzz(false)
end

local function OnDropped(inst)
    inst.sg:GoToState("idle")
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.brain ~= nil then
        inst.brain:Start()
    end
    if inst.sg ~= nil then
        inst.sg:Start()
    end
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        while inst.components.stackable:IsStack()do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(x, y, z)
            end
        end
    end

    StartLookingForTarget(inst)
    inst.components.formationfollower:StartUpdating()
    inst:EnableBuzz(true)

    -- Needs to wait one frame in order for dropped stacks of lightfliers to run this at the correct time
    inst:DoTaskInTime(0, MakeCurrentPositionHome)
end

local function AlertFormation(inst)
    local time = GetTime()
    local leader = inst.components.formationfollower.formationleader

    if leader ~= nil then
        for k, v in pairs(leader.formation) do
            v._time_since_formation_attacked = time + math.random() * TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION_VARIANCE
        end

        leader:DisbandFormation()
    else
        inst._time_since_formation_attacked = time + math.random() * TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION_VARIANCE
    end
end

local function OnAttacked(inst, attacker, damage)
    AlertFormation(inst)
end

local function OnTeleported(inst)
    if inst.components.formationfollower.formationleader ~= nil then
        inst.components.formationfollower.formationleader:DisbandFormation()
    end
end

local function OnSleepGoHome(inst)
    inst._hometask = nil
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home ~= nil and home:IsValid() and home.components.childspawner ~= nil then
        home.components.childspawner:GoHome(inst)
    end
end

local function OnIsDay(inst, isday)
    if isday then
        if inst._hometask == nil then
            inst._hometask = inst:DoTaskInTime(10 + math.random(), OnSleepGoHome)
        end
    elseif inst._hometask ~= nil then
        inst._hometask:Cancel()
        inst._hometask = nil
    end
end

local function StopWatchingDay(inst)
    inst:StopWatchingWorldState("isday", OnIsDay)
    if inst._hometask ~= nil then
        inst._hometask:Cancel()
        inst._hometask = nil
    end
end

local function StartWatchingDay(inst)
    inst:WatchWorldState("isday", OnIsDay)
    OnIsDay(inst, TheWorld.state.isday)
end

local function SleepTest(inst)
    -- Doesn't sleep naturally
    return false
end

local function GoToSleep(inst)
    inst:EnableBuzz(false)
end

local function OnWakeUp(inst)
    inst:EnableBuzz(true)
end

-- hauntable doesn't push any event on haunt so this is mostly copy pasted from MakeHauntablePanic's OnHaunt fn
local function OnHaunt(inst, haunter)
    AlertFormation(inst)

    inst.components.sleeper:WakeUp()

    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        inst.components.hauntable.panic = true
        inst.components.hauntable.panictimer = TUNING.HAUNT_PANIC_TIME_SMALL
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function OnEntitySleep(inst)
    inst:ListenForEvent("enterlimbo", StopWatchingDay)
    inst:ListenForEvent("exitlimbo", StartWatchingDay)
    if not inst:IsInLimbo() then
        StartWatchingDay(inst)
    end

    StopLookingForTarget(inst)
end

local function OnEntityWake(inst)
    inst:RemoveEventCallback("enterlimbo", StopWatchingDay)
    inst:RemoveEventCallback("exitlimbo", StartWatchingDay)
    if not inst:IsInLimbo() then
        StopWatchingDay(inst)
    end

    if not inst.components.inventoryitem:IsHeld() then
        StartLookingForTarget(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeGhostPhysics(inst, 1, .5)

    inst.DynamicShadow:SetSize(1, .5)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("lightflier")
    inst.AnimState:SetBuild("lightflier")

    inst.AnimState:SetLightOverride(1)

    inst.scrapbook_deps = {"lightbulb"}

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1.8)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    inst:AddTag("lightflier")
    inst:AddTag("cavedweller")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("lightbattery")
    inst:AddTag("lunar_aligned")

    MakeInventoryFloatable(inst)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -- inst._formation_distribution_toggle = nil

    -- inst._find_target_task = nil
    inst._time_since_formation_attacked = -TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:SetStateGraph("SGlightflier")
    inst:SetBrain(brain)

    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem.pushlandedevents = false

    inst:AddComponent("tradable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper.sleeptestfn = SleepTest

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "lightbulb"

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LIGHTFLIER.HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("lightflier")

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:AddComponent("homeseeker")

    MakeSmallBurnableCharacter(inst, "lightbulb")
    MakeSmallFreezableCharacter(inst, "lightbulb")

    inst:AddComponent("follower")

    inst:AddComponent("formationfollower")
    inst.components.formationfollower.searchradius = FORMATION_SEARCH_RADIUS
    inst.components.formationfollower.formation_type = "lightflier"
    inst.components.formationfollower.onupdatefn = FollowerOnUpdate
    inst.components.formationfollower.onleaveformationfn = OnLeaveFormation
    inst.components.formationfollower.onenterformationfn = OnEnterFormation

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("teleported", OnTeleported)

    inst:ListenForEvent("gotosleep", GoToSleep)
    inst:ListenForEvent("onwakeup", OnWakeUp)

    MakeHauntablePanic(inst)
    MakeFeedableSmallLivestock(inst, TUNING.LIGHTFLIER.STARVE_TIME, OnPutInInventory, OnDropped)

    inst.incineratesound = "grotto/creatures/light_bug/death"
    
    inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/fly_LP", "loop")

    inst.EnableBuzz = EnableBuzz

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("lightflier", fn, assets, prefabs)
