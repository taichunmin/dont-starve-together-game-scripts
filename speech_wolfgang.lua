--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Judge man is busy.",
        },
        REPAIR =
        {
            WRONGPIECE = "Is wrong piece for little statue!",
        },
        BUILD =
        {
            MOUNTED = "Hair-cow is too tall. I can't reach.",
            HASPET = "Wolfgang has animal friend already!",
			TICOON = "Wolfgang already has good furry friend.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I will wait until he is not looking.",
			GENERIC = "That cannot be shaved.",
			NOBITS = "I cannot shave when there are no hairs.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "Is not Wolfgang's for shaving.",
		},
		STORE =
		{
			GENERIC = "I will make it fit!",
			NOTALLOWED = "Bah! Useless.",
			INUSE = "Wolfgang can share!",
            NOTMASTERCHEF = "Warly is very nice to cook. Wolfgang will not get in way.",
		},
        CONSTRUCT =
        {
            INUSE = "Wolfgang can share?",
            NOTALLOWED = "Is not right place for that.",
            EMPTY = "Wolfgang needs something to put here.",
            MISMATCH = "Wolfgang have wrong plans.",
        },
		RUMMAGE =
		{
			GENERIC = "Maybe Wolfgang do later.",
			INUSE = "Wolfgang would like to use after you, if okay.",
            NOTMASTERCHEF = "Warly is very nice to cook. Wolfgang will not get in way.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Is not right key!",
        	KLAUS = "Later! Now we FIGHT!",
			QUAGMIRE_WRONGKEY = "Is wrong key.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Let Wolfgang in!",
            HOSTBUSY = "He is very busy bird, have carnival to run!",
            CARNIVAL_HOST_HERE = "Where is bird man? Thought he was here...",
            NOCARNIVAL = "Looks like birds move carnival somewhere else.",
			EMPTY_CATCOONDEN = "Did Wolfgang's muscles scare tiny kitties away?",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "Wolfgang plays fair, where is fun in less kitties?",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "Wolfgang plays fair, is nowhere for kitties to hide here!",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "Is enough games for Wolfgang.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "Warly is very nice to cook. Wolfgang will not get in way.",
			SHADOWMAGIC = "Wolfgang is glad he cannot read!",
		},
        COOK =
        {
            GENERIC = "Wolfgang not in cooking mood.",
            INUSE = "Oh, smells good, friend!",
            TOOFAR = "Is pot very small, or just far away?",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Wolfgang must find leggy carrots for race!",
        },

		DISMANTLE =
		{
			COOKING = "Delicious meal must finish first.",
			INUSE = "Wolfgang would like to use after you, if okay.",
			NOTEMPTY = "Is still filled with things.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Wolfgang can't reach fish with tiny rod!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Don't need mighty fishing rod for tiny pond!",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "Wolfgang does not think that goes there.",
            DEAD = "You know is dead, yes?",
            SLEEPING = "Is sleeping now!",
            BUSY = "The Mighty Wolfgang will try again soon!",
            ABIGAILHEART = "Wolfgang smush heart into ghost girl but nothing happen!",
            GHOSTHEART = "No!",
            NOTGEM = "Not even mighty muscles can make fit!",
            WRONGGEM = "Little rock does not want to go there.",
            NOTSTAFF = "I do not think little platform would like that.",
            MUSHROOMFARM_NEEDSSHROOM = "Is needing tiny mushy-room, I think.",
            MUSHROOMFARM_NEEDSLOG = "Is needing tiny log with face.",
            MUSHROOMFARM_NOMOONALLOWED = "Why do the mushy-rooms not grow?",
            SLOTFULL = "Something is already put!",
            FOODFULL = "It must enjoy first yummy food from Wolfgang first!",
            NOTDISH = "Wolfgang serves only best dishes!",
            DUPLICATE = "Little recipe is already in there!",
            NOTSCULPTABLE = "Material is not mighty enough for strong statues!",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Is not working.",
            WRONGSHADOWFORM = "Bones is wrong shape.",
            NOMOON = "Is too scary in here for funny man to work.",
			PIGKINGGAME_MESSY = "Wolfgang clean first.",
			PIGKINGGAME_DANGER = "Is too scary for that now!",
			PIGKINGGAME_TOOLATE = "Is dark. No games now.",
			CARNIVALGAME_INVALID_ITEM = "Haha! Wolfgang thought it would be funny to try that!",
			CARNIVALGAME_ALREADY_PLAYING = "Friends are having good time, Wolfgang can wait.",
            SPIDERNOHAT = "Wolfgang's pockets are too small for both bug and hat!",
            TERRARIUM_REFUSE = "Tiny triangle is not wanting that.",
            TERRARIUM_COOLDOWN = "Wolfgang will wait for tiny tree to come back, then give present!",
        },
        GIVETOPLAYER =
        {
            FULL = "Make room for Wolfgang's presents!",
            DEAD = "You know is dead, yes?",
            SLEEPING = "Friend is sleeping now!",
            BUSY = "Please give Mighty Wolfgang your attention!",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "Make room for Wolfgang's presents!",
            DEAD = "You know is dead, yes?",
            SLEEPING = "Friend is sleeping now!",
            BUSY = "Please give Mighty Wolfgang your attention!",
        },
        WRITE =
        {
            GENERIC = "Wolfgang not good with tiny letters.",
            INUSE = "Can Wolfgang help make scribblemarks when you're done?",
        },
        DRAW =
        {
            NOIMAGE = "Wolfgang no good at drawing pictures from head.",
        },
        CHANGEIN =
        {
            GENERIC = "Clothes only good for ripping with strong muscles!",
            BURNING = "Wolfgang's weekday undergarments burning? Wolfgang is sad.",
            INUSE = "Wolfgang will wait til they leave to change. He is shy.",
            NOTENOUGHHAIR = "Will wait for hairs to grow back.",
            NOOCCUPANT = "Wolfgang needs beefalo to hitch.",
        },
        ATTUNE =
        {
            NOHEALTH = "Wolfgang is too woozy to do this.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I cannot ride it now! Hair-cow is proving itself in battle!",
            INUSE = "Hair-cow is occupied by another.",
			SLEEPING = "Is time for waking, hair-cow!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I cannot ride it now! Hair-cow is proving itself in battle!",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Wolfgang already knows this!",
            CANTLEARN = "I do not get it.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "Little paper is not for here!",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "Wolfgang can't read in here.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "Wolfgang has no little things to wrap!",
        },
        PICKUP =
        {
			RESTRICTION = "That is not mighty weapon!",
			INUSE = "Wolfgang will wait for friend to finish.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Is not Wolfgang's leggy carrot.",
                "Wolfgang's leggy carrot look completely different!",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Come back so Wolfgang can eat you!",
        },
        REPLATE =
        {
            MISMATCH = "Food need different dish.",
            SAMEDISH = "Wolfgang already put on dish.",
        },
        SAIL =
        {
        	REPAIR = "Tiny boat is strong, no need.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Need to paddle at right time!",
            BAD_TIMING1 = "Wolfgang need to concentrate.",
            BAD_TIMING2 = "Is easy! That was just practice run.",
        },
        LOWER_SAIL_FAIL =
        {
            "Tiny wind cloth not listening to Wolfgang!",
            "Wolfgang will show tiny boat who's mightier!",
            "Argh! Taking down big circus tent was easier than this!",
        },
        BATHBOMB =
        {
            GLASSED = "Is covered in see-through sharp stuff!",
            ALREADY_BOMBED = "Is already prettified.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "Little recipe is already in there!",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "Tiny fish not mighty enough!",
            OVERSIZEDVEGGIES_TOO_SMALL = "Wolfgang is able to lift it too easily, is not heavy enough!",
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
            GENERIC = "This plant is known to Wolfgang.",
            FERTILIZER = "This is known to Wolfgang.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Salt water not good for plants.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Water is run out.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Water is run out.",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Silly! Is not going to work!",
            BEEF_BELL_ALREADY_USED = "This hair-cow already has friend.",
            BEEF_BELL_HAS_BEEF_ALREADY = "Wolfgang already picked best hair-cow to befriend!",
        },
        HITCHUP =
        {
            NEEDBEEF = "Wolfgang needs hair-cow!",
            NEEDBEEF_CLOSER = "Hair-cow is too far away.",
            BEEF_HITCHED = "Is staying put.",
            INMOOD = "Is too feisty for hitching!",
        },
        MARK =
        {
            ALREADY_MARKED = "Wolfgang has chosen this one!",
            NOT_PARTICIPANT = "Wolfgang will wait for next time.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Where do you hide, strange little man?",
            ALREADYACTIVE = "Maybe contest is somewhere else.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "Ha! Was already there in Wolfgang's big brain!",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Little bird is too fast!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "Eep! Creepy bugs not listen to Wolfgang!",
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
            NOWEIGHT = "Wolfgang needs to find something to lift!",
            UNBALANCED = "Wolfgang does not want one arm mightier than other!",
            ONFIRE = "Is good to feel burn, but not that much.",
            SMOULDER = "Wolfgang will stomp puny fire out first.",
            HUNGRY = "Too hungry... can't lift with tummy grumbling...",
            FULL = "Is Wolfgang's turn for lifting now! Wait...",
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
            DOER_ISNT_MODULE_OWNER = "Wolfgang thinks it only speaks robot.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Is no good, Wolfgang doesn't have enough!",
		NO_TECH = "Hmm, is tricky. Wolfgang should learn how to make.",
		NO_STATION = "Wolfgang will need right working-place!",
	},

	ACTIONFAIL_GENERIC = "I am not mighty enough to do that.",
	ANNOUNCE_BOAT_LEAK = "Drippy drops is come through boat!",
	ANNOUNCE_BOAT_SINK = "Wolfgang cannot swim!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Ha! Dirt spoon fix it!", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Bah! Tiny plant is smell terrible!", --removed
	ANNOUNCE_ADVENTUREFAIL = "Next time I will be mightier!",
    ANNOUNCE_MOUNT_LOWHEALTH = "What is wrong, hair beast? Feeling not-so-mighty?",

    --waxwell and wickerbottom specific strings
--fallback to speech_wilson.lua     ANNOUNCE_TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua     ANNOUNCE_WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",

    --wolfgang specific
    ANNOUNCE_NORMALTOMIGHTY = "I AM MIGHTY!",
    ANNOUNCE_NORMALTOWIMPY = "I am not feeling so good.",
    ANNOUNCE_WIMPYTONORMAL = "Wolfgang is better.",
    ANNOUNCE_MIGHTYTONORMAL = "No! Wolfgang must get stronger!",
    ANNOUNCE_EXITGYM = {
        MIGHTY = "Hah! Wolfgang feel back to old self!",
        NORMAL = "Hmm muscles feel better, but could be stronger!",
        WIMPY = "Wolfgang is just needing... a bit of rest...",
    },

	ANNOUNCE_BEES = "Bees! Nasty stinging bug men!",
	ANNOUNCE_BOOMERANG = "Ow! Why did you hurt me, throwy stick?",
	ANNOUNCE_CHARLIE = "Show yourself!",
	ANNOUNCE_CHARLIE_ATTACK = "Ow! It got me!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "Brrrrrrr! Is frosty!",
	ANNOUNCE_HOT = "Hah, is sticky and hot!",
	ANNOUNCE_CRAFTING_FAIL = "I need to gather more things to make that.",
	ANNOUNCE_DEERCLOPS = "Sound like big strong man coming.",
	ANNOUNCE_CAVEIN = "Sky is fall soon.",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"Ground is crumble beneath might of Wolfgang!",
		"Wolfgang broke the ground!",
		"That rumble is not stomach!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Please do not eat me.",
        "Is tribute for a mighty... f-friend.",
        "Do not eat Wolfgang's friends, please?",
	},
	ANNOUNCE_SACREDCHEST_YES = "Chest is happy!",
	ANNOUNCE_SACREDCHEST_NO = "It did not like me.",
    ANNOUNCE_DUSK = "The scary time is coming soon.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Good food make Wolfgang strong!",
		PAINFUL = "Ooooh. I have belly ache.",
		SPOILED = "Ew! Tastes like garbage!",
		STALE = "Tastes funny.",
		INVALID = "Hahah! That's not food!",
        YUCKY = "Stomach is not strong enough for that.",

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
        "Is good... for muscles...",
        "Lift... with legs...",
        "Feel... good burn!",
        "Raa! Huff!",
        "Muscles... will be sore tomorrow!",
        "Ha ha...! Weight... is nothing!",
        "Little stone... cannot stop Wolfgang!",
        "Hngh...!",
        "Witness... Wolfgang strength!",
        "Wolfgang is mighty...!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Monsters is coming!",
		"Wolfgang wants out of cave!",
		"Wolfgang does not like dark cave.",
	},
    ANNOUNCE_RUINS_RESET = "Monsters is back!",
    ANNOUNCE_SNARED = "Wolfgang does not like bones!",
    ANNOUNCE_SNARED_IVY = "Wolfgang will pull you out of the ground!",
    ANNOUNCE_REPELLED = "Strong bubble protects beast!",
	ANNOUNCE_ENTER_DARK = "I cannot see! I am scared!",
	ANNOUNCE_ENTER_LIGHT = "I can see again!",
	ANNOUNCE_FREEDOM = "I am free! Strong freedom!",
	ANNOUNCE_HIGHRESEARCH = "Is maybe too much information.",
	ANNOUNCE_HOUNDS = "I hear puppies!",
	ANNOUNCE_WORMS = "Earth is tremble beneath Wolfgang's mighty feet!",
	ANNOUNCE_HUNGRY = "My mighty belly is empty!",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Animal is close!",
	ANNOUNCE_HUNT_LOST_TRAIL = "No animal here.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Animal tracks is mud now.",
	ANNOUNCE_INV_FULL = "My mighty arms can carry no more.",
	ANNOUNCE_KNOCKEDOUT = "Ugh, I must have hit head.",
	ANNOUNCE_LOWRESEARCH = "Is tiny information.",
	ANNOUNCE_MOSQUITOS = "Wolfgang need blood, get away sucking bugs!",
    ANNOUNCE_NOWARDROBEONFIRE = "Ehh, Wolfgang do that later...",
    ANNOUNCE_NODANGERGIFT = "Fight is better than present!",
    ANNOUNCE_NOMOUNTEDGIFT = "Wolfgang will fall if try to open on top of hair cow!",
	ANNOUNCE_NODANGERSLEEP = "Wolfgang prefer fight to sleep.",
	ANNOUNCE_NODAYSLEEP = "Is too bright for sleep.",
	ANNOUNCE_NODAYSLEEP_CAVE = "Is creepy in cave.",
	ANNOUNCE_NOHUNGERSLEEP = "Wolfgang say never sleep with empty stomach.",
	ANNOUNCE_NOSLEEPONFIRE = "Is too hot for sleeping.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Wolfgang can't sleep with bright light!",
	ANNOUNCE_NODANGERSIESTA = "I prefer fighting to napping!",
	ANNOUNCE_NONIGHTSIESTA = "Wolfgang have principles against siesta at night.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Wolfgang is tense. Too tense to relax.",
	ANNOUNCE_NOHUNGERSIESTA = "Wolfgang take siesta after eating time.",
	ANNOUNCE_NO_TRAP = "Easy like lift weights.",
	ANNOUNCE_PECKED = "What I do to deserve this?",
	ANNOUNCE_QUAKE = "Ground is shake. Wolfgang hate shaking ground.",
	ANNOUNCE_RESEARCH = "Is lot of information.",
	ANNOUNCE_SHELTER = "Wolfgang hide under tree.",
	ANNOUNCE_THORNS = "Pointy is not fair!",
	ANNOUNCE_BURNT = "Burny is not fair!",
	ANNOUNCE_TORCH_OUT = "Oh no! The light is gone!",
	ANNOUNCE_THURIBLE_OUT = "Swingy burnies has gone out!",
	ANNOUNCE_FAN_OUT = "Tiny fan is broken!",
    ANNOUNCE_COMPASS_OUT = "Little needle broke off!",
	ANNOUNCE_TRAP_WENT_OFF = "Ack! Do not surprise Wolfgang!",
	ANNOUNCE_UNIMPLEMENTED = "Is not ready.",
	ANNOUNCE_WORMHOLE = "It makes me feel alive!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Wolfgang is here!",
	ANNOUNCE_CANFIX = "\nMighty brain could make this better!",
	ANNOUNCE_ACCOMPLISHMENT = "I am doing great things with tiny arrow!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I have defeated the tiny arrow!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Is not enough poop.",
	ANNOUNCE_TOOL_SLIP = "Is too slippery for holding!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Lightning is weak compared to Wolfgang clothes!",
	ANNOUNCE_TOADESCAPING = "Is looking skittery!",
	ANNOUNCE_TOADESCAPED = "Scary frog got scared and left.",


	ANNOUNCE_DAMP = "Water time.",
	ANNOUNCE_WET = "Wolfgang does not like bath time.",
	ANNOUNCE_WETTER = "It is like sitting in pond.",
	ANNOUNCE_SOAKED = "Wolfgang is maybe now made of water.",

	ANNOUNCE_WASHED_ASHORE = "Wolfgang lucky to be alive.",

    ANNOUNCE_DESPAWN = "Wolfgang is scared!",
	ANNOUNCE_BECOMEGHOST = "oOooOOoo!!",
	ANNOUNCE_GHOSTDRAIN = "They are coming... for Wolfgang!",
	ANNOUNCE_PETRIFED_TREES = "Trees! Getting! STRONG!",
	ANNOUNCE_KLAUS_ENRAGE = "Wolfgang is sorry about little deer friends!",
	ANNOUNCE_KLAUS_UNCHAINED = "Do not hold back! Wolfgang can take you!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Wimpy monster has called for help!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Do not fear! Wolfgang will save you!",
		GLASS_LOW = "Wolfgang is close!",
		GLASS_REVEAL = "You have been saved! By Wolfgang!",
		IDOL_MED = "Do not fear! Wolfgang will save you!",
		IDOL_LOW = "Wolfgang is close!",
		IDOL_REVEAL = "You have been saved! By Wolfgang!",
		SEED_MED = "Do not fear! Wolfgang will save you!",
		SEED_LOW = "Wolfgang is close!",
		SEED_REVEAL = "You have been saved! By Wolfgang!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Wolfgang's eyes is playing tricky!",
	ANNOUNCE_BRAVERY_POTION = "Wolfgang is brave! Not scared of spooky tree!",
	ANNOUNCE_MOONPOTION_FAILED = "Wolfgang expected something to happen.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Wolfgang should share with tiny, weaker friends.",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Why do tiny sparks follow Wolfgang?",
	ANNOUNCE_IS_FEASTING = "Is the time for feasting!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Goodbye tiny sparks.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Up now, friend!",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Go! Fight many things!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Thank-you, friend!",

    ANNOUNCE_FLARE_SEEN = "Sky fire! Wolfgang is coming, dear friend!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Wolfgang does not like scary shadow!",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "That was not good recipe!",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Little meal cooked too long.",
    QUAGMIRE_ANNOUNCE_LOSE = "Sky beast is mad!",
    QUAGMIRE_ANNOUNCE_WIN = "Is time to leave. Goodbye, good food!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "Sparky! I like!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Wolfgang even mightier than was before!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "Ha! Wimpy blows bounce right off Wolfgang!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "You watch, let Wolfgang take care of this!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Water will not bother Wolfgang!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Wolfgang mightier than the sleepytimes!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Lightning magic gone.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Wolfgang still strong! Just little less strong!",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Wolfgang will need new defensive strategy.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Time for little break.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Feels damp... Wolfgang hope not to catch cold.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "Wolfgang feeling like he could use a little nap soon.",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Fish was too mighty for weak little string.",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "Wolfgang must reel in faster!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "Seems no fish stew for dinner.",
	ANNOUNCE_OCEANFISHING_BADCAST = "Was practice! Wolfgang will try for real now!",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Wolfgang can wait!",
		"Wolfgang can wait a little longer.",
		"Wolfgang getting bored.",
		"Wolfgang would like fish to go on hook now.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nGood thing Wolfgang have big muscles for carrying!",

	ANNOUNCE_WINCH_CLAW_MISS = "Boat is not in position!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "Mighty claw has turned up nothing.",

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
    ANNOUNCE_WEAK_RAT = "Is too weak for race.",

    ANNOUNCE_CARRAT_START_RACE = "Leggy carrot race start NOW!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "No! Wrong way!",
        "You go wrong way, leggy carrot!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Is not the sleepytime!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Leggy carrot must go faster!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "Will not win like that! Must go!",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Ooooh, time tunnel make Wolfgang dizzy...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Wolfgang's brain full of strange pictures!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "Wolfgang has seen these brain pictures already.",
    ANNOUNCE_ARCHIVE_NO_POWER = "Not sure what Wolfgang was expecting.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "Plant learning is easy! Just need right hat!",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "Will see what tiny seed grows into.",

    ANNOUNCE_FERTILIZER_RESEARCHED = "Wolfgang is learning much about stinky plant food.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Burny! Wolfgang not like!",
		"Puny plant has poisoned Wolfgang!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Ha! Puny plant poison could not last long in Wolfgang's mighty body!",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Hello! Wolfgang will talk to you now.",
        "You are doing well, yes?",
		"You will grow big and strong like Wolfgang!",
        "You are very good plant. You make food for Wolfgang!",
        "Who is mightiest plant of all? You are!",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Ready or not, here comes mighty Wolfgang!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Mighty Wolfgang wants to help find all tiny kitties!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Here, Wolfgang found kitty kitty!",
		"Wolfgang finds tiny kitties too easy!",
		"Phew, tiny kitty hid very well!",
		"Ah hah! Tiny Kitty cannot hide from mighty Wolfgang!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "Wolfgang is going to find you, tiny kitty!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "Tiny kitties now know Wolfgang is mightiest one!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "We are mightier together, ha ha!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Wolfgang needs to find tiny kitties faster!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Bah! Tiny kitties bested mighty Wolfgang!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "Wolfgang not sure if small kitty paws can walk so far...",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Kitties are over here, Wolfgang knows it!",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Why you not hiding like other kitties?",

	ANNOUNCE_TICOON_START_TRACKING	= "Go on, furry friend! Wolfgang trusts you!",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "Oh no, furry friend found nothing!",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Wolfgang should follow furry friend!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Wolfgang thinks furry friend wants to be followed.",
	ANNOUNCE_TICOON_NEAR_KITCOON = "Oh ho ho, we're near a kitty kitty!",
	ANNOUNCE_TICOON_LOST_KITCOON = "Someone found what Wolfgang was looking for!",
	ANNOUNCE_TICOON_ABANDONED = "Wolfgang will find tiny kitties himself!",
	ANNOUNCE_TICOON_DEAD = "Furry friend is gone? Who will show Wolfgang where tiny kitties are?",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Come, hair-cow!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "How will judge see Wolfgang's beautiful hair-cow from so far away?",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Is new hair-cow costume! Wolfgang will make.",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Wolfgang no like the look of that!",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Wolfgang stronger and braver now!",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Big scary eye scared of daylight? Ha ha ha!",

	BATTLECRY =
	{
		GENERIC = "I will punch you!",
		PIG = "I am sorry, my friend!",
		PREY = "Stomp! Stomp! Stomp!",
		SPIDER = "Die, evil scary bug!",
		SPIDER_WARRIOR = "I am still stronger, scary bug!",
		DEER = "I will make fight quick!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Ha! I win!",
		PIG = "I forgive you, pig man.",
		PREY = "You keep running!",
		SPIDER = "He ran away from me.",
		SPIDER_WARRIOR = "He knows I am stronger.",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Why door not crumble under mighty Wolfgang punches?!",
        MULTIPLAYER_PORTAL_MOONROCK = "Is strong like Wolfgang.",
        MOONROCKIDOL = "Hehe. Is funny little moon man.",
        CONSTRUCTION_PLANS = "If Wolfgang build it, they will come.",

        ANTLION =
        {
            GENERIC = "Scary monster is friend?",
            VERYHAPPY = "Monster does not look hungry today.",
            UNHAPPY = "Monster is looking very scary!",
        },
        ANTLIONTRINKET = "Is not for head.",
        SANDSPIKE = "Spike is made of sand!",
        SANDBLOCK = "Is very sandy.",
        GLASSSPIKE = "Spike is glass now.",
        GLASSBLOCK = "Wolfgang could crush little castle.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Is pretty.",
			LEVEL1 = "Little flower gives Wolfgang the \"heebie jeebies\".",
			LEVEL2 = "I do not like.",
			LEVEL3 = "Is making Wolfgang scared!",

			-- deprecated
            LONG = "Is pretty.",
            MEDIUM = "Little flower gives Wolfgang the \"heebie jeebies\".",
            SOON = "I do not like.",
            HAUNTED_POCKET = "Is making Wolfgang scared!",
            HAUNTED_GROUND = "Does it want to fight?",
        },

        BALLOONS_EMPTY = "Wolfgang will make balloon muscles.",
        BALLOON = "Is full of clown breath!",
		BALLOONPARTY = "Come, friends! Is party!",
		BALLOONSPEED =
        {
            DEFLATED = "Balloon has gotten scrawny and weak!",
            GENERIC = "Clownman has mighty lungs to make balloon so big!",
        },
		BALLOONVEST = "Wolfgang will try not to pop little vest with his mighty muscles.",
		BALLOONHAT = "Haha! Tiny clownman make funny rabbit hat!",

        BERNIE_INACTIVE =
        {
            BROKEN = "Is so broken.",
            GENERIC = "Is so cuddly!",
        },

        BERNIE_ACTIVE = "Is so brave!",
        BERNIE_BIG = "Oh no! Wolfgang has shrunken!",

        BOOK_BIRDS = "Book is for the birds!",
        BOOK_TENTACLES = "Wolfgang wants many foes to fight!",
        BOOK_GARDENING = "Wolfgang rather grow muscle than flowers.",
		BOOK_SILVICULTURE = "Wolfgang rather grow muscle than flowers.",
		BOOK_HORTICULTURE = "Little book makes food grow for Wolfgang.",
        BOOK_SLEEP = "Wolfgang's eyes feel heavy like dumbbells.",
        BOOK_BRIMSTONE = "Tiny book scares Wolfgang!",

        PLAYER =
        {
            GENERIC = "Is tiny %s! Hello!",
            ATTACKER = "Does %s want to fight?",
            MURDERER = "%s is killer!",
            REVIVER = "%s is nice person.",
            GHOST = "Wolfgang will get raw pump-y heart for you!",
            FIRESTARTER = "%s is lighting burny fires!",
        },
        WILSON =
        {
            GENERIC = "Is tiny egghead man, %s! Hello!",
            ATTACKER = "Does weak science man want to fight?",
            MURDERER = "%s stands no chance against Wolfgang!",
            REVIVER = "%s is nice, crazy man.",
            GHOST = "Ha ha! Big brain did not save you. I will get heart.",
            FIRESTARTER = "Wolfgang thought he could trust %s!",
        },
        WOLFGANG =
        {
            GENERIC = "Hello friend %s! We must arm wrestle!",
            ATTACKER = "%s will make a worthy fight!",
            MURDERER = "We will see who is best Wolfgang! Raaa!",
            REVIVER = "%s is nice man. Like me! Ha ha.",
            GHOST = "World needs more %s! I will get heart!",
            FIRESTARTER = "Wolfgang cannot trust even himself not to light fire!",
        },
        WAXWELL =
        {
            GENERIC = "Is tiny frailman, %s! Hello!",
            ATTACKER = "Does fragile %s want to fight? Ha ha! Is funny.",
            MURDERER = "%s has not changed. Killer!",
            REVIVER = "%s is one of us. Ha ha! Yes!",
            GHOST = "%s is friend of Wolfgang. He will get raw heart.",
            FIRESTARTER = "Is dastardly plan with fire, %s?",
        },
        WX78 =
        {
            GENERIC = "Is tiny robot, %s! Hello!",
            ATTACKER = "Ha! Metal can is want to rock'em and sock'em!",
            MURDERER = "%s is killer robot!",
            REVIVER = "%s is nice person. Deep down.",
            GHOST = "Robot %s is broken! Wolfgang rub heart on problem.",
            FIRESTARTER = "Robot trying to kill fleshypeople again, maybe?",
        },
        WILLOW =
        {
            GENERIC = "Is tiny torchlady, %s! Hello!",
            ATTACKER = "Wolfgang is burning to fight!",
            MURDERER = "%s is no match for Wolfgang!",
            REVIVER = "%s is very nice, when not light moustache on fire.",
            GHOST = "Do not hurt, torchlady. Wolfgang get heart!",
            FIRESTARTER = "Is not big surprise.",
        },
        WENDY =
        {
            GENERIC = "Is very tiny, scary %s! H-hello!",
            ATTACKER = "Ah! Creepy girl is try to fight me!",
            MURDERER = "Creepy girl is killer! Attack!",
            REVIVER = "%s is nice little lady. But still scare Wolfgang.",
            GHOST = "Please no hauntings, %s! Wolfgang will get you heart!",
            FIRESTARTER = "Oh no. Creepy girl is trying to burn us!",
        },
        WOODIE =
        {
            GENERIC = "Is beard! Hello!",
            ATTACKER = "Does beardman %s want to fight?",
            MURDERER = "Drop axe and fight, beardman!",
            REVIVER = "%s is nice man with magnificent beard.",
            GHOST = "Wolfgang will get heart for you, beard!",
            BEAVER = "The beard ate %s!",
            BEAVERGHOST = "Still have good moustache, %s.",
            MOOSE = "Something different about beardman today.",
            MOOSEGHOST = "Wolfgang will find heart for antlered beard.",
            GOOSE = "Beardman become birdman! Ha ha!",
            GOOSEGHOST = "No fear birdman, Wolfgang will help!",
            FIRESTARTER = "Be careful! Do not burn, beard!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Is strong brainlady! Hello, tiny %s!",
            ATTACKER = "Ha ha! %s should not pick fight with dumb books!",
            MURDERER = "%s is killer!",
            REVIVER = "%s smell like mothballs and kindness.",
            GHOST = "Wolfgang will get raw pump-y heart for you!",
            FIRESTARTER = "Strong brainlady probably know what she's doing with fire.",
        },
        WES =
        {
            GENERIC = "Is tiny oddman, %s! Hello!",
            ATTACKER = "Wolfgang does not trust your rosy cheeks, %s.",
            MURDERER = "Ah! Is killer clown! %s!",
            REVIVER = "%s is nice, weird little man.",
            GHOST = "Wolfgang will go get heart for odd clownman!",
            FIRESTARTER = "You are looking very guilty, clownman.",
        },
        WEBBER =
        {
            GENERIC = "Is tiny monsterchild, %s! H-hello!",
            ATTACKER = "Ah! Tiny child is try to fight me!",
            MURDERER = "Monsterchild %s is killer! Wolfgang is run!",
            REVIVER = "Creepy monster %s is nice kid.",
            GHOST = "Who squish small bug boy? Wolfgang will smash back!",
            FIRESTARTER = "Please no. Please no burnings!",
        },
        WATHGRITHR =
        {
            GENERIC = "Is very strong %s! Hello!",
            ATTACKER = "%s will make a worthy fight!",
            MURDERER = "Stronglady %s is killer!",
            REVIVER = "%s is nice, strong lady.",
            GHOST = "World needs stronglady! Wolfgang will get heart!",
            FIRESTARTER = "Why starting fires, stronglady? To fight them?",
        },
        WINONA =
        {
            GENERIC = "Is fixing lady, %s! Hello!",
            ATTACKER = "%s is breaking things!",
            MURDERER = "%s broke our friend!",
            REVIVER = "%s is kind lady.",
            GHOST = "Wolfgang will fix little %s with heart.",
            FIRESTARTER = "%s's fires is make Wolfgang nervous.",
        },
        WORTOX =
        {
            GENERIC = "Is scary horn man, %s! H-hello!",
            ATTACKER = "Your game is not nice, little horn man!",
            MURDERER = "Horn man is evil!",
            REVIVER = "Scary horn man is nice sometimes.",
            GHOST = "Fluffy ghost!",
            FIRESTARTER = "Fire is not game, horn man.",
        },
        WORMWOOD =
        {
            GENERIC = "Is leafy green man, %s! Hello!",
            ATTACKER = "%s is all bark AND all bite.",
            MURDERER = "%s is scary killer tree!",
            REVIVER = "%s is Wolfgang's best friend.",
            GHOST = "Little plant was overwatered, maybe?",
            FIRESTARTER = "Leafy green man did a fire booboo.",
        },
        WARLY =
        {
            GENERIC = "Is tasty-making man, %s! Hello!",
            ATTACKER = "Why not use fists for bread making, yes?",
            MURDERER = "Tasty-making man is murderer!",
            REVIVER = "%s has nice big heart.",
            GHOST = "Does tiny man %s need Mighty Wolfgang's help?",
            FIRESTARTER = "Tasty-making man was probably cook with big fire.",
        },

        WURT =
        {
            GENERIC = "Is tiny fish girl, %s! Hello!",
            ATTACKER = "Tiny fish girl has no manners!",
            MURDERER = "Wolfgang shouldn't have trusted tiny swamp monster!",
            REVIVER = "%s is good. Even if she smell of old fish.",
            GHOST = "Thought fish had nine lives? Oh, Wolfgang think of cats.",
            FIRESTARTER = "That not look safe, fish girl!",
        },

        WALTER =
        {
            GENERIC = "Is boy who tell the scary stories... h-hello %s!",
            ATTACKER = "Tiny %s think he can pick fight with Wolfgang?",
            MURDERER = "Wolfgang will not be part of next camping fire story!",
            REVIVER = "%s always help Wolfgang. Wolfgang remember this!",
            GHOST = "Wolfgang help you now, %s.",
            FIRESTARTER = "Silly %s forget where firepit is!",
        },

        WANDA =
        {
            GENERIC = "Is clock lady, %s! Hello!",
            ATTACKER = "%s is strong for old lady!",
            MURDERER = "Clock lady %s is killer!",
            REVIVER = "%s is strange lady, but kind.",
            GHOST = "Clock lady wait here, Wolfgang will find heart!",
            FIRESTARTER = "Clock lady say is for important reason. Wolfgang not sure...",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "Why you follow, weird bug?",
            SLEEPING = "Time for Wolfgang to make escape!",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Is shiny flower.",
            DEAD = "Is sad and shiny flower.",
        },
        GLOMMERWINGS = "Small like fairy wings.",
        GLOMMERFUEL = "Weird bug make weird poop.",
        BELL = "Bell make dainty sound.",
        STATUEGLOMMER =
        {
            GENERIC = "Why statue is not flying?",
            EMPTY = "Smash!",
        },

        LAVA_POND_ROCK = "Is just small rock.",

		WEBBERSKULL = "I crush skull!",
		WORMLIGHT = "Pretty light.",
		WORMLIGHT_LESSER = "Nice little light.",
		WORM =
		{
		    PLANT = "Pretty light.",
		    DIRT = "Is dirt moving?",
		    WORM = "Did not expect this!",
		},
        WORMLIGHT_PLANT = "Pretty light.",
		MOLE =
		{
			HELD = "Wolfgang have mercy for tiny soft animal.",
			UNDERGROUND = "Stay underground where you are safe from Wolfgang.",
			ABOVEGROUND = "Now you will know Wolfgang's strength!",
		},
		MOLEHILL = "Mole hole.",
		MOLEHAT = "Mole skin is stretchy.",

		EEL = "Eel needs cooking!",
		EEL_COOKED = "Eel has been cooked.",
		UNAGI = "Food makes me mighty!",
		EYETURRET = "Mighty structure will help me fight!",
		EYETURRET_ITEM = "It needs strong placing.",
		MINOTAURHORN = "Is trophy from mighty foe.",
		MINOTAURCHEST = "Chest have big strong horns.",
		THULECITE_PIECES = "Can smash together to make bigger piece!",
		POND_ALGAE = "Plant is so small! Is funny to me.",
		GREENSTAFF = "This stick has green gem in it.",
		GIFT = "Is nice little present!",
        GIFTWRAP = "Wolfgang needs help tying little bow.",
		POTTEDFERN = "Wolfgang worry greenthumb is gangrene.",
        SUCCULENT_POTTED = "Tough plant is mine.",
		SUCCULENT_PLANT = "Is tough plant.",
		SUCCULENT_PICKED = "Tough plant is not dead yet.",
		SENTRYWARD = "Wolfgang thinks is full of secrets.",
        TOWNPORTAL =
        {
			GENERIC = "Is friend-bringer!",
			ACTIVE = "Is ready now.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "Is rock for quick trip.",
			ACTIVE = "Is time to go.",
		},
        WETPAPER = "Wolfgang can rip like wet paper!",
        WETPOUCH = "Is treasure from pool.",
        MOONROCK_PIECES = "Is little pieces from moon!",
        MOONBASE =
        {
            GENERIC = "Little platform is still missing pieces.",
            BROKEN = "Tiny platform is broken!",
            STAFFED = "Is ready for good fight!",
            WRONGSTAFF = "Feels wrong to Wolfgang.",
            MOONSTAFF = "Sickly little light is not run out.",
        },
        MOONDIAL =
        {
			GENERIC = "Wolfgang see moon reflection, but not his mighty self!",
			NIGHT_NEW = "Moon is hiding.",
			NIGHT_WAX = "Tiny moon is get bigger!",
			NIGHT_FULL = "Moon is very mighty!",
			NIGHT_WANE = "Moon is get sleepy.",
			CAVE = "Moon is shy in cave!",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "M-maybe is not good night for looking up at sky.",
        },
		THULECITE = "Is pretty rock.",
		ARMORRUINS = "Protect me? I don't need it!",
		ARMORSKELETON = "Is scary strong bones.",
		SKELETONHAT = "Puts scary pictures in Wolfgang's head.",
		RUINS_BAT = "Is creepy.",
		RUINSHAT = "Is hat for king.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "No bad light.",
            WARN = "The bad light comes soon.",
            WAXING = "The bad light is here and getting stronger.",
            STEADY = "I think bad light not get stronger.",
            WANING = "Bad light time is ending.",
            DAWN = "Good time is soon.",
            NOMAGIC = "Is safe from bad light.",
		},
		BISHOP_NIGHTMARE = "Is angry man. Should relax.",
		ROOK_NIGHTMARE = "Is no match for my mighty chest!",
		KNIGHT_NIGHTMARE = "Funny metal man.",
		MINOTAUR = "Strong! Like me! I like him!",
		SPIDER_DROPPER = "Scary spider from above.",
		NIGHTMARELIGHT = "Is light, but not good light.",
		NIGHTSTICK = "Wolfgang like fists better.",
		GREENGEM = "Is pretty and cannot be crushed. Like me!",
		MULTITOOL_AXE_PICKAXE = "Chop and dig! I can do that all day.",
		ORANGESTAFF = "Better to walk I think.",
		YELLOWAMULET = "Is glowing yellow.",
		GREENAMULET = "Is so light! Feels like nothingness!",
		SLURPERPELT = "Strange fur clump.",

		SLURPER = "No! No! Stay off head!",
		SLURPER_PELT = "It's still moving!",
		ARMORSLURPER = "Is causing hunger or stopping it?",
		ORANGEAMULET = "For wearing around strong necks.",
		YELLOWSTAFF = "Pretty gem sits in stick.",
		YELLOWGEM = "Pretty rock.",
		ORANGEGEM = "Pretty rock.",
        OPALSTAFF = "Tiny stick make big cold!",
        OPALPRECIOUSGEM = "Is very nice little stone.",
        TELEBASE =
		{
			VALID = "Glow is good sign.",
			GEMS = "Do not think it working.",
		},
		GEMSOCKET =
		{
			VALID = "Pretty rock now hovers.",
			GEMS = "Is empty.",
		},
		STAFFLIGHT = "It hurts to touch.",
        STAFFCOLDLIGHT = "Is cold! Wolfgang will punch!",

        ANCIENT_ALTAR = "Is nasty, creepy altar.",

        ANCIENT_ALTAR_BROKEN = "Is broken altar.",

        ANCIENT_STATUE = "Ugly, ugly, ugly.",

        LICHEN = "I'm lichen this!",
		CUTLICHEN = "Tastes terrible.",

		CAVE_BANANA = "Is tasty!",
		CAVE_BANANA_COOKED = "Is warm and tasty!",
		CAVE_BANANA_TREE = "Hello, upside-down tree.",
		ROCKY = "He is mighty! Like me!",

		COMPASS =
		{
			GENERIC="Is all directions, but no directions.",
			N = "Is North.",
			S = "Is South.",
			E = "Is East.",
			W = "Is West.",
			NE = "Is Northeast.",
			SE = "Is Southeast.",
			NW = "Is Northwest.",
			SW = "Is Southwest.",
		},

        HOUNDSTOOTH = "Puppy tooth!",
        ARMORSNURTLESHELL = "Is sticky inside.",
        BAT = "Flying mousey!",
        BATBAT = "This club makes me feel funny.",
        BATWING = "Is all hairy and gross.",
        BATWING_COOKED = "Crispy!",
        BATCAVE = "It's the hidey hole for the flying mousies!",
        BEDROLL_FURRY = "So comfy!",
        BUNNYMAN = "Hello rabbit!",
        FLOWER_CAVE = "Is light plant.",
        GUANO = "More poop.",
        LANTERN = "It keeps me safe from dark.",
        LIGHTBULB = "Is food?",
        MANRABBIT_TAIL = "Puffy!",
        MUSHROOMHAT = "Is mushy-room... for head!",
        MUSHROOM_LIGHT2 =
        {
            ON = "Tall mushy-room make very pretty light!",
            OFF = "How Wolfgang turn on mushy-room light?",
            BURNT = "No more little lights.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Is nice light. Soft.",
            OFF = "Big mushy-room make little light, maybe.",
            BURNT = "Little light burnt too bright?",
        },
        SLEEPBOMB = "Is bedtime for flinging.",
        MUSHROOMBOMB = "Is dangerous mushy-boom!",
        SHROOM_SKIN = "Is squishy yucky frogman skin!",
        TOADSTOOL_CAP =
        {
            EMPTY = "Is little dirt hole.",
            INGROUND = "Squishy thing in ground.",
            GENERIC = "Tiny mushy-room is no threat to Wolfgang!",
        },
        TOADSTOOL =
        {
            GENERIC = "Bah! Frogman was hiding like coward!",
            RAGE = "Frogman is very strong now!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Tall mushy-room looks very bad!",
            BURNT = "Tall mushy-room is burnt now!",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "Big mushtree is big.",
            BLOOM = "Woah! It's even bigger!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Mushy bush.",
            BLOOM = "It's having fun!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Mushy shrub.",
            BLOOM = "Even smell is strong!",
        },
        MUSHTREE_TALL_WEBBED = "Aw, cheer up!",
        SPORE_TALL =
        {
            GENERIC = "Little blue bug has no wings.",
            HELD = "I make it my pet.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Is tiny red bug?",
            HELD = "I make it my pet.",
        },
        SPORE_SMALL =
        {
            GENERIC = "Nice green bug. Wolfgang will not swat.",
            HELD = "I make it my pet.",
        },
        RABBITHOUSE =
        {
            GENERIC = "I hear nomming inside.",
            BURNT = "Nomming is over.",
        },
        SLURTLE = "Ha! You are slow!",
        SLURTLE_SHELLPIECES = "Is broken.",
        SLURTLEHAT = "Keeps head safe.",
        SLURTLEHOLE = "Hole full of slugs.",
        SLURTLESLIME = "Boom snot!",
        SNURTLE = "Spirally!",
        SPIDER_HIDER = "Is scared spider!",
        SPIDER_SPITTER = "Ptoo! Ptoo!",
        SPIDERHOLE = "Spiders everywhere.",
        SPIDERHOLE_ROCK = "Spiders everywhere.",
        STALAGMITE = "Is pointy.",
        STALAGMITE_TALL = "Rock, reaching for the roof.",

        TURF_CARPETFLOOR = "Step stones.",
        TURF_CHECKERFLOOR = "Step stones.",
        TURF_DIRT = "Step stones.",
        TURF_FOREST = "Step stones.",
        TURF_GRASS = "Step stones.",
        TURF_MARSH = "Step stones.",
        TURF_METEOR = "Step stones.",
        TURF_PEBBLEBEACH = "Step stones.",
        TURF_ROAD = "Step stones.",
        TURF_ROCKY = "Step stones.",
        TURF_SAVANNA = "Step stones.",
        TURF_WOODFLOOR = "Step stones.",

		TURF_CAVE="Step stones.",
		TURF_FUNGUS="Step stones.",
		TURF_FUNGUS_MOON = "Step stones.",
		TURF_ARCHIVE = "Step stones.",
		TURF_SINKHOLE="Step stones.",
		TURF_UNDERROCK="Step stones.",
		TURF_MUD="Step stones.",

		TURF_DECIDUOUS = "Step stones.",
		TURF_SANDY = "Step stones.",
		TURF_BADLANDS = "Step stones.",
		TURF_DESERTDIRT = "Step stones.",
		TURF_FUNGUS_GREEN = "Step stones.",
		TURF_FUNGUS_RED = "Step stones.",
		TURF_DRAGONFLY = "Hot step stones.",

        TURF_SHELLBEACH = "Step stones.",

		POWCAKE = "Is made of nothings!",
        CAVE_ENTRANCE = "Even I am not that mighty.",
        CAVE_ENTRANCE_RUINS = "Even I am not that mighty.",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Who wants to go in scary cave hole, anyway!",
            OPEN = "World has belly button!",
            FULL = "Too many peoples stuffed in there.",
        },
        CAVE_EXIT =
        {
            GENERIC = "Please let Wolfgang out!",
            OPEN = "Is dark and scary down here.",
            FULL = "Please make room! Mighty Wolfgang is scared!",
        },

		MAXWELLPHONOGRAPH = "Is box that sings!",--single player
		BOOMERANG = "Boom! A rang! Ha!",
		PIGGUARD = "Is bad piggie!",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Are you friendly ghost?",
                "Are you friendly ghost?",
            },
            LEVEL2 =
            {
                "Are you friendly ghost?",
                "Are you friendly ghost?",
            },
            LEVEL3 =
            {
                "Are you friendly ghost?",
                "Are you friendly ghost?",
            },
		},
		ADVENTURE_PORTAL = "Is mouth door! Say Ahhhhh!",
		AMULET = "Is very pretty.",
		ANIMAL_TRACK = "Animal went this way.",
		ARMORGRASS = "Is prickly.",
		ARMORMARBLE = "Tie rocks to many muscles.",
		ARMORWOOD = "Is almost strong as belly!",
		ARMOR_SANITY = "Is like wearing scary little rag!",
		ASH =
		{
			GENERIC = "Is skeleton of fire.",
			REMAINS_GLOMMERFLOWER = "Is burned pieces of flower from teleport!",
			REMAINS_EYE_BONE = "Is burned pieces of eyebone from teleport!",
			REMAINS_THINGIE = "Is burned pieces of some thing. Is dead now...",
		},
		AXE = "Chop!",
		BABYBEEFALO =
		{
			GENERIC = "Baby hair-cow!",
		    SLEEPING = "Sleepy baby hair-cow!",
        },
        BUNDLE = "Is little surprise inside, maybe.",
        BUNDLEWRAP = "Is for hiding goodies.",
		BACKPACK = "Is for carry more thing.",
		BACONEGGS = "Food has yolk! And meat! More strong!",
		BANDAGE = "Can fix people!",
		BASALT = "Is stronger even than me!", --removed
		BEARDHAIR = "Gross. These are not from my face.",
		BEARGER = "Wolfgang not want to fight big bear.",
		BEARGERVEST = "Big bear shirt.",
		ICEPACK = "Furry bag.",
		BEARGER_FUR = "Is like hair on Wolfgang chest.",
		BEDROLL_STRAW = "Nap time!",
		BEEQUEEN = "Is giant lady bee!",
		BEEQUEENHIVE =
		{
			GENERIC = "Sticky stompy patch of muck!",
			GROWING = "Little hive is get bigger!",
		},
        BEEQUEENHIVEGROWN = "Wolfgang's mighty punches do nothing.",
        BEEGUARD = "Busy buzzy needle men!",
        HIVEHAT = "Makes Wolfgang feel special.",
        MINISIGN =
        {
            GENERIC = "Tiny picture is worth many, tinier words.",
            UNDRAWN = "Sign needs little scribbles!",
        },
        MINISIGN_ITEM = "Wolfgang will help punch into ground!",
		BEE =
		{
			GENERIC = "Is fat and angry-looking.",
			HELD = "Is safely in my pocket.",
		},
		BEEBOX =
		{
			READY = "Is ready for harvest!",
			FULLHONEY = "Is ready for harvest!",
			GENERIC = "Many bees!",
			NOHONEY = "It has no honey.",
			SOMEHONEY = "Bees are busy.",
			BURNT = "Bees are burned.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Is no more room for more mushy-rooms!",
			LOTS = "So many little mushy-rooms!",
			SOME = "Little mushy-rooms is start to grow.",
			EMPTY = "Is nothing.",
			ROTTEN = "Dead log is need to be replaced.",
			BURNT = "Log is not looking mighty!",
			SNOWCOVERED = "Mushy-rooms not mighty enough to fight snow!",
		},
		BEEFALO =
		{
			FOLLOWER = "Hair-cow follow me!",
			GENERIC = "Is hair-cow thing!",
			NAKED = "Hair-cow has no more hair.",
			SLEEPING = "Hair-cow is sleeping.",
            --Domesticated states:
            DOMESTICATED = "Hair-cow so fluffy and nice!",
            ORNERY = "You are feisty!",
            RIDER = "Like I'm back in cavalry!",
            PUDGY = "A critter after own heart!",
            MYPARTNER = "Is good hair-cow, very good.",
		},

		BEEFALOHAT = "Is good hat!",
		BEEFALOWOOL = "Clothes made of hair-cow.",
		BEEHAT = "Is hat for to protect from stinger bees.",
        BEESWAX = "Bee goop is smell nice.",
		BEEHIVE = "Oh, beehive!",
		BEEMINE = "Is ball full of angry bees.",
		BEEMINE_MAXWELL = "Is ball full of angry bitebugs.",--removed
		BERRIES = "Is tasty!",
		BERRIES_COOKED = "Is more tasty!",
        BERRIES_JUICY = "Is extra sweet and juicy!",
        BERRIES_JUICY_COOKED = "Sweet, juicy berries is ready for eating!",
		BERRYBUSH =
		{
			BARREN = "I need to poop on it.",
			WITHERED = "Is too hot for bush.",
			GENERIC = "Is full of food-balls!",
			PICKED = "Eating part is gone.",
			DISEASED = "Is weak. Sickly!",--removed
			DISEASING = "Is looking shrivelly.",--removed
			BURNING = "Ah! Is burning!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "I need to poop on it to make juicy again.",
			WITHERED = "Is it dead?",
			GENERIC = "I will eat you!",
			PICKED = "Eating part is gone.",
			DISEASED = "Is weak. Sickly!",--removed
			DISEASING = "Is looking shrivelly.",--removed
			BURNING = "Ah! Is burning!",
		},
		BIGFOOT = "Foot is too big!",--removed
		BIRDCAGE =
		{
			GENERIC = "Is home for birdies.",
			OCCUPIED = "Hello birdy!",
			SLEEPING = "I should be quiet!",
			HUNGRY = "I hear tiny grumbles!",
			STARVING = "His tiny stomach is empty!",
			DEAD = "Birdy? Are you okay?",
			SKELETON = "He is not okay.",
		},
		BIRDTRAP = "This will catch bird!",
		CAVE_BANANA_BURNT = "Is crisp.",
		BIRD_EGG = "Poor birdy.",
		BIRD_EGG_COOKED = "Yum!",
		BISHOP = "Padre!",
		BLOWDART_FIRE = "Careful, Wolfgang.",
		BLOWDART_SLEEP = "Dart do sleeping to enemies.",
		BLOWDART_PIPE = "Dart do pain to enemies.",
		BLOWDART_YELLOW = "Do not know if Wolfgang should be allowed to have this.",
		BLUEAMULET = "Would make good ice cube!",
		BLUEGEM = "Pretty rock.",
		BLUEPRINT =
		{
            COMMON = "Pretty pictures!",
            RARE = "Very, very fancy pictures!",
        },
        SKETCH = "Picture will help Wolfgang carve nice rocks!",
		BLUE_CAP = "Is good for tired muscles, I think.",
		BLUE_CAP_COOKED = "Is not same.",
		BLUE_MUSHROOM =
		{
			GENERIC = "Is mushy room.",
			INGROUND = "Mushy room is hiding!",
			PICKED = "Is taken already.",
		},
		BOARDS = "Log was broken to make board!",
		BONESHARD = "Wolfgang crush into even smaller bones!",
		BONESTEW = "Is stew full of strong meat.",
		BUGNET = "Catch bugs.",
		BUSHHAT = "So sneaky!",
		BUTTER = "Is buttery, and taste like insect.",
		BUTTERFLY =
		{
			GENERIC = "Is pretty flutterby!",
			HELD = "My pet!",
		},
		BUTTERFLYMUFFIN = "Wolfgang did not know about bug muffin. Would like to taste.",
		BUTTERFLYWINGS = "No fly without wings!",
		BUZZARD = "Carry on.",

		SHADOWDIGGER = "Ha ha! Tiny men should dance for amusement!",

		CACTUS =
		{
			GENERIC = "Wolfgang not like sharp plant.",
			PICKED = "Ha! Is flat plant.",
		},
		CACTUS_MEAT_COOKED = "Is safe now.",
		CACTUS_MEAT = "Spiky plant meat.",
		CACTUS_FLOWER = "Is not worth it.",

		COLDFIRE =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Good bye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not cold enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		CAMPFIRE =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Goodbye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not hot enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		CANE = "To walk AND hit things!",
		CATCOON = "Wolfgang does not trust it.",
		CATCOONDEN =
		{
			GENERIC = "Stump is suspicious.",
			EMPTY = "Wolfgang more comfortable now that stump is empty.",
		},
		CATCOONHAT = "Hat of untrust-y-ness.",
		COONTAIL = "Wiggly cat part!",
		CARROT = "Is food. I guess.",
		CARROT_COOKED = "Is not more like meat after do cooking.",
		CARROT_PLANTED = "Is hiding?",
		CARROT_SEEDS = "Seeds is too small.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Friends make little pictures to help Wolfgang not get lost!",
			BURNING = "Is no good!",
			BURNT = "No more little pictures.",
		},
		WATERMELON_SEEDS = "Maybe will grow into tasty snacks?",
		CAVE_FERN = "Pretty plant!",
		CHARCOAL = "Is like holding tiny dead tree.",
        CHESSPIECE_PAWN = "Little man is wearing little hat!",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Does not look like castle to Wolfgang.",
            STRUGGLE = "Wolfgang does not like moving statues!!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "Is good horsey, Wolfgang thinks.",
            STRUGGLE = "Wolfgang does not like moving statues!!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Weak little rock man looks nice.",
            STRUGGLE = "Wolfgang does not like moving statues!!",
        },
        CHESSPIECE_MUSE = "Faceless lady make Wolfgang uncomfortable.",
        CHESSPIECE_FORMAL = "Looks very not-mighty.",
        CHESSPIECE_HORNUCOPIA = "Why stone food hurt mouth?",
        CHESSPIECE_PIPE = "Might be good for lifting!",
        CHESSPIECE_DEERCLOPS = "Is scary monster statue.",
        CHESSPIECE_BEARGER = "Terrifying beast statue!",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Bad monster made of stone.",
        },
        CHESSPIECE_DRAGONFLY = "Is fiery killbeast, but stone.",
		CHESSPIECE_MINOTAUR = "Strong beast made from strong stone!",
        CHESSPIECE_BUTTERFLY = "Is look like little flutterby, but bigger!",
        CHESSPIECE_ANCHOR = "Is big. And heavy. Wolfgang would like to lift.",
        CHESSPIECE_MOON = "Is look just like sky cheese!",
        CHESSPIECE_CARRAT = "Wolfgang liked racing leggy carrots.",
        CHESSPIECE_MALBATROSS = "How will bird fly if it is stone?",
        CHESSPIECE_CRABKING = "Wolfgang was seasick for days...",
        CHESSPIECE_TOADSTOOL = "Wolfgang more handsome than ugly froggy.",
        CHESSPIECE_STALKER = "Ha! Wolfgang more mighty than statue.",
        CHESSPIECE_KLAUS = "Is that time of year already?",
        CHESSPIECE_BEEQUEEN = "Mighty statue stays mighty still.",
        CHESSPIECE_ANTLION = "Wolfgang will not battle it in staring contest.",
        CHESSPIECE_BEEFALO = "Is look almost like real hair-cow.",
		CHESSPIECE_KITCOON = "Wolfgang can lift twice as many!",
		CHESSPIECE_CATCOON = "Ha! Is easy to find this one.",
        CHESSPIECE_GUARDIANPHASE3 = "Wolfgang glad is just statue.",
        CHESSPIECE_EYEOFTERROR = "No like the way it look at Wolfgang.",
        CHESSPIECE_TWINSOFTERROR = "Brrr, still sends chill down Wolfgang's spine.",

        CHESSJUNK1 = "Metal junk.",
        CHESSJUNK2 = "Metal junk.",
        CHESSJUNK3 = "Metal junk.",
		CHESTER = "Strange box with legs.",
		CHESTER_EYEBONE =
		{
			GENERIC = "It is eyebone. Eyebone connect to facebone.",
			WAITING = "It sleeps now.",
		},
		COOKEDMANDRAKE = "Little plant man is food?",
		COOKEDMEAT = "I made meat good with fire!",
		COOKEDMONSTERMEAT = "I still do not want to eat this.",
		COOKEDSMALLMEAT = "It is even smaller cooked!",
		COOKPOT =
		{
			COOKING_LONG = "This take long time.",
			COOKING_SHORT = "Is almost cook!",
			DONE = "Is time to eat!",
			EMPTY = "Wolfgang will cook good meal for friends, meal like home!",
			BURNT = "Pot is dead.",
		},
		CORN = "Is corn. What expect?",
		CORN_COOKED = "Pop pop pop! Ha ha, funny corn.",
		CORN_SEEDS = "Is seeds for growing.",
        CANARY =
		{
			GENERIC = "Is small yellow bird!",
			HELD = "Small bird fit easily in big Wolfgang hands.",
		},
        CANARY_POISONED = "Bird is okay?",

		CRITTERLAB = "Wolfgang hear little noises inside.",
        CRITTER_GLOMLING = "Flying bug friend!",
        CRITTER_DRAGONLING = "Mighty pet! Very good!",
		CRITTER_LAMB = "Is walking fluff!",
        CRITTER_PUPPY = "I am call him Pupgang!",
        CRITTER_KITTEN = "Small fur is Wolfgang's friend.",
        CRITTER_PERDLING = "Bird baby is weak, but good.",
		CRITTER_LUNARMOTHLING = "Strong Wolfgang will protect soft flutterby.",

		CROW =
		{
			GENERIC = "I do not like birds. Too fragile.",
			HELD = "He is squawky.",
		},
		CUTGRASS = "Is pile of grass.",
		CUTREEDS = "Is clump of reeds.",
		CUTSTONE = "Rock was crushed to make brick!",
		DEADLYFEAST = "Look like evil food.", --unimplemented
		DEER =
		{
			GENERIC = "Not very mighty. More fragile.",
			ANTLER = "Fuzzy fragile beast got mightier.",
		},
        DEER_ANTLER = "Is only mighty part of fragile beast.",
        DEER_GEMMED = "You stand no chance in fight with Wolfgang!",
		DEERCLOPS = "He looks mightier than me!",
		DEERCLOPS_EYEBALL = "Yuck yuck yuck!",
		EYEBRELLAHAT =	"Is always looking up.",
		DEPLETED_GRASS =
		{
			GENERIC = "Is tuft of grass.",
		},
        GOGGLESHAT = "Makes Wolfgang look very mighty.",
        DESERTHAT = "Sand cannot stop Wolfgang!",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "Dirty dirt.",
		DIVININGROD =
		{
			COLD = "The robot box is talking.", --singleplayer
			GENERIC = "Is robot box.", --singleplayer
			HOT = "Robot box is scaring me!", --singleplayer
			WARM = "Ha! That is good one, robot box!", --singleplayer
			WARMER = "Robot box is getting angry...", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "What is purpose?", --singleplayer
			READY = "Rod thing need key to make start.", --singleplayer
			UNLOCKED = "Rod thing is on!", --singleplayer
		},
		DIVININGRODSTART = "Is funny rod thing.", --singleplayer
		DRAGONFLY = "I confuse... Is dragonfly, or dragon-fly?",
		ARMORDRAGONFLY = "Wolfgang not need protection.",
		DRAGON_SCALES = "Glowy scales.",
		DRAGONFLYCHEST = "Chest is not afraid of fire.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "Is very cute!",
			GENERIC = "Scaly pot for making hotness.", --no gems
			NORMAL = "Brainlady warned not to touch pot with bare hands.", --one gem
			HIGH = "Wolfgang hope does not burn moustache.", --two gems
		},

        HUTCH = "You are creepy.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Is tiny swimming teeth.",
            WAITING = "Is tiny floating teeth.",
        },
		LAVASPIT =
		{
			HOT = "Is hot mouth germs.",
			COOL = "Is cold, hard mouth germs.",
		},
		LAVA_POND = "Is not time for swimming!",
		LAVAE = "I must run!",
		LAVAE_COCOON = "Maybe cold bug is friend?",
		LAVAE_PET =
		{
			STARVING = "Tiny baby is starving!",
			HUNGRY = "Tiny baby is hungry.",
			CONTENT = "Tiny baby looks content.",
			GENERIC = "Tiny baby seems happy.",
		},
		LAVAE_EGG =
		{
			GENERIC = "Is made of rock?",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Little egg is shivering.",
			COMFY = "Little egg... seems comfortable.",
		},
		LAVAE_TOOTH = "What a mighty tooth!",

		DRAGONFRUIT = "Is funny-looking fruit.",
		DRAGONFRUIT_COOKED = "Is cooked but still look funny.",
		DRAGONFRUIT_SEEDS = "Is seeds for growing.",
		DRAGONPIE = "Pie made of funny red fruit.",
		DRUMSTICK = "Leg meat for make legs more strong.",
		DRUMSTICK_COOKED = "Eat off bone is good.",
		DUG_BERRYBUSH = "He is cold and lonely.",
		DUG_BERRYBUSH_JUICY = "He is cold, and juicy.",
		DUG_GRASS = "He is cold and lonely.",
		DUG_MARSH_BUSH = "He is cold and lonely.",
		DUG_SAPLING = "He is cold and lonely.",
		DURIAN = "Is spiky smelly fruit.",
		DURIAN_COOKED = "Now is hot spiky smelly fruit.",
		DURIAN_SEEDS = "Is seeds for growing.",
		EARMUFFSHAT = "Is could make me look like little bunny!",
		EGGPLANT = "Is not egg!",
		EGGPLANT_COOKED = "Has no yolk! Yolk is strongest part!",
		EGGPLANT_SEEDS = "Is seeds for growing.",

		ENDTABLE =
		{
			BURNT = "Is burny bits.",
			GENERIC = "Little flowers are weak, but look nice.",
			EMPTY = "Puny table will not hold Wolfgang's weight.",
			WILTED = "Little flowers are weaker than usual.",
			FRESHLIGHT = "Wolfgang does not like dark.",
			OLDLIGHT = "Please do not go out, little light.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "Broke it.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You lose, tiny tree!",
			POISON = "Is big and angry tree.",
			GENERIC = "Hello, tree!",
		},
		ACORN = "I could crush the tree-seed with my hands!",
        ACORN_SAPLING = "It will be tree soon.",
		ACORN_COOKED = "Tree has been cooked out of nut.",
		BIRCHNUTDRAKE = "Is small and angry nut.",
		EVERGREEN =
		{
			BURNING = "Is broke.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You stood no chance!",
			GENERIC = "Hello, tree!",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Is broke.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You stood no chance!",
			GENERIC = "Cheer up, tree!",
		},
		TWIGGYTREE =
		{
			BURNING = "Is broke.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You stood no chance!",
			GENERIC = "Wolfgang will snap like toothpick!",
			DISEASED = "Is weak. Sickly!", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Grow, grow little tree!",
        TWIGGY_OLD = "Wolfgang wishes to put weak tree out of misery!",
		TWIGGY_NUT = "Little cone make big tree!",
		EYEPLANT = "They are not what they seem.",
		INSPECTSELF = "Everyone! Come watch Wolfgang flex!",
		FARMPLOT =
		{
			GENERIC = "Will grow mighty crops here!",
			GROWING = "Grow my little friends! Grow!",
			NEEDSFERTILIZER = "Dirt is not dirty enough to make plants.",
			BURNT = "No more growing.",
		},
		FEATHERHAT = "Is silly hat of feather. Could make Wolfgang bird?",
		FEATHER_CROW = "Is feather of bird black.",
		FEATHER_ROBIN = "Is feather of bird red.",
		FEATHER_ROBIN_WINTER = "Is feather of bird white.",
		FEATHER_CANARY = "Is feather of bird yellow.",
		FEATHERPENCIL = "Wolfgang must stick pinky out when holding it.",
        COOKBOOK = "Is book of things to fill Wolfgang's mighty belly!",
		FEM_PUPPET = "Scary chair scares her!", --single player
		FIREFLIES =
		{
			GENERIC = "Sparkly!",
			HELD = "My pocket is sparkles!",
		},
		FIREHOUND = "Bark!",
		FIREPIT =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Good bye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not hot enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		COLDFIREPIT =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Good bye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not cold enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		FIRESTAFF = "Is staff for make fire. Careful, Wolfgang.",
		FIRESUPPRESSOR =
		{
			ON = "I can throw better.",
			OFF = "Machine know Wolfgang is stronger.",
			LOWFUEL = "Are you hungry, machine?",
		},

		FISH = "Is fishy.",
		FISHINGROD = "Is for get fishy from pond place.",
		FISHSTICKS = "Ha ha, is funny name.",
		FISHTACOS = "Wolfgang hope is not too spicy.",
		FISH_COOKED = "Meat from water still make Wolfgang strong.",
		FLINT = "Is rock, but eh, pointy.",
		FLOWER =
		{
            GENERIC = "They are very pretty.",
            ROSE = "Wolfgang tried to crush it, but it pricked him.",
        },
        FLOWER_WITHERED = "Aw, this one is sad.",
		FLOWERHAT = "Is so pretty!",
		FLOWER_EVIL = "Is not potato.",
		FOLIAGE = "Pretty plant is dead now.",
		FOOTBALLHAT = "To protect head!",
        FOSSIL_PIECE = "Is tiny bone!",
        FOSSIL_STALKER =
        {
			GENERIC = "Is not look done yet.",
			FUNNY = "Eh, maybe we take apart.",
			COMPLETE = "Is look good! Mighty!",
        },
        STALKER = "Skeleton should not be walking!",
        STALKER_ATRIUM = "Scary man!",
        STALKER_MINION = "I do not like it!",
        THURIBLE = "Is for monster control.",
        ATRIUM_OVERGROWTH = "Wolfgang cannot read.",
		FROG =
		{
			DEAD = "Is delicacy in my country.",
			GENERIC = "Hey little froggy, froggy.",
			SLEEPING = "Is asleep.",
		},
		FROGGLEBUNWICH = "Is sandwich with tasty leg meat.",
		FROGLEGS = "Is delicacy in my country!",
		FROGLEGS_COOKED = "Is mostly taste like chicken.",
		FRUITMEDLEY = "Is cup of teensy fruits.",
		FURTUFT = "Fur from bear?",
		GEARS = "Ah ha! Who is bigger muscles now?",
		GHOST = "Aaaaaaaaaaah!",
		GOLDENAXE = "Fancy axe more good for chop.",
		GOLDENPICKAXE = "Fancy pickaxe do better smash.",
		GOLDENPITCHFORK = "Fancy pitchfork good for stab ground.",
		GOLDENSHOVEL = "Fancy shovel is good hole maker.",
		GOLDNUGGET = "Money is for tiny men!",
		GRASS =
		{
			BARREN = "It needs poop.",
			WITHERED = "Grass has been defeated by heat.",
			BURNING = "Not good!",
			GENERIC = "Is grass.",
			PICKED = "The grass has been defeated!",
			DISEASED = "Is weak. Sickly!", --unimplemented
			DISEASING = "Is looking shrivelly.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Lizard looks flimsy.",
			DISEASED = "It looks worst than before.", --unimplemented
		},
		GREEN_CAP = "Is for salads. Blech.",
		GREEN_CAP_COOKED = "Is not same.",
		GREEN_MUSHROOM =
		{
			GENERIC = "Is mushy room.",
			INGROUND = "Mushy room is hiding!",
			PICKED = "Is taken already.",
		},
		GUNPOWDER = "Boom pepper!",
		HAMBAT = "Is still good.",
		HAMMER = "Needs sickle!",
		HEALINGSALVE = "Helps friends with boo-boos.",
		HEATROCK =
		{
			FROZEN = "Brrr! Is cold rock!",
			COLD = "Rock is a little bit cold.",
			GENERIC = "This round rock is like my head!",
			WARM = "Is pretty normal rock.",
			HOT = "Is hot enough for Wolfgang!",
		},
		HOME = "Tiny house for weaklings!",
		HOMESIGN =
		{
			GENERIC = "Is no time for reading signs!",
            UNWRITTEN = "Practice my letters!",
			BURNT = "Sign can't be read.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "Is no time for reading signs!",
            UNWRITTEN = "Practice my letters!",
			BURNT = "Sign can't be read.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Is no time for reading signs!",
            UNWRITTEN = "Practice my letters!",
			BURNT = "Sign can't be read.",
		},
		HONEY = "Is yum!",
		HONEYCOMB = "Bee used to live inside.",
		HONEYHAM = "Big meat with sweet is good meat.",
		HONEYNUGGETS = "Small meats with sweet still is good meat.",
		HORN = "Is hair-cow horn. Wolfgang hear hair-cow.",
		HOUND = "Woof!",
		HOUNDCORPSE =
		{
			GENERIC = "Wolfgang does not like look of this.",
			BURNING = "Fire is make yucky puppy go away.",
			REVIVING = "Wolfgang would like to run now!",
		},
		HOUNDBONE = "Wimpy woof dog was not strong enough.",
		HOUNDMOUND = "Is house of bones.",
		ICEBOX = "Box what makes cold!",
		ICEHAT = "Why put big ice on head?",
		ICEHOUND = "Bow wow!",
		INSANITYROCK =
		{
			ACTIVE = "Is in my way.",
			INACTIVE = "Hah. I step over tiny obstacle.",
		},
		JAMMYPRESERVES = "Oozes like tiny enemy I crush in hand.",

		KABOBS = "Eat off stick is good.",
		KILLERBEE =
		{
			GENERIC = "Angry bee!",
			HELD = "My angry bee!",
		},
		KNIGHT = "Horsey horse!",
		KOALEFANT_SUMMER = "Nose meat!",
		KOALEFANT_WINTER = "So soft, I want to squish it!",
		KRAMPUS = "Scary goat man! Run!",
		KRAMPUS_SACK = "Goat man finally give up his sack!",
		LEIF = "Wood man!",
		LEIF_SPARSE = "Wood man!",
		LIGHTER  = "Is tiny firebox!",
		LIGHTNING_ROD =
		{
			CHARGED = "Ooooh, sparks!",
			GENERIC = "Is wire in sky!",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "Hello, goat.",
			CHARGED = "Is flash before eyes.",
		},
		LIGHTNINGGOATHORN = "Tiny lightning bone.",
		GOATMILK = "Milk for muscles!",
		LITTLE_WALRUS = "You think you are mightier than old man?",
		LIVINGLOG = "Creepy face log!",
		LOG =
		{
			BURNING = "When I stick my hand over it, it tickles.",
			GENERIC = "Remains of tree-fights!",
		},
		LUCY = "Wolfgang like a sharp missus.",
		LUREPLANT = "You cannot fool Wolfgang!",
		LUREPLANTBULB = "Ah ha! Who is tricky now?",
		MALE_PUPPET = "Scary chair scares him!", --single player

		MANDRAKE_ACTIVE = "Little plant man friend!",
		MANDRAKE_PLANTED = "Is strange plant.",
		MANDRAKE = "Little plant man is died!",

        MANDRAKESOUP = "Little plant man is for make soup!",
        MANDRAKE_COOKED = "Little plant man is ready for eating!",
        MAPSCROLL = "No little pictures! Just paper.",
        MARBLE = "I can lift!",
        MARBLEBEAN = "Brainlady says is not for eat.",
        MARBLEBEAN_SAPLING = "Rock bush is growing!",
        MARBLESHRUB = "Rock is strongest bush!",
        MARBLEPILLAR = "Is too heavy to lift.",
        MARBLETREE = "Do not try punch tree.",
        MARSH_BUSH =
        {
			BURNT = "Spiky bush is gone now.",
            BURNING = "Uh oh. Spiky fire.",
            GENERIC = "Is thorny.",
            PICKED = "Thorns hurt.",
        },
        BURNT_MARSH_BUSH = "Is burnt now.",
        MARSH_PLANT = "Is plant.",
        MARSH_TREE =
        {
            BURNING = "Spikes is burned now!",
            BURNT = "Is spiky and black now.",
            CHOPPED = "Spikes is chopped now!",
            GENERIC = "Is spiky.",
        },
        MAXWELL = "A fancy suit is no match for my muscles!",--single player
        MAXWELLHEAD = "Scary head is twelve feet tall!",--removed
        MAXWELLLIGHT = "Scary light!",--single player
        MAXWELLLOCK = "Scary lock!",--single player
        MAXWELLTHRONE = "Scary chair!",--single player
        MEAT = "Meat makes me strong!",
        MEATBALLS = "Ball of meats make me strong!",
        MEATRACK =
        {
            DONE = "Yum, meaty leather!",
            DRYING = "Dry meaty things! Dry!",
            DRYINGINRAIN = "Go away, rain! Meat is drying!",
            GENERIC = "For drying many meats!",
            BURNT = "Cannot dry meat now.",
            DONE_NOTMEAT = "Is very good and dry now!",
            DRYING_NOTMEAT = "Wolfgang could punch water out, maybe?",
            DRYINGINRAIN_NOTMEAT = "Sky tears is re-wetting Wolfgang's dry things!",
        },
        MEAT_DRIED = "Look like leather, taste like meat.",
        MERM = "Is fishy man!",
        MERMHEAD =
        {
            GENERIC = "What a handsome devil!",
            BURNT = "Not so nice looking now.",
        },
        MERMHOUSE =
        {
            GENERIC = "The house was not strong enough.",
            BURNT = "The house was really not strong enough.",
        },
        MINERHAT = "Lamp for put on head.",
        MONKEY = "Ugly monkey man!",
        MONKEYBARREL = "This... thing. It smells not so good.",
        MONSTERLASAGNA = "Taste like hairs and meats with noodle.",
        FLOWERSALAD = "Is not spinach, but maybe still work!",
        ICECREAM = "Well, is Sunday after all.",
        WATERMELONICLE = "Ha! Melon on a stick.",
        TRAILMIX = "Berries and nuts, berries and nuts!",
        HOTCHILI = "Haha, nothing is too spicy for Wolfgang!",
        GUACAMOLE = "Wolfgang does not trust green mush.",
        MONSTERMEAT = "It is not looking like food.",
        MONSTERMEAT_DRIED = "Look like leather, taste like leather.",
        MOOSE = "Very strange creature.",
        MOOSE_NESTING_GROUND = "Is big bird baby bed!",
        MOOSEEGG = "Breakfast for whole family!",
        MOSSLING = "Mmmm. Is still breakfast, I think.",
        FEATHERFAN = "Ha! Is as big as head!",
        MINIFAN = "It's so twirly when I run! Haha!",
        GOOSE_FEATHER = "Tickle tickle tickle!",
        STAFF_TORNADO = "Spin and spin!",
        MOSQUITO =
        {
            GENERIC = "Reminds me of uncle!",
            HELD = "No more blood for you!",
        },
        MOSQUITOSACK = "Uncle did not have gut like this.",
        MOUND =
        {
            DUG = "Sorry, dead peoples.",
            GENERIC = "Scary! Is probably full of bones!",
        },
        NIGHTLIGHT = "Is strange glow.",
        NIGHTMAREFUEL = "Scary stuff.",
        NIGHTSWORD = "Is real? Is not real? Is sharp!",
        NITRE = "Is rock, but different.",
        ONEMANBAND = "Is big and loud. I like!",
        OASISLAKE =
		{
			GENERIC = "Splishes and splashes.",
			EMPTY = "Lake should be here!",
		},
        PANDORASCHEST = "Fancy box!",
        PANFLUTE = "You want Wolfgang play folk song?",
        PAPYRUS = "Is like paper.",
        WAXPAPER = "Strange paper not for make scribblemarks.",
        PENGUIN = "Funny walking birds!",
        PERD = "Dumb bird is take all berries!",
        PEROGIES = "Wolfgang love pierogi!",
        PETALS = "These smell nice.",
        PETALS_EVIL = "They make my brain hurt.",
        PHLEGM = "Aha ha ha! Boogers! Oh ho ho!",
        PICKAXE = "Pick!",
        PIGGYBACK = "Smelly bag!",
        PIGHEAD =
        {
            GENERIC = "Why long face?",
            BURNT = "Why no face?",
        },
        PIGHOUSE =
        {
            FULL = "Come out and fight, pig man!",
            GENERIC = "Door is too small for my broad shoulders.",
            LIGHTSOUT = "Where did he go?",
            BURNT = "Pig home is gone.",
        },
        PIGKING = "Ha! Is good people!",
        PIGMAN =
        {
            DEAD = "No! The pig is dead!",
            FOLLOWER = "Is friend now!",
            GENERIC = "Hello pig. How are you?",
            GUARD = "Does he even lift?",
            WEREPIG = "Angry piggie!",
        },
        PIGSKIN = "Why long butt? Ha ha, Wolfgang is funny man.",
        PIGTENT = "Is tent of pigs.",
        PIGTORCH = "How is fire made?",
        PINECONE = "I could crush the tree-seed with my hands!",
        PINECONE_SAPLING = "It will be tree soon.",
        LUMPY_SAPLING = "It pushed right up from the dirt!",
        PITCHFORK = "Reminds me of childhood.",
        PLANTMEAT = "What is this? Meat for baby man?",
        PLANTMEAT_COOKED = "Is slightly better now.",
        PLANT_NORMAL =
        {
            GENERIC = "Leafy!",
            GROWING = "Is still growing.",
            READY = "Mmmm. Is tasty now.",
            WITHERED = "Is sad and dried plant.",
        },
        POMEGRANATE = "Look like smartypants brain.",
        POMEGRANATE_COOKED = "Ha ha ha! Brain is cooked! Not so smart now.",
        POMEGRANATE_SEEDS = "Is seeds for growing.",
        POND = "Is all wet.",
        POOP = "Smelly!",
        FERTILIZER = "Bucket full of smelly.",
        PUMPKIN = "Is big as head of weakling man! Not Wolfgang head.",
        PUMPKINCOOKIE = "Is tasty cookie.",
        PUMPKIN_COOKED = "Very gourd!",
        PUMPKIN_LANTERN = "Now is actual head! Wolfgang afraid!",
        PUMPKIN_SEEDS = "Is seeds for growing.",
        PURPLEAMULET = "This amulet... it frightens Wolfgang.",
        PURPLEGEM = "Prettier rock.",
        RABBIT =
        {
            GENERIC = "Tiny rabbit! Hide from me!",
            HELD = "He is my friend.",
        },
        RABBITHOLE =
        {
            GENERIC = "You can not hide forever, jumping meat!",
            SPRING = "Is busy time in rabbit home.",
        },
        RAINOMETER =
        {
            GENERIC = "Splish! Splash!",
            BURNT = "Crackle!",
        },
        RAINCOAT = "Dry is nice.",
        RAINHAT = "Is like water off mole's back.",
        RATATOUILLE = "Is food. Sort of.",
        RAZOR = "My skin is too strong for hairs!",
        REDGEM = "Pretty rock.",
        RED_CAP = "Oh! Is pretty and shiny!",
        RED_CAP_COOKED = "Is not same.",
        RED_MUSHROOM =
        {
            GENERIC = "Is mushy room.",
            INGROUND = "Mushy room is hiding!",
            PICKED = "Is taken already.",
        },
        REEDS =
        {
            BURNING = "Not good!",
            GENERIC = "Is watery grass.",
            PICKED = "Watery grass has been beaten!",
        },
        RELIC = "Is junk?",
        RUINS_RUBBLE = "I will make better with crushing.",
        RUBBLE = "Broken house stuff.",
        RESEARCHLAB =
        {
            GENERIC = "I am not sure how I feel about... science.",
            BURNT = "Science not so strong after all.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "I am not sure how I feel about... science.",
            BURNT = "Science not so strong after all.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "What has Wolfgang done?",
            BURNT = "Well, is over now.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "Hat not just for head.",
            BURNT = "Hat also for burning.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "I'm not going to die.",
            BURNT = "Better him than Wolfgang.",
        },
        RESURRECTIONSTONE = "Hop on rock!",
        ROBIN =
        {
            GENERIC = "Is pretty red color bird.",
            HELD = "Is happy bird in pocket.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Is pretty white color bird.",
            HELD = "Is fluffy bird. Nice bird.",
        },
        ROBOT_PUPPET = "Scary chair scares them!", --single player
        ROCK_LIGHT =
        {
            GENERIC = "A pile of crusty rocks!",--removed
            OUT = "Ha! More thing to smash!",--removed
            LOW = "Is getting cold.",--removed
            NORMAL = "Liquid fire!",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Is no trouble to lift boulder.",
            RAISED = "Wolfgang must move other rocks.",
        },
        ROCK = "Everyone watch! Wolfgang will deadlift!",
        PETRIFIED_TREE = "Now I punch it apart!",
        ROCK_PETRIFIED_TREE = "Now I punch it apart!",
        ROCK_PETRIFIED_TREE_OLD = "Now I punch it apart!",
        ROCK_ICE =
        {
            GENERIC = "Rocks made of water.",
            MELTED = "I cannot grab water.",
        },
        ROCK_ICE_MELTED = "I cannot grab water.",
        ICE = "Good for refreshing snack.",
        ROCKS = "Is rock. What you not get?",
        ROOK = "This one jumps the queen!",
        ROPE = "Strong! Like me!",
        ROTTENEGG = "Stinky!",
        ROYAL_JELLY = "Sticky power goo!",
        JELLYBEAN = "Little tiny taste beans.",
        SADDLE_BASIC = "Just need creature mighty enough to hold me!",
        SADDLE_RACE = "Butterflies feel soft under Wolfgang's strong butt!",
        SADDLE_WAR = "We ride like kings!",
        SADDLEHORN = "I won't hurt you, hair cow!",
        SALTLICK = "Heh heh. Hair cow has funny tongue!",
        BRUSH = "For brush really strong hair!",
		SANITYROCK =
		{
			ACTIVE = "Is beautiful!",
			INACTIVE = "Is hiding underground.",
		},
		SAPLING =
		{
			BURNING = "Oops.",
			WITHERED = "Puny tree could not take heat.",
			GENERIC = "Puny tree! I am stronger than you!",
			PICKED = "Ha! Ha! Ha! Tree is floppy!",
			DISEASED = "Is weak. Sickly!", --removed
			DISEASING = "Is look even more puny.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Ha! Is not man! Is straw!",
			BURNING = "Little straw man is burning!",
			BURNT = "Little straw man is dead.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Is table for rocks!",
			BLOCK = "Is time for arts and crafts!",
			SCULPTURE = "Does not compare to chiseled jaw of Wolfgang!",
			BURNT = "Is burny bits.",
   		},
        SCULPTURE_KNIGHTHEAD = "Everyone! Watch Wolfgang carry horse head!",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "Is big fancy rock!",
			UNCOVERED = "Hidden marble man has big booboo.",
			FINISHED = "Booboo is all better!",
			READY = "Stone is getting scarier!",
		},
        SCULPTURE_BISHOPHEAD = "Watch Wolfgang lift little marble head!",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Lumpy, bumpy rock!",
			UNCOVERED = "Strange little man was in big rock!",
			FINISHED = "Marble man is fixed!",
			READY = "Stone is getting scarier!",
		},
        SCULPTURE_ROOKNOSE = "Wolfgang will carry long rock, is no problem!",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Does not budge, even under Wolfgang's mighty strength!",
			UNCOVERED = "Is many big rocks!",
			FINISHED = "Rock has all pieces now.",
			READY = "Stone is getting scarier!",
		},
        GARGOYLE_HOUND = "Is make Wolfgang uncomfortable!",
        GARGOYLE_WEREPIG = "Wolfgang does not like that.",
		SEEDS = "Too small to eat.",
		SEEDS_COOKED = "Fire make bigger, can eat now.",
		SEWING_KIT = "Is pokey!",
		SEWING_TAPE = "Is sticky and good for mending!",
		SHOVEL = "Dirt spoon!",
		SILK = "Is too fancy.",
		SKELETON = "Not enough muscle.",
		SCORCHED_SKELETON = "Wolfgang does not like this!!",
		SKULLCHEST = "This man had big head!", --removed
		SMALLBIRD =
		{
			GENERIC = "Is very small bird.",
			HUNGRY = "Small bird is hungry.",
			STARVING = "Small bird will die from starving.",
			SLEEPING = "Small bird sleeps now.",
		},
		SMALLMEAT = "Too small! Need bigger meat!",
		SMALLMEAT_DRIED = "Look like leather, taste like meat.",
		SPAT = "Look so friendly and cuddly.",
		SPEAR = "It gave me a sliver.",
		SPEAR_WATHGRITHR = "Is a good weapon.",
		WATHGRITHRHAT = "Is strong helm for strong warrior!",
		SPIDER =
		{
			DEAD = "Is made of sticky goo!",
			GENERIC = "He has scary face!",
			SLEEPING = "Walk quiet, he might not see me.",
		},
		SPIDERDEN = "The bugs are hiding in there.",
		SPIDEREGGSACK = "Nasty spider eggs.",
		SPIDERGLAND = "Squishy and wobbly!",
		SPIDERHAT = "Is like smooch from giant bug.",
		SPIDERQUEEN = "Oh no! Walking bug-house!",
		SPIDER_WARRIOR =
		{
			DEAD = "Not scary now!",
			GENERIC = "This one extra scary.",
			SLEEPING = "I think not smart to poke it.",
		},
		SPOILED_FOOD = "Is ball of yuck!",
        STAGEHAND =
        {
			AWAKE = "GAH! Table is creepy walking fist!",
			HIDING = "Wolfgang has no use for tiny table.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "Wolfgang does not know what to do with pretty statues.",
            TYPE1 = "Has funny little hat.",
            TYPE2 = "She seems like happy lady.",
            TYPE3 = "Is manly spittoon?", --bird bath type statue
        },
		STATUEHARP = "Where is pretty music?",
		STATUEMAXWELL = "Ha ha! Looks just like Wolfgang's new friend!",
		STEELWOOL = "Is like my arm hair.",
		STINGER = "Is sharp like skewer!",
		STRAWHAT = "Is good hat!",
		STUFFEDEGGPLANT = "Make yolk of other foods.",
		SWEATERVEST = "Is vest with pattern for fancy man.",
		REFLECTIVEVEST = "A vest's a vest.",
		HAWAIIANSHIRT = "Is vacation shirt.",
		TAFFY = "Is taffy for crushing!",
		TALLBIRD = "Is tallest bird!",
		TALLBIRDEGG = "There is bird inside.",
		TALLBIRDEGG_COOKED = "Cooked bird. Good for breakfast!",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Bird is like ice cube!",
			GENERIC = "Little bird is trying to get out.",
			HOT = "Is too hot for little bird!",
			LONG = "I wait for bird.",
			SHORT = "Bird comes soon.",
		},
		TALLBIRDNEST =
		{
			GENERIC = "Is big egg!",
			PICKED = "Is nest of emptiness.",
		},
		TEENBIRD =
		{
			GENERIC = "Hah! Not so tall.",
			HUNGRY = "Is hungry, and noisy.",
			STARVING = "Is hungry, noisy, and angry!",
			SLEEPING = "Bird is sleeping.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "I do not fear what lies beyond!", --single player
			GENERIC = "Strange rock. Do I sit on?", --single player
			LOCKED = "Something missing still.", --single player
			PARTIAL = "Is coming together now.", --single player
		},
		TELEPORTATO_BOX = "Has little lever.", --single player
		TELEPORTATO_CRANK = "Bendy thing is made of metal!", --single player
		TELEPORTATO_POTATO = "Ha ha! Ha ha! What ugly potato!", --single player
		TELEPORTATO_RING = "I can bend into perfect circle!", --single player
		TELESTAFF = "Fancy headache stick.",
		TENT =
		{
			GENERIC = "It is time for a mighty nap.",
			BURNT = "Nothing left to nap in.",
		},
		SIESTAHUT =
		{
			GENERIC = "Napping place.",
			BURNT = "Napping place is gone.",
		},
		TENTACLE = "Skinny monster!",
		TENTACLESPIKE = "Perfect for sticking!",
		TENTACLESPOTS = "Yuck! Slimy!",
		TENTACLE_PILLAR = "Lots of little friends!",
        TENTACLE_PILLAR_HOLE = "You run away from mighty Wolfgang?",
		TENTACLE_PILLAR_ARM = "Tiny tentacle baby thing! Ha!",
		TENTACLE_GARDEN = "Hmmmm, suspicious!",
		TOPHAT = "Is good hat!",
		TORCH = "Attack night with fire stick!",
		TRANSISTOR = "Science bean.",
		TRAP = "No trap can hold me!",
		TRAP_TEETH = "It bites bottoms from below!",
		TRAP_TEETH_MAXWELL = "Whoever put this is bad fella!", --single player
		TREASURECHEST =
		{
			GENERIC = "I put stuff there!",
			BURNT = "Nothing will stay inside.",
		},
		TREASURECHEST_TRAP = "Raagh!",
		SACRED_CHEST =
		{
			GENERIC = "Is little scare-chest.",
			LOCKED = "Is thinking.",
		},
		TREECLUMP = "Do not block Wolfgang's way!", --removed

		TRINKET_1 = "Glob of glass!", --Melted Marbles
		TRINKET_2 = "Fake bless you.", --Fake Kazoo
		TRINKET_3 = "Is knot what Wolfgang expected.", --Gord's Knot
		TRINKET_4 = "Ha ha! Is tiny man!", --Gnome
		TRINKET_5 = "What is do?", --Toy Rocketship
		TRINKET_6 = "Robot bits.", --Frazzled Wires
		TRINKET_7 = "Tiny torchlady Willow start firepits with toy! Very impressive.", --Ball and Cup
		TRINKET_8 = "Hardened, like Wolfgang.", --Rubber Bung
		TRINKET_9 = "Strong brainlady Wickerbottom maybe need for repair cardigans.", --Mismatched Buttons
		TRINKET_10 = "Is pearly chompers!", --Dentures
		TRINKET_11 = "Angry metal friend WX would like this, yes!", --Lying Robot
		TRINKET_12 = "Yuck.", --Dessicated Tentacle
		TRINKET_13 = "Ah! Is scary Wendy girl! ...No, wait, is just toy.", --Gnomette
		TRINKET_14 = "Beard will not like such pictures.", --Leaky Teacup
		TRINKET_15 = "Junk from braingame!", --Pawn
		TRINKET_16 = "Junk from braingame!", --Pawn
		TRINKET_17 = "Is still good!", --Bent Spork
		TRINKET_18 = "Wheeled horsey!", --Trojan Horse
		TRINKET_19 = "Could give it a spin.", --Unbalanced Top
		TRINKET_20 = "Wolfgang's arms too thick to reach back.", --Backscratcher
		TRINKET_21 = "Is fun to crank.", --Egg Beater
		TRINKET_22 = "Will take to fragile man Maxwell. He always talk about \"pulling strings\".", --Frayed Yarn
		TRINKET_23 = "Wolfgang does not know which end to blow.", --Shoehorn
		TRINKET_24 = "Wolfgang does not like even fake cat.", --Lucky Cat Jar
		TRINKET_25 = "Smell like laundry.", --Air Unfreshener
		TRINKET_26 = "Is cup made of potato, I think.", --Potato Cup
		TRINKET_27 = "Is skinny and bendy, like clownman Wes.", --Coat Hanger
		TRINKET_28 = "Junk from braingame!", --Rook
        TRINKET_29 = "Junk from braingame!", --Rook
        TRINKET_30 = "Junk from braingame!", --Knight
        TRINKET_31 = "Junk from braingame!", --Knight
        TRINKET_32 = "Wolfgang does not like spooky magics.", --Cubic Zirconia Ball
        TRINKET_33 = "Wolfgang not wear creepy finger-spider.", --Spider Ring
        TRINKET_34 = "Is soft, but spooky.", --Monkey Paw
        TRINKET_35 = "Little potion make Wolfgang mighty?", --Empty Elixir
        TRINKET_36 = "Gah! Do not scare Wolfgang!", --Faux fangs
        TRINKET_37 = "Stab-stick is useless now.", --Broken Stake
        TRINKET_38 = "Is making tiny friends look tinier!", -- Binoculars Griftlands trinket
        TRINKET_39 = "Is just one glove.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Wolfgang has no use for tiny garbage.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Wolfgang will crush it!", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Is tiny scary thing.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Is tiny toy monster.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Is very broke.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Wolfgang can barely hear this.", -- Odd Radio ONI trinket
        TRINKET_46 = "Is useless thing, I think.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_2  = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_7  = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_10 = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_11 = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_14 = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_18 = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_19 = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_42 = "Gives Wolfgang the heebiddy jeebers!",
        LOST_TOY_43 = "Gives Wolfgang the heebiddy jeebers!",

        HALLOWEENCANDY_1 = "Wolfgang eat many bushels!",
        HALLOWEENCANDY_2 = "Little corns get stuck in Wolfgang's mighty moustache!",
        HALLOWEENCANDY_3 = "Very bland. Reminds Wolfgang of back home candy!",
        HALLOWEENCANDY_4 = "Wolfgang feel strong when mashing tiny spiders between teeth!",
        HALLOWEENCANDY_5 = "Wolfgang not sure he has heart to eat.",
        HALLOWEENCANDY_6 = "Maybe is chocolate?",
        HALLOWEENCANDY_7 = "Little shrivelly sadlumps.",
        HALLOWEENCANDY_8 = "Is tasty little treat!",
        HALLOWEENCANDY_9 = "Is look yucky, but taste okay.",
        HALLOWEENCANDY_10 = "Is tasty little treat!",
        HALLOWEENCANDY_11 = "Little men of chocolate stand no chance against Wolfgang!",
        HALLOWEENCANDY_12 = "Is gross little candy bugs!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Hard candy is strong like Wolfgang!", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Is too hot for Wolfgang!!", --Hot Lava pepper candy
        CANDYBAG = "Is little bag for scary goodies!",

		HALLOWEEN_ORNAMENT_1 = "Wolfgang should be hanging it somewhere.",
		HALLOWEEN_ORNAMENT_2 = "Is real bat?! Is not real bat.",
		HALLOWEEN_ORNAMENT_3 = "Is for decorating.",
		HALLOWEEN_ORNAMENT_4 = "Wolfgang needs to be decorating.",
		HALLOWEEN_ORNAMENT_5 = "Wolfgang could hang somewheres.",
		HALLOWEEN_ORNAMENT_6 = "Little fake birdy is needing tree!",

		HALLOWEENPOTION_DRINKS_WEAK = "Is okay, but big Wolfgang need big drink!",
		HALLOWEENPOTION_DRINKS_POTENT = "Is strong like Wolfgang!",
        HALLOWEENPOTION_BRAVERY = "Wolfgang is brave. Is making Wolfgang braver.",
		HALLOWEENPOTION_MOON = "Hot leaf water make things change!",
		HALLOWEENPOTION_FIRE_FX = "Is making fire go boom boom!",
		MADSCIENCE_LAB = "Is making Wolfgang brain hurt.",
		LIVINGTREE_ROOT = "Hello little sticky!",
		LIVINGTREE_SAPLING = "Grow big and strong so Wolfgang can decorate!",

        DRAGONHEADHAT = "Wolfgang will be mighty beast!",
        DRAGONBODYHAT = "Is tums of big scarebeast.",
        DRAGONTAILHAT = "Mighty rear!",
        PERDSHRINE =
        {
            GENERIC = "Top is look like berry bird.",
            EMPTY = "Is wanting little bush plant?",
            BURNT = "Is small and broken now.",
        },
        REDLANTERN = "Wolfgang does not like the dark.",
        LUCKY_GOLDNUGGET = "Is money?",
        FIRECRACKERS = "Crackle bangs!",
        PERDFAN = "Wolfgang feel very lucky!",
        REDPOUCH = "Is good color!",
        WARGSHRINE =
        {
            GENERIC = "Stick made shiny puppy happy!",
            EMPTY = "Shiny puppy is wanting to play fetch.",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Puppy box is burned.",
        },
        CLAYWARG =
        {
        	GENERIC = "Big clay puppy!",
        	STATUE = "Is scary statue.",
        },
        CLAYHOUND =
        {
        	GENERIC = "Ruff, ruff!",
        	STATUE = "Little dog does not bark!",
        },
        HOUNDWHISTLE = "Tiny whistle stick makes no noise!",
        CHESSPIECE_CLAYHOUND = "Is nice little doggy.",
        CHESSPIECE_CLAYWARG = "It looks like scary monster!",

		PIGSHRINE =
		{
            GENERIC = "Is pretty piggy.",
            EMPTY = "Wolfgang give it meat.",
            BURNT = "Poor little piggy.",
		},
		PIG_TOKEN = "Is not fitting Wolfgang.",
		PIG_COIN = "This brings a piggy friend.",
		YOTP_FOOD1 = "Make Wolfgang mighty!",
		YOTP_FOOD2 = "Is not for Wolfgang.",
		YOTP_FOOD3 = "Is for making Wolfgang little bit mighty.",

		PIGELITE1 = "Wolfgang wave to little piggy!", --BLUE
		PIGELITE2 = "He is having nasty temper.", --RED
		PIGELITE3 = "Is dirty fighter.", --WHITE
		PIGELITE4 = "Is mighty. Wolfgang mightier.", --GREEN

		PIGELITEFIGHTER1 = "Wolfgang wave to little piggy!", --BLUE
		PIGELITEFIGHTER2 = "He is having nasty temper.", --RED
		PIGELITEFIGHTER3 = "Is dirty fighter.", --WHITE
		PIGELITEFIGHTER4 = "Is mighty. Wolfgang mightier.", --GREEN

		CARRAT_GHOSTRACER = "Something wrong with that one...",

        YOTC_CARRAT_RACE_START = "Is starting place for tiny leggy carrots.",
        YOTC_CARRAT_RACE_CHECKPOINT = "Is point for checking.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "Wolfgang will win, have leggy-est carrot!",
            BURNT = "Is all burnt away.",
            I_WON = "Haha! Good job, tiny friend!",
            SOMEONE_ELSE_WON = "{winner} trained leggy carrot well.",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Is gong-thing for race starting.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Is point for checking.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Wolfgang will find good place for finish spot.",

		YOTC_SEEDPACKET = "Is seeds for growing.",
		YOTC_SEEDPACKET_RARE = "Is fancy seeds for growing.",

		MINIBOATLANTERN = "Is floaty water light.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "Shiny leggy carrot was hungry!",
            EMPTY = "Is wanting nibbles. Wolfgang will find.",
            BURNT = "Very sad.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "Is tiny turny gym.",
            RAT = "You learning well!",
            BURNT = "Tiny gym burnt away.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Speed almost as important as mightiness.",
            RAT = "Haha! Run, little friend!",
            BURNT = "Tiny gym burnt away.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "Wolfgang smell popcorn.",
            RAT = "Good! Is learning!",
            BURNT = "Tiny gym burnt away.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "Yes!! Tiny gym will make leggy carrot strong!",
            RAT = "You will be mighty!",
            BURNT = "Tiny gym burnt away.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "Will make leggy carrot smarter!",
        YOTC_CARRAT_GYM_SPEED_ITEM = "Will make leggy carrot faster!",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "Will make leggy carrot stronger!",
        YOTC_CARRAT_GYM_REACTION_ITEM = "Will give good reflexes to leggy carrot!",

        YOTC_CARRAT_SCALE_ITEM = "Is measurer of racing mightiness!",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "Will see how mighty Wolfgang's leggy carrot is!",
            CARRAT = "Hmmm, could be mightier.",
            CARRAT_GOOD = "You will be good racer!",
            BURNT = "Will probably not work anymore.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Is fuzzy and happy now.",
            EMPTY = "Is hair-cow with no hair? Wolfgang must fix.",
            BURNT = "Nothing Wolfgang can do now.",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "For brushing and pampering of hair-cows.",
            OCCUPIED = "Do not worry hair-cow, you are in good hands with Wolfgang!",
            BURNT = "Hmm... not good.",
        },
        BEEFALO_GROOMER_ITEM = "Do not worry, Wolfgang will build it!",

		BISHOP_CHARGE_HIT = "Rrrraa!",
		TRUNKVEST_SUMMER = "Is warm fuzzy nose.",
		TRUNKVEST_WINTER = "Cozy nosy!",
		TRUNK_COOKED = "Is cooked nose.",
		TRUNK_SUMMER = "Is floppy nose.",
		TRUNK_WINTER = "Is floppy hairy nose.",
		TUMBLEWEED = "Come back little tumbling ball!",
		TURKEYDINNER = "Is good feast of bird meat.",
		TWIGS = "Puny twigs! I will break them!",
		UMBRELLA = "The rain hurts my mighty skin.",
		GRASS_UMBRELLA = "I do not like tiny umbrella.",
		UNIMPLEMENTED = "I do not trust unfinished business.",
		WAFFLES = "Why does bread have holes?",
		WALL_HAY =
		{
			GENERIC = "Wall is made of grass!",
			BURNT = "Grass burned up!",
		},
		WALL_HAY_ITEM = "Scratchy straws!",
		WALL_STONE = "Wall is strong like me!",
		WALL_STONE_ITEM = "Piles of rocks!",
		WALL_RUINS = "Old wall is strong!",
		WALL_RUINS_ITEM = "Stack of old rocks!",
		WALL_WOOD =
		{
			GENERIC = "Hello, pointy sticks!",
			BURNT = "Goodbye, pointy sticks!",
		},
		WALL_WOOD_ITEM = "Pokey sticks!",
		WALL_MOONROCK = "Rock of moon protects Wolfgang.",
		WALL_MOONROCK_ITEM = "Can build with power of moon!",
		FENCE = "I do not like trapping little animals.",
        FENCE_ITEM = "Wolfgang will help make fence!",
        FENCE_GATE = "Is little flimsy swingboards.",
        FENCE_GATE_ITEM = "Wolfgang will help make swingboards!",
		WALRUS = "Ha ha. Is blubbery flubbery man.",
		WALRUSHAT = "Sea cow man hat!",
		WALRUS_CAMP =
		{
			EMPTY = "Is locked.",
			GENERIC = "How do they all fit?",
		},
		WALRUS_TUSK = "Sea cow man tooth!",
		WARDROBE =
		{
			GENERIC = "Box of clothes!",
            BURNING = "Box of fire!",
			BURNT = "Box all gone.",
		},
		WARG = "Big puppy!",
        WARGLET = "Is bad dog!",
        
		WASPHIVE = "Mind says no. Muscles say yes!",
		WATERBALLOON = "Is very squishy-wobbly!",
		WATERMELON = "So many seeds.",
		WATERMELON_COOKED = "Seeds is cooked out of melon now.",
		WATERMELONHAT = "Why not wear melon on head! Haha!",
		WAXWELLJOURNAL = "Wolfgang is glad he cannot read!",
		WETGOOP = "Is not bad to eat, but is not good.",
        WHIP = "Good to floss teeth with.",
		WINTERHAT = "It make ears happy in cold!",
		WINTEROMETER =
		{
			GENERIC = "Cold go up! Red go down!",
			BURNT = "Flames go up! Measure machine go down!",
		},

        WINTER_TREE =
        {
            BURNT = "Happy tree is burn now.",
            BURNING = "Tree is not fireproof!",
            CANDECORATE = "Tree looks very happy!",
            YOUNG = "Is growing.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "Very nice little pot!",
            BURNT = "Happy tree is burn now.",
		},
        WINTER_ORNAMENT = "Is so small in Wolfgang's hand.",
        WINTER_ORNAMENTLIGHT = "Glass ball of twinkly light!",
        WINTER_ORNAMENTBOSS = "Pretty little token of mightiness!",
		WINTER_ORNAMENTFORGE = "Decoration of mighty enemy.",
		WINTER_ORNAMENTGORGE = "Hello, little friend!",

        WINTER_FOOD1 = "Little man will crumble under my mighty teeth!", --gingerbread cookie
        WINTER_FOOD2 = "Does Wolfgang have sugar in moustache?", --sugar cookie
        WINTER_FOOD3 = "Little sugar stick.", --candy cane
        WINTER_FOOD4 = "Wolfgang does not trust little fruit loaf.", --fruitcake
        WINTER_FOOD5 = "Ha! Wolfgang will eat log, just like beardman!", --yule log cake
        WINTER_FOOD6 = "Tiny yummy cakething make strong Wolfgang.", --plum pudding
        WINTER_FOOD7 = "Little fruit is sweet and tasty!", --apple cider
        WINTER_FOOD8 = "Wolfgang likes feeling cozy.", --hot cocoa
        WINTER_FOOD9 = "Is much protein inside, yes?", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Oven needs mighty fuel!",
			COOKING = "Is making Wolfgang's mouth water.",
			ALMOST_DONE_COOKING = "Is almost done...",
			DISH_READY = "Wolfgang will share with all his friends!",
		},
		BERRYSAUCE = "Is very berry!",
		BIBINGKA = "Leafy bread fills Wolfgang's mighty belly!",
		CABBAGEROLLS = "Wolfgang likes his cabbage rolls smothered in sauerkraut!",
		FESTIVEFISH = "Is good fish for holidays.",
		GRAVY = "Gravy is good indeed!",
		LATKES = "Will eat many, many of these.",
		LUTEFISK = "Wolfgang will eat the stinky fish.",
		MULLEDDRINK = "Is good, cozy drink.",
		PANETTONE = "Is good, sweet bread.",
		PAVLOVA = "Look very delicate, not like mighty Wolfgang.",
		PICKLEDHERRING = "Good fish, get in belly.",
		POLISHCOOKIE = "Ah, bring back good memories.",
		PUMPKINPIE = "Wolfgang's belly is going to grow bigger than muscles...",
		ROASTTURKEY = "Wolfgang hungry for bird meat!",
		STUFFING = "Bread chunks very good!",
		SWEETPOTATO = "Is very sweet, but see no potato.",
		TAMALES = "Was Wolfgang not supposed to eat husk of corn?",
		TOURTIERE = "Is pie filled with much protein!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Is place for all of Wolfgang's friends!",
			HAS_FOOD = "Come, friends, and eat the mighty food!",
			WRONG_TYPE = "Oops. Is not going here.",
			BURNT = "Think party has gotten out of hand.",
		},

		GINGERBREADWARG = "Wolfgang will defeat it. Then, dessert!",
		GINGERBREADHOUSE = "Wolfgang will punch it for the candy.",
		GINGERBREADPIG = "Hehe! Come back, little guy!",
		CRUMBS = "Is clue! Yummy, yummy clue!",
		WINTERSFEASTFUEL = "Is making Wolfgang think of friends.",

        KLAUS = "If Wolfgang had no eyes, he would not see terrible beast!",
        KLAUS_SACK = "Something inside for Wolfgang, maybe?",
		KLAUSSACKKEY = "Is very special antler!",
		WORMHOLE =
		{
			GENERIC = "Like soft pillow, growing on ground.",
			OPEN = "It can not harm this man!",
		},
		WORMHOLE_LIMITED = "Is not looking very good.",
		ACCOMPLISHMENT_SHRINE = "I will defeat you, tiny arrow!", --single player
		LIVINGTREE = "I do not like tree with eyes.",
		ICESTAFF = "Frosted tip.",
		REVIVER = "Blib blup! Blib blup! Blib blup!",
		SHADOWHEART = "Wolfgang is not shaking! Is manly flexing!!",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "Is picture of many sad, weak people.",
			LINE_2 = "Cannot tell what was picture of.",
			LINE_3 = "In picture darkness covers sad, weak people.",
			LINE_4 = "Monsters is bursting out of them!",
			LINE_5 = "Is picture of very pretty place.",
		},
        ATRIUM_STATUE = "Statue make Wolfgang's tummy do flip.",
        ATRIUM_LIGHT =
        {
			ON = "This light is scarier than the dark.",
			OFF = "Is place for light.",
		},
        ATRIUM_GATE =
        {
			ON = "Little lights is on now.",
			OFF = "Is very old thing.",
			CHARGING = "Looks very scary now!",
			DESTABILIZING = "Is going to blow!",
			COOLDOWN = "Is needing to recharge.",
        },
        ATRIUM_KEY = "Little key is for make door.",
		LIFEINJECTOR = "EeeeEEeeEEE!!",
		SKELETON_PLAYER =
		{
			MALE = "Hah. %s did not have enough muscle to survive %s.",
			FEMALE = "Hah. %s did not have enough muscle to survive %s.",
			ROBOT = "Hah. %s did not have enough muscle to survive %s.",
			DEFAULT = "Hah. %s did not have enough muscle to survive %s.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "But is not cheese?",
		MOONROCKNUGGET = "But is not cheese?",
		MOONROCKCRATER = "Rock from moon has hole. Like a cheese!",
		MOONROCKSEED = "Is ball not for throwing.",

        REDMOONEYE = "Marks Wolfgang's way, and good weight for squats!",
        PURPLEMOONEYE = "Is creepy, but maybe Wolfgang not get lost so much now.",
        GREENMOONEYE = "Is never blinking.",
        ORANGEMOONEYE = "Tiny rock watches Wolfgang wherever he go.",
        YELLOWMOONEYE = "Hmm, maybe Wolfgang try shotput?",
        BLUEMOONEYE = "Is small, but not crushable.",

        --Arena Event
        LAVAARENA_BOARLORD = "Is important-looking man.",
        BOARRIOR = "Large pig man cannot out-muscle Wolfgang!",
        BOARON = "Tiny pig cannot hurt Wolfgang.",
        PEGHOOK = "Wolfgang will beat you with fists!",
        TRAILS = "Wolfgang is stronger than you!",
        TURTILLUS = "Armor is for tiny men!",
        SNAPPER = "I will smush lizard man!",
		RHINODRILL = "Wolfgang is more macho.",
		BEETLETAUR = "Is not scaring Wolfgang.",

        LAVAARENA_PORTAL =
        {
            ON = "Goodbye, puny fire world!",
            GENERIC = "Is how Wolfgang got here.",
        },
        LAVAARENA_KEYHOLE = "Nothing here.",
		LAVAARENA_KEYHOLE_FULL = "Is ready now.",
        LAVAARENA_BATTLESTANDARD = "We must all smash little flag!",
        LAVAARENA_SPAWNER = "Little circle! Give me many things to fight!",

        HEALINGSTAFF = "Wolfgang cannot fight with twig.",
        FIREBALLSTAFF = "Puny stick is not for Wolfgang.",
        HAMMER_MJOLNIR = "Wolfgang is ready for high striker!",
        SPEAR_GUNGNIR = "Wolfgang will stab many foes!",
        BLOWDART_LAVA = "Wolfgang does not fight from afar.",
        BLOWDART_LAVA2 = "Wolfgang will not use wimpy weapon.",
        LAVAARENA_LUCY = "Is beard's axe.",
        WEBBER_SPIDER_MINION = "Is tiny monsters!",
        BOOK_FOSSIL = "Is look very hard to read.",
		LAVAARENA_BERNIE = "Nice little creepy bear.",
		SPEAR_LANCE = "Wolfgang likes swirly stab-stick.",
		BOOK_ELEMENTAL = "Wolfgang does not understand little letters.",
		LAVAARENA_ELEMENTAL = "Is rock friend.",

   		LAVAARENA_ARMORLIGHT = "Wolfgang does not want flimsy thing.",
		LAVAARENA_ARMORLIGHTSPEED = "Only cowards run from fights!",
		LAVAARENA_ARMORMEDIUM = "Is not very thick.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Wolfgang does not like weak armor.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Is too weak for Wolfgang.",
		LAVAARENA_ARMORHEAVY = "Armor is strong, like Wolfgang.",
		LAVAARENA_ARMOREXTRAHEAVY = "Is perfect fit for Wolfgang.",

		LAVAARENA_FEATHERCROWNHAT = "Silly little feather hat.",
        LAVAARENA_HEALINGFLOWERHAT = "It would make Wolfgang look nice.",
        LAVAARENA_LIGHTDAMAGERHAT = "Mighty little spike hat!",
        LAVAARENA_STRONGDAMAGERHAT = "Wolfgang would like to wear it.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Is useless leaf hat.",
        LAVAARENA_EYECIRCLETHAT = "Is no-good creepy hat.",
        LAVAARENA_RECHARGERHAT = "Nice little head rocks.",
        LAVAARENA_HEALINGGARLANDHAT = "Is many little fast flowers.",
        LAVAARENA_CROWNDAMAGERHAT = "Is so mighty!",

		LAVAARENA_ARMOR_HP = "Is mighty like Wolfgang.",

		LAVAARENA_FIREBOMB = "Wolfgang doesn't like.",
		LAVAARENA_HEAVYBLADE = "Is might sword for mighty Wolfgang!",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "Little stone. Wolfgang will cook for you.",
        	FULL = "Enjoy hearty meal from Wolfgang!",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Nice stone lady.",
		QUAGMIRE_PARK_FOUNTAIN = "There is no water for little birdies.",

        QUAGMIRE_HOE = "Wolfgang must do farmwork for tastiest veggies.",

        QUAGMIRE_TURNIP = "I will use in many dishes! Yes!",
        QUAGMIRE_TURNIP_COOKED = "Smell is very good.",
        QUAGMIRE_TURNIP_SEEDS = "Is little tiny seeds for burying.",

        QUAGMIRE_GARLIC = "Is good flavor for stewing.",
        QUAGMIRE_GARLIC_COOKED = "Flavor is good now.",
        QUAGMIRE_GARLIC_SEEDS = "Is little tiny seeds for burying.",

        QUAGMIRE_ONION = "Wolfgang eats like apple when not cooking.",
        QUAGMIRE_ONION_COOKED = "Crispy, brown, sweet.",
        QUAGMIRE_ONION_SEEDS = "Is little tiny seeds for burying.",

        QUAGMIRE_POTATO = "Wolfgang's favorite veggie.",
        QUAGMIRE_POTATO_COOKED = "Is golden brown! Texture like sun!",
        QUAGMIRE_POTATO_SEEDS = "Is little tiny seeds for burying.",

        QUAGMIRE_TOMATO = "Is good for sauce makings.",
        QUAGMIRE_TOMATO_COOKED = "Roasty and toasty.",
        QUAGMIRE_TOMATO_SEEDS = "Is little tiny seeds for burying.",

        QUAGMIRE_FLOUR = "Is for dough and many good noodles.",
        QUAGMIRE_WHEAT = "Flour! Wolfgang will grind with bare hands!",
        QUAGMIRE_WHEAT_SEEDS = "Is little tiny seeds for burying.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Is little tiny seeds for burying.",

        QUAGMIRE_ROTTEN_CROP = "Ground turned veggie to gunk.",

		QUAGMIRE_SALMON = "Is floppy, floppy fish.",
		QUAGMIRE_SALMON_COOKED = "Fish is cooked now.",
		QUAGMIRE_CRABMEAT = "Is meat of tiny pincher.",
		QUAGMIRE_CRABMEAT_COOKED = "Yummy, yummy pincher.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "Is little tree of yummy goop.",
			STUMP = "Tree has been cut down!",
			TAPPED_EMPTY = "Little bucket needs to fill up.",
			TAPPED_READY = "Little bucket is full!",
			TAPPED_BUGS = "Wolfgang will crush tiny creatures.",
			WOUNDED = "Little tree has boo-boo.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "Is little shrub for eating.",
			PICKED = "We took the food bits.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Is nice little garnish.",
		QUAGMIRE_SPOTSPICE_GROUND = "Wolfgang will cook delicious things.",
		QUAGMIRE_SAPBUCKET = "Is for get yummy tree goop.",
		QUAGMIRE_SAP = "Is yummy tree goop!",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Is ready!",
			GENERIC = "Is not ready yet.",
		},

		QUAGMIRE_POND_SALT = "Is tiny ocean.",
		QUAGMIRE_SALT_RACK_ITEM = "Mighty hands make quick work.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "What is inside?",
			LOCKED = "Punches do nothing.",
		},

		QUAGMIRE_KEY = "Wolfgang have key to treasure.",
		QUAGMIRE_KEY_PARK = "Haha! Wolfgang open gate now!",
        QUAGMIRE_PORTAL_KEY = "Is heavy key but Wolfgang strong!",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Wolfgang could use in soups.",
			PICKED = "No more for Wolfgang.",
		},
		QUAGMIRE_MUSHROOMS = "Mushrooms need cooking!",
        QUAGMIRE_MEALINGSTONE = "We must grind grain for bread!",
		QUAGMIRE_PEBBLECRAB = "Hello, itty bitty pincher!",


		QUAGMIRE_RUBBLE_CARRIAGE = "Is not work.",
        QUAGMIRE_RUBBLE_CLOCK = "Wolfgang cannot tell time.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Someone is smashed it.",
        QUAGMIRE_RUBBLE_PUBDOOR = "Is not going nowhere.",
        QUAGMIRE_RUBBLE_ROOF = "Wolfgang lift it, then Wolfgang have roof over head.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "Is working? No is not working.",
        QUAGMIRE_RUBBLE_BIKE = "Is busted.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Is no one here.",
            "Someone crushed homes.",
            "Must have made something angry.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Wolfgang will punch whatever did this.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Wolfgang not do this. But Wolfgang could.",
        QUAGMIRE_MERMHOUSE = "That house is for smelly fish men.",
        QUAGMIRE_SWAMPIG_HOUSE = "Wimpy house for hairy pigs.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Little house is ruined.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "He seems like good fellow!",
            SLEEPING = "Gone beddy-bye.",
        },
        QUAGMIRE_SWAMPIG = "Is big teeth you have!",

        QUAGMIRE_PORTAL = "It did not go home. Is no surprise.",
        QUAGMIRE_SALTROCK = "Wolfgang will crush bits into salt shaker.",
        QUAGMIRE_SALT = "Is make food taste good.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Is sad sight.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Wolfgang will feed big sky beast!",
            MISMATCH = "Is not what sky beast wants.",
            MATCH = "Is good for sky beast.",
            MATCH_BUT_SNACK = "Is tiny food, but good for sky beast.",
        },

        QUAGMIRE_FERN = "Is tiny leaf plant.",
        QUAGMIRE_FOLIAGE_COOKED = "Is garnish now.",
        QUAGMIRE_COIN1 = "Goat lady and fish men would like.",
        QUAGMIRE_COIN2 = "Goat lady and fish men would like.",
        QUAGMIRE_COIN3 = "Goat lady and fish men would like.",
        QUAGMIRE_COIN4 = "Sky beast liked Wolfgang's cookings!",
        QUAGMIRE_GOATMILK = "Maybe goat lady got from hair cows?",
        QUAGMIRE_SYRUP = "Yummy sugar goop!",
        QUAGMIRE_SAP_SPOILED = "Wolfgang cannot cook with yuck sludge.",
        QUAGMIRE_SEEDPACKET = "Give your seeds to Wolfgang, tiny paper!",

        QUAGMIRE_POT = "Wolfgang put this over fire.",
        QUAGMIRE_POT_SMALL = "Friends, do not look! Pot needs to boil.",
        QUAGMIRE_POT_SYRUP = "Wolfgang put in sugar goop. New sugar goop come out.",
        QUAGMIRE_POT_HANGER = "Wolfgang hang things over fire.",
        QUAGMIRE_POT_HANGER_ITEM = "Is make pot hang over fire.",
        QUAGMIRE_GRILL = "Is put fire to food.",
        QUAGMIRE_GRILL_ITEM = "Where will Wolfgang put this?",
        QUAGMIRE_GRILL_SMALL = "Is put fire on tiny food.",
        QUAGMIRE_GRILL_SMALL_ITEM = "Wolfgang needs put this down some place.",
        QUAGMIRE_OVEN = "Friends! Wolfgang will cook for you!",
        QUAGMIRE_OVEN_ITEM = "Is fire box bits.",
        QUAGMIRE_CASSEROLEDISH = "Is shame Wolfgang forget cabbage casserole recipe.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "Is making of small foods.",
        QUAGMIRE_PLATE_SILVER = "Is for fancy eating.",
        QUAGMIRE_BOWL_SILVER = "Is for fancy eating.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Wolfgang could lift it.", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Wolfgang could lift it.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Is scary.",
        QUAGMIRE_PARK_ANGEL2 = "Wolfgang don't like.",
        QUAGMIRE_PARK_URN = "Is burned dead person pieces.",
        QUAGMIRE_PARK_OBELISK = "Wolfgang could lift it.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "What nice things is in pink park?",
            LOCKED = "Is needing key.",
        },
        QUAGMIRE_PARKSPIKE = "Is pointy spiky thing.",
        QUAGMIRE_CRABTRAP = "Is for catching tiny pinchers.",
        QUAGMIRE_TRADER_MERM = "Is having things for Wolfgang?",
        QUAGMIRE_TRADER_MERM2 = "Is having things for Wolfgang?",

        QUAGMIRE_GOATMUM = "Is fluffy goat lady!",
        QUAGMIRE_GOATKID = "You grow up strong like Wolfgang, yes?",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Is dead.",
            GENERIC = "Silly bird does not matter to Wolfgang.",
            SLEEPING = "Gone beddy-bye.",
        },
        QUAGMIRE_LAMP_POST = "Wolfgang loves lamp.",

        QUAGMIRE_BEEFALO = "Is old.",
        QUAGMIRE_SLAUGHTERTOOL = "Wolfgang use to kill things.",

        QUAGMIRE_SAPLING = "Is broken.",
        QUAGMIRE_BERRYBUSH = "Is all gone.",

        QUAGMIRE_ALTAR_STATUE2 = "Is silly statue. Wolfgang not afraid.",
        QUAGMIRE_ALTAR_QUEEN = "Is big lady.",
        QUAGMIRE_ALTAR_BOLLARD = "Is post.",
        QUAGMIRE_ALTAR_IVY = "Is plant.",

        QUAGMIRE_LAMP_SHORT = "Wolfgang loves lamp.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "Little fixing lady has very big brainmeats.",
        	OFF = "Is not working.",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "Fixing lady knows Wolfgang not like dark.",
        	OFF = "Is not working.",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "Thingamabob made by fixing lady.",
        	LOWPOWER = "Is supposed to look like that?",
        	OFF = "Thingamabob is dead!",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "Fixing lady doohickeys.",
        	LOWPOWER = "It does not look so good.",
        	OFF = "Fixing lady, quick, come fix!",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },

        --Wormwood
        COMPOSTWRAP = "Is very mighty poop.",
        ARMOR_BRAMBLE = "Mighty Wolfgang does not need armor!",
        TRAP_BRAMBLE = "Is sharp plant for hurting feets.",

        BOATFRAGMENT03 = "Weak boat is woodchips now!",
        BOATFRAGMENT04 = "Weak boat is woodchips now!",
        BOATFRAGMENT05 = "Weak boat is woodchips now!",
		BOAT_LEAK = "Wolfgang will plug hole with mighty fists!",
        MAST = "Wooden wind catcher!",
        SEASTACK = "Is a big watery rock.",
        FISHINGNET = "I will catch many tasty fish!", --unimplemented
        ANTCHOVIES = "Is little squirmy sea bug.", --unimplemented
        STEERINGWHEEL = "Wolfgang does not know where he is going.",
        ANCHOR = "Is good for weightlift. Build muscle.",
        BOATPATCH = "Mighty Wolfgang will fix all boats!",
        DRIFTWOOD_TREE =
        {
            BURNING = "Is burning!",
            BURNT = "Is burnt up.",
            CHOPPED = "All chopped up.",
            GENERIC = "Is tree from the sea.",
        },

        DRIFTWOOD_LOG = "Small log is practically fit in palm of my hand!",

        MOON_TREE =
        {
            BURNING = "Is burning!",
            BURNT = "Is burnt up.",
            CHOPPED = "Is stumpy stump now.",
            GENERIC = "Roly poly weird tree.",
        },
		MOON_TREE_BLOSSOM = "It come from weird tree.",

        MOONBUTTERFLY =
        {
        	GENERIC = "Flutterby is big and green!",
        	HELD = "Green flutterby is soft.",
        },
		MOONBUTTERFLYWINGS = "Flutterby flappers.",
        MOONBUTTERFLY_SAPLING = "Puny little tree!",
        ROCK_AVOCADO_FRUIT = "Why little fruit hurt mouth?",
        ROCK_AVOCADO_FRUIT_RIPE = "Is soft for the eatings now.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Mushy and warm. Yum.",
        ROCK_AVOCADO_FRUIT_SPROUT = "Little bush is tiny and weak.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It no longer makes the tiny fruits.",
			WITHERED = "Is very hot out.",
			GENERIC = "No fruit is too strong for Wolfgang's mighty jaw!",
			PICKED = "No little fruits today.",
			DISEASED = "Little bush is sick!", --unimplemented
            DISEASING = "Is not look very good.", --unimplemented
			BURNING = "Is burning!",
		},
        DEAD_SEA_BONES = "Big fish is very dead.",
        HOTSPRING =
        {
        	GENERIC = "Is hot puddle.",
        	BOMBED = "Puddle stinks with good smells now.",
        	GLASS = "Mighty Wolfgang will punch through silly glass!",
			EMPTY = "Is just dirt hole now.",
        },
        MOONGLASS = "Is clear green sharp-stuff.",
        MOONGLASS_CHARGED = "Sharp and glowy stuff.",
        MOONGLASS_ROCK = "Sharp stuff that fell from sky cheese.",
        BATHBOMB = "Is for prettifying little hotbath.",
        TRAP_STARFISH =
        {
            GENERIC = "Wolfgang be careful not to step on.",
            CLOSED = "Ha ha! You is no match for mighty Wolfgang!",
        },
        DUG_TRAP_STARFISH = "Is not bite Wolfgang toesies now.",
        SPIDER_MOON =
        {
        	GENERIC = "Wolfgang does not like that!",
        	SLEEPING = "Wolfgang will not disturb.",
        	DEAD = "Goodbye!",
        },
        MOONSPIDERDEN = "Scary things is inside maybe.",
		FRUITDRAGON =
		{
			GENERIC = "Is little planty scrambler!",
			RIPE = "Planty scrambler smells delicious today.",
			SLEEPING = "Wolfgang will not disturb.",
		},
        PUFFIN =
        {
            GENERIC = "Feather bird likes water.",
            HELD = "You is small, feather friend.",
            SLEEPING = "Wolfgang will not disturb.",
        },

		MOONGLASSAXE = "Is for swing and chop.",
		GLASSCUTTER = "My new friend taught me how to make.",

        ICEBERG =
        {
            GENERIC = "Is big freezy cube.", --unimplemented
            MELTED = "Is all melty!", --unimplemented
        },
        ICEBERG_MELTED = "Is all melty!", --unimplemented

        MINIFLARE = "Is tiny sky boom!",

		MOON_FISSURE =
		{
			GENERIC = "Wolfgang is frighten, but happy.",
			NOLIGHT = "Tiny ground is crack apart!",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Wolfgang like to help new friends.",
            GENERIC = "You have secrets for Wolfgang, friend?",
        },

        MOON_ALTAR_IDOL = "Wolfgang is here to help, yes.",
        MOON_ALTAR_GLASS = "Tell Wolfgang where you go and he will take you.",
        MOON_ALTAR_SEED = "Yes, Wolfgang will carry you.",

        MOON_ALTAR_ROCK_IDOL = "Special things is trapped inside!",
        MOON_ALTAR_ROCK_GLASS = "Special things is trapped inside!",
        MOON_ALTAR_ROCK_SEED = "Special things is trapped inside!",

        MOON_ALTAR_CROWN = "Wolfgang will help you!",
        MOON_ALTAR_COSMIC = "Such loud whisperings. Make head hurt.",

        MOON_ALTAR_ASTRAL = "Seems happy now, Wolfgang thinks.",
        MOON_ALTAR_ICON = "Wolfgang will carry you most mightily!",
        MOON_ALTAR_WARD = "Is not so heavy, Wolfgang will carry as far as you need!",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Wolfgang need help thinking on scary water.",
            BURNT = "Is burny stuff now.",
        },
        BOAT_ITEM = "Is for making very nice boat.",
        STEERINGWHEEL_ITEM = "Is for making little whirly steer-wheel.",
        ANCHOR_ITEM = "Is for making big boat weight.",
        MAST_ITEM = "Is for making big sail-stick.",
        MUTATEDHOUND =
        {
        	DEAD = "Wolfgang would like to stay far away.",
        	GENERIC = "Meaty puppy is very scary!",
        	SLEEPING = "Wolfgang does not like meaty puppy.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Is dead, but still scary.",
			GENERIC = "Is too scary!",
			SLEEPING = "Please do not wake up.",
		},
        CARRAT =
        {
        	DEAD = "Is dead.",
        	GENERIC = "Leggy carrot is getting away!",
        	HELD = "You are safe now, leggy carrot.",
        	SLEEPING = "Leggy carrot is sleeping.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Big pond is growing hair.",
            PICKED = "All gone.",
        },
		BULLKELP_ROOT = "Is not very good weapon, I think.",
        KELPHAT = "This make Wolfgang uneasy.",
		KELP = "Slimy sea spinach!",
		KELP_COOKED = "Sea spinach make Wolfgang strong to the finish.",
		KELP_DRIED = "Little sea flakes make Wolfgang grow strong!",

		GESTALT = "Wolfgang's brainmeats have never been so mighty!",
        GESTALT_GUARD = "As long as they fight scary shadow, Wolfgang is happy.",

		COOKIECUTTER = "Fish has strangely punchable face...",
		COOKIECUTTERSHELL = "Tough, but not as tough as Wolfgang!",
		COOKIECUTTERHAT = "Keep head safe and dry!",
		SALTSTACK =
		{
			GENERIC = "Weird statues.",
			MINED_OUT = "Nothing left for Wolfgang to break.",
			GROWING = "Weird statues growing back.",
		},
		SALTROCK = "Wolfgang confused, thought salt came from tiny shakers?",
		SALTBOX = "Put food inside!",

		TACKLESTATION = "Make better rod for fish!",
		TACKLESKETCH = "Picture will help Wolfgang catch fish!",

        MALBATROSS = "Big fishy bird!",
        MALBATROSS_FEATHER = "Feather from big water bird.",
        MALBATROSS_BEAK = "Hmm, too big for stew.",
        MAST_MALBATROSS_ITEM = "Make good sail out of bird feathers!",
        MAST_MALBATROSS = "Bird make good sail.",
		MALBATROSS_FEATHERED_WEAVE = "Is cloth of bird!",

        GNARWAIL =
        {
            GENERIC = "Big fish think it can poke holes in Wolfgang's boat?!",
            BROKENHORN = "Big fish know better than to mess with Wolfgang now!",
            FOLLOWER = "Yes, you follow mighty Wolfgang!",
            BROKENHORN_FOLLOWER = "Don't need horn to be mighty! You big, like Wolfgang!",
        },
        GNARWAIL_HORN = "Will make good pokey spear!",

        WALKINGPLANK = "Maybe Wolfgang go for dip.",
        OAR = "Wolfgang will be mighty rower!",
		OAR_DRIFTWOOD = "Oar feels so light in Wolfgang's mighty hands!",

		OCEANFISHINGROD = "Strong rod to catch mighty fish!",
		OCEANFISHINGBOBBER_NONE = "Need something to fish better.",
        OCEANFISHINGBOBBER_BALL = "Float well, tiny bobber!",
        OCEANFISHINGBOBBER_OVAL = "Float well, tiny bobber!",
		OCEANFISHINGBOBBER_CROW = "Feather of crow float well on water!",
		OCEANFISHINGBOBBER_ROBIN = "Feather of red bird float well on water!",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "Feather of winter bird float well on water!",
		OCEANFISHINGBOBBER_CANARY = "Feather of yellow bird float well on water!",
		OCEANFISHINGBOBBER_GOOSE = "Wolfgang use big feather to catch big fish!",
		OCEANFISHINGBOBBER_MALBATROSS = "Wolfgang use big feather to catch big fish!",

		OCEANFISHINGLURE_SPINNER_RED = "Is tiny fish bait.",
		OCEANFISHINGLURE_SPINNER_GREEN = "Is tiny fish bait.",
		OCEANFISHINGLURE_SPINNER_BLUE = "Is tiny fish bait.",
		OCEANFISHINGLURE_SPOON_RED = "Is tiny fish bait.",
		OCEANFISHINGLURE_SPOON_GREEN = "Is tiny fish bait.",
		OCEANFISHINGLURE_SPOON_BLUE = "Is tiny fish bait.",
		OCEANFISHINGLURE_HERMIT_RAIN = "For fishing when raining.",
		OCEANFISHINGLURE_HERMIT_SNOW = "For fishing when is snow outside.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Ha! It make fish stupid!",
		OCEANFISHINGLURE_HERMIT_HEAVY = "Wolfgang will show all how to catch biggest fish!",

		OCEANFISH_SMALL_1 = "Fish is puny!",
		OCEANFISH_SMALL_2 = "Is tiny fish!",
		OCEANFISH_SMALL_3 = "Wolfgang could eat in one bite!",
		OCEANFISH_SMALL_4 = "Is small and weak fish.",
		OCEANFISH_SMALL_5 = "Would make good snack for Wolfgang.",
		OCEANFISH_SMALL_6 = "Has creepy flat face, Wolfgang not like.",
		OCEANFISH_SMALL_7 = "Oh, is nice little flower fish.",
		OCEANFISH_SMALL_8 = "Is strange burny fish.",
        OCEANFISH_SMALL_9 = "Funny little spit fish.",

		OCEANFISH_MEDIUM_1 = "Don't like way its buggy eyes stare.",
		OCEANFISH_MEDIUM_2 = "Aha! Big fish for dinner!",
		OCEANFISH_MEDIUM_3 = "This fish very pokey.",
		OCEANFISH_MEDIUM_4 = "Wolfgang doesn't want bad luck!",
		OCEANFISH_MEDIUM_5 = "Haha! Is corn and fish!",
		OCEANFISH_MEDIUM_6 = "Is mighty fish!",
		OCEANFISH_MEDIUM_7 = "Is mighty fish!",
		OCEANFISH_MEDIUM_8 = "Brrr, gives Wolfgang the chills.",
        OCEANFISH_MEDIUM_9 = "Pretty purple fishy.",

		PONDFISH = "Is fishy.",
		PONDEEL = "Eel needs cooking!",

        FISHMEAT = "Lump of stinky protein.",
        FISHMEAT_COOKED = "Meat from water still make Wolfgang strong.",
        FISHMEAT_SMALL = "Fish lump for eating.",
        FISHMEAT_SMALL_COOKED = "Looks better now.",
		SPOILED_FISH = "Is good no more.",

		FISH_BOX = "Is new home for fish. For now.",
        POCKET_SCALE = "Tiny scale fit in palm of Wolfgang's hand!",

		TACKLECONTAINER = "Is good place for fish things!",
		SUPERTACKLECONTAINER = "Is even better place for fish things!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "Is scale to measure mightiness of fish!",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nIs very impressive.",
			BURNING = "Little scale is burning!",
			BURNT = "Little scale is all burned away.",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nOf course Wolfgang's fish is mightiest!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nCome see mighty fish caught by Wolfgang!",
		},

		OCEANFISHABLEFLOTSAM = "Is just lump of mud?",

		CALIFORNIAROLL = "Get in Wolfgang's stomach!",
		SEAFOODGUMBO = "This will make very strong Wolfgang!",
		SURFNTURF = "Very good.",

        WOBSTER_SHELLER = "Wolfgang will steer clear of the pinchers.",
        WOBSTER_DEN = "Is home of the shellbeasts.",
        WOBSTER_SHELLER_DEAD = "Wolfgang wish he had fearsome hand claws!",
        WOBSTER_SHELLER_DEAD_COOKED = "Is ready to eat now.",

        LOBSTERBISQUE = "Seems fancy.",
        LOBSTERDINNER = "A meal fit for Wolfgang!",

        WOBSTER_MOONGLASS = "Is glassy shellbeast?",
        MOONGLASS_WOBSTER_DEN = "Is home of the glassy shellbeasts.",

		TRIDENT = "Is good fork for Wolfgang-sized meals!",

		WINCH =
		{
			GENERIC = "Is mighty wooden arm for grabbing!",
			RETRIEVING_ITEM = "Pull, mighty arm! Pull!",
			HOLDING_ITEM = "Ha! Easy job for Wolfgang!",
		},

        HERMITHOUSE = {
            GENERIC = "This no place for someone's babushka.",
            BUILTUP = "Make good home for old shell lady.",
        },

        SHELL_CLUSTER = "Wolfgang will break it open with own mighty fists!",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "Is mighty singing shell!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Is singing shell?",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Is wimpy small singing shell.",
        },

        CHUM = "Eat, fish! Is good for you!",

        SUNKENCHEST =
        {
            GENERIC = "Is filled with treasure things, yes?",
            LOCKED = "Wolfgang... can't... pry... open!",
        },

        HERMIT_BUNDLE = "Mighty Wolfgang was happy to help frail old lady!",
        HERMIT_BUNDLE_SHELLS = "Wolfgang like the plink-plonk shells.",

        RESKIN_TOOL = "Is like magic show!",
        MOON_FISSURE_PLUGGED = "Why is ground stuffed with stinky shells?",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Tiny dog grow mighty too!",
            "Tiny dog grow mighty too!",
        },
        WOBYSMALL =
        {
            "Woby is good pup.",
            "Woby is good pup.",
        },
		WALTERHAT = "Will tiny hat fit on Wolfgang's mighty head?",
		SLINGSHOT = "Wolfgang prefer to fight with fists.",
		SLINGSHOTAMMO_ROCK = "Is little bits of junk.",
		SLINGSHOTAMMO_MARBLE = "Is little bits of junk.",
		SLINGSHOTAMMO_THULECITE = "Is little bits of junk.",
        SLINGSHOTAMMO_GOLD = "Is little bits of junk.",
        SLINGSHOTAMMO_SLOW = "Is little bits of junk.",
        SLINGSHOTAMMO_FREEZE = "Is little bits of junk.",
		SLINGSHOTAMMO_POOP = "Is little bits of poop.",
        PORTABLETENT = "Is good, solid tent!",
        PORTABLETENT_ITEM = "Wolfgang will set up tent. Make it strong!",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Stronglady have voice as powerful as her muscles!",
        BATTLESONG_HEALTHGAIN = "Stronglady have voice as powerful as her muscles!",
        BATTLESONG_SANITYGAIN = "Stronglady have voice as powerful as her muscles!",
        BATTLESONG_SANITYAURA = "Stronglady have voice as powerful as her muscles!",
        BATTLESONG_FIRERESISTANCE = "Stronglady have voice as powerful as her muscles!",
        BATTLESONG_INSTANT_TAUNT = "Wolfgang will stick to lifting and punching.",
        BATTLESONG_INSTANT_PANIC = "Wolfgang will stick to lifting and punching.",

        -- Webber
        MUTATOR_WARRIOR = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        MUTATOR_DROPPER = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        MUTATOR_HIDER = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        MUTATOR_SPITTER = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        MUTATOR_MOON = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        MUTATOR_HEALER = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        SPIDER_WHISTLE = "Wolfgang not sure he wants to be at spider party...",
        SPIDERDEN_BEDAZZLER = "Monsterchild will draw Wolfgang next, yes?",
        SPIDER_HEALER = "Scary dust spider!",
        SPIDER_REPELLENT = "Is clicky clacky spider box.",
        SPIDER_HEALER_ITEM = "Wolfgang will leave yucky glop for spiders.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "Wolfgang not trust tiny bottles made by creepy girl.",
		GHOSTLYELIXIR_FASTREGEN = "Wolfgang not trust tiny bottles made by creepy girl.",
		GHOSTLYELIXIR_SHIELD = "Wolfgang not trust tiny bottles made by creepy girl.",
		GHOSTLYELIXIR_ATTACK = "Wolfgang not trust tiny bottles made by creepy girl.",
		GHOSTLYELIXIR_SPEED = "Wolfgang not trust tiny bottles made by creepy girl.",
		GHOSTLYELIXIR_RETALIATION = "Wolfgang not trust tiny bottles made by creepy girl.",
		SISTURN =
		{
			GENERIC = "Is like tiny house for bird! But why is little pot here?",
			SOME_FLOWERS = "Wolfgang will find more flowers for tiny house!",
			LOTS_OF_FLOWERS = "Wolfgang like the flowers, but why is little pot floating?",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Wolfgang will cook good meal for friends, meal like home!",
            DONE = "A meal with friends!",

			COOKING_LONG = "Good meal needs time to stew.",
			COOKING_SHORT = "Will be ready soon, my friends!",
			EMPTY = "Wolfgang will find something to cook!",
        },

        PORTABLEBLENDER_ITEM = "Wolfgang could smash food like that if he wanted.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Wolfgang will turn grinder with his mighty muscles!",
            DONE = "Is little pile with mighty taste.",
        },
        SPICEPACK = "Wolfgang will carry all the food!",
        SPICE_GARLIC = "Smells like mama used to make.",
        SPICE_SUGAR = "Fruit smashing made sweet sauce.",
        SPICE_CHILI = "Is mighty spicy, but Wolfgang can take it.",
        SPICE_SALT = "Smashed big salt rock into many tiny tasty rocks!",
        MONSTERTARTARE = "Blech!",
        FRESHFRUITCREPES = "Manly midmorning brunch.",
        FROGFISHBOWL = "Food will make Wolfgang very strong!",
        POTATOTORNADO = "Wolfgang loves potato.",
        DRAGONCHILISALAD = "Vegetables help Wolfgang grow big and strong.",
        GLOWBERRYMOUSSE = "Tasty-making friend has made thing very tasty.",
        VOLTGOATJELLY = "Is look very nice, tasty-making friend!",
        NIGHTMAREPIE = "Wolfgang must eat with eyes closed.",
        BONESOUP = "Wolfgang will be so mighty!",
        MASHEDPOTATOES = "Friend has made Wolfgang delicious potatoes.",
        POTATOSOUFFLE = "Wolfgang is very proud of tiny cooking friend.",
        MOQUECA = "Made by Wolfgang's friend. Mmm.",
        GAZPACHO = "Is tasting very good!",
        ASPARAGUSSOUP = "Is warm in Wolfgang's belly.",
        VEGSTINGER = "Hoo! Is spicy!",
        BANANAPOP = "Wolfgang can eat in one bite!",
        CEVICHE = "It will be better in Wolfgang's belly!",
        SALSA = "Is a tasty sauce!",
        PEPPERPOPPER = "Wolfgang like a spicy challenge!",

        TURNIP = "I will use in many dishes! Yes!",
        TURNIP_COOKED = "Smell is very good.",
        TURNIP_SEEDS = "Is little tiny seeds for burying.",

        GARLIC = "Is good flavor for stewing.",
        GARLIC_COOKED = "Flavor is good now.",
        GARLIC_SEEDS = "Is little tiny seeds for burying.",

        ONION = "Wolfgang eats like apple when not cooking.",
        ONION_COOKED = "Crispy, brown, sweet.",
        ONION_SEEDS = "Is little tiny seeds for burying.",

        POTATO = "Wolfgang's favorite veggie.",
        POTATO_COOKED = "Is golden brown! Texture like sun!",
        POTATO_SEEDS = "Is little tiny seeds for burying.",

        TOMATO = "Is good for sauce makings.",
        TOMATO_COOKED = "Roasty and toasty.",
        TOMATO_SEEDS = "Is little tiny seeds for burying.",

        ASPARAGUS = "Wolfgang always eat his vegetables.",
        ASPARAGUS_COOKED = "Vegetables make me big and strong.",
        ASPARAGUS_SEEDS = "It grows up to make food.",

        PEPPER = "Hehe! Is little tiny vegetable.",
        PEPPER_COOKED = "Teeny vegetable smashes Wolfgang's tastebuds.",
        PEPPER_SEEDS = "It grows up to make food.",

        WEREITEM_BEAVER = "Beard is making crafts?",
        WEREITEM_GOOSE = "Wolfgang getting a bit worried about beardy friend...",
        WEREITEM_MOOSE = "This make beardman mighty like Wolfgang?",

        MERMHAT = "Wolfgang will be biggest and strongest fish man!",
        MERMTHRONE =
        {
            GENERIC = "Big sitting mat looks very inviting.",
            BURNT = "Is burnt up.",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "Tiny fish girl seems very busy.",
            BURNT = "All gone in puff of smoke.",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Is house for fish men!",
            BURNT = "Little house was no match for fire.",
        },

        MERMWATCHTOWER_REGULAR = "Is tree full of fighting fish!",
        MERMWATCHTOWER_NOKING = "Is tree full of fish!",
        MERMKING = "Wolfgang would like to challenge him to arm wrestle!",
        MERMGUARD = "Not as mighty as Wolfgang!",
        MERM_PRINCE = "Looks too scrawny to be king!",

        SQUID = "Wolfgang make friends with bright little fishies.",

		GHOSTFLOWER = "Is pretty... pretty scary.",
        SMALLGHOST = "Aaaaah! Er, ahem, meant AAAAAAAAAAAAAAH!!",

        CRABKING =
        {
            GENERIC = "This makes Wolfgang very scared AND hungry.",
            INERT = "Is giant castle of sand!",
        },
		CRABKING_CLAW = "Keep away from boat, big pinchers!",

		MESSAGEBOTTLE = "Has tiny note inside!",
		MESSAGEBOTTLEEMPTY = "Nothing inside.",

        MEATRACK_HERMIT =
        {
            DONE = "Will old lady be able to eat such tough meat?",
            DRYING = "Dry meaty things! Dry!",
            DRYINGINRAIN = "Go away, rain! Meat is drying!",
            GENERIC = "Is sad and meat-less.",
            BURNT = "Cannot dry meat now.",
            DONE_NOTMEAT = "Is very good and dry now!",
            DRYING_NOTMEAT = "Wolfgang could punch water out, maybe?",
            DRYINGINRAIN_NOTMEAT = "Sky tears is re-wetting the dry things!",
        },
        BEEBOX_HERMIT =
        {
            READY = "Is ready for harvest!",
            FULLHONEY = "Is ready for harvest!",
            GENERIC = "Funny looking house for bees.",
            NOHONEY = "It has no honey.",
            SOMEHONEY = "Bees are busy.",
            BURNT = "Bees are burned.",
        },

        HERMITCRAB = "Wolfgang never seen such crabby old lady.",

        HERMIT_PEARL = "Will take good care of shiny stone!",
        HERMIT_CRACKED_PEARL = "Wolfgang did not take good care of shiny stone.",

        -- DSEAS
        WATERPLANT = "Tall plant makes Wolfgang nervous...",
        WATERPLANT_BOMB = "Is bad plant! Very bad plant!",
        WATERPLANT_BABY = "Ha! So small and weak!",
        WATERPLANT_PLANTER = "It needs rock for the growing.",

        SHARK = "Eep! Wolfgang's muscles too tough for eating!",

        MASTUPGRADE_LAMP_ITEM = "Put fire up high. Is safer that way.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "Is lightning trap.",

        WATERPUMP = "Splishy splashy pump.",

        BARNACLE = "Come out of shell, Wolfgang is hungry!",
        BARNACLE_COOKED = "Is taste of sea.",

        BARNACLEPITA = "Wolfgang like chewy food pocket.",
        BARNACLESUSHI = "Is too tiny!",
        BARNACLINGUINE = "Good food, fills belly!",
        BARNACLESTUFFEDFISHHEAD = "Wolfgang stuff face with stuffed fish faces!",

        LEAFLOAF = "This food confuses Wolfgang.",
        LEAFYMEATBURGER = "Wolfgang want to eat cow, not eat LIKE cow.",
        LEAFYMEATSOUFFLE = "Jiggly!",
        MEATYSALAD = "Need more than weird leaves to fill Wolfgang's mighty belly!",

        -- GROTTO

		MOLEBAT = "Sniffer Rat has weak and puny wings! This makes Wolfgang laugh!",
        MOLEBATHILL = "Is mushy, stinky home.",

        BATNOSE = "Is naked? Wolfgang will look away.",
        BATNOSE_COOKED = "Nose has been toasted.",
        BATNOSEHAT = "Wolfgang likes funny milk hat!",

        MUSHGNOME = "Little mushy man.",

        SPORE_MOON = "Make big noise for tiny puff.",

        MOON_CAP = "Wolfgang tired of mushrooms.",
        MOON_CAP_COOKED = "It is changed.",

        MUSHTREE_MOON = "Mushy tree.",

        LIGHTFLIER = "Please stay close to Wolfgang.",

        GROTTO_POOL_BIG = "Wolfgang would like to swim, but too much glass in the way.",
        GROTTO_POOL_SMALL = "Even tiny pond is full of glass.",

        DUSTMOTH = "Bushy beardy bug.",

        DUSTMOTHDEN = "Is cozy home for moths.",

        ARCHIVE_LOCKBOX = "Strange box puzzles Wolfgang...",
        ARCHIVE_CENTIPEDE = "Metal bug is angry.",
        ARCHIVE_CENTIPEDE_HUSK = "Is big pile of junk.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "This take long time.",
            COOKING_SHORT = "Is almost cook!",
            DONE = "Is time to eat!",
            EMPTY = "Is dusty old pot.",
            BURNT = "Pot is dead.",
        },

        ARCHIVE_MOON_STATUE = "Ha! Wolfgang could carry big rock all by himself!",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "Is nice statue, but is covered in scribblemarks.",
            LINE_2 = "Very fancy.",
            LINE_3 = "Is nice statue, but is covered in scribblemarks.",
            LINE_4 = "Very fancy.",
            LINE_5 = "Is nice statue, but is covered in scribblemarks.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "Will show the way to... something.",
            IDLE = "Is pointing way no more.",
        },

        ARCHIVE_RESONATOR_ITEM = "Is magic or science, Wolfgang not picky.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "Silly machine does nothing.",
          GENERIC =  "Buttons for Wolfgang to mash mightily!",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "Seems fine to Wolfgang.",
            GENERIC = "Wolfgang was wrong, is very bad.",
        },

        ARCHIVE_SECURITY_PULSE = "Where you going? Wolfgang will follow!",

        ARCHIVE_SWITCH = {
            VALID = "There is strange hum coming from underneath.",
            GEMS = "Fancy pillar is empty. Too bad.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Is another door?",
            GENERIC = "Maybe is just pretty floor.",
        },

        WALL_STONE_2 = "Wall is strong like me!",
        WALL_RUINS_2 = "Old wall is strong!",

        REFINED_DUST = "Is strong dust! Very strong!",
        DUSTMERINGUE = "Wolfgang will leave that for someone else to eat.",

        SHROOMCAKE = "Wolfgang will eat whole cake!",

        NIGHTMAREGROWTH = "Wolfgang feels chill crawling up mighty spine...",

        TURFCRAFTINGSTATION = "Wolfgang will crush up dirt and turn into new dirt!",

        MOON_ALTAR_LINK = "Maybe little light ball needs time to get mightier?",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Is barrel of stink dirt.",
            WET = "Squishy soggy.",
            DRY = "Too dry.",
            BALANCED = "Is good! Dirt is ready!",
            BURNT = "Can't use anymore.",
        },
        COMPOST = "Is food for plants.",
        SOIL_AMENDER =
		{
			GENERIC = "Will be good drink for plants, make them strong!",
			STALE = "Stink getting stronger... will make plants stronger too!",
			SPOILED = "Is powerful plant drink with powerful smell!",
		},

		SOIL_AMENDER_FERMENTED = "Is ready to make plants mighty!",

        WATERINGCAN =
        {
            GENERIC = "Wolfgang will give garden a drink!",
            EMPTY = "Is empty.",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "Wolfgang can carry much water in that.",
            EMPTY = "Need water.",
        },

		FARM_PLOW = "It is doing a mighty job!",
		FARM_PLOW_ITEM = "Will make garden full of fruits and veggies for Wolfgang!",
		FARM_HOE = "Is to till soil for tiny seeds.",
		GOLDEN_FARM_HOE = "Fancy garden hoe good for planting seeds!",
		NUTRIENTSGOGGLESHAT = "Fills Wolfgang's head with the plant know-hows!",
		PLANTREGISTRYHAT = "Is helmet for gardening?",

        FARM_SOIL_DEBRIS = "You are in the way!",

		FIRENETTLES = "Bad and stingy.",
		FORGETMELOTS = "Pretty little flowers.",
		SWEETTEA = "Ahhh... is nice.",
		TILLWEED = "Took Wolfgang ages to get out of garden!",
		TILLWEEDSALVE = "Feels nice on the boo-boos.",
        WEED_IVY = "Is sharp looking.",
        IVY_SNARE = "Now is more weeds in the way.",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Whose fruit or veggie will be mightiest?",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nWolfgang could lift with only one finger.",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nHa! Very mighty indeed!",
            HAS_ITEM_LIGHT = "Is too puny for scale to work.",
			BURNING = "Not good!",
			BURNT = "Cooked.",
        },

        CARROT_OVERSIZED = "At least is big. Wolfgang can use for weights.",
        CORN_OVERSIZED = "Wolfgang's muscles will get even more mighty lifting giant corn!",
        PUMPKIN_OVERSIZED = "Is even bigger than weakling science man's head!",
        EGGPLANT_OVERSIZED = "Wolfgang is getting tired of being fooled by non-egg plant...",
        DURIAN_OVERSIZED = "Is big and spiky fruit.",
        POMEGRANATE_OVERSIZED = "Is big and good for lifting!",
        DRAGONFRUIT_OVERSIZED = "Do not worry small weak friends, Wolfgang can carry giant fruit!",
        WATERMELON_OVERSIZED = "Is extra big to hold more melon inside.",
        TOMATO_OVERSIZED = "Is almost big enough to fill Wolfgang's mighty belly!",
        POTATO_OVERSIZED = "Is... is most beautiful thing Wolfgang has ever seen...",
        ASPARAGUS_OVERSIZED = "Big vegetables for growing even bigger and stronger!",
        ONION_OVERSIZED = "Onion is good for you! Big ones even better!",
        GARLIC_OVERSIZED = "Is never enough garlic!",
        PEPPER_OVERSIZED = "Is filled with powerful spice.",

        VEGGIE_OVERSIZED_ROTTEN = "Wolfgang was going to eat that...",

		FARM_PLANT =
		{
			GENERIC = "Plant.",
			SEED = "Is just tiny seed.",
			GROWING = "Is growing up strong.",
			FULL = "Good to eat!",
			ROTTEN = "Is so sad!",
			FULL_OVERSIZED = "Plant has reached full mightiness!",
			ROTTEN_OVERSIZED = "Wolfgang was going to eat that...",
			FULL_WEED = "Sneaky weed thinks it can muscle in on Wolfgang's garden?!",

			BURNING = "No! Is burning!",
		},

        FRUITFLY = "Wolfgang not like bugs!",
        LORDFRUITFLY = "Ack! Is big and creepy!",
        FRIENDLYFRUITFLY = "Is helpful bug, but still creepy.",
        FRUITFLYFRUIT = "Weird thing attracts helpful, creepy flies.",

        SEEDPOUCH = "Is small pack for seeds.",

		-- Crow Carnival
		CARNIVAL_HOST = "He is like ringmaster, but more birdy.",
		CARNIVAL_CROWKID = "Welcome, bird child! Enjoy carnival!",
		CARNIVAL_GAMETOKEN = "Is token for bird games.",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "Aha! Is ticket for prize!",
			GENERIC_SMALLSTACK = "Wolfgang will get biggest prize!",
			GENERIC_LARGESTACK = "Pile is almost as big as Wolfgang's muscles!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "Little bird door.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "Is needing token first.",
			PLAYING = "Ha ha! Wolfgang will feed all the birdies!",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "Ah... reminds Wolfgang of circus days.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Haha! Is worms, but not real!",

		CARNIVALGAME_MEMORY_KIT = "Ah... reminds Wolfgang of circus days.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "Is needing token first.",
			PLAYING = "Birds make very tricky game.",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "Little bird door.",
			PLAYING = "Was this one! No... that one?",
		},

		CARNIVALGAME_HERDING_KIT = "Ah... reminds Wolfgang of circus days.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "Is needing token first.",
			PLAYING = "Haha! They run like tiny scared running things!",
		},
		CARNIVALGAME_HERDING_CHICK = "Come back egg!",

		CARNIVAL_PRIZEBOOTH_KIT = "Don't worry birdies, Wolfgang will build it!",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Give biggest prize to Wolfgang!",
		},

		CARNIVALCANNON_KIT = "Ah... reminds Wolfgang of circus days.",
		CARNIVALCANNON =
		{
			GENERIC = "Is time for celebration!",
			COOLDOWN = "Ack! Little cannon startled Wolfgang!",
		},

		CARNIVAL_PLAZA_KIT = "Will make nice tree for birds.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Hm... this place looks bare to Wolfgang...",
			LEVEL_2 = "Wolfgang can make it even more beautiful!",
			LEVEL_3 = "Is prettiest tree in forest!",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "Ha! Is tiny and easy to make.",
		CARNIVALDECOR_EGGRIDE = "Little egg ride.",

		CARNIVALDECOR_LAMP_KIT = "Ha! Is tiny and easy to make.",
		CARNIVALDECOR_LAMP = "Makes tiny, pretty light.",
		CARNIVALDECOR_PLANT_KIT = "Ha! Is tiny and easy to make.",
		CARNIVALDECOR_PLANT = "Wolfgang could snap trunk like toothpick!",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "Very special, this one.",
			UNCOMMON = "Wolfgang has not seen many like it!",
			GENERIC = "Ah, is tiny statue!",
		},
		CARNIVALDECOR_FIGURE_KIT = "What is in tiny secret box?",

        CARNIVAL_BALL = "Reminds Wolfgang of childhood.", --unimplemented
		CARNIVAL_SEEDPACKET = "Bird snack.",
		CARNIVALFOOD_CORNTEA = "Is cold corny sludge.",

        CARNIVAL_VEST_A = "Leafy bird scarf.",
        CARNIVAL_VEST_B = "Always thought cape would look good on Wolfgang.",
        CARNIVAL_VEST_C = "Takes many more leaves to cover Wolfgang's giant muscles.",

        -- YOTB
        YOTB_SEWINGMACHINE = "Will sew loveliest of costumes for hairy cow.",
        YOTB_SEWINGMACHINE_ITEM = "So many fiddly pieces for Wolfgang to put together...",
        YOTB_STAGE = "Is reminding Wolfgang of circus.",
        YOTB_POST =  "Is good stage for hairy cows!",
        YOTB_STAGE_ITEM = "Is easy - like setting up small circus tent.",
        YOTB_POST_ITEM =  "Ha! Wolfgang will have it built in quickest of snaps!",


        YOTB_PATTERN_FRAGMENT_1 = "Is bit of pattern. Wolfgang should find more.",
        YOTB_PATTERN_FRAGMENT_2 = "Is bit of pattern. Wolfgang should find more.",
        YOTB_PATTERN_FRAGMENT_3 = "Is bit of pattern. Wolfgang should find more.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "Ha! Is huggable friend!",
            YOTB = "Wolfgang should show to judge.",
        },

        WAR_BLUEPRINT = "Yes, will make hairy cow fearsome!",
        DOLL_BLUEPRINT = "Will make hairy cow so cute!",
        FESTIVE_BLUEPRINT = "Is made from brightest of colors!",
        ROBOT_BLUEPRINT = "Will make hairy cow tough like iron!",
        NATURE_BLUEPRINT = "Flowers would be good against cow smell.",
        FORMAL_BLUEPRINT = "Who makes fancy suit for cow?",
        VICTORIAN_BLUEPRINT = "Looks very complicated to Wolfgang.",
        ICE_BLUEPRINT = "Wolfgang's hair cow will face the cold mightily!",
        BEAST_BLUEPRINT = "Hope beast gives Wolfgang luck in contest!",

        BEEF_BELL = "Ringy ding!",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "Is tiny home of tiny kitties.",
            BURNT = "Is tiny kitties safe?",
			PLAYING_HIDEANDSEEK = "Tiny kitties must be hiding somewhere.",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "Tiny kitty game will end soon, ha!",
		},

		KITCOONDEN_KIT = "Is for making strong home for tiny kitties.",

		TICOON = 
		{
			GENERIC = "Is Wolfgang's furry friend.",
			ABANDONED = "Wolfgang is sorry.",
			SUCCESS = "Furry friend is doing great job!",
			LOST_TRACK = "What you looking for, furry friend?",
			NEARBY = "Wolfgang thinks furry friend found something!",
			TRACKING = "Go, furry friend, help Wolfgang!",
			TRACKING_NOT_MINE = "Oh, is wrong kitty!",
			NOTHING_TO_TRACK = "Furry friend didn't find anything for Wolfgang.",
			TARGET_TOO_FAR_AWAY = "Tiny kitties too far from us!",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "Looks like tiny kitty, but shiny.",
            EMPTY = "Is wanting little feather, Wolfgang will help!",
            BURNT = "Poor tiny kitty.",
        },

		KITCOON_FOREST = "Is walking bush. Wait, is tiny kitty!",
		KITCOON_SAVANNA = "AHH! Wolfgang thought tiny kitty was mean kitty!",
		KITCOON_MARSH = "Is weird smell coming from tiny kitty?",
		KITCOON_DECIDUOUS = "Is tiny. Good for hiding, ha ha!",
		KITCOON_GRASS = "Ouch! Pokes Wolfgang's finger.",
		KITCOON_ROCKY = "Is tough tiny kitty, learned from Wolfgang.",
		KITCOON_DESERT = "Can tiny kitty hear Wolfgang from over there?",
		KITCOON_MOON = "Is tiny kitty made of... cheese?",
		KITCOON_YOT = "Is year of tiny kitty, yes?",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Ha! Wolfgang's punches are mighty enough to shatter stone!",
            DEAD = "Is dead so quickly!",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "Sky stone is back from dead!",
            DEAD = "Wolfgang has bad feeling...",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "Spiky wall can't stop Wolfgang!",
        ALTERGUARDIAN_PHASE3 = "Sky stone is very mad!",
        ALTERGUARDIAN_PHASE3TRAP = "Wolfgang will smash sleepy stones!",
        ALTERGUARDIAN_PHASE3DEADORB = "Old man should be careful, sky stone might wake up!",
        ALTERGUARDIAN_PHASE3DEAD = "Hmm... Wolfgang will smash it, just to be sure.",

        ALTERGUARDIANHAT = "Is good hat, except for creepy whisperings...",
        ALTERGUARDIANHATSHARD = "Hat broke apart into tiny bits.",

        MOONSTORM_GLASS = {
            GENERIC = "Can see reflection of Wolfgang's big muscles in it!",
            INFUSED = "Is strange and glowy."
        },

        MOONSTORM_STATIC = "Is tiny jumpy spark-thing.",
        MOONSTORM_STATIC_ITEM = "Ha! Tiny spark is too weak to break out!",
        MOONSTORM_SPARK = "Makes Wolfgang's moustache hairs bristle!",

        BIRD_MUTANT = "Creepy bird.",
        BIRD_MUTANT_SPITTER = "Something wrong with that bird.",

        WAGSTAFF_NPC = "Do not worry, Wolfgang is here to help flickery science man.",
        ALTERGUARDIAN_CONTAINED = "Old man brought big fancy thingamobob with him!",

        WAGSTAFF_TOOL_1 = "Wolfgang found thing for funny old man!",
        WAGSTAFF_TOOL_2 = "Funny old man is looking for this, maybe?",
        WAGSTAFF_TOOL_3 = "Is maybe belonging to funny old man?",
        WAGSTAFF_TOOL_4 = "Ha! Found you!",
        WAGSTAFF_TOOL_5 = "Old man will be so happy Wolfgang found it!",

        MOONSTORM_GOGGLESHAT = "Is fueled by potato, like Wolfgang!",

        MOON_DEVICE = {
            GENERIC = "Wolfgang understand, is giant night light!",
            CONSTRUCTION1 = "Is nice floor for light ball.",
            CONSTRUCTION2 = "Wolfgang just follow instructions.",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Is just little clock.",
			RECHARGING = "Little clock sleeps now.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Is just little clock.",
			RECHARGING = "Little clock sleeps now.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Is just little clock.",
			RECHARGING = "Little clock sleeps now.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Is just little clock.",
			RECHARGING = "Little clock sleeps now.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Is just little clock.",
			RECHARGING = "Little clock sleeps now.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Wolfgang would like to try!",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Is jumble of tiny clock things.",
        POCKETWATCH_DISMANTLER = "These tools too tiny for Wolfgang's mighty hands!",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Is very dark inside... maybe Wolfgang will just walk instead?",
			DIFFERENTSHARD = "Is very dark inside... maybe Wolfgang will just walk instead?",
		},
        POCKETWATCH_PORTAL_EXIT = "Wolfgang is happy to be out of tunnel.",

        -- Waterlog
        WATERTREE_PILLAR = "Tree must lift lot of weights to get so big!",
        OCEANTREE = "What is tree doing way out here?",
        OCEANTREENUT = "Is heavy, but not too heavy for Wolfgang!",
        WATERTREE_ROOT = "Is big tree root.",

        OCEANTREE_PILLAR = "Wolfgang make mighty tree of his own!",
        
        OCEANVINE = "AAAH-- oh. Wolfgang thought was snake.",
        FIG = "Is big sweet fruit.",
        FIG_COOKED = "Warm fruit ready for Wolfgang to eat!",

        SPIDER_WATER = "Scary water spider!",
        MUTATOR_WATER = "Tiny spider will be crushed in Wolfgang's mighty jaws! Or maybe not.",
        OCEANVINE_COCOON = "Wolfgang not like look of that...",
        OCEANVINE_COCOON_BURNT = "Hmm, Wolfgang smell burnt spiders.",

        GRASSGATOR = "If he not bother Wolfgang, Wolfgang not bother him.",

        TREEGROWTHSOLUTION = "Grow, tree! Be strong!",

        FIGATONI = "Is noodles of sweetness.",
        FIGKABAB = "All food should go on stick!",
        KOALEFIG_TRUNK = "Is nose, cooked and stuffed.",
        FROGNEWTON = "Is sweet, but also slimy.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "How did tiny tree get inside?",
            CRIMSON = "Should maybe not have fed scary stuff to weird triangle.",
            ENABLED = "Tiny tree is shooting rainbow!",
			WAITING_FOR_DARK = "Wolfgang likes the sparkles.",
			COOLDOWN = "Tiny tree is now gone! Strange...",
			SPAWN_DISABLED = "Wolfgang not want to see giant eye again.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Watch, puny friends! Wolfgang will perform feats of strength!",
            BURNT = "Wolfgang will hold back mighty tears...",
        },

        DUMBBELL = "Ha! Wolfgang could lift boulders twice this size!",
        DUMBBELL_GOLDEN = "Lift! Lift to get strong!",
		DUMBBELL_MARBLE = "Wolfgang will be strongest!",
        DUMBBELL_GEM = "Make muscles mighty!",
        POTATOSACK = "Ha! Lifting and potatoes are three of Wolfgang's favorite things!",


        TERRARIUMCHEST = 
		{
			GENERIC = "Is looking like normal chest without sparkles.",
			BURNT = "Is burned away to dust.",
			SHIMMER = "Wolfgang wants to peek inside!",
		},

		EYEMASKHAT = "Wolgang not fan of squishy hat.",

        EYEOFTERROR = "Wolfgang not like big scary eye!",
        EYEOFTERROR_MINI = "Feeling of being watched is bad, but feeling of being bitten is much worse!",
        EYEOFTERROR_MINI_GROUNDED = "Is weird thing trying to hatch?",

        FROZENBANANADAIQUIRI = "Cold and tasty! ANOTHER!",
        BUNNYSTEW = "Tiny rabbit makes big food? Wolfgang likes math.",
        MILKYWHITES = "Looks gross, must be good for Wolfgang!",

        CRITTER_EYEOFTERROR = "Little eye not so scary!",

        SHIELDOFTERROR ="Haha! Now big scary teeth belong to Wolfgang!",
        TWINOFTERROR1 = "Eep! Big scary metal eyes even worse!",
        TWINOFTERROR2 = "Eep! Big scary metal eyes even worse!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "Eep! Oh, is not real.",
        KITCOON_NAMETAG = "Wolfgang will give tiny kitty good, strong name!",

		KITCOONDECOR1 =
        {
            GENERIC = "Wolfgang will punch teasing bird!",
            BURNT = "This makes Wolfgang sad.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "Wait... is not real fish?",
            BURNT = "This makes Wolfgang sad.",
        },

		KITCOONDECOR1_KIT = "Is to make tiny kitties happy.",
		KITCOONDECOR2_KIT = "Is to make tiny kitties happy.",

        -- WX78
        WX78MODULE_MAXHEALTH = "Is robot snacks, yes?",
        WX78MODULE_MAXSANITY1 = "Is robot snacks, yes?",
        WX78MODULE_MAXSANITY = "Is robot snacks, yes?",
        WX78MODULE_MOVESPEED = "Is robot snacks, yes?",
        WX78MODULE_MOVESPEED2 = "Is robot snacks, yes?",
        WX78MODULE_HEAT = "Is robot snacks, yes?",
        WX78MODULE_NIGHTVISION = "Is robot snacks, yes?",
        WX78MODULE_COLD = "Is robot snacks, yes?",
        WX78MODULE_TASER = "Is robot snacks, yes?",
        WX78MODULE_LIGHT = "Is robot snacks, yes?",
        WX78MODULE_MAXHUNGER1 = "Is robot snacks, yes?",
        WX78MODULE_MAXHUNGER = "Is robot snacks, yes?",
        WX78MODULE_MUSIC = "Is robot snacks, yes?",
        WX78MODULE_BEE = "Is robot snacks, yes?",
        WX78MODULE_MAXHEALTH2 = "Is robot snacks, yes?",

        WX78_SCANNER = 
        {
            GENERIC ="Wolfgang's muscles too mighty for scanning, would break tiny metal brain!",
            HUNTING = "Wolfgang's muscles too mighty for scanning, would break tiny metal brain!",
            SCANNING = "Wolfgang's muscles too mighty for scanning, would break tiny metal brain!",
        },

        WX78_SCANNER_ITEM = "It sleeps now.",
        WX78_SCANNER_SUCCEEDED = "Funny machine is winking at Wolfgang?",

        WX78_MODULEREMOVER = "Is funny robot thing.",

        SCANDATA = "Is tiny boring paper.",
    },

    DESCRIBE_GENERIC = "What is this thing?",
    DESCRIBE_TOODARK = "Help friends! Save Wolfgang from dark!",
    DESCRIBE_SMOLDERING = "Is almost fire.",

    DESCRIBE_PLANTHAPPY = "Is happy, yes?",
    DESCRIBE_PLANTVERYSTRESSED = "Is very unhappy, many problems in its life.",
    DESCRIBE_PLANTSTRESSED = "Is bothered by something...",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Wolfgang should tidy up garden.",
    DESCRIBE_PLANTSTRESSORFAMILY = "Is lonely, needs family!",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "Is not enough space for so many plants!",
    DESCRIBE_PLANTSTRESSORSEASON = "Is not good season for this one.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Plant needs a drink!",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Is hungry! What do plants like to eat...",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "Wolfgang will have a little chat with plant.",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "This egg too crunchy.",
		WINTERSFEASTFUEL = "Remind Wolfgang of old country...",
    },
}
