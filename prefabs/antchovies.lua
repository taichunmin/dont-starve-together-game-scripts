local assets =
{
    Asset("ANIM", "anim/antchovy.zip"),
}

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)

    inst.entity:AddDynamicShadow()

    inst.DynamicShadow:SetSize(0.65, 0.25)

    inst.AnimState:SetBank("antchovy")
    inst.AnimState:SetBuild("antchovy")
    inst.AnimState:PlayAnimation("idle")

	inst.Transform:SetTwoFaced()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

	--inst:SetStateGraph("SGantchovies")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    return inst
end

return Prefab("antchovies", fn, assets)
