local assets =
{
    Asset("ANIM", "anim/lavaarena_rhino_buff_effect.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_rhino_buff_effect")
    inst.AnimState:SetBuild("lavaarena_rhino_buff_effect")
    inst.AnimState:PlayAnimation("in")

    inst.Transform:SetSixFaced()

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_rhinobuff").master_postinit(inst)

    return inst
end

return Prefab("rhinobuff", fn, assets)
