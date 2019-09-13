local TechTree = require("techtree")

TUNING = {}

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
    local calories_per_day = 75

    local wilson_attack_period = .1
    
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

        TOAST_FALLBACK_TIME = 1440,
        ITEM_DROP_TIME = seg_time, -- time to wait after start of night before activating

        STACK_SIZE_LARGEITEM = 10,
        STACK_SIZE_MEDITEM = 20,
        STACK_SIZE_SMALLITEM = 40,

        MAX_FIRE_DAMAGE_PER_SECOND = 120,

        GOLDENTOOLFACTOR = 4*multiplayer_goldentool_modifier,

        DARK_CUTOFF = 0,
        DARK_SPAWNCUTOFF = 0.1,
        WILSON_HEALTH = wilson_health,
        WILSON_ATTACK_PERIOD = wilson_attack_period,
        WILSON_HUNGER = 150, --stomach size
        WILSON_HUNGER_RATE = calories_per_day/total_day_time, --calories burnt per day

        WX78_MIN_HEALTH = 150,
        WX78_MIN_HUNGER = 150, -- 100 For pax we are increasing this.  Hungers out too easily.
        WX78_MIN_SANITY = 150,

        WX78_MAX_HEALTH = 400,
        WX78_MAX_HUNGER = 200,
        WX78_MAX_SANITY = 300,

        WILSON_SANITY = 200,

        BALLOON_PILE_DECAY_TIME = total_day_time * 3,
        BALLOON_MAX_COUNT = 100,

        HAMMER_LOOT_PERCENT = .5,
        BURNT_HAMMER_LOOT_PERCENT = .25,
        AXE_USES = 100,
        HAMMER_USES = 75,
        SHOVEL_USES = 25,
        PITCHFORK_USES = 25,
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
        MULTITOOL_AXE_PICKAXE_USES = 400,
        RUINS_BAT_USES = 150,
        SADDLEHORN_USES = 10,
        BRUSH_USES = 75,

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

        FISHING_MINWAIT = 2,
        FISHING_MAXWAIT = 20,

		OCEAN_FISHING =
		{
			MAX_CAST_DIST = 16,
			CAST_DIST_MIN_OFFSET = 0.8,
			CAST_DIST_MAX_OFFSET = 1.1,
			CAST_ANGLE_OFFSET = 20 / RADIANS,

			MAX_HOOK_DIST = 20,

		},

        STAGEHAND_HITS_TO_GIVEUP = 86,
        ENDTABLE_FLOWER_WILTTIME = total_day_time * 2.25,
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
        BUGNET_DAMAGE = wilson_attack*.125,
        WHIP_DAMAGE = wilson_attack*.8,
        BULLKELP_ROOT_DAMAGE = wilson_attack*.8,
        FISHINGROD_DAMAGE = wilson_attack*.125,
        UMBRELLA_DAMAGE = wilson_attack*.5,
        CANE_DAMAGE = wilson_attack*.5,
        MULTITOOL_DAMAGE = wilson_attack*.9,
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
        HEAVY_SPEED_MULT = .15,

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
        PIG_LOYALTY_MAXTIME = 2.5*total_day_time,
        PIG_LOYALTY_POLITENESS_MAXTIME_BONUS = .5*total_day_time,
        PIG_LOYALTY_PER_HUNGER = total_day_time/25,
        PIG_MIN_POOP_PERIOD = seg_time * .5,

        PIG_TOKEN_CHANCE = 0.05,
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

        MERM_DAMAGE = 30,
        MERM_HEALTH = 250 * 2, -- harder for multiplayer
        MERM_ATTACK_PERIOD = 3,
        MERM_RUN_SPEED = 8,
        MERM_WALK_SPEED = 3,
        MERM_TARGET_DIST = 10,
        MERM_DEFEND_DIST = 30,

        WALRUS_DAMAGE = 33,
        WALRUS_HEALTH = 150 * 2, -- harder for multiplayer
        WALRUS_ATTACK_PERIOD = 3,
        WALRUS_ATTACK_DIST = 15,
        WALRUS_DART_RANGE = 25,
        WALRUS_MELEE_RANGE = 5,
        WALRUS_TARGET_DIST = 10,
        WALRUS_LOSETARGET_DIST = 30,
        WALRUS_REGEN_PERIOD = total_day_time*2.5,

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

        DEER_DAMAGE = 25,
        DEER_HEALTH = 350 * 2, -- harder for multiplayer
        DEER_ATTACK_RANGE = 3,
        DEER_ATTACK_PERIOD = 2,
        DEER_ATTACKER_REMEMBER_DIST = 20,
        DEER_WALK_SPEED = 2.5,
        DEER_RUN_SPEED = 8,

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
        KLAUSSACK_SPAWN_DELAY = total_day_time * 1,
        KLAUSSACK_SPAWN_DELAY_VARIANCE = total_day_time * 2,

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

        ABIGAIL_SPEED = 5,
        ABIGAIL_HEALTH = wilson_health*4,
        ABIGAIL_DAMAGE_PER_SECOND = 20,
        ABIGAIL_DMG_PERIOD = 1.5,
        ABIGAIL_DMG_PLAYER_PERCENT = 0.25,
        ABIGAIL_FLOWER_DECAY_TIME = total_day_time * 3,

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
        HUNT_COOLDOWNDEVIATION = total_day_time*.3,
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
        DEERCLOPS_AOE_RANGE = 6,
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
        FROG_RAIN_CHANCE = .16,

        BEE_HEALTH = 100,
        BEE_DAMAGE = 10,
        BEE_ATTACK_RANGE = .6,
        BEE_ATTACK_PERIOD = 2,
        BEE_TARGET_DIST = 8,

        BEEMINE_BEES = 4,
        BEEMINE_RADIUS = 3,

        SPIDERDEN_GROW_TIME = {day_time*8, day_time*8, day_time*20},
        SPIDERDEN_HEALTH = {50*5, 50*10, 50*20},
        SPIDERDEN_SPIDERS = {3, 6, 9},
        SPIDERDEN_WARRIORS = {0, 1, 3},  -- every hit, release up to this many warriors, and fill remainder with regular spiders
        SPIDERDEN_EMERGENCY_WARRIORS = {0, 4, 8}, -- the max "bonus" spiders, one per player
        SPIDERDEN_EMERGENCY_RADIUS = {10, 15, 20},
        SPIDERDEN_SPIDER_TYPE = {"spider", "spider_warrior", "spider_warrior"},
        SPIDERDEN_REGEN_TIME = 3*seg_time,
        SPIDERDEN_RELEASE_TIME = 5,

        HOUNDMOUND_HOUNDS_MIN = 2,
        HOUNDMOUND_HOUNDS_MAX = 3,
        HOUNDMOUND_REGEN_TIME = seg_time * 6,
        HOUNDMOUND_RELEASE_TIME = seg_time,

        MERMHOUSE_MERMS = 3,
        MERMHOUSE_EMERGENCY_MERMS = 3,
        MERMHOUSE_EMERGENCY_RADIUS = 15,

        POND_FROGS = 4,
        POND_REGEN_TIME = day_time/2,
        POND_SPAWN_TIME = day_time/4,
        POND_RETURN_TIME = day_time*3/4,
        FISH_RESPAWN_TIME = day_time/3,

        BEEHIVE_BEES = 5,
        BEEHIVE_EMERGENCY_BEES = 8,
        BEEHIVE_EMERGENCY_RADIUS = 20,
        BEEHIVE_RELEASE_TIME = day_time/6,
        BEEHIVE_REGEN_TIME = seg_time,
        BEEBOX_BEES = 4,
        WASPHIVE_WASPS = 5,
        WASPHIVE_EMERGENCY_WASPS = 8,
        WASPHIVE_EMERGENCY_RADIUS = 25,
        BEEBOX_RELEASE_TIME = (0.5*day_time)/4,
        BEEBOX_HONEY_TIME = day_time,
        BEEBOX_REGEN_TIME = seg_time*4,

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

			MOON_ALTAR_FULL = TechTree.Create({
                MOON_ALTAR = 2,
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

            MADSCIENCE = TechTree.Create({
                MADSCIENCE = 1,
            }),

            FOODPROCESSING = TechTree.Create({
                FOODPROCESSING = 1,
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

        GLOMMERFUEL_FERTILIZE = day_time,
        GLOMMERFUEL_SOILCYCLES = 8,

        SPOILEDFOOD_FERTILIZE = day_time/4,
        SPOILEDFOOD_SOILCYCLES = 2,
        SPOILEDFOOD_WITHEREDCYCLES = 0.5,

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

        CROW_LEAVINGS_CHANCE = .3333,
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

        RABBIT_RESPAWN_TIME = day_time*4*multiplayer_wildlife_respawn_modifier,
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
            ANTLION = 1,
            MEAT = 1,
            RAREMEAT = 5,
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

        CALORIES_TINY = calories_per_day/8, -- berries
        CALORIES_SMALL = calories_per_day/6, -- veggies
        CALORIES_MEDSMALL = calories_per_day/4,
        CALORIES_MED = calories_per_day/3, -- meat
        CALORIES_LARGE = calories_per_day/2, -- cooked meat
        CALORIES_HUGE = calories_per_day, -- crockpot foods?
        CALORIES_SUPERHUGE = calories_per_day*2, -- crockpot foods?

        SPOILED_HEALTH = -1,
        SPOILED_HUNGER = -10,
        PERISH_COLD_FROZEN_MULT = 0, -- frozen things don't spoil in an ice box or if it's cold out
        PERISH_FROZEN_FIRE_MULT = 30, -- frozen things spoil very quickly if near a fire
        PERISH_FRIDGE_MULT = .5,
        PERISH_FOOD_PRESERVER_MULT = .75,
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

        REPAIR_BOARDS_HEALTH = 25,
        REPAIR_LOGS_HEALTH = 25/4,
        REPAIR_STICK_HEALTH = 13,
        REPAIR_CUTGRASS_HEALTH = 13,

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

        BEEQUEEN_DODGE_SPEED = 6,
        BEEQUEEN_DODGE_HIT_RECOVERY = 2,

        BEEQUEEN_AGGRO_DIST = 15,
        BEEQUEEN_DEAGGRO_DIST = 60,

        BEEQUEEN_RESPAWN_TIME = total_day_time * 20,

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
        WX78_RAIN_HURT_RATE = 1,
        WX78_MIN_MOISTURE_DAMAGE= -.1,
        WX78_MAX_MOISTURE_DAMAGE = -.5,
        WX78_MOISTURE_DRYING_DAMAGE = -.3,

        WOLFGANG_HUNGER = 300,
        WOLFGANG_START_HUNGER = 200,
        WOLFGANG_START_MIGHTY_THRESH = 225,
        WOLFGANG_END_MIGHTY_THRESH = 220,
        WOLFGANG_START_WIMPY_THRESH = 100,
        WOLFGANG_END_WIMPY_THRESH = 105,

        WOLFGANG_HUNGER_RATE_MULT_MIGHTY = 3,
        WOLFGANG_HUNGER_RATE_MULT_NORMAL = 1.5,
        WOLFGANG_HUNGER_RATE_MULT_WIMPY = 1,

        WOLFGANG_HEALTH_MIGHTY = 300,
        WOLFGANG_HEALTH_NORMAL = 200,
        WOLFGANG_HEALTH_WIMPY = 150,

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

        WENDY_DAMAGE_MULT = .75,
        WENDY_SANITY_MULT = .75,

        WES_DAMAGE_MULT = .75,

        WICKERBOTTOM_SANITY = 250,
        WICKERBOTTOM_STALE_FOOD_HUNGER = .333,
        WICKERBOTTOM_SPOILED_FOOD_HUNGER = .167,
        WICKERBOTTOM_STALE_FOOD_HEALTH = .25,
        WICKERBOTTOM_SPOILED_FOOD_HEALTH = 0,

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
        FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT = -1,
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

        CATCOONDEN_REGEN_TIME = seg_time * 4,
        CATCOONDEN_RELEASE_TIME = seg_time, 

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
        GRASSGEKKO_DENSITY_RANGE = 20,
        GRASSGEKKO_MAX_DENSITY = 6,

        FERTILIZER_USES = 10,

        GLOMMERBELL_USES = 3,

        CLAYWARG_RUNSPEED = 5.5,
        WARG_RUNSPEED = 5.5,
        WARG_HEALTH = 600 * 3, --harder for multiplayer
        WARG_DAMAGE = 50,
        WARG_ATTACKPERIOD = 3,
        WARG_ATTACKRANGE = 5,
        WARG_FOLLOWERS = 6,
        WARG_SUMMONPERIOD = 15,
        WARG_MAXHELPERS = 10,
        WARG_TARGETRANGE = 10,
        WARG_NEARBY_PLAYERS_DIST = 30,
        WARG_BASE_HOUND_AMOUNT = 2,

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
        FLOWER_REGROWTH_TIME = 30,
        FLOWER_REGROWTH_TIME_MULT = 1,
        FLOWER_WITHER_IN_CAVE_LIGHT = 0.05,
        RABBITHOLE_REGROWTH_TIME = total_day_time * 5,
        FLOWER_CAVE_REGROWTH_TIME = total_day_time * 5,
        FLOWER_CAVE_REGROWTH_TIME_MULT = 1,

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
        STALKER_HIT_RECOVERY = 1,

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
        },

		GAMEMODE_STARTING_ITEMS =
		{
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
			},
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
        },

	    LAVAARENA_BERNIE_SCALE = 1.2,

        REVIVE_CORPSE_ACTION_TIME = 6,

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
            MINOTAUR         = {basic=1, special=nil},
            BEEQUEEN         = {basic=2, special="winter_ornament_boss_beequeen"},
            TOADSTOOL        = {basic=2, special="winter_ornament_boss_toadstool"},
            TOADSTOOL_DARK   = {basic=3, special="winter_ornament_boss_toadstool"},
            MOOSE            = {basic=1, special="winter_ornament_boss_moose"}, -- goose?
            ANTLION          = {basic=1, special="winter_ornament_boss_antlion"},
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

        FIRECRACKERS_STARTLE_RANGE = 10,
        REDLANTERN_LIGHTTIME = total_day_time * 12,
        REDLANTERN_RAIN_RATE = .25,
        PERDFAN_USES = 9, --tornado costs 2 charges
        PERDFAN_TORNADO_LIFETIME = 2,
        DRAGONHAT_PERISHTIME = total_day_time, --only consumes while dancing
        YOTG_PERD_SPAWNCHANCE = .3,
        MAX_WALKABLE_PLATFORM_RADIUS = 4,
        ROWING_RADIUS = 0.6,
        ROWING_RADIUS_ITERATIONS = 4,

        --v2 Winona
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
        BERNIE_BIG_HIT_RECOVERY = 1,
        BERNIE_BIG_DAMAGE = 50,
        BERNIE_BIG_ATTACK_PERIOD = 2,
        BERNIE_BIG_ATTACK_RANGE = 3,
        BERNIE_BIG_HIT_RANGE = 3.25,
        BERNIE_BIG_COOLDOWN = 6,
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
            PREPICK = { BASE = 1*seg_time, VAR = 0 },
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

		BRIGHTMARE_MELTY =
		{
			WALK_SPEED = 3,
		},

        MAX_FISH_SCHOOL_SIZE = 2,

        WAVE_HIT_MOISTURE = 15,
        WAVE_HIT_DAMAGE = 5,

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

		MOONALTAR_ROCKS_MINE = 20,

        WATERBIRD_SEE_THREAT_DISTANCE = 6,

        BOAT =
        {
            HEALTH = 200,
            MASS = 500,
            
            BASE_DRAG = 0.4,
            MAX_VELOCITY = 1.2,            
            MAX_VELOCITY_MOD = 1,            
            PUSH_BACK_VELOCITY = 1.75,
            SCARY_MINSPEED_SQR = 1,
            RUDDER_TURN_SPEED = 0.6,    
            NO_BUILD_BORDER_RADIUS = -0.2,
			FIRE_DAMAGE = 5,

            OARS =
            {
                BASIC =
                {
                    FORCE = 0.3,
                    DAMAGE = wilson_attack*.5,
                    ATTACKWEAR = 25,
                    USES = 500,
                },

                DRIFTWOOD = 
                {
                    FORCE = 0.5,
                    DAMAGE = wilson_attack*.4,
                    ATTACKWEAR = 25,
                    USES = 400
                },                
            },

            ANCHOR =
            {
                BASIC =
                {                    
                    MAX_VELOCITY_MOD = 0.1,
                    ANCHOR_DRAG = 0.45,
                },
            },

            MAST =
            {   
                BASIC = 
                {
                    MAX_VELOCITY = 1.5,
                    MAX_VELOCITY_MOD = 1.2,
                    SAIL_FORCE = 0.6,
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
		},

        CARRAT =
        {
            WALK_SPEED = 7,
            HEALTH = 25 * multiplayer_attack_modifier,
            PERISH_TIME = total_day_time * 5,
            EAT_TIME = { BASE = 4, VAR = 4 },

            PLANTED_RUFFLE_TIME = 30,

            EMERGED_TIME_LIMIT = seg_time * 4,
        },

		OCEAN =
		{
			WETNESS = 75,
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
        WORMWOOD_BURN_TIME = 4.3,
        WORMWOOD_FIRE_DAMAGE = 1.25,
        ARMORBRAMBLE_DMG = wilson_attack/1.5,
        ARMORBRAMBLE_ABSORPTION = .65*multiplayer_armor_absorption_modifier,
        ARMORBRAMBLE = wilson_health*2.5*multiplayer_armor_durability_modifier,
        TRAP_BRAMBLE_USES = 10,
        TRAP_BRAMBLE_DAMAGE = 40,
        TRAP_BRAMBLE_RADIUS = 2.5,
        COMPOSTWRAP_SOILCYCLES = 20,
        COMPOSTWRAP_WITHEREDCYCLES = 2,
        COMPOSTWRAP_FERTILIZE = day_time * 6,
        POOP_FERTILIZE_HEALTH = 2,        

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
        WARLY_HUNGER = 250,
        WARLY_HUNGER_RATE_MODIFIER = 1.2,
        WARLY_SAME_OLD_COOLDOWN = total_day_time * 2,
        WARLY_SAME_OLD_MULTIPLIERS = { .9, .8, .65, .5, .3 },
        PORTABLE_COOK_POT_TIME_MULTIPLIER = .8, --multiplier for cook time, NOT speed! (less time means faster)

        -- Multipliers can be temperaturedelta, temperatureduration, health, sanity or hunger
        SPICE_MULTIPLIERS =
        {
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
        WERE_SANITY_PENALTY = -.5,
        WERE_FULLMOON_DRAIN_TIME_MULTIPLIER = 2,
        WOODCUTTER_LEIF_CHANCE_MOD = 1.5,
        WOODCUTTER_DECID_MONSTER_CHANCE_MOD = 1.5,
        --
        BEAVER_LEIF_CHANCE_MOD = 0,
        BEAVER_DECID_MONSTER_CHANCE_MOD = 0,
        BEAVER_DRAIN_TIME = 15,
        BEAVER_WORKING_DRAIN_TIME_MULTIPLIER2 = 5,
        BEAVER_WORKING_DRAIN_TIME_MULTIPLIER1 = 3,
        BEAVER_WORKING_DRAIN_TIME_DURATION = 3, --time for the working mults to wear off
        BEAVER_RUN_SPEED = 6.6, --x1.1 speed
        BEAVER_ABSORPTION = .25,
        BEAVER_DAMAGE = wilson_attack * .8,
        BEAVER_WOOD_DAMAGE = wilson_attack * .5, -- extra damage to wood things
        --
        WEREMOOSE_DRAIN_TIME = 15,
        WEREMOOSE_FIGHTING_DRAIN_TIME_MULTIPLIER2 = 6,
        WEREMOOSE_FIGHTING_DRAIN_TIME_MULTIPLIER1 = 3,
        WEREMOOSE_FIGHTING_DRAIN_TIME_DURATION = 3, --time for fighting mults to wear off
        WEREMOOSE_RUN_SPEED = 5.4, --x0.9 speed
        WEREMOOSE_ABSORPTION = .8,
        WEREMOOSE_DAMAGE = wilson_attack * 1.75,
        --
        WEREGOOSE_DRAIN_TIME = 12,
        WEREGOOSE_RUN_DRAIN_TIME_MULTIPLIER = 5,
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
        --
    }
end

Tune()
