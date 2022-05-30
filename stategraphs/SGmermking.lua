require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}


local events=
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("oncreated", function(inst)
        inst.sg:GoToState("oncreated")
    end),

    EventHandler("call_guards", function(inst)
        inst.sg:GoToState("call_guards")
    end),

}

local function DoChewSound(inst)
    inst.sg.statemem.chewsounds = (inst.sg.statemem.chewsounds or 0) - 1
    if inst.sg.statemem.chewsounds <= 0 then
        inst.sg.statemem.chewsounds = nil
        return
    end
    inst.SoundEmitter:PlaySound("dontstarve/beefalo/chew")
end

local states=
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },

    State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre")

            local chews = data and data.chews or 2
            for i = 1, chews do
                inst.AnimState:PushAnimation("eat_loop_1", false) -- "eat_loop_1" does 2 chews per play.
            end

            inst.AnimState:PushAnimation("eat_pst", false)

            inst.sg.statemem.chewsounds = math.max(chews * 2, 4) -- Just in case.
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/eat") end),
            TimeEvent(27*FRAMES, DoChewSound),
            TimeEvent(40*FRAMES, DoChewSound),
            TimeEvent(51*FRAMES, DoChewSound),
            TimeEvent(63*FRAMES, DoChewSound),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "oncreated",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/taunt")
            inst.AnimState:PlayAnimation("transform_pst")
            local fx = SpawnPrefab("merm_king_splash")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/throne/spawn")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "trade",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("give")

        end,

        timeline =
        {
            TimeEvent(22*FRAMES, function(inst) inst:TradeItem() end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/warcry")end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "call_guards",
        tags = {"busy", "calling_guards"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("call")
            inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/warning")
        end,

        timeline =
        {
            -- Staff reaches the peak
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/call") end),
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/warcry") end),
            TimeEvent(30*FRAMES, function(inst) -- Staff hits the ground
                inst.CallGuards(inst)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "refuse",
        tags = {"busy"},

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("refuse")
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/talk") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
}

CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/hit") end),
    },
    deathtimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/merm/king/death") end),
    },
})

return StateGraph("mermking", states, events, "idle", actionhandlers)