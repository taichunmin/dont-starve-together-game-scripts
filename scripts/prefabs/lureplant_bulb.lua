require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/eyeplant_bulb.zip"),
    Asset("ANIM", "anim/eyeplant_trap.zip"),
}

local function ondeploy(inst, pt)
    local lp = SpawnPrefab("lureplant", inst.linked_skinname, inst.skin_id)
    if lp ~= nil then
        lp.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        PreventCharacterCollisionsWithPlacedObjects(lp)
        lp.sg:GoToState("spawn")
        lp:AddTag("planted")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("eyeplant_bulb")
    inst.AnimState:SetBuild("eyeplant_bulb")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "vegetation_firm"

    MakeInventoryFloatable(inst, "small", 0.05, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    --inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.DEFAULT)
    inst.components.deployable.ondeploy = ondeploy

    return inst
end

return Prefab("lureplantbulb", fn, assets),
    MakePlacer("lureplantbulb_placer", "eyeplant_trap", "eyeplant_trap", "idle_hidden")
