local assets =
{
    Asset("ANIM", "anim/bearger_tuft.zip"),
}

local function OnDropped(inst)
    inst.components.disappears:PrepareDisappear()
end

local function OnPutInInventory(inst)
    inst.components.disappears:StopDisappear()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bearger_tuft")
    inst.AnimState:SetBuild("bearger_tuft")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("disappears")
    inst.components.disappears.sound = "dontstarve/common/dust_blowaway"
    inst.components.disappears.anim = "disappear"

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:ListenForEvent("ondropped", OnDropped)
    inst.components.disappears:PrepareDisappear()

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("furtuft", fn, assets)