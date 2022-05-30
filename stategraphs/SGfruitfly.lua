require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.INTERACT_WITH, "plant_dance"),
	ActionHandler(ACTIONS.ATTACKPLANT,
		function(inst)
			return inst:HasTag("lordfruitfly") and "plant_attack" or "plant_attack_minion"
		end),
	ActionHandler(ACTIONS.PLANTWEED,
		function(inst)
			return inst:HasTag("lordfruitfly") and "plant_attack" or "plant_attack_minion"
		end),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false,true),
}

local function StartFlap(inst)
	if not inst.SoundEmitter:PlayingSound("flap") then
		inst.SoundEmitter:PlaySound(inst.sounds.flap, "flap")
	end
end

local function StopFlap(inst)
	if inst.SoundEmitter:PlayingSound("flap") then
		inst.SoundEmitter:KillSound("flap")
	end
end

local function SpawnFruitFly(inst)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil then
        local num = inst:NumFruitFliesToSpawn()
        local pt = inst:GetPosition()
		for i = 1, num do
			local x, z = pt.x + GetRandomWithVariance(0, 10), pt.z + GetRandomWithVariance(0, 10)
			local fruitfly = SpawnPrefab("fruitfly")
			fruitfly.Transform:SetPosition(x, 20, z)
			fruitfly.sg:GoToState("land")
            if fruitfly ~= nil and fruitfly.components.follower ~= nil then
                fruitfly.components.follower:SetLeader(inst)
            end
        end
    end
end

local states=
{
	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle")
			StartFlap(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if math.random() < 0.05 then
					inst.sg:GoToState("bored")
				else
					inst.sg:GoToState("idle")
				end
			end)
		},
    },
	State{
		name = "bored",
		tags = {"idle"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("spin")
			StartFlap(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
    },
    State{
        name = "plant_dance", --friendlyfruitfly only
        tags = {"busy"},

        onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_dance_pre", false)
			inst.AnimState:PushAnimation("plant_dance_loop", true)
			StartFlap(inst)
		end,

		timeline =
		{
			TimeEvent(77 * FRAMES, function(inst)
                inst:PerformBufferedAction()
				inst.sg:GoToState("plant_dance_pst")
			end),
		},
    },
    State{
        name = "plant_dance_pst", --friendlyfruitfly only
        tags = {"busy"},

        onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_dance_pst", false)
			StartFlap(inst)
        end,

		events =
		{
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
				inst.sg:GoToState("idle")
			end)
		},
    },
    State{
        name = "plant_attack", --fruitfly only
        tags = {"busy"},

        onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_attack_pre", false)
			inst.AnimState:PushAnimation("plant_attack_loop", true)
			StartFlap(inst)
        end,

		timeline =
		{
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.spin) end),
			TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.plant_attack) end),
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.plant_attack) end),
			TimeEvent(37 * FRAMES, function(inst)
				inst:PerformBufferedAction()
				inst.hascausedhavoc = true
				inst.sg:GoToState("plant_attack_pst")
			end),
		},

	},
    State{
        name = "plant_attack_minion", --fruitfly minion only
        tags = {"busy"},

        onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_attack_pre", false)
			inst.AnimState:PushAnimation("plant_attack_loop", true)
			StartFlap(inst)
        end,

		timeline =
		{
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.spin) end),
			TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.plant_attack) end),
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.plant_attack) end),
			TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.spin) end),
			TimeEvent(42*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.plant_attack) end),
			TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.plant_attack) end),
			TimeEvent(63*FRAMES, function(inst)
				inst:PerformBufferedAction()
				inst.hascausedhavoc = true
				inst.sg:GoToState("plant_attack_pst")
			end),
		},

	},
    State{
        name = "plant_attack_pst", --fruitfly only
        tags = {"busy"},

        onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_attack_pst", false)
			StartFlap(inst)
        end,

		events =
		{
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end)
		},
	},
    State{
        name = "land",
        tags = { "flight", "busy" },

        onenter = function(inst)
			inst.AnimState:PlayAnimation("idle", true)
			local sx, sy, sz = inst.Transform:GetScale()
            inst.Physics:SetMotorVelOverride(0, -12/sy, 0)
			StartFlap(inst)
        end,

        onupdate = function(inst)
			local sx, sy, sz = inst.Transform:GetScale()
            inst.Physics:SetMotorVelOverride(0, -12/sy, 0)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 0.2 or inst:IsAsleep() then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 0 then
                inst.Transform:SetPosition(x, 0, z)
            end
            inst.Physics:ClearMotorVelOverride()
        end,
	},
	State{
		name = "buzz",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_dance_pre", false)
			inst.AnimState:PushAnimation("plant_dance_loop", false)
			inst.AnimState:PushAnimation("plant_dance_pst", false)
			StartFlap(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.buzz)
        end,

        timeline =
        {
            TimeEvent(32 * FRAMES, function(inst)
                SpawnFruitFly(inst)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },

	},
	State{
		name = "taunt",
		tags = { "busy" },

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("plant_dance_pre", false)
			inst.AnimState:PushAnimation("plant_dance_loop", false)
			inst.AnimState:PushAnimation("plant_dance_pst", false)
            inst.SoundEmitter:PlaySound(inst.sounds.buzz)
		end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
	}
}

--CommonStates.AddSimpleActionState(states, "action", "idle", FRAMES*5, {"busy"})
CommonStates.AddCombatStates(states,
{
	hittimeline =
	{
		TimeEvent(0, function(inst) StartFlap(inst) end),
		TimeEvent(0, function(inst)	inst.SoundEmitter:PlaySound(inst.sounds.hurt) end)
    },
	attacktimeline =
    {
		TimeEvent(0, function(inst) StartFlap(inst) end),
        TimeEvent(8*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
		TimeEvent(7*FRAMES, function(inst)	inst.SoundEmitter:PlaySound(inst.sounds.attack) end), --fruitfly only.
    },
	deathtimeline =
	{
		TimeEvent(0, function(inst) StartFlap(inst) end),
		TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.die) end),
		TimeEvent(10*FRAMES, function(inst) StopFlap(inst) end),
        TimeEvent(10*FRAMES, LandFlyingCreature),
		TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.die_ground) end)
	},
})
CommonStates.AddWalkStates(states,
{
	starttimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
	walktimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
	endtimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
})
CommonStates.AddSleepStates(states,
{
	starttimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
	sleeptimeline =
		{
			TimeEvent(0*FRAMES, function(inst) StopFlap(inst) end),
			TimeEvent(35*FRAMES, function(inst) StartFlap(inst) end),
			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end)
		},
	endtimeline = {TimeEvent(0, function(inst) StartFlap(inst) end)},
},
{
    onsleep = LandFlyingCreature,
    onwake = RaiseFlyingCreature,
})
CommonStates.AddFrozenStates(states, LandFlyingCreature, RaiseFlyingCreature)

return StateGraph("fruitfly", states, events, "taunt", actionhandlers)