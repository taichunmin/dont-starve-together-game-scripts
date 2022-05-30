local function CreateLight()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("playerlight")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddLight()

    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(200 / 255, 150 / 255, 50 / 255)
    inst.Light:SetFalloff(.5)
    inst.Light:SetRadius(1)

    return inst
end

local function AttachLightTo(inst, target)
    inst._light.entity:SetParent(target.entity)
end

local function OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil then
        AttachLightTo(inst, parent)
    end
end

local function OnRemoveEntity(inst)
    inst._light:Remove()
end

local function MakeLighterFire(name, customassets, customprefabs, common_postinit, master_postinit)
    local assets =
    {
        Asset("SCRIPT", "scripts/prefabs/lighterfire_common.lua"),
    }

    if customassets ~= nil then
        for i, v in ipairs(customassets) do
            table.insert(assets, v)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.SoundEmitter:PlaySound("dontstarve/wilson/lighter_LP", "torch")
        inst.SoundEmitter:SetParameter("torch", "intensity", 1)

        inst._light = CreateLight()
        inst._light.entity:SetParent(inst.entity)

        inst.OnRemoveEntity = OnRemoveEntity

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst.OnEntityReplicated = OnEntityReplicated

            return inst
        end

        inst.persists = false
        inst.AttachLightTo = AttachLightTo

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

    return Prefab(name, fn, assets, customprefabs)
end

return MakeLighterFire
