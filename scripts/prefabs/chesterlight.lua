local assets =
{
    Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local MAX_LIGHT_FRAME = 6
local MAX_LIGHT_RADIUS = 5
local FRAME_RADIUS = MAX_LIGHT_RADIUS / MAX_LIGHT_FRAME

local function OnUpdateLight(inst, dframes)
    local done
    if inst._islighton:value() then
        local frame = inst._lightframe:value() + dframes
        done = frame >= MAX_LIGHT_FRAME
        inst._lightframe:set_local(done and MAX_LIGHT_FRAME or frame)
    else
        local frame = inst._lightframe:value() - dframes
        done = frame <= 0
        inst._lightframe:set_local(done and 0 or frame)
    end

    inst.Light:SetRadius(inst._lightframe:value() * FRAME_RADIUS)

    if done then
        inst._lighttask:Cancel()
        inst._lighttask = nil
    end
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function TurnOn(inst)
    inst.AnimState:PlayAnimation("on")
    inst.AnimState:PushAnimation("idle_loop", false)
    inst._islighton:set(true)
    inst._lightframe:set(inst._lightframe:value())
    OnLightDirty(inst)
end

local function TurnOff(inst)
    inst.AnimState:PlayAnimation("off")
    inst:ListenForEvent("animover", inst.Remove)
    inst._islighton:set(false)
    inst._lightframe:set(inst._lightframe:value())
    OnLightDirty(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("cavelight")
    inst.AnimState:SetBuild("cave_exit_lightsource")

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.9)
    inst.Light:SetFalloff(.3)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
    inst.Light:EnableClientModulation(true)

    inst._lightframe = net_tinybyte(inst.GUID, "chesterlight._lightframe", "lightdirty")
    inst._islighton = net_bool(inst.GUID, "chesterlight._islighton", "lightdirty")
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.TurnOn = TurnOn
    inst.TurnOff = TurnOff

    return inst
end

return Prefab("chesterlight", fn, assets)
