local function AddHighlightChildren(inst, target)
    if target.prefab == "firepit" then
        if target.highlightchildren == nil then
            target.highlightchildren = { inst }
        else
            table.insert(target.highlightchildren, inst)
        end
    end
end

local function KillFX(fx)
    if not fx.killed then
        fx.killed = true

		local remaining = fx.AnimState:GetCurrentAnimationLength() - fx.AnimState:GetCurrentAnimationTime()
        if remaining > 0 then
            local parent = fx.entity:GetParent()
            if parent ~= nil then
                fx.entity:SetParent(nil)
                fx.Transform:SetPosition(parent.Transform:GetWorldPosition())
            end
            fx:DoTaskInTime(remaining, fx.Remove)
        else
            fx:Remove()
        end
    end
end

local function CreateBurntSmoke(build, sound)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()
    if sound then
        fx.entity:AddSoundEmitter()
    end

    fx.AnimState:SetBank(build)
    fx.AnimState:SetBuild(build)
    fx.AnimState:PlayAnimation("cooking_burnt_loop", true)
    fx.AnimState:Hide("grill")

    fx.KillFX = KillFX

    return fx
end

local function OnBurntDirty(inst)
    if inst._burnt:value() > 0 then
        if inst._smokefrontfx == nil then
            inst._smokefrontfx = CreateBurntSmoke(inst.prefab, true)
            inst._smokefrontfx.AnimState:Hide("smoke_back")
            inst._smokefrontfx.AnimState:SetFinalOffset(3)
            inst._smokefrontfx.entity:SetParent(inst.entity)
        end
        if inst._smokebackfx == nil then
            inst._smokebackfx = CreateBurntSmoke(inst.prefab, false)
            inst._smokebackfx.AnimState:Hide("smoke_front")
            inst._smokebackfx.AnimState:SetFinalOffset(1)
            inst._smokebackfx.entity:SetParent(inst.entity)
        end
        if inst._burnt:value() == 1 then
            inst._smokefrontfx.AnimState:SetAddColour(.15, .15, 0, 0)
            inst._smokebackfx.AnimState:SetAddColour(.15, .15, 0, 0)
            inst._smokefrontfx.SoundEmitter:KillSound("smoke")
        else
            inst._smokefrontfx.AnimState:SetAddColour(0, 0, 0, 0)
            inst._smokebackfx.AnimState:SetAddColour(0, 0, 0, 0)
            if not inst._smokefrontfx.SoundEmitter:PlayingSound("smoke") then
                inst._smokefrontfx.SoundEmitter:PlaySound("dontstarve/quagmire/common/cooking/burnt_LP", "smoke", .25)
            end
        end
    else
        if inst._smokefrontfx ~= nil then
            inst._smokefrontfx:KillFX()
            inst._smokefrontfx = nil
        end
        if inst._smokebackfx ~= nil then
            inst._smokebackfx:KillFX()
            inst._smokebackfx = nil
        end
    end
end

local function OnGrillSmoke(inst)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()
    fx.entity:AddSoundEmitter()

    fx.AnimState:SetBank(inst.prefab)
    fx.AnimState:SetBuild(inst.prefab)
    fx.AnimState:PlayAnimation("smoke")
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
        if parent.replica.container ~= nil then
            parent.replica.container:WidgetSetup(inst.prefab)
        end
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

local function OnEmbersDirty(inst)
    if inst._embers:value() <= 0 then
        inst.embersfx:Hide()
    else
        inst.embersfx:Show()
        if inst._embers:value() <= 1 then
            inst.embersfx.AnimState:Show("ember1")
            inst.embersfx.AnimState:Hide("ember2")
            inst.embersfx.AnimState:Hide("ember3")
        elseif inst._embers:value() <= 2 then
            inst.embersfx.AnimState:Hide("ember1")
            inst.embersfx.AnimState:Show("ember2")
            inst.embersfx.AnimState:Hide("ember3")
        else
            inst.embersfx.AnimState:Hide("ember1")
            inst.embersfx.AnimState:Show("ember2")
            inst.embersfx.AnimState:Show("ember3")
        end
    end
end

local function CreateEmbers(build)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.AnimState:SetBank(build)
    fx.AnimState:SetBuild(build)
    fx.AnimState:PlayAnimation("embers", true)
    fx.AnimState:SetFinalOffset(3)

    fx:Hide()

    return fx
end

local ret = {}

local function MakeGrill(name)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/quagmire_pot_fire.zip"),
    }

    local prefabs =
    {
        name.."_item",
        "quagmire_food_plate_burnt",
    }

    local prefabs_item =
    {
        name,
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetFinalOffset(2)

        inst:AddTag("FX")

        inst._smoke = net_event(inst.GUID, name.."._smoke")
        inst._burnt = net_tinybyte(inst.GUID, name.."._burnt", "burntdirty")
        inst._embers = net_tinybyte(inst.GUID, name.."._embers", "embersdirty")

        inst.entity:SetPristine()

        inst.embersfx = CreateEmbers(name)
        inst.embersfx.entity:SetParent(inst.entity)

        inst.OnRemoveEntity = OnRemoveEntity

        if not TheWorld.ismastersim then
            inst.OnEntityReplicated = OnEntityReplicated
            inst:ListenForEvent(name.."._smoke", OnGrillSmoke)
            inst:ListenForEvent("burntdirty", OnBurntDirty)
            inst:ListenForEvent("embersdirty", OnEmbersDirty)

            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_grill").master_postinit(inst, name, AddHighlightChildren, OnBurntDirty, OnGrillSmoke, OnEmbersDirty)

        return inst
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("item")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_grill").master_postinit_item(inst, name)

        return inst
    end

    table.insert(ret, Prefab(name, fn, assets, prefabs))
    table.insert(ret, Prefab(name.."_item", itemfn, assets, prefabs_item))
end

MakeGrill("quagmire_grill", 4)
MakeGrill("quagmire_grill_small", 3)
return unpack(ret)
