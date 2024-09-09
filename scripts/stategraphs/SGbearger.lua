require("stategraphs/commonstates")
local easing = require("easing")

local SHAKE_DIST = 40

--------------------------------------------------------------------------

local YAWNTARGET_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local YAWNTARGET_ONEOF_TAGS = { "sleeper", "player" }

function yawnfn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.BEARGER_YAWN_RANGE, nil, YAWNTARGET_CANT_TAGS, YAWNTARGET_ONEOF_TAGS)
    for i, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and
            not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
            not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
            not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
            local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
            if mount ~= nil then
                mount:PushEvent("ridersleep", { sleepiness = 7, sleeptime = TUNING.BEARGER_YAWN_SLEEPTIME })
            end
            if v:HasTag("player") then
                v:PushEvent("yawn", { grogginess = 4, knockoutduration = TUNING.BEARGER_YAWN_SLEEPTIME })
            elseif v.components.sleeper ~= nil then
                v.components.sleeper:AddSleepiness(7, TUNING.BEARGER_YAWN_SLEEPTIME)
            elseif v.components.grogginess ~= nil then
                v.components.grogginess:AddGrogginess(4, TUNING.BEARGER_YAWN_SLEEPTIME)
            else
                v:PushEvent("knockedout")
            end
        end
    end
    return true
end

--------------------------------------------------------------------------

local function ClearInventory(inst)
	if inst.components.inventory == nil then
		return
	end
	local function CanEat(item)
		return inst.components.eater:CanEat(item)
	end
	local item = inst.components.inventory:FindItem(CanEat)
	while item ~= nil do
		item:Remove()
		item = inst.components.inventory:FindItem(CanEat)
	end
end

local function ChooseAttack(inst, target)
	target = target or inst.components.combat.target
	if target ~= nil and not target:IsValid() then
		target = nil
	end

	if target == nil then
		return false
	end

    -- Clear out the inventory if he got interrupted
	ClearInventory(inst)

	if target:HasTag("beehive") then
		inst.sg:GoToState("attack", target)
		return true
    end

    if inst.sg:HasStateTag("running") then
		if inst.canrunningbutt then
			inst.Transform:SetRotation(inst.Transform:GetRotation() + 180)
			inst.sg:GoToState("running_butt_pre", target)
			return true
		else
			inst.sg:GoToState("pound")
			return true
		end
	elseif inst.components.sleeper ~= nil and inst:HasTag("hibernation") and not (inst.components.timer:TimerExists("Yawn") or inst.sg:HasStateTag("yawn")) then
        inst.sg:GoToState("yawn")
		return true
	elseif not inst.components.timer:TimerExists("GroundPound") then
        inst.sg:GoToState("pound")
		return true
    end
	inst.sg:GoToState("attack", target)
	return true
end

--------------------------------------------------------------------------

local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO" }

local function DestroyStuff(inst, dist, radius, arc, nofx)
    local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation() * DEGREES
	if dist ~= 0 then
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)) do
		if v:IsValid() and not v:IsInLimbo() and v.components.workable ~= nil then
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			if arc == nil or ((x1 ~= x or z1 ~= z) and DiffAngleRad(rot, math.atan2(z - z1, x1 - x)) < arc) then
				local work_action = v.components.workable:GetWorkAction()
				--V2C: nil action for NPC_workable (e.g. campfires)
				if (work_action == nil and v:HasTag("NPC_workable")) or
					(v.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
				then
					if not nofx then
						SpawnPrefab("collapse_small").Transform:SetPosition(x1, y1, z1)
					end
					v.components.workable:Destroy(inst)
				end
			end
		end
    end
end

--------------------------------------------------------------------------

local ARC = 90 * DEGREES --degrees to each side
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local MAX_SIDE_TOSS_STR = 0.8

local function DoArcAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation() * DEGREES
	local x0, z0
	if dist ~= 0 then
		if dist > 0 and ((mult ~= nil and mult > 1) or (heavymult ~= nil and heavymult > 1)) then
			x0, z0 = x, z
		end
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
		if v ~= inst and
			not (targets ~= nil and targets[v]) and
			v:IsValid() and not v:IsInLimbo()
			and not (v.components.health ~= nil and v.components.health:IsDead())
		then
			local range = radius + v:GetPhysicsRadius(0)
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local dx = x1 - x
			local dz = z1 - z
			local distsq = dx * dx + dz * dz
			if distsq > 0 and distsq < range * range and
				DiffAngleRad(rot, math.atan2(-dz, dx)) < ARC and
				inst.components.combat:CanTarget(v)
			then
				inst.components.combat:DoAttack(v)
				if mult ~= nil then
					local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
					if strengthmult > MAX_SIDE_TOSS_STR and x0 ~= nil then
						--Don't toss as far to the side for frontal attacks
						dx = x1 - x0
						dz = z1 - z0
						if dx ~= 0 or dz ~= 0 then
							local rot1 = math.atan2(-dz, dx) + PI
							local k = math.max(0, math.cos(math.min(PI, DiffAngleRad(rot1, rot) * 2)))
							strengthmult = MAX_SIDE_TOSS_STR + (strengthmult - MAX_SIDE_TOSS_STR) * k * k
						end
					end
					v:PushEvent("knockback", { knocker = inst, radius = radius + dist, strengthmult = strengthmult, forcelanded = forcelanded })
				end
				if targets ~= nil then
					targets[v] = true
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end

local COMBO_ARC_OFFSET = 0.5

local function DoComboArcAttack(inst, targets)
	DoArcAttack(inst, COMBO_ARC_OFFSET, TUNING.BEARGER_MELEE_RANGE, 1, 1, nil, targets)
end

local function DoComboArcWork(inst)
	DestroyStuff(inst, COMBO_ARC_OFFSET, TUNING.BEARGER_MELEE_RANGE, ARC, true)
end

--------------------------------------------------------------------------

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets, knockback_existing_targets)
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation() * DEGREES
	if dist ~= 0 then
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
		if v ~= inst and v:IsValid() and not v:IsInLimbo() and
			not (v.components.health ~= nil and v.components.health:IsDead())
		then
			local is_existing_target = targets ~= nil and targets[v]
			if not is_existing_target or knockback_existing_targets then
				local range = radius + v:GetPhysicsRadius(0)
				local distsq = v:GetDistanceSqToPoint(x, y, z)
				if distsq < range * range then
					local should_knockback = is_existing_target
					if not is_existing_target and inst.components.combat:CanTarget(v) then
						inst.components.combat:DoAttack(v)
						should_knockback = true
						if targets ~= nil then
							targets[v] = true
						end
					end
					if should_knockback and mult ~= nil then
						v:PushEvent("knockback", { knocker = inst, radius = radius + dist, strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult, forcelanded = forcelanded })
					end
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end

--------------------------------------------------------------------------

local function TryStagger(inst)
	inst.sg:GoToState("stagger_pre")
	return true
end

local function IsAggro(inst)
	return inst.components.combat.target ~= nil
		and not inst.components.combat.target:HasTag("beehive")
end

--------------------------------------------------------------------------

local TRACKING_ARC = 90

local function StartTrackingTarget(inst, target)
	if target ~= nil and target:IsValid() then
		inst.sg.statemem.target = target
		inst.sg.statemem.targetpos = target:GetPosition()
		inst.sg.statemem.tracking = true
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local rot = inst.Transform:GetRotation()
		local rot1 = inst:GetAngleToPoint(x1, y1, z1)
		local diff = DiffAngle(rot, rot1)
		if diff < TRACKING_ARC then
			inst.Transform:SetRotation(rot1)
		end
	end
end

local function UpdateTrackingTarget(inst)
	if inst.sg.statemem.tracking then
		if inst.sg.statemem.target ~= nil then
			if inst.sg.statemem.target:IsValid() then
				local p = inst.sg.statemem.targetpos
				p.x, p.y, p.z = inst.sg.statemem.target.Transform:GetWorldPosition()
			else
				inst.sg.statemem.target = nil
			end
		end
		if inst.sg.statemem.targetpos ~= nil then
			local rot = inst.Transform:GetRotation()
			local rot1 = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
			local drot = ReduceAngle(rot1 - rot)
			if math.abs(drot) < TRACKING_ARC then
				rot1 = rot + math.clamp(drot / 2, -1, 1)
				inst.Transform:SetRotation(rot1)
			end
		end
	end
end

local function StopTrackingTarget(inst)
	inst.sg.statemem.tracking = false
end

local function ShouldComboTarget(inst, target)
	if inst.components.combat:TargetIs(target) then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		local distsq = dx * dx + dz * dz
		if distsq > 0 and distsq < inst.components.combat:CalcAttackRangeSq(target) then
			local rot = inst.Transform:GetRotation()
			local rot1 = math.atan2(-dz, dx) * RADIANS
			return DiffAngle(rot, rot1) < TRACKING_ARC
		end
	end
	return false
end

local function ShouldButtTarget(inst, target)
	if target ~= nil and target:IsValid() and not IsEntityDeadOrGhost(target) then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		local distsq = dx * dx + dz * dz
		if distsq > 0 and distsq < 64 then
			local rot = inst.Transform:GetRotation() + 180
			local rot1 = math.atan2(-dz, dx) * RADIANS
			return DiffAngle(rot, rot1) < TRACKING_ARC
		end
	end
	return false
end

local function TryButt(inst)
	if inst:IsButtRecovering() then
		return false
	elseif ShouldButtTarget(inst, inst.sg.statemem.target) then
		inst.sg:GoToState("butt_pre", inst.sg.statemem.target)
		return true
	end
	local target = inst.components.combat.target
	if target ~= nil and target ~= inst.sg.statemem.target and ShouldButtTarget(inst, target) then
		inst.sg:GoToState("butt_pre", target)
		return true
	end
	return false
end

--------------------------------------------------------------------------

local function SpawnSwipeFX(inst, offset, reverse)
	if inst.swipefx ~= nil then
		--spawn 3 frames early (with 3 leading blank frames) since anim is super short, and tends to get lost with network timing
		inst.sg.statemem.fx = SpawnPrefab(inst.swipefx)
		inst.sg.statemem.fx.entity:SetParent(inst.entity)
		inst.sg.statemem.fx.Transform:SetPosition(offset, 0, 0)
		if reverse then
			inst.sg.statemem.fx:Reverse()
		end
	end
end

local function KillSwipeFX(inst)
	if inst.sg.statemem.fx ~= nil then
		if inst.sg.statemem.fx:IsValid() then
			inst.sg.statemem.fx:Remove()
		end
		inst.sg.statemem.fx = nil
	end
end

--------------------------------------------------------------------------

local actionhandlers =
{
	--ActionHandler(ACTIONS.HAMMER, "attack"),
	ActionHandler(ACTIONS.GOHOME, "taunt"),

	ActionHandler(ACTIONS.STEAL, "steal"),
	ActionHandler(ACTIONS.HAMMER, "steal"),
	ActionHandler(ACTIONS.EAT, "eat_loop"),

	ActionHandler(ACTIONS.PICKUP, "action"),
	ActionHandler(ACTIONS.HARVEST, "action"),
	ActionHandler(ACTIONS.PICK, "action"),

	ActionHandler(ACTIONS.ATTACK, "attack_action"),
}

local events =
{
	CommonHandlers.OnLocomote(true, true),
	CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnDeath(),
    CommonHandlers.OnSink(),
	EventHandler("doattack", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
			ChooseAttack(inst, data ~= nil and data.target or nil)
		end
	end),
	EventHandler("attacked", function(inst, data)
		--V2C: health check since corpse shares this SG
		if inst.components.health ~= nil and not inst.components.health:IsDead() and (
			not inst.sg:HasStateTag("busy") or
			inst.sg:HasStateTag("caninterrupt") or
			inst.sg:HasStateTag("frozen")
		) then
			if inst.sg:HasStateTag("staggered") then
				inst.sg.statemem.staggered = true
				inst.sg:GoToState("stagger_hit")
			elseif not CommonHandlers.HitRecoveryDelay(inst) then
				-- Clear out the inventory if he got interrupted
				ClearInventory(inst)
				inst.sg:GoToState(inst:IsStandState("quad") and "hit" or "standing_hit")
			end
		end
	end),
}

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 1, inst, 40)
end

local function ShakeIfClose_Pound(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .025, 1.25, inst, 40)
end

local function ShakeIfClose_Footstep(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)
end

local function DoFootstep(inst)
	if inst:IsStandState("quad") then
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
	else
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
		ShakeIfClose_Footstep(inst)
	end
end

local function GoToStandState(inst, state, customtrans, params)
	if inst:IsStandState(state) then
		return true
	end
	inst.sg:GoToState(string.lower(state), { endstate = inst.sg.currentstate.name, customtrans = customtrans, params = params })
end

local IDLE_FLAGS =
{
	Aggro =		0x01,
	Calm =		0x02,
	NoFaced =	0x04,
}

local states =
{
	State{
		name = "init",
		onenter = function(inst)
			inst.sg:GoToState(inst.components.locomotor ~= nil and "idle" or "corpse_idle")
		end,
	},

	State{
		name = "bi",
		tags = { "busy" },

		onenter = function(inst, data)
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.endstate = data.endstate
			inst.sg.statemem.params = data.params

			local flags = data.endstate == "idle" and data.params or nil
			local nofaced, aggro
			if flags ~= nil then
				nofaced = checkbit(flags, IDLE_FLAGS.NoFaced)
				if checkbit(flags, IDLE_FLAGS.Aggro) then
					aggro = true
				elseif checkbit(flags, IDLE_FLAGS.Calm) then
					aggro = false
				end
			end
			if aggro == nil then
				aggro = IsAggro(inst)
			end

			if data.customtrans ~= nil then
				inst.AnimState:PlayAnimation(data.customtrans)
				inst:SetStandState("bi")
			else
				inst.AnimState:PlayAnimation((aggro and "taunt_pre" or "to_bi")..(nofaced and "_nofaced" or ""))
			end

			inst.sg.statemem.endbusy =
				data.endstate == "idle" or
				data.endstate == "walk_start" or
				data.endstate == "run_start"
		end,

		timeline =
		{
			FrameEvent(6, DoFootstep),
			FrameEvent(7, function(inst)
				inst:SetStandState("bi")
			end),
			FrameEvent(8, function(inst)
				if inst.sg.statemem.endbusy and inst.sg.mem.dostagger then
					TryStagger(inst)
				end
			end),
			FrameEvent(12, function(inst)
				if inst.sg.statemem.endbusy then
					if inst.sg.mem.dostagger and TryStagger(inst) then
						return
					end
					inst.sg:RemoveStateTag("busy")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.endstate, inst.sg.statemem.params)
				end
			end),
		},
	},

	State{
		name = "quad",
		tags = { "busy" },

		onenter = function(inst, data)
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.endstate = data.endstate
			inst.sg.statemem.params = data.params
			if data.customtrans ~= nil then
				inst.AnimState:PlayAnimation(data.customtrans)
				inst:SetStandState("quad")
			else
				inst.AnimState:PlayAnimation("taunt_pst")
			end
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				inst:SetStandState("quad")
				DoFootstep(inst)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.endstate, inst.sg.statemem.params)
				end
			end),
		},
	},

	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst, flags)
			if inst.sg.mem.dostagger and TryStagger(inst) then
				return
			elseif GoToStandState(inst, "bi", nil, flags) then
				inst.components.locomotor:StopMoving()
				local nofaced, aggro
				if flags ~= nil then
					nofaced = checkbit(flags, IDLE_FLAGS.NoFaced)
					if checkbit(flags, IDLE_FLAGS.Aggro) then
						aggro = true
					elseif checkbit(flags, IDLE_FLAGS.Calm) then
						aggro = false
					end
				end
				if aggro == nil then
					aggro = IsAggro(inst)
				end
				inst.AnimState:PlayAnimation((aggro and "standing_idle" or "idle_loop")..(nofaced and "_nofaced" or ""), true)
			end
		end,

		onexit = function(inst)
			inst:SwitchToFourFaced()
		end,
	},

	State{
		name = "targetstolen",
		tags = { "busy", "canrotate" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:Stop()
				inst.AnimState:PlayAnimation("taunt")
			end
		end,

		timeline =
		{
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt") end),
			FrameEvent(9, DoFootstep),
			FrameEvent(33, DoFootstep),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:ClearBufferedAction()
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("hit")
			inst.sg.statemem.aggro = IsAggro(inst)
			inst.AnimState:PushAnimation(inst.sg.statemem.aggro and "taunt_pre" or "to_bi", false)
			inst:SetStandState("quad")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if not inst.sg.mem.dostagger and inst.sg.statemem.doattack == nil then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			--"hit" is 12 frames
			FrameEvent(12 + 7, function(inst)
				inst:SetStandState("bi")
			end),
			FrameEvent(12 + 8, function(inst)
				if inst.sg.mem.dostagger then
					TryStagger(inst)
				end
			end),
			FrameEvent(12 + 12, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger then
					if not inst.sg:HasStateTag("busy") then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
						inst.sg:RemoveStateTag("caninterrupt")
					end
				end
				return true
			end),
			EventHandler("stagger", function(inst)
				if not inst.sg:HasStateTag("busy") then
					TryStagger(inst)
				else
					inst.sg.mem.dostagger = true
					inst.sg:RemoveStateTag("caninterrupt")
				end
				return true
			end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm)
				end
			end),
		},
	},

	State{
		name = "standing_hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("standing_hit")
			inst:SetStandState("bi")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger then
					if not inst.sg:HasStateTag("busy") then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},

	State{
		name = "yawn",
		tags = { "yawn", "busy" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("yawn")
				inst.sg.statemem.aggro = IsAggro(inst)
				inst.AnimState:PushAnimation(inst.sg.statemem.aggro and "standing_yawn_pst" or "yawn_pst", false)
			end
		end,

		timeline =
		{
			FrameEvent(22, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/yawn")
				inst.components.timer:StopTimer("Yawn")
				inst.components.timer:StartTimer("Yawn", TUNING.BEARGER_YAWN_COOLDOWN)
			end),
			FrameEvent(50, yawnfn),
			FrameEvent(54, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(65, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("canrotate")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.NoFaced + (inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm))
				end
			end),
		},
	},

	State{
		name = "attack_action",
		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg:GoToState("attack", buffaction ~= nil and buffaction.target or nil)
		end,
	},

	State{
		name = "attack",
		tags = { "attack", "busy", "weapontoss" },

		onenter = function(inst, target)
			if inst.cancombo then
				inst.sg:GoToState("attack_combo1", target)
			elseif GoToStandState(inst, "bi", nil, target) then
				inst.components.locomotor:StopMoving()
				inst.components.combat:StartAttack()
				inst:SwitchToEightFaced()
				inst.AnimState:PlayAnimation("atk")
				StartTrackingTarget(inst, target)
				inst.sg.statemem.original_target = target --remember for onmissother event
			end
		end,

		onupdate = UpdateTrackingTarget,

		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(10, StopTrackingTarget),
			FrameEvent(28, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(29, function(inst)
				SpawnSwipeFX(inst, 1)
			end),
			FrameEvent(32, function(inst)
				inst.sg.statemem.targets = {}
				DoArcAttack(inst, 1, TUNING.BEARGER_MELEE_RANGE, nil, nil, nil, inst.sg.statemem.targets)
			end),
			FrameEvent(33, function(inst)
				DoArcAttack(inst, 1, TUNING.BEARGER_MELEE_RANGE, nil, nil, nil, inst.sg.statemem.targets)
				DestroyStuff(inst, 1, TUNING.BEARGER_MELEE_RANGE)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target }) --for ChaseAndAttack
				end
			end),
			FrameEvent(47, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(54, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.keepfacing = true
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			KillSwipeFX(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
		end,
	},

	State{
		name = "attack_combo1",
		tags = { "attack", "busy", "jumping", "weapontoss" },

		onenter = function(inst, target)
			if GoToStandState(inst, "bi", nil, target) then
				inst.components.locomotor:Stop()
				inst.components.combat:StartAttack()
				inst:SwitchToEightFaced()
				inst.AnimState:PlayAnimation("atk1")
				inst.AnimState:PushAnimation("atk1_pst", false)
				StartTrackingTarget(inst, target)
				inst.sg.statemem.original_target = target --remember for onmissother event
			end
		end,

		onupdate = UpdateTrackingTarget,

		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(10, StopTrackingTarget),
			FrameEvent(28, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(27, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(28, function(inst) inst.Physics:SetMotorVelOverride(12, 0, 0) end),
			FrameEvent(29, function(inst)
				SpawnSwipeFX(inst, COMBO_ARC_OFFSET)
			end),
			FrameEvent(32, function(inst)
				inst.sg.statemem.targets = {}
				ToggleOffCharacterCollisions(inst)
				DoComboArcAttack(inst, inst.sg.statemem.targets)
			end),
			FrameEvent(33, function(inst)
				DoComboArcAttack(inst, inst.sg.statemem.targets)
				DoComboArcWork(inst)
				ToggleOnCharacterCollisions(inst)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target }) --for ChaseAndAttack
				end
			end),
			FrameEvent(34, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(35, function(inst) inst.Physics:SetMotorVelOverride(3, 0, 0) end),
			FrameEvent(36, function(inst) inst.Physics:SetMotorVelOverride(1.5, 0, 0) end),
			FrameEvent(37, function(inst) inst.Physics:SetMotorVelOverride(0.75, 0, 0) end),
			FrameEvent(38, function(inst) inst.Physics:SetMotorVelOverride(0.375, 0, 0) end),
			FrameEvent(39, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			--
			FrameEvent(41, function(inst)
				if ShouldComboTarget(inst, inst.sg.statemem.target) then
					inst.sg:GoToState("attack_combo2", inst.sg.statemem.target)
				end
			end),
			FrameEvent(47, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.canbutt and TryButt(inst))
				then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(54, function(inst)
				if inst.canbutt and TryButt(inst) then
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.canbutt and TryButt(inst) then
						return
					end
					inst.sg.statemem.keepfacing = true
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			ToggleOnCharacterCollisions(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			KillSwipeFX(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
		end,
	},

	State{
		name = "attack_combo2",
		tags = { "attack", "busy", "jumping", "weapontoss" },

		onenter = function(inst, target)
			inst:SetStandState("bi")
			inst.components.locomotor:Stop()
			inst.components.combat:StartAttack()
			inst:SwitchToEightFaced()
			inst.AnimState:PlayAnimation("atk2")
			inst.AnimState:PushAnimation("atk2_pst", false)
			StartTrackingTarget(inst, target)
			inst.sg.statemem.original_target = target --remember for onmissother event
		end,

		onupdate = UpdateTrackingTarget,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(10, StopTrackingTarget),
			FrameEvent(24, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(23, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(24, function(inst) inst.Physics:SetMotorVelOverride(12, 0, 0) end),
			FrameEvent(25, function(inst)
				SpawnSwipeFX(inst, COMBO_ARC_OFFSET, true)
			end),
			FrameEvent(28, function(inst)
				inst.sg.statemem.targets = {}
				ToggleOffCharacterCollisions(inst)
				DoComboArcAttack(inst, inst.sg.statemem.targets)
			end),
			FrameEvent(29, function(inst)
				DoComboArcAttack(inst, inst.sg.statemem.targets)
				DoComboArcWork(inst)
				ToggleOnCharacterCollisions(inst)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target }) --for ChaseAndAttack
				end
			end),
			FrameEvent(30, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(31, function(inst) inst.Physics:SetMotorVelOverride(3, 0, 0) end),
			FrameEvent(32, function(inst) inst.Physics:SetMotorVelOverride(1.5, 0, 0) end),
			FrameEvent(33, function(inst) inst.Physics:SetMotorVelOverride(0.75, 0, 0) end),
			FrameEvent(34, function(inst) inst.Physics:SetMotorVelOverride(0.375, 0, 0) end),
			FrameEvent(35, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			--
			FrameEvent(37, function(inst)
				if ShouldComboTarget(inst, inst.sg.statemem.target) then
					inst.sg:GoToState("attack_combo1a", inst.sg.statemem.target)
				end
			end),
			FrameEvent(43, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.canbutt and TryButt(inst))
				then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(50, function(inst)
				if inst.canbutt and TryButt(inst) then
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.canbutt and TryButt(inst) then
						return
					end
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			ToggleOnCharacterCollisions(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			KillSwipeFX(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
		end,
	},

	State{
		name = "attack_combo1a",
		tags = { "attack", "busy", "jumping", "weapontoss" },

		onenter = function(inst, target)
			inst:SetStandState("bi")
			inst.components.locomotor:Stop()
			inst.components.combat:StartAttack()
			inst:SwitchToEightFaced()
			inst.AnimState:PlayAnimation("atk1a")
			inst.AnimState:PushAnimation("atk1_pst", false)
			StartTrackingTarget(inst, target)
			inst.sg.statemem.original_target = target --remember for onmissother event
		end,

		onupdate = UpdateTrackingTarget,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(10, StopTrackingTarget),
			FrameEvent(24, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(23, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(24, function(inst) inst.Physics:SetMotorVelOverride(12, 0, 0) end),
			FrameEvent(25, function(inst)
				SpawnSwipeFX(inst, COMBO_ARC_OFFSET)
			end),
			FrameEvent(28, function(inst)
				inst.sg.statemem.targets = {}
				ToggleOffCharacterCollisions(inst)
				DoComboArcAttack(inst, inst.sg.statemem.targets)
			end),
			FrameEvent(29, function(inst)
				DoComboArcAttack(inst, inst.sg.statemem.targets)
				DoComboArcWork(inst)
				ToggleOnCharacterCollisions(inst)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target }) --for ChaseAndAttack
				end
			end),
			FrameEvent(30, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(31, function(inst) inst.Physics:SetMotorVelOverride(3, 0, 0) end),
			FrameEvent(32, function(inst) inst.Physics:SetMotorVelOverride(1.5, 0, 0) end),
			FrameEvent(33, function(inst) inst.Physics:SetMotorVelOverride(0.75, 0, 0) end),
			FrameEvent(34, function(inst) inst.Physics:SetMotorVelOverride(0.375, 0, 0) end),
			FrameEvent(35, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			--
			FrameEvent(37, function(inst)
				if ShouldComboTarget(inst, inst.sg.statemem.target) then
					inst.sg:GoToState("attack_combo2", inst.sg.statemem.target)
				end
			end),
			FrameEvent(43, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.canbutt and TryButt(inst))
				then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(50, function(inst)
				if inst.canbutt and TryButt(inst) then
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.canbutt and TryButt(inst) then
						return
					end
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			ToggleOnCharacterCollisions(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			KillSwipeFX(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
		end,
	},

	State{
		name = "pound",
		tags = { "attack", "busy" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("ground_pound")
			end
		end,

		timeline =
		{
			FrameEvent(13, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(20, function(inst)
				ShakeIfClose_Pound(inst)
				inst.components.groundpounder:GroundPound()
				inst.components.timer:StopTimer("GroundPound")
				inst.components.timer:StartTimer("GroundPound", TUNING.BEARGER_NORMAL_GROUNDPOUND_COOLDOWN)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
			end),
			FrameEvent(21, function(inst)
				inst:SetStandState("quad")
			end),
			FrameEvent(30, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
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
		name = "butt_pre",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			if GoToStandState(inst, "bi", nil, target) then
				inst.components.locomotor:Stop()
				local left
				if target ~= nil and target:IsValid() then
					local x1, y1, z1 = target.Transform:GetWorldPosition()
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(x1, y1, z1) + 180
					local drot = ReduceAngle(rot1 - rot)
					if drot ~= 0 and math.abs(drot) < TRACKING_ARC then
						left = drot > 0
						inst.sg.statemem.left = left
						inst.sg.statemem.target = target
						inst.sg.statemem.targetpos = target:GetPosition()
					end
				end
				if left == nil then
					left = math.random() < 0.5
				end
				inst.AnimState:PlayAnimation(left and "butt_pre_L" or "butt_pre_R")
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(23, function(inst)
				local p = inst.sg.statemem.targetpos
				if p ~= nil then
					local rot2
					local target = inst.sg.statemem.target
					if target ~= nil and target:IsValid() then
						local x1, y1, z1 = target.Transform:GetWorldPosition()
						local rot = inst.Transform:GetRotation()
						local rot1 = inst:GetAngleToPoint(x1, y1, z1) + 180
						local drot = ReduceAngle(rot1 - rot)
						local left = drot > 0
						if drot ~= 0 and math.abs(drot) < (left == inst.sg.statemem.left and TRACKING_ARC or TRACKING_ARC / 3) then
							rot2 = rot + drot / 2
							p.x, p.y, p.z = x1, y1, z1
						end
					end
					if rot2 == nil then
						rot2 = inst:GetAngleToPoint(p) + 180
					end
					inst.Transform:SetRotation(rot2)
				end
			end),
			FrameEvent(25, function(inst)
				inst:SetStandState("quad")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local data = inst.sg.statemem.targetpos ~= nil and {
						targetpos = inst.sg.statemem.targetpos,
						target = inst.sg.statemem.target,
					} or nil
					inst.sg:GoToState("butt", data)
				end
			end),
		},
	},

	State{
		name = "running_butt_pre",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst:SetStandState("bi")
			inst.components.locomotor:Stop()
			local left
			if target ~= nil and target:IsValid() then
				local x1, y1, z1 = target.Transform:GetWorldPosition()
				local rot = inst.Transform:GetRotation()
				local rot1 = inst:GetAngleToPoint(x1, y1, z1) + 180
				local drot = ReduceAngle(rot1 - rot)
				if drot ~= 0 and math.abs(drot) < TRACKING_ARC then
					left = drot > 0
					inst.sg.statemem.left = left
					inst.sg.statemem.target = target
					inst.sg.statemem.targetpos = target:GetPosition()
				end
			end
			if left == nil then
				left = math.random() < 0.5
			end
			inst.AnimState:PlayAnimation(left and "butt_pre_L" or "butt_pre_R")
			inst.AnimState:SetFrame(22)
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				local p = inst.sg.statemem.targetpos
				if p ~= nil then
					local rot2
					local target = inst.sg.statemem.target
					if target ~= nil and target:IsValid() then
						local x1, y1, z1 = target.Transform:GetWorldPosition()
						local rot = inst.Transform:GetRotation()
						local rot1 = inst:GetAngleToPoint(x1, y1, z1) + 180
						local drot = ReduceAngle(rot1 - rot)
						local left = drot > 0
						if drot ~= 0 and math.abs(drot) < (left == inst.sg.statemem.left and TRACKING_ARC or TRACKING_ARC / 3) then
							rot2 = rot + drot / 2
							p.x, p.y, p.z = x1, y1, z1
						end
					end
					if rot2 == nil then
						rot2 = inst:GetAngleToPoint(p) + 180
					end
					inst.Transform:SetRotation(rot2)
				end
			end),
			FrameEvent(3, function(inst)
				inst:SetStandState("quad")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local data = inst.sg.statemem.targetpos ~= nil and {
						targetpos = inst.sg.statemem.targetpos,
						target = inst.sg.statemem.target,
						running = true,
					} or nil
					inst.sg:GoToState("butt", data)
				end
			end),
		},
	},

	State{
		name = "butt",
		tags = { "attack", "busy", "jumping", "nointerrupt" },

		onenter = function(inst, data)
			inst:SetStandState("bi")
			inst.components.locomotor:Stop()
			inst.components.combat:RestartCooldown()
			inst.AnimState:PlayAnimation("butt")
			local dist
			if data ~= nil then
				if data.running then
					dist = 6
				else
					local x, y, z = inst.Transform:GetWorldPosition()
					if data.target ~= nil and data.target:IsValid() then
						local x1, y1, z1 = data.target.Transform:GetWorldPosition()
						local dx = x1 - x
						local dz = z1 - z
						if dx ~= 0 or dz ~= 0 then
							local rot = inst.Transform:GetRotation() * DEGREES
							local rot1 = math.atan2(-dz, dx) + PI
							local diff = DiffAngleRad(rot, rot1)
							if diff < PI / 4 then
								dist = math.sqrt(dx * dx + dz * dz)
								dist = dist * math.cos(diff)
							end
						end
					end
					if dist == nil and data.targetpos ~= nil then
						local dx = data.targetpos.x - x
						local dz = data.targetpos.z - z
						if dx ~= 0 or dz ~= 0 then
							dist = math.sqrt(dx * dx + dz * dz)
						end
					end
				end
				inst.sg.statemem.original_target = data.target --remember for onmissother event
			end
			dist = math.clamp(dist or 3, 3, 6)
			inst.Physics:SetMotorVelOverride(-dist / inst.AnimState:GetCurrentAnimationLength(), 0, 0)
		end,

		timeline =
		{
			FrameEvent(1, ToggleOffCharacterCollisions),
			FrameEvent(8, function(inst)
				local pt = inst:GetPosition()
				local rot = inst.Transform:GetRotation() * DEGREES
				local dist = -1
				pt.x = pt.x + dist * math.cos(rot)
				pt.y = 0
				pt.z = pt.z - dist * math.sin(rot)

				inst.sg.statemem.targets = {}
				inst.components.groundpounder:GroundPound(pt, inst.sg.statemem.targets)
				inst.SoundEmitter:PlaySound("rifts3/mutated_bearger/buttslam")
			end),
			FrameEvent(9, function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot = inst.Transform:GetRotation() * DEGREES
				local dist = -1
				x = x + dist * math.cos(rot)
				z = z - dist * math.sin(rot)

				--extra "true" to knockback existing targets from groundpound
				DoAOEAttack(inst, dist, 4, 1.2, 1.5, nil, inst.sg.statemem.targets, true)
				ToggleOnCharacterCollisions(inst)

				local sinkhole = SpawnPrefab("bearger_sinkhole")
				sinkhole.Transform:SetPosition(x, 0, z)
				sinkhole:PushEvent("docollapse")

				ShakeIfClose_Pound(inst) --override sinkhole shake
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.butt = true
					inst.sg:GoToState("butt_pst", {
						target = inst.sg.statemem.original_target,
						targets = inst.sg.statemem.targets,
					})
				end
			end),
		},

		onexit = function(inst)
			ToggleOnCharacterCollisions(inst)
			if not inst.sg.statemem.butt then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end
		end,
	},

	State{
		name = "butt_pst",
		tags = { "attack", "busy", "jumping" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("butt_pst")
			if data ~= nil and data.targets ~= nil then
				DoAOEAttack(inst, -1, 4, 1.2, 1.5, nil, data.targets)
				if next(data.targets) == nil then
					inst:PushEvent("onmissother", { target = data.target }) --for ChaseAndAttack
				end
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.Physics:SetMotorVelOverride(-4, 0, 0) end),
			FrameEvent(1, function(inst) inst.Physics:SetMotorVelOverride(-2, 0, 0) end),
			FrameEvent(2, function(inst) inst.Physics:SetMotorVelOverride(-1, 0, 0) end),
			FrameEvent(3, function(inst) inst.Physics:SetMotorVelOverride(-0.5, 0, 0) end),
			FrameEvent(4, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			FrameEvent(20, function(inst)
				inst.sg.statemem.vulnerable = true
			end),
			FrameEvent(41, function(inst)
				inst.sg.statemem.vulnerable = false
				inst:SetStandState("quad")
			end),
		},

		events =
		{
			EventHandler("attacked", function(inst, data)
				if inst.sg.statemem.vulnerable and
					not inst.components.health:IsDead() and
					data ~= nil and data.spdamage ~= nil and data.spdamage.planar ~= nil
				then
					inst.sg:GoToState("butt_face_hit")
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
		end,
	},

	State{
		name = "butt_face_hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("butt_face_hit")
			inst:SetStandState("bi")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
			inst.sg.statemem.vulnerable = true
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg.statemem.canstagger = true
			end),
			FrameEvent(28, function(inst)
				inst:SetStandState("quad")
				inst.sg.statemem.vulnerable = false
			end),
		},

		events =
		{
			EventHandler("attacked", function(inst, data)
				if inst.sg.statemem.vulnerable and
					not inst.components.health:IsDead() and
					data ~= nil and data.spdamage ~= nil and data.spdamage.planar ~= nil
				then
					inst.sg.mem.dostagger = true
					if inst.sg.statemem.canstagger then
						TryStagger(inst)
					end
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},

	State{
		name = "death",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:Stop()
				inst.AnimState:PlayAnimation("death")
			else
				inst.sg:AddStateTag("dead")
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/death") end),
			FrameEvent(46, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound") end),
			FrameEvent(48, function(inst)
				ShakeIfClose(inst)
				inst.components.lootdropper:DropLoot(inst:GetPosition())
				inst.looted = true
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("corpse")
				end
			end)
		},
	},

	State{
		name = "corpse",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("corpse")
		end,

		timeline =
		{
			--delay 1 frame in case we are loading
			FrameEvent(1, function(inst)
				local corpse = not inst:HasTag("lunar_aligned") and TheWorld.components.lunarriftmutationsmanager ~= nil and TheWorld.components.lunarriftmutationsmanager:TryMutate(inst, "beargercorpse") or nil
				if corpse == nil then
					inst:AddTag("NOCLICK")
					inst.persists = false
					RemovePhysicsColliders(inst)

					--58 + 1 frames since death anim started
					local delay = (inst.components.health.destroytime or 2) - 59 * FRAMES
					if delay > 0 then
						inst.sg:SetTimeout(delay)
					else
						ErodeAway(inst)
					end
				elseif IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
					corpse:SetAltBuild("yule")
				end
			end),
		},

		ontimeout = ErodeAway,
	},

	--------------------------------------------------------------------------
	--Used by "beargercorpse"

	State{
		name = "corpse_idle",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("corpse")
		end,
	},

	State{
		name = "corpse_mutate_pre",
		tags = { "mutating" },

		onenter = function(inst, mutantprefab)
			inst.AnimState:PlayAnimation("twitch", true)
			inst.sg.statemem.mutantprefab = mutantprefab
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/twitching_LP", "loop")
		end,

		timeline =
		{
			FrameEvent(82, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_bearger/mutate_pre_cracks_f0") end),
			TimeEvent(3, function(inst)
				inst.sg:GoToState("corpse_mutate", inst.sg.statemem.mutantprefab)
			end),
		},

		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	State{
		name = "corpse_mutate",
		tags = { "mutating" },

		onenter = function(inst, mutantprefab)
			inst.AnimState:OverrideSymbol("bearger_rib", "bearger_mutated", "bearger_rib")
			inst.AnimState:PlayAnimation("mutate_pre")
			inst.SoundEmitter:PlaySound("rifts3/mutated_bearger/mutate_pre_tone_f0")
			inst.sg.statemem.mutantprefab = mutantprefab
		end,

		timeline =
		{
			FrameEvent(68, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft") end),
			FrameEvent(70, function(inst) ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, .5, inst, 30) end),
			FrameEvent(125, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_bearger/mutate") end),
			FrameEvent(149, function(inst)
				inst.AnimState:SetAddColour(.5, .5, .5, 0)
				inst.AnimState:SetLightOverride(.5)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local rot = inst.Transform:GetRotation()
					local creature = ReplacePrefab(inst, inst.sg.statemem.mutantprefab)
					creature.Transform:SetRotation(rot)
					creature.AnimState:MakeFacingDirty() --not needed for clients
					creature.sg:GoToState("mutate_pst")
				end
			end),
		},

		onexit = function(inst)
			--Shouldn't reach here!
			inst.AnimState:ClearAllOverrideSymbols()
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
		end,
	},

	--------------------------------------------------------------------------
	--Transitions from corpse_mutate after prefab switch
	State{
		name = "mutate_pst",
		tags = { "busy", "noattack", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("mutate")
			inst.SoundEmitter:PlaySound("rifts3/mutated_bearger/taunt")
			inst.sg.statemem.flash = 24
			inst:SetStandState("bi")
		end,

		onupdate = function(inst)
			local c = inst.sg.statemem.flash
			if c >= 0 then
				inst.sg.statemem.flash = c - 1
				c = easing.inOutQuad(math.min(20, c), 0, 1, 20)
				inst.AnimState:SetAddColour(c, c, c, 0)
				inst.AnimState:SetLightOverride(c)
			end
		end,

		timeline =
		{
			FrameEvent(25, DoFootstep),
			FrameEvent(27, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft") end),
			FrameEvent(28, function(inst)
				inst:SetStandState("quad")
			end),
			FrameEvent(44, function(inst)
				inst:SetStandState("bi")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.NoFaced + IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
		end,
	},

	--------------------------------------------------------------------------

	State{
		name = "action",
		tags = { "busy" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("action")
				inst.AnimState:PushAnimation("eat_loop", false)
			end
		end,

		timeline =
		{
			FrameEvent(14, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/gulp") end),
			FrameEvent(15, function(inst)
				inst:PerformBufferedAction()
				inst.sg:AddStateTag("wantstoeat")
				inst.last_eat_time = GetTime()
                if inst.brain ~= nil then
                    inst.brain:ForceUpdate()
                end
			end),
			FrameEvent(39, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("eat_pst")
				end
			end),
		},
	},

	State{
		name = "eat_loop",
		tags = { "busy" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:StopMoving()
				if inst.AnimState:IsCurrentAnimation("action") or inst.AnimState:IsCurrentAnimation("eat_loop") then
					inst.AnimState:PushAnimation("eat_loop")
				else
					inst.AnimState:PlayAnimation("eat_loop", true)
				end
				local timeout = math.random()+.5
				local ba = inst:GetBufferedAction()
				if ba and ba.target and ba.target:HasTag("honeyed") then
					timeout = timeout*2
				end
				inst.sg:SetTimeout(timeout)
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
			FrameEvent(14, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
			FrameEvent(23, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
		},

		ontimeout = function(inst)
			inst:PerformBufferedAction()
			inst.last_eat_time = GetTime()
			inst.sg:GoToState("eat_pst")
		end,
	},

	State{
		name = "eat_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst)
			if inst.sg.mem.dostagger and TryStagger(inst) then
				return
			end
			inst:SetStandState("bi")
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("eat_pst")
		end,

		timeline =
		{
			FrameEvent(12, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("canrotate")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.NoFaced + IDLE_FLAGS.Calm)
				end
			end),
		},
	},

	State{
		name = "steal",
		tags = { "busy" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("atk")
			end
		end,

		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(28, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(32, function(inst)
				inst:PerformBufferedAction()
			end),
			FrameEvent(47, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(54, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},

	State{
		name = "walk_start",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				if IsAggro(inst) then
					inst.components.locomotor.walkspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
					inst.AnimState:PlayAnimation("charge_pre")
				else
					inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
					inst.AnimState:PlayAnimation("walk_pre")
				end
				inst.components.locomotor:WalkForward()
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("walk")
				end
			end),
		},
	},

	State{
		name = "walk",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			inst:SetStandState("bi")
			inst.sg.statemem.aggro = IsAggro(inst)
			if inst.sg.statemem.aggro then
				inst.components.locomotor.walkspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
				inst.AnimState:PlayAnimation("charge_loop")
			else
				inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
				inst.AnimState:PlayAnimation("walk_loop")
			end
			inst.components.locomotor:WalkForward()
			if inst.components.combat:HasTarget() and math.random() < 0.5 then
				inst.sg:SetTimeout(math.random(13) * FRAMES)
			end
		end,

		ontimeout = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/grrrr")
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				if inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
			FrameEvent(17, function(inst)
				if inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
			--
			FrameEvent(3, function(inst)
				if not inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
			FrameEvent(29, function(inst)
				if not inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("walk")
				end
			end),
		},
	},

	State{
		name = "walk_stop",
		tags = { "canrotate" },

		onenter = function(inst)
			inst:SetStandState("bi")
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.aggro = IsAggro(inst)
			inst.AnimState:PlayAnimation(inst.sg.statemem.aggro and "charge_pst" or "walk_pst")
			DoFootstep(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm)
				end
			end),
		},
	},

	State{
		name = "run_start",
		tags = { "moving", "running", "atk_pre", "canrotate" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor.runspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
				inst.components.locomotor:RunForward()
				if not inst.SoundEmitter:PlayingSound("taunt") then
					inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt")
				end
				inst.AnimState:PlayAnimation("charge_pre")
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
		},

		onexit = function(inst)
			inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
		end,
	},

	State{
		name = "run",
		tags = { "moving", "running", "canrotate" },

		onenter = function(inst)
			inst:SetStandState("bi")
			inst.components.locomotor:RunForward()
			if not inst.SoundEmitter:PlayingSound("taunt") then
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt")
			end
			inst.AnimState:PlayAnimation("charge_roar_loop")
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				DoFootstep(inst)
				DestroyStuff(inst, 0, 5)
			end),
			FrameEvent(8, function(inst)
				DoFootstep(inst)
				DestroyStuff(inst, 0, 5)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
		},
	},

	State{
		name = "run_stop",
		tags = { "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("charge_pst")
			DoFootstep(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},

	State{
		name = "sleep",
		tags = { "busy", "sleeping", "nowake", "caninterrupt" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.last_eat_time = nil -- Unset eat timer
			inst.sg.mem.dostagger = nil
			if inst:IsStandState("quad") then
				inst.AnimState:PlayAnimation("sleep_pre")
			else
				inst.AnimState:PlayAnimation("standing_sleep_pre")
				inst.AnimState:PushAnimation("sleep_pre", false)
			end
		end,

		timeline =
		{
			FrameEvent(24, function(inst)
				if inst.AnimState:IsCurrentAnimation("sleep_pre") then
					inst.sg:RemoveStateTag("caninterrupt")
				end
			end),
			FrameEvent(25, function(inst)
				if inst:IsStandState("bi") then
					inst:SetStandState("quad")
					DoFootstep(inst)
				end
			end),
			FrameEvent(34 + 24, function(inst)
				inst.sg:RemoveStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.continuesleeping = true
					inst.sg:GoToState(inst.sg.mem.sleeping and "sleeping" or "wake")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.continuesleeping and inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
		end,
	},

	State{
		name = "sleeping",
		tags = { "busy", "sleeping" },

		onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/sleep")
			inst.AnimState:PlayAnimation("sleep_loop")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.continuesleeping = true
					inst.sg:GoToState("sleeping")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.continuesleeping and inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
		end,
	},

	State{
		name = "wake",
		tags = { "busy", "waking", "nosleep" },

		onenter = function(inst)
			inst.last_eat_time = GetTime() -- Fake this as eating so he doesn't aggro immediately
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("sleep_pst")
			if inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
			inst:SetStandState("quad")
		end,

		timeline =
		{
			FrameEvent(27, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt_short") end),
			CommonHandlers.OnNoSleepFrameEvent(33, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:RemoveStateTag("nosleep")
			end),
			FrameEvent(44, function(inst)
				inst:SetStandState("bi")
			end),
		},

		events =
		{
			EventHandler("stagger", function(inst)
				if not inst.sg:HasStateTag("nosleep") then
					TryStagger(inst)
				else
					inst.sg.mem.dostagger = true
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("yawn")
				end
			end),
		},
	},

	--------------------------------------------------------------------------

	State{
		name = "stagger_pre",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst)
			inst.sg.mem.dostagger = nil
			inst.components.timer:StopTimer("stagger")
			inst.components.timer:StartTimer("stagger", TUNING.MUTATED_BEARGER_STAGGER_TIME)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_pre")
			if inst:IsStandState("bi") then
				inst.AnimState:SetFrame(3)
				inst.sg:GoToState("stagger_pre_timeline_from_frame3")
			end
		end,

		timeline =
		{
			--from quad
			FrameEvent(2, function(inst)
				inst:SetStandState("bi")
			end),
			FrameEvent(3, function(inst)
				inst.sg:GoToState("stagger_pre_timeline_from_frame3")
			end),
		},
	},

	State{
		name = "stagger_pre_timeline_from_frame3",
		tags = { "staggered", "busy", "nosleep" },

		timeline =
		{
			--already standing (skips 3 frames)
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/yawn") end),
			FrameEvent(33, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(40, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/yawn", nil, 0.5) end),
			FrameEvent(54, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
				ShakeIfClose_Footstep(inst)
			end),
			FrameEvent(56, function(inst)
				inst:SetStandState("quad")
			end),
			FrameEvent(80, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
				ShakeIfClose(inst)
			end),
			FrameEvent(83, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.components.timer:TimerExists("stagger") and "stagger_idle" or "stagger_pst")
				end
			end),
		},
	},

	State{
		name = "stagger_idle",
		tags = { "staggered", "busy", "caninterrupt", "nosleep" },

		onenter = function(inst)
			if not inst.components.timer:TimerExists("stagger") then
				inst.sg:GoToStandState("stagger_pst")
				return
			end
			inst.AnimState:PlayAnimation("stagger", true)
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" then
					inst.sg:GoToState("stagger_pst")
				end
			end),
		},
	},

	State{
		name = "stagger_hit",
		tags = { "staggered", "busy", "hit", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_hit")
		end,

		timeline =
		{
			FrameEvent(10, function(inst)
				if inst.components.timer:TimerExists("stagger") then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(15, function(inst)
				if not inst.components.timer:TimerExists("stagger") then
					inst.sg:GoToState("stagger_pst", true)
					return
				end
				inst.sg.statemem.cangetup = true
			end),
		},

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" and inst.sg.statemem.cangetup then
					inst.sg:GoToState("stagger_pst", true)
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.components.timer:TimerExists("stagger") then
						inst.sg:GoToState("stagger_idle")
					else
						inst.sg:GoToState("stagger_pst", true)
					end
				end
			end),
		},
	},

	State{
		name = "stagger_pst",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst, nohit)
			inst.AnimState:PlayAnimation("stagger_pst")
			inst.sg.statemem.aggro = IsAggro(inst)
			inst.AnimState:PushAnimation(inst.sg.statemem.aggro and "standing_stagger_pst2" or "stagger_pst2", false)
			if not nohit then
				inst.sg:AddStateTag("caninterrupt")
			end
			if inst.components.sleeper ~= nil then
				inst.components.sleeper:WakeUp()
			end
		end,

		timeline =
		{
			FrameEvent(41, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt_short") end),
			FrameEvent(45, function(inst)
				inst.sg:RemoveStateTag("staggered")
				inst.sg:RemoveStateTag("caninterrupt")
			end),
			FrameEvent(56, function(inst)
				inst:SetStandState("bi")
			end),
			CommonHandlers.OnNoSleepFrameEvent(60, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(67, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("canrotate")
				inst:StartButtRecovery()
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.NoFaced + (inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm))
				end
			end),
		},

		onexit = function(inst)
			inst:StartButtRecovery()
		end,
	},

	--------------------------------------------------------------------------
}

CommonStates.AddFrozenStates(states, function(inst) inst:SetStandState("bi") end)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("bearger", states, events, "init", actionhandlers)
