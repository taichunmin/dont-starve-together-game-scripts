local assets =
{
    Asset("ANIM", "anim/staff_projectile.zip"),
}

local ice_prefabs =
{
    "shatter",
}

local function OnHitIce(inst, owner, target)
    if target:IsValid() and not target:HasTag("freezable") then
        local fx = SpawnPrefab("shatter")
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        fx.components.shatterfx:SetLevel(2)
    end

    inst:Remove()
end

local function common(anim, bloom)
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

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

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
    return common("fire_spin_loop", "shaders/anim.ksh")
end

return Prefab("ice_projectile", ice, assets, ice_prefabs),
    Prefab("fire_projectile", fire, assets)
