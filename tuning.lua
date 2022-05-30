local TechTree = require("techtree")

TUNING = {}
TUNING_MODIFIERS = {}
ORIGINAL_TUNING = {}

function AddTuningModifier(tuning_var, fn, tuning_value)
    if not TUNING_MODIFIERS[tuning_var] then
        TUNING_MODIFIERS[tuning_var] = {fn, TUNING[tuning_var] or tuning_value}
        TUNING[tuning_var] = nil
    end
end

function Tune(overrides)
    if overrides == nil then
        overrides = {}
    end

    local seg_time = 30
    local total_day_time = seg_time*16

    local day_segs = 10
    local dusk_segs = 4
    local night_segs = 2

    --default day composition. changes in winter, etc
    local day_time = seg_time * day_segs
    local dusk_time = seg_time * dusk_segs
    local night_time = seg_time * night_segs

    local multiplayer_attack_modifier = 1--0.6--0.75
    local multiplayer_goldentool_modifier = 1--0.5--0.75
    local multiplayer_armor_durability_modifier = 0.7
    local multiplayer_armor_absorption_modifier = 1--0.75
    local multiplayer_wildlife_respawn_modifier = 1--2

    local wilson_attack = 34 * multiplayer_attack_modifier
    local wilson_health = 150
    local wilson_hunger = 150
    local wilson_sanity = 200
    local calories_per_day = 75

    local wilson_attack_period = 0.4 --prevents players

    -----------------------

    local perish_warp = 1--/200

    local OCEAN_NOISE_BASE_SCALE = 10
    local OCEAN_SPEED_BASE_SCALE = 0.01

    TUNING =
    {
        MAX_SERVER_SIZE = 6,
        DEMO_TIME = total_day_time * 2 + day_time*.2,
        AUTOSAVE_INTERVAL = total_day_time,
        SEG_TIME = seg_time,
        TOTAL_DAY_TIME = total_day_time,
        DAY_SEGS_DEFAULT = day_segs,
        DUSK_SEGS_DEFAULT = dusk_segs,
        NIGHT_SEGS_DEFAULT = night_segs,

        DAY_TIME_DEFAULT = day_time,
        DUSK_TIME_DEFAULT = dusk_time,
        NIGHT_TIME_DEFAULT = night_time,

        MULTIPLAYER_ATTACK_MODIFIER = multiplayer_attack_modifier,
        MULTIPLAYER_GOLDENTOOL_MODIFIER = multiplayer_goldentool_modifier,
        MULTIPLAYER_ARMOR_DURABILITY_MODIFIER = multiplayer_armor_durability_modifier,
        MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER = multiplayer_armor_absorption_modifier,
        MULTIPLAYER_WILDLIFE_RESPAWN_MODIFIER = multiplayer_wildlife_respawn_modifier,

        TOAST_FALLBACK_TIME = 1440,
        ITEM_DROP_TIME = seg_time, -- time to wait after start of night before activating

        STACK_SIZE_LARGEITEM = 10,
        STACK_SIZE_MEDITEM = 20,
        STACK_SIZE_SMALLITEM = 40,
		STACK_SIZE_TINYITEM = 60,

		OCEAN_WETNESS = 75, -- same as MAX_WETNESS in weather.lua

		DEFAULT_TALKER_DURATION = 2.5,
		MAX_TALKER_DURATION = 8.0,

        MAX_FIRE_DAMAGE_PER_SECOND = 120,

        GOLDENTOOLFACTOR = 4*multiplayer_goldentool_modifier,

		SEED_CHANCE_VERYCOMMON = 5,
		SEED_CHANCE_COMMON = 2.5,
		SEED_CHANCE_UNCOMMON = 1,
		SEED_CHANCE_RARE = 0.5,

		SEED_WEIGHT_SEASON_MOD = 2,
		FARM_PLANT_RANDOMSEED_WEED_CHANCE = 0.20,

        DARK_CUTOFF = 0,
        DARK_SPAWNCUTOFF = 0.1,

		DEFAULT_ATTACK_RANGE = 2,
		DEFAULT_HIT_RECOVERY = .75,

		DEFAULT_CHARACTER_HEALTH = wilson_health,

		BASE_SURVIVOR_ATTACK = wilson_attack,

        WILSON_HEALTH = wilson_health,
        WILSON_ATTACK_PERIOD = wilson_attack_period,
        WILSON_HUNGER = wilson_hunger, --stomach size
        WILSON_HUNGER_RATE = calories_per_day/total_day_time, --calories burnt per day
        WILSON_SANITY = wilson_sanity,

        -- WX78 Refresh: WX78 min and max health variables kept for backwards compatibility & mods
        WX78_MIN_HEALTH = 150,
        WX78_MIN_HUNGER = 150, -- 100 For pax we are increasing this.  Hungers out too easily.
        WX78_MIN_SANITY = 150,

        WX78_MAX_HEALTH = 400,
        WX78_MAX_HUNGER = 200,
        WX78_MAX_SANITY = 300,

        WX78_HEALTH = 125,
        WX78_HUNGER = 125,
        WX78_SANITY = 150,

        HAMMER_LOOT_PERCENT = .5,
        BURNT_HAMMER_LOOT_PERCENT = .25,
        AXE_USES = 100,
        HAMMER_USES = 75,
        SHOVEL_USES = 25,
        PITCHFORK_USES = 25,
        FARM_HOE_USES = 25,
        PICKAXE_USES = 33,
        BUGNET_USES = 10,
        WHIP_USES = 175,
        SPEAR_USES = 150,
        CLAW_GLOVE_USES = 200,
        WATHGRITHR_SPEAR_USES = 200,
        SPIKE_USES = 100,
        FISHINGROD_USES = 9,
        TRAP_USES = 8,
        BOOMERANG_USES = 10,
        BOOMERANG_DISTANCE = 12,
        NIGHTSWORD_USES = 100,
        ICESTAFF_USES = 20,
        FIRESTAFF_USES = 20,
        TELESTAFF_USES = 5,
        TELESTAFF_MOISTURE = 500,
        HAMBAT_USES = 100,
        BATBAT_USES = 75,
        MULTITOOL_AXE_PICKAXE_USES = 800,
        RUINS_BAT_USES = 200,
        SADDLEHORN_USES = 10,
        BRUSH_USES = 75,

        MULTITOOL_AXE_PICKAXE_EFFICIENCY = 4/3,

        JELLYBEAN_DURATION = total_day_time * .25,
        JELLYBEAN_TICK_RATE = 2,
        JELLYBEAN_TICK_VALUE = 2,

        REDAMULET_USES = 20,
        REDAMULET_CONVERSION = 5,

        BLUEAMULET_FUEL = total_day_time * 0.75,
        BLUEGEM_COOLER = -20,

        PURPLEAMULET_FUEL = total_day_time * 0.4,

        YELLOWAMULET_FUEL = total_day_time,
        YELLOWSTAFF_USES = 20,
        YELLOWSTAFF_STAR_DURATION = total_day_time * 3.5,

        OPALSTAFF_USES = 50,
        OPALSTAFF_STAR_DURATION = total_day_time * 2,

        ORANGEAMULET_USES = 225,
        ORANGEAMULET_RANGE = 4,
        ORANGEAMULET_ICD = 0.33,
        ORANGESTAFF_USES = 20,

        GREENAMULET_USES = 5,
        GREENAMULET_INGREDIENTMOD = 0.5,
        GREENSTAFF_USES = 5,

		POCKETSCALE_USES = 100,

        FISHING_MINWAIT = 2,
        FISHING_MAXWAIT = 20,

		OCEAN_FISHING =
		{
			MAX_CAST_DIST = 16,
			CAST_DIST_MIN_OFFSET = 0.8,
			CAST_DIST_MAX_OFFSET = 1.1,
			CAST_ANGLE_OFFSET = 20 / RADIANS,

			REEL_ACTION_REPEAT_DELAY = 0.300,

			REEL_STRENGTH_MIN = 2,
			REEL_STRENGTH_MAX = 3,
			REEL_SPEED_MAX = 4,
			REEL_ANGLE_VAR = 50,
			STOP_FISHING_HOOK_DIST = 2.5,
			FISHING_CATCH_DIST = 2.5,
			MUDBALL_CATCH_DIST = 2,


			MAX_HOOK_DIST = 26,

			LINE_TENSION_HIGH = 0.80, -- line tension is high if greater than this
			LINE_TENSION_GOOD = 0.10, -- line tension is good if greater than this
			-- LINE_TENSION_LOW would be "<= LINE_TENSION_GOOD"

			REELING_SNAP_TENSION = 0.92,
			UNSET_HOOK_TENSION = 0.0, -- should be less than LINE_TENSION_GOOD

			START_UNREELING_TENSION = 0.7,

			IDLE_QUOTE_TIME_MIN = 15,
			IDLE_QUOTE_TIME_VAR = 5,
		},

		OCEANFISHING_TACKLE =
		{
			-- max_angle_offset is +/-

			BASE				= {dist_max =  5, dist_min_accuracy = 0.70, dist_max_accuracy =  1.30, max_angle_offset =  40 },

			-- everything below here is in addition to BASE
			BOBBER_TWIG			= {dist_max =  2, dist_min_accuracy = 0.10, dist_max_accuracy = -0.10, max_angle_offset = -10 },
			BOBBER_BALL			= {dist_max =  4, dist_min_accuracy = 0.10, dist_max_accuracy = -0.10, max_angle_offset = -20 },
			BOBBER_OVAL			= {dist_max =  6, dist_min_accuracy = 0.10, dist_max_accuracy = -0.10, max_angle_offset = -20 },
			BOBBER_PLUG			= {dist_max =  8, dist_min_accuracy = 0.10, dist_max_accuracy = -0.10, max_angle_offset = -10 },
			BOBBER_LIGHTBULB	= {dist_max =  4, dist_min_accuracy = 0.10, dist_max_accuracy = -0.10, max_angle_offset = -20 },

			BOBBER_CROW			= {dist_max =  4, dist_min_accuracy = 0.15, dist_max_accuracy = -0.15, max_angle_offset = -25 },
			BOBBER_ROBIN		= {dist_max =  4, dist_min_accuracy = 0.15, dist_max_accuracy = -0.15, max_angle_offset = -25 },
			BOBBER_ROBIN_WINTER	= {dist_max =  4, dist_min_accuracy = 0.15, dist_max_accuracy = -0.15, max_angle_offset = -25 },
			BOBBER_CANARY		= {dist_max =  4, dist_min_accuracy = 0.15, dist_max_accuracy = -0.15, max_angle_offset = -25 },
			BOBBER_GOOSE		= {dist_max =  8, dist_min_accuracy = 0.25, dist_max_accuracy = -0.25, max_angle_offset = -35 },
			BOBBER_MALBATROSS	= {dist_max =  8, dist_min_accuracy = 0.25, dist_max_accuracy = -0.25, max_angle_offset = -35 },
		},

		OCEANFISHING_LURE =
		{
			-- radius = how far away the fish will start to be attracted to it
			-- charm = 0 to 1
			-- reel_charm = -1 to 1
			-- timeofday = {day = 1, dusk = 0.5, night = 0.5}
			-- style = spoon, spinnerbait, berry, seed, hook
			-- dist_max = added to the casting distance

			-- a basic hook, kind of shinny, maybe it can hook something if you are lucky
			HOOK				= { charm = 0.1, reel_charm =  0.0, radius = 1.0, style = "hook", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 0 },

			SPOILED_FOOD		= { charm = 0.1, reel_charm = -0.3, radius = 2.0, style = "rot", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 2 },

			SEED				= { charm = 0.2, reel_charm = -0.3, radius = 3.0, style = "seed", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1 },
			BERRY				= { charm = 0.3, reel_charm = -0.3, radius = 3.0, style = "berry", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1 },
            FIG                 = { charm = 0.5, reel_charm = -0.3, radius = 4.0, style = "berry", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1 },

			SPOON_DAY			= { charm = 0.2, reel_charm =  0.3, radius = 4.0, style = "spoon", timeofday = {day = 1.0, dusk = 0.3, night = 0.3}, dist_max = 1 },
			SPOON_DUSK			= { charm = 0.2, reel_charm =  0.3, radius = 4.0, style = "spoon", timeofday = {day = 0.3, dusk = 1.0, night = 0.3}, dist_max = 1 },
			SPOON_NIGHT			= { charm = 0.2, reel_charm =  0.3, radius = 4.0, style = "spoon", timeofday = {day = 0.3, dusk = 0.3, night = 1.0}, dist_max = 1 },
			SPOON_SPORK			= { charm = 0.2, reel_charm =  0.3, radius = 4.0, style = "spoon", timeofday = {day = 1.0, dusk = 1.0, night = 1.0}, dist_max = 1 },

			SPINNERBAIT_DAY		= { charm = 0.4, reel_charm =  0.4, radius = 5.0, style = "spinnerbait", timeofday = {day = 1.0, dusk = 0.3, night = 0.3}, dist_max = 2 },
			SPINNERBAIT_DUSK	= { charm = 0.4, reel_charm =  0.4, radius = 5.0, style = "spinnerbait", timeofday = {day = 0.3, dusk = 1.0, night = 0.3}, dist_max = 2 },
			SPINNERBAIT_NIGHT	= { charm = 0.4, reel_charm =  0.4, radius = 5.0, style = "spinnerbait", timeofday = {day = 0.3, dusk = 0.3, night = 1.0}, dist_max = 2 },

			SPECIAL_RAIN		= { charm = 0.3, reel_charm =  0.5, radius = 5.0, style = "special", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1, weather = {default = 0.0, raining = 1.0, snowing = 0.0} },
			SPECIAL_SNOW		= { charm = 0.3, reel_charm =  0.5, radius = 5.0, style = "special", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1, weather = {default = 0.0, raining = 0.0, snowing = 1.0} },
			SPECIAL_DROWSY		= { charm = 0.1, reel_charm =  0.3, radius = 3.0, style = "special", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1, stamina_drain = 1.0 },
			SPECIAL_HEAVY		= { charm = 0.5, reel_charm =  0.0, radius = 5.0, style = "special", timeofday = {day = 1, dusk = 1, night = 1}, dist_max = 1, },

			SPOON_WIP			= { charm = 0.2, reel_charm =  0.3, radius = 4.0, style = "spoon", timeofday = {day = 0.0, dusk = 0.0, night = 0.0} },
			SPINNERBAIT_WIP		= { charm = 0.2, reel_charm =  0.3, radius = 4.0, style = "spinnerbait", timeofday = {day = 0.0, dusk = 0.0, night = 0.0} },
		},

		OCEANFISHING_LURE_WEATHER_DEFAULT = {default = 1.0, raining = 0.5, snowing = 0.5},

		OCEANFISH_LURE_PREFERENCE =
		{
			SMALL_VEGGIE	= { hook = 0.25, special = 1.00, rot = 1.00, seed = 1.50, berry = 1.50, spoon = 0.00, spinnerbait = 0.00, insect = 0.00 },
			VEGGIE			= { hook = 0.25, special = 1.00, rot = 0.50, seed = 1.50, berry = 1.50, spoon = 0.50, spinnerbait = 0.00, insect = 0.00 },
			SMALL_OMNI		= { hook = 0.25, special = 1.00, rot = 1.00, seed = 1.00, berry = 1.00, spoon = 1.00, spinnerbait = 0.00, insect = 1.00 },
			OMNI			= { hook = 0.25, special = 1.00, rot = 0.50, seed = 0.25, berry = 1.00, spoon = 1.00, spinnerbait = 1.00, insect = 1.00 },
			SMALL_MEAT		= { hook = 0.25, special = 1.00, rot = 1.00, seed = 0.00, berry = 0.00, spoon = 1.00, spinnerbait = 0.00, insect = 1.00 },
			MEAT			= { hook = 0.25, special = 1.00, rot = 0.50, seed = 0.00, berry = 0.00, spoon = 1.00, spinnerbait = 1.00, insect = 1.00 },
            WOBSTER         = { hook = 0.25, special = 1.00, rot = 1.00, seed = 0.25, berry = 1.00, spoon = 1.00, spinnerbait = 1.00, insect = 1.00 },
            BERRY           = { hook = 0.25, special = 1.00, rot = 0.50, seed = 0.50, berry = 2.00, spoon = 0.50, spinnerbait = 0.00, insect = 0.00 },
		},

        OCEANFISH_MIN_INTEREST_TO_BITE = 0.2,
        OCEANFISH_SEE_CHUM_DIST = 16,

		WEIGHABLE_HEAVY_WEIGHT_PERCENT = 0.8, -- anything >= to this is "heavy" for its type of fish

        STAGEHAND_HITS_TO_GIVEUP = 86,
        ENDTABLE_FLOWER_WILTTIME = total_day_time * 10,
        ENDTABLE_LIGHT_UPDATE = seg_time * 0.75,

        RESEARCH_MACHINE_DIST = 4,

        UNARMED_DAMAGE = 10,
        NIGHTSWORD_DAMAGE = wilson_attack*2,
        -------
        BATBAT_DAMAGE = wilson_attack * 1.25,
        BATBAT_DRAIN = wilson_attack * 0.2,
        -------
        SPIKE_DAMAGE = wilson_attack*1.5,
        HAMBAT_DAMAGE = wilson_attack*1.75,
        HAMBAT_MIN_DAMAGE_MODIFIER = .5,
        SPEAR_DAMAGE = wilson_attack,
        CLAW_GLOVE_DAMAGE = wilson_attack*1.5,
        WATHGRITHR_SPEAR_DAMAGE = wilson_attack * 1.25,
        AXE_DAMAGE = wilson_attack*.8,
        PICK_DAMAGE = wilson_attack*.8,
        BOOMERANG_DAMAGE = wilson_attack*.8,
        TORCH_DAMAGE = wilson_attack*.5,
        HAMMER_DAMAGE = wilson_attack*.5,
        SHOVEL_DAMAGE = wilson_attack*.5,
        PITCHFORK_DAMAGE = wilson_attack*.5,
        FARM_HOE_DAMAGE = wilson_attack*.5,
        BUGNET_DAMAGE = wilson_attack*.125,
        WHIP_DAMAGE = wilson_attack*.8,
        BULLKELP_ROOT_DAMAGE = wilson_attack*.8,
        FISHINGROD_DAMAGE = wilson_attack*.125,
        UMBRELLA_DAMAGE = wilson_attack*.5,
        CANE_DAMAGE = wilson_attack*.5,
        MULTITOOL_DAMAGE = wilson_attack*1.25,
        RUINS_BAT_DAMAGE = wilson_attack * 1.75,
        NIGHTSTICK_DAMAGE = wilson_attack*.85, -- Due to the damage being electric, it will get multiplied by 1.5 against any mob
        MINIFAN_DAMAGE = wilson_attack*.5,
        SADDLEHORN_DAMAGE = wilson_attack*.5,
        BRUSH_DAMAGE = wilson_attack*.8,
        OAR_DAMAGE = wilson_attack*.5,

        SADDLE_BASIC_BONUS_DAMAGE = 0,
        SADDLE_WAR_BONUS_DAMAGE = 16,
        SADDLE_RACE_BONUS_DAMAGE = 0,

        SADDLE_BASIC_USES = 5,
        SADDLE_WAR_USES = 8,
        SADDLE_RACE_USES = 8,

        SADDLE_BASIC_SPEEDMULT = 1.4,
        SADDLE_WAR_SPEEDMULT = 1.25,
        SADDLE_RACE_SPEEDMULT = 1.55,

        CANE_SPEED_MULT = 1.25,
        PIGGYBACK_SPEED_MULT = 0.9,
        HEAVY_SPEED_MULT = 0.15,
		ICEHAT_SPEED_MULT = 0.9,
		RUINS_BAT_SPEED_MULT = 1.1,

        TORCH_ATTACK_IGNITE_PERCENT = 1,

        WHIP_RANGE = 2,
        WHIP_SUPERCRACK_RANGE = 14,
        WHIP_SUPERCRACK_EPIC_CHANCE = .05,
        WHIP_SUPERCRACK_MONSTER_CHANCE = .2,
        WHIP_SUPERCRACK_CREATURE_CHANCE = .25,

        BULLKELP_ROOT_RANGE = 2.0,
        BULLKELP_ROOT_USE = 0.02,
        BULLKELP_ROOT_USE_VAR = 0.02,

        SPRING_COMBAT_MOD = 1.33,

        PINNABLE_WEAR_OFF_TIME = 10,
        PINNABLE_ATTACK_WEAR_OFF = 2.0,
        PINNABLE_RECOVERY_LEEWAY = 1.5,

        PIG_DAMAGE = 33,
        PIG_HEALTH = 250,
        PIG_ATTACK_PERIOD = 3,
        PIG_TARGET_DIST = 16,
		PIG_MAX_STUN_LOCKS = 2,
        PIG_LOYALTY_MAXTIME = 2.5*total_day_time,
        PIG_LOYALTY_POLITENESS_MAXTIME_BONUS = .5*total_day_time,
        PIG_LOYALTY_PER_HUNGER = total_day_time/25,
        PIG_MIN_POOP_PERIOD = seg_time * .5,

        PIG_TOKEN_CHANCE = 0.01,
        PIG_TOKEN_CHANCE_YOTP = .5,
        PIG_MINIGAME_ARENA_RADIUS = 12,
        PIG_MINIGAME_REQUIRED_TIME = seg_time * 4,
		PIG_MINIGAME_SCORE_GREAT = 0.6,
		PIG_MINIGAME_SCORE_GOOD = 0.3,
		PIG_MINIGAME_SCORE_BAD = 0.1,

        PIG_FULL_LOYALTY_PERCENT = 0.9,

		MINIGAME_CROWD_DIST_MIN = 12,
		MINIGAME_CROWD_DIST_TARGET = 14,
		MINIGAME_CROWD_DIST_MAX = 20,

        SPIDER_LOYALTY_MAXTIME = 2.5*total_day_time,
        SPIDER_LOYALTY_PER_HUNGER = total_day_time/25,

        WEREPIG_DAMAGE = 40,
        WEREPIG_HEALTH = 350 * 1.5, -- harder for multiplayer
        WEREPIG_ATTACK_PERIOD = 2,

        PIG_GUARD_DAMAGE = 33,
        PIG_GUARD_HEALTH = 300 * 2, -- harder for multiplayer
        PIG_GUARD_ATTACK_PERIOD = 1.5,
        PIG_GUARD_TARGET_DIST = 8,
        PIG_GUARD_DEFEND_DIST = 20,

        PIG_RUN_SPEED = 5,
        PIG_WALK_SPEED = 3,

        WEREPIG_RUN_SPEED = 7,
        WEREPIG_WALK_SPEED = 3,

        PIG_ELITE_RUN_SPEED = 9,
        PIG_ELITE_WALK_SPEED = 3,
        PIG_ELITE_HIT_RECOVERY = 1,
        PROP_WEAPON_RANGE = .5,

        PIG_ELITE_FIGHTER_DESPAWN_TIME = 10,
        PIG_ELITE_FIGHTER_DAMAGE = 45,
        PIG_ELITE_FIGHTER_ATTACK_PERIOD = 0.5,

        --for pig king gold minigame
        --delay b4 pigs and players can pick up something recently knocked out of someone's inventory
        --players are faster
        --high is for stuff knocked out of the hand slot
        --low is for stuff knocked out of pockets
        KNOCKBACK_DROP_ITEM_HEIGHT_HIGH = 3,
        KNOCKBACK_DROP_ITEM_HEIGHT_LOW = 1,
        KNOCKBACK_DELAY_INTERACTION_HIGH = .6,
        KNOCKBACK_DELAY_INTERACTION_LOW = .45,
        KNOCKBACK_DELAY_PLAYER_INTERACTION_HIGH = .3,
        KNOCKBACK_DELAY_PLAYER_INTERACTION_LOW = .15,

        WILSON_WALK_SPEED = 4,
        WILSON_RUN_SPEED = 6,

		WILSON_EMBARK_SPEED_MIN = 4,
		WILSON_EMBARK_SPEED_MAX = 10,
		WILSON_EMBARK_SPEED_BOOST = 1.5,

		WILSON_HOP_DISTANCE_SHORT = 2.5,
		WILSON_HOP_DISTANCE = 4,
		WILSON_HOP_DISTANCE_FAR = 6,

        CRITTER_WALK_SPEED = 6,
        CRITTER_HUNGERTIME = total_day_time * 3.25,
        CRITTER_HUNGERTIME_MIN = total_day_time * 2,
        CRITTER_HUNGERTIME_MAX = total_day_time * 4.5,
        CRITTER_HUNGERTIME_DELTA = total_day_time * 0.5,
        CRITTER_EMOTE_DELAY = seg_time,
        CRITTER_NUZZLE_DELAY = total_day_time * 0.5,
        CRITTER_PLAYFUL_DELAY = seg_time * 0.4,
        CRITTER_COMBAT_LOOP_CHANCE = 0.33,
        CRITTER_WANTS_TO_BE_PET_TIME = seg_time * 0.5,

        CRITTER_TRAITS =
        {
            COMBAT          = {inc=0.003, decay=1.35},
            WELLFED         = {inc=0.70,  decay=.7},
            PLAYFUL         = {inc=0.32,  decay=.7},
            CRAFTY          = {inc=0.25,  decay=.9},
        },

        CRITTER_TRAIT_DECAY_DELAY = seg_time,
        CRITTER_TRAIT_INITIAL_DOMINANT_DELAY = total_day_time * 10,
        CRITTER_TRAIT_DOMINANT_DELAY = total_day_time * 4,
        CRITTER_TRAIT_DOMINANT_RETRY_DELAY = total_day_time * 2,
        CRITTER_TRAIT_DOMINANT_DELAY_VARIANCE = seg_time * 4,

        CRITTER_DOMINANTTRAIT_COMBAT_EMOTE_DELAY = seg_time * 0.25,
        CRITTER_DOMINANTTRAIT_COMBAT_LOOP_CHANCE = 0.75,
        CRITTER_DOMINANTTRAIT_PLAYFUL_EMOTE_DELAY = seg_time * 0.5,
        CRITTER_DOMINANTTRAIT_PLAYFUL_WITHOTHER_DELAY = seg_time * 0.1,
        CRITTER_DOMINANTTRAIT_HUNGERTIME_MIN = total_day_time * 3.25,
        CRITTER_DOMINANTTRAIT_HUNGERTIME_MAX = total_day_time * 5.5,

        PERD_SPAWNCHANCE = 0.1,
        PERD_DAMAGE = 20,
        PERD_HEALTH = 50,
        PERD_ATTACK_PERIOD = 3,
        PERD_RUN_SPEED = 8,
        PERD_WALK_SPEED = 3,

        WALRUS_DAMAGE = 33,
        WALRUS_HEALTH = 150 * 2, -- harder for multiplayer
        WALRUS_ATTACK_PERIOD = 3,
        WALRUS_ATTACK_DIST = 15,
        WALRUS_DART_RANGE = 25,
        WALRUS_MELEE_RANGE = 5,
        WALRUS_TARGET_DIST = 10,
        WALRUS_LOSETARGET_DIST = 30,
		WALRUS_MAX_STUN_LOCKS = 4,
        WALRUS_REGEN_PERIOD = total_day_time*2.5,
        WALRUS_REGEN_ENABLED = true,

        LITTLE_WALRUS_DAMAGE = 22,
        LITTLE_WALRUS_HEALTH = 100,
        LITTLE_WALRUS_ATTACK_PERIOD = 3 * 1.7,
        LITTLE_WALRUS_ATTACK_DIST = 15,

        PIPE_DART_DAMAGE = 100,
        YELLOW_DART_DAMAGE = 60,

        PENGUIN_DAMAGE = 33,
        PENGUIN_HEALTH = 150,
        PENGUIN_ATTACK_PERIOD = 3,
        PENGUIN_ATTACK_DIST = 2.5,
        PENGUIN_MATING_SEASON_LENGTH = 6,
        PENGUIN_MATING_SEASON_WAIT = 1,
        PENGUIN_MATING_SEASON_BABYDELAY = total_day_time*1.5,
        PENGUIN_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
        PENGUIN_TARGET_DIST = 15,
        PENGUIN_CHASE_DIST = 30,
        PENGUIN_FOLLOW_TIME = 10,
        PENGUIN_HUNGER = total_day_time * 12,  -- takes all winter to starve
        PENGUIN_STARVE_TIME = total_day_time * 12,
        PENGUIN_STARVE_KILL_TIME = 20,

        MUTATED_PENGUIN_DAMAGE = 20,
		MUTATED_PENGUIN_HEALTH = 100,

        KNIGHT_DAMAGE = 40,
        KNIGHT_HEALTH = 300 * 3, -- harder for multiplayer
        KNIGHT_ATTACK_PERIOD = 2,
        KNIGHT_WALK_SPEED = 5,
        KNIGHT_TARGET_DIST = 10,

        BISHOP_DAMAGE = 40,
        BISHOP_HEALTH = 300 * 3, -- harder for multiplayer
        BISHOP_ATTACK_PERIOD = 4,
        BISHOP_ATTACK_DIST = 6,
        BISHOP_WALK_SPEED = 5,
        BISHOP_TARGET_DIST = 12,

        ROOK_DAMAGE = 45,
        ROOK_HEALTH = 300 * 3, -- harder for multiplayer
        ROOK_ATTACK_PERIOD = 2,
        ROOK_WALK_SPEED = 5,
        ROOK_RUN_SPEED = 16,
        ROOK_TARGET_DIST = 12,

        MINOTAUR_DAMAGE = 100,
        MINOTAUR_HEALTH = 2500 * 4, -- harder for multiplayer
        MINOTAUR_ATTACK_PERIOD = 2,
        MINOTAUR_WALK_SPEED = 5,
        MINOTAUR_RUN_SPEED = 17,
        MINOTAUR_TARGET_DIST = 25,

        SLURTLE_DAMAGE = 25,
        SLURTLE_HEALTH = 600 * 2, -- harder for multiplayer
        SLURTLE_ATTACK_PERIOD = 4,
        SLURTLE_ATTACK_DIST = 2.5,
        SLURTLE_WALK_SPEED = 3,
        SLURTLE_TARGET_DIST = 10,
        SLURTLE_SHELL_ABSORB = 0.95,
        SLURTLE_DAMAGE_UNTIL_SHIELD = 150,

        SLURTLE_EXPLODE_DAMAGE = 300,
        SLURTLESLIME_EXPLODE_DAMAGE = 50,

        SNURTLE_WALK_SPEED = 4,
        SNURTLE_DAMAGE = 5,
        SNURTLE_HEALTH = 200,
        SNURTLE_SHELL_ABSORB = 0.8,
        SNURTLE_DAMAGE_UNTIL_SHIELD = 10,
        SNURTLE_EXPLODE_DAMAGE = 300,

        SLURPER_WALKSPEED = 9,
        SLURPER_HEALTH = 200,
        SLURPER_DAMAGE = 30,
        SLURPER_ATTACK_DIST = 8,
        SLURPER_ATTACK_PERIOD = 5,

        LIGHTNING_DAMAGE = 10,
		PLAYER_LIGHTNING_TARGET_CHANCE = 0.3,
		WX78_LIGHTNING_TARGET_CHANCE = 1.0,
		WES_LIGHTNING_TARGET_CHANCE = 0.6,

        ELECTRIC_WET_DAMAGE_MULT = 1,
        ELECTRIC_DAMAGE_MULT = 1.5,

        LIGHTNING_GOAT_DAMAGE = 25,
        LIGHTNING_GOAT_HEALTH = 350 * 2, -- harder for multiplayer
        LIGHTNING_GOAT_ATTACK_RANGE = 3,
        LIGHTNING_GOAT_ATTACK_PERIOD = 2,
        LIGHTNING_GOAT_WALK_SPEED = 4,
        LIGHTNING_GOAT_RUN_SPEED = 8,
        LIGHTNING_GOAT_TARGET_DIST = 8,
        LIGHTNING_GOAT_CHASE_DIST = 30,
        LIGHTNING_GOAT_FOLLOW_TIME = 30,
        LIGHTNING_GOAT_MATING_SEASON_BABYDELAY = total_day_time*1.5,
        LIGHTNING_GOAT_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,

		LIGHTNINGGOATHERD_MAX_SIZE = 6,

        DEER_DAMAGE = 25,
        DEER_HEALTH = 350 * 2, -- harder for multiplayer
        DEER_ATTACK_RANGE = 3,
        DEER_ATTACK_PERIOD = 2,
        DEER_ATTACKER_REMEMBER_DIST = 20,
        DEER_WALK_SPEED = 2.5,
        DEER_RUN_SPEED = 8,
		DEER_HIT_RECOVERY = 1,
		DEER_MAX_STUN_LOCKS = 4,

        DEER_HERD_MOVE_DIST = 10,

        DEER_GEMMED_DAMAGE = 50,
        DEER_GEMMED_HEALTH = 1500,
        DEER_GEMMED_AGGRO_DIST = 10,
        DEER_GEMMED_FIRST_CAST_CD = 4,
        DEER_GEMMED_CAST_RANGE = 12,
        DEER_GEMMED_CAST_MAX_RANGE = 15,
        DEER_GEMMED_MAX_SPELLS = 6,

        DEER_ICE_BURN_PANIC_TIME = 10,
        DEER_ICE_SPEED_PENALTY = .4,
        DEER_ICE_TEMPERATURE = -2,
        DEER_ICE_FATIGUE = .1,
        DEER_ICE_FREEZE_LOCK_FRAMES = 30,
        DEER_ICE_CAST_CD = 10,

        DEER_FIRE_FREEZE_WEAR_OFF_TIME = 5,
        DEER_FIRE_TEMPERATURE = 72, --must be higher than OVERHEAT_TEMP
        DEER_FIRE_IGNITE_FRAMES = 30,
        DEER_FIRE_CAST_CD = 8,

        KLAUS_HEALTH = 10000,
        KLAUS_HEALTH_REGEN = 25, --per second (only when not in combat)
        KLAUS_HEALTH_REZ = .5,
        KLAUS_DAMAGE = 75,
        KLAUS_ATTACK_PERIOD = 3,
        KLAUS_ATTACK_RANGE = 3,
        KLAUS_HIT_RANGE = 4,
        KLAUS_SPEED = 2.75,
        KLAUS_HIT_RECOVERY = 1,

        KLAUS_ENRAGE_SCALE = 1.4,

        KLAUS_NAUGHTY_MIN_SPAWNS = 2,
        KLAUS_NAUGHTY_MAX_SPAWNS = 6,

        KLAUS_COMMAND_CD = 6,

        KLAUS_CHOMP_CD = 6,
        KLAUS_CHOMP_MIN_RANGE = 4.5,
        KLAUS_CHOMP_RANGE = 7,
        KLAUS_CHOMP_MAX_RANGE = 9, --for scaling
        KLAUS_CHOMP_HIT_RANGE = 3.5,

        KLAUS_AGGRO_DIST = 15,
        KLAUS_DEAGGRO_DIST = 30,
        KLAUS_EPICSCARE_RANGE = 10,

        KLAUSSACK_EVENT_RESPAWN_TIME = total_day_time * 20, -- winters feast event respawn time
        KLAUSSACK_RESPAWN_DELAY = total_day_time * 10,
        KLAUSSACK_SPAWN_DELAY = total_day_time * 1,
        KLAUSSACK_SPAWN_DELAY_VARIANCE = total_day_time * 2,
        KLAUSSACK_MAX_SPAWNS = 1,
        SPAWN_KLAUS = true,

        BUZZARD_DAMAGE = 15,
        BUZZARD_ATTACK_RANGE = 2,
        BUZZARD_ATTACK_PERIOD = 2,
        BUZZARD_WALK_SPEED = 4,
        BUZZARD_RUN_SPEED = 8,
        BUZZARD_HEALTH = 125 * 2, -- harder for multiplayer

        BUZZARD_REGEN_PERIOD = total_day_time*3*multiplayer_wildlife_respawn_modifier,
        BUZZARD_SPAWN_PERIOD = seg_time*1.5,
        BUZZARD_SPAWN_VARIANCE = seg_time*0.5,

        FREEZING_KILL_TIME = 120,
        STARVE_KILL_TIME = 120,
        HUNGRY_THRESH = .333,
        GHOST_THRESH = .125,

        HUNGRY_BUILDER_DELTA = -5,
        HUNGRY_BUILDER_RESET_TIME = seg_time * 2,

        GRUEDAMAGE = wilson_health*.667,

        MARSHBUSH_DAMAGE = wilson_health*.02,
        CACTUS_DAMAGE = wilson_health*.04,
        ROSE_DAMAGE = 1,

        GHOST_SPEED = 2,
        GHOST_HEALTH = 200,
        GHOST_RADIUS = 1.5,
        GHOST_DAMAGE = wilson_health*0.1,
        GHOST_DMG_PERIOD = 1.2,
        GHOST_DMG_PLAYER_PERCENT = 1,
        GHOST_LIGHT_OVERRIDE = .5,
        GHOST_GRAVESTONE_CHANCE = 0.05,
        GHOST_FOLLOW_DSQ = 30 * 30, -- Used in ghost.lua and ghostbrain.lua
        GHOST_SISTURN_CHANCE_PER_DECOR = 0.05,

        MIN_LEAF_CHANGE_TIME = .1 * day_time,
        MAX_LEAF_CHANGE_TIME = 3 * day_time,
        MIN_SWAY_FX_FREQUENCY = 1 * seg_time,
        MAX_SWAY_FX_FREQUENCY = 2 * seg_time,
        SWAY_FX_FREQUENCY = 1 * seg_time,

        EVERGREEN_GROW_TIME =
        {
            {base=1.5*day_time, random=0.5*day_time},   --short
            {base=5*day_time, random=2*day_time},   --normal
            {base=5*day_time, random=2*day_time},   --tall
            {base=1*day_time, random=0.5*day_time}   --old
        },
        TWIGGY_TREE_GROW_TIME =
        {
            {base=1.5*day_time, random=0.5*day_time},   --short
            {base=3*day_time, random=1*day_time},   --normal
            {base=3*day_time, random=1*day_time},   --tall
            {base=5*day_time, random=0.5*day_time}   --old
        },
        PINECONE_GROWTIME = {base=0.75*day_time, random=0.25*day_time},
        EVERGREEN_CHOPS_SMALL = 5,
        EVERGREEN_CHOPS_NORMAL = 10,
        EVERGREEN_CHOPS_TALL = 15,

        DECIDUOUS_GROW_TIME =
        {
            {base=1.5*day_time, random=0.5*day_time},   --short
            {base=5*day_time, random=2*day_time},   --normal
            {base=5*day_time, random=2*day_time},   --tall
            {base=1*day_time, random=0.5*day_time}   --old
        },
        ACORN_GROWTIME = {base=0.75*day_time, random=0.25*day_time},
        DECIDUOUS_CHOPS_SMALL = 5,
        DECIDUOUS_CHOPS_NORMAL = 10,
        DECIDUOUS_CHOPS_TALL = 15,
        DECIDUOUS_CHOPS_MONSTER = 12 * 1.5, -- harder for multiplayer

        MUSHTREE_CHOPS_SMALL = 10,
        MUSHTREE_CHOPS_MEDIUM = 10,
        MUSHTREE_CHOPS_TALL = 15,
        MUSHTREE_WEBBED_SPIDER_RADIUS = 20,
        MUSHTREE_WEBBED_MAX_PER_DEN = 6,

        MUSHSPORE_PERISH_TIME = seg_time * 3,
        MUSHSPORE_MAX_DENSITY = 10,
        MUSHSPORE_MAX_DENSITY_RAD = 20,
        MUSHSPORE_DENSITY_CHECK_TIME = 15,
        MUSHSPORE_DENSITY_CHECK_VAR = 15,

        MUSHROOMHAT_SPORE_TIME = seg_time * 2,
        MUSHROOMHAT_SLOW_HUNGER = 0.75,

        MARBLESHRUB_MINE_SMALL = 6,  -- why are you even mining at this stage?
        MARBLESHRUB_MINE_NORMAL = 8, -- same as MARBLETREE_MINE
        MARBLESHRUB_MINE_TALL = 10,  -- same as MARBLEPILLAR_MINE
        MARBLESHRUB_GROW_TIME =
        {
            {base=9.0*day_time, random=1.0*day_time}, --short
            {base=9.0*day_time, random=1.0*day_time}, --normal
            {base=9.0*day_time, random=1.0*day_time}, --tall
        },

        ICE_MINE = 3,
        ROCKS_MINE = 6,
        ROCKS_MINE_MED = 4,
        ROCKS_MINE_LOW = 2,
        SPILAGMITE_SPAWNER = 2,
        SPILAGMITE_ROCK = 4,
        MARBLEPILLAR_MINE = 10,
        MARBLETREE_MINE = 8,
        CAVEIN_BOULDER_MINE = 3,
        SEASTACK_MINE = 9,
		SEACOCOON_MINE = 1,
		SHELL_CLUSTER_MINE = 3,

        PETRIFIED_TREE_SMALL = 2,
        PETRIFIED_TREE_NORMAL = 3,
        PETRIFIED_TREE_TALL = 4,
        PETRIFIED_TREE_OLD = 1,

        BEEFALO_HEALTH = 500 * 2, -- harder for multiplayer
        BEEFALO_HEALTH_REGEN_PERIOD = 10,
        BEEFALO_HEALTH_REGEN = (500*2)/(total_day_time*3)*10,
        BEEFALO_DAMAGE =
        {
            DEFAULT = 34,
            RIDER = 25,
            ORNERY = 50,
            PUDGY = 20,
        },
        BEEFALO_MATING_SEASON_LENGTH = 3,
        BEEFALO_MATING_SEASON_WAIT = 20,
        BEEFALO_MATING_ENABLED = true,
        BEEFALO_MATING_ALWAYS = false,
        BEEFALO_MATING_SEASON_BABYDELAY = total_day_time*1.5,
        BEEFALO_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
        BEEFALO_TARGET_DIST = 5,
        BEEFALO_CHASE_DIST = 30,
        BEEFALO_FOLLOW_TIME = 30,
        BEEFALO_HUNGER = (calories_per_day*4)/0.8, -- so a 0.8 fullness lasts a day
        BEEFALO_HUNGER_RATE = (calories_per_day*4)/total_day_time,
        BEEFALO_WALK_SPEED = 1.0,
        BEEFALO_RUN_SPEED =
        {
            DEFAULT = 7,
            RIDER = 8.0,
            ORNERY = 7.0,
            PUDGY = 6.5,
        },
        BEEFALO_HAIR_GROWTH_DAYS = 3,
        BEEFALO_BEARD_BITS = 3,
        BEEFALO_SADDLEABLE_OBEDIENCE = 0.1,
        BEEFALO_KEEP_SADDLE_OBEDIENCE = 0.4,
        BEEFALO_MIN_BUCK_OBEDIENCE = 0.5,
        BEEFALO_MIN_BUCK_TIME = 50,
        BEEFALO_MAX_BUCK_TIME = 800,
        BEEFALO_BUCK_TIME_VARIANCE = 3,
        BEEFALO_MIN_DOMESTICATED_OBEDIENCE =
        {
            DEFAULT = 0.8,
            ORNERY = 0.45,
            RIDER = 0.95,
            PUDGY = 0.6,
        },
        BEEFALO_BUCK_TIME_MOOD_MULT = 0.2,
        BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT = 0.3,
        BEEFALO_BUCK_TIME_NUDE_MULT = 0.2,

        BEEFALO_BEG_HUNGER_PERCENT = 0.45,

        BEEFALO_DOMESTICATION_STARVE_OBEDIENCE = -1/(total_day_time*1),
        BEEFALO_DOMESTICATION_FEED_OBEDIENCE = 0.1,
        BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE = -0.3,
        BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_OBEDIENCE = -1,
        BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE = 0.4,
        BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE = -1,

        BEEFALO_DOMESTICATION_LOSE_DOMESTICATION = -1/(total_day_time*4),
        BEEFALO_DOMESTICATION_GAIN_DOMESTICATION = 1/(total_day_time*20),
        BEEFALO_DOMESTICATION_MAX_LOSS_DAYS = 10, -- days
        BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION = -0.01,
        BEEFALO_DOMESTICATION_ATTACKED_DOMESTICATION = 0,
        BEEFALO_DOMESTICATION_ATTACKED_OBEDIENCE = -0.01,
        BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_DOMESTICATION = -0.3,
        BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION = (1-(15/20))/15, -- (1-(targetdays/basedays))/targetdays

        BEEFALO_PUDGY_WELLFED = 1/(total_day_time*5),
        BEEFALO_PUDGY_OVERFEED = 0.02,
        BEEFALO_RIDER_RIDDEN = 1/(total_day_time*5),
        BEEFALO_ORNERY_DOATTACK = 0.004,
        BEEFALO_ORNERY_ATTACKED = 0.004,

        BEEFALOHERD_RANGE = 40,
        BEEFALOHERD_MAX_IN_RANGE = 16,

        BABYBEEFALO_HEALTH = 300,
        BABYBEEFALO_GROW_TIME = {base=3*day_time, random=2*day_time},

        KOALEFANT_HEALTH = 500 * 2, -- harder for multiplayer
        KOALEFANT_DAMAGE = 50,
        KOALEFANT_TARGET_DIST = 5,
        KOALEFANT_CHASE_DIST = 30,
        KOALEFANT_FOLLOW_TIME = 30,

        SPAT_HEALTH = 800,
        SPAT_PHLEGM_DAMAGE = 5,
        SPAT_PHLEGM_ATTACKRANGE = 12,
        SPAT_PHLEGM_RADIUS = 4,
        SPAT_MELEE_DAMAGE = 60,
        SPAT_MELEE_ATTACKRANGE = 0.5,
        SPAT_TARGET_DIST = 10,
        SPAT_CHASE_DIST = 30,
        SPAT_FOLLOW_TIME = 30,

        HUNT_SPAWN_DIST = 40,
        HUNT_COOLDOWN = total_day_time*1.2,
        HUNT_COOLDOWNDEVIATION = total_day_time*0.3,
        HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.05,
        HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.33,

        HUNT_RESET_TIME = 5,
        HUNT_SPRING_RESET_TIME = total_day_time * 3,
        MIN_JOINED_HUNT_DISTANCE = 200, -- if you`re under this distance to an active hunt, you won`t get one

        TRACK_ANGLE_DEVIATION = 30,
        MIN_HUNT_DISTANCE = 300, -- you can't find a new beast without being at least this far from the last one
        MAX_DIRT_DISTANCE = 200, -- if you get this far away from your dirt pile, you probably aren't going to see it any time soon, so remove it and place a new one

        BAT_DAMAGE = 20,
        BAT_HEALTH = 50,
        BAT_ATTACK_PERIOD = 1,
        BAT_ATTACK_DIST = 1.5,
        BAT_WALK_SPEED = 8,
        BAT_TARGET_DIST = 8,
        BAT_ESCAPE_TIME = 60,
        BAT_ESCAPE_RADIUS = 40,

        BATCAVE_REGEN_PERIOD = seg_time * 4,
        BATCAVE_SPAWN_PERIOD = 20,
        BATCAVE_MAX_CHILDREN = 4,
        BATCAVE_ENABLED = true,

        CAVE_ENTRANCE_BATS_REGEN_PERIOD = seg_time * 2,
        CAVE_ENTRANCE_BATS_SPAWN_PERIOD = 1,
        CAVE_ENTRANCE_BATS_MAX_CHILDREN = 6,
        CAVE_ENTRANCE_BATS_ENABLED = true,

        SPIDER_HEALTH = 100,
        SPIDER_DAMAGE = 20,
        SPIDER_ATTACK_PERIOD = 3,
        SPIDER_TARGET_DIST = 4,
        SPIDER_INVESTIGATETARGET_DIST = 6,
        SPIDER_WAKE_RADIUS = 4,
        SPIDER_FLAMMABILITY = .33,
        SPIDER_SUMMON_WARRIORS_RADIUS = 12,
        SPIDER_EAT_DELAY = 1.5,

        SPIDER_WALK_SPEED = 3,
        SPIDER_RUN_SPEED = 5,

        SPIDER_WARRIOR_HEALTH = 200 * 2, -- harder for multiplayer
        SPIDER_WARRIOR_DAMAGE = 20,
        SPIDER_WARRIOR_ATTACK_PERIOD = 4,
        SPIDER_WARRIOR_ATTACK_RANGE = 6,
        SPIDER_WARRIOR_HIT_RANGE = 3,
        SPIDER_WARRIOR_MELEE_RANGE = 3,
        SPIDER_WARRIOR_TARGET_DIST = 10,
        SPIDER_WARRIOR_WAKE_RADIUS = 6,

        SPIDER_WARRIOR_WALK_SPEED = 4,
        SPIDER_WARRIOR_RUN_SPEED = 5,

        SPIDER_HIDER_HEALTH = 150 * 1.5, -- harder for multiplayer
        SPIDER_HIDER_DAMAGE = 20,
        SPIDER_HIDER_ATTACK_PERIOD = 3,
        SPIDER_HIDER_WALK_SPEED = 3,
        SPIDER_HIDER_RUN_SPEED = 5,
        SPIDER_HIDER_SHELL_ABSORB = 0.75,

        SPIDER_SPITTER_HEALTH = 175 * 2, -- harder for multiplayer
        SPIDER_SPITTER_DAMAGE_MELEE = 20,
        SPIDER_SPITTER_DAMAGE_RANGED = 20,
        SPIDER_SPITTER_ATTACK_PERIOD = 5,
        SPIDER_SPITTER_ATTACK_RANGE = 5,
        SPIDER_SPITTER_MELEE_RANGE = 2,
        SPIDER_SPITTER_HIT_RANGE = 3,
        SPIDER_SPITTER_WALK_SPEED = 4,
        SPIDER_SPITTER_RUN_SPEED = 5,

		SPIDER_MOON_HEALTH = 250,
		SPIDER_MOON_DAMAGE = 25,
		SPIDER_MOON_SPIKE_DAMAGE = 10,
		SPIDER_MOON_ATTACK_PERIOD = 3,

        LEIF_HEALTH = 2000 * 1.5, -- harder for multiplayer
        LEIF_DAMAGE = 150,
        LEIF_DAMAGE_PLAYER_PERCENT = .33,
        LEIF_ATTACK_PERIOD = 3,
        LEIF_FLAMMABILITY = .333,
		LEIF_HIT_RECOVERY = 1.5,

        LEIF_MIN_DAY = 3,
        LEIF_PERCENT_CHANCE = 1/75,
        LEIF_MAXSPAWNDIST = 15,

        LEIF_PINECONE_CHILL_CHANCE_CLOSE = .33,
        LEIF_PINECONE_CHILL_CHANCE_FAR = .15,
        LEIF_PINECONE_CHILL_CLOSE_RADIUS = 5,
        LEIF_PINECONE_CHILL_RADIUS = 16,
        LEIF_REAWAKEN_RADIUS = 20,

        LEIF_BURN_TIME = 10,
        LEIF_BURN_DAMAGE_PERCENT = 1/8,

        DEERCLOPS_HEALTH = 2000 * 2, -- harder for multiplayer
        DEERCLOPS_DAMAGE = 150,
        DEERCLOPS_DAMAGE_PLAYER_PERCENT = .5,
        DEERCLOPS_ATTACK_PERIOD = 4,
        DEERCLOPS_ATTACK_RANGE = 8,
        DEERCLOPS_AOE_RANGE = 12,-- 6,
        DEERCLOPS_AOE_SCALE = 0.8,
        DEERCLOPS_LOSE_TARGET_PERIOD = 60,

        BIRD_SPAWN_MAX = 4,
        BIRD_SPAWN_DELAY = {min=5, max=15},
        BIRD_SPAWN_MAX_FEATHERHAT = 7,                   -- DEPRECATED
        BIRD_SPAWN_DELAY_FEATHERHAT = {min=2, max=10},   -- DEPRECATED
        BIRD_SPAWN_MAXDELTA_FEATHERHAT = 3,
        BIRD_SPAWN_DELAYDELTA_FEATHERHAT = {MIN = -3, MAX = -5},
        BIRD_SEE_THREAT_DISTANCE = 5,

        FROG_RAIN_DELAY = {min=0.1, max=2},
        FROG_RAIN_SPAWN_RADIUS = 60,
        FROG_RAIN_MAX = 300,
        FROG_RAIN_LOCAL_MIN = 12,
        FROG_RAIN_LOCAL_MAX = 35,
        FROG_RAIN_LOCAL_MIN_ADVENTURE = 10,
        FROG_RAIN_LOCAL_MAX_ADVENTURE = 25,
        FROG_RAIN_MAX_RADIUS = 50,
        FROG_RAIN_PRECIPITATION = 0.55, -- 0-1, 0.8 by default (old "often" setting for Adventure)
        FROG_RAIN_MOISTURE = 2500, -- 0-4000ish, 2500 by default (old "often" setting for Adventure)
        FROG_RAIN_CHANCE = 0.16,

        BEE_HEALTH = 100,
        BEE_DAMAGE = 10,
        BEE_ATTACK_RANGE = .6,
        BEE_ATTACK_PERIOD = 2,
        BEE_TARGET_DIST = 8,
        BEE_ALLERGY_EXTRADAMAGE = 10,

        BEEMINE_BEES = 4,
        BEEMINE_RADIUS = 3,

        SPIDERDEN_GROW_TIME = {day_time*8, day_time*8, day_time*20}, --[3] is now unused.
        SPIDERDEN_GROW_TIME_QUEEN = day_time*20,
        SPIDERDEN_QUEEN_CAP = 4,
        SPIDERDEN_QUEEN_RANGE_CHECK = 60,
        SPIDERDEN_HEALTH = {50*5, 50*10, 50*20},
        SPIDERDEN_SPIDERS = {3, 6, 9},
        SPIDERDEN_WARRIORS = {0, 1, 3},  -- every hit, release up to this many warriors, and fill remainder with regular spiders
        SPIDERDEN_EMERGENCY_WARRIORS = {0, 4, 8}, -- the max "bonus" spiders, one per player
        SPIDERDEN_EMERGENCY_RADIUS = {10, 15, 20},
        SPIDERDEN_SPIDER_TYPE = {"spider", "spider_warrior", "spider_warrior"},
        SPIDERDEN_REGEN_TIME = 3*seg_time,
        SPIDERDEN_RELEASE_TIME = 5,
        SPIDERDEN_ENABLED = true,
        SPAWN_SPIDER_WARRIORS = true,

        HOUNDMOUND_HOUNDS_MIN = 2,
        HOUNDMOUND_HOUNDS_MAX = 3,
        HOUNDMOUND_REGEN_TIME = seg_time * 6,
        HOUNDMOUND_RELEASE_TIME = seg_time,
        HOUNDMOUND_ENABLED = true,

        POND_FROGS = 4,
        POND_REGEN_TIME = day_time/2,
        POND_SPAWN_TIME = day_time/4,
        FROG_POND_REGEN_TIME = day_time/2,
        FROG_POND_SPAWN_TIME = day_time/4,
        FROG_POND_CHILDREN = {min = 3, max = 4},
        FROG_POND_ENABLED = true,
        MOSQUITO_POND_REGEN_TIME = day_time/2,
        MOSQUITO_POND_SPAWN_TIME = day_time/4,
        MOSQUITO_POND_CHILDREN = {min = 3, max = 4},
        MOSQUITO_POND_ENABLED = true,
        POND_RETURN_TIME = day_time*3/4,
        FISH_RESPAWN_TIME = day_time/3,

        BEEHIVE_BEES = 5,
        BEEHIVE_EMERGENCY_BEES = 8,
        BEEHIVE_EMERGENCY_RADIUS = 20,
        BEEHIVE_RELEASE_TIME = day_time/6,
        BEEHIVE_REGEN_TIME = seg_time,
        BEEHIVE_ENABLED = true,
        BEEBOX_BEES = 4,
        WASPHIVE_RELEASE_TIME = 20,
        WASPHIVE_REGEN_TIME = 20,
        WASPHIVE_WASPS = 5,
        WASPHIVE_EMERGENCY_WASPS = 8,
        WASPHIVE_EMERGENCY_RADIUS = 25,
        WASPHIVE_ENABLED = true,
        BEEBOX_RELEASE_TIME = (0.5*day_time)/4,
        BEEBOX_HONEY_TIME = day_time,
        BEEBOX_REGEN_TIME = seg_time*4,
        BEEBOX_ENABLED = true,

        WORM_DAMAGE = 75,
        WORM_ATTACK_PERIOD = 4,
        WORM_ATTACK_DIST = 3,
        WORM_HEALTH = 900,
        WORM_CHASE_TIME = 20,
        WORM_LURE_TIME = 30,
        WORM_LURE_VARIANCE = 10,
        WORM_FOOD_DIST = 15,
        WORM_CHASE_DIST = 50,
        WORM_WANDER_DIST = 30,
        WORM_TARGET_DIST = 20,
        WORM_LURE_COOLDOWN = 30,
        WORM_EATING_COOLDOWN = 30,

        WORMLIGHT_RADIUS = 3,
        WORMLIGHT_DURATION = seg_time * 8,

        WORMLIGHT_PLANT_REGROW_TIME = total_day_time*4,

        TENTACLE_DAMAGE = 34,
        TENTACLE_ATTACK_PERIOD = 2,
        TENTACLE_ATTACK_DIST = 4,
        TENTACLE_STOPATTACK_DIST = 6,
        TENTACLE_HEALTH = 500,

        TENTACLE_PILLAR_HEALTH = 500 * 1.5, -- harder for multiplayer
        TENTACLE_PILLAR_ARMS = 12,   -- max spawned at a time
        TENTACLE_PILLAR_ARMS_TOTAL = 25,  -- max simultaneous arms
        TENTACLE_PILLAR_ARM_DAMAGE = 5,
        TENTACLE_PILLAR_ARM_ATTACK_PERIOD = 3,
        TENTACLE_PILLAR_ARM_ATTACK_DIST = 3,
        TENTACLE_PILLAR_ARM_STOPATTACK_DIST = 5,
        TENTACLE_PILLAR_ARM_HEALTH = 20,
        TENTACLE_PILLAR_ARM_EMERGE_TIME = seg_time * 12,

        BIG_TENTACLE_DAMAGE = 60,

        EYEPLANT_DAMAGE = 20,
        EYEPLANT_HEALTH = 30,
        EYEPLANT_ATTACK_PERIOD = 1,
        EYEPLANT_ATTACK_DIST = 2.5,
        EYEPLANT_STOPATTACK_DIST = 4,

        LUREPLANT_HIBERNATE_TIME = total_day_time * 2,
        LUREPLANT_GROWTHCHANCE = 0.02,
        LUREPLANT_SPAWNTIME = total_day_time * 12,
        LUREPLANT_SPAWNTIME_VARIANCE = total_day_time * 3,

        TALLBIRD_HEALTH = 400 * 2, -- harder for multiplayer
        TALLBIRD_DAMAGE = 50,
        TALLBIRD_ATTACK_PERIOD = 2,
        TALLBIRD_HATEPIGS_DIST = 16,
        TALLBIRD_TARGET_DIST = 8,
        TALLBIRD_DEFEND_DIST = 12,
        TALLBIRD_ATTACK_RANGE = 3,

        TEENBIRD_HEALTH = 400*.75 * 2, -- harder for multiplayer
        TEENBIRD_DAMAGE = 50*.75,
        TEENBIRD_ATTACK_PERIOD = 2,
        TEENBIRD_ATTACK_RANGE = 3,
        TEENBIRD_DAMAGE_PECK = 2,
        TEENBIRD_PECK_PERIOD = 4,
        TEENBIRD_HUNGER = 60,
        TEENBIRD_STARVE_TIME = total_day_time * 1,
        TEENBIRD_STARVE_KILL_TIME = 240,
        TEENBIRD_GROW_TIME = total_day_time*18,
        TEENBIRD_TARGET_DIST = 8,

        SMALLBIRD_HEALTH = 50,
        SMALLBIRD_DAMAGE = 10,
        SMALLBIRD_ATTACK_PERIOD = 1,
        SMALLBIRD_ATTACK_RANGE = 3,
        SMALLBIRD_HUNGER = 20,
        SMALLBIRD_STARVE_TIME = total_day_time * 1,
        SMALLBIRD_STARVE_KILL_TIME = 120,
        SMALLBIRD_GROW_TIME = total_day_time*10,

        SMALLBIRD_HATCH_CRACK_TIME = 10, -- set by fire for this much time to start hatching progress
        SMALLBIRD_HATCH_TIME = total_day_time * 3, -- must be content for this amount of cumulative time to hatch
        SMALLBIRD_HATCH_FAIL_TIME = night_time * .5, -- being too hot or too cold this long will kill the egg

        MIN_SPRING_SMALL_BIRD_SPAWN_TIME = total_day_time * 2,
        MAX_SPRING_SMALL_BIRD_SPAWN_TIME = total_day_time * 8,

        HATCH_UPDATE_PERIOD = 3,
        HATCH_CAMPFIRE_RADIUS = 4,

        CHESTER_HEALTH = wilson_health*3,
        CHESTER_RESPAWN_TIME = total_day_time * 1,
        CHESTER_HEALTH_REGEN_AMOUNT = (wilson_health*3) * 3/60,
        CHESTER_HEALTH_REGEN_PERIOD = 3,

        HUTCH_HEALTH = wilson_health * 3,
        HUTCH_RESPAWN_TIME = total_day_time * 1,
        HUTCH_HEALTH_REGEN_AMOUNT = (wilson_health*3) * 3/60,
        HUTCH_HEALTH_REGEN_PERIOD = 3,

        PROTOTYPER_TREES =
        {
            SCIENCEMACHINE = TechTree.Create({
                SCIENCE = 1,
                MAGIC = 1,
            }),

            ALCHEMYMACHINE = TechTree.Create({
                SCIENCE = 2,
                MAGIC = 1,
            }),

            PRESTIHATITATOR = TechTree.Create({
                MAGIC = 2,
            }),

            SHADOWMANIPULATOR = TechTree.Create({
                MAGIC = 3,
            }),

            ANCIENTALTAR_LOW = TechTree.Create({
                ANCIENT = 2,
            }),

            ANCIENTALTAR_HIGH = TechTree.Create({
                ANCIENT = 4,
            }),

            MOONORB_LOW = TechTree.Create({
                CELESTIAL = 1,
            }),

            MOONORB_UPGRADED = TechTree.Create({
                CELESTIAL = 3,
            }),

			MOON_ALTAR_FULL = TechTree.Create({
                CELESTIAL = 3,
            }),

            WAXWELLJOURNAL = TechTree.Create({
                SHADOW = 4,
            }),

            CARTOGRAPHYDESK = TechTree.Create({
                CARTOGRAPHY = 2,
            }),

			SEAFARING_STATION = TechTree.Create({
                SEAFARING = 2,
            }),

            SCULPTINGTABLE = TechTree.Create({
                SCULPTING = 1,
            }),

            CRITTERLAB = TechTree.Create({
                ORPHANAGE = 1,
            }),

            PERDSHRINE = TechTree.Create({
                PERDOFFERING = 3,
            }),

            WARGSHRINE = TechTree.Create({
                WARGOFFERING = 3,
                PERDOFFERING = 1,
            }),

            PIGSHRINE = TechTree.Create({
                PIGOFFERING = 3,
                PERDOFFERING = 1,
            }),

            CARRATSHRINE = TechTree.Create({
                CARRATOFFERING = 3,
                PERDOFFERING = 1,
            }),

            BEEFSHRINE = TechTree.Create({
                BEEFOFFERING = 3,
                PERDOFFERING = 1,
            }),

            CATCOONSHRINE = TechTree.Create({
                CATCOONOFFERING = 3,
                PERDOFFERING = 1,
            }),

            MADSCIENCE = TechTree.Create({
                MADSCIENCE = 1,
            }),

			CARNIVAL_PRIZESHOP = TechTree.Create({
                CARNIVAL_PRIZESHOP = 1,
            }),

			CARNIVAL_HOSTSHOP_WANDER = TechTree.Create({
                CARNIVAL_HOSTSHOP = 1,
            }),

			CARNIVAL_HOSTSHOP_PLAZA = TechTree.Create({
                CARNIVAL_HOSTSHOP = 3,
            }),

            FOODPROCESSING = TechTree.Create({
                FOODPROCESSING = 1,
            }),

            FISHING = TechTree.Create({
                FISHING = 1,
            }),

			WINTERSFEASTCOOKING = TechTree.Create({
				WINTERSFEASTCOOKING = 1,
			}),

			HERMITCRABSHOP_L1 = TechTree.Create({
				HERMITCRABSHOP = 1,
			}),
			HERMITCRABSHOP_L2 = TechTree.Create({
				HERMITCRABSHOP = 3,
			}),
			HERMITCRABSHOP_L3 = TechTree.Create({
				HERMITCRABSHOP = 5,
			}),
            HERMITCRABSHOP_L4 = TechTree.Create({
                HERMITCRABSHOP = 7,
            }),

            TURFCRAFTING = TechTree.Create({
                TURFCRAFTING = 2,
                MASHTURFCRAFTING = 2,
            }),

            SPIDERCRAFT = TechTree.Create({
                SPIDERCRAFT = 1,
            }),

            ROBOTMODULECRAFT = TechTree.Create({
                ROBOTMODULECRAFT = 1,
            }),
		},

        RABBIT_HEALTH = 25 * multiplayer_attack_modifier,
        MOLE_HEALTH = 30,

        FROG_HEALTH = 100,
        FROG_DAMAGE = 10,
        FROG_ATTACK_PERIOD = 1,
        FROG_TARGET_DIST = 4,

        HOUND_SPECIAL_CHANCE =
        {
            {minday=0, chance=0},
            {minday=15, chance=.1},
            {minday=30, chance=.2},
            {minday=50, chance=.333},
            {minday=75, chance=.5},
        },

        HOUND_HEALTH = 150,
        HOUND_DAMAGE = 20,
        HOUND_ATTACK_PERIOD = 2,
        HOUND_TARGET_DIST = 20,
        HOUND_SPEED = 10,
        HOUND_SWIM_SPEED = 3.5,
        CLAYHOUND_SPEED = 8.5,

        HOUND_FOLLOWER_TARGET_DIST = 10,
        HOUND_FOLLOWER_TARGET_KEEP = 20,
        HOUND_FOLLOWER_AGGRO_DIST = 8,
        HOUND_FOLLOWER_RETURN_DIST = 12,

        FIREHOUND_HEALTH = 100,
        FIREHOUND_DAMAGE = 30,
        FIREHOUND_ATTACK_PERIOD = 2,
        FIREHOUND_SPEED = 10,

        ICEHOUND_HEALTH = 100,
        ICEHOUND_DAMAGE = 30,
        ICEHOUND_ATTACK_PERIOD = 2,
        ICEHOUND_SPEED = 10,

        MOONHOUND_HEALTH = 150,
        MOONHOUND_DAMAGE = 20,
        MOONHOUND_ATTACK_PERIOD = 2,
        MOONHOUND_SPEED = 10,
        MOONHOUND_AGGRO_DIST = 15,
        MOONHOUND_RETURN_DIST = 30,
        MOONHOUND_FREEZE_WEAR_OFF_TIME = 3,

		MUTATEDHOUND_SPAWN_CHANCE = 0.5,
		MUTATEDHOUND_SPAWN_DELAY = 4,
        MUTATEDHOUND_HEALTH = 100,
        MUTATEDHOUND_DAMAGE = 25,
        MUTATEDHOUND_ATTACK_PERIOD = 2.5,

        MOONPIG_AGGRO_DIST = 15,
        MOONPIG_RETURN_DIST = 30,
        MOONPIG_FREEZE_WEAR_OFF_TIME = 3,

        MOSQUITO_WALKSPEED = 8,
        MOSQUITO_RUNSPEED = 12,
        MOSQUITO_DAMAGE = 3,
        MOSQUITO_HEALTH = 100,
        MOSQUITO_ATTACK_RANGE = 1.75,
        MOSQUITO_ATTACK_PERIOD = 7,
        MOSQUITO_MAX_DRINKS = 4,
        MOSQUITO_BURST_DAMAGE = 34,
        MOSQUITO_BURST_RANGE = 4,

        KRAMPUS_HEALTH = 200 * 1.5, -- harder for multiplayer
        KRAMPUS_DAMAGE = 50,
        KRAMPUS_ATTACK_PERIOD = 1.2,
        KRAMPUS_SPEED = 7,
        KRAMPUS_THRESHOLD = 30,
        KRAMPUS_THRESHOLD_VARIANCE = 20,
        KRAMPUS_INCREASE_LVL1 = 50,
        KRAMPUS_INCREASE_LVL2 = 100,
        KRAMPUS_INCREASE_RAMP = 2,
        KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 60,

        TERRORBEAK_SPEED = 7,
        TERRORBEAK_HEALTH = 400,
        TERRORBEAK_DAMAGE = 50,
        TERRORBEAK_ATTACK_PERIOD= 1.5,

        CRAWLINGHORROR_SPEED = 3,
        CRAWLINGHORROR_HEALTH = 300,
        CRAWLINGHORROR_DAMAGE = 20,
        CRAWLINGHORROR_ATTACK_PERIOD= 2.5,

        SHADOWCREATURE_TARGET_DIST = 20,
		SHADOWCREATURE_TARGET_DIST_SQ = 20*20,

        SHADOW_CHESSPIECE_EPICSCARE_RANGE = 10,
        SHADOW_CHESSPIECE_DESPAWN_TIME = 30,

        SHADOW_ROOK =
        {
            LEVELUP_SCALE = {1, 1.2, 1.6},
            SPEED = 7,                          -- levels are procedural
            HEALTH = {1000, 4000, 10000},
            DAMAGE = {45, 100, 165},
            ATTACK_PERIOD = {6, 5.5, 5},
            ATTACK_RANGE = 8,                   -- levels are procedural
            HIT_RANGE = 3.35,
            RETARGET_DIST = 15,
        },

        SHADOW_KNIGHT =
        {
            LEVELUP_SCALE = {1, 1.7, 2.5},
            SPEED = {7, 9, 12},
            HEALTH = {900, 2700, 8100},
            DAMAGE = {40, 90, 150},
            ATTACK_PERIOD = {3, 2.5, 2},
            ATTACK_RANGE = 2.3,                 -- levels are procedural
            ATTACK_RANGE_LONG = 4.5,            -- levels are procedural
            RETARGET_DIST = 15,
        },

        SHADOW_BISHOP =
        {
            LEVELUP_SCALE = {1, 1.6, 2.2},
            SPEED = 3,                          -- levels are procedural
            HEALTH = {800, 2500, 7500},
            DAMAGE = {20, 35, 60},
            ATTACK_PERIOD = {15, 14, 12},
            ATTACK_RANGE = {4, 6, 8},           -- levels are procedural
            HIT_RANGE = 1.75,
            ATTACK_TICK = .5,
            ATTACK_START_TICK = .2,
            RETARGET_DIST = 15,
        },

        FROSTY_BREATH = -5,

        SEEDS_GROW_TIME = day_time*6,
        FARM1_GROW_BONUS = 1,
        FARM2_GROW_BONUS = .6667,
        FARM3_GROW_BONUS = .333,
        POOP_FERTILIZE = day_time,
        POOP_SOILCYCLES = 10,
        POOP_WITHEREDCYCLES = 1,
        POOP_CAN_USES = 8,
        GUANO_FERTILIZE = day_time * 1.5,
        GUANO_SOILCYCLES = 12,
        GUANO_WITHEREDCYCLES = 1,

		SOILAMENDER_FERTILIZE_HEALTH_LOW	= 1,
		SOILAMENDER_FERTILIZE_LOW			= day_time/8,
		SOILAMENDER_SOILCYCLES_LOW			= 1,
		SOILAMENDER_WITHEREDCYCLES_LOW		= 0.25,

		SOILAMENDER_FERTILIZE_HEALTH_MED	= 2,
		SOILAMENDER_FERTILIZE_MED			= day_time/2,
		SOILAMENDER_SOILCYCLES_MED			= 2,
		SOILAMENDER_WITHEREDCYCLES_MED		= 0.5,

		SOILAMENDER_FERTILIZE_HEALTH_HIGH	= 3,
		SOILAMENDER_FERTILIZE_HIGH			= day_time*1.5,
		SOILAMENDER_SOILCYCLES_HIGH			= 5,
		SOILAMENDER_WITHEREDCYCLES_HIGH		= 1,

		SOILAMENDER_FERMENTED_USES	= 5,

		SOILAMENDER_PERCOLATE_ANIM_DELAY_FRESH = 15,
		SOILAMENDER_PERCOLATE_ANIM_DELAY_STALE = 8,
		SOILAMENDER_PERCOLATE_ANIM_DELAY_SPOILED = 4,

		PERISH_FRESH = 0.5,
		PERISH_STALE = 0.2,

        GLOMMERFUEL_FERTILIZE = day_time,
        GLOMMERFUEL_SOILCYCLES = 8,

        SPOILEDFOOD_FERTILIZE = day_time/4,
        SPOILEDFOOD_SOILCYCLES = 2,
        SPOILEDFOOD_WITHEREDCYCLES = 0.5,

        TREEGROWTH_SOILCYCLES = 8,
        TREEGROWTH_FERTILIZE = day_time,
        TREEGROWTH_WITHEREDCYCLES = 1,

        MUSHROOMFARM_MAX_HARVESTS = 4,
        MUSHROOMFARM_FULL_GROW_TIME = total_day_time * 3.75,
        MUSHROOMFARM_SPAWN_SPORE_CHANCE = 0.50,

        FISHING_CATCH_CHANCE = 0.4,
        FISHING_LOSEROD_CHANCE = 0.4,

        TURNON_FUELED_CONSUMPTION = .5,
        TURNON_FULL_FUELED_CONSUMPTION = 1 / 60,

        WET_FUEL_PENALTY = 0.75,

        TINY_FUEL = seg_time*.25,
        SMALL_FUEL = seg_time * .5,
        MED_FUEL = seg_time * 1.5,
        MED_LARGE_FUEL = seg_time * 3,
        LARGE_FUEL = seg_time * 6,

        TINY_BURNTIME = seg_time*.1,
        SMALL_BURNTIME = seg_time*.25,
        MED_BURNTIME = seg_time*0.5,
        LARGE_BURNTIME = seg_time,

        TREE_BURN_TIME = 45,

        CAMPFIRE_RAIN_RATE = 2.5,
        CAMPFIRE_FUEL_MAX = (night_time+dusk_time)*1.5,
        CAMPFIRE_FUEL_START = (night_time+dusk_time)*.75,

        COLDFIRE_RAIN_RATE = 2.5,
        COLDFIRE_FUEL_MAX = (night_time+dusk_time)*1.5,
        COLDFIRE_FUEL_START = (night_time+dusk_time)*.75,

        ROCKLIGHT_FUEL_MAX = (night_time+dusk_time)*1.5,

        FIREPIT_RAIN_RATE = 2,
        FIREPIT_FUEL_MAX = (night_time+dusk_time)*2,
        FIREPIT_FUEL_START = night_time+dusk_time,
        FIREPIT_BONUS_MULT = 2,

        COLDFIREPIT_RAIN_RATE = 2,
        COLDFIREPIT_FUEL_MAX = (night_time+dusk_time)*2,
        COLDFIREPIT_FUEL_START = night_time+dusk_time,
        COLDFIREPIT_BONUS_MULT = 2,

        PIGTORCH_RAIN_RATE = 2,
        PIGTORCH_FUEL_MAX = night_time,

        NIGHTLIGHT_FUEL_MAX = (night_time+dusk_time)*3,
        NIGHTLIGHT_FUEL_START = (night_time+dusk_time),

        TORCH_RAIN_RATE = 1.5,
        TORCH_FUEL = night_time*1.25,
        TORCH_SHRINE_FUEL_RATE_MULT = .2,

        MINIFAN_FUEL = day_time * 0.3,

        COMPASS_FUEL = day_time * 4,
        COMPASS_ATTACK_DECAY_PERCENT = -0.3,

        NIGHTSTICK_FUEL = night_time*6,
        LIGHTER_RAIN_RATE = 1,
        LIGHTER_FUEL = total_day_time*1.25,

        MINERHAT_LIGHTTIME = (night_time+dusk_time)*2.6,
        LANTERN_LIGHTTIME = (night_time+dusk_time)*2.6,
        SPIDERHAT_PERISHTIME = 4*seg_time,
        SPIDERHAT_RANGE = 12,
        ONEMANBAND_PERISHTIME = 6*seg_time,
        ONEMANBAND_RANGE = 12,
        HEATROCK_NUMUSES = 8,

        GRASS_UMBRELLA_PERISHTIME = 2*total_day_time*perish_warp,
        UMBRELLA_PERISHTIME = total_day_time*6,
        EYEBRELLA_PERISHTIME = total_day_time*9,

        STRAWHAT_PERISHTIME = total_day_time*5,
        EARMUFF_PERISHTIME = total_day_time*5,
        WINTERHAT_PERISHTIME = total_day_time*10,
        BEEFALOHAT_PERISHTIME = total_day_time*10,

        TRUNKVEST_PERISHTIME = total_day_time*15,
        REFLECTIVEVEST_PERISHTIME = total_day_time*8,
        HAWAIIANSHIRT_PERISHTIME = total_day_time*15,
        SWEATERVEST_PERISHTIME = total_day_time*10,
        HUNGERBELT_PERISHTIME = total_day_time*8,
        BEARGERVEST_PERISHTIME = total_day_time*7,
        RAINCOAT_PERISHTIME = total_day_time*10,

        WALRUSHAT_PERISHTIME = total_day_time*25,
        FEATHERHAT_PERISHTIME = total_day_time*8,
        TOPHAT_PERISHTIME = total_day_time*8,

        ICEHAT_PERISHTIME = total_day_time*4,
        MOLEHAT_PERISHTIME = total_day_time*1.5,
        RAINHAT_PERISHTIME = total_day_time*10,
        CATCOONHAT_PERISHTIME = total_day_time*10,
        GOGGLES_PERISHTIME = total_day_time*10,
        NUTRIENTSGOGGLESHAT_PERISHTIME = total_day_time*10,

        WALTERHAT_PERISHTIME = total_day_time*10,

        GRASS_REGROW_TIME = total_day_time*3,
        SAPLING_REGROW_TIME = total_day_time*4,
        MARSHBUSH_REGROW_TIME = total_day_time*4,
        CACTUS_REGROW_TIME = total_day_time*4,
        FLOWER_CAVE_REGROW_TIME = total_day_time*3,
        FLOWER_CAVE_LIGHT_TIME = 90,
        FLOWER_CAVE_RECHARGE_TIME = 110,
        LICHEN_REGROW_TIME = total_day_time*5,

        BERRY_REGROW_TIME = total_day_time*3,
        BERRY_REGROW_INCREASE = total_day_time*.5,
        BERRY_REGROW_VARIANCE = total_day_time*2,
        BERRYBUSH_CYCLES = 3,

        BERRY_JUICY_REGROW_TIME =  total_day_time * 9,
        BERRY_JUICY_REGROW_INCREASE = total_day_time*.5,
        BERRY_JUICY_REGROW_VARIANCE = total_day_time*2,
        BERRYBUSH_JUICY_CYCLES = 3,

        REEDS_REGROW_TIME = total_day_time*3,

        BIRD_LEAVINGS_CHANCE = 0.2,
        CROW_LEAVINGS_CHANCE = 0.3333,
        BIRD_TRAP_CHANCE = 0.025,
        BIRD_HEALTH = 25*multiplayer_attack_modifier,
        BIRD_PERISH_TIME = total_day_time * 5,
        BIRD_CANARY_LURE_DISTANCE = 12,

        BUTTERFLY_SPAWN_TIME = 10*multiplayer_wildlife_respawn_modifier,
        BUTTERFLY_POP_CAP = 4,
        BUTTERFLY_PERISH_TIME = total_day_time * 3,

        MOONBUTTERFLY_SPEED = 2.5,
        MOONBUTTERFLY_PERISH_TIME = total_day_time / 2,
		MOONBUTTERFLY_PERISH_INV_MODIFIER = 0.25,

        FLOWER_SPAWN_TIME_VARIATION = 20,
        FLOWER_SPAWN_TIME = 30,
        MAX_FLOWERS_PER_AREA = 50,

        MOLE_RESPAWN_TIME = day_time*4*multiplayer_wildlife_respawn_modifier,
        MOLE_ENABLED = true,

        RABBIT_RESPAWN_TIME = day_time*4*multiplayer_wildlife_respawn_modifier,
        RABBIT_ENABLED = true,
        RABBIT_PERISH_TIME = total_day_time * 5,

        MIN_RABBIT_HOLE_TRANSITION_TIME = day_time*.5,
        MAX_RABBIT_HOLE_TRANSITION_TIME = day_time*2,

        FULL_ABSORPTION = 1,
        ARMORGRASS = wilson_health*1.5*multiplayer_armor_durability_modifier,
        ARMORGRASS_ABSORPTION = .6*multiplayer_armor_absorption_modifier,
        ARMORWOOD = wilson_health*3*multiplayer_armor_durability_modifier,
        ARMORWOOD_ABSORPTION = .8*multiplayer_armor_absorption_modifier,
        ARMORMARBLE = wilson_health*7*multiplayer_armor_durability_modifier,
        ARMORMARBLE_ABSORPTION = .95*multiplayer_armor_absorption_modifier,
        ARMORSNURTLESHELL_ABSORPTION = 0.6*multiplayer_armor_absorption_modifier,
        ARMORSNURTLESHELL = wilson_health*7*multiplayer_armor_durability_modifier,
        ARMORMARBLE_SLOW = 0.7,
        ARMORRUINS_ABSORPTION = 0.9*multiplayer_armor_absorption_modifier,
        ARMORRUINS = wilson_health * 12*multiplayer_armor_durability_modifier,
        ARMORSLURPER_ABSORPTION = 0.6*multiplayer_armor_absorption_modifier,
        ARMORSLURPER_SLOW_HUNGER = 0.6,
        ARMORSLURPER = wilson_health * 4*multiplayer_armor_durability_modifier,
        ARMOR_FOOTBALLHAT = wilson_health*3*multiplayer_armor_durability_modifier,
        ARMOR_FOOTBALLHAT_ABSORPTION = .8*multiplayer_armor_absorption_modifier,
        ARMOR_COOKIECUTTERHAT = wilson_health*5*multiplayer_armor_durability_modifier,
        ARMOR_COOKIECUTTERHAT_ABSORPTION = .7*multiplayer_armor_absorption_modifier,

        ARMORDRAGONFLY = wilson_health * 9*multiplayer_armor_durability_modifier,
        ARMORDRAGONFLY_ABSORPTION = 0.7*multiplayer_armor_absorption_modifier,
        ARMORDRAGONFLY_FIRE_RESIST = 1,

        ARMORBEARGER_SLOW_HUNGER = 0.75,

        ARMOR_WATHGRITHRHAT = wilson_health * 5*multiplayer_armor_durability_modifier,
        ARMOR_WATHGRITHRHAT_ABSORPTION = .8*multiplayer_armor_absorption_modifier,

        ARMOR_RUINSHAT = wilson_health*8*multiplayer_armor_durability_modifier,
        ARMOR_RUINSHAT_ABSORPTION = 0.9*multiplayer_armor_absorption_modifier,
        ARMOR_RUINSHAT_PROC_CHANCE = 0.33,
        ARMOR_RUINSHAT_COOLDOWN = 5,
        ARMOR_RUINSHAT_DURATION = 4,
        ARMOR_RUINSHAT_DMG_AS_SANITY = 0.05,

        ARMOR_SLURTLEHAT = wilson_health*5*multiplayer_armor_durability_modifier,
        ARMOR_SLURTLEHAT_ABSORPTION = 0.9*multiplayer_armor_absorption_modifier,
        ARMOR_BEEHAT = wilson_health*10*multiplayer_armor_durability_modifier,
        ARMOR_BEEHAT_ABSORPTION = .8*multiplayer_armor_absorption_modifier,
        ARMOR_SANITY = wilson_health * 5*multiplayer_armor_durability_modifier,
        ARMOR_SANITY_ABSORPTION = .95*multiplayer_armor_absorption_modifier,
        ARMOR_SANITY_DMG_AS_SANITY = 0.10,

        ARMOR_HIVEHAT = wilson_health * 9 * multiplayer_armor_durability_modifier,
        ARMOR_HIVEHAT_ABSORPTION = .7 * multiplayer_armor_absorption_modifier,
        ARMOR_HIVEHAT_SANITY_ABSORPTION = .5,

        ARMOR_SKELETONHAT = wilson_health * 9 * multiplayer_armor_durability_modifier,
        ARMOR_SKELETONHAT_ABSORPTION = .7 * multiplayer_armor_absorption_modifier,

        ARMOR_SKELETON_COOLDOWN = 5,
        ARMOR_SKELETON_FIRST_COOLDOWN = 1,

        PANFLUTE_SLEEPTIME = 20,
        PANFLUTE_SLEEPRANGE = 15,
        PANFLUTE_USES = 10,

        HORN_RANGE = 25,
        HORN_USES = 10,
        HORN_EFFECTIVE_TIME = 20,
        HORN_MAX_FOLLOWERS = 5,

        HOUNDWHISTLE_USES = 10,
        HOUNDWHISTLE_RANGE = 25,
        HOUNDWHISTLE_EFFECTIVE_TIME = 40,
        HOUNDWHISTLE_MAX_FOLLOWERS = 5,

        MANDRAKE_SLEEP_TIME = 10,
        MANDRAKE_SLEEP_RANGE = 15,
        MANDRAKE_SLEEP_RANGE_COOKED = 25,
        KNOCKOUT_SLEEP_TIME = 30,
        SLEEPBOMB_DURATION = 20,

        GOLD_VALUES =
        {
            CARNIVAL_GAMETOKEN = 1,
            ANTLION = 1,
            MEAT = 1,
            RAREMEAT = 5,
            YOTB_BEEFALO_DOLL = 3,
            TRINKETS =
            {
                4, --[1] Melty Marbles
                6, --[2] Fake Kazoo
                4, --[3] Gord's Knot
                5, --[4] Gnome
                4, --[5] Tiny Rocketship
                5, --[6] Frazzled Wires
                4, --[7] Ball and Cup
                8, --[8] Hardened Rubber Bung
                7, --[9] Mismatched Buttons
                2, --[10] Second-hand Dentures
                5, --[11] Lying Robot
                8, --[12] Dessicated Tentacle
                5, --[13] Gnomette
                3, --[14] Leaky Teacup
                4, --[15] White Bishop
                4, --[16] Black Bishop
                2, --[17] Bent Spork
                6, --[18] Toy Trojan Horse
                6, --[19] Unbalanced Top
                7, --[20] Back Scratcher
                5, --[21] Beaten Beater
                4, --[22] Ball of Twine
                3, --[23] Shoe Horn
                8, --[24] Lucky Cat Jar
                2, --[25] Air Unfreshener
                9, --[26] Potato Cup
                4, --[27] Wire Hanger
                4, --[28] White Rook
                4, --[29] Black Rook
                4, --[30] White Knight
                4, --[31] Black Knight
                1, --[32] Crystal Ball
                1, --[33] Spider Ring
                1, --[34] Hand / Monkey Paw?
                1, --[35] Empty Potion Bottle
                1, --[36] Vampire Teeth
                1, --[37] Wooden Stake
            },
        },

        RESEARCH_COST_CHEAP = 30,
        RESEARCH_COST_MEDIUM = 100,
        RESEARCH_COST_EXPENSIVE = 200,

        SPIDERQUEEN_WALKSPEED = 1.75,
        SPIDERQUEEN_HEALTH = 1250 * 2, -- harder for multiplayer
        SPIDERQUEEN_DAMAGE = 80,
        SPIDERQUEEN_ATTACKPERIOD = 3,
        SPIDERQUEEN_ATTACKRANGE = 5,
        SPIDERQUEEN_FOLLOWERS = 16,
        SPIDERQUEEN_GIVEBIRTHPERIOD = 10,
        SPIDERQUEEN_MINWANDERTIME = total_day_time * 1.5,
        SPIDERQUEEN_MINDENSPACING = 20,
        SPIDERQUEEN_NEARBYPLAYERSDIST = 20,

        SPAWN_SPIDERQUEEN = true,

        TRAP_TEETH_USES = 10,
        TRAP_TEETH_DAMAGE = 60,
        TRAP_TEETH_RADIUS = 1.5,

        MAX_HEALING_NORMAL = -0.25, --as a % of maximum health

        HEALING_TINY = 1,
        HEALING_SMALL = 3,
        HEALING_MEDSMALL = 8,
        HEALING_MED = 20,
        HEALING_MEDLARGE = 30,
        HEALING_LARGE = 40,
        HEALING_HUGE = 60,
        HEALING_SUPERHUGE = 100,

        SANITY_SUPERTINY = 1,
        SANITY_TINY = 5,
        SANITY_SMALL = 10,
        SANITY_MED = 15,
        SANITY_MEDLARGE = 20,
        SANITY_LARGE = 33,
        SANITY_HUGE = 50,

        LUCY_REVERT_TIME = 90, -- seconds
        LUCY_BITE_DAMAGE = 5, -- amount of damage done to non-woodies who equip lucy

        PERISH_ONE_DAY = 1*total_day_time*perish_warp,
        PERISH_TWO_DAY = 2*total_day_time*perish_warp,
        PERISH_SUPERFAST = 3*total_day_time*perish_warp,
        PERISH_FAST = 6*total_day_time*perish_warp,
        PERISH_FASTISH = 8*total_day_time*perish_warp,
        PERISH_MED = 10*total_day_time*perish_warp,
        PERISH_SLOW = 15*total_day_time*perish_warp,
        PERISH_PRESERVED = 20*total_day_time*perish_warp,
        PERISH_SUPERSLOW = 40*total_day_time*perish_warp,

		DRY_SUPERFAST = 0.25*total_day_time,
		DRY_VERYFAST = 0.5*total_day_time,
        DRY_FAST = total_day_time,
        DRY_MED = 2*total_day_time,

        CALORIES_TINY = calories_per_day/8,			-- berries				 9.375
        CALORIES_SMALL = calories_per_day/6,		-- veggies				 12.5
        CALORIES_MEDSMALL = calories_per_day/4,		--						 18.75
        CALORIES_MED = calories_per_day/3,			-- meat					 25
        CALORIES_LARGE = calories_per_day/2,		-- cooked meat			 37.5
        CALORIES_HUGE = calories_per_day,			-- crockpot foods?		 75
        CALORIES_SUPERHUGE = calories_per_day*2,	-- crockpot foods?		150

		-- food affinity multipliers to add 15 calories
		AFFINITY_15_CALORIES_TINY = 2.6,
		AFFINITY_15_CALORIES_SMALL = 2.2,
		AFFINITY_15_CALORIES_MED = 1.6,
		AFFINITY_15_CALORIES_LARGE = 1.4,
		AFFINITY_15_CALORIES_HUGE = 1.2,
		AFFINITY_15_CALORIES_SUPERHUGE = 1.1,

        SPOILED_HEALTH = -1,
        SPOILED_HUNGER = -10,
        PERISH_COLD_FROZEN_MULT = 0, -- frozen things don't spoil in an ice box or if it's cold out
        PERISH_FROZEN_FIRE_MULT = 30, -- frozen things spoil very quickly if near a fire
        PERISH_FRIDGE_MULT = .5,
        PERISH_FOOD_PRESERVER_MULT = .75,
		PERISH_SALTBOX_MULT = .25,
		PERISH_MUSHROOM_LIGHT_MULT = .25,
        PERISH_GROUND_MULT = 1.5,
        PERISH_WET_MULT = 1.3,
        PERISH_CAGE_MULT = 0.25,
        PERISH_GLOBAL_MULT = 1,
        PERISH_WINTER_MULT = .75,
        PERISH_SUMMER_MULT = 1.25,

        STALE_FOOD_HUNGER = .667,
        SPOILED_FOOD_HUNGER = .5,

        STALE_FOOD_HEALTH = .333,
        SPOILED_FOOD_HEALTH = 0,

        BASE_COOK_TIME = night_time*.3333,

        TALLBIRDEGG_HEALTH = 15;
        TALLBIRDEGG_HUNGER = 15,
        TALLBIRDEGG_COOKED_HEALTH = 25;
        TALLBIRDEGG_COOKED_HUNGER = 30,

        REPAIR_CUTSTONE_HEALTH = 50,
        REPAIR_ROCKS_HEALTH = 50/3,
        REPAIR_GEMS_WORK = 1,
        REPAIR_GEARS_WORK = 1,

        REPAIR_THULECITE_WORK = 1.5,
        REPAIR_THULECITE_HEALTH = 100,

        REPAIR_THULECITE_PIECES_WORK = 1.5/6,
        REPAIR_THULECITE_PIECES_HEALTH = 100/6,

        REPAIR_BOARDS_HEALTH = 50,
        REPAIR_LOGS_HEALTH = 50/4,
        REPAIR_STICK_HEALTH = 13,
        REPAIR_CUTGRASS_HEALTH = 13,
        REPAIR_TREEGROWTH_HEALTH = 20,

        REPAIR_MOONROCK_CRATER_HEALTH = 80,
        REPAIR_MOONROCK_CRATER_WORK = 4,

        REPAIR_MOONROCK_NUGGET_HEALTH = 80/2,
        REPAIR_MOONROCK_NUGGET_WORK = 2,

        SCULPTURE_COMPLETE_WORK = 10,
        SCULPTURE_COVERED_WORK = 6,

        GARGOYLE_MINE = 4,
        GARGOYLE_MINE_LOW = 2,
        GARGOYLE_REANIMATE_DELAY = .2,--6 * FRAMES--FRAMES is not declared at worldgen YO

        MOONBASE_CHARGE_DELAY = 10, --so it won't start right away as it fades to night
        MOONBASE_CHARGE_DURATION = seg_time * 2 - 10.1, --tiny error to make sure it fits within a 2 seg night
        MOONBASE_CHARGE_DURATION1 = 18.7, --18.6, --first stage, to match music length
        MOONBASE_COMPLETE_WORK = 6,
        MOONBASE_DAMAGED_WORK = 4,

        HAYWALL_HEALTH = 100,
        WOODWALL_HEALTH = 200,
        STONEWALL_HEALTH = 400,
        RUINSWALL_HEALTH = 800,

        MOONROCKWALL_HEALTH = 600,
        MOONROCKWALL_PLAYERDAMAGEMOD = .25,
        MOONROCKWALL_WORK = 25,

        PORTAL_HEALTH_PENALTY = 0.25,
        HEART_HEALTH_PENALTY = 0.125,

        MAXIMUM_HEALTH_PENALTY = 0.75,
        MAXIMUM_SANITY_PENALTY = 0.9,

        EFFIGY_HEALTH_PENALTY = 40,
        REVIVE_HEALTH_PENALTY_AS_MULTIPLE_OF_EFFIGY = 1,

        REVIVE_SHADOW_SANITY_PENALTY = -40,
        REVIVE_OTHER_SANITY_BONUS = 80,
        REVIVE_HEALTH_PENALTY = 0.25,

        SANITY_HIGH_LIGHT = .6,
        SANITY_LOW_LIGHT =  0.1,

        SANITY_DAPPERNESS = 1,

        SANITY_BECOME_SANE_THRESH = 35/200,
        SANITY_BECOME_INSANE_THRESH = 30/200,

        SANITY_BECOME_ENLIGHTENED_THRESH = 170/200,
        SANITY_LOSE_ENLIGHTENMENT_THRESH = 165/200,

        SANITY_DAY_GAIN = 0,--100/(day_time*32),

        SANITY_NIGHT_LIGHT = -100/(night_time*20),
        SANITY_NIGHT_MID = -100/(night_time*20),
        SANITY_NIGHT_DARK = -100/(night_time*2),

        SANITY_LUNACY_DAY_GAIN = 100/(day_time*32),
        SANITY_LUNACY_NIGHT_LIGHT = 0,
        SANITY_LUNACY_NIGHT_MID = 0,
        SANITY_LUNACY_NIGHT_DARK = -100/(night_time*10),

        SANITY_GHOST_PLAYER_DRAIN = -100/(night_time*30),
        MAX_SANITY_GHOST_PLAYER_DRAIN_MULT = 3,

        SANITYAURA_TINY = 100/(seg_time*32),
        SANITYAURA_SMALL_TINY = 100/(seg_time*20),
        SANITYAURA_SMALL = 100/(seg_time*8),
        SANITYAURA_MED = 100/(seg_time*5),
        SANITYAURA_LARGE = 100/(seg_time*2),
        SANITYAURA_HUGE = 100/(seg_time*.5),
        SANITYAURA_SUPERHUGE = 100/(seg_time*.25),

        DAPPERNESS_TINY = 100/(day_time*15),
        DAPPERNESS_SMALL = 100/(day_time*10),
        DAPPERNESS_MED = 100/(day_time*6),
        DAPPERNESS_MED_LARGE = 100/(day_time*4.5),
        DAPPERNESS_LARGE = 100/(day_time*3),
        DAPPERNESS_HUGE = 100/(day_time),
        DAPPERNESS_SUPERHUGE = 100/(day_time*0.5),

        MOISTURE_SANITY_PENALTY_MAX = -100/(day_time*6), -- Was originally 10 days

        CRAZINESS_SMALL = -100/(day_time*2),
        CRAZINESS_MED = -100/(day_time),

        RABBIT_RUN_SPEED = 5,
        AUTUMN_LENGTH = 20,
        WINTER_LENGTH = 15,
        SPRING_LENGTH = 20,
        SUMMER_LENGTH = 15,

        SANITY_EFFECT_RANGE = 10,
        SANITY_AURA_SEACH_RANGE = 20,

        SEASON_LENGTH_FRIENDLY_DEFAULT = 20,
        SEASON_LENGTH_HARSH_DEFAULT = 15,

        SEASON_LENGTH_FRIENDLY_VERYSHORT = 5,
        SEASON_LENGTH_FRIENDLY_SHORT = 12,
        SEASON_LENGTH_FRIENDLY_LONG = 30,
        SEASON_LENGTH_FRIENDLY_VERYLONG = 50,
        SEASON_LENGTH_HARSH_VERYSHORT = 5,
        SEASON_LENGTH_HARSH_SHORT = 10,
        SEASON_LENGTH_HARSH_LONG = 22,
        SEASON_LENGTH_HARSH_VERYLONG = 40,

        DIVINING_DISTANCES =
        {
            {maxdist=50, describe="hot", pingtime=1},
            {maxdist=100, describe="warmer", pingtime=2},
            {maxdist=200, describe="warm", pingtime=4},
            {maxdist=400, describe="cold", pingtime=8},
        },
        DIVINING_MAXDIST = 300,
        DIVINING_DEFAULTPING = 8,

        --expressed in 'additional time before you freeze to death'
        INSULATION_TINY = seg_time,
        INSULATION_SMALL = seg_time*2,
        INSULATION_MED = seg_time*4,
        INSULATION_MED_LARGE = seg_time*6,
        INSULATION_LARGE = seg_time*8,
        INSULATION_PER_BEARD_BIT = seg_time*.5,
        WEBBER_BEARD_INSULATION_FACTOR = .75,

        PLAYER_FREEZE_WEAR_OFF_TIME = 3,
        PLAYER_BURN_TIME = 3.3,

        DUSK_INSULATION_BONUS = seg_time*2,
        NIGHT_INSULATION_BONUS = seg_time*4,

        --CROP_BONUS_TEMP = 28,
        MIN_CROP_GROW_TEMP = 5,
        --CROP_HEAT_BONUS = 1,
        CROP_RAIN_BONUS = 3,
        CROP_DARK_WITHER_TIME = total_day_time * 1.5,

        WITHER_BUFFER_TIME = 15,
        MIN_PLANT_WITHER_TEMP = 70,
        MAX_PLANT_WITHER_TEMP = 94, -- max world temperature is 95
        MIN_PLANT_REJUVENATE_TEMP = 45,
        MAX_PLANT_REJUVENATE_TEMP = 55,
        SPRING_GROWTH_MODIFIER = 0.75,

        MIN_TUMBLEWEEDS_PER_SPAWNER = 4,
        MAX_TUMBLEWEEDS_PER_SPAWNER = 7,
        MIN_TUMBLEWEED_SPAWN_PERIOD = total_day_time*.5,
        MAX_TUMBLEWEED_SPAWN_PERIOD = total_day_time*3,
        TUMBLEWEED_REGEN_PERIOD = total_day_time*1.5,

        HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR = 2.1,--1.85,

        DAY_HEAT = 8,
        NIGHT_COLD = -10,
        CAVES_MOISTURE_MULT = 3,--6.5,
        CAVES_TEMP_MULT = 0.6,
        CAVES_TEMP_LOCUS = 0,
        SUMMER_RAIN_TEMP = -20,
        STARTING_TEMP = 35,
        OVERHEAT_TEMP = 70,
        TARGET_SLEEP_TEMP = 35,
        MIN_ENTITY_TEMP = -20,
        MAX_ENTITY_TEMP = 90,
        WARM_DEGREES_PER_SEC = 1,
        THAW_DEGREES_PER_SEC = 5,

        -- Ice Flingomatic emergency mode
        EMERGENCY_BURNT_NUMBER = 2,
        EMERGENCY_BURNING_NUMBER = 5, -- number of fires to maintain warning level one automatically
        EMERGENCY_WARNING_TIME = 3,   -- minimum length of warning period
        EMERGENCY_RESPONSE_TIME = 15, -- BURNT_NUMBER structures must burn within this time period to trigger flingomatic emergency response
        EMERGENCY_SHUT_OFF_TIME = 30, -- stay on for this length of time

        -- The target temperatures for these coolers
        ICEHAT_COOLER = 40,
        WATERMELON_COOLER = 55,
        MINIFAN_COOLER = 55,
        TREE_SHADE_COOLER = 45,
        TREE_SHADE_COOLING_THRESHOLD = 63,

        HOT_FOOD_BONUS_TEMP = 40,
        HOT_FOOD_WARMING_THRESHOLD = 62, --don't actually overheat, but still triggers heat idles
        COLD_FOOD_BONUS_TEMP = -40,
        COLD_FOOD_CHILLING_THRESHOLD = 12,
        FOOD_TEMP_BRIEF = 5,
        FOOD_TEMP_AVERAGE = 10,
        FOOD_TEMP_LONG = 15,

        WET_HEAT_FACTOR_PENALTY = 0.75,

        SPRING_FIRE_RANGE_MOD = 0.67,

        WILDFIRE_THRESHOLD = 80,
        WILDFIRE_CHANCE = 0.2,
        WILDFIRE_RETRY_TIME = seg_time * 1.5,
        MIN_SMOLDER_TIME = .5*seg_time,
        MAX_SMOLDER_TIME = seg_time,

        TENT_USES = 6,
        SIESTA_CANOPY_USES = 6,
        PORTABLE_TENT_USES = 10,

        DAPPER_BEARDLING_SANITY = .3,
        BEARDLING_SANITY = .4,
        UMBRELLA_USES = 20,

        GUNPOWDER_RANGE = 3,
        GUNPOWDER_DAMAGE = 200,
        BIRD_RAIN_FACTOR = .25,

        EXPLOSIVE_MAX_RESIST_DAMAGE = 8000,
        EXPLOSIVE_RESIST_DECAY_TIME = 8,
        EXPLOSIVE_RESIST_DECAY_DELAY = 2,

        RESURRECT_HEALTH = 50,

        SEWINGKIT_USES = 5,
        SEWINGKIT_REPAIR_VALUE = total_day_time*5,

        SEWING_TAPE_REPAIR_VALUE = total_day_time*5,

        RABBIT_CARROT_LOYALTY = seg_time*8,
        RABBIT_POLITENESS_LOYALTY_BONUS = seg_time * 4,
        BUNNYMAN_DAMAGE = 40,
        BEARDLORD_DAMAGE = 60,
        BUNNYMAN_HEALTH = 200,
        BUNNYMAN_ATTACK_PERIOD = 2,
		BUNNYMAN_MAX_STUN_LOCKS = 2,
        BEARDLORD_ATTACK_PERIOD = 1,
        BUNNYMAN_RUN_SPEED = 6,
        BUNNYMAN_WALK_SPEED = 3,
        BUNNYMAN_PANIC_THRESH = .333,
        BEARDLORD_PANIC_THRESH = .25,
        BUNNYMAN_HEALTH_REGEN_PERIOD = 5,
        BUNNYMAN_HEALTH_REGEN_AMOUNT = (200/120)*5,
        BUNNYMAN_SEE_MEAT_DIST = 8,

        CAVE_BANANA_GROW_TIME = 4*total_day_time,
        ROCKY_SPAWN_DELAY = 4*total_day_time,
        ROCKY_SPAWN_VAR = 0,

        ROCKY_DAMAGE = 75,
        ROCKY_HEALTH = 1500 * 2, -- harder for multiplayer
        ROCKY_WALK_SPEED = 2,
        ROCKY_MAX_SCALE = 1.2,
        ROCKY_MIN_SCALE = .75,
        ROCKY_GROW_RATE = (1.2-.75) / (total_day_time*40),
        ROCKY_LOYALTY = seg_time*6,
        ROCKY_POLITENESS_LOYALTY_BONUS = seg_time * 2,
        ROCKY_ABSORB = 0.95,
        ROCKY_REGEN_AMOUNT = 10,
        ROCKY_REGEN_PERIOD = 1,
        ROCKYHERD_RANGE = 40,
        ROCKYHERD_MAX_IN_RANGE = 12,

        MONKEY_MELEE_DAMAGE = 20,
        MONKEY_HEALTH = 125,
        MONKEY_ATTACK_PERIOD = 2,
        MONKEY_MELEE_RANGE = 3,
        MONKEY_RANGED_RANGE = 17,
        MONKEY_MOVE_SPEED = 7,
        MONKEY_NIGHTMARE_CHASE_DIST = 40,

        MOOSE_HEALTH = 3000 * 2, -- harder for multiplayer
        MOOSE_DAMAGE = 150,
        MOOSE_ATTACK_PERIOD = 3,
        MOOSE_ATTACK_RANGE = 5.5,
        MOOSE_WALK_SPEED = 8,
        MOOSE_RUN_SPEED = 12,

        MOOSE_EGG_NUM_MOSSLINGS = 5,
        MOOSE_EGG_HATCH_TIMER = total_day_time * 2,
        MOOSE_EGG_DAMAGE = 10,

        MOSSLING_HEALTH = 350 * 1.5, -- harder for multiplayer
        MOSSLING_DAMAGE = 50,
        MOSSLING_ATTACK_PERIOD = 3,
        MOSSLING_ATTACK_RANGE = 2,
        MOSSLING_WALK_SPEED = 5,

        TOADSTOOL_HEALTH = 52500,
        TOADSTOOL_ATTACK_RANGE = 7,
        TOADSTOOL_EPICSCARE_RANGE = 10,
        TOADSTOOL_DEAGGRO_DIST = 25,
        TOADSTOOL_AGGRO_DIST = 15,
        TOADSTOOL_RESPAWN_TIME = total_day_time * 20,
        TOADSTOOL_SPAWN_TIME = 10,
        SPAWN_TOADSTOOL = true,

        --TOADSTOOL stats are scaled by level [0..3] and phase [1..3]
        TOADSTOOL_SPEED_LVL =
        {
            [0] = .6,
            [1] = .8,
            [2] = 1.2,
            [3] = 3.2,
        },
        TOADSTOOL_DAMAGE_LVL =
        {
            [0] = 100,
            [1] = 120,
            [2] = 150,
            [3] = 250,
        },
        TOADSTOOL_ATTACK_PERIOD_LVL =
        {
            [0] = 3.5,
            [1] = 3,
            [2] = 2.5,
            [3] = 2,
        },
        TOADSTOOL_ABSORPTION_LVL =
        {
            [0] = 0,
            [1] = .2,
            [2] = .4,
            [3] = .8,
        },
        TOADSTOOL_HIT_RECOVERY_LVL =
        {
            [0] = 1,
            [1] = 1.5,
            [2] = 2,
            [3] = 3,
        },

        TOADSTOOL_MUSHROOMBOMB_MIN_RANGE = 4,
        TOADSTOOL_MUSHROOMBOMB_MAX_RANGE = 8.75,
        TOADSTOOL_MUSHROOMBOMB_RADIUS = 3.5,
        TOADSTOOL_MUSHROOMBOMB_CD = 5,
        TOADSTOOL_MUSHROOMBOMB_COUNT_PHASE =
        {
            [1] = 4,
            [2] = 5,
            [3] = 6,
        },
        TOADSTOOL_MUSHROOMBOMB_VAR_LVL =
        {
            [0] = 0,
            [1] = 1,
            [2] = 2,
            [3] = 3,
        },
        TOADSTOOL_MUSHROOMBOMB_CHAIN_LVL =
        {
            [0] = 1,
            [1] = 2,
            [2] = 3,
            [3] = 5,
        },

        TOADSTOOL_SPOREBOMB_ATTACK_RANGE = 10,
        TOADSTOOL_SPOREBOMB_HIT_RANGE = 14,
        TOADSTOOL_SPOREBOMB_TIMER = 3.5,
        TOADSTOOL_SPOREBOMB_TARGETS_PHASE =
        {
            [1] = 1,
            [2] = 2,
            [3] = 2,
        },
        TOADSTOOL_SPOREBOMB_CD_PHASE =
        {
            [1] = 14,
            [2] = 10,
            [3] = 10,
        },

        TOADSTOOL_SPORECLOUD_DAMAGE = 20,
        TOADSTOOL_SPORECLOUD_ROT = .07,
        TOADSTOOL_SPORECLOUD_RADIUS = 3.5,
        TOADSTOOL_SPORECLOUD_TICK = 1,
        TOADSTOOL_SPORECLOUD_LIFETIME = 60,

        TOADSTOOL_MUSHROOMSPROUT_NUM = 8,
        TOADSTOOL_MUSHROOMSPROUT_MIN_RANGE = 6,
        TOADSTOOL_MUSHROOMSPROUT_MAX_RANGE = 10,
        TOADSTOOL_MUSHROOMSPROUT_TICK = 2,
        TOADSTOOL_MUSHROOMSPROUT_DURATION = 15,
        TOADSTOOL_MUSHROOMSPROUT_CD = 45,
        TOADSTOOL_MUSHROOMSPROUT_CHOPS = 10,

        TOADSTOOL_POUND_CD = 20,
        TOADSTOOL_ABILITY_INTRO_CD = 10,

        TOADSTOOL_DARK_HEALTH = 99999,
        TOADSTOOL_DARK_MUSHROOMSPROUT_CHOPS = 14,
        TOADSTOOL_DARK_DAMAGE_LVL =
        {
            [0] = 150,
            [1] = 175,
            [2] = 225,
            [3] = 300,
        },
        TOADSTOOL_DARK_ABSORPTION_LVL =
        {
            [0] = 0,
            [1] = .25,
            [2] = .5,
            [3] = .99,
        },

        BEEQUEEN_HEALTH = 22500,
        BEEQUEEN_DAMAGE = 120,
        BEEQUEEN_ATTACK_PERIOD = 2,
        BEEQUEEN_ATTACK_RANGE = 4,
        BEEQUEEN_HIT_RANGE = 6,
        BEEQUEEN_SPEED = 4,
        BEEQUEEN_HIT_RECOVERY = 1,
        BEEQUEEN_MIN_GUARDS_PER_SPAWN = 4,
        BEEQUEEN_MAX_GUARDS_PER_SPAWN = 5,
        BEEQUEEN_TOTAL_GUARDS = 8,
        BEEQUEEN_CHASE_TO_RANGE = 8,
		BEEQUEEN_MAX_STUN_LOCKS = 4,

        BEEQUEEN_DODGE_SPEED = 6,
        BEEQUEEN_DODGE_HIT_RECOVERY = 2,

        BEEQUEEN_AGGRO_DIST = 15,
        BEEQUEEN_DEAGGRO_DIST = 60,

        BEEQUEEN_RESPAWN_TIME = total_day_time * 20,
        BEEQUEEN_SPAWN_WORK_THRESHOLD = 12,
        BEEQUEEN_SPAWN_MAX_WORK = 16,

        BEEQUEEN_EPICSCARE_RANGE = 10,

        BEEQUEEN_SPAWNGUARDS_CD = { 18, 16, 7, 12 },
        BEEQUEEN_SPAWNGUARDS_CHAIN = { 0, 1, 0, 1 },

        BEEQUEEN_FOCUSTARGET_CD = { 0, 0, 20, 16 },
        BEEQUEEN_FOCUSTARGET_RANGE = 20,

        BEEQUEEN_HONEYTRAIL_SPEED_PENALTY = .4,

        BEEGUARD_HEALTH = 180,
        BEEGUARD_DAMAGE = 30,
        BEEGUARD_ATTACK_PERIOD = 2,
        BEEGUARD_ATTACK_RANGE = 1.5,
        BEEGUARD_SPEED = 3,
        BEEGUARD_GUARD_RANGE = 4,
        BEEGUARD_AGGRO_DIST = 12,

        BEEGUARD_SQUAD_SIZE = 3,
        BEEGUARD_DASH_SPEED = 8,
        BEEGUARD_PUFFY_DAMAGE = 40,
        BEEGUARD_PUFFY_ATTACK_PERIOD = 1.5,

        DRAGONFLY_RESPAWN_TIME = total_day_time * 20,
        DRAGONFLY_SPAWN_TIME = 1,
        SPAWN_DRAGONFLY = true,

        DRAGONFLY_HEALTH = 27500,
        DRAGONFLY_DAMAGE = 150,
        DRAGONFLY_ATTACK_PERIOD = 4,
        DRAGONFLY_ATTACK_RANGE = 4,
        DRAGONFLY_HIT_RANGE = 5,
        DRAGONFLY_SPEED = 5,

        DRAGONFLY_FIRE_ATTACK_PERIOD = 3,
        DRAGONFLY_FIRE_DAMAGE = 300,
        DRAGONFLY_FIRE_HIT_RANGE = 6,
        DRAGONFLY_FIRE_SPEED = 7,

        DRAGONFLY_RESET_DIST = 60,
        DRAGONFLY_AGGRO_DIST = 15,

        DRAGONFLY_STUN = 1250,
        DRAGONFLY_STUN_PERIOD = 5,
        DRAGONFLY_STUN_DURATION = 10,
        DRAGONFLY_STUN_COOLDOWN = 60,
        DRAGONFLY_STUN_RESIST = 250,

        DRAGONFLY_ENRAGE_DURATION = 60,
        DRAGONFLY_BREAKOFF_DAMAGE = 2500,

        DRAGONFLY_FREEZE_RESIST = 100,
        DRAGONFLY_POUND_CD = 20,
        DRAGONFLY_HIT_RECOVERY = 2,
        DRAGONFLY_FLYING_HIT_RECOVERY = 4,

        DRAGONFLY_FREEZE_THRESHOLD = 8,
        DRAGONFLY_ENRAGED_FREEZE_THRESHOLD = 12,

        LAVAE_HEALTH = 500,
        LAVAE_DAMAGE = 50,
        LAVAE_ATTACK_PERIOD = 4,
        LAVAE_HIT_RANGE = 3,
        LAVAE_ATTACK_RANGE = 6,
        LAVAE_HUNGER_RATE = 50/total_day_time,
        LAVAE_LIFESPAN = 30,

        LAVAE_HATCH_CRACK_TIME = 10,
        LAVAE_HATCH_TIME = total_day_time*2,
        LAVAE_HATCH_FAIL_TIME = night_time,

        BEARGER_HEALTH = 3000 * 2, -- harder for multiplayer
        BEARGER_DAMAGE = 200,
        BEARGER_ATTACK_PERIOD = 3,
        BEARGER_MELEE_RANGE = 6,
        BEARGER_ATTACK_RANGE = 6,
        BEARGER_CALM_WALK_SPEED = 3,
        BEARGER_ANGRY_WALK_SPEED = 6,
        BEARGER_RUN_SPEED = 10,
        BEARGER_DISGRUNTLE_TIME = 30,
        BEARGER_STOLEN_TARGETS_FOR_AGRO = 3,
        BEARGER_GROWL_INTERVAL = 10,
        BEARGER_SHORT_TRAVEL = 30,
        BEARGER_LONG_TRAVEL = 400,
        BEARGER_SHED_INTERVAL = 45, -- time in seconds
        BEARGER_ATTACK_CONE_WIDTH = math.pi/2,
        BEARGER_NORMAL_GROUNDPOUND_COOLDOWN = 10,
        BEARGER_MAX_CHASE_TIME = 9.5, -- important that this is less than the groundpound cooldown, to avoid an infinite chase
        BEARGER_YAWN_COOLDOWN = 14,
        BEARGER_YAWN_RANGE = 25,
        BEARGER_YAWN_SLEEPTIME = 10,

        LIGHTER_ATTACK_IGNITE_PERCENT = .5,
        LIGHTER_DAMAGE = wilson_attack*.5,
        WILLOW_LIGHTFIRE_SANITY_THRESH = .5,

        WOLFGANG_HUNGER = 200,
        WOLFGANG_START_HUNGER = 200,
        WOLFGANG_START_MIGHTY_THRESH = 225,
        WOLFGANG_END_MIGHTY_THRESH = 220,
        WOLFGANG_START_WIMPY_THRESH = 100,
        WOLFGANG_END_WIMPY_THRESH = 105,

        WOLFGANG_HUNGER_RATE_MULT_MIGHTY = 3,
        WOLFGANG_HUNGER_RATE_MULT_NORMAL = 1.5,
        WOLFGANG_HUNGER_RATE_MULT_WIMPY = 1,

		WOLFGANG_HEALTH = 200, -- this is used for the character descriptions, gameplay uses WOLFGANG_HEALTH_NORMAL
        WOLFGANG_HEALTH_MIGHTY = 300,
        WOLFGANG_HEALTH_NORMAL = 200,
        WOLFGANG_HEALTH_WIMPY = 150,

		WOLFGANG_SANITY = wilson_sanity,

        WOLFGANG_ATTACKMULT_MIGHTY_MAX = 2,
        WOLFGANG_ATTACKMULT_MIGHTY_MIN = 1.25,
        WOLFGANG_ATTACKMULT_NORMAL = 1,
        WOLFGANG_ATTACKMULT_WIMPY_MAX = .75,
        WOLFGANG_ATTACKMULT_WIMPY_MIN = .5,

        WATHGRITHR_HEALTH = 200,
        WATHGRITHR_SANITY = 120,
        WATHGRITHR_HUNGER = 120,
        WATHGRITHR_DAMAGE_MULT = 1.25,
        WATHGRITHR_ABSORPTION = 0.25,

        WEBBER_HEALTH = 175,
        WEBBER_SANITY = 100,
        WEBBER_HUNGER = 175,

		WENDY_HEALTH = wilson_health,
		WENDY_HUNGER = wilson_hunger,
        WENDY_SANITY = wilson_sanity,

        WENDY_DAMAGE_MULT = .75,
        WENDY_SANITY_MULT = .75,

		WES_HEALTH = math.ceil(wilson_health * .5),
		WES_HUNGER = math.ceil(wilson_hunger * .5),
        WES_SANITY = math.ceil(wilson_sanity * .375),
        WES_DAMAGE_MULT = .75,
		WES_GROGGINESS_DECAY_RATE = 0.01 * 0.75, --GROGGINESS_DECAY_RATE = .01,
		WES_WORKEFFECTIVENESS_MODIFIER = 0.75,
		WES_HOUND_TARGET_MULT = 2.0,

		WAXWELL_HEALTH = math.ceil(wilson_health * .5),
		WAXWELL_HUNGER = wilson_hunger,
        WAXWELL_SANITY = wilson_sanity,

        WICKERBOTTOM_HEALTH = wilson_health,
        WICKERBOTTOM_HUNGER = wilson_hunger,
        WICKERBOTTOM_SANITY = 250,
        WICKERBOTTOM_STALE_FOOD_HUNGER = .333,
        WICKERBOTTOM_SPOILED_FOOD_HUNGER = .167,
        WICKERBOTTOM_STALE_FOOD_HEALTH = .25,
        WICKERBOTTOM_SPOILED_FOOD_HEALTH = 0,

		WALTER_HEALTH = 130,
		WALTER_HUNGER = 110,
        WALTER_SANITY = wilson_sanity,

		WANDA_OLDAGER = 60, -- 20 to 80 yo
		OLDAGE_HEALTH_SCALE = 60/150, -- WANDA_OLDAGER / WILSON_HEALTH
        WANDA_HUNGER = 175,
        WANDA_SANITY = wilson_sanity,

		CHARACTER_DETAILS_OVERRIDE =
		{
			wanda_health = "oldager",
		},

        FISSURE_CALMTIME_MIN = 600,
        FISSURE_CALMTIME_MAX = 1200,
        FISSURE_WARNTIME_MIN = 20,
        FISSURE_WARNTIME_MAX = 30,
        FISSURE_NIGHTMARETIME_MIN = 160,
        FISSURE_NIGHTMARETIME_MAX = 260,
        FISSURE_DAWNTIME_MIN = 30,
        FISSURE_DAWNTIME_MAX = 45,

        EYETURRET_DAMAGE = 65,
        EYETURRET_HEALTH = 1000,
        EYETURRET_REGEN = 12,
        EYETURRET_RANGE = 15,
        EYETURRET_ATTACK_PERIOD = 3,

        NIGHTMARE_SEGS =
        {
            CALM = 12,
            WARN = 3,
            WILD = 5,
            DAWN = 2,
        },
        NIGHTMARE_SEG_VARIATION = 3,

        SHADOWWAXWELL_SPEED = 6,
        SHADOWWAXWELL_DAMAGE = 40,
        SHADOWWAXWELL_LIFE = 75,
        SHADOWWAXWELL_ATTACK_PERIOD = 2,
        SHADOWWAXWELL_HEALTH_REGEN = 15,
        SHADOWWAXWELL_HEALTH_REGEN_PERIOD = 2,
        SHADOWWAXWELL_TARGET_DIST = 10,

        SHADOWWAXWELL_SANITY_PENALTY =
        {
            SHADOWLUMBER = .2,
            SHADOWMINER = .2,
            SHADOWDIGGER = .2,
            SHADOWDUELIST = .35,
        },

        LIVINGTREE_CHANCE = 0.55,
        LIVINGTREE_YOUNG_WORK = 15,
        LIVINGTREE_YOUNG_GROW_TIME = 3 * day_time,
        LIVINGTREE_WORK = 20,
        LIVINGTREE_EXTRA_SPACING = 4,

        HALLOWEEN_ORNAMENT_TUMBLEWEED_CHANCE = 0.1,
		HALLOWEEN_ORNAMENT_FLOTSAM_CHANCE = 0.1,
        HALLOWEENPOTION_FIREFX_FUEL_MOD = .8,
        HALLOWEENPOTION_FIREFX_DURATION = seg_time * 8,

        -- Birchnut monster chances have been reduced and tied to seasons instead of the number of days to balance things out for dedicated servers (which may be running for extremely long times)
        DECID_MONSTER_MIN_DAY = 3, -- No monsters during the first few days
        DECID_MONSTER_SPAWN_CHANCE_AUTUMN = .15,    -- high chance of monsters in autumn to cancel out double birchnut and general easyness of autumn
        DECID_MONSTER_SPAWN_CHANCE_SPRING = .08, -- next highest in spring because everything attacks in spring
        DECID_MONSTER_SPAWN_CHANCE_SUMMER = .033, -- low chance in summer since summer is hard anyway
        DECID_MONSTER_SPAWN_CHANCE_WINTER = 0, -- can't make monsters in winter, they have to have leaves
        DECID_MONSTER_DAY_THRESHOLDS = { 20, 35, 70 }, -- Ramp monster spawns a bit over time
        DECID_MONSTER_SPAWN_CHANCE_MOD = { .2, .5, 1, 1.12 },

        DECID_MONSTER_TARGET_DIST = 7,
        DECID_MONSTER_ATTACK_PERIOD = 2.3,
        DECID_MONSTER_ROOT_ATTACK_RADIUS = 3.7,
        DECID_MONSTER_DAMAGE = 30,
        DECID_MONSTER_ADDITIONAL_LOOT_CHANCE = .2,
        DECID_MONSTER_DURATION = total_day_time*.5,
        MIN_TREE_DRAKES = 3,
        MAX_TREE_DRAKES = 5,
        PASSIVE_DRAKE_SPAWN_NUM_NORMAL = 1,
        PASSIVE_DRAKE_SPAWN_NUM_LARGE = 2,
        PASSIVE_DRAKE_SPAWN_INTERVAL = 12,
        PASSIVE_DRAKE_SPAWN_INTERVAL_VARIANCE = 3,

        DECID_MONSTER_ACORN_CHILL_RADIUS = 30,

        WET_TIME =  10, --seg_time,
        DRY_TIME = 10, --seg_time * 2,
        WET_ITEM_DAPPERNESS = -0.1,
        WET_EMPTY_SLOT_DAPPERNESS = -0.2,

        MOISTURE_TEMP_PENALTY = 30,
        MOISTURE_WET_THRESHOLD = 35,
        MOISTURE_DRY_THRESHOLD = 15,
        SLEEP_MOISTURE_DELTA = 30,

        FIRE_DETECTOR_PERIOD = 1,
        FIRE_DETECTOR_RANGE = 15,
        FIRESUPPRESSOR_RELOAD_TIME = 3,
        FIRESUPPRESSOR_MAX_FUEL_TIME = total_day_time*5,
        FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT = -4,
        FIRESUPPRESSOR_TEMP_REDUCTION = 5,
        FIRESUPPRESSOR_PROTECTION_TIME = 60,
        FIRESUPPRESSOR_ADD_COLDNESS = 2,
        SMOTHERER_EXTINGUISH_HEAT_PERCENT = .2,

        WATERBALLOON_EXTINGUISH_HEAT_PERCENT = -1,
        WATERBALLOON_TEMP_REDUCTION = 5,
        WATERBALLOON_ADD_WETNESS = 20,
        WATERBALLOON_PROTECTION_TIME = 30,

        WATERPROOFNESS_SMALL = 0.2,
        WATERPROOFNESS_SMALLMED = 0.35,
        WATERPROOFNESS_MED = 0.5,
        WATERPROOFNESS_LARGE = 0.7,
        WATERPROOFNESS_HUGE = 0.9,
        WATERPROOFNESS_ABSOLUTE = 1,

        CATCOONDEN_MAXCHILDREN = 1,
        CATCOONDEN_REGEN_TIME = seg_time * 4,
        CATCOONDEN_RELEASE_TIME = seg_time * 0.5,
        CATCOONDEN_ENABLED = true,
		CATCOONDEN_INV_SIZE = 20,
		CATCOONDEN_REPAIR_TIME = 15 * total_day_time,
		CATCOONDEN_REPAIR_TIME_VAR = 5 * total_day_time,

        CATCOON_ATTACK_RANGE = 4,
        CATCOON_MELEE_RANGE = 3,
        CATCOON_TARGET_DIST = 25,
        CATCOON_SPEED = 3,
        CATCOON_DAMAGE = 25,
        CATCOON_LIFE = 150,
        CATCOON_ATTACK_PERIOD = 2,
        CATCOON_LOYALTY_MAXTIME = total_day_time,
        CATCOON_LOYALTY_PER_ITEM = total_day_time*.1,
        CATCOON_MIN_HAIRBALL_TIME_FRIENDLY = .25 * total_day_time,
        CATCOON_MAX_HAIRBALL_TIME_FRIENDLY = total_day_time,
        CATCOON_MIN_HAIRBALL_TIME_BASE = .75 * total_day_time,
        CATCOON_MAX_HAIRBALL_TIME_BASE = 1.5 * total_day_time,
        MIN_CATNAP_INTERVAL = 30,
        MAX_CATNAP_INTERVAL = 120,
        MIN_CATNAP_LENGTH = 20,
        MAX_CATNAP_LENGTH = 40,
        MIN_HAIRBALL_FRIEND_INTERVAL = 30,
        MAX_HAIRBALL_FRIEND_INTERVAL = 90,
        MIN_HAIRBALL_NEUTRAL_INTERVAL = .5*total_day_time,
        MAX_HAIRBALL_NEUTRAL_INTERVAL = total_day_time,
        CATCOON_PICKUP_ITEM_CHANCE = .67,
        CATCOON_ATTACK_CONNECT_CHANCE = .25,
		CATCOON_ACTIVATE_CONNECT_CHANCE = 0.25,
		CATCOON_DEN_LEASH_MAX_DIST = 30,

        CATCOONDEN_REGROWTH_TIME = day_time * 15,
        CATCOONDEN_REGROWTH_TIME_SPRING_MULT = 0.5,
        CATCOONDEN_REGROWTH_TIME_AUTUMN_MULT = 1,

        GRASSGEKKO_LIFE = 150,
        GRASSGEKKO_WALK_SPEED = 1, --0.5
        GRASSGEKKO_RUN_SPEED = 10,
        GRASSGEKKO_REGROW_TIME = total_day_time*2,
        GRASSGEKKO_REGROW_INCREASE = total_day_time*.5,
        GRASSGEKKO_REGROW_VARIANCE = total_day_time,
        GRASSGEKKO_CYCLES = 3,
        GRASSGEKKO_MORPH_DELAY = total_day_time * 25,
        GRASSGEKKO_MORPH_DELAY_VARIANCE = total_day_time * 5,
        GRASSGEKKO_MORPH_CHANCE = 1 / 100,
        GRASSGEKKO_MORPH_ENABLED = true,
        GRASSGEKKO_DENSITY_RANGE = 20,
        GRASSGEKKO_MAX_DENSITY = 6,

        FERTILIZER_USES = 10,

        GLOMMERBELL_USES = 3,

        CLAYWARG_RUNSPEED = 5.5,
        WARG_RUNSPEED = 5.5,
        WARG_HEALTH = 600 * 3, --harder for multiplayer
        WARG_DAMAGE = 50,
        WARG_ATTACKPERIOD = 3,
        WARG_ATTACKRANGE = 4,
        WARG_FOLLOWERS = 6,
        WARG_SUMMONPERIOD = 15,
        WARG_MAXHELPERS = 10,
        WARG_TARGETRANGE = 10,
        WARG_NEARBY_PLAYERS_DIST = 30,
        WARG_BASE_HOUND_AMOUNT = 2,

        WARGLET_HEALTH = 600,
        WARGLET_BASE_HOUND_AMOUNT = 1,
        WARGLET_MAX_HOUND_AMOUNT = 3,

        SMOTHER_DAMAGE = 3,

        TORNADO_WALK_SPEED = 25,
        TORNADO_DAMAGE = 7,
        TORNADO_LIFETIME = 5,
        TORNADOSTAFF_USES = 15,

        FEATHERFAN_USES = 15,
        FEATHERFAN_COOLING = -50,
        FEATHERFAN_RADIUS = 7,
        FEATHERFAN_MINIMUM_TEMP = 2.5,

        NO_BOSS_TIME = 26,  -- 1.5 seasons

        HAUNT_COOLDOWN_TINY = 1,
        HAUNT_COOLDOWN_SMALL = 3,
        HAUNT_COOLDOWN_MEDIUM = 5,
        HAUNT_COOLDOWN_LARGE = 7,
        HAUNT_COOLDOWN_HUGE = 10,

        HAUNT_CHANCE_ALWAYS = 1,
        HAUNT_CHANCE_OFTEN = .75,
        HAUNT_CHANCE_HALF = .5,
        HAUNT_CHANCE_OCCASIONAL = .25,
        HAUNT_CHANCE_RARE = .1,
        HAUNT_CHANCE_VERYRARE = .005,
        HAUNT_CHANCE_SUPERRARE = .001,

        HAUNT_TINY = 1,
        HAUNT_SMALL = 3,
        HAUNT_MEDIUM = 5,
        HAUNT_MEDLARGE = 7,
        HAUNT_LARGE = 10,
        HAUNT_HUGE = 15,
        HAUNT_INSTANT_REZ = 9999,

        LAUNCH_SPEED_SMALL = 3,
        LAUNCH_SPEED_MEDIUM = 5,
        LAUNCH_SPEED_LARGE = 7,

        HAUNT_PANIC_TIME_SMALL = 3,
        HAUNT_PANIC_TIME_MEDIUM = 5,
        HAUNT_PANIC_TIME_LARGE = 7,

        SLEEP_TICK_PERIOD = 1,
        SLEEP_SANITY_PER_TICK = 1,
        SLEEP_HUNGER_PER_TICK = -1,
        SLEEP_HEALTH_PER_TICK = 1,

        EFFICIENT_SLEEP_SANITY_MULT = 1,
        EFFICIENT_SLEEP_HUNGER_MULT = 0.5,
        EFFICIENT_SLEEP_HEALTH_MULT = 1,

        SLEEP_TEMP_PER_TICK = 1,
        SLEEP_WETNESS_PER_TICK = -1,
        SLEEP_TARGET_TEMP_TENT = 40,
        SLEEP_TARGET_TEMP_BEDROLL_FURRY = 30,


        PVP_DAMAGE_MOD = .5,

        MIN_INDICATOR_RANGE = 20,
        MAX_INDICATOR_RANGE = 50,

        METEOR_DAMAGE = 50,
        METEOR_RADIUS = 3.5,
        METEOR_SMASH_INVITEM_CHANCE = .75,

        METEOR_MEDIUM_CHANCE = .4,
        METEOR_LARGE_CHANCE = .2,

        METEOR_CHANCE_INVITEM_ALWAYS = 1,
        METEOR_CHANCE_INVITEM_OFTEN = .6,
        METEOR_CHANCE_INVITEM_SOMETIMES = .4,
        METEOR_CHANCE_INVITEM_OCCASIONAL = .3,
        METEOR_CHANCE_INVITEM_RARE = .2,
        METEOR_CHANCE_INVITEM_VERYRARE = .12,
        METEOR_CHANCE_INVITEM_SUPERRARE = .05,

        METEOR_CHANCE_BOULDERROCK = 1,
        METEOR_CHANCE_BOULDERFLINTLESS = .3,
        METEOR_CHANCE_BOULDERMOON = .15,

        METEOR_SHOWER_SPAWN_RADIUS = 60,
        METEOR_SHOWER_CLEANUP_BUFFER = 10,

        METEOR_SHOWER_OFFSCREEN_MOD = .5,

        METEOR_SHOWER_LVL1_BASETIME = total_day_time*6,
        METEOR_SHOWER_LVL1_VARTIME = total_day_time*4,
        METEOR_SHOWER_LVL2_BASETIME = total_day_time*9,
        METEOR_SHOWER_LVL2_VARTIME = total_day_time*6,
        METEOR_SHOWER_LVL3_BASETIME = total_day_time*12,
        METEOR_SHOWER_LVL3_VARTIME = total_day_time*8,

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

		MOONROCKSHELL_CHANCE = 0.34,

        GROGGINESS_DECAY_RATE = .01,
        GROGGINESS_WEAR_OFF_DURATION = .5,
        MIN_KNOCKOUT_TIME = 10,
        MIN_GROGGY_SPEED_MOD = .4,
        MAX_GROGGY_SPEED_MOD = .6,

        GHOST_DECAY_RATE = 80,--4,

        AFK_TIME = 5,
        AFK_TIME_GHOST = 0.5,

        CARROT_REGROWTH_TIME = day_time * 20,
        CARROT_REGROWTH_TIME_MULT = 1,
        FLOWER_REGROWTH_TIME = 30,
        FLOWER_REGROWTH_TIME_MULT = 1,
        FLOWER_WITHER_IN_CAVE_LIGHT = 0.05,
        RABBITHOLE_REGROWTH_TIME = total_day_time * 5,
        FLOWER_CAVE_REGROWTH_TIME = total_day_time * 5,
        FLOWER_CAVE_REGROWTH_TIME_MULT = 1,
        REEDS_REGROWTH_TIME = total_day_time * 5,

        EVERGREEN_REGROWTH = {
            OFFSPRING_TIME = total_day_time * 5,
            DESOLATION_RESPAWN_TIME = total_day_time * 50,
            DEAD_DECAY_TIME = total_day_time * 30,
        },

        EVERGREEN_SPARSE_REGROWTH = {
            OFFSPRING_TIME = total_day_time * 8,
            DESOLATION_RESPAWN_TIME = total_day_time * 50,
            DEAD_DECAY_TIME = total_day_time * 30,
        },

        TWIGGY_TREE_REGROWTH = {
            OFFSPRING_TIME = total_day_time * 8,
            DESOLATION_RESPAWN_TIME = total_day_time * 50,
            DEAD_DECAY_TIME = total_day_time * 30,
        },

        DECIDUOUS_REGROWTH = {
            OFFSPRING_TIME = total_day_time * 3,
            DESOLATION_RESPAWN_TIME = total_day_time * 50,
            DEAD_DECAY_TIME = total_day_time * 30,
        },

        MUSHTREE_REGROWTH = {
            OFFSPRING_TIME = total_day_time * 3,
            DESOLATION_RESPAWN_TIME = total_day_time * 50,
            DEAD_DECAY_TIME = total_day_time * 30,
        },

        REGROWTH_TIME_MULTIPLIER = 1,

        TALLBIRD_ATTACK_AGGRO_TIMEOUT = 2,
        TENTACLE_ATTACK_AGGRO_TIMEOUT = 2,

        MAX_PLAYER_SKELETONS = 100,

        STUNLOCK_TIMES = {
            OFTEN = 0.5,
            SOMETIMES = 1.0,
            RARELY = 1.5,
        },

        ANCIENT_ALTAR_COMPLETE_WORK = 1,
        ANCIENT_ALTAR_BROKEN_WORK = 9,

        CAVE_LIGHT_WAKE_TIME = 4.0,

        HUTCH_RADIUS = 1.5,
        HUTCH_DMG_PERIOD = 1.2,
        HUTCH_PRICKLY_DAMAGE = 30,

        NUM_PREFAB_SWAPS = 0,

        ACHIEVEMENT_RADIUS_FOR_GIANT_KILL = 30,
        ACHIEVEMENT_PIG_POSSE_SIZE = 6,
        ACHIEVEMENT_ROCKY_POSSE_SIZE = 4,
        ACHIEVEMENT_HOST_FOR_DAYS = 40,
        ACHIEVEMENT_HELPOUT_GIVER_MIN_AGE = 20,
        ACHIEVEMENT_HELPOUT_RECEIVER_MAX_AGE = 2,

        PETRIFICATION_CYCLE =
        {
            MIN_YEARS = .6,
            MAX_YEARS = .9,
        },

        DISEASE_SPREAD_RADIUS = 4,
        DISEASE_SPREAD_TIME = total_day_time * 2,
        DISEASE_SPREAD_TIME_VARIANCE = total_day_time * .5,
        DISEASE_DELAY_TIME = total_day_time * 50,
        DISEASE_DELAY_TIME_VARIANCE = total_day_time * 20,
        DISEASE_WARNING_TIME = total_day_time * 5,
        DISEASE_WARNING_TIME_VARIANCE = total_day_time,
        DISEASE_CHANCE = .1,

        SALTLICK_CHECK_DIST = 20,
        SALTLICK_USE_DIST = 4,
        SALTLICK_DURATION = total_day_time / 8,
        SALTLICK_MAX_LICKS = 240, -- 15 days @ 8 beefalo licks per day
        SALTLICK_BEEFALO_USES = 2,
        SALTLICK_KOALEFANT_USES = 4,        
        SALTLICK_LIGHTNINGGOAT_USES = 1,
        SALTLICK_DEER_USES = 1,
        SALTLICK_GRASSGATOR_USES = 4,

        ANTLION_HEALTH = 6000,
        ANTLION_MAX_ATTACK_PERIOD = 4,
        ANTLION_MIN_ATTACK_PERIOD = 2,
        ANTLION_SPEED_UP = -.2,
        ANTLION_SLOW_DOWN = .4,
        ANTLION_CAST_RANGE = 15,
        ANTLION_CAST_MAX_RANGE = 20,
        ANTLION_WALL_CD = 20,
        ANTLION_HIT_RECOVERY = 1,
        ANTLION_EAT_HEALING = 200,

        ANTLION_SINKHOLE_WORKTOREPAIR = 3,
        ANTLION_SINKHOLE =
        {
            RADIUS = 2.5,
            UNEVENGROUND_RADIUS = 3,

            WAVE_MAX_ATTACKS = 5,
            WAVE_MIN_ATTACKS = 2,
            WAVE_ATTACK_DELAY = .75,
            WAVE_ATTACK_DELAY_VARIANCE = 1,
            WAVE_MERGE_ATTACKS_DIST_SQ = math.pow(4 * 3, 2), -- 4 == TILE_SCALE

            NUM_WARNINGS = 12,
            WARNING_DELAY = 1,
            WARNING_DELAY_VARIANCE = .3,

            ATTACK_SEQUENCE_INITIAL_DELAY = 1 * total_day_time,
            ATTACK_SEQUENCE_INITIAL_DELAY_VARIANCE = 1 * total_day_time,
            ATTACK_SEQUENCE_NEXT_WAVE_DELAY = .35 * total_day_time, -- useage: val * remaing days in season
            ATTACK_SEQUENCE_NEXT_WAVE_DELAY_VARIANCE = 1 * total_day_time,

            DAMAGE = 30,

            REPAIR_TIME_VARIANCE = 1 * total_day_time,
            REPAIR_TIME = -- Note: these times are used from last to first
            {
				4 * total_day_time,
				5 * total_day_time,
				21 * total_day_time,
            },
        },

        ANTLION_RAGE_TIME_INITIAL = 4.2 * total_day_time,
        ANTLION_RAGE_TIME_MIN = 1 * total_day_time,
        ANTLION_RAGE_TIME_MAX = 6 * total_day_time,
        ANTLION_RAGE_TIME_FAILURE_SCALE = 0.8,
        ANTLION_TRIBUTE_TO_RAGE_TIME = .33 * total_day_time,
        ANTLION_RAGE_TIME_UNHAPPY_PERCENT = 0.6,
        ANTLION_RAGE_TIME_HAPPY_PERCENT = 0.95,
        ANTLION_TRIBUTER_TALKER_TIME = 8,
        ANTLION_TRIBUTE = true,

        SANDSTORM_OASIS_RADIUS = 1,
        SANDSTORM_FULLY_ENTERED_DEPTH = 20,
        SANDSTORM_FULL_LEVEL = .7,
        SANDSTORM_VISION_RANGE_SQ = 25,
        SANDSTORM_SPEED_MOD = .4,

        SANDSPIKE =
        {
            HEALTH =
            {
                SHORT = 25,
                MED = 65,
                TALL = 100,
                BLOCK = 250,
            },
            DAMAGE =
            {
                SHORT = 100,
                MED = 150,
                TALL = 200,
                BLOCK = 0,
            },
            LIFETIME =
            {
                SHORT = { 6, 7 },
                MED = { 7, 8 },
                TALL = { 8, 10 },
                BLOCK = { 15, 16 },
            },
        },

        OASISLAKE_MAX_FISH = 15,
        OASISLAKE_FISH_RESPAWN_TIME = seg_time * 3,

        CAREFUL_SPEED_MOD = .3,

        STALKER_HEALTH = 4000,
        STALKER_DAMAGE = 200,
        STALKER_ATTACK_PERIOD = 4,
        STALKER_ATTACK_RANGE = 2.4,
        STALKER_HIT_RANGE = 3.8,
        STALKER_AOE_RANGE = 2,
        STALKER_AOE_SCALE = .8,
        STALKER_SPEED = 4.2,
        STALKER_HIT_RECOVERY = 1.5,

        STALKER_ABILITY_RETRY_CD = 3,

        STALKER_SNARE_RANGE = 12,
        STALKER_SNARE_MAX_RANGE = 15,
        STALKER_SNARE_TIME = 6,
        STALKER_SNARE_TIME_VARIANCE = .5,
        STALKER_MAX_SNARES = 6,
        STALKER_SNARE_CD = 10,
        STALKER_FIRST_SNARE_CD = 5,

        STALKER_AGGRO_DIST = 15,
        STALKER_KEEP_AGGRO_DIST = 9,
        STALKER_DEAGGRO_DIST = 30,
        STALKER_EPICSCARE_RANGE = 10,

        STALKER_BLOOM_DECAY = 5,

        STALKER_ATRIUM_HEALTH = 16000,
        STALKER_ATRIUM_PHASE2_HEALTH = 10000,
        STALKER_ATRIUM_ATTACK_PERIOD = 3,

        FOSSIL_SPIKE_DAMAGE = 100,
        STALKER_SPIKES_CD = 8,
        STALKER_FIRST_SPIKES_CD = 4,

        STALKER_CHANNELERS_COUNT = 6,
        STALKER_CHANNELERS_CD = 20,
        STALKER_FIRST_CHANNELERS_CD = 5,

        STALKER_FEAST_HEALING = 400,
        STALKER_MINIONS_LIFESPAN = 45,
        STALKER_MINIONS_LIFESPAN_VARIANCE = 5,
        STALKER_MINIONS_COUNT = 20,
        STALKER_MINIONS_CD = 20,
        STALKER_FIRST_MINIONS_CD = 5,

        STALKER_MINDCONTROL_RANGE = 15,
        STALKER_MINDCONTROL_DURATION = 3.5,
        STALKER_MINDCONTROL_CD = 15,
        STALKER_FIRST_MINDCONTROL_CD = 5,

        THURIBLE_FUEL_MAX = (night_time + dusk_time) * 3,
        THURIBLE_AOE_RANGE = 6,

        ATRIUM_GATE_DESTABILIZE_DELAY = 12,
        ATRIUM_GATE_DESTABILIZE_TIME = seg_time * 8,
        ATRIUM_GATE_DESTABILIZE_WARNING_TIME = seg_time * 0.55,
        ATRIUM_GATE_DESTABILIZE_INITIAL_WARNING_DELAY = 2, -- this is the time after ATRIUM_GATE_DESTABILIZE_DELAY that the first pulse will happen
        ATRIUM_GATE_COOLDOWN = total_day_time * 20,

        LAVAARENA_STARTING_HEALTH =
        {
            WILSON = 150,
            WILLOW = 125,
            WENDY = 125,
            WOLFGANG = 200,
            WX78 = 150,
            WICKERBOTTOM = 125,
            WES = 100,
            WAXWELL = 75,
            WOODIE = 200,
            WATHGRITHR = 150,
            WEBBER = 150,
            WINONA = 200,
            WORTOX = 200, --VITO do something here
            WORMWOOD = 200, --TODO
            WARLY = 200, --TODO
            WURT = 200, --TODO
            WALTER = 200, --TODO
            WANDA = 200, --TODO
        },

		GAMEMODE_STARTING_ITEMS =
		{
		    DEFAULT =
			{
				WILSON = {},
				WILLOW = {"lighter", "bernie_inactive"},
				WENDY = {"abigail_flower"},
				WOLFGANG = {"dumbbell"},
				WX78 = {"wx78_scanner_item", "wx78_moduleremover"},
				WICKERBOTTOM = {"papyrus", "papyrus"},
				WES = {"balloons_empty"},
				WAXWELL = {"waxwelljournal", "nightmarefuel", "nightmarefuel", "nightmarefuel", "nightmarefuel", "nightmarefuel", "nightmarefuel"},
				WOODIE = {"lucy"},
				WATHGRITHR = {"spear_wathgrithr", "wathgrithrhat", "meat", "meat", "meat", "meat"},
				WEBBER = {"spidereggsack", "monstermeat", "monstermeat", "spider_whistle"},
				WINONA = {"sewing_tape", "sewing_tape", "sewing_tape"},
                WORTOX = {"wortox_soul", "wortox_soul", "wortox_soul", "wortox_soul", "wortox_soul", "wortox_soul"},
                WORMWOOD = {},
                WARLY = {"portablecookpot_item", "potato", "potato", "garlic"},
                WURT = {},
                WALTER = {"walterhat", "slingshot", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock", "slingshotammo_rock"},
                WANDA = {"pocketwatch_heal", "pocketwatch_parts", "pocketwatch_parts", "pocketwatch_parts"},
			},

			LAVAARENA =
			{
				WILSON = { "blowdart_lava", "lavaarena_armormedium" },
				WILLOW = { "blowdart_lava", "lavaarena_armorlightspeed" },
				WENDY = { "blowdart_lava", "lavaarena_armorlightspeed" },
				WOLFGANG = { "hammer_mjolnir", "lavaarena_armormedium" },
				WX78 = { "hammer_mjolnir", "lavaarena_armormedium" },
				WICKERBOTTOM = { "book_fossil", "lavaarena_armorlight" },
				WES = { "blowdart_lava", "lavaarena_armorlightspeed" },
				WAXWELL = { "book_fossil", "lavaarena_armorlight" },
				WOODIE = { "lavaarena_lucy", "lavaarena_armormedium" },
				WATHGRITHR = { "spear_gungnir", "lavaarena_armorlightspeed" },
				WEBBER = { "blowdart_lava", "lavaarena_armorlightspeed" },
				WINONA = { "hammer_mjolnir", "lavaarena_armormedium" },
                WORTOX = {}, --VITO do something here
                WORMWOOD = {}, --TODO
                WARLY = {}, --TODO
                WURT = {}, -- TODO
                WALTER = {}, -- TODO
                WANDA = {}, -- TODO
			},
			QUAGMIRE =
			{
				WILSON = {},
				WILLOW = {},
				WENDY = { "spoiled_food" },
				WOLFGANG = {},
				WX78 = {},
				WICKERBOTTOM = {},
				WES = {},
				WAXWELL = {},
				WOODIE = {},
				WATHGRITHR = {},
				WEBBER = {},
				WINONA = {},
                WORTOX = {}, --VITO do something here
                WORMWOOD = {}, --TODO
                WARLY = {}, --TODO
                WURT = {}, -- TODO
                WALTER = {}, -- TODO
                WANDA = {}, -- TODO
			},
		},

		MAX_PINNED_RECIPES = 9,
		DEFAULT_PINNED_RECIPES = {"torch", "campfire", "axe", "pickaxe", "researchlab"},
		DEFAULT_PINNED_RECIPES_2 = {"rope", "boards", "cutstone", "transistor", "papyrus"},

		DROP_EVERYTHING_ON_DESPAWN = false,

		EXTRA_STARTING_ITEMS_MIN_DAYS = 10,
		EXTRA_STARTING_ITEMS =
		{
			autumn = { "cutgrass", "cutgrass", "cutgrass", "cutgrass", "cutgrass", "twigs", "twigs", "twigs", "twigs", "twigs", "flint" },
			winter = { "cutgrass", "cutgrass", "cutgrass", "cutgrass", "cutgrass", "twigs", "twigs", "twigs", "twigs", "twigs", "flint" },
			spring = { "cutgrass", "cutgrass", "cutgrass", "cutgrass", "cutgrass", "twigs", "twigs", "twigs", "twigs", "twigs", "flint" },
			summer = { "cutgrass", "cutgrass", "cutgrass", "cutgrass", "cutgrass", "twigs", "twigs", "twigs", "twigs", "twigs", "flint" },
		},

		SEASONAL_STARTING_ITEMS =
		{
			autumn = { },
			winter = { "earmuffshat" },
			spring = { "strawhat" },
			summer = { "grass_umbrella" },
		},

		STARTING_ITEM_IMAGE_OVERRIDE =
		{
			-- this was added for mod characters and items. example: balloons_empty = {atlas = "images/inventoryimages2.xml", image = "spidereggsack.tex" },
		},

        LAVAARENA_SURVIVOR_DIFFICULTY =
        {
            WILSON = 1,
            WILLOW = 1,
            WENDY = 1,
            WOLFGANG = 1,
            WX78 = 3,
            WICKERBOTTOM = 2,
            WES = 3,
            WAXWELL = 3,
            WOODIE = 2,
            WATHGRITHR = 2,
            WEBBER = 1,
            WINONA = 1,
            WORTOX = 1, --VITO do something here
            WORMWOOD = 1, --TODO
            WARLY = 1, --TODO
            WURT = 1, -- TODO
            WALTER = 1, -- TODO
        },

	    LAVAARENA_BERNIE_SCALE = 1.2,

        REVIVE_CORPSE_ACTION_TIME = 6,

		SPAWNPROTECTIONBUFF_IDLE_DURATION = 60,
		SPAWNPROTECTIONBUFF_DURATION = 30,
		SPAWNPROTECTIONBUFF_SPAWN_DIST_SQ = 8*8,

        VOTE_PASSED_SQUELCH_TIME = 0,
        VOTE_FAILED_SQUELCH_TIME = 30,
        VOTE_CANCELLED_SQUELCH_TIME = 30,
        VOTE_TIMEOUT_DEFAULT = 30,
        VOTE_KICK_TIME = 10 * 60, --10min

        DICE_ROLL_COOLDOWN = 30,

        WINTER_TREE_CHOP_SMALL = 5,  -- why are you doing this?
        WINTER_TREE_CHOP_NORMAL = 10, -- but it's almost ready to decorate!
        WINTER_TREE_CHOP_TALL = 15,  -- winters feast is over
        WINTER_TREE_GROW_TIME =
        {
            {base=0, random=0}, --empty
            {base=0.5*day_time, random=0.1*day_time}, --sapling
            {base=1.0*day_time, random=0.2*day_time}, --short
            {base=1.0*day_time, random=0.2*day_time}, --normal
            {base=1.0*day_time, random=0.2*day_time}, --tall
        },

        WINTERS_FEAST_TREE_DECOR_LOOT =
        {
            DEERCLOPS        = {basic=0, special="winter_ornament_boss_deerclops"},
            BEARGER          = {basic=1, special="winter_ornament_boss_bearger"},
            DRAGONFLY        = {basic=2, special="winter_ornament_boss_dragonfly"},
            MINOTAUR         = {basic=1, special="winter_ornament_boss_minotaur"},
            BEEQUEEN         = {basic=2, special="winter_ornament_boss_beequeen"},
            TOADSTOOL        = {basic=2, special="winter_ornament_boss_toadstool"},
            TOADSTOOL_DARK   = {basic=3, special="winter_ornament_boss_toadstool_misery"},
            MOOSE            = {basic=1, special="winter_ornament_boss_moose"}, -- goose?
            ANTLION          = {basic=1, special="winter_ornament_boss_antlion"},
            MALBATROSS       = {basic=1, special="winter_ornament_boss_malbatross"},
            EYEOFTERROR      = {basic=1},
            TWINOFTERROR1     = {basic=1, special="winter_ornament_boss_eyeofterror1"},
            TWINOFTERROR2     = {basic=1, special="winter_ornament_boss_eyeofterror2"},
            ALTERGUARDIAN_PHASE3 = {basic=2},
        },

        WINTERS_FEAST_LOOT_EXCLUSION =
        {
            BEEGUARD = true,
            FROG = true,
            TENTACLE = true,
            KLAUS = true,
            STALKER = true,
            STALKER_FOREST = true,
        },

		WINTERS_FEAST_OVEN_BASE_COOK_TIME = night_time*.3333,

        FIRECRACKERS_STARTLE_RANGE = 10,
        REDLANTERN_LIGHTTIME = total_day_time * 12,
        REDLANTERN_RAIN_RATE = .25,
        PERDFAN_USES = 9, --tornado costs 2 charges
        PERDFAN_TORNADO_LIFETIME = 2,
        DRAGONHAT_PERISHTIME = total_day_time, --only consumes while dancing
        YOTG_PERD_SPAWNCHANCE = .3,
        MAX_WALKABLE_PLATFORM_RADIUS = 4,
        GOOD_LEAKSPAWN_PLATFORM_RADIUS = 9, -- (MAX_WALKABLE_PLATFORM_RADIUS * 0.75) ^2
        ROWING_RADIUS = 0.6,
        ROWING_RADIUS_ITERATIONS = 4,

        --v2 Winona
		WINONA_HEALTH = wilson_health,
		WINONA_HUNGER = wilson_hunger,
        WINONA_SANITY = wilson_sanity,


        WINONA_ENGINEERING_SPACING = 3.2,
        --this is just the default recipe spacing
        --we still want to explicitly define it for engineering recipes because of the fixed range indicators

        WINONA_CATAPULT_HEALTH = 400,
        WINONA_CATAPULT_HEALTH_REGEN_PERIOD = 10,
        WINONA_CATAPULT_HEALTH_REGEN = 400 * 10 / total_day_time,
        WINONA_CATAPULT_DAMAGE = wilson_attack * 1.25,
        WINONA_CATAPULT_MIN_RANGE = 6,
        WINONA_CATAPULT_MAX_RANGE = 15,
        WINONA_CATAPULT_ATTACK_PERIOD = 2.5,
        WINONA_CATAPULT_AOE_RADIUS = 1.25,
        WINONA_CATAPULT_KEEP_TARGET_BUFFER = 5,

        WINONA_SPOTLIGHT_RADIUS = 2.4,
        WINONA_SPOTLIGHT_MIN_RANGE = 4,
        WINONA_SPOTLIGHT_MAX_RANGE = 20,

        WINONA_BATTERY_LOW_MAX_FUEL_TIME = seg_time * 6,
        WINONA_BATTERY_LOW_FUEL_RATE_MULT = .375, --changes max fuel to last 1 full day, while still only costing 2 nitre
        WINONA_BATTERY_HIGH_MAX_FUEL_TIME = total_day_time * 6,
        WINONA_BATTERY_RANGE = 5,
        WINONA_BATTERY_MIN_LOAD = .2,

        --v2 Willow
        BERNIE_HEALTH = 1000,
        BERNIE_FUEL = total_day_time * 15 / 3, --multiply by fuel_rate
        BERNIE_FUEL_RATE = 1 / 3, --bernie lasts 15 days, but can still be repaired by one sewing kit (+5 days)
        BERNIE_DECAY_TIME = total_day_time * 3,
        BERNIE_SPEED = 1,
        BERNIE_BIG_HEALTH = 2000,
        BERNIE_BIG_WALK_SPEED = 4.5,
        BERNIE_BIG_RUN_SPEED = 11,
        BERNIE_BIG_HIT_RECOVERY = 1.5,
        BERNIE_BIG_DAMAGE = 50,
        BERNIE_BIG_ATTACK_PERIOD = 2,
        BERNIE_BIG_ATTACK_RANGE = 3,
        BERNIE_BIG_HIT_RANGE = 3.25,
        BERNIE_BIG_COOLDOWN = 6,

		WILLOW_HEALTH = wilson_health,
		WILLOW_HUNGER = wilson_hunger,
        WILLOW_SANITY = 120,
        WILLOW_SANITY_MODIFIER = 1.1,
        WILLOW_FREEZING_KILL_TIME = 60,
        WILLOW_OVERHEAT_KILL_TIME = 180,
        WILLOW_CAMPFIRE_FUEL_MULT = 1.5,
        WILLOW_FIRE_DAMAGE = 0,

        DRIFTWOOD_TREE_CHOPS = 12,
        DRIFTWOOD_SMALL_CHOPS = 6,

        HOTSPRING_GEM_DROP_CHANCE = 0.2,
        HOTSPRING_GLOW =
        {
            RADIUS = 2.00,
            INTENSITY = 0.75,
            FALLOFF = 0.75,
        },
        HOTSPRING_WORK = 6,
        HOTSPRING_IDLE =
        {
            BASE = 3,
            DELAY = 4,
        },
        HOTSPRING_HEAT =
        {
            ACTIVE = 90,
            PASSIVE = 45,
        },

		BULLKELP_REGROW_TIME = total_day_time*3,

        ROCK_FRUIT_MINES = 1,
        ROCK_FRUIT_LOOT =
        {
            ANGLE = 65,
            SPEED = -1.8,
            HEIGHT = 0.5,
            RIPE_CHANCE = 0.65,
            SEED_CHANCE = 0.01,
            MAX_SPAWNS = 10,
        },
        ROCK_FRUIT_SPROUT_GROWTIME = 5*day_time,
        ROCK_FRUIT_REGROW =
        {
            EMPTY = { BASE = 2*day_time, VAR = 2*seg_time },
            PREPICK = { BASE = 6*seg_time, VAR = 2*seg_time },
            PICK = { BASE = 3*day_time, VAR = 2*seg_time },
            CRUMBLE = { BASE = 1*day_time, VAR = 2*seg_time },
        },

        -- After being transplanted, this is the number of times the bush can be picked
        -- before it becomes barren.
        ROCK_FRUIT_PICKABLE_CYCLES = 3,

        DEAD_SEA_BONES_HAMMERS = 3,

        STARFISH_TRAP_DAMAGE = 60,
        STARFISH_TRAP_RADIUS = 1.4,
        STARFISH_TRAP_TIMING =
        {
            BASE = 0.1,
            VARIANCE = 0,
        },
        STARFISH_TRAP_NOTDAY_RESET =
        {
            BASE = 2*seg_time,
            VARIANCE = 2,
        },

		MOONGLASSAXE =
		{
			EFFECTIVENESS = 2.5,
			CONSUMPTION = 1.25,
			DAMAGE = wilson_attack,
			ATTACKWEAR = 2,
			SHADOW_WEAR = 0.5,
		},

		GLASSCUTTER =
		{
			USES = 75,
			DAMAGE = wilson_attack * 2,
			SHADOW_WEAR = 0.5,
		},

        MOON_TREE_REGROWTH = {
            OFFSPRING_TIME = total_day_time * 3,
            DESOLATION_RESPAWN_TIME = total_day_time * 50,
            DEAD_DECAY_TIME = total_day_time * 30,
        },

        MOON_TREE_GROWTH_TIME =
        {
            {base=1.5*day_time, random=0.5*day_time},   --short
            {base=5*day_time, random=2*day_time},       --normal
            {base=5*day_time, random=2*day_time},       --tall
        },
        MOON_TREE_CHOPS_SMALL = 8,
        MOON_TREE_CHOPS_NORMAL = 12,
        MOON_TREE_CHOPS_TALL = 16,  -- 4 chops per log
        MOON_TREE_DEPLOY_SPACING = 4,

        MOONSPIDERDEN_WORK = 8,
        MOONSPIDERDEN_CREEPRADIUS = { 8, 12, 14 },
        MOONSPIDERDEN_WORK_REGENTIME = 4*seg_time,
        MOONSPIDERDEN_SPIDERS = {2, 3, 4},
        MOONSPIDERDEN_SPIDER_REGENTIME = 4*seg_time,
        MOONSPIDERDEN_RELEASE_TIME = 3*seg_time,
        MOONSPIDERDEN_EMERGENCY_WARRIORS = {0, 0, 0},
        MOONSPIDERDEN_EMERGENCY_RADIUS = {10, 15, 20},
        MOONSPIDERDEN_MAX_INVESTIGATORS = {1, 2, 2},
        MOONSPIDERDEN_ENABLED = true,

        --UNUSED
        MOONSPIDERDEN =
        {
            WORK = 8,
            CREEPRADIUS = { 8, 12, 14 },
            WORK_REGENTIME = 4*seg_time,
            SPIDERS = {2, 3, 4},
            SPIDER_REGENTIME = 4*seg_time,
            RELEASE_TIME = 3*seg_time,
            EMERGENCY_WARRIORS = {0, 0, 0},
            EMERGENCY_RADIUS = {10, 15, 20},
            MAX_INVESTIGATORS = {1, 2, 2},
        },

		FRUITDRAGON =
		{
			HEALTH = 900,
			WALK_SPEED = 0.5,
			RUN_SPEED = 2,

			FIND_HOME_RANGE = 8,
			ENTITY_SLEEP_FIND_HOME_RANGE = 15,
			KEEP_HOME_RANGE = 15,

			CHALLENGE_DIST = 6,
			CHALLENGE_LOST_PANIC_TIME = 6,
			CHALLENGE_WIN_CHANCE = 0.5,

			AWAKE_TIME_MIN = 20,
			AWAKE_TIME_VAR = 10,
			AWAKE_TIME_RIPE_MOD = 4.0,
			AWAKE_TIME_HOMELESS_MOD = 2.0,

			NAP_TIME_MIN = 15,
			NAP_TIME_VAR = 10,
			NAP_TIME_RIPE_MOD = 4/3,
			NAP_TIME_HOMELESS_MOD = 2/3,
			NAP_DIST_FROM_HOME = 4,

			NAP_REGEN_AMOUNT = 5,
			NAP_REGEN_INTERVAL = 1,

			NAP_MIN_HEAT = 5,
			RIPEN_NAP_MIN_HEAT = 90,

			ATTACK_PERIOD = 2,
			UNRIPE_DAMAGE = 30,
			RIPE_DAMAGE = 50,
			ATTACK_RANGE = 2.0,
			HIT_RANGE = 3,
			FIREATTACK_HIT_RANGE = 3,
			FIREATTACK_DAMAGE = 25,
			FIREATTACK_COOLDOWN = 6,
		},

        GESTALT_WALK_SPEED = 1.5,

        GESTALT_SPAWN_DIST = 14,
        GESTALT_SPAWN_DIST_VAR = 3,
        GESTALT_SPAWN_MORPH_DIST = 8,

        GESTALT_INITIAL_MORPH_TIMER = seg_time,
        GESTALT_EMERGE_MORPH_DELAY = seg_time / 3,

        GESTALT_MIN_SANITY_TO_SPAWN = 0.25,
        GESTALT_POPULATION_DIST = 30,
        GESTALT_RELOCATED_FAR_DIST = 18,

        GESTALT_COMBAT_TRANSPERENCY = 0.85,

        GESTALT_AGGRESSIVE_RANGE = 6,
        GESTALT_ATTACK_RANGE = 2.5,
        GESTALT_ATTACK_HIT_RANGE_SQ = 1.5,
        GESTALT_ATTACK_COOLDOWN = 4,
        GESTALT_ATTACK_DAMAGE_SANITY = 10,
        GESTALT_ATTACK_DAMAGE_GROGGINESS = 2,
        GESTALT_ATTACK_DAMAGE_KO_TIME = 6,

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

        --UNUSED
		GESTALT =
		{
			WALK_SPEED = 1.5,

			SPAWN_DIST = 14,
			SPAWN_DIST_VAR = 3,
			SPAWN_MORPH_DIST = 8,

			INITIAL_MORPH_TIMER = seg_time,
			EMERGE_MORPH_DELAY = seg_time / 3,

			MIN_SANITY_TO_SPAWN = .25,
			POPULATION_DIST = 30,
			RELOCATED_FAR_DIST = 18,

			COMBAT_TRANSPERENCY = 0.85,

			AGGRESSIVE_RANGE = 6,
			ATTACK_RANGE = 2.5,
			ATTACK_HIT_RANGE_SQ = 1.5,
			ATTACK_COOLDOWN = 4,
			ATTACK_DAMAGE_SANITY = 10,
			ATTACK_DAMAGE_GROGGINESS = 2,
			ATTACK_DAMAGE_KO_TIME = 6,

			POPULATION_LEVEL =
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
		},

		--GESTALT GUARD
		GESTALTGUARD_WALK_SPEED = 4,
		GESTALTGUARD_HEALTH = 200,
		GESTALTGUARD_DAMAGE = 180,
		GESTALTGUARD_ATTACK_RANGE = 3.5,
		GESTALTGUARD_WATCHING_RANGE = 6,
		GESTALTGUARD_AGGRESSIVE_RANGE = 18,
		GESTALTGUARD_MAX_DISTSQ_FROM_SPAWN_PT = 36*36,

		GROTTOWAR_NIGHTMARE_TARGET_PLAYER_CHANCE = 0.25,
		GROTTOWAR_POPULATION_DIST = 35,
		GROTTOWAR_NUM_BRIGHTMARES_PRE_NIGHTMARE = 1.5,
		GROTTOWAR_MAX_NIGHTMARES = 5,
		GROTTOWAR_NUM_AMBIENT_BRIGHTMARES = 2,

        MAX_FISH_SCHOOL_SIZE = 2,

        ROGUEWAVE_HIT_MOISTURE = 25,
        ROGUEWAVE_HIT_DAMAGE = 10,
        ROGUEWAVE_SPEED_MULTIPLIER = 3,

        FISHING_NET_USES = 22,

        MINIFLARE =
        {
            TIME = 15,
			HUD_INDICATOR_TIME = 8,
            ANIM_SWAP_TIME = 0.35,
            OFFSHOOT_RADIUS = 30,
            SPEECH_MIN_DISTANCE_SQ = 30*30,
            CHANCE_TO_NOTICE = 0.25,
            NEXT_NOTICE_DELAY = 30,
            HUD_MAX_DISTANCE_SQ = 35*35,

            FAR_AUDIO_GATE_DISTANCE_SQ = 200*200,
            BASE_VOLUME = 0.3,
        },

        MOON_ALTAR_COMPLETE_WORK = 3,
        MOON_ALTAR_ASTRAL_COMPLETE_WORK = 2,
        MOON_ALTAR_ESTABLISH_LINK_RADIUS = 20,
        MOON_ALTAR_LINK_MAX_ABS_DOT = 0.975,

		MOONALTAR_ROCKS_MINE = 20,

        WATERBIRD_SEE_THREAT_DISTANCE = 6,

		COOKIECUTTER =
		{
			HEALTH = 100,
			WANDER_SPEED = 0.25,
			APPROACH_SPEED = 0.7,
			RUN_SPEED = 2,
			FLEE_DURATION = 6,

			BOARDING_DISTANCE = 0.5,
			BOARDING_DISTANCE_VARIANCE = 1.2,

			DRILL_TIME = 3,
			DRILL_DAMAGE = 10,

			EAT_DELAY = seg_time,

			DAMAGE = 20,
			ATTACK_RADIUS = 2.5,
			JUMP_ATTACK_RADIUS = 1.5,

			WANDER_DIST = 12,

			FOOD_DETECTION_DIST = 8,
			BOAT_DETECTION_DIST = 12, -- TUNING.MAX_WALKABLE_PLATFORM_RADIUS + FOOD_DETECTION_DIST
			BOAT_DETECTION_SHARE_DIST = 5,
		},

		COOKIECUTTER_SPAWNER_REGEN_TIME = 3*seg_time,
		COOKIECUTTER_SPAWNER_RELEASE_TIME = 5,
		COOKIECUTTER_SPAWNER_MAX_CHILDREN = 7,
        COOKIECUTTER_SPAWNER_ENABLED = true,

        --unused
		COOKIECUTTER_SPAWNER =
		{
			REGEN_TIME = 3*seg_time,
			RELEASE_TIME = 5,
			MAX_CHILDREN = 7,
		},

		SALTROCK_PRESERVE_PERCENT_ADD = 0.5,

        SALTSTACK_WORK_REQUIRED = 10,
        SALTSTACK_GROWTH_FREQUENCY = total_day_time*9,
        SALTSTACK_GROWTH_FREQUENCY_VARIANCE = total_day_time*2,
        SALTSTACK_GROWTH_ENABLED = true,

        --unused
		SALTSTACK =
		{
			WORK_REQUIRED = 10,
			GROWTH_FREQUENCY = total_day_time*9,
			GROWTH_FREQUENCY_VARIANCE = total_day_time*2,
		},

		SPOILED_FISH_WORK_REQUIRED = 1,
        SPOILED_FISH_SMALL_WORK_REQUIRED = 1,
		SPOILED_FISH_LOOT =
		{
			LAUNCH_SPEED = -1.8,
			LAUNCH_HEIGHT = 0.5,
			LAUNCH_ANGLE = 65,

			WORK_MAX_SPAWNS = 10,
		},

        BOAT =
        {
            HEALTH = 200,
            MAX_HULL_HEALTH_DAMAGE = 70,
            MASS = 500,

            WAKE_TEST_TIME = 2,

            MAX_FORCE_VELOCITY = 3.5,
            MAX_ALLOWED_VELOCITY = 10,

            BASE_DRAG = 0.2,
            MAX_DRAG = 1.5,
            BASE_DAMPENING = 0,
            MAX_DAMPENING = 1,
            MAX_VELOCITY = 1.2,
            MAX_VELOCITY_MOD = 1,
            PUSH_BACK_VELOCITY = 1.75,
            SCARY_MINSPEED_SQR = 1,
            SCARY_MINSPEED = 1,
            RUDDER_TURN_SPEED = 0.6,
            NO_BUILD_BORDER_RADIUS = -0.2,
			FIRE_DAMAGE = 5,
            BOATPHYSICS_COLLISION_TIME_BUFFER = 4 * FRAMES, --now unused.

            OARS =
            {
                BASIC =
                {
                    FORCE = 0.3,
                    DAMAGE = wilson_attack*.5,
					ROW_FAIL_WEAR = 25,
                    ATTACKWEAR = 25,
                    USES = 500,
                    MAX_VELOCITY = 2,
                },

                DRIFTWOOD =
                {
                    FORCE = 0.5,
                    DAMAGE = wilson_attack*.5,
					ROW_FAIL_WEAR = 25,
                    ATTACKWEAR = 25,
                    USES = 400,
                    MAX_VELOCITY = 3.5,
                },

                MALBATROSS =
                {
                    FORCE = 0.8,
                    DAMAGE = wilson_attack*.8,
					ROW_FAIL_WEAR = 6,
                    ATTACKWEAR = 6,
                    USES = 1500,
                    MAX_VELOCITY = 5,
                },
            },

            ANCHOR =
            {
                BASIC =
                {
                    MAX_VELOCITY_MOD = 0.15,
                    ANCHOR_DRAG = 2,
                    SAILFORCEDRAG = 0.8,
                },
            },

            MAST =
            {
                BASIC =
                {
                    MAX_VELOCITY = 2.5,
        --            MAX_VELOCITY_MOD = 1.2,
                    SAIL_FORCE = 0.6,
                    RUDDER_TURN_DRAG = 0.23,
                },

                MALBATROSS =
                {
                    MAX_VELOCITY = 4,
      --              MAX_VELOCITY_MOD = 1.2,
                    SAIL_FORCE = 1.3,
                    RUDDER_TURN_DRAG = 0.23,
                },

                HEAVABLE_ACTIVE_FRAME = 8,
                HEAVABLE_START_FRAME = 12,
            },
        },

		DROWNING_DAMAGE =
		{
			DEFAULT =
			{
				HEALTH_PENALTY = 0.25,
				HUNGER = 25,
				SANITY = 25,
				WETNESS = 100,
			},

			WX78 =
			{
				HEALTH_PENALTY = 0.4,
				HUNGER = 25,
				SANITY = 50,
				WETNESS = 100,
			},

			WOODIE =
			{
				HEALTH_PENALTY = 0.25,
				HUNGER = 50,
				SANITY = 25,
				WETNESS = 100,
			},

			WEREWOODIE =
			{
				WERENESS = 100,
				WETNESS = 100,
			},

            WURT =
            {
                HEALTH_PENALTY = 0,
                HUNGER = 0,
                SANITY = 0,
                WETNESS = 50,
            },

            WALTER =
            {
                HEALTH_PENALTY = 0.1,
                HUNGER = 25,
                SANITY = 12,
                WETNESS = 100,
            },

			WANDA =
			{
				HEALTH = 25,
				HUNGER = 25,
				SANITY = 25,
				WETNESS = 100,
			},

			CREATURE =
			{
				WETNESS = 100,
			},
		},

        CARRAT =
        {
            WALK_SPEED = 4,
            RUN_SPEED = 7,
            HEALTH = 25 * multiplayer_attack_modifier,
            PERISH_TIME = total_day_time * 5,
            EAT_TIME = { BASE = 4, VAR = 4 },

            PLANTED_RUFFLE_TIME = 30,

            EMERGED_TIME_LIMIT = seg_time * 4,
        },

		OCEAN =
		{
			WETNESS = 75, -- DEPRECATED - use TUNING.OCEAN_WETNESS
		},

        OCEAN_SILHOUETTE =
        {
            SPAWN_TEST_TIME = {base = seg_time * 8, random = seg_time * 8},
            SPAWN_DISTANCE = 40,
            MOVE_SPEED = 4,
            RETURN_MOVE_SPEED = 8,
            FAILSAFE_TIMELIMIT = total_day_time,
        },

        OCEAN_SHADER =
        {
            TEXTURE_BLUR_PASS_SIZE = 1,
            TEXTURE_BLUR_PASS_COUNT = 3,
            WAVE_TINT_AMOUNT = 0.8,                     --How much the waves get tinted by the ocean color
            EFFECT_TINT_AMOUNT = 0.6,                   --How much the effects under floating items/boat get tinted by the ocean color

            OCEAN_FLOOR_COLOR =      {   0,  19,   20, 255 },
            OCEAN_FLOOR_COLOR_DUSK = {   0,  0,   0, 255 },

            NOISE =
            {
                {
                    ANGLE = 15,
                    SPEED = 0.35 * OCEAN_SPEED_BASE_SCALE,
                    SCALE = 2.6 * OCEAN_NOISE_BASE_SCALE,
                    FREQUENCY = 1,
                },

                {
                    ANGLE = 100,
                    SPEED = 0.45 * OCEAN_SPEED_BASE_SCALE,
                    SCALE = 3.0 * OCEAN_NOISE_BASE_SCALE,
                    FREQUENCY = 1,
                },

                {
                    ANGLE = 230,
                    SPEED = 0.55 * OCEAN_SPEED_BASE_SCALE,
                    SCALE = 3.4 * OCEAN_NOISE_BASE_SCALE,
                    FREQUENCY = 1,
                },
            }
        },

        OCEAN_MINIMAP_SHADER =
        {
            TEXTURE_BLUR_SIZE = 2,
            TEXTURE_BLUR_PASS_COUNT = 6,

            TEXTURE_ALPHA_BLUR_SIZE = 1,
            TEXTURE_ALPHA_BLUR_PASS_COUNT = 2,

            MASK_BLUR_SIZE = 2,
            MASK_BLUR_PASS_COUNT = 8,

            EDGE_COLOR0 = { 47, 52, 79 },
            EDGE_PARAMS0 =
            {
                THRESHOLD = 0.5,
                HALF_THRESHOLD_RANGE = 0.6,
            },

            EDGE_COLOR1 = { 80, 69, 54 },
            EDGE_PARAMS1 =
            {
                THRESHOLD = 0.46,
                HALF_THRESHOLD_RANGE = 0.4,
            },

            EDGE_SHADOW_COLOR = { 43, 43, 43 },
            EDGE_SHADOW_PARAMS =
            {
                THRESHOLD = 0.37,
                HALF_THRESHOLD_RANGE = 0.4,
                UV_OFFSET_X = -0.001,
                UV_OFFSET_Y = 0.001,
            },

            EDGE_FADE_PARAMS =
            {
                THRESHOLD = 0.41,
                HALF_THRESHOLD_RANGE = 0.02,
                MASK_INSET = 0.01,
            },

            EDGE_NOISE_PARAMS =
            {
                UV_SCALE = 4,
            },
        },

        WATERFALL_SHADER =
        {
            FADE_COLOR = {161, 161, 161},
            FADE_START = 0.05,

            NOISE =
            {
                {
                    SCALE = 1.0,
                    SPEED = 1.0,
                    OPACITY = 0.1,
                    FADE_START = 0.0,
                },
                {
                    SCALE = 1.9,
                    SPEED = 0.8,
                    OPACITY = 1.0,
                    FADE_START = 0.25,
                },
            }
        },

        BURNED_LOOT_OVERRIDES =
        {
            carrot_seeds = "seeds_cooked",
            corn_seeds = "seeds_cooked",
            pumpkin_seeds = "seeds_cooked",
            eggplant_seeds = "seeds_cooked",
            durian_seeds = "seeds_cooked",
            pomegranate_seeds = "seeds_cooked",
            dragonfruit_seeds = "seeds_cooked",
            watermelon_seeds = "seeds_cooked",
            tomato_seeds = "seeds_cooked",
            potato_seeds = "seeds_cooked",
            asparagus_seeds = "seeds_cooked",
            onion_seeds = "seeds_cooked",
            garlic_seeds = "seeds_cooked",
            pepper_seeds = "seeds_cooked",
            pondfish = "fishmeat_small_cooked",
        },

        --wortox
        WORTOX_HEALTH = 200,
        WORTOX_HUNGER = 175,
        WORTOX_SANITY = 150,
        WORTOX_SANITY_AURA_MULT = .5,
        WORTOX_MAX_SOULS = 20,
        WORTOX_FOOD_MULT = .5,
        WORTOX_SOULEXTRACT_RANGE = 20, --die within this range of wortox to spawn soul
        WORTOX_SOULSTEALER_RANGE = 8, --souls fly towards wortox when he walks within this range
        WORTOX_SOULHEAL_RANGE = 8,

        --Wormwood
		WORMWOOD_HEALTH = wilson_health,
		WORMWOOD_HUNGER = wilson_hunger,
        WORMWOOD_SANITY = wilson_sanity,

        WORMWOOD_BURN_TIME = 4.3,
        WORMWOOD_FIRE_DAMAGE = 1.25,
        ARMORBRAMBLE_DMG = wilson_attack/1.5,
        ARMORBRAMBLE_ABSORPTION = .8*multiplayer_armor_absorption_modifier,
        ARMORBRAMBLE = wilson_health*5*multiplayer_armor_durability_modifier,
        TRAP_BRAMBLE_USES = 10,
        TRAP_BRAMBLE_DAMAGE = 40,
        TRAP_BRAMBLE_RADIUS = 2.5,
        COMPOSTWRAP_SOILCYCLES = 20,
        COMPOSTWRAP_WITHEREDCYCLES = 2,
        COMPOSTWRAP_FERTILIZE = day_time * 6,
        POOP_FERTILIZE_HEALTH = 2,
		FERTILIZER_FERTILIZE_HEALTH = 3,

		WORMWOOD_BLOOM_FARM_PLANT_INTERACT_RANGE = 4,

		WORMWOOD_FERTILIZER_RATE_MOD = 1/128,
		WORMWOOD_FERTILIZER_BLOOM_TIME_MOD = seg_time / 4,

		WORMWOOD_SPRING_BLOOM_MOD = 1.5,
		WORMWOOD_SPRING_BLOOMDRAIN_RATE = 0,
		WORMWOOD_WINTER_BLOOM_MOD = 0.75,
		WORMWOOD_WINTER_BLOOMDRAIN_RATE = 2,

		WORMWOOD_BLOOM_STAGE_DURATION = total_day_time,
		WORMWOOD_BLOOM_FULL_DURATION = total_day_time * 3,
		WORMWOOD_BLOOM_FULL_MAX_DURATION = total_day_time * 5,

		WORMWOOD_BLOOM_PLANTS_WARNING_TIME_LOW = total_day_time * 0.5,
		WORMWOOD_BLOOM_PLANTS_WARNING_TIME_MED = total_day_time * 1.0,

        WATER_TURTLE_WALKSPEED = 0.5,
        WATER_TURTLE_RUNSPEED = 3,
        WATER_TURTLE_HEALTH = 300,
        WATER_TURTLE_MATING_SEASON_BABYDELAY = total_day_time*1.5,
        WATER_TURTLE_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,

        ANCHOR_DEPTH_TIMES = {
            LAND = 0,
            SHALLOW = 2,
            BASIC = 6,
            DEEP = 8,
            VERY_DEEP = 10,
        },

        --v2 Warly
		WARLY_HEALTH = wilson_health,
        WARLY_SANITY = wilson_sanity,
        WARLY_HUNGER = 250,
        WARLY_HUNGER_RATE_MODIFIER = 1.2,
        WARLY_SAME_OLD_COOLDOWN = total_day_time * 2,
        WARLY_SAME_OLD_MULTIPLIERS = { .9, .8, .65, .5, .3 },
        PORTABLE_COOK_POT_TIME_MULTIPLIER = .8, --multiplier for cook time, NOT speed! (less time means faster)

        -- Multipliers can be temperaturedelta, temperatureduration, health, sanity or hunger
        SPICE_MULTIPLIERS =
        {
            SPICE_SALT = { HEALTH = 0.25 }
            --currently not used, but still supported (for future use)
        },

        BUFF_ATTACK_DURATION = total_day_time * .5,
        BUFF_PLAYERABSORPTION_DURATION = total_day_time * .5,
        BUFF_WORKEFFECTIVENESS_DURATION = total_day_time * .5,
        BUFF_MOISTUREIMMUNITY_DURATION = day_time,
        BUFF_ELECTRICATTACK_DURATION = day_time,
        BUFF_FOOD_TEMP_DURATION = day_time,

        BUFF_ATTACK_MULTIPLIER = 1.2,
        BUFF_PLAYERABSORPTION_MODIFIER = 1 / 3,
        BUFF_WORKEFFECTIVENESS_MODIFIER = 2,

        --v2 Woodie
		WOODIE_HEALTH = wilson_health,
		WOODIE_HUNGER = wilson_hunger,
        WOODIE_SANITY = wilson_sanity,

        WERE_SANITY_PENALTY = -.1,
        WERE_FULLMOON_DRAIN_TIME_MULTIPLIER = 2,
        WOODCUTTER_LEIF_CHANCE_MOD = 1.5,
        WOODCUTTER_DECID_MONSTER_CHANCE_MOD = 1.5,
        --
        BEAVER_LEIF_CHANCE_MOD = 0,
        BEAVER_DECID_MONSTER_CHANCE_MOD = 0,
        BEAVER_DRAIN_TIME = 15,
        BEAVER_WORKING_DRAIN_TIME_MULTIPLIER2 = 16,
        BEAVER_WORKING_DRAIN_TIME_MULTIPLIER1 = 10,
        BEAVER_WORKING_DRAIN_TIME_DURATION = 4, --time for the working mults to wear off
        BEAVER_RUN_SPEED = 6.6, --x1.1 speed
        BEAVER_ABSORPTION = .25,
        BEAVER_DAMAGE = wilson_attack * .8,
        BEAVER_WOOD_DAMAGE = wilson_attack * .5, -- extra damage to wood things
        --
        WEREMOOSE_DRAIN_TIME = 15,
        WEREMOOSE_FIGHTING_DRAIN_TIME_MULTIPLIER2 = 16,
        WEREMOOSE_FIGHTING_DRAIN_TIME_MULTIPLIER1 = 10,
        WEREMOOSE_FIGHTING_DRAIN_TIME_DURATION = 6, --time for fighting mults to wear off
        WEREMOOSE_RUN_SPEED = 5.4, --x0.9 speed
        WEREMOOSE_ABSORPTION = .9,
        WEREMOOSE_DAMAGE = wilson_attack * 1.75,
        --
        WEREGOOSE_DRAIN_TIME = 15,
        WEREGOOSE_RUN_DRAIN_TIME_MULTIPLIER2 = 16,
        WEREGOOSE_RUN_DRAIN_TIME_MULTIPLIER1 = 10,
        WEREGOOSE_RUN_DRAIN_TIME_DURATION = 2, --time for running mults to wear off
        WEREGOOSE_RUN_SPEED = 8.4, --x1.4 speed
        --deprecated beaverness stuff
        --BEAVER_DRAIN_TIME = 5 * total_day_time, -- time it takes the log meter to drain to transform threshold
        BEAVER_FULLMOON_DRAIN_MULTIPLIER = 5 * 8,
        WOODIE_TRANSFORM_TO_HUMAN = 0.99, -- because .99000001 shows as 100 in the HUD
        WOODIE_TRANSFORM_TO_BEAVER = 0.25,
        BEAVER_GNAW_GAIN = 1,
        WOODIE_CHOP_DRAIN = -1.5,
        WOODIE_PLANT_TREE_GAIN = 5,
        LOG_WOODINESS = 10,

        -- Wurt
        WURT_HEALTH = 150,
        WURT_HUNGER = 200,
        WURT_SANITY = 150,

        WURT_HEALTH_KINGBONUS = 250,
        WURT_HUNGER_KINGBONUS = 250,
        WURT_SANITY_KINGBONUS = 200,

        WURT_FISH_PRESERVER_RATE = 1/4,

        MERM_DAMAGE = 30,
        MERM_HEALTH = 250 * 2, -- harder for multiplayer
        MERM_HEALTH_REGEN_PERIOD = 10,
        MERM_HEALTH_REGEN_AMOUNT = (10 * (250 * 2)) / (total_day_time * 2), -- 2 days to recover to full to promote keeping Merms versus letting them die for the 4 day cooldown on houses.
        MERM_ATTACK_PERIOD = 3,
        MERM_RUN_SPEED = 8,
        MERM_WALK_SPEED = 3,
        MERM_TARGET_DIST = 10,
        MERM_DEFEND_DIST = 30,
		MERM_MAX_STUN_LOCKS = 2,

        MERM_SHARE_TARGET_DIST = 40,
        MERM_MAX_TARGET_SHARES = 5,

        MERM_LOW_LOYALTY_WARNING_PERCENT = 0.07,
        MERM_LOYALTY_MAXTIME_KINGBONUS = 2 * total_day_time,
        MERM_LOYALTY_PER_HUNGER_KINGBONUS = total_day_time/33,

        MERM_LOYALTY_MAXTIME = 3 * total_day_time,
        MERM_LOYALTY_PER_HUNGER = total_day_time/25,
        MERM_FOLLOWER_COUNT = 2,
        MERM_FOLLOWER_RADIUS = 8,

        MERM_DAMAGE_KINGBONUS = 40,
        MERM_HEALTH_KINGBONUS = 560,

        MERM_GUARD_DAMAGE = 50,
        MERM_GUARD_HEALTH = 660,
        MERM_GUARD_ATTACK_PERIOD = 3,
        MERM_GUARD_RUN_SPEED = 8,
        MERM_GUARD_WALK_SPEED = 3,
        MERM_GUARD_TARGET_DIST = 15,
        MERM_GUARD_DEFEND_DIST = 40,

        MERM_GUARD_SHARE_TARGET_DIST = 60,
        MERM_GUARD_MAX_TARGET_SHARES = 8,

        MERM_GUARD_LOYALTY_MAXTIME = 5 * total_day_time,
        MERM_GUARD_LOYALTY_PER_HUNGER = total_day_time/15,
        MERM_GUARD_FOLLOWER_COUNT = 5,
        MERM_GUARD_FOLLOWER_RADIUS = 16,

        MERM_KING_HEALTH = 1000,
        MERM_KING_HEALTH_REGEN_PERIOD = 1,
        MERM_KING_HEALTH_REGEN = 2,
        MERM_KING_HUNGER = 200,
        MERM_KING_HUNGER_KILL_TIME = total_day_time * 2,
        MERM_KING_HUNGER_RATE = 200 / (total_day_time * 8),

        PUNY_MERM_HEALTH = 200,
        PUNY_MERM_DAMAGE = 20,

        MERMHOUSE_REGEN_TIME = total_day_time * 4,
        MERMHOUSE_RELEASE_TIME = 10,
        MERMHOUSE_MERMS = 3,
        MERMHOUSE_ENABLED = true,

        MERMWATCHTOWER_REGEN_TIME = total_day_time / 2,
        MERMWATCHTOWER_RELEASE_TIME = 10,
        MERMWATCHTOWER_MERMS = 1,
        MERMWATCHTOWER_ENABLED = true,

        MERMHOUSE_EMERGENCY_MERMS = 3,
        MERMHOUSE_EMERGENCY_RADIUS = 15,

        -- WENDY
        GHOST_HUNT =
        {
            TOY_COUNT =
            {
                MIN = 3,
                MAX = 5,
            },
            TOY_DIST =
            {
                BASE = 125,
                RADIUS = 20,
                VARIANCE = 5,
            },
            TOY_FADE =
            {
                IN = 5.5,
                OUT = 6.5,
            },
            PICKUP_DSQ = 4,
            HINT_OFFSET = 3,
            MINIMUM_HINT_DIST = 40,
            MAXIMUM_HINT_DIST = 180,
        },

        UNIQUE_SMALLGHOST_DISTANCE = 50,

        ABIGAIL_SPEED = 5,
        ABIGAIL_HEALTH = wilson_health*4,
        ABIGAIL_HEALTH_LEVEL1 = wilson_health*1,
        ABIGAIL_HEALTH_LEVEL2 = wilson_health*2,
        ABIGAIL_HEALTH_LEVEL3 = wilson_health*4,
		ABIGAIL_FORCEFIELD_ABSORPTION = 1.0,
        ABIGAIL_DAMAGE_PER_SECOND = 20, -- deprecated
        ABIGAIL_DAMAGE =
        {
            day = 15,
			dusk = 25,
			night = 40,
        },
		ABIGAIL_VEX_DURATION = 2,
		ABIGAIL_VEX_DAMAGE_MOD = 1.1,
		ABIGAIL_VEX_GHOSTLYFRIEND_DAMAGE_MOD = 1.4,


        ABIGAIL_DMG_PERIOD = 1.5,
        ABIGAIL_DMG_PLAYER_PERCENT = 0.25,
        ABIGAIL_FLOWER_DECAY_TIME = total_day_time * 3,

        ABIGAIL_BOND_LEVELUP_TIME = total_day_time * 1,
        ABIGAIL_BOND_LEVELUP_TIME_MULT = 4,
        ABIGAIL_MAX_STAGE = 3,

        ABIGAIL_LIGHTING =
		{
			{l = 0.0, r = 0.0},
			{l = 0.1, r = 0.3, i = 0.7, f = 0.5},
			{l = 0.5, r = 0.7, i = 0.6, f = 0.6},
		},

        ABIGAIL_FLOWER_PROX_DIST = 6*6,
        ABIGAIL_COMBAT_TARGET_DISTANCE = 15,

        ABIGAIL_DEFENSIVE_MIN_FOLLOW = 1,
        ABIGAIL_DEFENSIVE_MAX_FOLLOW = 5,
        ABIGAIL_DEFENSIVE_MED_FOLLOW = 3,

        ABIGAIL_AGGRESSIVE_MIN_FOLLOW = 3,
        ABIGAIL_AGGRESSIVE_MAX_FOLLOW = 10,
        ABIGAIL_AGGRESSIVE_MED_FOLLOW = 6,

        ABIGAIL_DEFENSIVE_MAX_CHASE_TIME = 3,
        ABIGAIL_AGGRESSIVE_MAX_CHASE_TIME = 6,

		GHOSTLYELIXIR_SLOWREGEN_HEALING = 2,
		GHOSTLYELIXIR_SLOWREGEN_TICK_TIME = 1,
		GHOSTLYELIXIR_SLOWREGEN_DURATION = total_day_time, -- 960 hp

		GHOSTLYELIXIR_FASTREGEN_HEALING = 20,
		GHOSTLYELIXIR_FASTREGEN_TICK_TIME = 1,
		GHOSTLYELIXIR_FASTREGEN_DURATION = seg_time, -- 600 hp

		GHOSTLYELIXIR_DAMAGE_DURATION = total_day_time,

		GHOSTLYELIXIR_SPEED_LOCO_MULT = 1.75,
		GHOSTLYELIXIR_SPEED_DURATION = total_day_time,
		GHOSTLYELIXIR_SPEED_PLAYER_GHOST_DURATION = 3,

		GHOSTLYELIXIR_SHIELD_DURATION = total_day_time,

		GHOSTLYELIXIR_RETALIATION_DAMAGE = 20,
		GHOSTLYELIXIR_RETALIATION_DURATION = total_day_time,

		GHOSTLYELIXIR_DRIP_FX_DELAY = seg_time / 2,

        -- WALTER
		SLINGSHOT_DISTANCE = 10,
		SLINGSHOT_DISTANCE_MAX = 14,

		SLINGSHOT_AMMO_MOVESPEED_MULT = 2/3,
		SLINGSHOT_AMMO_MOVESPEED_DURATION = 30,
		SLINGSHOT_AMMO_FREEZE_COLDNESS = 2,
		SLINGSHOT_AMMO_SHADOWTENTACLE_CHANCE = 0.5,

		SLINGSHOT_AMMO_DAMAGE_ROCKS = wilson_attack * 0.5,		-- 17
		SLINGSHOT_AMMO_DAMAGE_GOLD = wilson_attack,				-- 34
		SLINGSHOT_AMMO_DAMAGE_MARBLE = wilson_attack * 1.5,		-- 51
		SLINGSHOT_AMMO_DAMAGE_THULECITE = wilson_attack * 1.5,	-- 51
		SLINGSHOT_AMMO_DAMAGE_SLOW = wilson_attack * 0.5,		-- 17
		SLINGSHOT_AMMO_DAMAGE_TRINKET_1 = wilson_attack * 1.75,	-- 59.5

        WALTER_TREE_SANITY_RADIUS = 10,
        WALTER_TREE_SANITY_THRESHOLD = 5,
        WALTER_TREE_SANITY_BONUS = 0.1, -- cancels out health drain while above 50% health
		WALTER_TREE_SANITY_UPDATE_TIME = 1,

        WALTER_SANITY_DAMAGE_RATE = 2,
		WALTER_SANITY_DAMAGE_OVERTIME_RATE = 1,
        WALTER_SANITY_HEALTH_DRAIN = .2,

		WALTERHAT_SANITY_DAMAGE_PROTECTION = .5,

		WALTER_STARTING_WOBY = "wobysmall",

        WOBY_BIG_HUNGER = 50,
        WOBY_BIG_HUNGER_RATE = 50/(total_day_time * 2.5),
        WOBY_BIG_SPEED =
        {
            FAST = 10,
            MEDIUM = 9,
            SLOW = 8
        },

        WOBY_BIG_WALK_SPEED = 1.5,

        WOBY_SMALL_HUNGER = 50,
        WOBY_SMALL_HUNGER_RATE = 50 / (total_day_time * 2.5),

        -- WIGFRID
        BATTLESONG_ATTACH_RADIUS = 12,
        BATTLESONG_DETACH_RADIUS = 16,

        INSPIRATION_MAX = 100,
        INSPIRATION_GAIN_RATE = 0.024,
        INSPIRATION_GAIN_EPIC_BONUS = 3,
        INSPIRATION_DRAIN_RATE = -2,
        INSPIRATION_DRAIN_BUFFER_TIME = 7.5,

        MAX_ACTIVE_SONGS = 3,
        SONG_REAPPLY_PERIOD = .5,
        SONG_REFRESH_PERIOD = 1,

		BATTLESONG_THRESHOLDS =
		{
			1/6,
			3/6,
			5/6,
		},
		BATTLESONG_INSTANT_COST = 100 * 1/6, -- INSPIRATION_MAX * BATTLESONG_THRESHOLDS[1]

        BATTLEBORN_STORE_TIME = 3,
        BATTLEBORN_DECAY_TIME = 5,
        BATTLEBORN_TRIGGER_THRESHOLD = 1,

        WATHGRITHR_BATTLEBORN_BONUS = 0.25,
        REGULAR_BATTLEBORN_BONUS = 0.1,

        BATTLESONG_DURABILITY_MOD = 0.75,
        BATTLESONG_NEG_SANITY_AURA_MOD = 0.5,
        BATTLESONG_FIRE_RESIST_MOD = 0.66,
        BATTLESONG_PANIC_TIME = 4,

        BATTLESONG_HEALTHGAIN_DELTA = 1,
        BATTLESONG_HEALTHGAIN_DELTA_SINGER = 0.5,
        BATTLESONG_SANITYGAIN_DELTA = 1,

		-- WANDA
		WANDA_MIN_YEARS_OLD = 20,
		WANDA_MAX_YEARS_OLD = 80,

        WANDA_AGE_THRESHOLD_OLD = .25,
        WANDA_AGE_THRESHOLD_YOUNG = .75,

		POCKETWATCH_SHADOW_DAMAGE = wilson_attack*2.4,
		POCKETWATCH_DEPLETED_DAMAGE = wilson_attack*.8,

		POCKETWATCH_HEAL_COOLDOWN = seg_time * 4,
		POCKETWATCH_HEAL_HEALING = 20, -- health pre-oldager modifier

		POCKETWATCH_REVIVE_COOLDOWN = total_day_time * 0.5,
		POCKETWATCH_WARP_COOLDOWN = 2,
		POCKETWATCH_RECALL_COOLDOWN = total_day_time,

        WANDA_OLD_HAMMER_EFFECTIVENESS = 0.75,
        LONGEST_ACTION_TIMEOUT = 1.5,

        WANDA_STAFFSANITY_YOUNG = 1,
        WANDA_STAFFSANITY_NORMAL = 0.5,
        WANDA_STAFFSANITY_OLD = 0.25,

        WANDA_SHADOW_RESISTANCE_YOUNG = 1,
        WANDA_SHADOW_RESISTANCE_NORMAL = 0.33,
        WANDA_SHADOW_RESISTANCE_OLD = 0,

        WANDA_REGULAR_DAMAGE_OLD = 0.5,
        WANDA_REGULAR_DAMAGE_NORMAL = 1,
        WANDA_REGULAR_DAMAGE_YOUNG = 1,

        WANDA_SHADOW_DAMAGE_OLD = 1.75,
        WANDA_SHADOW_DAMAGE_NORMAL = 1.2,
        WANDA_SHADOW_DAMAGE_YOUNG = 1,

        WANDA_WARP_DIST_OLD = 2,
        WANDA_WARP_DIST_NORMAL = 4,
        WANDA_WARP_DIST_YOUNG = 8,

        -- Salty dog
        FLOTSAM_SPAWN_MAX = 4,
        FLOTSAM_SPAWN_DELAY = {min=30, max=180},

        MALBATROSS_HEALTH = 2500 * 2,
        MALBATROSS_DAMAGE = 150,

        MALBATROSS_DAMAGE_PLAYER_PERCENT = .5,
        MALBATROSS_ATTACK_PERIOD = 4,
        MALBATROSS_ATTACK_RANGE = 5,
        MALBATROSS_AOE_RANGE = 3,
        MALBATROSS_AOE_SCALE = 0.8,
        MALBATROSS_LOSE_TARGET_PERIOD = 60,
        MALBATROSS_BOAT_DAMAGE = 5,
        MALBATROSS_BOAT_PUSH = 1,
        MALBATROSS_NOTHUNGRY_TIME =
        {
            MIN = 15,
            MAX = 25,
        },
        MALBATROSS_MISSFISH_TIME =
        {
            MIN = 10,
            MAX = 10,
        },
        MALBATROSS_ENTITYSLEEP_RELOCATE_TIME = 3 * total_day_time,
        MALBATROSS_EATSUCCESS_CHANCE = 0.50,
        MALBATROSS_MAX_CHASEAWAY_DIST = 50,
        MALBATROSS_NOTICEPLAYER_DISTSQ = 400, -- 20 * 20
        MALBATROSS_STOLENFISH_AGGROCOUNT = 2,
        MALBATROSS_HOOKEDFISH_SUMMONCHANCE = 0.1,

        OCEANFISH_SHOAL =
        {
            CHILD_REGENPERIOD = 3*seg_time,
            CHILD_SPAWNPERIOD = 5,
            MAX_CHILDREN = 8,
            SPAWNRADIUS = 6,
        },

		OCEANFISH =
		{
			WALKSPEED = 1.5,
			RUNSPEED = 3,
			FISHABLE_STAMINA =
			{
				drain_rate = 0.05, -- per second
				recover_rate = 0.1, -- per second
				struggle_times = {low = 3, high = 8, r_low = 1, r_high = 1}, -- uses self.stamina to lerp between low and high
				tired_times = {low = 4, high = 2, r_low = 1, r_high = 1}, -- uses self.stamina to lerp between low and high
			},

            SPRINKLER_DETECT_RANGE = 7,
            SPRINKLER_DETECT_PERIOD = 4,
		},

        GNARWAIL =
        {
            HEALTH = 1000,
            DAMAGE = 50,
            TARGET_DISTANCE = 9, -- TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 5,
            WALK_SPEED = 1.5,
            RUN_SPEED = 4,
            DIVE_SPEED = 10,
            EAT_DELAY = seg_time * 0.5,
            TOSS_DELAY = seg_time,
            LOYALTY_PER_HUNGER = total_day_time/25,
            MAX_LOYALTY_TIME = 2.5*total_day_time,
            FULL_LOYALTY_PERCENT = 0.9,

            BODY_SLAM_ATTACK_DISTANCESQ = 100,

            DAMAGE_RADIUS = 3,
            ATTACK_PERIOD = 14,
            BOATATTACK_RADIUSSQ = 2.25, -- 1.5 * 1.5
            BOAT_ATTACK_DELAY = 2.5,
            HORN_RETREAT_TIME = 3,
            HORN_HEALTH = 130,
            HORN_BOAT_DAMAGE = 20,
        },
        GNARWAIL_HORN =
        {
            USES = 10,
        },
		GNARWAIL_HORN_FARM_PLANT_INTERACT_RANGE = 20, -- castspell action distance

        SQUID_RUNSPEED = 6,
        SQUID_WALKSPEED = 3,
        SQUID_SWIM_SPEED = 4,
        SQUID_HEALTH = 170,
        SQUID_DAMAGE = 20/3,
        SQUID_TARGET_RANGE = 2,
        SQUID_ATTACK_RANGE = 1.5,
        SQUID_ATTACK_PERIOD = 4,
        SQUID_TARGET_DIST = 8,
        SQUID_TARGET_KEEP = 20,
        SQUID_LIGHT_UP_INTENSITY = 0.8,
        SQUID_LIGHT_UP_FALLOFF = 0.5,
        SQUID_LIGHT_UP_RADIUS = 1.2,
        SQUID_LIGHT_DOWN_INTENSITY = 0.5,
        SQUID_LIGHT_DOWN_FALLOFF = 1.25,
        SQUID_LIGHT_DOWN_RADIUS = 0.75,
		SQUID_FISHABLE_STAMINA =
		{
			drain_rate = 0.05, -- per second
			recover_rate = 0.1, -- per second
			struggle_times = {low = 3, high = 8, r_low = 1, r_high = 1}, -- uses self.stamina to lerp between low and high
			tired_times = {low = 4, high = 2, r_low = 1, r_high = 1}, -- uses self.stamina to lerp between low and high
		},

        SCHOOL_SPAWN_DELAY = {min=0.5*seg_time, max=2*seg_time},
		SCHOOL_SPAWNER_FISH_CHECK_RADIUS = 30,
        SCHOOL_SPAWNER_FISH_OCEAN_PERCENT = 0.1,
		SCHOOL_SPAWNER_MAX_FISH = 5,
		SCHOOL_SPAWNER_BLOCKER_MOD = 1/3, -- 3 or more blockers will prevent spawning
		SCHOOL_SPAWNER_BLOCKER_LIFETIME = total_day_time,

		FISH_BOX_PRESERVER_RATE = -1/3,
		SEEDPOUCH_PRESERVER_RATE = 0.5,


        -- Wintersfeast 2019
		WARG_GINGERBREAD_GOO_DIST_VAR = 3,
		WARG_GOO_DAMAGE = 20,
        WARG_GOO_RADIUS = 1.5,
		WARG_GINGERBREAD_GOO_COOLDOWN = 10,

        GINGERBREADPIG_RUN_SPEED = 10,

		WINTERSFEASTTABLE =
		{
            TABLE_RANGE = 3.5, -- this will make FEAST RANGE obsolete.
			FEAST_RANGE = 8,
			PERISH_TIME_DEPLETION = 50,
			PERISH_OVER_TIME_MULTIPLIER = 0.25,
		},
		WINTERSFEASTBUFF =
		{
			MAXDURATION = 50,
			DURATION_GAIN_BASE = 7,
			DURATION_GAIN_MAXBONUS = 15,
			DROP_SPIRIT_PERCENTAGE_THRESHOLD = 0.5,
            EATTIME = 180,
			TICKRATE = 2,
			HEALTH_GAIN = 1,
			HUNGER_GAIN = (calories_per_day/total_day_time)*2,
			SANITY_GAIN = 100/(night_time*10),
		},


        -- Year of the Carrat, 2020 --
        RACE_STATS =
        {
            MIN_STAT_VALUE = 0,
            MAX_STAT_VALUE = 5,
            INIT_STAT_VALUE = 0,

            BAD_STAT_SPREAD = 3,
            WILD_STAT_SPREAD = 5,
        },

        CARRAT_GYM =
        {
            TRAINS_PER_DAY = 4,
            TRAINING_TIME = 3*seg_time,
        },

		YOTC_ADDTORACE_DIST = 5,

		YOTC_RACER_MAX_VISITS_PER_CHECKPOINT = 5,
		YOTC_RACER_CHECKPOINT_FIND_DIST = 20,
		YOTC_RACER_CHECKPOINT_TOO_FAR_AWAY = 40, -- double YOTC_RACER_CHECKPOINT_FIND_DIST
        YOTC_RACER_CHECKPOINT_REACHED_DIST = 2,
		YOTC_RACER_FORGETFULNESS_MAX_CHECKPOINTS = 8,
		YOTC_RACER_CHECKPOINT_TIMEOUT = 75, -- racers will abort the race if it takes longer then this amount of time to get to the next check point

		YOTC_RACE_MAX_DISTANCE_REWARDS = 9,

		YOTC_RACER_STAMINA_BAD = 2,
		YOTC_RACER_STAMINA_GOOD = 22,
		YOTC_RACER_STAMINA_VAR = 3,
		YOTC_RACER_STAMINA_EXHAUSTED_TIME = 2,
		YOTC_RACER_STAMINA_EXHAUSTED_TIME_VAR = 1,
		YOTC_RACER_STAMINA_SLEEP_CHANCE = .1,
		YOTC_RACER_STAMINA_SLEEP_TIME = 3,
		YOTC_RACER_STAMINA_SLEEP_TIME_VAR = 3,

        YOTC_RACER_SPEED_BAD = 5, -- carrat's walk speed is 4
        YOTC_RACER_SPEED_GOOD = 7, -- carrat's run speed is 7
		YOTC_RACER_SPEED_VAR = 0.5,

		YOTC_RACER_REACTION_START_STUN_LOOPS_MIN = 4,
		YOTC_RACER_REACTION_START_STUN_LOOPS_MAX = 5,
		YOTC_RACER_REACTION_START_BAD = 2,
		YOTC_RACER_REACTION_START_GOOD = 0,
		YOTC_RACER_REACTION_START_BAD_VAR = 2,
		YOTC_RACER_REACTION_START_GOOD_VAR = 0,

		YOTC_RACER_DIRECTION_BAD = 100, -- +/- degrees
		YOTC_RACER_DIRECTION_GOOD = 30, -- +/- degrees

        YOTC_RACER_TRAINER_DIST = 6,

		MINIBOATLANTERN_SPEED = 0.4,
		MINIBOATLANTERN_ACCELERATION = 0.3*FRAMES,
		MINIBOATLANTERN_WANDER_DIST = 6,
        MINIBOATLANTERN_LIGHTTIME = total_day_time*6,
        MINIBOATLANTERN_BURNTIME = 1.7,

		YOT_CATCOON_SHRINE_SYMBOLS =
		{
			DEFAULT = "feather01",
			goose_feather = "goose_feather01",
		},
		
        KITCOON_WALK_SPEED = 2,
        KITCOON_RUN_SPEED = 6,

		KITCOON_LOYALTY_MAX				= seg_time * 4, -- DEPRECATED
		KITCOON_LOYALTY_EMOTE_CHANCE	= 0.4,
		KITCOON_NEAR_DEN_DIST			= 10,

		KITCOON_PLAY_DELAY				= 10, -- play with toys
		KITCOON_PLAYFUL_DELAY			= 10, -- play with other kitcoons
		KITCOON_PLAYFUL_DELAY_RAND		= 8, -- play with other kitcoons

		KITCOON_NAMING_DIST = 8,
		KITCOON_NAMING_MAX_LENGTH = 20,

        KITCOON_HIDEANDSEEK_HIDETIMEOUT = 3,

		KITCOONDEN_HIDEANDSEEK_MIN_KITCOONS = 3,
		KITCOONDEN_HIDEANDSEEK_HIDING_RADIUS_MAX = 30,
		KITCOONDEN_HIDEANDSEEK_HIDING_RADIUS_MIN_SQ = 5*5,
		KITCOONDEN_HIDEANDSEEK_TIME_LIMIT = 60,

        KITCOON_HIDING_SOUND_FREQUENCY = 10,
		KITCOON_HIDING_OFFSET = 
		{
			rock1					= {-175,    0,    0},
			rock2					= {-150,   50,    0},
			rock_flintless			= {-150,    0,    0},
			rock_flintless_med		= {  80,    0,    0},
			rock_flintless_low		= {-150,    0,    0},
			rock_moon				= {-115,   25,    0},
			rock_moon_shell			= {-175,    0,    0},

			berrybush				= {-130,    0,    0},
			berrybush2				= {-100,   25,    0},
			berrybush_juicy			= {-100,    0,    0},

			oasis_cactus			= { -25,   20,    0},
			cactus					= { -75,   20,    0},
		},

        TICOON_SPEED = 3.25,
		TICOON_EMBARK_SPEED = 7,
        TICOON_DAMAGE = 30,
        TICOON_LIFE = 200,

		KITCOON_HIDEANDSEEK_NOT_YOT_REWARDS =
		{
			flint					= 10,
			cutgrass				= 10,
			twigs					= 10,
			petals					= 10,

			acorn					= 3,
			pinecone				= 3,
			twiggy_nut				= 3,	-- oh, now players can get twiggy trees without them replacing saplings at world gen!

			rocks					= 3,
			petals_evil				= 3,
			spoiled_fish_small		= 3,

			feather_robin			= 3,
			feather_crow			= 3,
			feather_canary			= 3,

			oceanfish_small_2_inv	= 1,
			oceanfish_small_4_inv	= 1,

			trinket_3				= 1,
			trinket_6				= 1,
			trinket_22				= 2,
			trinket_24				= 1,
		},

        CRABKING_HEALTH = 20000,
        CRABKING_HEALTH_BONUS = 3000,

        CRABKING_CLAW_BOATDAMAGE = 35,
        CRABKING_CLAW_HEALTH = 500,
        CRABKING_CLAW_HEALTH_BOOST = 50,
        CRABKING_CLAW_WALK_SPEED = 1,
        CRABKING_CLAW_RUN_SPEED = 4,
        CRABKING_CLAW_RESPAWN_DELAY = 30,-- time each claw must regen for before being spawnable
        CRABKING_CLAW_PLAYER_DAMAGE = 15,
        CRABKING_CLAW_REGEN_DELAY = 5,  -- time between regening claws while healing
        CRABKING_BASE_CLAWS = 5,

        CRABKING_MAX_VELOCITY_MOD = 0,
        CRABKING_ANCHOR_DRAG = 10,

        CRABKING_STACKS = 20,
        CRABKING_DEADLY_GEYSERS = 5,
        CRABKING_GEYSER_BOATDAMAGE = 10,

        CRABKING_CAST_TIME = 8,
        CRABKING_CAST_TIME_FREEZE = 5,

        CRABKING_STACK_SUMMON_DELAY = 20,
        CRABKING_HEAL_DELAY = 40,
        CRABKING_CAST_DELAY = 5,
        CRABKING_FIX_TIME = 10,
        CRABKING_BASE_FREEZE_AMOUNT = 40,
        CRABKING_FREEZE_INCRAMENT = 10,
        CRABKING_FREEZE_RANGE = 10,
        CRABKING_REGEN = 650,
        CRABKING_REGEN_BUFF = 100,

        CRABKING_RESPAWN_TIME = total_day_time * 20,
        CRABKING_SPAWN_TIME = 1,
        SPAWN_CRABKING = true,

        CRABKING_CLAW_THRESHOLD = 0.9,
        CRABKING_HEAL_THRESHOLD = 0.85,
        CRABKING_FREEZE_THRESHOLD = 0.85,

        -- why not.
        CRABKING_DAMAGE = 150,
        CRABKING_DAMAGE_PLAYER_PERCENT = .5,
        CRABKING_ATTACK_RANGE = 5,
        CRABKING_AOE_RANGE = 3,
        CRABKING_AOE_SCALE = 0.8,
        CRABKING_ATTACK_PERIOD = 4,

        TRIDENT =
        {
            DAMAGE = wilson_attack * 0.8, -- Same damage as an axe... hahaha.
            OCEAN_DAMAGE = wilson_attack * 2,
            USES = 150,
            SPELL =
            {
                USE_COUNT = 50,
                RADIUS = 2.75,
                DAMAGE = wilson_attack * 2.5,
                MINES = 10,
            },
        },
		TRIDENT_FARM_PLANT_INTERACT_RANGE = 20, -- castspell action distance


        WOBSTER_DEN_REGEN_PERIOD = 3*seg_time,
        WOBSTER_DEN_SPAWN_PERIOD = 4*seg_time,
        WOBSTER_DEN_MAX_CHILDREN = 2,
        WOBSTER_DEN_SPAWNRADIUS = 4,
        WOBSTER_DEN_WORK = 9,
        WOBSTER_DEN_ENABLED = true,

        --UNUSED
        WOBSTER_DEN =
        {
            REGEN_PERIOD = 3*seg_time,
            SPAWN_PERIOD = 4*seg_time,
            MAX_CHILDREN = 2,

            SPAWNRADIUS = 4,
            WORK = 9,
        },

        WOBSTER =
        {
            SURVIVE_TIME = 4*total_day_time,
            HEALTH = 25 * multiplayer_attack_modifier,
            SPEED =
            {
                SWIM = 0.5,
                GROUND = 1,
            },
            FISHABLE_STAMINA =
            {
                drain_rate = 0.05,
                recover_rate = 0.1,
                struggle_times =
                {
                    low = 3,
                    high = 8,
                    r_low = 1,
                    r_high = 1,
                },
                tired_times =
                {
                    low = 4,
                    high = 2,
                    r_low = 1,
                    r_high = 1,
                },
            },
		},

		BOAT_WINCH =
		{
			LOWERING_SPEED = 2,
			RAISING_SPEED_FAST = 1.8,
			RAISING_SPEED_SLOW = 1.1,

			DURATION_LOWERED_SUCCESS = 1,
			DURATION_LOWERED_FAILURE = 0.5,

			BOAT_DRAG_DURATION = 1,
		},

        HERMITCRAB =
        {
            UNFRIENDLY_LEVEL = 0,
            SPEAKTIME = 3.5,
            DANCE_RANGE = 8,
            WALKSPEED = 2.8,
            RUNSPEED = 5,

            HEAVY_FISH_THRESHHOLD = 0.70,

            MEETING_RADIUS = 16,
        },

        MESSAGEBOTTLE_NOTE_CHANCE = 0.66,

        SINGINGSHELL_TRIGGER_RANGE = 4,
        SINGINGSHELL_FARM_PLANT_INTERACT_RANGE = 2,

        WATERPLANT =
        {
            DAMAGE = wilson_attack * 2,
            ITEM_DAMAGE = wilson_attack * 0.7,
            ATTACK_PERIOD = 5,
            YELLOW_ATTACK_PERIOD = 2.5,
            ATTACK_DISTANCE = 18,
            ATTACK_AOE = 1.5,
            HEALTH = 500,

            MAX_BARNACLES = 3,
            GROW_TIME = 2.5 * total_day_time,
            GROW_VARIANCE = 1.5 * total_day_time,
            REBIRTH_TIME = 2 * total_day_time,

            ANGERING_HIT_VELOCITY = 2.01,

            POLLEN_DURATION = 25,
            POLLEN_FADETIME = 2,
            POLLEN_RESETTIME = seg_time * 6,
            PINK_POLLEN_RESETTIME = seg_time * 3,
            POLLEN_RESETVARIANCE = seg_time / 2,

            FISH_SPAWN =
            {
                MAX_CHILDREN = 1,
                SPAWN_RADIUS = 4.5,
                REGEN_PERIOD = seg_time * 8,
                WHITE_REGEN_PERIOD = seg_time * 4,
            },
        },

        WATERPLANT_ROCK_WORKAMOUNT = 3,

        WAVEYJONES =
        {
            HAND =
            {
                WALK_SPEED = 1,--0.5,
            },
            RESPAWN_TIMER = 10,
        },

        SHARK =
        {
            DAMAGE = 30,
            HEALTH = 1000,
            WALK_SPEED = 1,
            RUN_SPEED = 7,

            WALK_SPEED_LAND = 7,
            RUN_SPEED_LAND = 7,

            ATTACK_RANGE = 4,

            TARGET_DIST = 8, --20,

            AOE_RANGE = 3,
            AOE_SCALE = 0.5,
        },

        OCEANHORROR =
        {
            ATTACH_OFFSET_PADDING = 0.5,

            ATTACK_RANGE = 4.1,
            SPEED = 2,
            HEALTH = 400,
            DAMAGE = 50,
            ATTACK_PERIOD = 3,
            BLOCK_TELEPORT_ON_HIT_DURATION = 3.5,
            BLOCK_TELEPORT_ON_HIT_DURATION_VARIANCE = 2,
        },

        MAST_LAMP_LIGHTTIME = (night_time+dusk_time)*2,

        WATERSTREAK_AOE_DIST = 3,

        WATERPUMP =
        {
            MAXRANGE = 7.5,
        },

        -- GROTTO

        SLEEPRESISTBUFF_TIME = total_day_time,
        SLEEPRESISTBUFF_VALUE = 10,

        MOON_MUSHROOM_SLEEPTIME = 3,

        MOLEBAT_TARGET_DIST = 5,
        MOLEBAT_WALK_SPEED = 5,
        MOLEBAT_ATTACK_PERIOD = 2,
        MOLEBAT_ATTACK_RANGE = 2,
        MOLEBAT_HEALTH = 150,
        MOLEBAT_DAMAGE = 30,
        MOLEBAT_MAX_CHASE_DSQ = 225,
        MOLEBAT_NAP_COOLDOWN = seg_time * 9,
        MOLEBAT_NAP_LENGTH = seg_time * 4,
        MOLEBAT_ALLY_COOLDOWN = total_day_time * 2,
        MOLEBAT_ENABLED = true,

        --UNUSED
        MOLEBAT =
        {
            TARGET_DIST = 5,
            WALK_SPEED = 5,
            ATTACK_PERIOD = 2,
            ATTACK_RANGE = 2,
            HEALTH = 150,
            DAMAGE = 30,
            MAX_CHASE_DSQ = 225,
            ALLY_COOLDOWN = total_day_time * 2,
            NAP_COOLDOWN = seg_time * 9,
            NAP_LENGTH = seg_time * 4,
        },

        BATNOSEHAT_PERISHTIME = 0.5*total_day_time*perish_warp,
        HUNGERREGEN_TICK_RATE = 5,
        HUNGERREGEN_TICK_VALUE = 5 * (calories_per_day*2.5) / (0.5*total_day_time*perish_warp), -- Ensure that this matches the properties above!

        LIGHTFLIER =
        {
            HEALTH = 25 * multiplayer_attack_modifier,
            WALK_SPEED = 3.5,
            ON_ATTACKED_ALERT_DURATION = 4,
            ON_ATTACKED_ALERT_DURATION_VARIANCE = 1,
            STARVE_TIME = total_day_time*2,
        },

        LIGHTFLIER_FLOWER_REGROW_TIME = total_day_time*12, -- this refers to regrow after picked, not duration for regrowthmanager
        LIGHTFLIER_FLOWER_LIGHT_TIME = 140,
        LIGHTFLIER_FLOWER_LIGHT_TIME_VARIANCE = 50,
        LIGHTFLIER_FLOWER_RECHARGE_TIME = 110,
        LIGHTFLIER_FLOWER_TARGET_NUM_CHILDREN_OUTSIDE = 1,
        LIGHTFLIER_FLOWER_PICKABLE = true,

        LIGHTFLIER_FLOWER_RECALL_DELAY = 60,
        LIGHTFLIER_FLOWER_RECALL_DELAY_VARIANCE = 60,

        LIGHTFLIER_FLOWER_REGROWTH_TIME = total_day_time*5,
        LIGHTFLIER_FLOWER_REGROWTH_TIME_MULT = 1,

        LIGHTFLIER_FLOWER =
        {
            REGROW_TIME = total_day_time*12, -- this refers to regrow after picked, not duration for regrowthmanager
            LIGHT_TIME = 140,
            LIGHT_TIME_VARIANCE = 50,
            RECHARGE_TIME = 110,
            TARGET_NUM_CHILDREN_OUTSIDE = 1,

            RECALL_DELAY = 60,
            RECALL_DELAY_VARIANCE = 60,

            REGROWTH =
            {
                TIME = total_day_time*5,
                TIME_MULT = 1,
            },
        },

        MUSHGNOME_HEALTH = 600,
        MUSHGNOME_SPORESPAWN_MIN = 2,
        MUSHGNOME_SPORESPAWN_MAX = 4,
        MUSHGNOME_ATTACK_PERIOD = 8,
        MUSHGNOME_SPAWN_RADIUSSQ = 400,

        MOONSPORE_ATTACK_RANGE = 3,
        MOONSPORE_ATTACK_PROXIMITY = 3.5,
        MOONSPORE_DAMAGE = 10,
        MOONSPORE_PERISH_TIME = seg_time * 0.25,

        GROTTO_POOL_BIG_RADIUS = 5.5,
        GROTTO_POOL_SMALL_RADIUS = 2.0,
        GROTTO_MOONGLASS_REGROW_CHANCE = 0.10,

        ARCHIVE_CENTIPEDE =
        {
            DAMAGE = 40,
            AOE_DAMAGE = 20,
            HEALTH = 400 * 3,
            WALK_SPEED = 4,
            ATTACK_PERIOD = 5,
            HUSK_HEALTH = 300,
            AOE_RANGE = 5,
            TARGET_DIST = 12,
        },

        ARCHIVE_SECURITY =
        {
            REGEN_TIME = seg_time * 4,
            RELEASE_TIME = seg_time,
            WALK_SPEED = 5,
        },
        DUSTMOTH =
        {
            HEALTH = 200,
            HEALTH_REGEN = 4,
            WALK_SPEED = 2.6,
            DUSTABLE_RESET_TIME = seg_time * 2,
            DUSTABLE_RESET_TIME_VARIANCE = seg_time,
            DUSTOFF_COOLDOWN = 4,
            DUSTOFF_COOLDOWN_VARIANCE = 6,
            SEARCH_ANIM_COOLDOWN = 12,
        },
        DUSTMOTHDEN_REPAIR_TIME = total_day_time * 0.75,
        DUSTMOTHDEN_REGEN_TIME = total_day_time * 10,
        DUSTMOTHDEN_RELEASE_TIME = seg_time,
        DUSTMOTHDEN_MAX_CHILDREN = 1,
        DUSTMOTHDEN_MAXWORK = 5,
        DUSTMOTHDEN_ENABLED = true,

        --UNUSED
        DUSTMOTHDEN =
        {
            REPAIR_TIME = total_day_time * 0.75,
            REGEN_TIME = total_day_time * 10,
            RELEASE_TIME = seg_time,
            MAXWORK = 5,
        },

        ARCHIVE_RESONATOR =
        {
            USES = 10,
        },

		DAYLIGHT_SEARCH_RANGE = 30,

		-- Farming
		FARM_TILL_SPACING = 1.25,
		FARM_PLANT_PHYSICS_RADIUS = 0.5,

		STARTING_NUTRIENTS_MIN = 20,
		STARTING_NUTRIENTS_MAX = 40,

        FARM_PLOW_USES = 4,
		FARM_PLOW_DRILLING_DURATION = seg_time * 0.5,
		FARM_PLOW_DRILLING_DEBRIS_MIN = 2,
		FARM_PLOW_DRILLING_DEBRIS_MAX = 4,

		FARM_PLOW_DRILLING_DIRT_DELAY_BASE_START = 1.5,
		FARM_PLOW_DRILLING_DIRT_DELAY_BASE_END = 0.2,
		FARM_PLOW_DRILLING_DIRT_DELAY_VAR = 0.3,

		SOIL_MOISTURE_UPDATE_TIME = 5,
		SOIL_RAIN_MOD = 1.5,
		SOIL_MIN_DRYING_TEMP = 0,
		SOIL_MAX_DRYING_TEMP = 70, -- same as OVERHEAT_TEMP
		SOIL_MIN_TEMP_DRY_RATE = 0,
		SOIL_MAX_TEMP_DRY_RATE = -0.05,
        SOIL_MAX_MOISTURE_VALUE = 100, --same as weather's max moisture

		FARM_SOIL_DEBRIS_LOOT_CHANCE = 0.25,

        ICE_MELT_GROUND_MOISTURE_AMOUNT = 25,

        WATERINGCAN_WATER_AMOUNT = 25,
        WATERINGCAN_USES = 40,
        WATERINGCAN_EXTINGUISH_HEAT_PERCENT = -1,
        WATERINGCAN_TEMP_REDUCTION = 5,
        WATERINGCAN_PROTECTION_TIME = 30,
		WATERINGCAN_PROTECTION_DIST = 2.25,

        PREMIUMWATERINGCAN_WATER_AMOUNT = 25,
        PREMIUMWATERINGCAN_USES = 160,

		FARM_PLANT_LONG_LIFE_MULT = 1.5,

		FARM_PLANT_CONSUME_NUTRIENT_LOW = 2,
		FARM_PLANT_CONSUME_NUTRIENT_MED = 4,
		FARM_PLANT_CONSUME_NUTRIENT_HIGH = 8,

		FARM_PLANT_DRINK_LOW =  -0.0075,
		FARM_PLANT_DRINK_MED =  -0.0200,
		FARM_PLANT_DRINK_HIGH = -0.0350,

		FARM_PLANT_DROUGHT_TOLERANCE = 0.10,

		FARM_PLANT_KILLJOY_RADIUS = 6,
		FARM_PLANT_KILLJOY_TOLERANCE = 0,

		FARM_PANT_OVERCROWDING_MAX_PLANTS = 10,

		FARM_PLANT_SAME_FAMILY_MIN = 4,  -- includes the plant doing the test
        FARM_PLANT_SAME_FAMILY_RADIUS = 4,

		SEASONAL_WEED_SPAWN_CAHNCE =
		{
			autumn = 0.05,
			spring = 0.15,
		},

		FORGETMELOTS_RESPAWNER_MIN = total_day_time * 2,
		FORGETMELOTS_RESPAWNER_VAR = total_day_time * 3,

		FIRE_NETTLE_TOXIN_TEMP_MODIFIER = 60,
		FIRE_NETTLE_TOXIN_DURATION = seg_time * 2,
		WEED_FIRENETTLE_DAMAGE = 3,

		WEED_TILLWEED_MAX_DEBRIS = 5,
		WEED_TILLWEED_DEBRIS_TIME_MIN = total_day_time * 0.75,
		WEED_TILLWEED_DEBRIS_TIME_VAR = total_day_time * 0.25,

        TILLWEEDSALVE_HEALTH_DELTA = 1,
        TILLWEEDSALVE_TICK_RATE = 3,
        TILLWEEDSALVE_DURATION = seg_time * 2,

		SWEETTEA_SANITY_DELTA = 1,
		SWEETTEA_TICK_RATE = 2,
		SWEETTEA_DURATION = seg_time * 2,

		FARM_PLANT_DEFENDER_SEARCH_DIST = 10,
		WEED_IVY_SNARE_DAMAGE = 10,

		BOOK_GARDENING_MAX_TARGETS = 10,

        COMPOSTINGBIN_COMPOSTING_TIME_MIN = day_time*0.8,
        COMPOSTINGBIN_COMPOSTING_TIME_MAX = day_time*1.6,
        COMPOSTINGBIN_TURN_COMPOST_DURATION_MULTIPLIER = 0.7,

        COMPOST_FERTILIZE = day_time,
        COMPOST_SOILCYCLES = 10,
        COMPOST_WITHEREDCYCLES = 1,

		FORMULA_NUTRIENTS_INDEX = 1,
		COMPOST_NUTRIENTS_INDEX = 2,
		MANURE_NUTRIENTS_INDEX = 3,

        POOP_NUTRIENTS					= {  0,  0,  8 },
		FERTILIZER_NUTRIENTS			= {  0,  0, 16 },
        GUANO_NUTRIENTS					= {  0,  0, 16 },

        SPOILED_FOOD_NUTRIENTS			= {  0,  8,  0 },
		ROTTENEGG_NUTRIENTS				= {  0, 16,  0 },
        COMPOST_NUTRIENTS				= {  0, 24,  0 },

        SPOILED_FISH_SMALL_NUTRIENTS	= {  8,  0,  0 },
        SPOILED_FISH_NUTRIENTS			= { 16,  0,  0 },
		SOILAMENDER_NUTRIENTS_LOW		= {  8,  0,  0 },
		SOILAMENDER_NUTRIENTS_MED		= { 16,  0,  0 },
		SOILAMENDER_NUTRIENTS_HIGH		= { 32,  0,  0 },

        COMPOSTWRAP_NUTRIENTS			= { 24, 32, 24 },
        GLOMMERFUEL_NUTRIENTS			= {  8,  8,  8 },

        TREEGROWTH_NUTRIENTS            = {  8, 32,  8 },

		WORMWOOD_MANURE_HEAL_VALUES = { 2, 3, 8, 12 },

		WORMWOOD_COMPOST_HEAL_VALUES = { 4, 6, 8, 32 },
		WORMWOOD_COMPOST_HEALOVERTIME_HEALTH = 2,
		WORMWOOD_COMPOST_HEALOVERTIME_TICK = 2,

--[[
		FERTILIZER_HEAL_1 = 2,
		FERTILIZER_HEAL_2 = 4,
		FERTILIZER_HEAL_3 = 8, -- medsmall
		FERTILIZER_HEAL_4 = 30,
]]

        LORDFRUITFLY_DEAGGRO_DIST = 30,
        LORDFRUITFLY_TARGETRANGE = 15,
        LORDFRUITFLY_ATTACK_PERIOD = 2,
        LORDFRUITFLY_DAMAGE = 25,
        LORDFRUITFLY_ATTACK_DIST = 2,
        LORDFRUITFLY_HEALTH = 1500,
        LORDFRUITFLY_SUMMONPERIOD = 30,
        LORDFRUITFLY_INITIALSPAWN_TIME = total_day_time * 35,
        LORDFRUITFLY_RESPAWN_TIME = total_day_time * 20,
        LORDFRUITFLY_CROP_ROTTED_ADVANCE_TIME = total_day_time * 0.5,
        LORDFRUITFLY_SPAWNERRADIUS = 4,
        LORDFRUITFLY_SPAWNERCOUNT = 15,
        SPAWN_LORDFRUITFLY = true,
        LORDFRUITFLY_FRUITFLY_AMOUNT = 4,
        LORDFRUITFLY_WALKSPEED = 4,
        LORDFRUITFLY_TRIGGER_RANGE = 15,

        FRUITFLY_DEAGGRO_DIST = 20,
        FRUITFLY_HEALTH = 100,
        FRUITFLY_DAMAGE = 5,
        FRUITFLY_ATTACK_DIST = 1,
        FRUITFLY_ATTACK_PERIOD = 2,
        FRUITFLY_TARGETRANGE = 15,
        FRUITFLY_WALKSPEED = 8,

		-- WES rework
		BALLOON_DAMAGE = 5,
		BALLOON_ATTACK_RANGE = 2,

		BALLOON_SPEEDS = {1, 1.1, 1.2, 1.3},
		BALLOON_SPEED_DURATION = total_day_time * 0.25,

        BALLOON_PILE_DECAY_TIME = total_day_time * 3,
		BALLOON_MAP_ICON_DURATION = 10,

		CONFFETI_PARTY_SANITY_TICKRATE = 2,
		CONFFETI_PARTY_SANITY_DELTA =
		{
			0,
			1,
			2,
			3,
			3.5,
			4,
		},

		-- Crow Carnival
		CARNIVAL_DECOR_RANK_RANGE = 8,
		CARNIVAL_DECOR_RANK_MAX = 3,
		CARNIVAL_DECOR_VALUE_PER_RANK = 100,

		CARNIVAL_THEME_MUSIC_RANGE = 12,

		CARNIVALGAME_DURATION = 30,

		CARNIVALGAME_FEEDCHICKS_NUM_ACTIVE = 5,
		CARNIVALGAME_FEEDCHICKS_HUNGRY_DURATION = 3,
		CARNIVALGAME_FEEDCHICKS_HUNGRY_DURATION_VAR = 1,
		CARNIVALGAME_FEEDCHICKS_ARENA_RADIUS = 8,
		CARNIVALGAME_FEEDCHICKS_NUM_FOOD = 4,

		CARNIVALGAME_HERDING_ARENA_RADIUS = 10,

		CARNIVALGAME_MEMORY_ARENA_RADIUS = 6,

		CARNIVALGAME_CAMERA_FOCUS_MIN = 8,
		CARNIVALGAME_CAMERA_FOCUS_MAX = 8,

        CARNIVAL_HOST_TALK_TO_PLAYER_COOLDOWN = 10,

        CARNIVAL_CROWKID_RUN_SPEED = 5,
        CARNIVAL_CROWKID_WALK_SPEED = 3,
        CARNIVAL_CROWKID_TALK_TO_PLAYER_COOLDOWN = 15,
		CROWKID_ACTIVATE_DECOR_DELAY_MIN = 15,
		CROWKID_ACTIVATE_DECOR_DELAY_MAX = 30,
		CROWKID_ACTIVATE_DECOR_CHAIN_DELAY = 60,

        CARNIVAL_VEST_PERISHTIME = total_day_time*5,

		CARNIVALDECOR_LAMP_ACTIVATE_TIME = seg_time * 2,
		CARNIVALDECOR_LAMP_TOKEN_TIME = total_day_time,

		CARNIVALDECOR_EGGRIDE_ACTIVATE_TIME = seg_time,
		CARNIVALDECOR_EGGRIDE_TOKEN_TIME = total_day_time * 5,

        CARNIVAL_BALL_COLLISIONTIMEBUFFER = 8 * FRAMES,
        CARNIVAL_BALL_YBOUNCE = 20.0,        -- YOTB: Year of the Beefalo
        BASE_SEWING_TIME = night_time*.3333,
        REJECTION_SEWING_TIME = night_time*.3333,
        YOTB_STAGERANGE = 12,
        YOTB_POSTDISTANCE = 5,

        BEEFALO_NAMING_DIST = 12,
		BEEFALO_NAMING_MAX_LENGTH = 50,

        DEERCLOPS_ATTACKS_PER_SEASON = 4,
        DEERCLOPS_ATTACKS_OFF_SEASON = false,
        SPAWN_DEERCLOPS = true,

        BEARGER_CHANCES = {1},
        SPAWN_BEARGER = true,

        MOOSE_DENSITY = 0.5,

        MAX_BUTTERFLIES = 4,

        LUREPLANT_SPAWNINTERVAL = total_day_time * 4,
        LUREPLANT_SPAWNINTERVALVARIANCE = total_day_time * 1,

        PENGUINS_FLOCK_SIZE = 9,
        PENGUINS_MIN_DIST_FROM_STRUCTURES = 20,
        PENGUINS_MAX_COLONIES = 5,
        PENGUINS_MAX_COLONIES_BUFFER = 1,
        PENGUINS_SPAWN_INTERVAL = 30,

        PENGUINS_DEFAULT_NUM_BOULDERS = 7,

        QUAKE_FREQUENCY_MULTIPLIER = 1,

        SPAWN_MOON_PENGULLS = true,
        SPAWN_MUTATED_HOUNDS = true,

        RABBITHOLE_REGROWTH_TIME_MULT = 0,
        RABBITHOLE_REGROWTH_TIME_SUMMER_MULT = 1,

        REEDS_REGROWTH_TIME_MULT = 0,
        REEDS_REGROWTH_TIME_SPRING_MULT = 1,

        PIGHOUSE_SPAWN_TIME = total_day_time * 4,
        PIGHOUSE_ENABLED = true,
        RABBITHOUSE_SPAWN_TIME = total_day_time,
        RABBITHOUSE_ENABLED = true,

        SLURTLEHOLE_REGEN_PERIOD = seg_time*4,
        SLURTLEHOLE_SPAWN_PERIOD = 3,
        SLURTLEHOLE_CHILDREN = {min = 1, max = 2},
        SLURTLEHOLE_ENABLED = true,
        SLURTLEHOLE_RARECHILD_CHANCE = 0.1,

        MONKEYBARREL_REGEN_PERIOD = seg_time*4,
        MONKEYBARREL_SPAWN_PERIOD = seg_time,
        MONKEYBARREL_CHILDREN = {min = 3, max = 4},
        MONKEYBARREL_ENABLED = true,

        ROCKYHERD_SPAWNER_RANGE = 20,
        ROCKYHERD_SPAWNER_DENSITY = 6,

        MALBATROSS_SPAWNDELAY_BASE = total_day_time * 10,
        MALBATROSS_SPAWNDELAY_RANDOM = total_day_time * 5,
        MALBATROSS_SHOAL_PERCENTAGE_TO_TEST = 0.25,
        SPAWN_MALBATROSS = true,

        EVERGREEN_REGROWTH_TIME_MULT = 1,
        TWIGGYTREE_REGROWTH_TIME_MULT = 1,
        DECIDIOUS_REGROWTH_TIME_MULT = 1,
        MUSHTREE_REGROWTH_TIME_MULT = 1,
        MOONTREE_REGROWTH_TIME_MULT = 1,
        MOONMUSHTREE_REGROWTH_TIME_MULT = 1,

        MUSHGNOME_RELEASE_TIME = 20,
        MUSHGNOME_REGEN_TIME = total_day_time,
        MUSHGNOME_MAX_CHILDREN = 1,
        MUSHGNOME_ENABLED = true,

        NIGHTMARELIGHT_RELEASE_TIME = 5,
        NIGHTMARELIGHT_REGEN_TIME = seg_time,
        NIGHTMARELIGHT_MINCHILDREN = 1,
        NIGHTMARELIGHT_MAXCHILDREN = 2,
        NIGHTMARELIGHT_ENABLED = true,
        NIGHTMAREFISSURE_RELEASE_TIME = 5,
        NIGHTMAREFISSURE_REGEN_TIME = seg_time,
        NIGHTMAREFISSURE_MAXCHILDREN = 1,
        NIGHTMAREFISSURE_ENABLED = true,

        SHARK_SPAWN_CHANCE = 0.075,
        SHARK_TEST_RADIUS = 100,

        GNARWAIL_SPAWN_CHANCE = 0.075,
        GNARWAIL_TEST_RADIUS = 100,

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

        DROPPERWEB_RELEASE_TIME = total_day_time/2,
        DROPPERWEB_REGEN_TIME = total_day_time/4,
        DROPPERWEB_MIN_CHILDREN = 2,
        DROPPERWEB_MAX_CHILDREN = 3,
        DROPPERWEB_ENABLED = true,

        SPIDERHOLE_RELEASE_TIME = total_day_time/2,
        SPIDERHOLE_REGEN_TIME = total_day_time/4,
        SPIDERHOLE_MIN_CHILDREN = 2,
        SPIDERHOLE_MAX_CHILDREN = 3,
        SPIDERHOLE_SPITTER_CHANCE = 0.33,
        SPIDERHOLE_ENABLED = true,

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

        -- Moon Storms
        ALTERGUARDIAN_PLAYERDAMAGEPERCENT = 0.75,

        ALTERGUARDIAN_PHASE1_WALK_SPEED = 5,
        ALTERGUARDIAN_PHASE1_HEALTH = 10000,
        ALTERGUARDIAN_PHASE1_ROLLDAMAGE = 166.67,
        ALTERGUARDIAN_PHASE1_AOEDAMAGE = 66.67,
        ALTERGUARDIAN_PHASE1_ATTACK_PERIOD = 7.5,
        ALTERGUARDIAN_PHASE1_AOERANGE = 4.25,
        ALTERGUARDIAN_PHASE1_ROLLCOOLDOWN = 8.5,
        ALTERGUARDIAN_PHASE1_MINROLLCOUNT = 3,
        ALTERGUARDIAN_PHASE1_SUMMONCOOLDOWN = 20,
        ALTERGUARDIAN_PHASE1_TARGET_DIST = 20,
        ALTERGUARDIAN_PHASE1_SHIELDTRIGGER = 2000,
        ALTERGUARDIAN_PHASE1_SHIELDABSORB = 0.80,

        ALTERGUARDIAN_PHASE2_WALK_SPEED = 4.5,
        ALTERGUARDIAN_PHASE2_MAXHEALTH = 20000,
        ALTERGUARDIAN_PHASE2_STARTHEALTH = 13000,
        ALTERGUARDIAN_PHASE2_DAMAGE = 133.33,
        ALTERGUARDIAN_PHASE2_ATTACK_PERIOD = 6.0,
        ALTERGUARDIAN_PHASE2_CHOP_RANGE = 4.5,
        ALTERGUARDIAN_PHASE2_SPIN_RANGE = 18,
        ALTERGUARDIAN_PHASE2_SPIN_SPEED = 7.6,
        ALTERGUARDIAN_PHASE2_SPINMIN = 3,
        ALTERGUARDIAN_PHASE2_SPINMAX = 5,
        ALTERGUARDIAN_PHASE2_SPINCD = 14.25,
        ALTERGUARDIAN_PHASE2_SPIKEDAMAGE = 50,
        ALTERGUARDIAN_PHASE2_SPIKECOOLDOWN = 18.25,
        ALTERGUARDIAN_PHASE2_SPIKE_RANGE = 10,
        ALTERGUARDIAN_PHASE2_SPIKE_LIFETIME = 30,
        ALTERGUARDIAN_PHASE2_SUMMONCOOLDOWN = 24.25,
        ALTERGUARDIAN_PHASE2_TARGET_DIST = 30,

        ALTERGUARDIAN_PHASE3_WALK_SPEED = 7.5,
        ALTERGUARDIAN_PHASE3_MAXHEALTH = 22500,
        ALTERGUARDIAN_PHASE3_STARTHEALTH = 14000,
        ALTERGUARDIAN_PHASE3_RUNAWAY_BLOCK_TIME = 1.0,
        ALTERGUARDIAN_PHASE3_GOHOMEDSQ = 144,
        ALTERGUARDIAN_PHASE3_DAMAGE = 150,
        ALTERGUARDIAN_PHASE3_LASERDAMAGE = 120,
        ALTERGUARDIAN_PHASE3_ATTACK_PERIOD = 5.0,
        ALTERGUARDIAN_PHASE3_ATTACK_RANGE = 14,
        ALTERGUARDIAN_PHASE3_STAB_RANGE = 3.5,
        ALTERGUARDIAN_PHASE3_STAB_HITRANGE = 2,
        ALTERGUARDIAN_PHASE3_TRAP_CD = 40,
        ALTERGUARDIAN_PHASE3_TRAP_LT = 20,
        ALTERGUARDIAN_PHASE3_TRAP_MINRANGE = 2.0,
        ALTERGUARDIAN_PHASE3_TRAP_MAXRANGE = 3.5,
        ALTERGUARDIAN_PHASE3_TRAP_AOERANGE = 3.0,
        ALTERGUARDIAN_PHASE3_TRAP_GROGGINESS = 1.0,
        ALTERGUARDIAN_PHASE3_TRAP_KNOCKOUTTIME = 3.0,
        ALTERGUARDIAN_PHASE3_TRAP_LANDEDDAMAGE = 50,
        ALTERGUARDIAN_PHASE3_TRAP_WORKS = 3,
        ALTERGUARDIAN_PHASE3_SUMMONCOOLDOWN = 45,
        ALTERGUARDIAN_PHASE3_SUMMONMAXLOOPS = 60,
        ALTERGUARDIAN_PHASE3_SUMMONRSQ = 400, --20 ^2
        ALTERGUARDIAN_PHASE3_TARGET_DIST = 20,
		ALTERGUARDIAN_PHASE3_MAX_STUN_LOCKS = 5,

        ALTERGUARDIAN_PROJECTILE_SPEED = 20,

		ALTERGUARDIANHAT_GESTALT_DAMAGE = wilson_attack * 1.25,

        WAGSTAFF_NPC_EXPIRE_TIME = seg_time * 4,
        WAGSTAFF_NPC_HUNTS = 4,
        WAGSTAFF_EXPERIMENT_TIME = 90,

        MOONSTORM_MOVE_TIME = 4,
        MOONSTORM_MOVE_MAX = 6,

        MUTANT_BIRD_AGGRO_DIST = 15,
        MUTANT_BIRD_RETURN_DIST = 30,
        MUTANT_BIRD_DAMAGE = 20,
        MUTANT_BIRD_HEALTH = 10,
        MUTANT_BIRD_SPLASH_DAMAGE = 20,
        MUTANT_BIRD_TARGET_DIST = 16,
        MUTANT_BIRD_ATTACK_RANGE = 2,
        MUTANT_BIRD_WALK_SPEED = 4,
        MUTANT_BIRD_ATTACK_COOLDOWN = 6,
        MUTANT_BIRD_SPIT_RANGE = 10,

        MOONSTORM_SPARK_HEALTH = 100,

        MOONSTORM_GOGGLES_PERISHTIME = total_day_time*1,

        MOONSTORM_SPEED_MOD = .4,

        STORM_SWAP_TIME = 4/30,

        MOON_ALTAR_LINK_AREA_CLEAR_RADIUS = 6,
        MOON_ALTAR_LINK_POINT_VALID_RADIUS_SQ = 2.5*2.5,
        MOON_ALTAR_LINK_ALTAR_MIN_RADIUS_SQ = 2.5*2.5,
		
        MOONGLASS_CHARGED_PERISH_TIME = total_day_time*1.5,
        SPARK_PERISH_TIME = total_day_time*0.75,

        SPIDER_SUMMON_TIME = 12,
        SPIDER_WHISTLE_USE_AMOUNT = 2.5,
        SPIDER_DEN_SHAVING_AMOUNT = 1,
        
        SPIDER_PERISH_TIME = total_day_time * 5,
        
        SPIDER_HEALER_HEALTH = 400,
        SPIDER_HEALER_DAMAGE = 10,

        SPIDER_HEALING_AMOUNT = 150,
        SPIDER_HEALING_RADIUS = 8,
        SPIDER_HEALING_COOLDOWN = 8,
        SPIDER_HEALING_MELEE_RANGE = 1,

        SPIDER_HEALING_ITEM_AMOUNT = 80,
        SPIDER_HEALING_ITEM_RADIUS = 5,

        SPIDER_WHISTLE_DURATION = 10,
        SPIDER_WHISTLE_RANGE = 16,

        SPIDER_DEFENSIVE_MIN_FOLLOW = 2,
        SPIDER_DEFENSIVE_MED_FOLLOW = 2,
        SPIDER_DEFENSIVE_MAX_FOLLOW = 4,
        SPIDER_AGGRESSIVE_MIN_FOLLOW = 2,
        SPIDER_AGGRESSIVE_MED_FOLLOW = 3,
        SPIDER_AGGRESSIVE_MAX_FOLLOW = 8,
        
        SPIDER_DEFENSIVE_MAX_CHASE_TIME = 3,
        SPIDER_AGGRESSIVE_MAX_CHASE_TIME = 8,

        BEDAZZLEMENT_RATE = 1,
        BEDAZZLEMENT_RADIUS = { 12, 16, 20 },
        BEDAZZLEMENT_DURATION = 2,
        BEDAZZLER_USE_AMOUNT = 20,

        SPIDERDEN_CREEP_RADIUS_BEDAZZLED = 4,
        SPIDERDEN_CREEP_RADIUS = {5, 9, 9 },

        SPIDER_REPELLENT_USES = 20,
        SPIDER_REPELLENT_RADIUS = 8,

        SPIDER_FOLLOWER_COUNT = 2,

        FOLLOWER_REFOLLOW_DIST_SQ = 20 * 20,

        -- Waterlogged
        OCEANVINE_ENABLED = true,
        OCEANVINE_COCOON_SPIDER_RADIUS = 16,
        OCEANVINE_COCOON_REGEN_TIME = total_day_time/4,
        OCEANVINE_COCOON_RELEASE_TIME = total_day_time/2,
        OCEANVINE_COCOON_MIN_CHILDREN = 2,
        OCEANVINE_COCOON_MAX_CHILDREN = 3,
        OCEANVINE_COCOON_REGEN_BASE = 3 * total_day_time,
        OCEANVINE_COCOON_REGEN_RAND = 2 * total_day_time,

        SPIDER_WATER_DAMAGE = 20,
        SPIDER_WATER_ATTACK_PERIOD = 3,
        SPIDER_WATER_HIT_RANGE = 2,
        SPIDER_WATER_HEALTH = 200,
        SPIDER_WATER_EATCD = 20,
        SPIDER_WATER_FISH_TARGET_DIST = 1.5,
        SPIDER_WATER_INVESTIGATETIMEBASE = 15,
        SPIDER_WATER_WALKSPEED = 3.0,
        SPIDER_WATER_RUNSPEED = 7.0,
        SPIDER_WATER_OCEANFLOATSPEED = 1.5,
        SPIDER_WATER_OCEANDASHSPEED = 10,

        GRASSGATOR_WALKSPEED = 1.5,
        GRASSGATOR_RUNSPEED = 6.5,
        GRASSGATOR_RUNSPEED_WATER = 3.5,
        GRASSGATOR_HEALTH = 500 * 2, -- harder for multiplayer
        GRASSGATOR_DAMAGE = 50,
        GRASSGATOR_TARGET_DIST = 5,
        GRASSGATOR_CHASE_DIST = 30,
        GRASSGATOR_FOLLOW_TIME = 30,
        GRASSGATOR_SHEDTIME_SET = total_day_time/2,
        GRASSGATOR_SHEDTIME_VAR = total_day_time/2,
        GRASSGATOR_REGEN_TIME = seg_time * 4,
        GRASSGATOR_RELEASE_TIME = seg_time,
        GRASSGATOR_MAXCHILDREN = 1,
        GRASSGATOR_ENABLED = true,


        SHADE_CANOPY_RANGE = 28,
        SHADE_CANOPY_RANGE_SMALL = 22, -- this is just a number now.. 
        WATERTREE_PILLAR_CANOPY_BUFFER = 1,

        WATERTREE_PILLAR_RAM_RECHARGE_TIME = 1.5, -- in days
        OCEANTREENUT_REGENERATE_TIME = total_day_time * 1,
        OCEANTREENUT_REGENERATE_TIME_VARIANCE = total_day_time * 0.5,

        CANOPY_MAX_ROTATION = 20,
        CANOPY_ROTATION_SPEED = 5,
        CANOPY_MAX_TRANSLATION = 1,
        CANOPY_TRANSLATION_SPEED = 5,

        CANOPY_MIN_STRENGTH = 0.2,
        CANOPY_MAX_STRENGTH = 0.4,  --0.7

        CANOPY_SCALE = 4,

        OCEANTREE_ENRICHED_COOLDOWN_MIN = total_day_time * 3,
        OCEANTREE_ENRICHED_COOLDOWN_VARIANCE = total_day_time * 1.5,
        OCEANTREE_CHOPS_NORMAL = 10,
        OCEANTREE_PILLAR_CHOPS = 25,

        OCEANTREE_VINE_DROP_MAX = 4,

        OCEANTREENUT_GROW_TIME = total_day_time * 1.2,
        OCEANTREENUT_GROW_TIME_VARIANCE = total_day_time * 1.5,

        WATERTREE_ROOT_CHOPS = 3,

        OCEANVINE_REGROW_TIME = total_day_time*2.5,

        -- Eye For An Eye
        SPAWN_EYEOFTERROR = true,
        EYEOFTERROR_SPAWNDELAY = total_day_time * 15,

		TERRARIUM_WARNING_TIME = 10,
		TERRARIUM_SUMMON_DELAY = 5,

        EYEOFTERROR_HEALTH = 5000,
        EYEOFTERROR_HEALTHPCT_PERDAY = 0.05,
        EYEOFTERROR_TRANSFORMPERCENT = 0.65,
        EYEOFTERROR_DAMAGE = 125,
        EYEOFTERROR_DAMAGEPLAYERPERCENT = 0.5,
        EYEOFTERROR_DEAGGRO_DIST = 60,
        EYEOFTERROR_CHARGESPEED = 15,
        EYEOFTERROR_CHARGEMINDSQ = 0,
        EYEOFTERROR_CHARGEMAXDSQ = 196,
        EYEOFTERROR_ATTACK_RANGE = 3,
        EYEOFTERROR_AOERANGE = 3,
        EYEOFTERROR_AOE_DAMAGE = 100,
        EYEOFTERROR_ATTACKPERIOD = 3,
        EYEOFTERROR_SLEEPRESIST = 4,
        EYEOFTERROR_CHOMP_SINKHOLERADIUS = 2.0,
        EYEOFTERROR_MINGUARDS_PERSPAWN = 2,
        EYEOFTERROR_EYE_MINGUARDS = 2,
        EYEOFTERROR_MOUTH_MINGUARDS = 4,
        EYEOFTERROR_EPICSCARE_RANGE = 10,

        EYEOFTERROR_CHARGECD = 7,
        EYEOFTERROR_MOUTHCHARGECD = 15,
        EYEOFTERROR_SPAWNCD = 18,
        EYEOFTERROR_FOCUSCD = 21,

        EYEOFTERROR_MINI_EGGTIME = 15,
        EYEOFTERROR_MINI_HEALTH = 200,
        EYEOFTERROR_MINI_DAMAGE = 20,
        EYEOFTERROR_MINI_ATTACK_RANGE = 4.0,
        EYEOFTERROR_MINI_HIT_RANGE = 2.25,
        EYEOFTERROR_MINI_ATTACK_PERIOD = 3,

        TWINS_RESET_DAY_COUNT = 2,  -- 1 higher than we really want, just makes the code simpler.

		-- Twin 1
		TWIN1_HEALTH				= 10000,  --2.0*TUNING.EYEOFTERROR_HEALTH,
		TWIN1_DAMAGE				= 250,    --2.0*TUNING.EYEOFTERROR_DAMAGE,
        TWIN1_AOE_DAMAGE			= 250,    --2.5*TUNING.EYEOFTERROR_AOE_DAMAGE
        TWIN1_MINGUARDS_PERSPAWN	= 2 + 2,   --TUNING.EYEOFTERROR_MINGUARDS_PERSPAWN + 2

		TWIN1_CHARGECD				= 0.50* 7, --0.50*TUNING.EYEOFTERROR_CHARGECD,
		TWIN1_MOUTHCHARGECD			= 0.50*15, --0.50*TUNING.EYEOFTERROR_MOUTHCHARGECD,
		TWIN1_SPAWNCD				= 0.30*18, --0.30*TUNING.EYEOFTERROR_SPAWNCD,
		TWIN1_FOCUSCD				= 0.60*21, --0.60*TUNING.EYEOFTERROR_FOCUSCD,

        TWIN1_CHARGESPEED			= 20,
		TWIN1_CHARGETIMEOUT			= 1.0,
		TWIN1_MOUTH_CHARGESPEED		= 22,
		TWIN1_MOUTH_CHARGETIMEOUT	= 0.70,
		TWIN1_TAUNT_CHANCE			= 0.50,

		-- Twin 2
		TWIN2_HEALTH				= 10000,   --2.0*TUNING.EYEOFTERROR_HEALTH,
		TWIN2_DAMAGE				= 250,     --2.0*TUNING.EYEOFTERROR_DAMAGE,
        TWIN2_AOE_DAMAGE			= 250,	   --2.5*TUNING.EYEOFTERROR_AOE_DAMAGE
        TWIN2_MINGUARDS_PERSPAWN	= 2,       --TUNING.EYEOFTERROR_MINGUARDS_PERSPAWN

		TWIN2_CHARGECD				= 0.25* 7, --0.25*TUNING.EYEOFTERROR_CHARGECD,
		TWIN2_MOUTHCHARGECD			= 0.25*15, --0.25*TUNING.EYEOFTERROR_MOUTHCHARGECD,
		TWIN2_SPAWNCD				= 1.00*18, --TUNING.EYEOFTERROR_SPAWNCD,
		TWIN2_FOCUSCD				= 0.60*21, --0.60*TUNING.EYEOFTERROR_FOCUSCD,

        TWIN2_CHARGESPEED			= 23,      --1.15*TWIN1_CHARGESPEED
		TWIN2_CHARGETIMEOUT			= 0.40,
		TWIN2_MOUTH_CHARGESPEED		= 25,
		TWIN2_MOUTH_CHARGETIMEOUT	= 0.50,
		TWIN2_TAUNT_CHANCE			= 0.25,

		EYEMASK_PERISHTIME = total_day_time*10,

        SHIELDOFTERROR_DAMAGE = wilson_attack*1.5,
        SHIELDOFTERROR_ABSORPTION = .8*multiplayer_armor_absorption_modifier,
        SHIELDOFTERROR_ARMOR = wilson_health*3*multiplayer_armor_durability_modifier,
        SHIELDOFTERROR_USEDAMAGE = 2,
        
        -- Wolfgang
        MIGHTINESS_MAX = 100,
        MIGHTINESS_DRAIN_RATE = 0.2, -- per second

        MIGHTINESS_DRAIN_MULT_SLOW = 0.5,
        MIGHTINESS_DRAIN_MULT_NORMAL = 1,
        MIGHTINESS_DRAIN_MULT_FAST = 2,
        MIGHTINESS_DRAIN_MULT_FASTEST = 3,
        MIGHTINESS_DRAIN_MULT_STARVING = 8,

        WIMPY_THRESHOLD = 25,
        MIGHTY_THRESHOLD = 75,

        DUMBBELL_CONSUMPTION_ROCK = 0.8,
        DUMBBELL_CONSUMPTION_GOLD = 0.5,
        DUMBBELL_CONSUMPTION_MARBLE = 0.3,
        DUMBBELL_CONSUMPTION_GEM = 0.2,

        DUMBBELL_DAMAGE_ROCK = wilson_attack*.5,
        DUMBBELL_DAMAGE_GOLD = wilson_attack*.8,
        DUMBBELL_DAMAGE_MARBLE = wilson_attack,
        DUMBBELL_DAMAGE_GEM = wilson_attack * 1.25,

		-- Dumbbells are custom made tools (designed by Wolfgang for Wolfgang), not something to be tossed about...
		DUMBBELL_ATTACK_CONSUMPTION_MULT = 2,
		DUMBBELL_THROWN_CONSUMPTION_MULT = 10,

		DUMBBELL_SLOW_MARBEL = 0.9,

        DUMBBELL_EFFICIENCY_LOW = 1.5,
        DUMBBELL_EFFICIENCY_MED = 3.0,
        DUMBBELL_EFFICIENCY_HIGH = 5.0,
		DUMBBELL_EFFICIENCY_ATTCK_SCALE = 0.5,

		WOLFGANG_MIGHTINESS_WORK_GAIN = 
		{
			CHOP = 0.5,				-- ~0.4s
			MINE = 1.0,				-- ~0.4s
			HAMMER = 0.25,			-- ~0.4s -- please dont hammer down other people's bases...
			DIG = 2,
			ROW = 0.5,				-- ~0.4s without lag
			LOWER_SAIL_BOOST = 2,
			TILL = 1,				-- ~1.1s
			TERRAFORM = 1.5,
		},

		WOLFGANG_MIGHTINESS_ATTACK_GAIN_GIANT = 1,
		WOLFGANG_MIGHTINESS_ATTACK_GAIN_SMALLCREATURE = 0.25,
		WOLFGANG_MIGHTINESS_ATTACK_GAIN_DEFAULT = 0.5,

		WOLFGANG_MIGHTINESS_DRAIN_DELAY = 4,

        WIMPY_WORK_EFFECTIVENESS = 0.75,
		WIMPY_HUNGER_RATE_MULT = 0.75,

        MIGHTY_WORK_CHANCE = 0.99,
        MIGHTY_WORK_EFFECTIVENESS = 1.5,
        MIGHTY_ROWER_MULT = 1.33,
		MIGHTY_ROWER_EXTRA_MAX_VELOCITY = 0.5,
        MIGHTY_ANCHOR_SPEED = 2,
        MIGHTY_SAIL_BOOST_STRENGTH = 18,

		DEFAULT_SAIL_BOOST_STRENGTH = 10,

		MIGHTY_HEAVY_SPEED_MULT_BONUS = 0.45, -- DEPRECATED

        WOLFGANG_SANITY_DRAIN = 1.1,
        WOLFGANG_SANITY_NIGHT_DRAIN = 1.25,
        WOLFGANG_SANITY_NIGHT_DRAIN_SMALL = 1.1,
        WOLFGANG_SANITY_RANGE = 16,
        WOLFGANG_SANITY_PER_MONSTER = 1/13,

        BELL_SUCCESS_MIN_2 = nil, -- no perfect here
        BELL_SUCCESS_MAX_2 = nil, -- no perfect here 
        BELL_MID_SUCCESS_MIN_2 = 0.37,
        BELL_MID_SUCCESS_MAX_2 = 0.63,

        BELL_SUCCESS_MIN_3 = nil, -- no perfect here
        BELL_SUCCESS_MAX_3 = nil, -- no perfect here 
        BELL_MID_SUCCESS_MIN_3 = 0.25,
        BELL_MID_SUCCESS_MAX_3 = 0.75,

        BELL_SUCCESS_MIN_4 = 0.45,
        BELL_SUCCESS_MAX_4 = 0.60,
        BELL_MID_SUCCESS_MIN_4 = 0.12,
        BELL_MID_SUCCESS_MAX_4 = 0.90,

        BELL_SUCCESS_MIN_5 = 0.33,
        BELL_SUCCESS_MAX_5 = 0.69,
        BELL_MID_SUCCESS_MIN_5 = 0.14,
        BELL_MID_SUCCESS_MAX_5 = 0.87,

        BELL_SUCCESS_MIN_6 = 0.24,
        BELL_SUCCESS_MAX_6 = 0.78,
        BELL_MID_SUCCESS_MIN_6 = 0.12,
        BELL_MID_SUCCESS_MAX_6 = 0.88,

        BELL_SUCCESS_MIN_7 = 0.44,
        BELL_SUCCESS_MAX_7 = 0.57,
        BELL_MID_SUCCESS_MIN_7 = 0.12,
        BELL_MID_SUCCESS_MAX_7 = 0.86,

        BELL_SUCCESS_MIN_8 = 0.37,
        BELL_SUCCESS_MAX_8 = 0.66,
        BELL_MID_SUCCESS_MIN_8 = 0.14,
        BELL_MID_SUCCESS_MAX_8 = 0.90,

        MIGHTYGYM_WORKOUT_HUNGER = {
            LOW = 4,
            MED = 11,
            HIGH = 22,
        },

        GYM_RATE = {
            -- rate in number of hits to reach 100 mightiness
            LOW = 100/25,
            MED = 100/15,
            HIGH = 100/10,
        },

        RUINS_CAVEIN_OBSTACLE_FALL_DAMAGE = 40,

        -- WX78 Refresh
        WX78_MAXELECTRICCHARGE = 6,
        WX78_MINACCEPTABLEMOISTURE = 15,
        WX78_HUNGRYCHARGEDRAIN_TICKTIME = 300 * FRAMES,
        WX78_CHARGE_REGENTIME = 3*seg_time,
        WX78_FROZEN_CHARGELOSS = 2,
        WX78_MODULE_USES = 4,

        WX78_RAIN_HURT_RATE = 1,            -- DEPRECATED
        WX78_MAX_MOISTURE_DAMAGE = -.5,     -- DEPRECATED
        WX78_MOISTURE_DRYING_DAMAGE = -.3,  -- DEPRECATED

        WX78_MOISTUREUPDATERATE = 30, -- Frames count
        WX78_MOISTURESTEPTRIGGER = 5, -- How many updates there are before a discharge
        WX78_MIN_MOISTURE_DAMAGE = -0.60,     -- Damage per second
        WX78_PERCENT_MOISTURE_DAMAGE = -1.2,

        WX78_MAXHEALTH_BOOST = 50,

        WX78_MAXSANITY1_BOOST = 40,

        WX78_MAXSANITY_BOOST = 100,
        WX78_MAXSANITY_DAPPERNESS = 100/(day_time*10),

        WX78_MAXHUNGER1_BOOST = 40,

        WX78_MAXHUNGER_BOOST = 100,
        WX78_MAXHUNGER_SLOWPERCENT = 0.80,

        WX78_MOVESPEED_CHIPBOOSTS = {0.00, 0.25, 0.40, 0.50}, -- Set so that speed circuits give diminishing returns.

        WX78_HEATERTEMPPERMODULE = 25,
        WX78_MINTEMPCHANGEPERMODULE = 20,

        WX78_COLD_ICEMOISTURE = 94, -- Kind of 95; the moisture badge presentation makes this work better.
        WX78_COLD_ICECOUNT = 2,

        WX78_PERISH_COLDRATE = 0.75,
        WX78_PERISH_HOTRATE = 1.25,

        WX78_TASERDAMAGE = 20,

        WX78_LIGHT_BASERADIUS = 3.5,
        WX78_LIGHT_EXTRARADIUS = 1.5,

        WX78_MUSIC_TENDRANGE = 12,
        WX78_MUSIC_AURADSQ = 256,
        WX78_MUSIC_UPDATERATE = 144*FRAMES,
        WX78_MUSIC_DAPPERNESS = 100/(day_time*4.5),
        WX78_MUSIC_SANITYAURA = 100/(day_time*4.5),

        WX78_BEE_TICKPERIOD = seg_time,
        WX78_BEE_HEALTHPERTICK = 5.0,

        WX78_MAXHEALTH2_MULT = 3.0, -- A multiplier on WX78_MAXHEALTH_BOOST

        WX78_CHARGING_FOODS = {
            voltgoatjelly = 1,
            voltgoatjelly_spice_chili = 1,
            voltgoatjelly_spice_garlic = 1,
            voltgoatjelly_spice_sugar = 1,
            voltgoatjelly_spice_salt = 1,
            goatmilk = 1,
        },

        WX78_SCANNER_SCANPERIOD = 10,
        WX78_SCANNER_MODULETARGETSCANTIME = 10,
        WX78_SCANNER_MODULETARGETSCANTIME_EPIC = 20,

        WX78_SCANNER_DISTANCES =
        {
            {maxdist=10, describe="hot", pingtime=1},
            {maxdist=15, describe="warmer", pingtime=2},
        },
        WX78_SCANNER_SCANDIST = 4.0,

        WX78_SCANNER_RANGE = 7,
        WX78_SCANNER_PLAYER_PROX = 7,

        WX78_SCANNER_TIMEOUT = total_day_time,

        -- Wurt QoL/AI
        -- Default fallbacks for follower brain AI distances.
        FOLLOWER_HELP_LEADERDIST = 18,
        FOLLOWER_HELP_FINDDIST = 6,
    }

    TUNING_MODIFIERS = {}
    ORIGINAL_TUNING = {}

    setmetatable(TUNING,
    {
        --these only run when indexing a nil value in TUNING
        __index = function(t, k)
            if TUNING_MODIFIERS[k] then
                local modifier = TUNING_MODIFIERS[k]
                return modifier[1](modifier[2])
            end
        end,
        __newindex = function(t, k, v)
            if TUNING_MODIFIERS[k] then
                TUNING_MODIFIERS[k][2] = v
                return
            end
            rawset(t, k, v)
        end
    })
end

Tune()
