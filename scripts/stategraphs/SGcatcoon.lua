require("stategraphs/commonstates")

--hiss_pre, vomit, swipe_pre

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, function(inst) return inst.raining and "gohome_raining" or "gohome" end),
    ActionHandler(ACTIONS.HAIRBALL, "hairball_hack"),
    ActionHandler(ACTIONS.CATPLAYGROUND, "pawgroundaction"),
    ActionHandler(ACTIONS.CATPLAYAIR, "pounceplayaction"),
}

local events=
{
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
    EventHandler("doattack", function(inst, data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            if data.target:HasTag("cattoyairborne") then
                if data.target.sg and (data.target.sg:HasStateTag("landing") or data.target.sg:HasStateTag("landed")) then
                    inst.components.combat:SetTarget(nil)
                else
                    inst.sg:GoToState("pounceplay", data.target)
                end
            elseif data.target and data.target:IsValid() and inst:GetDistanceSqToInst(data.target) > TUNING.CATCOON_MELEE_RANGE*TUNING.CATCOON_MELEE_RANGE then
                inst.sg:GoToState("pounceattack", data.target)
            else
                inst.sg:GoToState("attack", data.target)
            end
        end
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
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
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "gohome_raining",
		tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt_pre")
            inst.AnimState:PushAnimation("taunt", false)
            inst.AnimState:PushAnimation("taunt_pst", false)
        end,

        onexit = function(inst)

        end,

        timeline =
        {
            --TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss_pre") end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss") end)
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "gohome",
		tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("action")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(13*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(20*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(27*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(34*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(37*FRAMES, function(inst) inst:PerformBufferedAction() inst.sg:GoToState("idle") end),
        },
    },	
	
	State{
		name = "hairball_hack",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("furball_pre_loop")
            inst.numretches = 1
		end,

		onexit = function(inst)

		end,

		timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hairball_hack") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
                if math.random() <= .25 then
                    inst.sg:GoToState("hairball")
                else
                    inst.sg:GoToState("hairball_hack_loop")
                end
            end),
		},
	},

    State{
        name = "hairball_hack_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("furball_pre_loop")
            inst.numretches = inst.numretches + 1
        end,

        onexit = function(inst)

        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hairball_hack") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                local neutralmax = inst.neutralGiftPrefabs and #inst.neutralGiftPrefabs or 7
                local friendmax = inst.friendGiftPrefabs and #inst.friendGiftPrefabs or 7
                local MAX_RETCHES = (inst.components.follower and inst.components.follower.leader) and friendmax or neutralmax
                local rand = math.random()
                --print("Retching:", inst.numretches, .8/inst.numretches, rand)
                if inst.numretches >= MAX_RETCHES or rand < (.8/inst.numretches) then
                    inst.sg:GoToState("hairball")
                else
                    inst.sg:GoToState("hairball_hack_loop")
                end
            end),
        },
    },

    State{
        name = "hairball",
        tags = {"busy", "hairball"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("furball", false)
            inst.hairballfollowup = math.random() <= .75
            if inst.hairballfollowup then
                inst.AnimState:PushAnimation("idle_loop", false)
                inst.AnimState:PushAnimation("action", false)
            end
        end,

        onexit = function(inst)

        end,

        timeline =
        {
            TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hairball_vomit") end),
            TimeEvent(46*FRAMES, function(inst)
                inst.vomit = SpawnPrefab(inst:PickRandomGift(inst.numretches))
				if inst.vomit ~= nil then
					local downvec = TheCamera:GetDownVec()
					local face = math.atan2(downvec.z, downvec.x) * (180/math.pi)
					local pos = inst:GetPosition() + downvec:Normalize()
					inst.Transform:SetRotation(-face)

					inst.vomit.Transform:SetPosition(pos.x, pos.y, pos.z)
					if inst.vomit.components.inventoryitem and inst.vomit.components.inventoryitem.ondropfn then
						inst.vomit.components.inventoryitem.ondropfn(inst.vomit)
					end
					if inst.vomit.components.weighable ~= nil then
						inst.vomit.components.weighable.prefab_override_owner = inst.prefab
					end

					local cur_time = GetTime()

					if IsSpecialEventActive(SPECIAL_EVENTS.YOT_CATCOON) then
						local redpouch = SpawnPrefab("redpouch_yot_catcoon")
						local lucky_nugget = SpawnPrefab("lucky_goldnugget")
						redpouch.components.unwrappable:WrapItems({lucky_nugget})
						lucky_nugget:Remove()

						redpouch.Transform:SetPosition(pos.x + 0.2, pos.y, pos.z + 0.1)
					end

					inst.last_hairball_time = cur_time
				end


                inst:PerformBufferedAction()
            end),
            TimeEvent(118*FRAMES, function(inst)
                if inst.hairballfollowup and math.random() <= .5 then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
                end
            end),
            TimeEvent(140*FRAMES, function(inst)
                if inst.hairballfollowup and inst.vomit and inst.vomit:IsValid() and inst:GetDistanceSqToInst(inst.vomit) <= 3 and math.random() <= (TUNING.CATCOON_PICKUP_ITEM_CHANCE / 3) then
                    if not inst.vomit:HasTag("INLIMBO") then
                        inst.vomit:Remove()
                    end
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if not inst.hairballfollowup and math.random() <= .5 then
                    inst:DoTaskInTime(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup") end)
                end
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "pawground",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("action")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup")
        end,

        onexit = function(inst)

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

    State{
        name = "pawgroundaction",
        tags = {"busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("action")
            if math.random() < .5 then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pickup") end
        end,

        onexit = function(inst)

        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(13*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(20*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(22*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(27*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(34*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(42*FRAMES, function(inst) PlayFootstep(inst) end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "pounceplayaction",
        tags = {"canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.target = target
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jump_grab")
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pounce_pre") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pounce") end),
            TimeEvent(26*FRAMES, function(inst) inst.Physics:SetMotorVelOverride(7,0,0) end),
            TimeEvent(31*FRAMES, function(inst) inst:PerformBufferedAction() end),
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
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/hiss") end)
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "pounceattack",
        tags = {"attack", "canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("jump_atk")
            inst.hiss = (target:HasTag("smallcreature") and math.random() <= .5)
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/attack") end),
            TimeEvent(6*FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(12,0,0)
                -- When the catcoon jumps, check if the target is a bird. If so, roll a chance for the bird to fly away
                local isbird = inst.components.combat and inst.components.combat.target and inst.components.combat.target:HasTag("bird")
                if isbird and math.random() > TUNING.CATCOON_ATTACK_CONNECT_CHANCE then
                    inst.components.combat.target:PushEvent("threatnear")
                end
            end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/jump") end),
            TimeEvent(19*FRAMES, function(inst) inst.components.combat:DoAttack() end),
            TimeEvent(20*FRAMES,
                function(inst)
                    inst.Physics:ClearMotorVelOverride()
                    inst.components.locomotor:Stop()
                end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.hiss then
                    inst.hiss = false
                    inst.sg:GoToState("hiss")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "pounceplay",
        tags = {"canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.target = target
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("jump_grab")
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pounce_pre") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/pounce") end),
            TimeEvent(26*FRAMES, function(inst) inst.Physics:SetMotorVelOverride(7,0,0) end),
            TimeEvent(31*FRAMES, function(inst)
                if inst.target ~= nil and (inst.target:HasTag("balloon") or inst.target:HasTag("bird")) and math.random() < (TUNING.CATCOON_ATTACK_CONNECT_CHANCE * 2) then
                    inst.components.combat:DoAttack()
                    inst.hiss = true
                elseif inst.target and inst.target:IsValid() and math.random() <= (TUNING.CATCOON_ATTACK_CONNECT_CHANCE * 1.5) and inst:GetDistanceSqToInst(inst.target) <= 3 then
                    inst.components.combat:DoAttack()
                end
            end),
            TimeEvent(39*FRAMES,
                function(inst)
                    inst.Physics:ClearMotorVelOverride()
                    inst.components.locomotor:Stop()
                end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                inst.target = nil
                if inst.hiss then
                    inst.hiss = false
                    inst.sg:GoToState("hiss")
                else
                    inst.sg:GoToState("idle")
                end
            end),
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
CommonStates.AddHopStates(states, true, {pre = "walK_pre", loop = "jump_atk", pst = "walk_pst"})
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("catcoon", states, events, "idle", actionhandlers)
