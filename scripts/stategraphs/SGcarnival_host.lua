require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
}

local events=
{
    CommonHandlers.OnLocomote(false, true),

    EventHandler("ontalk", function(inst, data)
        if not inst.sg:HasStateTag("busy") then
			local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator.minigame
			if minigame and minigame.components.minigame ~= nil and minigame.components.minigame:GetIsIntro() then
				inst.SoundEmitter:PlaySound("summerevent/characters/corvus/speak_1_shot")
			else
	            inst.sg:GoToState((not inst.hassold_plaza or math.random() < 0.1) and "announce" or "talk")
			end
        end
    end),
}


local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "flyaway",
        tags = { "flight", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("takeoff_pre")
            inst.AnimState:PushAnimation("fly_loop", true)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("glide")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.Physics:SetMotorVel(0.7, 11, 0.4) end),
        },
    },

    State{
        name = "glide",
        tags = { "flight", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fly_loop", true)

            local homepos = inst.components.knownlocations:GetLocation("home")
            local offset = FindWalkableOffset(homepos, math.random() * TWOPI, 4, 16)
							or FindWalkableOffset(homepos, math.random() * TWOPI, 6, 16)
            if offset then
                homepos = homepos + offset
            end
            inst.Transform:SetPosition(homepos.x, 30, homepos.z)

            inst.Physics:SetMotorVelOverride(0, -6, 0)
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVelOverride(0, -8, 0)
            local x, y, z = inst.Transform:GetWorldPosition()
            if y < 0.1 or inst:IsAsleep() then
                inst.sg:GoToState("land")
            end
        end,

        onexit = function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.Physics:ClearMotorVelOverride()
            inst.Physics:Stop()
            inst.Physics:Teleport(x, 0, z)
        end,
    },

    State{
        name = "land",
        tags = { "flight", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("land")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "talk",
        tags = {"canrotate", "talking"},

        onenter = function(inst)
			inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dialog"..math.random(3))
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/corvus/speak", "talk") end),
            TimeEvent(50*FRAMES, function(inst) inst.SoundEmitter:KillSound("talk") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

		onexit = function(inst)
	        inst.SoundEmitter:KillSound("talk")
		end,
    },

    State{
        name = "announce",
        tags = {"canrotate", "talking"},

        onenter = function(inst)
			inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("welcome")
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent/characters/corvus/speak", "talk") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:KillSound("talk") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

		onexit = function(inst)
	        inst.SoundEmitter:KillSound("talk")
		end,
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst) inst.components.locomotor.walkspeed = 3 end),
    },

    walktimeline =
    {
        TimeEvent(0, PlayFootstep),
        TimeEvent(0 * FRAMES, function(inst) inst.components.locomotor.walkspeed = 5 end),
        TimeEvent(7 * FRAMES, function(inst) inst.components.locomotor.walkspeed = 3  end),
        TimeEvent(12 * FRAMES, function(inst) inst.components.locomotor.walkspeed = 5 end),
        TimeEvent(18 * FRAMES, function(inst) inst.components.locomotor.walkspeed = 3 end),
        TimeEvent(12 * FRAMES, PlayFootstep),
    },
})

return StateGraph("carnival_host", states, events, "idle", actionhandlers)
