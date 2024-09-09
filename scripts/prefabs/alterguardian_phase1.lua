local assets =
{
    Asset("ANIM", "anim/alterguardian_phase1.zip"),
    Asset("ANIM", "anim/alterguardian_spawn_death.zip"),
}

local prefabs =
{
    "alterguardian_phase2",
    "alterguardian_summon_fx",
    "gestalt_alterguardian_projectile",
    "mining_moonglass_fx",
    "moonrocknugget",
}

SetSharedLootTable("alterguardian_phase1",
{
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      0.66},
    {"moonrocknugget",      0.66},
})

local brain = require "brains/alterguardian_phase1brain"

--MUSIC------------------------------------------------------------------------
local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("nomusic") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "alterguardian_phase1", duration = 2 })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
        inst._playingmusic = false
    end
end

local function OnMusicDirty(inst)
    if not TheNet:IsDedicated() then
        if inst._musictask ~= nil then
            inst._musictask:Cancel()
        end
        inst._musictask = inst:DoPeriodicTask(1, PushMusic)
        PushMusic(inst)
    end
end

local function SetNoMusic(inst, val)
    if val then
        inst:AddTag("nomusic")
    else
        inst:RemoveTag("nomusic")
    end
    inst._musicdirty:push()
    OnMusicDirty(inst)
end
--MUSIC------------------------------------------------------------------------

local function play_custom_hit(inst)
    if not inst.components.timer:TimerExists("hitsound_cd") then
        if inst._is_shielding then
            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian1/hit")
        else
            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian1/onothercollide")
        end

        inst.components.timer:StartTimer("hitsound_cd", 5*FRAMES)
    end
end

local TARGET_DIST = TUNING.ALTERGUARDIAN_PHASE1_TARGET_DIST
local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "shadowminion" }
local function Retarget(inst)
    local gx, gy, gz = inst.Transform:GetWorldPosition()
    local potential_targets = TheSim:FindEntities(
        gx, gy, gz, TARGET_DIST,
        RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS
    )

    local newtarget = nil
    for _, target in ipairs(potential_targets) do
        if target ~= inst and target.entity:IsVisible()
                and inst.components.combat:CanTarget(target)
                and target:IsOnValidGround() then
            newtarget = target
            break
        end
    end

    if newtarget ~= nil and newtarget ~= inst.components.combat.target then
        return newtarget, true
    else
        return nil
    end
end

local MAX_CHASEAWAY_DIST_SQ = 625 --25 * 25
local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and target:IsOnValidGround()
            and target:GetDistanceSqToPoint(inst.Transform:GetWorldPosition()) < MAX_CHASEAWAY_DIST_SQ
end

local function teleport_override_fn(inst)
    local ipos = inst:GetPosition()
    local offset = FindWalkableOffset(ipos, TWOPI*math.random(), 10, 8, true, false)
        or FindWalkableOffset(ipos, TWOPI*math.random(), 14, 8, true, false)

    return (offset ~= nil and ipos + offset) or ipos
end

local function OnAttacked(inst, data)
    inst.components.combat:SuggestTarget(data.attacker)
    play_custom_hit(inst)
end

local function OnPhaseTransition(inst)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local target = inst.components.combat.target

    inst:Remove()

    local phase2 = SpawnPrefab("alterguardian_phase2")
    phase2.Transform:SetPosition(px, py, pz)
    phase2.components.combat:SuggestTarget(target)
    phase2.sg:GoToState("spawn")
end

local function onothercollide(inst, other)
    if not other:IsValid() then
        return

    elseif other:HasTag("smashable") and other.components.health ~= nil then
        other.components.health:Kill()

    elseif other.components.workable ~= nil
            and other.components.workable:CanBeWorked()
            and other.components.workable.action ~= ACTIONS.NET then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)

	elseif other.components.combat ~= nil
		and other.components.health ~= nil and not other.components.health:IsDead()
		and (other:HasTag("wall") or other:HasTag("structure"))
		then
        inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian1/onothercollide")
        inst.components.combat:DoAttack(other)
    end
end

local COLLISION_DSQ = 42
local function oncollide(inst, other)
    if inst._collisions[other] == nil and other ~= nil and other:IsValid()
            and Vector3(inst.Physics:GetVelocity()):LengthSq() > COLLISION_DSQ then
        ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
        inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
        inst._collisions[other] = true
    end
end

local function EnableRollCollision(inst, enable)
    if enable then
        inst.Physics:SetCollisionCallback(oncollide)
        inst._collisions = {}
    else
        inst.Physics:SetCollisionCallback(nil)
        inst._collisions = nil
    end
end

local function find_gestalt_target(gestalt)
    local gx, gy, gz = gestalt.Transform:GetWorldPosition()
    local target = nil
    local rangesq = 36
    for _, v in ipairs(AllPlayers) do
        if not IsEntityDeadOrGhost(v) and
                not (v.sg:HasStateTag("knockout") or
                    v.sg:HasStateTag("sleeping") or
                    v.sg:HasStateTag("bedroll") or
                    v.sg:HasStateTag("tent") or
                    v.sg:HasStateTag("waking")) and
                v.entity:IsVisible() then

            local distsq = v:GetDistanceSqToPoint(gx, 0, gz)
            if distsq < rangesq then
                rangesq = distsq
                target = v
            end
        end
    end

    return target
end

local MIN_GESTALTS, MAX_GESTALTS = 6, 10
local EXTRA_GESTALTS_BYHEALTH = 12
local MIN_SUMMON_RANGE, MAX_SUMMON_RANGE = 5, 7
local function DoGestaltSummon(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local spawn_warning = SpawnPrefab("alterguardian_summon_fx")
    spawn_warning.Transform:SetScale(1.2, 1.2, 1.2)
    spawn_warning.Transform:SetPosition(ix, iy, iz)

    -- A random amount of spawns plus a base amount based on missing health.
    local num_gestalts = GetRandomMinMax(MIN_GESTALTS, MAX_GESTALTS) + math.ceil((1 - inst.components.health:GetPercent()) * EXTRA_GESTALTS_BYHEALTH)

    local angle_increment = 3.75*PI / num_gestalts -- almost 2pi twice; loop 2 times, but slightly offset
    local initial_angle = TWOPI*math.random()

    for i = 1, num_gestalts do
        -- Spawn a collection of gestalts in a haphazard ring around the boss.
        -- The gestalts are undirected, but will target somebody if they're nearby.

        inst:DoTaskInTime(2.0 + (i*4*FRAMES), function(inst2)
            local gestalt = SpawnPrefab("gestalt_alterguardian_projectile")
            if gestalt ~= nil then
                -- NOTE: Deliberately not square rooting this radius;
                -- clustering closer to the boss is fine behaviour.
                local r = GetRandomMinMax(MIN_SUMMON_RANGE, MAX_SUMMON_RANGE)
                local angle = initial_angle + GetRandomWithVariance((i - 1) * angle_increment, PI/8)
                local x, z = r * math.cos(angle), r * math.sin(angle)

                gestalt.Transform:SetPosition(ix + x, iy + 0, iz + z)

                local target = find_gestalt_target(gestalt)
                if target ~= nil then
                    gestalt:ForceFacePoint(target:GetPosition())
                    gestalt:SetTargetPosition(target:GetPosition())
                end
            end
        end)
    end

    inst:DoTaskInTime(2.0 + (num_gestalts*4*FRAMES) + 1.0, function(inst2)
        spawn_warning:PushEvent("endloop")
    end)

    inst.components.timer:StartTimer("summon_cooldown", TUNING.ALTERGUARDIAN_PHASE1_SUMMONCOOLDOWN)
end

local function EnterShield(inst)
    inst._is_shielding = true

    inst.components.health:SetAbsorptionAmount(TUNING.ALTERGUARDIAN_PHASE1_SHIELDABSORB)

    if not inst.components.timer:TimerExists("summon_cooldown") then
        DoGestaltSummon(inst)
    end
end

local function ExitShield(inst)
    inst._is_shielding = nil

    inst.components.health:SetAbsorptionAmount(0)
end

local function CalcSanityAura(inst, observer)
    return (inst.components.combat.target ~= nil and TUNING.SANITYAURA_HUGE) or TUNING.SANITYAURA_LARGE
end

local function OnSave(inst, data)
    data.loot_dropped = inst._loot_dropped
    data.prespawn_idling = (inst.sg.currentstate.name == "prespawn_idle")
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst._loot_dropped = data.loot_dropped
        if data.prespawn_idling then
            inst.sg:GoToState("prespawn_idle")
        end
    end
end

local function OnEntitySleep(inst)
    if inst.components.health:IsDead() then
        return
    end

    -- If we're hurt, set a time so that, when we wake up, we can regain health.
    if inst.components.health:IsHurt() then
        inst._start_sleep_time = GetTime()
    end
end

local HEALTH_GAIN_RATE = TUNING.ALTERGUARDIAN_PHASE1_HEALTH / (TUNING.TOTAL_DAY_TIME * 5)
local function gain_sleep_health(inst)
    local time_diff = GetTime() - inst._start_sleep_time
    if time_diff > 0.0001 then
        inst.components.health:DoDelta(HEALTH_GAIN_RATE * time_diff)
    end
end

local function OnEntityWake(inst)
    -- If a sleep time was set, gain health as appropriate.
    if inst._start_sleep_time ~= nil then
        gain_sleep_health(inst)

        inst._start_sleep_time = nil
    end
end

local function inspect_boss(inst)
    return (inst.sg:HasStateTag("dead") and "DEAD") or nil
end

local function on_timer_finished(inst, data)
    if data.name == "summon_cooldown" then
        if inst._is_shielding then
            DoGestaltSummon(inst)
        end
    elseif data.name == "gotospawn" then
        inst:PushEvent("startspawnanim")
    end
end

local function hauntchancefn(inst)
    local statename = inst.sg.currentstate.name
    if statename == "prespawn_idle"
            or statename == "spawn"
            or statename == "death" then
        return 0
    else
        return TUNING.HAUNT_CHANCE_OCCASIONAL
    end
end

local scrapbook_adddeps = {
    "moonglass",
    "moonglass_charged",
    "alterguardianhat",
    "alterguardianhatshard",
}

local BURN_OFFSET = Vector3(0, 1.5, 0)
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.DynamicShadow:SetSize(5.00, 1.50)

    inst.AnimState:SetBank("alterguardian_phase1")
    inst.AnimState:SetBuild("alterguardian_phase1")

    MakeGiantCharacterPhysics(inst, 500, 1.25)

    inst:AddTag("brightmareboss")
    inst:AddTag("epic")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("mech")
    inst:AddTag("monster")
    inst:AddTag("noepicmusic")
    inst:AddTag("scarytoprey")
    inst:AddTag("soulless")
    inst:AddTag("lunar_aligned")

    inst._musicdirty = net_event(inst.GUID, "alterguardian_phase1._musicdirty", "musicdirty")
    inst._playingmusic = false
    --inst._musictask = nil
    OnMusicDirty(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)

        return inst
    end

    inst.scrapbook_adddeps = scrapbook_adddeps

    inst.scrapbook_damage = { TUNING.ALTERGUARDIAN_PHASE1_ROLLDAMAGE, TUNING.ALTERGUARDIAN_PHASE3_DAMAGE }
    inst.scrapbook_maxhealth = TUNING.ALTERGUARDIAN_PHASE1_HEALTH + TUNING.ALTERGUARDIAN_PHASE2_STARTHEALTH + TUNING.ALTERGUARDIAN_PHASE3_STARTHEALTH

    --inst._loot_dropped = nil      -- For handling save/loads during death; see SGalterguardian_phase1

    inst.EnableRollCollision = EnableRollCollision
    inst.EnterShield = EnterShield
    inst.ExitShield = ExitShield
    inst.SetNoMusic = SetNoMusic

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ALTERGUARDIAN_PHASE1_WALK_SPEED

    inst:SetStateGraph("SGalterguardian_phase1")
    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ALTERGUARDIAN_PHASE1_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ALTERGUARDIAN_PHASE1_ROLLDAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ALTERGUARDIAN_PHASE1_ATTACK_PERIOD)
    inst.components.combat:SetRange(15, TUNING.ALTERGUARDIAN_PHASE1_AOERANGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat.playerdamagepercent = TUNING.ALTERGUARDIAN_PLAYERDAMAGEPERCENT
    inst.components.combat.noimpactsound = true
    inst:ListenForEvent("blocked", play_custom_hit)

    inst:AddComponent("explosiveresist")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura
    inst.components.sanityaura.max_distsq = 225

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("alterguardian_phase1")
    inst.components.lootdropper.min_speed = 4.0
    inst.components.lootdropper.max_speed = 6.0
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 2

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_boss

    inst:AddComponent("knownlocations")

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("roll_cooldown", TUNING.ALTERGUARDIAN_PHASE1_ROLLCOOLDOWN)
    --inst.components.timer:StartTimer("summon_cooldown", TUNING.ALTERGUARDIAN_PHASE1_SUMMONCOOLDOWN)
    --inst.components.timer:StartTimer("gotospawn", N_A)
    inst:ListenForEvent("timerdone", on_timer_finished)

    inst:AddComponent("teleportedoverride")
    inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    inst:AddComponent("drownable")

    MakeLargeFreezableCharacter(inst)
    inst.components.freezable:SetResistance(8)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("phasetransition", OnPhaseTransition)

    inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian1/idle_LP", "idle_LP")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("alterguardian_phase1", fn, assets, prefabs)
