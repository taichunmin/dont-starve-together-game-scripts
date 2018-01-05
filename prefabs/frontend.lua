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

    Asset("IMAGE", "images/customisation.tex"),
    Asset("ATLAS", "images/customisation.xml"),

    --BETA
    Asset("DYNAMIC_ATLAS", "images/anr_silhouettes.xml"),
    Asset("PKGREF", "images/anr_silhouettes.tex"),

    Asset("ATLAS", "images/frontscreen.xml"),
    Asset("IMAGE", "images/frontscreen.tex"),

    Asset("ATLAS", "images/frontend_redux.xml"),
    Asset("IMAGE", "images/frontend_redux.tex"),

    -- Asset("ANIM", "anim/portrait_frame.zip"), -- Not currently used, but likely to come back

    Asset("ANIM", "anim/build_status.zip"),

    -- normal menu background
    --Asset("ANIM", "anim/dst_menu.zip"),
    Asset("ANIM", "anim/dst_menu_feast.zip"),
    Asset("ANIM", "anim/dst_menu_feast_bg.zip"),

    -- lavaarena festival event
    Asset("ANIM", "anim/main_menu1.zip"),
    Asset("ATLAS", "images/bg_redux_labg.xml"),
    Asset("IMAGE", "images/bg_redux_labg.tex"),
    Asset("ATLAS", "images/fepanels_redux_event_goals_panel.xml"),
    Asset("IMAGE", "images/fepanels_redux_event_goals_panel.tex"),
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

    Asset("ATLAS", "images/new_host_picker.xml"),
    Asset("IMAGE", "images/new_host_picker.tex"),

    Asset("FILE", "images/motd.xml"),

    --character portraits
    Asset("ATLAS", "images/saveslot_portraits.xml"),
    Asset("IMAGE", "images/saveslot_portraits.tex"),

    Asset("ATLAS", "bigportraits/unknownmod.xml"),
    Asset("IMAGE", "bigportraits/unknownmod.tex"),

    --V2C: originally in global, for old options and controls screens
    Asset("ATLAS", "images/bg_plain.xml"),
    Asset("IMAGE", "images/bg_plain.tex"),

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

    Asset("ANIM", "anim/skinevent_popup_spiral.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/skinevent_popup.zip"), --needed for the mystery and purchase box opening animation (happens to contain the forge box build too)
    
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
    -- TODO(dbriscoe): Finish replacing frames_comp with accountitem_frame and remove.
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
    Asset("DYNAMIC_ATLAS", "images/thankyou_item_popup_rog.xml"),
    Asset("PKGREF", "images/thankyou_item_popup_rog.tex"),

    --Credits screen
    Asset("SOUND", "sound/gramaphone.fsb"),

    --FE Music
    Asset("PKGREF", "sound/music_frontend.fsb"),

    Asset("PKGREF", "movies/intro.ogv"),
}

if PLATFORM == "PS4" then
    table.insert(assets, Asset("ATLAS", "images/ps4.xml"))
    table.insert(assets, Asset("IMAGE", "images/ps4.tex"))
    table.insert(assets, Asset("ATLAS", "images/ps4_controllers.xml"))
    table.insert(assets, Asset("IMAGE", "images/ps4_controllers.tex"))
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
