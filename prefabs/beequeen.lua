local assets =
{
    Asset("ANIM", "anim/bee_queen_basic.zip"),
    Asset("ANIM", "anim/bee_queen_actions.zip"),
    Asset("ANIM", "anim/bee_queen_build.zip"),
}

local prefabs =
{
    "beeguard",
    "honey_trail",
	"ocean_splash_ripple1",
	"ocean_splash_ripple2",
    "royal_jelly",
    "honeycomb",
    "honey",
    "stinger",
    "hivehat",
    "bundlewrap_blueprint",
	"chesspiece_beequeen_sketch",
}

SetSharedLootTable('beequeen',
{
    {'royal_jelly',      1.00},
    {'royal_jelly',      1.00},
    {'royal_jelly',      1.00},
    {'royal_jelly',      1.00},
    {'royal_jelly',      1.00},
    {'royal_jelly',      1.00},
    {'royal_jelly',      0.50},
    {'honeycomb',        1.00},
    {'honeycomb',        0.50},
    {'honey',            1.00},
    {'honey',            1.00},
    {'honey',            1.00},
    {'honey',            0.50},
    {'stinger',          1.00},
    {'hivehat',          1.00},
    {'bundlewrap_blueprint', 1.00},
	{'chesspiece_beequeen_sketch', 1.00},
})

--------------------------------------------------------------------------

local brain = require("brains/beequeenbrain")

--------------------------------------------------------------------------

local MAX_HONEY_VARIATIONS = 7
local MAX_RECENT_HONEY = 4
local HONEY_PERIOD = .2
local HONEY_LEVELS =
{
    {
        min_scale = .5,
        max_scale = .8,
        threshold = 8,
        duration = 1.2,
    },
    {
        min_scale = .5,
        max_scale = 1.1,
        threshold = 2,
        duration = 2,
    },
    {
        min_scale = 1,
        max_scale = 1.3,
        threshold = 1,
        duration = 4,
    },
}

local function PickHoney(inst)
    local rand = table.remove(inst.availablehoney, math.random(#inst.availablehoney))
    table.insert(inst.usedhoney, rand)
    if #inst.usedhoney > MAX_RECENT_HONEY then
        table.insert(inst.availablehoney, table.remove(inst.usedhoney, 1))
    end
    return rand
end

local function TrySpawnHoney(inst, x, z, min_scale, max_scale, duration)
	if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
		local fx = SpawnPrefab("honey_trail")
        fx.Transform:SetPosition(x, 0, z) -- NOTES(JBK): This must be before SetVariation is called!
		fx:SetVariation(PickHoney(inst), GetRandomMinMax(min_scale, max_scale), duration + math.random() * .5)
	else
		SpawnPrefab("ocean_splash_ripple"..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
	end
end

local function DoHoneyTrail(inst)
    local level = HONEY_LEVELS[
        (not inst.sg:HasStateTag("moving") and 1) or
        (inst.components.locomotor.walkspeed <= TUNING.BEEQUEEN_SPEED and 2) or
        3
    ]

    inst.honeycount = inst.honeycount + 1

    if inst.honeythreshold > level.threshold then
        inst.honeythreshold = level.threshold
    end

    if inst.honeycount >= inst.honeythreshold then
        local hx, hy, hz = inst.Transform:GetWorldPosition()
        inst.honeycount = 0
        if inst.honeythreshold < level.threshold then
            inst.honeythreshold = math.ceil((inst.honeythreshold + level.threshold) * .5)
        end

		TrySpawnHoney(inst, hx, hz, level.min_scale, level.max_scale, level.duration)
    end
end

local function StartHoney(inst)
    if inst.honeytask == nil then
        inst.honeythreshold = HONEY_LEVELS[1].threshold
        inst.honeycount = math.ceil(inst.honeythreshold * .5)
        inst.honeytask = inst:DoPeriodicTask(HONEY_PERIOD, DoHoneyTrail, 0)
    end
end

local function StopHoney(inst)
    if inst.honeytask ~= nil then
        inst.honeytask:Cancel()
        inst.honeytask = nil
    end
end

--------------------------------------------------------------------------

local function UpdatePlayerTargets(inst)
    local toadd = {}
    local toremove = {}
    local pos = inst.components.knownlocations:GetLocation("spawnpoint")

    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        toremove[k] = true
    end
    for i, v in ipairs(FindPlayersInRange(pos.x, pos.y, pos.z, TUNING.BEEQUEEN_DEAGGRO_DIST, true)) do
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

local function RetargetFn(inst)
    UpdatePlayerTargets(inst)

    local target = inst.components.combat.target
    local inrange = target ~= nil and inst:IsNear(target, TUNING.BEEQUEEN_ATTACK_RANGE + target:GetPhysicsRadius(0))

    if target ~= nil and target:HasTag("player") then
        local newplayer = inst.components.grouptargeter:TryGetNewTarget()
        return newplayer ~= nil
            and newplayer:IsNear(inst, inrange and TUNING.BEEQUEEN_ATTACK_RANGE + newplayer:GetPhysicsRadius(0) or TUNING.BEEQUEEN_AGGRO_DIST)
            and newplayer
            or nil,
            true
    end

    local nearplayers = {}
    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        if inst:IsNear(k, inrange and TUNING.BEEQUEEN_ATTACK_RANGE + k:GetPhysicsRadius(0) or TUNING.BEEQUEEN_AGGRO_DIST) then
            table.insert(nearplayers, k)
        end
    end
    return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and target:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("spawnpoint")) < TUNING.BEEQUEEN_DEAGGRO_DIST * TUNING.BEEQUEEN_DEAGGRO_DIST
end

local function bonus_damage_via_allergy(inst, target, damage, weapon)
    return (target:HasTag("allergictobees") and TUNING.BEE_ALLERGY_EXTRADAMAGE) or 0
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        local target = inst.components.combat.target
        if not (target ~= nil and
                target:HasTag("player") and
				target:IsNear(inst, (inst.focustarget_cd > 0 or inst.components.stuckdetection:IsStuck()) and TUNING.BEEQUEEN_ATTACK_RANGE + target:GetPhysicsRadius(0) or TUNING.BEEQUEEN_AGGRO_DIST)) then
            inst.components.combat:SetTarget(data.attacker)
        end
        inst.components.commander:ShareTargetToAllSoldiers(data.attacker)
    end
end

local function OnAttackOther(inst, data)
	inst.components.stuckdetection:Reset()

    if data.target ~= nil then
		local x, y, z = data.target.Transform:GetWorldPosition()
		TrySpawnHoney(inst, x, z, 1, 1.3, 4)
    end
end

local function OnMissOther(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = -inst.Transform:GetRotation() * DEGREES
	x = x + TUNING.BEEQUEEN_ATTACK_RANGE * math.cos(angle)
	z = z + TUNING.BEEQUEEN_ATTACK_RANGE * math.sin(angle)
	TrySpawnHoney(inst, x, z, 1, 1.3, 4)
end

--------------------------------------------------------------------------

local DEFAULT_COMMANDER_RANGE = 40
local BOOSTED_COMMANDER_RANGE = 80

local function UpdateCommanderRange(inst)
    local range = inst.components.commander.trackingdist - 4
    if range > DEFAULT_COMMANDER_RANGE then
        inst.components.commander:SetTrackingDistance(range)
    else
        inst.components.commander:SetTrackingDistance(DEFAULT_COMMANDER_RANGE)
        inst.commandertask:Cancel()
        inst.commandertask = nil
    end
end

local function BoostCommanderRange(inst, boost)
    inst.commanderboost = boost
    if boost then
        if inst.commandertask ~= nil then
            inst.commandertask:Cancel()
            inst.commandertask = nil
        end
        inst.components.commander:SetTrackingDistance(BOOSTED_COMMANDER_RANGE)
    elseif inst.components.commander.trackingdist > DEFAULT_COMMANDER_RANGE
        and inst.commandertask == nil
        and not inst:IsAsleep() then
        inst.commandertask = inst:DoPeriodicTask(1, UpdateCommanderRange)
    end
end

--------------------------------------------------------------------------

local PHASE2_HEALTH = .75
local PHASE3_HEALTH = .5
local PHASE4_HEALTH = .25

local function SetPhaseLevel(inst, phase)
    inst.focustarget_cd = TUNING.BEEQUEEN_FOCUSTARGET_CD[phase]
    inst.spawnguards_cd = TUNING.BEEQUEEN_SPAWNGUARDS_CD[phase]
    inst.spawnguards_maxchain = TUNING.BEEQUEEN_SPAWNGUARDS_CHAIN[phase]
    inst.spawnguards_threshold = phase > 1 and TUNING.BEEQUEEN_TOTAL_GUARDS or 1
end

local function EnterPhase2Trigger(inst)
    SetPhaseLevel(inst, 2)
    inst:PushEvent("screech")
end

local function EnterPhase3Trigger(inst)
    SetPhaseLevel(inst, 3)
    inst:PushEvent("screech")
end

local function EnterPhase4Trigger(inst)
    SetPhaseLevel(inst, 4)
    inst:PushEvent("screech")
end

local function OnSave(inst, data)
    data.boost = inst.components.commander.trackingdist > DEFAULT_COMMANDER_RANGE and math.ceil(inst.components.commander.trackingdist) or nil
end

local function OnLoad(inst, data)
    local healthpct = inst.components.health:GetPercent()
    SetPhaseLevel(
        inst,
        (healthpct > PHASE2_HEALTH and 1) or
        (healthpct > PHASE3_HEALTH and 2) or
        (healthpct > PHASE4_HEALTH and 3) or
        4
    )

    if data ~= nil and
        data.boost ~= nil and
        data.boost > inst.components.commander.trackingdist then
        inst.components.commander:SetTrackingDistance(data.boost)
        if not (inst.commanderboost or inst:IsAsleep()) then
            BoostCommanderRange(inst, false)
        end
    end
end

--------------------------------------------------------------------------

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

--------------------------------------------------------------------------

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
    end
    inst._sleeptask = not inst.components.health:IsDead() and inst:DoTaskInTime(10, inst.Remove) or nil

    if inst.commandertask ~= nil then
        inst.commandertask:Cancel()
        inst.commandertask = nil
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end

    BoostCommanderRange(inst, inst.commanderboost)
end

--------------------------------------------------------------------------

local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("flight") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "beequeen" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
        inst._playingmusic = false
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(1.4, 1.4, 1.4)

    inst.DynamicShadow:SetSize(4, 2)

    MakeFlyingGiantCharacterPhysics(inst, 500, 1.4)

    inst.AnimState:SetBank("bee_queen")
    inst.AnimState:SetBuild("bee_queen_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("bee")
    inst:AddTag("beequeen")
    inst:AddTag("insect")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/wings_LP", "flying")

    MakeInventoryFloatable(inst, "large", 0.1, {0.6, 1.0, 0.6})

    inst.entity:SetPristine()

    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        inst._playingmusic = false
        inst:DoPeriodicTask(1, PushMusic, 0)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('beequeen')

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper.diminishingreturns = true

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorewalls = true, allowocean = true }
    inst.components.locomotor.walkspeed = TUNING.BEEQUEEN_SPEED

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEQUEEN_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("healthtrigger")
    inst.components.healthtrigger:AddTrigger(PHASE2_HEALTH, EnterPhase2Trigger)
    inst.components.healthtrigger:AddTrigger(PHASE3_HEALTH, EnterPhase3Trigger)
    inst.components.healthtrigger:AddTrigger(PHASE4_HEALTH, EnterPhase4Trigger)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BEEQUEEN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEEQUEEN_ATTACK_PERIOD)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.BEEQUEEN_ATTACK_RANGE, TUNING.BEEQUEEN_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.battlecryenabled = false
    inst.components.combat.hiteffectsymbol = "hive_body"
    inst.components.combat.bonusdamagefn = bonus_damage_via_allergy

	inst:AddComponent("stuckdetection")
	inst.components.stuckdetection:SetTimeToStuck(2)

    inst:AddComponent("explosiveresist")

    inst:AddComponent("grouptargeter")
    inst:AddComponent("commander")
    inst.components.commander:SetTrackingDistance(DEFAULT_COMMANDER_RANGE)

    inst:AddComponent("timer")

    inst:AddComponent("sanityaura")

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(TUNING.BEEQUEEN_EPICSCARE_RANGE)

    inst:AddComponent("knownlocations")

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "hive_body")
    inst.components.freezable.diminishingreturns = true

    inst:SetStateGraph("SGbeequeen")
    inst:SetBrain(brain)

    inst.hit_recovery = TUNING.BEEQUEEN_HIT_RECOVERY
    inst.spawnguards_chain = 0
    SetPhaseLevel(inst, 1)

    inst.BoostCommanderRange = BoostCommanderRange
    inst.commanderboost = false
    inst.commandertask = nil

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.StartHoney = StartHoney
    inst.StopHoney = StopHoney
    inst.honeytask = nil
    inst.honeycount = 0
    inst.honeythreshold = 0
    inst.usedhoney = {}
    inst.availablehoney = {}
    for i = 1, MAX_HONEY_VARIATIONS do
        table.insert(inst.availablehoney, i)
    end
    inst:StartHoney()

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("onmissother", OnMissOther)

    return inst
end

return Prefab("beequeen", fn, assets, prefabs)
