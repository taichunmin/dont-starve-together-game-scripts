local events =
{
	EventHandler("worked", function(inst)
		if not (inst.sg:HasStateTag("busy") or inst:HasTag("burnt")) then
			inst.sg:GoToState("hit")
		end
	end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            local direction = inst.sg.mem.direction or 0
            local anim =
                direction > 0 and "idle_clockwise" or
                direction < 0 and "idle_counterclockwise" or
                "idle"
            inst.AnimState:PlayAnimation(anim, true)
        end,
    },

    State{
        name = "place",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("monkeyisland/boatrotator/place")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.mem.direction and inst.sg.mem.direction ~= 0 then
                    inst.sg:GoToState("on")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            local direction = inst.sg.mem.direction or 0
            local anim =
                direction > 0 and "hit_clockwise" or
                direction < 0 and "hit_counterclockwise" or
                "hit"
            inst.AnimState:PlayAnimation(anim)
            inst.SoundEmitter:PlaySound("monkeyisland/boatrotator/hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "on",
        tags = { "busy" },

        onenter = function(inst)
            local direction = inst.sg.mem.direction or 0
            local anim =
                direction > 0 and "clockwise_on" or
                "counterclockwise_on"
            inst.AnimState:PlayAnimation(anim)
            inst.SoundEmitter:PlaySound("monkeyisland/boatrotator/on")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "off",
        tags = { "busy" },

        onenter = function(inst)
            local direction = inst.sg.mem.direction or 0
            local anim =
                direction > 0 and "clockwise_off" or
                "counterclockwise_off"
            inst.AnimState:PlayAnimation(anim)
            inst.SoundEmitter:PlaySound("monkeyisland/boatrotator/off")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.mem.direction = 0
                inst.sg:GoToState("idle")
            end),
        },
    },
}

return StateGraph("boatrotator", states, events, "idle")
