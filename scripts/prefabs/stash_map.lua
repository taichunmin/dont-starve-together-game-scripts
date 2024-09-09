local assets =
{
    Asset("ANIM", "anim/stash_map.zip"),
}

local function getrevealtargetpos(inst, doer)
    if not TheWorld.components.piratespawner or not TheWorld.components.piratespawner:GetCurrentStash() then
        return false, "STASH_MAP_NOT_FOUND"
    end

    return Vector3(TheWorld.components.piratespawner:GetCurrentStash().Transform:GetWorldPosition())
end

local function prereveal(inst, doer)

    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("stash_map")
    inst.AnimState:SetBuild("stash_map")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("mapspotrevealer")
    inst.components.mapspotrevealer:SetGetTargetFn(getrevealtargetpos)
    inst.components.mapspotrevealer.postreveal = function(inst) 
        inst.components.stackable:Get():Remove()
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("tradable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("stash_map", fn, assets)
