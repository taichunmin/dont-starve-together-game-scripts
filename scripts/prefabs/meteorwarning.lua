local assets =
{
    Asset("ANIM", "anim/meteor_shadow.zip"),
}

local function AlphaToFade(alpha)
    return math.floor(alpha * 63 + .5)
end

local function FadeToAlpha(fade)
    return fade / 63
end

local function CalculatePeriod(time, starttint, endtint)
    return time / math.max(1, AlphaToFade(endtint) - AlphaToFade(starttint))
end

local DEFAULT_START = .33
local DEFAULT_END = 1
local DEFAULT_DURATION = 1
local DEFAULT_PERIOD = CalculatePeriod(DEFAULT_DURATION, DEFAULT_START, DEFAULT_END)

local function PushAlpha(inst)
    local alpha = FadeToAlpha(inst._fade:value())
    inst.AnimState:OverrideMultColour(1, 1, 1, alpha)
end

local function UpdateFade(inst)
    if inst._fade:value() < inst._fadeend:value() then
        inst._fade:set_local(inst._fade:value() + 1)
        PushAlpha(inst)
    end
    if inst._fade:value() >= inst._fadeend:value() and inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function OnFadeDirty(inst)
    PushAlpha(inst)
    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoPeriodicTask(inst._period:value(), UpdateFade)
end

local function startshadow(inst, time, starttint, endtint)
    if time ~= DEFAULT_DURATION or starttint ~= DEFAULT_START or endtint ~= DEFAULT_END then
        inst._fade:set(AlphaToFade(starttint))
        inst._fadeend:set(AlphaToFade(endtint))
        inst._period:set(CalculatePeriod(time, starttint, endtint))
        OnFadeDirty(inst)
    end
end

local function PlayMeteorSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/meteor_spawn")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("warning_shadow")
    inst.AnimState:SetBuild("meteor_shadow")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst._fade = net_smallbyte(inst.GUID, "meteorwarning._fade", "fadedirty")
    inst._fadeend = net_smallbyte(inst.GUID, "meteorwarning._fadeend", "fadedirty")
    inst._period = net_float(inst.GUID, "meteorwarning._period", "fadedirty")
    inst._fade:set(AlphaToFade(DEFAULT_START))
    inst._fadeend:set(AlphaToFade(DEFAULT_END))
    inst._period:set(DEFAULT_PERIOD)
    inst._task = nil
    OnFadeDirty(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

    inst:DoTaskInTime(0, PlayMeteorSound)

    inst.startfn = startshadow

    inst.persists = false

    return inst
end

return Prefab("meteorwarning", fn, assets)
