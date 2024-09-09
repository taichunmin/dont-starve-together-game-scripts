require("stategraphs/commonstates")

local BOO_TIME = 5

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "flyaway"),
    ActionHandler(ACTIONS.ACTIVATE, "activate"),
    ActionHandler(ACTIONS.ADDFUEL, "activate"),
}

local function GoToGameOverState(inst)
	inst.sg:GoToState((inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator._good_ending) and "minigame_over_cheer" or "minigame_over_boo")
end

local function DropRewards(inst)
	if not inst.sg.statemem.rewards_given then
		inst.sg.statemem.rewards_given = true

		local num_rewards = math.random()
		num_rewards = 3 + math.ceil(num_rewards * 5)

		local tickets = SpawnPrefab("carnival_prizeticket")
		tickets.components.stackable:SetStackSize(num_rewards)
		tickets.Transform:SetPosition(inst.Transform:GetWorldPosition())

		local token = SpawnPrefab("carnival_gametoken")
		token.Transform:SetPosition(inst.Transform:GetWorldPosition())

		local giver = inst.sg.statemem.giver
		if giver ~= nil and giver:IsValid() then
			inst:ForceFacePoint(giver.Transform:GetWorldPosition())
		end

		LaunchAt(tickets, inst, giver, 0, 1, 1, 45)
		LaunchAt(token, inst, giver, 0, 1, 1, 45)
	end
end

local function GetEatSnackState(inst)
	return inst.has_snack == "corn_cooked" and "eat_popcorn"
			or inst.has_snack == "carnivalfood_corntea" and "eat_corntea"
			or nil
end

local events=
{
    CommonHandlers.OnLocomote(true, true),

	EventHandler("minigame_spectator_start_outro", function(inst, data)
		if not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("game_over") then
			if data ~= nil and data.no_delay then
				GoToGameOverState(inst)
			else
				inst:DoTaskInTime(math.random() * 0.5, GoToGameOverState)
			end
		end
	end),

    EventHandler("ontalk", function(inst, data)
        if not inst.sg:HasStateTag("talking") and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("game_over") then
			if inst.components.minigame_spectator ~= nil then
				--if not inst.components.locomotor.wantstomoveforward then
				--	inst.sg:GoToState("talkto")
				--else
				    inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/neutral")
				--end
			else
	            inst.sg:GoToState("talkto")
			end
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, short_delay)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)

			if inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator._good_ending ~= nil then
				GoToGameOverState(inst)
			else
				inst.sg:SetTimeout(1 + math.random() * (short_delay and 1 or 3))
			end
        end,

        ontimeout = function(inst)
			inst.sg:SetTimeout(inst.sg.timeinstate + 1 + math.random() * 3)

			local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame()
			minigame = minigame and minigame.components.minigame

			if minigame then
				if minigame:GetIsPlaying() then
					inst.sg:GoToState(minigame:IsExciting() and "minigame_cheer" or "minigame_boo", minigame:TimeSinceLastExcitement())
				elseif inst.components.minigame_spectator._good_ending ~= nil then
					GoToGameOverState(inst)
				end
			else
				local snack = GetEatSnackState(inst)
				if snack ~= nil then
					inst.sg:GoToState(snack)
				elseif inst._watch_campfire ~= nil and inst._watch_campfire:IsValid() and inst:IsNear(inst._watch_campfire, TUNING.CARNIVAL_CROWKID_CAMPFIRE_SIT_DIST) then
					inst.sg:GoToState(math.random() < 0.25 and "campfire_sit2" or "campfire_sit")
					inst:ForceFacePoint(inst._watch_campfire:GetPosition())
				end
			end
        end,
    },

    State{
        name = "eat_popcorn",
        tags = { },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("popcorn")
        end,

        timeline =
        {
            TimeEvent(19 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/crowkid/popcorn_toss") end),
            TimeEvent(58 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/crowkid/popcorn_crunch") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

    },

    State{
        name = "eat_corntea",
        tags = { },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cornyslush")
        end,

        timeline =
        {
            TimeEvent(29 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/crowkid/slurp_cornslush") end),
            TimeEvent(50 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/crowkid/happy_chirp") end),

        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "campfire_sit",
        tags = { },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sit_pre")
            inst.AnimState:PushAnimation("sit_loop", false)
            inst.AnimState:PushAnimation("sit_loop", false)
            inst.AnimState:PushAnimation("sit_loop", false)
            inst.AnimState:PushAnimation("sit_pst", false)
        end,

        timeline =
        {
            --TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "campfire_sit2",
        tags = { },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sit_pre")
            inst.AnimState:PushAnimation("sit_sleep", false)
            inst.AnimState:PushAnimation("sit_pst", false)
        end,

        timeline =
        {
            --TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "glide",
        tags = {"flight", "busy"},
        onenter= function(inst)
            inst.AnimState:PlayAnimation("fly_loop", true)
            inst.DynamicShadow:Enable(false)
            inst.Physics:SetMotorVelOverride(0,-10,0)
        end,

        onupdate= function(inst)
            inst.Physics:SetMotorVelOverride(0,-10,0)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y <= .1 or inst:IsAsleep() then
                inst.Physics:ClearMotorVelOverride()
                inst.Physics:Stop()
                inst.Physics:Teleport(x, 0, z)
                inst.AnimState:PlayAnimation("land")
                inst.DynamicShadow:Enable(true)
                inst.sg:GoToState("idle")
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y > 0 then
                inst.Transform:SetPosition(x, 0, z)
            end
        end,
    },

    State{
        name = "flyaway",
        tags = {"flight", "busy", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.sg:SetTimeout(.1 + math.random() * .2)

            inst.DynamicShadow:Enable(false)

            inst.AnimState:PlayAnimation("takeoff_pre")
            inst.AnimState:PushAnimation("fly_loop")

			inst.persists = false
        end,

        ontimeout = function(inst)
            inst.Physics:SetMotorVel(math.random() * 4 - 2, math.random() * 5 + 10, math.random() * 4 - 2)
        end,

        timeline =
        {
            TimeEvent(2, function(inst)
                inst:Remove()
            end),
        },
    },

    State{
        name = "talkto",
        tags = {"canrotate", "talking"},

        onenter = function(inst)
			inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("talk_" .. tostring(math.random(2)), true)
	        --inst.SoundEmitter:PlaySound("dontstarve/characters/wilson/talk_LP", "talk")
		    inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/neutral")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(GetEatSnackState(inst) or "idle")
            end),
        },

		onexit = function(inst)
	        --inst.SoundEmitter:KillSound("talk")
		end,
    },

    State{
        name = "give_reward",
        tags = {"canrotate", "busy", "talking"},

        onenter = function(inst, giver)
			inst.components.locomotor:Stop()

			if giver ~= nil then
				inst.sg.statemem.giver = giver
				inst:ForceFacePoint(giver.Transform:GetWorldPosition())

				inst.components.talker:Say(STRINGS.CARNIVAL_CROWKID_ACCEPTGIFT[math.random(#STRINGS.CARNIVAL_CROWKID_ACCEPTGIFT)])
			end

            inst.AnimState:PlayAnimation("talk_" .. tostring(math.random(2)), true)
		    inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/neutral")

			inst.sg:SetTimeout(0.4)
        end,

        ontimeout = function(inst)
			DropRewards(inst)
		end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(GetEatSnackState(inst) or "idle")
            end),
        },

		onexit = function(inst)
			DropRewards(inst)
		end,
    },

    State{
        name = "minigame_boo",
        tags = { "idle", "canrotate" },

        onenter = function(inst, last_excitement)
			inst.components.locomotor:Stop()

			inst.sg.statemem.loops = last_excitement > BOO_TIME + 5 and math.random(2, 3) or 1

            inst.AnimState:PlayAnimation("boo_pre")
            inst.AnimState:PushAnimation("boo_loop", false)
			if inst.sg.statemem.loops >= 2 then
	            inst.AnimState:PushAnimation("boo_loop", false)
			end
			if inst.sg.statemem.loops >= 3 then
	            inst.AnimState:PushAnimation("boo_loop", false)
			end

            inst.AnimState:PushAnimation("boo_pst", false)

        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/neutral") end),
            TimeEvent(28 * FRAMES, function(inst) if inst.sg.statemem.loops >= 2 then inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end end),
            TimeEvent(46 * FRAMES, function(inst) if inst.sg.statemem.loops >= 3 then inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },
    },

    State{
        name = "minigame_cheer",
        tags = { "idle", "canrotate" },

        onenter = function(inst, last_excitement)
			inst.components.locomotor:Stop()

			inst.sg.statemem.loops = last_excitement < 2 and math.random(2) or 1

            inst.AnimState:PlayAnimation("cheer_pre")
            inst.AnimState:PushAnimation("cheer_loop", false)
			if inst.sg.statemem.loops >= 2 then
	            inst.AnimState:PushAnimation("cheer_loop", false)
			end

            inst.AnimState:PushAnimation("cheer_pst", false)

        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/happy") end),
            TimeEvent(28 * FRAMES, function(inst) if inst.sg.statemem.loops >= 2 then inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/happy") end end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },
    },

    State{
        name = "minigame_over_cheer",
        tags = { "canrotate", "game_over" },

        onenter = function(inst)
			inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cheer_pre")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("minigame_over_cheer_loop")
            end),
        },
    },

    State{
        name = "minigame_over_cheer_loop",
        tags = { "canrotate", "game_over" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cheer_loop")
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/happy") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.components.minigame_spectator == nil and "minigame_over_cheer_pst" or "minigame_over_cheer_loop")
            end),
        },
    },

    State{
        name = "minigame_over_cheer_pst",
        tags = { "canrotate", "game_over" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("cheer_pst", false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "minigame_over_boo",
        tags = { "canrotate", "game_over" },

        onenter = function(inst)
			inst.components.locomotor:Stop()

			inst.sg.statemem.loops = math.random(1, 2)

            inst.AnimState:PlayAnimation("boo_pre")
            inst.AnimState:PushAnimation("boo_loop", false)
			if inst.sg.statemem.loops >= 2 then
	            inst.AnimState:PushAnimation("boo_loop", false)
			end

            inst.AnimState:PushAnimation("boo_pst", false)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end),
            TimeEvent(28 * FRAMES, function(inst) if inst.sg.statemem.loops >= 2 then inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState(inst.components.minigame_spectator == nil and "idle" or "minigame_over_boo")
            end),
        },
    },

    State{
        name = "activate",
        tags = { "canrotate", "game_over" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()

            inst.AnimState:PlayAnimation("cheer_pre")
            inst.AnimState:PushAnimation("cheer_loop", false)
            inst.AnimState:PushAnimation("cheer_pst", false)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/happy") end),
            TimeEvent(15 * FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}


CommonStates.AddWalkStates(states,
{
	walktimeline = {
		    TimeEvent(0*FRAMES, function(inst)
				inst.Physics:Stop()
				PlayFootstep(inst, 0.50)
            end ),

            TimeEvent(3*FRAMES, function(inst)
                inst.components.locomotor:WalkForward()
            end ),
            TimeEvent(15*FRAMES, function(inst)
                PlayFootstep(inst, 0.50)
                inst.Physics:Stop()
            end ),
	},
},
nil,
true, true)

CommonStates.AddRunStates(states,
{
	runtimeline = {
		    TimeEvent(0*FRAMES, function(inst)
				inst.Physics:Stop()
				PlayFootstep(inst, 0.50)
            end ),

            TimeEvent(3*FRAMES, function(inst)
                inst.components.locomotor:RunForward()
            end ),
            TimeEvent(15*FRAMES, function(inst)
                PlayFootstep(inst, 0.50)
                inst.Physics:Stop()
            end ),
	},
},
{
    startrun = "walk_pre",
    run = "walk_loop",
    stoprun = "walk_pst",
},
true, true)


return StateGraph("carnival_crowkid", states, events, "idle", actionhandlers)
