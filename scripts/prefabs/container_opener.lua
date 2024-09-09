local function OnRemoveEntity(inst)
    if inst._parent ~= nil then
        inst._parent.container_opener = nil
    end
end

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
    elseif inst._parent.replica.container ~= nil then
        inst._parent.replica.container:AttachOpener(inst)
    elseif inst._parent.components.container_proxy ~= nil then
        inst._parent.components.container_proxy:AttachOpener(inst)
    else
        inst._parent.container_opener = inst
        inst.OnRemoveEntity = OnRemoveEntity
    end
end

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform() --So we can follow parent's sleep state
    end
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("container_opener", fn)