require("stategraphs/commonstates")

local actionhandlers =
{
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
	--[[EventHandler("floater_startfloating", function(inst)
		inst.sg:GoToState("idle")
    end),]]
	EventHandler("floater_stopfloating", function(inst)
		inst.sg:GoToState("idle")
    end),
    EventHandler("onturnoff", function(inst)
        inst.sg:GoToState("idle")
    end),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(
                TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition()) and "idle"
                or "idle_ground",
                true)
        end,
    },
}

CommonStates.AddWalkStates(states)

return StateGraph("sgminiboatlantern", states, events, "idle", actionhandlers)
