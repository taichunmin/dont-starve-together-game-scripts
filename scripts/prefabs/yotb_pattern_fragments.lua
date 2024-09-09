local assets =
{
    Asset("ANIM", "anim/yotb_pattern_fragment_1.zip"),
    Asset("ANIM", "anim/yotb_pattern_fragment_2.zip"),
    Asset("ANIM", "anim/yotb_pattern_fragment_3.zip"),
}

local function make(name,bank)

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("cattoy")
        inst:AddTag("yotb_pattern_fragment")

        MakeInventoryFloatable(inst, "med", 0.05, 0.68)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("tradable")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)

        MakeHauntableLaunchAndIgnite(inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return  make("yotb_pattern_fragment_1","pattern_fragment_1"),
        make("yotb_pattern_fragment_2","pattern_fragment_2"),
        make("yotb_pattern_fragment_3","pattern_fragment_3")
