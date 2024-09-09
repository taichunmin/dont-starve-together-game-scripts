local assets =
{
    Asset("ANIM", "anim/pillar_atrium.zip"),
}

local function OnPoweredFn(inst, ispowered)
    inst.AnimState:PlayAnimation(ispowered and "idle_active" or "idle", ispowered)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2.5)
    inst.Physics:SetCylinder(2.35, 6)

    inst.AnimState:SetBank("pillar_atrium")
    inst.AnimState:SetBuild("pillar_atrium")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("groundhole")
    inst:AddTag("pillar_atrium")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("atriumpowered", function(_, ispowered) OnPoweredFn(inst, ispowered) end, TheWorld)

    return inst
end

return Prefab("pillar_atrium", fn, assets)
