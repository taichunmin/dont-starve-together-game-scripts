local assets =
{
    --In-game only
    Asset("ATLAS", "images/hud.xml"),
    Asset("IMAGE", "images/hud.tex"),

    Asset("ATLAS", "images/fx.xml"),
    Asset("IMAGE", "images/fx.tex"),

    Asset("ATLAS", "images/fx2.xml"),
    Asset("IMAGE", "images/fx2.tex"),

    Asset("ATLAS", "images/fx3.xml"),
    Asset("IMAGE", "images/fx3.tex"),

    Asset("ANIM", "anim/sand_over.zip"),
    Asset("ANIM", "anim/mind_control_overlay.zip"),

    Asset("ANIM", "anim/clock_transitions.zip"),
    Asset("ANIM", "anim/moon_phases_clock.zip"),
    Asset("ANIM", "anim/moon_phases.zip"),
    Asset("ANIM", "anim/cave_clock.zip"),

    Asset("ANIM", "anim/health.zip"),
    Asset("ANIM", "anim/health_effigy.zip"),
    Asset("ANIM", "anim/sanity.zip"),
    Asset("ANIM", "anim/sanity_ghost.zip"),
    Asset("ANIM", "anim/sanity_arrow.zip"),
    Asset("ANIM", "anim/effigy_topper.zip"),
    Asset("ANIM", "anim/effigy_button.zip"),
    Asset("ANIM", "anim/hunger.zip"),
    Asset("ANIM", "anim/beaver_meter.zip"),
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

    Asset("ATLAS", "images/inventoryimages.xml"),
    Asset("IMAGE", "images/inventoryimages.tex"),

    Asset("ANIM", "anim/wet_meter_player.zip"), 
    Asset("ANIM", "anim/wet_meter.zip"),

    Asset("ANIM", "anim/tab_gift.zip"),

    Asset("INV_IMAGE", "unknown_head"),
    Asset("INV_IMAGE", "unknown_hand"),
    Asset("INV_IMAGE", "unknown_body"),

    Asset("INV_IMAGE", "decrease_health"),
    Asset("INV_IMAGE", "decrease_hunger"),
    Asset("INV_IMAGE", "decrease_sanity"),

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
