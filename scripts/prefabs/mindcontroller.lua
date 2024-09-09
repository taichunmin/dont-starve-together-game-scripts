--see mindcontrolover.lua for constants
local MAX_LEVEL = 135
local CONTROL_LEVEL = 110
local EXTEND_TICKS = MAX_LEVEL - CONTROL_LEVEL

local function OnAttached(inst, target)--, followsymbol, followoffset)
    inst.entity:SetParent(target.entity)
    inst.Network:SetClassifiedTarget(target)
end

local function ExtendDebuff(inst)
    inst.countdown = 3 + (inst._level:value() < CONTROL_LEVEL and EXTEND_TICKS or math.floor(TUNING.STALKER_MINDCONTROL_DURATION / FRAMES + .5))
end

local function OnUpdate(inst, ismastersim)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        local old = inst._level:value()
        if old < MAX_LEVEL then
            inst._level:set_local(old + 1)
        end
        parent:PushEvent("mindcontrollevel", inst._level:value() / MAX_LEVEL)

        if ismastersim and inst._level:value() >= CONTROL_LEVEL then
            if old < CONTROL_LEVEL then
                ExtendDebuff(inst)
            end
            parent:PushEvent("mindcontrolled", { duration = TUNING.STALKER_MINDCONTROL_DURATION })
        end
    end

    if ismastersim then
        if inst.countdown > 1 then
            inst.countdown = inst.countdown - 1
        else
            inst.components.debuff:Stop()
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")

    inst._level = net_byte(inst.GUID, "mindcontroller._level")

    inst:DoPeriodicTask(0, OnUpdate, nil, TheWorld.ismastersim)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(ExtendDebuff)

    ExtendDebuff(inst)

    return inst
end

return Prefab("mindcontroller", fn)
