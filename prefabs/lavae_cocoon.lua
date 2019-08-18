local assets =
{
    Asset("ANIM", "anim/lavae_cocoon.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lavae_cocoon")
    inst.AnimState:SetBuild("lavae_cocoon")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    MakeHauntableLaunch(inst)

    inst:AddComponent("bait")

    return inst
end

return Prefab("lavae_cocoon", fn, assets)
