local POS_Y_1 =  172
local POS_Y_2 = POS_Y_1 - 38
local POS_Y_3 = POS_Y_1 - (38 * 2)
local POS_Y_4 = POS_Y_1 - (38 * 3)
local POS_Y_5 = POS_Y_1 - (38 * 4)

local TITLE_Y = POS_Y_1 + 30

local TILEGAP = 38

local WETNESS_POS_X = -210.5

local MOSQUITO_1_X = -46.5
local MERM_KING_HUNGER_X = MOSQUITO_1_X + 104.5
local ITEM_QUESTS_X = (MERM_KING_HUNGER_X+MOSQUITO_1_X) * .5
local CIV_1_X = ITEM_QUESTS_X - TILEGAP
local ALLIEGIANCE_1_X = 184.5

local AMPHIBIAN_TITLE_X = WETNESS_POS_X + TILEGAP / 2
local SWAMPMASTER_TITLE_X = (MOSQUITO_1_X + MERM_KING_HUNGER_X) * .5
local ALLIEGIANCE_TITLE_X = ALLIEGIANCE_1_X + TILEGAP / 2

-- Positions

--------------------------------------------------------------------------------------------------

-- Functions

local function CreateAddTagFn(tag)
    return function(inst) inst:AddTag(tag) end
end

local function CreateRemoveTagFn(tag)
    return function(inst) inst:RemoveTag(tag) end
end

local function RefreshWetnessSkills(inst)
    inst:RefreshWetnessSkills()
end

local function RefreshPathFinderSkill(inst)
    inst:RefreshPathFinderSkill()
end

--------------------------------------------------------------------------------------------------

local ORDERS =
{
    {"amphibian",   { AMPHIBIAN_TITLE_X,   TITLE_Y }},
    {"swampmaster", { SWAMPMASTER_TITLE_X, TITLE_Y }},
    {"allegiance",  { ALLIEGIANCE_TITLE_X, TITLE_Y }},
}

--------------------------------------------------------------------------------------------------

local WURT_SKILL_STRINGS = STRINGS.SKILLTREE.WURT

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- Description.
        wurt_amphibian_sanity_1 = {
            pos = {WETNESS_POS_X + TILEGAP/2, POS_Y_1},
            group = "amphibian",
            tags = {"amphibian", "wetness_sanity"},
            root = true,
            onactivate   = RefreshWetnessSkills,
            ondeactivate = RefreshWetnessSkills,
            connects = {
                "wurt_amphibian_sanity_2",
            },
        },

        -- Description.
        wurt_amphibian_sanity_2 = {
            pos = {WETNESS_POS_X + TILEGAP/2, POS_Y_2},
            group = "amphibian",
            tags = {"amphibian", "wetness_sanity"},
            onactivate   = RefreshWetnessSkills,
            ondeactivate = RefreshWetnessSkills,
            connects = {
                "wurt_amphibian_temperature",
            },
        },

        -- Description.
        wurt_amphibian_temperature = {
            pos = {WETNESS_POS_X + TILEGAP/2, POS_Y_3},
            group = "amphibian",
            tags = {"amphibian", "wetness_temperature"},

            onactivate   = function(inst)
                if inst.components.temperature ~= nil then
                    inst.components.temperature.maxmoisturepenalty = inst.components.temperature.maxmoisturepenalty + TUNING.SKILLS.WURT.MAX_MOISTURE_TEMPERATURE_PENALTY_OFFSET
                end

                local moisture = inst.components.moisture

                if moisture ~= nil then
                    moisture.optimalPlayerTempDrying = moisture.optimalPlayerTempDrying + TUNING.SKILLS.WURT.OPTIMAL_TEMPERATURE_DRYING_OFFSET
                    moisture.maxPlayerTempDrying     = moisture.maxPlayerTempDrying     + TUNING.SKILLS.WURT.MAX_TEMPERATURE_DRYING_OFFSET
                end
            end,

            ondeactivate = function(inst)
                if inst.components.temperature ~= nil then
                    inst.components.temperature.maxmoisturepenalty = inst.components.temperature.maxmoisturepenalty - TUNING.SKILLS.WURT.MAX_MOISTURE_TEMPERATURE_PENALTY_OFFSET
                end

                local moisture = inst.components.moisture

                if moisture ~= nil then
                    moisture.optimalPlayerTempDrying = moisture.optimalPlayerTempDrying - TUNING.SKILLS.WURT.OPTIMAL_TEMPERATURE_DRYING_OFFSET
                    moisture.maxPlayerTempDrying     = moisture.maxPlayerTempDrying     - TUNING.SKILLS.WURT.MAX_TEMPERATURE_DRYING_OFFSET
                end
            end,

            connects = {
                "wurt_amphibian_thickskin_1",
                "wurt_amphibian_healing_1",
            },
        },

        -- Description.
        wurt_amphibian_thickskin_1 = {
            pos = {WETNESS_POS_X, POS_Y_4},
            group = "amphibian",
            tags = {"amphibian", "wetness_defense"},
            onactivate   = RefreshWetnessSkills,
            ondeactivate = RefreshWetnessSkills,
            connects = {
                "wurt_amphibian_thickskin_2",
            },
        },

        -- Description.
        wurt_amphibian_thickskin_2 = {
            pos = {WETNESS_POS_X, POS_Y_5},
            group = "amphibian",
            tags = {"amphibian", "wetness_defense", "marsh_wetness"},
            onactivate   = RefreshWetnessSkills,
            ondeactivate = RefreshWetnessSkills,
        },

        -- Description.
        wurt_amphibian_healing_1 = {
            pos = {WETNESS_POS_X + TILEGAP, POS_Y_4},
            group = "amphibian",
            tags = {"amphibian", "wetness_healing"},
            onactivate   = RefreshWetnessSkills,
            ondeactivate = RefreshWetnessSkills,
            connects = {
                "wurt_amphibian_healing_2",
            },
        },

        -- Description.
        wurt_amphibian_healing_2 = {
            pos = {WETNESS_POS_X + TILEGAP, POS_Y_5},
            group = "amphibian",
            tags = {"amphibian", "wetness_healing", "marsh_wetness"},
            onactivate   = RefreshWetnessSkills,
            ondeactivate = RefreshWetnessSkills,
        },

        ------------------------------------------------------------------------------

        -- Description.
        wurt_mosquito_craft_1 = {
            pos = {MOSQUITO_1_X, POS_Y_1},
            group = "swampmaster",
            tags = {"swampmaser", "mosquito"},
            root = true,
            connects = {
                "wurt_mosquito_craft_2",
            },
            defaultfocus = true,
        },

        -- Description.
        wurt_mosquito_craft_2 = {
            pos = {MOSQUITO_1_X, POS_Y_2},
            group = "swampmaster",
            tags = {"swampmaser", "mosquito"},
            connects = {
                "wurt_mosquito_craft_3",
            },
        },

        -- Description.
        wurt_mosquito_craft_3 = {
            pos = {MOSQUITO_1_X, POS_Y_3},
            group = "swampmaster",
            tags = {"swampmaser", "mosquito"},
        },

        -- Description.
        wurt_civ_1 = {
            pos = {CIV_1_X, POS_Y_4},
            group = "swampmaster",
            tags = {"swampmaser", "civ"},
            root = true,
            connects = {
                "wurt_civ_1_2",
            },
        },

        wurt_civ_1_2 = {
            pos = {CIV_1_X, POS_Y_5},
            group = "swampmaster",
            tags = {"swampmaser", "civ"},
        },

        wurt_civ_2 = {
            pos = {CIV_1_X+TILEGAP, POS_Y_4},
            group = "swampmaster",
            tags = {"swampmaser", "civ"},
            root = true,
            connects = {
                "wurt_civ_2_2",
            },
        },

        wurt_civ_2_2 = {
            pos = {CIV_1_X+TILEGAP, POS_Y_5},
            group = "swampmaster",
            tags = {"swampmaser", "civ"},
        },

        wurt_civ_3 = {
            pos = {CIV_1_X+TILEGAP+TILEGAP, POS_Y_4},
            group = "swampmaster",
            tags = {"swampmaser", "civ"},
            root = true,
            connects = {
                "wurt_civ_3_2",
            },
        },

        wurt_civ_3_2 = {
            pos = {CIV_1_X+TILEGAP+TILEGAP, POS_Y_5},
            group = "swampmaster",
            tags = {"swampmaser", "civ"},
        },

        -- Description.
        wurt_pathfinder = {
            pos = {MERM_KING_HUNGER_X + TILEGAP * .9, (POS_Y_4 + POS_Y_5) * .5},
            group = "swampmaster",
            tags = {"swampmaser", "pathfinder"},
            root = true,
            onactivate   = RefreshPathFinderSkill,
            ondeactivate = RefreshPathFinderSkill,
        },

        ------------------------------------------------------------------------------

        -- Description.
        wurt_merm_king_hunger_1 = {
            pos = {MERM_KING_HUNGER_X, POS_Y_1},
            group = "swampmaster",
            tags = {"swampmaser", "merm_king_max_hunger"},
            root = true,
            connects = {
                "wurt_merm_king_hunger_2",
            }
        },

        -- Description.
        wurt_merm_king_hunger_2 = {
            pos = {MERM_KING_HUNGER_X, POS_Y_2},
            group = "swampmaster",
            tags = {"swampmaser", "merm_king_max_hunger"},
            connects = {
                "wurt_merm_king_hunger_3",
            }
        },

        -- Description.
        wurt_merm_king_hunger_3 = {
            pos = {MERM_KING_HUNGER_X, POS_Y_3},
            group = "swampmaster",
            tags = {"swampmaser", "merm_king_hunger_rate"},
        },

        ------------------------------------------------------------------------------

        -- Description.
        wurt_merm_flee = {
            pos = {MOSQUITO_1_X - TILEGAP * .9, (POS_Y_4 + POS_Y_5) * .5},
            group = "swampmaster",
            tags = {"swampmaser", "merm_flee"},
            root = true,
        },

        ------------------------------------------------------------------------------

        wurt_mermkingshoulders = {
            pos = {ITEM_QUESTS_X, POS_Y_1},
            group = "swampmaster",
            tags = {"swampmaser", "mermking_quest"},
            root = true,
            connects = {
                "wurt_mermkingcrown",
            },
            onactivate = function(inst) inst:TryPauldronUpgrade() end,
            ondeactivate = function(inst) inst:TryPauldronDowngrade() end,
        },

        wurt_mermkingcrown = {
            pos = {ITEM_QUESTS_X, POS_Y_2},
            group = "swampmaster",
            tags = {"swampmaser", "mermking_quest"},
            connects = {
                "wurt_mermkingtrident",
            },
            onactivate = function(inst) inst:TryCrownUpgrade() end,
            ondeactivate = function(inst) inst:TryCrownDowngrade() end,
        },

        wurt_mermkingtrident = {
            pos = {ITEM_QUESTS_X, POS_Y_3},
            group = "swampmaster",
            tags = {"swampmaser", "mermking_quest"},
            onactivate = function(inst) inst:TryTridentUpgrade() end,
            ondeactivate = function(inst) inst:TryTridentDowngrade() end,
        },

        ------------------------------------------------------------------------------

        wurt_allegiance_lock_1 = {
            pos = {ALLIEGIANCE_TITLE_X, POS_Y_1},
            group = "allegiance",
            tags = {"allegiance", "lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
        },

        wurt_allegiance_lock_2 = SkillTreeFns.MakeFuelWeaverLock(
            { pos = {ALLIEGIANCE_1_X + TILEGAP, POS_Y_2} }
        ),

        wurt_allegiance_lock_4 = SkillTreeFns.MakeNoLunarLock(
            { pos = {ALLIEGIANCE_1_X + TILEGAP, POS_Y_3} }
        ),

        wurt_shadow_allegiance_1 = {
            pos = {ALLIEGIANCE_1_X + TILEGAP , POS_Y_4},
            group = "allegiance",
            tags = {"allegiance", "shadow", "shadow_favor"},
            locks = {"wurt_allegiance_lock_1", "wurt_allegiance_lock_2", "wurt_allegiance_lock_4"},

            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                inst:AddTag(SPELLTYPES.WURT_SHADOW.."_spelluser")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WURT.ALLEGIANCE_SHADOW_RESIST, "allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WURT.ALLEGIANCE_VS_LUNAR_BONUS, "allegiance_shadow")
                end
            end,

            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                inst:RemoveTag(SPELLTYPES.WURT_SHADOW.."_spelluser")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "allegiance_shadow")
                end
            end,

            connects = {
                "wurt_shadow_allegiance_2",
            },
        },

        wurt_allegiance_lock_3 = SkillTreeFns.MakeCelestialChampionLock(
            { pos = {ALLIEGIANCE_1_X, POS_Y_2} }
        ),

        wurt_allegiance_lock_5 = SkillTreeFns.MakeNoShadowLock(
            { pos = {ALLIEGIANCE_1_X, POS_Y_3} }
        ),

        wurt_lunar_allegiance_1 = {
            pos = {ALLIEGIANCE_1_X , POS_Y_4},
            group = "allegiance",
            tags = {"allegiance", "lunar", "lunar_favor"},
            locks = {"wurt_allegiance_lock_1", "wurt_allegiance_lock_3", "wurt_allegiance_lock_5"},

            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                inst:AddTag(SPELLTYPES.WURT_LUNAR.."_spelluser")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WURT.ALLEGIANCE_LUNAR_RESIST, "allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WURT.ALLEGIANCE_VS_SHADOW_BONUS, "allegiance_lunar")
                end
            end,

            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                inst:RemoveTag(SPELLTYPES.WURT_LUNAR.."_spelluser")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "allegiance_lunar")
                end
            end,

            connects = {
                "wurt_lunar_allegiance_2",
            },
        },

        wurt_lunar_allegiance_2 = {
            pos = {ALLIEGIANCE_1_X, POS_Y_5},
            group = "allegiance",
            tags = {"allegiance", "lunar"},
            onactivate = CreateAddTagFn(SPELLTYPES.LUNAR_SWAMP_BOMB.."_spelluser"),
            ondeactivate = CreateRemoveTagFn(SPELLTYPES.LUNAR_SWAMP_BOMB.."_spelluser"),
        },

        wurt_shadow_allegiance_2 = {
            pos = {ALLIEGIANCE_1_X+TILEGAP, POS_Y_5},
            group = "allegiance",
            tags = {"allegiance", "shadow"},
            onactivate = CreateAddTagFn(SPELLTYPES.SHADOW_SWAMP_BOMB.."_spelluser"),
            ondeactivate = CreateRemoveTagFn(SPELLTYPES.SHADOW_SWAMP_BOMB.."_spelluser"),
        },
    }

    for name, data in pairs(skills) do
        local uppercase_name = string.upper(name)

        if not data.desc then
            data.desc = WURT_SKILL_STRINGS[uppercase_name.."_DESC"]
        end

        -- If it's not a lock.
        if not data.lock_open then
            if not data.title then
                data.title = WURT_SKILL_STRINGS[uppercase_name.."_TITLE"]
            end

            if not data.icon then
                data.icon = name
            end
        end
    end

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData