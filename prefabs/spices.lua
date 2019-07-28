local assets =
{
    Asset("ANIM", "anim/spices.zip"),
}

local function MakeSpice(name)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("spices")
        inst.AnimState:SetBuild("spices")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("swap_spice", "spices", name)

        inst:AddTag("spice")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeSpice("spice_garlic"),
    MakeSpice("spice_sugar"),
    MakeSpice("spice_chili")
--spice_salt
