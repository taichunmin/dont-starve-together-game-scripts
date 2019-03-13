local assets =
{
    Asset("ANIM", "anim/quagmire_mushrooms.zip"),
}

local prefabs =
{
    "quagmire_mushrooms_cooked",
}

local prefabs_cooked =
{
    "quagmire_burnt_ingredients",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_mushrooms")
    inst.AnimState:SetBuild("quagmire_mushrooms")
    inst.AnimState:PlayAnimation("raw")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst:AddTag("quagmire_stewable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_mushrooms").master_postinit(inst)

    return inst
end

local function cookedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_mushrooms")
    inst.AnimState:SetBuild("quagmire_mushrooms")
    inst.AnimState:PlayAnimation("cooked")

    inst:AddTag("quagmire_stewable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_mushrooms").master_postinit_cooked(inst)

    return inst
end

return Prefab("quagmire_mushrooms", fn, assets, prefabs),
    Prefab("quagmire_mushrooms_cooked", cookedfn, assets, prefabs_cooked)
