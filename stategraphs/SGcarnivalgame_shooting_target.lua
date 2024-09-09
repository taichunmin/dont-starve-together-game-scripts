local events =
{
    EventHandler("carnivalgame_turnon", function(inst)
		inst.sg:GoToState("turn_on")
    end),

    EventHandler("carnivalgame_target_startround", function(inst, data)
		if not inst._shouldturnoff then
			inst.sg.mem.is_active = data.isactivated
            inst.sg.mem.isfriendlytarget = data.isfriendlytarget

			if data.isactivated then
				inst.sg:GoToState(data.isfriendlytarget and "friendly_activate" or "enemy_activate")
			end
		end
    end),

    EventHandler("carnivalgame_endofround", function(inst)
		if not inst._shouldturnoff and inst.sg.mem.is_active then
            inst.sg.mem.is_active = false
			inst.sg:GoToState(inst.sg.mem.isfriendlytarget and "friendly_activate_pst" or "enemy_activate_pst")
		end
    end),

    EventHandler("carnivalgame_shooting_target_hit", function(inst, data)
		if not inst._shouldturnoff and inst.sg.mem.is_active then
            inst.sg.mem.is_active = false
            inst.sg:GoToState(inst.sg.mem.isfriendlytarget and "friendly_activate_hit" or "enemy_activate_hit_pst")
		end
    end),

    EventHandler("carnivalgame_turnoff", function(inst)
		if inst.sg:HasStateTag("on") then
			if inst.sg.mem.is_active then
				inst.sg:GoToState(inst.sg.mem.isfriendlytarget and "friendly_activate_pst" or "enemy_activate_pst")
			else
				inst.sg:GoToState("turn_off")
			end
		end
    end),

}

local states =
{
    State{
        name = "place",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("place")
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
        end,
    },

    State{
        name = "turn_on",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("turn_on")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState(inst._shouldturnoff and "turn_off" or "idle_on") end),
        },
    },

    State{
        name = "idle_on",
        tags = {"on"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("on")
        end,
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
        name = "friendly_activate",
        tags = {"on"},
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
                inst.AnimState:PlayAnimation("reveal_good_pre")
                inst.AnimState:PushAnimation("reveal_good_loop", true)
				inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/on")
			end
        end,

    },

    State{
        name = "friendly_activate_hit",
        tags = {"on"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("reveal_good_hit")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/hit_bird")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },

    State{
        name = "friendly_activate_pst",
        tags = {"on"},
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
                inst.AnimState:PlayAnimation("reveal_good_pst")
				inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_good_pst")
			end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },

    State{
        name = "enemy_activate",
        tags = {"on"},
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
                inst.AnimState:PlayAnimation("reveal_bad_pre")
                inst.AnimState:PushAnimation("reveal_bad_loop", true)
				inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_good")
			end
        end,
    },

    State{
        name = "enemy_activate_hit_pst",
        tags = {"on"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("reveal_bad_hit")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_shooting/hit_bug")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },

    State{
        name = "enemy_activate_pst",
        tags = {"on"},
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
                inst.AnimState:PlayAnimation("reveal_bad_pst")
				inst.SoundEmitter:PlaySound("summerevent/carnival_games/memory/card/reveal_good_pst")
			end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        },
    },
}

return StateGraph("carnivalgame_shooting_target", states, events, "idle_off")
