require("stategraphs/commonstates")

-- Lavae doesn't want to change his target to attackers.
local function onattackedfn(inst, data)
	if inst.components.health and not inst.components.health:IsDead() and
	(not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then
		inst.sg:GoToState("hit")
	end
end

local function ondeathfn(inst, data)
	if inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("thawing") then
		inst.sg:GoToState("thaw_break", data)
	else
		inst.sg:GoToState("death", data)
	end
end

local actionhandlers =
{
	ActionHandler(ACTIONS.GOHOME, "gohome"),
	ActionHandler(ACTIONS.EAT, "eat"),
	ActionHandler(ACTIONS.NUZZLE, "nuzzle"),
	ActionHandler(ACTIONS.PICKUP, "pickup")
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    EventHandler("attacked", onattackedfn),
    EventHandler("death", ondeathfn),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
}

local NUM_FX_VARIATIONS = 7
local MAX_RECENT_FX = 4
local MOVE_FX_INTERVAL = 3 * FRAMES
local MIN_FX_SCALE = .5
local MAX_FX_SCALE = 1.3
local FX_RAND_SCALE = math.sqrt(MAX_FX_SCALE - MIN_FX_SCALE)

local function SpawnMoveFx(inst)
    if math.random() < .4 then
        local fx = SpawnPrefab("lavae_move_fx")
        if fx ~= nil then
            if inst.sg.mem.recentfx == nil then
                inst.sg.mem.recentfx = {}
            end
            local recentcount = #inst.sg.mem.recentfx
            local rand = math.random(NUM_FX_VARIATIONS - recentcount)
            if recentcount > 0 then
                while table.contains(inst.sg.mem.recentfx, rand) do
                    rand = rand + 1
                end
                if recentcount >= MAX_RECENT_FX then
                    table.remove(inst.sg.mem.recentfx, 1)
                end
            end
            table.insert(inst.sg.mem.recentfx, rand)
            local basescale = inst.Transform:GetScale()
            local randscale = math.random() * FX_RAND_SCALE
            fx:SetVariation(rand, basescale * (MAX_FX_SCALE - randscale * randscale))
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end
    inst.sg.mem.lastspawnmovefx = GetTime()
end

local states =
{
	State{
		name = "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle", true)
			inst.sg:SetTimeout(math.random(2, 4))
		end,

		ontimeout = function(inst)
			local hunger = inst.components.hunger
			if hunger then
				local play_random = math.random() <= 0.2
				if play_random and hunger:GetPercent() <= 0.25 then
					inst.sg:GoToState("hungry")
				elseif play_random and hunger:GetPercent() >= 0.25 and hunger:GetPercent() < 0.5 then
					inst.sg:GoToState("peckish")
				elseif play_random and hunger:GetPercent() >= 0.75 then
					inst.sg:GoToState(math.random() < 0.5 and "idle_spin" or "idle_hop")
				else
					inst.sg:GoToState("idle")
				end
			else
				inst.sg:GoToState("idle")
			end
		end
	},

	State{
		name = "attack",
		tags = {"attack", "canrotate", "busy", "jumping"},

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)

			inst.components.combat:StartAttack()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk")
			inst.AnimState:PushAnimation("atk_pst", false)
		end,

		onexit = function(inst)
			inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
		end,

		timeline =
		{
			TimeEvent(16*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/jump")
				inst.Physics:SetMotorVelOverride(20,0,0)
			end),
			TimeEvent(21*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/attack")
				inst.components.combat:DoAttack()

			end),
			TimeEvent(23*FRAMES, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.components.locomotor:Stop()
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
				PlayFootstep(inst)
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("taunt") end),
		}
	},

	State{
		name = "gohome",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("taunt")
		end,

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/jump")
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/taunt")
			end),
			TimeEvent(17*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst) inst:PerformBufferedAction() end),
		},
	},

	State{
		name = "taunt",
		tags = {"busy"},

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("taunt")
		end,

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/jump")
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/taunt")
			end),
			TimeEvent(17*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
			end),
		},


		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "hit",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("hit")
			inst.Physics:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		}
	},

	State{
		name = "walk_start",
		tags = {"moving", "canrotate"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("walk_pre")
			inst.components.locomotor:WalkForward()
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
		},
	},

	State{
		name = "walk",
		tags = {"moving", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_loop")

			local movesound = inst:HasTag("smallcreature") and "move_small" or "move"
			inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/"..movesound)
			if TheWorld.state.snowlevel > 0.15 or TheWorld.state.wetness > 15 then
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/sizzle_snow")
			end

            local elapsed = GetTime() - (inst.sg.mem.lastspawnmovefx or 0)
            inst.sg.statemem.task = inst:DoPeriodicTask(MOVE_FX_INTERVAL, SpawnMoveFx, math.max(0, MOVE_FX_INTERVAL - elapsed))
		end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
        },

        onexit = function(inst)
            inst.sg.statemem.task:Cancel()
        end,
    },

	State{
		name = "walk_stop",
		tags = {"canrotate"},

		onenter = function(inst)
			if inst.components.locomotor then
				inst.components.locomotor:StopMoving()
			end
			inst.AnimState:PlayAnimation("walk_pst")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "death",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("death")
			if inst.components.lootdropper then
    			inst.components.lootdropper:SetChanceLootTable(inst.NormalLootTable or 'lavae_lava')
            	inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        		inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/death")
			end
		end,
	},

    State{
        name = "frozen",
        tags = {"busy", "frozen"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
        	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/frozen")
        	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/sizzle_snow")
            -- Tell clients to no longer target this entity because it will die when it thaws.
            inst.replica.health:SetIsDead(true)
            inst:PushEvent("inevitabledeath") -- Death is inescapable.
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)	inst.components.health:Kill() end ),
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),
        },
    },

    State{
        name = "thaw",
        tags = {"busy", "thawing"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
        end,

        events =
        {
            EventHandler("unfreeze", function(inst) inst.components.health:Kill() end),
        },
    },

    State{
        name = "thaw_break",
        tags = {"busy"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("shatter")
            if inst.components.lootdropper then
	    		inst.components.lootdropper:SetChanceLootTable(inst.FrozenLootTable or 'lavae_frozen')
	            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/shatter")
            end
        end,
    },

	State{
		name = "nuzzle",
		tags = {"busy"},

		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("nuzzle")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/nuzzle")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/sizzle")

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
		name = "hungry",
		tags = {"busy"},

		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("hungry")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/beg")

		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "peckish",
		tags = {"busy"},
		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle4")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/beg")

		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "idle_hop",
		tags = {"busy"},

		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle3")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/happy_voice")
		end,

		timeline =
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/jump") end),
			TimeEvent(14*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
				PlayFootstep(inst)
			end),
			TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/jump") end),
			TimeEvent(29*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
				PlayFootstep(inst)
			end),
			TimeEvent(34*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/jump") end),
			TimeEvent(45*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/land")
				PlayFootstep(inst)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "idle_spin",
		tags = {"busy"},
		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle2")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/twirl")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "eat",
		tags = {"busy", "canrotate"},

		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat_loop")
            inst.AnimState:PushAnimation("eat_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/happy_voice")
		end,

		timeline =
		{
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/eat") end),
			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/happy_voice") end),
			TimeEvent(40*FRAMES, function(inst) inst:PerformBufferedAction() end)
		},

		events =
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "pickup",
		tags = {"busy"},
		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("idle2")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/twirl")
		end,

		timeline =
		{
			TimeEvent(20*FRAMES, function(inst) inst:PerformBufferedAction() end),
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

}

CommonStates.AddSleepStates(states,
{
	starttimeline =
	{
		TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/together/lavae/sleep") end),
	},
})

return StateGraph("lavae", states, events, "idle", actionhandlers)
