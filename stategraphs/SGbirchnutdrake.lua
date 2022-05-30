require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local function OnExit(inst, data)
    if (data ~= nil and data.force) or not inst.sg:HasStateTag("hidden") then
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState(data ~= nil and data.idleanim and "exit_pre" or "exit")
        elseif not inst.sg:HasStateTag("exit") then
            inst.sg.mem.exit = data ~= nil and data.idleanim and "exit_pre" or "exit"
        end
    end
end

local events =
{
    EventHandler("exit", OnExit),
    EventHandler("gotosleep", function(inst)
        OnExit(inst, nil)
    end),
    CommonHandlers.OnFreeze(),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            --target CAN go invalid because SG events are buffered
            inst.sg:GoToState(
                data.target:IsValid()
                and not inst:IsNear(data.target, 2)
                and "attack_leap"
                or "attack",
                data.target
            )
        end
    end),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false, true),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            if inst.sg.mem.exit ~= nil then
                inst.sg:GoToState(inst.sg.mem.exit)
                return
            end

            inst.Physics:Stop()
            inst.target = nil
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "spawn",
        tags = { "busy", "hidden", "noattack" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ground_enter")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_pop_small") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("enter")
            end),
        },
    },

    State{
        name = "ground_idle",
        tags = { "idle", "hidden", "noattack" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ground_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("ground_idle")
            end),
        },
    },

    State{
        name = "enter",
        tags = { "busy", "hidden", "noattack" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_pop_large") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "exit_pre",
        tags = { "busy", "hidden", "noattack", "exit" },

        onenter = function(inst, idleanim)
            inst.sg.mem.exit = nil
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("exit")
            end),
        },
    },

    State{
        name = "exit",
        tags = { "busy", "hidden", "noattack", "exit" },

        onenter = function(inst)
            inst.sg.mem.exit = nil
            inst.Physics:Stop()
            inst.Physics:SetMass(99999)
            inst.AnimState:PlayAnimation("exit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_jump")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_run_voice")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_intoground") end),
            TimeEvent(20 * FRAMES, RemovePhysicsColliders),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },

    State{
        name = "attack_leap",
        tags = { "attack", "canrotate", "busy", "jumping" },

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_jump")
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(5, 0, 0)
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_attack")
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,
    },
}

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_jump") end),
        TimeEvent(12 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_attack")
            inst.components.combat:DoAttack(inst.sg.statemem.target)
        end)
    },
    deathtimeline =
    {
        TimeEvent(FRAMES, function(inst)
            RemovePhysicsColliders(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_die")
        end),
    },
})
CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_run_voice")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/deciduous/drake_run_rustle")
        end),
    },
})
CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)

return StateGraph("birchnutdrake", states, events, "spawn", actionhandlers)
