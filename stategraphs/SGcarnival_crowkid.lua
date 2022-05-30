require("stategraphs/commonstates")

local BOO_TIME = 5

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "flyaway"),
    ActionHandler(ACTIONS.ACTIVATE, "activate"),
}

local function GoToGameOverState(inst)
	inst.sg:GoToState((inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator._good_ending) and "minigame_over_cheer" or "minigame_over_boo")
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

        onenter = function(inst, from_minigame_reaction)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)

			if inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator._good_ending ~= nil then
				GoToGameOverState(inst)
			else
				inst.sg:SetTimeout(1 + math.random() * (from_minigame_reaction and 1 or 3))
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
			end
        end,
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
                inst.sg:GoToState("idle", true)
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
        tags = {"canrotate"},

        onenter = function(inst)
			inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("talk_" .. tostring(math.random(2)), true)
	        --inst.SoundEmitter:PlaySound("dontstarve/characters/wilson/talk_LP", "talk")
		    inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/neutral")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

		onexit = function(inst)
	        --inst.SoundEmitter:KillSound("talk")
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
            TimeEvent(28 * FRAMES, function(inst) if inst.sg.statemem.loops >= 3 then inst.SoundEmitter:PlaySound("summerevent/characters/crowkid/upset") end end),
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
