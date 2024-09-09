require("stategraphs/commonstates")


local states=
{
    State{
        name = "idle",
        onenter = function(inst)
			if inst._isrunning then
				inst.sg:GoToState("start_running")
			else
				inst.AnimState:PlayAnimation("held_idle", true)
			end
        end,
        events =
        {
            EventHandler("sg_update_running_state", function(inst)
				if inst._isrunning then
                   inst.sg:GoToState("start_running")
                end
            end),
        },
    },

    State{
        name = "start_running",
        onenter = function(inst)
			inst.AnimState:PlayAnimation("held_running_pre")
        end,
        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState(inst._isrunning and "running" or "stop_running")
			end),
        },
    },

    State{
        name = "running",
        onenter = function(inst)
			inst.AnimState:PlayAnimation("held_running_loop")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wes/characters/wes/speedballoon") end),
        },

        events =
        {
            EventHandler("sg_update_running_state", function(inst)
				if not inst._isrunning then
                   inst.sg:GoToState("stop_running")
                end
            end),
             EventHandler("animover", function(inst)
                inst.sg:GoToState("running")
            end),
        },
    },

    State{
        name = "stop_running",
        onenter = function(inst)
			inst.AnimState:PlayAnimation("held_running_pst")
        end,
        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
            EventHandler("sg_update_running_state", function(inst)
				if inst.sg.timeinstate * FRAMES <= 3 then
					inst.sg:GoToState("running")
				end
			end),
        },
    },

    State{
        name = "deflate",
        onenter = function(inst)
			inst.AnimState:PlayAnimation(inst._isrunning and "held_running_deflate" or "deflate", false)
			inst.sg.statemem._wasrunning = inst._isrunning
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wes/characters/wes/deflate_speedballoon") end),
            TimeEvent(13 * FRAMES, function(inst)
				inst:UpdateBalloonSymbol()
				inst.sg.statemem.overridesymboldone = true
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState(inst._isrunning and "running"
								or inst.sg.statemem._wasrunning and "stop_running"
								or "idle")
			end),
        },

        onexit = function(inst)
			if not inst.sg.statemem.overridesymboldone then
				inst:UpdateBalloonSymbol()
			end
        end,
    },
}

return StateGraph("balloonheld", states, {}, "idle")
