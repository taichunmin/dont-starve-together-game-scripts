local assets =
{
    Asset("ANIM", "anim/quagmire_saltrock.zip"),
    Asset("ANIM", "anim/quagmire_salt.zip"),
}

local function rock_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_saltrock")
    inst.AnimState:SetBuild("quagmire_saltrock")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_salts").master_postinit_rock(inst)

    return inst
end

local function ground_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_salt")
    inst.AnimState:SetBuild("quagmire_salt")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_salts").master_postinit_ground(inst)

    return inst
end

return Prefab("quagmire_saltrock", rock_fn, assets),
    Prefab("quagmire_salt", ground_fn, assets)
