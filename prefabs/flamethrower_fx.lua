local prefabs =
{
	"warg_mutated_breath_fx",
	"warg_mutated_ember_fx",
}

local function SpawnBreathFX(inst, dist, targets, updateangle)
	if updateangle then
		inst.angle = (inst.entity:GetParent() or inst).Transform:GetRotation() * DEGREES

		if not inst.SoundEmitter:PlayingSound("loop") then
			inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
			inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "loop")
		end
	end

	local fx = table.remove(inst.flame_pool)
	if fx == nil then
		fx = SpawnPrefab("warg_mutated_breath_fx")
		fx:SetFXOwner(inst, inst.flamethrower_attacker)
	end

	local scale = (1.4 + math.random() * 0.25)
	if dist < 6 then
		scale = scale * 1.2
	elseif dist > 7 then
		scale = scale * (1 + (dist - 7) / 6)
	end

	local fadeoption = (dist < 6 and "nofade") or (dist <= 7 and "latefade") or nil

	local x, y, z = inst.Transform:GetWorldPosition()
	local angle = inst.angle
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist
	dist = dist / 20
	angle = math.random() * PI2
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist

	fx.Transform:SetPosition(x, 0, z)
	fx:RestartFX(scale, fadeoption, targets)
end

local function SetFlamethrowerAttacker(inst, attacker)
	inst.flamethrower_attacker = attacker
end

local function OnRemoveEntity(inst)
	if inst.flame_pool ~= nil then
		for i, v in ipairs(inst.flame_pool) do
			v:Remove()
		end
		inst.flame_pool = nil
	end
	if inst.ember_pool ~= nil then
		for i, v in ipairs(inst.ember_pool) do
			v:Remove()
		end
		inst.ember_pool = nil
	end
end

local function KillSound(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function KillFX(inst)
	for i, v in ipairs(inst.tasks) do
		v:Cancel()
	end
	inst.OnRemoveEntity = nil
	OnRemoveEntity(inst)
	--Delay removal because lingering flame fx still references us for weapon damage
	inst:DoTaskInTime(1, inst.Remove)

	inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pst")
	inst:DoTaskInTime(6 * FRAMES, KillSound)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("CLASSIFIED")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.flame_pool = {}
	inst.ember_pool = {}
	inst.angle = 0

	local targets = {}
	local period = 10 * FRAMES
	inst.tasks =
	{
		inst:DoPeriodicTask(period, SpawnBreathFX, 0 * FRAMES, 3, targets, true),
		inst:DoPeriodicTask(period, SpawnBreathFX, 3 * FRAMES, 5, targets),
		inst:DoPeriodicTask(period, SpawnBreathFX, 6 * FRAMES, 7, targets),
		inst:DoPeriodicTask(period, SpawnBreathFX, 9 * FRAMES, 9, targets),
	}

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.WILLOW_LUNAR_FIRE_DAMAGE)

	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.WILLOW_LUNAR_FIRE_PLANAR_DAMAGE)

	inst:AddComponent("damagetypebonus")
	inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WILLOW_LUNAR_FIRE_BONUS)	

	inst.SetFlamethrowerAttacker = SetFlamethrowerAttacker
	inst.KillFX = KillFX
	inst.OnRemoveEntity = OnRemoveEntity

	inst.persists = false

	return inst
end

return Prefab("flamethrower_fx", fn, nil, prefabs)
