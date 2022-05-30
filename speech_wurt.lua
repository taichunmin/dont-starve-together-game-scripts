--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Glurph. He too busy.",
        },
        REPAIR =
        {
            WRONGPIECE = "That look wrong, glorp.",
        },
        BUILD =
        {
            MOUNTED = "Grrr, can't reach!",
            HASPET = "Don't need 'nother pet, glort.",
			TICOON = "Huh? You not right one!",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Me not crazy, florp.",
			GENERIC = "Nope.",
			NOBITS = "No fluffs left to take.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "Would probably get in trouble...",
		},
		STORE =
		{
			GENERIC = "It full.",
			NOTALLOWED = "Can't, glorp.",
			INUSE = "Gotta wait.",
            NOTMASTERCHEF = "Fancy cooking man can do it, florpt.",
		},
        CONSTRUCT =
        {
            INUSE = "Grrr, have to wait.",
            NOTALLOWED = "Nuh-uh.",
            EMPTY = "Need some buildy things.",
            MISMATCH = "Glort? Not right?",
        },
		RUMMAGE =
		{
			GENERIC = "Nuh-uh.",
			INUSE = "You find something good?",
            NOTMASTERCHEF = "Fancy cooking man can do it, florpt.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Grrr, key not work!",
        	KLAUS = "Not good time, florp!",
			QUAGMIRE_WRONGKEY = "Grrr, key not work!",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Grrr... want in!",
            HOSTBUSY = "Hey! Trying to talk to you!",
            CARNIVAL_HOST_HERE = "Fancy Birdfolk over here!",
            NOCARNIVAL = "Huh? Where the Birdfolk go?",
			EMPTY_CATCOONDEN = "Glargh... no stuff in there, where they hide it?!",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "Need more scratchy fluffies to play!",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "Hmm, no good hidey spots here.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "Glurgh. Bored of this game.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "Fancy cooking man can do it, florpt.",
			SHADOWMAGIC = "...Don't like stories in that book.",
		},
        COOK =
        {
            GENERIC = "Don't wanna, glort.",
            INUSE = "Mmm... what that smell?",
            TOOFAR = "It way over there!",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Can't start yet! Need veggie rats!",
        },

		DISMANTLE =
		{
			COOKING = "Wait, it making food!",
			INUSE = "Gotta wait.",
			NOTEMPTY = "Too much stuff inside, florp.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Come closer, fishes! Won't hurt you!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Don't need this one for pond, flort.",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "Nuh-uh.",
            DEAD = "They don't need it, flort.",
            SLEEPING = "Wake up! Have present for you!",
            BUSY = "Flurmph, too busy to take present?",
            ABIGAILHEART = "Aw... sorry Abby-gill.",
            GHOSTHEART = "Errmmm... don't think so, florp.",
            NOTGEM = "Don't fit.",
            WRONGGEM = "Glorp? This not right gem.",
            NOTSTAFF = "Don't look right.",
            MUSHROOMFARM_NEEDSSHROOM = "Need to find mushroom!",
            MUSHROOMFARM_NEEDSLOG = "Oooh, need creepy log for this.",
            MUSHROOMFARM_NOMOONALLOWED = "Why mushrooms not grow?",
            SLOTFULL = "It already full.",
            FOODFULL = "Something cooking already.",
            NOTDISH = "Blegh!!",
            DUPLICATE = "Oh! Knew that one already!",
            NOTSCULPTABLE = "Can't shape that!",
            NOTATRIUMKEY = "Don't look right.",
            CANTSHADOWREVIVE = "Don't work.",
            WRONGSHADOWFORM = "That not look right...",
            NOMOON = "Not gonna work, need moon power.",
			PIGKINGGAME_MESSY = "Fluuurph... need to clean first...",
			PIGKINGGAME_DANGER = "Florp! No time for game!",
			PIGKINGGAME_TOOLATE = "Aw... too late.",
			CARNIVALGAME_INVALID_ITEM = "It not want that.",
			CARNIVALGAME_ALREADY_PLAYING = "Me next, me next!",
            SPIDERNOHAT = "Spiderfolk no need hat in there.",
            TERRARIUM_REFUSE = "Glurph. Gotta try something else.",
            TERRARIUM_COOLDOWN = "There no tree inside for giving to, flurp! Will check later.",
        },
        GIVETOPLAYER =
        {
            FULL = "They already have lots!",
            DEAD = "Don't think they need this, glorp.",
            SLEEPING = "Wake up!! Got thing for you!",
            BUSY = "Take thing! TAKE THING!!",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "They already have lots!",
            DEAD = "Don't think they need this, glorp.",
            SLEEPING = "Wake up!! Got stuff for you!",
            BUSY = "Take stuff! TAKE STUFF!!",
        },
        WRITE =
        {
            GENERIC = "Nuh-uh.",
            INUSE = "Me next! Me next!",
        },
        DRAW =
        {
            NOIMAGE = "Glort... forget what to draw.",
        },
        CHANGEIN =
        {
            GENERIC = "Don't wanna, florp.",
            BURNING = "Nope!",
            INUSE = "Gotta wait...",
            NOTENOUGHHAIR = "Big fuzzy not fuzzy enough!",
            NOOCCUPANT = "Need big fuzzy to hitch, florp.",
        },
        ATTUNE =
        {
            NOHEALTH = "Feel bad ... do later.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "They look mad...",
            INUSE = "Let me on, florpt!",
			SLEEPING = "WAKE UP, BIG FUZZY!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "It too mad right now.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Knew that already, florp!",
            CANTLEARN = "Flurph... this make head hurt.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "Map don't match this place...",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "Grrr, can't read! Too dark here!",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "Nothing for wrapping, florp.",
        },
        PICKUP =
        {
			RESTRICTION = "Don't wanna.",
			INUSE = "Flurmph. Gotta wait.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "It not want to come, flort.",
                "That one already have owner.",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Grrr... come back!",
        },
        REPLATE =
        {
            MISMATCH = "Not right dish, florpt.",
            SAMEDISH = "Already got dish!",
        },
        SAIL =
        {
        	REPAIR = "It good enough.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Not right time!",
            BAD_TIMING1 = "Arms tired, florp.",
            BAD_TIMING2 = "Rowing hard...",
        },
        LOWER_SAIL_FAIL =
        {
            "Glrrrpphh!!",
            "Grrr... go down!",
            "Didn't work...",
        },
        BATHBOMB =
        {
            GLASSED = "Water too hard.",
            ALREADY_BOMBED = "Water hot enough, florp.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "Oh! Knew that one already!",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "Glurph... this fish too small!",
            OVERSIZEDVEGGIES_TOO_SMALL = "What you mean is too little?!",
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
            GENERIC = "Know everything already!",
            FERTILIZER = "Know everything about it, florp!",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Plants not like to drink from the big water.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Huh? Glurgh... no water...",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "No water left!",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Won't work!",
            BEEF_BELL_ALREADY_USED = "Huh? Maybe belong to someone else...",
            BEEF_BELL_HAS_BEEF_ALREADY = "Have big fuzzy already, florpt!",
        },
        HITCHUP =
        {
            NEEDBEEF = "Don't have any big fuzzy...",
            NEEDBEEF_CLOSER = "Big fuzzy too far away.",
            BEEF_HITCHED = "Stay there, florp!",
            INMOOD = "Too mad, won't listen!",
        },
        MARK =
        {
            ALREADY_MARKED = "Yeah! This the one!",
            NOT_PARTICIPANT = "When is next contest?! Want turn!!",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Huh? Where is contest??",
            ALREADYACTIVE = "Maybe he doing secret contest somewhere else...",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "Glurgh, know it already!",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Slow down, birdies!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "Hey! Talking to you! Listen!!",
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
            DOER_ISNT_MODULE_OWNER = "Glurph. You boring!",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Don't got stuff for that!",
		NO_TECH = "Glurgh... don't know how to make...",
		NO_STATION = "Can't make it right now, florp.",
	},

	ACTIONFAIL_GENERIC = "Grrr... can't do it, florpt.",
	ANNOUNCE_BOAT_LEAK = "Boat getting wetter!",
	ANNOUNCE_BOAT_SINK = "Boat too wet!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Look better?", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Gluurgh... smell bad.", --removed
	ANNOUNCE_ADVENTUREFAIL = "Grrr, messed up!",
    ANNOUNCE_MOUNT_LOWHEALTH = "Big fuzzy look hurt...",

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

	ANNOUNCE_BEES = "Glorp! Buzzy stingers!",
	ANNOUNCE_BOOMERANG = "Glorp! Come-back stick hurts.",
	ANNOUNCE_CHARLIE = "Me think saw scary night lady!",
	ANNOUNCE_CHARLIE_ATTACK = "GLORP! GO AWAY!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "Flrrrr... c-cold...",
	ANNOUNCE_HOT = "Drying... up...",
	ANNOUNCE_CRAFTING_FAIL = "Nuh-uh, need more things.",
	ANNOUNCE_DEERCLOPS = "Glurp... me know that sound...",
	ANNOUNCE_CAVEIN = "Gloooorrp! Rocks falling!!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"Glooorrrpp!!",
		"Why ground shaking?!",
		"Something moving!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Take this, scary lady.",
        "This for you, florp.",
        "This make you happy now, florp?",
	},
	ANNOUNCE_SACREDCHEST_YES = "Yay!",
	ANNOUNCE_SACREDCHEST_NO = "Grrr... mean box.",
    ANNOUNCE_DUSK = "Sun going to sleep soon.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Mmm-mmmm!",
		PAINFUL = "Glurph... belly hurts...",
		SPOILED = "Blegh... gone bad.",
		STALE = "Tastes funny, florp.",
		INVALID = "Not for eating.",
        YUCKY = "Nuh-UH.",

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
        "Fluurph... Hrrrgh...",
        "Tired...",
        "Gluuurph!",
        "Me too little... for carry... heavy thing!",
        "Don't... like... this...",
        "(Splutter)",
        "Flurrrgh...!",
        "Someone... bigger... help...?",
        "RRRRGH!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Gl-glorp!!",
		"Something wrong!",
		"Need to go now, florp!",
	},
    ANNOUNCE_RUINS_RESET = "D-don't like these monsters, florp!",
    ANNOUNCE_SNARED = "GLORP!",
    ANNOUNCE_SNARED_IVY = "Bad plant!",
    ANNOUNCE_REPELLED = "Why not hit?!",
	ANNOUNCE_ENTER_DARK = "It dark in here...",
	ANNOUNCE_ENTER_LIGHT = "Light!!",
	ANNOUNCE_FREEDOM = "Buh-bye!",
	ANNOUNCE_HIGHRESEARCH = "Head feels so full of smarts, florp!",
	ANNOUNCE_HOUNDS = "Glurp... doggies coming...",
	ANNOUNCE_WORMS = "Glurt?",
	ANNOUNCE_HUNGRY = "Want food!",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Where these footprints go?",
	ANNOUNCE_HUNT_LOST_TRAIL = "No more prints, flort.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Dirt too wet for tracks, have mud bath instead!",
	ANNOUNCE_INV_FULL = "Don't have enough pockets, florp.",
	ANNOUNCE_KNOCKEDOUT = "Glurgh... head hurt...",
	ANNOUNCE_LOWRESEARCH = "Don't get it...",
	ANNOUNCE_MOSQUITOS = "Gluuurph! Shoo, bugs!",
    ANNOUNCE_NOWARDROBEONFIRE = "Nuh-uh.",
    ANNOUNCE_NODANGERGIFT = "Wanna open present... but not safe.",
    ANNOUNCE_NOMOUNTEDGIFT = "Need to get down first.",
	ANNOUNCE_NODANGERSLEEP = "No sleepy-time now, florp!",
	ANNOUNCE_NODAYSLEEP = "Too bright out to sleep!",
	ANNOUNCE_NODAYSLEEP_CAVE = "Not sleepy, florp.",
	ANNOUNCE_NOHUNGERSLEEP = "Need food, then sleepy-time.",
	ANNOUNCE_NOSLEEPONFIRE = "Not gonna sleep there, glort.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Glurgh... IRONFOLK TOO BRIGHT.",
	ANNOUNCE_NODANGERSIESTA = "Too scary for nap!",
	ANNOUNCE_NONIGHTSIESTA = "Don't want nap, want bedtime!",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Glurp... too scary in here...",
	ANNOUNCE_NOHUNGERSIESTA = "Belly too rumbly!",
	ANNOUNCE_NO_TRAP = "Easy, florp!",
	ANNOUNCE_PECKED = "Ow! OW! Ouchie!",
	ANNOUNCE_QUAKE = "Ground shaking!",
	ANNOUNCE_RESEARCH = "Head getting full of smarts, flurp!",
	ANNOUNCE_SHELTER = "Why not play in rain, florp?",
	ANNOUNCE_THORNS = "Ouchie!",
	ANNOUNCE_BURNT = "Glorpt!! Hot!!",
	ANNOUNCE_TORCH_OUT = "Hey, where fire go, florp?",
	ANNOUNCE_THURIBLE_OUT = "Aw, no more.",
	ANNOUNCE_FAN_OUT = "Glurp... me didn't break it!!",
    ANNOUNCE_COMPASS_OUT = "Spinny pointer broken. Didn't do it, florp!!",
	ANNOUNCE_TRAP_WENT_OFF = "....Glop.",
	ANNOUNCE_UNIMPLEMENTED = "Trap not ready!",
	ANNOUNCE_WORMHOLE = "Wheeeeee!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Glorp... felt weird!",
	ANNOUNCE_CANFIX = "\nCan fix easy, florp!",
	ANNOUNCE_ACCOMPLISHMENT = "Did it!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "Did it!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Plant still hungry.",
	ANNOUNCE_TOOL_SLIP = "Claws too slimy, florp.",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "GLORPT! Almost got sparky!",
	ANNOUNCE_TOADESCAPING = "Don't leave!",
	ANNOUNCE_TOADESCAPED = "Come back toad!!",


	ANNOUNCE_DAMP = "Ahh... wetter feel better, florp!",
	ANNOUNCE_WET = "Mermfolk love water, florp!",
	ANNOUNCE_WETTER = "Feels good on scales!",
	ANNOUNCE_SOAKED = "Aaah, splish-splash!",

	ANNOUNCE_WASHED_ASHORE = "Had good swim!",

    ANNOUNCE_DESPAWN = "Feel cold...",
	ANNOUNCE_BECOMEGHOST = "gloOooOooorp!!",
	ANNOUNCE_GHOSTDRAIN = "Gluurrr... glorph... GLORRPP...",
	ANNOUNCE_PETRIFED_TREES = "Glurp... trees getting scary...",
	ANNOUNCE_KLAUS_ENRAGE = "Aaah! Scary scary!!",
	ANNOUNCE_KLAUS_UNCHAINED = "GLOOOORRP!! Belly has teeth!",
	ANNOUNCE_KLAUS_CALLFORHELP = "It calling friends!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Something in there?",
		GLASS_LOW = "Almost done, florp!",
		GLASS_REVEAL = "Free!",
		IDOL_MED = "Something in there?",
		IDOL_LOW = "Almost done, florp!",
		IDOL_REVEAL = "Free!",
		SEED_MED = "Something in there?",
		SEED_LOW = "Almost done, florp!",
		SEED_REVEAL = "Free!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "G-glurp... saw something...",
	ANNOUNCE_BRAVERY_POTION = "Me was never scared, florp!",
	ANNOUNCE_MOONPOTION_FAILED = "Awww... nothing happen.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Should share with others, florp.",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Oooooh, feel sparkly!",
	ANNOUNCE_IS_FEASTING = "So much food, flurt!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Hey! Where sparkles go?",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Us friends now... florp?",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "All better, flurp!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "G-glurp... that was scary.",

    ANNOUNCE_FLARE_SEEN = "Fire in sky??",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Someone coming?",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Glurgh, that not gonna taste good together.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Oops...",
    QUAGMIRE_ANNOUNCE_LOSE = "We win! No? Glurp...",
    QUAGMIRE_ANNOUNCE_WIN = "Yay! Going back now, bye-bye sky mouth!",

    ANNOUNCE_ROYALTY =
    {
        "Big important!",
        "Crowny head!",
        "Any fairy stories about you, florp?",
    },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "Sparky!!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Wanna fight!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "Me tougher than you!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Florp...? Why me suddenly wanna do chores?",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Glurph... drying up...",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "No sleep ever!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Awwwwww...",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Don't feel like fighting anymore.",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "G-glorp, don't hit!",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Tired...",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Yay!! Feel wetter already, flurp!",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "Getting bit sleepy now, florp.",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Glurph! Hey!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "Line too loose, fish gonna get away!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "No! Come back, fishy!",
	ANNOUNCE_OCEANFISHING_BADCAST = "Glurgh... this hard.",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Fish! Come here fish!",
		"Doo-dee-doo-dee-dum...",
		"Where the fishies?",
		"Glurph. This taking too long.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nGlurgh... is so heavy!",

	ANNOUNCE_WINCH_CLAW_MISS = "Aww, no fair!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "Glurgh... gotta start over.",

    --Wurt announce strings
    ANNOUNCE_KINGCREATED = "Mermfolk have new King!",
    ANNOUNCE_KINGDESTROYED = "Was bad King, will find better one!",
    ANNOUNCE_CANTBUILDHERE_THRONE = "This no place for swamp King!",
    ANNOUNCE_CANTBUILDHERE_HOUSE = "Pretty house should go in pretty swamp!",
    ANNOUNCE_CANTBUILDHERE_WATCHTOWER = "No, no! Guards defend swamp!",
    ANNOUNCE_READ_BOOK =
    {
        BOOK_SLEEP = "Wuh... wunce? Once! U-up... on... uh...",
        BOOK_BIRDS = "This one have pictures of birdies!",
        BOOK_TENTACLES =  "This a good one!",
        BOOK_BRIMSTONE = "Flurrgh, wanna know how it ends!",
        BOOK_GARDENING = "So many hard words...",
		BOOK_SILVICULTURE = "Is whole story about trees? Me know about trees!",
		BOOK_HORTICULTURE = "So many hard words...",
    },
    ANNOUNCE_WEAK_RAT = "It not look so good...",

    ANNOUNCE_CARRAT_START_RACE = "Go! Go! Go!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Hey! That way! THAT WAY!",
        "Glurph, veggie rat going wrong way!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "No sleepy! Gotta win!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Not move fast enough, florp!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "What wrong, why you not going?!",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Oooh... head feel swimmy...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Head filled with pictures!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "Seen these pictures already.",
    ANNOUNCE_ARCHIVE_NO_POWER = "Hey! It not do anything!",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "Oooh, learn new plant thing!",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "What it gonna be?",

    ANNOUNCE_FERTILIZER_RESEARCHED = "Learning lots!",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Ouchie! It hot! Don't like it, florp!",
		"It a bad plant! Makes insides burny!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Glurgh... feel bit better now.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Hello, florp!",
        "You green, makes you good.",
		"Wanna hear fairy story?",
        "You gonna grow up big and tasty!",
        "Hey, you listening?",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Hide now! Me coming!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Wanna play too, florp!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Found you, florp!",
		"Ha ha, you easy to find.",
		"Me is best at this game!",
		"Need to find better hidey spot than that, flort!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "Is one left somewhere!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "You last one!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "{name} find last one? Glurgh... coulda done it...",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Where they hiding?! Time almost up!!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "No fair! Scratchy fluffies cheat!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "Hmm, don't smell no scratchy fluffies out here.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Smell scratchy fluffies nearby, flort!",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "You lost? Will take you home, florp!",

	ANNOUNCE_TICOON_START_TRACKING	= "Hey, where you going florp?",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "What wrong? Can't find nothing?",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Coming!! Wait up, flort!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "He smell something!",
	ANNOUNCE_TICOON_NEAR_KITCOON = "There something nearby...",
	ANNOUNCE_TICOON_LOST_KITCOON = "What happen? Can't smell them no more?",
	ANNOUNCE_TICOON_ABANDONED = "You no fun anymore. Bye-bye!",
	ANNOUNCE_TICOON_DEAD = "Don't think he gonna be helping anymore, florp.",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "HEY! Come here!!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "Too far away, flort.",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Yay! New dress-up thing!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Sky is falling, glorp!!",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Why you come back, flurt? Said go away!!",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Y-Yeah, big eye better run away! Glurgh...",

	BATTLECRY =
	{
		GENERIC = "Not scared of you, florp!",
		PIG = "ENEMY OF MERMFOLK!",
		PREY = "Stay... stay!",
		SPIDER = "Glurph, yucky spider!",
		SPIDER_WARRIOR = "Go away fighty spider!",
		DEER = "Glurph, go away!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Pbbbbbbth!",
		PIG = "Bad Pigman got away.",
		PREY = "Come back, florp!",
		SPIDER = "Oh... might be friend of Webby boy.",
		SPIDER_WARRIOR = "Don't like you anyway, flurt!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Scale-less say this what brought them here?",
        MULTIPLAYER_PORTAL_MOONROCK = "It made of moon stuff!",
        MOONROCKIDOL = "It looking at me.",
        CONSTRUCTION_PLANS = "Look easy to build!",

        ANTLION =
        {
            GENERIC = "What you want?",
            VERYHAPPY = "She look much happier!",
            UNHAPPY = "Glorp, don't be mad!",
        },
        ANTLIONTRINKET = "Know someone who'd like this, florp!",
        SANDSPIKE = "Aaah! Spiky!",
        SANDBLOCK = "Gloorph!",
        GLASSSPIKE = "Would look better with Pig head on it, florp!",
        GLASSBLOCK = "Look very breakable, florp.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="It not quite as ugly as most flowers.",
			LEVEL1 = "Abby-gill hiding.",
			LEVEL2 = "She sure taking her time, flort.",
			LEVEL3 = "Come out!",

			-- deprecated
            LONG = "Pretty.",
            MEDIUM = "Hmm?",
            SOON = "Something happening!",
            HAUNTED_POCKET = "Glorp! Down flower!",
            HAUNTED_GROUND = "Shouldn't be here, flurp...",
        },

        BALLOONS_EMPTY = "Look chewy, florp.",
        BALLOON = "Want one!!",
		BALLOONPARTY = "Huh? There stuff inside!",
		BALLOONSPEED =
        {
            DEFLATED = "Awww, got all small.",
            GENERIC = "That a big one, flurp!",
        },
		BALLOONVEST = "Ooooh, water floaty!",
		BALLOONHAT = "Squeaky hat.",

        BERNIE_INACTIVE =
        {
            BROKEN = "Aww...",
            GENERIC = "No playing anymore?",
        },

        BERNIE_ACTIVE = "Wanna play with it!",
        BERNIE_BIG = "Fun toy, flurp!",

        BOOK_BIRDS = "Read this one, Wicker-lady!",
        BOOK_TENTACLES = "Remind me of home, florp.",
        BOOK_GARDENING = "A... appled...? (Sigh)",
		BOOK_SILVICULTURE = "A... appled...? (Sigh)",
		BOOK_HORTICULTURE = "What does bridge have to do with plants, florp?",
        BOOK_SLEEP = "Want bedtime story!",
        BOOK_BRIMSTONE = "Where Wicker-lady? Want to know what happen next!",

        PLAYER =
        {
            GENERIC = "Hello, %s!",
            ATTACKER = "Grrr... don't trust %s.",
            MURDERER = "G...glorp... %s a killer!!",
            REVIVER = "Didn't need help! ...But thanks, florp.",
            GHOST = "You look spooky, %s.",
            FIRESTARTER = "You gonna burn everything up, %s!!",
        },
        WILSON =
        {
            GENERIC = "Hello funny hair man!",
            ATTACKER = "Not very nice, flort!",
            MURDERER = "Knew scale-less not to be trusted!",
            REVIVER = "That \"science\" pretty good, florp!",
            GHOST = "Hee-hee, you look silly!",
            FIRESTARTER = "This for \"science\"?",
        },
        WOLFGANG =
        {
            GENERIC = "Hello muscly mustache man!",
            ATTACKER = "Not fair, you way bigger!",
            MURDERER = "Grrr, you just a bully!",
            REVIVER = "This mean you not scared of me anymore?",
            GHOST = "Don't be scared, will find heart for you!",
            FIRESTARTER = "That was bad idea, flort.",
        },
        WAXWELL =
        {
            GENERIC = "You the one other scale-less don't like?",
            ATTACKER = "You a bad man!!",
            MURDERER = "Now see why other scale-less don't like you, flort.",
            REVIVER = "You not seem so bad, florp.",
            GHOST = "Don't be grumpy, will help!",
            FIRESTARTER = "He did it! He did it!",
        },
        WX78 =
        {
            GENERIC = "Hello short Ironfolk.",
            ATTACKER = "Ow! Stop it, flort!",
            MURDERER = "This mean war!",
            REVIVER = "Wasn't sure you would...",
            GHOST = "You not look very happy like that.",
            FIRESTARTER = "Think you having too much fun, flort.",
        },
        WILLOW =
        {
            GENERIC = "Hello fire lady!",
            ATTACKER = "You not so tough, flort!",
            MURDERER = "Grrrr, bad lady!",
            REVIVER = "You actually pretty nice, florp.",
            GHOST = "Me play with bear while you--? Fine, will find heart.",
            FIRESTARTER = "She seem happy.",
        },
        WENDY =
        {
            GENERIC = "Hello sad girl, how sister today?",
            ATTACKER = "Hey! Stop it, florp!",
            MURDERER = "You only wanna play with ghosts?",
            REVIVER = "Said hi to Abby-gill for you, flort.",
            GHOST = "Do you... really want heart?",
            FIRESTARTER = "Why you do that?",
        },
        WOODIE =
        {
            GENERIC = "Hello wood choppy man!",
            ATTACKER = "Go find tree to hit instead!",
            MURDERER = "Shoulda known choppy man was killer!",
            REVIVER = "Choppy man is nice.",
            GHOST = "Need help, florp?",
            BEAVER = "Where choppy man go?!",
            BEAVERGHOST = "Will find heart, if you bring back wood choppy man!",
            MOOSE = "Where choppy man go?!",
            MOOSEGHOST = "Will find heart, if you bring back wood choppy man!",
            GOOSE = "Where choppy man go?!",
            GOOSEGHOST = "Will find heart, if you bring back wood choppy man!",
            FIRESTARTER = "Thought you like chopping things, not burning?",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Can you read me story, florp?",
            ATTACKER = "Why mad? Didn't do anything!",
            MURDERER = "Trusted you!",
            REVIVER = "Thank you very much! (Me say that right?)",
            GHOST = "Will get you heart right away!",
            FIRESTARTER = "That not where campfire goes.",
        },
        WES =
        {
            GENERIC = "Hello clown man.",
            ATTACKER = "Glorph, go away!",
            MURDERER = "Scale-less bad, never shoulda left swamp!",
            REVIVER = "Oh... thanks, flort.",
            GHOST = "Look paler than usual, florp.",
            FIRESTARTER = "You a strange man, flort.",
        },
        WEBBER =
        {
            GENERIC = "Hi Webby boy!",
            ATTACKER = "Why you being so mean?",
            MURDERER = "Thought you was friend!",
            REVIVER = "Knew we was friends!",
            GHOST = "Don't be sad, will get heart!",
            FIRESTARTER = "You gonna get in trouble!",
        },
        WATHGRITHR =
        {
            GENERIC = "Hello Viking lady!",
            ATTACKER = "Grrr, Viking lady want to fight??",
            MURDERER = "Glorp! Me not to be hunted!!",
            REVIVER = "....Thank you, flort.",
            GHOST = "Ooooh, you look spooky!",
            FIRESTARTER = "Thought that was fire lady's job, flort.",
        },
        WINONA =
        {
            GENERIC = "You know the night lady?",
            ATTACKER = "That not safe!",
            MURDERER = "You broke trust!!",
            REVIVER = "All fixed up!",
            GHOST = "Thought you never take breaks, flort?",
            FIRESTARTER = "Maybe she tired of fixing things, florp.",
        },
        WORTOX =
        {
            GENERIC = "What an \"imp\"?",
            ATTACKER = "Glorph, you so mean!",
            MURDERER = "Knew you not to be trusted!",
            REVIVER = "This not a trick...?",
            GHOST = "You poofed right out of body!!",
            FIRESTARTER = "He look very scary right now, flurp.",
        },
        WORMWOOD =
        {
            GENERIC = "Hi leafy!",
            ATTACKER = "Ow! You mean old weed!",
            MURDERER = "We not friends anymore, flort!",
            REVIVER = "You a good plant!",
            GHOST = "Stay! Will get help!",
            FIRESTARTER = "Glorp, that dangerous!",
        },
        WARLY =
        {
            GENERIC = "Hello fancy cook man!",
            ATTACKER = "Glurph, thought you were nice!",
            MURDERER = "You not friend at all!",
            REVIVER = "You... help me, flort?",
            GHOST = "Nooo! Who gonna cook yummy things for me...",
            FIRESTARTER = "He wanna cook everything!",
        },

        WURT =
        {
            GENERIC = "Hello me!",
            ATTACKER = "Mermfolk should stick together!",
            MURDERER = "Glurp... am own worst enemy!",
            REVIVER = "Can always count on me!",
            GHOST = "There gotta be heart around somewhere.",
            FIRESTARTER = "Stop! You gonna get us in trouble!",
        },

        WALTER =
        {
            GENERIC = "Hello pine boy!",
            ATTACKER = "You not help, you mean!",
            MURDERER = "Grrr, should never trust scale-less!",
            REVIVER = "You is very nice and good, florp.",
            GHOST = "Pine boy not having fun?",
            FIRESTARTER = "You gonna burn everything, flort!",
        },

        WANDA =
        {
            GENERIC = "Why you not always look the same?",
            ATTACKER = "Go away! You mean!",
            MURDERER = "Some scale-less okay, but you very bad!",
            REVIVER = "You kinda weird, but nice!",
            GHOST = "You need help, flort?",
            FIRESTARTER = "She start fire, not me, florp!",
        },

        MIGRATION_PORTAL =
        {
        --    GENERIC = "If I had any friends, this could take me to them.",
        --    OPEN = "If I step through, will I still be me?",
        --    FULL = "It seems to be popular over there.",
        },
        GLOMMER =
        {
            GENERIC = "Hee-hee, goopy bug thing!",
            SLEEPING = "Nighty night, buggy.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "What so special about this flower, florp?",
            DEAD = "Almost sad it gone.",
        },
        GLOMMERWINGS = "Big bug had weird tiny wings, flurt.",
        GLOMMERFUEL = "Bug goop.",
        BELL = "Make nice sound.",
        STATUEGLOMMER =
        {
            GENERIC = "Rock look like weird bug.",
            EMPTY = "Oops... didn't do it!",
        },

        LAVA_POND_ROCK = "Rock.",

		WEBBERSKULL = "That not where bone belong!",
		WORMLIGHT = "Big glowy berry!",
		WORMLIGHT_LESSER = "Little glowy...",
		WORM =
		{
		    PLANT = "Oooh, pretty fruit...",
		    DIRT = "Dirt pile!",
		    WORM = "WORM!!",
		},
        WORMLIGHT_PLANT = "Pretty......",
		MOLE =
		{
			HELD = "Quit wiggling, flort!",
			UNDERGROUND = "Where you going?",
			ABOVEGROUND = "So nosey!",
		},
		MOLEHILL = "Mole home.",
		MOLEHAT = "Has nice stench to it, florp.",

		EEL = "Hello long fishy!",
		EEL_COOKED = "No!!",
		UNAGI = "That not what you do with fish, flort!",
		EYETURRET = "Glurp, won't hit me... right?",
		EYETURRET_ITEM = "Not sure this good idea...",
		MINOTAURHORN = "Mine now, flort!",
		MINOTAURCHEST = "Treasure?",
		THULECITE_PIECES = "Bitty bits.",
		POND_ALGAE = "Ooooh, slimy!",
		GREENSTAFF = "Has pretty green rock on it.",
		GIFT = "Present for me!",
        GIFTWRAP = "Why scale-less wrap things in more things?",
		POTTEDFERN = "This plant have little house.",
        SUCCULENT_POTTED = "Has a home now.",
		SUCCULENT_PLANT = "How you live in place like this?",
		SUCCULENT_PICKED = "Oop, broke it.",
		SENTRYWARD = "How it float like that?",
        TOWNPORTAL =
        {
			GENERIC = "Take me where friends are!",
			ACTIVE = "Ready, flort!",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "Go-stone!",
			ACTIVE = "Jump to friends!",
		},
        WETPAPER = "Got all soggy, flort.",
        WETPOUCH = "Found pond treasure!",
        MOONROCK_PIECES = "Moon made these?",
        MOONBASE =
        {
            GENERIC = "It want something?",
            BROKEN = "Someone broke it, flrot!",
            STAFFED = "Anything happen, florp?",
            WRONGSTAFF = "Don't look right.",
            MOONSTAFF = "Bright stick!",
        },
        MOONDIAL =
        {
			GENERIC = "Special moon pond.",
			NIGHT_NEW = "Moon not swimming tonight?",
			NIGHT_WAX = "Grow big, moon!",
			NIGHT_FULL = "Big bouncy moon, florp!",
			NIGHT_WANE = "Moon look smaller tonight.",
			CAVE = "This not good spot.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "Glurph... something watching.",
        },
		THULECITE = "Look weird, florp...",
		ARMORRUINS = "Strong!",
		ARMORSKELETON = "Glorp! Look scary!",
		SKELETONHAT = "Glurph... head feel funny...",
		RUINS_BAT = "Clobbery!",
		RUINSHAT = "Queen Wurt!!",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "It seem safe.",
            WARN = "Getting weird, florp...",
            WAXING = "Something happening!",
            STEADY = "Staying the same,.",
            WANING = "It going away!",
            DAWN = "Over soon, over soon.",
            NOMAGIC = "Seem okay.",
		},
		BISHOP_NIGHTMARE = "Something wrong with it, glort!",
		ROOK_NIGHTMARE = "Glorp! What wrong with it?!",
		KNIGHT_NIGHTMARE = "Glurp, it has the bad stuff on it!",
		MINOTAUR = "Glurp... it look cranky.",
		SPIDER_DROPPER = "See you hiding up there, flort!",
		NIGHTMARELIGHT = "Don't like it, florp.",
		NIGHTSTICK = "Ooooh, bright!",
		GREENGEM = "Like this stone, florp.",
		MULTITOOL_AXE_PICKAXE = "That pretty smart, florp.",
		ORANGESTAFF = "Orangey rock stick!",
		YELLOWAMULET = "Feel warm...",
		GREENAMULET = "Help with building things!",
		SLURPERPELT = "Took its fur, florp.",

		SLURPER = "Ha ha, tickly!",
		SLURPER_PELT = "Took its fur, florp.",
		ARMORSLURPER = "Good belt, glorp.",
		ORANGEAMULET = "It make me feel fancy, flurp.",
		YELLOWSTAFF = "Has pretty yellow rock on it.",
		YELLOWGEM = "There sunshine inside it.",
		ORANGEGEM = "Weird orangey rock.",
        OPALSTAFF = "Rainbow light stick!",
        OPALPRECIOUSGEM = "There so many colors, flort!",
        TELEBASE =
		{
			VALID = "Ready!",
			GEMS = "Something missing...",
		},
		GEMSOCKET =
		{
			VALID = "Rock got all floaty.",
			GEMS = "Find sparkly rock to go in here.",
		},
		STAFFLIGHT = "Glorph! Burny light!",
        STAFFCOLDLIGHT = "It so cold!",

        ANCIENT_ALTAR = "Look real old.",

        ANCIENT_ALTAR_BROKEN = "It broken, flurp.",

        ANCIENT_STATUE = "Creepy.",

        LICHEN = "Cave food.",
		CUTLICHEN = "Crumbly.",

		CAVE_BANANA = "Mmm... good fruit, florp.",
		CAVE_BANANA_COOKED = "Yummy!",
		CAVE_BANANA_TREE = "See fruits up there!",
		ROCKY = "Hi!",

		COMPASS =
		{
			GENERIC="There spinny needle inside!",
			N = "North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "Big chomper.",
        ARMORSNURTLESHELL = "Sticky!",
        BAT = "Grrr!",
        BATBAT = "Whack! Whack!",
        BATWING = "No more bat.",
        BATWING_COOKED = "Gluurrggh...",
        BATCAVE = "Me not afraid, florp!",
        BEDROLL_FURRY = "Fluffy...",
        BUNNYMAN = "Don't like Bunnyman!",
        FLOWER_CAVE = "Glowy!",
        GUANO = "Bats poop too, florp.",
        LANTERN = "Glowy!",
        LIGHTBULB = "What you mean, \"don't put in your mouth\"?",
        MANRABBIT_TAIL = "He don't need it anymore, flurpt.",
        MUSHROOMHAT = "Keeps head nice and clammy!",
        MUSHROOM_LIGHT2 =
        {
            ON = "Oooh, pretty color!",
            OFF = "It supposed to do something?",
            BURNT = "It was so pretty, florp...",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Glowy!",
            OFF = "It in a funny shape, florp.",
            BURNT = "Didn't do it!",
        },
        SLEEPBOMB = "Hee-hee, nighty night!",
        MUSHROOMBOMB = "Glurp! Run away!",
        SHROOM_SKIN = "Oooh, had such nice skin!",
        TOADSTOOL_CAP =
        {
            EMPTY = "Hallooo? ANYBODY HOME?",
            INGROUND = "See you in there!",
            GENERIC = "What nice cap you have, flort.",
        },
        TOADSTOOL =
        {
            GENERIC = "Has pretty face, bad personality.",
            RAGE = "Think we made him mad, flort!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Big mushroom!",
            BURNT = "Oops...",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "It grow so big!",
            BLOOM = "Something falling off it.",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Look kinda tasty, florp.",
            BLOOM = "Pretty!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Short and stumpy.",
            BLOOM = "Floaty lights!",
        },
        MUSHTREE_TALL_WEBBED = "This one claimed by Spiderfolk.",
        SPORE_TALL =
        {
            GENERIC = "Pretty!",
            HELD = "My floaty fluff now!",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Floaty!",
            HELD = "My floaty fluff now!",
        },
        SPORE_SMALL =
        {
            GENERIC = "It dancing!",
            HELD = "My floaty fluff now!",
        },
        RABBITHOUSE =
        {
            GENERIC = "Sniff... there someone inside...",
            BURNT = "Aww, wanted to eat that!",
        },
        SLURTLE = "Look like a friend, flort.",
        SLURTLE_SHELLPIECES = "Aw, it broke!",
        SLURTLEHAT = "My shell now!",
        SLURTLEHOLE = "Ooooh, slimy!",
        SLURTLESLIME = "Splodey loogies!",
        SNURTLE = "Has trustworthy face, florp.",
        SPIDER_HIDER = "Grrr, scaredy spider!!",
        SPIDER_SPITTER = "Glurph, spider loogies!!",
        SPIDERHOLE = "Spiderfolk hole!",
        SPIDERHOLE_ROCK = "All webby...",
        STALAGMITE = "Cave rock.",
        STALAGMITE_TALL = "Big cave rock.",

        TURF_CARPETFLOOR = "Fuzzy ground.",
        TURF_CHECKERFLOOR = "Ground bit.",
        TURF_DIRT = "Ground bit.",
        TURF_FOREST = "Ground bit.",
        TURF_GRASS = "Ground bit.",
        TURF_MARSH = "Ground bit.",
        TURF_METEOR = "Ground bit.",
        TURF_PEBBLEBEACH = "Ground bit.",
        TURF_ROAD = "Make ground walk-ier!",
        TURF_ROCKY = "Ground bit.",
        TURF_SAVANNA = "Ground bit.",
        TURF_WOODFLOOR = "Tree parts.",

		TURF_CAVE="Ground bit.",
		TURF_FUNGUS="Ground bit.",
		TURF_FUNGUS_MOON = "Ground bit.",
		TURF_ARCHIVE = "Ground bit.",
		TURF_SINKHOLE="Ground bit.",
		TURF_UNDERROCK="Ground bit.",
		TURF_MUD="Ground bit.",

		TURF_DECIDUOUS = "Ground bit.",
		TURF_SANDY = "Ground bit.",
		TURF_BADLANDS = "Ground bit.",
		TURF_DESERTDIRT = "Ground bit.",
		TURF_FUNGUS_GREEN = "Ground bit.",
		TURF_FUNGUS_RED = "Ground bit.",
		TURF_DRAGONFLY = "Scaly ground!",

        TURF_SHELLBEACH = "Ground bit.",

		POWCAKE = "Gives tummy-ache, but... smell so good...",
        CAVE_ENTRANCE = "There rocks in the way.",
        CAVE_ENTRANCE_RUINS = "What down there?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Something down there.",
            OPEN = "Wanna see what inside, glorp!",
            FULL = "Lemme in!",
        },
        CAVE_EXIT =
        {
            GENERIC = "Kinda like it down here, florp.",
            OPEN = "Miss the outside.",
            FULL = "Lemme out!",
        },

		MAXWELLPHONOGRAPH = "Music comes out of it, florp!",--single player
		BOOMERANG = "Come-back stick!",
		PIGGUARD = "Glurp, he even scarier than others.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "You... nice?",
                "You... nice?",
            },
            LEVEL2 =
            {
                "You... nice?",
                "You... nice?",
            },
            LEVEL3 =
            {
                "You... nice?",
                "You... nice?",
            },
		},
		ADVENTURE_PORTAL = "Where this go?",
		AMULET = "Pretty magic rock!",
		ANIMAL_TRACK = "Tracks!",
		ARMORGRASS = "Swishy swish!",
		ARMORMARBLE = "It heavyyyy...",
		ARMORWOOD = "Wood shirt!",
		ARMOR_SANITY = "Don't like it, flurp!!",
		ASH =
		{
			GENERIC = "Pile of burny bits.",
			REMAINS_GLOMMERFLOWER = "Aww... all gone.",
			REMAINS_EYE_BONE = "Buh-bye blinky stick.",
			REMAINS_THINGIE = "It gone now.",
		},
		AXE = "Choppy chop!",
		BABYBEEFALO =
		{
			GENERIC = "So little.",
		    SLEEPING = "Night night!",
        },
        BUNDLE = "Keep for later.",
        BUNDLEWRAP = "Pack lots of things, flurpt!",
		BACKPACK = "For carry all the things!",
		BACONEGGS = "Blegh!!",
		BANDAGE = "Make hurts feel better, flurp.",
		BASALT = "Hard rock!!", --removed
		BEARDHAIR = "Scale-less are weird...",
		BEARGER = "Run away!!",
		BEARGERVEST = "Feel warm and fuzzy...",
		ICEPACK = "Fuzzy bag!",
		BEARGER_FUR = "Stripy fluff.",
		BEDROLL_STRAW = "Scale-less rather sleep on itchy grass than mud?",
		BEEQUEEN = "Queen of stingers!!",
		BEEQUEENHIVE =
		{
			GENERIC = "That honey in there, florp?",
			GROWING = "Something strange...",
		},
        BEEQUEENHIVEGROWN = "Have bad feeling, florp...",
        BEEGUARD = "Glurp! Big stinger!",
        HIVEHAT = "Wurt your queen now!",
        MINISIGN =
        {
            GENERIC = "Oooh, pictures!",
            UNDRAWN = "Glorph? Nothing on it.",
        },
        MINISIGN_ITEM = "Where put it?",
		BEE =
		{
			GENERIC = "Buzzy stinger.",
			HELD = "Ha! Got you, florp!",
		},
		BEEBOX =
		{
			READY = "Sweets!!",
			FULLHONEY = "Sweets!!",
			GENERIC = "Home for stingers.",
			NOHONEY = "Aww no sweets inside.",
			SOMEHONEY = "Don't wanna wait!!",
			BURNT = "It not buzzing anymore...",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "No room for more mushrooms!",
			LOTS = "Mmm, lots of tasty snacks growing!",
			SOME = "They starting to grow!",
			EMPTY = "Needs mushrooms!",
			ROTTEN = "Need more creepy logs!",
			BURNT = "Too burnt for mushrooms, florp.",
			SNOWCOVERED = "Maybe mushrooms sleeping?",
		},
		BEEFALO =
		{
			FOLLOWER = "Follow me!",
			GENERIC = "Big fuzzy!",
			NAKED = "Glurph, look better with fur.",
			SLEEPING = "Night night, fuzzy.",
            --Domesticated states:
            DOMESTICATED = "This one a friend.",
            ORNERY = "Don't be mad!!",
            RIDER = "Wanna ride!",
            PUDGY = "Big fuzzy look extra big.",
            MYPARTNER = "Is my friend! MINE!",
		},

		BEEFALOHAT = "Bigger horns!!",
		BEEFALOWOOL = "Fluffs.",
		BEEHAT = "Can't see in here!",
        BEESWAX = "Stole from stinger nest!",
		BEEHIVE = "Home for stingers.",
		BEEMINE = "Careful, florp!",
		BEEMINE_MAXWELL = "Don't like the way this hums.",--removed
		BERRIES = "Yummy shrub snacks!",
		BERRIES_COOKED = "Why try to burn snacks, glort?",
        BERRIES_JUICY = "Ooooh, big tasty!",
        BERRIES_JUICY_COOKED = "Wanna eat them all!",
		BERRYBUSH =
		{
			BARREN = "Put poop on it, flurp.",
			WITHERED = "Too dry.",
			GENERIC = "Snacks!",
			PICKED = "Gotta wait for more snacks.",
			DISEASED = "Won't make snacks if sick, florp.",--removed
			DISEASING = "Don't look right.",--removed
			BURNING = "Bye-bye.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Need poop.",
			WITHERED = "It don't like heat either.",
			GENERIC = "Gotta eat them fast!",
			PICKED = "Make snacks! Make snacks!",
			DISEASED = "Look bad, florp.",--removed
			DISEASING = "Don't look right.",--removed
			BURNING = "Hot! Hot!!",
		},
		BIGFOOT = "Has big feets!",--removed
		BIRDCAGE =
		{
			GENERIC = "Stick bird inside!",
			OCCUPIED = "Now bird stay forever!",
			SLEEPING = "Nighty night, birdy.",
			HUNGRY = "Bird needs snack.",
			STARVING = "It look so hungry...",
			DEAD = "Aw, it dead now.",
			SKELETON = "...",
		},
		BIRDTRAP = "Catch birdies!",
		CAVE_BANANA_BURNT = "Glurph, it ruined.",
		BIRD_EGG = "Baby bird inside?",
		BIRD_EGG_COOKED = "Don't want it!",
		BISHOP = "Zappy Ironfolk!!",
		BLOWDART_FIRE = "Wanna try that!",
		BLOWDART_SLEEP = "Sleepy-time, florp!",
		BLOWDART_PIPE = "Ph-tooey!",
		BLOWDART_YELLOW = "Zappy!",
		BLUEAMULET = "Chilly!",
		BLUEGEM = "Pretty rock.",
		BLUEPRINT =
		{
            COMMON = "Has pictures on it!",
            RARE = "Look really complicated, florp.",
        },
        SKETCH = "Oooh, picture!",
		BLUE_CAP = "Good for belly, bad for head.",
		BLUE_CAP_COOKED = "It smell different...",
		BLUE_MUSHROOM =
		{
			GENERIC = "Food!",
			INGROUND = "Will come back when it dark out, florp.",
			PICKED = "Grow big again!",
		},
		BOARDS = "Tree pieces for building, florp.",
		BONESHARD = "Piece of something dead.",
		BONESTEW = "Glurgh.",
		BUGNET = "Wanna catch bugs!",
		BUSHHAT = "Can't see me!!",
		BUTTER = "Taste like bugs... not bad, florp.",
		BUTTERFLY =
		{
			GENERIC = "It ugly, but fun to chase.",
			HELD = "Gotcha!!",
		},
		BUTTERFLYMUFFIN = "Tasty!",
		BUTTERFLYWINGS = "Pluck, pluck!",
		BUZZARD = "Pretty bird!",

		SHADOWDIGGER = "He use the bad magic!!",

		CACTUS =
		{
			GENERIC = "It full of spikes.",
			PICKED = "Grow back, florp!",
		},
		CACTUS_MEAT_COOKED = "Mmmm, it eating time!",
		CACTUS_MEAT = "Ow! Still spiky.",
		CACTUS_FLOWER = "Glurph, ugly but tasty.",

		COLDFIRE =
		{
			EMBERS = "It dying.",
			GENERIC = "Time for story-tell around fire, florp!",
			HIGH = "Big fire!",
			LOW = "Fire getting small.",
			NORMAL = "Chilly fire?",
			OUT = "Bye-bye.",
		},
		CAMPFIRE =
		{
			EMBERS = "It dying.",
			GENERIC = "Time for story-tell around fire, florp!",
			HIGH = "Big fire!",
			LOW = "Fire getting small.",
			NORMAL = "Warm and toasty.",
			OUT = "Bye-bye.",
		},
		CANE = "This for old folk, florp.",
		CATCOON = "You funny, florp!",
		CATCOONDEN =
		{
			GENERIC = "Something skritching inside.",
			EMPTY = "Nobody home.",
		},
		CATCOONHAT = "Ha ha, is hat now.",
		COONTAIL = "Mine now, florp!",
		CARROT = "Tasty root!",
		CARROT_COOKED = "It was fine way it was.",
		CARROT_PLANTED = "Grow! Grow!",
		CARROT_SEEDS = "Make more tasty snacks!",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Mermfolk don't need map!",
			BURNING = "Bye-bye!",
			BURNT = "Gone now.",
		},
		WATERMELON_SEEDS = "Make more tasty snacks!",
		CAVE_FERN = "Leafy cave plant.",
		CHARCOAL = "Gets claws all smudgy.",
        CHESSPIECE_PAWN = "It littlest of its kin...",
        CHESSPIECE_ROOK =
        {
            GENERIC = "This castle too small.",
            STRUGGLE = "It moving!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "It look like an Ironfolk.",
            STRUGGLE = "It moving!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Pointy.",
            STRUGGLE = "It moving!",
        },
        CHESSPIECE_MUSE = "Scary lady.",
        CHESSPIECE_FORMAL = "Why everyone act weird around this one.",
        CHESSPIECE_HORNUCOPIA = "Full of yummies, florp!",
        CHESSPIECE_PIPE = "Scale-less are weird, florp.",
        CHESSPIECE_DEERCLOPS = "Won't bother us again.",
        CHESSPIECE_BEARGER = "Grrrr!",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Ha ha! Her face!",
        },
        CHESSPIECE_DRAGONFLY = "It all buggy-eyed.",
		CHESSPIECE_MINOTAUR = "It good for scratching scales against.",
        CHESSPIECE_BUTTERFLY = "It so ugly.",
        CHESSPIECE_ANCHOR = "Why made anchor for land, florpt?",
        CHESSPIECE_MOON = "It look just like real thing!",
        CHESSPIECE_CARRAT = "Veggie rat look happy.",
        CHESSPIECE_MALBATROSS = "It very fancy looking statue.",
        CHESSPIECE_CRABKING = "Glurgh, he make crab lady sad!",
        CHESSPIECE_TOADSTOOL = "No more glurp-glurping.",
        CHESSPIECE_STALKER = "Not so spooky now.",
        CHESSPIECE_KLAUS = "Can't chase me anymore!",
        CHESSPIECE_BEEQUEEN = "That what you get, stingy lady!",
        CHESSPIECE_ANTLION = "How she stay so still?",
        CHESSPIECE_BEEFALO = "It just rock, real thing better.",
		CHESSPIECE_KITCOON = "Aww, they having a nap.",
		CHESSPIECE_CATCOON = "It pretty good statue, has dead butterfly!",
        CHESSPIECE_GUARDIANPHASE3 = "Glorp! Oh, it not real.",
        CHESSPIECE_EYEOFTERROR = "Oh no... got dried out, glorp...",
        CHESSPIECE_TWINSOFTERROR = "Ha ha, they just rocks now!",

        CHESSJUNK1 = "It all broken.",
        CHESSJUNK2 = "Didn't do it!!",
        CHESSJUNK3 = "It all messed up.",
		CHESTER = "You weird and fuzzy, but me like you.",
		CHESTER_EYEBONE =
		{
			GENERIC = "Neat!",
			WAITING = "Wake up, florpt!",
		},
		COOKEDMANDRAKE = "Feel bit weird eating veggie with face, florp.",
		COOKEDMEAT = "Don't want it, florp.",
		COOKEDMONSTERMEAT = "Gluuurrrgh.",
		COOKEDSMALLMEAT = "Won't eat it, flurp.",
		COOKPOT =
		{
			COOKING_LONG = "This take foreverrr...",
			COOKING_SHORT = "Will be done quick!",
			DONE = "Time for yums!",
			EMPTY = "Wish there was food inside, flurp.",
			BURNT = "Oops...",
		},
		CORN = "Eat cob for extra crunchy snack, flort.",
		CORN_COOKED = "They 'sploded!",
		CORN_SEEDS = "Make more tasty snacks!",
        CANARY =
		{
			GENERIC = "Yellow birdy.",
			HELD = "Got you, florp!",
		},
        CANARY_POISONED = "What wrong with it?",

		CRITTERLAB = "See something moving inside, florp.",
        CRITTER_GLOMLING = "Good bouncy bug.",
        CRITTER_DRAGONLING = "Green scaly friends stick together, florp!",
		CRITTER_LAMB = "Don't worry, will keep you safe!",
        CRITTER_PUPPY = "Wanna play, flurp?",
        CRITTER_KITTEN = "...Guess you pretty okay, florpt.",
        CRITTER_PERDLING = "Hello birdy!",
		CRITTER_LUNARMOTHLING = "You ugly, but me love you.",

		CROW =
		{
			GENERIC = "It a black bird.",
			HELD = "Will find good new home for you, florp.",
		},
		CUTGRASS = "It grass.",
		CUTREEDS = "Swamp full of useful things, florp.",
		CUTSTONE = "It stone. It cut.",
		DEADLYFEAST = "Shouldn't eat that.", --unimplemented
		DEER =
		{
			GENERIC = "Need haircut, florp.",
			ANTLER = "Deer got pointier.",
		},
        DEER_ANTLER = "Deer horn!",
        DEER_GEMMED = "Something wrong with deer's head!",
		DEERCLOPS = "She not look happy, florp.",
		DEERCLOPS_EYEBALL = "Oooh, want to touch it.",
		EYEBRELLAHAT =	"What it looking at?",
		DEPLETED_GRASS =
		{
			GENERIC = "Leftover grass bits.",
		},
        GOGGLESHAT = "Feel silly, flurp.",
        DESERTHAT = "Hate desert, but this help a bit.",
		DEVTOOL = "Like this!",
		DEVTOOL_NODEV = "Can't do it, flurt.",
		DIRTPILE = "Somebody in there?",
		DIVININGROD =
		{
			COLD = "Not making much noise now, florp.", --singleplayer
			GENERIC = "What this weird box thingy?", --singleplayer
			HOT = "It yelling at me!!", --singleplayer
			WARM = "Noises getting louder.", --singleplayer
			WARMER = "More louder!", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "What this?", --singleplayer
			READY = "It need something...", --singleplayer
			UNLOCKED = "Think it work now!", --singleplayer
		},
		DIVININGRODSTART = "This thing look weird, florp.", --singleplayer
		DRAGONFLY = "Scaled-folk shouldn't fight, florp!",
		ARMORDRAGONFLY = "More scales!!",
		DRAGON_SCALES = "Pretty...",
		DRAGONFLYCHEST = "Like look of this box, florpt.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "Broke it...",
			GENERIC = "Look fancy.", --no gems
			NORMAL = "Has friendly face.", --one gem
			HIGH = "Glorpt!! Too hot!!", --two gems
		},

        HUTCH = "Such cute little face!!",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Hello fishy-fishy!",
            WAITING = "Taking nap?",
        },
		LAVASPIT =
		{
			HOT = "Gluuurgh! Hot rock!",
			COOL = "Just rock now.",
		},
		LAVA_POND = "Too hot for swimming, florp.",
		LAVAE = "Aww, it just a baby.",
		LAVAE_COCOON = "Time for nap.",
		LAVAE_PET =
		{
			STARVING = "Need to find food for you quick!",
			HUNGRY = "Needs snack!",
			CONTENT = "Look happy!",
			GENERIC = "She give warm cuddles.",
		},
		LAVAE_EGG =
		{
			GENERIC = "Something skritching inside.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Need a hug, florp?",
			COMFY = "Feel all warm inside!",
		},
		LAVAE_TOOTH = "Baby lost its first tooth, florp.",

		DRAGONFRUIT = "Pretty fruit, florp.",
		DRAGONFRUIT_COOKED = "Taste like medicine.",
		DRAGONFRUIT_SEEDS = "Make more tasty snacks!",
		DRAGONPIE = "Mmmm this best pie!!",
		DRUMSTICK = "Gluurph...",
		DRUMSTICK_COOKED = "You put bird in fire??",
		DUG_BERRYBUSH = "You come with me, florp.",
		DUG_BERRYBUSH_JUICY = "Taking you home.",
		DUG_GRASS = "Where put this?",
		DUG_MARSH_BUSH = "Little bit of home, florpt.",
		DUG_SAPLING = "Will find good place for you.",
		DURIAN = "Mmm... smell a bit like swamp!",
		DURIAN_COOKED = "Has good stink to it!",
		DURIAN_SEEDS = "Make more tasty snacks!",
		EARMUFFSHAT = "Keep cute webby ears warm.",
		EGGPLANT = "Big purple yummy!",
		EGGPLANT_COOKED = "Brings out purple flavor, flort.",
		EGGPLANT_SEEDS = "Make more tasty snacks!",

		ENDTABLE =
		{
			BURNT = "Fire lady did it, flurt!",
			GENERIC = "Table with ugly flower.",
			EMPTY = "Think fish would look better in there than flower.",
			WILTED = "Fish wouldn't get wilty like this, florp.",
			FRESHLIGHT = "Friendly little light.",
			OLDLIGHT = "Need new light.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "Aaah, it hot!!",
			BURNT = "Bye-bye tree.",
			CHOPPED = "Broke into pieces!",
			POISON = "What you looking at, florp?",
			GENERIC = "It a tree.",
		},
		ACORN = "Little tree seed!",
        ACORN_SAPLING = "Grow up big!",
		ACORN_COOKED = "Yum!",
		BIRCHNUTDRAKE = "Ha ha! It funny!",
		EVERGREEN =
		{
			BURNING = "Supposed to chop tree THEN make campfire, flort.",
			BURNT = "Bye-bye piney tree.",
			CHOPPED = "Tiny piney pieces.",
			GENERIC = "Me ever-green too, florpt!",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Supposed to chop tree THEN make campfire, flort.",
			BURNT = "Bye-bye piney tree.",
			CHOPPED = "Tiny piney pieces.",
			GENERIC = "Tree look skinny, someone should feed it.",
		},
		TWIGGYTREE =
		{
			BURNING = "Bye-bye skinny tree.",
			BURNT = "All burnt up.",
			CHOPPED = "Stumpy, florp.",
			GENERIC = "Skinny tree.",
			DISEASED = "Think it's sick...", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Will grow big someday!",
        TWIGGY_OLD = "Has lived in forest long time.",
		TWIGGY_NUT = "Is baby tree.",
		EYEPLANT = "It keeping an eye out.",
		INSPECTSELF = "Wanna see me make funny face?",
		FARMPLOT =
		{
			GENERIC = "Can make own veggies?!",
			GROWING = "Growing snacks!",
			NEEDSFERTILIZER = "Put poop on it, florp!",
			BURNT = "It too burnt up for growing.",
		},
		FEATHERHAT = "Look like bird, think like bird.",
		FEATHER_CROW = "Black birdy feather.",
		FEATHER_ROBIN = "Red birdy feather.",
		FEATHER_ROBIN_WINTER = "Snowy bird feather.",
		FEATHER_CANARY = "Yellow birdy feather.",
		FEATHERPENCIL = "For fancy writing, florp.",
        COOKBOOK = "Like this one, has pictures of food!",
		FEM_PUPPET = "You stuck?", --single player
		FIREFLIES =
		{
			GENERIC = "Come back, flurp!",
			HELD = "They tickle!",
		},
		FIREHOUND = "Don't like look of that one, flurp.",
		FIREPIT =
		{
			EMBERS = "It dying.",
			GENERIC = "Time for story-tell around fire, florp!",
			HIGH = "Big fire!",
			LOW = "Fire getting small.",
			NORMAL = "Comfy cozy.",
			OUT = "Can make more fire later!",
		},
		COLDFIREPIT =
		{
			EMBERS = "It dying.",
			GENERIC = "Time for story-tell around fire, florp!",
			HIGH = "Big fire!",
			LOW = "Fire getting small.",
			NORMAL = "Chilly fire?",
			OUT = "Can make more fire later!",
		},
		FIRESTAFF = "Fire shooty stick!",
		FIRESUPPRESSOR =
		{
			ON = "Good machine!",
			OFF = "It sleeping.",
			LOWFUEL = "It getting hungry.",
		},

		FISH = "Awwww, it so cute!",
		FISHINGROD = "Grab on, fishes!",
		FISHSTICKS = "Why you do this to fish?!",
		FISHTACOS = "Fish not happy in there...",
		FISH_COOKED = "Fish are friends, not food!",
		FLINT = "Glorph! It sharp!",
		FLOWER =
		{
            GENERIC = "Glurgh, such ugly plant.",
            ROSE = "Creepy, florp.",
        },
        FLOWER_WITHERED = "Good.",
		FLOWERHAT = "Hat ugly, but killing flowers fun!",
		FLOWER_EVIL = "Blegh, even worse than normal flower.",
		FOLIAGE = "Purple one of tastiest colors, florp.",
		FOOTBALLHAT = "Made from hide of enemies, florp.",
        FOSSIL_PIECE = "Spooky bones.",
        FOSSIL_STALKER =
        {
			GENERIC = "Need more spooky bones.",
			FUNNY = "That how he supposed to look?",
			COMPLETE = "...Why we do this again?",
        },
        STALKER = "Glurph! Has bad shadow magic!",
        STALKER_ATRIUM = "Glurp, i-it real!",
        STALKER_MINION = "Little crawlers!",
        THURIBLE = "Weird smell, flort.",
        ATRIUM_OVERGROWTH = "Weird letters make head hurt, florp...",
		FROG =
		{
			DEAD = "He gone to big swamp in the sky.",
			GENERIC = "How you do?",
			SLEEPING = "Night-night, froggy.",
		},
		FROGGLEBUNWICH = "This a bad sandwich.",
		FROGLEGS = "Poor froggy...",
		FROGLEGS_COOKED = "Glurgh... can't look.",
		FRUITMEDLEY = "Fruit meldy... moldy... meddle-y?",
		FURTUFT = "It smell funny.",
		GEARS = "Ironfolk guts.",
		GHOST = "Glorph, go away!",
		GOLDENAXE = "Gold very strong.",
		GOLDENPICKAXE = "It stronger than normal rock cracker.",
		GOLDENPITCHFORK = "For fancy farming, florp.",
		GOLDENSHOVEL = "Fancy tool for digging in dirt.",
		GOLDNUGGET = "Shiny from the ground!",
		GRASS =
		{
			BARREN = "Need some poop.",
			WITHERED = "It too hot out.",
			BURNING = "Fire!!",
			GENERIC = "Some grass, florpt.",
			PICKED = "Not grown back yet.",
			DISEASED = "Looking bit green around the gills, florp.", --unimplemented
			DISEASING = "Something wrong with it.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Should sneak up on it, florp.",
			DISEASED = "Something wrong with grass lizard.", --unimplemented
		},
		GREEN_CAP = "Has nice color, probably tasty.",
		GREEN_CAP_COOKED = "It smell different now.",
		GREEN_MUSHROOM =
		{
			GENERIC = "Best mushroom, florp.",
			INGROUND = "It hiding.",
			PICKED = "All mine!",
		},
		GUNPOWDER = "Splodey powder.",
		HAMBAT = "Use meat for hitting? Never thought of that, florp.",
		HAMMER = "Break everything!",
		HEALINGSALVE = "Feel nice.",
		HEATROCK =
		{
			FROZEN = "It all icy.",
			COLD = "Brrr... chilly.",
			GENERIC = "Lucky rock!",
			WARM = "Snuggly warm, florp.",
			HOT = "Hot rock!",
		},
		HOME = "Anyone there?",
		HOMESIGN =
		{
			GENERIC = "What it say?",
            UNWRITTEN = "Nothing there.",
			BURNT = "Aw well.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "What it say?",
            UNWRITTEN = "Nothing there!",
			BURNT = "Roasty.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "What it say?",
            UNWRITTEN = "Nothing there!",
			BURNT = "It dead.",
		},
		HONEY = "Hello my honey!",
		HONEYCOMB = "Stole this from bees!",
		HONEYHAM = "Ruined honey with Pigmeat!!",
		HONEYNUGGETS = "Wasting honey!",
		HORN = "Toot toot!",
		HOUND = "Bad doggy!",
		HOUNDCORPSE =
		{
			GENERIC = "Weird-looking dog.",
			BURNING = "Glurph, smell bad.",
			REVIVING = "It coming back!",
		},
		HOUNDBONE = "Spiky.",
		HOUNDMOUND = "Found doggy nest, florp.",
		ICEBOX = "Chilly box.",
		ICEHAT = "This a very good hat.",
		ICEHOUND = "Chilly doggy.",
		INSANITYROCK =
		{
			ACTIVE = "Where this come from...?",
			INACTIVE = "Tricky rock...",
		},
		JAMMYPRESERVES = "Got claws all sticky.",

		KABOBS = "Glurgh... yucky meat bits.",
		KILLERBEE =
		{
			GENERIC = "It look mad.",
			HELD = "Nice buzzer...",
		},
		KNIGHT = "Springy Ironfolk.",
		KOALEFANT_SUMMER = "What big ears you have!",
		KOALEFANT_WINTER = "What big ears you have!",
		KRAMPUS = "Big meanie!!",
		KRAMPUS_SACK = "It jingles!",
		LEIF = "Treebeast!!",
		LEIF_SPARSE = "Treebeast!!",
		LIGHTER  = "This very special to fire lady, florp.",
		LIGHTNING_ROD =
		{
			CHARGED = "It sizzling!",
			GENERIC = "Scale-less can call down lightning?",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "Curly-head!",
			CHARGED = "Should run now!",
		},
		LIGHTNINGGOATHORN = "Crackly!",
		GOATMILK = "Zappier than woulda thought, flurp.",
		LITTLE_WALRUS = "Hello, florp! Wanna play?",
		LIVINGLOG = "Feel kinda bad, florp...",
		LOG =
		{
			BURNING = "Campfire!",
			GENERIC = "Can we make campfire?",
		},
		LUCY = "You wood choppy man's friend?",
		LUREPLANT = "Glurgh, why that plant have meat on it??",
		LUREPLANTBULB = "Nasty plant.",
		MALE_PUPPET = "He look stuck!", --single player

		MANDRAKE_ACTIVE = "Glargh! It following me!",
		MANDRAKE_PLANTED = "Supposed to pick those at night, florp.",
		MANDRAKE = "It not moving anymore.",

        MANDRAKESOUP = "Little veggie man make tasty soup.",
        MANDRAKE_COOKED = "Bedtime snack.",
        MAPSCROLL = "Where the pictures?",
        MARBLE = "Big rock chunk.",
        MARBLEBEAN = "Glargh! Ith chippf'd my toof...",
        MARBLEBEAN_SAPLING = "That rock growing?",
        MARBLESHRUB = "Rock bush.",
        MARBLEPILLAR = "It look old.",
        MARBLETREE = "Mr. choppy man, try chop down this tree! Hee-hee...",
        MARSH_BUSH =
        {
			BURNT = "Burnt up.",
            BURNING = "Fire! Fire!",
            GENERIC = "Lots of these in swamp, flort.",
            PICKED = "Ouchie!",
        },
        BURNT_MARSH_BUSH = "It so sad, florp...",
        MARSH_PLANT = "Swamp plant.",
        MARSH_TREE =
        {
            BURNING = "Didn't do it!",
            BURNT = "Burnt up.",
            CHOPPED = "Chopped it all up!",
            GENERIC = "Shouldn't play too close to those, florp.",
        },
        MAXWELL = "He not seem very nice.",--single player
        MAXWELLHEAD = "Glurp! Big head!",--removed
        MAXWELLLIGHT = "Don't like it...",--single player
        MAXWELLLOCK = "Needs key, florpt?",--single player
        MAXWELLTHRONE = "Shouldn't be here...",--single player
        MEAT = "Glargh!",
        MEATBALLS = "Glurgh... hunks of yuck.",
        MEATRACK =
        {
            DONE = "Glurgh, not touching that.",
            DRYING = "Glurgh... it stink.",
            DRYINGINRAIN = "Not sure this thought through, flort.",
            GENERIC = "Scale-less use this for making yucky foods.",
            BURNT = "Oh well, flort.",
            DONE_NOTMEAT = "Look even worse than usual, florp.",
            DRYING_NOTMEAT = "That not look right.",
            DRYINGINRAIN_NOTMEAT = "Thought you said this make things dry?",
        },
        MEAT_DRIED = "It smell bad.",
        MERM = "Hello, flort!",
        MERMHEAD =
        {
            GENERIC = "Who do such thing...",
            BURNT = "Glurp...",
        },
        MERMHOUSE =
        {
            GENERIC = "Home is where the swamp is, florp.",
            BURNT = "Noooooooo!!",
        },
        MINERHAT = "Funny head-light.",
        MONKEY = "Hee-hee, funny monkey.",
        MONKEYBARREL = "Look like a friendly face, florp.",
        MONSTERLASAGNA = "What... in this?",
        FLOWERSALAD = "Look bad, but taste okay.",
        ICECREAM = "Cold treat!",
        WATERMELONICLE = "Chilly melon!",
        TRAILMIX = "Crunch, crunch, crunch!",
        HOTCHILI = "Don't want it, florp!",
        GUACAMOLE = "Yummy green sludge!",
        MONSTERMEAT = "Glurgh, nuh-uh.",
        MONSTERMEAT_DRIED = "Smells even worse now, florp!",
        MOOSE = "This \"Mother Goose\" that Wicker-lady told about?",
        MOOSE_NESTING_GROUND = "This where she keep her babies, florp.",
        MOOSEEGG = "Could crack open and see what inside?",
        MOSSLING = "Hee-hee, funny waddler.",
        FEATHERFAN = "What bird this come from?!",
        MINIFAN = "Hee-hee-hee!",
        GOOSE_FEATHER = "Stole it from goose, florp!",
        STAFF_TORNADO = "Make wind go spinny!",
        MOSQUITO =
        {
            GENERIC = "Wouldn't like my blood, florp!",
            HELD = "Gotcha, nasty pokey bug!",
        },
        MOSQUITOSACK = "Glurgh...",
        MOUND =
        {
            DUG = "Someone left buncha bones in there, florp.",
            GENERIC = "Hmm? Something buried here?",
        },
        NIGHTLIGHT = "Creepy light.",
        NIGHTMAREFUEL = "Bad stuff!",
        NIGHTSWORD = "It made of spooky stuff, florp.",
        NITRE = "Funny rock.",
        ONEMANBAND = "Boom boom boom!",
        OASISLAKE =
		{
			GENERIC = "Water!!",
			EMPTY = "Nooooo! Where water go?!",
		},
        PANDORASCHEST = "What in the box?",
        PANFLUTE = "Plays sleepy music, florp.",
        PAPYRUS = "Make more stories, Wicker-lady!",
        WAXPAPER = "No pictures on this paper!",
        PENGUIN = "They smart birds, would rather swim than fly.",
        PERD = "Grrr, go away gobble-bird!",
        PEROGIES = "Glurgh, hid meat inside??",
        PETALS = "Hee-hee, take that flowers!",
        PETALS_EVIL = "Glurgh, don't wanna carry these.",
        PHLEGM = "Eaten worse, florp.",
        PICKAXE = "Rock cracker.",
        PIGGYBACK = "Made bag from nasty pigskin.",
        PIGHEAD =
        {
            GENERIC = "Ha ha!",
            BURNT = "Crispy Pig!",
        },
        PIGHOUSE =
        {
            FULL = "That house full of nasty Pigfolk!",
            GENERIC = "Sniff... smell like... Pigfolk!",
            LIGHTSOUT = "Coast clear, florp.",
            BURNT = "Hee-hee, pig house all burnt up!",
        },
        PIGKING = "He no King, flort!!",
        PIGMAN =
        {
            DEAD = "Serve you right, flurp.",
            FOLLOWER = "Stay away!",
            GENERIC = "Glurp! Pigfolk...",
            GUARD = "He look even scarier than others.",
            WEREPIG = "Glaaargh!!",
        },
        PIGSKIN = "Took it from nasty Pig!!",
        PIGTENT = "Glurp... there Pigman inside?",
        PIGTORCH = "Grrrr!",
        PINECONE = "Not very good for eating, florp.",
        PINECONE_SAPLING = "Baby tree.",
        LUMPY_SAPLING = "It trying its best, florp.",
        PITCHFORK = "Pokey tool.",
        PLANTMEAT = "Feel... confused...",
        PLANTMEAT_COOKED = "Still not gonna eat it, florp.",
        PLANT_NORMAL =
        {
            GENERIC = "Leafy greens!",
            GROWING = "Ready soon, flort?",
            READY = "Veggies for meee!",
            WITHERED = "Plant need drink of water?",
        },
        POMEGRANATE = "Ohhh, you not supposed to just bite into it?",
        POMEGRANATE_COOKED = "Hmm... okay...",
        POMEGRANATE_SEEDS = "Make more tasty snacks!",
        POND = "Splishy splashy!",
        POOP = "Ha ha, stinky!",
        FERTILIZER = "What? It just some poop.",
        PUMPKIN = "Lumpy and good, florp!",
        PUMPKINCOOKIE = "THIS THE BEST KIND OF PUM-KIN.",
        PUMPKIN_COOKED = "Squishy!",
        PUMPKIN_LANTERN = "Has a friendly face, flort.",
        PUMPKIN_SEEDS = "Make more tasty snacks!",
        PURPLEAMULET = "Glurp... don't wanna play with this anymore.",
        PURPLEGEM = "It pretty...",
        RABBIT =
        {
            GENERIC = "Be vewy vewy quiet.",
            HELD = "Hello, rabbit!",
        },
        RABBITHOLE =
        {
            GENERIC = "Rabbit house.",
            SPRING = "Anybody home, florp?",
        },
        RAINOMETER =
        {
            GENERIC = "Hope rain's coming!",
            BURNT = "Aw well, florp.",
        },
        RAINCOAT = "Why scale-less so scared of rain?",
        RAINHAT = "Rain not scary!",
        RATATOUILLE = "This the best!!",
        RAZOR = "Cutty thing?",
        REDGEM = "It pretty and warm.",
        RED_CAP = "These ones bad for you, florp.",
        RED_CAP_COOKED = "Bit better...",
        RED_MUSHROOM =
        {
            GENERIC = "Hello mushroom!",
            INGROUND = "Come out!",
            PICKED = "None left.",
        },
        REEDS =
        {
            BURNING = "Glurgh!! Swamp burning!",
            GENERIC = "There lots of these in the swamp!",
            PICKED = "Gotta find more, flurp.",
        },
        RELIC = "Old thing.",
        RUINS_RUBBLE = "Rocks and things.",
        RUBBLE = "Rocks and things.",
        RESEARCHLAB =
        {
            GENERIC = "Funny-hair man say \"Science\" come out of it?",
            BURNT = "Aw well.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "All-kemmy... en...jun...",
            BURNT = "Well it gone now.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "Glurp... shouldn't play with that.",
            BURNT = "Glad it gone.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "Think you just made that up, florp.",
            BURNT = "Weird hat machine burned up.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "Is Funny-hair man... okay?",
            BURNT = "Glurgh... it smell real bad.",
        },
        RESURRECTIONSTONE = "This strong magic!",
        ROBIN =
        {
            GENERIC = "Red bird.",
            HELD = "My birdy!",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Snowy bird.",
            HELD = "It like to be pet.",
        },
        ROBOT_PUPPET = "You stuck?", --single player
        ROCK_LIGHT =
        {
            GENERIC = "Don't like it, florp.",--removed
            OUT = "Hmm.",--removed
            LOW = "It getting all rocky.",--removed
            NORMAL = "Glowy!",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "That a big boulder...",
            RAISED = "Can't reach, florp!",
        },
        ROCK = "Just a rock, florpt.",
        PETRIFIED_TREE = "It rock shaped like tree?",
        ROCK_PETRIFIED_TREE = "Rock shaped like tree?",
        ROCK_PETRIFIED_TREE_OLD = "Rock shaped like tree?",
        ROCK_ICE =
        {
            GENERIC = "Brrr, that cold on scales!",
            MELTED = "Slushy puddle.",
        },
        ROCK_ICE_MELTED = "Slushy puddle.",
        ICE = "Brrrr...",
        ROCKS = "Buncha rocks, florp.",
        ROOK = "Look mean...",
        ROPE = "For tying, florpt.",
        ROTTENEGG = "Has good stink to it.",
        ROYAL_JELLY = "Mmmmmmmm!",
        JELLYBEAN = "A good bean.",
        SADDLE_BASIC = "Hee-hee, has little horns on it!",
        SADDLE_RACE = "Butterflies good for something, flort!",
        SADDLE_WAR = "Will fight for glory of Mermfolk!",
        SADDLEHORN = "Get saddle off the big fuzzy.",
        SALTLICK = "What you mean, \"only for beefalo\"?",
        BRUSH = "Hair so weird, flurp.",
		SANITYROCK =
		{
			ACTIVE = "Move, florp!",
			INACTIVE = "Maybe imagined it...",
		},
		SAPLING =
		{
			BURNING = "Fire!",
			WITHERED = "Too dry, florp.",
			GENERIC = "Little tree!",
			PICKED = "Took it!",
			DISEASED = "Hmm... look bad.", --removed
			DISEASING = "Something wrong with it, florp.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Like him very much!",
			BURNING = "Nooooo! Save him!!",
			BURNT = "Glort...",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Make things outta rocks!",
			BLOCK = "Gonna make something good, flort!",
			SCULPTURE = "Look! Made it with own claws!",
			BURNT = "Can't use now.",
   		},
        SCULPTURE_KNIGHTHEAD = "Look like Ironfolk head.",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "What that supposed to be?",
			UNCOVERED = "It broken!",
			FINISHED = "All together!",
			READY = "Something happening...",
		},
        SCULPTURE_BISHOPHEAD = "Look lost, flort.",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Something weird about it.",
			UNCOVERED = "It lost its head, flurp!",
			FINISHED = "All done!",
			READY = "Huh?",
		},
        SCULPTURE_ROOKNOSE = "Hm, think this belong somewhere.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "That a strange lump of rock...",
			UNCOVERED = "Missing something...",
			FINISHED = "Look a bit better, flurt.",
			READY = "Something happening...",
		},
        GARGOYLE_HOUND = "It look surprised.",
        GARGOYLE_WEREPIG = "Glurph. Don't like having this around.",
		SEEDS = "Put in dirt, florp!",
		SEEDS_COOKED = "Teeny snacks!",
		SEWING_KIT = "Glurgh... needle hard to hold with claws...",
		SEWING_TAPE = "Weenowna-lady good at fixing.",
		SHOVEL = "Scooper.",
		SILK = "Spiderfolk loogies!",
		SKELETON = "It dead.",
		SCORCHED_SKELETON = "Got too close to campfire, florp.",
		SKULLCHEST = "Maybe something good inside!", --removed
		SMALLBIRD =
		{
			GENERIC = "It so teeny!",
			HUNGRY = "Wants snack, florp.",
			STARVING = "Look really hungry.",
			SLEEPING = "Sleep tight!",
		},
		SMALLMEAT = "Glurgh...",
		SMALLMEAT_DRIED = "Glargh, it even worse now.",
		SPAT = "He not look comfortable, florp.",
		SPEAR = "Stabby stick!",
		SPEAR_WATHGRITHR = "Took Viking lady's stab stick!!",
		WATHGRITHRHAT = "Will wearing make me strong like Viking lady?",
		SPIDER =
		{
			DEAD = "Not so strong, flort.",
			GENERIC = "Spiderfolk...",
			SLEEPING = "Shhhh...",
		},
		SPIDERDEN = "Glurgh, stepped in sticky stuff!",
		SPIDEREGGSACK = "Blegh, this where baby Spiderfolk come from?",
		SPIDERGLAND = "Medicine!",
		SPIDERHAT = "Ha ha, look like Webby boy.",
		SPIDERQUEEN = "She a mighty Queen!",
		SPIDER_WARRIOR =
		{
			DEAD = "Victory for Mermfolk!",
			GENERIC = "Spiderfolk warrior...",
			SLEEPING = "It dreaming of spider things.",
		},
		SPOILED_FOOD = "Maybe it still good?",
        STAGEHAND =
        {
			AWAKE = "Leeme alone, flort!!",
			HIDING = "Something... weird...",
        },
        STATUE_MARBLE =
        {
            GENERIC = "This rock in a funny shape.",
            TYPE1 = "Missing her head!",
            TYPE2 = "Feels sad, florp.",
            TYPE3 = "Look fancy and boring, florp.", --bird bath type statue
        },
		STATUEHARP = "Someone broke it, florp.",
		STATUEMAXWELL = "Look sort of like fragile scale-less man.",
		STEELWOOL = "Scratchy!",
		STINGER = "Buzzer butt.",
		STRAWHAT = "Itchy...",
		STUFFEDEGGPLANT = "Wha-! Veggie with more veggie inside!?",
		SWEATERVEST = "Scale-less wear so many clothes.",
		REFLECTIVEVEST = "Hm... orange.",
		HAWAIIANSHIRT = "Glurgh, there flowers all over!",
		TAFFY = "MMMMMMMM! ITH THO CHEWY!",
		TALLBIRD = "Leggy bird.",
		TALLBIRDEGG = "Hear something inside!",
		TALLBIRDEGG_COOKED = "Glurgh...",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "You cold?",
			GENERIC = "It hatching!",
			HOT = "Hm... feel hot...",
			LONG = "Why taking so long!!",
			SHORT = "Will be out soon!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "Leggy bird egg!",
			PICKED = "This where leggy bird sleep.",
		},
		TEENBIRD =
		{
			GENERIC = "You not as fun now that you older.",
			HUNGRY = "Wants snacks.",
			STARVING = "Gets cranky when it's hungry.",
			SLEEPING = "Likes taking naps, flort.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Glorp, can always come back, right?", --single player
			GENERIC = "This go to... other worlds?", --single player
			LOCKED = "Something missing, florpt?", --single player
			PARTIAL = "Not done yet?", --single player
		},
		TELEPORTATO_BOX = "Funny box.", --single player
		TELEPORTATO_CRANK = "What this thing?", --single player
		TELEPORTATO_POTATO = "Big metal lump.", --single player
		TELEPORTATO_RING = "Hmm, too big for crown, florp.", --single player
		TELESTAFF = "Make head feel funny, florp...",
		TENT =
		{
			GENERIC = "Sleeping place.",
			BURNT = "It burnt up.",
		},
		SIESTAHUT =
		{
			GENERIC = "Wanna take a nap! Nap right here...",
			BURNT = "Gotta find new napping spot...",
		},
		TENTACLE = "Scale-less always walking into those, florp.",
		TENTACLESPIKE = "Ha ha, spiky!",
		TENTACLESPOTS = "Took its skin!",
		TENTACLE_PILLAR = "Tickle its belly!",
        TENTACLE_PILLAR_HOLE = "What in there?",
		TENTACLE_PILLAR_ARM = "They just little.",
		TENTACLE_GARDEN = "Found its house!",
		TOPHAT = "Oooooh, fancy!",
		TORCH = "Fire stick.",
		TRANSISTOR = "It buzzing! Bees stuck inside?",
		TRAP = "Sneaky!",
		TRAP_TEETH = "Look scary, florp.",
		TRAP_TEETH_MAXWELL = "Glorph! Scary spikes!", --single player
		TREASURECHEST =
		{
			GENERIC = "Oooooh, box for things!",
			BURNT = "Noooo!",
		},
		TREASURECHEST_TRAP = "Treasure!",
		SACRED_CHEST =
		{
			GENERIC = "Wonder what inside?",
			LOCKED = "Hey!",
		},
		TREECLUMP = "Can't go past those because... erm... because.....", --removed

		TRINKET_1 = "Pretty little stones!", --Melted Marbles
		TRINKET_2 = "Why it not toot?!", --Fake Kazoo
		TRINKET_3 = "Grrr, can't... un-knot...!", --Gord's Knot
		TRINKET_4 = "Weird tiny man.", --Gnome
		TRINKET_5 = "Nyoooom!", --Toy Rocketship
		TRINKET_6 = "Weird bendy colored sticks?", --Frazzled Wires
		TRINKET_7 = "This game too hard!", --Ball and Cup
		TRINKET_8 = "Crunchy, florp.", --Rubber Bung
		TRINKET_9 = "These rocks have holes in middle?", --Mismatched Buttons
		TRINKET_10 = "Hee-hee, such short stubby chompers.", --Dentures
		TRINKET_11 = "It say everything gonna be okay!", --Lying Robot
		TRINKET_12 = "Hee-hee, it dead.", --Dessicated Tentacle
		TRINKET_13 = "Weird tiny lady.", --Gnomette
		TRINKET_14 = "For drinking or bath, flort.", --Leaky Teacup
		TRINKET_15 = "Look like... tiny Ironfolk...?", --Pawn
		TRINKET_16 = "Look like... tiny Ironfolk...?", --Pawn
		TRINKET_17 = "Food scooper.", --Bent Spork
		TRINKET_18 = "Something rattling inside.", --Trojan Horse
		TRINKET_19 = "Spin! Spin!", --Unbalanced Top
		TRINKET_20 = "Extra claws for scratching!", --Backscratcher
		TRINKET_21 = "Scale-less have weird inventions, florp.", --Egg Beater
		TRINKET_22 = "Tiny rope?", --Frayed Yarn
		TRINKET_23 = "Not look like a horn, florp.", --Shoehorn
		TRINKET_24 = "Look happy.", --Lucky Cat Jar
		TRINKET_25 = "How get tree so small and flat?", --Air Unfreshener
		TRINKET_26 = "Where all the insides?!", --Potato Cup
		TRINKET_27 = "Has little claw at the end!", --Coat Hanger
		TRINKET_28 = "This castle for ants?", --Rook
        TRINKET_29 = "This castle for ants?", --Rook
        TRINKET_30 = "Look like... tiny Ironfolk...?", --Knight
        TRINKET_31 = "Look like... tiny Ironfolk...?", --Knight
        TRINKET_32 = "Can see cute face in it!", --Cubic Zirconia Ball
        TRINKET_33 = "Who ever seen such tiny Spiderfolk?", --Spider Ring
        TRINKET_34 = "Seem safe, florp.", --Monkey Paw
        TRINKET_35 = "Somebody drank it, florp.", --Empty Elixir
        TRINKET_36 = "Good chompers!", --Faux fangs
        TRINKET_37 = "Didn't break it!! Found like this!", --Broken Stake
        TRINKET_38 = "Can see forever!", -- Binoculars Griftlands trinket
        TRINKET_39 = "Keep one claw warm.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "This snail sleeping.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Warm goop!", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Oooh, fun toy!", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Hee-hee it wear funny clothes!", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Someone broke plant house.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "What it do?", -- Odd Radio ONI trinket
        TRINKET_46 = "Hm...", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Huh? Can't pick it up!",
        LOST_TOY_2  = "Huh? Can't pick it up!",
        LOST_TOY_7  = "Huh? Can't pick it up!",
        LOST_TOY_10 = "Huh? Can't pick it up!",
        LOST_TOY_11 = "Huh? Can't pick it up!",
        LOST_TOY_14 = "Huh? Can't pick it up!",
        LOST_TOY_18 = "Huh? Can't pick it up!",
        LOST_TOY_19 = "Huh? Can't pick it up!",
        LOST_TOY_42 = "Huh? Can't pick it up!",
        LOST_TOY_43 = "Huh? Can't pick it up!",

        HALLOWEENCANDY_1 = "These even better than regular apple, flort!",
        HALLOWEENCANDY_2 = "Made corn even better?!",
        HALLOWEENCANDY_3 = "Corn!!",
        HALLOWEENCANDY_4 = "Didn't know Spiderfolk could be tasty!",
        HALLOWEENCANDY_5 = "Will eat you in one bite, florp!",
        HALLOWEENCANDY_6 = "Taste good to me, florp.",
        HALLOWEENCANDY_7 = "Can eat yours if you don't want them, florp.",
        HALLOWEENCANDY_8 = "Yummy yum!",
        HALLOWEENCANDY_9 = "Even better than normal worm!",
        HALLOWEENCANDY_10 = "Mmm, taste like swamp!",
        HALLOWEENCANDY_11 = "Grrr, will eat you all up!!",
        HALLOWEENCANDY_12 = "Yum yum in the tum-tum!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Mermfolk have jaws of steel!", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Hot-hot, HOT!!", --Hot Lava pepper candy
        CANDYBAG = "Sweets!!",

		HALLOWEEN_ORNAMENT_1 = "Boo! Hee-hee.",
		HALLOWEEN_ORNAMENT_2 = "Can help decorate too, florp!",
		HALLOWEEN_ORNAMENT_3 = "Hee-hee... look just like Webby boy.",
		HALLOWEEN_ORNAMENT_4 = "These not so scary.",
		HALLOWEEN_ORNAMENT_5 = "Mermfolk very fearsome! Where Merm ornament??",
		HALLOWEEN_ORNAMENT_6 = "Pretty bird.",

		HALLOWEENPOTION_DRINKS_WEAK = "Didn't turn out so good...",
		HALLOWEENPOTION_DRINKS_POTENT = "Has strong smell.",
        HALLOWEENPOTION_BRAVERY = "Not scared of anything, flurt!",
		HALLOWEENPOTION_MOON = "Look breakable...",
		HALLOWEENPOTION_FIRE_FX = "Sparkle bottle.",
		MADSCIENCE_LAB = "Bubble, bubble!",
		LIVINGTREE_ROOT = "Still roots left!",
		LIVINGTREE_SAPLING = "Still growing.",

        DRAGONHEADHAT = "Look almost as cute as own face, florp.",
        DRAGONBODYHAT = "Everything go with scales!",
        DRAGONTAILHAT = "Always wanted a tail!",
        PERDSHRINE =
        {
            GENERIC = "Huh? What you want, gobble-bird?",
            EMPTY = "Something go here?",
            BURNT = "It all burnt up, flurt.",
        },
        REDLANTERN = "Hm, it look kinda nice.",
        LUCKY_GOLDNUGGET = "Shiny rock!",
        FIRECRACKERS = "Make big sounds and lights!!",
        PERDFAN = "Feather stick!",
        REDPOUCH = "Something clinking inside.",
        WARGSHRINE =
        {
            GENERIC = "House for gold doggy.",
            EMPTY = "Need some light, flort.",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "All burnt up.",
        },
        CLAYWARG =
        {
        	GENERIC = "Big teeth!",
        	STATUE = "Have weird feeling, florp.",
        },
        CLAYHOUND =
        {
        	GENERIC = "Glurp! Bitey!",
        	STATUE = "Who make you, florp?",
        },
        HOUNDWHISTLE = "It make no sound?",
        CHESSPIECE_CLAYHOUND = "Bad doggy.",
        CHESSPIECE_CLAYWARG = "Grrrr!",

		PIGSHRINE =
		{
            GENERIC = "Who make this??",
            EMPTY = "Not giving you anything, flurt.",
            BURNT = "Good, it gone now.",
		},
		PIG_TOKEN = "Stole Pigman's belt!",
		PIG_COIN = "Shiny pig nose, florp!",
		YOTP_FOOD1 = "Blegh! Has nasty Pig face!",
		YOTP_FOOD2 = "Usually like mud, but that just bad.",
		YOTP_FOOD3 = "This insulting to fish.",

		PIGELITE1 = "Stay away!", --BLUE
		PIGELITE2 = "Grrr, bad Pig!", --RED
		PIGELITE3 = "Nasty Pigman!", --WHITE
		PIGELITE4 = "Enemy of Mermfolk!", --GREEN

		PIGELITEFIGHTER1 = "Stay away!", --BLUE
		PIGELITEFIGHTER2 = "Grrr, bad Pig!", --RED
		PIGELITEFIGHTER3 = "Nasty Pigman!", --WHITE
		PIGELITEFIGHTER4 = "Enemy of Mermfolk!", --GREEN

		CARRAT_GHOSTRACER = "That one creepy, flurp.",

        YOTC_CARRAT_RACE_START = "Veggie race start here!",
        YOTC_CARRAT_RACE_CHECKPOINT = "It show the way!",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "Is the finish place.",
            BURNT = "Awwwwww.",
            I_WON = "Yeah!! Beat you, ha ha!",
            SOMEONE_ELSE_WON = "Glurgh, {winner} cheated...",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Is starting spot for veggie race.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Help veggie rats find way.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Where finish place go?",

		YOTC_SEEDPACKET = "Tiny snacks!",
		YOTC_SEEDPACKET_RARE = "Wonder if it grow into something tasty.",

		MINIBOATLANTERN = "Pretty water floaty.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "It look like veggie rat, flort.",
            EMPTY = "Want presents?",
            BURNT = "Didn't do it!!",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "Hee-hee, my veggie rat gonna be best!",
            RAT = "Go, go!",
            BURNT = "Aww...",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Race wheel.",
            RAT = "Spinny, spinny, spin!",
            BURNT = "Aww...",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "Is very good racing training, flort.",
            RAT = "Getting better, florp!",
            BURNT = "Aww...",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "Hoppy string machine.",
            RAT = "Jump!",
            BURNT = "Aww...",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "Gotta make veggie rat the best!",
        YOTC_CARRAT_GYM_SPEED_ITEM = "For veggie rat.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "Where a good place to put this, flort?",
        YOTC_CARRAT_GYM_REACTION_ITEM = "Glurph, lot of pieces to put together.",

        YOTC_CARRAT_SCALE_ITEM = "Will see which veggie rat is best one!",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "Need to get best veggie rat!",
            CARRAT = "Not very good, flort.",
            CARRAT_GOOD = "Gonna be good racer, florp!",
            BURNT = "Didn't do it!",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Gimme stuff!",
            EMPTY = "Hmm... what it need?",
            BURNT = "Glurgh... now gotta build another one...",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Oooooooh!!",
            OCCUPIED = "Gonna make you soooo pretty!",
            BURNT = "Aww...",
        },
        BEEFALO_GROOMER_ITEM = "Buildy pieces.",

		BISHOP_CHARGE_HIT = "GLOP!",
		TRUNKVEST_SUMMER = "Wearing a nose!",
		TRUNKVEST_WINTER = "Cozy...",
		TRUNK_COOKED = "Blegh!",
		TRUNK_SUMMER = "Got its nose!",
		TRUNK_WINTER = "Fuzzy.",
		TUMBLEWEED = "Where you going?",
		TURKEYDINNER = "Horrible, flort.",
		TWIGS = "Buncha sticks, florp.",
		UMBRELLA = "Umm-brella keep rain away!",
		GRASS_UMBRELLA = "Don't see what so pretty about it.",
		UNIMPLEMENTED = "What that?",
		WAFFLES = "Fluffy sweet squares!",
		WALL_HAY =
		{
			GENERIC = "Will huff and puff and blow wall down!",
			BURNT = "That not how story usually end, flort.",
		},
		WALL_HAY_ITEM = "Wicker-lady has story of house built with straw.",
		WALL_STONE = "Look good, florp!",
		WALL_STONE_ITEM = "Rock pile!",
		WALL_RUINS = "How look so old already, flort?",
		WALL_RUINS_ITEM = "Will make strong wall!",
		WALL_WOOD =
		{
			GENERIC = "Would look nice with some Pig heads.",
			BURNT = "Aww, was nice wall...",
		},
		WALL_WOOD_ITEM = "Nice and sharp, florp.",
		WALL_MOONROCK = "Moon wall!",
		WALL_MOONROCK_ITEM = "Tough rocks.",
		FENCE = "Keep out nasty Pigfolk, florp.",
        FENCE_ITEM = "For building fence!",
        FENCE_GATE = "Oooh smart, put door in fence.",
        FENCE_GATE_ITEM = "For building fence-door!",
		WALRUS = "He look big and important, florp.",
		WALRUSHAT = "Hee-hee, it go with my scales!",
		WALRUS_CAMP =
		{
			EMPTY = "Somebody here before, florp.",
			GENERIC = "Look warm for ice house.",
		},
		WALRUS_TUSK = "Took his tooth!",
		WARDROBE =
		{
			GENERIC = "Can play dress-up!",
            BURNING = "Fire! Fire!!",
			BURNT = "Aww...",
		},
		WARG = "What big teeth he have!",
        WARGLET = "What big teeth he have!",
        
		WASPHIVE = "Look scary... but sweet stuff inside...",
		WATERBALLOON = "Don't worry, won't throw at you... (hee-hee)",
		WATERMELON = "Gimme!!",
		WATERMELON_COOKED = "Roasty melon.",
		WATERMELONHAT = "Think me like fa-shun, florp!",
		WAXWELLJOURNAL = "...Don't like stories in that book.",
		WETGOOP = "Usually like wet goopy things...",
        WHIP = "Whi-chaaa!!",
		WINTERHAT = "It look cozy!",
		WINTEROMETER =
		{
			GENERIC = "Scale-less need this to tell if warm or cold?",
			BURNT = "Okay.",
		},

        WINTER_TREE =
        {
            BURNT = "Was so pretty...",
            BURNING = "Glorph! Put it out!!",
            CANDECORATE = "Never saw such pretty tree!",
            YOUNG = "Grow big!",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "Gotta find pine cone!",
            BURNT = "Oh...",
		},
        WINTER_ORNAMENT = "Oooooh... pretty!",
        WINTER_ORNAMENTLIGHT = "Glowy!",
        WINTER_ORNAMENTBOSS = "These get special place on tree!",
		WINTER_ORNAMENTFORGE = "Have to put that one on tree?",
		WINTER_ORNAMENTGORGE = "...?",

        WINTER_FOOD1 = "MMMM, but what it supposed to be?", --gingerbread cookie
        WINTER_FOOD2 = "This snowflake melt on tongue too!", --sugar cookie
        WINTER_FOOD3 = "Crunchy!", --candy cane
        WINTER_FOOD4 = "Glurgh, what in this?", --fruitcake
        WINTER_FOOD5 = "It not a real log?", --yule log cake
        WINTER_FOOD6 = "Watch! Can put whole thing in mouth!", --plum pudding
        WINTER_FOOD7 = "Mmmmm...", --apple cider
        WINTER_FOOD8 = "This. Best. Thing. Ever.", --hot cocoa
        WINTER_FOOD9 = "Sluuuurrrrp!", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Is big burny thing!",
			COOKING = "It making the food now, florp.",
			ALMOST_DONE_COOKING = "Can eat now? Maybe now? Now?",
			DISH_READY = "FOOD READY!",
		},
		BERRYSAUCE = "Yummy yummy berries!",
		BIBINGKA = "Like this!",
		CABBAGEROLLS = "Cabbage rolled up with more cabbage, flort!",
		FESTIVEFISH = "Someone playing tricks, it just veggies shaped like fish!",
		GRAVY = "Mmmm, is chocolate!",
		LATKES = "Is good and crunchy!",
		LUTEFISK = "Is just potatoes made into fish shape!",
		MULLEDDRINK = "Mmmm, warms up tummy!",
		PANETTONE = "Tasty tasty bread!",
		PAVLOVA = "Fancy cook man call it a mer... mer-ingy... mer-angy...",
		PICKLEDHERRING = "Someone playing tricks, it just veggies shaped like fish!",
		POLISHCOOKIE = "Yummy fruit pockets!",
		PUMPKINPIE = "Mmmmmmmmmm!",
		ROASTTURKEY = "It look like yucky turkey, but smell like veggies?",
		STUFFING = "Tasty bready bits.",
		SWEETPOTATO = "This even better than normal potato!",
		TAMALES = "Mmm, hot veggie bits inside.",
		TOURTIERE = "Mmm, is hot veggie pie!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Is very fancy table.",
			HAS_FOOD = "Ready to eat! Ready to eat!",
			WRONG_TYPE = "That not go there!",
			BURNT = "Aww, feast over?",
		},

		GINGERBREADWARG = "Will eat you all up!",
		GINGERBREADHOUSE = "Anybody home?",
		GINGERBREADPIG = "No mercy for tiny Cookie-Pigfolk!",
		CRUMBS = "Left tasty trail, florp.",
		WINTERSFEASTFUEL = "It look tasty.",

        KLAUS = "You have presents for me?",
        KLAUS_SACK = "Open it! Open it!",
		KLAUSSACKKEY = "Funny-looking antler, florp...",
		WORMHOLE =
		{
			GENERIC = "Something moving?",
			OPEN = "Ha ha! It just toothy tunnel, florp.",
		},
		WORMHOLE_LIMITED = "Not feeling good, florp?",
		ACCOMPLISHMENT_SHRINE = "Done so many things, florp!", --single player
		LIVINGTREE = "It giving me funny look, florp.",
		ICESTAFF = "Magic cold stick.",
		REVIVER = "Glurp! It still moving!",
		SHADOWHEART = "Feel... sad...",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "Ooooh, picture story!",
			LINE_2 = "Can't see pictures, florp.",
			LINE_3 = "Look like... bad things happen.",
			LINE_4 = "This getting scary...",
			LINE_5 = "They had village here.",
		},
        ATRIUM_STATUE = "Glurp... something wrong with it...",
        ATRIUM_LIGHT =
        {
			ON = "Glurp! Scary!",
			OFF = "Need fire?",
		},
        ATRIUM_GATE =
        {
			ON = "Shouldn't have done that!",
			OFF = "Someone broke it.",
			CHARGING = "What happening?!",
			DESTABILIZING = "G-glorp!",
			COOLDOWN = "It over now?",
        },
        ATRIUM_KEY = "This look important!",
		LIFEINJECTOR = "Don't like needles, florp!",
		SKELETON_PLAYER =
		{
			MALE = "Something happen to them...",
			FEMALE = "Something happen to them...",
			ROBOT = "Something happen to them...",
			DEFAULT = "Bye-bye...",
		},
		HUMANMEAT = "Nuh-uh.",
		HUMANMEAT_COOKED = "Glurgh, scale-less smell even worse cooked.",
		HUMANMEAT_DRIED = "Nope.",
		ROCK_MOON = "Moonrock!",
		MOONROCKNUGGET = "Weird rock.",
		MOONROCKCRATER = "Rock need pretty decoration!",
		MOONROCKSEED = "Floaty!",

        REDMOONEYE = "Got something in its eye, florp.",
        PURPLEMOONEYE = "Stop staring, glort!",
        GREENMOONEYE = "Wonder what it sees, flort.",
        ORANGEMOONEYE = "It looking at me, flurp.",
        YELLOWMOONEYE = "What it looking at?",
        BLUEMOONEYE = "Where you looking, flurt?",

        --Arena Event
        LAVAARENA_BOARLORD = "Grrr, will show you!",
        BOARRIOR = "G-glorp... b-big Pigfolk...",
        BOARON = "You kin of Pigfolk??",
        PEGHOOK = "Glurp, bad bug!",
        TRAILS = "He... not so tough looking... glurp.",
        TURTILLUS = "Why not get along, florp?",
        SNAPPER = "Toothy.",
		RHINODRILL = "They not so tough, flort!",
		BEETLETAUR = "Glurt!!",

        LAVAARENA_PORTAL =
        {
            ON = "Bye-bye!",
            GENERIC = "How that door work?",
        },
        LAVAARENA_KEYHOLE = "Something go in there...",
		LAVAARENA_KEYHOLE_FULL = "All done!",
        LAVAARENA_BATTLESTANDARD = "It ok to break it? YEAH!!",
        LAVAARENA_SPAWNER = "Fighty folk keep coming from there.",

        HEALINGSTAFF = "Blegh, ugly stick...",
        FIREBALLSTAFF = "Thwooooom!",
        HAMMER_MJOLNIR = "Extra hitty hammer!",
        SPEAR_GUNGNIR = "Stabby!",
        BLOWDART_LAVA = "Shouldn't play with it... gonna anyway.",
        BLOWDART_LAVA2 = "Look dangerous!",
        LAVAARENA_LUCY = "Loo-cy look different.",
        WEBBER_SPIDER_MINION = "Spiderfolk and Mermfolk truced for now, florp.",
        BOOK_FOSSIL = "What this say, florp?",
		LAVAARENA_BERNIE = "Yay!! Bear come to play!",
		SPEAR_LANCE = "Swirly!",
		BOOK_ELEMENTAL = "What this say, florp?",
		LAVAARENA_ELEMENTAL = "Glurp!! Rock monster!",

   		LAVAARENA_ARMORLIGHT = "Reeds good for hide in... not so good for fight in.",
		LAVAARENA_ARMORLIGHTSPEED = "Hee-hee, it's tickly!",
		LAVAARENA_ARMORMEDIUM = "Made of strong tree skin.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Grrr! Look very fearsome!",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Look light, for working quick!",
		LAVAARENA_ARMORHEAVY = "Made of strong rocks!",
		LAVAARENA_ARMOREXTRAHEAVY = "So safe!! But, glurgh... so heavy...",

		LAVAARENA_FEATHERCROWNHAT = "Hee-hee! Feather head!",
        LAVAARENA_HEALINGFLOWERHAT = "Blegh... have to wear it...?",
        LAVAARENA_LIGHTDAMAGERHAT = "Feel little stronger!",
        LAVAARENA_STRONGDAMAGERHAT = "Hrrraaaaagh!!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "It fill head with healing learning!",
        LAVAARENA_EYECIRCLETHAT = "Has magic eye.",
        LAVAARENA_RECHARGERHAT = "Feel speedy, florp!",
        LAVAARENA_HEALINGGARLANDHAT = "Know it good for me, but gluuurrgghh...",
        LAVAARENA_CROWNDAMAGERHAT = "Extra horns for extra fight!!",

		LAVAARENA_ARMOR_HP = "Feel bit safer, florp.",

		LAVAARENA_FIREBOMB = "BOOOOM!!",
		LAVAARENA_HEAVYBLADE = "This sword almost big as me, florp!",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "That where food goes.",
        	FULL = "It just ate!",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Look creepy...",
		QUAGMIRE_PARK_FOUNTAIN = "Aww... no water to splash in.",

        QUAGMIRE_HOE = "Farming... thing!",

        QUAGMIRE_TURNIP = "Mmm, turnip!",
        QUAGMIRE_TURNIP_COOKED = "Hot turnip!",
        QUAGMIRE_TURNIP_SEEDS = "Wonder what gonna grow?",

        QUAGMIRE_GARLIC = "Make good snack.",
        QUAGMIRE_GARLIC_COOKED = "It smell even better now!",
        QUAGMIRE_GARLIC_SEEDS = "Wonder what gonna grow?",

        QUAGMIRE_ONION = "Can have some? Pleeaaase?",
        QUAGMIRE_ONION_COOKED = "(Sniff) Mmmm...",
        QUAGMIRE_ONION_SEEDS = "Wonder what gonna grow?",

        QUAGMIRE_POTATO = "It a 'tato!",
        QUAGMIRE_POTATO_COOKED = "Tasty 'tatoes.",
        QUAGMIRE_POTATO_SEEDS = "Wonder what gonna grow?",

        QUAGMIRE_TOMATO = "It nice and ripe.",
        QUAGMIRE_TOMATO_COOKED = "Cooked it real good!",
        QUAGMIRE_TOMATO_SEEDS = "Wonder what gonna grow?",

        QUAGMIRE_FLOUR = "This dusty stuff go in food?",
        QUAGMIRE_WHEAT = "It like grass, with hidden snacks!",
        QUAGMIRE_WHEAT_SEEDS = "Wonder what gonna grow?",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Wonder what gonna grow?",

        QUAGMIRE_ROTTEN_CROP = "Don't think big sky mouth would like that, florp.",

		QUAGMIRE_SALMON = "Hello fishy!",
		QUAGMIRE_SALMON_COOKED = "Nooooooo!!",
		QUAGMIRE_CRABMEAT = "(Sniff) poor crab...",
		QUAGMIRE_CRABMEAT_COOKED = "Glurph... can't look.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "There sweet stuff inside!",
			STUMP = "Someone took tree! Not me!",
			TAPPED_EMPTY = "Aww... nothing left.",
			TAPPED_READY = "Mmm, it full of sweet stuff!",
			TAPPED_BUGS = "Blegh, there bugs stuck in the sweet stuff.",
			WOUNDED = "Tree okay?",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "Something about it feel like home.",
			PICKED = "Nothing left for picking.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Smell kinda spicy.",
		QUAGMIRE_SPOTSPICE_GROUND = "Oooh, it taste good!",
		QUAGMIRE_SAPBUCKET = "Holds sweet tree stuff!",
		QUAGMIRE_SAP = "Mmmm, so sweet!!",
		QUAGMIRE_SALT_RACK =
		{
			READY = "There stuff growing on it!",
			GENERIC = "How this supposed to work, florp?",
		},

		QUAGMIRE_POND_SALT = "Blegh, it full of salty water!",
		QUAGMIRE_SALT_RACK_ITEM = "This go over salty pond?",

		QUAGMIRE_SAFE =
		{
			GENERIC = "Wonder what inside this hidey box...",
			LOCKED = "Aww, let me in!!",
		},

		QUAGMIRE_KEY = "Maybe this open those hidey boxes!",
		QUAGMIRE_KEY_PARK = "Not for hidey boxes... what it open?",
        QUAGMIRE_PORTAL_KEY = "Ooooh, look important!",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Ooooh, this where mushrooms grow!",
			PICKED = "No more mushroom...?",
		},
		QUAGMIRE_MUSHROOMS = "Mushrooms very chewy and good.",
        QUAGMIRE_MEALINGSTONE = "Crush into tiny bits!",
		QUAGMIRE_PEBBLECRAB = "Aww, it so cute!",


		QUAGMIRE_RUBBLE_CARRIAGE = "What this thing?",
        QUAGMIRE_RUBBLE_CLOCK = "What happen to it?",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Mermfolk have story passed down... about mouth in the sky...",
        QUAGMIRE_RUBBLE_PUBDOOR = "It all broken.",
        QUAGMIRE_RUBBLE_ROOF = "Was there fight? Look like Goatfolk lose.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "All broken up.",
        QUAGMIRE_RUBBLE_BIKE = "Weird looking thing...",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Hellooooo?",
            "Glurph... it feel spooky here.",
            "Nobody home, flort.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Nobody live here anymore?",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Nobody live here anymore?",
        QUAGMIRE_MERMHOUSE = "Just bit of a fixer upper!",
        QUAGMIRE_SWAMPIG_HOUSE = "Glurgh, it smell like Pigfolk!",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Ha ha! Pig house all broken.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Something weird about that Pigfolk.",
            SLEEPING = "Is asleep?",
        },
        QUAGMIRE_SWAMPIG = "You a weird looking Pigfolk.",

        QUAGMIRE_PORTAL = "Another dead end.",
        QUAGMIRE_SALTROCK = "Tasty rock!",
        QUAGMIRE_SALT = "Shaky shaky!",
        --food--
        QUAGMIRE_FOOD_BURNT = "Glurp, didn't mean to burn it!",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Should give to big mouth in sky!",
            MISMATCH = "Don't think it'll like that, florp.",
            MATCH = "Is good food for sky mouth!",
            MATCH_BUT_SNACK = "Food seem small for such big mouth.",
        },

        QUAGMIRE_FERN = "Is dee-lishuss and newt-rishuss.",
        QUAGMIRE_FOLIAGE_COOKED = "Yummy yum!",
        QUAGMIRE_COIN1 = "Can't eat this, florp!",
        QUAGMIRE_COIN2 = "Ooooh, shiny!",
        QUAGMIRE_COIN3 = "Look extra fancy.",
        QUAGMIRE_COIN4 = "This help me get home!",
        QUAGMIRE_GOATMILK = "Glurgh...",
        QUAGMIRE_SYRUP = "Sticky sweet!",
        QUAGMIRE_SAP_SPOILED = "Glurgh... not so good anymore.",
        QUAGMIRE_SEEDPACKET = "Seeeeeeds!!",

        QUAGMIRE_POT = "Is just normal pot.",
        QUAGMIRE_POT_SMALL = "Bitty pot.",
        QUAGMIRE_POT_SYRUP = "Is for sweet stuff.",
        QUAGMIRE_POT_HANGER = "Put food over fire!",
        QUAGMIRE_POT_HANGER_ITEM = "It help for cooking.",
        QUAGMIRE_GRILL = "Make food hot and tasty.",
        QUAGMIRE_GRILL_ITEM = "Is for making food hot and tasty!",
        QUAGMIRE_GRILL_SMALL = "Teeny food cooker.",
        QUAGMIRE_GRILL_SMALL_ITEM = "Teeny food cooker.",
        QUAGMIRE_OVEN = "Wonder what to cook...",
        QUAGMIRE_OVEN_ITEM = "Food cooker.",
        QUAGMIRE_CASSEROLEDISH = "Not good with breakable things...",
        QUAGMIRE_CASSEROLEDISH_SMALL = "Is so teeny tiny!",
        QUAGMIRE_PLATE_SILVER = "Shiny!",
        QUAGMIRE_BOWL_SILVER = "Can see own cute reflection!",
        QUAGMIRE_CRATE = "Ooooooh, present for me?",

        QUAGMIRE_MERM_CART1 = "Ooooh, what you have?", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "You gimme stuff?", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Don't like it.",
        QUAGMIRE_PARK_ANGEL2 = "Is creepy...",
        QUAGMIRE_PARK_URN = "Cookies inside?",
        QUAGMIRE_PARK_OBELISK = "Big stone thing.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Better be good stuff in here.",
            LOCKED = "Lemme iiiin!!",
        },
        QUAGMIRE_PARKSPIKE = "Look real pointy.",
        QUAGMIRE_CRABTRAP = "Look like little house!",
        QUAGMIRE_TRADER_MERM = "Finally find someone normal!",
        QUAGMIRE_TRADER_MERM2 = "Hello! How you do, florp?",

        QUAGMIRE_GOATMUM = "She seem nice enough.",
        QUAGMIRE_GOATKID = "Hello weird kid! Wanna play?",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Ewww, it dead.",
            GENERIC = "Hello birdy!",
            SLEEPING = "Sleepy bird.",
        },
        QUAGMIRE_LAMP_POST = "Ooooooh, glowy!",

        QUAGMIRE_BEEFALO = "Where all its fluff?",
        QUAGMIRE_SLAUGHTERTOOL = "Huh? What this for?",

        QUAGMIRE_SAPLING = "Baby tree!",
        QUAGMIRE_BERRYBUSH = "Aww, where the berries?!",

        QUAGMIRE_ALTAR_STATUE2 = "What red eyes it have...",
        QUAGMIRE_ALTAR_QUEEN = "She look nice.",
        QUAGMIRE_ALTAR_BOLLARD = "Not that interesting, florp.",
        QUAGMIRE_ALTAR_IVY = "Creepy crawly.",

        QUAGMIRE_LAMP_SHORT = "Is fancy light.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "Rock thrower! Rock thrower!",
        	OFF = "Why it not work?",
        	BURNING = "It look super dangerous now!",
        	BURNT = "Awww...",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "What this thing?",
        	OFF = "Think it tired.",
        	BURNING = "That not right kind of light.",
        	BURNT = "Not gonna help now, florp.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "This box have weird colored branches sticking out.",
        	LOWPOWER = "The little light getting lower...",
        	OFF = "Think it asleep.",
        	BURNING = "Didn't do it!!",
        	BURNT = "Weenowna-lady can build 'nother one, florp!",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "What it do?",
        	LOWPOWER = "It looking tired.",
        	OFF = "It supposed to be doing something?",
        	BURNING = "It supposed to do that, florp?",
        	BURNT = "Oh well.",
        },

        --Wormwood
        COMPOSTWRAP = "(Sniff) Glurgh!!",
        ARMOR_BRAMBLE = "Plant made it!",
        TRAP_BRAMBLE = "Plant trap!",

        BOATFRAGMENT03 = "Bye-bye boat.",
        BOATFRAGMENT04 = "Bye-bye boat.",
        BOATFRAGMENT05 = "Bye-bye boat.",
		BOAT_LEAK = "Don't see this as big problem, florp.",
        MAST = "This for boat?",
        SEASTACK = "Ooooh, big rock!",
        FISHINGNET = "Scoop many fishes.", --unimplemented
        ANTCHOVIES = "Is fish? Or bug?", --unimplemented
        STEERINGWHEEL = "Wurt is captain!!",
        ANCHOR = "Keep boat stuck.",
        BOATPATCH = "Why patch? Let water in, florpt!",
        DRIFTWOOD_TREE =
        {
            BURNING = "Hot! Hot!!",
            BURNT = "Gone now.",
            CHOPPED = "Choppy chop!",
            GENERIC = "It drowned, florp.",
        },

        DRIFTWOOD_LOG = "Floaty log.",

        MOON_TREE =
        {
            BURNING = "Fire! Fire!",
            BURNT = "All burnt up.",
            CHOPPED = "Only stump left.",
            GENERIC = "Trees weird here.",
        },
		MOON_TREE_BLOSSOM = "Glargh, tree was full of flowers.",

        MOONBUTTERFLY =
        {
        	GENERIC = "It slightly less ugly than normal butterflies.",
        	HELD = "Soft...",
        },
		MOONBUTTERFLYWINGS = "Bit dusty.",
        MOONBUTTERFLY_SAPLING = "Tree grow from bug? Me learning lots today!",
        ROCK_AVOCADO_FRUIT = "Ow! Too hard!",
        ROCK_AVOCADO_FRUIT_RIPE = "It ready!",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Made it yummier!",
        ROCK_AVOCADO_FRUIT_SPROUT = "Too little to make fruit yet.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "No fruits here, flort.",
			WITHERED = "It look thirsty.",
			GENERIC = "Huh? Those fruits look like rocks, flort.",
			PICKED = "Grow back now!",
			DISEASED = "It look sick, flurt.", --unimplemented
            DISEASING = "Something wrong with it...", --unimplemented
			BURNING = "Fire! Fire!",
		},
        DEAD_SEA_BONES = "Poor fish, shoulda stayed in water, florp.",
        HOTSPRING =
        {
        	GENERIC = "Swimming hole!",
        	BOMBED = "Look nice and warm!",
        	GLASS = "Pretty!",
			EMPTY = "Nothing here!",
        },
        MOONGLASS = "Glurp! Sharp!",
        MOONGLASS_CHARGED = "Is sharp glowy things.",
        MOONGLASS_ROCK = "Good color, florp.",
        BATHBOMB = "Wanna throw it now!",
        TRAP_STARFISH =
        {
            GENERIC = "Wanna poke it!",
            CLOSED = "Glorp! Tried to eat me!",
        },
        DUG_TRAP_STARFISH = "Will find good spot for you, hee-hee.",
        SPIDER_MOON =
        {
        	GENERIC = "Never seen Spiderfolk like that.",
        	SLEEPING = "Shhh...",
        	DEAD = "Bye-bye!",
        },
        MOONSPIDERDEN = "Extra nasty Spiderfolk!!",
		FRUITDRAGON =
		{
			GENERIC = "It not easy being green.",
			RIPE = "Smell like... fruit?",
			SLEEPING = "It taking a nap.",
		},
        PUFFIN =
        {
            GENERIC = "Fat little bird.",
            HELD = "Got it, flurt!!",
            SLEEPING = "Sleepy bird.",
        },

		MOONGLASSAXE = "Chop extra good, florp!",
		GLASSCUTTER = "Glorp! Sharp!",

        ICEBERG =
        {
            GENERIC = "Watch out, florp!", --unimplemented
            MELTED = "All melty!", --unimplemented
        },
        ICEBERG_MELTED = "All melty!", --unimplemented

        MINIFLARE = "Sparky!",

		MOON_FISSURE =
		{
			GENERIC = "Glurph... head feel funny.",
			NOLIGHT = "ECHO! Echo! Echoooo...",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Still need something.",
            GENERIC = "You need help, florp?",
        },

        MOON_ALTAR_IDOL = "Where you want to go?",
        MOON_ALTAR_GLASS = "It look sad there.",
        MOON_ALTAR_SEED = "You need to go home, flort.",

        MOON_ALTAR_ROCK_IDOL = "Hello?",
        MOON_ALTAR_ROCK_GLASS = "Hello?",
        MOON_ALTAR_ROCK_SEED = "Hello?",

        MOON_ALTAR_CROWN = "Time to go home!",
        MOON_ALTAR_COSMIC = "It saying something...",

        MOON_ALTAR_ASTRAL = "All done, florp!",
        MOON_ALTAR_ICON = "Found you!",
        MOON_ALTAR_WARD = "Glurgh... would be easier if you weren't so heavy.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Make things for water, florp!",
            BURNT = "That seem to happen a lot...",
        },
        BOAT_ITEM = "For travel on the big pond!",
        STEERINGWHEEL_ITEM = "This go on boat?",
        ANCHOR_ITEM = "Can make boat-stopper!",
        MAST_ITEM = "Pieces for boat thing.",
        MUTATEDHOUND =
        {
        	DEAD = "Bye-bye doggy.",
        	GENERIC = "Glurph, it look sick?",
        	SLEEPING = "Shouldn't wake it up, florp.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "That better, florp.",
			GENERIC = "Glorp, can see its insides!",
			SLEEPING = "Night-night scary bird.",
		},
        CARRAT =
        {
        	DEAD = "It not moving anymore.",
        	GENERIC = "What that?",
        	HELD = "Food or pet, florp?",
        	SLEEPING = "It sleeping now.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Water snack!",
            PICKED = "Will come back later, florp.",
        },
		BULLKELP_ROOT = "Plant more water snacks!",
        KELPHAT = "Would rather eat than wear, florp.",
		KELP = "Sea snack!",
		KELP_COOKED = "Mmmm, slimy!",
		KELP_DRIED = "Salty crunchies.",

		GESTALT = "They want to tell story.",
        GESTALT_GUARD = "Not as strong as Mermfold guard, florp!",

		COOKIECUTTER = "It look friendly.",
		COOKIECUTTERSHELL = "Ha ha! Mine now!",
		COOKIECUTTERHAT = "Make good spiky hat!",
		SALTSTACK =
		{
			GENERIC = "Weird rocks, florp.",
			MINED_OUT = "Nothing left for taking.",
			GROWING = "It growing!",
		},
		SALTROCK = "Weird rock.",
		SALTBOX = "Good place for hiding tasty things.",

		TACKLESTATION = "That not how you treat fish, florp!",
		TACKLESKETCH = "Ooooh, pictures!",

        MALBATROSS = "Bad bird!",
        MALBATROSS_FEATHER = "Stole it from the bad bird!",
        MALBATROSS_BEAK = "Squawk! Squawk! Hee-hee...",
        MAST_MALBATROSS_ITEM = "Birdy sail!",
        MAST_MALBATROSS = "Make boat fly! No? Aww...",
		MALBATROSS_FEATHERED_WEAVE = "Made from bird!",

        GNARWAIL =
        {
            GENERIC = "You a weird looking fish, florp.",
            BROKENHORN = "Broken horn not so bad!",
            FOLLOWER = "We friends now!",
            BROKENHORN_FOLLOWER = "Broken horn not so bad!",
        },
        GNARWAIL_HORN = "Ha ha! Mine now!",

        WALKINGPLANK = "Jumpy board!",
        OAR = "Make boat go!",
		OAR_DRIFTWOOD = "Make boat go!",

		OCEANFISHINGROD = "Gonna catch fish from the big water, florp!",
		OCEANFISHINGBOBBER_NONE = "Need something...",
        OCEANFISHINGBOBBER_BALL = "Bobby floaty!",
        OCEANFISHINGBOBBER_OVAL = "Bobby floaty!",
		OCEANFISHINGBOBBER_CROW = "Feather floaty!",
		OCEANFISHINGBOBBER_ROBIN = "Feather floaty!",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "Feather floaty!",
		OCEANFISHINGBOBBER_CANARY = "Feather floaty!",
		OCEANFISHINGBOBBER_GOOSE = "Big feather floaty!",
		OCEANFISHINGBOBBER_MALBATROSS = "Big feather floaty!",

		OCEANFISHINGLURE_SPINNER_RED = "Won't hurt fish, will it?",
		OCEANFISHINGLURE_SPINNER_GREEN = "Won't hurt fish, will it?",
		OCEANFISHINGLURE_SPINNER_BLUE = "Won't hurt fish, will it?",
		OCEANFISHINGLURE_SPOON_RED = "Won't hurt fish, will it?",
		OCEANFISHINGLURE_SPOON_GREEN = "Won't hurt fish, will it?",
		OCEANFISHINGLURE_SPOON_BLUE = "Won't hurt fish, will it?",
		OCEANFISHINGLURE_HERMIT_RAIN = "Can play with fish friends in rain!",
		OCEANFISHINGLURE_HERMIT_SNOW = "Can play with fish friends in snow!",
		OCEANFISHINGLURE_HERMIT_DROWSY = "This one not very nice...",
		OCEANFISHINGLURE_HERMIT_HEAVY = "Ooooooh, can catch big fishy!",

		OCEANFISH_SMALL_1 = "Aww, so little!",
		OCEANFISH_SMALL_2 = "Will be new pet! And will feed it and love it and squeeze it!",
		OCEANFISH_SMALL_3 = "Hi little fishy!",
		OCEANFISH_SMALL_4 = "Little baby fishy!",
		OCEANFISH_SMALL_5 = "Hee-hee, looks silly!",
		OCEANFISH_SMALL_6 = "Makes crunchy sounds!",
		OCEANFISH_SMALL_7 = "Is ugly fish, but still like it!",
		OCEANFISH_SMALL_8 = "Ow! Is hot!",
        OCEANFISH_SMALL_9 = "Can spit far too! Watch! Pt-ooey!",

		OCEANFISH_MEDIUM_1 = "Goopy!",
		OCEANFISH_MEDIUM_2 = "Has such big pretty eyes!",
		OCEANFISH_MEDIUM_3 = "Look like it has little spiky crown on head!",
		OCEANFISH_MEDIUM_4 = "Will you be new pet?",
		OCEANFISH_MEDIUM_5 = "Feel... weird mixed feeling about this one, florp.",
		OCEANFISH_MEDIUM_6 = "You very pretty, florp.",
		OCEANFISH_MEDIUM_7 = "Like your scales, flort!",
		OCEANFISH_MEDIUM_8 = "Brrrr, chilly fishy!",
        OCEANFISH_MEDIUM_9 = "Aww, you so sweet!",

		PONDFISH = "Awwww, it so cute!",
		PONDEEL = "Hello long fishy!",

        FISHMEAT = "No!!",
        FISHMEAT_COOKED = "Won't eat it!",
        FISHMEAT_SMALL = "Was so little...",
        FISHMEAT_SMALL_COOKED = "Glurgh... who do such thing!",
		SPOILED_FISH = "Someone not take care of fish pet!",

		FISH_BOX = "This where scale-less keep fish pets, florp?",
        POCKET_SCALE = "Is funny measure thing.",

		TACKLECONTAINER = "What this for?",
		SUPERTACKLECONTAINER = "Is dangerous, full of fish snacks with hooks on them!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "This good home for fish!",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nOoooh, so big!",
			BURNING = "AAAAAH! NOOOO!",
			BURNT = "(Sniff) Poor fish home...",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nHee-hee. My fish best.",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nIs biggest fish ever!",
		},

		OCEANFISHABLEFLOTSAM = "Oooh! Found mud!",

		CALIFORNIAROLL = "Wait... there fish in here!",
		SEAFOODGUMBO = "Fish looks so sad in there...",
		SURFNTURF = "Blegh! Don't want it!",

        WOBSTER_SHELLER = "No pinching!",
        WOBSTER_DEN = "Hey! Come out!",
        WOBSTER_SHELLER_DEAD = "Is sleeping?",
        WOBSTER_SHELLER_DEAD_COOKED = "Ewww, it all pink now!",

        LOBSTERBISQUE = "Glurgh... what in this?",
        LOBSTERDINNER = "Don't want it.",

        WOBSTER_MOONGLASS = "Got moon stuff all over it, florp!",
        MOONGLASS_WOBSTER_DEN = "Think saw something move in there.",

		TRIDENT = "Pokey poke!",

		WINCH =
		{
			GENERIC = "Treasure grabber!",
			RETRIEVING_ITEM = "Got something! Got something!",
			HOLDING_ITEM = "Huh? What is it?",
		},

        HERMITHOUSE = {
            GENERIC = "Is very nice home.",
            BUILTUP = "Crabby lady's house got taller!",
        },

        SHELL_CLUSTER = "Tried biting, isn't food.",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "Is big shell!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Pretty!",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Think there some kind of bug inside?",
        },

        CHUM = "Eat up, fishies!",

        SUNKENCHEST =
        {
            GENERIC = "Seashell is good for hiding things, florpt!",
            LOCKED = "Grrr, open up!",
        },

        HERMIT_BUNDLE = "Presents!",
        HERMIT_BUNDLE_SHELLS = "Full of pretty shells!",

        RESKIN_TOOL = "Change things to... different things!",
        MOON_FISSURE_PLUGGED = "Bad moon things can't get out, florp!",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Me want turn to ride!",
            "Me want turn to ride!",
        },
        WOBYSMALL =
        {
            "Aww, hey doggie!",
            "Aww, hey doggie!",
        },
		WALTERHAT = "Is good color.",
		SLINGSHOT = "Hee-hee, look fun!",
		SLINGSHOTAMMO_ROCK = "Bits of stuff.",
		SLINGSHOTAMMO_MARBLE = "Bits of stuff.",
		SLINGSHOTAMMO_THULECITE = "Bits of stuff.",
        SLINGSHOTAMMO_GOLD = "Bits of stuff.",
        SLINGSHOTAMMO_SLOW = "Bits of stuff.",
        SLINGSHOTAMMO_FREEZE = "Bits of stuff.",
		SLINGSHOTAMMO_POOP = "Tiny poops.",
        PORTABLETENT = "Is sleeping place.",
        PORTABLETENT_ITEM = "Building something, florp?",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Someone drew bunch of flies stuck in Spiderfolk webs, florpt.",
        BATTLESONG_HEALTHGAIN = "Someone drew bunch of flies stuck in Spiderfolk webs, florpt.",
        BATTLESONG_SANITYGAIN = "Someone drew bunch of flies stuck in Spiderfolk webs, florpt.",
        BATTLESONG_SANITYAURA = "Someone drew bunch of flies stuck in Spiderfolk webs, florpt.",
        BATTLESONG_FIRERESISTANCE = "Someone drew bunch of flies stuck in Spiderfolk webs, florpt.",
        BATTLESONG_INSTANT_TAUNT = "Glurgh... these words really hard...",
        BATTLESONG_INSTANT_PANIC = "Glurgh... these words really hard...",

        -- Webber
        MUTATOR_WARRIOR = "Webby boy make Merm cookie next!!",
        MUTATOR_DROPPER = "Webby boy make Merm cookie next!!",
        MUTATOR_HIDER = "Webby boy make Merm cookie next!!",
        MUTATOR_SPITTER = "Webby boy make Merm cookie next!!",
        MUTATOR_MOON = "Webby boy make Merm cookie next!!",
        MUTATOR_HEALER = "Webby boy make Merm cookie next!!",
        SPIDER_WHISTLE = "It tickly!",
        SPIDERDEN_BEDAZZLER = "What you making Webby boy?",
        SPIDER_HEALER = "Glurgh, dusty spider!",
        SPIDER_REPELLENT = "It goes clicky-clacky-clak!",
        SPIDER_HEALER_ITEM = "Glurgh, have funny smell.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "Ooooh! Me wanna make some too, florp!",
		GHOSTLYELIXIR_FASTREGEN = "Ooooh! Me wanna make some too, florp!",
		GHOSTLYELIXIR_SHIELD = "Ooooh! Me wanna make some too, florp!",
		GHOSTLYELIXIR_ATTACK = "Ooooh! Me wanna make some too, florp!",
		GHOSTLYELIXIR_SPEED = "Ooooh! Me wanna make some too, florp!",
		GHOSTLYELIXIR_RETALIATION = "Ooooh! Me wanna make some too, florp!",
		SISTURN =
		{
			GENERIC = "What in jar? Snacks?",
			SOME_FLOWERS = "Scaleless like putting flowers here.",
			LOTS_OF_FLOWERS = "So is... not snack jar?",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Put food inside and different food come out, florp?",
            DONE = "Wow!",

			COOKING_LONG = "This take too long!",
			COOKING_SHORT = "Food! Food! Food!",
			EMPTY = "Huh? Nothing in here!",
        },

        PORTABLEBLENDER_ITEM = "Shaky shaky!",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Put flavor bits on foodthings!",
            DONE = "All done!",
        },
        SPICEPACK = "Keep foods inside!",
        SPICE_GARLIC = "Mmmm make breath smell nice.",
        SPICE_SUGAR = "YUM!!",
        SPICE_CHILI = "Hot bits!",
        SPICE_SALT = "This sand taste good!",
        MONSTERTARTARE = "Fancy name not make it better, flort.",
        FRESHFRUITCREPES = "Fancy fruit pancake!",
        FROGFISHBOWL = ".........",
        POTATOTORNADO = "Hee-hee, spinny potato!",
        DRAGONCHILISALAD = "Mmmm, thank you fancy cook man!",
        GLOWBERRYMOUSSE = "Oooh, it glowing!!",
        VOLTGOATJELLY = "Ooooooh, it jiggly!",
        NIGHTMAREPIE = "Hee-hee, it has funny face.",
        BONESOUP = "Don't want it, florp.",
        MASHEDPOTATOES = "Mushy mash!",
        POTATOSOUFFLE = "Wha-? This potato!!",
        MOQUECA = "There fish inside!",
        GAZPACHO = "Goopy!",
        ASPARAGUSSOUP = "Mmmm...",
        VEGSTINGER = "Fancy spicy juice!",
        BANANAPOP = "Fruit taste even better on stick!",
        CEVICHE = "Blegh. Nuh-uh.",
        SALSA = "Spicy veggie mush!",
        PEPPERPOPPER = "Where the \"pop\", flort? It just spicy!",

        TURNIP = "Crunchy snack!",
        TURNIP_COOKED = "Roasty!",
        TURNIP_SEEDS = "Make more tasty snacks!",

        GARLIC = "Make breath smell nice.",
        GARLIC_COOKED = "Mmm... hot smelly snack!",
        GARLIC_SEEDS = "Make more tasty snacks!",

        ONION = "Mmm-mmmm, crunchy!",
        ONION_COOKED = "Smell so good, florp!",
        ONION_SEEDS = "Make more tasty snacks!",

        POTATO = "Good dirt veggie.",
        POTATO_COOKED = "Mmm, hot potato!",
        POTATO_SEEDS = "Put in ground!",

        TOMATO = "Big juicy tomato!",
        TOMATO_COOKED = "Squishy.",
        TOMATO_SEEDS = "Make more tasty snacks!",

        ASPARAGUS = "Snack sticks!",
        ASPARAGUS_COOKED = "Hot snack sticks!",
        ASPARAGUS_SEEDS = "Make more snacks, florp!",

        PEPPER = "Glaaagh! Mouth on fire!",
        PEPPER_COOKED = "Why make pepper even hotter?",
        PEPPER_SEEDS = "Make more tasty snacks!",

        WEREITEM_BEAVER = "There something spilling out its belly.",
        WEREITEM_GOOSE = "Wanna play with doll!",
        WEREITEM_MOOSE = "Wicker-lady say should eat with mouth closed.",

        MERMHAT = "Make scale-less look like friendly Mermfolk!",
        MERMTHRONE =
        {
            GENERIC = "Good seat for Merm King!",
            BURNT = "WHO DO THIS?!",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "There lots of Kings in fairy stories... look easy to make!",
            BURNT = "NOOOOOO!!",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Made it with own claws!",
            BURNT = "WHYYYYY!?",
        },

        MERMWATCHTOWER_REGULAR = "Need royal guard to protect new King!",
        MERMWATCHTOWER_NOKING = "Royal guard need King to protect...",
        MERMKING = "Yay! You look just like Kings from fairy stories!",
        MERMGUARD = "Will grow up big and strong like that one day!",
        MERM_PRINCE = "Need to fatten up if you gonna be proper King!",

        SQUID = "Stay still, little squiddies!",

		GHOSTFLOWER = "Spooky!",
        SMALLGHOST = "Glurp! Y-you not scare me!",

        CRABKING =
        {
            GENERIC = "Glurp... he kinda cranky.",
            INERT = "Castle not very pretty yet.",
        },
		CRABKING_CLAW = "Go away! No pinching!",

		MESSAGEBOTTLE = "Wicker-lady!! Read what it say!",
		MESSAGEBOTTLEEMPTY = "There nothing in here!",

        MEATRACK_HERMIT =
        {
            DONE = "Crabby lady! Nasty dry stuff ready now!",
            DRYING = "Crabby lady! Nasty dry stuff ready now!",
            DRYINGINRAIN = "Not sure this thought through, flort.",
            GENERIC = "These belong to crabby lady, florp.",
            BURNT = "Oh well, flort.",
            DONE_NOTMEAT = "Look even worse than usual, florp.",
            DRYING_NOTMEAT = "That not look right.",
            DRYINGINRAIN_NOTMEAT = "Thought you said this make things dry?",
        },
        BEEBOX_HERMIT =
        {
            READY = "It look full of sweet stuff now!",
            FULLHONEY = "It look full of sweet stuff now!",
            GENERIC = "Crabby lady made nice bee house, flort!",
            NOHONEY = "Aww no sweets inside.",
            SOMEHONEY = "Don't wanna wait!!",
            BURNT = "It not buzzing anymore...",
        },

        HERMITCRAB = "Hee-hee, she funny.",

        HERMIT_PEARL = "Oooooh, so shiny!",
        HERMIT_CRACKED_PEARL = "D-didn't do it!",

        -- DSEAS
        WATERPLANT = "Big ugly flower.",
        WATERPLANT_BOMB = "Glurph! Flower is mean!",
        WATERPLANT_BABY = "Ugly baby flower.",
        WATERPLANT_PLANTER = "Maybe we just throw it into the big pond, florp.",

        SHARK = "Glurp... they not look very nice.",

        MASTUPGRADE_LAMP_ITEM = "Tall boat light!",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "Lightning catcher!",

        WATERPUMP = "Splashy splashy!",

        BARNACLE = "They hiding in shell.",
        BARNACLE_COOKED = "Glurgh!",

        BARNACLEPITA = "Don't like it!",
        BARNACLESUSHI = "Glurph...",
        BARNACLINGUINE = "Nuh-uh, not eating that.",
        BARNACLESTUFFEDFISHHEAD = "Who make this terrible thing?!",

        LEAFLOAF = "Nuh-uh.",
        LEAFYMEATBURGER = "Glurph, not real veggie!",
        LEAFYMEATSOUFFLE = "Smell funny... not gonna eat it.",
        MEATYSALAD = "Don't think this real veggies!",

        -- GROTTO

		MOLEBAT = "Don't trust its big piggy nose.",
        MOLEBATHILL = "Maybe there treasures inside!",

        BATNOSE = "Glurph... don't like it.",
        BATNOSE_COOKED = "Nuh-uh.",
        BATNOSEHAT = "Weird hat.",

        MUSHGNOME = "Hee-hee, silly spinny mushroom.",

        SPORE_MOON = "Explodey floaty fluffs!",

        MOON_CAP = "Glurgh, make eyes feel heavy.",
        MOON_CAP_COOKED = "Taste diffent now.",

        MUSHTREE_MOON = "Mushrooms weird here.",

        LIGHTFLIER = "Follow me, glowy bug!",

        GROTTO_POOL_BIG = "Spiky water!",
        GROTTO_POOL_SMALL = "Spiky water!",

        DUSTMOTH = "Hee-hee, tickly!",

        DUSTMOTHDEN = "Any sweepy bugs in there?",

        ARCHIVE_LOCKBOX = "Grrr, how get it open?!",
        ARCHIVE_CENTIPEDE = "Glurp! Never see Ironfolk like that before!",
        ARCHIVE_CENTIPEDE_HUSK = "Buncha Ironfolk bits.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "This take foreverrr...",
            COOKING_SHORT = "Will be done quick!",
            DONE = "Time for yums!",
            EMPTY = "It old and dusty.",
            BURNT = "Oops...",
        },

        ARCHIVE_MOON_STATUE = "Look just like moon!",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "Glorph... it too hard to read.",
            LINE_2 = "Someone read story!",
            LINE_3 = "Glorph... it too hard to read.",
            LINE_4 = "Someone read story!",
            LINE_5 = "Glorph... it too hard to read.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "Glorph! What it doing?!",
            IDLE = "It not point way anymore.",
        },

        ARCHIVE_RESONATOR_ITEM = "Wonder why it so important, florp?",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "Weird statue.",
          GENERIC =  "Funny-hair man say it full of \"gnaw-ledge\".",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "It fancy.",
            GENERIC = "Ooooh, got more fancy!",
        },

        ARCHIVE_SECURITY_PULSE = "Floaty glowy! Come back!",

        ARCHIVE_SWITCH = {
            VALID = "Shiny!",
            GEMS = "It missing a shiny...",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "It look like pond, but not.",
            GENERIC = "Still not pond.",
        },

        WALL_STONE_2 = "Look good, florp!",
        WALL_RUINS_2 = "How look so old already, flort?",

        REFINED_DUST = "Made dusty block, florpt.",
        DUSTMERINGUE = "Throw it on floor, then don't have to eat it.",

        SHROOMCAKE = "It best cake ever!",

        NIGHTMAREGROWTH = "Glurp... something bad happening!",

        TURFCRAFTINGSTATION = "Yay! Can make so much more swamp, florp!",

        MOON_ALTAR_LINK = "What inside? Wanna see!",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Look like nice warm place to nap.",
            WET = "Gooshy.",
            DRY = "Glurgh, is too dry.",
            BALANCED = "It good!",
            BURNT = "Who did it?!",
        },
        COMPOST = "Plant snacks.",
        SOIL_AMENDER =
		{
			GENERIC = "Look kinda tasty, florp.",
			STALE = "Good and stinky!",
			SPOILED = "Ready for plants now?",
		},

		SOIL_AMENDER_FERMENTED = "It ready!",

        WATERINGCAN =
        {
            GENERIC = "Splishy splashy can.",
            EMPTY = "Hey, no water in here!",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "Splishy birdy can.",
            EMPTY = "Hey, where water go?",
        },

		FARM_PLOW = "It fighting the dirt!",
		FARM_PLOW_ITEM = "Scaleless use it to make \"guard-in.\"",
		FARM_HOE = "Make hole for baby plants.",
		GOLDEN_FARM_HOE = "Fancy digger for baby plants, florp.",
		NUTRIENTSGOGGLESHAT = "Extra shiny plant learning hat!",
		PLANTREGISTRYHAT = "Wear plant on head to learn about plant? Make sense, florp!",

        FARM_SOIL_DEBRIS = "This spot not for you! Out!",

		FIRENETTLES = "Don't like them...",
		FORGETMELOTS = "Glurgh. Is another flower.",
		SWEETTEA = "Mmm... is nice.",
		TILLWEED = "What is difference between weeds and other plants?",
		TILLWEEDSALVE = "See? Weeds more useful than flowers.",
        WEED_IVY = "It pretty!",
        IVY_SNARE = "It warrior plant.",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Mine gonna win!",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nMaybe take teeny little bite...",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nWanna eat it... anyone looking, florp?",
            HAS_ITEM_LIGHT = "Hey! Why it not working, florp?",
			BURNING = "Aaah! Who did it?!",
			BURNT = "Aww...",
        },

        CARROT_OVERSIZED = "Is big buncha roots!",
        CORN_OVERSIZED = "Big crunchy!",
        PUMPKIN_OVERSIZED = "Grew so big!",
        EGGPLANT_OVERSIZED = "Mmmm mine!",
        DURIAN_OVERSIZED = "YAY!!",
        POMEGRANATE_OVERSIZED = "Big juicy snack!",
        DRAGONFRUIT_OVERSIZED = "All mine, florp!",
        WATERMELON_OVERSIZED = "Mmmm big tasty.",
        TOMATO_OVERSIZED = "Big squishy snack.",
        POTATO_OVERSIZED = "Big 'tato!",
        ASPARAGUS_OVERSIZED = "Is tree? Or snack?",
        ONION_OVERSIZED = "Maybe will take little bite while nobody looking...",
        GARLIC_OVERSIZED = "Is big and crunchy and all for me!",
        PEPPER_OVERSIZED = "That gonna be real hot, florp.",

        VEGGIE_OVERSIZED_ROTTEN = "Blegh! No good!",

		FARM_PLANT =
		{
			GENERIC = "It just plant.",
			SEED = "Grow fast!",
			GROWING = "This taking too long. Hungry now!",
			FULL = "Mine!",
			ROTTEN = "Aww, was gonna eat that...",
			FULL_OVERSIZED = "Big snack! All mine!",
			ROTTEN_OVERSIZED = "Blegh! No good!",
			FULL_WEED = "It a weed!",

			BURNING = "Glurp! Fire!",
		},

        FRUITFLY = "Nasty bug! Go away!",
        LORDFRUITFLY = "Grrr, go away! Those plants mine!",
        FRIENDLYFRUITFLY = "It seem ok. Will keep eye on it though, florpt.",
        FRUITFLYFRUIT = "Come with me fruit bug!",

        SEEDPOUCH = "Stuff seeds inside.",

		-- Crow Carnival
		CARNIVAL_HOST = "Ooooh, is fancy Birdfolk.",
		CARNIVAL_CROWKID = "How you grow so big, flort?",
		CARNIVAL_GAMETOKEN = "Shiny!",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "Birdfolk give prize for these?!",
			GENERIC_SMALLSTACK = "Need more! Need more!",
			GENERIC_LARGESTACK = "Gonna get biggest prize ever!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "Where that go, florp?",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "Won't play without shiny thing...",
			PLAYING = "Why feeding fake birdies fake worms?",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "It not look so hard to make, flort.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Me not eat worms!",

		CARNIVALGAME_MEMORY_KIT = "It not look so hard to make, flort.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "Won't play without shiny thing...",
			PLAYING = "Glurgh... not very good with counting...",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "Where that go, florp?",
			PLAYING = "Is this one!",
		},

		CARNIVALGAME_HERDING_KIT = "It not look so hard to make, flort.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "Won't play without shiny thing...",
			PLAYING = "How eggs run around so fast?",
		},
		CARNIVALGAME_HERDING_CHICK = "Grrr, no run away egg!",

		CARNIVAL_PRIZEBOOTH_KIT = "Want prizes!",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Gimme prize!!",
		},

		CARNIVALCANNON_KIT = "Gonna build it real good, florp!",
		CARNIVALCANNON =
		{
			GENERIC = "Esplode! Esplode!!",
			COOLDOWN = "Wheee! Pretty!",
		},

		CARNIVAL_PLAZA_KIT = "Never see tree like that, florp.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Need more fun stuff around!",
			LEVEL_2 = "Birdfolk like shiny decorations, florp.",
			LEVEL_3 = "All pretty!",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "Gonna build it real good, florp!",
		CARNIVALDECOR_EGGRIDE = "Hee-hee, faster! Faster!!",

		CARNIVALDECOR_LAMP_KIT = "Gonna build it real good, florp!",
		CARNIVALDECOR_LAMP = "How little light ball float like that?",
		CARNIVALDECOR_PLANT_KIT = "Where put little tree?",
		CARNIVALDECOR_PLANT = "How tree stay so small?",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "Ooooh, it look different!",
			UNCOMMON = "Not snack, but still good.",
			GENERIC = "Can eat it? No? Aww...",
		},
		CARNIVALDECOR_FIGURE_KIT = "Open up!",

        CARNIVAL_BALL = "Mine!! Hee-hee-hee!", --unimplemented
		CARNIVAL_SEEDPACKET = "Mmmm, crunchy snack.",
		CARNIVALFOOD_CORNTEA = "Mmm! Want more!",

        CARNIVAL_VEST_A = "Hee-hee, look like pine boy!",
        CARNIVAL_VEST_B = "Is cam... cam-oo... cam-oo-flodge!",
        CARNIVAL_VEST_C = "Look just like Birdfolk.",

        -- YOTB
        YOTB_SEWINGMACHINE = "Make fancy dress-up things!",
        YOTB_SEWINGMACHINE_ITEM = "Bits of things.",
        YOTB_STAGE = "Has weird scale-less hiding inside.",
        YOTB_POST =  "Big fancy stick.",
        YOTB_STAGE_ITEM = "Someone left stuff on ground.",
        YOTB_POST_ITEM =  "Mermfolk great at building.",


        YOTB_PATTERN_FRAGMENT_1 = "Hey, where the rest?",
        YOTB_PATTERN_FRAGMENT_2 = "Hey, where the rest?",
        YOTB_PATTERN_FRAGMENT_3 = "Hey, where the rest?",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "Too soft, florp. Rips on claws too easy.",
            YOTB = "Should show to weird scale-less hiding in tent!",
        },

        WAR_BLUEPRINT = "Hee-hee good and scary!",
        DOLL_BLUEPRINT = "Look kind of creepy...",
        FESTIVE_BLUEPRINT = "Big fuzzy gonna look so good in this!",
        ROBOT_BLUEPRINT = "Make big fuzzy look like Ironfolk?",
        NATURE_BLUEPRINT = "Glurgh... this one ugly...",
        FORMAL_BLUEPRINT = "Ooooh, all fancy.",
        VICTORIAN_BLUEPRINT = "Scale-less sure dress weird, florp.",
        ICE_BLUEPRINT = "Don't want big fuzzy to get cold.",
        BEAST_BLUEPRINT = "Awww, big fuzzy wanna have scales too?",

        BEEF_BELL = "Big fuzzies really like bell.",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "It too tiny to fit inside...",
            BURNT = "Glurp! Didn't do it!!",
			PLAYING_HIDEANDSEEK = "Nobody hiding in there?",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "Where they go?!",
		},

		KITCOONDEN_KIT = "Building house easy! Done it lots of times, flort.",

		TICOON = 
		{
			GENERIC = "It big squishy kitty! Hello!",
			ABANDONED = "Maybe we play later, okay?",
			SUCCESS = "He did good job, florp.",
			LOST_TRACK = "His nose not so good after all.",
			NEARBY = "Think he smell something nearby.",
			TRACKING = "He looking for something!",
			TRACKING_NOT_MINE = "Wait... this not the right squishy kitty.",
			NOTHING_TO_TRACK = "Guess he not smell anything around.",
			TARGET_TOO_FAR_AWAY = "Come on squishy kitty, wanna try somewhere else!",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "It home for shiny kitty.",
            EMPTY = "Will find present for you, florp.",
            BURNT = "Uh oh...",
        },

		KITCOON_FOREST = "Ha ha! It fluffy AND scratchy!",
		KITCOON_SAVANNA = "Ha ha! It fluffy AND scratchy!",
		KITCOON_MARSH = "You from swamp too? You best one.",
		KITCOON_DECIDUOUS = "Ha ha! It fluffy AND scratchy!",
		KITCOON_GRASS = "Ha ha! It fluffy AND scratchy!",
		KITCOON_ROCKY = "It so little!",
		KITCOON_DESERT = "It so little!",
		KITCOON_MOON = "It so little!",
		KITCOON_YOT = "It so little!",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Glorp! Didn't do it! Didn't do it!",
            DEAD = "W-wasn't even scared at all!",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "How it get back up?!",
            DEAD = "Now is super dead!",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "Grrr, these things getting in way!",
        ALTERGUARDIAN_PHASE3 = "Glurp... maybe it time to run?",
        ALTERGUARDIAN_PHASE3TRAP = "Don't trust weird rocks, florp.",
        ALTERGUARDIAN_PHASE3DEADORB = "Look out! Might come back!",
        ALTERGUARDIAN_PHASE3DEAD = "I-is gone for good now right, florp?",

        ALTERGUARDIANHAT = "Makes head full of funny whispers...",
        ALTERGUARDIANHATSHARD = "Glurp! D-didn't break it!",

        MOONSTORM_GLASS = {
            GENERIC = "Is very sharp.",
            INFUSED = "Oooooooh pretty!"
        },

        MOONSTORM_STATIC = "What that sparky stuff?",
        MOONSTORM_STATIC_ITEM = "Hee-hee! It can't get out!",
        MOONSTORM_SPARK = "Glorp! It zaps!",

        BIRD_MUTANT = "Ha ha! What happen to you?",
        BIRD_MUTANT_SPITTER = "Pt-ooey back at you, florp!",

        WAGSTAFF_NPC = "Is another scaleless? Can't smell him, florpt...",
        ALTERGUARDIAN_CONTAINED = "What that thing for?",

        WAGSTAFF_TOOL_1 = "Hmm... it have no smell, like weird scale-less.",
        WAGSTAFF_TOOL_2 = "Maybe this what weird scale-less looking for.",
        WAGSTAFF_TOOL_3 = "It all flickery, like weird scale-less.",
        WAGSTAFF_TOOL_4 = "What that? Maybe it belong to weird scale-less...",
        WAGSTAFF_TOOL_5 = "Look like someone drop this, florp.",

        MOONSTORM_GOGGLESHAT = "Grrr, can't get the 'tato out!",

        MOON_DEVICE = {
            GENERIC = "Have weird feeling, florp...",
            CONSTRUCTION1 = "Is throne? Not as good as Mermfolk throne.",
            CONSTRUCTION2 = "Hmm... now it not look like throne at all...",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Only chewed on it little bit! But Wandy-lady got mad...",
			RECHARGING = "Wandy-lady say it \"ree-plin-ishing tem-pooral\"... glurgh. Forget rest.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Only chewed on it little bit! But Wandy-lady got mad...",
			RECHARGING = "Wandy-lady say it \"ree-plin-ishing tem-pooral\"... glurgh. Forget rest.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Only chewed on it little bit! But Wandy-lady got mad...",
			RECHARGING = "Wandy-lady say it \"ree-plin-ishing tem-pooral\"... glurgh. Forget rest.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Only chewed on it little bit! But Wandy-lady got mad...",
			RECHARGING = "Wandy-lady say it \"ree-plin-ishing tem-pooral\"... glurgh. Forget rest.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Only chewed on it little bit! But Wandy-lady got mad...",
			RECHARGING = "Wandy-lady say it \"ree-plin-ishing tem-pooral\"... glurgh. Forget rest.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Would like to see nasty Pigfolk hit with it!",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Too small for Ironfolk guts...",
        POCKETWATCH_DISMANTLER = "Won't break them, florp! Promise!",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Weird tunnel.",
			DIFFERENTSHARD = "Weird tunnel.",
		},
        POCKETWATCH_PORTAL_EXIT = "Glurgh, it too high to reach!",

        -- Waterlog
        WATERTREE_PILLAR = "It biggest tree ever!",
        OCEANTREE = "Tree like the water, florpt.",
        OCEANTREENUT = "Gonna plant new water tree.",
        WATERTREE_ROOT = "It just boring old root, flurt.",

        OCEANTREE_PILLAR = "It probably second biggest tree ever.",
        
        OCEANVINE = "There some yummy fruit over there!",
        FIG = "Mmmm! Mine!",
        FIG_COOKED = "Mmm, squishy!",

        SPIDER_WATER = "Spiderfolk run on water?? No fair!!",
        MUTATOR_WATER = "Webby boy make Merm cookie next!!",
        OCEANVINE_COCOON = "Why Spiderfolk house in tree?",
        OCEANVINE_COCOON_BURNT = "No tell Webby boy!",

        GRASSGATOR = "Hee-hee! Scaredy gator!",

        TREEGROWTHSOLUTION = "Glurph. Put all over face and didn't grow any bigger!",

        FIGATONI = "Mmmmmmm chewy sweet!",
        FIGKABAB = "Blegh, fruit ruined with meat!",
        KOALEFIG_TRUNK = "Glurgh... fruit have yucky nose juice all over...",
        FROGNEWTON = "Glurph! There frog leg in this!",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "It so... glowy...",
            CRIMSON = "It look kinda funny inside.",
            ENABLED = "WHAT GOING ON?!",
			WAITING_FOR_DARK = "Ooooh! Wanna float like that too!",
			COOLDOWN = "Where little tree go, florp?",
			SPAWN_DISABLED = "It not working.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Can do it too! Mermfolk super strong, flurt!",
            BURNT = "Glurp! Didn't do it!!",
        },

        DUMBBELL = "Muscly mustache man leave rocks everywhere.",
        DUMBBELL_GOLDEN = "Muscly mustache man leave rocks everywhere.",
		DUMBBELL_MARBLE = "Muscly mustache man leave rocks everywhere.",
        DUMBBELL_GEM = "Muscly mustache man leave rocks everywhere.",
        POTATOSACK = "Snacks! Mine!!",


        TERRARIUMCHEST = 
		{
			GENERIC = "It smell strange, not from here.",
			BURNT = "Didn't do it!!",
			SHIMMER = "Maybe have extra shiny treasure inside?",
		},

		EYEMASKHAT = "Feels like hug from a slug.",

        EYEOFTERROR = "Glurp...",
        EYEOFTERROR_MINI = "Grrrr, not afraid of little chompy eyes!",
        EYEOFTERROR_MINI_GROUNDED = "It gonna open soon!",

        FROZENBANANADAIQUIRI = "Cold fruit tastes yummy, florp!",
        BUNNYSTEW = "Glorp... Bunny's bath was too hot...",
        MILKYWHITES = "Squishy!",

        CRITTER_EYEOFTERROR = "Will make sure no get dry, glorp. Very important.",

        SHIELDOFTERROR ="How come it allowed to bite, but me get in trouble?!",
        TWINOFTERROR1 = "M-mermfolk not scared of any Ironfolk, flort!",
        TWINOFTERROR2 = "M-mermfolk not scared of any Ironfolk, flort!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "It so fast!",
        KITCOON_NAMETAG = "Fish necklace for little kitties.",

		KITCOONDECOR1 =
        {
            GENERIC = "Ha ha, it fun to hit!",
            BURNT = "Awww...",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "It have little fishy on it!",
            BURNT = "Nooo!!",
        },

		KITCOONDECOR1_KIT = "It not hard to build, florp.",
		KITCOONDECOR2_KIT = "It need building still!",

        -- WX78
        WX78MODULE_MAXHEALTH = "Crunchy.",
        WX78MODULE_MAXSANITY1 = "Crunchy.",
        WX78MODULE_MAXSANITY = "Crunchy.",
        WX78MODULE_MOVESPEED = "Crunchy.",
        WX78MODULE_MOVESPEED2 = "Crunchy.",
        WX78MODULE_HEAT = "Crunchy.",
        WX78MODULE_NIGHTVISION = "Crunchy.",
        WX78MODULE_COLD = "Crunchy.",
        WX78MODULE_TASER = "Crunchy.",
        WX78MODULE_LIGHT = "Crunchy.",
        WX78MODULE_MAXHUNGER1 = "Crunchy.",
        WX78MODULE_MAXHUNGER = "Crunchy.",
        WX78MODULE_MUSIC = "Crunchy.",
        WX78MODULE_BEE = "Crunchy.",
        WX78MODULE_MAXHEALTH2 = "Crunchy.",

        WX78_SCANNER = 
        {
            GENERIC ="Bug? No? Hmm...",
            HUNTING = "Bug? No? Hmm...",
            SCANNING = "Bug? No? Hmm...",
        },

        WX78_SCANNER_ITEM = "Bug? No? Hmm...",
        WX78_SCANNER_SUCCEEDED = "Why it all blinky?",

        WX78_MODULEREMOVER = "Haha! Ironfolk weird.",

        SCANDATA = "Glurgh... can Wicker-lady read it?",
    },

    DESCRIBE_GENERIC = "What that?",
    DESCRIBE_TOODARK = "It really, really dark.",
    DESCRIBE_SMOLDERING = "Smell something...",

    DESCRIBE_PLANTHAPPY = "Seem fine.",
    DESCRIBE_PLANTVERYSTRESSED = "Look very bad...",
    DESCRIBE_PLANTSTRESSED = "More than one thing wrong, florp.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Too much stuff in the way.",
    DESCRIBE_PLANTSTRESSORFAMILY = "Wants other plant like it around.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "Is too many plants here! Can't grow big!",
    DESCRIBE_PLANTSTRESSORSEASON = "It not like this seasontime.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Need water!",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Need plant food.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "Wicker-lady say plant like talking to...",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Blegh, who wanna eat that?",
		WINTERSFEASTFUEL = "Mmmmm, sweets!",
    },
}
