
local function OverrideTuningVariables(tuning)
    if tuning ~= nil then
        for k, v in pairs(tuning) do
            TUNING[k] = v
        end
    end
end

local SPAWN_MODE_FN =
{
    never = "SpawnModeNever",
    always = "SpawnModeHeavy",
    often = "SpawnModeMed",
    rare = "SpawnModeLight",
}

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

local function SetSpawnMode(spawner, difficulty)
    if spawner ~= nil then
        spawner[SPAWN_MODE_FN[difficulty]](spawner)
    end
end

return
{
    hounds = function(difficulty)
        SetSpawnMode(TheWorld.components.hounded, difficulty)
    end,

    wormattacks = function(difficulty)
		if TheWorld:HasTag("cave") then
	        SetSpawnMode(TheWorld.components.hounded, difficulty)
	    end
    end,

    deerclops = function(difficulty)
        local deerclopsspawner = TheWorld.components.deerclopsspawner
        if deerclopsspawner then
            if difficulty == "never" then
                deerclopsspawner:OverrideAttacksPerSeason("DEERCLOPS", 0)
                deerclopsspawner:OverrideAttackDuringOffSeason("DEERCLOPS", false)
            elseif difficulty == "rare" then
                deerclopsspawner:OverrideAttacksPerSeason("DEERCLOPS", 2)
                deerclopsspawner:OverrideAttackDuringOffSeason("DEERCLOPS", false)
            elseif difficulty == "default" then
				-- Defaults specified in deerclopsspawner.lua
            elseif difficulty == "often" then
                deerclopsspawner:OverrideAttacksPerSeason("DEERCLOPS", 8)
                deerclopsspawner:OverrideAttackDuringOffSeason("DEERCLOPS", false)
            elseif difficulty == "always" then
                deerclopsspawner:OverrideAttacksPerSeason("DEERCLOPS", 10)
                deerclopsspawner:OverrideAttackDuringOffSeason("DEERCLOPS", true)
            end
        end
    end,

    bearger = function(difficulty)
        local beargerspawner = TheWorld.components.beargerspawner
        if beargerspawner then
            if difficulty == "never" then
	            -- no beargers    
	            beargerspawner:SetFirstBeargerChance(0)
	            beargerspawner:SetSecondBeargerChance(0)
            elseif difficulty == "rare" then
            	-- 50% chance of bearger (Should he have a chance of despawning?)
            	 beargerspawner:SetFirstBeargerChance(.5)
	            beargerspawner:SetSecondBeargerChance(0)
            elseif difficulty == "default" then 
            	-- spawn 1 bearger
            elseif difficulty == "often" then
            	-- 1 bearger
            	-- 50% chance of spawning a second bearger
            	 beargerspawner:SetFirstBeargerChance(1)
	            beargerspawner:SetSecondBeargerChance(.5)
            elseif difficulty == "always" then
            	-- 2 beargers
            	 beargerspawner:SetFirstBeargerChance(1)
	            beargerspawner:SetSecondBeargerChance(1)
            end
        end
    end,

    goosemoose = function(difficulty)
        local moosespawner = TheWorld.components.moosespawner
        if moosespawner then
            if difficulty == "never" then
                moosespawner:OverrideAttackDensity(0)
            elseif difficulty == "rare" then
                moosespawner:OverrideAttackDensity(0.25)
            elseif difficulty == "often" then
                moosespawner:OverrideAttackDensity(0.75)
            elseif difficulty == "always" then
                moosespawner:OverrideAttackDensity(1)
            end
        end
    end,

    dragonfly = function(difficulty)

        local tuning_vars =
        {
            never =     {DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 9999, DRAGONFLY_SPAWN_TIME = TUNING.TOTAL_DAY_TIME * 9999},
            rare =      {DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 40},
            often =     {DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 10},
            always =    {DRAGONFLY_RESPAWN_TIME = TUNING.TOTAL_DAY_TIME * 5},
        }

        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    antliontribute = function(difficulty)
        local tuning_vars =
        {
            never =  {ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 999, ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 999},
            rare =   {ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 7.2, ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 10, ANTLION_TRIBUTE_TO_RAGE_TIME = TUNING.TOTAL_DAY_TIME * .5},
            often =  {ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 4, ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 5},
            always = {ANTLION_RAGE_TIME_INITIAL = TUNING.TOTAL_DAY_TIME * 3.2, ANTLION_RAGE_TIME_MAX = TUNING.TOTAL_DAY_TIME * 4.5, ANTLION_RAGE_TIME_FAILURE_SCALE = 0.7},
        }

        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    disease_delay = function(difficulty)
    
        local tuning_vars = {
            none      = { DISEASE_DELAY_TIME = 0, DISEASE_DELAY_TIME_VARIANCE = 0 },                                                   -- disabled
            random    = { DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 50, DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 40 }, -- from 10 days to 5 seasons
            long      = { DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 80, DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 20 }, -- around 5 to 6 seasons
            default   = { },                                                                                                           -- around 2 seasons to 4 seasons
            short     = { DISEASE_DELAY_TIME = TUNING.TOTAL_DAY_TIME * 35, DISEASE_DELAY_TIME_VARIANCE = TUNING.TOTAL_DAY_TIME * 15 }, -- around 1 seasons to 3 seasons
        }

        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    perd = function(difficulty)
        local tuning_vars =
        {
            never = { PERD_SPAWNCHANCE = 0, PERD_ATTACK_PERIOD = 1 },
            rare = { PERD_SPAWNCHANCE = .1, PERD_ATTACK_PERIOD = 1 },
            often = { PERD_SPAWNCHANCE = .2, PERD_ATTACK_PERIOD = 1 },
            always = { PERD_SPAWNCHANCE = .4, PERD_ATTACK_PERIOD = 1 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    hunt = function(difficulty)
        local tuning_vars =
        {
            never = { HUNT_COOLDOWN = -1, HUNT_COOLDOWNDEVIATION = 0, HUNT_RESET_TIME = 0, HUNT_SPRING_RESET_TIME = -1 },
            rare = { HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * 2.4, HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * .3, HUNT_RESET_TIME = 5, HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 5 },
            often = { HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * .6, HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * .3, HUNT_RESET_TIME = 5, HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 2 },
            always = { HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * .3, HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * .2, HUNT_RESET_TIME = 5, HUNT_SPRING_RESET_TIME = TUNING.TOTAL_DAY_TIME * 1 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    alternatehunt = function(difficulty)
        local tuning_vars =
        {
            never = { HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0, HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0 },
            rare = { HUNT_ALTERNATE_BEAST_CHANCE_MIN = TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MIN * 0.25, HUNT_ALTERNATE_BEAST_CHANCE_MAX = TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MAX * 0.25 },
            often = { HUNT_ALTERNATE_BEAST_CHANCE_MIN = TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MIN * 2, HUNT_ALTERNATE_BEAST_CHANCE_MAX = TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MAX * 2 },
            always = { HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.7, HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.9 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

	deciduousmonster = function(difficulty)
		local tuning_vars =
		{
			never =  {DECID_MONSTER_MIN_DAY = 9999, DECID_MONSTER_SPAWN_CHANCE_BASE = -1, DECID_MONSTER_SPAWN_CHANCE_LOW = -1, DECID_MONSTER_SPAWN_CHANCE_MED = -1, DECID_MONSTER_SPAWN_CHANCE_HIGH = -1},
			rare = 	 {DECID_MONSTER_MIN_DAY = 5, DECID_MONSTER_SPAWN_CHANCE_BASE = .015, DECID_MONSTER_SPAWN_CHANCE_LOW = .04, DECID_MONSTER_SPAWN_CHANCE_MED = .075, DECID_MONSTER_SPAWN_CHANCE_HIGH = .167},
			often =  {DECID_MONSTER_MIN_DAY = 2, DECID_MONSTER_SPAWN_CHANCE_BASE = .07, DECID_MONSTER_SPAWN_CHANCE_LOW = .15, DECID_MONSTER_SPAWN_CHANCE_MED = .33, DECID_MONSTER_SPAWN_CHANCE_HIGH = .5},
			always = {DECID_MONSTER_MIN_DAY = 1, DECID_MONSTER_SPAWN_CHANCE_BASE = .2, DECID_MONSTER_SPAWN_CHANCE_LOW = .33, DECID_MONSTER_SPAWN_CHANCE_MED = .5, DECID_MONSTER_SPAWN_CHANCE_HIGH = .67},
		}
		OverrideTuningVariables(tuning_vars[difficulty])
	end,

	krampus = function(difficulty)
        local tuning_vars =
        {
            never = { KRAMPUS_THRESHOLD = -1, KRAMPUS_THRESHOLD_VARIATION = 0, KRAMPUS_INCREASE_LVL1 = -1, KRAMPUS_INCREASE_LVL2 = -1, KRAMPUS_INCREASE_RAMP = -1, KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 1 },
            rare = { KRAMPUS_THRESHOLD = 45, KRAMPUS_THRESHOLD_VARIATION = 30, KRAMPUS_INCREASE_LVL1 = 75, KRAMPUS_INCREASE_LVL2 = 125, KRAMPUS_INCREASE_RAMP = 1, KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 30 },
            often = { KRAMPUS_THRESHOLD = 20, KRAMPUS_THRESHOLD_VARIATION = 15, KRAMPUS_INCREASE_LVL1 = 37, KRAMPUS_INCREASE_LVL2 = 75, KRAMPUS_INCREASE_RAMP = 3, KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 90 },
            always = { KRAMPUS_THRESHOLD = 10, KRAMPUS_THRESHOLD_VARIATION = 5, KRAMPUS_INCREASE_LVL1 = 25, KRAMPUS_INCREASE_LVL2 = 50, KRAMPUS_INCREASE_RAMP = 4, KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 120 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    butterfly = function(difficulty)
        SetSpawnMode(TheWorld.components.butterflyspawner, difficulty)
    end,

    flowers = function(difficulty)
        local tuning_vars =
        {
            never = { FLOWER_REGROWTH_TIME_MULT = 0 },
            rare = { FLOWER_REGROWTH_TIME_MULT = .5 },
            often = { FLOWER_REGROWTH_TIME_MULT = 1.5 },
            always = { FLOWER_REGROWTH_TIME_MULT = 3 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    flower_cave = function(difficulty)
        local tuning_vars =
        {
            never = { FLOWER_CAVE_REGROWTH_TIME_MULT = 0 },
            rare = { FLOWER_CAVE_REGROWTH_TIME_MULT = .5 },
            often = { FLOWER_CAVE_REGROWTH_TIME_MULT = 1.5 },
            always = { FLOWER_CAVE_REGROWTH_TIME_MULT = 3 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    birds = function(difficulty)
        SetSpawnMode(TheWorld.components.birdspawner, difficulty)
    end,

    penguins = function(difficulty)
        SetSpawnMode(TheWorld.components.penguinspawner, difficulty)
    end,

    lureplants = function(difficulty)
        SetSpawnMode(TheWorld.components.lureplantspawner, difficulty)
    end,

    rock_ice = function(difficulty)
        local lookup = {
            never = 0,
            rare = 4,
            default = 7,
            always = 7,
            often = 7,
        }
        TheWorld:PushEvent("ms_setpenguinnumboulders", lookup[difficulty])
    end,

    beefaloheat = function(difficulty)
        local tuning_vars =
        {
            never = { BEEFALO_MATING_SEASON_LENGTH = 0, BEEFALO_MATING_SEASON_WAIT = -1 },
            rare = { BEEFALO_MATING_SEASON_LENGTH = 2, BEEFALO_MATING_SEASON_WAIT = 18 },
            often = { BEEFALO_MATING_SEASON_LENGTH = 4, BEEFALO_MATING_SEASON_WAIT = 6 },
            always = { BEEFALO_MATING_SEASON_LENGTH = -1, BEEFALO_MATING_SEASON_WAIT = 0 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    liefs = function(difficulty)
        local tuning_vars =
        {
            never = { LEIF_MIN_DAY = 9999, LEIF_PERCENT_CHANCE = 0 },
            rare = { LEIF_MIN_DAY = 5, LEIF_PERCENT_CHANCE = 1 / 100 },
            often = { LEIF_MIN_DAY = 2, LEIF_PERCENT_CHANCE = 1 / 70 },
            always = { LEIF_MIN_DAY = 1, LEIF_PERCENT_CHANCE = 1 / 55 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

	day = function(difficulty)
		local lookup = { 
			["onlyday"]={
				day = 3, dusk = 0, night = 0
			},
			["onlydusk"]={
				day = 0, dusk = 3, night = 0
			},
			["onlynight"]={
				day = 0, dusk = 0, night = 3
			},
			["default"]={
				day = 1, dusk = 1, night = 1
			},
			["longday"]={
				day = 1.6, dusk = 0.7, night = 0.7
			},
			["longdusk"]={
				day = 0.7, dusk = 1.6, night = 0.7
			},
			["longnight"]={
				day = 0.7, dusk = 0.7, night = 1.6
			},
			["noday"]={ 
				day = 0, dusk = 1.5, night = 1.5
			},
			["nodusk"]={
				day = 1.5, dusk = 0, night = 1.5
			},
			["nonight"]={
				day = 1.5, dusk = 1.5, night = 0
			}
		}
        TheWorld:PushEvent("ms_setseasonsegmodifier", lookup[difficulty])
    end,

	autumn = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "autumn", length = GetRandomItem(SEASON_FRIENDLY_LENGTHS)})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "autumn", length = SEASON_FRIENDLY_LENGTHS[difficulty]})
		end
	end,

	winter = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "winter", length = GetRandomItem(SEASON_HARSH_LENGTHS)})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "winter", length = SEASON_HARSH_LENGTHS[difficulty]})
		end
	end,

	spring = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "spring", length = GetRandomItem(SEASON_FRIENDLY_LENGTHS)})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "spring", length = SEASON_FRIENDLY_LENGTHS[difficulty]})
		end
	end,

	summer = function(difficulty)
		if difficulty == "random" then
			TheWorld:PushEvent("ms_setseasonlength", {season = "summer", length = GetRandomItem(SEASON_HARSH_LENGTHS)})
		else
			TheWorld:PushEvent("ms_setseasonlength", {season = "summer", length = SEASON_HARSH_LENGTHS[difficulty]})
		end
	end,

    season_start = function(difficulty)
        if difficulty == "random" then
            difficulty = GetRandomItem({"winter","spring","summer","autumn"})
        elseif difficulty == "autumnorspring" then
            difficulty = GetRandomItem({"spring","autumn"})
        elseif difficulty == "winterorsummer" then
            difficulty = GetRandomItem({"winter","summer"})
        end

        if difficulty == "winter" then
            TheWorld:PushEvent("ms_setstartseason", "winter")
            TheWorld:PushEvent("ms_setseason", "winter")
            TheWorld:PushEvent("ms_setsnowlevel", 1)
        elseif difficulty == "spring" then
            TheWorld:PushEvent("ms_setstartseason", "spring")
            TheWorld:PushEvent("ms_setseason", "spring")
            TheWorld:PushEvent("ms_setsnowlevel", 0)
        elseif difficulty == "summer" then
            TheWorld:PushEvent("ms_setstartseason", "summer")
            TheWorld:PushEvent("ms_setseason", "summer")
            TheWorld:PushEvent("ms_setsnowlevel", 0)
        else
            TheWorld:PushEvent("ms_setstartseason", "autumn")
            TheWorld:PushEvent("ms_setseason", "autumn")
            TheWorld:PushEvent("ms_setsnowlevel", 0)
        end
    end,

    weather = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_setprecipitationmode", "never")
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_setmoisturescale", .5)
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_setmoisturescale", 2)
        elseif difficulty == "squall" then
            TheWorld:PushEvent("ms_setmoisturescale", 30)
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_setprecipitationmode", "always")
        end
    end,

    lightning = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_setlightningmode", "never")
            TheWorld:PushEvent("ms_setlightningdelay", {})
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_setlightningmode", "rain")
            TheWorld:PushEvent("ms_setlightningdelay", { min = 60, max = 90 })
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_setlightningmode", "any")
            TheWorld:PushEvent("ms_setlightningdelay", { min = 10, max = 20 })
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_setlightningmode", "always")
            TheWorld:PushEvent("ms_setlightningdelay", { min = 10, max = 30 })
        end
    end,

	frograin = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_setfrograinchance", -1)
            TheWorld:PushEvent("ms_setfrograinlocalfrogs", {min=0,max=1})
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_setfrograinchance", .08)
            TheWorld:PushEvent("ms_setfrograinlocalfrogs", {min=3,max=20})
        elseif difficulty == "default" then
            TheWorld:PushEvent("ms_setfrograinchance", .16)
            TheWorld:PushEvent("ms_setfrograinlocalfrogs", {min=12,max=35})
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_setfrograinchance", .33)
            TheWorld:PushEvent("ms_setfrograinlocalfrogs", {min=23,max=40})
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_setfrograinchance", .50)
            TheWorld:PushEvent("ms_setfrograinlocalfrogs", {min=30,max=50})
        elseif difficulty == "force" then
            -- This preset can only be used by custom levels, not from the front-end settings
            TheWorld:PushEvent("ms_setfrograinchance", 1.0)
            TheWorld:PushEvent("ms_setfrograinlocalfrogs", {min=30,max=50})
        end
	end,

	wildfires = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_setwildfirechance", -1)
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_setwildfirechance", .1)
        elseif difficulty == "default" then
            TheWorld:PushEvent("ms_setwildfirechance", .2)
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_setwildfirechance", .4)
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_setwildfirechance", .8)
        end
	end,

	earthquakes = function(difficulty)
        if difficulty == "never" then
            TheWorld:PushEvent("ms_quakefrequencymultiplier", -1)
        elseif difficulty == "rare" then
            TheWorld:PushEvent("ms_quakefrequencymultiplier", 0.3)
        elseif difficulty == "default" then
            TheWorld:PushEvent("ms_quakefrequencymultiplier", 1)
        elseif difficulty == "often" then
            TheWorld:PushEvent("ms_quakefrequencymultiplier", 3)
        elseif difficulty == "always" then
            TheWorld:PushEvent("ms_quakefrequencymultiplier", 10)
        end
	end,

    creepyeyes = function(difficulty)
        local tuning_vars =
        {
            always =
            {
                CREEPY_EYES =
                {
                    { maxsanity = 1, maxeyes = 6 },
                },
            },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    areaambient = function(data)
        -- HACK HACK HACK
        local world = TheWorld
        world:PushEvent("overrideambientsound", { tile = GROUND.ROAD, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.ROAD, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.ROCKY, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.DIRT, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.WOODFLOOR, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.GRASS, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.SAVANNA, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.FOREST, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.MARSH, override = data })
        world:PushEvent("overrideambientsound", { tile = GROUND.IMPASSABLE, override = data })
    end,

    areaambientdefault = function(data)
        local world = TheWorld
        if data == "cave" then
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
    end,

    meteorshowers = function(difficulty)
        local tuning_vars =
        {
            never = 
            { 
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
            rare = 
            { 
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
            often = 
            { 
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
            always = 
            { 
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

    waves = function(data)
        if data == "off" and TheWorld.WaveComponent then
            TheWorld.WaveComponent:SetRegionNumWaves(0)
        end
    end,

    colourcube = function(data)
        TheWorld:PushEvent("overridecolourcube", "images/colour_cubes/"..data..".tex")
    end,

    regrowth = function(difficulty)
        local tuning_vars = {
            veryslow = { REGROWTH_TIME_MULTIPLIER = .15 },
            slow     = { REGROWTH_TIME_MULTIPLIER = .33 },
            default  = { REGROWTH_TIME_MULTIPLIER = 1 },
            fast     = { REGROWTH_TIME_MULTIPLIER = 3 },
            veryfast = { REGROWTH_TIME_MULTIPLIER = 7 },
        }
        OverrideTuningVariables(tuning_vars[difficulty])
    end,

    petrification = function(difficulty)
        local tuning_vars =
        {
            none = { PETRIFICATION_CYCLE = { MIN_YEARS = 0, MAX_YEARS = 0 } },
            few = { PETRIFICATION_CYCLE = { MIN_YEARS = .9, MAX_YEARS = 1.2 } },
            default = { PETRIFICATION_CYCLE = { MIN_YEARS = .6, MAX_YEARS = .9 } },
            many = { PETRIFICATION_CYCLE = { MIN_YEARS = .4, MAX_YEARS = .6 } },
            max = { PETRIFICATION_CYCLE = { MIN_YEARS = .2, MAX_YEARS = .4 } },
        }

        OverrideTuningVariables(tuning_vars[difficulty])
    end,
}
