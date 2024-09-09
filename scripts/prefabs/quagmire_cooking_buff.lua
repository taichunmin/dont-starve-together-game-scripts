local assets =
{
    Asset("ANIM", "anim/quagmire_cooking_buff.zip"),
}

local function OnAnimOver(inst)
    if inst.killed then
        inst:Remove()
    else
        inst.AnimState:PlayAnimation("fx")
    end
end

local function CreateFX()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("quagmire_cooking_buff")
    inst.AnimState:SetBuild("quagmire_cooking_buff")
    inst.AnimState:PlayAnimation("fx")
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(1.8, .8)

    inst:ListenForEvent("animover", OnAnimOver)

    return inst
end

local function OnShowDirty(inst)
    if inst._show:value() then
        if inst._fx ~= nil then
            inst._fx.killed = nil
        else
            inst._fx = CreateFX()
            inst._fx.entity:SetParent(inst.entity)
            inst._fx.OnRemoveEntity = function()
                inst._fx = nil
            end
        end
    elseif inst._fx ~= nil then
        inst._fx.killed = true
    end
end

local function ShowFX(inst)
    if not inst._show:value() then
        inst._show:set(true)

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            OnShowDirty(inst)
        end
    end
end

local function HideFX(inst)
    if inst._show:value() then
        inst._show:set(false)

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            OnShowDirty(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst._show = net_bool(inst.GUID, "quagmire_cooking_buff._show", "showdirty")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("showdirty", OnShowDirty)

        return inst
    end

    inst.persists = false

    inst.ShowFX = ShowFX
    inst.HideFX = HideFX

    return inst
end

return Prefab("quagmire_cooking_buff", fn, assets)
