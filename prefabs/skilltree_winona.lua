local SHELF_HEIGHT = 60
local SHELF_SKILL_HEIGHT = 40
local SHELF_WIDTH = 520
local SHELF_WIDTH_SKILLS = 220
local ORIGIN_LOW_SHELF_X = 0
local ORIGIN_LOW_SHELF_Y = 5
local ORIGIN_MID_SHELF_X = 0
local ORIGIN_MID_SHELF_Y = SHELF_HEIGHT + ORIGIN_LOW_SHELF_Y
local ORIGIN_SHADOW_SHELF_X = -110
local ORIGIN_SHADOW_SHELF_Y = SHELF_HEIGHT + SHELF_SKILL_HEIGHT + ORIGIN_MID_SHELF_Y
local ORIGIN_LUNAR_SHELF_X = -ORIGIN_SHADOW_SHELF_X
local ORIGIN_LUNAR_SHELF_Y = ORIGIN_SHADOW_SHELF_Y
local ORDERS = {
    {"wagstaff", {ORIGIN_LUNAR_SHELF_X, ORIGIN_LUNAR_SHELF_Y}},
    {"charlie", {ORIGIN_SHADOW_SHELF_X, ORIGIN_SHADOW_SHELF_Y}},
    {"midshelf", {ORIGIN_MID_SHELF_X, ORIGIN_MID_SHELF_Y}},
    {"lowshelf", {ORIGIN_LOW_SHELF_X, ORIGIN_LOW_SHELF_Y}},
}

--------------------------------------------------------------------------------------------------

local BACKGROUND_SETTINGS = {
    tint_bright = false,
    tint_dim = false,
}

local function CreateShelfDecor(shelfdata)
    return {
        init = function(button, root, fromfrontend)
            local Image = require("widgets/image")
            -- NOTES(JBK): Keeping requires in the function so this definition does not need to pull other files.
            button.clickoffset = Vector3(0, 0, 0)

            local shelves = {}
            button.shelves = shelves
            local v = fromfrontend and 0.5 or 0
            for _, data in ipairs(shelfdata) do
                local shelf = root:AddChild(Image(GetSkilltreeBG("winona_background.tex"), data.imagename))
                shelf:MoveToBack()
                button.shelf = shelf
                shelf:SetClickable(false)
                if data.width then
                    shelf:ScaleToSize(data.width, data.height)
                end
                if data.scale then
                    shelf:SetScale(data.scale, data.scale, 1)
                end
                shelf:SetPosition(data.x, data.y - 50) -- NOTES(JBK): - 50 is from root to midlay offset too busy to fixup offsets below.
                shelf:SetTint(v, v, v, 0)
                table.insert(shelves, shelf)
            end
        end,
        onlocked = function(button, instant, fromfrontend)
            local v = fromfrontend and 0.5 or 0
            for _, shelf in ipairs(button.shelves) do
                shelf:SetTint(v, v, v, 1)
            end
        end,
        onunlocked = function(button, instant, fromfrontend)
            for _, shelf in ipairs(button.shelves) do
                shelf:SetTint(1, 1, 1, 1)
            end
        end,
    }
end

local WINONA_SHELF_LOCK_DECOR_LOW = CreateShelfDecor({{
    imagename = "winona_background1.tex",
    width = SHELF_WIDTH,
    height = 90,
    x = -3,
    y = -18,
}})

local WINONA_SHELF_LOCK_DECOR_MED = CreateShelfDecor({{
    imagename = "winona_background2.tex",
    width = SHELF_WIDTH + 3,
    height = 120,
    x = -1,
    y = 71,
},{
    imagename = "winona_background3.tex",
    width = SHELF_WIDTH + 6,
    height = 120,
    x = 0,
    y = 173,
}})

local WINONA_DECOR_WAGSTAFF = CreateShelfDecor({{
    imagename = "winona_background4.tex",
    scale = 0.65,
    x = 3,
    y = 219,
}})
local WINONA_DECOR_CHARLIE = CreateShelfDecor({{
    imagename = "winona_background5.tex",
    scale = 0.65,
    x = 3,
    y = 170,
}})


local function BuildSkillsData(SkillTreeFns)
    local skills = 
    {
        -- Low shelf.
        winona_spotlight_heated = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_SPOTLIGHT_HEATED_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_SPOTLIGHT_HEATED_DESC,
            icon = "winona_spotlight_heated",
            pos = {ORIGIN_LOW_SHELF_X - 125, ORIGIN_LOW_SHELF_Y + 0},
            group = "lowshelf",
            tags = {"lowshelf"},
            root = true,
        },
        winona_spotlight_range = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_SPOTLIGHT_RANGE_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_SPOTLIGHT_RANGE_DESC,
            icon = "winona_spotlight_range",
            pos = {ORIGIN_LOW_SHELF_X - 75, ORIGIN_LOW_SHELF_Y + 0},
            group = "lowshelf",
            tags = {"lowshelf"},
            root = true,
        },
        winona_portable_structures = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_PORTABLE_STRUCTURES_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_PORTABLE_STRUCTURES_DESC,
            icon = "winona_portable_structures",
            pos = {ORIGIN_LOW_SHELF_X + 0, ORIGIN_LOW_SHELF_Y + 0},
            group = "lowshelf",
            tags = {"lowshelf"},
            root = true,
			onactivate = function(inst)
				inst:RemoveTag("basicengineer")
				inst:AddTag("portableengineer")
			end,
			ondeactivate = function(inst)
				inst:RemoveTag("portableengineer")
				inst:AddTag("basicengineer")
			end,
            connects = {
                "winona_gadget_recharge",
            },
            defaultfocus = true,
        },
        winona_gadget_recharge = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_GADGET_RECHARGE_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_GADGET_RECHARGE_DESC,
            icon = "winona_gadget_recharge",
            pos = {ORIGIN_LOW_SHELF_X + 50, ORIGIN_LOW_SHELF_Y + 0},
            group = "lowshelf",
            tags = {"lowshelf"},
        },
        winona_battery_idledrain = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_IDLEDRAIN_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_IDLEDRAIN_DESC,
            icon = "winona_battery_idledrain",
            pos = {ORIGIN_LOW_SHELF_X + 125, ORIGIN_LOW_SHELF_Y + 0},
            group = "lowshelf",
            tags = {"lowshelf"},
            root = true,
        },
        winona_lowshelf_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_LOWSHELF_LOCK_DESC,
            pos = {ORIGIN_LOW_SHELF_X - SHELF_WIDTH_SKILLS, ORIGIN_LOW_SHELF_Y + SHELF_SKILL_HEIGHT * 0.75},
            group = "lowshelf",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "lowshelf", activatedskills) > 2
            end,
            button_decorations = WINONA_SHELF_LOCK_DECOR_LOW,
            connects = {
                "winona_catapult_speed_1",
                "winona_catapult_aoe_1",
                "winona_battery_efficiency_1",
            },
            forced_focus = {
                down = "winona_spotlight_heated",
            },
        },
        -- Mid shelf.
        winona_catapult_speed_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_SPEED_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_SPEED_1_DESC,
            icon = "winona_catapult_speed_1",
            pos = {ORIGIN_MID_SHELF_X - 100, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            connects = {
                "winona_catapult_speed_2",
            },
        },
        winona_catapult_speed_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_SPEED_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_SPEED_2_DESC,
            icon = "winona_catapult_speed_2",
            pos = {ORIGIN_MID_SHELF_X - 150, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            connects = {
                "winona_catapult_speed_3",
            },
        },
        winona_catapult_speed_3 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_SPEED_3_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_SPEED_3_DESC,
            icon = "winona_catapult_speed_3",
            pos = {ORIGIN_MID_SHELF_X - 200, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
        },
        winona_catapult_aoe_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_AOE_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_AOE_1_DESC,
            icon = "winona_catapult_aoe_1",
            pos = {ORIGIN_MID_SHELF_X - 100, ORIGIN_MID_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "midshelf",
            tags = {"midshelf"},
            connects = {
                "winona_catapult_aoe_2",
            },
        },
        winona_catapult_aoe_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_AOE_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_AOE_2_DESC,
            icon = "winona_catapult_aoe_2",
            pos = {ORIGIN_MID_SHELF_X - 150, ORIGIN_MID_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "midshelf",
            tags = {"midshelf"},
            connects = {
                "winona_catapult_aoe_3",
            },
        },
        winona_catapult_aoe_3 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_AOE_3_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_AOE_3_DESC,
            icon = "winona_catapult_aoe_3",
            pos = {ORIGIN_MID_SHELF_X - 200, ORIGIN_MID_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "midshelf",
            tags = {"midshelf"},
        },
        winona_battery_efficiency_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_EFFICIENCY_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_EFFICIENCY_1_DESC,
            icon = "winona_battery_efficiency_1",
            pos = {ORIGIN_MID_SHELF_X + 100, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            connects = {
                "winona_battery_efficiency_2",
            },
        },
        winona_battery_efficiency_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_EFFICIENCY_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_EFFICIENCY_2_DESC,
            icon = "winona_battery_efficiency_2",
            pos = {ORIGIN_MID_SHELF_X + 150, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            connects = {
                "winona_battery_efficiency_3",
            },
        },
        winona_battery_efficiency_3 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_EFFICIENCY_3_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_BATTERY_EFFICIENCY_3_DESC,
            icon = "winona_battery_efficiency_3",
            pos = {ORIGIN_MID_SHELF_X + 200, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            forced_focus = {
                down = "winona_battery_idledrain",
            },
        },
        winona_portable_structures_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_PORTABLE_STRUCTURES_LOCK_DESC,
            pos = {ORIGIN_MID_SHELF_X + 0, ORIGIN_MID_SHELF_Y + SHELF_SKILL_HEIGHT * 0.5},
            group = "midshelf",
            tags = {"lock"},
            lock_open = function(prefabname, activatedskills, readonly)
                return activatedskills and activatedskills["winona_portable_structures"] and SkillTreeFns.CountTags(prefabname, "lowshelf", activatedskills) > 2
            end,
            root = true,
            connects = {
                "winona_catapult_volley_1",
                "winona_catapult_boost_1",
            },
        },
        winona_catapult_volley_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_VOLLEY_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_VOLLEY_DESC,
            icon = "winona_catapult_volley_1",
            pos = {ORIGIN_MID_SHELF_X - 35, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            locks = {
                "winona_lowshelf_lock",
                "winona_portable_structures_lock",
            },
        },
        winona_catapult_boost_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_BOOST_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CATAPULT_BOOST_DESC,
            icon = "winona_catapult_boost_1",
            pos = {ORIGIN_MID_SHELF_X + 35, ORIGIN_MID_SHELF_Y + 0},
            group = "midshelf",
            tags = {"midshelf"},
            locks = {
                "winona_lowshelf_lock",
                "winona_portable_structures_lock",
            },
        },
        winona_midshelf_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_MIDSHELF_LOCK_DESC,
            pos = {ORIGIN_MID_SHELF_X - SHELF_WIDTH_SKILLS, ORIGIN_MID_SHELF_Y + SHELF_SKILL_HEIGHT + SHELF_SKILL_HEIGHT * 0.75},
            group = "midshelf",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountTags(prefabname, "lowshelf", activatedskills) + SkillTreeFns.CountTags(prefabname, "midshelf", activatedskills) > 5
            end,
            button_decorations = WINONA_SHELF_LOCK_DECOR_MED,
            connects = {
                "winona_shadow_1",
                "winona_charlie_1",
                "winona_lunar_1",
                "winona_wagstaff_1",
            },
        },
        -- Shadow.
        winona_shadow_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_1_DESC,
            icon = "winona_shadow_1",
            pos = {ORIGIN_SHADOW_SHELF_X - 10, ORIGIN_SHADOW_SHELF_Y + 0},
            group = "charlie",
            tags = {"charlie"},
            connects = {
                "winona_shadow_2",
            },
        },
        winona_shadow_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_2_DESC,
            icon = "winona_shadow_2",
            pos = {ORIGIN_SHADOW_SHELF_X + 0, ORIGIN_SHADOW_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "charlie",
            tags = {"charlie"},
            forced_focus = {
                left = "winona_charlie_2",
            },
        },
        winona_shadow_3_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_3_LOCK_DESC,
            pos = {ORIGIN_SHADOW_SHELF_X + 50, ORIGIN_SHADOW_SHELF_Y + 0},
            group = "charlie",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return activatedskills and (activatedskills["winona_portable_structures"] and activatedskills["winona_shadow_2"])
            end,
        },
        winona_shadow_3 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_3_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_SHADOW_3_DESC,
            icon = "winona_shadow_3",
            pos = {ORIGIN_SHADOW_SHELF_X + 50, ORIGIN_SHADOW_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "charlie",
            tags = {"charlie"},
            locks = {
                "winona_shadow_3_lock",
                "winona_portable_structures_lock",
            },
        },
        winona_charlie_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CHARLIE_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CHARLIE_1_DESC,
            icon = "winona_charlie_1",
            pos = {ORIGIN_SHADOW_SHELF_X - 60, ORIGIN_SHADOW_SHELF_Y + 0},
            group = "charlie",
            tags = {"charlie"},
        },
        winona_charlie_2_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CHARLIE_2_LOCK_DESC,
            pos = {ORIGIN_SHADOW_SHELF_X - 100, ORIGIN_SHADOW_SHELF_Y + 0},
            group = "charlie",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return activatedskills and (activatedskills["winona_charlie_1"] and not activatedskills["winona_wagstaff_2"])
            end,
        },
        winona_charlie_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_CHARLIE_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_CHARLIE_2_DESC,
            icon = "winona_charlie_2",
            pos = {ORIGIN_SHADOW_SHELF_X - 110, ORIGIN_SHADOW_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "charlie",
            tags = {"charlie"},
            onactivate = function(inst)
                inst.components.grue:AddImmunity("winona_charlie_2")
            end,
            ondeactivate = function(inst)
                inst.components.grue:RemoveImmunity("winona_charlie_2")
            end,
            locks = {
                "winona_charlie_2_lock",
            },
            button_decorations = WINONA_DECOR_CHARLIE,
            forced_focus = {
                right = "winona_shadow_2",
            },
        },
        -- Lunar.
        winona_lunar_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_1_DESC,
            icon = "winona_lunar_1",
            pos = {ORIGIN_LUNAR_SHELF_X + 10, ORIGIN_LUNAR_SHELF_Y + 0},
            group = "wagstaff",
            tags = {"wagstaff"},
            connects = {
                "winona_lunar_2",
            },
        },
        winona_lunar_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_2_DESC,
            icon = "winona_lunar_2",
            pos = {ORIGIN_LUNAR_SHELF_X - 0, ORIGIN_LUNAR_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "wagstaff",
            tags = {"wagstaff"},
            connects = {
                "winona_lunar_3",
            },
            forced_focus = {
                right = "winona_wagstaff_2",
            },
        },
        winona_lunar_3_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_3_LOCK_DESC,
            pos = {ORIGIN_LUNAR_SHELF_X - 50, ORIGIN_LUNAR_SHELF_Y + 0},
            group = "wagstaff",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return activatedskills and (activatedskills["winona_portable_structures"] and activatedskills["winona_lunar_2"])
            end,
        },
        winona_lunar_3 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_3_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_LUNAR_3_DESC,
            icon = "winona_lunar_3",
            pos = {ORIGIN_LUNAR_SHELF_X - 50, ORIGIN_LUNAR_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "wagstaff",
            tags = {"wagstaff"},
            locks = {
                "winona_lunar_3_lock",
                "winona_portable_structures_lock",
            },
        },
        winona_wagstaff_1 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_WAGSTAFF_1_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_WAGSTAFF_1_DESC,
            icon = "winona_wagstaff_1",
            pos = {ORIGIN_LUNAR_SHELF_X + 60, ORIGIN_LUNAR_SHELF_Y + 0},
            group = "wagstaff",
            tags = {"wagstaff"},
            onactivate = function(inst) inst:AddTag("inspectacleshatuser") end,
            ondeactivate = function(inst) inst:RemoveTag("inspectacleshatuser") end,
        },
        winona_wagstaff_2_lock = {
            desc = STRINGS.SKILLTREE.WINONA.WINONA_WAGSTAFF_2_LOCK_DESC,
            pos = {ORIGIN_LUNAR_SHELF_X + 100, ORIGIN_LUNAR_SHELF_Y + 0},
            group = "wagstaff",
            tags = {"lock"},
            root = true,
            lock_open = function(prefabname, activatedskills, readonly)
                return activatedskills and (activatedskills["winona_wagstaff_1"] and not activatedskills["winona_charlie_2"])
            end,
        },
        winona_wagstaff_2 = {
            title = STRINGS.SKILLTREE.WINONA.WINONA_WAGSTAFF_2_TITLE,
            desc = STRINGS.SKILLTREE.WINONA.WINONA_WAGSTAFF_2_DESC,
            icon = "winona_wagstaff_2",
            pos = {ORIGIN_LUNAR_SHELF_X + 110, ORIGIN_LUNAR_SHELF_Y + SHELF_SKILL_HEIGHT},
            group = "wagstaff",
            tags = {"wagstaff"},
            locks = {
                "winona_wagstaff_2_lock",
            },
            button_decorations = WINONA_DECOR_WAGSTAFF,
            forced_focus = {
                left = "winona_lunar_2",
            },
        },
    }

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
        BACKGROUND_SETTINGS = BACKGROUND_SETTINGS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData