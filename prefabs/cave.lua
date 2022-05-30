require("prefabs/world")

local prefabs =
{
    "forest",
    "cave_network",
    "cave_exit",
    "slurtle",
    "snurtle",
    "slurtlehole",
    "warningshadow",
    "cavelight",
    "cavelight_small",
    "cavelight_tiny",
    "cavelight_atrium",
    "flower_cave",
    "ancient_altar",
    "ancient_altar_broken",
    "stalagmite",
    "stalagmite_tall",
    "bat",
    "mushtree_tall",
    "mushtree_medium",
    "mushtree_small",
    "mushtree_tall_webbed",
    "cave_banana_tree",
    "spiderhole",
    "ground_chunks_breaking",
    "tentacle_pillar",
    "batcave",
    "rockyherd",
    "cave_fern",
    "monkey",
    "monkeybarrel",
    "rock_light",
    "ruins_plate",
    "ruins_bowl",
    "ruins_chair",
    "ruins_chipbowl",
    "ruins_vase",
    "ruins_table",
    "ruins_rubble_table",
    "ruins_rubble_chair",
    "ruins_rubble_vase",
    "rubble",
    "lichen",
    "cutlichen",
    "rook_nightmare",
    "bishop_nightmare",
    "knight_nightmare",
    "ruins_statue_head",
    "ruins_statue_head_nogem",
    "ruins_statue_mage",
    "ruins_statue_mage_nogem",
    "nightmarelight",
    "pillar_ruins",
    "pillar_algae",
    "pillar_cave",
    "pillar_cave_rock",
    "pillar_cave_flintless",
    "pillar_stalactite",
    "worm",
    "wormlight_plant",
    "fissure",
    "fissure_lower",
    "slurper",
    "minotaur",
    "spider_dropper",
    "caverain",
    "dropperweb",
    "hutch",
    "toadstool_cap",
    "cavein_boulder",
    "cavein_debris",
    "pillar_atrium",
    "atrium_light",
    "atrium_gate",
    "atrium_statue",
    "atrium_statue_facing",
    "atrium_fence",
    "atrium_rubble",
    "atrium_idol", -- deprecated
    "atrium_overgrowth",
    "cave_hole",
    "chessjunk",
    "pandoraschest",
    "sacred_chest",

    -- GROTTO
    "archive_centipede",
    "archive_chandelier",
    "archive_moon_statue",
    "archive_orchestrina_main",
    "archive_pillar",
    "archive_moon_statue",
    "archive_rune_statue",
    "archive_security_desk",
    "archive_lockbox_dispencer",
    "archive_lockbox_dispencer_temp",
    "archive_switch",
    "archive_portal",
    "archive_cookpot",
    "archive_ambient_sfx",
    "rubble2",
    "rubble1",

    "cavelightmoon",
    "cavelightmoon_small",
    "cavelightmoon_tiny",
    "dustmothden",
    "fissure_grottowar",
    "nightmaregrowth",
    "gestalt_guard",
    "grotto_pool_big",
    "grotto_pool_small",
    "lightflier_flower",
    "molebat",
    "mushgnome_spawner",
    "mushtree_moon",
    "moonglass_stalactite1",
    "moonglass_stalactite2",
    "moonglass_stalactite3",
    "dustmeringue",

	"retrofit_archiveteleporter",
	"retrofitted_grotterwar_spawnpoint",
	"retrofitted_grotterwar_homepoint",
 --   "wall_ruins_2",
}

local monsters =
{
    "worm",
}
for i, v in ipairs(monsters) do
    for level = 1, 4 do
        table.insert(prefabs, v.."warning_lvl"..tostring(level))
    end
end
monsters = nil

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/world.lua"),

    Asset("SOUND", "sound/cave_AMB.fsb"),
    Asset("SOUND", "sound/cave_mem.fsb"),
    Asset("IMAGE", "images/colour_cubes/caves_default.tex"),

    Asset("IMAGE", "images/colour_cubes/ruins_light_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/ruins_dim_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/ruins_dark_cc.tex"),

    Asset("IMAGE", "images/colour_cubes/fungus_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/sinkhole_cc.tex"),
}

local wormspawn =
{
    base_prefab = "worm",
    winter_prefab = "worm",
    summer_prefab = "worm",

    attack_levels =
    {
        intro   = { warnduration = function() return 120 end, numspawns = function() return 1 end },
        light   = { warnduration = function() return 60 end, numspawns = function() return 1 + math.random(0,1) end },
        med     = { warnduration = function() return 45 end, numspawns = function() return 1 + math.random(0,1) end },
        heavy   = { warnduration = function() return 30 end, numspawns = function() return 2 + math.random(0,1) end },
        crazy   = { warnduration = function() return 30 end, numspawns = function() return 3 + math.random(0,2) end },
    },

    attack_delays =
    {
        intro 		= function() return TUNING.TOTAL_DAY_TIME * 6, math.random() * TUNING.TOTAL_DAY_TIME * 2.5 end,
        rare 		= function() return TUNING.TOTAL_DAY_TIME * 7, math.random() * TUNING.TOTAL_DAY_TIME * 2.5 end,
        occasional 	= function() return TUNING.TOTAL_DAY_TIME * 8, math.random() * TUNING.TOTAL_DAY_TIME * 2.5 end,
        frequent 	= function() return TUNING.TOTAL_DAY_TIME * 9, math.random() * TUNING.TOTAL_DAY_TIME * 2.5 end,
        crazy 		= function() return TUNING.TOTAL_DAY_TIME * 10, math.random() * TUNING.TOTAL_DAY_TIME * 2.5 end,
    },

    warning_speech = "ANNOUNCE_WORMS",

    --Key = time, Value = sound prefab
    warning_sound_thresholds =
    {
        { time = 30, sound = "LVL4_WORM" },
        { time = 60, sound = "LVL3_WORM" },
        { time = 90, sound = "LVL2_WORM" },
        { time = 500, sound = "LVL1_WORM" },
    },
}

local function common_postinit(inst)
    --Initialize lua components
    inst:AddComponent("ambientlighting")

    --Dedicated server does not require these components
    --NOTE: ambient lighting is required by light watchers
    if not TheNet:IsDedicated() then
        inst:AddComponent("dynamicmusic")
        inst:AddComponent("ambientsound")
        inst.components.ambientsound:SetReverbPreset("cave")
        inst.components.ambientsound:SetWavesEnabled(false)
        inst:AddComponent("dsp")
        inst:AddComponent("colourcube")
        inst:AddComponent("hallucinations")

        -- Grotto
        inst:AddComponent("grottowaterfallsoundcontroller")
    end

    TheWorld.Map:SetUndergroundFadeHeight(5)
end

local function master_postinit(inst)
    --Spawners
    inst:AddComponent("shadowcreaturespawner")
    inst:AddComponent("shadowhandspawner")
    inst:AddComponent("brightmarespawner")
    inst:AddComponent("toadstoolspawner")
    inst:AddComponent("grottowarmanager")

    --gameplay
    inst:AddComponent("caveins")
    inst:AddComponent("kramped")
    inst:AddComponent("chessunlocks")
    inst:AddComponent("townportalregistry")

    --world management
    inst:AddComponent("forestresourcespawner") -- a cave version of this would be nice, but it serves it's purpose...
    inst:AddComponent("regrowthmanager")
    inst:AddComponent("desolationspawner")
    inst:AddComponent("mermkingmanager")
    inst:AddComponent("feasts")

    inst:AddComponent("yotc_raceprizemanager")
    inst:AddComponent("yotb_stagemanager")

    if METRICS_ENABLED then
        inst:AddComponent("worldoverseer")
    end

    --cave specifics
    inst:AddComponent("hounded")
    inst.components.hounded:SetSpawnData(wormspawn)
	inst.components.hounded.max_thieved_spawn_per_thief = 1

    --anr update retrofitting
    inst:AddComponent("retrofitcavemap_anr")

    -- Archive
    inst:AddComponent("archivemanager")

    return inst
end

return MakeWorld("cave", prefabs, assets, common_postinit, master_postinit, { "cave" })
