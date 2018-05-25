local assets =
{
    Asset("PKGREF", "sound/dontstarve.fev"),
    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC001.fev"),
    Asset("FILE", "sound/DLC_music.fsb"),

    Asset("FILE", "sound/wilton.fsb"),         -- Legacy sound that can be used in mods
    Asset("FILE", "sound/winnie.fsb"),         -- Legacy sound that can be used in mods
    Asset("FILE", "sound/wallace.fsb"),        -- Legacy sound that can be used in mods
    Asset("FILE", "sound/woodrow.fsb"),        -- Legacy sound that can be used in mods
    Asset("FILE", "sound/stuff.fsb"),          -- Legacy sound that can be used in mods

    Asset("ATLAS", "images/global.xml"),
    Asset("IMAGE", "images/global.tex"),
    Asset("IMAGE", "images/visited.tex"),
    Asset("ANIM", "anim/scroll_arrow.zip"),

    Asset("ANIM", "anim/corner_dude.zip"),

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

    -- Used in event join flow and in-game victory.
    Asset("ATLAS", "images/dialogcurly_9slice.xml"),
    Asset("IMAGE", "images/dialogcurly_9slice.tex"),

    -- Used for motd and options
    Asset("ATLAS", "images/dialogrect_9slice.xml"),
    Asset("IMAGE", "images/dialogrect_9slice.tex"),

    Asset("DYNAMIC_ATLAS", "images/lavaarena_achievements.xml"),
    Asset("PKGREF", "images/lavaarena_achievements.tex"),

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
    Asset("SHADER", "shaders/ceiling.ksh"),
    -- Asset("SHADER", "shaders/triplanar.ksh"),
    Asset("SHADER", "shaders/triplanar_bg.ksh"),
    Asset("SHADER", "shaders/triplanar_alpha_wall.ksh"),
    Asset("SHADER", "shaders/triplanar_alpha_ceiling.ksh"),
    Asset("SHADER", "shaders/lighting.ksh"),
    Asset("SHADER", "shaders/minimap.ksh"),
    Asset("SHADER", "shaders/minimapfs.ksh"),
    Asset("SHADER", "shaders/particle.ksh"),
    Asset("SHADER", "shaders/vfx_particle.ksh"),
    Asset("SHADER", "shaders/vfx_particle_add.ksh"),
    Asset("SHADER", "shaders/vfx_particle_reveal.ksh"),
    Asset("SHADER", "shaders/road.ksh"),
    Asset("SHADER", "shaders/river.ksh"),
    Asset("SHADER", "shaders/splat.ksh"),
    Asset("SHADER", "shaders/texture.ksh"),
    Asset("SHADER", "shaders/ui.ksh"),
    Asset("SHADER", "shaders/ui_yuv.ksh"),
    Asset("SHADER", "shaders/swipe_fade.ksh"),
    Asset("SHADER", "shaders/ui_anim.ksh"),
    Asset("SHADER", "shaders/combine_colour_cubes.ksh"),
    Asset("SHADER", "shaders/postprocess.ksh"),
    Asset("SHADER", "shaders/postprocessbloom.ksh"),
    Asset("SHADER", "shaders/postprocessdistort.ksh"),
    Asset("SHADER", "shaders/postprocessbloomdistort.ksh"),

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
    Asset("ANIM", "anim/generating_cave.zip"),
    Asset("ANIM", "anim/creepy_hands.zip"),    
    Asset("ANIM", "anim/saving_indicator.zip"),

    Asset("ANIM", "anim/skingift_popup.zip"),
    Asset("ATLAS", "images/giftpopup.xml"),
    Asset("IMAGE", "images/giftpopup.tex"),

    --oft-used panel bgs
    Asset("DYNAMIC_ATLAS", "images/globalpanels2.xml"),
    Asset("PKGREF", "images/globalpanels2.tex"),

    Asset("ATLAS", "images/button_icons.xml"),
    Asset("IMAGE", "images/button_icons.tex"),

    Asset("ATLAS", "images/avatars.xml"),
    Asset("IMAGE", "images/avatars.tex"),

    Asset("ATLAS", "images/profileflair.xml"),
    Asset("IMAGE", "images/profileflair.tex"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/body_default1.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/hand_default1.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/legs_default1.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/feet_default1.zip"),

    Asset("DYNAMIC_ANIM", "anim/dynamic/previous_skin.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/random_skin.zip"),
}

-- Loading Screens from items
require "skinsutils"
require "misc_items"
for item_key,item_blob in pairs(GetAllMiscItemsOfType("loading")) do
    local atlas,tex = GetLoaderAtlasAndTexPkgref(item_key)
    table.insert(assets, Asset("DYNAMIC_ATLAS", atlas))
    table.insert(assets, Asset("PKGREF", tex))
end
-- Player portrait backgrounds from items
local playerportraits = GetAllMiscItemsOfType("playerportrait")
playerportraits.playerportrait_bg_none = {} -- none is not a real item
for item_key,item_blob in pairs(playerportraits) do
    local atlas,tex = GetPlayerPortraitAtlasAndTexPkgref(item_key)
    table.insert(assets, Asset("DYNAMIC_ATLAS", atlas))
    table.insert(assets, Asset("PKGREF", tex))
end

require "fonts"
for i, font in ipairs( FONTS ) do
    table.insert( assets, Asset( "FONT", font.filename ) )
end

-- Add all the characters by name
-- GetActiveCharacterList doesn't exist in the pipeline.
local active_characters = GetActiveCharacterList and GetActiveCharacterList() or DST_CHARACTERLIST
for i,char in ipairs(active_characters) do
    if PREFAB_SKINS[char] then
        for _,character in pairs(PREFAB_SKINS[char]) do
            table.insert(assets, Asset("DYNAMIC_ATLAS", "bigportraits/"..character..".xml"))
            table.insert(assets, Asset("PKGREF", "bigportraits/"..character..".tex"))
        end
        table.insert(assets, Asset("DYNAMIC_ATLAS", "bigportraits/"..char..".xml"))
        table.insert(assets, Asset("PKGREF", "bigportraits/"..char..".tex"))

        table.insert(assets, Asset("DYNAMIC_ATLAS", "images/names_"..char..".xml"))
        table.insert(assets, Asset("PKGREF", "images/names_"..char..".tex"))

        table.insert(assets, Asset("DYNAMIC_ATLAS", "images/names_gold_"..char..".xml"))
        table.insert(assets, Asset("PKGREF", "images/names_gold_"..char..".tex"))

        --table.insert(assets, Asset("IMAGE", "images/selectscreen_portraits/"..char..".tex")) -- Not currently used, but likely to come back
        --table.insert(assets, Asset("IMAGE", "images/selectscreen_portraits/"..char.."_silho.tex")) -- Not currently used, but likely to come back
    end
end

for i, v in pairs(active_characters) do
    if v ~= "" then
        table.insert(assets, Asset("ANIM", "anim/"..v..".zip"))
    end
end

--Skins assets
for _, clothing_asset in pairs(require("clothing_assets")) do
    table.insert(assets, clothing_asset)
end
local skinprefabs = {require("prefabs/skinprefabs")}
for _,skin_prefab in pairs(skinprefabs) do
    if string.sub(skin_prefab.name, -5) ~= "_none" then
        for k, v in pairs(skin_prefab.assets) do
            table.insert(assets, v)
        end
    end
end

--klump files for package refs
for _,klump_asset in pairs(require("klump_assets")) do
    table.insert(assets, klump_asset)
end

return Prefab("global", function() end, assets)
