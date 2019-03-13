require("stategraphs/commonstates")

--------------------------------------------------------------------------

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .5, .02, .2, inst, 30)
end

local function ShakeRoar(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 1.2, .03, .7, inst, 30)
end

local function ShakeSummonRoar(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .03, .4, inst, 30)
end

local function ShakeSummon(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .02, .2, inst, 30)
end

local function ShakePound(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, .7, inst, 30)
end

local function ShakeMindControl(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 2, .04, .075, inst, 30)
end

local function ShakeDeath(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .6, .02, .4, inst, 30)
end

--------------------------------------------------------------------------

local function SetBlinkLevel(inst, level)
    inst.AnimState:SetAddColour(level, level, level, 0)
    inst.AnimState:SetLightOverride(math.min(1, (inst.sg.statemem.baselightoverride or 0) + level))
end

local function BlinkHigh(inst) SetBlinkLevel(inst, 1) end
local function BlinkMed(inst) SetBlinkLevel(inst, .3) end
local function BlinkLow(inst) SetBlinkLevel(inst, .2) end
local function BlinkOff(inst) SetBlinkLevel(inst, 0) end

--------------------------------------------------------------------------

local function DoTrail(inst)
    if inst.foreststalker then
        inst:DoTrail()
    end
end

--------------------------------------------------------------------------

local MAIN_SHIELD_CD = 1.2
local function PickShield(inst)
    local t = GetTime()
    if (inst.sg.mem.lastshieldtime or 0) + .2 >= t then
        return
    end

    inst.sg.mem.lastshieldtime = t

    --variation 3 or 4 is the main shield
    local dt = t - (inst.sg.mem.lastmainshield or 0)
    if dt >= MAIN_SHIELD_CD then
        inst.sg.mem.lastmainshield = t
        return math.random(3, 4)
    end

    local rnd = math.random()
    if rnd < dt / MAIN_SHIELD_CD then
        inst.sg.mem.lastmainshield = t
        return math.random(3, 4)
    end

    return rnd < dt / (MAIN_SHIELD_CD * 2) + .5 and 2 or 1
end

--------------------------------------------------------------------------

local function StartMindControlSound(inst)
    if inst.sg.mem.mindcontrolsoundtask ~= nil then
        inst.sg.mem.mindcontrolsoundtask:Cancel()
        inst.sg.mem.mindcontrolsoundtask = nil
        inst.SoundEmitter:KillSound("mindcontrol")
    end
    if not inst.SoundEmitter:PlayingSound("mindcontrol") then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/mindcontrol_LP", "mindcontrol")
    end
end

local function OnMindControlSoundFaded(inst)
    inst.sg.mem.mindcontrolsoundtask = nil
    inst.SoundEmitter:KillSound("mindcontrol")
end

local function StopMindControlSound(inst)
    if inst.sg.mem.mindcontrolsoundtask == nil and inst.SoundEmitter:PlayingSound("mindcontrol") then
        inst.SoundEmitter:SetVolume("mindcontrol", 0)
        inst.sg.mem.mindcontrolsoundtask = inst:DoTaskInTime(10, OnMindControlSoundFaded)
    end
end

--------------------------------------------------------------------------

local function ShouldReturnToGate(inst)
    return inst.returntogate and not inst.components.combat:HasTarget()
end

--------------------------------------------------------------------------

local events =
{
    CommonHandlers.OnLocomote(false, true),
    EventHandler("death", function(inst)
        if not inst.sg:HasStateTag("delaydeath") then
            if inst.atriumstalker then
                inst:DespawnChannelers()
                inst.sg:GoToState(inst:IsAtriumDecay() and "death" or "death3")
            else
                inst.sg:GoToState(inst.foreststalker and "death2" or "death")
            end
        end
    end),
    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("fossilsnare", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) and
            data ~= nil and data.targets ~= nil and #data.targets > 0 then
            inst.sg:GoToState("snare", data.targets)
        end
    end),
    EventHandler("fossilspikes", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("spikes")
        end
    end),
    EventHandler("shadowchannelers", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("summon_channelers_pre")
        end
    end),
    EventHandler("fossilminions", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("summon_minions_pre")
        end
    end),
    EventHandler("fossilfeast", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("eat_pre")
        end
    end),
    EventHandler("mindcontrol", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("mindcontrol_pre")
        end
    end),
    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() then
            if inst.hasshield then
                local shieldtype = PickShield(inst)
                if shieldtype ~= nil then
                    local fx = SpawnPrefab("stalker_shield"..tostring(shieldtype))
                    fx.entity:SetParent(inst.entity)
                    if shieldtype < 3 and math.random() < .5 then
                        fx.AnimState:SetScale(-2.36, 2.36, 2.36)
                    end
                end
            end
            if (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
                (inst.hasshield or (inst.sg.mem.last_hit_time or 0) + TUNING.STALKER_HIT_RECOVERY < GetTime()) then
                if inst.hasshield and data.attacker ~= nil and data.attacker:IsValid() then
                    inst:ForceFacePoint(data.attacker.Transform:GetWorldPosition())
                end
                inst.sg:GoToState("hit", inst.hasshield)
            end
        end
    end),
    EventHandler("roar", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("taunt")
        elseif not inst.sg:HasStateTag("roar") then
            inst.sg.mem.wantstoroar = true
        end
    end),
    EventHandler("flinch", function(inst)
        inst.sg.mem.wantstoflinch = true
        if not (inst.sg:HasStateTag("flinching") or inst.components.health:IsDead()) and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) then
            inst.sg:GoToState("flinch")
        end
    end),
    EventHandler("skullache", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("skullache")
        else
            inst.sg.mem.wantstoskullache = true
        end
    end),
    EventHandler("fallapart", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("fallapart")
        else
            inst.sg.mem.wantstofallapart = true
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.foreststalker and inst.components.health:IsDead() then
                inst.sg:GoToState("death2")
            elseif inst.sg.mem.wantstoflinch then
                inst.sg:GoToState("flinch")
            elseif inst.sg.mem.wantstoskullache then
                inst.sg:GoToState("skullache")
            elseif inst.sg.mem.wantstofallapart then
                inst.sg:GoToState("fallapart")
            elseif inst.sg.mem.wantstoroar then
                inst.sg:GoToState("taunt")
            elseif ShouldReturnToGate(inst) then
                inst.sg:GoToState("idle_gate")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle")
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/in") end),
            TimeEvent(26 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
        },

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
        name = "resurrect",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.health:SetInvincible(true)
            inst.Transform:SetNoFaced()
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_get_bloodpump")
            inst.sg.statemem.baselightoverride = .1
            if inst.foreststalker then
                inst:StopBlooming()
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/enter") end),

            TimeEvent(18 * FRAMES, BlinkLow),
            TimeEvent(19 * FRAMES, BlinkOff),

            TimeEvent(29 * FRAMES, BlinkLow),
            TimeEvent(30 * FRAMES, function(inst)
                BlinkOff(inst)
                ShakeIfClose(inst)
            end),

            TimeEvent(31 * FRAMES, BlinkMed),
            TimeEvent(32 * FRAMES, BlinkLow),
            TimeEvent(33 * FRAMES, BlinkOff),

            TimeEvent(37 * FRAMES, BlinkMed),
            TimeEvent(38 * FRAMES, BlinkLow),
            TimeEvent(39 * FRAMES, BlinkOff),

            TimeEvent(40 * FRAMES, BlinkMed),
            TimeEvent(41 * FRAMES, BlinkOff),

            TimeEvent(42 * FRAMES, function(inst)
                BlinkMed(inst)
                ShakeIfClose(inst)
            end),
            TimeEvent(43 * FRAMES, BlinkLow),
            TimeEvent(44 * FRAMES, BlinkOff),

            TimeEvent(47 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/head") end),

            TimeEvent(50 * FRAMES, BlinkMed),
            TimeEvent(51 * FRAMES, BlinkLow),
            TimeEvent(52 * FRAMES, BlinkOff),

            TimeEvent(54 * FRAMES, BlinkMed),
            TimeEvent(55 * FRAMES, BlinkLow),
            TimeEvent(56 * FRAMES, BlinkOff),

            TimeEvent(57 * FRAMES, function(inst)
                BlinkHigh(inst)
                ShakeIfClose(inst)
            end),
            TimeEvent(58 * FRAMES, BlinkOff),

            TimeEvent(60 * FRAMES, BlinkMed),
            TimeEvent(61 * FRAMES, BlinkLow),
            TimeEvent(62 * FRAMES, BlinkOff),

            TimeEvent(63 * FRAMES, function(inst)
                inst.sg.statemem.baselightoverride = 0
                inst.sg.statemem.fadeout = .2
            end),

            TimeEvent(67 * FRAMES, function(inst)
                if inst.foreststalker then
                    inst:StartBlooming()
                end
            end),
        },

        onupdate = function(inst)
            if inst.sg.statemem.fadeout ~= nil then
                if inst.sg.statemem.fadeout > .02 then
                    inst.sg.statemem.fadeout = inst.sg.statemem.fadeout - .02
                    inst.AnimState:SetLightOverride(inst.sg.statemem.fadeout)
                else
                    inst.sg.statemem.fadeout = nil
                    inst.AnimState:SetLightOverride(0)
                end
            elseif inst.sg.statemem.baselightoverride < .2 then
                inst.sg.statemem.baselightoverride = math.min(.2, inst.sg.statemem.baselightoverride + .01)
                inst.AnimState:SetLightOverride(inst.sg.statemem.baselightoverride)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.atriumstalker and "taunt" or "idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
            inst.components.health:SetInvincible(false)
            inst.sg.statemem.baselightoverride = nil
            BlinkOff(inst)
            if inst.foreststalker then
                inst:StartBlooming()
            end
        end,
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.components.locomotor:WalkForward()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/footstep") end),
            TimeEvent(1 * FRAMES, DoTrail),
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/footstep") end),
            TimeEvent(18 * FRAMES, DoTrail),
            TimeEvent(32 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/footstep") end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("walk")
        end,
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, DoTrail),
        },

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

        onenter = function(inst, shielded)
            inst.components.locomotor:StopMoving()
            if shielded then
                inst.AnimState:PlayAnimation("shield")
                inst.sg:SetTimeout(18 * FRAMES)
            else
                inst.AnimState:PlayAnimation("hit")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/hit")
                inst.sg:SetTimeout(16 * FRAMES)
                inst.sg.mem.last_hit_time = GetTime()
            end
        end,

        ontimeout = function(inst)
            if not inst.components.health:IsDead() then
                if inst.sg.statemem.dosnare then
                    local targets = inst:FindSnareTargets()
                    if targets ~= nil then
                        inst.sg:GoToState("snare", targets)
                        return
                    end
                end
                if inst.sg.statemem.dospikes then
                    inst.sg:GoToState("spikes")
                    return
                elseif inst.sg.statemem.doattack then
                    inst.sg:GoToState("attack")
                    return
                end
            end
            inst.sg.statemem.doattack = nil
            inst.sg.statemem.dosnare = nil
            inst.sg.statemem.dospikes = nil
            inst.sg:RemoveStateTag("busy")
        end,

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("fossilsnare", function(inst)
                inst.sg.statemem.dosnare = true
            end),
            EventHandler("fossilspikes", function(inst)
                inst.sg.statemem.dospikes = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if not inst.components.health:IsDead() then
                        if inst.sg.statemem.dosnare then
                            local targets = inst:FindSnareTargets()
                            if targets ~= nil then
                                inst.sg:GoToState("snare", targets)
                                return 
                            end
                        end
                        if inst.sg.statemem.dospikes then
                            inst.sg:GoToState("spikes")
                            return
                        elseif inst.sg.statemem.doattack then
                            inst.sg:GoToState("attack")
                            return
                        end
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
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst:AddTag("NOCLICK")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death")
            if inst.atriumstalker then
                inst:BattleChatter("decaycry", true)
            end
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(17 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(21 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(24 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(27 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_bone_drop")
            end),
            TimeEvent(55 * FRAMES, function(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(55.5 * FRAMES, ShakeDeath),
            TimeEvent(5, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst:RemoveTag("NOCLICK")
        end,
    },

    State{
        name = "death2",
        tags = { "busy", "movingdeath" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death2")
            inst:AddTag("NOCLICK")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_walk") end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.components.locomotor.walkspeed = 2.2
                inst.components.locomotor:WalkForward()
            end),
            TimeEvent(20 * FRAMES, DoTrail),
            TimeEvent(21.5 * FRAMES, ShakeIfClose),
            TimeEvent(22 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop")
                inst.components.locomotor.walkspeed = 2
                inst.components.locomotor:WalkForward()
            end),
            TimeEvent(38 * FRAMES, DoTrail),
            TimeEvent(39.5 * FRAMES, ShakeIfClose),
            TimeEvent(40 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop")
                inst.components.locomotor.walkspeed = 1.5
                inst.components.locomotor:WalkForward()
            end),
            TimeEvent(54 * FRAMES, DoTrail),
            TimeEvent(55 * FRAMES, function(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(55.5 * FRAMES, ShakeDeath),
            TimeEvent(56 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop")
                inst.components.locomotor.walkspeed = 1
                inst.components.locomotor:WalkForward()
            end),
            TimeEvent(68.5 * FRAMES, ShakeIfClose),
            TimeEvent(69 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop")
                inst.components.locomotor:StopMoving()
                inst:StopBlooming()
            end),
            TimeEvent(5, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst:RemoveTag("NOCLICK")
            inst.components.locomotor.walkspeed = TUNING.STALKER_SPEED
        end,
    },

    State{
        name = "death3",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death3_pre")
            inst:AddTag("NOCLICK")

            inst:EnableCameraFocus(true)
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(7 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.death = true
                    inst.sg:GoToState("death3_pst")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.death then
                --Should NOT happen!
                inst:RemoveTag("NOCLICK")
                inst:EnableCameraFocus(false)
            end
        end,
    },

    State{
        name = "death3_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death3")

            --12 frames from "death3_pre" animation
            --3 frames buffer
            inst.sg:SetTimeout(TUNING.ATRIUM_GATE_DESTABILIZE_DELAY - 15 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/swell") end),
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death_pop") end),
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip") end),
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip_snap") end),
            TimeEvent(41 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/pianohits_1") end),
            TimeEvent(44 * FRAMES, ShakeIfClose),
            TimeEvent(49 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/orchhits") end),
            TimeEvent(55 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/stretch") end),
            TimeEvent(73 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip") end),
            TimeEvent(85 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip_snap") end),
            TimeEvent(108 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/pianohits_1") end),
            TimeEvent(110 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip") end),
            TimeEvent(111 * FRAMES, ShakeIfClose),
            TimeEvent(116 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/orchhits") end),
            TimeEvent(132 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip_snap") end),
            TimeEvent(135 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip_snap")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/fwump")
            end),
            TimeEvent(138 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/pianohits_1") end),
            TimeEvent(152 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/pianohits_2") end),
            TimeEvent(155 * FRAMES, ShakeDeath),
            TimeEvent(168 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/stretch") end),
            TimeEvent(170 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt_short") end),
            TimeEvent(179 * FRAMES, function(inst)
                inst:BattleChatter("deathcry", true)
            end),
            TimeEvent(185 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/whip_snap")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death")
            end),
            TimeEvent(190 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/death3/transform") end),
            TimeEvent(194 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                ShakeIfClose(inst)
            end),
            TimeEvent(300 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/charlie/attack_low") end),
            TimeEvent(303 * FRAMES, ShakeIfClose),
            TimeEvent(304 * FRAMES, function(inst)
                if inst.persists then
                    inst.persists = false
                    local pos = inst:GetPosition()
                    SpawnPrefab("flower_rose").Transform:SetPosition(pos:Get())
                    inst.components.lootdropper:DropLoot(pos)
                end
            end),
            TimeEvent(15, ErodeAway),
        },

        ontimeout = function(inst)
            inst:EnableCameraFocus(false)
        end,

        onexit = function(inst)
            --Should NOT happen!
            inst:RemoveTag("NOCLICK")
            inst:EnableCameraFocus(false)
        end,
    },

    State{
        name = "taunt",
        tags = { "busy", "roar" },

        onenter = function(inst)
            inst.sg.mem.wantstoroar = nil
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt1")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out")
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt") end),
            TimeEvent(18 * FRAMES, ShakeRoar),
            TimeEvent(19 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(58 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out")
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/head") end),
            TimeEvent(13 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack_swipe") end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
            TimeEvent(47 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/head") end),
            TimeEvent(63 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "snare",
        tags = { "attack", "busy", "snare" },

        onenter = function(inst, targets)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("attack1")
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
            inst:StartAbility("snare")
            inst.sg.statemem.targets = targets
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack1_pbaoe_pre") end),
            TimeEvent(24 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack1_pbaoe") end),
            TimeEvent(25.5 * FRAMES, function(inst)
                ShakePound(inst)
                inst.components.combat:DoAreaAttack(inst, 3.5, nil, nil, nil, { "INLIMBO", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" })
                if inst.sg.statemem.targets ~= nil then
                    inst:SpawnSnares(inst.sg.statemem.targets)
                end
            end),
            TimeEvent(39 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "spikes",
        tags = { "attack", "busy", "spikes" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("spike")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack1_pbaoe_pre")
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
            inst:StartAbility("spikes")
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst:SpawnSpikes()
            end),
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/in") end),
            TimeEvent(30 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/laugh")
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(48 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt_short", nil, .6) end),
            TimeEvent(50 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/attack1_pbaoe") end),
            TimeEvent(51 * FRAMES, function(inst)
                ShakePound(inst)
                inst.components.combat:DoAreaAttack(inst, 3.5, nil, nil, nil, { "INLIMBO", "notarget", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" })
            end),
            TimeEvent(61 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "summon_channelers_pre",
        tags = { "busy", "summoning" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt3_pre")
            inst.sg.statemem.count = 2
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
            inst:StartAbility("channelers")
        end,

        events =
        {
            EventHandler("attacked", function(inst)
                inst.sg.statemem.count = inst.sg.statemem.count - 1
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:SpawnChannelers()
                    inst:BattleChatter("summon_channelers")
                    inst.sg:GoToState("summon_channelers_loop", inst.sg.statemem.count)
                end
            end),
        },
    },

    State{
        name = "summon_channelers_loop",
        tags = { "busy", "summoning" },

        onenter = function(inst, count)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt3_loop")
            inst.sg.statemem.count = count or 0
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt_short") end),
            TimeEvent(11 * FRAMES, ShakeSummonRoar),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(29 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt_short") end),
            TimeEvent(34 * FRAMES, ShakeSummonRoar),
            TimeEvent(35 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                inst.sg.statemem.count = inst.sg.statemem.count - 1
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.count > 1 then
                        inst.sg:GoToState("summon_channelers_loop", inst.sg.statemem.count - 1)
                    else
                        inst.sg:GoToState("summon_channelers_pst")
                    end
                end
            end),
        },
    },

    State{
        name = "summon_channelers_pst",
        tags = { "busy", "summoning" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt3_pst")
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
        name = "summon_minions_pre",
        tags = { "busy", "summoning" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("summon_pre")
            inst.sg.statemem.count = 6
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
            inst:StartAbility("minions")
        end,

        events =
        {
            EventHandler("attacked", function(inst)
                inst.sg.statemem.count = inst.sg.statemem.count - 1
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:SpawnMinions()
                    inst:BattleChatter("summon_minions")
                    inst.sg:GoToState("summon_minions_loop", { count = inst.sg.statemem.count })
                end
            end),
        },
    },

    State{
        name = "summon_minions_loop",
        tags = { "busy", "summoning" },

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("summon_loop")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/summon")
            inst.sg.statemem.data = data or { count = 0 }
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, ShakeSummon),
            TimeEvent(5 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                inst.sg.statemem.data.count = inst.sg.statemem.data.count - 1
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.data.count > 1 or not inst.sg.statemem.data.looped then
                        inst.sg.statemem.data.count = inst.sg.statemem.data.count - 1
                        inst.sg.statemem.data.looped = true
                        inst.sg:GoToState("summon_minions_loop", inst.sg.statemem.data)
                    else
                        inst.sg:GoToState("summon_minion_pst")
                    end
                end
            end),
        },
    },

    State{
        name = "summon_minion_pst",
        tags = { "busy", "summoning" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("summon_pst")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "eat_pre",
        tags = { "busy", "feasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt2_pre")
            inst.sg.statemem.data =
            {
                side = math.random() < .5,
                resist = 3,
            }
        end,

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.hasshield then
                    inst.sg.statemem.data.resist = inst.sg.statemem.data.resist - 1
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("eat_idle", inst.sg.statemem.data)
                end
            end),
        },
    },

    State{
        name = "eat_idle",
        tags = { "busy", "feasting" },

        onenter = function(inst, data)
            local ishurt = inst.components.health:IsHurt()
            if ishurt and #inst:FindMinions() > 0 then
                data.idle = 0
                inst.sg:GoToState("eat_loop", data)
                return
            elseif data.idle ~= nil and (not ishurt or data.idle > 6 or data.resist <= 0 or #inst:FindMinions(5) <= 0) then
                inst.sg:GoToState("eat_pst")
                return
            end

            data.idle = (data.idle or 0) + 1
            inst.sg.statemem.data = data

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt2_loop1")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/in") end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(18 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.hasshield then
                    inst.sg.statemem.data.resist = inst.sg.statemem.data.resist - 1
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("eat_idle", inst.sg.statemem.data)
                end
            end),
        },
    },

    State{
        name = "eat_loop",
        tags = { "busy", "feasting" },

        onenter = function(inst, data)
            inst.components.locomotor:StopMoving()
            data.side = not data.side
            inst.sg.statemem.data = data
            inst.AnimState:PlayAnimation(data.side and "taunt2_loop2" or "taunt2_loop3")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                if inst:EatMinions() > 0 then
                    inst.AnimState:Show("FX_EAT")
                else
                    inst.AnimState:Hide("FX_EAT")
                end
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt_short")
            end),
            TimeEvent(11.5 * FRAMES, ShakeIfClose),
            TimeEvent(12.5 * FRAMES, function(inst)
                inst.components.epicscare:Scare(5)
            end),
            TimeEvent(21 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
        },

        events =
        {
            EventHandler("attacked", function(inst)
                if not inst.hasshield then
                    inst.sg.statemem.data.resist = inst.sg.statemem.data.resist - 1
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("eat_idle", inst.sg.statemem.data)
                end
            end),
        },
    },

    State{
        name = "eat_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt2_pst")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "mindcontrol_pre",
        tags = { "busy", "mindcontrol" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("control_pre")
            inst.sg.statemem.count = 4
            --V2C: don't trigger attack cooldown
            --inst.components.combat:StartAttack()
            inst:StartAbility("mindcontrol")
        end,

        events =
        {
            --[[EventHandler("attacked", function(inst)
                inst.sg.statemem.count = inst.sg.statemem.count - 1
            end),]]
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mindcontrol_loop", inst.sg.statemem.count)
                end
            end),
        },
    },

    State{
        name = "mindcontrol_loop",
        tags = { "busy", "mindcontrol" },

        onenter = function(inst, count)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("control_loop")
            StartMindControlSound(inst)
            inst.sg.statemem.count = inst:MindControl() > 0 and count or 0
            ShakeMindControl(inst)
            inst.components.epicscare:Scare(5)
        end,

        onupdate = function(inst)
            if inst:MindControl() <= 0 then
                inst.sg.statemem.count = 0
            end
        end,

        events =
        {
            --[[EventHandler("attacked", function(inst)
                inst.sg.statemem.count = inst.sg.statemem.count - 1
            end),]]
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.count > 1 then
                        inst.sg.statemem.continue = true
                        inst.sg:GoToState("mindcontrol_loop", inst.sg.statemem.count - 1)
                    else
                        inst.sg:GoToState("mindcontrol_pst")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continue then
                StopMindControlSound(inst)
            end
        end,
    },

    State{
        name = "mindcontrol_pst",
        tags = { "busy", "mindcontrol" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("control_pst")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

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
        name = "flinch",
        tags = { "busy", "flinch", "delaydeath" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt2_pre")
            inst.sg.mem.wantstoflinch = nil
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("flinch_loop")
                end
            end),
        },
    },

    State{
        name = "flinch_loop",
        tags = { "busy", "flinch", "delaydeath" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if not inst.AnimState:IsCurrentAnimation("taunt2_loop") then
                inst.AnimState:PlayAnimation("taunt2_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/hurt") end),
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
            TimeEvent(24 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/in") end),
        },

        ontimeout = function(inst)
            if inst.sg.mem.wantstoflinch and not inst.components.health:IsDead() then
                inst.sg:GoToState("flinch_loop")
            else
                inst.AnimState:PushAnimation("taunt2_pst", false)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.components.health:IsDead() and "death2" or "idle")
                end
            end),
        },

        onexit = function(inst)
            inst.sg.mem.wantstoflinch = nil
        end,
    },

    State{
        name = "skullache",
        tags = { "busy", "skullache", "delaydeath" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt3_pre")
            inst.AnimState:PushAnimation("taunt3_loop", false)
            inst.AnimState:PushAnimation("taunt3_pst", false)
            --pre: 8 frames
            --loop: 40 frames
            --pst: 18 frames
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/taunt")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/head")
            end),
            TimeEvent(25 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/head") end),
            TimeEvent(47 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/head") end),
            TimeEvent(68 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.sg.mem.wantstoskullache = nil
        end,
    },

    State{
        name = "fallapart",
        tags = { "busy", "fallapart", "delaydeath" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt1")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop") end),
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop") end),
            TimeEvent(19 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/hurt") end),
            TimeEvent(23 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/bone_drop") end),
            TimeEvent(46 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/in") end),
            TimeEvent(50 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/arm") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.sg.mem.wantstofallapart = nil
        end,
    },

    State{
        name = "idle_gate",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("gate_pre")
            local stargate = inst.components.entitytracker:GetEntity("stargate")
            if stargate ~= nil then
                inst:ForceFacePoint(stargate.Transform:GetWorldPosition())
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.idlegate = true
                    inst:BattleChatter("usegate")
                    inst.sg:GoToState("idle_gate_loop")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.idlegate then
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "idle_gate_loop",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("gate_loop")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/in") end),
            TimeEvent(17 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/out") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.idlegate = true
                    inst.sg:GoToState(ShouldReturnToGate(inst) and "idle_gate_loop" or "idle_gate_pst")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.idlegate then
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "idle_gate_pst",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("gate_pst")
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
        end,
    },
}

return StateGraph("SGstalker", states, events, "idle")
