local function makefeather(name)
    local assetname = "feather_"..name
    local assets =
    {
        Asset("ANIM", "anim/"..assetname..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(assetname)
        inst.AnimState:SetBuild(assetname)
        inst.AnimState:PlayAnimation("idle")

        inst.pickupsound = "cloth"

        inst:AddTag("cattoy")
        inst:AddTag("birdfeather")

        MakeInventoryFloatable(inst, "small", 0.05, 0.95)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.nobounce = true

        inst:AddComponent("tradable")

        return inst
    end
    return Prefab( assetname, fn, assets)
end

return makefeather("crow"),
    makefeather("robin"),
    makefeather("robin_winter"),
    makefeather("canary")
