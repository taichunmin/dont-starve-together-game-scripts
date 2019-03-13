local assets =
{
    Asset("ANIM", "anim/quagmire_oven.zip"),
    Asset("ANIM", "anim/quagmire_oven_fire.zip"),
}

local assets_parts =
{
    Asset("ANIM", "anim/quagmire_oven.zip"),
}

local prefabs =
{
    "quagmire_oven_item",
    "quagmire_oven_back",
}

local prefabs_item =
{
    "quagmire_oven",
}

local function AddHighlightChildren(inst, target)
    if target.prefab == "firepit" then
        if target.highlightchildren == nil then
            target.highlightchildren = { inst }
        else
            table.insert(target.highlightchildren, inst)
        end
    end
end

local function OnBakeSteam(inst)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()
    fx.entity:AddSoundEmitter()

    fx.AnimState:SetBank("quagmire_oven")
    fx.AnimState:SetBuild("quagmire_oven")
    fx.AnimState:PlayAnimation("steam")
    fx.AnimState:SetFinalOffset(3)

    fx:ListenForEvent("animover", fx.Remove)

    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", nil, .6)
    fx.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
end

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        AddHighlightChildren(inst, parent)
    end
end

local function OnEntityReplicated_Back(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        local parent2 = parent.entity:GetParent()
        if parent2 ~= nil then
            parent.ovenback = inst
            AddHighlightChildren(inst, parent2)
        end
    end
end

local function OnRemoveEntity(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.highlightchildren ~= nil then
        table.removearrayvalue(parent.highlightchildren, inst)
        if inst.ovenback ~= nil then
            table.removearrayvalue(parent.highlightchildren, inst.ovenback)
        end
        if parent.prefab == "firepit" and #parent.highlightchildren <= 0 then
            parent.highlightchildren = nil
        end
    end
end

local function OnChimneyFireDirty(inst)
    if inst._chimneyfire:value() then
        inst.chimneyfirefx:Show()
    else
        inst.chimneyfirefx:Hide()
    end
end

local function CreateChimneyFire()
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.AnimState:SetBank("quagmire_oven")
    fx.AnimState:SetBuild("quagmire_oven")
    fx.AnimState:PlayAnimation("chimney_fire", true)
    fx.AnimState:SetFinalOffset(1)

    fx:Hide()

    return fx
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_oven")
    inst.AnimState:SetBuild("quagmire_oven")
    inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:Hide("goop")
    inst.AnimState:Hide("goop_small")
    inst.AnimState:Hide("oven_back")
    inst.AnimState:SetFinalOffset(2)

    inst:AddTag("FX")

    inst._steam = net_event(inst.GUID, "quagmire_oven._steam")
    inst._chimneyfire = net_bool(inst.GUID, "quagmire_oven._chimneyfire", "chimneyfiredirty")

    inst.entity:SetPristine()

    inst.chimneyfirefx = CreateChimneyFire()
    inst.chimneyfirefx.entity:SetParent(inst.entity)

    inst.OnRemoveEntity = OnRemoveEntity

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
        inst:ListenForEvent("quagmire_oven._steam", OnBakeSteam)
        inst:ListenForEvent("chimneyfiredirty", OnChimneyFireDirty)

        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_oven").master_postinit(inst, AddHighlightChildren, OnBakeSteam, OnChimneyFireDirty)

    return inst
end

local function backfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_oven")
    inst.AnimState:SetBuild("quagmire_oven")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("steam")
    inst.AnimState:Hide("smoke")
    inst.AnimState:Hide("oven")
    --inst.AnimState:Hide("goop")
    inst.AnimState:Hide("goop_small")
    inst.AnimState:Hide("casserole")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated_Back

        return inst
    end

    inst.persists = false

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_oven")
    inst.AnimState:SetBuild("quagmire_oven")
    inst.AnimState:PlayAnimation("item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_oven").master_postinit_item(inst)

    return inst
end

return Prefab("quagmire_oven", fn, assets, prefabs),
    Prefab("quagmire_oven_back", backfn, assets_parts),
    Prefab("quagmire_oven_item", itemfn, assets_parts, prefabs_item)
