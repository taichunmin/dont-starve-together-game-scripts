local assets =
{
    Asset("ANIM", "anim/poop.zip"),
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
    end
end

local function OnPickup(inst)
    if inst.flies ~= nil then
        inst.flies:Remove()
        inst.flies = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("poop")
    inst.AnimState:SetBuild("poop")
    inst.AnimState:PlayAnimation("dump")

    MakeInventoryFloatable(inst, "med", 0.1, 0.73)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("idle", false)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("fertilizer")
    inst.components.fertilizer:SetHealingAmount(TUNING.POOP_FERTILIZE_HEALTH)
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES

    inst:AddComponent("smotherer")

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

    inst.flies = inst:SpawnChild("flies")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    if TheNet:GetServerGameMode() == "quagmire" then
        inst.components.fuel:SetOnTakenFn(nil)
    end

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(OnBurn)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("poop", fn, assets, prefabs)
