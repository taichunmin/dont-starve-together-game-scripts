
local events = {}

local states =
{
    State{
        name = "idle",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_empty", true)
        end,
    },

    State{
        name = "hit",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit_loaded", true)
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end)
        }        
    },

    State{
        name = "place_weight",
        tags = { },
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation(("place_"..data.slot) or 1)
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end)
        }
    },    

    State{
        name = "workout_pst",
        
        onenter = function(inst,data)
            if data and data >= 1 then
                inst.AnimState:PlayAnimation("active_pst_full")
            else
                inst.AnimState:PlayAnimation("active_pst")
            end
            inst.SoundEmitter:KillSound("workout_LP")
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        }
    },
}

return StateGraph("mighty_gym", states, events, "idle")