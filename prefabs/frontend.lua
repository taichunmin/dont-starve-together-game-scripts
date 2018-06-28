local assets =
{
	Asset("ATLAS", "images/quagmire_food_common_inv_images.xml"),
	Asset("ATLAS", "images/quagmire_food_common_inv_images_hires.xml"),

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

    --BETA
    Asset("DYNAMIC_ATLAS", "images/anr_silhouettes.xml"),
    Asset("PKGREF", "images/anr_silhouettes.tex"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/quagmire_countdown2.zip"),
    Asset("PKGREF", "anim/dynamic/quagmire_countdown2.dyn"),

    Asset("ATLAS", "images/frontscreen.xml"),
    Asset("IMAGE", "images/frontscreen.tex"),
        
    -- Asset("ANIM", "anim/portrait_frame.zip"), -- Not currently used, but likely to come back

    Asset("ANIM", "anim/build_status.zip"),

    Asset("ATLAS", "images/fepanels_redux_shop_panel.xml"),
    Asset("IMAGE", "images/fepanels_redux_shop_panel.tex"),
    Asset("ATLAS", "images/fepanels_redux_shop_panel_wide.xml"),
    Asset("IMAGE", "images/fepanels_redux_shop_panel_wide.tex"),

    -- Swirly fire frontend menu background
    --~ Asset("ANIM", "anim/animated_title.zip"), -- Not currently used, but likely to come back
    --~ Asset("ANIM", "anim/animated_title2.zip"), -- Not currently used, but likely to come back
    --~ Asset("ANIM", "anim/title_fire.zip"), -- Not currently used, but likely to come back

    -- Used by TEMPLATES.Background
    -- Asset("ATLAS", "images/bg_color.xml"), -- Not currently used, but likely to come back
    -- Asset("IMAGE", "images/bg_color.tex"), -- Not currently used, but likely to come back

    Asset("ATLAS", "images/servericons.xml"),
    Asset("IMAGE", "images/servericons.tex"),

    Asset("ATLAS", "images/server_intentions.xml"),
    Asset("IMAGE", "images/server_intentions.tex"),

    Asset("DYNAMIC_ATLAS", "images/new_host_picker.xml"),
    Asset("PKGREF", "images/new_host_picker.tex"),

    Asset("FILE", "images/motd.xml"),

    --character portraits
    Asset("ATLAS", "images/saveslot_portraits.xml"),
    Asset("IMAGE", "images/saveslot_portraits.tex"),

    Asset("ATLAS", "bigportraits/unknownmod.xml"),
    Asset("IMAGE", "bigportraits/unknownmod.tex"),

    --V2C: originally in global, for old options and controls screens
    Asset("DYNAMIC_ATLAS", "images/bg_plain.xml"),
    Asset("PKGREF", "images/bg_plain.tex"),

    -- Collections screen
    Asset("ANIM", "anim/spool.zip"), -- doodads
    Asset("ANIM", "anim/player_progressbar_large.zip"),
    Asset("ANIM", "anim/player_progressbar_small.zip"),
    Asset("ANIM", "anim/skin_progressbar.zip"),
    Asset("ANIM", "anim/player_emotes.zip"), -- item emotes
    Asset("ANIM", "anim/player_emote_extra.zip"), -- item emotes
    Asset("ANIM", "anim/player_emotes_dance2.zip"), -- item emotes
    -- If we want nonitem emotes, we need these too.
    --~ Asset("ANIM", "anim/player_emotes_dance0.zip"),
    --~ Asset("ANIM", "anim/player_emotes_sit.zip"),

    -- Wardrobe
    Asset("ANIM", "anim/player_emotesxl.zip"), -- idle emote animations

    -- Unused and deprecated. Keeping for mods.
    Asset("DYNAMIC_ATLAS", "images/skinsscreen.xml"),
    Asset("PKGREF", "images/skinsscreen.tex"),
    Asset("DYNAMIC_ATLAS", "images/serverbrowser.xml"),
    Asset("PKGREF", "images/serverbrowser.tex"),
    --

    Asset("DYNAMIC_ANIM", "anim/dynamic/box_shared_spiral.zip"),
    Asset("PKGREF", "anim/dynamic/box_shared_spiral.dyn"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/box_shared.zip"), --needed for the mystery and purchase box opening animation (happens to contain the forge box build too)
    Asset("PKGREF", "anim/dynamic/box_shared.dyn"),
    
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

    --testing 
    Asset("ATLAS", "images/inventoryimages.xml"),
    Asset("IMAGE", "images/inventoryimages.tex"),

    Asset("ANIM", "anim/mod_player_build.zip"),

    Asset("ANIM", "anim/accountitem_frame.zip"),
    -- If we replace frames_comp with accountitem_frame, we can remove.
    Asset("ANIM", "anim/frames_comp.zip"),
    Asset("ANIM", "anim/frame_bg.zip"),

    -- DISABLE SPECIAL RECIPES
    --Asset("ANIM", "anim/button_weeklyspecial.zip"),

    Asset("ANIM", "anim/swapshoppe.zip"),

    -- DISABLE SPECIAL RECIPES
    --Asset("ANIM", "anim/swapshoppe_special_build.zip"),
    --Asset("ANIM", "anim/swapshoppe_special_lightfx.zip"),
    --Asset("ANIM", "anim/swapshoppe_special_transitionfx.zip"),

    Asset("ANIM", "anim/swapshoppe_bg.zip"),
    Asset("ANIM", "anim/joystick.zip"),
    Asset("ANIM", "anim/button.zip"),
    Asset("ANIM", "anim/shoppe_frames.zip"),
    Asset("ANIM", "anim/skin_collector.zip"),
    Asset("ANIM", "anim/textbox.zip"),

    Asset("ANIM", "anim/chest_bg.zip"),

    Asset("ANIM", "anim/puff_spawning.zip"),

    Asset("DYNAMIC_ATLAS", "images/thankyou_item_popup.xml"),
    Asset("PKGREF", "images/thankyou_item_popup.tex"),
    Asset("DYNAMIC_ATLAS", "images/thankyou_item_event.xml"),
    Asset("PKGREF", "images/thankyou_item_event.tex"),
    Asset("DYNAMIC_ATLAS", "images/thankyou_item_event2.xml"),
    Asset("PKGREF", "images/thankyou_item_event2.tex"),
    Asset("DYNAMIC_ATLAS", "images/thankyou_item_popup_rog.xml"),
    Asset("PKGREF", "images/thankyou_item_popup_rog.tex"),

    --Credits screen
    Asset("SOUND", "sound/gramaphone.fsb"),

    --FE Music
    Asset("PKGREF", "sound/music_frontend.fsb"),

    Asset("PKGREF", "movies/intro.ogv"),
}

if IsConsole() then
	if TRUE_DEDICATED_SERVER == false then
	    table.insert(assets, Asset("ATLAS", "images/ui_ps4.xml"))
	    table.insert(assets, Asset("IMAGE", "images/ui_ps4.tex"))
	end
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
end

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

local prefabs = {}

--Skins assets
for _, clothing_asset in pairs(require("clothing_assets")) do
    table.insert(assets, clothing_asset)
end

for item,data in pairs(MISC_ITEMS) do
	if data.box_build ~= nil then
		table.insert(assets, Asset("DYNAMIC_ANIM", "anim/dynamic/" .. data.box_build .. ".zip"))
		table.insert(assets, Asset("PKGREF", "anim/dynamic/" .. data.box_build .. ".dyn"))
	end
	
	if data.featured_pack then
		if data.display_atlas == nil or data.display_tex == nil then
			print( "Invalid pack data:", item, data.display_atlas, data.display_tex )
		end
		
		table.insert(assets, Asset("DYNAMIC_ATLAS", data.display_atlas ))
		table.insert(assets, Asset("PKGREF", "images/iap_images_"..data.display_tex ))
	end
end

for _, skins_prefabs in pairs(PREFAB_SKINS) do
    for _, skin_prefab in pairs(skins_prefabs) do
        table.insert(prefabs, skin_prefab)
    end
end

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn()
    return CreateEntity()
end

return Prefab("frontend", fn, assets, prefabs)
