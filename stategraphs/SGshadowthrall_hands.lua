require("stategraphs/commonstates")

local function ChooseAttack(inst, data)
	local horns = inst.components.entitytracker:GetEntity("horns")
	if horns ~= nil and horns.sg ~= nil and horns.sg:HasStateTag("attack") then
		return false
	end
	local wings = inst.components.entitytracker:GetEntity("wings")
	if wings ~= nil and wings.sg ~= nil and wings.sg:HasStateTag("attack") then
		return false
	end

	if data ~= nil and data.target ~= nil and data.target:IsValid() then
		if not inst.sg:HasStateTag("running") then
			inst:FacePoint(data.target.Transform:GetWorldPosition())
			inst.sg:GoToState("run_start")
			return true
		end
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
	EventHandler("locomote", function(inst)
		local is_moving = inst.sg:HasStateTag("moving")
		local is_running = inst.sg:HasStateTag("running")
		local is_idling = inst.sg:HasStateTag("idle")
		local can_walk = true
		local can_run = is_running

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
	end),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),
}

local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack", "shadowthrall" }

local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
	inst.components.combat.ignorehitrange = true
	local target = inst.components.combat.target
	local targethit = false
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
				if target == v then
					targethit = true
				end
				inst.components.combat:DoAttack(v)
				if mult ~= nil then
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
	return targethit
end

local function SetShadowScale(inst, scale)
	inst.DynamicShadow:SetSize(2 * scale, scale)
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
	local horns = inst.components.entitytracker:GetEntity("horns")
	if horns ~= nil and horns.components.combat ~= nil then
		horns.components.combat:OverrideCooldown(math.max(TEAM_ATTACK_COOLDOWN, horns.components.combat:GetCooldown()))
		if target ~= nil then
			horns.components.combat:SetTarget(target)
		end
	end
	local wings = inst.components.entitytracker:GetEntity("wings")
	if wings ~= nil and wings.components.combat ~= nil then
		wings.components.combat:OverrideCooldown(math.max(TEAM_ATTACK_COOLDOWN, wings.components.combat:GetCooldown()))
		if target ~= nil then
			wings.components.combat:SetTarget(target)
		end
	end
	if target ~= nil and (horns ~= nil or wings ~= nil) then
		inst.formation = target:GetAngleToPoint(inst.Transform:GetWorldPosition())
		if horns ~= nil and wings ~= nil then
			local f1 = inst.formation + 120
			local f2 = inst.formation - 120
			local horns_dir = target:GetAngleToPoint(horns.Transform:GetWorldPosition())
			local wings_dir = target:GetAngleToPoint(wings.Transform:GetWorldPosition())
			local horns_diff1 = DiffAngle(horns_dir, f1)
			local horns_diff2 = DiffAngle(horns_dir, f2)
			local wings_diff1 = DiffAngle(wings_dir, f1)
			local wings_diff2 = DiffAngle(wings_dir, f2)
			if horns_diff1 + wings_diff2 < horns_diff2 + wings_diff1 then
				horns.formation = f1
				wings.formation = f2
			else
				horns.formation = f2
				wings.formation = f1
			end
		else
			(horns or wings).formation = inst.formation + 180
		end
	else
		inst.formation = nil
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
			FrameEvent(44, function(inst) SetShadowScale(inst, .9) end),
			FrameEvent(45, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_hands/appear") end),
			FrameEvent(46, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("appearing")
				SetShadowScale(inst, .95)
			end),
			FrameEvent(47, ToggleOnCharacterCollisions),
			FrameEvent(48, function(inst) SetShadowScale(inst, 1) end),
			FrameEvent(51, function(inst)
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
			FrameEvent(18, function(inst) inst.DynamicShadow:SetSize(1.7, 1) end),
			FrameEvent(19, RemovePhysicsColliders),
			FrameEvent(20, function(inst) SetSpawnShadowScale(inst, 1) end),
			FrameEvent(46, function(inst)
				SetSpawnShadowScale(inst, .75)
				inst.SoundEmitter:PlaySound("rifts2/thrall_generic/death_pop")
			end),
			FrameEvent(48, function(inst) SetSpawnShadowScale(inst, .5) end),
			FrameEvent(50, function(inst) SetSpawnShadowScale(inst, .25) end),
			FrameEvent(51, function(inst) inst.DynamicShadow:Enable(false) end),
			FrameEvent(53, function(inst)
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
			FrameEvent(12, function(inst)
				if inst.sg.statemem.doattack == nil then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(14, function(inst)
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
		name = "run_start",
		tags = { "attack", "moving", "running", "canrotate", "softstop" },

		onenter = function(inst)
			inst.components.combat:SetRange(0)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("run_pre")
		end,

		events =
		{
			EventHandler("attacked", function(inst)
				return true
			end),
			EventHandler("locomote", function(inst)
				if inst.components.locomotor:WantsToMoveForward() then
					if inst.sg.statemem.stop then
						inst.sg.statemem.stop = false
						inst.sg:AddStateTag("canrotate")
					end
					inst.sg.statemem.walk = not inst.components.locomotor:WantsToRun()
				elseif not inst.sg.statemem.stop then
					inst.sg.statemem.stop = true
					inst.sg.statemem.walk = false
					inst.sg:RemoveStateTag("canrotate")
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.running = true
					inst.sg:GoToState("run", {
						stop = inst.sg.statemem.stop,
						walk = inst.sg.statemem.walk,
					})
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.running then
				inst.components.combat:SetRange(TUNING.SHADOWTHRALL_HANDS_ATTACK_RANGE)
			end
		end,
	},

	State{
		name = "run",
		tags = { "attack", "moving", "running", --[["canrotate",]] "softstop" },

		onenter = function(inst, data)
			inst.components.combat:SetRange(0)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("run_loop")
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_big")
			if not inst.SoundEmitter:PlayingSound("running") then
				inst.SoundEmitter:PlaySound("rifts2/thrall_hands/running_wind_lp", "running")
			end
			if type(data) == "table" then
				inst.SoundEmitter:PlaySound("rifts2/thrall_hands/footstep_run", nil, .6)
				if data.stop then
					inst.sg.statemem.stop = data.stop
					inst.sg:RemoveStateTag("canrotate")
				else
					inst.sg.statemem.walk = data.walk
				end
				inst.AnimState:Hide("fx")
				inst.Physics:ClearCollidesWith(COLLISION.OBSTACLES)
				inst.Physics:ClearCollidesWith(COLLISION.SMALLOBSTACLES)
				SetTeamAttackCooldown(inst, true)
			else
				inst.sg.statemem.loops = data
				SetTeamAttackCooldown(inst)
			end
		end,

		timeline =
		{
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_hands/footstep_run") end),
			FrameEvent(11, function(inst)
				inst.sg.statemem.targets = {}
				if DoAOEAttack(inst, 1.5, 1.2, nil, nil, nil, inst.sg.statemem.targets) then
					inst.sg.statemem.targethit = true
				end
			end),
			FrameEvent(12, function(inst)
				if DoAOEAttack(inst, 1.5, 1.2, nil, nil, nil, inst.sg.statemem.targets) then
					inst.sg.statemem.targethit = true
				end
			end),
			FrameEvent(13, function(inst)
				if DoAOEAttack(inst, .5, 1.8, nil, nil, nil, inst.sg.statemem.targets) then
					inst.sg.statemem.targethit = true
				end
			end),
		},

		events =
		{
			EventHandler("attacked", function(inst)
				return true
			end),
			EventHandler("locomote", function(inst)
				if inst.components.locomotor:WantsToMoveForward() then
					if inst.sg.statemem.stop then
						inst.sg.statemem.stop = false
						inst.sg:AddStateTag("canrotate")
					end
					inst.sg.statemem.walk = not inst.components.locomotor:WantsToRun()
				elseif not inst.sg.statemem.stop then
					inst.sg.statemem.stop = true
					inst.sg.statemem.walk = false
					inst.sg:RemoveStateTag("canrotate")
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.stop then
						inst.sg:GoToState("run_stop", inst.sg.statemem.targets ~= nil)
					elseif inst.sg.statemem.walk then
						inst.sg:GoToState("walk_start")
					elseif inst.sg.statemem.targethit
						and (inst.components.entitytracker:GetEntity("horns") ~= nil or
							inst.components.entitytracker:GetEntity("wings") ~= nil)
						then
						inst.sg:GoToState("run_stop", inst.sg.statemem.targets ~= nil)
					else
						local loops = (inst.sg.statemem.loops or 0) + 1
						if loops < 4 then
							inst.sg.statemem.running = true
							inst.sg:GoToState("run", loops)
						else
							inst.sg:GoToState("run_stop", inst.sg.statemem.targets ~= nil)
						end
					end
				end
			end),
		},

		onexit = function(inst)
			inst.AnimState:Show("fx")
			if not inst.sg.statemem.running then
				inst.SoundEmitter:KillSound("running")
				inst.components.combat:SetRange(TUNING.SHADOWTHRALL_HANDS_ATTACK_RANGE)
				inst.Physics:CollidesWith(COLLISION.OBSTACLES)
				inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
			end
		end,
	},

	State{
		name = "run_stop",
		tags = { "canrotate" },

		onenter = function(inst, attacking)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("run_pst")
			if not attacking then
				inst.AnimState:Hide("fx")
			end
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
			inst.AnimState:Show("fx")
		end,
	},
}

CommonStates.AddWalkStates(states,
{
	starttimeline =
	{
		FrameEvent(0, function(inst)
			inst.sg.mem.lastfootstep = GetTime()
			inst.SoundEmitter:PlaySound("rifts2/thrall_hands/footstep", nil, .4)
		end),
	},
	walktimeline =
	{
		FrameEvent(0, function(inst)
			local t = GetTime()
			if t > (inst.sg.mem.nextwalkvocal or 0) then
				inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_small")
				inst.sg.mem.nextwalkvocal = t + .5 + math.random()
			end
		end),
		FrameEvent(6, function(inst)
			inst.sg.mem.lastfootstep = GetTime()
			inst.SoundEmitter:PlaySound("rifts2/thrall_hands/footstep")
		end),
	},
	endtimeline =
	{
		FrameEvent(0, function(inst)
			if inst.sg.mem.lastfootstep + 0.2 <= GetTime() then
				inst.SoundEmitter:PlaySound("rifts2/thrall_hands/footstep", nil, .6)
			end
		end),
	},
})

return StateGraph("shadowthrall_hands", states, events, "idle")
