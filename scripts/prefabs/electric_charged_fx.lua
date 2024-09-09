local assets =
{
    Asset("ANIM", "anim/elec_charged_fx.zip"),
}

local function onupdate(inst, dt)
    if inst.sound then
        inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
        inst.sound = nil
    end

    inst.Light:SetIntensity(inst.i)
    inst.i = inst.i - dt * 2
    if inst.i <= 0 then
        if inst.killfx then
            inst:Remove()
        else
            inst.task:Cancel()
            inst.task = nil
        end
    end
end

local function OnAnimOver(inst)
    if inst.task == nil then
        inst:Remove()
    else
        inst:RemoveEventCallback("animover", OnAnimOver)
        inst.killfx = true
    end
end

local function StartFX(proxy, animindex, build)
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

    inst.AnimState:SetBank("elec_charged_fx")
    inst.AnimState:SetBuild("elec_charged_fx")
    inst.AnimState:PlayAnimation("discharged")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.Light:Enable(true)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    local dt = 1 / 20
    inst.i = .9
    inst.sound = inst.SoundEmitter ~= nil
    inst.task = inst:DoPeriodicTask(dt, onupdate, nil, dt)

    inst:ListenForEvent("animover", OnAnimOver)
end

local function OnRemoveFlash(inst)
    if inst.target.components.colouradder == nil and inst.target:IsValid() then
        if inst.target.components.freezable ~= nil then
            inst.target.components.freezable:UpdateTint()
        else
            inst.target.AnimState:SetAddColour(0, 0, 0, 0)
        end
    end
end

local function OnUpdateFlash(inst)
    if not inst.target:IsValid() then
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    elseif inst.flash > .1 then
        inst.flash = inst.flash - .07
        inst.blink = inst.blink < 3 and inst.blink + 1 or 0
        local c = inst.blink < 2 and inst.flash * .25 or 0
        if inst.target.components.colouradder ~= nil then
            inst.target.components.colouradder:PushColour(inst, c, c, c, 0)
        else
            inst.target.AnimState:SetAddColour(c, c, c, 0)
        end
    else
        if inst.target.components.colouradder ~= nil then
            inst.target.components.colouradder:PopColour(inst)
        elseif inst.target.components.freezable ~= nil then
            inst.target.components.freezable:UpdateTint()
        else
            inst.target.AnimState:SetAddColour(0, 0, 0, 0)
        end
        inst.OnRemoveEntity = nil
        inst:RemoveComponent("updatelooper")
    end
end

local function SetTarget(inst, target)
    inst.entity:SetParent(target.entity)

    if inst.components.updatelooper == nil then
        inst.OnRemoveEntity = OnRemoveFlash
        inst.target = target
        inst.flash = 1
        inst.blink = 0

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

    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, StartFX)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    inst.SetTarget = SetTarget

    return inst
end

return Prefab("electricchargedfx", fn, assets)
