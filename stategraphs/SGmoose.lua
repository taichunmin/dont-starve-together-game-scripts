require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.EAT, "eat_loop"),
	ActionHandler(ACTIONS.PICKUP, "action"),
	ActionHandler(ACTIONS.HARVEST, "action"),
	ActionHandler(ACTIONS.PICK, "action"),
	ActionHandler(ACTIONS.LAYEGG, "layegg2"),
	ActionHandler(ACTIONS.GOHOME, "flyaway"),
}

local function onattackfn(inst)
	if inst.components.health and not inst.components.health:IsDead()
	   and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
		if inst.CanDisarm then
			inst.sg:GoToState("disarm")
		else
			inst.sg:GoToState("attack")
		end
	end
end

local events=
{
	EventHandler("locomote",
	function(inst)
		if (not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving")) then return end

		if not inst.components.locomotor:WantsToMoveForward() then
			if not inst.sg:HasStateTag("idle") then
				inst.sg:GoToState("idle", {softstop = true})
			end
		else
			if not inst.sg:HasStateTag("hopping") then
				inst.sg:GoToState("hop")
			end
		end
	end),

	CommonHandlers.OnSleep(),
	CommonHandlers.OnFreeze(),
	EventHandler("doattack", onattackfn),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),

	EventHandler("flyaway", function(inst)
		if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("flyaway")
		end
	end),
}

local function DisarmTarget(inst, target)
	local item = nil
	if target and target.components.inventory then
		item = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	end
	if item and item.Physics then
		target.components.inventory:DropItem(item)
		local x, y, z = item:GetPosition():Get()
		y = .1
		item.Physics:Teleport(x,y,z)
		local hp = target:GetPosition()
		local pt = inst:GetPosition()
		local vel = (hp - pt):GetNormalized()
		local speed = 5 + (math.random() * 2)
		local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
		item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
	end
	inst.CanDisarm = false
end

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)
end

local function DeathCollapseShake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, 40)
end

local states =
{
	State{
		name = "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst, data)
			inst.Physics:Stop()
			if data and data.softstop then
				inst.AnimState:PushAnimation("idle", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
			inst.sg:SetTimeout(math.random()*10+2)
		end,

		timeline = {},

		ontimeout= function(inst)
			inst.sg:GoToState((math.random() < 0.5 and "preen" or "twitch"))
		end,
	},

	State{
		name = "twitch",
		tags = {"idle"},

		onenter = function(inst, playanim)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_2")
		end,

		events =
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end)
		}
	},

	State{
		name = "preen",
		tags = {"idle"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle_3")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},

		timeline =
		{
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/preen") end),
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/preen_feathers") end),
		},
	},

	State{
		name = "hop",
		tags = {"moving", "canrotate", "hopping"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("hop")
			PlayFootstep(inst)
			inst.components.locomotor:WalkForward()
			inst.sg:SetTimeout(math.random()+.5)
		end,

		onupdate= function(inst)
			if not inst.components.locomotor:WantsToMoveForward() then
				inst.sg:GoToState("idle")
			end
		end,

		timeline=
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/attack") end),
			TimeEvent(9*FRAMES, function(inst)
				inst.Physics:Stop()
				ShakeIfClose(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land")
			end),
		},

		ontimeout= function(inst)
			inst.sg:GoToState("hop")
		end,
	},

	State{
		name = "action",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("action")
			inst.AnimState:PushAnimation("eat", false)
		end,

		timeline=
		{
			TimeEvent(FRAMES*1, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/attack") end),
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
	},

	State{
		name = "eat_loop",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PushAnimation("eat", true)
			inst.sg:SetTimeout(math.random()*2+1)
		end,

		timeline = {},

		ontimeout = function(inst)
			inst:PerformBufferedAction()
			inst.sg:GoToState("eat_pst")
		end,

	},

	State{
		name = "eat_pst",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("eat_pst")
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
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/taunt") end),
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(27*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
		},

		events=
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "glide",
		tags = {"flight", "busy"},

		onenter= function(inst)
			inst.AnimState:PlayAnimation("glide", true)
			inst.Physics:SetMotorVelOverride(0,-11,0)
			inst.flapSound = inst:DoPeriodicTask(6*FRAMES,
				function(inst)
					inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap")
				end)
		end,

		onupdate= function(inst)
			inst.Physics:SetMotorVelOverride(0,-15,0)
			local pt = Point(inst.Transform:GetWorldPosition())
			if pt.y < 2 or inst:IsAsleep() then
				inst.Physics:ClearMotorVelOverride()
				pt.y = 0
				inst.Physics:Stop()
				inst.Physics:Teleport(pt.x,pt.y,pt.z)
				inst.AnimState:PlayAnimation("land")
				inst.DynamicShadow:Enable(true)
				inst.sg:GoToState("idle", {softstop = true})
				ShakeIfClose(inst)
			end
		end,

		onexit = function(inst)
			if inst.flapSound then
				inst.flapSound:Cancel()
				inst.flapSound = nil
			end
			if inst:GetPosition().y > 0 then
				local pos = inst:GetPosition()
				pos.y = 0
				inst.Transform:SetPosition(pos:Get())
			end
			inst.components.knownlocations:RememberLocation("landpoint", inst:GetPosition())
		end,
	},

	State{
		name = "flyaway",
		tags = {"flight", "busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.DynamicShadow:Enable(false)
			inst.AnimState:PlayAnimation("takeoff_pre_vertical")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap")
			inst.sg.statemem.flapSound = 9*FRAMES
		end,

		onupdate = function(inst, dt)
			inst.sg.statemem.flapSound = inst.sg.statemem.flapSound - dt
			if inst.sg.statemem.flapSound <= 0 then
				inst.sg.statemem.flapSound = 6*FRAMES
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap")
			end
		end,

		timeline =
		{
			TimeEvent(9*FRAMES, function(inst)
				inst.AnimState:PushAnimation("takeoff_vertical", true)
				inst.Physics:SetMotorVel(math.random()*4,7+math.random()*2,math.random()*4)
			end),
			TimeEvent(10, function(inst) inst:Remove() end)
		}
	},

	State{
		name = "disarm",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("honk")
		end,

		timeline =
		{
			TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(11*FRAMES, function(inst)
				PlayFootstep(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/swhoosh")
			end),
			TimeEvent(12*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/honk")
				if inst.components.combat.target and inst.components.combat.target.ShakeCamera then
					inst.components.combat.target:ShakeCamera(CAMERASHAKE.FULL, 0.75, 0.01, 1.5, 40)
				end
			end),
			TimeEvent(15*FRAMES, function(inst) DisarmTarget(inst, inst.components.combat.target) end),
			TimeEvent(29*FRAMES, function(inst) PlayFootstep(inst) end),
		},

		events=
		{
			EventHandler("animqueueover", function(inst)
				inst.sg:GoToState("idle")
			end ),
		},

	},

	State{
		name = "layegg2",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("honk")
			inst.AnimState:PushAnimation("idle", false)
		end,

		timeline =
		{
			TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/honk") end),

			TimeEvent(15*FRAMES, function(inst) TheWorld:PushEvent("ms_forceprecipitation", true) end),

			TimeEvent(50*FRAMES,
				function(inst)
					local egg = SpawnPrefab("mooseegg")
					local offset = FindWalkableOffset(inst:GetPosition(), math.random() * 2 * math.pi, 4, 12) or Vector3(0,0,0)
					local pt = offset + inst:GetPosition()
					egg.Transform:SetPosition(pt:Get())
					TheWorld:PushEvent("ms_sendlightningstrike", pt)
					inst.components.entitytracker:TrackEntity("egg", egg)
					egg.components.entitytracker:TrackEntity("mother", inst)
					egg:InitEgg()
				end)
		},

		events=
		{
			EventHandler("animqueueover", function(inst)
				inst.sg:GoToState("idle")
			end ),
		},

	},

--[[ This doesn't seem to be used animore...
	State{
		name = "layegg",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("layegg")
			inst.AnimState:PushAnimation("nesting_idle")
			inst.sg:SetTimeout(math.random(15,20))
		end,

		timeline =
		{
			TimeEvent(27.33*FRAMES, function(inst)
				inst.sg.statemem.eggPosition = inst:GetPosition()
				local right = TheCamera:GetRightVec()
				local angle = math.atan2(right.z, right.x)
				local sp = 11
				inst.Physics:SetMotorVelOverride(sp*math.cos(angle), 0, sp*math.sin(angle))
			end),

			TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),

			TimeEvent(30*FRAMES, function(inst)
				inst.sg.statemem.mooseEgg = SpawnPrefab("mooseegg")
				inst.components.entitytracker:TrackEntity("egg", inst.sg.statemem.mooseEgg)
				inst.sg.statemem.mooseEgg.components.entitytracker:TrackEntity("mother", inst)
				if inst.sg.statemem.mooseEgg then
					inst.sg.statemem.mooseEgg.Transform:SetPosition(inst.sg.statemem.eggPosition:Get())
				end
			end),

			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/flap") end),

			TimeEvent(37.33*FRAMES, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),

			TimeEvent(38*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/lay")
			end),

			TimeEvent(73*FRAMES, function(inst)
				if inst.sg.statemem.mooseEgg then
					inst.sg.statemem.mooseEgg:InitEgg()
				end
			end),

			TimeEvent(110*FRAMES, function(inst) inst.egglaid = true end),
		},

		onupdate= function(inst)
			if inst.components.playerprox:IsPlayerClose() and inst.egglaid then
				inst.sg:GoToState("layegg_pst")
			end
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("layegg_pst")
		end,
	},

	State{
		name = "layegg_pst",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("layegg_pst")
		end,

		timeline = {},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},
]]
}

CommonStates.AddCombatStates(states,
{
	attacktimeline =
	{
		TimeEvent(0*FRAMES, function(inst) PlayFootstep(inst) end),
		TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/swhoosh") end),
		TimeEvent(19*FRAMES, function(inst) PlayFootstep(inst) end),
		TimeEvent(20*FRAMES, function(inst)
			if not inst.components.timer:TimerExists("DisarmCooldown") then
				inst.components.timer:StartTimer("DisarmCooldown", 10)
			end
			inst.components.combat:DoAttack(inst.sg.statemem.target)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/attack")
		end),
		TimeEvent(25*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
	},

	deathtimeline =
	{
		TimeEvent(0*FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/death")
		end),

		TimeEvent(20*FRAMES, DeathCollapseShake),
	},
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states,
{
	sleeptimeline =
	{
		TimeEvent(22*FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/sleep")
		end),
	},
})

return StateGraph("moose", states, events, "idle", actionhandlers)
