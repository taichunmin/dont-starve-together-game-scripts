local ORDERS =
{
    {"torch",           { -214+18   , 176 + 30 }},
    {"alchemy",         { -62       , 176 + 30 }},
    {"beard",           { 66+18     , 176 + 30 }},
    {"allegiance",      { 204       , 176 + 30 }},
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {
        wilson_alchemy_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_1_DESC,
            icon = "wilson_alchemy_1",
            pos = {-62,176},
            --pos = {1,0},
            group = "alchemy",
            tags = {"alchemy"},
            root = true,
            connects = {
                "wilson_alchemy_2",
                "wilson_alchemy_3",
                "wilson_alchemy_4",
            },
        },
        wilson_alchemy_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_2_DESC,
            icon = "wilson_alchemy_gem_1",
            pos = {-62,176-54},        
            --pos = {0,-1},
            group = "alchemy",
            tags = {"alchemy"},
            connects = {
                "wilson_alchemy_5",
            },
        },
        wilson_alchemy_5 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_5_DESC,
            icon = "wilson_alchemy_gem_2",
            pos = {-62,176-54-38},        
            --pos = {0,-2},
            group = "alchemy",
            tags = {"alchemy"},
            connects = {
                "wilson_alchemy_6",
            },
        },
        wilson_alchemy_6 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_6_DESC,
            icon = "wilson_alchemy_gem_3",
            pos = {-62,176-54-38-38},        
            --pos = {0,-3},
            group = "alchemy",
            tags = {"alchemy"},
        },

        wilson_alchemy_3 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_3_DESC,
            icon = "wilson_alchemy_ore_1",
            pos = {-62-38,176-54},
            --pos = {1,-1},
            group = "alchemy",
            tags = {"alchemy"},
            connects = {
                "wilson_alchemy_7",
            },
        },
        wilson_alchemy_7 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_7_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_7_DESC,
            icon = "wilson_alchemy_ore_2",
            pos = {-62-38,176-54-38},
            --pos = {1,-2},
            group = "alchemy",
            tags = {"alchemy"},
            connects = {
                "wilson_alchemy_8",
            },
        },
        wilson_alchemy_8 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_8_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_8_DESC,
            icon = "wilson_alchemy_ore_3",
            pos = {-62-38,176-54-38-38},
            --pos = {1,-3},
            group = "alchemy",
            tags = {"alchemy"},
        },

        wilson_alchemy_4 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_4_DESC,
            icon = "wilson_alchemy_iky_1",
            pos = {-62+38,176-54},
            --pos = {2,-1},
            group = "alchemy",
            tags = {"alchemy"},
            connects = {
                "wilson_alchemy_9",
            },
        },
        wilson_alchemy_9 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_9_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_9_DESC,
            icon = "wilson_alchemy_iky_2",
            pos = {-62+38,176-54-38},
            --pos = {2,-2},
            group = "alchemy",
            tags = {"alchemy"},
            connects = {
                "wilson_alchemy_10",
            },
        },
        wilson_alchemy_10 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_10_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALCHEMY_10_DESC,
            icon = "wilson_alchemy_iky_3",
            pos = {-62+38,176-54-38-38},
            --pos = {2,-3},
            group = "alchemy",
            tags = {"alchemy"},
        },

        wilson_torch_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_DESC,
            icon = "wilson_torch_time_1",
            pos = {-214,176},
            --pos = {0,0},
            group = "torch",
            tags = {"torch", "torch1"},
            root = true,
            connects = {
                "wilson_torch_2",
            },
        },
        wilson_torch_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_2_DESC,
            icon = "wilson_torch_time_2",
            pos = {-214,176-38},
            --pos = {0,-1},
            group = "torch",
            tags = {"torch", "torch1"},
            connects = {
                "wilson_torch_3",
            },
        },
        wilson_torch_3 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_3_DESC,
            icon = "wilson_torch_time_3",
            pos = {-214,176-38-38},
            --pos = {0,-2},
            group = "torch",
            tags = {"torch", "torch1"},
        },
        wilson_torch_4 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_4_DESC,
            icon = "wilson_torch_brightness_1",
            pos = {-214+38,176},        
            --pos = {1,0},
            group = "torch",
            tags = {"torch", "torch1"},
            root = true,
            connects = {
                "wilson_torch_5",
            },
            defaultfocus = true,
        },
        wilson_torch_5 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_5_DESC,
            icon = "wilson_torch_brightness_2",
            pos = {-214+38,176-38},
            --pos = {1,-1},
            group = "torch",
            tags = {"torch", "torch1"},
            connects = {
                "wilson_torch_6",
            },
        },
        wilson_torch_6 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_6_DESC,
            icon = "wilson_torch_brightness_3",
            pos = {-214+38,176-38-38},
            --pos = {1,-2},
            group = "torch",
            tags = {"torch", "torch1"},
        }, 

        wilson_torch_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_1_LOCK_DESC,
            pos = {-214+18,58},
            --pos = {2,0},
            group = "torch",
            tags = {"torch","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "torch1", activatedskills) > 2
            end,
            connects = {
                "wilson_torch_7",
            },
        },
        wilson_torch_7 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_7_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_TORCH_7_DESC,
            icon = "wilson_torch_throw",
            pos = {-214+18,58-38},        
            --pos = {2,-1},
            group = "torch",
            tags = {"torch"},
        },    

        wilson_beard_1 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_DESC,
            icon = "wilson_beard_insulation_1",        
            pos = {66,176},
            --pos = {0,0},
            group = "beard",
            tags = {"beard", "beard1"},
            root = true,
            connects = {
                "wilson_beard_2",
            },
        },
        wilson_beard_2 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_2_DESC,
            icon = "wilson_beard_insulation_2",
            pos = {66,176-38},
            --pos = {0,-1},
            group = "beard",
            tags = {"beard", "beard1"},
            connects = {
                "wilson_beard_3",
            },
        },
        wilson_beard_3 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_3_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_3_DESC,
            icon = "wilson_beard_insulation_3",
            pos = {66,176-38-38},
            --pos = {0,-2},
            group = "beard",
            tags = {"beard", "beard1"},
        },

        wilson_beard_4 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_4_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_4_DESC,
            icon = "wilson_beard_speed_1",
            pos = {66+38,176},
            --pos = {1,0},
            group = "beard",
            tags = {"beard", "beard1"},
            root = true,
            connects = {
                "wilson_beard_5",
            },
        },
        wilson_beard_5 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_5_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_5_DESC,
            icon = "wilson_beard_speed_2",
            pos = {66+38,176-38},
            --pos = {1,-1},
            group = "beard",
            tags = {"beard", "beard1"},
            connects = {
                "wilson_beard_6",
            },
        },
        wilson_beard_6 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_6_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_6_DESC,
            icon = "wilson_beard_speed_3",
            pos = {66+38,176-38-38},
            --pos = {1,-2},
            group = "beard",
            tags = {"beard", "beard1"},
        },

        wilson_beard_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_1_LOCK_DESC,
            pos = {66+18,58},
            --pos = {2,0},
            group = "beard",
            tags = {"beard","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "beard1", activatedskills) > 2
            end,
            connects = {
                "wilson_beard_7",
            },
        },
        wilson_beard_7 = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_7_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_BEARD_7_DESC,
            icon = "wilson_beard_inventory",
            pos = {66+18,58-38},
            --pos = {2,-1},
            onactivate = function(inst, fromload)
                    if inst.components.beard then
                        inst.components.beard:UpdateBeardInventory()
                    end
                end,
            group = "beard",
            tags = {"beard"},
        },

        wilson_allegiance_lock_1 = {
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LOCK_1_DESC,
            pos = {204+2,176},
            --pos = {0.5,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
            connects = {
                "wilson_allegiance_shadow",
            },
        },

        wilson_allegiance_lock_2 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_2_DESC,
            pos = {204-22+2,176-50+2},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            connects = {
                "wilson_allegiance_shadow",
            },
        },

        wilson_allegiance_lock_4 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC,
            pos = {204-22+2,176-100+8},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "wilson_allegiance_shadow",
            },
        },    

        wilson_allegiance_shadow = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_SHADOW_DESC,
            icon = "wilson_favor_shadow",
            pos = {204-22+2 ,176-110-38+10},  --  -22
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            locks = {"wilson_allegiance_lock_1", "wilson_allegiance_lock_2", "wilson_allegiance_lock_4"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_SHADOW_RESIST, "wilson_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_LUNAR_BONUS, "wilson_allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "wilson_allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "wilson_allegiance_shadow")
                end
            end,
        },  

        wilson_allegiance_lock_3 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_3_DESC,
            pos = {204+22+2,176-50+2},
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            connects = {
                "wilson_allegiance_lunar",
            },
        },

        wilson_allegiance_lock_5 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_5_DESC,
            pos = {204+22+2,176-100+8},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                if SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills) == 0 then
                    return true
                end
    
                return nil -- Important to return nil and not false.
            end,
            connects = {
                "wilson_allegiance_lunar",
            },
        },

        wilson_allegiance_lunar = {
            title = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_TITLE,
            desc = STRINGS.SKILLTREE.WILSON.WILSON_ALLEGIANCE_LUNAR_DESC,
            icon = "wilson_favor_lunar",
            pos = {204+22+2 ,176-110-38+10},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            locks = {"wilson_allegiance_lock_1", "wilson_allegiance_lock_3","wilson_allegiance_lock_5"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_LUNAR_RESIST, "wilson_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILSON_ALLEGIANCE_VS_SHADOW_BONUS, "wilson_allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "wilson_allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "wilson_allegiance_lunar")
                end
            end,
        },
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData