local assets =
{
    Asset("ANIM", "anim/reticuleline.zip"),
}

local PAD_DURATION = .1
local SCALE = 1.5
local FLASH_TIME = .3

local function UpdatePing(inst, s0, s1, t0, duration, multcolour, addcolour)
    if next(multcolour) == nil then
        multcolour[1], multcolour[2], multcolour[3], multcolour[4] = inst.AnimState:GetMultColour()
    end
    if next(addcolour) == nil then
        addcolour[1], addcolour[2], addcolour[3], addcolour[4] = inst.AnimState:GetAddColour()
    end
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - PAD_DURATION) / duration
    k = 1 - k * k
    local c = Lerp(1, 0, k)
    inst.AnimState:SetScale(SCALE * Lerp(s0[1], s1[1], k), SCALE * Lerp(s0[2], s1[2], k))
    inst.AnimState:SetMultColour(multcolour[1], multcolour[2], multcolour[3], c * multcolour[4])

    k = math.min(FLASH_TIME, t) / FLASH_TIME
    c = math.max(0, 1 - k * k)
    inst.AnimState:SetAddColour(c * addcolour[1], c * addcolour[2], c * addcolour[3], c * addcolour[4])
end

local function pingfn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleline")
    inst.AnimState:SetBuild("reticuleline")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    local duration = .4
    inst:DoPeriodicTask(0, UpdatePing, nil, { 1, 1 }, { 1.04, 1.25 }, GetTime(), duration, {}, {})
    inst:DoTaskInTime(duration + PAD_DURATION, inst.Remove)

    return inst
end

local function MakeReticule(name)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetScale(SCALE, SCALE)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeReticule("reticuleline"),
    MakeReticule("reticuleline2"),
    Prefab("reticulelineping", pingfn, assets)
