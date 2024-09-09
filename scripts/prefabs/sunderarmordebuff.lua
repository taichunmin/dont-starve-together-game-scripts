local assets =
{
    Asset("ANIM", "anim/lavaarena_sunder_armor.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("lavaarena_sunder_armor")
    inst.AnimState:SetBuild("lavaarena_sunder_armor")
    inst.AnimState:PlayAnimation("pre")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/sunderarmordebuff").master_postinit(inst)

    return inst
end

return Prefab("sunderarmordebuff", fn, assets)
