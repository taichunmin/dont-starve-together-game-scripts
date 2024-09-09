local assets =
{
    Asset("ANIM", "anim/wintersfeastfuel.zip"),
}

local function OnEaten(inst, eater)
    if eater.components.talker ~= nil then
        eater.components.talker:Say( GetString(eater, "EAT_FOOD", "WINTERSFEASTFUEL") )
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wintersfeastfuel")
    inst.AnimState:SetBuild("wintersfeastfuel")
    inst.AnimState:PlayAnimation("idle_loop", true)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GENERIC
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible:SetOnEatenFn(OnEaten)

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("wintersfeastfuel", fn, assets)