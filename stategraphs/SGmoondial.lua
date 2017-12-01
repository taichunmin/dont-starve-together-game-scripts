require("stategraphs/commonstates")

local actionhandlers =
{
}

local events =
{
    EventHandler("worked", function(inst) inst.sg:GoToState("hit") end),
    EventHandler("onbuilt", function(inst) inst.sg:GoToState("placed") end),
}

local function CalcPhaseAnimName(anim)
	return anim.."_"..TheWorld.state.moonphase
end

local function CalcTransitionAnimName()
	if TheWorld.state.moonphase == "full" then
		return "wax_to_full"
	elseif TheWorld.state.moonphase == "new" then
		return "wane_to_new"
	end

	return (TheWorld.state.iswaxingmoon and "wax" or "wane").."_to_"..TheWorld.state.moonphase
end

local states =
{
	State{
		name = "idle",

        onenter = function(inst)
			inst.AnimState:PlayAnimation(CalcPhaseAnimName("idle"), true)

			if TheWorld.state.moonphase == "full" then
				inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/full_LP", "loop")
			else
				inst.SoundEmitter:KillSound("loop")
			end
        end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
    },
    
	State{
		name = "next",

        onenter = function(inst)
			inst.AnimState:PlayAnimation(CalcTransitionAnimName())
        end,

		timeline=
        {
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/fill") end),
        },

        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end),
        },
    },
    
	State{
		name = "hit",

        onenter = function(inst)
            inst.AnimState:PlayAnimation(CalcPhaseAnimName("hit"))
        end,

		timeline=
        {
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement") end),
        },

        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end),
        },
    },

	State{
		name = "placed",

        onenter = function(inst)
            inst.AnimState:PlayAnimation(CalcPhaseAnimName("place"))
        end,

		timeline=
        {
			TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/craft") end),
			TimeEvent(7*FRAMES, function(inst) if TheWorld.state.moonphase ~= "new" then inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement") end end),
        },

        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end),
        },
    },
    
}

return StateGraph("moondial", states, events, "idle", actionhandlers)

