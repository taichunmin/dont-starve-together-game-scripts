require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.BREAK, "break_molehill"),
    ActionHandler(ACTIONS.EAT, "eat_start"),
    ActionHandler(ACTIONS.MAKEMOLEHILL, "make_molehill"),
    ActionHandler(ACTIONS.TRAVEL, "startnap"),
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("summon", function(inst)
        if inst.components.health ~= nil and not inst.components.health:IsDead() then
            inst.sg:GoToState("summon_ally")
        end
    end),
}

local function return_to_idle(inst)
    inst.sg:GoToState("idle")
end

local states =
{
     State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.components.locomotor:StopMoving()

            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_sit", true)
            else
                inst.AnimState:PlayAnimation("idle_sit", true)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(math.random() < .15 and "sniff_idle" or "idle")
                end
            end),
        },
    },

    State{
        name = "sniff_idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("idle_smell")

            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/sniff")
        end,

        events=
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "startnap",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("idle_smell")

            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/sniff")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
            end),
        },

        onexit = function(inst)
            inst:ClearBufferedAction()
        end,
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/taunt") end),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "summon_ally",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("ally_call")
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/summon")
            end),
            TimeEvent(28*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/summon")
            end),
            TimeEvent(44*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/summon")
            end),
            TimeEvent(55*FRAMES, function(inst)
                if inst.SummonAlly ~= nil then
                    inst:SummonAlly()
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", return_to_idle),
        },
    },

    State{
        name = "fall",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.Physics:SetActive(false)
            inst.sg.statemem.physics_disabled = true

            inst.DynamicShadow:Enable(false)

            inst.AnimState:PlayAnimation("spawn")
        end,

        events =
        {
            EventHandler("animover", return_to_idle),
        },

        timeline =
        {
            TimeEvent(33 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/bodyfall")
            end),
            TimeEvent(38 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                inst.Physics:SetActive(true)
                inst.sg.statemem.physics_disabled = false
                inst.sg:RemoveStateTag("noattack")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.physics_disabled then
                inst.Physics:SetActive(true)
            end
        end,
    },

    State{
        name = "eat_start",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("eat", false)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/eat")
            end),
            TimeEvent(36 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/eat_swallow")
            end),

        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "make_molehill",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("eat")

            inst.sg:SetTimeout(32*FRAMES)
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/eat")
            end),
            TimeEvent(22 * FRAMES, function(inst)
                inst:PerformBufferedAction()

                inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_playerunstuck")
            end),
        },

        ontimeout = return_to_idle,

        onexit = function(inst)
            inst:ClearBufferedAction()
        end,
    },

    State{
        name = "break_molehill",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("suck_in")
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/suck_up")
        end,

        timeline =
        {
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/walk") end),
            TimeEvent(12 * FRAMES, function(inst)
                -- Even if something happened to our action target,
                -- we still want to stop trying if we get this far.
                inst._nest_needs_cleaning = false

                local ba = inst:GetBufferedAction()
                if ba ~= nil and ba.target ~= nil and ba.target:IsValid() then
                    ba.target:PushEvent("suckedup")
                end
            end),
            TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/bodyfall",nil,.5) end),
            TimeEvent(46*FRAMES, PlayFootstep ),
        },

        events =
        {
            EventHandler("animover", return_to_idle),
        },

        onexit = function(inst)
            inst:ClearBufferedAction()
        end,
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0       , function(inst)
            inst.Physics:Stop()
        end),
    },

    walktimeline =
    {
        TimeEvent(0       , function(inst)
            inst.Physics:Stop()
        end),
        TimeEvent(5*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/walk")
            inst.components.locomotor:WalkForward()
        end ),
        TimeEvent(20*FRAMES, function(inst)
            inst.Physics:Stop()
        end ),
    },

    endtimeline =
    {
        TimeEvent(1*FRAMES, PlayFootstep ),
    },

}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(2*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/yawn")
        end),
            TimeEvent(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/bodyfall")
        end),
    },

    sleeptimeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/sleep")
        end),
    },
})

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/attack")
        end),
        TimeEvent(10*FRAMES, function(inst)
            inst.components.combat:DoAttack()
        end),
        TimeEvent(21*FRAMES, PlayFootstep ),

    },
    hittimeline =
    {
        TimeEvent(0       , function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/hit")
        end),
    },
    deathtimeline =
    {
        TimeEvent(0       , function(inst)
            inst.SoundEmitter:PlaySound("grotto/creatures/mole_bat/death")
        end),
    },
},
{
    attack = "attack",
    hit = "walk_pst",
})

CommonStates.AddFrozenStates(states)

return StateGraph("molebat", states, events, "idle", actionhandlers)
