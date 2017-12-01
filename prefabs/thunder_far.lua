local function PlayThunderSound()
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:SetParent(TheFocalPoint.entity)

    inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_far")

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame in case we are about to be removed
        inst:DoTaskInTime(0, PlayThunderSound)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(2, inst.Remove)

    return inst
end

return Prefab("thunder_far", fn)
