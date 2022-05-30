require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.GOHOME, "gohome"),
}
local BEEFALOTEST_MUST_TAGS = {"beefalo"}
local BEEFALOTEST_CANT_TAGS = {"baby"}

local function beefalotest(inst)
    if inst.beefalo_carrat then
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 20, BEEFALOTEST_MUST_TAGS, BEEFALOTEST_CANT_TAGS)
        if #ents > 0 then
            return true
        end
    end
end

local events =
{
    CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("locomote", function(inst)
        -- Just in case we get locomote messages while we're burrowed, or some other unexpected locomotor-less state.
        if inst.components.locomotor ~= nil then
            local is_moving = inst.sg:HasStateTag("moving")
            local is_running = inst.sg:HasStateTag("running")
            local is_idling = inst.sg:HasStateTag("idle")

            local should_move = inst.components.locomotor:WantsToMoveForward()
            local should_run = inst.components.locomotor:WantsToRun()

            if is_moving and not should_move then
                inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
            elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run) then
                inst.sg:GoToState((should_run and "run_start") or "walk_start")
            end
        end
    end),

    EventHandler("trapped", function(inst) inst.sg:GoToState("trapped") end),

    EventHandler("yotc_racer_exhausted", function(inst)
		if (inst.components.health == nil or not inst.components.health:IsDead())
			and not inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("exhausted") then
			inst.sg:GoToState("exhausted")
		end
	end),

    EventHandler("stunbomb", function(inst)
        inst.sg:GoToState("stunned")
    end),
}

local function play_carrat_scream(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.scream)
end

local function GoToPostRaceState(inst)
    if inst.components.yotc_racecompetitor ~= nil and (inst.components.yotc_racecompetitor.racestate == "postrace" or inst.components.yotc_racecompetitor.racestate == "raceover") then
        local trainer = (inst.components.entitytracker ~= nil and inst.components.entitytracker:GetEntity("yotc_trainer")) or nil
		if inst.components.yotc_racecompetitor.race_prize ~= nil then
			if #inst.components.yotc_racecompetitor.race_prize > 1 then
				inst.sg:GoToState("endofrace_rewardlarge")
			else
				inst.sg:GoToState("endofrace_rewardsmall")
			end
		elseif inst.components.yotc_racecompetitor.finished_first then
			inst.sg:GoToState("endofrace_firstplace")
		else
			inst.sg:GoToState("endofrace_notfirstplace")
		end
		return true
	end

	return false
end

local states =
{
    State {
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
			if GoToPostRaceState(inst) then
				return
			end
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle1", true)
            elseif not inst.AnimState:IsCurrentAnimation("idle1") then
                inst.AnimState:PlayAnimation("idle1", true)
            end
            inst.sg:SetTimeout(1 + math.random()*1)
        end,

        ontimeout= function(inst)
            if ((inst.sg.mem.emerge_time or 0) + TUNING.CARRAT.EMERGED_TIME_LIMIT) < GetTime() and not beefalotest(inst) then
                inst.sg:GoToState("submerge")
            elseif math.random() > 0.55 then
                inst.sg:GoToState("idle2")
            else
                inst.sg:GoToState("idle")
            end
        end,
    },

    State {
        name = "idle2",
        tags = { "idle", "canrotate" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle2", false)
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.idle)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State {
        name = "submerge",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            if not inst:IsOnValidGround() then
                inst.sg:GoToState("idle")
                return
            end

            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.Physics:Stop()
            inst.Physics:SetActive(false)

            -- Ensure that we're facing to the right, to match what a planted carrat looks like after
            -- submerging. This prevents us from flipping much more obviously after we've prefabbed swapped
            -- in the "submerged" state.
            inst.Transform:SetNoFaced()

            inst.AnimState:PlayAnimation("submerge")
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.submerge)
            end),
            TimeEvent(30*FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("submerged")
            end),
        },

        onexit = function(inst)
            inst.Physics:SetActive(true)
            inst.Transform:SetSixFaced()
        end,
    },

    State {
        name = "submerged",
        tags = { "busy", "noattack" },

        onenter = function(inst, playanim)
            inst.Physics:SetActive(false)
            inst.Transform:SetNoFaced()

            inst.AnimState:PlayAnimation("planted")
            if inst.GoToSubmerged ~= nil then
                inst:GoToSubmerged()
            else
                -- Shadow carrats for the yotc race might come through here, so clean them up.
                inst:Remove()
            end
        end,

        onexit = function(inst)
            inst.Physics:SetActive(true)
            inst.Transform:SetSixFaced()
        end,
    },

    State {
        name = "emerge_fast",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.Physics:SetActive(false)
            inst.AnimState:PlayAnimation("emerge_fast")

            inst.sg.mem.emerge_time = GetTime()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.emerge)
            end),
            TimeEvent(5*FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
            end),
        },

        onexit = function(inst)
            inst.Physics:SetActive(true)
        end,
    },

    State {
        name = "eat",
		tags = {"busy"},

        onenter = function(inst)
            inst.Physics:SetActive(false)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre", false)
            inst.AnimState:PushAnimation("eat_loop", false)
            inst.AnimState:PushAnimation("eat_pst", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if beefalotest(inst) then
                    inst.sg:GoToState("idle")
                elseif inst.AnimState:AnimDone() then
                    inst.sg:GoToState("submerge")
                end
            end),
        },

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.eat)
            end),
            TimeEvent(25*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        onexit = function(inst)
            inst.Physics:SetActive(true)
        end,
    },

    State {
        name = "stunned",
        tags = { "busy", "stunned" },

        onenter = function(inst, dont_play_sound)
            inst.Physics:Stop()
            if not dont_play_sound then
                inst.SoundEmitter:PlaySound(inst.sounds.stunned)
            end
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(GetRandomWithVariance(6, 2))
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = true
            end
        end,

        onexit = function(inst)
            if inst.components.inventoryitem then
                inst.components.inventoryitem.canbepickedup = false
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "stunned_pst")
        end,
    },

    State {
        name = "trapped",
        tags = { "busy", "trapped" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("stunned_loop", true)
            inst.sg:SetTimeout(1)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State {
        name = "dug_up",
        tags = { "busy", "stunned" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.stunned)
            inst.AnimState:PlayAnimation("stunned_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("stunned", true)
                end
            end),
        },

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
            end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            if inst._is_burrowed then
                inst:Remove()
            else
                -- If we're not burrowed, do the "normal" thing.
                if inst.components.locomotor ~= nil then
                    inst.components.locomotor:StopMoving()
                end

                inst.AnimState:PlayAnimation("death")
                RemovePhysicsColliders(inst)
                inst.components.lootdropper:DropLoot(inst:GetPosition())
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.death) end),
        },
    },

    State {
        name = "alert",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
			if GoToPostRaceState(inst) then
				return
			end

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle1", true)

            inst.sg.statemem.best_stats = (inst.components.yotc_racestats ~= nil and inst.components.yotc_racestats:GetBestStats()) or {1, 2, 3, 4}

            inst.sg:SetTimeout(math.random() * 2 + 3)
        end,

        ontimeout = function(inst)
            local best_stat = inst.sg.statemem.best_stats[math.random(#inst.sg.statemem.best_stats)]
            if best_stat == 1 then
                inst.sg:GoToState("alert_speed")
            elseif best_stat == 2 then
                inst.sg:GoToState("alert_direction")
            elseif best_stat == 3 then
                inst.sg:GoToState("alert_reaction")
            elseif best_stat == 4 then
                inst.sg:GoToState("alert_stamina")
            else
                inst.sg:GoToState("alert")
            end
        end,
    },

    State {
        name = "endofrace_rewardlarge",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give_big_pre")
            inst.AnimState:PushAnimation("give_big_loop", true)
		end,

        timeline =
        {
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.submerge) end),
        },
    },

    State {
        name = "endofrace_rewardsmall",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give_small_pre")
			inst.AnimState:PushAnimation("give_small_loop", true)
		end,

        timeline =
        {
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.emerge, "lift") end),
		},

        onexit = function(inst)
			inst.SoundEmitter:KillSound("lift")
        end,
    },

    State {
        name = "endofrace_firstplace",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("victory_pre")
            inst.AnimState:PushAnimation("victory_loop", false)
            inst.AnimState:PushAnimation("victory_post", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("alert")
            end),
		},

        timeline =
        {
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.emerge) end),
        },
    },

    State {
        name = "endofrace_notfirstplace",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("lose_small_pre")
			inst.AnimState:PushAnimation("lose_small_loop", false)
            inst.AnimState:PushAnimation("small_big_trans", false)
            inst.AnimState:PushAnimation("lose_big_loop", false)
            inst.AnimState:PushAnimation("lose_big_loop", false)
            inst.AnimState:PushAnimation("lose_big_loop", false)
            inst.AnimState:PushAnimation("lose_big_post", false)
		end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("alert")
            end),
		},

        timeline =
        {
			TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.emerge) end),
			TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction)end),
			TimeEvent(45*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(50*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stunned, "cry") end),
        },

        onexit = function(inst)
			inst.SoundEmitter:KillSound("cry")
        end,
    },

    State {
        name = "alert_speed",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("speed")

			inst.sg.statemem.step_sound_task = inst:DoPeriodicTask(4*FRAMES, function() inst.SoundEmitter:PlaySound(inst.sounds.step) end)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("alert")
                end
            end),
		},

        timeline =
        {
			TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.emerge) end),

			TimeEvent(70*FRAMES, function(inst)
				if inst.sg.statemem.step_sound_task ~= nil then
					inst.sg.statemem.step_sound_task:Cancel()
					inst.sg.statemem.step_sound_task = nil
				end
			end),
		},

        onexit = function(inst)
			if inst.sg.statemem.step_sound_task ~= nil then
				inst.sg.statemem.step_sound_task:Cancel()
				inst.sg.statemem.step_sound_task = nil
			end
        end,
    },

    State {
        name = "alert_direction",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("direction")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("alert")
                end
            end),
		},

        timeline =
        {
			TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.emerge) end),
			TimeEvent(100*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
        },
    },

    State {
        name = "alert_reaction",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("reaction")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("alert")
                end
            end),
		},

        timeline =
        {
			TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.eat) end),
			TimeEvent(89*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.eat) end),
			TimeEvent(100*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.eat) end),
        },
    },

    State {
        name = "alert_stamina",
        tags = { "idle", "canrotate", "alert" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("stamina")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("alert")
                end
            end),
		},

        timeline =
        {
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
			TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
			TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.emerge) end),
			TimeEvent(56*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.step) end),
			TimeEvent(75*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.reaction) end),
        },
    },

    State {
        name = "exhausted",
        tags = { "exhausted" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("exhausted_pre", false)
        end,

        timeline =
        {
           TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.submerge) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("exhausted_loop")
            end),
        },
    },

    State {
        name = "exhausted_loop",
        tags = { "exhausted" },
        onenter = function(inst, count)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("exhausted_loop")
        end,

        timeline =
        {
--            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.idle) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst.components.yotc_racecompetitor ~= nil and inst.components.yotc_racecompetitor:IsExhausted() then
	                inst.sg:GoToState("exhausted_loop")
				else
					if inst.components.yotc_racestats ~= nil and inst.components.sleeper ~= nil and inst.components.yotc_racestats:GetStaminaModifier() == 0 and math.random() < TUNING.YOTC_RACER_STAMINA_SLEEP_CHANCE then
                        inst:PushEvent("carrat_error_sleeping")
						inst.components.sleeper:GoToSleep(TUNING.YOTC_RACER_STAMINA_SLEEP_TIME + math.random() * TUNING.YOTC_RACER_STAMINA_SLEEP_TIME_VAR)
					end
	                inst.sg:GoToState("exhausted_pst")
				end
            end),
        },
    },

    State {
        name = "exhausted_pst",
        tags = { "exhausted" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("exhausted_pst", false)
        end,

        timeline =
        {
--            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.idle) end),
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

    State {
        name = "race_start_startle",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },
    },

    State {
        name = "race_start_stunned",
        tags = { "busy", "stunned" },

        onenter = function(inst, stun_loops)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit_stun_trans")
			inst.sg.statemem.stun_loops = stun_loops or 1
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst) inst.sg:GoToState("race_startstunned_loop", inst.sg.statemem.stun_loops) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("race_startstunned_loop", inst.sg.statemem.stun_loops)
				end
			end),
        },
    },

    State {
        name = "race_startstunned_loop",
        tags = { "busy", "stunned" },

        onenter = function(inst, stun_loops)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_loop")
			inst.sg.statemem.stun_loops = stun_loops
        end,

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.stun_loops = inst.sg.statemem.stun_loops - 1
					if inst.sg.statemem.stun_loops > 0 then
						inst.sg:GoToState("race_startstunned_loop", inst.sg.statemem.stun_loops)
					else
						inst.sg:GoToState("race_startstunned_pst")
					end
				end
			end),
        },
    },

    State {
        name = "race_startstunned_pst",
        tags = { "busy", "stunned" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("stunned_pst")
            inst.AnimState:PushAnimation("idle2", false)
            inst.AnimState:PushAnimation("idle2", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
        },
    },

    State {
        name = "gohome",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle1", true)
            local action = inst:GetBufferedAction()
            if action.target and not action.target:HasTag("HasCarrat") then
                inst:PerformBufferedAction()
            else
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end
        end,
    },

    State{
        name = "fall",
        tags = {"busy", "stunned"},

        onenter = function(inst)
            inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0, (math.random() * 10) - 20, 0)
            inst.AnimState:PlayAnimation("stunned_loop", true)
        end,

        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
                inst.Physics:SetMotorVel(0,0,0)
            end

            if pt.y <= .1 then
                pt.y = 0

                inst.Physics:Stop()
                inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x, pt.y, pt.z)
                inst.DynamicShadow:Enable(true)

                inst.sg:GoToState("stunned")
            end
        end,

        onexit = function(inst)
            local pt = inst:GetPosition()
            pt.y = 0
            inst.Transform:SetPosition(pt:Get())
        end,
    },
}
CommonStates.AddSleepExStates(states,
{
    sleeptimeline =
    {
        TimeEvent(11 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
})
CommonStates.AddFrozenStates(states)
CommonStates.AddHitState(states)
CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(3*FRAMES, function(inst) PlayFootstep(inst)
            --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
        end),
    },
    walktimeline =
    {
        TimeEvent(1*FRAMES, function(inst) PlayFootstep(inst)
            --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
        end),
        TimeEvent(3*FRAMES, function(inst) PlayFootstep(inst)
            --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
        end),
        TimeEvent(5*FRAMES, function(inst) PlayFootstep(inst)
            --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
        end),
        TimeEvent(7*FRAMES, function(inst) PlayFootstep(inst)
            --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
        end),
    },
    endtimeline =
    {
        TimeEvent(0*FRAMES, function(inst) PlayFootstep(inst)
            --inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
        end),
    },
})
CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            if (inst.components.inventoryitem == nil or inst.components.inventoryitem.owner == nil) then
                inst.SoundEmitter:PlaySound(inst.sounds.stunned)
            end
        end),
    },
    runtimeline =
    {
        TimeEvent(0, PlayFootstep),
    },
    endtimeline =
    {
        TimeEvent(0, PlayFootstep),
    },
})

return StateGraph("carrat", states, events, "emerge_fast", actionhandlers)
