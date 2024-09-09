local brain = require("brains/dragonflybrain")

local assets =
{
    Asset("ANIM", "anim/dragonfly_build.zip"),
    Asset("ANIM", "anim/dragonfly_fire_build.zip"),
    Asset("ANIM", "anim/dragonfly_basic.zip"),
    Asset("ANIM", "anim/dragonfly_actions.zip"),
    Asset("ANIM", "anim/dragonfly_yule_build.zip"),
    Asset("ANIM", "anim/dragonfly_fire_yule_build.zip"),
    Asset("SOUND", "sound/dragonfly.fsb"),
}

local prefabs =
{
    "firesplash_fx",
    "tauntfire_fx",
    "attackfire_fx",
    "vomitfire_fx",
    "firering_fx",

    --loot:
    "dragon_scales",
    "lavae_egg",
    "meat",
    "goldnugget",
    "redgem",
    "bluegem",
    "purplegem",
    "orangegem",
    "yellowgem",
    "greengem",
    "dragonflyfurnace_blueprint",
    "chesspiece_dragonfly_sketch",
}

SetSharedLootTable('dragonfly',
{
    {'dragon_scales',             1.00},
    {'dragonflyfurnace_blueprint',1.00},
    {'chesspiece_dragonfly_sketch', 1.00},
    {'lavae_egg',                 0.33},

    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},

    {'goldnugget',       1.00},
    {'goldnugget',       1.00},
    {'goldnugget',       1.00},
    {'goldnugget',       1.00},

    {'goldnugget',       0.50},
    {'goldnugget',       0.50},
    {'goldnugget',       0.50},
    {'goldnugget',       0.50},

    {'redgem',           1.00},
    {'bluegem',          1.00},
    {'purplegem',        1.00},
    {'orangegem',        1.00},
    {'yellowgem',        1.00},
    {'greengem',         1.00},

    {'redgem',           1.00},
    {'bluegem',          1.00},
    {'purplegem',        0.50},
    {'orangegem',        0.50},
    {'yellowgem',        0.50},
    {'greengem',         0.50},
})

--------------------------------------------------------------------------

local function ForceDespawn(inst)
    inst:Reset()
    inst:DoDespawn()
end

local function ToggleDespawnOffscreen(inst)
    if inst:IsAsleep() then
        if inst.sleeptask == nil then
            inst.sleeptask = inst:DoTaskInTime(10, ForceDespawn)
        end
    elseif inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end
end

--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("flight") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 60 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "dragonfly", duration = 15 })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 64) then
        inst._playingmusic = false
    end
end

local function OnIsEngagedDirty(inst)
    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        if not inst._isengaged:value() then
            if inst._musictask ~= nil then
                inst._musictask:Cancel()
                inst._musictask = nil
            end
            inst._playingmusic = false
        elseif inst._musictask == nil then
            inst._musictask = inst:DoPeriodicTask(1, PushMusic)
            PushMusic(inst)
        end
    end
end

local function SetEngaged(inst, engaged)
    if inst._isengaged:value() ~= engaged then
        inst._isengaged:set(engaged)
        OnIsEngagedDirty(inst)
        ToggleDespawnOffscreen(inst)

        local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
        if home ~= nil then
            home:PushEvent("dragonflyengaged", { engaged = engaged, dragonfly = inst })
        end
    end
end

--------------------------------------------------------------------------

local function TransformNormal(inst)
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_yule_build" or "dragonfly_build")
    inst.enraged = false
    --Set normal stats
    inst.components.locomotor.walkspeed = TUNING.DRAGONFLY_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.DRAGONFLY_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.DRAGONFLY_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE, TUNING.DRAGONFLY_HIT_RANGE)

    inst.components.freezable:SetResistance(TUNING.DRAGONFLY_FREEZE_THRESHOLD)

    inst.components.propagator:StopSpreading()
    inst.Light:Enable(false)
end

local function _OnRevert(inst)
    inst.reverttask = nil
    if inst.enraged then
        inst:PushEvent("transform", { transformstate = "normal" })
    end
end

local function TransformFire(inst)
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_fire_yule_build" or "dragonfly_fire_build")
    inst.enraged = true
    inst.can_ground_pound = true
    --Set fire stats
    inst.components.locomotor.walkspeed = TUNING.DRAGONFLY_FIRE_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.DRAGONFLY_FIRE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.DRAGONFLY_FIRE_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE, TUNING.DRAGONFLY_FIRE_HIT_RANGE)

    inst.Light:Enable(true)
    inst.components.propagator:StartSpreading()

    inst.components.moisture:DoDelta(-inst.components.moisture:GetMoisture())

    inst.components.freezable:SetResistance(TUNING.DRAGONFLY_ENRAGED_FREEZE_THRESHOLD)

    if inst.reverttask ~= nil then
        inst.reverttask:Cancel()
    end
    inst.reverttask = inst:DoTaskInTime(TUNING.DRAGONFLY_ENRAGE_DURATION, _OnRevert)
end

local function IsFightingPlayers(inst)
    return inst.components.combat.target ~= nil and inst.components.combat.target:HasTag("player")
end

local function UpdatePlayerTargets(inst)
    local toadd = {}
    local toremove = {}
    local pos = inst.components.knownlocations:GetLocation("spawnpoint")

    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        toremove[k] = true
    end
    for i, v in ipairs(FindPlayersInRange(pos.x, pos.y, pos.z, TUNING.DRAGONFLY_RESET_DIST, true)) do
        if toremove[v] then
            toremove[v] = nil
        else
            table.insert(toadd, v)
        end
    end

    for k, v in pairs(toremove) do
        inst.components.grouptargeter:RemoveTarget(k)
    end
    for i, v in ipairs(toadd) do
        inst.components.grouptargeter:AddTarget(v)
    end
end

local function TryGetNewTarget(inst)
    UpdatePlayerTargets(inst)

    local new_target = inst.components.grouptargeter:SelectTarget()
    if new_target ~= nil then
        inst.components.combat:SetTarget(new_target)
    end
end

local function ResetLavae(inst)
    --Despawn all lavae
    local lavae = inst.components.rampingspawner.spawns
    for k, v in pairs(lavae) do
        k.components.combat:SetTarget(nil)
        k.components.locomotor:Clear()
        k.reset = true
    end
end

local function OnDeath(inst)
    AwardRadialAchievement("dragonfly_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
    ResetLavae(inst)
    SetEngaged(inst, false)
end

local function SoftReset(inst)
    inst.SoftResetTask = nil
    --Double check for nearby players & combat targets before reseting.
    TryGetNewTarget(inst)
    if inst.components.combat:HasTarget() then
        return
    end

    --print(string.format("Dragonfly - Execute soft reset @ %2.2f", GetTime()))

    ResetLavae(inst)
    SetEngaged(inst, false)
    inst.components.freezable:Unfreeze()
    inst.components.freezable:SetExtraResist(0)
    inst.components.sleeper:WakeUp()
    inst.components.sleeper:SetExtraResist(0)
    inst.components.health:SetCurrentHealth(inst.components.health.maxhealth)
    inst.components.rampingspawner:Stop()
    inst.components.rampingspawner:Reset()
    TransformNormal(inst)
    inst.components.stunnable.stun_threshold = TUNING.DRAGONFLY_STUN
    inst.components.stunnable.stun_period = TUNING.DRAGONFLY_STUN_PERIOD
end

local function Reset(inst)
    ResetLavae(inst)
    --Fly off
    inst.reset = true

    --No longer start the respawn task here - was possible to duplicate this if the exiting failed.
end

local function DoDespawn(inst)
    --Schedule new spawn time
    --Called at the time the dragonfly actually leaves the world.
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home ~= nil then
        home.components.childspawner:GoHome(inst)
        home.components.childspawner:StartSpawning()
    else
        inst:Remove() --Dragonfly was probably debug spawned in?
    end
end

local function TrySoftReset(inst)
    if inst.SoftResetTask == nil then
        --print(string.format("Dragonfly - Start soft reset task @ %2.2f", GetTime()))
        inst.SoftResetTask = inst:DoTaskInTime(10, SoftReset)
    end
end

local function OnTargetDeathTask(inst)
    inst._ontargetdeathtask = nil
    TryGetNewTarget(inst)
    if inst.components.combat.target == nil and inst.components.grouptargeter.num_targets <= 0 then
        TrySoftReset(inst)
    end
end

local function OnNewTarget(inst, data)
    if inst.SoftResetTask ~= nil then
        --print(string.format("Dragonfly - Cancel soft reset task @ %2.2f", GetTime()))
        inst.SoftResetTask:Cancel()
        inst.SoftResetTask = nil
    end
    if data.oldtarget ~= nil then
        inst:RemoveEventCallback("death", inst._ontargetdeath, data.oldtarget)
    end
    if data.target ~= nil  then
        inst:ListenForEvent("death", inst._ontargetdeath, data.target)
        if data.target:HasTag("player") then
            SetEngaged(inst, true)
        end
    end
end

local function RetargetFn(inst)
    UpdatePlayerTargets(inst)

    local target = inst.components.combat.target
    if target ~= nil and target:HasTag("player") then
        local newplayer = inst.components.grouptargeter:TryGetNewTarget()
        return newplayer ~= nil
            and newplayer:IsNear(inst, TUNING.DRAGONFLY_AGGRO_DIST)
            and newplayer
            or nil,
            true
    end

    local inrange = target ~= nil and inst:IsNear(target, TUNING.DRAGONFLY_ATTACK_RANGE + target:GetPhysicsRadius(0))
    local nearplayers = {}
    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        if inst:IsNear(k, inrange and TUNING.DRAGONFLY_ATTACK_RANGE + k:GetPhysicsRadius(0) or TUNING.DRAGONFLY_AGGRO_DIST) then
            table.insert(nearplayers, k)
        end
    end
    return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end

local function GetLavaePos(inst)
    local pos = inst:GetPosition()
    local facingangle = inst.Transform:GetRotation() * DEGREES
    pos.x = pos.x + 1.7 * math.cos(-facingangle)
    pos.y = pos.y - .3
    pos.z = pos.z + 1.7 * math.sin(-facingangle)
    return pos
end

local function OnLavaeDeath(inst, data)
    --If that was my last lavae & I'm out of lavaes to spawn then enrage.
    if inst.components.rampingspawner:GetCurrentWave() <= 0 and data.remaining_spawns <= 0 then
        --Blargh!
        inst.components.rampingspawner:Stop()
        inst.components.rampingspawner:Reset()
        inst:PushEvent("transform", { transformstate = "fire" })
    end
end

local function OnLavaeSpawn(inst, data)
    --Lavae should pick the closest player and imprint on them.
    --This allows players to pick a person to kite lavaes.
    local lavae = data.newent
    local targets = {}
    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        table.insert(targets, k)
    end
    local target = GetClosest(lavae, targets) or inst.components.grouptargeter:SelectTarget()
    lavae.components.entitytracker:TrackEntity("mother", inst)
    lavae.LockTargetFn(lavae, target)
end

function OnMoistureDelta(inst, data)
    if inst.enraged then
        local break_threshold = inst.components.moisture.maxmoisture * 0.9
        if (data.old < break_threshold and data.new >= break_threshold) then
            TransformNormal(inst)
        end
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

local function DoBreakOff(inst)
    local player--[[, rangesq]] = inst:GetNearestPlayer()
    LaunchAt(SpawnPrefab("dragon_scales"), inst, player, 1, 3, 1.5)
end

local function OnSave(inst, data)
    --Check if the dragonfly is in combat with players so we can reset.
    data.playercombat = inst._isengaged:value() or nil
end

--delayed until homeseeker is initialized (from dragonfly_spawner)
local function OnInitEngaged(inst)
    if inst._isengaged:value() then
        local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
        if home ~= nil then
            home:PushEvent("dragonflyengaged", { engaged = true, dragonfly = inst })
        end
    end
end

local function OnLoad(inst, data)
    --If the dragonfly was in combat when the game saved then we're going to reset the fight.
    if data.playercombat then
        SetEngaged(inst, true)
        inst:DoTaskInTime(0, OnInitEngaged)
        inst:DoTaskInTime(1, Reset)
    end
end

local function OnTimerDone(inst, data)
    if data.name == "groundpound_cd" then
        inst.can_ground_pound = true
    end
end

local function OnSpawnStart(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "spawning", 1.4)
end

local function OnSpawnStop(inst)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "spawning")
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        local target = inst.components.combat.target
        if not (target ~= nil and
                target:HasTag("player") and
                target:IsNear(inst, TUNING.DRAGONFLY_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
            inst.components.combat:SetTarget(data.attacker)
        end
    end
end

local function OnHealthTrigger(inst)
    inst:PushEvent("transform", { transformstate = "normal" })
    inst.components.rampingspawner:Start()
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(6, 3.5)
    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(1.3, 1.3, 1.3)

    MakeFlyingGiantCharacterPhysics(inst, 500, 1.4)

    inst.AnimState:SetBank("dragonfly")
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_yule_build" or "dragonfly_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("dragonfly")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(235/255, 121/255, 12/255)

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")

    inst._isengaged = net_bool(inst.GUID, "dragonfly._isengaged", "isengageddirty")
    inst._playingmusic = false
    inst._musictask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("isengageddirty", OnIsEngagedDirty)

        return inst
    end

    inst.scrapbook_damage = { TUNING.DRAGONFLY_DAMAGE, TUNING.DRAGONFLY_FIRE_DAMAGE }

    -- Component Definitions
    local combat = inst:AddComponent("combat")
    local damagetracker = inst:AddComponent("damagetracker")
    inst:AddComponent("explosiveresist")
    local groundpounder = inst:AddComponent("groundpounder")
    inst:AddComponent("grouptargeter")
    local health = inst:AddComponent("health")
    local healthtrigger = inst:AddComponent("healthtrigger")
    local inspectable = inst:AddComponent("inspectable")
    inst:AddComponent("inventory")
    inst:AddComponent("knownlocations")
    local lootdropper = inst:AddComponent("lootdropper")
    local locomotor = inst:AddComponent("locomotor")
    inst:AddComponent("moisture")
    local rampingspawner = inst:AddComponent("rampingspawner")
    local sleeper = inst:AddComponent("sleeper")
	local stuckdetection = inst:AddComponent("stuckdetection")
    local stunnable = inst:AddComponent("stunnable")
    inst:AddComponent("timer")

    inst:SetStateGraph("SGdragonfly")
    inst:SetBrain(brain)

    -- Component Init
    combat:SetDefaultDamage(TUNING.DRAGONFLY_DAMAGE)
    combat:SetAttackPeriod(TUNING.DRAGONFLY_ATTACK_PERIOD)
    combat.playerdamagepercent = 0.5
    combat:SetRange(TUNING.DRAGONFLY_ATTACK_RANGE, TUNING.DRAGONFLY_HIT_RANGE)
    combat:SetRetargetFunction(3, RetargetFn)
    combat:SetKeepTargetFunction(KeepTargetFn)
    combat.battlecryenabled = false
    combat.hiteffectsymbol = "dragonfly_body"
    combat:SetHurtSound("dontstarve_DLC001/creatures/dragonfly/hurt")

    damagetracker.damage_threshold = TUNING.DRAGONFLY_BREAKOFF_DAMAGE
    damagetracker.damage_threshold_fn = DoBreakOff

    groundpounder:UseRingMode()
    groundpounder.numRings = 3
    groundpounder.initialRadius = 1.5
    groundpounder.radiusStepDistance = 2
    groundpounder.ringWidth = 2
    groundpounder.damageRings = 2
    groundpounder.destructionRings = 3
    groundpounder.platformPushingRings = 3
    groundpounder.fxRings = 2
    groundpounder.fxRadiusOffset = 1.5
    groundpounder.burner = true
    groundpounder.groundpoundfx = "firesplash_fx"
    groundpounder.groundpounddamagemult = 0.5
    groundpounder.groundpoundringfx = "firering_fx"

    health:SetMaxHealth(TUNING.DRAGONFLY_HEALTH)
    health.nofadeout = true --Handled in death state instead
    health.fire_damage_scale = 0 -- Take no damage from fire

    healthtrigger:AddTrigger(0.8, OnHealthTrigger)
    healthtrigger:AddTrigger(0.5, OnHealthTrigger)
    healthtrigger:AddTrigger(0.2, OnHealthTrigger)

    inspectable:RecordViews()

    lootdropper:SetChanceLootTable("dragonfly")

    locomotor:EnableGroundSpeedMultiplier(false)
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = { ignorewalls = true, allowocean = true }
    locomotor.walkspeed = TUNING.DRAGONFLY_SPEED

    rampingspawner.getspawnposfn = GetLavaePos
    rampingspawner.onstartfn = OnSpawnStart
    rampingspawner.onstopfn = OnSpawnStop

    sleeper:SetResistance(4)
    sleeper:SetSleepTest(ShouldSleep)
    sleeper:SetWakeTest(ShouldWake)
    sleeper.diminishingreturns = true

    stuckdetection:SetTimeToStuck(2)

    stunnable.stun_threshold = TUNING.DRAGONFLY_STUN
    stunnable.stun_period = TUNING.DRAGONFLY_STUN_PERIOD
    stunnable.stun_duration = TUNING.DRAGONFLY_STUN_DURATION
    stunnable.stun_resist = TUNING.DRAGONFLY_STUN_RESIST
    stunnable.stun_cooldown = TUNING.DRAGONFLY_STUN_COOLDOWN

    -- Event Watching
    --inst._ontargetdeathtask = nil
    inst._ontargetdeath = function()
        inst._ontargetdeathtask = inst._ontargetdeathtask or inst:DoTaskInTime(2, OnTargetDeathTask)
    end

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath) --Get rid of lavaes.
    inst:ListenForEvent("moisturedelta", OnMoistureDelta)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("rampingspawner_death", OnLavaeDeath)
    inst:ListenForEvent("rampingspawner_spawn", OnLavaeSpawn)
    inst:ListenForEvent("timerdone", OnTimerDone)

    -- Variables

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad -- Reset fight if in combat with players.
    inst.OnEntitySleep = ToggleDespawnOffscreen
    inst.OnEntityWake = ToggleDespawnOffscreen
    inst.Reset = Reset
    inst.DoDespawn = DoDespawn
    inst.TransformFire = TransformFire
    inst.TransformNormal = TransformNormal
    inst.can_ground_pound = false
    inst.hit_recovery = TUNING.DRAGONFLY_HIT_RECOVERY

    local freezable = MakeHugeFreezableCharacter(inst)
    freezable:SetResistance(TUNING.DRAGONFLY_FREEZE_THRESHOLD)
    freezable.damagetobreak = TUNING.DRAGONFLY_FREEZE_RESIST
    freezable.diminishingreturns = true

    local propagator = MakeLargePropagator(inst)
    propagator.decayrate = 0

    return inst
end

return Prefab("dragonfly", fn, assets, prefabs)
