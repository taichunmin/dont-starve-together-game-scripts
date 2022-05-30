local events =
{
--	EventHandler("conteststarted", function(inst, data) inst.sg:GoToState("start") end),
    EventHandler("trader_arrives", function(inst, data) inst.sg:GoToState("arrive") end),
    EventHandler("trader_leaves", function(inst, data) inst.sg:GoToState("leave") end),
	EventHandler("contestdisabled", function(inst, data) inst.sg:GoToState("idle_closed_ready_pst") end),
    EventHandler("contestenabled", function(inst, data)
        if not inst.sg:HasStateTag("open") and not inst.sg:HasStateTag("busy") then
            if TheWorld.components.yotb_stagemanager and TheWorld.components.yotb_stagemanager:IsContestEnabled() then
                if not inst.sg:HasStateTag("ready") then
                    inst.sg:GoToState("idle_closed_ready_reset")
                end
            else
                inst.sg:GoToState("idle_closed_ready_pre")
            end
        end
    end),
    EventHandler("ontalk", function(inst, data) if not inst.sg:HasStateTag("busy") then inst.sg:GoToState("talk") end end),
    EventHandler("onflourishend", function(inst, data) inst.sg:GoToState("flourish_end") end),
    EventHandler("onflourishstart", function(inst, data) inst.sg:GoToState("flourish_start") end),
    EventHandler("yotb_throwprizes", function(inst, data) inst.sg:GoToState("throwprizes") end),

}

local states =
{
    State{
        name="idle_closed",
        tags = {},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("idle_closed",true)
        end,
    },

    State{
        name="hit_closed",
        tags = {},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("hit_closed")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed")
            end),
        },
    },

    State{
        name="hit_ready",
        tags = {"ready"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("hit_closed_ready")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed_ready")
            end),
        },
    },


    State{
        name="idle_closed_ready",
        tags = {"ready"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("idle_closed_ready",true)
            inst.sg:SetTimeout(4 + 2*math.random())
        end,

        ontimeout=function(inst)
            inst.sg:GoToState("idle_closed_ready_sparkle")
        end,
    },

    State{
        name="idle_closed_ready_sparkle",
        tags = {"ready"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("idle_closed_ready_sparkle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed_ready")
            end),
        },
    },

    State{
        name="idle_closed_ready_pre",
        tags = {"ready"},

        onenter = function(inst, data)
        print(debugstack())
            inst.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/idle_closed_ready_pre")
            inst.AnimState:PlayAnimation("idle_closed_ready_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed_ready")
            end),
        },
    },


    State{
        name="arrive",
        tags = {"busy","open"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("host_arriving")
            inst.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/host_arriving")
        end,

        onexit = function(inst,data)
            inst:PushEvent("yotb_advance_queue")

        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
            end),
        },
    },

    State{
        name="idle_open",
        tags = {"open"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("idle_open",true)
        end,
    },


    State{
        name="flourish_start",
        tags = {"busy","open"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("flourish_start")
            inst.components.talker:Say(STRINGS.YOTB_HEY[math.random(1,#STRINGS.YOTB_HEY)],2)
            inst.SoundEmitter:PlaySound("dontstarve/characters/skincollector/talk_LP","talking")
        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("talking")
            end),
        },

        onexit = function(inst,data)
            inst.SoundEmitter:KillSound("talking")
            inst:PushEvent("yotb_advance_queue")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle_open")
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("talk")
            end),
        },
    },

    State{
        name="talk",
        tags = {"open"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("talk_loop")
            inst.SoundEmitter:PlaySound("dontstarve/characters/skincollector/talk_LP","talking")
        end,

        onexit = function(inst,data)
            inst.SoundEmitter:KillSound("talking")
        end,
        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle_open")
                inst:PushEvent("yotb_advance_queue")
            end),
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
                inst:PushEvent("yotb_advance_queue")
            end),
        },
    },

    State{
        name="thinking",
        tags = {"open"},

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/thinking")
            inst.AnimState:PlayAnimation("thinking")
        end,

        onexit = function(inst,data)
            inst:PushEvent("yotb_advance_queue")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
            end),
        },
    },

    State{
        name="flourish_end",
        tags = {"busy","open"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("flourish_end")
        end,

        onexit = function(inst,data)
      --      inst:PushEvent("yotb_advance_queue")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst:PushEvent("yotb_advance_queue")
                inst.sg:GoToState("idle_open")
            end),

            EventHandler("animover", function(inst)
              --  inst.sg:GoToState("idle_open")
                inst.sg:GoToState("talk")
            end),
        },
    },

    State{
        name="idle_closed_ready_pst",
        tags = {"busy", "ready"},

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/idle_closed_ready_pst")
            inst.AnimState:PlayAnimation("idle_closed_ready_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed")
            end),
        },
    },

    State{
        name="idle_closed_ready_reset",
        tags = {"busy", "ready"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("idle_closed_ready_reset")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_closed_ready")
            end),
        },
    },

    State{
        name="throwprizes",
        tags = {"busy","open"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("flourish_start")
        end,

        onexit = function(inst,data)
            inst:PushEvent("yotb_advance_queue")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.components.yotb_stager then
                    inst.components.yotb_stager:Tossprizes()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle_open")
            end),
        },
    },


    State{
        name="leave",
        tags = {"busy","open"},

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/host_leaving")
            inst.AnimState:PlayAnimation("host_leaving")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                print("LEAVE OVER")
                if TheWorld.components.yotb_stagemanager and TheWorld.components.yotb_stagemanager:IsContestEnabled() then
                    print("CONTEST ENABLED")
                    inst.sg:GoToState("idle_closed_ready_reset")
                else
                    print("CONTEST DISABLED")
                    inst.sg:GoToState("idle_closed_ready_pst")
                end
            end),
        },
    },

    State{
        name="place",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if TheWorld.components.yotb_stagemanager and TheWorld.components.yotb_stagemanager:IsContestEnabled() then
                    inst.sg:GoToState("idle_closed_ready_pre")
                else
                    inst.sg:GoToState("idle_closed")
                end
            end),
        },
    },
}

return StateGraph("SGyotb_stage", states, events, "idle_closed")