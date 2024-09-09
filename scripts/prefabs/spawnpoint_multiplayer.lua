local function common_fn(ismaster)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    --NOTE: this is not mastersim, it means the master
    --      spawnpoint to be used in fixed spawn mode.
    inst.master = ismaster or nil

    TheWorld:PushEvent("ms_registerspawnpoint", inst)

    return inst
end

local function multiplayer_fn()
    return common_fn(false)
end

local function master_fn()
    return common_fn(true)
end

return Prefab("spawnpoint_multiplayer", multiplayer_fn),
    Prefab("spawnpoint_master", master_fn)