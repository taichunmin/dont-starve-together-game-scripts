require("prefabs/world")
local GroundTiles = require "worldtiledefs"

local prefabs =
{
    "lavaarena_portal",
    "lavaarena_network",
    "lavaarena_crowdstand",
    "lavaarena_groundtargetblocker",
    "lavaarena_boarlord",
    "lavaarena_center",
    "lavaarena_spawner",
    "lavaarena_floorgrate",
    "lavaarena_battlestandard_damager",
    "lavaarena_battlestandard_shield",
    "lavaarena_battlestandard_heal",

    "lavaarenastage_attack",
    "lavaarenastage_delay",
    "lavaarenastage_dialog",
    "lavaarenastage_allplayersspawned",
    "lavaarenastage_startround",
    "lavaarenastage_wait",
    "lavaarenastage_endofround",
    "lavaarenastage_endofmatch",
    "lavaarenastage_resetgame",

    "boaron",
    "boarrior",
    "peghook",
    "turtillus",
    "trails",
    "snapper",
    "rhinodrill",
    "rhinodrill2",
    "beetletaur",

    "lavaarena_lootbeacon",
    "damagenumber",

    "book_fossil",
    "book_elemental",
    "fireballstaff",
    "healingstaff",
    "hammer_mjolnir",
    "spear_gungnir",
    "spear_lance",
    "blowdart_lava",
    "blowdart_lava2",

    "lavaarena_armorlight",
    "lavaarena_armorlightspeed",
    "lavaarena_armormedium",
    "lavaarena_armormediumdamager",
    "lavaarena_armormediumrecharger",
    "lavaarena_armorheavy",
    "lavaarena_armorextraheavy",

    "lavaarena_feathercrownhat",
    "lavaarena_healingflowerhat",
    --"lavaarena_extraheavyhat",
    "lavaarena_lightdamagerhat",
    "lavaarena_strongdamagerhat",
    "lavaarena_tiaraflowerpetalshat",
    "lavaarena_eyecirclethat",
    "lavaarena_rechargerhat",
    "lavaarena_healinggarlandhat",
    "lavaarena_crowndamagerhat",

    -- Lavaarena season 2
    "lavaarena_armor_hpextraheavy",
    "lavaarena_armor_hppetmastery",
    "lavaarena_armor_hprecharger",
    "lavaarena_armor_hpdamager",

    "lavaarena_firebomb",
    "lavaarena_heavyblade",
}

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/world.lua"),

    Asset("SOUND", "sound/lava_arena.fsb"),
    Asset("SOUND", "sound/forge2.fsb"),

    Asset("IMAGE", "images/lavaarena_wave.tex"),

    Asset("IMAGE", "levels/tiles/lavaarena_falloff.tex"),
    Asset("FILE", "levels/tiles/lavaarena_falloff.xml"),

    Asset("IMAGE", "images/colour_cubes/day05_cc.tex"), --default CC at startup
    Asset("IMAGE", "images/colour_cubes/lavaarena2_cc.tex"), --override CC
    Asset("IMAGE", "images/colour_cubes/insane_day_cc.tex"), --default insanity CC
    Asset("IMAGE", "images/colour_cubes/lunacy_regular_cc.tex"), --default lunacy CC

    Asset("ANIM", "anim/progressbar_tiny.zip"),
}

local function common_preinit(inst)
    for i, v in ipairs(GroundTiles.falloff) do
        if v[1] == FALLOFF_IDS.FALLOFF then
            v[2].name = "lavaarena_falloff"
            break
        end
    end
    MapLayerManager:SetSampleStyle(MAP_SAMPLE_STYLE.MARCHING_SQUARES)
end

local function tile_physics_init(inst)
    inst.Map:AddTileCollisionSet(
        COLLISION.LAND_OCEAN_LIMITS,
        TileGroups.ImpassableTiles, true,
        TileGroups.ImpassableTiles, false,
        0.25, 64
    )
end

local function common_postinit(inst)
    --Initialize lua components
    inst:AddComponent("ambientlighting")
    inst:PushEvent("overrideambientlighting", Point(200 / 255, 200 / 255, 200 / 255))

    inst:AddComponent("lavaarenamobtracker")

    --Dedicated server does not require these components
    --NOTE: ambient lighting is required by light watchers
    if not TheNet:IsDedicated() then
        -- add lava waves
        inst.entity:AddWaveComponent()
        local scale = 1.3
        inst.WaveComponent:SetWaveParams(13.5 * scale, 2.8 * (scale - .15), -5) -- wave texture u repeat, forward distance between waves, world y-axis position
        inst.WaveComponent:SetWaveSize(80 * scale, 3.5 * scale)                 -- wave mesh width and height
        inst.WaveComponent:SetWaveMotion(.3, .5, .35)                           -- speed, horizontal travel, vertical travel

        inst.WaveComponent:SetWaveTexture(resolvefilepath("images/lavaarena_wave.tex"))
        inst.WaveComponent:SetWaveEffect("shaders/waves.ksh")

        inst:AddComponent("ambientsound")
        inst.components.ambientsound:SetReverbPreset("lava_arena")
        inst.components.ambientsound:SetWavesEnabled(false)
        inst:PushEvent("overrideambientsound", { tile = WORLD_TILES.IMPASSABLE, override = WORLD_TILES.LAVAARENA_FLOOR })
        inst:AddComponent("colourcube")
        inst:PushEvent("overridecolourcube", "images/colour_cubes/lavaarena2_cc.tex")

        inst:ListenForEvent("playeractivated", function(inst, player)
            if ThePlayer == player then
                TheNet:UpdatePlayingWithFriends()
            end
        end)
    end
end

local function master_postinit(inst)
    event_server_data("lavaarena", "prefabs/lavaarena").master_postinit(inst)
end

return MakeWorld("lavaarena", prefabs, assets, common_postinit, master_postinit, { "lavaarena" }, {common_preinit = common_preinit, tile_physics_init = tile_physics_init})
