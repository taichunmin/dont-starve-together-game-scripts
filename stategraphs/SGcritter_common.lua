
SGCritterEvents = {}
SGCritterStates = {}


--------------------------------------------------------------------------
SGCritterEvents.OnEat = function()
    return EventHandler("oneat", function(inst) inst.sg:GoToState("eat") end)
end

SGCritterEvents.OnAvoidCombat = function()
    return EventHandler("critter_avoidcombat", function(inst, data) inst.sg.mem.avoidingcombat = (data ~= nil and data.avoid or false) end)
end

SGCritterEvents.OnTraitChanged = function()
    return EventHandler("crittertraitchanged",
		function(inst, data)
			if inst.sg:HasStateTag("busy") then
				inst.sg.mem.queuenewdominanttraitemote = true
			else
				inst.sg:GoToState("emote_cute")
			end
		end)
end

--------------------------------------------------------------------------
SGCritterStates.AddIdle = function(states, num_emotes, timeline, idle_anim_fn)
    table.insert(states, State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
			if inst.components.locomotor ~= nil then
				inst.components.locomotor:StopMoving()
			end

			local curtime = GetTime()

			if inst.sg.mem.queuenewdominanttraitemote then
				inst.sg.mem.queuenewdominanttraitemote = nil
				inst.sg.mem.prevemotetime = curtime
				inst.sg:GoToState("emote_cute")
			elseif inst.sg.mem.queuecraftyemote then
				inst.sg.mem.queuecraftyemote = nil
				inst.sg.mem.prevemotetime = curtime
				inst.sg:GoToState("emote_cute")
			elseif inst.sg.mem.avoidingcombat and inst.components.crittertraits:IsDominantTrait("combat") then
				if (curtime - (inst.sg.mem.prevemotetime or 0) > TUNING.CRITTER_DOMINANTTRAIT_COMBAT_EMOTE_DELAY) then
					inst.sg.mem.prevemotetime = curtime
					inst.sg:GoToState("combat_pre")
				else
					if idle_anim_fn ~= nil then
						inst.AnimState:PlayAnimation(idle_anim_fn(inst))
					else
						inst.AnimState:PlayAnimation("idle_loop")
					end
				end
			elseif inst.sg.mem.queuedplayfultarget ~= nil then
				inst.sg.mem.prevemotetime = curtime
				inst.sg.mem.prevplayfultime = inst.sg.mem.prevemotetime

				inst.sg:GoToState("playful", inst.sg.mem.queuedplayfultarget)
				inst.sg.mem.queuedplayfultarget = nil
			else
				local r = math.random()
				if r <= inst:GetPeepChance() then
					inst.sg:GoToState("hungry")
				elseif r <= (inst.components.crittertraits:IsDominantTrait("playful") and 0.2 or 0.1) and
					(curtime - (inst.sg.mem.prevemotetime or 0) > (inst.components.crittertraits:IsDominantTrait("playful") and TUNING.CRITTER_DOMINANTTRAIT_PLAYFUL_EMOTE_DELAY or TUNING.CRITTER_EMOTE_DELAY)) then
					inst.sg.mem.prevemotetime = curtime
					if inst.sg.mem.avoidingcombat then
						inst.sg:GoToState("combat_pre")
					else
						local choice = math.random(inst.components.crittertraits:IsDominantTrait("playful") and (num_emotes + 1) or num_emotes) -- if playful, then add a chance to play the cute emote instead of normal emotes
						inst.sg:GoToState("emote_"..((choice <= num_emotes) and tostring(choice) or "cute"))
					end

				else
					if idle_anim_fn ~= nil then
						inst.AnimState:PlayAnimation(idle_anim_fn(inst))
					else
						inst.AnimState:PlayAnimation("idle_loop")
					end
				end
			end
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
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddEat = function(states, timeline, fns)
    table.insert(states, State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat_loop", false)
            inst.AnimState:PushAnimation("eat_pst", false)

            if fns ~= nil and fns.onenter ~= nil then
                fns.onenter(inst)
            end
        end,

		timeline = timeline,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					local dest_state = inst.sg.mem.queuethankyou and "emote_cute" or "idle"
					inst.sg.mem.queuethankyou = nil
                    inst.sg:GoToState(dest_state)
                end
            end),
        },

        onexit = fns ~= nil and fns.onexit or nil,
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddHungry = function(states, timeline)
    table.insert(states, State{
        name = "hungry",
        tags = {"idle"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("distress")
        end,

        timeline = timeline,

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddNuzzle = function(states, actionhandlers, timeline, fns)
    table.insert(actionhandlers, ActionHandler(ACTIONS.NUZZLE, "nuzzle"))

    table.insert(states, State{
		name = "nuzzle",
		tags = {"busy"},

		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("emote_nuzzle")

            inst.sg.mem.prevnuzzletime = GetTime()

            if fns ~= nil and fns.onenter ~= nil then
                fns.onenter(inst)
            end
		end,

		onexit = function(inst)
			inst:PerformBufferedAction()
			inst:ClearBufferedAction()
			if fns ~= nil and fns.onexit ~= nil then
				fns.onexit(inst)
			end
		end,

		timeline = timeline,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst:PushEvent("critter_onnuzzle")
					inst.sg:GoToState("idle")
				end
			end)
		},
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddRandomEmotes = function(states, emotes)
	for i,v in ipairs(emotes) do
		table.insert(states, State{
			name = "emote_"..i,
			tags = { "busy", "canrotate" },

			onenter = function(inst, pushanim)
				if inst.components.locomotor ~= nil then
					inst.components.locomotor:StopMoving()
				end

				inst.AnimState:PlayAnimation(v.anim)

                if v.fns ~= nil and v.fns.onenter ~= nil then
                    v.fns.onenter(inst)
                end
			end,

			timeline = v.timeline,

			events =
			{
				EventHandler("animover", function(inst)
					if inst.AnimState:AnimDone() then
						inst.sg:GoToState("idle")
					end
				end),
			},

            onexit = v.fns ~= nil and v.fns.onexit or nil,
		})
	end
end

--------------------------------------------------------------------------
SGCritterStates.AddEmote = function(states, name, timeline)
    table.insert(states, State{
		name = "emote_"..name,
		tags = {"busy"},

		onenter = function(inst)
            inst.AnimState:PlayAnimation("emote_"..name)
		end,

		timeline = timeline,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end)
		},
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddPetEmote = function(states, timeline, onexit)
    table.insert(states, State{
		name = "emote_pet",
		tags = {"busy"},

		onenter = function(inst)
            inst.AnimState:PlayAnimation("emote_pet")
		end,

		timeline = timeline,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst:PushEvent("critter_onpet")
					inst.sg:GoToState("idle")
				end
			end)
		},

		onexit = onexit,
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddCombatEmote = function(states, timelines)
    table.insert(states, State{
		name = "combat_pre",
		tags = {"busy"},

		onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("emote_combat_pre")
		end,

		timeline = timelines and timelines.pre or nil,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					local loop = (inst.components.locomotor ~= nil and not inst.components.locomotor:WantsToMoveForward()) and inst.sg.mem.avoidingcombat
					inst.sg:GoToState(loop and "combat_loop" or "combat_pst")
				end
			end)
		},
    })

    table.insert(states, State{
		name = "combat_loop",
		tags = {"busy"},

		onenter = function(inst)
            inst.AnimState:PlayAnimation("emote_combat_loop")
		end,

		timeline = timelines and timelines.loop or nil,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					local loop_change = inst.components.crittertraits:IsDominantTrait("combat") and TUNING.CRITTER_DOMINANTTRAIT_COMBAT_LOOP_CHANCE or TUNING.CRITTER_COMBAT_LOOP_CHANCE
					local loop = (inst.components.locomotor ~= nil and not inst.components.locomotor:WantsToMoveForward()) and inst.sg.mem.avoidingcombat and math.random() < loop_change
					inst.sg:GoToState( loop and "combat_loop" or "combat_pst")
				end
			end)
		},
    })

    table.insert(states, State{
		name = "combat_pst",
		tags = {"busy"},

		onenter = function(inst)
            inst.AnimState:PlayAnimation("emote_combat_pst")
		end,

		timeline = timelines and timelines.pst or nil,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end)
		},
    })
end

--------------------------------------------------------------------------
SGCritterStates.AddPlayWithOtherCritter = function(states, events, timeline, onexit)
	table.insert(events, EventHandler("start_playwithplaymate", function(inst, data)
		local playful_delay = inst.components.crittertraits:IsDominantTrait("playful") and TUNING.CRITTER_DOMINANTTRAIT_PLAYFUL_WITHOTHER_DELAY or TUNING.CRITTER_PLAYFUL_DELAY

		if inst:IsPlayful() and data.target ~= nil and data.target:IsValid()
	        and (GetTime() - (inst.sg.mem.prevplayfultime or 0) > playful_delay)
	        and not inst.sg:HasStateTag("playful") then

			inst.sg.mem.queuedplayfultarget = data.target
            inst.sg.mem.queueplayfulanim = inst.sg.mem.playfulanim ~= 1 and 1 or 2

		    data.target:PushEvent("critterplaywithme", {target=inst, anim=(inst.sg.mem.queueplayfulanim == 1 and 2 or 1)})
		end
	end))

	table.insert(events, EventHandler("critterplaywithme", function(inst, data)
		if inst:IsPlayful() and data.target ~= nil and data.target:IsValid() then
			if inst.sg.mem.queuedplayfultarget == nil or inst.sg.mem.queuedplayfultarget == data.target then
				inst.sg.mem.queuedplayfultarget = data.target
				inst.sg.mem.queueplayfulanim = data.anim
			end
		end
	end))


    table.insert(states, State{
		name = "playful",
		tags = {"busy", "canrotate", "playful"},

		onenter = function(inst, target)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end

            inst.sg.mem.playfulanim = inst.sg.mem.queueplayfulanim
            inst.sg.mem.queueplayfulanim = nil

			inst:PushEvent("oncritterplaying")

            if target ~= nil and target:IsValid() then
				inst:ForceFacePoint(target:GetPosition())
			end

            if inst.sg.mem.playfulanim == nil or inst.sg.mem.playfulanim == 1 then
				inst.AnimState:PlayAnimation("interact_active")
			else
				inst.sg:GoToState("playful2")
			end

		end,

		timeline = timeline ~= nil and timeline.active or nil,

        onexit = onexit ~= nil and onexit.active or nil,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end)
		},
    })

    table.insert(states, State{
		name = "playful2",
		tags = {"busy", "canrotate", "playful"},

		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("interact_passive")
		end,

		timeline = timeline ~= nil and timeline.passive or nil,

        onexit = onexit ~= nil and onexit.inactive or nil,

		events =
		{
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end)
		},
    })

end

--------------------------------------------------------------------------
local function walkontimeout(inst)
    inst.sg:GoToState("walk")
end

SGCritterStates.AddWalkStates = function(states, timelines, softstop)
    table.insert(states, State{
        name = "walk_start",
        tags = { "moving", "canrotate", "softstop" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        timeline = timelines ~= nil and timelines.starttimeline or nil,

        events =
        {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("walk")
				end
			end),
        },
    })

    table.insert(states, State{
        name = "walk",
        tags = { "moving", "canrotate", "softstop" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = timelines ~= nil and timelines.walktimeline or nil,

        ontimeout = walkontimeout,
    })

    table.insert(states, State{
        name = "walk_stop",
        tags = { "canrotate", "softstop" },

        onenter = function(inst)
            if softstop == true or (type(softstop) == "function" and softstop(inst)) then
                inst.AnimState:PushAnimation("walk_pst", false)
                if inst.AnimState:IsCurrentAnimation("walk_pst") then
                    inst.components.locomotor:StopMoving()
                else
                    local remaining = inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() - (inst:HasTag("flying") and 0 or 2 * FRAMES)
                    if remaining > 0 then
                        inst.sg.statemem.softstopmult = .9
                        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "softstop", inst.sg.statemem.softstopmult)
                        inst.components.locomotor:WalkForward()
                        inst.sg:SetTimeout(remaining)
                    else
                        inst.components.locomotor:StopMoving()
                    end
                end
            else
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("walk_pst")
            end
        end,

        timeline = timelines ~= nil and timelines.endtimeline or nil,

        onupdate = function(inst)
            if inst.sg.statemem.softstopmult ~= nil then
                inst.sg.statemem.softstopmult = inst.sg.statemem.softstopmult * .9
                inst.components.locomotor:SetExternalSpeedMultiplier(inst, "softstop", inst.sg.statemem.softstopmult)
                inst.components.locomotor:WalkForward()
            end
        end,

        ontimeout = function(inst)
            inst.sg.statemem.softstopmult = nil
            inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "softstop")
            inst.components.locomotor:StopMoving()
        end,

        events =
        {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
        },

        onexit = function(inst)
            if inst.sg.statemem.softstopmult ~= nil then
                inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "softstop")
            end
        end,
    })
end
