local UI_LEFT, UI_RIGHT = -214, 228
local UI_VERTICAL_MIDDLE = (UI_LEFT + UI_RIGHT) * 0.5
local UI_TOP, UI_BOTTOM = 176, 20
local TILE_SIZE, TILE_HALFSIZE = 34, 16
local SKILLTREESTRINGS = STRINGS.SKILLTREE.WORMWOOD

--------------------------------------------------------------------------------------------------

local ORDERS =
{
    { "crafting",    { UI_LEFT, UI_TOP } },
    { "gathering",   { UI_LEFT, UI_TOP } },
    { "allegiance1", { UI_LEFT, UI_TOP } },
    { "allegiance2", { UI_LEFT, UI_TOP } },
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        wormwood_identify_plants2 = { -- NOTES(JBK): Changing the root name to force a respec it is not used elsewhere so this is safe.
            title = SKILLTREESTRINGS.IDENTIFY_PLANTS_TITLE,
            desc = SKILLTREESTRINGS.IDENTIFY_PLANTS_DESC,
            icon = "wormwood_identify_plants",
            pos = {(UI_LEFT + UI_RIGHT) * 0.5, UI_BOTTOM},

            group = "gathering",
            tags = {},
            root = true,
            onactivate = function(owner, from_load)
                owner:AddTag("farmplantidentifier")
            end,
            ondeactivate = function(owner, from_load)
                owner:RemoveTag("farmplantidentifier")
            end,
            connects = {
                "wormwood_saplingcrafting",
                "wormwood_mushroomplanter_ratebonus1",
                "wormwood_blooming_speed1",
                "wormwood_blooming_farmrange1",
            },
            defaultfocus = true,
        },

        wormwood_saplingcrafting = {
            title = SKILLTREESTRINGS.SAPLINGCRAFTING_TITLE,
            desc = SKILLTREESTRINGS.SAPLINGCRAFTING_DESC,
            icon = "wormwood_saplingcrafting",
            pos = {UI_VERTICAL_MIDDLE - 105, UI_BOTTOM + 10},

            group = "crafting",
            tags = {"crafting"},
            connects = {
                "wormwood_berrybushcrafting",
            },
        },
        wormwood_berrybushcrafting = {
            title = SKILLTREESTRINGS.BERRYBUSHCRAFTING_TITLE,
            desc = SKILLTREESTRINGS.BERRYBUSHCRAFTING_DESC,
            icon = "wormwood_berrybushcrafting",
            pos = {UI_VERTICAL_MIDDLE - 105 - 50, UI_BOTTOM + 10},

            group = "crafting",
            tags = {"crafting"},
            connects = {
                "wormwood_reedscrafting",
                "wormwood_juicyberrybushcrafting",
            },
        },
        wormwood_juicyberrybushcrafting = {
            title = SKILLTREESTRINGS.JUICYBERRYBUSHCRAFTING_TITLE,
            desc = SKILLTREESTRINGS.JUICYBERRYBUSHCRAFTING_DESC,
            icon = "wormwood_juicyberrybushcrafting",
            pos = {UI_VERTICAL_MIDDLE - 115 - 60, UI_BOTTOM + 58},

            group = "crafting",
            tags = {"crafting"},
        },
        wormwood_reedscrafting = {
            title = SKILLTREESTRINGS.REEDSCRAFTING_TITLE,
            desc = SKILLTREESTRINGS.REEDSCRAFTING_DESC,
            icon = "wormwood_reedscrafting",
            pos = {UI_VERTICAL_MIDDLE - 105 - 100, UI_BOTTOM + 10},

            group = "crafting",
            tags = {"crafting"},
            connects = {
                "wormwood_lureplantbulbcrafting",
            },
        },
        wormwood_lureplantbulbcrafting = {
            title = SKILLTREESTRINGS.LUREPLANTCRAFTING_TITLE,
            desc = SKILLTREESTRINGS.LUREPLANTCRAFTING_DESC,
            icon = "wormwood_lureplantbulbcrafting",
            pos = {UI_VERTICAL_MIDDLE - 115 - 120, UI_BOTTOM + 58},

            group = "crafting",
            tags = {"crafting"},
        },

        wormwood_mushroomplanter_ratebonus1 = {
            title = SKILLTREESTRINGS.MUSHROOMPLANTER_RATEBONUS_1_TITLE,
            desc = SKILLTREESTRINGS.MUSHROOMPLANTER_RATEBONUS_1_DESC,
            icon = "wormwood_mushroomplanter_ratebonus1",
            pos = {UI_VERTICAL_MIDDLE - 35, UI_BOTTOM + 65},

            group = "crafting",
            tags = {"crafting"},
            connects = {
                "wormwood_mushroomplanter_ratebonus2",
            },
        },
        wormwood_mushroomplanter_ratebonus2 = {
            title = SKILLTREESTRINGS.MUSHROOMPLANTER_RATEBONUS_2_TITLE,
            desc = SKILLTREESTRINGS.MUSHROOMPLANTER_RATEBONUS_2_DESC,
            icon = "wormwood_mushroomplanter_ratebonus2",
            pos = {UI_VERTICAL_MIDDLE - 90, UI_BOTTOM + 95},

            group = "crafting",
            tags = {"crafting"},
            connects = {
                "wormwood_mushroomplanter_upgrade",
                "wormwood_syrupcrafting",
            },
        },
        wormwood_mushroomplanter_upgrade = {
            title = SKILLTREESTRINGS.MUSHROOMPLANTER_UPGRADE_TITLE,
            desc = SKILLTREESTRINGS.MUSHROOMPLANTER_UPGRADE_DESC,
            icon = "wormwood_mushroomplanter_upgrade",
            pos = {UI_VERTICAL_MIDDLE - 90, UI_BOTTOM + 145},

            group = "crafting",
            tags = {"crafting"},
            connects = {
                "wormwood_moon_cap_eating",
            },
        },
        wormwood_moon_cap_eating = {
            title = SKILLTREESTRINGS.MOON_CAP_EATING_TITLE,
            desc = SKILLTREESTRINGS.MOON_CAP_EATING_DESC,
            icon = "wormwood_moon_cap_eating",
            pos = {UI_VERTICAL_MIDDLE - 70, UI_BOTTOM + 190},

            group = "crafting",
            tags = {"crafting"},
        },
        wormwood_syrupcrafting = {
            title = SKILLTREESTRINGS.SYRUPCRAFTING_TITLE,
            desc = SKILLTREESTRINGS.SYRUPCRAFTING_DESC,
            icon = "wormwood_syrupcrafting",
            pos = {UI_VERTICAL_MIDDLE - 30, UI_BOTTOM + 125},

            group = "crafting",
            tags = {"crafting"},
        },

        wormwood_allegiance_lock_lunar_2 = SkillTreeFns.MakeCelestialChampionLock({
            pos = {UI_RIGHT - 3.5, UI_TOP - 45},
            group = "allegiance2",
        }),

        wormwood_allegiance_count_lock_2 = {
            desc = SKILLTREESTRINGS.COUNT_LOCK_2_DESC,
            pos = {UI_RIGHT - 3.5, UI_TOP - 12},
            group = "allegiance2",
            tags = {"allegiance", "lock"},
            locks = {"wormwood_allegiance_lock_lunar_2"},
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "blooming", activatedskills) >= 5
            end,
        },

        wormwood_allegiance_lunar_plant_gear_1 = {
            title = SKILLTREESTRINGS.LUNAR_GEAR_1_TITLE,
            desc = SKILLTREESTRINGS.LUNAR_GEAR_1_DESC,
            icon = "wormwood_allegiance_lunar_plant_gear_1",
            pos = {UI_RIGHT - 3.5, UI_TOP + 25},
            locks = {"wormwood_allegiance_lock_lunar_2", "wormwood_allegiance_count_lock_2"},

            onactivate = function(owner, from_load)
                if not owner.components.skilltreeupdater:IsActivated("wormwood_allegiance_lunar_mutations_1") then
                    owner:AddTag("player_lunar_aligned")
                    if owner.components.damagetyperesist then
                        owner.components.damagetyperesist:AddResist("lunar_aligned", owner, TUNING.SKILLS.WILSON_ALLEGIANCE_LUNAR_RESIST, "wormwood_allegiance_lunar")
                    end
                    if owner.components.damagetypebonus then
                        owner.components.damagetypebonus:AddBonus("shadow_aligned", owner, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS, "wormwood_allegiance_lunar")
                    end
                end
            end,
            ondeactivate = function(owner, from_load)
                if not owner.components.skilltreeupdater:IsActivated("wormwood_allegiance_lunar_mutations_1") then
                    owner:RemoveTag("player_lunar_aligned")
                    if owner.components.damagetyperesist then
                        owner.components.damagetyperesist:RemoveResist("lunar_aligned", owner, "wormwood_allegiance_lunar")
                    end
                    if owner.components.damagetypebonus then
                        owner.components.damagetypebonus:RemoveBonus("shadow_aligned", owner, "wormwood_allegiance_lunar")
                    end
                end
            end,

            group = "allegiance2",
            tags = {"allegiance", "lunar", "lunar_favor"},
            connects = {
                "wormwood_allegiance_lunar_plant_gear_2",
            },
        },
        wormwood_allegiance_lunar_plant_gear_2 = {
            title = SKILLTREESTRINGS.LUNAR_GEAR_2_TITLE,
            desc = SKILLTREESTRINGS.LUNAR_GEAR_2_DESC,
            icon = "wormwood_allegiance_lunar_plant_gear_2",
            pos = {UI_RIGHT - 3.5, UI_TOP + 65},

            group = "allegiance2",
            tags = {"allegiance", "lunar", "lunar_favor"},
        },

        wormwood_blooming_speed1 = {
            title = SKILLTREESTRINGS.BLOOMING_SPEED1_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_SPEED1_DESC,
            icon = "wormwood_blooming_speed1",
            pos = {UI_VERTICAL_MIDDLE + 105, UI_BOTTOM + 10},

            group = "gathering",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                local bloomness = owner.components.bloomness
                if bloomness then
                    local skilltreeupdater = owner.components.skilltreeupdater
                    if not (skilltreeupdater:IsActivated("wormwood_blooming_speed2")
                            or skilltreeupdater:IsActivated("wormwood_blooming_speed3")) then
                        bloomness:SetDurations(TUNING.WORMWOOD_BLOOM_STAGE_DURATION_UPGRADED1, bloomness.full_bloom_duration)
                    end
                end
            end,
            connects = {
                "wormwood_blooming_speed2",
            },
        },
        wormwood_blooming_speed2 = {
            title = SKILLTREESTRINGS.BLOOMING_SPEED2_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_SPEED2_DESC,
            icon = "wormwood_blooming_speed2",
            pos = {UI_VERTICAL_MIDDLE + 105 + 50, UI_BOTTOM + 10},

            group = "gathering",
            tags = {"blooming"},
            onactivate = function(owner, from_load)
                local bloomness = owner.components.bloomness
                if bloomness then
                    local skilltreeupdater = owner.components.skilltreeupdater
                    if not skilltreeupdater:IsActivated("wormwood_blooming_speed3") then
                        bloomness:SetDurations(TUNING.WORMWOOD_BLOOM_STAGE_DURATION_UPGRADED2, bloomness.full_bloom_duration)
                    end
                end
            end,
            connects = {
                "wormwood_blooming_max_upgrade",
                "wormwood_blooming_overheatprotection",
            },
        },
        wormwood_blooming_overheatprotection = {
            title = SKILLTREESTRINGS.BLOOMING_OVERHEATPROTECTION_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_OVERHEATPROTECTION_DESC,
            icon = "wormwood_blooming_overheatprotection",
            pos = {UI_VERTICAL_MIDDLE + 165, UI_BOTTOM + 60},

            group = "gathering",
            tags = {"blooming"},

            onactivate = function(inst)
                if inst.fullbloom then
                    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_MED_LARGE
                end
            end,
            ondeactivate = function(inst)
                if inst.fullbloom then
                    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_SMALL
                else
                    inst.components.temperature.inherentsummerinsulation = 0
                end
            end,
        },
        wormwood_blooming_max_upgrade = {
            title = SKILLTREESTRINGS.BLOOMING_MAX_UPGRADE_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_MAX_UPGRADE_DESC,
            icon = "wormwood_blooming_speed3",
            pos = {UI_VERTICAL_MIDDLE + 105 + 100, UI_BOTTOM + 10},

            group = "gathering",
            tags = {"blooming"},
            connects = {
                "wormwood_blooming_photosynthesis",
            },
        },

        wormwood_blooming_photosynthesis = {
            title = SKILLTREESTRINGS.BLOOMING_PHOTOSYNTHESIS_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_PHOTOSYNTHESIS_DESC,
            icon = "wormwood_blooming_photosynthesis",
            pos = {UI_VERTICAL_MIDDLE + 165 + 55, UI_BOTTOM + 60},

            group = "gathering",
            tags = {"blooming"},

            onactivate = function(inst)
                inst:WatchWorldState("isday", inst.UpdatePhotosynthesisState)
                inst:UpdatePhotosynthesisState(TheWorld.state.isday)
            end,
            ondeactivate = function(inst)
                inst:StopWatchingWorldState("isday", inst.UpdatePhotosynthesisState)
                inst:UpdatePhotosynthesisState(TheWorld.state.isday)
            end,
        },

        wormwood_blooming_farmrange1 = {
            title = SKILLTREESTRINGS.BLOOMING_FARMRANGE1_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_FARMRANGE1_DESC,
            icon = "wormwood_blooming_farmrange1",
            pos = {UI_VERTICAL_MIDDLE + 55, UI_BOTTOM + 45 + TILE_SIZE},

            group = "gathering",
            tags = {"blooming"},
            onactivate = function(owner)
                owner:AddTag("farmplantfastpicker")
            end,
            ondeactivate = function(owner)
                owner:RemoveTag("farmplantfastpicker")
            end,
            connects = {
                "wormwood_quick_selffertilizer",
            },
        },

        wormwood_quick_selffertilizer = {
            title = SKILLTREESTRINGS.QUICK_SELFFERTILIZER_TITLE,
            desc = SKILLTREESTRINGS.QUICK_SELFFERTILIZER_DESC,
            icon = "wormwood_quick_selffertilizer",
            pos = {UI_VERTICAL_MIDDLE + 95, UI_BOTTOM + 115},

            group = "gathering",
            tags = {"blooming"},
            connects = {
                "wormwood_blooming_trapbramble",
                "wormwood_bugs",
            },
        },
        wormwood_bugs = {
            title = SKILLTREESTRINGS.BUGS_TITLE,
            desc = SKILLTREESTRINGS.BUGS_DESC,
            icon = "wormwood_bugs",
            pos = {UI_VERTICAL_MIDDLE + 43, UI_BOTTOM + 150},

            group = "gathering",
            tags = {"blooming"},
        },

        wormwood_blooming_trapbramble = {
            title = SKILLTREESTRINGS.BLOOMING_TRAPBRAMBLE_TITLE,
            desc = SKILLTREESTRINGS.BLOOMING_TRAPBRAMBLE_DESC,
            icon = "wormwood_blooming_trapbramble",
            pos = {UI_VERTICAL_MIDDLE + 137, UI_BOTTOM + 145},

            group = "gathering",
            tags = {"blooming"},
            connects = {
                "wormwood_armor_bramble",
            },
        },

        wormwood_armor_bramble = {
            title = SKILLTREESTRINGS.ARMOR_BRAMBLE_TITLE,
            desc = SKILLTREESTRINGS.ARMOR_BRAMBLE_DESC,
            icon = "wormwood_armor_bramble",
            pos = {UI_VERTICAL_MIDDLE + 120, UI_BOTTOM + 187},

            group = "gathering",
            tags = {"blooming"},
        },

        wormwood_allegiance_lock_lunar_1 = SkillTreeFns.MakeCelestialChampionLock({
            pos = {UI_LEFT + 13, UI_BOTTOM + 110},
            group = "allegiance1",
        }),
        wormwood_allegiance_count_lock_1 = {
            desc = SKILLTREESTRINGS.COUNT_LOCK_1_DESC,
            pos = {UI_LEFT + 13, UI_BOTTOM + 140},
            group = "allegiance1",
            tags = {"allegiance", "lock"},
            locks = {"wormwood_allegiance_lock_lunar_1"},
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "crafting", activatedskills) >= 5
            end,
        },
        wormwood_allegiance_lunar_mutations_1 = {
            title = SKILLTREESTRINGS.LUNAR_MUTATIONS_1_TITLE,
            desc = SKILLTREESTRINGS.LUNAR_MUTATIONS_1_DESC,
            icon = "wormwood_lunar_mutations_1",
            pos = {UI_LEFT + 13, UI_BOTTOM + 175},
            locks = {"wormwood_allegiance_lock_lunar_1", "wormwood_allegiance_count_lock_1"},

            onactivate = function(owner, from_load)
                if not owner.components.skilltreeupdater:IsActivated("wormwood_allegiance_lunar_plant_gear_1") then
                    owner:AddTag("player_lunar_aligned")
                    if owner.components.damagetyperesist then
                        owner.components.damagetyperesist:AddResist("lunar_aligned", owner, TUNING.SKILLS.WILSON_ALLEGIANCE_LUNAR_RESIST, "wormwood_allegiance_lunar")
                    end
                    if owner.components.damagetypebonus then
                        owner.components.damagetypebonus:AddBonus("shadow_aligned", owner, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS, "wormwood_allegiance_lunar")
                    end
                end
            end,
            ondeactivate = function(owner, from_load)
                if not owner.components.skilltreeupdater:IsActivated("wormwood_allegiance_lunar_plant_gear_1") then
                    owner:RemoveTag("player_lunar_aligned")
                    if owner.components.damagetyperesist then
                        owner.components.damagetyperesist:RemoveResist("lunar_aligned", owner, "wormwood_allegiance_lunar")
                    end
                    if owner.components.damagetypebonus then
                        owner.components.damagetypebonus:RemoveBonus("shadow_aligned", owner, "wormwood_allegiance_lunar")
                    end
                end
            end,
            group = "allegiance1",
            tags = {"allegiance", "lunar", "lunar_favor"},
            connects = {
                "wormwood_allegiance_lunar_mutations_2",
                "wormwood_allegiance_lunar_mutations_3",
            },
        },
        wormwood_allegiance_lunar_mutations_2 = {
            title = SKILLTREESTRINGS.LUNAR_MUTATIONS_2_TITLE,
            desc = SKILLTREESTRINGS.LUNAR_MUTATIONS_2_DESC,
            icon = "wormwood_lunar_mutations_2",
            pos = {UI_LEFT - 14, UI_TOP + 60},
            group = "allegiance1",
            tags = {"allegiance", "lunar", "lunar_favor"},
        },
        wormwood_allegiance_lunar_mutations_3 = {
            title = SKILLTREESTRINGS.LUNAR_MUTATIONS_3_TITLE,
            desc = SKILLTREESTRINGS.LUNAR_MUTATIONS_3_DESC,
            icon = "wormwood_lunar_mutations_3",
            pos = {UI_LEFT + 40, UI_TOP + 60},
            group = "allegiance1",
            tags = {"allegiance", "lunar", "lunar_favor"},
        },
    }


    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData