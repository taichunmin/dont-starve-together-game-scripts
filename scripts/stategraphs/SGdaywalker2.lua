--@V2C NOTE: -trying new thing; add "canrotate" to any interruptible nofaced state
--           -this is to fix cases where after a nofaced state, there is a flicker
--            of idle in the old direction before changing to new moving direction

require("stategraphs/commonstates")
local SGDaywalkerCommon = require("stategraphs/SGdaywalker_common")

--------------------------------------------------------------------------

local function ChooseAttack(inst)
	local target = inst.components.combat.target
	if target then
		--NOTE: there is a priority here, hence the duplicated attacks
		if inst.canswing and inst:IsNear(target, TUNING.DAYWALKER2_ATTACK_RANGE + 1) then
			inst.sg:GoToState("attack_swing", target)
			return true
		elseif inst.cancannon and inst:IsNear(target, TUNING.DAYWALKER2_CANNON_ATTACK_RANGE) then
			inst.sg:GoToState("cannon_pre", target)
			return true
		elseif inst.cantackle and inst:TestTackle(target, TUNING.DAYWALKER2_TACKLE_RANGE) then
			inst.sg:GoToState("tackle_pre", target)
			return true
		elseif inst.cancannon then
			inst.sg:GoToState("cannon_pre", target)
			return true
		elseif inst.canswing then
			inst.sg:GoToState("attack_swing", target)
			return true
		elseif inst.components.rooted or inst.components.stuckdetection:IsStuck() then
			inst.sg:GoToState("attack_pounce_pre", target)
			return true
		end
	end
end

local events =
{
	CommonHandlers.OnLocomote(true, true),
	EventHandler("freeze", function(inst)
		if not inst.defeated then
			inst.sg:GoToState("frozen")
		end
	end),
	EventHandler("gotosleep", function(inst)
		inst.sg.mem.sleeping = true
		if not inst.defeated and not (inst.sg:HasStateTag("nosleep") or inst.sg:HasStateTag("sleeping")) then
			inst.sg:GoToState("sleep")
		end
	end),
	EventHandler("onwakeup", function(inst)
		inst.sg.mem.sleeping = false
		if not inst.defeated and inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("nowake") then
			inst.sg.statemem.continuesleeping = true
			inst.sg:GoToState("wake")
		end
	end),
	EventHandler("ontalk", function(inst)
		if not (inst.hostile or inst.sg:HasStateTag("busy")) then
			if inst._thieflevel > 2 then
				inst.sg:GoToState("angry_taunt")
			elseif inst._thief and inst._thief:IsValid() and inst:IsNear(inst._thief, 8) then
				inst.sg.statemem.keepsixfaced = true
				inst.sg:GoToState("talk", inst.sg:HasStateTag("talking"))
			else
				inst.sg.statemem.keepnofaced = true
				inst.sg:GoToState("angry", inst.sg:HasStateTag("angry"))
			end
		end
	end),
	EventHandler("doattack", function(inst)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) then
			ChooseAttack(inst)
		end
	end),
	EventHandler("attacked", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) or inst.sg:HasStateTag("caninterrupt") then
			if inst.sg:HasStateTag("rummaging") then
				inst.sg:GoToState("rummage_hit", inst.sg.statemem.data)
			elseif not CommonHandlers.HitRecoveryDelay(inst) then
				inst.sg:GoToState("hit")
			end
		end
	end),
	EventHandler("roar", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) then
			inst.sg:GoToState("taunt", data ~= nil and data.target or nil)
		end
	end),
	EventHandler("minhealth", function(inst, data)
		if inst.defeated and not inst.sg:HasStateTag("defeated") then
			inst.sg:GoToState("defeat")
		end
	end),
	EventHandler("teleported", function(inst)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) or inst.sg:HasStateTag("caninterrupt") then
			inst.sg:GoToState("hit")
		end
	end),
	EventHandler("rummage", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) then
			inst.sg:GoToState("rummage", data)
		end
	end),
	EventHandler("tackle", function(inst, target)
		if not (inst.sg:HasStateTag("busy") or inst.defeated) and target and target:IsValid() then
			inst.sg:GoToState("tackle_pre", target)
		end
	end),
}

--------------------------------------------------------------------------

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "junk_fence" }
local NOBLOCK_AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "blocker" }

local function _AOEAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets, overridenontags)
	local hit = false
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	local arcx, cos_theta, sin_theta
	if dist ~= 0 or arc then
		local theta = inst.Transform:GetRotation() * DEGREES
		cos_theta = math.cos(theta)
		sin_theta = math.sin(theta)
		if dist ~= 0 then
			x = x + dist * cos_theta
			z = z - dist * sin_theta
		end
		if arc then
			--min-x for testing points converted to local space
			arcx = x + math.cos(arc / 2 * DEGREES) * radius
		end
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, overridenontags and NOBLOCK_AOE_TARGET_CANT_TAGS or AOE_TARGET_CANT_TAGS)) do
		if v ~= inst and
			not (targets and targets[v]) and
			v:IsValid() and not v:IsInLimbo() and
			not (v.components.health and v.components.health:IsDead())
		then
			local range = radius + v:GetPhysicsRadius(0)
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local dx = x1 - x
			local dz = z1 - z
			if dx * dx + dz * dz < range * range and
				--convert to local space x, and test against arcx
				(arcx == nil or x + cos_theta * dx - sin_theta * dz > arcx) and
				inst.components.combat:CanTarget(v)
			then
				inst.components.combat:DoAttack(v)
				if mult then
					local strengthmult = (v.components.inventory and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
					v:PushEvent("knockback", { knocker = inst, radius = radius + dist, strengthmult = strengthmult, forcelanded = forcelanded })
				end
				if targets then
					targets[v] = true
				end
				hit = true
			end
		end
	end
	inst.components.combat.ignorehitrange = false
	return hit
end

local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end

local NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO" }
local NOBLOCK_NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO", "blocker" }
local FOOTSTEP_NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO", "junk_pile_big" }

--Each step a bit under 1 second.
--The timeout is for resetting the counter to reach threshold, in case he's
--not stuck stationary, but is still trapped bouncing around in small area.
--Also could be stunlocked while trying to run through, slowing down steps.
local TRAMPLE_TIMEOUT = 5 --seconds
local TRAMPLE_THRESHOLD = 5 --steps
local FRONT_ANGLE_THRESHOLD = 60 * DEGREES

local function _OnTrampleTimeout(inst, trampledelays, target)
	trampledelays[target] = nil
end

local function _DoAOEWork(inst, dist, radius, arc, targets, canblock, overridenontags, trampledelays)
	local hit, blocked = false, false
	local x, y, z = inst.Transform:GetWorldPosition()
	local theta = inst.Transform:GetRotation() * DEGREES
	local arcx, cos_theta, sin_theta
	if dist ~= 0 or arc then
		cos_theta = math.cos(theta)
		sin_theta = math.sin(theta)
		if dist ~= 0 then
			x = x + dist * cos_theta
			z = z - dist * sin_theta
		end
		if arc then
			--min-x for testing points converted to local space
			arcx = x + math.cos(arc / 2 * DEGREES) * radius
		end
	end
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, nil, overridenontags or NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)) do
		if not (targets and targets[v]) and v:IsValid() and not v:IsInLimbo() then
			local range = radius + v:GetPhysicsRadius(0)
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local dx = x1 - x
			local dz = z1 - z
			if dx * dx + dz * dz < range * range and
				--convert to local space x, and test against arcx
				(arcx == nil or x + cos_theta * dx - sin_theta * dz > arcx) and
				v.components.workable
			then
				local work_action = v.components.workable:GetWorkAction()
				--V2C: nil action for NPC_workable (e.g. campfires)
				--     allow digging spawners (e.g. rabbithole)
				if (work_action == nil and v:HasTag("NPC_workable")) or
					(v.components.workable:CanBeWorked() and work_action and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
				then
					--blocked is if we want to stop when colliding with an obstacle in front of us
					local isblocker, infront
					if canblock and not blocked then
						isblocker = v:HasTag("blocker")
						infront = isblocker and (dx ~= 0 or dz ~= 0) and DiffAngleRad(theta, math.atan2(-dz, dx)) < FRONT_ANGLE_THRESHOLD
						if infront then
							blocked = true
						end
					end

					--obstacles take a few footsteps b4 getting destroyed by regular running
					local shoulddelaytrample
					if trampledelays then
						if isblocker == nil then
							isblocker = v:HasTag("blocker")
						end
						if isblocker then
							local data = trampledelays[v]
							if data == nil then
								trampledelays[v] =
								{
									n = 1,
									task = inst:DoTaskInTime(TRAMPLE_TIMEOUT, _OnTrampleTimeout, trampledelays, v),
								}
								shoulddelaytrample = true
							else
								data.n = data.n + 1
								data.task:Cancel()
								if data.n < TRAMPLE_THRESHOLD then
									data.task = inst:DoTaskInTime(TRAMPLE_TIMEOUT, _OnTrampleTimeout, trampledelays, v)
									shoulddelaytrample = true
								else
									trampledelays[v] = nil
								end
							end
						end
					elseif v:HasTag("junk_fence") then
						if inst.sg:HasStateTag("tackle") then
							if infront == nil then
								infront = (dx ~= 0 or dz ~= 0) and DiffAngleRad(theta, math.atan2(-dz, dx)) < FRONT_ANGLE_THRESHOLD
							end
							if not infront then
								--when tackling, only break junk fences directly in front of us
								shoulddelaytrample = true
							end
						else
							--when not trampling don't break junk fences
							shoulddelaytrample = true
						end
					end

					if shoulddelaytrample then
						v.components.workable:WorkedBy(inst, 0)
					else
						v.components.workable:Destroy(inst)
					end
					if targets then
						targets[v] = true
					end
					hit = true
				end
			end
		end
	end
	return hit, blocked
end

local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }
local TOSS_RADIUS_PADDING = 0.5

local function TossLaunch(inst, launcher, basespeed, startheight)
	local x0, y0, z0 = launcher.Transform:GetWorldPosition()
	local x1, y1, z1 = inst.Transform:GetWorldPosition()
	local dx, dz = x1 - x0, z1 - z0
	local dsq = dx * dx + dz * dz
	local angle
	if dsq > 0 then
		local dist = math.sqrt(dsq)
		angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
	else
		angle = TWOPI * math.random()
	end
	local sina, cosa = math.sin(angle), math.cos(angle)
	local speed = basespeed + math.random()
	inst.Physics:Teleport(x1, startheight, z1)
	inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end

local function TossItems(inst, dist, radius)
	local x, y, z = inst.Transform:GetWorldPosition()
	if dist ~= 0 then
		local rot = inst.Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, radius + TOSS_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)) do
		if v.components.mine then
			v.components.mine:Deactivate()
		end
		if not v.components.inventoryitem.nobounce and v.Physics and v.Physics:IsActive() then
			TossLaunch(v, inst, 1.2, 0.1)
		end
	end
end

local function DoArcAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets)
	local worked = _DoAOEWork(inst, dist, radius, arc, targets, false, nil, nil)
	local hit = _AOEAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets, nil)
	if hit or worked then
		inst.components.stuckdetection:Reset()
		return true
	end
	return false
end

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets, canblock, ignoreblock)
	local worked, blocked = _DoAOEWork(inst, dist, radius, nil, targets, canblock, ignoreblock and NOBLOCK_NON_COLLAPSIBLE_TAGS or nil, nil)
	local hit = _AOEAttack(inst, dist, radius, nil, heavymult, mult, forcelanded, targets, ignoreblock and NOBLOCK_AOE_TARGET_CANT_TAGS or nil)
	if hit or worked then
		inst.components.stuckdetection:Reset()
		return true, blocked
	end
	return false, blocked
end

--pounce stacks these calls, so let the state handle resetting stuckdetection
local function DoPounceAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
	local hit = _AOEAttack(inst, dist, radius, nil, heavymult, mult, forcelanded, targets, nil)
	return hit
end

--pounce stacks these calls, so let the state handle resetting stuckdetection
local function DoPounceAOEWork(inst, dist, radius, targets)
	local worked, blocked = _DoAOEWork(inst, dist, radius, nil, targets, false, nil, nil)
	return worked, blocked
end

local function DoFootstepAOE(inst)
	local worked = _DoAOEWork(inst, 0.3, 1.5, nil, nil, false, FOOTSTEP_NON_COLLAPSIBLE_TAGS, inst._trampledelays)
	if worked then
		inst.components.stuckdetection:Reset()
	end
end

--------------------------------------------------------------------------

local CHATTER_DELAYS =
{
	--NOTE: len must work for (net_tinybyte)
	["DAYWALKER_POWERDOWN"] =			{ delay = 3, len = 1.5 },
	["DAYWALKER2_CHASE_AWAY"] =			{ delay = 4, len = 1.5 },
	["DAYWALKER2_RUMMAGE_SUCCESS"] =	{ delay = 2, len = 1.5 },
	["DAYWALKER2_RUMMAGE_FAIL"] =		{ delay = 0, len = 1.5 },
}

local function TryChatter(inst, strtblname, index, ignoredelay, echotochatpriority)
	-- 'echotochatpriority' defaults to CHATPRIORITIES.LOW if nil is passed.
	SGDaywalkerCommon.TryChatter(inst, CHATTER_DELAYS, strtblname, index, ignoredelay, echotochatpriority)
end

--------------------------------------------------------------------------

local function SpawnDroppedJunk(inst, offset)
	local x, y, z = inst.Transform:GetWorldPosition()
	local theta = inst.Transform:GetRotation() * DEGREES
	SpawnPrefab("junk_break_fx").Transform:SetPosition(x + math.cos(theta), 0, z - math.sin(theta))
end

local function SpawnSwipeFX(inst, offset, reverse)
	--spawn 3 frames early (with 3 leading blank frames) since anim is super short, and tends to get lost with network timing
	inst.sg.statemem.fx = SpawnPrefab("daywalker2_swipe_fx")
	inst.sg.statemem.fx.entity:SetParent(inst.entity)
	inst.sg.statemem.fx.Transform:SetPosition(offset, 0, 0)
	if reverse then
		inst.sg.statemem.fx:Reverse()
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

local function CalcKnockback(scale)
	if scale >= 1 then
		return nil, Lerp(1, 1.5, scale - 1)
	end
	return scale, scale * 1.3, true
end

local function CalcDamage(dist)
	local min = TUNING.ALTERGUARDIAN_PHASE3_LASERDAMAGE * TUNING.DAYWALKER2_CANNON_FAR_DAMAGE_MULT
	local max = TUNING.ALTERGUARDIAN_PHASE3_LASERDAMAGE * TUNING.DAYWALKER2_CANNON_NEAR_DAMAGE_MULT
	return math.clamp(Remap(dist, 5.4, 10, max, min), min, max), TUNING.ALTERGUARDIAN_PLAYERDAMAGEPERCENT
end

local function SpawnLaserHitOnly(inst, dist, scale, targets)
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation() * DEGREES
	local fx = SpawnPrefab("alterguardian_laserempty")
	fx.caster = inst
	fx.Transform:SetPosition(x + dist * math.cos(rot), 0, z - dist * math.sin(rot))

	local dmg, playerdamagepercent = CalcDamage(dist)
	local hitscale = math.max(1, scale)
	local heavymult, mult, forcelanded = CalcKnockback(scale)

	fx:OverrideDamage(dmg, playerdamagepercent)
	fx:Trigger(0, targets, nil, true, nil, nil, hitscale, heavymult, mult, forcelanded)
end

local function SpawnLaser(inst, dist, angle_offset, scale, scorchscale, targets)
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = (inst.Transform:GetRotation() + angle_offset) * DEGREES
	local fx = SpawnPrefab("alterguardian_laser")
	fx.caster = inst
	fx.Transform:SetPosition(x + dist * math.cos(rot), 0, z - dist * math.sin(rot))

	local knockback = scale >= 1 and Lerp(1, 1.5, scale - 1) or nil
	local animscale = scale * (0.9 + math.random() * 0.2) * (inst.sg.mem.fliplaser and -1 or 1)
	inst.sg.mem.fliplaser = not inst.sg.mem.fliplaser

	local dmg, playerdamagepercent = CalcDamage(dist)
	local hitscale = math.max(1, scale)
	local heavymult, mult, forcelanded = CalcKnockback(scale)

	fx:OverrideDamage(dmg, playerdamagepercent)
	fx:Trigger(0, targets, nil, scorchscale < 0.2, animscale, scorchscale, hitscale, heavymult, mult, forcelanded)
	return dist + 0.4
end

local function DoFootstep(inst, volume)
	inst.sg.mem.lastfootstep = GetTime()
	inst.SoundEmitter:PlaySound(inst.footstep, nil, volume)
end

local function TurnToTargetFromNoFaced(inst)
	if inst.sg.lasttags and inst.sg.lasttags["canrotate"] and inst.sg.lasttags["busy"] then
		local target = inst.components.combat.target
		if target then
			inst:ForceFacePoint(target.Transform:GetWorldPosition())
		end
	end
end

--------------------------------------------------------------------------

local function rummage_ontimeout(inst)
	local loot = inst.sg.statemem.data and inst.sg.statemem.data.loot or nil
	if loot == "ball" then
		inst.sg:GoToState("throw_pre")
	else
		local nextstate1, nextstate2
		if loot == "object" then
			inst:SetEquip("swing", "object")
			nextstate1 = "lift_object"
		elseif loot == "spike" then
			inst:SetEquip("tackle", "spike")
			nextstate1 = "lift_spike"
		elseif loot == "cannon" then
			inst:SetEquip("cannon", "cannon")
			nextstate1 = "lift_cannon"
		end

		if nextstate1 then
			if inst.candoublerummage and inst.canmultiwield then
				local junk, loot2 = inst:GetNextItem()
				if loot2 == "object" then
					inst:SetEquip("swing", "object")
					nextstate2 = "lift_object"
				elseif loot2 == "spike" then
					inst:SetEquip("tackle", "spike")
					nextstate2 = "lift_spike"
				elseif loot2 == "cannon" then
					inst:SetEquip("cannon", "cannon")
					nextstate2 = "lift_cannon"
				end

				if nextstate2 and (nextstate2 == "lift_object" or nextstate1 == "lift_cannon") then
					local swap = nextstate1
					nextstate1 = nextstate2
					nextstate2 = swap
				end
			end

			inst.components.timer:StopTimer("multiwield")
			inst.components.timer:StartTimer("multiwield", TUNING.DAYWALKER2_MULTIWIELD_CD)
		end

		inst.sg:GoToState("rummage_pst", nextstate1 and { nextstate1 = nextstate1, nextstate2 = nextstate2 } or nil)
	end
end

--------------------------------------------------------------------------

local states =
{
	State{
		name = "transition",
	},

	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			if inst.sg.mem.sleeping then
				if inst.components.sleeper then
					inst.sg:GoToState("sleep")
					return
				end
				inst.sg.mem.sleeping = nil
			end
			inst.components.locomotor:Stop()
			TurnToTargetFromNoFaced(inst)
			if inst:IsStalking() then
				inst.sg:AddStateTag("stalking")
				inst:SetHeadTracking(true)
				inst.AnimState:PlayAnimation("idlewalk", true)
			elseif inst.sg.lasttags and inst.sg.lasttags["walk"] then
				inst.AnimState:PlayAnimation("idlewalk", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
		end,
	},

	State{
		name = "emerge",
		tags = { "busy", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("emerge")
			inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/emerge")
			ToggleOffCharacterCollisions(inst)
		end,

		timeline =
		{
			FrameEvent(4, function(inst)
				ToggleOnCharacterCollisions(inst)
				SGDaywalkerCommon.DoDefeatShake(inst)
			end),
		},

		events =
		{
			CommonHandlers.OnNoSleepAnimOver("idle"),
		},

		onexit = ToggleOnCharacterCollisions,
	},

	--------------------------------------------------------------------------
	--Out of combat
	--------------------------------------------------------------------------

	State{
		name = "talk",
		tags = { "talking", "idle", "canrotate" },

		onenter = function(inst, noanim)
			inst.components.locomotor:Stop()
			inst.Transform:SetSixFaced()
			if not noanim then
				inst.AnimState:PlayAnimation("idle_creepy_pre") --14
				inst.AnimState:PushAnimation("idle_creepy_loop") --55
				inst.sg:SetTimeout((14 + 55) * FRAMES)
			elseif inst.AnimState:IsCurrentAnimation("idle_creepy_pre") then
				inst.sg:SetTimeout((14 + 55) * FRAMES - inst.AnimState:GetCurrentAnimationTime())
			else
				inst.sg:SetTimeout(55 * FRAMES - inst.AnimState:GetCurrentAnimationTime())
			end
			if inst._thief and inst._thief:IsValid() then
				inst:FacePoint(inst._thief.Transform:GetWorldPosition())
				inst.sg.statemem.thief = inst._thief
			end
		end,

		ontimeout = function(inst)
			inst.sg.statemem.keepsixfaced = true
			inst.sg:GoToState("talk_pst")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.keepsixfaced then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "talk_pst",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("idle_creepy_pst")
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
			inst.Transform:SetFourFaced()
		end,
	},

	State{
		name = "angry",
		tags = { "angry", "idle", "canrotate" },

		onenter = function(inst, noanim)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			if not noanim then
				inst.AnimState:PlayAnimation("idle_angry_pre") --12
				inst.AnimState:PushAnimation("idle_angry_loop") --44
				inst.sg:SetTimeout((12 + 44) * FRAMES)
			elseif inst.AnimState:IsCurrentAnimation("idle_angry_pre") then
				inst.sg:SetTimeout((12 + 44) * FRAMES - inst.AnimState:GetCurrentAnimationTime())
			else
				inst.sg:SetTimeout(44 * FRAMES - inst.AnimState:GetCurrentAnimationTime())
			end
			if inst._thief and inst._thief:IsValid() then
				inst:FacePoint(inst._thief.Transform:GetWorldPosition())
				inst.sg.statemem.thief = inst._thief
			end
		end,

		ontimeout = function(inst)
			inst.sg.statemem.keepnofaced = true
			inst.sg:GoToState("angry_pst")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.keepnofaced then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "angry_pst",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("idle_angry_pst")
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
			inst.Transform:SetFourFaced()
		end,
	},

	State{
		name = "angry_taunt",
		tags = { "talking", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("angry_taunt")
			if inst._thief and inst._thief:IsValid() then
				inst:ForceFacePoint(inst._thief.Transform:GetWorldPosition())
			end
		end,

		timeline =
		{
			FrameEvent(5, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),
			FrameEvent(7, SGDaywalkerCommon.DoRoarShake),
			FrameEvent(23, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/speak_short") end),
			FrameEvent(28, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.3) end),
			FrameEvent(31, SGDaywalkerCommon.DoRoarShake),
			FrameEvent(51, function(inst)
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
	--Combat
	--------------------------------------------------------------------------

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst:SetStalking(nil)
			TurnToTargetFromNoFaced(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		timeline =
		{
			FrameEvent(9, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(13, function(inst)
				if not (inst.sg.statemem.doattack and ChooseAttack(inst)) then
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
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State{
		name = "dropitem",
		tags = { "busy" },

		onenter = function(inst, itemaction)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			inst:DropItem(itemaction)
		end,

		timeline =
		{
			FrameEvent(9, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(13, function(inst)
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

	State{
		name = "rummage",
		tags = { "rummaging", "busy", "nosleep" },

		onenter = function(inst, data)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()

			local timeout = (not (data and data.loot) or data.loot == "ball") and 1 or nil
			if data and data.hits then
				inst.AnimState:PlayAnimation("rummage_loop", true)
				timeout = timeout or math.max(1, 2 - data.hits * 0.5)
			else
				inst.AnimState:PlayAnimation("rummage_pre")
				inst.AnimState:PushAnimation("rummage_loop")
				inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
				timeout = timeout or 2
			end

			inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "rummage")

			if data then
				if data.junk and data.junk:IsValid() then
					inst:ForceFacePoint(data.junk.Transform:GetWorldPosition())
					data.junk:PushEvent("startlongaction", inst)
				end
				inst.sg.statemem.data = data
			end

			if timeout > 1 then
				inst.sg.statemem.caninterrupt = true
			end
			inst.sg:SetTimeout(timeout)
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if inst.sg.statemem.caninterrupt then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			TimeEvent(1, function(inst)
				if inst.sg.mem.sleeping then
					rummage_ontimeout(inst)
				end
			end),
		},

		ontimeout = rummage_ontimeout,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("rummage")
		end,
	},

	State{
		name = "rummage_hit",
		tags = { "rummaging", "busy", "hit", "nosleep" },

		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("rummage_hit")
			inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			if data == nil then
				inst.sg.statemem.data = { hits = 1 }
			elseif data.hits then
				inst.sg.statemem.data = data
				data.hits = data.hits + 1
			else
				inst.sg.statemem.data = shallowcopy(data)
				inst.sg.statemem.data.hits = 1
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		--Better timing than events
		ontimeout = function(inst)
			inst.sg:GoToState("rummage", inst.sg.statemem.data)
		end,

		--[[events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("rummage", inst.sg.statemem.data)
				end
			end),
		},]]
	},

	State{
		name = "rummage_pst",
		tags = { "busy", "nosleep" },

		onenter = function(inst, data)
			if data and data.nextstate1 then
				inst.sg.statemem.data = data
				inst.sg:AddStateTag("canrotate")
				inst.Transform:SetNoFaced()
				inst.AnimState:PlayAnimation("rummage_pst_nofaced")
			else
				inst.AnimState:PlayAnimation("rummage_pst")
			end
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
		end,

		timeline =
		{
			CommonHandlers.OnNoSleepFrameEvent(3, function(inst)
				local data = inst.sg.statemem.data
				if data then
					local nextstate = data.nextstate1
					data.nextstate1 = data.nextstate2
					data.nextstate2 = nil
					inst.sg.statemem.lifting = true
					inst.sg:GoToState(nextstate, data)
					return
				end
				inst.sg:RemoveStateTag("nosleep")
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

		onexit = function(inst)
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "lift_object",
		tags = { "busy", "canrotate" },

		onenter = function(inst, data)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("lift_object_pre") --8 frames
			inst.AnimState:PushAnimation("lift_object_loop") --17 frames
			if data and data.nextstate1 then
				--going to another lift state
				inst.AnimState:PushAnimation("lift_object_pst", false)
				inst.sg.statemem.data = data
			end
			TryChatter(inst, "DAYWALKER2_RUMMAGE_SUCCESS")
		end,

		timeline =
		{
			FrameEvent((8 + 17) + 7, function(inst)
				local data = inst.sg.statemem.data
				if data then
					local nextstate = data.nextstate1
					data.nextstate1 = data.nextstate2
					data.nextstate2 = nil
					data.fastforward = true
					inst.sg.statemem.lifting = true
					inst.sg:GoToState(nextstate, data)
				end
			end),
			FrameEvent((8 + 17) + 8, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent((8 + 17 * 2), function(inst)
				inst.AnimState:PlayAnimation("lift_object_pst")
			end),
			FrameEvent((8 + 17 * 2) + 9, function(inst)
				inst.sg:RemoveStateTag("busy")
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
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "lift_spike",
		tags = { "busy", "canrotate" },

		onenter = function(inst, data)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("lift_upperarm_pre") --8 frames
			if data then
				if data.fastforward then
					--came from another lift state
					inst.AnimState:SetFrame(5)
				end
				inst.sg.statemem.data = data
			end
			TryChatter(inst, "DAYWALKER2_RUMMAGE_SUCCESS")
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime())
		end,

		--Better timing than events
		ontimeout = function(inst)
			inst.sg.statemem.lifting = true
			inst.sg:GoToState("lift_spike2", inst.sg.statemem.data)
		end,

		--[[events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.lifting = true
					inst.sg:GoToState("lift_spike2", inst.sg.statemem.data)
				end
			end),
		},]]

		onexit = function(inst)
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "lift_spike2",
		tags = { "busy", "canrotate" },

		onenter = function(inst, data)
			if data and (data.fastforward or data.nextstate1) then
				inst.AnimState:PlayAnimation("lift_upperarm_loop") --17 frames
				inst.AnimState:PushAnimation("lift_upperarm_pst", false)
				if data.nextstate1 == nil then
					inst.sg.statemem.lifting = true
					inst.sg:GoToState("lift_spike3")
				else
					inst.sg.statemem.data = data
				end
			else
				inst.AnimState:PlayAnimation("lift_upperarm_loop", true)
				inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
			end
		end,

		timeline =
		{
			FrameEvent((17) + 7, function(inst)
				local data = inst.sg.statemem.data
				if data and data.nextstate1 then
					local nextstate = data.nextstate1
					data.nextstate1 = data.nextstate2
					data.nextstate2 = nil
					data.fastforward = true
					inst.sg.statemem.lifting = true
					inst.sg:GoToState(nextstate, data)
				end
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.lifting = true
			inst.sg:GoToState("lift_spike3", true)
		end,

		onexit = function(inst)
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "lift_spike3",
		tags = { "busy", "canrotate" },

		onenter = function(inst, playpst)
			inst.sg.statemem.playpst = playpst
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(17, function(inst)
				if inst.sg.statemem.playpst then
					inst.AnimState:PlayAnimation("lift_upperarm_pst")
				end
			end),
			FrameEvent((17) + 9, function(inst)
				inst.sg:RemoveStateTag("busy")
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
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "lift_cannon",
		tags = { "busy", "canrotate" },

		onenter = function(inst, data)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("lift_lowerarm_pre") --8 frames
			if data then
				if data.fastforward then
					--came from another lift state
					inst.AnimState:SetFrame(3)
				end
				inst.sg.statemem.data = data
			end
			TryChatter(inst, "DAYWALKER2_RUMMAGE_SUCCESS")
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime())
		end,

		--Better timing than events
		ontimeout = function(inst)
			inst.sg.statemem.lifting = true
			inst.sg:GoToState("lift_cannon2", inst.sg.statemem.data)
		end,

		--[[events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.lifting = true
					inst.sg:GoToState("lift_cannon2", inst.sg.statemem.data)
				end
			end),
		},]]

		onexit = function(inst)
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "lift_cannon2",
		tags = { "busy", "canrotate" },

		onenter = function(inst, data)
			inst.AnimState:PushAnimation("lift_lowerarm_loop") --34 frames (not a loop)
			inst.AnimState:PushAnimation("lift_lowerarm_pst", false) --14 frames
			inst.sg.statemem.data = data
		end,

		timeline =
		{
			FrameEvent(14, function(inst)
				inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			end),
			FrameEvent(31, function(inst)
				if not (inst.sg.statemem.data and inst.sg.statemem.data.nextstate1) then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent((34) + 7, function(inst)
				local data = inst.sg.statemem.data
				if data and data.nextstate1 then
					local nextstate = data.nextstate1
					data.nextstate1 = data.nextstate2
					data.nextstate2 = nil
					data.fastforward = true
					inst.sg.statemem.lifting = true
					inst.sg:GoToState(nextstate, data)
				end
			end),
			FrameEvent((34) + 9, function(inst)
				inst.sg:RemoveStateTag("busy")
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
			if not inst.sg.statemem.lifting then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "attack_swing",
		tags = { "attack", "busy", "notalksound" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_object")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
			TryChatter(inst, "DAYWALKER2_CHASE_AWAY")

			if target and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.target = target
			end
			inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER2_ATTACK_SWING_DAMAGE)
		end,

		timeline =
		{
			FrameEvent(9, function(inst) inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/objectswing_f15") end),
			FrameEvent(12, function(inst)
				inst:StartAttackCooldown()
				SpawnSwipeFX(inst, 1, true)
			end),
			FrameEvent(16, function(inst)
				local target = inst.sg.statemem.target
				local targets = target and {} or nil
				inst.sg.statemem.hit = DoArcAttack(inst, 1, 4.5, 240, nil, 0.75, nil, targets)
				if targets and not targets[target] then
					inst.sg.statemem.target = nil
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local hit = inst.sg.statemem.hit
					inst.sg.statemem.hit = nil
					inst.sg:GoToState("attack_swing_pst", {
						target = inst.sg.statemem.target,
						hit = hit,
					})
				end
			end),
		},

		onexit = function(inst)
			inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
			KillSwipeFX(inst)
			if inst.sg.statemem.hit and not inst:OnItemUsed("swing") then
				inst:DropItem("swing")
			end
		end,
	},

	State{
		name = "attack_swing_pst",
		tags = { "attack", "busy" },

		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("atk_object_pst")
			inst.sg.statemem.target = data and data.target or nil --for combo
			inst.sg.statemem.hit = data and data.hit or nil
		end,

		timeline =
		{
			FrameEvent(4, function(inst)
				if inst.sg.statemem.hit then
					inst.sg.statemem.hit = nil
					if not inst:OnItemUsed("swing") then
						inst.sg:GoToState("dropitem", "swing")
						return
					end
				end
				local target = inst.sg.statemem.target
				if target and (inst.cancannon or inst.cantackle) and inst.components.combat:CanTarget(target) then
					if inst.cancannon then
						inst.sg:GoToState("cannon_pre", target)
						return true
					elseif inst:TestTackle(target, nil) then --pass nil for range when combo
						inst.sg:GoToState("tackle_pre", target)
						return true
					end
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(8, function(inst)
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

		onexit = function(inst)
			if inst.sg.statemem.hit and not inst:OnItemUsed("swing") then
				inst:DropItem("swing")
			end
		end,
	},

	State{
		name = "cannon_pre",
		tags = { "attack", "busy", "notalksound" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("laser_pre")
			inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/laser_pre")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			TryChatter(inst, "DAYWALKER2_CHASE_AWAY")

			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.target then
				if inst.sg.statemem.target:IsValid() then
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(inst.sg.statemem.target.Transform:GetWorldPosition())
					if DiffAngle(rot, rot1) < 60 then
						inst.Transform:SetRotation(rot1)
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(14, function(inst) inst:StartAttackCooldown() end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("cannon", inst.sg.statemem.target)
				end
			end),
		},
	},

	State{
		name = "cannon",
		tags = { "attack", "busy", "nosleep" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("laser_pst")
			inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/laser_pst")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")

			inst.sg.statemem.target = target
		end,

		onupdate = function(inst)
			if inst.sg.statemem.target then
				if inst.sg.statemem.target:IsValid() then
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(inst.sg.statemem.target.Transform:GetWorldPosition())
					if DiffAngle(rot, rot1) < 60 then
						inst.Transform:SetRotation(rot1)
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(5, function(inst)
				inst.sg.statemem.target = nil
				inst.sg.statemem.targets = { [inst] = true }

				SpawnPrefab("alterguardian_laserhit"):SetTarget(inst)
				inst.sg.statemem.hit = true

				SpawnLaserHitOnly(inst, 1.5, 2.5, inst.sg.statemem.targets)

				local dist = 3
				SpawnLaser(inst, dist, -30, 2, 0, inst.sg.statemem.targets)
				SpawnLaser(inst, dist, 30, 2, 0, inst.sg.statemem.targets)
				dist = SpawnLaser(inst, dist, 0, 2, 5, inst.sg.statemem.targets)

				SpawnLaser(inst, dist, -25, 1.5, 0, inst.sg.statemem.targets)
				SpawnLaser(inst, dist, 25, 1.5, 0, inst.sg.statemem.targets)
				dist = SpawnLaser(inst, dist, 0, 1.5, 3, inst.sg.statemem.targets)
				inst.sg.statemem.dist = dist
			end),
			FrameEvent(6, function(inst)
				local dist = inst.sg.statemem.dist
				local scorchscale = 3
				for i = 1, 5 do
					scorchscale = scorchscale * 0.8
					dist = SpawnLaser(inst, dist, 0, 1, scorchscale, inst.sg.statemem.targets)
				end
				inst.sg.statemem.dist = dist
				inst.sg.statemem.scorchscale = scorchscale
			end),
			FrameEvent(7, function(inst)
				local dist = inst.sg.statemem.dist
				local scorchscale = inst.sg.statemem.scorchscale
				for i = 1, 9 do
					scorchscale = scorchscale * 0.8
					dist = SpawnLaser(inst, dist, 0, Lerp(1, 0.5, i / 10), scorchscale, inst.sg.statemem.targets)
				end
				inst.sg.statemem.dist = dist
				inst.sg.statemem.scorchscale = scorchscale
			end),
			FrameEvent(8, function(inst)
				local dist = inst.sg.statemem.dist
				local scorchscale = inst.sg.statemem.scorchscale
				--0.99 so we don't knockback
				SpawnLaser(inst, dist, 0, 0.99, scorchscale, inst.sg.statemem.targets)
			end),
			CommonHandlers.OnNoSleepFrameEvent(32, function(inst)
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(34, function(inst)
				if inst.sg.statemem.hit then
					inst.sg.statemem.hit = nil
					if not inst:OnItemUsed("cannon") then
						inst.sg:GoToState("dropitem", "cannon")
					end
				end
			end),
			FrameEvent(38, function(inst)
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

		onexit = function(inst)
			if inst.sg.statemem.hit and not inst:OnItemUsed("cannon") then
				inst:DropItem("cannon")
			end
		end,
	},

	State{
		name = "throw_pre",
		tags = { "attack", "busy", "notalksound", "nosleep" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("throw_pre")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			inst.sg.statemem.target = target
			TryChatter(inst, "DAYWALKER2_RUMMAGE_FAIL")
		end,

		timeline =
		{
			FrameEvent(5, function(inst)
				inst.sg.statemem.hasjunk = true
			end),
			CommonHandlers.OnNoSleepFrameEvent(11, function(inst)
				inst.sg:RemoveStateTag("nosleep")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local target = inst.sg.statemem.target
					if not (target and target:IsValid()) then
						target = inst.components.combat.target
					end
					inst.sg.statemem.throwing = true
					if target then
						inst.sg:GoToState("throw", target)
					else
						inst.Transform:SetRotation(inst.Transform:GetRotation() + 180)
						inst.sg:GoToState("throw_loop")
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.throwing and inst.sg.statemem.hasjunk then
				SpawnDroppedJunk(inst, 2)
			end
		end,
	},

	State{
		name = "throw_loop",
		tags = { "attack", "busy" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("throw_loop", true)
			inst.sg:SetTimeout(2 * inst.AnimState:GetCurrentAnimationLength())
		end,

		onupdate = function(inst)
			local target = inst.components.combat.target
			if target then
				inst.sg.statemem.throwing = true
				inst.sg:GoToState("throw", target)
			end
		end,

		ontimeout = function(inst)
			inst.Transform:SetRotation(inst.Transform:GetRotation() - 30 + math.random() * 60)
			inst.sg.statemem.throwing = true
			inst.sg:GoToState("throw")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.throwing then
				SpawnDroppedJunk(inst, 2)
			end
		end,
	},

	State{
		name = "throw",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("throw")
			inst.SoundEmitter:PlaySound("daywalker/voice/attack_big")

			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
			inst.sg.statemem.hasjunk = true
		end,

		onupdate = function(inst)
			local target = inst.sg.statemem.target
			if target then
				if target:IsValid() then
					local p = inst.sg.statemem.targetpos
					p.x, p.y, p.z = target.Transform:GetWorldPosition()

					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(p)
					if DiffAngle(rot, rot1) < 45 then
						inst.Transform:SetRotation(rot1)
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(21, function(inst)
				inst.sg.statemem.hasjunk = false
				SpawnPrefab("junkball_fx"):SetupJunkTossAttack(inst, 2, inst.sg.statemem.target, inst.sg.statemem.targetpos)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("throw_pst")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.statemem.hasjunk then
				SpawnDroppedJunk(inst, 2)
			end
		end,
	},

	State{
		name = "throw_pst",
		tags = { "attack", "busy", "caninterrupt" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("throw_pst")
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
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

	State{
		name = "tackle_pre",
		tags = { "tackle", "attack", "busy", "notalksound" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("tackle_pre")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			TryChatter(inst, "DAYWALKER2_CHASE_AWAY")

			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end

			if inst.sg.lasttags and inst.sg.lasttags["moving"] then
				inst.sg:AddStateTag("jumping")
				if inst.sg.lasttags["running"] then
					inst.AnimState:SetFrame(4)
					inst.Physics:SetMotorVelOverride(inst.components.locomotor:GetRunSpeed(), 0, 0)
				else
					inst.Physics:SetMotorVelOverride(inst.components.locomotor:GetWalkSpeed(), 0, 0)
				end
			end
		end,

		onupdate = function(inst)
			local target = inst.sg.statemem.target
			if target then
				if target:IsValid() then
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(target.Transform:GetWorldPosition())
					local drot = ReduceAngle(rot1 - rot)
					if math.abs(drot) < 90 then
						rot1 = rot + math.clamp(drot / 2, -1, 1)
						inst.Transform:SetRotation(rot1)
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(6, DoFootstep),
			--FrameEvent(7, DoFootstepAOE), --bumped to start of tackle_loop
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.tackling = true
					inst.sg:GoToState("tackle_loop", inst.sg.statemem.target)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.tackling and inst.sg:HasStateTag("jumping") then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end
		end,
	},

	State{
		name = "tackle_loop",
		tags = { "tackle", "attack", "busy", "jumping" },

		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("tackle", true)
			inst:StartAttackCooldown()
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() * 3) --16 * 3
			inst.sg.statemem.target = target
			inst.sg.statemem.targets = {}
			inst.sg.statemem.ignoreblock = true --for first few frames
			inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER2_TACKLE_DAMAGE)
		end,

		onupdate = function(inst)
			local speedmult = inst.components.locomotor:GetSpeedMultiplier()
			inst.Physics:SetMotorVelOverride(TUNING.DAYWALKER2_TACKLE_SPEED * speedmult, 0, 0)

			local target = inst.sg.statemem.target
			if target then
				if target:IsValid() then
					local x1, y1, z1 = target.Transform:GetWorldPosition()
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(x1, y1, z1)
					local drot = ReduceAngle(rot1 - rot)
					if math.abs(drot) < 90 then
						rot1 = rot + math.clamp(drot / 2, -1, 1)
						inst.Transform:SetRotation(rot1)
					end

					--rougly how far we travel at the start of the lift, plus some buffer for the hitbox
					local range = TUNING.DAYWALKER2_TACKLE_SPEED * 0.1 * speedmult + 2.5
					if inst:GetDistanceSqToPoint(x1, y1, z1) < range * range then
						inst.sg.statemem.tackling = true
						inst.sg:GoToState("tackle_lift", {
							target = target,
							targets = inst.sg.statemem.targets,
							hit = inst.sg.statemem.hit,
						})
						return
					end
				else
					inst.sg.statemem.target = nil
				end
			end

			local ignoreblock = inst.sg.statemem.ignoreblock
			local hit, blocked = DoAOEAttack(inst, 1, 2, nil, 1, nil, inst.sg.statemem.targets, not ignoreblock, ignoreblock)
			if blocked then
				inst.sg.statemem.hit = nil
				inst.sg:GoToState("tackle_collide") --this state assumes hit
				return
			elseif hit then
				inst.sg.statemem.hit = true
			end
			if target and inst.sg.statemem.targets[target] then
				inst.sg.statemem.tackling = true
				inst.sg:GoToState("tackle_lift", {
					target = target,
					targets = inst.sg.statemem.targets,
					hit = inst.sg.statemem.hit,
				})
				return
			end

			if inst.sg.statemem.trample then
				inst.sg.statemem.trample = nil
				DoFootstepAOE(inst)
			end
		end,

		timeline =
		{
			FrameEvent(0, DoFootstepAOE), --from tackle_pre

			--loop 1
			FrameEvent(7, DoFootstep),
			FrameEvent(8, function(inst)
				inst.sg.statemem.ignoreblock = nil
				inst.sg.statemem.trample = true
			end),
			FrameEvent(15, DoFootstep),
			FrameEvent(16, function(inst)
				inst.sg.statemem.trample = true
				DoFootstepAOE(inst)
			end),

			--loop 2
			FrameEvent(23, DoFootstep),
			FrameEvent(24, function(inst)
				inst.sg.statemem.ignoreblock = nil
				inst.sg.statemem.trample = true
			end),
			FrameEvent(31, DoFootstep),
			FrameEvent(32, function(inst)
				inst.sg.statemem.trample = true
				DoFootstepAOE(inst)
			end),

			--loop 3
			FrameEvent(39, DoFootstep),
			FrameEvent(40, function(inst)
				inst.sg.statemem.ignoreblock = nil
				inst.sg.statemem.trample = true
			end),
			FrameEvent(47, DoFootstep),
			FrameEvent(48, function(inst)
				inst.sg.statemem.trample = true
				DoFootstepAOE(inst)
			end),
		},

		ontimeout = function(inst)
			local hit = inst.sg.statemem.hit
			inst.sg.statemem.hit = nil
			inst.sg:GoToState("tackle_pst", hit)
		end,

		onexit = function(inst)
			if not inst.sg.statemem.tackling then
				inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				if inst.sg.statemem.hit and not inst:OnItemUsed("tackle") then
					inst:DropItem("tackle")
				end
			end
		end,
	},

	State{
		name = "tackle_lift",
		tags = { "tackle", "attack", "busy", "jumping" },

		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("tackle_lift")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/bodyswing_f5")
			inst:StartAttackCooldown()
			inst.sg.statemem.target = data and data.target or nil
			inst.sg.statemem.targets = data and data.targets or {}
			inst.sg.statemem.hit = data and data.hit or nil
			inst.sg.statemem.speedmult = 1
			inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER2_TACKLE_DAMAGE)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speedmult then
				inst.sg.statemem.speedmult = inst.sg.statemem.speedmult * 0.75
				inst.Physics:SetMotorVelOverride(TUNING.DAYWALKER2_TACKLE_SPEED * inst.components.locomotor:GetSpeedMultiplier() * inst.sg.statemem.speedmult, 0, 0)
				--no knockback during deceleration
				if DoAOEAttack(inst, 1, 2, nil, nil, nil, inst.sg.statemem.targets, false, false) then
					inst.sg.statemem.hit = true
				end
			end
		end,

		timeline =
		{
			FrameEvent(5, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
				inst.sg.statemem.speedmult = nil
				inst.sg.statemem.targets = {} --reset targets
				if DoAOEAttack(inst, 1, 2, nil, 0.75, nil, inst.sg.statemem.targets, false, false) then
					inst.sg.statemem.hit = true
				end
				TossItems(inst, 1, 2)
			end),
			FrameEvent(6, function(inst)
				if DoAOEAttack(inst, 1, 2, nil, 0.75, nil, inst.sg.statemem.targets, false, false) then
					inst.sg.statemem.hit = true
				end
			end),
			FrameEvent(16, function(inst)
				if inst.sg.statemem.hit then
					inst.sg.statemem.hit = nil
					if not inst:OnItemUsed("tackle") then
						inst.sg:GoToState("dropitem", "tackle")
						return
					end
				end
				local target = inst.sg.statemem.target
				if target and (inst.canswing and inst.cancannon) and inst.sg.statemem.targets[target] and inst.components.combat:CanTarget(target) then
					inst.sg:GoToState("attack_swing", target)
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(18, function(inst)
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

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
			if inst.sg.statemem.hit and not inst:OnItemUsed("tackle") then
				inst:DropItem("tackle")
			end
		end,
	},

	State{
		name = "tackle_collide",
		tags = { "busy" },

		onenter = function(inst)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("tackle_hit") --3 frames
			inst.AnimState:PushAnimation("hit", false)
			inst.sg.statemem.hit = true
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				inst.sg.statemem.hit = nil
				if not inst:OnItemUsed("tackle") then
					inst:DropItem("tackle")
				end
				inst.SoundEmitter:PlaySound("daywalker/voice/hurt")
			end),
			FrameEvent(3 + 9, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
			FrameEvent(3 + 13, function(inst)
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

		onexit = function(inst)
			if inst.sg.statemem.hit and not inst:OnItemUsed("tackle") then
				inst:DropItem("tackle")
			end
		end,
	},

	State{
		name = "tackle_pst",
		tags = { "busy" },

		onenter = function(inst, hit)
			inst.AnimState:PlayAnimation("tackle_pst")
			inst.sg.statemem.hit = hit
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if inst.sg.statemem.hit then
					inst.sg.statemem.hit = nil
					if not inst:OnItemUsed("tackle") then
						inst.sg:GoToState("dropitem", "tackle")
						return
					end
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(10, function(inst)
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

		onexit = function(inst)
			if inst.sg.statemem.hit and not inst:OnItemUsed("tackle") then
				inst:DropItem("tackle")
			end
		end,
	},

	State{
		name = "attack_pounce_pre",
		tags = { "attack", "busy", "jumping" },

		onenter = function(inst, target)
			inst:SetStalking(nil)
			inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst.AnimState:PlayAnimation("run_pre")
			inst.SoundEmitter:PlaySound(inst.footstep)
			if target and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
			inst.sg.statemem.speedmult = not (inst.sg.lasttags and inst.sg.lasttags["running"]) and 0.8 or nil
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
		tags = { "attack", "busy", "jumping", "nointerrupt", "nosleep", "notalksound" },

		onenter = function(inst, speedmult)
			inst:SetStalking(nil)
			--inst.components.locomotor:Stop()
			inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			inst:StartAttackCooldown()
			inst.AnimState:PlayAnimation("atk3")
			inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
			inst.SoundEmitter:PlaySound("daywalker/action/attack3")
			TryChatter(inst, "DAYWALKER2_CHASE_AWAY")
			inst.sg.statemem.speedmult = speedmult or 1
			inst.Physics:SetMotorVelOverride(11 * inst.sg.statemem.speedmult, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speed then
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed * inst.sg.statemem.speedmult, 0, 0)
			end
			if inst.sg.statemem.collides then
				local hit = DoPounceAOEAttack(inst, 0.2, 1.4, nil, nil, nil, inst.sg.statemem.collides)
				if hit then
					inst.components.stuckdetection:Reset()
				end
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
				inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_XCLAW_DAMAGE)
				local targets = {}
				local hit
				hit = DoPounceAOEWork(inst, 3, 3, targets)
				hit = DoPounceAOEWork(inst, 0.4, 1.6, targets) or hit
				hit = DoPounceAOEAttack(inst, 3, 3, 1 + 0.1 * inst.sg.statemem.speedmult, 1 + 0.2 * inst.sg.statemem.speedmult, false, targets) or hit
				hit = DoPounceAOEAttack(inst, 0.4, 1.6, 1, 1, false, targets) or hit
				if hit then
					inst.components.stuckdetection:Reset()
				end
			end),
			CommonHandlers.OnNoSleepFrameEvent(14, function(inst)
				inst.sg:RemoveStateTag("nosleep")
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
					inst.sg:GoToState("attack_pounce_pst")
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
		name = "attack_pounce_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("atk3_pst")
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
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State{
		name = "taunt",
		tags = { "taunt", "busy", "notalksound" }, --has facings! don't need "canrotate"

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
				TryChatter(inst, "DAYWALKER2_CHASE_AWAY", nil, true)
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
		tags = { "defeated", "busy", "nointerrupt", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			inst.AnimState:PlayAnimation("defeat")
			if inst.canswing then
				inst:DropItem("swing")
			end
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

				if inst.cantackle or inst.cancannon then
					if inst.cantackle then
						if inst.equiptackle == "spike" then
							inst:DropItemAsLoot("tackle", true)
						else
							inst:DropItem("tackle", true)
						end
					end
					if inst.cancannon then
						inst:DropItem("cannon", true)
					end
					--just play it once for all loot
					inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
				end

				local parts = { "daywalker2_armor1_break_fx", "daywalker2_armor2_break_fx", "daywalker2_cloth_break_fx" }
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot0 = math.random() * 360
				local drot = 360 / #parts
				for i, v in ipairs(parts) do
					local rot = rot0 + i * drot + math.random() * 0.8 * drot
					local fx = SpawnPrefab(v)
					fx.Transform:SetRotation(rot)
					rot = rot * DEGREES
					local r = 0.5 + math.random()
					fx.Transform:SetPosition(x + math.cos(rot) * r, y, z - math.sin(rot) * r)
				end

				inst.AnimState:HideSymbol("swap_hunch_1")
				inst.AnimState:HideSymbol("swap_hunch_2")
				inst.AnimState:HideSymbol("swap_cloth")
				inst.AnimState:HideSymbol("swap_eye_R")
				inst.AnimState:Hide("flake")

				if inst.defeated and not inst.looted then
					inst.looted = true
					inst.components.timer:ResumeTimer("despawn")
					inst.components.lootdropper:DropLoot(inst:GetPosition())
				end
			end),
			--[[FrameEvent(48, function(inst)
				inst:RemoveTag("lunar_aligned")
			end),]]
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
				inst.Transform:SetFourFaced()
				--inst:AddTag("lunar_aligned")
				inst.AnimState:ShowSymbol("swap_hunch_1")
				inst.AnimState:ShowSymbol("swap_hunch_2")
				inst.AnimState:ShowSymbol("swap_cloth")
				inst.AnimState:ShowSymbol("swap_eye_R")
			end
		end,
	},

	State{
		name = "defeat_idle_pre",
		tags = { "defeated", "busy", "nointerrupt", "nosleep", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			--inst:RemoveTag("lunar_aligned")
			inst.AnimState:PlayAnimation("defeat_idle_pre")
			inst.AnimState:HideSymbol("swap_hunch_1")
			inst.AnimState:HideSymbol("swap_hunch_2")
			inst.AnimState:HideSymbol("swap_cloth")
			inst.AnimState:HideSymbol("swap_eye_R")
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
				inst.Transform:SetFourFaced()
				--inst:AddTag("lunar_aligned")
				inst.AnimState:ShowSymbol("swap_hunch_1")
				inst.AnimState:ShowSymbol("swap_hunch_2")
				inst.AnimState:ShowSymbol("swap_cloth")
				inst.AnimState:ShowSymbol("swap_eye_R")
			end
		end,
	},

	State{
		name = "defeat_idle",
		tags = { "defeated", "busy", "nointerrupt", "nosleep", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.Transform:SetNoFaced()
			--inst:RemoveTag("lunar_aligned")
			if not inst.AnimState:IsCurrentAnimation("defeat_idle_loop") then
				inst.AnimState:PlayAnimation("defeat_idle_loop", true)
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(13, function(inst)
				TryChatter(inst, "DAYWALKER_POWERDOWN")
			end),
		},

		ontimeout = function(inst)
			inst.sg.statemem.defeat = true
			inst.sg:GoToState("defeat_idle")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.defeat then
				--Should not reach here
				inst.Transform:SetFourFaced()
				--inst:AddTag("lunar_aligned")
				inst.AnimState:ShowSymbol("swap_hunch_1")
				inst.AnimState:ShowSymbol("swap_hunch_2")
				inst.AnimState:ShowSymbol("swap_cloth")
				inst.AnimState:ShowSymbol("swap_eye_R")
			end
		end,
	},
}

SGDaywalkerCommon.AddWalkStates(states)
SGDaywalkerCommon.AddRunStates(states,
{
	runtimeline =
	{
		FrameEvent(9, DoFootstep),
		FrameEvent(10, DoFootstepAOE),
		FrameEvent(22, DoFootstep),
		FrameEvent(23, DoFootstepAOE),
	},
})

local function CleanupIfSleepInterrupted(inst)
	if not inst.sg.statemem.continuesleeping then
		inst.Transform:SetFourFaced()
	end
end

CommonStates.AddSleepExStates(states,
{
	starttimeline =
	{
		FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/sleep") end),
		FrameEvent(43, function(inst) inst.SoundEmitter:PlaySound(inst.footstep) end),
		FrameEvent(45, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/hurt", nil, 0.5) end),
		FrameEvent(46, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt") end),
		FrameEvent(47, SGDaywalkerCommon.DoSleepShake),
		FrameEvent(48, function(inst)
			inst.sg:RemoveStateTag("caninterrupt")
		end),
	},
	sleeptimeline =
	{
		FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/sleep") end),
		FrameEvent(34, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/hurt", nil, 0.4) end),
	},
	waketimeline =
	{
		FrameEvent(16, function(inst) inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/sleep", nil, 0.6) end),
		FrameEvent(19, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
		FrameEvent(33, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.4) end),
		CommonHandlers.OnNoSleepFrameEvent(35, function(inst)
			inst.sg:RemoveStateTag("nosleep")
			inst.sg:AddStateTag("caninterrupt")
		end),
		FrameEvent(38, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
	},
},
{
	onsleep = function(inst)
		inst.sg:AddStateTag("caninterrupt")
		inst.sg:AddStateTag("canrotate")
		inst.Transform:SetNoFaced()
	end,
	onexitsleep = CleanupIfSleepInterrupted,
	onsleeping = function(inst)
		inst.sg:AddStateTag("canrotate")
		inst.Transform:SetNoFaced()
	end,
	onexitsleeping = CleanupIfSleepInterrupted,
	onwake = function(inst)
		inst.sg:AddStateTag("canrotate")
		inst.Transform:SetNoFaced()
	end,
	onexitwake = CleanupIfSleepInterrupted,
})

CommonStates.AddFrozenStates(states)

return StateGraph("daywalker2", states, events, "idle")
