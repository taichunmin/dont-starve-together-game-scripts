local brain = require "brains/eyeofterrorbrain"

local assets =
{
    Asset("ANIM", "anim/eyeofterror_action.zip"),
    Asset("ANIM", "anim/eyeofterror_basic.zip"),
}

local twinassets =
{
    Asset("ANIM", "anim/eyeofterror_action.zip"),
    Asset("ANIM", "anim/eyeofterror_basic.zip"),
    Asset("ANIM", "anim/eyeofterror_twin1_build.zip"),
    Asset("ANIM", "anim/eyeofterror_twin2_build.zip"),
}

local prefabs =
{
    "boat_leak",
    "chesspiece_eyeofterror_sketch",
    "eyemaskhat",
    "eyeofterror_arrive_fx",
    "eyeofterror_mini_projectile",
    "boss_ripple_fx",
    "eyeofterror_sinkhole",
    "milkywhites",
    "slide_puff",
    "shieldofterror",
}

local twinprefabs =
{
    "boat_leak",
    "eyeofterror_arrive_fx",
    "boss_ripple_fx",
    "eyeofterror_sinkhole",
    "gears",
    "greengem",
    "nightmarefuel",
    "slide_puff",
    "transistor",
    "trinket_6",
    "yellowgem",
    "winter_ornament_boss_eyeofterror1",
    "winter_ornament_boss_eyeofterror2",
}

local twinmanagerprefabs =
{
    "chesspiece_twinsofterror_sketch",
    "shieldofterror",
    "twinofterror1",
    "twinofterror2",
}

--MUSIC------------------------------------------------------------------------
local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("INLIMBO") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 60 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "eyeofterror" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 64) then
        inst._playingmusic = false
    end
end

local function OnMusicDirty(inst)
    if not TheNet:IsDedicated() then
        if inst._musictask ~= nil then
            inst._musictask:Cancel()
        end
        inst._musictask = inst:DoPeriodicTask(1, PushMusic, 0.5)
    end
end
--MUSIC------------------------------------------------------------------------

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "decor", "eyeofterror", "FX", "INLIMBO", "NOCLICK", "notarget", "playerghost", "wall" }
local RETARGET_ONEOF_TAGS = { "epic", "player" }    -- The eye tries to fight players and also other Epic monsters
local function update_targets(inst)
    local to_remove = {}
    local pos = inst.components.knownlocations:GetLocation("spawnpoint") or inst:GetPosition()

    for k, _ in pairs(inst.components.grouptargeter:GetTargets()) do
        to_remove[k] = true
    end

    local ents_near_spawnpoint = TheSim:FindEntities(
        pos.x, 0, pos.z,
        TUNING.EYEOFTERROR_DEAGGRO_DIST,
        RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS
    )
    for _, v in ipairs(ents_near_spawnpoint) do
        if to_remove[v] then
            to_remove[v] = nil
        else
            inst.components.grouptargeter:AddTarget(v)
        end
    end

    for non_target, _ in pairs(to_remove) do
        inst.components.grouptargeter:RemoveTarget(non_target)
    end
end

local TARGET_DIST = 20
local function get_target_test_range(use_short_dist, target)
    return (use_short_dist and 8 + target:GetPhysicsRadius(0)) or TARGET_DIST
end

local function RetargetFn(inst)
    update_targets(inst)

    local current_target = inst.components.combat.target
    local target_in_range = current_target ~= nil and current_target:IsNear(inst, 8 + current_target:GetPhysicsRadius(0))

    if current_target ~= nil and current_target:HasTag("player") then
        local new_target = inst.components.grouptargeter:TryGetNewTarget()
        return (new_target ~= nil
            and new_target:IsNear(inst, get_target_test_range(target_in_range, new_target))
            and new_target)
            or nil,
            true
    end

    local targets_in_range = {}
    for target, _ in pairs(inst.components.grouptargeter:GetTargets()) do
        if inst:IsNear(target, get_target_test_range(target_in_range, target)) then
            table.insert(targets_in_range, target)
        end
    end
    return (#targets_in_range > 0 and targets_in_range[math.random(#targets_in_range)]) or nil, true
end

local TARGET_DSQ = TARGET_DIST * TARGET_DIST
local function KeepTargetFn(inst, target)
    return not inst:IsInLimbo() and inst.components.combat:CanTarget(target)
        and target:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("spawnpoint")) < TARGET_DSQ
end

local function OnAttacked(inst, data)
    -- Target our attackers, unless it's one of our soldiers somehow.
    if data.attacker and not inst.components.commander:IsSoldier(data.attacker) then
        local current_target = inst.components.combat.target
        if current_target == nil or not current_target:IsNear(inst, TARGET_DIST) then
            inst.components.combat:SetTarget(data.attacker)
            inst.components.commander:ShareTargetToAllSoldiers(data.attacker)
        end
    end
end

--------------------------------------------------------------------------

local function ClearRecentlyCharged(inst)
    inst._recentlycharged = nil
end

local function on_other_collided(inst, other)
    if not other.components.health or other.components.health:IsDead() then
        return
    end

    -- Lazy initialize the recently charged list if it doesn't exist yet.
    -- If it does, check if there's an existing timestamp for this "other".
    local current_time = GetTime()
    local prev_value = nil
    if inst._recentlycharged == nil then
        inst._recentlycharged = {}
    else
        prev_value = inst._recentlycharged[other]
    end

    -- If we had a timestamp for this "other" and hit it too recently, don't hit it again.
    if prev_value ~= nil and prev_value - current_time < 3 then
        return
    end
    inst._recentlycharged[other] = current_time

    inst.components.combat:DoAttack(other)
end

local function OnCollide(inst, other)
    if other ~= nil and other:IsValid() then
        on_other_collided(inst, other)
    end
end

local function GetDesiredSoldiers(inst)
    if not inst.components.combat:HasTarget() then
        return 1
    else
        return (inst.sg.mem.transformed and TUNING.EYEOFTERROR_MOUTH_MINGUARDS)
            or TUNING.EYEOFTERROR_EYE_MINGUARDS
    end
end

local function OnFinishedLeaving(inst)
    inst._leftday = TheWorld.state.cycles
end

local function FlybackHealthUpdate(inst)
    if inst._leftday ~= nil then
        local day_difference = math.min(TheWorld.state.cycles - inst._leftday, 1/TUNING.EYEOFTERROR_HEALTHPCT_PERDAY)
        if day_difference > 0 then
            inst.components.health:DoDelta(day_difference * TUNING.EYEOFTERROR_HEALTHPCT_PERDAY * inst.components.health.maxhealth)
        end

        if inst._transformonhealthupdate then
            if inst.components.health:GetPercent() > TUNING.EYEOFTERROR_TRANSFORMPERCENT then
                inst.AnimState:Hide("mouth")
                inst.AnimState:Hide("ball_mouth")
                inst.AnimState:Show("eye")
                inst.AnimState:Show("ball_eye")
                inst.sg.mem.transformed = false
            end
        end

        inst._leftday = nil
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

local function OnSave(inst, data)
    if inst.sg.mem.transformed then
        data.is_transformed = inst.sg.mem.transformed
    end

    if inst._leftday ~= nil then
        data.leftday = inst._leftday
    end

    data.loot_dropped = inst._loot_dropped
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst._loot_dropped = data._loot_dropped

        if data.leftday then
            inst._leftday = data.leftday
        end

        if data.is_transformed then
            inst.AnimState:Show("mouth")
            inst.AnimState:Show("ball_mouth")

            inst.AnimState:Hide("eye")
            inst.AnimState:Hide("ball_eye")

            inst.sg.mem.transformed = true
        end
    end
end

--------------------------------------------------------------------------

local DEFAULT_COMMANDER_RANGE = 40
local function common_fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeTinyFlyingCharacterPhysics(inst, 100, 1.5)

    inst.DynamicShadow:SetSize(6, 2)

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:Hide("ball_mouth")
    inst.AnimState:Hide("mouth")
    inst.AnimState:PlayAnimation("eye_idle", true)

    MakeInventoryFloatable(inst, "large")

    inst:AddTag("eyeofterror")

    inst:AddTag("epic")
    inst:AddTag("flying")
    inst:AddTag("hostile")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("largecreature")
    inst:AddTag("monster")
    inst:AddTag("noepicmusic")
    inst:AddTag("scarytoprey")

    -- Optimization tags
    inst:AddTag("sleeper")      -- From sleeper component

    inst._musicdirty = net_event(inst.GUID, "eyeofterror._musicdirty", "musicdirty")
    inst._playingmusic = false
    --inst._musictask = nil
    OnMusicDirty(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)

        return inst
    end

    ------------------------------------------
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 4.5
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true }

    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(data.health)
    inst.components.health.destroytime = 5

    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(data.damage or TUNING.EYEOFTERROR_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.EYEOFTERROR_DAMAGEPLAYERPERCENT
    inst.components.combat:SetRange(TUNING.EYEOFTERROR_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "swap_fire"
    inst.components.combat:SetAttackPeriod(TUNING.EYEOFTERROR_ATTACKPERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    ------------------------------------------
    inst:AddComponent("explosiveresist")

    ------------------------------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(TUNING.EYEOFTERROR_SLEEPRESIST)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    ------------------------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable(data.chanceloottable)

    ------------------------------------------
    inst:AddComponent("inspectable")

    ------------------------------------------
    inst:AddComponent("timer")

    -- Do initial cooldowns, so the boss doesn't start the fight by doing all of its special moves immediately.
    -- NOTE: These are intended to be different from the normal cooldowns in the stategraph.
    inst.components.timer:StartTimer("spawneyes_cd", GetRandomWithVariance(10, 3))
    inst.components.timer:StartTimer("charge_cd", GetRandomWithVariance(4, 1))
    inst.components.timer:StartTimer("focustarget_cd", GetRandomWithVariance(20, 5))

    ------------------------------------------
    inst:AddComponent("knownlocations")

    ------------------------------------------
    inst:AddComponent("grouptargeter")

    ------------------------------------------
    inst:AddComponent("commander")
    inst.components.commander:SetTrackingDistance(DEFAULT_COMMANDER_RANGE)

    ------------------------------------------
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE

    ------------------------------------------
    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(TUNING.EYEOFTERROR_EPICSCARE_RANGE)

    ------------------------------------------
    MakeLargeBurnableCharacter(inst, "swap_fire")

    ------------------------------------------
    MakeHugeFreezableCharacter(inst)
    inst.components.freezable.diminishingreturns = true

    ------------------------------------------
    -- Events here.
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("finished_leaving", OnFinishedLeaving)

    ------------------------------------------
    -- Instance variables here
    inst._soundpath = data.soundpath
    inst._cooldowns = data.cooldowns
    inst._chargedata = data.chargedata
    inst._mouthspawncount = data.mouthspawncount
    inst._chompdamage = data.chompdamage
    --inst._recentlycharged = nil       -- Used by the charge functions to help avoid continuous collisions.
    --inst._loot_dropped = nil          -- For handling save/loads during death

    ------------------------------------------
    -- Instance functions here
    inst.OnCollide = OnCollide
    inst.ClearRecentlyCharged = ClearRecentlyCharged
    inst.GetDesiredSoldiers = GetDesiredSoldiers
    inst.FlybackHealthUpdate = FlybackHealthUpdate
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    ------------------------------------------
    inst:SetStateGraph("SGeyeofterror")
    inst:SetBrain(brain)

    return inst
end

------------------------------------------------------------------------

SetSharedLootTable("eyeofterror",
{
    {"chesspiece_eyeofterror_sketch",   1.00},
    {"eyemaskhat",                      1.00},
    {"milkywhites",                     1.00},
    {"milkywhites",                     1.00},
    {"milkywhites",                     1.00},
    {"milkywhites",                     0.50},
    {"milkywhites",                     0.50},
    {"monstermeat",                     1.00},
    {"monstermeat",                     1.00},
    {"monstermeat",                     0.50},
    {"monstermeat",                     0.50},
})

local function eyeofterror_should_transform(inst, health_data)
    if health_data and health_data.newpercent < TUNING.EYEOFTERROR_TRANSFORMPERCENT then
        inst:PushEvent("health_transform")
    end
end

local function eyeofterror_setspawntarget(inst, target)
    inst.components.combat:SetTarget(target)
end

local function eyeofterror_isdying(inst)
    return inst.components.health:IsDead()
end

local function eyeofterror_onleave_entitysleepcleanup(inst)
    if inst:IsAsleep() then
        inst:PushEvent("finished_leaving")
    end
end

local function eyefn()
	local EYE_DATA =
	{
		bank = "eyeofterror",
		build = "eyeofterror_basic",
		soundpath = "terraria1/eyeofterror/",
		cooldowns =
		{
			charge =                TUNING.EYEOFTERROR_CHARGECD,
			mouthcharge =           TUNING.EYEOFTERROR_MOUTHCHARGECD,
			spawn =                 TUNING.EYEOFTERROR_SPAWNCD,
			focustarget =           TUNING.EYEOFTERROR_FOCUSCD,
		},
		chargedata =
		{
			eyechargespeed =        TUNING.EYEOFTERROR_CHARGESPEED,
			eyechargetimeout =      1.00,
			mouthchargespeed =      1.25*TUNING.EYEOFTERROR_CHARGESPEED,
			mouthchargetimeout =    1.00,
			tauntchance =           1.00,
		},
		health = TUNING.EYEOFTERROR_HEALTH,
		damage = TUNING.EYEOFTERROR_DAMAGE,
		chompdamage = TUNING.EYEOFTERROR_AOE_DAMAGE,
		mouthspawncount = TUNING.EYEOFTERROR_MINGUARDS_PERSPAWN,
		chanceloottable = "eyeofterror",
	}

    local inst = common_fn(EYE_DATA)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.IsDying = eyeofterror_isdying

    ------------------------------------------
    inst._transformonhealthupdate = true

    ------------------------------------------
    inst:ListenForEvent("set_spawn_target", eyeofterror_setspawntarget)
    inst:ListenForEvent("healthdelta", eyeofterror_should_transform)
    inst:ListenForEvent("leave", eyeofterror_onleave_entitysleepcleanup)

    return inst
end

------------------------------------------------------------------------

SetSharedLootTable("twinofterror1",
{
    --{"chesspiece_eyeofterror_sketch",   1.00},
    --{"shieldofterror",                  1.00},
    {"yellowgem",       1.00},
    {"gears",           1.00},
    {"gears",           1.00},
    {"gears",           1.00},
    {"gears",           0.50},
    {"gears",           0.50},
    {"transistor",      1.00},
    {"transistor",      1.00},
    {"transistor",      0.75},
    {"nightmarefuel",   1.00},
    {"nightmarefuel",   1.00},
    {"nightmarefuel",   0.50},
    {"nightmarefuel",   0.50},
    {"trinket_6",       1.00},
    {"trinket_6",       0.50},
})

local function twin1fn()
	local TWIN1_DATA =
	{
		bank = "eyeofterror",
		build = "eyeofterror_twin1_build",
		soundpath = "terraria1/robo_eyeofterror/",
		cooldowns =
		{
			charge =                TUNING.TWIN1_CHARGECD,
			mouthcharge =           TUNING.TWIN1_MOUTHCHARGECD,
			spawn =                 TUNING.TWIN1_SPAWNCD,
			focustarget =           TUNING.TWIN1_FOCUSCD,
		},
		chargedata =
		{
			eyechargespeed =        TUNING.TWIN1_CHARGESPEED,
			eyechargetimeout =      TUNING.TWIN1_CHARGETIMEOUT,
			mouthchargespeed =      TUNING.TWIN1_MOUTH_CHARGESPEED,
			mouthchargetimeout =    TUNING.TWIN1_MOUTH_CHARGETIMEOUT,
			tauntchance =           TUNING.TWIN1_TAUNT_CHANCE,
		},
		health = TUNING.TWIN1_HEALTH,
		damage = TUNING.TWIN1_DAMAGE,
		chompdamage = TUNING.TWIN1_AOE_DAMAGE,
		mouthspawncount = TUNING.TWIN1_MINGUARDS_PERSPAWN,
		chanceloottable = "twinofterror1",
	}

    local inst = common_fn(TWIN1_DATA)

    inst:AddTag("mech")
    inst:AddTag("soulless")

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------
    inst.components.sleeper:SetResistance(2*TUNING.EYEOFTERROR_SLEEPRESIST)

    return inst
end

------------------------------------------------------------------------

SetSharedLootTable("twinofterror2",
{
    --{"chesspiece_eyeofterror_sketch",   1.00},
    --{"shieldofterror",                  1.00},
    {"greengem",        1.00},
    {"gears",           1.00},
    {"gears",           1.00},
    {"gears",           1.00},
    {"gears",           0.50},
    {"gears",           0.50},
    {"transistor",      1.00},
    {"transistor",      1.00},
    {"transistor",      0.75},
    {"nightmarefuel",   1.00},
    {"nightmarefuel",   1.00},
    {"nightmarefuel",   0.50},
    {"nightmarefuel",   0.50},
    {"trinket_6",       1.00},
    {"trinket_6",       0.50},
})

local function twin2fn()
	local TWIN2_DATA =
	{
		bank = "eyeofterror",
		build = "eyeofterror_twin2_build",
		soundpath = "terraria1/robo_eyeofterror2/",
		cooldowns =
		{
			charge =                TUNING.TWIN2_CHARGECD,
			mouthcharge =           TUNING.TWIN2_MOUTHCHARGECD,
			spawn =                 TUNING.TWIN2_SPAWNCD,
			focustarget =           TUNING.TWIN2_FOCUSCD,
		},
		chargedata =
		{
			eyechargespeed =        TUNING.TWIN2_CHARGESPEED,
			eyechargetimeout =      TUNING.TWIN2_CHARGETIMEOUT,
			mouthchargespeed =      TUNING.TWIN2_MOUTH_CHARGESPEED,
			mouthchargetimeout =    TUNING.TWIN2_MOUTH_CHARGETIMEOUT,
			tauntchance =           TUNING.TWIN2_TAUNT_CHANCE,
		},
		health = TUNING.TWIN2_HEALTH,
		damage = TUNING.TWIN2_DAMAGE,
		chompdamage = TUNING.TWIN2_AOE_DAMAGE,
		mouthspawncount = TUNING.TWIN2_MINGUARDS_PERSPAWN,
		chanceloottable = "twinofterror2",
	}

    local inst = common_fn(TWIN2_DATA)

    inst:AddTag("mech")
    inst:AddTag("soulless")

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------
    inst._nospeech = true

    ------------------------------------------
    inst.components.sleeper:SetResistance(2*TUNING.EYEOFTERROR_SLEEPRESIST)

    return inst
end

------------------------------------------------------------------------

local EXTRA_LOOT = {"chesspiece_twinsofterror_sketch", "shieldofterror"}
local function hookup_twin_listeners(inst, twin)
    inst:ListenForEvent("onremove", function(t)
        local et = inst.components.entitytracker
        if et:GetEntity("twin1") == nil and et:GetEntity("twin2") == nil then
            inst:Remove()
        end
    end, twin)

    inst:ListenForEvent("death", function(t)
        local et = inst.components.entitytracker
        local t1 = et:GetEntity("twin1")
        local t2 = et:GetEntity("twin2")
        if (t1 == nil or t1.components.health:IsDead()) and (t2 == nil or t2.components.health:IsDead()) then
            -- This only really works because SetLoot doesn't clear lootdropper.chanceloottable
            t.components.lootdropper:SetLoot(EXTRA_LOOT)
        end
    end, twin)

    inst:ListenForEvent("turnoff_terrarium", function(t)
        local et = inst.components.entitytracker
        local t1 = et:GetEntity("twin1")
        local t2 = et:GetEntity("twin2")
        if (t1 == nil or t1.components.health:IsDead())
                and (t2 == nil or t2.components.health:IsDead()) then
            inst:PushEvent("turnoff_terrarium")
            inst:Remove()
        end
    end, twin)

    inst:ListenForEvent("finished_leaving", function(t)
        if t ~= nil and not t:IsInLimbo() then
            t:RemoveFromScene()
        end

        local et = inst.components.entitytracker
        local t1 = et:GetEntity("twin1")
        local t2 = et:GetEntity("twin2")
        if (t1 == nil or t1:IsInLimbo()) and (t2 == nil or t2:IsInLimbo()) then
            inst:PushEvent("finished_leaving")
        end
    end, twin)

    inst:ListenForEvent("healthdelta", function(t, data)
        local et = inst.components.entitytracker
        local t1 = et:GetEntity("twin1")
        local t2 = et:GetEntity("twin2")

        local t1_health = (t1 == nil and 0) or t1.components.health.currenthealth
        local t2_health = (t2 == nil and 0) or t2.components.health.currenthealth
        if (t1_health + t2_health) < ((TUNING.TWIN1_HEALTH + TUNING.TWIN2_HEALTH) * TUNING.EYEOFTERROR_TRANSFORMPERCENT) then
            if t1 ~= nil then
                t1:PushEvent("health_transform")
            end

            if t2 ~= nil then
                t2:PushEvent("health_transform")
            end
        end
    end, twin)
end

local UP_VEC3 = Vector3(0, 1, 0)
local TWINS_SPAWN_OFFSET = 5
local function get_spawn_positions(inst, targeted_player)
    local manager_position = inst:GetPosition()
    local player_position = targeted_player:GetPosition()
    local manager_to_player = (player_position - manager_position):Normalize()

    local offset_unit = manager_to_player:Cross(UP_VEC3):Normalize()

    local offset1_angle = math.atan2(offset_unit.z, offset_unit.x)
    local twin1_offset = FindWalkableOffset(manager_position, offset1_angle, TWINS_SPAWN_OFFSET, nil, false, true, nil, true, true)
        or (offset_unit * TWINS_SPAWN_OFFSET)

    local offset2_angle = offset1_angle + PI
    local twin2_offset = FindWalkableOffset(manager_position, offset2_angle, TWINS_SPAWN_OFFSET, nil, false, true, nil, true, true)
        or (offset_unit * -1 * TWINS_SPAWN_OFFSET)

    return manager_position + twin1_offset, manager_position + twin2_offset
end

local function spawn_arriving_twins(inst, targeted_player)
    local twin1spawnpos, twin2spawnpos = get_spawn_positions(inst, targeted_player)

    local twin1 = SpawnPrefab("twinofterror1")
    inst.components.entitytracker:TrackEntity("twin1", twin1)
    twin1.Transform:SetPosition(twin1spawnpos:Get())
    twin1.sg:GoToState("arrive")
    hookup_twin_listeners(inst, twin1)

    local twin2 = SpawnPrefab("twinofterror2")
    inst.components.entitytracker:TrackEntity("twin2", twin2)
    twin2.Transform:SetPosition(twin2spawnpos:Get())
    twin2.sg:GoToState("arrive_delay")
    hookup_twin_listeners(inst, twin2)

    -- Reset the hardmode reset counter whenever the boss is spawned back in to fight.
    inst._hardmode_days_reset_counter = TUNING.TWINS_RESET_DAY_COUNT
end

local function on_enterlimbo(inst)
    local twin1 = inst.components.entitytracker:GetEntity("twin1")
    if twin1 and not twin1:IsInLimbo() then
        twin1:RemoveFromScene()
    end

    local twin2 = inst.components.entitytracker:GetEntity("twin2")
    if twin2 and not twin2:IsInLimbo() then
        twin2:RemoveFromScene()
    end
end

local function flyback_twins(inst, targeted_player)
    local twin1returnpos, twin2returnpos = get_spawn_positions(inst, targeted_player)

    local twin1 = inst.components.entitytracker:GetEntity("twin1")
    if twin1 then
        twin1:ReturnToScene()
        twin1.Transform:SetPosition(twin1returnpos:Get())
        twin1.sg:GoToState("flyback")
    end

    local twin2 = inst.components.entitytracker:GetEntity("twin2")
    if twin2 then
        if not twin1 then
            twin2._nospeech = false -- If our other twin died, we should start playing speech lines.
        end
        twin2:ReturnToScene()
        twin2.Transform:SetPosition(twin2returnpos:Get())
        twin2.sg:GoToState("flyback_delay")
    end

    -- Reset the hardmode reset counter whenever the boss is spawned back in to fight.
    inst._hardmode_days_reset_counter = TUNING.TWINS_RESET_DAY_COUNT
end

local function twinsmanager_leave(inst)
    local et = inst.components.entitytracker
    local t1 = et:GetEntity("twin1")
    if t1 ~= nil then
        if t1:IsAsleep() then
            t1:RemoveFromScene()
        else
            t1:PushEvent("leave")
        end
    end

    local t2 = et:GetEntity("twin2")
    if t2 ~= nil then
        if t2:IsAsleep() then
            t2:RemoveFromScene()
        else
            t2:PushEvent("leave")
        end
    end

    if (t1 == nil or t1:IsInLimbo()) and (t2 == nil or t2:IsInLimbo()) then
        inst:PushEvent("finished_leaving")
    end
end

local function twinsmanager_isdying(inst)
    local et = inst.components.entitytracker
    local t1 = et:GetEntity("twin1")
    local t2 = et:GetEntity("twin2")

    if t1 == nil and t2 == nil then
        return false
    elseif t1 == nil then
        return t2.components.health:IsDead()
    elseif t2 == nil then
        return t1.components.health:IsDead()
    else
        return false
    end
end

local function manager_setspawntarget(inst, target)
    local twin1 = inst.components.entitytracker:GetEntity("twin1")
    if twin1 then
        twin1.components.combat:SetTarget(target)
    end

    local twin2 = inst.components.entitytracker:GetEntity("twin2")
    if twin2 then
        twin2.components.combat:SetTarget(target)
    end
end

local function on_cycles_twinmanager(inst, cycles)
    inst._hardmode_days_reset_counter = inst._hardmode_days_reset_counter - 1
    if inst._hardmode_days_reset_counter <= 0 then
        local et = inst.components.entitytracker
        local t1 = et:GetEntity("twin1")
        local t2 = et:GetEntity("twin2")

        if t1 ~= nil then
            t1:Remove()
        end
        if t2 ~= nil then
            t2:Remove()
        end
    end
end

local function OnTwinManagerSave(inst, data)
    data.hardmode_reset_counter = inst._hardmode_days_reset_counter or 0
end

local function OnTwinManagerLoad(inst, data)
    if data then
        inst._hardmode_days_reset_counter = data.hardmode_reset_counter
    end
end

local function OnTwinManagerLoadPostPass(inst, newents, data)
    local manager_in_limbo = inst:IsInLimbo()

    local t1 = inst.components.entitytracker:GetEntity("twin1")
    if t1 then
        hookup_twin_listeners(inst, t1)
        if manager_in_limbo then
            t1:RemoveFromScene()
        end
    end

    local t2 = inst.components.entitytracker:GetEntity("twin2")
    if t2 then
        hookup_twin_listeners(inst, t2)
        if manager_in_limbo then
            t2:RemoveFromScene()
        end
    end
end

local function twinmanagerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------
    inst.IsDying = twinsmanager_isdying

    ------------------------------------------
    inst._hardmode_days_reset_counter = TUNING.TWINS_RESET_DAY_COUNT

    ------------------------------------------
    inst:AddComponent("entitytracker")

    ------------------------------------------
    inst:ListenForEvent("arrive", spawn_arriving_twins)
    inst:ListenForEvent("enterlimbo", on_enterlimbo)
    inst:ListenForEvent("flyback", flyback_twins)
    inst:ListenForEvent("leave", twinsmanager_leave)
    inst:ListenForEvent("set_spawn_target", manager_setspawntarget)

    inst:WatchWorldState("cycles", on_cycles_twinmanager)

    ------------------------------------------
    inst.OnSave = OnTwinManagerSave
    inst.OnLoad = OnTwinManagerLoad
    inst.OnLoadPostPass = OnTwinManagerLoadPostPass

    return inst
end

return Prefab("eyeofterror", eyefn, assets, prefabs),
    Prefab("twinofterror1", twin1fn, twinassets, twinprefabs),
    Prefab("twinofterror2", twin2fn, twinassets, twinprefabs),
    Prefab("twinmanager", twinmanagerfn, twinassets, twinmanagerprefabs)
