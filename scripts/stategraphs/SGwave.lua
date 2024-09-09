require("stategraphs/commonstates")

local events = {} --apparently stategraphs need this table.

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local states=
{

	State{
		name = "rise",
		tags = {"rising"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("appear")
		end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.waveactive = true
            end),
        },

		events =
		{
			EventHandler("animover", go_to_idle)
		},
	},

    State{
        name = "instant_rise",
		tags = {"rising"},

		onenter = function(inst)
            inst.waveactive = true
			inst.AnimState:PlayAnimation("appear")
			inst.AnimState:SetFrame(10)
		end,

		events =
		{
			EventHandler("animover", go_to_idle)
		},
    },

	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.waveactive = true
			inst.AnimState:PlayAnimation("idle", false)
			inst.sg:SetTimeout(inst.idle_time or 5)
		end,

		ontimeout = function(inst)
            inst.sg:GoToState("lower")
		end,
	},

	State{
		name = "lower",
		tags = {"lowering"},

		onenter = function(inst)
			inst.waveactive = true
			inst.AnimState:Resume()
			inst.AnimState:PlayAnimation("disappear")
		end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst)
                inst.waveactive = false
            end),
        },

		events =
		{
			EventHandler("animover", function(inst)
				inst:Remove()
			end)
		},
	},
}

return StateGraph("wave", states, events, "rise")
