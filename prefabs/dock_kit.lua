local assets =
{
    Asset("ANIM", "anim/dock_kit.zip"),
    Asset("INV_IMAGE", "dock_kit"),
}

local prefabs =
{
    "gridplacer",
    "dock_damage",
}

local function CLIENT_CanDeployDockKit(inst, pt, mouseover, deployer, rotation)
    local x, y, z = pt:Get()
    local tile = TheWorld.Map:GetTileAtPoint(x, 0, z)
    if tile ~= WORLD_TILES.OCEAN_COASTAL_SHORE and tile ~= WORLD_TILES.OCEAN_COASTAL then
        return false
    end

    local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, 0, z)
    if not TheWorld.Map:HasAdjacentLandTile(tx, ty) then
        return false
    end

    local center_pt = Vector3(TheWorld.Map:GetTileCenterPoint(tx, ty))
    return TheWorld.Map:CanDeployDockAtPoint(center_pt, inst, mouseover)
end

local function on_deploy(inst, pt, deployer)
    if TheWorld.components.dockmanager ~= nil then
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", { intensity = 0.8 })
        end

        TheWorld.components.dockmanager:CreateDockAtPoint(pt.x, pt.y, pt.z, WORLD_TILES.MONKEY_DOCK)

        -- Since this tile was player-deployed; let's see if it can actually hold its position.
        local dock_unsafe = TheWorld.components.dockmanager:ResolveDockSafetyAtPoint(pt.x, pt.y, pt.z)

        if dock_unsafe and deployer.components.talker ~= nil then
            deployer.components.talker:Say(GetString(deployer, "ANNOUNCE_BOAT_SINK"))
        end
    end

    inst.components.stackable:Get():Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dock_kit")
    inst.AnimState:SetBuild("dock_kit")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "wood"

    MakeInventoryFloatable(inst, "med", 0.2, 0.75)

    inst:AddTag("groundtile")
    inst:AddTag("usedeployspacingasoffset")

    inst._custom_candeploy_fn = CLIENT_CanDeployDockKit -- for DEPLOYMODE.CUSTOM
    
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -------------------------------------------------------
    inst:AddComponent("inspectable")

    -------------------------------------------------------
    inst:AddComponent("inventoryitem")

    -------------------------------------------------------
    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    inst.components.deployable:SetUseGridPlacer(true)
    inst.components.deployable.ondeploy = on_deploy

    -------------------------------------------------------
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

-----------------------------------------------------------------------------
local function on_registrator_loaded(inst, data, newents)
    if data ~= nil and data.undertile ~= nil then
        inst._loaded_undertile = WORLD_TILES[data.undertile]
    end
end

local function on_registrator_postpass(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.components.dockmanager ~= nil then
        TheWorld.components.dockmanager:CreateDockAtPoint(x, y, z, WORLD_TILES.MONKEY_DOCK)
    end

    if TheWorld.components.undertile ~= nil then
        local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, y, z)
        TheWorld.components.undertile:SetTileUnderneath(tx, ty, inst._loaded_undertile)
    end

    inst.persists = false
end

local function registrator_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst._loaded_undertile = nil
    inst.OnLoad = on_registrator_loaded

    inst:DoTaskInTime(1*FRAMES, on_registrator_postpass)

    return inst
end

return Prefab("dock_kit", fn, assets, prefabs),
    Prefab("dock_tile_registrator", registrator_fn)