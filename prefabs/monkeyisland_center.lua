local function fn()
    -- this is just used during world gen and should not stick around.
    local inst = CreateEntity()
    inst.entity:AddTransform()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(0, inst.Remove)
    return inst
end

--------------------------------------------------------------------------------

local function on_safetyarea_loaded(inst, data, newents)
    if data ~= nil then
        inst.width = data.width or 0
        inst.height = data.height or 0
    end
end

local function safetyareafn()
    local inst = CreateEntity()
    inst.entity:AddTransform()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.width = 0
    inst.height = 0

    inst.OnLoad = on_safetyarea_loaded

    inst:DoTaskInTime(0, inst.Remove)
    return inst
end

return Prefab("monkeyisland_center", fn),
       Prefab("monkeyisland_direction", fn),
       Prefab("monkeyisland_dockgen_safeareacenter", safetyareafn)
