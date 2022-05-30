local assets =
{
    Asset("ANIM", "anim/burntground.zip"),
}

local FADE_INTERVAL = TUNING.TOTAL_DAY_TIME * 5 / 64 --64 ticks for smallbyte

local function OnFadeDirty(inst)
    local alpha = (64 - inst._fade:value()) / 65
    inst.AnimState:OverrideMultColour(alpha, alpha, alpha, alpha)
end

local function UpdateFade(inst)
    if inst._fade:value() < 63 then
        inst._fade:set_local(inst._fade:value() + 1)
        OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    else
        inst.AnimState:OverrideMultColour(0, 0, 0, 0)
    end
end

local function OnSave(inst, data)
    data.fade = inst._fade:value() > 0 and inst._fade:value() or nil
    data.rotation = inst.Transform:GetRotation()
    data.scale = { inst.Transform:GetScale() }
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.rotation ~= nil then
            inst.Transform:SetRotation(data.rotation)
        end
        if data.scale ~= nil then
            inst.Transform:SetScale(data.scale[1] or 1, data.scale[2] or 2, data.scale[3] or 3)
        end
        if data.fade ~= nil and data.fade > 0 then
            inst._fade:set(math.min(data.fade, 63))
            OnFadeDirty(inst)
        end
    end
end

local function makeburntground(name, initial_fade)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBuild("burntground")
        inst.AnimState:SetBank("burntground")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_GROUND)
        inst.AnimState:SetSortOrder(3)

        inst:AddTag("NOCLICK")
        inst:AddTag("FX")

        inst._fade = net_smallbyte(inst.GUID, "burntground._fade", "fadedirty")

        inst:SetPrefabName("burntground")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:DoPeriodicTask(FADE_INTERVAL, UpdateFade, math.random())
            inst:ListenForEvent("fadedirty", OnFadeDirty)
            inst._fade:set_local(initial_fade or 0)
            OnFadeDirty(inst)

            return inst
        end

        inst:DoPeriodicTask(FADE_INTERVAL, UpdateFade, math.max(0, FADE_INTERVAL - math.random()))
        inst._fade:set(initial_fade or 0)
        OnFadeDirty(inst)

        inst.Transform:SetRotation(math.random() * 360)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        return inst
    end

    return Prefab(name, fn, assets)
end

return makeburntground("burntground"),
    makeburntground("burntground_faded", 20)
