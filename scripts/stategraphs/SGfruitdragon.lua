require("stategraphs/commonstates")

local ATTACK_FIRE_CANT_TAGS = {"fruitdragon", "INLIMBO"}
local ATTACK_FIRE_ONEOF_TAGS = {"_health", "canlight"}

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
}

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(true, true),

    EventHandler("doattack", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead()
			and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then

			if data.target:IsValid() and data.target:HasTag("fruitdragon") then
				inst.sg:GoToState("challenge_attack_pre")
			else
				inst.sg:GoToState((inst._is_ripe and not inst.components.timer:TimerExists("fire_cd")) and "attack_fire" or "attack")
			end
		end
	end),

	EventHandler("attacked", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead()
			and (not inst.sg:HasStateTag("busy") or
				inst.sg:HasStateTag("caninterrupt") or
				inst.sg:HasStateTag("frozen")) then
			inst.sg:GoToState("hit")
		end
	end),

	EventHandler("wake_up_to_challenge", function(inst)
		inst.sg:GoToState("hit")
	end),


	EventHandler("lostfruitdragonchallenge", function(inst)
		inst.sg:GoToState("challenge_lose")
	end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound(inst.sounds.idle)
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "do_ripen",
        tags = {"busy", "waking"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_ripe_pst")
        end,

        --[[timeline=
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.do_ripen) end),
        },]]

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

		onexit = function(inst)
			if not inst._is_ripe then
				inst:MakeRipe()
			end
		end,
    },

    State{
        name = "do_unripen",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_ripe_pre")
			if inst._is_ripe then
				inst:MakeUnripe()
			end
        end,

        timeline=
        {
            TimeEvent(36*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.do_unripen)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

	State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack")
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = target
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
			TimeEvent(22*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(28*FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
		},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "attack_fire",
        tags = { "attack", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("attack_fire")
            inst.components.combat:StartAttack()
        end,

        timeline =
		{
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack_fire) end),
			TimeEvent(16*FRAMES, function(inst)
				inst.Light:Enable(true)
				inst.DynamicShadow:Enable(false)
			end),
			TimeEvent(20*FRAMES, function(inst)
                inst.components.timer:StopTimer("fire_cd")
                inst.components.timer:StartTimer("fire_cd", TUNING.FRUITDRAGON.FIREATTACK_COOLDOWN)

				local x, y, z = inst.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, TUNING.FRUITDRAGON.FIREATTACK_HIT_RANGE + 6, nil, ATTACK_FIRE_CANT_TAGS, ATTACK_FIRE_ONEOF_TAGS)
				for _, ent in ipairs(ents) do
					if inst:IsNear(ent, ent:GetPhysicsRadius(0) + TUNING.FRUITDRAGON.FIREATTACK_HIT_RANGE) then
						if ent.components.health ~= nil and not ent.components.health:IsDead() then
							ent.components.health:DoFireDamage(TUNING.FRUITDRAGON.FIREATTACK_DAMAGE, inst, true)
						end
						if ent.components.burnable and ent.components.fueled == nil then
							ent.components.burnable:Ignite(true, inst)
						end
					end
				end
			end),

			TimeEvent(37*FRAMES, function(inst)
				inst.Light:Enable(false)
				inst.DynamicShadow:Enable(true)
				inst.sg:RemoveStateTag("busy")
			end),
		},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

		onexit = function(inst)
			inst.Light:Enable(false)
			inst.DynamicShadow:Enable(true)
		end
    },

	State{
        name = "challenge_attack_pre",
        tags = {"busy", "canrotate", "caninterrupt"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("challenge_pre")
			inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.challenge_pre)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("challenge_attack", 1 + math.random(3)) end ),
        },
    },

    State{
        name = "challenge_attack",
        tags = {"busy", "canrotate", "caninterrupt"},

        onenter = function(inst, num_loops)
			inst.sg.statemem.num_loops = (num_loops or 1) - 1
            inst.AnimState:PlayAnimation("challenge_loop")
			inst.components.locomotor:StopMoving()
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.challenge)
				if inst.sg.statemem.num_loops <= 0 then
					inst.components.combat:DoAttack(nil, nil, nil, nil, 0)
				end
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
				if not inst.components.combat:HasTarget() then
					inst.sg:GoToState("challenge_win")
				elseif inst.sg.statemem.num_loops <= 0 then
					inst.sg:GoToState("challenge_attack_pst")
				else
					inst.sg:GoToState("challenge_attack", inst.sg.statemem.num_loops)
				end
			end),
        },
    },

    State{
        name = "challenge_attack_pst",
        tags = {"busy", "canrotate", "caninterrupt"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("challenge_pst")
			inst.components.locomotor:StopMoving()
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.challenge_pst) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "challenge_win",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("challenge_win")
			inst.components.locomotor:StopMoving()
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.challenge_win)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "challenge_lose",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
			inst.components.locomotor:StopMoving()
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.challenge_lose)
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

}
CommonStates.AddHitState(states,
{
    TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.onhit) end),
})

CommonStates.AddDeathState(states,
{
    TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.death) end),
    TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/grass_gekko/body_fall") end),
})

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
    },
    walktimeline =
    {
        TimeEvent(0,            PlayFootstep),
        TimeEvent(4*FRAMES,     PlayFootstep),
        TimeEvent(12*FRAMES,    PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0,            PlayFootstep),
    },
}
, nil, nil, true)

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(6*FRAMES,     PlayFootstep),
        TimeEvent(10*FRAMES,    PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0,            PlayFootstep),
    },
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stretch) end)
    },

    sleeptimeline =
    {
        TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep_loop) end),
        TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep_loop) end),
    },

    waketimeline =
    {
        TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stretch) end),
    },
},
{
	onsleep = function(inst)
		if inst._unripen_pending then
            inst.sg:GoToState("do_unripen")
		end
	end,

	onwake = function(inst)
		if inst._ripen_pending then
            inst.sg:GoToState("do_ripen")
		end
	end,
})

CommonStates.AddFrozenStates(states)

return StateGraph("fruit_dragon", states, events, "idle", actionhandlers)
