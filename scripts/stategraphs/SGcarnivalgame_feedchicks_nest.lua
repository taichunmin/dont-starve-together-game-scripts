local events =
{
    EventHandler("carnivalgame_turnon", function(inst)
		inst.sg:GoToState("turn_on")
    end),
    EventHandler("carnivalgame_feedchicks_hungry", function(inst, data)
		if not inst._shouldturnoff then
			inst.sg:GoToState("hungry_pre", data.duration)
		end
    end),
}

local states =
{
    State{
        name = "place",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/place")
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
			inst:RemoveTag("scarytoprey")

			if inst.components.inspectable == nil then
				inst:AddComponent("inspectable")
			end
        end,

		onexit = function(inst)
			inst:AddTag("scarytoprey")
		end,
    },

    State{
        name = "turn_on",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("turn_on")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/turnon")
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
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/turnoff")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_off") end),
        },
    },

    State{
        name = "idle_on",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle", true)
            --inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/idle2")
        end,

        events =
        {
            EventHandler("carnivalgame_turnoff", function(inst) inst.sg:GoToState("turn_off") end),
        },
    },

    State{
        name = "hungry_pre",
        onenter = function(inst, duration)
			inst.sg.statemem.duration = duration
            inst.AnimState:PlayAnimation("hungry_pre")
            --inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/station/hungrypre")
            
        end,

        events =
        {
            EventHandler("animover", function(inst) if inst._shouldturnoff then inst.sg:GoToState("hungry_pst") else inst.sg:GoToState("hungry_loop", inst.sg.statemem.duration) end end),
        },
    },

    State{
        name = "hungry_loop",
        onenter = function(inst, duration)
			inst.components.carnivalgamefeedable.enabled = true
            inst.AnimState:PlayAnimation("hungry_loop", true)
			if duration ~= nil then
				inst.sg:SetTimeout(duration)
			end
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/hungry_LP", "hungry")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("hungry_pst")
        end,

        events =
        {
            EventHandler("carnivalgame_feedchicks_feed", function(inst) inst.sg:GoToState("hungry_fed") end),
            EventHandler("carnivalgame_turnoff", function(inst) inst.sg:GoToState("hungry_pst") end),
        },

		onexit = function(inst)
			inst.components.carnivalgamefeedable.enabled = false
			inst.SoundEmitter:KillSound("hungry") 
		end,
    },

    State{
        name = "hungry_fed",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hungry_fed")
             inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/hungryfed")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState(inst._shouldturnoff and "turn_off" or "idle_on") end),
        },

		onexit = function(inst)
			inst:PushEvent("carnivalgame_feedchicks_available")
		end,
    },

    State{
        name = "hungry_pst",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hungry_pst")
            inst.SoundEmitter:PlaySound("summerevent/carnival_games/feedchicks/bird/hungrypst")
                                         
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState(inst._shouldturnoff and "turn_off" or "idle_on") end),
        },

		onexit = function(inst)
			inst:PushEvent("carnivalgame_feedchicks_available")
		end,
    },
}

return StateGraph("carnivalgame_feedchicks_nest", states, events, "idle_off")
