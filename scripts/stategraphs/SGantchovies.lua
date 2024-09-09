local events =
{

}

local states =
{
    State{
        name = "idle",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("caught_idle_loop", true)
        end,

        events =
        {
            EventHandler("on_caught_in_net", function(inst) inst.sg:GoToState("caught_in_net") end),
        },
    },

    State{
        name = "caught_in_net",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("catch_loop", true)
        end,

        events =
        {
            EventHandler("on_release_from_net", function(inst) inst.sg:GoToState("released_from_net") end),
        },
    },

    State{
        name = "released_from_net",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("caught_idle_pre", false)
            inst.AnimState:PushAnimation("caught_idle_loop", true)
        end,

        events =
        {
            --EventHandler("lowering_anchor", function(inst) inst.sg:GoToState("lowering") end),
        },
    }
}

return StateGraph("antchovies", states, events, "idle")
