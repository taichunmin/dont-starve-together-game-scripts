local assets =
{
    Asset("ANIM", "anim/cotl_trinket.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cotl_trinket")
    inst.AnimState:SetBuild("cotl_trinket")
    inst.AnimState:PlayAnimation("1")

    inst:AddTag("molebait")

	MakeInventoryFloatable(inst, "med", nil, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "1"

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.COTL_TRINKET
    inst.components.tradable.rocktribute = 6

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("cotl_trinket", fn, assets)
