require("stategraphs/commonstates")

local action_handlers =
{
    ActionHandler(ACTIONS.PICKUP, function(inst, action)
        inst.sg:GoToState("pickup", action.target)
    end),

    ActionHandler(ACTIONS.JUMPIN, "hint"),
}

local events =
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("death", function(inst)
        inst.sg:GoToState("dissipate")
    end),
}

local function get_idle_anim(inst)
    return (inst:HasTag("questing") and "idle") or "idle_sad"
end

local function return_to_idle(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("idle")
    end
end

local function play_howl(inst)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/howl")
end

local function play_joy(inst)
    inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/small_ghost/joy")
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate", "canslide" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation(get_idle_anim(inst), true)
        end,
    },

    State{
        name = "idle_to_sad",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sad")
        end,

        events =
        {
            EventHandler("animover", return_to_idle)
        },
    },

    State{
        name = "appear",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState((inst:HasTag("questing") and "idle") or "idle_to_sad")
            end),
        },

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(STRINGS.SMALLGHOST_TALK[math.random(#STRINGS.SMALLGHOST_TALK)])
                end
                play_howl(inst)
            end),
        },
    },

    State{
        name = "disappear",
        tags = { "busy", "nointerrupt" },

        onenter = function(inst, animoverfn)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.sg.statemem.aof = animoverfn
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, play_howl),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.sg.statemem.aof ~= nil then
                    inst.sg.statemem.aof(inst)
                end
            end),
        },
    },

    State{
        name = "dissipate",
        tags = { "busy", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dissipate")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, play_howl),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PushEvent("detachchild")
                    inst:Remove()
                end
            end)
        },
    },

    State{
        name = "pickup",
        tags = {"busy"},

        onenter = function(inst, pickup_target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("small_happy")

            inst.sg.statemem.pu_t = pickup_target
        end,

        timeline =
        {
            TimeEvent(3*FRAMES, play_joy),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PerformBufferedAction()

                    if inst.sg.statemem.pu_t ~= nil and inst.sg.statemem.pu_t:IsValid() then
                        inst:PickupToy(inst.sg.statemem.pu_t)
                    end

                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "quest_begin",
        tags = { "busy", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("small_happy")
        end,

        timeline =
        {
            TimeEvent(3*FRAMES, play_joy),
        },


        events =
        {
            EventHandler("animover", return_to_idle),
        },
    },

    State{
        name = "quest_abandoned",
        tags = { "busy", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sad")
        end,

        events =
        {
            EventHandler("animover", return_to_idle)
        },
    },

    State{
        name = "quest_finished",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("quest_completed")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, play_howl),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:PushEvent("detachchild")
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "hint",
        tags = {"busy"},

        onenter = function(inst, dont_talk)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("small_happy")

            if not dont_talk and inst._playerlink ~= nil and inst._playerlink.components.talker ~= nil then
                inst._playerlink.components.talker:Say(GetString(inst._playerlink, "ANNOUNCE_GHOST_HINT"))
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                if math.random() < 0.4 then
                    play_joy(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.is_hinting then
                        inst.sg:GoToState("hint", true)
                    else
                        inst:ClearBufferedAction()
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },
}

local HOWL_CHANCE = 0.5
CommonStates.AddSimpleWalkStates(
    states,
    get_idle_anim,
    {
        starttimeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                if math.random() < HOWL_CHANCE then
                    play_howl(inst)
                end
            end),
        },
    }
)
CommonStates.AddSimpleRunStates( states, get_idle_anim )

return StateGraph("ghost", states, events, "appear", action_handlers)
