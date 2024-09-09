local MOLE_PEEK_INTERVAL = 20
local MOLE_PEEK_VARIANCE = 5

require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.STEALMOLEBAIT, function(inst)
        return inst.isunder and "steal_pre_under" or "steal_pre_above"
    end),
    ActionHandler(ACTIONS.MAKEMOLEHILL, "make_molehill"),
    ActionHandler(ACTIONS.MOLEPEEK, "peek"),
}

local function onstopflee(inst)
    inst.flee = false
end

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst, data)
        inst.flee = true
        inst:DoTaskInTime(math.random(3, 6), onstopflee)
        if data ~= nil and data.weapon ~= nil then
            if data.weapon:HasTag("hammer") then
                inst.components.inventory:DropEverything(false, true)
                if inst.components.health ~= nil and not inst.components.health:IsDead() then
                    inst.sg:GoToState("stunned", false)
                end
            elseif not inst.sg:HasStateTag("busy") and inst.components.health ~= nil and not inst.components.health:IsDead() then
                inst.sg:GoToState("hit")
            end
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death")
    end),
    EventHandler("trapped", function(inst)
        inst.flee = true
        inst:DoTaskInTime(math.random(3, 6), onstopflee)
    end),
    EventHandler("locomote",
        function(inst)
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState(
                    inst.components.locomotor:WantsToMoveForward() and
                    (inst.isunder and "walk_pre" or "exit") or
                    (inst.sg:HasStateTag("moving") and "walk_pst" or "idle")
                )
            end
        end),

    EventHandler("stunbomb", function(inst)
        inst.sg:GoToState("stunned", true)
    end),
}

local function SpawnMoveFx(inst)
    SpawnPrefab("mole_move_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function PlayStunnedSound(inst)
    if not inst.SoundEmitter:PlayingSound("stunned") then
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "stunned")
    end
end

local function KillStunnedSound(inst)
    inst.SoundEmitter:KillSound("stunned")
end

local function KillSniff(inst)
    inst.SoundEmitter:KillSound("sniff")
end

local states =
{
    State{
        name = "enter",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:KillSound("move")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "peek",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("enter")

            inst.peek_interval = GetRandomWithVariance(MOLE_PEEK_INTERVAL, MOLE_PEEK_VARIANCE)
            inst.last_above_time = GetTime()
            inst:PerformBufferedAction()
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
            end),
            TimeEvent(3*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge_voice")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("exit")
            end),
        },
    },

    State{
        name = "steal_pre_under",
        tags = { "busy" },
        onenter = function(inst, data)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("enter")
            inst.AnimState:PushAnimation("idle", false)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
            end),
            TimeEvent(3*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge_voice")
            end),
            TimeEvent(26*FRAMES, function(inst)
                if not inst.SoundEmitter:PlayingSound("sniff") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                end
            end),
            TimeEvent(77*FRAMES, KillSniff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("steal")
            end),
        },

        onexit = KillSniff,
    },

    State{
        name = "steal_pre_above",
        tags = { "busy" },
        onenter = function(inst, data)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.SoundEmitter:KillSound("move")
            inst.AnimState:PlayAnimation("idle", false)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                if not inst.SoundEmitter:PlayingSound("sniff") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                end
            end),
            TimeEvent(52*FRAMES, KillSniff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("steal")
            end)
        },

        onexit = KillSniff,
    },

    State{
        name = "steal",
        tags = { "busy", "canrotate" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.AnimState:PlayAnimation("action")
            inst.AnimState:PushAnimation("idle", false)
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/pickup")
            end),
            TimeEvent(12*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(27*FRAMES, function(inst)
                if not inst.SoundEmitter:PlayingSound("sniff") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                end
            end),
            TimeEvent(78*FRAMES, KillSniff),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("exit")
            end),
        },

        onexit = KillSniff,
    },

    State{
        name = "exit",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.AnimState:PlayAnimation("exit")
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/jump")
            end),
            TimeEvent(26*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract")
            end),
            TimeEvent(43*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:SetUnderPhysics()
                inst.last_above_time = GetTime()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("move")
            if inst.isunder then
                inst.sg:AddStateTag("noattack")
            end
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation(inst.isunder and "idle_under" or "idle", true)
            else
                inst.AnimState:PlayAnimation(inst.isunder and "idle_under" or "idle", true)
            end
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                if not (inst.isunder or inst.SoundEmitter:PlayingSound("sniff")) then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sniff", "sniff")
                end
            end),
            TimeEvent(52*FRAMES, KillSniff),
        },
    },

    State{
        name = "walk_pre",
        tags = { "moving", "canrotate", "noattack" },

        onenter = function(inst)
            inst:SetUnderPhysics()
            inst.AnimState:PlayAnimation("walk_pre")
            if not inst.SoundEmitter:PlayingSound("move") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/move", "move")
            end
            inst.components.locomotor:WalkForward()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("walk")
            end),
        }
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate", "noattack" },

        onenter = function(inst)
            inst:SetUnderPhysics()
            inst.AnimState:PlayAnimation("walk_loop")
            inst.components.locomotor:WalkForward()
        end,

        timeline =
        {
            TimeEvent(0*FRAMES,  SpawnMoveFx),
            TimeEvent(5*FRAMES,  SpawnMoveFx),
            TimeEvent(10*FRAMES, SpawnMoveFx),
            TimeEvent(15*FRAMES, SpawnMoveFx),
            TimeEvent(20*FRAMES, SpawnMoveFx),
            TimeEvent(25*FRAMES, SpawnMoveFx),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("walk")
            end),
        }
    },

    State{
        name = "walk_pst",
        tags = { "canrotate", "noattack" },

        onenter = function(inst)
            inst:SetUnderPhysics()
            inst.components.locomotor:StopMoving()

            --local should_softstop = false
            --if should_softstop then
                --inst.AnimState:PushAnimation("walk_pst")
            --else
                inst.AnimState:PlayAnimation("walk_pst")
            --end

            inst.SoundEmitter:KillSound("move")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "gohome",
        tags = { "canrotate" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if inst.isunder then
                inst.sg:AddStateTag("noattack")
                inst.AnimState:PlayAnimation("idle_under")
            else
                inst.AnimState:PlayAnimation("idle")
            end
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function (inst, data)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "make_molehill",
        tags = { "busy", "noattack" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst:SetUnderPhysics()
            inst.AnimState:PlayAnimation("mound")
        end,

        timeline =
        {
            TimeEvent(16*FRAMES, function(inst)
                inst:SetAbovePhysics()
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
            end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge_voice") end),
        },

        events =
        {
            EventHandler("animover", function(inst, data)
                inst:PerformBufferedAction()
                inst:SetUnderPhysics()
                inst.last_above_time = GetTime()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:KillSound("move")
            inst.SoundEmitter:KillSound("sniff")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            inst.components.inventory:DropEverything(false, true)
        end,
    },

    State{
        name = "fall",
        tags = { "busy" },
        onenter = function(inst)
            inst:SetAbovePhysics()
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0, math.random() * 10 - 20, 0)
            inst.AnimState:PlayAnimation("stunned_loop", true)
        end,

        onupdate = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 2 then
                inst.Physics:SetMotorVel(0, 0, 0)
                if y <= .1 then
                    inst.Physics:Stop()
                    inst.Physics:SetDamping(5)
                    inst.Physics:Teleport(x, 0, z)
                    inst.sg:GoToState("stunned", true)
                end
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.Transform:SetPosition(x, 0, z)
        end,
    },

    State{
        name = "stunned",
        tags = { "busy", "noattack","canwxscan" },

        onenter = function(inst, skippre)
            inst:ClearBufferedAction()
            inst.SoundEmitter:KillSound("move")
            inst.SoundEmitter:KillSound("sniff")
            inst.components.inventory:DropEverything(false, true)
            inst.Physics:Stop()
            inst:SetAbovePhysics()
            inst.Physics:SetMass(1)
            local fxdelay = 0
            if skippre then
                inst.AnimState:PlayAnimation("stunned_loop", true)
            else
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/hurt")
                inst.AnimState:PlayAnimation("stunned_pre", false)
                fxdelay = inst.AnimState:GetCurrentAnimationLength()
                inst.AnimState:PushAnimation("stunned_loop", true)
            end
            inst.sg.statemem.playtask = inst:DoPeriodicTask(23 * FRAMES, PlayStunnedSound, fxdelay)
            inst.sg.statemem.killtask = inst:DoPeriodicTask(23 * FRAMES, KillStunnedSound, fxdelay + 11 * FRAMES)
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2))
            inst.last_above_time = GetTime()
            if inst.components.inventoryitem ~= nil then
                inst.components.inventoryitem.canbepickedup = true
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("stunned_pst")
        end,

        onexit = function(inst)
            if inst.components.inventoryitem ~= nil then
                inst.components.inventoryitem.canbepickedup = false
            end
            inst.SoundEmitter:KillSound("stunned")
            if inst.sg.statemem.playtask ~= nil then
                inst.sg.statemem.playtask:Cancel()
                inst.sg.statemem.playtask = nil
            end
            if inst.sg.statemem.killtask ~= nil then
                inst.sg.statemem.killtask:Cancel()
                inst.sg.statemem.killtask = nil
            end
            inst.Physics:SetMass(99999)
        end,
    },

    State{
        name = "stunned_pst",
        tags = { "busy" },
        onenter = function(inst)
            inst:SetAbovePhysics()
            inst.AnimState:PushAnimation("stunned_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/jump")
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/retract") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:KillSound("move")
            inst.SoundEmitter:KillSound("sniff")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
            inst:SetAbovePhysics()
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if inst.isunder then
                inst:SetAbovePhysics()
                inst.AnimState:PlayAnimation("enter")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge")
                inst.AnimState:PushAnimation("sleep_pre", false)
            else
                inst.AnimState:PlayAnimation("sleep_pre")
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:KillSound("sniff")
                inst.SoundEmitter:KillSound("stunned")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("sleeping")
            end),
            EventHandler("onwakeup", function(inst)
                inst.sg:GoToState("wake")
            end),
        },
    },

    State{
        name = "sleeping",
        tags = { "busy", "sleeping" },
        onenter = function(inst)
            inst:SetAbovePhysics()
            inst.AnimState:PlayAnimation("sleep_loop")
        end,

        timeline =
        {
            TimeEvent(27*FRAMES, function(inst)
                if not inst.SoundEmitter:PlayingSound("sleep") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/sleep", "sleep")
                end
            end),
            TimeEvent(42*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("sleep")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("sleeping")
            end),
            EventHandler("onwakeup", function(inst)
                inst.sg:GoToState("wake")
            end),
        },
    },

    State{
        name = "wake",
        tags = { "busy", "waking" },

        onenter = function(inst)
            inst:SetAbovePhysics()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_pst")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:KillSound("sleep")
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}
CommonStates.AddFrozenStates(states)

return StateGraph("mole", states, events, "idle", actionhandlers)
