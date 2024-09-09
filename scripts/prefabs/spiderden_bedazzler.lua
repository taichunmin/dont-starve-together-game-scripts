local assets =
{
    Asset("ANIM", "anim/spiderden_bedazzler.zip")
}

local prefabs = 
{
    "bedazzle_buff",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("spiderden_bedazzler")
    inst.AnimState:SetBuild("spiderden_bedazzler")
    inst.AnimState:PlayAnimation("idle", true)
    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

    inst.scrapbook_specialinfo = "DENBEDAZZLER"

	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(function() inst:Remove() end)
    
    inst:AddComponent("bedazzler")
    inst.components.bedazzler:SetUseAmount(TUNING.BEDAZZLER_USE_AMOUNT)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)

    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("spiderden_bedazzler", fn, assets, prefabs)