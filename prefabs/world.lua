local GroundTiles = require "worldtiledefs"
require "components/map" --extends Map component

local assets =
{
    Asset("SOUND", "sound/music.fsb"),
    Asset("SOUND", "sound/sanity.fsb"),
    Asset("SOUND", "sound/amb_stream.fsb"),
    Asset("SHADER", "shaders/uifade.ksh"),
    -- Asset("ATLAS", "images/selectscreen_portraits.xml"), -- Not currently used, but likely to come back
    -- Asset("IMAGE", "images/selectscreen_portraits.tex"), -- Not currently used, but likely to come back
    Asset("DYNAMIC_ATLAS", "bigportraits/locked.xml"),
    Asset("PKGREF", "bigportraits/locked.tex"),

    Asset("DYNAMIC_ATLAS", "bigportraits/random.xml"),
    Asset("PKGREF", "bigportraits/random.tex"),
    Asset("DYNAMIC_ATLAS", "bigportraits/random_none.xml"),
    Asset("PKGREF", "bigportraits/random_none.tex"),

    Asset("DYNAMIC_ATLAS", "images/names_random.xml"),
    Asset("PKGREF", "images/names_random.tex"),

    Asset("DYNAMIC_ATLAS", "images/names_gold_random.xml"),
    Asset("PKGREF", "images/names_gold_random.tex"),

    -- Asset("ANIM", "anim/portrait_frame.zip"), -- Not currently used, but likely to come back
    Asset("ANIM", "anim/spiral_bg.zip"),

    Asset("ANIM", "anim/frames_comp.zip"),

    Asset("ANIM", "anim/frozen.zip"),

    Asset("DYNAMIC_ATLAS", "images/bg_spiral_anim.xml"),
    Asset("PKGREF", "images/bg_spiral_anim.tex"),
    Asset("DYNAMIC_ATLAS", "images/bg_spiral_anim_overlay.xml"),
    Asset("PKGREF", "images/bg_spiral_anim_overlay.tex"),
}


for k, v in pairs(GroundTiles.assets) do
    table.insert(assets, v)
end

local prefabs =
{
    "sounddebugicon",

    "minimap",
    "evergreen",
    "evergreen_normal",
    "evergreen_short",
    "evergreen_tall",
    "evergreen_sparse",
    "evergreen_sparse_normal",
    "evergreen_sparse_short",
    "evergreen_sparse_tall",
    "evergreen_burnt",
    "evergreen_stump",

    "twiggytree",
    "twiggy_tall",
    "twiggy_short",
    "twiggy_normal",

    "sapling",
    "berrybush",
    "berrybush2",
    "berrybush_juicy",
    "grass",
    "rock1",
    "rock2",
    "rock_flintless",
    "rock_moon",
    "rock_petrified_tree",
    "rock_petrified_tree_tall",
    "rock_petrified_tree_short",
    "rock_petrified_tree_med",

    "tallbirdnest",
    "hound",
    "firehound",
    "icehound",
    "krampus",
    "mound",

    "pigman",
    "pighouse",
    "pigking",
    "mandrake",
    "rook",
    "bishop",
    "knight",

    "critterlab",

    "goldnugget",
    "crow",
    "robin",
    "robin_winter",
    "canary",
    "butterfly",
    "flint",
    "log",
    "spiderden",
    "fireflies",

    "turf_road",
    "turf_rocky",
    "turf_marsh",
    "turf_savanna",
    "turf_forest",
    "turf_grass",
    "turf_cave",
    "turf_fungus",
    "turf_sinkhole",
    "turf_underrock",
    "turf_mud",

    "skeleton",
    "insanityrock",
    "sanityrock",
    "basalt",
    "basalt_pillar",
    "houndmound",
    "houndbone",
    "pigtorch",
    "red_mushroom",
    "green_mushroom",
    "blue_mushroom",
    "mermhouse",
    "flower_evil",
    "blueprint",
    "wormhole_limited_1",
    "diviningrod",
    "diviningrodbase",
    "splash_ocean",
    "maxwell_smoke",
    "chessjunk1",
    "chessjunk2",
    "chessjunk3",
    "statue_transition_2",
    "statue_transition",

    "lightninggoat",
    "smoke_plant",
    "acorn",
    "deciduoustree",
    "deciduoustree_normal",
    "deciduoustree_tall",
    "deciduoustree_short",
    "deciduoustree_burnt",
    "deciduoustree_stump",
    "buzzardspawner",

    "glommer",
    "statueglommer",

    "cactus",

    "spawnlight_multiplayer",
    "spawnpoint_multiplayer",
    --"spawn_fx_huge",
    --"spawn_fx_large",
    "spawn_fx_medium",
    "spawn_fx_small",
    "spawn_fx_tiny",
    "spawn_fx_small_high",

    -- used to be in BACKEND_PREFABS constant
    "hud",
    "fire",
    "character_fire",
    "shatter",
    --

    "migration_portal",
    "shard_network",

    "focalpoint",

    -- Common classified prefabs
    "attunable_classified",
    "inventoryitem_classified",
    "writeable_classified",
    "container_classified",
    "constructionsite_classified",

    "dummytarget",
}

--------------------------------------------------------------------------

local function DoGameDataChanged(inst)
    inst.game_data_task = nil

    local game_data =
    {
        day = inst.state.cycles + 1,
        daysleftinseason = inst.state.remainingdaysinseason,
        dayselapsedinseason = inst.state.elapseddaysinseason,
    }
    TheNet:SetGameData(DataDumper(game_data, nil, false))
    TheNet:SetSeason(inst.state.season)
end

local function OnGameDataChanged(inst)
    if inst.game_data_task == nil then
        inst.game_data_task = inst:DoTaskInTime(0, DoGameDataChanged)
    end
end

local function PostInit(inst)
    if inst.net ~= nil then
        inst.net:PostInit()
    end

    inst:LongUpdate(0)

    for k, v in pairs(inst.components) do
        if v.OnPostInit ~= nil then
            v:OnPostInit()
        end
    end

    if inst.ismastersim then
        inst:WatchWorldState("season", OnGameDataChanged)
        inst:WatchWorldState("cycles", OnGameDataChanged)
        inst:WatchWorldState("remainingdaysinseason", OnGameDataChanged)
        inst:WatchWorldState("elapseddaysinseason", OnGameDataChanged)
        DoGameDataChanged(inst)
    end
end

local function OnRemoveEntity(inst)
    inst.minimap:Remove()

    assert(TheWorld == inst)
    TheWorld = nil

    assert(TheFocalPoint ~= nil)
    TheFocalPoint:Remove()
    TheFocalPoint = nil
end

--------------------------------------------------------------------------

function MakeWorld(name, customprefabs, customassets, common_postinit, master_postinit, tags, custom_data)
	custom_data = custom_data or {}

    local worldprefabs = {}
    if name ~= "world" then
        table.insert(worldprefabs, "world")
    end
    if customprefabs ~= nil then
        for i, v in ipairs(customprefabs) do
            table.insert(worldprefabs, v)
        end
    end

    local function fn()
        local inst = CreateEntity()

        assert(TheWorld == nil)
        TheWorld = inst
        inst.net = nil
        inst.shard = nil

        inst.ismastersim = TheNet:GetIsMasterSimulation()
        inst.ismastershard = inst.ismastersim and not TheShard:IsSlave()
        --V2C: Masters is hard

        inst:AddTag("NOCLICK")
        inst:AddTag("CLASSIFIED")

        if tags ~= nil then
            for i, v in ipairs(tags) do
                inst:AddTag(v)
            end
        end

        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        --Add core components
        inst.entity:AddTransform()
        inst.entity:AddMap()
        inst.entity:AddPathfinder()
        inst.entity:AddGroundCreep()
        inst.entity:AddSoundEmitter()

        if custom_data.common_preinit ~= nil then
            custom_data.common_preinit(inst)
        end

        --Initialize map
        for i, data in ipairs(GroundTiles.ground) do
            local tile_type, props = unpack(data)
            local layer_name = props.name
            local handle = MapLayerManager:CreateRenderLayer(
                tile_type, --embedded map array value
                resolvefilepath(GroundAtlas(layer_name)),
                resolvefilepath(GroundImage(layer_name)),
                resolvefilepath(props.noise_texture)
            )
            inst.Map:AddRenderLayer(handle)
            --TODO: When this object is destroyed, these handles really should be freed. At this time,
            --this is not an issue because the map lifetime matches the game lifetime but if this were
            --to ever change, we would have to clean up properly or we leak memory.
        end

        for i, data in ipairs(GroundTiles.creep) do
            local tile_type, props = unpack(data)
            local handle = MapLayerManager:CreateRenderLayer(
                tile_type,
                resolvefilepath(GroundAtlas(props.name)),
                resolvefilepath(GroundImage(props.name)),
                resolvefilepath(props.noise_texture)
            )
            inst.GroundCreep:AddRenderLayer(handle)
        end

        local underground_layer = GroundTiles.underground[1][2]
        local underground_handle = MapLayerManager:CreateRenderLayer(
            GROUND.UNDERGROUND,
            resolvefilepath(GroundAtlas(underground_layer.name)),
            resolvefilepath(GroundImage(underground_layer.name)),
            resolvefilepath(underground_layer.noise_texture)
        )
        inst.Map:SetUndergroundRenderLayer(underground_handle)

        inst.Map:SetImpassableType(GROUND.IMPASSABLE)

        --Initialize lua world state
        inst:AddComponent("worldstate")
        inst.state = inst.components.worldstate.data

        --Initialize lua components
        inst:AddComponent("groundcreep")

        --Public member functions
        inst.PostInit = PostInit
        inst.OnRemoveEntity = OnRemoveEntity

        --Initialize minimap
        inst.minimap = SpawnPrefab("minimap")

        --Initialize local focal point
        assert(TheFocalPoint == nil)
        TheFocalPoint = SpawnPrefab("focalpoint")
        TheCamera:SetTarget(TheFocalPoint)

        if common_postinit ~= nil then
            common_postinit(inst)
        end

        inst:SetPrefabName("world") -- the actual prefab to load comes from gamelogic.lua, this is for postinitfns.

        if not inst.ismastersim then
            return inst
        end

        inst:AddComponent("playerspawner")

        --World health management
        inst:AddComponent("skeletonsweeper")

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        --Metrics
        inst:AddComponent("uniqueprefabids")

        --World gen data for server listing
        --Also updated in shardnetworking.lua for multilevel server clusters
        UpdateServerWorldGenDataString()

        inst.game_data_task = nil

        return inst
    end

    return Prefab(name, fn, customassets, worldprefabs)
end

return MakeWorld("world", prefabs, assets)
