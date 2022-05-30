require("stategraphs/commonstates")
require("stategraphs/SGcritter_common")

local function GoToRandomPlayAnim(inst, data)
	if data.target ~= nil and data.target:IsValid() and not inst:HasTag("busy") and not inst.sg:HasStateTag("playful") then
		inst.sg:GoToState("playful"..math.random(4), data)
		return true
	end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.CATPLAYGROUND, "catplayground"),
    ActionHandler(ACTIONS.CATPLAYAIR, function(inst, data) 
		return (data.target ~= nil and (data.target.sg == nil or not (data.target.sg:HasStateTag("landing") or data.target.sg:HasStateTag("landed")))) and "catplayair" 
			or "catplayground" 
		end),
}

local events =
{
	EventHandler("critterplaywithme", GoToRandomPlayAnim),
	EventHandler("kitcoonplaywithme", GoToRandomPlayAnim),
	EventHandler("start_playwithplaymate", function(inst, data)
		if not data.target.sg:HasStateTag("playful") then
			data.rate = 1.2 + math.random() * 0.2
			if GoToRandomPlayAnim(inst, data) then
				data.target:PushEvent("kitcoonplaywithme", {target=inst})
			end
		end
	end),

    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
}

local states =
{
	State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
			if inst.components.locomotor ~= nil then
				inst.components.locomotor:StopMoving()
			end

			inst.AnimState:PlayAnimation("idle_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					local r = math.random()
					local emote_idle_chance = TUNING.KITCOON_LOYALTY_EMOTE_CHANCE
                    inst.sg:GoToState(r < emote_idle_chance*0.5 and "emote_lick" 
									or r < emote_idle_chance and "emote_stretch"
									or "idle")
                end
            end),
        },
	},

	State{
        name = "nuzzle",
        tags = { "busy", "canrotate" },

        onenter = function(inst, finder)
			if inst.components.locomotor ~= nil then
				inst.components.locomotor:StopMoving()
			end

		    inst:PerformBufferedAction()
			inst.next_play_time = GetTime() + TUNING.KITCOON_PLAYFUL_DELAY + math.random() * TUNING.KITCOON_PLAYFUL_DELAY_RAND

			local target = finder or (inst.components.follower ~= nil and inst.components.follower.leader) or nil
			if target then 
				inst:ForceFacePoint(target.Transform:GetWorldPosition())

				if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
					local loots = inst._first_nuzzle and {SpawnPrefab("lucky_goldnugget"), SpawnPrefab("lucky_goldnugget"), SpawnPrefab("lucky_goldnugget"), SpawnPrefab("lucky_goldnugget")}
									or nil

					inst._first_nuzzle = nil

					if loots ~= nil then
						local redpouch = SpawnPrefab("redpouch_yot_catcoon")
						redpouch.components.unwrappable:WrapItems(loots)
						for _, v in ipairs(loots) do
							v:Remove()
						end

						LaunchAt(redpouch, inst, target, .5, .6, .6)
					end
				end
			end

			inst.AnimState:PlayAnimation("emote_nuzzle")
        end,

		timeline = 
		{
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
	},


	State{
        name = "found",
        tags = { "busy" },

        onenter = function(inst, finder)
			if inst.components.locomotor ~= nil then
				inst.components.locomotor:StopMoving()
			end

			inst.sg.statemem.finder = finder

			inst.AnimState:PlayAnimation("jump_out")
        end,

		timeline = 
		{
			TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("nuzzle", inst.sg.statemem.finder)
                end
            end),
        },
	},

	State{
        name = "evicted",
        tags = { "busy" },

        onenter = function(inst)
			if inst.components.locomotor ~= nil then
				inst.components.locomotor:StopMoving()
			end
            inst.sg:SetTimeout(12*FRAMES)
			inst.AnimState:PlayAnimation("jump_out")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

		timeline = 
		{
			TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
	},

    State{
        name = "catplayground",
        tags = {"canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("emote_cute")
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
            TimeEvent(39*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "catplayair",
        tags = {"canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.target = target
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("emote_cute")
        end,

        timeline =
        {
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
            TimeEvent(24*FRAMES, function(inst) inst.Physics:SetMotorVelOverride(4,0,0) end),
			TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
            TimeEvent(28*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(39*FRAMES,
                function(inst)
                    inst.Physics:ClearMotorVelOverride()
                    inst.components.locomotor:Stop()
                end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,
    },

    State {
        name = "endofhiding_jump",		-- Note: PREHIDE_ANIM_LEN handles when the kitcoon will actually do the hide
        tags = {"busy", "jumping"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emote_combat_pre")
            inst.AnimState:PushAnimation("emote_combat_loop", false)
        end,

        timeline =
        {
--            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
        end,
    },
}



CommonStates.AddSimpleState(states, "emote_stretch", "emote_stretch", {"idle", "canrotate"}, nil, 
	{
		TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end),
	}
)

CommonStates.AddSimpleState(states, "emote_lick", "emote_lick", {"idle", "canrotate"}, nil, 
	{
		TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end),
		TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end),
		TimeEvent(58*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_lick") end),
	}
)


local function AddPlayAnim(s, name, anim, timeline)
    table.insert(s, State{
        name = name,
        tags = {"busy", "canrotate", "playful"},

        onenter = function(inst, data)
			inst.next_play_time = GetTime() + TUNING.KITCOON_PLAYFUL_DELAY + math.random() * TUNING.KITCOON_PLAYFUL_DELAY_RAND

			if data ~= nil and data.target ~= nil and data.target:IsValid() then 
				inst:ForceFacePoint(data.target:GetPosition()) 
			end 

            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anim)
			inst.AnimState:SetDeltaTimeMultiplier(data ~= nil and data.rate or 1)
        end,
        
        timeline = timeline,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			inst.AnimState:SetDeltaTimeMultiplier(1)
		end,
    })
end

-- reactions to kitten critter playing with me
AddPlayAnim(states, "playful1", "interact_active",
	{
		TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		TimeEvent(48*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
	}
)

AddPlayAnim(states, "playful2", "interact_passive",
	{
		TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle") end),
	}
) 
AddPlayAnim(states, "playful3", "emote_playful",
	{
		TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/pounce") end),
		TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote_nuzzle") end),
	}
)  
AddPlayAnim(states, "playful4", "emote_cute",
	{
		TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
		TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/emote") end),
	}
) 


CommonStates.AddWalkStates(states)
CommonStates.AddRunStates(states, nil,
{
	startrun = "walk_pre",
	run = "walk_loop",
	stoprun = "walk_pst",
})

CommonStates.AddSleepExStates(states,
		{
			starttimeline =
			{
				TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/yawn") end),
			},
			sleeptimeline =
			{
				TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/together/kittington/sleep") end),
			},
		})

CommonStates.AddHopStates(states, true)
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("SGcritter_kitten", states, events, "idle", actionhandlers)
