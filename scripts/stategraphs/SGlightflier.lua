require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "go_home"),
}

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),

    EventHandler("startled", function(inst)
        inst.sg:GoToState("startled")
    end),
}

local states =
{
    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("walk_loop", true)
            else
                inst.AnimState:PlayAnimation("walk_loop", true)
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{

        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{

        name = "startled",
        tags = { "busy" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{

        name = "go_home",
        tags = { "busy" },

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sleep_pre")
        end,
        timeline =
        {
            TimeEvent(20*FRAMES, function(inst)
                local ba = inst:GetBufferedAction()
                if ba ~= nil and ba.target ~= nil and ba.target:IsValid()
                    and not (ba.target:HasTag("fire") or ba.target:HasTag("burnt")) then

                    inst:PerformBufferedAction()
                else
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end
            end),
        }
    },
}

local walkanims =
{
    startwalk = "walk_pre",
    walk = "walk_loop",
    stopwalk = "walk_pst",
}

CommonStates.AddWalkStates(states, nil, walkanims, true)

local function Land(inst)
    inst:EnableBuzz(false)
    LandFlyingCreature(inst)
end

local function Liftoff(inst)
    inst:EnableBuzz(true)
    RaiseFlyingCreature(inst)
end

CommonStates.AddSleepExStates(states,
{
    -- starttimeline =
    -- {
    --     TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap") end ),
    --     TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap") end ),
    -- },

    -- sleeptimeline =
    -- {
    --     TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/sleep") end),
    -- },
},
{
    onsleeping = Land,
    onexitsleeping = Liftoff,
})

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/hit") end),
    },

    deathtimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
            inst.SoundEmitter:KillSound("loop")
            inst.SoundEmitter:PlaySound("grotto/creatures/light_bug/death")
        end),
    },
},
{
    hit = "hit_2",
})

CommonStates.AddFrozenStates(states, Land, Liftoff)

return StateGraph("lightflier", states, events, "idle", actionhandlers)
