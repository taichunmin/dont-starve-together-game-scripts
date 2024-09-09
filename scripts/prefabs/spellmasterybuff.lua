local assets =
{
    Asset("ANIM", "anim/lavaarena_arcane_orb.zip"),
}

local prefabs =
{
    "spellmasteryorbs",
}

local prefabs_orbs =
{
    "spellmasteryorb",
}

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("lavaarena_arcane_orb")
    inst.AnimState:SetBuild("lavaarena_arcane_orb")
    inst.AnimState:PlayAnimation("anchor")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/spellmasterybuff").buff_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

local function orbfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_arcane_orb")
    inst.AnimState:SetBuild("lavaarena_arcane_orb")
    inst.AnimState:PlayAnimation("in")

    inst.Transform:SetEightFaced()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("idle")

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------

local function orbsfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/spellmasterybuff").orbs_postinit(inst)

    return inst
end

--------------------------------------------------------------------------

return Prefab("spellmasterybuff", fn, assets, prefabs),
    Prefab("spellmasteryorb", orbfn, assets),
    Prefab("spellmasteryorbs", orbsfn, nil, prefabs_orbs)
