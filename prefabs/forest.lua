require("prefabs/world")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/world.lua"),

    Asset("IMAGE", "images/colour_cubes/day05_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/dusk03_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/night03_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/snow_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/snowdusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/night04_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/summer_night_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/spring_night_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_day_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_dusk_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/insane_night_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/purple_moon_cc.tex"),

    Asset("ANIM", "anim/snow.zip"),
    Asset("ANIM", "anim/lightning.zip"),

    Asset("SOUND", "sound/forest_stream.fsb"),
    Asset("SOUND", "sound/amb_stream.fsb"),

    Asset("IMAGE", "levels/textures/snow.tex"),
    Asset("IMAGE", "levels/textures/mud.tex"),
    Asset("IMAGE", "images/wave.tex"),
}

local prefabs =
{
    "cave",
    "forest_network",
    "adventure_portal",
    "resurrectionstone",
    "deer",
    "deerspawningground",
    "deerclops",
    "gravestone",
    "flower",
    "animal_track",
    "dirtpile",
    "beefaloherd",
    "beefalo",
    "penguinherd",
    "penguin_ice",
    "penguin",
    "koalefant_summer",
    "koalefant_winter",
    "beehive",
    "wasphive",
    "walrus_camp",
    "pighead",
    "mermhead",
    "rabbithole",
    "molehill",
    "carrot_planted",
    "tentacle",
    "wormhole",
    "cave_entrance",
    "teleportato_base",
    "teleportato_ring",
    "teleportato_box",
    "teleportato_crank",
    "teleportato_potato",
    "pond", 
    "marsh_tree", 
    "marsh_bush", 
    "burnt_marsh_bush",
    "reeds", 
    "mist",
    "snow",
    "rain",
    "pollen",
    "marblepillar",
    "marbletree",
    "statueharp",
    "statuemaxwell",
    "beemine_maxwell",
    "trap_teeth_maxwell",
    "sculpture_knight",
    "sculpture_bishop",
    "sculpture_rook",
    "statue_marble",
    "eyeplant",
    "lureplant",
    "purpleamulet",
    "monkey",
    "livingtree",
    "tumbleweed",
    "rock_ice",
    "catcoonden",
    "shadowmeteor",
    "meteorwarning",
    "warg",
    "spat",
    "multiplayer_portal",
    "lavae",
    "lava_pond",
    "scorchedground",
    "scorched_skeleton",
    "lavae_egg",
    "terrorbeak",
    "crawlinghorror",
    "creepyeyes",
    "shadowskittish",
    "shadowwatcher",
    "shadowhand",
    "stagehand",
    "tumbleweedspawner",
    "meteorspawner",
    "dragonfly_spawner",
    "moose",
    "mossling",
    "bearger",
    "dragonfly",
    "chester",
    "grassgekko",
    "petrify_announce",
    "moonbase",
    "moonrock_pieces",
    "shadow_rook",
    "shadow_knight",
    "shadow_bishop",
    "beequeenhive",
    "klaus_sack",
    "antlion_spawner",
    "oasislake",
    "succulent_plant",
}

local monsters =
{
    { "hound", 4 },
    { "deerclops", 4 },
    { "bearger", 4 },
    { "krampus", 3 },
}
for i, v in ipairs(monsters) do
    for level = 1, v[2] do
        table.insert(prefabs, v[1].."warning_lvl"..tostring(level))
    end
end
monsters = nil

local houndspawn =
{
    base_prefab = "hound",
    winter_prefab = "icehound",
    summer_prefab = "firehound",

    attack_levels =
    {
        intro   = { warnduration = function() return 120 end, numspawns = function() return 2 end },
        light   = { warnduration = function() return 60 end, numspawns = function() return 2 + math.random(2) end },
        med     = { warnduration = function() return 45 end, numspawns = function() return 3 + math.random(3) end },
        heavy   = { warnduration = function() return 30 end, numspawns = function() return 4 + math.random(3) end },
        crazy   = { warnduration = function() return 30 end, numspawns = function() return 6 + math.random(4) end },
    },

    attack_delays =
    {
        rare        = function() return TUNING.TOTAL_DAY_TIME * 6, math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
        occasional  = function() return TUNING.TOTAL_DAY_TIME * 4, math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
        frequent    = function() return TUNING.TOTAL_DAY_TIME * 3, math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
    },

    warning_speech = "ANNOUNCE_HOUNDS",

    --Key = time, Value = sound prefab
    warning_sound_thresholds =
    {
        { time = 30, sound = "houndwarning_lvl4" },
        { time = 60, sound = "houndwarning_lvl3" },
        { time = 90, sound = "houndwarning_lvl2" },
        { time = 500, sound = "houndwarning_lvl1" },
    },
}

local function common_postinit(inst)
    --Add waves
    inst.entity:AddWaveComponent()
    inst.WaveComponent:SetWaveParams(13.5, 2.5)						-- wave texture u repeat, forward distance between waves
    inst.WaveComponent:SetWaveSize(80, 3.5)							-- wave mesh width and height
    inst.WaveComponent:SetWaveTexture("images/wave.tex")
    --See source\game\components\WaveRegion.h
    inst.WaveComponent:SetWaveEffect("shaders/waves.ksh")
    --inst.WaveComponent:SetWaveEffect("shaders/texture.ksh")

    --Initialize lua components
    inst:AddComponent("ambientlighting")

    --Dedicated server does not require these components
    --NOTE: ambient lighting is required by light watchers
    if not TheNet:IsDedicated() then
        inst:AddComponent("dynamicmusic")
        inst:AddComponent("ambientsound")
        inst:AddComponent("dsp")
        inst:AddComponent("colourcube")
        inst:AddComponent("hallucinations")
    end
end

local function master_postinit(inst)
    --Spawners
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")
    inst:AddComponent("hounded")

    inst.components.hounded:SetSpawnData(houndspawn)

    inst:AddComponent("worlddeciduoustreeupdater")
    inst:AddComponent("kramped")
    inst:AddComponent("frograin")
    inst:AddComponent("penguinspawner")
    inst:AddComponent("deerherdspawner")
    inst:AddComponent("deerherding")
    inst:AddComponent("klaussackspawner")
    inst:AddComponent("deerclopsspawner")
    inst:AddComponent("beargerspawner")
    inst:AddComponent("moosespawner")
    inst:AddComponent("hunter")
    inst:AddComponent("lureplantspawner")
    inst:AddComponent("shadowcreaturespawner")
    inst:AddComponent("shadowhandspawner")
    inst:AddComponent("wildfires")
    inst:AddComponent("worldwind")
    inst:AddComponent("forestresourcespawner")
    inst:AddComponent("regrowthmanager")
    inst:AddComponent("desolationspawner")
    inst:AddComponent("forestpetrification")
    inst:AddComponent("chessunlocks")
    inst:AddComponent("retrofitforestmap_anr")
    inst:AddComponent("specialeventsetup")
    inst:AddComponent("townportalregistry")
    inst:AddComponent("sandstorms")

    if METRICS_ENABLED then
        inst:AddComponent("worldoverseer")
    end
end

return MakeWorld("forest", prefabs, assets, common_postinit, master_postinit, {"forest"})
