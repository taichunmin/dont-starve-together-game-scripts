local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(252 / 255, 251 / 255, 237 / 255)
    inst.Light:SetFalloff(.6)
    inst.Light:SetRadius(4)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("nightstickfire", fn)
