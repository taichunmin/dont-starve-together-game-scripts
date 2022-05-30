require("stategraphs/commonstates")

local events=
{
}

local states=
{
    State{
        name = "place",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 0.5)
        end,

		ontimeout = function(inst)
			inst.sg:GoToState("drilling")
		end,

        events=
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("drilling")
				end
			end),
        },
    },

	State{
        name = "drilling",
        onenter = function(inst, drill_time)
            inst.AnimState:PlayAnimation("drill", true)

			inst.sg:SetTimeout(drill_time or TUNING.FARM_PLOW_DRILL_TIME)
	        inst.SoundEmitter:PlaySound("grotto/common/archive_resonator/idle_LP", "idle_loop")
        end,

		ontimeout = function(inst)
			inst:OnFinishedDrilling()
		end,

        timeline =
        {
            --TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/pop") end)
        },
    },
}

return StateGraph("farmplow", states, events, "place")
