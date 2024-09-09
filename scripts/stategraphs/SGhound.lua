--------------------------------------------------------------------------
-- *** WARNING ***
--  This stategraph is also used by warglet, which uses wargbrain
--------------------------------------------------------------------------

require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.EAT, function(inst)
		return inst.sg:HasStateTag("chewing") and "eat_from_loop" or "eat"
	end),
}

local function TryHowl(inst)
	--warglet howl spawns hounds like a warg does
	inst.sg:GoToState("howl", inst.NumHoundsToSpawn ~= nil and { howl = true } or nil)
	return true
end

local events =
{
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death", inst.sg.statemem.dead)
    end),
    EventHandler("doattack", function(inst, data)
        if not inst.components.health:IsDead() and
                (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack", data.target)
        end
    end),

	--warglet needs this, since it uses wargbrain
	EventHandler("dohowl", function(inst)
		if not inst.components.health:IsDead() then
			if inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy") then
				TryHowl(inst)
			else
				inst.sg.mem.dohowl = true
			end
		end
	end),

    CommonHandlers.OnSleep(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnFreeze(),

    EventHandler("startle", function(inst)
        if not (inst.sg:HasStateTag("startled") or
                inst.sg:HasStateTag("statue") or
                inst.components.health:IsDead() or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            inst.components.combat:SetTarget(nil)
            inst.sg:GoToState("startle")
        end
    end),

    EventHandler("heardwhistle", function(inst, data)
        if not (inst.sg:HasStateTag("statue") or
                inst.components.health:IsDead() or
                (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())) then
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
                inst.components.combat:SetTarget(nil)
            else
                if inst.components.combat:TargetIs(data.musician) then
                    inst.components.combat:SetTarget(nil)
                end
                if not inst.sg:HasStateTag("howling") then
                    inst.sg:GoToState("howl", {count =2} )
                end
            end
        end
    end),

	EventHandler("chomp", function(inst, data)
		if data ~= nil and data.target ~= nil and not inst.components.health:IsDead() then
			if inst.sg:HasStateTag("chewing") then
				inst.sg:GoToState("chomp_pre_from_loop", data.target)
			elseif not inst.sg:HasStateTag("busy") then
				inst.sg:GoToState("chomp_pre", data.target)
			end
		end
	end),

    --Moon hounds
    EventHandler("workmoonbase", function(inst, data)
        if data ~= nil and data.moonbase ~= nil and
                not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("workmoonbase", data.moonbase)
        end
    end),

    --Clay hounds
    EventHandler("becomestatue", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("transformstatue")
        end
    end),
}

local function SpawnHound(inst)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil then
        local num = inst:NumHoundsToSpawn()
        if inst.max_hound_spawns then
            num = math.min(num,inst.max_hound_spawns)
            inst.max_hound_spawns = inst.max_hound_spawns - num
        end
        local pt = inst:GetPosition()
        for i = 1, num do
            local hound = hounded:SummonSpawn(pt)
            if hound ~= nil and hound.components.follower ~= nil then
                hound.components.follower:SetLeader(inst)
            end
        end
    end
end

local function PlayClayShakeSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/stone_shake", nil, .6)
end

local function PlayClayFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/clayhound/footstep_hound")
end

local function StartAura(inst)
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
end

local function StopAura(inst)
    inst.components.sanityaura.aura = 0
end

local function ShowEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(true)
    end
end

local function HideEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(false)
    end
end

local function MakeStatue(inst)
    if not inst.sg.mem.statue then
        inst.sg.mem.statue = true
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:Stop()
        ChangeToObstaclePhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:AddTag("notarget")
        inst.components.health:SetInvincible(true)

        --Snap to nearest 45 degrees + 15 degree offset for better facing update during camera rotation
        inst.Transform:SetRotation(math.floor(inst.Transform:GetRotation() / 45 + .5) * 45 + 15)
    end
end

local function MakeReanimated(inst)
    if inst.sg.mem.statue then
        inst.sg.mem.statue = nil
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.Physics:SetMass(10)
        ChangeToCharacterPhysics(inst)
        inst.Physics:Teleport(x, 0, z)
        inst:RemoveTag("notarget")
        inst.components.health:SetInvincible(false)
    end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
			if inst.sg.mem.dohowl and TryHowl(inst) then
				return
			end
            inst.SoundEmitter:PlaySound(inst.sounds.pant)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(2*math.random()+.5)
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {

            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if math.random() < .333 then
                    inst.components.combat:SetTarget(nil)
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle", "atk_pst")
                end
            end),
        },
    },

	State{
		name = "eat",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.attack)
			local buffaction = inst:GetBufferedAction()
			local target = buffaction.target
			if target ~= nil and target:IsValid() then
				inst.components.combat:StartAttack()
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				inst.sg:GoToState("eat_timeline_from_frame6")
			end),
		},
	},

	State{
		name = "eat_from_loop",

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.components.combat:StartAttack()
			inst.AnimState:PlayAnimation("eat_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, 0.5)
			local buffaction = inst:GetBufferedAction()
			local target = buffaction.target
			if target ~= nil and target:IsValid() then
				inst.components.combat:StartAttack()
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst.AnimState:SetFrame(6)
			inst.sg:GoToState("eat_timeline_from_frame6")
		end,
	},

	State{
		name = "eat_timeline_from_frame6",
		tags = { "busy" },

		timeline =
		{
			FrameEvent(14 - 6, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bite) end),
			FrameEvent(16 - 6, function(inst)
				if inst:PerformBufferedAction() then
					inst.sg:AddStateTag("chewing")
					inst.SoundEmitter:PlaySound("rifts3/chewing/hounds", "loop")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.chewing = true
					inst.sg:GoToState(inst.sg:HasStateTag("chewing") and "eat_chewing" or "eat_pst")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.chewing then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "eat_chewing",
		tags = { "chewing", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_loop")
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("rifts3/chewing/hounds", "loop")
			end
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				inst.sg:AddStateTag("caninterrupt")
				inst.sg:AddStateTag("wantstoeat")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.chewing = true
					inst.sg:GoToState("eat_pst", true)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.chewing then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "eat_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst, chewing)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pst")
			if chewing then
				inst.sg:AddStateTag("chewing")
				inst.sg:AddStateTag("wantstoeat")
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				if inst.sg.mem.dohowl and TryHowl(inst) then
					return
				elseif inst.sg:HasStateTag("chewing") then --eat success
					inst.components.combat:SetTarget(nil)
					inst.sg:GoToState("taunt")
				else
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("chewing")
					inst.sg:AddStateTag("idle")
					inst.sg:AddStateTag("canrotate")
					inst.SoundEmitter:KillSound("loop")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	State{
		name = "chomp_pre",
		tags = { "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.attack)
			if target ~= nil and target:IsValid() then
				inst.components.combat:StartAttack()
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.target = target
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				inst.sg:GoToState("chomp_pre_timeline_from_frame6", inst.sg.statemem.target)
			end),
		},
	},

	State{
		name = "chomp_pre_from_loop",

		onenter = function(inst, target)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pre")
			inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, 0.5)
			if target ~= nil and target:IsValid() then
				inst.components.combat:StartAttack()
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			else
				target = nil
			end
			inst.AnimState:SetFrame(6)
			inst.sg:GoToState("chomp_pre_timeline_from_frame6", target)
		end,
	},

	State{
		name = "chomp_pre_timeline_from_frame6",
		tags = { "busy" },

		onenter = function(inst, target)
			inst.sg.statemem.target = target
		end,

		timeline =
		{
			FrameEvent(14 - 6, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bite) end),
			FrameEvent(16 - 6, function(inst)
				local target = inst.sg.statemem.target
				if target ~= nil and target:IsValid() and
					inst:IsNear(target, inst.components.combat:GetHitRange() + target:GetPhysicsRadius(0))
				then
					target:PushEvent("chomped", { eater = inst, amount = inst.chomp_power or 1 })
					inst.SoundEmitter:PlaySound("rifts3/chewing/hounds", "loop")
				else
					inst.sg.statemem.target = nil
				end
				inst:ClearBufferedAction()
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.chewing = true
					inst.sg:GoToState(inst.sg.statemem.target ~= nil and "chomp_loop" or "chomp_pst")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.chewing then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "chomp_loop",
		tags = { "chewing", "busy", "caninterrupt" },

		onenter = function(inst, numlooped)
			inst.sg.statemem.numlooped = numlooped or 1
			inst.components.locomotor:StopMoving()
			if not inst.AnimState:IsCurrentAnimation("eat_loop") then
				inst.AnimState:PlayAnimation("eat_loop", true)
			end
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("rifts3/chewing/hounds", "loop")
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		ontimeout = function(inst)
			inst.sg.statemem.chewing = true
			if inst.sg.statemem.numlooped > 1 and inst.sg.mem.dohowl then
				inst.sg:GoToState("chomp_pst")
			elseif inst.sg.statemem.numlooped == 2 and math.random() < 0.25 then
				inst.sg:GoToState("chomp_pst", true)
				inst.sg.statemem.forcetaunt = true
			elseif inst.sg.statemem.numlooped < 4 then
				inst.sg:GoToState("chomp_loop", inst.sg.statemem.numlooped + 1)
			else
				inst.sg:GoToState("chomp_pst", true)
			end
		end,

		onexit = function(inst)
			if not inst.sg.statemem.chewing then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "chomp_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst, caninterrupt)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pst")
			--NOTE: inst.sg.statemem.forcetaunt comes from "chomp_loop"
		end,

		timeline =
		{
			FrameEvent(6, function(inst) inst.SoundEmitter:KillSound("loop") end),
			FrameEvent(8, function(inst)
				if inst.sg.mem.dohowl and TryHowl(inst) then
					return
				elseif inst.sg.statemem.forcetaunt or math.random() < 0.25 then
					inst.components.combat:SetTarget(nil)
					inst.sg:GoToState("taunt")
					return
				end
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("idle")
				inst.sg:AddStateTag("canrotate")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "startle",
        tags = { "busy", "startled" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("scared_pre")
            inst.AnimState:PushAnimation("scared_loop", true)
            inst.SoundEmitter:PlaySound(inst.components.combat.hurtsound)
            inst.sg:SetTimeout(.8 + .3 * math.random())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "scared_pst")
        end,
    },

    State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst, norepeat)
            if inst:HasTag("clay") then
                inst.sg:GoToState("howl", {count = norepeat and -1 or 0})
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("taunt")
                inst.sg.statemem.norepeat = norepeat
            end
        end,

        timeline =
        {
            FrameEvent(13, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bark) end),
            FrameEvent(24, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.bark) end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.sg.statemem.norepeat and math.random() < .333 then
                    inst.sg:GoToState("taunt", inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("player"))
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "howl",
        tags = { "busy", "howling" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("howl")
            if data.howl == true then
                inst.sg.statemem.spawnhounds = true
            else
                inst.sg.statemem.count = data.count or 0
            end
			inst.sg.mem.dohowl = nil
        end,

        timeline =
        {
            FrameEvent(0, function(inst)
                inst.SoundEmitter:PlaySound(inst.sounds.howl)
            end),
            FrameEvent(10, function(inst)
                if inst.sg.statemem.spawnhounds then
                    SpawnHound(inst)
                end
            end),
        },

        events =
        {
            EventHandler("heardwhistle", function(inst)
                inst.sg.statemem.count = 2
            end),
            EventHandler("animover", function(inst)
                if inst.sg.statemem.spawnhounds then
                    inst.sg:GoToState("idle")
                elseif inst.sg.statemem.count > 0 then
                    inst.sg:GoToState("howl", {count= inst.sg.statemem.count > 1 and inst.sg.statemem.count - 1 or -1})
                elseif inst.sg.statemem.count == 0 and math.random() < 0.333 then
                    inst.sg:GoToState("howl", {
                        count = (inst.components.follower.leader ~= nil
                            and inst.components.follower.leader:HasTag("player")
                            and -1) or 0
                        })
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst, reanimating)
            if reanimating then
                inst.AnimState:Pause()
			elseif inst.death_shatter then
				inst.AnimState:PlayAnimation("death_shatter")
			else
				inst.AnimState:PlayAnimation("death")
				if inst.components.amphibiouscreature ~= nil and inst.components.amphibiouscreature.in_water then
					inst.AnimState:PushAnimation("death_idle", true)
				end
			end
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            if inst:HasTag("clay") then
                inst.sg.statemem.clay = true
                HideEyeFX(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
            end
            inst.SoundEmitter:PlaySound(inst.sounds.death)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
            FrameEvent(11, function(inst)
                if inst.sg.statemem.clay then
                    PlayClayFootstep(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst._CanMutateFromCorpse ~= nil and inst:_CanMutateFromCorpse() then
					local corpse = SpawnPrefab("houndcorpse")
					corpse.Transform:SetPosition(inst.Transform:GetWorldPosition())
					corpse.Transform:SetRotation(inst.Transform:GetRotation())
					corpse.AnimState:MakeFacingDirty() -- Not needed for clients.
					if inst.wargleader ~= nil and
                            not inst.wargleader.components.health:IsDead()
                            and inst.wargleader:IsValid() then
						corpse:RememberWargLeader(inst.wargleader)
					end
					inst:Remove()
				end
            end),
        },


        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
            if inst.sg.statemem.clay then
                ShowEyeFX(inst)
            end
        end,
    },

    State{
        name = "forcesleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_loop", true)
        end,
    },

    --Moon hound
    State{
        name = "workmoonbase",
        tags = { "busy", "working" },

        onenter = function(inst, moonbase)
            inst.sg.statemem.moonbase = moonbase
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {
            FrameEvent(16, function(inst)
                local moonbase = inst.sg.statemem.moonbase
                if moonbase ~= nil and
                        moonbase.components.workable ~= nil and
                        moonbase.components.workable:CanBeWorked() then
                    moonbase.components.workable:WorkedBy(inst, 1)
                    SpawnPrefab("mining_fx").Transform:SetPosition(moonbase.Transform:GetWorldPosition())
                    inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_stone_wall_sharp")
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.components.combat:SetTarget(nil)
                if math.random() < .333 then
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle", "atk_pst")
                end
            end),
        },
    },

    State{
        name = "reanimate",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.sg.statemem.taunted = data.anim == "taunt"
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(data.anim)
            inst.AnimState:Pause()
			if data.frame ~= nil then
				inst.AnimState:SetFrame(data.frame)
			elseif data.time ~= nil then
                inst.AnimState:SetTime(data.time)
            end
            inst.sg.statemem.dead = data.dead
        end,

        timeline =
        {
            TimeEvent(TUNING.GARGOYLE_REANIMATE_DELAY, function(inst)
                if not inst:IsInLimbo() then
                    inst.AnimState:Resume()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.taunted and "idle" or "taunt")
            end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },

    --Clay hound
    State{
        name = "statue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            HideEyeFX(inst)
            StopAura(inst)
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("idle_statue")
        end,

        events =
        {
            EventHandler("reanimate", function(inst, data)
                inst.sg.statemem.statue = true
                inst.sg:GoToState("reanimatestatue", data ~= nil and data.target or nil)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.statue then
                MakeReanimated(inst)
                ShowEyeFX(inst)
                StartAura(inst)
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "reanimatestatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst, target)
            MakeStatue(inst)
            ShowEyeFX(inst)
            StartAura(inst)
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("statue_pst")
            inst.sg.statemem.target = target
        end,

        timeline =
        {
            FrameEvent(2, PlayClayShakeSound),
            FrameEvent(4, PlayClayShakeSound),
            FrameEvent(6, PlayClayShakeSound),
            FrameEvent(8, PlayClayShakeSound),
            FrameEvent(10, PlayClayShakeSound),
            FrameEvent(12, PlayClayShakeSound),
            FrameEvent(14, function(inst)
                PlayClayShakeSound(inst)
                PlayClayFootstep(inst)
            end),
            FrameEvent(16, PlayClayShakeSound),
            FrameEvent(41, PlayClayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            MakeReanimated(inst)
            if inst.sg.statemem.target ~= nil then
                inst.components.combat:SetTarget(inst.sg.statemem.target)
            end
            inst.Transform:SetFourFaced()
        end,
    },

    State{
        name = "transformstatue",
        tags = { "busy", "noattack", "statue" },

        onenter = function(inst)
            MakeStatue(inst)
            inst.Transform:SetSixFaced()
            inst.AnimState:PlayAnimation("statue_pre")
            local leader = inst.components.follower.leader
            if leader ~= nil then
                inst.Transform:SetRotation(leader.Transform:GetRotation())
            end
        end,

        timeline =
        {
            FrameEvent(2, PlayClayShakeSound),
            FrameEvent(4, PlayClayShakeSound),
            FrameEvent(6, PlayClayShakeSound),
            FrameEvent(8, PlayClayShakeSound),
            FrameEvent(9, PlayClayFootstep),
            FrameEvent(10, function(inst)
                PlayClayShakeSound(inst)
                HideEyeFX(inst)
            end),
            FrameEvent(12, PlayClayShakeSound),
            FrameEvent(14, PlayClayShakeSound),
            FrameEvent(16, PlayClayShakeSound),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.statue = true
                    inst.sg:GoToState("statue")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.statue then
                MakeReanimated(inst)
                ShowEyeFX(inst)
                StartAura(inst)
                inst.Transform:SetFourFaced()
            end
        end,
    },


    State{
        name = "mutated_spawn",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("mutated_hound_spawn")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("taunt")
            end),
        },
    },
}

CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- config
	swimming_clear_collision_frame = 9 * FRAMES,
},
{ -- anims
},
{ -- timeline
	hop_pre =
	{
		TimeEvent(0, function(inst)
			if inst:HasTag("swimming") then
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
	},
	hop_pst = {
		FrameEvent(4, function(inst)
			if inst:HasTag("swimming") then
				inst.components.locomotor:Stop()
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
		FrameEvent(6, function(inst)
			if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
			end
		end),
	}
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        FrameEvent(30, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.growl)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                if inst:HasTag("clay") then
                    PlayClayFootstep(inst)
                else
                    PlayFootstep(inst)
                end
            end
        end),
        FrameEvent(4, function(inst)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                if inst:HasTag("clay") then
                    PlayClayFootstep(inst)
                else
                    PlayFootstep(inst)
                end
            end
        end),
    },
})
CommonStates.AddFrozenStates(states, HideEyeFX, ShowEyeFX)

return StateGraph("hound", states, events, "taunt", actionhandlers)
