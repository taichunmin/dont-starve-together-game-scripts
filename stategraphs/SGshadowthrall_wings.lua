require("stategraphs/commonstates")

local function ChooseAttack(inst, data)
	local hands = inst.components.entitytracker:GetEntity("hands")
	if hands ~= nil and hands.sg ~= nil and hands.sg:HasStateTag("attack") then
		return false
	end
	local horns = inst.components.entitytracker:GetEntity("horns")
	if horns ~= nil and horns.sg ~= nil and horns.sg:HasStateTag("attack") then
		return false
	end

	if data ~= nil and data.target ~= nil and data.target:IsValid() then
		inst.sg:GoToState("cast", data.target)
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

local function SetShadowScale(inst, scale)
	inst.DynamicShadow:SetSize(1.7 * scale, .9 * scale)
end

local function SetSpawnShadowScale(inst, scale)
	inst.DynamicShadow:SetSize(1.5 * scale, scale)
end

local TEAM_ATTACK_COOLDOWN = 1.5
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
	local horns = inst.components.entitytracker:GetEntity("horns")
	if horns ~= nil and horns.components.combat ~= nil then
		horns.components.combat:OverrideCooldown(math.max(TEAM_ATTACK_COOLDOWN, horns.components.combat:GetCooldown()))
		if target ~= nil then
			horns.components.combat:SetTarget(target)
		end
	end
	if target ~= nil and (hands ~= nil or horns ~= nil) then
		inst.formation = target:GetAngleToPoint(inst.Transform:GetWorldPosition())
		if hands ~= nil and horns ~= nil then
			local f1 = inst.formation + 120
			local f2 = inst.formation - 120
			local hands_dir = target:GetAngleToPoint(hands.Transform:GetWorldPosition())
			local horns_dir = target:GetAngleToPoint(horns.Transform:GetWorldPosition())
			local hands_diff1 = DiffAngle(hands_dir, f1)
			local hands_diff2 = DiffAngle(hands_dir, f2)
			local horns_diff1 = DiffAngle(horns_dir, f1)
			local horns_diff2 = DiffAngle(horns_dir, f2)
			if hands_diff1 + horns_diff2 < hands_diff2 + horns_diff1 then
				hands.formation = f1
				horns.formation = f2
			else
				hands.formation = f2
				horns.formation = f1
			end
		else
			(hands or horns).formation = inst.formation + 180
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
			FrameEvent(40, function(inst)
				SetSpawnShadowScale(inst, .93)
				inst.SoundEmitter:PlaySound("rifts2/thrall_wings/appear")
			end),
			FrameEvent(42, function(inst) SetSpawnShadowScale(inst, .9) end),
			FrameEvent(44, function(inst) SetShadowScale(inst, .93) end),
			FrameEvent(45, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("appearing")
				SetShadowScale(inst, 1)
				ToggleOnCharacterCollisions(inst)
			end),
			FrameEvent(48, function(inst)
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
			if inst.sg:HasStateTag("noattack") then
				SetShadowScale(inst, 1)
				inst.DynamicShadow:Enable(true)
				ToggleOnCharacterCollisions(inst)
			end
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
			FrameEvent(13, function(inst)
				RemovePhysicsColliders(inst)
				SetSpawnShadowScale(inst, 1)
			end),
			FrameEvent(25, function(inst) inst.SoundEmitter:PlaySound("rifts2/thrall_generic/death_pop") end),
			FrameEvent(30, function(inst) SetSpawnShadowScale(inst, .5) end),
			FrameEvent(31, function(inst) inst.DynamicShadow:Enable(false) end),
			FrameEvent(32, function(inst)
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
			FrameEvent(11, function(inst)
				if inst.sg.statemem.doattack == nil then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(12, function(inst)
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
		name = "cast",
		tags = { "attack", "busy" },

		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("cast")
			inst.SoundEmitter:PlaySound("rifts2/thrall_wings/cast_f0")
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_big")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
		end,

		onupdate = function(inst)
			if inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					local pos = inst.sg.statemem.targetpos
					pos.x, pos.y, pos.z = inst.sg.statemem.target.Transform:GetWorldPosition()
				else
					inst.sg.statemem.target = nil
				end
			end
			inst:ForceFacePoint(inst.sg.statemem.targetpos)
		end,

		timeline =
		{
			FrameEvent(23, function(inst)
				SetTeamAttackCooldown(inst, true)
				inst.SoundEmitter:PlaySound("rifts2/thrall_wings/cast_f25")

				local x, y, z = inst.Transform:GetWorldPosition()
				local pos = inst.sg.statemem.targetpos
				if inst.sg.statemem.target ~= nil then
					if inst.sg.statemem.target:IsValid() then
						pos.x, pos.y, pos.z = inst.sg.statemem.target.Transform:GetWorldPosition()
					end
					inst.sg.statemem.target = nil
				end
				local dir
				if pos ~= nil then
					inst:ForceFacePoint(pos)
					dir = inst.Transform:GetRotation() * DEGREES
				else
					dir = inst.Transform:GetRotation() * DEGREES
					pos = Vector3(x + 8 * math.cos(dir), 0, z - 8 * math.sin(dir))
				end

				local targets = {} --shared table for the whole patch of particles
				local sfx = {} --shared table so we only play sfx once for the whole batch
				local proj = SpawnPrefab("shadowthrall_projectile_fx")
				proj.Physics:Teleport(x, y, z)
				proj.targets = targets
				proj.sfx = sfx
				proj.components.complexprojectile:Launch(pos, inst)

				dir = dir + PI
				local pos1 = Vector3(0, 0, 0)
				for i = 0, 4 do
					local theta = dir + TWOPI / 5 * i
					pos1.x = pos.x + 2 * math.cos(theta)
					pos1.z = pos.z - 2 * math.sin(theta)
					local proj = SpawnPrefab("shadowthrall_projectile_fx")
					proj.Physics:Teleport(x, y, z)
					proj.targets = targets
					proj.sfx = sfx
					proj.components.complexprojectile:Launch(pos1, inst)
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
}

CommonStates.AddWalkStates(states,
nil, --timeline
nil, nil, nil,
{
	walkonenter = function(inst)
		local t = GetTime()
		if t > (inst.sg.mem.nextwalkvocal or 0) then
			inst.SoundEmitter:PlaySound("rifts2/thrall_generic/vocalization_small")
			inst.sg.mem.nextwalkvocal = t + .5 + math.random()
		end
		inst.SoundEmitter:PlaySound("rifts2/thrall_wings/flap_walk")
		inst.sg.mem.lastflap = t
	end,
	endonenter = function(inst)
		if (inst.sg.mem.lastflap or 0) + 0.5 < GetTime() then
			inst.SoundEmitter:PlaySound("rifts2/thrall_wings/flap_walk", nil, .5)
		end
	end,
})

return StateGraph("shadowthrall_wings", states, events, "idle")
