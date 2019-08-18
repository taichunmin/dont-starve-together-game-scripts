local assets =
{
    Asset("ANIM", "anim/guano.zip"),
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
    SpawnPrefab("poopcloud").Transform:SetPosition(taker.Transform:GetWorldPosition())
end

local function ondropped(inst)
    if inst.flies == nil then
        inst.flies = inst:SpawnChild("flies")
    end
end

local function onpickup(inst)
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

    inst.AnimState:SetBank("guano")
    inst.AnimState:SetBuild("guano")
    inst.AnimState:PlayAnimation("dump")
    inst.AnimState:PushAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.1, 0.73)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("fertilizer")
    inst.components.fertilizer:SetHealingAmount(TUNING.POOP_FERTILIZE_HEALTH)
    inst.components.fertilizer.fertilizervalue = TUNING.GUANO_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.GUANO_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.GUANO_WITHEREDCYCLES

    inst:AddComponent("smotherer")

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)

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

    inst:AddComponent("savedscale")

    ---------------------

    return inst
end

return Prefab("guano", fn, assets, prefabs)
