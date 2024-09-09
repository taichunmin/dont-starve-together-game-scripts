local clockwork_common = require "prefabs/clockwork_common"
local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/archive_centipede.zip"),
    Asset("ANIM", "anim/archive_centipede_actions.zip"),
    Asset("ANIM", "anim/archive_centipede_build.zip"),

}

local prefabs =
{
    "gears",
    "archive_centipede_husk",
}

-- START LIGHTING
local light_params =
{
    on =
    {
        radius = 2,
        intensity = .4,
        falloff = .6,
        colour = {237/255, 237/255, 209/255},
        time = 80/30,
    },

    off =
    {
        radius = 0,
        intensity = 0,
        falloff = 0.2,
        colour = { 0, 0, 0 },
        time = 1,
    },
}

local function pushparams(inst, params)
    inst.Light:SetRadius(params.radius * inst.widthscale)
    inst.Light:SetIntensity(params.intensity)
    inst.Light:SetFalloff(params.falloff)
    inst.Light:SetColour(unpack(params.colour))

    if TheWorld.ismastersim then
        if params.intensity > 0 then
            inst.Light:Enable(true)
        else
            inst.Light:Enable(false)
        end
    end
end

-- Not using deepcopy because we want to copy in place
local function copyparams(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = dest[k] or {}
            copyparams(dest[k], v)
        else
            dest[k] = v
        end
    end
end

local function lerpparams(pout, pstart, pend, lerpk)
    for k, v in pairs(pend) do
        if type(v) == "table" then
            lerpparams(pout[k], pstart[k], v, lerpk)
        else
            pout[k] = pstart[k] * (1 - lerpk) + v * lerpk
        end
    end
end

local function OnUpdateLight(inst, dt)
    inst._currentlight.time = inst._currentlight.time + dt
    if inst._currentlight.time >= inst._endlight.time then
        inst._currentlight.time = inst._endlight.time
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
    lerpparams(inst._currentlight, inst._startlight, inst._endlight, inst._endlight.time > 0 and inst._currentlight.time / inst._endlight.time or 1)
    pushparams(inst, inst._currentlight)
    local remap = Remap(inst._currentlight.intensity, 0,1, 0,1)
    inst.AnimState:SetLightOverride(remap)
end

local function beginfade(inst)
    copyparams(inst._startlight, inst._currentlight)
    inst._currentlight.time = 0
    inst._startlight.time = 0

    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, FRAMES)
    end

end
-- END LIGHTING

local SLEEP_DIST_FROMHOME_SQ = 1 * 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST_SQ = 40 * 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local brain = require "brains/centipedebrain"

local CHARACTER_TAGS = {"character"}
local function _BasicWakeCheck(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
        or GetClosestInstWithTag(CHARACTER_TAGS, inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and inst:GetDistanceSqToPoint(homePos:Get()) < SLEEP_DIST_FROMHOME_SQ
        and not _BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil and
            inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
        or _BasicWakeCheck(inst)
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myLeader = inst.components.follower ~= nil and inst.components.follower.leader or nil

    return not (homePos ~= nil and
                inst:GetDistanceSqToPoint(homePos:Get()) >= TUNING.ARCHIVE_CENTIPEDE.TARGET_DIST * TUNING.ARCHIVE_CENTIPEDE.TARGET_DIST and
                (inst.components.follower == nil or inst.components.follower.leader == nil))
        and FindEntity(
            inst,
            TUNING.ARCHIVE_CENTIPEDE.TARGET_DIST,
            function(guy)
                if myLeader == guy then
                    return false
                end
                if myLeader ~= nil and myLeader:HasTag("player") and guy:HasTag("player") then
                    return false  -- don't automatically attack other players, wait for the leader's insturctions
                end
                local theirLeader = guy.components.follower ~= nil and guy.components.follower.leader or nil
                local bothFollowingSamePlayer = myLeader ~= nil and myLeader == theirLeader and myLeader:HasTag("player")
                return not bothFollowingSamePlayer
                    and not (guy:HasTag("archive_centipede") and theirLeader == nil)
                    and inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS,
            RETARGET_ONEOF_TAGS
        )
        or nil
end

local function KeepTarget(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (inst.components.follower ~= nil and inst.components.follower.leader ~= nil)
        or (homePos ~= nil and target:GetDistanceSqToPoint(homePos:Get()) < MAX_CHASEAWAY_DIST_SQ)
end

local function _ShareTargetFn(dude)
    return dude:HasTag("archive_centipede")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("archive_centipede") then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, _ShareTargetFn, MAX_TARGET_SHARES)
end
local function RememberKnownLocation(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end


local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function onothercollide(inst, other)
    if not other:IsValid() or inst.recentlycharged[other] then
        return
    elseif other:HasTag("smashable") and other.components.health ~= nil then
        other.components.health:Kill()
    elseif other.components.workable ~= nil
        and other.components.workable:CanBeWorked()
        and other.components.workable.action ~= ACTIONS.NET then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
	elseif other.components.combat ~= nil
		and other.components.health ~= nil and not other.components.health:IsDead()
		and (other:HasTag("wall") or other:HasTag("structure"))
		then
        inst.recentlycharged[other] = true
        inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
        inst.components.combat:DoAttack(other)
    end
end

local function oncollide(inst, other)
    if not (other ~= nil and other:IsValid() and inst:IsValid())
        or inst.recentlycharged[other]
        or Vector3(inst.Physics:GetVelocity()):LengthSq() < 42 then
        return
    end
    ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
    inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
end

local function fn_common(tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.entity:AddLight()

    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(false)

    inst.widthscale = 1
    inst._endlight = light_params.off
    inst._startlight = {}
    inst._currentlight = {}
    copyparams(inst._startlight, inst._endlight)
    copyparams(inst._currentlight, inst._endlight)
    pushparams(inst, inst._currentlight)

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("archive_centipede")
    inst.AnimState:SetBuild("archive_centipede_build")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("soulless")
    inst:AddTag("mech")
    inst:AddTag("archive_centipede")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_removedeps = {"gears"}

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(oncollide)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ARCHIVE_CENTIPEDE.WALK_SPEED

    inst:SetStateGraph("SGcentipede")

    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.ARCHIVE_CENTIPEDE.HEALTH)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "cent_bod"
    inst.components.combat:SetAttackPeriod(TUNING.ARCHIVE_CENTIPEDE.ATTACK_PERIOD)
	inst.components.combat:SetRange(TUNING.ARCHIVE_CENTIPEDE.ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(TUNING.ARCHIVE_CENTIPEDE.DAMAGE)

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:DoTaskInTime(0, RememberKnownLocation)

    inst:AddComponent("follower")

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeMediumFreezableCharacter(inst, "swap_fire")

    MakeHauntablePanic(inst)

    inst.kind = ""

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("death") then
            local husk = SpawnPrefab("archive_centipede_husk")
            local x,y,z = inst.Transform:GetWorldPosition()
            husk.Transform:SetPosition(x,y,z)
            husk.Transform:SetRotation(inst.Transform:GetRotation())
            inst:Remove()
        end
    end)

    inst:DoTaskInTime(0,function()
        inst.SoundEmitter:PlaySound("grotto/creatures/centipede/active_LP","alive")
    end)

    inst.light_params = light_params
    inst.copyparams = copyparams
    inst.beginfade = beginfade
    inst.pushparams = pushparams

    return inst
end

local function fn()
    local inst = fn_common()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end
local MED_THRESHOLD_DOWN = 0.66
local LOW_THRESHOLD_DOWN = 0.33

local MED_THRESHOLD_UP = 0.66 -- 0.75
local LOW_THRESHOLD_UP = 0.33 --0.50
local BOTTOM_THRESHOLD = 0.2 --0.50

local function OnHealthDelta(inst, oldpercent, newpercent)
    if newpercent < oldpercent then
        if oldpercent >= MED_THRESHOLD_DOWN and
            newpercent < MED_THRESHOLD_DOWN and newpercent >= LOW_THRESHOLD_DOWN then
                inst.AnimState:PlayAnimation("idle_med")
                inst:RemoveTag("gestalt_possessable")
        elseif oldpercent >=  MED_THRESHOLD_DOWN and
            newpercent < LOW_THRESHOLD_DOWN then
                inst.AnimState:PlayAnimation("idle_low")
                inst:RemoveTag("gestalt_possessable")
        elseif oldpercent <  MED_THRESHOLD_DOWN and  oldpercent >= LOW_THRESHOLD_DOWN and
            newpercent < LOW_THRESHOLD_DOWN then
                inst.AnimState:PlayAnimation("idle_low")
                inst:RemoveTag("gestalt_possessable")
        end
    else
        if oldpercent < LOW_THRESHOLD_UP and
            newpercent >= LOW_THRESHOLD_UP and newpercent < MED_THRESHOLD_UP then
                inst.AnimState:PlayAnimation("low_to_med")
                inst.AnimState:PushAnimation("idle_med")
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/low_to_med")
        elseif oldpercent <  LOW_THRESHOLD_UP and
            newpercent >= MED_THRESHOLD_UP then
                inst.AnimState:PlayAnimation("low_to_med")
                inst.AnimState:PushAnimation("med_to_full")
                inst.AnimState:PushAnimation("idle_full")
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/low_to_med")
                inst:AddTag("gestalt_possessable")
        elseif oldpercent <  MED_THRESHOLD_UP and  oldpercent >= LOW_THRESHOLD_UP and
            newpercent >= MED_THRESHOLD_UP then
                inst.AnimState:PlayAnimation("med_to_full")
                inst.AnimState:PushAnimation("idle_full")
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/med_to_full")
                inst:AddTag("gestalt_possessable")
        end
    end
    if newpercent < (BOTTOM_THRESHOLD) then
        if inst.components.combat then
            inst:RemoveComponent("combat")
        end
        if newpercent < BOTTOM_THRESHOLD - 0.05 then
            inst.components.health:SetPercent(BOTTOM_THRESHOLD - 0.05)
        end
    else
        if not inst.components.combat then
            inst:AddComponent("combat")
        end
    end
end

local function onpossess(inst, data)
    if data.possesser and data.possesser:HasTag("power_point") then
        data.possesser:Remove()
        local x,y,z = inst.Transform:GetWorldPosition()
        local centipede = SpawnPrefab("archive_centipede")
        centipede.Transform:SetPosition(x,y,z)
        centipede.sg:GoToState("spawn")
        if inst.idle2task then
            inst.idle2task:Cancel()
            inst.idle2task = nil
        end
        inst:Remove()
    end
end

local function OnAttacked(inst)
    if not inst.AnimState:IsCurrentAnimation("low_to_med") and
       not inst.AnimState:IsCurrentAnimation("med_to_full") then
        if inst.components.health:GetPercent() < LOW_THRESHOLD_DOWN then
            inst.AnimState:PlayAnimation("low_hit")
            inst.AnimState:PushAnimation("idle_low")
        elseif inst.components.health:GetPercent() < MED_THRESHOLD_DOWN then
            inst.AnimState:PlayAnimation("med_hit")
            inst.AnimState:PushAnimation("idle_med")
        else
            inst.AnimState:PlayAnimation("full_hit")
            inst.AnimState:PushAnimation("idle_full")
        end
    end
end

local function playidle2(inst)

    if inst.idle2task then
        inst.idle2task:Cancel()
        inst.idle2task = nil
    end

    if inst.AnimState:IsCurrentAnimation("idle_full") or
       inst.AnimState:IsCurrentAnimation("idle_med") or
       inst.AnimState:IsCurrentAnimation("idle_low") then

        inst.SoundEmitter:PlaySound("grotto/creatures/centipede/electricity/idle2")
        if inst.components.health:GetPercent() < LOW_THRESHOLD_DOWN then
            inst.AnimState:PlayAnimation("idle2_low")
            inst.AnimState:PushAnimation("idle_low")
        elseif inst.components.health:GetPercent() < MED_THRESHOLD_DOWN then
            inst.AnimState:PlayAnimation("idle2_med")
            inst.AnimState:PushAnimation("idle_med")
        else
            inst.AnimState:PlayAnimation("idle2_full")
            inst.AnimState:PushAnimation("idle_full")
        end
    end

    inst.idle2task = inst:DoTaskInTime((math.random()*10)+8,function() playidle2(inst) end)
end

local function huskfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    --MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("archive_centipede")
    inst.AnimState:SetBuild("archive_centipede_build")
    inst.AnimState:PlayAnimation("idle_full")

    inst:AddTag("security_powerpoint")
    inst:AddTag("mech")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_removedeps = {"gears"}
    inst.scrapbook_anim = "idle_full"

    inst:AddComponent("lootdropper")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ARCHIVE_CENTIPEDE.HUSK_HEALTH)
    inst.components.health.ondelta = OnHealthDelta
    inst.components.health:StartRegen(1,1)
    inst.components.health.nofadeout = true

    inst.possessable = true

    inst.MED_THRESHOLD_DOWN = MED_THRESHOLD_DOWN

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")

    inst:ListenForEvent("possess", onpossess)
    inst:ListenForEvent("attacked", OnAttacked)
    inst.idle2task = inst:DoTaskInTime((math.random()*3)+3,function() playidle2(inst) end)

    MakeHauntableWork(inst)

    return inst
end

return Prefab("archive_centipede", fn, assets, prefabs),
       Prefab("archive_centipede_husk", huskfn, assets, prefabs)
