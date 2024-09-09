local function MakeTemporary(inst, duration)
    inst.persists = false
    if inst._blinkfocus_task ~= nil then
        inst._blinkfocus_task:Cancel()
        inst._blinkfocus_task = nil
    end
    inst._blinkfocus_task = inst:DoTaskInTime(duration, inst.Remove)
end

local function SetMaxRange(inst, range)
    inst.maxrange:set(range)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState() -- NOTES(JBK): This is here in case we want to use this focus with art later and do it only if the player has a controller plugged in!
    inst.entity:AddNetwork()

    inst.maxrange = net_float(inst.GUID, "blinkfocus_marker.maxrange")
    inst:AddTag("blinkfocus")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.MakeTemporary = MakeTemporary
    inst.SetMaxRange = SetMaxRange

    return inst
end

return Prefab("blinkfocus_marker", fn)