require("stategraphs/commonstates")

--------------------------------------------------------------------------

local function DoFaceplantShake(inst)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .03, .15, inst, 30)
end

--------------------------------------------------------------------------

local function ChooseAttack(inst, data)
	local hands = inst.components.entitytracker:GetEntity("hands")
	if hands ~= nil and hands.sg ~= nil and hands.sg:HasStateTag("attack") then
		return false
	end
	local wings = inst.components.entitytracker:GetEntity("wings")
	if wings ~= nil and wings.sg ~= nil and wings.sg:HasStateTag("attack") then
		return false
	end

	if data ~= nil and data.target ~= nil and data.target:IsValid() then
		if inst:IsNear(data.target, 4) then
			inst.sg:GoToState("slap", data.target)
		else
			inst.sg:GoToState("jump", data.target)
		end
		return true
	end
	return false
end

local events =
{
	EventHandler("doattack", function(inst, data)
		if not inst.sg:HasStateTag("busy") then
			ChooseAttack(inst, data)
		end
	end),
	CommonHandlers.OnLocomote(false, true),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),
}

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "shadowthrall" }
local AOE_DEVOUR_RADIUS_SQ = TUNING.SHADOWTHRALL_HORNS_DEVOUR_RADIUS * TUNING.SHADOWTHRALL_HORNS_DEVOUR_RADIUS

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets, devour)
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	if dist ~= 0 then
		local rot = inst.Transform:GetRotation() * DEGREES
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
			local dsq = v:GetDistanceSqToPoint(x, y, z)
			if dsq < range * range and inst.components.combat:CanTarget(v) then
				inst.components.combat:DoAttack(v)
				if devour == true and v.sg ~= nil and v:HasTag("player") and dsq < AOE_DEVOUR_RADIUS_SQ then
					--Don't buffer, handle immediately
					v.sg:HandleEvent("devoured", { attacker = inst })
					if v.sg:HasStateTag("devoured") and v.sg.statemem.attacker == inst then
						devour = v
					end
				end
				if mult ~= nil and devour ~= v then
					local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
					v:PushEvent("knockback", { knocker = inst, radius = radius + dist + 3, strengthmult = strengthmult, forcelanded = forcelanded })
				end
				if targets ~= nil then
					targets[v] = true
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
	return EntityScript.is_instance(devour) and devour or nil
end

local SLAP_BEAM_LEN = TUNING.SHADOWTHRALL_HORNS_BISHIBASHI_RANGE
local SLAP_BEAM_WID = TUNING.SHADOWTHRALL_HORNS_BISHIBASHI_WIDTH
local SLAP_AOE_DIST = SLAP_BEAM_LEN / 2
local SLAP_AOE_RADIUS = math.sqrt(SLAP_AOE_DIST * SLAP_AOE_DIST + SLAP_BEAM_WID * SLAP_BEAM_WID / 4)

local function DoAOESlap(inst)
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	local theta = inst.Transform:GetRotation() * DEGREES
	local vx = math.cos(theta)
	local vz = -math.sin(theta)
	for i, v in ipairs(TheSim:FindEntities(x + SLAP_AOE_DIST * vx, y, z + SLAP_AOE_DIST * vz, SLAP_AOE_RADIUS + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
		if v ~= inst and
			v:IsValid() and not v:IsInLimbo()
			and not (v.components.health ~= nil and v.components.health:IsDead())
			then
			local physrad = v:GetPhysicsRadius(0)
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local dx = x1 - x
			local dz = z1 - z
			local dot = vx * dx + vz * dz
			if dot > 0 and dot < SLAP_BEAM_LEN + physrad and
				--perpendicular vector: (vz, -vx)
				math.abs(vz * dx - vx * dz) < SLAP_BEAM_WID + physrad and
				inst.components.combat:CanTarget(v)
				then
				local noimpactsound = v.components.combat.noimpactsound
				v.components.combat.noimpactsound = true
				inst.components.combat:DoAttack(v)
				v.components.combat.noimpactsound = noimpactsound
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
				v.components.workable:Destroy(inst)
				--[[if v:IsValid() and v:HasTag("stump") then
					v:Remove()
				end]]
			end
		end
	end
end

local function PlaySlapSound(inst)
	inst.SoundEmitter:PlaySound("rifts2/thrall_horns/smack")
end

local function IsDevouring(inst, target)
	return target ~= nil
		and target:IsValid()
		and target.sg ~= nil
		and target.sg:HasStateTag("devoured")
		and target.sg.statemem.attacker == inst
end

local function DoChew(inst, target, useimpactsound)
	if not useimpactsound then
		inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_flesh_med_dull")
	end
	if IsDevouring(inst, target) then
		local dmg, spdmg = inst.components.combat:CalcDamage(target)
		local noimpactsound = target.components.combat.noimpactsound
		target.components.combat.noimpactsound = not useimpactsound
		target.components.combat:GetAttacked(inst, dmg, nil, nil, spdmg)
		target.components.combat.noimpactsound = noimpactsound
	end
end

local function DoSpitOut(inst, target)
	if IsDevouring(inst, target) then
		target.sg.currentstate:HandleEvent(target.sg, "spitout", { spitter = inst, radius = inst:GetPhysicsRadius(0) + 3, strengthmult = 1 })
		if not inst.components.health:IsDead() then
			inst.components.combat:SetTarget(target)
		end
	end
end

local function SetShadowScale(inst, scale)
	inst.DynamicShadow:SetSize(5 * scale, 2.5 * scale)
end

local function SetSpawnShadowScale(inst, scale)
	inst.DynamicShadow:SetSize(1.5 * scale, scale)
end

local TEAM_ATTACK_COOLDOWN = 1
local function SetTeamAttackCooldown(inst, isstart)
	if isstart then
		inst.sg.mem.lastattack = GetTime()
		inst.components.combat:StartAttack()
	else
		inst.components.combat:RestartCooldown()
	end
	local target = inst.components.combat.target
	local hands = inst.components.entitytracker:GetEntity("hands")
	if hands ~= nil and hands.components.combat ~= nil then
		hands.components.combat:OverrideCooldown(math.max(TEAM_ATTACK_COOLDOWN, hands.components.combat:GetCooldown()))
		if target ~= nil then
			hands.components.combat:SetTarget(target)
		end
	end
	local wings = inst.components.entitytracker:GetEntity("wings")
	if wings ~= nil and wings.components.combat ~= nil then
		wings.components.combat:OverrideCooldown(math.max(TEAM_ATTACK_COOLDOWN, wings.components.combat:GetCooldown()))
		if target ~= nil then
			wings.components.combat:SetTarget(target)
		end
	end
	if target ~= nil and (hands ~= nil or wings ~= nil) then
		inst.formation = target:GetAngleToPoint(inst.Transform:GetWorldPosition())
		if hands ~= nil and wings ~= nil then
			local f1 = inst.formation + 120
			local f2 = inst.formation - 120
			local hands_dir = target:GetAngleToPoint(hands.Transform:GetWorldPosition())
			local wings_dir = target:GetAngleToPoint(wings.Transform:GetWorldPosition())
			local hands_diff1 = DiffAngle(hands_dir, f1)
			local hands_diff2 = DiffAngle(hands_dir, f2)
			local wings_diff1 = DiffAngle(wings_dir, f1)
			local wings_diff2 = DiffAngle(wings_dir, f2)
			if hands_diff1 + wings_diff2 < hands_diff2 + wings_diff1 then
				hands.formation = f1
				wings.formation = f2
			else
				hands.formation = f2
				wings.formation = f1
			end
		else
			(hands or wings).formation = inst.formation + 180
		end
	else
		inst.formation = nil
	end
end

local function ResetTeamTarget(inst)
	local target = inst.components.combat.target
	if target ~= nil then
		local hands = inst.components.entitytracker:GetEntity("hands")
		if hands ~= nil and hands.components.combat ~= nil then
			hands.components.combat:SetTarget(target)
		end
		local wings = inst.components.entitytracker:GetEntity("wings")
		if wings ~= nil and wings.components.combat ~= nil then
			wings.components.combat:SetTarget(target)
		end
	end
end

local states =
{
	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("idle", true)
		end,
	},

	State{
		name = "spawndelay",
		tags = { "busy", "noattack", "temp_invincible", "invisible" },

		onenter = function(inst, delay)
			inst.components.locomotor:Stop()
			inst.DynamicShadow:Enable(false)
			inst.Physics:SetActive(false)
			inst:Hide()
			inst:AddTag("NOCLICK")
			inst.sg:SetTimeout(delay or 0)
		end,

		ontimeout = function(inst)
			inst.sg.statemem.spawning = true
			inst.sg:GoToState("spawn")
		end,

		onexit = function(inst)
			if not inst.sg.statemem.spawning then
				inst.DynamicShadow:Enable(true)
			end
			inst.Physics:SetActive(true)
			inst:Show()
			inst:RemoveTag("NOCLICK")
		end,
	},

	State{
		name = "spawn",
		tags = { "appearing", "busy", "noattack", "temp_invincible" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("appear")
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/appear_cloth")
			inst.DynamicShadow:Enable(false)
			ToggleOffCharacterCollisions(inst)
			inst.sg.mem.lastattack = GetTime()
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				SetSpawnShadowScale(inst, .25)
				inst.DynamicShadow:Enable(true)
			end),
			FrameEvent(8, function(inst) SetSpawnShadowScale(inst, .5) end),
			FrameEvent(9, function(inst) SetSpawnShadowScale(inst, .75) end),
			FrameEvent(10, function(inst) SetSpawnShadowScale(inst, 1) end),
			FrameEvent(40, function(inst) SetSpawnShadowScale(inst, .93) end),
			FrameEvent(42, function(inst) SetSpawnShadowScale(inst, .9) end),
			FrameEvent(44, function(inst) SetShadowScale(inst, .6) end),
			FrameEvent(45, function(inst)
				SetShadowScale(inst, .8)
				inst.SoundEmitter:PlaySound("rifts2/thrall_horns/appear_f46")
			end),
			FrameEvent(46, function(inst) SetShadowScale(inst, 1) end),
			FrameEvent(47, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("appearing")
				inst.sg.statemem.targets = {}
				DoAOEWork(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, inst.sg.statemem.targets)
				DoAOEAttack(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, 1.3, 1, false, inst.sg.statemem.targets)
			end),
			FrameEvent(48, function(inst)
				ToggleOnCharacterCollisions(inst)
				DoFaceplantShake(inst)
				DoAOEWork(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, inst.sg.statemem.targets)
				DoAOEAttack(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, 1.3, 1, false, inst.sg.statemem.targets)
			end),
			FrameEvent(71, function(inst)
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

		onexit = function(inst)
			SetShadowScale(inst, 1)
			inst.DynamicShadow:Enable(true)
			ToggleOnCharacterCollisions(inst)
		end,
	},

	State{
		name = "death",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("death")
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_death")
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/death_cloth")
		end,

		timeline =
		{
			FrameEvent(9, function(inst)
				RemovePhysicsColliders(inst)
				SetShadowScale(inst, .7)
			end),
			FrameEvent(10, function(inst) SetShadowScale(inst, .5) end),
			FrameEvent(11, function(inst) SetSpawnShadowScale(inst, 1) end),
			FrameEvent(36, function(inst) SetSpawnShadowScale(inst, .75) end),
			FrameEvent(37, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_generic/death_pop") end),
			FrameEvent(38, function(inst) SetSpawnShadowScale(inst, .5) end),
			FrameEvent(40, function(inst) SetSpawnShadowScale(inst, .25) end),
			FrameEvent(41, function(inst) inst.DynamicShadow:Enable(false) end),
			FrameEvent(44, function(inst)
				local pos = inst:GetPosition()
				pos.y = 3
				inst.components.lootdropper:DropLoot(pos)
				inst:AddTag("NOCLICK")
				inst.persists = false
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:Remove()
				end
			end),
		},
	},

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_hit")
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				if inst.sg.statemem.doattack == nil then
					inst.sg:AddStateTag("caninterrupt")
					if inst.components.entitytracker:GetEntity("hands") == nil and
						inst.components.entitytracker:GetEntity("wings") == nil then
						--
						inst.components.combat:ResetCooldown()
					end
				end
			end),
			FrameEvent(10, function(inst)
				if inst.sg.statemem.doattack ~= nil then
					if ChooseAttack(inst, inst.sg.statemem.doattack) then
						return
					end
					inst.sg.statemem.doattack = nil
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if inst.sg:HasStateTag("busy") then
					inst.sg.statemem.doattack = data
					inst.sg:RemoveStateTag("caninterrupt")
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
		name = "walk_start",
		onenter = function(inst) inst.sg:GoToState("walk") end,
	},

	State{
		name = "walk",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			if not inst.AnimState:IsCurrentAnimation("walk_loop") then
				inst.AnimState:PlayAnimation("walk_loop", true)
			end
			local t = GetTime()
			if t > (inst.sg.mem.nextwalkvocal or 0) then
				inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_small")
				inst.sg.mem.nextwalkvocal = t + .5 + math.random()
			end
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		onupdate = function(inst)
			if inst.sg.statemem.accel ~= nil then
				local k = math.min(1, inst.sg.statemem.accel + .075)
				inst.sg.statemem.accel = k < 1 and k or nil
				inst.components.locomotor.walkspeed = k * TUNING.SHADOWTHRALL_HORNS_WALKSPEED
				inst.components.locomotor:WalkForward()
			elseif inst.sg.statemem.decel ~= nil then
				local k = math.max(.7, inst.sg.statemem.decel - .075)
				inst.sg.statemem.decel = k > .7 and k or nil
				inst.components.locomotor.walkspeed = k * TUNING.SHADOWTHRALL_HORNS_WALKSPEED
				inst.components.locomotor:WalkForward()
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				inst.sg.statemem.decel = 1
			end),
			FrameEvent(10, function(inst)
				inst.sg.statemem.accel = inst.sg.statemem.decel or .7
			end),
		},

		ontimeout = function(inst)
			inst.sg:GoToState("walk")
		end,

		onexit = function(inst)
			inst.components.locomotor.walkspeed = TUNING.SHADOWTHRALL_HORNS_WALKSPEED
		end,
	},

	State{
		name = "walk_stop",
		tags = { "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pst")
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
		name = "jump",
		tags = { "busy", "attack", "jumping" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jump")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst.sg.statemem.tracking = true
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.tracking then
				local target = inst.sg.statemem.target
				local targetpos = inst.sg.statemem.targetpos
				if target ~= nil then
					if target:IsValid() then
						targetpos.x, targetpos.y, targetpos.z = target.Transform:GetWorldPosition()
					else
						inst.sg.statemem.target = nil
					end
				end
				inst:ForceFacePoint(targetpos)
			end
		end,

		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_horns/jump_f5") end),
			FrameEvent(6, function(inst)
				inst.sg.statemem.tracking = false
			end),
			FrameEvent(9, function(inst)
				local x, y, z = inst.Transform:GetWorldPosition()
				local targetdist =
					inst.sg.statemem.targetpos ~= nil and
					math.min(9, math.sqrt(distsq(x, z, inst.sg.statemem.targetpos.x, inst.sg.statemem.targetpos.z))) or
					7.5
				local theta = inst.Transform:GetRotation() * DEGREES
				local costheta = math.cos(theta)
				local sintheta = math.sin(theta)
				local physrad = inst:GetPhysicsRadius(0)
				targetdist = targetdist + physrad
				local dist = math.min(1, targetdist)
				while dist < targetdist do
					if not TheWorld.Map:IsPassableAtPoint(x + costheta * dist, 0, z - sintheta * dist) then
						break
					end
					dist = math.min(targetdist, dist + 0.5)
				end
				dist = math.max(1, dist - physrad)
				-- 30 fps; 20 frames at full speed
				inst.sg.statemem.speed = dist * 30 / 20
				inst.Physics:SetMotorVelOverride(inst.sg.statemem.speed, 0, 0)
			end),
			FrameEvent(10, function(inst)
				ToggleOffAllObjectCollisions(inst)
				SetTeamAttackCooldown(inst, true)
				inst.sg:AddStateTag("nointerrupt")
			end),
			FrameEvent(29, function(inst)
				SetTeamAttackCooldown(inst)
				inst.SoundEmitter:PlaySound("rifts2/thrall_horns/jump_f31")
				inst.sg.statemem.targets = {}
				DoAOEWork(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, inst.sg.statemem.targets)
				inst.sg.statemem.devoured = DoAOEAttack(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, 1.3, 1, false, inst.sg.statemem.targets, true)
			end),
			FrameEvent(30, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
				inst.Physics:SetMotorVelOverride(.5 * inst.sg.statemem.speed, 0, 0)
				DoFaceplantShake(inst)
				DoAOEWork(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, inst.sg.statemem.targets)
				inst.sg.statemem.devoured = DoAOEAttack(inst, 0, TUNING.SHADOWTHRALL_HORNS_FACEPLANT_RADIUS, 1.3, 1, false, inst.sg.statemem.targets, inst.sg.statemem.devoured == nil) or inst.sg.statemem.devoured
				if inst.sg.statemem.devoured then
					inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/swallow")
					inst.SoundEmitter:PlaySound("rifts2/thrall_horns/wormhole_amb", "devour_loop")
				end
			end),
			FrameEvent(33, function(inst) inst.Physics:SetMotorVelOverride(.4 * inst.sg.statemem.speed, 0, 0) end),
			FrameEvent(35, function(inst) inst.Physics:SetMotorVelOverride(.2 * inst.sg.statemem.speed, 0, 0) end),
			FrameEvent(37, function(inst) inst.Physics:SetMotorVelOverride(.1 * inst.sg.statemem.speed, 0, 0) end),
			FrameEvent(39, function(inst) inst.Physics:SetMotorVelOverride(.05 * inst.sg.statemem.speed, 0, 0) end),
			FrameEvent(41, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.Physics:SetMotorVelOverride(.05 * inst.sg.statemem.speed, 0, 0)
					inst.sg.statemem.jumping = true
					if inst.sg.statemem.devoured ~= nil and inst.sg.statemem.devoured:IsValid() then
						inst.sg:GoToState("spit", inst.sg.statemem.devoured)
					else
						inst.sg:GoToState("jump_pst")
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.jumping then
				inst.SoundEmitter:KillSound("devour_loop")
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				DoSpitOut(inst, inst.sg.statemem.devoured)
				ResetTeamTarget(inst) --team may have dropped target while devoured
			end
			if inst.sg.mem.isobstaclepassthrough then
				local x, y, z = inst.Transform:GetWorldPosition()
				ToggleOnAllObjectCollisionsAt(inst, x, z)
			end
		end,
	},

	State{
		name = "jump_pst",
		tags = { "busy", "attack", "jumping" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("jump_pst")
		end,

		timeline =
		{
			FrameEvent(2, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_horns/spit_f14", nil, .7) end),
			FrameEvent(14, function(inst) inst.SoundEmitter:KillSound("devour_loop") end),
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
			inst.SoundEmitter:KillSound("devour_loop")
			if inst.sg:HasStateTag("jumping") then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end
		end,
	},

	State{
		name = "spit",
		tags = { "busy", "attack", "jumping" },

		onenter = function(inst, devoured)
			inst.AnimState:PlayAnimation("spit")
			inst.sg.statemem.devoured = devoured
		end,

		timeline =
		{
			FrameEvent(2, function(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
				inst.sg:RemoveStateTag("jumping")
			end),
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_horns/spit_f14") end),
			FrameEvent(22, function(inst)
				SetTeamAttackCooldown(inst)
				DoChew(inst, inst.sg.statemem.devoured)
			end),
			FrameEvent(28, function(inst) DoChew(inst, inst.sg.statemem.devoured) end),
			FrameEvent(38, function(inst) DoChew(inst, inst.sg.statemem.devoured) end),
			FrameEvent(44, function(inst) DoChew(inst, inst.sg.statemem.devoured) end),
			FrameEvent(55, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_horns/spit_f46") end),
			FrameEvent(58, function(inst) DoChew(inst, inst.sg.statemem.devoured, true) end),
			FrameEvent(58, function(inst)
				inst.SoundEmitter:KillSound("devour_loop")
				local devoured = inst.sg.statemem.devoured
				inst.sg.statemem.devoured = nil
				DoSpitOut(inst, devoured)
				SetTeamAttackCooldown(inst) --team may have dropped target while devoured
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
			inst.SoundEmitter:KillSound("devour_loop")
			if inst.sg:HasStateTag("jumping") then
				inst.Physics:ClearMotorVelOverride()
				inst.Physics:Stop()
			end
			DoSpitOut(inst, inst.sg.statemem.devoured)
			ResetTeamTarget(inst) --team may have dropped target while devoured
		end,
	},

	State{
		name = "slap",
		tags = { "busy", "attack" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.Transform:SetEightFaced()
			inst.AnimState:PlayAnimation("slap")
			local dir = target ~= nil and target:IsValid() and inst:GetAngleToPoint(target.Transform:GetWorldPosition()) or inst.Transform:GetRotation()
			--snap to 45's
			inst.Transform:SetRotation(math.floor(dir / 45 + .5) * 45)
		end,

		timeline =
		{
			FrameEvent(8, PlaySlapSound),
			FrameEvent(14, function(inst)
				SetTeamAttackCooldown(inst, true)
				DoAOESlap(inst)
			end),
			--
			FrameEvent(14, PlaySlapSound),
			FrameEvent(20, DoAOESlap),
			--
			FrameEvent(26, PlaySlapSound),
			FrameEvent(32, DoAOESlap),
			--
			FrameEvent(30, PlaySlapSound),
			FrameEvent(36, DoAOESlap),
			--
			FrameEvent(36, PlaySlapSound),
			FrameEvent(42, function(inst)
				SetTeamAttackCooldown(inst)
				DoAOESlap(inst)
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
			inst.Transform:SetFourFaced()
		end,
	},
}

return StateGraph("shadowthrall_horns", states, events, "idle")
