local assets =
{
    Asset("PKGREF", "sound/dontstarve.fev"),
    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC001.fev"),
    Asset("FILE", "sound/DLC_music.fsb"),
    Asset("SOUNDPACKAGE", "sound/turnoftides.fev"),
    Asset("FILE", "sound/turnoftides.fsb"),

    Asset("FILE", "sound/wilton.fsb"),         -- Legacy sound that can be used in mods
    Asset("FILE", "sound/winnie.fsb"),         -- Legacy sound that can be used in mods
    Asset("FILE", "sound/wallace.fsb"),        -- Legacy sound that can be used in mods
    Asset("FILE", "sound/woodrow.fsb"),        -- Legacy sound that can be used in mods
    Asset("FILE", "sound/stuff.fsb"),          -- Legacy sound that can be used in mods


    -- Legacy for modders to view. These files are now dynamically loaded.
    Asset("PKGREF", "anim/ghost_wathgrithr_build.zip"),
    Asset("PKGREF", "anim/ghost_waxwell_build.zip"),
    Asset("PKGREF", "anim/ghost_webber_build.zip"),
    Asset("PKGREF", "anim/ghost_wendy_build.zip"),
    Asset("PKGREF", "anim/ghost_werebeaver_build.zip"),
    Asset("PKGREF", "anim/ghost_wes_build.zip"),
    Asset("PKGREF", "anim/ghost_wickerbottom_build.zip"),
    Asset("PKGREF", "anim/ghost_willow_build.zip"),
    Asset("PKGREF", "anim/ghost_wilson_build.zip"),
    Asset("PKGREF", "anim/ghost_winona_build.zip"),
    Asset("PKGREF", "anim/ghost_wolfgang_build.zip"),
    Asset("PKGREF", "anim/ghost_woodie_build.zip"),
    Asset("PKGREF", "anim/ghost_wx78_build.zip"),
    Asset("PKGREF", "anim/wathgrithr.zip"),
    Asset("PKGREF", "anim/waxwell.zip"),
    Asset("PKGREF", "anim/webber.zip"),
    Asset("PKGREF", "anim/wendy.zip"),
    Asset("PKGREF", "anim/werebeaver_build.zip"),
    Asset("PKGREF", "anim/wes.zip"),
    Asset("PKGREF", "anim/wickerbottom.zip"),
    Asset("PKGREF", "anim/willow.zip"),
    Asset("PKGREF", "anim/wilson.zip"),
    Asset("PKGREF", "anim/winona.zip"),
    Asset("PKGREF", "anim/wolfgang.zip"),
    Asset("PKGREF", "anim/wolfgang_mighty.zip"),
    Asset("PKGREF", "anim/wolfgang_skinny.zip"),
    Asset("PKGREF", "anim/woodie.zip"),
    Asset("PKGREF", "anim/wx78.zip"),



    Asset("ATLAS", "images/global.xml"),
    Asset("IMAGE", "images/global.tex"),
    Asset("IMAGE", "images/visited.tex"),
    Asset("ANIM", "anim/scroll_arrow.zip"),

    Asset("SHADER", "shaders/anim_bloom.ksh"),
    Asset("SHADER", "shaders/anim_bloom_ghost.ksh"),
    Asset("SHADER", "shaders/road.ksh"),

    Asset("IMAGE", "images/shadow.tex"),
    Asset("IMAGE", "images/erosion.tex"),
    Asset("IMAGE", "images/circle.tex"),
    Asset("IMAGE", "images/square.tex"),
    Asset("IMAGE", "images/trans.tex"),

    Asset("DYNAMIC_ATLAS", "images/fepanels.xml"),
    Asset("PKGREF", "images/fepanels.tex"),
    
    --item explorer stuff in and out of game
    Asset("ANIM", "anim/bolt_of_cloth.zip"),
    Asset("ANIM", "anim/spool.zip"),
    Asset("ANIM", "anim/frame_bg.zip"),
    Asset("ANIM", "anim/accountitem_frame.zip"),
    Asset("ANIM", "anim/frames_comp.zip"), -- If we replace frames_comp with accountitem_frame, we can remove.

    --IAP shop is accessible in FE and in in-game lobby
    Asset("DYNAMIC_ATLAS", "images/fepanels_redux.xml"),
    Asset("PKGREF", "images/fepanels_redux.tex"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/box_shared_spiral.zip"),
    Asset("PKGREF", "anim/dynamic/box_shared_spiral.dyn"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/box_shared.zip"), --needed for the mystery and purchase box opening animation (happens to contain the forge box build too)
    Asset("PKGREF", "anim/dynamic/box_shared.dyn"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/box_bolt.zip"),
    Asset("PKGREF", "anim/dynamic/box_bolt.dyn"),

    -- Used in event join flow and in-game victory.
    Asset("ATLAS", "images/dialogcurly_9slice.xml"),
    Asset("IMAGE", "images/dialogcurly_9slice.tex"),

    -- Used for motd and options
    Asset("ATLAS", "images/dialogrect_9slice.xml"),
    Asset("IMAGE", "images/dialogrect_9slice.tex"),

    Asset("DYNAMIC_ATLAS", "images/lavaarena_achievements.xml"),
    Asset("PKGREF", "images/lavaarena_achievements.tex"),

	Asset("ATLAS", "images/lavaarena_unlocks.xml"),
	Asset("IMAGE", "images/lavaarena_unlocks.tex"),

	Asset("ATLAS", "images/lavaarena_unlocks2.xml"),
	Asset("IMAGE", "images/lavaarena_unlocks2.tex"),

	Asset("ATLAS", "images/lavaarena_quests.xml"),
	Asset("IMAGE", "images/lavaarena_quests.tex"),

    Asset("DYNAMIC_ATLAS", "images/quagmire_food_common_inv_images_hires.xml"),
    Asset("PKGREF", "images/quagmire_food_common_inv_images_hires.tex"),

    Asset("ATLAS", "images/quagmire_achievements.xml"),
    Asset("IMAGE", "images/quagmire_achievements.tex"),

    Asset("ATLAS", "images/quagmire_recipebook.xml"),
    Asset("IMAGE", "images/quagmire_recipebook.tex"),

    Asset("DYNAMIC_ATLAS", "images/options.xml"),
    Asset("PKGREF", "images/options.tex"),
    Asset("DYNAMIC_ATLAS", "images/options_bg.xml"),
    Asset("PKGREF", "images/options_bg.tex"),

    Asset("ATLAS", "images/frontend.xml"),
    Asset("IMAGE", "images/frontend.tex"),
    Asset("ATLAS", "images/frontend_redux.xml"),
    Asset("IMAGE", "images/frontend_redux.tex"),

    Asset("ATLAS", "images/bg_spiral.xml"),
    Asset("IMAGE", "images/bg_spiral.tex"),
    Asset("ATLAS", "images/bg_vignette.xml"),
    Asset("IMAGE", "images/bg_vignette.tex"),
    Asset("ANIM", "anim/sail_over.zip"),
    Asset("ANIM", "anim/paddle_over.zip"),


    Asset("DYNAMIC_ATLAS", "images/fepanel_fills.xml"),
    Asset("PKGREF", "images/fepanel_fills.tex"),

    Asset("ATLAS", "images/bg_redux_dark_right.xml"),
    Asset("IMAGE", "images/bg_redux_dark_right.tex"),
    Asset("ATLAS", "images/bg_redux_dark_sidebar.xml"),
    Asset("IMAGE", "images/bg_redux_dark_sidebar.tex"),

    -- Old portal frontend background from before The Forge UI update. Still
    -- used on tradescreen.
    --Note(Peter):try moving this to the frontend prefab
    Asset("DYNAMIC_ATLAS", "images/bg_animated_portal.xml"),
    Asset("PKGREF", "images/bg_animated_portal.tex"),
    Asset("DYNAMIC_ATLAS", "images/fg_animated_portal.xml"),
    Asset("PKGREF", "images/fg_animated_portal.tex"),
    Asset("DYNAMIC_ATLAS", "images/fg_trees.xml"),
    Asset("PKGREF", "images/fg_trees.tex"),
    --

    Asset("ANIM", "anim/portal_scene2.zip"),
    Asset("ANIM", "anim/portal_scene_steamfxbg.zip"),
    Asset("ANIM", "anim/portal_scene2_inside.zip"),
    Asset("ANIM", "anim/portal_scene_steamfxeast.zip"),
    Asset("ANIM", "anim/portal_scene_steamfxwest.zip"),
    Asset("ANIM", "anim/portal_scene_steamfxsouth.zip"),
    Asset("ANIM", "anim/cloud_build.zip"),

    --Asset("IMAGE", "images/river_bed.tex"),
    --Asset("IMAGE", "images/water_river.tex"),
    Asset("IMAGE", "images/pathnoise.tex"),
    Asset("IMAGE", "images/mini_pathnoise.tex"),
    Asset("IMAGE", "images/roadnoise.tex"),
    Asset("IMAGE", "images/roadedge.tex"),
    Asset("IMAGE", "images/roadcorner.tex"),
    Asset("IMAGE", "images/roadendcap.tex"),

    --TODO(YOG): Why does this get unloaded a the wrong time if we load it as part of the forest prefab?
    Asset("IMAGE", "images/overlays_lunacy.tex"),

    Asset("IMAGE", "images/colour_cubes/identity_colourcube.tex"),

    Asset("SHADER", "shaders/anim.ksh"),
    Asset("SHADER", "shaders/anim_fade.ksh"),
    Asset("SHADER", "shaders/anim_bloom.ksh"),
    Asset("SHADER", "shaders/blurh.ksh"),
    Asset("SHADER", "shaders/blurv.ksh"),
    Asset("SHADER", "shaders/creep.ksh"),
    Asset("SHADER", "shaders/debug_line.ksh"),
    Asset("SHADER", "shaders/debug_tri.ksh"),
    Asset("SHADER", "shaders/render_depth.ksh"),
    Asset("SHADER", "shaders/font.ksh"),
    Asset("SHADER", "shaders/font_packed.ksh"),
    Asset("SHADER", "shaders/font_packed_outline.ksh"),
    Asset("SHADER", "shaders/ground.ksh"),
    Asset("SHADER", "shaders/ground_overlay.ksh"),
    Asset("SHADER", "shaders/ground_lights.ksh"),
    Asset("SHADER", "shaders/ground_underground.ksh"),
	Asset("SHADER", "shaders/ocean.ksh"),
    Asset("SHADER", "shaders/ocean_combined.ksh"),
    Asset("SHADER", "shaders/ceiling.ksh"),
    Asset("SHADER", "shaders/lighting.ksh"),
    Asset("SHADER", "shaders/minimap.ksh"),
    Asset("SHADER", "shaders/minimapocean.ksh"),
    Asset("SHADER", "shaders/minimapfs.ksh"),
    Asset("SHADER", "shaders/particle.ksh"),
    Asset("SHADER", "shaders/vfx_particle.ksh"),
    Asset("SHADER", "shaders/vfx_particle_add.ksh"),
    Asset("SHADER", "shaders/vfx_particle_reveal.ksh"),
    Asset("SHADER", "shaders/road.ksh"),
    Asset("SHADER", "shaders/river.ksh"),
    Asset("SHADER", "shaders/splat.ksh"),
    Asset("SHADER", "shaders/sprite.ksh"),
    Asset("SHADER", "shaders/texture.ksh"),
    Asset("SHADER", "shaders/ui.ksh"),
    Asset("SHADER", "shaders/ui_cc.ksh"),
    Asset("SHADER", "shaders/ui_yuv.ksh"),
    Asset("SHADER", "shaders/swipe_fade.ksh"),
    Asset("SHADER", "shaders/ui_anim.ksh"),
    Asset("SHADER", "shaders/combine_colour_cubes.ksh"),
	Asset("SHADER", "shaders/zoomblur.ksh"),
    Asset("SHADER", "shaders/postprocess_none.ksh"),
    Asset("SHADER", "shaders/postprocess.ksh"),    
    Asset("SHADER", "shaders/postprocessbloom.ksh"),
    Asset("SHADER", "shaders/postprocessdistort.ksh"),
    Asset("SHADER", "shaders/postprocessbloomdistort.ksh"),
    Asset("SHADER", "shaders/postprocesslunacy.ksh"),
    Asset("SHADER", "shaders/postprocessbloomlunacy.ksh"),
    Asset("SHADER", "shaders/postprocessdistortlunacy.ksh"),
    Asset("SHADER", "shaders/postprocessbloomdistortlunacy.ksh"),    
	Asset("SHADER", "shaders/blendoceantexture.ksh"),  
    Asset("SHADER", "shaders/waterfall2.ksh"),

    Asset("SHADER", "shaders/waves.ksh"),
    Asset("SHADER", "shaders/overheat.ksh"),

    Asset("SHADER", "shaders/anim.ksh"),
    Asset("SHADER", "shaders/anim_bloom.ksh"),
    Asset("SHADER", "shaders/anim_fade.ksh"),
    Asset("SHADER", "shaders/anim_haunted.ksh"),
    Asset("SHADER", "shaders/anim_fade_haunted.ksh"),
    Asset("SHADER", "shaders/anim_bloom_haunted.ksh"),
    Asset("SHADER", "shaders/minimapblend.ksh"),
    
    --common UI elements that we will always need
    Asset("ATLAS", "images/ui.xml"),
    Asset("IMAGE", "images/ui.tex"),
    Asset("ATLAS", "images/global_redux.xml"),
    Asset("IMAGE", "images/global_redux.tex"),
    Asset("ATLAS", "images/textboxes.xml"),
    Asset("IMAGE", "images/textboxes.tex"),
    Asset("ATLAS", "images/scoreboard.xml"),
    Asset("IMAGE", "images/scoreboard.tex"),
    Asset("ANIM", "anim/generating_world.zip"),
    Asset("ANIM", "anim/generating_forest.zip"),
    Asset("ANIM", "anim/generating_cave.zip"),
    Asset("ANIM", "anim/creepy_hands.zip"),    
    Asset("ANIM", "anim/saving_indicator.zip"),

    Asset("ANIM", "anim/skingift_popup.zip"),
    Asset("ATLAS", "images/giftpopup.xml"),
    Asset("IMAGE", "images/giftpopup.tex"),

    --Used in the FE and BG
    Asset("DYNAMIC_ATLAS", "images/inventoryimages.xml"),--legacy for mods
    Asset("PKGREF", "images/inventoryimages.tex"),
    Asset("ATLAS", "images/inventoryimages1.xml"),
    Asset("IMAGE", "images/inventoryimages1.tex"),
    Asset("ATLAS", "images/inventoryimages2.xml"),
    Asset("IMAGE", "images/inventoryimages2.tex"),

    --oft-used panel bgs
    Asset("DYNAMIC_ATLAS", "images/globalpanels2.xml"),
    Asset("PKGREF", "images/globalpanels2.tex"),

    Asset("ATLAS", "images/button_icons.xml"),
    Asset("IMAGE", "images/button_icons.tex"),

    Asset("ATLAS", "images/avatars.xml"),
    Asset("IMAGE", "images/avatars.tex"),

    Asset("ATLAS", "images/profileflair.xml"),
    Asset("IMAGE", "images/profileflair.tex"),

	--Wardrobe previewing
	Asset("ANIM", "anim/player_ghost_withhat.zip"),
	Asset("ANIM", "anim/werebeaver_basic.zip"),
	Asset("ANIM", "anim/player_idles.zip"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/body_default1.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/hand_default1.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/legs_default1.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/feet_default1.zip"),
    Asset("PKGREF", "anim/dynamic/body_default1.dyn"),
    Asset("PKGREF", "anim/dynamic/hand_default1.dyn"),
    Asset("PKGREF", "anim/dynamic/legs_default1.dyn"),
    Asset("PKGREF", "anim/dynamic/feet_default1.dyn"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/previous_skin.zip"),
    Asset("PKGREF", "anim/dynamic/previous_skin.dyn"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/random_skin.zip"),
    Asset("PKGREF", "anim/dynamic/random_skin.dyn"),   
}

require "fonts"
for i, font in ipairs( FONTS ) do
    table.insert( assets, Asset( "FONT", font.filename ) )
end

-- Add all the characters by name
-- GetOfficialCharacterList doesn't exist in the pipeline.
local official_characters = GetOfficialCharacterList and GetOfficialCharacterList() or DST_CHARACTERLIST
for _,char in ipairs(official_characters) do
    table.insert(assets, Asset("DYNAMIC_ATLAS", "bigportraits/"..char..".xml"))
    table.insert(assets, Asset("PKGREF", "bigportraits/"..char..".tex"))

    table.insert(assets, Asset("DYNAMIC_ATLAS", "images/names_"..char..".xml"))
    table.insert(assets, Asset("PKGREF", "images/names_"..char..".tex"))

    table.insert(assets, Asset("DYNAMIC_ATLAS", "images/names_gold_"..char..".xml"))
    table.insert(assets, Asset("PKGREF", "images/names_gold_"..char..".tex"))
    
    table.insert(assets, Asset("DYNAMIC_ATLAS", "images/names_gold_cn_"..char..".xml"))
    table.insert(assets, Asset("PKGREF", "images/names_gold_cn_"..char..".tex"))


    --table.insert(assets, Asset("IMAGE", "images/selectscreen_portraits/"..char..".tex")) -- Not currently used, but likely to come back
    --table.insert(assets, Asset("IMAGE", "images/selectscreen_portraits/"..char.."_silho.tex")) -- Not currently used, but likely to come back
end

--Skin assets
for _, skin_asset in pairs(require("skin_assets")) do
    table.insert(assets, skin_asset)
end

if QUAGMIRE_USE_KLUMP then
    --Add the custom quagmire recipe images
    for _,file in pairs(require("klump_files")) do
        local klump_file = string.gsub(file, "klump/", "")
        if klump_file:find(".tex") and klump_file:find("_hires") then --crappy assumption for now that _hires .tex klump files have a matching atlas that we need to load
            local xml_file = string.gsub(klump_file, ".tex", ".xml")
            table.insert(assets, Asset("DYNAMIC_ATLAS", xml_file)) --global because the recipe book is used in the frontend and backend
        end
    end
end

return Prefab("global", function() end, assets)
