local assets =
{
    Asset("ANIM", "anim/redlantern.zip"),
    Asset("ANIM", "anim/redlantern_water.zip"),
    Asset("ANIM", "anim/swap_redlantern.zip"),
    Asset("INV_IMAGE", "redlantern_lit"),
}

local prefabs =
{
    "redlanternlight",
    "redlanternbody",
}

local LIGHT_RADIUS = 1.2
local LIGHT_COLOUR = Vector3(200 / 255, 100 / 255, 100 / 255)
local LIGHT_INTENSITY = .8
local LIGHT_FALLOFF = .5

local function OnUpdateFlicker(inst, starttime)
    local time = starttime ~= nil and (GetTime() - starttime) * 15 or 0
    local flicker = (math.sin(time) + math.sin(time + 2) + math.sin(time + 0.7777)) * .5 -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetRadius(LIGHT_RADIUS + .1 * flicker)
    flicker = flicker * 2 / 255
    inst.Light:SetColour(LIGHT_COLOUR.x + flicker, LIGHT_COLOUR.y + flicker, LIGHT_COLOUR.z + flicker)
end

local function onremovelight(light)
    light._lantern._light = nil
end

local function stoptrackingowner(inst)
    if inst._owner ~= nil then
        inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
        inst._owner = nil
    end
end

local function starttrackingowner(inst, owner)
    if owner ~= inst._owner then
        stoptrackingowner(inst)
        if owner ~= nil and owner.components.inventory ~= nil then
            inst._owner = owner
            inst:ListenForEvent("equip", inst._onownerequip, owner)
        end
    end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:StartConsuming()

        if inst._light == nil then
            inst._light = SpawnPrefab("redlanternlight")
            inst._light._lantern = inst
            inst:ListenForEvent("onremove", onremovelight, inst._light)
        end
        inst._light.entity:SetParent((inst.components.inventoryitem.owner or inst._body or inst).entity)

        inst.AnimState:Show("LIGHT")

        if inst._body ~= nil then
            inst._body.AnimState:Show("LIGHT")
        end

        if not (inst._body ~= nil and inst._body.entity:IsVisible()) and
            inst.components.equippable:IsEquipped() and
            inst.components.inventoryitem.owner ~= nil then
            inst.components.inventoryitem.owner.AnimState:Show("LANTERN_OVERLAY")
        end

        inst.components.inventoryitem:ChangeImageName("redlantern_lit")
    end
end

local function turnoff(inst)
    stoptrackingowner(inst)

    inst.components.fueled:StopConsuming()

    if inst._light ~= nil then
        inst._light:Remove()
    end

    inst.AnimState:Hide("LIGHT")

    if inst._body ~= nil then
        inst._body.AnimState:Hide("LIGHT")
    end

    if inst.components.equippable:IsEquipped() then
        inst.components.inventoryitem.owner.AnimState:Hide("LANTERN_OVERLAY")
    end

    inst.components.inventoryitem:ChangeImageName("redlantern")
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
    if inst._body ~= nil then
        inst._body:Remove()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function ToggleOverrideSymbols(inst, owner)
    if owner.sg ~= nil and (owner.sg:HasStateTag("nodangle")
            or (owner.components.rider ~= nil and owner.components.rider:IsRiding()
                and not owner.sg:HasStateTag("forcedangle"))) then
        owner.AnimState:OverrideSymbol("swap_object", "swap_redlantern", "swap_redlantern")
        if not inst.components.fueled:IsEmpty() then
            owner.AnimState:Show("LANTERN_OVERLAY")
        end
        inst._body:Hide()
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_redlantern", "swap_redlantern_stick")
        owner.AnimState:Hide("LANTERN_OVERLAY")
        inst._body:Show()
    end
end

local function onremovebody(body)
    body._lantern._body = nil
end

local function onequip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_redlantern", "redlantern_overlay")

    if inst._body ~= nil then
        inst._body:Remove()
    end
    inst._body = SpawnPrefab("redlanternbody")
    inst._body._lantern = inst
    inst:ListenForEvent("onremove", onremovebody, inst._body)

    inst._body.entity:SetParent(owner.entity)
    inst._body.entity:AddFollower()
    inst._body.Follower:FollowSymbol(owner.GUID, "swap_object", 68, -126, 0)
    inst._body:ListenForEvent("newstate", function(owner, data)
        ToggleOverrideSymbols(inst, owner)
    end, owner)

    ToggleOverrideSymbols(inst, owner)

    if owner.components.bloomer ~= nil then
        owner.components.bloomer:AttachChild(inst._body)
    end
    if owner.components.colouradder ~= nil then
        owner.components.colouradder:AttachChild(inst._body)
    end

    if inst.components.fueled:IsEmpty() then
        inst._body.AnimState:Hide("LIGHT")
        owner.AnimState:Hide("LANTERN_OVERLAY")
    else
        if inst._body.entity:IsVisible() then
            owner.AnimState:Hide("LANTERN_OVERLAY")
        else
            owner.AnimState:Show("LANTERN_OVERLAY")
        end
        turnon(inst)
    end
end

local function onunequip(inst, owner)
    if inst._body ~= nil then
        if inst._body.entity:IsVisible() then
            --need to see the lantern when animating putting away the object
            owner.AnimState:OverrideSymbol("swap_object", "swap_redlantern", "swap_redlantern")
        end
        if inst._light ~= nil then
            inst._light.entity:SetParent((inst.components.inventoryitem.owner or inst).entity)
        end
        inst._body:Remove()
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
    owner.AnimState:Hide("LANTERN_OVERLAY")

    if inst.components.fueled.consuming then
        starttrackingowner(inst, owner)
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst._body ~= nil then
        if inst._body.entity:IsVisible() then
            --need to see the lantern when animating putting away the object
            owner.AnimState:OverrideSymbol("swap_object", "swap_redlantern", "swap_redlantern")
        end
        if inst._light ~= nil then
            inst._light.entity:SetParent((inst.components.inventoryitem.owner or inst).entity)
        end
        inst._body:Remove()
    end

    if inst.components.fueled.consuming then
        starttrackingowner(inst, owner)
    end

    turnoff(inst)
end

local function nofuel(inst)
    if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner ~= nil then
        local data =
        {
            prefab = inst.prefab,
            equipslot = inst.components.equippable.equipslot,
        }
        turnoff(inst)
        inst.components.inventoryitem.owner:PushEvent("torchranout", data)
    else
        turnoff(inst)
    end
end

local function onupdatefueledraining(inst)
    local owner = inst.components.inventoryitem.owner
    inst.components.fueled.rate =
        owner ~= nil and
		(owner.components.sheltered ~= nil and owner.components.sheltered.sheltered or owner.components.rainimmunity ~= nil) and
        1 or 1 + TUNING.REDLANTERN_RAIN_RATE * TheWorld.state.precipitationrate
end

local function onisraining(inst, israining)
    if israining then
        inst.components.fueled:SetUpdateFn(onupdatefueledraining)
        onupdatefueledraining(inst)
    else
        inst.components.fueled:SetUpdateFn()
        inst.components.fueled.rate = 1
    end
end

local function OnLoad(inst, data)
    if inst.components.fueled:IsEmpty() then
        nofuel(inst)
    end
end

local function lanternlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(LIGHT_INTENSITY)
    --inst.Light:SetColour(LIGHT_COLOUR.x, LIGHT_COLOUR.y, LIGHT_COLOUR.z)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    --inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:EnableClientModulation(true)

    inst:DoPeriodicTask(.1, OnUpdateFlicker, nil, GetTime())
    OnUpdateFlicker(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("redlantern")
    inst.AnimState:SetBuild("redlantern")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("light")

    MakeInventoryFloatable(inst, "med", nil, {0.775, 0.5, 0.775})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC --no associated fuel, and not burnable fuel, since we want this item to be lit on fire
    inst.components.fueled:InitializeFuelLevel(TUNING.REDLANTERN_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL -- so people can toss depleted lanterns into a firepit

    inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:PlayAnimation("float") end)
    inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:PlayAnimation("idle_loop", true) end)

    inst:WatchWorldState("israining", onisraining)
    onisraining(inst, TheWorld.state.israining)

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    inst.components.burnable.ignorefuel = true --igniting/extinguishing should not start/stop fuel consumption

    inst.OnRemoveEntity = OnRemove
    inst.OnLoad = OnLoad

    inst._light = nil
    turnon(inst)

    inst._onownerequip = function(owner, data)
        if data.item ~= inst and
            (   data.eslot == EQUIPSLOTS.HANDS or
                (data.eslot == EQUIPSLOTS.BODY and data.item:HasTag("heavy"))
            ) then
            turnoff(inst)
        end
    end

    return inst
end

local function lanternbodyfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("redlantern")
    inst.AnimState:SetBuild("redlantern")
    inst.AnimState:PlayAnimation("idle_body_loop", true)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst.persists = false

    return inst
end

return Prefab("redlantern", fn, assets, prefabs),
    Prefab("redlanternlight", lanternlightfn),
    Prefab("redlanternbody", lanternbodyfn)
