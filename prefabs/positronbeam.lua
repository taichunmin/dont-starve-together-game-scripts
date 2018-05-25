local assets =
{
    Asset("ANIM", "anim/moonbase_fx.zip"),
}

local function createbeam(layer, offset)
    local function KillFX(inst)
        if not inst._iskilled then --i skilled?
            inst._iskilled = true
            if layer == "front" then
                inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_stop_fail")
            end
            inst.AnimState:PlayAnimation("lunar_"..layer.."_pst")
            inst:ListenForEvent("animover", inst.Remove)
            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        if layer == "front" then
            inst.entity:AddSoundEmitter()
        end
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lunar_fx")
        inst.AnimState:SetBuild("moonbase_fx")
        inst.AnimState:PlayAnimation("lunar_"..layer.."_pre")
        inst.AnimState:PushAnimation("lunar_"..layer.."_loop", true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(offset)

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst.KillFX = KillFX

        return inst
    end

    return Prefab("positronbeam_"..layer, fn, assets)
end

local function SetLevel(inst, level)
    if inst._finished then
        --wot
    elseif level == nil or level < 2 then
        inst:Hide()
        inst.SoundEmitter:SetParameter("beam", "intensity", 0)
    else
        local anim = "lunar_"..tostring(math.min(level, 3)).."_loop"
        if not inst.AnimState:IsCurrentAnimation(anim) then
            inst.AnimState:PlayAnimation(anim, true)
        end
        inst:Show()
        inst.SoundEmitter:SetParameter("beam", "intensity", level < 3 and .6 or .9)
        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_level_up")
    end
end

local function FinishFX(inst)
    if not (inst._finished or inst.AnimState:IsCurrentAnimation("lunar_full_pst")) then
        inst.SoundEmitter:KillSound("beam")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_stop")
        inst.AnimState:PlayAnimation("lunar_full_pst")
        inst._finished = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)
        inst:Show()
    end
end

local function InitFX(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_level_up")
end

local function createpulse(offset)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("lunar_fx")
        inst.AnimState:SetBuild("moonbase_fx")
        inst.AnimState:PlayAnimation("lunar_2_loop", true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(offset)

        inst:AddTag("FX")

        inst:Hide()

        inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam", "beam")
        inst.SoundEmitter:SetParameter("beam", "intensity", 0)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:DoTaskInTime(0, InitFX)

        inst.persists = false

        inst._finished = nil
        inst.SetLevel = SetLevel
        inst.FinishFX = FinishFX
        inst.KillFX = inst.Remove

        return inst
    end

    return Prefab("positronpulse", fn, assets)
end

return createbeam("back", 0), createbeam("front", 2), createpulse(3)
