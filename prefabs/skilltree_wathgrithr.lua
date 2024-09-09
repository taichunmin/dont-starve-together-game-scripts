local POS_Y_1 =  180
local POS_Y_2 = POS_Y_1 - 38
local POS_Y_3 = POS_Y_2 - 38
local POS_Y_4 = POS_Y_3 - 38
local POS_Y_5 = POS_Y_4 - 38

local ALLEGIANCE_POS_Y_1 = POS_Y_1
local ALLEGIANCE_POS_Y_2 = 141
local ALLEGIANCE_POS_Y_3 = ALLEGIANCE_POS_Y_2 - 45
local ALLEGIANCE_POS_Y_4 = ALLEGIANCE_POS_Y_3 - 53

local ARSENAL_SHIELD_Y_2 = POS_Y_5 - 15
local ARSENAL_SHIELD_Y_1 = (POS_Y_3 + ARSENAL_SHIELD_Y_2) * .5

local ARSENAL_UPGRADES_Y_1 = (POS_Y_2 + POS_Y_3) * .5
local ARSENAL_UPGRADES_Y_2 = ARSENAL_UPGRADES_Y_1 - 38

local COMBAT_POS_Y = POS_Y_5 - 3

--------------------------------------------------------------------------------------------------

local X_GAP = 68.5

local SONGS_POS_X_1 = -218
local SONGS_POS_X_2 = SONGS_POS_X_1 + 38

local ARSENAL_POS_X_1 = SONGS_POS_X_2 + X_GAP - 2
local ARSENAL_POS_X_2 = ARSENAL_POS_X_1 + 57
local ARSENAL_POS_X_3 = ARSENAL_POS_X_2 + 40
local ARSENAL_POS_X_4 = ARSENAL_POS_X_3 + 57

local ARSENAL_POS_X_MIDDLE = (ARSENAL_POS_X_2 + ARSENAL_POS_X_3) * .5

local BEEFALO_POS_X = ARSENAL_POS_X_4 + X_GAP -2

local COMBAT_POS_X = SONGS_POS_X_1 + 22

local ALLEGIANCE_LOCK_X = 202
local ALLEGIANCE_SHADOW_X = ALLEGIANCE_LOCK_X - 24
local ALLEGIANCE_LUNAR_X  = ALLEGIANCE_LOCK_X + 23

--------------------------------------------------------------------------------------------------

local ARSENAL_TITLE_X   = ARSENAL_POS_X_MIDDLE
local BEEFALO_TITLE_X   = BEEFALO_POS_X
local SONGS_TITLE_X     = (SONGS_POS_X_1 + SONGS_POS_X_2) * .5
local COMBAT_TITLE_X    = COMBAT_POS_X
local ALLEGIANCE_TILE_X = ALLEGIANCE_LOCK_X

--------------------------------------------------------------------------------------------------

local TITLE_Y = POS_Y_1 + 30
local TITLE_Y_2 = POS_Y_4 - 20

--------------------------------------------------------------------------------------------------

local POSITIONS =
{
    wathgrithr_arsenal_spear_1 =                { x = ARSENAL_POS_X_2, y = POS_Y_1 },
    wathgrithr_arsenal_spear_2 =                { x = ARSENAL_POS_X_2, y = POS_Y_2 },
    wathgrithr_arsenal_spear_3 =                { x = ARSENAL_POS_X_2, y = POS_Y_3 },
    wathgrithr_arsenal_spear_4 =                { x = ARSENAL_POS_X_1, y = ARSENAL_UPGRADES_Y_1 },
    wathgrithr_arsenal_spear_5 =                { x = ARSENAL_POS_X_1, y = ARSENAL_UPGRADES_Y_2 },

    wathgrithr_arsenal_helmet_1 =               { x = ARSENAL_POS_X_3, y = POS_Y_1 },
    wathgrithr_arsenal_helmet_2 =               { x = ARSENAL_POS_X_3, y = POS_Y_2 },
    wathgrithr_arsenal_helmet_3 =               { x = ARSENAL_POS_X_3, y = POS_Y_3 },
    wathgrithr_arsenal_helmet_4 =               { x = ARSENAL_POS_X_4, y = ARSENAL_UPGRADES_Y_1 },
    wathgrithr_arsenal_helmet_5 =               { x = ARSENAL_POS_X_4, y = ARSENAL_UPGRADES_Y_2 },

    wathgrithr_arsenal_shield_1 =               { x = ARSENAL_POS_X_MIDDLE, y = ARSENAL_SHIELD_Y_1 },
    wathgrithr_arsenal_shield_2 =               { x = ARSENAL_POS_X_2, y = ARSENAL_SHIELD_Y_2 },
    wathgrithr_arsenal_shield_3 =               { x = ARSENAL_POS_X_3, y = ARSENAL_SHIELD_Y_2 },

    wathgrithr_beefalo_1 =                      { x = BEEFALO_POS_X, y = POS_Y_1 },
    wathgrithr_beefalo_2 =                      { x = BEEFALO_POS_X, y = POS_Y_2 },
    wathgrithr_beefalo_3 =                      { x = BEEFALO_POS_X, y = POS_Y_3 },
    wathgrithr_beefalo_saddle =                 { x = BEEFALO_POS_X, y = POS_Y_4 },

    wathgrithr_songs_instantsong_cd_lock =      { x = SONGS_POS_X_1, y = POS_Y_1 },
    wathgrithr_songs_instantsong_cd =           { x = SONGS_POS_X_2, y = POS_Y_1 },

    wathgrithr_songs_container_lock =           { x = SONGS_POS_X_1, y = POS_Y_2 },
    wathgrithr_songs_container =                { x = SONGS_POS_X_2, y = POS_Y_2 },

    wathgrithr_songs_revivewarrior_lock =       { x = SONGS_POS_X_1, y = POS_Y_3 },
    wathgrithr_songs_revivewarrior =            { x = SONGS_POS_X_2, y = POS_Y_3 },

    wathgrithr_combat_defense =                 { x = COMBAT_POS_X, y = COMBAT_POS_Y},

    wathgrithr_allegiance_lock_1 =              { x = ALLEGIANCE_LOCK_X, y = POS_Y_1 },
    wathgrithr_allegiance_lunar =               { x = ALLEGIANCE_LUNAR_X, y = ALLEGIANCE_POS_Y_4 },
    wathgrithr_allegiance_shadow =              { x = ALLEGIANCE_SHADOW_X, y = ALLEGIANCE_POS_Y_4 },
}

--------------------------------------------------------------------------------------------------

local WATHGRITHR_SKILL_STRINGS = STRINGS.SKILLTREE.WATHGRITHR

--------------------------------------------------------------------------------------------------

local function CreateAddTagFn(tag)
    return function(inst) inst:AddTag(tag) end
end

local function CreateRemoveTagFn(tag)
    return function(inst) inst:RemoveTag(tag) end
end

local function CreateAccomplishmentLockFn(key)
    return
        function(prefabname, activatedskills, readonly)
            return readonly and "question" or TheGenericKV:GetKV(key) == "1"
        end
end

local function CreateAccomplishmentCountLockFn(key, value)
    return
        function(prefabname, activatedskills, readonly)
            return readonly and "question" or tonumber(TheGenericKV:GetKV(key) or 0) >= (value or 1)
        end
end

--------------------------------------------------------------------------------------------------

local ONACTIVATE_FNS = {
    CombatDefense = function(inst)
        if inst.components.planardefense ~= nil then
            inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WATHGRITHR.BONUS_PLANAR_DEF, "wathgrithr_combat_defense")
        end
    end,

    Beefalo = function(inst)
        if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
            inst._riding_music:push()
        end
    end,

    AllegianceShadow = function(inst)
        inst:AddTag("player_shadow_aligned")

        if inst.components.damagetyperesist ~= nil then
            inst.components.damagetyperesist:AddResist("shadow_aligned", inst, TUNING.SKILLS.WATHGRITHR.ALLEGIANCE_SHADOW_RESIST, "allegiance_shadow")
        end

        if inst.components.damagetypebonus ~= nil then
            inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.SKILLS.WATHGRITHR.ALLEGIANCE_VS_LUNAR_BONUS, "allegiance_shadow")
        end
    end,

    AllegianceLunar = function(inst)
        inst:AddTag("player_lunar_aligned")

        if inst.components.damagetyperesist ~= nil then
            inst.components.damagetyperesist:AddResist("lunar_aligned", inst, TUNING.SKILLS.WATHGRITHR.ALLEGIANCE_LUNAR_RESIST, "allegiance_lunar")
        end

        if inst.components.damagetypebonus ~= nil then
            inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.SKILLS.WATHGRITHR.ALLEGIANCE_VS_SHADOW_BONUS, "allegiance_lunar")
        end
    end,
}

local ONDEACTIVATE_FNS = {
    CombatDefense = function(inst)
        if inst.components.planardefense ~= nil then
            inst.components.planardefense:RemoveBonus(inst, "wathgrithr_combat_defense")
        end
    end,

    AllegianceShadow = function(inst)
        inst:RemoveTag("player_shadow_aligned")

        if inst.components.damagetyperesist ~= nil then
            inst.components.damagetyperesist:RemoveResist("shadow_aligned", inst, "allegiance_shadow")
        end

        if inst.components.damagetypebonus ~= nil then
            inst.components.damagetypebonus:RemoveBonus("lunar_aligned", inst, "allegiance_shadow")
        end
    end,

    AllegianceLunar = function(inst)
        inst:RemoveTag("player_lunar_aligned")

        if inst.components.damagetyperesist ~= nil then
            inst.components.damagetyperesist:RemoveResist("lunar_aligned", inst, "allegiance_lunar")
        end

        if inst.components.damagetypebonus ~= nil then
            inst.components.damagetypebonus:RemoveBonus("shadow_aligned", inst, "allegiance_lunar")
        end
    end,
}

--------------------------------------------------------------------------------------------------


local ORDERS =
{
    {"songs",      { SONGS_TITLE_X,      TITLE_Y }},
    {"beefalo",    { BEEFALO_TITLE_X,    TITLE_Y   }},
    {"arsenal",    { ARSENAL_TITLE_X,    TITLE_Y   }},
    {"combat",     { COMBAT_TITLE_X,     TITLE_Y_2 }},
    {"allegiance", { ALLEGIANCE_TILE_X , TITLE_Y   }},
}


--------------------------------------------------------------------------------------------------

local function BuildSkillsData(SkillTreeFns)
    local skills =
    {
        -- Inspiration gain rate will increase a little when attacking using Battle Spears.
        wathgrithr_arsenal_spear_1 = {
            group = "arsenal",
            tags = { "spear", "inspirationgain" },

            root = true,
            connects = { "wathgrithr_arsenal_spear_2" },
            defaultfocus = true,
        },

        -- Inspiration gain rate will increase a fair amount when attacking using Battle Spears.
        wathgrithr_arsenal_spear_2 = {
            group = "arsenal",
            tags = { "spear", "inspirationgain" },

            connects = { "wathgrithr_arsenal_spear_3" },
        },

        -- Learn to craft the Lightning Spear.
        wathgrithr_arsenal_spear_3 = {
            group = "arsenal",
            tags = { "spear" },

            connects = {
                "wathgrithr_arsenal_spear_4",
                "wathgrithr_arsenal_spear_5",

                "wathgrithr_arsenal_shield_1",
            },
        },

        -- The Lightning Spear can now perform a special attack.\nThis attack repairs Charged Lightning Spears if it hits a target.
        wathgrithr_arsenal_spear_4 = {
            group = "arsenal",
            tags = { "spear" },
        },

        -- Upgrade the Lightning Spear using Restrained Static to deal +20 Planar Damage.
        wathgrithr_arsenal_spear_5 = {
            group = "arsenal",
            tags = { "spear" },

            onactivate   = CreateAddTagFn(UPGRADETYPES.SPEAR_LIGHTNING.."_upgradeuser"),
            ondeactivate = CreateRemoveTagFn(UPGRADETYPES.SPEAR_LIGHTNING.."_upgradeuser"),
        },

        --------------------------------------------------------------------------

        -- Battle Helms will be a little more durable when worn by Wigfrid.
        wathgrithr_arsenal_helmet_1 = {
            group = "arsenal",
            tags = { "helmet", "helmetcondition" },

            root = true,
            connects = { "wathgrithr_arsenal_helmet_2" },
        },

        -- Battle Helms will be a fair amount more durable when worn by Wigfrid.
        wathgrithr_arsenal_helmet_2 = {
            group = "arsenal",
            tags = { "helmet", "helmetcondition" },

            connects = { "wathgrithr_arsenal_helmet_3" },
        },

        -- Learn to craft the Commander's Helm: a helm that protects against knockback attacks.
        wathgrithr_arsenal_helmet_3 = {
            group = "arsenal",
            tags = { "helmet" },

            connects = {
                "wathgrithr_arsenal_helmet_4",
                "wathgrithr_arsenal_helmet_5",

                "wathgrithr_arsenal_shield_1",
            },
        },

        -- The Commander's Helm now has protection against planar damage.
        wathgrithr_arsenal_helmet_4 = {
            group = "arsenal",
            tags = { "helmet" },
        },

        -- Wigfrid's natural healing ability will repair her Commander's Helm when she continues to fight at maximum health.
        wathgrithr_arsenal_helmet_5 = {
            group = "arsenal",
            tags = { "helmet" },
        },

        --------------------------------------------------------------------------

        -- Learn to craft the Battle Rönd. This shield can be used to attack, block attacks, and provide extra protection while equipped.
        wathgrithr_arsenal_shield_1 = {
            group = "arsenal",
            tags = { "shield" },

            connects = {
                "wathgrithr_arsenal_shield_2",
                "wathgrithr_arsenal_shield_3",
            },

            onactivate   = CreateAddTagFn("wathgrithrshielduser"),
            ondeactivate = CreateRemoveTagFn("wathgrithrshielduser"),
        },

        -- The duration of the Battle Rönd's ability to block attacks will be increased.
        wathgrithr_arsenal_shield_2 = {
            group = "arsenal",
            tags = { "shield" },
        },

        -- After blocking an attack with the Battle Rönd, your next attack within 5 seconds will deal +10 damage.
        wathgrithr_arsenal_shield_3 = {
            group = "arsenal",
            tags = { "shield" },
        },

        --------------------------------------------------------------------------

        -- Beefalos will be domesticated 15% faster.
        wathgrithr_beefalo_1 = {
            group = "beefalo",
            tags = { "beefalodomestication" },

            root = true,
            connects = { "wathgrithr_beefalo_2" },

            onactivate = ONACTIVATE_FNS.Beefalo,
        },

        -- Beefalos will allow you to ride them for 30% longer.
        wathgrithr_beefalo_2 = {
            group = "beefalo",
            tags = { "beefalobucktime" },

            connects = { "wathgrithr_beefalo_3" },
        },

        -- Riding a beefalo will make your inspiration slowly rise until it reaches the halfway mark.
        wathgrithr_beefalo_3 = {
            group = "beefalo",
            tags = { "beefaloinspiration" },

            connects = { "wathgrithr_beefalo_saddle" },
        },

        -- Learn to craft a new Beefalo Saddle that protects your beefalo.
        wathgrithr_beefalo_saddle = {
            group = "beefalo",
            tags = { "saddle" },
        },

        --------------------------------------------------------------------------

        -- Sing quote battle songs 10 times to unlock.
        wathgrithr_songs_instantsong_cd_lock = {
            group = "songs",

            root = true,
            connects = { "wathgrithr_songs_instantsong_cd" },

            lock_open = CreateAccomplishmentCountLockFn("wathgrithr_instantsong_uses", TUNING.SKILLS.WATHGRITHR.INSTANTSONG_CD_UNLOCK_COUNT),
        },

        -- Quote battle songs now no longer consume Inspiration, and instead have a cooldown.
        wathgrithr_songs_instantsong_cd = {
            group = "songs",
        },

        -- Have 6 different battle songs in your inventory.
        wathgrithr_songs_container_lock = {
            group = "songs",

            root = true,
            connects = { "wathgrithr_songs_container" },

            lock_open = CreateAccomplishmentLockFn("wathgrithr_container_unlocked"),
        },

        -- Quote battle songs now no longer consume Inspiration, and instead have a cooldown.
        wathgrithr_songs_container = {
            group = "songs",
        },

        -- Play a Beefalo Horn to unlock.
        wathgrithr_songs_revivewarrior_lock = {
            group = "songs",

            root = true,
            connects = { "wathgrithr_songs_revivewarrior" },

            lock_open = CreateAccomplishmentLockFn("wathgrithr_horn_played"),
        },

        -- Learn to craft the Warrior's Reprise: Bring your allies back to life so they can fight for Valhalla.
        wathgrithr_songs_revivewarrior = {
            group = "songs",
        },

        --------------------------------------------------------------------------

        -- Receive a divine blessing that will provide you with +10 Planar Defense.
        wathgrithr_combat_defense = {
            group = "combat",
            root = true,

            onactivate = ONACTIVATE_FNS.CombatDefense,
            ondeactivate = ONDEACTIVATE_FNS.CombatDefense,
        },

        --------------------------------------------------------------------------

        wathgrithr_allegiance_lock_1 = {
            group = "allegiance",

            root = true,

            lock_open = function(prefabname, activatedskills, readonly)
                return SkillTreeFns.CountSkills(prefabname, activatedskills) >= 12
            end,
        },

        wathgrithr_allegiance_shadow_lock_1 = SkillTreeFns.MakeFuelWeaverLock({ pos = {ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_2} }),
        wathgrithr_allegiance_shadow_lock_2 = SkillTreeFns.MakeNoLunarLock({ pos = {ALLEGIANCE_SHADOW_X, ALLEGIANCE_POS_Y_3} }),

        wathgrithr_allegiance_lunar_lock_1  = SkillTreeFns.MakeCelestialChampionLock({ pos = {ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_2} }),
        wathgrithr_allegiance_lunar_lock_2  = SkillTreeFns.MakeNoShadowLock({ pos = {ALLEGIANCE_LUNAR_X, ALLEGIANCE_POS_Y_3} }),

        -- Learn to craft the Dark Lament: Allies will take less damage from shadow aligned enemies and will give bonus damage to lunar aligned enemies.
        wathgrithr_allegiance_shadow = {
            group = "allegiance",
            tags = { "shadow", "shadow_favor" },

            locks = { "wathgrithr_allegiance_lock_1", "wathgrithr_allegiance_shadow_lock_1", "wathgrithr_allegiance_shadow_lock_2" },

            onactivate = ONACTIVATE_FNS.AllegianceShadow,
            ondeactivate = ONDEACTIVATE_FNS.AllegianceShadow,
        },

        -- Learn to craft the Enlightened Lullaby: Allies will take less damage from lunar aligned enemies and will give bonus damage to shadow aligned enemies.
        wathgrithr_allegiance_lunar = {
            group = "allegiance",
            tags = { "lunar", "lunar_favor" },

            locks = { "wathgrithr_allegiance_lock_1", "wathgrithr_allegiance_lunar_lock_1", "wathgrithr_allegiance_lunar_lock_2" },

            onactivate = ONACTIVATE_FNS.AllegianceLunar,
            ondeactivate = ONDEACTIVATE_FNS.AllegianceLunar,
        },
    }


    for name, data in pairs(skills) do
        local uppercase_name = string.upper(name)

        data.tags = data.tags or {}

        local pos = POSITIONS[name]

        data.pos = pos ~= nil and { pos.x, pos.y } or data.pos

        if not table.contains(data.tags, data.group) then
            table.insert(data.tags, data.group)
        end

        data.desc = data.desc or WATHGRITHR_SKILL_STRINGS[uppercase_name.."_DESC"]

        -- If it's not a lock.
        if not data.lock_open then
            data.title = data.title or WATHGRITHR_SKILL_STRINGS[uppercase_name.."_TITLE"]
            data.icon = data.icon or name

        elseif not table.contains(data.tags, "lock") then
            table.insert(data.tags, "lock")
        end
    end

    return {
        SKILLS = skills,
        ORDERS = ORDERS,
    }
end

--------------------------------------------------------------------------------------------------

return BuildSkillsData