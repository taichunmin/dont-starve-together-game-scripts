local assets =
{
    Asset("ANIM", "anim/alterguardian_phase2.zip"),
    Asset("ANIM", "anim/alterguardian_spawn_death.zip"),
}

local prefabs =
{
    "alterguardian_phase2spiketrail",
    "alterguardian_phase3",
    "alterguardian_spintrail_fx",
    "alterguardian_summon_fx",
    "moonglass",
    "mining_moonglass_fx",
    "moonrocknugget",
    "smallguard_alterguardian_projectile",
}

SetSharedLootTable("alterguardian_phase2",
{
    {"moonglass",           1.00},
    {"moonglass",           1.00},
    {"moonglass",           1.00},
    {"moonglass",           1.00},
    {"moonglass",           0.66},
    {"moonglass",           0.66},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      1.00},
    {"moonrocknugget",      0.66},
    {"moonrocknugget",      0.66},
})

local brain = require "brains/alterguardian_phase2brain"

--MUSIC------------------------------------------------------------------------
local function PushMusic(inst)
    if ThePlayer == nil or inst:HasTag("nomusic") then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "alterguardian_phase2", duration = 2 })
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

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster", "shadowminion" }

local function spawn_spike_with_target(inst, data)
    if not data then
        return
    end

    local spawn_vec = data.spawn_pos or inst:GetPosition()

    local spike = SpawnPrefab("alterguardian_phase2spiketrail")
    spike.Transform:SetPosition(spawn_vec.x, 0, spawn_vec.z)
    spike.Transform:SetRotation(data.angle)
    spike:SetOwner(inst)
end

local MIN_SPIKE_COUNT, MAX_SPIKE_COUNT = 3, 4
local SPIKE_DSQ = TUNING.ALTERGUARDIAN_PHASE2_SPIKE_RANGE * TUNING.ALTERGUARDIAN_PHASE2_SPIKE_RANGE
local SPIKE_SPAWN_DELAY = 15*FRAMES
local SPIKEATTACK_CANT_TAGS = {}
for _, tag in ipairs(RETARGET_CANT_TAGS) do
    table.insert(SPIKEATTACK_CANT_TAGS, tag)
end
table.insert(SPIKEATTACK_CANT_TAGS, "player")

local function do_spike_attack(inst)
    local ipos = inst:GetPosition()

    -- Yes, we could decrement here, but using an increment serves our
    -- frame delaying of the spawns better, since the max count is random.
    local spikes_to_spawn = GetRandomMinMax(MIN_SPIKE_COUNT, MAX_SPIKE_COUNT)
    local spikes_spawned = 0

    local angles_chosen = {}

    -- Prioritize nearby players first.
    for _, p in ipairs(AllPlayers) do
        if not p:HasTag("playerghost") and p.entity:IsVisible()
                and (p.components.health ~= nil and not p.components.health:IsDead())
                and p:GetDistanceSqToPoint(ipos:Get()) < SPIKE_DSQ then
            local firing_angle = inst:GetAngleToPoint(p.Transform:GetWorldPosition())
            table.insert(angles_chosen, firing_angle)

            local spawn_data =
            {
                spawn_pos = ipos,
                angle = firing_angle,
            }
            inst:DoTaskInTime(SPIKE_SPAWN_DELAY*spikes_spawned, spawn_spike_with_target, spawn_data)
            spikes_spawned = spikes_spawned + 1
            if spikes_spawned >= spikes_to_spawn then
                break
            end
        end
    end

    if spikes_spawned >= spikes_to_spawn then
        return
    end

    -- There are still spikes we could spawn, so look for other entities that are targetable.

    local ix, iy, iz = ipos:Get()
    local targetable_entities = TheSim:FindEntities(
        ix, iy, iz, TUNING.ALTERGUARDIAN_PHASE2_SPIKE_RANGE,
        RETARGET_MUST_TAGS, SPIKEATTACK_CANT_TAGS, RETARGET_ONEOF_TAGS
    )
    if #targetable_entities <= 0 then
        return
    end

    for _, p in ipairs(targetable_entities) do
        if p.components.health ~= nil and not p.components.health:IsDead() then
            local firing_angle = inst:GetAngleToPoint(p.Transform:GetWorldPosition())
            table.insert(angles_chosen, firing_angle)

            local spawn_data =
            {
                spawn_pos = ipos,
                angle = firing_angle,
            }
            inst:DoTaskInTime(SPIKE_SPAWN_DELAY*spikes_spawned, spawn_spike_with_target, spawn_data)
            spikes_spawned = spikes_spawned + 1
            if spikes_spawned >= spikes_to_spawn then
                break
            end
        end
    end

    if spikes_spawned >= spikes_to_spawn then
        return
    end

    -- We STILL have spikes remaining. So try to just pick random angles
    -- that are some amount different than the ones we've already chosen.
    local spikes_remaining = spikes_to_spawn - spikes_spawned
    for i=1, spikes_remaining do
        local start_angle = 360*math.random()
        local firing_angle = nil
        for ang = 0, 360, 60 do
            local possible_angle = start_angle + ang
            local angle_valid = true
            for _, used_ang in ipairs(angles_chosen) do
                if math.abs(possible_angle - used_ang) < 30 then
                    angle_valid = false
                    break
                end
            end

            if angle_valid then
                firing_angle = possible_angle
                break
            end
        end

        if firing_angle then
            table.insert(angles_chosen, firing_angle)
            local spawn_data =
            {
                spawn_pos = ipos,
                angle = firing_angle,
            }
            inst:DoTaskInTime(SPIKE_SPAWN_DELAY*spikes_spawned, spawn_spike_with_target, spawn_data)
        end
    end
end

local TARGET_DIST = TUNING.ALTERGUARDIAN_PHASE2_TARGET_DIST
local function Retarget(inst)
    local gx, gy, gz = inst.Transform:GetWorldPosition()
    local potential_targets = TheSim:FindEntities(
        gx, gy, gz, TARGET_DIST,
        RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS
    )

    for _, target in ipairs(potential_targets) do
        if target ~= inst and target.entity:IsVisible()
                and inst.components.combat:CanTarget(target) then
            return target, true
        end
    end

    return nil
end

local MAX_CHASEAWAY_DIST_SQ = 1600 --40 ^2
local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target)
        and target:GetDistanceSqToPoint(inst.Transform:GetWorldPosition()) < MAX_CHASEAWAY_DIST_SQ
end

local function OnAttacked(inst, data)
    inst.components.combat:SuggestTarget(data.attacker)
end

local function teleport_override_fn(inst)
    local ipos = inst:GetPosition()
    local offset = FindWalkableOffset(ipos, 2*PI*math.random(), 10, 8, true, false)
        or FindWalkableOffset(ipos, 2*PI*math.random(), 14, 8, true, false)

    return (offset ~= nil and ipos + offset) or ipos
end

local function OnPhaseTransition(inst)
    local px, py, pz = inst.Transform:GetWorldPosition()
    local target = inst.components.combat.target

    inst:Remove()

    local phase3 = SpawnPrefab("alterguardian_phase3")
    phase3.Transform:SetPosition(px, py, pz)
    phase3.components.combat:SuggestTarget(target)
    phase3.sg:GoToState("spawn")
end

local function CalcSanityAura(inst, observer)
    return (inst.components.combat.target ~= nil and TUNING.SANITYAURA_HUGE) or TUNING.SANITYAURA_LARGE
end

local function OnSave(inst, data)
    data.loot_dropped = inst._loot_dropped
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst._loot_dropped = data.loot_dropped
    end
end

local function OnEntitySleep(inst)
    if inst.components.health:IsDead() then
        return
    end

    -- If we haven't reached our max health yet OR we're hurt, set a time
    -- so that, when we wake up, we can regain health.
    if inst.components.health.maxhealth < TUNING.ALTERGUARDIAN_PHASE2_MAXHEALTH
            or inst.components.health:IsHurt() then
        inst._start_sleep_time = GetTime()
    end
end

local HEALTH_GAIN_RATE = (TUNING.ALTERGUARDIAN_PHASE2_MAXHEALTH - TUNING.ALTERGUARDIAN_PHASE2_STARTHEALTH) / (TUNING.TOTAL_DAY_TIME * 2)
local function gain_sleep_health(inst)
    local gain = HEALTH_GAIN_RATE * (GetTime() - inst._start_sleep_time)
    local hp_plus_gain = inst.components.health.currenthealth + gain

    -- If our gain would be enough to break our current max health,
    -- assign a new max health, up to our tuned real maximum health.
    if hp_plus_gain > inst.components.health.maxhealth then
        local new_max = math.min(hp_plus_gain, TUNING.ALTERGUARDIAN_PHASE2_MAXHEALTH)
        inst.components.health:SetMaxHealth(new_max)
    else
        inst.components.health:DoDelta(gain)
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

local function hauntchancefn(inst)
    local statename = inst.sg.currentstate.name
    if statename == "spawn" or statename == "death" then
        return 0
    else
        return TUNING.HAUNT_CHANCE_OCCASIONAL
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

    inst.Transform:SetSixFaced()

    inst.DynamicShadow:SetSize(5.5, 2.0)

    inst.Light:SetIntensity(0)
    inst.Light:SetRadius(0)
    inst.Light:SetFalloff(0)
    inst.Light:SetColour(0.01, 0.35, 1)

    inst.AnimState:SetBank("alterguardian_phase2")
    inst.AnimState:SetBuild("alterguardian_phase2")
    inst.AnimState:PlayAnimation("idle")

    MakeGiantCharacterPhysics(inst, 500, 2)

    inst:AddTag("brightmareboss")
    inst:AddTag("epic")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("mech")
    inst:AddTag("monster")
    inst:AddTag("noepicmusic")
    inst:AddTag("scarytoprey")
    inst:AddTag("soulless")

    inst._musicdirty = net_event(inst.GUID, "alterguardian_phase2._musicdirty", "musicdirty")
    inst._playingmusic = false
    --inst._musictask = nil
    OnMusicDirty(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)

        return inst
    end

    inst.DoSpikeAttack = do_spike_attack
    inst.SetNoMusic = SetNoMusic

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ALTERGUARDIAN_PHASE2_WALK_SPEED

    inst:SetStateGraph("SGalterguardian_phase2")
    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ALTERGUARDIAN_PHASE2_STARTHEALTH)
    inst.components.health.nofadeout = true
    inst.components.health.save_maxhealth = true

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ALTERGUARDIAN_PHASE2_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ALTERGUARDIAN_PHASE2_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRange(TUNING.ALTERGUARDIAN_PHASE2_SPIN_RANGE, TUNING.ALTERGUARDIAN_PHASE2_CHOP_RANGE)
    inst.components.combat.playerdamagepercent = TUNING.ALTERGUARDIAN_PLAYERDAMAGEPERCENT
    inst.components.combat.noimpactsound = true
    inst.components.combat:SetHurtSound("moonstorm/creatures/boss/alterguardian1/onothercollide")

    inst:AddComponent("explosiveresist")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura
    inst.components.sanityaura.max_distsq = 225

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("alterguardian_phase2")
    inst.components.lootdropper.min_speed = 4.0
    inst.components.lootdropper.max_speed = 6.0
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 2

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_boss

    inst:AddComponent("knownlocations")

    inst:AddComponent("timer")
    --inst.components.timer:StartTimer("spin_cd", 5)
    --inst.components.timer:StartTimer("summon_cd", 15)

    inst:AddComponent("teleportedoverride")
    inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    MakeLargeFreezableCharacter(inst)
    inst.components.freezable:SetResistance(8)

    MakeHauntableGoToStateWithChanceFunction(inst, "atk_chop", hauntchancefn, TUNING.ALTERGUARDIAN_PHASE2_ATTACK_PERIOD, TUNING.HAUNT_SMALL)

    inst:ListenForEvent("phasetransition", OnPhaseTransition)
    inst:ListenForEvent("attacked", OnAttacked)

    inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian2/idle_LP","idle_LP")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("alterguardian_phase2", fn, assets, prefabs)
