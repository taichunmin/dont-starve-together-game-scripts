local assets =
{
    Asset("ANIM", "anim/atrium_gate_overload_fx.zip"),
}

local function SetFX(inst, anim)
    if inst.killed then
        return
    elseif (inst.anim or "idle") ~= anim then
        if inst.anim ~= nil then
            inst.AnimState:PushAnimation(inst.anim.."_pst", false)
            inst.AnimState:PushAnimation(anim.."_pre", false)
        else
            inst.AnimState:PlayAnimation(anim.."_pre")
        end
        inst.AnimState:PushAnimation(anim.."_loop", true)

        if anim == "idle" then
            inst:RemoveTag("NOCLICK")
            inst:RemoveTag("DECOR")
            inst:AddTag("FX")
        else
            inst:RemoveTag("FX")
            inst:AddTag("DECOR")
            inst:AddTag("NOCLICK")
        end
    end
    inst.anim = anim
end

local function KillFX(inst)
    if not inst.killed then
        inst.killed = true
        inst.AnimState:PushAnimation((inst.anim or "idle").."_pst", false)
        inst:ListenForEvent("animqueueover", inst.Remove)
        inst:DoTaskInTime(4, inst.Remove)
    end
end

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "atrium_gate" then
        table.insert(parent.highlightchildren, inst)
    end
end

local function OnRemoveEntity(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.highlightchildren ~= nil then
        table.removearrayvalue(parent.highlightchildren, inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:Enable(false)
    inst.Light:SetColour(200 / 255, 140 / 255, 140 / 255)
    inst.Light:SetRadius(8.0)
    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(0.65)

    inst.AnimState:SetBank("atrium_gate_overload_fx")
    inst.AnimState:SetBuild("atrium_gate_overload_fx")
    inst.AnimState:PlayAnimation("idle_pre")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.OnRemoveEntity = OnRemoveEntity

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated

        return inst
    end

    inst.anim = nil
    inst.AnimState:PushAnimation("idle_loop", true)

    inst.SetFX = SetFX
    inst.KillFX = KillFX

    inst.persists = false

    return inst
end

return Prefab("atrium_gate_activatedfx", fn, assets)
