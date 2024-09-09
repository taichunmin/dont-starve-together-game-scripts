

local GAP = 38
local BIGGAP = 54
local CATGAP = 87 --math.abs(-214 - 228)/(#ORDERS)
local X = -218
local Y = 170 --6

local TITLE_Y_OFFSET = 30
local ORDERS =
{
    {"might",           {-218,                  Y+TITLE_Y_OFFSET}},
    {"training",        {-70,                   Y+TITLE_Y_OFFSET}},
    {"planardamage",    {90 ,                   Y+TITLE_Y_OFFSET}},
    {"allegiance",      {200,                   Y+TITLE_Y_OFFSET}},
}

--------------------------------------------------------------------------------------------------

local function RecalculatePlanarDamage(inst, fromload)
    inst:RecalculatePlanarDamage()
end

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- MIGHT
        wolfgang_critwork_1 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_CRITWORK_1_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_CRITWORK_1_DESC,
            icon = "wolfgang_critwork_1",
            pos = {X,Y},
            --pos = {1,0},
            group = "might",
            tags = {"might"},
            root = true,
            connects = {
                "wolfgang_critwork_2",
            },
        },
        wolfgang_critwork_2 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_CRITWORK_2_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_CRITWORK_2_DESC,
            icon = "wolfgang_critwork_2",
            pos = {X,Y-GAP},
            --pos = {1,0},
            group = "might",
            tags = {"might"},
            connects = {
                "wolfgang_critwork_3",
            },
        }, 
        wolfgang_critwork_3 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_CRITWORK_3_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_CRITWORK_3_DESC,
            icon = "wolfgang_critwork_3",
            pos = {X,Y-GAP*2},
            --pos = {1,0},
            group = "might",
            tags = {"might"},
        }, 

        -- TRAINING
        -- 1

        wolfgang_autogym = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_AUTO_GYM_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_AUTO_GYM_DESC,
            icon = "wolfgang_autogym",
            pos = {X+CATGAP,Y},
            --pos = {1,0},
            group = "training",
            tags = {"autogym"},
            root = true,
        },

        wolfgang_normal_coach = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_COACH_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_COACH_DESC,
            icon = "wolfgang_coach",
            pos = {X+CATGAP+GAP,Y},
            --pos = {1,0},
            group = "training",
            tags = {"training"},
            onactivate = function(inst, fromload) inst:AddTag("wolfgang_coach") end,
            ondeactivate = function(inst, fromload) inst:RemoveTag("wolfgang_coach") end,
            root = true,
            connects = {
                "wolfgang_normal_speed",
            },            
        }, 

        wolfgang_normal_speed = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_NORMAL_SPEED_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_NORMAL_SPEED_DESC,
            icon = "wolfgang_speed",
            pos = {X+CATGAP+GAP,Y-GAP},
            --pos = {X+CATGAP*2,Y-GAP*2-BIGGAP},
            --pos = {1,0},
            group = "training",
            tags = {"training"},
            onactivate = function(inst, fromload) inst:RecalculateMightySpeed() end,
            ondeactivate = function(inst, fromload) inst:RecalculateMightySpeed() end,
        },         

        wolfgang_dumbbell_crafting = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_DUMBBELL_CRAFTING_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_DUMBBELL_CRAFTING_DESC,
            icon = "wolfgang_dumbbell_crafting",
            pos = {X+CATGAP+GAP*2,Y},
            --pos = {1,0},
            group = "training",
            tags = {"dumbbell_craft"},
            root = true,
            connects = {
                "wolfgang_dumbbell_throwing_1",
            },             
            defaultfocus = true,
        }, 


        -- 2
        wolfgang_dumbbell_throwing_1 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_DUMBBELL_THROWING_1_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_DUMBBELL_THROWING_1_DESC,
            icon = "wolfgang_dumbbell_throwing_1",
            pos = {X+CATGAP+GAP*2,Y-GAP},
            --pos = {1,0},
            group = "training",
            tags = {"dumbbell_throwing"},
            connects = {
                "wolfgang_dumbbell_throwing_2",
            },            
        }, 

        wolfgang_dumbbell_throwing_2 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_DUMBBELL_THROWING_2_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_DUMBBELL_THROWING_2_DESC,
            icon = "wolfgang_dumbbell_throwing_2",
            pos = {X+CATGAP+GAP*2,Y-GAP*2},
            --pos = {1,0},
            group = "training",
            tags = {"dumbbell_throwing"},
        },

        wolfgang_overbuff_1 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_1_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_1_DESC,
            icon = "wolfgang_overbuff_1",
            pos = {X+CATGAP+GAP*3,Y},
            --pos = {1,0},
            group = "training",
            tags = {"overbuff"},
            onactivate = function(inst, fromload)
                    inst:AddTag("wolfgang_overbuff_1")
                    if inst.components.mightiness:GetOverMax() < TUNING.SKILLS.WOLFGANG_OVERBUFF_1 then
                        inst.components.mightiness:SetOverMax(TUNING.SKILLS.WOLFGANG_OVERBUFF_1) 
                    end
                end,
            root = true,
            connects = {
                "wolfgang_overbuff_2",
            },             
        }, 

        --3
        wolfgang_overbuff_2 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_2_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_2_DESC,
            icon = "wolfgang_overbuff_2",
            pos = {X+CATGAP+GAP*3,Y-GAP},
            --pos = {1,0},
            group = "training",
            tags = {"overbuff"},
            onactivate = function(inst, fromload)
                    inst:AddTag("wolfgang_overbuff_2")
                    if inst.components.mightiness:GetOverMax() < TUNING.SKILLS.WOLFGANG_OVERBUFF_2 then
                        inst.components.mightiness:SetOverMax(TUNING.SKILLS.WOLFGANG_OVERBUFF_2) 
                    end
                end,
            connects = {
                "wolfgang_overbuff_3",
            },             
        },   

        wolfgang_overbuff_3 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_3_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_3_DESC,
            icon = "wolfgang_overbuff_3",
            pos = {X+CATGAP+GAP*3,Y-GAP*2},
            --pos = {1,0},
            group = "training",
            tags = {"overbuff"},
            onactivate = function(inst, fromload)
                    inst:AddTag("wolfgang_overbuff_3")
                    if inst.components.mightiness:GetOverMax() < TUNING.SKILLS.WOLFGANG_OVERBUFF_3 then
                        inst.components.mightiness:SetOverMax(TUNING.SKILLS.WOLFGANG_OVERBUFF_3) 
                    end
                end,
            connects = {
                "wolfgang_overbuff_4",
            }, 
        }, 

        wolfgang_overbuff_4 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_4_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_4_DESC,
            icon = "wolfgang_overbuff_4",
            pos = {X+CATGAP+GAP*3,Y-GAP*3},
            --pos = {1,0},
            group = "training",
            tags = {"overbuff"},
            onactivate = function(inst, fromload)
                    inst:AddTag("wolfgang_overbuff_4")
                    if inst.components.mightiness:GetOverMax() < TUNING.SKILLS.WOLFGANG_OVERBUFF_4 then
                        inst.components.mightiness:SetOverMax(TUNING.SKILLS.WOLFGANG_OVERBUFF_4) 
                    end
                end,
            connects = {
                "wolfgang_overbuff_5",
            },             
        },

        wolfgang_overbuff_5 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_5_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_GYM_OVERBUFF_5_DESC,
            icon = "wolfgang_overbuff_5",
            pos = {X+CATGAP+GAP*3,Y-GAP*4},
            --pos = {1,0},
            group = "training",
            tags = {"overbuff"},
            onactivate = function(inst, fromload)
                    inst:AddTag("wolfgang_overbuff_5")
                    if inst.components.mightiness:GetOverMax() < TUNING.SKILLS.WOLFGANG_OVERBUFF_5 then
                        inst.components.mightiness:SetOverMax(TUNING.SKILLS.WOLFGANG_OVERBUFF_5) 
                    end
                end,            
        },



        -- SUPER        
        wolfgang_planardamage_1 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_1_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_1_DESC,
            icon = "wolfgang_planardamage_1",
            pos = {90,Y},
            --pos = {1,0},
            group = "planardamage",
            tags = {"planardamage"},
            onactivate = RecalculatePlanarDamage,
            ondeactivate = RecalculatePlanarDamage,
            root = true,
            connects = {
                "wolfgang_planardamage_2",
            }, 
        }, 

        wolfgang_planardamage_2 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_2_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_2_DESC,
            icon = "wolfgang_planardamage_2",
            pos = {90,Y-GAP},
            --pos = {1,0},
            group = "planardamage",
            tags = {"planardamage"},
            onactivate = RecalculatePlanarDamage,
            ondeactivate = RecalculatePlanarDamage,
            connects = {
                "wolfgang_planardamage_3",
            },             
        },

        wolfgang_planardamage_3 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_3_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_3_DESC,
            icon = "wolfgang_planardamage_3",
            pos = {90,Y-GAP*2},
            --pos = {1,0},
            group = "planardamage",
            tags = {"planardamage"},
            onactivate = RecalculatePlanarDamage,
            ondeactivate = RecalculatePlanarDamage,
            connects = {
                "wolfgang_planardamage_4",
            },             
        }, 

        wolfgang_planardamage_4 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_4_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_4_DESC,
            icon = "wolfgang_planardamage_4",
            pos = {90,Y-GAP*3},
            --pos = {1,0},
            group = "planardamage",
            tags = {"planardamage"},
            onactivate = RecalculatePlanarDamage,
            ondeactivate = RecalculatePlanarDamage,
            connects = {
                "wolfgang_planardamage_5",
            },             
        }, 

        wolfgang_planardamage_5 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_5_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_MIGHTY_PLANAR_DAMAGE_5_DESC,
            icon = "wolfgang_planardamage_5",
            pos = {90,Y-GAP*4},
            --pos = {1,0},
            group = "planardamage",
            tags = {"planardamage"},
            onactivate = RecalculatePlanarDamage,
            ondeactivate = RecalculatePlanarDamage,
        },  

        wolfgang_allegiance_lock_1 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_2_DESC,
            pos = {200-GAP/2,Y},  
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,
            root = true,
            connects = {
                "wolfgang_allegiance_shadow_1",
            },
        },

        wolfgang_allegiance_lock_2 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_3_DESC,
            pos = {200+GAP/2,Y},
            --pos = {0,-1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            lock_open = function(prefabname, activatedskills, readonly) 
                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,
            root = true,
            connects = {
                "wolfgang_allegiance_lunar_1",
            },
        },

        wolfgang_allegiance_lock_3 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_4_DESC,
            pos = {200-GAP/2,Y-GAP},
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
                "wolfgang_allegiance_shadow_1",
            },
        }, 

        wolfgang_allegiance_lock_4 = {
            desc = STRINGS.SKILLTREE.ALLEGIANCE_LOCK_5_DESC,
            pos = {200+GAP/2,Y-GAP},
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
                "wolfgang_allegiance_lunar_1",
            },
        },

        wolfgang_allegiance_shadow_1 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_SHADOW_1_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_SHADOW_1_DESC,
            icon = "wolfgang_allegiance_shadow_1",
            pos = {200-GAP/2,Y-GAP*2},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            locks = {"wolfgang_allegiance_lock_1", "wolfgang_allegiance_lock_3"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_SHADOW_RESIST_1, "wolfgang_allegiance_shadow_1")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_VS_LUNAR_BONUS_1, "wolfgang_allegiance_shadow_1")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "wolfgang_allegiance_shadow_1")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "wolfgang_allegiance_shadow_1")
                end
            end,            
            connects = {
                "wolfgang_allegiance_shadow_2",
            },
        },

        wolfgang_allegiance_shadow_2 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_SHADOW_2_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_SHADOW_2_DESC,
            icon = "wolfgang_allegiance_shadow_2",
            pos = {200-GAP/2,Y-GAP*3},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"}, 
            onactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_VS_LUNAR_BONUS_2, "wolfgang_allegiance_shadow_2")
                end
            end,
            ondeactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "wolfgang_allegiance_shadow_2")
                end
            end,                        
            connects = {
                "wolfgang_allegiance_shadow_3",
            },
        },  

        wolfgang_allegiance_shadow_3 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_SHADOW_3_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_SHADOW_3_DESC,
            icon = "wolfgang_allegiance_shadow_3",
            pos = {200-GAP/2,Y-GAP*4},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            onactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_VS_LUNAR_BONUS_3, "wolfgang_allegiance_shadow_3")
                end
            end,
            ondeactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "wolfgang_allegiance_shadow_3")
                end
            end, 
        },      

        wolfgang_allegiance_lunar_1 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_LUNAR_1_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_LUNAR_1_DESC,
            icon = "wolfgang_allegiance_lunar_1",
            pos = {200+GAP/2,Y-GAP*2},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            locks = {"wolfgang_allegiance_lock_2", "wolfgang_allegiance_lock_4"},
            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_LUNAR_RESIST_1, "wolfgang_allegiance_lunar_1")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_VS_SHADOW_BONUS_1, "wolfgang_allegiance_lunar_1")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")
                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "wolfgang_allegiance_lunar_1")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "wolfgang_allegiance_lunar_1")
                end
            end,
            connects = {
                "wolfgang_allegiance_lunar_2",
            },            
        },

        wolfgang_allegiance_lunar_2 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_LUNAR_2_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_LUNAR_2_DESC,
            icon = "wolfgang_allegiance_lunar_2",
            pos = {200+GAP/2,Y-GAP*3},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            onactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_VS_SHADOW_BONUS_2, "wolfgang_allegiance_lunar_2")
                end
            end,
            ondeactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "wolfgang_allegiance_lunar_2")
                end
            end,                        
            connects = {
                "wolfgang_allegiance_lunar_3",
            },
        }, 

        wolfgang_allegiance_lunar_3 = {
            title = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_LUNAR_3_TITLE,
            desc = STRINGS.SKILLTREE.WOLFGANG.WOLFGANG_ALLEGIANCE_LUNAR_3_DESC,
            icon = "wolfgang_allegiance_lunar_3",
            pos = {200+GAP/2,Y-GAP*4},
            --pos = {0,-2},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},            
            onactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WOLFGANG_ALLEGIANCE_VS_SHADOW_BONUS_3, "wolfgang_allegiance_lunar_3")
                end
            end,
            ondeactivate = function(inst, fromload)
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "wolfgang_allegiance_lunar_3")
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