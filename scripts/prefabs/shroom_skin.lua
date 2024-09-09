local assets =
{
    Asset("ANIM", "anim/shroom_skin.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("shroom_skin")
    inst.AnimState:SetBuild("shroom_skin")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "large", nil, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("shroom_skin", fn, assets)