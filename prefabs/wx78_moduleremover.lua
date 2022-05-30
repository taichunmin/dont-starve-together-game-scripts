local assets =
{
    Asset("ANIM", "anim/wx78_moduleremover.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("wx78_moduleremover")
    inst.AnimState:SetBuild("wx78_moduleremover")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "med", nil, 0.65)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------------
    inst:AddComponent("inventoryitem")

    ------------------------------------------------
    inst:AddComponent("inspectable")

    ------------------------------------------------
    inst:AddComponent("upgrademoduleremover")

    ------------------------------------------------
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    ------------------------------------------------
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("wx78_moduleremover", fn, assets)
