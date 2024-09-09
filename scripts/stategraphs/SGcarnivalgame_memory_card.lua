local events =
{
    EventHandler("carnivalgame_turnon", function(inst)
		inst.sg:GoToState("turn_on")
    end),
    EventHandler("carnivalgame_memory_cardstartround", function(inst, data)
		if not inst._shouldturnoff then
			inst.sg.mem.isgood = data.isgood
			inst.sg:GoToState(data.isgood and "hint_good" or "hint_bad")
		end
    end),
    EventHandler("carnivalgame_memory_revealcard", function(inst, data)
		if not inst._shouldturnoff then
			inst.sg:GoToState(inst.sg.mem.isgood and "reveal_good" or "reveal_bad")
		end
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

			if inst.components.inspectable == nil then
				inst:AddComponent("inspectable")
			end
        end,
    },

    State{
        name = "turn_on",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("turn_on")
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
	           inst.AnimState:PlayAnimation("on", true)
			end
        end,

        events =
        {
            EventHandler("carnivalgame_turnoff", function(inst) inst.sg:GoToState("turn_off") end),
        },
    },

	 State{
        name = "hint_good",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hint_good")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/hint_good")
        end,

        timeline =
        {
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },

	 State{
        name = "hint_bad",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hint_bad")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/hint_bad")
        end,

        timeline =
        {
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },


	State{
        name = "reveal_good",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("reveal_good_pre")
            inst.AnimState:PushAnimation("reveal_good_loop", true)
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_good")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst:PushEvent("carnivalgame_memory_cardrevealed") end),
        },

        events =
        {
            EventHandler("carnivalgame_endofround", function(inst) inst.sg:GoToState("reveal_good_pst") end),
            EventHandler("carnivalgame_turnoff", function(inst) inst.sg:GoToState("reveal_good_pst") end),
        },

        onexit = function(inst)
        end,
    },

    State{
        name = "reveal_good_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("reveal_good_pst")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_good_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },

	State{
        name = "reveal_bad",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("reveal_bad_pre")
            inst.AnimState:PushAnimation("reveal_bad_loop", true)
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_bad")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst:PushEvent("carnivalgame_memory_cardrevealed") end),
        },

        events =
        {
            EventHandler("carnivalgame_endofround", function(inst) inst.sg:GoToState("reveal_bad_pst") end),
            EventHandler("carnivalgame_turnoff", function(inst) inst.sg:GoToState("reveal_bad_pst") end),
        },

        onexit = function(inst)
        end,
    },

	State{
        name = "reveal_bad_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("reveal_bad_pst")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_bad_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
            --EventHandler("animover", function(inst) inst.sg:GoToState("turn_off") end),
        },
    },
}

return StateGraph("carnivalgame_feedchicks_nest", states, events, "idle_off")
