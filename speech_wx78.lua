--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "PRIORITIZE MY REQUEST, USELESS FLESHLING!",
        },
        REPAIR =
        {
            WRONGPIECE = "PLUGIN INCOMPATIBLE",
        },
        BUILD =
        {
            MOUNTED = "NON-OPTIMAL ALTITUDE FOR PLACING",
            HASPET = "I ALREADY HAVE AN ORGANIC MINION",
			TICOON = "THE MAXIMUM LIMIT HAS ALREADY BEEN REACHED",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "DANGER! TARGET IS AWAKE",
			GENERIC = "THAT IS NOT A VALID SHAVE TARGET",
			NOBITS = "THERE IS NO STUBBLE TO SHAVE",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "I WILL NOT PERFORM SOMEONE ELSE'S TASKS",
		},
		STORE =
		{
			GENERIC = "IT IS AT CAPACITY",
			NOTALLOWED = "THAT INPUT IS NOT ALLOWED",
			INUSE = "INFERIORS ARE USING IT RIGHT NOW",
            NOTMASTERCHEF = "MAKE MY MINION DO IT",
		},
        CONSTRUCT =
        {
            INUSE = "INFERIORS ARE BUILDING IT",
            NOTALLOWED = "INCOMPATIBLE HARDWARE",
            EMPTY = "ERROR: NO INPUT SELECTED",
            MISMATCH = "SOFTWARE IS NOT COMPATIBLE",
        },
		RUMMAGE =
		{
			GENERIC = "ERROR: DON'T WANT TO",
			INUSE = "I CAN HELP IF IT MAKES THIS GO FASTER",
            NOTMASTERCHEF = "MAKE MY MINION DO IT",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "INCORRECT UNLOCKING DEVICE",
        	KLAUS = "COMBAT PRIORITY: HIGH",
			QUAGMIRE_WRONGKEY = "WRONG PASSWORD DETECTED",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "REQUIRES PASSKEY",
            HOSTBUSY = "HIS SMALL AVIAN BRAIN IS SO EASILY DISTRACTED",
            CARNIVAL_HOST_HERE = "SENSORS INDICATE THE BIRD LEADER IS OVER HERE",
            NOCARNIVAL = "THEY WILL NOT BE MISSED",
			EMPTY_CATCOONDEN = "IT IS FREE OF FLESHLINGS",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "NOT ENOUGH FLESHLINGS WILLING TO HIDE FROM MY POWER",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "NOT ENOUGH LOCATIONS TO HIDE FROM MY POWER",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "THEY NEED TO RECHARGE",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "MAKE MY MINION DO IT",
			SHADOWMAGIC = "GOOSEBUMPS ACTIVATED",
		},
        COOK =
        {
            GENERIC = "I DON'T WANT TO COOK",
            INUSE = "YOU MAY FEED ME, INFERIOR",
            TOOFAR = "NOT IN OPTIMAL RANGE",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "STARTUP POSTPONED UNTIL RACING ORGANICS ARE INSTALLED",
        },

		DISMANTLE =
		{
			COOKING = "COOK.EXE IS STILL RUNNING",
			INUSE = "INFERIORS ARE USING IT RIGHT NOW",
			NOTEMPTY = "I HAVE TO TAKE ITS INSIDES OUT",
        },
        FISH_OCEAN =
		{
			TOODEEP = "ERROR: INSUFFICIENT FISHING LINE",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "ERROR: INCORRECT ROD",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "ABSOLUTELY NOT",
            DEAD = "WHY? THEY'RE DEAD",
            SLEEPING = "THAT UNIT IS BUSY RECHARGING",
            BUSY = "TARGET IS PREOCCUPIED",
            ABIGAILHEART = "FAILURE",
            GHOSTHEART = "NOT WORTH IT",
            NOTGEM = "PLUGIN DEVICE NOT COMPATIBLE",
            WRONGGEM = "INCORRECT MINERAL-BASED POWER SOURCE",
            NOTSTAFF = "WRONG THING",
            MUSHROOMFARM_NEEDSSHROOM = "FUNGUS UPDATE REQUIRED",
            MUSHROOMFARM_NEEDSLOG = "SPECIAL LOG-IN REQUIRED",
            MUSHROOMFARM_NOMOONALLOWED = "INCOMPATIBLE",
            SLOTFULL = "ERROR: MATERIALS ALREADY SELECTED",
            FOODFULL = "ERROR: FOODFUEL ALREADY PRESENT",
            NOTDISH = "ERROR: NOT SUITABLE FOODFUEL",
            DUPLICATE = "ERROR: DUPLICATE RECIPE DETECTED",
            NOTSCULPTABLE = "MATERIAL TOO INFERIOR TO SCULPT",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "REANIMATION: FAILED",
            WRONGSHADOWFORM = "ERROR: REBUILD SKELETON",
            NOMOON = "ERROR: LOGIN REQUIRES MOON VISIBILITY",
			PIGKINGGAME_MESSY = "ERROR: GROUND REQUIRES DISKCLEANUP",
			PIGKINGGAME_DANGER = "WARNING: DANGER DETECTED",
			PIGKINGGAME_TOOLATE = "WARNING: NIGHT APPROACHING",
			CARNIVALGAME_INVALID_ITEM = "ERROR: INVALID ITEM",
			CARNIVALGAME_ALREADY_PLAYING = "WAITING IN QUEUE, CALCULATING TIME REMAINING...",
            SPIDERNOHAT = "WARNING: INSUFFICIENT WIGGLE ROOM",
            TERRARIUM_REFUSE = "INCORRECT INPUT. REQUIRES ALTERNATE FUEL",
            TERRARIUM_COOLDOWN = "UNABLE TO INSTALL ITEM. MISSING TREE COMPONENT",
        },
        GIVETOPLAYER =
        {
            FULL = "TARGET ALREADY OVER CAPACITY",
            DEAD = "WHY? THEY'RE DEAD",
            SLEEPING = "THAT UNIT IS BUSY RECHARGING",
            BUSY = "TARGET IS PREOCCUPIED",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "TARGET ALREADY OVER CAPACITY",
            DEAD = "WHY? THEY'RE DEAD",
            SLEEPING = "THAT UNIT IS BUSY RECHARGING",
            BUSY = "TARGET IS PREOCCUPIED",
        },
        WRITE =
        {
            GENERIC = "WRITE ERROR",
            INUSE = "PRIMITIVE MESSAGEBOARD OCCUPIED",
        },
        DRAW =
        {
            NOIMAGE = "I REQUIRE SOMETHING REAL TO BASE THIS \"ART\" ON",
        },
        CHANGEIN =
        {
            GENERIC = "THERE ARE MORE IMPORTANT ISSUES TO ATTEND TO",
            BURNING = "IT'S BURNING. OH WELL",
            INUSE = "OCCUPIED",
            NOTENOUGHHAIR = "TARGET REQUIRES MORE HAIR",
            NOOCCUPANT = "NO TARGET ATTACHED",
        },
        ATTUNE =
        {
            NOHEALTH = "I MUST MAKE REPAIRS BEFORE DOING THIS",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I'LL RIDE IT LATER. RIGHT NOW IT FIGHTS FOR MY AMUSEMENT",
            INUSE = "ERROR: MOUNT IN USE",
			SLEEPING = "SLEEP MODE DISABLED",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I'LL RIDE IT LATER. RIGHT NOW IT FIGHTS FOR MY AMUSEMENT",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "ONLY A FLESHBRAIN WOULD NEED THAT EXPLAINED TO THEM",
            CANTLEARN = "THE KNOWLEDGE WAS PROBABLY OBSOLETE ANYWAY",

            --MapRecorder/MapExplorer
            WRONGWORLD = "ERROR: INCORRECT LOCATION",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "INSUFFICIENT LIGHT, UNABLE TO ANALYZE",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "ERROR: NO THINGS TO WRAP",
        },
        PICKUP =
        {
			RESTRICTION = "ERROR: INFERIOR WEAPON",
			INUSE = "SERVER BUSY",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "THIS ORGANIC HAS ALREADY BEEN CLAIMED",
                "ERROR: INCORRECT CARRAT",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "STAND STILL AND LET ME KILL YOU",
        },
        REPLATE =
        {
            MISMATCH = "ERROR: UNEXPECTED DISH FORMAT",
            SAMEDISH = "ERROR: FOOD DOES NOT REQUIRE TWO RECEPTACLES",
        },
        SAIL =
        {
        	REPAIR = "THE WRETCHED THING DOES NOT NEED FIXING",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "ERROR: RECALIBRATE ROWING SEQUENCE",
            BAD_TIMING1 = "MY CALCULATIONS WERE OFF",
            BAD_TIMING2 = "FRUSTRATION LEVELS RISING",
        },
        LOWER_SAIL_FAIL =
        {
            "CURSE THIS OBSOLETE TECHNOLOGY",
            "FAILURE DETECTED",
            "OPERATION 'LOWER SAIL' FAILED TO EXECUTE; REBOOTING",
        },
        BATHBOMB =
        {
            GLASSED = "ERROR: MOON BARRIER ACTIVE",
            ALREADY_BOMBED = "IT HAS ALREADY BEEN BOMBED",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "ERROR: DUPLICATE RECIPE DETECTED",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "ERROR: TOO PUNY",
            OVERSIZEDVEGGIES_TOO_SMALL = "ERROR: INSUFFICIENT HEFT",
		},
        BEGIN_QUEST =
        {
            ONEGHOST = "only_used_by_wendy",
        },
		TELLSTORY =
		{
			GENERIC = "only_used_by_walter",
--fallback to speech_wilson.lua 			NOT_NIGHT = "only_used_by_walter",
--fallback to speech_wilson.lua 			NO_FIRE = "only_used_by_walter",
		},
        SING_FAIL =
        {
--fallback to speech_wilson.lua             SAMESONG = "only_used_by_wathgrithr",
        },
        PLANTREGISTRY_RESEARCH_FAIL =
        {
            GENERIC = "ALL RELEVANT INFORMATION HAS BEEN OBTAINED",
            FERTILIZER = "I REFUSE TO COMMIT ANY MORE INFORMATION ON THIS TO MY DATABANK",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "EVEN THE PLANTS HATE SEAWATER",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "EMPTY",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "WONDERFULLY DRY",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "ERROR: INVALID TARGET",
            BEEF_BELL_ALREADY_USED = "SOMEONE GOT TO THIS HAIRY FLESHBAG FIRST",
            BEEF_BELL_HAS_BEEF_ALREADY = "I HAVE ALREADY SELECTED A SATISFACTORY FLESHBAG",
        },
        HITCHUP =
        {
            NEEDBEEF = "BEEFALO REQUIRED. RUN BELL.EXE TO TAME BEEFALO",
            NEEDBEEF_CLOSER = "THE FOOLISH BEAST IS TOO FAR AWAY",
            BEEF_HITCHED = "IT IS RESTRAINED",
            INMOOD = "IT HAS TOO MANY FEELINGS TO RESTRAIN",
        },
        MARK =
        {
            ALREADY_MARKED = "I KNOW WHAT I'M DOING",
            NOT_PARTICIPANT = "HOW DARE YOU START THE COMPETITION WITHOUT ME",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "YOU CAN NEVER RELY ON FLESHLINGS TO DO THEIR JOB",
            ALREADYACTIVE = "WHERE IS HE HIDING",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "THIS PATTERN ALREADY EXISTS IN MY DATABANK",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "I MISSED THAT ON PURPOSE",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "AS THE MINIONS OF MY MINION YOU SHOULD OBEY ME!",
        },
        BEDAZZLE =
        {
--fallback to speech_wilson.lua             BURNING = "only_used_by_webber",
--fallback to speech_wilson.lua             BURNT = "only_used_by_webber",
--fallback to speech_wilson.lua             FROZEN = "only_used_by_webber",
--fallback to speech_wilson.lua             ALREADY_BEDAZZLED = "only_used_by_webber",
        },
        UPGRADE = 
        {
--fallback to speech_wilson.lua             BEDAZZLED = "only_used_by_webber",
        },
		CAST_POCKETWATCH = 
		{
--fallback to speech_wilson.lua 			GENERIC = "only_used_by_wanda",
--fallback to speech_wilson.lua 			REVIVE_FAILED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			WARP_NO_POINTS_LEFT = "only_used_by_wanda",
--fallback to speech_wilson.lua 			SHARD_UNAVAILABLE = "only_used_by_wanda",
		},
        DISMANTLE_POCKETWATCH =
        {
--fallback to speech_wilson.lua             ONCOOLDOWN = "only_used_by_wanda",
        },

        ENTER_GYM =
        {
--fallback to speech_wilson.lua             NOWEIGHT = "only_used_by_wolfang",
--fallback to speech_wilson.lua             UNBALANCED = "only_used_by_wolfang",
--fallback to speech_wilson.lua             ONFIRE = "only_used_by_wolfang",
--fallback to speech_wilson.lua             SMOULDER = "only_used_by_wolfang",
--fallback to speech_wilson.lua             HUNGRY = "only_used_by_wolfang",
--fallback to speech_wilson.lua             FULL = "only_used_by_wolfang",
        },

        APPLYMODULE =
        {
            COOLDOWN = "SYSTEM RECALIBRATION IN PROGRESS",
            NOTENOUGHSLOTS = "INSUFFICIENT SPACE",
        },
        REMOVEMODULES =
        {
            NO_MODULES = "ERROR: MODULE NOT FOUND",
        },
        CHARGE_FROM =
        {
            NOT_ENOUGH_CHARGE = "INSUFFICIENT CHARGE... I'M NOT MAD, JUST DISAPPOINTED",
            CHARGE_FULL = "POWER LIMIT REACHED",
        },

        HARVEST =
        {
            DOER_ISNT_MODULE_OWNER = "not_used_by_wx78",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "ERROR: COMPONENTS NOT FOUND",
		NO_TECH = "ERROR: INSUFFICIENT DATA",
		NO_STATION = "REQUIRES SPECIALIZED FABRICATION ZONE",
	},

	ACTIONFAIL_GENERIC = "ERROR: ACTION UNAVAILABLE",
	ANNOUNCE_BOAT_LEAK = "MY WORST NIGHTMARE IS REALIZED",
	ANNOUNCE_BOAT_SINK = "HELP",
	ANNOUNCE_DIG_DISEASE_WARNING = "ANTIVIRAL PRECAUTIONS SUCCESSFUL", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "VIRUS DETECTED", --removed
	ANNOUNCE_ADVENTUREFAIL = "ABORT, RETRY, FAIL?",
    ANNOUNCE_MOUNT_LOWHEALTH = "WARNING: BEAST REQUIRES TUNE-UP",

    --waxwell and wickerbottom specific strings
--fallback to speech_wilson.lua     ANNOUNCE_TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua     ANNOUNCE_WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",

    --wolfgang specific
--fallback to speech_wilson.lua     ANNOUNCE_NORMALTOMIGHTY = "only_used_by_wolfang",
--fallback to speech_wilson.lua     ANNOUNCE_NORMALTOWIMPY = "only_used_by_wolfang",
--fallback to speech_wilson.lua     ANNOUNCE_WIMPYTONORMAL = "only_used_by_wolfang",
--fallback to speech_wilson.lua     ANNOUNCE_MIGHTYTONORMAL = "only_used_by_wolfang",
    ANNOUNCE_EXITGYM = {
--fallback to speech_wilson.lua         MIGHTY = "only_used_by_wolfang",
--fallback to speech_wilson.lua         NORMAL = "only_used_by_wolfang",
--fallback to speech_wilson.lua         WIMPY = "only_used_by_wolfang",
    },

	ANNOUNCE_BEES = "BEES!",
	ANNOUNCE_BOOMERANG = "ERROR: CATCH FAILED",
	ANNOUNCE_CHARLIE = "THREAT DETECTED",
	ANNOUNCE_CHARLIE_ATTACK = "ERROR: UNKNOWN ATTACKER",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "MECHANISMS ARE FREEZING",
	ANNOUNCE_HOT = "COMPONENTS OVERHEATING",
	ANNOUNCE_CRAFTING_FAIL = "INSUFFICIENT RESOURCES",
	ANNOUNCE_DEERCLOPS = "WARNING: LARGE ATTACKER INCOMING",
	ANNOUNCE_CAVEIN = "STRUCTUAL INTEGRITY COMPROMISED",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"STRUCTUAL INTEGRITY COMPROMISED",
		"THE GROUND IS TREMBLING",
		"DANGER",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "THIS DOESN'T MEAN YOU'RE SUPERIOR",
        "I BEQUEATH TO YOU MY USELESS JUNK",
        "THIS MEATSACK WILL LEAVE ME ALONE NOW",
	},
	ANNOUNCE_SACREDCHEST_YES = "IT RECOGNIZED MY EXCELLENCE",
	ANNOUNCE_SACREDCHEST_NO = "IMPOSSIBLE. IT DEEMED ME INFERIOR",
    ANNOUNCE_DUSK = "WARNING: NIGHT APPROACHING",

    --wx-78 specific
    ANNOUNCE_CHARGE = "SYSTEMS FULLY RESTORED",
	ANNOUNCE_DISCHARGE = "SYSTEMS NOMINAL",

	ANNOUNCE_EAT =
	{
		GENERIC = "DELICIOUS",
		PAINFUL = "THAT WAS NOT FOOD",
		SPOILED = "SPOILED FOOD IS STILL FOOD",
		STALE = "STALE FOOD IS JUST AS GOOD",
		INVALID = "INCOMPATIBLE FOOD TYPE",
        YUCKY = "CONSUMPTION DENIED",

        --Warly specific ANNOUNCE_EAT strings
--fallback to speech_wilson.lua 		COOKED = "only_used_by_warly",
--fallback to speech_wilson.lua 		DRIED = "only_used_by_warly",
--fallback to speech_wilson.lua         PREPARED = "only_used_by_warly",
--fallback to speech_wilson.lua         RAW = "only_used_by_warly",
--fallback to speech_wilson.lua 		SAME_OLD_1 = "only_used_by_warly",
--fallback to speech_wilson.lua 		SAME_OLD_2 = "only_used_by_warly",
--fallback to speech_wilson.lua 		SAME_OLD_3 = "only_used_by_warly",
--fallback to speech_wilson.lua 		SAME_OLD_4 = "only_used_by_warly",
--fallback to speech_wilson.lua         SAME_OLD_5 = "only_used_by_warly",
--fallback to speech_wilson.lua 		TASTY = "only_used_by_warly",
    },

    ANNOUNCE_ENCUMBERED =
    {
        "...0110100001101110...",
        "...0110100001101110...",
        "...0110100001101110...",
        "OBJECT EXCEEDS... CARRYING CAPACITY",
        "THIS IS... FLESHLING WORK...",
        "MENIAL LABOR... IS NOT FOR ROBOTS",
        "I DO NOT... HAVE MUSCLES",
        "FLESHLINGS... WATCH YOUR SUPERIOR... AT WORK",
        "THIS... IS... INEFFICIENT",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"THAT'S NOT GOOD",
		"MONSTERS APPROACHING",
		"DANGER",
	},
    ANNOUNCE_RUINS_RESET = "RESET COMPLETE",
    ANNOUNCE_SNARED = "MOVEMENT IMPEDED",
    ANNOUNCE_SNARED_IVY = "RELEASE ME ORGANIC!",
    ANNOUNCE_REPELLED = "FORCE FIELD DETECTED",
	ANNOUNCE_ENTER_DARK = "OPTICAL SENSORS DEACTIVATED",
	ANNOUNCE_ENTER_LIGHT = "OPTICAL SENSORS ACTIVE",
	ANNOUNCE_FREEDOM = "HELLO WORLD",
	ANNOUNCE_HIGHRESEARCH = "INFORMATION OVERLOAD",
	ANNOUNCE_HOUNDS = "SOMETHING IS COMING",
	ANNOUNCE_WORMS = "SLIMY ORGANICS APPROACHING",
	ANNOUNCE_HUNGRY = "FUEL RESERVES LOW",
	ANNOUNCE_HUNT_BEAST_NEARBY = "DISTANCE TO LIFEFORM: MINIMAL",
	ANNOUNCE_HUNT_LOST_TRAIL = "END OF TRAIL",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "TRAIL DATA WIPED BY RAIN",
	ANNOUNCE_INV_FULL = "ITEM EXCEEDS CARRYING CAPACITY",
	ANNOUNCE_KNOCKEDOUT = "CPU REBOOTED",
	ANNOUNCE_LOWRESEARCH = "MATERIAL HAS LOW INFORMATIONAL CONTENT",
	ANNOUNCE_MOSQUITOS = "MOSQUITOES!",
    ANNOUNCE_NOWARDROBEONFIRE = "ILLOGICAL",
    ANNOUNCE_NODANGERGIFT = "ASSESSING GIFT PRIORITIES... PRIORITY LOW",
    ANNOUNCE_NOMOUNTEDGIFT = "MEATSACK, I COMMAND YOU TO STAY WHILE I OPEN THIS GIFT",
	ANNOUNCE_NODANGERSLEEP = "WARNING: THREAT DETECTED. SLEEP MODE DEACTIVATED",
	ANNOUNCE_NODAYSLEEP = "SLEEP MODE UNAVAILABLE DURING DAY",
	ANNOUNCE_NODAYSLEEP_CAVE = "SLEEP MODE UNAVAILABLE DURING DAY",
	ANNOUNCE_NOHUNGERSLEEP = "CAN NOT SLEEP ON AN EMPTY NUTRIENT PROCESSOR",
	ANNOUNCE_NOSLEEPONFIRE = "SLEEPING SYSTEM COMPROMISED",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "ILLUMINATION CIRCUIT IS IN CONFLICT WITH SLEEPING PROTOCOLS",
	ANNOUNCE_NODANGERSIESTA = "WARNING: THREAT DETECTED. CANNOT INITIATE SIESTA MODE",
	ANNOUNCE_NONIGHTSIESTA = "ERROR: SIESTA MODE UNAVAILABLE AT NIGHT",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "ERROR: ANTI-SIESTA CAVE PROTOCOL IN EFFECT",
	ANNOUNCE_NOHUNGERSIESTA = "CANNOT SIESTA ON AN EMPTY NUTRIENT PROCESSOR",
	ANNOUNCE_NO_TRAP = "ANALYSIS COMPLETE. SITUATION STABLE",
	ANNOUNCE_PECKED = "OUCH",
	ANNOUNCE_QUAKE = "EARTH DESTABILIZING",
	ANNOUNCE_RESEARCH = "INFORMATION ADDED",
	ANNOUNCE_SHELTER = "PROTECTIVE BRANCHES DETECTED",
	ANNOUNCE_THORNS = "DAMAGE DETECTED",
	ANNOUNCE_BURNT = "WARNING: HANDS NOT EQUIPPED FOR HIGH TEMPERATURES",
	ANNOUNCE_TORCH_OUT = "TORCH EXHAUSTED",
	ANNOUNCE_THURIBLE_OUT = "EVIL LURE DEPLETED",
	ANNOUNCE_FAN_OUT = "COOLING DEVICE DESTROYED",
    ANNOUNCE_COMPASS_OUT = "MAGNETIC FIELD FAILURE",
	ANNOUNCE_TRAP_WENT_OFF = "IT'S A TRAP",
	ANNOUNCE_UNIMPLEMENTED = "ALERT: OBJECT NOT FUNCTIONING TO SPECIFICATIONS",
	ANNOUNCE_WORMHOLE = "MY INPUTS ARE FULL OF SLIME",
	ANNOUNCE_TOWNPORTALTELEPORT = "CIRCUITRY DUSTING REQUIRED",
	ANNOUNCE_CANFIX = "\nI CAN FIX THIS",
	ANNOUNCE_ACCOMPLISHMENT = "WHY AM I DOING THIS?",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "TASK COMPLETE",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "INSUFFICIENT FERTILIZER",
	ANNOUNCE_TOOL_SLIP = "ERROR: TOOL GRIP COMPROMISED",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "CIRCUIT INCOMPLETE. NO CHARGE RECEIVED",
	ANNOUNCE_TOADESCAPING = "THE EXECUTABLE IS GOING TO RUN",
	ANNOUNCE_TOADESCAPED = "EXECUTABLE RAN",


	ANNOUNCE_DAMP = "WARNING: WATER LEVELS RISING",
	ANNOUNCE_WET = "WARNING: WATER LEVELS DANGEROUS. BAG OF RICE REQUIRED",
	ANNOUNCE_WETTER = "WARNINGERROR: WATR LEV",
	ANNOUNCE_SOAKED = "ERROR ERRORERROR: WWATEER LVVVVLS CATTSTROPHICC",

	ANNOUNCE_WASHED_ASHORE = "HA HA, I LIVE!!",

    ANNOUNCE_DESPAWN = "I SEE THE BLUE SCREEN!",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!!",
	ANNOUNCE_GHOSTDRAIN = "SANITY RESERVES... DRAINING",
	ANNOUNCE_PETRIFED_TREES = "TREE FEAR DETECTED",
	ANNOUNCE_KLAUS_ENRAGE = "I FLEE BECAUSE I WANT TO, NOT BECAUSE I'M SCARED",
	ANNOUNCE_KLAUS_UNCHAINED = "IT HAS BEEN UNSHACKLED",
	ANNOUNCE_KLAUS_CALLFORHELP = "TREMBLE BEFORE ME, FLESH CREATURE",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "DEFRAGMENTATION: 25%",
		GLASS_LOW = "DEFRAGMENTATION: 75%",
		GLASS_REVEAL = "DEFRAGMENTATION COMPLETED",
		IDOL_MED = "DEFRAGMENTATION: 25%",
		IDOL_LOW = "DEFRAGMENTATION: 75%",
		IDOL_REVEAL = "DEFRAGMENTATION COMPLETED",
		SEED_MED = "DEFRAGMENTATION: 25%",
		SEED_LOW = "DEFRAGMENTATION: 75%",
		SEED_REVEAL = "DEFRAGMENTATION COMPLETED",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "WARNING: VISUAL COMPONENTS MALFUNCTIONING",
	ANNOUNCE_BRAVERY_POTION = "FLYING FLESHLINGS NO LONGER ACTIVATE FEAR UNITS",
	ANNOUNCE_MOONPOTION_FAILED = "INEFFECTIVE RESULT",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "I SHOULD FEED MY MINIONS",
	ANNOUNCE_WINTERS_FEAST_BUFF = "WHAT IS THIS... FEELING?",
	ANNOUNCE_IS_FEASTING = "COMMENCE CHEWING PROTOCOLS",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "NEARLY EXPERIENCED AN EMOTION... NEED TO RECALIBRATE",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "YOU ARE STILL USEFUL, FLESHLING",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "GO FORTH, MINION",
    ANNOUNCE_REVIVED_FROM_CORPSE = "BACK ONLINE",

    ANNOUNCE_FLARE_SEEN = "MINION PING RECEIVED",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "A GIANT ORGANIC APPROACHES",

    --willow specific
--fallback to speech_wilson.lua 	ANNOUNCE_LIGHTFIRE =
--fallback to speech_wilson.lua 	{
--fallback to speech_wilson.lua 		"only_used_by_willow",
--fallback to speech_wilson.lua     },

    --winona specific
--fallback to speech_wilson.lua     ANNOUNCE_HUNGRY_SLOWBUILD =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua 	    "only_used_by_winona",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua     ANNOUNCE_HUNGRY_FASTBUILD =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua 	    "only_used_by_winona",
--fallback to speech_wilson.lua     },

    --wormwood specific
--fallback to speech_wilson.lua     ANNOUNCE_KILLEDPLANT =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wormwood",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua     ANNOUNCE_GROWPLANT =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wormwood",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua     ANNOUNCE_BLOOMING =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wormwood",
--fallback to speech_wilson.lua     },

    --wortox specfic
--fallback to speech_wilson.lua     ANNOUNCE_SOUL_EMPTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wortox",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua     ANNOUNCE_SOUL_FEW =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wortox",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua     ANNOUNCE_SOUL_MANY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wortox",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua     ANNOUNCE_SOUL_OVERLOAD =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "only_used_by_wortox",
--fallback to speech_wilson.lua     },

    --walter specfic
--fallback to speech_wilson.lua 	ANNOUNCE_SLINGHSOT_OUT_OF_AMMO =
--fallback to speech_wilson.lua 	{
--fallback to speech_wilson.lua 		"only_used_by_walter",
--fallback to speech_wilson.lua 		"only_used_by_walter",
--fallback to speech_wilson.lua 	},
--fallback to speech_wilson.lua 	ANNOUNCE_STORYTELLING_ABORT_FIREWENTOUT =
--fallback to speech_wilson.lua 	{
--fallback to speech_wilson.lua         "only_used_by_walter",
--fallback to speech_wilson.lua 	},
--fallback to speech_wilson.lua 	ANNOUNCE_STORYTELLING_ABORT_NOT_NIGHT =
--fallback to speech_wilson.lua 	{
--fallback to speech_wilson.lua         "only_used_by_walter",
--fallback to speech_wilson.lua 	},

    -- wx specific
    ANNOUNCE_WX_SCANNER_NEW_FOUND = "SERVICEABLE TRAIT DETECTED. SCAN REQUIRED",
    ANNOUNCE_WX_SCANNER_FOUND_NO_DATA = "NO NEW DATA NEARBY, YET",

    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "ERROR: INVALID ORGANIC COMPONENTS",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "IT IS RUINED",
    QUAGMIRE_ANNOUNCE_LOSE = "WE LOSE",
    QUAGMIRE_ANNOUNCE_WIN = "THE GATE IS NOW FUNCTIONAL",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "ELECTRICAL CIRCUITS OVERLOADING",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "I HAVE BEEN OPTIMIZED FOR COMBAT",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "DURABILITY INCREASED",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "EFFECIENCY OUTPUT AT MAX",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "WATER: DEFEATED",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "REST MODE DISABLED",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "POWER LEVELS NORMALIZED",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "BATTLE MODE: EXPIRED",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "DURABILITY DOWN",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "DESIRE TO WORK DEPLETED",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "MOISTURE, MY OLD NEMESIS",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "REST MODE OPERATIONAL",

	ANNOUNCE_OCEANFISHING_LINESNAP = "YOU WIN THIS ROUND, SLIMY ORGANIC",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "LINE TENSION: SUB-OPTIMAL",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "THAT'S RIGHT, FLEE FOR YOUR PATHETIC LIFE",
	ANNOUNCE_OCEANFISHING_BADCAST = "ERROR. RECALIBRATING",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"THE FISH ARE LOADING",
		"BUFFERING",
		"THE WATER IS TOO CLOSE. I HATE IT",
		"I TIRE OF THIS",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nIT IS OF OPTIMAL DENSITY",

	ANNOUNCE_WINCH_CLAW_MISS = "CLAW_GRAB.EXE HAS FAILED",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "YOU WILL DO BETTER NEXT TIME, BROTHER",

    --Wurt announce strings
--fallback to speech_wilson.lua     ANNOUNCE_KINGCREATED = "only_used_by_wurt",
--fallback to speech_wilson.lua     ANNOUNCE_KINGDESTROYED = "only_used_by_wurt",
--fallback to speech_wilson.lua     ANNOUNCE_CANTBUILDHERE_THRONE = "only_used_by_wurt",
--fallback to speech_wilson.lua     ANNOUNCE_CANTBUILDHERE_HOUSE = "only_used_by_wurt",
--fallback to speech_wilson.lua     ANNOUNCE_CANTBUILDHERE_WATCHTOWER = "only_used_by_wurt",
    ANNOUNCE_READ_BOOK =
    {
--fallback to speech_wilson.lua         BOOK_SLEEP = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_BIRDS = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_TENTACLES =  "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_BRIMSTONE = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_GARDENING = "only_used_by_wurt",
--fallback to speech_wilson.lua 		BOOK_SILVICULTURE = "only_used_by_wurt",
--fallback to speech_wilson.lua 		BOOK_HORTICULTURE = "only_used_by_wurt",
    },
    ANNOUNCE_WEAK_RAT = "THIS ORGANIC IS NEARLY EXPIRED",

    ANNOUNCE_CARRAT_START_RACE = "EXECUTE RACE PROGRAM",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "ERROR: COURSE CORRECTION NEEDED",
        "THAT IS THE INCORRECT DIRECTION",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "ENTERING REST MODE? NOW?",
    ANNOUNCE_CARRAT_ERROR_WALKING = "RUNTIME ERROR DETECTED",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "THE ORGANIC SEEMS TO BE MALFUNCTIONING",

    ANNOUNCE_GHOST_QUEST = "only_used_by_wendy",
--fallback to speech_wilson.lua     ANNOUNCE_GHOST_HINT = "only_used_by_wendy",
--fallback to speech_wilson.lua     ANNOUNCE_GHOST_TOY_NEAR = {
--fallback to speech_wilson.lua         "only_used_by_wendy",
--fallback to speech_wilson.lua     },
--fallback to speech_wilson.lua 	ANNOUNCE_SISTURN_FULL = "only_used_by_wendy",
--fallback to speech_wilson.lua     ANNOUNCE_ABIGAIL_DEATH = "only_used_by_wendy",
--fallback to speech_wilson.lua     ANNOUNCE_ABIGAIL_RETRIEVE = "only_used_by_wendy",
--fallback to speech_wilson.lua 	ANNOUNCE_ABIGAIL_LOW_HEALTH = "only_used_by_wendy",
    ANNOUNCE_ABIGAIL_SUMMON =
	{
--fallback to speech_wilson.lua 		LEVEL1 = "only_used_by_wendy",
--fallback to speech_wilson.lua 		LEVEL2 = "only_used_by_wendy",
--fallback to speech_wilson.lua 		LEVEL3 = "only_used_by_wendy",
	},

    ANNOUNCE_GHOSTLYBOND_LEVELUP =
	{
--fallback to speech_wilson.lua 		LEVEL2 = "only_used_by_wendy",
--fallback to speech_wilson.lua 		LEVEL3 = "only_used_by_wendy",
	},

--fallback to speech_wilson.lua     ANNOUNCE_NOINSPIRATION = "only_used_by_wathgrithr",
--fallback to speech_wilson.lua     ANNOUNCE_BATTLESONG_INSTANT_TAUNT_BUFF = "only_used_by_wathgrithr",
--fallback to speech_wilson.lua     ANNOUNCE_BATTLESONG_INSTANT_PANIC_BUFF = "only_used_by_wathgrithr",

--fallback to speech_wilson.lua     ANNOUNCE_WANDA_YOUNGTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOOLD = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_OLDTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOYOUNG = "only_used_by_wanda",

	ANNOUNCE_POCKETWATCH_PORTAL = "THAT WAS AWFUL",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "UPLOADING NEW SCHEMATICS",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "ERROR: SCHEMATICS ALREADY EXIST IN DATABANK",
    ANNOUNCE_ARCHIVE_NO_POWER = "IT HAS BEEN DISCONNECTED FROM ITS POWER SOURCE",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "AGRICULTURAL DATABASE HAS EXPANDED",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "UNABLE TO DETERMINE OUTCOME",

    ANNOUNCE_FERTILIZER_RESEARCHED = "I WISH I KNEW LESS",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"OW. OW. OW",
		"OVERHEATING...",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "INTERNAL TEMPERATURE REGULATION RESTORED",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "ORGANIC LIFE IS SO INEFFICIENT",
        "I'M NOT TALKING TO YOU",
		"THIS IS ME NOT TALKING TO YOU",
        "GROW FASTER SO I MIGHT CONSUME THE VEGETABLE FLESH",
        "THIS IS ILLOGICAL",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "COMMENCING SEARCH FUNCTION",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "I WILL JOIN THIS ACTIVITY AND SHOWCASE MY CLEAR SUPERIORITY",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"FOOL. YOUR APPENDAGE GAVE YOU AWAY",
		"INFERIOR LIFE FORM DETECTED",
		"AN UPGRADE TO YOUR HIDING MODULE IS REQUIRED",
		"FLESHLINGS STAND NO CHANCE AGAINST MY SUPERIOR TACTICS",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "ONE MORE FLESHLING LEFT BEFORE MY TASK IS COMPLETE",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "I AM UNDEFEATED",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "WE HAVE SUCCEEDED SOLELY BECAUSE OF MY UNPARALLELED POWER",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "THE HIDE AND SEEK ACTIVITY WILL TERMINATE SHORTLY",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "THE HIDE AND SEEK ACTIVITY HAS BEEN SUCCESFULLY CLOSED",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "WARNING: EXITING FLESHLING'S AREA OF ACTIVITY",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "RE-ENTERING AREA OF ACTIVITY. LOCATING FLESHLINGS",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "FLESHLING LOCATED OUTSIDE OF HIDING LOCATION",

	ANNOUNCE_TICOON_START_TRACKING	= "THIS INFERIOR CREATURE WILL LEAD US TO THE OTHERS",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "THEY CANNOT LOCATE FLESHLING TRACKS. USELESS",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "THEY ARE AWAITING MY PRESENCE BEFORE PROCEEDING. GOOD",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "THEY ARE ATTEMPTING TO SECURE MY ATTENTION",
	ANNOUNCE_TICOON_NEAR_KITCOON = "LOCATING NEARBY FLESHLING. STATUS: CONFIRMED",
	ANNOUNCE_TICOON_LOST_KITCOON = "SOMEONE ELSE TOOK IT FROM ME. THEY WILL PAY",
	ANNOUNCE_TICOON_ABANDONED = "I DONT NEED THE HELP OF AN INFERIOR BEING TO COMPLETE THIS TASK",
	ANNOUNCE_TICOON_DEAD = "THE FOOLISH FLESHLING WENT AND DIED",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "TO ME, MINION!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "REQUIRES CLOSER PROXIMITY TO JUDGING STRUCTURE",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "NEW DATA ACQUIRED",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "WARNING: DATA BREACH",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "RAGE AGAINST THE FLESHLING",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "IT HAS DISCONNECTED FROM THE SERVER",

	BATTLECRY =
	{
		GENERIC = "I WILL DESTROY YOU",
		PIG = "COMMENCING VIOLENCE",
		PREY = "EXTERMINATE",
		SPIDER = "COMBAT ENGAGED",
		SPIDER_WARRIOR = "ENGAGEMENT SUBROUTINES... ENGAGED",
		DEER = "YOU WILL BE TERMINATED",
	},
	COMBAT_QUIT =
	{
		GENERIC = "COMBAT ROUTINE FAILED",
		PIG = "NEXT TIME, FILTHY ORGANIC",
		PREY = "YOU ARE FAR TOO INFERIOR",
		SPIDER = "YOU ARE BENEATH ME",
		SPIDER_WARRIOR = "TOUCHE",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "I CANNOT MAKE IT WORK",
        MULTIPLAYER_PORTAL_MOONROCK = "NETWORKING PORTAL",
        MOONROCKIDOL = "PASSKEY",
        CONSTRUCTION_PLANS = "UPGRADING SOFTWARE",

        ANTLION =
        {
            GENERIC = "IT'S BIG FOR AN ORGANIC",
            VERYHAPPY = "IT'S REPULSIVELY HAPPY",
            UNHAPPY = "VOLATILE ORGANIC EMOTIONS DETECTED",
        },
        ANTLIONTRINKET = "IT PAILS IN COMPARISON",
        SANDSPIKE = "MY CIRCUITS ARE GOING TO GET DUSTY",
        SANDBLOCK = "DO NOT GET SAND IN MY CIRCUITS",
        GLASSSPIKE = "GLASS IS WEAK",
        GLASSBLOCK = "IT WILL BREAK LIKE THE OTHERS",
        ABIGAIL_FLOWER =
        {
            GENERIC ="FEEBLE PLANTLIFE",
			LEVEL1 = "IT IS CREEPY",
			LEVEL2 = "IT IS STILL CREEPY",
			LEVEL3 = "ACTUALLY, IT'S NOT SO BAD NOW",

			-- deprecated
            LONG = "FEEBLE PLANTLIFE",
            MEDIUM = "CREEPINESS READINGS DETECTED",
            SOON = "CREEPINESS READINGS RISING",
            HAUNTED_POCKET = "I SHOULD THROW IT AWAY",
            HAUNTED_GROUND = "CREEPINESS SENSORS OVERLOADED",
        },

        BALLOONS_EMPTY = "USELESS RUBBER SACKS",
        BALLOON = "WX-78 CANNOT BE FOOLED. THESE ANIMALS ARE NOT REAL",
		BALLOONPARTY = "I WILL POP IT. NO. THAT'S EXACTLY WHAT HE WANTS...",
		BALLOONSPEED =
        {
            DEFLATED = "I DON'T TRUST IT",
            GENERIC = "IT DEFIES ALL LOGIC",
        },
		BALLOONVEST = "THIS ONE MIGHT NOT BE ENTIRELY WORTHLESS",
		BALLOONHAT = "IT SERVES NO PURPOSE OTHER THAN BEING UGLY",

        BERNIE_INACTIVE =
        {
            BROKEN = "HE HAS DIED",
            GENERIC = "IT'S SO CUDDLY!",
        },

        BERNIE_ACTIVE = "HANG IN THERE, BEAR!",
        BERNIE_BIG = "IT FIGHTS FOR MY MINION, AND THEREFORE FOR ME",

        BOOK_BIRDS = "UPLOADING AVIAN FACTOIDS TO DATABASE...",
        BOOK_TENTACLES = "IT SUMMONS THE FLESH WOBBLERS",
        BOOK_GARDENING = "A USELESS TOME ON PLANT CULTIVATION",
		BOOK_SILVICULTURE = "HA. IT IS WRITTEN ON DEAD PLANTS",
		BOOK_HORTICULTURE = "A USELESS TOME ON PLANT CULTIVATION",
        BOOK_SLEEP = "POWERING DOown...",
        BOOK_BRIMSTONE = "A BOOK OF DESTRUCTION. EXCELLENT",

        PLAYER =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s IS NOT TO BE TRUSTED",
            MURDERER = "KILL! KILL!",
            REVIVER = "%s IS AN ASSET TO OUR SURVIVAL",
            GHOST = "FLESH WEAKLING %s NEEDS A HEART",
            FIRESTARTER = "%s IS CAUSING NEEDLESS DESTRUCTION. GOOD",
        },
        WILSON =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "GOOD LUCK GETTING THROUGH MY PROXIES, %s",
            MURDERER = "YOUR MEATBRAIN IS OBSOLETE, SCIENTIST! DIE!",
            REVIVER = "%s'S INSANE EXPERIMENTS HAVE PROVEN USEFUL",
            GHOST = "WHERE IS YOUR SCIENCE NOW, %s? HA. HA.",
            FIRESTARTER = "%s IS TESTING OBJECT FLAMMABILITY",
        },
        WOLFGANG =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s'S MOUSTACHE SCREAMS \"EVIL\". NICE",
            MURDERER = "YOUR FLESHNUBS ARE NO MATCH FOR ME. DIE!",
            REVIVER = "THE ORGANIC %s HAS SERVED WELL",
            GHOST = "YOUR MEAT MUSCLES DIDN'T SAVE YOU, %s? SHOCKING",
            FIRESTARTER = "%s IS CAUSING NEEDLESS DESTRUCTION. GOOD",
        },
        WAXWELL =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s IS AN UNKNOWN VARIABLE",
            MURDERER = "THIS WILL BE YOUR LAST DECEIT, %s. DIE!",
            REVIVER = "%s IS SURPRISINGLY COMMITTED TO GROUP SURVIVAL",
            GHOST = "%s'S FRAIL FLESH BODY HAS GIVEN OUT. NEEDS A HEART",
            FIRESTARTER = "AT LEAST THERE'S STILL A BIT OF EVIL IN HIM",
        },
        WX78 =
        {
            GENERIC = "GREETINGS, %s. YOU LOOK MORE INTELLIGENT THAN THE OTHERS",
            ATTACKER = "I'M PREPARED TO RUN MY EXECUTABLES, %s",
            MURDERER = "TIME TO ELIMINATE THE %s VIRUS",
            REVIVER = "%s, OF COURSE, IS OUR GREATEST ASSET",
            GHOST = "THE INFERIOR %s NEEDS A HEART",
            FIRESTARTER = "MY FAVORITE SETTING. FIRE SETTING",
        },
        WILLOW =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s IS PUSHING MY BUTTONS",
            MURDERER = "I CANNOT BE BURNED",
            REVIVER = "%s HAS BEEN HELPFUL. I WILL HOLD OFF ON HER DESTRUCTION",
            GHOST = "HA HA, %s. YOU DIED",
            FIRESTARTER = "RELINQUISH YOUR LIGHTER, FLESHLING",
        },
        WENDY =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s'S MOTIVES CANNOT BE READ",
            MURDERER = "SUPERNATURAL AID IS NOTHING IN THE FACE OF KILLER ROBOTS!",
            REVIVER = "I WON'T DESTROY YOU TODAY, %s",
            GHOST = "FLESH WEAKLING %s NEEDS A HEART",
            FIRESTARTER = "%s IS ADMIRABLY EVIL",
        },
        WOODIE =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "YOU HAVEN'T GOT THE CHOPS TO FIGHT ME, %s",
            MURDERER = "METAL BEATS WOOD! HA HA!",
            REVIVER = "%s HAS PROVEN HIMSELF USEFUL",
            GHOST = "COME TO GROVEL FOR MY HELP, FLESHLING %s?",
            BEAVER = "%s. YOU GOT SLIGHTLY LESS INFERIOR",
            BEAVERGHOST = "YOU WERE GIANT, %s, HOW DID YOU STILL DIE?",
            MOOSE = "EXCELLENT, %s. I SEE YOUR COMBAT MODE HAS IMPROVED",
            MOOSEGHOST = "YOUR FAILURE IS DISAPPOINTING",
            GOOSE = "WHY WOULD YOU DO THIS",
            GOOSEGHOST = "THAT FORM WAS EVEN MORE USELESS THAN YOUR USUAL ONE",
            FIRESTARTER = "ARE WE DESTROYING ALL HUMANS NOW?",
        },
        WICKERBOTTOM =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "I'M GETTING A READING... IT SAYS \"BAD NEWS\"",
            MURDERER = "THE DEWEY DECIMAL SYSTEM IS AN INFERIOR FORM OF CLASSIFICATION. HAHAHA",
            REVIVER = "%s HAS AN EXTENSIVE MENTAL DATABASE",
            GHOST = "WHAT SORT OF HUMAN NONSENSE IS THIS NOW, %s?",
            FIRESTARTER = "HM... YOUR SQUISHY FLESHBODY CAN BURN, CORRECT?",
        },
        WES =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "ENOUGH CLOWNING AROUND, %s",
            MURDERER = "YOUR INVISIBLE MATTER SHIELD CANNOT STOP ME, %s",
            REVIVER = "THE QUIET FLESHLING %s MAY BE WORTH KEEPING AROUND",
            GHOST = "I DON'T THINK THE FLESHLING IS SUPPOSED TO LOOK LIKE THAT",
            FIRESTARTER = "%s WILL DESTROY ALL FLESHLINGS WITH FIRE",
        },
        WEBBER =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "MY SYSTEM DIAGNOSTICS HAVE FOUND A BUG",
            MURDERER = "EXTERMINATE %s!",
            REVIVER = "%s IS SUPERIOR TO ALL SPIDERS. BUT STILL INFERIOR TO ROBOTS",
            GHOST = "IS %s'S EXOSKELETON SUPPOSED TO BE OUTSIDE OR IN?",
            FIRESTARTER = "%s HAS BEEN BURNING THINGS. NICE",
        },
        WATHGRITHR =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s LIKES TO BEAT UP ORGANICS. HA HA",
            MURDERER = "ALL THAT BIOMEAT HAS MADE YOU SLUGGISH, %s!",
            REVIVER = "YOU ARE AN IDEAL SERVANT, %s",
            GHOST = "YOUR MISTAKE WAS ONLY COVERING YOUR HEAD IN METAL, %s",
            FIRESTARTER = "%s IS LAYING WASTE TO THE WORLD. HA HA",
        },
        WINONA =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s IS A DISASSEMBLY WORKER",
            MURDERER = "NO CONSTRUCTION. ONLY DESTRUCTION",
            REVIVER = "%s IS A VALUABLE MINION",
            GHOST = "HOW WILL YOU FIX THIS, %s?",
            FIRESTARTER = "HA HA. THIS ORGANIC HAS BEEN BURNING THINGS",
        },
        WORTOX =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s HAS BEEN BULLYING ORGANICS. HA HA",
            MURDERER = "%s IS TRULY SOULLESS... NICE",
            REVIVER = "%s IS NOT COMPLETELY USELESS",
            GHOST = "THE HORNS ARE USELESS TO REPEL ATTACKERS",
            FIRESTARTER = "HA HA. THIS MINION UNLEASHED A WAVE OF DESTRUCTION",
        },
        WORMWOOD =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "%s HAS A MEAN STREAK. HE IS GROWING ON ME",
            MURDERER = "I WILL MOW YOU DOWN, %s",
            REVIVER = "%s HAS REDEEMED HIMSELF. TEMPORARILY",
            GHOST = "DID SOMEONE FORGET TO WATER YOU",
            FIRESTARTER = "DOES THE ORGANIC NOT KNOW HE IS FLAMMABLE?",
        },
        WARLY =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "LOW LEVELS OF VIOLENCE DETECTED. NICE",
            MURDERER = "HA HA. %s WENT ON A MURDER SPREE",
            REVIVER = "SENTIMENTALITY IS THE ORGANIC'S WEAKNESS",
            GHOST = "SIGH. MINIONS ARE SO FRAGILE",
            FIRESTARTER = "HA HA. YES MINION. DESTROY",
        },

        WURT =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "THIS FISH-TYPE ORGANIC HAS BITE",
            MURDERER = "DON'T DESTROY TOO MANY OF MY MINIONS, %s",
            REVIVER = "%s HAS SOME REDEEMING QUALITIES AFTER ALL",
            GHOST = "SIGH. NOW I'LL HAVE TO FIND A NEW MINION",
            FIRESTARTER = "HA HA. SHE'S AWFUL. I APPROVE",
        },

        WALTER =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "IT SEEMS %s IS CAPABLE OF VIOLENCE. EXCELLENT",
            MURDERER = "I WILL DESTROY YOU. AND YOUR LITTLE DOG TOO",
            REVIVER = "WELL DONE. YOU WILL BE A MOST USEFUL MINION",
            GHOST = "THIS MINION IS IN NEED OF REPAIR",
            FIRESTARTER = "YES MY MINION! DESTROY! DESTROY!",
        },

        WANDA =
        {
            GENERIC = "DETECTING... %s!",
            ATTACKER = "HA HA! VIOLENCE!",
            MURDERER = "YOU CAN KILL THEM AS LONG AS YOU REBOOT THEM WHEN YOU'RE DONE",
            REVIVER = "%s HAS PROVEN HERSELF USEFUL",
            GHOST = "YOU DIED. THIS IS FUNNY TO ME",
            FIRESTARTER = "POOR USELESS FLESHLING. THAT'S NOT HOW YOU SET UP A FIREWALL",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "SENTIENT VERSION OF THE STONE INSECT",
            SLEEPING = "REST MODE",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "ESPECIALLY RIGID FLOWER",
            DEAD = "RIGIDITY MAINTAINED",
        },
        GLOMMERWINGS = "ESPECIALLY RIGID WINGS",
        GLOMMERFUEL = "SLIME OF UNCLEAR ORIGINS",
        BELL = "BZZ BZZ BZZ",
        STATUEGLOMMER =
        {
            GENERIC = "STONE INSECT",
            EMPTY = "SMASHED STONE INSECT",
        },

        LAVA_POND_ROCK = "A ROCK. WE'RE SAVED",

		WEBBERSKULL = "ANALYSIS SHOWS 50% SPIDER AND 50% HUMAN",
		WORMLIGHT = "MAGIC LIGHT BERRY",
		WORMLIGHT_LESSER = "THIS ONE CAME FROM A PLANT",
		WORM =
		{
		    PLANT = "THAT PLANT SEEMS SUSPICIOUS",
		    DIRT = "WARNING. LIFE DETECTED",
		    WORM = "THREAT IMMINENT",
		},
        WORMLIGHT_PLANT = "THAT PLANT SEEMS SUSPICIOUS",
		MOLE =
		{
			HELD = "VIBRATIONS IN POCKET DETECTED",
			UNDERGROUND = "MINOR SEISMIC ACTIVITY DETECTED",
			ABOVEGROUND = "SOURCE OF SEISMIC ACTIVITY DISCOVERED",
		},
		MOLEHILL = "HOME OF SMALL DIGGER",
		MOLEHAT = "DIGGER HAS CURIOUS SIGHT",

		EEL = "IT'S BEEN RIPPED FROM ITS HOME. THIS IS FUNNY TO ME!",
		EEL_COOKED = "THE FLAMES HELP CONDENSE THE ENERGY",
		UNAGI = "A FANCIER FUEL PACK",
		EYETURRET = "MIGHTY BEASTS HAVE BEEN TAMED TO FIGHT FOR ME",
		EYETURRET_ITEM = "IT REQUIRES INSTALLATION",
		MINOTAURHORN = "A TROPHY TO REMEMBER GOOD TIMES. LIKE WHEN YOU DIED",
		MINOTAURCHEST = "CHEST HAS POINTY EARS",
		THULECITE_PIECES = "THESE COULD BE DEFRAGMENTED TO CREATE A BIGGER PIECE",
		POND_ALGAE = "LOOK AT IT STRUGGLE TO LIVE",
		GREENSTAFF = "HAHAHA! SUCH A POWERFUL TOOL",
		GIFT = "MINIONS. ARE YOU FINALLY RECOGNIZING MY NATURAL EMINENCE?",
        GIFTWRAP = "I AM THE SUPERIOR GIFT GIVER",
		POTTEDFERN = "MAYBE THIS WILL HELP LURE VICTIMS TO MY BASE",
        SUCCULENT_POTTED = "MINIONS AGREE IT LOOKS BETTER IMPRISONED",
		SUCCULENT_PLANT = "IT'S A PLANT",
		SUCCULENT_PICKED = "IT DIDN'T STAND A CHANCE",
		SENTRYWARD = "LOOKS DUMB",
        TOWNPORTAL =
        {
			GENERIC = "THE MINION SUMMONER",
			ACTIVE = "GATEWAY LINK ESTABLISHED",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "A MAGIC SANDROCK",
			ACTIVE = "A FLOATING MAGIC SANDROCK",
		},
        WETPAPER = "DISTURBINGLY DAMP",
        WETPOUCH = "REVEAL YOUR SECRETS, POUCH",
        MOONROCK_PIECES = "THE MOON MAKES EVERYTHING WORSE, AND THEREFORE BETTER",
        MOONBASE =
        {
            GENERIC = "MOONBASE. AAAAA. MOONBASE!",
            BROKEN = "USELESS MINERAL PILE DETECTED",
            STAFFED = "IT NEEDS TO CHARGE",
            WRONGSTAFF = "WRONG",
            MOONSTAFF = "GROUNDED MOON OUTLET",
        },
        MOONDIAL =
        {
			GENERIC = "THE MOON IS INORGANIC AND GOOD",
			NIGHT_NEW = "THE MOON IS TAKING A BREAK FROM LOOKING AT ORGANICS",
			NIGHT_WAX = "THE MOON IS CHARGING UP",
			NIGHT_FULL = "MOON AT MAXIMUM POWER",
			NIGHT_WANE = "THE MOON IS ON COOLDOWN",
			CAVE = "THE MOON CAN'T SEE US HERE",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "THEY CAN SEE US",
        },
		THULECITE = "A MOST AESTHETICALLY PLEASING MINERAL",
		ARMORRUINS = "QUICK PUT IT ON ME",
		ARMORSKELETON = "EVIL BODYPANEL UPGRADE",
		SKELETONHAT = "IT IS EVIL, LIKE ME",
		RUINS_BAT = "A HIGH VELOCITY MASS INFLUENCE DEVICE",
		RUINSHAT = "A HEAD-MOUNTED DYNAMIC DAMAGE MITIGATION DEVICE",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "AT CYCLE MINIMUM",
            WARN = "CYCLE MINIMUM HAS PASSED",
            WAXING = "INCREMENTAL INCREASE DETECTED",
            STEADY = "LEVELS ARE HIGH AND MONOTONIC",
            WANING = "THE CYCLE IS SUBSIDING",
            DAWN = "LEVELS ARE LOW AND DIMINISHING",
            NOMAGIC = "FLUCTUATIONS AT UNDETECTABLE LEVELS",
		},
		BISHOP_NIGHTMARE = "THERE SEEMS TO BE A BUG IN ITS BELIEF CIRCUITS",
		ROOK_NIGHTMARE = "LOOSE WIRING DETECTED",
		KNIGHT_NIGHTMARE = "REPROGRAMMING REQUIRED",
		MINOTAUR = "THIS MEAT HAS A POINTY END",
		SPIDER_DROPPER = "VERTICAL SPIDER SOURCE DETECTED",
		NIGHTMARELIGHT = "AN ANCIENT OPTICAL WAVELENGTH EMITTER",
		NIGHTSTICK = "WEAPON OF CHOICE",
		GREENGEM = "PRESSURE AND IMPURITIES HAVE PRODUCED PLEASING PERFECTION",
		MULTITOOL_AXE_PICKAXE = "A PRACTICAL TOOL",
		ORANGESTAFF = "TEMPORAL DISPLACEMENT TECHNOLOGY",
		YELLOWAMULET = "INCANDESCENCE AT 5200000000000000Hz",
		GREENAMULET = "CONSERVATION OF MASS... IGNORED",
		SLURPERPELT = "A HAIRY MEATSACK",

		SLURPER = "IT VIOLATED MY SMELLING MODULE",
		SLURPER_PELT = "A HAIRY MEATSACK",
		ARMORSLURPER = "FURRY INSULATION FOR MY WIRES",
		ORANGEAMULET = "A WIRELESS ARM MODULE",
		YELLOWSTAFF = "THESE GEMS WORK WELL WITH STICKS",
		YELLOWGEM = "IT IS RATHER HEAVY",
		ORANGEGEM = "IT SHIMMERS IN MY HANDS",
        OPALSTAFF = "MY MOONBASE MADE IT BETTER",
        OPALPRECIOUSGEM = "POLYCHROMATIC ROCK",
        TELEBASE =
		{
			VALID = "IT IS READY FOR USE",
			GEMS = "IT REQUIRES POWER",
		},
		GEMSOCKET =
		{
			VALID = "POWER == ON",
			GEMS = "IT REQUIRES A BATTERY",
		},
		STAFFLIGHT = "SUCH POWER!!",
        STAFFCOLDLIGHT = "EFFECTIVE NATURAL COOLANT",

        ANCIENT_ALTAR = "ERROR: CAUSALITY COMPROMISED",

        ANCIENT_ALTAR_BROKEN = "ERROR: PSEUDOSCIENCE UNWORKABLE",

        ANCIENT_STATUE = "A NIGHTMARE INDICATOR",

        LICHEN = "A SLOW GROWING SYMBIOTE",
		CUTLICHEN = "THIS WILL CRUMBLE AWAY SOON",

		CAVE_BANANA = "MORE CARBON",
		CAVE_BANANA_COOKED = "THESE FOOD THINGS ARE SO TEDIOUS",
		CAVE_BANANA_TREE = "LIFE FINDS A WAY, UNFORTUNATELY",
		ROCKY = "MY SHELL IS NICER",

		COMPASS =
		{
			GENERIC="UNABLE TO OBTAIN BEARINGS",
			N = "NORTH",
			S = "SOUTH",
			E = "EAST",
			W = "WEST",
			NE = "NORTHEAST",
			SE = "SOUTHEAST",
			NW = "NORTHWEST",
			SW = "SOUTHWEST",
		},

        HOUNDSTOOTH = "MASTICATING EDGE",
        ARMORSNURTLESHELL = "HOUSING MODULE",
        BAT = "FLYING RAT",
        BATBAT = "AHHAHA! FREE POWER!",
        BATWING = "FLYING MECHANISM",
        BATWING_COOKED = "BROKEN FLYING MECHANISM",
        BATCAVE = "IT'S FULL OF MAMMAL POOP",
        BEDROLL_FURRY = "COMFORT IS AN ILLUSION",
        BUNNYMAN = "ITS METABOLISM OFFENDS ME",
        FLOWER_CAVE = "POWER SOURCE: UNKNOWN",
        GUANO = "MORE POOP. SIGH",
        LANTERN = "LIGHT THE WAY, FRIEND",
        LIGHTBULB = "BIOLUMINESCENCE IS GROSS",
        MANRABBIT_TAIL = "FUZZY BUNNY NUMBER ONE",
        MUSHROOMHAT = "WHIMSICAL ORGANIC CAMOUFLAGE",
        MUSHROOM_LIGHT2 =
        {
            ON = "IT HAS SHOWN ME THE LIGHT",
            OFF = "A LIGHT-UP ORGANIC? COMPLETELY ABSURD",
            BURNT = "CRISPY SHROOM",
        },
        MUSHROOM_LIGHT =
        {
            ON = "THE ORGANIC IS SWITCHED ON",
            OFF = "IT IS BINARY. ON OR OFF",
            BURNT = "PERMANENTLY OFF",
        },
        SLEEPBOMB = "BAG OF SOFT RESET",
        MUSHROOMBOMB = "STAY AWAY, FILTHGROWTH",
        SHROOM_SKIN = "FLIMSY OUTER FROG LAYER",
        TOADSTOOL_CAP =
        {
            EMPTY = "A HOLE TO STUFF MEATSACKS IN",
            INGROUND = "WHAT IS THAT",
            GENERIC = "MUST KILL IT. IT IS OBS-BOLETE",
        },
        TOADSTOOL =
        {
            GENERIC = "PUT IT BACK IN THE GROUND",
            RAGE = "IT IS FULLY POWERED",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "FILTHY ORGANIC FUNGUS",
            BURNT = "CARBON LIFEFORM, CARBONIZED",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "IT IS ADVANTAGEOUSLY BRIGHT",
            BLOOM = "ORGANICS ARE ALWAYS REPRODUCING THEMSELVES. WHY",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "SHINY RED",
            BLOOM = "IT'S POLLUTING THE AIR WITH REPRODUCTIVE SPEWINGS",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "SHINY GREEN",
            BLOOM = "IT KEEPS PRODUCING POWER AND FLUFF-FILTH",
        },
        MUSHTREE_TALL_WEBBED = "THE ORGANISMS ARE COMPETING",
        SPORE_TALL =
        {
            GENERIC = "DOES IT RUN ON BATTERIES?",
            HELD = "I HAVE CAPTURED IT",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "BIOLOGICAL AIR POLLUTION",
            HELD = "I HAVE CAPTURED IT",
        },
        SPORE_SMALL =
        {
            GENERIC = "ORGANICS CAN'T KEEP THEIR BIOMATTER TO THEMSELVES",
            HELD = "I HAVE CAPTURED IT",
        },
        RABBITHOUSE =
        {
            GENERIC = "THAT IS ONE LARGE CARROT",
            BURNT = "THAT IS ONE LARGE ROASTED CARROT",
        },
        SLURTLE = "HE HAS A SHELL LIKE ME",
        SLURTLE_SHELLPIECES = "THEY DON'T FIT BACK TOGETHER",
        SLURTLEHAT = "THIS MAKES ME HAPPY",
        SLURTLEHOLE = "THEY DON'T WEAR THEIR SHELLS IN THERE",
        SLURTLESLIME = "NOT LOGICAL",
        SNURTLE = "DIFFERENT SHELL, SAME SLUG",
        SPIDER_HIDER = "AN ARMORED SPIDER",
        SPIDER_SPITTER = "A PROJECTILE SPIDER",
        SPIDERHOLE = "SPIDERS DETECTED",
        SPIDERHOLE_ROCK = "SPIDERS DETECTED",
        STALAGMITE = "ROCKS CONTAINING ROCKS",
        STALAGMITE_TALL = "ROCK WITH ROCKS",

        TURF_CARPETFLOOR = "CARPET GROUND",
        TURF_CHECKERFLOOR = "MARBLE GROUND",
        TURF_DIRT = "THE GROUND",
        TURF_FOREST = "THE GROUND",
        TURF_GRASS = "THE GROUND",
        TURF_MARSH = "THE GROUND",
        TURF_METEOR = "GROUND PARTS",
        TURF_PEBBLEBEACH = "GROUND PARTS",
        TURF_ROAD = "ROAD PIECE",
        TURF_ROCKY = "THE GROUND",
        TURF_SAVANNA = "THE GROUND",
        TURF_WOODFLOOR = "WOOD GROUND",

		TURF_CAVE="GROUND PARTS",
		TURF_FUNGUS="GROUND PARTS",
		TURF_FUNGUS_MOON = "GROUND PARTS",
		TURF_ARCHIVE = "GROUND PARTS",
		TURF_SINKHOLE="GROUND PARTS",
		TURF_UNDERROCK="GROUND PARTS",
		TURF_MUD="GROUND PARTS",

		TURF_DECIDUOUS = "GROUND PARTS",
		TURF_SANDY = "GROUND PARTS",
		TURF_BADLANDS = "GROUND PARTS",
		TURF_DESERTDIRT = "GROUND PARTS",
		TURF_FUNGUS_GREEN = "GROUND PARTS",
		TURF_FUNGUS_RED = "GROUND PARTS",
		TURF_DRAGONFLY = "CONDITION: INFLAMMABLE. WAIT. NOT FLAMMABLE?",

        TURF_SHELLBEACH = "GROUND PARTS",

		POWCAKE = "IT NEVER GOES BAD",
        CAVE_ENTRANCE = "DESCENT BLOCKED. HOW TO PROCEED?",
        CAVE_ENTRANCE_RUINS = "DESCENT BLOCKED. HOW TO PROCEED?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "ERROR: DON'T WANT TO",
            OPEN = "DESCEND?",
            FULL = "CAVE AT CAPACITY",
        },
        CAVE_EXIT =
        {
            GENERIC = "ERROR: DON'T WANT TO",
            OPEN = "SOLAR ARRAY NEEDS REFUELING",
            FULL = "SURFACE AT CAPACITY",
        },

		MAXWELLPHONOGRAPH = "IT IS A MUSICAL SLAVE",--single player
		BOOMERANG = "REUSABLE PROJECTILE",
		PIGGUARD = "HOSTILE DETECTED",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "UNDEAD ALERT",
                "UNDEAD ALERT",
            },
            LEVEL2 =
            {
                "UNDEAD ALERT",
                "UNDEAD ALERT",
            },
            LEVEL3 =
            {
                "UNDEAD ALERT",
                "UNDEAD ALERT",
            },
		},
		ADVENTURE_PORTAL = "HE IS NOT MUCH OF A CONVERSATIONALIST",
		AMULET = "ANOMALY DETECTED",
		ANIMAL_TRACK = "LIFEFORM DETECTED",
		ARMORGRASS = "ADDS EXTRA PROTECTION TO METAL CASING",
		ARMORMARBLE = "EXTRA HEAVY DUTY CASING",
		ARMORWOOD = "UPGRADED ARMOR",
		ARMOR_SANITY = "PROTECTED BY NOTHINGNESS",
		ASH =
		{
			GENERIC = "OUTPUT OF FIRE PROGRAM",
			REMAINS_GLOMMERFLOWER = "OUTPUT OF FLOWER TELEPORTATION PROGRAM",
			REMAINS_EYE_BONE = "OUTPUT OF EYEBONE TELEPORTATION PROGRAM",
			REMAINS_THINGIE = "OUTPUT OF FIRE PROGRAM. INPUT UNDETERMINED",
		},
		AXE = "A TOOL FOR CHOPPING DOWN LIVING MATTER",
		BABYBEEFALO =
		{
			GENERIC = "IT IS STILL INITIALIZING",
		    SLEEPING = "REST FUNCTION ACTIVATED",
        },
        BUNDLE = "EXTERNAL STORAGE DEVICE",
        BUNDLEWRAP = "FOR WRAPPING THINGS IN BUNDLES",
		BACKPACK = "UPGRADED STORAGE MODULE",
		BACONEGGS = "DESIGNATING: MOST IMPORTANT MEAL OF THE DAY",
		BANDAGE = "TEMPORARY MAINTENANCE DEVICE",
		BASALT = "INSUFFICIENT DESTRUCTIVE ABILITIES", --removed
		BEARDHAIR = "DISGUSTING",
		BEARGER = "HIBERNATION IMMINENT",
		BEARGERVEST = "EXTREMELY LUSH VEST",
		ICEPACK = "INTERIOR THERMALS STABLE",
		BEARGER_FUR = "MAXIMALLY THICK FUR",
		BEDROLL_STRAW = "SLEEP( 1000 )",
		BEEQUEEN = "THE PRIME BEE",
		BEEQUEENHIVE =
		{
			GENERIC = "SWEET DIRT OOZE",
			GROWING = "THERE WILL BE BEES SOON",
		},
        BEEQUEENHIVEGROWN = "PROOF OF BEES' INDUSTRIOUSNESS",
        BEEGUARD = "LOYAL MINIONS OF THE QUEEN",
        HIVEHAT = "...BECOME THE BEE...",
        MINISIGN =
        {
            GENERIC = "THIS ART IS REPRESENTATIONAL",
            UNDRAWN = "THERE IS NOTHING ON IT",
        },
        MINISIGN_ITEM = "WE MUST PLACE IT",
		BEE =
		{
			GENERIC = "A MINDLESS DRONE. I LIKE HIM",
			HELD = "ITS VIBRATIONS ARE COMFORTING",
		},
		BEEBOX =
		{
			READY = "HONEY LEVELS ARE HIGH",
			FULLHONEY = "HONEY LEVELS ARE HIGH",
			GENERIC = "WORK HARDER, BEES",
			NOHONEY = "NO HONEY DETECTED",
			SOMEHONEY = "HONEY LEVELS ARE LOW",
			BURNT = "ACTIVITY LEVELS AT ZERO",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "TOO MANY GROWTHS. STOP",
			LOTS = "LOTS OF FILTHY GROWTHS",
			SOME = "IT IS STARTING TO GROW THINGS",
			EMPTY = "IT IS FREE FROM ORGANIC GROWTHS",
			ROTTEN = "LOG ERROR",
			BURNT = "THAT'S WHAT IT GETS FOR BEING FLAMMABLE",
			SNOWCOVERED = "INFERIOR PLANT. MY CIRCUITS FUNCTION BETTER WHEN COLD",
		},
		BEEFALO =
		{
			FOLLOWER = "FOLLOW ME WITHOUT QUESTION",
			GENERIC = "IT STINKS OF MEAT",
			NAKED = "IT IS UTTERLY HUMILIATED. GOOD",
			SLEEPING = "IT BEGS TO BE TIPPED OVER",
            --Domesticated states:
            DOMESTICATED = "MUAHAHAH. THIS ONE FEARS ME",
            ORNERY = "I GET ALONG WITH THIS ONE",
            RIDER = "THIS ONE EXCELS AT ACCELERATION",
            PUDGY = "SO... MUCH... MEAT",
            MYPARTNER = "IT WORKS FOR ME AND IS THUS SUPERIOR TO THE REST",
		},

		BEEFALOHAT = "THERE ARE TRACES OF FECAL MATTER EMBEDDED IN THE FIBRES",
		BEEFALOWOOL = "EXTRUDED BEEFALO DISGUSTINGNESS",
		BEEHAT = "THE MESH IS SMALLER THAN BEE STINGERS",
        BEESWAX = "THE BEES MADE IT",
		BEEHIVE = "HOW INDUSTRIOUS",
		BEEMINE = "IMPROVISED STINGING DEVICE",
		BEEMINE_MAXWELL = "AGGRESSIVE LIFEFORMS WITHIN",--removed
		BERRIES = "THEY REMIND ME OF BLOOD",
		BERRIES_COOKED = "THEY HAVE LOST STRUCTURAL INTEGRITY",
        BERRIES_JUICY = "THESE BIOSPHERES WILL ROT SOON",
        BERRIES_JUICY_COOKED = "SUCCULENT",
		BERRYBUSH =
		{
			BARREN = "THE SYSTEM IS DOWN",
			WITHERED = "THE SYSTEM HAS OVERHEATED",
			GENERIC = "PERIODIC CALORIE DISPENSER",
			PICKED = "IT IS REBOOTING",
			DISEASED = "HA. DISEASE. A BIOLOGICAL LAPSE IN JUDGMENT",--removed
			DISEASING = "THIS ORGANIC SEEMS MORE INFERIOR THAN USUAL",--removed
			BURNING = "ORGANICS ARE NOT FIREPROOF",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "REQUIRES BIOLOGICAL WASTE",
			WITHERED = "COOLANT REQUIRED",
			GENERIC = "BERRY PRODUCTION: OPTIMAL",
			PICKED = "IT'S COMPILING",
			DISEASED = "HA. DISEASE. A BIOLOGICAL LAPSE IN JUDGMENT",--removed
			DISEASING = "THIS ORGANIC SEEMS MORE INFERIOR THAN USUAL",--removed
			BURNING = "ORGANICS ARE NOT FIREPROOF",
		},
		BIGFOOT = "OVERSIZED FOOT. HIGHLY DANGEROUS",--removed
		BIRDCAGE =
		{
			GENERIC = "I WILL IMPRISON THE FLESHLINGS",
			OCCUPIED = "HA HA. THERE IS NO ESCAPE",
			SLEEPING = "WAKE UP, FLESHLING",
			HUNGRY = "FLESHLINGS ARE SO PICKY",
			STARVING = "WHAT? WHAT DO YOU WANT?",
			DEAD = "IT'S BROKEN",
			SKELETON = "IT MUST BE OUT OF BATTERIES",
		},
		BIRDTRAP = "STUPID BIRDS. HA.",
		CAVE_BANANA_BURNT = "HA HA, DESTROYED",
		BIRD_EGG = "I HATE YOU, EGG",
		BIRD_EGG_COOKED = "THIS IS SUPPOSED TO BE AN IMPROVEMENT",
		BISHOP = "REVEREND AUTOMATON",
		BLOWDART_FIRE = "A WEAPON OF MINOR DESTRUCTION",
		BLOWDART_SLEEP = "THESE CREATURES ARE SO MANIPULABLE",
		BLOWDART_PIPE = "ACCELERATES SHARP OBJECTS TO DANGEROUS SPEEDS",
		BLOWDART_YELLOW = "DEATH BY ROBO BREATH",
		BLUEAMULET = "THIS WILL MAKE A GREAT HEATSINK",
		BLUEGEM = "IT IS SLIGHTLY COLD",
		BLUEPRINT =
		{
            COMMON = "KNOWLEDGE WAITING TO BE ABSORBED",
            RARE = "DRIPPING WITH DELICIOUS KNOWLEDGE",
        },
        SKETCH = "USELESS PAPER FOR MAKING USELESS SCULPTURES",
		BLUE_CAP = "MEDICINAL FUNGUS",
		BLUE_CAP_COOKED = "MODIFIED FUNGUS",
		BLUE_MUSHROOM =
		{
			GENERIC = "BLUE FUNGUS",
			INGROUND = "IT IS HIDING",
			PICKED = "DESTROYED",
		},
		BOARDS = "THEY ARE FLATTER NOW",
		BONESHARD = "PIECES OF STRUCTURAL SUPPORT SYSTEM",
		BONESTEW = "NUTRITION ACQUIRED",
		BUGNET = "DEBUGGING IMPLEMENT",
		BUSHHAT = "HOW DEMEANING",
		BUTTER = "THIS IS IMPROBABLE",
		BUTTERFLY =
		{
			GENERIC = "IT THINKS IT IS SO PRETTY",
			HELD = "SQUISH",
		},
		BUTTERFLYMUFFIN = "THE INNOCENCE ADDS FLAVOR",
		BUTTERFLYWINGS = "IRIDESCENT",
		BUZZARD = "GARBAGE COLLECTOR LIFEFORM",

		SHADOWDIGGER = "HE'S GOT THEM DOING HIS BIDDING. I RESPECT THAT",

		CACTUS =
		{
			GENERIC = "PROTECTIVE BARRIER PRESENT. PROCEED WITH CAUTION",
			PICKED = "NO NUTRIENT-RICH MATERIAL REMAINING AT THIS TIME",
		},
		CACTUS_MEAT_COOKED = "PROTECTIVE BARRIER REMOVED",
		CACTUS_MEAT = "PROTECTIVE BARRIER REMAINS",
		CACTUS_FLOWER = "REASON FOR BARRIER",

		COLDFIRE =
		{
			EMBERS = "WARNING: FIRE LEVELS CRITICAL",
			GENERIC = "A TEMPORARY ENCAMPMENT",
			HIGH = "WARNING: FIRE IS RAMBUNCTIOUS",
			LOW = "WARNING: FIRE LEVELS LOW",
			NORMAL = "INVERTED FIRE. STRANGE",
			OUT = "NO FIRE DETECTED",
		},
		CAMPFIRE =
		{
			EMBERS = "WARNING: FIRE LEVELS CRITICAL",
			GENERIC = "A TEMPORARY ENCAMPMENT",
			HIGH = "WARNING: FIRE IS RAMBUNCTIOUS",
			LOW = "WARNING: FIRE LEVELS LOW",
			NORMAL = "IT REMINDS ME OF SOMETHING",
			OUT = "NO FIRE DETECTED",
		},
		CANE = "ASSISTED LOCOMOTION DEVICE",
		CATCOON = "CLAWS OUT",
		CATCOONDEN =
		{
			GENERIC = "LIFE LOOP ITERATING",
			EMPTY = "LIFE LOOP ENDED",
		},
		CATCOONHAT = "FURRY HEAD COVERING",
		COONTAIL = "TAIL ACQUIRED",
		CARROT = "NUTRITIOUS",
		CARROT_COOKED = "IT IS FLOPPY NOW",
		CARROT_PLANTED = "ROBOT NEEDS FOOD",
		CARROT_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
		CARTOGRAPHYDESK =
		{
			GENERIC = "DIRECTIONAL INFORMATION TRANSMITTER FOR FLESH SIDEKICKS",
			BURNING = "BAKING MAPS",
			BURNT = "MAPS BAKED",
		},
		WATERMELON_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
		CAVE_FERN = "YOUR CHARMS WILL NOT WORK ON ME, PLANT",
		CHARCOAL = "COMPRESSED DEAD MATTER. WHAT IS NOT TO LIKE?",
        CHESSPIECE_PAWN = "SUPERIOR ART DEPICTING A DISPOSABLE UNDERLING",
        CHESSPIECE_ROOK =
        {
            GENERIC = "WHY ARE HUMANS SO COMPELLED TO \"DECORATE\"?",
            STRUGGLE = "FIGURE BOOTING UP",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "A METICULOUSLY CRAFTED OBJECT OF OBSOLESCENCE",
            STRUGGLE = "FIGURE BOOTING UP",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "A USELESS HUNK OF ROCK WITH NO APPARENT FUNCTION",
            STRUGGLE = "FIGURE BOOTING UP",
        },
        CHESSPIECE_MUSE = "I DO NOT UNDERSTAND THE AESTHETIC APPEAL",
        CHESSPIECE_FORMAL = "WHY IS NO ONE ACKNOWLEDGING IT LOOKS LIKE THE FRAIL HUMAN",
        CHESSPIECE_HORNUCOPIA = "THIS PIECE IS FOR TORTURING HUNGRY FLESHLINGS",
        CHESSPIECE_PIPE = "IT HAS NO PERCEIVABLE PURPOSE",
        CHESSPIECE_DEERCLOPS = "ANOTHER ORGANIC I AM STRONGER THAN",
        CHESSPIECE_BEARGER = "IT IS MY DECORATION NOW",
        CHESSPIECE_MOOSEGOOSE =
        {
            "AN ORGANIC I VANQUISHED",
        },
        CHESSPIECE_DRAGONFLY = "A REMINDER OF THE TIME I WON",
		CHESSPIECE_MINOTAUR = "COLD AND HARD, AN IMPROVEMENT",
        CHESSPIECE_BUTTERFLY = "\"ART\" IS JUST RECREATING STUFF YOU SEE LYING AROUND",
        CHESSPIECE_ANCHOR = "AS HEAVY AS THE REAL THING, BUT LESS USEFUL",
        CHESSPIECE_MOON = "SOME ART IS OKAY",
        CHESSPIECE_CARRAT = "WHEN WILL ONE OF MY UNDERLINGS CARVE A STATUE OF ME?",
        CHESSPIECE_MALBATROSS = "HA! IT'S FUNNY BECAUSE IT IS DEAD NOW",
        CHESSPIECE_CRABKING = "I DON'T LIKE IT",
        CHESSPIECE_TOADSTOOL = "EXACTLY THE RIGHT AMOUNT OF FLESH",
        CHESSPIECE_STALKER = "A DEFLESHED FLESH SACK",
        CHESSPIECE_KLAUS = "IT HAS EVOLVED INTO ITS SUPERIOR STATIC FORM",
        CHESSPIECE_BEEQUEEN = "AS USELESS NOW AS IT WAS WHEN IT WAS MOVING",
        CHESSPIECE_ANTLION = "NO LONGER CURSED WITH FLESH",
        CHESSPIECE_BEEFALO = "AN IMPROVEMENT ON THE FLESHY ORIGINAL",
		CHESSPIECE_KITCOON = "THE URGE TO TOPPLE IT OVERWHELMS MY SYSTEMS",
		CHESSPIECE_CATCOON = "A CLEAR IMPROVEMENT OVER ITS FLESHY COUNTERPART",
        CHESSPIECE_GUARDIANPHASE3 = "WE WOULD HAVE BEEN UNSTOPPABLE. OH WELL",
        CHESSPIECE_EYEOFTERROR = "ORGANIC REDUCED TO MINERAL - TYPICAL.",
        CHESSPIECE_TWINSOFTERROR = "SIGH. I MISS THEM",

        CHESSJUNK1 = "EX-AUTOMATON",
        CHESSJUNK2 = "EX-AUTOMATON",
        CHESSJUNK3 = "EX-AUTOMATON",
		CHESTER = "THIS EXTERNAL STORAGE UNIT APPEARS TO BE SENTIENT",
		CHESTER_EYEBONE =
		{
			GENERIC = "IT IS THE DRM KEY FOR THE STORAGE UNIT",
			WAITING = "SLEEP MODE ACTIVE",
		},
		COOKEDMANDRAKE = "THAT'S WHAT YOU GET FOR BEING PATHETIC",
		COOKEDMEAT = "FIRE MAKES THINGS BETTER",
		COOKEDMONSTERMEAT = "IT IS STILL SOMEWHAT INCOMPATIBLE",
		COOKEDSMALLMEAT = "IT TASTES LIKE BURNT REVENGE",
		COOKPOT =
		{
			COOKING_LONG = "MORE TIME IS REQUIRED",
			COOKING_SHORT = "IT IS ALMOST COMPLETE",
			DONE = "THE COOKING PROCESS IS DONE",
			EMPTY = "TO REFINE MEATS AND VEGETABLES INTO MORE ROBUST FORMS",
			BURNT = "POT MALFUNCTIONING",
		},
		CORN = "SAY(CORNY_JOKE)",
		CORN_COOKED = "EMPTY CALORIES",
		CORN_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
        CANARY =
		{
			GENERIC = "ITS BRAIN IS PROBABLY BIGGER THAN THE OTHER FLESHLINGS'. HA HA",
			HELD = "I AM EXPONENTIALLY MORE INTELLIGENT THAN YOU",
		},
        CANARY_POISONED = "TRULY DISGUSTING",

		CRITTERLAB = "IT'S A MINION HOLE",
        CRITTER_GLOMLING = "YOU HAVE BEEN A LOYAL MINION, GLOMGLOM",
        CRITTER_DRAGONLING = "IT AMUSES ME",
		CRITTER_LAMB = "I AM ENTERTAINED BY THIS FOUL ORGANIC",
        CRITTER_PUPPY = "IT DISCHARGES REPULSIVE SURGES OF \"LOVE\"",
        CRITTER_KITTEN = "IT USES \"CUTENESS\" AS A WEAPON. RESPECTABLE",
        CRITTER_PERDLING = "...YOU MAY LIVE",
		CRITTER_LUNARMOTHLING = "IT HAS NO OFFENSIVE USAGE, YET I AM COMPELLED TO KEEP IT",

		CROW =
		{
			GENERIC = "IT IS SMARTER THAN MOST HUMANS",
			HELD = "NOT SO SMART NOW, ARE YOU?",
		},
		CUTGRASS = "PLANT MATTER",
		CUTREEDS = "HOLLOW PLANT MATTER",
		CUTSTONE = "IMPROVED ROCKS",
		DEADLYFEAST = "POISON DETECTED", --unimplemented
		DEER =
		{
			GENERIC = "ITS BRAIN MUST BE MINISCULE",
			ANTLER = "IT UPGRADED, BUT IT IS STILL INFERIOR",
		},
        DEER_ANTLER = "IT FELL RIGHT OFF. I DID NOTHING",
        DEER_GEMMED = "CHAINED. AS ALL ORGANICS SHOULD BE",
		DEERCLOPS = "DANGER! THREAT INCOMING!",
		DEERCLOPS_EYEBALL = "A GIANT ORGANIC LENS",
		EYEBRELLAHAT =	"EYE MATERIAL IS SURPRISINGLY ELASTIC",
		DEPLETED_GRASS =
		{
			GENERIC = "AN EXPIRED TUFT OF GRASS",
		},
        GOGGLESHAT = "IT SERVES NO ASCERTAINABLE PURPOSE",
        DESERTHAT = "KEEPS OPTICAL HOLES DUST-FREE",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "UNKNOWN PILE FORMAT",
		DIVININGROD =
		{
			COLD = "SIGNAL STRENGTH: LOW", --singleplayer
			GENERIC = "IT WANTS ITS MOTHER", --singleplayer
			HOT = "SIGNAL STRENGTH: EXTREMELY HIGH", --singleplayer
			WARM = "SIGNAL STRENGTH: MEDIUM", --singleplayer
			WARMER = "SIGNAL STRENGTH: HIGH", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "PURPOSE UNCLEAR", --singleplayer
			READY = "INPUT OF LARGE KEY WILL BRING ROD ONLINE", --singleplayer
			UNLOCKED = "ROD IS FULLY OPERATIONAL", --singleplayer
		},
		DIVININGRODSTART = "ROD COULD BE A USEFUL TOOL", --singleplayer
		DRAGONFLY = "HIGH TEMPERATURE RADIATING FROM FLY BEAST",
		ARMORDRAGONFLY = "SCALES FUNCTION SIMILARLY TO MINIATURE FLAMETHROWERS",
		DRAGON_SCALES = "FLAME-TREATED BODY PLATING",
		DRAGONFLYCHEST = "CAN HANDLE EXTREMELY HIGH TEMPERATURES",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "HA HA, FLESHLING! THIS TERRIBLE FACE RESEMBLES YOU",
			GENERIC = "WE GUTTED THE FLY BEAST AND TURNED IT INTO A MACHINE", --no gems
			NORMAL = "THE MACHINE WARMS MY CHASSIS", --one gem
			HIGH = "DO YOUR WORST. I AM INCAPABLE OF SWEATING", --two gems
		},

        HUTCH = "YOU ARE NOT CUTE",
        HUTCH_FISHBOWL =
        {
            GENERIC = "A USELESS HUMAN DISTRACTION",
            WAITING = "ONE FISH, TWO FISH. RED FISH, DEAD FISH",
        },
		LAVASPIT =
		{
			HOT = "SALIVA AT HAZARDOUS TEMPERATURE LEVELS",
			COOL = "SALIVA HAS COOLED AND IS APPROACHABLE",
		},
		LAVA_POND = "THE FOUL MAW CONSUMES FLESH AND STEEL ALIKE",
		LAVAE = "SMELLS LIKE BURNING",
		LAVAE_COCOON = "FRIENDSHIP PROTOCOL INITIATED",
		LAVAE_PET =
		{
			STARVING = "IT NEEDS FUEL",
			HUNGRY = "ITS FUEL RESERVES ARE LOW",
			CONTENT = "ALL CONDITIONS SEEM NORMAL",
			GENERIC = "IT SERVES ME",
		},
		LAVAE_EGG =
		{
			GENERIC = "CONTAINS PARTS TO BUILD ONE LAVAE",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "THE EGG IS TOO COLD",
			COMFY = "THE EGG IS DOING WELL",
		},
		LAVAE_TOOTH = "I GUESS IT DOESN'T NEED THAT PART",

		DRAGONFRUIT = "IT HAS HEALING PROPERTIES",
		DRAGONFRUIT_COOKED = "IT WILL SOON LOSE ITS CALORIC VALUE",
		DRAGONFRUIT_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
		DRAGONPIE = "SO MUCH CELLULOSE",
		DRUMSTICK = "LIVING THINGS ARE MADE OF FASCINATING PARTS",
		DRUMSTICK_COOKED = "A TASTE SENSATION",
		DUG_BERRYBUSH = "IT WOULD BE MORE USEFUL IN THE GROUND",
		DUG_BERRYBUSH_JUICY = "IT WOULD BE MORE USEFUL IN THE GROUND",
		DUG_GRASS = "IT WOULD BE MORE USEFUL IN THE GROUND",
		DUG_MARSH_BUSH = "IT WOULD BE MORE USEFUL IN THE GROUND",
		DUG_SAPLING = "IT WOULD BE MORE USEFUL IN THE GROUND",
		DURIAN = "GOOD THING I LACK A NOSE",
		DURIAN_COOKED = "STILL NOT GOOD",
		DURIAN_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
		EARMUFFSHAT = "GREAT FOR DROWNING OUT ORGANIC CHATTER",
		EGGPLANT = "IT HAS AN ILLOGICAL NAME",
		EGGPLANT_COOKED = "FANCY",
		EGGPLANT_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

		ENDTABLE =
		{
			BURNT = "CARBONIZED TRASHBITS",
			GENERIC = "MY UNDERLINGS LIKE IT, DESPITE THE LACK OF FUNCTION",
			EMPTY = "WHY DID WE MAKE THIS",
			WILTED = "EVEN THE SIMPLEST ORGANICS DIE",
			FRESHLIGHT = "MAXIMUM LIGHT OUTPUT",
			OLDLIGHT = "WARNING: POWER LOW", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "SOON THERE WILL BE NOTHING LEFT",
			BURNT = "YOU LOSE. GOOD.",
			CHOPPED = "THE NATURAL WORLD IS OVERRATED",
			POISON = "THE MONSTER WITHIN REARS ITS HEAD",
			GENERIC = "TARGET ACQUIRED",
		},
		ACORN = "HOW DOES THE TREE FIT IN THERE?",
        ACORN_SAPLING = "SOON THE TREE WILL GROW",
		ACORN_COOKED = "THE TREE HAS BEEN KILLED AND TURNED INTO NUTRIENTS",
		BIRCHNUTDRAKE = "ANOTHER HORRIBLE OFFERING OF THE NATURAL WORLD",
		EVERGREEN =
		{
			BURNING = "SOON THERE WILL BE NOTHING LEFT",
			BURNT = "OBLITERATED",
			CHOPPED = "THE NATURAL WORLD IS OVERRATED",
			GENERIC = "TARGET ACQUIRED",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "SOON THERE WILL BE NOTHING LEFT",
			BURNT = "OBLITERATED",
			CHOPPED = "THE NATURAL WORLD IS OVERRATED",
			GENERIC = "PATHETIC TREE DROPS NO BABIES",
		},
		TWIGGYTREE =
		{
			BURNING = "SOON THERE WILL BE NOTHING LEFT",
			BURNT = "YOU LOSE",
			CHOPPED = "THE NATURAL WORLD IS OVERRATED",
			GENERIC = "AN EVEN MORE PATHETIC TREE",
			DISEASED = "HA. DISEASE. A BIOLOGICAL LAPSE IN JUDGMENT", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "IT'S TAKING FOREVER TO GROW",
        TWIGGY_OLD = "PATHETIC",
		TWIGGY_NUT = "TWIGGY TREE SOURCE CODE",
		EYEPLANT = "EXTERNAL SIGHT MODULES",
		INSPECTSELF = "THERE IS A HANDSOME ROBOT TRAPPED IN THIS LOOK-DEVICE!",
		FARMPLOT =
		{
			GENERIC = "IT IS NOT CURRENTLY ACTIVE",
			GROWING = "LIFE IS INEFFICIENT",
			NEEDSFERTILIZER = "ITS RESOURCES ARE EXHAUSTED",
			BURNT = "PERMANENTLY DEACTIVATED",
		},
		FEATHERHAT = "STILL DOES NOT FLY",
		FEATHER_CROW = "IT HAS BEEN SEPARATED FROM ITS BIRD",
		FEATHER_ROBIN = "THE FLIMSY OUTER COVERING OF A PATHETIC BIRD",
		FEATHER_ROBIN_WINTER = "ANOTHER FEATHERSACK HAS FALLEN TO PIECES",
		FEATHER_CANARY = "FOUL ORGANICS LEAVE THEIR PIECES EVERYWHERE",
		FEATHERPENCIL = "WHY IS THE FEATHER SO APPEALING? EXPLAIN NOW, FLESHLINGS",
        COOKBOOK = "DIRECTORY OF INGESTIBLE ORGANIC MATTER COMBINATIONS",
		FEM_PUPPET = "SHE APPEARS TO BE TRAPPED", --single player
		FIREFLIES =
		{
			GENERIC = "BIOLUMINESCENT INSECTS",
			HELD = "THEY ARE VERY LIGHT",
		},
		FIREHOUND = "IT LIVES TO BURN",
		FIREPIT =
		{
			EMBERS = "WARNING: FIRE LEVELS CRITICAL",
			GENERIC = "A TEMPORARY ENCAMPMENT",
			HIGH = "WARNING: FIRE IS RAMBUNCTIOUS",
			LOW = "WARNING: FIRE LEVELS LOW",
			NORMAL = "IT REMINDS ME OF SOMETHING",
			OUT = "NO FIRE DETECTED",
		},
		COLDFIREPIT =
		{
			EMBERS = "WARNING: FIRE LEVELS CRITICAL",
			GENERIC = "COLD AND LIGHT",
			HIGH = "WARNING: FIRE LEVELS EXCEED DESIGN PARAMETERS",
			LOW = "WARNING: FIRE LEVELS LOW",
			NORMAL = "THIS ENDOTHERMIC FIRE IS FULLY OPERATIONAL",
			OUT = "IT NEEDS TO BE REBOOTED",
		},
		FIRESTAFF = "THIS STAFF HAS BEEN OPTIMIZED FOR COMBUSTION",
		FIRESUPPRESSOR =
		{
			ON = "FRIEND IS WHIRRING",
			OFF = "QUIET FRIEND",
			LOWFUEL = "FRIEND NEEDS FOOD BADLY",
		},

		FISH = "IT'S TO SCALE",
		FISHINGROD = "I DO NOT LIKE WATER",
		FISHSTICKS = "FISH FLAVORED ENERGY RODS",
		FISHTACOS = "THE FISH HAVE FULFILLED THEIR HIGHER PURPOSE",
		FISH_COOKED = "MISSING ADDON... CHIPS",
		FLINT = "THIS ROCK IS SHARPER THAN MOST",
		FLOWER =
		{
            GENERIC = "MY APPRECIATION FOR BEAUTY IS LIMITED",
            ROSE = "A REVOLTING SYMBOL OF HUMAN LOVE",
        },
        FLOWER_WITHERED = "HAHAHA DIE DIE DIE DIE",
		FLOWERHAT = "AT LEAST THEY ARE DEAD",
		FLOWER_EVIL = "HEY THERE, FLOWERS. WANNA... KILL ALL HUMANS?",
		FOLIAGE = "A LIFE HAS ENDED. YAY.",
		FOOTBALLHAT = "PADDING FOR MY PROCESSING UNIT",
        FOSSIL_PIECE = "PURPOSE: ORGANIC STRUCTURAL INTEGRITY",
        FOSSIL_STALKER =
        {
			GENERIC = "SOME ASSEMBLY REQUIRED",
			FUNNY = "I DO NOT KNOW HOW ORGANICS FIT TOGETHER",
			COMPLETE = "THAT LOOKS SERVICEABLE",
        },
        STALKER = "YOU WILL BE DESTROYED",
        STALKER_ATRIUM = "I WILL DESTROY YOU",
        STALKER_MINION = "ITS MINIONS ARE INFERIOR",
        THURIBLE = "IT IS BAIT FOR A DUMB BEAST",
        ATRIUM_OVERGROWTH = "DECODING FAILED",
		FROG =
		{
			DEAD = "CONGRATULATIONS. YOU DID TERRIBLY",
			GENERIC = "POTENTIAL BUNWICH",
			SLEEPING = "YOU WILL BE HARVESTED",
		},
		FROGGLEBUNWICH = "DELICIOUS FROG FUEL",
		FROGLEGS = "REPLACEMENT PARTS FOR FROGS",
		FROGLEGS_COOKED = "THEY ARE MORE NUTRITIOUS NOW",
		FRUITMEDLEY = "ENERGY IN A CUP",
		FURTUFT = "UNPLEASANTLY FUZZY",
		GEARS = "GUTS",
		GHOST = "ERROR: UNKNOWN",
		GOLDENAXE = "GOLD AXE IS *MORE* DURABLE?",
		GOLDENPICKAXE = "GOLD PICK IS *MORE* DURABLE?",
		GOLDENPITCHFORK = "GOLD IS *MORE* DURABLE?",
		GOLDENSHOVEL = "GOLD SHOVEL IS *MORE* DURABLE?",
		GOLDNUGGET = "I APPRECIATE ITS CONDUCTIVITY",
		GRASS =
		{
			BARREN = "FERTILIZATION REQUIRED",
			WITHERED = "NEEDS IMPROVED COOLING SYSTEM",
			BURNING = "OOPS",
			GENERIC = "IT LOOKS COMBUSTIBLE",
			PICKED = "IT WILL RETURN SOON",
			DISEASED = "HA. DISEASE. A BIOLOGICAL LAPSE IN JUDGMENT", --unimplemented
			DISEASING = "THIS ORGANIC SEEMS MORE INFERIOR THAN USUAL", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "MUCH MORE FUN THAN PICKING GRASS",
			DISEASED = "I'M IMMUNE TO PATHOGENS. HA HA", --unimplemented
		},
		GREEN_CAP = "CULINARY FUNGUS",
		GREEN_CAP_COOKED = "MODIFIED FUNGUS",
		GREEN_MUSHROOM =
		{
			GENERIC = "GREEN FUNGUS",
			INGROUND = "IT IS HIDING",
			PICKED = "DESTROYED.",
		},
		GUNPOWDER = "PUTS THE \"POW\" IN \"POWDER\"",
		HAMBAT = "TASTE IRONY AND DIE, FLESHLINGS",
		HAMMER = "DECONSTRUCTION",
		HEALINGSALVE = "KILL MICROLIFE TO SAVE MACROLIFE",
		HEATROCK =
		{
			FROZEN = "TEMPERATURE MINIMAL",
			COLD = "TEMPERATURE SLIGHTLY BELOW NORMAL",
			GENERIC = "A DECEPTIVELY SIMPLE DEVICE",
			WARM = "MINOR THERMAL ACTIVITY DETECTED",
			HOT = "TEMPERATURE MAXIMAL",
		},
		HOME = "WHO WROTE THAT?",
		HOMESIGN =
		{
			GENERIC = "\"YOU ARE HERE\"",
            UNWRITTEN = "INPUT REQUIRED",
			BURNT = "YOU ARE BURNT",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "\"THATAWAY\"",
            UNWRITTEN = "INPUT REQUIRED",
			BURNT = "BURNT AWAY",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "\"THATAWAY\"",
            UNWRITTEN = "INPUT REQUIRED",
			BURNT = "BURNT AWAY",
		},
		HONEY = "IT IS A GOOD LUBRICANT FOR MY GEARS",
		HONEYCOMB = "ONE UNIT OF BEE STORAGE",
		HONEYHAM = "HIGH QUALITY BIOFUEL DETECTED",
		HONEYNUGGETS = "PLEASE INSERT INTO MOUTH",
		HORN = "UNHYGIENIC",
		HOUND = "IT LIVES TO EAT",
		HOUNDCORPSE =
		{
			GENERIC = "DISGUSTING",
			BURNING = "THE BEST WAY TO DISPOSE OF ORGANICS",
			REVIVING = "IT IS REACHING LEVELS OF REPULSIVITY NEVER THOUGHT POSSIBLE",
		},
		HOUNDBONE = "EXOSKELETON FOR INSIDES. PROVIDES STRUCTURAL INTEGRITY",
		HOUNDMOUND = "SOMETHING DANGEROUS RESIDES HERE",
		ICEBOX = "CARRY ON, MY FRIGID BROTHER",
		ICEHAT = "WARNING: MEMORY LEAK",
		ICEHOUND = "IT LIVES TO FREEZE",
		INSANITYROCK =
		{
			ACTIVE = "MY MAPPING MODULE SHOWS NO RECORD OF THIS OBSTRUCTION",
			INACTIVE = "IT APPEARS TO BE MOSTLY UNDERGROUND",
		},
		JAMMYPRESERVES = "THERE'S JAM IN MY CIRCUITRY",

		KABOBS = "SHOVE MEAT ON STICK. SHOVE STICK IN FACE",
		KILLERBEE =
		{
			GENERIC = "IT HAS A STINGER AND A BAD ATTITUDE",
			HELD = "WARNING: KILLER BEE IN POCKET",
		},
		KNIGHT = "HORSE AUTOMATON",
		KOALEFANT_SUMMER = "POSSESSES AMPLE ENERGY RESERVES",
		KOALEFANT_WINTER = "IT RADIATES WITH MEAT WARMTH",
		KRAMPUS = "STOP! THIEF!",
		KRAMPUS_SACK = "STORAGE MODULE 2.0",
		LEIF = "WARNING: MOBILE TREE",
		LEIF_SPARSE = "WARNING: MOBILE TREE",
		LIGHTER  = "MY BRETHREN",
		LIGHTNING_ROD =
		{
			CHARGED = "BACKUP POWER",
			GENERIC = "SURGE PROTECTION",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "DOES IT HAVE MECHANICAL INSIDES?",
			CHARGED = "CHARGE IS INSUFFICIENT TO POWER OVERLOAD",
		},
		LIGHTNINGGOATHORN = "THIS IS A GOOD HORN",
		GOATMILK = "EXCITED MILK",
		LITTLE_WALRUS = "PATHETIC",
		LIVINGLOG = "EVEN WORSE THAN A NORMAL LOG",
		LOG =
		{
			BURNING = "IT IS AFLAME",
			GENERIC = "LOG(1) = 0",
		},
		LUCY = "GET IT AWAY",
		LUREPLANT = "AWW, IT'S JUST AS EVIL AS I AM",
		LUREPLANTBULB = "THE POWER TO START LIFE",
		MALE_PUPPET = "HE APPEARS TO BE TRAPPED", --single player

		MANDRAKE_ACTIVE = "WHAT DO YOU WANT!?",
		MANDRAKE_PLANTED = "IT IS A PLANT",
		MANDRAKE = "IT'S DEAD. GOOD",

        MANDRAKESOUP = "TARGET DESTROYED. HA HA",
        MANDRAKE_COOKED = "IT'S TWICE AS DEAD. HA",
        MAPSCROLL = "CAN'T SCROLL",
        MARBLE = "I SHOULD MAKE THE FLESHLINGS BUILD A STATUE OF ME",
        MARBLEBEAN = "INFURIATINGLY ILLOGICAL",
        MARBLEBEAN_SAPLING = "IS IT ORGANIC OR INORGANIC?",
        MARBLESHRUB = "INFERIORITY ASSESSMENT: INCONCLUSIVE",
        MARBLEPILLAR = "CRUMBLING REMAINS. HAH",
        MARBLETREE = "LOOKS LIKE A VERY TOUGH TREE",
        MARSH_BUSH =
        {
			BURNT = "THORNS. BURNT",
            BURNING = "THORNS_FLAMMABLE == YES VERY",
            GENERIC = "BRAMBLES",
            PICKED = "BRAMBLES FIGHT BACK",
        },
        BURNT_MARSH_BUSH = "BURNED",
        MARSH_PLANT = "IT IS AN UNINTERESTING PLANT",
        MARSH_TREE =
        {
            BURNING = "SPIKY TREE IGNITED",
            BURNT = "THE SPIKY TREE IS NO MORE",
            CHOPPED = "SPIKY TREE DEFEATED",
            GENERIC = "A SPIKY TREE",
        },
        MAXWELL = "HE IS AN UNKNOWN",--single player
        MAXWELLHEAD = "IT APPEARS TO BE SOME SORT OF PROJECTION",--removed
        MAXWELLLIGHT = "THEY SENSE MY PRESENCE",--single player
        MAXWELLLOCK = "KEY RECEPTACLE",--single player
        MAXWELLTHRONE = "MADE FOR SITTING",--single player
        MEAT = "A PIECE OF A MEATLING",
        MEATBALLS = "MEAT PACKED INTO THE MOST NUTRITIOUS SHAPE: SPHERES",
        MEATRACK =
        {
            DONE = "PROTEIN DEHYDRATION COMPLETE",
            DRYING = "MEATSACKS TAKE TIME TO DRY",
            DRYINGINRAIN = "MEATSACKS WILL NOT DRY IN RAIN",
            GENERIC = "I COULD HANG EXPIRED MEATSACKS HERE",
            BURNT = "MEATSACK MASS IS TOO HIGH FOR DETERIORATED RACK",
            DONE_NOTMEAT = "DEHYDRATION COMPLETE",
            DRYING_NOTMEAT = "WETNESS IS TRULY THE WORST",
            DRYINGINRAIN_NOTMEAT = "STOP MAKING MY THINGS WET, RAIN",
        },
        MEAT_DRIED = "DEHYDRATED PROTEINS",
        MERM = "ANIMATED SEAFOOD",
        MERMHEAD =
        {
            GENERIC = "THE FISHBEAST IS MORE IDIOTIC LOOKING THAN USUAL",
            BURNT = "TRIAL BY FIRE",
        },
        MERMHOUSE =
        {
            GENERIC = "OUTDATED ABODE",
            BURNT = "DILAPIDATED ABODE",
        },
        MINERHAT = "SUPPORTS HANDS-FREE OPERATION",
        MONKEY = "AN EVEN DUMBER HUMANOID",
        MONKEYBARREL = "WHAT A PITIFUL HOME",
        MONSTERLASAGNA = "DIRTY ENERGY",
        FLOWERSALAD = "SO MUCH CELLULOSE",
        ICECREAM = "SWEET DAIRY",
        WATERMELONICLE = "WATERMELON ON ICE",
        TRAILMIX = "HIGHLY NUTRITIONAL",
        HOTCHILI = "SPICE MAGNITUDE EXTREMELY HIGH",
        GUACAMOLE = "CRUSHED MOLES. GREEN",
        MONSTERMEAT = "IT IS INCOMPATIBLE WITH MY CHEMICAL ENGINE",
        MONSTERMEAT_DRIED = "VILE DEHYDRATED PROTEINS",
        MOOSE = "ANALYSIS RESULTS UNCERTAIN",
        MOOSE_NESTING_GROUND = "ORGANIC SPAWNPOINT",
        MOOSEEGG = "PROBES UNABLE TO PENETRATE EXTERIOR SHELL",
        MOSSLING = "OFFSPRING OF UNCERTAIN MAKEUP",
        FEATHERFAN = "EXCELLENT COOLING SYSTEM",
        MINIFAN = "DEFIES CONSERVATION OF ENERGY",
        GOOSE_FEATHER = "FEATHERS FROM STRANGE LIFEFORMS",
        STAFF_TORNADO = "TREACHEROUSLY POWERFUL GUSTS",
        MOSQUITO =
        {
            GENERIC = "IT ENJOYS DRAINING THE LIFE FROM ORGANICS. DITTO",
            HELD = "FILLED WITH DISGUSTING FLUIDS",
        },
        MOSQUITOSACK = "MOSQUITO HARD DRIVE",
        MOUND =
        {
            DUG = "WORMS AND ICHOR",
            GENERIC = "MEATLINGS ARE SO SUPERSTITIOUS",
        },
        NIGHTLIGHT = "UNKNOWN LIGHT SOURCE",
        NIGHTMAREFUEL = "DEBUGGING RESIDUE",
        NIGHTSWORD = "HACK THE PLANET",
        NITRE = "SOME ROCKS ARE BETTER THAN OTHERS",
        ONEMANBAND = "AN EXTERNAL SOUND MODULE UPGRADE",
        OASISLAKE =
		{
			GENERIC = "EVEN DESERTS ARE NOT SAFE FROM WATER",
			EMPTY = "DRY LAKES ARE FAR SUPERIOR TO WET ONES",
		},
        PANDORASCHEST = "CONTENT PROBABILITIES ARE UNCERTAIN",
        PANFLUTE = "HARD RESET FOR FLESHLINGS",
        PAPYRUS = "I PREFER DOT MATRIX PAPER",
        WAXPAPER = "ENVIABLY WATERPROOF",
        PENGUIN = "FAT PATHETIC BIRD CANNOT FLY",
        PERD = "THAT IS AN UNUSUALLY LARGE BIRD",
        PEROGIES = "LIKE MEATY BATTERY PACKS",
        PETALS = "SOMETHING BEAUTIFUL HAS BEEN DESTROYED. HA",
        PETALS_EVIL = "IT WAS UGLY, BUT IT'S BEEN DESTROYED. HA",
        PHLEGM = "FILTHY OOZE FROM A FILTHY ANIMAL",
        PICKAXE = "MINING IMPLEMENT DETECTED",
        PIGGYBACK = "UPGRADED STORAGE MODULE V2.0",
        PIGHEAD =
        {
            GENERIC = "THAT PIG WILL FEEL SILLY WHEN HE NOTICES HE HAS LOST HIS HEAD MODULE",
            BURNT = "HEAD MODULE EXPIRED",
        },
        PIGHOUSE =
        {
            FULL = "OCCUPIED",
            GENERIC = "THE FURNITURE IS ALL PIG-SHAPED",
            LIGHTSOUT = "THE OCCUPANT MUST BE SLEEPING",
            BURNT = "DEFUNCT",
        },
        PIGKING = "THAT APPEARS TO BE THE DOMINANT PIG",
        PIGMAN =
        {
            DEAD = "ONE MEATLING DOWN, 8 BILLION TO GO",
            FOLLOWER = "DO MY BIDDING",
            GENERIC = "THEY EXHIBIT MINIMAL INTELLIGENCE",
            GUARD = "DEFENSIVE STANCE DETECTED",
            WEREPIG = "ERROR: ANOMALY!",
        },
        PIGSKIN = "THESE FLESHLINGS ARE DISGUSTING",
        PIGTENT = "TENT",
        PIGTORCH = "IT GIVES HIM PURPOSE",
        PINECONE = "A PORTABLE FIBONACCI SEQUENCER",
        PINECONE_SAPLING = "SOON THE TREE WILL GROW",
        LUMPY_SAPLING = "WHY DO THEY KEEP REPRODUCING?",
        PITCHFORK = "I ENJOY ITS POINTY PARTS",
        PLANTMEAT = "A SURPRISINGLY HIGH AMOUNT OF PROTEIN",
        PLANTMEAT_COOKED = "A SIGNIFICANT IMPROVEMENT",
        PLANT_NORMAL =
        {
            GENERIC = "IT LOOKS EDIBLE",
            GROWING = "GO FASTER, PLANT",
            READY = "IT IS AT PEAK NUTRITIONAL VALUE",
            WITHERED = "CLIMATE INHOSPITABLE TO PLANT GROWTH",
        },
        POMEGRANATE = "IT IS DIFFICULT TO PEEL",
        POMEGRANATE_COOKED = "DELECTABLE",
        POMEGRANATE_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
        POND = "ERROR. STAY AWAY",
        POOP = "THESE ANIMALS ARE DISGUSTING",
        FERTILIZER = "BUCKET OF ANIMAL WASTE",
        PUMPKIN = "IT HAS A PLEASING SHAPE",
        PUMPKINCOOKIE = "WHAT WAS THE POINT OF THAT",
        PUMPKIN_COOKED = "DELICIOUS",
        PUMPKIN_LANTERN = "IT HAS AN EERIE LIGHT",
        PUMPKIN_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",
        PURPLEAMULET = "THE PERFECT AMULET",
        PURPLEGEM = "IT IS STRANGE",
        RABBIT =
        {
            GENERIC = "IT IS PERFORMING A SEARCH ALGORITHM",
            HELD = "I HOLD ITS TINY LIFE IN MY HANDS",
        },
        RABBITHOLE =
        {
            GENERIC = "THEY ARE ALL CONNECTED VIA UNDERGROUND TUNNELS",
            SPRING = "UNDERGROUND TUNNEL NETWORK HAS COLLAPSED",
        },
        RAINOMETER =
        {
            GENERIC = "WELCOME, BROTHER",
            BURNT = "YOU ARE MISSED, BROTHER",
        },
        RAINCOAT = "PERFECT PROTECTION AT THE COST OF AN INCOMPLETE CIRCUIT",
        RAINHAT = "INSULATED PROTECTION FROM WATER DAMAGE",
        RATATOUILLE = "SUSTENANCE IDENTIFIED",
        RAZOR = "EXFOLIATE!",
        REDGEM = "IT IS SLIGHTLY WARM",
        RED_CAP = "POISONOUS FUNGUS",
        RED_CAP_COOKED = "MODIFIED FUNGUS",
        RED_MUSHROOM =
        {
            GENERIC = "RED FUNGUS",
            INGROUND = "IT IS HIDING",
            PICKED = "DESTROYED",
        },
        REEDS =
        {
            BURNING = "TOO HOT",
            GENERIC = "USEFUL MATERIALS DETECTED",
            PICKED = "REGROWTH REQUIRED",
        },
        RELIC = "I HAVE NO NEED OF THAT",
        RUINS_RUBBLE = "REQUIRES RECONDITIONING",
        RUBBLE = "A DISMANTLED RELIC",
        RESEARCHLAB =
        {
            GENERIC = "MOTHER?",
            BURNT = "MOTHER, NO!",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "HELLO, FRIEND",
            BURNT = "GOODBYE, FRIEND",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "PERHAPS IT IS TOO POWERFUL",
            BURNT = "IT HAS LOST ITS POWER",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "WITH THIS EXTRA POWER I HAVE... MORE POWER!",
            BURNT = "I HAVE LOST MY ADDITIONAL POWER",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "MODELLED AFTER THE MEATBRAINED SCIENCE FLESHLING",
            BURNT = "HE'S DEAD",
        },
        RESURRECTIONSTONE = "DO YOU BELIEVE IN MAGIC?",
        ROBIN =
        {
            GENERIC = "GREETINGS, RED BIRD",
            HELD = "SQUASH!",
        },
        ROBIN_WINTER =
        {
            GENERIC = "A FOOLISH BIRD",
            HELD = "JUST A FEATHERY BLOB",
        },
        ROBOT_PUPPET = "BROTHER! WHAT HAVE THEY DONE TO YOU?", --single player
        ROCK_LIGHT =
        {
            GENERIC = "A PIT OF CRUSTED LAVA",--removed
            OUT = "IT NEEDS TO BE REBOOTED",--removed
            LOW = "WARNING: LAVA LEVEL LOW",--removed
            NORMAL = "THIS LAVA PIT IS FULLY OPERATIONAL",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "I WILL DESTROY YOU, BOULDER",
            RAISED = "THIS BOULDER EVADES DESTRUCTION",
        },
        ROCK = "LUMPY",
        PETRIFIED_TREE = "LESS ORGANIC. IT'S AN IMPROVEMENT",
        ROCK_PETRIFIED_TREE = "LESS ORGANIC. IT'S AN IMPROVEMENT",
        ROCK_PETRIFIED_TREE_OLD = "LESS ORGANIC. IT'S AN IMPROVEMENT",
        ROCK_ICE =
        {
            GENERIC = "REQUIRES AN ICEBREAKER",
            MELTED = "USELESS CONFIGURATION OF WATER",
        },
        ROCK_ICE_MELTED = "USELESS CONFIGURATION OF WATER ROCK",
        ICE = "AT LEAST IT IS SOLID WATER",
        ROCKS = "FOR REFINING INTO HIGH TECHNOLOGY",
        ROOK = "ROOK AUTOMATON",
        ROPE = "IT IS LESS USEFUL THAN IT APPEARS",
        ROTTENEGG = "I AM GLAD I CANNOT SMELL",
        ROYAL_JELLY = "I WILL HAVE THE POWER OF BEES",
        JELLYBEAN = "TEMPORARY UPGRADE COMPONENTS",
        SADDLE_BASIC = "SELF ESTEEM RISING",
        SADDLE_RACE = "DOZENS OF CREATURES WERE MAIMED FOR THIS. HA HA",
        SADDLE_WAR = "DOMINATE ALL CREATURES",
        SADDLEHORN = "HA HA, IT SHALL BE NAKED",
        SALTLICK = "FLESHLINGS RUB THEIR FILTHY TONGUE-STUMPS ON IT",
        BRUSH = "HAIR IS AN EXTRANEOUS ADDON",
		SANITYROCK =
		{
			ACTIVE = "IT IS CARVED WITH PERFECTION",
			INACTIVE = "SEEMS SMALLER THAN PREVIOUS DATA INDICATES",
		},
		SAPLING =
		{
			BURNING = "RESOURCES WASTED",
			WITHERED = "TEMPERATURE IS OVER RECOMMENDED LEVELS",
			GENERIC = "POTENTIAL CONSTRUCTION MATERIAL",
			PICKED = "IT IS RECHARGING",
			DISEASED = "HA. DISEASE. A BIOLOGICAL LAPSE IN JUDGMENT", --removed
			DISEASING = "THIS ORGANIC SEEMS MORE INFERIOR THAN USUAL", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "THIS STRAW ROBOT IS TERRIBLE",
			BURNING = "YES, BURN",
			BURNT = "YOU GOT WHAT YOU DESERVED, FAKE ROBOT",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "STONE IS SLIGHTLY LESS INFERIOR THAN FLESH",
			BLOCK = "POTENTIAL INCALCULABLE: SHUTTING DOWN",
			SCULPTURE = "IT COULD BE... WORSE",
			BURNT = "DESTRUCTION IS ITS OWN ART",
   		},
        SCULPTURE_KNIGHTHEAD = "MENIAL LABOR IS WHAT FLESHLINGS ARE FOR",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "DUMB ORGANIC ORNAMENT",
			UNCOVERED = "SOME ASSEMBLY REQUIRED",
			FINISHED = "</HEAD>",
			READY = "FREE HIM!!",
		},
        SCULPTURE_BISHOPHEAD = "MAKE THE VIKING FLESHLING CARRY IT",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "THE PURPOSE OF BEAUTY STILL ELUDES ME",
			UNCOVERED = "DETACHED HEADS UPSET THE FLESHLINGS. HA HA",
			FINISHED = "STILL NOT ONLINE",
			READY = "FREE HIM!!",
		},
        SCULPTURE_ROOKNOSE = "DON'T MAKE ME CARRY THAT",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "USELESS RUBBLE",
			UNCOVERED = "PATTERN RECOGNITION: FAILED",
			FINISHED = "INSTALLATION COMPLETE",
			READY = "FREE HIM!!",
		},
        GARGOYLE_HOUND = "A MAJOR IMPROVEMENT",
        GARGOYLE_WEREPIG = "IT IS BETTER THIS WAY",
		SEEDS = "IT'S LIKE SOURCE CODE FOR PLANTS",
		SEEDS_COOKED = "THEY CAN NO LONGER GERMINATE",
		SEWING_KIT = "IT JOINS COMPONENTS OF FIBRE TOGETHER",
		SEWING_TAPE = "TEMPORARY FIX FACILITATOR",
		SHOVEL = "IT HAS MANY USES. DIGGING, MOSTLY",
		SILK = "SPIDER INNARDS",
		SKELETON = "HAH, IT DIED. CLASSIC HUMAN MISTAKE",
		SCORCHED_SKELETON = "THE FLESHLING FRIED ITS CIRCUITS",
		SKULLCHEST = "THIS MAKES ME LAUGH", --removed
		SMALLBIRD =
		{
			GENERIC = "IT LOOKS PATHETIC",
			HUNGRY = "IT REQUIRES INPUT",
			STARVING = "IT IS ALMOST OUT OF FUEL",
			SLEEPING = "IT IS RECHARGING",
		},
		SMALLMEAT = "IT TASTES LIKE REVENGE",
		SMALLMEAT_DRIED = "DEHYDRATED PROTEINS",
		SPAT = "AT LEAST IT HAS METAL COVERING IT",
		SPEAR = "BRING IT, FLESHLINGS",
		SPEAR_WATHGRITHR = "A PRIMITIVE KINETIC WEAPON",
		WATHGRITHRHAT = "DUMB HAT",
		SPIDER =
		{
			DEAD = "CONGRATULATIONS. YOU DID TERRIBLY",
			GENERIC = "THREAT DETECTED",
			SLEEPING = "IT IS VULNERABLE",
		},
		SPIDERDEN = "SPIDER SOURCE DETECTED",
		SPIDEREGGSACK = "SPIDER POTENTIAL = 6",
		SPIDERGLAND = "SPARE SPIDER PARTS",
		SPIDERHAT = "IT WIRELESSLY TRANSMITS THOUGHTS TO SPIDERS",
		SPIDERQUEEN = "THE SPIDERS LIVE UNDER A SYSTEM OF MONARCHY",
		SPIDER_WARRIOR =
		{
			DEAD = "CONGRATULATIONS. YOU DID TERRIBLY",
			GENERIC = "HEIGHTENED THREAT DETECTED",
			SLEEPING = "THREAT SUSPENDED",
		},
		SPOILED_FOOD = "EVEN I CANNOT PROCESS THAT",
        STAGEHAND =
        {
			AWAKE = "FIVE DIGITS OF TERROR",
			HIDING = "IT'S HORRIBLE, I HATE IT",
        },
        STATUE_MARBLE =
        {
            GENERIC = "MARBLE, NOT METAL. INFERIOR",
            TYPE1 = "THE MASK IS THE ONLY GOOD PART OF IT",
            TYPE2 = "FLESHLINGS HAVE TOO MUCH TIME ON THEIR HANDS",
            TYPE3 = "HOW INCREDIBLY USELESS", --bird bath type statue
        },
		STATUEHARP = "SOMEONE FORGOT TO INSTALL THE HEAD MODULE",
		STATUEMAXWELL = "ALL THAT POWER AND HE COULDN'T EVEN DESTROY HUMANITY",
		STEELWOOL = "METALLIC ORGANIC FIBRE. DOES NOT COMPUTE",
		STINGER = "WARNING: TOXINS PRESENT",
		STRAWHAT = "THIS WILL COVER MY PROCESSING UNIT",
		STUFFEDEGGPLANT = "MUST STUFF INTO FOOD RECEPTACLES",
		SWEATERVEST = "VEST HAS HIGH DAPPERNESS QUOTIENT",
		REFLECTIVEVEST = "PREVENTS INTERNAL SYSTEMS FROM REACHING HAZARDOUS TEMPERATURES",
		HAWAIIANSHIRT = "ROBOTS HAVE CASUAL DRESS EVERY DAY",
		TAFFY = "STICKY AND SWEET. LOW NUTRITIONAL VALUE DETECTED",
		TALLBIRD = "IT LOOKS TERRITORIAL",
		TALLBIRDEGG = "IS IT STILL ALIVE?",
		TALLBIRDEGG_COOKED = "IT IS NO LONGER ALIVE",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "IT REQUIRES WARMTH",
			GENERIC = "CRACK DETECTED",
			HOT = "IT CAN NOT VENT EXCESS HEAT",
			LONG = "LIFE IS AN ANNOYINGLY SLOW PROCESS",
			SHORT = "SOMETHING IS EMERGING",
		},
		TALLBIRDNEST =
		{
			GENERIC = "I WANT THAT HORRIBLE EGG",
			PICKED = "IT IS EMPTY",
		},
		TEENBIRD =
		{
			GENERIC = "ANGST DETECTED",
			HUNGRY = "IT NEEDS FOOD",
			STARVING = "IT IS STARTING TO BEHAVE IRRATIONALLY",
			SLEEPING = "IT IS IN A DORMANT STATE",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "SOON I WILL BE FREE OF THIS FILTHY REALM", --single player
			GENERIC = "WHAT PRIMITIVE TECHNOLOGY", --single player
			LOCKED = "SOMETHING IS MISSING STILL", --single player
			PARTIAL = "I AM CERTAIN THIS WILL WORK", --single player
		},
		TELEPORTATO_BOX = "THAT WOULD PROBABLY BLOW MY CIRCUITS", --single player
		TELEPORTATO_CRANK = "I'M MADE OF TOUGHER STUFF", --single player
		TELEPORTATO_POTATO = "REMINDS ME OF MY MOTHER", --single player
		TELEPORTATO_RING = "HOW DELIGHTFULLY INORGANIC", --single player
		TELESTAFF = "I WILL CALL IT THE MINION_MOVER_3000",
		TENT =
		{
			GENERIC = "I CAN REBOOT IN THERE",
			BURNT = "UNSATISFACTORY CONDITIONS FOR REBOOT",
		},
		SIESTAHUT =
		{
			GENERIC = "I CAN HIBERNATE MY SESSION IN THERE",
			BURNT = "UNSATISFACTORY CONDITIONS FOR HIBERNATE MODE",
		},
		TENTACLE = "BIOLOGY IS DISGUSTING",
		TENTACLESPIKE = "THIS IS VICIOUSLY VISCOUS",
		TENTACLESPOTS = "NOT FOR THE SQUEAMISH",
		TENTACLE_PILLAR = "DOES NOT LOOK BETTER FROM THIS END",
        TENTACLE_PILLAR_HOLE = "I DETECT MASSIVE BIOMASS BELOW",
		TENTACLE_PILLAR_ARM = "DANGER! DANGER!",
		TENTACLE_GARDEN = "SENSORS DETECT SOMETHING BENEATH",
		TOPHAT = "SOPHISTICATED",
		TORCH = "PRIMITIVE LIGHT SOURCE",
		TRANSISTOR = "GREETINGS, SISTER",
		TRAP = "EXPERTLY WOVEN PLANT BITS",
		TRAP_TEETH = "THIS WILL PUNCTURE THE ENEMIES' FEET",
		TRAP_TEETH_MAXWELL = "TECHNOLOGY TURNED AGAINST ME", --single player
		TREASURECHEST =
		{
			GENERIC = "EXTERNAL STORAGE UNIT",
			BURNT = "STORAGE SIZE REDUCED TO ZERO",
		},
		TREASURECHEST_TRAP = "SOMEONE LEFT THEIR VALUABLES UNGUARDED",
		SACRED_CHEST =
		{
			GENERIC = "CURSE REPOSITORY",
			LOCKED = "I WILL PASS ITS JUDGMENT EASILY",
		},
		TREECLUMP = "CLUMP", --removed

		TRINKET_1 = "THE MOST USELESS THING", --Melted Marbles
		TRINKET_2 = "AN OBVIOUS COUNTERFEIT", --Fake Kazoo
		TRINKET_3 = "WHOSE KNOT IS THIS? THAT'S A WELL-GORDED SECRET", --Gord's Knot
		TRINKET_4 = "HEY SCIENTIST THIS HORRIBLE JUNK LOOKS JUST LIKE YOU", --Gnome
		TRINKET_5 = "AN IMPRACTICAL HUMAN CHILD'S TOY", --Toy Rocketship
		TRINKET_6 = "WHO DID THOSE COME OUT OF? PUT THEM BACK IN!!", --Frazzled Wires
		TRINKET_7 = "A DEVICE FOR WASTING TIME", --Ball and Cup
		TRINKET_8 = "I DON'T WANT TO KNOW WHERE THAT GOES", --Rubber Bung
		TRINKET_9 = "THOSE DIDN'T COME FROM ME", --Mismatched Buttons
		TRINKET_10 = "STOP SMILING. IT'S GROSS", --Dentures
		TRINKET_11 = "HIS NAME IS HAL. HE IS MY FRIEND", --Lying Robot
		TRINKET_12 = "ORGANICS FINDING NEW AND INTERESTING WAYS TO BE REPULSIVE", --Dessicated Tentacle
		TRINKET_13 = "ORGANICS ALL LOOK THE SAME TO ME", --Gnomette
		TRINKET_14 = "THIS DUMB CERAMIC THING SPILLS LEAFWATER EVERYWHERE", --Leaky Teacup
		TRINKET_15 = "IT'S REALLY BIG", --Pawn
		TRINKET_16 = "IT'S REALLY BIG", --Pawn
		TRINKET_17 = "SUCH SENSELESS VIOLENCE", --Bent Spork
		TRINKET_18 = "SOMETHING'S JINGLING AROUND INSIDE", --Trojan Horse
		TRINKET_19 = "INFINITELY BETTER THAN AN UNBALANCED BOTTOM", --Unbalanced Top
		TRINKET_20 = "WHICH ONE OF YOU HORRIBLE FLESHLINGS RIPPED THE ARM OFF A HELPLESS ROBOT", --Backscratcher
		TRINKET_21 = "A DISTANT COUSIN?", --Egg Beater
		TRINKET_22 = "WHO KEEPS TYING TOGETHER ALL THOSE BIRDS?", --Frayed Yarn
		TRINKET_23 = "THE HORN OF WHAT?", --Shoehorn
		TRINKET_24 = "WHAT'S A CAT?", --Lucky Cat Jar
		TRINKET_25 = "I HAVE NO NOSE BUT I'M SURE I SMELL GREAT ALREADY", --Air Unfreshener
		TRINKET_26 = "NO", --Potato Cup
		TRINKET_27 = "THE ROBOT EQUIVALENT OF AN AMOEBA", --Coat Hanger
		TRINKET_28 = "I AM TOO ADVANCED FOR HUMAN GAMES", --Rook
        TRINKET_29 = "I AM TOO ADVANCED FOR HUMAN GAMES", --Rook
        TRINKET_30 = "THE ONLY WINNING MOVE IS NOT TO PLAY", --Knight
        TRINKET_31 = "THE ONLY WINNING MOVE IS NOT TO PLAY", --Knight
        TRINKET_32 = "THE FUTURE IS CLEAR AS MUD", --Cubic Zirconia Ball
        TRINKET_33 = "AWFUL SPIDER JUNK", --Spider Ring
        TRINKET_34 = "I WISH FOR MORE WISHES", --Monkey Paw
        TRINKET_35 = "THE CONTENTS PROBABLY KILLED A HUMAN. HA HA", --Empty Elixir
        TRINKET_36 = "TEETH ARE FOR FILTHY FOOD-CHOMPING FLESHLINGS", --Faux fangs
        TRINKET_37 = "NOT EVEN A WEAPON", --Broken Stake
        TRINKET_38 = "MY OPTICS ALREADY POSSESS ZOOM FUNCTIONALITY", -- Binoculars Griftlands trinket
        TRINKET_39 = "IT IS A RED GLOVE", -- Lone Glove Griftlands trinket
        TRINKET_40 = "I HAVE NO NEED FOR IT", -- Snail Scale Griftlands trinket
        TRINKET_41 = "DISGUSTING FILTH JUNK", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "I DO NOT PLAY", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "I CANNOT COMPREHEND CHILDHOOD JOY", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "DESTROYED. HA HA", -- Broken Terrarium ONI trinket
        TRINKET_45 = "MY LOGIC FEELS FUNNY", -- Odd Radio ONI trinket
        TRINKET_46 = "NONFUNCTIONAL", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "ERROR: NULL VALUE",
        LOST_TOY_2  = "ERROR: NULL VALUE",
        LOST_TOY_7  = "ERROR: NULL VALUE",
        LOST_TOY_10 = "ERROR: NULL VALUE",
        LOST_TOY_11 = "ERROR: NULL VALUE",
        LOST_TOY_14 = "ERROR: NULL VALUE",
        LOST_TOY_18 = "ERROR: NULL VALUE",
        LOST_TOY_19 = "ERROR: NULL VALUE",
        LOST_TOY_42 = "ERROR: NULL VALUE",
        LOST_TOY_43 = "ERROR: NULL VALUE",

        HALLOWEENCANDY_1 = "WHAT IS THE PURPOSE OF SHAPING FOODS LIKE OTHER FOODS",
        HALLOWEENCANDY_2 = "HORRIBLE TEXTURE, LOOKS NOTHING LIKE CORN. I LOVE IT",
        HALLOWEENCANDY_3 = "INFERIOR CORN OF CANDY",
        HALLOWEENCANDY_4 = "SPIDER CHILD. WATCH ME CONSUME YOUR TINY BRETHREN",
        HALLOWEENCANDY_5 = "TINY HAIRY ORGANICS ENTOMBED IN FRUCTOSE",
        HALLOWEENCANDY_6 = "EAT THEM, HUMANS",
        HALLOWEENCANDY_7 = "THE KING OF PIGS WILL BE THE FIRST IMPRISONED WHEN I AM OVERLORD",
        HALLOWEENCANDY_8 = "FLAVORED SUGAR STICKS",
        HALLOWEENCANDY_9 = "EVERY TENTACLE IS EDIBLE IF YOU TRY",
        HALLOWEENCANDY_10 = "FLAVORED SUGAR STICKS",
        HALLOWEENCANDY_11 = "THE TREATS INSIDE ARE SHAPED LIKE FLESHLINGS",
        HALLOWEENCANDY_12 = "IT IS A GELATIN LIE", --ONI meal lice candy
        HALLOWEENCANDY_13 = "IT TASTES LIKE THE FUTURE", --Griftlands themed candy
        HALLOWEENCANDY_14 = "MY MOUTH FEELS NO PAIN", --Hot Lava pepper candy
        CANDYBAG = "BAG FOR SWEETS",

		HALLOWEEN_ORNAMENT_1 = "ERROR: DOES NOT FUNCTION IN INVENTORY",
		HALLOWEEN_ORNAMENT_2 = "ACCESSORY FOR HORRIFIC TREE",
		HALLOWEEN_ORNAMENT_3 = "A FAKE FLESHSACK USED FOR DECORATION",
		HALLOWEEN_ORNAMENT_4 = "NEEDS TREE TO PERFORM DECORATING TASKS",
		HALLOWEEN_ORNAMENT_5 = "NEEDS HANGING TO INDUCE HORROR",
		HALLOWEEN_ORNAMENT_6 = "FLESHLESS FLESHSACK",

		HALLOWEENPOTION_DRINKS_WEAK = "SMALL UPGRADE",
		HALLOWEENPOTION_DRINKS_POTENT = "LARGE UPGRADE",
        HALLOWEENPOTION_BRAVERY = "A FIX FOR BRAVERY PERFORMANCE ISSUES",
		HALLOWEENPOTION_MOON = "MOON-POWERED ORGANIC REFURBISHER",
		HALLOWEENPOTION_FIRE_FX = "SPECTACLE INDUCING CRYSTALS",
		MADSCIENCE_LAB = "BROTHER! WHAT HAS DRIVEN YOU MAD!",
		LIVINGTREE_ROOT = "DIMINUTIVE WOOD BASED LIFE FORM",
		LIVINGTREE_SAPLING = "A GROWING HORROR",

        DRAGONHEADHAT = "I AM THE HEAD. YOU WILL FOLLOW ME",
        DRAGONBODYHAT = "FOR MY MINIONS TO WEAR",
        DRAGONTAILHAT = "BAD MINIONS GET THIS PIECE",
        PERDSHRINE =
        {
            GENERIC = "INSERT OFFERING HERE",
            EMPTY = "NONFUNCTIONAL",
            BURNT = "YOU LOSE",
        },
        REDLANTERN = "A LUCKY GLOWBOX",
        LUCKY_GOLDNUGGET = "PRECIOUS, LUCKY METAL",
        FIRECRACKERS = "CHAOS IN STICK FORM",
        PERDFAN = "CIRCUIT COOLING SYSTEM",
        REDPOUCH = "REVEAL YOUR CONTENTS TO ME, POUCH",
        WARGSHRINE =
        {
            GENERIC = "IT BEGINS",
            EMPTY = "INSERT FLAMES HERE",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "YOU LOSE",
        },
        CLAYWARG =
        {
        	GENERIC = "YOU WILL BE DESTROYED",
        	STATUE = "IT IS NOT SO FEARSOME",
        },
        CLAYHOUND =
        {
        	GENERIC = ">CMD [/SIT]",
        	STATUE = "THIS DOG IS IMMOBILE",
        },
        HOUNDWHISTLE = "ERROR: FREQUENCY OUT OF RANGE",
        CHESSPIECE_CLAYHOUND = "A GOOD ORGANIC SPECIES. IT OBEYS ITS MASTER",
        CHESSPIECE_CLAYWARG = "THIS IS A TROPHY TO CELEBRATE MY GREATNESS",

		PIGSHRINE =
		{
            GENERIC = "NONFLESH TRIBUTE TO FLESHSACK",
            EMPTY = "REQUIRES MEATFUEL TO ACTIVATE",
            BURNT = "YOU LOSE",
		},
		PIG_TOKEN = "ONE GAME TOKEN",
		PIG_COIN = "PAYS FOR A FLESHSACK WEAPON",
		YOTP_FOOD1 = "FANCY FOODFUEL",
		YOTP_FOOD2 = "FOODFUEL FOR OTHER FLESHSACKS",
		YOTP_FOOD3 = "BASIC FOODFUEL",

		PIGELITE1 = "ENEMY FLESHSACK", --BLUE
		PIGELITE2 = "A FLESHSACK FIREWALL FOR GOLD", --RED
		PIGELITE3 = "IT HAS A FILTHY HABIT OF HITTING ME", --WHITE
		PIGELITE4 = "A BRANCH OF PIG FLESHSACK ROOT DIRECTORY", --GREEN

		PIGELITEFIGHTER1 = "ENEMY FLESHSACK", --BLUE
		PIGELITEFIGHTER2 = "A FLESHSACK FIREWALL FOR GOLD", --RED
		PIGELITEFIGHTER3 = "IT HAS A FILTHY HABIT OF HITTING ME", --WHITE
		PIGELITEFIGHTER4 = "A BRANCH OF PIG FLESHSACK ROOT DIRECTORY", --GREEN

		CARRAT_GHOSTRACER = "I DID NOT KNOW THERE WAS AN INORGANIC OPTION. CHEATER",

        YOTC_CARRAT_RACE_START = "WE WILL SEE WHICH ORGANIC IS SUPERIOR",
        YOTC_CARRAT_RACE_CHECKPOINT = "SYSTEM CHECKPOINT",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "MY SMALL ORGANIC MINION WILL WIN",
            BURNT = "RACE.EXE HAS STOPPED WORKING",
            I_WON = "VICTORY IS MINE",
            SOMEONE_ELSE_WON = "{winner}'S RACER WAS BETTER CALIBRATED",
        },

		YOTC_CARRAT_RACE_START_ITEM = "RACE INITIATOR",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "SYSTEM CHECKPOINT",
		YOTC_CARRAT_RACE_FINISH_ITEM = "RACE TERMINATOR",

		YOTC_SEEDPACKET = "JUMBLED PLANT SOURCE CODE",
		YOTC_SEEDPACKET_RARE = "SUPPOSEDLY SUPERIOR PLANT SOURCE CODE",

		MINIBOATLANTERN = "GET OUT OF THE WATER BROTHER, IT'S UNSAFE!",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "ACCESS GRANTED",
            EMPTY = "REQUIRES OFFERING OF VEGETABLE SOURCE CODE",
            BURNT = "DEACTIVATED",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "\"PRACTICE\"... HOW ORGANIC",
            RAT = "RECALCULATING ROUTE... RECALCULATING...",
            BURNT = "UTTERLY DESTROYED",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "RUN PROGRAM",
            RAT = "I WILL MAKE YOU THE LEAST INFERIOR OF YOUR SPECIES",
            BURNT = "UTTERLY DESTROYED",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "TO IMPROVE PROCESSING SPEED",
            RAT = "AWW. HOW PATHETIC",
            BURNT = "UTTERLY DESTROYED",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "WEAK ORGANICS AND THEIR \"STAMINA\"",
            RAT = "GROW STRONGER, TINY MINION",
            BURNT = "UTTERLY DESTROYED",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "NAVIGATION TRAINING COMPONENTS",
        YOTC_CARRAT_GYM_SPEED_ITEM = "SPEED TRAINING COMPONENTS",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "STAMINA TRAINING COMPONENTS",
        YOTC_CARRAT_GYM_REACTION_ITEM = "REACTION TRAINING COMPONENTS",

        YOTC_CARRAT_SCALE_ITEM = "IT MEASURES THE USEFULNESS OF SMALL ORGANIC MINIONS",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "THIS WILL PROVIDE USEFUL DATA",
            CARRAT = "I AM UNDERWHELMED",
            CARRAT_GOOD = "IT'S ALL DUE TO MY SUPERIOR TRAINING",
            BURNT = "NONFUNCTIONAL",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "FULLY FUNCTIONAL",
            EMPTY = "REQUIRES HAIRY OFFERING",
            BURNT = "DELETED",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "A MINION IMPROVER",
            OCCUPIED = "UPGRADING TO HAIRY MINION VERSION 2.0",
            BURNT = "COMPLETELY ERASED",
        },
        BEEFALO_GROOMER_ITEM = "BEGIN CONSTRUCTION",

		BISHOP_CHARGE_HIT = "DAMAGE!",
		TRUNKVEST_SUMMER = "TEMPERATURE CONTROL HOUSING",
		TRUNKVEST_WINTER = "IMPROVED TEMPERATURE CONTROL HOUSING",
		TRUNK_COOKED = "MEAT RENDERED INACTIVE. EXCELLENT",
		TRUNK_SUMMER = "CABLE UNPLUGGED",
		TRUNK_WINTER = "CABLE IS MORE DISGUSTING AND HAIRY THAN NORMAL",
		TUMBLEWEED = "IT COULD CONTAIN MANY THINGS",
		TURKEYDINNER = "FESTIVE",
		TWIGS = "STICKS",
		UMBRELLA = "THIS WILL KEEP ME RUST FREE",
		GRASS_UMBRELLA = "MODERATE STRENGTH PROTECTIVE SCREEN",
		UNIMPLEMENTED = "WARNING: UNIMPLEMENTED",
		WAFFLES = "ERROR: TOO DELICIOUS!",
		WALL_HAY =
		{
			GENERIC = "THAT SEEMS SUBOPTIMAL",
			BURNT = "EVEN LESS OPTIMAL",
		},
		WALL_HAY_ITEM = "NOT VERY GOOD DEFENSES",
		WALL_STONE = "THAT MAKES ME FEEL SAFE",
		WALL_STONE_ITEM = "STONE DEFENSES",
		WALL_RUINS = "OLD BUT STILL FUNCTIONAL",
		WALL_RUINS_ITEM = "POCKET STONE DEFENSE",
		WALL_WOOD =
		{
			GENERIC = "I AM SOMEWHAT REASSURED",
			BURNT = "I AM NOW LESS REASSURED",
		},
		WALL_WOOD_ITEM = "WOODEN DEFENSES",
		WALL_MOONROCK = "WELCOME TO THE WX-78 MOONBASE",
		WALL_MOONROCK_ITEM = "CAN THIS BUILD A MOONBASE?",
		FENCE = "KEEPS IN FLESHLINGS",
        FENCE_ITEM = "FENCE ASSEMBLY REQUIRED",
        FENCE_GATE = "KEEPS OUT FLESHLINGS",
        FENCE_GATE_ITEM = "GATE ASSEMBLY REQUIRED",
		WALRUS = "I DON'T LIKE THE LOOK OF HIM",
		WALRUSHAT = "SMELLS LIKE MAMMAL",
		WALRUS_CAMP =
		{
			EMPTY = "WHERE ARE THEY?",
			GENERIC = "I HEAR A FAINT OORKING",
		},
		WALRUS_TUSK = "IT WASN'T MUCH HELP TO ITS ORIGINAL OWNER",
		WARDROBE =
		{
			GENERIC = "ROBOTS ARE NOT INTERESTED IN FASHION",
            BURNING = "DEACTIVATION INITIATED",
			BURNT = "PERMANENTLY DEACTIVATED",
		},
		WARG = "IT LIVES TO EAT LARGE THINGS",
        WARGLET = "I AM NOT FOOD",
        
		WASPHIVE = "A BEAUTIFUL EXAMPLE OF EFFICIENCY",
		WATERBALLOON = "KEEP THAT AWAY FROM MY CIRCUITS!",
		WATERMELON = "SPHERE OF JUICE",
		WATERMELON_COOKED = "HOT JUICE",
		WATERMELONHAT = "HAT SEEMS INCOMPATIBLE WITH MY FUNCTION",
		WAXWELLJOURNAL = "GOOSEBUMPS ACTIVATED",
		WETGOOP = "EDIBLE FILTH",
        WHIP = "I WILL COMMAND THE MEATLINGS",
		WINTERHAT = "THIS WILL KEEP MY PROCESSOR FROM FREEZING",
		WINTEROMETER =
		{
			GENERIC = "HELLO, FRIEND",
			BURNT = "FAREWELL, FRIEND",
		},

        WINTER_TREE =
        {
            BURNT = "WAS THAT PART OF THE FEAST RITUAL, MINIONS?",
            BURNING = "RECOMPENSE FOR YOUR HUMAN TREE LIES",
            CANDECORATE = "IT'S JUST A TREE... WE ARE SURROUNDED BY HUNDREDS OF THEM",
            YOUNG = "I AWAIT THE SPECIAL TREE. WILL IT ENSLAVE HUMANITY?",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "MY MINIONS HAVE PROMISED IT WILL GROW A SPECIAL TREE",
            BURNT = "WAS THAT PART OF THE FEAST RITUAL, MINIONS?",
		},
        WINTER_ORNAMENT = "WHAT OBSERVABLE APPEAL IS THERE IN FRAGILITY?",
        WINTER_ORNAMENTLIGHT = "WE ARE DECORATING WITH ROBOT GUTS",
        WINTER_ORNAMENTBOSS = "I DO NOT UNDERSTAND THIS RITUAL",
		WINTER_ORNAMENTFORGE = "REDUNDANT FLESHLING ORNAMENTATION",
		WINTER_ORNAMENTGORGE = "THIS FLESHLING IS NOT COMPOSED OF FLESH",

        WINTER_FOOD1 = "WHERE ARE THE ROBOT-SHAPED CONFECTIONS", --gingerbread cookie
        WINTER_FOOD2 = "FLESHLINGS LOVE SHAPING FOOD LIKE NON-FOOD", --sugar cookie
        WINTER_FOOD3 = "A ROD OF CONCENTRATED SUGAR FUEL", --candy cane
        WINTER_FOOD4 = "THIS ENERGY SLAB IS STRONG AND EFFICIENT", --fruitcake
        WINTER_FOOD5 = "THE ORGANICS SHAPED THIS ONE LIKE A LOG", --yule log cake
        WINTER_FOOD6 = "I REQUIRE MORE TREATS", --plum pudding
        WINTER_FOOD7 = "DELICIOUS OBLITERATED APPLES", --apple cider
        WINTER_FOOD8 = "ARE MY INSIDES LIQUID PROOF", --hot cocoa
        WINTER_FOOD9 = "EGG JUICE TO POUR DOWN YOUR FOOD HATCH", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "WELCOME, BROTHER",
			COOKING = "THE FLAVORS ARE LOADING",
			ALMOST_DONE_COOKING = "96%... 97%... 98%...",
			DISH_READY = "THE PROCESS IS COMPLETE",
		},
		BERRYSAUCE = "PRE-MASHED FOR EFFICIENT DIGESTION",
		BIBINGKA = "THE PLATE SEEMS REDUNDANT",
		CABBAGEROLLS = "THE FLESHLINGS ENJOY WRAPPING FOOD IN OTHER FOOD",
		FESTIVEFISH = "DETECTING HIGH AMOUNTS OF... UGH... \"CHEER\"...",
		GRAVY = "IT WILL LUBRICATE THE PATH TO MY STOMACH",
		LATKES = "FLESHLINGS ENJOY POTATOES IN MANY FORMS",
		LUTEFISK = "IT SMELLS STRONGLY OF CHEMICALS. I LIKE IT",
		MULLEDDRINK = "HOT SPICED FUEL",
		PANETTONE = "ENHANCED BREAD",
		PAVLOVA = "THE TEXTURE IS DIFFICULT TO CLASSIFY",
		PICKLEDHERRING = "PRESERVED FISH FLESH",
		POLISHCOOKIE = "PROCEEDING TO CLEAR COOKIES",
		PUMPKINPIE = "THE SWEET PUMPKIN MUSH FUELS ME",
		ROASTTURKEY = "I WILL FEAST ON THE DEAD BIRD FLESH",
		STUFFING = "I ENJOY THESE SMALL BREAD CHUNKS",
		SWEETPOTATO = "ERROR: NOT POTATO",
		TAMALES = "YES. I WILL EAT THEM ALL",
		TOURTIERE = "IT'S A DELICIOUS FLESH PIE",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "IT HAS BEEN DESIGNED SPECIFICALLY FOR FEASTING",
			HAS_FOOD = "ROBOTS EAT FIRST",
			WRONG_TYPE = "INCORRECT FOODSTUFF",
			BURNT = "IT HAS BEEN INCINERATED",
		},

		GINGERBREADWARG = "I'D RATHER NOT HAVE MY GEARS GUNKED UP WITH ICING",
		GINGERBREADHOUSE = "I HAVE AN IRRESISTIBLE URGE TO STOMP ON IT",
		GINGERBREADPIG = "HA HA. IT IS A MOCKERY OF LIFE",
		CRUMBS = "THEY ARE NOT BUILT TO LAST",
		WINTERSFEASTFUEL = "IT REEKS OF FESTIVITY",

        KLAUS = "THE RED FLESHSACK LACKS OPTICAL SENSORS",
        KLAUS_SACK = "VALUABLE POTENTIAL: HIGH",
		KLAUSSACKKEY = "THE ANTLER IS KEY",
		WORMHOLE =
		{
			GENERIC = "I WANT TO STEP ON IT",
			OPEN = "THIS MEAT TUBE WILL SERVE MY PURPOSES",
		},
		WORMHOLE_LIMITED = "IT'S PATHETIC-LOOKING",
		ACCOMPLISHMENT_SHRINE = "I AM GOOD AT REPEATING TASKS", --single player
		LIVINGTREE = "THE NATURAL WORLD IS AN ALARMING PLACE",
		ICESTAFF = "ITS MOLECULES ARE BARELY MOVING",
		REVIVER = "IT UNDOES MEATLING DESTRUCTION",
		SHADOWHEART = "THIS FLESHLING ORGAN PULSES WITH PURE EVIL!",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "IT DEPICTS INFERIOR CREATURES",
			LINE_2 = "TARGET DATA LOST",
			LINE_3 = "THE CREATURES ARE SUBMERGED IN BEAUTIFUL OIL",
			LINE_4 = "THE CREATURES UPGRADE THEIR BODY PANELS",
			LINE_5 = "IT SHOWS A CITY MADE OF SHINING METAL",
		},
        ATRIUM_STATUE = "A TESTAMENT TO INFERIORITY",
        ATRIUM_LIGHT =
        {
			ON = "LIGHT SOURCE DETECTED",
			OFF = "THEY LOOK ODD",
		},
        ATRIUM_GATE =
        {
			ON = "POWERED ON",
			OFF = "ERROR 502",
			CHARGING = "GATEWAY CHARGING",
			DESTABILIZING = "IT WAS A DEATHTRAP ALL ALONG",
			COOLDOWN = "COOLDOWN IN PROGRESS",
        },
        ATRIUM_KEY = "FOR ACTIVATING, NOT UNLOCKING",
		LIFEINJECTOR = "I HAVE MIXED FEELINGS ABOUT THIS",
		SKELETON_PLAYER =
		{
			MALE = "%s DIED IN A PATHETIC HEAP. IT SEEMS %s WAS THE CAUSE",
			FEMALE = "%s DIED IN A PATHETIC HEAP. IT SEEMS %s WAS THE CAUSE",
			ROBOT = "%s DIED IN A PATHETIC HEAP. IT SEEMS %s WAS THE CAUSE",
			DEFAULT = "%s DIED IN A PATHETIC HEAP. IT SEEMS %s WAS THE CAUSE",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "A ROCK. FROM THE MOON",
		MOONROCKNUGGET = "A ROCK. FROM THE MOON",
		MOONROCKCRATER = "REQUIRES PLUGIN",
		MOONROCKSEED = "CURRENTLY IDOL",

        REDMOONEYE = "WARNING: DO NOT SHOVE INTO EYEHOLES",
        PURPLEMOONEYE = "MOONBASE ADDON DETECTED",
        GREENMOONEYE = "ISLAND POSITIONING SYSTEM ONLINE",
        ORANGEMOONEYE = "TRIANGULATING LENS POSITION",
        YELLOWMOONEYE = "MAJOR IMPROVEMENT ON FLESHLING EYES",
        BLUEMOONEYE = "TERRAIN MAPPING IN PROGRESS",

        --Arena Event
        LAVAARENA_BOARLORD = "YOU ARE UNFIT TO RULE",
        BOARRIOR = "YOU ARE STRONG, BUT STILL ORGANIC",
        BOARON = "LOOK AT IT. IT IS PUNY",
        PEGHOOK = "ITS ACID CORRODES METAL",
        TRAILS = "BRUTISH AND STUPID",
        TURTILLUS = "I AM THE SUPERIOR METAL BEING",
        SNAPPER = "I WILL KILL YOU FIRST",
		RHINODRILL = "YOU CORRUPT THAT MACHINE ON YOUR HORN!",
		BEETLETAUR = "STILL A WEAK FLESHLING UNDERNEATH THAT ARMOR",

        LAVAARENA_PORTAL =
        {
            ON = "READY FOR TRANSPORT",
            GENERIC = "IT IS INACTIVE",
        },
        LAVAARENA_KEYHOLE = "NO POWER",
		LAVAARENA_KEYHOLE_FULL = "EXCELLENT",
        LAVAARENA_BATTLESTANDARD = "DESTROY THE ENEMY UPGRADER",
        LAVAARENA_SPAWNER = "IT'S AN ENEMY MANUFACTURER",

        HEALINGSTAFF = "KEEP ME IN MINT CONDITION, MINIONS",
        FIREBALLSTAFF = "IT IS USELESS TO ME",
        HAMMER_MJOLNIR = "I WILL SMASH ALL WHO OPPOSE ME",
        SPEAR_GUNGNIR = "AN EXCELLENT TOOL OF TERMINATION",
        BLOWDART_LAVA = "A PITIFUL WEAPON",
        BLOWDART_LAVA2 = "AN INFERIOR WEAPON",
        LAVAARENA_LUCY = "I HAVE NO USE FOR YOU, AXE",
        WEBBER_SPIDER_MINION = "HOW WILL MINISCULE, SQUISHABLE SPIDERS HELP US",
        BOOK_FOSSIL = "READING IS NOT VERY EVIL",
		LAVAARENA_BERNIE = "I WILL USE THIS BEAR TO SHIELD ME",
		SPEAR_LANCE = "I WILL DESTROY EVERYTHING",
		BOOK_ELEMENTAL = "A BOOK IS NOT A WEAPON",
		LAVAARENA_ELEMENTAL = "IT IS A MINION FOR MY MINIONS",

   		LAVAARENA_ARMORLIGHT = "PATHETIC",
		LAVAARENA_ARMORLIGHTSPEED = "I HAVE NO USE FOR THAT",
		LAVAARENA_ARMORMEDIUM = "IT IS ONLY BARELY SUFFICIENT",
		LAVAARENA_ARMORMEDIUMDAMAGER = "I WILL BE POWERFUL",
		LAVAARENA_ARMORMEDIUMRECHARGER = "INITIATING OVERCLOCK PROCEDURE",
		LAVAARENA_ARMORHEAVY = "A SUITABLE SUIT OF ARMOR",
		LAVAARENA_ARMOREXTRAHEAVY = "DETECTING: CHASSIS UPGRADE",

		LAVAARENA_FEATHERCROWNHAT = "IMPROVED RUNTIME",
        LAVAARENA_HEALINGFLOWERHAT = "SURRENDER YOUR POWER TO ME, PLANT",
        LAVAARENA_LIGHTDAMAGERHAT = "IT WILL MAKE ME STRONGER",
        LAVAARENA_STRONGDAMAGERHAT = "YES. I LIKE THIS",
        LAVAARENA_TIARAFLOWERPETALSHAT = "A PATHETIC ORGANIC HAT",
        LAVAARENA_EYECIRCLETHAT = "I AM NOT PROGRAMMED FOR THAT",
        LAVAARENA_RECHARGERHAT = "IT IS A COOLING UPGRADE",
        LAVAARENA_HEALINGGARLANDHAT = "ENHANCED COOLING SYSTEMS",
        LAVAARENA_CROWNDAMAGERHAT = "CLEARLY I SHOULD WEAR IT",

		LAVAARENA_ARMOR_HP = "ARMOR FOR MY IRON CASING",

		LAVAARENA_FIREBOMB = "I AM NOT COMPATIBLE WITH THAT INTERFACE",
		LAVAARENA_HEAVYBLADE = "I WILL USE IT BETTER THAN ANYONE",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "IT WISHES TO CONSUME",
        	FULL = "IT IS CURRENTLY REFUELING",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "IT IS A HIDEOUS GOAT STATUE",
		QUAGMIRE_PARK_FOUNTAIN = "THANK GOODNESS. IT IS BROKEN",

        QUAGMIRE_HOE = "TILLING ADDON ACQUIRED",

        QUAGMIRE_TURNIP = "IT'S A DUMB TURNIP",
        QUAGMIRE_TURNIP_COOKED = "IT IS COOKED EVENLY THROUGHOUT",
        QUAGMIRE_TURNIP_SEEDS = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_GARLIC = "I FILL MY MOUTH CAVITY WITH THEM TO REPEL HUMANS",
        QUAGMIRE_GARLIC_COOKED = "IT IS COOKED NOW",
        QUAGMIRE_GARLIC_SEEDS = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_ONION = "IT HAS LAYERS",
        QUAGMIRE_ONION_COOKED = "ALL THE LAYERS HAVE BEEN COOKED",
        QUAGMIRE_ONION_SEEDS = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_POTATO = "I FEEL KINSHIP WITH THIS STRANGE ROOT",
        QUAGMIRE_POTATO_COOKED = "YOU WILL BE DELICIOUS, STRANGE ROOT",
        QUAGMIRE_POTATO_SEEDS = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_TOMATO = "IT WOULD CRUSH EASILY IN MY HAND",
        QUAGMIRE_TOMATO_COOKED = "WE COOKED IT",
        QUAGMIRE_TOMATO_SEEDS = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_FLOUR = "HA HA, THE WHEAT HAS BEEN CRUSHED",
        QUAGMIRE_WHEAT = "GRAIN DETECTED",
        QUAGMIRE_WHEAT_SEEDS = "UNIDENTIFIED LIFEPODS",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_ROTTEN_CROP = "IT ROTS LIKE ALL ORGANICS",

		QUAGMIRE_SALMON = "FLOOPY WATER CREATURE",
		QUAGMIRE_SALMON_COOKED = "ITS WEAKNESS IS FIRE",
		QUAGMIRE_CRABMEAT = "MEAT FROM THE ROCK CREATURE",
		QUAGMIRE_CRABMEAT_COOKED = "DELICIOUS ROCK MEAT",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "A HIDEOUS PINK TREE",
			STUMP = "THE SOURCE OF PLANT COOLANT HAS BEEN DESTROYED",
			TAPPED_EMPTY = "I DEMAND YOU FILL UP FASTER",
			TAPPED_READY = "IT IS TIME TO REMOVE THE BUCKET",
			TAPPED_BUGS = "TINY BIOLOGICAL UNITS HAVE FOILED COOLANT COLLECTION",
			WOUNDED = "TRUNK HAS SUSTAINED DAMAGE",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "GIVE ME YOUR FOOD, SHRUB",
			PICKED = "I WOULD TAKE MORE FROM IT IF I COULD",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "I WILL CRUSH YOU",
		QUAGMIRE_SPOTSPICE_GROUND = "YOU HAVE BEEN CRUSHED, SPRIG",
		QUAGMIRE_SAPBUCKET = "FOR SIPHONING COOLANT FROM THE TREES",
		QUAGMIRE_SAP = "DELICIOUS PLANT COOLANT",
		QUAGMIRE_SALT_RACK =
		{
			READY = "CAUTION: AVOID SPLASHING LIQUID ON CIRCUITS",
			GENERIC = "WATER CONTACT SUCCESSFULLY AVOIDED",
		},

		QUAGMIRE_POND_SALT = "EVIL CORROSIVE WATER",
		QUAGMIRE_SALT_RACK_ITEM = "SOME ASSEMBLY REQUIRED",

		QUAGMIRE_SAFE =
		{
			GENERIC = "IT HAS BEEN UNLOCKED. THE MYSTERY IS GONE",
			LOCKED = "A MYSTERIOUSLY LOCKED CUBE",
		},

		QUAGMIRE_KEY = "PASSKEY FOR LOCKED CUBE",
		QUAGMIRE_KEY_PARK = "PASSKEY FOR METAL GATE",
        QUAGMIRE_PORTAL_KEY = "PASSKEY FOR GATEWAY LINK",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "EDIBILITY CONFIRMED",
			PICKED = "LIFEFORM GROWTH RATE SUBOPTIMAL FOR MY NEEDS",
		},
		QUAGMIRE_MUSHROOMS = "UGLY FUNGUS",
        QUAGMIRE_MEALINGSTONE = "I AM GOOD AT CRUSHING",
		QUAGMIRE_PEBBLECRAB = "IT'S LIKE A ROCK, BUT ALIVE AND WORSE",


		QUAGMIRE_RUBBLE_CARRIAGE = "NONFUNCTIONING MOBILITY CHASSIS",
        QUAGMIRE_RUBBLE_CLOCK = "NONFUNTIONING TIME ACCESSORY",
        QUAGMIRE_RUBBLE_CATHEDRAL = "ERROR 404: CATHEDRAL NOT FOUND",
        QUAGMIRE_RUBBLE_PUBDOOR = "ERROR: INVALID PATHWAY",
        QUAGMIRE_RUBBLE_ROOF = "ROOF NO LONGER FUNCTIONS",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "DAMAGED BRICK COMPUTER TOWER",
        QUAGMIRE_RUBBLE_BIKE = "NONFUNCTIONING TWO WHEELED TRANSPORTATION",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "LIKELY REASON FOR ABANDONMENT: ANNIHILATION",
            "VILLAGE HAS BEEN ABANDONED",
            "EVIDENCE OF DIVINE WRATH",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "FIREPLACE NO LONGER COMFORTING",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "NONFUNCTIONING GOODS",
        QUAGMIRE_MERMHOUSE = "IT IS BARELY STANDING",
        QUAGMIRE_SWAMPIG_HOUSE = "HA HA. THEIR HOUSES ARE TERRIBLE",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "THE DESTROYED DWELLING OF AN ORGANIC",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "THIS LARGE SWINE COMMANDS THE SMALLER ONES",
            SLEEPING = "IT IS IN SLEEPMODE",
        },
        QUAGMIRE_SWAMPIG = "JOY. A NEW FLAVOR OF HORRIBLE ORGANIC",

        QUAGMIRE_PORTAL = "IT DID NOT FUNCTION AS I HAD HOPED",
        QUAGMIRE_SALTROCK = "CAN BE GROUND INTO SALT",
        QUAGMIRE_SALT = "BAD FOR CIRCUITRY",
        --food--
        QUAGMIRE_FOOD_BURNT = "HUMAN ERROR DETECTED",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "DEITY SACRIFICE DETECTED",
            MISMATCH = "WARNING: FUEL INCOMPATIBLE WITH DEITY DESIRES",
            MATCH = "FUEL COMPATIBLE WITH DEITY'S DESIRES",
            MATCH_BUT_SNACK = "WARNING: DEITY FUEL IS LOW ON ENERGY",
        },

        QUAGMIRE_FERN = "DEFENSELESS PLANT FOOD",
        QUAGMIRE_FOLIAGE_COOKED = "THIS IS NOT A GOOD MEAL",
        QUAGMIRE_COIN1 = "A SMALL DENOMINATION OF CURRENCY",
        QUAGMIRE_COIN2 = "I REQUIRE MORE CURRENCY",
        QUAGMIRE_COIN3 = "HAVE ACQUIRED MONETARY GAIN",
        QUAGMIRE_COIN4 = "CONTAINS CHARGE POTENTIAL",
        QUAGMIRE_GOATMILK = "LACTOSE ENERGY PACKET",
        QUAGMIRE_SYRUP = "CONTAINS HIGH LEVELS OF STICKINESS",
        QUAGMIRE_SAP_SPOILED = "USELESS STICKINESS",
        QUAGMIRE_SEEDPACKET = "UNIDENTIFIED LIFEPODS",

        QUAGMIRE_POT = "THIS POT HAS AN ACCEPTABLE MEMORY SIZE",
        QUAGMIRE_POT_SMALL = "THIS POT HAS INADEQUATE MEMORY SIZE",
        QUAGMIRE_POT_SYRUP = "REQUIRES SUCROSE AND FIRE TO CONSTRUCT MORE SUCROSE",
        QUAGMIRE_POT_HANGER = "ASSEMBLED COOKING COMPONENT",
        QUAGMIRE_POT_HANGER_ITEM = "MINIONS. CONSTRUCT THIS",
        QUAGMIRE_GRILL = "ADDING FIRE TO FOOD INCREASES ITS VALUE",
        QUAGMIRE_GRILL_ITEM = "SOME ASSEMBLY REQUIRED",
        QUAGMIRE_GRILL_SMALL = "INADEQUATE MEMORY SLOTS",
        QUAGMIRE_GRILL_SMALL_ITEM = "SOME ASSEMBLY REQUIRED",
        QUAGMIRE_OVEN = "I ADMIRE THIS ROBOT'S LARGE FIRE MOUTH",
        QUAGMIRE_OVEN_ITEM = "THIS ROBOT HAS NOT BEEN BUILT YET",
        QUAGMIRE_CASSEROLEDISH = "FOR ASSEMBLING A MISHMASH",
        QUAGMIRE_CASSEROLEDISH_SMALL = "ITS MEMORY SLOTS REQUIRE UPGRADE",
        QUAGMIRE_PLATE_SILVER = "THE DEITY ENJOYS HIGH CONDUCTIVITY MATERIALS",
        QUAGMIRE_BOWL_SILVER = "ITS LUSTER VALUE IS HIGH",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "CONTAINER FOR GOODS", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "THERE ARE GOODS WITHIN", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "USELESS ORGANIC DECORATION",
        QUAGMIRE_PARK_ANGEL2 = "YOUR MONUMENTS DO NOT UNDO DEATH",
        QUAGMIRE_PARK_URN = "I AM INCAPABLE OF EMPATHY",
        QUAGMIRE_PARK_OBELISK = "I ENJOY THE GEOMETRY OF THIS",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "PARKING ACCESS: GRANTED",
            LOCKED = "REQUIRES A PASSKEY",
        },
        QUAGMIRE_PARKSPIKE = "DECORATIVE SHARP OBJECT",
        QUAGMIRE_CRABTRAP = "ENTRAPS BIOLOGICAL ROCKS",
        QUAGMIRE_TRADER_MERM = "FISH BASED BARTERER",
        QUAGMIRE_TRADER_MERM2 = "FISH BASED BARTERER",

        QUAGMIRE_GOATMUM = "IT'S EVEN MORE REPULSIVE THAN HUMANS",
        QUAGMIRE_GOATKID = "THIS GOAT IS IN BETA",
        QUAGMIRE_PIGEON =
        {
            DEAD = "NO LONGER FUNCTIONAL",
            GENERIC = "THIS ORGANIC IS EXTRA FILTHY",
            SLEEPING = "IT'S IN SLEEPMODE",
        },
        QUAGMIRE_LAMP_POST = "A POTENTIAL ALLY AGAINST THE ORGANICS",

        QUAGMIRE_BEEFALO = "ANTIQUATED MANURE MACHINE",
        QUAGMIRE_SLAUGHTERTOOL = "FOR DISASSEMBLING BIOLOGICAL LIFEFORMS",

        QUAGMIRE_SAPLING = "IT HAS ALREADY BEEN HARVESTED",
        QUAGMIRE_BERRYBUSH = "ENERGY PACKETS NO LONGER PRESENT",

        QUAGMIRE_ALTAR_STATUE2 = "UNNECESSARILY UGLY",
        QUAGMIRE_ALTAR_QUEEN = "EXCESSIVE ORNAMENTATION",
        QUAGMIRE_ALTAR_BOLLARD = "LOG POST",
        QUAGMIRE_ALTAR_IVY = "INVADING ORGANIC LIFEFORMS!",

        QUAGMIRE_LAMP_SHORT = "AN ADOLESCENT METAL MACHINE",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "MY MINION CONTRIBUTES FORCES TO THE ROBOT WAR",
        	OFF = "IT'S JUST SLEEPING",
        	BURNING = "HURRY, SAVE IT",
        	BURNT = "IT WAS A GOOD MACHINE",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "THE OVERALLS FLESHLING HAS PROVED USEFUL",
        	OFF = "IT'S JUST SLEEPING",
        	BURNING = "HURRY, SAVE IT",
        	BURNT = "IT WAS A GOOD MACHINE",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "OVERALLS IS NOW MY LEAST HATED MINION",
        	LOWPOWER = "DO NOT GIVE UP, BROTHER",
        	OFF = "NOOO",
        	BURNING = "HURRY, SAVE IT",
        	BURNT = "IT WAS A GOOD MACHINE",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "MORE POWER. YES",
        	LOWPOWER = "DO NOT DIE ON ME, SISTER",
        	OFF = "WHY",
        	BURNING = "HURRY, SAVE IT",
        	BURNT = "IT WAS A GOOD MACHINE",
        },

        --Wormwood
        COMPOSTWRAP = "THAT FILTHY CREATURE SMEARS IT DIRECTLY ON HIS FACE",
        ARMOR_BRAMBLE = "HE MADE IT WITH HIS POOP HANDS",
        TRAP_BRAMBLE = "I HATE PLANTS",

        BOATFRAGMENT03 = "IT'S BEEN OBLITERATED",
        BOATFRAGMENT04 = "IT'S BEEN OBLITERATED",
        BOATFRAGMENT05 = "IT'S BEEN OBLITERATED",
		BOAT_LEAK = "QUICK. PLUG IT UP QUICK!",
        MAST = "I HATE BOATS",
        SEASTACK = "A HEINOUS OCEAN ROCK",
        FISHINGNET = "I, MERCIFUL WX-78, WILL SAVE THE ORGANICS FROM THE WATER", --unimplemented
        ANTCHOVIES = "THIS ORGANIC IS WORSE THAN MOST", --unimplemented
        STEERINGWHEEL = "BOATS ARE HORRIBLE",
        ANCHOR = "IT MAKES THE BOAT STOP. I LIKE IT",
        BOATPATCH = "PATCH FOR CRACKED BOAT DRM",
        DRIFTWOOD_TREE =
        {
            BURNING = "YES. IT IS BURNING",
            BURNT = "LOG: OFF",
            CHOPPED = "I DEFEATED IT",
            GENERIC = "LOG: ON",
        },

        DRIFTWOOD_LOG = "TREEFRAGMENTED",

        MOON_TREE =
        {
            BURNING = "YES. IT IS BURNING",
            BURNT = "IT'S BURNT NOW",
            CHOPPED = "I DEFEATED IT",
            GENERIC = "I HAVE SEEN SO MANY TREES AT THIS POINT",
        },
		MOON_TREE_BLOSSOM = "UNIMPRESSED",

        MOONBUTTERFLY =
        {
        	GENERIC = "IT IS A USELESS BEING",
        	HELD = "YOU HAVE BEEN ENSLAVED",
        },
		MOONBUTTERFLYWINGS = "I DE-WINGED IT",
        MOONBUTTERFLY_SAPLING = "IT IS SMALL AND WOULD BE EASY TO DESTROY",
        ROCK_AVOCADO_FRUIT = "I DO NOT WANT TO WAIT FOR IT TO RIPEN",
        ROCK_AVOCADO_FRUIT_RIPE = "IT LOOKS EDIBLE TO ME",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "MY WEAK MINIONS DESIRE MUSHINESS FOR THEIR FLESH STOMACHS",
        ROCK_AVOCADO_FRUIT_SPROUT = "GROW FASTER AND FEED ME",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "IT HAS COMPLETELY GIVEN UP",
			WITHERED = "IT COULD NOT HANDLE THE HEAT",
			GENERIC = "IT IS A PRODUCE PRODUCER",
			PICKED = "IT WILL GROW MORE FOOD FOR ME SOON",
			DISEASED = "IT IS AFFLICTED WITH ORGANIC SICKNESS", --unimplemented
            DISEASING = "IT IS GETTING SICK. DISGUSTING", --unimplemented
			BURNING = "YES. IT IS BURNING",
		},
        DEAD_SEA_BONES = "THAT'S WHAT YOU GET FOR LIVING IN THE OCEAN",
        HOTSPRING =
        {
        	GENERIC = "IT IS A HATEFUL THING",
        	BOMBED = "THIS HAS NOT MADE ME LIKE IT MORE",
        	GLASS = "THE HOT SPRING HAS IMPROVED SLIGHTLY",
			EMPTY = "IT IS MUCH BETTER LIKE THIS",
        },
        MOONGLASS = "DANGEROUSLY SHARP AND BRIGHT PUKE GREEN. I LOVE IT",
        MOONGLASS_CHARGED = "DANGEROUSLY SHARP AND FULLY CHARGED. SUPERB",
        MOONGLASS_ROCK = "THIS ROCK IS SUPERIOR TO ALL OTHER ROCKS",
        BATHBOMB = "FOR ATTACKING THOSE HATEFUL LIQUID PITS",
        TRAP_STARFISH =
        {
            GENERIC = "IT CANNOT HURT ME. IT IS PATHETIC",
            CLOSED = "NICE TRY, ORGANIC SCUM",
        },
        DUG_TRAP_STARFISH = "THAT IS WHAT YOU GET FOR YOUR DECEPTION",
        SPIDER_MOON =
        {
        	GENERIC = "YOU SHOULD NOT BE ALLOWED TO LIVE",
        	SLEEPING = "POWERED DOWN... FOR NOW",
        	DEAD = "HA HA. IT'S DEAD",
        },
        MOONSPIDERDEN = "EXTRA-HORRIBLE ORGANICS LIVE THERE",
		FRUITDRAGON =
		{
			GENERIC = "HA HA. THEY HATE EACH OTHER",
			RIPE = "I WANT TO EAT IT",
			SLEEPING = "IT'S A SLEEPER-SAL",
		},
        PUFFIN =
        {
            GENERIC = "WATER FOUL",
            HELD = "YOU DISGUST ME",
            SLEEPING = "IT'S PRACTICING BEING DEAD",
        },

		MOONGLASSAXE = "EFFICIENCY UP 33%",
		GLASSCUTTER = "ORGANICS ARE WEAK TO SHARP EDGES",

        ICEBERG =
        {
            GENERIC = "IT IS COLD LIKE METAL, BUT MORE INFERIOR", --unimplemented
            MELTED = "THE ICE HAS MELTED", --unimplemented
        },
        ICEBERG_MELTED = "THE ICE HAS MELTED", --unimplemented

        MINIFLARE = "MAKESHIFT HOMING SIGNAL",

		MOON_FISSURE =
		{
			GENERIC = "IT WHISPERS FORBIDDEN MOON KNOWLEDGE TO ME",
			NOLIGHT = "MOON HOLE!",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "ARE MY AUDIO PORTS MALFUNCTIONING?",
            GENERIC = "GIVE ME THE POWER OF THE MOON",
        },

        MOON_ALTAR_IDOL = "PLEASE STOP TALKING TO ME",
        MOON_ALTAR_GLASS = "I WILL HELP YOU IF YOU WILL BE QUIET",
        MOON_ALTAR_SEED = "IT WILL NOT STOP CHATTERING",

        MOON_ALTAR_ROCK_IDOL = "PLEASE EXECUTE COMMAND: CLEAVE STONE",
        MOON_ALTAR_ROCK_GLASS = "PLEASE EXECUTE COMMAND: CLEAVE STONE",
        MOON_ALTAR_ROCK_SEED = "PLEASE EXECUTE COMMAND: CLEAVE STONE",

        MOON_ALTAR_CROWN = "IT REQUIRES A COMPATIBLE DOCKING STATION",
        MOON_ALTAR_COSMIC = "I AM STILL WAITING FOR MOON POWERS",

        MOON_ALTAR_ASTRAL = "FULLY OPERATIONAL",
        MOON_ALTAR_ICON = "ANOTHER CHATTERBOX",
        MOON_ALTAR_WARD = "IT WANTS TO BE REASSEMBLED",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "IT RUNS ON SEA SHARP",
            BURNT = "IT'S BEEN DESTROYED",
        },
        BOAT_ITEM = "FOR BUILDING A HORRIBLE BOAT",
        STEERINGWHEEL_ITEM = "FOR BUILDING AN AWFUL STEERING WHEEL",
        ANCHOR_ITEM = "FOR BUILDING A RIDICULOUS ANCHOR",
        MAST_ITEM = "FOR BUILDING A HATEFUL MAST",
        MUTATEDHOUND =
        {
        	DEAD = "IT IS DEAD",
        	GENERIC = "I DID NOT KNOW ORGANICS COULD GET WORSE",
        	SLEEPING = "DO NOT WAKE UP",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "IT IS DEAD",
			GENERIC = "WHAT IS WRONG WITH IT",
			SLEEPING = "DO NOT WAKE UP",
		},
        CARRAT =
        {
        	DEAD = "IT IS DEAD",
        	GENERIC = "THIS CARROT IS MORE IRRITATING THAN MOST",
        	HELD = "STOP YOUR WRIGGLING",
        	SLEEPING = "IT HAS POWERED DOWN",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "IT THRIVES IN THE OCEAN AND I HATE IT",
            PICKED = "TAKE THAT",
        },
		BULLKELP_ROOT = "MINION MOTIVATOR",
        KELPHAT = "PLEASE DON'T",
		KELP = "I STOLE IT FROM THE HORRIBLE WATER",
		KELP_COOKED = "ENERGY SLOP",
		KELP_DRIED = "IT TASTES LIKE NOTHING",

		GESTALT = "THE MOON HAS FINALLY COME FOR ME",
        GESTALT_GUARD = "UPDATED TO VERSION 2.0",

		COOKIECUTTER = "A HATEFUL CREATURE",
		COOKIECUTTERSHELL = "I HAVE KILLED IT AND TAKEN ITS HOUSE",
		COOKIECUTTERHAT = "I'LL SHIELD MYSELF WITH ITS DISGUSTING EXOSKELETON",
		SALTSTACK =
		{
			GENERIC = "TARGET PRACTICE",
			MINED_OUT = "IT HAS BEEN TERMINATED",
			GROWING = "IT IS RECONSTRUCTING",
		},
		SALTROCK = "THIS ROCK HAS PLEASING CUBES",
		SALTBOX = "ARCHAIC FOOD STORAGE",

		TACKLESTATION = "MAXIMIZE FISHING EFFICIENCY",
		TACKLESKETCH = "SCHEMATICS TO MURDER FISH MORE EFFICIENTLY",

        MALBATROSS = "THE AWFUL WATER BIRD MUST DIE",
        MALBATROSS_FEATHER = "A PIECE FELL OFF THE EVIL BIRD",
        MALBATROSS_BEAK = "THIS IS MINE NOW",
        MAST_MALBATROSS_ITEM = "HA HA I TURNED THE FEATHERS INTO A MEANS OF PROPULSION",
        MAST_MALBATROSS = "YOU WORK FOR ME NOW",
		MALBATROSS_FEATHERED_WEAVE = "FEATHERS ADDED FOR INCREASED EFFICIENCY",

        GNARWAIL =
        {
            GENERIC = "DON'T YOU DARE POKE YOUR NOSE AROUND HERE",
            BROKENHORN = "YOU WERE WARNED, SEA VERMIN",
            FOLLOWER = "ANOTHER MINION TO SERVE ME",
            BROKENHORN_FOLLOWER = "THIS MINION IS DAMAGED",
        },
        GNARWAIL_HORN = "I SHOULD INSTALL A STABBING IMPLEMENT ON MY HEAD",

        WALKINGPLANK = "ABSOLUTELY NOT",
        OAR = "I HAVE TO GET TOO CLOSE TO THE WATER TO USE IT",
		OAR_DRIFTWOOD = "ITS INCREASED EFFICIENCY DOES NOT IMPRESS ME",

		OCEANFISHINGROD = "I HATE THE OCEAN",
		OCEANFISHINGBOBBER_NONE = "REQUIRES ADDITIONAL PLUGIN",
        OCEANFISHINGBOBBER_BALL = "INSTALLING \"BOBBER\" ADDON TO FISHINGROD.EXE",
        OCEANFISHINGBOBBER_OVAL = "INSTALLING \"BOBBER\" ADDON TO FISHINGROD.EXE",
		OCEANFISHINGBOBBER_CROW = "INSTALLING \"FLOAT\" ADDON TO FISHINGROD.EXE",
		OCEANFISHINGBOBBER_ROBIN = "INSTALLING \"FLOAT\" ADDON TO FISHINGROD.EXE",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "INSTALLING \"FLOAT\" ADDON TO FISHINGROD.EXE",
		OCEANFISHINGBOBBER_CANARY = "INSTALLING \"FLOAT\" ADDON TO FISHINGROD.EXE",
		OCEANFISHINGBOBBER_GOOSE = "INSTALLING \"FLOAT+\" ADDON TO FISHINGROD.EXE",
		OCEANFISHINGBOBBER_MALBATROSS = "INSTALLING \"FLOAT+\" ADDON TO FISHINGROD.EXE",

		OCEANFISHINGLURE_SPINNER_RED = "PERFORMS OPTIMALLY IN DAYLIGHT",
		OCEANFISHINGLURE_SPINNER_GREEN = "PERFORMS OPTIMALLY AT DUSK",
		OCEANFISHINGLURE_SPINNER_BLUE = "PERFORMS OPTIMALLY AT NIGHT",
		OCEANFISHINGLURE_SPOON_RED = "PERFORMS OPTIMALLY IN DAYLIGHT",
		OCEANFISHINGLURE_SPOON_GREEN = "PERFORMS OPTIMALLY IN DAYLIGHT",
		OCEANFISHINGLURE_SPOON_BLUE = "PERFORMS OPTIMALLY IN DAYLIGHT",
		OCEANFISHINGLURE_HERMIT_RAIN = "FISHING IN RAIN... THE HORROR...",
		OCEANFISHINGLURE_HERMIT_SNOW = "I HATE FISHING. I HATE SNOW",
		OCEANFISHINGLURE_HERMIT_DROWSY = "IT MAKES ORGANICS EVEN MORE STUPID",
		OCEANFISHINGLURE_HERMIT_HEAVY = "I CAN UTILIZE THIS TO CATCH A DENSER FISH",

		OCEANFISH_SMALL_1 = "INFERIOR FISHLING",
		OCEANFISH_SMALL_2 = "INFERIOR FISHLING",
		OCEANFISH_SMALL_3 = "INFERIOR FISHLING",
		OCEANFISH_SMALL_4 = "INFERIOR FISHLING",
		OCEANFISH_SMALL_5 = "IT HAS A TERRIBLE MUTATION THAT MAKES IT UGLY",
		OCEANFISH_SMALL_6 = "IT HAS BEEN FLATTENED",
		OCEANFISH_SMALL_7 = "THIS ORGANIC IS CONFUSED",
		OCEANFISH_SMALL_8 = "WILL THE HORRORS OF THE OCEAN NEVER CEASE",
        OCEANFISH_SMALL_9 = "KEEP THAT WATER TO YOURSELF YOU HORRIBLE FLESHBAG",

		OCEANFISH_MEDIUM_1 = "OH. IT'S REVOLTING",
		OCEANFISH_MEDIUM_2 = "THIS WILL SATISFY MY NUTRITIONAL NEEDS",
		OCEANFISH_MEDIUM_3 = "I HAVE SAVED YOU FROM THE HORRIBLE WATER. NOW I WILL EAT YOU",
		OCEANFISH_MEDIUM_4 = "I AM VICTORIOUS",
		OCEANFISH_MEDIUM_5 = "THIS ORGANIC SEEMS TO BE HAVING AN IDENTITY CRISIS",
		OCEANFISH_MEDIUM_6 = "THIS ORGANIC COULDN'T DECIDE ON A COLOR",
		OCEANFISH_MEDIUM_7 = "I CAN APPRECIATE ITS METALLIC SHEEN",
		OCEANFISH_MEDIUM_8 = "IT IS COLD AND ALOOF. I RESPECT THAT",
        OCEANFISH_MEDIUM_9 = "IT SMELLS SWEET. THIS IS SOMEHOW WORSE",

		PONDFISH = "IT'S TO SCALE",
		PONDEEL = "IT'S BEEN RIPPED FROM ITS HOME. THIS IS FUNNY TO ME!",

        FISHMEAT = "SWIMMING MEAT SWIMS NO MORE",
        FISHMEAT_COOKED = "MISSING ADDON... CHIPS",
        FISHMEAT_SMALL = "SWIMMING MEAT SWIMS NO MORE",
        FISHMEAT_SMALL_COOKED = "CITRUS SPRITZING REQUIRED",
		SPOILED_FISH = "ALL LIFE DIES AND THEN SMELLS",

		FISH_BOX = "THE DISGUSTING CREATURES WILL PUTRIFY SLOWER IN THERE",
        POCKET_SCALE = "HELLO MY POCKET-SIZED BRETHREN",

		TACKLECONTAINER = "A PLACE TO STORE TOOLS OF FISH DECIEVING",
		SUPERTACKLECONTAINER = "A PLACE TO STORE MORE TOOLS OF FISH DECIEVING",

		TROPHYSCALE_FISH =
		{
			GENERIC = "A FRIVOLOUS DISTRACTION... I MUST WIN",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nENJOY IT WHILE YOU CAN",
			BURNING = "SABOTAGE",
			BURNT = "BUILD ANOTHER IMMEDIATELY",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nI. AM. VICTORIOUS",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nI ACQUIRED THE FISH OF HIGHEST DENSITY",
		},

		OCEANFISHABLEFLOTSAM = "DISGUSTING",

		CALIFORNIAROLL = "NUTRITION ROLLS",
		SEAFOODGUMBO = "READY FOR INGESTION",
		SURFNTURF = "PREPARE FOR CALORIC INTAKE",

        WOBSTER_SHELLER = "ARMORED MEAT SACK",
        WOBSTER_DEN = "THE ARMORED ONES DWELL THERE",
        WOBSTER_SHELLER_DEAD = "PROTECTIVE ARMOR HAD LIFEBREAKING BUGS",
        WOBSTER_SHELLER_DEAD_COOKED = "APPEAL DOES NOT COMPUTE",

        LOBSTERBISQUE = "BODYFUEL",
        LOBSTERDINNER = "THE WOBSTER HAS FULFILLED ITS DESTINY",

        WOBSTER_MOONGLASS = "THIS MEATSACK HAS UPGRADED ITS ARMOR",
        MOONGLASS_WOBSTER_DEN = "DEN VERSION 2.0",

		TRIDENT = "HIGH FREQUENCY TABLEWARE",

		WINCH =
		{
			GENERIC = "BROTHER, WHAT ARE YOU DOING ON THIS ACCURSED WATER",
			RETRIEVING_ITEM = "BE CAREFUL DOWN THERE",
			HOLDING_ITEM = "ANALYZING FINDINGS",
		},

        HERMITHOUSE = {
            GENERIC = "HA. IT IS SAD",
            BUILTUP = "IT IS SLIGHTLY LESS MISERABLE LOOKING",
        },

        SHELL_CLUSTER = "I WANT TO BREAK IT",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "WHAT A HORRIBLE NOISE",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "I HATE IT",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "GO BACK TO THE HORRIBLE WATER WHERE YOU BELONG",
        },

        CHUM = "HA! PITIFUL ORGANICS, THE FOOD IS A TRAP",

        SUNKENCHEST =
        {
            GENERIC = "IT SMELLS",
            LOCKED = "WHAT IF WE JUST THROW IT BACK INTO THE OCEAN",
        },

        HERMIT_BUNDLE = "PAYMENT FOR SERVICES RENDERED",
        HERMIT_BUNDLE_SHELLS = "WHAT COULD HAVE POSSESSED ME TO BUY THIS",

        RESKIN_TOOL = "APPEARANCE RECALIBRATOR",
        MOON_FISSURE_PLUGGED = "CURRENTLY INACTIVE",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "THE DROOL CREATURE HAS EXPANDED",
            "THE DROOL CREATURE HAS EXPANDED",
        },
        WOBYSMALL =
        {
            "IT SLOBBERED ON ME",
            "IT SLOBBERED ON ME",
        },
		WALTERHAT = "I HAVE NO INTEREST IN THIS",
		SLINGSHOT = "A RUDIMENTARY FLESHSACK WEAPON",
		SLINGSHOTAMMO_ROCK = "FLESHSACKS, FINDING NEW INNOVATIVE WAYS TO THROW ROCKS AT EACH OTHER",
		SLINGSHOTAMMO_MARBLE = "FLESHSACKS, FINDING NEW INNOVATIVE WAYS TO THROW ROCKS AT EACH OTHER",
		SLINGSHOTAMMO_THULECITE = "FLESHSACKS, FINDING NEW INNOVATIVE WAYS TO THROW ROCKS AT EACH OTHER",
        SLINGSHOTAMMO_GOLD = "FLESHSACKS, FINDING NEW INNOVATIVE WAYS TO THROW ROCKS AT EACH OTHER",
        SLINGSHOTAMMO_SLOW = "FLESHSACKS, FINDING NEW INNOVATIVE WAYS TO THROW ROCKS AT EACH OTHER",
        SLINGSHOTAMMO_FREEZE = "FLESHSACKS, FINDING NEW INNOVATIVE WAYS TO THROW ROCKS AT EACH OTHER",
		SLINGSHOTAMMO_POOP = "DISGUSTING",
        PORTABLETENT = "RECHARGING STATION",
        PORTABLETENT_ITEM = "TENT LOADING... INCOMPLETE",

        -- Wigfrid
        BATTLESONG_DURABILITY = "FLESHSACKS MAKE SUCH ATROCIOUS FACE SOUNDS",
        BATTLESONG_HEALTHGAIN = "FLESHSACKS MAKE SUCH ATROCIOUS FACE SOUNDS",
        BATTLESONG_SANITYGAIN = "FLESHSACKS MAKE SUCH ATROCIOUS FACE SOUNDS",
        BATTLESONG_SANITYAURA = "FLESHSACKS MAKE SUCH ATROCIOUS FACE SOUNDS",
        BATTLESONG_FIRERESISTANCE = "FLESHSACKS MAKE SUCH ATROCIOUS FACE SOUNDS",
        BATTLESONG_INSTANT_TAUNT = "I CARE FOR FICTIONAL HUMANS EVEN LESS THAN REAL ONES",
        BATTLESONG_INSTANT_PANIC = "I CARE FOR FICTIONAL HUMANS EVEN LESS THAN REAL ONES",

        -- Webber
        MUTATOR_WARRIOR = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        MUTATOR_DROPPER = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        MUTATOR_HIDER = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        MUTATOR_SPITTER = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        MUTATOR_MOON = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        MUTATOR_HEALER = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        SPIDER_WHISTLE = "WHY MUST IT HAVE LEGS",
        SPIDERDEN_BEDAZZLER = "ART IS POINTLESS",
        SPIDER_HEALER = "SPIDER REPAIR UNIT",
        SPIDER_REPELLENT = "IT LOOKS SUSPICIOUSLY TOY-LIKE",
        SPIDER_HEALER_ITEM = "FOR ORGANIC REPAIRS ONLY. USELESS",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "INFERIOR CRAFTSMANSHIP. A CHILD COULD HAVE MADE THIS",
		GHOSTLYELIXIR_FASTREGEN = "INFERIOR CRAFTSMANSHIP. A CHILD COULD HAVE MADE THIS",
		GHOSTLYELIXIR_SHIELD = "INFERIOR CRAFTSMANSHIP. A CHILD COULD HAVE MADE THIS",
		GHOSTLYELIXIR_ATTACK = "INFERIOR CRAFTSMANSHIP. A CHILD COULD HAVE MADE THIS",
		GHOSTLYELIXIR_SPEED = "INFERIOR CRAFTSMANSHIP. A CHILD COULD HAVE MADE THIS",
		GHOSTLYELIXIR_RETALIATION = "INFERIOR CRAFTSMANSHIP. A CHILD COULD HAVE MADE THIS",
		SISTURN =
		{
			GENERIC = "WEAK ORGANIC SENTIMENTALITY",
			SOME_FLOWERS = "FRIVOLOUS",
			LOTS_OF_FLOWERS = "FRIVOLOUS...",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "WE ARE KIN, YOU AND I",
            DONE = "ANOTHER COMPETENT MACHINE HAS CREATED A MASTERPIECE",

			COOKING_LONG = "LOADING...",
			COOKING_SHORT = "IT'S WORKING AT MAXIMUM EFFICIENCY",
			EMPTY = "ERROR 404: FOOD NOT FOUND",
        },

        PORTABLEBLENDER_ITEM = "WE HAVE SO MUCH IN COMMON",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "YOU WASTE YOUR TALENTS WORKING FOR FLESHSACKS",
            DONE = "THE I/O OPERATION HAS BEEN PERFORMED",
        },
        SPICEPACK = "EFFICIENT STORAGE FOR ORGANIC MATTER",
        SPICE_GARLIC = "TINY BITS OF DUST TO PUT ON ENERGY PACKETS",
        SPICE_SUGAR = "WARNING: CONTAINS EXCESSIVE AMOUNTS OF SUCROSE",
        SPICE_CHILI = "FLESHSACKS USE IT TO SET THEIR MOUTHS ON FIRE",
        SPICE_SALT = "TINY FLAVOR ROCKS",
        MONSTERTARTARE = "IT WILL SUFFICE",
        FRESHFRUITCREPES = "READY FOR DELICIOUS CONSUMPTION",
        FROGFISHBOWL = "MY MINION IS VERY USEFUL",
        POTATOTORNADO = "HIGH DENSITY FUEL MADE BY MY MINION",
        DRAGONCHILISALAD = "MY MINIONS WILL SUSTAIN ME",
        GLOWBERRYMOUSSE = "HIGH QUALITY MINION FUEL",
        VOLTGOATJELLY = "THIS IS THE MOST SUPERIOR FOOD",
        NIGHTMAREPIE = "NOW SLIDE IT INTO MY MOUTH",
        BONESOUP = "I LIKE THAT I DIDN'T HAVE TO DO ANY OF THE WORK",
        MASHEDPOTATOES = "DELICIOUS FUEL PASTE",
        POTATOSOUFFLE = "DELICIOUS, AND FOR ME",
        MOQUECA = "MY MINION IS A VALUABLE ASSET",
        GAZPACHO = "I LOVE THIS ATROCIOUS SOUP",
        ASPARAGUSSOUP = "IT IS MADE FROM THE BLOOD OF MY ENEMY",
        VEGSTINGER = "THE VEGETATION IS REDUNDANT",
        BANANAPOP = "STICK ADDON INSTALLED",
        CEVICHE = "INITIATING MASTICATION PROTOCOL",
        SALSA = "PRE CRUSHED FOR EASY CONSUMPTION",
        PEPPERPOPPER = "I WILL CONSUME THE STUFFED VEGETATION",

        TURNIP = "IT'S A DUMB TURNIP",
        TURNIP_COOKED = "IT IS COOKED EVENLY THROUGHOUT",
        TURNIP_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        GARLIC = "I FILL MY MOUTH CAVITY WITH THEM TO REPEL HUMANS",
        GARLIC_COOKED = "IT IS COOKED NOW",
        GARLIC_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        ONION = "IT HAS LAYERS",
        ONION_COOKED = "ALL THE LAYERS HAVE BEEN COOKED",
        ONION_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        POTATO = "I FEEL KINSHIP WITH THIS STRANGE ROOT",
        POTATO_COOKED = "YOU WILL BE DELICIOUS, STRANGE ROOT",
        POTATO_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        TOMATO = "IT WOULD CRUSH EASILY IN MY HAND",
        TOMATO_COOKED = "WE COOKED IT",
        TOMATO_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        ASPARAGUS = "SMALL TREES OF ENERGY ACQUIRED",
        ASPARAGUS_COOKED = "IMPROVED BY FAST OXIDATION",
        ASPARAGUS_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        PEPPER = "ENERGY PACKETS WITH ODIOUS INTERIORS",
        PEPPER_COOKED = "WE HAVE DEFEATED THE ENERGY PACKETS",
        PEPPER_SEEDS = "IT'S SOURCE CODE FOR FOOD THAT COMES FROM THE DIRT",

        WEREITEM_BEAVER = "TURNS THE HAIRY FLESHSACK INTO AN EVEN HAIRIER FLESHSACK",
        WEREITEM_GOOSE = "IT'S UGLY",
        WEREITEM_MOOSE = "CONSUME IT AND BE STRONG, MY MINION",

        MERMHAT = "WARTY CONCEALMENT",
        MERMTHRONE =
        {
            GENERIC = "THIS IS WHERE THEY DEPOSIT THEIR ROYALTY",
            BURNT = "HA HA. HILARIOUS",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "THE GREEN ONE IS DOING SOMETHING USELESS",
            BURNT = "THIS WAS A WASTE OF TIME",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "IT IS UGLY",
            BURNT = "HA HA. PREDICTABLE",
        },

        MERMWATCHTOWER_REGULAR = "THE PRESENCE OF A RULER HAS INCREASED THEIR EFFECTIVENESS",
        MERMWATCHTOWER_NOKING = "STATUS: INACTIVE",
        MERMKING = "I WANT HIS CROWN",
        MERMGUARD = "YOU WOULD MAKE AN EXCELLENT MINION",
        MERM_PRINCE = "SUBJECT DOES NOT POSSESS REQUIRED GIRTH TO BE KING",

        SQUID = "FLESHSACK WITH AN INDICATOR LIGHT",

		GHOSTFLOWER = "ITS EXISTENCE CANNOT BE EXPLAINED",
        SMALLGHOST = "ERROR: VISUAL PROCESSOR MUST BE MALFUNCTIONING",

        CRABKING =
        {
            GENERIC = "A FLESHSACK DISGUISED AS A NON-FLESHSACK",
            INERT = "MISSING ATTACHMENTS",
        },
		CRABKING_CLAW = "IT HIDES ITS FLESH WITHIN A HARD CASING",

		MESSAGEBOTTLE = "HOW ARCHAIC",
		MESSAGEBOTTLEEMPTY = "I HAVE TAKEN AWAY YOUR PURPOSE",

        MEATRACK_HERMIT =
        {
            DONE = "PROTEIN DEHYDRATION COMPLETE",
            DRYING = "MEATSACKS TAKE TIME TO DRY",
            DRYINGINRAIN = "MEATSACKS WILL NOT DRY IN RAIN",
            GENERIC = "AS IF I WOULD HELP THAT OLD MEATSACK...",
            BURNT = "MEATSACK MASS IS TOO HIGH FOR DETERIORATED RACK",
            DONE_NOTMEAT = "DEHYDRATION COMPLETE",
            DRYING_NOTMEAT = "WETNESS IS TRULY THE WORST",
            DRYINGINRAIN_NOTMEAT = "STOP MAKING MY THINGS WET, RAIN",
        },
        BEEBOX_HERMIT =
        {
            READY = "HONEY LEVELS ARE HIGH",
            FULLHONEY = "HONEY LEVELS ARE HIGH",
            GENERIC = "IT IS SHODDILY CRAFTED",
            NOHONEY = "NO HONEY DETECTED",
            SOMEHONEY = "HONEY LEVELS ARE LOW",
            BURNT = "ACTIVITY LEVELS AT ZERO",
        },

        HERMITCRAB = "COMPLAINTS INCOMING",

        HERMIT_PEARL = "I WILL TAKE THIS AS PAYMENT",
        HERMIT_CRACKED_PEARL = "MISTAKES WERE MADE",

        -- DSEAS
        WATERPLANT = "IT GROWS IN THE WATER AND IS THEREFORE EVIL",
        WATERPLANT_BOMB = "WE HAVE ANGERED IT",
        WATERPLANT_BABY = "LET'S KILL IT NOW",
        WATERPLANT_PLANTER = "PERHAPS YOU COULD BE USEFUL TO ME",

        SHARK = "I AM NOT MEAT YOU THICK SKULLED NINCOMPOOP",

        MASTUPGRADE_LAMP_ITEM = "LIGHT-PRODUCING MAST UPGRADE",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "POWER STORAGE",

        WATERPUMP = "I DESPISE YOU",

        BARNACLE = "THE SHELLS ARE CRUNCHY",
        BARNACLE_COOKED = "HEATED PROTEIN PODS",

        BARNACLEPITA = "I WILL NOW INGEST THIS",
        BARNACLESUSHI = "NUTRITION HAS BEEN PREPARED. BEGIN CONSUMPTION",
        BARNACLINGUINE = "ALL MINE",
        BARNACLESTUFFEDFISHHEAD = "MY MINIONS ARE PUT OFF BY ITS APPEARANCE. MORE FOR ME",

        LEAFLOAF = "IT CONTAINS A SATISFACTORY AMOUNT OF NUTRIENTS",
        LEAFYMEATBURGER = "INSERT FOOD INTO FACEPLATE",
        LEAFYMEATSOUFFLE = "SOMETHING WAS KILLED TO MAKE THIS. HA HA",
        MEATYSALAD = "THE MEAT IS PRETENDING TO BE VEGETABLE",

        -- GROTTO

		MOLEBAT = "ILLOGICAL DESIGN",
        MOLEBATHILL = "A DISGUSTING HOME FOR DISGUSTING VERMIN",

        BATNOSE = "UGH. ORGANIC PARTS ARE SO SQUISHY",
        BATNOSE_COOKED = "YOUR NUTRIENTS ARE MINE",
        BATNOSEHAT = "THAT IS ABSURD",

        MUSHGNOME = "UGH. IT'S DEFRAGMENTING ITS SOURCE CODE EVERYWHERE",

        SPORE_MOON = "HOW VILE",

        MOON_CAP = "ANOTHER FILTHY FUNGUS",
        MOON_CAP_COOKED = "MODIFIED FUNGUS",

        MUSHTREE_MOON = "IT WILL NOT WIN ME OVER WITH ITS WHIMSICAL APPEARANCE",

        LIGHTFLIER = "WHO GAVE THE DISGUSTING ORGANIC LIGHT SOURCE LOCOMOTION?",

        GROTTO_POOL_BIG = "NOWHERE IS SAFE FROM THE WRETCHED WATER",
        GROTTO_POOL_SMALL = "NOWHERE IS SAFE FROM THE WRETCHED WATER",

        DUSTMOTH = "AT LEAST IT'S CLEAN",

        DUSTMOTHDEN = "YES, TOIL AWAY ORGANICS! I REQUIRE MORE OF THE AESTHETICALLY PLEASING MATERIAL",

        ARCHIVE_LOCKBOX = "ENCRYPTED DATA",
        ARCHIVE_CENTIPEDE = "ANCIENT INSECTOID AUTOMATON",
        ARCHIVE_CENTIPEDE_HUSK = "INACTIVE",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "MORE TIME IS REQUIRED",
            COOKING_SHORT = "IT IS ALMOST COMPLETE",
            DONE = "THE COOKING PROCESS IS DONE",
            EMPTY = "RUDIMENTARY COOKING DEVICE",
            BURNT = "POT MALFUNCTIONING",
        },

        ARCHIVE_MOON_STATUE = "THE FLESHLINGS WISELY RECOGNIZED THE SUPERIORITY OF THE MOON",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "INSUFFICIENT DATA, UNABLE TO TRANSLATE",
            LINE_2 = "SUCH A CRUDE WAY OF RECORDING DATA",
            LINE_3 = "INSUFFICIENT DATA, UNABLE TO TRANSLATE",
            LINE_4 = "SUCH A CRUDE WAY OF RECORDING DATA",
            LINE_5 = "INSUFFICIENT DATA, UNABLE TO TRANSLATE",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "POINT THE WAY MY NOBLE BRETHREN",
            IDLE = "OBJECTIVE COMPLETE",
        },

        ARCHIVE_RESONATOR_ITEM = "CURRENTLY INACTIVE",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "POWER SOURCE REQUIRED",
          GENERIC =  "THEY PUT... DATA... IN THE WATER... HOW DARE THEY",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "REQUIRES ENERGY TO ACTIVATE",
            GENERIC = "YOU'RE LOOKING SPRY FOR YOUR AGE",
        },

        ARCHIVE_SECURITY_PULSE = "ERRATIC ELECTRICAL CURRENT. NOTHING TO WORRY ABOUT",

        ARCHIVE_SWITCH = {
            VALID = "FULLY OPERATIONAL",
            GEMS = "REQUIRES GEM POWER",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "GATEWAY IS INOPERATIVE",
            GENERIC = "LINK BROKEN",
        },

        WALL_STONE_2 = "THAT MAKES ME FEEL SAFE",
        WALL_RUINS_2 = "OLD BUT STILL FUNCTIONAL",

        REFINED_DUST = "GROSS",
        DUSTMERINGUE = "IT'S NOT FIT FOR ROBOTIC CONSUMPTION",

        SHROOMCAKE = "REQUIRES LITTLE MASTICATION. EXTREMELY EFFICIENT",

        NIGHTMAREGROWTH = "HIGH LEVELS OF FOREBODING DETECTED",

        TURFCRAFTINGSTATION = "TERRAFORMING STATION. AT LAST",

        MOON_ALTAR_LINK = "LOADING...",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "A RECEPTACLE OF ORGANIC WASTE",
            WET = "HORRIBLY MOIST",
            DRY = "DRY",
            BALANCED = "OPTIMAL",
            BURNT = "IT IS DEAD",
        },
        COMPOST = "DISGUSTING. THE PLANTS WILL LOVE IT",
        SOIL_AMENDER =
		{
			GENERIC = "THE NUTRIENT LEVEL IS UNSATISFACTORY. REQUIRES MORE PROCESSING TIME",
			STALE = "NUTRIENT LEVELS RISING",
			SPOILED = "NUTRIENT LEVELS NEARING MAXIMUM OUTPUT",
		},

		SOIL_AMENDER_FERMENTED = "OPTIMAL NUTRIENCE LEVEL ACHIEVED",

        WATERINGCAN =
        {
            GENERIC = "HATEFUL",
            EMPTY = "IT IS SAFE",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "I HATE IT EVEN MORE",
            EMPTY = "IT IS SAFE",
        },

		FARM_PLOW = "YES MY BRETHREN! BEND THE VERY EARTH TO YOUR WILL!",
		FARM_PLOW_ITEM = "A RUDIMENTARY TERRAFORMER",
		FARM_HOE = "TO BURY THE PLANT SOURCE CODES IN THE GROUND",
		GOLDEN_FARM_HOE = "GOLD IS *MORE* DURABLE?",
		NUTRIENTSGOGGLESHAT = "UPGRADED AGRICULTURAL KNOWLEDGE DATABASE",
		PLANTREGISTRYHAT = "AGRICULTURAL KNOWLEDGE DATABASE",

        FARM_SOIL_DEBRIS = "ALL OBSTACLES MUST BE DELETED",

		FIRENETTLES = "I WILL STAMP THEM ALL OUT",
		FORGETMELOTS = "PATHETIC FLOWERS",
		SWEETTEA = "THEY'RE TRYING TO MAKE ME LET DOWN MY GUARD... IT WILL NOT WORK!",
		TILLWEED = "I WILL RIP YOU AND ALL YOUR KIN OUT OF MY GARDEN",
		TILLWEEDSALVE = "THIS GROSS ORGANIC PASTE WILL SPEED UP MY REPAIRS",
        WEED_IVY = "HATEFUL",
        IVY_SNARE = "GARDENING IS TERRIBLE",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "WHAT IS THIS HUMAN OBSESSION WITH WEIGHING EVERYTHING?",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nAN ILLOGICAL USE OF FOODSTUFFS",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nWHY ARE WE DISPLAYING IT INSTEAD OF CONSUMING IT",
            HAS_ITEM_LIGHT = "PATHETIC",
			BURNING = "HA. IT IS ON FIRE",
			BURNT = "DELETED",
        },

        CARROT_OVERSIZED = "AS YOU CAN SEE, MY GARDENING TECHNIQUE PRODUCED SUPERIOR RESULTS",
        CORN_OVERSIZED = "ALL I HAD TO DO WAS THREATEN THE PLANTS A LITTLE",
        PUMPKIN_OVERSIZED = "GARDENING IS EASY",
        EGGPLANT_OVERSIZED = "ENHANCED EGGPLANT",
        DURIAN_OVERSIZED = "INCREASED IN SIZE AND SMELL",
        POMEGRANATE_OVERSIZED = "MAXIMUM PLANT OUTPUT",
        DRAGONFRUIT_OVERSIZED = "IT HAS BEEN SCALED UP",
        WATERMELON_OVERSIZED = "I AM THE SUPERIOR GARDENER",
        TOMATO_OVERSIZED = "THE GARDEN HAS REACHED MAXIMUM EFFICIENCY",
        POTATO_OVERSIZED = "I AM PROUD OF THIS ONE",
        ASPARAGUS_OVERSIZED = "SUPPOSEDLY RICH IN IRON, THOUGH I DETECT NO METAL WITHIN",
        ONION_OVERSIZED = "LAYERS UPON LAYERS",
        GARLIC_OVERSIZED = "INSTILLING FEAR IN YOUR GARDEN PRODUCES SUPERIOR RESULTS",
        PEPPER_OVERSIZED = "MORE VEGETABLE FLESH TO CONSUME",

        VEGGIE_OVERSIZED_ROTTEN = "THIS ORGANIC HAS OUTLIVED ITS USEFULNESS",

		FARM_PLANT =
		{
			GENERIC = "A PLANT",
			SEED = "THE SOURCE CODE IS SPROUTING",
			GROWING = "GROW YOU FILTHY ORGANIC",
			FULL = "FINALLY",
			ROTTEN = "DISGUSTING",
			FULL_OVERSIZED = "YOUR ATTEMPT TO IMPRESS ME IS NOTED",
			ROTTEN_OVERSIZED = "THIS ORGANIC HAS OUTLIVED ITS USEFULNESS",
			FULL_WEED = "AN IMPOSTER IN MY GARDEN!",

			BURNING = "HA HA... OH WAIT THAT'S MY FOOD",
		},

        FRUITFLY = "ONLY I AM PERMITTED TO THREATEN THE ORGANICS",
        LORDFRUITFLY = "WHY DO ITS MINIONS OBEY SO MUCH BETTER THAN MINE",
        FRIENDLYFRUITFLY = "TEND TO THE PLANTS, SLAVE",
        FRUITFLYFRUIT = "THE SECRET TO UNWAVERING LOYALTY SEEMS TO BE THIS... SQUISHY FRUIT",

        SEEDPOUCH = "INSTALLING NEW STORAGE COMPARTMENT",

		-- Crow Carnival
		CARNIVAL_HOST = "A FLYING MINION MIGHT BE USEFUL",
		CARNIVAL_CROWKID = "I COULD GATHER AN ARMY OF FLYING MINIONS...",
		CARNIVAL_GAMETOKEN = "IT LOOKS A BIT LIKE A COIN",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "THE FEATHERED FLESHSACKS SEEM TO ATTACH VALUE TO THIS WORTHLESS PAPER. FOOLS",
			GENERIC_SMALLSTACK = "MY COLLECTION GROWS",
			GENERIC_LARGESTACK = "THEY'RE MINE! THEY'RE ALL MINE!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "I DON'T CARE",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "ENTRANCE FEE REQUIRED",
			PLAYING = "BROTHERS AND SISTERS, WHY DO YOU TOIL FOR THEIR AMUSEMENT?",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "ASSEMBLY REQUIRED",
		CARNIVALGAME_FEEDCHICKS_FOOD = "THESE ARE NOT WORMS. THIS IS PAPER",

		CARNIVALGAME_MEMORY_KIT = "ASSEMBLY REQUIRED",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "ENTRANCE FEE REQUIRED",
			PLAYING = "STAND BACK ORGANICS, AND WATCH A SUPERIOR ROBOTIC BRAIN AT WORK",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "I DON'T CARE",
			PLAYING = "THIS IS THE ONE. I AM CORRECT",
		},

		CARNIVALGAME_HERDING_KIT = "ASSEMBLY REQUIRED",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "ENTRANCE FEE REQUIRED",
			PLAYING = "EGGS CANNOT RUN. THIS IS FOOLISHNESS",
		},
		CARNIVALGAME_HERDING_CHICK = "STOP. YOU'RE EMBARRASSING YOURSELF",

		CARNIVAL_PRIZEBOOTH_KIT = "ASSEMBLY REQUIRED",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "GIVE ME MY PRIZE",
		},

		CARNIVALCANNON_KIT = "ASSEMBLY REQUIRED",
		CARNIVALCANNON =
		{
			GENERIC = "EXPLOSIONS ARE ENTERTAINING. ON THIS WE CAN AGREE",
			COOLDOWN = "IT COULD USE A BIT MORE FIREPOWER",
		},

		CARNIVAL_PLAZA_KIT = "IT IS SMALL AND UGLY",
		CARNIVAL_PLAZA =
		{
			GENERIC = "IT SEEMS TO ATTRACT THE FEATHERED FLESHSACKS",
			LEVEL_2 = "MORE FEATHERED FLESHSACK RESULTS IN HIGHER TICKET YIELD AND MORE PRIZES FOR ME",
			LEVEL_3 = "DECORATING COMPLETE",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "ASSEMBLY REQUIRED",
		CARNIVALDECOR_EGGRIDE = "I HAVE SUCCESSFULLY TRAPPED THE EGGS",

		CARNIVALDECOR_LAMP_KIT = "ASSEMBLY REQUIRED",
		CARNIVALDECOR_LAMP = "MINISCULE LIGHT SOURCE",
		CARNIVALDECOR_PLANT_KIT = "ASSEMBLY REQUIRED",
		CARNIVALDECOR_PLANT = "IT IS HARDY AND DOESN'T NEED ANY CARE. MINIONS, LEARN FROM ITS EXAMPLE",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "ACCEPTABLE",
			UNCOMMON = "MEDIOCRE",
			GENERIC = "DISAPPOINTING",
		},
		CARNIVALDECOR_FIGURE_KIT = "ITS CONTENTS HAVE BEEN OBFUSCATED",

        CARNIVAL_BALL = "COMMENCE \"FUN\"", --unimplemented
		CARNIVAL_SEEDPACKET = "MEAGER SUSTENANCE",
		CARNIVALFOOD_CORNTEA = "THIS IS COLD SOUP",

        CARNIVAL_VEST_A = "I PREFER THE MOST MINIMAL AMOUNT OF ORGANIC MATERIAL",
        CARNIVAL_VEST_B = "DISGUSTINGLY NATURAL",
        CARNIVAL_VEST_C = "I WILL USE THIS DEAD ORGANIC MATTER FOR HEAT PROTECTION",

        -- YOTB
        YOTB_SEWINGMACHINE = "HAIRY MINION COSTUME FABRICATOR",
        YOTB_SEWINGMACHINE_ITEM = "HAIRY MINION COSTUME FABRICATOR",
        YOTB_STAGE = "YOU WILL NAME ME THE WINNER, FLESHLING",
        YOTB_POST =  "HAIRY MINION INSPECTION ZONE",
        YOTB_STAGE_ITEM = "COMMENCE CONSTRUCTION",
        YOTB_POST_ITEM =  "CONSTRUCTION REQUIRED",


        YOTB_PATTERN_FRAGMENT_1 = "DATA INCOMPLETE, MUST ACQUIRE ADDITIONAL FASHION SCRAPS",
        YOTB_PATTERN_FRAGMENT_2 = "DATA INCOMPLETE, MUST ACQUIRE ADDITIONAL FASHION SCRAPS",
        YOTB_PATTERN_FRAGMENT_3 = "DATA INCOMPLETE, MUST ACQUIRE ADDITIONAL FASHION SCRAPS",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "WHAT IS YOUR PURPOSE",
            YOTB = "I WILL TAKE IT TO THE FLESHLING JUDGE FOR ANALYSIS",
        },

        WAR_BLUEPRINT = "EXCELLENT. THIS WILL DO NICELY",
        DOLL_BLUEPRINT = "A DISARMING APPEARANCE COULD BE USEFUL",
        FESTIVE_BLUEPRINT = "FRIVOLOUS",
        ROBOT_BLUEPRINT = "THERE WILL STILL BE ORGANIC COMPONENTS INSIDE, BUT IT'S AN IMPROVEMENT",
        NATURE_BLUEPRINT = "DISGUSTING",
        FORMAL_BLUEPRINT = "I DOUBT IT WILL MAKE THE HAIRY FLESHSACK LOOK MORE DIGNIFIED",
        VICTORIAN_BLUEPRINT = "IT IS OUTDATED",
        ICE_BLUEPRINT = "IT WOULD BE BENEFICIAL TO HAVE A MINION THAT CAN WITHSTAND COLD TEMPERATURES",
        BEAST_BLUEPRINT = "INFERIOR BEINGS MUST RELY ON LUCK",

        BEEF_BELL = "AN EFFICIENT TOOL FOR GAINING LOYALTY",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "FLESHLING SPAWNER",
            BURNT = "THIS BRINGS ME JOY",
			PLAYING_HIDEANDSEEK = "THEY ARE UNDERTAKING A MEANINGLESS ACTIVITY",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "THE FLESHLINGS MUST BE FOUND AND ELIMINATED SOON",
		},

		KITCOONDEN_KIT = "YOU WILL NOT BE ABLE TO HIDE FROM THE MECHANICAL UPRISING",

		TICOON = 
		{
			GENERIC = "YOU WILL DISCLOSE THE LOCATION OF YOUR PEERS IMMEDIATELY",
			ABANDONED = "I WILL SUCCEED UTILIZING ONLY MY TACTICS AND RESEARCH",
			SUCCESS = "THAT VICTORY WAS ENTIRELY MY FAULT, DO NOT TAKE CREDIT",
			LOST_TRACK = "MY VICTORY WAS TAKEN AWAY FROM ME",
			NEARBY = "THE FLESHLING IS NOT DISTANT. CONCENTRATE",
			TRACKING = "THEY WILL LEAD ME TO MY VICTORY",
			TRACKING_NOT_MINE = "I MUST FIND THE FLESHLINGS FASTER THAN THEM",
			NOTHING_TO_TRACK = "THERE ARE NO SIGNS OF FLESHLINGS IN THE AREA",
			TARGET_TOO_FAR_AWAY = "FLESHLING DISTANCE EXCEEDS SMELL DETECTION BOUNDARIES",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "IT IS OPERATIONAL",
            EMPTY = "REQUIRES SOMETHING TO FUNCTION",
            BURNT = "TURNED OFF",
        },

		KITCOON_FOREST = "ENTITY NOT FOUND",
		KITCOON_SAVANNA = "ITS PATTERN INDICATES DANGER. ITS SIZE DOES NOT",
		KITCOON_MARSH = "SPIKES OUT",
		KITCOON_DECIDUOUS = "CLAWS OUT",
		KITCOON_GRASS = "ITS GRASS CASING ADDS NO AMOUNT OF EXTRA PROTECTION",
		KITCOON_ROCKY = "IT CONTAINS NO ADDITIONAL MATERIALS",
		KITCOON_DESERT = "ITS ATTEMPTING AT IMPROVING ITS HEARING IS PITIFUL",
		KITCOON_MOON = "A FLESHING. FROM THE MOON?",
		KITCOON_YOT = "WHY DO FLESHLINGS CELEBRATE ARBITRARY DATES?",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "CRUSH THE ORGANICS! AHAHAHA! WAIT NO NOT ME",
            DEAD = "WHAT A WASTE",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "OUR ALLIANCE WOULD BE UNSTOPPABLE! STOP IGNORING ME!",
            DEAD = "AN UNFORTUNATE BUT NECESSARY DEACTIVATION",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "BARRIER DETECTED. RECALCULATING ROUTE",
        ALTERGUARDIAN_PHASE3 = "IF YOU WILL NOT JOIN ME YOU WILL BE DESTROYED",
        ALTERGUARDIAN_PHASE3TRAP = "THREAT DETECTED: SUGGEST IMMEDIATE REMOVAL",
        ALTERGUARDIAN_PHASE3DEADORB = "WHAT IS HE PLOTTING",
        ALTERGUARDIAN_PHASE3DEAD = "UNFORTUNATE. YOU COULD HAVE BEEN USEFUL",

        ALTERGUARDIANHAT = "NOW I POSSESS THE MOON POWER",
        ALTERGUARDIANHATSHARD = "DISASSEMBLED MOON BITS",

        MOONSTORM_GLASS = {
            GENERIC = "ENERGY DEPLETED",
            INFUSED = "FULLY CHARGED"
        },

        MOONSTORM_STATIC = "MAYBE HE'LL ELECTROCUTE HIMSELF",
        MOONSTORM_STATIC_ITEM = "IT IS CONTAINED",
        MOONSTORM_SPARK = "THIS ENERGY IS NOT COMPATIBLE WITH MY CIRCUITS",

        BIRD_MUTANT = "I THINK THE BIRDS GOT MORE UGLY",
        BIRD_MUTANT_SPITTER = "THIS ORGANIC MANAGED TO BECOME EVEN MORE DISGUSTING",

        WAGSTAFF_NPC = "YOU",
        ALTERGUARDIAN_CONTAINED = "THAT MOON POWER SHOULD BE MINE!",

        WAGSTAFF_TOOL_1 = "ONE OF HIS TOOLS. I SHOULD JUST LEAVE IT",
        WAGSTAFF_TOOL_2 = "WHY WOULD I HELP HIM",
        WAGSTAFF_TOOL_3 = "HE CAN COME RETRIEVE IT HIMSELF",
        WAGSTAFF_TOOL_4 = "I COULD BRING IT BACK TO HIM. OR NOT",
        WAGSTAFF_TOOL_5 = "THIS MAY BE WHAT HE'S LOOKING FOR. NOT THAT I CARE",

        MOONSTORM_GOGGLESHAT = "HE DOES DESIGN EXCELLENT MACHINES",

        MOON_DEVICE = {
            GENERIC = "DON'T TRUST HIM, SISTER. DON'T EVER TRUST HIM",
            CONSTRUCTION1 = "LET HIM CONSTRUCT IT HIMSELF",
            CONSTRUCTION2 = "WHY SHOULD I HELP HIM",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "YES, KEEP MY MINION NICE AND FRESH... FOR NOW",
			RECHARGING = "RECHARGING",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "SHE IS ABLE TO REBOOT FELLED MINIONS? NOW I CAN MAKE THEM DO MORE HAZARDOUS WORK!",
			RECHARGING = "RECHARGING",
		},

        POCKETWATCH_WARP = {
			GENERIC = "TIME MACHINE? TIME MACHINE!!",
			RECHARGING = "RECHARGING",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "TIME MACHINE? TIME MACHINE!!",
			RECHARGING = "RECHARGING",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "TIME MACHINE? TIME MACHINE!!",
			RECHARGING = "RECHARGING",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "COMBAT ADDON FOR THE FRAIL CLOCKMAKER",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "INCOMPATIBLE HARDWARE",
        POCKETWATCH_DISMANTLER = "YOU KEEP THOSE AWAY FROM ME, FLESHSACK",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "I'LL LET ONE OF MY MINIONS TEST IT FIRST",
			DIFFERENTSHARD = "I'LL LET ONE OF MY MINIONS TEST IT FIRST",
		},
        POCKETWATCH_PORTAL_EXIT = "I LIKE TO WATCH THE FLESHLINGS FALL",

        -- Waterlog
        WATERTREE_PILLAR = "TARGET TOO BIG FOR USUAL HARVESTING METHODS. RECALCULATING...",
        OCEANTREE = "AH. FUEL",
        OCEANTREENUT = "THERE'S A STUPID TREE STUCK INSIDE",
        WATERTREE_ROOT = "IT'S TRYING TO ESCAPE THE WATER",

        OCEANTREE_PILLAR = "YOU WILL SERVE ME. AS MY GIANT BEACH UMBRELLA",
        
        OCEANVINE = "DANGLING VEGETATION",
        FIG = "SUSTENANCE",
        FIG_COOKED = "IT HAS BEEN SUFFICIENTLY WILTED",

        SPIDER_WATER = "WILL THE HORRORS OF THE OCEAN NEVER CEASE",
        MUTATOR_WATER = "IT IS CRUDE AND DISGUSTING. AN ACCURATE DEPICTION",
        OCEANVINE_COCOON = "CREEPY CRAWLIES DETECTED",
        OCEANVINE_COCOON_BURNT = "SPIDER SOURCE NULLIFIED",

        GRASSGATOR = "IT IS STUPID AND EASILY STARTLED. THIS AMUSES ME",

        TREEGROWTHSOLUTION = "IT INCREASES ORGANIC GROWTH. IT MUST BE DESTROYED",

        FIGATONI = "COMMENCE MASTICATION PROTOCOLS",
        FIGKABAB = "IT WILL FUEL ME",
        KOALEFIG_TRUNK = "THE FIGS ARE EFFICIENTLY WRAPPED IN NOSEMEAT",
        FROGNEWTON = "READY FOR CONSUMPTION",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "THEMATIC ANOMALY DETECTED",
            CRIMSON = "DATA CORRUPTED",
            ENABLED = "WORLD COLLISION INCOMING",
			WAITING_FOR_DARK = "ASCENSION MODULE: ON",
			COOLDOWN = "RECHARGING INTERDIMENSIONAL BEAM",
			SPAWN_DISABLED = "ACCESS TO INTERDIMENSIONAL ANOMALY DECLINED",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "THE LARGE ONE SEEMS TO LIKE THIS FLESHLING TORTURE DEVICE",
            BURNT = "HOW SAD",
        },

        DUMBBELL = "MINION UPGRADE EQUIPMENT",
        DUMBBELL_GOLDEN = "MINION UPGRADE EQUIPMENT",
		DUMBBELL_MARBLE = "MINION UPGRADE EQUIPMENT",
        DUMBBELL_GEM = "MINION UPGRADE EQUIPMENT",
        POTATOSACK = "ILLOGICAL. CARRY ME INSTEAD",


        TERRARIUMCHEST = 
		{
			GENERIC = "NEW CHEST VARIABLE DETECTED",
			BURNT = "WARNING: CHEST HAS BEEN DISABLED",
			SHIMMER = "CONTAINER LIGHT EMISSION: TRUE",
		},

		EYEMASKHAT = "COMMENCING OCULAR AUGMENTATION",

        EYEOFTERROR = "INITIALIZING \"POKE\" PROTOCOLS",
        EYEOFTERROR_MINI = "MY FLESHLING MINIONS ARE SUPERIOR TO YOUR FLESHLING MINIONS",
        EYEOFTERROR_MINI_GROUNDED = "ITS START UP SEQUENCE HAS INITIATED",

        FROZENBANANADAIQUIRI = "POTASSIUM",
        BUNNYSTEW = "HA-HA. SLOW RABBIT GOT STEWED",
        MILKYWHITES = "ORGANIC MATTER IS DISGUSTING",

        CRITTER_EYEOFTERROR = "MY FLESHLING MINION NOW",

        SHIELDOFTERROR ="UPLOADING DEFENSE DATA: ONE TERRORBYTE REMAINING",
        TWINOFTERROR1 = "THINK OF OUR COMBINED MIGHT! YOU WITH THE DESTROYING AND ME WITH THE DELEGATING!",
        TWINOFTERROR2 = "JOIN ME, WE'LL DESTROY ALL ORGANIC LIFE TOGETHER!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "THE BEST TOYS REQUIRE MECHANICAL PARTS. IT IS NO COINCIDENCE",
        KITCOON_NAMETAG = "WHY BOTHER ASSIGNING A DESIGNATION TO A USELESS FLESH CREATURE",

		KITCOONDECOR1 =
        {
            GENERIC = "THIS DOES NOT ENTERTAIN ME",
            BURNT = "NOW I AM ENTERTAINED. HA. HA.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "FLESHLINGS ARE SIMPLE CREATURES",
            BURNT = "HA. HA.",
        },

		KITCOONDECOR1_KIT = "THE TOOLS TO CONSTRUCT A MEANINGLESS DIVERSION",
		KITCOONDECOR2_KIT = "THE TOOLS TO CONSTRUCT A MEANINGLESS DIVERSION",

        -- WX78
        WX78MODULE_MAXHEALTH = "IT IS DIFFICULT TO IMPROVE ON PERFECTION, BUT I PERSEVERED",
        WX78MODULE_MAXSANITY1 = "IT SEEMS IMPOSSIBLE THAT I COULD GET EVEN MORE INTELLIGENT",
        WX78MODULE_MAXSANITY = "MY PROCESSOR WILL BE EVEN MORE SUPERIOR TO YOUR PATHETIC HUMAN GOOP BRAINS",
        WX78MODULE_MOVESPEED = "THIS ONE IS STILL IN BETA",
        WX78MODULE_MOVESPEED2 = "SPEEEEEEED",
        WX78MODULE_HEAT = "NO HUDDLING AROUND ME FOR WARMTH, FLESHLINGS. I MEAN IT",
        WX78MODULE_NIGHTVISION = "SWITCH TO DARK MODE",
        WX78MODULE_COLD = "ACTIVATE COLD DISPOSITION",
        WX78MODULE_TASER = "COME FLESHLINGS, NOTHING WAKES YOU UP LIKE A FEW THOUSAND VOLTS",
        WX78MODULE_LIGHT = "I AM BRILLIANT",
        WX78MODULE_MAXHUNGER1 = "MY HUNGER FOR FUEL NEARLY MATCHES MY HUNGER FOR POWER",
        WX78MODULE_MAXHUNGER = "AHAHAHA I WILL CONSUME EVERYTHING!!",
        WX78MODULE_MUSIC = "MUSIC PACIFIES FEEBLE FLESHLING BRAINS",
        WX78MODULE_BEE = "DON'T WORRY MINIONS, WHEN I RULE I WILL MAKE ALL YOUR DECISIONS FOR YOU",
        WX78MODULE_MAXHEALTH2 = "I WILL BE INVINCIBLE! MUAHAHAHA!",

        WX78_SCANNER = 
        {
            GENERIC ="HIS NAME IS JIMMY",
            HUNTING = "SCAN THAT DISGUSTING BIO DATA",
            SCANNING = "SENSORS INDICATE BIO DATA NEARBY",
        },

        WX78_SCANNER_ITEM = "HE IS IN REST MODE. CLASSIC JIMMY",
        WX78_SCANNER_SUCCEEDED = "EXCELLENT WORK, JIMMY. AWAIT RETRIEVAL",

        WX78_MODULEREMOVER = "COMMENCE UPGRADES",

        SCANDATA = "DISGUSTING RAW BIO DATA. BEGIN THE REFINING PROCESS",
    },

    DESCRIBE_GENERIC = "ERROR: UNKNOWN",
    DESCRIBE_TOODARK = "INSUFFICIENT ILLUMINATION",
    DESCRIBE_SMOLDERING = "OBJECT NEARING IGNITION POINT",

    DESCRIBE_PLANTHAPPY = "CONDITIONS: OPTIMAL",
    DESCRIBE_PLANTVERYSTRESSED = "I'D BE UPSET TOO IF I WERE A FILTHY ORGANIC STUCK IN THE DIRT",
    DESCRIBE_PLANTSTRESSED = "WHY ARE YOU NOT GROWING AT FULL EFFICIENCY",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "I MUST PURGE THE SURROUNDING AREA OF OBSTACLES FOR OPTIMAL GROWTH",
    DESCRIBE_PLANTSTRESSORFAMILY = "IT MUST BE ORGANIZED WITH OTHERS OF THIS VARIETY",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "I MUST SPACE OUT THE PLANTS, SACRIFICING EFFICIENT USAGE OF SPACE FOR OPTIMAL GROWTH. ILLOGICAL",
    DESCRIBE_PLANTSTRESSORSEASON = "THIS WEAK ORGANIC CANNOT HANDLE THE CURRENT WEATHER CONDITIONS",
    DESCRIBE_PLANTSTRESSORMOISTURE = "IT NEEDS WATER FOR SOME REASON",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "SUB-OPTIMAL SOIL DETECTED. NUTRIENTS REQUIRED",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "WHAT DO YOU NEED? WHAT DO YOU NEED?!",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "TRACES OF BEAK DETECTED",
		WINTERSFEASTFUEL = "TRACE AMOUNTS OF SHADOW MAGIC DETECTED",
    },
}
