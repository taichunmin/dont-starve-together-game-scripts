
local events = {}

local states =
{
    State{
        name = "idle_off",
        tags = {"idle"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_off", true)
            inst.SoundEmitter:KillSound("fireloop")
        end,
    },

    State{
        name = "place",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("yotd2024/startingpillar/place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end)
        },
    },

    State{
        name = "hit",
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end)
        },
    },

    State{
        name = "on",
        tags = { "on" },
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("on")

            inst.SoundEmitter:PlaySound("yotd2024/startingpillar/ding_start")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fire_lp", "fireloop") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_on")
            end)
        },
    },

    State{
        name = "idle_on",
        tags = { "on","idle" },
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("idle_on",true)
            if not inst.SoundEmitter:PlayingSound("fireloop") then
                inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fire_lp", "fireloop")
            end
        end,
    },

    State{
        name = "win",
        tags = { "on" },
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("win")
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotd2024/startingpillar/start_fireworks") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:winOver()
            end)
        },
    },

    State{
        name = "prize",
        tags = { "on" },
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("prize")
            inst.SoundEmitter:PlaySound("yotd2024/startingpillar/kit_toss")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:prizeOver()
            end)
        },
    },

    State{
        name = "checkpoint_throw",
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("checkpoint_toss")
            inst.SoundEmitter:PlaySound("yotd2024/startingpillar/kit_toss")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end)
        },
    },

    State{
        name = "reset",
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("reset")
            inst.SoundEmitter:PlaySound("yotd2024/startingpillar/reset")
            inst.SoundEmitter:KillSound("fireloop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_off")
            end)
        },
    },

    State{
        name = "fuse_off",
        tags = { "on" },
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("fuse_off")
            if data and data.fuse_off_frame then
                inst.AnimState:SetFrame(inst.fuse_off_frame)
            end

            inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fuse_lp","sparkloop")
        end,

        onexit = function(inst,data)
            inst.SoundEmitter:KillSound("sparkloop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:fuseoffOver()
            end)
        },
    },

    State{
        name = "fuse_on",
        tags = { "on" },
        onenter = function(inst,data)
           inst.AnimState:PlayAnimation("fuse_on")
           inst.SoundEmitter:PlaySound("yotd2024/startingpillar/fuse")
        end,

        timeline =
        {
            TimeEvent(67*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotd2024/startingpillar/light1") end),
            TimeEvent(142*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotd2024/startingpillar/light2") end),
            TimeEvent(215*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotd2024/startingpillar/light3") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:fuseonOver()
            end),
        },
    },
}

return StateGraph("boatrace_start", states, events, "idle_off")