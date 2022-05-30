local function OverrideTuningVariables(tuning)
    if tuning ~= nil then
        for k, v in pairs(tuning) do
            if BRANCH == "dev" then
                assert(TUNING[k] ~= nil, string.format("%s does not exist in TUNING, either fix the spelling, or add the value to TUNING.", k))
            end
            ORIGINAL_TUNING[k] = TUNING[k]
            TUNING[k] = v
        end
    end
end

local SEASON_FRIENDLY_LENGTHS =
{
	noseason = 0,
	veryshortseason = TUNING.SEASON_LENGTH_FRIENDLY_VERYSHORT,
	shortseason = TUNING.SEASON_LENGTH_FRIENDLY_SHORT,
	default = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT,
	longseason = TUNING.SEASON_LENGTH_FRIENDLY_LONG,
	verylongseason = TUNING.SEASON_LENGTH_FRIENDLY_VERYLONG,
}

local SEASON_HARSH_LENGTHS =
{
	noseason = 0,
	veryshortseason = TUNING.SEASON_LENGTH_HARSH_VERYSHORT,
	shortseason = TUNING.SEASON_LENGTH_HARSH_SHORT,
	default = TUNING.SEASON_LENGTH_HARSH_DEFAULT,
	longseason = TUNING.SEASON_LENGTH_HARSH_LONG,
	verylongseason = TUNING.SEASON_LENGTH_HARSH_VERYLONG,
}

local NEVER_TIME = TUNING.TOTAL_DAY_TIME*9999999999

--TheWorld does NOT exist when running _pre overrides
local applyoverrides_pre = {
    --giants
    deerclops = function(difficulty)
        local tuning_vars = {
            never = {
                SPAWN_DEERCLOPS = false,
            },
            rare = {
                DEERCLOPS_ATTACKS_PER_SEASON = 2,
                DEERCLOPS_ATTACKS_OFF_SEASON = false,
            },
            --[[
            default = {
                DEERCLOPS_ATTACKS_PER_SEASON = 4,
                DEERCLOPS_ATTACKS_OFF_SEASON = false,
                SPAWN_DEERCLOPS = true,
            },
            --]]
            often = {
                DEERCLOPS_ATTACKS_PER_SEASON = 8,
                DEERCLOPS_ATTACKS_OFF_SEASON = false,
            },
            always = {
                DEERCLOPS_ATTACKS_PER_SEASON = 10,
                DEERCLOPS_ATTACKS_OFF_SEASON = true,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    bearger = function(difficulty)
        local tuning_vars = {
            never = {
                SPAWN_BEARGER = false,
            },
            rare = {
                BEARGER_CHANCES = {0.5},
            },
            --[[
            default = {
                BEARGER_CHANCES = {1},
                SPAWN_BEARGER = true,
            },
            --]]
            often = {
                BEARGER_CHANCES = {1, 0.5},
            },
            always = {
                BEARGER_CHANCES = {1, 1},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    goosemoose = function(difficulty)
        local tuning_vars = {
            never = {
                MOOSE_DENSITY = 0,
            },
            rare = {
                MOOSE_DENSITY = 0.25,
            },
            --[[
            default = {
                MOOSE_DENSITY = 0.5,
            },
            --]]
            often = {
                MOOSE_DENSITY = 0.75,
            },
            always = {
                MOOSE_DENSITY = 1,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    dragonfly = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_DRAGONFLY = false,
            },
            rare = {
                DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 40,
            },
            --[[
            default = {
                DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 20,
                SPAWN_DRAGONFLY = true,
            },
            ]]
            often = {
                DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10,
            },
            always = {
                DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    antliontribute = function(difficulty)
        local tuning_vars =
        {
            never = {
                ANTLION_TRIBUTE = false,
            },
            rare = {
                ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 7.2,
                ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 10,
                ANTLION_TRIBUTE_TO_RAGE_TIME = TUNING.TOTAL_DAY_TIME * .5,
            },
            --[[
            default =   {
                ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 4.2,
                ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 6,
                ANTLION_TRIBUTE_TO_RAGE_TIME = TUNING.TOTAL_DAY_TIME * .33,
                ANTLION_RAGE_TIME_FAILURE_SCALE = 0.8,
                ANTLION_TRIBUTE = true,
            },
            --]]
            often =  {
                ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 4,
                ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 5,
            },
            always = {
                ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 3.2,
                ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 4.5,
                ANTLION_RAGE_TIME_FAILURE_SCALE = 0.7,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
	deciduousmonster = function(difficulty)
		local tuning_vars =
		{
			never = {
                DECID_MONSTER_MIN_DAY = NEVER_TIME,
                DECID_MONSTER_SPAWN_CHANCE_AUTUMN = 0,
                DECID_MONSTER_SPAWN_CHANCE_SPRING = 0,
                DECID_MONSTER_SPAWN_CHANCE_SUMMER = 0,
            },
			rare = {
                DECID_MONSTER_MIN_DAY = 5,
                DECID_MONSTER_SPAWN_CHANCE_BASE = 0.075,
                DECID_MONSTER_SPAWN_CHANCE_LOW = 0.04,
                DECID_MONSTER_SPAWN_CHANCE_MED = 0.0165,
            },
            --[[
            default = {
                DECID_MONSTER_MIN_DAY = 3,
                DECID_MONSTER_SPAWN_CHANCE_AUTUMN = 0.15,
                DECID_MONSTER_SPAWN_CHANCE_SPRING = 0.08,
                DECID_MONSTER_SPAWN_CHANCE_SUMMER = 0.033,
            },
            --]]
			often = {
                DECID_MONSTER_MIN_DAY = 2,
                DECID_MONSTER_SPAWN_CHANCE_BASE = 0.3,
                DECID_MONSTER_SPAWN_CHANCE_LOW = 0.16,
                DECID_MONSTER_SPAWN_CHANCE_MED = 0.066,
            },
			always = {
                DECID_MONSTER_MIN_DAY = 1,
                DECID_MONSTER_SPAWN_CHANCE_BASE = 0.6,
                DECID_MONSTER_SPAWN_CHANCE_LOW = 0.32,
                DECID_MONSTER_SPAWN_CHANCE_MED = 0.132,
            },
		}
		OverrideTuningVariables(tuning_vars[difficulty])
	end,
    liefs = function(difficulty)
        local tuning_vars =
        {
            never = {
                LEIF_MIN_DAY = NEVER_TIME,
                LEIF_PERCENT_CHANCE = 0,
            },
            rare = {
                LEIF_MIN_DAY = 5,
                LEIF_PERCENT_CHANCE = 1 / 100,
            },
            --[[
            default = {
                LEIF_MIN_DAY = 3,
                LEIF_PERCENT_CHANCE = 1/75,
            },
            --]]
            often = {
                LEIF_MIN_DAY = 2,
                LEIF_PERCENT_CHANCE = 1 / 70,
            },
            always = {
                LEIF_MIN_DAY = 1,
                LEIF_PERCENT_CHANCE = 1 / 55,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    crabking = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_CRABKING = false,
            },
            rare = {
                CRABKING_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 40,
            },
            --[[
            default = {
                CRABKING_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 20,
                SPAWN_CRABKING = true,
            },
            --]]
            often = {
                CRABKING_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10,
            },
            always = {
                CRABKING_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    beequeen = function(difficulty)
        local tuning_vars =
        {
            never = {
                BEEQUEEN_SPAWN_WORK_THRESHOLD = 0, --can't spawn beequeen
            },
            rare = {
                BEEQUEEN_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 40,
                BEEQUEEN_SPAWN_WORK_THRESHOLD = 8,
            },
            --[[
            default = {
                BEEQUEEN_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 20,
                BEEQUEEN_SPAWN_WORK_THRESHOLD = 12,
                BEEQUEEN_SPAWN_MAX_WORK = 16,
            },
            --]]
            often = {
                BEEQUEEN_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10,
            },
            always = {
                BEEQUEEN_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5,
                BEEQUEEN_SPAWN_WORK_THRESHOLD = 16,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    toadstool = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_TOADSTOOL = false,
            },
            rare = {
                TOADSTOOL_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 40,
            },
            --[[
            default = {
                TOADSTOOL_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 20,
                SPAWN_TOADSTOOL = true,
            },
            --]]
            often = {
                TOADSTOOL_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10,
            },
            always = {
                TOADSTOOL_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    malbatross = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_MALBATROSS = false,
            },
            rare = {
                MALBATROSS_SPAWNDELAY_BASE = TUNING.TOTAL_DAY_TIME * 20,
                MALBATROSS_SPAWNDELAY_RANDOM = TUNING.TOTAL_DAY_TIME * 10,
                MALBATROSS_HOOKEDFISH_SUMMONCHANCE = 0.05,
                MALBATROSS_SHOAL_PERCENTAGE_TO_TEST = 0.125,
            },
            --[[
            default = {
                MALBATROSS_SPAWNDELAY_BASE = TUNING.TOTAL_DAY_TIME * 10,
                MALBATROSS_SPAWNDELAY_RANDOM = TUNING.TOTAL_DAY_TIME * 5,
                MALBATROSS_HOOKEDFISH_SUMMONCHANCE = 0.1,
                MALBATROSS_SHOAL_PERCENTAGE_TO_TEST = 0.25,
                SPAWN_MALBATROSS = true,
            },
            --]]
            often = {
                MALBATROSS_SPAWNDELAY_BASE = TUNING.TOTAL_DAY_TIME * 8,
                MALBATROSS_SPAWNDELAY_RANDOM = TUNING.TOTAL_DAY_TIME * 4,
                MALBATROSS_HOOKEDFISH_SUMMONCHANCE = 0.2,
                MALBATROSS_SHOAL_PERCENTAGE_TO_TEST = 0.5,
            },
            always = {
                MALBATROSS_SPAWNDELAY_BASE = TUNING.TOTAL_DAY_TIME * 4,
                MALBATROSS_SPAWNDELAY_RANDOM = TUNING.TOTAL_DAY_TIME * 2,
                MALBATROSS_HOOKEDFISH_SUMMONCHANCE = 0.4,
                MALBATROSS_SHOAL_PERCENTAGE_TO_TEST = 1,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    fruitfly = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_LORDFRUITFLY = false,
            },
            rare = {
                LORDFRUITFLY_INITIALSPAWN_TIME = TUNING.TOTAL_DAY_TIME * 50,
                LORDFRUITFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 30,
                LORDFRUITFLY_CROP_ROTTED_ADVANCE_TIME = TUNING.TOTAL_DAY_TIME * 0.25,
                LORDFRUITFLY_SPAWNERRADIUS = 4,
                LORDFRUITFLY_SPAWNERCOUNT = 20,
            },
            --[[
            default = {
                LORDFRUITFLY_INITIALSPAWN_TIME = TUNING.TOTAL_DAY_TIME * 35,
                LORDFRUITFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 20,
                LORDFRUITFLY_CROP_ROTTED_ADVANCE_TIME = TUNING.TOTAL_DAY_TIME * 0.5,
                LORDFRUITFLY_SPAWNERRADIUS = 4,
                LORDFRUITFLY_SPAWNERCOUNT = 15,
                SPAWN_LORDFRUITFLY = true,
            },
            --]]
            often = {
                LORDFRUITFLY_INITIALSPAWN_TIME = TUNING.TOTAL_DAY_TIME * 25,
                LORDFRUITFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 15,
                LORDFRUITFLY_CROP_ROTTED_ADVANCE_TIME = TUNING.TOTAL_DAY_TIME * 1,
                LORDFRUITFLY_SPAWNERRADIUS = 6,
                LORDFRUITFLY_SPAWNERCOUNT = 15,
            },
            always = {
                LORDFRUITFLY_INITIALSPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10,
                LORDFRUITFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5,
                LORDFRUITFLY_CROP_ROTTED_ADVANCE_TIME = TUNING.TOTAL_DAY_TIME * 2,
                LORDFRUITFLY_SPAWNERRADIUS = 6,
                LORDFRUITFLY_SPAWNERCOUNT = 10,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    klaus = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_KLAUS = false,
            },
            rare = {
                KLAUSSACK_EVENT_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 30, -- winters feast event respawn time
                KLAUSSACK_SPAWN_DELAY = TUNING.TOTAL_DAY_TIME * 4,
                KLAUSSACK_SPAWN_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 8,
                KLAUSSACK_MAX_SPAWNS = 1,
            },
            --[[
            default = {
                KLAUSSACK_EVENT_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 20, -- winters feast event respawn time
                KLAUSSACK_RESPAWN_DELAY = TUNING.TOTAL_DAY_TIME * 10,
                KLAUSSACK_SPAWN_DELAY = TUNING.TOTAL_DAY_TIME * 1,
                KLAUSSACK_SPAWN_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 2,
                KLAUSSACK_MAX_SPAWNS = 1,
                SPAWN_KLAUS = true,
            },
            --]]
            often = {
                KLAUSSACK_EVENT_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10, -- winters feast event respawn time
                KLAUSSACK_RESPAWN_DELAY = TUNING.TOTAL_DAY_TIME * 5,
                KLAUSSACK_MAX_SPAWNS = 2,
            },
            always = {
                KLAUSSACK_EVENT_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5, -- winters feast event respawn time
                KLAUSSACK_RESPAWN_DELAY = TUNING.TOTAL_DAY_TIME * 2,
                KLAUSSACK_SPAWN_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 1,
                KLAUSSACK_MAX_SPAWNS = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    spiderqueen = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_SPIDERQUEEN = false,
            },
            rare = {
                SPIDERDEN_GROW_TIME_QUEEN = TUNING.DAY_TIME_DEFAULT * 40,
                SPIDERDEN_QUEEN_CAP = 2,
                SPIDERDEN_QUEEN_RANGE_CHECK = 60,
            },
            --[[
            default = {
                SPIDERDEN_GROW_TIME_QUEEN = TUNING.DAY_TIME_DEFAULT * 20,
                SPIDERDEN_QUEEN_CAP = 4,
                SPIDERDEN_QUEEN_RANGE_CHECK = 60,
                SPAWN_SPIDERQUEEN = true,
            },
            --]]
            often = {
                SPIDERDEN_GROW_TIME_QUEEN = TUNING.DAY_TIME_DEFAULT * 10,
                SPIDERDEN_QUEEN_CAP = 4,
                SPIDERDEN_QUEEN_RANGE_CHECK = 30,
            },
            always = {
                SPIDERDEN_GROW_TIME_QUEEN = TUNING.DAY_TIME_DEFAULT * 5,
                SPIDERDEN_QUEEN_RANGE_CHECK = 0, --0 will prevent the cap from ever being reached.
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    eyeofterror = function(difficulty)
        local tuning_vars = {
            never = {
                SPAWN_EYEOFTERROR = false,
            },
            rare = {
                EYEOFTERROR_SPAWNDELAY = TUNING.TOTAL_DAY_TIME * 25,
            },
            --[[
            default = {
                EYEOFTERROR_SPAWNDELAY = TUNING.TOTAL_DAY_TIME * 15,
            },
            --]]
            often = {
                EYEOFTERROR_SPAWNDELAY = TUNING.TOTAL_DAY_TIME * 10,
            },
            always = {
                EYEOFTERROR_SPAWNDELAY = TUNING.TOTAL_DAY_TIME * 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,


    --monsters
    mutated_hounds = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_MUTATED_HOUNDS = false,
            },
            --[[
            default = {
                SPAWN_MUTATED_HOUNDS = true,
            }
            --]]
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    lureplants = function(difficulty)
        local tuning_vars =
        {
            never = {
                LUREPLANT_SPAWNINTERVAL = 0,
                LUREPLANT_SPAWNINTERVALVARIANCE = 0,
            },
            rare = {
                LUREPLANT_SPAWNINTERVAL = TUNING.TOTAL_DAY_TIME * 10,
                LUREPLANT_SPAWNINTERVALVARIANCE = TUNING.TOTAL_DAY_TIME * 2,
            },
            --[[
            default = {
                LUREPLANT_SPAWNINTERVAL = TUNING.TOTAL_DAY_TIME * 4,
                LUREPLANT_SPAWNINTERVALVARIANCE = TUNING.TOTAL_DAY_TIME * 1,
            },
            --]]
            often = {
                LUREPLANT_SPAWNINTERVAL = TUNING.TOTAL_DAY_TIME * 3,
                LUREPLANT_SPAWNINTERVALVARIANCE = TUNING.TOTAL_DAY_TIME * 1,
            },
            always = {
                LUREPLANT_SPAWNINTERVAL = TUNING.TOTAL_DAY_TIME * 2,
                LUREPLANT_SPAWNINTERVALVARIANCE = TUNING.TOTAL_DAY_TIME * 0.5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    hound_mounds = function(difficulty) -- child spawner
        local tuning_vars =
        {
            never = {
                HOUNDMOUND_ENABLED = false,
            },
            few = {
                HOUNDMOUND_HOUNDS_MIN = 1,
                HOUNDMOUND_HOUNDS_MAX = 2,
                HOUNDMOUND_REGEN_TIME = TUNING.SEG_TIME * 12,
                HOUNDMOUND_RELEASE_TIME = TUNING.SEG_TIME * 2,
            },
            --[[
            default = {
                HOUNDMOUND_HOUNDS_MIN = 2,
                HOUNDMOUND_HOUNDS_MAX = 3,
                HOUNDMOUND_REGEN_TIME = TUNING.SEG_TIME * 6,
                HOUNDMOUND_RELEASE_TIME = TUNING.SEG_TIME,
                HOUNDMOUND_ENABLED = true,
            },
            --]]
            many = {
                HOUNDMOUND_HOUNDS_MIN = 3,
                HOUNDMOUND_HOUNDS_MAX = 5,
                HOUNDMOUND_REGEN_TIME = TUNING.SEG_TIME * 4,
                HOUNDMOUND_RELEASE_TIME = TUNING.SEG_TIME / 2,
            },
            always = {
                HOUNDMOUND_HOUNDS_MIN = 4,
                HOUNDMOUND_HOUNDS_MAX = 6,
                HOUNDMOUND_REGEN_TIME = TUNING.SEG_TIME * 2,
                HOUNDMOUND_RELEASE_TIME = TUNING.SEG_TIME / 4,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    bats_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                BATCAVE_ENABLED = false,
                CAVE_ENTRANCE_BATS_ENABLED = false,
            },
            few = {
                BATCAVE_REGEN_PERIOD = TUNING.SEG_TIME * 8,
                BATCAVE_SPAWN_PERIOD = 40,
                BATCAVE_MAX_CHILDREN = 3,

                CAVE_ENTRANCE_BATS_REGEN_PERIOD = TUNING.SEG_TIME * 4,
                CAVE_ENTRANCE_BATS_MAX_CHILDREN = 4,
            },
            --[[
            default = {
                BATCAVE_REGEN_PERIOD = TUNING.SEG_TIME * 4,
                BATCAVE_SPAWN_PERIOD = 20,
                BATCAVE_MAX_CHILDREN = 4,
                BATCAVE_ENABLED = true,

                CAVE_ENTRANCE_BATS_REGEN_PERIOD = TUNING.SEG_TIME * 2,
                CAVE_ENTRANCE_BATS_MAX_CHILDREN = 6,
                CAVE_ENTRANCE_BATS_ENABLED = true,
            },
            --]]
            many = {
                BATCAVE_REGEN_PERIOD = TUNING.SEG_TIME * 2,
                BATCAVE_SPAWN_PERIOD = 10,
                BATCAVE_MAX_CHILDREN = 6,

                CAVE_ENTRANCE_BATS_REGEN_PERIOD = TUNING.SEG_TIME * 1,
                CAVE_ENTRANCE_BATS_MAX_CHILDREN = 8,
            },
            always = {
                BATCAVE_REGEN_PERIOD = TUNING.SEG_TIME,
                BATCAVE_SPAWN_PERIOD = 5,
                BATCAVE_MAX_CHILDREN = 10,

                CAVE_ENTRANCE_BATS_REGEN_PERIOD = TUNING.SEG_TIME / 2,
                CAVE_ENTRANCE_BATS_MAX_CHILDREN = 10,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    molebats = function(difficulty)
        local tuning_vars =
        {
            never = {
                MOLEBAT_ENABLED = false,
            },
            few = {
                MOLEBAT_ALLY_COOLDOWN = TUNING.TOTAL_DAY_TIME * 4,
            },
            --[[
            default = {
                MOLEBAT_ALLY_COOLDOWN = TUNING.TOTAL_DAY_TIME * 2,
                MOLEBAT_ENABLED = true,
            },
            --]]
            many = {
                MOLEBAT_ALLY_COOLDOWN = TUNING.TOTAL_DAY_TIME * 1,
            },
            always = {
                MOLEBAT_ALLY_COOLDOWN = TUNING.TOTAL_DAY_TIME / 2,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    mushgnome = function(difficulty)
        local tuning_vars =
        {
            never = {
                MUSHGNOME_ENABLED = false,
            },
            few = {
                MUSHGNOME_RELEASE_TIME = 40,
                MUSHGNOME_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 2,
                MUSHGNOME_MAX_CHILDREN = 1,
            },
            --[[
            default = {
                MUSHGNOME_RELEASE_TIME = 20,
                MUSHGNOME_REGEN_TIME = TUNING.TOTAL_DAY_TIME,
                MUSHGNOME_MAX_CHILDREN = 1,
                MUSHGNOME_ENABLED = true,
            },
            --]]
            many = {
                MUSHGNOME_RELEASE_TIME = 10,
                MUSHGNOME_REGEN_TIME = TUNING.TOTAL_DAY_TIME / 2,
                MUSHGNOME_MAX_CHILDREN = 1,
            },
            always = {
                MUSHGNOME_RELEASE_TIME = 5,
                MUSHGNOME_REGEN_TIME = TUNING.TOTAL_DAY_TIME / 4,
                MUSHGNOME_MAX_CHILDREN = 2,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    nightmarecreatures = function(difficulty)
        local tuning_vars =
        {
            never = {
                NIGHTMARELIGHT_ENABLED = false,
                NIGHTMAREFISSURE_ENABLED = false,
            },
            few = {
                NIGHTMARELIGHT_RELEASE_TIME = 10,
                NIGHTMARELIGHT_REGEN_TIME = TUNING.SEG_TIME * 2,
                NIGHTMARELIGHT_MINCHILDREN = 1,
                NIGHTMARELIGHT_MAXCHILDREN = 1,

                NIGHTMAREFISSURE_RELEASE_TIME = 10,
                NIGHTMAREFISSURE_REGEN_TIME = TUNING.SEG_TIME * 2,
                NIGHTMAREFISSURE_MAXCHILDREN = 1,
            },
            --[[
            default = {
                NIGHTMARELIGHT_RELEASE_TIME = 5,
                NIGHTMARELIGHT_REGEN_TIME = TUNING.SEG_TIME,
                NIGHTMARELIGHT_MINCHILDREN = 1,
                NIGHTMARELIGHT_MAXCHILDREN = 2,
                NIGHTMARELIGHT_ENABLED = true,

                NIGHTMAREFISSURE_RELEASE_TIME = 5,
                NIGHTMAREFISSURE_REGEN_TIME = TUNING.SEG_TIME,
                NIGHTMAREFISSURE_MAXCHILDREN = 1,
                NIGHTMAREFISSURE_ENABLED = true,
            },
            --]]
            many = {
                NIGHTMARELIGHT_RELEASE_TIME = 5,
                NIGHTMARELIGHT_REGEN_TIME = TUNING.SEG_TIME / 2,
                NIGHTMARELIGHT_MINCHILDREN = 2,
                NIGHTMARELIGHT_MAXCHILDREN = 3,

                NIGHTMAREFISSURE_RELEASE_TIME = 5,
                NIGHTMAREFISSURE_REGEN_TIME = TUNING.SEG_TIME / 2,
                NIGHTMAREFISSURE_MAXCHILDREN = 1,
            },
            always = {
                NIGHTMARELIGHT_RELEASE_TIME = 1,
                NIGHTMARELIGHT_REGEN_TIME = TUNING.SEG_TIME / 4,
                NIGHTMARELIGHT_MINCHILDREN = 2,
                NIGHTMARELIGHT_MAXCHILDREN = 4,

                NIGHTMAREFISSURE_RELEASE_TIME = 1,
                NIGHTMAREFISSURE_REGEN_TIME = TUNING.SEG_TIME / 4,
                NIGHTMAREFISSURE_MAXCHILDREN = 2,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    sharks = function(difficulty)
        local tuning_vars =
        {
            never = {
                SHARK_SPAWN_CHANCE = 0,
                SHARK_TEST_RADIUS = 0,
            },
            few = {
                SHARK_SPAWN_CHANCE = 0.0375,
                SHARK_TEST_RADIUS = 150,
            },
            --[[
            default = {
                SHARK_SPAWN_CHANCE = 0.075,
                SHARK_TEST_RADIUS = 100,
            },
            --]]
            many = {
                SHARK_SPAWN_CHANCE = 0.15,
                SHARK_TEST_RADIUS = 75,
            },
            always = {
                SHARK_SPAWN_CHANCE = 0.3,
                SHARK_TEST_RADIUS = 50,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    spiders_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPIDERDEN_ENABLED = false,
            },
            few = {
                SPIDERDEN_SPIDERS = {2, 4, 6},
                SPIDERDEN_WARRIORS = {0, 0, 2},
                SPIDERDEN_EMERGENCY_WARRIORS = {0, 2, 4},
                SPIDERDEN_EMERGENCY_RADIUS = {5, 10, 15},
                SPIDERDEN_REGEN_TIME = TUNING.SEG_TIME*6,
            },
            --[[
            default = {
                SPIDERDEN_SPIDERS = {3, 6, 9},
                SPIDERDEN_WARRIORS = {0, 1, 3},
                SPIDERDEN_EMERGENCY_WARRIORS = {0, 4, 8},
                SPIDERDEN_EMERGENCY_RADIUS = {10, 15, 20},
                SPIDERDEN_REGEN_TIME = TUNING.SEG_TIME*3,
                SPIDERDEN_ENABLED = true,
            },
            --]]
            many = {
                SPIDERDEN_SPIDERS = {4, 8, 12},
                SPIDERDEN_WARRIORS = {0, 2, 6},
                SPIDERDEN_EMERGENCY_WARRIORS = {0, 8, 16},
                SPIDERDEN_EMERGENCY_RADIUS = {15, 20, 25},
                SPIDERDEN_REGEN_TIME = TUNING.SEG_TIME*1.5,
            },
            always = {
                SPIDERDEN_SPIDERS = {6, 12, 18},
                SPIDERDEN_WARRIORS = {2, 4, 12},
                SPIDERDEN_EMERGENCY_WARRIORS = {4, 12, 20},
                SPIDERDEN_EMERGENCY_RADIUS = {20, 25, 30},
                SPIDERDEN_REGEN_TIME = TUNING.SEG_TIME*0.75,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    spider_warriors = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_SPIDER_WARRIORS = false,
            },
            --[[
            default = {
                SPAWN_SPIDER_WARRIORS = true,
            }
            --]]
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    spider_hider = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPIDERHOLE_ENABLED = false,
            },
            few = {
                SPIDERHOLE_RELEASE_TIME = TUNING.TOTAL_DAY_TIME,
                SPIDERHOLE_REGEN_TIME = TUNING.TOTAL_DAY_TIME/2,
                SPIDERHOLE_MIN_CHILDREN = 1,
                SPIDERHOLE_MAX_CHILDREN = 2,
            },
            --[[
            default = {
                SPIDERHOLE_RELEASE_TIME = TUNING.TOTAL_DAY_TIME/2,
                SPIDERHOLE_REGEN_TIME = TUNING.TOTAL_DAY_TIME/4,
                SPIDERHOLE_MIN_CHILDREN = 2,
                SPIDERHOLE_MAX_CHILDREN = 3,
                SPIDERHOLE_ENABLED = true,
            },
            --]]
            many = {
                SPIDERHOLE_RELEASE_TIME = TUNING.TOTAL_DAY_TIME/4,
                SPIDERHOLE_REGEN_TIME = TUNING.TOTAL_DAY_TIME/8,
                SPIDERHOLE_MIN_CHILDREN = 3,
                SPIDERHOLE_MAX_CHILDREN = 4,
            },
            always = {
                SPIDERHOLE_RELEASE_TIME = TUNING.TOTAL_DAY_TIME/8,
                SPIDERHOLE_REGEN_TIME = TUNING.TOTAL_DAY_TIME/16,
                SPIDERHOLE_MIN_CHILDREN = 4,
                SPIDERHOLE_MAX_CHILDREN = 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    spider_spitter = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPIDERHOLE_SPITTER_CHANCE = 0,
            },
            few = {
                SPIDERHOLE_SPITTER_CHANCE = 0.16,
            },
            --[[
            default = {
                SPIDERHOLE_SPITTER_CHANCE = 0.33,
            },
            --]]
            many = {
                SPIDERHOLE_SPITTER_CHANCE = 0.5,
            },
            always = {
                SPIDERHOLE_SPITTER_CHANCE = 0.67,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    moon_spider = function(difficulty)
        local tuning_vars =
        {
            never = {
                MOONSPIDERDEN_ENABLED = false,
            },
            few = {
                MOONSPIDERDEN_SPIDERS = {1, 2, 3},
                MOONSPIDERDEN_SPIDER_REGENTIME = TUNING.SEG_TIME*8,
                MOONSPIDERDEN_RELEASE_TIME = TUNING.SEG_TIME*6,
                MOONSPIDERDEN_EMERGENCY_RADIUS = {5, 10, 15},
                MOONSPIDERDEN_MAX_INVESTIGATORS = {1, 1, 1},
            },
            --[[
            default = {
                MOONSPIDERDEN_SPIDERS = {2, 3, 4},
                MOONSPIDERDEN_SPIDER_REGENTIME = TUNING.SEG_TIME*4,
                MOONSPIDERDEN_RELEASE_TIME = TUNING.SEG_TIME*3,
                MOONSPIDERDEN_EMERGENCY_WARRIORS = {0, 0, 0},
                MOONSPIDERDEN_EMERGENCY_RADIUS = {10, 15, 20},
                MOONSPIDERDEN_MAX_INVESTIGATORS = {1, 2, 2},
                MOONSPIDERDEN_ENABLED = true,
            },
            --]]
            many = {
                MOONSPIDERDEN_SPIDERS = {3, 4, 5},
                MOONSPIDERDEN_SPIDER_REGENTIME = TUNING.SEG_TIME*2,
                MOONSPIDERDEN_RELEASE_TIME = TUNING.SEG_TIME*1.5,
                MOONSPIDERDEN_EMERGENCY_WARRIORS = {0, 1, 2},
                MOONSPIDERDEN_EMERGENCY_RADIUS = {15, 20, 25},
                MOONSPIDERDEN_MAX_INVESTIGATORS = {2, 3, 3},
            },
            always = {
                MOONSPIDERDEN_SPIDERS = {4, 5, 6},
                MOONSPIDERDEN_SPIDER_REGENTIME = TUNING.SEG_TIME,
                MOONSPIDERDEN_RELEASE_TIME = TUNING.SEG_TIME*0.75,
                MOONSPIDERDEN_EMERGENCY_WARRIORS = {1, 2, 3},
                MOONSPIDERDEN_EMERGENCY_RADIUS = {20, 25, 30},
                MOONSPIDERDEN_MAX_INVESTIGATORS = {3, 4, 4},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    spider_dropper = function(difficulty)
        local tuning_vars =
        {
            never = {
                DROPPERWEB_ENABLED = false,
            },
            few = {
                DROPPERWEB_RELEASE_TIME = TUNING.TOTAL_DAY_TIME,
                DROPPERWEB_REGEN_TIME = TUNING.TOTAL_DAY_TIME/2,
                DROPPERWEB_MIN_CHILDREN = 1,
                DROPPERWEB_MAX_CHILDREN = 2,
            },
            --[[
            default = {
                DROPPERWEB_RELEASE_TIME = TUNING.TOTAL_DAY_TIME/2,
                DROPPERWEB_REGEN_TIME = TUNING.TOTAL_DAY_TIME/4,
                DROPPERWEB_MIN_CHILDREN = 2,
                DROPPERWEB_MAX_CHILDREN = 3,
                DROPPERWEB_ENABLED = true,
            },
            --]]
            many = {
                DROPPERWEB_RELEASE_TIME = TUNING.TOTAL_DAY_TIME/4,
                DROPPERWEB_REGEN_TIME = TUNING.TOTAL_DAY_TIME/8,
                DROPPERWEB_MIN_CHILDREN = 3,
                DROPPERWEB_MAX_CHILDREN = 4,
            },
            always = {
                DROPPERWEB_RELEASE_TIME = TUNING.TOTAL_DAY_TIME/8,
                DROPPERWEB_REGEN_TIME = TUNING.TOTAL_DAY_TIME/16,
                DROPPERWEB_MIN_CHILDREN = 4,
                DROPPERWEB_MAX_CHILDREN = 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    squid = function(difficulty)
        local tuning_vars =
        {
            never = {
                SQUID_TEST_RADIUS = 0,
                SQUID_MAX_FISH = 0,
                SQUID_MAX_NUMBERS = {
                    ["new"] = 0,
                    ["quarter"] = 0,
                    ["half"] = 0,
                    ["threequarter"] = 0,
                    ["full"] = 0,
                },
                SQUID_CHANCE = {
                    ["new"] = 0,
                    ["quarter"] = 0,
                    ["half"] = 0,
                    ["threequarter"] = 0,
                    ["full"] = 0,
                },
            },
            few = {
                SQUID_TEST_RADIUS = 120,
                SQUID_MAX_FISH = 15,
                SQUID_MAX_NUMBERS = {
                    ["new"] = 4,
                    ["quarter"] = 2,
                    ["half"] = 2,
                    ["threequarter"] = 1,
                    ["full"] = 0,
                },
                SQUID_CHANCE = {
                    ["new"] = 0.1,
                    ["quarter"] = 0.05,
                    ["half"] = 0.025,
                    ["threequarter"] = 0.0125,
                    ["full"] = 0,
                },
            },
            --[[
            default = {
                SQUID_TEST_RADIUS = 80,
                SQUID_MAX_FISH = 10,
                SQUID_MAX_NUMBERS = {
                    ["new"] = 6,
                    ["quarter"] = 3,
                    ["half"] = 3,
                    ["threequarter"] = 2,
                    ["full"] = 0,
                },
                SQUID_CHANCE = {
                    ["new"] = 0.2,
                    ["quarter"] = 0.1,
                    ["half"] = 0.05,
                    ["threequarter"] = 0.025,
                    ["full"] = 0,
                },
            },
            --]]
            many = {
                SQUID_TEST_RADIUS = 60,
                SQUID_MAX_FISH = 8,
                SQUID_MAX_NUMBERS = {
                    ["new"] = 8,
                    ["quarter"] = 5,
                    ["half"] = 5,
                    ["threequarter"] = 3,
                    ["full"] = 0,
                },
                SQUID_CHANCE = {
                    ["new"] = 0.4,
                    ["quarter"] = 0.2,
                    ["half"] = 0.1,
                    ["threequarter"] = 0.05,
                    ["full"] = 0,
                },
            },
            always = {
                SQUID_TEST_RADIUS = 40,
                SQUID_MAX_FISH = 10,
                SQUID_MAX_NUMBERS = {
                    ["new"] = 12,
                    ["quarter"] = 6,
                    ["half"] = 6,
                    ["threequarter"] = 4,
                    ["full"] = 2,
                },
                SQUID_CHANCE = {
                    ["new"] = 0.8,
                    ["quarter"] = 0.4,
                    ["half"] = 0.2,
                    ["threequarter"] = 0.1,
                    ["full"] = 0.05,
                },
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    wasps = function(difficulty)
        local tuning_vars =
        {
            never = {
                WASPHIVE_ENABLED = false,
            },
            few = {
                WASPHIVE_RELEASE_TIME = 40,
                WASPHIVE_REGEN_TIME = 40,
                WASPHIVE_WASPS = 4,
                WASPHIVE_EMERGENCY_WASPS = 6,
                WASPHIVE_EMERGENCY_RADIUS = 20,
            },
            --[[
            default = {
                WASPHIVE_RELEASE_TIME = 20,
                WASPHIVE_REGEN_TIME = 20,
                WASPHIVE_WASPS = 5,
                WASPHIVE_EMERGENCY_WASPS = 8,
                WASPHIVE_EMERGENCY_RADIUS = 25,
                WASPHIVE_ENABLED = true,
            },
            --]]
            many = {
                WASPHIVE_RELEASE_TIME = 10,
                WASPHIVE_REGEN_TIME = 10,
                WASPHIVE_WASPS = 7,
                WASPHIVE_EMERGENCY_WASPS = 12,
                WASPHIVE_EMERGENCY_RADIUS = 30,
            },
            always = {
                WASPHIVE_RELEASE_TIME = 5,
                WASPHIVE_REGEN_TIME = 5,
                WASPHIVE_WASPS = 10,
                WASPHIVE_EMERGENCY_WASPS = 16,
                WASPHIVE_EMERGENCY_RADIUS = 40,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    merms = function(difficulty)
        local tuning_vars =
        {
            never = {
                MERMHOUSE_ENABLED = false,
                MERMWATCHTOWER_ENABLED = false,
            },
            few = {
                MERMHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 8,
                MERMHOUSE_MERMS = 2,

                MERMWATCHTOWER_REGEN_TIME = TUNING.TOTAL_DAY_TIME,
                MERMWATCHTOWER_MERMS = 1,
            },
            --[[
            default = {
                MERMHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 4,
                MERMHOUSE_MERMS = 3,
                MERMHOUSE_ENABLED = true,

                MERMWATCHTOWER_REGEN_TIME = TUNING.TOTAL_DAY_TIME / 2,
                MERMWATCHTOWER_MERMS = 1,
                MERMWATCHTOWER_ENABLED = true,
            },
            --]]
            many = {
                MERMHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 2,
                MERMHOUSE_MERMS = 4,

                MERMWATCHTOWER_REGEN_TIME = TUNING.TOTAL_DAY_TIME / 4,
                MERMWATCHTOWER_MERMS = 2,
            },
            always = {
                MERMHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 1,
                MERMHOUSE_MERMS = 6,

                MERMWATCHTOWER_REGEN_TIME = TUNING.TOTAL_DAY_TIME / 8,
                MERMWATCHTOWER_MERMS = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    walrus_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                WALRUS_REGEN_ENABLED = false,
            },
            few = {
                WALRUS_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME*5,
            },
            --[[
            default = {
                WALRUS_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME*2.5,
                WALRUS_REGEN_ENABLED = true,
            },
            --]]
            many = {
                WALRUS_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME*1.5,
            },
            always = {
                WALRUS_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME*0.5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    cookiecutters = function(difficulty)
        local tuning_vars =
        {
            never = {
                COOKIECUTTER_SPAWNER_ENABLED = false,
            },
            few = {
                COOKIECUTTER_SPAWNER_REGEN_TIME = 6*TUNING.SEG_TIME,
                COOKIECUTTER_SPAWNER_MAX_CHILDREN = 3,
            },
            --[[
            default = {
                COOKIECUTTER_SPAWNER_REGEN_TIME = 3*TUNING.SEG_TIME,
                COOKIECUTTER_SPAWNER_MAX_CHILDREN = 7,
                COOKIECUTTER_SPAWNER_ENABLED = true,
            },
            --]]
            many = {
                COOKIECUTTER_SPAWNER_REGEN_TIME = 2*TUNING.SEG_TIME,
                COOKIECUTTER_SPAWNER_MAX_CHILDREN = 12,
            },
            always = {
                COOKIECUTTER_SPAWNER_REGEN_TIME = TUNING.SEG_TIME,
                COOKIECUTTER_SPAWNER_MAX_CHILDREN = 16,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    --animals
    butterfly = function(difficulty)
        local tuning_vars =
        {
            never = {
                MAX_BUTTERFLIES = 0,
            },
            rare = {
                MAX_BUTTERFLIES = 2,
            },
            --[[
            default = {
                MAX_BUTTERFLIES = 4,
            },
            --]]
            often = {
                MAX_BUTTERFLIES = 7,
            },
            always = {
                MAX_BUTTERFLIES = 10,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    birds = function(difficulty)
        local tuning_vars =
        {
            never = {
                BIRD_SPAWN_MAX = 0,
            },
            rare = {
                BIRD_SPAWN_MAX = 2,
            },
            --[[
            default = {
                BIRD_SPAWN_MAX = 4,
            },
            --]]
            often = {
                BIRD_SPAWN_MAX = 7,
            },
            always = {
                BIRD_SPAWN_MAX = 10,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    perd = function(difficulty)
        local tuning_vars =
        {
            never = {
                PERD_SPAWNCHANCE = 0,
                PERD_ATTACK_PERIOD = 1,
            },
            rare = {
                PERD_SPAWNCHANCE = 0.1,
                PERD_ATTACK_PERIOD = 1,
            },
            --[[
            default = {
                PERD_SPAWNCHANCE = 0.1,
                PERD_ATTACK_PERIOD = 3,
            },
            --]]
            often = {
                PERD_SPAWNCHANCE = 0.2,
                PERD_ATTACK_PERIOD = 3,
            },
            always = {
                PERD_SPAWNCHANCE = 0.4,
                PERD_ATTACK_PERIOD = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    hunt = function(difficulty)
        local tuning_vars =
        {
            never = {
                HUNT_COOLDOWN = -1,
                HUNT_COOLDOWNDEVIATION = 0,
                HUNT_RESET_TIME = 0,
                HUNT_SPRING_RESET_TIME = -1,
            },
            rare = {
                HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * 2.4,
                HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * 0.3,
                HUNT_RESET_TIME = 5,
                HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 5,
            },
            --[[
            default = {
                HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * 1.2,
                HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * 0.3,
                HUNT_RESET_TIME = 5,
                HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 3,
            },
            --]]
            often = {
                HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * 0.6,
                HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * 0.3,
                HUNT_RESET_TIME = 5,
                HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 2,
            },
            always = {
                HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * 0.3,
                HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * 0.2,
                HUNT_RESET_TIME = 5,
                HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 1,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    alternatehunt = function(difficulty)
        local tuning_vars =
        {
            never = {
                HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0,
                HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0,
            },
            rare = {
                HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.0125,
                HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.0825,
            },
            --[[
            default = {
                HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.05,
                HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.33,
            },
            --]]
            often = {
                HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.1,
                HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.66,
            },
            always = {
                HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.7,
                HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.9,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    penguins = function(difficulty)
        local tuning_vars =
        {
            never = {
                PENGUINS_MAX_COLONIES = 0,
                PENGUINS_MAX_COLONIES_BUFFER = 0,
                PENGUINS_SPAWN_INTERVAL = 0,
                PENGUINS_DEFAULT_NUM_BOULDERS = 0,
            },
            rare = {
                PENGUINS_MAX_COLONIES = 3,
                PENGUINS_MAX_COLONIES_BUFFER = 1,
                PENGUINS_SPAWN_INTERVAL = 60,
                PENGUINS_DEFAULT_NUM_BOULDERS = 4,
            },
            --[[
            default = {
                PENGUINS_MAX_COLONIES = 5,
                PENGUINS_MAX_COLONIES_BUFFER = 1,
                PENGUINS_SPAWN_INTERVAL = 30,
                PENGUINS_DEFAULT_NUM_BOULDERS = 7,
            },
            --]]
            often = {
                PENGUINS_MAX_COLONIES = 6,
                PENGUINS_MAX_COLONIES_BUFFER = 2,
                PENGUINS_SPAWN_INTERVAL = 20,
                PENGUINS_DEFAULT_NUM_BOULDERS = 10,
            },
            always = {
                PENGUINS_MAX_COLONIES = 7,
                PENGUINS_MAX_COLONIES_BUFFER = 5,
                PENGUINS_SPAWN_INTERVAL = 10,
                PENGUINS_DEFAULT_NUM_BOULDERS = 14,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    penguins_moon = function(difficulty)
        local tuning_vars =
        {
            never = {
                SPAWN_MOON_PENGULLS = false,
            },
            --[[
            default = {
                SPAWN_MOON_PENGULLS = true,
            }
            --]]
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    bees_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                BEEHIVE_ENABLED = false,
                BEEBOX_ENABLED = false,
            },
            few = {
                BEEHIVE_BEES = 3,
                BEEHIVE_EMERGENCY_BEES = 4,
                BEEHIVE_RELEASE_TIME = TUNING.DAY_TIME_DEFAULT/3,
                BEEHIVE_REGEN_TIME = TUNING.SEG_TIME*2,
                BEEBOX_BEES = 2,
                BEEBOX_RELEASE_TIME = (0.5*TUNING.DAY_TIME_DEFAULT)/2,
                BEEBOX_REGEN_TIME = TUNING.SEG_TIME*6,
            },
            --[[
            default = {
                BEEHIVE_BEES = 5,
                BEEHIVE_EMERGENCY_BEES = 8,
                BEEHIVE_RELEASE_TIME = TUNING.DAY_TIME_DEFAULT/6,
                BEEHIVE_REGEN_TIME = TUNING.SEG_TIME,
                BEEBOX_BEES = 4,
                BEEBOX_RELEASE_TIME = (0.5*TUNING.DAY_TIME_DEFAULT)/4,
                BEEBOX_REGEN_TIME = TUNING.SEG_TIME*4,
                BEEHIVE_ENABLED = true,
                BEEBOX_ENABLED = true,
            },
            --]]
            many = {
                BEEHIVE_BEES = 8,
                BEEHIVE_EMERGENCY_BEES = 12,
                BEEHIVE_RELEASE_TIME = TUNING.DAY_TIME_DEFAULT/9,
                BEEHIVE_REGEN_TIME = TUNING.SEG_TIME/1.5,
                BEEBOX_BEES = 6,
                BEEBOX_RELEASE_TIME = (0.5*TUNING.DAY_TIME_DEFAULT)/6,
                BEEBOX_REGEN_TIME = TUNING.SEG_TIME*2,
            },
            always = {
                BEEHIVE_BEES = 12,
                BEEHIVE_EMERGENCY_BEES = 16,
                BEEHIVE_RELEASE_TIME = TUNING.DAY_TIME_DEFAULT/12,
                BEEHIVE_REGEN_TIME = TUNING.SEG_TIME/3,
                BEEBOX_BEES = 10,
                BEEBOX_RELEASE_TIME = (0.5*TUNING.DAY_TIME_DEFAULT)/10,
                BEEBOX_REGEN_TIME = TUNING.SEG_TIME,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    catcoons = function(difficulty)
        local tuning_vars =
        {
            never = {
                CATCOONDEN_ENABLED = false,
            },
            few = {
                CATCOONDEN_REGEN_TIME = TUNING.SEG_TIME*8,
                CATCOONDEN_MAXCHILDREN = 1,
            },
            --[[
            default = {
                CATCOONDEN_REGEN_TIME = TUNING.SEG_TIME*4,
                CATCOONDEN_MAXCHILDREN = 1,
                CATCOONDEN_ENABLED = true,
            },
            --]]
            many = {
                CATCOONDEN_REGEN_TIME = TUNING.SEG_TIME*2,
                CATCOONDEN_MAXCHILDREN = 1,
            },
            always = {
                CATCOONDEN_REGEN_TIME = TUNING.SEG_TIME*2,
                CATCOONDEN_MAXCHILDREN = 2,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    frogs = function(difficulty)
        local tuning_vars =
        {
            never = {
                FROG_POND_ENABLED = false,
            },
            few = {
                FROG_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/1,
                FROG_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/2,
                FROG_POND_CHILDREN = {min = 2, max = 3},
            },
            --[[
            default = {
                FROG_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/2,
                FROG_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/4,
                FROG_POND_CHILDREN = {min = 3, max = 4},
                FROG_POND_ENABLED = true,
            },
            --]]
            many = {
                FROG_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/4,
                FROG_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/8,
                FROG_POND_CHILDREN = {min = 5, max = 7},
            },
            always = {
                FROG_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/6,
                FROG_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/12,
                FROG_POND_CHILDREN = {min = 8, max = 10},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    grassgekkos = function(difficulty)
        local tuning_vars =
        {
            never = {
                GRASSGEKKO_MORPH_CHANCE = 0,
                GRASSGEKKO_MORPH_ENABLED = false,
            },
            few = {
                GRASSGEKKO_MORPH_DELAY = TUNING.TOTAL_DAY_TIME * 40,
                GRASSGEKKO_MORPH_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 10,
                GRASSGEKKO_MORPH_CHANCE = 0.5 / 100,
            },
            --[[
            default = {
                GRASSGEKKO_MORPH_DELAY = TUNING.TOTAL_DAY_TIME * 25,
                GRASSGEKKO_MORPH_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 5,
                GRASSGEKKO_MORPH_CHANCE = 1 / 100,
                GRASSGEKKO_MORPH_ENABLED = true,
            },
            --]]
            many = {
                GRASSGEKKO_MORPH_DELAY = TUNING.TOTAL_DAY_TIME * 17.5,
                GRASSGEKKO_MORPH_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 2.5,
                GRASSGEKKO_MORPH_CHANCE = 2 / 100,
            },
            always = {
                GRASSGEKKO_MORPH_DELAY = TUNING.TOTAL_DAY_TIME * 10,
                GRASSGEKKO_MORPH_DELAY_VARIANCE = TUNING.TOTAL_DAY_TIME * 5,
                GRASSGEKKO_MORPH_CHANCE = 5 / 100,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    moles_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                MOLE_ENABLED = false,
            },
            few = {
                MOLE_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*6*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER
            },
            --[[
            default = {
                MOLE_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*4*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER
                MOLE_ENABLED = true,
            },
            --]]
            many = {
                MOLE_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*2*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER
            },
            always = {
                MOLE_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*1*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    mosquitos = function(difficulty)
        local tuning_vars =
        {
            never = {
                MOSQUITO_POND_ENABLED = false,
            },
            few = {
                MOSQUITO_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/1,
                MOSQUITO_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/2,
                MOSQUITO_POND_CHILDREN = {min = 2, max = 3},
            },
            --[[
            default = {
                MOSQUITO_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/2,
                MOSQUITO_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/4,
                MOSQUITO_POND_CHILDREN = {min = 3, max = 4},
                MOSQUITO_POND_ENABLED = true,
            },
            --]]
            many = {
                MOSQUITO_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/4,
                MOSQUITO_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/8,
                MOSQUITO_POND_CHILDREN = {min = 5, max = 7},
            },
            always = {
                MOSQUITO_POND_REGEN_TIME = TUNING.DAY_TIME_DEFAULT/6,
                MOSQUITO_POND_SPAWN_TIME = TUNING.DAY_TIME_DEFAULT/12,
                MOSQUITO_POND_CHILDREN = {min = 8, max = 10},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    rabbits_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                RABBIT_ENABLED = false,
            },
            few = {
                RABBIT_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*6*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER,
            },
            --[[
            default = {
                RABBIT_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*4*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER,
                RABBIT_ENABLED = true,
            },
            --]]
            many = {
                RABBIT_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*2*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER,
            },
            always = {
                RABBIT_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*1*TUNING.MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    wobsters = function(difficulty)
        local tuning_vars =
        {
            never = {
                WOBSTER_DEN_ENABLED = false,
            },
            few = {
                WOBSTER_DEN_REGEN_PERIOD = 6*TUNING.SEG_TIME,
                WOBSTER_DEN_SPAWN_PERIOD = 8*TUNING.SEG_TIME,
            },
            --[[
            default = {
                WOBSTER_DEN_REGEN_PERIOD = 3*TUNING.SEG_TIME,
                WOBSTER_DEN_SPAWN_PERIOD = 4*TUNING.SEG_TIME,
                WOBSTER_DEN_MAX_CHILDREN = 2,
                WOBSTER_DEN_ENABLED = true,
            },
            --]]
            many = {
                WOBSTER_DEN_REGEN_PERIOD = 1.5*TUNING.SEG_TIME,
                WOBSTER_DEN_SPAWN_PERIOD = 2*TUNING.SEG_TIME,
                WOBSTER_DEN_MAX_CHILDREN = 3,
            },
            always = {
                WOBSTER_DEN_REGEN_PERIOD = 1*TUNING.SEG_TIME,
                WOBSTER_DEN_SPAWN_PERIOD = 1*TUNING.SEG_TIME,
                WOBSTER_DEN_MAX_CHILDREN = 4,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    pigs_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                PIGHOUSE_ENABLED = false,
            },
            few = {
                PIGHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 6,
            },
            --[[
            default = {
                PIGHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 4,
                PIGHOUSE_ENABLED = true,
            },
            --]]
            many = {
                PIGHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 2,
            },
            always = {
                PIGHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 1,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    slurtles_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                SLURTLEHOLE_ENABLED = false,
            },
            few = {
                SLURTLEHOLE_REGEN_PERIOD = TUNING.SEG_TIME*8,
                SLURTLEHOLE_CHILDREN = {min = 1, max = 2},
            },
            --[[
            default = {
                SLURTLEHOLE_REGEN_PERIOD = TUNING.SEG_TIME*4,
                SLURTLEHOLE_CHILDREN = {min = 1, max = 2},
                SLURTLEHOLE_ENABLED = true,
            },
            --]]
            many = {
                SLURTLEHOLE_REGEN_PERIOD = TUNING.SEG_TIME*2,
                SLURTLEHOLE_CHILDREN = {min = 2, max = 4},
            },
            always = {
                SLURTLEHOLE_REGEN_PERIOD = TUNING.SEG_TIME*1,
                SLURTLEHOLE_CHILDREN = {min = 4, max = 6},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    snurtles = function(difficulty)
        local tuning_vars =
        {
            never = {
                SLURTLEHOLE_RARECHILD_CHANCE = 0.0,
            },
            few = {
                SLURTLEHOLE_RARECHILD_CHANCE = 0.05,
            },
            default = {
                SLURTLEHOLE_RARECHILD_CHANCE = 0.1,
            },
            many = {
                SLURTLEHOLE_RARECHILD_CHANCE = 0.25,
            },
            always = {
                SLURTLEHOLE_RARECHILD_CHANCE = 0.5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    bunnymen_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                RABBITHOUSE_ENABLED = false,
            },
            few = {
                RABBITHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 2,
            },
            --[[
            default = {
                RABBITHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME,
                RABBITHOUSE_ENABLED = true,
            },
            --]]
            many = {
                RABBITHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 0.75,
            },
            always = {
                RABBITHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 0.5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    rocky_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                ROCKYHERD_SPAWNER_DENSITY = 0,
            },
            few = {
                ROCKYHERD_SPAWNER_DENSITY = 3,
            },
            --[[
            default = {
                ROCKYHERD_SPAWNER_DENSITY = 6,
            },
            --]]
            many = {
                ROCKYHERD_SPAWNER_DENSITY = 9,
            },
            always = {
                ROCKYHERD_SPAWNER_DENSITY = 12,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    monkey_setting = function(difficulty)
        local tuning_vars =
        {
            never = {
                MONKEYBARREL_ENABLED = false,
            },
            few = {
                MONKEYBARREL_REGEN_PERIOD = TUNING.SEG_TIME*6,
                MONKEYBARREL_SPAWN_PERIOD = TUNING.SEG_TIME*2,
                MONKEYBARREL_CHILDREN = {min = 3, max = 4},
            },
            --[[
            default = {
                MONKEYBARREL_REGEN_PERIOD = TUNING.SEG_TIME*4,
                MONKEYBARREL_SPAWN_PERIOD = TUNING.SEG_TIME,
                MONKEYBARREL_CHILDREN = {min = 3, max = 4},
                MONKEYBARREL_ENABLED = true,
            },
            --]]
            many = {
                MONKEYBARREL_REGEN_PERIOD = TUNING.SEG_TIME*2,
                MONKEYBARREL_SPAWN_PERIOD = TUNING.SEG_TIME,
                MONKEYBARREL_CHILDREN = {min = 4, max = 6},
            },
            always = {
                MONKEYBARREL_REGEN_PERIOD = TUNING.SEG_TIME,
                MONKEYBARREL_SPAWN_PERIOD = TUNING.SEG_TIME*0.5,
                MONKEYBARREL_CHILDREN = {min = 6, max = 8},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    dustmoths = function(difficulty)
        local tuning_vars =
        {
            never = {
                DUSTMOTHDEN_ENABLED = false,
            },
            few = {
                DUSTMOTHDEN_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 15,
                DUSTMOTHDEN_RELEASE_TIME = TUNING.SEG_TIME * 2,
                DUSTMOTHDEN_MAX_CHILDREN = 1,
            },
            --[[
            default = {
                DUSTMOTHDEN_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 10,
                DUSTMOTHDEN_RELEASE_TIME = TUNING.SEG_TIME,
                DUSTMOTHDEN_MAX_CHILDREN = 1,
                DUSTMOTHDEN_ENABLED = true,
            },
            --]]
            many = {
                DUSTMOTHDEN_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 7.5,
                DUSTMOTHDEN_RELEASE_TIME = TUNING.SEG_TIME * 0.75,
                DUSTMOTHDEN_MAX_CHILDREN = 1,
            },
            always = {
                DUSTMOTHDEN_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 5,
                DUSTMOTHDEN_RELEASE_TIME = TUNING.SEG_TIME * 0.5,
                DUSTMOTHDEN_MAX_CHILDREN = 2,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    lightfliers = function(difficulty)
        local tuning_vars =
        {
            never = {
                LIGHTFLIER_FLOWER_REGROW_TIME = NEVER_TIME,
                LIGHTFLIER_FLOWER_PICKABLE = false,
            },
            few = {
                LIGHTFLIER_FLOWER_REGROW_TIME = TUNING.TOTAL_DAY_TIME * 18,
            },
            --[[
            default = {
                LIGHTFLIER_FLOWER_REGROW_TIME = TUNING.TOTAL_DAY_TIME * 12,
                LIGHTFLIER_FLOWER_PICKABLE = true,
            },
            --]]
            many = {
                LIGHTFLIER_FLOWER_REGROW_TIME = TUNING.TOTAL_DAY_TIME * 8,
            },
            always = {
                LIGHTFLIER_FLOWER_REGROW_TIME = TUNING.TOTAL_DAY_TIME * 4,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    gnarwail = function(difficulty)
        local tuning_vars =
        {
            never = {
                GNARWAIL_SPAWN_CHANCE = 0,
                GNARWAIL_TEST_RADIUS = 0,
            },
            few = {
                GNARWAIL_SPAWN_CHANCE = 0.0375,
                GNARWAIL_TEST_RADIUS = 150,
            },
            --[[
            default = {
                GNARWAIL_SPAWN_CHANCE = 0.075,
                GNARWAIL_TEST_RADIUS = 100,
            },
            --]]
            many = {
                GNARWAIL_SPAWN_CHANCE = 0.15,
                GNARWAIL_TEST_RADIUS = 75,
            },
            always = {
                GNARWAIL_SPAWN_CHANCE = 0.3,
                GNARWAIL_TEST_RADIUS = 50,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    fishschools = function(difficulty)
        local tuning_vars =
        {
            never = {
                SCHOOL_SPAWNER_FISH_OCEAN_PERCENT = 1.1,
            },
            few = {
                SCHOOL_SPAWN_DELAY = {min=1*TUNING.SEG_TIME, max=4*TUNING.SEG_TIME},
                SCHOOL_SPAWNER_FISH_CHECK_RADIUS = 60,
                SCHOOL_SPAWNER_FISH_OCEAN_PERCENT = 0.25,
                SCHOOL_SPAWNER_MAX_FISH = 3,
                SCHOOL_SPAWNER_BLOCKER_MOD = 1/6,
                SCHOOL_SPAWNER_BLOCKER_LIFETIME = TUNING.TOTAL_DAY_TIME * 2,
            },
            --[[
            default = {
                SCHOOL_SPAWN_DELAY = {min=0.5*TUNING.SEG_TIME, max=2*TUNING.SEG_TIME},
                SCHOOL_SPAWNER_FISH_CHECK_RADIUS = 30,
                SCHOOL_SPAWNER_FISH_OCEAN_PERCENT = 0.1,
                SCHOOL_SPAWNER_MAX_FISH = 5,
                SCHOOL_SPAWNER_BLOCKER_MOD = 1/3, -- 3 or more blockers will prevent spawning
                SCHOOL_SPAWNER_BLOCKER_LIFETIME = TUNING.TOTAL_DAY_TIME,
            },
            --]]
            many = {
                SCHOOL_SPAWN_DELAY = {min=0.25*TUNING.SEG_TIME, max=1*TUNING.SEG_TIME},
                SCHOOL_SPAWNER_FISH_CHECK_RADIUS = 20,
                SCHOOL_SPAWNER_FISH_OCEAN_PERCENT = 0.05,
                SCHOOL_SPAWNER_MAX_FISH = 10,
                SCHOOL_SPAWNER_BLOCKER_MOD = 1/2, -- 3 or more blockers will prevent spawning
                SCHOOL_SPAWNER_BLOCKER_LIFETIME = TUNING.TOTAL_DAY_TIME / 2,
            },
            always = {
                SCHOOL_SPAWN_DELAY = {min=0.125*TUNING.SEG_TIME, max=0.5*TUNING.SEG_TIME},
                SCHOOL_SPAWNER_FISH_CHECK_RADIUS = 10,
                SCHOOL_SPAWNER_FISH_OCEAN_PERCENT = 0.025,
                SCHOOL_SPAWNER_MAX_FISH = 15,
                SCHOOL_SPAWNER_BLOCKER_MOD = 1/1, -- 3 or more blockers will prevent spawning
                SCHOOL_SPAWNER_BLOCKER_LIFETIME = TUNING.TOTAL_DAY_TIME / 4,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    --resources
    regrowth = function(difficulty)
        local tuning_vars = {
            never = {
                REGROWTH_TIME_MULTIPLIER = 0,
            },
            veryslow = {
                REGROWTH_TIME_MULTIPLIER = 0.15,
            },
            slow = {
                REGROWTH_TIME_MULTIPLIER = 0.33,
            },
            --[[
            default = {
                REGROWTH_TIME_MULTIPLIER = 1,
            },
            --]]
            fast = {
                REGROWTH_TIME_MULTIPLIER = 3,
            },
            veryfast = {
                REGROWTH_TIME_MULTIPLIER = 7,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    flowers_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                FLOWER_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                FLOWER_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                FLOWER_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                FLOWER_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                FLOWER_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                FLOWER_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    flower_cave_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                FLOWER_CAVE_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                FLOWER_CAVE_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                FLOWER_CAVE_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                FLOWER_CAVE_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                FLOWER_CAVE_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                FLOWER_CAVE_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    lightflier_flower_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    evergreen_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                EVERGREEN_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                EVERGREEN_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                EVERGREEN_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                EVERGREEN_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                EVERGREEN_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                EVERGREEN_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    twiggytrees_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                TWIGGYTREE_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                TWIGGYTREE_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                TWIGGYTREE_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                TWIGGYTREE_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                TWIGGYTREE_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                TWIGGYTREE_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    deciduoustree_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                DECIDIOUS_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                DECIDIOUS_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                DECIDIOUS_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                DECIDIOUS_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                DECIDIOUS_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                DECIDIOUS_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    mushtree_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                MUSHTREE_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                MUSHTREE_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                MUSHTREE_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                MUSHTREE_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                MUSHTREE_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                MUSHTREE_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    moon_tree_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                MOONTREE_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                MOONTREE_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                MOONTREE_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                MOONTREE_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                MOONTREE_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                MOONTREE_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    mushtree_moon_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                MOONMUSHTREE_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                MOONMUSHTREE_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                MOONMUSHTREE_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                MOONMUSHTREE_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                MOONMUSHTREE_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                MOONMUSHTREE_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    carrots_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                CARROT_REGROWTH_TIME_MULT = 0,
            },
            veryslow = {
                CARROT_REGROWTH_TIME_MULT = 0.25,
            },
            slow = {
                CARROT_REGROWTH_TIME_MULT = 0.5,
            },
            --[[
            default = {
                CARROT_REGROWTH_TIME_MULT = 1,
            },
            --]]
            fast = {
                CARROT_REGROWTH_TIME_MULT = 1.5,
            },
            veryfast = {
                CARROT_REGROWTH_TIME_MULT = 3,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    saltstack_regrowth = function(difficulty)
        local tuning_vars =
        {
            never = {
                SALTSTACK_GROWTH_ENABLED = false,
            },
            veryslow = {
                SALTSTACK_GROWTH_FREQUENCY = TUNING.TOTAL_DAY_TIME*27,
                SALTSTACK_GROWTH_FREQUENCY_VARIANCE = TUNING.TOTAL_DAY_TIME*6,
            },
            slow = {
                SALTSTACK_GROWTH_FREQUENCY = TUNING.TOTAL_DAY_TIME*18,
                SALTSTACK_GROWTH_FREQUENCY_VARIANCE = TUNING.TOTAL_DAY_TIME*4,
            },
            --[[
            default = {
                SALTSTACK_GROWTH_FREQUENCY = TUNING.TOTAL_DAY_TIME*9,
                SALTSTACK_GROWTH_FREQUENCY_VARIANCE = TUNING.TOTAL_DAY_TIME*2,
                SALTSTACK_GROWTH_ENABLED = true,
            },
            --]]
            fast = {
                SALTSTACK_GROWTH_FREQUENCY = TUNING.TOTAL_DAY_TIME*5,
                SALTSTACK_GROWTH_FREQUENCY_VARIANCE = TUNING.TOTAL_DAY_TIME*1,
            },
            veryfast = {
                SALTSTACK_GROWTH_FREQUENCY = TUNING.TOTAL_DAY_TIME*2,
                SALTSTACK_GROWTH_FREQUENCY_VARIANCE = TUNING.TOTAL_DAY_TIME*0.5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    --misc
    frograin = function(difficulty)
        local tuning_vars =
        {
            never = {
                FROG_RAIN_CHANCE = -1,
                FROG_RAIN_LOCAL_MIN = 0,
                FROG_RAIN_LOCAL_MAX = 1,
            },
            rare = {
                FROG_RAIN_CHANCE = 0.08,
                FROG_RAIN_LOCAL_MIN = 3,
                FROG_RAIN_LOCAL_MAX = 20,
            },
            --[[
            default = {
                FROG_RAIN_CHANCE = 0.16,
                FROG_RAIN_LOCAL_MIN = 12,
                FROG_RAIN_LOCAL_MAX = 35,
            },
            --]]
            often = {
                FROG_RAIN_CHANCE = 0.33,
                FROG_RAIN_LOCAL_MIN = 23,
                FROG_RAIN_LOCAL_MAX = 40,
            },
            always = {
                FROG_RAIN_CHANCE = 0.5,
                FROG_RAIN_LOCAL_MIN = 30,
                FROG_RAIN_LOCAL_MAX = 50,
            },
            force = {
                FROG_RAIN_CHANCE = 1,
                FROG_RAIN_LOCAL_MIN = 30,
                FROG_RAIN_LOCAL_MAX = 50,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
	end,
	earthquakes = function(difficulty)
        local tuning_vars =
        {
            never = {
                QUAKE_FREQUENCY_MULTIPLIER = -1,
            },
            rare = {
                QUAKE_FREQUENCY_MULTIPLIER = 0.3,
            },
            --[[
            default = {
                QUAKE_FREQUENCY_MULTIPLIER = 1,
        },
            --]]
            often = {
                QUAKE_FREQUENCY_MULTIPLIER = 3,
            },
            always = {
                QUAKE_FREQUENCY_MULTIPLIER = 10,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
	wildfires = function(difficulty)
        local tuning_vars =
        {
            never = {
                WILDFIRE_CHANCE = -1,
            },
            rare = {
                WILDFIRE_CHANCE = 0.1,
            },
            --[[
            default = {
                WILDFIRE_CHANCE = 0.2,
            },
            --]]
            often = {
                WILDFIRE_CHANCE = 0.4,
            },
            always = {
                WILDFIRE_CHANCE = 0.8,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
	end,
    petrification = function(difficulty)
        local tuning_vars =
        {
            none = {
                PETRIFICATION_CYCLE = {MIN_YEARS = 0, MAX_YEARS = 0},
            },
            few = {
                PETRIFICATION_CYCLE = {MIN_YEARS = 0.9, MAX_YEARS = 1.2},
            },
            --[[
            default = {
                PETRIFICATION_CYCLE = {MIN_YEARS = 0.6, MAX_YEARS = 0.9},
            },
            --]]
            many = {
                PETRIFICATION_CYCLE = {MIN_YEARS = 0.4, MAX_YEARS = 0.6},
            },
            max = {
                PETRIFICATION_CYCLE = {MIN_YEARS = 0.2, MAX_YEARS = 0.4},
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    meteorshowers = function(difficulty)
        local tuning_vars =
        {
            never = {
                METEOR_SHOWER_LVL1_BASETIME = 0,
                METEOR_SHOWER_LVL1_VARTIME = 0,
                METEOR_SHOWER_LVL2_BASETIME = 0,
                METEOR_SHOWER_LVL2_VARTIME = 0,
                METEOR_SHOWER_LVL3_BASETIME = 0,
                METEOR_SHOWER_LVL3_VARTIME = 0,

                METEOR_SHOWER_LVL1_DURATION_BASE = 0,
                METEOR_SHOWER_LVL1_DURATIONVAR_MIN = 0,
                METEOR_SHOWER_LVL1_DURATIONVAR_MAX = 0,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MIN = 0,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MAX = 0,
                METEOR_SHOWER_LVL1_MEDMETEORS_MIN = 0,
                METEOR_SHOWER_LVL1_MEDMETEORS_MAX = 0,
                METEOR_SHOWER_LVL1_LRGMETEORS_MIN = 0,
                METEOR_SHOWER_LVL1_LRGMETEORS_MAX = 0,

                METEOR_SHOWER_LVL2_DURATION_BASE = 0,
                METEOR_SHOWER_LVL2_DURATIONVAR_MIN = 0,
                METEOR_SHOWER_LVL2_DURATIONVAR_MAX = 0,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MIN = 0,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MAX = 0,
                METEOR_SHOWER_LVL2_MEDMETEORS_MIN = 0,
                METEOR_SHOWER_LVL2_MEDMETEORS_MAX = 0,
                METEOR_SHOWER_LVL2_LRGMETEORS_MIN = 0,
                METEOR_SHOWER_LVL2_LRGMETEORS_MAX = 0,

                METEOR_SHOWER_LVL3_DURATION_BASE = 0,
                METEOR_SHOWER_LVL3_DURATIONVAR_MIN = 0,
                METEOR_SHOWER_LVL3_DURATIONVAR_MAX = 0,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MIN = 0,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MAX = 0,
                METEOR_SHOWER_LVL3_MEDMETEORS_MIN = 0,
                METEOR_SHOWER_LVL3_MEDMETEORS_MAX = 0,
                METEOR_SHOWER_LVL3_LRGMETEORS_MIN = 0,
                METEOR_SHOWER_LVL3_LRGMETEORS_MAX = 0,
            },
            rare = {
                METEOR_SHOWER_LVL1_BASETIME = TUNING.TOTAL_DAY_TIME*12,
                METEOR_SHOWER_LVL1_VARTIME = TUNING.TOTAL_DAY_TIME*8,
                METEOR_SHOWER_LVL2_BASETIME = TUNING.TOTAL_DAY_TIME*18,
                METEOR_SHOWER_LVL2_VARTIME = TUNING.TOTAL_DAY_TIME*12,
                METEOR_SHOWER_LVL3_BASETIME = TUNING.TOTAL_DAY_TIME*24,
                METEOR_SHOWER_LVL3_VARTIME = TUNING.TOTAL_DAY_TIME*16,

                METEOR_SHOWER_LVL1_DURATION_BASE = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MIN = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MAX = 10,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MIN = 2,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MAX = 4,
                METEOR_SHOWER_LVL1_MEDMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_MEDMETEORS_MAX = 3,
                METEOR_SHOWER_LVL1_LRGMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_LRGMETEORS_MAX = 4,

                METEOR_SHOWER_LVL2_DURATION_BASE = 5,
                METEOR_SHOWER_LVL2_DURATIONVAR_MIN = 10,
                METEOR_SHOWER_LVL2_DURATIONVAR_MAX = 20,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MIN = 3,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MAX = 7,
                METEOR_SHOWER_LVL2_MEDMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_MEDMETEORS_MAX = 4,
                METEOR_SHOWER_LVL2_LRGMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_LRGMETEORS_MAX = 7,

                METEOR_SHOWER_LVL3_DURATION_BASE = 5,
                METEOR_SHOWER_LVL3_DURATIONVAR_MIN = 15,
                METEOR_SHOWER_LVL3_DURATIONVAR_MAX = 30,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MIN = 4,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MAX = 10,
                METEOR_SHOWER_LVL3_MEDMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_MEDMETEORS_MAX = 6,
                METEOR_SHOWER_LVL3_LRGMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_LRGMETEORS_MAX = 10,
            },
            --[[
            default = {
                METEOR_SHOWER_LVL1_BASETIME = TUNING.TOTAL_DAY_TIME*6,
                METEOR_SHOWER_LVL1_VARTIME = TUNING.TOTAL_DAY_TIME*4,
                METEOR_SHOWER_LVL2_BASETIME = TUNING.TOTAL_DAY_TIME*9,
                METEOR_SHOWER_LVL2_VARTIME = TUNING.TOTAL_DAY_TIME*6,
                METEOR_SHOWER_LVL3_BASETIME = TUNING.TOTAL_DAY_TIME*12,
                METEOR_SHOWER_LVL3_VARTIME = TUNING.TOTAL_DAY_TIME*8,

                METEOR_SHOWER_LVL1_DURATION_BASE = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MIN = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MAX = 10,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MIN = 2,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MAX = 4,
                METEOR_SHOWER_LVL1_MEDMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_MEDMETEORS_MAX = 3,
                METEOR_SHOWER_LVL1_LRGMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_LRGMETEORS_MAX = 4,

                METEOR_SHOWER_LVL2_DURATION_BASE = 5,
                METEOR_SHOWER_LVL2_DURATIONVAR_MIN = 10,
                METEOR_SHOWER_LVL2_DURATIONVAR_MAX = 20,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MIN = 3,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MAX = 7,
                METEOR_SHOWER_LVL2_MEDMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_MEDMETEORS_MAX = 4,
                METEOR_SHOWER_LVL2_LRGMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_LRGMETEORS_MAX = 7,

                METEOR_SHOWER_LVL3_DURATION_BASE = 5,
                METEOR_SHOWER_LVL3_DURATIONVAR_MIN = 15,
                METEOR_SHOWER_LVL3_DURATIONVAR_MAX = 30,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MIN = 4,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MAX = 10,
                METEOR_SHOWER_LVL3_MEDMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_MEDMETEORS_MAX = 6,
                METEOR_SHOWER_LVL3_LRGMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_LRGMETEORS_MAX = 10,
            },
            --]]
            often = {
                METEOR_SHOWER_LVL1_BASETIME = TUNING.TOTAL_DAY_TIME*3,
                METEOR_SHOWER_LVL1_VARTIME = TUNING.TOTAL_DAY_TIME*2,
                METEOR_SHOWER_LVL2_BASETIME = TUNING.TOTAL_DAY_TIME*5,
                METEOR_SHOWER_LVL2_VARTIME = TUNING.TOTAL_DAY_TIME*3,
                METEOR_SHOWER_LVL3_BASETIME = TUNING.TOTAL_DAY_TIME*6,
                METEOR_SHOWER_LVL3_VARTIME = TUNING.TOTAL_DAY_TIME*4,

                METEOR_SHOWER_LVL1_DURATION_BASE = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MIN = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MAX = 10,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MIN = 2,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MAX = 4,
                METEOR_SHOWER_LVL1_MEDMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_MEDMETEORS_MAX = 3,
                METEOR_SHOWER_LVL1_LRGMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_LRGMETEORS_MAX = 4,

                METEOR_SHOWER_LVL2_DURATION_BASE = 5,
                METEOR_SHOWER_LVL2_DURATIONVAR_MIN = 10,
                METEOR_SHOWER_LVL2_DURATIONVAR_MAX = 20,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MIN = 3,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MAX = 7,
                METEOR_SHOWER_LVL2_MEDMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_MEDMETEORS_MAX = 4,
                METEOR_SHOWER_LVL2_LRGMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_LRGMETEORS_MAX = 7,

                METEOR_SHOWER_LVL3_DURATION_BASE = 5,
                METEOR_SHOWER_LVL3_DURATIONVAR_MIN = 15,
                METEOR_SHOWER_LVL3_DURATIONVAR_MAX = 30,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MIN = 4,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MAX = 10,
                METEOR_SHOWER_LVL3_MEDMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_MEDMETEORS_MAX = 6,
                METEOR_SHOWER_LVL3_LRGMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_LRGMETEORS_MAX = 10,
            },
            always = {
                METEOR_SHOWER_LVL1_BASETIME = TUNING.TOTAL_DAY_TIME*2,
                METEOR_SHOWER_LVL1_VARTIME = TUNING.TOTAL_DAY_TIME*1,
                METEOR_SHOWER_LVL2_BASETIME = TUNING.TOTAL_DAY_TIME*3,
                METEOR_SHOWER_LVL2_VARTIME = TUNING.TOTAL_DAY_TIME*2,
                METEOR_SHOWER_LVL3_BASETIME = TUNING.TOTAL_DAY_TIME*4,
                METEOR_SHOWER_LVL3_VARTIME = TUNING.TOTAL_DAY_TIME*2,

                METEOR_SHOWER_LVL1_DURATION_BASE = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MIN = 5,
                METEOR_SHOWER_LVL1_DURATIONVAR_MAX = 10,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MIN = 2,
                METEOR_SHOWER_LVL1_METEORSPERSEC_MAX = 4,
                METEOR_SHOWER_LVL1_MEDMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_MEDMETEORS_MAX = 3,
                METEOR_SHOWER_LVL1_LRGMETEORS_MIN = 1,
                METEOR_SHOWER_LVL1_LRGMETEORS_MAX = 4,

                METEOR_SHOWER_LVL2_DURATION_BASE = 5,
                METEOR_SHOWER_LVL2_DURATIONVAR_MIN = 10,
                METEOR_SHOWER_LVL2_DURATIONVAR_MAX = 20,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MIN = 3,
                METEOR_SHOWER_LVL2_METEORSPERSEC_MAX = 7,
                METEOR_SHOWER_LVL2_MEDMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_MEDMETEORS_MAX = 4,
                METEOR_SHOWER_LVL2_LRGMETEORS_MIN = 2,
                METEOR_SHOWER_LVL2_LRGMETEORS_MAX = 7,

                METEOR_SHOWER_LVL3_DURATION_BASE = 5,
                METEOR_SHOWER_LVL3_DURATIONVAR_MIN = 15,
                METEOR_SHOWER_LVL3_DURATIONVAR_MAX = 30,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MIN = 4,
                METEOR_SHOWER_LVL3_METEORSPERSEC_MAX = 10,
                METEOR_SHOWER_LVL3_MEDMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_MEDMETEORS_MAX = 6,
                METEOR_SHOWER_LVL3_LRGMETEORS_MIN = 3,
                METEOR_SHOWER_LVL3_LRGMETEORS_MAX = 10,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    disease_delay = function(difficulty)
        local tuning_vars =
        {
            none = {
                DISEASE_DELAY_TIME = 0, DISEASE_DELAY_TIME_VARIANCE = 0
            },
            long = {
                DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 80,
                DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 20
            },
            --[[
            default = {
                DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 50,
                DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 20,
            },
            --]]
            short = {
                DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 35,
                DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 15
            },
            random = {
                DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 50,
                DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 40
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    atriumgate = function(difficulty)
        local tuning_vars =
        {
            veryslow = {
                ATRIUM_GATE_COOLDOWN = TUNING.TOTAL_DAY_TIME * 40,
            },
            slow = {
                ATRIUM_GATE_COOLDOWN = TUNING.TOTAL_DAY_TIME * 30,
            },
            --[[
            default = {
                ATRIUM_GATE_COOLDOWN = TUNING.TOTAL_DAY_TIME * 20,
            },
            --]]
            fast = {
                ATRIUM_GATE_COOLDOWN = TUNING.TOTAL_DAY_TIME * 10,
            },
            veryfast = {
                ATRIUM_GATE_COOLDOWN = TUNING.TOTAL_DAY_TIME * 5,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    --survivors
	extrastartingitems = function(difficulty)
		if difficulty == "none" then
	        OverrideTuningVariables({EXTRA_STARTING_ITEMS = {}})
        elseif difficulty == "default" then
            --[[
            OverrideTuningVariables({EXTRA_STARTING_ITEMS_MIN_DAYS = 10})
            --]]
        else
			local min_days = tonumber(difficulty)
			if min_days ~= nil then
		        OverrideTuningVariables({EXTRA_STARTING_ITEMS_MIN_DAYS = min_days})
			end
		end
	end,
    seasonalstartingitems = function(difficulty)
        local tuning_vars =
        {
            none = {
                SEASONAL_STARTING_ITEMS = {}
            }
            --[[
            default = {
                SEASONAL_STARTING_ITEMS =
                {
                    autumn = { },
                    winter = { "earmuffshat" },
                    spring = { "strawhat" },
                    summer = { "grass_umbrella" },
                },
            }
            --]]
        }
        OverrideTuningVariables(tuning_vars[difficulty])
	end,
    dropeverythingondespawn = function(difficulty)
        local tuning_vars =
        {
            --default = {
            --    DROP_EVERYTHING_ON_DESPAWN = false
            --}
            always = {
                DROP_EVERYTHING_ON_DESPAWN = true
            }
        }
        OverrideTuningVariables(tuning_vars[difficulty])
	end,
    shadowcreatures = function(difficulty)
        local tuning_vars =
        {
            never = {
                SANITYMONSTERS_INDUCED_MAXPOP = 0,
                SANITYMONSTERS_MAXPOP = {0, 0},
            },
            few = {
                SANITYMONSTERS_INDUCED_MAXPOP = 3,
                SANITYMONSTERS_INDUCED_CHANCES = {
                    inc = 0.35,
                    dec = 0.5,
                },
                SANITYMONSTERS_MAXPOP = {0, 1},
                SANITYMONSTERS_CHANCES = {
                    {
                        inc = 0,
                        dec = 0,
                    },
                    {
                        inc = 0.2,
                        dec = 0.3,
                    },
                },
                SANITYMONSTERS_POP_CHANGE_INTERVAL = 20,
                SANITYMONSTERS_POP_CHANGE_VARIANCE = 20,
                SANITYMONSTERS_SPAWN_INTERVAL = 10,
                SANITYMONSTERS_SPAWN_VARIANCE = 20,
                TERRORBEAK_SPAWN_CHANCE = 0.33,
            },
            --[[
            default = {
                SANITYMONSTERS_INDUCED_MAXPOP = 5,
                SANITYMONSTERS_INDUCED_CHANCES = {
                    inc = 0.7,
                    dec = 0.4,
                },
                SANITYMONSTERS_MAXPOP = {1, 2},
                SANITYMONSTERS_CHANCES = {
                    {
                        inc = 0.1,
                        dec = 0.3,
                    },
                    {
                        inc = 0.3,
                        dec = 0.2,
                    },
                },
                SANITYMONSTERS_POP_CHANGE_INTERVAL = 10,
                SANITYMONSTERS_POP_CHANGE_VARIANCE = 10,
                SANITYMONSTERS_SPAWN_INTERVAL = 5,
                SANITYMONSTERS_SPAWN_VARIANCE = 10,
                TERRORBEAK_SPAWN_CHANCE = 0.5,
            },
            --]]
            many = {
                SANITYMONSTERS_INDUCED_MAXPOP = 7,
                SANITYMONSTERS_INDUCED_CHANCES = {
                    inc = 0.8,
                    dec = 0.3,
                },
                SANITYMONSTERS_MAXPOP = {2, 4},
                SANITYMONSTERS_CHANCES = {
                    {
                        inc = 0.2,
                        dec = 0.2,
                    },
                    {
                        inc = 0.4,
                        dec = 0.1,
                    },
                },
                SANITYMONSTERS_POP_CHANGE_INTERVAL = 5,
                SANITYMONSTERS_POP_CHANGE_VARIANCE = 5,
                SANITYMONSTERS_SPAWN_INTERVAL = 3,
                SANITYMONSTERS_SPAWN_VARIANCE = 5,
                TERRORBEAK_SPAWN_CHANCE = 0.75,
            },
            always = {
                SANITYMONSTERS_INDUCED_MAXPOP = 12,
                SANITYMONSTERS_INDUCED_CHANCES = {
                    inc = 1,
                    dec = 0,
                },
                SANITYMONSTERS_MAXPOP = {4, 8},
                SANITYMONSTERS_CHANCES = {
                    {
                        inc = 0.6,
                        dec = 0.01,
                    },
                    {
                        inc = 0.9,
                        dec = 0.005,
                    },
                },
                SANITYMONSTERS_POP_CHANGE_INTERVAL = 1,
                SANITYMONSTERS_POP_CHANGE_VARIANCE = 0,
                SANITYMONSTERS_SPAWN_INTERVAL = 1,
                SANITYMONSTERS_SPAWN_VARIANCE = 2,
                TERRORBEAK_SPAWN_CHANCE = 0.9,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
    brightmarecreatures = function(difficulty)
        local tuning_vars =
        {
            never = {
                GESTALT_MIN_SANITY_TO_SPAWN = math.huge,
            },
            few = {
                GESTALT_MIN_SANITY_TO_SPAWN = 0.5,

                GESTALT_POPULATION_LEVEL =
                {
                    {
                        MAX_SPAWNS = 1,
                        MAX_SANITY = 0.8,
                    },
                    {
                        MAX_SPAWNS = 2,
                        MAX_SANITY = math.huge,
                    },
                },

                GESTALT_POP_CHANGE_INTERVAL = 20,
                GESTALT_POP_CHANGE_VARIANCE = 4,
            },
            --[[
            default = {
                GESTALT_MIN_SANITY_TO_SPAWN = 0.25,

                GESTALT_POPULATION_LEVEL =
                {
                    {
                        MAX_SPAWNS = 2,
                        MAX_SANITY = 0.5,
                    },
                    {
                        MAX_SPAWNS = 3,
                        MAX_SANITY = 0.8,
                    },
                    {
                        MAX_SPAWNS = 4,
                        MAX_SANITY = math.huge,
                    },
                },

                GESTALT_POP_CHANGE_INTERVAL = 10,
                GESTALT_POP_CHANGE_VARIANCE = 2,
            },
            --]]
            many = {
                GESTALT_POPULATION_LEVEL =
                {
                    {
                        MAX_SPAWNS = 4,
                        MAX_SANITY = 0.5,
                    },
                    {
                        MAX_SPAWNS = 6,
                        MAX_SANITY = 0.8,
                    },
                    {
                        MAX_SPAWNS = 8,
                        MAX_SANITY = math.huge,
                    },
                },

                GESTALT_POP_CHANGE_INTERVAL = 5,
                GESTALT_POP_CHANGE_VARIANCE = 1,
            },
            always = {
                GESTALT_POPULATION_LEVEL =
                {
                    {
                        MAX_SPAWNS = 6,
                        MAX_SANITY = 0.5,
                    },
                    {
                        MAX_SPAWNS = 9,
                        MAX_SANITY = 0.8,
                    },
                    {
                        MAX_SPAWNS = 12,
                        MAX_SANITY = math.huge,
                    },
                },

                GESTALT_POP_CHANGE_INTERVAL = 2,
                GESTALT_POP_CHANGE_VARIANCE = 0,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    --global
    beefaloheat = function(difficulty)
        local tuning_vars =
        {
            never = {
                BEEFALO_MATING_ENABLED = false,
            },
            rare = {
                BEEFALO_MATING_SEASON_LENGTH = 2,
                BEEFALO_MATING_SEASON_WAIT = 18,
            },
            --[[
            default = {
                BEEFALO_MATING_SEASON_LENGTH = 3,
                BEEFALO_MATING_SEASON_WAIT = 20,
                BEEFALO_MATING_ENABLED = true,
                BEEFALO_MATING_ALWAYS = false,
            },
            --]]
            often = {
                BEEFALO_MATING_SEASON_LENGTH = 4,
                BEEFALO_MATING_SEASON_WAIT = 6,
            },
            always = {
                BEEFALO_MATING_ALWAYS = true,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
	krampus = function(difficulty)
        local tuning_vars =
        {
            never = {
                KRAMPUS_THRESHOLD = -1,
                KRAMPUS_THRESHOLD_VARIANCE = 0,
                KRAMPUS_INCREASE_LVL1 = -1,
                KRAMPUS_INCREASE_LVL2 = -1,
                KRAMPUS_INCREASE_RAMP = -1,
                KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 1,
            },
            rare = {
                KRAMPUS_THRESHOLD = 45,
                KRAMPUS_THRESHOLD_VARIANCE = 30,
                KRAMPUS_INCREASE_LVL1 = 75,
                KRAMPUS_INCREASE_LVL2 = 125,
                KRAMPUS_INCREASE_RAMP = 1,
                KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 30,
            },
            --[[
            default = {
                KRAMPUS_THRESHOLD = 30,
                KRAMPUS_THRESHOLD_VARIANCE = 20,
                KRAMPUS_INCREASE_LVL1 = 50,
                KRAMPUS_INCREASE_LVL2 = 100,
                KRAMPUS_INCREASE_RAMP = 2,
                KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 60,
            },
            --]]
            often = {
                KRAMPUS_THRESHOLD = 20,
                KRAMPUS_THRESHOLD_VARIANCE = 15,
                KRAMPUS_INCREASE_LVL1 = 37,
                KRAMPUS_INCREASE_LVL2 = 75,
                KRAMPUS_INCREASE_RAMP = 3,
                KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 90,
            },
            always = {
                KRAMPUS_THRESHOLD = 10,
                KRAMPUS_THRESHOLD_VARIANCE = 5,
                KRAMPUS_INCREASE_LVL1 = 25,
                KRAMPUS_INCREASE_LVL2 = 50,
                KRAMPUS_INCREASE_RAMP = 4,
                KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 120,
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,
}

local applyoverrides_post = {
    hounds = function(difficulty)
        if TheWorld:HasTag("forest") then
            TheWorld:PushEvent("hounded_setdifficulty", difficulty)
        end
    end,
    summerhounds = function(difficulty)
        if TheWorld:HasTag("forest") then
            TheWorld:PushEvent("hounded_setsummervariant", difficulty)
        end
    end,
    winterhounds = function(difficulty)
        if TheWorld:HasTag("forest") then
            TheWorld:PushEvent("hounded_setwintervariant", difficulty)
        end
    end,
    wormattacks = function(difficulty)
        if TheWorld:HasTag("cave") then
            TheWorld:PushEvent("hounded_setdifficulty", difficulty)
        end
    end,
	autumn = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "autumn", length = GetRandomItem(SEASON_FRIENDLY_LENGTHS), random = true})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "autumn", length = SEASON_FRIENDLY_LENGTHS[difficulty]})
		end
	end,

	winter = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "winter", length = GetRandomItem(SEASON_HARSH_LENGTHS), random = true})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "winter", length = SEASON_HARSH_LENGTHS[difficulty]})
		end
	end,

	spring = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "spring", length = GetRandomItem(SEASON_FRIENDLY_LENGTHS), random = true})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "spring", length = SEASON_FRIENDLY_LENGTHS[difficulty]})
		end
	end,

	summer = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "summer", length = GetRandomItem(SEASON_HARSH_LENGTHS), random = true})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "summer", length = SEASON_HARSH_LENGTHS[difficulty]})
		end
	end,
	day = function(difficulty)
		local lookup = {
			["onlyday"] = {
				day = 3, dusk = 0, night = 0
			},
			["onlydusk"] = {
				day = 0, dusk = 3, night = 0
			},
			["onlynight"] = {
				day = 0, dusk = 0, night = 3
			},
			["default"] = {
				day = 1, dusk = 1, night = 1
			},
			["longday"] = {
				day = 1.6, dusk = 0.7, night = 0.7
			},
			["longdusk"] = {
				day = 0.7, dusk = 1.6, night = 0.7
			},
			["longnight"] = {
				day = 0.7, dusk = 0.7, night = 1.6
			},
			["noday"] = {
				day = 0, dusk = 1.5, night = 1.5
			},
			["nodusk"] = {
				day = 1.5, dusk = 0, night = 1.5
			},
			["nonight"] = {
				day = 1.5, dusk = 1.5, night = 0
			}
		}
        TheWorld:PushEvent("ms_setseasonsegmodifier", lookup[difficulty])
    end,
    weather = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_setprecipitationmode", "never")
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_setprecipitationmode", "dynamic")
            TheWorld:PushEvent("ms_setmoisturescale", .5)
        elseif difficulty == "default" then
            TheWorld:PushEvent("ms_setprecipitationmode", "dynamic")
            TheWorld:PushEvent("ms_setmoisturescale", 1)
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_setprecipitationmode", "dynamic")
            TheWorld:PushEvent("ms_setmoisturescale", 2)
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_setprecipitationmode", "always")
        elseif difficulty == "squall" then
            TheWorld:PushEvent("ms_setprecipitationmode", "dynamic")
            TheWorld:PushEvent("ms_setmoisturescale", 30)
        end
    end,
    lightning = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_setlightningmode", "never")
            TheWorld:PushEvent("ms_setlightningdelay", {})
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_setlightningmode", "rain")
            TheWorld:PushEvent("ms_setlightningdelay", { min = 60, max = 90 })
        elseif difficulty == "default" then
            TheWorld:PushEvent("ms_setlightningmode", "rain")
            TheWorld:PushEvent("ms_setlightningdelay", {})
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_setlightningmode", "any")
            TheWorld:PushEvent("ms_setlightningdelay", { min = 10, max = 20 })
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_setlightningmode", "always")
            TheWorld:PushEvent("ms_setlightningdelay", { min = 10, max = 30 })
        end
    end,
}

local function areaambientdefault(prefab)
    local world = TheWorld
    if prefab == "cave" then
        -- Clear out the above ground (forest) sounds
        world:PushEvent("overrideambientsound", { tile = GROUND.ROAD, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.ROCKY, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.DIRT, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.WOODFLOOR, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.SAVANNA, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.GRASS, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.FOREST, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.CHECKER, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.MARSH, override = "SINKHOLE" })
        world:PushEvent("overrideambientsound", { tile = GROUND.IMPASSABLE, override = "ABYSS" })
    else
        -- Clear out the cave sounds
        world:PushEvent("overrideambientsound", { tile = GROUND.CAVE, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.FUNGUSRED, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.FUNGUSGREEN, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.FUNGUS, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.SINKHOLE, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.UNDERROCK, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.MUD, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.UNDERGROUND, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.BRICK, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.BRICK_GLOW, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.TILES, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.TILES_GLOW, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.TRIM, override = "ROCKY" })
        world:PushEvent("overrideambientsound", { tile = GROUND.TRIM_GLOW, override = "ROCKY" })
    end
end

return {Pre = applyoverrides_pre, Post = applyoverrides_post, areaambientdefault = areaambientdefault}
