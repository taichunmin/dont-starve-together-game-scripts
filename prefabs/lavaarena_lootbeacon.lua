local assets =
{
    Asset("ANIM", "anim/lavaarena_item_pickup_fx.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_item_pickup_fx")
    inst.AnimState:SetBuild("lavaarena_item_pickup_fx")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst:Hide()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_lootbeacon").master_postinit(inst)

    return inst
end

return Prefab("lavaarena_lootbeacon", fn, assets)
