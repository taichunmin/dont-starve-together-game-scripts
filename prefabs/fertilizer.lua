local assets =
{
    Asset("ANIM", "anim/fertilizer.zip")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fertilizer")
    inst.AnimState:SetBuild("fertilizer")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.FERTILIZER_USES)
    inst.components.finiteuses:SetUses(TUNING.FERTILIZER_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("fertilizer")
    inst.components.fertilizer:SetHealingAmount(TUNING.POOP_FERTILIZE_HEALTH)
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES

    inst:AddComponent("smotherer")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("fertilizer", fn, assets)