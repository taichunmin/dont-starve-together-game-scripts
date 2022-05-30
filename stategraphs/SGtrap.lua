local events =
{
    EventHandler("ondropped", function(inst)
        if inst.components.trap then
            inst.components.trap:Set()
            inst.sg:GoToState("idle")
        end
    end),
    EventHandler("onpickup", function(inst)
        if inst.components.trap ~= nil then
            inst.components.trap:Disarm()
        end
    end),
    EventHandler("harvesttrap", function(inst, data)
        if inst.components.trap ~= nil then
            inst.components.trap:Disarm(data ~= nil and data.sprung)
        end
    end),
}

local states =
{
    State{
        name = "idle",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("springtrap", function(inst, data)
                if data ~= nil and data.loading then
                    inst.sg:GoToState(inst.components.trap.lootprefabs ~= nil and "full" or "empty")
                elseif inst.entity:IsAwake() then
                    inst.sg:GoToState("sprung")
                else
                    inst.components.trap:DoSpring()
                    inst.sg:GoToState(inst.components.trap.lootprefabs ~= nil and "full" or "empty")
                end
            end),
        },
    },

    State{
        name = "full",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("trap_loop")
            inst.SoundEmitter:PlaySound(inst.sounds.rustle)
        end,

        events =
        {
            EventHandler("harvesttrap", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst) inst.sg:GoToState("full") end),
        },
    },

    State{
        name = "empty",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("side")
        end,

        events =
        {
            EventHandler("harvesttrap", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sprung",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("trap_pre")
			if inst.components.inventoryitem ~= nil then
				inst.components.inventoryitem.canbepickedup = false
			end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.close)
                inst.components.trap:DoSpring()
                inst.sg:GoToState(inst.components.trap.lootprefabs ~= nil and "full" or "empty")
            end),
        },

		onexit = function(inst)
			if inst.components.inventoryitem ~= nil then
				inst.components.inventoryitem.canbepickedup = true
			end
		end,
    },
}

return StateGraph("trap", states, events, "idle")
