local events =
{
    CommonHandlers.OnLocomote(true, true),

    EventHandler("carnivalgame_herding_arivedhome", function(inst)
		if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("arived_home")
		end
    end),

    EventHandler("carnivalgame_turnoff", function(inst)
		if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("turn_off")
		end
    end),
}

local states =
{

    State{
        name = "idle",
		tags = {"idle"},
        onenter = function(inst)
			if inst._shouldturnoff then
				inst.sg:GoToState("turn_off")
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
        end,
    },

    State{
        name = "launched",
		tags = {"busy", "jumping"},
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("run_loop", true)
            inst:ClearBufferedAction()
        end,

		onupdate = function(inst)
			local x, y, z = inst.Transform:GetWorldPosition()
			if y < 0.1 then
				inst.Physics:Stop()
				inst.sg:GoToState("idle")
			end
		end,

		onexit = function(inst)
			inst:OnLaunchLanded()
		end,
    },

    State{
        name = "arived_home",
		tags = {"busy", "death"},
        onenter = function(inst)
			inst.components.locomotor:StopMoving()
			RemovePhysicsColliders(inst)

            inst.AnimState:PlayAnimation("win")

			inst:PushEvent("carnivalgame_herding_gothome")
            inst.SoundEmitter:KillSound("active_loop")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/win") end),
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/talk") end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/talk") end),
            TimeEvent(28 * FRAMES, function(inst) SpawnPrefab("carnival_confetti_fx").Transform:SetPosition(inst.Transform:GetWorldPosition()) end),
		},

        events =
        {
            EventHandler("animover", function(inst)  ErodeAway(inst) end),
        },
    },

    State{
        name = "turn_off",
		tags = {"busy", "death"},
        onenter = function(inst)
			if inst:IsValid() then -- when a chick turns off over the water, they will be invalid
				inst.components.locomotor:StopMoving()
				RemovePhysicsColliders(inst)

				inst.SoundEmitter:KillSound("active_loop")
				inst.AnimState:PlayAnimation("lose")
			end
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/talk") end),
		},

        events =
        {
            EventHandler("animover", function(inst) ErodeAway(inst, 0.5 + math.random() * 0.5) end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    runtimeline =
    {
    },
},
{
	startwalk = "run_pre",
	walk = "run_loop",
	stopwalk = "run_pst",
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
    },
},
{
	startrun = "run_pre2",
})

return StateGraph("carnivalgame_herding_chick", states, events, "idle")
