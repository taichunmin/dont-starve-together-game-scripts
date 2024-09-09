local prefabs = {}

local assets =
{
    --FE
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits2.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits3.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits4.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits5.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits6.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits7.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/credits8.zip"),
    Asset("PKGREF", "anim/dynamic/credits.dyn"),
    Asset("PKGREF", "anim/dynamic/credits2.dyn"),
    Asset("PKGREF", "anim/dynamic/credits3.dyn"),
    Asset("PKGREF", "anim/dynamic/credits4.dyn"),
    Asset("PKGREF", "anim/dynamic/credits5.dyn"),
    Asset("PKGREF", "anim/dynamic/credits6.dyn"),
    Asset("PKGREF", "anim/dynamic/credits7.dyn"),
    Asset("PKGREF", "anim/dynamic/credits8.dyn"),

    Asset("IMAGE", "images/customisation.tex"),
    Asset("ATLAS", "images/customisation.xml"),

    Asset("IMAGE", "images/worldgen_customization.tex"),
    Asset("ATLAS", "images/worldgen_customization.xml"),
    Asset("IMAGE", "images/worldsettings_customization.tex"),
    Asset("ATLAS", "images/worldsettings_customization.xml"),

    --BETA
    Asset("DYNAMIC_ATLAS", "images/anr_silhouettes.xml"),
    Asset("PKGREF", "images/anr_silhouettes.tex"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/quagmire_countdown2.zip"),
    Asset("PKGREF", "anim/dynamic/quagmire_countdown2.dyn"),

    Asset("ATLAS", "images/frontscreen.xml"),
    Asset("IMAGE", "images/frontscreen.tex"),

    -- Asset("ANIM", "anim/portrait_frame.zip"), -- Not currently used, but likely to come back

    Asset("ANIM", "anim/build_status.zip"),

    -- Swirly fire frontend menu background
    --~ Asset("ANIM", "anim/animated_title.zip"), -- Not currently used, but likely to come back
    --~ Asset("ANIM", "anim/animated_title2.zip"), -- Not currently used, but likely to come back
    --~ Asset("ANIM", "anim/title_fire.zip"), -- Not currently used, but likely to come back

    -- Used by TEMPLATES.Background
    -- Asset("ATLAS", "images/bg_color.xml"), -- Not currently used, but likely to come back
    -- Asset("IMAGE", "images/bg_color.tex"), -- Not currently used, but likely to come back

    Asset("ATLAS", "images/server_intentions.xml"),
    Asset("IMAGE", "images/server_intentions.tex"),

    Asset("ATLAS", "images/serverplaystyles.xml"),
    Asset("IMAGE", "images/serverplaystyles.tex"),

    Asset("DYNAMIC_ATLAS", "images/new_host_picker.xml"),
    Asset("PKGREF", "images/new_host_picker.tex"),

    Asset("FILE", "images/motd_box1.xml"),
    Asset("FILE", "images/motd_box2.xml"),
    Asset("FILE", "images/motd_box3.xml"),
    Asset("FILE", "images/motd_box4.xml"),
    Asset("FILE", "images/motd_box5.xml"),
    Asset("FILE", "images/motd_box6.xml"),
    Asset("FILE", "images/motd_box7.xml"),
    Asset("FILE", "images/motd_box8.xml"),
    Asset("FILE", "images/motd_box9.xml"),
    Asset("FILE", "images/motd_box10.xml"),
    Asset("DYNAMIC_ATLAS", "images/motd_fallbacks_box1.xml"),
    Asset("PKGREF", "images/motd_fallbacks_box1.tex"),
    Asset("DYNAMIC_ATLAS", "images/motd_fallbacks_box2.xml"),
    Asset("PKGREF", "images/motd_fallbacks_box2.tex"),
    Asset("DYNAMIC_ATLAS", "images/motd_fallbacks_box3.xml"),
    Asset("PKGREF", "images/motd_fallbacks_box3.tex"),
    Asset("DYNAMIC_ATLAS", "images/motd_fallbacks_box4.xml"),
    Asset("PKGREF", "images/motd_fallbacks_box4.tex"),
    Asset("DYNAMIC_ATLAS", "images/motd_fallbacks_box5.xml"),
    Asset("PKGREF", "images/motd_fallbacks_box5.tex"),
    Asset("DYNAMIC_ATLAS", "images/motd_fallbacks_box6.xml"),
    Asset("PKGREF", "images/motd_fallbacks_box6.tex"),

    Asset("ATLAS", "images/bg_redux_dark_bottom.xml"),
    Asset("IMAGE", "images/bg_redux_dark_bottom.tex"),
    Asset("ATLAS", "images/bg_redux_dark_bottom_solid.xml"),
    Asset("IMAGE", "images/bg_redux_dark_bottom_solid.tex"),
	Asset("ATLAS", "images/bg_redux_dark_bottom_vignette1.xml"),
	Asset("IMAGE", "images/bg_redux_dark_bottom_vignette1.tex"),
	Asset("ATLAS", "images/bg_redux_motd_frame_small_gold.xml"),
	Asset("IMAGE", "images/bg_redux_motd_frame_small_gold.tex"),
	Asset("ATLAS", "images/bg_redux_motd_frame_small_gold2.xml"),
	Asset("IMAGE", "images/bg_redux_motd_frame_small_gold2.tex"),
	Asset("ATLAS", "images/bg_redux_motd_frame_large_gold.xml"),
	Asset("IMAGE", "images/bg_redux_motd_frame_large_gold.tex"),
	Asset("ATLAS", "images/bg_redux_black_sidebar.xml"),
	Asset("IMAGE", "images/bg_redux_black_sidebar.tex"),

    --character portraits
    Asset("ATLAS", "images/saveslot_portraits.xml"),
    Asset("IMAGE", "images/saveslot_portraits.tex"),

    Asset("ATLAS", "bigportraits/unknownmod.xml"),
    Asset("IMAGE", "bigportraits/unknownmod.tex"),

    --V2C: originally in global, for old options and controls screens
    Asset("DYNAMIC_ATLAS", "images/bg_plain.xml"),
    Asset("PKGREF", "images/bg_plain.tex"),

    -- Collections screen
    Asset("ANIM", "anim/player_progressbar_large.zip"),
    Asset("ANIM", "anim/player_progressbar_small.zip"),
    Asset("ANIM", "anim/skin_progressbar.zip"),
    Asset("ANIM", "anim/player_emotes.zip"), -- item emotes
    Asset("ANIM", "anim/player_emote_extra.zip"), -- item emotes
    Asset("ANIM", "anim/player_emotes_dance0.zip"),
    Asset("ANIM", "anim/player_emotes_dance2.zip"), -- item emotes
    Asset("ANIM", "anim/player_emotes_sit.zip"),
    Asset("ANIM", "anim/player_actions_item.zip"),
    Asset("ANIM", "anim/player_idles_warly.zip"),
    Asset("ANIM", "anim/player_idles_wendy.zip"),
    Asset("ANIM", "anim/player_idles_willow.zip"),
    Asset("ANIM", "anim/player_idles_winona.zip"),
    Asset("ANIM", "anim/player_idles_woodie.zip"),
    Asset("ANIM", "anim/player_idles_wormwood.zip"),
    Asset("ANIM", "anim/player_idles_wortox.zip"),
    Asset("ANIM", "anim/player_idles_wurt.zip"),
    Asset("ANIM", "anim/player_idles_wathgrithr.zip"),
    Asset("ANIM", "anim/player_idles_wes.zip"),
    Asset("ANIM", "anim/player_idles_webber.zip"),
    Asset("ANIM", "anim/player_idles_wanda.zip"),
    Asset("ANIM", "anim/player_idles_wx.zip"),
    Asset("ANIM", "anim/player_idles_wonkey.zip"),
    Asset("ANIM", "anim/player_idles_wickerbottom.zip"),
    Asset("ANIM", "anim/player_idles_waxwell.zip"),
    Asset("ANIM", "anim/player_idles_wilson.zip"),    
    Asset("ANIM", "anim/bernie_build.zip"),
    Asset("ANIM", "anim/swap_lucy_axe.zip"),

    -- Wardrobe
    Asset("ANIM", "anim/player_emotesxl.zip"), -- idle emote animations

    -- Skill tree
    Asset("ANIM", "anim/skills_activate.zip"),
    Asset("ANIM", "anim/skill_unlock.zip"),


    -- Unused and deprecated. Keeping for mods.
    Asset("DYNAMIC_ATLAS", "images/skinsscreen.xml"),
    Asset("PKGREF", "images/skinsscreen.tex"),
    Asset("DYNAMIC_ATLAS", "images/serverbrowser.xml"),
    Asset("PKGREF", "images/serverbrowser.tex"),
    --

    Asset("ATLAS", "images/tradescreen.xml"),
    Asset("IMAGE", "images/tradescreen.tex"),
    Asset("ATLAS", "images/tradescreen_overflow.xml"),
    Asset("IMAGE", "images/tradescreen_overflow.tex"),

    -- Only used when tradescreen is closed
    Asset("DYNAMIC_ATLAS", "images/tradescreen_redux.xml"),
    Asset("PKGREF", "images/tradescreen_redux.tex"),

    -- Used by the infrequent ThankYouPopup.
    Asset("DYNAMIC_ATLAS", "images/lobbyscreen.xml"),
    Asset("PKGREF", "images/lobbyscreen.tex"),


    Asset("ANIM", "anim/mod_player_build.zip"),

    Asset("ANIM", "anim/swapshoppe.zip"),
    Asset("ANIM", "anim/swapshoppe_bg.zip"),
    Asset("ANIM", "anim/joystick.zip"),
    Asset("ANIM", "anim/button.zip"),
    Asset("ANIM", "anim/shoppe_frames.zip"),
    Asset("ANIM", "anim/skin_collector.zip"),
    Asset("ANIM", "anim/textbox.zip"),

    Asset("ANIM", "anim/kleipoints.zip"),

    Asset("ANIM", "anim/chest_bg.zip"),

    Asset("ANIM", "anim/puff_spawning.zip"),

	-- hard coded MotD for upsell (TODO: maybe try to fix this once we do proper MotD for non-Steam)
   	Asset("DYNAMIC_ATLAS", "images/stats_panel_motd.xml"),
   	Asset("PKGREF", "images/stats_panel_motd.tex"),

    --Credits screen
    Asset("SOUND", "sound/gramaphone.fsb"),

    --FE Music
    Asset("PKGREF", "sound/music_frontend.fsb"),

    Asset("PKGREF", "movies/intro.ogv"),


    --Including these here as well as global to ensure the exporter's resizing dependency works
    Asset("DYNAMIC_ANIM", "anim/dynamic/box_shared_spiral.zip"),
    Asset("PKGREF", "anim/dynamic/box_shared_spiral.dyn"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/box_shared.zip"),
    Asset("PKGREF", "anim/dynamic/box_shared.dyn"),


    Asset("DYNAMIC_ANIM", "anim/dynamic/box_bolt.zip"),
    Asset("PKGREF", "anim/dynamic/box_bolt.dyn"),


    --Mini Game Assets
    Asset("ANIM", "anim/crow_kids.zip"),
    Asset("ANIM", "anim/crow.zip"),
    Asset("ANIM", "anim/crow_build.zip"),
    Asset("ANIM", "anim/robin_winter_build.zip"),
    Asset("ANIM", "anim/robin_build.zip"),
    Asset("ANIM", "anim/explode.zip"),
    Asset("ANIM", "anim/minigametile.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_egg.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_egg_rotten.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_crow.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_snowbird.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_chevron_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_dotted_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_flower_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_foil_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_paper_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_striped_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_bluestriped_wrapper.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_roastturkey.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_gravy.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_berrysauce.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/oddment_pumpkinpie.zip"),
    Asset("PKGREF", "anim/dynamic/oddment_egg.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_egg_rotten.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_crow.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_snowbird.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_chevron_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_dotted_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_flower_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_foil_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_paper_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_striped_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_bluestriped_wrapper.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_roastturkey.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_gravy.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_berrysauce.dyn"),
    Asset("PKGREF", "anim/dynamic/oddment_pumpkinpie.dyn"),
    Asset("DYNAMIC_ATLAS", "images/maze.xml"),
    Asset("ASSET_PKGREF", "images/maze.tex"),
    
    Asset("ANIM", "anim/kitcoon_nametag.zip"),   
    Asset("ANIM", "anim/kitcoon_forest_build.zip"),
    Asset("ANIM", "anim/kitcoon_savanna_build.zip"),
    Asset("ANIM", "anim/kitcoon_deciduous_build.zip"),
    Asset("ANIM", "anim/kitcoon_marsh_build.zip"),
    Asset("ANIM", "anim/kitcoon_grass_build.zip"),
    Asset("ANIM", "anim/kitcoon_rocky_build.zip"),
    Asset("ANIM", "anim/kitcoon_desert_build.zip"),
    Asset("ANIM", "anim/kitcoon_moon_build.zip"),
    Asset("ANIM", "anim/kitcoon_yot_build.zip"), 
    Asset("ANIM", "anim/kitcoon_basic.zip"),
    Asset("ANIM", "anim/kitcoon_emotes.zip"),
    Asset("ANIM", "anim/kitcoon_traits.zip"),
    Asset("ANIM", "anim/kitcoon_jump.zip"),
    Asset("ANIM", "anim/kitcoon_poop.zip"),
    Asset("ANIM", "anim/kitcoon_food.zip"),
    Asset("ANIM", "anim/kitcoon_pouch.zip"),
    Asset("ANIM", "anim/kitcoon_bg.zip"),
    Asset("IMAGE", "images/colour_cubes/day05_cc.tex"),
    Asset("IMAGE", "images/colour_cubes/dusk03_cc.tex"),
}

--Including these here as well as global to ensure the exporter's resizing dependency works
for item,data in pairs(MISC_ITEMS) do
	if data.box_build ~= nil then
		table.insert(assets, Asset("DYNAMIC_ANIM", "anim/dynamic/" .. data.box_build .. ".zip"))
		table.insert(assets, Asset("PKGREF", "anim/dynamic/" .. data.box_build .. ".dyn"))
	end
end


local SkinGifts = require("skin_gifts")
for gifttype,data in pairs(SkinGifts.popupdata) do
    table.insert(assets, Asset("DYNAMIC_ATLAS", data.atlas))
    table.insert(assets, Asset("PKGREF", data.atlas:gsub(".xml", ".tex")))
end


if IsConsole() then
	if TRUE_DEDICATED_SERVER == false then
	    table.insert(assets, Asset("ATLAS", "images/ui_ps4.xml"))
	    table.insert(assets, Asset("IMAGE", "images/ui_ps4.tex"))
	end

	if IsPS4() then
		table.insert(assets, Asset("ATLAS", "images/ps4.xml"))
		table.insert(assets, Asset("IMAGE", "images/ps4.tex"))
		table.insert(assets, Asset("ATLAS", "images/ps4_controllers.xml"))
		table.insert(assets, Asset("IMAGE", "images/ps4_controllers.tex"))
	elseif IsXB1() then
		table.insert(assets, Asset("ATLAS", "images/xb1_controllers.xml"))
		table.insert(assets, Asset("IMAGE", "images/xb1_controllers.tex"))
		table.insert(assets, Asset("ATLAS", "images/blit.xml"))
		table.insert(assets, Asset("IMAGE", "images/blit.tex"))
	elseif IsSWITCH() then
		table.insert(assets, Asset("ATLAS", "images/nx_controllers.xml"))
		table.insert(assets, Asset("IMAGE", "images/nx_controllers.tex"))
		table.insert(assets, Asset("ATLAS", "images/nx.xml"))
		table.insert(assets, Asset("IMAGE", "images/nx.tex"))
	else
		assert(0) -- Add platform
	end
end

--Uncomment whichever platfor you need for testing dev_test_platform in optionsscreen.lua
--table.insert(assets, Asset("ATLAS", "images/ps4_controllers.xml"))
--table.insert(assets, Asset("IMAGE", "images/ps4_controllers.tex"))
--table.insert(assets, Asset("ATLAS", "images/xb1_controllers.xml"))
--table.insert(assets, Asset("IMAGE", "images/xb1_controllers.tex"))
--table.insert(assets, Asset("ATLAS", "images/nx_controllers.xml"))
--table.insert(assets, Asset("IMAGE", "images/nx_controllers.tex"))


if PLATFORM == "WIN32_RAIL" then
    table.insert(assets, Asset("DYNAMIC_ATLAS", "images/rail.xml") )
    table.insert(assets, Asset("ASSET_PKGREF", "images/rail.tex") )
end

for i, v in pairs(MAINSCREEN_TOOL_LIST) do
    if v ~= "" then
        table.insert(assets, Asset("ANIM", "anim/"..v..".zip"))
    end
end

for i, v in pairs(MAINSCREEN_TORSO_LIST) do
    if v ~= "" then
        table.insert(assets, Asset("ANIM", "anim/"..v..".zip"))
    end
end

for i, v in pairs(MAINSCREEN_HAT_LIST) do
    if v ~= "" then
        table.insert(assets, Asset("ANIM", "anim/"..v..".zip"))
    end
end

--Quagmire specific, but needed in the non-event UI now for the player summary recipe book
table.insert( assets, Asset("IMAGE", "images/colour_cubes/quagmire_cc.tex") )
if not QUAGMIRE_USE_KLUMP then
    for i = 1, QUAGMIRE_NUM_FOOD_PREFABS do
        local name = string.format("quagmire_food_%03i", i)
        table.insert( assets, Asset("DYNAMIC_ATLAS", "images/quagmire_food_inv_images_hires_"..name..".xml") )
        table.insert( assets, Asset("PKGREF", "images/quagmire_food_inv_images_hires_"..name..".tex") )
    end
end

-- adding these here so they can be used in the FrontEnd
table.insert( assets, Asset("ANIM", "anim/trophyscale_oversizedveggies.zip") )
for k, v in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
	table.insert(prefabs, v.prefab)
end
for k, v in pairs(require("prefabs/weed_defs").WEED_DEFS) do
	table.insert(prefabs, v.prefab)
end

-- Testing and viewing skins on a more close level.
if CAN_USE_DBUI then
    require("dbui_no_package/debug_skins_data/hooks").Hooks("frontend", assets)
end

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn()
    return CreateEntity()
end

return Prefab("frontend", fn, assets, prefabs)
