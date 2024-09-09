local assets =
{
    Asset("ANIM", "anim/atrium_key.zip"),
}

local assets_icon =
{
    Asset("MINIMAP_IMAGE", "atrium_key"),
}

local prefabs =
{
    "atrium_key_icon",
}

local prefabs_icon =
{
    "globalmapicon",
}

local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onputininventory", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("ondropped", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("onremove", inst._oncontainerremoved, container)
        inst._container = container
    end
end

local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onputininventory", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("ondropped", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("onremove", inst._oncontainerremoved, inst._container)
        inst._container = nil
    end
end

local function topocket(inst, owner)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
    owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner
    if inst._owner ~= owner then
        inst._owner = owner
        inst.icon.entity:SetParent(owner.entity)
        inst.icon.MiniMapEntity:SetRestriction("nightmaretracker")
        inst.icon.components.maprevealable:Stop()
    end
end

local function toground(inst)
    unstore(inst)
    inst._owner = nil
    inst.icon.entity:SetParent(inst.entity)
    inst.icon.MiniMapEntity:SetRestriction("")
    inst.icon.components.maprevealable:Start()
end

local function OnRemoveEntity(inst)
    inst.icon:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("atrium_key")
    inst.AnimState:SetBuild("atrium_key")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")
    inst:AddTag("nonpotatable")

	MakeInventoryFloatable(inst, "med", .15, 0.7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    MakeHauntableLaunch(inst)

    inst._owner = nil
    inst._container = nil

    inst._oncontainerownerchanged = function(container)
        topocket(inst, container)
    end

    inst._oncontainerremoved = function()
        unstore(inst)
    end

    inst.icon = SpawnPrefab("atrium_key_icon")
    inst.icon.entity:SetParent(inst.entity)
    inst.icon:ListenForEvent("onputininventory", topocket, inst)
    inst.icon:ListenForEvent("ondropped", toground, inst)

    inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

local function iconfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("atrium_key.png")
    inst.MiniMapEntity:SetPriority(15)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("maprevealable")
    inst.components.maprevealable:AddRevealSource(inst, "nightmaretracker")
    inst.components.maprevealable:SetIconPriority(15)

    inst.persists = false

    return inst
end

return Prefab("atrium_key", fn, assets, prefabs),
    Prefab("atrium_key_icon", iconfn, assets_icon, prefabs_icon)
