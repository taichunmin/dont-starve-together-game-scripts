local assets =
{
    Asset("ANIM", "anim/wx_fx.zip"),
}

local function onupdate(inst, dt)
    if inst._has_soundemitter then
        inst.SoundEmitter:PlaySound("WX_rework/shock/big")
        inst._has_soundemitter = nil
    end

    inst.Light:SetIntensity(inst._fx_intensity)
    inst._fx_intensity = inst._fx_intensity - (2*dt)
    if inst._fx_intensity <= 0 then
        if inst.killfx then
            inst:Remove()
        else
            inst._update_task:Cancel()
            inst._update_task = nil
        end
    end
end

local function OnAnimOver(inst)
    if inst._update_task == nil then
        inst:Remove()
    else
        inst:RemoveEventCallback("animover", OnAnimOver)
        inst.killfx = true
    end
end

local FX_UPDATE_RATE = 1/20
local function StartFX(proxy, anim, build)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    if not TheNet:IsDedicated() then
        inst.entity:AddSoundEmitter()
    end
    inst.entity:AddLight()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end
    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("wx_fx")
    inst.AnimState:SetBuild("wx_fx")
    inst.AnimState:PlayAnimation("big_shock")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Light:Enable(true)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst._fx_intensity = 0.90
    inst._has_soundemitter = inst.SoundEmitter ~= nil

    inst._update_task = inst:DoPeriodicTask(FX_UPDATE_RATE, onupdate, nil, FX_UPDATE_RATE)

    inst:ListenForEvent("animover", OnAnimOver)
end

--------------------------------------------------------------------------------------------

local function OnRemoveFlash(inst)
    if inst._target.components.colouradder == nil and inst._target:IsValid() then
        if inst._target.components.freezable ~= nil then
            inst._target.components.freezable:UpdateTint()
        else
            inst._target.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

local function OnUpdateFlash(inst)
    if not inst._target:IsValid() or inst.AnimState == nil then
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    elseif inst._flashtime > 0.10 then
        inst._flashtime = inst._flashtime - 0.08
        inst._blinkcycle = (inst._blinkcycle < 3 and inst._blinkcycle + 1) or 0

        local intensity_by_blinkcycle = (inst._blinkcycle < 2 and inst._intensity)
                                        or inst._intensity * 0.25

        local new_colour = inst._flashtime * intensity_by_blinkcycle
        if inst._target.components.colouradder ~= nil then
            inst._target.components.colouradder:PushColour(inst, new_colour, new_colour, new_colour, 0)
        else
            inst._target.AnimState:SetAddColour(new_colour, new_colour, new_colour, 0)
        end
    else
        if inst._target.components.colouradder ~= nil then
            inst._target.components.colouradder:PopColour(inst)
        elseif inst._target.components.freezable ~= nil then
            inst._target.components.freezable:UpdateTint()
        else
            inst._target.AnimState:SetAddColour(0, 0, 0, 0)
        end
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    end
end

local function AlignToTarget(inst, target)
    local x, y, z = target.Transform:GetWorldPosition()
    inst.Transform:SetPosition(x, 0, z)

    if inst.components.updatelooper == nil then
        inst._target = target
        inst._flashtime = 1
        inst._blinkcycle = 0
        inst._intensity = 0.2

        inst.OnRemoveEntity = OnRemoveFlash

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateFlash)
        OnUpdateFlash(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, StartFX)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    inst.AlignToTarget = AlignToTarget

    return inst
end

return Prefab("wx78_big_spark", fn, assets)
