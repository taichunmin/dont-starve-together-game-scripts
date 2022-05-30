local assets =
{
    Asset("ANIM", "anim/sewing_kit.zip"),
}

local function onsewn(inst, target, doer)
    doer:PushEvent("repair")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sewing_kit")
    inst.AnimState:SetBuild("sewing_kit")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SEWINGKIT_USES)
    inst.components.finiteuses:SetUses(TUNING.SEWINGKIT_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)



    inst:AddComponent("sewing")
    inst.components.sewing.repair_value = TUNING.SEWINGKIT_REPAIR_VALUE
    inst.components.sewing.onsewn = onsewn
    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("sewing_kit", fn, assets)