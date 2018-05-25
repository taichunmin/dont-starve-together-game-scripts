
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("deerspawningground")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    TheWorld:PushEvent("ms_registerdeerspawningground", inst)

    return inst
end

return Prefab("deerspawningground", fn)
