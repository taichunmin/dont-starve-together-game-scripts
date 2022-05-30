require("stategraphs/commonstates")

local actionhandlers =
{

}

local events =
{

}

local states=
{

    State{

        name = "in",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.AnimState:PlayAnimation("hand_in")
        end,

        onexit = function(inst)
            inst.pauserotation = nil
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                inst.parent:PushEvent("animover")
            end ),
        },
    },

    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("hand_in_loop")
            elseif not inst.AnimState:IsCurrentAnimation("hand_in_loop") then
                inst.AnimState:PlayAnimation("hand_in_loop")
            end

        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                if inst.parent then inst.parent:PushEvent("animover") end
            end ),
        },
    },

    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("crawl_pre")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("moving")
                if inst.parent then inst.parent:PushEvent("animover") end
            end),
        },
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PushAnimation("crawl_loop")
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/move_LP","move")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("move")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                if inst.parent then inst.parent:PushEvent("animover") end
                inst.sg:GoToState("moving")
            end),
        },
    },

    State{
        name = "short_action",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack_pre", false)
            inst.AnimState:PushAnimation("quick_attack", false)
            inst.AnimState:PushAnimation("quick_attack_pst", false)
        end,

        timeline=
        {

            TimeEvent(11*FRAMES, function(inst)  inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/attack") end),
            TimeEvent(18*FRAMES, function(inst) if inst.parent then inst.parent:PushEvent("performbufferedaction") end end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
                if inst.parent then
                    inst.parent:PushEvent("animqueueover")
                    inst.parent:resetposition()
                end
            end),
        },
    },

    State{
        name = "loop_action_anchor",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("continuous_attack", false)
            inst.AnimState:PushAnimation("continuous_attack_loop", true)
        end,
    },

    State{
        name = "loop_action_anchor_pst",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("continuous_attack", false)
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                if inst.parent then
                    inst.parent:PushEvent("animover")
                    inst.parent:resetposition()
                end
            end),
        },
    },

    State{
        name = "scared",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("scared", false)
        end,

        onexit = function(inst)
            if inst:IsValid() then
                inst:Remove()
            end
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },


    State{
        name = "trapped",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("struggle_pre", false)
            inst.AnimState:PlayAnimation("struggle_loop", true)
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/trapped_LP", "trapped")
            inst.SoundEmitter:SetParameter("trapped", "random_def",math.random(0,2))
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("trapped")
        end,
    },

    State{
        name = "trapped_pst",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("struggle_pst", false)
        end,

        events=
        {
            EventHandler("animover", function(inst)
                if inst.parent then inst.parent:PushEvent("animover") end
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "scared_relocate",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("scared", false)
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/wavey_jones/scared_relocate")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
                if inst.parent then
                    inst.parent:PushEvent("animover")
                    inst.parent:resetposition()
                end
            end)
        },
    },
}


return StateGraph("waveyjoneshand_art", states, events, "idle", actionhandlers)
