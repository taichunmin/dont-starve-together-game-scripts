--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Un moment, the judge seems to be occupied.",
        },
        REPAIR =
        {
            WRONGPIECE = "It needs something else.",
        },
        BUILD =
        {
            MOUNTED = "Mon dieu, that's far away.",
            HASPET = "I already have a little companion.",
			TICOON = "Non, that's not the one I'm following.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "It would be unwise to attempt this while the animal is awake.",
			GENERIC = "Not a shaveable beast.",
			NOBITS = "Nothing to shave.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "That would be someone else's animal.",
		},
		STORE =
		{
			GENERIC = "It is too full.",
			NOTALLOWED = "This is not the place for it.",
			INUSE = "Pardonnez-moi, I'll let you finish.",
            NOTMASTERCHEF = "unused_by_warly",
		},
        CONSTRUCT =
        {
            INUSE = "Pardonnez-moi! Someone's already doing that.",
            NOTALLOWED = "This isn't the best place for it.",
            EMPTY = "I'm missing some ingredients.",
            MISMATCH = "I think I've gotten something mixed up.",
        },
		RUMMAGE =
		{
			GENERIC = "I cannot right now.",
			INUSE = "Pardonnez-moi, I'll let you finish.",
            NOTMASTERCHEF = "unused_by_warly",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "This key doesn't fit here.",
        	KLAUS = "I'd like to get to safety first!",
			QUAGMIRE_WRONGKEY = "There must be another key somewhere.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "I'll need a key to get through.",
            HOSTBUSY = "I'll just have to come back later.",
            CARNIVAL_HOST_HERE = "Hello, monsieur? Are you here?",
            NOCARNIVAL = "The festivities seem to be over.",
			EMPTY_CATCOONDEN = "Ah zut, an empty cupboard.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "It would be better with more petits chats, non?",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "Ah, perhaps I should find a place with more hiding spots.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "I'm afraid that's enough playing for one day.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "unused_by_warly",
			SHADOWMAGIC = "Maman used to keep a journal, before her memory went.",
		},
        COOK =
        {
            GENERIC = "I'm not quite ready yet.",
            INUSE = "Pardonnez-moi! I shouldn't backseat cook.",
            TOOFAR = "I'll need to get a little closer to cook with that.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Pardonnez-moi, I was so excited I forgot to find a racer!",
        },

		DISMANTLE =
		{
			COOKING = "Just a little longer... It's almost done.",
			INUSE = "Oh, excusez-moi.",
			NOTEMPTY = "Oops, I've left some ingredients inside.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Ah non, the fish are too deep for my rod to reach.",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "This is a bit much for pond fishing, non?",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "Non.",
            DEAD = "Oh dear...",
            SLEEPING = "It's sleeping.",
            BUSY = "Pardonnez-moi, they seem busy right now.",
            ABIGAILHEART = "Apologies, ma petite choux-fleur.",
            GHOSTHEART = "I don't think they would appreciate it.",
            NOTGEM = "Hmm... Non.",
            WRONGGEM = "It wants a different gem.",
            NOTSTAFF = "I need something long and thin, like a wooden spoon.",
            MUSHROOMFARM_NEEDSSHROOM = "It needs a dash of something else.",
            MUSHROOMFARM_NEEDSLOG = "It needs a dash of something else.",
            MUSHROOMFARM_NOMOONALLOWED = "They don't seem to take well to planting.",
            SLOTFULL = "I'd have to take the other object out first.",
            FOODFULL = "Let them enjoy their meal first.",
            NOTDISH = "It would tarnish my reputation to serve that.",
            DUPLICATE = "We've learned that already.",
            NOTSCULPTABLE = "That doesn't seem right.",
            NOTATRIUMKEY = "It's not quite right.",
            CANTSHADOWREVIVE = "It doesn't seem to be working.",
            WRONGSHADOWFORM = "It looks a little funny, doesn't it?",
            NOMOON = "I imagine I'll need to see the moon for this.",
			PIGKINGGAME_MESSY = "We should sort out this mess first.",
			PIGKINGGAME_DANGER = "It wouldn't be safe right now.",
			PIGKINGGAME_TOOLATE = "It's a bit late in the evening for that.",
			CARNIVALGAME_INVALID_ITEM = "That wasn't to its liking.",
			CARNIVALGAME_ALREADY_PLAYING = "Un moment, the game has already started.",
            SPIDERNOHAT = "I'm afraid that's a bit of a tight squeeze.",
            TERRARIUM_REFUSE = "That doesn't seem to suit its tastes.",
            TERRARIUM_COOLDOWN = "Doesn't look like it's taking, maybe I should try again later.",
        },
        GIVETOPLAYER =
        {
            FULL = "Fuller than a belly at a six course meal.",
            DEAD = "Sadly it won't do them much good.",
            SLEEPING = "They're snoozing right now.",
            BUSY = "They've got other pans in the fire.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "Fuller than a belly at a six course meal.",
            DEAD = "Sadly it won't do them much good.",
            SLEEPING = "They're snoozing right now.",
            BUSY = "They've got other pans in the fire.",
        },
        WRITE =
        {
            GENERIC = "Maybe later. My hands are covered in cooking oil.",
            INUSE = "Oh, excusez-moi.",
        },
        DRAW =
        {
            NOIMAGE = "What should I draw?",
        },
        CHANGEIN =
        {
            GENERIC = "I guess it never occurred to me I'd need to change.",
            BURNING = "It, oh, it appears to be on fire.",
            INUSE = "I should give them their privacy.",
            NOTENOUGHHAIR = "There's not really much to work with at the moment.",
            NOOCCUPANT = "I'll be needing something to groom, non?",
        },
        ATTUNE =
        {
            NOHEALTH = "I would seriously hurt myself if I did.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Mon dieu. It's busy just now.",
            INUSE = "Oh. It must belong to someone else.",
			SLEEPING = "Excusez-moi, but perhaps you can nap later?",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "It's too angry to do that.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Ah. I already knew that.",
            CANTLEARN = "That might be a bit beyond me.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "That doesn't belong in this world, much like myself.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "I think that can wait until I'm back outside.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "There's nothing to wrap.",
        },
        PICKUP =
        {
			RESTRICTION = "I don't think that's for me.",
			INUSE = "Excusez-moi.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Pardonnez-moi, I mistook you for my carrat!",
                "Oh, je m'excuse, have you seen my carrat around here?",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "I don't know if I can catch up.",
        },
        REPLATE =
        {
            MISMATCH = "Non! I can't plate it with this!",
            SAMEDISH = "It's already beautifully plated.",
        },
        SAIL =
        {
        	REPAIR = "I'll have this fixed tout de suite!",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Ah, I must watch my timing!",
            BAD_TIMING1 = "I can bake a soufflé in the wilderness, but I can't do this?",
            BAD_TIMING2 = "Mais non! I must try harder.",
        },
        LOWER_SAIL_FAIL =
        {
            "Non, non!",
            "Quelle horreur!",
            "How embarrassing.",
        },
        BATHBOMB =
        {
            GLASSED = "No need, it's already en glace.",
            ALREADY_BOMBED = "That would be wasteful.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "We've learned that already.",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "Ah non, this fish is far too small.",
            OVERSIZEDVEGGIES_TOO_SMALL = "I'm afraid it's a bit too small.",
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
            GENERIC = "I already know all there is to know about that one.",
            FERTILIZER = "I think I know everything I need to, non?",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Mais non, this salt water will not do!",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "I've poured every last drop.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Not a drop left!",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "That will not work.",
            BEEF_BELL_ALREADY_USED = "It seems quite attached to someone else.",
            BEEF_BELL_HAS_BEEF_ALREADY = "I've already found my perfect cut of beef.",
        },
        HITCHUP =
        {
            NEEDBEEF = "I don't have anything to hitch to it.",
            NEEDBEEF_CLOSER = "I will need my delicious friend to come a bit closer.",
            BEEF_HITCHED = "Already done, mon ami.",
            INMOOD = "Perhaps when it's not in such a foul mood.",
        },
        MARK =
        {
            ALREADY_MARKED = "I've made my selection.",
            NOT_PARTICIPANT = "I'm staying out of the competition for the moment.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Nobody there? C'est la vie.",
            ALREADYACTIVE = "Perhaps there's another contest somewhere else.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "Quel dommage, I already knew that one.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Zut! Too slow!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "I'm afraid they won't listen to me.",
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
            DOER_ISNT_MODULE_OWNER = "I do not think I'm the one it wants to talk to.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Ah non, I'm missing some ingredients!",
		NO_TECH = "I don't know the recipe for that one yet.",
		NO_STATION = "If I had a station with the right tools I could cook that right up...",
	},

	ACTIONFAIL_GENERIC = "I cannot do that.",
	ANNOUNCE_BOAT_LEAK = "Mon dieu! She is sinking!",
	ANNOUNCE_BOAT_SINK = "I don't want to be brined!",
	ANNOUNCE_DIG_DISEASE_WARNING = "I hope that helps.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "It has a most un-delicious smell.", --removed
	ANNOUNCE_ADVENTUREFAIL = "I shall have to attempt that again.",
    ANNOUNCE_MOUNT_LOWHEALTH = "My poor sirloin's not looking so good!",

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

	ANNOUNCE_BEES = "The honeymakers are upon me!",
	ANNOUNCE_BOOMERANG = "Ouch! Damnable thing!",
	ANNOUNCE_CHARLIE = "What the devil!",
	ANNOUNCE_CHARLIE_ATTACK = "Gah! I do believe something bit me!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "I'm... getting freezer burn...",
	ANNOUNCE_HOT = "I'm baking like a soufflé here...",
	ANNOUNCE_CRAFTING_FAIL = "I am lacking the required ingredients.",
	ANNOUNCE_DEERCLOPS = "I do not like that sound one bit!",
	ANNOUNCE_CAVEIN = "This place is crumbling like a dry cookie!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"My soufflé!",
		"Was that my stomach rumbling?",
		"The earth must be very hungry.",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Pour vous.",
        "I hope you like it.",
        "For you, mon amie.",
	},
	ANNOUNCE_SACREDCHEST_YES = "Merci beacoup!",
	ANNOUNCE_SACREDCHEST_NO = "Apologies for my shortcomings.",
    ANNOUNCE_DUSK = "The dinner hour approaches.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Magnifique!",
		PAINFUL = "Aarg! My stomach...",
		SPOILED = "Blech! Why did I allow that to cross my lips?",
		STALE = "That was past its best-by date...",
		INVALID = "Clearly inedible.",
        YUCKY = "I'm frankly offended by the mere suggestion.",

        --Warly specific ANNOUNCE_EAT strings
		COOKED = "Not very palatable.",
		DRIED = "A bit dry.",
        PREPARED = "Delectable!",
        RAW = "Blech. Completely lacking in every way.",
		SAME_OLD_1 = "I'd prefer some variety.",
		SAME_OLD_2 = "So bland.",
		SAME_OLD_3 = "I want to eat something different.",
		SAME_OLD_4 = "I can't stand this food.",
        SAME_OLD_5 = "Enough already!",
		TASTY = "Tres magnifique!",
    },

    ANNOUNCE_ENCUMBERED =
    {
        "I'm not... built for this...",
        "I bet... this is burning some calories...",
        "Oof!",
        "Hrrrr...",
        "Mon dieu!",
        "I'm working up... an appetite!",
        "So... heavy!",
        "I am strong... like flour!",
        "HRR!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"I should like to head for the surface now!",
		"I think it's about time we left!",
		"Time to pack up and go.",
	},
    ANNOUNCE_RUINS_RESET = "The terrible monsters are back!",
    ANNOUNCE_SNARED = "Ouch! How rude!",
    ANNOUNCE_SNARED_IVY = "You think you can come between me and my fresh ingredients, mon ami?",
    ANNOUNCE_REPELLED = "I can't get through!",
	ANNOUNCE_ENTER_DARK = "Darkness, darkness.",
	ANNOUNCE_ENTER_LIGHT = "A new day comes with the dawning light.",
	ANNOUNCE_FREEDOM = "Freeeeeeee!",
	ANNOUNCE_HIGHRESEARCH = "My brain is tingling!",
	ANNOUNCE_HOUNDS = "I recognize that sound. Hunger.",
	ANNOUNCE_WORMS = "Huh? What's that?",
	ANNOUNCE_HUNGRY = "I need food...",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Game is close at hand...",
	ANNOUNCE_HUNT_LOST_TRAIL = "I have lost the trail.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "The trail has been washed out.",
	ANNOUNCE_INV_FULL = "I cannot carry another stitch.",
	ANNOUNCE_KNOCKEDOUT = "My head... spinning...",
	ANNOUNCE_LOWRESEARCH = "I did not learn any new tricks from that.",
	ANNOUNCE_MOSQUITOS = "Disease with wings!",
    ANNOUNCE_NOWARDROBEONFIRE = "Fire!",
    ANNOUNCE_NODANGERGIFT = "I would like to not die first.",
    ANNOUNCE_NOMOUNTEDGIFT = "First I should get down from this big sirloin here.",
	ANNOUNCE_NODANGERSLEEP = "In this particular instance I'd prefer not to die in my sleep!",
	ANNOUNCE_NODAYSLEEP = "It is too bright to sleep.",
	ANNOUNCE_NODAYSLEEP_CAVE = "I'm not tired.",
	ANNOUNCE_NOHUNGERSLEEP = "My hunger trumps my exhaustion.",
	ANNOUNCE_NOSLEEPONFIRE = "I think not! That's a hotbed for danger!",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "I can still see the light from our metal friend when I close my eyes...",
	ANNOUNCE_NODANGERSIESTA = "This is no time to close my eyes!",
	ANNOUNCE_NONIGHTSIESTA = "Siesta in the dark? I think not.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "This does not strike me as a relaxing place for siesta.",
	ANNOUNCE_NOHUNGERSIESTA = "I could use a nice meal first.",
	ANNOUNCE_NO_TRAP = "Went off without a hitch.",
	ANNOUNCE_PECKED = "Gah! Enough!",
	ANNOUNCE_QUAKE = "That is not a comforting sound...",
	ANNOUNCE_RESEARCH = "Education is a lifelong process.",
	ANNOUNCE_SHELTER = "I am thankful for this tree's protective buffer.",
	ANNOUNCE_THORNS = "Gah!",
	ANNOUNCE_BURNT = "Charred...",
	ANNOUNCE_TORCH_OUT = "Come back, light!",
	ANNOUNCE_THURIBLE_OUT = "Out of fuel.",
	ANNOUNCE_FAN_OUT = "It fell apart in my hands!",
    ANNOUNCE_COMPASS_OUT = "Oh. I believe it broke.",
	ANNOUNCE_TRAP_WENT_OFF = "Darn!",
	ANNOUNCE_UNIMPLEMENTED = "It is not operational yet.",
	ANNOUNCE_WORMHOLE = "I must be unhinged to travel so...",
	ANNOUNCE_TOWNPORTALTELEPORT = "Bonjour! I've arrived!",
	ANNOUNCE_CANFIX = "\nI believe I could repair that.",
	ANNOUNCE_ACCOMPLISHMENT = "I am triumphant!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I hope this feeling lasts forever...",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It requires more manure.",
	ANNOUNCE_TOOL_SLIP = "Everything is slick...",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "That was much too close!",
	ANNOUNCE_TOADESCAPING = "Was it something I said?",
	ANNOUNCE_TOADESCAPED = "It's going to leave soon.",


	ANNOUNCE_DAMP = "I've been lightly spritzed.",
	ANNOUNCE_WET = "I am getting positively drenched.",
	ANNOUNCE_WETTER = "I fear I may be water soluble!",
	ANNOUNCE_SOAKED = "I'm wetter than a dish rag!",

	ANNOUNCE_WASHED_ASHORE = "Land! I'm saved!",

    ANNOUNCE_DESPAWN = "I'm going to the kitchen in the sky.",
	ANNOUNCE_BECOMEGHOST = "oOooOooo!!",
	ANNOUNCE_GHOSTDRAIN = "My, I have a headache.",
	ANNOUNCE_PETRIFED_TREES = "Are the trees making that sound?",
	ANNOUNCE_KLAUS_ENRAGE = "Our egg's been beat! Run!",
	ANNOUNCE_KLAUS_UNCHAINED = "Its shackles fell away!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Something's coming!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Something looks to be trapped inside.",
		GLASS_LOW = "Nearly there, mon ami!",
		GLASS_REVEAL = "Taste sweet freedom!",
		IDOL_MED = "Something looks to be trapped inside.",
		IDOL_LOW = "Nearly there, mon ami!",
		IDOL_REVEAL = "Taste sweet freedom!",
		SEED_MED = "Something looks to be trapped inside.",
		SEED_LOW = "Nearly there, mon ami!",
		SEED_REVEAL = "Taste sweet freedom!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Eee!",
	ANNOUNCE_BRAVERY_POTION = "I feel bold as a sharp cheddar!",
	ANNOUNCE_MOONPOTION_FAILED = "Perhaps that is for the best.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "The others might enjoy this!",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Mon dieu, my world is aglow!",
	ANNOUNCE_IS_FEASTING = "Winter's Feast is served!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Ah non, is it over already?",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Hold on, mon amie.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Et voilà!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Do I smell pie?",

    ANNOUNCE_FLARE_SEEN = "What's this? Someone's trying to get our attention.",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Oh? What could that be?",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "As a chef, I am quite embarrassed.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "I should have taken that off sooner.",
    QUAGMIRE_ANNOUNCE_LOSE = "This doesn't look good.",
    QUAGMIRE_ANNOUNCE_WIN = "I'm almost sorry to leave!",

    ANNOUNCE_ROYALTY =
    {
        "Mon empereur!",
        "Your grace.",
        "Your excellency.",
    },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I'll zap you to a nice, even crisp!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Try my new specialty - an open-faced knuckle sandwich!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I feel très formidable!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Now we're cooking!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Ah, nice and dry!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Fresh and awake!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Oh well, I prefer natural gas over electric anyway.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Erm... I think I'm more of a food lover than a fighter after all.",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Ah... I've gone from tough to tender.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Ah non, I think I'm losing steam.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Is it getting a bit soggy in here?",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "Oh dear, I seem to be getting a bit tired after all...",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Ah, zut! I've lost my tackle.",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "I should tighten my line a bit.",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "You have escaped my crockpot for now, mon ami.",
	ANNOUNCE_OCEANFISHING_BADCAST = "Ah non, that was terrible!",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Fishing requires lots of patience.",
		"Fish! Wouldn't you like to sample my hook?",
		"Hum dum dee da...",
		"I wonder if there's a better spot elsewhere.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nEnough fish to feed an entire crew!",

	ANNOUNCE_WINCH_CLAW_MISS = "Ah, just missed!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "Perhaps I'll try again.",

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
    ANNOUNCE_WEAK_RAT = "Quel dommage, I think it's gone off.",

    ANNOUNCE_CARRAT_START_RACE = "Ready? Go!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Non, mon ami! You're going the wrong way!",
        "The other way, mon ami!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Mon dieu! Has it fallen into a food coma?",
    ANNOUNCE_CARRAT_ERROR_WALKING = "You must move faster!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "My carrat is frozen!",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Mon dieu, somehow that made me a bit seasick...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Oh! It's teaching me a new recipe for a machine!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "I believe I already knew that one.",
    ANNOUNCE_ARCHIVE_NO_POWER = "If only there was a way to get it working again...",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "I've learned a little something about this plant.",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "I wonder what it will turn out to be.",

    ANNOUNCE_FERTILIZER_RESEARCHED = "If it goes into the food we eat, I suppose I should know everything about it.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Mon dieu, I feel as though my insides are boiling!",
		"This strange heat... I wonder if this is how crabs feel when they're boiled.",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Whew, I'm very glad that's over.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Bonjour! Parlez-vous francais?",
        "May you grow big, ripe and delicious.",
		"My, you look fresh as a daisy today mon ami!",
        "What a good little plant you are.",
        "How are you today, mon ami? Everything growing well?",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Three, two, one... allons-y!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Might I join in, s'il vous plait?",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Voilà!",
		"There you are mon petit chat!",
		"Ah, there you are!",
		"Bonjour, I see you!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "There should only be one left.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "Et voilà! The last petit chat.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "Ah, {name} found them at last!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "The game will be finished soon.",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Well, I suppose I'll just have to do better next time.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "I think I might have wandered too far...",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Hmm, they should be around here somewhere...",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Oh! Bonjour petit chat!",

	ANNOUNCE_TICOON_START_TRACKING	= "Allons-y, monsieur! I'll be close behind.",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "Perhaps there are no petits chats around to track.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Just a moment, I'm coming!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Oh! Do you smell something, monsieur?",
	ANNOUNCE_TICOON_NEAR_KITCOON = "I have a feeling we're very close.",
	ANNOUNCE_TICOON_LOST_KITCOON = "Ah, he seems to have lost the trail.",
	ANNOUNCE_TICOON_ABANDONED = "I think perhaps it's time for a break. Au revoir!",
	ANNOUNCE_TICOON_DEAD = "Oh my, that must have been his ninth life...",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Over here, my mignon filet!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "I should build this within the judge's view, non?",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Ah, bon! A new flavor of beefalo costume!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Why do I suddenly feel such a sinking feeling in my stomach...",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Ah, it's back! Not going out without a fight, it seems.",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Leaving before breakfast?",

	BATTLECRY =
	{
		GENERIC = "I'm also an accomplished butcher!",
		PIG = "No part of you will go to waste, cochon!",
		PREY = "You look delicious!",
		SPIDER = "I hope it does not rain after I kill you!",
		SPIDER_WARRIOR = "You will die, pest!",
		DEER = "Oh, it's venisON!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "There's no shame in running!",
		PIG = "Noooo, those hocks, those chops...",
		PREY = "Whew. I'm out of breath.",
		SPIDER = "I hope it didn't take any bites out of me.",
		SPIDER_WARRIOR = "That could have been worse.",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Is anyone else coming for dinner?",
        MULTIPLAYER_PORTAL_MOONROCK = "It seems dangerous, but it's oddly calming.",
        MOONROCKIDOL = "It's very enchanting.",
        CONSTRUCTION_PLANS = "It's a recipe for building!",

        ANTLION =
        {
            GENERIC = "I think it's friendly.",
            VERYHAPPY = "Life is good right now.",
            UNHAPPY = "Oh no, don't be mad.",
        },
        ANTLIONTRINKET = "I think I know someone who would want this.",
        SANDSPIKE = "Watch yourself, it's quite sharp.",
        SANDBLOCK = "Very thick sand.",
        GLASSSPIKE = "I prefer my decor a smidge less... stabby.",
        GLASSBLOCK = "Reminds me of the ice sculptures in the ship's dining hall.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="I don't think it's edible.",
			LEVEL1 = "Something's stirring inside.",
			LEVEL2 = "Bonjour? Anyone there?",
			LEVEL3 = "Ah, you are looking quite well today little flower!",

			-- deprecated
            LONG = "Something's stirring inside.",
            MEDIUM = "I think it's waking up.",
            SOON = "I get the feeling something will happen soon.",
            HAUNTED_POCKET = "I don't think it's my place to be holding this.",
            HAUNTED_GROUND = "What now, Mademoiselle Wendy?",
        },

        BALLOONS_EMPTY = "It's been left completely breathless.",
        BALLOON = "How colorful!",
		BALLOONPARTY = "Ah! A celebration!",
		BALLOONSPEED =
        {
            DEFLATED = "Quite an odd design. Then again, it was made by an odd fellow.",
            GENERIC = "What a kind gift!",
        },
		BALLOONVEST = "I'm not sure how safe that is.",
		BALLOONHAT = "It's... not exactly my style.",

        BERNIE_INACTIVE =
        {
            BROKEN = "Poor little fellow.",
            GENERIC = "I've been told his name is \"Bernie\".",
        },

        BERNIE_ACTIVE = "What a silly fellow.",
        BERNIE_BIG = "Tres géant!",

        BOOK_BIRDS = "I had hoped it was a poultry cookbook.",
        BOOK_TENTACLES = "I don't see any recipes in this at all.",
        BOOK_GARDENING = "Maybe Mme. Wickerbottom would be interested in starting a herb garden.",
		BOOK_SILVICULTURE = "Perhaps it will tell me the best places to find mushrooms.",
		BOOK_HORTICULTURE = "Maybe Mme. Wickerbottom would be interested in starting a herb garden.",
        BOOK_SLEEP = "It's tradition to nap after a good meal.",
        BOOK_BRIMSTONE = "I don't think that's my forte.",

        PLAYER =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "Let's all calm down with a nice bowl of soup.",
            MURDERER = "Mon dieu! You're a murderer!",
            REVIVER = "You've been a big help, %s.",
            GHOST = "Oh my. Does that hurt?",
            FIRESTARTER = "I don't want to nitpick how you light fires, but...",
        },
        WILSON =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "Let's all calm down with a nice bowl of soup.",
            MURDERER = "Mon dieu! You're a murderer!",
            REVIVER = "You've been a big help, %s.",
            GHOST = "Oh my. Does that hurt?",
            FIRESTARTER = "I don't want to nitpick how you light fires, but...",
        },
        WOLFGANG =
        {
            GENERIC = "Salut, %s!",
            ATTACKER = "%s's fists are weapons.",
            MURDERER = "What a heinous act you've committed.",
            REVIVER = "%s is very strong indeed.",
            GHOST = "Don't be scared, mon amie. I will help.",
            FIRESTARTER = "Surely he didn't know what he was doing when he set the flames.",
        },
        WAXWELL =
        {
            GENERIC = "Salut, %s.",
            ATTACKER = "%s has been irritable lately.",
            MURDERER = "I may not have it in me to forgive %s.",
            REVIVER = "%s isn't bad, just a little crunchy on the outside.",
            GHOST = "That looks very uncomfortable.",
            FIRESTARTER = "Let's not trust %s with flammable things for now.",
        },
        WX78 =
        {
            GENERIC = "Bonjour, my metal friend!",
            ATTACKER = "%s seems to be on the fritz today.",
            MURDERER = "%s did something truly vile.",
            REVIVER = "%s did a kind thing today.",
            GHOST = "Excusez-moi? How is it possible they have a ghost?",
            FIRESTARTER = "They overheated, perhaps?",
        },
        WILLOW =
        {
            GENERIC = "Salut, %s!",
            ATTACKER = "Been in a tussle recently, %s?",
            MURDERER = "I've burned my bridges with that one.",
            REVIVER = "You can rely on %s when it's important.",
            GHOST = "Would a nice bowl of hot soup help?",
            FIRESTARTER = "She was bound to start a fire sometime.",
        },
        WENDY =
        {
            GENERIC = "Salut, Mademoiselle %s.",
            ATTACKER = "Have you been up to mischief, Mademoiselle %s?",
            MURDERER = "She's inflicted her grief upon others. Abominable.",
            REVIVER = "I'll cook her favorite dish for supper tonight.",
            GHOST = "Oh non, non, non. Let's get you fixed up.",
            FIRESTARTER = "You know better than to set flames, Mademoiselle %s.",
        },
        WOODIE =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "I don't trust him with that axe right now.",
            MURDERER = "%s did something unforgivable.",
            REVIVER = "%s has a soft spot a mile wide.",
            GHOST = "Would some comfort food help?",
            BEAVER = "What on earth have you been eating?",
            BEAVERGHOST = "My friends are very strange.",
            MOOSE = "That truly is a powerful curse.",
            MOOSEGHOST = "Don't worry mon ami, I'll get you back on your feet... er, hooves?",
            GOOSE = "Goodness, are you feeling alright?",
            GOOSEGHOST = "Looks like your goose is cooked, mon ami.",
            FIRESTARTER = "I thought you disliked forest fires?",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Bonjour, Mme. %s!",
            ATTACKER = "I thought you were more responsible that that, Mme. %s.",
            MURDERER = "Mme. %s has done an unthinkable deed.",
            REVIVER = "Mme. %s is a reliable sort.",
            GHOST = "It's not your time to go quite yet, Mme. %s.",
            FIRESTARTER = "I assume she meant it to be a controlled burn.",
        },
        WES =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "I didn't expect him to be the violent sort.",
            MURDERER = "What a terrible act you've committed.",
            REVIVER = "I love your act, by the way.",
            GHOST = "Is there a medic on this island?",
            FIRESTARTER = "Watch where you light those fires, %s.",
        },
        WEBBER =
        {
            GENERIC = "Salut, petit monsieur %s.",
            ATTACKER = "What have you been up to, petit monsieur?",
            MURDERER = "What a terrible creature.",
            REVIVER = "I should make him a little treat later.",
            GHOST = "Oh, you poor thing.",
            FIRESTARTER = "Fire is dangerous you know, petit monsieur.",
        },
        WATHGRITHR =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "I fear %s more than anyone here.",
            MURDERER = "%s has done something truly abominable.",
            REVIVER = "%s is a great ally, indeed.",
            GHOST = "I'm surprised I outlived %s, frankly.",
            FIRESTARTER = "%s's fires burn as wildly as her passions.",
        },
        WINONA =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "You've been much too rough lately, %s.",
            MURDERER = "She's done a truly awful thing.",
            REVIVER = "I admire %s's sense of duty.",
            GHOST = "Let's fix you up, alright?",
            FIRESTARTER = "%s started quite the fire recently.",
        },
        WORTOX =
        {
            GENERIC = "Salut, my fuzzy red friend!",
            ATTACKER = "I don't find %s's pranks very funny.",
            MURDERER = "%s did something very, very cruel.",
            REVIVER = "%s is a trickster, but he helps sometimes too.",
            GHOST = "I don't think it bothers him as much as it does mortals.",
            FIRESTARTER = "It makes sense that he'd like fire.",
        },
        WORMWOOD =
        {
            GENERIC = "Bonjour, %s!",
            ATTACKER = "You won't make friends that way, %s.",
            MURDERER = "I could never be friends with such a creature.",
            REVIVER = "%s is a kind little veg.",
            GHOST = "Hold on, mon amie, I will find a heart.",
            FIRESTARTER = "Fire isn't safe for you, %s.",
        },
        WARLY =
        {
            GENERIC = "Heh. Bonjour, mon a-ME.",
            ATTACKER = "%s, why fight when we can cook?",
            MURDERER = "Mon dieu! I'm a monster!",
            REVIVER = "It's quite nice to have myself around.",
            GHOST = "I cook so I don't have to think about my own mortality.",
            FIRESTARTER = "Mon dieu! Watch the fire!",
        },

        WURT =
        {
            GENERIC = "Salut, mademoiselle %s!",
            ATTACKER = "That wasn't very nice, %s!",
            MURDERER = "Mon dieu! What a horrible little creature!",
            REVIVER = "You are very kind, little one.",
            GHOST = "Don't you worry, we'll get this sorted out!",
            FIRESTARTER = "Ah-! Little ones shouldn't play with matches!",
        },

        WALTER =
        {
            GENERIC = "Salut, %s!",
            ATTACKER = "Are you trying to scare us, %s?",
            MURDERER = "You are worse than the monsters from your stories!",
            REVIVER = "%s is very helpful.",
            GHOST = "You're not finished just yet, mon ami!",
            FIRESTARTER = "%s, are you feeling well?",
        },

        WANDA =
        {
            GENERIC = "Bonjour, Mme. %s!",
            ATTACKER = "That doesn't seem like a good use of your time, Mme. %s.",
            MURDERER = "I can never forgive you for what you've done, Mme. %s!",
            REVIVER = "I knew Mme. %s would come in my time of need.",
            GHOST = "Let's get you back on your feet, Mme. %s!",
            FIRESTARTER = "Is there... a reason you're setting fires, Mme. %s?",
        },

        MIGRATION_PORTAL =
        {
        --    GENERIC = "If I had any friends, this could take me to them.",
        --    OPEN = "If I step through, will I still be me?",
        --    FULL = "It seems to be popular over there.",
        },
        GLOMMER =
        {
            GENERIC = "I think I like it.",
            SLEEPING = "Sleep well, mon ami.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Tres beau!",
            DEAD = "What a waste.",
        },
        GLOMMERWINGS = "A tiny delicacy.",
        GLOMMERFUEL = "Looks like bubblegum, tastes like floor.",
        BELL = "Should I ring it?",
        STATUEGLOMMER =
        {
            GENERIC = "Must have been a pretty important, uh, thingy...",
            EMPTY = "Oops.",
        },

        LAVA_POND_ROCK = "Looks like a rock to me.",

		WEBBERSKULL = "Stop staring at me or I'll bury you!",
		WORMLIGHT = "Radiates deliciousness.",
		WORMLIGHT_LESSER = "Not as fresh, but I imagine the flavor is still good.",
		WORM =
		{
		    PLANT = "I see nothing amiss here.",
		    DIRT = "Dirty.",
		    WORM = "Worm!",
		},
        WORMLIGHT_PLANT = "I see nothing amiss here.",
		MOLE =
		{
			HELD = "Do you \"dig\" your new surroundings?",
			UNDERGROUND = "Something dwells beneath.",
			ABOVEGROUND = "Are you spying on me?",
		},
		MOLEHILL = "It is a nice hill, but I won't make a mountain of it.",
		MOLEHAT = "Neat vision!",

		EEL = "Anguille.",
		EEL_COOKED = "Could use some Cajun spices...",
		UNAGI = "More like \"umami\"! Ooooh, mommy!",
		EYETURRET = "This is my friend, Lazer Oeil!",
		EYETURRET_ITEM = "Wake up!",
		MINOTAURHORN = "I wonder, if ground up into a powder...",
		MINOTAURCHEST = "I appreciate the attention to its aesthetic detail.",
		THULECITE_PIECES = "A pocketful of thule.",
		POND_ALGAE = "I can't see the bottom...",
		GREENSTAFF = "I probably shouldn't stir soup with this.",
		GIFT = "Pour moi?",
        GIFTWRAP = "I could hide some cookies inside for the little ones.",
		POTTEDFERN = "Nature. Tamed.",
        SUCCULENT_POTTED = "I would have preferred to cook it, but c'est la vie.",
		SUCCULENT_PLANT = "What an adorable little plant.",
		SUCCULENT_PICKED = "I wonder if I can find some culinary use for this.",
		SENTRYWARD = "It's watching over us.",
        TOWNPORTAL =
        {
			GENERIC = "Is someone coming for dinner?",
			ACTIVE = "Ready to receive the dinner guests.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "The sensation takes some getting used to.",
			ACTIVE = "Well, it will be quicker at least.",
		},
        WETPAPER = "It's a tiny bit soggy.",
        WETPOUCH = "I hope the contents don't fall out.",
        MOONROCK_PIECES = "I think it's breakable.",
        MOONBASE =
        {
            GENERIC = "What goes in the middle, I wonder?",
            BROKEN = "My mechanical friend seems intent on fixing it.",
            STAFFED = "I thought something would have happened.",
            WRONGSTAFF = "I think it wants something else.",
            MOONSTAFF = "That looks ripe for the taking.",
        },
        MOONDIAL =
        {
			GENERIC = "I hope the birds get to enjoy it, too.",
			NIGHT_NEW = "The new moon's arrive.",
			NIGHT_WAX = "The moon is waxing.",
			NIGHT_FULL = "The full moon's arrived.",
			NIGHT_WANE = "The moon is waning.",
			CAVE = "It doesn't seem very useful down here.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "Mon dieu, the water has turned to glass!",
        },
		THULECITE = "Thule-... thulec-... it rolls off the tongue, does it not?",
		ARMORRUINS = "Ancient armor.",
		ARMORSKELETON = "I'm supposed to put that on?",
		SKELETONHAT = "Un chapeau effrayant.",
		RUINS_BAT = "I could tenderize some meat with this.",
		RUINSHAT = "Seems unnecessarily fancy.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "It appears that all is well.",
            WARN = "I feel some magic coming on!",
            WAXING = "Magic hour!",
            STEADY = "Steady on.",
            WANING = "Subsiding.",
            DAWN = "This nightmare is almost over!",
            NOMAGIC = "Magicless.",
		},
		BISHOP_NIGHTMARE = "You are grinding my gears, dear fellow.",
		ROOK_NIGHTMARE = "What a monstrosity!",
		KNIGHT_NIGHTMARE = "Effroyable!",
		MINOTAUR = "Stay away!",
		SPIDER_DROPPER = "Ah, the old \"drop from the ceiling and commit violent acts\" act.",
		NIGHTMARELIGHT = "Am I crazy or is this light not helping my situation?",
		NIGHTSTICK = "I feel electric!",
		GREENGEM = "Ahh, a rare attraction!",
		MULTITOOL_AXE_PICKAXE = "Oh, I get it! Kind of like a spork!",
		ORANGESTAFF = "When I hold it it makes the world feel... fast.",
		YELLOWAMULET = "Puts some pep in my step!",
		GREENAMULET = "For more savvy construction!",
		SLURPERPELT = "Wear this? What in heavens for?",

		SLURPER = "It is not polite to slurp.",
		SLURPER_PELT = "Wear this? What in heavens for?",
		ARMORSLURPER = "Ah. My appetite wanes under its protection.",
		ORANGEAMULET = "Here one minute, gone the next!",
		YELLOWSTAFF = "I could stir a huge pot with this thing!",
		YELLOWGEM = "I miss lemons...",
		ORANGEGEM = "I miss oranges...",
        OPALSTAFF = "It makes me feel magical.",
        OPALPRECIOUSGEM = "It glimmers like maman's eyes.",
        TELEBASE =
		{
			VALID = "It is operational.",
			GEMS = "It requires more purple gems.",
		},
		GEMSOCKET =
		{
			VALID = "Voilà!",
			GEMS = "Gem it!",
		},
		STAFFLIGHT = "Too much power to hold in one hand.",
        STAFFCOLDLIGHT = "I appreciate it on sweltering afternoons.",

        ANCIENT_ALTAR = "A structure from antiquity.",

        ANCIENT_ALTAR_BROKEN = "It is broken.",

        ANCIENT_STATUE = "It gives off strange vibrations.",

        LICHEN = "Really scraping the barrel for produce here.",
		CUTLICHEN = "Hmm, odd.",

		CAVE_BANANA = "Bananas! Just the flavor I needed!",
		CAVE_BANANA_COOKED = "Could use some oats and a few chocolate chips...",
		CAVE_BANANA_TREE = "There must be monkeys close by.",
		ROCKY = "Hmm... I would have to be careful to not chip a tooth.",

		COMPASS =
		{
			GENERIC="Hmm, no reading.",
			N = "North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "Better to lose a tooth than your tongue!",
        ARMORSNURTLESHELL = "It allows me to turtle.",
        BAT = "If I only had a bat...",
        BATBAT = "A gruesome implement.",
        BATWING = "Hmmm, maybe a soup stock of batwings?",
        BATWING_COOKED = "Needs garlic...",
        BATCAVE = "I wouldn't want to disturb their peaceful slumber.",
        BEDROLL_FURRY = "Cozy.",
        BUNNYMAN = "I have so many good rabbit recipes...",
        FLOWER_CAVE = "Ah, a light in the dark.",
        GUANO = "Poop of the bat.",
        LANTERN = "It is my night light.",
        LIGHTBULB = "Looks like candy.",
        MANRABBIT_TAIL = "The texture is exceptionally comforting.",
        MUSHROOMHAT = "Wearing mushrooms is the next best thing to eating them.",
        MUSHROOM_LIGHT2 =
        {
            ON = "I like a nice pale blue, personally.",
            OFF = "Sometimes, you need a break.",
            BURNT = "Mmm, smells like fried mushrooms.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "I do like being able to see.",
            OFF = "Sometimes, you need a break.",
            BURNT = "Mmm, smells like fried mushrooms.",
        },
        SLEEPBOMB = "Bonne nuit, everybody.",
        MUSHROOMBOMB = "We should get far away from that.",
        SHROOM_SKIN = "Oh dear. I'm not sure I like that.",
        TOADSTOOL_CAP =
        {
            EMPTY = "Was there supposed to be something here?",
            INGROUND = "What's that poking out?",
            GENERIC = "How delectable! I should chop it down.",
        },
        TOADSTOOL =
        {
            GENERIC = "What massive legs you have!",
            RAGE = "It seems quite mad now!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "I wonder if it's edible.",
            BURNT = "Mmm, smells like fried mushrooms.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "There's simply no reason for it to be that big.",
            BLOOM = "What an un-delicious stench!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Fresh ingredients, ripe for the taking.",
            BLOOM = "What an un-delicious stench!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "I can't wait to harvest it.",
            BLOOM = "What an un-delicious stench!",
        },
        MUSHTREE_TALL_WEBBED = "I hope I don't run into any spiders.",
        SPORE_TALL =
        {
            GENERIC = "I can't believe mushrooms made something so pretty.",
            HELD = "How precious.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Something that pretty must taste good, right?",
            HELD = "How precious.",
        },
        SPORE_SMALL =
        {
            GENERIC = "It looks like floating candy.",
            HELD = "How precious.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Do my eyes deceive me?",
            BURNT = "That was no carrot!",
        },
        SLURTLE = "You would flavor a soup nicely. Your shell could be the bowl!",
        SLURTLE_SHELLPIECES = "If only I had crazy glue.",
        SLURTLEHAT = "Be the snail.",
        SLURTLEHOLE = "Yuck!",
        SLURTLESLIME = "Nature giveth, and nature grosseth.",
        SNURTLE = "Escar-goodness gracious!",
        SPIDER_HIDER = "A spider that turtles!",
        SPIDER_SPITTER = "So many spiders!",
        SPIDERHOLE = "I have no reason to investigate any further.",
        SPIDERHOLE_ROCK = "I'd prefer not to get closer.",
        STALAGMITE = "I always get you upside down with stalactites...",
        STALAGMITE_TALL = "Rocks to be had.",

        TURF_CARPETFLOOR = "Make fists with your toes...",
        TURF_CHECKERFLOOR = "It's like an ingredient for the ground.",
        TURF_DIRT = "It's like an ingredient for the ground.",
        TURF_FOREST = "It's like an ingredient for the ground.",
        TURF_GRASS = "Will I need to cut this?",
        TURF_MARSH = "It's like an ingredient for the ground.",
        TURF_METEOR = "Very down-to-earth.",
        TURF_PEBBLEBEACH = "It's like an ingredient for the ground.",
        TURF_ROAD = "It's like an ingredient for the ground.",
        TURF_ROCKY = "It's like an ingredient for the ground.",
        TURF_SAVANNA = "It's like an ingredient for the ground.",
        TURF_WOODFLOOR = "It's like an ingredient for the ground.",

		TURF_CAVE="It's like an ingredient for the ground.",
		TURF_FUNGUS="It's like an ingredient for the ground.",
		TURF_FUNGUS_MOON = "It's like an ingredient for the ground.",
		TURF_ARCHIVE = "It's like an ingredient for the ground.",
		TURF_SINKHOLE="It's like an ingredient for the ground.",
		TURF_UNDERROCK="It's like an ingredient for the ground.",
		TURF_MUD="It's like an ingredient for the ground.",

		TURF_DECIDUOUS = "It's like an ingredient for the ground.",
		TURF_SANDY = "It's like an ingredient for the ground.",
		TURF_BADLANDS = "It's like an ingredient for the ground.",
		TURF_DESERTDIRT = "It's like an ingredient for the ground.",
		TURF_FUNGUS_GREEN = "It's like an ingredient for the ground.",
		TURF_FUNGUS_RED = "It's like an ingredient for the ground.",
		TURF_DRAGONFLY = "It's like an ingredient for the ground.",

        TURF_SHELLBEACH = "It's like an ingredient for the ground.",

		POWCAKE = "I would not feed this to my worst enemies. Or would I...",
        CAVE_ENTRANCE = "I wonder what is underneath that?",
        CAVE_ENTRANCE_RUINS = "What is within?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "I wonder what is underneath that?",
            OPEN = "Dare I?",
            FULL = "Someone else is having their turn in there.",
        },
        CAVE_EXIT =
        {
            GENERIC = "Now isn't a good time to leave.",
            OPEN = "I should like to see the surface again.",
            FULL = "I'll wait til there's a little more room.",
        },

		MAXWELLPHONOGRAPH = "I wonder what is in his record collection?",--single player
		BOOMERANG = "Oh good. I have separation anxiety.",
		PIGGUARD = "What are you guarding, besides your own deliciousness?",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Bonjour, Mademoiselle Abigail!",
                "Bonjour, Mademoiselle Abigail!",
            },
            LEVEL2 =
            {
                "Bonjour, Mademoiselle Abigail!",
                "Bonjour, Mademoiselle Abigail!",
            },
            LEVEL3 =
            {
                "Bonjour, Mademoiselle Abigail!",
                "Bonjour, Mademoiselle Abigail!",
            },
		},
		ADVENTURE_PORTAL = "What fresh devilment is this?",
		AMULET = "I wear safety.",
		ANIMAL_TRACK = "These tracks point to fresh game.",
		ARMORGRASS = "How much protection can grass really provide?",
		ARMORMARBLE = "Weighs a ton.",
		ARMORWOOD = "Sturdy, but quite flammable.",
		ARMOR_SANITY = "Am I crazy to wear this?",
		ASH =
		{
			GENERIC = "I miss ash covered cheeses. I miss cheeses, period.",
			REMAINS_GLOMMERFLOWER = "The unusual flower is but ash now.",
			REMAINS_EYE_BONE = "The eyebone was sacrificed in my travels.",
			REMAINS_THINGIE = "It is no more.",
		},
		AXE = "A trusty companion in these environs.",
		BABYBEEFALO =
		{
			GENERIC = "I have mixed feelings about veal.",
		    SLEEPING = "Bonne nuit, baby steak.",
        },
        BUNDLE = "A cool dry place to keep food.",
        BUNDLEWRAP = "A good food wrap.",
		BACKPACK = "It has my back.",
		BACONEGGS = "Runny eggs... crisp bacon... I could die happy now...",
		BANDAGE = "First aid.",
		BASALT = "Made of strong stuff!", --removed
		BEARDHAIR = "Disgusting.",
		BEARGER = "Oh, I don't like you one bit!",
		BEARGERVEST = "Furry refuge from the elements.",
		ICEPACK = "Now this I can use!",
		BEARGER_FUR = "Feels warm.",
		BEDROLL_STRAW = "A little better than bare ground. Scratchy.",
		BEEQUEEN = "Your honey was too delicious not to steal!",
		BEEQUEENHIVE =
		{
			GENERIC = "I don't think that honey would taste very good.",
			GROWING = "I don't remember this being here.",
		},
        BEEQUEENHIVEGROWN = "That's almost definitely bigger than before.",
        BEEGUARD = "Oh non non non, I hate being stung!",
        HIVEHAT = "The stickiness is mostly gone. Mostly.",
        MINISIGN =
        {
            GENERIC = "Too small for a restaurant sign.",
            UNDRAWN = "I could draw the specials on there.",
        },
        MINISIGN_ITEM = "This would be better off in the ground.",
		BEE =
		{
			GENERIC = "Where there are bees, there is honey!",
			HELD = "Hi, honey.",
		},
		BEEBOX =
		{
			READY = "Honey jackpot!",
			FULLHONEY = "Honey jackpot!",
			GENERIC = "Home of the honeymakers!",
			NOHONEY = "No more honey...",
			SOMEHONEY = "There is a little honey.",
			BURNT = "Disastrously caramelized.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "My days of wild mushroom hunting are over!",
			LOTS = "It's nice not to have to forage for the basics.",
			SOME = "Oh, my mushrooms are beginning to grow!",
			EMPTY = "I could grow some fresh mushrooms here.",
			ROTTEN = "I'll need to find a replacement if I want fresh mushrooms.",
			BURNT = "Mmm, smells like fried mushrooms.",
			SNOWCOVERED = "Mushrooms are out of season right now.",
		},
		BEEFALO =
		{
			FOLLOWER = "That's it, my friend. I lead, you follow.",
			GENERIC = "Here's the beef.",
			NAKED = "Chin up, it'll grow back.",
			SLEEPING = "The sirloin slumbers...",
            --Domesticated states:
            DOMESTICATED = "This one's quite calm.",
            ORNERY = "It's boiling up!",
            RIDER = "I think I could actually handle this one.",
            PUDGY = "You enjoy food as much as me.",
            MYPARTNER = "We go together like steak and a lovely garlic herb butter.",
		},

		BEEFALOHAT = "Fits perfectly.",
		BEEFALOWOOL = "The beast's loss is my gain.",
		BEEHAT = "Essential honey harvesting attire.",
        BEESWAX = "A first-rate preservative.",
		BEEHIVE = "I can hear the activity within.",
		BEEMINE = "Weaponized bees.",
		BEEMINE_MAXWELL = "I pity whoever trips this.",--removed
		BERRIES = "Fresh fruit!",
		BERRIES_COOKED = "Could use a pinch of sugar...",
        BERRIES_JUICY = "What a unique, tangy flavor.",
        BERRIES_JUICY_COOKED = "I'd have preferred to cook them into a proper dish.",
		BERRYBUSH =
		{
			BARREN = "They require care and fertilizer.",
			WITHERED = "The heat has stifled these berries.",
			GENERIC = "Berries!",
			PICKED = "More will return.",
			DISEASED = "It's got food poisoning.",--removed
			DISEASING = "I think it's coming down with a little something.",--removed
			BURNING = "It's burning down!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "No more fresh berries for my desserts.",
			WITHERED = "It's much too hot, I agree.",
			GENERIC = "Berries!",
			PICKED = "I can't wait for more.",
			DISEASED = "It's got food poisoning.",--removed
			DISEASING = "I think it's coming down with a little something.",--removed
			BURNING = "It's burning down!",
		},
		BIGFOOT = "Please do not squish me!",--removed
		BIRDCAGE =
		{
			GENERIC = "Suitable lodgings for a feathered beast.",
			OCCUPIED = "I now have an egg farm!",
			SLEEPING = "Sleep now, lay later.",
			HUNGRY = "Let me cook something nice up for you.",
			STARVING = "Oh, what do birds eat? A nice brisket?",
			DEAD = "Maybe it will wake up.",
			SKELETON = "It is not waking up. Oh dear.",
		},
		BIRDTRAP = "Oh, roast bird! Hm, don't get ahead of yourself, Warly...",
		CAVE_BANANA_BURNT = "I would have liked more fresh bananas.",
		BIRD_EGG = "Nature's perfect food.",
		BIRD_EGG_COOKED = "Could use a few different herbs...",
		BISHOP = "You don't strike me as particularly spiritual.",
		BLOWDART_FIRE = "Breathing fire!",
		BLOWDART_SLEEP = "A sleep aid!",
		BLOWDART_PIPE = "They won't know what hit them.",
		BLOWDART_YELLOW = "It's positively electric.",
		BLUEAMULET = "Brrrrrr!",
		BLUEGEM = "Such a cool blue.",
		BLUEPRINT =
		{
            COMMON = "Time to stretch the brain muscles.",
            RARE = "This one looks complicated.",
        },
        SKETCH = "Oh! I could sculpt something based off this.",
		BLUE_CAP = "What deliciousness shall you yield?",
		BLUE_CAP_COOKED = "Could use a dash of smoked salt and balsamic vinegar...",
		BLUE_MUSHROOM =
		{
			GENERIC = "Ah, a blue truffle!",
			INGROUND = "It retreats from the light.",
			PICKED = "I hope the truffles are restocked soon.",
		},
		BOARDS = "Sigh. It would be so perfect for grilling salmon.",
		BONESHARD = "I could make a hearty stock with these.",
		BONESTEW = "Warms my soul!",
		BUGNET = "For catching alternative protein.",
		BUSHHAT = "Snacks to go?",
		BUTTER = "I thought I would never see you again, old friend!",
		BUTTERFLY =
		{
			GENERIC = "Your aerial dance is so soothing to behold...",
			HELD = "Don't slip from my butterfingers.",
		},
		BUTTERFLYMUFFIN = "Delectable!",
		BUTTERFLYWINGS = "I wonder what dishes I could create with these?",
		BUZZARD = "If only you were more turkey than vulture...",

		SHADOWDIGGER = "Oh, how odd.",

		CACTUS =
		{
			GENERIC = "I bet it has a sharp flavor.",
			PICKED = "It will live to prick again.",
		},
		CACTUS_MEAT_COOKED = "Could use some tortillas and melted queso...",
		CACTUS_MEAT = "I hope it does not prickle going down.",
		CACTUS_FLOWER = "Such a pretty flower from such a prickly customer!",

		COLDFIRE =
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "Fire that cools?",
			HIGH = "The flames climb higher!",
			LOW = "It's getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		CAMPFIRE =
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "To keep the dark at bay.",
			HIGH = "Rivals a grease fire!",
			LOW = "It is getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		CANE = "Now we are cooking with gas!",
		CATCOON = "What perky little ears.",
		CATCOONDEN =
		{
			GENERIC = "How many critters can fit in there?",
			EMPTY = "Vacant of critters.",
		},
		CATCOONHAT = "Not quite my style.",
		COONTAIL = "Chat noodle.",
		CARROT = "Fresh picked produce!",
		CARROT_COOKED = "Could use a dash of olive oil and cilantro...",
		CARROT_PLANTED = "Ah, a fresh carrot!",
		CARROT_SEEDS = "Future ingredients, just waiting to be grown!",
		CARTOGRAPHYDESK =
		{
			GENERIC = "I hope my penmanship is legible.",
			BURNING = "Oh dear!",
			BURNT = "Well, that won't help our explorations much.",
		},
		WATERMELON_SEEDS = "Future ingredients, just waiting to be grown!",
		CAVE_FERN = "How does anything grow down here?",
		CHARCOAL = "This, a grill and some meat and I'd have dinner.",
        CHESSPIECE_PAWN = "It looks a bit like a pawn.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "It looks a bit like a rook.",
            STRUGGLE = "Mon dieu! It's moving!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "It looks a bit like a knight.",
            STRUGGLE = "Mon dieu! It's moving!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "It looks a bit like a bishop.",
            STRUGGLE = "Mon dieu! It's moving!",
        },
        CHESSPIECE_MUSE = "This one looks like a queen.",
        CHESSPIECE_FORMAL = "This must be the king?",
        CHESSPIECE_HORNUCOPIA = "One can dream.",
        CHESSPIECE_PIPE = "I hope it doesn't set a bad example for the little ones.",
        CHESSPIECE_DEERCLOPS = "It was much scarier in the flesh.",
        CHESSPIECE_BEARGER = "I can't believe we survived that beast!",
        CHESSPIECE_MOOSEGOOSE =
        {
            "I should whip up some roast goose with cranberry sauce.",
        },
        CHESSPIECE_DRAGONFLY = "I was afraid I was going to be broiled alive!",
		CHESSPIECE_MINOTAUR = "Perhaps now you can keep watch over my crock pot.",
        CHESSPIECE_BUTTERFLY = "How lovely!",
        CHESSPIECE_ANCHOR = "I think Maman would like this.",
        CHESSPIECE_MOON = "Hits my eye like a big pizza pie.",
        CHESSPIECE_CARRAT = "Looking at it is making me a little hungry...",
        CHESSPIECE_MALBATROSS = "I hope this won't bring us ill luck at sea...",
        CHESSPIECE_CRABKING = "I'm getting a sudden craving for seafood.",
        CHESSPIECE_TOADSTOOL = "Stone mushroom soup anyone?",
        CHESSPIECE_STALKER = "If only I could use those bones in a broth.",
        CHESSPIECE_KLAUS = "A table centerpiece fit for a holiday feast.",
        CHESSPIECE_BEEQUEEN = "Muse for my new honey glaze!",
        CHESSPIECE_ANTLION = "I do like her better like this.",
        CHESSPIECE_BEEFALO = "What a beautifully marbled steak.",
		CHESSPIECE_KITCOON = "I think Mme. Wickerbottom is particularly fond of this one.",
		CHESSPIECE_CATCOON = "At least this one won't try to sneak off with my lunch.",
        CHESSPIECE_GUARDIANPHASE3 = "A three course fight I won't soon forget.",
        CHESSPIECE_EYEOFTERROR = "Did it just blink?",
        CHESSPIECE_TWINSOFTERROR = "They weren't the most polite guests, non?",

        CHESSJUNK1 = "Broken chess pieces?",
        CHESSJUNK2 = "More broken chess pieces?",
        CHESSJUNK3 = "And yet more broken chess pieces?",
		CHESTER = "You look cute and inedible.",
		CHESTER_EYEBONE =
		{
			GENERIC = "The eye follows me wherever I go...",
			WAITING = "It sleeps.",
		},
		COOKEDMANDRAKE = "Could use horseradish...",
		COOKEDMEAT = "Could use a chimichurri sauce...",
		COOKEDMONSTERMEAT = "Could use... uh... I don't even...",
		COOKEDSMALLMEAT = "Could use sea salt...",
		COOKPOT =
		{
			COOKING_LONG = "A masterpiece takes time.",
			COOKING_SHORT = "Nearly there...",
			DONE = "Ahh, fini!",
			EMPTY = "Empty pot, empty heart.",
			BURNT = "Tragique.",
		},
		CORN = "Corn! Sweet, sweet corn!",
		CORN_COOKED = "Could use miso and lardons...",
		CORN_SEEDS = "Future ingredients, just waiting to be grown!",
        CANARY =
		{
			GENERIC = "Sing me your sweet song, mon amie.",
			HELD = "Bonjour monsieur.",
		},
        CANARY_POISONED = "The poor thing!",

		CRITTERLAB = "I could use a friend in this difficult world.",
        CRITTER_GLOMLING = "She's a great comfort in times of stress.",
        CRITTER_DRAGONLING = "Her name is \"Flambé\" and she is precious.",
		CRITTER_LAMB = "This is Lambchop, my little kitchen helper.",
        CRITTER_PUPPY = "Le petit chien!",
        CRITTER_KITTEN = "Sweet petite chat.",
        CRITTER_PERDLING = "I would never eat you.",
		CRITTER_LUNARMOTHLING = "The light of my life!",

		CROW =
		{
			GENERIC = "Raven stew perhaps?",
			HELD = "Hush, my pet.",
		},
		CUTGRASS = "What shall I craft?",
		CUTREEDS = "Smells like greenery.",
		CUTSTONE = "Compressed stones, nice presentation.",
		DEADLYFEAST = "I would not recommend this.", --unimplemented
		DEER =
		{
			GENERIC = "Imagine... succulent venison bourguignon.",
			ANTLER = "Shouldn't they have two antlers?",
		},
        DEER_ANTLER = "It looks like a key, does it not?",
        DEER_GEMMED = "Oh deer!",
		DEERCLOPS = "I once had a saucier who looked like that.",
		DEERCLOPS_EYEBALL = "Giant eyeball... soup?",
		EYEBRELLAHAT =	"\"Eye\" like it!",
		DEPLETED_GRASS =
		{
			GENERIC = "Well past its expiry date.",
		},
        GOGGLESHAT = "Oh. I've never considered myself fashionable before!",
        DESERTHAT = "Goggles would be quite useful. I need my eyes.",
		DEVTOOL = "Efficient, oui?",
		DEVTOOL_NODEV = "No, I am a traditionalist.",
		DIRTPILE = "It's making a bit of a mess, isn't it?",
		DIVININGROD =
		{
			COLD = "Hmm, keep looking.", --singleplayer
			GENERIC = "A finely tuned radar stick.", --singleplayer
			HOT = "I can almost smell it!", --singleplayer
			WARM = "I've caught onto something!", --singleplayer
			WARMER = "Warmer, warmer...!", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "Is it a chopping block?", --singleplayer
			READY = "How do I turn it on?", --singleplayer
			UNLOCKED = "Preparation complete!", --singleplayer
		},
		DIVININGRODSTART = "That looks important.", --singleplayer
		DRAGONFLY = "I'm not cut out for this.",
		ARMORDRAGONFLY = "Heavy and hot.",
		DRAGON_SCALES = "Hot to the touch!",
		DRAGONFLYCHEST = "Ooh la la, burnproof storage.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "Is it reparable?",
			GENERIC = "It's a gilded furnace.", --no gems
			NORMAL = "I believe it's giving me the \"eye\".", --one gem
			HIGH = "What a handsome fire!", --two gems
		},

        HUTCH = "Just my cute little breadbox.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "He's a cheery little fishstick.",
            WAITING = "He's missing his other half.",
        },
		LAVASPIT =
		{
			HOT = "A chef-cuisinier never burns his fingers.",
			COOL = "The top has cooled like a barfy crème brûlée!",
		},
		LAVA_POND = "That looks a little toasty.",
		LAVAE = "You're a pretty cute little sausage link.",
		LAVAE_COCOON = "Yuck. I should wash my hands before I prepare food.",
		LAVAE_PET =
		{
			STARVING = "I should cook something for her, fast!",
			HUNGRY = "You are hungry, non? Let me whip something up.",
			CONTENT = "Happy as a deliciously seasoned clam.",
			GENERIC = "She's a fiery little one.",
		},
		LAVAE_EGG =
		{
			GENERIC = "Is its flavor profile comparable to a regular egg?",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Are you chilly, ma petite choux-fleur?",
			COMFY = "Nice and cozy.",
		},
		LAVAE_TOOTH = "It came off my petite fiery friend.",

		DRAGONFRUIT = "So exotic!",
		DRAGONFRUIT_COOKED = "Could use a spread of pudding and chia seeds...",
		DRAGONFRUIT_SEEDS = "Future ingredients, just waiting to be grown!",
		DRAGONPIE = "Flaky crust, tart filling... heavenly!",
		DRUMSTICK = "Dark meat!",
		DRUMSTICK_COOKED = "Could use a light honey garlic glaze...",
		DUG_BERRYBUSH = "Should I bring it back to life?",
		DUG_BERRYBUSH_JUICY = "Now I can have fresh berries wherever I please!",
		DUG_GRASS = "Should I bring it back to life?",
		DUG_MARSH_BUSH = "Should I bring it back to life?",
		DUG_SAPLING = "Should I bring it back to life?",
		DURIAN = "That odor...",
		DURIAN_COOKED = "Could use onions and chili...",
		DURIAN_SEEDS = "Future ingredients, just waiting to be grown!",
		EARMUFFSHAT = "Ahh, fuzzy!",
		EGGPLANT = "Aubergine!",
		EGGPLANT_COOKED = "Could use tomato sauce and Parmesan...",
		EGGPLANT_SEEDS = "Future ingredients, just waiting to be grown!",

		ENDTABLE =
		{
			BURNT = "Should have taken it out of the oven sooner.",
			GENERIC = "I miss table settings.",
			EMPTY = "It could use a little something.",
			WILTED = "I hope Maman Angeline is eating well without me.",
			FRESHLIGHT = "Now we can all shine a little brighter.",
			OLDLIGHT = "It's looking pretty dim.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			POISON = "No thank you!",
			GENERIC = "A bouquet of leaves.",
		},
		ACORN = "It rattles.",
        ACORN_SAPLING = "Just a petite bébé.",
		ACORN_COOKED = "This could use something... Anything.",
		BIRCHNUTDRAKE = "What madness is this?",
		EVERGREEN =
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A soldier of the exotic forest.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A coneless arbre.",
		},
		TWIGGYTREE =
		{
			BURNING = "It, oh, it appears to be on fire.",
			BURNT = "Crisp, no?",
			CHOPPED = "No more for now.",
			GENERIC = "It's a tree made of kabob sticks.",
			DISEASED = "It's under the weather.", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Just a petite bébé.",
        TWIGGY_OLD = "That tree looks like it's on its way out.",
		TWIGGY_NUT = "It will grow into a fine tree.",
		EYEPLANT = "Is that a mouth?",
		INSPECTSELF = "What a tasty dish!",
		FARMPLOT =
		{
			GENERIC = "I can grow my own ingredients!",
			GROWING = "Ah, couldn't be more fresh!",
			NEEDSFERTILIZER = "Needs to be fertilized.",
			BURNT = "Stayed in the oven a tad too long.",
		},
		FEATHERHAT = "What am I supposed to do with this?",
		FEATHER_CROW = "A bird's feather, in truffle black.",
		FEATHER_ROBIN = "A bird's feather, in cherry red.",
		FEATHER_ROBIN_WINTER = "A bird's feather, in tuna blue.",
		FEATHER_CANARY = "A bird's feather, in lemon yellow.",
		FEATHERPENCIL = "Lighter than my meringue.",
        COOKBOOK = "I added a few of my own personal recipes.",
		FEM_PUPPET = "She's trapped!", --single player
		FIREFLIES =
		{
			GENERIC = "A dash of glow.",
			HELD = "My petit lightbulb pets.",
		},
		FIREHOUND = "Chien, on fire!",
		FIREPIT =
		{
			EMBERS = "That fire's almost out!",
			GENERIC = "To warm my fingers and roast sausages.",
			HIGH = "Maximum heat!",
			LOW = "It's getting low.",
			NORMAL = "Parfait.",
			OUT = "I like when it's warm and toasty.",
		},
		COLDFIREPIT =
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "Fire that cools?",
			HIGH = "The flames climb higher!",
			LOW = "It's getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		FIRESTAFF = "Oven on a stick!",
		FIRESUPPRESSOR =
		{
			ON = "Make it snow!",
			OFF = "He's sleeping.",
			LOWFUEL = "Shall I fuel it up?",
		},

		FISH = "Poisson!",
		FISHINGROD = "I believe I prefer the fish market.",
		FISHSTICKS = "Crunchy and golden outside, flaky and moist inside!",
		FISHTACOS = "Takes me south of the border!",
		FISH_COOKED = "Could use a squeeze of lemon...",
		FLINT = "Sharp as can be!",
		FLOWER =
		{
            GENERIC = "I love to garnish with edible flowers.",
            ROSE = "Confections flavored with rose water, perhaps?",
        },
        FLOWER_WITHERED = "I only use fresh ingredients in my cooking.",
		FLOWERHAT = "Who doesn't look good in this?!",
		FLOWER_EVIL = "A terrible omen if I ever saw one.",
		FOLIAGE = "Feuillage.",
		FOOTBALLHAT = "Made from pork, to protect my melon.",
        FOSSIL_PIECE = "No marrow left in it.",
        FOSSIL_STALKER =
        {
			GENERIC = "There are still a few bits missing.",
			FUNNY = "At least it's good for a chuckle.",
			COMPLETE = "That looks about right. Now, what's the secret ingredient?",
        },
        STALKER = "We should have left it sleeping!",
        STALKER_ATRIUM = "This won't be an easy fight.",
        STALKER_MINION = "What creeps!",
        THURIBLE = "It smells like a dish that's begun to burn.",
        ATRIUM_OVERGROWTH = "Is this a language of some sort?",
		FROG =
		{
			DEAD = "I'll eat your legs for dinner!",
			GENERIC = "Frog. A delicacy.",
			SLEEPING = "Bonne nuit, little snack.",
		},
		FROGGLEBUNWICH = "Ah, French cuisine!",
		FROGLEGS = "I am hopping with excitement!",
		FROGLEGS_COOKED = "Could use garlic and clarified butter...",
		FRUITMEDLEY = "Invigorating!",
		FURTUFT = "Plush and soft, if a bit dirty.",
		GEARS = "The insides of those naughty machines.",
		GHOST = "Could I offer you a ghost pepper?",
		GOLDENAXE = "A golden chopper!",
		GOLDENPICKAXE = "That looks nice.",
		GOLDENPITCHFORK = "A golden fork for a giant, oui?",
		GOLDENSHOVEL = "Shiny.",
		GOLDNUGGET = "Yolk yellow, glowing gold!",
		GRASS =
		{
			BARREN = "Could I get some fertilizer over here?",
			WITHERED = "Too hot for you.",
			BURNING = "I never burn anything in the kitchen.",
			GENERIC = "A common ingredient for success around here.",
			PICKED = "Plucked clean!",
			DISEASED = "It's under the weather.", --unimplemented
			DISEASING = "It's starting to look a little funny.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "It doesn't seem dangerous.",
			DISEASED = "Would some nice soup make you feel better?", --unimplemented
		},
		GREEN_CAP = "Don't crowd the mushrooms.",
		GREEN_CAP_COOKED = "Could use a slathering of butter and chives...",
		GREEN_MUSHROOM =
		{
			GENERIC = "Little champignon!",
			INGROUND = "Did it eat itself...?",
			PICKED = "I eagerly await its rebirth!",
		},
		GUNPOWDER = "Boom!",
		HAMBAT = "Mmm, ham popsicle!",
		HAMMER = "For tenderizing boeuf!",
		HEALINGSALVE = "Soothing.",
		HEATROCK =
		{
			FROZEN = "Vanilla ice.",
			COLD = "Still cold.",
			GENERIC = "A temperature stone.",
			WARM = "It's warming up nicely.",
			HOT = "Hot!",
		},
		HOME = "Who lives here?",
		HOMESIGN =
		{
			GENERIC = "What's the use in a sign around here?",
            UNWRITTEN = "I'll write a nice note for the next person.",
			BURNT = "Overcooked.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "This must be a sign.",
            UNWRITTEN = "I'll write a nice note for the next person.",
			BURNT = "Overcooked.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "This must be a sign.",
            UNWRITTEN = "I'll write a nice note for the next person.",
			BURNT = "Crisp, non?",
		},
		HONEY = "Nectar of the gods!",
		HONEYCOMB = "Just add milk!",
		HONEYHAM = "Comfort food!",
		HONEYNUGGETS = "Junk food is my guilty pleasure. Shh!",
		HORN = "There's still some hairs inside.",
		HOUND = "Angry chien!",
		HOUNDCORPSE =
		{
			GENERIC = "What a terrible sight!",
			BURNING = "I'm afraid it's for the best.",
			REVIVING = "It sprung back to life!",
		},
		HOUNDBONE = "Hmm, soup stock...",
		HOUNDMOUND = "It smells wet.",
		ICEBOX = "The ice box, my second-most loyal culinary companion.",
		ICEHAT = "Must I wear it?",
		ICEHOUND = "Away, frozen diable!",
		INSANITYROCK =
		{
			ACTIVE = "And I'm in!",
			INACTIVE = "Do not lick it. Your tongue will get stuck.",
		},
		JAMMYPRESERVES = "Simple, sweet, parfait.",

		KABOBS = "Opa!",
		KILLERBEE =
		{
			GENERIC = "Almost not worth the honey!",
			HELD = "So sassy!",
		},
		KNIGHT = "A tricky cheval!",
		KOALEFANT_SUMMER = "Ah, you have fattened up nicely!",
		KOALEFANT_WINTER = "You can't get attached to cute cuts of meat.",
		KRAMPUS = "What the devil!",
		KRAMPUS_SACK = "Infinite pocket space!",
		LEIF = "I'm out of my element!",
		LEIF_SPARSE = "I'm out of my element!",
		LIGHTER  = "This is Willow's.",
		LIGHTNING_ROD =
		{
			CHARGED = "Electricity!",
			GENERIC = "I do feel a bit safer now.",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "I had a goat once.",
			CHARGED = "Goat milkshake!",
		},
		LIGHTNINGGOATHORN = "For kabobs, perhaps?",
		GOATMILK = "Can I make this into cheese?",
		LITTLE_WALRUS = "Oh, there's a little one!",
		LIVINGLOG = "Magic building blocks!",
		LOG =
		{
			BURNING = "Soon it won't be good for much.",
			GENERIC = "An important aspect of my art.",
		},
		LUCY = "Bonjour, mademoiselle.",
		LUREPLANT = "How alluring.",
		LUREPLANTBULB = "Growing meat from the ground? Now I've seen it all...",
		MALE_PUPPET = "Free him!", --single player

		MANDRAKE_ACTIVE = "How chatty you are, hm, bébé?",
		MANDRAKE_PLANTED = "I could always use more fresh veg.",
		MANDRAKE = "Have I discovered a new root vegetable?!",

        MANDRAKESOUP = "What an otherworldly flavor!",
        MANDRAKE_COOKED = "Could use... an explanation...",
        MAPSCROLL = "A blank map. Full of potential.",
        MARBLE = "Would make a nice counter top.",
        MARBLEBEAN = "I don't think this bean is edible.",
        MARBLEBEAN_SAPLING = "Just a petite marble bébé.",
        MARBLESHRUB = "If marble beans can grow, maybe they can be eaten.",
        MARBLEPILLAR = "I wonder how many counter tops I could get out of this...",
        MARBLETREE = "How supremely unnatural!",
        MARSH_BUSH =
        {
			BURNT = "Burned to ash.",
            BURNING = "It burns like any other bush.",
            GENERIC = "A prickly customer.",
            PICKED = "Not sure I want to do that again.",
        },
        BURNT_MARSH_BUSH = "What a shame.",
        MARSH_PLANT = "I wonder if it is edible.",
        MARSH_TREE =
        {
            BURNING = "You will not be missed.",
            BURNT = "The wood gives off a unique aroma when burned.",
            CHOPPED = "There. Now you cannot prick anyone.",
            GENERIC = "I am ever so glad I'm not a tree hugger.",
        },
        MAXWELL = "You! You... villain!",--single player
        MAXWELLHEAD = "He must eat massive sandwiches.",--removed
        MAXWELLLIGHT = "A light is always welcome.",--single player
        MAXWELLLOCK = "But where is the key?",--single player
        MAXWELLTHRONE = "Heavy is the bum that sits on the throne...",--single player
        MEAT = "I must remember to cut across the grain.",
        MEATBALLS = "I'm having a ball!",
        MEATRACK =
        {
            DONE = "Ready to test on my teeth!",
            DRYING = "Not quite dry enough.",
            DRYINGINRAIN = "Now it is more like a rehydrating rack...",
            GENERIC = "Just like the chefs of the stone age!",
            BURNT = "Too dry! Too dry!",
            DONE_NOTMEAT = "Et voila! It is done!",
            DRYING_NOTMEAT = "Not quite ready yet.",
            DRYINGINRAIN_NOTMEAT = "Now we're just watering it.",
        },
        MEAT_DRIED = "Could use chipotle...",
        MERM = "Fishmongers!",
        MERMHEAD =
        {
            GENERIC = "Its odor is not improving with time...",
            BURNT = "I think it needs to burned again! Pee-eew!",
        },
        MERMHOUSE =
        {
            GENERIC = "Fisherfolk live here. I can smell it.",
            BURNT = "That fire got the smell out.",
        },
        MINERHAT = "Aha! Now that is using my head!",
        MONKEY = "A new species of irritation.",
        MONKEYBARREL = "An absolute madhouse.",
        MONSTERLASAGNA = "What a wasted effort...",
        FLOWERSALAD = "Edible art!",
        ICECREAM = "The heat is sweetly beat!",
        WATERMELONICLE = "I feel like a kid again!",
        TRAILMIX = "Energy food!",
        HOTCHILI = "Spice up my life!",
        GUACAMOLE = "More like Greatamole!",
        MONSTERMEAT = "Hmmm, nice marbling...",
        MONSTERMEAT_DRIED = "Could use... better judgment...",
        MOOSE = "I wish you were a bit less moose-y and a lot more goose-y!",
        MOOSE_NESTING_GROUND = "Imagine how many omelets I could make with one of those eggs.",
        MOOSEEGG = "I think I'll leave this egg quite alone!",
        MOSSLING = "Looking for your momma? Apologies, but I hope you do not find her.",
        FEATHERFAN = "Why is it so big?",
        MINIFAN = "Like a cool ocean breeze.",
        GOOSE_FEATHER = "A plucked goose was here.",
        STAFF_TORNADO = "Does nature like being tamed?",
        MOSQUITO =
        {
            GENERIC = "We disagree on where my blood is best used.",
            HELD = "I do not care to be this close to it! Vile!",
        },
        MOSQUITOSACK = "Ugh! It can only be filled with one thing.",
        MOUND =
        {
            DUG = "What have I become?",
            GENERIC = "I cannot help wondering what might be down there.",
        },
        NIGHTLIGHT = "And I thought fluorescent tubes were a bad invention!",
        NIGHTMAREFUEL = "Who in their right mind would want to fuel MORE nightmares?",
        NIGHTSWORD = "This thing slices like a dream!",
        NITRE = "How curious.",
        ONEMANBAND = "What a racket!",
        OASISLAKE =
		{
			GENERIC = "I could use a little break.",
			EMPTY = "There's nothing but mud.",
		},
        PANDORASCHEST = "It's quite magnificent.",
        PANFLUTE = "This will be music to something's ears.",
        PAPYRUS = "I could write down my recipes on this.",
        WAXPAPER = "Wax paper! Always useful in the kitchen.",
        PENGUIN = "A cool customer.",
        PERD = "A fellow with excellent taste.",
        PEROGIES = "Mmmmm, pockets of palate punching pleasure!",
        PETALS = "Great in salads.",
        PETALS_EVIL = "Not so great in salads.",
        PHLEGM = "Ugh. Not food safe!",
        PICKAXE = "For those tough to crack nuts.",
        PIGGYBACK = "Cochon bag!",
        PIGHEAD =
        {
            GENERIC = "Ooh la la, the things I could do with you!",
            BURNT = "Not even the cheeks are left...",
        },
        PIGHOUSE =
        {
            FULL = "Looks like more than three little piggies in there.",
            GENERIC = "Can I blow this down?",
            LIGHTSOUT = "Yoo hoo! Anybody home?",
            BURNT = "Mmmm, barbecue!",
        },
        PIGKING = "Well, you've got the chops for it.",
        PIGMAN =
        {
            DEAD = "He wouldn't want himself to go to waste, would he?",
            FOLLOWER = "I do have a magnetic presence, do I not?",
            GENERIC = "Who bred you to walk upright like that? Deuced unsettling...",
            GUARD = "Alright, alright, moving along.",
            WEREPIG = "Aggression spoils the meat.",
        },
        PIGSKIN = "Crackling!",
        PIGTENT = "Sure to deliver sweet dreams.",
        PIGTORCH = "I wonder what it means?",
        PINECONE = "Pine-scented!",
        PINECONE_SAPLING = "Just a petite bébé.",
        LUMPY_SAPLING = "Just a petite bébé.",
        PITCHFORK = "Proper farm gear.",
        PLANTMEAT = "Meaty leaves? I'm so confused...",
        PLANTMEAT_COOKED = "Could use less oxymorons...",
        PLANT_NORMAL =
        {
            GENERIC = "The miracle of life!",
            GROWING = "That is it, just a little more...",
            READY = "Fresh-picked produce!",
            WITHERED = "Oh dear me, the crop has failed...",
        },
        POMEGRANATE = "Wonderful!",
        POMEGRANATE_COOKED = "Could use tahini and mint...",
        POMEGRANATE_SEEDS = "Future ingredients, just waiting to be grown!",
        POND = "I can't see the bottom...",
        POOP = "The end result of a fine meal.",
        FERTILIZER = "Sauce for my garden!",
        PUMPKIN = "I'm the pumpking of the world!",
        PUMPKINCOOKIE = "I've outdone myself this time.",
        PUMPKIN_COOKED = "Could use some pie crust and nutmeg...",
        PUMPKIN_LANTERN = "Trick 'r' neat!",
        PUMPKIN_SEEDS = "Future ingredients, just waiting to be grown!",
        PURPLEAMULET = "I must be crazy to fool around with this.",
        PURPLEGEM = "It holds deep secrets.",
        RABBIT =
        {
            GENERIC = "I haven't had rabbit in awhile...",
            HELD = "Your little heart is beating so fast.",
        },
        RABBITHOLE =
        {
            GENERIC = "Thump twice if you are fat and juicy.",
            SPRING = "What a pity rabbit season has ended.",
        },
        RAINOMETER =
        {
            GENERIC = "It measures moisture in the clouds.",
            BURNT = "It measures nothing now...",
        },
        RAINCOAT = "For a foggy Paris evening.",
        RAINHAT = "Better than a newspaper.",
        RATATOUILLE = "A veritable village of vegetables!",
        RAZOR = "If only I had aftershave.",
        REDGEM = "A deep fire burns within.",
        RED_CAP = "Could use cream and salt... And less poison.",
        RED_CAP_COOKED = "Perhaps I could make a good soup.",
        RED_MUSHROOM =
        {
            GENERIC = "Can't get fresher than that!",
            INGROUND = "It'll be hard to harvest like that.",
            PICKED = "There's nothing left.",
        },
        REEDS =
        {
            BURNING = "The fire took to those quite nicely.",
            GENERIC = "A small clump of reeds.",
            PICKED = "There's nothing left to pick.",
        },
        RELIC = "Ancient kitchenware.",
        RUINS_RUBBLE = "Delicious destruction.",
        RUBBLE = "Delicious destruction.",
        RESEARCHLAB =
        {
            GENERIC = "A center for learning.",
            BURNT = "That didn't cook very well.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "Oh, the things I'll learn!",
            BURNT = "The fire seemed to find it quite tasty.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "It boggles the mind.",
            BURNT = "The darkness is all burnt up.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "I won't even try to pronounce it...",
            BURNT = "Nothing but ashes.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "Part of my soul is within.",
            BURNT = "It won't be much good now.",
        },
        RESURRECTIONSTONE = "Looks like some sort of ritual stone.",
        ROBIN =
        {
            GENERIC = "Good afternoon, sir or madam!",
            HELD = "It's soft, and surprisingly calm.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "This little fellow seems quite frigid.",
            HELD = "Let me lend you my warmth, feathered friend.",
        },
        ROBOT_PUPPET = "Surely no one deserves such treatment!", --single player
        ROCK_LIGHT =
        {
            GENERIC = "The lava has crusted over.",--removed
            OUT = "It has no heat left to give.",--removed
            LOW = "Like a pie on a proverbial windowsill, it will soon cool.",--removed
            NORMAL = "Nature's fiery fondue pot.",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "I'm sure I'm strong enough to move it.",
            RAISED = "I can't get at it.",
        },
        ROCK = "Don't you go rolling off on me.",
        PETRIFIED_TREE = "This tree is made of stone.",
        ROCK_PETRIFIED_TREE = "Did someone sculpt that?",
        ROCK_PETRIFIED_TREE_OLD = "Did someone sculpt that?",
        ROCK_ICE =
        {
            GENERIC = "Brr!",
            MELTED = "It's just liquid now.",
        },
        ROCK_ICE_MELTED = "It's just liquid now.",
        ICE = "That's ice.",
        ROCKS = "Bite-sized boulders.",
        ROOK = "What a rude contraption.",
        ROPE = "A bit too thick to tie up a roast.",
        ROTTENEGG = "Pee-eew!",
        ROYAL_JELLY = "I feel inspired to try my hand at confections!",
        JELLYBEAN = "A little something sweet to brighten the day.",
        SADDLE_BASIC = "Let's see if I can ride on this.",
        SADDLE_RACE = "Adds a little spice to my ride.",
        SADDLE_WAR = "Durable.",
        SADDLEHORN = "It's like a spatula for a saddle.",
        SALTLICK = "Too salty.",
        BRUSH = "For tidying unkempt beast hair.",
		SANITYROCK =
		{
			ACTIVE = "It's tugging on my mind.",
			INACTIVE = "The darkness lurks within.",
		},
		SAPLING =
		{
			BURNING = "Those burn quite dramatically.",
			WITHERED = "It could use some love.",
			GENERIC = "Those could be key to my continued survival.",
			PICKED = "There is nothing left for me to grasp!",
			DISEASED = "Would some nice soup make you feel better?", --removed
			DISEASING = "It's coming down with something.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "He seems nice.",
			BURNING = "What a tragedy.",
			BURNT = "Overcooked.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Just need some stone to get cooking.",
			BLOCK = "Ready for the chisel.",
			SCULPTURE = "Someone's a very talented artist.",
			BURNT = "Overcooked.",
   		},
        SCULPTURE_KNIGHTHEAD = "Looks like it came off a sculpture somewhere.",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "What an odd shape for a rock.",
			UNCOVERED = "It's looking for its missing piece.",
			FINISHED = "Well, it's fixed now.",
			READY = "I think... it's stirring!",
		},
        SCULPTURE_BISHOPHEAD = "I think it was part of a statue.",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Some old, worn stone.",
			UNCOVERED = "It looks incomplete.",
			FINISHED = "It looks much better.",
			READY = "I think... it's stirring!",
		},
        SCULPTURE_ROOKNOSE = "That doesn't look like a natural rock.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Parts of it look like they were sculpted.",
			UNCOVERED = "Where is your nose?",
			FINISHED = "That looks nice.",
			READY = "I think... it's stirring!",
		},
        GARGOYLE_HOUND = "I feel strangely uneasy.",
        GARGOYLE_WEREPIG = "It won't begin to move, will it?",
		SEEDS = "You may grow up to be delicious one day.",
		SEEDS_COOKED = "Could use smoked paprika...",
		SEWING_KIT = "Not exactly my specialty.",
		SEWING_TAPE = "Winona is really very resourceful.",
		SHOVEL = "I'm not the landscaping type.",
		SILK = "Is that sanitary?",
		SKELETON = "I have a bone to pick with you.",
		SCORCHED_SKELETON = "A kitchen mishap, maybe?",
		SKULLCHEST = "What an ominous container.", --removed
		SMALLBIRD =
		{
			GENERIC = "Hello food... uh, friend.",
			HUNGRY = "I suppose I could whip something up for you.",
			STARVING = "You look famished!",
			SLEEPING = "Sleep well, petite oiseau.",
		},
		SMALLMEAT = "Fresh protein!",
		SMALLMEAT_DRIED = "Could use a teriyaki glaze...",
		SPAT = "I do enjoy a good mutton.",
		SPEAR = "For kebab-ing.",
		SPEAR_WATHGRITHR = "I'm better with a spatula.",
		WATHGRITHRHAT = "I don't have the confidence to pull it off like she does.",
		SPIDER =
		{
			DEAD = "Please no rain!",
			GENERIC = "You are not for eating.",
			SLEEPING = "It should make itself a silk pillow.",
		},
		SPIDERDEN = "A spider has to live somewhere, I suppose.",
		SPIDEREGGSACK = "This is probably a delicacy somewhere.",
		SPIDERGLAND = "Alternative medicine.",
		SPIDERHAT = "Well, it is on my head now. Best make the most of it.",
		SPIDERQUEEN = "I will not bend the knee to the likes of you!",
		SPIDER_WARRIOR =
		{
			DEAD = "It knew the risks.",
			GENERIC = "Does this mean you are even more warlike than the others?",
			SLEEPING = "It is having a flashback to the spider war...",
		},
		SPOILED_FOOD = "It is a sin to waste food...",
        STAGEHAND =
        {
			AWAKE = "I've got to hand it to you, I was startled!",
			HIDING = "Oh, what a nice table setting.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "A lovely marble statue.",
            TYPE1 = "Well, as they say, if it ain't baroque!",
            TYPE2 = "She seems regal.",
            TYPE3 = "Some fresh cut flowers would brighten it up!", --bird bath type statue
        },
		STATUEHARP = "Headless harpsmen.",
		STATUEMAXWELL = "He is literally made of stone.",
		STEELWOOL = "I used to use this to scrub dishes.",
		STINGER = "It would really sting to not have a use for this.",
		STRAWHAT = "Now I am on island time.",
		STUFFEDEGGPLANT = "Slightly smoky flesh, savory filling. Ah!",
		SWEATERVEST = "I feel so much better all of the sudden.",
		REFLECTIVEVEST = "Well, it should be hard to lose.",
		HAWAIIANSHIRT = "When in Rome...",
		TAFFY = "I hope it never dislodges from my teeth!",
		TALLBIRD = "Leggy.",
		TALLBIRDEGG = "I wonder what its incubation period is?",
		TALLBIRDEGG_COOKED = "Could use sliced fried tomatoes and beans...",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Oh, you poor egg, you are so cold!",
			GENERIC = "There is activity!",
			HOT = "I hope you don't hardboil.",
			LONG = "This is going to take some dedication.",
			SHORT = "A hatching is in the offing!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "No vacancy here.",
			PICKED = "Empty nest syndrome is setting in.",
		},
		TEENBIRD =
		{
			GENERIC = "You are sort of tall, I guess...",
			HUNGRY = "Teenagers, always hungry!",
			STARVING = "Are you trying to eat me out of base and home?",
			SLEEPING = "A growing bird needs their rest.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Where shall we go, thing?", --single player
			GENERIC = "It leads somewhere. And that is what I am afraid of.", --single player
			LOCKED = "It denies my access.", --single player
			PARTIAL = "It requires something additional.", --single player
		},
		TELEPORTATO_BOX = "\"This\" likely connects to a \"that.\"", --single player
		TELEPORTATO_CRANK = "Definitely for a cranking action of some kind.", --single player
		TELEPORTATO_POTATO = "This, I do not even...", --single player
		TELEPORTATO_RING = "One ring to teleport them all!", --single player
		TELESTAFF = "Let us take a trip. I am not picky as to where.",
		TENT =
		{
			GENERIC = "For roughing it.",
			BURNT = "A good night's sleep, up in smoke.",
		},
		SIESTAHUT =
		{
			GENERIC = "Comes in handy after a big lunch.",
			BURNT = "Overcooked.",
		},
		TENTACLE = "Calamari?",
		TENTACLESPIKE = "This would stick in my throat.",
		TENTACLESPOTS = "Would make a decent kitchen rag.",
		TENTACLE_PILLAR = "If only it were squid and not... whatever it is...",
        TENTACLE_PILLAR_HOLE = "I'm ready to take the plunge.",
		TENTACLE_PILLAR_ARM = "If only it were squid and not... whatever it is...",
		TENTACLE_GARDEN = "If only it were squid and not... whatever it is...",
		TOPHAT = "For a night out on the town...?",
		TORCH = "Not great for caramelizing crème brûlée, but it will do for seeing.",
		TRANSISTOR = "Positively charged to get my hands on one!",
		TRAP = "I do not wish to be so tricky, but the dinner bell calls me.",
		TRAP_TEETH = "This is not a cruelty-free trap.",
		TRAP_TEETH_MAXWELL = "I must remember where this is...", --single player
		TREASURECHEST =
		{
			GENERIC = "Treasure!",
			BURNT = "Its treasure-chesting days are over.",
		},
		TREASURECHEST_TRAP = "Hmmm, something does not feel right about this...",
		SACRED_CHEST =
		{
			GENERIC = "Now to add the final ingredients.",
			LOCKED = "Have I not been found worthy?",
		},
		TREECLUMP = "Someone or something does not want me to tree-spass.", --removed

		TRINKET_1 = "Someone must have really lost their marbles.", --Melted Marbles
		TRINKET_2 = "I'll hum my own tune.", --Fake Kazoo
		TRINKET_3 = "Some things can't be undone.", --Gord's Knot
		TRINKET_4 = "Somewhere there's a lawn that misses you.", --Gnome
		TRINKET_5 = "A rocketship for ants?", --Toy Rocketship
		TRINKET_6 = "These almost look dangerous.", --Frazzled Wires
		TRINKET_7 = "A distraction of little substance.", --Ball and Cup
		TRINKET_8 = "Ah, memories of bathing.", --Rubber Bung
		TRINKET_9 = "Buttons that are not so cute.", --Mismatched Buttons
		TRINKET_10 = "Manmade masticators.", --Dentures
		TRINKET_11 = "He doesn't seem trustworthy to me.", --Lying Robot
		TRINKET_12 = "I know of no recipe that calls for this.", --Dessicated Tentacle
		TRINKET_13 = "You'd look so sweet in your own little garden.", --Gnomette
		TRINKET_14 = "I could still use this for measuring.", --Leaky Teacup
		TRINKET_15 = "Aren't we all, mon ami.", --Pawn
		TRINKET_16 = "Aren't we all, mon ami.", --Pawn
		TRINKET_17 = "A pity.", --Bent Spork
		TRINKET_18 = "What could be inside?", --Trojan Horse
		TRINKET_19 = "It's having a hard time staying upright.", --Unbalanced Top
		TRINKET_20 = "You scratch my back, I scratch yours, non?", --Backscratcher
		TRINKET_21 = "No kitchen is complete without one.", --Egg Beater
		TRINKET_22 = "This would be handy if I had a roast to make.", --Frayed Yarn
		TRINKET_23 = "This seems shoehorned in.", --Shoehorn
		TRINKET_24 = "I think Mme. Wickerbottom had a cat.", --Lucky Cat Jar
		TRINKET_25 = "It's not a very pleasant smell.", --Air Unfreshener
		TRINKET_26 = "Who hurt you, sweet tuber.", --Potato Cup
		TRINKET_27 = "I don't have much to hang up anymore.", --Coat Hanger
		TRINKET_28 = "A little, tiny rook.", --Rook
        TRINKET_29 = "A little, tiny rook.", --Rook
        TRINKET_30 = "It looks all knight to me.", --Knight
        TRINKET_31 = "It looks all knight to me.", --Knight
        TRINKET_32 = "I see right through this sort of stuff.", --Cubic Zirconia Ball
        TRINKET_33 = "It wouldn't go with my look.", --Spider Ring
        TRINKET_34 = "I know better than to mess with this.", --Monkey Paw
        TRINKET_35 = "Whatever was inside is gone now.", --Empty Elixir
        TRINKET_36 = "Oh dear, how spooky!", --Faux fangs
        TRINKET_37 = "How ominous.", --Broken Stake
        TRINKET_38 = "I don't want that near my eyes.", -- Binoculars Griftlands trinket
        TRINKET_39 = "It must be so lonely.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Mm. Escargot.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "I'm not going to mess with it. It seems dangerous.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "How cute.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "What a fun little toy.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Hm. Not edible.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "You'd have to be a real dupe to think you could get that working.", -- Odd Radio ONI trinket
        TRINKET_46 = "Hm, what's that? I spaced out.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Mon dieu! My hand passes right through it!",
        LOST_TOY_2  = "Mon dieu! My hand passes right through it!",
        LOST_TOY_7  = "Mon dieu! My hand passes right through it!",
        LOST_TOY_10 = "Mon dieu! My hand passes right through it!",
        LOST_TOY_11 = "Mon dieu! My hand passes right through it!",
        LOST_TOY_14 = "Mon dieu! My hand passes right through it!",
        LOST_TOY_18 = "Mon dieu! My hand passes right through it!",
        LOST_TOY_19 = "Mon dieu! My hand passes right through it!",
        LOST_TOY_42 = "Mon dieu! My hand passes right through it!",
        LOST_TOY_43 = "Mon dieu! My hand passes right through it!",

        HALLOWEENCANDY_1 = "These can be enjoyable, now and then.",
        HALLOWEENCANDY_2 = "There are better confections available, in my professional opinion.",
        HALLOWEENCANDY_3 = "It could use some butter and salt.",
        HALLOWEENCANDY_4 = "Licorice is only for the most refined palates.",
        HALLOWEENCANDY_5 = "The closest thing I've found to an after dinner mint.",
        HALLOWEENCANDY_6 = "I don't think those are fit to eat.",
        HALLOWEENCANDY_7 = "Real raisins! Think of the culinary potential.",
        HALLOWEENCANDY_8 = "I don't need the whole thing, just a couple licks.",
        HALLOWEENCANDY_9 = "I wouldn't want to ruin my dinner.",
        HALLOWEENCANDY_10 = "The younger among us would enjoy it more than me.",
        HALLOWEENCANDY_11 = "There are few things I love more than milk chocolate.",
        HALLOWEENCANDY_12 = "I'm sure it tastes better than it looks.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "It's a little too sweet for my taste.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "It sticks in my teeth, but it's well worth it.", --Hot Lava pepper candy
        CANDYBAG = "Where I keep all my confections!",

		HALLOWEEN_ORNAMENT_1 = "Fear upsets my stomach.",
		HALLOWEEN_ORNAMENT_2 = "Its wings are so... leathery.",
		HALLOWEEN_ORNAMENT_3 = "I'm afraid to touch it.",
		HALLOWEEN_ORNAMENT_4 = "I miss calamari.",
		HALLOWEEN_ORNAMENT_5 = "How creepy.",
		HALLOWEEN_ORNAMENT_6 = "I'd rather not eat crow.",

		HALLOWEENPOTION_DRINKS_WEAK = "I don't think it'll do much.",
		HALLOWEENPOTION_DRINKS_POTENT = "Oof, smells strong.",
        HALLOWEENPOTION_BRAVERY = "I'm not convinced I want to drink it.",
		HALLOWEENPOTION_MOON = "I wouldn't drink that, mon ami.",
		HALLOWEENPOTION_FIRE_FX = "The fire has caramelized.",
		MADSCIENCE_LAB = "Chemistry is just fancy cooking, non?",
		LIVINGTREE_ROOT = "Edible roots, perhaps?",
		LIVINGTREE_SAPLING = "Just a petite bébé.",

        DRAGONHEADHAT = "Oh! Do I get to be the head?",
        DRAGONBODYHAT = "I can be the middle of the dragon.",
        DRAGONTAILHAT = "I'm just happy to be part of the festivities.",
        PERDSHRINE =
        {
            GENERIC = "I should show some appreciation. I've eaten a lot of turkey legs.",
            EMPTY = "I should give it something special.",
            BURNT = "Overcooked.",
        },
        REDLANTERN = "I do like festivals like this.",
        LUCKY_GOLDNUGGET = "It's nice to have a bit of luck.",
        FIRECRACKERS = "Like oil splattering in a hot pan.",
        PERDFAN = "Would anyone like me to cool them down?",
        REDPOUCH = "How nice it is to have luck on my side!",
        WARGSHRINE =
        {
            GENERIC = "Dogs are nice. I should pay tribute to them.",
            EMPTY = "Maybe it's hungry.",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Overcooked.",
        },
        CLAYWARG =
        {
        	GENERIC = "I'm not on the menu!",
        	STATUE = "It looks quite nice.",
        },
        CLAYHOUND =
        {
        	GENERIC = "Don't eat me, I'm unseasoned!",
        	STATUE = "Someone's a very talented sculptor.",
        },
        HOUNDWHISTLE = "I think I'm too old to hear it.",
        CHESSPIECE_CLAYHOUND = "I'm glad it's not trying to bite me.",
        CHESSPIECE_CLAYWARG = "I'm not sure why we memorialized this very scary creature.",

		PIGSHRINE =
		{
            GENERIC = "I should show my appreciation for delicious, tender pork.",
            EMPTY = "I think I should give it a gift.",
            BURNT = "It spent a second too long in the oven.",
		},
		PIG_TOKEN = "I'll try not to spend it all in one place.",
		PIG_COIN = "The best tip I have ever received.",
		YOTP_FOOD1 = "What a treat it is to be cooked for for a change!",
		YOTP_FOOD2 = "Respectfully I think I may pass on this course.",
		YOTP_FOOD3 = "I'd never turn my nose up at street food.",

		PIGELITE1 = "Perhaps we can talk this out?", --BLUE
		PIGELITE2 = "Sorry mon ami, that gold's mine!", --RED
		PIGELITE3 = "You belong in a pan!", --WHITE
		PIGELITE4 = "Stay away!", --GREEN

		PIGELITEFIGHTER1 = "Perhaps we can talk this out?", --BLUE
		PIGELITEFIGHTER2 = "Sorry mon ami, that gold's mine!", --RED
		PIGELITEFIGHTER3 = "You belong in a pan!", --WHITE
		PIGELITEFIGHTER4 = "Stay away!", --GREEN

		CARRAT_GHOSTRACER = "Oh! Well aren't you... cute?",

        YOTC_CARRAT_RACE_START = "Where do I even begin... oh, right here!",
        YOTC_CARRAT_RACE_CHECKPOINT = "Check!",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "La fin!",
            BURNT = "Burnt to a crisp.",
            I_WON = "We've won, mon ami!",
            SOMEONE_ELSE_WON = "{winner}'s carrat ran quite the race! Well done!",
        },

		YOTC_CARRAT_RACE_START_ITEM = "This will make a fine starting point.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Ah, this will keep the carrat's on course.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Every race needs a finish line.",

		YOTC_SEEDPACKET = "I wonder what will grow from this?",
		YOTC_SEEDPACKET_RARE = "I hope it grows into some tasty ingredients.",

		MINIBOATLANTERN = "Float along, little lantern.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "How do you do?",
            EMPTY = "Are you hungry?",
            BURNT = "Did I leave the oven on?",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "I hope the poor thing doesn't get too dizzy.",
            RAT = "Train hard, mon ami!",
            BURNT = "It's been burnt to a crisp.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "What a nice little wheel.",
            RAT = "You're doing very well!",
            BURNT = "It's been burnt to a crisp.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "I also find food quite motivating.",
            RAT = "Practice makes perfect!",
            BURNT = "It's been burnt to a crisp.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "Is that... a tiny jumping rope?",
            RAT = "Such perserverance! Tres bon!",
            BURNT = "It's been burnt to a crisp.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "I should find a good place to put this.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "My racer will be in tip top condition in no time.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "I'd better begin training my carrat!",
        YOTC_CARRAT_GYM_REACTION_ITEM = "I wonder how my carrat will react to this...",

        YOTC_CARRAT_SCALE_ITEM = "I hope I get a high rating.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "It takes four main ingredients to make a first-rate racer.",
            CARRAT = "Perhaps we should train some more.",
            CARRAT_GOOD = "I can taste victory already!",
            BURNT = "It's been overcooked.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "I wonder what I can cook up with this?",
            EMPTY = "It needs a special ingredient.",
            BURNT = "Far too well done.",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Presentation is important!",
            OCCUPIED = "And now, to dress the steak!",
            BURNT = "En flambé.",
        },
        BEEFALO_GROOMER_ITEM = "I'd better build it, non?",

		BISHOP_CHARGE_HIT = "Mon dieu!",
		TRUNKVEST_SUMMER = "Fashionably refreshing.",
		TRUNKVEST_WINTER = "Toasty and trendy.",
		TRUNK_COOKED = "Could use... Hm... I'm stumped...",
		TRUNK_SUMMER = "This meat has a gamey odor.",
		TRUNK_WINTER = "Not the finest cut of meat.",
		TUMBLEWEED = "What secrets do you hold?",
		TURKEYDINNER = "I'm getting sleepy just looking at it!",
		TWIGS = "The start of a good cooking fire.",
		UMBRELLA = "I will try to remember not to open indoors.",
		GRASS_UMBRELLA = "A bit of shade is better than none.",
		UNIMPLEMENTED = "It appears unfinished.",
		WAFFLES = "Oh, brunch, I have missed you so!",
		WALL_HAY =
		{
			GENERIC = "Calling it a \"wall\" is kind of a stretch.",
			BURNT = "That is what I expected.",
		},
		WALL_HAY_ITEM = "Hay look, a wall!",
		WALL_STONE = "Good stone work.",
		WALL_STONE_ITEM = "I feel secure behind this.",
		WALL_RUINS = "Look at the carvings...",
		WALL_RUINS_ITEM = "The stories these tell... fascinating...",
		WALL_WOOD =
		{
			GENERIC = "Putting down stakes.",
			BURNT = "Wood burns. Who knew? ...Me!?",
		},
		WALL_WOOD_ITEM = "Delivers a rather wooden performance as a wall.",
		WALL_MOONROCK = "I do kind of wish it was made of cheese.",
		WALL_MOONROCK_ITEM = "I can't believe this was once on the moon.",
		FENCE = "A fence.",
        FENCE_ITEM = "The ingredients for a fence.",
        FENCE_GATE = "Like an oven door.",
        FENCE_GATE_ITEM = "The ingredients for a gate.",
		WALRUS = "They move faster than you'd think.",
		WALRUSHAT = "Smells a little musty...",
		WALRUS_CAMP =
		{
			EMPTY = "Yes, vacancy.",
			GENERIC = "Some outdoorsy types made this.",
		},
		WALRUS_TUSK = "It won't be needing this anymore.",
		WARDROBE =
		{
			GENERIC = "I wish I'd had the chance to bring more clothes with me.",
            BURNING = "The wardrobe is burning!",
			BURNT = "We had some nice things in there.",
		},
		WARG = "Leader of the pack.",
        WARGLET = "I won't be put on the menu today!",
        
		WASPHIVE = "Not your average bees.",
		WATERBALLOON = "A balloon, filled with water? What a funny idea.",
		WATERMELON = "Despite its name, it is mostly filled with deliciousness!",
		WATERMELON_COOKED = "Could use mint and feta...",
		WATERMELONHAT = "Aaaahhhhhh sweet relief...",
		WAXWELLJOURNAL = "Maman used to keep a journal, before her memory went.",
		WETGOOP = "Thankfully my sous chefs aren't here to witness this abomination...",
        WHIP = "I'd rather whip up a nice meringue.",
		WINTERHAT = "I know when to don this, and not a minute sooner.",
		WINTEROMETER =
		{
			GENERIC = "Splendid. I should like to know when the worm is going to turn.",
			BURNT = "Foresight is 0/0.",
		},

        WINTER_TREE =
        {
            BURNT = "Now we'll have to grow another.",
            BURNING = "It's burning!",
            CANDECORATE = "Shall we \"spruce\" it up a little? Hm?",
            YOUNG = "It's coming along nicely.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "A pinecone should get things rolling.",
            BURNT = "That won't kill my spirit.",
		},
        WINTER_ORNAMENT = "How festive!",
        WINTER_ORNAMENTLIGHT = "I love seeing the forest lit up at night.",
        WINTER_ORNAMENTBOSS = "We've earned a moment to celebrate.",
		WINTER_ORNAMENTFORGE = "It's nice to be alive and safe.",
		WINTER_ORNAMENTGORGE = "I feel like cooking something.",

        WINTER_FOOD1 = "It has that \"homecooked\" charm.", --gingerbread cookie
        WINTER_FOOD2 = "Cooking is a way of expressing love.", --sugar cookie
        WINTER_FOOD3 = "The candy strands are expertly entwined.", --candy cane
        WINTER_FOOD4 = "It grows on you.", --fruitcake
        WINTER_FOOD5 = "I wouldn't turn down a slice.", --yule log cake
        WINTER_FOOD6 = "Just like maman used to make.", --plum pudding
        WINTER_FOOD7 = "Just the right amount of sweetness.", --apple cider
        WINTER_FOOD8 = "It smells like comfort and contentment.", --hot cocoa
        WINTER_FOOD9 = "I'm so happy I could weep.", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Finally, a proper oven!",
			COOKING = "Cooking should never be rushed.",
			ALMOST_DONE_COOKING = "Ah, that delicious aroma tells me it's almost done!",
			DISH_READY = "Et voila! Food is served.",
		},
		BERRYSAUCE = "Made from only the most festive berries.",
		BIBINGKA = "A tasty holiday treat from the Philippines.",
		CABBAGEROLLS = "A surprisingly time consuming dish, but well worth the wait.",
		FESTIVEFISH = "There's always room for new traditions!",
		GRAVY = "Rich and full of flavor.",
		LATKES = "Some chives, a dollop of sour cream, c'est parfait!",
		LUTEFISK = "A traditional Scandinavian holiday recipe.",
		MULLEDDRINK = "The taste of cinnamon always puts me in the holiday spirit!",
		PANETTONE = "A traditional Italian Yuletide treat.",
		PAVLOVA = "A perfect Pavlova!",
		PICKLEDHERRING = "It's really quite delicious.",
		POLISHCOOKIE = "A rich pastry with a sweet fruity filling.",
		PUMPKINPIE = "Simple and classic.",
		ROASTTURKEY = "The pièce de résistance of any holiday feast!",
		STUFFING = "To preserve the crispness, I actually cook it separate from the turkey.",
		SWEETPOTATO = "All the sweetness of the holidays.",
		TAMALES = "You can taste the care that went into this dish.",
		TOURTIERE = "Ah oui, now that's a meat pie!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Ah yes! A proper feasting table!",
			HAS_FOOD = "A masterpiece!",
			WRONG_TYPE = "Ah no! That does not seem right!",
			BURNT = "Oh dear, it looks a bit overdone.",
		},

		GINGERBREADWARG = "Looks sweet, but acts sour!",
		GINGERBREADHOUSE = "The piping on those roofs - magnifique!",
		GINGERBREADPIG = "I can catch you, gingerbread pig!",
		CRUMBS = "I'm on its delicious trail!",
		WINTERSFEASTFUEL = "To imbue my food with festive spirit.",

        KLAUS = "He doesn't look very jolly.",
        KLAUS_SACK = "There might be all sorts of treats inside.",
		KLAUSSACKKEY = "Well, it's the key to something.",
		WORMHOLE =
		{
			GENERIC = "That is no ordinary tooth-lined hole in the ground!",
			OPEN = "Am I really doing this?",
		},
		WORMHOLE_LIMITED = "These things can look worse?",
		ACCOMPLISHMENT_SHRINE = "I always wished to make a name for myself.", --single player
		LIVINGTREE = "Tres suspicious...",
		ICESTAFF = "It flash freezes poulet!",
		REVIVER = "I don't like that it's still beating.",
		SHADOWHEART = "That beef heart is almost certainly past its prime.",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "A picture of lots of unprepared seafood. I'm hungry.",
			LINE_2 = "This tablet's all worn down.",
			LINE_3 = "The world is flooded by a finely fermented black bean sauce.",
			LINE_4 = "The prawns being de-shelled.",
			LINE_5 = "The prawns have ascended into deliciousness.",
		},
        ATRIUM_STATUE = "When I turn my back, I imagine I hear it breathing.",
        ATRIUM_LIGHT =
        {
			ON = "There's a strange force behind this.",
			OFF = "Off, for now.",
		},
        ATRIUM_GATE =
        {
			ON = "It's ready.",
			OFF = "All the pieces are back in place.",
			CHARGING = "I think it's charging up.",
			DESTABILIZING = "Something unsafe is happening.",
			COOLDOWN = "It's in a recovery period.",
        },
        ATRIUM_KEY = "This seems very precious.",
		LIFEINJECTOR = "It's not so bad, if you close your eyes.",
		SKELETON_PLAYER =
		{
			MALE = "Poor %s was overcome by %s.",
			FEMALE = "Poor %s was overcome by %s.",
			ROBOT = "Poor %s was overcome by %s.",
			DEFAULT = "Poor %s was overcome by %s.",
		},
		HUMANMEAT = "I suppose I can't be picky with my ingredients, but...",
		HUMANMEAT_COOKED = "Some dishes probably shouldn't be made.",
		HUMANMEAT_DRIED = "I think I've lost my appetite.",
		ROCK_MOON = "It has a very peaceful energy.",
		MOONROCKNUGGET = "A little piece of sky to hold in my hand.",
		MOONROCKCRATER = "An eye without an iris.",
		MOONROCKSEED = "It's beautiful, isn't it?",

        REDMOONEYE = "It looks a bit like an eye with a gem inside, non?",
        PURPLEMOONEYE = "It's a purple stone eye.",
        GREENMOONEYE = "So long as it doesn't blink.",
        ORANGEMOONEYE = "This eye will keep an eye on things.",
        YELLOWMOONEYE = "Keep an eye out for me, oui?",
        BLUEMOONEYE = "It should keep watch for us.",

        --Arena Event
        LAVAARENA_BOARLORD = "He's the one who cooked up this whole thing.",
        BOARRIOR = "Bring it on, géant cochon!",
        BOARON = "Begone, cochon!",
        PEGHOOK = "Not a very polite gentleman.",
        TRAILS = "Be gentle, please!",
        TURTILLUS = "They seem a bit prickly, non?",
        SNAPPER = "Please don't take any bites out of me.",
		RHINODRILL = "Can't we just talk?",
		BEETLETAUR = "We don't really have to fight, do we?",

        LAVAARENA_PORTAL =
        {
            ON = "Let's go, tout suite!",
            GENERIC = "One day I'll find the portal that takes me home...",
        },
        LAVAARENA_KEYHOLE = "That's our way back.",
		LAVAARENA_KEYHOLE_FULL = "Time to leave, oui?",
        LAVAARENA_BATTLESTANDARD = "We must destroy it, tout suite!",
        LAVAARENA_SPAWNER = "That's where our foes keep coming from!",

        HEALINGSTAFF = "I like this.",
        FIREBALLSTAFF = "A portable stovetop.",
        HAMMER_MJOLNIR = "It's a heavy duty tenderizer.",
        SPEAR_GUNGNIR = "That's just a big skewer.",
        BLOWDART_LAVA = "That might hurt somebody.",
        BLOWDART_LAVA2 = "That looks very dangerous.",
        LAVAARENA_LUCY = "Lucy looks a little different, non?",
        WEBBER_SPIDER_MINION = "Oh, my. Bonjour, petit araignée.",
        BOOK_FOSSIL = "I don't think that's my forte.",
--fallback to speech_wilson.lua 		LAVAARENA_BERNIE = "He might make a good distraction for us.",
		SPEAR_LANCE = "Maybe I could make kabobs?",
		BOOK_ELEMENTAL = "I don't think that's my forte.",
--fallback to speech_wilson.lua 		LAVAARENA_ELEMENTAL = "It's a rock monster!",

--fallback to speech_wilson.lua    		LAVAARENA_ARMORLIGHT = "Light, but not very durable.",
--fallback to speech_wilson.lua 		LAVAARENA_ARMORLIGHTSPEED = "Lightweight and designed for mobility.",
--fallback to speech_wilson.lua 		LAVAARENA_ARMORMEDIUM = "It offers a decent amount of protection.",
--fallback to speech_wilson.lua 		LAVAARENA_ARMORMEDIUMDAMAGER = "That could help me hit a little harder.",
--fallback to speech_wilson.lua 		LAVAARENA_ARMORMEDIUMRECHARGER = "I'd have energy for a few more stunts wearing that.",
--fallback to speech_wilson.lua 		LAVAARENA_ARMORHEAVY = "That's as good as it gets.",
--fallback to speech_wilson.lua 		LAVAARENA_ARMOREXTRAHEAVY = "This armor has been petrified for maximum protection.",

--fallback to speech_wilson.lua 		LAVAARENA_FEATHERCROWNHAT = "Those fluffy feathers make me want to run!",
--fallback to speech_wilson.lua         LAVAARENA_HEALINGFLOWERHAT = "The blossom interacts well with healing magic.",
--fallback to speech_wilson.lua         LAVAARENA_LIGHTDAMAGERHAT = "My strikes would hurt a little more wearing that.",
--fallback to speech_wilson.lua         LAVAARENA_STRONGDAMAGERHAT = "It looks like it packs a wallop.",
--fallback to speech_wilson.lua         LAVAARENA_TIARAFLOWERPETALSHAT = "Looks like it amplifies healing expertise.",
--fallback to speech_wilson.lua         LAVAARENA_EYECIRCLETHAT = "It has a gaze full of science.",
--fallback to speech_wilson.lua         LAVAARENA_RECHARGERHAT = "Those crystals will quicken my abilities.",
--fallback to speech_wilson.lua         LAVAARENA_HEALINGGARLANDHAT = "This garland will restore a bit of my vitality.",
--fallback to speech_wilson.lua         LAVAARENA_CROWNDAMAGERHAT = "That could cause some major destruction.",

--fallback to speech_wilson.lua 		LAVAARENA_ARMOR_HP = "That should keep me safe.",

--fallback to speech_wilson.lua 		LAVAARENA_FIREBOMB = "It smells like brimstone.",
		LAVAARENA_HEAVYBLADE = "Perfect for chopping ingredients, and enemies!",

        --Quagmire
--fallback to speech_wilson.lua         QUAGMIRE_ALTAR =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         	GENERIC = "We'd better start cooking some offerings.",
--fallback to speech_wilson.lua         	FULL = "It's in the process of digestinating.",
--fallback to speech_wilson.lua     	},
--fallback to speech_wilson.lua 		QUAGMIRE_ALTAR_STATUE1 = "It's an old statue.",
--fallback to speech_wilson.lua 		QUAGMIRE_PARK_FOUNTAIN = "Been a long time since it was hooked up to water.",

--fallback to speech_wilson.lua         QUAGMIRE_HOE = "It's a farming instrument.",

--fallback to speech_wilson.lua         QUAGMIRE_TURNIP = "It's a raw turnip.",
--fallback to speech_wilson.lua         QUAGMIRE_TURNIP_COOKED = "Cooking is science in practice.",
--fallback to speech_wilson.lua         QUAGMIRE_TURNIP_SEEDS = "A handful of odd seeds.",

--fallback to speech_wilson.lua         QUAGMIRE_GARLIC = "The number one breath enhancer.",
--fallback to speech_wilson.lua         QUAGMIRE_GARLIC_COOKED = "Perfectly browned.",
--fallback to speech_wilson.lua         QUAGMIRE_GARLIC_SEEDS = "A handful of odd seeds.",

--fallback to speech_wilson.lua         QUAGMIRE_ONION = "Looks crunchy.",
--fallback to speech_wilson.lua         QUAGMIRE_ONION_COOKED = "A successful chemical reaction.",
--fallback to speech_wilson.lua         QUAGMIRE_ONION_SEEDS = "A handful of odd seeds.",

--fallback to speech_wilson.lua         QUAGMIRE_POTATO = "The apples of the earth.",
--fallback to speech_wilson.lua         QUAGMIRE_POTATO_COOKED = "A successful temperature experiment.",
--fallback to speech_wilson.lua         QUAGMIRE_POTATO_SEEDS = "A handful of odd seeds.",

--fallback to speech_wilson.lua         QUAGMIRE_TOMATO = "It's red because it's full of science.",
--fallback to speech_wilson.lua         QUAGMIRE_TOMATO_COOKED = "Cooking's easy if you understand chemistry.",
--fallback to speech_wilson.lua         QUAGMIRE_TOMATO_SEEDS = "A handful of odd seeds.",

--fallback to speech_wilson.lua         QUAGMIRE_FLOUR = "Ready for baking.",
--fallback to speech_wilson.lua         QUAGMIRE_WHEAT = "It looks a bit grainy.",
--fallback to speech_wilson.lua         QUAGMIRE_WHEAT_SEEDS = "A handful of odd seeds.",
        --NOTE: raw/cooked carrot uses regular carrot strings
--fallback to speech_wilson.lua         QUAGMIRE_CARROT_SEEDS = "A handful of odd seeds.",

--fallback to speech_wilson.lua         QUAGMIRE_ROTTEN_CROP = "I don't think the altar will want that.",

--fallback to speech_wilson.lua 		QUAGMIRE_SALMON = "Mm, fresh fish.",
--fallback to speech_wilson.lua 		QUAGMIRE_SALMON_COOKED = "Ready for the dinner table.",
--fallback to speech_wilson.lua 		QUAGMIRE_CRABMEAT = "No imitations here.",
--fallback to speech_wilson.lua 		QUAGMIRE_CRABMEAT_COOKED = "I can put a meal together in a pinch.",
--fallback to speech_wilson.lua 		QUAGMIRE_SUGARWOODTREE =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			GENERIC = "It's full of delicious, delicious sap.",
--fallback to speech_wilson.lua 			STUMP = "Where'd the tree go? I'm stumped.",
--fallback to speech_wilson.lua 			TAPPED_EMPTY = "Here sappy, sappy, sap.",
--fallback to speech_wilson.lua 			TAPPED_READY = "Sweet golden sap.",
--fallback to speech_wilson.lua 			TAPPED_BUGS = "That's how you get ants.",
--fallback to speech_wilson.lua 			WOUNDED = "It looks ill.",
--fallback to speech_wilson.lua 		},
--fallback to speech_wilson.lua 		QUAGMIRE_SPOTSPICE_SHRUB =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			GENERIC = "It reminds me of those tentacle monsters.",
--fallback to speech_wilson.lua 			PICKED = "I can't get anymore out of that shrub.",
--fallback to speech_wilson.lua 		},
--fallback to speech_wilson.lua 		QUAGMIRE_SPOTSPICE_SPRIG = "I could grind it up to make a spice.",
--fallback to speech_wilson.lua 		QUAGMIRE_SPOTSPICE_GROUND = "Flavorful.",
--fallback to speech_wilson.lua 		QUAGMIRE_SAPBUCKET = "We can use it to gather sap from the trees.",
--fallback to speech_wilson.lua 		QUAGMIRE_SAP = "It tastes sweet.",
--fallback to speech_wilson.lua 		QUAGMIRE_SALT_RACK =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			READY = "Salt has gathered on the rope.",
--fallback to speech_wilson.lua 			GENERIC = "Science takes time.",
--fallback to speech_wilson.lua 		},

--fallback to speech_wilson.lua 		QUAGMIRE_POND_SALT = "A little salty spring.",
--fallback to speech_wilson.lua 		QUAGMIRE_SALT_RACK_ITEM = "For harvesting salt from the pond.",

--fallback to speech_wilson.lua 		QUAGMIRE_SAFE =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			GENERIC = "It's a safe. For keeping things safe.",
--fallback to speech_wilson.lua 			LOCKED = "It won't open without the key.",
--fallback to speech_wilson.lua 		},

--fallback to speech_wilson.lua 		QUAGMIRE_KEY = "Safe bet this'll come in handy.",
--fallback to speech_wilson.lua 		QUAGMIRE_KEY_PARK = "I'll park it in my pocket until I get to the park.",
--fallback to speech_wilson.lua         QUAGMIRE_PORTAL_KEY = "This looks science-y.",


--fallback to speech_wilson.lua 		QUAGMIRE_MUSHROOMSTUMP =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			GENERIC = "Are those mushrooms? I'm stumped.",
--fallback to speech_wilson.lua 			PICKED = "I don't think it's growing back.",
--fallback to speech_wilson.lua 		},
--fallback to speech_wilson.lua 		QUAGMIRE_MUSHROOMS = "These are edible mushrooms.",
--fallback to speech_wilson.lua         QUAGMIRE_MEALINGSTONE = "The daily grind.",
--fallback to speech_wilson.lua 		QUAGMIRE_PEBBLECRAB = "That rock's alive!",


--fallback to speech_wilson.lua 		QUAGMIRE_RUBBLE_CARRIAGE = "On the road to nowhere.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_CLOCK = "Someone beat the clock. Literally.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_CATHEDRAL = "Preyed upon.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_PUBDOOR = "No longer a-door-able.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_ROOF = "Someone hit the roof.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_CLOCKTOWER = "That clock's been punched.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_BIKE = "Must have mis-spoke.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_HOUSE =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             "No one's here.",
--fallback to speech_wilson.lua             "Something destroyed this town.",
--fallback to speech_wilson.lua             "I wonder who they angered.",
--fallback to speech_wilson.lua         },
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_CHIMNEY = "Something put a damper on that chimney.",
--fallback to speech_wilson.lua         QUAGMIRE_RUBBLE_CHIMNEY2 = "Something put a damper on that chimney.",
--fallback to speech_wilson.lua         QUAGMIRE_MERMHOUSE = "What an ugly little house.",
--fallback to speech_wilson.lua         QUAGMIRE_SWAMPIG_HOUSE = "It's seen better days.",
--fallback to speech_wilson.lua         QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Some pig's house was ruined.",
--fallback to speech_wilson.lua         QUAGMIRE_SWAMPIGELDER =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "I guess you're in charge around here?",
--fallback to speech_wilson.lua             SLEEPING = "It's sleeping, for now.",
--fallback to speech_wilson.lua         },
--fallback to speech_wilson.lua         QUAGMIRE_SWAMPIG = "It's a super hairy pig.",

--fallback to speech_wilson.lua         QUAGMIRE_PORTAL = "Another dead end.",
--fallback to speech_wilson.lua         QUAGMIRE_SALTROCK = "Salt. The tastiest mineral.",
--fallback to speech_wilson.lua         QUAGMIRE_SALT = "It's full of salt.",
        --food--
--fallback to speech_wilson.lua         QUAGMIRE_FOOD_BURNT = "That one was an experiment.",
--fallback to speech_wilson.lua         QUAGMIRE_FOOD =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         	GENERIC = "I should offer it on the Altar of Gnaw.",
--fallback to speech_wilson.lua             MISMATCH = "That's not what it wants.",
--fallback to speech_wilson.lua             MATCH = "Science says this will appease the sky God.",
--fallback to speech_wilson.lua             MATCH_BUT_SNACK = "It's more of a light snack, really.",
--fallback to speech_wilson.lua         },

--fallback to speech_wilson.lua         QUAGMIRE_FERN = "Probably chock full of vitamins.",
--fallback to speech_wilson.lua         QUAGMIRE_FOLIAGE_COOKED = "We cooked the foliage.",
--fallback to speech_wilson.lua         QUAGMIRE_COIN1 = "I'd like more than a penny for my thoughts.",
--fallback to speech_wilson.lua         QUAGMIRE_COIN2 = "A decent amount of coin.",
--fallback to speech_wilson.lua         QUAGMIRE_COIN3 = "Seems valuable.",
--fallback to speech_wilson.lua         QUAGMIRE_COIN4 = "We can use these to reopen the Gateway.",
--fallback to speech_wilson.lua         QUAGMIRE_GOATMILK = "Good if you don't think about where it came from.",
--fallback to speech_wilson.lua         QUAGMIRE_SYRUP = "Adds sweetness to the mixture.",
--fallback to speech_wilson.lua         QUAGMIRE_SAP_SPOILED = "Might as well toss it on the fire.",
--fallback to speech_wilson.lua         QUAGMIRE_SEEDPACKET = "Sow what?",

--fallback to speech_wilson.lua         QUAGMIRE_POT = "This pot holds more ingredients.",
--fallback to speech_wilson.lua         QUAGMIRE_POT_SMALL = "Let's get cooking!",
--fallback to speech_wilson.lua         QUAGMIRE_POT_SYRUP = "I need to sweeten this pot.",
--fallback to speech_wilson.lua         QUAGMIRE_POT_HANGER = "It has hang-ups.",
--fallback to speech_wilson.lua         QUAGMIRE_POT_HANGER_ITEM = "For suspension-based cookery.",
--fallback to speech_wilson.lua         QUAGMIRE_GRILL = "Now all I need is a backyard to put it in.",
--fallback to speech_wilson.lua         QUAGMIRE_GRILL_ITEM = "I'll have to grill someone about this.",
--fallback to speech_wilson.lua         QUAGMIRE_GRILL_SMALL = "Barbecurious.",
--fallback to speech_wilson.lua         QUAGMIRE_GRILL_SMALL_ITEM = "For grilling small meats.",
--fallback to speech_wilson.lua         QUAGMIRE_OVEN = "It needs ingredients to make the science work.",
--fallback to speech_wilson.lua         QUAGMIRE_OVEN_ITEM = "For scientifically burning things.",
--fallback to speech_wilson.lua         QUAGMIRE_CASSEROLEDISH = "A dish for all seasonings.",
--fallback to speech_wilson.lua         QUAGMIRE_CASSEROLEDISH_SMALL = "For making minuscule motleys.",
--fallback to speech_wilson.lua         QUAGMIRE_PLATE_SILVER = "A silver plated plate.",
--fallback to speech_wilson.lua         QUAGMIRE_BOWL_SILVER = "A bright bowl.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

--fallback to speech_wilson.lua         QUAGMIRE_MERM_CART1 = "Any science in there?", --sammy's wagon
--fallback to speech_wilson.lua         QUAGMIRE_MERM_CART2 = "I could use some stuff.", --pipton's cart
--fallback to speech_wilson.lua         QUAGMIRE_PARK_ANGEL = "Take that, creature!",
--fallback to speech_wilson.lua         QUAGMIRE_PARK_ANGEL2 = "So lifelike.",
--fallback to speech_wilson.lua         QUAGMIRE_PARK_URN = "Ashes to ashes.",
--fallback to speech_wilson.lua         QUAGMIRE_PARK_OBELISK = "A monumental monument.",
--fallback to speech_wilson.lua         QUAGMIRE_PARK_GATE =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "Turns out a key was the key to getting in.",
--fallback to speech_wilson.lua             LOCKED = "Locked tight.",
--fallback to speech_wilson.lua         },
--fallback to speech_wilson.lua         QUAGMIRE_PARKSPIKE = "The scientific term is: \"Sharp pointy thing\".",
--fallback to speech_wilson.lua         QUAGMIRE_CRABTRAP = "A crabby trap.",
--fallback to speech_wilson.lua         QUAGMIRE_TRADER_MERM = "Maybe they'd be willing to trade.",
--fallback to speech_wilson.lua         QUAGMIRE_TRADER_MERM2 = "Maybe they'd be willing to trade.",

--fallback to speech_wilson.lua         QUAGMIRE_GOATMUM = "Reminds me of my old nanny.",
--fallback to speech_wilson.lua         QUAGMIRE_GOATKID = "This goat's much smaller.",
--fallback to speech_wilson.lua         QUAGMIRE_PIGEON =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             DEAD = "They're dead.",
--fallback to speech_wilson.lua             GENERIC = "He's just winging it.",
--fallback to speech_wilson.lua             SLEEPING = "It's sleeping, for now.",
--fallback to speech_wilson.lua         },
--fallback to speech_wilson.lua         QUAGMIRE_LAMP_POST = "Huh. Reminds me of home.",

--fallback to speech_wilson.lua         QUAGMIRE_BEEFALO = "Science says it should have died by now.",
--fallback to speech_wilson.lua         QUAGMIRE_SLAUGHTERTOOL = "Laboratory tools for surgical butchery.",

--fallback to speech_wilson.lua         QUAGMIRE_SAPLING = "I can't get anything else out of that.",
--fallback to speech_wilson.lua         QUAGMIRE_BERRYBUSH = "Those berries are all gone.",

--fallback to speech_wilson.lua         QUAGMIRE_ALTAR_STATUE2 = "What are you looking at?",
--fallback to speech_wilson.lua         QUAGMIRE_ALTAR_QUEEN = "A monumental monument.",
--fallback to speech_wilson.lua         QUAGMIRE_ALTAR_BOLLARD = "As far as posts go, this one is adequate.",
--fallback to speech_wilson.lua         QUAGMIRE_ALTAR_IVY = "Kind of clingy.",

--fallback to speech_wilson.lua         QUAGMIRE_LAMP_SHORT = "Enlightening.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "I feel so safe now.",
        	OFF = "It's not on.",
        	BURNING = "It, oh, it appears to be on fire.",
        	BURNT = "Crisp, non?",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "Oh good. I don't much like the dark out here.",
        	OFF = "Is it out of power?",
        	BURNING = "It, oh, it appears to be on fire.",
        	BURNT = "Crisp, non?",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "It's working really well!",
        	LOWPOWER = "It's getting a bit low, Winona.",
        	OFF = "I suppose it needs fuel.",
        	BURNING = "It, oh, it appears to be on fire.",
        	BURNT = "Crisp, non?",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "It's nice to have Winona around.",
        	LOWPOWER = "It's getting a bit low, Winona.",
        	OFF = "What sort of fuel does this take?",
        	BURNING = "It, oh, it appears to be on fire.",
        	BURNT = "Crisp, non?",
        },

        --Wormwood
        COMPOSTWRAP = "I'm frankly offended.",
        ARMOR_BRAMBLE = "I'll have to be very careful putting it on.",
        TRAP_BRAMBLE = "My salady friend made this.",

        BOATFRAGMENT03 = "Ah non! She is in pieces!",
        BOATFRAGMENT04 = "Ah non! She is in pieces!",
        BOATFRAGMENT05 = "Ah non! She is in pieces!",
		BOAT_LEAK = "I should do something about that.",
        MAST = "An important ingredient for any sailboat.",
        SEASTACK = "A big lumpy rock.",
        FISHINGNET = "Fresh seafood awaits!", --unimplemented
        ANTCHOVIES = "Mmmm you'd be delectable in a soup!", --unimplemented
        STEERINGWHEEL = "I'll steer us in the right direction!",
        ANCHOR = "Now you stay put!",
        BOATPATCH = "Better safe than sorry, non?",
        DRIFTWOOD_TREE =
        {
            BURNING = "Driftwood en flambé!",
            BURNT = "Charred to a crisp.",
            CHOPPED = "All nicely chopped.",
            GENERIC = "This tree's spent too much time at sea.",
        },

        DRIFTWOOD_LOG = "It's surprisingly light.",

        MOON_TREE =
        {
            BURNING = "It's on fire!",
            BURNT = "Quel dommage.",
            CHOPPED = "Nothing but a stump left.",
            GENERIC = "What a strange looking tree.",
        },
		MOON_TREE_BLOSSOM = "How lovely!",

        MOONBUTTERFLY =
        {
        	GENERIC = "Oh, how lovely!",
        	HELD = "Hello my little friend!",
        },
		MOONBUTTERFLYWINGS = "I can make something tasty with these.",
        MOONBUTTERFLY_SAPLING = "Grow big and strong, little tree!",
        ROCK_AVOCADO_FRUIT = "You can't expect me to eat this!",
        ROCK_AVOCADO_FRUIT_RIPE = "The fruit seems to have softened somewhat.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Cooking really does wonders.",
        ROCK_AVOCADO_FRUIT_SPROUT = "Let's find somewhere to plant this.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It's all out of fruit.",
			WITHERED = "It's withered from the heat.",
			GENERIC = "What a strange looking shrub!",
			PICKED = "I must be patient.",
			DISEASED = "That doesn't look healthy.", --unimplemented
            DISEASING = "I think something's wrong with it.", --unimplemented
			BURNING = "Did I leave the stove on?",
		},
        DEAD_SEA_BONES = "Hmm... that might be good in a soup.",
        HOTSPRING =
        {
        	GENERIC = "Ah, if only I had time for a nice soak.",
        	BOMBED = "What a nice aroma.",
        	GLASS = "It looks quite pretty in the moonlight, non?",
			EMPTY = "An empty basin.",
        },
        MOONGLASS = "My, that's sharp!",
        MOONGLASS_CHARGED = "It's still warm.",
        MOONGLASS_ROCK = "That's quite a bit of glass.",
        BATHBOMB = "A bath would be nice.",
        TRAP_STARFISH =
        {
            GENERIC = "That's an unusual looking starfish.",
            CLOSED = "Don't take a bite out of me!",
        },
        DUG_TRAP_STARFISH = "Ha! I'm nobody's snack!",
        SPIDER_MOON =
        {
        	GENERIC = "That's no ordinary spider.",
        	SLEEPING = "I shouldn't disturb it's nap.",
        	DEAD = "Thank goodness, it's over.",
        },
        MOONSPIDERDEN = "Something is different about that spider den...",
		FRUITDRAGON =
		{
			GENERIC = "Our little friend is not quite ripe.",
			RIPE = "You'd be perfect in a meal!",
			SLEEPING = "Sleep well, you tasty morsel.",
		},
        PUFFIN =
        {
            GENERIC = "Hm, I don't think I've cooked one of those before.",
            HELD = "What a cute little morsel!",
            SLEEPING = "I think it's asleep.",
        },

		MOONGLASSAXE = "This will cut my work time in half!",
		GLASSCUTTER = "Good for slicing and dicing!",

        ICEBERG =
        {
            GENERIC = "Iceberg ahead!", --unimplemented
            MELTED = "Melted like butter!", --unimplemented
        },
        ICEBERG_MELTED = "Melted like butter!", --unimplemented

        MINIFLARE = "I can signal mes amis!",

		MOON_FISSURE =
		{
			GENERIC = "It's giving me goosebumps.",
			NOLIGHT = "It looks like it goes down forever.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Nearly there, mon ami!",
            GENERIC = "You know how to get me home to maman?",
        },

        MOON_ALTAR_IDOL = "Oui, I'll take you back where you belong.",
        MOON_ALTAR_GLASS = "Hm? Where would you like to go, mon ami?",
        MOON_ALTAR_SEED = "Of course I can take you home.",

        MOON_ALTAR_ROCK_IDOL = "There's something inside that wants out.",
        MOON_ALTAR_ROCK_GLASS = "There's something inside that wants out.",
        MOON_ALTAR_ROCK_SEED = "There's something inside that wants out.",

        MOON_ALTAR_CROWN = "Come on mon ami, let's get you back where you belong!",
        MOON_ALTAR_COSMIC = "Something tells me this is part of a bigger recipe...",

        MOON_ALTAR_ASTRAL = "The ingredients are all together.",
        MOON_ALTAR_ICON = "I'll have you home tout de suite!",
        MOON_ALTAR_WARD = "Patience mon ami, you'll be home soon.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "All the knowledge of a seasoned seafarer!",
            BURNT = "It's all gone up in smoke.",
        },
        BOAT_ITEM = "Allons-y out to sea!",
        STEERINGWHEEL_ITEM = "We can't set sail without this.",
        ANCHOR_ITEM = "Looks like a recipe for an anchor.",
        MAST_ITEM = "An important ingredient for any sailboat.",
        MUTATEDHOUND =
        {
        	DEAD = "Au revoir.",
        	GENERIC = "Mon dieu, what happened to it?!",
        	SLEEPING = "I'd... rather not wake it.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "At least it's over now.",
			GENERIC = "What are you?!",
			SLEEPING = "I'll just... leave that be.",
		},
        CARRAT =
        {
        	DEAD = "I wonder what you'd taste like.",
        	GENERIC = "I... think I had a nightmare like this once.",
        	HELD = "Would you be a meat or a vegetable?",
        	SLEEPING = "Bonne nuit.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Salad of the sea!",
            PICKED = "She needs time to regrow, non?",
        },
		BULLKELP_ROOT = "Perhaps it'll grow if I plant it.",
        KELPHAT = "I'd rather have this in a broth than on my head.",
		KELP = "Salad of the sea!",
		KELP_COOKED = "This... could be a bit better.",
		KELP_DRIED = "Ah, crispy!",

		GESTALT = "Can you... get me home to dear Maman?",
        GESTALT_GUARD = "I think it would be wise to stay out of their way.",

		COOKIECUTTER = "Could I interest you in something other than my boat?",
		COOKIECUTTERSHELL = "Reminds me a bit of a durian... mostly the smell.",
		COOKIECUTTERHAT = "Not the best looking hat, but c'est la vie.",
		SALTSTACK =
		{
			GENERIC = "What beautiful formations!",
			MINED_OUT = "Nothing left, I'm afraid.",
			GROWING = "The sea is capable of amazing things.",
		},
		SALTROCK = "Quelle chance! I've found salt!",
		SALTBOX = "Just the thing for preserving ingredients.",

		TACKLESTATION = "I've got bigger fish to fry! And bake, and poach, and...",
		TACKLESKETCH = "Ah, it looks like a recipe for some fishing tackle.",

        MALBATROSS = "Très mal, indeed.",
        MALBATROSS_FEATHER = "\"Alouette, je te plumerai.\"",
        MALBATROSS_BEAK = "I'm sure I could find a use for this.",
        MAST_MALBATROSS_ITEM = "Light as many feathers!",
        MAST_MALBATROSS = "It looks nice, non?",
		MALBATROSS_FEATHERED_WEAVE = "This fabric is light as a feather!",

        GNARWAIL =
        {
            GENERIC = "Mon dieu, don't skewer me!",
            BROKENHORN = "Ha! You've no shish left to kabob with!",
            FOLLOWER = "You're really quite a gentle soul, aren't you mon ami?",
            BROKENHORN_FOLLOWER = "I am very sorry about your horn, mon ami.",
        },
        GNARWAIL_HORN = "I was nearly run through with that thing!",

        WALKINGPLANK = "That doesn't look safe.",
        OAR = "A paddle.",
		OAR_DRIFTWOOD = "A nice, light paddle.",

		OCEANFISHINGROD = "I wonder what deep sea delicacies are waiting for me?",
		OCEANFISHINGBOBBER_NONE = "A float might make fishing easier.",
        OCEANFISHINGBOBBER_BALL = "Simple, pas compliqué, parfait!",
        OCEANFISHINGBOBBER_OVAL = "This world can harden the best of us, mon ami.",
		OCEANFISHINGBOBBER_CROW = "Feathers are surprisingly useful for fishing!",
		OCEANFISHINGBOBBER_ROBIN = "Feathers are surprisingly useful for fishing!",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "Feathers are surprisingly useful for fishing!",
		OCEANFISHINGBOBBER_CANARY = "Feathers are surprisingly useful for fishing!",
		OCEANFISHINGBOBBER_GOOSE = "Fishing can sometimes require a soft touch.",
		OCEANFISHINGBOBBER_MALBATROSS = "Not bad at all!",

		OCEANFISHINGLURE_SPINNER_RED = "Not very appetizing, but fish seem to like it.",
		OCEANFISHINGLURE_SPINNER_GREEN = "Not very appetizing, but fish seem to like it.",
		OCEANFISHINGLURE_SPINNER_BLUE = "Not very appetizing, but fish seem to like it.",
		OCEANFISHINGLURE_SPOON_RED = "Not very appetizing, but smaller fish seem to like it.",
		OCEANFISHINGLURE_SPOON_GREEN = "Not very appetizing, but smaller fish seem to like it.",
		OCEANFISHINGLURE_SPOON_BLUE = "Not very appetizing, but smaller fish seem to like it.",
		OCEANFISHINGLURE_HERMIT_RAIN = "A chef must have fresh ingredients, rain or shine!",
		OCEANFISHINGLURE_HERMIT_SNOW = "A chilly lure, purchased from an icy shopkeep.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "I'd better handle this one carefully.",
		OCEANFISHINGLURE_HERMIT_HEAVY = "A heavy dish for a hefty fish, non?",

		OCEANFISH_SMALL_1 = "This will barely do as an appetizer!",
		OCEANFISH_SMALL_2 = "A tasty little morsel!",
		OCEANFISH_SMALL_3 = "Small, but surely delicious with the right accoutrements!",
		OCEANFISH_SMALL_4 = "I do wish I had bigger fish to fry.",
		OCEANFISH_SMALL_5 = "Has this fish already been cooked?",
		OCEANFISH_SMALL_6 = "The meat has a dry, oddly brittle texture.",
		OCEANFISH_SMALL_7 = "It's almost too pretty to eat... almost.",
		OCEANFISH_SMALL_8 = "Mon dieu! I'll be the one cooked if I stay too close!",
        OCEANFISH_SMALL_9 = "I've never had food spit at me before.",

		OCEANFISH_MEDIUM_1 = "I've worked with worse looking ingredients.",
		OCEANFISH_MEDIUM_2 = "You will make a fine fish dinner!",
		OCEANFISH_MEDIUM_3 = "Hm, I wonder if those spines are poisonous.",
		OCEANFISH_MEDIUM_4 = "Ah yes, with a squeeze of lemon, some pepper...",
		OCEANFISH_MEDIUM_5 = "Ah, some butter, some salt, and you'll be scrumptious!",
		OCEANFISH_MEDIUM_6 = "Its scales have such a lovely sheen.",
		OCEANFISH_MEDIUM_7 = "Its scales have such a lovely sheen.",
		OCEANFISH_MEDIUM_8 = "I prefer to use fresh fish, not frozen...",
        OCEANFISH_MEDIUM_9 = "The meat has a subtle sweetness that makes for some interesting dishes.",

		PONDFISH = "Poisson!",
		PONDEEL = "Anguille.",

        FISHMEAT = "Doesn't even smell fishy it's so fresh!",
        FISHMEAT_COOKED = "Could use a squeeze of lemon...",
        FISHMEAT_SMALL = "I will honor this ingredient.",
        FISHMEAT_SMALL_COOKED = "Could use fresh herbs and butter...",
		SPOILED_FISH = "Such a shame...",

		FISH_BOX = "Is the fish fresh or canned? I feel rather conflicted.",
        POCKET_SCALE = "A simple way to weigh!",

		TACKLECONTAINER = "I like my tackle to be as organized as my kitchen.",
		SUPERTACKLECONTAINER = "C'est super!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "Perhaps I will try my luck?",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nWhat a massive morsel!",
			BURNING = "(Sniff) Is that... fish soup?",
			BURNT = "Ah, quelle dommage...",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nI do have a bit of experience with fishing!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nAh, bon! It seems I've won for now!",
		},

		OCEANFISHABLEFLOTSAM = "Ah, I was hoping for something more delicious.",

		CALIFORNIAROLL = "Classic Japanese fusion!",
		SEAFOODGUMBO = "Incredible! Just like Nana used to make!",
		SURFNTURF = "Mwah! Perfection.",

        WOBSTER_SHELLER = "Enchanté, entrée!",
        WOBSTER_DEN = "Bonjour? Anyone home?",
        WOBSTER_SHELLER_DEAD = "One step closer to my mouth.",
        WOBSTER_SHELLER_DEAD_COOKED = "Could use garlic-butter...",

        LOBSTERBISQUE = "I've truly outdone myself!",
        LOBSTERDINNER = "No place is too remote for some fine dining!",

        WOBSTER_MOONGLASS = "A shame they're not edible...",
        MOONGLASS_WOBSTER_DEN = "Wobster, under glass!",

		TRIDENT = "What dish could accomodate a fork of that size?",

		WINCH =
		{
			GENERIC = "It reminds me a bit of my days on the trawler.",
			RETRIEVING_ITEM = "Ah bon! I've caught something!",
			HOLDING_ITEM = "Just what have I fished from the depths?",
		},

        HERMITHOUSE = {
            GENERIC = "That poor old woman... living here all on her own...",
            BUILTUP = "I hope she's a bit more comfortable in there now.",
        },

        SHELL_CLUSTER = "Perhaps I could break it open?",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "I wonder if there's something delicious inside...",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Do you hear the seashells sing?",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Maman had a lovely seashell collection.",
        },

        CHUM = "I suppose fish don't have an especially sophisticated palate.",

        SUNKENCHEST =
        {
            GENERIC = "I was hoping there would still be a fresh clam inside...",
            LOCKED = "Ah, zut! Locked.",
        },

        HERMIT_BUNDLE = "Not to complain, but I would have preferred a nice edible arrangement.",
        HERMIT_BUNDLE_SHELLS = "A shell stuffed with shells.",

        RESKIN_TOOL = "Ah, this will help freshen up the place, non?",
        MOON_FISSURE_PLUGGED = "I wonder why she's so determined to stay here.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "She is a beast with a gentle soul.",
            "She is a beast with a gentle soul.",
        },
        WOBYSMALL =
        {
            "She's quite good at cleaning up leftovers after a meal.",
            "Oh alright, I'm sure I can find a scrap of meat for you.",
        },
		WALTERHAT = "A tidy little chapeau.",
		SLINGSHOT = "Perhaps we could catch something for dinner with this.",
		SLINGSHOTAMMO_ROCK = "This looks like a key ingredient for a slingshot.",
		SLINGSHOTAMMO_MARBLE = "This looks like a key ingredient for a slingshot.",
		SLINGSHOTAMMO_THULECITE = "This looks like a key ingredient for a slingshot.",
        SLINGSHOTAMMO_GOLD = "This looks like a key ingredient for a slingshot.",
        SLINGSHOTAMMO_SLOW = "This looks like a key ingredient for a slingshot.",
        SLINGSHOTAMMO_FREEZE = "This looks like a key ingredient for a slingshot.",
		SLINGSHOTAMMO_POOP = "I suppose we must make do with what we have.",
        PORTABLETENT = "It looks very cozy.",
        PORTABLETENT_ITEM = "All rolled up like a crepe.",

        -- Wigfrid
        BATTLESONG_DURABILITY = "I didn't know she was such an accomplished singer!",
        BATTLESONG_HEALTHGAIN = "I didn't know she was such an accomplished singer!",
        BATTLESONG_SANITYGAIN = "I didn't know she was such an accomplished singer!",
        BATTLESONG_SANITYAURA = "I didn't know she was such an accomplished singer!",
        BATTLESONG_FIRERESISTANCE = "I didn't know she was such an accomplished singer!",
        BATTLESONG_INSTANT_TAUNT = "Shakespeare? I wonder how a Viking came upon this...",
        BATTLESONG_INSTANT_PANIC = "Shakespeare? I wonder how a Viking came upon this...",

        -- Webber
        MUTATOR_WARRIOR = "Next time, let's bake something together, non?",
        MUTATOR_DROPPER = "Oh my...",
        MUTATOR_HIDER = "Next time, let's bake something together, non?",
        MUTATOR_SPITTER = "Oh my...",
        MUTATOR_MOON = "Next time, let's bake something together, non?",
        MUTATOR_HEALER = "Oh my...",
        SPIDER_WHISTLE = "Oh dear, it's quite sticky.",
        SPIDERDEN_BEDAZZLER = "It's nice to see the petit monsieur expressing his creativity!",
        SPIDER_HEALER = "I suppose it's good to have a healthier alternative.",
        SPIDER_REPELLENT = "Unfortunately, it seems only spiders can shoo other spiders.",
        SPIDER_HEALER_ITEM = "It only appeals to a very specific palate.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "I'm not sure about some of those ingredients, mademoiselle.",
		GHOSTLYELIXIR_FASTREGEN = "I'm not sure about some of those ingredients, mademoiselle.",
		GHOSTLYELIXIR_SHIELD = "I'm not sure about some of those ingredients, mademoiselle.",
		GHOSTLYELIXIR_ATTACK = "I'm not sure about some of those ingredients, mademoiselle.",
		GHOSTLYELIXIR_SPEED = "I'm not sure about some of those ingredients, mademoiselle.",
		GHOSTLYELIXIR_RETALIATION = "I'm not sure about some of those ingredients, mademoiselle.",
		SISTURN =
		{
			GENERIC = "Poor mademoiselle...",
			SOME_FLOWERS = "Oh, that's looking very nice!",
			LOTS_OF_FLOWERS = "Such a calming presence...",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "What new culinary adventures shall we undertake, old friend?",
            DONE = "Pickup! Oh, old habits...",

			COOKING_LONG = "The flavors need time to meld.",
			COOKING_SHORT = "I threw that meal together!",
			EMPTY = "I would never leave home without it!",
        },

        PORTABLEBLENDER_ITEM = "It has greatly improved my culinary adventures.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Fresh spices! Oh, how I have missed you!",
            DONE = "Pickup! Oh, old habits...",
        },
        SPICEPACK = "My bag of chef's tricks!",
        SPICE_GARLIC = "Without garlic powder, life is not worth living.",
        SPICE_SUGAR = "The original all natural sweetener.",
        SPICE_CHILI = "My own special recipe.",
        SPICE_SALT = "Salt, at last! I could weep!",
        MONSTERTARTARE = "This is a culinary abomination. I'm appalled.",
        FRESHFRUITCREPES = "Is this not a thing of beauty?",
        FROGFISHBOWL = "I think I've outdone myself, given the available ingredients.",
        POTATOTORNADO = "Junk food can be as enjoyable as anything gourmet.",
        DRAGONCHILISALAD = "A hint of spice to awaken the tastebuds.",
        GLOWBERRYMOUSSE = "My own special recipe!",
        VOLTGOATJELLY = "I ground the horns up myself.",
        NIGHTMAREPIE = "It's really not as scary as it sounds.",
        BONESOUP = "Bone appétit!",
        MASHEDPOTATOES = "The secret is to use a whole stick of butter.",
        POTATOSOUFFLE = "It came out just right.",
        MOQUECA = "I'm quite proud of how it turned out.",
        GAZPACHO = "Ah. Perfect on a hot day.",
        ASPARAGUSSOUP = "Ah, a special dish.",
        VEGSTINGER = "Add a little spice.",
        BANANAPOP = "Perhaps not my most complicated dish, but no less tasty.",
        CEVICHE = "Truly what I live for!",
        SALSA = "I like to spice things up!",
        PEPPERPOPPER = "I like to make my dishes pop!",

        TURNIP = "Root vegetables are at the root of all good meals.",
        TURNIP_COOKED = "It will do in a pinch, but I can do better.",
        TURNIP_SEEDS = "What fresh ingredients will grow from these?",

        GARLIC = "Ah! The smell of fresh garlic!",
        GARLIC_COOKED = "What can I add this to?",
        GARLIC_SEEDS = "What fresh ingredients will grow from these?",

        ONION = "Boasts as many uses as it has layers.",
        ONION_COOKED = "I would prefer to put this to better use.",
        ONION_SEEDS = "What fresh ingredients will grow from these?",

        POTATO = "Ah, the mighty potato!",
        POTATO_COOKED = "Golden brown. Simplicity at its finest.",
        POTATO_SEEDS = "What fresh ingredients will grow from these?",

        TOMATO = "Mmm... I can smell the sauces already.",
        TOMATO_COOKED = "A nice light snack.",
        TOMATO_SEEDS = "What fresh ingredients will grow from these?",

        ASPARAGUS = "Sparrow grass!",
        ASPARAGUS_COOKED = "Roasted asparagus. What a treat!",
        ASPARAGUS_SEEDS = "These will grow some nice fresh vegetables.",

        PEPPER = "Finally, I can make my famous hot sauce!",
        PEPPER_COOKED = "The roasting really brings out the flavors.",
        PEPPER_SEEDS = "What fresh ingredients will grow from this?",

        WEREITEM_BEAVER = "You're mastering this curse business, mon ami!",
        WEREITEM_GOOSE = "Well... that certainly is... something.",
        WEREITEM_MOOSE = "Excusez-moi, but why does this smell like meat?",

        MERMHAT = "Mon dieu, must I dress as a frog?",
        MERMTHRONE =
        {
            GENERIC = "Très royal!",
            BURNT = "The throne has been charbroiled!",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "You have all the ingredients you need?",
            BURNT = "It's been burnt to a crisp!",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Oh! It looks... very nice!",
            BURNT = "Quel dommage, she worked so hard on it...",
        },

        MERMWATCHTOWER_REGULAR = "At least they seem friendly!",
        MERMWATCHTOWER_NOKING = "They don't look so friendly now...",
        MERMKING = "A real frog prince!",
        MERMGUARD = "A most fearsome fishmonger!",
        MERM_PRINCE = "Hm... he doesn't seem so different from the others.",

        SQUID = "Incandescent calamari!",

		GHOSTFLOWER = "Looking at it makes me feel... peaceful.",
        SMALLGHOST = "Oh! You gave me a little fright!",

        CRABKING =
        {
            GENERIC = "Oh, the dishes I could make with that much crab meat...",
            INERT = "It seems to be missing a few shiny ingredients.",
        },
		CRABKING_CLAW = "I had a nightmare like this back in culinary school.",

		MESSAGEBOTTLE = "I do hope that's a recipe inside!",
		MESSAGEBOTTLEEMPTY = "There's nothing sadder than a jam-less jam jar.",

        MEATRACK_HERMIT =
        {
            DONE = "Your jerky is served!!",
            DRYING = "Not quite dry enough.",
            DRYINGINRAIN = "Now it is more like a rehydrating rack...",
            GENERIC = "It looks so bare... perhaps I could put some meat on it.",
            BURNT = "Too dry! Too dry!",
            DONE_NOTMEAT = "Et voila! It is done!",
            DRYING_NOTMEAT = "Not quite ready yet.",
            DRYINGINRAIN_NOTMEAT = "Now we're just watering it.",
        },
        BEEBOX_HERMIT =
        {
            READY = "Madame, I believe your honey is ready!",
            FULLHONEY = "Madame, I believe your honey is ready!",
            GENERIC = "It's a little hive of honeymakers!",
            NOHONEY = "No more honey...",
            SOMEHONEY = "There is a little honey.",
            BURNT = "Disastrously caramelized.",
        },

        HERMITCRAB = "She's all alone...",

        HERMIT_PEARL = "Madame Pearl entrusted it to me.",
        HERMIT_CRACKED_PEARL = "Oh... oh dear...",

        -- DSEAS
        WATERPLANT = "Oh my! It's lovely!",
        WATERPLANT_BOMB = "Pardonnez-moi! I didn't realize those barnacles were yours!",
        WATERPLANT_BABY = "It's growing nicely.",
        WATERPLANT_PLANTER = "Where shall I start planting my sea garden?",

        SHARK = "I'm sure you can find something much tastier to eat elsewhere!",

        MASTUPGRADE_LAMP_ITEM = "It does lighten the mood considerably.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "It will be sizzling with electricity in no time.",

        WATERPUMP = "Fires on a ship are not to be taken lightly.",

        BARNACLE = "Ah, I've rarely had an opportunity to cook with these!",
        BARNACLE_COOKED = "I think we can do a bit better than that!",

        BARNACLEPITA = "An unconventional combination of ingredients, but delicious nonetheless!",
        BARNACLESUSHI = "Ah, bon! That turned out quite nicely!",
        BARNACLINGUINE = "Delectable!",
        BARNACLESTUFFEDFISHHEAD = "Some culinary experiments go better than others.",

        LEAFLOAF = "A basic recipe, elevated through the use of this strange meat!",
        LEAFYMEATBURGER = "Perhaps this is how we'll convince Mademoiselle Wigfrid to eat her vegetables?",
        LEAFYMEATSOUFFLE = "It is certainly... food.",
        MEATYSALAD = "I'm not sure whether we can truly call this vegetarian.",

        -- GROTTO

		MOLEBAT = "I've never seen a creature that inhales its food so... literally.",
        MOLEBATHILL = "Mon dieu, to think it can sleep in that mess!",

        BATNOSE = "This will be a challenging ingredient.",
        BATNOSE_COOKED = "It could use some marinade, perhaps.",
        BATNOSEHAT = "Quelle horreur! What a waste of good food!",

        MUSHGNOME = "I can't help but wonder how it tastes.",

        SPORE_MOON = "Keep those away from my soufflés!",

        MOON_CAP = "It would add a lovely pop of color... perhaps to a pasta dish.",
        MOON_CAP_COOKED = "Hm. It has quite the... interesting aroma.",

        MUSHTREE_MOON = "How lovely!",

        LIGHTFLIER = "Light the way, mon ami!",

        GROTTO_POOL_BIG = "My, how beautiful!",
        GROTTO_POOL_SMALL = "My, how beautiful!",

        DUSTMOTH = "It seems like a gentle soul.",

        DUSTMOTHDEN = "Quelle surprise! It's so clean you could eat off it!",

        ARCHIVE_LOCKBOX = "Perhaps it contains an ancient recipe of some kind.",
        ARCHIVE_CENTIPEDE = "Excusez-moi, sorry to disturb you!",
        ARCHIVE_CENTIPEDE_HUSK = "Hm, it seems to be missing a key ingredient.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "A masterpiece takes time.",
            COOKING_SHORT = "Nearly there...",
            DONE = "Ahh, fini!",
            EMPTY = "The ones who lived here had good taste in cookware.",
            BURNT = "Tragique.",
        },

        ARCHIVE_MOON_STATUE = "They seemed to think quite highly of the moon.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "I'm afraid its meaning is lost on me.",
            LINE_2 = "So many secrets lost to time.",
            LINE_3 = "I'm afraid its meaning is lost on me.",
            LINE_4 = "So many secrets lost to time.",
            LINE_5 = "I'm afraid its meaning is lost on me.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "Let's see where this takes us, non?",
            IDLE = "C'est fini.",
        },

        ARCHIVE_RESONATOR_ITEM = "I cooked it up with a dash of ancient knowledge.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "This looks like it hasn't been used in a long time.",
          GENERIC =  "I wonder what this machine will cook up for us.",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "It's quiet.",
            GENERIC = "How strange!",
        },

        ARCHIVE_SECURITY_PULSE = "C'est beau! I wonder where it's going?",

        ARCHIVE_SWITCH = {
            VALID = "The gems seem to be important.",
            GEMS = "It's missing a key ingredient.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Could this be a way home?",
            GENERIC = "Ah, I shouldn't have gotten my hopes up.",
        },

        WALL_STONE_2 = "Good stone work.",
        WALL_RUINS_2 = "Look at the carvings...",

        REFINED_DUST = "A most unusual ingredient.",
        DUSTMERINGUE = "I'm afraid even I can't make dust palatable.",

        SHROOMCAKE = "It certainly has a unique flavor profile.",

        NIGHTMAREGROWTH = "Mon dieu, the crust is cracking!",

        TURFCRAFTINGSTATION = "This recipe calls for some ground ingredients, non?",

        MOON_ALTAR_LINK = "It needs just a bit more time in the oven.",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "A good place for food scraps.",
            WET = "Too runny, it needs less moisture.",
            DRY = "Non, far too dry!",
            BALANCED = "Tres bon!",
            BURNT = "Burnt to a crisp.",
        },
        COMPOST = "The garden needs to be fed too, and proper plating is important!",
        SOIL_AMENDER =
		{
			GENERIC = "Now to let the ingredients marinade.",
			STALE = "It needs a bit more time to stew.",
			SPOILED = "It's not my idea of a fine meal, but the plants will love it.",
		},

		SOIL_AMENDER_FERMENTED = "Ah, c'est fini!",

        WATERINGCAN =
        {
            GENERIC = "Perhaps the garden might like a little drink, non?",
            EMPTY = "Perhaps there's a lake nearby...",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "To make the finest ingredients, our plants need the finest care.",
            EMPTY = "It's completely empty, I'm afraid.",
        },

		FARM_PLOW = "What a handy machine!",
		FARM_PLOW_ITEM = "Now, where to start the garden...",
		FARM_HOE = "I'd better get planting if I want some fresh ingredients.",
		GOLDEN_FARM_HOE = "Good tools do make a difference.",
		NUTRIENTSGOGGLESHAT = "I'd best ensure our plants are well fed with the proper nutrients!",
		PLANTREGISTRYHAT = "It never hurts to learn more about what goes into your food.",

        FARM_SOIL_DEBRIS = "There's a bit of unwanted garnish in my garden.",

		FIRENETTLES = "What a bother.",
		FORGETMELOTS = "Hm, I don't recall ever seeing a flower like that before.",
		SWEETTEA = "Ah... je me sens relaxé.",
		TILLWEED = "I'm afraid you're bothering the other plants, mon ami.",
		TILLWEEDSALVE = "Those weeds turned out to be a useful ingredient after all.",
        WEED_IVY = "What are you doing in my lovely garden?",
        IVY_SNARE = "It's trying to get between me and my ingredients!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Ah, a handy kitchen scale!",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nTres bien!",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nIncroyable!",
            HAS_ITEM_LIGHT = "It may not be substantial in size, but I'm sure it's still substantial in flavor!",
			BURNING = "That is not the way to cook en flambé!",
			BURNT = "Far too charred to eat.",
        },

        CARROT_OVERSIZED = "How many different ways could I prepare carrots of this size...",
        CORN_OVERSIZED = "Let's see, what shall I make with you? Corn gratin? Maque choux?",
        PUMPKIN_OVERSIZED = "You would make for a lovely pie.",
        EGGPLANT_OVERSIZED = "Now the question is, do I bake you or fry you?",
        DURIAN_OVERSIZED = "Oh, that's... quite a lot of durian.",
        POMEGRANATE_OVERSIZED = "I could make a fine dessert with you!",
        DRAGONFRUIT_OVERSIZED = "Delicious fresh fruit! What shall I make with you?",
        WATERMELON_OVERSIZED = "I'm sure I can find a use for all this watermelon.",
        TOMATO_OVERSIZED = "What a formidable tomato!",
        POTATO_OVERSIZED = "Ah, you can never go wrong with a potato!",
        ASPARAGUS_OVERSIZED = "Tres bon! You will make a lovely dish!",
        ONION_OVERSIZED = "You can never have enough onion.",
        GARLIC_OVERSIZED = "So much garlic! My chef's heart weeps with joy!",
        PEPPER_OVERSIZED = "What an impressive pepper!",

        VEGGIE_OVERSIZED_ROTTEN = "Non! What a terrible waste!",

		FARM_PLANT =
		{
			GENERIC = "My garden.",
			SEED = "All good things come with time.",
			GROWING = "The garden is coming along nicely.",
			FULL = "Ready for cooking!",
			ROTTEN = "How very sad.",
			FULL_OVERSIZED = "Mon dieu, it's enormous!",
			ROTTEN_OVERSIZED = "Non! What a terrible waste!",
			FULL_WEED = "It seems my garden is full of weeds!",

			BURNING = "It's too soon to start cooking!",
		},

        FRUITFLY = "Non! Out of my garden!",
        LORDFRUITFLY = "Mon dieu! It's killing the plants!",
        FRIENDLYFRUITFLY = "This one seems to be friendly.",
        FRUITFLYFRUIT = "They seem quite taken with whoever holds this.",

        SEEDPOUCH = "A little organization never hurts.",

		-- Crow Carnival
		CARNIVAL_HOST = "He's a bit odd, but so is everything around here, non?",
		CARNIVAL_CROWKID = "Bonjour! And who might you be, little one?",
		CARNIVAL_GAMETOKEN = "A token for le carnaval!",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "One lonely ticket.",
			GENERIC_SMALLSTACK = "Quite a few tickets.",
			GENERIC_LARGESTACK = "Mon dieu, a mountain of tickets!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "A door, tres petite.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "I should feed it something shiny.",
			PLAYING = "Quite the demanding group of diners.",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Birds certainly have unique tastes.",

		CARNIVALGAME_MEMORY_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "I should feed it something shiny.",
			PLAYING = "Sometimes you must crack some eggs to get an omelette, non?",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "A door, tres petite.",
			PLAYING = "Perhaps this is the right one?",
		},

		CARNIVALGAME_HERDING_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "I should feed it something shiny.",
			PLAYING = "Scrambled eggs are another specialty of mine.",
		},
		CARNIVALGAME_HERDING_CHICK = "Over here, s'il vous plait!",

		CARNIVAL_PRIZEBOOTH_KIT = "All the ingredients are together, now let's get cooking!",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "They have quite a menu of prizes to choose from!",
		},

		CARNIVALCANNON_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALCANNON =
		{
			GENERIC = "None of the ships I worked on had cannons.",
			COOLDOWN = "Bravo!",
		},

		CARNIVAL_PLAZA_KIT = "This tree has a certain je ne sais quoi.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Hm, it's looking a bit bland around here.",
			LEVEL_2 = "Having more decorations around would certainly give it some zest!",
			LEVEL_3 = "Magnifique!",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALDECOR_EGGRIDE = "Hm... I should cook some eggs for breakfast.",

		CARNIVALDECOR_LAMP_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALDECOR_LAMP = "How pleasant!",
		CARNIVALDECOR_PLANT_KIT = "I'll have it whipped up in no time at all.",
		CARNIVALDECOR_PLANT = "Perhaps it will attract normal sized crows?",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "A fine piece, extra rare.",
			UNCOMMON = "This one's medium rare.",
			GENERIC = "What a charming figurine.",
		},
		CARNIVALDECOR_FIGURE_KIT = "I wonder what could be inside?",

        CARNIVAL_BALL = "Perhaps I'll toss it around with the children.", --unimplemented
		CARNIVAL_SEEDPACKET = "They could use a bit of seasoning.",
		CARNIVALFOOD_CORNTEA = "It really shouldn't work, yet somehow it does...",

        CARNIVAL_VEST_A = "Ah, I remember this style being quite popular in Paris.",
        CARNIVAL_VEST_B = "It provides a nice bit of shade.",
        CARNIVAL_VEST_C = "When at a crow carnival, dress like the crows do, non?",

        -- YOTB
        YOTB_SEWINGMACHINE = "Now to find the recipe for a tasteful outfit.",
        YOTB_SEWINGMACHINE_ITEM = "I'd better put it together.",
        YOTB_STAGE = "Ah mes amis, I've been judged by top chefs - this is nothing!",
        YOTB_POST =  "A stake to display my prized steak, non?",
        YOTB_STAGE_ITEM = "I should be able to put that together.",
        YOTB_POST_ITEM =  "This looks like a good spot, non?",


        YOTB_PATTERN_FRAGMENT_1 = "One part of a recipe for a beefalo costume.",
        YOTB_PATTERN_FRAGMENT_2 = "One part of a recipe for a beefalo costume.",
        YOTB_PATTERN_FRAGMENT_3 = "One part of a recipe for a beefalo costume.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "Tres mignon!",
            YOTB = "Perhaps I should show it to the judge, to get a measure of his taste.",
        },

        WAR_BLUEPRINT = "Dressing for some rather tough beef!",
        DOLL_BLUEPRINT = "Tres mignon!",
        FESTIVE_BLUEPRINT = "Just the right thing for a celebration.",
        ROBOT_BLUEPRINT = "This does not look like any sewing pattern I've ever seen.",
        NATURE_BLUEPRINT = "Made from natural ingredients.",
        FORMAL_BLUEPRINT = "The beast will look as if it's going out to a fancy dinner party.",
        VICTORIAN_BLUEPRINT = "It's hard not to think about seafood with all these scalloped edges.",
        ICE_BLUEPRINT = "Frozen beef? I suppose I'll have to make do.",
        BEAST_BLUEPRINT = "The beefalo who will wear this is lucky indeed!",

        BEEF_BELL = "It is not a dinner bell?",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "Bonjour! Is anyone home?",
            BURNT = "Burnt to a crisp.",
			PLAYING_HIDEANDSEEK = "I don't think they're hiding in there.",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "My time is almost up, where could they be?",
		},

		KITCOONDEN_KIT = "I'll whip it together tout de suite.",

		TICOON = 
		{
			GENERIC = "He looks very well fed.",
			ABANDONED = "Perhaps we'll try again later, non?",
			SUCCESS = "Ah, he found something!",
			LOST_TRACK = "What's wrong, monsieur? Did you lose the scent?",
			NEARBY = "Hmm, I wonder if there's one nearby?",
			TRACKING = "Something has caught his attention.",
			TRACKING_NOT_MINE = "Oh excusez-moi, I didn't know you were preoccupied!",
			NOTHING_TO_TRACK = "Perhaps there's nothing left to find.",
			TARGET_TOO_FAR_AWAY = "Maybe we should try elsewhere, non?",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "What should we cook up together?",
            EMPTY = "I should give it a little gift.",
            BURNT = "Flame broiled.",
        },

		KITCOON_FOREST = "Bonjour petit chat!",
		KITCOON_SAVANNA = "Bonjour petit chat!",
		KITCOON_MARSH = "Bonjour petit chat!",
		KITCOON_DECIDUOUS = "Bonjour petit chat!",
		KITCOON_GRASS = "You're so sweet, I could just eat you up!",
		KITCOON_ROCKY = "You're so sweet, I could just eat you up!",
		KITCOON_DESERT = "You're so sweet, I could just eat you up!",
		KITCOON_MOON = "You're so sweet, I could just eat you up!",
		KITCOON_YOT = "You're so sweet, I could just eat you up!",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "It looks rather irritated...",
            DEAD = "Au revoir.",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "Mon dieu, a second course!",
            DEAD = "At last, it's finished. Or is it...",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "I will not be skewered by the likes of you!",
        ALTERGUARDIAN_PHASE3 = "I'd rather not be fried by that fiery gaze!",
        ALTERGUARDIAN_PHASE3TRAP = "Best to keep far away from those, non?",
        ALTERGUARDIAN_PHASE3DEADORB = "Is there more yet in store for us?",
        ALTERGUARDIAN_PHASE3DEAD = "Finalement, it's over.",

        ALTERGUARDIANHAT = "It makes me hear such sweet whispers...",
        ALTERGUARDIANHATSHARD = "It's been broken down to its basic ingredients.",

        MOONSTORM_GLASS = {
            GENERIC = "En glace.",
            INFUSED = "Freshly made."
        },

        MOONSTORM_STATIC = "That seems to be a key ingredient for whatever he's working on.",
        MOONSTORM_STATIC_ITEM = "What will we be cooking up with this, I wonder?",
        MOONSTORM_SPARK = "It definitely has a kick to it.",

        BIRD_MUTANT = "That bird is looking a bit odd.",
        BIRD_MUTANT_SPITTER = "Something is definitely amiss here.",

        WAGSTAFF_NPC = "Bonjour! Are you in need of assistance?",
        ALTERGUARDIAN_CONTAINED = "It's gobbling up all the energy!",

        WAGSTAFF_TOOL_1 = "This must be what I'm looking for!",
        WAGSTAFF_TOOL_2 = "Surely this must be the tool he wants?",
        WAGSTAFF_TOOL_3 = "That certainly looks like a scientific tool of some sort!",
        WAGSTAFF_TOOL_4 = "Perhaps that is what he is looking for?",
        WAGSTAFF_TOOL_5 = "It's a tool of some sort, hopefully the one I'm looking for.",

        MOONSTORM_GOGGLESHAT = "Mon dieu, I can think of much better uses for a potato.",

        MOON_DEVICE = {
            GENERIC = "Ah, some kind of light fixture perhaps?",
            CONSTRUCTION1 = "Some kind of platter for the ground?",
            CONSTRUCTION2 = "Only a few more ingredients left.",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Maybe I could ask her to make me a kitchen timer...",
			RECHARGING = "I don't think it's ready just yet.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Maybe I could ask her to make me a kitchen timer...",
			RECHARGING = "I don't think it's ready just yet.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Maybe I could ask her to make me a kitchen timer...",
			RECHARGING = "I don't think it's ready just yet.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Maybe I could ask her to make me a kitchen timer...",
			RECHARGING = "I don't think it's ready just yet.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Maybe I could ask her to make me a kitchen timer...",
			RECHARGING = "I don't think it's ready just yet.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "I'm starting to think Mme. Wanda has a bit of pent up aggression...",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "This is what goes into the watches, non?",
        POCKETWATCH_DISMANTLER = "Oh, Mme. Wanda left her tools!",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Must I... really go in?",
			DIFFERENTSHARD = "Must I... really go in?",
		},
        POCKETWATCH_PORTAL_EXIT = "I wonder who might be coming through?",

        -- Waterlog
        WATERTREE_PILLAR = "Une grande surprise!",
        OCEANTREE = "To think they could grow this far out to sea!",
        OCEANTREENUT = "I don't think that will fit in my pocket...",
        WATERTREE_ROOT = "A lonely tree root.",

        OCEANTREE_PILLAR = "A large souvenir from our travels at sea.",
        
        OCEANVINE = "Sigh. Another grapeless vine.",
        FIG = "You would be delicious in a tart.",
        FIG_COOKED = "It could use a bit of honey, perhaps some cinnamon and nutmeg...",

        SPIDER_WATER = "Mon dieu, these spiders have gotten their sea legs!",
        MUTATOR_WATER = "Next time, let's bake something together, non?",
        OCEANVINE_COCOON = "Perhaps I'll just leave that be.",
        OCEANVINE_COCOON_BURNT = "Burnt to a crisp.",

        GRASSGATOR = "He seems to be a gentle soul.",

        TREEGROWTHSOLUTION = "A growing tree should eat well!",

        FIGATONI = "I've never had pasta so decadent!",
        FIGKABAB = "Something about being on a stick brings out more of the flavor.",
        KOALEFIG_TRUNK = "I might have overdone it with the figs.",
        FROGNEWTON = "A lesser known French recipe.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "Is that broccoli growing inside? Non, it's a tiny tree!",
            CRIMSON = "That petit tree doesn't look well at all.",
            ENABLED = "What a lovely and fearsome light!",
			WAITING_FOR_DARK = "I feel as though it's cooking up something...",
			COOLDOWN = "For now, all seems well.",
			SPAWN_DISABLED = "I think I'll sleep a bit better now.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "I think perhaps I'll stick to cooking.",
            BURNT = "I think he might have overdone it.",
        },

        DUMBBELL = "All of my arm strength comes from whisking egg whites.",
        DUMBBELL_GOLDEN = "All of my arm strength comes from whisking egg whites.",
		DUMBBELL_MARBLE = "All of my arm strength comes from whisking egg whites.",
        DUMBBELL_GEM = "All of my arm strength comes from whisking egg whites.",
        POTATOSACK = "I suppose all that lifting works up quite an appetite.",


        TERRARIUMCHEST = 
		{
			GENERIC = "It doesn't look quite so strange now, non?",
			BURNT = "C'est fini.",
			SHIMMER = "Mon dieu, I think my eyes are playing tricks on me...",
		},

		EYEMASKHAT = "I must remember to avoid cutting onions while wearing this.",

        EYEOFTERROR = "That eye has a hungry look to it...",
        EYEOFTERROR_MINI = "I'm sure there are tastier things to eat than me!",
        EYEOFTERROR_MINI_GROUNDED = "Don't make me scramble you!",

        FROZENBANANADAIQUIRI = "There's no better refreshment!",
        BUNNYSTEW = "Ah, lapin a la cocotte. A classic.",
        MILKYWHITES = "Though it doesn't look too appealing now, it may be a useful substitute for other ingredients.",

        CRITTER_EYEOFTERROR = "Would you like me to make you some bacon and eggs?",

        SHIELDOFTERROR ="Mon dieu, it seems I have another mouth to feed...",
        TWINOFTERROR1 = "I promise, I'm not as delicious as I appear!",
        TWINOFTERROR2 = "I promise, I'm not as delicious as I appear!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "I'm afraid I don't have any clockwork cheese.",
        KITCOON_NAMETAG = "What shall I call you, mes petits chats?",

		KITCOONDECOR1 =
        {
            GENERIC = "A plaything for les petits chats.",
            BURNT = "Mon dieu, I knew I smelled something burning!",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "They must work up quite an appetite playing all day.",
            BURNT = "Ah. I don't think that was meant to be cooked.",
        },

		KITCOONDECOR1_KIT = "Nearly done.",
		KITCOONDECOR2_KIT = "Now, to put the ingredients together.",

        -- WX78
        WX78MODULE_MAXHEALTH = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MAXSANITY1 = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MAXSANITY = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MOVESPEED = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MOVESPEED2 = "They give our metal friend a little extra zest, non?",
        WX78MODULE_HEAT = "They give our metal friend a little extra zest, non?",
        WX78MODULE_NIGHTVISION = "They give our metal friend a little extra zest, non?",
        WX78MODULE_COLD = "They give our metal friend a little extra zest, non?",
        WX78MODULE_TASER = "They give our metal friend a little extra zest, non?",
        WX78MODULE_LIGHT = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MAXHUNGER1 = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MAXHUNGER = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MUSIC = "They give our metal friend a little extra zest, non?",
        WX78MODULE_BEE = "They give our metal friend a little extra zest, non?",
        WX78MODULE_MAXHEALTH2 = "They give our metal friend a little extra zest, non?",

        WX78_SCANNER = 
        {
            GENERIC ="It seems vaguely potato shaped... or perhaps I'm just hungry.",
            HUNTING = "It seems vaguely potato shaped... or perhaps I'm just hungry.",
            SCANNING = "It seems vaguely potato shaped... or perhaps I'm just hungry.",
        },

        WX78_SCANNER_ITEM = "It seems vaguely potato shaped... or perhaps I'm just hungry.",
        WX78_SCANNER_SUCCEEDED = "Voilà, it is done!",

        WX78_MODULEREMOVER = "Ah, I believe this utensil belongs to our metal friend.",

        SCANDATA = "What is this they're cooking up?",
    },

    DESCRIBE_GENERIC = "It is what it is...",
    DESCRIBE_TOODARK = "I cannot see a thing!",
    DESCRIBE_SMOLDERING = "I fear that that is about to cook itself.",

    DESCRIBE_PLANTHAPPY = "The picture of health.",
    DESCRIBE_PLANTVERYSTRESSED = "This is a very troubled plant.",
    DESCRIBE_PLANTSTRESSED = "Something's troubling it.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Perhaps it's time I did some weeding.",
    DESCRIBE_PLANTSTRESSORFAMILY = "I think it needs some company.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "The garden's a bit crowded, non?",
    DESCRIBE_PLANTSTRESSORSEASON = "Hm... this one might not be in season.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Would you care for a drink of water?",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Some fresh nutrients might be just the thing to perk it up.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "It's hungry for some good conversation.",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Fresh! Err... perhaps too fresh.",
		WINTERSFEASTFUEL = "Do I taste a hint of cinnamon?",
    },
}
