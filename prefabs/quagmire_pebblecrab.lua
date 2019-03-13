local assets =
{
    Asset("ANIM", "anim/quagmire_pebble_crab.zip"),
}

local prefabs =
{
    "quagmire_crabmeat",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, .25)

    inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("quagmire_pebble_crab")
    inst.AnimState:SetBuild("quagmire_pebble_crab")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("cattoy")
    inst:AddTag("crab")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_pebblecrab").master_postinit(inst)

    return inst
end

return Prefab("quagmire_pebblecrab", fn, assets, prefabs)
