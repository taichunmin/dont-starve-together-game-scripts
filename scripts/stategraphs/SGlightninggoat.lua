require("stategraphs/commonstates")

local events =
{
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    -- EventHandler("attacked", function(inst)
    --     if inst.components.health and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
    --         inst.sg:GoToState("hit")
    --     end
    -- end),
}

local states=
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.sg:SetTimeout(math.random()*4+2)
            if inst.charged then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
            end
            inst.jacobsladdersfxtask = inst:DoPeriodicTask(44*FRAMES, function(inst)
                if inst.charged then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
                end
            end)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("bleet")
        end,

        onexit= function(inst)
            if inst.jacobsladdersfxtask then
                inst.jacobsladdersfxtask:Cancel()
                inst.jacobsladdersfxtask = nil
            end
        end,

        timeline =
        {
            TimeEvent(GetRandomWithVariance(8,3)*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/chew")
            end),
            TimeEvent(GetRandomWithVariance(33,3)*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/chew")
            end),
        },
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jump")
            if inst.charged then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
            end
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                inst.components.locomotor:RunForward()
            end),
            TimeEvent(14*FRAMES, function(inst)
                inst.components.locomotor:WalkForward()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
        },
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst", false)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt_pre")
            inst.AnimState:PushAnimation("taunt")
            inst.AnimState:PushAnimation("taunt_pst", false)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/taunt") end),
            TimeEvent(17*FRAMES, function(inst) if inst.charged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn") end end),
            TimeEvent(27*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/hoof") end),
            TimeEvent(44*FRAMES, function(inst) if inst.charged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn") end end),
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/hoof") end),
            TimeEvent(71*FRAMES, function(inst) if inst.charged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn") end end),
            TimeEvent(79*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/hoof") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "bleet",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("bleet")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                if inst.charged then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
                end
            end),
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/bleet")
            end)
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "discharge",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("trans")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_electric")
        end,

        timeline =
        {
            TimeEvent(18*FRAMES, function(inst)
                inst.AnimState:Hide("fx")
                inst.AnimState:SetBuild("lightning_goat_build")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "shocked",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shock")
            inst.AnimState:PushAnimation("shock_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_electric")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/shocked_bleet")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end)
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
            if inst.charged then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
            end
        end),
        TimeEvent(9*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/headbutt")
        end),
        TimeEvent(12*FRAMES, function(inst)
            if inst.charged then
                inst.components.combat:DoAttack(inst.sg.statemem.target, nil, nil, "electric")
            else
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end
        end),
        TimeEvent(15*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
    },
    deathtimeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/death")
        end),
        TimeEvent(3*FRAMES, function(inst)
            if inst.charged then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
            end
        end),
        TimeEvent(34*FRAMES, function(inst)
            inst.Light:Enable(false)
            inst.AnimState:ClearBloomEffectHandle()
        end),
    },
})
CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states,
{
    startsleeptimeline =
    {
        TimeEvent(9*FRAMES, function(inst)
            if inst.charged then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/jacobshorn")
            end
        end),
    },
    sleeptimeline =
    {
        TimeEvent(41*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/lightninggoat/sleep")
        end),
    },
})

return StateGraph("lightninggoat", states, events, "idle")
