local assets =
{
    Asset("ANIM", "anim/cook_pot_food6.zip"),
}

local function OnPutInInventory(inst, owner)
    if owner ~= nil and owner:IsValid() then
        owner:PushEvent("learncookbookstats", inst.prefab)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cook_pot_food")
    inst.AnimState:SetBuild("cook_pot_food6")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food6", "dustmeringue")
    inst.scrapbook_overridedata = {"swap_food", "cook_pot_food6", "dustmeringue"}

    inst:AddTag("dustmothfood")
    inst:AddTag("molebait")

    MakeInventoryFloatable(inst, "small", 0.05, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")

    inst:ListenForEvent("onputininventory", OnPutInInventory)

    return inst
end

return Prefab("dustmeringue", fn, assets)
