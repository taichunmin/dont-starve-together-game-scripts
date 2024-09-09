local assets =
{
    Asset("ANIM", "anim/slingshotammo.zip"),
}


-- temp aggro system for the slingshots
local function no_aggro(attacker, target)
	local targets_target = target.components.combat ~= nil and target.components.combat.target or nil
	return targets_target ~= nil and targets_target:IsValid() and targets_target ~= attacker and attacker ~= nil and attacker:IsValid()
			and (GetTime() - target.components.combat.lastwasattackedbytargettime) < 4
			and (targets_target.components.health ~= nil and not targets_target.components.health:IsDead())
end

local function ImpactFx(inst, attacker, target)
    if target ~= nil and target:IsValid() then
		local impactfx = SpawnPrefab(inst.ammo_def.impactfx)
		impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function OnAttack(inst, attacker, target)
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
		if inst.ammo_def ~= nil and inst.ammo_def.onhit ~= nil then
			inst.ammo_def.onhit(inst, attacker, target)
		end
		ImpactFx(inst, attacker, target)
	end
end

local function OnPreHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil and no_aggro(attacker, target) then
        target.components.combat:SetShouldAvoidAggro(attacker)
	end
end

local function OnHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
		target.components.combat:RemoveShouldAvoidAggro(attacker)
	end
    inst:Remove()
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function SpawnShadowTentacle(inst, attacker, target, pt, starting_angle)
    local offset = FindWalkableOffset(pt, starting_angle, 2, 3, false, true, NoHoles, false, true)
    if offset ~= nil then
        local tentacle = SpawnPrefab("shadowtentacle")
        if tentacle ~= nil then
			tentacle.owner = attacker
            tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
            tentacle.components.combat:SetTarget(target)

			tentacle.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shadowTentacleAttack_1")
			tentacle.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shadowTentacleAttack_2")
        end
    end
end

local function OnHit_Thulecite(inst, attacker, target)
    if math.random() < 0.5 then
        local pt
        if target ~= nil and target:IsValid() then
            pt = target:GetPosition()
        else
            pt = inst:GetPosition()
            target = nil
        end

		local theta = math.random() * TWOPI
		SpawnShadowTentacle(inst, attacker, target, pt, theta)
    end

    inst:Remove()
end

local function onloadammo_ice(inst, data)
	if data ~= nil and data.slingshot then
		data.slingshot:AddTag("extinguisher")
	end
end

local function onunloadammo_ice(inst, data)
	if data ~= nil and data.slingshot then
		data.slingshot:RemoveTag("extinguisher")
	end
end

local function OnHit_Ice(inst, attacker, target)
    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(TUNING.SLINGSHOT_AMMO_FREEZE_COLDNESS)
        target.components.freezable:SpawnShatterFX()
    else
        local fx = SpawnPrefab("shatter")
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        fx.components.shatterfx:SetLevel(2)
    end

    if not no_aggro(attacker, target) and target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    inst:Remove()
end

local function OnHit_Speed(inst, attacker, target)
	local debuffkey = inst.prefab

	if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then
		if target._slingshot_speedmulttask ~= nil then
			target._slingshot_speedmulttask:Cancel()
		end
		target._slingshot_speedmulttask = target:DoTaskInTime(TUNING.SLINGSHOT_AMMO_MOVESPEED_DURATION, function(i) i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) i._slingshot_speedmulttask = nil end)

		target.components.locomotor:SetExternalSpeedMultiplier(target, debuffkey, TUNING.SLINGSHOT_AMMO_MOVESPEED_MULT)
	end

    inst:Remove()
end

local function OnHit_Distraction(inst, attacker, target)
	if target ~= nil and target:IsValid() and target.components.combat ~= nil then
		local targets_target = target.components.combat.target
		if targets_target == nil or targets_target == attacker then
            target.components.combat:SetShouldAvoidAggro(attacker)
			target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
            target.components.combat:RemoveShouldAvoidAggro(attacker)

			if not target:HasTag("epic") then
				target.components.combat:DropTarget()
			end
		end
	end

    inst:Remove()
end

local function OnMiss(inst, owner, target)
    inst:Remove()
end

local function projectile_fn(ammo_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("slingshotammo")
    inst.AnimState:SetBuild("slingshotammo")
    inst.AnimState:PlayAnimation("spin_loop", true)
	if ammo_def.symbol ~= nil then
		inst.AnimState:OverrideSymbol("rock", "slingshotammo", ammo_def.symbol)
	end

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

	if ammo_def.tags then
		for _, tag in pairs(ammo_def.tags) do
			inst:AddTag(tag)
		end
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

	inst.ammo_def = ammo_def

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(ammo_def.damage)
	inst.components.weapon:SetOnAttack(OnAttack)


    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnPreHitFn(OnPreHit)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile.range = 30
	inst.components.projectile.has_damage_set = true

    return inst
end

local function inv_fn(ammo_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("slingshotammo")
    inst.AnimState:SetBuild("slingshotammo")
    inst.AnimState:PlayAnimation("idle")
	if ammo_def.symbol ~= nil then
		inst.AnimState:OverrideSymbol("rock", "slingshotammo", ammo_def.symbol)
        inst.scrapbook_overridedata = {"rock", "slingshotammo", ammo_def.symbol}
	end

    inst:AddTag("molebait")
	inst:AddTag("slingshotammo")
	inst:AddTag("reloaditem_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("reloaditem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("bait")
    MakeHauntableLaunch(inst)

	if ammo_def.fuelvalue ~= nil then
		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = ammo_def.fuelvalue
	end

	if ammo_def.onloadammo ~= nil and ammo_def.onunloadammo ~= nil then
		inst:ListenForEvent("ammoloaded", ammo_def.onloadammo)
		inst:ListenForEvent("ammounloaded", ammo_def.onunloadammo)
		inst:ListenForEvent("onremove", ammo_def.onunloadammo)
	end

    return inst
end

-- NOTE(DiogoW): Add an entry to SCRAPBOOK_DEPS table in prefabs/slingshot.lua when adding a new ammo.
local ammo =
{
	{
		name = "slingshotammo_rock",
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS,
	},
    {
        name = "slingshotammo_gold",
		symbol = "gold",
        damage = TUNING.SLINGSHOT_AMMO_DAMAGE_GOLD,
    },
	{
		name = "slingshotammo_marble",
		symbol = "marble",
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_MARBLE,
	},
	{
		name = "slingshotammo_thulecite", -- chance to spawn a Shadow Tentacle
		symbol = "thulecite",
		onhit = OnHit_Thulecite,
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_THULECITE,
	},
    {
        name = "slingshotammo_freeze",
		symbol = "freeze",
        onhit = OnHit_Ice,
		tags = { "extinguisher" },
		onloadammo = onloadammo_ice,
		onunloadammo = onunloadammo_ice,
        damage = nil,
    },
    {
        name = "slingshotammo_slow",
		symbol = "slow",
        onhit = OnHit_Speed,
        damage = TUNING.SLINGSHOT_AMMO_DAMAGE_SLOW,
    },
    {
        name = "slingshotammo_poop", -- distraction (drop target, note: hostile creatures will probably retarget you very shortly after)
		symbol = "poop",
        onhit = OnHit_Distraction,
        damage = nil,
		fuelvalue = TUNING.MED_FUEL / 10, -- 1/10th the value of using poop
    },
    {
        name = "trinket_1",
		no_inv_item = true,
		symbol = "trinket_1",
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_TRINKET_1,
    },
}

local ammo_prefabs = {}
for _, v in ipairs(ammo) do
	v.impactfx = "slingshotammo_hitfx_" .. (v.symbol or "rock")

	---
	if not v.no_inv_item then
		table.insert(ammo_prefabs, Prefab(v.name, function() return inv_fn(v) end, assets))
	end

	local prefabs =
	{
		"shatter",
	}
	table.insert(prefabs, v.impactfx)
	table.insert(ammo_prefabs, Prefab(v.name.."_proj", function() return projectile_fn(v) end, assets, prefabs))
end


return unpack(ammo_prefabs)