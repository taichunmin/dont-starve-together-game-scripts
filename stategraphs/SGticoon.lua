require("stategraphs/commonstates")


-- abandon reaction
-- waiting for leader idle
-- returned to leader reaction
-- at tracking target idle
-- kitcoon found reaction


local actionhandlers =
{
}

local events =
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
	CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),

	EventHandler("ticoon_getattention", function(inst)
		if not inst:HasTag("busy") and not inst.components.embarker:HasDestination() then
			inst.sg:GoToState("hiss")
		end
	end),

	EventHandler("ticoon_abandoned", function(inst)
		if not inst:HasTag("busy") then
			inst.sg:GoToState("hiss")
		end
	end),

	EventHandler("ticoon_kitcoonfound", function(inst)
		inst.sg:GoToState("happy_done")
	end),

	EventHandler("oneat", function(inst) 
		if inst.components.health == nil or not inst.components.health:IsDead() and not inst:HasTag("busy") then
			inst.sg:GoToState("eat") 
		end
	end),

}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, delay_despawn)
			if not delay_despawn and inst.persists == false and inst.components.combat.target == nil then
				inst.sg:GoToState("despawn")
				return
			end

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        timeline =
        {
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/swipe_tail") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
        },
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop")
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
        },
        timeline=
        {
            TimeEvent(FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(8*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(15*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(23*FRAMES, function(inst) PlayFootstep(inst) end),
        },
    },

    State{
        name = "walk_stop",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst)
				if inst.components.entitytracker:GetEntity("tracking") then
					if inst.components.questowner.questcomplete then
						inst.sg:GoToState("searching") 
					elseif inst.components.follower.leader then
						inst.sg:GoToState("waiting")
					else
						inst.sg:GoToState("idle") 
					end
				else
					inst.sg:GoToState("idle") 
				end
			end ),
        },
    },

    State{
        name = "searching",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("action")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")

			inst.sg.statemem.msg = data ~= nil and data.msg or nil
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(13*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(20*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(27*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(34*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(42*FRAMES, function(inst) PlayFootstep(inst) end),
        },

        events =
        {
            EventHandler("animover", function(inst) 
				if inst.sg.statemem.msg then
					local leader = inst.components.follower.leader
					if leader ~= nil and leader.components.talker ~= nil then
						leader.components.talker:Say(GetString(leader, inst.sg.statemem.msg))
					end
				end
					
				inst.sg:GoToState("idle") 
			end),
        },
    },

    State{
        name = "annoyed",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("follow_angery")
        end,

        timeline =
        {
            TimeEvent(35*FRAMES, function(inst)
				local leader = inst.components.follower.leader
				if leader ~= nil and leader.components.talker ~= nil then
					leader.components.talker:Say(GetString(leader, "ANNOUNCE_TICOON_GET_LEADER_ATTENTION"))
					inst.sg.mem.prev_wait_talk_time = GetTime()
				end
			end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "waiting",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("follow_pre")
			inst.Transform:SetSixFaced()
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/enemy/venus_flytrap/4/death") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("waiting_loop") end),
        },

		onexit = function(inst)
			inst.Transform:SetFourFaced()
		end,
    },

    State{
        name = "waiting_loop",
        tags = {"idle"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("follow_loop")
			inst.Transform:SetSixFaced()
        end,

        timeline =
        {
            TimeEvent(30*FRAMES, function(inst)
				local leader = inst.components.follower.leader
				if leader ~= nil and leader.components.talker ~= nil then
					local t = GetTime()
					if inst.sg.mem.prev_wait_talk_time == nil or inst.sg.mem.prev_wait_talk_time + 30 < t then
						leader.components.talker:Say(GetString(leader, "ANNOUNCE_TICOON_WAITING_FOR_LEADER"))
						inst.sg.mem.prev_wait_talk_time = t
					end
				end
			end),
        },

        events =
        {
            EventHandler("animover", function(inst) 
				if inst.components.follower.leader == nil then
					inst.sg:GoToState("idle") 
				else
					inst.sg:GoToState("waiting_loop") 
				end
			end),
        },

		onexit = function(inst)
			inst.Transform:SetFourFaced()
		end,
    },

    State{
        name = "happy_done",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("happy_pre")
            inst.AnimState:PushAnimation("happy", false)
            inst.AnimState:PushAnimation("happy", false)
            inst.AnimState:PushAnimation("happy_pst", false)
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
        end,

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotc_2022_2/creatures/ticoon/happy_done") end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotc_2022_2/creatures/ticoon/happy_done") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle", true) end),
        },
    },

    State{
        name = "hiss",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt_pre")
            inst.AnimState:PushAnimation("taunt", false)
            inst.AnimState:PushAnimation("taunt_pst", false)
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss_pre") end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "despawn",
        tags = {"busy", "caninterrupt"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sleep_pre")
			inst.persists = false
        end,

        timeline =
        {
			TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/yawn") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("despawn_loop") end),
        },
    },

    State{
        name = "despawn_loop",
        tags = {"busy", "caninterrupt"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("sleep_loop")
			inst.persists = false
        end,

        timeline =
        {
			TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/sleep") end)
        },

        events =
        {
            EventHandler("animover", function(inst) ErodeAway(inst) inst.sg:GoToState("despawn_loop") end),
        },
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(13*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(20*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(27*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(34*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(42*FRAMES, function(inst) PlayFootstep(inst) end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

}

CommonStates.AddCombatStates(states,
{
	hittimeline = {},

	attacktimeline =
	{
        --TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/swipe_pre") end),
        TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/swipe") end),
        TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/swipe_whoosh") end),
        TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
	},

	deathtimeline =
	{
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/death") end),
	},
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/yawn") end)
    },

    sleeptimeline =
    {
        TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/sleep") end)
    },

    waketimeline =
    {
        TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup") end)
    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true)
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("titcoon", states, events, "idle", actionhandlers)
