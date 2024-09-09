local function CreateLight()
    local inst = CreateEntity()

    inst:AddTag("FX")
	--inst:AddTag("playerlight") --see AttachLightTo instead!
    --[[Non-networked entity]]
	--V2C: should be sleepable on host, and should follow parent's sleep anyway
	--inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddLight()

    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
    inst.Light:SetFalloff(TUNING.TORCH_FALLOFF[1])
    inst.Light:SetRadius(TUNING.TORCH_RADIUS[1])

    return inst
end

local function AttachLightTo(inst, target)
    inst._light.entity:SetParent(target.entity)
	if target:HasTag("player") then
		inst._light:AddTag("playerlight")
	else
		inst._light:RemoveTag("playerlight")
	end
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

local function OnLightRangeDirty(inst)
    inst._light.Light:SetRadius(TUNING.TORCH_RADIUS[inst._lightrange:value()])
    inst._light.Light:SetFalloff(TUNING.TORCH_FALLOFF[inst._lightrange:value()])
end

local function SetLightRange(inst,value)
    if value ~= inst._lightrange:value() then
        inst._lightrange:set(value)
        OnLightRangeDirty(inst)
    end
end

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
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
        inst.SoundEmitter:SetParameter("torch", "intensity", 1)

        inst._light = CreateLight()
        inst._light.entity:SetParent(inst.entity)

        inst.OnRemoveEntity = OnRemoveEntity

        inst._lightrange = net_tinybyte(inst.GUID, "torch._lightrange", "lightrangedirty")
        if not TheWorld.ismastersim then
            inst:ListenForEvent("lightrangedirty", OnLightRangeDirty)
        else
            inst.SetLightRange = SetLightRange
        end
        inst._lightrange:set(1)

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

return MakeTorchFire
