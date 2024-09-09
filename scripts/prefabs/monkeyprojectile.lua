local assets =
{
    Asset("ANIM", "anim/monkey_projectile.zip"),
}

local prefabs =
{
    "poop",
    "splash_ocean",
}

local function SplashOceanPoop(poop)
    if not poop.components.inventoryitem:IsHeld() then
        local x, y, z = poop.Transform:GetWorldPosition()
        if not poop:IsOnValidGround() or TheWorld.Map:IsPointNearHole(Vector3(x, 0, z)) then
            SpawnPrefab("splash_ocean").Transform:SetPosition(x, y, z)
            poop:Remove()
        end
    end
end

local function SpawnPoop(inst, owner, target)
    local poop = SpawnPrefab("poop")
    poop.SoundEmitter:PlaySound("dontstarve/creatures/monkey/poopsplat")
    if target ~= nil and target:IsValid() then
        LaunchAt(poop, target, owner ~= nil and owner:IsValid() and owner or inst)
    else
        poop.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if poop:IsAsleep() then
            SplashOceanPoop(poop)
        else
            poop:DoTaskInTime(8 * FRAMES, SplashOceanPoop)
        end
    end
end

local function OnHit(inst, owner, target)
    if target.components.sanity ~= nil then
        target.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
    end
    SpawnPoop(inst, owner, target)
    target:PushEvent("attacked", { attacker = owner, damage = 0 })
    inst:Remove()
end

local function OnMiss(inst, owner, target)
    SpawnPoop(inst, owner, nil)
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("monkey_projectile")
    inst.AnimState:SetBuild("monkey_projectile")
    inst.AnimState:PlayAnimation("idle")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile.range = 30

    return inst
end

return Prefab("monkeyprojectile", fn, assets, prefabs)