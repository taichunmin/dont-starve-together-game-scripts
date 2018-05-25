local function lavaarena_center()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")

    inst:Hide()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    TheWorld:PushEvent("ms_register_lavaarenacenter", inst)

    return inst
end

return Prefab("lavaarena_center", lavaarena_center)
