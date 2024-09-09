local assets =
{
    Asset("ANIM", "anim/quagmire_goatmilk.zip"),
}

local prefabs =
{
    "quagmire_burnt_ingredients",
    "spoiled_food",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_goatmilk")
    inst.AnimState:SetBuild("quagmire_goatmilk")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)

    inst:AddTag("catfood")
    inst:AddTag("quagmire_stewable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_goatmilk").master_postinit(inst)

    return inst
end

return Prefab("quagmire_goatmilk", fn, assets, prefabs)
