require("prefabs/world")

local prefabs =
{
    "quagmire_network",

    -- Base Game
    "rabbit",
    "sapling",
    "berrybush2",
    "beefaloherd",

    -- used to be in BACKEND_PREFABS constant
    "hud",
    "focalpoint",

    -- Common classified prefabs
    "inventoryitem_classified",
    "writeable_classified",
    "container_classified",
    "container_opener",

    ----------------------------------------------------------------------------------

    -- event flow
    "quagmirestage_cravings",
    "quagmirestage_delay",
    "quagmirestage_dialog",
    "quagmirestage_allplayersspawned",
    "quagmirestage_wait",
    "quagmirestage_endofmatch",
    "quagmirestage_resetgame",

    -- world gen
    "firepit",
    "minisign",
    "quagmire_hoe",
    "axe",
    "quagmire_mealingstone",

    "quagmire_portal",
    "quagmire_altar",
    "quagmire_altar_statue1",
    "quagmire_altar_statue2",
    "quagmire_altar_queen",
    "quagmire_altar_bollard",
    "quagmire_altar_ivy",

    "quagmire_trader_merm",
    "quagmire_trader_merm2",
    "quagmire_merm_cart1",
    "quagmire_merm_cart2",

    "quagmire_safe",

    "quagmire_sugarwoodtree",
    "quagmire_spotspice_shrub",
    "quagmire_park_fountain",
    "quagmire_park_angel",
    "quagmire_park_angel2",
    "quagmire_park_urn",
    "quagmire_park_obelisk",
    "quagmire_fern",
    "quagmire_lamp_post",
    "quagmire_lamp_short",
    "quagmire_parkspike",
    "quagmire_parkspike_short",
    "quagmire_park_gate",

    "quagmire_pebblecrab",
    "quagmire_pond_salt",

    "quagmire_rubble_carriage",
    "quagmire_rubble_clock",
    "quagmire_rubble_cathedral",
    "quagmire_rubble_pubdoor",
    "quagmire_rubble_roof",
    "quagmire_rubble_clocktower",
    "quagmire_rubble_bike",
    "quagmire_rubble_house",
    "quagmire_rubble_chimney",
    "quagmire_rubble_chimney2",
    "quagmire_rubble_empty",

    "quagmire_evergreen",
    "quagmire_mushroomstump",
    "quagmire_swampig_house",
    "quagmire_swampig_house_rubble",
    "quagmire_swampigelder",
    "quagmire_swampig",
    "quagmire_campfire",

    "quagmire_goatmum",
    "quagmire_goatkid",
    "quagmire_beefalo",
    "quagmire_pigeon",

	-- character specific
	"quagmire_book_fertilizer",
    "quagmire_book_shadow",
    "quagmire_cooking_buff",
}

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/world.lua"),

    Asset("SOUND", "sound/quagmire.fsb"),

    Asset("IMAGE", "images/wave.tex"),

    Asset("IMAGE", "levels/tiles/lavaarena_falloff.tex"),
    Asset("FILE", "levels/tiles/lavaarena_falloff.xml"),

    Asset("IMAGE", "images/colour_cubes/quagmire_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/day05_cc.tex"), --default CC at startup
    Asset("IMAGE", "images/colour_cubes/insane_day_cc.tex"), --default insanity CC
    Asset("IMAGE", "images/colour_cubes/lunacy_regular_cc.tex"), --default lunacy CC

    Asset("ANIM", "anim/progressbar_tiny.zip"),

    Asset("ANIM", "anim/frozen.zip"),
    Asset("ANIM", "anim/snow.zip"),

    --Player stuff
    Asset("ANIM", "anim/player_transform_merm.zip"),

    Asset("ATLAS", "images/quagmire_hud.xml"),
    Asset("IMAGE", "images/quagmire_hud.tex"),
    Asset("ANIM", "anim/quagmire_hangry_bar_fx.zip"),
    Asset("ANIM", "anim/quagmire_hangry_bar.zip"),
    Asset("ANIM", "anim/quagmire_hangry_status.zip"),
}

local function common_preinit(inst)
    require("components/quagmire_map") --extends Map component
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

    TheRecipeBook:RegisterWorld(inst)

    --Dedicated server does not require these components
    --NOTE: ambient lighting is required by light watchers
    if not TheNet:IsDedicated() then
        inst.entity:AddWaveComponent()
        inst.WaveComponent:SetWaveParams(13.5, 2.5)                     -- wave texture u repeat, forward distance between waves
        inst.WaveComponent:SetWaveSize(80, 3.5)                         -- wave mesh width and height
        inst.WaveComponent:SetWaveTexture("images/wave.tex")
        inst.WaveComponent:SetWaveEffect("shaders/waves.ksh")           -- See source\game\components\WaveRegion.h

        inst:AddComponent("ambientsound")
        inst.components.ambientsound:SetReverbPreset("default")
        --inst:PushEvent("overrideambientsound", { tile = WORLD_TILES.IMPASSABLE, override = WORLD_TILES.LAVAARENA_FLOOR })

        inst:AddComponent("colourcube")
        inst:PushEvent("overridecolourcube", "images/colour_cubes/quagmire_cc.tex")
        --inst:PushEvent("overridecolourcube", "images/colour_cubes/identity_colourcube.tex")

        inst:ListenForEvent("playeractivated", function(inst, player)
            if ThePlayer == player then
                TheNet:UpdatePlayingWithFriends()
            end
        end)
    end

    local _mod_protect_Recipes = mod_protect_Recipe
    mod_protect_Recipe = false

    --Replace recipes
    RemoveAllRecipes()

    --Mealing Stone
    Recipe("quagmire_flour",                { Ingredient("quagmire_wheat", 2) }, QUAGMIRE_RECIPETABS.QUAGMIRE_MEALINGSTONE, TECH.LOST, nil, nil, true)
    Recipe("quagmire_salt",                 { Ingredient("quagmire_saltrock", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_MEALINGSTONE, TECH.LOST, nil, nil, true, 3)
    Recipe("quagmire_spotspice_ground",     { Ingredient("quagmire_spotspice_sprig", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_MEALINGSTONE, TECH.LOST, nil, nil, true)

    --Goat Mum
    local food_atlas = resolvefilepath("images/quagmire_food_common_inv_images.xml")
    Recipe("quagmire_crate_pot_hanger",     { Ingredient("quagmire_coin1", 6) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("quagmire_crate_oven",           { Ingredient("quagmire_coin1", 6) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("quagmire_crate_grill_small",    { Ingredient("quagmire_coin1", 6) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    --
    Recipe("quagmire_crate_pot_hanger_cs",  { Ingredient("quagmire_coin1", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_crate_pot_hanger")
    Recipe("quagmire_crate_oven_cs",        { Ingredient("quagmire_coin1", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_crate_oven")
    Recipe("quagmire_crate_grill_small_cs", { Ingredient("quagmire_coin1", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_crate_grill_small")
    --
    Recipe("quagmire_plate_silver",         { Ingredient("quagmire_coin2", 2) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_shopper", food_atlas, "plate_silver.tex")
    Recipe("quagmire_bowl_silver",          { Ingredient("quagmire_coin2", 2) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_shopper", food_atlas, "bowl_silver.tex")
    --
    Recipe("quagmire_plate_silver_cs",      { Ingredient("quagmire_coin2", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", food_atlas, "plate_silver.tex", nil, "quagmire_plate_silver")
    Recipe("quagmire_bowl_silver_cs",       { Ingredient("quagmire_coin2", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", food_atlas, "bowl_silver.tex", nil, "quagmire_bowl_silver")
    --
    Recipe("quagmire_goatmilk",             { Ingredient("quagmire_coin3", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true, 3)
    Recipe("quagmire_portal_key",           { Ingredient("quagmire_coin4", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MUM, TECH.LOST, nil, nil, true)

    --Goat Kid
    Recipe("quagmire_pigeon_shop_item",     { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_shopper", nil, nil, nil, "quagmire_pigeon")
    Recipe("quagmire_salt_rack_item",       { Ingredient("quagmire_coin1", 8) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("fishingrod",                    { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("trap",                          { Ingredient("quagmire_coin1", 4) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("birdtrap",                      { Ingredient("quagmire_coin1", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    --
    Recipe("quagmire_pigeon_shop_item_cs",  { Ingredient("quagmire_coin1", 2) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_pigeon")
    Recipe("quagmire_salt_rack_item_cs",    { Ingredient("quagmire_coin1", 7) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_salt_rack_item")
    Recipe("fishingrod_cs",                 { Ingredient("quagmire_coin1", 2) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "fishingrod")
    Recipe("trap_cs",                       { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "trap")
    Recipe("birdtrap_cs",                   { Ingredient("quagmire_coin1", 4) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "birdtrap")
    --
    Recipe("quagmire_crabtrap",             { Ingredient("quagmire_coin3", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true)
    Recipe("quagmire_slaughtertool",        { Ingredient("quagmire_coin3", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID, TECH.LOST, nil, nil, true)

    --Merm
    Recipe("quagmire_seedpacket_2",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)
    Recipe("quagmire_seedpacket_5",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)
    Recipe("quagmire_seedpacket_6",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)
    Recipe("quagmire_seedpacket_4",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)
    Recipe("quagmire_seedpacket_1",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)
    Recipe("quagmire_seedpacket_mix",       { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)
    Recipe("quagmire_key_park",             { Ingredient("quagmire_coin2", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1, TECH.LOST, nil, nil, true)

    --Merm2
    Recipe("quagmire_seedpacket_7",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true)
    Recipe("quagmire_seedpacket_3",         { Ingredient("quagmire_coin1", 1) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true)
    --
    Recipe("quagmire_sapbucket",            { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, 3, "quagmire_shopper")
    Recipe("quagmire_pot_syrup",            { Ingredient("quagmire_coin1", 4) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("quagmire_pot",                  { Ingredient("quagmire_coin1", 4) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("quagmire_casseroledish",        { Ingredient("quagmire_coin1", 4) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    Recipe("quagmire_crate_grill",          { Ingredient("quagmire_coin1", 8) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_shopper")
    --
    Recipe("quagmire_sapbucket_cs",         { Ingredient("quagmire_coin1", 2) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, 3, "quagmire_cheapskate", nil, nil, nil, "quagmire_sapbucket")
    Recipe("quagmire_pot_syrup_cs",         { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_pot_syrup")
    Recipe("quagmire_pot_cs",               { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_pot")
    Recipe("quagmire_casseroledish_cs",     { Ingredient("quagmire_coin1", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_casseroledish")
    Recipe("quagmire_crate_grill_cs",       { Ingredient("quagmire_coin1", 7) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2, TECH.LOST, nil, nil, true, nil, "quagmire_cheapskate", nil, nil, nil, "quagmire_crate_grill")

    --Elder
    Recipe("axe",                           { Ingredient("log", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER, TECH.LOST, nil, nil, true, nil, nil, nil, "axe_victorian.tex").chooseskin = false
    Recipe("shovel",                        { Ingredient("log", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER, TECH.LOST, nil, nil, true, nil, nil, nil, "shovel_victorian.tex").chooseskin = false
    Recipe("quagmire_hoe",                  { Ingredient("log", 5) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER, TECH.LOST, nil, nil, true)
    Recipe("fertilizer",                    { Ingredient("log", 10) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER, TECH.LOST, nil, nil, true)
    Recipe("quagmire_key",                  { Ingredient("quagmire_salt", 3) }, QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER, TECH.LOST, nil, nil, true)

    mod_protect_Recipe = _mod_protect_Recipes
end

local function master_postinit(inst)
    event_server_data("quagmire", "prefabs/quagmire").master_postinit(inst)
end

return MakeWorld("quagmire", prefabs, assets, common_postinit, master_postinit, { "quagmire" }, {common_preinit = common_preinit, tile_physics_init = tile_physics_init})
