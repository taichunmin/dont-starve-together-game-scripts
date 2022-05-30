--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Patience is a virtue.",
        },
        REPAIR =
        {
            WRONGPIECE = "That is clearly the incorrect piece.",
        },
        BUILD =
        {
            MOUNTED = "In this elevated position, I can't reach the ground.",
            HASPET = "One domestic creature is enough for me.",
			TICOON = "Having two trackers at once could possibly confuse them.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I think he might object to that.",
			GENERIC = "I would really rather not.",
			NOBITS = "It's already smooth, dear.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "It's not my place to shave someone else's beefalo.",
		},
		STORE =
		{
			GENERIC = "It's full to the brim, I'm afraid.",
			NOTALLOWED = "Nonsense.",
			INUSE = "I do hope you're keeping organized, my dear.",
            NOTMASTERCHEF = "It would be rude of me to tamper with it.",
		},
        CONSTRUCT =
        {
            INUSE = "Someone's already using this.",
            NOTALLOWED = "That was erroneous.",
            EMPTY = "I need something to build with first.",
            MISMATCH = "Those are the wrong plans.",
        },
		RUMMAGE =
		{
			GENERIC = "I've other things on my mind currently.",
			INUSE = "Be sure to sort by color and weight, dear.",
            NOTMASTERCHEF = "It would be rude of me to tamper with it.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "That may have been the wrong implement.",
        	KLAUS = "The beast must first be defeated.",
			QUAGMIRE_WRONGKEY = "I'll have to find the right key.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "It appears to be locked.",
            HOSTBUSY = "He seems to be attending to other matters at the moment.",
            CARNIVAL_HOST_HERE = "I believe I saw our host somewhere in this direction.",
            NOCARNIVAL = "How disappointing, the corvids seem to have migrated elsewhere.",
			EMPTY_CATCOONDEN = "Unfortunately, it appears the kittens are not present.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "It would seem the seekers outnumber the kittens.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "I believe there are not enough locations for the kittens to hide.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "I believe I should take some time to rest.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "It would be rude of me to tamper with it.",
			SHADOWMAGIC = "I'm not letting THAT in MY library!",
		},
        COOK =
        {
            GENERIC = "Perhaps later. Not all old ladies enjoy cooking, you know.",
            INUSE = "Mmm, smells lovely, dear.",
            TOOFAR = "It is not within my reach.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "I can't gather any data with no subjects.",
        },

		DISMANTLE =
		{
			COOKING = "I'm afraid I'll have to wait until it's finished cooking.",
			INUSE = "It's already in use.",
			NOTEMPTY = "I'll have to remove its contents first.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Those fish are far too deep.",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "I don't require this for some simple pond fishing.",
		},
        --wickerbottom specific action
        READ =
        {
            GENERIC = "Other matters await.",
            NOBIRDS = "The birds are not keen on this weather.",
        },

        GIVE =
        {
            GENERIC = "I don't think so, dear.",
            DEAD = "That would be a waste.",
            SLEEPING = "It appears to be sleeping.",
            BUSY = "I'll try again when it's done.",
            ABIGAILHEART = "Her spirit is already bound to something in this world.",
            GHOSTHEART = "I'll not be meddling in that business.",
            NOTGEM = "Don't be silly, dear.",
            WRONGGEM = "This gemstone's properties are incorrect for my purposes.",
            NOTSTAFF = "This is not the staff I seek.",
            MUSHROOMFARM_NEEDSSHROOM = "Goodness no, it needs a fresh mushroom.",
            MUSHROOMFARM_NEEDSLOG = "It needs a log, imbued with magical properties.",
            MUSHROOMFARM_NOMOONALLOWED = "This species seems to only grow in the wild.",
            SLOTFULL = "Let's finish what's on our plate first, shall we?",
            FOODFULL = "I'll be around when you're ready for seconds, dear.",
            NOTDISH = "That food is simply not suitable.",
            DUPLICATE = "We've already taken note of this recipe.",
            NOTSCULPTABLE = "No one ought to sculpt with that, dear.",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Conditions are not right.",
            WRONGSHADOWFORM = "The skeletal anatomy is incorrect.",
            NOMOON = "It needs a lunar influence.",
			PIGKINGGAME_MESSY = "I'll need to do some tidying up first.",
			PIGKINGGAME_DANGER = "This is no time for fun and games!",
			PIGKINGGAME_TOOLATE = "No time for that now. It'll be dark soon.",
			CARNIVALGAME_INVALID_ITEM = "That doesn't appear to be the correct form of payment.",
			CARNIVALGAME_ALREADY_PLAYING = "I'm afraid I'll have to wait.",
            SPIDERNOHAT = "There simply isn't enough room for that.",
            TERRARIUM_REFUSE = "Perhaps I should make another attempt with something else.",
            TERRARIUM_COOLDOWN = "Oh that won't do, the intended arborous recipient appears to be missing.",
        },
        GIVETOPLAYER =
        {
            FULL = "They're already heavily burdened.",
            DEAD = "That would be a waste.",
            SLEEPING = "They've entered REM sleep. No need to disturb them.",
            BUSY = "I'll try again when they're free.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "They're already heavily burdened.",
            DEAD = "That would be a waste.",
            SLEEPING = "They've entered REM sleep. No need to disturb them.",
            BUSY = "I'll try again when they're free.",
        },
        WRITE =
        {
            GENERIC = "I'd rather write in my own books.",
            INUSE = "When you're done, dear.",
        },
        DRAW =
        {
            NOIMAGE = "An example of what I should diagram would be helpful.",
        },
        CHANGEIN =
        {
            GENERIC = "I think I look pretty smart already.",
            BURNING = "No more changes for me. It's gone up in flames.",
            INUSE = "If I could use that after you, dear.",
            NOTENOUGHHAIR = "Perhaps once the hair has regrown.",
            NOOCCUPANT = "This station requires a beefalo to be securely hitched before I can proceed any further.",
        },
        ATTUNE =
        {
            NOHEALTH = "I'm feeling too ill for that.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "It would be ill-advised to approach that scuffle.",
            INUSE = "Patience is required. I can ride this beefalo later.",
			SLEEPING = "Up now, I require your services.",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "It would be ill-advised to approach that scuffle.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Please. That knowledge is child's play.",
            CANTLEARN = "A piece of knowledge I cannot grasp... Intriguing!",

            --MapRecorder/MapExplorer
            WRONGWORLD = "This map is for some other location.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "It's much too dark to make any sense of this.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "I have to know what to wrap, dear.",
        },
        PICKUP =
        {
			RESTRICTION = "That's not my area of expertise.",
			INUSE = "It's already in use.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Oh my, I seem to have gotten a bit mixed up.",
                "My glasses need a good cleaning, that's clearly not my Daucus carota rattus!",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Oh dear, it got away.",
        },
        REPLATE =
        {
            MISMATCH = "That's not the proper dinnerware for this food.",
            SAMEDISH = "It's already on the proper dinnerware.",
        },
        SAIL =
        {
        	REPAIR = "It's already in ideal condition.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "I must time this perfectly.",
            BAD_TIMING1 = "This might take some tenacity.",
            BAD_TIMING2 = "Oh dear, I'll have to start over.",
        },
        LOWER_SAIL_FAIL =
        {
            "There must be a trick to this.",
            "Oh, you finicky thing!",
            "Come along now, no need to be stubborn.",
        },
        BATHBOMB =
        {
            GLASSED = "The surface of the spring has crystallized, unfortunately.",
            ALREADY_BOMBED = "No need to be excessive.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "We've already taken note of this recipe.",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "This specimen is far too insubstantial.",
            OVERSIZEDVEGGIES_TOO_SMALL = "I'm afraid this specimen simply doesn't have enough mass to compete.",
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
            GENERIC = "I'm already quite knowledgeable about this particular species.",
            FERTILIZER = "I've gleaned as much information as I can.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "I'm afraid only freshwater will do.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Oh dear, I'll have to replenish my water supply.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "I'll have to replenish my water supply at the earliest opportunity.",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "That won't do.",
            BEEF_BELL_ALREADY_USED = "It's already formed a bond with someone else, dear.",
            BEEF_BELL_HAS_BEEF_ALREADY = "I don't require any more beefalo.",
        },
        HITCHUP =
        {
            NEEDBEEF = "I will require a beefalo first.",
            NEEDBEEF_CLOSER = "My beefalo needs to be in closer proximity to the post.",
            BEEF_HITCHED = "Already done, dear.",
            INMOOD = "Nothing will be accomplished in the state they're in.",
        },
        MARK =
        {
            ALREADY_MARKED = "I'm fairly confident in my selection.",
            NOT_PARTICIPANT = "I'll have to observe for now.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "The contest will have to wait for the time being.",
            ALREADYACTIVE = "I imagine there must be a competition going on elsewhere.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "I've already familiarized myself with this particular pattern.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Oh dear, I wasn't quite fast enough.",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "I'm afraid this isn't my area of expertise.",
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
            DOER_ISNT_MODULE_OWNER = "As I thought, I'm unable to glean any information from it.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "I should endeavor to collect the required ingredients.",
		NO_TECH = "This looks like an opportunity to conduct some research.",
		NO_STATION = "I'm afraid this will require a specialized workspace.",
	},

	ACTIONFAIL_GENERIC = "It seems I can't do that.",
	ANNOUNCE_BOAT_LEAK = "The boat has fallen into dangerous disrepair.",
	ANNOUNCE_BOAT_SINK = "Goodness, we're sinking!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Caught it just in time. The roots were nearly rotten.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "This plant is exhibiting concerning signs.", --removed
	ANNOUNCE_ADVENTUREFAIL = "We must learn from our failures.",
    ANNOUNCE_MOUNT_LOWHEALTH = "My mount requires attention of the medical variety.",

    --waxwell and wickerbottom specific strings
    ANNOUNCE_TOOMANYBIRDS = "It doesn't work as well with this many birds around.",
    ANNOUNCE_WAYTOOMANYBIRDS = "The sky is out of birds for now.",

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

	ANNOUNCE_BEES = "Stinging nasties!",
	ANNOUNCE_BOOMERANG = "I misjudged the timing of its return.",
	ANNOUNCE_CHARLIE = "A noise! And a distinctly floral scent?",
	ANNOUNCE_CHARLIE_ATTACK = "OUCH! Who dares?!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "The ambient temperature is low.",
	ANNOUNCE_HOT = "The ambient temperature is high.",
	ANNOUNCE_CRAFTING_FAIL = "I can't make that now.",
	ANNOUNCE_DEERCLOPS = "That sounds quite large!",
	ANNOUNCE_CAVEIN = "The rocks above will soon give way.",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"The ground will soon give way.",
		"Not the work of tectonic plates.",
		"A six on the Richter scale.",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "For you, great Panthera auropunctata.",
        "It ought to be more docile now.",
        "The great Panthera auropunctata is tamed.",
	},
	ANNOUNCE_SACREDCHEST_YES = "That did the trick.",
	ANNOUNCE_SACREDCHEST_NO = "Shoot. I thought I had it.",
    ANNOUNCE_DUSK = "Night will be here soon.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Yum!",
		PAINFUL = "I should not have ingested that.",
		SPOILED = "That was partially decomposed.",
		STALE = "That was not at optimal freshness.",
		INVALID = "This cannot be consumed.",
        YUCKY = "Ingesting this would be ill-advised.",

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
        "It's all in the legs.",
        "Goodness...",
        "Dear me...",
        "I've got it, dear.",
        "I'm more spry than I look!",
        "You just need to know how to lift!",
        "No sweat off my back! Ho ho!",
        "How invigorating!",
        "This gets the blood pumping!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"I do believe it's time to go.",
		"It's dangerous to be here.",
		"Goodness gracious!",
	},
    ANNOUNCE_RUINS_RESET = "Careful, the monsters are back.",
    ANNOUNCE_SNARED = "You can't hold me for long, dear.",
    ANNOUNCE_SNARED_IVY = "Goodness, my garden seems to have quite an aggressive weed problem.",
    ANNOUNCE_REPELLED = "There's magic at work here.",
	ANNOUNCE_ENTER_DARK = "I am in the dark.",
	ANNOUNCE_ENTER_LIGHT = "It is bright enough to see.",
	ANNOUNCE_FREEDOM = "Freedom! I'll find a good book and tuck in.",
	ANNOUNCE_HIGHRESEARCH = "My my, that was extremely interesting!",
	ANNOUNCE_HOUNDS = "Something is approaching.",
	ANNOUNCE_WORMS = "Something nasty intends to rear its head.",
	ANNOUNCE_HUNGRY = "Librarian needs food.",
	ANNOUNCE_HUNT_BEAST_NEARBY = "The appearance of this track indicates recent activity.",
	ANNOUNCE_HUNT_LOST_TRAIL = "The trail is no longer distinguishable.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "The trail's been washed away by the precipitation.",
	ANNOUNCE_INV_FULL = "I can't carry anything more.",
	ANNOUNCE_KNOCKEDOUT = "Oof, that's one way to get some rest, I suppose.",
	ANNOUNCE_LOWRESEARCH = "Not a great resource, but there were useful bits.",
	ANNOUNCE_MOSQUITOS = "Cursed bloodsuckers!",
    ANNOUNCE_NOWARDROBEONFIRE = "As you can plainly see, it is ablaze.",
    ANNOUNCE_NODANGERGIFT = "Presents are not a top survival priority at this moment.",
    ANNOUNCE_NOMOUNTEDGIFT = "I do believe I should dismount first.",
	ANNOUNCE_NODANGERSLEEP = "I can barely sleep even when I'm not in danger!",
	ANNOUNCE_NODAYSLEEP = "I can hardly get to sleep at night, never mind during the day.",
	ANNOUNCE_NODAYSLEEP_CAVE = "These caves don't make it any easier to sleep.",
	ANNOUNCE_NOHUNGERSLEEP = "I can barely sleep even when I'm not starving!",
	ANNOUNCE_NOSLEEPONFIRE = "Even if I could sleep, these temperatures are highly unsafe.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "No need to turn the light off dear, I won't be able to sleep either way.",
	ANNOUNCE_NODANGERSIESTA = "I can't lie down when I'm in danger!",
	ANNOUNCE_NONIGHTSIESTA = "I can't sleep, no matter where I lie down.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "I couldn't possibly relax in these caves.",
	ANNOUNCE_NOHUNGERSIESTA = "My hunger won't make relaxing any easier!",
	ANNOUNCE_NO_TRAP = "A cinch!",
	ANNOUNCE_PECKED = "Settle down, this instant!",
	ANNOUNCE_QUAKE = "A tremor! At least magnitude seven on the Richter scale.",
	ANNOUNCE_RESEARCH = "No information should go to waste, no matter how trivial.",
	ANNOUNCE_SHELTER = "Ah, a welcome respite.",
	ANNOUNCE_THORNS = "Dang spinose structure!",
	ANNOUNCE_BURNT = "First degree, at least!",
	ANNOUNCE_TORCH_OUT = "I need another light.",
	ANNOUNCE_THURIBLE_OUT = "That's that.",
	ANNOUNCE_FAN_OUT = "This fragile device has decayed.",
    ANNOUNCE_COMPASS_OUT = "My compass has become demagnetized.",
	ANNOUNCE_TRAP_WENT_OFF = "Eek!",
	ANNOUNCE_UNIMPLEMENTED = "Tut tut, I don't think it's quite ready.",
	ANNOUNCE_WORMHOLE = "A detailed lesson in biology!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Goodness! That's one way to travel.",
	ANNOUNCE_CANFIX = "\nI do believe I can repair this.",
	ANNOUNCE_ACCOMPLISHMENT = "It's not there yet!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "File that under completed!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It needs just a touch more fecal assistance, I'd say.",
	ANNOUNCE_TOOL_SLIP = "My grip!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Thank goodness for this non-conductive clothing!",
	ANNOUNCE_TOADESCAPING = "It will need to burrow soon to rehydrate its skin.",
	ANNOUNCE_TOADESCAPED = "It has burrowed away.",


	ANNOUNCE_DAMP = "The layer of water begins to build up.",
	ANNOUNCE_WET = "I wonder what my body's saturation point is...",
	ANNOUNCE_WETTER = "Wet, wet, wet!",
	ANNOUNCE_SOAKED = "Positively soaked.",

	ANNOUNCE_WASHED_ASHORE = "I hope my books weren't ruined.",

    ANNOUNCE_DESPAWN = "I've never read anything describing this!",
	ANNOUNCE_BECOMEGHOST = "oOoooOoO!!",
	ANNOUNCE_GHOSTDRAIN = "My humanity... it's slipping.",
	ANNOUNCE_PETRIFED_TREES = "The chemical reaction has been catalyzed...",
	ANNOUNCE_KLAUS_ENRAGE = "No sense throwing one's life away. Fall back!",
	ANNOUNCE_KLAUS_UNCHAINED = "Whatever enchantment restrained it has been undone.",
	ANNOUNCE_KLAUS_CALLFORHELP = "Careful! It has summoned lesser Krampii.",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "I'm coming, dear.",
		GLASS_LOW = "Nearly there.",
		GLASS_REVEAL = "Tada!",
		IDOL_MED = "I'm coming, dear.",
		IDOL_LOW = "Nearly there.",
		IDOL_REVEAL = "Tada!",
		SEED_MED = "I'm coming, dear.",
		SEED_LOW = "Nearly there.",
		SEED_REVEAL = "Tada!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Curious. I seem to be hallucinating.",
	ANNOUNCE_BRAVERY_POTION = "My intestinal fortitude has returned!",
	ANNOUNCE_MOONPOTION_FAILED = "Oh dear, that didn't go as planned.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "I couldn't possibly eat this all myself!",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Intriguing! I appear to be filled with \"cheer\".",
	ANNOUNCE_IS_FEASTING = "I hope everyone remembered to wash their hands before eating.",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "That was very illuminating.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Hold on a moment, dear.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Off you go now.",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Oof! Back on my feet!",

    ANNOUNCE_FLARE_SEEN = "Someone's fired a flare.",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "The megafauna have set their eyes on us.",

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
    ANNOUNCE_WX_SCANNER_NEW_FOUND = "only_used_by_wx78",
--fallback to speech_wilson.lua     ANNOUNCE_WX_SCANNER_FOUND_NO_DATA = "only_used_by_wx78",

    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "That was not a viable recipe.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "It was too long on the fire.",
    QUAGMIRE_ANNOUNCE_LOSE = "We've failed.",
    QUAGMIRE_ANNOUNCE_WIN = "We best be on our way. Ta!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I seem to have been rendered conductive!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "My, I feel full of vim and vigor!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I daresay I'm tougher than I may appear!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "I'll have everything done in a snap!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "I feel so pleasantly dry!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "I'm no stranger to sleeplessness.",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Back to the the natural state of things.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Oh my, what came over me?",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "It appears my defense has weakened.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "I can only work tirelessly for so long.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Did I just feel a raindrop?",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "How strange, I do in fact feel a bit tired...",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Oh dear, I must have put too much strain on my line.",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "The line must remain taut!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "I suppose there will be no fish dinner for me this time.",
	ANNOUNCE_OCEANFISHING_BADCAST = "Let's give that another go, shall we?",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Patience is a virtue.",
		"I do not appreciate the tardiness of these fish.",
		"Perhaps if I tried a different lure...",
		"I wonder if I could get some reading done while I wait.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nThis specimen is decidedly larger than average.",

	ANNOUNCE_WINCH_CLAW_MISS = "This will require a bit more precision on my part.",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "Oh dear... perhaps it's time to clean my glasses.",

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
    ANNOUNCE_WEAK_RAT = "I'm afraid it's in no condition to race.",

    ANNOUNCE_CARRAT_START_RACE = "Let the race commence!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Wrong way, dear.",
        "Oh my, I'll have to make a note of this.",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "The subject seems to be exhibiting low levels of stamina.",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Let's try to look a bit more lively, dear.",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "You must pay attention!",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Oof! Might I suggest realigning the exit point closer to the ground next time, dear?",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "What a peculiar sensation, it's transmitting a blueprint telepathically!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "I'm already familiar with this particular piece of knowledge.",
    ANNOUNCE_ARCHIVE_NO_POWER = "How very disappointing, I was curious to see what it would do.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "I've gained a bit more insight into the workings of this species.",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "Once it grows I'll be able to identify the species.",

    ANNOUNCE_FERTILIZER_RESEARCHED = "Even with my considerable gardening experience, there's always something new to learn.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Oh dear... I seem to be afflicted by the plant's toxin.",
		"The toxin from those nettles carries a rather unpleasant burning sensation.",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Thankfully, the toxin's effects seem to be temporary.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Talking to my little garden always seemed to help it grow.",
        "My, those leaves are coming in quite nicely dear!",
		"All one needs to thrive is a bit of love and care, isn't that right?",
        "No need to rush dear, you just take your time.",
        "How are you doing today? Do you have enough water?",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "The game has commenced, I should start seeking.",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Excuse me, I will join the feline search.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Ah, there you are.",
		"It seems I've discovered a kitten.",
		"I could see your tail from the distance, dear.",
		"Finding kittens is quite simple once you become accustomed to it.",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "One more kitten has been encountered.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "I found all of the missing kittens.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "We found all of the missing kittens.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "The end of the game draws closer.",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "It appears we did not find them all in time.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "I am distancing myself from where the game is happening.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "The kittens should be over here, yes.",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Poor dear, are you lost?",

	ANNOUNCE_TICOON_START_TRACKING	= "I believe he has caught the kitten's scent.",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "There appears to be a clear lack of hiding evidence.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "He is awaiting my lead.",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Don't worry, dear, I'm coming.",
	ANNOUNCE_TICOON_NEAR_KITCOON = "He believes we're near one of the kittens.",
	ANNOUNCE_TICOON_LOST_KITCOON = "Someone arrived before us and found our kitten.",
	ANNOUNCE_TICOON_ABANDONED = "It appears I will have to continue the search alone.",
	ANNOUNCE_TICOON_DEAD = "Oh, how terrible! I suppose I'm on my own now.",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Come along now.",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "It would be much more practical to build this closer to the competition.",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "I do believe I can fabricate a new bovine costume now.",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Something from outside our dimension is trying to come in.",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "This ocular creature seems rather persistent.",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "I suppose the daylight gives it a migraine.",

	BATTLECRY =
	{
		GENERIC = "Combat!",
		PIG = "Foul cad!",
		PREY = "Just give up.",
		SPIDER = "Behave!",
		SPIDER_WARRIOR = "Respect your elders!",
		DEER = "This will be easy.",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Well, that's over.",
		PIG = "Oh dear.",
		PREY = "I must reassess the situation.",
		SPIDER = "I must read up on this!",
		SPIDER_WARRIOR = "Back to the drawing board!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Hmm... This may require further reading.",
        MULTIPLAYER_PORTAL_MOONROCK = "Its design is decidedly otherworldly.",
        MOONROCKIDOL = "Curious. It rather looks like a key.",
        CONSTRUCTION_PLANS = "Oh, I do like the look of this.",

        ANTLION =
        {
            GENERIC = "Ah. You must be behind all the seismic activity.",
            VERYHAPPY = "It has been mollified with tributes.",
            UNHAPPY = "Panthera auropunctata is looking irritable.",
        },
        ANTLIONTRINKET = "It appears to be a child's plaything.",
        SANDSPIKE = "Panthera auropunctata is misbehaving today.",
        SANDBLOCK = "Quite a phenomenal talent!",
        GLASSSPIKE = "Careful, it's sharp.",
        GLASSBLOCK = "I always loved glass sculptures.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Ah... I'm not familiar with this strain of flower.",
			LEVEL1 = "It's emitting a strange energy.",
			LEVEL2 = "That flower has perked up quite a bit.",
			LEVEL3 = "Its magic has reached maximum potency.",

			-- deprecated
            LONG = "Odd...",
            MEDIUM = "It's emitting a strange energy.",
            SOON = "The flower's energy is growing powerful.",
            HAUNTED_POCKET = "I feel I should set it down now.",
            HAUNTED_GROUND = "Does it expect something of me?",
        },

        BALLOONS_EMPTY = "These seem frivolous.",
        BALLOON = "Could serve as a suitable diversion.",
		BALLOONPARTY = "A reasonable amount of cheer every so often would do us good.",
		BALLOONSPEED =
        {
            DEFLATED = "Probably not enough air left to analyze its composition...",
            GENERIC = "The chemical composition of the young man's breath must be fascinating.",
        },
		BALLOONVEST = "I applaud your attempt at practicality, dear.",
		BALLOONHAT = "I believe it's meant to evoke the image of a Lagomorph.",

        BERNIE_INACTIVE =
        {
            BROKEN = "That bear is in need of repair.",
            GENERIC = "It's a teddy bear.",
        },

        BERNIE_ACTIVE = "That teddy bear seems to be animated somehow.",
        BERNIE_BIG = "As whimsical as it is befuddling.",

        BOOK_BIRDS = "The expurgated version, but it has my favorite: Megascops kennicottii.",
        BOOK_TENTACLES = "Hard to put this one down. It's gripping, frankly.",
        BOOK_GARDENING = "Dead plants tied together to help me aid living plants.",
		BOOK_SILVICULTURE = "Dead plants tied together to help me aid living plants.",
		BOOK_HORTICULTURE = "Only my best tricks for bringing a garden to fruition.",
        BOOK_SLEEP = "Warm milk in book form.",
        BOOK_BRIMSTONE = "What could possibly go wrong?",

        PLAYER =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "That no good %s is up to no good.",
            MURDERER = "I'll erase you from the history books!",
            REVIVER = "I appreciate your commitment to group survival, %s.",
            GHOST = "Poor dear. %s needs a heart to anchor them to this plane.",
            FIRESTARTER = "%s, what have I told you about lighting fires?",
        },
        WILSON =
        {
            GENERIC = "Greetings, dear %s! How are your theorems coming?",
            ATTACKER = "I'll pull you back to base by the ear if I have to, %s.",
            MURDERER = "It appears we've entered a battle of the wits, %s!",
            REVIVER = "You may know a thing or two after all, scientist!",
            GHOST = "Didn't I tell you to wear a jacket? I'll get the hearts...",
            FIRESTARTER = "%s needs a stern talking to.",
        },
        WOLFGANG =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "I will not tolerate such behavior, %s.",
            MURDERER = "That's it, %s! I'm taking my glasses off!",
            REVIVER = "Excellent work, %s. You're a fast learner.",
            GHOST = "%s acts tough, but he needs my help. A heart should do it.",
            FIRESTARTER = "Was that fire intentional, %s?",
        },
        WAXWELL =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "Up to your old tricks, are you %s?",
            MURDERER = "Fool me once, shame on you. Fool me twice... you're dead!",
            REVIVER = "There's good in you, %s.",
            GHOST = "Stings, doesn't it dear? Let me fetch you a heart.",
            FIRESTARTER = "Lighting fires are we now, %s? Tread carefully.",
        },
        WX78 =
        {
            GENERIC = "Ah, the automaton. Greetings, dear %s!",
            ATTACKER = "What devilishness is that robot up to?",
            MURDERER = "The binary is simple, %s... On, or OFF.",
            REVIVER = "I appreciate your commitment to group survival, %s.",
            GHOST = "Fascinating. %s indeed has a specter, and it lingers still.",
            FIRESTARTER = "Do be careful when trying to destroy all life, dear.",
        },
        WILLOW =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "You like to test boundaries, don't you dear?",
            MURDERER = "You WILL respect your elders, %s!",
            REVIVER = "You're doing so well, %s.",
            GHOST = "If you cross your ghosteyes they'll get stuck like that, dear.",
            FIRESTARTER = "What have I said about lighting fires, dear?",
        },
        WENDY =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "%s! That's enough out of you, young lady!",
            MURDERER = "Someone needs to teach you some manners, %s!",
            REVIVER = "You're a dear, %s. And so uniquely qualified to handle specters!",
            GHOST = "Goodness, this just won't do. Let me find you a heart, %s.",
            FIRESTARTER = "Who gave you flammable materials, %s?",
        },
        WOODIE =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "Careful, %s. You know what paper pulp is made of, don't you?",
            MURDERER = "I will defend myself from you, foul cad!",
            REVIVER = "Excellent work, %s.",
            GHOST = "What did I say about playing with axes? Let's get you a heart.",
            BEAVER = "Poor dear never mentioned he was afflicted by Castorthropy.",
            BEAVERGHOST = "I'll add \"Castorthrope\" to my endangered species list.",
            MOOSE = "Oh deer, it looks like you've expanded your repertoire.",
            MOOSEGHOST = "Don't you fret, I'll be back with a heart.",
            GOOSE = "My, what a silly goose!",
            GOOSEGHOST = "Poor dear, let's see about finding you a heart.",
            FIRESTARTER = "Keep lighting fires if you want to get burnt, dear.",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Ah, greetings %s! Fancy seeing you here.",
            ATTACKER = "%s's immorality is putting holes in my multiverse speculations.",
            MURDERER = "I am my own worst critic!",
            REVIVER = "Our knowledge comes in handy, doesn't it, %s?",
            GHOST = "All our self-help books will finally be put to use, hmm %s?",
            FIRESTARTER = "Book burnings are quite gauche, %s.",
        },
        WES =
        {
            GENERIC = "Ah, the mime lad. Greetings, dear %s!",
            ATTACKER = "His body language says everything.",
            MURDERER = "They'll tell tales of your defeat, %s!",
            REVIVER = "You're a fine young man, %s.",
            GHOST = "Poor dear. %s needs a heart to anchor him to this plane.",
            FIRESTARTER = "Don't cry to me when you burn yourself, dear.",
        },
        WEBBER =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "That's enough funny business, young arachnid.",
            MURDERER = "Someone needs to teach you some manners, %s!",
            REVIVER = "You're a sweet boy, %s.",
            GHOST = "I'll fetch you a nice colored bandage once you're revived.",
            FIRESTARTER = "Who gave you matches, %s?",
        },
        WATHGRITHR =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "You're not making trouble, are you %s?",
            MURDERER = "Your saga ends here, %s!",
            REVIVER = "I appreciate your commitment to group survival, %s.",
            GHOST = "%s, I told you not to run with spears. Tsk.",
            FIRESTARTER = "\"By Hel's fire\" is a turn of phrase, dear.",
        },
        WINONA =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "Rather crass wouldn't you say, %s?",
            MURDERER = "I'll not tolerate cruelty!",
            REVIVER = "%s is quite the Jane of all trades.",
            GHOST = "Tsk. Were you wearing your hardhat, dear?",
            FIRESTARTER = "That was not a regulation fire, dear.",
        },
        WORTOX =
        {
            GENERIC = "You must tell me more about your species sometime, dear.",
            ATTACKER = "You'd best play nice now, %s.",
            MURDERER = "Enough tricks, %s! I'll finish you!",
            REVIVER = "Thank-you for the assistance, %s.",
            GHOST = "That's what you get for causing mischief, %s.",
            FIRESTARTER = "I'll not tolerate that behavior, %s!",
        },
        WORMWOOD =
        {
            GENERIC = "Ah, greetings, dear %s!",
            ATTACKER = "%s is of the Urtica family, I suspect.",
            MURDERER = "%s is a deadly nightshade! Attack!",
            REVIVER = "You're a very good friend, %s.",
            GHOST = "Tsk, well that's no good. No good at all.",
            FIRESTARTER = "Do you want to singe your leaves off, %s?",
        },
        WARLY =
        {
            GENERIC = "Ah, greetings, dear %s!",
            ATTACKER = "No need to cause a ruckus now, %s.",
            MURDERER = "I smell fresh baked murder on the air. Attack!",
            REVIVER = "Excellent work today, %s.",
            GHOST = "We'd best get you back on your feet, dear.",
            FIRESTARTER = "I know that fire wasn't for cooking, dear.",
        },

        WURT =
        {
            GENERIC = "Hello dear %s, are you ready for more lessons?",
            ATTACKER = "Settle down, now!",
            MURDERER = "I will not tolerate that kind of behavior, %s!",
            REVIVER = "Why thank you, dear.",
            GHOST = "Oh that won't do at all, let's get you sorted out.",
            FIRESTARTER = "Do you remember what I said about fire? I should say not!",
        },

        WALTER =
        {
            GENERIC = "Ah, greetings dear %s!",
            ATTACKER = "Let's all use our words, dear.",
            MURDERER = "Goodness, is that how they taught you to behave in the Pioneers?",
            REVIVER = "My, how very kind of you %s.",
            GHOST = "Oh my, you must be more careful dear!",
            FIRESTARTER = "Not everything is a campfire, dear.",
        },

        WANDA =
        {
            GENERIC = "Greetings dear %s! Do you have any new insights on what lies ahead?",
            ATTACKER = "Really %s, you need to set a better example for the children.",
            MURDERER = "You should have known you wouldn't get away with it, %s. Attack!",
            REVIVER = "I appreciate you taking the time, dear.",
            GHOST = "Oh dear, even after all the precautions you took?",
            FIRESTARTER = "Surely you have the foresight to know that's unwise, don't you?",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "A bizarre specimen of the insecta class.",
            SLEEPING = "It appears to be resting.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "It's dripping with goo.",
            DEAD = "It's gone gray, but it's still dripping.",
        },
        GLOMMERWINGS = "The pennons of that strange specimen.",
        GLOMMERFUEL = "It appears to be quite volatile.",
        BELL = "Quiet! This is a library!",
        STATUEGLOMMER =
        {
            GENERIC = "Is it petrified?",
            EMPTY = "Nope, just a statue.",
        },

        LAVA_POND_ROCK = "Recently cooled igneous rock. Dangerous.",

		WEBBERSKULL = "That is a most unusual skull.",
		WORMLIGHT = "It's softer than I would've thought.",
		WORMLIGHT_LESSER = "This one is purely vegetable.",
		WORM =
		{
		    PLANT = "Reminds me of the Anglerfish.",
		    DIRT = "It would be best to stay away from that.",
		    WORM = "Worm attack!",
		},
        WORMLIGHT_PLANT = "Reminds me of the Anglerfish.",
		MOLE =
		{
			HELD = "I don't think my pocket is its natural habitat.",
			UNDERGROUND = "Something is tunneling down there.",
			ABOVEGROUND = "Ah, it's a Talpidae!",
		},
		MOLEHILL = "The tunnel system must be vast!",
		MOLEHAT = "Ah, to look through another creature's, uh, nose!",

		EEL = "It's an eel.",
		EEL_COOKED = "This eel has been cooked.",
		UNAGI = "A common way to prepare eel.",
		EYETURRET = "The magic of the two beasts has been concentrated by the Thulecite.",
		EYETURRET_ITEM = "I'll need to place this.",
		MINOTAURHORN = "An amazingly large horn. I wonder if the nightmare helped fuel the growth.",
		MINOTAURCHEST = "That chest is absolutely marvelous.",
		THULECITE_PIECES = "These could be combined to make a bigger piece.",
		POND_ALGAE = "It is a good thing this algae has no need for photosynthesis.",
		GREENSTAFF = "It appears to rewind time on an object.",
		GIFT = "Oh goodness, how lovely!",
        GIFTWRAP = "Wrapping presents is soothing work, isn't it?",
		POTTEDFERN = "A potted plant.",
        SUCCULENT_POTTED = "I wonder how my garden is doing without me.",
		SUCCULENT_PLANT = "Uniquely adapted to arid climates.",
		SUCCULENT_PICKED = "It will wither if not replanted.",
		SENTRYWARD = "Ah! A scrying orb.",
        TOWNPORTAL =
        {
			GENERIC = "It deconstructs the subject and reconstitutes them elsewhere.",
			ACTIVE = "The path is open.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "A bezoar formed in the gut of a large beast.",
			ACTIVE = "The bezoar's magic has been activated.",
		},
        WETPAPER = "This may prove useful.",
        WETPOUCH = "Perhaps something useful lies inside?",
        MOONROCK_PIECES = "What a perplexing transformation.",
        MOONBASE =
        {
            GENERIC = "The magic of this structure ebbs in predictable cycles.",
            BROKEN = "Ancient debris. Perhaps it can be restored?",
            STAFFED = "Now we must be patient.",
            WRONGSTAFF = "Hmm... It seems the staves are not interchangeable.",
            MOONSTAFF = "The magic of the stone appears to be inexhaustible.",
        },
        MOONDIAL =
        {
			GENERIC = "Something very odd is going on here.",
			NIGHT_NEW = "The moon's cycle begins anew.",
			NIGHT_WAX = "The moon is waxing.",
			NIGHT_FULL = "This cycle of the moon has drawn to a close.",
			NIGHT_WANE = "The moon is waning.",
			CAVE = "It appears to lose functionality in subterranean conditions.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "How curious, the water reacts similarly to what I observed in the grotto.",
        },
		THULECITE = "This seems to be an interesting, ectoplasmic residue-bearing variety of ziosite.",
		ARMORRUINS = "A hardy Thulecite armor.",
		ARMORSKELETON = "Now it's an exoskeleton. Ho ho!",
		SKELETONHAT = "It has a detrimental effect on the mortal mind.",
		RUINS_BAT = "An implement for administering devastating blows.",
		RUINSHAT = "A bit gaudy for my tastes, but it seems useful.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "The levels of ectoplasmic residue seem to be at their lowest.",
            WARN = "There are low, but increasing levels of vapors containing ectoplasmic residue.",
            WAXING = "Levels of ectoplasmic residue seem to be increasing.",
            STEADY = "The levels of ectoplasmic residue seem to be at their peak.",
            WANING = "Levels of ectoplasmic residue are high but seem to be decreasing.",
            DAWN = "There is very little ectoplasmic residue vapor.",
            NOMAGIC = "There doesn't seem to be any ectoplasmic vapor around here.",
		},
		BISHOP_NIGHTMARE = "Such exhilaratingly complex technology.",
		ROOK_NIGHTMARE = "It looks like it could break apart at any moment.",
		KNIGHT_NIGHTMARE = "Its nightmare fueled surroundings have corrupted its programming.",
		MINOTAUR = "Get away, you beast!",
		SPIDER_DROPPER = "Ah, this species of arachnid has adapted to life on the cave ceiling.",
		NIGHTMARELIGHT = "The ancients seem to have used nightmare fuel to power everything.",
		NIGHTSTICK = "I wonder if it's named for Venus?",
		GREENGEM = "Chromium impurities have colored this gem green.",
		MULTITOOL_AXE_PICKAXE = "Quite functional, it operates as both an axe and a pickaxe.",
		ORANGESTAFF = "Handy over small distances.",
		YELLOWAMULET = "This amulet is glowing at the mid 530 nanometer wavelength.",
		GREENAMULET = "Works almost as a magical binding agent.",
		SLURPERPELT = "This must be useful for something.",

		SLURPER = "A classic example of symbiosis.",
		SLURPER_PELT = "This must be useful for something.",
		ARMORSLURPER = "A disgusting and magical garment.",
		ORANGEAMULET = "The gem fades with each use.",
		YELLOWSTAFF = "Luckily the star is a manageable size.",
		YELLOWGEM = "Perhaps it is similar to citrine.",
		ORANGEGEM = "It looks like a Spessartite garnet.",
        OPALSTAFF = "Appears to summon a cold star into being.",
        OPALPRECIOUSGEM = "A precious light diffracting mineraloid.",
        TELEBASE =
		{
			VALID = "It looks to be ready.",
			GEMS = "I don't think it's powered yet.",
		},
		GEMSOCKET =
		{
			VALID = "What a strange effect.",
			GEMS = "These hold gems.",
		},
		STAFFLIGHT = "Perhaps a larger staff would summon a larger star.",
        STAFFCOLDLIGHT = "Some sort of self-contained aurora.",

        ANCIENT_ALTAR = "A monument to some long dead god.",

        ANCIENT_ALTAR_BROKEN = "Parts of this are missing.",

        ANCIENT_STATUE = "This seems mystically aligned to the world.",

        LICHEN = "A symbiote! A fungus and a phycobiontic bacteria.",
		CUTLICHEN = "This won't last long.",

		CAVE_BANANA = "All of them are genetically identical.",
		CAVE_BANANA_COOKED = "Somewhat better.",
		CAVE_BANANA_TREE = "The seeds must have fallen down a sinkhole.",
		ROCKY = "Their carapace is made of rocks.",

		COMPASS =
		{
			GENERIC="The coordinates remain unknown.",
			N = "North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "Made of calcium and brimstone.",
        ARMORSNURTLESHELL = "It is quite capacious.",
        BAT = "A flying mammal.",
        BATBAT = "Interesting. This weapon appears to be alive.",
        BATWING = "Technically edible.",
        BATWING_COOKED = "Technically edible.",
        BATCAVE = "This nook is actually a dwelling.",
        BEDROLL_FURRY = "I'm not sleeping on the ground.",
        BUNNYMAN = "A sentient lagomorph.",
        FLOWER_CAVE = "You could read by that light.",
        GUANO = "More metabolic byproduct.",
        LANTERN = "A refuelable light source.",
        LIGHTBULB = "Is this animal or vegetable?",
        MANRABBIT_TAIL = "They use their tails to balance.",
        MUSHROOMHAT = "Ooo. What a delightfully wizened look.",
        MUSHROOM_LIGHT2 =
        {
            ON = "Red and blue spores produce lovely reading light when combined.",
            OFF = "Basic color theory is a must.",
            BURNT = "Ahem. I'll be needing a new reading light.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Quite enthralling, no?",
            OFF = "A bioluminescent fungus. Neither Agaricales nor Xylariales.",
            BURNT = "That was myco-illogical. Ho ho!",
        },
        SLEEPBOMB = "It's past your bedtime.",
        MUSHROOMBOMB = "Everyone, give the volatile Agaricus wide berth!",
        SHROOM_SKIN = "Frog skin must remain damp, or they will suffocate. Not that this one minds.",
        TOADSTOOL_CAP =
        {
            EMPTY = "The soil has been disturbed here.",
            INGROUND = "The growth needs a catalyst to breach the surface.",
            GENERIC = "A new member of the Agaricus genus?",
        },
        TOADSTOOL =
        {
            GENERIC = "It has formed a dangerous symbiotic relationship with fungal spores.",
            RAGE = "The symbiotic bond between toad and fungus has reached its apex.",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "We must destroy that towering Agaricus.",
            BURNT = "A towering, burnt Agaricus.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "A tree with a fungal parasite.",
            BLOOM = "Apparently it's the breeding season for this species.",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "A red variety of Mycena luxaeterna.",
            BLOOM = "The smell is used to ward off predators.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "My word! A huge Mycena silvaelucens.",
            BLOOM = "The light is caused by a chemical reaction.",
        },
        MUSHTREE_TALL_WEBBED = "This relationship appears symbiotic.",
        SPORE_TALL =
        {
            GENERIC = "A soft blue carrier of genetic information.",
            HELD = "I'm a carrier of a carrier of genetic information.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "A bright red carrier of genetic information.",
            HELD = "I'm a carrier of a carrier of genetic information.",
        },
        SPORE_SMALL =
        {
            GENERIC = "A lovely green carrier of genetic information.",
            HELD = "I'm a carrier of a carrier of genetic information.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Sadly, it is just painted to look like a carrot.",
            BURNT = "It didn't even burn like a carrot.",
        },
        SLURTLE = "A mineral-devouring gastropod.",
        SLURTLE_SHELLPIECES = "Pieces of the broken.",
        SLURTLEHAT = "It provides protection.",
        SLURTLEHOLE = "A gastropod pod.",
        SLURTLESLIME = "Their mucus is explosive for some reason.",
        SNURTLE = "A rare variant of gastropod.",
        SPIDER_HIDER = "An arachnid with a thick carapace.",
        SPIDER_SPITTER = "An arachnid that spits projectiles.",
        SPIDERHOLE = "This is the source of the spider infestation.",
        SPIDERHOLE_ROCK = "This is the source of the spider infestation.",
        STALAGMITE = "A strange rock formation.",
        STALAGMITE_TALL = "Another stalagmite.",

        TURF_CARPETFLOOR = "The ground. You step on it.",
        TURF_CHECKERFLOOR = "The ground. You step on it.",
        TURF_DIRT = "The ground. You step on it.",
        TURF_FOREST = "The ground. You step on it.",
        TURF_GRASS = "The ground. You step on it.",
        TURF_MARSH = "The ground. You step on it.",
        TURF_METEOR = "I'm not sure you grasp the gravity of the situation. Ho ho!",
        TURF_PEBBLEBEACH = "The ground. You step on it.",
        TURF_ROAD = "The ground. You step on it.",
        TURF_ROCKY = "The ground. You step on it.",
        TURF_SAVANNA = "The ground. You step on it.",
        TURF_WOODFLOOR = "The ground. You step on it.",

		TURF_CAVE="The ground. You step on it.",
		TURF_FUNGUS="The ground. You step on it.",
		TURF_FUNGUS_MOON = "The ground. You step on it.",
		TURF_ARCHIVE = "The ground. You step on it.",
		TURF_SINKHOLE="The ground. You step on it.",
		TURF_UNDERROCK="The ground. You step on it.",
		TURF_MUD="The ground. You step on it.",

		TURF_DECIDUOUS = "The ground. You step on it.",
		TURF_SANDY = "The ground. You step on it.",
		TURF_BADLANDS = "The ground. You step on it.",
		TURF_DESERTDIRT = "The ground. You step on it.",
		TURF_FUNGUS_GREEN = "The ground. You step on it.",
		TURF_FUNGUS_RED = "The ground. You step on it.",
		TURF_DRAGONFLY = "This substance is imbued with a sort of natural fire deterrent.",

        TURF_SHELLBEACH = "The ground. You step on it.",

		POWCAKE = "The crowning achievement of the agricultural-industrial complex.",
        CAVE_ENTRANCE = "The placement of that rock looks intentional.",
        CAVE_ENTRANCE_RUINS = "The passage has been obstructed.",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Perhaps when I am better prepared.",
            OPEN = "The subterranean world awaits.",
            FULL = "Much too crowded for my liking.",
        },
        CAVE_EXIT =
        {
            GENERIC = "Perhaps later.",
            OPEN = "Maybe I should go back up for some fresh air.",
            FULL = "With all those people? It's bound to be cacophony.",
        },

		MAXWELLPHONOGRAPH = "It appears to have no power source.",--single player
		BOOMERANG = "It is a flat aerofoil.",
		PIGGUARD = "One of the warrior caste.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Fascinating. Can you speak, specter?",
                "Fascinating. Can you speak, specter?",
            },
            LEVEL2 =
            {
                "Fascinating. Can you speak, specter?",
                "Fascinating. Can you speak, specter?",
            },
            LEVEL3 =
            {
                "Fascinating. Can you speak, specter?",
                "Fascinating. Can you speak, specter?",
            },
		},
		ADVENTURE_PORTAL = "That violates some pretty fundamental physical laws.",
		AMULET = "A relic from another time.",
		ANIMAL_TRACK = "A sign of animal activity. Leads away.",
		ARMORGRASS = "Surprisingly effective with enough layers.",
		ARMORMARBLE = "An interesting choice of materials.",
		ARMORWOOD = "Crude plate mail cobbled together from log sections.",
		ARMOR_SANITY = "A protective shroud that transfers attacks to another dimension.",
		ASH =
		{
			GENERIC = "Some non-aqueous residue remains after the fire.",
			REMAINS_GLOMMERFLOWER = "The flower appears to have been completely burned up.",
			REMAINS_EYE_BONE = "The eyebone seems to have been burned entirely.",
			REMAINS_THINGIE = "This used to be something, but now it's just a pile of ash.",
		},
		AXE = "A dual inclined plane attached to a lever.",
		BABYBEEFALO =
		{
			GENERIC = "Look at his widdle face! (Ahem!)",
		    SLEEPING = "He's even more darling in sleep.",
        },
        BUNDLE = "At least someone's bundled up out here.",
        BUNDLEWRAP = "Antibacterial wrapping for food preservation.",
		BACKPACK = "That could carry so many books.",
		BACONEGGS = "Blue eggs and bacon!",
		BANDAGE = "Medicinal dressings.",
		BASALT = "Material of great density!", --removed
		BEARDHAIR = "This is human facial hair.",
		BEARGER = "It's the Caniformia suborder... Beyond that, I cannot say.",
		BEARGERVEST = "Whatever it was, its pelt makes for a fine garment.",
		ICEPACK = "Perfectly insulated.",
		BEARGER_FUR = "My, my! That is thick.",
		BEDROLL_STRAW = "I'm not sleeping on the ground.",
		BEEQUEEN = "The workers ferociously protect her.",
		BEEQUEENHIVE =
		{
			GENERIC = "Thick Apis mellifera honeycomb.",
			GROWING = "The Apis mellifera are constructing a new hive.",
		},
        BEEQUEENHIVEGROWN = "An Apis mellifera nest of unusual size.",
        BEEGUARD = "Very angry Apis mellifera workers!",
        HIVEHAT = "It's exuding powerful pheromones.",
        MINISIGN =
        {
            GENERIC = "An excellent diagram! Very accurate.",
            UNDRAWN = "A drawn diagram might help keep things tidy.",
        },
        MINISIGN_ITEM = "Finally, a proper organizational tool.",
		BEE =
		{
			GENERIC = "Apis mellifera. Quite large!",
			HELD = "It is not pleased.",
		},
		BEEBOX =
		{
			READY = "Honey can be harvested from it.",
			FULLHONEY = "Honey can be harvested from it.",
			GENERIC = "A crude apiary.",
			NOHONEY = "It's devoid of honey.",
			SOMEHONEY = "It's not ready for harvesting.",
			BURNT = "Poor bees!",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "We ought to pick them before they outgrow their planter.",
			LOTS = "An excellent fungal yield.",
			SOME = "The fungi are fruiting nicely.",
			EMPTY = "It must first be seeded with a cut specimen or fungal spore.",
			ROTTEN = "The state of decomposition is too advanced to support any specimens.",
			BURNT = "Carbonized by an exothermic chemical reaction.",
			SNOWCOVERED = "Its growth has been halted by the extreme cold.",
		},
		BEEFALO =
		{
			FOLLOWER = "It appears to be following me.",
			GENERIC = "It looks almost like a Bos Taurus.",
			NAKED = "It looks cold.",
			SLEEPING = "It's sleeping.",
            --Domesticated states:
            DOMESTICATED = "While tame, it has become dependent on its human master.",
            ORNERY = "The creature has developed a nasty disposition.",
            RIDER = "This one seems lean and athletic.",
            PUDGY = "Abundant nourishment has led to an amicable personality.",
            MYPARTNER = "It has become rather attached to me.",
		},

		BEEFALOHAT = "This hat is hideous.",
		BEEFALOWOOL = "Long follicles harvested from the beefalo.",
		BEEHAT = "Appropriate protective equipment is a must!",
        BEESWAX = "Naturally antibacterial. Could slow food decay if we use it properly.",
		BEEHIVE = "The natural home of the bee.",
		BEEMINE = "A dangerous mine filled with Antophila.",
		BEEMINE_MAXWELL = "A dangerous mine filled with Culicidae.",--removed
		BERRIES = "Some Ardisia crenata berries, I think.",
		BERRIES_COOKED = "Roasted Ardisia crenata, just in case.",
        BERRIES_JUICY = "A variant of Ardisia crenata berries. Good hydration.",
        BERRIES_JUICY_COOKED = "Spoilage is a constant threat.",
		BERRYBUSH =
		{
			BARREN = "It will require an intervention.",
			WITHERED = "Ardisia crenata don't do well in extreme heat.",
			GENERIC = "It's an Ardisia crenata bush.",
			PICKED = "The berries are growing back, slowly.",
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",--removed
			DISEASING = "Hm... The leaves are curling at the edges.",--removed
			BURNING = "Combustion!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "It needs some agricultural attention.",
			WITHERED = "The Ardisia crenata variant has shriveled in the heat.",
			GENERIC = "That bush looks ready for harvest.",
			PICKED = "It will have to wait.",
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",--removed
			DISEASING = "Hm... The leaves are curling at the edges.",--removed
			BURNING = "Combustion!",
		},
		BIGFOOT = "Prehistoric!",--removed
		BIRDCAGE =
		{
			GENERIC = "This will safely contain one avian specimen.",
			OCCUPIED = "He is contained.",
			SLEEPING = "Shhhhh!",
			HUNGRY = "He's getting hungry.",
			STARVING = "He's looking a bit malnourished.",
			DEAD = "I do believe he has starved.",
			SKELETON = "I guess I could study the bones.",
		},
		BIRDTRAP = "A simple clap-trap for birds.",
		CAVE_BANANA_BURNT = "I do not believe this one can be restored.",
		BIRD_EGG = "It is unfertilized.",
		BIRD_EGG_COOKED = "Just needs some toast.",
		BISHOP = "A clockwork clergyman.",
		BLOWDART_FIRE = "Improvised inflammatory device.",
		BLOWDART_SLEEP = "Improvised tranquilizer device.",
		BLOWDART_PIPE = "Improvised missile device.",
		BLOWDART_YELLOW = "Improvised electric device.",
		BLUEAMULET = "The gem appears to be sucking energy out anything it touches.",
		BLUEGEM = "It is cold.",
		BLUEPRINT =
		{
            COMMON = "A detailed technical drawing.",
            RARE = "Such a rare and detailed drawing!",
        },
        SKETCH = "Detailed diagrams of a stone sculpture.",
		BLUE_CAP = "This seems to have medicinal properties.",
		BLUE_CAP_COOKED = "Chemistry has altered it.",
		BLUE_MUSHROOM =
		{
			GENERIC = "It is a fungus.",
			INGROUND = "It is dormant this time of day.",
			PICKED = "It requires hydration before it can fruit again.",
		},
		BOARDS = "Roughly hewn wood boards.",
		BONESHARD = "Remnants of a life well lived.",
		BONESTEW = "Not quite how mum used to make, but it smells superb!",
		BUGNET = "The tool of entomologists.",
		BUSHHAT = "Camouflage",
		BUTTER = "Lepidopterous lipids?",
		BUTTERFLY =
		{
			GENERIC = "A colorful lepidopteran.",
			HELD = "It is captured.",
		},
		BUTTERFLYMUFFIN = "Who knew butterflies made such nice baked goods?",
		BUTTERFLYWINGS = "Wings from a captured butterfly.",
		BUZZARD = "Cathartes, of course.",

		SHADOWDIGGER = "Well, I suppose we did need an extra set of hands... Hm.",

		CACTUS =
		{
			GENERIC = "A young barrel cactus.",
			PICKED = "Desperate times, desperate measures.",
		},
		CACTUS_MEAT_COOKED = "Delightfully devoid of spines.",
		CACTUS_MEAT = "I'm not sure it's been prepared properly.",
		CACTUS_FLOWER = "Reminds me of Burroughs. A favorite at the library.",

		COLDFIRE =
		{
			EMBERS = "The fire has almost self-extinguished.",
			GENERIC = "A rather strange, magical fire pit.",
			HIGH = "That fire is burning at an alarming rate.",
			LOW = "The fire could use some more fuel.",
			NORMAL = "A perfectly unusual fire.",
			OUT = "It can be re-lit.",
		},
		CAMPFIRE =
		{
			EMBERS = "The fire has almost self-extinguished.",
			GENERIC = "A camp fire.",
			HIGH = "That fire is burning at an alarming rate.",
			LOW = "The fire could use some more fuel.",
			NORMAL = "A perfectly average fire.",
			OUT = "It can be re-lit.",
		},
		CANE = "I'm no rabologist.",
		CATCOON = "A sort of a wildcat. Handsome fellow.",
		CATCOONDEN =
		{
			GENERIC = "An excellent hollow for a den.",
			EMPTY = "Looks used up.",
		},
		CATCOONHAT = "Not quite like Crockett's, but it'll do.",
		COONTAIL = "A flexible torso appendage.",
		CARROT = "Daucus carota. Edible, and delicious.",
		CARROT_COOKED = "Daucus carota, roasted to perfection.",
		CARROT_PLANTED = "Daucus carota is a root vegetable.",
		CARROT_SEEDS = "It can't begin growing until it's been planted, dear.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Ah! A proper desk! Just look at the finish on that wood!",
			BURNING = "Can we have nothing decent?",
			BURNT = "The destruction of knowledge is such a difficult thing to stomach.",
		},
		WATERMELON_SEEDS = "It can't begin growing until it's been planted, dear.",
		CAVE_FERN = "A lovely ornamental plant.",
		CHARCOAL = "It's mostly carbon and ash.",
        CHESSPIECE_PAWN = "Pawns that journey to the seat of power can be quite dangerous.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Represents the protective walls of the king's castle.",
            STRUGGLE = "It seems magic is afoot.",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "A knight, in service to the king. Or perhaps the queen.",
            STRUGGLE = "It seems magic is afoot.",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "A decorative stone carving of a bishop chess piece.",
            STRUGGLE = "It seems magic is afoot.",
        },
        CHESSPIECE_MUSE = "In chess, the queen is by far the most strategically formidable.",
        CHESSPIECE_FORMAL = "The king is, by all measures, a liability to everyone on the board.",
        CHESSPIECE_HORNUCOPIA = "It is a commonly held belief that art imitates life.",
        CHESSPIECE_PIPE = "I hope this does not have a bad influence on the children.",
        CHESSPIECE_DEERCLOPS = "An anatomical study of those strange beasts.",
        CHESSPIECE_BEARGER = "Quite expressive!",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Bust of Alces canadensis.",
        },
        CHESSPIECE_DRAGONFLY = "Artist's interpretation of mythical Diptera.",
		CHESSPIECE_MINOTAUR = "A rather convincing likeness.",
        CHESSPIECE_BUTTERFLY = "Carved in the lunar moth's likeness.",
        CHESSPIECE_ANCHOR = "Artists tend to reference what they're familiar with.",
        CHESSPIECE_MOON = "The missing chunk is a recent development.",
        CHESSPIECE_CARRAT = "A delightfully rendered likeness of the Daucus carota rattus.",
        CHESSPIECE_MALBATROSS = "I'll have to add an appendix to \"Birds of the World\".",
        CHESSPIECE_CRABKING = "A rendering of a treasure-obsessed crustacean.",
        CHESSPIECE_TOADSTOOL = "The artist captured the parasitic relationship beautifully.",
        CHESSPIECE_STALKER = "The artist faithfully replicated its skeletal structure.",
        CHESSPIECE_KLAUS = "A wonderfully seasonal simulacrum.",
        CHESSPIECE_BEEQUEEN = "A queenly tribute to the Apis mellifera.",
        CHESSPIECE_ANTLION = "A stately statuary of the Panthera auropunctata.",
        CHESSPIECE_BEEFALO = "It captures my beefalo's likeness quite well.",
		CHESSPIECE_KITCOON = "I should warn the children not to play too close to it.",
		CHESSPIECE_CATCOON = "The resemblance to the Felis lybica is incredible.",
        CHESSPIECE_GUARDIANPHASE3 = "I must commend the artist for their attention to detail.",
        CHESSPIECE_EYEOFTERROR = "A trophy that doubles as a useful anatomical model.",
        CHESSPIECE_TWINSOFTERROR = "A stone rendition of a pair of mechanical marvels.",

        CHESSJUNK1 = "The magician's unfinished projects?",
        CHESSJUNK2 = "The magician's unfinished projects?",
        CHESSJUNK3 = "The magician's unfinished projects?",
		CHESTER = "A motile storage chest.",
		CHESTER_EYEBONE =
		{
			GENERIC = "Oculus Mysterium.",
			WAITING = "The oculus is inactive.",
		},
		COOKEDMANDRAKE = "Mandragora officinarum, cooked in the name of discovery.",
		COOKEDMEAT = "It is slightly more appetizing when cooked.",
		COOKEDMONSTERMEAT = "It's still a little bit poisonous.",
		COOKEDSMALLMEAT = "It is slightly more appetizing when cooked.",
		COOKPOT =
		{
			COOKING_LONG = "It's got a bit to go before it's ready.",
			COOKING_SHORT = "Almost done!",
			DONE = "Supper time!",
			EMPTY = "It looks derelict when it's not cooking something.",
			BURNT = "Now it's truly derelict.",
		},
		CORN = "Zea mays, a great staple food.",
		CORN_COOKED = "Popped corn!",
		CORN_SEEDS = "It can't begin growing until it's been planted, dear.",
        CANARY =
		{
			GENERIC = "Serinus canaria. A historically useful sentinel species.",
			HELD = "Serinus canaria. We ought never enter a cave without one.",
		},
        CANARY_POISONED = "Oh, dear.",

		CRITTERLAB = "A perfect hollow for nesting animals.",
        CRITTER_GLOMLING = "How do you maintain flight, dear?",
        CRITTER_DRAGONLING = "What a darling Diptera juvenile!",
		CRITTER_LAMB = "I could just squish that widdle face.",
        CRITTER_PUPPY = "Who's the sweetest little Canis lupus?",
        CRITTER_KITTEN = "Now it feels like home.",
        CRITTER_PERDLING = "What a handsome poult you are!",
		CRITTER_LUNARMOTHLING = "Who wuvs their widdle specimen?",

		CROW =
		{
			GENERIC = "Corvus brachyrhynchos.",
			HELD = "A perfectly handsome specimen.",
		},
		CUTGRASS = "Some grass cuttings.",
		CUTREEDS = "Some rush cuttings.",
		CUTSTONE = "Some smoothed rock slabs.",
		DEADLYFEAST = "I'm not sure that's good to eat.", --unimplemented
		DEER =
		{
			GENERIC = "It has shed its antler for the warmer months.",
			ANTLER = "Its antler has grown in for winter.",
		},
        DEER_ANTLER = "It looks like a key, but it's quite brittle.",
        DEER_GEMMED = "The poor creature has been forcibly fused to a magic gem.",
		DEERCLOPS = "Laurasiatheria!",
		DEERCLOPS_EYEBALL = "I feel a vague sense of accomplishment.",
		EYEBRELLAHAT =	"The cornea must be quite water-repellent.",
		DEPLETED_GRASS =
		{
			GENERIC = "A tuft of a graminoid.",
		},
        GOGGLESHAT = "I can't imagine these improving visibility.",
        DESERTHAT = "Much more effective than reading glasses.",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "Unhygienic!",
		DIVININGROD =
		{
			COLD = "The dial is moving faintly.", --singleplayer
			GENERIC = "It is a magitechnical homing device.", --singleplayer
			HOT = "Here we are!", --singleplayer
			WARM = "This is definitely the right track.", --singleplayer
			WARMER = "Must be getting close.", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "It will need some work before it can function.", --singleplayer
			READY = "It simply needs a key now.", --singleplayer
			UNLOCKED = "Ah. The beauty of functionality.", --singleplayer
		},
		DIVININGRODSTART = "This rod could be useful!", --singleplayer
		DRAGONFLY = "It's some kind of mythical variant of a Diptera.",
		ARMORDRAGONFLY = "Pyrotechnic armor!",
		DRAGON_SCALES = "Scales from an insect? Unheard of!",
		DRAGONFLYCHEST = "Scales! Scales are the winner!",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "Hm, that was an interesting choice of alteration.",
			GENERIC = "A very efficient, magically powered furnace.", --no gems
			NORMAL = "It is burning at half strength, presently.", --one gem
			HIGH = "The magic of the two gems keeps it burning at maximum strength.", --two gems
		},

        HUTCH = "Eons of subterranean evolution went into this widdle malformed monstrosity.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Pygocentrus Nattereri.",
            WAITING = "Mortuus piscis.",
        },
		LAVASPIT =
		{
			HOT = "Its saliva is similar to molten lava.",
			COOL = "It's cooled down, almost like basalt.",
		},
		LAVA_POND = "Molten rock. Best not to get too close.",
		LAVAE = "I believe it is a larval dragonfly.",
		LAVAE_COCOON = "A domestication opportunity, I'd say.",
		LAVAE_PET =
		{
			STARVING = "This creature requires sustenance immediately!",
			HUNGRY = "This creature is hungry.",
			CONTENT = "I have to admit it is rather appealing.",
			GENERIC = "A healthy larval dragonfly.",
		},
		LAVAE_EGG =
		{
			GENERIC = "A large macrolecithal egg.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "The temperature of this egg is below optimal.",
			COMFY = "This egg is at a suitable temperature for hatching.",
		},
		LAVAE_TOOTH = "An egg tooth used by a baby reptile to break out of its egg.",

		DRAGONFRUIT = "Hylocereus undatus, or pitahaya blanca.",
		DRAGONFRUIT_COOKED = "Pleasantly prepared pitahaya blanca.",
		DRAGONFRUIT_SEEDS = "It can't begin growing until it's been planted, dear.",
		DRAGONPIE = "I do love a nice fruit pie.",
		DRUMSTICK = "A leg of poultry.",
		DRUMSTICK_COOKED = "Not terribly healthy, but my is it delicious!",
		DUG_BERRYBUSH = "It requires soil to grow.",
		DUG_BERRYBUSH_JUICY = "It requires soil to grow.",
		DUG_GRASS = "It requires soil to grow.",
		DUG_MARSH_BUSH = "It requires soil to grow.",
		DUG_SAPLING = "It requires soil to grow.",
		DURIAN = "Aha, the Durio zibethinus. It really does reek.",
		DURIAN_COOKED = "Cooking this certainly did not improve its odor.",
		DURIAN_SEEDS = "It can't begin growing until it's been planted, dear.",
		EARMUFFSHAT = "Poor Leporidae. At least it's warm.",
		EGGPLANT = "A nightshade. Solanum melongena, specifically.",
		EGGPLANT_COOKED = "For your enjoyment: Braised Solanum melongena.",
		EGGPLANT_SEEDS = "It can't begin growing until it's been planted, dear.",

		ENDTABLE =
		{
			BURNT = "Well, such as it is.",
			GENERIC = "It's pleasant to see a little decor out here.",
			EMPTY = "Ah, could use a doily, wouldn't you say?",
			WILTED = "A pity. Shall we find replacements?",
			FRESHLIGHT = "The more light to read by the better, in my opinion.",
			OLDLIGHT = "It is Maxwell's turn to procure bulbs. I've it written down right here.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "The tree is burning.",
			BURNT = "A carbonized tree.",
			CHOPPED = "It has been harvested.",
			POISON = "That is no tree I've seen before!",
			GENERIC = "Fagales of some kind. It bears fruit when fully grown.",
		},
		ACORN = "Deciduous seeds encased in a Pericarp.",
        ACORN_SAPLING = "Deciduous seeds approaching maturity.",
		ACORN_COOKED = "The poison has been successfully cooked out of them.",
		BIRCHNUTDRAKE = "Run awaaay!",
		EVERGREEN =
		{
			BURNING = "The tree is burning.",
			BURNT = "A carbonized tree.",
			CHOPPED = "It has been harvested.",
			GENERIC = "A generically coniferous tree.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "The tree is burning.",
			BURNT = "A carbonized tree.",
			CHOPPED = "It has been harvested.",
			GENERIC = "This genus seems to lack reproductive capabilities.",
		},
		TWIGGYTREE =
		{
			BURNING = "The tree is burning.",
			BURNT = "A carbonized tree.",
			CHOPPED = "It has been harvested.",
			GENERIC = "This species yields lumber and pliable sprigs. Useful.",
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "It is fast growing into a fine young tree.",
        TWIGGY_OLD = "It would be a waste of time and resources to chop that old thing.",
		TWIGGY_NUT = "Seeds encased in a mature strobilus.",
		EYEPLANT = "I believe they are controlled by the larger plant.",
		INSPECTSELF = "I'm aging like a fine, intelligent wine, am I not?",
		FARMPLOT =
		{
			GENERIC = "A small cultivated patch of ground.",
			GROWING = "The plants are extracting minerals from the ground.",
			NEEDSFERTILIZER = "It has been rendered infertile for lack of nutrients.",
			BURNT = "It shan't grow a crop again.",
		},
		FEATHERHAT = "Not quite the genuine article, but it might fool some birds.",
		FEATHER_CROW = "Feather of Corvus. Or Alcidae?",
		FEATHER_ROBIN = "Feather of Cardinalis.",
		FEATHER_ROBIN_WINTER = "It looks like a feather of Cardinalis, but white.",
		FEATHER_CANARY = "Feather of Canaria.",
		FEATHERPENCIL = "Oh, how I missed proper writing implements!",
        COOKBOOK = "A collection of culinary observations.",
		FEM_PUPPET = "Poor girl.", --single player
		FIREFLIES =
		{
			GENERIC = "They disperse when I approach.",
			HELD = "Their bioluminescent properties might prove useful.",
		},
		FIREHOUND = "That hound is more dangerous than the others.",
		FIREPIT =
		{
			EMBERS = "The fire has almost self-extinguished.",
			GENERIC = "A fire pit.",
			HIGH = "That fire is burning at an alarming rate.",
			LOW = "The fire could use some more fuel.",
			NORMAL = "A perfectly average fire.",
			OUT = "It can be re-lit.",
		},
		COLDFIREPIT =
		{
			EMBERS = "The fire has almost self-extinguished.",
			GENERIC = "A fire pit. It's chilly.",
			HIGH = "That fire is burning at an alarming rate.",
			LOW = "The fire could use some more fuel, whatever fuel it takes.",
			NORMAL = "A fire. Of some kind.",
			OUT = "It can be re-lit.",
		},
		FIRESTAFF = "Some kind of fire-throwing contraption.",
		FIRESUPPRESSOR =
		{
			ON = "Pitch that ice!",
			OFF = "Nothing to see here.",
			LOWFUEL = "Fuel's getting low.",
		},

		FISH = "Some kind of whitefish, I believe.",
		FISHINGROD = "I've read all about fishing. It should be a snap.",
		FISHSTICKS = "Give me some tartar sauce and I'm in heaven.",
		FISHTACOS = "Personally I relish a spot of spice on my fish.",
		FISH_COOKED = "Beautifully grilled.",
		FLINT = "A hard nodule of quartz.",
		FLOWER =
		{
            GENERIC = "It's a wildflower. I'm unfamiliar with the species.",
            ROSE = "Ah, a Rosa Macdub... what's it doing out here?",
        },
        FLOWER_WITHERED = "This flower lacks the essentials for growth.",
		FLOWERHAT = "How celebratory.",
		FLOWER_EVIL = "It's not often one sees a flower with such a powerful aura.",
		FOLIAGE = "These may have some nutritional value.",
		FOOTBALLHAT = "Protective gear for full-contact endeavors.",
        FOSSIL_PIECE = "Hardened remains preserved by taphonomic processes.",
        FOSSIL_STALKER =
        {
			GENERIC = "There are pieces of the skeleton still yet to be assembled.",
			FUNNY = "Paleontological incompetence has produced a sad excuse for a creature.",
			COMPLETE = "Oh! A specimen fit for a museum!",
        },
        STALKER = "A mistake in need of correcting.",
        STALKER_ATRIUM = "We could have learned much from each other.",
        STALKER_MINION = "The weaver's twisted creation.",
        THURIBLE = "We were its intended recipient.",
        ATRIUM_OVERGROWTH = "It would take much too long to decipher.",
		FROG =
		{
			DEAD = "Considered a delicacy in some countries.",
			GENERIC = "A amphibian tetrapod.",
			SLEEPING = "It's sleeping.",
		},
		FROGGLEBUNWICH = "It was an interesting choice to serve it as a sandwich.",
		FROGLEGS = "They're still twitching a bit.",
		FROGLEGS_COOKED = "Not unlike a chicken wing.",
		FRUITMEDLEY = "What a nice selection of fruit!",
		FURTUFT = "Fur from a Bearger.",
		GEARS = "Various cogs and wheels.",
		GHOST = "It must be fake. I don't believe it.",
		GOLDENAXE = "The most malleable of metals, but let's see how this chops.",
		GOLDENPICKAXE = "The most malleable of metals, but let's see how this mines.",
		GOLDENPITCHFORK = "The most malleable of metals, but let's see how this tills.",
		GOLDENSHOVEL = "The most malleable of metals, but let's see how this digs.",
		GOLDNUGGET = "A small lump of gold. Atomic number 79.",
		GRASS =
		{
			BARREN = "It needs poop.",
			WITHERED = "It can't survive in this hot climate.",
			BURNING = "Combustion!",
			GENERIC = "A cluster graminoid stalks.",
			PICKED = "I think it will grow back.",
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.", --unimplemented
			DISEASING = "Hm... There are spots of discoloration here.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "I've never encountered this species before. Seems harmless.",
			DISEASED = "It appears to be infected by some unknown pathogen.", --unimplemented
		},
		GREEN_CAP = "Seems edible, though it may not be totally sane to consume it.",
		GREEN_CAP_COOKED = "Chemistry has altered it.",
		GREEN_MUSHROOM =
		{
			GENERIC = "It is a fungus.",
			INGROUND = "It is dormant this time of day.",
			PICKED = "It requires hydration before it can fruit again.",
		},
		GUNPOWDER = "Knowledge is power!",
		HAMBAT = "This was perhaps not the most efficient use of resources.",
		HAMMER = "A worker's tool.",
		HEALINGSALVE = "A natural disinfectant.",
		HEATROCK =
		{
			FROZEN = "Its temperature is below freezing.",
			COLD = "It's a bit chilly.",
			GENERIC = "Its temperature is totally unremarkable.",
			WARM = "It is retaining thermal energy. But only a bit.",
			HOT = "It is warm enough to radiate heat and light!",
		},
		HOME = "A place to kick up one's feet.",
		HOMESIGN =
		{
			GENERIC = "A navigational aid. \"You are here\".",
            UNWRITTEN = "A chance to give direction.",
			BURNT = "Not much of an aid now.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "A navigational aid. \"Thataway\".",
            UNWRITTEN = "A chance to give direction.",
			BURNT = "Not much of an aid now.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "A navigational aid. \"Thataway\".",
            UNWRITTEN = "A chance to give direction.",
			BURNT = "Not much of an aid now.",
		},
		HONEY = "Sweetened plant nectar.",
		HONEYCOMB = "Beeswax used for storing honey.",
		HONEYHAM = "Honey was the only sweetener used for this lovely ham.",
		HONEYNUGGETS = "Bite-sized sweetened meat!",
		HORN = "What an excellent specimen! I can almost hear the beefalo.",
		HOUND = "That hound is not domesticated.",
		HOUNDCORPSE =
		{
			GENERIC = "It would be in our best interest to dispose of it quickly.",
			BURNING = "That ought to prevent any more mishaps.",
			REVIVING = "Fascinating, it's reanimating before my eyes.",
		},
		HOUNDBONE = "The endoskeleton of Canis lupus, definitely not familiaris.",
		HOUNDMOUND = "Those bones are foreboding.",
		ICEBOX = "It is a crude heat exchanger.",
		ICEHAT = "A perfect cube of ice.",
		ICEHOUND = "What a strange, cold beast.",
		INSANITYROCK =
		{
			ACTIVE = "I must be seeing things.",
			INACTIVE = "It appears to be a tiny pyramid.",
		},
		JAMMYPRESERVES = "I'd love some toast to put this jam on. Oh well.",

		KABOBS = "Meat on a stick, what next?",
		KILLERBEE =
		{
			GENERIC = "It is especially venomous.",
			HELD = "It is not pleased.",
		},
		KNIGHT = "An automatic equine.",
		KOALEFANT_SUMMER = "Koalefanta Proboscidea.",
		KOALEFANT_WINTER = "Koalefanta Proboscidea in thick winter pelage.",
		KRAMPUS = "It's a mythological holiday monster.",
		KRAMPUS_SACK = "It seems bigger inside than out.",
		LEIF = "I... don't even know.",
		LEIF_SPARSE = "I... don't even know.",
		LIGHTER  = "Ah, a mechanical tool for fire starting. How useful.",
		LIGHTNING_ROD =
		{
			CHARGED = "Radiant electrical energy!",
			GENERIC = "Highly conductive!",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "A variant of Capra aegagrus, keen on electricity.",
			CHARGED = "Quite keen.",
		},
		LIGHTNINGGOATHORN = "There must be something unnatural in the horn.",
		GOATMILK = "Tantalizing!",
		LITTLE_WALRUS = "The juvenile is not as aggressive.",
		LIVINGLOG = "This log is special.",
		LOG =
		{
			BURNING = "An axial section of tree trunk. On fire.",
			GENERIC = "An axial section of tree trunk.",
		},
		LUCY = "A perfectly fine looking axe.",
		LUREPLANT = "An invasive plant species.",
		LUREPLANTBULB = "Now it can be planted wherever is best.",
		MALE_PUPPET = "Poor boy.", --single player

		MANDRAKE_ACTIVE = "Mandragora officinarum. But with a face.",
		MANDRAKE_PLANTED = "Mandragora officinarum.",
		MANDRAKE = "Mandragora officinarum. Deceased.",

        MANDRAKESOUP = "Mandragora officinarum, prepared as a soup in the name of discovery.",
        MANDRAKE_COOKED = "Mandragora officinarum, cooked in the name of discovery.",
        MAPSCROLL = "The potential of the blank page is paralyzing for some.",
        MARBLE = "A statuesque rock.",
        MARBLEBEAN = "Marble growth is arboriculturally impossible.",
        MARBLEBEAN_SAPLING = "I believe it's a perennial.",
        MARBLESHRUB = "Not ideal for topiary.",
        MARBLEPILLAR = "It shows the touch of a Roman artisan. How amazing.",
        MARBLETREE = "Amazing. A tree made entirely of marble.",
        MARSH_BUSH =
        {
			BURNT = "Burned entirely.",
            BURNING = "Combustion!",
            GENERIC = "A cluster of brambles.",
            PICKED = "Picking brambles is dangerous.",
        },
        BURNT_MARSH_BUSH = "Reduced to ash.",
        MARSH_PLANT = "A swamp-dwelling rhizome.",
        MARSH_TREE =
        {
            BURNING = "Combustion!",
            BURNT = "A carbonized mangrove.",
            CHOPPED = "It has been felled.",
            GENERIC = "A mangal rhizophora.",
        },
        MAXWELL = "Get down from there this instant!",--single player
        MAXWELLHEAD = "I wish he wouldn't do that.",--removed
        MAXWELLLIGHT = "How magical!",--single player
        MAXWELLLOCK = "Now I just need a key.",--single player
        MAXWELLTHRONE = "What an intimidating chair.",--single player
        MEAT = "It's improper to eat it raw, but if we've no choice...",
        MEATBALLS = "A pile of processed meat. Who knows what went into this.",
        MEATRACK =
        {
            DONE = "The process has completed.",
            DRYING = "Dehydration is a slow process.",
            DRYINGINRAIN = "The rain has temporarily halted the dehydration process.",
            GENERIC = "Meats can be dehydrated.",
            BURNT = "It doesn't seem stable.",
            DONE_NOTMEAT = "The process has completed.",
            DRYING_NOTMEAT = "Dehydration is a slow process.",
            DRYINGINRAIN_NOTMEAT = "The rain has temporarily halted the dehydration process.",
        },
        MEAT_DRIED = "Salty, yet satisfying.",
        MERM = "A piscean biped!",
        MERMHEAD =
        {
            GENERIC = "I'm uncertain whether it is rotting or fermenting.",
            BURNT = "It's neither rotting nor fermenting now.",
        },
        MERMHOUSE =
        {
            GENERIC = "Obviously dilapidated.",
            BURNT = "On beyond dilapidated.",
        },
        MINERHAT = "This would make a great reading light.",
        MONKEY = "They produce quite an odor.",
        MONKEYBARREL = "This appears to be the home of several primates.",
        MONSTERLASAGNA = "Lasagna or no, it would be hazardous to consume it.",
        FLOWERSALAD = "Plenty of nutrients!",
        ICECREAM = "Nothing like a book and a bowl of ice cream.",
        WATERMELONICLE = "The melon is entirely encased in an ice lattice.",
        TRAILMIX = "Mmmm, natural!",
        HOTCHILI = "Chili gives me indigestion.",
        GUACAMOLE = "I always made guacamole for science day at the library.",
        MONSTERMEAT = "It would be hazardous to consume this.",
        MONSTERMEAT_DRIED = "Salty, yet satisfying.",
        MOOSE = "I dub it Alces canadensis.",
        MOOSE_NESTING_GROUND = "I should like to research its mating habits, someday.",
        MOOSEEGG = "What a marvel!",
        MOSSLING = "I suppose that's approximately what I expected.",
        FEATHERFAN = "This will induce quite an airflow!",
        MINIFAN = "Its aerodynamic principals are astonishing.",
        GOOSE_FEATHER = "Soft body down! It makes me wish I could sleep.",
        STAFF_TORNADO = "I've never seen a weather vane employed as a weapon.",
        MOSQUITO =
        {
            GENERIC = "A thirsty female Haemagogus Devorator.",
            HELD = "It is securely stored.",
        },
        MOSQUITOSACK = "The stomach of a Culicidae, brimming with blood.",
        MOUND =
        {
            DUG = "A desecrated burial mound.",
            GENERIC = "A burial mound.",
        },
        NIGHTLIGHT = "Curiously luminescent.",
        NIGHTMAREFUEL = "Ectoplasmic residue.",
        NIGHTSWORD = "Transdimensional weaponry.",
        NITRE = "Also known as saltpeter.",
        ONEMANBAND = "An impressive improvement to the traditional pipe and tabor.",
        OASISLAKE =
		{
			GENERIC = "It could support a small ecosystem.",
			EMPTY = "Perhaps it's not the right time of year.",
		},
        PANDORASCHEST = "An artifact which may contain other artifacts.",
        PANFLUTE = "Hollow reeds with harmonic resonance.",
        PAPYRUS = "Thin sheets of cellulose and lignin.",
        WAXPAPER = "Now we just require rope to secure it in place.",
        PENGUIN = "What a classy bird.",
        PERD = "Nasty Meleagris, you stay away from those berries!",
        PEROGIES = "A wonderfully bland dumpling.",
        PETALS = "Now it's a delightful handful of potpourri.",
        PETALS_EVIL = "Interesting. These petals seem to have a mind of their own.",
        PHLEGM = "The congealed mucus retains its sticky texture.",
        PICKAXE = "A specialized axe for chipping away at rocks.",
        PIGGYBACK = "A face only necessity could love.",
        PIGHEAD =
        {
            GENERIC = "Tut tut. It's a head on a stick.",
            BURNT = "It's the charred remains of a head on a stick. Tsk!",
        },
        PIGHOUSE =
        {
            FULL = "I wonder what they do in there.",
            GENERIC = "The pig creatures have such prosaic taste in architecture.",
            LIGHTSOUT = "That was quite rude.",
            BURNT = "The house had no fire-prevention system.",
        },
        PIGKING = "He appears to be the leader of the village.",
        PIGMAN =
        {
            DEAD = "Don't worry, there are plenty more where that came from.",
            FOLLOWER = "He seems to have bonded with me.",
            GENERIC = "It's a semi-intelligent bipedal pig.",
            GUARD = "It appears to be a guardian.",
            WEREPIG = "It's a lycanthropic pig.",
        },
        PIGSKIN = "The haunch of a semi-intelligent bipedal pig.",
        PIGTENT = "Filthy.",
        PIGTORCH = "I wonder how it's fueled.",
        PINECONE = "Conifer seeds encased in a mature strobilus.",
        PINECONE_SAPLING = "Conifer seeds approaching maturity.",
        LUMPY_SAPLING = "Perhaps this species is surculose.",
        PITCHFORK = "Its design is effective at loosening earth.",
        PLANTMEAT = "The plant produced a meaty substance.",
        PLANTMEAT_COOKED = "This looks much safer for consumption.",
        PLANT_NORMAL =
        {
            GENERIC = "It's a... plant. Of some kind.",
            GROWING = "It is not yet ready for harvest.",
            READY = "It looks mature, now.",
            WITHERED = "It couldn't survive the heat.",
        },
        POMEGRANATE = "Punica granatum. Watery, sweet and a bit sour.",
        POMEGRANATE_COOKED = "Punica granatum is so nice when it's warmed up.",
        POMEGRANATE_SEEDS = "It can't begin growing until it's been planted, dear.",
        POND = "A small but deep freshwater pond.",
        POOP = "A quantity of animal feces. How fragrant.",
        FERTILIZER = "A bucket of animal feces. Pungent.",
        PUMPKIN = "Cucurbita pepo.",
        PUMPKINCOOKIE = "Pumpkin biscuits, goody!",
        PUMPKIN_COOKED = "Cooked Cucurbita pepo. Gooey and delicious.",
        PUMPKIN_LANTERN = "Carving the Cucurbita pepo is such a nice pastime.",
        PUMPKIN_SEEDS = "It can't begin growing until it's been planted, dear.",
        PURPLEAMULET = "I can almost sense it beckoning to something.",
        PURPLEGEM = "It gives off a strange aura.",
        RABBIT =
        {
            GENERIC = "It's some kind of Lagomorph. With horns.",
            HELD = "It is a cute widdle horned Lagomorph.",
        },
        RABBITHOLE =
        {
            GENERIC = "It looks like a small animal's burrow.",
            SPRING = "I hope the Lagomorph is all right down there!",
        },
        RAINOMETER =
        {
            GENERIC = "Measure before you act.",
            BURNT = "I can't read any measurements from that husk.",
        },
        RAINCOAT = "Totally non-porous.",
        RAINHAT = "I hate when my bun gets wet.",
        RATATOUILLE = "Nicoise, so nutritious!",
        RAZOR = "A personal hygiene implement.",
        REDGEM = "It is warm.",
        RED_CAP = "Red usually indicates poison.",
        RED_CAP_COOKED = "Chemistry has altered it.",
        RED_MUSHROOM =
        {
            GENERIC = "It is a fungus.",
            INGROUND = "It is dormant this time of day.",
            PICKED = "It requires hydration before it can fruit again.",
        },
        REEDS =
        {
            BURNING = "Combustion!",
            GENERIC = "A group of juncaceae graminoids.",
            PICKED = "I believe they shall grow back.",
        },
        RELIC = "A relic of an ancient civilization, lost to the ravages of time.",
        RUINS_RUBBLE = "With a little elbow grease this could be put into working order.",
        RUBBLE = "Looks like a job for library paste!",
        RESEARCHLAB =
        {
            GENERIC = "It's a research station. I can learn new things with it.",
            BURNT = "I can't learn anything from a carbonized research station.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "It's a research station. I can learn new things with it.",
            BURNT = "I can't learn anything from a carbonized research station.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "Perhaps I have gone too far.",
            BURNT = "An omen.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "I think the hat collects energy from the air.",
            BURNT = "It won't be collecting any energy now.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "How very pagan.",
            BURNT = "It has been smote.",
        },
        RESURRECTIONSTONE = "That stone has regenerative powers.",
        ROBIN =
        {
            GENERIC = "Cardinalis! Beautiful plumage.",
            HELD = "This little fellow will be my friend.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "A winter coat for the Cardinalis? How peculiar!",
            HELD = "It's so delicate.",
        },
        ROBOT_PUPPET = "Poor child.", --single player
        ROCK_LIGHT =
        {
            GENERIC = "A capped lava pit.",--removed
            OUT = "Nothing but a sheath of igneous rock now.",--removed
            LOW = "The cooling process has begun.",--removed
            NORMAL = "Much too hot to touch.",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "It looks as though it can be moved.",
            RAISED = "We must clear the surrounding boulders first.",
        },
        ROCK = "A large sedimentary rock.",
        PETRIFIED_TREE = "Should make for an excellent building material.",
        ROCK_PETRIFIED_TREE = "Should make for an excellent building material.",
        ROCK_PETRIFIED_TREE_OLD = "Should make for an excellent building material.",
        ROCK_ICE =
        {
            GENERIC = "A small block of extremely dense ice.",
            MELTED = "It must have melted due to its small size.",
        },
        ROCK_ICE_MELTED = "It must have melted due to its small size.",
        ICE = "The solid state of water.",
        ROCKS = "A handful of assorted rocks.",
        ROOK = "A clockwork castle.",
        ROPE = "A short length of strong hemp rope.",
        ROTTENEGG = "How unappetizing.",
        ROYAL_JELLY = "In the wild this might have produced more queens.",
        JELLYBEAN = "Sweets, emulsified with beeswax.",
        SADDLE_BASIC = "A crude device for equestrianism.",
        SADDLE_RACE = "The decorative antennae are a lovely touch.",
        SADDLE_WAR = "A favorite perch of generals and assorted warlords.",
        SADDLEHORN = "A device for forceful unfurnishment.",
        SALTLICK = "A cube of sodium chloride to lure wild beasts.",
        BRUSH = "Microscopic barbs allow for optimal hair retrieval.",
		SANITYROCK =
		{
			ACTIVE = "Fascinating. I'll have to study these markings later.",
			INACTIVE = "It seems to have sunk into the soil.",
		},
		SAPLING =
		{
			BURNING = "Combustion!",
			WITHERED = "The heat's gotten to it.",
			GENERIC = "It's a small tree.",
			PICKED = "Odd. I thought that would have killed it.",
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.", --removed
			DISEASING = "Hm... Seems more brittle than is usual.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Ah, excellent. No more leaving clothes on branches to get wrinkled.",
			BURNING = "Hm. I suppose it was quite flammable.",
			BURNT = "Pity. He was such a jolly fellow.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "A method of ceramic production. We somehow use it for sculpture.",
			BLOCK = "Oh, I never considered myself much of an artist!",
			SCULPTURE = "We were all in dire need of an emotional outlet, I believe.",
			BURNT = "What a shame. It was a lovely addition.",
   		},
        SCULPTURE_KNIGHTHEAD = "You have to lift with your knees, dear.",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "Very tasteful.",
			UNCOVERED = "They say every block of stone has a statue inside.",
			FINISHED = "The structure is whole once again.",
			READY = "Something is stirring within.",
		},
        SCULPTURE_BISHOPHEAD = "I can lift it. I'm more spry than I look.",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "There's an almost animalistic ferocity in the chiselwork.",
			UNCOVERED = "So this is what was lurking inside.",
			FINISHED = "An excellent repair job.",
			READY = "Something is stirring within.",
		},
        SCULPTURE_ROOKNOSE = "That's a thrown out back waiting to happen.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "I feel a light dusting of magic. Odd.",
			UNCOVERED = "What an awful state it's in!",
			FINISHED = "We may want to keep an eye on this.",
			READY = "Something is stirring within.",
		},
        GARGOYLE_HOUND = "Completely petrified as a result of lunar exposure.",
        GARGOYLE_WEREPIG = "Lunar light catalyzes a strange reaction in its skin.",
		SEEDS = "A handful of unidentifiable seeds.",
		SEEDS_COOKED = "A toasted embryonic plant treat!",
		SEWING_KIT = "A simple implement for domestic tasks.",
		SEWING_TAPE = "A high grade adhesive, good for small mends.",
		SHOVEL = "It's a shovel. Surely you've seen one before?",
		SILK = "Protein fiber extruded from an arachnid.",
		SKELETON = "An incredibly well preserved human skeleton.",
		SCORCHED_SKELETON = "You don't inspire a great deal of confidence, dear.",
		SKULLCHEST = "A container resembling a cranium.", --removed
		SMALLBIRD =
		{
			GENERIC = "A rather diminutive specimen of the class Aves.",
			HUNGRY = "It requires sustenance.",
			STARVING = "Without sustenance, it will surely perish.",
			SLEEPING = "It tired itself out.",
		},
		SMALLMEAT = "It's a small, raw piece of meat.",
		SMALLMEAT_DRIED = "High sodium content.",
		SPAT = "Ovis chalybs, and a right mean looking one at that.",
		SPEAR = "Ancient weapons technology.",
		SPEAR_WATHGRITHR = "What a handsome hunting implement.",
		WATHGRITHRHAT = "Anachronistic drivel.",
		SPIDER =
		{
			DEAD = "It's dead.",
			GENERIC = "A large, carnivorous arachnid species.",
			SLEEPING = "They appear to be nocturnal.",
		},
		SPIDERDEN = "Fascinating. These spiders have a communal hive.",
		SPIDEREGGSACK = "A highly portable spider egg sack.",
		SPIDERGLAND = "This gland secretes a mildly toxic venom.",
		SPIDERHAT = "Psionic control to exert over spiders. Excluding the boy, of course.",
		SPIDERQUEEN = "That must be the center of the hive-mind.",
		SPIDER_WARRIOR =
		{
			DEAD = "He gave his life for his queen.",
			GENERIC = "It appears to be of the warrior caste.",
			SLEEPING = "A well deserved rest, no doubt.",
		},
		SPOILED_FOOD = "It is heavy with bacteria.",
        STAGEHAND =
        {
			AWAKE = "That was an underhanded trick!",
			HIDING = "Something devious is lurking in the shadows.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "It's been sculpted from metamorphic rock.",
            TYPE1 = "A Grecian-inspired sculpture of the muse Melpomene. Some liberties have been taken.",
            TYPE2 = "A Grecian-inspired sculpture of the muse Thalia. Some liberties have been taken.",
            TYPE3 = "The rain may inadvertently turn it into a bird bath.", --bird bath type statue
        },
		STATUEHARP = "A simple statue.",
		STATUEMAXWELL = "He's actually quite a sweet boy when you peel away the ego.",
		STEELWOOL = "It has a variety of household uses.",
		STINGER = "It tapers to a sharp point.",
		STRAWHAT = "This will offer some protection from the sun.",
		STUFFEDEGGPLANT = "This aubergine has been cooked and packed with comestibles.",
		SWEATERVEST = "This vest screams \"stylish, but well-read.\".",
		REFLECTIVEVEST = "That could keep one moderately cool.",
		HAWAIIANSHIRT = "I prefer tweed.",
		TAFFY = "That's terrible for your teeth, dear.",
		TALLBIRD = "Magnus Avis, fully developed.",
		TALLBIRDEGG = "It requires incubation.",
		TALLBIRDEGG_COOKED = "Full of cholesterol.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "You will catch your death of cold!",
			GENERIC = "Development appears to be progressing.",
			HOT = "Exposure to temperature extremes may result in death.",
			LONG = "A watched pot never boils.",
			SHORT = "We shall soon reap the fruits of our labors.",
		},
		TALLBIRDNEST =
		{
			GENERIC = "What a tremendous Magnus Avis egg!",
			PICKED = "The nest is empty. Soon the cycle will begin anew.",
		},
		TEENBIRD =
		{
			GENERIC = "An adolescent avian.",
			HUNGRY = "Please keep your voice level to a minimum.",
			STARVING = "A very naughty bird!",
			SLEEPING = "It seems to have had too much excitement.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "This machine can be used to travel between worlds.", --single player
			GENERIC = "This runestone has unique geometric properties!", --single player
			LOCKED = "The device needs to be activated.", --single player
			PARTIAL = "The device is in a partial state of completion.", --single player
		},
		TELEPORTATO_BOX = "An electrical charge regulator.", --single player
		TELEPORTATO_CRANK = "It applies basic mechanical principles.", --single player
		TELEPORTATO_POTATO = "Neither fully organic nor inorganic!", --single player
		TELEPORTATO_RING = "A torus of alloys and wiring.", --single player
		TELESTAFF = "The gem appears to focus the nightmare fuel.",
		TENT =
		{
			GENERIC = "Sleeping in there would give me a stiff neck.",
			BURNT = "It wasn't doing me much good anyhow.",
		},
		SIESTAHUT =
		{
			GENERIC = "I can barely sleep on a bed, never mind the ground.",
			BURNT = "It wasn't doing me much good anyhow.",
		},
		TENTACLE = "A horror waiting in the mud.",
		TENTACLESPIKE = "Never grab the pointy end.",
		TENTACLESPOTS = "Hmmm, reproductive organs.",
		TENTACLE_PILLAR = "There's more of it below than above!",
        TENTACLE_PILLAR_HOLE = "It appears to be all connected somehow.",
		TENTACLE_PILLAR_ARM = "A tiny horror waiting in the mud.",
		TENTACLE_GARDEN = "I wonder how they breed?",
		TOPHAT = "How bourgeois.",
		TORCH = "An improvised handheld light.",
		TRANSISTOR = "This is quite advanced technology.",
		TRAP = "A simple stick-and-basket trap.",
		TRAP_TEETH = "It's covered with a thin film of canine digestive fluid.",
		TRAP_TEETH_MAXWELL = "A crude attempt at tricking me.", --single player
		TREASURECHEST =
		{
			GENERIC = "A storage chest.",
			BURNT = "The charred skeleton of a storage chest.",
		},
		TREASURECHEST_TRAP = "Looks suspicious...",
		SACRED_CHEST =
		{
			GENERIC = "A small dimension tightly bound in magic.",
			LOCKED = "The magic's at work.",
		},
		TREECLUMP = "The flora grows thick here.", --removed

		TRINKET_1 = "What a lovely set of bottle washers! Too bad they're all melted.", --Melted Marbles
		TRINKET_2 = "A fake membranophone.", --Fake Kazoo
		TRINKET_3 = "Oh, I just love the bard.", --Gord's Knot
		TRINKET_4 = "What a positively, delightfully odd little fellow.", --Gnome
		TRINKET_5 = "This spacecraft looks to have inadequate thermal controls.", --Toy Rocketship
		TRINKET_6 = "I do hope WX-78 is feeling alright.", --Frazzled Wires
		TRINKET_7 = "I think I'll keep this. I know someone who might like it.", --Ball and Cup
		TRINKET_8 = "It reminds me of my bathtub. I could use a long soak.", --Rubber Bung
		TRINKET_9 = "What a coincidence. My cardigan is missing a button!", --Mismatched Buttons
		TRINKET_10 = "I don't appreciate the insinuation, dear.", --Dentures
		TRINKET_11 = "Ah, it's a scale replica of that mischievous robot.", --Lying Robot
		TRINKET_12 = "A muscular hydrostat that's been sat near something hygroscopic.", --Dessicated Tentacle
		TRINKET_13 = "What a positively, delightfully odd little lady.", --Gnomette
		TRINKET_14 = "I think it's quite lovely, despite the cracks left by age...", --Leaky Teacup
		TRINKET_15 = "In medieval chess, this piece was called the elephant.", --Pawn
		TRINKET_16 = "The groove in this piece symbolizes the bishop's ceremonial headwear.", --Pawn
		TRINKET_17 = "This would be a practical eating utensil if it weren't bent.", --Bent Spork
		TRINKET_18 = "Beware of Greeks bearing gifts.", --Trojan Horse
		TRINKET_19 = "A good illustration of gyroscopic precession.", --Unbalanced Top
		TRINKET_20 = "An instrument of self-sufficiency.", --Backscratcher
		TRINKET_21 = "I have an excellent meringue recipe.", --Egg Beater
		TRINKET_22 = "My grandmother used to knit.", --Frayed Yarn
		TRINKET_23 = "It reminds me of home.", --Shoehorn
		TRINKET_24 = "What a positively adorable kitty cat. Sigh.", --Lucky Cat Jar
		TRINKET_25 = "What an unpleasant scent.", --Air Unfreshener
		TRINKET_26 = "It appears to be a primitive cup fashioned from a tuber.", --Potato Cup
		TRINKET_27 = "I miss the comforts of home.", --Coat Hanger
		TRINKET_28 = "It was once called the \"tower\", long ago.", --Rook
        TRINKET_29 = "Calling it a \"castle\" is plainly incorrect.", --Rook
        TRINKET_30 = "Knights are better pieces when they're active in the center.", --Knight
        TRINKET_31 = "In German it is referred to as the \"springer\".", --Knight
        TRINKET_32 = "Oh, I got my hopes up for a nice crystal ball.", --Cubic Zirconia Ball
        TRINKET_33 = "A decorative arachnid adornment! How darling!", --Spider Ring
        TRINKET_34 = "The paw grants three wishes, with terribly ironic results. So the story goes.", --Monkey Paw
        TRINKET_35 = "Odorless. I believe it may have been sugar water.", --Empty Elixir
        TRINKET_36 = "Dunk those in boiling water before wearing them, dear.", --Faux fangs
        TRINKET_37 = "Luckily it is much too brittle to inflict any real damage.", --Broken Stake
        TRINKET_38 = "This simply does not work right.", -- Binoculars Griftlands trinket
        TRINKET_39 = "It appears to be an abandoned glove.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "What a cute little mollusk shaped scale!", -- Snail Scale Griftlands trinket
        TRINKET_41 = "This does not seem like it came from this world.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Goodness, it seems quite wistful.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Perhaps I ought to save it for Webber.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "A waste of a unique flora specimen.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "What a curious device!", -- Odd Radio ONI trinket
        TRINKET_46 = "What an odd contraption.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_2  = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_7  = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_10 = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_11 = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_14 = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_18 = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_19 = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_42 = "How odd... perhaps it's merely a mirage.",
        LOST_TOY_43 = "How odd... perhaps it's merely a mirage.",

        HALLOWEENCANDY_1 = "Remember to eat in moderation, children.",
        HALLOWEENCANDY_2 = "Delightfully colored kernels of high fructose corn syrup.",
        HALLOWEENCANDY_3 = "Hmm, well, at least there's a healthy option on the table.",
        HALLOWEENCANDY_4 = "I was always a fan of black licorice, myself.",
        HALLOWEENCANDY_5 = "It almost seems a shame to eat them.",
        HALLOWEENCANDY_6 = "I'd prefer none of you eat these at all.",
        HALLOWEENCANDY_7 = "I'll take the ones you don't want, dears.",
        HALLOWEENCANDY_8 = "How darling!",
        HALLOWEENCANDY_9 = "I had best not hear of any tummy aches later.",
        HALLOWEENCANDY_10 = "How darling!",
        HALLOWEENCANDY_11 = "I fear I've a terrible weakness for a spot of chocolate.",
        HALLOWEENCANDY_12 = "The candy itself is quite pleasant, if unappealing in appearance.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "There will be some sore jaws in the morning, I imagine.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "A delightful ten on the Scoville scale.", --Hot Lava pepper candy
        CANDYBAG = "A festive bag for seasonal treats.",

		HALLOWEEN_ORNAMENT_1 = "An ornamental poltergeist meant to be hung somewhere.",
		HALLOWEEN_ORNAMENT_2 = "A flourish of flying mammal.",
		HALLOWEEN_ORNAMENT_3 = "An arborator adornment of the arachnid variety.",
		HALLOWEEN_ORNAMENT_4 = "I really should decorate.",
		HALLOWEEN_ORNAMENT_5 = "An ornament such as this should be hung up.",
		HALLOWEEN_ORNAMENT_6 = "A corvus such as this would do better in a tree.",

		HALLOWEENPOTION_DRINKS_WEAK = "Not as potent as I would have liked.",
		HALLOWEENPOTION_DRINKS_POTENT = "An impressive elixir.",
        HALLOWEENPOTION_BRAVERY = "Bottled valor.",
		HALLOWEENPOTION_MOON = "It seems to catalyze a mutation.",
		HALLOWEENPOTION_FIRE_FX = "It appears combustible.",
		MADSCIENCE_LAB = "Mad science indeed!",
		LIVINGTREE_ROOT = "The root cutting of a beastly tree.",
		LIVINGTREE_SAPLING = "Ah. Its horror has taken root.",

        DRAGONHEADHAT = "This is the head to the dragon costume.",
        DRAGONBODYHAT = "The longer the dragon, the better the luck.",
        DRAGONTAILHAT = "This is the back of the dragon costume.",
        PERDSHRINE =
        {
            GENERIC = "The native Meleagris flock to it.",
            EMPTY = "A bush must be placed to attract the Meleagris.",
            BURNT = "A carbonized structure.",
        },
        REDLANTERN = "What a colorful little lantern.",
        LUCKY_GOLDNUGGET = "Such a curious shape.",
        FIRECRACKERS = "A little too noisy for my liking.",
        PERDFAN = "It's quite lovely.",
        REDPOUCH = "The vibrant red hue is a sign of good luck.",
        WARGSHRINE =
        {
            GENERIC = "Let the festivities begin!",
            EMPTY = "Tribute by fire, hm?",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "A shame.",
        },
        CLAYWARG =
        {
        	GENERIC = "Ah, how charmingly fearsome.",
        	STATUE = "An intricately crafted terra cotta statue.",
        },
        CLAYHOUND =
        {
        	GENERIC = "The earthenware has been magically animated.",
        	STATUE = "Terra cotta earthenware.",
        },
        HOUNDWHISTLE = "It emits a frequency undetectable to the human ear.",
        CHESSPIECE_CLAYHOUND = "A replica of Canis lupis.",
        CHESSPIECE_CLAYWARG = "The sculptor clearly studied the creature closely.",

		PIGSHRINE =
		{
            GENERIC = "A Porcine tribute.",
            EMPTY = "It needs a sacrifice of meat.",
            BURNT = "No use to me like this.",
		},
		PIG_TOKEN = "How did they could achieve such detail using pig hooves?",
		PIG_COIN = "A boon from the Pig King.",
		YOTP_FOOD1 = "A feast fit for a festival!",
		YOTP_FOOD2 = "Not fit for human consumption.",
		YOTP_FOOD3 = "I do enjoy a snack now and then.",

		PIGELITE1 = "He's saturated with markings.", --BLUE
		PIGELITE2 = "Rather hot-tempered.", --RED
		PIGELITE3 = "Has an earthy musk to him.", --WHITE
		PIGELITE4 = "I wonder what those green markings signify.", --GREEN

		PIGELITEFIGHTER1 = "He's saturated with markings.", --BLUE
		PIGELITEFIGHTER2 = "Rather hot-tempered.", --RED
		PIGELITEFIGHTER3 = "Has an earthy musk to him.", --WHITE
		PIGELITEFIGHTER4 = "I wonder what those green markings signify.", --GREEN

		CARRAT_GHOSTRACER = "Fascinating! A new genus, perhaps?",

        YOTC_CARRAT_RACE_START = "This will be a unique opportunity to observe the Daucus carota rattus.",
        YOTC_CARRAT_RACE_CHECKPOINT = "This marker should help keep things on track.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "I'm eager to document the results!",
            BURNT = "Oh dear, that won't do at all.",
            I_WON = "Oh ho! Superb results, if I do say so myself.",
            SOMEONE_ELSE_WON = "\"Note: {winner}'s specimen displays superior racing ability.\"",
        },

		YOTC_CARRAT_RACE_START_ITEM = "I should find a suitable place for this.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "I'd best make sure I have enough to reach the finish line.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "The ending point for this little experiment.",

		YOTC_SEEDPACKET = "I used to be quite an avid gardener.",
		YOTC_SEEDPACKET_RARE = "I wonder what species it will turn out to be.",

		MINIBOATLANTERN = "The balloon seems a bit redundant, doesn't it?",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "It's a tribute to the small plant-animal hybrid.",
            EMPTY = "It requires an offering of some sort.",
            BURNT = "That won't do at all.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "This will put the creature's sense of direction to the test.",
            RAT = "Who's a clever little Daucus carota rattus?",
            BURNT = "I'm afraid it won't be of much use to anyone now.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Speed is no replacement for cleverness, but it helps.",
            RAT = "Oh my, look at it go!",
            BURNT = "I'm afraid it won't be of much use to anyone now.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "This should be a good test of reflexes.",
            RAT = "I do believe its reaction time is improving!",
            BURNT = "I'm afraid it won't be of much use to anyone now.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "The repeated jumping should help build the creature's stamina.",
            RAT = "The little dear is working so hard.",
            BURNT = "I'm afraid it won't be of much use to anyone now.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "An easily constructed directional testing apparatus.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "An easily constructed speed testing device.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "Everything I need to test the stamina of my subject.",
        YOTC_CARRAT_GYM_REACTION_ITEM = "Everything I need to test my subject's alertness.",

        YOTC_CARRAT_SCALE_ITEM = "It measures the racing prowess of herbaceous rodents.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "Fascinating! I never realized skill could be measured by weight.",
            CARRAT = "Hm, it seems that more training might be in order.",
            CARRAT_GOOD = "The specimen seems to have responded well to the training!",
            BURNT = "Oh my, that won't do at all.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Let's get to it then, shall we?",
            EMPTY = "I will require an offering.",
            BURNT = "How unfortunate.",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "These creatures require regular grooming.",
            OCCUPIED = "Let's get you looking a bit more presentable, shall we?",
            BURNT = "What an unfortunate turn of events.",
        },
        BEEFALO_GROOMER_ITEM = "I'd best get it set up.",

		BISHOP_CHARGE_HIT = "Augh!",
		TRUNKVEST_SUMMER = "Durable outerwear.",
		TRUNKVEST_WINTER = "Ample protection against the elements.",
		TRUNK_COOKED = "Unpalatable, but high in protein.",
		TRUNK_SUMMER = "A utilitarian proboscis.",
		TRUNK_WINTER = "A specimen of leather and fur.",
		TUMBLEWEED = "A dried collection of plant matter.",
		TURKEYDINNER = "What a nice roast.",
		TWIGS = "Some small twigs.",
		UMBRELLA = "A simple apparatus for keeping dry.",
		GRASS_UMBRELLA = "A dainty parasol that will provide moderate protection.",
		UNIMPLEMENTED = "It's under construction.",
		WAFFLES = "Salutations, waffles.",
		WALL_HAY =
		{
			GENERIC = "I don't trust that wall.",
			BURNT = "I was right not to trust it.",
		},
		WALL_HAY_ITEM = "Hay bales.",
		WALL_STONE = "That is quite secure.",
		WALL_STONE_ITEM = "I'll carry them. My strong backbone always was my best asset.",
		WALL_RUINS = "A very secure wall.",
		WALL_RUINS_ITEM = "My pockets must be bigger on the inside.",
		WALL_WOOD =
		{
			GENERIC = "That offers some protection.",
			BURNT = "Fire was its weakness.",
		},
		WALL_WOOD_ITEM = "Deployable pickets.",
		WALL_MOONROCK = "A job well done.",
		WALL_MOONROCK_ITEM = "Fits comfortably in my pocket.",
		FENCE = "A simply constructed fence.",
        FENCE_ITEM = "All the components for a wooden fence.",
        FENCE_GATE = "That is a wooden gate.",
        FENCE_GATE_ITEM = "All the components for a wooden gate.",
		WALRUS = "Odobenus rosmarus; Gaelic variety.",
		WALRUSHAT = "Should auld acquaintance be forgot?",
		WALRUS_CAMP =
		{
			EMPTY = "It has been deserted for now.",
			GENERIC = "Some kind of temporary habitation.",
		},
		WALRUS_TUSK = "This would be useful for scrimshaw.",
		WARDROBE =
		{
			GENERIC = "This reminds me of a famous book.",
            BURNING = "Hmm, now it reminds me of a very different famous book.",
			BURNT = "It used to be a wardrobe.",
		},
		WARG = "Domesticating this Canis will be an entertaining challenge.",
        WARGLET = "This Canis needs a lesson in manners.",
        
		WASPHIVE = "I had best keep my distance.",
		WATERBALLOON = "A toy for children.",
		WATERMELON = "Citrullus lanatus.",
		WATERMELON_COOKED = "Beautifully grilled.",
		WATERMELONHAT = "That's certainly one thing you could do with a watermelon.",
		WAXWELLJOURNAL = "I'm not letting THAT in MY library!",
		WETGOOP = "Oh no. No, no, no. This won't do at all.",
        WHIP = "An instrument for developing pain compliance.",
		WINTERHAT = "I ought to teach the children how to pick up a stitch.",
		WINTEROMETER =
		{
			GENERIC = "Measure before you act.",
			BURNT = "I can't read any measurements from that husk.",
		},

        WINTER_TREE =
        {
            BURNT = "Not to worry. We can still celebrate.",
            BURNING = "Oh gracious, not again.",
            CANDECORATE = "Lovely job on the tree, dears.",
            YOUNG = "It'd surely snap under the weight of ornaments.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "Let's grow a proper tree, shall we?",
            BURNT = "Not to worry. We can still celebrate.",
		},
        WINTER_ORNAMENT = "Careful with it now, dear.",
        WINTER_ORNAMENTLIGHT = "Electrical currents do have a certain appeal, don't they?",
        WINTER_ORNAMENTBOSS = "I'm of the opinion that one can never overdecorate.",
		WINTER_ORNAMENTFORGE = "A harrowing handicraft.",
		WINTER_ORNAMENTGORGE = "The needlework on this is quite intricate.",

        WINTER_FOOD1 = "What a delightful little individual.", --gingerbread cookie
        WINTER_FOOD2 = "Just like holidays at the library!", --sugar cookie
        WINTER_FOOD3 = "The perfect stir stick for hot cup of tea.", --candy cane
        WINTER_FOOD4 = "An object with negligible temporal drag.", --fruitcake
        WINTER_FOOD5 = "Such expertly prepared raspberry filling!", --yule log cake
        WINTER_FOOD6 = "\"Plum\" is a 17th century term for \"fruit\", dear.", --plum pudding
        WINTER_FOOD7 = "Pair it with a good book and you've a cure for the winter blues.", --apple cider
        WINTER_FOOD8 = "A small enchantment keeps it a pleasant temperature.", --hot cocoa
        WINTER_FOOD9 = "I've always harbored a weakness for good 'nog.", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "What sort of fuel does it run on?",
			COOKING = "Roasting nicely.",
			ALMOST_DONE_COOKING = "It will be done, momentarily.",
			DISH_READY = "It is complete!",
		},
		BERRYSAUCE = "How festive!",
		BIBINGKA = "Traditionally, bibingka is baked in a specialized clay oven.",
		CABBAGEROLLS = "Variations of this dish can be found across Europe and Asia.",
		FESTIVEFISH = "I'm unfamiliar with the origins of this dish.",
		GRAVY = "Oh my, it's a bit rich for me.",
		LATKES = "Delightfully crispy.",
		LUTEFISK = "The fish is dried and then soaked in lye, hence the odd aroma.",
		MULLEDDRINK = "A taste of Yuletide cheer.",
		PANETTONE = "The origins of this cake trace all the way back to ancient Rome.",
		PAVLOVA = "It takes its name from the Russian ballerina Anna Pavlova.",
		PICKLEDHERRING = "I do enjoy some pickled herring around the holidays.",
		POLISHCOOKIE = "Now it feels like the holidays.",
		PUMPKINPIE = "Perhaps just a nibble...",
		ROASTTURKEY = "I do hope it had enough time in the oven.",
		STUFFING = "Pairs perfectly with some turkey and gravy.",
		SWEETPOTATO = "It's always a hit at holiday get-togethers.",
		TAMALES = "The spice is actually quite mild, quite to my liking.",
		TOURTIERE = "A rather hearty meat pie.",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Big enough for company.",
			HAS_FOOD = "A considerable amount of food!",
			WRONG_TYPE = "Most certainly the wrong type.",
			BURNT = "Oh my, that won't do at all.",
		},

		GINGERBREADWARG = "Canis Festivus.",
		GINGERBREADHOUSE = "Reminds me of a story I know.",
		GINGERBREADPIG = "If it would sit still long enough, I could classify it.",
		CRUMBS = "I believe this came from the walking confectionery.",
		WINTERSFEASTFUEL = "It reminds me of reading holiday stories by the fire.",

        KLAUS = "It uses its powerful olfactory sense to locate prey.",
        KLAUS_SACK = "How curious.",
		KLAUSSACKKEY = "Hmm. Quite a sturdy antler.",
		WORMHOLE =
		{
			GENERIC = "The sleeping Megadrilacea Oraduos.",
			OPEN = "Concentric rings of teeth for rapid ingestion.",
		},
		WORMHOLE_LIMITED = "It will only last a few trips.",
		ACCOMPLISHMENT_SHRINE = "I feel a compulsive urge to activate it, again and again.", --single player
		LIVINGTREE = "This tree is special.",
		ICESTAFF = "Some kind of ice-throwing contraption.",
		REVIVER = "This provides a corporeal anchor for the ectoplasmic configuration.",
		SHADOWHEART = "This... This is no child's magic.",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "An ancient mural of a non-mammalian civilization.",
			LINE_2 = "This mural panel is too eroded to decipher.",
			LINE_3 = "A dark shadow, or perhaps a substance, overtakes the civilization.",
			LINE_4 = "The citizens molt from their exoskeletons in this panel.",
			LINE_5 = "The city appears exponentially more prosperous.",
		},
        ATRIUM_STATUE = "It refuses to comply with this world's laws.",
        ATRIUM_LIGHT =
        {
			ON = "Indeed. It gained power from the key.",
			OFF = "I suspect it is powered by that horrible fuel.",
		},
        ATRIUM_GATE =
        {
			ON = "That's taken care of.",
			OFF = "Now where might that lead?",
			CHARGING = "It is storing power.",
			DESTABILIZING = "We'd best not be around when it goes off.",
			COOLDOWN = "We must be patient.",
        },
        ATRIUM_KEY = "The key to that old gateway.",
		LIFEINJECTOR = "The mold appears to have medicinal properties.",
		SKELETON_PLAYER =
		{
			MALE = "%s's skeleton is a permanent reminder to be mindful around %s.",
			FEMALE = "%s's skeleton is a permanent reminder to be mindful around %s.",
			ROBOT = "%s's skeleton is a permanent reminder to be mindful around %s.",
			DEFAULT = "%s's skeleton is a permanent reminder to be mindful around %s.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "Implications of a lunar body? Interesting.",
		MOONROCKNUGGET = "Implications of a lunar body? Interesting.",
		MOONROCKCRATER = "Would make a useful cartographic instrument with proper embellishments.",
		MOONROCKSEED = "A floating orb of knowledge.",

        REDMOONEYE = "The red lens will mark this position.",
        PURPLEMOONEYE = "A tool to mark our whereabouts.",
        GREENMOONEYE = "That should help us keep our bearings.",
        ORANGEMOONEYE = "The fewer search parties we have to organize, the better.",
        YELLOWMOONEYE = "The geography of this place is less unknown each day.",
        BLUEMOONEYE = "An excellent marker for group coordination.",

        --Arena Event
        LAVAARENA_BOARLORD = "He has a chip on his shoulder, though I couldn't say why.",
        BOARRIOR = "We best not underestimate that one.",
        BOARON = "They appear to be used as fodder.",
        PEGHOOK = "A sentient Scorpiones. How odd.",
        TRAILS = "All brawn and no brain, I'm afraid.",
        TURTILLUS = "Best steer clear of those spikes, dear.",
        SNAPPER = "What a ruffian!",
		RHINODRILL = "Prone to unnecessary displays of masculinity.",
		BEETLETAUR = "That lock must be heavy on its snout.",

        LAVAARENA_PORTAL =
        {
            ON = "Well, this was an unexpected foray.",
            GENERIC = "It is linked to our Gateway, but inactive on this side.",
        },
        LAVAARENA_KEYHOLE = "It requires a key.",
		LAVAARENA_KEYHOLE_FULL = "All ready for activation.",
        LAVAARENA_BATTLESTANDARD = "That banner is invigorating nearby enemies.",
        LAVAARENA_SPAWNER = "It seems to facilitate local teleportation.",

        HEALINGSTAFF = "It is thankless work.",
        FIREBALLSTAFF = "Someone experienced with magic ought to wield this. Like myself!",
        HAMMER_MJOLNIR = "That looks much too strenuous.",
        SPEAR_GUNGNIR = "I fear I'll not be much use with that.",
        BLOWDART_LAVA = "I haven't the lung capacity for such a thing.",
        BLOWDART_LAVA2 = "I'll leave that to the younger folks.",
        LAVAARENA_LUCY = "Quite the unusual axe.",
        WEBBER_SPIDER_MINION = "What an adorable little arachnid!",
        BOOK_FOSSIL = "A tome of accelerated petrification.",
		LAVAARENA_BERNIE = "Fascinating. It is animated, even here.",
		SPEAR_LANCE = "Such an ineffectual shape for a polearm.",
		BOOK_ELEMENTAL = "A powerful tome of summoning.",
		LAVAARENA_ELEMENTAL = "It is bound to our service.",

   		LAVAARENA_ARMORLIGHT = "Light, but not particularly protective.",
		LAVAARENA_ARMORLIGHTSPEED = "The lightweight material grants the wearer better mobility.",
		LAVAARENA_ARMORMEDIUM = "This ought to prevent grievous harm from befalling the wearer.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "I can't say it would be much use to me.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "A weave of magic replenishes the wearer's will.",
		LAVAARENA_ARMORHEAVY = "I'll leave that to one of the younger folks.",
		LAVAARENA_ARMOREXTRAHEAVY = "Best for someone on the receiving end of harsh attacks.",

		LAVAARENA_FEATHERCROWNHAT = "A weak enchantment is present on this wreath.",
        LAVAARENA_HEALINGFLOWERHAT = "This will amplify the effects of incoming healing magic.",
        LAVAARENA_LIGHTDAMAGERHAT = "How brutish.",
        LAVAARENA_STRONGDAMAGERHAT = "I'll leave that to someone a tad more spry.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "This strengthens the wearer's restorative magicks.",
        LAVAARENA_EYECIRCLETHAT = "An enviable magic relic, I must say.",
        LAVAARENA_RECHARGERHAT = "A focal point for magical energies.",
        LAVAARENA_HEALINGGARLANDHAT = "Proximity to the blossoms produces a restorative effect for the user.",
        LAVAARENA_CROWNDAMAGERHAT = "Goodness, I've no desire to wear such a thing.",

		LAVAARENA_ARMOR_HP = "Safety first.",

		LAVAARENA_FIREBOMB = "I prefer my books.",
		LAVAARENA_HEAVYBLADE = "Goodness. I could never lift that!",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "What is this \"Gnaw\", I wonder?",
        	FULL = "That should tide it over while I prepare our next dish.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Decrepit statuary.",
		QUAGMIRE_PARK_FOUNTAIN = "A pity. I always enjoyed a good fountain.",

        QUAGMIRE_HOE = "It can be used to till fertile soil.",

        QUAGMIRE_TURNIP = "Edible root of Brassica rapa.",
        QUAGMIRE_TURNIP_COOKED = "Roast Brassica rapa.",
        QUAGMIRE_TURNIP_SEEDS = "Mutated seed of Brassica rapa.",

        QUAGMIRE_GARLIC = "Allium sativum, a close relative of Allium cepa.",
        QUAGMIRE_GARLIC_COOKED = "Roast Allium sativum.",
        QUAGMIRE_GARLIC_SEEDS = "Mutated seed of Allium sativum.",

        QUAGMIRE_ONION = "Edible bulb of Allium cepa.",
        QUAGMIRE_ONION_COOKED = "Roast Allium cepa.",
        QUAGMIRE_ONION_SEEDS = "Mutated seed of Allium cepa.",

        QUAGMIRE_POTATO = "Solanum tuberosum, a staple in some cultures.",
        QUAGMIRE_POTATO_COOKED = "Roasted Solanum tuberosum.",
        QUAGMIRE_POTATO_SEEDS = "Mutated seed of Solanum tuberosum.",

        QUAGMIRE_TOMATO = "Fruit of Solanum lycopersicum.",
        QUAGMIRE_TOMATO_COOKED = "Roasted Solanum lycopersicum.",
        QUAGMIRE_TOMATO_SEEDS = "Mutated seed of Solanum lycopersicum.",

        QUAGMIRE_FLOUR = "Ground Triticum aestivum grain.",
        QUAGMIRE_WHEAT = "Fresh Triticum aestivum.",
        QUAGMIRE_WHEAT_SEEDS = "Mutated grain of Triticum aestivum.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Mutated seed of Daucus carota.",

        QUAGMIRE_ROTTEN_CROP = "The soil in this realm is fetid.",

		QUAGMIRE_SALMON = "Mmmm! Oncorhynchus nerka!",
		QUAGMIRE_SALMON_COOKED = "Seared oncorhynchus nerka.",
		QUAGMIRE_CRABMEAT = "Raw Paralithodes meat.",
		QUAGMIRE_CRABMEAT_COOKED = "It no longer presents a threat of salmonellosis.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "What unique coloring. I should like to press its leaves in my books!",
			STUMP = "I should at least like to study its rings.",
			TAPPED_EMPTY = "Sap collection is under way.",
			TAPPED_READY = "No sense letting it sit.",
			TAPPED_BUGS = "The insecta are drawn to the glucose.",
			WOUNDED = "Its internal structure has been damaged, but it can still recover.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "I am not familiar with this species of plant.",
			PICKED = "I don't have time to wait for it to grow back.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "It passes the universal edibility test.",
		QUAGMIRE_SPOTSPICE_GROUND = "Processed and ready for cooking.",
		QUAGMIRE_SAPBUCKET = "A simple implement for tapping trees.",
		QUAGMIRE_SAP = "This tree sap has extraordinary glucose content.",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Enough salt has crystallized to harvest.",
			GENERIC = "Salt deposits should form on the rack soon.",
		},

		QUAGMIRE_POND_SALT = "It is a natural spring of sodium-infused water.",
		QUAGMIRE_SALT_RACK_ITEM = "We ought to put it up by the sodium spring.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "This city's former inhabitants had stashed goods within.",
			LOCKED = "Surely there's an accompanying key.",
		},

		QUAGMIRE_KEY = "I shall have to see what this unlocks.",
		QUAGMIRE_KEY_PARK = "I believe this is for the park.",
        QUAGMIRE_PORTAL_KEY = "Quite an elaborate key.",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "A wild cluster of edible mushrooms.",
			PICKED = "I don't think they'll grow back.",
		},
		QUAGMIRE_MUSHROOMS = "I'm not familiar with the species, though it is edible.",
        QUAGMIRE_MEALINGSTONE = "For mechanically powdering our ingredients.",
		QUAGMIRE_PEBBLECRAB = "I should like to study its shell more closely.",


		QUAGMIRE_RUBBLE_CARRIAGE = "The remnants of a once thriving culture.",
        QUAGMIRE_RUBBLE_CLOCK = "Antiquated but not without sophistication.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Interesting. It appears they didn't worship Gnaw.",
        QUAGMIRE_RUBBLE_PUBDOOR = "The door to a public house.",
        QUAGMIRE_RUBBLE_ROOF = "It has collapsed.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "The clockwork has seized as well.",
        QUAGMIRE_RUBBLE_BIKE = "Beyond repair.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "What creatures once lived here?",
            "There's nothing left of the inhabitants.",
            "What caused this city to crumble?",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Something must have knocked it down.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "It's crumbling.",
        QUAGMIRE_MERMHOUSE = "Home of the local piscean bipeds.",
        QUAGMIRE_SWAMPIG_HOUSE = "Tsk! What disrepair.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "This house is no longer livable.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Their society has stark social class roles.",
            SLEEPING = "It has entered the REM stage of sleep.",
        },
        QUAGMIRE_SWAMPIG = "What a magnificent subspecies!",

        QUAGMIRE_PORTAL = "My suspicions were correct. It has more than one destination.",
        QUAGMIRE_SALTROCK = "Clusters of unprocessed sodium chloride.",
        QUAGMIRE_SALT = "Sodium chloride. Also known as table salt.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Completely carbonized.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "I suppose it's ready for the altar.",
            MISMATCH = "Not the proper dish for the great wyrm.",
            MATCH = "The exact thing to placate the great wyrm.",
            MATCH_BUT_SNACK = "It's the correct food, although an insufficient amount.",
        },

        QUAGMIRE_FERN = "This species of fern is edible.",
        QUAGMIRE_FOLIAGE_COOKED = "I believe we could have prepared it better.",
        QUAGMIRE_COIN1 = "Worth a paltry sum to the locals.",
        QUAGMIRE_COIN2 = "A coin of some denomination.",
        QUAGMIRE_COIN3 = "A coin of some value.",
        QUAGMIRE_COIN4 = "It's made of a sort of condensed magic.",
        QUAGMIRE_GOATMILK = "I shan't question its origins.",
        QUAGMIRE_SYRUP = "A sweetener.",
        QUAGMIRE_SAP_SPOILED = "No longer food grade.",
        QUAGMIRE_SEEDPACKET = "An envelope of potential crops.",

        QUAGMIRE_POT = "A larger pot takes longer to boil.",
        QUAGMIRE_POT_SMALL = "Hmmm, what shall we make next?",
        QUAGMIRE_POT_SYRUP = "It needs sap.",
        QUAGMIRE_POT_HANGER = "Traditionally one hangs a pot from it.",
        QUAGMIRE_POT_HANGER_ITEM = "The old fashioned way to cook over a fire.",
        QUAGMIRE_GRILL = "Perhaps some barbeque is in order.",
        QUAGMIRE_GRILL_ITEM = "It needs to be on the ground.",
        QUAGMIRE_GRILL_SMALL = "Smaller than normal, but it'll do.",
        QUAGMIRE_GRILL_SMALL_ITEM = "I need to put it down somewhere to use it.",
        QUAGMIRE_OVEN = "It is best suited to baking sweets.",
        QUAGMIRE_OVEN_ITEM = "All the parts are necessary to construct a fully functional oven.",
        QUAGMIRE_CASSEROLEDISH = "I do love a good casserole.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "Enough for one.",
        QUAGMIRE_PLATE_SILVER = "I did miss proper dishware.",
        QUAGMIRE_BOWL_SILVER = "There are so many uses for a bowl.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Reminds me of my bookmobile days.", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "There are wares within.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Quite an interesting sculpture.",
        QUAGMIRE_PARK_ANGEL2 = "Rather ghoulish monument.",
        QUAGMIRE_PARK_URN = "I wonder who's ashes those are.",
        QUAGMIRE_PARK_OBELISK = "I wish I could read the writing.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "We should have full access now.",
            LOCKED = "It needs a key to open.",
        },
        QUAGMIRE_PARKSPIKE = "Wrought iron, it seems.",
        QUAGMIRE_CRABTRAP = "For trapping sea creatures.",
        QUAGMIRE_TRADER_MERM = "They appear to have been quarantined. How foolish.",
        QUAGMIRE_TRADER_MERM2 = "They appear to have been quarantined. How foolish.",

        QUAGMIRE_GOATMUM = "Perhaps she would be willing to barter.",
        QUAGMIRE_GOATKID = "A sweet bipedal Bovidae adolescent.",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Deceased.",
            GENERIC = "An agreeable member of the Columbidae family.",
            SLEEPING = "It has entered the REM stage of sleep.",
        },
        QUAGMIRE_LAMP_POST = "What is it powered by, I wonder?",

        QUAGMIRE_BEEFALO = "Years past its life expectancy.",
        QUAGMIRE_SLAUGHTERTOOL = "Gruesome.",

        QUAGMIRE_SAPLING = "That's not growing back.",
        QUAGMIRE_BERRYBUSH = "Those berries need time to grow back. Time I don't have.",

        QUAGMIRE_ALTAR_STATUE2 = "A gruesome gargoyle.",
        QUAGMIRE_ALTAR_QUEEN = "Impressive in scope.",
        QUAGMIRE_ALTAR_BOLLARD = "A nice enough bollard.",
        QUAGMIRE_ALTAR_IVY = "Something in the Hedera family.",

        QUAGMIRE_LAMP_SHORT = "It's a nice enough light.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "That Winona is quite resourceful.",
        	OFF = "It requires a power source.",
        	BURNING = "Oh dear, who did this?",
        	BURNT = "I do hope she'll build another.",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "A sensible safety precaution.",
        	OFF = "It requires a power source.",
        	BURNING = "Oh dear, who did this?",
        	BURNT = "I do hope she'll build another.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "An electrical power supply for her lovely inventions.",
        	LOWPOWER = "Hm, her invention is starting to run down.",
        	OFF = "I'll grab the nitre, yes?",
        	BURNING = "Oh dear, who did this?",
        	BURNT = "I do hope she'll build another.",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "It's good to see her keeping an open mind.",
        	LOWPOWER = "The magical focus will wear out soon.",
        	OFF = "It needs a new magic focus.",
        	BURNING = "Oh dear, who did this?",
        	BURNT = "I do hope she'll build another.",
        },

        --Wormwood
        COMPOSTWRAP = "Oh dear. Those are some large droppings.",
        ARMOR_BRAMBLE = "I believe our friend knit it himself.",
        TRAP_BRAMBLE = "Microscopic barbs on the thorns make them quite unpleasant.",

        BOATFRAGMENT03 = "What a pity.",
        BOATFRAGMENT04 = "What a pity.",
        BOATFRAGMENT05 = "What a pity.",
		BOAT_LEAK = "Our ship is taking on water.",
        MAST = "Simply raise a sail, and off we go!",
        SEASTACK = "It would be no good to run aground of that.",
        FISHINGNET = "The sea is a treasure trove of survival resources.", --unimplemented
        ANTCHOVIES = "Ah, I see! A brand new oceanic species!", --unimplemented
        STEERINGWHEEL = "Ship steering is no easy task.",
        ANCHOR = "An anchor for our vessel.",
        BOATPATCH = "For repairing hull damages.",
        DRIFTWOOD_TREE =
        {
            BURNING = "The tree is burning.",
            BURNT = "Carbonized, through and through.",
            CHOPPED = "Little of use remains.",
            GENERIC = "A new material may be of some use to us.",
        },

        DRIFTWOOD_LOG = "A naturally buoyant material.",

        MOON_TREE =
        {
            BURNING = "Tsk. Such a waste of resources.",
            BURNT = "Carbonized, through and through.",
            CHOPPED = "Little of use remains.",
            GENERIC = "It seems to have been altered by ambient lunar energies.",
        },
		MOON_TREE_BLOSSOM = "What a peculiar specimen.",

        MOONBUTTERFLY =
        {
        	GENERIC = "It gets its green hue from the lunar residue in its system.",
        	HELD = "I may have a use for this.",
        },
		MOONBUTTERFLYWINGS = "As I suspected. There are high concentrations of lunar residue.",
        MOONBUTTERFLY_SAPLING = "The moths and the trees have somehow mutated together here.",
        ROCK_AVOCADO_FRUIT = "The outside is mineral, yet the inside is organic.",
        ROCK_AVOCADO_FRUIT_RIPE = "I miss a nice fresh avocado.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "It's perfectly safe for consumption.",
        ROCK_AVOCADO_FRUIT_SPROUT = "It would be better to allow it to grow at this point.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It is past the reproduction phase of its life cycle.",
			WITHERED = "These are not ideal conditions for this species.",
			GENERIC = "Surely that can't be fruit.",
			PICKED = "A bush that grew from the lunar soil.",
			DISEASED = "I fear it has contracted a disease.", --unimplemented
            DISEASING = "Hm, I see browning at the leaves' edges.", --unimplemented
			BURNING = "Tsk. Such a waste of resources.",
		},
        DEAD_SEA_BONES = "What curious skeletal structures.",
        HOTSPRING =
        {
        	GENERIC = "My old feet could use a good soak.",
        	BOMBED = "Yes, I'll definitely soak my feet later.",
        	GLASS = "I strongly suspect moon glass is organic in composition now.",
			EMPTY = "The spring will replenish itself in good time.",
        },
        MOONGLASS = "Perhaps I could keep a sample and study the composition.",
        MOONGLASS_CHARGED = "The energy seems unstable, I'll have to be quick to put it to any use.",
        MOONGLASS_ROCK = "It appears to be mineral, but may actually be organic in nature.",
        BATHBOMB = "Ah, I do love a warm bath with a book.",
        TRAP_STARFISH =
        {
            GENERIC = "I'd be careful of that if I were you.",
            CLOSED = "It hunts similarly to Dionaea muscipula.",
        },
        DUG_TRAP_STARFISH = "It is no longer a danger.",
        SPIDER_MOON =
        {
        	GENERIC = "Those mineral deposits may have irritated it into hostility.",
        	SLEEPING = "How convenient, it's sleeping.",
        	DEAD = "Good riddance.",
        },
        MOONSPIDERDEN = "Those poor hideous creatures are making their den here.",
		FRUITDRAGON =
		{
			GENERIC = "Plant and animal have merged into one in this specimen.",
			RIPE = "It does smell quite delicious.",
			SLEEPING = "It's in a deep sleep.",
		},
        PUFFIN =
        {
            GENERIC = "What a dear Fratercula corniculata!",
            HELD = "There there, now.",
            SLEEPING = "It's in a deep sleep.",
        },

		MOONGLASSAXE = "Always strive for greater efficacy.",
		GLASSCUTTER = "I like to get straight to the point.",

        ICEBERG =
        {
            GENERIC = "We ought to steer the ships clear of that.", --unimplemented
            MELTED = "From dangerous solid to harmless liquid. Thank-you, heat.", --unimplemented
        },
        ICEBERG_MELTED = "From dangerous solid to harmless liquid. Thank-you, heat.", --unimplemented

        MINIFLARE = "It's safer for everyone to stick together.",

		MOON_FISSURE =
		{
			GENERIC = "This is not the same type of magic I've seen from Maxwell's fuel.",
			NOLIGHT = "The moon cycles here are beginning to make a lot more sense.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "It says it'll share a secret with me if I complete it.",
            GENERIC = "The voice says it has knowledge to share.",
        },

        MOON_ALTAR_IDOL = "Its energy is prodding at the edges of my mind.",
        MOON_ALTAR_GLASS = "I believe it is trying to communicate with me telepathically.",
        MOON_ALTAR_SEED = "It is projecting images of an altar into my mind.",

        MOON_ALTAR_ROCK_IDOL = "I think I had best mine it out.",
        MOON_ALTAR_ROCK_GLASS = "I think I had best mine it out.",
        MOON_ALTAR_ROCK_SEED = "I think I had best mine it out.",

        MOON_ALTAR_CROWN = "Come now, let's get you back where you belong.",
        MOON_ALTAR_COSMIC = "It says there's more knowledge yet to be found.",

        MOON_ALTAR_ASTRAL = "Are you ready to share your knowledge with me?",
        MOON_ALTAR_ICON = "It's projecting a sense of urgency into my mind.",
        MOON_ALTAR_WARD = "It's communicating a need to be reconstructed.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "It's good to keep the mind occupied at sea.",
            BURNT = "How irresponsible.",
        },
        BOAT_ITEM = "It will allow us to go on the water.",
        STEERINGWHEEL_ITEM = "A necessity should we want to steer our boat.",
        ANCHOR_ITEM = "It will allow us to create an anchor for our ships.",
        MAST_ITEM = "A tool for harnessing the wind's power.",
        MUTATEDHOUND =
        {
        	DEAD = "What a pity.",
        	GENERIC = "Another moon-induced mutation... Hm.",
        	SLEEPING = "I should like to study it up close.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "That takes care of that.",
			GENERIC = "Something about this place has made the creature go quite wrong.",
			SLEEPING = "I see no reason to wake it.",
		},
        CARRAT =
        {
        	DEAD = "Perhaps that was unnecessary.",
        	GENERIC = "My, another plant and animal hybrid. How odd.",
        	HELD = "The plant and animal matter has fused in total harmony.",
        	SLEEPING = "It's in a deep sleep.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Nereocystis luetkeana.",
            PICKED = "Nereocystis luetkeana needs time to regrow.",
        },
		BULLKELP_ROOT = "I suppose this is why it's referred to as \"bullwhip\" kelp.",
        KELPHAT = "It understandably has an effect on one's emotional wellbeing.",
		KELP = "It is an edible kelp species.",
		KELP_COOKED = "That certainly didn't improve the texture.",
		KELP_DRIED = "It's slightly more palatable with this texture.",

		GESTALT = "They are the projections of something stronger.",
        GESTALT_GUARD = "They possess higher defensive capabilities than their smaller counterparts.",

		COOKIECUTTER = "Its eyes seem fixed to my raft.",
		COOKIECUTTERSHELL = "A thick casing of calcium carbonate.",
		COOKIECUTTERHAT = "Hm, it has a very disagreeable odor.",
		SALTSTACK =
		{
			GENERIC = "Intriguing... just how were those figures constructed?",
			MINED_OUT = "The salt has already been harvested.",
			GROWING = "Oh my... they seem to form that way naturally.",
		},
		SALTROCK = "It's growing in a curiously geometric formation.",
		SALTBOX = "This should help prevent food spoilage.",

		TACKLESTATION = "I can improve my chances of success with better fishing implements.",
		TACKLESKETCH = "Interesting! These would improve my fishing significantly!",

        MALBATROSS = "It appears to be of the family Diomedeidae.",
        MALBATROSS_FEATHER = "Its plumage has an almost scale-like texture.",
        MALBATROSS_BEAK = "These beaks are designed to catch slippery prey.",
        MAST_MALBATROSS_ITEM = "Raise the sail, and let's be off!",
        MAST_MALBATROSS = "What an impressive wingspan.",
		MALBATROSS_FEATHERED_WEAVE = "A sturdy, lightweight material.",

        GNARWAIL =
        {
            GENERIC = "It appears to be a variation of the Monodon monoceros.",
            BROKENHORN = "Serves you right.",
            FOLLOWER = "His manners have improved considerably.",
            BROKENHORN_FOLLOWER = "I'm sure it will grow back in time, dear.",
        },
        GNARWAIL_HORN = "A gnarwail's \"horn\" is actually a tooth, you know.",

        WALKINGPLANK = "A dangerous escape route for one stranded at sea.",
        OAR = "One and two, and one and two!",
		OAR_DRIFTWOOD = "A much more efficient, lighter design.",

		OCEANFISHINGROD = "A sturdy rod for ocean fishing.",
		OCEANFISHINGBOBBER_NONE = "A float might improve the rod's accuracy.",
        OCEANFISHINGBOBBER_BALL = "The use of a fishing float was first documented in 1496.",
        OCEANFISHINGBOBBER_OVAL = "The use of a fishing float was first documented in 1496.",
		OCEANFISHINGBOBBER_CROW = "The use of a fishing float was first documented in 1496.",
		OCEANFISHINGBOBBER_ROBIN = "The use of a fishing float was first documented in 1496.",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "The use of a fishing float was first documented in 1496.",
		OCEANFISHINGBOBBER_CANARY = "The use of a fishing float was first documented in 1496.",
		OCEANFISHINGBOBBER_GOOSE = "The large plumage adds a little something special.",
		OCEANFISHINGBOBBER_MALBATROSS = "The large plumage adds a little something special.",

		OCEANFISHINGLURE_SPINNER_RED = "Its effect appears to be stronger during the day.",
		OCEANFISHINGLURE_SPINNER_GREEN = "Its effect appears to be stronger at dusk.",
		OCEANFISHINGLURE_SPINNER_BLUE = "Its effect appears to be stronger at night.",
		OCEANFISHINGLURE_SPOON_RED = "Its effect appears to be stronger during the day.",
		OCEANFISHINGLURE_SPOON_GREEN = "Its effect appears to be stronger at dusk.",
		OCEANFISHINGLURE_SPOON_BLUE = "Its effect appears to be stronger at night.",
		OCEANFISHINGLURE_HERMIT_RAIN = "It seems to work in conjunction with precipitation.",
		OCEANFISHINGLURE_HERMIT_SNOW = "It would be best utilized in snowy weather.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Fascinating! The spines secrete a potent neurotoxin.",
		OCEANFISHINGLURE_HERMIT_HEAVY = "This will ensure that I catch a larger specimen.",

		OCEANFISH_SMALL_1 = "A rather dimimutive specimen.",
		OCEANFISH_SMALL_2 = "A smaller species of saltwater fish.",
		OCEANFISH_SMALL_3 = "One of the smaller varieties.",
		OCEANFISH_SMALL_4 = "I believe they only grow to about this size.",
		OCEANFISH_SMALL_5 = "I don't think I'm familiar with this genus...",
		OCEANFISH_SMALL_6 = "Curious, it seems to be camouflaged for the wrong environment.",
		OCEANFISH_SMALL_7 = "Oh my, you'd look right at home in my old garden.",
		OCEANFISH_SMALL_8 = "Careful not to look directly at it, dears.",
        OCEANFISH_SMALL_9 = "It's not unlike the Toxotes jaculator, though the coloring is unusual.",

		OCEANFISH_MEDIUM_1 = "Oh my... is it supposed to look like that?",
		OCEANFISH_MEDIUM_2 = "This species usually prefers deeper waters.",
		OCEANFISH_MEDIUM_3 = "Oh dear, I believe these are actually an invasive species.",
		OCEANFISH_MEDIUM_4 = "I've never been superstitious about black cats, never mind a catfish!",
		OCEANFISH_MEDIUM_5 = "A fascinating blend of animal and vegetable.",
		OCEANFISH_MEDIUM_6 = "It appears to be a subspecies of Cyprinus carpio.",
		OCEANFISH_MEDIUM_7 = "It appears to be a subspecies of Cyprinus carpio.",
		OCEANFISH_MEDIUM_8 = "All fish are cold-blooded of course, but this is exceptional.",
        OCEANFISH_MEDIUM_9 = "I surmise that its coloring is a result of its fig-based diet.",

		PONDFISH = "Some kind of whitefish, I believe.",
		PONDEEL = "It's an eel.",

        FISHMEAT = "An odorous slab of fish meat.",
        FISHMEAT_COOKED = "Beautifully grilled.",
        FISHMEAT_SMALL = "Fish flesh.",
        FISHMEAT_SMALL_COOKED = "A small bit of nourishment.",
		SPOILED_FISH = "That fish matter is becoming a biohazard.",

		FISH_BOX = "A clever contraption to keep seafood fresh.",
        POCKET_SCALE = "I'm always prepared to weigh in.",

		TACKLECONTAINER = "Organized belongings are key to an organized mind.",
		SUPERTACKLECONTAINER = "A place for everything, and everything in its place.",

		TROPHYSCALE_FISH =
		{
			GENERIC = "A place to display only the largest aquatic specimens.",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nQuite the accomplishment!",
			BURNING = "My, I don't think it's supposed to do that.",
			BURNT = "Oh dear...",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nOh ho! I seem to be the victor!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nFishing is really quite easy, isn't it?",
		},

		OCEANFISHABLEFLOTSAM = "Oh my, what a mess!",

		CALIFORNIAROLL = "Delicious makizushi.",
		SEAFOODGUMBO = "I can feel the heartburn already!",
		SURFNTURF = "The perfect dish.",

        WOBSTER_SHELLER = "A most interesting invertebrate.",
        WOBSTER_DEN = "Home to the arthropod.",
        WOBSTER_SHELLER_DEAD = "I might as well eat it now.",
        WOBSTER_SHELLER_DEAD_COOKED = "Dinner is served!",

        LOBSTERBISQUE = "I'd almost forgotten what real food tasted like.",
        LOBSTERDINNER = "How decadent.",

        WOBSTER_MOONGLASS = "This arthropod seems to have evolved to suit its environment.",
        MOONGLASS_WOBSTER_DEN = "It appears to be a den of some sort.",

		TRIDENT = "It produces quite literal sound waves!",

		WINCH =
		{
			GENERIC = "Mankind has used winches for many hundreds of years.",
			RETRIEVING_ITEM = "Practice and precision make perfect!",
			HOLDING_ITEM = "I've caught something!",
		},

        HERMITHOUSE = {
            GENERIC = "Tsk. Look at the state of it...",
            BUILTUP = "Improving your living space can do wonders for one's mood.",
        },

        SHELL_CLUSTER = "A fascinating assortment of mollusks!",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "SHHH!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Shhh!",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Shhh!",
        },

        CHUM = "I find it best not to dwell on what it's made of.",

        SUNKENCHEST =
        {
            GENERIC = "A mollusk of exceptional size and functionality.",
            LOCKED = "Oh dear. I believe this will require a key.",
        },

        HERMIT_BUNDLE = "How very welcome!",
        HERMIT_BUNDLE_SHELLS = "How very welcome!",

        RESKIN_TOOL = "We're well past due for a spring cleaning around here.",
        MOON_FISSURE_PLUGGED = "Goodness, that must have required some tenacity!",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "There must be a mutagen in monster meat that triggers her growth.",
            "There must be a mutagen in monster meat that triggers her growth.",
        },
        WOBYSMALL =
        {
            "I was always more of a cat person, but she is very sweet.",
            "I was always more of a cat person, but she is very sweet.",
        },
		WALTERHAT = "I suppose one must try to stay young at heart.",
		SLINGSHOT = "Do be careful with that, dear.",
		SLINGSHOTAMMO_ROCK = "Remember to clean up after yourself, dear.",
		SLINGSHOTAMMO_MARBLE = "Remember to clean up after yourself, dear.",
		SLINGSHOTAMMO_THULECITE = "Remember to clean up after yourself, dear.",
        SLINGSHOTAMMO_GOLD = "Remember to clean up after yourself, dear.",
        SLINGSHOTAMMO_SLOW = "Remember to clean up after yourself, dear.",
        SLINGSHOTAMMO_FREEZE = "Remember to clean up after yourself, dear.",
		SLINGSHOTAMMO_POOP = "Oh dear...",
        PORTABLETENT = "It's a lovely tent, but I'm afraid I don't have much use for it.",
        PORTABLETENT_ITEM = "How very practical.",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Musical notation, if I'm not mistaken.",
        BATTLESONG_HEALTHGAIN = "Musical notation, if I'm not mistaken.",
        BATTLESONG_SANITYGAIN = "Musical notation, if I'm not mistaken.",
        BATTLESONG_SANITYAURA = "Musical notation, if I'm not mistaken.",
        BATTLESONG_FIRERESISTANCE = "Musical notation, if I'm not mistaken.",
        BATTLESONG_INSTANT_TAUNT = "Oh my, those are some rather colorful turns of phrase.",
        BATTLESONG_INSTANT_PANIC = "Ah, how I love the classics!",

        -- Webber
        MUTATOR_WARRIOR = "How interesting! It appears to alter an arachnid's form when ingested.",
        MUTATOR_DROPPER = "They're lovely, dear.",
        MUTATOR_HIDER = "How interesting! It appears to alter an arachnid's form when ingested.",
        MUTATOR_SPITTER = "They're lovely, dear.",
        MUTATOR_MOON = "How interesting! It appears to alter an arachnid's form when ingested.",
        MUTATOR_HEALER = "They're lovely, dear.",
        SPIDER_WHISTLE = "Arachnids seem to find the sound quite agreeable.",
        SPIDERDEN_BEDAZZLER = "Be sure to tidy up when you're finished, young arachnid.",
        SPIDER_HEALER = "This arachnid has evolved the ability to heal others around it.",
        SPIDER_REPELLENT = "Unfortunately, it seems that the arachnids only respond to one of their kind.",
        SPIDER_HEALER_ITEM = "This balm appears specially formulated to heal arachnids.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "Color-coded and clearly labeled. Well done!",
		GHOSTLYELIXIR_FASTREGEN = "Color-coded and clearly labeled. Well done!",
		GHOSTLYELIXIR_SHIELD = "Color-coded and clearly labeled. Well done!",
		GHOSTLYELIXIR_ATTACK = "Color-coded and clearly labeled. Well done!",
		GHOSTLYELIXIR_SPEED = "Color-coded and clearly labeled. Well done!",
		GHOSTLYELIXIR_RETALIATION = "Color-coded and clearly labeled. Well done!",
		SISTURN =
		{
			GENERIC = "The poor dear.",
			SOME_FLOWERS = "I believe flowers are a traditional offering to the deceased.",
			LOTS_OF_FLOWERS = "The flowers seem to give off an aromatic effect.",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "It will be nice to eat some properly prepared food.",
            DONE = "Smells nourishing.",

			COOKING_LONG = "Patience is a virtue!",
			COOKING_SHORT = "This will be finished in no time at all.",
			EMPTY = "Hm, perhaps I'll whip something up.",
        },

        PORTABLEBLENDER_ITEM = "Quite a lively cooking instrument.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "It'll need some elbow grease.",
            DONE = "The flavoring is ready for use.",
        },
        SPICEPACK = "This should keep my provisions from spoiling!",
        SPICE_GARLIC = "My goodness that smell is pungent!",
        SPICE_SUGAR = "A treacle of fruits.",
        SPICE_CHILI = "I'm not a fan of spicy food.",
        SPICE_SALT = "Just a pinch will do.",
        MONSTERTARTARE = "Monster meat, dressed up fancy.",
        FRESHFRUITCREPES = "Sticky fingers will ensue.",
        FROGFISHBOWL = "I'll happily volunteer to taste-test.",
        POTATOTORNADO = "How creative!",
        DRAGONCHILISALAD = "I do like fresh greens.",
        GLOWBERRYMOUSSE = "A brand new recipe I see. Marvelous!",
        VOLTGOATJELLY = "His ingenuity with limited materials is very impressive.",
        NIGHTMAREPIE = "It tastes a bit like magic.",
        BONESOUP = "Extremely savory. I wouldn't mind seconds.",
        MASHEDPOTATOES = "I wouldn't mind a bite or two, myself.",
        POTATOSOUFFLE = "It looks lovely, dear.",
        MOQUECA = "He's so very talented.",
        GAZPACHO = "Ah! A classic Spanish cuisine.",
        ASPARAGUSSOUP = "Smelly, but quite nutritious.",
        VEGSTINGER = "It's quite piquant.",
        BANANAPOP = "Well, isn't that refreshing?",
        CEVICHE = "Could use a little more sauce.",
        SALSA = "My goodness, that has some zest to it!",
        PEPPERPOPPER = "Just a tad spicy for me!",

        TURNIP = "Edible root of Brassica rapa.",
        TURNIP_COOKED = "Roast Brassica rapa.",
        TURNIP_SEEDS = "It can't begin growing until it's been planted, dear.",

        GARLIC = "Allium sativum, a close relative of Allium cepa.",
        GARLIC_COOKED = "Roast Allium sativum.",
        GARLIC_SEEDS = "It can't begin growing until it's been planted, dear.",

        ONION = "Edible bulb of Allium cepa.",
        ONION_COOKED = "Roast Allium cepa.",
        ONION_SEEDS = "It can't begin growing until it's been planted, dear.",

        POTATO = "Solanum tuberosum, a staple in some cultures.",
        POTATO_COOKED = "Roasted Solanum tuberosum.",
        POTATO_SEEDS = "It can't begin growing until it's been planted, dear.",

        TOMATO = "Fruit of Solanum lycopersicum.",
        TOMATO_COOKED = "Roasted Solanum lycopersicum.",
        TOMATO_SEEDS = "It can't begin growing until it's been planted, dear.",

        ASPARAGUS = "A great source of dietary fiber.",
        ASPARAGUS_COOKED = "It releases sulfur compounds when it's digested.",
        ASPARAGUS_SEEDS = "It can't begin growing until it's been planted, dear.",

        PEPPER = "Of the genus Capsicum, if I'm not mistaken.",
        PEPPER_COOKED = "I must be careful not to rub my eyes.",
        PEPPER_SEEDS = "It can't begin growing until it's been planted, dear.",

        WEREITEM_BEAVER = "It appears to induce a Castorthropic state.",
        WEREITEM_GOOSE = "An... artistic representation of the Branta canadensis.",
        WEREITEM_MOOSE = "Someone's going to trip on this, dear.",

        MERMHAT = "I'm not eager to test out its effectiveness.",
        MERMTHRONE =
        {
            GENERIC = "The \"if it fits, it sits\" method of choosing a monarch. I'm familiar.",
            BURNT = "Oh my... I suppose they'll have to start all over.",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "Careful not to get a splinter, dear.",
            BURNT = "Oh, oh dear...",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "It's good to see her doing something constructive.",
            BURNT = "Oh dear...",
        },

        MERMWATCHTOWER_REGULAR = "They seem to have found themselves a leader.",
        MERMWATCHTOWER_NOKING = "A crude, but effective fortification.",
        MERMKING = "He seems to be the one in charge here.",
        MERMGUARD = "A royal bodyguard.",
        MERM_PRINCE = "The heir, apparently.",

        SQUID = "Luminesca Cephalopoda! What beautiful bioluminescence!",

		GHOSTFLOWER = "I'm afraid I'm unfamiliar with this genus.",
        SMALLGHOST = "Your adorable appearance won't make me believe in you!",

        CRABKING =
        {
            GENERIC = "I wonder if its size is natural or caused by lunar mutations?",
            INERT = "Those impressions appear to have been made to house gems.",
        },
		CRABKING_CLAW = "Thank goodness I'm not allergic to shellfish.",

		MESSAGEBOTTLE = "Not the most effective postal service.",
		MESSAGEBOTTLEEMPTY = "This type of jar is most commonly used for canning.",

        MEATRACK_HERMIT =
        {
            DONE = "The process has completed.",
            DRYING = "Dehydration is a slow process.",
            DRYINGINRAIN = "The rain has temporarily halted the dehydration process.",
            GENERIC = "It seems our chitinous friend could use some assistance.",
            BURNT = "It doesn't seem stable.",
            DONE_NOTMEAT = "The process has completed.",
            DRYING_NOTMEAT = "Dehydration is a slow process.",
            DRYINGINRAIN_NOTMEAT = "The rain has temporarily halted the dehydration process.",
        },
        BEEBOX_HERMIT =
        {
            READY = "Honey can be harvested from it.",
            FULLHONEY = "Honey can be harvested from it.",
            GENERIC = "It appears to be a crudely fashioned apiary.",
            NOHONEY = "It's devoid of honey.",
            SOMEHONEY = "It's not ready for harvesting.",
            BURNT = "Poor bees!",
        },

        HERMITCRAB = "My, she is a bit rude, isn't she?",

        HERMIT_PEARL = "Oh dear, I do hope I can find him.",
        HERMIT_CRACKED_PEARL = "I should tell her.",

        -- DSEAS
        WATERPLANT = "I'm unfamiliar with this variety of sea vegetation.",
        WATERPLANT_BOMB = "We'd best avoid those.",
        WATERPLANT_BABY = "This one must be a juvenile.",
        WATERPLANT_PLANTER = "Perhaps I'll get back into gardening.",

        SHARK = "Fascinating! The entire jaw seems to be comprised of living stone!",

        MASTUPGRADE_LAMP_ITEM = "I'm always in need of a good reading light.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "A very sensible safety measure.",

        WATERPUMP = "It's just common sense.",

        BARNACLE = "People in ancient times believed geese grew from barnacles. Can you imagine?",
        BARNACLE_COOKED = "As I suspected, it tastes nothing like goose.",

        BARNACLEPITA = "A rather interesting combination.",
        BARNACLESUSHI = "I think I'm developing a taste for it.",
        BARNACLINGUINE = "Oh my, it's very rich.",
        BARNACLESTUFFEDFISHHEAD = "I don't think I can stomach it.",

        LEAFLOAF = "Such an unusual flavor!",
        LEAFYMEATBURGER = "At least I shouldn't have to worry about it being undercooked.",
        LEAFYMEATSOUFFLE = "It seems to be made from a plant-based gelatin of sorts.",
        MEATYSALAD = "It contains quite a bit of protein for a salad.",

        -- GROTTO

		MOLEBAT = "I suspect the impressive snout must compensate for its poor eyesight.",
        MOLEBATHILL = "The burrow appears to be mainly comprised of phlegm and mud.",

        BATNOSE = "Evolution truly is remarkable.",
        BATNOSE_COOKED = "It's moderately better.",
        BATNOSEHAT = "How... innovative.",

        MUSHGNOME = "Should I classify you under Animalia or Fungi?",

        SPORE_MOON = "An odd, yet effective defense mechanism.",

        MOON_CAP = "It seems to possess strong sleep inducing properties.",
        MOON_CAP_COOKED = "How odd. Once cooked, they seem to act as a stimulant.",

        MUSHTREE_MOON = "I suspect some property in the water caused it to change.",

        LIGHTFLIER = "If it could be convinced to stay still, it would make an excellent reading light.",

        GROTTO_POOL_BIG = "How interesting, it seems to be forming moon glass stalagmites.",
        GROTTO_POOL_SMALL = "How interesting, it seems to be forming moon glass stalagmites.",

        DUSTMOTH = "I would have been quite pleased to have one helping me in the library.",

        DUSTMOTHDEN = "It seems a chemical reaction within the bodies of these creatures creates Thulecite.",

        ARCHIVE_LOCKBOX = "It seems to require an outside power source to activate.",
        ARCHIVE_CENTIPEDE = "An impressive piece of ancient engineering.",
        ARCHIVE_CENTIPEDE_HUSK = "These parts appear to be inoperative.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "It's got a bit to go before it's ready.",
            COOKING_SHORT = "Almost done!",
            DONE = "Supper time!",
            EMPTY = "I suspect it must have had a purpose specific to these chambers.",
            BURNT = "Now it's truly derelict.",
        },

        ARCHIVE_MOON_STATUE = "These chambers appear to pre-date the rest of the ruins.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "Fascinating! These glyphs seem to be the base that their language evolved from.",
            LINE_2 = "The introduction of shadow fuel must have had a tremendous impact on their culture.",
            LINE_3 = "These glyphs must pre-date their discovery of the shadow fuel.",
            LINE_4 = "This glyph in particular keeps repeating... if only I could decipher its meaning.",
            LINE_5 = "This will need further study.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "The path to discovery awaits.",
            IDLE = "It appears there are no more artifacts to find.",
        },

        ARCHIVE_RESONATOR_ITEM = "How exciting! This technology most likely hasn't been used in hundreds of years!",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "It appears to lack an energy source.",
          GENERIC =  "Somehow, the ancients devised a way to store knowledge in liquid form.",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "I wonder what its intended purpose was.",
            GENERIC = "It appears to be a remarkably advanced security system.",
        },

        ARCHIVE_SECURITY_PULSE = "It seems unwise to follow it.",

        ARCHIVE_SWITCH = {
            VALID = "The pedestals seem to draw power from these gems.",
            GEMS = "It appears to require a specific gem to activate.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "The design is reminiscent of the Gateways we've traversed through before.",
            GENERIC = "A shame, it appears to no longer be operational.",
        },

        WALL_STONE_2 = "That is quite secure.",
        WALL_RUINS_2 = "A very secure wall.",

        REFINED_DUST = "Better here than on my bookshelves.",
        DUSTMERINGUE = "Perhaps there's a creature around here that could metabolize this.",

        SHROOMCAKE = "I don't believe that qualifies as a \"cake\" dear.",

        NIGHTMAREGROWTH = "These crystalline structures do not appear to be natural.",

        TURFCRAFTINGSTATION = "I surmise this was a crucial part of ancient farming methods.",

        MOON_ALTAR_LINK = "I'm afraid its purpose eludes me, for now.",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Composting is an essential component to gardening.",
            WET = "The moisture level of this mixture is too high.",
            DRY = "It requires a bit more moisture.",
            BALANCED = "A well balanced mix.",
            BURNT = "Well... I suppose plants need carbon too.",
        },
        COMPOST = "The secret to any garden's success is nutrient-rich soil.",
        SOIL_AMENDER =
		{
			GENERIC = "Kelp makes for an excellent fertilizer if prepared correctly.",
			STALE = "It should sit for a while longer yet, to reach full potency.",
			SPOILED = "Quite acceptable, though it would be even better if I left it for just a bit longer.",
		},

		SOIL_AMENDER_FERMENTED = "Oh, the garden will enjoy this immensely!",

        WATERINGCAN =
        {
            GENERIC = "A standard watering can.",
            EMPTY = "Perhaps there's a freshwater source nearby.",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "A bit unconventional, but an effective irrigation tool nevertheless.",
            EMPTY = "I'll have to fill it with water before it's usable.",
        },

		FARM_PLOW = "How very efficient!",
		FARM_PLOW_ITEM = "I'd best find a suitable spot for my garden.",
		FARM_HOE = "Humans have cultivated crops since Neolithic times.",
		GOLDEN_FARM_HOE = "The most malleable of metals, but let's see how it does in the garden.",
		NUTRIENTSGOGGLESHAT = "The prudent gardener ensures they are able to discern every detail about their crops.",
		PLANTREGISTRYHAT = "It seems to be a wearable directory of sorts, detailing various plant strains.",

        FARM_SOIL_DEBRIS = "Oh no you don't! Out of my garden!",

		FIRENETTLES = "Dastardly things.",
		FORGETMELOTS = "This strain can be used to brew a rather pleasant herbal tea.",
		SWEETTEA = "It's as if all my worries and cares are fading away.",
		TILLWEED = "What a nuisance!",
		TILLWEEDSALVE = "The Tillweed's roots appear to have limited healing capabilities.",
        WEED_IVY = "Another garden pest.",
        IVY_SNARE = "This plant is quite territorial.",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "I suppose I must put my gardening prowess to the test!",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nA very respectable harvest.",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nMy, quite the accomplishment!",
            HAS_ITEM_LIGHT = "I'm afraid the weight of this bit of produce is too small to tabulate.",
			BURNING = "Oh dear...",
			BURNT = "I'm afraid that's that.",
        },

        CARROT_OVERSIZED = "The result of proper research, planning and care.",
        CORN_OVERSIZED = "Quite an impressive harvest.",
        PUMPKIN_OVERSIZED = "A wonderfully plump squash.",
        EGGPLANT_OVERSIZED = "A particularly resplendent Solanum melongena.",
        DURIAN_OVERSIZED = "Oh, our diminutive green friend will be thrilled!",
        POMEGRANATE_OVERSIZED = "A rather large Punica granatum specimen.",
        DRAGONFRUIT_OVERSIZED = "The result of proper research, planning and care.",
        WATERMELON_OVERSIZED = "The result of proper research, planning and care.",
        TOMATO_OVERSIZED = "I always was quite good at growing tomatoes.",
        POTATO_OVERSIZED = "A rather impressive tuber!",
        ASPARAGUS_OVERSIZED = "It's quite the source of fiber!",
        ONION_OVERSIZED = "A rather large Allium cepa specimen.",
        GARLIC_OVERSIZED = "How fascinating, it seems to have grown into a braided configuration all on its own!",
        PEPPER_OVERSIZED = "The result of proper research, planning and care.",

        VEGGIE_OVERSIZED_ROTTEN = "How terrible to see it all go to waste!",

		FARM_PLANT =
		{
			GENERIC = "Of the kingdom Plantae.",
			SEED = "It takes patience to grow crops from seed.",
			GROWING = "It's coming along.",
			FULL = "I daresay that's ready to harvest.",
			ROTTEN = "I detest the sight of spoiled food!",
			FULL_OVERSIZED = "How splendid!",
			ROTTEN_OVERSIZED = "How terrible to see it all go to waste!",
			FULL_WEED = "Weeds have no place in the garden.",

			BURNING = "What an unfortunate turn of events!",
		},

        FRUITFLY = "Those pests are making quite the nuisance of themselves.",
        LORDFRUITFLY = "I have no patience for garden pests!",
        FRIENDLYFRUITFLY = "This one appears to be of a different, more agreeable subspecies.",
        FRUITFLYFRUIT = "It seems that I can exert some level of control over these insects with this.",

        SEEDPOUCH = "For the practical storage and transport of seeds.",

		-- Crow Carnival
		CARNIVAL_HOST = "He's a rather curious character.",
		CARNIVAL_CROWKID = "Corvids are remarkably intelligent, I'd imagine this species is even more so.",
		CARNIVAL_GAMETOKEN = "A form of avian currency, perhaps?",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "I should be able to exchange these for a prize of some sort.",
			GENERIC_SMALLSTACK = "I assume the more tickets I collect, the greater the prize will be.",
			GENERIC_LARGESTACK = "I seem to be quite good at these games!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "Part of the mechanism for the game, I'd imagine.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "I believe it requires a form of currency to start.",
			PLAYING = "The game appears to require quick reflexes.",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "It appears simple enough to construct.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Colorful paper representations of Annelida.",

		CARNIVALGAME_MEMORY_KIT = "It appears simple enough to construct.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "I believe it requires a form of currency to start.",
			PLAYING = "Ah! A simple test of one's aptitude for memorization.",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "Part of the mechanism for the game, I'd imagine.",
			PLAYING = "I believe it was this one here.",
		},

		CARNIVALGAME_HERDING_KIT = "It appears simple enough to construct.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "I believe it requires a form of currency to start.",
			PLAYING = "This looks like a good bit of exercise.",
		},
		CARNIVALGAME_HERDING_CHICK = "Go on now, scoot!",

		CARNIVAL_PRIZEBOOTH_KIT = "It appears simple enough to construct.",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "There is a surprisingly varied selection to choose from.",
		},

		CARNIVALCANNON_KIT = "Let's just put it somewhere far away from the encampment.",
		CARNIVALCANNON =
		{
			GENERIC = "Thankfully idle, for now.",
			COOLDOWN = "Oh, these sorts of things always make such a mess...",
		},

		CARNIVAL_PLAZA_KIT = "What an intriguing specimen... I can't quite pinpoint the subspecies.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "It seems customary to place decorations around it.",
			LEVEL_2 = "Oh yes, that's coming along quite nicely!",
			LEVEL_3 = "That appears to be an acceptable level of decoration.",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "I should be able to assemble it easily enough.",
		CARNIVALDECOR_EGGRIDE = "Those corvids are quite capable craftspeople.",

		CARNIVALDECOR_LAMP_KIT = "I should be able to assemble it easily enough.",
		CARNIVALDECOR_LAMP = "It has a most curious light source.",
		CARNIVALDECOR_PLANT_KIT = "I wouldn't mind a bit of gardening.",
		CARNIVALDECOR_PLANT = "It's so soothing to care for a small tree.",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "I believe this is among the rarest of the whole collection.",
			UNCOMMON = "It appears to be of a slightly upgraded rarity.",
			GENERIC = "It would look lovely in a little curio cabinet, don't you think?",
		},
		CARNIVALDECOR_FIGURE_KIT = "How intriguing! I wonder what's inside?",

        CARNIVAL_BALL = "I don't want to see anyone playing with this near any breakables.", --unimplemented
		CARNIVAL_SEEDPACKET = "A bit of extra fiber added to one's diet never hurts.",
		CARNIVALFOOD_CORNTEA = "An acquired taste, but nevertheless quite refreshing.",

        CARNIVAL_VEST_A = "The corvids seem to have developed a method of fabricating clothing from leaves.",
        CARNIVAL_VEST_B = "How fascinating that these corvids have evolved to the point of wearing clothing.",
        CARNIVAL_VEST_C = "It smells deligthfully of summer leaves.",

        -- YOTB
        YOTB_SEWINGMACHINE = "I tend to prefer crochet.",
        YOTB_SEWINGMACHINE_ITEM = "Well, I'd better get that set up.",
        YOTB_STAGE = "How intriguing!",
        YOTB_POST =  "This is where the beefalo are to be displayed for judging.",
        YOTB_STAGE_ITEM = "I suppose it's not going to construct itself.",
        YOTB_POST_ITEM =  "It should be simple enough to erect.",


        YOTB_PATTERN_FRAGMENT_1 = "Merely a single piece of a larger costuming pattern.",
        YOTB_PATTERN_FRAGMENT_2 = "Merely a single piece of a larger costuming pattern.",
        YOTB_PATTERN_FRAGMENT_3 = "Merely a single piece of a larger costuming pattern.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "How very charming!",
            YOTB = "The judge might be able to give me some insight regarding its sense of style.",
        },

        WAR_BLUEPRINT = "It's rather aggressive looking.",
        DOLL_BLUEPRINT = "A bit childish for my tastes.",
        FESTIVE_BLUEPRINT = "It features quite an eclectic combination of colors.",
        ROBOT_BLUEPRINT = "I'm not certain just how much sewing is actually involved.",
        NATURE_BLUEPRINT = "How delightful!",
        FORMAL_BLUEPRINT = "It seems rather senseless to attempt to make a beefalo appear dignified.",
        VICTORIAN_BLUEPRINT = "Ah, this style does take me back...",
        ICE_BLUEPRINT = "It's always prudent to have a set of winter garments.",
        BEAST_BLUEPRINT = "I'm not one to rely on luck, but a bit won't hurt in a competition.",

        BEEF_BELL = "Something about its tone triggers an affectionate response in beefalo.",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "A well-constructed habitation for the kittens.",
            BURNT = "It seems the kittens have lost their residence.",
			PLAYING_HIDEANDSEEK = "The kittens are currently attempting to hide.",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "The kittens' hiding game will come to an end soon.",
		},

		KITCOONDEN_KIT = "Materials to construct a proper kitten household.",

		TICOON = 
		{
			GENERIC = "Quite a wise feline.",
			ABANDONED = "He has left me to procure the kittens alone.",
			SUCCESS = "He encountered one of the kittens.",
			LOST_TRACK = "The kitten was found before we arrived.",
			NEARBY = "I believe we're near.",
			TRACKING = "He is guiding me to a kitten's hiding spot.",
			TRACKING_NOT_MINE = "He is guiding someone else to a kitten's hiding spot.",
			NOTHING_TO_TRACK = "There is no clear evidence left to point us towards the kitten.",
			TARGET_TOO_FAR_AWAY = "The kittens are far enough away to hide their smell.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "A special representation of wildcats.",
            EMPTY = "A golden offering is necessary.",
            BURNT = "The fire was overwhelming.",
        },

		KITCOON_FOREST = "It appears to have developed a form of camouflage.",
		KITCOON_SAVANNA = "The resemblance to a Panthera tigris is incredible.",
		KITCOON_MARSH = "This feline has quite an uncanny appearance.",
		KITCOON_DECIDUOUS = "Oh dear, you are quite adorable.",
		KITCOON_GRASS = "Oh dear, have you been startled?",
		KITCOON_ROCKY = "Hmm, their body language seems to imply annoyance.",
		KITCOON_DESERT = "They possess large ears to facilitate hunting small desert critters.",
		KITCOON_MOON = "A feline? From the moon? Quite fascinating...",
		KITCOON_YOT = "Oh dear, the bell truly augments your... cuteness. Ho ho!",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Our activities seem to have triggered a defense mechanism of sorts.",
            DEAD = "Strange, I was expecting a bit more than that.",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "Interesting, it seems to utilize aspects of the altars for combat.",
            DEAD = "I doubt it will stay inert for long.",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "I should endeavor to not become trapped by its barriers.",
        ALTERGUARDIAN_PHASE3 = "If my assumptions are correct, this should be its final form.",
        ALTERGUARDIAN_PHASE3TRAP = "They appear to have a sleep inducing effect. Best to stay away.",
        ALTERGUARDIAN_PHASE3DEADORB = "Interesting, it seems to have retained the energy that powered it.",
        ALTERGUARDIAN_PHASE3DEAD = "With the energy removed, I doubt it will be able to re-form.",

        ALTERGUARDIANHAT = "The multitudes of knowledge it contains... if only I could write it all down...",
        ALTERGUARDIANHATSHARD = "These shards hold a significant amount of energy on their own.",

        MOONSTORM_GLASS = {
            GENERIC = "The glass seems to have stabilized.",
            INFUSED = "It's radiating a faintly glowing energy."
        },

        MOONSTORM_STATIC = "That energy seems quite volatile.",
        MOONSTORM_STATIC_ITEM = "This device appears to keep the energy contained, somehow.",
        MOONSTORM_SPARK = "I assumed it was a form of electricity, but it seems to be something else entirely...",

        BIRD_MUTANT = "Oh dear, that creature looks unwell.",
        BIRD_MUTANT_SPITTER = "The poor thing appears to have been altered by its proximity to the storm.",

        WAGSTAFF_NPC = "He seems to be conducting research on the storm, I should assist him.",
        ALTERGUARDIAN_CONTAINED = "I wonder what he means to do with all that energy.",

        WAGSTAFF_TOOL_1 = "Oh dear, I wonder whether that is the tool he requested or not...",
        WAGSTAFF_TOOL_2 = "Perhaps this is the tool he requires? I should suggest a cataloging system.",
        WAGSTAFF_TOOL_3 = "His instructions weren't particularly clear, but this might be what I seek.",
        WAGSTAFF_TOOL_4 = "His tools would be much easier to procure if there was some organization...",
        WAGSTAFF_TOOL_5 = "Regrettably unlabeled... I'll just have to assume it's what he's looking for.",

        MOONSTORM_GOGGLESHAT = "A rather eccentric design, yet surprisingly effective.",

        MOON_DEVICE = {
            GENERIC = "As I suspected, it's meant to function as a battery of sorts.",
            CONSTRUCTION1 = "I'm afraid I can't yet ascertain its function.",
            CONSTRUCTION2 = "The pieces are slowly falling into place.",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Horology mixed with magic, truly fascinating.",
			RECHARGING = "It appears to require some time to replenish its power between uses.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Horology mixed with magic, truly fascinating.",
			RECHARGING = "It appears to require some time to replenish its power between uses.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Horology mixed with magic, truly fascinating.",
			RECHARGING = "It appears to require some time to replenish its power between uses.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Horology mixed with magic, truly fascinating.",
			RECHARGING = "It appears to require some time to replenish its power between uses.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Horology mixed with magic, truly fascinating.",
			RECHARGING = "It appears to require some time to replenish its power between uses.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "A handy bit of pocket-sized weaponry.",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "It appears these pieces of clockwork have been infused with shadow fuel.",
        POCKETWATCH_DISMANTLER = "These tools are specialized for clockmaking.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Magic triggered by a clockwork mechanism, how fascinating!",
			DIFFERENTSHARD = "Magic triggered by a clockwork mechanism, how fascinating!",
		},
        POCKETWATCH_PORTAL_EXIT = "I wonder if she would allow me to write down my observations...",

        -- Waterlog
        WATERTREE_PILLAR = "I wonder what contributed to its advanced growth?",
        OCEANTREE = "It seems to be a hybrid between the genera Rhizophora and Salix.",
        OCEANTREENUT = "Oh my, this seed seems quite eager to grow.",
        WATERTREE_ROOT = "I suggest we avoid hitting those with our boat.",

        OCEANTREE_PILLAR = "I was able to recreate the growth conditions, but not to the extent of the original.",
        
        OCEANVINE = "These vines seem to enjoy a symbiotic relationship with the tree.",
        FIG = "I do enjoy a nice ripe fig.",
        FIG_COOKED = "Cooking it brings out more of the flavor.",

        SPIDER_WATER = "It's incredible that they can create enough surface tension to stay above water at that size.",
        MUTATOR_WATER = "How interesting! They appear to alter an arachnid's form when ingested.",
        OCEANVINE_COCOON = "This species seems to be both arboreal and aquatic.",
        OCEANVINE_COCOON_BURNT = "How unfortunate.",

        GRASSGATOR = "It appears docile enough.",

        TREEGROWTHSOLUTION = "This fig mixture appears to induce rapid arboreal growth.",

        FIGATONI = "An unexpected, but not unpleasant combination.",
        FIGKABAB = "I suppose this is the next logical step after meat on a stick.",
        KOALEFIG_TRUNK = "High in protein and fiber.",
        FROGNEWTON = "It has quite a unique flavor.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "This is certainly not of this world. Curious.",
            CRIMSON = "The nightmare fuel appears to have had an adverse affect on it.",
            ENABLED = "What is the meaning of this?!",
			WAITING_FOR_DARK = "I believe it's storing up energy, but for what purpose?",
			COOLDOWN = "It appears to have expended its energy, but I cannot say for how long.",
			SPAWN_DISABLED = "It should remain inactive, as long as it's not disturbed.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Do be careful not to overexert yourself, dear.",
            BURNT = "I'd suggest looking elsewhere for a place to exercise.",
        },

        DUMBBELL = "A bit of exercise can be quite beneficial to one's health.",
        DUMBBELL_GOLDEN = "A bit of exercise can be quite beneficial to one's health.",
		DUMBBELL_MARBLE = "A bit of exercise can be quite beneficial to one's health.",
        DUMBBELL_GEM = "A bit of exercise can be quite beneficial to one's health.",
        POTATOSACK = "He seems to have a deep fondness for tubers.",


        TERRARIUMCHEST = 
		{
			GENERIC = "I wonder how it came to be here.",
			BURNT = "Oh dear...",
			SHIMMER = "That light is refracting rather unnaturally.",
		},

		EYEMASKHAT = "I doubt that they make my prescription in this size.",

        EYEOFTERROR = "Oculus dexter or oculus sinister, I wonder? I have a suspicion it's the latter.",
        EYEOFTERROR_MINI = "I'm fascinated, but now is not the time to study you.",
        EYEOFTERROR_MINI_GROUNDED = "An eyeball... embryo? These creatures are quite perplexing.",

        FROZENBANANADAIQUIRI = "This would pair nicely with a short book.",
        BUNNYSTEW = "Caloric, but nutritious. It smells wonderful, as well. ",
        MILKYWHITES = "Tunica albuginea oculi, the opaque white covering of the vitreous humor. Also known as disgusting.",

        CRITTER_EYEOFTERROR = "Now, I wonder if your nerves are functional, or merely decorative...",

        SHIELDOFTERROR ="It seems better suited to offensive measures, rather than defensive as one might think.",
        TWINOFTERROR1 = "How curious, I wonder who might have constructed such a thing?",
        TWINOFTERROR2 = "How curious, I wonder who might have constructed such a thing?",

        -- Year of the Catcoon
        CATTOY_MOUSE = "A simple mechanism behind an entertaining toy for felines.",
        KITCOON_NAMETAG = "Ah, it does bring back memories of my dear old cat...",

		KITCOONDECOR1 =
        {
            GENERIC = "Its movement appears to be hypnotic to the kittens.",
            BURNT = "Gone with the fire.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "I used to have one of those back home.",
            BURNT = "Unfortunately, it's useless now.",
        },

		KITCOONDECOR1_KIT = "Materials to construct entertaining toys for kittens.",
		KITCOONDECOR2_KIT = "Materials to construct entertaining toys for kittens.",

        -- WX78
        WX78MODULE_MAXHEALTH = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MAXSANITY1 = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MAXSANITY = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MOVESPEED = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MOVESPEED2 = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_HEAT = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_NIGHTVISION = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_COLD = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_TASER = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_LIGHT = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MAXHUNGER1 = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MAXHUNGER = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MUSIC = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_BEE = "They dislike organics, but don't seem opposed to taking inspiration from them.",
        WX78MODULE_MAXHEALTH2 = "They dislike organics, but don't seem opposed to taking inspiration from them.",

        WX78_SCANNER = 
        {
            GENERIC ="I suspect our resident handywoman might have assisted with its construction.",
            HUNTING = "It appears to be searching for a suitable specimen to analyze.",
            SCANNING = "It seems to be collecting data from that specimen.",
        },

        WX78_SCANNER_ITEM = "It appears to be dormant, for the moment.",
        WX78_SCANNER_SUCCEEDED = "It's finished compiling some more research, I believe.",

        WX78_MODULEREMOVER = "Do be careful with that, dear.",

        SCANDATA = "An incredibly thorough analysis. Well done!",
    },

    DESCRIBE_GENERIC = "A rare occurrence. I don't know what that is.",
    DESCRIBE_TOODARK = "I can't see in the dark.",
    DESCRIBE_SMOLDERING = "Seems it's about to ignite from the heat.",

    DESCRIBE_PLANTHAPPY = "This crop appears to be in good health.",
    DESCRIBE_PLANTVERYSTRESSED = "It appears to be suffering from quite a variety of stressors.",
    DESCRIBE_PLANTSTRESSED = "It seems to be suffering from two different stressors at once.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "I'll have to remove some of those troublesome weeds.",
    DESCRIBE_PLANTSTRESSORFAMILY = "These grow best when surrounded by others of its particular species.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "The density of plants should be reduced to avoid competition for nutrients.",
    DESCRIBE_PLANTSTRESSORSEASON = "I'm afraid this plant might not be in season.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "It could use a little hydration.",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "It requires more nutrient-rich soil.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "I should stimulate its growth with some conversation.",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Al dente.",
		WINTERSFEASTFUEL = "I feel as though I've been wrapped in a cozy blanket.",
    },
}
