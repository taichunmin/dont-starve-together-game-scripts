local assets =
{
    Asset("ANIM", "anim/staff_projectile.zip"),
}

local ice_prefabs =
{
    "shatter",
}

local fire_prefabs =
{
	"fire_fail_fx",
}

local function OnHitIce(inst, owner, target)
    if target:IsValid() and not target:HasTag("freezable") then
        local fx = SpawnPrefab("shatter")
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        fx.components.shatterfx:SetLevel(2)
    end
    inst:Remove()
end

local function OnHitFire(inst, owner, target)
	if target:IsValid() and not (target.components.burnable ~= nil and target.components.burnable:IsBurning()) then
		local radius = target:GetPhysicsRadius(0) + .2
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local x, y, z = inst.Transform:GetWorldPosition()
		if x ~= x1 or z ~= z1 then
			local dx = x - x1
			local dz = z - z1
			local k = radius / math.sqrt(dx * dx + dz * dz)
			x1 = x1 + dx * k
			z1 = z1 + dz * k
		end
		local fx = SpawnPrefab("fire_fail_fx")
		fx.Transform:SetPosition(
			x1 + GetRandomMinMax(-.2, .2),
			GetRandomMinMax(.1, .3),
			z1 + GetRandomMinMax(-.2, .2)
		)
	end
	inst:Remove()
end

local function common(anim, bloom, lightoverride)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("projectile")
    inst.AnimState:SetBuild("staff_projectile")
    inst.AnimState:PlayAnimation(anim, true)
    if bloom ~= nil then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
	if lightoverride ~= nil then
		inst.AnimState:SetLightOverride(lightoverride)
	end

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(50)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)

    return inst
end

local function ice()
    local inst = common("ice_spin_loop")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.projectile:SetOnHitFn(OnHitIce)

    return inst
end

local function fire()
	local inst = common("fire_spin_loop", "shaders/anim.ksh", 1)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.components.projectile:SetOnHitFn(OnHitFire)

	return inst
end

return Prefab("ice_projectile", ice, assets, ice_prefabs),
	Prefab("fire_projectile", fire, assets, fire_prefabs)
