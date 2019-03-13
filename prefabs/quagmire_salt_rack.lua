local assets =
{
    Asset("ANIM", "anim/quagmire_salt_rack.zip"),
}

local prefabs =
{
    "quagmire_salt_rack_item",
    "quagmire_saltrock",
    "collapse_small",
    "splash",
}

local prefabs_item =
{
    "quagmire_salt_rack",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_salt_rack")
    inst.AnimState:SetBuild("quagmire_salt_rack")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("salt")

    MakeObstaclePhysics(inst, 1.95)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_salt_rack").master_postinit(inst)

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_pot_hanger")
    inst.AnimState:SetBuild("quagmire_pot_hanger")
    inst.AnimState:PlayAnimation("item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_salt_rack").master_postinit_item(inst)

    return inst
end

return Prefab("quagmire_salt_rack", fn, assets, prefabs),
    Prefab("quagmire_salt_rack_item", itemfn, assets, prefabs_item)
