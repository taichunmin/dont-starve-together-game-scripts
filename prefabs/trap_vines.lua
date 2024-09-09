local assets =
{
	Asset("ANIM", "anim/trap_vines.zip"),
}

local assets_base =
{
	Asset("ANIM", "anim/shadow_pillar_fx.zip"),
}

local prefabs =
{
	"trap_vines_base_fx",
}

local AOE_RADIUS = 1
local HALF_AOE_RADIUS = AOE_RADIUS / 2
local AOE_RANGE_PADDING = 3

--see winona_catapult_projectile
local NO_TAGS_PVP = { "flying", "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion" }
local NO_TAGS = shallowcopy(NO_TAGS_PVP)
table.insert(NO_TAGS, "player")
local COMBAT_TAGS = { "_combat", "locomotor" }

local TARGETS = {}

local function ForgetTarget(target)
	TARGETS[target] = nil
	target:RemoveEventCallback("onremove", ForgetTarget)
end

local function TryDoDamage(inst, target)--, attacker)
	if not TARGETS[target] then
		TARGETS[target] = true
		target:DoTaskInTime(TUNING.TRAP_VINES_HIT_COOLDOWN, ForgetTarget)
		target:ListenForEvent("onremove", ForgetTarget)

		--[[if attacker and not (target.components.combat.target and target.components.combat.target:HasTag("player")) then
			--if target is not targeting a player, then use the catapult as attacker to draw aggro
			attacker.components.combat:DoAttack(target)
		else]]
			inst.components.combat:DoAttack(target)
		--end
		return true
	end
end

local DEBUFFS = {}

local function RemoveDebuff(target)
	DEBUFFS[target] = nil

	if target.components.locomotor and target:IsValid() then
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, "trap_vines_debuff")
	end
end

local function ApplyDebuff(inst, target)
	if target.components.locomotor then
		if DEBUFFS[target] then
			DEBUFFS[target]:Cancel()
		else
			target.components.locomotor:SetExternalSpeedMultiplier(target, "trap_vines_debuff", TUNING.TRAP_VINES_SPEEDMULT)
		end
		--must be slightly longer than the update period
		DEBUFFS[target] = target:DoTaskInTime(0.2, RemoveDebuff)
		target:ListenForEvent("onremove", RemoveDebuff)
	end
end

local function OnUpdate(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, AOE_RADIUS + AOE_RANGE_PADDING, COMBAT_TAGS, TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS)

	if #ents > 0 then
		--[[if inst.attacker and inst.attacker.components.combat and inst.attacker:IsValid() then
			inst.attacker.components.combat.ignorehitrange = true
			inst.attacker.components.combat:SetDefaultDamage(TUNING.TRAP_VINES_DAMAGE)
			inst.attacker.components.planardamage:SetBaseDamage(TUNING.TRAP_VINES_PLANAR_DAMAGE)
			inst.attacker.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WINONA_CATAPULT_DAMAGETYPE_MULT)
		else
			inst.attacker = nil
		end]]

		local caster_combat
		if inst.caster and inst.caster:IsValid() then
			caster_combat = inst.caster.components.combat
		else
			inst.caster = nil
		end

		local jiggle = false
		for i, v in ipairs(ents) do
			if v:IsValid() and
				v.entity:IsVisible() and
				v:GetDistanceSqToPoint(x, y, z) < inst.components.combat:CalcHitRangeSq(v) and
				inst.components.combat:CanTarget(v)
			then
				local isally
				if caster_combat then
					isally = caster_combat:IsAlly(v)
				elseif not TheNet:GetPVPEnabled() and
					not (v.components.combat and v.components.combat:HasTarget() and v.components.combat.target:HasTag("player")) and
					(	v:HasTag("companion") or
						(v.components.follower and v.components.follower:GetLeader() and v.components.follower:GetLeader():HasTag("player"))
					)
				then
					isally = true
				end

				if not isally then
					ApplyDebuff(inst, v)

					local vx, vy, vz = v.Physics:GetVelocity()
					if vx ~= 0 or vy ~= 0 or vz ~= 0 then
						jiggle = true
						TryDoDamage(inst, v)--, inst.attacker)
					end
				end
			end
		end

		--[[if inst.attacker then
			inst.attacker.components.combat.ignorehitrange = false
			inst.attacker.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_DAMAGE)
			inst.attacker.components.planardamage:SetBaseDamage(0)
			inst.attacker.components.damagetypebonus:RemoveBonus("shadow_aligned", inst)
			inst.attacker.components.damagetypebonus:RemoveBonus("lunar_aligned", inst)
		end]]

		if jiggle and not (inst.AnimState:IsCurrentAnimation("jiggle") and inst.AnimState:GetCurrentAnimationFrame() < 8) then
			inst.AnimState:PlayAnimation("jiggle"..tostring(inst.variation))
			inst.AnimState:PushAnimation("idle"..tostring(inst.variation))
		end
	end
end

local function KeepTargetFn(inst)
	return false
end

local function DespawnTrap(inst)
	if inst._task then
		inst._task:Cancel()
		inst._task = nil

		if inst._base then
			inst._base.entity:SetParent(nil)
			inst._base.Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst._base:KillFX()
			inst._base = nil

			inst:ListenForEvent("animover", inst.Remove)
			inst.AnimState:PlayAnimation("despawn"..tostring(inst.variation))

			inst.persists = false
		else
			--we're still hidden so just remove
			inst:Remove()
		end
	end
end

local function StartSoundLoop(inst)
	if not inst.sound then
		inst.sound = true
		inst.SoundEmitter:PlaySound("meta4/winona_catapult/shadow_projectile_rose_field_lp", "loop")
	end
end

local function OnTimerDone(inst, data)
	if data and data.name == "decay" then
		inst:DespawnTrap()
	end
end

local function OnInit(inst)
	inst._base = SpawnPrefab("trap_vines_base_fx")
	inst._base.entity:SetParent(inst.entity)

	inst.AnimState:PlayAnimation("spawn"..tostring(inst.variation))
	inst.AnimState:PushAnimation("idle"..tostring(inst.variation))
	inst:Show()

	inst._task = inst:DoPeriodicTask(0.1, OnUpdate, 0.7 + math.random() * 0.1)
end

local function OnSave(inst, data)
	data.varation = inst.variation ~= 1 and inst.variation or nil
	data.sound = inst.sound or nil
end

local function OnLoad(inst, data)
	if inst._task then
		inst._task:Cancel()
		inst._task = inst:DoPeriodicTask(0.1, OnUpdate, math.random() * 0.1)

		if inst._base == nil then
			inst._base = SpawnPrefab("trap_vines_base_fx")
			inst._base.entity:SetParent(inst.entity)
		end
		inst._base.AnimState:PlayAnimation("idle", true)

		inst.variation = data and data.variation or 1
		inst.AnimState:PlayAnimation("idle"..tostring(inst.variation), true)
		inst:Show()

		if data and data.sound then
			inst:StartSoundLoop()
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("trap_vines")
	inst.AnimState:SetBuild("trap_vines")

	inst:AddTag("trap")
	inst:AddTag("trap_vines")
	inst:AddTag("NOCLICK")

	inst:Hide()

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.TRAP_VINES_DAMAGE)
	inst.components.combat:SetRange(AOE_RADIUS)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.ignorehitrange = true

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.TRAP_VINES_PLANAR_DAMAGE)

	inst:AddComponent("damagetypebonus")
	inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WINONA_CATAPULT_DAMAGETYPE_MULT)

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("decay", TUNING.TRAP_VINES_DURATION + math.random() * 0.3)
	inst:ListenForEvent("timerdone", OnTimerDone)

	inst._task = inst:DoTaskInTime(math.random() * 0.3, OnInit)
	inst.variation = math.random(3)

	inst.DespawnTrap = DespawnTrap
	inst.StartSoundLoop = StartSoundLoop
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	--inst.attacker is the catapult that spawned us
	--inst.caster is the player that triggered the catapult

	return inst
end

--------------------------------------------------------------------------

local function Base_KillFX(inst)
	inst.AnimState:PlayAnimation("pst")
	inst:ListenForEvent("animover", inst.Remove)
end

local function base_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("shadow_pillar_fx")
	inst.AnimState:SetBuild("shadow_pillar_fx")
	inst.AnimState:PlayAnimation("pre")
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:UsePointFiltering(true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("idle")

	inst.KillFX = Base_KillFX
	inst.persists = false

	return inst
end

return Prefab("trap_vines", fn, assets, prefabs),
	Prefab("trap_vines_base_fx", base_fn, assets_base)
