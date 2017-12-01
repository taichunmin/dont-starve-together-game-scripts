local assets =
{
    Asset("ANIM", "anim/spider_spit.zip"),
}

local prefabs =
{
    "spider_web_spit_creep",
    "splash_spiderweb"
}

local function OnThrown(inst)
    inst:ListenForEvent("entitysleep", inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("spider_spit")
    inst.AnimState:SetBuild("spider_spit")
    inst.AnimState:PlayAnimation("idle")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(inst.Remove)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)

    return inst
end

return Prefab("spider_web_spit", fn, assets, prefabs)