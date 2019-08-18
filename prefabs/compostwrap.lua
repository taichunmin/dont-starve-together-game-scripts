local assets =
{
    Asset("ANIM", "anim/healing_cream.zip"),
}

local prefabs =
{
    "flies",
    "poopcloud",
}

local function OnBurn(inst)
    DefaultBurnFn(inst)
    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    elseif inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
end

local function FuelTaken(inst, taker)
    local fx = taker.components.burnable ~= nil and taker.components.burnable.fxchildren[1] or nil
    local x, y, z
    if fx ~= nil and fx:IsValid() then
        x, y, z = fx.Transform:GetWorldPosition()
    else
        x, y, z = taker.Transform:GetWorldPosition()
    end
    SpawnPrefab("poopcloud").Transform:SetPosition(x, y + 1, z)
end

local function OnDropped(inst)
    if inst.flies == nil then
        inst.flies = inst:SpawnChild("flies")
        if inst.inittask ~= nil then
            inst.inittask:Cancel()
            inst.inittask = nil
        end
    end
end

local function OnPickup(inst)
    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    elseif inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
end

local function OnInit(inst)
    inst.inittask = nil
    inst.flies = inst:SpawnChild("flies")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("healing_cream")
    inst.AnimState:SetBuild("healing_cream")
    inst.AnimState:PlayAnimation("idle")

    --heal_fertilize (from fertilizer component) added to pristine state for optimization
    inst:AddTag("heal_fertilize")

    inst:AddTag("slowfertilize") -- for player self fertilize healing action

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

    inst:AddComponent("fertilizer")
    inst.components.fertilizer:SetHealingAmount(TUNING.HEALING_MEDLARGE)
    inst.components.fertilizer.fertilizervalue = TUNING.COMPOSTWRAP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.COMPOSTWRAP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.COMPOSTWRAP_WITHEREDCYCLES

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    inst:AddComponent("smotherer")

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(OnBurn)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    --V2C: delay spawning flies, since it's most likely being crafted into our pockets
    inst.inittask = inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab("compostwrap", fn, assets)
