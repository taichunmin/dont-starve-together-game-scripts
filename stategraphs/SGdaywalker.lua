require("stategraphs/commonstates")
local SGDaywalkerCommon = require("stategraphs/SGdaywalker_common")

--------------------------------------------------------------------------

local function ChooseAttack(inst)
	local running = inst.sg:HasStateTag("running")
	if inst.canslam and not running and (inst.nostalkcd or math.random() < 0.3) then
		inst.sg:GoToState("attack_slam_pre", inst.components.combat.target)
	else
		inst.sg:GoToState("attack_pounce_pre", {
			running = running,
			target = inst.components.combat.target,
		})
	end
	return true
end

local function IsPlayerMelee(data) --"attacked" event data
	return data ~= nil
		and data.attacker ~= nil
		and data.attacker:HasTag("player")
		and (data.damage or 0) > 0
		and (data.weapon == nil or (
				(data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil) and
				data.weapon.components.projectile == nil
			))
end

local events =
{
	CommonHandlers.OnLocomote(true, true),
	EventHandler("doattack", function(inst)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) then
			ChooseAttack(inst)
		end
	end),
	EventHandler("attacked", function(inst, data)
		if inst.sg:HasStateTag("tired") then
			if not inst.sg:HasStateTag("notiredhit") then
				inst.sg.statemem.tired = true
				inst.sg:GoToState("tired_hit", inst.sg.statemem.loops)
			end
		elseif inst.defeated then
			if not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt") then
				inst.sg:GoToState("hit")
			end
		else
			local playermelee = IsPlayerMelee(data)
			if playermelee then
				inst:DeltaFatigue(0) --reset fatigue regen timers
				if inst.sg:HasStateTag("pounce_recovery") and inst:IsFatigued() then
					inst.sg:GoToState("hit", true)
					return
				end
			end
			if (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
				not CommonHandlers.HitRecoveryDelay(inst) then
				inst.sg:GoToState("hit", playermelee or inst.sg.statemem.trytired)
			end
		end
	end),
	EventHandler("leechattached", function(inst, data)
		if not inst.defeated and
			(inst.sg:HasStateTag("canattach") or not inst.sg:HasStateTag("nointerrupt")) then
			inst.sg.statemem.struggling = true
			inst.sg:GoToState("attach", data ~= nil and data.attachpos or nil)
		end
	end),
	EventHandler("roar", function(inst, data)
		if not (inst.defeated or inst.sg:HasStateTag("busy")) then
			inst.sg:GoToState("taunt", data ~= nil and data.target or nil)
		end
	end),
	EventHandler("minhealth", function(inst, data)
		if inst.defeated and not inst.sg:HasStateTag("defeated") then
			inst.sg:GoToState("defeat")
		end
	end),
	EventHandler("teleported", function(inst)
		if inst.sg:HasStateTag("tired") then
			if not inst.sg:HasStateTag("notiredhit") then
				inst.sg.statemem.tired = true
				inst.sg:GoToState("tired_hit", inst.sg.statemem.loops)
			end
		elseif inst.sg:HasStateTag("struggle") then
			if inst.sg:HasStateTag("canattach") or not inst.sg:HasStateTag("nointerrupt") then
				inst.sg.statemem.struggling = true
				inst.sg:GoToState("collide", 0)
			end
		elseif not inst.defeated then
			if not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt") then
				inst.sg:GoToState("hit", inst.sg.statemem.trytired)
			end
		end
	end),
}

--------------------------------------------------------------------------

local PILLAR_TAGS = { "daywalker_pillar", "MINE_workable" }

local function RandomPillarFacing(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local pillars = TheSim:FindEntities(x, y, z, 16, PILLAR_TAGS)
	local x2, z2, count = 0, 0, 0
	for i, v in ipairs(pillars) do
		local x1, y1, z1 = v.Transform:GetWorldPosition()
		x2 = x2 + x1
		z2 = z2 + z1
		count = count + 1
	end
	if count > 0 then
		x2 = x2 / count
		z2 = z2 / count
		if distsq(x, z, x2, z2) >= 25 then
			local dir = math.atan2(z - z2, x2 - x) * RADIANS
			inst.Transform:SetRotation(dir + math.random() * 40 - 20)
			return
		end
	end
	inst.Transform:SetRotation(math.random() * 360)
end

local STRUGGLE_AOE_RANGE = 1.5
local STRUGGLE_AOE_RANGE_OFFSET = .5
local PILLAR_RANGE = 1

local function TryCollidePillar(inst, forward)
	local x, y, z = inst.Transform:GetWorldPosition()
	local x1, z1 = x, z
	local range = STRUGGLE_AOE_RANGE + PILLAR_RANGE
	if forward then
		local theta = inst.Transform:GetRotation() * DEGREES
		x1 = x1 + math.cos(theta) * STRUGGLE_AOE_RANGE_OFFSET
		z1 = z1 - math.sin(theta) * STRUGGLE_AOE_RANGE_OFFSET
	else
		range = range + STRUGGLE_AOE_RANGE_OFFSET
	end
	local collided
	for i, v in ipairs(TheSim:FindEntities(x1, 0, z1, range, PILLAR_TAGS)) do
		v:OnCollided(inst)
		collided = collided or v
	end
	if collided ~= nil then
		x1, y, z1 = collided.Transform:GetWorldPosition()
		inst.Transform:SetRotation(math.atan2(z - z1, x1 - x) * RADIANS)
		inst.sg.statemem.struggling = true
		inst.sg:GoToState("collide")
	end
end

local function TryDetachLeech(inst, attachpos, speedmult, randomdir)
	if next(inst._incoming_jumps) == nil then
		local t = GetTime()
		if t > (inst.sg.mem.detachtime or 0) then
			if inst:DetachLeech(attachpos, speedmult, randomdir) then
				inst.sg.mem.detachtime = t + 2
			end
		end
	end
end

--------------------------------------------------------------------------

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local MAX_SIDE_TOSS_STR = 0.8

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot0, x0, z0
	if dist ~= 0 then
		if dist > 0 and ((mult ~= nil and mult > 1) or (heavymult ~= nil and heavymult > 1)) then
			x0, z0 = x, z
		end
		rot0 = inst.Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot0)
		z = z - dist * math.sin(rot0)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
		if v ~= inst and
			not (targets ~= nil and targets[v]) and
			v:IsValid() and not v:IsInLimbo()
			and not (v.components.health ~= nil and v.components.health:IsDead())
			then
			local range = radius + v:GetPhysicsRadius(0)
			if v:GetDistanceSqToPoint(x, y, z) < range * range and inst.components.combat:CanTarget(v) then
				inst.components.combat:DoAttack(v)
				if mult ~= nil then
					local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
					if strengthmult > MAX_SIDE_TOSS_STR and x0 ~= nil then
						--Don't toss as far to the side for frontal attacks
						local rot1 = (v:GetAngleToPoint(x0, 0, z0) + 180) * DEGREES
						local k = math.max(0, math.cos(math.min(PI, DiffAngleRad(rot1, rot0) * 2)))
						strengthmult = MAX_SIDE_TOSS_STR + (strengthmult - MAX_SIDE_TOSS_STR) * k * k
					end
					v:PushEvent("knockback", { knocker = inst, radius = radius + dist + 3, strengthmult = strengthmult, forcelanded = forcelanded })
				end
				if targets ~= nil then
					targets[v] = true
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end

local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	HAMMER = true,
	MINE = true,
	-- no digging
}
local COLLAPSIBLE_TAGS = { "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO" }

local function DoAOEWork(inst, dist, radius, targets)
	local x, y, z = inst.Transform:GetWorldPosition()
	if dist ~= 0 then
		local rot = inst.Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)) do
		if not (targets ~= nil and targets[v]) and v:IsValid() and not v:IsInLimbo() and v.components.workable ~= nil then
			local work_action = v.components.workable:GetWorkAction()
			--V2C: nil action for NPC_workable (e.g. campfires)
			if (work_action == nil and v:HasTag("NPC_workable")) or
				(v.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
				then
				if v:HasTag("daywalker_pillar") then
					v:OnCollided(inst)
				else
					v.components.workable:Destroy(inst)
					--[[if v:IsValid() and v:HasTag("stump") then
						v:Remove()
					end]]
				end
			end
		end
	end
end

--------------------------------------------------------------------------

local SLAM_DETECT_MAX_ROT = 60
local SLAM_DETECT_RANGE_SQ = 9 * 9
local WAKEUP_SLAM_DETECT_RANGE_SQ = 6 * 6

local function IsSlamTarget(x, z, guy, rangesq, checkrot)
	if guy:IsValid() and
		--guy:HasTag("player") and
		not (guy.components.health ~= nil and
			guy.components.health:IsDead() or
			guy:HasTag("playerghost")) and
		guy.entity:IsVisible()
		then
		local x1, y1, z1 = guy.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		return dx * dx + dz * dz < SLAM_DETECT_RANGE_SQ
			and (checkrot == nil or DiffAngle(checkrot, math.atan2(-dz, dx) * RADIANS) < SLAM_DETECT_MAX_ROT)
			and TheWorld.Map:IsAboveGroundAtPoint(x1, y1, z1)
	end
	return false
end

local function FindSlamTarget(inst, rangesq)
	local x, y, z = inst.Transform:GetWorldPosition()
	local target = inst.components.combat.target
	if target ~= nil and IsSlamTarget(x, z, target, rangesq, nil) then
		return target
	end
	local targets = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if k ~= target then
			table.insert(targets, k)
		end
	end
	for i = 1, #targets do
		local rnd = math.random(#targets)
		target = targets[rnd]
		if IsSlamTarget(x, z, target, rangesq, nil) then
			return target
		end
		targets[rnd] = targets[#targets]
		targets[#targets] = nil
	end
	return nil
end

--------------------------------------------------------------------------

local CHATTER_DELAYS =
{
	--NOTE: len must work for (net_tinybyte)
	["DAYWALKER_SHAKE_LEECHES"] =	{ delay = 2, len = 1 },
	["DAYWALKER_COLLIDE"] =			{ delay = 0, len = 1 },
	["DAYWALKER_LEECH_BITE"] =		{ delay = 0.5, len = 1 },
	["DAYWALKER_TIRED"] =			{ delay = 3, len = 1.5 },
	["DAYWALKER_POWERDOWN"] =		{ delay = 3, len = 1.5 },
	["DAYWALKER_ATTACK"] =			{ delay = 4, len = 1.5 },
}

local function TryChatter(inst, strtblname, index, ignoredelay, echotochatpriority)
	-- 'echotochatpriority' defaults to CHATPRIORITIES.LOW if nil is passed.
	SGDaywalkerCommon.TryChatter(inst, CHATTER_DELAYS, strtblname, index, ignoredelay, echotochatpriority)
end

--------------------------------------------------------------------------

local states =
{
	State{
		name = "transition",
	},

	--------------------------------------------------------------------------
	--PHASE 1
	--------------------------------------------------------------------------

	State{
		name = "tired_pre",
		tags = { "tired", "busy", "nointerrupt", "canattach", "notiredhit" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("tired_pre")
			inst:ResetFatigue()
			inst.sg.mem.tired_start = GetTime()
			if inst.defeated then
				inst:SetHeadTracking(false)
			end
		end,

		timeline =
		{
			--steps
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),

			FrameEvent(12, function(inst)
				inst.sg:RemoveStateTag("notiredhit")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.tired = true
					inst.sg:GoToState("tired")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.tired then
				inst.sg.mem.last_tired_hit = nil
				inst.sg.mem.tired_start = nil
				inst.sg.mem.tired_hit_alt_count = nil
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
				else
					inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
				end
			end
		end,
	},

	State{
		name = "tired",
		tags = { "tired", "busy", "nointerrupt", "canattach" },

		onenter = function(inst, loops)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			if not inst.AnimState:IsCurrentAnimation("chained_idle") then
				inst.AnimState:PlayAnimation("chained_idle", true)
			end
			inst:ResetFatigue()
			inst.sg.mem.tired_start = inst.sg.mem.tired_start or GetTime()
			inst.sg.statemem.loops = loops or 0
			if inst.defeated then
				inst.components.health:StopRegen()
				TryChatter(inst, "DAYWALKER_POWERDOWN")
			elseif inst.hostile then
				if inst.engaged and inst.sg.statemem.loops >= 0 then
					inst.components.health:StartRegen(TUNING.DAYWALKER_COMBAT_TIRED_HEALTH_REGEN, TUNING.DAYWALKER_COMBAT_HEALTH_REGEN_PERIOD, false)
				end
				TryChatter(inst, "DAYWALKER_TIRED", 1)
			elseif inst:HasLeechTracked() then
				inst.components.health:SetAbsorptionAmount(0)
				inst.components.health:StopRegen()
				inst.components.sanityaura.aura = -TUNING.SANITYAURA_SUPERHUGE
			else
				inst.components.health:SetAbsorptionAmount(1)
				inst.components.health:StartRegen(math.max(TUNING.DAYWALKER_HEALTH_REGEN, TUNING.DAYWALKER_HEALTH / 10), 0.5, false)
				inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
				TryChatter(inst, "DAYWALKER_TIRED", (inst.sg.mem.last_tired_hit or 0) + 4 >= GetTime() and 1 or nil)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		ontimeout = function(inst)
			inst.sg.statemem.tired = true
			if inst.defeated then
				inst.sg:GoToState("tired", inst.sg.statemem.loops + 1)
			elseif inst.hostile then
				if inst.sg.mem.tired_start + (inst.sg.mem.last_tired_hit ~= nil and TUNING.DAYWALKER_FATIGUE_TIRED_MIN_TIME or TUNING.DAYWALKER_FATIGUE_TIRED_MAX_TIME) < GetTime() then
					inst.sg:GoToState("tired_stand")
				else
					inst.sg.statemem.hostileloop = true
					inst.sg:GoToState("tired", inst.sg.statemem.loops + 1)
				end
			elseif inst:HasLeechTracked() then
				inst.sg:GoToState("tired")
			elseif inst.sg.statemem.loops < 3 or inst.components.health:IsHurt() then
				inst.sg:GoToState("tired", inst.sg.statemem.loops + 1)
			else
				inst.components.health:SetAbsorptionAmount(0)
				inst.components.health:StopRegen()
				inst:MakeHostile()
				--force initial stalking (ability may still be locked)
				inst.components.combat:TryRetarget()
				inst:SetStalking(inst.components.combat.target)
				inst.sg:GoToState("tired_stand")
			end
		end,

		onexit = function(inst)
			if not inst.sg.statemem.tired then
				inst.sg.mem.last_tired_hit = nil
				inst.sg.mem.tired_start = nil
				inst.sg.mem.tired_hit_alt_count = nil
				if not inst.hostile then
					inst.components.health:SetAbsorptionAmount(0)
					inst.components.health:StopRegen()
				end
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
				else
					inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
				end
			end
			if inst.hostile and inst.engaged and not inst.sg.statemem.hostileloop then
				inst.components.health:StopRegen()
			end
		end,
	},

	State{
		name = "tired_hit",
		tags = { "tired", "busy", "nointerrupt", "canattach", "notalksound", "notiredhit" },

		onenter = function(inst, loops)
			inst.sg.statemem.isincombat = inst.hostile and not inst.defeated
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			if inst.hostile and not inst.defeated then
				inst.sg.mem.tired_hit_alt_count = (inst.sg.mem.tired_hit_alt_count or 0) + 1
				if inst.sg.mem.tired_hit_alt_count <= 0 then
					inst.AnimState:PlayAnimation("chained_hit")
				elseif inst.sg.mem.tired_hit_alt_count > math.random(3) then
					inst.sg.mem.tired_hit_alt_count = math.random(2) - 2
					inst.AnimState:PlayAnimation("chained_hit")
				else
					inst.sg.statemem.alt = true
					inst.AnimState:PlayAnimation("tired_hit")
				end
			else
				inst.AnimState:PlayAnimation("chained_hit")
			end
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			inst.sg.statemem.loops = loops
			inst.sg.mem.last_tired_hit = GetTime()
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				if inst.defeated then
					TryChatter(inst, "DAYWALKER_POWERDOWN")
				else
					TryChatter(inst, "DAYWALKER_TIRED", 1)
				end
				if not inst.sg.statemem.alt then
					if inst.hostile and inst.sg.mem.tired_start + TUNING.DAYWALKER_FATIGUE_TIRED_MIN_TIME < GetTime() then
						inst.sg.statemem.tired = true
						inst.sg:GoToState("tired_stand")
					else
						inst.sg:RemoveStateTag("notiredhit")
					end
				end
			end),
			FrameEvent(12, function(inst)
				if inst.sg.statemem.alt then
					if inst.hostile and inst.sg.mem.tired_start + TUNING.DAYWALKER_FATIGUE_TIRED_MIN_TIME < GetTime() then
						inst.sg.statemem.tired = true
						inst.sg:GoToState("tired_stand")
					else
						inst.sg:RemoveStateTag("notiredhit")
					end
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.tired = true
					if not inst.hostile then
						inst.sg:GoToState("tired", inst.sg.statemem.loops)
					elseif inst.sg.mem.tired_start + TUNING.DAYWALKER_FATIGUE_TIRED_MIN_TIME < GetTime() then
						inst.sg:GoToState("tired_stand")
					else
						inst.sg:GoToState("tired", -1) --delayed hp regen
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.tired then
				inst.sg.mem.last_tired_hit = nil
				inst.sg.mem.tired_start = nil
				inst.sg.mem.tired_hit_alt_count = nil
				if not inst.hostile then
					inst.components.health:SetAbsorptionAmount(0)
					inst.components.health:StopRegen()
				end
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
				else
					inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
				end
			end
		end,
	},

	State{
		name = "tired_stand",
		tags = { "busy", "nointerrupt" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			if not inst:IsStalking() then
				if not inst.components.timer:TimerExists("roar_cd") and math.random() < 0.5 then
					inst.sg.statemem.roar = true
				elseif inst.canwakeuphit and FindSlamTarget(inst, WAKEUP_SLAM_DETECT_RANGE_SQ) ~= nil then
					--don't stalk
				elseif inst.canstalk and not inst.components.timer:TimerExists("stalk_cd") then
					inst:SetStalking(inst.components.combat.target)
				end
			end
			if inst:IsStalking() then
				inst:StartAttackCooldown()
				inst.sg.statemem.stalkingstand = true
				inst.AnimState:PlayAnimation("tired_standwalk")
				inst.AnimState:PushAnimation("tired_idlewalk")
			else
				inst.AnimState:PlayAnimation("tired_stand")
				inst.AnimState:PushAnimation("tired_idle")
			end
			inst.sg.mem.last_tired_hit = nil
			inst.sg.mem.tired_start = nil
			inst.sg.mem.tired_hit_alt_count = nil
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				if inst.canwakeuphit and not (inst.sg.statemem.stalkingstand or inst.sg.statemem.roar) then
					local slamtarget = FindSlamTarget(inst, SLAM_DETECT_RANGE_SQ)
					if slamtarget ~= nil then
						inst:ForceFacePoint(slamtarget.Transform:GetWorldPosition())
						inst.sg:GoToState("attack_slam", slamtarget)
					end
				end
			end),
			FrameEvent(16, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.5) end),
		},

		ontimeout = function(inst)
			if inst.sg.statemem.roar then
				inst.sg:GoToState("taunt", inst.components.combat.target)
			else
				--basically transitioned to phase 2, but staying here for NoFaced model
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nointerrupt")
				inst.sg:AddStateTag("idle")
				inst.sg:AddStateTag("canrotate")
			end
		end,

		onexit = function(inst)
			if inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			else
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "struggle_idle",
		tags = { "busy", "nointerrupt", "canattach" },

		onenter = function(inst)
			--inst.components.locomotor:Stop()
			--inst.AnimState:PlayAnimation("struggle_idle", true)
			if not inst:HasLeechAttached() then
				inst.sg:GoToState("tired_pre")
			elseif (inst.sg.mem.struggle_count or 0) > 1 or math.random() < 0.5 then
				inst.sg:GoToState("shrug1")
			else
				inst.sg:GoToState("struggle1")
			end
		end,
	},

	State{
		name = "struggle1",
		tags = { "struggle", "busy", "nointerrupt", "notalksound", "canattach" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("struggle1")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			inst.sg.mem.struggle_count = (inst.sg.mem.struggle_count or 0) + 1
			inst.sg.mem.shrug_count = 0
			TryChatter(inst, "DAYWALKER_SHAKE_LEECHES", nil, nil, CHATPRIORITIES.HIGH)
		end,

		timeline =
		{
			FrameEvent(3, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),
			FrameEvent(5, function(inst)
				TryDetachLeech(inst, { "top", "right" }, 0.55 + math.random() * 0.1, true)
				inst.sg.statemem.targets = {}
				DoAOEAttack(inst, 0, 1.8, nil, nil, nil, inst.sg.statemem.targets)
			end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.1) end),
			FrameEvent(11, function(inst)
				TryDetachLeech(inst, { "left", "top" }, 0.55 + math.random() * 0.1, true)
			end),
			FrameEvent(12, function(inst)
				if math.random() < 0.5 then
					inst.sg.statemem.chain = shallowcopy(inst.sg.statemem.targets)
				end
				DoAOEAttack(inst, 0, 1.8, nil, nil, nil, inst.sg.statemem.targets)
			end),
			FrameEvent(13, function(inst)
				if inst.sg.statemem.chain == nil then
					TryCollidePillar(inst, false)
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.struggling = true
					if inst.sg.statemem.chain ~= nil then
						for k in pairs(inst.sg.statemem.chain) do
							inst.sg.statemem.targets[k] = nil
						end
						inst.sg:GoToState("struggle2", inst.sg.statemem.targets)
					else
						inst.sg:GoToState("struggle1_pst")
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "struggle1_pst",
		tags = { "struggle", "busy", "nointerrupt", "canattach" },

		onenter = function(inst)
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("struggle1_pst")
			inst.sg:SetTimeout(GetRandomMinMax(4 * FRAMES, inst.AnimState:GetCurrentAnimationLength()))
		end,

		ontimeout = function(inst)
			inst.sg.statemem.struggling = true
			inst.sg:GoToState("struggle_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "struggle2",
		tags = { "struggle", "busy", "nointerrupt", "notalksound", "canattach" },

		onenter = function(inst, targets)
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("struggle2")
			inst.sg:SetTimeout(GetRandomMinMax(13 * FRAMES, inst.AnimState:GetCurrentAnimationLength()))
			inst.sg.statemem.targets = targets
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.1)
				TryDetachLeech(inst, { "top", "right" }, 0.55 + math.random() * 0.1, true)
			end),
			FrameEvent(1, function(inst)
				DoAOEAttack(inst, 0, 1.8, nil, nil, nil, inst.sg.statemem.targets)
			end),
			FrameEvent(3, function(inst)
				TryCollidePillar(inst, false)
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.struggling = true
			inst.sg:GoToState("struggle_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "shrug1",
		tags = { "struggle", "busy", "nointerrupt", "notalksound", "canattach" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("shrug1")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			RandomPillarFacing(inst)
			inst.Physics:SetMotorVelOverride(2, 0, 0)
			inst.sg.mem.shrug_count = (inst.sg.mem.shrug_count or 0) + 1
			inst.sg.mem.struggle_count = 0
			TryChatter(inst, "DAYWALKER_SHAKE_LEECHES", nil, nil, CHATPRIORITIES.HIGH)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.colliding then
				TryCollidePillar(inst, true)
			end
		end,

		timeline =
		{
			FrameEvent(5, function(inst) inst.Physics:SetMotorVelOverride(6, 0, 0) end),
			FrameEvent(6, function(inst) inst.Physics:SetMotorVelOverride(12, 0, 0) end),
			FrameEvent(7, function(inst)
				TryDetachLeech(inst, "right", 0.9 + math.random() * 0.2)
				DoAOEAttack(inst, 1.2, 1.8)
			end),
			FrameEvent(8, function(inst)
				inst.Physics:SetMotorVelOverride(6, 0, 0)
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.6)
			end),
			FrameEvent(9, function(inst)
				inst.Physics:SetMotorVelOverride(4, 0, 0)
				inst.sg.statemem.colliding = true
			end),
			FrameEvent(10, function(inst) inst.Physics:SetMotorVelOverride(2, 0, 0) end),
			FrameEvent(11, function(inst)
				inst.sg.statemem.colliding = false
			end),
			FrameEvent(12, function(inst) inst.Physics:SetMotorVelOverride(1, 0, 0) end),
			FrameEvent(13, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2) end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.struggling = true
					if math.random() < 0.5 then
						inst.sg.statemem.shrugging = true
						inst.sg:GoToState("shrug2")
					else
						inst.sg:GoToState("shrug_pst")
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
			if not inst.sg.statemem.shrugging then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end
		end,
	},

	State{
		name = "shrug2",
		tags = { "struggle", "busy", "nointerrupt", "notalksound", "canattach" },

		onenter = function(inst)
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("shrug2")
			inst.Physics:SetMotorVelOverride(1, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.colliding then
				TryCollidePillar(inst, true)
			end
		end,

		timeline =
		{
			FrameEvent(2, function(inst) inst.Physics:SetMotorVelOverride(4, 0, 0) end),
			FrameEvent(3, function(inst)
				inst.Physics:SetMotorVelOverride(8, 0, 0)
				TryDetachLeech(inst, "right", 0.75 + math.random() * 0.2)
			end),
			FrameEvent(4, function(inst)
				DoAOEAttack(inst, 1.1, 1.8)
			end),
			FrameEvent(5, function(inst)
				inst.Physics:SetMotorVelOverride(4, 0, 0)
				inst.sg.statemem.colliding = true
			end),
			FrameEvent(6, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.6) end),
			FrameEvent(7, function(inst)
				inst.Physics:SetMotorVelOverride(2, 0, 0)
				inst.sg.statemem.colliding = false
			end),
			FrameEvent(9, function(inst) inst.Physics:SetMotorVelOverride(1, 0, 0) end),
			FrameEvent(11, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2) end),
			FrameEvent(12, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.struggling = true
					inst.sg:GoToState("shrug_pst")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
		end,
	},

	State{
		name = "shrug_pst",
		tags = { "struggle", "busy", "nointerrupt", "canattach" },

		onenter = function(inst)
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("shrug_pst")
			inst.sg:SetTimeout(math.random() * inst.AnimState:GetCurrentAnimationLength())
		end,

		ontimeout = function(inst)
			inst.sg.statemem.struggling = true
			inst.sg:GoToState("struggle_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "collide",
		tags = { "struggle", "busy", "nointerrupt", "notalksound", "canattach" },

		onenter = function(inst, speedmult)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("collide")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")

			inst.sg.statemem.speedmult = speedmult or 1

			TryChatter(inst, "DAYWALKER_COLLIDE")

			inst.sg:SetTimeout(GetRandomMinMax(16 * FRAMES, inst.AnimState:GetCurrentAnimationLength()))
		end,

		timeline =
		{
			FrameEvent(1, function(inst) inst.Physics:SetMotorVelOverride(-3 * inst.sg.statemem.speedmult, 0, 0) end),
			FrameEvent(3, function(inst) inst.Physics:SetMotorVelOverride(-1 * inst.sg.statemem.speedmult, 0, 0) end),
			FrameEvent(5, function(inst) inst.Physics:SetMotorVelOverride(-.5 * inst.sg.statemem.speedmult, 0, 0) end),
			FrameEvent(7, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),
			FrameEvent(13, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.struggling = true
			inst.sg:GoToState("struggle_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
		end,
	},

	State{
		name = "attach",
		tags = { "struggle", "busy", "nointerrupt", "notalksound", "canattach" },

		onenter = function(inst, attachpos)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("attach_"..(attachpos or "top").."_leech")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2)
			inst.sg.mem.detachtime = math.max(inst.sg.mem.detachtime or 0, GetTime() + 1)
			TryChatter(inst, "DAYWALKER_LEECH_BITE")
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		ontimeout = function(inst)
			inst.sg.statemem.struggling = true
			inst.sg:GoToState("struggle_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.struggling then
				inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
			end
		end,
	},

	--------------------------------------------------------------------------
	--PHASE 2
	--------------------------------------------------------------------------

	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			if inst.defeated then
				inst.sg:GoToState("tired_pre")
				return
			end
			inst.components.locomotor:Stop()
			if inst:IsStalking() then
				inst.sg:AddStateTag("stalking")
				inst:SetHeadTracking(true)
				inst.AnimState:PlayAnimation("idlewalk", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
		end,
	},

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst, trytired)
			if inst:IsStalking() then
				inst:SetStalking(nil)
				if inst.nostalkcd then
					inst.components.combat:ResetCooldown()
				end
			end
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
			inst.sg.statemem.trytired = trytired
		end,

		timeline =
		{
			FrameEvent(9, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(11, function(inst)
				if inst.sg.statemem.trytired and inst:IsFatigued() or inst.defeated then
					inst.sg:GoToState("tired_pre")
				end
			end),
			FrameEvent(13, function(inst)
				if not inst.defeated and not (inst.sg.statemem.doattack and ChooseAttack(inst)) then
					inst.sg:RemoveStateTag("busy")
				end
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst)
				inst.sg.statemem.doattack = true
				return inst.sg:HasStateTag("busy")
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.trytired and inst:IsFatigued() or inst.defeated then
						inst.sg:GoToState("tired_pre")
					else
						inst.sg:GoToState("idle")
					end
				end
			end),
		},
	},

	State{
		name = "attack_pounce_pre",
		tags = { "attack", "busy", "jumping" },

		onenter = function(inst, data)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst.AnimState:PlayAnimation("run_pre")
			inst.SoundEmitter:PlaySound(inst.footstep)
			if data ~= nil then
				if data.target ~= nil and data.target:IsValid() then
					inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
				end
				inst.sg.statemem.speedmult = not data.running and 0.8 or nil
			end
			inst.Physics:SetMotorVelOverride(11 * (inst.sg.statemem.speedmult or 1), 0, 0)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.pouncing = true
					inst.sg:GoToState("attack_pounce", inst.sg.statemem.speedmult)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.pouncing then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			end
		end,
	},

	State{
		name = "attack_pounce",
		tags = { "attack", "busy", "jumping", "nointerrupt", "notalksound" },

		onenter = function(inst, speedmult)
			inst:SetStalking(nil)
			--inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst:StartAttackCooldown()
			inst.AnimState:PlayAnimation("atk3")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			inst.SoundEmitter:PlaySound("daywalker/action/attack3")
			TryChatter(inst, "DAYWALKER_ATTACK")
			inst.sg.statemem.speedmult = speedmult or 1
			inst.Physics:SetMotorVelOverride(11 * inst.sg.statemem.speedmult, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * inst.sg.statemem.speedmult, 0, 0)
			end
			if inst.sg.statemem.collides ~= nil then
				DoAOEAttack(inst, 0.2, 1.4, nil, nil, nil, inst.sg.statemem.collides)
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_POUNCE_DAMAGE)
				inst.sg.statemem.collides = {}
			end),
			FrameEvent(5, function(inst)
				inst.sg.statemem.collides = nil
			end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.footstep) end),
			FrameEvent(11, SGDaywalkerCommon.DoPounceShake),
			FrameEvent(12, function(inst)
				inst.sg:AddStateTag("pounce_recovery")
				inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_XCLAW_DAMAGE)
				local targets = {}
				inst.sg.statemem.targets = targets
				DoAOEWork(inst, 3, 3, targets)
				DoAOEWork(inst, 0.4, 1.6, targets)
				DoAOEAttack(inst, 3, 3, 1 + 0.1 * inst.sg.statemem.speedmult, 1 + 0.2 * inst.sg.statemem.speedmult, false, targets)
				DoAOEAttack(inst, 0.4, 1.6, 1, 1, false, targets)
				--local targets table; this code is valid even if we left state
				for k in pairs(targets) do
					if k:IsValid() and k:HasTag("smallcreature") then
						targets[k] = nil
					end
				end
				if next(targets) ~= nil then
					--reinvigorated when successfully hitting something not small
					inst:DeltaFatigue(TUNING.DAYWALKER_FATIGUE.POUNCE_HIT)
				else
					--getting tired from whiffing all these dashing attacks
					inst:DeltaFatigue(TUNING.DAYWALKER_FATIGUE.POUNCE_MISS)
				end
			end),
			FrameEvent(14, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
			end),
			FrameEvent(15, function(inst)
				inst.sg.statemem.speed = 8
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.targets ~= nil and next(inst.sg.statemem.targets) ~= nil then
						local target = inst.components.combat.target
						local targethit = target ~= nil and inst.sg.statemem.targets[target]
						local slamtarget
						if inst.canslam then
							local x, y, z = inst.Transform:GetWorldPosition()
							local rot = inst.Transform:GetRotation()
							if targethit and IsSlamTarget(x, z, target, SLAM_DETECT_RANGE_SQ, rot) then
								slamtarget = target
							else
								local targets = {}
								for k in pairs(inst.sg.statemem.targets) do
									if k ~= target and IsSlamTarget(x, z, k, SLAM_DETECT_RANGE_SQ, rot) then
										table.insert(targets, k)
									end
								end
								slamtarget = #targets > 0 and targets[math.random(#targets)] or nil
							end
						end
						if slamtarget ~= nil then
							if inst.hostile then
								inst.components.combat:SetTarget(slamtarget)
							end
							inst.sg.statemem.slam = true
							inst.sg:GoToState("attack_slam", slamtarget)
						else
							inst.sg:GoToState("attack_pounce_pst", targethit)
						end
					elseif inst.sg.statemem.speedmult >= 1 and inst:IsFatigued() then
						inst.sg:GoToState("attack_pounce_pst_tired")
					else
						inst.sg:GoToState("attack_pounce_pst")
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.slam then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.components.locomotor:EnableGroundSpeedMultiplier(true)
				inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
			end
		end,
	},

	State{
		name = "attack_pounce_pst",
		tags = { "busy", "caninterrupt", "pounce_recovery" },

		onenter = function(inst, targethit)
			inst.AnimState:PlayAnimation("atk3_pst")
			inst.sg.statemem.trystalk = targethit
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.canstalk and (inst.sg.statemem.trystalk or inst.nostalkcd) and not (inst:IsStalking() or inst.components.timer:TimerExists("stalk_cd")) then
						inst:SetStalking(inst.components.combat.target)
					end
					if not (inst:IsStalking() or inst.components.timer:TimerExists("roar_cd")) and math.random() < 0.25 then
						inst.sg:GoToState("taunt") --don't change facing
					else
						inst.sg:GoToState("idle")
					end
				end
			end),
		},
	},

	State{
		name = "attack_pounce_pst_tired",
		tags = { "busy", "caninterrupt", "pounce_recovery" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("atk3_pst_tired")
			TryChatter(inst, "DAYWALKER_TIRED", 1, true)
			inst.sg.statemem.trytired = true --for going to "hit" state
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("tired_pre")
				end
			end),
		},
	},

	State{
		name = "attack_slam_pre",
		tags = { "attack", "busy", "jumping" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst.AnimState:PlayAnimation("atk_slam_pre")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst.sg.statemem.speed = 3.5
			inst.sg.statemem.decel = -0.25
		end,

		onupdate = function(inst)
			if inst.sg.statemem.decel ~= 0 then
				if inst.sg.statemem.speed <= 0 then
					inst.Physics:ClearMotorVelOverride()
					inst.Physics:Stop()
					inst.sg.statemem.decel = 0
				else
					inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
					inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.decel
				end
			end
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
			end),
			FrameEvent(18, function(inst)
				inst.sg.statemem.decel = 0
				inst.Physics:SetMotorVelOverride(1, 0, 0)
			end),
			FrameEvent(19, function(inst) inst.Physics:SetMotorVelOverride(2, 0, 0) end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.slam = true
					inst.sg:GoToState("attack_slam", inst.sg.statemem.target)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.slam then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			end
		end,
	},

	State{
		name = "attack_slam",
		tags = { "attack", "busy", "jumping", "notalksound" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst:StartAttackCooldown()
			inst.AnimState:PlayAnimation("atk_slam")
			TryChatter(inst, "DAYWALKER_ATTACK")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst.sg.statemem.tracking = true
				local x1, y1, z1 = target.Transform:GetWorldPosition()
				local rot = inst.Transform:GetRotation()
				local rot1 = inst:GetAngleToPoint(x1, y1, z1)
				local diff = DiffAngle(rot, rot1)
				if diff < 90 then
					inst.Transform:SetRotation(rot1)
				end
			end
			inst.sg.statemem.speedmult = 1
			inst.sg.statemem.speed = 2
			inst.sg.statemem.decel = 0
			inst.Physics:SetMotorVelOverride(2, 0, 0)
		end,

		onupdate = function(inst)
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
					if math.abs(drot) < 90 then
						rot1 = rot + math.clamp(drot / 2, -1, 1)
						inst.Transform:SetRotation(rot1)
					end
				end
			end
			if inst.sg.statemem.decel ~= 0 then
				if inst.sg.statemem.speed <= 0 then
					inst.Physics:ClearMotorVelOverride()
					inst.Physics:Stop()
					inst.sg.statemem.decel = 0
				else
					inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * inst.sg.statemem.speedmult, 0, 0)
					inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.decel
				end
			end
		end,

		timeline =
		{
			FrameEvent(1, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_whoosh") end),
			FrameEvent(2, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")
				inst.SoundEmitter:PlaySound(inst.footstep)
			end),
			FrameEvent(25, function(inst) inst.SoundEmitter:PlaySound("daywalker/action/attack_slam_down") end),

			FrameEvent(1, function(inst) inst.Physics:SetMotorVelOverride(8, 0, 0) end),
			FrameEvent(6, function(inst) inst.Physics:SetMotorVelOverride(2, 0, 0) end),
			FrameEvent(8, function(inst) inst.Physics:SetMotorVelOverride(1.5, 0, 0) end),
			FrameEvent(20, function(inst)
				inst.sg.statemem.tracking = false
				inst.Physics:SetMotorVelOverride(3, 0, 0)
			end),
			FrameEvent(21, function(inst)
				if inst.sg.statemem.targetpos ~= nil then
					local x, y, z = inst.Transform:GetWorldPosition()
					local dx = inst.sg.statemem.targetpos.x - x
					local dz = inst.sg.statemem.targetpos.z - z
					if dx ~= 0 or dz ~= 0 then
						local rot1 = math.atan2(-dz, dx)
						local diff = DiffAngleRad(inst.Transform:GetRotation() * DEGREES, rot1)
						if diff * RADIANS < 60 then
							local dist = math.sqrt(dx * dx + dz * dz) * math.cos(diff)
							local maxdist = (12 + 20 + 3 * 36) * FRAMES
							inst.sg.statemem.speedmult = math.clamp(math.abs(dist / maxdist), 0.25, 1.2)
						else
							inst.sg.statemem.speedmult = 1
						end
					else
						inst.sg.statemem.speedmult = 0.25
					end
				end
				inst.Physics:SetMotorVelOverride(12 * inst.sg.statemem.speedmult, 0, 0)
			end),
			FrameEvent(22, function(inst) inst.Physics:SetMotorVelOverride(20 * inst.sg.statemem.speedmult, 0, 0) end),
			FrameEvent(23, function(inst) inst.Physics:SetMotorVelOverride(36 * inst.sg.statemem.speedmult, 0, 0) end),
			FrameEvent(24, function(inst)
				inst.sg:AddStateTag("nointerrupt")
			end),
			FrameEvent(26, function(inst)
				inst.sg.statemem.speed = 4
				inst.sg.statemem.decel = -1

				local sinkhole = SpawnPrefab("daywalker_sinkhole")
				sinkhole.Transform:SetPosition(inst.Transform:GetWorldPosition())
				sinkhole:PushEvent("docollapse")

				inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_SLAM_DAMAGE)
				local targets = {}
				inst.sg.statemem.targets = targets
				DoAOEAttack(inst, 0, TUNING.DAYWALKER_SLAM_SINKHOLERADIUS, 0.7, 0.7, false, targets)
				--local targets table; this code is valid even if we left state
				for k in pairs(targets) do
					if k:IsValid() and k:HasTag("smallcreature") then
						targets[k] = nil
					end
				end
				if next(targets) ~= nil then
					--reinvigorated when successfully hitting something not small
					inst:DeltaFatigue(TUNING.DAYWALKER_FATIGUE.SLAM_HIT)
				end
			end),
			FrameEvent(61, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.canstalk and not (inst:IsStalking() or inst.components.timer:TimerExists("stalk_cd")) and inst.sg.statemem.targets ~= nil then
						local target = inst.components.combat.target
						if target ~= nil and (inst.nostalkcd or inst.sg.statemem.targets[target]) then
							inst:SetStalking(target)
						end
					end
					if not (inst:IsStalking() or inst.components.timer:TimerExists("roar_cd")) and math.random() < 0.25 then
						inst.sg:GoToState("taunt") --don't change facing
					else
						inst.sg:GoToState("idle")
					end
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
		end,
	},

	State{
		name = "taunt",
		tags = { "taunt", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("taunt")
			if target ~= nil and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst:SetStalking(nil)
			inst.components.timer:StopTimer("roar_cd")
			inst.components.timer:StartTimer("roar_cd", TUNING.DAYWALKER_ROAR_CD)
			if inst.canstalk and not inst.nostalkcd then
				local mincd = TUNING.DAYWALKER_STALK_CD / 2
				local cd = inst.components.timer:GetTimeLeft("stalk_cd")
				if cd == nil then
					inst.components.timer:StartTimer("stalk_cd", mincd)
				elseif cd < mincd then
					inst.components.timer:SetTimeLeft("stalk_cd", mincd)
				end
			end
		end,

		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_2") end),
			FrameEvent(18, function(inst)
				inst.components.epicscare:Scare(5)
			end),
			FrameEvent(19, function(inst)
				inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3)
				SGDaywalkerCommon.DoRoarShake(inst)
			end),
			FrameEvent(38, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(47, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2) end),
			FrameEvent(50, function(inst)
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
	},

	--------------------------------------------------------------------------
	--DEFEATED
	--------------------------------------------------------------------------

	State{
		name = "defeat",
		tags = { "defeated", "busy", "nointerrupt" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("defeat")
		end,

		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/hurt") end),
			FrameEvent(7, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(23, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/speak_short") end),
			FrameEvent(33, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt") end),
			FrameEvent(34, SGDaywalkerCommon.DoDefeatShake),
			FrameEvent(36, function(inst)
				inst.sg:AddStateTag("noattack")
				if inst.defeated and not inst.looted then
					inst.looted = true
					inst.components.timer:ResumeTimer("despawn")
					inst.components.lootdropper:DropLoot(inst:GetPosition())
				end
			end),
			FrameEvent(48, function(inst)
				inst:RemoveTag("shadow_aligned")
			end),
			FrameEvent(76, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/speak_short") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.defeat = true
					inst.sg:GoToState("defeat_idle_pre")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.defeat then
				--Should not reach here
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
				else
					inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
				end
				inst:AddTag("shadow_aligned")
			end
		end,
	},

	State{
		name = "defeat_idle_pre",
		tags = { "defeated", "busy", "nointerrupt", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			inst:RemoveTag("shadow_aligned")
			inst.AnimState:PlayAnimation("defeat_idle_pre")
		end,

		timeline =
		{
			FrameEvent(12, function(inst)
				TryChatter(inst, "DAYWALKER_POWERDOWN")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.defeat = true
					inst.sg:GoToState("defeat_idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.defeat then
				--Should not reach here
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
				else
					inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
				end
				inst:AddTag("shadow_aligned")
			end
		end,
	},

	State{
		name = "defeat_idle",
		tags = { "defeated", "busy", "nointerrupt", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
			inst:RemoveTag("shadow_aligned")
			if not inst.AnimState:IsCurrentAnimation("defeat_idle_loop") then
				inst.AnimState:PlayAnimation("defeat_idle_loop", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(13, function(inst)
				TryChatter(inst, "DAYWALKER_POWERDOWN", nil, nil, CHATPRIORITIES.HIGH)
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.defeat = true
			inst.sg:GoToState("defeat_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.defeat then
				--Should not reach here
				if inst.sg.statemem.struggling then
					inst:SwitchToFacingModel(6) --inst.Transform:SetSixFaced()
				else
					inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
				end
				inst:AddTag("shadow_aligned")
			end
		end,
	},
}

SGDaywalkerCommon.AddWalkStates(states)
SGDaywalkerCommon.AddRunStates(states, nil,
{
	runonenter = function(inst)
		if not inst.components.combat:InCooldown() then
			local target = inst.components.combat.target
			if target and DiffAngle(inst.Transform:GetRotation(), inst:GetAngleToPoint(target.Transform:GetWorldPosition())) < 45 then
				TryChatter(inst, "DAYWALKER_ATTACK")
			end
		end
	end,
})

return StateGraph("daywalker", states, events, "idle")
