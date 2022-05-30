local assets =
{
    Asset("ANIM", "anim/quagmire_portal.zip"),
    Asset("ANIM", "anim/quagmire_portal_base.zip"),
}

local prefabs =
{
    "quagmire_portal_activefx",
    "quagmire_portal_bubblefx",
    "quagmire_portal_player_fx",
    "quagmire_portal_playerdrip_fx",
    "quagmire_portal_player_splash_fx",
}

local fx_assets =
{
    Asset("ANIM", "anim/quagmire_portal_fx.zip"),
}

local fx_bubble_assets =
{
    Asset("ANIM", "anim/quagmire_portalbubbles_fx.zip"),
}

local function CreateDropShadow(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --[[Non-networked entity]]

    inst.AnimState:SetBuild("quagmire_portal_base")
    inst.AnimState:SetBank("quagmire_portal_base")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    --inst.AnimState:OverrideSymbol("quagmire_portal01", "quagmire_portal", "shadow")

    inst.Transform:SetEightFaced()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    inst.persists = false
    inst.entity:SetParent(parent.entity)

    return inst
end

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 30, 30, 1)
    else
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("quagmire_portal")
    inst.AnimState:SetBank("quagmire_portal")
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

    inst:AddTag("groundhole")
    inst:AddTag("blocker")

    inst._camerafocus = net_bool(inst.GUID, "quagmire_portal._camerafocus", "camerafocusdirty")
    inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_portal").master_postinit(inst)

    return inst
end

local function activefx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("quagmire_portal_fx")
    inst.AnimState:SetBank("quagmire_portal_fx")
    inst.AnimState:PlayAnimation("portal_pre")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:OverrideMultColour(1, 1, 1, 1)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("scarytoprey")
    inst:AddTag("birdblocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("portal_loop")

    inst.persists = false

    return inst
end

local function bubblefx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("quagmire_portalbubbles_fx")
    inst.AnimState:SetBank("quagmire_portalbubbles_fx")
    --inst.AnimState:PlayAnimation("idle")
    inst:Hide()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("quagmire_portal", fn, assets, prefabs),
    Prefab("quagmire_portal_activefx", activefx_fn, fx_assets),
    Prefab("quagmire_portal_bubblefx", bubblefx_fn, fx_bubble_assets)
