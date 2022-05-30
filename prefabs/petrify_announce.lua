local function PlayPetrifySound(proxy)
    local inst = CreateEntity()

    --[[Non-networked entity]]

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    if TheFocalPoint ~= nil then
        local x, y, z = TheFocalPoint.Transform:GetWorldPosition()
        local x1, y1, z1 = proxy.Transform:GetWorldPosition()
        local dx, dz = x1 - x, z1 - z
        local dist = math.sqrt(dx * dx + dz * dz)
        local maxdist = 20
        if dist > maxdist then
            --too far to be heard, normalize to max distance
            dx = dx * maxdist / dist
            dz = dz * maxdist / dist
            x1 = x + dx
            z1 = z + dz
        end
        inst.Transform:SetPosition(x1, 0, z1)
    else
        inst.Transform:SetFromProxy(proxy.GUID)
    end

    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/post_distant")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame so that we are positioned properly before starting the effect
        --or in case we are about to be removed
        inst:DoTaskInTime(0, PlayPetrifySound)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("petrify_announce", fn)
