require("stategraphs/commonstates")

local actionhandlers = nil

-- The number of traps above which the boss will not spawn more
local MIN_TRAP_COUNT_FOR_RESPAWN = 4

-- The distance past which a ranged attack should be used.
local RANGED_ATTACK_DSQ = TUNING.ALTERGUARDIAN_PHASE3_STAB_RANGE^2
local SUMMON_DSQ = TUNING.ALTERGUARDIAN_PHASE3_SUMMONRSQ - 36

local events =
{
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttacked(nil, TUNING.ALTERGUARDIAN_PHASE3_MAX_STUN_LOCKS),

    EventHandler("doattack", function(inst, data)
        if not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy"))
                and (data.target ~= nil and data.target:IsValid()) then
            local dsq_to_target = inst:GetDistanceSqToInst(data.target)

            if not inst.components.timer:TimerExists("summon_cd") and dsq_to_target < SUMMON_DSQ then
                inst.sg:GoToState("atk_summon_pre", data.target)
            else
                local attack_state = "atk_stab"
                local geyser_pos = inst.components.knownlocations:GetLocation("geyser")
                if not inst.components.timer:TimerExists("traps_cd")
                        and GetTableSize(inst._traps) <= MIN_TRAP_COUNT_FOR_RESPAWN
                        and (geyser_pos == nil
                            or inst:GetDistanceSqToPoint(geyser_pos:Get()) < (TUNING.ALTERGUARDIAN_PHASE3_GOHOMEDSQ / 2)) then
                    attack_state = "atk_traps"
                elseif dsq_to_target > RANGED_ATTACK_DSQ then
                    attack_state = (math.random() > 0.5 and "atk_beam" or "atk_sweep")
                end

                inst.sg:GoToState(attack_state, data.target)
            end
        end
    end),
}

local TRIBEAM_ANGLEOFF = PI/5
local TRIBEAM_COS = math.cos(TRIBEAM_ANGLEOFF)
local TRIBEAM_SIN = math.sin(TRIBEAM_ANGLEOFF)
local TRIBEAM_COSNEG = math.cos(-TRIBEAM_ANGLEOFF)
local TRIBEAM_SINNEG = math.sin(-TRIBEAM_ANGLEOFF)

local SECOND_BLAST_TIME = 22*FRAMES

local NUM_STEPS = 10
local STEP = 1.0
local OFFSET = 2 - STEP
local function SpawnBeam(inst, target_pos)
    if target_pos == nil then
        return
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()

    -- This is the "step" of fx spawning that should align with the position the beam is targeting.
    local target_step_num = RoundBiasedUp(NUM_STEPS * 2/5)

    local angle = nil

    -- gx, gy, gz is the point of the actual first beam fx
    local gx, gy, gz = nil, 0, nil
    local x_step = STEP
    if inst:GetDistanceSqToPoint(target_pos:Get()) < 4 then
        angle = math.atan2(iz - target_pos.z, ix - target_pos.x)

        -- If the target is too close, use the minimum distance
        gx, gy, gz = inst.Transform:GetWorldPosition()
        gx = gx + (2 * math.cos(angle))
        gz = gz + (2 * math.sin(angle))
    else
        angle = math.atan2(iz - target_pos.z, ix - target_pos.x)

        gx, gy, gz = target_pos:Get()
        gx = gx + (target_step_num * STEP * math.cos(angle))
        gz = gz + (target_step_num * STEP * math.sin(angle))
    end

    local targets, skiptoss = {}, {}
    local sbtargets, sbskiptoss = {}, {}
    local x, z = nil, nil
    local trigger_time = nil

    local i = -1
    while i < NUM_STEPS do
        i = i + 1
        x = gx - i * x_step * math.cos(angle)
        z = gz - i * STEP * math.sin(angle)

        local first = (i == 0)
        local prefab = (i > 0 and "alterguardian_laser") or "alterguardian_laserempty"
        local x1, z1 = x, z

        trigger_time = math.max(0, i - 1) * FRAMES

        inst:DoTaskInTime(trigger_time, function(inst2)
            local fx = SpawnPrefab(prefab)
            fx.caster = inst2
            fx.Transform:SetPosition(x1, 0, z1)
            fx:Trigger(0, targets, skiptoss)
            if first then
                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .2, target_pos or fx, 30)
            end
        end)

        inst:DoTaskInTime(trigger_time + SECOND_BLAST_TIME, function(inst2)
            local fx = SpawnPrefab(prefab)
            fx.caster = inst2
            fx.Transform:SetPosition(x1, 0, z1)
            fx:Trigger(0, sbtargets, sbskiptoss, true)
            if first then
                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .2, target_pos or fx, 30)
            end
        end)
    end

    inst:DoTaskInTime(i*FRAMES, function(inst2)
        local fx = SpawnPrefab("alterguardian_laser")
        fx.Transform:SetPosition(x, 0, z)
        fx:Trigger(0, targets, skiptoss)
    end)

    inst:DoTaskInTime((i+1)*FRAMES, function(inst2)
        local fx = SpawnPrefab("alterguardian_laser")
        fx.Transform:SetPosition(x, 0, z)
        fx:Trigger(0, targets, skiptoss)
    end)
end

local BASE_NUM_ANGULAR_STEPS = 10
local SWEEP_ANGULAR_LENGTH = 75
local BASE_SWEEP_DISTANCE = 8
local MIN_SWEEP_DISTANCE = 3
local function SpawnSweep(inst, target_pos)
    local gx, gy, gz = inst.Transform:GetWorldPosition()

    local angle = nil
    local dist = nil
    local angle_step_dir = 1
    local x_dir = 1

    if target_pos == nil then
        angle = DEGREES * (inst.Transform:GetRotation() + (SWEEP_ANGULAR_LENGTH/2))
        dist = BASE_SWEEP_DISTANCE
        x_dir = -1
        angle_step_dir = -1
    else
        angle = math.atan2(gz - target_pos.z, gx - target_pos.x) - (SWEEP_ANGULAR_LENGTH * DEGREES/2)
        dist = math.max(math.sqrt(inst:GetDistanceSqToPoint(target_pos:Get())), MIN_SWEEP_DISTANCE)
    end

    local num_angle_steps = BASE_NUM_ANGULAR_STEPS + RoundBiasedDown((math.abs(dist) - BASE_SWEEP_DISTANCE) / 2)
    local angle_step = (SWEEP_ANGULAR_LENGTH / num_angle_steps) * DEGREES

    local targets, skiptoss = {}, {}
    local sbtargets, sbskiptoss = {}, {}
    local x, z = nil, nil
    local delay = nil

    local i = -1
    while i < num_angle_steps do
        i = i + 1
        delay = math.max(0, i - 1)*FRAMES

        x = gx - (x_dir * dist * math.cos(angle))
        z = gz - dist * math.sin(angle)
        angle = angle + (angle_step_dir * angle_step)

        -- Assign loop-local values to be captured (we still need x and z for post-loop)
        local first = (i == 0)
        local x1, z1 = x, z
        inst:DoTaskInTime(delay, function(inst2)
            local fx = SpawnPrefab("alterguardian_laser")
            fx.caster = inst2
            fx.Transform:SetPosition(x1, 0, z1)
            fx:Trigger(0, targets, skiptoss)
            if first then
                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .6, target_pos or fx, 30)
            end
        end)

        inst:DoTaskInTime(delay + SECOND_BLAST_TIME, function(inst2)
            local fx = SpawnPrefab("alterguardian_laser")
            fx.caster = inst2
            fx.Transform:SetPosition(x1, 0, z1)
            fx:Trigger(0, sbtargets, sbskiptoss, true)
            if first then
                ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .6, target_pos or fx, 30)
            end
        end)
    end

    inst:DoTaskInTime(i*FRAMES, function(inst2)
        local fx = SpawnPrefab("alterguardian_laser")
        fx.Transform:SetPosition(x, 0, z)
        fx:Trigger(0, targets, skiptoss)
    end)

    inst:DoTaskInTime((i+1)*FRAMES, function(inst2)
        local fx = SpawnPrefab("alterguardian_laser")
        fx.Transform:SetPosition(x, 0, z)
        fx:Trigger(0, targets, skiptoss)
    end)
end

local function laser_sound(inst)
    -- inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_beam_laser")
end

local function start_summon_circle(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    if inst.sg.mem.summon_circle == nil then
        inst.sg.mem.summon_circle = SpawnPrefab("alterguardian_phase3circle")
        inst.sg.mem.summon_circle.Transform:SetPosition(ix, iy, iz)
    end

    if inst.sg.mem.summon_fx == nil then
        inst.sg.mem.summon_fx = SpawnPrefab("alterguardian_summon_fx")
        inst.sg.mem.summon_fx.Transform:SetScale(1.3, 1.3, 1.3)
        inst.sg.mem.summon_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function stop_summon_circle(inst)
    if inst.sg.mem.summon_circle ~= nil and inst.sg.mem.summon_circle:IsValid() then
        inst.sg.mem.summon_circle:Remove()
        inst.sg.mem.summon_circle = nil
    end

    if inst.sg.mem.summon_fx ~= nil and inst.sg.mem.summon_fx:IsValid() then
        inst.sg.mem.summon_fx:PushEvent("endloop")
        inst.sg.mem.summon_fx = nil
    end
end

local function do_summon_spawn(inst)
    local player_in_range = false
    local ix, _, iz = inst.Transform:GetWorldPosition()
    for i, p in ipairs(AllPlayers) do
        local dsq_to_player = p:GetDistanceSqToPoint(ix, 0, iz)
        if dsq_to_player < TUNING.ALTERGUARDIAN_PHASE3_SUMMONRSQ then
            -- Don't count ghosts, and don't "sleep-camp" players that are knocked out.
            if (p.components.grogginess ~= nil and not p.components.grogginess:IsKnockedOut())
                    and not p:HasTag("playerghost") then
                player_in_range = true

                local spawn_prefab = (math.random() < 0.4 and "largeguard_alterguardian_projectile") or "gestalt_alterguardian_projectile"
                local gestalt = SpawnPrefab(spawn_prefab)

                local px, py, pz = p.Transform:GetWorldPosition()

                local radius = GetRandomMinMax(3, 5)
                local angle = (inst:GetAngleToPoint(px, py, pz) + GetRandomMinMax(-90, 90)) * DEGREES
                gestalt.Transform:SetPosition(
                    px + radius * math.cos(angle),
                    py,
                    pz + radius * -math.sin(angle)
                )
                gestalt:ForceFacePoint(px, py, pz)
                gestalt:SetTargetPosition(Vector3(px, py, pz))
            end
        end
    end

    if not player_in_range then
        inst.sg.statemem.ready_to_finish = true
    end
end

local function do_stab_attack(inst)
    inst.components.combat:DoAttack(inst.sg.statemem.target)
    --inst.SoundEmitter:PlaySound(attack sound)
end

local function post_attack_idle(inst)
    inst.components.timer:StopTimer("runaway_blocker")
    inst.components.timer:StartTimer("runaway_blocker", TUNING.ALTERGUARDIAN_PHASE3_RUNAWAY_BLOCK_TIME)

    inst.sg:GoToState("idle")
end

local function set_lightvalues(inst, val)
    inst.Light:SetIntensity(0.60 + (0.39 * val * val))
    inst.Light:SetRadius(5 * val)
    inst.Light:SetFalloff(0.85)
end

local states =
{
    State{
        name = "spawn",
        tags = {"busy", "noaoestun", "noattack", "nofreeze", "nosleep", "nostun" },

        onenter = function(inst)
            inst.AnimState:SetBuild("alterguardian_spawn_death")
            inst.AnimState:SetBankAndPlayAnimation("alterguardian_spawn_death", "phase3_spawn")
            inst.components.health:SetInvincible(true)
            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/idle_LP","idle")

            set_lightvalues(inst, 0.0)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/spawn")
            end),
            TimeEvent(12*FRAMES, function(inst) set_lightvalues(inst, 0.05) end),
            TimeEvent(13*FRAMES, function(inst) set_lightvalues(inst, 0.075) end),
            TimeEvent(14*FRAMES, function(inst) set_lightvalues(inst, 0.10) end),

            TimeEvent(18*FRAMES, function(inst) set_lightvalues(inst, 0.15) end),

            TimeEvent(23*FRAMES, function(inst) set_lightvalues(inst, 0.1) end),

            TimeEvent(28*FRAMES, function(inst) set_lightvalues(inst, 0.15) end),

            TimeEvent(30*FRAMES, function(inst) set_lightvalues(inst, 0.2) end),

            TimeEvent(33*FRAMES, function(inst) set_lightvalues(inst, 0.25) end),

            TimeEvent(40*FRAMES, function(inst) set_lightvalues(inst, 0.1) end),

            TimeEvent(44*FRAMES, function(inst) set_lightvalues(inst, 0.05) end),

            TimeEvent(47*FRAMES, function(inst) set_lightvalues(inst, 0.2) end),

            TimeEvent(59*FRAMES, function(inst) set_lightvalues(inst, 0.1) end),

            TimeEvent(62*FRAMES, function(inst) set_lightvalues(inst, 0.2) end),
            TimeEvent(63*FRAMES, function(inst) set_lightvalues(inst, 0.175) end),
            TimeEvent(64*FRAMES, function(inst) set_lightvalues(inst, 0.15) end),
            TimeEvent(65*FRAMES, function(inst) set_lightvalues(inst, 0.2) end),
            TimeEvent(66*FRAMES, function(inst) set_lightvalues(inst, 0.175) end),
            TimeEvent(67*FRAMES, function(inst) set_lightvalues(inst, 0.15) end),
            TimeEvent(68*FRAMES, function(inst) set_lightvalues(inst, 0.175) end),
            TimeEvent(69*FRAMES, function(inst) set_lightvalues(inst, 0.2) end),
            TimeEvent(70*FRAMES, function(inst) set_lightvalues(inst, 0.225) end),

            TimeEvent(72*FRAMES, function(inst) set_lightvalues(inst, 0.26) end),

            TimeEvent(74*FRAMES, function(inst) set_lightvalues(inst, 0.295) end),

            TimeEvent(76*FRAMES, function(inst) set_lightvalues(inst, 0.330) end),

            TimeEvent(78*FRAMES, function(inst) set_lightvalues(inst, 0.365) end),
            TimeEvent(79*FRAMES, function(inst) set_lightvalues(inst, 0.4) end),

            TimeEvent(95*FRAMES, function(inst) set_lightvalues(inst, 0.45) end),
            TimeEvent(96*FRAMES, function(inst) set_lightvalues(inst, 0.525) end),
            TimeEvent(97*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(98*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(99*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(100*FRAMES, function(inst) set_lightvalues(inst, 0.825) end),
            TimeEvent(101*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),

            TimeEvent(112*FRAMES, function(inst) set_lightvalues(inst, 0.925) end),
            TimeEvent(113*FRAMES, function(inst) set_lightvalues(inst, 0.95) end),

            TimeEvent(118*FRAMES, function(inst) set_lightvalues(inst, 0.925) end),

            TimeEvent(125*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.AnimState:SetBuild("alterguardian_phase3")
            inst.AnimState:SetBankAndPlayAnimation("alterguardian_phase3", "idle")
        end,
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate", "canroll"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle")

            set_lightvalues(inst, 0.9)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "atk_stab",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_stab")

            inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_stab") end),
            TimeEvent(22*FRAMES, function (inst) inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_stab_LP","stab_loop") end),
            TimeEvent(29*FRAMES, do_stab_attack),
            TimeEvent(45*FRAMES, do_stab_attack),
            TimeEvent(55*FRAMES, function(inst) inst.SoundEmitter:KillSound("stab_loop") end),
        },

        events =
        {
            EventHandler("animover", post_attack_idle),
        },
    },

    State{
        name = "atk_summon_pre",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_stab2_pre")

            inst.components.combat:StartAttack()

            start_summon_circle(inst)

            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_stab_short")
            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_stab_LP_pre","atk_stab_loop_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.loop_exit = true
                inst.sg:GoToState("atk_summon_loop")
            end),
        },

        onexit = function(inst)
            -- If we're not exiting via the animover event,
            -- we need to clean up the circle (i.e. frozen, death)
            if not inst.sg.statemem.loop_exit then
                stop_summon_circle(inst)
            end
        end,
    },

    State{
        name = "atk_summon_loop",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_stab2_loop")

            -- Keep the combat cooldown running while we loop here.
            inst.components.combat:RestartCooldown()

            inst.sg.mem.summon_loops = inst.sg.mem.summon_loops or 0
            inst.sg.mem.loop_anim_len = inst.sg.mem.loop_anim_len or inst.AnimState:GetCurrentAnimationLength()

            inst.sg.statemem.previous_loop_time = (inst.sg.mem.summon_loops * inst.sg.mem.loop_anim_len)

            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/summon")
        end,

        onupdate = function(inst, dt)
            local time_in_summon = inst.sg:GetTimeInState() + inst.sg.statemem.previous_loop_time
            local summon_maxtime = inst.sg.mem.loop_anim_len * TUNING.ALTERGUARDIAN_PHASE3_SUMMONMAXLOOPS
            local percent_in_summon = time_in_summon / summon_maxtime

            inst.SoundEmitter:SetParameter("atk_stab_loop_pre", "intensity", percent_in_summon)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, do_stab_attack),
            TimeEvent(8*FRAMES, do_summon_spawn),
            TimeEvent(16*FRAMES, do_summon_spawn),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.legit_exit = true

                inst.sg.mem.summon_loops = inst.sg.mem.summon_loops + 1

                if inst.sg.statemem.ready_to_finish or inst.sg.mem.summon_loops >= TUNING.ALTERGUARDIAN_PHASE3_SUMMONMAXLOOPS then
                    inst.sg.mem.summon_loops = nil
                    inst.sg:GoToState("atk_summon_pst")
                else
                    inst.sg:GoToState("atk_summon_loop")
                end
            end),
        },

        onexit = function(inst)
            -- Whether we go to pst or loop, we're fine.
            -- This is to cover stuff like death and frozen.
            if not inst.sg.statemem.legit_exit then
                inst.SoundEmitter:KillSound("summon_loop")
                stop_summon_circle(inst)
            end
        end,
    },

    State{
        name = "atk_summon_pst",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_stab2_pst")

            inst.components.timer:StartTimer("summon_cd", TUNING.ALTERGUARDIAN_PHASE3_SUMMONCOOLDOWN)

            inst.SoundEmitter:KillSound("atk_stab_loop_pre")
            inst.SoundEmitter:KillSound("summon_loop")
        end,

        events =
        {
            EventHandler("animover", post_attack_idle),
        },

        onexit = function(inst)
            stop_summon_circle(inst)
        end,
    },

    State{
        name = "atk_traps",
        tags = {"attacking", "busy", "canrotate"},

        onenter = function(inst, target)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_skybeam")
            inst.sg.statemem.skybeamanim_playing = true

            inst.components.combat:StartAttack()

            inst.sg:AddStateTag("nofreeze")

            inst.sg:SetTimeout(15)
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_sky_beam")
            end),
            TimeEvent(44*FRAMES, function(inst)
                inst:DoTraps(
                    4,
                    TUNING.ALTERGUARDIAN_PHASE3_TRAP_MINRANGE,
                    TUNING.ALTERGUARDIAN_PHASE3_TRAP_MAXRANGE
                )
                inst.components.timer:StartTimer("traps_cd", TUNING.ALTERGUARDIAN_PHASE3_TRAP_CD)
            end),
            TimeEvent(54*FRAMES, function(inst)
                inst:DoTraps(
                    6,
                    TUNING.ALTERGUARDIAN_PHASE3_TRAP_MINRANGE + 3.5,
                    TUNING.ALTERGUARDIAN_PHASE3_TRAP_MAXRANGE + 3.5
                )
            end),

            TimeEvent(1*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
            TimeEvent(2*FRAMES, function(inst) set_lightvalues(inst, 0.875) end),
            TimeEvent(3*FRAMES, function(inst) set_lightvalues(inst, 0.85) end),
            TimeEvent(4*FRAMES, function(inst) set_lightvalues(inst, 0.825) end),
            TimeEvent(5*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(6*FRAMES, function(inst) set_lightvalues(inst, 0.775) end),
            TimeEvent(7*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(8*FRAMES, function(inst) set_lightvalues(inst, 0.725) end),
            TimeEvent(9*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(10*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(11*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(12*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(13*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(14*FRAMES, function(inst) set_lightvalues(inst, 0.575) end),
            TimeEvent(15*FRAMES, function(inst) set_lightvalues(inst, 0.55) end),
            TimeEvent(16*FRAMES, function(inst) set_lightvalues(inst, 0.525) end),
            TimeEvent(17*FRAMES, function(inst) set_lightvalues(inst, 0.5) end),
            TimeEvent(18*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(19*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(20*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(21*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
            TimeEvent(22*FRAMES, function(inst) set_lightvalues(inst, 0.92) end),
            TimeEvent(23*FRAMES, function(inst) set_lightvalues(inst, 0.94) end),

            TimeEvent(40*FRAMES, function(inst) set_lightvalues(inst, 0.92) end),
            TimeEvent(41*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
        },

        events =
        {
            EventHandler("endtraps", post_attack_idle),
            EventHandler("animover", function(inst)
                if inst.sg.statemem.skybeamanim_playing then
                    inst.sg.statemem.skybeamanim_playing = false
                    inst.AnimState:PushAnimation("idle2", true)
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        ontimeout = post_attack_idle,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("channel")
            inst.sg:RemoveStateTag("nofreeze")
        end,
    },

    State{
        name = "atk_beam",
        tags = {"attacking", "busy", "canrotate"},

        onenter = function(inst, target)
            inst.Transform:SetEightFaced()

            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_beam")

            if inst.components.combat:TargetIs(target) then
                inst.components.combat:StartAttack()
            end

            inst:ForceFacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.target = target

            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_beam")

            inst.sg:AddStateTag("nofreeze")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                local x, _, z = inst.Transform:GetWorldPosition()
                local x1, y1, z1 = inst.sg.statemem.target.Transform:GetWorldPosition()
                local dx, dz = x1 - x, z1 - z
                if (dx * dx + dz * dz) < 256 and math.abs(anglediff(inst.Transform:GetRotation(), math.atan2(-dz, dx) / DEGREES)) < 45 then
                    inst:ForceFacePoint(x1, y1, z1)
                    return
                end
            end
        end,

        timeline =
        {
            TimeEvent(21*FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.target_pos = inst.sg.statemem.target:GetPosition()
                end
                inst.sg.statemem.target = nil
            end),

            TimeEvent(35*FRAMES, function(inst)
                local ipos = inst:GetPosition()

                local target_pos = inst.sg.statemem.target_pos
                if target_pos == nil then
                    local angle = inst.Transform:GetRotation() * DEGREES
                    target_pos = ipos + Vector3(OFFSET * math.cos(angle), 0, -OFFSET * math.sin(angle))
                end
                SpawnBeam(inst, target_pos)

                -- Take the vector from the boss to the target position, and rotate it a bit
                -- both clockwise and counterclockwise, to get target positions that produce
                -- an aligned tri-beam, sourced at the boss.
                local i_to_target = target_pos - ipos

                local offpos1 = Vector3(
                    (i_to_target.x * TRIBEAM_COS - i_to_target.z * TRIBEAM_SIN) + ipos.x,
                    0,
                    (i_to_target.x * TRIBEAM_SIN + i_to_target.z * TRIBEAM_COS) + ipos.z
                )
                SpawnBeam(inst, offpos1)

                local offpos2 = Vector3(
                    (i_to_target.x * TRIBEAM_COSNEG - i_to_target.z * TRIBEAM_SINNEG) + ipos.x,
                    0,
                    (i_to_target.x * TRIBEAM_SINNEG + i_to_target.z * TRIBEAM_COSNEG) + ipos.z
                )
                SpawnBeam(inst, offpos2)
            end),
            -- Play a second blast sound about when the second blast will occur, relative to the above TimeEvent.
            TimeEvent(35*FRAMES + SECOND_BLAST_TIME, laser_sound),

            TimeEvent(1*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
            TimeEvent(2*FRAMES, function(inst) set_lightvalues(inst, 0.875) end),
            TimeEvent(3*FRAMES, function(inst) set_lightvalues(inst, 0.85) end),
            TimeEvent(4*FRAMES, function(inst) set_lightvalues(inst, 0.825) end),
            TimeEvent(5*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(6*FRAMES, function(inst) set_lightvalues(inst, 0.775) end),
            TimeEvent(7*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(8*FRAMES, function(inst) set_lightvalues(inst, 0.725) end),
            TimeEvent(9*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(10*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(11*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(12*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(13*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(14*FRAMES, function(inst) set_lightvalues(inst, 0.575) end),
            TimeEvent(15*FRAMES, function(inst) set_lightvalues(inst, 0.55) end),
            TimeEvent(16*FRAMES, function(inst) set_lightvalues(inst, 0.525) end),
            TimeEvent(17*FRAMES, function(inst) set_lightvalues(inst, 0.5) end),

            TimeEvent(21*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(22*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(23*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(24*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(25*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),

            TimeEvent(26*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(27*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(28*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(29*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(30*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(31*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),

            TimeEvent(32*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(33*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(34*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
        },

        events =
        {
            EventHandler("animover", post_attack_idle),
        },

        onexit = function(inst)
            inst.Transform:SetSixFaced()
            inst.sg:RemoveStateTag("nofreeze")
        end,
    },

    State{
        name = "atk_sweep",
        tags = {"attacking", "busy", "canrotate"},

        onenter = function(inst, target)
            inst.Transform:SetFourFaced()

            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("attk_swipe")

            if inst.components.combat:TargetIs(target) then
                inst.components.combat:StartAttack()
            end

            inst:ForceFacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.target = target

            inst.sg:AddStateTag("nofreeze")

            inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/atk_beam")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                local x, _, z = inst.Transform:GetWorldPosition()
                local x1, y1, z1 = inst.sg.statemem.target.Transform:GetWorldPosition()
                local dx, dz = x1 - x, z1 - z
                if (dx * dx + dz * dz) < 256 and math.abs(anglediff(inst.Transform:GetRotation(), math.atan2(-dz, dx) / DEGREES)) < 45 then
                    inst:ForceFacePoint(x1, y1, z1)
                end
            end
        end,

        timeline =
        {
            TimeEvent(21*FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.target_pos = inst.sg.statemem.target:GetPosition()
                end
                inst.sg.statemem.target = nil
            end),

            TimeEvent(37*FRAMES, function(inst)
                local target_pos = inst.sg.statemem.target_pos

                SpawnSweep(inst, target_pos)

                if target_pos ~= nil then
                    local itot = target_pos - inst:GetPosition()
                    if itot:LengthSq() > 0 then
                        local itot_dir, itot_len = itot:GetNormalizedAndLength()
                        SpawnSweep(inst, target_pos + (itot_dir * 4.5))
                        if itot_len > 4.75 then
                            SpawnSweep(inst, target_pos - (itot_dir * 4.5))
                        end
                    end
                end
            end),
            -- Play a second blast sound about when the second blast will occur, relative to the above TimeEvent.
            TimeEvent(37*FRAMES + SECOND_BLAST_TIME, laser_sound),

            TimeEvent(1*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
            TimeEvent(2*FRAMES, function(inst) set_lightvalues(inst, 0.875) end),
            TimeEvent(3*FRAMES, function(inst) set_lightvalues(inst, 0.85) end),
            TimeEvent(4*FRAMES, function(inst) set_lightvalues(inst, 0.825) end),
            TimeEvent(5*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(6*FRAMES, function(inst) set_lightvalues(inst, 0.775) end),
            TimeEvent(7*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(8*FRAMES, function(inst) set_lightvalues(inst, 0.725) end),
            TimeEvent(9*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(10*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(11*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(12*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(13*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(14*FRAMES, function(inst) set_lightvalues(inst, 0.575) end),
            TimeEvent(15*FRAMES, function(inst) set_lightvalues(inst, 0.55) end),
            TimeEvent(16*FRAMES, function(inst) set_lightvalues(inst, 0.525) end),
            TimeEvent(17*FRAMES, function(inst) set_lightvalues(inst, 0.5) end),

            TimeEvent(21*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(22*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(23*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(24*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(25*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),

            TimeEvent(26*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(27*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(28*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(29*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(30*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(31*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),

            TimeEvent(32*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(33*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(34*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(35*FRAMES, function(inst) set_lightvalues(inst, 0.85) end),
            TimeEvent(36*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
        },

        events =
        {
            EventHandler("animover", post_attack_idle),
        },

        onexit = function(inst)
            inst.Transform:SetSixFaced()
            inst.sg:RemoveStateTag("nofreeze")
        end,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:SetBuild("alterguardian_spawn_death")
            inst.AnimState:SetBankAndPlayAnimation("alterguardian_spawn_death", "phase3_death")

            RemovePhysicsColliders(inst)

            set_lightvalues(inst, 0.9)

            TheWorld:PushEvent("moonboss_defeated")

            inst:SetNoMusic(true)
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian3/death")
            end),
            TimeEvent(65*FRAMES, function(inst)
                if not inst._loot_dropped then
                    -- Use lootdropper for the nice spray of moon glass and rocks and such.
                    inst.components.lootdropper:DropLoot(inst:GetPosition())

                    inst._loot_dropped = true
                end

                ShakeAllCameras(CAMERASHAKE.FULL, 0.10, 0.05, 0.1, inst, 40)
            end),

            TimeEvent(87*FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.75, 0.05, 0.6, inst, 40)
            end),

            TimeEvent(18*FRAMES, function(inst) set_lightvalues(inst, 0.9) end),
            TimeEvent(19*FRAMES, function(inst) set_lightvalues(inst, 0.85) end),
            TimeEvent(20*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(21*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(22*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(23*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(24*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(25*FRAMES, function(inst) set_lightvalues(inst, 0.85) end),
            TimeEvent(26*FRAMES, function(inst) set_lightvalues(inst, 0.8) end),
            TimeEvent(27*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(28*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(29*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(30*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(31*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(32*FRAMES, function(inst) set_lightvalues(inst, 0.725) end),
            TimeEvent(33*FRAMES, function(inst) set_lightvalues(inst, 0.75) end),
            TimeEvent(34*FRAMES, function(inst) set_lightvalues(inst, 0.725) end),
            TimeEvent(35*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),
            TimeEvent(36*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(37*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(38*FRAMES, function(inst) set_lightvalues(inst, 0.625) end),
            TimeEvent(39*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(40*FRAMES, function(inst) set_lightvalues(inst, 0.675) end),
            TimeEvent(41*FRAMES, function(inst) set_lightvalues(inst, 0.7) end),

            TimeEvent(53*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(54*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(55*FRAMES, function(inst) set_lightvalues(inst, 0.55) end),
            TimeEvent(56*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(57*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
            TimeEvent(58*FRAMES, function(inst) set_lightvalues(inst, 0.55) end),
            TimeEvent(59*FRAMES, function(inst) set_lightvalues(inst, 0.6) end),
            TimeEvent(60*FRAMES, function(inst) set_lightvalues(inst, 0.65) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                local orb = SpawnPrefab("alterguardian_phase3deadorb")
                orb.Transform:SetPosition(inst.Transform:GetWorldPosition())

                inst:Remove()
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline = {

    },
    walktimeline = {

    },
    endtimeline = {

    },
})

CommonStates.AddHitState(states)
CommonStates.AddFrozenStates(states)

return StateGraph("alterguardian_phase3", states, events, "idle", actionhandlers)
