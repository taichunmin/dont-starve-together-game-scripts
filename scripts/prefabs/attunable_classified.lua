local function OnRemoveEntity(inst)
    if inst._parent ~= nil and inst._parent.components.attuner ~= nil then
        inst._parent.components.attuner:UnregisterAttunedSource(inst)
    end
end

local function RegisterAttunableToPlayer(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for attunable")
    elseif inst._parent.components.attuner ~= nil then
        inst._parent.components.attuner:RegisterAttunedSource(inst)
        inst.OnRemoveEntity = OnRemoveEntity
    end
end

local function AttachToPlayer(inst, player, source)
    inst.Network:SetClassifiedTarget(player)
    inst.entity:SetParent(player.entity)
    inst.source_guid:set(source.GUID)
    RegisterAttunableToPlayer(inst)
end

local function IsAttunableType(inst, tag)
    return inst:HasTag(tag)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.source_guid = net_uint(inst.GUID, "attunable.source_guid")

    inst.entity:SetPristine()

    inst._parent = nil

    inst.IsAttunableType = IsAttunableType

    if not TheWorld.ismastersim then
        --Delay registration until after initial values are deserialized
        inst:DoTaskInTime(0, RegisterAttunableToPlayer)
        return inst
    end

    inst.persists = false

    inst.AttachToPlayer = AttachToPlayer

    return inst
end

return Prefab("attunable_classified", fn)
