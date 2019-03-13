local assets =
{
    Asset("ANIM", "anim/quagmire_safe.zip"),
    Asset("ANIM", "anim/quagmire_ui_chest_3x3.zip"),
}

local prefabs =
{
    "quagmire_key",
}

local function DisplayNameFn(inst)
    return inst.replica.container ~= nil
        and not inst.replica.container:CanBeOpened()
        and STRINGS.NAMES.QUAGMIRE_SAFE_LOCKED
        or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("structure")

    inst.AnimState:SetBank("quagmire_safe")
    inst.AnimState:SetBuild("quagmire_safe")
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    inst.displaynamefn = DisplayNameFn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_safe").master_postinit(inst)

    return inst
end

return Prefab("quagmire_safe", fn, assets, prefabs)
