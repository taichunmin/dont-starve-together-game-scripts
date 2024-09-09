--NOTE: "diging" and "fin" state tags control physics when entering state.
--      (see sharkboi.lua)
--      do NOT add/remove these state tags mid state!

require("stategraphs/commonstates")

local function DoImpactShake(inst)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, 1, 0.02, 0.3, inst, 30)
end

local function DoJumpOutShake(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, 0.6, 0.02, 0.2, inst, 30)
end

local function DoDiggingShake(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, 0.6, 0.015, 0.15, inst, 30)
end

--------------------------------------------------------------------------

local function ChooseAttack(inst, target)
	target = target or inst.components.combat.target
	if target and not target:IsValid() then
		target = nil
	end

	if inst.sg:HasStateTag("fin") then
		if inst.sg:HasStateTag("moving") then
			inst.sg.statemem.fin = true
			inst.sg:GoToState("fin_stop", { "dive_jump_delay", target })
		elseif inst.sg.currentstate.name == "fin_stop" then
			if inst.sg.nextstateparams then
				inst.sg.nextstateparams[2] = target
			else
				inst.sg.nextstateparams = { "dive_jump_delay", target }
			end
		else
			inst.sg:GoToState("dive_jump_delay", target)
		end
		return true
	elseif not inst.components.timer:TimerExists("torpedo_cd") then
		inst.sg:GoToState("ice_summon", target)
		return true
	elseif not inst.components.timer:TimerExists("standing_dive_cd") then
		inst.sg:GoToState("standing_dive_jump_pre", target)
		return true
	elseif target and inst:IsNear(target, TUNING.SHARKBOI_MELEE_RANGE + target:GetPhysicsRadius(0)) then
		inst.sg:GoToState("attack1", target)
		return true
	end
	return false
end

local function ShouldBeDefeated(inst)
	return inst.components.health.currenthealth <= inst.components.health.minhealth
end

--------------------------------------------------------------------------

local events =
{
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),

	EventHandler("locomote", function(inst, data)
		if inst.components.locomotor:WantsToMoveForward() then
			if inst.sg:HasStateTag("idle") then
				--V2C: in case we were in "idle" without "canrotate"
				if data and data.dir then
					inst.components.locomotor:SetMoveDir(data.dir)
				end
				--start moving
				inst.sg:GoToState(
					(inst.sg:HasStateTag("fin") and "fin_start") or
					(inst.components.locomotor:WantsToRun() and "run_start" or "walk_start")
				)
			elseif inst.sg:HasStateTag("moving") and not inst.sg:HasStateTag("fin") then
				--switch between running/walking
				local should_run = inst.components.locomotor:WantsToRun()
				if should_run ~= inst.sg:HasStateTag("running") then
					inst.sg:GoToState(should_run and "run_start" or "walk_start")
				end
			end
		elseif inst.sg:HasStateTag("moving") then
			--stop moving
			if inst.sg:HasStateTag("fin") then
				inst.sg.statemem.fin = true
				inst.sg:GoToState("fin_stop")
			else
				inst.sg:GoToState(inst.sg:HasStateTag("running") and "run_stop" or "walk_stop")
			end
		end
	end),
	EventHandler("attacked", function(inst)
		if not inst.sg:HasStateTag("busy") or
			inst.sg:HasStateTag("caninterrupt") or
			inst.sg:HasStateTag("frozen")
		then
			if inst.sg:HasStateTag("defeated") then
				inst.sg.statemem.defeat = true
				inst.sg:GoToState("defeat_hit", inst.sg.statemem.hits)
			elseif inst.sg:HasStateTag("digging") then
				inst.sg:GoToState("dive_dig_hit", inst.sg.statemem.hits)
			elseif inst.sg:HasStateTag("dizzy") then
				local hits = (inst.sg.statemem.hits or 0) + 1
				inst.sg:GoToState("hit", { hits > 2 and "torpedo_pst" or "torpedo_dizzy", hits })
			elseif inst.sg:HasStateTag("torpedoready") then
				inst.sg:GoToState("hit", { "torpedo_pre", inst.sg.statemem.target })
			elseif not CommonHandlers.HitRecoveryDelay(inst) then
				inst.sg:GoToState("hit")
			end
		end
	end),
	EventHandler("minhealth", function(inst)
		if not (inst.components.trader or inst.sg:HasStateTag("defeated")) and (
			not inst.sg:HasStateTag("busy") or
			inst.sg:HasStateTag("caninterrupt") or
			inst.sg:HasStateTag("candefeat") or
			inst.sg:HasStateTag("frozen")
		) then
			inst.sg:GoToState(inst.sg:HasStateTag("digging") and "dive_dig_hit" or "hit")
		end
	end),
	EventHandler("doattack", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or ShouldBeDefeated(inst)) then
			ChooseAttack(inst, data and data.target or nil)
		end
	end),
	EventHandler("ontalk", function(inst)
		inst.sg.mem.lasttalktime = GetTime()
		if not (inst:HasTag("hostile") or inst.trading or inst.pendingreward or inst.sg:HasStateTag("busy")) then
			inst.sg.statemem.keepsixfaced = true
			inst.sg:GoToState("talk", inst.sg:HasStateTag("talking"))
		end
	end),
	EventHandler("trade", function(inst, data)
		if inst.pendingreward then
			if not inst.sg:HasStateTag("busy") then
				inst.sg.mem.pendinggiver = nil
				inst.sg.statemem.keepsixfaced = true
				inst.sg:GoToState("give", data and data.giver or nil)
			else
				inst.sg.mem.pendinggiver = data and data.giver or nil
			end
		end
	end),
	EventHandler("onrefuseitem", function(inst, data)
		if not inst.sg:HasStateTag("busy") then
			inst.sg.statemem.keepsixfaced = true
			inst.sg:GoToState("refuse", data)
		end
	end),
}

--------------------------------------------------------------------------

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }

local function _AOEAttack(inst, dig, dist, radius, arc, heavymult, mult, forcelanded, targets)
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
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
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
				if dig and v.components.locomotor == nil then
					v.components.health:Kill()
				else
					inst.components.combat:DoAttack(v)
					if mult then
						local strengthmult = (v.components.inventory and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
						v:PushEvent("knockback", { knocker = inst, radius = radius + dist, strengthmult = strengthmult, forcelanded = forcelanded })
					end
				end
				if targets then
					targets[v] = true
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end

local WORK_RADIUS_PADDING = 0.5
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

local COLLAPSIBLE_WORK_AND_DIG_ACTIONS = shallowcopy(COLLAPSIBLE_WORK_ACTIONS)
local COLLAPSIBLE_DIG_TAGS = shallowcopy(COLLAPSIBLE_TAGS)
COLLAPSIBLE_WORK_AND_DIG_ACTIONS["DIG"] = true
table.insert(COLLAPSIBLE_DIG_TAGS, "pickable")
table.insert(COLLAPSIBLE_DIG_TAGS, "DIG_workable")

local NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO" }

local function DoAOEWork(inst, dig, dist, radius, arc, targets)
	local actions = dig and COLLAPSIBLE_WORK_AND_DIG_ACTIONS or COLLAPSIBLE_WORK_ACTIONS
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
	for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + WORK_RADIUS_PADDING, nil, NON_COLLAPSIBLE_TAGS, dig and COLLAPSIBLE_DIG_TAGS or COLLAPSIBLE_TAGS)) do
		if not (targets and targets[v]) and v:IsValid() and not v:IsInLimbo() then
			local inrange = true
			if arcx then
				--convert to local space x, and test against arcx
				local x1, y1, z1 = v.Transform:GetWorldPosition()
				inrange = x + cos_theta * (x1 - x) - sin_theta * (z1 - z) > arcx
			end
			if inrange then
				local isworkable = false
				if v.components.workable then
					local work_action = v.components.workable:GetWorkAction()
					--V2C: nil action for NPC_workable (e.g. campfires)
					--     allow digging spawners (e.g. rabbithole)
					isworkable = (
						(work_action == nil and v:HasTag("NPC_workable")) or
						(v.components.workable:CanBeWorked() and work_action and actions[work_action.id])
					)
				end
				if isworkable then
					v.components.workable:Destroy(inst)
					if dig and v:IsValid() and v:HasTag("stump") then
						v:Remove()
					end
					if targets then
						targets[v] = true
					end
				elseif dig and v.components.pickable and v.components.pickable:CanBePicked() and not v:HasTag("intense") then
					v.components.pickable:Pick(inst)
					if targets then
						targets[v] = true
					end
				end
			end
		end
	end
end

local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }

local function TossLaunch(inst, launcher, basespeed, startheight, startradius)
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
	inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
	inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end

local function TossItems(inst, dist, radius)
	local x, y, z = inst.Transform:GetWorldPosition()
	if dist ~= 0 then
		local rot = inst.Transform:GetRotation() * DEGREES
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, radius + WORK_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)) do
		if v.prefab == "ice" then
			v:Remove()
		else
			if v.components.mine then
				v.components.mine:Deactivate()
			end
			if not v.components.inventoryitem.nobounce and v.Physics and v.Physics:IsActive() then
				TossLaunch(v, inst, .8 + radius, radius * .4, radius + v:GetPhysicsRadius(0))
			end
		end
	end
end

local function DoAOEAttackAndWork(inst, dist, radius, heavymult, mult, forcelanded, targets)
	DoAOEWork(inst, false, dist, radius, nil, targets)
	_AOEAttack(inst, false, dist, radius, nil, heavymult, mult, forcelanded, targets)
end

local function DoAOEAttackAndDig(inst, dist, radius, heavymult, mult, forcelanded, targets)
	DoAOEWork(inst, true, dist, radius, nil, targets)
	_AOEAttack(inst, true, dist, radius, nil, heavymult, mult, forcelanded, targets)
	TossItems(inst, dist, radius)
end

local function DoArcAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets)
	DoAOEWork(inst, false, dist, radius, arc, targets)
	_AOEAttack(inst, false, dist, radius, arc, heavymult, mult, forcelanded, targets)
end

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
	DoAOEWork(inst, false, dist, radius, nil, targets)
	_AOEAttack(inst, false, dist, radius, nil, heavymult, mult, forcelanded, targets)
end

local function DoRunWork(inst)
	DoAOEWork(inst, false, 1, 2)
end

local function DoLandingWork(inst)
	DoAOEWork(inst, false, 0, 2)
end

local function DoFinWork(inst)
	DoAOEWork(inst, true, 0.3, 0.8)
	TossItems(inst, 0.3, 0.8)
end

local SWIPE_ARC = 240
local SWIPE_OFFSET = 2
local SWIPE_RADIUS = 3.5

--------------------------------------------------------------------------

local function SpawnSwipeFX(inst, offset, reverse)
	--spawn 3 frames early (with 3 leading blank frames) since anim is super short, and tends to get lost with network timing
	inst.sg.statemem.fx = SpawnPrefab("sharkboi_swipe_fx")
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

local function SpawnIcePlowFX(inst, sideoffset)
	local x, y, z = inst.Transform:GetWorldPosition()
	if sideoffset and sideoffset ~= 0 then
		local theta = (inst.Transform:GetRotation() + 90) * DEGREES
		x = x + math.cos(theta) * sideoffset
		z = z - math.sin(theta) * sideoffset
	end
	local fx = SpawnPrefab("sharkboi_iceplow_fx")
	fx.Transform:SetPosition(x, 0, z)
end

local function SpawnIceImpactFX(inst, x, z)
	if x == nil then
		local y
		x, y, z = inst.Transform:GetWorldPosition()
	end
	local fx = SpawnPrefab("sharkboi_iceimpact_fx")
	fx.Transform:SetPosition(x, 0, z)
end

local function SpawnIceTrailFX(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local fx = SpawnPrefab("sharkboi_icetrail_fx")
	fx.Transform:SetPosition(x, 0, z)
	fx.Transform:SetRotation(inst.Transform:GetRotation())
end

local function SpawnIceHoleFX(inst, x, z)
	if x == nil then
		local y
		x, y, z = inst.Transform:GetWorldPosition()
	end
	local fx = SpawnPrefab("sharkboi_icehole_fx")
	fx.Transform:SetPosition(x, 0, z)
	return fx
end

--------------------------------------------------------------------------

local function IsTargetInFront(inst, target, arc)
	if not (target and target:IsValid()) then
		return false
	end
	local rot = inst.Transform:GetRotation()
	local rot1 = inst:GetAngleToPoint(target.Transform:GetWorldPosition())
	return DiffAngle(rot, rot1) < (arc or 180) / 2
end


local SPAWN_CHECK_TAGS = { "locomotor" }
local SPAWN_CHECK_NOTAGS = { "INLIMBO", "invisible", "flight" }
local function IsSpawnPointClear(pt)
	return #TheSim:FindEntities(pt.x, 0, pt.z, 2, SPAWN_CHECK_TAGS, SPAWN_CHECK_NOTAGS) == 0
end

--------------------------------------------------------------------------

local CHATTER_DELAYS =
{
	--NOTE: len must work for (net_tinybyte)
	["SHARKBOI_TALK_GIVEUP"] =			{ delay = 3, len = 2 },
	["SHARKBOI_ACCEPT_OCEANFISH"] =		{ delay = 3 },
	--["SHARKBOI_ACCEPT_BIG_OCEANFISH"] =	{ delay = 3 }, --no delay for the big one
	["SHARKBOI_REFUSE_NOT_OCEANFISH"] =	{ delay = 3 },
	["SHARKBOI_REFUSE_TOO_SMALL"] =		{ delay = 3 },
	["SHARKBOI_REFUSE_EMPTY"] =			{ delay = 3 },
}

local DEFAULT_CHAT_ECHO_PRIORITY = CHATPRIORITIES.LOW
local CHATTER_ECHO_PRIORITIES =
{
	["SHARKBOI_ACCEPT_OCEANFISH"]		= CHATPRIORITIES.HIGH,
	["SHARKBOI_ACCEPT_BIG_OCEANFISH"] 	= CHATPRIORITIES.HIGH,
	["SHARKBOI_REFUSE_NOT_OCEANFISH"] 	= CHATPRIORITIES.HIGH,
	["SHARKBOI_REFUSE_TOO_SMALL"]		= CHATPRIORITIES.HIGH,
	["SHARKBOI_REFUSE_EMPTY"]			= CHATPRIORITIES.HIGH,
}

local function TryChatter(inst, strtblname, index, ignoredelay, force)
	local t = GetTime()
	local delays = CHATTER_DELAYS[strtblname]
	if ignoredelay or (inst.sg.mem.lastchatter or 0) + (delays and delays.delay or 0) < t then
		inst.sg.mem.lastchatter = t
		local echo_priority = CHATTER_ECHO_PRIORITIES[strtblname] or DEFAULT_CHAT_ECHO_PRIORITY
		inst.components.talker:Chatter(
			strtblname,
			index or math.random(#STRINGS[strtblname]),
			(delays and delays.len) or nil,
			force,
			echo_priority
		)
	end
end

--------------------------------------------------------------------------

local states =
{
	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst, norotate)
			if inst.sg.mem.sleeping then
				inst.sg:GoToState("sleep")
				return
			elseif inst.pendingreward then
				inst.sg.statemem.keepsixfaced = true
				inst.sg:GoToState("give", inst.sg.mem.pendinggiver)
				return
			elseif inst:HasTag("hostile") and ShouldBeDefeated(inst) then
				inst.sg:GoToState("defeat")
				return
			elseif norotate then
				inst.sg:RemoveStateTag("canrotate")
				inst.sg:AddStateTag("try_restore_canrotate") --for brain
				inst.components.locomotor.pusheventwithdirection = true
			end
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("idle", true)
		end,

		onexit = function(inst)
			if not inst.sg.statemem.keepsixfaced then
				inst.Transform:SetFourFaced()
			end
			inst.components.locomotor.pusheventwithdirection = false
		end,
	},

	State{
		name = "talk",
		tags = { "talking", "idle", "canrotate" },

		onenter = function(inst, noanim)
			inst.components.locomotor:Stop()
			inst.Transform:SetSixFaced()
			if not noanim then
				inst.AnimState:PlayAnimation("sharkboi_talk_pre")
				inst.AnimState:PushAnimation("sharkboi_talk", true)
			end
			inst.sg:SetTimeout(5)
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
			inst.AnimState:PlayAnimation("sharkboi_talk_pst")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					--maintain 6 faced to idle!
					inst.sg.statemem.keepsixfaced = true
					inst.sg:GoToState("idle", true)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.keepsixfaced then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "refuse",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("sharkboi_reject")
			if data then
				if data.giver and data.giver:IsValid() then
					inst:ForceFacePoint(data.giver.Transform:GetWorldPosition())
				end
				if data.reason == "NOT_OCEANFISH" then
					TryChatter(inst, "SHARKBOI_REFUSE_NOT_OCEANFISH", nil, nil, true)
				elseif data.reason == "TOO_SMALL" then
					TryChatter(inst, "SHARKBOI_REFUSE_TOO_SMALL", nil, nil, true)
				elseif data.reason == "EMPTY" then
					TryChatter(inst, "SHARKBOI_REFUSE_EMPTY", nil, nil, true)
				end
			end
		end,

		timeline =
		{
			FrameEvent(27, function(inst)
				if inst.pendingreward then
					inst.sg.statemem.keepsixfaced = true
					inst.sg:GoToState("give", inst.sg.mem.pendinggiver)
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.keepsixfaced = true
					inst.sg:GoToState("idle", true)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.keepsixfaced then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "give",
		tags = { "busy" },

		onenter = function(inst, giver)
			inst.components.locomotor:Stop()
			inst.Transform:SetSixFaced()
			inst.AnimState:PlayAnimation("sharkboi_take")
			inst.sg.statemem.giver = giver
			if inst.pendingreward then
				TryChatter(inst, inst.pendingreward > 1 and "SHARKBOI_ACCEPT_BIG_OCEANFISH" or "SHARKBOI_ACCEPT_OCEANFISH", nil, nil, true)
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.giver then
				if inst.sg.statemem.giver:IsValid() then
					inst:ForceFacePoint(inst.sg.statemem.giver.Transform:GetWorldPosition())
				else
					inst.sg.statemem.giver = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(12, function(inst)
				if inst.pendingreward then
					inst:GiveReward(inst.sg.statemem.giver)
				end
				inst.sg.statemem.giver = nil
				inst.sg.mem.pendinggiver = nil
			end),
			FrameEvent(23, function(inst)
				if inst.pendingreward then
					inst.sg.statemem.keepsixfaced = true
					inst.sg:GoToState("give", inst.sg.mem.pendinggiver)
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.keepsixfaced = true
					inst.sg:GoToState("idle", true)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.keepsixfaced then
				inst.Transform:SetFourFaced()
			end
		end,
	},

	State{
		name = "spawn",
		tags = { "busy", "jumping", "nosleep", "noattack", "temp_invincible", "notalksound" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("spawn")
			inst.SoundEmitter:PlaySound("turnoftides/common/together/water/emerge/large")
			inst.SoundEmitter:PlaySound("meta3/sharkboi/spawn")
			local pos = inst:GetPosition()
			SpawnPrefab("splash_green_large").Transform:SetPosition(pos.x, 0, pos.z)
			TryChatter(inst, "SHARKBOI_TALK_IDLE", nil, true, true)
			inst.components.talker:IgnoreAll("spawn")

			local offset, angle = FindWalkableOffset(pos, math.random() * PI2, 3.75, 8, false, nil, IsSpawnPointClear, false, false)
			inst.Transform:SetRotation(angle and angle * RADIANS or math.random(360))

			inst.Physics:SetMotorVelOverride(7, 0, 0)
			ToggleOffAllObjectCollisions(inst)
			DoImpactShake(inst)
		end,

		timeline =
		{
			FrameEvent(16, function(inst)
				PlayFootstep(inst)
				inst.Physics:SetMotorVelOverride(4, 0, 0)
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
				DoLandingWork(inst)
			end),
			FrameEvent(17, function(inst) inst.Physics:SetMotorVelOverride(2, 0, 0) end),
			FrameEvent(18, function(inst) inst.Physics:SetMotorVelOverride(1, 0, 0) end),
			FrameEvent(19, function(inst) inst.Physics:SetMotorVelOverride(0.5, 0, 0) end),
			FrameEvent(20, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),
			CommonHandlers.OnNoSleepFrameEvent(24, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("temp_invincible")
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
			inst.components.talker:StopIgnoringAll("spawn")
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			if inst.sg.mem.isobstaclepassthrough then
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
			end
		end,
	},

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst, nextstateparams)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("meta3/sharkboi/hit")
			inst.sg.statemem.nextstateparams = nextstateparams
			if inst.sg.lasttags and inst.sg.lasttags["dizzy"] then
				inst.sg:AddStateTag("dizzy")
			end
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				if ShouldBeDefeated(inst) then
					inst.sg:GoToState("defeat")
					return
				elseif inst.sg.statemem.nextstateparams then
					inst.sg:GoToState(unpack(inst.sg.statemem.nextstateparams))
					return
				elseif inst.sg.statemem.doattack then
					if ChooseAttack(inst, inst.sg.statemem.doattack) then
						return
					end
					--stunlocked at range? (melee attack didn't trigger)
					local cd = inst.components.timer:GetTimeLeft("standing_dive_cd")
					if cd then
						local delta = TUNING.SHARKBOI_STANDING_DIVE_CD / 5
						if cd > delta then
							inst.components.timer:SetTimeLeft("standing_dive_cd", cd - delta)
						else
							inst.components.timer:StopTimer("standing_dive_cd")
						end
					end
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if inst.sg:HasStateTag("busy") and inst.sg.statemem.nextstateparams == nil then
					inst.sg.statemem.doattack = data and data.target or nil
					return true
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

	State{
		name = "attack1",
		tags = { "attack", "busy", "candefeat" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk1")
			if target and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
				inst.sg.statemem.target = target
			end
		end,

		timeline =
		{

			FrameEvent(12, function(inst)
				inst.components.combat:StartAttack()
				inst.SoundEmitter:PlaySound(inst.voicepath.."attack_small")
				inst.SoundEmitter:PlaySound("meta3/sharkboi/swipe_arm")
				SpawnSwipeFX(inst, 2)
			end),
			FrameEvent(16, function(inst)
				DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if IsTargetInFront(inst, inst.sg.statemem.target, SWIPE_ARC) then
						inst.sg:GoToState("attack2", inst.sg.statemem.target)
					elseif inst.components.combat.target ~= inst.sg.statemem.target and IsTargetInFront(inst, inst.components.combat.target, SWIPE_ARC) then
						inst.sg:GoToState("attack2", inst.components.combat.target)
					else
						inst.sg:GoToState("attack1_pst")
					end
				end
			end),
		},

		onexit = KillSwipeFX,
	},

	State{
		name = "attack1_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk1_pst")
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
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
		name = "attack2",
		tags = { "attack", "busy", "candefeat" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk2")
			if target and target:IsValid() then
				inst.sg.statemem.target = target
			end
			inst.components.combat:StartAttack()
			inst.SoundEmitter:PlaySound(inst.voicepath.."attack_small")
			inst.SoundEmitter:PlaySound("meta3/sharkboi/swipe_arm")
			SpawnSwipeFX(inst, 2, true)
		end,

		timeline =
		{
			FrameEvent(4, function(inst)
				DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if IsTargetInFront(inst, inst.sg.statemem.target, 120) then
						inst.sg:GoToState("attack2_delay", inst.sg.statemem.target)
					elseif inst.components.combat.target ~= inst.sg.statemem.target and IsTargetInFront(inst, inst.components.combat.target, 120) then
						inst.sg:GoToState("attack2_delay", inst.components.combat.target)
					else
						inst.sg:GoToState("attack2_pst")
					end
				end
			end),
		},

		onexit = KillSwipeFX,
	},

	State{
		name = "attack2_pst",
		tags = { "busy", "caninterrupt" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk2_pst")
		end,

		timeline =
		{
			FrameEvent(5, function(inst)
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
		name = "attack2_delay",
		tags = { "attack", "busy", "candefeat" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk2_delay")
			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				local rot = inst.Transform:GetRotation()
				local rot1 = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
				local drot = ReduceAngle(rot1 - rot)
				if math.abs(drot) < 60 then
					rot1 = rot + drot / 2
					inst.Transform:SetRotation(rot1)
				end
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.targetpos then
				if inst.sg.statemem.target then
					if inst.sg.statemem.target:IsValid() then
						local p = inst.sg.statemem.targetpos
						p.x, p.y, p.z = inst.sg.statemem.target.Transform:GetWorldPosition()
					else
						inst.sg.statemem.target = nil
					end
				end
				local rot = inst.Transform:GetRotation()
				local rot1 = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
				local drot = ReduceAngle(rot1 - rot)
				if math.abs(drot) < 90 then
					rot1 = rot + math.clamp(drot / 2, -1, 1)
					inst.Transform:SetRotation(rot1)
				end
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("attack3", inst.sg.statemem.target)
				end
			end),
		},
	},

	State{
		name = "attack3",
		tags = { "attack", "busy", "jumping", "candefeat" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk3")
			if target and target:IsValid() then
				inst.sg.statemem.target = target
			end
			inst.components.combat:StartAttack()
			inst.Physics:SetMotorVelOverride(9, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.decelspeed then
				if inst.sg.statemem.decelspeed > 1 then
					inst.sg.statemem.decelspeed = inst.sg.statemem.decelspeed - 1
					inst.Physics:SetMotorVelOverride(inst.sg.statemem.decelspeed, 0, 0)
				else
					inst.sg.statemem.decelspeed = nil
					inst.Physics:ClearMotorVelOverride()
					inst.Physics:Stop()
				end
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst) inst.sg.statemem.decelspeed = 9 end),
			FrameEvent(6, function(inst) inst.SoundEmitter:PlaySound(inst.voicepath.."attack_big") end),
			FrameEvent(8, function(inst)
				inst.SoundEmitter:PlaySound("meta3/sharkboi/swipe_tail")
				SpawnSwipeFX(inst, 2)
			end),
			FrameEvent(12, function(inst)
				DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC, nil, 1)
			end),
			FrameEvent(19, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(24, function(inst)
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
		end,
	},

	State{
		name = "ice_summon",
		tags = { "busy", "candefeat", "torpedoready" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("ice_summon")

			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.targetpos then
				if inst.sg.statemem.target then
					if inst.sg.statemem.target:IsValid() then
						local p = inst.sg.statemem.targetpos
						p.x, p.y, p.z = inst.sg.statemem.target.Transform:GetWorldPosition()
					else
						inst.sg.statemem.target = nil
					end
				end
				local rot = inst.Transform:GetRotation()
				local rot1 = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
				local drot = ReduceAngle(rot1 - rot)
				if math.abs(drot) < 90 then
					rot1 = rot + math.clamp(drot / 2, -2, 2)
					inst.Transform:SetRotation(rot1)
				end
			end
		end,

		timeline =
		{
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound(inst.voicepath.."attack_small") end),
			FrameEvent(35, function(inst)
				inst.SoundEmitter:PlaySound(inst.voicepath.."attack_big")
				inst.sg.statemem.target = nil
				inst.sg.statemem.targetpos = nil

				local x, y, z = inst.Transform:GetWorldPosition()
				local theta = inst.Transform:GetRotation() * DEGREES
				x = x + math.cos(theta)
				z = z - math.sin(theta)
				inst.sg.statemem.fx = SpawnPrefab("sharkboi_icetunnel_fx")
				inst.sg.statemem.fx.Transform:SetPosition(x, 0, z)
				inst.sg.statemem.fx.Transform:SetRotation(inst.Transform:GetRotation())
			end),
			FrameEvent(58, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interrupted = true
					--inst.sg:GoToState("idle")
					inst.sg:GoToState("torpedo_pre") --don't send target; don't change dir
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.not_interrupted and inst.sg.statemem.fx and inst.sg.statemem.fx:IsValid() then
				inst.sg.statemem.fx:Remove()
			end
		end,
	},

	--------------------------------------------------------------------------
	--Torpedo in ice field

	State{
		name = "torpedo_pre",
		tags = { "attack", "busy", "candefeat" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("torpedo_pre")
			if inst.sg.lasttags and inst.sg.lasttags["hit"] then
				inst.sg.statemem.quick = true
				inst.AnimState:SetFrame(16)
			end
			inst.SoundEmitter:PlaySound(inst.voicepath.."attack_small")

			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.targetpos then
				if inst.sg.statemem.target then
					if inst.sg.statemem.target:IsValid() then
						local p = inst.sg.statemem.targetpos
						p.x, p.y, p.z = inst.sg.statemem.target.Transform:GetWorldPosition()
					else
						inst.sg.statemem.target = nil
					end
				end
				local rot = inst.Transform:GetRotation()
				local rot1 = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
				local drot = ReduceAngle(rot1 - rot)
				if math.abs(drot) < 90 then
					rot1 = rot + math.clamp(drot / 2, -2, 2)
					inst.Transform:SetRotation(rot1)
				end
			end
		end,

		timeline =
		{
			FrameEvent(30 - 16, function(inst)
				if inst.sg.statemem.quick then
					PlayFootstep(inst)
				end
			end),
			FrameEvent(30, function(inst)
				if not inst.sg.statemem.quick then
					PlayFootstep(inst)
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("torpedo_jump")
				end
			end),
		},
	},

	State{
		name = "torpedo_jump",
		tags = { "attack", "busy", "jumping", "nosleep", "cantalk" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("torpedo_jump")
			inst.SoundEmitter:PlaySound(inst.voicepath.."attack_big")
			inst.components.combat:StartAttack()
			inst.components.timer:StopTimer("torpedo_cd")
			inst.components.timer:StartTimer("torpedo_cd", TUNING.SHARKBOI_TORPEDO_CD)
			inst.Physics:SetMotorVelOverride(16, 0, 0)
			ToggleOffCharacterCollisions(inst)
			inst.sg.statemem.targets = {}
		end,

		onupdate = function(inst)
			DoAOEAttackAndWork(inst, 0, 2.5, nil, 1, nil, inst.sg.statemem.targets)
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				inst.SoundEmitter:PlaySound("meta3/sharkboi/torpedo_drill", "drill")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.torpedo = true
					inst.sg:GoToState("torpedo", inst.sg.statemem.targets)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.torpedo then
				inst.SoundEmitter:KillSound("drill")
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				ToggleOnCharacterCollisions(inst)
			end
		end,
	},

	State{
		name = "torpedo",
		tags = { "attack", "busy", "jumping", "nosleep" },

		onenter = function(inst, targets)
			inst.components.talker:ShutUp()
			inst.components.locomotor:Stop()
			inst.Transform:SetEightFaced()
			inst.AnimState:PlayAnimation("torpedo_loop", true)
			inst.Physics:SetMotorVelOverride(16, 0, 0)
			ToggleOffCharacterCollisions(inst)
			inst.sg:SetTimeout(1)
			inst.sg.statemem.targets = targets or {}
			inst.sg.statemem.icedelay = 0
			inst.sg.statemem.traildelay = 0
			inst.sg.statemem.shakedelay = 8
			DoImpactShake(inst)
			if not inst.SoundEmitter:PlayingSound("drill") then
				inst.SoundEmitter:PlaySound("meta3/sharkboi/torpedo_drill", "drill")
			end
		end,

		onupdate = function(inst)
			DoAOEAttackAndDig(inst, -0.4, 3, nil, 1, nil, inst.sg.statemem.targets)
			if inst.sg.statemem.icedelay > 0 then
				inst.sg.statemem.icedelay = inst.sg.statemem.icedelay - 1
			else
				inst.sg.statemem.icedelay = 3
				SpawnIcePlowFX(inst, 2)
				SpawnIcePlowFX(inst, -2)
				SpawnIceTrailFX(inst)
			end
			if inst.sg.statemem.traildelay > 0 then
				inst.sg.statemem.traildelay = inst.sg.statemem.traildelay - 1
			else
				inst.sg.statemem.traildelay = 2
				SpawnIceTrailFX(inst)
			end
			if inst.sg.statemem.shakedelay > 0 then
				inst.sg.statemem.shakedelay = inst.sg.statemem.shakedelay - 1
			else
				inst.sg.statemem.shakedelay = 6
				DoDiggingShake(inst)
			end
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("torpedo_climb")
		end,

		onexit = function(inst)
			inst.Transform:SetFourFaced()
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			ToggleOnCharacterCollisions(inst)
			inst.SoundEmitter:KillSound("drill")
		end,
	},

	State{
		name = "torpedo_climb",
		tags = { "busy", "dizzy", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("torpedo_climb")
		end,

		timeline =
		{
			FrameEvent(32, function(inst) inst.SoundEmitter:PlaySound("meta3/sharkboi/hit") end),
			CommonHandlers.OnNoSleepFrameEvent(36, function(inst)
				if ShouldBeDefeated(inst) then
					inst.sg:GoToState("defeat")
					return
				end
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("torpedo_dizzy")
				end
			end),
		},
	},

	State{
		name = "torpedo_dizzy",
		tags = { "busy", "dizzy", "caninterrupt" },

		onenter = function(inst, hits)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("torpedo_dizzy")
			if hits then
				inst.AnimState:SetFrame(23)
				inst.SoundEmitter:PlaySound("meta3/sharkboi/hit", nil, 0.6)
				inst.sg.statemem.hits = hits
			end
		end,

		timeline =
		{
			FrameEvent(22, function(inst)
				if inst.sg.statemem.hits == nil then
					inst.SoundEmitter:PlaySound("meta3/sharkboi/hit")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("torpedo_pst")
				end
			end),
		},
	},

	State{
		name = "torpedo_pst",
		tags = { "busy", "notalksound" },

		onenter = function(inst, hits)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("torpedo_pst")
			if hits then
				inst.AnimState:SetFrame(19)
				inst.SoundEmitter:PlaySound(inst.voicepath.."talk", nil, 0.4)
				inst.SoundEmitter:PlaySound("meta3/sharkboi/hit", nil, 0.6)
			else
				inst.sg:AddStateTag("dizzy")
				inst.sg:AddStateTag("caninterrupt")
			end
			inst.sg.statemem.hits = 3 --maxed so we don't go back to torpedo_dizzy
		end,

		timeline =
		{
			--timeline from frame 19
			FrameEvent(34 - 19, function(inst)
				if not inst.sg:HasStateTag("dizzy") then
					inst.sg:AddStateTag("caninterrupt")

					--in case we were silenced for too long while dizzy
					if (inst.sg.mem.lasttalktime or 0) + 3 < GetTime() then
						TryChatter(inst, "SHARKBOI_TALK_FIGHT", nil, true, true)
					end
				end
			end),
			--timeline from frame 0
			FrameEvent(16, function(inst)
				if inst.sg:HasStateTag("dizzy") then
					inst.SoundEmitter:PlaySound(inst.voicepath.."talk", nil, 0.4)
					inst.SoundEmitter:PlaySound("meta3/sharkboi/hit", nil, 0.6)
				end
			end),
			FrameEvent(19, function(inst)
				if inst.sg:HasStateTag("dizzy") then
					inst.sg:RemoveStateTag("dizzy")
					inst.sg:RemoveStateTag("caninterrupt")
				end
			end),
			FrameEvent(34, function(inst)
				inst.sg:AddStateTag("caninterrupt")

				--in case we were silenced for too long while dizzy
				if (inst.sg.mem.lasttalktime or 0) + 3 < GetTime() then
					TryChatter(inst, "SHARKBOI_TALK_FIGHT", nil, true, true)
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
	},

	--------------------------------------------------------------------------
	--Jump dive in ice field

	State{
		name = "standing_dive_jump_pre",
		tags = { "busy", "candefeat", "fastdig" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_standing_jump_pre")
			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
		end,

		onupdate = function(inst)
			local target = inst.sg.statemem.target
			if target then
				if target:IsValid() then
					local pos = inst.sg.statemem.targetpos
					pos.x, pos.y, pos.z = target.Transform:GetWorldPosition()
					if target.Physics then
						--lead the target a bit
						local vx, vy, vz = target.Physics:GetVelocity()
						pos.x = pos.x + vx * 0.3
						pos.z = pos.z + vz * 0.3
					end
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(pos)
					if DiffAngle(rot, rot1) < 45 then
						inst.Transform:SetRotation(rot1)
					else
						inst.sg.statemem.target = nil
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(10, PlayFootstep),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("dive_jump", inst.sg.statemem.targetpos)
				end
			end),
		},
	},

	State{
		name = "dive_jump_delay",
		tags = { "fin", "busy", "nosleep", "noattack", "invisible", "temp_invincible", "jumping" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst:Hide()
			ToggleOffAllObjectCollisions(inst)
			if target and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
			end
			if inst.sg.lasttags and inst.sg.lasttags["idle"] then
				inst.Physics:SetMotorVelOverride(TUNING.SHARKBOI_FINSPEED / 4, 0, 0)
			else
				inst.Physics:SetMotorVelOverride(TUNING.SHARKBOI_FINSPEED / 2, 0, 0)
			end
			inst.sg:SetTimeout(0.5)
		end,

		onupdate = function(inst)
			local target = inst.sg.statemem.target
			local pos = inst.sg.statemem.targetpos
			if target then
				if target:IsValid() then
					pos.x, pos.y, pos.z = target.Transform:GetWorldPosition()
					if target.Physics then
						--lead the target a bit
						local vx, vy, vz = target.Physics:GetVelocity()
						pos.x = pos.x + vx * 0.3
						pos.z = pos.z + vz * 0.3
					end
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(pos)
					if DiffAngle(rot, rot1) < 45 then
						inst.Transform:SetRotation(rot1)
					else
						inst.sg.statemem.target = nil
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		ontimeout = function(inst)
			inst.sg.statemem.diving = true
			inst.sg:GoToState("dive_jump_pre", {
				target = inst.sg.statemem.target,
				targetpos = inst.sg.statemem.targetpos,
			})
		end,

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			if not inst.sg.statemem.diving then
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
			end
			inst:Show()
		end,
	},

	State{
		name = "dive_jump_pre",
		tags = { "busy", "nosleep", "noattack", "invisible", "temp_invincible" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_jump_pre")
			inst.DynamicShadow:Enable(false)
			if data then
				if EntityScript.is_instance(data) then
					if data:IsValid() then
						inst.sg.statemem.target = data
						inst.sg.statemem.targetpos = data:GetPosition()
						inst:ForceFacePoint(inst.sg.statemem.targetpos)
					end
				else
					inst.sg.statemem.target = data.target
					inst.sg.statemem.targetpos = data.targetpos
				end
			end
			ToggleOffAllObjectCollisions(inst)
			DoDiggingShake(inst)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.targets then
				local targets = inst.sg.statemem.targets
				DoAOEAttackAndDig(inst, 0, 2, nil, 1, nil, targets)
				if targets ~= inst.sg.statemem.targets then
					--checks if we left state or not
					return
				end
			end

			local target = inst.sg.statemem.target
			if target then
				if target:IsValid() then
					local pos = inst.sg.statemem.targetpos
					pos.x, pos.y, pos.z = target.Transform:GetWorldPosition()
					if target.Physics then
						--lead the target a bit
						local vx, vy, vz = target.Physics:GetVelocity()
						pos.x = pos.x + vx * 0.3
						pos.z = pos.z + vz * 0.3
					end
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(pos)
					if DiffAngle(rot, rot1) < 45 then
						inst.Transform:SetRotation(rot1)
					else
						inst.sg.statemem.target = nil
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				inst.sg:RemoveStateTag("invisible")
				inst.sg:RemoveStateTag("temp_invincible")
				inst.DynamicShadow:Enable(true)
				inst.components.combat:StartAttack()
				inst.sg.statemem.targets = {}
				inst.SoundEmitter:PlaySound("meta3/sharkboi/popup")
				SpawnIceImpactFX(inst)
				DoJumpOutShake(inst)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.jumping = true
					inst.sg:GoToState("dive_jump", inst.sg.statemem.targetpos)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.jumping then
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
			end
			inst.DynamicShadow:Enable(true)
		end,
	},

	State{
		name = "dive_jump",
		tags = { "busy", "jumping", "nosleep" },

		onenter = function(inst, pos)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_jump")
			inst.SoundEmitter:PlaySound(inst.voicepath.."attack_big")
			inst.components.combat:StartAttack()

			local x, y, z = inst.Transform:GetWorldPosition()
			inst.components.timer:StopTimer("standing_dive_cd")
			if inst.sg.lasttags and inst.sg.lasttags["fastdig"] then
				inst.sg:AddStateTag("fastdig")
				inst.components.timer:StartTimer("standing_dive_cd", TUNING.SHARKBOI_STANDING_DIVE_CD / 2)
			else
				inst.components.timer:StartTimer("standing_dive_cd", TUNING.SHARKBOI_STANDING_DIVE_CD)
				SpawnIceHoleFX(inst, x, z)
			end

			local theta = inst.Transform:GetRotation() * DEGREES
			local costheta = math.cos(theta)
			local sintheta = math.sin(theta)
			local dist = 6
			if pos then
				local dx = pos.x - x
				local dz = pos.z - z
				if dx == 0 and dz == 0 then
					dist = 2
				else
					local theta1 = math.atan2(-dz, dx)
					local dtheta = DiffAngleRad(theta, theta1)
					dist = math.sqrt(dx * dx + dz * dz) * math.cos(dtheta)
					dist = math.clamp(math.abs(dist), 2, 8)
				end
			end
			--V2C: allow jumping over gaps, since we can't get interrupted by death
			local map = TheWorld.Map
			while dist > 1 and not map:IsVisualGroundAtPoint(x + costheta * dist, 0, z - sintheta * dist) do
				dist = math.max(1, dist - 0.5)
			end
			local speed = dist / inst.AnimState:GetCurrentAnimationLength()
			inst.Physics:SetMotorVelOverride(speed, 0, 0)
			ToggleOffAllObjectCollisions(inst)
		end,

		timeline =
		{
			FrameEvent(20, function(inst)
				inst.sg.statemem.targets = {}
				DoAOEAttack(inst, 0, 2, nil, 1, nil, inst.sg.statemem.targets)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("dive_dig_pre", inst.sg.statemem.targets)
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
			local x, y, z = inst.Transform:GetWorldPosition()
			ToggleOnAllObjectCollisionsAt(inst, x, z)
		end,
	},

	State{
		name = "dive_dig_pre",
		tags = { "digging", "busy", "caninterrupt", "nosleep" },

		onenter = function(inst, targets)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_dig_pre")
			inst.SoundEmitter:PlaySound("meta3/sharkboi/divedown")
			SpawnIceImpactFX(inst)
			DoImpactShake(inst)
			DoAOEAttackAndDig(inst, 0, 2, nil, 1, nil, targets)
			if inst.sg.mem.sleeping or ShouldBeDefeated(inst) then
				inst.sg:GoToState("dive_dig_hit")
			elseif inst.sg.lasttags and inst.sg.lasttags["fastdig"] then
				inst.sg:AddStateTag("fastdig")
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("dive_dig_loop")
				end
			end),
		},
	},

	State{
		name = "dive_dig_loop",
		tags = { "digging", "busy", "caninterrupt", "nosleep" },

		onenter = function(inst, hits)
			inst.components.locomotor:Stop()
			if hits then
				inst.AnimState:PlayAnimation("icedive_dig_loop")
				inst.sg.statemem.hits = hits
			elseif inst.sg.lasttags and inst.sg.lasttags["fastdig"] then
				inst.AnimState:PlayAnimation("icedive_dig_loop")
			else
				inst.AnimState:PlayAnimation("icedive_dig_loop", true)
				inst.sg:SetTimeout(2 * inst.AnimState:GetCurrentAnimationLength())
			end
			inst.SoundEmitter:PlaySound("meta3/sharkboi/feetsies_wiggle_LP", "loop")
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("dive_dig_pst")
		end,

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("dive_dig_pst")
				end
			end),
		},

		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	State{
		name = "dive_dig_hit",
		tags = { "digging", "hit", "busy", "nosleep" },

		onenter = function(inst, hits)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_dig_hit")
			inst.sg.statemem.hits = (hits or 0) + 1
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				if inst.sg.statemem.hits >= 3 or inst.sg.mem.sleeping or ShouldBeDefeated(inst) then
					inst.sg:GoToState("dive_dig_stun")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("dive_dig_loop", inst.sg.statemem.hits)
				end
			end),
		},
	},

	State{
		name = "dive_dig_pst",
		tags = { "digging", "busy", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_dig_pst")
			inst.sg.statemem.fx = SpawnIceHoleFX(inst)
			inst.sg.statemem.fx.AnimState:Pause()
		end,

		timeline =
		{
			FrameEvent(2, function(inst) inst.SoundEmitter:PlaySound("meta3/sharkboi/popup") end),
			FrameEvent(3, DoDiggingShake),
			FrameEvent(4, function(inst)
				if ShouldBeDefeated(inst) then
					inst.sg:GoToState("dive_dig_hit")
					return
				end
				inst.sg:AddStateTag("noattack")
				inst.sg:AddStateTag("temp_invincible")
				ToggleOffAllObjectCollisions(inst)
				inst.DynamicShadow:Enable(false)
				SpawnIcePlowFX(inst)
			end),
			FrameEvent(10, function(inst)
				inst.sg.statemem.fx.AnimState:Resume()
				inst.sg.statemem.fx = nil
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.fin = true
					inst.sg:GoToState("fin_idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.fin then
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
				inst.DynamicShadow:Enable(true)
			end
			if inst.sg.statemem.fx then
				inst.sg.statemem.fx.AnimState:Resume()
			end
		end,
	},

	State{
		name = "dive_dig_stun",
		tags = { "busy", "dizzy", "jumping", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("icedive_stun")
			inst.SoundEmitter:PlaySound("meta3/sharkboi/popup")
			local x, y, z = inst.Transform:GetWorldPosition()
			SpawnIceImpactFX(inst, x, z)
			SpawnIceHoleFX(inst, x, z)
			DoDiggingShake(inst)
			inst.Physics:SetMotorVelOverride(4, 0, 0)
		end,

		timeline =
		{
			--Bounce
			FrameEvent(9, PlayFootstep),
			FrameEvent(12, function(inst) inst.Physics:SetMotorVelOverride(2, 0, 0) end),
			FrameEvent(12, DoDiggingShake),

			--Bounce
			FrameEvent(17, PlayFootstep),
			FrameEvent(20, function(inst) inst.Physics:SetMotorVelOverride(1, 0, 0) end),
			FrameEvent(21, function(inst) inst.Physics:SetMotorVelOverride(0.5, 0, 0) end),
			FrameEvent(22, function(inst) inst.Physics:SetMotorVelOverride(0.25, 0, 0) end),
			FrameEvent(23, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),

			FrameEvent(29, function(inst) PlayFootstep(inst, 0.5) end),
			FrameEvent(36, function(inst) PlayFootstep(inst, 0.5) end),
			FrameEvent(59, function(inst) PlayFootstep(inst, 0.75) end),
			CommonHandlers.OnNoSleepFrameEvent(59, function(inst)
				if ShouldBeDefeated(inst) then
					inst.sg:GoToState("defeat")
					return
				end
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("torpedo_dizzy")
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.Physics:Stop()
		end,
	},

	--------------------------------------------------------------------------
	--Swimming through ice field

	State{
		name = "fin_idle",
		tags = { "fin", "idle", "canrotate", "nosleep", "noattack", "invisible" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst:Hide()
			ToggleOffAllObjectCollisions(inst)
			inst.sg:SetTimeout(0.6)
		end,

		ontimeout = function(inst)
			inst.components.combat:ResetCooldown()
		end,

		onexit = function(inst)
			local x, y, z = inst.Transform:GetWorldPosition()
			ToggleOnAllObjectCollisionsAt(inst, x, z)
			inst:Show()
		end,
	},

	State{
		name = "fin_start",
		tags = { "fin", "moving", "running", "canrotate", "nosleep", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("fin_pre")
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("meta3/sharkboi/movement_thru_ice", "loop")
			end
		end,

		timeline =
		{
			FrameEvent(2, SpawnIcePlowFX),
			FrameEvent(2, SpawnIceTrailFX),
			FrameEvent(4, DoFinWork),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.fin = true
					inst.sg:GoToState("fin")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.fin then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "fin",
		tags = { "fin", "moving", "running", "canrotate", "nosleep", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			if not inst.AnimState:IsCurrentAnimation("fin_loop") then
				inst.AnimState:PlayAnimation("fin_loop", true)
			end
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("meta3/sharkboi/movement_thru_ice", "loop")
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		timeline =
		{
			FrameEvent(3, SpawnIcePlowFX),
			FrameEvent(12, SpawnIcePlowFX),
			FrameEvent(21, SpawnIcePlowFX),

			FrameEvent(0, SpawnIceTrailFX),
			FrameEvent(4, SpawnIceTrailFX),
			FrameEvent(9, SpawnIceTrailFX),
			FrameEvent(13, SpawnIceTrailFX),
			FrameEvent(18, SpawnIceTrailFX),
			FrameEvent(22, SpawnIceTrailFX),

			FrameEvent(0, DoFinWork),
			FrameEvent(3, DoFinWork),
			FrameEvent(6, DoFinWork),
			FrameEvent(9, DoFinWork),
			FrameEvent(12, DoFinWork),
			FrameEvent(15, DoFinWork),
			FrameEvent(18, DoFinWork),
			FrameEvent(21, DoFinWork),
			FrameEvent(24, DoFinWork),
		},

		ontimeout = function(inst)
			inst.sg.statemem.fin = true
			inst.sg:GoToState("fin")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.fin then
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},

	State{
		name = "fin_stop",
		tags = { "fin", "canrotate", "nosleep", "noattack" },

		onenter = function(inst, nextstateparams)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("fin_pst")
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("meta3/sharkboi/movement_thru_ice", "loop")
			end
			if nextstateparams then
				inst.sg.statemem.nextstateparams = nextstateparams
				inst.sg:AddStateTag("jumping")
			end
			SpawnIceTrailFX(inst)
		end,

		timeline =
		{
			FrameEvent(5, function(inst) inst.SoundEmitter:KillSound("loop") end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.nextstateparams then
						inst.sg:GoToState(unpack(inst.sg.statemem.nextstateparams))
					else
						inst.sg:GoToState("fin_idle")
					end
				end
			end),
		},

		onexit = function(inst)
			inst.components.locomotor:StopMoving()
			inst.SoundEmitter:KillSound("loop")
		end,
	},

	--------------------------------------------------------------------------
	--Defeated

	State{
		name = "defeat",
		tags = { "defeated", "busy", "notalksound" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("defeated_pre")
			inst.SoundEmitter:PlaySound(inst.voicepath.."stunned_pre")
			inst:StopAggro()
			TryChatter(inst, "SHARKBOI_TALK_GIVEUP", nil, true)
		end,

		timeline =
		{
			FrameEvent(4, PlayFootstep),
			FrameEvent(12, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.defeat = true
					inst.sg:GoToState("defeat_loop")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.defeat and ShouldBeDefeated(inst) then
				inst:MakeTrader()
			end
		end,
	},

	State{
		name = "defeat_loop",
		tags = { "defeated", "busy" },

		onenter = function(inst, hits)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("defeated_loop", true)
			inst.sg.statemem.hits = hits
			if hits == nil or hits < 30 then
				inst.sg:AddStateTag("caninterrupt")
				inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() * 3)
			else
				if ShouldBeDefeated(inst) then
					inst.sg:AddStateTag("noattack")
				end
				inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() * 2)
			end
			TryChatter(inst, "SHARKBOI_TALK_GIVEUP")
		end,

		ontimeout = function(inst)
			inst.sg.statemem.defeat = true
			inst.sg:GoToState("defeat_pst")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.defeat and ShouldBeDefeated(inst) then
				inst:MakeTrader()
			end
		end,
	},

	State{
		name = "defeat_hit",
		tags = { "defeated", "hit", "busy", "notalksound" },

		onenter = function(inst, hits)
			inst.components.locomotor:Stop()
			hits = (hits or 0) + 1
			local alt = hits % 10
			if alt < math.random(3, 4) then
				inst.AnimState:PlayAnimation("defeated_hit2")
				inst.sg.statemem.hits = hits
			else
				inst.AnimState:PlayAnimation("defeated_hit1")
				inst.sg.statemem.hits = hits - alt + 10
			end
			inst.SoundEmitter:PlaySound(inst.voicepath.."stunned_hit")
			TryChatter(inst, "SHARKBOI_TALK_GIVEUP")
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				if inst.sg.statemem.hits < 30 then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.defeat = true
					inst.sg:GoToState("defeat_loop", inst.sg.statemem.hits)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.defeat and ShouldBeDefeated(inst) then
				inst:MakeTrader()
			end
		end,
	},

	State{
		name = "defeat_pst",
		tags = { "defeated", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("defeated_pst")
			inst.SoundEmitter:PlaySound(inst.voicepath.."stunned_pst")
			if ShouldBeDefeated(inst) then
				inst:AddTag("notarget")
			end
		end,

		timeline =
		{
			FrameEvent(12, PlayFootstep),
			FrameEvent(14, function(inst)
				inst.sg:AddStateTag("caninterrupt")
				if ShouldBeDefeated(inst) then
					inst:MakeTrader()
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.defeat = true
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.defeat and ShouldBeDefeated(inst) then
				inst:MakeTrader()
			end
		end,
	},
}

local function DoFootstep(inst, volume)
	inst.sg.mem.lastfootstep = GetTime()
	PlayFootstep(inst, volume)
end

CommonStates.AddWalkStates(states,
{
	walktimeline =
	{
		FrameEvent(2, DoFootstep),
		FrameEvent(20, DoFootstep),
	},
},
nil, nil, nil,
{
	endonenter = function(inst)
		local t = GetTime()
		if (inst.sg.mem.lastfootstep or -math.huge) + 0.3 < t then
			inst.sg.mem.lastfootstep = t
			PlayFootstep(inst, 0.5)
		end
	end,
})

CommonStates.AddRunStates(states,
{
	starttimeline =
	{
		FrameEvent(1, DoRunWork),
	},
	runtimeline =
	{
		FrameEvent(2, DoFootstep),
		FrameEvent(16, DoFootstep),

		FrameEvent(0, DoRunWork),
		FrameEvent(4, DoRunWork),
		FrameEvent(8, DoRunWork),
		FrameEvent(12, DoRunWork),
		FrameEvent(16, DoRunWork),
		FrameEvent(20, DoRunWork),
		FrameEvent(24, DoRunWork),
	},
},
nil, nil, nil,
{
	endonenter = function(inst)
		local t = GetTime()
		if (inst.sg.mem.lastfootstep or -math.huge) + 0.3 < t then
			inst.sg.mem.lastfootstep = t
			PlayFootstep(inst, 0.5)
		end
	end,
})

CommonStates.AddSleepExStates(states,
{
	starttimeline =
	{
		FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.voicepath.."sleep_pre") end),
		FrameEvent(43, PlayFootstep),
		FrameEvent(45, function(inst)
			inst.sg:RemoveStateTag("caninterrupt")	
		end),
		FrameEvent(48, PlayFootstep),
	},
	waketimeline =
	{
		FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound(inst.voicepath.."sleep_pst") end),
		FrameEvent(4, function(inst) PlayFootstep(inst, 0.4) end),
		FrameEvent(14, function(inst) PlayFootstep(inst, 0.8) end),
		CommonHandlers.OnNoSleepFrameEvent(23, function(inst)
			if ShouldBeDefeated(inst) then
				inst.sg:GoToState("defeat")
				return
			end
			inst.sg:RemoveStateTag("nosleep")
			inst.sg:AddStateTag("caninterrupt")
		end),
		FrameEvent(25, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
	},
},
{
	onsleep = function(inst)
		inst.sg:AddStateTag("caninterrupt")
	end,
	onsleeping = function(inst)
		inst.SoundEmitter:PlaySound(inst.voicepath.."sleep_lp", "loop")
	end,
	onexitsleeping = function(inst)
		inst.SoundEmitter:KillSound("loop")
	end,
})

CommonStates.AddFrozenStates(states)

return StateGraph("sharkboi", states, events, "idle")
