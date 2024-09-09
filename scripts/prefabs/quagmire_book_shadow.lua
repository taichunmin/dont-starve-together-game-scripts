local assets =
{
    Asset("ANIM", "anim/book_maxwell.zip"),
    Asset("INV_IMAGE", "waxwelljournal"),
}

local prefabs =
{
    "quagmire_shadowwaxwell",
    "shadow_despawn",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("book_maxwell")
    inst.AnimState:SetBuild("book_maxwell")
    inst.AnimState:PlayAnimation("idle")

    inst:SetPrefabNameOverride("waxwelljournal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_book_shadow").master_postinit(inst)

    return inst
end

return Prefab("quagmire_book_shadow", fn, assets, prefabs)
