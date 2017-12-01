require("prefabs/world")

local prefabs =
{
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
        rare        = function() return TUNING.TOTAL_DAY_TIME * 10, math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
        occasional  = function() return TUNING.TOTAL_DAY_TIME * 8, math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
        frequent    = function() return TUNING.TOTAL_DAY_TIME * 6, math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
    },

    warning_speech = "ANNOUNCE_WORMS",

    --Key = time, Value = sound prefab
    warning_sound_thresholds =
    {
        { time = 30, sound = "wormwarning_lvl4" },
        { time = 60, sound = "wormwarning_lvl3" },
        { time = 90, sound = "wormwarning_lvl2" },
        { time = 500, sound = "wormwarning_lvl1" },
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
    end
end

local function master_postinit(inst)
    --Spawners
    inst:AddComponent("shadowcreaturespawner")
    inst:AddComponent("shadowhandspawner")
    inst:AddComponent("toadstoolspawner")

    --gameplay
    inst:AddComponent("caveins")
    inst:AddComponent("kramped")
    inst:AddComponent("chessunlocks")
    inst:AddComponent("townportalregistry")

    --world management
    inst:AddComponent("forestresourcespawner") -- a cave version of this would be nice, but it serves it's purpose...
    inst:AddComponent("regrowthmanager")
    inst:AddComponent("desolationspawner")

    if METRICS_ENABLED then
        inst:AddComponent("worldoverseer")
    end

    --cave specifics
    inst:AddComponent("hounded")
    inst.components.hounded:SetSpawnData(wormspawn)

    --anr update retrofitting
    inst:AddComponent("retrofitcavemap_anr")

    return inst
end

return MakeWorld("cave", prefabs, assets, common_postinit, master_postinit, { "cave" })
