require("stategraphs/commonstates")

--------------------------------------------------------------------------

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, .15, inst, 30)
end

local function ShakeCasting(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .3, .02, 1, inst, 30)
end

local function ShakeRaising(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1, .02, 1, inst, 30)
end

--------------------------------------------------------------------------

local function ChooseAttack(inst)
    local target = inst.components.combat.target
    if target ~= nil and target:IsNear(inst, TUNING.ANTLION_CAST_RANGE) then
        if inst.components.worldsettingstimer:ActiveTimerExists("wall_cd") then
            inst.sg:GoToState("summonspikes", target)
        else
            inst.sg:GoToState("summonwall")
        end
        return true
    end
    return false
end

--------------------------------------------------------------------------

--See sand_spike.lua
local SPIKE_SIZES =
{
    "short",
    "med",
    "tall",
}

local SPIKE_RADIUS =
{
    ["short"] = .2,
    ["med"] = .4,
    ["tall"] = .6,
    ["block"] = 1.1,
}

local function CanSpawnSpikeAt(pos, size)
    local radius = SPIKE_RADIUS[size]
    for i, v in ipairs(TheSim:FindEntities(pos.x, 0, pos.z, radius + 1.5, nil, { "antlion_sinkhole" }, { "groundspike", "antlion_sinkhole_blocker" })) do
        if v.Physics == nil then
            return false
        end
        local spacing = radius + v:GetPhysicsRadius(0)
        if v:GetDistanceSqToPoint(pos) < spacing * spacing then
            return false
        end
    end
    return true
end

local function SpawnSpikes(inst, pos, count)
    for i = #SPIKE_SIZES, 1, -1 do
        local size = SPIKE_SIZES[i]
        if CanSpawnSpikeAt(pos, size) then
            SpawnPrefab("sandspike_"..size).Transform:SetPosition(pos:Get())
            count = count - 1
            break
        end
    end
    if count > 0 then
        local dtheta = TWOPI / count
        for theta = math.random() * dtheta, TWOPI, dtheta do
            local size = SPIKE_SIZES[math.random(#SPIKE_SIZES)]
            local offset = FindWalkableOffset(pos, theta, 2 + math.random() * 2, 3, false, true,
                function(pt)
                    return CanSpawnSpikeAt(pt, size)
                end,
                false, true)
            if offset ~= nil then
                SpawnPrefab("sandspike_"..size).Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
            end
        end
    end
end

local function SpawnBlock(inst, x, z)
    SpawnPrefab("sandblock").Transform:SetPosition(x, 0, z)
end

local function SpawnBlocks(inst, pos, count)
    if count > 0 then
        local dtheta = TWOPI / count
        local thetaoffset = math.random() * TWOPI
        for theta = math.random() * dtheta, TWOPI, dtheta do
            local offset = FindWalkableOffset(pos, theta + thetaoffset, 8 + math.random(), 3, false, true,
                function(pt)
                    return CanSpawnSpikeAt(pt, "block")
                end)
            if offset ~= nil then
                if theta < dtheta then
                    SpawnBlock(inst, pos.x + offset.x, pos.z + offset.z)
                else
                    inst:DoTaskInTime(math.random() * .5, SpawnBlock, pos.x + offset.x, pos.z + offset.z)
                end
            end
        end
    end
end

--------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreezeEx(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            ChooseAttack(inst)
        end
    end),
    EventHandler("attacked", function(inst)
        inst.sg.mem.wantstoeat = nil
        if not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
            not CommonHandlers.HitRecoveryDelay(inst, TUNING.ANTLION_HIT_RECOVERY) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("eatrocks", function(inst)
        if inst.components.health:IsHurt() and not inst.components.health:IsDead() then
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("eat")
            else
                inst.sg.mem.wantstoeat = true
            end
        end
    end),
    EventHandler("antlionstopfighting", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst:StopCombat()
        else
            inst.sg.mem.wantstostopfighting = true
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst, loopcount)
            if inst.sg.mem.wantstostopfighting then
                inst:StopCombat()
                return
            elseif inst.sg.mem.wantstoeat then
                if inst.components.health:IsHurt() then
                    inst.sg:GoToState("eat")
                    return
                end
                inst.sg.mem.wantstoeat = nil
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/hit")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.doattack then
                    if not inst.components.health:IsDead() and
                        not inst.sg.mem.wantstostopfighting and
                        ChooseAttack(inst) then
                        return
                    end
                    inst.sg.statemem.doattack = nil
                end
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.doattack and
                        not inst.components.health:IsDead() and
                        not inst.sg.mem.wantstostopfighting and
                        ChooseAttack(inst) then
                        return
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/death") end),
            TimeEvent(40 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/bodyfall_death") end),
            TimeEvent(42 * FRAMES, function(inst)
                inst.components.sanityaura.aura = 0
                ShakeIfClose(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(5, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
            inst:RemoveTag("NOCLICK")
        end,
    },

    --[[State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_pre")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
        end,

        timeline =
        {
            TimeEvent(24 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("attack_pst", inst.sg.statemem.target)
                end
            end),
        },
    },

    State{
        name = "attack_pst",
        tags = { "attack", "busy", "nosleep", "nofreeze" },

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("attack")
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            CommonHandlers.OnNoSleepTimeEvent(15 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },]]

    State{
        name = "summonspikes",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("cast_pre")
            inst.components.combat:SetAttackPeriod(math.max(TUNING.ANTLION_MIN_ATTACK_PERIOD, inst.components.combat.min_attack_period + TUNING.ANTLION_SPEED_UP))
            inst.components.combat:StartAttack()
            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst.sg.statemem.targetpos = target:GetPosition()
                inst.sg.statemem.targetpos.y = 0
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil then
                if not inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.target = nil
                else
                    local x, y, z = inst.sg.statemem.target.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    if distsq < TUNING.ANTLION_CAST_MAX_RANGE * TUNING.ANTLION_CAST_MAX_RANGE then
                        inst.sg.statemem.targetpos.x, inst.sg.statemem.targetpos.z = x, z
                    elseif distsq >= TUNING.ANTLION_DEAGGRO_DIST * TUNING.ANTLION_DEAGGRO_DIST then
                        inst.sg.statemem.target = nil
                    end
                end
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                --NOTE: sandspike has 28 frames lead in time
                if inst.sg.statemem.targetpos ~= nil then
                    inst.sg.statemem.target = nil --not typo, this is to stop updating
                    SpawnSpikes(inst, inst.sg.statemem.targetpos, math.random(6, 7))
                end
            end),
            TimeEvent(6 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/cast_pre") end),
            TimeEvent(25.5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/cast_post") end),
            TimeEvent(29 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/ground_break") end),
            TimeEvent(32 * FRAMES, ShakeCasting),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("summonspikes_pst")
                end
            end),
        },
    },

    State{
        name = "summonspikes_pst",
        tags = { "attack", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cast_pst")
        end,

        timeline =
        {
            CommonHandlers.OnNoSleepTimeEvent(10 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "summonwall",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cast_sandcastle")
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
            end),
            TimeEvent(9 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/attack_pre") end),
            TimeEvent(14 * FRAMES, function(inst)
                --NOTE: sandblock has 10 frames lead in time
                SpawnBlocks(inst, inst:GetPosition(), 19)
                inst.components.worldsettingstimer:StartTimer("wall_cd", TUNING.ANTLION_WALL_CD)
            end),
            TimeEvent(25 * FRAMES, ShakeRaising),
            CommonHandlers.OnNoSleepTimeEvent(56 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.sg:AddStateTag("nosleep")
                inst.sg:AddStateTag("nofreeze")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/taunt")
            end),
            CommonHandlers.OnNoSleepTimeEvent(28 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
                inst.sg:RemoveStateTag("nofreeze")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },
    },

    State{
        name = "eat",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst, data)
            inst.sg.mem.wantstoeat = nil
            inst.AnimState:PlayAnimation("eat")
            inst.components.burnable:Extinguish()
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/eat") end),
            TimeEvent(36 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/eat") end),
            TimeEvent(38 * FRAMES, function(inst)
                if not inst.components.health:IsDead() then
                    inst.components.health:DoDelta(TUNING.ANTLION_EAT_HEALING)
                    inst.components.combat:SetAttackPeriod(math.min(TUNING.ANTLION_MAX_ATTACK_PERIOD, inst.components.combat.min_attack_period + TUNING.ANTLION_SLOW_DOWN))
                end
            end),
            TimeEvent(59 * FRAMES, function(inst)
                if not inst.components.health:IsDead() then
                    inst.components.health:DoDelta(TUNING.ANTLION_EAT_HEALING)
                    inst.components.combat:SetAttackPeriod(math.min(TUNING.ANTLION_MAX_ATTACK_PERIOD, inst.components.combat.min_attack_period + TUNING.ANTLION_SLOW_DOWN))
                end
            end),
            TimeEvent(71 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/swallow") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.wantstoeat and inst.components.health:IsHurt() then
                        inst.sg:GoToState("eat")
                    else
                        inst.sg.mem.wantstoeat = nil
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },
}

CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(45 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("caninterrupt")
        end),
        TimeEvent(46 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/bodyfall_death") end),
        TimeEvent(48 * FRAMES, ShakeIfClose),
    },
    sleeptimeline =
    {
        TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sleep_in") end),
        TimeEvent(40 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sleep_out") end),
    },
    waketimeline =
    {
        CommonHandlers.OnNoSleepTimeEvent(23 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("nosleep")
        end),
    },
},
{
    onsleep = function(inst)
        inst.sg:AddStateTag("caninterrupt")
    end,
})

CommonStates.AddFrozenStates(states)

return StateGraph("antlion_angry", states, events, "idle")
