local assets =
{
    Asset("ANIM", "anim/quagmire_portal_key.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_portal_key")
    inst.AnimState:SetBuild("quagmire_portal_key")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_portal_key").master_postinit(inst)

    return inst
end

return Prefab("quagmire_portal_key", fn, assets)
