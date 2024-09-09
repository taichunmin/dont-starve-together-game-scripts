local events =
{

}

local states =
{
    State{
        name = "retracted",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_idle")
            inst:RemoveTag("plank_extended")
            inst:AddTag("interactable")
        end,

        events =
        {
            EventHandler("start_extending", function(inst) inst.sg:GoToState("extending") end),
        },
    },


    State{
        name = "retracting",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_deactivate")
            inst:RemoveTag("interactable")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/plank/in")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("retracted") end),
        },
    },

    State{
        name = "extended",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_activated_idle")
            inst:AddTag("plank_extended")
            inst:AddTag("interactable")
        end,

        events =
        {
            EventHandler("start_retracting", function(inst) inst.sg:GoToState("retracting") end),
            EventHandler("start_mounting", function(inst) inst.sg:GoToState("mounted") end),
            EventHandler("start_abandoning", function(inst) inst.sg:GoToState("abandon_ship") end),
        },
    },

    State{
        name = "mounted",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_activated_idle")
            inst:RemoveTag("interactable")
        end,

        events =
        {
            EventHandler("stop_mounting", function(inst) inst.sg:GoToState("extended") end),
        },
    },

    State{
        name = "extending",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_activate")
            inst:RemoveTag("interactable")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/plank/out")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("extended") end),
        },
    },

    State{
        name = "abandon_ship",

        onenter = function(inst)
            inst:RemoveTag("interactable")
            inst.sg:SetTimeout(2)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("extended")
        end,
    },
}

return StateGraph("walkingplank", states, events, "retracted")
