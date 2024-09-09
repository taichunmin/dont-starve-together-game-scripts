local assets =
{
    Asset("ANIM", "anim/spider_repellent.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("spider_repellent")
    inst.AnimState:SetBuild("spider_repellent")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

    inst.scrapbook_specialinfo = "SPIDERREPELLENT"

	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")
    
    inst:AddComponent("repellent")
    inst.components.repellent:AddRepelTag("spider")
    inst.components.repellent:AddIgnoreTag("spiderqueen")
    inst.components.repellent:SetRadius(TUNING.SPIDER_REPELLENT_RADIUS)
    inst.components.repellent:SetUseAmount(10)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(function() inst:Remove() end)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)

    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("spider_repellent", fn, assets)