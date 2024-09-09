local events =
{
    EventHandler("carnivalgame_turnon", function(inst)
		inst.sg:GoToState("turn_on")
    end),
}

local states =
{
    State{
        name = "place",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/place")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_off") end), -- or idle_off
        },
    },

    State{
        name = "idle_off",
		tags = {"off"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("off")
			inst.components.activatable.inactive = false
        end,
    },

    State{
        name = "turn_on",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("turn_on")
			inst.components.activatable.inactive = true
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/turn_on")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState(inst._shouldturnoff and "turn_off" or "idle_on") end),
        },
    },

    State{
        name = "turn_off",
		tags = {"off"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("turn_off")
			inst.components.activatable.inactive = false
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_off") end),
        },
    },

    State{
        name = "idle_on",
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
	           inst.AnimState:PlayAnimation("idle_on", true)
			end
        end,

        events =
        {
            EventHandler("carnivalgame_turnoff", function(inst) inst.sg:GoToState("turn_off") end),
        },
    },

    State{
        name = "shoot",
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
	           inst.AnimState:PlayAnimation("press", true)
			end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },


}

return StateGraph("carnivalgame_shooting_target", states, events, "idle_off")
