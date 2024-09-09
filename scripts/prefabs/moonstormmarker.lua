local assets =
{
    Asset("MINIMAP_IMAGE", "moonstormmarker0"),
    Asset("MINIMAP_IMAGE", "moonstormmarker1"),
    Asset("MINIMAP_IMAGE", "moonstormmarker2"),
    Asset("MINIMAP_IMAGE", "moonstormmarker3"),
    Asset("MINIMAP_IMAGE", "moonstormmarker4"),
    Asset("MINIMAP_IMAGE", "moonstormmarker5"),
    Asset("MINIMAP_IMAGE", "moonstormmarker6"),
    Asset("MINIMAP_IMAGE", "moonstormmarker7"),
}

local prefabs =
{
    "globalmapicon",
}

local function do_marker_minimap_swap(inst)
    inst.marker_index = inst.marker_index == nil and 0 or ((inst.marker_index + 1) % 8)

    local marker_image = "moonstormmarker"..inst.marker_index..".png"

    inst.MiniMapEntity:SetIcon(marker_image)
    inst.icon.MiniMapEntity:SetIcon(marker_image)
end

local function show_minimap(inst)
    -- Create a global map icon so the minimap icon is visible to other players as well.
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon:TrackEntity(inst)
    inst.icon.MiniMapEntity:SetPriority(21)

    inst:DoPeriodicTask(TUNING.STORM_SWAP_TIME, do_marker_minimap_swap)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetIcon("moonstormmarker0.png")
    inst.MiniMapEntity:SetPriority(21)

    inst.entity:SetCanSleep(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.marker_index = 1
    inst:DoTaskInTime(0, show_minimap)

    return inst
end

return Prefab("moonstormmarker_big", fn, assets, prefabs),
    Prefab("monstormmarker_debug", fn)