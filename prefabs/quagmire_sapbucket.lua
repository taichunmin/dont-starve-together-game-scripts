local assets =
{
    Asset("ANIM", "anim/quagmire_sapbucket.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_sapbucket")
    inst.AnimState:SetBuild("quagmire_sapbucket")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_sapbucket").master_postinit(inst)

    return inst
end

return Prefab("quagmire_sapbucket", fn, assets, prefabs)
