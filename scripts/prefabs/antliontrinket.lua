local assets =
{
    Asset("ANIM", "anim/antliontrinket.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("antliontrinket")
    inst.AnimState:SetBuild("antliontrinket")
    inst.AnimState:PlayAnimation("1")
    inst.scrapbook_anim = "1"

    inst:AddTag("molebait")

	MakeInventoryFloatable(inst, "med", nil, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.ANTLION
    inst.components.tradable.rocktribute = 9

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("antliontrinket", fn, assets)
