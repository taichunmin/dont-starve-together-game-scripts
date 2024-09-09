local ORDERS =
{
    {"lighter",             { -200+20   , 176 + 26 }},
    {"bernie",              { 2         , 176 + 18 }},
    {"allegiance",          { 185       , 176 + 26 }},
}

--------------------------------------------------------------------------------------------------

local HGAP = 35
local WGAP = 44
local TOP = 186
local NUDGE = 10
local SMALLNUDGE = 5

local CAT1 = -200 -20
local CAT2 = -32 -20
local CAT3 = 150 -30

-- controlled burn
local L1X = -8
local L1Y = -10

--embers
local L2X = -6
local L2Y = 2

--lighter
local L3X = -5
local L3Y = -10

--Bernie block
local B1X = 8
local B1Y = -20

--Bottom Bernie Block
local B2X = 7
local B2Y = 3

-- shadow affinity
local A1X = 16
local A1Y = -12

-- lunar affinity
local A2X = 16
local A2Y = -8



local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {
        willow_controlled_burn_1 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_CONTROLLED_BURN_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_CONTROLLED_BURN_1_DESC,
            icon = "willow_controlled_burn_1",
            pos = {CAT1+NUDGE +L1X ,TOP +L1Y },
            group = "lighter",
            tags = {"lighter"},
            onactivate = function(inst, fromload)
                    --inst:AddTag("fire_mastery_1")
                    inst:AddTag("controlled_burner")
                end,
            root = true,
            connects = {
                "willow_controlled_burn_2",
            },
        },

        willow_controlled_burn_2 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_CONTROLLED_BURN_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_CONTROLLED_BURN_2_DESC,
            icon = "willow_controlled_burn_2",
            pos = {CAT1+NUDGE +L1X ,TOP-HGAP +L1Y -4 },
            group = "lighter",
            tags = {"lighter"},
            onactivate = function(inst, fromload)
                  
                end,
            connects = {
                "willow_controlled_burn_3",
            },
        },

        willow_controlled_burn_3 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_CONTROLLED_BURN_3_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_CONTROLLED_BURN_3_DESC,
            icon = "willow_controlled_burn_3",
            pos = {CAT1+NUDGE +L1X ,TOP-HGAP-HGAP +L1Y-8 },
            group = "lighter",
            tags = {"lighter"},
            onactivate = function(inst, fromload)
                  
                end,
        },

        willow_attuned_lighter = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_ATTUNED_LIGHTER_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ATTUNED_LIGHTER_DESC,
            icon = "willow_attuned_lighter",
            pos = {CAT1+WGAP+L2X+27,TOP-HGAP-HGAP-HGAP+L2Y+12},
            group = "lighter",
            tags = {"lighter"},
            connects = {
                "willow_embers",
            },
            root = true,
        },

        willow_embers = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_EMBERS_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_EMBERS_DESC,
            icon = "willow_embers",
            pos = {CAT1+WGAP+L2X+27,TOP-HGAP-HGAP-HGAP-HGAP+L2Y+8},
            group = "lighter",
            tags = {"lighter"},
            onactivate = function(inst, fromload)
                    inst:AddTag("ember_master")
                end,
            connects = {
                "willow_fire_burst",
                "willow_fire_ball",
                "willow_fire_frenzy",
            },
        },

        willow_fire_burst = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_FIRE_BURST_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_FIRE_BURST_DESC,
            icon = "willow_fire_burst",
            pos = {CAT1+L2X,TOP-HGAP-HGAP-HGAP-HGAP-HGAP+L2Y},
            group = "lighter",
            tags = {"lighter"},
        },

        willow_fire_ball = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_FIRE_BALL_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_FIRE_BALL_DESC,
            icon = "willow_fire_ball",
            pos = {CAT1+WGAP+L2X,TOP-HGAP-HGAP-HGAP-HGAP-HGAP+L2Y},
            group = "lighter",
            tags = {"lighter"},
        },

        willow_fire_frenzy = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_FIRE_FRENZY_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_FIRE_FRENZY_DESC,
            icon = "willow_fire_frenzy",
            pos = {CAT1+WGAP+WGAP+L2X,TOP-HGAP-HGAP-HGAP-HGAP-HGAP+L2Y},
            group = "lighter",
            tags = {"lighter"},
        },        
 
        willow_lightradius_1 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_LIGHTRADIUS_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_LIGHTRADIUS_1_DESC,
            icon = "willow_lightradius_1",
            pos = {CAT1+WGAP+WGAP-NUDGE+L3X,TOP+L3Y},
            group = "lighter",
            tags = {"lighter"},
            root = true,
            connects = {
                "willow_lightradius_2",
            },
            defaultfocus = true,
        },

        willow_lightradius_2 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_LIGHTRADIUS_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_LIGHTRADIUS_2_DESC,
            icon = "willow_lightradius_2",
            pos = {CAT1+WGAP+WGAP-NUDGE+L3X,TOP-HGAP+L3Y-4},
            group = "lighter",
            tags = {"lighter"},
        },

        -- BERNIE
        willow_bernieregen_1 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEREGEN_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEREGEN_1_DESC,
            icon = "willow_bernieregen_1",
            pos = {CAT2+B1X,TOP+B1Y},
            group = "bernie",
            tags = {"bernie"},
            root = true,
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,
            connects = {
                "willow_bernieregen_2",
            }                
        },
 
        willow_bernieregen_2 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEREGEN_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEREGEN_2_DESC,
            icon = "willow_bernieregen_2", 
            pos = {CAT2+B1X,TOP-HGAP+B1Y-4},
            --pos = {1,0},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,
        },

        willow_berniesanity_1 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESANITY_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESANITY_1_DESC,
            icon = "willow_berniesanity_1",
            pos = {CAT2+WGAP+B1X,TOP+B1Y},
            group = "bernie",
            tags = {"bernie"},
            root = true,
            connects = {
                "willow_berniesanity_2",
            },
        },

        willow_berniesanity_2 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESANITY_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESANITY_2_DESC,
            icon = "willow_berniesanity_2",
            pos = {CAT2+WGAP+B1X,TOP-HGAP+B1Y-4},
            group = "bernie",
            tags = {"bernie"},
            connects = {
                "willow_bernieai",
            }
        },

        willow_bernieai = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEAI_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEAI_DESC,
            icon = "willow_bernieai",
            pos = {CAT2+WGAP+B1X,TOP-HGAP-HGAP+B1Y-8},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)

                end,
        },

        willow_berniespeed_1 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESPEED_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESPEED_1_DESC,
            icon = "willow_berniespeed_1",
            pos = {CAT2+WGAP+WGAP+B1X,TOP+B1Y},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,
            root = true,
            connects = {
                "willow_berniespeed_2",
            },
        },

        willow_berniespeed_2 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESPEED_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIESPEED_2_DESC,
            icon = "willow_berniespeed_2",
            pos = {CAT2+WGAP+WGAP+B1X,TOP-HGAP+B1Y-4},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,     
        },

        willow_bernie_lock = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIE_LOCK_DESC,
            pos = {CAT2+B2X,TOP-HGAP-HGAP-HGAP+B2Y},
            group = "bernie",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local bernie_skills = SkillTreeFns.CountTags(prefabname, "bernie", activatedskills)
                return bernie_skills >= 4
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_berniehealth_1",
            },                
        },

        willow_berniehealth_1 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEHEALTH_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEHEALTH_1_DESC,
            icon = "willow_berniehealth_1",
            pos = {CAT2+B2X,TOP-HGAP-HGAP-HGAP-HGAP+B2Y},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,
            connects = {
                "willow_berniehealth_2",
            },
        },

        willow_berniehealth_2 = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEHEALTH_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIEHEALTH_2_DESC,
            icon = "willow_berniehealth_2",
            pos = {CAT2+B2X,TOP-HGAP-HGAP-HGAP-HGAP-HGAP+B2Y},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,               
        },

        willow_bernie_lock_2 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BERNIE_DOUBLE_LOCK_DESC,
            pos = {CAT2+WGAP+WGAP+B2X,TOP-HGAP-HGAP-HGAP+B2Y},
            --pos = {1,0},
            group = "bernie",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local bernie_skills = SkillTreeFns.CountTags(prefabname, "bernie", activatedskills)
                return bernie_skills >= 8
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_burnignbernie",
            },                
        },

        -- FIXME(JBK): This is a typo 'burnign' only fix this when something else in the skill tree gets fixed and players need respec.
        willow_burnignbernie = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_BURNINGBERNIE_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_BURNINGBERNIE_DESC,
            icon = "willow_burnignbernie",
            pos = {CAT2+WGAP+WGAP+B2X,TOP-HGAP-HGAP-HGAP-HGAP+B2Y},
            --pos = {1,0},
            group = "bernie",
            tags = {"bernie"},
            onactivate = function(inst, fromload)
                    if inst.bigbernies then
                        for bern, val in pairs(inst.bigbernies)do
                            bern:onLeaderChanged(inst)
                        end
                    end
                end,
        },        

        -- ALLEGIANCE        
        willow_allegiance_lock_1 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LOCK_1_DESC,
            pos = {CAT3+WGAP+A1X,TOP+A1Y},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local lunar_skills = SkillTreeFns.CountTags(prefabname, "lunar_favor", activatedskills)
                if lunar_skills > 0 then
                    return false
                end

                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("fuelweaver_killed") == "1"
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_allegiance_shadow_fire",
                "willow_allegiance_shadow_bernie",
            },
        },

        willow_allegiance_lock_2 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LOCK_2_DESC,
            pos = {CAT3+NUDGE+A1X,TOP-HGAP+A1Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,            
            lock_open = function(prefabname, activatedskills, readonly) 
                local bernie_skills = SkillTreeFns.CountTags(prefabname, "bernie", activatedskills)
                return bernie_skills >= 6
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_allegiance_shadow_bernie",
            },
        },

        willow_allegiance_lock_3 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LOCK_3_DESC,
            pos = {CAT3+WGAP+WGAP-NUDGE+A1X,TOP-HGAP+A1Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                local lighter_skills = SkillTreeFns.CountTags(prefabname, "lighter", activatedskills)
                return lighter_skills >= 7
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_allegiance_shadow_fire",
            },
        },

        willow_allegiance_shadow_fire = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_SHADOW_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_SHADOW_1_DESC,
            icon = "willow_allegiance_shadow_fire",
            pos = {CAT3+WGAP+WGAP-NUDGE+A1X,TOP-HGAP-HGAP+A1Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","shadow_favor"},
            locks = {"willow_allegiance_lock_1", "willow_allegiance_lock_3"},
            onactivate = function(inst, fromload)
                    if not inst.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_bernie") then
                        inst:AddTag("player_shadow_aligned")
                        local damagetyperesist = inst.components.damagetyperesist
                        if damagetyperesist then
                            damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_SHADOW_RESIST, "willow_allegiance_shadow")
                        end
                        local damagetypebonus = inst.components.damagetypebonus
                        if damagetypebonus then
                            damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_VS_LUNAR_BONUS, "willow_allegiance_shadow")                        
                        end
                    end
                end,
        },

        willow_allegiance_shadow_bernie = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_SHADOW_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_SHADOW_2_DESC,
            icon = "willow_allegiance_shadow_bernie",
            pos = {CAT3+NUDGE+A1X,TOP-HGAP-HGAP+A1Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","shadow_favor"},
            locks = {"willow_allegiance_lock_1", "willow_allegiance_lock_2"},
            onactivate = function(inst, fromload)
                    if not inst.components.skilltreeupdater:IsActivated("willow_allegiance_shadow_fire") then
                        inst:AddTag("player_shadow_aligned")
                        local damagetyperesist = inst.components.damagetyperesist
                        if damagetyperesist then
                            damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_SHADOW_RESIST, "willow_allegiance_shadow")
                        end
                        local damagetypebonus = inst.components.damagetypebonus
                        if damagetypebonus then
                            damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_VS_LUNAR_BONUS, "willow_allegiance_shadow")
                        end
                    end
                    if inst.bigbernies then
                        for bernie, _ in pairs(inst.bigbernies) do
                            bernie.should_shrink = true
                        end
                    end
                end,
        },

        willow_allegiance_lock_4 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LOCK_4_DESC,
            pos = {CAT3+WGAP+A2X,TOP-HGAP-HGAP-HGAP+A2Y},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local shadow_skills = SkillTreeFns.CountTags(prefabname, "shadow_favor", activatedskills)
                if shadow_skills > 0 then
                    return false
                end

                if readonly then
                    return "question"
                end

                return TheGenericKV:GetKV("celestialchampion_killed") == "1"
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_allegiance_lunar_fire",
                "willow_allegiance_lunar_bernie",
            },
        },

        willow_allegiance_lock_5 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LOCK_5_DESC,
            pos = {CAT3+WGAP+WGAP-NUDGE+A2X,TOP-HGAP-HGAP-HGAP-HGAP+A2Y+SMALLNUDGE},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly) 
                local lighter_skills = SkillTreeFns.CountTags(prefabname, "lighter", activatedskills)
                return lighter_skills >= 7
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_allegiance_lunar_fire",
            },
        },

        willow_allegiance_lock_6 = {
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LOCK_6_DESC,
            pos = {CAT3+NUDGE+A2X,TOP-HGAP-HGAP-HGAP-HGAP+A2Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                local bernie_skills = SkillTreeFns.CountTags(prefabname, "bernie", activatedskills)
                return bernie_skills >= 6
            end,            
            onactivate = function(inst, fromload)
                    --inst:AddTag("alchemist")
                end,
            connects = {
                "willow_allegiance_lunar_bernie",
            },
        },

        willow_allegiance_lunar_fire = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LUNAR_1_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LUNAR_1_DESC,
            icon = "willow_allegiance_lunar_fire",
            pos = {CAT3+WGAP+WGAP-NUDGE+A2X,TOP-HGAP-HGAP-HGAP-HGAP-HGAP+A2Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lunar_favor"},            
            locks = {"willow_allegiance_lock_4", "willow_allegiance_lock_5"},
            onactivate = function(inst, fromload)
                    if not inst.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_bernie") then
                        inst:AddTag("player_lunar_aligned")
                        local damagetyperesist = inst.components.damagetyperesist
                        if damagetyperesist then
                            damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_LUNAR_RESIST, "willow_allegiance_lunar")
                        end
                        local damagetypebonus = inst.components.damagetypebonus
                        if damagetypebonus then
                            damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_VS_SHADOW_BONUS, "willow_allegiance_lunar")
                        end
                    end

                end,
        },

        willow_allegiance_lunar_bernie = {
            title = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LUNAR_2_TITLE,
            desc = STRINGS.SKILLTREE.WILLOW.WILLOW_ALLEGIANCE_LUNAR_2_DESC,
            icon = "willow_allegiance_lunar_bernie",
            pos = {CAT3+NUDGE+A2X,TOP-HGAP-HGAP-HGAP-HGAP-HGAP+A2Y+SMALLNUDGE},
            --pos = {1,0},
            group = "allegiance",
            tags = {"allegiance","lunar_favor"},
            locks = {"willow_allegiance_lock_4", "willow_allegiance_lock_6"},
            onactivate = function(inst, fromload)
                    if not inst.components.skilltreeupdater:IsActivated("willow_allegiance_lunar_fire") then
                        inst:AddTag("player_lunar_aligned")
                        local damagetyperesist = inst.components.damagetyperesist
                        if damagetyperesist then
                            damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_LUNAR_RESIST, "willow_allegiance_lunar")
                        end
                        local damagetypebonus = inst.components.damagetypebonus
                        if damagetypebonus then
                            damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WILLOW_ALLEGIANCE_VS_SHADOW_BONUS, "willow_allegiance_lunar")
                        end
                    end
                    if inst.bigbernies then
                        for bernie, _ in pairs(inst.bigbernies) do
                            bernie.should_shrink = true
                        end
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