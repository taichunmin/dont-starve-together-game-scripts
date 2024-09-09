local assets =
{
    Asset("ANIM", "anim/quagmire_flour.zip"),
}

local prefabs =
{
    "quagmire_burnt_ingredients",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_flour")
    inst.AnimState:SetBuild("quagmire_flour")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("quagmire_stewable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_flour").master_postinit(inst)

    return inst
end

return Prefab("quagmire_flour", fn, assets, prefabs)
