local POS_Y_1 =  172
local POS_Y_2 = POS_Y_1 - 38
local POS_Y_3 = POS_Y_1 - (38 * 2)
local POS_Y_4 = POS_Y_1 - (38 * 3)
local POS_Y_5 = POS_Y_1 - (38 * 4)

local HUMAN_POS_Y_1 = POS_Y_1
local HUMAN_POS_Y_2 = HUMAN_POS_Y_1 - 36
local HUMAN_POS_Y_3 = HUMAN_POS_Y_2 - 36
local HUMAN_POS_Y_4 = HUMAN_POS_Y_3 - 48
local HUMAN_POS_Y_5 = HUMAN_POS_Y_4 - 38

local ALLEGIANCE_POS_Y_1 = POS_Y_1
local ALLEGIANCE_POS_Y_2 = 128
local ALLEGIANCE_POS_Y_3 = 84
local ALLEGIANCE_POS_Y_4 = 38

local WEREMETER_POS_X = -205

local BEAVER_POS_X = WEREMETER_POS_X + 65
local MOOSE_POS_X = BEAVER_POS_X + 44.5
local GOOSE_POS_X = MOOSE_POS_X  + 43.5

local QUICKPICKER_POS_X = 37
local TREE_GUARD_POS_X = QUICKPICKER_POS_X + 40 + 32

local LUCY_POS_X_1 = (QUICKPICKER_POS_X + TREE_GUARD_POS_X) * .5
local LUCY_POS_X_2 = LUCY_POS_X_1 - 28
local LUCY_POS_X_3 = LUCY_POS_X_1 + 31

local ALLEGIANCE_LOCK_X = 202
local ALLEGIANCE_SHADOW_X = ALLEGIANCE_LOCK_X - 23
local ALLEGIANCE_LUNAR_X  = ALLEGIANCE_LOCK_X + 24

local CURSE_TITLE_X = (GOOSE_POS_X + WEREMETER_POS_X) * .5
local HUMAN_TITLE_X = LUCY_POS_X_1
local ALLEGIANCE_TILE_X = ALLEGIANCE_LOCK_X

local TITLE_Y = POS_Y_1 + 30

local WOODIE_SKILL_STRINGS = STRINGS.SKILLTREE.WOODIE

local function CreateAddTagFn(tag)
    return function(inst) inst:AddTag(tag) end
end

local function CreateRemoveTagFn(tag)
    return function(inst) inst:RemoveTag(tag) end
end

local function CreateAddDamageBonusVsTreeguardsFn(level)
    return function(inst)
        local damagetypebonus = inst.components.damagetypebonus
        if damagetypebonus ~= nil then
            damagetypebonus:AddBonus("evergreens", inst, TUNING.SKILLS.WOODIE.DAMAGE_BONUS_VS_TREEGUARDS, "woodie_treeguard_skill_level_"..level)
        end
    end
end

local function CreateRemoveDamageBonusVsTreeguardsFn(level)
    return function(inst)
        local damagetypebonus = inst.components.damagetypebonus
        if damagetypebonus ~= nil then
            damagetypebonus:RemoveBonus("evergreens", inst, "woodie_treeguard_skill_level_"..level)
        end
    end
end

local function RecalculateWereformSpeed(inst)
    inst:RecalculateWereformSpeed()
end

--------------------------------------------------------------------------------------------------

local ORDERS =
{
    {"curse",       { CURSE_TITLE_X,     TITLE_Y }},
    {"human",       { HUMAN_TITLE_X,     TITLE_Y }},
    {"allegiance",  { ALLEGIANCE_TILE_X, TITLE_Y }},
}

--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- Wereforms transformations last longer.
        woodie_curse_weremeter_1 = {
            pos = {WEREMETER_POS_X, POS_Y_1},
            group = "curse",
            tags = {"curse", "weremeter"},
            root = true,
            connects = {
                "woodie_curse_weremeter_2",
            },
        },

        -- Wereforms transformations last longer.
        woodie_curse_weremeter_2 = {
            pos = {WEREMETER_POS_X, POS_Y_2},
            group = "curse",
            tags = {"curse", "weremeter"},
            connects = {
                "woodie_curse_weremeter_3",
            },
        },

        -- Wereforms transformations last longer.
        woodie_curse_weremeter_3 = {
            pos = {WEREMETER_POS_X, POS_Y_3},
            group = "curse",
            tags = {"curse", "weremeter"},
        },

        --------------------------------------------------------------------------

        woodie_curse_master_lock = {
            pos = {WEREMETER_POS_X, POS_Y_4},
            group = "curse",
            tags = {"curse", "lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "curse", activatedskills) >= 6
            end,
            connects = {
                "woodie_curse_master",
            },
        },

        -- No health and sanity penalties for eating Kitschy Idols.
        -- Returns to human form without having an empty stomach.
        woodie_curse_master = {
            pos = {WEREMETER_POS_X, POS_Y_5},
            group = "curse",
            tags = {"curse"},
            onactivate   = CreateAddTagFn("cursemaster"),
            ondeactivate = CreateRemoveTagFn("cursemaster"),
        },

        --------------------------------------------------------------------------

        -- The Werebeaver mines faster.
        woodie_curse_beaver_1 = {
            pos = {BEAVER_POS_X, POS_Y_1},
            group = "curse",
            tags = {"curse", "beaver"},
            root = true,
            connects = {
                "woodie_curse_beaver_2",
            },
            onactivate = function(inst)
                -- For load (skills activation occurs after onload functions).
                if inst:IsWerebeaver() and inst.components.worker ~= nil then
                    local modifiers = TUNING.SKILLS.WOODIE.BEAVER_WORK_MULTIPLIER

                    inst.components.worker:SetAction(ACTIONS.MINE, .5 * modifiers.MINE)
                end
            end,
        },

        -- The Werebeaver chops faster.
        woodie_curse_beaver_2 = {
            pos = {BEAVER_POS_X, POS_Y_2},
            group = "curse",
            tags = {"curse", "beaver"},
            connects = {
                "woodie_curse_beaver_3",
            },
            onactivate = function(inst)
                -- For load (skills activation occurs after onload functions).
                if inst:IsWerebeaver() and inst.components.worker ~= nil then
                    local modifiers = TUNING.SKILLS.WOODIE.BEAVER_WORK_MULTIPLIER

                    inst.components.worker:SetAction(ACTIONS.CHOP, 4 * modifiers.CHOP)
                end
            end,
        },

        -- The Werebeaver can chop, mine and break hard materials.
        woodie_curse_beaver_3 = {
            pos = {BEAVER_POS_X, POS_Y_3},
            group = "curse",
            tags = {"curse", "beaver", "recoilimmune"},
            connects = {
                "woodie_curse_beaver_lock",
            },
            onactivate = function(inst)
                -- For load (skills activation occurs after onload functions).
                if inst:IsWerebeaver() then
                    inst:AddTag("toughworker")
                end
            end,
        },

        woodie_curse_beaver_lock = {
            pos = {BEAVER_POS_X, POS_Y_4},
            group = "curse",
            tags = {"curse", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                return
                    SkillTreeFns.CountTags(prefabname, "beaver", activatedskills) >= 3 and
                    SkillTreeFns.CountTags(prefabname, "moose_epic", activatedskills) == 0 and
                    SkillTreeFns.CountTags(prefabname, "goose_epic", activatedskills) == 0
            end,
            connects = {
                "woodie_curse_epic_beaver",
            },
        },

        -- The Werebeaver can smack the ground with its tail, destroying everything around it.
        woodie_curse_epic_beaver = {
            pos = {BEAVER_POS_X, POS_Y_5},
            group = "curse",
            tags = {"curse", "beaver_epic"},
        },

        --------------------------------------------------------------------------

        -- The Werebeaver is more resistant to hitting obstacles and walks a little faster.
        woodie_curse_moose_1 = {
            pos = {MOOSE_POS_X, POS_Y_1},
            group = "curse",
            tags = {"curse", "moose"},
            root = true,
            onactivate   = RecalculateWereformSpeed,
            ondeactivate = RecalculateWereformSpeed,
            connects = {
                "woodie_curse_moose_2",
            },
        },

        -- The Weremoose gains slow health regeneration.
        woodie_curse_moose_2 = {
            pos = {MOOSE_POS_X, POS_Y_2},
            group = "curse",
            tags = {"curse", "moose"},
            connects = {
                "woodie_curse_moose_3",
            },
            onactivate = function(inst)
                -- For load (skills activation occurs after onload functions).
                if inst:IsWeremoose() then
                    local regendata = TUNING.SKILLS.WOODIE.MOOSE_HEALTH_REGEN
                    inst.components.health:AddRegenSource(inst, regendata.amount, regendata.period, "weremoose_skill")
                end
            end,
        },

        -- The Werebeaver can stop his dash whenever he wants.
        woodie_curse_moose_3 = {
            pos = {MOOSE_POS_X, POS_Y_3},
            group = "curse",
            tags = {"curse", "moose"},
            connects = {
                "woodie_curse_moose_lock",
            },
        },

        woodie_curse_moose_lock = {
            pos = {MOOSE_POS_X, POS_Y_4},
            group = "curse",
            tags = {"curse", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                return
                    SkillTreeFns.CountTags(prefabname, "moose", activatedskills) >= 3 and
                    SkillTreeFns.CountTags(prefabname, "beaver_epic", activatedskills) == 0 and
                    SkillTreeFns.CountTags(prefabname, "goose_epic", activatedskills) == 0
            end,
            connects = {
                "woodie_curse_epic_moose",
            },
        },

        -- The Werebeaver has learned to throw stronger punches and has a tougher coat.
        woodie_curse_epic_moose = {
            pos = {MOOSE_POS_X, POS_Y_5},
            group = "curse",
            tags = {"curse", "moose_epic"},
            onactivate = function(inst)
                inst:AddTag("weremoosecombo")

                -- For load (skills activation occurs after onload functions).
                if inst:IsWeremoose() then
                    inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WOODIE.MOOSE_PLANAR_DEF, "weremoose_skill")
                end
            end,
            ondeactivate = CreateRemoveTagFn("weremoosecombo"),
        },

        --------------------------------------------------------------------------

        -- The weregoose runs faster.
        woodie_curse_goose_1 = {
            pos = {GOOSE_POS_X, POS_Y_1},
            group = "curse",
            tags = {"curse", "goose"},
            root = true,
            onactivate   = RecalculateWereformSpeed,
            ondeactivate = RecalculateWereformSpeed,
            connects = {
                "woodie_curse_goose_2",
            },
        },

        -- The weregoose is completely waterproof.
        woodie_curse_goose_2 = {
            pos = {GOOSE_POS_X, POS_Y_2},
            group = "curse",
            tags = {"curse", "goose"},
            connects = {
                "woodie_curse_goose_3",
            },
            onactivate = function(inst)
                -- For load (skills activation occurs after onload functions).
                if inst:IsWeregoose() then
                    inst.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_ABSOLUTE)
                end
            end,
        },

        -- The weregoose can dodge an attack from time to time.
        woodie_curse_goose_3 = {
            pos = {GOOSE_POS_X, POS_Y_3},
            group = "curse",
            tags = {"curse", "goose"},
            connects = {
                "woodie_curse_goose_lock",
            },
            onactivate = function(inst)
                -- For load (skills activation occurs after onload functions).
                if inst:IsWeregoose() and not inst.components.attackdodger then
                    inst:AddComponent("attackdodger")
                    inst.components.attackdodger:SetCooldownTime(TUNING.SKILLS.WOODIE.GOOSE_DODGE_COOLDOWN_TIME)
                    inst.components.attackdodger:SetOnDodgeFn(inst.OnDodgeAttack)
                end
            end,
        },

        woodie_curse_goose_lock = {
            pos = {GOOSE_POS_X, POS_Y_4},
            group = "curse",
            tags = {"curse", "lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                return
                    SkillTreeFns.CountTags(prefabname, "goose", activatedskills) >= 3 and
                    SkillTreeFns.CountTags(prefabname, "beaver_epic", activatedskills) == 0 and
                    SkillTreeFns.CountTags(prefabname, "moose_epic", activatedskills) == 0
            end,
            connects = {
                "woodie_curse_epic_goose",
            },
        },

        -- The Weregoose can fly around to explore the world, but it's a little out of control.
        woodie_curse_epic_goose = {
            pos = {GOOSE_POS_X, POS_Y_5},
            group = "curse",
            tags = {"curse", "goose_epic"},
        },

        --------------------------------------------------------------------------

        -- Can use Lucy to carve boards more efficiently.
        woodie_human_lucy_1 = {
            pos = {LUCY_POS_X_1, HUMAN_POS_Y_4},
            group = "human",
            tags = {"human", "lucy"},
            root = true,
            connects = {
                "woodie_human_lucy_2",
                "woodie_human_lucy_3",
            },
        },

        -- Can use Lucy to carve a nice "woodcarvedhat" for protection.
        woodie_human_lucy_2 = {
            pos = {LUCY_POS_X_2, HUMAN_POS_Y_5},
            group = "human",
            tags = {"human", "lucy"},
        },

        -- Can use Lucy to carve a "walking_stick" for easy mobility.
        woodie_human_lucy_3 = {
            pos = {LUCY_POS_X_3, HUMAN_POS_Y_5},
            group = "human",
            tags = {"human", "lucy"},
        },

        --------------------------------------------------------------------------

        -- Collect stuff faster.
        woodie_human_quickpicker_1 = {
            pos = {QUICKPICKER_POS_X, HUMAN_POS_Y_1},
            group = "human",
            tags = {"human", "quickpicker"},
            onactivate   = CreateAddTagFn("woodiequickpicker"),
            ondeactivate = CreateRemoveTagFn("woodiequickpicker"),
            root = true,
            connects = {
                "woodie_human_quickpicker_2",
            },
            defaultfocus = true,
        },

        -- Collect stuff faster.
        woodie_human_quickpicker_2 = {
            pos = {QUICKPICKER_POS_X, HUMAN_POS_Y_2},
            group = "human",
            tags = {"human", "quickpicker"},
            connects = {
                "woodie_human_quickpicker_3",
            },
        },

        -- Collect stuff faster.
        woodie_human_quickpicker_3 = {
            pos = {QUICKPICKER_POS_X, HUMAN_POS_Y_3},
            group = "human",
            tags = {"human", "quickpicker"},
        },

        --------------------------------------------------------------------------

        -- Does more damage to Treeguards.
        woodie_human_treeguard_1 = {
            pos = {TREE_GUARD_POS_X, HUMAN_POS_Y_1},
            group = "human",
            tags = {"human", "treeguard"},
            root = true,
            onactivate   = CreateAddDamageBonusVsTreeguardsFn(1),
            ondeactivate = CreateRemoveDamageBonusVsTreeguardsFn(1),
            connects = {
                "woodie_human_treeguard_2",
            },
        },

        -- Does more damage to Treeguards.
        woodie_human_treeguard_2 = {
            pos = {TREE_GUARD_POS_X, HUMAN_POS_Y_2},
            group = "human",
            tags = {"human", "treeguard"},
            onactivate   = CreateAddDamageBonusVsTreeguardsFn(2),
            ondeactivate = CreateRemoveDamageBonusVsTreeguardsFn(2),
            connects = {
                "woodie_human_treeguard_max",
            },
        },

        -- Can craft "leif_idol", an extremely burnable effigy.
        woodie_human_treeguard_max = {
            pos = {TREE_GUARD_POS_X, HUMAN_POS_Y_3},
            group = "human",
            tags = {"human", "treeguard"},
        },

        --------------------------------------------------------------------------

        woodie_allegiance_lock_1 = {
            pos = {ALLEGIANCE_LOCK_X, ALLEGIANCE_POS_Y_1},
            group = "allegiance",
            tags = {"allegiance","lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
        },

        woodie_allegiance_lock_2 = SkillTreeFns.MakeFuelWeaverLock(
            { pos = {ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_2} }
        ),


        woodie_allegiance_lock_4 = SkillTreeFns.MakeNoLunarLock(
            { pos = {ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_3} }
        ),

        -- Woodie no longer draws the aggression of shadow creatures when transformed into one of the wereforms.
        woodie_allegiance_shadow = {
            icon = "wilson_favor_shadow",
            pos = {ALLEGIANCE_SHADOW_X , ALLEGIANCE_POS_Y_4},
            group = "allegiance",
            tags = {"allegiance","shadow","shadow_favor"},
            locks = {"woodie_allegiance_lock_1", "woodie_allegiance_lock_2", "woodie_allegiance_lock_4"},

            onactivate = function(inst, fromload)
                inst:AddTag("player_shadow_aligned")
                inst:UpdateShadowDominanceState()

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_SHADOW_RESIST, "allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_VS_LUNAR_BONUS, "allegiance_shadow")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_shadow_aligned")
                inst:UpdateShadowDominanceState()

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("shadow_aligned", inst, "allegiance_shadow")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("lunar_aligned", inst, "allegiance_shadow")
                end
            end,
        },

        woodie_allegiance_lock_3 = SkillTreeFns.MakeCelestialChampionLock(
            { pos = {ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_2} }
        ),

        woodie_allegiance_lock_5 = SkillTreeFns.MakeNoShadowLock(
            { pos = {ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_3} }
        ),

        -- Woodie's curse is no longer triggered by full moons.
        woodie_allegiance_lunar = {
            icon = "wilson_favor_lunar",
            pos = {ALLEGIANCE_LUNAR_X , ALLEGIANCE_POS_Y_4},
            group = "allegiance",
            tags = {"allegiance","lunar","lunar_favor"},
            locks = {"woodie_allegiance_lock_1", "woodie_allegiance_lock_3", "woodie_allegiance_lock_5"},

            onactivate = function(inst, fromload)
                inst:AddTag("player_lunar_aligned")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_LUNAR_RESIST, "allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WOODIE.ALLEGIANCE_VS_SHADOW_BONUS, "allegiance_lunar")
                end
            end,
            ondeactivate = function(inst, fromload)
                inst:RemoveTag("player_lunar_aligned")

                local damagetyperesist = inst.components.damagetyperesist
                if damagetyperesist then
                    damagetyperesist:RemoveResist("lunar_aligned", inst, "allegiance_lunar")
                end
                local damagetypebonus = inst.components.damagetypebonus
                if damagetypebonus then
                    damagetypebonus:RemoveBonus("shadow_aligned", inst, "allegiance_lunar")
                end
            end,
        },
    }


    for name, data in pairs(skills) do
        local uppercase_name = string.upper(name)

        if not data.desc then
            data.desc = WOODIE_SKILL_STRINGS[uppercase_name.."_DESC"]
        end

        -- If it's not a lock.
        if not data.lock_open then
            if not data.title then
                data.title = WOODIE_SKILL_STRINGS[uppercase_name.."_TITLE"]
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