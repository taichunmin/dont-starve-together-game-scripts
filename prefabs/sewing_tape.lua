local assets =
{
    Asset("ANIM", "anim/sewing_tape.zip"),
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

    inst.AnimState:SetBank("tape")
    inst.AnimState:SetBuild("sewing_tape")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("tape")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("sewing")
    inst.components.sewing.repair_value = TUNING.SEWING_TAPE_REPAIR_VALUE
    inst.components.sewing.onsewn = onsewn
    ---------------------       

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("sewing_tape", fn, assets)