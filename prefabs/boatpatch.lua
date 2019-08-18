local assets =
{
    Asset("ANIM", "anim/boat_repair_build.zip"),
    Asset("ANIM", "anim/boat_repair.zip"),
}

local prefabs =
{
    "fishingnetvisualizer"
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("boat_patch")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boat_repair")
    inst.AnimState:SetBuild("boat_repair_build")
    inst.AnimState:PlayAnimation("item")

    MakeInventoryFloatable(inst, "med", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("boatpatch")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("boatpatch", fn, assets, prefabs)
