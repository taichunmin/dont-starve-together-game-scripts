require("stategraphs/commonstates")

local function FixupWorkerCarry(inst, swap)
    if inst.prefab == "shadowworker" then
		if inst.sg.mem.swaptool == swap then
			return false
		end
		inst.sg.mem.swaptool = swap
		if swap == nil then
            inst.AnimState:ClearOverrideSymbol("swap_object")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        else
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
            inst.AnimState:OverrideSymbol("swap_object", swap, swap)
        end
		return true
    else
        if swap == nil then -- DEPRECATED workers.
            inst.AnimState:Hide("swap_arm_carry")
        --'else' case cannot exist old workers had one item only assumed.
        end
    end
end

local function DetachFX(fx)
	fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
	fx.entity:SetParent(nil)
end

local function DoDespawnFX(inst)
	--shadow_despawn is in the air => detaches from sinking boats
	--shadow_glob_fx is on ground => dies with sinking boats
	local x, y, z = inst.Transform:GetWorldPosition()
	local fx1 = SpawnPrefab("shadow_despawn")
	local fx2 = SpawnPrefab("shadow_glob_fx")
	fx2.AnimState:SetScale(math.random() < .5 and -1.3 or 1.3, 1.3, 1.3)
	local platform = inst:GetCurrentPlatform()
	if platform ~= nil then
		fx1.entity:SetParent(platform.entity)
		fx2.entity:SetParent(platform.entity)
		fx1:ListenForEvent("onremove", function() DetachFX(fx1) end, platform)
		x, y, z = platform.entity:WorldToLocalSpace(x, y, z)
	end
	fx1.Transform:SetPosition(x, y, z)
	fx2.Transform:SetPosition(x, y, z)
end

local function TrySplashFX(inst, size)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		SpawnPrefab("ocean_splash_"..(size or "med")..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
		return true
	end
end

local function TryStepSplash(inst)
	local t = GetTime()
	if (inst.sg.mem.laststepsplash == nil or inst.sg.mem.laststepsplash + .1 < t) and TrySplashFX(inst) then
		inst.sg.mem.laststepsplash = t
	end
end

local function DoSound(inst, sound)
	inst.SoundEmitter:PlaySound(sound)
end

local function NotBlocked(pt)
	return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function IsNearTarget(inst, target, range)
	return inst:IsNear(target, range + target:GetPhysicsRadius(0))
end

local function IsLeaderNear(inst, leader, target, range)
	--leader is in range of us or our target
	return inst:IsNear(leader, range) or (target ~= nil and IsNearTarget(leader, target, range))
end

local COMBAT_TIMEOUT = 6
local function CheckCombatLeader(inst, target)
	local score = 0
	local leader = inst.components.follower:GetLeader()
	if leader ~= nil then
		local isnear = IsLeaderNear(inst, leader, target, TUNING.SHADOWWAXWELL_PROTECTOR_ACTIVE_LEADER_RANGE)
		local leader_combat = leader.components.combat
		if leader_combat ~= nil then
			local t = GetTime()
			if math.max(leader_combat.laststartattacktime or 0, leader_combat.lastdoattacktime or 0) + COMBAT_TIMEOUT > t then
				if target ~= nil and leader_combat:IsRecentTarget(target) then
					--leader attacking same target as me, ignore range
					score = 4
				elseif isnear then
					--leader is near me, but fighting something else
					score = 3.5
				else
					local leader_target = Ents[leader_combat.lasttargetGUID]
					if leader_target ~= nil and leader_target:IsValid() and inst:IsNear(leader_target, TUNING.SHADOWWAXWELL_PROTECTOR_ACTIVE_LEADER_RANGE) then
						--i'm near my leader's target, so that counts too
						score = 3.5
					end
				end
			end
			if score == 0 and leader_combat:GetLastAttackedTime() + COMBAT_TIMEOUT > t then
				if target ~= nil and leader_combat.lastattacker == target then
					--leader got hit by my target, ignore range
					score = 3
				elseif isnear then
					--leader is near me, but got hit by something else
					score = 2.5
				else
					local attacker = leader_combat.lastattacker
					if attacker ~= nil and attacker:IsValid() and IsNearTarget(inst, attacker, TUNING.SHADOWWAXWELL_PROTECTOR_ACTIVE_LEADER_RANGE) then
						--i'm near my leader's attacker, so that counts too
						score = 2.5
					end
				end
			end
		end
		if score == 0 and isnear then
			score = 1.5
		end
	end

	--0 is most inactive, 4 is most active, convert score to %
	score = score / 4

	--Scale attack speed
	inst.components.combat:SetAttackPeriod(Lerp(TUNING.SHADOWWAXWELL_PROTECTOR_ATTACK_PERIOD_INACTIVE_LEADER, TUNING.SHADOWWAXWELL_PROTECTOR_ATTACK_PERIOD, score))

	--Scale shadowstrike cooldown
	local elapsed = inst.components.timer ~= nil and inst.components.timer:GetTimeElapsed("shadowstrike_cd") or nil
	if elapsed ~= nil then
		inst.components.timer:StopTimer("shadowstrike_cd")
		local cd = Lerp(TUNING.SHADOWWAXWELL_SHADOWSTRIKE_COOLDOWN_INACTIVE_LEADER, TUNING.SHADOWWAXWELL_SHADOWSTRIKE_COOLDOWN, score)
		if elapsed < cd then
			inst.components.timer:StartTimer("shadowstrike_cd", cd - elapsed, nil, cd)
		end
	end
end

local function CheckLeaderShadowLevel(inst, target)
	local level = 0
	local leader = inst.components.follower:GetLeader()
	if leader ~= nil and
		leader.components.inventory ~= nil and
		IsLeaderNear(inst, leader, target, TUNING.SHADOWWAXWELL_PROTECTOR_SHADOW_LEADER_RADIUS)
		then
		for k, v in pairs(EQUIPSLOTS) do
			local equip = leader.components.inventory:GetEquippedItem(v)
			if equip ~= nil and equip.components.shadowlevel ~= nil then
				level = level + equip.components.shadowlevel:GetCurrentLevel()
			end
		end
	end

	--Scale damage
	inst.components.combat:SetDefaultDamage(TUNING.SHADOWWAXWELL_PROTECTOR_DAMAGE + level * TUNING.SHADOWWAXWELL_PROTECTOR_DAMAGE_BONUS_PER_LEVEL)
end

local function TryRepeatAction(inst, buffaction, right)
	if buffaction ~= nil and
		buffaction:IsValid() and
		buffaction.target ~= nil and
		buffaction.target.components.workable ~= nil and
		buffaction.target.components.workable:CanBeWorked() and
		buffaction.target:IsActionValid(buffaction.action, right)
		then
		local otheraction = inst:GetBufferedAction()
		if otheraction == nil or (
			otheraction.target == buffaction.target and
			otheraction.action == buffaction.action
		) then
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			inst:PushBufferedAction(buffaction)
			return true
		end
	end
	return false
end

local actionhandlers =
{
    ActionHandler(ACTIONS.CHOP,
        function(inst)
			if FixupWorkerCarry(inst, "swap_axe") then
				return "item_out_chop"
			elseif not inst.sg:HasStateTag("prechop") then
                return inst.sg:HasStateTag("chopping")
                    and "chop"
                    or "chop_start"
            end
        end),
    ActionHandler(ACTIONS.MINE,
        function(inst)
			if FixupWorkerCarry(inst, "swap_pickaxe") then
				return "item_out_mine"
			elseif not inst.sg:HasStateTag("premine") then
                return inst.sg:HasStateTag("mining")
                    and "mine"
                    or "mine_start"
            end
        end),
    ActionHandler(ACTIONS.DIG,
        function(inst)
			if FixupWorkerCarry(inst, "swap_shovel") then
				return "item_out_dig"
			elseif not inst.sg:HasStateTag("predig") then
                return inst.sg:HasStateTag("digging")
                    and "dig"
                    or "dig_start"
            end
        end),
    ActionHandler(ACTIONS.GIVE, "give"),
    ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
    ActionHandler(ACTIONS.DROP, "give"),
    ActionHandler(ACTIONS.PICKUP, "take"),
    ActionHandler(ACTIONS.CHECKTRAP, "take"),
    ActionHandler(ACTIONS.PICK,
		function(inst, action)
			return action.target ~= nil
				and (action.target.components.pickable ~= nil and (
						(action.target.components.pickable.jostlepick and "doshortaction") or -- Short action for jostling.
						(action.target.components.pickable.quickpick and "doshortaction") or
						"dolongaction"
					)) or
					(action.target.components.searchable ~= nil and (
						(action.target.components.searchable.jostlesearch and "doshortaction") or
						(action.target.components.searchable.quicksearch and "doshortaction") or
						"dolongaction"
					))
				or nil
		end),
}

local events =
{
    CommonHandlers.OnLocomote(true, false),
    --CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    --CommonHandlers.OnAttack(),
	EventHandler("attacked", function(inst, data)
		if not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
			inst.sg:GoToState("disappear", data ~= nil and data.attacker or nil)
		end
	end),
	EventHandler("doattack", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
			if inst.components.combat.attackrange == 5 then
				inst.sg:GoToState("lunge_pre", data ~= nil and data.target or nil)
			else
				inst.sg:GoToState("attack", data ~= nil and data.target or nil)
			end
		end
	end),
    EventHandler("dance", function(inst)
        if not inst.sg:HasStateTag("busy") and (inst._brain_dancedata ~= nil or not inst.sg:HasStateTag("dancing")) then
            inst.sg:GoToState("dance")
        end
    end),
}

local states =
{
	State{
		name = "spawn",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst, mult)
			inst.Physics:Stop()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("minion_spawn")
           -- inst.SoundEmitter:PlaySound("maxwell_rework/shadow_worker/spawn")
			mult = mult or (0.8 + math.random() * 0.2)
			inst.AnimState:SetDeltaTimeMultiplier(mult)

			mult = 1 / mult
			inst.sg.statemem.tasks =

			{
                inst:DoTaskInTime(0 * FRAMES * mult, DoSound, "maxwell_rework/shadow_worker/spawn"),
				inst:DoTaskInTime(0 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(20 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(44 * FRAMES * mult, TrySplashFX, "small"),
			}
			inst.sg:SetTimeout(70 * FRAMES * mult)
		end,

		ontimeout = function(inst)
			inst.sg:AddStateTag("caninterrupt")
			ToggleOnCharacterCollisions(inst)
			inst.AnimState:SetDeltaTimeMultiplier(1)
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
			if not inst.sg.statemem.spawn then
				ToggleOnCharacterCollisions(inst)
				inst.AnimState:SetDeltaTimeMultiplier(1)
			end
			for i, v in ipairs(inst.sg.statemem.tasks) do
				v:Cancel()
			end
		end,
	},

	State{
		name = "quickspawn",

		onenter = function(inst)
			SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst.sg:GoToState("idle")
		end,
	},

	State{
		name = "quickdespawn",

		onenter = function(inst)
			DoDespawnFX(inst)
			if inst.sg.mem.laststepsplash ~= GetTime() then
				TrySplashFX(inst)
			end
			inst:Remove()
		end,
	},

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
			if inst.components.timer ~= nil and not inst.components.timer:TimerExists("shadowstrike_cd") then
				inst.components.combat:SetRange(5)
			end
        end,
    },

	State{
		name = "ready_pre",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("ready_stance_pre")
			if inst.components.timer ~= nil and not inst.components.timer:TimerExists("shadowstrike_cd") then
				inst.components.combat:SetRange(5)
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("ready")
				end
			end),
		},
	},

	State{
		name = "ready",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("ready_stance_loop", true)
		end,

		onupdate = function(inst)
			if not inst.components.combat:HasTarget() then
				inst.sg:GoToState("ready_pst")
			end
		end,
	},

	State{
		name = "ready_pst",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("ready_stance_pst")
		end,

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
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },

        timeline =
        {
			TimeEvent(1 * FRAMES, TryStepSplash),
			TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
        },
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("run_loop") then
                inst.AnimState:PlayAnimation("run_loop", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
			TimeEvent(5 * FRAMES, TryStepSplash),
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
				inst.sg.mem.laststepsplash = GetTime()
            end),
			TimeEvent(13 * FRAMES, TryStepSplash),
            TimeEvent(15 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
				inst.sg.mem.laststepsplash = GetTime()
            end),
        },

        ontimeout = function(inst)
			inst.sg.statemem.running = true
            inst.sg:GoToState("run")
        end,

		onexit = function(inst)
			if not inst.sg.statemem.running then
				TryStepSplash(inst)
			end
		end,
    },

    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,

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
        name = "attack",
		tags = {"attack", "abouttoattack", "busy"},

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)

			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			else
				target = nil
			end
			CheckCombatLeader(inst, target)
        end,

        timeline =
        {
			TimeEvent(6 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
			end),
			TimeEvent(8*FRAMES, function(inst)
				inst.sg:RemoveStateTag("abouttoattack")
				local target = inst.sg.statemem.target
				CheckLeaderShadowLevel(inst, target ~= nil and target:IsValid() and target or nil)
				inst.components.combat:DoAttack(target) --purposely not checking valid for this call
			end),
            TimeEvent(12*FRAMES, function(inst) -- Keep FRAMES time synced up with ShouldKiteProtector.
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(13*FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
            end),
			TimeEvent(16 * FRAMES, function(inst)
				if inst.isprotector and inst.components.combat:HasTarget() then
					inst.sg:GoToState("ready_pre")
				end
			end),
        },

        events =
        {
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            --FixupWorkerCarry(inst, nil)
            inst.AnimState:PlayAnimation("death")
        end,

		timeline =
		{
			TimeEvent(13 * FRAMES, TrySplashFX),
			TimeEvent(38 * FRAMES, TrySplashFX),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					DoDespawnFX(inst)
					TrySplashFX(inst)
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "take",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle") 
                end
            end),
        },
    },

    State{
        name = "give",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
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
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
    },

    State{
        name = "stunned",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_sanity_pre")
            inst.AnimState:PushAnimation("idle_sanity_loop", true)
            inst.sg:SetTimeout(5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "chop_start",
        tags = {"prechop", "working"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("chop")
                end
            end),
        },
    },

    State{
        name = "chop",
        tags = {"prechop", "chopping", "working"},

        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("chop_loop")
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(14 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prechop")
				TryRepeatAction(inst, inst.sg.statemem.action)
            end),
            TimeEvent(16*FRAMES, function(inst)
                inst.sg:RemoveStateTag("chopping")
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
    },

    State{
        name = "mine_start",
        tags = {"premine", "working"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mine")
                end
            end),
        },
    },

    State{
        name = "mine",
        tags = {"premine", "mining", "working"},

        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
				if inst.sg.statemem.action ~= nil then
					PlayMiningFX(inst, inst.sg.statemem.action.target)
					inst.sg.statemem.recoilstate = "mine_recoil"
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("premine")
				TryRepeatAction(inst, inst.sg.statemem.action)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

	State{
		name = "mine_recoil",
		tags = { "busy", "recoil" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation("pickaxe_recoil")
			if data ~= nil and data.target ~= nil and data.target:IsValid() then
				SpawnPrefab("impact").Transform:SetPosition(data.target.Transform:GetWorldPosition())
			end
			inst.Physics:SetMotorVelOverride(-6, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
			end
		end,

		timeline =
		{
			FrameEvent(4, function(inst)
				inst.sg.statemem.speed = -3
			end),
			FrameEvent(17, function(inst)
				inst.sg.statemem.speed = nil
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),
			FrameEvent(23, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(30, function(inst)
				inst.sg:GoToState("idle", true)
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
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
		end,
	},

    State{
        name = "dig_start",
        tags = {"predig", "working"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dig")
                end
            end),
        },
    },

    State{
        name = "dig",
        tags = {"predig", "digging", "working"},

        onenter = function(inst)
			inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("shovel_loop")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
            end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("predig")
				TryRepeatAction(inst, inst.sg.statemem.action, true)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "dance",
        tags = {"idle", "dancing"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            local ignoreplay = inst.AnimState:IsCurrentAnimation("run_pst")
            if inst._brain_dancedata and #inst._brain_dancedata > 0 then
                for _, data in ipairs(inst._brain_dancedata) do
                    if data.play and not ignoreplay then
                        inst.AnimState:PlayAnimation(data.anim, data.loop)
                    else
                        inst.AnimState:PushAnimation(data.anim, data.loop)
                    end
                end
            else
                -- NOTES(JBK): No dance data do default dance.
                if ignoreplay then
                    inst.AnimState:PushAnimation("emoteXL_pre_dance0")
                else
                    inst.AnimState:PlayAnimation("emoteXL_pre_dance0")
                end
                inst.AnimState:PushAnimation("emoteXL_loop_dance0", true)
            end
            inst._brain_dancedata = nil -- Remove reference no matter what so garbage collector can pick up the memory.
        end,
    },

    State{
        name = "dolongaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, timeout)
            if timeout == nil then
                timeout = 1
            elseif timeout > 1 then
                inst.sg:AddStateTag("slowaction")
            end
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
					inst.bufferedaction.target:PushEvent("startlongaction", inst)
                end
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "doshortaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("pickup")
			inst.AnimState:PushAnimation("pickup_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(6 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "jumpout",
        tags = { "busy", "canrotate", "jumping" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jumpout")
            inst.Physics:SetMotorVel(4, 0, 0)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.GROUND)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(3, 0, 0)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(2, 0, 0)
            end),
            TimeEvent(15.2 * FRAMES, function(inst)
                inst.sg.statemem.physicson = true
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.WORLD)
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(1, 0, 0)
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.Physics:Stop()
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
            if not inst.sg.statemem.physicson then
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.WORLD)
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)
            end
        end,
    },

	State{
		name = "disappear",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },

		onenter = function(inst, attacker)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("disappear")
			if attacker ~= nil and attacker:IsValid() then
				inst.sg.statemem.attackerpos = attacker:GetPosition()
			end
			TrySplashFX(inst, "small")
			inst:DropAggro()
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local theta =
						inst.sg.statemem.attackerpos ~= nil and
						inst:GetAngleToPoint(inst.sg.statemem.attackerpos) or
						inst.Transform:GetRotation()

					theta = (theta + 165 + math.random() * 30) * DEGREES

					local pos = inst:GetPosition()
					pos.y = 0

					local offs =
						FindWalkableOffset(pos, theta, 4 + math.random(), 8, false, true, NotBlocked, true, true) or
						FindWalkableOffset(pos, theta, 2 + math.random(), 6, false, true, NotBlocked, true, true)

					if offs ~= nil then
						pos.x = pos.x + offs.x
						pos.z = pos.z + offs.z
					end
					inst.Physics:Teleport(pos:Get())
					if inst.sg.statemem.attackerpos ~= nil then
						inst:ForceFacePoint(inst.sg.statemem.attackerpos)
					end

					inst.sg.statemem.appearing = true
					inst.sg:GoToState("appear")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.appearing then
				ToggleOnCharacterCollisions(inst)
			end
		end,
	},

	State{
		name = "appear",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			ToggleOffCharacterCollisions(inst)
			inst.AnimState:PlayAnimation("appear")
		end,

		timeline =
		{
			TimeEvent(9 * FRAMES, function(inst)
				TrySplashFX(inst, "small")
			end),
			TimeEvent(11 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
				inst.sg:RemoveStateTag("phasing")
				ToggleOnCharacterCollisions(inst)
			end),
			TimeEvent(13 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
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

		onexit = ToggleOnCharacterCollisions,
	},

	State{
		name = "lunge_pre",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst:StopBrain()
			inst.components.locomotor:Stop()
			inst.AnimState:SetBankAndPlayAnimation("lavaarena_shadow_lunge", "lunge_pre")

			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			else
				target = nil
			end
			CheckCombatLeader(inst, target)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					inst.sg.statemem.targetpos = inst.sg.statemem.target:GetPosition()
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("lunge_loop", { target = inst.sg.statemem.target, targetpos = inst.sg.statemem.targetpos })
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.lunge then
				inst.components.combat:CancelAttack()
				inst:RestartBrain()
				inst.AnimState:SetBank("wilson")
			end
		end,
	},

	State{
		name = "lunge_loop",
		tags = { "attack", "busy", "noattack", "temp_invincible" },

		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("lunge_loop") --NOTE: this anim NOT a loop yo
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
			inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_shadow_med_sharp")
			inst.Physics:ClearCollidesWith(COLLISION.GIANTS)
			ToggleOffCharacterCollisions(inst)
			TrySplashFX(inst)
			inst:DropAggro()

			if inst.components.timer ~= nil then
				inst.components.timer:StopTimer("shadowstrike_cd")
				inst.components.timer:StartTimer("shadowstrike_cd", TUNING.SHADOWWAXWELL_SHADOWSTRIKE_COOLDOWN)
			end

			if data ~= nil then
				if data.target ~= nil and data.target:IsValid() then
					inst.sg.statemem.target = data.target
					inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
				elseif data.targetpos ~= nil then
					inst:ForceFacePoint(data.targetpos)
				end
			end
			inst.Physics:SetMotorVelOverride(35, 0, 0)

			inst.sg:SetTimeout(8 * FRAMES)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.attackdone then
				return
			end
			local target = inst.sg.statemem.target
			if target == nil or not target:IsValid() then
				if inst.sg.statemem.animdone then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("lunge_pst")
					return
				end
				inst.sg.statemem.target = nil
			elseif inst:IsNear(target, 1) then
				local fx = SpawnPrefab(math.random() < .5 and "shadowstrike_slash_fx" or "shadowstrike_slash2_fx")
				local x, y, z = target.Transform:GetWorldPosition()
				fx.Transform:SetPosition(x, y + 1.5, z)
				fx.Transform:SetRotation(inst.Transform:GetRotation())

				CheckLeaderShadowLevel(inst, target)
				inst.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.SHADOWWAXWELL_SHADOWSTRIKE_DAMAGE_MULT, "shadowstrike")
				inst.components.combat:DoAttack(target)
				--Drop aggro again here, since we're in i-frames, and we might've
				--triggered spawners, and they will be initially targeted on me.
				inst:DropAggro()
				if inst.sg.statemem.animdone then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("lunge_pst", target)
					return
				end
				inst.sg.statemem.attackdone = true
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.attackdone or inst.sg.statemem.target == nil then
						inst.sg.statemem.lunge = true
						inst.sg:GoToState("lunge_pst", inst.sg.statemem.target)
						return
					end
					inst.sg.statemem.animdone = true
				end
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.lunge = true
			inst.sg:GoToState("lunge_pst")
		end,

		onexit = function(inst)
			inst.components.combat.externaldamagemultipliers:RemoveModifier(inst, "shadowstrike")
			inst.components.combat:SetRange(2)
			if not inst.sg.statemem.lunge then
				inst:RestartBrain()
				inst.AnimState:SetBank("wilson")
				inst.Physics:CollidesWith(COLLISION.GIANTS)
				ToggleOnCharacterCollisions(inst)
			end
		end,
	},

	State{
		name = "lunge_pst",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },

		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("lunge_pst")
			inst.Physics:SetMotorVelOverride(12, 0, 0)
			inst.sg.statemem.target = target
		end,

		onupdate = function(inst)
			inst.Physics:SetMotorVelOverride(inst.Physics:GetMotorVel() * .8, 0, 0)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local target = inst.sg.statemem.target
					local pos = inst:GetPosition()
					pos.y = 0
					local moved = false
					if target ~= nil then
						if target:IsValid() then
							local targetpos = target:GetPosition()
							local dx, dz = targetpos.x - pos.x, targetpos.z - pos.z
							local radius = math.sqrt(dx * dx + dz * dz)
							local theta = math.atan2(dz, -dx)
							local offs = FindWalkableOffset(targetpos, theta, radius + 3 + math.random(), 8, false, true, NotBlocked, true, true)
							if offs ~= nil then
								pos.x = targetpos.x + offs.x
								pos.z = targetpos.z + offs.z
								inst.Physics:Teleport(pos:Get())
								moved = true
							end
						else
							target = nil
						end
					end
					if not moved and not TheWorld.Map:IsPassableAtPoint(pos.x, 0, pos.z, true) then
						pos = FindNearbyLand(pos, 1) or FindNearbyLand(pos, 2)
						if pos ~= nil then
							inst.Physics:Teleport(pos.x, 0, pos.z)
						end
					end

					if target ~= nil then
						inst:ForceFacePoint(target.Transform:GetWorldPosition())
					end

					inst.sg.statemem.appearing = true
					inst.sg:GoToState("appear")
				end
			end),
		},

		onexit = function(inst)
			inst:RestartBrain()
			inst.AnimState:SetBank("wilson")
			inst.Physics:CollidesWith(COLLISION.GIANTS)
			if not inst.sg.statemem.appearing then
				ToggleOnCharacterCollisions(inst)
			end
		end,
	},

	State{
		name = "item_out_chop",
		onenter = function(inst) inst.sg:GoToState("item_out", "chop") end,
	},

	State{
		name = "item_out_mine",
		onenter = function(inst) inst.sg:GoToState("item_out", "mine") end,
	},

	State{
		name = "item_out_dig",
		onenter = function(inst) inst.sg:GoToState("item_out", "dig") end,
	},

	State{
		name = "item_out",
		tags = { "working" },

		onenter = function(inst, action)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("item_out")
			if action ~= nil then
				inst.sg:AddStateTag("pre"..action)
				inst.sg.statemem.action = action
				inst.sg:SetTimeout(9 * FRAMES)
			else
				inst.sg:RemoveStateTag("working")
				inst.sg:AddStateTag("idle")
			end
		end,

		ontimeout = function(inst)
			inst.sg:GoToState(inst.sg.statemem.action.."_start")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
}

return StateGraph("shadowmaxwell", states, events, "spawn", actionhandlers)
