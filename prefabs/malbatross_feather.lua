local assets =
{
    Asset("ANIM", "anim/malbatross_feather.zip"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("malbatross_feather")
    inst.AnimState:SetBuild("malbatross_feather")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

	inst:AddTag("cattoy")
    inst:AddTag("birdfeather")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end


local function fallfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("malbatross_feather")
    inst.AnimState:SetBuild("malbatross_feather")
    inst.AnimState:PlayAnimation("fall")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", function()
        local x,y,z = inst.Transform:GetWorldPosition()
        local prop = SpawnPrefab("malbatross_feather")
        prop.Transform:SetPosition(x,y,z)
        prop.components.floater:OnLandedServer()
        inst:Remove()
    end)

    return inst
end


return Prefab("malbatross_feather", fn, assets),
        Prefab("malbatross_feather_fall", fallfn, assets)