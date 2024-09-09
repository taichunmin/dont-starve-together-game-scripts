local assets =
{
    Asset("ANIM", "anim/stinger.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stinger")
    inst.AnimState:SetBuild("stinger")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.1, 0.7)

    --selfstacker (from selfstacker component) added to pristine state for optimization
    inst:AddTag("selfstacker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    local selfstacker = inst:AddComponent("selfstacker")
    selfstacker:SetIgnoreMovingFast(true)

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("stinger", fn, assets)