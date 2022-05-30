--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Busy",
        },
        REPAIR =
        {
            WRONGPIECE = "Wrong one",
        },
        BUILD =
        {
            MOUNTED = "Not up here",
            HASPET = "Already have Care Friend",
			TICOON = "Already have friend",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Too awake",
			GENERIC = "Hmmm... Can't do",
			NOBITS = "Nothing there",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "Nope. Not mine",
		},
		STORE =
		{
			GENERIC = "Too full",
			NOTALLOWED = "Why can't it go?",
			INUSE = "Someone else's",
            NOTMASTERCHEF = "Not mine",
		},
        CONSTRUCT =
        {
            INUSE = "Someone else's",
            NOTALLOWED = "Nope",
            EMPTY = "Nothing to build with",
            MISMATCH = "Nope",
        },
		RUMMAGE =
		{
			GENERIC = "Nope",
			INUSE = "Friends doing it",
            NOTMASTERCHEF = "Not mine",
		},
		UNLOCK =
        {
        	WRONGKEY = "Wrong key. Oops",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Wrong key. Oops",
        	KLAUS = "Too much danger now!",
			QUAGMIRE_WRONGKEY = "Wrong key. Oops",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Nope. Locked",
            HOSTBUSY = "Big Tweeter busy",
            CARNIVAL_HOST_HERE = "Hello? Big Tweeter here?",
            NOCARNIVAL = "Tweeters? Aww...",
			EMPTY_CATCOONDEN = "No friend inside",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "Not many friends to hide",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "Not many hideys for friends",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "Already had fun",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "Not mine",
			SHADOWMAGIC = "Nope",
		},
        COOK =
        {
            GENERIC = "Can't cook now",
            INUSE = "Someone else using it",
            TOOFAR = "Get closer. Not too close",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Find friends for race",
        },

		DISMANTLE =
		{
			COOKING = "Cooking. Wait",
			INUSE = "Someone else using it",
			NOTEMPTY = "Things inside",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Can't reach Glub Glub",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Not right Glub Glub stick",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "No good",
            DEAD = "They are dead",
            SLEEPING = "Shhh...",
            BUSY = "Busy",
            ABIGAILHEART = "Nope",
            GHOSTHEART = "Not alive",
            NOTGEM = "Won't work",
            WRONGGEM = "Wrong sparkly. Oops",
            NOTSTAFF = "Wrong one. Oops",
            MUSHROOMFARM_NEEDSSHROOM = "Needs Fun Guy Friends",
            MUSHROOMFARM_NEEDSLOG = "Needs friends",
            MUSHROOMFARM_NOMOONALLOWED = "Friends won't live here",
            SLOTFULL = "Too full",
            FOODFULL = "Already has belly stuff",
            NOTDISH = "Not belly stuff",
            DUPLICATE = "Already know it",
            NOTSCULPTABLE = "Can't make with it",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Nope",
            WRONGSHADOWFORM = "Can't do it",
            NOMOON = "Needs Night Ball",
			PIGKINGGAME_MESSY = "Have to clean first",
			PIGKINGGAME_DANGER = "Too much danger!",
			PIGKINGGAME_TOOLATE = "Too late!",
			CARNIVALGAME_INVALID_ITEM = "Not right",
			CARNIVALGAME_ALREADY_PLAYING = "Not yet",
            SPIDERNOHAT = "No room",
            TERRARIUM_REFUSE = "Want something else?",
            TERRARIUM_COOLDOWN = "Friend is away... will come back later?",
        },
        GIVETOPLAYER =
        {
            FULL = "Nope. Too much stuff",
            DEAD = "Nope. Dead now",
            SLEEPING = "After sleeping",
            BUSY = "Nope. Too busy",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "Nope. Too much stuff",
            DEAD = "Nope. Dead now",
            SLEEPING = "After sleeping",
            BUSY = "Nope. Too busy",
        },
        WRITE =
        {
            GENERIC = "Can't write",
            INUSE = "Someone else's",
        },
        DRAW =
        {
            NOIMAGE = "Draw what?",
        },
        CHANGEIN =
        {
            GENERIC = "Not now",
            BURNING = "Fire! Don't like fire!",
            INUSE = "Someone else's",
            NOTENOUGHHAIR = "Not fuzzy enough",
            NOOCCUPANT = "Need Shaggy Buddy.",
        },
        ATTUNE =
        {
            NOHEALTH = "Oooooh. Feeling sick",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Too much fighting!",
            INUSE = "Someone else's",
			SLEEPING = "Upsie daisies!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "Too much fighting!",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Know that already",
            CANTLEARN = "Don't get it",

            --MapRecorder/MapExplorer
            WRONGWORLD = "Not for here",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "Not here",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "What to wrap... What to wrap...",
        },
        PICKUP =
        {
			RESTRICTION = "Nope. Can't use it",
			INUSE = "Someone else's",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Someone else's friend",
                "Not friend",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Nope. Too far",
        },
        REPLATE =
        {
            MISMATCH = "Oops. Wrong food holder",
            SAMEDISH = "Already has food holder",
        },
        SAIL =
        {
        	REPAIR = "Already good",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Why slow down?",
            BAD_TIMING1 = "Row, row-- oh",
            BAD_TIMING2 = "That not right...",
        },
        LOWER_SAIL_FAIL =
        {
            "Oopsy!",
            "Come down here!",
            "Oh no!",
        },
        BATHBOMB =
        {
            GLASSED = "Water too hard",
            ALREADY_BOMBED = "Already has friends",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "Already know it",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "Too small",
            OVERSIZEDVEGGIES_TOO_SMALL = "Not big enough",
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
            GENERIC = "Know already",
            FERTILIZER = "Know all about it",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Bad water for friends",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "All gone",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "No water",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Not working",
            BEEF_BELL_ALREADY_USED = "Not mine",
            BEEF_BELL_HAS_BEEF_ALREADY = "Have Buddy already",
        },
        HITCHUP =
        {
            NEEDBEEF = "Need Shaggy Buddy",
            NEEDBEEF_CLOSER = "Too far",
            BEEF_HITCHED = "Stay",
            INMOOD = "Too cranky!",
        },
        MARK =
        {
            ALREADY_MARKED = "Picked this one",
            NOT_PARTICIPANT = "Have to wait",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Hm...",
            ALREADYACTIVE = "Not here",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "Know it",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Too slow",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "Leggy Bugs don't listen",
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
            COOLDOWN = "only_used_by_wx78",
            NOTENOUGHSLOTS = "only_used_by_wx78",
        },
        REMOVEMODULES =
        {
            NO_MODULES = "only_used_by_wx78",
        },
        CHARGE_FROM =
        {
            NOT_ENOUGH_CHARGE = "only_used_by_wx78",
            CHARGE_FULL = "only_used_by_wx78",
        },

        HARVEST =
        {
            DOER_ISNT_MODULE_OWNER = "Shy?",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Hmm. Need things",
		NO_TECH = "Don't know how",
		NO_STATION = "Can't",
	},

	ACTIONFAIL_GENERIC = "Nope",
	ANNOUNCE_BOAT_LEAK = "Water! Water coming!",
	ANNOUNCE_BOAT_SINK = "Why sinking, Floater?",
	ANNOUNCE_DIG_DISEASE_WARNING = "Poor sick friend", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Ooh. Smells sick", --removed
	ANNOUNCE_ADVENTUREFAIL = "Try again",
    ANNOUNCE_MOUNT_LOWHEALTH = "Riding friend is hurt",

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

	ANNOUNCE_BEES = "Buzz! Buzz!",
	ANNOUNCE_BOOMERANG = "Whoops. Missed it",
	ANNOUNCE_CHARLIE = "Someone here?",
	ANNOUNCE_CHARLIE_ATTACK = "Ouch!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "Brrr... Cold!",
	ANNOUNCE_HOT = "Woo-wee, it's hot!",
	ANNOUNCE_CRAFTING_FAIL = "Failed",
	ANNOUNCE_DEERCLOPS = "Something scary coming!!",
	ANNOUNCE_CAVEIN = "Sky is falling!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"Sinking!",
		"Ground going!",
		"Dirt sinking!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Here you go",
        "For you",
        "Happy? Yes, happy",
	},
	ANNOUNCE_SACREDCHEST_YES = "Said yes!",
	ANNOUNCE_SACREDCHEST_NO = "...Nope",
    ANNOUNCE_DUSK = "Light ball is sleepy",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Tasty",
		PAINFUL = "Ouch",
		SPOILED = "Oooh... hurts",
		STALE = "Food!",
		INVALID = "Can't",
        YUCKY = "Nope",

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
        "Getting heavy...",
        "Little bit further...",
        "Don't give up...",
        "So... heavy",
        "ugh",
        "(grunt, grunt)",
        "oof. Heavy...",
        "Need rest... soon",
        "Keep going...",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Ground shaky",
		"Sky falling!",
		"Not safe!",
	},
    ANNOUNCE_RUINS_RESET = "Oh. Everything back",
    ANNOUNCE_SNARED = "Oh! Caught!",
    ANNOUNCE_SNARED_IVY = "Ha ha! Silly",
    ANNOUNCE_REPELLED = "Didn't hurt?",
	ANNOUNCE_ENTER_DARK = "Too dark",
	ANNOUNCE_ENTER_LIGHT = "It's light again",
	ANNOUNCE_FREEDOM = "Free!",
	ANNOUNCE_HIGHRESEARCH = "Smarter now",
	ANNOUNCE_HOUNDS = "Woofers!",
	ANNOUNCE_WORMS = "Wigglies are coming",
	ANNOUNCE_HUNGRY = "Need stuff for belly",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Prints!",
	ANNOUNCE_HUNT_LOST_TRAIL = "Prints gone",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Prints gone",
	ANNOUNCE_INV_FULL = "Too much stuff",
	ANNOUNCE_KNOCKEDOUT = "Wha--?",
	ANNOUNCE_LOWRESEARCH = "Learned stuff",
	ANNOUNCE_MOSQUITOS = "Bzzt! Bzzt!",
    ANNOUNCE_NOWARDROBEONFIRE = "Fire! Fire!",
    ANNOUNCE_NODANGERGIFT = "Too scary!",
    ANNOUNCE_NOMOUNTEDGIFT = "Get down first",
	ANNOUNCE_NODANGERSLEEP = "Too much danger",
	ANNOUNCE_NODAYSLEEP = "Too bright!",
	ANNOUNCE_NODAYSLEEP_CAVE = "Can't",
	ANNOUNCE_NOHUNGERSLEEP = "Too hungry",
	ANNOUNCE_NOSLEEPONFIRE = "Burning!",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Bright, robot friend! Bright!!",
	ANNOUNCE_NODANGERSIESTA = "Too dangerous",
	ANNOUNCE_NONIGHTSIESTA = "Can't. It's nighttime",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Not in caves",
	ANNOUNCE_NOHUNGERSIESTA = "Too hungry",
	ANNOUNCE_NO_TRAP = "Lucky!",
	ANNOUNCE_PECKED = "Ouch!",
	ANNOUNCE_QUAKE = "Rumbles!",
	ANNOUNCE_RESEARCH = "Smart now",
	ANNOUNCE_SHELTER = "Nice under here",
	ANNOUNCE_THORNS = "Hey! Spiky friends!",
	ANNOUNCE_BURNT = "Agghh! Too much hot!",
	ANNOUNCE_TORCH_OUT = "Oh. Fire stick is out",
	ANNOUNCE_THURIBLE_OUT = "Ran out",
	ANNOUNCE_FAN_OUT = "Wind gone",
    ANNOUNCE_COMPASS_OUT = "Direction Thing broke",
	ANNOUNCE_TRAP_WENT_OFF = "Trap snapped!",
	ANNOUNCE_UNIMPLEMENTED = "Can't do it",
	ANNOUNCE_WORMHOLE = "Urgh",
	ANNOUNCE_TOWNPORTALTELEPORT = "Made it!",
	ANNOUNCE_CANFIX = "\nCan fix it!",
	ANNOUNCE_ACCOMPLISHMENT = "A game!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "Did it! Yay!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Need more poop",
	ANNOUNCE_TOOL_SLIP = "Whoops",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Too close!",
	ANNOUNCE_TOADESCAPING = "Getting away!",
	ANNOUNCE_TOADESCAPED = "Ribbit! Come back!",


	ANNOUNCE_DAMP = "Rain!",
	ANNOUNCE_WET = "Drip drop",
	ANNOUNCE_WETTER = "Water water all around",
	ANNOUNCE_SOAKED = "Big drink!",

	ANNOUNCE_WASHED_ASHORE = "Very wet!",

    ANNOUNCE_DESPAWN = "Don't want to go!",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!",
	ANNOUNCE_GHOSTDRAIN = "What happening?",
	ANNOUNCE_PETRIFED_TREES = "Friends! Friends talking!",
	ANNOUNCE_KLAUS_ENRAGE = "Agh! Run away!",
	ANNOUNCE_KLAUS_UNCHAINED = "Agh! Scary belly mouth!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Oh. Needs friends",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Need to help!",
		GLASS_LOW = "Almost...",
		GLASS_REVEAL = "Free!",
		IDOL_MED = "Need to help!",
		IDOL_LOW = "Almost...",
		IDOL_REVEAL = "Free!",
		SEED_MED = "Need to help!",
		SEED_LOW = "Almost...",
		SEED_REVEAL = "Free!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Scary!",
	ANNOUNCE_BRAVERY_POTION = "Feeling strong!",
	ANNOUNCE_MOONPOTION_FAILED = "No work",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Friends might like?",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Oooooh",
	ANNOUNCE_IS_FEASTING = "Fill belly with good belly stuff",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Gone",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Helping...",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Made better",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Thank you!",

    ANNOUNCE_FLARE_SEEN = "See friend make pretty light.",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Water friend?",

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
    ANNOUNCE_KILLEDPLANT =
    {
        "Sorry, friend",
        "Don't like hurting friend",
        "Friends don't like that",
    },
    ANNOUNCE_GROWPLANT =
    {
        "Grow!",
        "New friend!",
        "Happy Birthday!",
    },
    ANNOUNCE_BLOOMING =
    {
        "Feeling bloomy!",
    },

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
    ANNOUNCE_WX_SCANNER_NEW_FOUND = "only_used_by_wx78",
--fallback to speech_wilson.lua     ANNOUNCE_WX_SCANNER_FOUND_NO_DATA = "only_used_by_wx78",

    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Oops. Not good belly stuff",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Burnt. Oh",
    QUAGMIRE_ANNOUNCE_LOSE = "Didn't win. Oh",
    QUAGMIRE_ANNOUNCE_WIN = "Yay! Did it!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "Zap! Zap, Zap!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Feel stronger!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "Hmm, bark feel thicker!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Faster gooder!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "No more wet!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Awake!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Aww. No more zaps",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Feel less fighty now",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Back to normal",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Tired now",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Water back!",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "Bit sleepy...",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Oh!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "Too loose?",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "Too bad",
	ANNOUNCE_OCEANFISHING_BADCAST = "Will try again",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Waiting...",
		"Hm...",
		"Glub Glubs?",
		"Not yet",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nHeavy",

	ANNOUNCE_WINCH_CLAW_MISS = "Oh. Missed",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "Nothing",

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
    ANNOUNCE_WEAK_RAT = "Tired",

    ANNOUNCE_CARRAT_START_RACE = "Go!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Not right",
        "Wrong way",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Tired",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Too slow",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "Confused?",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Ouch! Oooooh...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Oooooh, pictures!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "Know it",
    ANNOUNCE_ARCHIVE_NO_POWER = "Nope",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "Learning lots about friend",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "Who it going to be?",

    ANNOUNCE_FERTILIZER_RESEARCHED = "Learning about bellystuff",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"not_used_by_wormwood",
		"not_used_by_wormwood",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Feel better",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Hello friend!",
        "Is friend happy? Yay!",
		"Hehe, friend has best jokes",
        "Yes? Oh. Hmm... yes",
        "Nice to talk to other plants",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Friends hiding now",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Looking for friends too",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Found you",
		"Peek-a-boo",
		"Hello there",
		"Hi hi",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "Just one friend left",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "Last friend found",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "Someone found last friend",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Find friends fast",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Friends hide too good",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "Friends not hiding here",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Going back to friends",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Friend not in hidey?",

	ANNOUNCE_TICOON_START_TRACKING	= "Looking for friends?",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "No friend to find",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "He's waiting",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Should follow",
	ANNOUNCE_TICOON_NEAR_KITCOON = "Friend nearby",
	ANNOUNCE_TICOON_LOST_KITCOON = "Friend already found",
	ANNOUNCE_TICOON_ABANDONED = "Friend left me",
	ANNOUNCE_TICOON_DEAD = "Friend left?",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Here Shaggy Buddy!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "Too far for contest",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Ooooh! Make new thing",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Big peeper peeping!",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Big peeper back!",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Where going?",

	BATTLECRY =
	{
		GENERIC = "Attack!",
		PIG = "Attack!",
		PREY = "Attack!",
		SPIDER = "Attack!",
		SPIDER_WARRIOR = "Attack!",
		DEER = "Attack!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Don't want to fight",
		PIG = "Don't want to fight",
		PREY = "Don't want to fight",
		SPIDER = "Don't want to fight",
		SPIDER_WARRIOR = "Don't want to fight",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Hmm... new door",
        MULTIPLAYER_PORTAL_MOONROCK = "Glowy. Like Night Ball",
        MOONROCKIDOL = "Oh. Hello",
        CONSTRUCTION_PLANS = "Door plans",

        ANTLION =
        {
            GENERIC = "Hello!",
            VERYHAPPY = "Happy Roar Bug!",
            UNHAPPY = "Oh no. Needs gifts",
        },
        ANTLIONTRINKET = "Gift!",
        SANDSPIKE = "Oh. Ouch!",
        SANDBLOCK = "Can play with it?",
        GLASSSPIKE = "Clear Rock Pricker",
        GLASSBLOCK = "Pretty burnt sand",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Friend?",
			LEVEL1 = "Hello there!",
			LEVEL2 = "Growing",
			LEVEL3 = "Floaty friend!",

			-- deprecated
            LONG = "Sleeping",
            MEDIUM = "Hello there!",
            SOON = "Ready!",
            HAUNTED_POCKET = "Jumpy pocket",
            HAUNTED_GROUND = "Ghost friend",
        },

        BALLOONS_EMPTY = "Needs air",
        BALLOON = "Boop",
		BALLOONPARTY = "Fun!",
		BALLOONSPEED =
        {
            DEFLATED = "Boop",
            GENERIC = "Run run run!",
        },
		BALLOONVEST = "Safe?",
		BALLOONHAT = "Squee Hopper? Hm. No",

        BERNIE_INACTIVE =
        {
            BROKEN = "What happened?",
            GENERIC = "Hello, Squishy Friend!",
        },

        BERNIE_ACTIVE = "Yay! Squishy Friend can play!",
        BERNIE_BIG = "Big Squishy Friend!",

        BOOK_BIRDS = "Pretty pictures",
        BOOK_TENTACLES = "About Scary Arms",
        BOOK_GARDENING = "This one's nice",
		BOOK_SILVICULTURE = "About friends!",
		BOOK_HORTICULTURE = "This one's nice",
        BOOK_SLEEP = "(yawn)",
        BOOK_BRIMSTONE = "Fire!",

        PLAYER =
        {
            GENERIC = "Hello, %s!",
            ATTACKER = "Bad! Bad %s!",
            MURDERER = "Killing bad!",
            REVIVER = "Good helper",
            GHOST = "Need help?",
            FIRESTARTER = "Fire maker! Fire bad!",
        },
        WILSON =
        {
            GENERIC = "Hello, Science man!",
            ATTACKER = "%s! Stop hurting!",
            MURDERER = "Bad %s. Don't kill!",
            REVIVER = "Yay! Made Floaty Friend solid again!",
            GHOST = "You okay, %s?",
            FIRESTARTER = "No! No fire!",
        },
        WOLFGANG =
        {
            GENERIC = "%s is big muscle man!",
            ATTACKER = "Don't hurt! Hurting bad!",
            MURDERER = "Killer! Bad!",
            REVIVER = "Good, %s!",
            GHOST = "Oh. %s is Floaty Friend now",
            FIRESTARTER = "Fire! Don't like fire!",
        },
        WAXWELL =
        {
            GENERIC = "Oh. %s looks frowny",
            ATTACKER = "Not nice, %s!",
            MURDERER = "Bad %s. Make not alive!",
            REVIVER = "Thank you, %s!",
            GHOST = "You okay, %s?",
            FIRESTARTER = "%s made too much fire!",
        },
        WX78 =
        {
            GENERIC = "%s is robot friend",
            ATTACKER = "Bad %s likes to hurt!",
            MURDERER = "%s is bad robot. Bad!",
            REVIVER = "%s is nice robot",
            GHOST = "Like being floaty, %s?",
            FIRESTARTER = "%s made too much fire!",
        },
        WILLOW =
        {
            GENERIC = "Oh. %s likes fire",
            ATTACKER = "Don't hurt, %s!",
            MURDERER = "Killing bad, %s!",
            REVIVER = "%s is helping friend",
            GHOST = "Oh. Need help?",
            FIRESTARTER = "Made too much fire, %s!",
        },
        WENDY =
        {
            GENERIC = "%s has Floaty Sister friend",
            ATTACKER = "Why, %s? Why hurting?!",
            MURDERER = "No! Making dead friends is bad!",
            REVIVER = "Friend %s is good",
            GHOST = "Now %s is like Floaty Sister",
            FIRESTARTER = "Don't like fire!",
        },
        WOODIE =
        {
            GENERIC = "Keep axe friend away, please",
            ATTACKER = "Bad %s!",
            MURDERER = "No killing!",
            REVIVER = "%s is a make betterer",
            GHOST = "Hello, Floaty Friend",
            BEAVER = "Friend Eater! Keep away!",
            BEAVERGHOST = "Can't eat friends anymore",
            MOOSE = "Like Branch Head better than Friend Eater.",
            MOOSEGHOST = "Branch Head friend is floaty!",
            GOOSE = "Oh. Friend made small!",
            GOOSEGHOST = "Hello floaty friend!",
            FIRESTARTER = "No! Fire hurts!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "%s is good book friend",
            ATTACKER = "%s is bad book friend",
            MURDERER = "No! Don't make friends dead!",
            REVIVER = "%s is good",
            GHOST = "Like floating, %s?",
            FIRESTARTER = "Aggh! Made too much fire!",
        },
        WES =
        {
            GENERIC = "%s is quiet friend",
            ATTACKER = "Bad %s! Don't hurt!",
            MURDERER = "%s is silent dead maker",
            REVIVER = "%s is a good friend",
            GHOST = "%s is a quiet floaty",
            FIRESTARTER = "Aggh! %s made too much fire!",
        },
        WEBBER =
        {
            GENERIC = "Hello Leggy Bug friend!",
            ATTACKER = "No! Hurting bad!",
            MURDERER = "Bad! Made friends not alive",
            REVIVER = "%s is friend fixer",
            GHOST = "Like being floaty, %s?",
            FIRESTARTER = "Fire bad, %s! Fire bad!",
        },
        WATHGRITHR =
        {
            GENERIC = "%s is strong friend",
            ATTACKER = "Bad %s! Don't hurt!",
            MURDERER = "%s is bad!",
            REVIVER = "%s is good Floaty Friend fixer",
            GHOST = "Oh. Hello, Floaty Friend!",
            FIRESTARTER = "Too much fire! Too much!",
        },
        WINONA =
        {
            GENERIC = "%s is good Fixer",
            ATTACKER = "No! Hurt too much!",
            MURDERER = "Aggh! %s is a dead maker!",
            REVIVER = "Good friend. Helping",
            GHOST = "Need help, %s?",
            FIRESTARTER = "Too much fire, %s!",
        },
        WORTOX =
        {
            GENERIC = "Nice head branches %s!",
            ATTACKER = "Bad! Hurt too much!",
            MURDERER = "%s made friends dead!",
            REVIVER = "%s is good friend",
            GHOST = "Oh. Need help?",
            FIRESTARTER = "Agh! Fire maker!",
        },
        WORMWOOD =
        {
            GENERIC = "Looking good, Friend!",
            ATTACKER = "Why so hurty, %s?",
            MURDERER = "No! Bad %s!",
            REVIVER = "%s makes friends well again!",
            GHOST = "Oh. That you, %s?",
            FIRESTARTER = "Why make so much fire?!",
        },
        WARLY =
        {
            GENERIC = "Friend that makes tummy happy",
            ATTACKER = "Friend make lots of Ouch!",
            MURDERER = "Do not eat friends!",
            REVIVER = "Thank you, friend %s!",
            GHOST = "%s needs help!",
            FIRESTARTER = "Ah! %s make scary burnies!",
        },

        WURT =
        {
            GENERIC = "Hello scaly friend!",
            ATTACKER = "Not very nice, %s",
            MURDERER = "%s kill! Very bad!",
            REVIVER = "You good helper",
            GHOST = "Oh. Need heart?",
            FIRESTARTER = "Ah! Why start fires, %s?",
        },

        WALTER =
        {
            GENERIC = "%s is helpful friend",
            ATTACKER = "Ah! Why you hurt friend?",
            MURDERER = "%s do bad thing!",
            REVIVER = "%s is very good",
            GHOST = "Oh. %s having fun?",
            FIRESTARTER = "No! Stop %s!",
        },

        WANDA =
        {
            GENERIC = "Friend keeps changing",
            ATTACKER = "Don't make hurt, %s!",
            MURDERER = "Why make friends dead? %s bad!",
            REVIVER = "%s is nice friend",
            GHOST = "Is %s? Need helping?",
            FIRESTARTER = "No fire, %s! No fire!",
        },

        MIGRATION_PORTAL =
        {
        --    GENERIC = "If I had any friends, this could take me to them.",
        --    OPEN = "If I step through, will I still be me?",
        --    FULL = "It seems to be popular over there.",
        },
        GLOMMER =
        {
            GENERIC = "You're nice. Stay close",
            SLEEPING = "Shh...",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Moon Flower",
            DEAD = "Poor friend...",
        },
        GLOMMERWINGS = "So teeny",
        GLOMMERFUEL = "Yum! (urp)",
        BELL = "Ding! Dong!",
        STATUEGLOMMER =
        {
            GENERIC = "That you, nice friend?",
            EMPTY = "Gone",
        },

        LAVA_POND_ROCK = "Rock",

		WEBBERSKULL = "Oh. Oh dear",
		WORMLIGHT = "Shiny...",
		WORMLIGHT_LESSER = "Still good",
		WORM =
		{
		    PLANT = "Hmm... not safe",
		    DIRT = "Something hiding",
		    WORM = "Hello, Wiggly!",
		},
        WORMLIGHT_PLANT = "Hmm... not safe",
		MOLE =
		{
			HELD = "It's wiggling",
			UNDERGROUND = "Smelly Digger is hiding",
			ABOVEGROUND = "Smelly Digger!",
		},
		MOLEHILL = "You okay, dirt?",
		MOLEHAT = "A Smelly Digger hat",

		EEL = "Sea Wiggly",
		EEL_COOKED = "Not wiggly anymore",
		UNAGI = "Sea Wiggly wiggles in belly",
		EYETURRET = "Pew!",
		EYETURRET_ITEM = "Pew Pew rock",
		MINOTAURHORN = "Ouch!",
		MINOTAURCHEST = "Lots of stuff!",
		THULECITE_PIECES = "Old rocks",
		POND_ALGAE = "Nice day for a swim?",
		GREENSTAFF = "A Take Apart Stick",
		GIFT = "Give to friends!",
        GIFTWRAP = "Fun wrapping time!",
		POTTEDFERN = "Stay. Good boy",
        SUCCULENT_POTTED = "Found friend a home",
		SUCCULENT_PLANT = "Friend! Good to see you!",
		SUCCULENT_PICKED = "Keep you safe, friend",
		SENTRYWARD = "Sparkly Stone see far!",
        TOWNPORTAL =
        {
			GENERIC = "Friend poofer",
			ACTIVE = "Can poof to friends now!",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "Sandy rock",
			ACTIVE = "Can poof now!",
		},
        WETPAPER = "Soppy paper",
        WETPOUCH = "Soppy pocket",
        MOONROCK_PIECES = "From Night ball?",
        MOONBASE =
        {
            GENERIC = "Does it work?",
            BROKEN = "Needs fixes",
            STAFFED = "Hmm... What's happening?",
            WRONGSTAFF = "Nope",
            MOONSTAFF = "Stick makes light!",
        },
        MOONDIAL =
        {
			GENERIC = "Night Ball looker",
			NIGHT_NEW = "No Night Ball",
			NIGHT_WAX = "Night Ball getting bigger",
			NIGHT_FULL = "Big Night Ball!",
			NIGHT_WANE = "Night Ball getting smaller",
			CAVE = "Oh. No Night Ball here",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "Hello!",
        },
		THULECITE = "Rocks from old times",
		ARMORRUINS = "Heavy clothes",
		ARMORSKELETON = "Magic bones",
		SKELETONHAT = "Scary head",
		RUINS_BAT = "Old Rock Whacker",
		RUINSHAT = "Weighs down head",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Quiet now",
            WARN = "Something happening...",
            WAXING = "Getting scary",
            STEADY = "Bad! Really bad!",
            WANING = "Getting better",
            DAWN = "Whew",
            NOMAGIC = "Safe here",
		},
		BISHOP_NIGHTMARE = "Hurt",
		ROOK_NIGHTMARE = "Run down",
		KNIGHT_NIGHTMARE = "Busted",
		MINOTAUR = "Don't want to fight!",
		SPIDER_DROPPER = "Aggh! Scary!",
		NIGHTMARELIGHT = "Night light for scary times",
		NIGHTSTICK = "A Light Ball Stick",
		GREENGEM = "Looks familiar...",
		MULTITOOL_AXE_PICKAXE = "Handy stick",
		ORANGESTAFF = "Poof stick",
		YELLOWAMULET = "Can go zoomy now!",
		GREENAMULET = "Helps for building",
		SLURPERPELT = "(sigh) Sad",

		SLURPER = "Furry Head Eater",
		SLURPER_PELT = "(sigh) Sad",
		ARMORSLURPER = "Furry Belt. Looks good",
		ORANGEAMULET = "Picker Upper",
		YELLOWSTAFF = "Zoom Stick",
		YELLOWGEM = "Ohhh. Shiny...",
		ORANGEGEM = "Helper Shiny",
        OPALSTAFF = "Oh! Stick is cold",
        OPALPRECIOUSGEM = "Pretty, pretty shiny",
        TELEBASE =
		{
			VALID = "Ready",
			GEMS = "Needs Purple Shiny",
		},
		GEMSOCKET =
		{
			VALID = "Ready",
			GEMS = "Where shiny things?",
		},
		STAFFLIGHT = "Bright!! Very bright!",
        STAFFCOLDLIGHT = "Oh! Cold stick makes light!",

        ANCIENT_ALTAR = "Makes more things!",

        ANCIENT_ALTAR_BROKEN = "Broken. Needs old stones",

        ANCIENT_STATUE = "Alive? Hmmm...",

        LICHEN = "Rock belly stuff",
		CUTLICHEN = "Smells good",

		CAVE_BANANA = "Mmmmm...",
		CAVE_BANANA_COOKED = "Smokey",
		CAVE_BANANA_TREE = "Friend with Sweet Hair",
		ROCKY = "Rock Pinchy",

		COMPASS =
		{
			GENERIC="Which way?",
			N = "North",
			S = "South",
			E = "East",
			W = "West",
			NE = "Northeast",
			SE = "Southeast",
			NW = "Northwest",
			SW = "Southwest",
		},

        HOUNDSTOOTH = "Sharp. Ouch!",
        ARMORSNURTLESHELL = "Anyone hiding?",
        BAT = "Flying Claws!",
        BATBAT = "Flying Claw Whacker",
        BATWING = "Can't fly anymore",
        BATWING_COOKED = "Little chewy. And claw-y",
        BATCAVE = "Smells good!",
        BEDROLL_FURRY = "Furry for sleepytime",
        BUNNYMAN = "Wants belly things",
        FLOWER_CAVE = "Glowy Friend",
        GUANO = "Good poop!",
        LANTERN = "Carry light",
        LIGHTBULB = "Glowy food",
        MANRABBIT_TAIL = "Fluffy. And soft",
        MUSHROOMHAT = "Haha! Friend hat!",
        MUSHROOM_LIGHT2 =
        {
            ON = "Oh! Colors pretty",
            OFF = "Hello friends!",
            BURNT = "Oh. Oh dear",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Glow friends! Hi!",
            OFF = "Oh. Where's light?",
            BURNT = "Oh. Oh dear",
        },
        SLEEPBOMB = "Bag of sleepytime",
        MUSHROOMBOMB = "Oh. Smells explody",
        SHROOM_SKIN = "Oh. Friends missing clothes",
        TOADSTOOL_CAP =
        {
            EMPTY = "Gone",
            INGROUND = "Hiding",
            GENERIC = "Hi friend!",
        },
        TOADSTOOL =
        {
            GENERIC = "Ribbit giving friends a ride!",
            RAGE = "Uh oh",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Hello!",
            BURNT = "Oh...",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "Growing nicely",
            BLOOM = "Pretty!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Fun guy",
            BLOOM = "Fancy!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Hi there!",
            BLOOM = "Looking good",
        },
        MUSHTREE_TALL_WEBBED = "It's trapped!",
        SPORE_TALL =
        {
            GENERIC = "Where you going?",
            HELD = "Glowing babies",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "So cute!",
            HELD = "Coochy-coo!",
        },
        SPORE_SMALL =
        {
            GENERIC = "Hey little guys!",
            HELD = "Safe now",
        },
        RABBITHOUSE =
        {
            GENERIC = "Big Squee Hopper home",
            BURNT = "Bad fire! Bad!",
        },
        SLURTLE = "Shy Spiky Shell",
        SLURTLE_SHELLPIECES = "Spiky Shell bits",
        SLURTLEHAT = "Hard Head Thing",
        SLURTLEHOLE = "Spiky Shell home",
        SLURTLESLIME = "For hungry machines",
        SNURTLE = "Not Spiky Shell",
        SPIDER_HIDER = "Shy?",
        SPIDER_SPITTER = "Patuey!",
        SPIDERHOLE = "Something hiding?",
        SPIDERHOLE_ROCK = "What's in there?",
        STALAGMITE = "Rocks",
        STALAGMITE_TALL = "Rock",

        TURF_CARPETFLOOR = "Not dirt",
        TURF_CHECKERFLOOR = "Not dirt",
        TURF_DIRT = "Dirt!",
        TURF_FOREST = "Dirt!",
        TURF_GRASS = "Soft!",
        TURF_MARSH = "Squishy",
        TURF_METEOR = "Rocky",
        TURF_PEBBLEBEACH = "Tiny rocks",
        TURF_ROAD = "Not dirt",
        TURF_ROCKY = "Not dirt",
        TURF_SAVANNA = "Full of friends",
        TURF_WOODFLOOR = "Not dirt",

		TURF_CAVE="Rocky",
		TURF_FUNGUS="Mushy",
		TURF_FUNGUS_MOON = "Mushy",
		TURF_ARCHIVE = "Not dirt",
		TURF_SINKHOLE="Slimy",
		TURF_UNDERROCK="Too rocky",
		TURF_MUD="Sticky",

		TURF_DECIDUOUS = "Nice dirt",
		TURF_SANDY = "Sandy",
		TURF_BADLANDS = "Dirt",
		TURF_DESERTDIRT = "Sand",
		TURF_FUNGUS_GREEN = "Squishy",
		TURF_FUNGUS_RED = "Squashy",
		TURF_DRAGONFLY = "Fire can't come here!",

        TURF_SHELLBEACH = "Sand",

		POWCAKE = "Ka-pow!",
        CAVE_ENTRANCE = "Goes somewhere",
        CAVE_ENTRANCE_RUINS = "Goes somewhere",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Closed",
            OPEN = "Open now",
            FULL = "Can't go there",
        },
        CAVE_EXIT =
        {
            GENERIC = "Closed",
            OPEN = "Open",
            FULL = "Can't go there",
        },

		MAXWELLPHONOGRAPH = "Can't dance to it",--single player
		BOOMERANG = "Returny Stick",
		PIGGUARD = "Twirly Tail Tough Guy",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Floaty Friend",
                "Floaty Friend",
            },
            LEVEL2 =
            {
                "Floaty Friend",
                "Floaty Friend",
            },
            LEVEL3 =
            {
                "Floaty Friend",
                "Floaty Friend",
            },
		},
		ADVENTURE_PORTAL = "Adventure?",
		AMULET = "Yay! More life!",
		ANIMAL_TRACK = "Mystery Prints!",
		ARMORGRASS = "Friend Hair made clothes",
		ARMORMARBLE = "Heavy",
		ARMORWOOD = "Friend Shirt",
		ARMOR_SANITY = "Brain Guard",
		ASH =
		{
			GENERIC = "Something burned",
			REMAINS_GLOMMERFLOWER = "Oh",
			REMAINS_EYE_BONE = "All gone",
			REMAINS_THINGIE = "Gone",
		},
		AXE = "Hurts friends (sob)",
		BABYBEEFALO =
		{
			GENERIC = "Needs more fur",
		    SLEEPING = "Shh...",
        },
        BUNDLE = "Stuff inside",
        BUNDLEWRAP = "Put stuff inside",
		BACKPACK = "For more things carrying",
		BACONEGGS = "Belly filler",
		BANDAGE = "Sweet Heal Paper",
		BASALT = "Too heavy", --removed
		BEARDHAIR = "Fuzzy",
		BEARGER = "Mad Molter",
		BEARGERVEST = "Warm. Cozy",
		ICEPACK = "Not good for rot",
		BEARGER_FUR = "Poor guy",
		BEDROLL_STRAW = "For sleepytime",
		BEEQUEEN = "Big Mommy Buzz!",
		BEEQUEENHIVE =
		{
			GENERIC = "Full of Buzz Juice",
			GROWING = "Getting bigger!",
		},
        BEEQUEENHIVEGROWN = "Big Buzz home!",
        BEEGUARD = "Oh. Scary Buzz",
        HIVEHAT = "Hehe. Funny Branch Hat",
        MINISIGN =
        {
            GENERIC = "Pretty picture",
            UNDRAWN = "Needs pretty picture",
        },
        MINISIGN_ITEM = "Needs ground",
		BEE =
		{
			GENERIC = "Buzz!",
			HELD = "Needs home",
		},
		BEEBOX =
		{
			READY = "Buzz Juice ready!",
			FULLHONEY = "Buzz Juice ready!",
			GENERIC = "Buzz home!",
			NOHONEY = "Empty",
			SOMEHONEY = "Wait",
			BURNT = "Fire breaks everything",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Party!",
			LOTS = "Lots of new friends!",
			SOME = "Hello, little friends!",
			EMPTY = "What happened, friend?",
			ROTTEN = "Oh. So sorry",
			BURNT = "Fire is bad",
			SNOWCOVERED = "Too cold?",
		},
		BEEFALO =
		{
			FOLLOWER = "Looking for belly stuff",
			GENERIC = "Shaggy Buddy",
			NAKED = "Bald",
			SLEEPING = "Shh... Don't wake it",
            --Domesticated states:
            DOMESTICATED = "A pet now",
            ORNERY = "Cranky",
            RIDER = "Can ride now",
            PUDGY = "Full belly",
            MYPARTNER = "Shaggy Buddy is friend",
		},

		BEEFALOHAT = "Warm",
		BEEFALOWOOL = "Buddy hair",
		BEEHAT = "Looks good",
        BEESWAX = "Buzz Blocks",
		BEEHIVE = "Buzz Home",
		BEEMINE = "Buzz Ka-bloey",
		BEEMINE_MAXWELL = "It's buzzing...",--removed
		BERRIES = "Tiny little belly fillers",
		BERRIES_COOKED = "Slurp!",
        BERRIES_JUICY = "Tiny squishy belly fillers",
        BERRIES_JUICY_COOKED = "Squish, squish!",
		BERRYBUSH =
		{
			BARREN = "Needs poop",
			WITHERED = "Poor guy",
			GENERIC = "Full of stuff for belly",
			PICKED = "Belly fillers will grow back",
			DISEASED = "Sick! Very, very sick!",--removed
			DISEASING = "You sick, friend?",--removed
			BURNING = "Oh! Oh no!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Needs poop",
			WITHERED = "Too hot, friend?",
			GENERIC = "Full of belly fillers!",
			PICKED = "Oh. Out of belly fillers",
			DISEASED = "Oh! Friend got sick!",--removed
			DISEASING = "Get well soon",--removed
			BURNING = "Oh! Stop! Stop!",
		},
		BIGFOOT = "Smelly Stomper",--removed
		BIRDCAGE =
		{
			GENERIC = "Needs a friend",
			OCCUPIED = "Tweet! Tweet!",
			SLEEPING = "Sleep well, Tweeter",
			HUNGRY = "Hungry?",
			STARVING = "Needs food!",
			DEAD = "Oh. Whoops",
			SKELETON = "(sigh)",
		},
		BIRDTRAP = "Tweeter Nabber",
		CAVE_BANANA_BURNT = "Smokey",
		BIRD_EGG = "Baby Tweeter",
		BIRD_EGG_COOKED = "Goes in belly",
		BISHOP = "A Pointy Hat Machine Man!",
		BLOWDART_FIRE = "Fire Ptooey",
		BLOWDART_SLEEP = "Sleepytime Ptooey",
		BLOWDART_PIPE = "Ptooey stick",
		BLOWDART_YELLOW = "Zzzt Ptooey",
		BLUEAMULET = "Cold Neck Thing",
		BLUEGEM = "Makes the cold",
		BLUEPRINT =
		{
            COMMON = "Paper for stuff making",
            RARE = "Ohhhh... Looks important",
        },
        SKETCH = "Pretty picture",
		BLUE_CAP = "Hurts head. Ow!",
		BLUE_CAP_COOKED = "Helps head. Ahhh...",
		BLUE_MUSHROOM =
		{
			GENERIC = "Little blue friend!",
			INGROUND = "He's shy",
			PICKED = "All gone",
		},
		BOARDS = "Fallen friends",
		BONESHARD = "Sharp. Ouch!",
		BONESTEW = "Pot of lots of meat",
		BUGNET = "Bzzt Catcher",
		BUSHHAT = "Friend costume",
		BUTTER = "Where are wings?",
		BUTTERFLY =
		{
			GENERIC = "A friend for friends",
			HELD = "Flappy",
		},
		BUTTERFLYMUFFIN = "Yummm...",
		BUTTERFLYWINGS = "Can fly with it? No",
		BUZZARD = "Meat Tweeter",

		SHADOWDIGGER = "Dark Floaty Digger",

		CACTUS =
		{
			GENERIC = "Ouch Friend",
			PICKED = "Grow, Ouch Friend! Grow!",
		},
		CACTUS_MEAT_COOKED = "Will eat it",
		CACTUS_MEAT = "Mmm... belly stuff",
		CACTUS_FLOWER = "Yum",

		COLDFIRE =
		{
			EMBERS = "Almost gone",
			GENERIC = "Chilly",
			HIGH = "Really big!",
			LOW = "Cool",
			NORMAL = "Cooling",
			OUT = "Needs food",
		},
		CAMPFIRE =
		{
			EMBERS = "Dying",
			GENERIC = "Not too close",
			HIGH = "Too high!",
			LOW = "Stay back",
			NORMAL = "Not too close",
			OUT = "Whew!",
		},
		CANE = "Friend for walking",
		CATCOON = "Hello, Kitty!",
		CATCOONDEN =
		{
			GENERIC = "Anyone home?",
			EMPTY = "No more Kitties",
		},
		CATCOONHAT = "Kitty thing for head",
		COONTAIL = "Poor little Kitty",
		CARROT = "Thanks, dirt!",
		CARROT_COOKED = "Tiny circles for belly",
		CARROT_PLANTED = "Nice growing! Keep going!",
		CARROT_SEEDS = "Makes the orange belly stuff",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Needs Findy Paper",
			BURNING = "No! Fire! Fire!",
			BURNT = "Oh. Oh no",
		},
		WATERMELON_SEEDS = "Makes Water Fruit!",
		CAVE_FERN = "How you doing?",
		CHARCOAL = "Burnt rock",
        CHESSPIECE_PAWN = "Nice head thing!",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Home? Not home",
            STRUGGLE = "Alive?",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "Stone Neigher!",
            STRUGGLE = "What's happening?",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Like Pointy Head thing",
            STRUGGLE = "Strange things happening!",
        },
        CHESSPIECE_MUSE = "Pretty Stone",
        CHESSPIECE_FORMAL = "Where head?",
        CHESSPIECE_HORNUCOPIA = "Not for belly",
        CHESSPIECE_PIPE = "Bubbles!",
        CHESSPIECE_DEERCLOPS = "Oh. Where legs?",
        CHESSPIECE_BEARGER = "Not so smelly now",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Oh. Tweeter can't tweet now",
        },
        CHESSPIECE_DRAGONFLY = "Only stone fire now",
		CHESSPIECE_MINOTAUR = "Scary",
        CHESSPIECE_BUTTERFLY = "Can't fly like that",
        CHESSPIECE_ANCHOR = "Heavy",
        CHESSPIECE_MOON = "Night Ball broken",
        CHESSPIECE_CARRAT = "Friends!",
        CHESSPIECE_MALBATROSS = "Bad Tweeter",
        CHESSPIECE_CRABKING = "Snip snap!",
        CHESSPIECE_TOADSTOOL = "Alive? Nope",
        CHESSPIECE_STALKER = "Hello? Hello?",
        CHESSPIECE_KLAUS = "Not squishy",
        CHESSPIECE_BEEQUEEN = "No more buzz-buzz",
        CHESSPIECE_ANTLION = "Not moving",
        CHESSPIECE_BEEFALO = "Not fluffy...",
		CHESSPIECE_KITCOON = "Not hiding?",
		CHESSPIECE_CATCOON = "No tail swish swoosh",
        CHESSPIECE_GUARDIANPHASE3 = "Big",
        CHESSPIECE_EYEOFTERROR = "Not watching?",
        CHESSPIECE_TWINSOFTERROR = "Can't see now",

        CHESSJUNK1 = "Machine stuff",
        CHESSJUNK2 = "Lots of machine stuff",
        CHESSJUNK3 = "Full of machine stuff",
		CHESTER = "Carries stuff. Thank you!",
		CHESTER_EYEBONE =
		{
			GENERIC = "Blinky!",
			WAITING = "Sleeping. Shh...",
		},
		COOKEDMANDRAKE = "Smells sleepy",
		COOKEDMEAT = "Yummm",
		COOKEDMONSTERMEAT = "Smells bad",
		COOKEDSMALLMEAT = "Little belly stuff",
		COOKPOT =
		{
			COOKING_LONG = "Waiting...",
			COOKING_SHORT = "Done soon",
			DONE = "Done!",
			EMPTY = "Nothing there",
			BURNT = "Oh",
		},
		CORN = "Tiny seeds good for belly",
		CORN_COOKED = "Pop! Pop!",
		CORN_SEEDS = "Dirt likes these",
        CANARY =
		{
			GENERIC = "Boom Tweeter",
			HELD = "Hello. Friend?",
		},
        CANARY_POISONED = "Oh. Oh no",

		CRITTERLAB = "Little friends hiding inside",
        CRITTER_GLOMLING = "Little Bounce Bounce Friend",
        CRITTER_DRAGONLING = "Hi, Little Patuey!",
		CRITTER_LAMB = "Tiny Horkbeast is friend",
        CRITTER_PUPPY = "Little Woofer! Woof!",
        CRITTER_KITTEN = "Me-Raow, Teeny Kitkit",
        CRITTER_PERDLING = "Wee Tweeter is friend now",
		CRITTER_LUNARMOTHLING = "Flap flap Flappy friend",

		CROW =
		{
			GENERIC = "Caw Tweeter!",
			HELD = "Needs a home",
		},
		CUTGRASS = "Hair from friends!",
		CUTREEDS = "Hair cut",
		CUTSTONE = "Square stones",
		DEADLYFEAST = "Nope", --unimplemented
		DEER =
		{
			GENERIC = "Where eyes?",
			ANTLER = "Like your branches!",
		},
        DEER_ANTLER = "Like your branches!",
        DEER_GEMMED = "Ohhh... Sparkly eye",
		DEERCLOPS = "Branch Head",
		DEERCLOPS_EYEBALL = "(poke)",
		EYEBRELLAHAT =	"Peeping Rain Taker",
		DEPLETED_GRASS =
		{
			GENERIC = "Needs poop",
		},
        GOGGLESHAT = "More eyes for head?",
        DESERTHAT = "Funny eyes. Like it",
		DEVTOOL = "Strange",
		DEVTOOL_NODEV = "Can't",
		DIRTPILE = "What's hiding?",
		DIVININGROD =
		{
			COLD = "It's quiet", --singleplayer
			GENERIC = "Leads to somewhere", --singleplayer
			HOT = "It's LOUD!", --singleplayer
			WARM = "Humming", --singleplayer
			WARMER = "More humming!", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "Hmm...", --singleplayer
			READY = "Needs key", --singleplayer
			UNLOCKED = "Works!", --singleplayer
		},
		DIVININGRODSTART = "Stick", --singleplayer
		DRAGONFLY = "Patuey Fly",
		ARMORDRAGONFLY = "Fire Keeper Outer",
		DRAGON_SCALES = "Fiery clothes",
		DRAGONFLYCHEST = "Fire Safe",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "Just stuff now",
			GENERIC = "Not working", --no gems
			NORMAL = "Needs more sparkly", --one gem
			HIGH = "Hot! So hot!", --two gems
		},

        HUTCH = "Glub Glub Lugger",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Making friends!",
            WAITING = "Can swim on back?",
        },
		LAVASPIT =
		{
			HOT = "Yeouch!",
			COOL = "Cooled down",
		},
		LAVA_POND = "Earth Blood. Hot!",
		LAVAE = "Too hot!",
		LAVAE_COCOON = "Nice and warm?",
		LAVAE_PET =
		{
			STARVING = "Needs ashes",
			HUNGRY = "Hungry?",
			CONTENT = "Happy",
			GENERIC = "Hot!",
		},
		LAVAE_EGG =
		{
			GENERIC = "Baby Patuey Fly",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Too cold!",
			COMFY = "Warm inside",
		},
		LAVAE_TOOTH = "Patuey Fly is teething?",

		DRAGONFRUIT = "Pretty fruit",
		DRAGONFRUIT_COOKED = "Mmm...",
		DRAGONFRUIT_SEEDS = "Grows the pretty fruit",
		DRAGONPIE = "Pie. Yummy pie",
		DRUMSTICK = "Not friend stick",
		DRUMSTICK_COOKED = "A stick for belly",
		DUG_BERRYBUSH = "Needs dirt",
		DUG_BERRYBUSH_JUICY = "Needs dirt",
		DUG_GRASS = "Needs dirt",
		DUG_MARSH_BUSH = "Needs dirt",
		DUG_SAPLING = "Needs dirt",
		DURIAN = "Smelly belly stuff",
		DURIAN_COOKED = "Still smells",
		DURIAN_SEEDS = "Want this, dirt?",
		EARMUFFSHAT = "Squee Hopper ears",
		EGGPLANT = "Mmm...",
		EGGPLANT_COOKED = "Belly likes it",
		EGGPLANT_SEEDS = "Grows the purple belly stuff",

		ENDTABLE =
		{
			BURNT = "No! NOOOOO!",
			GENERIC = "Ohh! Table friend!",
			EMPTY = "Needs friend for cup",
			WILTED = "Sick, Friend?",
			FRESHLIGHT = "Light Friend looks good!",
			OLDLIGHT = "Sick, Light Friend?", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "No!",
			BURNT = "Sorry",
			CHOPPED = "Oh!",
			POISON = "Hello! Friend?",
			GENERIC = "Sleeping?",
		},
		ACORN = "So cute!",
        ACORN_SAPLING = "Grow big and strong!",
		ACORN_COOKED = "For belly now",
		BIRCHNUTDRAKE = "So cute",
		EVERGREEN =
		{
			BURNING = "Nonononono!",
			BURNT = "(sob)",
			CHOPPED = "Sorry",
			GENERIC = "How doing, friend?",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Fire!",
			BURNT = "Oh",
			CHOPPED = "Sad. So sad",
			GENERIC = "Shh... Sleeping",
		},
		TWIGGYTREE =
		{
			BURNING = "No! NOOOOOOO!",
			BURNT = "So young...",
			CHOPPED = "Keep growing, friend!",
			GENERIC = "Skinny friend!",
			DISEASED = "Sick?", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Cute little friend",
        TWIGGY_OLD = "Wise old friend",
		TWIGGY_NUT = "Needs dirt",
		EYEPLANT = "Blinky friend",
		INSPECTSELF = "Looking nice",
		FARMPLOT =
		{
			GENERIC = "Good soil",
			GROWING = "Growing stuff for belly",
			NEEDSFERTILIZER = "Needs poop",
			BURNT = "Oh",
		},
		FEATHERHAT = "Tweeter disguise",
		FEATHER_CROW = "Caw Tweeter clothes",
		FEATHER_ROBIN = "Red Tweeter clothes",
		FEATHER_ROBIN_WINTER = "Snow Tweeter clothes",
		FEATHER_CANARY = "Tweeter clothes",
		FEATHERPENCIL = "Draws pretty pictures",
        COOKBOOK = "Belly things",
		FEM_PUPPET = "Friend?", --single player
		FIREFLIES =
		{
			GENERIC = "Glow Bums",
			HELD = "Needs home",
		},
		FIREHOUND = "Fire Woofers",
		FIREPIT =
		{
			EMBERS = "Dying",
			GENERIC = "Not too close",
			HIGH = "Too high!",
			LOW = "Stay back",
			NORMAL = "Not too close",
			OUT = "Whew. No fire",
		},
		COLDFIREPIT =
		{
			EMBERS = "Almost gone",
			GENERIC = "Chilly",
			HIGH = "Pretty",
			LOW = "Getting warmer",
			NORMAL = "Cooling",
			OUT = "Needs food",
		},
		FIRESTAFF = "Hot Pew Stick",
		FIRESUPPRESSOR =
		{
			ON = "Good machine",
			OFF = "Keep fire away",
			LOWFUEL = "Needs food",
		},

		FISH = "Glub Glub",
		FISHINGROD = "Glub Glub Stick",
		FISHSTICKS = "Glub Glub on a friend",
		FISHTACOS = "What's wrong with eyes, Glub Glub?",
		FISH_COOKED = "Watch for bones",
		FLINT = "Sharp stone",
		FLOWER =
		{
            GENERIC = "Friend!",
            ROSE = "Pretty! Pretty friend!",
        },
        FLOWER_WITHERED = "Oh, friend. What's wrong?",
		FLOWERHAT = "Friends for head",
		FLOWER_EVIL = "What happened, friend?",
		FOLIAGE = "Friend. Good friend",
		FOOTBALLHAT = "Twirly Tail head thing",
        FOSSIL_PIECE = "Where the rest?",
        FOSSIL_STALKER =
        {
			GENERIC = "Not done yet",
			FUNNY = "Oops. Made wrong",
			COMPLETE = "All better",
        },
        STALKER = "Branches? Or bones?",
        STALKER_ATRIUM = "Aggh! Big Bone Roarer!",
        STALKER_MINION = "Big Bone Roarer has tiny pals!",
        THURIBLE = "Burns dark fire",
        ATRIUM_OVERGROWTH = "Don't know those scribbles",
		FROG =
		{
			DEAD = "Oh",
			GENERIC = "Ribbit",
			SLEEPING = "Tired",
		},
		FROGGLEBUNWICH = "Fills belly",
		FROGLEGS = "Ribbit legs",
		FROGLEGS_COOKED = "Legs for belly",
		FRUITMEDLEY = "Fruit party!",
		FURTUFT = "Molt (sniff sniff) Smells good",
		GEARS = "Machine food",
		GHOST = "Floaty man!",
		GOLDENAXE = "Pretty. Pretty scary",
		GOLDENPICKAXE = "Pretty Pokey",
		GOLDENPITCHFORK = "Pretty Ground Getter",
		GOLDENSHOVEL = "Pretty Digger",
		GOLDNUGGET = "Little Yellow Stone",
		GRASS =
		{
			BARREN = "Needs poop",
			WITHERED = "Too hot!",
			BURNING = "Agghh!",
			GENERIC = "Smells nice",
			PICKED = "Nice trim!",
			DISEASED = "Sick! Sick friend!", --unimplemented
			DISEASING = "Get better soon", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Looking good. Like hair",
			DISEASED = "Sick?", --unimplemented
		},
		GREEN_CAP = "Hurts head",
		GREEN_CAP_COOKED = "Helps head",
		GREEN_MUSHROOM =
		{
			GENERIC = "Green mushy",
			INGROUND = "Hiding",
			PICKED = "Gone",
		},
		GUNPOWDER = "BOOM!",
		HAMBAT = "Twirly Tail Whacker",
		HAMMER = "Smasher",
		HEALINGSALVE = "Boo Boo Gloop",
		HEATROCK =
		{
			FROZEN = "Brrrr...",
			COLD = "Cold",
			GENERIC = "Hot cold rock",
			WARM = "Warm",
			HOT = "Yeeouch!",
		},
		HOME = "Home",
		HOMESIGN =
		{
			GENERIC = "Scribbles on friends",
            UNWRITTEN = "Needs scribbles",
			BURNT = "(sigh)",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "Pointy friend",
            UNWRITTEN = "Needs scribbles",
			BURNT = "oh. (sob)",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Pointy friend",
            UNWRITTEN = "Needs scribbles",
			BURNT = "oh. (sob)",
		},
		HONEY = "Buzz Juice",
		HONEYCOMB = "From Buzz home",
		HONEYHAM = "Poor Twirly Tail...",
		HONEYNUGGETS = "Buzz Juice and Twirly Tails",
		HORN = "Branch?",
		HOUND = "Woofer! Woof! Woof!",
		HOUNDCORPSE =
		{
			GENERIC = "Woofer okay?",
			BURNING = "Smell bad",
			REVIVING = "Coming back",
		},
		HOUNDBONE = "Sharp!",
		HOUNDMOUND = "Woofers around?",
		ICEBOX = "Keeps belly stuff cold",
		ICEHAT = "Cool hat!",
		ICEHOUND = "Brrr Woofer",
		INSANITYROCK =
		{
			ACTIVE = "Ow. Hurts head...",
			INACTIVE = "Hiding",
		},
		JAMMYPRESERVES = "Sweet belly stuff",

		KABOBS = "Meat is belly stuff. Stick is not",
		KILLERBEE =
		{
			GENERIC = "Bad Buzz! Bad!",
			HELD = "Needs home",
		},
		KNIGHT = "Neigh machine",
		KOALEFANT_SUMMER = "Bruamp! Bruamp!",
		KOALEFANT_WINTER = "Bruamp! Bruamp!",
		KRAMPUS = "Mean Branch Head",
		KRAMPUS_SACK = "Full of stuff?",
		LEIF = "Hello!... Hello?",
		LEIF_SPARSE = "Friend?",
		LIGHTER  = "Fire box!",
		LIGHTNING_ROD =
		{
			CHARGED = "Zzzzt! Zzzzt!",
			GENERIC = "Zzzzt Stick",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "Lovely head branches",
			CHARGED = "Yaaah!",
		},
		LIGHTNINGGOATHORN = "From Twirly Branch Head",
		GOATMILK = "Mmmm...",
		LITTLE_WALRUS = "Teeth Branches",
		LIVINGLOG = "Friend. Nice friend",
		LOG =
		{
			BURNING = "AAAHHHHHH!",
			GENERIC = "Sorry. So sorry",
		},
		LUCY = "Aggah! Stay back, please!",
		LUREPLANT = "Careful!",
		LUREPLANTBULB = "For dirt",
		MALE_PUPPET = "Friend?", --single player

		MANDRAKE_ACTIVE = "Merp! Merp! Meep! Merp!",
		MANDRAKE_PLANTED = "Hiding",
		MANDRAKE = "Need friend?",

        MANDRAKESOUP = "Sleepytime soup",
        MANDRAKE_COOKED = "Smells sleepy",
        MAPSCROLL = "Findy Paper!",
        MARBLE = "Solid",
        MARBLEBEAN = "Baby Stone Friend!",
        MARBLEBEAN_SAPLING = "So cute...",
        MARBLESHRUB = "Stone? Stone friend?",
        MARBLEPILLAR = "Good trunk. Solid",
        MARBLETREE = "Friend? Solid friend",
        MARSH_BUSH =
        {
			BURNT = "Oh...",
            BURNING = "AGGGH!!!",
            GENERIC = "Twisty friend",
            PICKED = "Keep growing!",
        },
        BURNT_MARSH_BUSH = "oh. (sob)",
        MARSH_PLANT = "Hello, little guy",
        MARSH_TREE =
        {
            BURNING = "YAAAAAAHH!",
            BURNT = "Oh",
            CHOPPED = "(sob)",
            GENERIC = "Sleeping. Shh...",
        },
        MAXWELL = "Not friend",--single player
        MAXWELLHEAD = "Not friend head",--removed
        MAXWELLLIGHT = "Bright rock",--single player
        MAXWELLLOCK = "Needs key",--single player
        MAXWELLTHRONE = "Smells bad",--single player
        MEAT = "For belly",
        MEATBALLS = "Balls of belly stuff",
        MEATRACK =
        {
            DONE = "Done",
            DRYING = "Getting unwet",
            DRYINGINRAIN = "Rain can't help",
            GENERIC = "Takes out wet",
            BURNT = "Oh",
            DONE_NOTMEAT = "Done?",
            DRYING_NOTMEAT = "Getting unwet",
            DRYINGINRAIN_NOTMEAT = "Rain not helping",
        },
        MEAT_DRIED = "Dried up belly stuff",
        MERM = "Glub Glub Man",
        MERMHEAD =
        {
            GENERIC = "Rotten",
            BURNT = "Just ashes",
        },
        MERMHOUSE =
        {
            GENERIC = "Glub Glub Man home",
            BURNT = "Fire is bad",
        },
        MINERHAT = "Fits",
        MONKEY = "Cheeky",
        MONKEYBARREL = "Full of Cheekies",
        MONSTERLASAGNA = "For belly?",
        FLOWERSALAD = "Want to eat it",
        ICECREAM = "Keeps belly cold",
        WATERMELONICLE = "Keeping cool, stick?",
        TRAILMIX = "Belly stuff for belly",
        HOTCHILI = "Hot! It's hot!",
        GUACAMOLE = "Cute!",
        MONSTERMEAT = "Belly stuff?",
        MONSTERMEAT_DRIED = "Hmmm...",
        MOOSE = "Branch Head Tweeter",
        MOOSE_NESTING_GROUND = "Sticks!",
        MOOSEEGG = "Tweeter inside",
        MOSSLING = "Why so hungry?",
        FEATHERFAN = "Fire Outer",
        MINIFAN = "Wheeee!",
        GOOSE_FEATHER = "Tickles. Hehe!",
        STAFF_TORNADO = "Makes big winds!",
        MOSQUITO =
        {
            GENERIC = "Bzzt",
            HELD = "It's bzzt-ing",
        },
        MOSQUITOSACK = "Bzzt Bum",
        MOUND =
        {
            DUG = "Dug up",
            GENERIC = "Dirt hill",
        },
        NIGHTLIGHT = "Glowy",
        NIGHTMAREFUEL = "Dark Floaty Man",
        NIGHTSWORD = "Dark Floaty Swoosh Stick",
        NITRE = "Pow Rock",
        ONEMANBAND = "Boom! Boom! Crash!",
        OASISLAKE =
		{
			GENERIC = "Water! Water!",
			EMPTY = "Oh. Empty",
		},
        PANDORASCHEST = "Stuff!",
        PANFLUTE = "Toot!",
        PAPYRUS = "Flat friends",
        WAXPAPER = "Shiny paper. So shiny...",
        PENGUIN = "Woddle Woddle",
        PERD = "Hidey Tweeter",
        PEROGIES = "Good belly stuff",
        PETALS = "Smells good",
        PETALS_EVIL = "Hmmm... smells bad",
        PHLEGM = "Hork",
        PICKAXE = "Pokey",
        PIGGYBACK = "Carries stuff",
        PIGHEAD =
        {
            GENERIC = "Rot inside",
            BURNT = "Ashes",
        },
        PIGHOUSE =
        {
            FULL = "Hello?",
            GENERIC = "Twirly Tail home",
            LIGHTSOUT = "Twirly Tail not home",
            BURNT = "Oh. Don't like fire",
        },
        PIGKING = "Twirly Tail Boss",
        PIGMAN =
        {
            DEAD = "Aww...",
            FOLLOWER = "Twirly Tail friend",
            GENERIC = "Hello Twirly Tail!",
            GUARD = "Twirly Tail Tough Guy",
            WEREPIG = "Twirly Tail Woofer",
        },
        PIGSKIN = "Twirly Tail Bum",
        PIGTENT = "Twirly Tail house",
        PIGTORCH = "Hello! Hello! Hello! Hello!",
        PINECONE = "Aw... Little baby friends",
        PINECONE_SAPLING = "Getting big!",
        LUMPY_SAPLING = "Keep growing!",
        PITCHFORK = "Dirt Getter",
        PLANTMEAT = "Meat from dirt",
        PLANTMEAT_COOKED = "Good for belly",
        PLANT_NORMAL =
        {
            GENERIC = "Dirt stuff for belly",
            GROWING = "Almost there!",
            READY = "Thank you, dirt!",
            WITHERED = "Sick?",
        },
        POMEGRANATE = "Seedy fruit",
        POMEGRANATE_COOKED = "Good belly stuff",
        POMEGRANATE_SEEDS = "Needs dirt",
        POND = "Big puddle",
        POOP = "Mmm... Smells good!",
        FERTILIZER = "Poop! Yay!",
        PUMPKIN = "Good for belly",
        PUMPKINCOOKIE = "Belly wants it",
        PUMPKIN_COOKED = "Slurpy",
        PUMPKIN_LANTERN = "Spooky...",
        PUMPKIN_SEEDS = "For dirt",
        PURPLEAMULET = "Brain Neck Thing",
        PURPLEGEM = "Shiny",
        RABBIT =
        {
            GENERIC = "Bouncy Squee Hopper",
            HELD = "So soft",
        },
        RABBITHOLE =
        {
            GENERIC = "Bouncy Squee Hopper home?",
            SPRING = "Where'd they go?",
        },
        RAINOMETER =
        {
            GENERIC = "Rain?",
            BURNT = "Ashes. Only ashes",
        },
        RAINCOAT = "Rain Taker Coat",
        RAINHAT = "Looks good?",
        RATATOUILLE = "Belly party!",
        RAZOR = "Sharp",
        REDGEM = "Red Shiny",
        RED_CAP = "Yummy friend hat",
        RED_CAP_COOKED = "Hurts head",
        RED_MUSHROOM =
        {
            GENERIC = "Squishy friend",
            INGROUND = "Hiding",
            PICKED = "Gone",
        },
        REEDS =
        {
            BURNING = "Save them!",
            GENERIC = "Water friends",
            PICKED = "Keep growing",
        },
        RELIC = "Old",
        RUINS_RUBBLE = "Can fix it?",
        RUBBLE = "Rocks",
        RESEARCHLAB =
        {
            GENERIC = "Makes more things!",
            BURNT = "Fire hurts everything",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "More things to make!",
            BURNT = "Too bad",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "More magics",
            BURNT = "Gone",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "Makes magics things",
            BURNT = "Why, fire? Why?!",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "Regrowing friends",
            BURNT = "Fire hurts everything",
        },
        RESURRECTIONSTONE = "Life Rock",
        ROBIN =
        {
            GENERIC = "Red Tweeter",
            HELD = "Needs home",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Snow Tweeter",
            HELD = "Needs home",
        },
        ROBOT_PUPPET = "Friend?", --single player
        ROCK_LIGHT =
        {
            GENERIC = "Dirt is bleeding",--removed
            OUT = "All better",--removed
            LOW = "Healing",--removed
            NORMAL = "Earth blood",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Raining rocks?",
            RAISED = "Can't reach. Oh",
        },
        ROCK = "Rock. Hello",
        PETRIFIED_TREE = "Friend made of rock",
        ROCK_PETRIFIED_TREE = "Strong friend!",
        ROCK_PETRIFIED_TREE_OLD = "Hello, old friend!",
        ROCK_ICE =
        {
            GENERIC = "Big, cold rock",
            MELTED = "Water now",
        },
        ROCK_ICE_MELTED = "Water now",
        ICE = "Cold. Really cold",
        ROCKS = "Rocks",
        ROOK = "Rock machine",
        ROPE = "Friends made string!",
        ROTTENEGG = "Smells good!",
        ROYAL_JELLY = "Bloopy belly stuff",
        JELLYBEAN = "Mmmmm!",
        SADDLE_BASIC = "Shaggy Buddy Sitting Thing",
        SADDLE_RACE = "Shaggy Buddy Zoomer!",
        SADDLE_WAR = "Shaggy Buddy Fight Thing",
        SADDLEHORN = "Sitting Thing Getter Offer",
        SALTLICK = "Lick rock. For Shaggy Buddy",
        BRUSH = "Buddies like the brushing",
		SANITYROCK =
		{
			ACTIVE = "Helps head",
			INACTIVE = "Hiding",
		},
		SAPLING =
		{
			BURNING = "NOOO!",
			WITHERED = "Poor friend",
			GENERIC = "Hello? Little friend?",
			PICKED = "Keep growing, friend!",
			DISEASED = "Sick. Very, very sick", --removed
			DISEASING = "Looks sick. Poor little guy", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Tweeter Friend",
			BURNING = "No! Save him!",
			BURNT = "Oh",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "No rock yet",
			BLOCK = "What to make?",
			SCULPTURE = "Fun! Want to do again!",
			BURNT = "Nooooo!",
   		},
        SCULPTURE_KNIGHTHEAD = "Hello Neigher!",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "Like it!",
			UNCOVERED = "Needs help?",
			FINISHED = "Looks good!",
			READY = "Something moving?",
		},
        SCULPTURE_BISHOPHEAD = "Where's rest?",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Looks good!",
			UNCOVERED = "Broken?",
			FINISHED = "Fixed now",
			READY = "Hello? Anyone there?",
		},
        SCULPTURE_ROOKNOSE = "Can lift it?",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Nice looking rock",
			UNCOVERED = "Needs fixing",
			FINISHED = "Better now",
			READY = "Something moving?",
		},
        GARGOYLE_HOUND = "Just stone",
        GARGOYLE_WEREPIG = "Arrrooooo!",
		SEEDS = "Wants dirt",
		SEEDS_COOKED = "Mmmm...",
		SEWING_KIT = "Fixey kit",
		SEWING_TAPE = "Sticky ribbon",
		SHOVEL = "Digger",
		SILK = "Soft",
		SKELETON = "Still alive?",
		SCORCHED_SKELETON = "Oh. Oh no",
		SKULLCHEST = "Stuff inside", --removed
		SMALLBIRD =
		{
			GENERIC = "Baby Eye Tweeter",
			HUNGRY = "Hungry?",
			STARVING = "Needs stuff for belly!!",
			SLEEPING = "Shh... Sleeping",
		},
		SMALLMEAT = "Little belly thing",
		SMALLMEAT_DRIED = "Chewy",
		SPAT = "Horkbeast",
		SPEAR = "Sharp stick",
		SPEAR_WATHGRITHR = "Sharp",
		WATHGRITHRHAT = "Pokey branch hat",
		SPIDER =
		{
			DEAD = "Oh",
			GENERIC = "Leggy Bug",
			SLEEPING = "Shh...",
		},
		SPIDERDEN = "Home for Leggy Bugs",
		SPIDEREGGSACK = "Leggy Bug Babies inside",
		SPIDERGLAND = "Good for heart",
		SPIDERHAT = "Leggy Bug head thing",
		SPIDERQUEEN = "Leggy Bug Mommy",
		SPIDER_WARRIOR =
		{
			DEAD = "Oh",
			GENERIC = "Angry Leggy Bug",
			SLEEPING = "Sleepytime",
		},
		SPOILED_FOOD = "Not good for belly",
        STAGEHAND =
        {
			AWAKE = "Ohh! Table friend!",
			HIDING = "Too shy?",
        },
        STATUE_MARBLE =
        {
            GENERIC = "Like it",
            TYPE1 = "Why so sad?",
            TYPE2 = "No head? Where's head?",
            TYPE3 = "Big bowl", --bird bath type statue
        },
		STATUEHARP = "Where'd head go?",
		STATUEMAXWELL = "Alive?",
		STEELWOOL = "Horkbeast clothes",
		STINGER = "Youchy!",
		STRAWHAT = "Friend hat",
		STUFFEDEGGPLANT = "Stuffed belly stuff",
		SWEATERVEST = "Warm",
		REFLECTIVEVEST = "For the hot times",
		HAWAIIANSHIRT = "Breezy",
		TAFFY = "Chewy goo",
		TALLBIRD = "Big Eye Tweeter",
		TALLBIRDEGG = "Eye Tweeter inside?",
		TALLBIRDEGG_COOKED = "For belly",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Needs warm",
			GENERIC = "Tweet! ",
			HOT = "Too hot!",
			LONG = "(yawn)",
			SHORT = "Tweeter coming soon!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "Tweet! Tweet!",
			PICKED = "Eye Tweeter sticks",
		},
		TEENBIRD =
		{
			GENERIC = "Eye Tweeter is growing!",
			HUNGRY = "Hungry?",
			STARVING = "Needs belly stuff",
			SLEEPING = "Shh... Sleepytime",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Open", --single player
			GENERIC = "Hmm...", --single player
			LOCKED = "Key?", --single player
			PARTIAL = "Needs more things", --single player
		},
		TELEPORTATO_BOX = "Box", --single player
		TELEPORTATO_CRANK = "Crank", --single player
		TELEPORTATO_POTATO = "Thing", --single player
		TELEPORTATO_RING = "Ring", --single player
		TELESTAFF = "Poof stick",
		TENT =
		{
			GENERIC = "Little home",
			BURNT = "Turned to ash",
		},
		SIESTAHUT =
		{
			GENERIC = "Nap time?",
			BURNT = "No more naptime",
		},
		TENTACLE = "Arms from the dirt",
		TENTACLESPIKE = "Spiky Whacker",
		TENTACLESPOTS = "Spots. Pretty spots",
		TENTACLE_PILLAR = "Sleeping",
        TENTACLE_PILLAR_HOLE = "Hello?",
		TENTACLE_PILLAR_ARM = "Little Dirt Arms",
		TENTACLE_GARDEN = "Sleeping",
		TOPHAT = "Soft head thing",
		TORCH = "Fire Stick",
		TRANSISTOR = "It's humming! Hummm...",
		TRAP = "Snap!",
		TRAP_TEETH = "Hurty Spikes",
		TRAP_TEETH_MAXWELL = "Hurty Spikes", --single player
		TREASURECHEST =
		{
			GENERIC = "Stuff!",
			BURNT = "(sigh)",
		},
		TREASURECHEST_TRAP = "Hmm...",
		SACRED_CHEST =
		{
			GENERIC = "Put stuff in there!",
			LOCKED = "Stuff is gone",
		},
		TREECLUMP = "Party!", --removed

		TRINKET_1 = "Swirly rocks", --Melted Marbles
		TRINKET_2 = "Hummm...", --Fake Kazoo
		TRINKET_3 = "Twisty string", --Gord's Knot
		TRINKET_4 = "Pointy hat little man", --Gnome
		TRINKET_5 = "Pakow!", --Toy Rocketship
		TRINKET_6 = "Zzzt", --Frazzled Wires
		TRINKET_7 = "Wood?", --Ball and Cup
		TRINKET_8 = "Pretty", --Rubber Bung
		TRINKET_9 = "Rocks?", --Mismatched Buttons
		TRINKET_10 = "Chatters", --Dentures
		TRINKET_11 = "Hello!", --Lying Robot
		TRINKET_12 = "Sticky", --Dessicated Tentacle
		TRINKET_13 = "Hello!... Hello?", --Gnomette
		TRINKET_14 = "Can't drink from it", --Leaky Teacup
		TRINKET_15 = "Can't play", --Pawn
		TRINKET_16 = "Can't play", --Pawn
		TRINKET_17 = "Pokey shiny thing", --Bent Spork
		TRINKET_18 = "Wheee!", --Trojan Horse
		TRINKET_19 = "Twirly!", --Unbalanced Top
		TRINKET_20 = "(scritch, scritch)", --Backscratcher
		TRINKET_21 = "Hmm... Can't use it", --Egg Beater
		TRINKET_22 = "Ball!", --Frayed Yarn
		TRINKET_23 = "What's this?", --Shoehorn
		TRINKET_24 = "Me-Raow? Oh. Not alive", --Lucky Cat Jar
		TRINKET_25 = "Little friend?", --Air Unfreshener
		TRINKET_26 = "Hmm... What's this for?", --Potato Cup
		TRINKET_27 = "Stick? No not stick", --Coat Hanger
		TRINKET_28 = "Can't play", --Rook
        TRINKET_29 = "Anyone to play with?", --Rook
        TRINKET_30 = "Little Neigher", --Knight
        TRINKET_31 = "Little Neigher", --Knight
        TRINKET_32 = "Ball!", --Cubic Zirconia Ball
        TRINKET_33 = "Hello? Oh. Not alive", --Spider Ring
        TRINKET_34 = "Where's rest?", --Monkey Paw
        TRINKET_35 = "Empty", --Empty Elixir
        TRINKET_36 = "Pokey teeth", --Faux fangs
        TRINKET_37 = "Oh. What happened?", --Broken Stake
        TRINKET_38 = "Makes things big!", -- Binoculars Griftlands trinket
        TRINKET_39 = "Doesn't fit", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Can't use it", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Goop inside", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Aggh! Oh. Not real", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Wheeee!", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Friend has broken home", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Not working", -- Odd Radio ONI trinket
        TRINKET_46 = "What's this?", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Spooky",
        LOST_TOY_2  = "Spooky",
        LOST_TOY_7  = "Spooky",
        LOST_TOY_10 = "Spooky",
        LOST_TOY_11 = "Spooky",
        LOST_TOY_14 = "Spooky",
        LOST_TOY_18 = "Spooky",
        LOST_TOY_19 = "Spooky",
        LOST_TOY_42 = "Spooky",
        LOST_TOY_43 = "Spooky",

        HALLOWEENCANDY_1 = "Careful! Don't eat stick",
        HALLOWEENCANDY_2 = "Not for dirt",
        HALLOWEENCANDY_3 = "Yum!",
        HALLOWEENCANDY_4 = "Squishy",
        HALLOWEENCANDY_5 = "Hehe!",
        HALLOWEENCANDY_6 = "Sweet stuff for belly",
        HALLOWEENCANDY_7 = "Belly stuff",
        HALLOWEENCANDY_8 = "Sad?",
        HALLOWEENCANDY_9 = "Wiggly!",
        HALLOWEENCANDY_10 = "Mmm...",
        HALLOWEENCANDY_11 = "Twirly Tail?",
        HALLOWEENCANDY_12 = "Yum!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Ball of belly stuff!", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Ho! Ha! Hot belly stuff!", --Hot Lava pepper candy
        CANDYBAG = "Holds sweet belly stuff!",

		HALLOWEEN_ORNAMENT_1 = "Ooooooo!",
		HALLOWEEN_ORNAMENT_2 = "Not flapping",
		HALLOWEEN_ORNAMENT_3 = "Not alive",
		HALLOWEEN_ORNAMENT_4 = "Spiky pretty thing",
		HALLOWEEN_ORNAMENT_5 = "Haha! Wrong way Leggy Bug",
		HALLOWEEN_ORNAMENT_6 = "Alive, Tweeter? Nope",

		HALLOWEENPOTION_DRINKS_WEAK = "Little thing for belly",
		HALLOWEENPOTION_DRINKS_POTENT = "Big thing for belly",
        HALLOWEENPOTION_BRAVERY = "Makes strong!",
		HALLOWEENPOTION_MOON = "Change to moony-things",
		HALLOWEENPOTION_FIRE_FX = "Ka-POW! inside",
		MADSCIENCE_LAB = "For making scaries",
		LIVINGTREE_ROOT = "Needs dirt",
		LIVINGTREE_SAPLING = "Keep growing, friend!",

        DRAGONHEADHAT = "Patuey Head looks good!",
        DRAGONBODYHAT = "Where's rest?",
        DRAGONTAILHAT = "Can wear bottom for head",
        PERDSHRINE =
        {
            GENERIC = "Found a Hidey Tweeter!",
            EMPTY = "Needs belly stuff",
            BURNT = "No! AGGGH!",
        },
        REDLANTERN = "Pretty light",
        LUCKY_GOLDNUGGET = "Yellow Rock Round Thing",
        FIRECRACKERS = "POP! POP!",
        PERDFAN = "Makes wind",
        REDPOUCH = "What's inside?",
        WARGSHRINE =
        {
            GENERIC = "Yellow Woofer has house",
            EMPTY = "Needs fire",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Too much fire",
        },
        CLAYWARG =
        {
        	GENERIC = "Aggh! Alive now!",
        	STATUE = "Real Woofer?",
        },
        CLAYHOUND =
        {
        	GENERIC = "Too much moving now!",
        	STATUE = "Good Woofer. Stay",
        },
        HOUNDWHISTLE = "Tweet Tweet for Woofer",
        CHESSPIECE_CLAYHOUND = "Alive? Hmmm...",
        CHESSPIECE_CLAYWARG = "Stay stone, please",

		PIGSHRINE =
		{
            GENERIC = "Little Twirly Tail House",
            EMPTY = "Needs belly stuff",
            BURNT = "Why, fire? Why?",
		},
		PIG_TOKEN = "Oh. Doesn't fit",
		PIG_COIN = "Twirly Tail shiny thing",
		YOTP_FOOD1 = "You okay, Twirly Tail?",
		YOTP_FOOD2 = "Oh... can't eat it",
		YOTP_FOOD3 = "Glub Glub on friends",

		PIGELITE1 = "Hello, Twirly Tail!", --BLUE
		PIGELITE2 = "Angry Twirly Tail", --RED
		PIGELITE3 = "Friend?", --WHITE
		PIGELITE4 = "Like him", --GREEN

		PIGELITEFIGHTER1 = "Hello, Twirly Tail!", --BLUE
		PIGELITEFIGHTER2 = "Angry Twirly Tail", --RED
		PIGELITEFIGHTER3 = "Friend?", --WHITE
		PIGELITEFIGHTER4 = "Like him", --GREEN

		CARRAT_GHOSTRACER = "Dark floaty... friend?",

        YOTC_CARRAT_RACE_START = "Start place",
        YOTC_CARRAT_RACE_CHECKPOINT = "Friend help show the way",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "End place",
            BURNT = "Oh",
            I_WON = "Good job friend!",
            SOMEONE_ELSE_WON = "{winner}'s friend did good job",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Start place",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Friend help show the way",
		YOTC_CARRAT_RACE_FINISH_ITEM = "End place",

		YOTC_SEEDPACKET = "Shh... friends sleeping inside",
		YOTC_SEEDPACKET_RARE = "Shh... friends sleeping inside",

		MINIBOATLANTERN = "Little Floater",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "Shiny thing has little house",
            EMPTY = "Hungry?",
            BURNT = "Oh",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "Turn-arounder",
            RAT = "Learning",
            BURNT = "(sigh)",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Fast spinner",
            RAT = "Going faster",
            BURNT = "(sigh)",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "Springy box",
            RAT = "Can little friend get poppy corn?",
            BURNT = "(sigh)",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "Jumper",
            RAT = "Getting strong",
            BURNT = "(sigh)",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "For little friend",
        YOTC_CARRAT_GYM_SPEED_ITEM = "For little friend",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "For little friend",
        YOTC_CARRAT_GYM_REACTION_ITEM = "For little friend",

        YOTC_CARRAT_SCALE_ITEM = "Measure little friend",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "Measure little friend",
            CARRAT = "Not so good",
            CARRAT_GOOD = "Good!",
            BURNT = "Oh",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Fluffy now",
            EMPTY = "Shaggy Buddy... has no fluff",
            BURNT = "(sigh)",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Shaggy Buddy brusher",
            OCCUPIED = "Hmm hmm, make you pretty!",
            BURNT = "Oh",
        },
        BEEFALO_GROOMER_ITEM = "Make Shaggy Buddy brusher",

		BISHOP_CHARGE_HIT = "Aggh!",
		TRUNKVEST_SUMMER = "Cool",
		TRUNKVEST_WINTER = "Warm",
		TRUNK_COOKED = "For belly?",
		TRUNK_SUMMER = "Bruamp nose",
		TRUNK_WINTER = "Bruamp nose",
		TUMBLEWEED = "Come back!",
		TURKEYDINNER = "Lots of belly stuff",
		TWIGS = "Little friends! Hi!",
		UMBRELLA = "Rain Taker",
		GRASS_UMBRELLA = "Friend hair keeps rain away",
		UNIMPLEMENTED = "Hmm...",
		WAFFLES = "Yum",
		WALL_HAY =
		{
			GENERIC = "Wall of friends",
			BURNT = "Bye bye, friends",
		},
		WALL_HAY_ITEM = "Hi, friends!",
		WALL_STONE = "Solid",
		WALL_STONE_ITEM = "For the ground",
		WALL_RUINS = "Strong",
		WALL_RUINS_ITEM = "For the ground",
		WALL_WOOD =
		{
			GENERIC = "So many friends",
			BURNT = "Noo!!",
		},
		WALL_WOOD_ITEM = "Friends!",
		WALL_MOONROCK = "Hard",
		WALL_MOONROCK_ITEM = "For the ground",
		FENCE = "Made of friends",
        FENCE_ITEM = "Put in ground",
        FENCE_GATE = "Door made of friends",
        FENCE_GATE_ITEM = "Put in ground",
		WALRUS = "Grows mouth branches?",
		WALRUSHAT = "Floppy head thing",
		WALRUS_CAMP =
		{
			EMPTY = "No one here",
			GENERIC = "Ball home",
		},
		WALRUS_TUSK = "Tooth branch",
		WARDROBE =
		{
			GENERIC = "Friends holding clothes",
            BURNING = "AGHHH!",
			BURNT = "Fire bad",
		},
		WARG = "Big Bad Woofer",
        WARGLET = "Big Bad Woofer",
        
		WASPHIVE = "Bad Buzz home",
		WATERBALLOON = "Water Booper",
		WATERMELON = "Watery Sweet belly stuff",
		WATERMELON_COOKED = "Slurpy",
		WATERMELONHAT = "Watery head thing",
		WAXWELLJOURNAL = "Nope",
		WETGOOP = "Yum",
        WHIP = "Snappy Kitty Tail",
		WINTERHAT = "Looks good",
		WINTEROMETER =
		{
			GENERIC = "Warm? Cold?",
			BURNT = "Noo!",
		},

        WINTER_TREE =
        {
            BURNT = "NOOOOOO!",
            BURNING = "Help! Help!",
            CANDECORATE = "Make pretty!",
            YOUNG = "So cute...",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "For friends",
            BURNT = "So sad...",
		},
        WINTER_ORNAMENT = "So pretty",
        WINTER_ORNAMENTLIGHT = "Shiny thing...",
        WINTER_ORNAMENTBOSS = "Put on friends",
		WINTER_ORNAMENTFORGE = "It goes on friend",
		WINTER_ORNAMENTGORGE = "For friends to feel pretty",

        WINTER_FOOD1 = "Friend?", --gingerbread cookie
        WINTER_FOOD2 = "Oh. Didn't fall from sky", --sugar cookie
        WINTER_FOOD3 = "Mmm... Sweet belly thing", --candy cane
        WINTER_FOOD4 = "So many little colors!", --fruitcake
        WINTER_FOOD5 = "Friend?!... Oh. Nope", --yule log cake
        WINTER_FOOD6 = "Ball goes in belly", --plum pudding
        WINTER_FOOD7 = "Haha! Friend made a drink!", --apple cider
        WINTER_FOOD8 = "Mmm... Makes belly warm", --hot cocoa
        WINTER_FOOD9 = "Makes belly full", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Doesn't use friends",
			COOKING = "Mmm...",
			ALMOST_DONE_COOKING = "Almost...",
			DISH_READY = "Food!",
		},
		BERRYSAUCE = "Mushy sweet balls",
		BIBINGKA = "Wrapped in friends",
		CABBAGEROLLS = "Rolled up belly stuff",
		FESTIVEFISH = "Fancy Glub Glub",
		GRAVY = "Not mud?",
		LATKES = "Potato bits",
		LUTEFISK = "Mushy Glub Glub",
		MULLEDDRINK = "Makes insides warm",
		PANETTONE = "Tiny friends inside!",
		PAVLOVA = "Crunchy",
		PICKLEDHERRING = "Salty Glub Glub",
		POLISHCOOKIE = "Sweet belly stuff",
		PUMPKINPIE = "Mmmm...",
		ROASTTURKEY = "Tweeter go in belly!",
		STUFFING = "Tasty bready bits",
		SWEETPOTATO = "Yummy yum!",
		TAMALES = "Friends holding it",
		TOURTIERE = "Mmm... hot belly stuff",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Friends can eat here",
			HAS_FOOD = "Friends eat?",
			WRONG_TYPE = "Oops. Nope",
			BURNT = "Oh...",
		},

		GINGERBREADWARG = "Scary Sweet Woofer",
		GINGERBREADHOUSE = "Yummy house. Mmmmm!",
		GINGERBREADPIG = "Come back, friend!",
		CRUMBS = "Oh. Friend lost thing",
		WINTERSFEASTFUEL = "Friends...",

        KLAUS = "Hello! Friend?",
        KLAUS_SACK = "Prize inside?",
		KLAUSSACKKEY = "Branch? No",
		WORMHOLE =
		{
			GENERIC = "Sharp hole",
			OPEN = "Deep. Dark",
		},
		WORMHOLE_LIMITED = "Get well soon",
		ACCOMPLISHMENT_SHRINE = "Pretty!", --single player
		LIVINGTREE = "Friend?",
		ICESTAFF = "Chilly stick",
		REVIVER = "Ba-bum. Ba-bum",
		SHADOWHEART = "Cold. But still beating...",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "Story!",
			LINE_2 = "Can't read it",
			LINE_3 = "Black. Lots of black",
			LINE_4 = "Oh! People changing!",
			LINE_5 = "Pretty picture!",
		},
        ATRIUM_STATUE = "Still alive?",
        ATRIUM_LIGHT =
        {
			ON = "Light!",
			OFF = "Not working",
		},
        ATRIUM_GATE =
        {
			ON = "Working now!",
			OFF = "Needs fixing",
			CHARGING = "Oh. What's it doing?",
			DESTABILIZING = "Looks sick",
			COOLDOWN = "Tired?",
        },
        ATRIUM_KEY = "Goes where?",
		LIFEINJECTOR = "Makes strong!",
		SKELETON_PLAYER =
		{
			MALE = "Oh. Friend not alive",
			FEMALE = "Still alive? No",
			ROBOT = "Oh. Not alive",
			DEFAULT = "Oh. Friend not alive",
		},
		HUMANMEAT = "Belly stuff",
		HUMANMEAT_COOKED = "Mmmm...",
		HUMANMEAT_DRIED = "Chewy",
		ROCK_MOON = "Night Ball inside?",
		MOONROCKNUGGET = "Piece of Night Ball",
		MOONROCKCRATER = "Big bump in it",
		MOONROCKSEED = "Makes Night Ball things",

        REDMOONEYE = "Ball with Shiny",
        PURPLEMOONEYE = "Shows on Findy Paper",
        GREENMOONEYE = "Like this one",
        ORANGEMOONEYE = "Shiny shows on Findy Paper",
        YELLOWMOONEYE = "Ooooh. Shiny",
        BLUEMOONEYE = "Glowy ball",

        --Arena Event
        LAVAARENA_BOARLORD = "Nice head branches, boss guy!",
        BOARRIOR = "Twirly Tail is mad",
        BOARON = "Little crawling Twirly Tails",
        PEGHOOK = "Tail Patoo-ies! Watch out!",
        TRAILS = "Likes to hide",
        TURTILLUS = "Spiny Shell likes the spins",
        SNAPPER = "No biting! Bad!",
		RHINODRILL = "Aww... bro love",
		BEETLETAUR = "Where's other eye?",

        LAVAARENA_PORTAL =
        {
            ON = "Can go now",
            GENERIC = "Not working",
        },
        LAVAARENA_KEYHOLE = "Where's key?",
		LAVAARENA_KEYHOLE_FULL = "Open now",
        LAVAARENA_BATTLESTANDARD = "Break it!",
        LAVAARENA_SPAWNER = "Makes the bad guys",

        HEALINGSTAFF = "Make friends better",
        FIREBALLSTAFF = "Fire Pew-er",
        HAMMER_MJOLNIR = "Ugh! Can't lift it",
        SPEAR_GUNGNIR = "Don't like it",
        BLOWDART_LAVA = "Makes lots of patoo-eys",
        BLOWDART_LAVA2 = "Fire!",
        LAVAARENA_LUCY = "Ugh! Don't like chopping!",
        WEBBER_SPIDER_MINION = "Baby Leggy Bugs like helping",
        BOOK_FOSSIL = "Can't read",
		LAVAARENA_BERNIE = "So cute!",
		SPEAR_LANCE = "Pokey stick",
		BOOK_ELEMENTAL = "Calls little Fire Friends",
		LAVAARENA_ELEMENTAL = "Watch out for Fire Friends!",

   		LAVAARENA_ARMORLIGHT = "Clothes make safer",
		LAVAARENA_ARMORLIGHTSPEED = "Zoomy clothes!",
		LAVAARENA_ARMORMEDIUM = "Friends made Safe Clothes!",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Oh! Pokey Clothes!",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Pretty Friend clothes",
		LAVAARENA_ARMORHEAVY = "Really Safe Clothes!",
		LAVAARENA_ARMOREXTRAHEAVY = "Heavy clothes make safe",

		LAVAARENA_FEATHERCROWNHAT = "Zoomy Head Thing",
        LAVAARENA_HEALINGFLOWERHAT = "Oooh! Hello, pretty friend!",
        LAVAARENA_LIGHTDAMAGERHAT = "For safe head keeping",
        LAVAARENA_STRONGDAMAGERHAT = "Branches! Metal branches!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Like this one!",
        LAVAARENA_EYECIRCLETHAT = "Head Thing has the magics!",
        LAVAARENA_RECHARGERHAT = "Pretty head thing!",
        LAVAARENA_HEALINGGARLANDHAT = "Friends! Lots of friends!",
        LAVAARENA_CROWNDAMAGERHAT = "Big branches for head!",

		LAVAARENA_ARMOR_HP = "Safe clothes!",

		LAVAARENA_FIREBOMB = "Scary boomer",
		LAVAARENA_HEAVYBLADE = "Chop cutter",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "Needs belly stuff",
        	FULL = "For you, Sky Mouth!",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Oh. Not alive",
		QUAGMIRE_PARK_FOUNTAIN = "Where's water?",

        QUAGMIRE_HOE = "Dirt comber",

        QUAGMIRE_TURNIP = "Cute little dirt friend",
        QUAGMIRE_TURNIP_COOKED = "Makes good belly stuff",
        QUAGMIRE_TURNIP_SEEDS = "Mystery baby",

        QUAGMIRE_GARLIC = "Mmm... Smelly Dirt thing!",
        QUAGMIRE_GARLIC_COOKED = "Mmm... Smells good",
        QUAGMIRE_GARLIC_SEEDS = "Mystery baby",

        QUAGMIRE_ONION = "Makes wet eyes",
        QUAGMIRE_ONION_COOKED = "Sky Belly will like this",
        QUAGMIRE_ONION_SEEDS = "Mystery baby",

        QUAGMIRE_POTATO = "Thanks, dirt!",
        QUAGMIRE_POTATO_COOKED = "Dirt makes good belly stuff",
        QUAGMIRE_POTATO_SEEDS = "Mystery baby",

        QUAGMIRE_TOMATO = "Oh! Squishy ball",
        QUAGMIRE_TOMATO_COOKED = "Made little red circles",
        QUAGMIRE_TOMATO_SEEDS = "Mystery baby",

        QUAGMIRE_FLOUR = "Dust for belly stuff",
        QUAGMIRE_WHEAT = "Oh! Pretty seeds!",
        QUAGMIRE_WHEAT_SEEDS = "Mystery baby",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Mystery baby",

        QUAGMIRE_ROTTEN_CROP = "Mmm...Smells good",

		QUAGMIRE_SALMON = "Glub Glub from ground",
		QUAGMIRE_SALMON_COOKED = "Sky Belly will like it",
		QUAGMIRE_CRABMEAT = "Branch from Ground Pinchy",
		QUAGMIRE_CRABMEAT_COOKED = "Pinchy makes good belly stuff",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "Sweet Friend!",
			STUMP = "Sorry",
			TAPPED_EMPTY = "Oh, friend. Sorry",
			TAPPED_READY = "Full of friend insides",
			TAPPED_BUGS = "Bugs hurt friend!",
			WOUNDED = "OUCH! Friend hurt",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "What's on hair, friend?",
			PICKED = "Hair cut already",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Hair from friend",
		QUAGMIRE_SPOTSPICE_GROUND = "Makes belly stuff good",
		QUAGMIRE_SAPBUCKET = "Mean Metal Thing",
		QUAGMIRE_SAP = "Friend insides are out now",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Done!",
			GENERIC = "Getting Tasty Rocks",
		},

		QUAGMIRE_POND_SALT = "Full of Tasty Rocks",
		QUAGMIRE_SALT_RACK_ITEM = "Gets the Tasty Rocks",

		QUAGMIRE_SAFE =
		{
			GENERIC = "What's inside?",
			LOCKED = "Where's key?",
		},

		QUAGMIRE_KEY = "Where's lock?",
		QUAGMIRE_KEY_PARK = "Needs lock",
        QUAGMIRE_PORTAL_KEY = "Where's it go?",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Friends! Party!",
			PICKED = "Oh. Friends gone",
		},
		QUAGMIRE_MUSHROOMS = "Hello, friends!",
        QUAGMIRE_MEALINGSTONE = "Crushy rock",
		QUAGMIRE_PEBBLECRAB = "Ground Pinchy!",


		QUAGMIRE_RUBBLE_CARRIAGE = "Where going?",
        QUAGMIRE_RUBBLE_CLOCK = "Tic! Tic! Tic!",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Oh. Fell down",
        QUAGMIRE_RUBBLE_PUBDOOR = "Go anywhere? No",
        QUAGMIRE_RUBBLE_ROOF = "No one home",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "Broken",
        QUAGMIRE_RUBBLE_BIKE = "Can ride it?... Nope",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Hello?",
            "Anyone home?",
            "Oh. No one here",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "What's happened?",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Not working",
        QUAGMIRE_MERMHOUSE = "You home, Glub Glub?",
        QUAGMIRE_SWAMPIG_HOUSE = "Anyone home?",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Oh. Broken",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Wrapped Arm Twirly Tail",
            SLEEPING = "Shhh",
        },
        QUAGMIRE_SWAMPIG = "Fuzzy Wuzzy Twirly Tail",

        QUAGMIRE_PORTAL = "Can't go out",
        QUAGMIRE_SALTROCK = "Rock Tongue Stinger",
        QUAGMIRE_SALT = "Tasty Rocks. Mmmmm...",
        --food--
        QUAGMIRE_FOOD_BURNT = "Oh. Not good",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Made thing for Sky Belly",
            MISMATCH = "Not good",
            MATCH = "Good belly stuff",
            MATCH_BUT_SNACK = "Small belly stuff",
        },

        QUAGMIRE_FERN = "Sky Belly will like it?",
        QUAGMIRE_FOLIAGE_COOKED = "Little belly stuff",
        QUAGMIRE_COIN1 = "Disc for spending",
        QUAGMIRE_COIN2 = "Can buy things now!",
        QUAGMIRE_COIN3 = "Sky Belly says \"Good Job\"",
        QUAGMIRE_COIN4 = "Big fancy spend disc!",
        QUAGMIRE_GOATMILK = "Floppy Ear Soup",
        QUAGMIRE_SYRUP = "Makes the sweet stuff",
        QUAGMIRE_SAP_SPOILED = "No no no!",
        QUAGMIRE_SEEDPACKET = "Aw... Babies!",

        QUAGMIRE_POT = "BIG bubbly water place",
        QUAGMIRE_POT_SMALL = "Hoo! Makes water bubbly!",
        QUAGMIRE_POT_SYRUP = "Makes sweet blubbly",
        QUAGMIRE_POT_HANGER = "Holds clinky thing",
        QUAGMIRE_POT_HANGER_ITEM = "Needs fire",
        QUAGMIRE_GRILL = "Hot bars!",
        QUAGMIRE_GRILL_ITEM = "Needs fire",
        QUAGMIRE_GRILL_SMALL = "Teeny Hot Bars",
        QUAGMIRE_GRILL_SMALL_ITEM = "Needs fire",
        QUAGMIRE_OVEN = "Gives food fire bath",
        QUAGMIRE_OVEN_ITEM = "Makes belly stuff hot",
        QUAGMIRE_CASSEROLEDISH = "Make belly stuff pretty",
        QUAGMIRE_CASSEROLEDISH_SMALL = "Put belly stuff here",
        QUAGMIRE_PLATE_SILVER = "Pretty food holder",
        QUAGMIRE_BOWL_SILVER = "Shiny food place",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Junk trunk", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Wheely Push Thing", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Scary Floppy Ear",
        QUAGMIRE_PARK_ANGEL2 = "Scary Floppy Ear",
        QUAGMIRE_PARK_URN = "Smooth Dust Holder",
        QUAGMIRE_PARK_OBELISK = "Tall sharp stone",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Open now",
            LOCKED = "Where key?",
        },
        QUAGMIRE_PARKSPIKE = "Clinky sharp!",
        QUAGMIRE_CRABTRAP = "Ground Pinchy jail",
        QUAGMIRE_TRADER_MERM = "Gives good things",
        QUAGMIRE_TRADER_MERM2 = "Gives stuff for spend disc",

        QUAGMIRE_GOATMUM = "Soft Floppy Ear Mommy",
        QUAGMIRE_GOATKID = "Small Floppy Ear Sprout",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Oh. Dead",
            GENERIC = "Grey Flap Tweeter",
            SLEEPING = "Sleeper Tweeter",
        },
        QUAGMIRE_LAMP_POST = "Bright light!",

        QUAGMIRE_BEEFALO = "Shaggy Buddy",
        QUAGMIRE_SLAUGHTERTOOL = "Mean things",

        QUAGMIRE_SAPLING = "Small cute!",
        QUAGMIRE_BERRYBUSH = "Sweet friend",

        QUAGMIRE_ALTAR_STATUE2 = "Moss friend house",
        QUAGMIRE_ALTAR_QUEEN = "Tall Still Floppy Ear",
        QUAGMIRE_ALTAR_BOLLARD = "Clinky stump",
        QUAGMIRE_ALTAR_IVY = "Frizzy hair friend",

        QUAGMIRE_LAMP_SHORT = "Light stick",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "Big Rock Flinger!",
        	OFF = "Not on",
        	BURNING = "AGGGHH!",
        	BURNT = "Fire bad",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "Friend made Followy Light!",
        	OFF = "Where's light?",
        	BURNING = "Help! Help!",
        	BURNT = "Oh. So sad",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "Friends made machine feeder",
        	LOWPOWER = "Getting tired",
        	OFF = "Not working",
        	BURNING = "No fire! No!",
        	BURNT = "Fire hurt it",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "Big Machine Feeder!",
        	LOWPOWER = "Sleepy?",
        	OFF = "Oh. Needs sparkly",
        	BURNING = "No fire! No!",
        	BURNT = "Fire hurt it",
        },

        --Wormwood
        COMPOSTWRAP = "Poop good for heart",
        ARMOR_BRAMBLE = "Pokey protection",
        TRAP_BRAMBLE = "Friends made a trap!",

        BOATFRAGMENT03 = "Floaty got broken",
        BOATFRAGMENT04 = "Floaty got broken",
        BOATFRAGMENT05 = "Floaty got broken",
		BOAT_LEAK = "Floaty is spitting!",
        MAST = "Hello! Helping, Friend?",
        SEASTACK = "Oops! Watch out!",
        FISHINGNET = "Catches Glub Glubs", --unimplemented
        ANTCHOVIES = "Aww... so cute!", --unimplemented
        STEERINGWHEEL = "Which way?",
        ANCHOR = "Won't let Floaty move",
        BOATPATCH = "Floaty Fixer",
        DRIFTWOOD_TREE =
        {
            BURNING = "No!!! Stop!",
            BURNT = "So sad. So sad",
            CHOPPED = "Oh. Sorry",
            GENERIC = "Hello, Watery Friend!",
        },

        DRIFTWOOD_LOG = "Going for swim, friend?",

        MOON_TREE =
        {
            BURNING = "HELP!! HELP!!",
            BURNT = "(sob)",
            CHOPPED = "So sad",
            GENERIC = "Friend likes Night Ball",
        },
		MOON_TREE_BLOSSOM = "Lost?",

        MOONBUTTERFLY =
        {
        	GENERIC = "Hehe! Glowy!",
        	HELD = "Hello, Flappy friend!",
        },
		MOONBUTTERFLYWINGS = "Can't fly with them",
        MOONBUTTERFLY_SAPLING = "Keep growing! You can do it!",
        ROCK_AVOCADO_FRUIT = "Too crusty",
        ROCK_AVOCADO_FRUIT_RIPE = "Rocks for belly",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Cooked belly stuff",
        ROCK_AVOCADO_FRUIT_SPROUT = "Baby friend needs dirt",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "Rest well, old friend",
			WITHERED = "Hot enough for you?",
			GENERIC = "Grows rocks for belly",
			PICKED = "No belly rocks yet",
			DISEASED = "Oh no! Friend is sick!", --unimplemented
            DISEASING = "Feeling okay, friend?", --unimplemented
			BURNING = "NOOO! AGH! HELP!",
		},
        DEAD_SEA_BONES = "Dead?",
        HOTSPRING =
        {
        	GENERIC = "Pool party!",
        	BOMBED = "Warm now. Glowy",
        	GLASS = "Ice? Nope",
			EMPTY = "Muddy.",
        },
        MOONGLASS = "Ouch! Sharp!",
        MOONGLASS_CHARGED = "Glowy sharp things",
        MOONGLASS_ROCK = "Clear Rock",
        BATHBOMB = "Friends made a ball!",
        TRAP_STARFISH =
        {
            GENERIC = "Nice teeth!",
            CLOSED = "Snap!",
        },
        DUG_TRAP_STARFISH = "Got it!",
        SPIDER_MOON =
        {
        	GENERIC = "Night Ball make you mad?",
        	SLEEPING = "Shh... sleepy",
        	DEAD = "Oh. So sorry",
        },
        MOONSPIDERDEN = "Hello? Anyone here?",
		FRUITDRAGON =
		{
			GENERIC = "Growing belly stuff",
			RIPE = "Feeling warm...",
			SLEEPING = "Naptime",
		},
        PUFFIN =
        {
            GENERIC = "Swimmy Tweeter",
            HELD = "Hello there!",
            SLEEPING = "Night night",
        },

		MOONGLASSAXE = "Clear Rock Chopper",
		GLASSCUTTER = "Swoosh!",

        ICEBERG =
        {
            GENERIC = "Big Cold Water Rock!", --unimplemented
            MELTED = "Oh. Water now", --unimplemented
        },
        ICEBERG_MELTED = "Oh. Water now", --unimplemented

        MINIFLARE = "Makes pretty lights",

		MOON_FISSURE =
		{
			GENERIC = "Makes head say 'Wee-aow, Wee-aow'",
			NOLIGHT = "Hello? No one there",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Needs more things",
            GENERIC = "Saying stuff",
        },

        MOON_ALTAR_IDOL = "Oh... glowy!",
        MOON_ALTAR_GLASS = "What's this for?",
        MOON_ALTAR_SEED = "Glow ball! Fun!",

        MOON_ALTAR_ROCK_IDOL = "Trapped?",
        MOON_ALTAR_ROCK_GLASS = "Trapped?",
        MOON_ALTAR_ROCK_SEED = "Trapped?",

        MOON_ALTAR_CROWN = "Lost?",
        MOON_ALTAR_COSMIC = "Soon",

        MOON_ALTAR_ASTRAL = "Ready?",
        MOON_ALTAR_ICON = "Silly! Home not under dirt",
        MOON_ALTAR_WARD = "Lonely. Find friends",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Can build Floaty stuff",
            BURNT = "Fire... (sigh)",
        },
        BOAT_ITEM = "Needs water",
        STEERINGWHEEL_ITEM = "For pointing Floaty",
        ANCHOR_ITEM = "Heavy...",
        MAST_ITEM = "Tall friend for Floater.",
        MUTATEDHOUND =
        {
        	DEAD = "Dead now?",
        	GENERIC = "Where clothes, Woofer?",
        	SLEEPING = "Shh... Sleepytime",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Oh. Dead",
			GENERIC = "You okay, Woddle Woddle?",
			SLEEPING = "Naptime",
		},
        CARRAT =
        {
        	DEAD = "Oh. Dead",
        	GENERIC = "Belly stuff running away!",
        	HELD = "He he. Funny little tail",
        	SLEEPING = "Sleepytime",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Water friends!",
            PICKED = "Yum!",
        },
		BULLKELP_ROOT = "Friends made a Snappy!",
        KELPHAT = "Slimy Head Thing looks good",
		KELP = "Belly stuff?",
		KELP_COOKED = "Mmmm... slimy!",
		KELP_DRIED = "Crunchy",

		GESTALT = "Saying something?",
        GESTALT_GUARD = "Protect",

		COOKIECUTTER = "Oh. Hello!",
		COOKIECUTTERSHELL = "Spiky home",
		COOKIECUTTERHAT = "Spiny hat",
		SALTSTACK =
		{
			GENERIC = "Lumpy",
			MINED_OUT = "All gone",
			GROWING = "Growing back",
		},
		SALTROCK = "Hmm...",
		SALTBOX = "Salty Food Holder",

		TACKLESTATION = "Help catch Glub Glubs",
		TACKLESKETCH = "Glub Glub pictures",

        MALBATROSS = "Big Tweeter",
        MALBATROSS_FEATHER = "Big Tweeter clothes",
        MALBATROSS_BEAK = "Tweeter nose",
        MAST_MALBATROSS_ITEM = "New friend for Floater",
        MAST_MALBATROSS = "Came from Tweeter",
		MALBATROSS_FEATHERED_WEAVE = "Feather cloth",

        GNARWAIL =
        {
            GENERIC = "Pointy head",
            BROKENHORN = "Not so pointy head",
            FOLLOWER = "Pointy head friend!",
            BROKENHORN_FOLLOWER = "Friend lost pointy bit",
        },
        GNARWAIL_HORN = "Sharp!",

        WALKINGPLANK = "Splashy jump spot",
        OAR = "Friend helps push water",
		OAR_DRIFTWOOD = "Friend helps push water fast!",

		OCEANFISHINGROD = "Strong Glub Glub stick",
		OCEANFISHINGBOBBER_NONE = "Missing thing...",
        OCEANFISHINGBOBBER_BALL = "Floaty thing",
        OCEANFISHINGBOBBER_OVAL = "Floaty thing",
		OCEANFISHINGBOBBER_CROW = "Floaty thing",
		OCEANFISHINGBOBBER_ROBIN = "Floaty thing",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "Floaty thing",
		OCEANFISHINGBOBBER_CANARY = "Floaty thing",
		OCEANFISHINGBOBBER_GOOSE = "Floaty thing",
		OCEANFISHINGBOBBER_MALBATROSS = "Floaty thing",

		OCEANFISHINGLURE_SPINNER_RED = "Glub Glub belly stuff",
		OCEANFISHINGLURE_SPINNER_GREEN = "Glub Glub belly stuff",
		OCEANFISHINGLURE_SPINNER_BLUE = "Glub Glub belly stuff",
		OCEANFISHINGLURE_SPOON_RED = "Glub Glub belly stuff",
		OCEANFISHINGLURE_SPOON_GREEN = "Glub Glub belly stuff",
		OCEANFISHINGLURE_SPOON_BLUE = "Glub Glub belly stuff",
		OCEANFISHINGLURE_HERMIT_RAIN = "For raining time",
		OCEANFISHINGLURE_HERMIT_SNOW = "For snow time",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Dizzy...",
		OCEANFISHINGLURE_HERMIT_HEAVY = "Oh. Heavy",

		OCEANFISH_SMALL_1 = "Small Glub Glub",
		OCEANFISH_SMALL_2 = "Small Glub Glub",
		OCEANFISH_SMALL_3 = "Small Glub Glub",
		OCEANFISH_SMALL_4 = "Small Glub Glub",
		OCEANFISH_SMALL_5 = "Popped Glub Glub",
		OCEANFISH_SMALL_6 = "Friends?",
		OCEANFISH_SMALL_7 = "Friend?",
		OCEANFISH_SMALL_8 = "Hot!",
        OCEANFISH_SMALL_9 = "Funny Glub Glub",

		OCEANFISH_MEDIUM_1 = "Oooh, mud!",
		OCEANFISH_MEDIUM_2 = "Big Glub Glub",
		OCEANFISH_MEDIUM_3 = "Pointy Glub Glub",
		OCEANFISH_MEDIUM_4 = "Good for belly",
		OCEANFISH_MEDIUM_5 = "Is friend?",
		OCEANFISH_MEDIUM_6 = "Pretty Glub Glub",
		OCEANFISH_MEDIUM_7 = "Gold Glub Glub",
		OCEANFISH_MEDIUM_8 = "Cold!",
        OCEANFISH_MEDIUM_9 = "Glub Glub smell sweet like fruit!",

		PONDFISH = "Glub Glub",
		PONDEEL = "Sea Wiggly",

        FISHMEAT = "Glub Glub",
        FISHMEAT_COOKED = "Watch for bones",
        FISHMEAT_SMALL = "Wee Glub Glub",
        FISHMEAT_SMALL_COOKED = "Cute little belly stuff",
		SPOILED_FISH = "Smells good. Mmmmm...",

		FISH_BOX = "Glub Glubs go in there",
        POCKET_SCALE = "Weigh thing",

		TACKLECONTAINER = "Glub Glub stuff",
		SUPERTACKLECONTAINER = "More Glub Glub stuff",

		TROPHYSCALE_FISH =
		{
			GENERIC = "Glub Glub holder",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nHeavy Glub Glub",
			BURNING = "On fire!",
			BURNT = "Gone",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nBig!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nHeavy Glub Glub",
		},

		OCEANFISHABLEFLOTSAM = "Oh! Mud!",

		CALIFORNIAROLL = "Rolled Glub Glub",
		SEAFOODGUMBO = "Glub Glub stew",
		SURFNTURF = "Fills belly",

        WOBSTER_SHELLER = "Snappy Glub Glub",
        WOBSTER_DEN = "Wet nest",
        WOBSTER_SHELLER_DEAD = "Oh. Belly stuff now.",
        WOBSTER_SHELLER_DEAD_COOKED = "Why changed color?",

        LOBSTERBISQUE = "Still snappy?",
        LOBSTERDINNER = "For belly",

        WOBSTER_MOONGLASS = "Moony Snappy Glub Glub",
        MOONGLASS_WOBSTER_DEN = "Moony wet nest",

		TRIDENT = "Pokey",

		WINCH =
		{
			GENERIC = "Thing lifter",
			RETRIEVING_ITEM = "Bringing thing",
			HOLDING_ITEM = "Got thing",
		},

        HERMITHOUSE = {
            GENERIC = "Sad shell...",
            BUILTUP = "Happy now",
        },

        SHELL_CLUSTER = "Shells!",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "It sings",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "It sings",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "It sings",
        },

        CHUM = "Glub Glub belly stuff",

        SUNKENCHEST =
        {
            GENERIC = "Shell stuff",
            LOCKED = "Oh. Locked",
        },

        HERMIT_BUNDLE = "Thank you!",
        HERMIT_BUNDLE_SHELLS = "Shells shell",

        RESKIN_TOOL = "Dusty changer",
        MOON_FISSURE_PLUGGED = "Can't hear them",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Biiiiig woofer!",
            "Biiiiig woofer!",
        },
        WOBYSMALL =
        {
            "Pat pat!",
            "Pat pat!",
        },
		WALTERHAT = "Look like friend!",
		SLINGSHOT = "Pew pew!",
		SLINGSHOTAMMO_ROCK = "Pew pew things",
		SLINGSHOTAMMO_MARBLE = "Pew pew things",
		SLINGSHOTAMMO_THULECITE = "Pew pew things",
        SLINGSHOTAMMO_GOLD = "Pew pew things",
        SLINGSHOTAMMO_SLOW = "Pew pew things",
        SLINGSHOTAMMO_FREEZE = "Pew pew things",
		SLINGSHOTAMMO_POOP = "Poop things",
        PORTABLETENT = "Soft house",
        PORTABLETENT_ITEM = "Not done yet",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Biiiig mouth sounds",
        BATTLESONG_HEALTHGAIN = "Biiiig mouth sounds",
        BATTLESONG_SANITYGAIN = "Biiiig mouth sounds",
        BATTLESONG_SANITYAURA = "Biiiig mouth sounds",
        BATTLESONG_FIRERESISTANCE = "Biiiig mouth sounds",
        BATTLESONG_INSTANT_TAUNT = "Funny words",
        BATTLESONG_INSTANT_PANIC = "Funny words",

        -- Webber
        MUTATOR_WARRIOR = "Belly stuff for Leggy Bugs?",
        MUTATOR_DROPPER = "Belly stuff for Leggy Bugs?",
        MUTATOR_HIDER = "Belly stuff for Leggy Bugs?",
        MUTATOR_SPITTER = "Belly stuff for Leggy Bugs?",
        MUTATOR_MOON = "Belly stuff for Leggy Bugs?",
        MUTATOR_HEALER = "Belly stuff for Leggy Bugs?",
        SPIDER_WHISTLE = "Fweee!",
        SPIDERDEN_BEDAZZLER = "Making pretty things",
        SPIDER_HEALER = "Takes care of leggy friends",
        SPIDER_REPELLENT = "Clicky-clack!",
        SPIDER_HEALER_ITEM = "Gloopy",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "For ghost friend",
		GHOSTLYELIXIR_FASTREGEN = "For ghost friend",
		GHOSTLYELIXIR_SHIELD = "For ghost friend",
		GHOSTLYELIXIR_ATTACK = "For ghost friend",
		GHOSTLYELIXIR_SPEED = "For ghost friend",
		GHOSTLYELIXIR_RETALIATION = "For ghost friend",
		SISTURN =
		{
			GENERIC = "Lonely",
			SOME_FLOWERS = "Friends!",
			LOTS_OF_FLOWERS = "Nice here",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "For belly stuff",
            DONE = "All done!",

			COOKING_LONG = "Do dee doo...",
			COOKING_SHORT = "Done soon",
			EMPTY = "Empty...",
        },

        PORTABLEBLENDER_ITEM = "Chops belly stuff",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "What's it do?",
            DONE = "Made pile of tasty dirt",
        },
        SPICEPACK = "Pack for belly stuff!",
        SPICE_GARLIC = "(sniff) ahh-CHOO!",
        SPICE_SUGAR = "Sweet tasty juice!",
        SPICE_CHILI = "Makes mouth on fire!",
        SPICE_SALT = "Tasty rocks!",
        MONSTERTARTARE = "Nope",
        FRESHFRUITCREPES = "Sweet belly stuff",
        FROGFISHBOWL = "Yum yums!",
        POTATOTORNADO = "Whirly Swirly!",
        DRAGONCHILISALAD = "Eating bits",
        GLOWBERRYMOUSSE = "Glowy chomp-stuff",
        VOLTGOATJELLY = "Friend made. With Love",
        NIGHTMAREPIE = "Scare nibbles",
        BONESOUP = "Yum Broth",
        MASHEDPOTATOES = "Tasty goop",
        POTATOSOUFFLE = "Different Potato",
        MOQUECA = "Made by friend",
        GAZPACHO = "Friend made Liquid",
        ASPARAGUSSOUP = "Swimming sticks",
        VEGSTINGER = "Tangy water",
        BANANAPOP = "Frozen friend hair",
        CEVICHE = "Belly goop",
        SALSA = "Tasty mush",
        PEPPERPOPPER = "Yummy bites",

        TURNIP = "Cute little dirt friend",
        TURNIP_COOKED = "Makes good belly stuff",
        TURNIP_SEEDS = "Mystery baby",

        GARLIC = "Mmm... Smelly Dirt thing!",
        GARLIC_COOKED = "Mmm... Smells good",
        GARLIC_SEEDS = "Mystery baby",

        ONION = "Makes eyes wet",
        ONION_COOKED = "Smells nice",
        ONION_SEEDS = "Mystery baby",

        POTATO = "Thanks, dirt!",
        POTATO_COOKED = "Dirt makes good belly stuff",
        POTATO_SEEDS = "Mystery baby",

        TOMATO = "Oh! Squishy ball",
        TOMATO_COOKED = "Made little red circles",
        TOMATO_SEEDS = "Mystery baby",

        ASPARAGUS = "Sticks for belly",
        ASPARAGUS_COOKED = "Smells pointy",
        ASPARAGUS_SEEDS = "Grows the belly sticks",

        PEPPER = "Aww... cute!",
        PEPPER_COOKED = "Oh. Smells like fire",
        PEPPER_SEEDS = "Mystery baby",

        WEREITEM_BEAVER = "Friend Eater!",
        WEREITEM_GOOSE = "Tweeter?",
        WEREITEM_MOOSE = "Small Branch Head",

        MERMHAT = "Glub Glub pretend face",
        MERMTHRONE =
        {
            GENERIC = "Place for big Glub Glub",
            BURNT = "Oh. Gone",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "Making something",
            BURNT = "All gone",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Glub Glub house",
            BURNT = "Oh...",
        },

        MERMWATCHTOWER_REGULAR = "Glub Glubs happy",
        MERMWATCHTOWER_NOKING = "Glub Glubs inside",
        MERMKING = "King Glub Glub",
        MERMGUARD = "Friends?",
        MERM_PRINCE = "Special Glub Glub?",

        SQUID = "Bright Eye Glub Glub",

		GHOSTFLOWER = "Friend...?",
        SMALLGHOST = "Floaty is... sad?",

        CRABKING =
        {
            GENERIC = "Crabby...",
            INERT = "Something missing?",
        },
		CRABKING_CLAW = "Scary!",

		MESSAGEBOTTLE = "Holding thing",
		MESSAGEBOTTLEEMPTY = "Empty",

        MEATRACK_HERMIT =
        {
            DONE = "Done",
            DRYING = "Getting unwet",
            DRYINGINRAIN = "Rain can't help",
            GENERIC = "Need food?",
            BURNT = "Oh",
            DONE_NOTMEAT = "Done?",
            DRYING_NOTMEAT = "Getting unwet",
            DRYINGINRAIN_NOTMEAT = "Rain not helping",
        },
        BEEBOX_HERMIT =
        {
            READY = "Buzz Juice ready!",
            FULLHONEY = "Buzz Juice ready!",
            GENERIC = "Buzzing...",
            NOHONEY = "Empty",
            SOMEHONEY = "Wait",
            BURNT = "Fire breaks everything",
        },

        HERMITCRAB = "Crabby",

        HERMIT_PEARL = "Shiny!",
        HERMIT_CRACKED_PEARL = "Broken...",

        -- DSEAS
        WATERPLANT = "Big friend!",
        WATERPLANT_BOMB = "Stop, friend!",
        WATERPLANT_BABY = "Baby friend",
        WATERPLANT_PLANTER = "Find nice spot for friend",

        SHARK = "Bad chomper!",

        MASTUPGRADE_LAMP_ITEM = "Night light",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "Zzzzt catcher",

        WATERPUMP = "Sploosh!",

        BARNACLE = "Hiding?",
        BARNACLE_COOKED = "Chewy",

        BARNACLEPITA = "Goes in belly now",
        BARNACLESUSHI = "Belly stuff",
        BARNACLINGUINE = "Strings of belly stuff",
        BARNACLESTUFFEDFISHHEAD = "Glub Glubs?",

        LEAFLOAF = "Is friend? Or not friend?",
        LEAFYMEATBURGER = "Hmmm",
        LEAFYMEATSOUFFLE = "Wiggly",
        MEATYSALAD = "Friends? No?",

        -- GROTTO

		MOLEBAT = "Big sniffer",
        MOLEBATHILL = "Sleeping",

        BATNOSE = "Chewy",
        BATNOSE_COOKED = "Crispy",
        BATNOSEHAT = "Food? No. Hat?",

        MUSHGNOME = "Mushy friend!",

        SPORE_MOON = "Pop!",

        MOON_CAP = "Sleepytime",
        MOON_CAP_COOKED = "Wakey wakey",

        MUSHTREE_MOON = "Friend looks different",

        LIGHTFLIER = "Buzzy",

        GROTTO_POOL_BIG = "Clear rock water",
        GROTTO_POOL_SMALL = "Clear rock water",

        DUSTMOTH = "Sweep Sweep",

        DUSTMOTHDEN = "Home for Sweep Sweep",

        ARCHIVE_LOCKBOX = "Plant this in funny floor",
        ARCHIVE_CENTIPEDE = "Ouchie roll bug awake!",
        ARCHIVE_CENTIPEDE_HUSK = "Sleeping. Shhh",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "Waiting...",
            COOKING_SHORT = "Done soon",
            DONE = "Done!",
            EMPTY = "Dusty",
            BURNT = "Oh",
        },

        ARCHIVE_MOON_STATUE = "Friends of night ball",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "Skritch scratches",
            LINE_2 = "Pretty",
            LINE_3 = "Skritch scratches",
            LINE_4 = "Pretty",
            LINE_5 = "Skritch scratches",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "That way",
            IDLE = "Done",
        },

        ARCHIVE_RESONATOR_ITEM = "Hmmmm",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "Sleeping",
          GENERIC =  "Not for watering?",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "Sleeping",
            GENERIC = "Woke up",
        },

        ARCHIVE_SECURITY_PULSE = "Come back friend!",

        ARCHIVE_SWITCH = {
            VALID = "Awake",
            GEMS = "Missing...",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Door?",
            GENERIC = "Stuck closed",
        },

        WALL_STONE_2 = "Solid",
        WALL_RUINS_2 = "Strong",

        REFINED_DUST = "Dusty",
        DUSTMERINGUE = "Sweep Sweep belly stuff",

        SHROOMCAKE = "Squishy",

        NIGHTMAREGROWTH = "Bad things",

        TURFCRAFTINGSTATION = "Make dirt!",

        MOON_ALTAR_LINK = "Seed",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Yum!",
            WET = "Too wet",
            DRY = "Too dry",
            BALANCED = "Is good",
            BURNT = "Nooooo!",
        },
        COMPOST = "Mmmm...",
        SOIL_AMENDER =
		{
			GENERIC = "Drink stuff, good for friends",
			STALE = "Getting better",
			SPOILED = "Really good!",
		},

		SOIL_AMENDER_FERMENTED = "Really-really good!",

        WATERINGCAN =
        {
            GENERIC = "Drink can",
            EMPTY = "Oh. Empty",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "Fancy drink can",
            EMPTY = "Oh. Empty",
        },

		FARM_PLOW = "Make ground soft and nice",
		FARM_PLOW_ITEM = "Where will friends live?",
		FARM_HOE = "Tuck in babies",
		GOLDEN_FARM_HOE = "Pretty dirt mover",
		NUTRIENTSGOGGLESHAT = "Friend looks cozy there",
		PLANTREGISTRYHAT = "Wear friend on head!",

        FARM_SOIL_DEBRIS = "Friends don't like it",

		FIRENETTLES = "Hot hot friends",
		FORGETMELOTS = "Pretty friends",
		SWEETTEA = "Mmmm... ahhh",
		TILLWEED = "Stubborn friends",
		TILLWEEDSALVE = "Thank you friends!",
        WEED_IVY = "Pointy friends",
        IVY_SNARE = "Oooh, friends got mad",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Friend holder",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nGood job!",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nProud of you!",
            HAS_ITEM_LIGHT = "Did their best",
			BURNING = "No! Oh no!",
			BURNT = "Gone...",
        },

        CARROT_OVERSIZED = "Good job!",
        CORN_OVERSIZED = "Biiiig belly stuff!",
        PUMPKIN_OVERSIZED = "So big!",
        EGGPLANT_OVERSIZED = "Big tasty!",
        DURIAN_OVERSIZED = "Big smell",
        POMEGRANATE_OVERSIZED = "Big seedy fruit",
        DRAGONFRUIT_OVERSIZED = "Pretty! Big!",
        WATERMELON_OVERSIZED = "Big watery fruit",
        TOMATO_OVERSIZED = "Big squishy ball",
        POTATO_OVERSIZED = "Big!",
        ASPARAGUS_OVERSIZED = "Big pointy",
        ONION_OVERSIZED = "Crunchy",
        GARLIC_OVERSIZED = "Mmmm!",
        PEPPER_OVERSIZED = "Hot hot belly stuff",

        VEGGIE_OVERSIZED_ROTTEN = "So sorry",

		FARM_PLANT =
		{
			GENERIC = "Friend",
			SEED = "Baby",
			GROWING = "Doing so good!",
			FULL = "Good job!",
			ROTTEN = "Oh",
			FULL_OVERSIZED = "Biiiig!",
			ROTTEN_OVERSIZED = "So sorry",
			FULL_WEED = "Don't bully other friends!",

			BURNING = "Oh no oh no!",
		},

        FRUITFLY = "Mean!",
        LORDFRUITFLY = "No! Leave friends alone!",
        FRIENDLYFRUITFLY = "Nice to friends",
        FRUITFLYFRUIT = "Fruit bug friend maker",

        SEEDPOUCH = "Seed carry-arounder",

		-- Crow Carnival
		CARNIVAL_HOST = "Oooh, Big Tweeter!",
		CARNIVAL_CROWKID = "Hello!",
		CARNIVAL_GAMETOKEN = "Shiny",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "Win paper",
			GENERIC_SMALLSTACK = "Lots of win papers",
			GENERIC_LARGESTACK = "Lots and lots of win papers!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "Hello? Hiding?",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "Needs shiny",
			PLAYING = "Tweeters hungry",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "Tweeter games!",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Wigglers!",

		CARNIVALGAME_MEMORY_KIT = "Tweeter games!",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "Needs shiny",
			PLAYING = "Remembery game, hmm...",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "Hello? Hiding?",
			PLAYING = "That one!",
		},

		CARNIVALGAME_HERDING_KIT = "Tweeter games!",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "Needs shiny",
			PLAYING = "Run run run!",
		},
		CARNIVALGAME_HERDING_CHICK = "Over here!",

		CARNIVAL_PRIZEBOOTH_KIT = "Make house for Tweeter treasure",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Trade?",
		},

		CARNIVALCANNON_KIT = "Not finished yet",
		CARNIVALCANNON =
		{
			GENERIC = "Boom maker",
			COOLDOWN = "Boom!",
		},

		CARNIVAL_PLAZA_KIT = "New friend!",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Make fancy?",
			LEVEL_2 = "Big Tweeters like decoration",
			LEVEL_3 = "Oooh, friend look so nice!",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "Prize!",
		CARNIVALDECOR_EGGRIDE = "Wheee!",

		CARNIVALDECOR_LAMP_KIT = "Prize!",
		CARNIVALDECOR_LAMP = "Friend make nice glowy light",
		CARNIVALDECOR_PLANT_KIT = "Find nice place for friend",
		CARNIVALDECOR_PLANT = "Short friend",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "Fancy",
			UNCOMMON = "Pretty",
			GENERIC = "Ooooh",
		},
		CARNIVALDECOR_FIGURE_KIT = "Surprise",

        CARNIVAL_BALL = "Bouncy bounce", --unimplemented
		CARNIVAL_SEEDPACKET = "Thanks Tweeters!",
		CARNIVALFOOD_CORNTEA = "Mmmm",

        CARNIVAL_VEST_A = "Made of friend hair!",
        CARNIVAL_VEST_B = "Look just like tall friends",
        CARNIVAL_VEST_C = "Friend hair tickles",

        -- YOTB
        YOTB_SEWINGMACHINE = "Clothes maker",
        YOTB_SEWINGMACHINE_ITEM = "Clothes maker bits",
        YOTB_STAGE = "Hello!",
        YOTB_POST =  "Friend watch Shaggy Buddy please",
        YOTB_STAGE_ITEM = "Where to plant?",
        YOTB_POST_ITEM =  "Put on ground",


        YOTB_PATTERN_FRAGMENT_1 = "Huh? Not finished",
        YOTB_PATTERN_FRAGMENT_2 = "Huh? Not finished",
        YOTB_PATTERN_FRAGMENT_3 = "Huh? Not finished",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "Squishy!",
            YOTB = "Show to shaggy hidey man",
        },

        WAR_BLUEPRINT = "Scary!",
        DOLL_BLUEPRINT = "Aww",
        FESTIVE_BLUEPRINT = "Pretty",
        ROBOT_BLUEPRINT = "Machine?",
        NATURE_BLUEPRINT = "Covered in friends",
        FORMAL_BLUEPRINT = "Fancy",
        VICTORIAN_BLUEPRINT = "Lots of work...",
        ICE_BLUEPRINT = "Brrr!",
        BEAST_BLUEPRINT = "Lucky!",

        BEEF_BELL = "Ding dong",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "Where friends live",
            BURNT = "Fire very bad",
			PLAYING_HIDEANDSEEK = "Friends out playing",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "Hidey game ending soon",
		},

		KITCOONDEN_KIT = "Makes house for friends",

		TICOON = 
		{
			GENERIC = "Big fur friend",
			ABANDONED = "Please come back",
			SUCCESS = "Friend found friend",
			LOST_TRACK = "Someone found friend first",
			NEARBY = "Friend near us",
			TRACKING = "Should follow friend",
			TRACKING_NOT_MINE = "Looking for other friend",
			NOTHING_TO_TRACK = "Nothing to find",
			TARGET_TOO_FAR_AWAY = "Friends are very far",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "Kitty likes box",
            EMPTY = "Wants to play?",
            BURNT = "Fire so evil",
        },

		KITCOON_FOREST = "Looks like friend hair",
		KITCOON_SAVANNA = "Friend full of lines",
		KITCOON_MARSH = "Friend is soggy",
		KITCOON_DECIDUOUS = "Small fur friend",
		KITCOON_GRASS = "Scared friend?",
		KITCOON_ROCKY = "Rocky friend",
		KITCOON_DESERT = "Hear me, friend?",
		KITCOON_MOON = "Friend likes night ball",
		KITCOON_YOT = "Happy friend",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "From Night Ball?",
            DEAD = "Good night",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "Not happy!",
            DEAD = "Sleeping again?",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "Spiky wall",
        ALTERGUARDIAN_PHASE3 = "Very very mad!",
        ALTERGUARDIAN_PHASE3TRAP = "Sleepy rocks",
        ALTERGUARDIAN_PHASE3DEADORB = "Hello sometimes-there man",
        ALTERGUARDIAN_PHASE3DEAD = "Just rocks",

        ALTERGUARDIANHAT = "Helps hear them",
        ALTERGUARDIANHATSHARD = "Hmm...",

        MOONSTORM_GLASS = {
            GENERIC = "Just sharp",
            INFUSED = "Sharp glowy!"
        },

        MOONSTORM_STATIC = "Little fire?",
        MOONSTORM_STATIC_ITEM = "Safe inside",
        MOONSTORM_SPARK = "Zzzt?",

        BIRD_MUTANT = "Tweeter okay?",
        BIRD_MUTANT_SPITTER = "Tweeter sick?",

        WAGSTAFF_NPC = "Hello! Oh, goodbye... oh, hello!",
        ALTERGUARDIAN_CONTAINED = "Locked away",

        WAGSTAFF_TOOL_1 = "Thing?",
        WAGSTAFF_TOOL_2 = "Here it is!",
        WAGSTAFF_TOOL_3 = "Found it!",
        WAGSTAFF_TOOL_4 = "Funny thing",
        WAGSTAFF_TOOL_5 = "Flickery",

        MOONSTORM_GOGGLESHAT = "Belly stuff... for head?",

        MOON_DEVICE = {
            GENERIC = "Oooooh!",
            CONSTRUCTION1 = "Lots to do",
            CONSTRUCTION2 = "Almost done",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Tick tock tick tock",
			RECHARGING = "Tock tick tock tick",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Tick tock tick tock",
			RECHARGING = "Tock tick tock tick",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Tick tock tick tock",
			RECHARGING = "Tock tick tock tick",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Tick tock tick tock",
			RECHARGING = "Tock tick tock tick",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Tick tock tick tock",
			RECHARGING = "Tock tick tock tick",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Hurty Tick Tock",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Tick Tock insides",
        POCKETWATCH_DISMANTLER = "Full of funny little sticks",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Spinny hole",
			DIFFERENTSHARD = "Spinny hole",
		},
        POCKETWATCH_PORTAL_EXIT = "Spinny sky hole",

        -- Waterlog
        WATERTREE_PILLAR = "Biiiiig friend!",
        OCEANTREE = "Friends like water",
        OCEANTREENUT = "Baby friend growing",
        WATERTREE_ROOT = "Oh! Don't bump into friends!",

        OCEANTREE_PILLAR = "Biiig friend!",
        
        OCEANVINE = "Wants to give fruit",
        FIG = "From hanging tree friend",
        FIG_COOKED = "Sweet yums",

        SPIDER_WATER = "Tall Leggy Bug",
        MUTATOR_WATER = "Belly stuff for Leggy Bugs?",
        OCEANVINE_COCOON = "Made house in friend",
        OCEANVINE_COCOON_BURNT = "No more house",

        GRASSGATOR = "Friend?",

        TREEGROWTHSOLUTION = "Tree friends like it!",

        FIGATONI = "Sweet pocket",
        FIGKABAB = "Friend helped!",
        KOALEFIG_TRUNK = "Think is for belly...?",
        FROGNEWTON = "Squishy",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "Friend stuck inside?",
            CRIMSON = "Ohhh, friend looks sick!",
            ENABLED = "Friend free!",
			WAITING_FOR_DARK = "Oooooh, friend is pretty!",
			COOLDOWN = "Where friend go?",
			SPAWN_DISABLED = "Closed up",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Muscle man home",
            BURNT = "Oh... poor muscle man...",
        },

        DUMBBELL = "Rocks",
        DUMBBELL_GOLDEN = "Heavy!",
		DUMBBELL_MARBLE = "Heaaavy rocks",
        DUMBBELL_GEM = "Sparkly rocks",
        POTATOSACK = "Carry friends",


        TERRARIUMCHEST = 
		{
			GENERIC = "Shiny gone...",
			BURNT = "Oh",
			SHIMMER = "Shiny stuff",
		},

		EYEMASKHAT = "Friend is watching",

        EYEOFTERROR = "Biiiig peeper!",
        EYEOFTERROR_MINI = "Little peepers",
        EYEOFTERROR_MINI_GROUNDED = "Peeper baby?",

        FROZENBANANADAIQUIRI = "Cold friend water",
        BUNNYSTEW = "Poor Hopper...",
        MILKYWHITES = "Peeper goop",

        CRITTER_EYEOFTERROR = "Little peeper friend!",

        SHIELDOFTERROR ="Chomp chomp!",
        TWINOFTERROR1 = "Big machine peeper!",
        TWINOFTERROR2 = "Big machine peeper!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "Squeak squeak",
        KITCOON_NAMETAG = "For furry friends to wear",

		KITCOONDECOR1 =
        {
            GENERIC = "Tweeter likes to dance",
            BURNT = "No! Fire took tweeter",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "Glub glub is stuck",
            BURNT = "No! Fire took glub glub",
        },

		KITCOONDECOR1_KIT = "Makes toy for friends",
		KITCOONDECOR2_KIT = "Makes toy for friends",

        -- WX78
        WX78MODULE_MAXHEALTH = "Beep boops",
        WX78MODULE_MAXSANITY1 = "Beep boops",
        WX78MODULE_MAXSANITY = "Beep boops",
        WX78MODULE_MOVESPEED = "Beep boops",
        WX78MODULE_MOVESPEED2 = "Beep boops",
        WX78MODULE_HEAT = "Beep boops",
        WX78MODULE_NIGHTVISION = "Beep boops",
        WX78MODULE_COLD = "Beep boops",
        WX78MODULE_TASER = "Beep boops",
        WX78MODULE_LIGHT = "Beep boops",
        WX78MODULE_MAXHUNGER1 = "Beep boops",
        WX78MODULE_MAXHUNGER = "Beep boops",
        WX78MODULE_MUSIC = "Beep boops",
        WX78MODULE_BEE = "Beep boops",
        WX78MODULE_MAXHEALTH2 = "Beep boops",

        WX78_SCANNER = 
        {
            GENERIC ="Little friend of robot friend",
            HUNTING = "Little friend of robot friend",
            SCANNING = "Little friend of robot friend",
        },

        WX78_SCANNER_ITEM = "Little friend of robot friend",
        WX78_SCANNER_SUCCEEDED = "Blinky blink",

        WX78_MODULEREMOVER = "Robot friend fixer",

        SCANDATA = "Hmm!",
    },

    DESCRIBE_GENERIC = "Friend?",
    DESCRIBE_TOODARK = "Where is light?",
    DESCRIBE_SMOLDERING = "Uh oh...",

    DESCRIBE_PLANTHAPPY = "Happy",
    DESCRIBE_PLANTVERYSTRESSED = "No no no, not happy!",
    DESCRIBE_PLANTSTRESSED = "Something wrong",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Too many bothers around",
    DESCRIBE_PLANTSTRESSORFAMILY = "Misses family",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "Need room",
    DESCRIBE_PLANTSTRESSORSEASON = "Doesn't like weather now",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Thirsty",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Needs food!",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "Wants to talk",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Don't feel good",
		WINTERSFEASTFUEL = "Friends?",
    },
}
