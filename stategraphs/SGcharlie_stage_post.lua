require("stategraphs/commonstates")

local events =
{
    EventHandler("ontalk", function(inst, data)
        if not inst.sg:HasStateTag("talking") then
            inst.sg:GoToState("narrate", data)
        end
    end),
}

local states =
{
    State{
        name = "idle_closed",
        tags = { "idle", "closed" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation((math.random() < 0.01 and "idle_closed2") or "idle_closed")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed")
            end),
        }, 
    },

    State{
        name = "open",
        tags = { "busy", "open" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("curtain_open")

            inst.SoundEmitter:PlaySound("stageplay_set/stage/curtains_open")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
            end),
        },
    },

    State{
        name = "idle_open",
        tags = { "idle", "open" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_open")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
            end),
        },
    },

    State{
        name = "narrator_on",
        tags = {"busy","open","on"},

        onenter= function(inst)
            inst.AnimState:PlayAnimation("narrator_on")

            inst.SoundEmitter:PlaySound("stageplay_set/statue_mask/arm_movement")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open_on")
            end),
        }, 
    },

    State{
        name = "idle_open_on",
        tags = { "idle", "open", "on" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_open_on")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open_on")
            end),
        },
    },

    State{
        name = "narrate",
        tags = {"busy","open", "on", "talking"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("narrate", true)
            inst.sg:SetTimeout(1.5 + math.random() * 0.5)

            local sound_name = (data.sgparam == "upbeat" and "stageplay_set/statue_mask/speak_upbeat")
                    or (data.sgparam == "mysterious" and "stageplay_set/statue_mask/speak_mysterious")
                    or "stageplay_set/statue_mask/speak_neutral"
            inst.SoundEmitter:PlaySound(sound_name)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle_open_on")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle_open_on")
            end),
        },
    },

    State{
        name = "stinger",
        tags = {"busy","open","on"},

        onenter= function(inst, sound)
            if sound == nil then
                inst.sg:GoToState("idle_open_on")
                return
            end

            inst.AnimState:PlayAnimation("stinger")
            inst.AnimState:PushAnimation("stinger", false)
            inst.AnimState:PushAnimation("stinger", false)

            inst.SoundEmitter:PlaySound(sound)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle_open_on")
            end),
        }, 
    },

    State{
        name = "narrator_off",
        tags = {"busy","open"},

        onenter= function(inst)
            inst.AnimState:PlayAnimation("narrator_off")

            inst.SoundEmitter:PlaySound("stageplay_set/statue_mask/arm_movement")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
            end),
        }, 
    },

    State{
        name = "close",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("close")

            inst.SoundEmitter:PlaySound("stageplay_set/stage/curtains_close")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed")
            end),
        },
    },
}

return StateGraph("charlie_stage_post", states, events, "idle_open")
