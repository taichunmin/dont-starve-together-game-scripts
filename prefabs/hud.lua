local assets =
{
    --In-game only
    Asset("ATLAS", "images/fx.xml"),
    Asset("IMAGE", "images/fx.tex"),

    Asset("ATLAS", "images/fx2.xml"),
    Asset("IMAGE", "images/fx2.tex"),

    Asset("ATLAS", "images/fx3.xml"),
    Asset("IMAGE", "images/fx3.tex"),

    Asset("ATLAS", "images/fx4.xml"),
    Asset("IMAGE", "images/fx4.tex"),

    Asset("ATLAS", "images/fx5.xml"),
    Asset("IMAGE", "images/fx5.tex"),

    Asset("ANIM", "anim/sand_over.zip"),
    Asset("ANIM", "anim/moonstorm_over.zip"),
    Asset("ANIM", "anim/moonstorm_over_static.zip"),
    Asset("ANIM", "anim/mind_control_overlay.zip"),
    Asset("ANIM", "anim/screenlightning.zip"),

    Asset("ANIM", "anim/clock_transitions.zip"),
    Asset("ANIM", "anim/moon_phases_clock.zip"),
    Asset("ANIM", "anim/moon_phases_clock_alter.zip"),
    Asset("ANIM", "anim/moon_phases.zip"),
    Asset("ANIM", "anim/moonalter_phases.zip"),
    Asset("ANIM", "anim/cave_clock.zip"),

    Asset("PKGREF", "anim/health.zip"),
    Asset("PKGREF", "anim/health_effigy.zip"),
    Asset("PKGREF", "anim/sanity.zip"),
    Asset("PKGREF", "anim/sanity_ghost.zip"),
    Asset("ANIM", "anim/sanity_arrow.zip"),
    Asset("PKGREF", "anim/effigy_topper.zip"),
    Asset("ANIM", "anim/effigy_button.zip"),
    Asset("PKGREF", "anim/hunger.zip"),
    Asset("PKGREF", "anim/beaver_meter.zip"),
    Asset("ANIM", "anim/status_meter.zip"),
    Asset("ANIM", "anim/status_health.zip"),
    Asset("ANIM", "anim/status_abigail.zip"),
    Asset("ANIM", "anim/status_hunger.zip"),
    Asset("ANIM", "anim/status_sanity.zip"),
    Asset("ANIM", "anim/status_wet.zip"),
    Asset("ANIM", "anim/status_boat.zip"),
    Asset("ANIM", "anim/status_were.zip"),
    Asset("ANIM", "anim/status_wathgrithr.zip"),
    Asset("ANIM", "anim/status_wolfgang.zip"),
    Asset("ANIM", "anim/status_meter_circle.zip"),
    Asset("ANIM", "anim/status_clear_bg.zip"),
    Asset("ANIM", "anim/hunger_health_pulse.zip"),
    Asset("ANIM", "anim/spoiled_meter.zip"),
    Asset("ANIM", "anim/recharge_meter.zip"),
    Asset("ANIM", "anim/compass_bg.zip"),
    Asset("ANIM", "anim/compass_needle.zip"),
    Asset("ANIM", "anim/compass_hud.zip"),

    Asset("ANIM", "anim/saving.zip"),
    Asset("ANIM", "anim/vig.zip"),
    Asset("ANIM", "anim/fire_over.zip"),
    Asset("ANIM", "anim/clouds_ol.zip"),

    Asset("ATLAS", "images/avatars.xml"),
    Asset("IMAGE", "images/avatars.tex"),

    -- Used by old and new DressupPanel (in-game wardrobes).
    Asset("ATLAS", "images/lobbyscreen.xml"),
    Asset("Image", "images/lobbyscreen.tex"),
    -- Used by old DressupPanel (in-game wardrobes).
    Asset("ATLAS", "images/serverbrowser.xml"),
    Asset("IMAGE", "images/serverbrowser.tex"),
    --

    Asset("PKGREF", "anim/wet_meter_player.zip"),
    Asset("ANIM", "anim/wet_meter.zip"),

    Asset("PKGREF", "anim/boat_meter.zip"),
    Asset("PKGREF", "anim/boat_meter_leak.zip"),

    Asset("ANIM", "anim/tab_gift.zip"),
    Asset("ANIM", "anim/tab_yotb.zip"),

    Asset("INV_IMAGE", "unknown_head"),
    Asset("INV_IMAGE", "unknown_hand"),
    Asset("INV_IMAGE", "unknown_body"),

    Asset("INV_IMAGE", "decrease_health"),
    Asset("INV_IMAGE", "decrease_hunger"),
    Asset("INV_IMAGE", "decrease_sanity"),
    Asset("INV_IMAGE", "decrease_oldage"),

    Asset("INV_IMAGE", "half_health"),
    Asset("INV_IMAGE", "half_hunger"),
    Asset("INV_IMAGE", "half_sanity"),

    Asset("INV_IMAGE", "sculpting_material"),

    Asset("DYNAMIC_ATLAS", "images/lavaarena_hud.xml"),
    Asset("PKGREF", "images/lavaarena_hud.tex"),

    Asset("ANIM", "anim/lavaarena_health.zip"),
    Asset("ANIM", "anim/lavaarena_pethealth.zip"),
    Asset("ANIM", "anim/lavaarena_partyhealth.zip"),
    Asset("ANIM", "anim/ringmeter.zip"),

    Asset("SOUND", "sound/together.fsb"),

	Asset("DYNAMIC_ATLAS", "images/bg_redux_wardrobe_bg.xml"),
    Asset("PKGREF", "images/bg_redux_wardrobe_bg.tex"),

    Asset("ANIM", "anim/ink_over.zip"),

    Asset("ANIM", "anim/leaves_canopy.zip"),

    Asset("ANIM", "anim/status_wx.zip"),
    Asset("ANIM", "anim/status_wet_wx.zip"),
}

local prefabs =
{
    "minimap",
    "gridplacer",
}

--we don't actually instantiate this prefab. It's used for controlling asset loading
local function fn()
    return CreateEntity()
end

return Prefab("hud", fn, assets, prefabs)
