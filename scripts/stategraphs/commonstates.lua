CommonStates = {}
CommonHandlers = {}

--------------------------------------------------------------------------
local function onstep(inst)
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/movement/run_dirt")
        --inst.SoundEmitter:PlaySound("dontstarve/movement/walk_dirt")
    end
end

CommonHandlers.OnStep = function()
    return EventHandler("step", onstep)
end

--------------------------------------------------------------------------
local function onsleep(inst)
    if inst.components.health == nil or (inst.components.health ~= nil and not inst.components.health:IsDead()) then
		if inst.sg:HasStateTag("jumping") and inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() then
			inst.sg:GoToState("sink")
		else
		    inst.sg:GoToState(inst.sg:HasStateTag("sleeping") and "sleeping" or "sleep")
		end
    end
end

CommonHandlers.OnSleep = function()
    return EventHandler("gotosleep", onsleep)
end

--------------------------------------------------------------------------
local function onfreeze(inst)
    if inst.components.health ~= nil and not inst.components.health:IsDead() then
        inst.sg:GoToState("frozen")
    end
end

CommonHandlers.OnFreeze = function()
    return EventHandler("freeze", onfreeze)
end

--------------------------------------------------------------------------
--V2C: DST improved to support freezable entities with no health component

local function onfreezeex(inst)
    if not (inst.components.health ~= nil and inst.components.health:IsDead()) then
        inst.sg:GoToState("frozen")
    end
end

CommonHandlers.OnFreezeEx = function()
    return EventHandler("freeze", onfreezeex)
end

--------------------------------------------------------------------------
local function onfossilize(inst, data)
    if not (inst.components.health ~= nil and inst.components.health:IsDead() or inst.sg:HasStateTag("fossilized")) then
        if inst.sg:HasStateTag("nofreeze") then
            inst.components.fossilizable:OnSpawnFX()
        else
            inst.sg:GoToState("fossilized", data)
        end
    end
end

CommonHandlers.OnFossilize = function()
    return EventHandler("fossilize", onfossilize)
end

--------------------------------------------------------------------------
-- delay: how long before we can play another hit reaction animation, 
-- max_hitreacts: the number of hit reacts before we enter the react cooldown. The creature's AI may still early out of this.
-- skip_cooldown_fn: return true if you want to allow hit reacts while the hit react is in cooldown (allowing stun locking)
local function hit_recovery_delay(inst, delay, max_hitreacts, skip_cooldown_fn)
	local on_cooldown = false
	if (inst._last_hitreact_time ~= nil and inst._last_hitreact_time + (delay or inst.hit_recovery or TUNING.DEFAULT_HIT_RECOVERY) >= GetTime()) then	-- is hit react is on cooldown?
		max_hitreacts = max_hitreacts or inst._max_hitreacts
		if max_hitreacts then
			if inst._hitreact_count == nil then
				inst._hitreact_count = 2
				return false
			elseif inst._hitreact_count < max_hitreacts then
				inst._hitreact_count = inst._hitreact_count + 1
				return false
			end
		end

		skip_cooldown_fn = skip_cooldown_fn or inst._hitreact_skip_cooldown_fn
		if skip_cooldown_fn ~= nil then
			on_cooldown = not skip_cooldown_fn(inst, inst._last_hitreact_time, delay)
		elseif inst.components.combat ~= nil then
			on_cooldown = not (inst.components.combat:InCooldown() and inst.sg:HasStateTag("idle"))		-- skip the hit react cooldown if the creature is ready to attack
		else
			on_cooldown = true
		end
	end

	if inst._hitreact_count ~= nil and not on_cooldown then
		inst._hitreact_count = 1
	end
	return on_cooldown
end

CommonHandlers.HitRecoveryDelay = hit_recovery_delay -- returns true if inst is still in a hit reaction cooldown

local function update_hit_recovery_delay(inst)
	inst._last_hitreact_time = GetTime()
end

CommonHandlers.UpdateHitRecoveryDelay = update_hit_recovery_delay

CommonHandlers.ResetHitRecoveryDelay = function(inst)
	inst._last_hitreact_time = nil
	inst._last_hitreact_count = nil
end

local function onattacked(inst, data, hitreact_cooldown, max_hitreacts, skip_cooldown_fn)
    if inst.components.health ~= nil and not inst.components.health:IsDead()
		and not hit_recovery_delay(inst, hitreact_cooldown, max_hitreacts, skip_cooldown_fn)
        and (not inst.sg:HasStateTag("busy")
            or inst.sg:HasStateTag("caninterrupt")
            or inst.sg:HasStateTag("frozen")) then
        inst.sg:GoToState("hit")
    end
end

CommonHandlers.OnAttacked = function(hitreact_cooldown, max_hitreacts, skip_cooldown_fn) -- params are optional
	hitreact_cooldown = type(hitreact_cooldown) == "number" and hitreact_cooldown or nil -- validting the data because a lot of poeple were passing in 'true' for no reason

	if hitreact_cooldown ~= nil or max_hitreacts ~= nil or skip_cooldown_fn ~= nil then
		return EventHandler("attacked", function(inst, data) onattacked(inst, data, hitreact_cooldown, max_hitreacts, skip_cooldown_fn) end)
	else
	    return EventHandler("attacked", onattacked)
	end
end

--------------------------------------------------------------------------
local function onattack(inst)
    if inst.components.health ~= nil and not inst.components.health:IsDead()
        and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
        inst.sg:GoToState("attack")
    end
end

CommonHandlers.OnAttack = function()
    return EventHandler("doattack", onattack)
end

--------------------------------------------------------------------------
local function ondeath(inst, data)
	if not inst.sg:HasStateTag("dead") then
		inst.sg:GoToState("death", data)
	end
end

CommonHandlers.OnDeath = function()
    return EventHandler("death", ondeath)
end

--------------------------------------------------------------------------
CommonHandlers.OnLocomote = function(can_run, can_walk)
    return EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()

        if is_moving and not should_move then
            inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
            if can_run and (should_run or not can_walk) then
                inst.sg:GoToState("run_start")
            elseif can_walk then
                inst.sg:GoToState("walk_start")
            end
        end
    end)
end

--------------------------------------------------------------------------
local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

--------------------------------------------------------------------------
CommonStates.AddIdle = function(states, funny_idle_state, anim_override, timeline)
    table.insert(states, State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local anim =
                (anim_override == nil and "idle_loop") or
                (type(anim_override) ~= "function" and anim_override) or
                anim_override(inst)

            --pushanim could be bool or string?
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(anim, true)
            elseif not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end
        end,

        timeline = timeline,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(math.random() < .1 and funny_idle_state or "idle")
                end
            end),
        },
    })
end

--------------------------------------------------------------------------
CommonStates.AddSimpleState = function(states, name, anim, tags, finishstate, timeline, fns)
    table.insert(states, State{
        name = name,
        tags = tags or {},

        onenter = function(inst, params)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anim)
			if fns ~= nil and fns.onenter ~= nil then
				fns.onenter(inst, params)
			end
        end,

        timeline = timeline,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(finishstate or "idle")
                end
            end),
        },

		onexit = fns ~= nil and fns.onexit or nil
    })
end

--------------------------------------------------------------------------
local function performbufferedaction(inst)
    inst:PerformBufferedAction()
end

--------------------------------------------------------------------------
CommonStates.AddSimpleActionState = function(states, name, anim, time, tags, finishstate, timeline, fns)
    table.insert(states, State{
        name = name,
        tags = tags or {},

        onenter = function(inst, params)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anim)
			if fns ~= nil and fns.onenter ~= nil then
				fns.onenter(inst, params)
			end
        end,

        timeline = timeline or
        {
            TimeEvent(time, performbufferedaction),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(finishstate or "idle")
                end
            end),
        },

		onexit = fns ~= nil and fns.onexit or nil
    })
end

--------------------------------------------------------------------------
CommonStates.AddShortAction = function(states, name, anim, timeout, finishstate)
    table.insert(states, State{
        name = "name",
        tags = { "doing" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anim)
            inst.sg:SetTimeout(timeout or (6 * FRAMES))
        end,

        ontimeout = performbufferedaction,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(finishstate or "idle")
                end
            end),
        },
    })
end

--------------------------------------------------------------------------
local function idleonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("idle")
    end
end

--------------------------------------------------------------------------
local function get_loco_anim(inst, override, default)
    return (override == nil and default)
        or (type(override) ~= "function" and override)
        or override(inst)
end

--------------------------------------------------------------------------
local function runonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("run")
    end
end

local function runontimeout(inst)
    inst.sg:GoToState("run")
end

CommonStates.AddRunStates = function(states, timelines, anims, softstop, delaystart, fns)
    table.insert(states, State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
			if fns ~= nil and fns.startonenter ~= nil then -- this has to run before RunForward so that startonenter has a chance to update the run speed
				fns.startonenter(inst)
			end
			if delaystart then
				inst.components.locomotor:StopMoving()
			else
	            inst.components.locomotor:RunForward()
			end
            inst.AnimState:PlayAnimation(get_loco_anim(inst, anims ~= nil and anims.startrun or nil, "run_pre"))
        end,

        timeline = timelines ~= nil and timelines.starttimeline or nil,

		onupdate = fns ~= nil and fns.startonupdate or nil,

		onexit = fns ~= nil and fns.startonexit or nil,

        events =
        {
            EventHandler("animover", runonanimover),
        },
    })

    table.insert(states, State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
			if fns ~= nil and fns.runonenter ~= nil then
				fns.runonenter(inst)
			end
            inst.components.locomotor:RunForward()
			--V2C: -normally we wouldn't restart an already looping anim
			--     -however, changing this might affect softstop behaviour
			--     -i.e. PushAnimation over a looping anim (first play vs subsequent loops)
			--     -why do we even tell it to loop here then?  for smoother playback on clients
			inst.AnimState:PlayAnimation(get_loco_anim(inst, anims ~= nil and anims.run or nil, "run_loop"), true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = timelines ~= nil and timelines.runtimeline or nil,

		onupdate = fns ~= nil and fns.runonupdate or nil,

		onexit = fns ~= nil and fns.runonexit or nil,

        ontimeout = runontimeout,
    })

    table.insert(states, State{
        name = "run_stop",
        tags = { "idle" },

        onenter = function(inst)
			if fns ~= nil and fns.endonenter ~= nil then
				fns.endonenter(inst)
			end
            inst.components.locomotor:StopMoving()
            if softstop == true or (type(softstop) == "function" and softstop(inst)) then
                inst.AnimState:PushAnimation(get_loco_anim(inst, anims ~= nil and anims.stoprun or nil, "run_pst"), false)
            else
                inst.AnimState:PlayAnimation(get_loco_anim(inst, anims ~= nil and anims.stoprun or nil, "run_pst"))
            end
        end,

        timeline = timelines ~= nil and timelines.endtimeline or nil,

		onupdate = fns ~= nil and fns.endonupdate or nil,

		onexit = fns ~= nil and fns.endonexit or nil,

        events =
        {
            EventHandler("animqueueover", idleonanimover),
        },
    })
end

--------------------------------------------------------------------------
CommonStates.AddSimpleRunStates = function(states, anim, timelines)
    CommonStates.AddRunStates(states, timelines, { startrun = anim, run = anim, stoprun = anim } )
end

--------------------------------------------------------------------------
local function walkonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("walk")
    end
end

local function walkontimeout(inst)
    inst.sg:GoToState("walk")
end

CommonStates.AddWalkStates = function(states, timelines, anims, softstop, delaystart, fns)
    table.insert(states, State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
			if fns ~= nil and fns.startonenter ~= nil then -- this has to run before WalkForward so that startonenter has a chance to update the walk speed
				fns.startonenter(inst)
			end
			if delaystart then
				inst.components.locomotor:StopMoving()
			else
	            inst.components.locomotor:WalkForward()
			end
            inst.AnimState:PlayAnimation(get_loco_anim(inst, anims ~= nil and anims.startwalk or nil, "walk_pre"))
        end,

        timeline = timelines ~= nil and timelines.starttimeline or nil,

		onupdate = fns ~= nil and fns.startonupdate or nil,

		onexit = fns ~= nil and fns.startonexit or nil,

        events =
        {
            EventHandler("animover", walkonanimover),
        },
    })

    table.insert(states, State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
			if fns ~= nil and fns.walkonenter ~= nil then
				fns.walkonenter(inst)
			end
            inst.components.locomotor:WalkForward()
			--V2C: -normally we wouldn't restart an already looping anim
			--     -however, changing this might affect softstop behaviour
			--     -i.e. PushAnimation over a looping anim (first play vs subsequent loops)
			--     -why do we even tell it to loop here then?  for smoother playback on clients
            inst.AnimState:PlayAnimation(get_loco_anim(inst, anims ~= nil and anims.walk or nil, "walk_loop"), true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline = timelines ~= nil and timelines.walktimeline or nil,

		onupdate = fns ~= nil and fns.walkonupdate or nil,

		onexit = fns ~= nil and fns.walkonexit or nil,

        ontimeout = walkontimeout,
    })

    table.insert(states, State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
			if fns ~= nil and fns.endonenter ~= nil then
				fns.endonenter(inst)
			end
            inst.components.locomotor:StopMoving()
            if softstop == true or (type(softstop) == "function" and softstop(inst)) then
                inst.AnimState:PushAnimation(get_loco_anim(inst, anims ~= nil and anims.stopwalk or nil, "walk_pst"), false)
            else
                inst.AnimState:PlayAnimation(get_loco_anim(inst, anims ~= nil and anims.stopwalk or nil, "walk_pst"))
            end
        end,

        timeline = timelines ~= nil and timelines.endtimeline or nil,

		onupdate = fns ~= nil and fns.endonupdate or nil,

		onexit = fns ~= nil and fns.endonexit or nil,

        events =
        {
            EventHandler("animqueueover", idleonanimover),
        },
    })
end

--------------------------------------------------------------------------
CommonStates.AddSimpleWalkStates = function(states, anim, timelines)
    CommonStates.AddWalkStates(states, timelines, { startwalk = anim, walk = anim, stopwalk = anim }, true)
end

--------------------------------------------------------------------------
CommonHandlers.OnHop = function()
    return EventHandler("onhop",
        function(inst)
            if (inst.components.health == nil or not inst.components.health:IsDead()) and (inst.sg:HasStateTag("moving") or inst.sg:HasStateTag("idle")) then
                if not inst.sg:HasStateTag("jumping") then
                    if inst.components.embarker and inst.components.embarker.antic and inst:HasTag("swimming") then
                        inst.sg:GoToState("hop_antic")
                    else
                        inst.sg:GoToState("hop_pre")
                    end
                end
            elseif inst.components.embarker then
                inst.components.embarker:Cancel()
            end
        end)
end

local function DoHopLandSound(inst, land_sound)
	if inst:GetCurrentPlatform() ~= nil then
		inst.SoundEmitter:PlaySound(land_sound, nil, nil, true)
	end
end

CommonStates.AddHopStates = function(states, wait_for_pre, anims, timelines, land_sound, landed_in_water_state, data)
	anims = anims or {}
    timelines = timelines or {}
	data = data or {}

    table.insert(states, State{
        name = "hop_pre",
        tags = { "doing", "nointerrupt", "busy", "boathopping", "jumping", "autopredict", "nomorph", "nosleep" },

        onenter = function(inst)
            local embark_x, embark_z = inst.components.embarker:GetEmbarkPosition()
            inst:ForceFacePoint(embark_x, 0, embark_z)
            if not wait_for_pre then
				inst.sg.statemem.not_interrupted = true
                inst.sg:GoToState("hop_loop", inst.sg.statemem.queued_post_land_state)
			else
	            inst.AnimState:PlayAnimation(FunctionOrValue(anims.pre, inst) or "jump_pre", false)
				if data.start_embarking_pre_frame ~= nil then
					inst.sg:SetTimeout(data.start_embarking_pre_frame)
				end
            end
        end,

        timeline = timelines.hop_pre or nil,

		ontimeout = function(inst)
			inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)
			if not TheWorld.ismastersim then
	            inst.Physics:SetLocalCollisionMask(COLLISION.GROUND)
			end
			inst.components.embarker:StartMoving()
		end,

        events =
        {
            EventHandler("animover",
                function(inst)
                    if wait_for_pre then
						inst.sg.statemem.not_interrupted = true
                        inst.sg:GoToState("hop_loop", {queued_post_land_state = inst.sg.statemem.queued_post_land_state, collisionmask = inst.sg.statemem.collisionmask})
                    end
                end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.not_interrupted then
				if data.start_embarking_pre_frame ~= nil then
					inst.Physics:ClearLocalCollisionMask()
					if inst.sg.statemem.collisionmask ~= nil then
						inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
					end
				end
	            inst.components.embarker:Cancel()
			end
		end,
    })

    table.insert(states, State{
        name = "hop_loop",
        tags = { "doing", "nointerrupt", "busy", "boathopping", "jumping", "autopredict", "nomorph", "nosleep" },

        onenter = function(inst, data)
			inst.sg.statemem.queued_post_land_state = data ~= nil and data.queued_post_land_state or nil
            inst.AnimState:PlayAnimation(FunctionOrValue(anims.loop, inst) or "jump_loop", true)
			inst.sg.statemem.collisionmask = data ~= nil and data.collisionmask or inst.Physics:GetCollisionMask()
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)
			if not TheWorld.ismastersim then
	            inst.Physics:SetLocalCollisionMask(COLLISION.GROUND)
			end
            inst.components.embarker:StartMoving()
            inst:AddTag("ignorewalkableplatforms")
        end,

        timeline = timelines.hop_loop or nil,

        events =
        {
            EventHandler("done_embark_movement", function(inst)
                local px, _, pz = inst.Transform:GetWorldPosition()
				inst.sg.statemem.not_interrupted = true
                inst.sg:GoToState("hop_pst", {landed_in_water = not TheWorld.Map:IsPassableAtPoint(px, 0, pz), queued_post_land_state = inst.sg.statemem.queued_post_land_state} )
            end),
        },

		onexit = function(inst)
            inst.Physics:ClearLocalCollisionMask()
			if inst.sg.statemem.collisionmask ~= nil then
	            inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
			end
            inst:RemoveTag("ignorewalkableplatforms")
			if not inst.sg.statemem.not_interrupted then
	            inst.components.embarker:Cancel()
			end

			if inst.components.locomotor.isrunning then
                inst:PushEvent("locomote")
			end
		end,
    })

    table.insert(states, State{
        name = "hop_pst",
        tags = { "doing", "nointerrupt", "boathopping", "jumping", "autopredict", "nomorph", "nosleep" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation(FunctionOrValue(anims.pst, inst) or "jump_pst", false)

            inst.components.embarker:Embark()

            local nextstate = "hop_pst_complete"
			if data ~= nil then
				nextstate = (
                                data.landed_in_water and landed_in_water_state ~= nil and
                                (
                                    type(landed_in_water_state) ~= "function" and landed_in_water_state or
                                    landed_in_water_state(inst)
                                )
                            )
							 or data.queued_post_land_state
							 or nextstate
			end
            if wait_for_pre then
                inst.sg.statemem.nextstate = nextstate
            else
                inst.sg:GoToState(nextstate)
            end
        end,

        timeline = timelines.hop_pst or nil,

        events =
        {
            EventHandler("animover", function(inst)
                if wait_for_pre then
                    inst.sg:GoToState(inst.sg.statemem.nextstate)
                end
            end),
        },

		onexit = function(inst)
			-- here for now, should be moved into timeline
			if land_sound ~= nil then
				--For now we just have the land on boat sound
				--Delay since inst:GetCurrentPlatform() may not be updated yet
				inst:DoTaskInTime(0, DoHopLandSound, land_sound)
            end
		end
    })

    table.insert(states, State{
        name = "hop_pst_complete",
        tags = {"autopredict", "nomorph", "nosleep" },

        onenter = function(inst)
			if inst.components.locomotor.isrunning then
                inst:DoTaskInTime(0,
                    function()
                        if inst.sg.currentstate.name == "hop_pst_complete" then
                            inst.sg:GoToState("idle")
                        end
                    end)
            else
                inst.sg:GoToState("idle")
            end
        end,
    })
end

CommonStates.AddAmphibiousCreatureHopStates = function(states, config, anims, timelines, updates)
	config = config or {}
	anims = anims or {}
	timelines = timelines or {}

	local onenters = (config ~= nil and config.onenters ~= nil) and config.onenters or nil
	local onexits = (config ~= nil and config.onexits ~= nil) and config.onexits or nil

	local base_hop_pre_timeline = {
        TimeEvent(config.swimming_clear_collision_frame or 0, function(inst)
			if inst.sg.statemem.swimming then
				inst.Physics:ClearCollidesWith(COLLISION.LIMITS)
			end
		end),
	}
	timelines.hop_pre = timelines.hop_pre == nil and base_hop_pre_timeline or JoinArrays(timelines.hop_pre, base_hop_pre_timeline)

    table.insert(states, State{
        name = "hop_pre",
        tags = { "doing", "busy", "jumping", "canrotate" },

        onenter = function(inst)
			inst.sg.statemem.swimming = inst:HasTag("swimming")
            inst.AnimState:PlayAnimation(anims.pre or "jump")
			if not inst.sg.statemem.swimming then
				inst.Physics:ClearCollidesWith(COLLISION.LIMITS)
			end
			if inst.components.embarker:HasDestination() then
	            inst.sg:SetTimeout(18 * FRAMES)
                inst.components.embarker:StartMoving()
			else
	            inst.sg:SetTimeout(18 * FRAMES)
                if inst.landspeed then
                    inst.components.locomotor.runspeed = inst.landspeed
                end
                inst.components.locomotor:RunForward()
			end

			if onenters ~= nil and onenters.hop_pre ~= nil then
				onenters.hop_pre(inst)
			end
        end,

	    onupdate = function(inst,dt)
			if inst.components.embarker:HasDestination() then
				if inst.sg.statemem.embarked then
					inst.components.embarker:Embark()
					inst.components.locomotor:FinishHopping()
					inst.sg:GoToState("hop_pst", false)
				elseif inst.sg.statemem.timeout then
					inst.components.embarker:Cancel()
					inst.components.locomotor:FinishHopping()

					local x, y, z = inst.Transform:GetWorldPosition()
					inst.sg:GoToState("hop_pst", not TheWorld.Map:IsVisualGroundAtPoint(x, y, z) and inst:GetCurrentPlatform() == nil)
				end
            elseif inst.sg.statemem.timeout or
                   (inst.sg.statemem.tryexit and inst.sg.statemem.swimming == TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition())) or
                   (not inst.components.locomotor.dest and not inst.components.locomotor.wantstomoveforward) then
				inst.components.embarker:Cancel()
				inst.components.locomotor:FinishHopping()
				local x, y, z = inst.Transform:GetWorldPosition()
				inst.sg:GoToState("hop_pst", not TheWorld.Map:IsVisualGroundAtPoint(x, y, z) and inst:GetCurrentPlatform() == nil)
			end
		end,

        timeline = timelines.hop_pre,

		ontimeout = function(inst)
			inst.sg.statemem.timeout = true
		end,

        events =
        {
            EventHandler("done_embark_movement", function(inst)
				if not inst.AnimState:IsCurrentAnimation("jump_loop") then
					inst.AnimState:PlayAnimation(anims.loop or "jump_loop", false)
					inst.components.amphibiouscreature:OnExitOcean()
				end
				inst.sg.statemem.embarked = true
            end),
            EventHandler("animover", function(inst)
				if not inst.AnimState:IsCurrentAnimation("jump_loop") then
					if inst.AnimState:AnimDone() then
						if not inst.components.embarker:HasDestination() then
							inst.sg.statemem.tryexit = true
						end
					end
					inst.AnimState:PlayAnimation(anims.loop or "jump_loop", false)

					inst.components.amphibiouscreature:OnExitOcean()
				end
            end),
        },

		onexit = function(inst)
            inst.Physics:CollidesWith(COLLISION.LIMITS)
			if inst.components.embarker:HasDestination() then
				inst.components.embarker:Cancel()
				inst.components.locomotor:FinishHopping()
			end

			if onexits ~= nil and onexits.hop_pre ~= nil then
				onexits.hop_pre(inst)
			end
		end,
    })

    table.insert(states, State{
        name = "hop_pst",
        tags = { "busy", "jumping" },

        onenter = function(inst, land_in_water)
			if land_in_water then
				inst.components.amphibiouscreature:OnEnterOcean()
			else
				inst.components.amphibiouscreature:OnExitOcean()
			end

			if onenters ~= nil and onenters.hop_pst ~= nil then
				onenters.hop_pst(inst)
			end

            inst.AnimState:PlayAnimation(anims.pst or "jump_pst")
        end,

        timeline = timelines.hop_pst,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if onexits ~= nil and onexits.hop_pst ~= nil then
				onexits.hop_pst(inst)
			end
		end,
    })

    table.insert(states, State{
        name = "hop_antic",
        tags = { "doing", "busy", "jumping", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.sg.statemem.swimming = inst:HasTag("swimming")

            inst.AnimState:PlayAnimation(anims.antic or "jump_antic")

            inst.sg:SetTimeout(30 * FRAMES)

			if onenters ~= nil and onenters.hop_antic ~= nil then
				onenters.hop_antic(inst)
			end
        end,

        timeline = timelines.hop_antic,

        ontimeout = function(inst)
            inst.sg:GoToState("hop_pre")
        end,
        onexit = function(inst)
			if onexits ~= nil and onexits.hop_antic ~= nil then
				onexits.hop_antic(inst)
			end
        end,
    })
end

--------------------------------------------------------------------------
local function sleeponanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("sleeping")
    end
end

local function onwakeup(inst)
	if not inst.sg:HasStateTag("nowake") then
	    inst.sg:GoToState("wake")
	end
end

local function onentersleeping(inst)
    inst.AnimState:PlayAnimation("sleep_loop")
end

CommonStates.AddSleepStates = function(states, timelines, fns)
    table.insert(states, State{
        name = "sleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("sleep_pre")
            if fns ~= nil and fns.onsleep ~= nil then
                fns.onsleep(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.starttimeline or nil,

        events =
        {
            EventHandler("animover", sleeponanimover),
            EventHandler("onwakeup", onwakeup),
        },
    })

    table.insert(states, State{
        name = "sleeping",
        tags = { "busy", "sleeping" },

        onenter = onentersleeping,

        onexit = fns and fns.onsleepexit or nil,

        timeline = timelines ~= nil and timelines.sleeptimeline or nil,

        events =
        {
            EventHandler("animover", sleeponanimover),
            EventHandler("onwakeup", onwakeup),
        },
    })

    table.insert(states, State{
        name = "wake",
        tags = { "busy", "waking" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("sleep_pst")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            if fns ~= nil and fns.onwake ~= nil then
                fns.onwake(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.waketimeline or nil,

        events =
        {
            EventHandler("animover", idleonanimover),
        },
    })
end

--------------------------------------------------------------------------
local function onunfreeze(inst)
    inst.sg:GoToState(inst.sg.sg.states.hit ~= nil and "hit" or "idle")
end

local function onthaw(inst)
	inst.sg.statemem.thawing = true
    inst.sg:GoToState("thaw")
end

local function onenterfrozenpre(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
    end
    inst.AnimState:PlayAnimation("frozen", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function onenterfrozenpst(inst)
    --V2C: cuz... freezable component and SG need to match state,
    --     but messages to SG are queued, so it is not great when
    --     when freezable component tries to change state several
    --     times within one frame...
    if inst.components.freezable == nil then
        onunfreeze(inst)
    elseif inst.components.freezable:IsThawing() then
        onthaw(inst)
    elseif not inst.components.freezable:IsFrozen() then
        onunfreeze(inst)
    end
end

local function onenterfrozen(inst)
    onenterfrozenpre(inst)
    onenterfrozenpst(inst)
end

local function onexitfrozen(inst)
	if not inst.sg.statemem.thawing then
		inst.AnimState:ClearOverrideSymbol("swap_frozen")
	end
end

local function onenterthawpre(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor:StopMoving()
    end
    inst.AnimState:PlayAnimation("frozen_loop_pst", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function onenterthawpst(inst)
    --V2C: cuz... freezable component and SG need to match state,
    --     but messages to SG are queued, so it is not great when
    --     when freezable component tries to change state several
    --     times within one frame...
    if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
        onunfreeze(inst)
    end
end

local function onenterthaw(inst)
    onenterthawpre(inst)
    onenterthawpst(inst)
end

local function onexitthaw(inst)
    inst.SoundEmitter:KillSound("thawing")
    inst.AnimState:ClearOverrideSymbol("swap_frozen")
end

CommonStates.AddFrozenStates = function(states, onoverridesymbols, onclearsymbols)
    table.insert(states, State{
        name = "frozen",
        tags = { "busy", "frozen" },

        onenter = onoverridesymbols ~= nil and function(inst)
            onenterfrozenpre(inst)
            onoverridesymbols(inst)
            onenterfrozenpst(inst)
        end or onenterfrozen,

        events =
        {
            EventHandler("unfreeze", onunfreeze),
            EventHandler("onthaw", onthaw),
        },

        onexit = onclearsymbols ~= nil and function(inst)
            onexitfrozen(inst)
            onclearsymbols(inst)
        end or onexitfrozen,
    })

    table.insert(states, State{
        name = "thaw",
        tags = { "busy", "thawing" },

        onenter = onoverridesymbols ~= nil and function(inst)
            onenterthawpre(inst)
            onoverridesymbols(inst)
            onenterthawpst(inst)
        end or onenterthaw,

        events =
        {
            EventHandler("unfreeze", onunfreeze),
        },

        onexit = onclearsymbols ~= nil and function(inst)
            onexitthaw(inst)
            onclearsymbols(inst)
        end or onexitthaw,
    })
end

--------------------------------------------------------------------------
CommonStates.AddCombatStates = function(states, timelines, anims, fns)
    table.insert(states, State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation(
                ((anims == nil or anims.hit == nil) and "hit") or
                (type(anims.hit) ~= "function" and anims.hit) or
                anims.hit(inst)
            )

            if inst.SoundEmitter ~= nil and inst.sounds ~= nil and inst.sounds.hit ~= nil then
                inst.SoundEmitter:PlaySound(inst.sounds.hit)
            end

			update_hit_recovery_delay(inst)
        end,

        timeline = timelines ~= nil and timelines.hittimeline or nil,

        events =
        {
            EventHandler("animover", idleonanimover),
        },
    })

    table.insert(states, State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anims ~= nil and anims.attack or (fns and fns.attackanimfn and fns.attackanimfn(inst)) or "atk")
            inst.components.combat:StartAttack()

            --V2C: Cached to force the target to be the same one later in the timeline
            --     e.g. combat:DoAttack(inst.sg.statemem.target)
            inst.sg.statemem.target = target
        end,

        timeline = timelines ~= nil and timelines.attacktimeline or nil,

        onexit = function(inst)
            if fns ~= nil and fns.attackexit ~= nil then
                fns.attackexit(inst)
            end
        end,

        events =
        {
            EventHandler("animover", idleonanimover),
        },
    })

    table.insert(states, State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anims ~= nil and anims.death or "death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline = timelines ~= nil and timelines.deathtimeline or nil,
    })
end

--------------------------------------------------------------------------
CommonStates.AddHitState = function(states, timeline, anim)
    table.insert(states, State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local hitanim =
                (anim == nil and "hit") or
                (type(anim) ~= "function" and anim) or
                anim(inst)

            inst.AnimState:PlayAnimation(hitanim)

            if inst.SoundEmitter ~= nil and inst.sounds ~= nil and inst.sounds.hit ~= nil then
                inst.SoundEmitter:PlaySound(inst.sounds.hit)
            end

			update_hit_recovery_delay(inst)
        end,

        timeline = timeline,

        events =
        {
            EventHandler("animover", idleonanimover),
        },
    })
end

--------------------------------------------------------------------------
CommonStates.AddDeathState = function(states, timeline, anim)
    table.insert(states, State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation(anim or "death")
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline = timeline,
    })

end

--------------------------------------------------------------------------
--V2C: DST improved sleep states that support "nosleep" state tag

local function onsleepex(inst)
    inst.sg.mem.sleeping = true
	if inst.components.health == nil or not inst.components.health:IsDead() then
		if inst.sg:HasStateTag("jumping") and inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() then
			inst.sg:GoToState("sink")
		elseif not (inst.sg:HasStateTag("nosleep") or inst.sg:HasStateTag("sleeping")) then
		    inst.sg:GoToState("sleep")
		end
    end
end

local function onwakeex(inst)
    inst.sg.mem.sleeping = false
    if inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("nowake") and
        not (inst.components.health ~= nil and inst.components.health:IsDead()) then
        inst.sg.statemem.continuesleeping = true
        inst.sg:GoToState("wake")
    end
end

CommonHandlers.OnSleepEx = function()
    return EventHandler("gotosleep", onsleepex)
end

CommonHandlers.OnWakeEx = function()
    return EventHandler("onwakeup", onwakeex)
end

CommonHandlers.OnNoSleepAnimOver = function(nextstate)
    return EventHandler("animover", function(inst)
        if inst.AnimState:AnimDone() then
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            elseif type(nextstate) == "string" then
                inst.sg:GoToState(nextstate)
            elseif nextstate ~= nil then
                nextstate(inst)
            end
        end
    end)
end

CommonHandlers.OnNoSleepTimeEvent = function(t, fn)
    return TimeEvent(t, function(inst)
        if inst.sg.mem.sleeping and not (inst.components.health ~= nil and inst.components.health:IsDead()) then
            inst.sg:GoToState("sleep")
        elseif fn ~= nil then
            fn(inst)
        end
    end)
end

CommonHandlers.OnNoSleepFrameEvent = function(frame, fn)
	return CommonHandlers.OnNoSleepTimeEvent(frame * FRAMES, fn)
end

local function sleepexonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg.statemem.continuesleeping = true
        inst.sg:GoToState(inst.sg.mem.sleeping and "sleeping" or "wake")
    end
end

local function sleepingexonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg.statemem.continuesleeping = true
        inst.sg:GoToState("sleeping")
    end
end

local function wakeexonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState(inst.sg.mem.sleeping and "sleep" or "idle")
    end
end

CommonStates.AddSleepExStates = function(states, timelines, fns)
    table.insert(states, State{
        name = "sleep",
        tags = { "busy", "sleeping", "nowake" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("sleep_pre")
            if fns ~= nil and fns.onsleep ~= nil then
                fns.onsleep(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.starttimeline or nil,

        events =
        {
            EventHandler("animover", sleepexonanimover),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping and inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            if fns ~= nil and fns.onexitsleep ~= nil then
                fns.onexitsleep(inst)
            end
        end,
    })

    table.insert(states, State{
        name = "sleeping",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_loop")
            if fns ~= nil and fns.onsleeping ~= nil then
                fns.onsleeping(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.sleeptimeline or nil,

        events =
        {
            EventHandler("animover", sleepingexonanimover),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping and inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            if fns ~= nil and fns.onexitsleeping ~= nil then
                fns.onexitsleeping(inst)
            end
        end,
    })

    table.insert(states, State{
        name = "wake",
        tags = { "busy", "waking", "nosleep" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("sleep_pst")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            if fns ~= nil and fns.onwake ~= nil then
                fns.onwake(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.waketimeline or nil,

        events =
        {
            EventHandler("animover", wakeexonanimover),
        },

        onexit = fns ~= nil and fns.onexitwake or nil,
    })
end

--------------------------------------------------------------------------

CommonStates.AddFossilizedStates = function(states, timelines, fns)
    table.insert(states, State{
        name = "fossilized",
        tags = { "busy", "fossilized", "caninterrupt" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("fossilized")
            inst.components.fossilizable:OnFossilize(data ~= nil and data.duration or nil, data ~= nil and data.doer or nil)
            if fns ~= nil and fns.fossilized_onenter ~= nil then
                fns.fossilized_onenter(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.fossilizedtimeline or nil,

        events =
        {
            EventHandler("fossilize", function(inst, data)
                inst.components.fossilizable:OnExtend(data ~= nil and data.duration or nil, data ~= nil and data.doer or nil)
            end),
            EventHandler("unfossilize", function(inst)
                inst.sg.statemem.unfossilizing = true
                inst.sg:GoToState("unfossilizing")
            end),
        },

        onexit = function(inst)
            inst.components.fossilizable:OnUnfossilize()
            if not inst.sg.statemem.unfossilizing then
                --Interrupted
                inst.components.fossilizable:OnSpawnFX()
            end
            if fns ~= nil and fns.fossilized_onexit ~= nil then
                fns.fossilized_onexit(inst)
            end
        end,
    })

    table.insert(states, State{
        name = "unfossilizing",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fossilized_shake")
            if fns ~= nil and fns.unfossilizing_onenter ~= nil then
                fns.unfossilizing_onenter(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.unfossilizingtimeline or nil,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.unfossilized = true
                    inst.sg:GoToState("unfossilized")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.unfossilized then
                --Interrupted
                inst.components.fossilizable:OnSpawnFX()
            end
            if fns ~= nil and fns.unfossilizing_onexit ~= nil then
                fns.unfossilizing_onexit(inst)
            end
        end,
    })

    table.insert(states, State{
        name = "unfossilized",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fossilized_pst")
            inst.components.fossilizable:OnSpawnFX()
            if fns ~= nil and fns.unfossilized_onenter ~= nil then
                fns.unfossilized_onenter(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.unfossilizedtimeline or nil,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = fns ~= nil and fns.unfossilized_onexit or nil,
    })
end

--------------------------------------------------------------------------

CommonStates.AddRowStates = function(states, is_client)
    table.insert(states, State{
        name = "row",
        tags = { "rowing", "doing" },

        onenter = function(inst)
            local locomotor = inst.components.locomotor
            local target_pos = nil
            if locomotor.bufferedaction then
                target_pos = locomotor.bufferedaction:GetActionPoint()
                if target_pos == nil then
                    target_pos = locomotor.bufferedaction.target:GetPosition()
                    inst:ForceFacePoint(target_pos:Get())
                end
            else
                target_pos = Vector3(inst.Transform:GetWorldPosition())
            end
            inst:AddTag("is_rowing")
            inst.AnimState:PlayAnimation("row_pre")
            locomotor:Stop()

            local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
            local boat_x, boat_y, boat_z = 0, 0, 0
            local boat = inst:GetCurrentPlatform()
            if boat ~= nil then
                boat_x, boat_y, boat_z = boat.Transform:GetWorldPosition()
            end

            if is_client then
                inst:PerformPreviewBufferedAction()
            end

            local target_x, target_z = nil,nil

            if inst.components.playercontroller.isclientcontrollerattached then
                local dir_x, dir_z = VecUtil_Normalize(my_x - boat_x, my_z - boat_z)
                target_x, target_z = my_x + dir_x, my_z + dir_z
            else
                target_x, target_z = target_pos.x, target_pos.z
            end

            local delta_target_x, delta_target_z = target_x- my_x, target_z - my_z
            local delta_boat_x, delta_boat_z = my_x - boat_x, my_z - boat_z

            local camera_down_vec = TheCamera:GetDownVec()
            local camera_right_vec = TheCamera:GetRightVec()

            local camera_up_x, camera_up_z = -camera_down_vec.x, -camera_down_vec.z
            local camera_right_x, camera_right_z = camera_right_vec.x, camera_right_vec.z

            local delta_target_x_camera, delta_target_z_camera = delta_target_x * camera_right_x + delta_target_z * camera_right_z, delta_target_x * camera_up_x + delta_target_z * camera_up_z
            local delta_boat_x_camera, delta_boat_z_camera = delta_boat_x * camera_right_x + delta_boat_z * camera_right_z, delta_boat_x * camera_up_x + delta_boat_z * camera_up_z

            local target_anim = "row_medium"
            local debug_id = ""
            local is_facing_horizontal = math.abs(delta_target_x_camera) > math.abs(delta_target_z_camera)
            local is_on_upper_half = delta_boat_z_camera > 0
            local is_on_right_side = delta_boat_x_camera > 0
            local is_facing_right = delta_target_x_camera > 0
            local is_facing_up = delta_target_z_camera > 0

            if is_facing_horizontal then
                if is_on_upper_half then
                    if is_facing_right then
                        target_anim = "row_medium_off"
                        debug_id = "is_facing_horizontal, is_on_upper_half, is_facing_right"
                    else
                        target_anim = "row_medium_off"
                        debug_id = "is_facing_horizontal, is_on_upper_half, is_facing_left"
                    end
                else
                    if is_facing_right then
                        target_anim = "row_medium"
                        debug_id = "is_facing_horizontal, is_on_lower_half, is_facing_right"
                    else
                        target_anim = "row_medium"
                        debug_id = "is_facing_horizontal, is_on_lower_half, is_facing_left"
                    end
                end
            else
                if is_on_right_side then
                    if is_facing_up then
                        target_anim = "row_medium"
                        debug_id = "is_facing_vertical, is_on_right_side, is_facing_up"
                    else
                        target_anim = "row_medium_off"
                        debug_id = "is_facing_vertical, is_on_right_side, is_facing_down"
                    end
                else
                    if is_facing_up then
                        target_anim = "row_medium_off"
                        debug_id = "is_facing_vertical, is_on_left_side, is_facing_up"
                    else
                        target_anim = "row_medium"
                        debug_id = "is_facing_vertical, is_on_left_side, is_facing_down"
                    end
                end
            end

            inst.AnimState:PushAnimation(target_anim, false)

            inst:ForceFacePoint(target_x, 0, target_z)
        end,

        onexit = function(inst)
            inst:RemoveTag("is_rowing")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                if not is_client then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
                end
            end),

            TimeEvent(8 * FRAMES, function(inst)
                if not is_client then
                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("rowing")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("row_idle")
            end),
        },

        ontimeout = function(inst)
            if is_client then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end
        end,
    })

    table.insert(states, State{
        name = "row_fail",
        tags = { "busy", "row_fail" },

        onenter = function(inst)
            if is_client then
                inst:PerformPreviewBufferedAction()
            else
                inst:PerformBufferedAction()
            end

            inst:AddTag("is_row_failing")
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("row_fail_pre")
            inst.AnimState:PushAnimation("row_fail", false)
        end,

        onexit = function(inst)
            inst:RemoveTag("is_row_failing")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                if not is_client then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
                end
            end),

            TimeEvent(13 * FRAMES, function(inst)
                if not is_client then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("row_idle")
            end),
        },

        ontimeout = function(inst)
            if is_client then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end
        end,
    })


    table.insert(states, State{
        name = "row_idle",

        onenter = function(inst)
            inst.sg:SetTimeout(4 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("row_idle_pst")
            inst.sg:GoToState("idle", true)
        end,
    })

end

--------------------------------------------------------------------------

local function onsink(inst, data)
    if (inst.components.health == nil or not inst.components.health:IsDead()) and not inst.sg:HasStateTag("drowning") and (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
        inst.sg:GoToState("sink", data)
    end
end

CommonHandlers.OnSink = function()
    return EventHandler("onsink", onsink)
end

local function DoWashAshore(inst, skip_splash)
	if not skip_splash then
		SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end

	inst.sg.statemem.isteleporting = true
	inst:Hide()
	if inst.components.health ~= nil then
		inst.components.health:SetInvincible(true)
	end
	inst.components.drownable:WashAshore()
end

CommonStates.AddSinkAndWashAshoreStates = function(states, anims, timelines, fns)
	anims = anims or {}
	timelines = timelines or {}
	fns = fns or {}

    table.insert(states, State{
        name = "sink",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt", "nowake" },

        onenter = function(inst, data)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

			inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)

			if data ~= nil and data.shore_pt ~= nil then
				inst.components.drownable:OnFallInOcean(data.shore_pt:Get())
			else
				inst.components.drownable:OnFallInOcean()
			end

			if inst.DynamicShadow ~= nil then
			    inst.DynamicShadow:Enable(false)
			end

		    if inst.brain ~= nil then
				inst.brain:Stop()
			end

			local skip_anim = data ~= nil and data.noanim
			if anims.sink ~= nil and not skip_anim then
				inst.sg.statemem.has_anim = true
	            inst.AnimState:PlayAnimation(anims.sink)
			else
				DoWashAshore(inst, skip_anim)
			end

        end,

		timeline = timelines.sink,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.has_anim and inst.AnimState:AnimDone() then
					DoWashAshore(inst)
				end
            end),

            EventHandler("on_washed_ashore", function(inst)
				inst.sg:GoToState("washed_ashore")
			end),
        },

        onexit = function(inst)
			if inst.sg.statemem.collisionmask ~= nil then
				inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
			end

            if inst.sg.statemem.isteleporting then
				if inst.components.health ~= nil then
					inst.components.health:SetInvincible(false)
				end
				inst:Show()
			end

			if inst.DynamicShadow ~= nil then
				inst.DynamicShadow:Enable(true)
			end

			if inst.components.herdmember ~= nil then
				inst.components.herdmember:Leave()
			end

			if inst.components.combat ~= nil then
				inst.components.combat:DropTarget()
			end

		    if inst.brain ~= nil then
				inst.brain:Start()
			end
        end,
    })

	table.insert(states, State{
		name = "washed_ashore",
        tags = { "doing", "busy", "nopredict", "silentmorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if type(anims.washashore) == "table" then
				for i, v in ipairs(anims.washashore) do
					if i == 1 then
			            inst.AnimState:PlayAnimation(v)
					else
			            inst.AnimState:PushAnimation(v, false)
					end
				end
			elseif anims.washashore ~= nil then
				inst.AnimState:PlayAnimation(anims.washashore)
			else
				inst.AnimState:PlayAnimation("sleep_loop")
	            inst.AnimState:PushAnimation("sleep_pst", false)
			end

		    if inst.brain ~= nil then
				inst.brain:Stop()
			end

			if inst.components.drownable ~= nil then
				inst.components.drownable:TakeDrowningDamage()
			end

			local x, y, z = inst.Transform:GetWorldPosition()
			SpawnPrefab("washashore_puddle_fx").Transform:SetPosition(x, y, z)
			SpawnPrefab("splash_green").Transform:SetPosition(x, y, z)
        end,

		timeline = timelines.washashore,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
		    if inst.brain ~= nil then
				inst.brain:Start()
			end
        end,
	})
end

--Backward compatibility for originally mispelt function name
CommonStates.AddSinkAndWashAsoreStates = CommonStates.AddSinkAndWashAshoreStates

--------------------------------------------------------------------------

function PlayMiningFX(inst, target, nosound)
    if target ~= nil and target:IsValid() then
        local frozen = target:HasTag("frozen")
        local moonglass = target:HasTag("moonglass")
        local crystal = target:HasTag("crystal")
        if target.Transform ~= nil then
            SpawnPrefab(
                (frozen and "mining_ice_fx") or
                (moonglass and "mining_moonglass_fx") or
                (crystal and "mining_crystal_fx") or
                "mining_fx"
            ).Transform:SetPosition(target.Transform:GetWorldPosition())
        end
        if not nosound and inst.SoundEmitter ~= nil then
            inst.SoundEmitter:PlaySound(
                (frozen and "dontstarve_DLC001/common/iceboulder_hit") or
                ((moonglass or crystal) and "turnoftides/common/together/moon_glass/mine") or
                "dontstarve/wilson/use_pick_rock"
            )
        end
    end
end

--------------------------------------------------------------------------

local function IpecacPoop(inst)
    if not (inst.sg:HasStateTag("busy") or (inst.components.health ~= nil and inst.components.health:IsDead())) then
        inst.sg:GoToState("ipecacpoop")
    end
end

CommonHandlers.OnIpecacPoop = function()
    return EventHandler("ipecacpoop", IpecacPoop)
end

CommonStates.AddIpecacPoopState = function(states, anim)
    anim = anim or "hit"

    table.insert(states, State{
        name = "ipecacpoop",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("meta2/wormwood/laxative_poot")
            inst.AnimState:PlayAnimation(anim)
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", idleonanimover),
        },
    })
end

--------------------------------------------------------------------------
