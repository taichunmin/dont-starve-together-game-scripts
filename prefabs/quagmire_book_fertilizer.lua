local assets =
{
    Asset("ANIM", "anim/books.zip"),
    Asset("INV_IMAGE", "book_gardening")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("books")
    inst.AnimState:SetBuild("books")
    inst.AnimState:PlayAnimation("book_gardening")

    inst:SetPrefabNameOverride("book_gardening")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_book_fertilizer").master_postinit(inst)

    return inst
end

return Prefab("quagmire_book_fertilizer", fn, assets)
