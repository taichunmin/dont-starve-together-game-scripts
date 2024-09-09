require("stategraphs/commonstates")

local events =
{
    EventHandler("ontalk", function(inst, data)
        if not inst.sg:HasStateTag("talking") then
            inst.sg:GoToState("talkto", data)
        end
    end),

    EventHandler("arrive", function(inst)
        inst.sg:GoToState("arrive")
    end),

    EventHandler("leave", function(inst)
        inst.sg:GoToState("leave")
    end),
}

local EXCITED_PARAM = "excited"
local DISAPPOINTED_PARAM = "disappointed"
local LAUGH_PARAM = "laugh"

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.exit then
                inst.sg:GoToState("leave")
            else
                inst.AnimState:PlayAnimation("idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "idle_arrived",
        tags = { "idle" },

        onenter = function(inst)
            if inst.exit then
                inst.sg:GoToState("leave")
            else
                inst.AnimState:PlayAnimation((math.random() < 0.2 and "idle2_arrived") or "idle_arrived")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_arrived")
            end),
        },
    },

    State{
        name = "arrive",
        tags = {"busy"},

        onenter= function(inst)
            local sound_root = "stageplay_set/heckler_"..(inst.sound_set or "a")
            inst.AnimState:PlayAnimation("arrive")
            inst.SoundEmitter:PlaySound(sound_root.."/arrive")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_arrived")
            end),
        }, 
    },

    State{
        name = "leave",
        tags = {"busy"},

        onenter = function(inst)
            local sound_root = "stageplay_set/heckler_"..(inst.sound_set or "a")   
            inst.AnimState:PlayAnimation("leave")
            inst.SoundEmitter:PlaySound(sound_root.."/leave")

            inst:AddTag("NOCLICK")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.exit = nil
                inst.sg:GoToState("away")
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
        end,
    },

    State{
        name = "away",
        tags = {"busy"},

        onenter = function(inst)
            inst:Hide()
        end,

        onexit = function(inst)
            inst:Show()
        end,
    },

    State{
        name = "talkto",
        tags = {"talking"},

        onenter = function(inst, data)
            local sound_root = "stageplay_set/heckler_"..(inst.sound_set or "a")

            if data.sgparam == EXCITED_PARAM then
                inst.AnimState:PlayAnimation("talk_excited_pre", false)
                inst.AnimState:PushAnimation("talk_excited_loop", false)
                inst.AnimState:PushAnimation("talk_excited_pst", false)

                inst.SoundEmitter:PlaySound(sound_root.."/talk_happy")
            elseif data.sgparam == DISAPPOINTED_PARAM then
                inst.AnimState:PlayAnimation("talk_disappointment_pre", false)
                inst.AnimState:PushAnimation("talk_disappointment_loop", false)
                inst.AnimState:PushAnimation("talk_disappointment_pst", false)

                inst.SoundEmitter:PlaySound(sound_root.."/talk_disappointment")
            elseif data.sgparam == LAUGH_PARAM then
                inst.AnimState:PlayAnimation("talk_happy_pre", false)
                inst.AnimState:PushAnimation("talk_happy_loop", false)
                inst.AnimState:PushAnimation("talk_happy_pst", false)

                inst.SoundEmitter:PlaySound(sound_root.."/laugh")
            else
                inst.AnimState:PlayAnimation("talk_happy_pre", false)
                inst.AnimState:PushAnimation("talk_happy_loop", false)
                inst.AnimState:PushAnimation("talk_happy_pst", false)
            
                inst.SoundEmitter:PlaySound(sound_root.."/talk_happy")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle_arrived")
            end),
        },
    },
}

return StateGraph("charlie_heckler", states, events, "idle")
