--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Guess he ain't got the time right now.",
        },
        REPAIR =
        {
            WRONGPIECE = "That'd clog the assembly line.",
        },
        BUILD =
        {
            MOUNTED = "Can't assemble anything from up here.",
            HASPET = "Nah. I'm a one-pet gal.",
			TICOON = "I'm not lookin' to expand my workforce.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Dirty work's not for broad daylight.",
			GENERIC = "I'd NEVER misuse a tool.",
			NOBITS = "Smooth as sheet metal.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "Nope, I'm not shavin' someone else's beefalo.",
		},
		STORE =
		{
			GENERIC = "It's full to bursting.",
			NOTALLOWED = "That's just impractical.",
			INUSE = "No rush.",
            NOTMASTERCHEF = "I don't wanna ruin whatever Warly's working on.",
		},
        CONSTRUCT =
        {
            INUSE = "Aw someone else is building it already.",
            NOTALLOWED = "Square peg in a round hole.",
            EMPTY = "I gotta have something to build with.",
            MISMATCH = "Oops! Wrong plans.",
            NOTREADY = "Maybe once it's settled down around here!",
        },
		RUMMAGE =
		{
			GENERIC = "I can't right now.",
			INUSE = "No rush.",
            NOTMASTERCHEF = "I don't wanna ruin whatever Warly's working on.",
            NOTAMERM = "Nah. I know where I ain't welcome.",
		},
		UNLOCK =
        {
            WRONGKEY = "That ain't right.",
        },
		USEKLAUSSACKKEY =
        {
            WRONGKEY = "Hm. Didn't work.",
            KLAUS = "Success!",
			QUAGMIRE_WRONGKEY = "There's another key around here somewhere.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Can't get in yet.",
            HOSTBUSY = "Looks like he's got a lot on his hands right now. Do these birds have hands?",
            CARNIVAL_HOST_HERE = "Where's the bird in charge around here?",
            NOCARNIVAL = "Looks like the party's over. Back to work, everyone!",
			EMPTY_CATCOONDEN = "They're fresh outta everything.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "Looks like we gotta find more players.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "Not really enough places for them to hide.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "They look pretty tired, let's see if they wanna play again tomorrow.",
            MANNEQUIN_EQUIPSWAPFAILED = "Just kiddin'!",
            PILLOWFIGHT_NO_HANDPILLOW = "Err, I think I'm missin' something.",
            NOTMYBERNIE = "Whoa. Take it easy, big fella.",
            NOTMERM = "Fine. Y'all wait around for Wurt then.",
            NOKELP = "only_used_by_wurt",
--fallback to speech_wilson.lua             HASMERMLEADER = "only_used_by_wurt",
		},
		OPEN_CRAFTING =
		{
            PROFESSIONALCHEF = "I don't wanna ruin whatever Warly's working on.",
			SHADOWMAGIC = "I don't trust that thing one bit.",
		},
        COOK =
        {
            GENERIC = "I'm not really in a cooking mood.",
            INUSE = "How's the grub coming?",
            TOOFAR = "I gotta get closer. Or grow longer arms.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Whoever heard of a race with no racers?",
        },

		DISMANTLE = 
		{
			COOKING = "I'm all for striking while the iron's hot, but...",
			INUSE = "No rush.",
			NOTEMPTY = "Better clear it out first.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "I'll need a tougher rod to reel in one of those whoppers!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "I think I could just use a regular old rod here.",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOWATERNEARBY = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOFIRES =       "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOSILVICULTURE = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOHORTICULTURE = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOTENTACLEGROUND = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOSLEEPTARGETS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             TOOMANYBEES = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             NOMOONINCAVES = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua             ALREADYFULLMOON = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "That ain't right.",
            DEAD = "They appear to be dead. Very dead.",
            SLEEPING = "They're off the clock.",
            BUSY = "They're busy working.",
            ABIGAILHEART = "No one should ever lose a sister.",
            GHOSTHEART = "Some things even I can't fix.",
            NOTGEM = "What sort of worker do you take me for?",
            WRONGGEM = "Nn-nn. That doesn't go there.",
			NOGENERATORSKILL = "I'm sure it can be done, with the right know-how.",
            NOTSTAFF = "It doesn't fit together like that.",
            MUSHROOMFARM_NEEDSSHROOM = "It doesn't need this.",
            MUSHROOMFARM_NEEDSLOG = "It needs something else.",
            MUSHROOMFARM_NOMOONALLOWED = "No amount of elbow grease is gonna make these things grow.",
            SLOTFULL = "No sense wasting materials.",
            FOODFULL = "Ah, a wonderful bird, the peli-can.",
            NOTDISH = "I don't wanna go angering no demons.",
            DUPLICATE = "We already got these schematics.",
            NOTSCULPTABLE = "That ain't for sculpting.",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Don't think that'll work.",
            WRONGSHADOWFORM = "I gotta disassemble it and try again.",
            NOMOON = "Gonna have to make this under the influence of the moon.",
			PIGKINGGAME_MESSY = "Gotta clean up first.",
			PIGKINGGAME_DANGER = "Nah. It ain't safe for that now.",
			PIGKINGGAME_TOOLATE = "Nah. I'll wait until morning.",
			CARNIVALGAME_INVALID_ITEM = "Guess it doesn't want that.",
			CARNIVALGAME_ALREADY_PLAYING = "I can wait until they're done.",
            SPIDERNOHAT = "There just ain't enough space for that.",
            TERRARIUM_REFUSE = "Maybe I should try powering it up with somethin' else?",
            TERRARIUM_COOLDOWN = "Guess we gotta wait for the tree to grow back before we can give it anything.",
            NOTAMONKEY = "I can't make sense of all yer hollerin'!",
            QUEENBUSY = "I'll wait, she's got work to do.",
        },
        GIVETOPLAYER =
        {
            FULL = "I'll hold on to it for now. They're all loaded up.",
            DEAD = "Seems they're dead.",
            SLEEPING = "They're off the clock.",
            BUSY = "They're busy working.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "They've got their hands full.",
            DEAD = "Seems they're dead.",
            SLEEPING = "They're off the clock.",
            BUSY = "They're busy working.",
        },
        WRITE =
        {
            GENERIC = "I'm better with my hands than my words.",
            INUSE = "Workin' hard, or hardly workin'?",
        },
        DRAW =
        {
            NOIMAGE = "I'm not much of an artist.",
        },
        CHANGEIN =
        {
            GENERIC = "All a gal needs is a good pair of overalls.",
            BURNING = "Fire in textiles!",
            INUSE = "Should I put together another one?",
            NOTENOUGHHAIR = "I need more hair to work with.",
            NOOCCUPANT = "It might work better if I had a beefalo hitched up.",
        },
        ATTUNE =
        {
            NOHEALTH = "I don't have it in me right now.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "It's a bit preoccupied.",
            INUSE = "Only one to a beef, hey?",
			SLEEPING = "Up and at 'em, big guy!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "It's a bit preoccupied.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Pfft. A baby could assemble those.",
            CANTLEARN = "That's above my pay grade.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "That ain't gonna work here.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "It's kinda hard to read in here...",--Likely trying to read messagebottle treasure map in caves

            STASH_MAP_NOT_FOUND = "I can't make heads or monkey tails of it. Ha!",-- Likely trying to read stash map  in world without stash                  
        },
        WRAPBUNDLE =
        {
            EMPTY = "I can't wrap up thin air.",
        },
        PICKUP =
        {
			RESTRICTION = "That's not really my forte.",
			INUSE = "Shucks. Someone beat me to it.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Whoops, hard to keep track of whose racer is whose!",
                "Have you seen my racer around here?",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
            FULL_OF_CURSES = "I'll be keepin' my distance.",
        },
        SLAUGHTER =
        {
            TOOFAR = "It's well outta my reach.",
        },
        REPLATE =
        {
            MISMATCH = "I always get my dishes mixed up.",
            SAMEDISH = "It's on a dish already.",
        },
        SAIL =
        {
            REPAIR = "In my professional opinion, she don't need repairin'.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Gotta keep a steady pace, like on the ol' assembly line!",
            BAD_TIMING1 = "I'll get the hang of this!",
            BAD_TIMING2 = "Shoot, I'm sure there's a knack to this.",
        },
        LOWER_SAIL_FAIL =
        {
            "Pretty sure that ain't how that's supposed to go.",
            "One more time, nice an' easy...",
            "C'mon now, work with me here!",
        },
        BATHBOMB =
        {
            GLASSED = "Can't do that with all this glass in the way.",
            ALREADY_BOMBED = "That one's already been glitzed up.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "We already got these schematics.",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "This one's too shrimpy!",
            OVERSIZEDVEGGIES_TOO_SMALL = "Nah, this one's not quite up to snuff.",
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
            GENERIC = "I know about all there is to know about that one.",
            FERTILIZER = "Yeah, I think I've got the gist.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "I've got a hunch that'll be bad for the plants.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "I'd better get some more water.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Everybody take five while I go find some more water!",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Nope, that's not gonna work.",
            BEEF_BELL_ALREADY_USED = "I'm pretty sure that's someone else's beefalo.",
            BEEF_BELL_HAS_BEEF_ALREADY = "I've already got a beefalo, thanks.",
        },
        HITCHUP =
        {
            NEEDBEEF = "I'd better rustle up a beefalo.",
            NEEDBEEF_CLOSER = "I gotta coax my beefalo to come closer.",
            BEEF_HITCHED = "All hitched up.",
            INMOOD = "It's too ornery to hitch up.",
        },
        MARK =
        {
            ALREADY_MARKED = "This one looks like a winner!",
            NOT_PARTICIPANT = "Guess I'll wait for the next round.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "This judge is slackin' on the job!",
            ALREADYACTIVE = "There must be a contest already goin' on somewhere.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "I've already got this one down pat.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Shoot! I've gotta be faster next time!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "Looks like I'm not the boss here.",
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
            DOER_ISNT_MODULE_OWNER = "I just thought the lil guy could use a polish.",
        },

		CAST_SPELLBOOK =
		{
--fallback to speech_wilson.lua 			NO_TOPHAT = "only_used_by_waxwell",
		},

        CASTSPELL =
        {
            TERRAFORM_TOO_SOON = "only_used_by_wurt",
        },

		CASTAOE =
		{
--fallback to speech_wilson.lua 			NO_MAX_SANITY = "only_used_by_waxwell",
            NOT_ENOUGH_EMBERS = "only_used_by_willow",
            NO_TARGETS = "only_used_by_willow",
            CANT_SPELL_MOUNTED = "only_used_by_willow",
            SPELL_ON_COOLDOWN = "only_used_by_willow",
			NO_BATTERY = "Darn clicker's outta juice.",
			NO_CATAPULTS = "Looks like I'm outta range.",
		},

        PICK =
        {
            NOTHING_INSIDE = "Well that was pointless.",
        },

        HEAL =
        {
            NOT_MERM = "Sorry, guess it's specially-made for merms.",
        },

		LOOKAT = --fail strings for close inspection
		{
			-- Winona specific
			ROSEGLASSES_INVALID = "No signs of Charlie.",
			ROSEGLASSES_COOLDOWN = "Let's take a breather.",
            ROSEGLASSES_DISMISS = "Drat, I lost the trail!",
            ROSEGLASSES_STUMPED = "Hmm... I can't tell if Charlie's been here.",
			--
		},

		REMOTE_TELEPORT =
		{
			NOSKILL = "Huh. I ain't familiar with this model.",
			NODEST = "It's not gonna work without a receiving end.",
		},
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Looks like I need some parts.",
		NO_TECH = "Can't say I ever learned how to make one of those.",
		NO_STATION = "I'll be needing a station made for this kinda work.",
	},

	ACTIONFAIL_GENERIC = "I sure gummed the works there.",
	ANNOUNCE_BOAT_LEAK = "We gotta repair this ol'girl!",
	ANNOUNCE_BOAT_SINK = "We're goin' down!",
	ANNOUNCE_DIG_DISEASE_WARNING = "That helped a bit.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Whew! If that isn't the mightiest smell.", --removed
	ANNOUNCE_ADVENTUREFAIL = "Yeow. Don't make me come back in there!",
    ANNOUNCE_MOUNT_LOWHEALTH = "You're not looking too good, big guy.",

    --waxwell and wickerbottom specific strings
--fallback to speech_wilson.lua     ANNOUNCE_TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua     ANNOUNCE_WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua     ANNOUNCE_NOWATERNEARBY = "only_used_by_waxwell_and_wicker",

	--waxwell specific
--fallback to speech_wilson.lua 	ANNOUNCE_SHADOWLEVEL_ITEM = "only_used_by_waxwell",
--fallback to speech_wilson.lua 	ANNOUNCE_EQUIP_SHADOWLEVEL_T1 = "only_used_by_waxwell",
--fallback to speech_wilson.lua 	ANNOUNCE_EQUIP_SHADOWLEVEL_T2 = "only_used_by_waxwell",
--fallback to speech_wilson.lua 	ANNOUNCE_EQUIP_SHADOWLEVEL_T3 = "only_used_by_waxwell",
--fallback to speech_wilson.lua 	ANNOUNCE_EQUIP_SHADOWLEVEL_T4 = "only_used_by_waxwell",

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

	ANNOUNCE_BEES = "BEEEES!",
	ANNOUNCE_BOOMERANG = "I'll catch you next time! Ow...",
	ANNOUNCE_CHARLIE = "C-Charlie?",
	ANNOUNCE_CHARLIE_ATTACK = "Yeow! Rude!",
	ANNOUNCE_CHARLIE_MISSED = "Ha! I know all your moves!", --winona specific
	ANNOUNCE_COLD = "Brr! Cold as frozen steel out here!",
	ANNOUNCE_HOT = "It's hotter than a tin smelter in July!",
	ANNOUNCE_CRAFTING_FAIL = "How did I junk that up?!",
	ANNOUNCE_DEERCLOPS = "Democrew incoming!",
	ANNOUNCE_CAVEIN = "Uh... I hope everyone brought hardhats.",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"Earthquake! I think?",
		"What's that?!",
		"What on earth? The earth!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Get a load of this!",
        "Hope it's to your likin'!",
        "Here ya go!",
	},
	ANNOUNCE_SACREDCHEST_YES = "Huh. Guess I'm worthy.",
	ANNOUNCE_SACREDCHEST_NO = "Guess I didn't make the cut.",
    ANNOUNCE_DUSK = "There's the quittin' bell.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

    -- Winona specific
    ANNOUNCE_ROSEGLASSES = 
    {
        "Gotcha, sis!",
        "Charlie was here.",
        "I'm pickin' up traces of her magic.",
    },
    ANNOUNCE_CHARLIESAVE = 
    {
        "Yeesh! I can't tell if she's tryin' to help me or kill me.",
    },
	ANNOUNCE_ENGINEERING_CAN_UPGRADE = "Easy peasy, my version is miles ahead.",
	ANNOUNCE_ENGINEERING_CAN_DOWNGRADE = "Whoa, this one is more advanced than my version.",
	ANNOUNCE_ENGINEERING_CAN_SIDEGRADE = "Interestin'. This version and mine are ahead in different ways.",

	ANNOUNCE_EAT =
	{
		GENERIC = "That hits the spot.",
		PAINFUL = "Yeow! That one bit back!",
		SPOILED = "I am full of regret.",
		STALE = "I've had worse.",
		INVALID = "Pretty sure that's not food.",
        YUCKY = "Blech! Even I got limits!",

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

	ANNOUNCE_FOODMEMORY = "only_used_by_warly",

    ANNOUNCE_ENCUMBERED =
    {
        "Hhff!",
        "Easy as pie! Hff!",
        "Like eggs in coffee!",
        "Hhngh!",
        "I... *huff* I got it!",
        "Ha! I'm plenty rugged! *huff*",
        "Ooff...",
        "This... ain't... nothin'!",
        "Where's worker's comp when you need it?",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Better skedaddle!",
		"Somethin's going haywire!",
		"Time to go!",
	},
    ANNOUNCE_RUINS_RESET = "Huh? Where'd all these monsters come from?",
    ANNOUNCE_SNARED = "Hey!",
    ANNOUNCE_SNARED_IVY = "Knock it off, will ya?",
    ANNOUNCE_REPELLED = "It's protected!",
	ANNOUNCE_ENTER_DARK = "I can't see!",
	ANNOUNCE_ENTER_LIGHT = "Whew! I can see!",
	ANNOUNCE_FREEDOM = "Ha! Outsmarted!",
	ANNOUNCE_HIGHRESEARCH = "Cutting edge!",
	ANNOUNCE_HOUNDS = "Are those dogs I hear?",
	ANNOUNCE_WORMS = "Was that a tremor?",
    ANNOUNCE_ACIDBATS = "I don't like the sound of that.",
	ANNOUNCE_HUNGRY = "When's lunch?",
	ANNOUNCE_HUNT_BEAST_NEARBY = "I didn't order lunch to go. Get'em!",
	ANNOUNCE_HUNT_LOST_TRAIL = "Gah! I lost it.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Err, are those my footprints? Shoot!",
    ANNOUNCE_HUNT_START_FORK = "This trail looks like a doozy.",
    ANNOUNCE_HUNT_SUCCESSFUL_FORK = "I think we got the jump on this critter.",
    ANNOUNCE_HUNT_WRONG_FORK = "I'm gettin' the heebie-jeebies. Somethin's watchin' me.",
    ANNOUNCE_HUNT_AVOID_FORK = "This trail looks like a cake walk.",
	ANNOUNCE_INV_FULL = "I only got two hands.",
	ANNOUNCE_KNOCKEDOUT = "Yeowch! Hello workman's comp!",
	ANNOUNCE_LOWRESEARCH = "I'll take what I can get.",
	ANNOUNCE_MOSQUITOS = "Gah! I hate bugs!",
    ANNOUNCE_NOWARDROBEONFIRE = "Uh. It's on fire.",
    ANNOUNCE_NODANGERGIFT = "Not a keen idea right now!",
    ANNOUNCE_NOMOUNTEDGIFT = "I can't open anything up here.",
	ANNOUNCE_NODANGERSLEEP = "It ain't safe.",
	ANNOUNCE_NODAYSLEEP = "Can't sleep now, there's work to do!",
	ANNOUNCE_NODAYSLEEP_CAVE = "No way I'm falling asleep here.",
	ANNOUNCE_NOHUNGERSLEEP = "Not without supper first.",
	ANNOUNCE_NOSLEEPONFIRE = "That's NOT fine.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Hey WX, mind turning the light down?",
	ANNOUNCE_NODANGERSIESTA = "But I'm in danger!",
	ANNOUNCE_NONIGHTSIESTA = "I'd rather sleep than nap.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Sleeping down here ain't a bright idea.",
	ANNOUNCE_NOHUNGERSIESTA = "I'd rather whip up some grub.",
	ANNOUNCE_NO_TRAP = "That was a cinch.",
	ANNOUNCE_PECKED = "Yeow! Lay off!",
	ANNOUNCE_QUAKE = "Earthquake!",
	ANNOUNCE_RESEARCH = "I can build even MORE things!",
	ANNOUNCE_SHELTER = "Ah, that's better.",
	ANNOUNCE_THORNS = "Yeow! That smarts!",
	ANNOUNCE_BURNT = "Ow! Ow! Ow!",
	ANNOUNCE_TORCH_OUT = "Out like a light.",
	ANNOUNCE_THURIBLE_OUT = "Ran outta juice.",
	ANNOUNCE_FAN_OUT = "Useless handmade junk!",
    ANNOUNCE_COMPASS_OUT = "Shoddy handmade junk!",
	ANNOUNCE_TRAP_WENT_OFF = "Heh, whoops.",
	ANNOUNCE_UNIMPLEMENTED = "Yeow! That still needs some tinkering!",
	ANNOUNCE_WORMHOLE = "That'll get the adrenaline pumping!",
    ANNOUNCE_WORMHOLE_SAMESPOT = "Sheesh. Just took the long way to nowhere.",
	ANNOUNCE_TOWNPORTALTELEPORT = "Thanks for the lift!",
	ANNOUNCE_CANFIX = "\nIt'd be a pleasure to fix it.",
	ANNOUNCE_ACCOMPLISHMENT = "I can do ANYTHING!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "Mitt me, kid!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It demands poop!",
	ANNOUNCE_TOOL_SLIP = "I meant to do that!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Ha! Now you gotta kiss me!",
	ANNOUNCE_TOADESCAPING = "Oh no you don't!",
	ANNOUNCE_TOADESCAPED = "Slippery devil.",


	ANNOUNCE_DAMP = "A light mist never hurt nobody.",
	ANNOUNCE_WET = "I oughta find some shelter.",
	ANNOUNCE_WETTER = "This is just uncomfortable now.",
	ANNOUNCE_SOAKED = "I'm DRENCHED!",

	ANNOUNCE_WASHED_ASHORE = "Shoot. I hate working in wet clothes.",

    ANNOUNCE_DESPAWN = "Good thing I got all my affairs in order.",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!",
	ANNOUNCE_GHOSTDRAIN = "My head's all fuzzy...",
	ANNOUNCE_PETRIFED_TREES = "Do these trees seem shadier?",
	ANNOUNCE_KLAUS_ENRAGE = "HOLY RIVETS! Time to make tracks!",
	ANNOUNCE_KLAUS_UNCHAINED = "The mitts are coming off!",
	ANNOUNCE_KLAUS_CALLFORHELP = "He called his goons!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Hang on, I'll getcha outta there!",
		GLASS_LOW = "Nearly through!",
		GLASS_REVEAL = "Ha! Gotcha!",
		IDOL_MED = "Hang on, I'll getcha outta there!",
		IDOL_LOW = "Nearly through!",
		IDOL_REVEAL = "Ha! Gotcha!",
		SEED_MED = "Hang on, I'll getcha outta there!",
		SEED_LOW = "Nearly through!",
		SEED_REVEAL = "Ha! Gotcha!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "I'm seein' things!",
	ANNOUNCE_BRAVERY_POTION = "I got my moxie back. Now to tackle those trees.",
	ANNOUNCE_MOONPOTION_FAILED = "Back to the drawing board.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "I ain't gonna hog this all to myself!",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Woah! I'm sparklin' like a Winter's Feast tree!",
	ANNOUNCE_IS_FEASTING = "What a spread!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Hey, someone cut the power!",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Up'n'attem now.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Back to work!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "I'm back on the clock!",

    ANNOUNCE_FLARE_SEEN = "A flare! Hold on, I'm comin'!",
    ANNOUNCE_MEGA_FLARE_SEEN = "Looks like someone's fixin' for a fight.",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Woah, that's a bigg'un!",

    --willow specific
--fallback to speech_wilson.lua 	ANNOUNCE_LIGHTFIRE =
--fallback to speech_wilson.lua 	{
--fallback to speech_wilson.lua 		"only_used_by_willow",
--fallback to speech_wilson.lua     },

    --winona specific
    ANNOUNCE_HUNGRY_SLOWBUILD =
    {
	    "My head's all clouded by hunger!",
	    "Oof. I got the brainfog.",
	    "Maybe I could take a snack break?",
	    "I could sure go for some grub.",
    },
    ANNOUNCE_HUNGRY_FASTBUILD =
    {
	    "This's hungry work.",
	    "I'm working up an appetite.",
	    "That made me a lil hungry.",
	    "I'll need some brainfood at this rate.",
    },

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "The ingredients didn't assemble right.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "What a waste of food!",
    QUAGMIRE_ANNOUNCE_LOSE = "N-nice sky wyrm... Uh-oh.",
    QUAGMIRE_ANNOUNCE_WIN = "Better leave while we can!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I ain't no electrician, but what the heck!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Time to give 'em the old one-two!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I'm tough as nails!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Let's turn up the elbow grease!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "I've been waterproofed!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Whew, wish I had some of this back when I was working night shifts.",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "I'm all outta juice!",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Y'know, fightin' ain't always the answer.",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "I'd better take a step back.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "I'm off the clock!",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "I think I might be needin' an umbrella soon.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "I'm beat!",

	ANNOUNCE_OCEANFISHING_LINESNAP = "You rascal!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "I ain't no slacker! Time to reel 'er in!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "Guess I've got to brush up on my technique.",
	ANNOUNCE_OCEANFISHING_BADCAST = "Practice makes perfect!",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"I'm not a fan of just sittin' around...",
		"Maybe I could invent something quicker.",
		"Come on fish, let's get a move on!",
		"I'm starting to feel a bit antsy.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nI reeled in a whopper!",

	ANNOUNCE_WINCH_CLAW_MISS = "Shoot! Missed it!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "A whole lotta nothing.",

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

--fallback to speech_wilson.lua         BOOK_FISH = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_FIRE = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_WEB = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_TEMPERATURE = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_LIGHT = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_RAIN = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_MOON = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_BEES = "only_used_by_wurt",

--fallback to speech_wilson.lua         BOOK_HORTICULTURE_UPGRADED = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_RESEARCH_STATION = "only_used_by_wurt",
--fallback to speech_wilson.lua         BOOK_LIGHT_UPGRADED = "only_used_by_wurt",
    },

    ANNOUNCE_WEAK_RAT = "It's too tuckered out.",

    ANNOUNCE_CARRAT_START_RACE = "And they're off!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Hey, you're getting off-track!",
        "No, not that way!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Now's no time to be sleeping on the job!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Hey! Let's get a move on!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "What's with the lollygagging? Hop to it!",

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
--fallback to speech_wilson.lua     ANNOUNCE_NOTSKILLEDENOUGH = "only_used_by_wathgrithr",
--fallback to speech_wilson.lua     ANNOUNCE_BATTLESONG_INSTANT_TAUNT_BUFF = "only_used_by_wathgrithr",
--fallback to speech_wilson.lua     ANNOUNCE_BATTLESONG_INSTANT_PANIC_BUFF = "only_used_by_wathgrithr",
--fallback to speech_wilson.lua     ANNOUNCE_BATTLESONG_INSTANT_REVIVE_BUFF = "only_used_by_wathgrithr",

--fallback to speech_wilson.lua     ANNOUNCE_WANDA_YOUNGTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOOLD = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_OLDTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOYOUNG = "only_used_by_wanda",

	ANNOUNCE_POCKETWATCH_PORTAL = "Yeesh, that was a bumpy ride...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "It's showin' me how to build... a machine!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "I've already got that one stored in my noggin'.",
    ANNOUNCE_ARCHIVE_NO_POWER = "Maybe I should poke around, see if I can't get it workin' again.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "That's some real practical gardening know-how!",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "We'll see what happens!",

    ANNOUNCE_FERTILIZER_RESEARCHED = "I always say it's best to know what you're workin' with.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Yeesh, I feel hotter than a furnace!",
		"Ugh, I'm burnin' up...",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Whew, I'm not keen to try that again.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Hey there, plants! Workin' hard?",
        "Now you better grow fast, you hear? I don't wanna catch you slacking!",
		"I want to see you do your best! Now hustle!",
        "I'm here to motivate ya! Feeling motivated yet?",
        "I'm not usually one to stand around chin-wagging, but if it helps ya grow faster...",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Ready or not, here I come!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Need another set of eyes?",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND =
	{
		"Gotcha!",
		"Found you!",
		"There's one!",
		"I see you!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "Just one more left!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "Woo-hoo! That's all of em'!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "Good eye, {name}!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "We're almost out of time!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Drat, you kits are just too good at hiding.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "Would they be hiding this far out?",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "They're probably around here somewhere.",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Well look what we've got here!",

	ANNOUNCE_TICOON_START_TRACKING	= "Looks like they're onto somethin'...",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "Huh. Guess there's nothin' around here.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "He's waitin' on me, let's catch up to him.",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "I think he wants me to follow him.",
	ANNOUNCE_TICOON_NEAR_KITCOON = "A kit's nearby!",
	ANNOUNCE_TICOON_LOST_KITCOON = "I think someone got to that kit before us.",
	ANNOUNCE_TICOON_ABANDONED = "Oh well, guess I'm on my own.",
	ANNOUNCE_TICOON_DEAD = "Poor little guy. He was just doin' his job.",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Come over here, we've got work to do!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "I should build it closer to the judging area.",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Hey, I think I figured out a new costume pattern!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Uhh... maybe it's a friendly giant eyeball?",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Back for more?",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Agh, I guess we'll finish it off another night.",

    -- PIRATES
    ANNOUNCE_CANT_ESCAPE_CURSE = "I'm not one for knickknacks, but for some reason I just can't let 'em go...",
    ANNOUNCE_MONKEY_CURSE_1 = "Uuurgh, I don't feel so good...",
    ANNOUNCE_MONKEY_CURSE_CHANGE = "I guess now I'm a real grease monkey. Ha...",
    ANNOUNCE_MONKEY_CURSE_CHANGEBACK = "That was more than enough monkeying around for me.",

    ANNOUNCE_PIRATES_ARRIVE = "Sounds like someone's about to throw a monkey wrench in the works...",

--fallback to speech_wilson.lua     ANNOUNCE_BOOK_MOON_DAYTIME = "only_used_by_waxwell_and_wicker",

    ANNOUNCE_OFF_SCRIPT = "That didn't seem right.",

    ANNOUNCE_COZY_SLEEP = "I feel all bright-eyed and bushy-tailed!",

	--
	ANNOUNCE_TOOL_TOOWEAK = "Maybe this ain't the right tool for the job...",

    ANNOUNCE_LUNAR_RIFT_MAX = "I should check out that weird glow.",
    ANNOUNCE_SHADOW_RIFT_MAX = "I've got a bad feelin'...",

    ANNOUNCE_SCRAPBOOK_FULL = "I can't squeeze any more pages in my scrapbook.",

    ANNOUNCE_CHAIR_ON_FIRE = "This is fine.",

    ANNOUNCE_HEALINGSALVE_ACIDBUFF_DONE = "Uh oh, better slap on some more Acid Repellent.",

    ANNOUNCE_COACH = 
    {
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
    },
    ANNOUNCE_WOLFGANG_WIMPY_COACHING = "only_used_by_wolfang",
    ANNOUNCE_WOLFGANG_MIGHTY_COACHING = "only_used_by_wolfang",
    ANNOUNCE_WOLFGANG_BEGIN_COACHING = "only_used_by_wolfang",
    ANNOUNCE_WOLFGANG_END_COACHING = "only_used_by_wolfang",
    ANNOUNCE_WOLFGANG_NOTEAM = 
    {
        "only_used_by_wolfang",
        "only_used_by_wolfang",
        "only_used_by_wolfang",
    },

    ANNOUNCE_YOTD_NOBOATS = "Whoops, that start point's a bit far off.",
    ANNOUNCE_YOTD_NOCHECKPOINTS = "Can't start before I've finished settin' up the race!",
    ANNOUNCE_YOTD_NOTENOUGHBOATS = "I guess there ain't much room for anyone else to join, huh?",

    ANNOUNCE_OTTERBOAT_OUTOFSHALLOWS = "This rickety thing wasn't built for deep water!",
    ANNOUNCE_OTTERBOAT_DENBROKEN = "Looks like the den was the main structural support...",

    ANNOUNCE_GATHER_MERM = "only_used_by_wurt",

	BATTLECRY =
	{
		GENERIC = "I'll demolish you!",
		PIG = "We're makin' bacon!",
		PREY = "I'll demolish you!",
		SPIDER = "I hate spiders!",
		SPIDER_WARRIOR = "Let's dance!",
		DEER = "Let's throw down!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "I quit!",
		PIG = "I went easy on you!",
		PREY = "...Demolition's rescheduled.",
		SPIDER = "This isn't over!",
		SPIDER_WARRIOR = "Next time!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "That was a one-way ticket.",
        MULTIPLAYER_PORTAL_MOONROCK = "Wow. Can't even see the weld joints.",
        MOONROCKIDOL = "Do I gotta offer it up to something?",
        CONSTRUCTION_PLANS = "Let's get building.",

        ANTLION =
        {
            GENERIC = "How's the weather up there?",
            VERYHAPPY = "Looks like we're safe for awhile.",
            UNHAPPY = "That is not a happy monster.",
        },
        ANTLIONTRINKET = "It's a colorful bucket.",
        SANDSPIKE = "Hit and a miss!",
        SANDBLOCK = "Things are getting gritty!",
        GLASSSPIKE = "That's a hazardous decoration.",
        GLASSBLOCK = "It's a big hunk of glass.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="What a nice little flower.",
			LEVEL1 = "Looks like someone needed a break.",
			LEVEL2 = "Up'n'attem! The day's a-wasting!",
			LEVEL3 = "That flower looks raring to go.",

			-- deprecated
            LONG = "What a nice little flower.",
            MEDIUM = "It's getting antsy.",
            SOON = "Something's coming.",
            HAUNTED_POCKET = "It wants down.",
            HAUNTED_GROUND = "What do you want? Water?",
        },

        BALLOONS_EMPTY = "No fun without Wes.",
        BALLOON = "Oh! A balloon.",
		BALLOONPARTY = "We can celebrate once the work is done.",
		BALLOONSPEED =
        {
            DEFLATED = "Better not leave that unattended.",
            GENERIC = "It's full of get up and go!",
        },
		BALLOONVEST = "I think he's trying to be helpful... in his own way.",
		BALLOONHAT = "Cute, but it won't protect your noggin' from much.",

        BERNIE_INACTIVE =
        {
            BROKEN = "He's a bit of a fixer-upper.",
            GENERIC = "This little guy's been well loved.",
        },

        BERNIE_ACTIVE = "Is he clockwork? Can I peek inside?",
        BERNIE_BIG = "That girl knows how to put on a show.",

		BOOKSTATION =
		{
			GENERIC = "I've gotta say, that's some pretty solid construction.",
			BURNT = "Shoot. Grams is gonna have a fit.",
		},
        BOOK_BIRDS = "I was never much of a book learner.",
        BOOK_TENTACLES = "I'm not really a \"book smarts\" kind of gal.",
        BOOK_GARDENING = "I prefer to learn from experience.",
		BOOK_SILVICULTURE = "I'd rather have building material than reading material.",
		BOOK_HORTICULTURE = "I prefer to learn from experience.",
        BOOK_SLEEP = "I already know how to sleep, thanks.",
        BOOK_BRIMSTONE = "I prefer hands-on learning.",

        BOOK_FISH = "I learn by doing, not reading.",
        BOOK_FIRE = "Not really my kinda thing.",
        BOOK_WEB = "This ain't one of them self-help books, is it?",
        BOOK_TEMPERATURE = "Sorry grams, I'm not much of a reader.",
        BOOK_LIGHT = "I gotta admit, pretty handy to have a book with a built-in reading lamp.",
        BOOK_RAIN = "I'm too busy to sit around and read.",
        BOOK_MOON = "At this point, I wish I knew less about the moon.",
        BOOK_BEES = "I can't read when there's work to do!",
        
        BOOK_HORTICULTURE_UPGRADED = "I don't need a book tellin' me how to stick seeds in the ground.",
        BOOK_RESEARCH_STATION = "You'll only really learn by gettin' your hands dirty.",
        BOOK_LIGHT_UPGRADED = "It's all Greek to me.",

        FIREPEN = "Yeesh, that pen's piping hot!",

        PLAYER =
        {
            GENERIC = "Hey, %s! How ya doin'?",
            ATTACKER = "Hands to yourself, bucko!",
            MURDERER = "Murderer! Get'em!",
            REVIVER = "You're good people, %s.",
            GHOST = "Stop whinin', %s, it's just a scratch!",
            FIRESTARTER = "You better not have singed any of my projects, %s.",
        },
        WILSON =
        {
            GENERIC = "Hey %s! How ya doin'?",
            ATTACKER = "Hands to yourself, bucko!",
            MURDERER = "Mad scientist! Get'em!",
            REVIVER = "You're good people, scientist.",
            GHOST = "Stop whinin', %s, it's just a scratch!",
            FIRESTARTER = "You better not have singed any of my projects, scientist.",
        },
        WOLFGANG =
        {
            GENERIC = "How you doin', big guy?",
            ATTACKER = "I wouldn't wanna catch the business end of those mitts!",
            MURDERER = "Watch out! He's got a taste fer blood now!",
            REVIVER = "You're just a big softie, aintcha?",
            GHOST = "Walk it off, big guy!",
            FIRESTARTER = "Was that fire an accident, %s?",
        },
        WAXWELL =
        {
            GENERIC = "So... %s.",
            ATTACKER = "Don't make me noogie you, %s.",
            MURDERER = "How many lives you plannin' on ruinin', %s?",
            REVIVER = "Nice job, ya big walnut.",
            GHOST = "I could just leave you like this, hey?",
            FIRESTARTER = "Mysterious fires follow you like a plague, %s.",
        },
        WX78 =
        {
            GENERIC = "C'mon, %s! Justa tiny peek under the hood!",
            ATTACKER = "Yeesh. They're on the fritz again.",
            MURDERER = "I'll reset you to factory standards, bot.",
            REVIVER = "Ha! The bucket'o'bolts has feelings after all!",
            GHOST = "Incredible! You gotta tell me how that works, %s!",
            FIRESTARTER = "Your logic lets you set fires, %s? Why?",
        },
        WILLOW =
        {
            GENERIC = "Good ta see ya, %s!",
            ATTACKER = "Yer a workplace hazard, %s.",
            MURDERER = "She's mad! Get'er!",
            REVIVER = "Knew I could count on you, %s.",
            GHOST = "Ha! You're a disaster, %s.",
            FIRESTARTER = "Business as usual.",
        },
        WENDY =
        {
            GENERIC = "Hey there, %s.",
            ATTACKER = "Woah there, slugger!",
            MURDERER = "She's not playin'! Murderer!",
            REVIVER = "You got a sharp mind in that noggin, %s.",
            GHOST = "I hope you left the other guy lookin' worse.",
            FIRESTARTER = "Anythin' you wanna tell me about that fire, kiddo?",
        },
        WOODIE =
        {
            GENERIC = "You down ta chop some trees for me later, %s?",
            ATTACKER = "Watch where you're swingin' that thing, %s!",
            MURDERER = "Yikes! Axe murderer!",
            REVIVER = "You're a good, honest guy, %s.",
            GHOST = "You're fine, %s, I've seen worse.",
            BEAVER = "Well ain't that somethin'.",
            BEAVERGHOST = "You're just a walkin' disaster, ain'tcha, %s?",
            MOOSE = "Is this normal for you folks up North?",
            MOOSEGHOST = "I'll getcha a heart, hold yer horses... er, mooses?",
            GOOSE = "Don't even think about goosin' me!",
            GOOSEGHOST = "Well if this ain't a fine feathered mess.",
            FIRESTARTER = "You're gonna start a forest fire, %s!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "How's life treatin' ya, grams?",
            ATTACKER = "Yeesh, that ol' librarian packs a punch!",
            MURDERER = "Watch out! Grams is on a rampage!",
            REVIVER = "Don't worry grams, I won't read too much into it. Ha!",
            GHOST = "You're a tough one, %s, I'll give ya that.",
            FIRESTARTER = "A fire? Here I thought you were responsible, grams.",
        },
        WES =
        {
            GENERIC = "Don't worry %s, I can talk enough for two. Ha!",
            ATTACKER = "Didn't know ya had it in ya, %s!",
            MURDERER = "Killer mime! I'll have nightmares tonight!",
            REVIVER = "Thanks for the assist, %s.",
            GHOST = "Let's getcha back on your feet, %s.",
            FIRESTARTER = "You responsible for that fire there, %s?",
        },
        WEBBER =
        {
            GENERIC = "How's life treating ya, kiddo?",
            ATTACKER = "Yeesh, kid, dial it back!",
            MURDERER = "Killer spider! Get it!",
            REVIVER = "You did good, kid.",
            GHOST = "You'll be fine, kid, yer a boxer.",
            FIRESTARTER = "Alright, %s. Why'd ya set the fire?",
        },
        WATHGRITHR =
        {
            GENERIC = "Hey, %s! Arm wrestle rematch later?",
            ATTACKER = "Woah! Watch that right hook, %s!",
            MURDERER = "Takin' the warrior thing too far, %s!",
            REVIVER = "That was good work there, %s.",
            GHOST = "Well that just won't do at all!",
            FIRESTARTER = "Quit startin' fires, %s!",
        },
        WINONA =
        {
            GENERIC = "That's a good lookin' gal!",
            ATTACKER = "Ooo, I'm gonna disassemble you.",
            MURDERER = "Pfft! I'd never murder so openly!",
            REVIVER = "I owe ya one, %s.",
            GHOST = "That is not a good look on you, %s.",
            FIRESTARTER = "Haven't we lost enough to fires, %s?",
        },
        WORTOX =
        {
            GENERIC = "Hey, %s! Heard any good jokes lately?",
            ATTACKER = "Keep them claws to yourself, how about?!",
            MURDERER = "Look out! %s is positively demonic!",
            REVIVER = "Thanks for the assist there, %s.",
            GHOST = "Oof! You need a hand there, %s?",
            FIRESTARTER = "Were you plannin' on putting that fire out?",
        },
        WORMWOOD =
        {
            GENERIC = "%s! How ya doin', ya big bean sprout?",
            ATTACKER = "Yer on thin ice there, %s.",
            MURDERER = "Time to roll up my sleeves and pluck a few weeds!",
            REVIVER = "Keep up the good work there, bucko.",
            GHOST = "You're not slackin' off, are ya?",
            FIRESTARTER = "Watch where you're lightin' them fires!",
        },
        WARLY =
        {
            GENERIC = "Hey, %s! Got anything tasty for me?",
            ATTACKER = "Watch where you're throwin' them oven mitts!",
            MURDERER = "Killer chef! Get'em!",
            REVIVER = "You're a real pal, %s.",
            GHOST = "Missed your snack break, didja %s?",
            FIRESTARTER = "I'm sure %s knows how to handle grease fires.",
        },

        WURT =
        {
            GENERIC = "Hey there kiddo, how's it going?",
            ATTACKER = "Sure you wanna do that, kiddo?",
            MURDERER = "I gave ya the benefit of the doubt, but that's it!",
            REVIVER = "Whew, not bad, kid!",
            GHOST = "Don't you worry, I'll fix ya right up.",
            FIRESTARTER = "Hey, who let you play with that?!",
        },

        WALTER =
        {
            GENERIC = "Hey, %s! Caught any interestin' bugs lately?",
            ATTACKER = "You better simmer down, %s!",
            MURDERER = "No murderer's gettin' away on my watch!",
            REVIVER = "Thanks kid, you really got the helpfulness thing down pat!",
            GHOST = "Hey %s, no slacking! We've got lots to do!",
            FIRESTARTER = "That ain't safe, %s.",
        },

        WANDA =
        {
            GENERIC = "Hey, %s! Keepin' busy?",
            ATTACKER = "Hey, what's got you so riled up, %s?",
            MURDERER = "Don't think I'll pull my punches just cause you're an old lady sometimes!",
            REVIVER = "Thanks for givin' me a hand, %s!",
            GHOST = "Oh yikes, that's no good.",
            FIRESTARTER = "Mind letting me in on why you're doin' that, %s?",
        },

        WONKEY =
        {
            GENERIC = "What a sweet lil monkey.",
            ATTACKER = "Yeesh, calm down there fella!",
            MURDERER = "Yikes, guess yer a wild animal after all.",
            REVIVER = "You're a helpful monkey aren'tcha?",
            GHOST = "Got yourself in quite the mess now didn'tcha?",
            FIRESTARTER = "How'd that monkey manage to start a fire?!",
        },

        MIGRATION_PORTAL =
        {
        --    GENERIC = "If I had any friends, this could take me to them.",
        --    OPEN = "If I step through, will I still be me?",
        --    FULL = "It seems to be popular over there.",
        },
        GLOMMER =
        {
            GENERIC = "Check out the peepers on this guy.",
            SLEEPING = "He deserves the break.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "That's one big flower.",
            DEAD = "Did we not water it enough?",
        },
        GLOMMERWINGS = "You can see right through'em.",
        GLOMMERFUEL = "Doesn't look useful.",
        BELL = "There's always a stampede when the quittin' bell rings.",
        STATUEGLOMMER =
        {
            GENERIC = "One weird sculpture.",
            EMPTY = "The materials were worth more than the statue.",
        },

        LAVA_POND_ROCK = "That... is a rock.",

		WEBBERSKULL = "I swear the kid'd lose his head if it weren't... wait.",
		WORMLIGHT = "It glows just as much on the way out, lemme tell you.",
		WORMLIGHT_LESSER = "This one's a bit shrivelly.",
		WORM =
		{
		    PLANT = "Nothing out of the ordinary.",
		    DIRT = "Mhm. That's dirt!",
		    WORM = "That's a huge worm!",
		},
        WORMLIGHT_PLANT = "Nothing out of the ordinary.",
		MOLE =
		{
			HELD = "I love it.",
			UNDERGROUND = "Dutiful little miner.",
			ABOVEGROUND = "Taking a break from the mines?",
		},
		MOLEHILL = "The excavation crew's down there.",
		MOLEHAT = "A real strange contraption.",

		EEL = "You're looking a little eel. Ha!",
		EEL_COOKED = "I'll eat anything once.",
		UNAGI = "Fancy eats.",
		EYETURRET = "That's a fine piece of work.",
		EYETURRET_ITEM = "Lemme assemble it.",
		MINOTAURHORN = "That's a doozy!",
		MINOTAURCHEST = "Maybe there's loot inside.",
		THULECITE_PIECES = "Just needs a spit shine.",
		POND_ALGAE = "Ha! Gross.",
		GREENSTAFF = "It's a hard work destroyer.",
		GIFT = "My presence is a gift. Ha.",
        GIFTWRAP = "I could wrap stuff up real nice.",
		POTTEDFERN = "That's my kind of decor. Simple.",
        SUCCULENT_POTTED = "It's in a pot now.",
		SUCCULENT_PLANT = "This plant don't give up easy.",
		SUCCULENT_PICKED = "It's been picked.",
		SENTRYWARD = "Someone's got their eye on me.",
        TOWNPORTAL =
        {
			GENERIC = "It runs on \"magic\" instead of electricity.",
			ACTIVE = "Rarin' to go.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "It's uh, a rock. Mhm.",
			ACTIVE = "Let's get a move on.",
		},
        WETPAPER = "Is something written on it?",
        WETPOUCH = "Hefty.",
        MOONROCK_PIECES = "That's... strange.",
        MOONBASE =
        {
            GENERIC = "I don't think it's done yet.",
            BROKEN = "In need of a good fixin'!",
            STAFFED = "Job well done! Now what?",
            WRONGSTAFF = "Hm. This wasn't assembled right.",
            MOONSTAFF = "Moonlight's good for the complexion, hey?",
        },
        MOONDIAL =
        {
			GENERIC = "Must be broke. I can still see the moon.",
			NIGHT_NEW = "Brand spanking new moon.",
			NIGHT_WAX = "It's waxing.",
			NIGHT_FULL = "Full as can be.",
			NIGHT_WANE = "It's waning.",
			CAVE = "It was impractical to build this here.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "Why do I get the feeling something's watchin' me...",
        },
		THULECITE = "I love working with new materials.",
		ARMORRUINS = "Not a bad piece of work.",
		ARMORSKELETON = "A bit creepy, isn't it?",
		SKELETONHAT = "Makes me a little uneasy. Heh heh...",
		RUINS_BAT = "This thulecite stuff is incredible!",
		RUINSHAT = "Transforms the wearer into the \"King of Snoot\".",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Nothing out of place here.",
            WARN = "I feel uneasy for some reason.",
            WAXING = "The air's all prickly.",
            STEADY = "It can't possibly get worse.",
            WANING = "My head's starting to clear a bit.",
            DAWN = "I'm feeling much better.",
            NOMAGIC = "Things seem pretty normal.",
		},
		BISHOP_NIGHTMARE = "You look awful!",
		ROOK_NIGHTMARE = "Get a load of this spalder.",
		KNIGHT_NIGHTMARE = "You're in rough shape, hey?",
		MINOTAUR = "I've had about enough of terrible beasts!",
		SPIDER_DROPPER = "That's a nasty looking spider!",
		NIGHTMARELIGHT = "I regret poking my nose so far down here.",
		NIGHTSTICK = "Electricity at my fingertips.",
		GREENGEM = "Now that's a proper gem.",
		MULTITOOL_AXE_PICKAXE = "That's really not my forte.",
		ORANGESTAFF = "For people who fear good, honest work.",
		YELLOWAMULET = "Useful little tool.",
		GREENAMULET = "We could be good friends, you and I.",
		SLURPERPELT = "That's WAY too fuzzy.",

		SLURPER = "It's just a mouth!",
		SLURPER_PELT = "That's WAY too fuzzy.",
		ARMORSLURPER = "So tight I barely remember the gnawing hunger!",
		ORANGEAMULET = "For those with a lackluster work ethic.",
		YELLOWSTAFF = "I'm not fully grasping this whole \"magic\" thing.",
		YELLOWGEM = "I like gems best before they're cut.",
		ORANGEGEM = "I don't like it.",
        OPALSTAFF = "Did it just get chillier?",
        OPALPRECIOUSGEM = "Pretty! Pretty useless.",
        TELEBASE =
		{
			VALID = "Fully operational.",
			GEMS = "Still gotta tinker with it a bit.",
		},
		GEMSOCKET =
		{
			VALID = "Ready for a test run!",
			GEMS = "Still gotta tinker with it a bit.",
		},
		STAFFLIGHT = "No time for star gazin'.",
        STAFFCOLDLIGHT = "That's real pretty.",

        ANCIENT_ALTAR = "Some incredible stuff could be assembled here.",

        ANCIENT_ALTAR_BROKEN = "Needs a good fixin'.",

        ANCIENT_STATUE = "I'd never wanna meet one in person.",

        LICHEN = "Not to my lichen. Ha!",
		CUTLICHEN = "Not to my lichen. Ha!",

		CAVE_BANANA = "Everything since I got here has been bananas.",
		CAVE_BANANA_COOKED = "Caramelized banana's the tops.",
		CAVE_BANANA_TREE = "That's, uh, a banana tree.",
		ROCKY = "Easy there, slugger!",

		COMPASS =
		{
			GENERIC="I'm pretty good with directions.",
			N = "South.",
			S = "North.",
			E = "West.",
			W = "East.",
			NE = "Southwest",
			SE = "Northwest",
			NW = "Southeast",
			SW = "Northeast",
		},

        HOUNDSTOOTH = "Sure hope no one comes back for it.",
        ARMORSNURTLESHELL = "Go ahead, give'it a punch.",
        BAT = "Flyin' rodent.",
        BATBAT = "Ha! Clever.",
        BATWING = "Surprisingly meaty.",
        BATWING_COOKED = "Meat's meat.",
        BATCAVE = "I'm gonna leave that right alone.",
        BEDROLL_FURRY = "Better to hit the fur than the hay.",
        BUNNYMAN = "You really oughta get some sun.",
        FLOWER_CAVE = "Woah! It doesn't even need electricity!",
        GUANO = "What? We all do it.",
        LANTERN = "Who'd want a non-electric lamp?",
        LIGHTBULB = "Not at all like the lightbulbs I'm used to.",
        MANRABBIT_TAIL = "This piece fell off. Shoddy craftsmanship.",
        MUSHROOMHAT = "Really?",
        MUSHROOM_LIGHT2 =
        {
            ON = "It lights up, even without filament.",
            OFF = "Is there an \"on\" switch?",
            BURNT = "Roasted.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "How's it work without circuitry?",
            OFF = "Where's the plug?",
            BURNT = "Roasted.",
        },
        SLEEPBOMB = "An unethical weapon, plain and simple.",
        MUSHROOMBOMB = "Fire in the hole!",
        SHROOM_SKIN = "A weird and not too welcome texture.",
        TOADSTOOL_CAP =
        {
            EMPTY = "Hole lotta nothing.",
            INGROUND = "Something's in there.",
            GENERIC = "I got this.",
        },
        TOADSTOOL =
        {
            GENERIC = "I don't got this!",
            RAGE = "He's tougher than he looks... but so am I!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Now that's a big mushroom!",
            BURNT = "That seemed like a waste.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "It's huge!",
            BLOOM = "Whew. That's an odor.",
            ACIDCOVERED = "What is that nasty stench?",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "That's a big mushroom!",
            BLOOM = "Stink.",
            ACIDCOVERED = "What is that nasty stench?",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "I guess they grow better down here?",
            BLOOM = "Not a fan of the smell.",
            ACIDCOVERED = "What is that nasty stench?",
        },
        MUSHTREE_TALL_WEBBED =
        {
            GENERIC = "There's spiders in the crawlspace.",
            ACIDCOVERED = "What is that nasty stench?",
        },
        SPORE_TALL =
        {
            GENERIC = "I've breathed in worse stuff at work.",
            HELD = "Never hurts to have extra light.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "I've breathed in worse stuff at work.",
            HELD = "Never hurts to have extra light.",
        },
        SPORE_SMALL =
        {
            GENERIC = "I've breathed in worse stuff at work.",
            HELD = "Never hurts to have extra light.",
        },
        RABBITHOUSE =
        {
            GENERIC = "How'd they build these with no thumbs?",
            BURNT = "Welp.",
        },
        SLURTLE = "Just don't seem right.",
        SLURTLE_SHELLPIECES = "Broke, but I might salvage something useful.",
        SLURTLEHAT = "Gotta protect my noggin! I keep my ideas in there.",
        SLURTLEHOLE = "There's something gross in there.",
        SLURTLESLIME = "I hock those up after a long day at the factory.",
        SNURTLE = "Get along, little snurtle.",
        SPIDER_HIDER = "You know I can see you, right?",
        SPIDER_SPITTER = "Pfft, I can spit further than that!",
        SPIDERHOLE = "A rock filled with spiders. Great.",
        SPIDERHOLE_ROCK = "A rock filled with spiders. Great.",
        STALAGMITE = "Yep, yep. It's a rock.",
        STALAGMITE_TALL = "Ah! A rock.",

        TURF_CARPETFLOOR = "That's a chunk of ground.",
        TURF_CHECKERFLOOR = "That's a chunk of ground.",
        TURF_DIRT = "That's a chunk of ground.",
        TURF_FOREST = "That's a chunk of ground.",
        TURF_GRASS = "That's a chunk of grassy ground.",
        TURF_MARSH = "That's a chunk of squishy ground.",
        TURF_METEOR = "That's a chunk of fancy ground.",
        TURF_PEBBLEBEACH = "That's a chunk of fancy ground.",
        TURF_ROAD = "That's a chunk of road.",
        TURF_ROCKY = "That's a chunk of rocky ground.",
        TURF_SAVANNA = "That's a chunk of ground.",
        TURF_WOODFLOOR = "That's a chunk of ground.",

		TURF_CAVE="That's a chunk of mineshaft.",
		TURF_FUNGUS="That's a chunk of weird ground.",
		TURF_FUNGUS_MOON = "That's a chunk of weird ground.",
		TURF_ARCHIVE = "That's a well made chunk of ground.",
		TURF_SINKHOLE="That's a chunk of ground.",
		TURF_UNDERROCK="That's a chunk of ground.",
		TURF_MUD="That's a chunk of muddy ground.",

		TURF_DECIDUOUS = "That's a chunk of ground.",
		TURF_SANDY = "That's a chunk of sandy ground.",
		TURF_BADLANDS = "That's a chunk of ground.",
		TURF_DESERTDIRT = "That's a chunk of ground.",
		TURF_FUNGUS_GREEN = "That's a chunk of weird ground.",
		TURF_FUNGUS_RED = "That's a chunk of weird ground.",
		TURF_DRAGONFLY = "That's a chunk of fancy ground.",

        TURF_SHELLBEACH = "That's a chunk of sandy ground.",

		TURF_RUINSBRICK = "That's a chunk of ground.",
		TURF_RUINSBRICK_GLOW = "That's a chunk of ground.",
		TURF_RUINSTILES = "That's a chunk of ground.",
		TURF_RUINSTILES_GLOW = "That's a chunk of ground.",
		TURF_RUINSTRIM = "That's a chunk of ground.",
		TURF_RUINSTRIM_GLOW = "That's a chunk of ground.",

        TURF_MONKEY_GROUND = "That's a chunk of sandy ground.",

        TURF_CARPETFLOOR2 = "That's a real dramatic chunk of ground.",
        TURF_MOSAIC_GREY = "That's a chunk of ground.",
        TURF_MOSAIC_RED = "That's a chunk of ground.",
        TURF_MOSAIC_BLUE = "That's a chunk of ground.",

        TURF_BEARD_RUG = "That's sure makin' do with what you have.",

		POWCAKE = "Gotta eat what you can around here.",
        CAVE_ENTRANCE = "Into the depths!",
        CAVE_ENTRANCE_RUINS = "Is it wise to go deeper?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Nah, I don't want blacklung.",
            OPEN = "Another day, another creepy cave.",
            FULL = "They're at capacity down there.",
        },
        CAVE_EXIT =
        {
            GENERIC = "I don't need fresh air.",
            OPEN = "I barely remember what the surface looks like.",
            FULL = "Nah, it's packed up there.",
        },

		MAXWELLPHONOGRAPH = "I prefer blues.",--single player
		BOOMERANG = "It's great at comebacks. Ha!",
		PIGGUARD = "You don't look so tough.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "How are you, boo?",
                "How are you, boo?",
            },
            LEVEL2 =
            {
                "How are you, boo?",
                "How are you, boo?",
            },
            LEVEL3 =
            {
                "How are you, boo?",
                "How are you, boo?",
            },
		},
		ADVENTURE_PORTAL = "I ain't jumping willy-nilly through strange portals!",
		AMULET = "Jewelry ain't really my thing.",
		ANIMAL_TRACK = "Something tasty passed through here.",
		ARMORGRASS = "Not at all useful.",
		ARMORMARBLE = "Protects your inner workings.",
		ARMORWOOD = "Punch me! It does nothing! Ha!",
		ARMOR_SANITY = "Soothingly unsettling.",
		ASH =
		{
			GENERIC = "Sooty.",
			REMAINS_GLOMMERFLOWER = "Burnt bits of big ol' buzzer.",
			REMAINS_EYE_BONE = "Burnt up eye stick.",
			REMAINS_THINGIE = "That was a... Y'know! A thing.",
		},
		AXE = "I was never the \"woodsy\" type.",
		BABYBEEFALO =
		{
			GENERIC = "You're not too young to work.",
		    SLEEPING = "You're too young to be lazy.",
        },
        BUNDLE = "That oughta keep everything nice and fresh.",
        BUNDLEWRAP = "We could wrap stuff up for later.",
		BACKPACK = "I don't mind playing pack mule.",
		BACONEGGS = "A hearty breakfast for a full day's work.",
		BANDAGE = "Takes care of workplace injuries.",
		BASALT = "Great, it's a rock.", --removed
		BEARDHAIR = "Ha! Disgusting.",
		BEARGER = "Bring it on, ya big lug!",
		BEARGERVEST = "One seriously cozy vest.",
		ICEPACK = "Keeps drinks cool until breaktime.",
		BEARGER_FUR = "Real soothing to run your fingers through.",
		BEDROLL_STRAW = "Gonna hit the hay. Literally.",
		BEEQUEEN = "It's the queen of bees!",
		BEEQUEENHIVE =
		{
			GENERIC = "Sticky. I'd rather not walk on it.",
			GROWING = "I swear that thing's gotten bigger.",
		},
        BEEQUEENHIVEGROWN = "Yeesh! I'd take a hammer to that.",
        BEEGUARD = "Monarchy is an outdated ruling system!",
        HIVEHAT = "Snoot city.",
        MINISIGN =
        {
            GENERIC = "Cutesy little drawing.",
            UNDRAWN = "What good's a blank sign?",
        },
        MINISIGN_ITEM = "I hate handmade stuff.",
		BEE =
		{
			GENERIC = "She's an incredible worker.",
			HELD = "Workers gotta look out for one another.",
		},
		BEEBOX =
		{
			READY = "Excellent work, bees!",
			FULLHONEY = "Excellent work, bees!",
			GENERIC = "It's like an assembly line in there. Busy!",
			NOHONEY = "Where's that stellar work ethic, bees?!",
			SOMEHONEY = "You've been working hard.",
			BURNT = "Factory fire!",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Lookit all that fungus.",
			LOTS = "Looks like a pretty good yield.",
			SOME = "We've got our first mushrooms!",
			EMPTY = "Nothing yet.",
			ROTTEN = "Not much use with a dead log.",
			BURNT = "All burned up.",
			SNOWCOVERED = "It's real cold out.",
		},
		BEEFALO =
		{
			FOLLOWER = "Looks like I made a friend.",
			GENERIC = "Heh. Big lug.",
			NAKED = "Ha! That's just vulgar.",
			SLEEPING = "Lazy.",
            --Domesticated states:
            DOMESTICATED = "We're friends now.",
            ORNERY = "Rein in that attitude before I rein in you!",
            RIDER = "Wow! You're in top form!",
            PUDGY = "You're getting soft!",
            MYPARTNER = "We're buddies!",
		},

		BEEFALOHAT = "Seem secretive.",
		BEEFALOWOOL = "Smelly, but warm.",
		BEEHAT = "Respecting bees means respecting stingers.",
        BEESWAX = "It smells kinda alright.",
		BEEHIVE = "Hard at work.",
		BEEMINE = "Sounds like the hum of an engine.",
		BEEMINE_MAXWELL = "That guy's got no concern for others. Pfft.",--removed
		BERRIES = "A handful of loose berries.",
		BERRIES_COOKED = "A bit charred in places, but I don't mind.",
        BERRIES_JUICY = "They're so juicy!",
        BERRIES_JUICY_COOKED = "They're still pretty darn juicy.",
		BERRYBUSH =
		{
			BARREN = "Needs something from a beast's backside.",
			WITHERED = "You've obviously never worked a boiler room.",
			GENERIC = "Can I eat those?",
			PICKED = "Picked it right clean.",
			DISEASED = "Maybe you oughta take a sick day...",--removed
			DISEASING = "Yeuch! Is it supposed to smell like that?",--removed
			BURNING = "Not much I can do now.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Totally pooped. Or unpooped?",
			WITHERED = "Pssh. This heat's nothing.",
			GENERIC = "Looks tasty. Hope they're not poison.",
			PICKED = "Picked it right clean.",
			DISEASED = "Maybe you oughta take a sick day...",--removed
			DISEASING = "Yeuch! Is it supposed to smell like that?",--removed
			BURNING = "Not much I can do now.",
		},
		BIGFOOT = "At least it doesn't have steel-toed workboots!",--removed
		BIRDCAGE =
		{
			GENERIC = "That's some proper metalwork.",
			OCCUPIED = "She was just a patsy.",
			SLEEPING = "Why are you tired? Your life is so cushy.",
			HUNGRY = "Hey! Is it my turn to feed the bird?",
			STARVING = "This poor bird's a bag of bones.",
			DEAD = "I think it was my turn to feed her.",
			SKELETON = "Let's uh... just sweep that under the rug.",
		},
		BIRDTRAP = "Birds of a feather get trapped together.",
		CAVE_BANANA_BURNT = "Big ol' burnt banana tree.",
		BIRD_EGG = "Breakfast.",
		BIRD_EGG_COOKED = "I always get bits of shell in there by accident.",
		BISHOP = "How industrial.",
		BLOWDART_FIRE = "Simple, but effective.",
		BLOWDART_SLEEP = "Inflicts the very worst thing... laziness.",
		BLOWDART_PIPE = "Ptoo!",
		BLOWDART_YELLOW = "I'm gonna shoot this at the bot's butt.",
		BLUEAMULET = "Now I don't have to take breaks to cool off.",
		BLUEGEM = "It's a gem. A gem that's blue.",
		BLUEPRINT =
		{
            COMMON = "Blueprint paper just smells right.",
            RARE = "Progress on paper!",
        },
        SKETCH = "What a nice drawing.",
		COOKINGRECIPECARD =
		{
			GENERIC = "I can't make heads or tails of it.",
		},
		BLUE_CAP = "Yep. Blue mushroom.",
		BLUE_CAP_COOKED = "Well, I don't THINK it's poison.",
		BLUE_MUSHROOM =
		{
			GENERIC = "It's some sorta blue mushroom.",
			INGROUND = "Lazy mushroom.",
			PICKED = "Got'er done.",
		},
		BOARDS = "Oh, the possibilities.",
		BONESHARD = "Whew. These got crunched real good.",
		BONESTEW = "Hearty.",
		BUGNET = "Wish we had mosquito netting.",
		BUSHHAT = "Just, y'know. Strap a bush on your head.",
		BUTTER = "This makes everything better.",
		BUTTERFLY =
		{
			GENERIC = "It has no work or responsibilities. Poor thing.",
			HELD = "How you doin' in there?",
		},
		BUTTERFLYMUFFIN = "Never liked having butterflies in my stomach.",
		BUTTERFLYWINGS = "There's no flight in their future.",
		BUZZARD = "It lives off the hard work of others.",

		SHADOWDIGGER = "Too lazy to do your own chores, Max?",
        SHADOWDANCER = "Now even his shadow is slackin' off.",

		CACTUS =
		{
			GENERIC = "Prickly.",
			PICKED = "Guess we know who won that one.",
		},
		CACTUS_MEAT_COOKED = "That seems a lot safer.",
		CACTUS_MEAT = "It's got a sharp taste. Ha!",
		CACTUS_FLOWER = "Much less prickly.",

		COLDFIRE =
		{
			EMBERS = "On its last legs.",
			GENERIC = "It's... cold? Somehow?",
			HIGH = "A good healthy blaze.",
			LOW = "Gonna go out soon.",
			NORMAL = "Seems good for now.",
			OUT = "That's that.",
		},
		CAMPFIRE =
		{
			EMBERS = "On its last legs.",
			GENERIC = "It'll last me the night, hopefully.",
			HIGH = "A good healthy blaze.",
			LOW = "Gonna go out soon.",
			NORMAL = "About as cozy as it gets out here.",
			OUT = "My sister was afraid of the dark.",
		},
		CANE = "It's no Tin Lizzie.",
		CATCOON = "She'll keep the rats outta the factory.",
		CATCOONDEN =
		{
			GENERIC = "We all gotta sleep.",
			EMPTY = "As abandoned as an old warehouse.",
		},
		CATCOONHAT = "Do I look like a fur trader?",
		COONTAIL = "Grab life by the tail.",
		CARROT = "Free food from the ground.",
		CARROT_COOKED = "Easier on the gums. Not that that matters.",
		CARROT_PLANTED = "Perfectly pluckable.",
		CARROT_SEEDS = "A handful of seeds.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Good place to kick your feet up, if nothin' else.",
			BURNING = "Welp.",
			BURNT = "It's okay. I'll assemble another.",
		},
		WATERMELON_SEEDS = "A handful of seeds.",
		CAVE_FERN = "Take a gander at this tiny fern!",
		CHARCOAL = "It gets everywhere.",
        CHESSPIECE_PAWN = "Nice hat.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Looks heavy.",
            STRUGGLE = "That ain't supposed to move.",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "Why the long face?",
            STRUGGLE = "That ain't supposed to move.",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "I'm not big on headgames.",
            STRUGGLE = "That ain't supposed to move.",
        },
        CHESSPIECE_MUSE = "I've got a bad feeling about this one.",
        CHESSPIECE_FORMAL = "It's BUSTed. Ha!",
        CHESSPIECE_HORNUCOPIA = "Ugh, don't remind me of food.",
        CHESSPIECE_PIPE = "It's got bubbles coming out the top.",
        CHESSPIECE_DEERCLOPS = "Ha. It looks kinda surprised, don't it?",
        CHESSPIECE_BEARGER = "Y'got a mean mug there, buddy.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "It looks like it's hollerin'.",
        },
        CHESSPIECE_DRAGONFLY = "My pals and I can't be beat.",
		CHESSPIECE_MINOTAUR = "What a stone-faced brute.",
        CHESSPIECE_BUTTERFLY = "I feel like it's lookin' at me.",
        CHESSPIECE_ANCHOR = "I'm fond'a this one.",
        CHESSPIECE_MOON = "That statue's moonin' me! HA!",
        CHESSPIECE_CARRAT = "Look at it, just lazing around!",
        CHESSPIECE_MALBATROSS = "It tried to mess with the wrong gal.",
        CHESSPIECE_CRABKING = "Hey Max, you guys have a lot in common!",
        CHESSPIECE_TOADSTOOL = "I built a stool once but it didn't look like that.",
        CHESSPIECE_STALKER = "I like 'em better when he's not stalkin' me.",
        CHESSPIECE_KLAUS = "Kinda makes me nostalgic.",
        CHESSPIECE_BEEQUEEN = "I wonder if I could sculpt a hat like that.",
        CHESSPIECE_ANTLION = "Looks so real, I can almost feel the earth rumblin'.",
        CHESSPIECE_BEEFALO = "Aw, it looks just like my beefalo.",
		CHESSPIECE_KITCOON = "I can't tell if this a great feat of engineering or a very stupid one. Either way, it sure is cute.",
		CHESSPIECE_CATCOON = "Aw, whatcha got there? ...Oh.",
        CHESSPIECE_MANRABBIT = "It doesn't look like he has a care in the world.",
        CHESSPIECE_GUARDIANPHASE3 = "A little too lifelike for my comfort.",
        CHESSPIECE_EYEOFTERROR = "An eye (statue) for an eye (monster)!",
        CHESSPIECE_TWINSOFTERROR = "A fresh pair of eyes is just what we needed around here!",
        CHESSPIECE_DAYWALKER = "It's so lifelike, I can almost smell the bad breath.",
        CHESSPIECE_DEERCLOPS_MUTATED = "She's almost a looker.",
        CHESSPIECE_WARG_MUTATED = "Now this is a pooch I could play with.",
        CHESSPIECE_BEARGER_MUTATED = "That was one ornery son of a beast.",
        CHESSPIECE_SHARKBOI = "That shark was kind of a jerk.",

        CHESSJUNK1 = "A heap of spare parts.",
        CHESSJUNK2 = "A heap of spare parts.",
        CHESSJUNK3 = "A heap of spare parts.",
		CHESTER = "Who's the cutest lil toolbox?",
		CHESTER_EYEBONE =
		{
			GENERIC = "Toolbox controls.",
			WAITING = "Something upset it.",
		},
		COOKEDMANDRAKE = "Dead as several doornails.",
		COOKEDMEAT = "Cooked meat, ready to eat.",
		COOKEDMONSTERMEAT = "It's still purple in the middle.",
		COOKEDSMALLMEAT = "Well, a morsel's a morsel.",
		COOKPOT =
		{
			COOKING_LONG = "Still got a bit of a wait.",
			COOKING_SHORT = "Almost!",
			DONE = "Soup's on!",
			EMPTY = "I make a mean stew.",
			BURNT = "You guys like gristle, right?",
		},
		CORN = "I talked its ear off. Ha!",
		CORN_COOKED = "Tell me if I get'em stuck in my teeth.",
		CORN_SEEDS = "A handful of seeds.",
        CANARY =
		{
			GENERIC = "That brings back memories.",
			HELD = "I should take it with me if I go spelunking.",
		},
        CANARY_POISONED = "Everybody out of the mineshaft!!",

		CRITTERLAB = "Come on out, don't be shy.",
        CRITTER_GLOMLING = "You're pretty cute for a giant bug, hey?",
        CRITTER_DRAGONLING = "You're pretty swell, for a tiny monstrosity.",
		CRITTER_LAMB = "You're just a fluffball on legs!",
        CRITTER_PUPPY = "Pups love you no matter who you are.",
        CRITTER_KITTEN = "I'm going to spoil you rotten.",
        CRITTER_PERDLING = "Hey there, feathers.",
		CRITTER_LUNARMOTHLING = "You sure are fragile, aren'tcha lil fella?",

		CROW =
		{
			GENERIC = "Looks a bit flighty. Ha!",
			HELD = "Hauling you around is murder on the feet! Ha!",
		},
		CUTGRASS = "A fire waiting to happen.",
		CUTREEDS = "Doesn't hold a candle to steel pipe.",
		CUTSTONE = "Prepped and ready for the assembly line.",
		DEADLYFEAST = "Food poisoning and a half.", --unimplemented
		DEER =
		{
			GENERIC = "A bouncy fluffster.",
			ANTLER = "Looks like she has a new addition.",
		},
        DEER_ANTLER = "What am I supposed to do with this?",
        DEER_GEMMED = "Looks dangerous!",
		DEERCLOPS = "Don't even think about it, you dumb lug!",
		DEERCLOPS_EYEBALL = "You lookin' at me? Are YOU lookin' at ME?",
		EYEBRELLAHAT =	"Nice and dry underneath.",
		DEPLETED_GRASS =
		{
			GENERIC = "It's closed for business.",
		},
        GOGGLESHAT = "I hate fashion.",
        DESERTHAT = "Helps you see, see?",
        ANTLIONHAT = "It sure makes landscaping a breeze!",
		DEVTOOL = "What an incredible tool!",
		DEVTOOL_NODEV = "Lazy builders.",
		DIRTPILE = "Time to get my hands dirty.",
		DIVININGROD =
		{
			COLD = "S'not picking anything up.", --singleplayer
			GENERIC = "I'm probably one of the few left that knows how to use these.", --singleplayer
			HOT = "I'm sitting right on top of... something.", --singleplayer
			WARM = "It's getting something.", --singleplayer
			WARMER = "Gonna hit paydirt any second now.", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "Just like in the bossman's workshop.", --singleplayer
			READY = "I guess it wants the Voxola?", --singleplayer
			UNLOCKED = "At least I assembled it right.", --singleplayer
		},
		DIVININGRODSTART = "That's a Voxola! What's it doing here?", --singleplayer
		DRAGONFLY = "Get a load of this flying welding torch!",
		ARMORDRAGONFLY = "Bit flashy, hey?",
		DRAGON_SCALES = "Showy.",
		DRAGONFLYCHEST =
		{
			GENERIC = "For the snootiest of snoots.",
            UPGRADED_STACKSIZE = "Snooty, but durable.",
		},
		DRAGONFLYFURNACE =
		{
			HAMMERED = "We oughta fix that.",
			GENERIC = "Pretty fancy for a heater.", --no gems
			NORMAL = "Could use a bit more kick.", --one gem
			HIGH = "That's a proper furnace.", --two gems
		},

        HUTCH = "You wanna be my toolbox, lil guy?",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Who left you out here all alone, hey?",
            WAITING = "Yeesh. Fishfry.",
        },
		LAVASPIT =
		{
			HOT = "Woah! Hot potato!",
			COOL = "Just a rock, now.",
		},
		LAVA_POND = "Lava!",
		LAVAE = "I'm gonna squish that!",
		LAVAE_COCOON = "We could probably wake it back up.",
		LAVAE_PET =
		{
			STARVING = "You need some meat on those bones. Do you have bones?",
			HUNGRY = "Let's fatten you up.",
			CONTENT = "You're a happy little fellow.",
			GENERIC = "Seems friendly enough.",
		},
		LAVAE_EGG =
		{
			GENERIC = "Maybe we shouldn't hatch this.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Looks chilly.",
			COMFY = "It's feeling right as rain.",
		},
		LAVAE_TOOTH = "Aw. That's a baby tooth.",

		DRAGONFRUIT = "Snooty fruit.",
		DRAGONFRUIT_COOKED = "Cooked the snoot right out of it.",
		DRAGONFRUIT_SEEDS = "A handful of seeds.",
		DRAGONPIE = "Where's the beef?",
		DRUMSTICK = "Can't say a raw drumstick sounds too appealing.",
		DRUMSTICK_COOKED = "Can't be beat.",
		DUG_BERRYBUSH = "I love getting my hands dirty.",
		DUG_BERRYBUSH_JUICY = "I'll replant that if no one else wants to.",
		DUG_GRASS = "Looks like some gardening's in order.",
		DUG_MARSH_BUSH = "Well it's not gonna replant itself.",
		DUG_SAPLING = "Needs replanting.",
		DURIAN = "Powerful stench! I respect that.",
		DURIAN_COOKED = "Whew! That'll put some hair on your hair.",
		DURIAN_SEEDS = "A handful of seeds.",
		EARMUFFSHAT = "I hate cold weather.",
		EGGPLANT = "Look how weird it is! Ha!",
		EGGPLANT_COOKED = "Did that make it better? I don't know.",
		EGGPLANT_SEEDS = "A handful of seeds.",

		ENDTABLE =
		{
			BURNT = "That's a shame.",
			GENERIC = "Pretty sure this one won't move.",
			EMPTY = "Sturdily built.",
			WILTED = "That bouquet's seen better days.",
			FRESHLIGHT = "I miss lamps.",
			OLDLIGHT = "That's not gonna last much longer.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "That's an impressive blaze.",
			BURNT = "Completely charred.",
			CHOPPED = "Done and done.",
			POISON = "Why does a tree need a mouth?!",
			GENERIC = "Another tree.",
		},
		ACORN = "Everything you need to build a tree.",
        ACORN_SAPLING = "This tree's still under construction.",
		ACORN_COOKED = "Looks edible. One way to find out!",
		BIRCHNUTDRAKE = "Shoo! Get outta here!",
		EVERGREEN =
		{
			BURNING = "That's an impressive blaze.",
			BURNT = "Completely charred.",
			CHOPPED = "As long as the job's done.",
			GENERIC = "Just a tree.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Impressive blaze.",
			BURNT = "Completely charred.",
			CHOPPED = "Glad that's over with.",
			GENERIC = "Yep. Definitely a tree.",
		},
		TWIGGYTREE =
		{
			BURNING = "That's an impressive blaze.",
			BURNT = "Completely charred.",
			CHOPPED = "Won't have to do that again for awhile.",
			GENERIC = "That's one skinny tree.",
			DISEASED = "Doesn't look great.", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Not even worth chopping.",
        TWIGGY_OLD = "Looks like that two-bit magician.",
		TWIGGY_NUT = "Belongs in the ground.",
		EYEPLANT = "Y'know? I'm not even gonna ask.",
		INSPECTSELF = "Who's that good-looking gal!",
		FARMPLOT =
		{
			GENERIC = "You reap whatcha sow.",
			GROWING = "Our hard work is paying off.",
			NEEDSFERTILIZER = "It needs a bit of a kick.",
			BURNT = "I hate seeing hard work wasted.",
		},
		FEATHERHAT = "Well la-dee-da.",
		FEATHER_CROW = "Not a whole lotta use for that.",
		FEATHER_ROBIN = "Kinda useless. Looks nice, anyway.",
		FEATHER_ROBIN_WINTER = "If only I had a cap to put it in.",
		FEATHER_CANARY = "That's not a good sign.",
		FEATHERPENCIL = "I've got ugly handwriting.",
        COOKBOOK = "Havin' a blueprint sure makes cooking easier!",
		FEM_PUPPET = "She doesn't look none too happy.", --single player
		FIREFLIES =
		{
			GENERIC = "Natural light, huh? Might be useful.",
			HELD = "I could think of a couple uses for these babies.",
		},
		FIREHOUND = "Get outta here, bucko!",
		FIREPIT =
		{
			EMBERS = "On its last legs.",
			GENERIC = "It's the pits out here.",
			HIGH = "Properly roaring.",
			LOW = "It's gonna go out soon.",
			NORMAL = "About as cozy as it gets out here.",
			OUT = "My sister was afraid of the dark.",
		},
		COLDFIREPIT =
		{
			EMBERS = "On its last legs.",
			GENERIC = "It makes cold fire? I don't quite get it.",
			HIGH = "Properly roaring.",
			LOW = "It's gonna go out soon.",
			NORMAL = "Doin' okay.",
			OUT = "Out, for now.",
		},
		FIRESTAFF = "This \"magic\" stuff's a safety hazard.",
		FIRESUPPRESSOR =
		{
			ON = "Witness the efficiency of the future!",
			OFF = "We should mass produce these things.",
			LOWFUEL = "Needs a top up.",
		},

		FISH = "I'd rather eat for a day than not at all.",
		FISHINGROD = "Not a bad way to unwind.",
		FISHSTICKS = "I've never seen a fish this shape before.",
		FISHTACOS = "That's some good eating.",
		FISH_COOKED = "I hate picking bones outta my teeth.",
		FLINT = "So archaic...",
		FLOWER =
		{
            GENERIC = "A bit cutesy.",
            ROSE = "Not sure how to feel about that...",
        },
        FLOWER_WITHERED = "That's how I feel after a long shift.",
		FLOWERHAT = "For getting dolled up.",
		FLOWER_EVIL = "I think I'll steer clear of that.",
		FOLIAGE = "Just a bunch of leaves.",
		FOOTBALLHAT = "Gotta protect the assets.",
        FOSSIL_PIECE = "No bones about it, that's a fossil. Ha!",
        FOSSIL_STALKER =
        {
			GENERIC = "Some more assembly required.",
			FUNNY = "That was not assembled correctly.",
			COMPLETE = "What is this a skeleton of?!",
        },
        STALKER = "That thing's terrifying!",
        STALKER_ATRIUM = "You got a bone to pick with me, bub? Ha!",
        STALKER_MINION = "I don't want that anywhere near me!",
        THURIBLE = "Smells kinda like gasoline.",
        ATRIUM_OVERGROWTH = "Don't think it's supposed to look like that.",
		FROG =
		{
			DEAD = "It croaked.",
			GENERIC = "Yep! That's a frog.",
			SLEEPING = "Shouldn't you be off hopping or something?",
		},
		FROGGLEBUNWICH = "It's really not as bad as it looks.",
		FROGLEGS = "Not glamorous, but I'll eat it.",
		FROGLEGS_COOKED = "Them's good eats.",
		FRUITMEDLEY = "Gotta get those vitamins, I guess.",
		FURTUFT = "Wouldn't mind lining my workboots with this stuff.",
		GEARS = "I'm a bit homesick.",
		GHOST = "I don't want nothing to do with that.",
		GOLDENAXE = "A shiny way to cut stuff down.",
		GOLDENPICKAXE = "A shiny way to smash up rocks.",
		GOLDENPITCHFORK = "I mean why not, hey?",
		GOLDENSHOVEL = "A little too snazzy for my taste.",
		GOLDNUGGET = "Gold! What a prospect.",
		GRASS =
		{
			BARREN = "Needs a little boost.",
			WITHERED = "It couldn't stand the heat.",
			BURNING = "Grass fire!",
			GENERIC = "That's some tall grass.",
			PICKED = "It's on break.",
			DISEASED = "You should see a doctor.", --unimplemented
			DISEASING = "Not lookin' too lush.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Is that lizard made of grass?",
			DISEASED = "I didn't know lizards could wilt.", --unimplemented
		},
		GREEN_CAP = "Yep. Green mushroom.",
		GREEN_CAP_COOKED = "Doesn't look TOO deadly.",
		GREEN_MUSHROOM =
		{
			GENERIC = "It's some sorta green mushroom.",
			INGROUND = "Lazy mushroom.",
			PICKED = "It's a mushroom hole.",
		},
		GUNPOWDER = "For when you need a big KABOOM!",
		HAMBAT = "Good fer a smackin'.",
		HAMMER = "And I know how to use it!",
		HEALINGSALVE = "Soothes minor cuts and scrapes.",
		HEATROCK =
		{
			FROZEN = "Brr! Like a chunk of ice.",
			COLD = "It's a little chilly.",
			GENERIC = "This is a good rock. A special rock.",
			WARM = "Tepid.",
			HOT = "Almost TOO hot.",
		},
		HOME = "They say you can't go home again.",
		HOMESIGN =
		{
			GENERIC = "I'll take this as a sign.",
            UNWRITTEN = "Just waiting for some scribbles.",
			BURNT = "Burnt to cinders.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "I'll take this as a sign.",
            UNWRITTEN = "Just waiting for some scribbles.",
			BURNT = "Burnt to cinders.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "I'll take this as a sign.",
            UNWRITTEN = "Just waiting for some scribbles.",
			BURNT = "Burnt to cinders.",
		},
		HONEY = "The sweet results of honest work.",
		HONEYCOMB = "Let's build a bee house.",
		HONEYHAM = "Think I could fit that whole thing in my mouth?",
		HONEYNUGGETS = "Not bad!",
		HORN = "Watch out for the business end!",
		HOUND = "Anyone got some rolled up newspaper?",
		HOUNDCORPSE =
		{
			GENERIC = "Kinda feel bad for the little fella.",
			BURNING = "Better safe than sorry.",
			REVIVING = "Yikes! Someone burn that thing, quick!",
		},
		HOUNDBONE = "It's covered in tooth marks.",
		HOUNDMOUND = "So that's where they're comin' from.",
		ICEBOX = "It's not factory standard.",
		ICEHAT = "There must be a more practical solution.",
		ICEHOUND = "Keep those fangs to yourself.",
		INSANITYROCK =
		{
			ACTIVE = "I can't begin to imagine how it works.",
			INACTIVE = "What on earth is that thing?",
		},
		JAMMYPRESERVES = "The sweet taste of good planning.",

		KABOBS = "Now that's my kind of cooking.",
		KILLERBEE =
		{
			GENERIC = "Stay back, bug!",
			HELD = "You can just calm right down.",
		},
		KNIGHT = "Incredible! Let me look at those gears!",
		KOALEFANT_SUMMER = "Hey! You look tasty!",
		KOALEFANT_WINTER = "Hey! You look tasty!",
		KOALEFANT_CARCASS = "Poor thing's dead as a doornail.",
		KRAMPUS = "Some sort of... festive devil?",
		KRAMPUS_SACK = "I could carry a whole warehouse in that thing!",
		LEIF = "The trees have eyes!!",
		LEIF_SPARSE = "Back off, you lumbering lumber!",
		LIGHTER  = "Neat little gizmo there.",
		LIGHTNING_ROD =
		{
			CHARGED = "All charged up and nowhere to go.",
			GENERIC = "That's one way to get electricity.",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "You and I are gonna get along.",
			CHARGED = "Electrifying! Ha!",
		},
		LIGHTNINGGOATHORN = "It's even more interesting up close.",
		GOATMILK = "I'm a growing gal, you know!",
		LITTLE_WALRUS = "Nice kilt.",
		LIVINGLOG = "Stop looking at me like that.",
		LOG =
		{
			BURNING = "I coulda built something with that.",
			GENERIC = "It's a hunk of wood.",
		},
		LUCY = "You're alright for an axe.",
		LUREPLANT = "That doesn't look right at all.",
		LUREPLANTBULB = "That is not a comforting texture!",
		MALE_PUPPET = "He doesn't look none too happy.", --single player

		MANDRAKE_ACTIVE = "This is exactly what having a little sister's like.",
		MANDRAKE_PLANTED = "That's a weird shrub.",
		MANDRAKE = "Dead as a doornail.",

        MANDRAKESOUP = "It's vegetable soup, now.",
        MANDRAKE_COOKED = "Dead as several doornails.",
        MAPSCROLL = "There's nothin' on it.",
        MARBLE = "This marble's real fancy.",
        MARBLEBEAN = "That couldn't possibly work.",
        MARBLEBEAN_SAPLING = "Uh, it's growing? Maybe?",
        MARBLESHRUB = "That came in pretty nicely.",
        MARBLEPILLAR = "Fancy.",
        MARBLETREE = "How does that work?",
        MARSH_BUSH =
        {
			BURNT = "Nothin' but cinders.",
            BURNING = "It's on fire.",
            GENERIC = "Gnarly little bush.",
            PICKED = "Gotta wait a bit.",
        },
        BURNT_MARSH_BUSH = "Right to a crisp.",
        MARSH_PLANT = "A tiny little plant.",
        MARSH_TREE =
        {
            BURNING = "Gone up in flames.",
            BURNT = "Looks brittle.",
            CHOPPED = "That's one down.",
            GENERIC = "Mhm. It's a tree.",
        },
        MAXWELL = "Well, you're a tall piece of work.",--single player
        MAXWELLHEAD = "You don't scare me.",--removed
        MAXWELLLIGHT = "How does that even work?",--single player
        MAXWELLLOCK = "Neat contraption. Can I take a look at it?",--single player
        MAXWELLTHRONE = "Who'd wanna to sit on THAT?",--single player
        MEAT = "Someone's eatin' good tonight!",
        MEATBALLS = "Don't mind if I do.",
        MEATRACK =
        {
            DONE = "Ready for eatin'.",
            DRYING = "It's well on its way.",
            DRYINGINRAIN = "Not gonna make much progress like that.",
            GENERIC = "A rack for drying meat.",
            BURNT = "Well, it's dry.",
            DONE_NOTMEAT = "Ready for eatin'.",
            DRYING_NOTMEAT = "It's well on its way.",
            DRYINGINRAIN_NOTMEAT = "Not gonna make much progress like that.",
        },
        MEAT_DRIED = "It'll last awhile like this.",
        MERM = "You sure are ugly!",
        MERMHEAD =
        {
            GENERIC = "I'd better hammer down that eyesore.",
            BURNT = "Hooboy, that's a powerful stench.",
        },
        MERMHOUSE =
        {
            GENERIC = "I could disassemble that.",
            BURNT = "A waste of building materials.",
        },
        MINERHAT = "I put that behind me.",
        MONKEY = "No monkeying around on the job.",
        MONKEYBARREL = "Ha! Smells like me after a full shift!",
        MONSTERLASAGNA = "Not sure meat's supposed to be that color.",
        FLOWERSALAD = "I guess a bunch of petals count as food.",
        ICECREAM = "Y'gotta eat it before it melts.",
        WATERMELONICLE = "A good treat for work breaks.",
        TRAILMIX = "All the energy you need for a long day at work.",
        HOTCHILI = "I'm tough enough to handle a little spice.",
        GUACAMOLE = "This green mush ain't bad!",
        MONSTERMEAT = "Hooboy! Is that even meat?",
        MONSTERMEAT_DRIED = "Drying didn't help none.",
        MOOSE = "Oh, mama!",
        MOOSE_NESTING_GROUND = "That's where the mom keeps her babies.",
        MOOSEEGG = "Animals don't build things well.",
        MOSSLING = "Don'tcha just wanna noogie it?",
        FEATHERFAN = "Too fancy.",
        MINIFAN = "Swirly.",
        GOOSE_FEATHER = "I could think of one or two uses for that, tops.",
        STAFF_TORNADO = "All bluster, no bite.",
        MOSQUITO =
        {
            GENERIC = "Once you've dealt with bedbugs, mosquitoes aren't so bad.",
            HELD = "Stop wriggling, it's gross.",
        },
        MOSQUITOSACK = "Ha. That's real gross.",
        MOUND =
        {
            DUG = "Just a hole now.",
            GENERIC = "Anything good in there, ya think?",
        },
        NIGHTLIGHT = "Creepy to the core.",
        NIGHTMAREFUEL = "I don't trust that stuff.",
        NIGHTSWORD = "Not too keen on touching that.",
        NITRE = "I got some plans in mind for that.",
        ONEMANBAND = "I ain't musically inclined.",
        OASISLAKE =
		{
			GENERIC = "Never seen such a clear lake before.",
			EMPTY = "There used to be water there.",
		},
        PANDORASCHEST = "Best not open that.",
        PANFLUTE = "Let's see if I can't play a little ditty.",
        PAPYRUS = "I don't have much use for that, personally.",
        WAXPAPER = "So waxy.",
        PENGUIN = "I don't mix well with the upper class.",
        PERD = "The light's on but no one's home.",
        PEROGIES = "You work up a mighty appetite at the factory.",
        PETALS = "Don't see a whole lotta use for these.",
        PETALS_EVIL = "They seem mean-spirited.",
        PHLEGM = "Please. I hock bigger loogies in my sleep.",
        PICKAXE = "Not my preferred kind of manual labor.",
        PIGGYBACK = "Makes everything smell like pig.",
        PIGHEAD =
        {
            GENERIC = "I should hammer down that eyesore.",
            BURNT = "What a waste of materials.",
        },
        PIGHOUSE =
        {
            FULL = "Fuller than a downtown tenement house.",
            GENERIC = "No way that's up to code.",
            LIGHTSOUT = "Hey! I just want some light!",
            BURNT = "That's a shame.",
        },
        PIGKING = "Those hooves've never seen a day of work.",
        PIGMAN =
        {
            DEAD = "That threw a wrench into his plans.",
            FOLLOWER = "Chummy fellow!",
            GENERIC = "Hey there, ya lug!",
            GUARD = "Don't want no trouble.",
            WEREPIG = "I have no idea what's going on!",
        },
        PIGSKIN = "The backside of an oinker.",
        PIGTENT = "Yeesh, smells ripe in there.",
        PIGTORCH = "Kitschy.",
        PINECONE = "That's a pine cone.",
        PINECONE_SAPLING = "It can handle itself from here.",
        LUMPY_SAPLING = "I don't know how it got here, but good on it.",
        PITCHFORK = "It's so... rural.",
        PLANTMEAT = "This is beyond confusing.",
        PLANTMEAT_COOKED = "It cooked up pretty good.",
        PLANT_NORMAL =
        {
            GENERIC = "It's a plant.",
            GROWING = "It's hard at work.",
            READY = "Good to go.",
            WITHERED = "It's a bit hot out.",
        },
        POMEGRANATE = "Eat that and you're stuck here forever!",
        POMEGRANATE_COOKED = "It does look pretty tempting.",
        POMEGRANATE_SEEDS = "A handful of seeds.",
        POND = "I can't see the bottom.",
        POOP = "Nothing to be ashamed of.",
        FERTILIZER = "Plants can't get enough.",
        PUMPKIN = "Hey there, pumpkin.",
        PUMPKINCOOKIE = "Gotta indulge sometimes, hey?",
        PUMPKIN_COOKED = "Not bad! Kind of sweet.",
        PUMPKIN_LANTERN = "It's childish, but in a nice way.",
        PUMPKIN_SEEDS = "A handful of seeds.",
        PURPLEAMULET = "It's, uh, a purple necklace.",
        PURPLEGEM = "A little snooty gem.",
        RABBIT =
        {
            GENERIC = "Running after it would be pointless.",
            HELD = "It's skittish.",
        },
        RABBITHOLE =
        {
            GENERIC = "Lots of excavation work around here.",
            SPRING = "Guess it wasn't structurally sound.",
        },
        RAINOMETER =
        {
            GENERIC = "That's a mighty fine gadget.",
            BURNT = "Must fire take everything I love?",
        },
        RAINCOAT = "Very practical.",
        RAINHAT = "Dry as a daisy. That's the phrase, right?",
        RATATOUILLE = "Lots of fresh veggies.",
        RAZOR = "Never hurts to have more tools.",
        REDGEM = "Glitter doesn't really appeal to me.",
        RED_CAP = "Let Max try it first.",
        RED_CAP_COOKED = "Not too interested in trying that.",
        RED_MUSHROOM =
        {
            GENERIC = "It's some sorta red mushroom.",
            INGROUND = "Lazy mushroom.",
            PICKED = "Picked clean. Gotta wait.",
        },
        REEDS =
        {
            BURNING = "Uh...",
            GENERIC = "Looks like they're hollow inside.",
            PICKED = "It's on break.",
        },
        RELIC = "Hand craftsmanship is old hat. Mass production is the future.",
        RUINS_RUBBLE = "In dire need of repairs. Good thing I'm here.",
        RUBBLE = "The foundation's crumbling.",
        RESEARCHLAB =
        {
            GENERIC = "Rickety, but I can use it to build things.",
            BURNT = "Can I make the next one?",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "I guess proximity activates the whirlygigs?",
            BURNT = "Now we get to make another!",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "Not sure how it works, but I'm gonna find out.",
            BURNT = "Let's make another.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "Why do we even have that lever?!",
            BURNT = "The next one we make'll be better.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "Looks just like that egghead! Ha!",
            BURNT = "That ain't coming back to life.",
        },
        RESURRECTIONSTONE = "Does anyone actually stay dead around here?",
        ROBIN =
        {
            GENERIC = "She ain't bothering no one.",
            HELD = "She feels real fragile in my hands.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "She ain't bothering no one.",
            HELD = "You're just feather and bone.",
        },
        ROBOT_PUPPET = "They don't look none too happy.", --single player
        ROCK_LIGHT =
        {
            GENERIC = "Some sorta crusty rock.",--removed
            OUT = "That ain't burning no one.",--removed
            LOW = "It's losing heat.",--removed
            NORMAL = "A real scorcher!",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Looks movable.",
            RAISED = "I'm just not tall enough.",
        },
        ROCK = "Mhm, yep. That's a rock.",
        PETRIFIED_TREE = "Solid stone.",
        ROCK_PETRIFIED_TREE = "Solid stone.",
        ROCK_PETRIFIED_TREE_OLD = "Solid stone.",
        ROCK_ICE =
        {
            GENERIC = "A weirdly isolated glacier.",
            MELTED = "Yep. That's a puddle.",
        },
        ROCK_ICE_MELTED = "Yep. That's a puddle.",
        ICE = "Chilly.",
        ROCKS = "A bunch of rocks.",
        ROOK = "No way that was made in a factory.",
        ROPE = "An essential building material.",
        ROTTENEGG = "Yeesh, get a whiff of that. No wait, don't!",
        ROYAL_JELLY = "A big bee boogie.",
        JELLYBEAN = "I would eat them all in one sitting.",
        SADDLE_BASIC = "How'd I get saddled with this? Ha!",
        SADDLE_RACE = "Still wouldn't keep up with a Leapin' Lena...",
        SADDLE_WAR = "Alright, who wants to fight?",
        SADDLEHORN = "Takes a saddle off real quick.",
        SALTLICK = "Keeps livestock nice and docile.",
        BRUSH = "Repetitive tasks are soothing.",
		SANITYROCK =
		{
			ACTIVE = "I can't begin to imagine how it works.",
			INACTIVE = "What on earth is that thing?",
		},
		SAPLING =
		{
			BURNING = "Lit up brighter than a New York powergrid.",
			WITHERED = "The heat did a number on this one.",
			GENERIC = "Might be useful.",
			PICKED = "All the useful bits are gone.",
			DISEASED = "That thing does not look good.", --removed
			DISEASING = "You're smelling a little funky.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Doesn't look too scary.",
			BURNING = "That lit up real fast!",
			BURNT = "That happens when you build stuff with straw.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Not bad for a handmade table.",
			BLOCK = "Ready for sculpting.",
			SCULPTURE = "Looks great!",
			BURNT = "Let's build another.",
   		},
        SCULPTURE_KNIGHTHEAD = "I just can't stand disrepair.",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "I'd rather having building materials than art.",
			UNCOVERED = "Creepy. Let's fix it.",
			FINISHED = "A job well done.",
			READY = "Something else needs to happen.",
		},
        SCULPTURE_BISHOPHEAD = "Someone's in need of a fixing.",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "I could take it or leave it.",
			UNCOVERED = "Needs a proper a repair job.",
			FINISHED = "Doesn't that give you a good, satisfied feeling?",
			READY = "Something else needs to happen.",
		},
        SCULPTURE_ROOKNOSE = "Let's fix that up.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Looks like free marble to me.",
			UNCOVERED = "I could probably fix that up a bit.",
			FINISHED = "There we go, back in one piece.",
			READY = "Something else needs to happen.",
		},
        GARGOYLE_HOUND = "Something scare ya? You look petrified!",
        GARGOYLE_WEREPIG = "At least it's not trying to kill us now.",
		SEEDS = "Some seeds. Not sure what kind.",
		SEEDS_COOKED = "Anyone wanna see how far I can spit the shells?",
		SEWING_KIT = "I don't need thimbles. My hands are pure callus!",
		SEWING_TAPE = "That's my trusty mending tape.",
		SHOVEL = "Time to get digging.",
		SILK = "Unprocessed silk, fresh from the spider!",
		SKELETON = "A workplace safety reminder.",
		SCORCHED_SKELETON = "Yikes. Not a good way to go.",
        SKELETON_NOTPLAYER = "Rest in peace, whatever you were.",
		SKULLCHEST = "Is that supposed to scare me?", --removed
		SMALLBIRD =
		{
			GENERIC = "Ha! You're so tiny!",
			HUNGRY = "You feelin' a bit peckish? Ha!",
			STARVING = "Yeesh, you ain't lookin' so good.",
			SLEEPING = "Sleep well, fluffnugget.",
		},
		SMALLMEAT = "Looks like grub to me.",
		SMALLMEAT_DRIED = "Meat to go.",
		SPAT = "Looks like the old foreman. Ha!",
		SPEAR = "So crude.",
		SPEAR_WATHGRITHR = "This would never pass inspection.",
		WATHGRITHRHAT = "Surprisingly practical.",
		SPIDER =
		{
			DEAD = "No sleeping on the job!",
			GENERIC = "I don't like you.",
			SLEEPING = "Get back to work!",
		},
		SPIDERDEN = "I'd rather not mess with that.",
		SPIDEREGGSACK = "I think it'd be unwise to plant this.",
		SPIDERGLAND = "Ha! How indecent.",
		SPIDERHAT = "This is disgusting.",
		SPIDERQUEEN = "Better stay out of her way.",
		SPIDER_WARRIOR =
		{
			DEAD = "It's just trying to get out of work.",
			GENERIC = "You'll look better on the underside of my workboot.",
			SLEEPING = "Lazy spider.",
		},
		SPOILED_FOOD = "Wouldn't touch that with a ten foot pole.",
        STAGEHAND =
        {
			AWAKE = "Shoo!",
			HIDING = "Why's this table givin' me the creeps?",
        },
        STATUE_MARBLE =
        {
            GENERIC = "A bit snooty.",
            TYPE1 = "This is too strange.",
            TYPE2 = "We thought she was gone...",
            TYPE3 = "Too artsy fartsy for me.", --bird bath type statue
        },
		STATUEHARP = "I don't know. Some fancy thing.",
		STATUEMAXWELL = "So THIS is \"Maxy\".",
		STEELWOOL = "At least there's SOME steel around here.",
		STINGER = "I don't see the point. Oh wait, there it is.",
		STRAWHAT = "Keeps the sun outta your eyes.",
		STUFFEDEGGPLANT = "It's practically bursting.",
		SWEATERVEST = "A vest fit for an egghead.",
		REFLECTIVEVEST = "Workplace safety is a top priority.",
		HAWAIIANSHIRT = "That's one loud shirt.",
		TAFFY = "Proper treats stick to your teeth.",
		TALLBIRD = "Look at the legs on that one!",
		TALLBIRDEGG = "You wanna be an omelet, don'tcha?",
		TALLBIRDEGG_COOKED = "Dinner!",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "This egg's gonna freeze over.",
			GENERIC = "This one just might hatch.",
			HOT = "It's sweating buckets.",
			LONG = "You've got your work cut out for ya, lil guy.",
			SHORT = "I can see the beak!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "That looks mighty tasty.",
			PICKED = "Someone's an empty nester.",
		},
		TEENBIRD =
		{
			GENERIC = "We all go through that awkward stage.",
			HUNGRY = "Are you ever not-hungry?!",
			STARVING = "Stop whining, I'll feed you when I can!",
			SLEEPING = "Sleep well, awkward fluffnugget.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "That did it.", --single player
			GENERIC = "That gadget has my name on it.", --single player
			LOCKED = "Still needs a bit of tinkering.", --single player
			PARTIAL = "Coming along real nice.", --single player
		},
		TELEPORTATO_BOX = "Pulling the lever makes me feel better.", --single player
		TELEPORTATO_CRANK = "Let's get cranky. Ha!", --single player
		TELEPORTATO_POTATO = "Yuck. Handmade.", --single player
		TELEPORTATO_RING = "Nice little metal doodad.", --single player
		TELESTAFF = "So you're telling me this stick is \"magic\"?",
		TENT =
		{
			GENERIC = "Putting the tent together is the best part of camping.",
			BURNT = "Yup. Just like camping.",
		},
		SIESTAHUT =
		{
			GENERIC = "What sort of bonehead sleeps during the day?!",
			BURNT = "Probably for the best. Back to work!",
		},
		TENTACLE = "Hands off!",
		TENTACLESPIKE = "A real good whackin' stick.",
		TENTACLESPOTS = "Looks a bit spotty to me! Ha!",
		TENTACLE_PILLAR = "Don't even think about touching me.",
        TENTACLE_PILLAR_HOLE = "I've done worse jobs.",
		TENTACLE_PILLAR_ARM = "Hands off, buddy.",
		TENTACLE_GARDEN = "Is there no end to these things?",
		TOPHAT = "How bourgeoisie.",
		TORCH = "There's beauty in a simple design.",
		TRANSISTOR = "A thing of beauty.",
		TRAP = "All the trappings of a good dinner. Ha!",
		TRAP_TEETH = "Gnarly gnashers.",
		TRAP_TEETH_MAXWELL = "That's a safety hazard.", --single player
		TREASURECHEST =
		{
			GENERIC = "Handmade, so you know it's not up to snuff.",
			BURNT = "Hope there was nothin' good inside.",
            UPGRADED_STACKSIZE = "It's new and improved.",
		},
		TREASURECHEST_TRAP = "I don't need to be concerned about that.",
        CHESTUPGRADE_STACKSIZE = "Looks like something the bossman would've come up with.", -- Describes the kit upgrade item.
		COLLAPSEDCHEST = "Yeesh, what a mess!",
		SACRED_CHEST =
		{
			GENERIC = "Yeesh, it's givin' me the creeps.",
			LOCKED = "It's thinkin' real hard on it.",
		},
		TREECLUMP = "A big clump of tree.", --removed

		TRINKET_1 = "I was never much into marbles.", --Melted Marbles
		TRINKET_2 = "It's got no film to make a sound.", --Fake Kazoo
		TRINKET_3 = "Everyone's been real good at showin' me the ropes. Ha!", --Gord's Knot
		TRINKET_4 = "We're not goin' gnome anytime soon. Ha! ...Oh.", --Gnome
		TRINKET_5 = "Handcrafted. Yuck.", --Toy Rocketship
		TRINKET_6 = "The copper's probably valuable.", --Frazzled Wires
		TRINKET_7 = "Was this whittled... by hand? Blech!", --Ball and Cup
		TRINKET_8 = "No bathtub in sight.", --Rubber Bung
		TRINKET_9 = "Where's all this junk coming from?", --Mismatched Buttons
		TRINKET_10 = "All bite and no bark. Ha!", --Dentures
		TRINKET_11 = "Maybe this bot'll let me poke around its insides.", --Lying Robot
		TRINKET_12 = "Hey Willow! Dare ya ta eat it!", --Dessicated Tentacle
		TRINKET_13 = "Looks like my old landlord. Ha!", --Gnomette
		TRINKET_14 = "Tea's not really my taste.", --Leaky Teacup
		TRINKET_15 = "A bit highbrow, don'tcha think?", --Pawn
		TRINKET_16 = "A bit highbrow, don'tcha think?", --Pawn
		TRINKET_17 = "A waste of good metal.", --Bent Spork
		TRINKET_18 = "Handcrafted. Blech.", --Trojan Horse
		TRINKET_19 = "This is why we need production standards.", --Unbalanced Top
		TRINKET_20 = "I can reach my own back! Watch!", --Backscratcher
		TRINKET_21 = "Nice and mechanical.", --Egg Beater
		TRINKET_22 = "I got no use for that.", --Frayed Yarn
		TRINKET_23 = "I prefer to break workboots in myself.", --Shoehorn
		TRINKET_24 = "The reliable quality of a mass manufactured product!", --Lucky Cat Jar
		TRINKET_25 = "Ha! Nasty!", --Air Unfreshener
		TRINKET_26 = "That thing's an affront to manufacturing.", --Potato Cup
		TRINKET_27 = "Not a lotta use for that out here.", --Coat Hanger
		TRINKET_28 = "That's a rook.", --Rook
        TRINKET_29 = "That's a rook.", --Rook
        TRINKET_30 = "That's a knight.", --Knight
        TRINKET_31 = "That's a knight.", --Knight
        TRINKET_32 = "It's not the real thing.", --Cubic Zirconia Ball
        TRINKET_33 = "It's a plastic creepy crawly.", --Spider Ring
        TRINKET_34 = "I wish for more wishes.", --Monkey Paw
        TRINKET_35 = "Someone drank it already.", --Empty Elixir
        TRINKET_36 = "Chomp chomp.", --Faux fangs
        TRINKET_37 = "Doesn't seem worth fixing.", --Broken Stake
        TRINKET_38 = "Hope no one's been snoopin' on us.", -- Binoculars Griftlands trinket
        TRINKET_39 = "That just ain't right - it's left! Ha!", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Not sure what to do with it. I'm weighing my options.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Not sure what this was for.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Cute little toy, hey?", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Blech. Handmade.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Nope. Can't fix that.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "I'm not messing with anymore radios.", -- Odd Radio ONI trinket
        TRINKET_46 = "That might be fun to take apart.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Nope. Not touchin' that.",
        LOST_TOY_2  = "Nope. Not touchin' that.",
        LOST_TOY_7  = "Nope. Not touchin' that.",
        LOST_TOY_10 = "Nope. Not touchin' that.",
        LOST_TOY_11 = "Nope. Not touchin' that.",
        LOST_TOY_14 = "Nope. Not touchin' that.",
        LOST_TOY_18 = "Nope. Not touchin' that.",
        LOST_TOY_19 = "Nope. Not touchin' that.",
        LOST_TOY_42 = "Nope. Not touchin' that.",
        LOST_TOY_43 = "Nope. Not touchin' that.",

        HALLOWEENCANDY_1 = "A nice change from baked apples.",
        HALLOWEENCANDY_2 = "Is this even food?",
        HALLOWEENCANDY_3 = "That's no treat.",
        HALLOWEENCANDY_4 = "That gummy has too many legs for my taste.",
        HALLOWEENCANDY_5 = "Not made of catcoons, thankfully.",
        HALLOWEENCANDY_6 = "Not sure anyone should eat those.",
        HALLOWEENCANDY_7 = "That's just regular food.",
        HALLOWEENCANDY_8 = "How spooky.",
        HALLOWEENCANDY_9 = "Real gelatinous.",
        HALLOWEENCANDY_10 = "Curious flavor.",
        HALLOWEENCANDY_11 = "Best eaten by the handful.",
        HALLOWEENCANDY_12 = "Ha, yuck! Everyone watch me eat'em!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "I ain't patient enough to eat these.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Whew! That's the kick y'need!", --Hot Lava pepper candy
        CANDYBAG = "It's a goodybag.",

		HALLOWEEN_ORNAMENT_1 = "Ha! Ya almost fooled me.",
		HALLOWEEN_ORNAMENT_2 = "I should hang this somewhere.",
		HALLOWEEN_ORNAMENT_3 = "Time to decorate.",
		HALLOWEEN_ORNAMENT_4 = "Time for decoratin'!",
		HALLOWEEN_ORNAMENT_5 = "Hey, it's them hanging guys.",
		HALLOWEEN_ORNAMENT_6 = "It needs to be in a tree.",

		HALLOWEENPOTION_DRINKS_WEAK = "Aw, I was hoping for a little more.",
		HALLOWEENPOTION_DRINKS_POTENT = "I got lucky and got the big bottle.",
        HALLOWEENPOTION_BRAVERY = "Makes ya plucky.",
		HALLOWEENPOTION_MOON = "I'm more of a coffee drinker, myself.",
		HALLOWEENPOTION_FIRE_FX = "Ohh. This'll make a spark.",
		MADSCIENCE_LAB = "I can do some experimentin' with that.",
		LIVINGTREE_ROOT = "Oh hey! There's a little stick in there.",
		LIVINGTREE_SAPLING = "Keep growin' little guy! I'm gonna decorate you.",

        DRAGONHEADHAT = "Front and center!",
        DRAGONBODYHAT = "It's the beast's tummy!",
        DRAGONTAILHAT = "That's the business end.",
        PERDSHRINE =
        {
            GENERIC = "I feel luckier already.",
            EMPTY = "We oughta put a bush in there.",
            BURNT = "Smells like burnt gobbler.",
        },
        REDLANTERN = "Nothing luckier around here than a light.",
        LUCKY_GOLDNUGGET = "I could use a bit of prosperity.",
        FIRECRACKERS = "Lucky firecrackers!",
        PERDFAN = "It's a big fan made of tailfeathers.",
        REDPOUCH = "Seems my fortune's changin'.",
        WARGSHRINE =
        {
            GENERIC = "I should build something with it!",
            EMPTY = "Needs a little something extra.",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Burned right up.",
        },
        CLAYWARG =
        {
            GENERIC = "You lookin' to scrap, big guy?",
            STATUE = "I'm glad it ain't movin'.",
        },
        CLAYHOUND =
        {
            GENERIC = "I'll send you runnin', mutt!",
            STATUE = "How earthy.",
        },
        HOUNDWHISTLE = "This oughta give them paws pause.",
        CHESSPIECE_CLAYHOUND = "A good boy if ever I saw one.",
        CHESSPIECE_CLAYWARG = "It's a sculpture of that mean mutt.",

		PIGSHRINE =
		{
            GENERIC = "A bunch of things to build.",
            EMPTY = "I gotta find some meat for it.",
            BURNT = "No good now.",
		},
		PIG_TOKEN = "Too big for me to wear.",
		PIG_COIN = "Not bad payment for a good wrassle.",
		YOTP_FOOD1 = "Now that's a feast!",
		YOTP_FOOD2 = "I'll give it to a pig or somethin'.",
		YOTP_FOOD3 = "Somethin' to chew on.",

		PIGELITE1 = "Swell tattoos you got there.", --BLUE
		PIGELITE2 = "Chill out, red.", --RED
		PIGELITE3 = "He's giving me a dirty look.", --WHITE
		PIGELITE4 = "Stand still so I can hit you with a sign.", --GREEN

		PIGELITEFIGHTER1 = "Swell tattoos you got there.", --BLUE
		PIGELITEFIGHTER2 = "Chill out, red.", --RED
		PIGELITEFIGHTER3 = "He's giving me a dirty look.", --WHITE
		PIGELITEFIGHTER4 = "Stand still so I can hit you with a sign.", --GREEN

		CARRAT_GHOSTRACER = "You always did have a competitive streak, didn't ya sis?",

        YOTC_CARRAT_RACE_START = "We all gotta start somewhere.",
        YOTC_CARRAT_RACE_CHECKPOINT = "This checks out. Ha!",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "Keep your eyes on the prize!",
            BURNT = "Hm. That's not gonna work.",
            I_WON = "Woo-wee! What a race!",
            SOMEONE_ELSE_WON = "Ha! Good race {winner}, but I'll get it next time.",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Better set up the race!",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Time to plot out a course for our little racers.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Now, where to put the finish line...",

		YOTC_SEEDPACKET = "Some seeds.",
		YOTC_SEEDPACKET_RARE = "Wonder what's gonna sprout outta these?",

		MINIBOATLANTERN = "Nice to have some more light out here on the water.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "Time to get buildin'!",
            EMPTY = "You want somethin'?",
            BURNT = "Yeesh, that was not built up to fire code.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "Now that's a nifty little contraption.",
            RAT = "I think yer gettin' the hang of this, little guy!",
            BURNT = "Guess it was really feelin' the burn. Ha!",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Let's get the ball rolling! Or, uh, the wheel.",
            RAT = "Come on, let's hustle!",
            BURNT = "Guess it was really feelin' the burn. Ha!",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "Better start training.",
            RAT = "Pop goes the popcorn!",
            BURNT = "Guess it was really feelin' the burn. Ha!",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "Better hop to it.",
            RAT = "Don't quit now!",
            BURNT = "Guess it was really feelin' the burn. Ha!",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "Better roll up my sleeves and get started!",
        YOTC_CARRAT_GYM_SPEED_ITEM = "Let's get a move on!",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "Time to get training!",
        YOTC_CARRAT_GYM_REACTION_ITEM = "I'll have this all set up in a jiffy.",

        YOTC_CARRAT_SCALE_ITEM = "Time to see if my Carrat's up to snuff.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "Alright, let's see what I'm working with.",
            CARRAT = "Still some room for improvement.",
            CARRAT_GOOD = "I think we've got a real winner on our hands!",
            BURNT = "Yikes, that was not up to code.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Let's see what we've got!",
            EMPTY = "I bet I could find some beefalo fluff to give it.",
            BURNT = "It's not good for much now.",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Awfully fancy for a beefalo.",
            OCCUPIED = "Let's get this beefalo spiffed up.",
            BURNT = "Guess I'll have to build another one.",
        },
        BEEFALO_GROOMER_ITEM = "Better get building!",

        YOTR_RABBITSHRINE =
        {
            GENERIC = "All this for a bunch of rabbits?",
            EMPTY = "I'm guessing it's hungry for somethin'.",
            BURNT = "Guess that's enough of that.",
        },

        NIGHTCAPHAT = "A solid night's sleep'll help ya do a solid day's work.",

        YOTR_FOOD1 = "I guess a little cake break won't hurt anything.",
        YOTR_FOOD2 = "Can't quite pin down the flavor, but I like it!",
        YOTR_FOOD3 = "It looks like one of Warly's more fancy-pants desserts.",
        YOTR_FOOD4 = "Sweetness on a stick.",

        YOTR_TOKEN = "This'll get those layabouts off their fuzzy tushes!",

        COZY_BUNNYMAN = "What a bunch of slackers!",

        HANDPILLOW_BEEFALOWOOL = "It's cushy enough for me.",
        HANDPILLOW_KELP = "It wouldn't be my first choice of pillow stuffing.",
        HANDPILLOW_PETALS = "Way too flimsy, there's no support at all!",
        HANDPILLOW_STEELWOOL = "Aww, it kinda makes me nostalgic for the old steel mill.",

        BODYPILLOW_BEEFALOWOOL = "It's cushy enough for me.",
        BODYPILLOW_KELP = "It wouldn't be my first choice of pillow stuffing.",
        BODYPILLOW_PETALS = "Way too flimsy, there's no support at all!",
        BODYPILLOW_STEELWOOL = "Aww, it kinda makes me nostalgic for the old steel mill.",

		BISHOP_CHARGE_HIT = "Yeow!",
		TRUNKVEST_SUMMER = "They weren't kidding about the breeze.",
		TRUNKVEST_WINTER = "I wish it had sleeves.",
		TRUNK_COOKED = "Singed the nosehairs right off.",
		TRUNK_SUMMER = "I'll eat it. Don't think I won't.",
		TRUNK_WINTER = "I'll eat it. Don't think I won't.",
		TUMBLEWEED = "Rollin' along the road of life.",
		TURKEYDINNER = "We're eatin' well tonight!",
		TWIGS = "I could snap these like twigs! Ha!",
		UMBRELLA = "It serves its purpose.",
		GRASS_UMBRELLA = "Better than nothing.",
		UNIMPLEMENTED = "What kind of bonehead leaves stuff half-built?!",
		WAFFLES = "Bet I can fit them all in my mouth.",
		WALL_HAY =
		{
			GENERIC = "It's just a hay bale, really.",
			BURNT = "Guess we should've seen that coming.",
		},
		WALL_HAY_ITEM = "Assembly time.",
		WALL_STONE = "The building part is over.",
		WALL_STONE_ITEM = "Assembly time.",
		WALL_RUINS = "If I break it, I'll get to build it again.",
		WALL_RUINS_ITEM = "Assembly time.",
		WALL_WOOD =
		{
			GENERIC = "Built nice and sturdy.",
			BURNT = "Just means we gotta build more.",
		},
		WALL_WOOD_ITEM = "Assembly time.",
		WALL_MOONROCK = "It's already been built. Sigh.",
		WALL_MOONROCK_ITEM = "Assembly time.",
		WALL_DREADSTONE = "Well, at least it's sturdy.",
		WALL_DREADSTONE_ITEM = "Assembly time.",
        WALL_SCRAP = "A wall's a wall, I suppose.",
        WALL_SCRAP_ITEM = "A wall's a wall, I suppose.",
		FENCE = "A clearly handmade fence.",
        FENCE_ITEM = "Just needs to be assembled.",
        FENCE_GATE = "A clearly handmade gate.",
        FENCE_GATE_ITEM = "Just gotta assemble it now.",
		WALRUS = "Maybe you oughta retire.",
		WALRUSHAT = "Oddly comforting.",
		WALRUS_CAMP =
		{
			EMPTY = "Just a mud pit.",
			GENERIC = "I wonder how long that took to build?",
		},
		WALRUS_TUSK = "He was gettin' a bit long in the tooth. Ha!",
		WARDROBE =
		{
			GENERIC = "I could build a million of these.",
            BURNING = "And up it goes.",
			BURNT = "So who wants to build another one?",
		},
		WARG = "Quite the set of chompers on that one.",
        WARGLET = "I don't think we're gonna get along.",

		WASPHIVE = "Wouldn't mess with that without good reason.",
		WATERBALLOON = "I throw a killer curveball.",
		WATERMELON = "We used to slice these up on hot summer days.",
		WATERMELON_COOKED = "This was an odd choice.",
		WATERMELONHAT = "A melon for your melon.",
		WAXWELLJOURNAL =
		{
			GENERIC = "I don't trust that thing one bit.",
--fallback to speech_wilson.lua 			NEEDSFUEL = "only_used_by_waxwell",
		},
		WETGOOP = "Yuck.",
        WHIP = "The preferred tool of the foreman.",
		WINTERHAT = "Perfect for winters in the tenement house.",
		WINTEROMETER =
		{
			GENERIC = "Assembling gadgets is so fulfilling.",
			BURNT = "Rest in peace, sweet gizmo.",
		},

        WINTER_TREE =
        {
            BURNT = "No reason we can't make another.",
            BURNING = "Such a shame.",
            CANDECORATE = "Now that's a job well done.",
            YOUNG = "Still a bit on the small side.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "Just needs a tree.",
            BURNT = "Burnt.",
		},
        WINTER_ORNAMENT = "Gotta be careful not to break it.",
        WINTER_ORNAMENTLIGHT = "Finally, something with wiring.",
        WINTER_ORNAMENTBOSS = "Fancy lil ornament.",
		WINTER_ORNAMENTFORGE = "Reminds me of somthin'.",
		WINTER_ORNAMENTGORGE = "Look at that fancy pants decoration.",

        WINTER_FOOD1 = "I love these things!", --gingerbread cookie
        WINTER_FOOD2 = "No thanks, I'm sweet enough.", --sugar cookie
        WINTER_FOOD3 = "Homemade. What a waste of time!", --candy cane
        WINTER_FOOD4 = "Just terrible.", --fruitcake
        WINTER_FOOD5 = "Chocolatey.", --yule log cake
        WINTER_FOOD6 = "Not my favorite thing.", --plum pudding
        WINTER_FOOD7 = "That's the good stuff.", --apple cider
        WINTER_FOOD8 = "Don't burn your mouth.", --hot cocoa
        WINTER_FOOD9 = "I know what eggs are, but what's a \"nog\"?", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "A nice sturdy oven.",
			COOKING = "What's cookin', oven?",
			ALMOST_DONE_COOKING = "Smells like it's almost done.",
			DISH_READY = "Mmmm mmmm! Good eatin'!",
		},
		BERRYSAUCE = "Pass it over here!",
		BIBINGKA = "I'll give it a try!",
		CABBAGEROLLS = "That'll put meat on your bones!",
		FESTIVEFISH = "Sure, why not.",
		GRAVY = "Now we're talking!",
		LATKES = "I love me some potatoes!",
		LUTEFISK = "That doesn't look half bad!",
		MULLEDDRINK = "I ain't one to pull my punches... but I'll mull them! Ha!",
		PANETTONE = "Huh. Some kinda fancy-shmancy holiday bread?",
		PAVLOVA = "Is cake supposed to crunch? Not that I'm complainin!",
		PICKLEDHERRING = "It's actually not bad!",
		POLISHCOOKIE = "Tasty!",
		PUMPKINPIE = "Tis the season for some good eatin'!",
		ROASTTURKEY = "Now that's a beautiful bird!",
		STUFFING = "I could eat this for days!",
		SWEETPOTATO = "Sticks to yer ribs!",
		TAMALES = "Now that'll warm ya right up!",
		TOURTIERE = "Now that's a good meat pie!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Now that's a sturdy table!",
			HAS_FOOD = "When do we eat?",
			WRONG_TYPE = "Whoops! That doesn't go here.",
			BURNT = "A darn shame.",
		},

		GINGERBREADWARG = "This guy's just making me hungry.",
		GINGERBREADHOUSE = "Better as a dessert than a dwelling.",
		GINGERBREADPIG = "Hey cookie, what's the rush?",
		CRUMBS = "A trail of crumbs to follow!",
		WINTERSFEASTFUEL = "This season always makes me think of Charlie.",

        KLAUS = "Get out of here ya big creep.",
        KLAUS_SACK = "There's gotta be something good in there.",
		KLAUSSACKKEY = "This must be the actual key.",
		WORMHOLE =
		{
			GENERIC = "I'm not one to shy away from a dirty job.",
			OPEN = "Here we go!",
		},
		WORMHOLE_LIMITED = "That thing can't take much more.",
		ACCOMPLISHMENT_SHRINE = "A testament to my achievements. Or lack of them.", --single player
		LIVINGTREE = "Did that tree just move?",
		ICESTAFF = "This doesn't seem safe.",
		REVIVER = "I got heart to spare.",
		SHADOWHEART = "This is twisted.",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "There's a picture on it of some strangely shaped people.",
			LINE_2 = "Can't make heads or tails of this picture.",
			LINE_3 = "The people are drowning in axle grease.",
			LINE_4 = "Yuck. Something grotesque is happening in this picture.",
			LINE_5 = "A picture of a beautiful, well engineered city.",
		},
        ATRIUM_STATUE = "It's giving me goosebumps.",
        ATRIUM_LIGHT =
        {
			ON = "Not sure how it works.",
			OFF = "I think it's supposed to turn on.",
		},
        ATRIUM_GATE =
        {
			ON = "Not sure I trust strange portals anymore.",
			OFF = "Oughta turn on somehow.",
			CHARGING = "It's gearing up for something.",
			DESTABILIZING = "I don't think we oughta be here when it goes off!",
			COOLDOWN = "It won't be running again for awhile.",
        },
        ATRIUM_KEY = "Some sort of old power source.",
		LIFEINJECTOR = "I've never taken a sick day in my life.",
		SKELETON_PLAYER =
		{
			MALE = "%s got disassembled by %s.",
			FEMALE = "%s got disassembled by %s.",
			ROBOT = "%s got disassembled by %s.",
			DEFAULT = "%s got disassembled by %s.",
		},
		HUMANMEAT = "This was a terrible idea.",
		HUMANMEAT_COOKED = "Who thought this was a good idea?",
		HUMANMEAT_DRIED = "Nope.",
		ROCK_MOON = "Seems like just another rock to me.",
		MOONROCKNUGGET = "Woah! What an odd texture.",
		MOONROCKCRATER = "A rock with a hole in it.",
		MOONROCKSEED = "I could learn a thing or two from this.",

        REDMOONEYE = "You get sawdust in your eye?",
        PURPLEMOONEYE = "That's amore.",
        GREENMOONEYE = "You coulda been a useful necklace.",
        ORANGEMOONEYE = "You lookin' at me?",
        YELLOWMOONEYE = "Quit staring.",
        BLUEMOONEYE = "It saw me standing alone.",

        --Arena Event
        LAVAARENA_BOARLORD = "Why don't you fight us yourself!",
        BOARRIOR = "Let's cut him down to size!",
        BOARON = "Who's ready fer some bacon?!",
        PEGHOOK = "That acid stuff burns!",
        TRAILS = "He's justa big meathead.",
        TURTILLUS = "Steel yourself, turtle.",
        SNAPPER = "You keep yer spit to yourself now, buddy.",
		RHINODRILL = "Am I supposed to be impressed?",
		BEETLETAUR = "Go back to your cage.",

        LAVAARENA_PORTAL =
        {
            ON = "Welp, time to go!",
            GENERIC = "Just like the one I came through...",
        },
        LAVAARENA_KEYHOLE = "Can't go home without the key.",
		LAVAARENA_KEYHOLE_FULL = "Perfect assembly!",
        LAVAARENA_BATTLESTANDARD = "Hey! We gotta destroy that Battle Standard!",
        LAVAARENA_SPAWNER = "Wonder how it works?",

        HEALINGSTAFF = "I'm a bit of a Jane-of-all-trades.",
        FIREBALLSTAFF = "Doesn't look too hard to operate.",
        HAMMER_MJOLNIR = "I'm most effective with a tool in hand.",
        SPEAR_GUNGNIR = "Pretty snazzy weapon there!",
        BLOWDART_LAVA = "Efficient, and painful!",
        BLOWDART_LAVA2 = "That's right up my alley!",
        LAVAARENA_LUCY = "I could take a swing at it. Ha!",
        WEBBER_SPIDER_MINION = "Can you tell your friends not to get so close to me, kid?",
        BOOK_FOSSIL = "I ain't much of a bookworm.",
		LAVAARENA_BERNIE = "You here to help, lil fella?",
		SPEAR_LANCE = "Check out this drill bit!",
		BOOK_ELEMENTAL = "I ain't too well read.",
		LAVAARENA_ELEMENTAL = "Hey lil fella.",

   		LAVAARENA_ARMORLIGHT = "It's paper thin!",
		LAVAARENA_ARMORLIGHTSPEED = "I'd rather something a bit heftier.",
		LAVAARENA_ARMORMEDIUM = "It'll do in a pinch.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "That should do the trick.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "That armor puts ya at peak efficiency!",
		LAVAARENA_ARMORHEAVY = "This is more my style!",
		LAVAARENA_ARMOREXTRAHEAVY = "I could really take a hit in that thing!",

		LAVAARENA_FEATHERCROWNHAT = "Faster than tiny hands on an assembly line.",
        LAVAARENA_HEALINGFLOWERHAT = "That hat'll help you feel right as rain.",
        LAVAARENA_LIGHTDAMAGERHAT = "Gives ya a lil extra punch!",
        LAVAARENA_STRONGDAMAGERHAT = "I'm gonna be a real slugger with that thing!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "That'd be fer healin' my pals.",
        LAVAARENA_EYECIRCLETHAT = "Just some high class trinket.",
        LAVAARENA_RECHARGERHAT = "I'd be so efficient with that!",
        LAVAARENA_HEALINGGARLANDHAT = "That's fer a bit of self maintenance.",
        LAVAARENA_CROWNDAMAGERHAT = "You'd be a real heavy hitter with that.",

		LAVAARENA_ARMOR_HP = "Can't go wrong with armor.",

		LAVAARENA_FIREBOMB = "Here's fire in yer eye!",
		LAVAARENA_HEAVYBLADE = "That'll do the trick.",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "Moss has grown over some sorta socket in the base.",
        	FULL = "That should keep it busy fer a bit.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "It probably looked real nice once.",
		QUAGMIRE_PARK_FOUNTAIN = "Under-used 'n overgrown.",

        QUAGMIRE_HOE = "I never done farmwork.",

        QUAGMIRE_TURNIP = "A fresh, ripe turnip.",
        QUAGMIRE_TURNIP_COOKED = "I'd rather not eat them on their own.",
        QUAGMIRE_TURNIP_SEEDS = "I got no idea what they'd grow into.",

        QUAGMIRE_GARLIC = "Makes everything taste better.",
        QUAGMIRE_GARLIC_COOKED = "Bet that brought out the flavor.",
        QUAGMIRE_GARLIC_SEEDS = "I got no idea what they'd grow into.",

        QUAGMIRE_ONION = "I hate chopping vegetables.",
        QUAGMIRE_ONION_COOKED = "Done and done.",
        QUAGMIRE_ONION_SEEDS = "I got no idea what they'd grow into.",

        QUAGMIRE_POTATO = "I just think they're neat.",
        QUAGMIRE_POTATO_COOKED = "I've always been a meat and potatoes gal.",
        QUAGMIRE_POTATO_SEEDS = "I got no idea what they'd grow into.",

        QUAGMIRE_TOMATO = "Gotta appreciate havin' fresh vegetables.",
        QUAGMIRE_TOMATO_COOKED = "I prefer'em fried and green.",
        QUAGMIRE_TOMATO_SEEDS = "I got no idea what they'd grow into.",

        QUAGMIRE_FLOUR = "I ain't much of a baker.",
        QUAGMIRE_WHEAT = "I go against the grain whenever possible. Ha!",
        QUAGMIRE_WHEAT_SEEDS = "I got no idea what they'd grow into.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "I got no idea what they'd grow into.",

        QUAGMIRE_ROTTEN_CROP = "I am not a good farmer.",

		QUAGMIRE_SALMON = "It ain't pink. It's salmon! Ha!",
		QUAGMIRE_SALMON_COOKED = "Fancy dining.",
		QUAGMIRE_CRABMEAT = "I get crabby when I'm hungry. Ha!",
		QUAGMIRE_CRABMEAT_COOKED = "It's a big lump of cooked crab.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "It's a big, pink tree.",
			STUMP = "That ain't growin' back.",
			TAPPED_EMPTY = "I wish trees leaked a little faster.",
			TAPPED_READY = "That bucket's practically overflowing!",
			TAPPED_BUGS = "It's a little buggy.",
			WOUNDED = "It's lost some of its color.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "Yeah, we could probably eat that.",
			PICKED = "It's got a weird texture.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Tastes sorta like... pepper?",
		QUAGMIRE_SPOTSPICE_GROUND = "That should add some kick.",
		QUAGMIRE_SAPBUCKET = "Buckets. The most advanced farming technology.",
		QUAGMIRE_SAP = "Alright, it's pretty good.",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Salt's ready for minin'.",
			GENERIC = "It needs a bit more time.",
		},

		QUAGMIRE_POND_SALT = "It's a bit salty, hey?",
		QUAGMIRE_SALT_RACK_ITEM = "Let's set'er up proper.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "Wouldn't mind a peek inside.",
			LOCKED = "My lockpicking skills are a bit rusty.",
		},

		QUAGMIRE_KEY = "Hmmm... looks like the key to a safe.",
		QUAGMIRE_KEY_PARK = "It's a gate key.",
        QUAGMIRE_PORTAL_KEY = "Looks like it unlocks somethin' big.",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Well, they don't LOOK poisonous.",
			PICKED = "It's just a stump.",
		},
		QUAGMIRE_MUSHROOMS = "Wouldn't mind popping these suckers into the pot.",
        QUAGMIRE_MEALINGSTONE = "Ah! A job that could use some elbow grease!",
		QUAGMIRE_PEBBLECRAB = "He ain't a threat to no one.",


		QUAGMIRE_RUBBLE_CARRIAGE = "Never thought I'd say this, but it's beyond repair.",
        QUAGMIRE_RUBBLE_CLOCK = "Something muddled this clockwork real good.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Well I sure ain't goin' in it now.",
        QUAGMIRE_RUBBLE_PUBDOOR = "Even I can't fix it.",
        QUAGMIRE_RUBBLE_ROOF = "I've repaired roofs before but this is a lost cause.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "Looks like something destroyed it.",
        QUAGMIRE_RUBBLE_BIKE = "It's busted.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Something happened here.",
            "Ain't no one here anymore.",
            "Something busted this town.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "It's broken. I can't fix it.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Needs a lot more love than I got to give it.",
        QUAGMIRE_MERMHOUSE = "Zero form, zero function.",
        QUAGMIRE_SWAMPIG_HOUSE = "Plain shoddy worksmanship.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "It might have been a house, once.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "You're a big guy, hey?",
            SLEEPING = "Sleeping on the job.",
        },
        QUAGMIRE_SWAMPIG = "They don't seem very afraid of people.",

        QUAGMIRE_PORTAL = "I might not be good at rescue missions.",
        QUAGMIRE_SALTROCK = "It's a big ol' eatin' rock.",
        QUAGMIRE_SALT = "But where's the pepper?",
        --food--
        QUAGMIRE_FOOD_BURNT = "It's a little toastier than normal.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Let's throw it up on that altar, hey?",
            MISMATCH = "Well this ain't right.",
            MATCH = "Perfect.",
            MATCH_BUT_SNACK = "It's the right food, but it don't look too filling.",
        },

        QUAGMIRE_FERN = "Fresh roughage.",
        QUAGMIRE_FOLIAGE_COOKED = "Cooked roughage.",
        QUAGMIRE_COIN1 = "A lucky coin.",
        QUAGMIRE_COIN2 = "Save this for a rainy day.",
        QUAGMIRE_COIN3 = "Gotta watch I don't turn into a rich dope.",
        QUAGMIRE_COIN4 = "We could bust outta here with enough of these.",
        QUAGMIRE_GOATMILK = "I try to support local artisans.",
        QUAGMIRE_SYRUP = "It's like honey from a tree.",
        QUAGMIRE_SAP_SPOILED = "It's no good now.",
        QUAGMIRE_SEEDPACKET = "Better than a market.",

        QUAGMIRE_POT = "Could make a real big stew in that pot.",
        QUAGMIRE_POT_SMALL = "I only ever made stew before this.",
        QUAGMIRE_POT_SYRUP = "Syrup makes me sappy. Ha!",
        QUAGMIRE_POT_HANGER = "Needs a pot in there or somethin'.",
        QUAGMIRE_POT_HANGER_ITEM = "Ready for assembly.",
        QUAGMIRE_GRILL = "Time for a cookout!",
        QUAGMIRE_GRILL_ITEM = "I need to to find a firepit for this to work.",
        QUAGMIRE_GRILL_SMALL = "Big enough for a small cookout.",
        QUAGMIRE_GRILL_SMALL_ITEM = "Now where can I put this...",
        QUAGMIRE_OVEN = "It's a regular ol' oven.",
        QUAGMIRE_OVEN_ITEM = "Welp. Another day, another project.",
        QUAGMIRE_CASSEROLEDISH = "I'll need to bake it.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "For making little stews and stuff.",
        QUAGMIRE_PLATE_SILVER = "Little too fancy for my tastes.",
        QUAGMIRE_BOWL_SILVER = "Fancy lookin' but it still just holds food.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Anything good in there?", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "It's full of stuff I could use.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Gives me the heebie jeebies.",
        QUAGMIRE_PARK_ANGEL2 = "Kinda creepy.",
        QUAGMIRE_PARK_URN = "Oh well. Happens to the best of us.",
        QUAGMIRE_PARK_OBELISK = "Nice stonework.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Can't keep me outta nothing.",
            LOCKED = "Needs a key.",
        },
        QUAGMIRE_PARKSPIKE = "Nice metalwork.",
        QUAGMIRE_CRABTRAP = "Here lil crabby crab.",
        QUAGMIRE_TRADER_MERM = "What'a ya got?",
        QUAGMIRE_TRADER_MERM2 = "Got anything good?",

        QUAGMIRE_GOATMUM = "Got anything for me?",
        QUAGMIRE_GOATKID = "What's goin' on, squirt?",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Dead as a doornail.",
            GENERIC = "You seen one, you seen'em all.",
            SLEEPING = "Sleeping on the job.",
        },
        QUAGMIRE_LAMP_POST = "That'd be a street lamp. Yep.",

        QUAGMIRE_BEEFALO = "Take it easy. You don't looks so good.",
        QUAGMIRE_SLAUGHTERTOOL = "Not my kinda tool.",

        QUAGMIRE_SAPLING = "That's gone.",
        QUAGMIRE_BERRYBUSH = "Nothing in that bush anymore.",

        QUAGMIRE_ALTAR_STATUE2 = "I wonder who chiseled that.",
        QUAGMIRE_ALTAR_QUEEN = "Woo-wee. Impress-ive.",
        QUAGMIRE_ALTAR_BOLLARD = "Nice metalwork.",
        QUAGMIRE_ALTAR_IVY = "That stuff can ruin good architecture.",

        QUAGMIRE_LAMP_SHORT = "That's a light.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "Not a bad result considering the materials.",
        	OFF = "Gotta hook it up to the generator.",
        	BURNING = "Quick! Put it out!",
        	BURNT = "Aw, nuts and bolts!",
			SLEEP = "Not a bad result considering the materials.",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "Sorry, Charlie.",
        	OFF = "Gotta hook it up to the generator.",
        	BURNING = "Quick! Put it out!",
        	BURNT = "Criminy! My machine!",
			SLEEP = "Ready to go.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "That oughta do it.",
        	LOWPOWER = "Just about out of juice.",
        	OFF = "Needs some more nitre.",
        	BURNING = "Quick! Put it out!",
        	BURNT = "Aw, nuts and bolts!",
        },
        WINONA_BATTERY_HIGH =
        {
			GENERIC = "I don't get how gems work, I just know they do.",
			LOWPOWER = "Gonna need a top up soon.",
			OFF = "Needs a few more'a those gem thingies.",
			BURNING = "Quick! Put it out!",
			BURNT = "Criminy! My machine!",
			OVERLOADED = "Yikes! Better give it a minute to cool off!",
        },
		--v3 Winona
		WINONA_REMOTE =
		{
			GENERIC = "It ain't magic, just some good engineering!",
			OFF = "Gotta hook it up to the generator.",
			CHARGING = "Needs some more time to charge.",
			CHARGED = "Charged and ready to go.",
		},
		WINONA_TELEBRELLA =
		{
			GENERIC = "I made a few adjustments to the bossman's design.",
            MISSINGSKILL = "Interesting design, but above my pay grade...",
			OFF = "Gotta hook it up to the generator.",
			CHARGING = "Needs some more time to charge.",
			CHARGED = "Charged and ready to go.",
		},
		WINONA_TELEPORT_PAD_ITEM =
		{
			GENERIC = "Sure beats luggin' stuff around!",
            MISSINGSKILL = "Interesting design, but above my pay grade...",
			OFF = "I'd better hook it up to some power.",
			BURNING = "Quick! Put it out!",
			BURNT = "Aw, nuts and bolts!",
		},
		WINONA_STORAGE_ROBOT =
		{
			GENERIC = "Nice to have a helpin' hand around here!",
			OFF = "Poor little guy, let's get you hooked up to some power.",
			SLEEP = "Take five, little guy!",
			CHARGING = "Needs some more time to charge.",
			CHARGED = "Charged and ready to go.",
		},
		INSPECTACLESBOX = "Sure hope the bossman doesn't mind me borrowing a few things.",
		INSPECTACLESBOX2 = "Jackpot!",
		INSPECTACLESHAT = 
        {
            GENERIC = "Now I can track down the bossman's loot!",
            MISSINGSKILL = "I'd love to know the specs for those specs! Ha!",
        },
		ROSEGLASSESHAT =
        {
            GENERIC = "Alright, Charlie. Show me the way.",
            MISSINGSKILL = "Something about 'em makes me really miss Charlie.",
        },
		CHARLIERESIDUE = "I must've just missed her... but she left somethin' behind.",
		CHARLIEROSE = "Oh, Charlie. What are you gettin' me into now?",
        WINONA_MACHINEPARTS_1 = "You just can't get quality manufactured parts like this out here!",
        WINONA_MACHINEPARTS_2 = "Oh, I've got big plans for this.",
		WINONA_RECIPESCANNER = "One scan with this Calibrated Perceiver, and I'll know how somethin's built!",
		WINONA_HOLOTELEPAD = "Looks like one of the boss's old designs. I should give it a scan.",
		WINONA_HOLOTELEBRELLA = "I should give it a scan with the ol' Calibrated Perceiver.",

        --Wormwood
        COMPOSTWRAP = "Heh. That bean sprout's a gross little guy.",
        ARMOR_BRAMBLE = "Odd design. How do you wear it without pricking yourself?",
        TRAP_BRAMBLE = "That lil plant fella whipped it up.",

        BOATFRAGMENT03 = "Busted right up, hey?",
        BOATFRAGMENT04 = "Busted right up, hey?",
        BOATFRAGMENT05 = "Busted right up, hey?",
		BOAT_LEAK = "That needs a fixin'!",
        MAST = "Better get to hoistin'.",
        SEASTACK = "It's a big rock in the middle of nowhere.",
        FISHINGNET = "Seems a bit unfair to the fish.", --unimplemented
        ANTCHOVIES = "We all feel like a fish outta water sometimes.", --unimplemented
        STEERINGWHEEL = "I'm ready for a sea adventure.",
        ANCHOR = "That'll keep the boat right where we want it.",
        BOATPATCH = "Never know when you might need one.",
        DRIFTWOOD_TREE =
        {
            BURNING = "Yeesh, that thing's on fire!",
            BURNT = "Looks like there was an accident here.",
            CHOPPED = "Wonder if driftwood's a good buildin' material?",
            GENERIC = "This tree's seen better days.",
        },

        DRIFTWOOD_LOG = "Oof. Kitschy.",

        MOON_TREE =
        {
            BURNING = "Yeesh, that thing's on fire!",
            BURNT = "Looks like there was an accident here.",
            CHOPPED = "Don't worry, we'll put it to good use.",
            GENERIC = "Sure is pretty, ain't it?",
        },
		MOON_TREE_BLOSSOM = "The trees sure are pretty 'round here.",

        MOONBUTTERFLY =
        {
        	GENERIC = "Cute little fella, aintcha?",
        	HELD = "So... you like engineerin'?",
        },
		MOONBUTTERFLYWINGS = "They ain't flyin' no more.",
        MOONBUTTERFLY_SAPLING = "It'll be a nice tree someday.",
        ROCK_AVOCADO_FRUIT = "Not sure how to crack this nut.",
        ROCK_AVOCADO_FRUIT_RIPE = "I think I could eat it now.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Who knew rocks were so tasty looking inside?",
        ROCK_AVOCADO_FRUIT_SPROUT = "We could use more fruit bushes I suppose.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It's done making fruit. Forever.",
			WITHERED = "You look a little down there, bucko.",
			GENERIC = "It looks like it's growing rocks!",
			PICKED = "Ain't got none of them little stone fruits today.",
			DISEASED = "It's definitely diseased.", --unimplemented
            DISEASING = "I think it's coming down with something.", --unimplemented
			BURNING = "Yeesh, that thing's on fire!",
		},
        DEAD_SEA_BONES = "They're picked clean dry.",
        HOTSPRING =
        {
        	GENERIC = "It's a nice, warm spring.",
        	BOMBED = "I'm not really a bubble bath kinda gal.",
        	GLASS = "Woah, the top glassed over solid.",
			EMPTY = "Dry as a bone.",
        },
        MOONGLASS = "Can't wait to try this out.",
        MOONGLASS_CHARGED = "I'd better hustle, the energy's not gonna last long.",
        MOONGLASS_ROCK = "Wonder if it's got any special properties.",
        BATHBOMB = "I'm not really the frou-frou type.",
        TRAP_STARFISH =
        {
            GENERIC = "Watch yer step.",
            CLOSED = "That thing's a workplace hazard.",
        },
        DUG_TRAP_STARFISH = "Can't fool me, ha!",
        SPIDER_MOON =
        {
        	GENERIC = "Urgh! What's wrong with it??",
        	SLEEPING = "Down and out. For now.",
        	DEAD = "Don't get back up.",
        },
        MOONSPIDERDEN = "I don't wanna see whatever's in there.",
		FRUITDRAGON =
		{
			GENERIC = "You play nice with the other lizards now, hey?",
			RIPE = "Lookit you, all orange!",
			SLEEPING = "I hope you earned that break.",
		},
        PUFFIN =
        {
            GENERIC = "Cute lil bird. Never seen one before.",
            HELD = "Hope you're comfy in there.",
            SLEEPING = "Taking her mandated break.",
        },

		MOONGLASSAXE = "Anything to make gettin' firewood easier.",
		GLASSCUTTER = "Ha ha! Just try and fight me!",

        ICEBERG =
        {
            GENERIC = "Better steer clear'a that.", --unimplemented
            MELTED = "It's just a lil ice cube now.", --unimplemented
        },
        ICEBERG_MELTED = "It's just a lil ice cube now.", --unimplemented

        MINIFLARE = "Safety in numbers, hey?",
        MEGAFLARE = "If I'm gonna start somethin', I'd better be ready to finish it.",

		MOON_FISSURE =
		{
			GENERIC = "Hm, wonder if I could use this energy somehow.",
			NOLIGHT = "Wonder how far down it goes.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Don't worry, we're nearly done.",
            GENERIC = "Inventions? What sort of inventions?",
        },

        MOON_ALTAR_IDOL = "I'll fix ya up right proper!",
        MOON_ALTAR_GLASS = "Huh? You talkin' to me?",
        MOON_ALTAR_SEED = "You're a pretty lil fella.",

        MOON_ALTAR_ROCK_IDOL = "Somethin' inside is itching to get out.",
        MOON_ALTAR_ROCK_GLASS = "Somethin' inside is itching to get out.",
        MOON_ALTAR_ROCK_SEED = "Somethin' inside is itching to get out.",

        MOON_ALTAR_CROWN = "Don't worry, I'll get you where you need to go.",
        MOON_ALTAR_COSMIC = "Can't shake the feeling that this is all building up to somethin'...",

        MOON_ALTAR_ASTRAL = "All the pieces are finally in their proper place.",
        MOON_ALTAR_ICON = "Now what were you doin' hiding underground?",
        MOON_ALTAR_WARD = "Let's getcha fixed up.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Always be inventing.",
            BURNT = "Time to make another!",
        },
        BOAT_ITEM = "Time to roll up my sleeves!",
        BOAT_GRASS_ITEM = "Don't expect to build somethin' that's gonna last with cheap materials.",
        STEERINGWHEEL_ITEM = "That steering wheel ain't gonna assemble itself.",
        ANCHOR_ITEM = "Someone's gotta assemble this anchor, might as well be me.",
        MAST_ITEM = "I can't wait to build that. I love hoisting things.",
        MUTATEDHOUND =
        {
        	DEAD = "Sorry, Fido.",
        	GENERIC = "That pup looks awful!",
        	SLEEPING = "Well, it looks more peaceful at least.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Sorry, fella.",
			GENERIC = "Yeeshkabob! What happened to your... everything?",
			SLEEPING = "Better than it being awake.",
		},
        CARRAT =
        {
        	DEAD = "That don't look good.",
        	GENERIC = "Yer an orange nuisance, aintcha?",
        	HELD = "Aw, I can't stay mad at you.",
        	SLEEPING = "Sleep tight.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "We can pick it if we can get close enough.",
            PICKED = "The sea's fulla food, hey?",
        },
		BULLKELP_ROOT = "Preferred tool of the foreman.",
        KELPHAT = "I'll stick with my bandana, thanks.",
		KELP = "I'll try anything once.",
		KELP_COOKED = "Well, that's not how I would have prepared it.",
		KELP_DRIED = "I kinda like the stuff!",

		GESTALT = "I feel like... they've seen my sister.",
        GESTALT_GUARD = "Don't think I like the looks of that.",

		COOKIECUTTER = "What's the matter lil guy?",
		COOKIECUTTERSHELL = "That thing was well protected.",
		COOKIECUTTERHAT = "Hardhats must be worn beyond this point!",
		SALTSTACK =
		{
			GENERIC = "Now that's just unsettlin'.",
			MINED_OUT = "Ain't nothin left of that one.",
			GROWING = "Huh, I wonder why they grow like that?",
		},
		SALTROCK = "Hey, that looks like salt!",
		SALTBOX = "This'll keep things fresher longer!",

		TACKLESTATION = "Need the right tool for the job!",
		TACKLESKETCH = "Hey! This will come in real handy next time I go fishin'!",

        MALBATROSS = "Yeesh, you're a big fella!",
        MALBATROSS_FEATHER = "I'll find a practical use for this.",
        MALBATROSS_BEAK = "How come I got left to pick up the bill? Ha!",
        MAST_MALBATROSS_ITEM = "Heave-ho!",
        MAST_MALBATROSS = "A bit showy, but useful.",
		MALBATROSS_FEATHERED_WEAVE = "Now that's some fancy fabric.",

        GNARWAIL =
        {
            GENERIC = "Yeesh, uh... nice whale?",
            BROKENHORN = "Them's the breaks.",
            FOLLOWER = "Glad to see ya pullin' your weight around here!",
            BROKENHORN_FOLLOWER = "You should really get that horn looked at.",
        },
        GNARWAIL_HORN = "I'm sure I can use this for somethin.",

        WALKINGPLANK = "That thing don't look stable.",
        WALKINGPLANK_GRASS = "That thing don't look stable.",
        OAR = "Remember, back straight, move those arms!",
		OAR_DRIFTWOOD = "Catch my drift? Ha!",

		OCEANFISHINGROD = "The right tool for the job!",
		OCEANFISHINGBOBBER_NONE = "I think that line needs something.",
        OCEANFISHINGBOBBER_BALL = "Bobber's yer uncle! Ha!",
        OCEANFISHINGBOBBER_OVAL = "Bobber's yer uncle! Ha!",
		OCEANFISHINGBOBBER_CROW = "It's nothin' to crow about, but it ain't half bad!",
		OCEANFISHINGBOBBER_ROBIN = "This'll do the trick.",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "This'll do the trick.",
		OCEANFISHINGBOBBER_CANARY = "This'll do the trick.",
		OCEANFISHINGBOBBER_GOOSE = "This thing's so fancy! Am I fishin' for food or compliments?",
		OCEANFISHINGBOBBER_MALBATROSS = "This thing's so fancy! Am I fishin' for food or compliments?",

		OCEANFISHINGLURE_SPINNER_RED = "Not that lifelike, but it fools the fish.",
		OCEANFISHINGLURE_SPINNER_GREEN = "Not that lifelike, but it fools the fish.",
		OCEANFISHINGLURE_SPINNER_BLUE = "Not that lifelike, but it fools the fish.",
		OCEANFISHINGLURE_SPOON_RED = "Not that lifelike, but it fools the fish.",
		OCEANFISHINGLURE_SPOON_GREEN = "Not that lifelike, but it fools the fish.",
		OCEANFISHINGLURE_SPOON_BLUE = "Not that lifelike, but it fools the fish.",
		OCEANFISHINGLURE_HERMIT_RAIN = "Sure wish it rained fish, not just cats and dogs.",
		OCEANFISHINGLURE_HERMIT_SNOW = "At least fishing is more productive than taking a snow day.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "I'll be extra careful with that one.",
		OCEANFISHINGLURE_HERMIT_HEAVY = "If I'm gonna catch fish, I may as well catch the biggest one!",

		OCEANFISH_SMALL_1 = "A little on the puny side, ain't it?",
		OCEANFISH_SMALL_2 = "Not a lot of meat on that one.",
		OCEANFISH_SMALL_3 = "It's just a teeny thing!",
		OCEANFISH_SMALL_4 = "My fish dinner might be a bit lean...",
		OCEANFISH_SMALL_5 = "Not sure that fish is healthy.",
		OCEANFISH_SMALL_6 = "Huh. Never heard a fish rustle before.",
		OCEANFISH_SMALL_7 = "Aww, it's kinda cute!",
		OCEANFISH_SMALL_8 = "That thing's a fire hazard!",
        OCEANFISH_SMALL_9 = "That thing sure can spit!",

		OCEANFISH_MEDIUM_1 = "Here's hoping it tastes better than it looks.",
		OCEANFISH_MEDIUM_2 = "Now that's a nice fat fish!",
		OCEANFISH_MEDIUM_3 = "Yeesh, I'd better watch the spines on that thing!",
		OCEANFISH_MEDIUM_4 = "Never been much for superstition.",
		OCEANFISH_MEDIUM_5 = "Never had to shuck a fish before.",
		OCEANFISH_MEDIUM_6 = "Looks like one of those fish rich people put in ponds.",
		OCEANFISH_MEDIUM_7 = "Looks like one of those fish rich people put in ponds.",
		OCEANFISH_MEDIUM_8 = "It's an ice fish if I do say so myself. Ha!",
        OCEANFISH_MEDIUM_9 = "You'll make a nice dinner!",

		PONDFISH = "I'd rather eat for a day than not at all.",
		PONDEEL = "You're looking a little eel. Ha!",

        FISHMEAT = "Is it safe to eat like that?",
        FISHMEAT_COOKED = "Nothing fancy, just how I like it.",
        FISHMEAT_SMALL = "You sure that's fish? Looks pretty shrimpy to me.",
        FISHMEAT_SMALL_COOKED = "I won't turn down a bite!",
		SPOILED_FISH = "Such a shame to let good food go to waste.",

		FISH_BOX = "Now there's a nice practical way to store fish!",
        POCKET_SCALE = "What a handy doo-hickey!",

		TACKLECONTAINER = "Gotta keep your tools organized!",
		SUPERTACKLECONTAINER = "I'll never say no to havin' more room for my tools!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "A challenge, huh?",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nWoo-wee, that's a big one!",
			BURNING = "Yikes! That fish scale's in some hot water!",
			BURNT = "Looks like someone was a sore loser.",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nHeh. No big deal.",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nAll it took was patience and hard work.",
		},

		OCEANFISHABLEFLOTSAM = "Ugh, what sorta mess did I reel in?",

		CALIFORNIAROLL = "Looks a bit fancy, but I'll give it a try!",
		SEAFOODGUMBO = "Sticks to yer ribs!",
		SURFNTURF = "Now THAT'S a meal!",

        WOBSTER_SHELLER = "Hey little guy, you look like dinner!",
        WOBSTER_DEN = "Anyone home?",
        WOBSTER_SHELLER_DEAD = "I think we got 'em.",
        WOBSTER_SHELLER_DEAD_COOKED = "That's some good eatin'!",

        LOBSTERBISQUE = "Hey Warly? Can you just keep makin' this forever?",
        LOBSTERDINNER = "That's some pretty fancy lookin' grub!",

        WOBSTER_MOONGLASS = "I don't trust those glassy eyes.",
        MOONGLASS_WOBSTER_DEN = "Wonder what lives in there?",

		TRIDENT = "I ain't afraid to make waves! Ha!",

		WINCH =
		{
			GENERIC = "Now that's a handy bit of machinery!",
			RETRIEVING_ITEM = "Time to haul up the goods!",
			HOLDING_ITEM = "All in a day's work.",
		},

        HERMITHOUSE = {
            GENERIC = "That can't be up to code.",
            BUILTUP = "Just needed a bit of elbow grease.",
        },

        SHELL_CLUSTER = "Time to break out the ol' hammer.",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "Never thought I'd be serenaded by a seashell.",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "It can sure hold a tune.",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "I'm usually against knicknacks, but this one's alright.",
        },

        CHUM = "I'm all for anything that makes fishing go faster.",

        SUNKENCHEST =
        {
            GENERIC = "Here's hoping I never have to tussle with a live one.",
            LOCKED = "Can't seem to get it open.",
        },

        HERMIT_BUNDLE = "Aw, she didn't have to give me anything...",
        HERMIT_BUNDLE_SHELLS = "Not sure what came over me to buy these knicknacks.",

        RESKIN_TOOL = "Is this one of Max's magic doo-hickeys?",
        MOON_FISSURE_PLUGGED = "That old lady's more resourceful than I gave her credit for.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Awful skittish for such a big gal.",
            "Awful skittish for such a big gal.",
        },
        WOBYSMALL =
        {
            "Well, ain't you sweet!",
            "Well, ain't you sweet!",
        },
		WALTERHAT = "I'll stick to my hardhat.",
		SLINGSHOT = "Looks kinda flimsy.",
		SLINGSHOTAMMO_ROCK = "Hmph. Handmade. The shape's all irregular.",
		SLINGSHOTAMMO_MARBLE = "Hmph. Handmade. The shape's all irregular.",
		SLINGSHOTAMMO_THULECITE = "Hmph. Handmade. The shape's all irregular.",
        SLINGSHOTAMMO_GOLD = "Hmph. Handmade. The shape's all irregular.",
        SLINGSHOTAMMO_SLOW = "Hmph. Handmade. The shape's all irregular.",
        SLINGSHOTAMMO_FREEZE = "Hmph. Handmade. The shape's all irregular.",
		SLINGSHOTAMMO_POOP = "I don't even wanna ask.",
        PORTABLETENT = "Aw, this reminds me of campin' with Charlie when we were little...",
        PORTABLETENT_ITEM = "Need any help settin' that up?",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Opera's a bit hoity-toity for me.",
        BATTLESONG_HEALTHGAIN = "Opera's a bit hoity-toity for me.",
        BATTLESONG_SANITYGAIN = "Opera's a bit hoity-toity for me.",
        BATTLESONG_SANITYAURA = "Opera's a bit hoity-toity for me.",
        BATTLESONG_FIRERESISTANCE = "Opera's a bit hoity-toity for me.",
        BATTLESONG_INSTANT_TAUNT = "This kind of stuff was more Charlie's thing...",
        BATTLESONG_INSTANT_PANIC = "This kind of stuff was more Charlie's thing...",

        -- Webber
        MUTATOR_WARRIOR = "I don't think I'll be takin' a bite out of that.",
        MUTATOR_DROPPER = "Hope those spiders have strong stomachs.",
        MUTATOR_HIDER = "I don't think I'll be takin' a bite out of that.",
        MUTATOR_SPITTER = "Hope those spiders have strong stomachs.",
        MUTATOR_MOON = "I don't think I'll be takin' a bite out of that.",
        MUTATOR_HEALER = "Hope those spiders have strong stomachs.",
        SPIDER_WHISTLE = "Sure wish that kid would hang around a better crowd.",
        SPIDERDEN_BEDAZZLER = "Doing some home improvements, kiddo?",
        SPIDER_HEALER = "You're a real stinker, you know that?",
        SPIDER_REPELLENT = "Guess it can only be used by a spider specialist.",
        SPIDER_HEALER_ITEM = "Doesn't look like good eatin' to me.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "I don't think that's safe to drink...",
		GHOSTLYELIXIR_FASTREGEN = "I don't think that's safe to drink...",
		GHOSTLYELIXIR_SHIELD = "I don't think that's safe to drink...",
		GHOSTLYELIXIR_ATTACK = "I don't think that's safe to drink...",
		GHOSTLYELIXIR_SPEED = "I don't think that's safe to drink...",
		GHOSTLYELIXIR_RETALIATION = "I don't think that's safe to drink...",
		SISTURN =
		{
			GENERIC = "Nothin' stronger than the bond between sisters.",
			SOME_FLOWERS = "Looks a bit sparse. Maybe I can chip in a flower or two.",
			LOTS_OF_FLOWERS = "It looks real nice, kiddo.",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "A fancy pot for some fancy cookin'.",
            DONE = "Let's see if all that fuss was worth it.",

			COOKING_LONG = "All good things take time.",
			COOKING_SHORT = "This'll be done lickety-split!",
			EMPTY = "Could use some ingredients in there.",
        },

        PORTABLEBLENDER_ITEM = "I like the way that machine dances.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Probably a whole lot of interesting gears in there.",
            DONE = "Well worth all that work.",
        },
        SPICEPACK = "Say, this is some fine bit of engineering!",
        SPICE_GARLIC = "Hooboy. That's some smelly dust.",
        SPICE_SUGAR = "Now all I need is some pancakes to pour this over.",
        SPICE_CHILI = "Just smelling it is making my eyes water.",
        SPICE_SALT = "I could really go for some potato chips.",
        MONSTERTARTARE = "I'm all for getting my daily iron but this goes too far.",
        FRESHFRUITCREPES = "Fruit wrapped in a blanket of pancake.",
        FROGFISHBOWL = "Mmm! Love Warly's dishes.",
        POTATOTORNADO = "Count on Warly's cookin' to always make my day.",
        DRAGONCHILISALAD = "Can't believe Warly's got me eatin' salads.",
        GLOWBERRYMOUSSE = "You really outdid yourself with this one, buddy.",
        VOLTGOATJELLY = "You can really taste the electricity.",
        NIGHTMAREPIE = "Lookit that, Warly's at it again.",
        BONESOUP = "Knocked it out of the park again, bucko.",
        MASHEDPOTATOES = "That's good eatin' there, Warl'!",
        POTATOSOUFFLE = "Looks great, Warly!",
        MOQUECA = "What's this fancy stuff? I like it!",
        GAZPACHO = "I'd never turn down grub!",
        ASPARAGUSSOUP = "Huh. Interesting choice but I ain't complainin'!",
        VEGSTINGER = "I could use one of these after a long day.",
        BANANAPOP = "Cool and refreshin'!",
        CEVICHE = "Now that's some tasty grub!",
        SALSA = "Wish I had some chips to go with this.",
        PEPPERPOPPER = "My mouth's havin' a party!",

        TURNIP = "A fresh, ripe turnip.",
        TURNIP_COOKED = "I'd rather not eat them on their own.",
        TURNIP_SEEDS = "I got no idea what they'd grow into.",

        GARLIC = "Makes everything taste better.",
        GARLIC_COOKED = "Bet that brought out the flavor.",
        GARLIC_SEEDS = "I got no idea what they'd grow into.",

        ONION = "I hate chopping vegetables.",
        ONION_COOKED = "Done and done.",
        ONION_SEEDS = "I got no idea what they'd grow into.",

        POTATO = "I just think they're neat.",
        POTATO_COOKED = "I've always been a meat and potatoes gal.",
        POTATO_SEEDS = "I got no idea what they'd grow into.",

        TOMATO = "Gotta appreciate havin' fresh vegetables.",
        TOMATO_COOKED = "I prefer'em fried and green.",
        TOMATO_SEEDS = "I got no idea what they'd grow into.",

        ASPARAGUS = "Makes ya big and strong.",
        ASPARAGUS_COOKED = "I'm not fussy.",
        ASPARAGUS_SEEDS = "What's this going to grow into, I wonder.",

        PEPPER = "Ye-hooo! They gotta a kick to 'em.",
        PEPPER_COOKED = "Just the smell is making my eyes water.",
        PEPPER_SEEDS = "Wonder what these'll make.",

        WEREITEM_BEAVER = "Huh. The craftsmanship ain't half bad.",
        WEREITEM_GOOSE = "Does he hafta leave these creepy things lyin' around?",
        WEREITEM_MOOSE = "I ain't one for er... decorations.",

        MERMHAT = "Do I look a little green around the gills? Ha!",        
        MERMTHRONE =
        {
            GENERIC = "Not bad handiwork.",
            BURNT = "Yeesh, what a mess.",
        },
        MOSQUITOMUSK = "Somehow it's still not the creepiest doll I've seen.",
        MOSQUITOBOMB = "Talk about a buzz-kill. Ha!",
        MOSQUITOFERTILIZER = "Just throw a healthy dollop on the ground.",
        MOSQUITOMERMSALVE = "I almost feel sorry for the bloodsucker. Almost.",

        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "Whatcha makin' there, kid?",
            BURNT = "Guess it's back to the drawing board.",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Hm, I should teach that kid how to use a level.",
            BURNT = "All that work, up in smoke...",
        },

        MERMWATCHTOWER_REGULAR = "Now that's a proper tree fort!",
        MERMWATCHTOWER_NOKING = "It looks kinda gloomy.",
        MERMKING = "Are you the boss around here?",
        MERMGUARD = "Just doin' their job.",
        MERM_PRINCE = "Looks like someone got a promotion!",

        SQUID = "Jeepers, those peepers move fast!",

		GHOSTFLOWER = "Don't know if I want that in my garden.",
        SMALLGHOST = "Y'know, you're awful cute for a grim reminder of my own mortality.",

        CRABKING =
        {
            GENERIC = "Looks like he thinks he's the boss around here.",
            INERT = "The foundation doesn't look very stable.",
        },
		CRABKING_CLAW = "Now that's some claws for alarm. Ha!",

		MESSAGEBOTTLE = "Wonder where this came from?",
		MESSAGEBOTTLEEMPTY = "Might as well reuse this.",

        MEATRACK_HERMIT =
        {
            DONE = "Ready for eatin'.",
            DRYING = "It's well on its way.",
            DRYINGINRAIN = "Not gonna make much progress like that.",
            GENERIC = "Maybe I should give the old lady a hand.",
            BURNT = "Well, it's dry.",
            DONE_NOTMEAT = "Ready for eatin'.",
            DRYING_NOTMEAT = "It's well on its way.",
            DRYINGINRAIN_NOTMEAT = "Not gonna make much progress like that.",
        },
        BEEBOX_HERMIT =
        {
            READY = "Excellent work, bees!",
            FULLHONEY = "Excellent work, bees!",
            GENERIC = "Huh. Interestin' construction.",
            NOHONEY = "Where's that stellar work ethic, bees?!",
            SOMEHONEY = "You've been working hard.",
            BURNT = "Factory fire!",
        },

        HERMITCRAB = "Nothin' wrong with being independent.",

        HERMIT_PEARL = "I know a bit about not givin' up on someone.",
        HERMIT_CRACKED_PEARL = "I'm so sorry, Pearl.",

        -- DSEAS
        WATERPLANT = "Look at the size of it!",
        WATERPLANT_BOMB = "Seems determined to ruin the structural integrity of our boat.",
        WATERPLANT_BABY = "The spittin' image of its parents.",
        WATERPLANT_PLANTER = "Let's find a good rock to plant you on.",

        SHARK = "Just give 'em a good bop on the nose!",

        MASTUPGRADE_LAMP_ITEM = "One less thing cluttering up the deck.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "Seems pretty practical.",

        WATERPUMP = "Why do I get the feeling this is that funny-haired scientist's handiwork...",

        BARNACLE = "Took a bit of elbow grease to harvest 'em.",
        BARNACLE_COOKED = "They're kinda chewier than I expected.",

        BARNACLEPITA = "That's good eatin!",
        BARNACLESUSHI = "Can't say I've ever tasted somethin' quite like that before.",
        BARNACLINGUINE = "Nothin' like a pot full of pasta.",
        BARNACLESTUFFEDFISHHEAD = "I'm all for using the materials you've got.",

        LEAFLOAF = "It's hard to pin down the flavor...",
        LEAFYMEATBURGER = "It's not like any burger I've ever tried.",
        LEAFYMEATSOUFFLE = "Well... I guess it's creative.",
        MEATYSALAD = "Huh. Pretty hearty for some leafy greens.",

        -- GROTTO

		MOLEBAT = "I think it nose a thing or two. Ha!",
        MOLEBATHILL = "Might be some good materials stuck in that gunk.",

        BATNOSE = "Got yer nose!",
        BATNOSE_COOKED = "I ain't picky.",
        BATNOSEHAT = "Pretty practical if you ask me.",

        MUSHGNOME = "Strange, no matter how you spin it.",

        SPORE_MOON = "Yeesh, that's gotta be a health hazard.",

        MOON_CAP = "Anyone wanna volunteer to try it?",
        MOON_CAP_COOKED = "Wouldn't have minded having some of these around when I was pulling overtime.",

        MUSHTREE_MOON = "Now that's a weird looking mushroom.",

        LIGHTFLIER = "Doesn't even need a battery!",

        GROTTO_POOL_BIG = "Fancy a swim? Ha! Didn't think so.",
        GROTTO_POOL_SMALL = "Fancy a swim? Ha! Didn't think so.",

        DUSTMOTH = "Quite the tenacious little worker.",

        DUSTMOTHDEN = "Sorry little fellas, but you've got some material I need.",

        ARCHIVE_LOCKBOX = "I'm thinkin' this might be a cog for a larger machine.",
        ARCHIVE_CENTIPEDE = "Feelin' feisty now, are we?",
        ARCHIVE_CENTIPEDE_HUSK = "Wonder what made these things tick?",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "Still got a bit of a wait.",
            COOKING_SHORT = "Almost!",
            DONE = "Soup's on!",
            EMPTY = "Seems to be the only thing those critters haven't dusted.",
            BURNT = "You guys like gristle, right?",
        },

        ARCHIVE_MOON_STATUE = "All that material wasted on some decoration.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "I can't make heads or tails of it.",
            LINE_2 = "Ancient writing ain't exactly my specialty.",
            LINE_3 = "I can't make heads or tails of it.",
            LINE_4 = "Ancient writing ain't exactly my specialty.",
            LINE_5 = "I can't make heads or tails of it.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "Might as well see where the trail leads.",
            IDLE = "Guess we got 'em all!",
        },

        ARCHIVE_RESONATOR_ITEM = "They sure knew how to build 'em back in the day.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "Looks like it needs some power to get it going.",
          GENERIC =  "Now that's one fine piece of engineering!",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "Bet if it had some power it'd start right up.",
            GENERIC = "They really built things to last back then.",
        },

        ARCHIVE_SECURITY_PULSE = "Just where do you think you're going?",

        ARCHIVE_SWITCH = {
            VALID = "Seems like all three need a power source to complete the circuit.",
            GEMS = "This one needs a power source.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Is that... a portal? Maybe we can get it up and running!",
            GENERIC = "Come on! Why won't you work?",
        },

        WALL_STONE_2 = "The building part is over.",
        WALL_RUINS_2 = "If I break it, I'll get to build it again.",

        REFINED_DUST = "It's gotta be useful for something.",
        DUSTMERINGUE = "Ugh. Maybe one of those little moth guys will clean this mess up.",

        SHROOMCAKE = "Aw c'mon, it's not that bad.",
        SHROOMBAIT = "I can't make heads or tails out of it.",

        NIGHTMAREGROWTH = "Charlie...",

        TURFCRAFTINGSTATION = "Better pound the pavement! Ha!",

        MOON_ALTAR_LINK = "Looks like it's still under construction.",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "It's dirty work, but somebody's got to do it.",
            WET = "I'd guess there's a bit too much water in there.",
            DRY = "Looks a bit dry to me.",
            BALANCED = "That should do it!",
            BURNT = "Guess I'll have to start from scratch.",
        },
        COMPOST = "Why do I feel like I'm a waiter for those plants?",
        SOIL_AMENDER =
		{
			GENERIC = "Wouldn't want to take a sip of that stuff.",
			STALE = "This stuff sure takes a while to do its thing.",
			SPOILED = "That looks like some strong stuff.",
		},

		SOIL_AMENDER_FERMENTED = "I don't think it can smell any worse, must mean it's done!",

        WATERINGCAN =
        {
            GENERIC = "Pretty straightforward.",
            EMPTY = "Looks like I'll have to find some water.",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "As long as it works, I don't care what it looks like.",
            EMPTY = "Looks like I'll have to find some water.",
        },

		FARM_PLOW = "Now that's handy!",
		FARM_PLOW_ITEM = "This gizmo will get us gardening in no time flat!",
		FARM_HOE = "Let's get to planting, then!",
		GOLDEN_FARM_HOE = "Awfully ritzy for yard work.",
		NUTRIENTSGOGGLESHAT = "It's kinda fancy-shmancy for farming, but at least it's useful.",
		PLANTREGISTRYHAT = "Better fill my noggin' with some planting know-how.",

        FARM_SOIL_DEBRIS = "Let's clear out that clutter.",

		FIRENETTLES = "Definitely a workplace hazard.",
		FORGETMELOTS = "I'm not one for flowers, especially when they crowd out my hard working crops!",
		SWEETTEA = "I've got no time for tea! There's work to be done, like... er...",
		TILLWEED = "Stubborn rascals.",
		TILLWEEDSALVE = "Glad to have found a use for those weeds.",
        WEED_IVY = "I don't like the look of that one.",
        IVY_SNARE = "Now I've got to clean all this up!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "What is this, a county fair?",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nPretty good!",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nWhat a whopper!",
            HAS_ITEM_LIGHT = "Hey, a lot of hard work went into growing that thing!",
			BURNING = "I knew that thing looked like a fire hazard waiting to happen...",
			BURNT = "Alright everyone, back to it!",
        },

        CARROT_OVERSIZED = "A big bunch of carrots.",
        CORN_OVERSIZED = "Who wants some corn on the cob? There's plenty to go around!",
        PUMPKIN_OVERSIZED = "Hey there, gourd lookin'! Ha!",
        EGGPLANT_OVERSIZED = "It sure makes a big impression. Ha!",
        DURIAN_OVERSIZED = "It sure is making a big stink.",
        POMEGRANATE_OVERSIZED = "That's one pumped up pomegranate.",
        DRAGONFRUIT_OVERSIZED = "We'll be eating this stuff for days!",
        WATERMELON_OVERSIZED = "There's enough here to feed a whole work crew!",
        TOMATO_OVERSIZED = "You could make a lot of spaghetti with that.",
        POTATO_OVERSIZED = "Can't have too much potato.",
        ASPARAGUS_OVERSIZED = "I'll bet there's a ton of iron in that.",
        ONION_OVERSIZED = "Who's gonna draw the short straw and have to cut that thing?",
        GARLIC_OVERSIZED = "I'm not scared of a bit of garlic breath.",
        PEPPER_OVERSIZED = "I'd bet that pepper packs a punch!",

        VEGGIE_OVERSIZED_ROTTEN = "Such a waste.",

		FARM_PLANT =
		{
			GENERIC = "A plant.",
			SEED = "It has a lot of work ahead of it.",
			GROWING = "Seems to be coming along.",
			FULL = "Time to harvest!",
			ROTTEN = "Should've picked it sooner.",
			FULL_OVERSIZED = "Woo-wee, that's a big one!",
			ROTTEN_OVERSIZED = "Such a waste.",
			FULL_WEED = "Looks like I'd better get to weeding.",

			BURNING = "Not the crops!",
		},

        FRUITFLY = "Get outta here! Shoo!",
        LORDFRUITFLY = "You think you can just come in here and lord over my garden?",
        FRIENDLYFRUITFLY = "Now this one's a good little worker!",
        FRUITFLYFRUIT = "Now I'm the boss!",

        SEEDPOUCH = "Gotta stay organized!",

		-- Crow Carnival
		CARNIVAL_HOST = "That's one fancy crow.",
		CARNIVAL_CROWKID = "Aww, hey little guy!",
		CARNIVAL_GAMETOKEN = "I haven't been to a fair since I was a kid!",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "I wonder if I can get anything for one ticket...",
			GENERIC_SMALLSTACK = "I've got a decent pile of tickets going!",
			GENERIC_LARGESTACK = "Now we're talkin'! Let's take a look at those prizes!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "Looks like a tripping hazard to me.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "Yeesh, that mama bird sure has a lot of mouths to feed.",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "I'll have that set up lickety-split.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "They're gonna make my hands all grubby. Ha!",

		CARNIVALGAME_MEMORY_KIT = "These birds can't build their own carnival?",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "Let's get crackin'! Ha!",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "Looks like a tripping hazard to me.",
			PLAYING = "It's gotta be that one!",
		},

		CARNIVALGAME_HERDING_KIT = "Gotta work before you can play.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "Those are some real free-running eggs!",
		},
		CARNIVALGAME_HERDING_CHICK = "I'm gonna getcha!",

		CARNIVALGAME_SHOOTING_KIT = "Gotta work before you can play.",
		CARNIVALGAME_SHOOTING_STATION =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "I pride myself on being a straight-shooter! Ha!",
		},
		CARNIVALGAME_SHOOTING_TARGET =
		{
			GENERIC = "Looks like a tripping hazard to me.",
			PLAYING = "Time for some pest control.",
		},

		CARNIVALGAME_SHOOTING_BUTTON =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "None of the buttons back at the factory were this fancy.",
		},

		CARNIVALGAME_WHEELSPIN_KIT = "Gotta work before you can play.",
		CARNIVALGAME_WHEELSPIN_STATION =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "Well would ya look at that, I'm winning!",
		},

		CARNIVALGAME_PUCKDROP_KIT = "Gotta work before you can play.",
		CARNIVALGAME_PUCKDROP_STATION =
		{
			GENERIC = "Looks like I just need a token to play.",
			PLAYING = "That little ball's got a mind of its own.",
		},

		CARNIVAL_PRIZEBOOTH_KIT = "A job well done is its own reward, but gettin' a prize is even better!",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Heh, I always had to win the toys for Charlie when we were kids...",
		},

		CARNIVALCANNON_KIT = "Well, this thing's not gonna build itself.",
		CARNIVALCANNON =
		{
			GENERIC = "Looks like it's on break.",
			COOLDOWN = "Now that'll cheer you right up!",
		},

		CARNIVAL_PLAZA_KIT = "Gotta set the foundations for the Cawnival.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Hm... this area could stand to be gussied up a bit.",
			LEVEL_2 = "Lookin' pretty good... but I think we can do even better.",
			LEVEL_3 = "Now that's a fine lookin' tree!",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "Let's get crackin'! Ha!",
		CARNIVALDECOR_EGGRIDE = "Not sure what I should do with this now that I built it...",

		CARNIVALDECOR_LAMP_KIT = "Shouldn't take long to build.",
		CARNIVALDECOR_LAMP = "A bit delicate lookin' for my taste, but at least it works.",
		CARNIVALDECOR_PLANT_KIT = "I'll have that set up in a jiffy.",
		CARNIVALDECOR_PLANT = "You can't exactly hang a swing from it, but it's pretty enough.",
		CARNIVALDECOR_BANNER_KIT = "Shouldn't take long to build.",
		CARNIVALDECOR_BANNER = "It really fancies the place up, doesn't it?",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "Whoever made this did some mighty fine work.",
			UNCOMMON = "Kind of cutesy, but it's growing on me.",
			GENERIC = "I'm not really one for knickknacks.",
		},
		CARNIVALDECOR_FIGURE_KIT = "Alright, I gotta know what's inside...",
		CARNIVALDECOR_FIGURE_KIT_SEASON2 = "Alright, I gotta know what's inside...",

        CARNIVAL_BALL = "You can't beat a good old rubber ball.", --unimplemented
		CARNIVAL_SEEDPACKET = "Looks like a bag of bird food.",
		CARNIVALFOOD_CORNTEA = "Err... refreshing...?",

        CARNIVAL_VEST_A = "That's a nice little scarf.",
        CARNIVAL_VEST_B = "Surprisingly well made, considering it was made by birds.",
        CARNIVAL_VEST_C = "It's actually pretty practical for keepin' cool on hot summer days.",

        -- YOTB
        YOTB_SEWINGMACHINE = "I'm more handy with tape than a needle...",
        YOTB_SEWINGMACHINE_ITEM = "I'll have that put together in a jiffy.",
        YOTB_STAGE = "Is there a circus in town?",
        YOTB_POST =  "A good, sturdy hitching post.",
        YOTB_STAGE_ITEM = "Let's get building!",
        YOTB_POST_ITEM =  "Better roll up my sleeves and get building!",


        YOTB_PATTERN_FRAGMENT_1 = "Looks like a set of instructions, I should try putting a few together.",
        YOTB_PATTERN_FRAGMENT_2 = "Looks like a set of instructions, I should try putting a few together.",
        YOTB_PATTERN_FRAGMENT_3 = "Looks like a set of instructions, I should try putting a few together.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "Well, aren't you a cutie!",
            YOTB = "Wait until the judge get's a load of you!",
        },

        WAR_BLUEPRINT = "I don't know if I want to encourage my beefalo's ornery side.",
        DOLL_BLUEPRINT = "That's a lot of ruffles to sew on...",
        FESTIVE_BLUEPRINT = "Sure is a cheery looking design!",
        ROBOT_BLUEPRINT = "Now this one I can do!",
        NATURE_BLUEPRINT = "Good thing I'm not allergic to pollen.",
        FORMAL_BLUEPRINT = "That's a pretty fancy thing to put on a big shaggy beast.",
        VICTORIAN_BLUEPRINT = "This looks like it involves a lotta fancy needlework...",
        ICE_BLUEPRINT = "Winter gear, huh? Seems practical.",
        BEAST_BLUEPRINT = "Hope it gives me some luck in the contest.",

        BEEF_BELL = "The beefalo sure do like that bell!",

		-- YOT Catcoon
		KITCOONDEN =
		{
			GENERIC = "Lofty housing for tiny kits.",
            BURNT = "Well, hope they can stay with a friend or something.",
			PLAYING_HIDEANDSEEK = "They're out and about.",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "",
		},

		KITCOONDEN_KIT = "We'll make a nice home for the kitcoons.",

		TICOON =
		{
			GENERIC = "Huh. Never thought I'd see the day when the fat cats work for ME.",
			ABANDONED = "Looks like I'm finding them on my own.",
			SUCCESS = "Good eye, big guy!",
			LOST_TRACK = "Looks like someone else got to this kit first.",
			NEARBY = "I get the feelin' there's a kitcoon around here.",
			TRACKING = "Oh, he's caught a scent.",
			TRACKING_NOT_MINE = "That one's workin' for someone else.",
			NOTHING_TO_TRACK = "He's not catchin' any more scent trails.",
			TARGET_TOO_FAR_AWAY = "Might be a bit too far.",
		},

		YOT_CATCOONSHRINE =
        {
            GENERIC = "This little fella's a beacon of inspiration.",
            EMPTY = "I wonder what kinda offering it's waiting for?",
            BURNT = "Aww. I was using that.",
        },

		KITCOON_FOREST = "A clever little thing.",
		KITCOON_SAVANNA = "A clever little thing.",
		KITCOON_MARSH = "A clever little thing.",
		KITCOON_DECIDUOUS = "A clever little thing.",
		KITCOON_GRASS = "A clever little thing.",
		KITCOON_ROCKY = "A clever little thing.",
		KITCOON_DESERT = "A clever little thing.",
		KITCOON_MOON = "A clever little thing.",
		KITCOON_YOT = "A clever little thing.",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "That thing went and busted up all our hard work!",
            DEAD = "Well, glad that's done with.",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "Uh-oh, the gloves are really comin' off now.",
            DEAD = "Yeesh, this thing doesn't know when to quit!",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "Some pretty slap-dash construction work, if you ask me.",
        ALTERGUARDIAN_PHASE3 = "Next time I see the bossman I'm asking for extra hazard pay...",
        ALTERGUARDIAN_PHASE3TRAP = "Nice try, you won't catch me sleeping on the job!",
        ALTERGUARDIAN_PHASE3DEADORB = "Mr. Wagstaff... did you plan for this?",
        ALTERGUARDIAN_PHASE3DEAD = "Might as well salvage what we can from what's left.",

        ALTERGUARDIANHAT = "It's a pretty heady experience havin' that much power. Ha...",
        ALTERGUARDIANHATSHARD = "There's still a heck of a lot of power left in this one little piece.",

        MOONSTORM_GLASS = {
            GENERIC = "That's some good, workable material there.",
            INFUSED = "It's been powered up."
        },

        MOONSTORM_STATIC = "Looks like an electrical fire waiting to happen.",
        MOONSTORM_STATIC_ITEM = "The boss really does have a gadget for everything.",
        MOONSTORM_SPARK = "Not quite electricity, but it could still work...",

        BIRD_MUTANT = "That bird gives me the creeps.",
        BIRD_MUTANT_SPITTER = "There's something... off about it.",

        WAGSTAFF_NPC = "Mr. Wagstaff! Is that really you?",

        WAGSTAFF_NPC_MUTATIONS = "Er, will I be gettin' overtime for this?",
        WAGSTAFF_NPC_WAGPUNK = "Hey! Wait up!",

        ALTERGUARDIAN_CONTAINED = "The machine's sucking up all the energy from that thing...",

        WAGSTAFF_TOOL_1 = "Found the Reticulating Buffer! Better get it back to the bossman.",
        WAGSTAFF_TOOL_2 = "There's the boss' Widget Deflubber!",
        WAGSTAFF_TOOL_3 = "Hey, that looks like a Grommet Scriber!",
        WAGSTAFF_TOOL_4 = "Ha! Found you, you sneaky old Conceptual Scrubber!",
        WAGSTAFF_TOOL_5 = "There's the Calibrated Perceiver! Almost missed it.",

        MOONSTORM_GOGGLESHAT = "You work with the materials you've got out here.",

        MOON_DEVICE = {
            GENERIC = "Wonder what the boss is gonna use all this energy for?",
            CONSTRUCTION1 = "Feels kinda like old times back at the factory.",
            CONSTRUCTION2 = "Well, it's not shaping up to be a portal. I was hopin' the boss had figured out a way back...",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "I wouldn't mind takin' a look at its inner workings.",
			RECHARGING = "Doesn't look like it's in working condition right now.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "I wouldn't mind takin' a look at its inner workings.",
			RECHARGING = "Doesn't look like it's in working condition right now.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "I wouldn't mind takin' a look at its inner workings.",
			RECHARGING = "Doesn't look like it's in working condition right now.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "I wouldn't mind takin' a look at its inner workings.",
			RECHARGING = "Doesn't look like it's in working condition right now.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "I wouldn't mind takin' a look at its inner workings.",
			RECHARGING = "Doesn't look like it's in working condition right now.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Yeesh, that thing looks like it packs a wallop.",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Looks kinda shady if you ask me.",
        POCKETWATCH_DISMANTLER = "Wish I'd had the chance to grab some of my tools before I got here.",

        POCKETWATCH_PORTAL_ENTRANCE =
		{
			GENERIC = "I must be off my rocker to think about jumping into another portal...",
			DIFFERENTSHARD = "I must be off my rocker to think about jumping into another portal...",
		},
        POCKETWATCH_PORTAL_EXIT = "Pretty sure putting it at that height is a safety violation.",

        -- Waterlog
        WATERTREE_PILLAR = "Yeesh, look at the size of that thing!",
        OCEANTREE = "Must be a really stubborn tree to be able to grow out here.",
        OCEANTREENUT = "Turns out it's not a tough nut to crack.",
        WATERTREE_ROOT = "Let's get to the root of this problem. Ha!",

        OCEANTREE_PILLAR = "It's no industrial ice flinger, but it'll help me beat the heat.",

        OCEANVINE = "That's all vine and dandy. Ha!",
        FIG = "Never tried one back home, seemed too fancy-shmancy for me.",
        FIG_COOKED = "A bit hoity-toity, but I've gotta admit it's pretty tasty.",

        SPIDER_WATER = "You and your creepy long legs better stay far away from me!",
        MUTATOR_WATER = "I don't think I'll be takin' a bite out of that.",
        OCEANVINE_COCOON = "I'm... trying not to think about how many of those are probably dangling above us.",
        OCEANVINE_COCOON_BURNT = "One less to worry about.",

        GRASSGATOR = "How can he see anything like that?",

        TREEGROWTHSOLUTION = "Alright trees, come get your grub!",

        FIGATONI = "Gotta say, that's good eatin'!",
        FIGKABAB = "Just the kind of thing you'd want on your lunch break.",
        KOALEFIG_TRUNK = "Looks like some really snooty food. Ha!",
        FROGNEWTON = "Surprisingly tasty.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "Something feels off about this... sure is pretty, though.",
            CRIMSON = "Yeesh, that little tree sure isn't looking good.",
            ENABLED = "Yikes! A power surge!",
			WAITING_FOR_DARK = "It's working up to something...",
			COOLDOWN = "Guess it's on its lunch break.",
			SPAWN_DISABLED = "Looks like it's out of order.",
        },

        -- Wolfgang
        MIGHTY_GYM =
        {
            GENERIC = "I might've helped him a little bit on the mechanical side of things.",
            BURNT = "Aw shoot, I hope the big guy isn't too upset.",
        },

        DUMBBELL = "Why not do some real work instead of just liftin' these things?",
        DUMBBELL_GOLDEN = "Awful fancy for something you just pick up and put down over and over.",
		DUMBBELL_MARBLE = "Awful fancy for something you just pick up and put down over and over.",
        DUMBBELL_GEM = "Awful fancy for something you just pick up and put down over and over.",
        POTATOSACK = "Always nice to have a snack on hand when you're workin'.",

        DUMBBELL_HEAT = "Is that what he uses for a warm-up?",
        DUMBBELL_REDGEM = "You'll really be feelin' the burn! Ha!",
        DUMBBELL_BLUEGEM = "Better get some ice on that!",

        TERRARIUMCHEST =
		{
			GENERIC = "Well, a free chest's a free chest.",
			BURNT = "Easy come, easy go.",
			SHIMMER = "Why does that chest look like it's short-circuiting?",
		},

		EYEMASKHAT = "Guess I'll really be seein' the world through different eyes.",

        EYEOFTERROR = "Yeesh, what an eyesore.",
        EYEOFTERROR_MINI = "Can't fault them for doing their job with the big overseer right there.",
        EYEOFTERROR_MINI_GROUNDED = "You'd think I'd be used to this kind of thing by now.",

        FROZENBANANADAIQUIRI = "Perfect after a long day of work.",
        BUNNYSTEW = "I'm so hungry I could eat a... bunny?",
        MILKYWHITES = "That's not appetizing..",

        CRITTER_EYEOFTERROR = "I spy with my little guy...",

        SHIELDOFTERROR ="I can't bring myself to let good machinery go to waste.",
        TWINOFTERROR1 = "You really can't help but admire the craftsmanship.",
        TWINOFTERROR2 = "C'mon, I only want to take you apart a little!",

		-- Cult of the Lamb
		COTL_TRINKET = "Awfully high-and-mighty, huh?",
		TURF_COTL_GOLD = "Couldn't that gold have been used for somethin' more practical?",
		TURF_COTL_BRICK = "Some good, dependable bricks.",
		COTL_TABERNACLE_LEVEL1 =
		{
			LIT = "A little elbow grease, and it'll look good as new.",
			GENERIC = "Looks like the fire's outta fuel.",
		},
		COTL_TABERNACLE_LEVEL2 =
		{
			LIT = "Now that's a well-built statue!",
			GENERIC = "Looks like the fire's outta fuel.",
		},
		COTL_TABERNACLE_LEVEL3 =
		{
			LIT = "Polished and gleaming!",
			GENERIC = "Looks like the fire's outta fuel.",
		},

        -- Year of the Catcoon
        CATTOY_MOUSE = "I think it's got a squeaky wheel.",
        KITCOON_NAMETAG = "Name tags can be pretty handy in the workplace.",

		KITCOONDECOR1 =
        {
            GENERIC = "Not the most productive use of their time... but it sure is cute.",
            BURNT = "They won't be playing with that anytime soon.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "The kits sure seem to like it.",
            BURNT = "They really shouldn't make these things so flammable.",
        },

		KITCOONDECOR1_KIT = "I've always been a do-it-yourself kinda gal.",
		KITCOONDECOR2_KIT = "All it needs now is a bit of elbow grease.",

        -- WX78
        WX78MODULE_MAXHEALTH = "WX, you gotta stop leavin' this stuff lying around!",
        WX78MODULE_MAXSANITY1 = "WX, you gotta stop leavin' this stuff lying around!",
        WX78MODULE_MAXSANITY = "WX, you gotta stop leavin' this stuff lying around!",
        WX78MODULE_MOVESPEED = "They've really gotta start takin' better care of themselves.",
        WX78MODULE_MOVESPEED2 = "They've really gotta start takin' better care of themselves.",
        WX78MODULE_HEAT = "Hey WX, if you're needin' a charge, just let me know!",
        WX78MODULE_NIGHTVISION = "Hey WX, if you're needin' a charge, just let me know!",
        WX78MODULE_COLD = "WX, you gotta stop leavin' this stuff lying around!",
        WX78MODULE_TASER = "They've really gotta start takin' better care of themselves.",
        WX78MODULE_LIGHT = "Hey WX, if you're needin' a charge, just let me know!",
        WX78MODULE_MAXHUNGER1 = "WX, you gotta stop leavin' this stuff lying around!",
        WX78MODULE_MAXHUNGER = "WX, you gotta stop leavin' this stuff lying around!",
        WX78MODULE_MUSIC = "Hey WX, if you're needin' a charge, just let me know!",
        WX78MODULE_BEE = "They've really gotta start takin' better care of themselves.",
        WX78MODULE_MAXHEALTH2 = "Hey WX, if you're needin' a charge, just let me know!",

        WX78_SCANNER =
        {
            GENERIC ="Keepin' busy, Jimmy?",
            HUNTING = "Keepin' busy, Jimmy?",
            SCANNING = "Keepin' busy, Jimmy?",
        },

        WX78_SCANNER_ITEM = "Must be on break.",
        WX78_SCANNER_SUCCEEDED = "He's signalling his supervisor.",

        WX78_MODULEREMOVER = "Sheesh, they could just ask for my help!",

        SCANDATA = "Yeesh, this stuff would make ol' Wickerbottom's writing seem flowery.",

		-- QOL 2022
		JUSTEGGS = "Nice and simple.",
		VEGGIEOMLET = "Less dishes to wash if you leave it in the pan.",
		TALLEGGS = "What's this, some kinda fancy boiled egg?",
		BEEFALOFEED = "Feedin' time!",
		BEEFALOTREAT = "My beefalo's been pulling her weight, she should get a reward.",

        -- Pirates
        BOAT_ROTATOR = "Controllin' the boat rotation is mighty useful.",
        BOAT_ROTATOR_KIT = "Time to put this doo-hickey to the test.",
        BOAT_BUMPER_KELP = "Slimy, but it'll do for securin' the boat some more.",
        BOAT_BUMPER_KELP_KIT = "Extra protection's always good, 'specially on water.",
		BOAT_BUMPER_SHELL = "Turns out seashells are good for givin' shellter from the sea. Ha!",
        BOAT_BUMPER_SHELL_KIT = "Extra protection's always good, 'specially on water.",
        BOAT_BUMPER_CRABKING = "It sometimes pays to have a tough exterior.",
        BOAT_BUMPER_CRABKING_KIT = "Extra protection's always good, 'specially on water.",

        BOAT_CANNON = {
            GENERIC = "It won't do much good if it's not loaded.",
            AMMOLOADED = "All you sea critters better think twice about messing with my boat!",
            NOAMMO = "I won't be able to do much without some cannonballs.",
        },
        BOAT_CANNON_KIT = "I'll get 'er firin' ready in no time.",
        CANNONBALL_ROCK_ITEM = "Better load this in the cannon.",

        OCEAN_TRAWLER = {
            GENERIC = "It does all the fishin' so I'm free to work on other things.",
            LOWERED = "Ain't technology great?",
            CAUGHT = "Looks like we've got fish for dinner!",
            ESCAPED = "Shoot, guess I should've come back sooner.",
            FIXED = "Fixed up, good as new!",
        },
        OCEAN_TRAWLER_KIT = "This'll be ready in a lick.",

        BOAT_MAGNET =
        {
            GENERIC = "Hands-free sailing, pretty nifty.",
            ACTIVATED = "Leaves my hands free for other work!",
        },
        BOAT_MAGNET_KIT = "I think I get the gist, just gotta put it together.",

        BOAT_MAGNET_BEACON =
        {
            GENERIC = "It'll be handy if it works.",
            ACTIVATED = "I'm not sayin' I'm surprised it works, but...",
        },
        DOCK_KIT = "Leave the dock buildin' to me.",
        DOCK_WOODPOSTS_ITEM = "I don't like seeing \"spare\" parts lyin' around...",

        MONKEYHUT =
        {
            GENERIC = "Looks pretty rickety to me.",
            BURNT = "I don't think it was up to code.",
        },
        POWDER_MONKEY = "He looks like he wants to start some trouble.",
        PRIME_MATE = "Yeesh, what an ugly mug.",
		LIGHTCRAB = "I guess crabs can glow now, huh?",
        CUTLESS = "Looks more like a toy than a sword.",
        CURSED_MONKEY_TOKEN = "Charm bracelets were never really my thing.",
        OAR_MONKEY = "Pretty sure that's not how yer s'posed to use a paddle.",
        BANANABUSH = "Sure beats goin' down to the caves.",
        DUG_BANANABUSH = "Sure beats goin' down to the caves.",
        PALMCONETREE = "That's gotta be one of those tropical trees.",
        PALMCONE_SEED = "This could become a tree with a bit of work.",
        PALMCONE_SAPLING = "Not much of a tree yet, but it'll get there.",
        PALMCONE_SCALE = "Looks like a durable building material.",
        MONKEYTAIL = "Those are some tall tails, I tell ya!",
        DUG_MONKEYTAIL = "Those are some tall tails, I tell ya!",

        MONKEY_MEDIUMHAT = "Dress for the job you want.",
        MONKEY_SMALLHAT = "Keeps the sun off your head and the hair outta your face.",
        POLLY_ROGERSHAT = "That's a real feather in my cap. Ha!",
        POLLY_ROGERS = "Nice to have a little extra help around here.",

        MONKEYISLAND_PORTAL = "Something ain't right about it.",
        MONKEYISLAND_PORTAL_DEBRIS = "This looks like the bossman's... but what was he doing out here?",
        MONKEYQUEEN = "She must be one of the higher-ups.",
        MONKEYPILLAR = "Looks shoddy, but it's stable somehow.",
        PIRATE_FLAG_POLE = "They're surprisingly artistic for a bunch of monkeys.",

        BLACKFLAG = "Not the cheeriest, is it?",
        PIRATE_STASH = "I think this is the place.",
        STASH_MAP = "Might find some loot if I follow this.",

        BANANAJUICE = "Would ya look at that, you can juice 'em too!",

        FENCE_ROTATOR = "There's a right tool for every job.",

        CHARLIE_STAGE_POST = "Who'd build a stage out here? Oh...",
        CHARLIE_LECTURN = "Everyone's got their part to play, huh?",

        CHARLIE_HECKLER = "You can't please everyone.",

        PLAYBILL_THE_DOLL = "Somehow I think there's more to the story.",
        STATUEHARP_HEDGESPAWNER = "Yeesh, this place needs a good pruning.",
        HEDGEHOUND = "You're gettin' to be a real thorn in my side!",
        HEDGEHOUND_BUSH = "Why am I gettin' a bad feeling...",

        MASK_DOLLHAT = "Why do I feel like it's lookin' at me?",
        MASK_DOLLBROKENHAT = "Why do I feel like it's lookin' at me?",
        MASK_DOLLREPAIREDHAT = "Why do I feel like it's lookin' at me?",
        MASK_BLACKSMITHHAT = "Why do I feel like it's lookin' at me?",
        MASK_MIRRORHAT = "Why do I feel like it's lookin' at me?",
        MASK_QUEENHAT = "Why do I feel like it's lookin' at me?",
        MASK_KINGHAT = "Why do I feel like it's lookin' at me?",
        MASK_TREEHAT = "Why do I feel like it's lookin' at me?",
        MASK_FOOLHAT = "Why do I feel like it's lookin' at me?",

        COSTUME_DOLL_BODY = "Looks like a doll's costume.",
        COSTUME_QUEEN_BODY = "Looks like a Queen's costume.",
        COSTUME_KING_BODY = "Looks like a King's costume.",
        COSTUME_BLACKSMITH_BODY = "Hey, that looks like it'll fit me!",
        COSTUME_MIRROR_BODY = "Looks like some kind of costume.",
        COSTUME_TREE_BODY = "Looks like a tree costume.",
        COSTUME_FOOL_BODY = "Looks like a jester costume.",

        STAGEUSHER =
        {
            STANDING = "Shoo!",
            SITTING = "Why's this table givin' me the creeps?",
        },
        SEWING_MANNEQUIN =
        {
            GENERIC = "Lookin' good!",
            BURNT = "Yeesh, looks like this one's toast.",
        },

		-- Waxwell
		MAGICIAN_CHEST = "I dunno if I want to stick my hand in there.",
		TOPHAT_MAGICIAN = "Max is a little too good at keepin' things under his hat.",

        -- Year of the Rabbit
        YOTR_FIGHTRING_KIT = "Better get buildin'!",
        YOTR_FIGHTRING_BELL =
        {
            GENERIC = "Heh. Being an older sister trained me well for this.",
            PLAYING = "Looks like a good way to let off some steam.",
        },

        YOTR_DECOR_1 = {
            GENERAL = "A little rustic for my tastes, but functional enough.",
            OUT = "It ain't much to look at without its light.",
        },
        YOTR_DECOR_2 = {
            GENERAL = "A little rustic for my tastes, but functional enough.",
            OUT = "It ain't much to look at without its light.",
        },

        HAREBALL = "Yuck!",
        YOTR_DECOR_1_ITEM = "Gotta find a good place for it.",
        YOTR_DECOR_2_ITEM = "Gotta find a good place for it.",

		--
		DREADSTONE = "It's evil-lookin', but tough as nails.",
		HORRORFUEL = "Makes the usual nightmare goop look almost pleasant by comparison.",
		DAYWALKER =
		{
			GENERIC = "Yeesh big guy, I was just tryin' to help you out!",
			IMPRISONED = "That pig's seen better days.",
		},
		DAYWALKER_PILLAR =
		{
			GENERIC = "That marble doesn't look structurally sound to me.",
			EXPOSED = "I stand corrected. That rock ain't goin' nowhere.",
		},
		DAYWALKER2 =
		{
			GENERIC = "He seems to be minding his own business.",
			BURIED = "He sure is in a sorry state.",
			HOSTILE = "Take it easy, big boy!",
		},
		ARMORDREADSTONE = "That's some real high-grade protective equipment.",
		DREADSTONEHAT = "Lookin' sharp! Literally.",

        -- Rifts 1
        LUNARRIFT_PORTAL = "That tear's a bit beyond what my trusty tape can fix.",
        LUNARRIFT_CRYSTAL = "It's about the prettiest tripping hazard you'll ever see.",

        LUNARTHRALL_PLANT = "It thinks this is its turf!",
        LUNARTHRALL_PLANT_VINE_END = "You think you wanna tangle with me?",

		LUNAR_GRAZER = "I'm not about to let it catch me sleepin'!",

        PUREBRILLIANCE = "I ain't dazzled by much, but that'll do it.",
        LUNARPLANT_HUSK = "That's tough stuff!",

		LUNAR_FORGE = "It's givin' me some bright ideas.",
		LUNAR_FORGE_KIT = "Let's get this thing up and running!",

		LUNARPLANT_KIT = "Never hurts to keep a repair kit handy.",
		ARMOR_LUNARPLANT = "Built to last!",
		LUNARPLANTHAT = "It should keep my noggin' nice and safe.",
		BOMB_LUNARPLANT = "Anyone call for a demolition crew?",
		STAFF_LUNARPLANT = "Another magical doodad?",
		SWORD_LUNARPLANT = "It's a cut above most other swords I've seen. Ha!",
		PICKAXE_LUNARPLANT = "Sure makes mining a breeze.",
		SHOVEL_LUNARPLANT = "It makes digging things up almost too easy.",

		BROKEN_FORGEDITEM = "I bet I could get it back in working order.",

        PUNCHINGBAG = "Whatcha say? Wanna go a few rounds?",

        -- Rifts 2
        SHADOWRIFT_PORTAL = "This place is falling apart at the seams.",

		SHADOW_FORGE = "Might as well put the shadows to work.",
		SHADOW_FORGE_KIT = "Just needs a bit of elbow grease.",

        FUSED_SHADELING = "I don't like the look of those chompers.",
        FUSED_SHADELING_BOMB = "Watch out, it's gonna blow!",

		VOIDCLOTH = "I can work with any material.",
		VOIDCLOTH_KIT = "Never hurts to keep a repair kit handy.",
		VOIDCLOTHHAT = "Some folks think it's safer to be kept in the dark.",
		ARMOR_VOIDCLOTH = "Looks pretty tattered, will it really protect me from anything?",

        VOIDCLOTH_UMBRELLA = "It sure provides plenty of shade.",
        VOIDCLOTH_SCYTHE = "It gives me the creeps, but it sure works like a charm.",

		SHADOWTHRALL_HANDS = "What? Mad I left ya hanging?",
		SHADOWTHRALL_HORNS = "It's gonna chew me up and spit me back out! Literally!",
		SHADOWTHRALL_WINGS = "Must be one of the higher-ups. Ha...",

        CHARLIE_NPC = "Charlie, wait!!",
        CHARLIE_HAND = "You want something, huh?",

        NITRE_FORMATION = "Oh, I've got big plans for that!",
        DREADSTONE_STACK = "Must be a lot of the stuff growing down there.",
        
        SCRAPBOOK_PAGE = "Let's see if there's anything interesting written on it.",

        LEIF_IDOL = "That's some quality carving, there.",
        WOODCARVEDHAT = "Gotta keep the old noggin' safe on the work site.",
        WALKING_STICK = "Woodie and Lucy really stick together, huh?",

        IPECACSYRUP = "That stuff can't be good for your health.",
        BOMB_LUNARPLANT_WORMWOOD = "I think that little green fella did some tinkering.", -- Unused
        WORMWOOD_MUTANTPROXY_CARRAT =
        {
        	DEAD = "That don't look good.",
        	GENERIC = "Yer an orange nuisance, aintcha?",
        	HELD = "Aw, I can't stay mad at you.",
        	SLEEPING = "Sleep tight.",
        },
        WORMWOOD_MUTANTPROXY_LIGHTFLIER = "Doesn't even need a battery!",
		WORMWOOD_MUTANTPROXY_FRUITDRAGON =
		{
			GENERIC = "You play nice with the other lizards now, hey?",
			RIPE = "Lookit you, all orange!",
			SLEEPING = "I hope you earned that break.",
		},

        SUPPORT_PILLAR_SCAFFOLD = "Looks like there's some buildin' to be done!",
        SUPPORT_PILLAR = "Looks like it could use some repairs.",
        SUPPORT_PILLAR_COMPLETE = "Good and sturdy!",
        SUPPORT_PILLAR_BROKEN = "I'd better roll up my sleeves and get to rebuildin'.",

		SUPPORT_PILLAR_DREADSTONE_SCAFFOLD = "Looks like there's some buildin' to be done!",
		SUPPORT_PILLAR_DREADSTONE = "Looks like it could use some repairs.",
		SUPPORT_PILLAR_DREADSTONE_COMPLETE = "Now that's one mean lookin' pillar!",
		SUPPORT_PILLAR_DREADSTONE_BROKEN = "Well don't just look at it. Let's get to fixin'.",

        WOLFGANG_WHISTLE = "Whatcha need, coach?",

        -- Rifts 3

        MUTATEDDEERCLOPS = "Shoulda wore safety goggles. Or is it goggle?",
        MUTATEDWARG = "Whose yard did you get out of?",
        MUTATEDBEARGER = "Grumpy hasn't had his mornin' cup of joe yet.",

        LUNARFROG = "Hop along now, lil' freakshow.",

        DEERCLOPSCORPSE =
        {
            GENERIC  = "She's the deerly departed.",
            BURNING  = "There's no comin' back from that.",
            REVIVING = "That just ain't right.",
        },

        WARGCORPSE =
        {
            GENERIC  = "I'm sure someone loved this monstrous mutt.",
            BURNING  = "Is that really necessary?",
            REVIVING = "There's nothing in the manual about this.",
        },

        BEARGERCORPSE =
        {
            GENERIC  = "Big boy took the ol' dirt nap.",
            BURNING  = "He'll be smokin' for days.",
            REVIVING = "Oh boy...",
        },

        BEARGERFUR_SACK = "Weirdest lunch bucket I've ever seen.",
        HOUNDSTOOTH_BLOWPIPE = "Shoots dog teeth? What will they think of next?",
        DEERCLOPSEYEBALL_SENTRYWARD =
        {
            GENERIC = "That is one creepy refrigeration unit.",    -- Enabled.
            NOEYEBALL = "It needs that spooky ol' eye to work.",  -- Disabled.
        },
        DEERCLOPSEYEBALL_SENTRYWARD_KIT = "Time to roll up the ol' sleeves!",

        SECURITY_PULSE_CAGE = "Well, there's a whole lotta nothin' inside.",
        SECURITY_PULSE_CAGE_FULL = "Sure it's bright, but what else does it do?",

		CARPENTRY_STATION =
        {
            GENERIC = "I... love you.",
            BURNT = "You didn't deserve this.",
        },

        WOOD_TABLE = -- Shared between the round and square tables.
        {
            GENERIC = "I don't care if it's fancy, just solidly built.",
            HAS_ITEM = "It's doin' what tables do.",
            BURNT = "A shame to see that craftsmanship go to waste.",
        },

        WOOD_CHAIR =
        {
            GENERIC = "Looks sturdy enough.",
            OCCUPIED = "Looks like that seat's spoken for.",
            BURNT = "I ain't one to sit around anyway.",
        },

        DECOR_CENTERPIECE = "Looks like some frou-frou clutter to me.",
        DECOR_LAMP = "A good lamp will keep ya workin' through the night!",
        DECOR_FLOWERVASE =
        {
            GENERIC = "Lookin' fresh as a daisy!",
            EMPTY = "Looks nice enough, but it feels kinda empty.",
            WILTED = "I think it's time to retire this one.",
            FRESHLIGHT = "It ain't a lamp, but it'll work.",
            OLDLIGHT = "That's not gonna last much longer.",
        },
        DECOR_PICTUREFRAME =
        {
            GENERIC = "One of them highbrow \"still life\" pieces, huh?",
            UNDRAWN = "That frame looks kinda plain with nothin' in it.",
        },
        DECOR_PORTRAITFRAME = "It's a pretty good likeness.",

        PHONOGRAPH = "Nothin' like some music to get through the workday faster.",
        RECORD = "Just plain unsettlin'.",
        RECORD_CREEPYFOREST = "That's a real toe-tapper!",
        RECORD_DANGER = "This ain't at all relaxin'.",
        RECORD_DAWN = "Here we go.",
        RECORD_DRSTYLE = "She's a doozy.",
        RECORD_DUSK = "Rather somber, ain't it?",
        RECORD_EFS = "Here we go.",
        RECORD_END = "Not my cupa.",
        RECORD_MAIN = "Here we go.",
        RECORD_WORKTOBEDONE = "Work up a sweat with this one.",

        ARCHIVE_ORCHESTRINA_MAIN = "Some mighty complicated engineering went into this.",

        WAGPUNKHAT = "Love me a steam-powered murder helmet as much as the next gal but clunky much?",
        ARMORWAGPUNK = "Well ain't that a fancy lil' robo-romper.",
        WAGSTAFF_MACHINERY = "I bet I could break this stuff down for parts.",
        WAGPUNK_BITS = "Don't let its looks fool you, these are some high-quality parts!",
        WAGPUNKBITS_KIT = "Nifty!",

        WAGSTAFF_MUTATIONS_NOTE = "Some interestin' theories here...",

        -- Meta 3

        BATTLESONG_INSTANT_REVIVE = "Opera's a bit hoity-toity for me.",

        WATHGRITHR_IMPROVEDHAT = "Wonder if it's made from real unicorn...",
        SPEAR_WATHGRITHR_LIGHTNING = "A lightning spear? What will they think of next?",

        BATTLESONG_CONTAINER = "That is some fancy song holder.",

        SADDLE_WATHGRITHR = "Goin' for that understated look, I see.",

        WATHGRITHR_SHIELD = "Nothin' more practical than a good sturdy shield.",

        BATTLESONG_SHADOWALIGNED = "Opera's a bit hoity-toity for me.",
        BATTLESONG_LUNARALIGNED = "Opera's a bit hoity-toity for me.",

		SHARKBOI = "You picked the wrong gal to mess with!",
        BOOTLEG = "Guess I'd better shake a leg. Ha!",
        OCEANWHIRLPORTAL = "Alright, time to sink or swim!",

        EMBERLIGHT = "Nice and toasty.",
        WILLOW_EMBER = "only_used_by_willow",

        -- Year of the Dragon
        YOTD_DRAGONSHRINE =
        {
            GENERIC = "Let's see whatcha got!",
            EMPTY = "You want some charcoal to snack on?",
            BURNT = "Guess I should've seen that coming.",
        },

        DRAGONBOAT_KIT = "It's not gonna build itself.",
        DRAGONBOAT_PACK = "This baby's got everything you need!",

        BOATRACE_CHECKPOINT = "Checkpoint ahead!",
        BOATRACE_CHECKPOINT_THROWABLE_DEPLOYKIT = "Better roll up my sleeves and get to buildin'.",
        BOATRACE_START = "No sense stallin', let's go!",
        BOATRACE_START_THROWABLE_DEPLOYKIT = "Better get started!",

        BOATRACE_PRIMEMATE = "Tryin' to throw a monkeywrench in my race, sis?",
        BOATRACE_SPECTATOR_DRAGONLING = "Must be the new supervisor.",

        YOTD_STEERINGWHEEL = "Good thing I've got a great sense of direction.",
        YOTD_STEERINGWHEEL_ITEM = "That steering wheel ain't gonna assemble itself.",
        YOTD_OAR = "I can always use an extra hand rowing, a claw works too!",
        YOTD_ANCHOR = "Awful fancy for somethin' that'll spend most of its time underwater.",
        YOTD_ANCHOR_ITEM = "Someone's gotta assemble this anchor, might as well be me.",
        MAST_YOTD = "It's gotta be the fanciest sail I've ever seen.",
        MAST_YOTD_ITEM = "I can't wait to build that. I love hoisting things.",
        BOAT_BUMPER_YOTD = "Wouldn't wanna end up on the business end of those fangs.",
        BOAT_BUMPER_YOTD_KIT = "Extra protection's always good, 'specially on water.",
        BOATRACE_SEASTACK = "Buoy ahead!",
        BOATRACE_SEASTACK_THROWABLE_DEPLOYKIT = "Better watch where I throw it, wouldn't wanna bust up someone's boat.",
        BOATRACE_SEASTACK_MONKEY = "Buoy ahead!",
        BOATRACE_SEASTACK_MONKEY_THROWABLE_DEPLOYKIT = "Better watch where I throw it, wouldn't wanna bust up someone's boat.",
        MASTUPGRADE_LAMP_YOTD = "Looks nice perched up there.",
        MASTUPGRADE_LAMP_ITEM_YOTD = "One less thing cluttering up the deck.",
        WALKINGPLANK_YOTD = "Sure it looks nice, but I ain't keen on using it anytime soon.",
        CHESSPIECE_YOTD = "We really brought the heat! Ha!",

        -- Rifts / Meta QoL

        HEALINGSALVE_ACID = "I guess you'd call it an antacid.",

        BEESWAX_SPRAY = "I never liked perfume. Now I like it even less",
        WAXED_PLANT = "It'll stay fresh as a daisy forever.", -- Used for all waxed plants, from farm plants to trees.

        STORAGE_ROBOT = {
            GENERIC = "Industrious lil' fella.",
            BROKEN = "Poor lil' guy is all busted.",
        },

        SCRAP_MONOCLEHAT = "The bossman always said you gotta \"see the bigger picture.\"",
        SCRAPHAT = "Now that's one industrial-strength hardhat!",

        FENCE_JUNK = "It does the trick.",
        JUNK_PILE = "Folks underestimate how much good stuff you can find in a scrap pile.",
        JUNK_PILE_BIG = "Who's in charge here? Someone could get hurt!",

        ARMOR_LUNARPLANT_HUSK = "Pretty well constructed, for a plant.",

        -- Meta 4 / Ocean QoL

        OTTER = "Nasty lil hoarder ain't it?",
        OTTERDEN = {
            GENERIC = "Looks tapped out.",
            HAS_LOOT = "It might have left us some goodies.",
        },
        OTTERDEN_DEAD = "It was definitely holding it all together.",

        BOAT_ANCIENT_ITEM = "They sure don't build 'em like they used to.",
        BOAT_ANCIENT_CONTAINER = "Plenty of space for storage.",
        WALKINGPLANK_ANCIENT = "That thing don't look stable.",

        ANCIENTTREE_SEED = "I believe this goes in the dirt.",

        ANCIENTTREE_GEM = {
            GENERIC = "That tree has got fire in its belly.",
            STUMP = "Just a pile of rubble now.",
        },

        ANCIENTTREE_SAPLING_ITEM = "This might be one of them finicky trees.",

        ANCIENTTREE_SAPLING = {
            GENERIC = "Looks like it's on its way.",
            WRONG_TILE = "Maybe it ain't in the right spot.",
            WRONG_SEASON = "I don't think the time is right.",
        },
 
        ANCIENTTREE_NIGHTVISION = {
            GENERIC = "That is one gloomy tree.",
            STUMP = "Can't say I'm sad to see it gone.",
        },

        ANCIENTFRUIT_GEM = "For a fruit, it's one tough nut to crack.",
        ANCIENTFRUIT_NIGHTVISION = "I don't think berries are supposed to do that.",
        ANCIENTFRUIT_NIGHTVISION_COOKED = "At least it ain't pulsin'.",

        BOATPATCH_KELP = "Just a quick fix until I can do some proper repairs.",

        CRABKING_MOB = "Just a hired hand. Er, claw.",
        CRABKING_MOB_KNIGHT = "I've had supervisors crabbier than him.",
        CRABKING_CANNONTOWER = "There's no way they've got a permit for that.",
        CRABKING_ICEWALL = "Heh. I think this guy's tryin' to ice me out!",

        SALTLICK_IMPROVED = "Do you sea salt?",

        OFFERING_POT =
        {
            GENERIC = "Shucks, I can't just leave it empty!",
            SOME_KELP = "I should add a little more, wouldn't want them to run out.",
            LOTS_OF_KELP = "That should keep'em well fed.",
        },

        OFFERING_POT_UPGRADED =
        {
            GENERIC = "Shucks, I can't just leave it empty!",
            SOME_KELP = "I should add a little more, wouldn't want them to run out.",
            LOTS_OF_KELP = "That should keep'em well fed.",
        },

        MERM_ARMORY = "Get your merm hats here!",
        MERM_ARMORY_UPGRADED = "Get your merm hats here!",
        MERM_TOOLSHED = "I know a toolshed when I see one.",
        MERM_TOOLSHED_UPGRADED = "I know a toolshed when I see one.",
        MERMARMORHAT = "Ain’t my style.",
        MERMARMORUPGRADEDHAT = "Ain’t my style.",
        MERM_TOOL = "Should get the job done... I hope.",
        MERM_TOOL_UPGRADED = "It's an improvement.",

        WURT_SWAMPITEM_SHADOW = "Aw, she made a lil' shadow wand thing.",
        WURT_SWAMPITEM_LUNAR = "Wurt is tappin' into some weird stuff here.",

        MERM_SHADOW = "Can't seem to catch a break, can ya?",
        MERMGUARD_SHADOW = "Whoa, I'll just stay outta your way.",

        MERM_LUNAR = "You're a rather prickly one, ain't ya?",
        MERMGUARD_LUNAR = "I'm sure he's got a sparkling personality.",
    },

    DESCRIBE_GENERIC = "Incredible! I have no idea what that is.",
    DESCRIBE_TOODARK = "Low visibility causes workplace accidents!",
    DESCRIBE_SMOLDERING = "That's gonna start a fire!",

    DESCRIBE_PLANTHAPPY = "Healthy as a horse!",
    DESCRIBE_PLANTVERYSTRESSED = "There's a whole laundry list of things wrong with this one.",
    DESCRIBE_PLANTSTRESSED = "Something's bugging it.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "I'd better get back to weeding.",
    DESCRIBE_PLANTSTRESSORFAMILY = "Guess it's kind of lonely being the only one out here, huh?",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "The poor plants are packed like sardines in this garden!",
    DESCRIBE_PLANTSTRESSORSEASON = "I don't think this is the right season for it.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "You look like you could use some water.",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Better give it some nutrients.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "It needs a good talking to.",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "That crunch was upsetting.",
		WINTERSFEASTFUEL = "I remember the last holiday we spent as a family.",
    },
}
