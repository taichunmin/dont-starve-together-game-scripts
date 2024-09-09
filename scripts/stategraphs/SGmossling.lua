require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.EAT, "eat_loop"),
	ActionHandler(ACTIONS.PICKUP, "action"),
	ActionHandler(ACTIONS.HARVEST, "action"),
	ActionHandler(ACTIONS.PICK, "action"),
	ActionHandler(ACTIONS.SUMMONGUARDIAN, "meep"),
	ActionHandler(ACTIONS.GOHOME, "flyaway"),
}

local events=
{
	CommonHandlers.OnSleep(),
	CommonHandlers.OnFreeze(),
	EventHandler("doattack", function(inst)
		if inst.components.health and not inst.components.health:IsDead()
			and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
			if not inst.mother_dead then
				inst.sg:GoToState("attack")
			else
				inst.sg:GoToState("spin_pre")
			end
		end
	end),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),

	EventHandler("flyaway", function(inst)
		if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("flyaway")
		end
	end),

	EventHandler("locomote", function(inst)
		local is_moving = inst.sg:HasStateTag("moving")
		local is_idling = inst.sg:HasStateTag("idle")
		local is_spinning = inst.sg:HasStateTag("spinning")
		local should_move = inst.components.locomotor:WantsToMoveForward()

		if (is_moving and not should_move) or (is_spinning and not should_move) then
			if is_spinning then
				--Stop Moving
				inst.sg.statemem.move = false
			else
				inst.sg:GoToState("walk_stop")
			end
		elseif (is_idling or is_moving or is_spinning) and should_move then
			if is_spinning then
				--Start Moving
				inst.sg.statemem.move = true
			elseif not is_moving then
				inst.sg:GoToState("walk_start")
			end
		end
	end)
}

local function ShouldStopSpin(inst)
	local pos = inst:GetPosition()

	local nearby_player = FindClosestPlayerInRange(pos.x, pos.y, pos.z, 7.5, true)
	local time_out = inst.numSpins >= 2

	return not nearby_player or time_out
end

local function LightningStrike(inst)
	local rad = math.random(0,3)
	local angle = math.random() * TWOPI
	local offset = Vector3(rad * math.cos(angle), 0, -rad * math.sin(angle))

	local pos = inst:GetPosition() + offset

	TheWorld:PushEvent("ms_sendlightningstrike", pos)
	TheWorld:PushEvent("ms_forceprecipitation", true)
end

local states=
{

	State{

		name = "idle",
		tags = {"idle", "canrotate"},
		onenter = function(inst, playanim)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				if inst.components.combat.target then
					if math.random() < 0.25 then
						inst.sg:GoToState("taunt")
						return
					end
				end
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "action",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("action")
			inst.AnimState:PushAnimation("eat", false)
			inst.sg:SetTimeout(math.random()*2+1)
		end,

		timeline=
		{
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/eat") end),

			TimeEvent(10*FRAMES, function(inst)
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("busy")
                if inst.brain ~= nil then
                    inst.brain:ForceUpdate()
                end
				inst.sg:AddStateTag("wantstoeat")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("eat_pst") end)
		},

		ontimeout = function(inst)
			inst.sg:GoToState("eat_pst")
		end,
	},

	State{
		name = "eat_loop",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PushAnimation("eat", false)
		end,

		events =
		{
			EventHandler("animqueueover", function(inst)
				inst:PerformBufferedAction()
				inst.sg:GoToState("eat_pst")
			end)
		},

		timeline =
		{
			TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/chew") end),
		},
	},

	State{
		name = "eat_pst",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("eat_pst")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/strain")
		end,

		timeline = {},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "taunt",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("taunt_pre")
			inst.AnimState:PushAnimation("taunt")
			inst.AnimState:PushAnimation("taunt_pst", false)
		end,

		timeline=
		{
			TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/taunt") end),
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
		},

		events=
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
		},
	},


	State{
		name = "meep",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("meep")
		end,

		timeline=
		{
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(10*FRAMES, function(inst) inst:PerformBufferedAction() end),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/honk") end),
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
			TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap") end),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "flyaway",
		tags = {"flight", "busy"},
		onenter = function(inst)
			inst.Physics:Stop()
			inst.DynamicShadow:Enable(false)
			inst.AnimState:PlayAnimation("takeoff_pre_vertical")
			inst.sg.statemem.strainSound = 20*FRAMES
			inst.sg.statemem.flapSound = 9*FRAMES
		end,

		onupdate = function(inst, dt)
			inst.sg.statemem.strainSound = inst.sg.statemem.strainSound - dt
			if inst.sg.statemem.strainSound <= 0 then
				inst.sg.statemem.strainSound = 70*FRAMES
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/strain")
			end

			inst.sg.statemem.flapSound = inst.sg.statemem.flapSound - dt
			if inst.sg.statemem.flapSound <= 0 then
				inst.sg.statemem.flapSound = 3*FRAMES
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/flap")
			end
		end,

		timeline =
		{
			TimeEvent(9*FRAMES, function(inst)
				inst.AnimState:PushAnimation("takeoff_vertical", true)
				inst.Physics:SetMotorVel(-2 + math.random()*4,3+math.random()*2,-2 + math.random()*4)
			end),
			TimeEvent(10, function(inst) inst:Remove() end)
		}
	},

	State{
		name = "hatch",
		tags = {"busy"},

		onenter = function(inst)
			local angle = math.random()*TWOPI
			local speed = GetRandomWithVariance(3, 2)
			inst.Physics:SetMotorVel(speed*math.cos(angle), 0, speed*math.sin(angle))
			inst.AnimState:PlayAnimation("hatch")
		end,

		timeline =
		{
			TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/hatch") end),
			TimeEvent(20*FRAMES, function(inst) inst.Physics:SetMotorVel(0,0,0) end),
			TimeEvent(47*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/pop") end)
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},


	State{
		name = "spin_pre",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("spin_pre")
			inst.components.burnable:Extinguish()
			inst.numSpins = 0
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("spin_loop") end),
		},

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/attack") end),
		},
	},

	State{
		name = "spin_loop",
		tags = {"busy", "spinning"},

		onenter = function(inst)
			inst.DynamicShadow:SetSize(2.5,1.25)
			inst.components.sizetweener:StartTween(1.55, 2)
			inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "mossling_yule_angry_build" or "mossling_angry_build")

			inst.AnimState:PlayAnimation("spin_loop")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin", "spinLoop")

			local fx = SpawnPrefab("mossling_spin_fx")
			fx.entity:SetParent(inst.entity)
			fx.Transform:SetPosition(0,0.1,0)
			inst.components.burnable:Extinguish()
		end,

		onupdate = function(inst)
			if inst.sg.statemem.move then
				inst.components.locomotor:WalkForward()
			else
				inst.components.locomotor:StopMoving()
			end
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("spinLoop")
			inst.components.locomotor:StopMoving()
		end,

		timeline=
		{
			TimeEvent(5*FRAMES, function(inst)
				if math.random() < 0.1 then
					LightningStrike(inst)
				end
			end),
			TimeEvent(0*FRAMES, function(inst) inst.components.combat:DoAttack() end),
			TimeEvent(35*FRAMES, function(inst) inst.components.combat:DoAttack() end),
			TimeEvent(70*FRAMES, function(inst) inst.components.combat:DoAttack() end),
		},

		events=
		{
			EventHandler("animover",
			function(inst)
				inst.numSpins = inst.numSpins + 1
				if ShouldStopSpin(inst) then
					inst.sg:GoToState("spin_pst")
				else
					inst.sg:GoToState("spin_loop")
				end
			end),
		},
	},

	State{
		name = "spin_pst",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("spin_pst")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("spin_pst_loop") end),
		},
	},

	State{
		name = "spin_pst_loop",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("spin_pst_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/dizzy", "dizzy")
			inst.sg:SetTimeout(math.random() + 4.5)
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("dizzy")
		end,

		timeline=
		{
		},

		ontimeout = function(inst)
			inst.sg:GoToState("spin_pst_loop_pst")
		end,
	},

	State{
		name = "spin_pst_loop_pst",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("spin_pst_loop_pst")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},
}

CommonStates.AddFrozenStates(states)
CommonStates.AddWalkStates(states,
{
	walktimeline =
	{
		TimeEvent(FRAMES, function(inst) PlayFootstep(inst) end),
		TimeEvent(5*FRAMES, function(inst) PlayFootstep(inst) end),
		TimeEvent(10*FRAMES, function(inst) PlayFootstep(inst) end),
	}
})
CommonStates.AddCombatStates(states,
{
	attacktimeline =
	{
		TimeEvent(20*FRAMES, function(inst)
			inst.components.combat:DoAttack(inst.sg.statemem.target, nil, nil, "electric")
		end),
		TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/attack") end),
		TimeEvent(22*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
	},

	deathtimeline =
	{
		TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/death") end)
	},
})
CommonStates.AddSleepStates(states,
{
	starttimeline =
	{
		TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/yawn") end)
	},
	sleeptimeline =
	{
		TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/sleep") end)
	},
	waketimeline =
	{
		TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/hatch") end)
	}
})

return StateGraph("mossling", states, events, "idle", actionhandlers)

