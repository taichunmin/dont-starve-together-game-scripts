local function MakeTorchFire(name, customassets, customprefabs, common_postinit, master_postinit)
    local assets =
    {
        Asset("SCRIPT", "scripts/prefabs/torchfire_common.lua"),
    }

    if customassets ~= nil then
        for i, v in ipairs(customassets) do
            table.insert(assets, v)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddLight()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("playerlight")

        inst.Light:SetIntensity(.75)
        inst.Light:SetColour(197 / 255, 197 / 255, 50 / 255)
        inst.Light:SetFalloff(.5)
        inst.Light:SetRadius(2)

        inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
        inst.SoundEmitter:SetParameter("torch", "intensity", 1)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, customprefabs)
end

return MakeTorchFire
