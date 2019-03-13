local assets =
{
    Asset("ANIM", "anim/quagmire_pot_hanger.zip"),
    Asset("ANIM", "anim/quagmire_pot_fire.zip"),
}

local prefabs =
{
    "quagmire_pot_hanger_item",
}

local prefabs_item =
{
    "quagmire_pot_hanger",
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

local function OnPotSteam(inst)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()
    fx.entity:AddSoundEmitter()

    fx.AnimState:SetBank("quagmire_pot_hanger")
    fx.AnimState:SetBuild("quagmire_pot_hanger")
    fx.AnimState:PlayAnimation("steam")
    fx.AnimState:SetFinalOffset(1)

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

local function OnRemoveEntity(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.highlightchildren ~= nil then
        table.removearrayvalue(parent.highlightchildren, inst)
        if parent.prefab == "firepit" and #parent.highlightchildren <= 0 then
            parent.highlightchildren = nil
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quagmire_pot_hanger")
    inst.AnimState:SetBuild("quagmire_pot_hanger")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("mouseover")
    inst.AnimState:Hide("goop")
    inst.AnimState:Hide("goop_small")
    inst.AnimState:Hide("goop_syrup")

    inst:AddTag("FX")

    inst._steam = net_event(inst.GUID, "quagmire_pot_hanger._steam")

    inst.entity:SetPristine()

    inst.OnRemoveEntity = OnRemoveEntity

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
        inst:ListenForEvent("quagmire_pot_hanger._steam", OnPotSteam)

        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_pot_hanger").master_postinit(inst, AddHighlightChildren, OnPotSteam)

    return inst
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_pot_hanger")
    inst.AnimState:SetBuild("quagmire_pot_hanger")
    inst.AnimState:PlayAnimation("item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_pot_hanger").master_postinit_item(inst)

    return inst
end

return Prefab("quagmire_pot_hanger", fn, assets, prefabs),
    Prefab("quagmire_pot_hanger_item", itemfn, assets, prefabs_item)
