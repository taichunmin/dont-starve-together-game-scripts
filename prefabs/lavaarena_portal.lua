local assets =
{
    Asset("ANIM", "anim/lavaarena_portal.zip"),
}

local prefabs =
{
    "lavaarena_keyhole",
    "lavaarena_portal_activefx",
    "lavaarena_portal_player_fx",
}

local keyhole_assets =
{
    Asset("ANIM", "anim/lavaarena_keyhole.zip"),
}

local fx_assets =
{
    Asset("ANIM", "anim/lavaarena_portal_fx.zip"),
}

local function CreateDropShadow(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --[[Non-networked entity]]

    inst.AnimState:SetBuild("lavaarena_portal")
    inst.AnimState:SetBank("lavaarena_portal")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:OverrideSymbol("lavaarena_portal01", "lavaarena_portal", "shadow")

    inst.Transform:SetEightFaced()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.persists = false
    inst.entity:SetParent(parent.entity)

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("lavaarena_portal")
    inst.AnimState:SetBank("lavaarena_portal")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(2)

    inst.Transform:SetEightFaced()

    --Dedicated server does not need the shadow object
    if not TheNet:IsDedicated() then
        CreateDropShadow(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_portal").master_postinit(inst)

    return inst
end

local function keyhole_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("lavaarena_keyhole")
    inst.AnimState:SetBank("lavaarena_keyhole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("key")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)

    inst.Transform:SetEightFaced()
    inst.Transform:SetScale(1.1, 1.1, 1.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst.persists = false

    return inst
end

local function activefx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("lavaarena_portal_fx")
    inst.AnimState:SetBank("lavaportal_fx")
    inst.AnimState:PlayAnimation("portal_pre")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:OverrideMultColour(1, 1, 1, .6)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("portal_loop")

    inst.persists = false

    return inst
end

return Prefab("lavaarena_portal", fn, assets, prefabs),
    Prefab("lavaarena_keyhole", keyhole_fn, keyhole_assets),
    Prefab("lavaarena_portal_activefx", activefx_fn, fx_assets)
