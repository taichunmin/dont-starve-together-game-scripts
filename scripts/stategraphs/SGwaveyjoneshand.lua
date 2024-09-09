require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.RAISE_SAIL, "short_action"),
    ActionHandler(ACTIONS.LOWER_ANCHOR, "short_action"),
    ActionHandler(ACTIONS.RAISE_ANCHOR, "loop_action_anchor"),
    ActionHandler(ACTIONS.UNPATCH, "short_action"),
    ActionHandler(ACTIONS.ROTATE_BOAT_COUNTERCLOCKWISE, "short_action"),
    ActionHandler(ACTIONS.ROTATE_BOAT_CLOCKWISE, "short_action"),
    ActionHandler(ACTIONS.EXTINGUISH, "short_action"),
}

local events =
{

    EventHandler("locomote", function(inst, data)
        inst:rotatearthand()
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and wants_to_move and not is_moving then
                inst.sg:GoToState("premoving")
            end
        end
    end),
    EventHandler("trapped", function(inst, data)
        inst.sg:GoToState("trapped")
    end),
}

local function passtate(inst,state)
    if inst.handart then inst.handart:PushEvent(state) end
end

local states=
{

    State{

        name = "in",
        tags = {"busy"},
        onenter = function(inst, playanim)
            passtate(inst,"STATE_IN")

            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            passtate(inst,"STATE_IDLE")

            inst.Physics:Stop()
        end,
    },

    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            passtate(inst,"STATE_PREMOVING")
            inst.components.locomotor:WalkForward()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            passtate(inst,"STATE_MOVING")

            inst.components.locomotor:WalkForward()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "short_action",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            passtate(inst,"STATE_SHORT_ACTION")
        end,

        events=
        {
            EventHandler("performbufferedaction", function(inst)
                inst:PerformBufferedAction()
                inst:ClearWaveyJonesTarget()
                if inst.arm and inst.arm.jones then
                    inst.arm.jones:PushEvent("laugh")
                end
            end),
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "loop_action_anchor",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            passtate(inst,"STATE_LOOP_ACTION_ANCHOR")

            inst.components.locomotor:Stop()

            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
					inst.bufferedaction.target:PushEvent("startlongaction", inst)
                end
            end
            if not inst:PerformBufferedAction() then
                inst.sg:GoToState("idle")
            else
                if inst.arm and inst.arm.jones then
                    inst.arm.jones:PushEvent("laugh")
                end
            end
        end,

        onexit = function(inst)
            inst:ClearWaveyJonesTarget()
        end,

        events=
        {
             EventHandler("stopraisinganchor", function(inst)

                inst.sg:GoToState("loop_action_anchor_pst")
            end),
        },
    },

    State{
        name = "loop_action_anchor_pst",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            passtate(inst,"STATE_LOOP_ACTION_ANCHOR_PST")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "trapped",
        tags = {"busy","trapped"},

        onenter = function(inst)
            passtate(inst,"STATE_TRAPPED")
            inst.Physics:Stop()
            inst:ClearBufferedAction()
            inst.components.timer:StartTimer("trappedtimer", 1)
        end,

        onexit = function(inst)
            inst.components.timer:StopTimer("trappedtimer")
        end,

        events=
        {
            EventHandler("released", function(inst) inst.sg:GoToState("trapped_pst") end),
            EventHandler("timerdone", function(inst,data)
                if data.name == "trappedtimer" then
                    inst.sg:GoToState("scared_relocate")
                end
            end),
        },
    },

    State{
        name = "trapped_pst",
        tags = {"busy","trapped"},

        onenter = function(inst)
            passtate(inst,"STATE_TRAPPED_PST")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "scared_relocate",
        tags = {"busy","trapped"},

        onenter = function(inst)
            passtate(inst,"STATE_SCARED_RELOCATE")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}


return StateGraph("waveyjoneshand", states, events, "idle", actionhandlers)