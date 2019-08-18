require("stategraphs/commonstates")


local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.EAT, 
		function(inst, action)
			return action.target.components.oceanfishinghook ~= nil and "hooked" or "eat"
		end),
}

local events=
{
    CommonHandlers.OnLocomote(true, true),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },
    
    State{
        name = "arrive",
        tags = {"busy", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.AnimState:PlayAnimation("arrive")
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
	        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
    },
    
    State{
        name = "leave",
        tags = {"busy"},
        onenter = function(inst)
            --inst.AnimState:PlayAnimation("leave")
            inst.AnimState:PlayAnimation("idle_loop")
			inst.persists = false
        end,

        events =
        {
	        EventHandler("animqueueover", function(inst) inst:Remove() end),
		},
    },

    State{
        name = "eat",
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("breach")
			inst.Transform:SetTwoFaced()
        end,
        
        events =
		{
	        EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.components.timer:StopTimer("bite_cooldown")
					inst.components.timer:StartTimer("bite_cooldown", 0.5 + math.random()*1)
					if math.random() < 0.2 then
						inst:PerformBufferedAction()
					else
						inst:ClearBufferedAction()
					end
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.Transform:SetSixFaced()
		end,
    },

    State{
        name = "hooked",
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("struggle_loop")
			inst:PerformBufferedAction()
        end,
        
        events =
		{
	        EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst.components.oceanfishinghookable:GetHook() ~= nil then
						inst.sg:GoToState("hooked")
					else
						inst.sg:GoToState("idle")
					end
				end
			end),
		},
    },    
}

CommonStates.AddWalkStates(states)
CommonStates.AddRunStates(states)

return StateGraph("sgoceanfish", states, events, "idle", actionhandlers)
