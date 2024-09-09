local assets =
{
    Asset("ANIM", "anim/abigail_flower.zip"),
}

local prefabs =
{
    "lavaarena_abigail",
    "redpouch_unwrap",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("abigail_flower")
    inst.AnimState:SetBuild("abigail_flower")
    inst.AnimState:PlayAnimation("idle_1")

    inst:Hide()

    inst:SetPrefabNameOverride("abigail_flower")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_abigail_flower").master_postinit(inst)

    return inst
end

return Prefab("lavaarena_abigail_flower", fn, assets, prefabs)
