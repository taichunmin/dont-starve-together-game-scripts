local function grottopool_sfx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst:AddTag("CLASSIFIED")
    --[[Non-networked entity]]

    inst:AddTag("FX")

    --inst.entity:SetCanSleep ??

    inst:AddComponent("fader")

    inst.persists = false

    return inst
end

return Prefab("grottopool_sfx", grottopool_sfx)
