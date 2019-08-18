local assets =
{
    Asset("ANIM", "anim/flower_petals.zip"),
}

local prefabs =
{
    "small_puff",
    "petals_evil",
}

local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
        local new = SpawnPrefab("petals_evil")
        if new ~= nil then
            new.Transform:SetPosition(x, y, z)
            if new.components.stackable ~= nil and inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
                new.components.stackable:SetStackSize(inst.components.stackable:StackSize())
            end
            if new.components.inventoryitem ~= nil and inst.components.inventoryitem ~= nil then
                new.components.inventoryitem:InheritMoisture(inst.components.inventoryitem:GetMoisture(), inst.components.inventoryitem:IsWet())
            end
            if new.components.perishable ~= nil and inst.components.perishable ~= nil then
                new.components.perishable:SetPercent(inst.components.perishable:GetPercent())
            end
            new:PushEvent("spawnedfromhaunt", { haunter = haunter, oldPrefab = inst })
            inst:PushEvent("despawnedfromhaunt", { haunter = haunter, newPrefab = new })
            inst.persists = false
            inst.entity:Hide()
            inst:DoTaskInTime(0, inst.Remove)
        end
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("petals")
    inst.AnimState:SetBuild("flower_petals")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("cattoy")
    inst:AddTag("vasedecoration")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("vasedecoration")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = 0
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunchAndPerish(inst)
    AddHauntableCustomReaction(inst, OnHaunt, false, true, false)

    return inst
end

return Prefab("petals", fn, assets, prefabs)
