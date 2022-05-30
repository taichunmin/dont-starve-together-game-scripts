--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "I tried, but they're occupied.",
        },
        REPAIR =
        {
            WRONGPIECE = "That is incorrect!",
        },
        BUILD =
        {
            MOUNTED = "Either I must get down, or the world must come up.",
            HASPET = "I've made my pact with a beast already.",
			TICOON = "Oh, but one's enough, hyuyu!",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I may only do that while it sleeps.",
			GENERIC = "I can't, I won't, I shan't.",
			NOBITS = "Instead of hair, there's nothing there!",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "I think you will find that creature's not mine.",
		},
		STORE =
		{
			GENERIC = "It's full, full, full.",
			NOTALLOWED = "Oh I simply couldn't.",
			INUSE = "Another soul has use of it right now.",
            NOTMASTERCHEF = "Warly won't let me peek inside. He's no fun.",
		},
        CONSTRUCT =
        {
            INUSE = "Another soul has use of it right now.",
            NOTALLOWED = "Oh I simply couldn't.",
            EMPTY = "I can't create from nothing.",
            MISMATCH = "I've made an error.",
        },
		RUMMAGE =
		{
			GENERIC = "Oh I simply couldn't.",
			INUSE = "It is making a pact with another.",
            NOTMASTERCHEF = "Warly won't let me peek inside. He's no fun.",
		},
		UNLOCK =
        {
        	WRONGKEY = "Either the key is wrong, or the lock is.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Either the key is wrong, or the lock is.",
        	KLAUS = "Hyuyu!",
			QUAGMIRE_WRONGKEY = "I believe there is another way.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Am I locked out, or in?",
            HOSTBUSY = "Goodfeather, hm? I think I know him by another name.",
            CARNIVAL_HOST_HERE = "Now where is our feathered friend?",
            NOCARNIVAL = "They've come and gone, were they but a dream all along?",
			EMPTY_CATCOONDEN = "No one's home, I'm all alone!",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "We'll need more friends if we want to play, hyuyu!",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "The game was denied, there's nowwhere to hide!",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "If we play any more, it's gonna be a chore.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "Warly won't let me peek inside. He's no fun.",
			SHADOWMAGIC = "I don't think he knows how to use it.",
		},
        COOK =
        {
            GENERIC = "I'd rather snack on a soul no one's using.",
            INUSE = "Mortals need physical food more than I do.",
            TOOFAR = "I could hop over, I suppose.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Now that's quite the trick, invisible racing Carrats!",
        },

		DISMANTLE =
		{
			COOKING = "I'm afraid the pot is far too hot!",
			INUSE = "Another soul has use of it right now.",
			NOTEMPTY = "First it must be relieved of its possessions.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Stop, abort! My line's too short!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "I fear I've brought the wrong gear, hyuyu!",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "No, no, no.",
            DEAD = "Their soul's not in right now.",
            SLEEPING = "Their mind inhabits another plane right now.",
            BUSY = "I will try again at a different point in time.",
            ABIGAILHEART = "This soul's already been sucked! Hyuyu!",
            GHOSTHEART = "There's no body for it to return to.",
            NOTGEM = "It couldn't fit if it wanted to!",
            WRONGGEM = "Its color is wrong, wrong, wrong.",
            NOTSTAFF = "That's quite wrong, yes, yes!",
            MUSHROOMFARM_NEEDSSHROOM = "There is only room... for a 'shroom!",
            MUSHROOMFARM_NEEDSLOG = "Its tummy rumbles for the soul of a log.",
            MUSHROOMFARM_NOMOONALLOWED = "It doesn't want to put down roots here.",
            SLOTFULL = "It is full already.",
            FOODFULL = "There's already a dish, and it looks delish!",
            NOTDISH = "It would be in our best interest to not.",
            DUPLICATE = "We cannot learn what we already know!",
            NOTSCULPTABLE = "I do not think so, no no no!",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Its soul is prevented from returning here.",
            WRONGSHADOWFORM = "It looks downright silly, hyuyu!",
            NOMOON = "The light of the moon, I hope it comes soon!",
			PIGKINGGAME_MESSY = "This beautiful chaos inhibits me.",
			PIGKINGGAME_DANGER = "Our souls are in mortal danger right now!",
			PIGKINGGAME_TOOLATE = "The night is upon us!",
			CARNIVALGAME_INVALID_ITEM = "Oh drat, it doesn't want that.",
			CARNIVALGAME_ALREADY_PLAYING = "Let them have their fun, then I'll show the mortals how it's done.",
            SPIDERNOHAT = "My pocket's too tight for that hat to sit right.",
            TERRARIUM_REFUSE = "What a picky little prism!",
            TERRARIUM_COOLDOWN = "Now wait one minute, there's nothing in it!",
        },
        GIVETOPLAYER =
        {
            FULL = "Their brim is bursting!",
            DEAD = "Their soul's not in right now.",
            SLEEPING = "Their mind inhabits another plane right now.",
            BUSY = "First I must gain their focus.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "Their brim is bursting!",
            DEAD = "Their soul's not in right now.",
            SLEEPING = "Their mind inhabits another plane right now.",
            BUSY = "First I must gain their focus.",
        },
        WRITE =
        {
            GENERIC = "What is written cannot be unwrote!",
            INUSE = "Someone else has command of it.",
        },
        DRAW =
        {
            NOIMAGE = "I have no imagination.",
        },
        CHANGEIN =
        {
            GENERIC = "I prefer my current form.",
            BURNING = "I'm not big on clothes, anyway.",
            INUSE = "Another soul has use of it right now.",
            NOTENOUGHHAIR = "I could give it some flair... once it has enough hair.",
            NOOCCUPANT = "I can't begin without a beefalo hitched in.",
        },
        ATTUNE =
        {
            NOHEALTH = "My body would surely die.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Its focus is elsewhere.",
            INUSE = "It has made a pact with another.",
			SLEEPING = "It's had its forty winks, methinks.",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "Its focus is elsewhere.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "You cannot learn what you already know.",
            CANTLEARN = "My poor imp head cannot contain this knowledge.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "I'm on the wrong plane of existence for this.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "Not here, my dear.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "I need something to bind within.",
        },
        PICKUP =
        {
			RESTRICTION = "I am cautious about touching it.",
			INUSE = "Another soul has use of it.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "What's the matter? I won't bite.",
                "This soul is already bound to someone else.",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Oh ho! Too late, they've made their escape.",
        },
        REPLATE =
        {
            MISMATCH = "Hyuyu! They all look the same to me!",
            SAMEDISH = "I cannot redo what's already been done!",
        },
        SAIL =
        {
        	REPAIR = "The ship is tippy tip top!",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Time to sync or swim, hyuyu!",
            BAD_TIMING1 = "If I time it just right, the end is in sight!",
            BAD_TIMING2 = "I mustn't rock the boat!",
        },
        LOWER_SAIL_FAIL =
        {
            "What a fiendishly frustrating contraption! I'm impressed.",
            "Perhaps I should try a new tack! Hyuyu!",
            "My guise as a sailor was a spectacular failure!",
        },
        BATHBOMB =
        {
            GLASSED = "I can't throw it through the looking glass!",
            ALREADY_BOMBED = "Someone else took the fun!",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "We cannot learn what we already know!",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "This minnow won't win, no!",
            OVERSIZEDVEGGIES_TOO_SMALL = "I'll have to produce some bigger produce, hyuyuyu!",
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
            GENERIC = "I already know all its tricks, hyuyu!",
            FERTILIZER = "That's all I need to know to make my garden grow.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "I'd better abscond to a freshwater pond.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Oh my, the water's run dry!",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Goodness me, it's dry as can be!",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Nope, hyuyuyu!",
            BEEF_BELL_ALREADY_USED = "Turns out in the end, it already had a friend.",
            BEEF_BELL_HAS_BEEF_ALREADY = "Having more than one wouldn't be much fun.",
        },
        HITCHUP =
        {
            NEEDBEEF = "First I must find a beefalo to be mine.",
            NEEDBEEF_CLOSER = "Now now my friend, I can't hitch you up while you're way over there!",
            BEEF_HITCHED = "Surely secured!",
            INMOOD = "My furry friend is too caught up in their furious frenzy.",
        },
        MARK =
        {
            ALREADY_MARKED = "Will a change of fate be in order?",
            NOT_PARTICIPANT = "Why was I not invited to the festivities?",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Oh ho! Something's gone awry!",
            ALREADYACTIVE = "Perhaps he too likes to travel between planes? Hyuyuyu!",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "Oh what a bore, I've seen it before.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Oh ho, too slow!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "Fiddle dee dee, they won't listen to me!",
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
            DOER_ISNT_MODULE_OWNER = "The tin gnat is not keen to chat.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "I seem to be missing a thing or two.",
		NO_TECH = "Its making is a mystery to me.",
		NO_STATION = "No, no, this just won't do.",
	},

	ACTIONFAIL_GENERIC = "No, no, no.",
	ANNOUNCE_BOAT_LEAK = "Now this ride's getting fun!",
	ANNOUNCE_BOAT_SINK = "Into the drink I go, hyuyu!",
	ANNOUNCE_DIG_DISEASE_WARNING = "I've helped it!", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Its soul has not left its body, yet still it stinks.", --removed
	ANNOUNCE_ADVENTUREFAIL = "I've had enough plane hopping.",
    ANNOUNCE_MOUNT_LOWHEALTH = "Its soul hangs by a thread.",

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

	ANNOUNCE_BEES = "Fiddle dee dee, HERE COMES A BEE!",
	ANNOUNCE_BOOMERANG = "Hyuyu!",
	ANNOUNCE_CHARLIE = "What manner of imp was that??",
	ANNOUNCE_CHARLIE_ATTACK = "OWIE-HEE-HEE!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "It's finally frozen over!",
	ANNOUNCE_HOT = "Hot, hot, hot!",
	ANNOUNCE_CRAFTING_FAIL = "My hands are truly cursed.",
	ANNOUNCE_DEERCLOPS = "A massive brute is en route!",
	ANNOUNCE_CAVEIN = "I'd best hop on out of here!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"Tremors and trembles!",
		"Crumbles and cracks!",
		"Seismic shivers, seismic shakes!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Tidings and tithings to you!",
        "Chin up!",
        "Gifts all around! Or for you, at least.",
	},
	ANNOUNCE_SACREDCHEST_YES = "I'm... worthy?",
	ANNOUNCE_SACREDCHEST_NO = "It seems my soul is too tarnished.",
    ANNOUNCE_DUSK = "The night soon approaches. Hyuyu!",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Mmm! Soul free!",
		PAINFUL = "Ouch! Hyuyu!",
		SPOILED = "Blech! At least souls never spoil.",
		STALE = "How unpleasant!",
		INVALID = "Not even I could eat that.",
        YUCKY = "I'd rather eat my own tail!",

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
        "Huff... puff...",
        "Hoof...",
        "What... a terrible burden...",
        "Hyu... yu... yu....",
        "Hff!",
        "Imps were not... made for this!",
        "Puff... huff...",
        "I cannot... go on!",
        "What... a weight... to bear!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Hyuyuyu, time to go!",
		"Oh my, something's stirring.",
		"Hmm, did you hear something?",
	},
    ANNOUNCE_RUINS_RESET = "Oh good. The monsters have returned.",
    ANNOUNCE_SNARED = "I've been bound!",
    ANNOUNCE_SNARED_IVY = "Oh ho! You think you can contain me?",
    ANNOUNCE_REPELLED = "What trickery is this!",
	ANNOUNCE_ENTER_DARK = "I've been banished to the darkness plane!",
	ANNOUNCE_ENTER_LIGHT = "I return to this plane of existence!",
	ANNOUNCE_FREEDOM = "I am unbound!",
	ANNOUNCE_HIGHRESEARCH = "My brain's grown three sizes this day!",
	ANNOUNCE_HOUNDS = "The beasts are baying!",
	ANNOUNCE_WORMS = "Something approaches from beneath!",
	ANNOUNCE_HUNGRY = "Oh no, I'm hungry again.",
	ANNOUNCE_HUNT_BEAST_NEARBY = "I love a game of hide and seek!",
	ANNOUNCE_HUNT_LOST_TRAIL = "You win this round!",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Sabotaged by this realm's mushiness.",
	ANNOUNCE_INV_FULL = "I only have two paws.",
	ANNOUNCE_KNOCKEDOUT = "Oh, good morning!",
	ANNOUNCE_LOWRESEARCH = "That wasn't very enlightening.",
	ANNOUNCE_MOSQUITOS = "Mosquitos! Do I even have blood??",
    ANNOUNCE_NOWARDROBEONFIRE = "I'd prefer not to singe my fur.",
    ANNOUNCE_NODANGERGIFT = "Presents later, playtime now!",
    ANNOUNCE_NOMOUNTEDGIFT = "I must depart this sweet beast first.",
	ANNOUNCE_NODANGERSLEEP = "Who could sleep when there's fun to be had?",
	ANNOUNCE_NODAYSLEEP = "I wouldn't want to mess up my sleep schedule.",
	ANNOUNCE_NODAYSLEEP_CAVE = "An imp must stay on guard when underground.",
	ANNOUNCE_NOHUNGERSLEEP = "I'm too soul-famished to sleep.",
	ANNOUNCE_NOSLEEPONFIRE = "I'd prefer not to singe my fur.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "It's far too bright to sleep tonight.",
	ANNOUNCE_NODANGERSIESTA = "Why sleep when there's fun afoot?",
	ANNOUNCE_NONIGHTSIESTA = "No honorable imp would siesta at night.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "An imp must stay on guard when underground.",
	ANNOUNCE_NOHUNGERSIESTA = "I'm too soul-famished to siesta.",
	ANNOUNCE_NO_TRAP = "Can't catch me!",
	ANNOUNCE_PECKED = "But why!",
	ANNOUNCE_QUAKE = "Shiver and shake, that's a quake!",
	ANNOUNCE_RESEARCH = "My mind has expanded!",
	ANNOUNCE_SHELTER = "Ah, much better!",
	ANNOUNCE_THORNS = "It pricked me!",
	ANNOUNCE_BURNT = "Too hot for my impish paws!",
	ANNOUNCE_TORCH_OUT = "Farewell, sweet flame!",
	ANNOUNCE_THURIBLE_OUT = "Oh dear, I think our truce just expired.",
	ANNOUNCE_FAN_OUT = "I've lost a fan!",
    ANNOUNCE_COMPASS_OUT = "My compass has pass-ed out!",
	ANNOUNCE_TRAP_WENT_OFF = "Oh dear, oh dear.",
	ANNOUNCE_UNIMPLEMENTED = "What on earth could it be!",
	ANNOUNCE_WORMHOLE = "Hyuyu, how grotesque that was!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Never fear, the imp is here!",
	ANNOUNCE_CANFIX = "\nI could restore it.",
	ANNOUNCE_ACCOMPLISHMENT = "I feel excellent about myself!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I've done the thing!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It needs some plant food.",
	ANNOUNCE_TOOL_SLIP = "Whoops-a-doodle, hyuyu!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Hyuyu! Can't catch me!",
	ANNOUNCE_TOADESCAPING = "Don't flee! Play with me!",
	ANNOUNCE_TOADESCAPED = "It's gone home.",


	ANNOUNCE_DAMP = "The world is giving me a shower!",
	ANNOUNCE_WET = "There is wet imp smell in my future.",
	ANNOUNCE_WETTER = "I am the soggiest imp!",
	ANNOUNCE_SOAKED = "I AM DRENCHED!",

	ANNOUNCE_WASHED_ASHORE = "I escaped the threat, but now I'm wet!",

    ANNOUNCE_DESPAWN = "Hyuyu, fare thee well!",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!",
	ANNOUNCE_GHOSTDRAIN = "Ghosts play... strange games...",
	ANNOUNCE_PETRIFED_TREES = "The trees are playing a funny prank!",
	ANNOUNCE_KLAUS_ENRAGE = "Time to hop out of here!",
	ANNOUNCE_KLAUS_UNCHAINED = "Shall we dance?",
	ANNOUNCE_KLAUS_CALLFORHELP = "Well that's no fun, friend!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Time to come out and play, okay?",
		GLASS_LOW = "Yoo-hyuyu!",
		GLASS_REVEAL = "Hello there!",
		IDOL_MED = "Time to come out and play, okay?",
		IDOL_LOW = "Yoo-hyuyu!",
		IDOL_REVEAL = "Hello there!",
		SEED_MED = "Time to come out and play, okay?",
		SEED_LOW = "Yoo-hyuyu!",
		SEED_REVEAL = "Hello there!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "What a s-silly prank!",
	ANNOUNCE_BRAVERY_POTION = "Okay, let's play!",
	ANNOUNCE_MOONPOTION_FAILED = "Oh, you're no fun at all.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "I'm not going to eat it, might as well give it to the mortals.",
	ANNOUNCE_WINTERS_FEAST_BUFF = "Hyuyu, how splendid!",
	ANNOUNCE_IS_FEASTING = "A fancy feast... or a fancied feast? Hyuyu!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "I'll never lose the impish sparkle in my eye.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "C'mon back, silly goose.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Up and at'em!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "The imp returns!",

    ANNOUNCE_FLARE_SEEN = "One of my friends is inviting me to play!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Hyuyu, something's come to play!",

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
    ANNOUNCE_SOUL_EMPTY =
    {
        "Woe be to a soul-starved imp!",
        "I don't want to suck anymore souls!",
        "What gruesome things I must do to live!",
    },
    ANNOUNCE_SOUL_FEW =
    {
        "I'll need more souls soon.",
        "I feel the soul hunger stirring.",
    },
    ANNOUNCE_SOUL_MANY =
    {
        "I've enough souls to sustain me.",
        "I hope I was not too greedy.",
    },
    ANNOUNCE_SOUL_OVERLOAD =
    {
        "I can't handle that much soul power!",
        "That was one soul too many!",
    },

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "That was nothing! Nothing!",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Well it's not raw! Hyuyu!",
    QUAGMIRE_ANNOUNCE_LOSE = "Oh dear.",
    QUAGMIRE_ANNOUNCE_WIN = "Must be off now!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I'm an electric imp!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Hyuyu, I'm ready to play!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I feel just great! Must've been something I ate!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "That was just the thing to give my step a spring!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "There will be no wet fur smell for this imp! Hyuyu!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "You won't catch this imp sleeping, hyuyu!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "I think I gave them quite a shock! Hyuyu!",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "It was all just a prank!",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "That was fun, let's do it again!",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "All work and no play doesn't suit an imp. Hyuyu!",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Alas and alack, the dampness is back.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "Maybe I could do with a wink or two...",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Well drat, I guess that's that.",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "The line's gone slack, best reel it back!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "Hyuyu, what a slippery little fellow!",
	ANNOUNCE_OCEANFISHING_BADCAST = "Try and try again!",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Surely there's more fun ways to catch a fish.",
		"I'm really only interested in catching soles.",
		"I do hope a fish will fall for my prank.",
		"Perhaps they're still spawning.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nI got my wish, a hefty fish!",

	ANNOUNCE_WINCH_CLAW_MISS = "I thought I'd be better at this game.",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "It's come up with nothing.",

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
    ANNOUNCE_WEAK_RAT = "Time has nearly run out for this would-be racer.",

    ANNOUNCE_CARRAT_START_RACE = "Let the race begin, I'm sure to win!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Your route seems rather roundabout.",
        "The path to victory is the other way, my friend!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Oh pardon me, does this race bore you?",
    ANNOUNCE_CARRAT_ERROR_WALKING = "If you don't quicken your pace, we'll lose this race!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "Gotten cold feet? And have they frozen to the ground?",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "It's not nearly as comfortable as my kind's way of traveling...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Oooh, now there's an interesting idea!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "Oh drat, I already knew that.",
    ANNOUNCE_ARCHIVE_NO_POWER = "What great power could wake it from its slumber?",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "I'm learning a lot about this plant I've got!",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "What will grow from this seed is a mystery, indeed!",

    ANNOUNCE_FERTILIZER_RESEARCHED = "I'm getting the scoop on this gardening goop.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Such nasty nettles!",
		"Ouch! There wasn't any silver in those nettles, was there?",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "It seems I've beat the heat!",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "A pleasant day to you, my good greenery!",
        "I'm so sorry, I'm afraid I'm not quite fluent in plant.",
		"How dull to spend your life stuck in the ground! Luckily I'm here to make it more exciting!",
        "You like hearing the sound of my voice almost as much as I do, hyuyu!",
        "Let's pull a prank! What do you think the mortals would do if you sprouted into a sheep?",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "The cats have run, the game's begun!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Oh, what fun, I'll help find one!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"I found a cat, but no fiddle, hyuyu!",
		"The cat's out of the bag, hyuyu!",
		"Your tail's a tattletale!",
		"Always at the last place I would look!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "The last one better hide with all their might, hyuyu!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "Smile from ear to ear, the cats are all here!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "I found, we found, the cats all around!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "I'm late! I'm late! I'll lose at this rate.",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "I'll have to note down those hiding spots, hyuyu.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "No furry mortal would hide far far away!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Back to the guessing game, hyuyu.",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "And what are you doing over here?",

	ANNOUNCE_TICOON_START_TRACKING	= "He'll get us nowhere fast, hyuyu!",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "No tracks, no clue, I say we're through.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "He won't go ahead unless I keep my step, hyuyu!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Oh, is it me you're looking for?",
	ANNOUNCE_TICOON_NEAR_KITCOON = "We're close, closer, yet closer!",
	ANNOUNCE_TICOON_LOST_KITCOON = "Oh me, oh my, they passed me by!",
	ANNOUNCE_TICOON_ABANDONED = "I did my best, now I'll rest.",
	ANNOUNCE_TICOON_DEAD = "My guide is gone, do I carry on?",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Over here, beefalo dear!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "Alas, I fear I can't build that here.",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Hyuyu! A new plan has taken shape!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "I don't suppose this is a friendly visit? Hyuyu...",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Hyuyu, back for more fun?",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "The light of day keeps the eye at bay!",

	BATTLECRY =
	{
		GENERIC = "Let's have some fun.",
		PIG = "Dance with me, piggy pig!",
		PREY = "I want to play!",
		SPIDER = "Let's play, let's play!",
		SPIDER_WARRIOR = "Do you dance?",
		DEER = "You look like fun, dear.",
	},
	COMBAT_QUIT =
	{
		GENERIC = "I am the wimp imp!",
		PIG = "Never mind, I've forgotten my dancing shoes.",
		PREY = "You no longer entertain me.",
		SPIDER = "I am the wimp imp!",
		SPIDER_WARRIOR = "I'll take my leave. Hyuyu!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "I can come and go as I please.",
        MULTIPLAYER_PORTAL_MOONROCK = "Ooo, what delightful games we might play in there!",
        MOONROCKIDOL = "What, pray tell, do you desire?",
        CONSTRUCTION_PLANS = "But it's more fun to wing it!",

        ANTLION =
        {
            GENERIC = "You need only tell me what you desire.",
            VERYHAPPY = "Are you not pleased, my friend?",
            UNHAPPY = "Apologies, dear beast! I am but a worm!",
        },
        ANTLIONTRINKET = "Better get a bucket!",
        SANDSPIKE = "Hyuyu, you won't get me!",
        SANDBLOCK = "Goodness gracious, goodness me!",
        GLASSSPIKE = "Sharp and pointy as my tooth!",
        GLASSBLOCK = "A pretty spire, made of glass.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="I think it eats souls, too.",
			LEVEL1 = "No need to hide from me... tasty as you might be.",
			LEVEL2 = "How are you doing in there?",
			LEVEL3 = "My, you're looking spirited! Hyuyu!",

			-- deprecated
            LONG = "It's very sad. Full of regrets.",
            MEDIUM = "Waking up, are we?",
            SOON = "It seems the fun will soon begin.",
            HAUNTED_POCKET = "Sadly, it is not mine to keep.",
            HAUNTED_GROUND = "Ohh, you're hungry too.",
        },

        BALLOONS_EMPTY = "Stores one's breath for later spells.",
        BALLOON = "I often feel like I might float away. Hyuyu!",
		BALLOONPARTY = "A party! Am I invited?",
		BALLOONSPEED =
        {
            DEFLATED = "Its magic is spent.",
            GENERIC = "With this gift, I'll be more swift!",
        },
		BALLOONVEST = "A bright balloon vest to wear across my chest.",
		BALLOONHAT = "I'm likely to get lightheaded from wearing it, hyuyuyu!",

        BERNIE_INACTIVE =
        {
            BROKEN = "He seemed a fine chap.",
            GENERIC = "What a pity.",
        },

        BERNIE_ACTIVE = "Good sir, are you aware you've no soul?",
        BERNIE_BIG = "It's grown to new heights to win all our fights!",

        BOOK_BIRDS = "Humans share their knowledge so freely.",
        BOOK_TENTACLES = "Imps don't disseminate precious knowledge so carelessly.",
        BOOK_GARDENING = "Secret knowledge of vegetables.",
		BOOK_SILVICULTURE = "Why not read it to the reeds? Hyuyuyu!",
		BOOK_HORTICULTURE = "Secret knowledge of vegetables.",
        BOOK_SLEEP = "Knowledge is power. Literally.",
        BOOK_BRIMSTONE = "Who would leave such precious knowledge lying here?",

        PLAYER =
        {
            GENERIC = "Hello, hello, good day, good day!",
            ATTACKER = "That was a mean prank, %s!",
            MURDERER = "That wasn't a prank! That mortal's dead!",
            REVIVER = "What a kind soul you have there!",
            GHOST = "Ooo, lunch is here!",
            FIRESTARTER = "Ooo, who did you prank?",
        },
        WILSON =
        {
            GENERIC = "Who wants to do science when you can play?",
            ATTACKER = "That was a mean prank, %s!",
            MURDERER = "That wasn't a prank! That mortal's dead!",
            REVIVER = "%s traded a soul for a heart!",
            GHOST = "Ooo, lunch is here!",
            FIRESTARTER = "%s knows how to tell a joke!",
        },
        WOLFGANG =
        {
            GENERIC = "Hello, hello my giant friend!",
            ATTACKER = "Hoohoo, %s knows how to throw a punch!",
            MURDERER = "%s, you've got a taste for souls!",
            REVIVER = "What a sweet soul %s is!",
            GHOST = "Can I just get a taste?",
            FIRESTARTER = "Hyuyu, %s is so funny!",
        },
        WAXWELL =
        {
            GENERIC = "He has a bit of magic, that one.",
            ATTACKER = "Not the horns!",
            MURDERER = "Eep! Don't banish me from this plane!",
            REVIVER = "Thank-you, thank-you %s!",
            GHOST = "What a tasty looking soul!",
            FIRESTARTER = "%s, you have a funnybone after all!",
        },
        WX78 =
        {
            GENERIC = "Hyuyu %s, do you have an off button?",
            ATTACKER = "Hoohoo, I'll stop grinding your gears! Promise!",
            MURDERER = "Don't kill the poor little imp!",
            REVIVER = "What a kind and noble deed!",
            GHOST = "Not so soulless after all, hyuyu!",
            FIRESTARTER = "Ooo, the tin can has a sense of humor!",
        },
        WILLOW =
        {
            GENERIC = "Oh, you're the funny one!",
            ATTACKER = "Hey! That's not funny!",
            MURDERER = "%s! You're just as bad as my old partner!",
            REVIVER = "Thanks for the leg up!",
            GHOST = "Ooo, free soul!",
            FIRESTARTER = "Ooohoo, have you been playing pranks?",
        },
        WENDY =
        {
            GENERIC = "Do my claws scare you? Hyuyu!",
            ATTACKER = "I don't like the game you're playing.",
            MURDERER = "I was just playing around! Please don't hurt me!",
            REVIVER = "Thanks for not eating that soul, %s!",
            GHOST = "Don't worry, I'm not gonna eat you.",
            FIRESTARTER = "Hyuyu, how funny you are, %s!",
        },
        WOODIE =
        {
            GENERIC = "That axe of his sure can tell a joke.",
            ATTACKER = "I'll stop hiding your axe, promise! Hyuyu!",
            MURDERER = "Don't kill me, hyuyuyu!",
            REVIVER = "%s is oh so helpful!",
            GHOST = "You wouldn't even notice if I took a bite.",
            BEAVER = "Hyuyu, you're so funny, %s!",
            BEAVERGHOST = "What a funny soul! I wonder what it tastes like.",
            MOOSE = "The curse is growing, your antlers are showing!",
            MOOSEGHOST = "You wouldn't mind if I sneak a bite, would you?",
            GOOSE = "What's got your feathers in a bunch? Hyuyu!",
            GOOSEGHOST = "Do goose souls taste like chicken?",
            FIRESTARTER = "%s has been a bit of a prankster!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "%s needs to have some fun.",
            ATTACKER = "I'm sorry about the exploding pen gag, hyuyu!",
            MURDERER = "Hyuyu! Please don't kill me!",
            REVIVER = "%s wouldn't lose a soul so easily!",
            GHOST = "Mmm, fresh soul!",
            FIRESTARTER = "You're having too much fun, %s!",
        },
        WES =
        {
            GENERIC = "%s, let's practice our routine!",
            ATTACKER = "Those punches weren't part of the bit!",
            MURDERER = "Don't hurt me, %s!",
            REVIVER = "Thank-you, thank-you, funny friend!",
            GHOST = "%s, did you get more delicious?",
            FIRESTARTER = "Ooohoohoo, what have you been up to?",
        },
        WEBBER =
        {
            GENERIC = "Hello hello, itsy bitsy spider!",
            ATTACKER = "Please don't grab my tail!",
            MURDERER = "You wouldn't murder a helpless imp, would you??",
            REVIVER = "Hoohoo, that little monster's soft on souls.",
            GHOST = "Oh don't worry, I won't eat you.",
            FIRESTARTER = "%s is having so much fun!",
        },
        WATHGRITHR =
        {
            GENERIC = "%s, which of your myths mentions imps?",
            ATTACKER = "Don't hit me!",
            MURDERER = "Eep! Don't kill me!",
            REVIVER = "Hoohoo! %s gave a soul a helping hand!",
            GHOST = "Are you gonna eat that?",
            FIRESTARTER = "%s has been having so much fun!",
        },
        WINONA =
        {
            GENERIC = "Do you think me too silly, %s?",
            ATTACKER = "Hyuyu, I think I pushed her buttons!",
            MURDERER = "Eep! I'm but a helpless imp!",
            REVIVER = "%s, you generous soul!",
            GHOST = "Just a nibble? You don't need all that soul.",
            FIRESTARTER = "Ooo, what funny pranks you play!",
        },
        WORTOX =
        {
            GENERIC = "Oh! What a handsome devil.",
            ATTACKER = "Hey! What's with that impish grin?",
            MURDERER = "He's stealing all the good souls!",
            REVIVER = "Hyuyu, I would have eaten that soul were I you.",
            GHOST = "Are you gonna eat that?",
            FIRESTARTER = "Hyuyu! What pranks have you been playing?",
        },
        WORMWOOD =
        {
            GENERIC = "Heard any good jokes lately, %s?",
            ATTACKER = "What a cruel trick you've played! Hyuyu!",
            MURDERER = "You've really gone and dung it this time, hyuyu!",
            REVIVER = "%s is just too kind a soul, I suppose.",
            GHOST = "Finally, a break from his poop jokes.",
            FIRESTARTER = "Ooo, there's an ember of fun in you yet.",
        },
        WARLY =
        {
            GENERIC = "%s sure likes food. I don't get humans.",
            ATTACKER = "I think %s's been causing some trouble. How fun!",
            MURDERER = "Don't hurt me-hee-hee!",
            REVIVER = "I guess %s doesn't have a taste for souls.",
            GHOST = "The culinarian's become the culination, hyuyu!",
            FIRESTARTER = "Oh, are we playing pranks today, %s?",
        },

        WURT =
        {
            GENERIC = "Gotten into any trouble yet today, %s?",
            ATTACKER = "%s has a fiendish look in her eye.",
            MURDERER = "Surely we can sort this out, imp to shrimp?",
            REVIVER = "You have a good soul, %s. I promise not to eat it.",
            GHOST = "Don't fret, I won't eat you!",
            FIRESTARTER = "Hyuyuyu, brilliant!",
        },

        WALTER =
        {
            GENERIC = "Helped anyone cross the street lately, %s?",
            ATTACKER = "Making some mischief, are we %s?",
            MURDERER = "Eep! I rather like this plane, I'd hate to leave it!",
            REVIVER = "Hyuyu! Such a helpful soul!",
            GHOST = "I'll just take a nibble... hyuyu I'm only joking!",
            FIRESTARTER = "Rules are meant to be broken, hyuyuyu!",
        },

        WANDA =
        {
            GENERIC = "Have you been anytime interesting lately, %s?",
            ATTACKER = "Hyuyuyu, I don't think she liked my last prank.",
            MURDERER = "You wouldn't kill an imp in the prime of his life, would you?",
            REVIVER = "Hyuyu, %s doesn't seem to be wise to soul power, thankfully.",
            GHOST = "You're looking much tastier than usual, %s!",
            FIRESTARTER = "Oooh, mind if I join in?",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "What thoughts lurk within that curious noggin?",
            SLEEPING = "If only I were a sleep demon.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "A flower that attracts a friend.",
            DEAD = "Oh no, oh dear!",
        },
        GLOMMERWINGS = "How dainty!",
        GLOMMERFUEL = "This stuff's so funny!",
        BELL = "I believe it might bring forth delight.",
        STATUEGLOMMER =
        {
            GENERIC = "The moon will bring a friend my way.",
            EMPTY = "Whoopsie doopsie!",
        },

        LAVA_POND_ROCK = "Cold lava.",

		WEBBERSKULL = "Hm. There's two souls wedged inside.",
		WORMLIGHT = "A glowing fruit. I am astute.",
		WORMLIGHT_LESSER = "This glowy fruit is going bad.",
		WORM =
		{
		    PLANT = "The shimmer of a soul lurks below.",
		    DIRT = "A simple pile of dirt and muck.",
		    WORM = "Hyuyu! What do I do??",
		},
        WORMLIGHT_PLANT = "The shimmer of a soul lurks below.",
		MOLE =
		{
			HELD = "Careful, I don't want to accidentally touch you.",
			UNDERGROUND = "The mole is sheltered in its hole.",
			ABOVEGROUND = "The mole has left its hole!",
		},
		MOLEHILL = "Peering inside it makes my brow furrow.",
		MOLEHAT = "It lets me see on every plane!",

		EEL = "A slippery soul, that one.",
		EEL_COOKED = "I'd rather not put that in my flesh body.",
		UNAGI = "Yet another dish cooked up by mortals.",
		EYETURRET = "Oh me oh my, look at that eye!",
		EYETURRET_ITEM = "To build it would be all it took to fell my foes by deadly look.",
		MINOTAURHORN = "Harumph. It doesn't even spiral.",
		MINOTAURCHEST = "Perhaps a surprise awaits inside.",
		THULECITE_PIECES = "Such strength and such shine.",
		POND_ALGAE = "Little growth of winding green.",
		GREENSTAFF = "Do not treat it like a toy. Its purpose is to destroy.",
		GIFT = "Presents! How fun!",
        GIFTWRAP = "That's a wrap!",
		POTTEDFERN = "A plant, imprisoned for eternity.",
        SUCCULENT_POTTED = "A plant, imprisoned for eternity.",
		SUCCULENT_PLANT = "A strong willed plant, desert born.",
		SUCCULENT_PICKED = "Leaves of a plant we picked.",
		SENTRYWARD = "Hyuyu! What a mischievous way to spy!",
        TOWNPORTAL =
        {
			GENERIC = "Soul delivery machine.",
			ACTIVE = "My order's almost here.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "A rock containing a touch of fun.",
			ACTIVE = "Cheers, my dears, I must be off.",
		},
        WETPAPER = "Oh dear. Just mush now.",
        WETPOUCH = "It can barely contain itself!",
        MOONROCK_PIECES = "Smashable, crashable fun to be had.",
        MOONBASE =
        {
            GENERIC = "What are the conditions for this ritual?",
            BROKEN = "We can't perform the ritual like this.",
            STAFFED = "It's time! Call upon the moon!",
            WRONGSTAFF = "Hyuyu. That's just silly.",
            MOONSTAFF = "It is done!",
        },
        MOONDIAL =
        {
			GENERIC = "What a handsome devil I see in the water!",
			NIGHT_NEW = "A newest moon!",
			NIGHT_WAX = "It's waxing, yes oh yes it is.",
			NIGHT_FULL = "Hyuyu, I feel a bit loony!",
			NIGHT_WANE = "It's on the wane, oh yes indeed.",
			CAVE = "It was so silly to build it down here!",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "They certainly are keeping a watchful eye over us, hyuyu!",
        },
		THULECITE = "I'll use the nearest shrine to produce a design.",
		ARMORRUINS = "This thulecite sure is a delight!",
		ARMORSKELETON = "This fashion's all the rage... it's an external rib cage!",
		SKELETONHAT = "Ooohoo, it tickles my little imp-y brain!",
		RUINS_BAT = "A spiked hunk of ill intent!",
		RUINSHAT = "Jewelry to emphasize my fantastic horns!",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "No games to play today.",
            WARN = "I'm getting so excited!",
            WAXING = "Ooo, it's picking up!",
            STEADY = "Hyuyu! What fun!",
            WANING = "Aw, the chaos is dissipating.",
            DAWN = "Playtime's almost over.",
            NOMAGIC = "A fun medallion for a more fun rapscallion!",
		},
		BISHOP_NIGHTMARE = "Eep! Play nice with the imp!",
		ROOK_NIGHTMARE = "Eep! Play nice with the imp!",
		KNIGHT_NIGHTMARE = "Eep! Play nice with the imp!",
		MINOTAUR = "Goodness gracious, aren't you fearsome.",
		SPIDER_DROPPER = "You look like you want to play!",
		NIGHTMARELIGHT = "Beware, beware, it says to me.",
		NIGHTSTICK = "Shed some light on any fight.",
		GREENGEM = "Gentlest green from lush vales gleaned.",
		MULTITOOL_AXE_PICKAXE = "It couldn't decide which to be, so it became both.",
		ORANGESTAFF = "A touch of magic not my own.",
		YELLOWAMULET = "I'll give my brain a slight refrain.",
		GREENAMULET = "So I'll be more skilled when I rebuild.",
		SLURPERPELT = "My fur is much nicer!",

		SLURPER = "Please keep that mouth to yourself!",
		SLURPER_PELT = "My fur is much nicer!",
		ARMORSLURPER = "If it means I eat less often, count me in!",
		ORANGEAMULET = "It nestles nicely on my chest fur.",
		YELLOWSTAFF = "It calls the sun from out the sky!",
		YELLOWGEM = "From lava floes bellow this glimmering yellow.",
		ORANGEGEM = "Bright and orange like a... a...",
        OPALSTAFF = "Chilly and bright as a moonlit night.",
        OPALPRECIOUSGEM = "A gem like this is precious indeed.",
        TELEBASE =
		{
			VALID = "Ready for some fun!",
			GEMS = "I don't think my magic would power it.",
		},
		GEMSOCKET =
		{
			VALID = "Magic always does provide!",
			GEMS = "It could use some shine, if you ask me.",
		},
		STAFFLIGHT = "So bright it hurts my beady imp eyes!",
        STAFFCOLDLIGHT = "Hyuyu, how cold and unwelcoming!",

        ANCIENT_ALTAR = "A fun place to do some naughty magic.",

        ANCIENT_ALTAR_BROKEN = "Oh dear oh dear, that will not do.",

        ANCIENT_STATUE = "Hyuyu, how spooky!",

        LICHEN = "Last resort underground foodstuffs.",
		CUTLICHEN = "I'd really rather not eat it.",

		CAVE_BANANA = "One of the least offensive mortal food flavors.",
		CAVE_BANANA_COOKED = "It's cooked now.",
		CAVE_BANANA_TREE = "What do I see? An underground tree!",
		ROCKY = "Can a rock possess a soul?",

		COMPASS =
		{
			GENERIC="For when up is down and down is out.",
			N = "North!",
			S = "South!",
			E = "East!",
			W = "West!",
			NE = "Northeast!",
			SE = "Southeast!",
			NW = "Northwest!",
			SW = "Southwest!",
		},

        HOUNDSTOOTH = "You cannot compete with my fangs, no, no.",
        ARMORSNURTLESHELL = "Little bits of snurtle, yes.",
        BAT = "I'm quite batty myself! Hyuyu!",
        BATBAT = "Extra batty!",
        BATWING = "Look at that! The wing of a bat.",
        BATWING_COOKED = "Perhaps I'll find a hungry mortal to give it to.",
        BATCAVE = "Where the bats lie in wait.",
        BEDROLL_FURRY = "Fur upon fur!",
        BUNNYMAN = "You hop just like me!",
        FLOWER_CAVE = "How kind of you to light my way.",
        GUANO = "It came from a bat, and that is that.",
        LANTERN = "Guide my way!",
        LIGHTBULB = "Magnificent, I do dare say.",
        MANRABBIT_TAIL = "A tail from those great big bunnies.",
        MUSHROOMHAT = "I'll have mushroom spores in my horns for days.",
        MUSHROOM_LIGHT2 =
        {
            ON = "I quite like it when it's red!",
            OFF = "When it's out I feel great dread.",
            BURNT = "The light has long fled.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "A spotted spotlight to chase away the dark.",
            OFF = "It could use a little spark.",
            BURNT = "Now we're destined to the dark.",
        },
        SLEEPBOMB = "I'll throw it, then you'll catch some ZZZs!",
        MUSHROOMBOMB = "I will stay far away!",
        SHROOM_SKIN = "Spotty and stinky!",
        TOADSTOOL_CAP =
        {
            EMPTY = "Just a hole.",
            INGROUND = "Have we summoned something fun?",
            GENERIC = "Nothing to do but chop it in two.",
        },
        TOADSTOOL =
        {
            GENERIC = "Ooo, you look like FUN!",
            RAGE = "Now we're REALLY having fun!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "My, my! What do we have here?",
            BURNT = "A pity.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "A massive mushroom! Did I quaff a shrinking potion?",
            BLOOM = "Delightfully disgusting!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "A massive mushroom! Did I quaff a shrinking potion?",
            BLOOM = "How wonderfully un-wonderful!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "A massive mushroom! Did I quaff a shrinking potion?",
            BLOOM = "Hyuyu! How wretched!",
        },
        MUSHTREE_TALL_WEBBED = "She's shy so she's wearing her veil.",
        SPORE_TALL =
        {
            GENERIC = "Dazzling!",
            HELD = "My beautiful spores.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Dazzling!",
            HELD = "My beautiful spores.",
        },
        SPORE_SMALL =
        {
            GENERIC = "Dazzling!",
            HELD = "My beautiful spores.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Hyuyu! How whimsical.",
            BURNT = "Burnt down to the ground.",
        },
        SLURTLE = "Slinky, slurp and slime.",
        SLURTLE_SHELLPIECES = "Shards of shell I do see here.",
        SLURTLEHAT = "Oh how safe I do feel!",
        SLURTLEHOLE = "The hole where all the slurtles go!",
        SLURTLESLIME = "A useful slime, I think, I say.",
        SNURTLE = "Slink and slither, little snurtle.",
        SPIDER_HIDER = "Spindly spider, begone, begone!",
        SPIDER_SPITTER = "Do you spit your goop at me sir?",
        SPIDERHOLE = "All webbed up!",
        SPIDERHOLE_ROCK = "All webbed up!",
        STALAGMITE = "It's just a rock.",
        STALAGMITE_TALL = "It's just a rock.",

        TURF_CARPETFLOOR = "Floor or ceiling, depending on your perspective.",
        TURF_CHECKERFLOOR = "Floor or ceiling, depending on your perspective.",
        TURF_DIRT = "Floor or ceiling, depending on your perspective.",
        TURF_FOREST = "Floor or ceiling, depending on your perspective.",
        TURF_GRASS = "Floor or ceiling, depending on your perspective.",
        TURF_MARSH = "Floor or ceiling, depending on your perspective.",
        TURF_METEOR = "Floor or ceiling, depending on your perspective.",
        TURF_PEBBLEBEACH = "Floor or ceiling, depending on your perspective.",
        TURF_ROAD = "Floor or ceiling, depending on your perspective.",
        TURF_ROCKY = "Floor or ceiling, depending on your perspective.",
        TURF_SAVANNA = "Floor or ceiling, depending on your perspective.",
        TURF_WOODFLOOR = "Floor or ceiling, depending on your perspective.",

		TURF_CAVE="Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS="Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS_MOON = "Floor or ceiling, depending on your perspective.",
		TURF_ARCHIVE = "Floor or ceiling, depending on your perspective.",
		TURF_SINKHOLE="Floor or ceiling, depending on your perspective.",
		TURF_UNDERROCK="Floor or ceiling, depending on your perspective.",
		TURF_MUD="Floor or ceiling, depending on your perspective.",

		TURF_DECIDUOUS = "Floor or ceiling, depending on your perspective.",
		TURF_SANDY = "Floor or ceiling, depending on your perspective.",
		TURF_BADLANDS = "Floor or ceiling, depending on your perspective.",
		TURF_DESERTDIRT = "Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS_GREEN = "Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS_RED = "Floor or ceiling, depending on your perspective.",
		TURF_DRAGONFLY = "Floor or ceiling, depending on your perspective.",

        TURF_SHELLBEACH = "Floor or ceiling, depending on your perspective.",

		POWCAKE = "Hyuyu! This cake packs a wallop!",
        CAVE_ENTRANCE = "Clear the way I say!",
        CAVE_ENTRANCE_RUINS = "Let me have a peek inside!",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "No spelunking for this little imp!",
            OPEN = "Away I go, hyuyu!",
            FULL = "A party rages down below!",
        },
        CAVE_EXIT =
        {
            GENERIC = "I like it here in the deep dark.",
            OPEN = "Away I go, hyuyu!",
            FULL = "A party rages up above!",
        },

		MAXWELLPHONOGRAPH = "Ooo, music! I'm practically giddy!",--single player
		BOOMERANG = "What goes around comes around, they say, they say!",
		PIGGUARD = "We don't have to fight, you know.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Poor soul.",
                "Poor soul.",
            },
            LEVEL2 =
            {
                "Poor soul.",
                "Poor soul.",
            },
            LEVEL3 =
            {
                "Poor soul.",
                "Poor soul.",
            },
		},
		ADVENTURE_PORTAL = "I want to play a game with you!",
		AMULET = "A glimmering jewel that's rife with life.",
		ANIMAL_TRACK = "Those aren't my hoofprints!",
		ARMORGRASS = "Protect oneself with a swish and a wish!",
		ARMORMARBLE = "Stone cold!",
		ARMORWOOD = "Knock on wood, they say, they say!",
		ARMOR_SANITY = "Keeps the flesh body safe! The mind's another story.",
		ASH =
		{
			GENERIC = "Cinders, cinders, cinders.",
			REMAINS_GLOMMERFLOWER = "The planar hop has destroyed this flower!",
			REMAINS_EYE_BONE = "The planar hop has destroyed this bone!",
			REMAINS_THINGIE = "It could not exist on this plane.",
		},
		AXE = "To whack and to chop.",
		BABYBEEFALO =
		{
			GENERIC = "It belongs with its momma.",
		    SLEEPING = "Sleep softly sweet soul.",
        },
        BUNDLE = "Does a nice surprise await inside?",
        BUNDLEWRAP = "Bind all cursed objects!",
		BACKPACK = "Behold this burden on my back!",
		BACONEGGS = "A mortal favorite.",
		BANDAGE = "A wrap for wounds.",
		BASALT = "Big, big rock, for sure, for sure.", --removed
		BEARDHAIR = "Mortal fur.",
		BEARGER = "Do not eat me, oh please, oh please!",
		BEARGERVEST = "Sometimes you want to wear someone else's fur.",
		ICEPACK = "Chilly, chilly, to be sure!",
		BEARGER_FUR = "You won't be eating me today!",
		BEDROLL_STRAW = "To lay my sweet little head down.",
		BEEQUEEN = "Tweeheehe! You're a big bee!",
		BEEQUEENHIVE =
		{
			GENERIC = "My hooves would get stuck in it.",
			GROWING = "Ooo, a new mystery!",
		},
        BEEQUEENHIVEGROWN = "The mystery grows!",
        BEEGUARD = "Beeee gentle with me!",
        HIVEHAT = "Hyuyu! I'm the king!",
        MINISIGN =
        {
            GENERIC = "Hyuyu, draw me next!",
            UNDRAWN = "Time for a little doodle, yes?",
        },
        MINISIGN_ITEM = "A bunch of wood to plant in the ground.",
		BEE =
		{
			GENERIC = "Buzz buzz buzz, tiny bee!",
			HELD = "Careful now, little mortal.",
		},
		BEEBOX =
		{
			READY = "So much honey! The mortals will be overjoyed!",
			FULLHONEY = "So much honey! The mortals will be overjoyed!",
			GENERIC = "A box full of bees would make a great prank.",
			NOHONEY = "Nothing inside but bees, oh yes!",
			SOMEHONEY = "We could scrape a bit of honey out.",
			BURNT = "Mayhaps it's caramelized within!",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "The mortals will be very, very pleased.",
			LOTS = "Oh good! The mortals get cranky when they're hungry.",
			SOME = "I don't want them, but the mortals might.",
			EMPTY = "Just a log if you ask me!",
			ROTTEN = "I don't think the mortals will eat that.",
			BURNT = "No more mushrooms to have here!",
			SNOWCOVERED = "Little tiny icy log.",
		},
		BEEFALO =
		{
			FOLLOWER = "Hyuyu! Are we playing follow the leader?",
			GENERIC = "Hello, hello, dear beefalo!",
			NAKED = "Hyuyuyu! That's too good!",
			SLEEPING = "Shhh.",
            --Domesticated states:
            DOMESTICATED = "I believe we've made a friend!",
            ORNERY = "Don't you feel just hopping mad?",
            RIDER = "Don't you want to carry me?",
            PUDGY = "It's soul is chubby too, hyuyu!",
            MYPARTNER = "We're kindred souls, wouldn't you say?",
		},

		BEEFALOHAT = "Horn replacements.",
		BEEFALOWOOL = "Ex-beefalo.",
		BEEHAT = "What if my horns get stung?",
        BEESWAX = "None of mine!",
		BEEHIVE = "One swift kick and it becomes a great prank.",
		BEEMINE = "This will be a funny prank.",
		BEEMINE_MAXWELL = "That's not a funny prank at all!",--removed
		BERRIES = "A handful of mortal treats.",
		BERRIES_COOKED = "I hear they last longer this way.",
        BERRIES_JUICY = "Mortals eat them as a snack.",
        BERRIES_JUICY_COOKED = "I hear they last longer this way.",
		BERRYBUSH =
		{
			BARREN = "It won't be returning to this plane.",
			WITHERED = "Feeling down, are you?",
			GENERIC = "Mortals say they're sweet to eat.",
			PICKED = "Gone, all gone.",
			DISEASED = "Now it stinks really good!",--removed
			DISEASING = "It's started to stink.",--removed
			BURNING = "Whoops-a-doodle.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Salted earth, none will return.",
			WITHERED = "Feeling down, are you?",
			GENERIC = "The humans like them, yes indeed.",
			PICKED = "Gone, all gone.",
			DISEASED = "Now it stinks really good!",--removed
			DISEASING = "It's started to stink.",--removed
			BURNING = "Whoops-a-doodle.",
		},
		BIGFOOT = "Do not step on little old me!",--removed
		BIRDCAGE =
		{
			GENERIC = "A place where little birds are penned.",
			OCCUPIED = "Hello my singing, feathered friend.",
			SLEEPING = "No more sleepless nights you'll spend.",
			HUNGRY = "No worries, lunch is right around the bend.",
			STARVING = "Does no one have some seeds to lend?",
			DEAD = "It seems you went and met your end.",
			SKELETON = "I don't think she's exactly on the mend.",
		},
		BIRDTRAP = "The birds will find this so funny!",
		CAVE_BANANA_BURNT = "I don't think anyone wants it now.",
		BIRD_EGG = "An egg from a bird, or so I've heard.",
		BIRD_EGG_COOKED = "Probably a mortal thing.",
		BISHOP = "You sure look mean, you nasty fiend!",
		BLOWDART_FIRE = "Ptt!",
		BLOWDART_SLEEP = "Pph!",
		BLOWDART_PIPE = "Ptoo!",
		BLOWDART_YELLOW = "Prrp!",
		BLUEAMULET = "The cold won't get through my chest tuft, hyuyu.",
		BLUEGEM = "Somber blue from seabeds grew.",
		BLUEPRINT =
		{
            COMMON = "What knowledge will I find within?",
            RARE = "Ooo, secret knowledge, what fun, what power!",
        },
        SKETCH = "Would you look at that!",
		BLUE_CAP = "Funny tricks it tries to play.",
		BLUE_CAP_COOKED = "That changed it somehow.",
		BLUE_MUSHROOM =
		{
			GENERIC = "Found you!",
			INGROUND = "It's playing hide and seek!",
			PICKED = "Gone, all gone.",
		},
		BOARDS = "It's a board. How untoward!",
		BONESHARD = "Fragmented, like my thoughts!",
		BONESTEW = "Mortals like drinking goop like this.",
		BUGNET = "I'll bind those bugs.",
		BUSHHAT = "Now you see me, now you don't! Hyuyu!",
		BUTTER = "Essence of slipperiness.",
		BUTTERFLY =
		{
			GENERIC = "Flutter, flutter, dearest butter!",
			HELD = "I'll try not to suck your soul out.",
		},
		BUTTERFLYMUFFIN = "Muffin to see here, my dear.",
		BUTTERFLYWINGS = "Fly away, sweet soul.",
		BUZZARD = "It doesn't want to feed on death. It just has to.",

		SHADOWDIGGER = "So, what's he paying you?",

		CACTUS =
		{
			GENERIC = "Spiny and mean, just how I like them.",
			PICKED = "To pick a cactus, you just need some prac-tus!",
		},
		CACTUS_MEAT_COOKED = "The prickles are gone, but I still don't want to eat it.",
		CACTUS_MEAT = "I don't want to eat anything prickly.",
		CACTUS_FLOWER = "How pretty! I fear to touch it.",

		COLDFIRE =
		{
			EMBERS = "Soon to extinguish.",
			GENERIC = "Brrrning brrrright.",
			HIGH = "Chilly! So chilly.",
			LOW = "It burns so low, so low!",
			NORMAL = "Brisk fire. That's new.",
			OUT = "And out it goes.",
		},
		CAMPFIRE =
		{
			EMBERS = "Soon to extinguish.",
			GENERIC = "This fire will slake my thirst for warmth.",
			HIGH = "Those are some spicy flames.",
			LOW = "It burns so low, so low!",
			NORMAL = "When I roam, camp feels like home.",
			OUT = "And out it goes.",
		},
		CANE = "Is it walking me, or am I walking it?",
		CATCOON = "I prefer playing with smarter mortals.",
		CATCOONDEN =
		{
			GENERIC = "A home for friends.",
			EMPTY = "Yoohoo! Anybody home?",
		},
		CATCOONHAT = "It's a stripey horn concealer.",
		COONTAIL = "Better yours than mine.",
		CARROT = "Non-imps like to eat things like this.",
		CARROT_COOKED = "I think non-imps like it better cooked.",
		CARROT_PLANTED = "There's a plant underneath.",
		CARROT_SEEDS = "Grow a seed and you shall feed!",
		CARTOGRAPHYDESK =
		{
			GENERIC = "I could make maps to anywhere and nowhere.",
			BURNING = "Someone's been up to some mischief.",
			BURNT = "That's all she wrote.",
		},
		WATERMELON_SEEDS = "Grow a seed and you shall feed!",
		CAVE_FERN = "It prefers the dark.",
		CHARCOAL = "Pre-burnt tree.",
        CHESSPIECE_PAWN = "Would you like to play?",
        CHESSPIECE_ROOK =
        {
            GENERIC = "We carved this from the rock ourselves.",
            STRUGGLE = "Yes, yes, come play!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "Let's play a game, you and I!",
            STRUGGLE = "Yes, yes, come play!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Bishop made of polished stone.",
            STRUGGLE = "Yes, yes, come play!",
        },
        CHESSPIECE_MUSE = "How whimsically elegant.",
        CHESSPIECE_FORMAL = "You've a much too competitive spirit, sir.",
        CHESSPIECE_HORNUCOPIA = "What a funny use for a horn!",
        CHESSPIECE_PIPE = "Bubble, bubble, no such trouble.",
        CHESSPIECE_DEERCLOPS = "That was such a fun day!",
        CHESSPIECE_BEARGER = "I'll say a prayer for this slain bear.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "We've established a stone goose truce.",
            "We've established a stone moose truce.",
        },
        CHESSPIECE_DRAGONFLY = "Bye bye, dear dragonfly.",
		CHESSPIECE_MINOTAUR = "It's as though the Minotaur met Medusa.",
        CHESSPIECE_BUTTERFLY = "It does not float, nor does it sting.",
        CHESSPIECE_ANCHOR = "So heavy, heavy, dreary, dreary.",
        CHESSPIECE_MOON = "The mortals thought it was made of cheese! Hyuyu!",
        CHESSPIECE_CARRAT = "Not so light on its feet now, hyuyu!",
        CHESSPIECE_MALBATROSS = "Oh my word, that was a feisty bird!",
        CHESSPIECE_CRABKING = "He was better at sinking than being a sea king.",
        CHESSPIECE_TOADSTOOL = "A fine piece of art, especially the warts.",
        CHESSPIECE_STALKER = "No more rattlin' bones.",
        CHESSPIECE_KLAUS = "A stagnant stag.",
        CHESSPIECE_BEEQUEEN = "Stationary majesty. Static insect.",
        CHESSPIECE_ANTLION = "An anti Ant Lion, formerly furry. Hyuyu!",
        CHESSPIECE_BEEFALO = "This beefalo is even more hard-headed than most!",
		CHESSPIECE_KITCOON = "They'll reach the sky on high!",
		CHESSPIECE_CATCOON = "This little guy and I don't see eye to eye, hyuyu.",
        CHESSPIECE_GUARDIANPHASE3 = "In all its selenic splendour!",
        CHESSPIECE_EYEOFTERROR = "He's gone, no matter how you look at it, hyuyu!",
        CHESSPIECE_TWINSOFTERROR = "What an eye-catching statue, hyuyu!",

        CHESSJUNK1 = "It looks quite broke, and that's no joke!",
        CHESSJUNK2 = "It looks quite broke, and that's no joke!",
        CHESSJUNK3 = "It looks quite broke, and that's no joke!",
		CHESTER = "Greetings! Sorry, I can't pet you.",
		CHESTER_EYEBONE =
		{
			GENERIC = "My, my, what do you see?",
			WAITING = "There's no soul attuned to it.",
		},
		COOKEDMANDRAKE = "It's at peace now.",
		COOKEDMEAT = "I don't really like having food in my stomach.",
		COOKEDMONSTERMEAT = "I'd still rather not eat it.",
		COOKEDSMALLMEAT = "At least it smells better now.",
		COOKPOT =
		{
			COOKING_LONG = "It will take quite some time.",
			COOKING_SHORT = "I'm shivering with anticipation!",
			DONE = "Looks like my treat is ready to eat!",
			EMPTY = "Can souls simmer?",
			BURNT = "I don't understand how to make mortal food.",
		},
		CORN = "I prefer not to ingest food.",
		CORN_COOKED = "I thought it was supposed to pop.",
		CORN_SEEDS = "Grow a seed and you shall feed!",
        CANARY =
		{
			GENERIC = "Let's look out for each other, you and I.",
			HELD = "Mind my paws now.",
		},
        CANARY_POISONED = "Mortals don't usually look like that.",

		CRITTERLAB = "Ooo, I'd like a partner in pranks.",
        CRITTER_GLOMLING = "What a cute little munchkin you are.",
        CRITTER_DRAGONLING = "Look at you, little firebreather!",
		CRITTER_LAMB = "Just know that I'm petting you in my mind.",
        CRITTER_PUPPY = "Sorry I can't pet you, little friend.",
        CRITTER_KITTEN = "What should our next prank be, little kitty?",
        CRITTER_PERDLING = "You're so sweet, I could just gobble you up.",
		CRITTER_LUNARMOTHLING = "On wings alight comes a fuzzy delight!",

		CROW =
		{
			GENERIC = "Clever trickster.",
			HELD = "Careful, don't touch my hands.",
		},
		CUTGRASS = "Oh, what I could weave!",
		CUTREEDS = "One swift yank was all it took.",
		CUTSTONE = "Brick by brick, they say, they say.",
		DEADLYFEAST = "I desire this even less than regular food.", --unimplemented
		DEER =
		{
			GENERIC = "Greetings, dearest!",
			ANTLER = "My, what a lovely horn you have!",
		},
        DEER_ANTLER = "I like mine better.",
        DEER_GEMMED = "That's a good look for you!",
		DEERCLOPS = "So large, so rude, so full of 'tude!",
		DEERCLOPS_EYEBALL = "Apologies, dear sir.",
		EYEBRELLAHAT =	"A cyclops' sight stretched mighty thin.",
		DEPLETED_GRASS =
		{
			GENERIC = "It's gone away for now.",
		},
        GOGGLESHAT = "I have to keep up appearances.",
        DESERTHAT = "I do so dislike having sand in my face fur.",
		DEVTOOL = "It's a prank-maker.",
		DEVTOOL_NODEV = "Whoops-a-doodle!",
		DIRTPILE = "I could get my claws in there.",
		DIVININGROD =
		{
			COLD = "The trail's gone cold, I feel cajoled.", --singleplayer
			GENERIC = "It will guide me where I wish to go.", --singleplayer
			HOT = "Red hot! We're near the spot!", --singleplayer
			WARM = "Hey, hey, hey! We're on our way!", --singleplayer
			WARMER = "I have to boast, we're getting close!", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "How very, very curious!", --singleplayer
			READY = "Let's hop, skip and jump out of here!", --singleplayer
			UNLOCKED = "Ooo, my fur's standing on end in anticipation!", --singleplayer
		},
		DIVININGRODSTART = "And now begins a thrilling game!", --singleplayer
		DRAGONFLY = "Fear me! I'm a scary imp!",
		ARMORDRAGONFLY = "Ooo, I've always wanted to be scaly.",
		DRAGON_SCALES = "I prefer fur to scales.",
		DRAGONFLYCHEST = "Chest to impress.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "It lost its glamor to the hammer.",
			GENERIC = "A cage to hold the dragon's rage.", --no gems
			NORMAL = "It burns the right amount, I'd say.", --one gem
			HIGH = "It burns so bright both day and night.", --two gems
		},

        HUTCH = "Hello, hello, my small cave friend.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "It is on the inside looking out.",
            WAITING = "Its heart is weeping for its friend.",
        },
		LAVASPIT =
		{
			HOT = "If I don't get bit I'll burn in spit!",
			COOL = "It cannot hurt my hooves now!",
		},
		LAVA_POND = "I won't dip my toe in.",
		LAVAE = "I remember when I was that age.",
		LAVAE_COCOON = "A friend is sleeping deep within.",
		LAVAE_PET =
		{
			STARVING = "Oh gracious, it's starving!",
			HUNGRY = "Do you eat souls?",
			CONTENT = "What a happy wyrm you are.",
			GENERIC = "You are blessed with eternal youth! Yes you are!",
		},
		LAVAE_EGG =
		{
			GENERIC = "Is there a sweet pet inside?",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "My oh my, you're much too cold!",
			COMFY = "Sweet and cozy as a clam.",
		},
		LAVAE_TOOTH = "My mom still has mine somewhere.",

		DRAGONFRUIT = "Plucked fresh from the dragon. Hyuyu!",
		DRAGONFRUIT_COOKED = "It's been cooked in dragonfire.",
		DRAGONFRUIT_SEEDS = "Grow a seed and you shall feed!",
		DRAGONPIE = "Chock full of genuine dragon.",
		DRUMSTICK = "Ba-dum-chhh!",
		DRUMSTICK_COOKED = "It's been cooked now.",
		DUG_BERRYBUSH = "A bush out of dirt is like a fish out of water.",
		DUG_BERRYBUSH_JUICY = "A bush out of dirt is like a fish out of water.",
		DUG_GRASS = "Put it back in the dirt, before it gets hurt!",
		DUG_MARSH_BUSH = "Put it back in the dirt, before it gets hurt!",
		DUG_SAPLING = "Put it back in the dirt, before it gets hurt!",
		DURIAN = "I love a good stink!",
		DURIAN_COOKED = "Don't mind if I do-rian.",
		DURIAN_SEEDS = "Let's give them some soil, before they spoil.",
		EARMUFFSHAT = "They weren't made for floppy ears.",
		EGGPLANT = "I've never seen such a thing before!",
		EGGPLANT_COOKED = "My favourite treat... it can't be beat!",
		EGGPLANT_SEEDS = "Let's give them some soil, before they spoil.",

		ENDTABLE =
		{
			BURNT = "That was hardly necessary.",
			GENERIC = "I never learned my table manners.",
			EMPTY = "Now now, let's set the table.",
			WILTED = "Tiny flower on the table... you aren't looking very stable.",
			FRESHLIGHT = "A light so bright I might still see at night!",
			OLDLIGHT = "I'll try not to pout when that light soon goes out.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "Twiddle dee dee, a burning tree!",
			BURNT = "Well, that was fun.",
			CHOPPED = "A funny tree prank.",
			POISON = "It is no longer bound to the earth!",
			GENERIC = "Fanciful tree of papery bark.",
		},
		ACORN = "It's nutty, like me!",
        ACORN_SAPLING = "You know how to grow!",
		ACORN_COOKED = "I'll only eat it if I have to.",
		BIRCHNUTDRAKE = "Tiny forest children of hate!",
		EVERGREEN =
		{
			BURNING = "Twiddle dee dee, a burning tree!",
			BURNT = "Well, that was fun.",
			CHOPPED = "A funny tree prank.",
			GENERIC = "A hearty tree of dark green leaves.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Twiddle dee dee, a burning tree!",
			BURNT = "Well, that was fun.",
			CHOPPED = "A funny tree prank.",
			GENERIC = "A mournful tree full of lumps and bumps.",
		},
		TWIGGYTREE =
		{
			BURNING = "Twiddle dee dee, a burning tree!",
			BURNT = "Well, that was fun.",
			CHOPPED = "A funny tree prank.",
			GENERIC = "A slender tree of twigs and sticks.",
			DISEASED = "Oh jeez, oh ick, that tree looks sick!", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "It's just a tree baby.",
        TWIGGY_OLD = "This tree is long in the tooth.",
		TWIGGY_NUT = "It wants to be a lovely tree.",
		EYEPLANT = "My oh my, what a lovely eye.",
		INSPECTSELF = "What a handsome devil. Hyuyu!",
		FARMPLOT =
		{
			GENERIC = "Mortal food maker.",
			GROWING = "The mortals are making mortal food.",
			NEEDSFERTILIZER = "The semi-formed food is hungry.",
			BURNT = "A silly prank to be sure.",
		},
		FEATHERHAT = "Feathers and horns go well together.",
		FEATHER_CROW = "A memento of my jet feathered friend.",
		FEATHER_ROBIN = "To remind myself of its sweet beaky face.",
		FEATHER_ROBIN_WINTER = "A keepsake of a gentle blue friend.",
		FEATHER_CANARY = "A token, to remember its sweet song by.",
		FEATHERPENCIL = "Use this quill, I will, I will.",
        COOKBOOK = "Oh what shall I cook up next? Hyuyu!",
		FEM_PUPPET = "Greetings and salutations, ma'am.", --single player
		FIREFLIES =
		{
			GENERIC = "Some natural light to grant me sight.",
			HELD = "Little jittery, fluttery souls.",
		},
		FIREHOUND = "Hyuyu, fiery!",
		FIREPIT =
		{
			EMBERS = "Soon to extinguish.",
			GENERIC = "This fire will slake my thirst for warmth.",
			HIGH = "Those are some spicy flames.",
			LOW = "It burns so low, so low!",
			NORMAL = "When I roam, camp feels like home.",
			OUT = "And out it goes.",
		},
		COLDFIREPIT =
		{
			EMBERS = "Soon to extinguish.",
			GENERIC = "Brrrning brrrright.",
			HIGH = "Chilly! So chilly.",
			LOW = "It burns so low, so low!",
			NORMAL = "Brisk fire. That's new.",
			OUT = "And out it goes.",
		},
		FIRESTAFF = "It makes fire by its own magic.",
		FIRESUPPRESSOR =
		{
			ON = "It is ready to fling at a moment's notice.",
			OFF = "Dead to the world.",
			LOWFUEL = "It hungers for souls! Or fuel.",
		},

		FISH = "You are quite fragrant.",
		FISHINGROD = "A mortal pastime.",
		FISHSTICKS = "No thank-you.",
		FISHTACOS = "More mortal food.",
		FISH_COOKED = "At least it isn't suffering anymore.",
		FLINT = "My eye was caught by its dull glint.",
		FLOWER =
		{
            GENERIC = "Perfumed petals to pick and pluck.",
            ROSE = "It's as red as I am.",
        },
        FLOWER_WITHERED = "Farewell sweet petals.",
		FLOWERHAT = "I'll place a crown upon my head to ward away the growing dread.",
		FLOWER_EVIL = "It's not its fault it's evil.",
		FOLIAGE = "Purpled leaves from down below.",
		FOOTBALLHAT = "I hope I don't get helmet horns.",
        FOSSIL_PIECE = "A little piece of a great big beast.",
        FOSSIL_STALKER =
        {
			GENERIC = "Still could use a piece or two.",
			FUNNY = "A silly look, that's to be sure!",
			COMPLETE = "That looks right at rain, it does it does!",
        },
        STALKER = "Your mind's not quite right, but neither is mine!",
        STALKER_ATRIUM = "Shall we dance, dearest demon?",
        STALKER_MINION = "Silly thing!",
        THURIBLE = "Ooo! Smells like fire and brimstone!",
        ATRIUM_OVERGROWTH = "Ooo, there's some naughty magic at play here!",
		FROG =
		{
			DEAD = "I am sorry! So sorry!",
			GENERIC = "I hop, you hop. Friends til the end!",
			SLEEPING = "Sleep fast little hopper.",
		},
		FROGGLEBUNWICH = "Mortals are weird.",
		FROGLEGS = "To hop no more.",
		FROGLEGS_COOKED = "Definitely no more hopping.",
		FRUITMEDLEY = "The mortals threw a bunch of plants together.",
		FURTUFT = "Not from my chest!",
		GEARS = "Grind them and grind them well.",
		GHOST = "An unclaimed soul!",
		GOLDENAXE = "Now where's my golden fiddle?",
		GOLDENPICKAXE = "The mortals say you have to spend gold to make gold.",
		GOLDENPITCHFORK = "Fancy mob gear. Hyuyu!",
		GOLDENSHOVEL = "Luxuriously unnecessary! Hyuyu!",
		GOLDNUGGET = "Money is soulless.",
		GRASS =
		{
			BARREN = "Salted earth, none will return.",
			WITHERED = "Feeling down, are you?",
			BURNING = "Whoops-a-doodle.",
			GENERIC = "Grass that grows from richest earth.",
			PICKED = "Gone, all gone.",
			DISEASED = "Now it stinks really good!", --unimplemented
			DISEASING = "It's started to stink.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Hello dear friend! No need to drop your tail.",
			DISEASED = "I can see the disease creeping into your soul.", --unimplemented
		},
		GREEN_CAP = "These mushrooms play all sorts of tricks.",
		GREEN_CAP_COOKED = "That changed it somehow.",
		GREEN_MUSHROOM =
		{
			GENERIC = "Found you!",
			INGROUND = "It's playing hide and seek!",
			PICKED = "Gone, all gone.",
		},
		GUNPOWDER = "I'll spell your doom with a mighty BOOM!",
		HAMBAT = "I'll bring it down with a mighty hamTHWACK!",
		HAMMER = "To drive my points home.",
		HEALINGSALVE = "To remove the pain of this weary world!",
		HEATROCK =
		{
			FROZEN = "Frozen hard as a rock! Hyuyu.",
			COLD = "Slightly chilled, to be sure.",
			GENERIC = "My goodness! A rock!",
			WARM = "Quite cozy!",
			HOT = "So cozy it's almost unpleasant.",
		},
		HOME = "Yoohoo! Anyone home?",
		HOMESIGN =
		{
			GENERIC = "\"You are here\" it says, it says.",
            UNWRITTEN = "Nothing to be seen here, I fear.",
			BURNT = "A silly prank to be sure.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "It really doesn't matter which way I go!",
            UNWRITTEN = "Nothing to be seen here, I fear.",
			BURNT = "A silly prank to be sure.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "It really doesn't matter which way I go!",
            UNWRITTEN = "Nothing to be seen here, I fear.",
			BURNT = "A silly prank to be sure.",
		},
		HONEY = "It can help heal injuries if I use it right.",
		HONEYCOMB = "Former bee home. Sorry bees.",
		HONEYHAM = "Mortals have so many ways of preparing meat.",
		HONEYNUGGETS = "I guess they do look kind of good.",
		HORN = "Phew! Not one of mine.",
		HOUND = "Hyuyu, you're so badly behaved!",
		HOUNDCORPSE =
		{
			GENERIC = "A corpse is a corpse, of course, of course.",
			BURNING = "Sizzle sizzle, pop and crack.",
			REVIVING = "I do believe I'll take my leave!",
		},
		HOUNDBONE = "Short work made by gnashing teeth.",
		HOUNDMOUND = "It's the dog house!",
		ICEBOX = "Freeze mortal foods for midday feasts.",
		ICEHAT = "Horns on ice!",
		ICEHOUND = "You wouldn't want to eat an imp. Much too stringy.",
		INSANITYROCK =
		{
			ACTIVE = "My mind's in a tizzy!",
			INACTIVE = "It wants to see me lose my marbles!",
		},
		JAMMYPRESERVES = "Oh no, it's in my fur.",

		KABOBS = "More mortal food it seems, it seems.",
		KILLERBEE =
		{
			GENERIC = "Please don't sting my delicate imp skin.",
			HELD = "My claws will sting you right back.",
		},
		KNIGHT = "A knight in rusted armor!",
		KOALEFANT_SUMMER = "A gentle beast with tiny horns.",
		KOALEFANT_WINTER = "How do you do? Why are you blue?",
		KRAMPUS = "Heh heh. No hard feelings?",
		KRAMPUS_SACK = "He should have known I would not hold back.",
		LEIF = "No need to fight, my great tree friend!",
		LEIF_SPARSE = "No need to fight, my great tree friend!",
		LIGHTER  = "A tool to set fire, if you desire.",
		LIGHTNING_ROD =
		{
			CHARGED = "For peace of mind.",
			GENERIC = "It's brimming with elemental energy.",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "Your horns aren't so great.",
			CHARGED = "That one got zapped recently.",
		},
		LIGHTNINGGOATHORN = "It's okay.",
		GOATMILK = "Please, no thanks.",
		LITTLE_WALRUS = "I could play twenty tricks on you!",
		LIVINGLOG = "Don't look at me with those sad eyes!",
		LOG =
		{
			BURNING = "Oh I say, it'll burn away!",
			GENERIC = "A piece of what was once a tree.",
		},
		LUCY = "An axe is an axe, those are the facts.",
		LUREPLANT = "As the spider catches the fly.",
		LUREPLANTBULB = "There's hunger deep within that eye.",
		MALE_PUPPET = "Greetings and salutations, sir.", --single player

		MANDRAKE_ACTIVE = "Stop that or I'll steal your voice.",
		MANDRAKE_PLANTED = "It's a prank plant.",
		MANDRAKE = "It's out of prank juice.",

        MANDRAKESOUP = "Soon I'll sip a sleepy soup.",
        MANDRAKE_COOKED = "Oh, dear.",
        MAPSCROLL = "It doesn't really matter which way you go.",
        MARBLE = "Little stone slab, soon statues will be.",
        MARBLEBEAN = "Big bean, made of marble.",
        MARBLEBEAN_SAPLING = "How does it grow? I just do not know!",
        MARBLESHRUB = "A shubbery!",
        MARBLEPILLAR = "A column of marble, so tall and so cold.",
        MARBLETREE = "And here we see... a marble tree!",
        MARSH_BUSH =
        {
			BURNT = "Ashes to ashes.",
            BURNING = "Shh, shush! I see ahead a burning bush!",
            GENERIC = "Yikes! Spikes.",
            PICKED = "Gone, all gone.",
        },
        BURNT_MARSH_BUSH = "Farewell, little bristles.",
        MARSH_PLANT = "Move, I'm gazing here.",
        MARSH_TREE =
        {
            BURNING = "It seems to be a burning tree!",
            BURNT = "Goodbye, dear spikes.",
            CHOPPED = "Taken in its prime. Hyuyu!",
            GENERIC = "A sickly tree, so sharp and slender.",
        },
        MAXWELL = "You have no power over me, heehee!",--single player
        MAXWELLHEAD = "Hyuyu, that's a good trick!",--removed
        MAXWELLLIGHT = "Ooohoohoo, it warms in my presence!",--single player
        MAXWELLLOCK = "Now let's see, where is the key?",--single player
        MAXWELLTHRONE = "A precarious place to rest one's rump.",--single player
        MEAT = "Ex-animal.",
        MEATBALLS = "Physical food is so hilarious.",
        MEATRACK =
        {
            DONE = "The jerky is ready.",
            DRYING = "It's drying.",
            DRYINGINRAIN = "It's undrying day.",
            GENERIC = "I don't have much use for this.",
            BURNT = "A silly prank to be sure.",
            DONE_NOTMEAT = "The food's ready.",
            DRYING_NOTMEAT = "It's drying.",
            DRYINGINRAIN_NOTMEAT = "It's undrying day.",
        },
        MEAT_DRIED = "Mortals like this more than when it's wet.",
        MERM = "Aren't you intimidated by my massive horns?",
        MERMHEAD =
        {
            GENERIC = "I guess there are more distasteful things than soul consumption.",
            BURNT = "So long, repulsive head.",
        },
        MERMHOUSE =
        {
            GENERIC = "A stinky structure, to be sure.",
            BURNT = "Goodbye, ugly domicile.",
        },
        MINERHAT = "A head light to brighten my dreary thoughts.",
        MONKEY = "How do you do, little sir?",
        MONKEYBARREL = "Home of the little sirs.",
        MONSTERLASAGNA = "Even the mortals dislike it.",
        FLOWERSALAD = "I don't really like eating.",
        ICECREAM = "I could probably stomach that.",
        WATERMELONICLE = "Looks stomachable.",
        TRAILMIX = "Looks chewy. I hate chewing.",
        HOTCHILI = "I don't \"digest\" well.",
        GUACAMOLE = "I don't like to eat, unless I have to.",
        MONSTERMEAT = "I hope *I* don't look like that inside.",
        MONSTERMEAT_DRIED = "I still do not wish to eat it.",
        MOOSE = "What manner of beast are you?",
        MOOSE_NESTING_GROUND = "It's a place to nest and rest.",
        MOOSEEGG = "The egg of that most fearsome creature.",
        MOSSLING = "The whirlwind of youth.",
        FEATHERFAN = "It makes a big gust. What's all the fuss?",
        MINIFAN = "Round and round and round it goes.",
        GOOSE_FEATHER = "This feather may help one brave hot weather.",
        STAFF_TORNADO = "Swirl and twirl, let cruel winds unfurl!",
        MOSQUITO =
        {
            GENERIC = "Please do not bite me.",
            HELD = "I have no blood for you, sweet thing.",
        },
        MOSQUITOSACK = "It's full of mortal blood.",
        MOUND =
        {
            DUG = "The dead had no use of it, you see.",
            GENERIC = "I sense no souls within.",
        },
        NIGHTLIGHT = "Goodness gracious, what excellent decorations!",
        NIGHTMAREFUEL = "Hyuyu! It's squishy.",
        NIGHTSWORD = "To slash and stab!",
        NITRE = "I've no earthly clue how to use this.",
        ONEMANBAND = "I'll sing a song, please hum along!",
        OASISLAKE =
		{
			GENERIC = "Swimming gives me wet imp smell.",
			EMPTY = "No swimming today!",
		},
        PANDORASCHEST = "Open it, open it!",
        PANFLUTE = "My flute!",
        PAPYRUS = "An ancient scroll in the making.",
        WAXPAPER = "Waxy little wrapping scroll.",
        PENGUIN = "A bird that flies within the sea.",
        PERD = "Begone you greedy, greedy bird.",
        PEROGIES = "Mortal food, this seems to be.",
        PETALS = "Evidence of flower violence.",
        PETALS_EVIL = "A tainted beauty.",
        PHLEGM = "How very unpleasant!",
        PICKAXE = "Heigh ho, heigh ho!",
        PIGGYBACK = "So I keep my things within this little bag made of pig skin.",
        PIGHEAD =
        {
            GENERIC = "Yuck.",
            BURNT = "Goodbye, revolting pighead.",
        },
        PIGHOUSE =
        {
            FULL = "There's someone hiding, there, inside.",
            GENERIC = "A house that I may never enter.",
            LIGHTSOUT = "They will not invite me across the threshold.",
            BURNT = "Fare thee well, hideous house.",
        },
        PIGKING = "I don't mean to pester, but please make me your jester!",
        PIGMAN =
        {
            DEAD = "Oh my goodness, no.",
            FOLLOWER = "Hyuyu! Are we playing follow the leader?",
            GENERIC = "Would you like to see a trick?",
            GUARD = "You wouldn't hit an imp, would you?!",
            WEREPIG = "Goodness! How bestial!",
        },
        PIGSKIN = "Not by the hair of my rumpy rump rump!",
        PIGTENT = "Oh piggies! Let me in!",
        PIGTORCH = "It lights a flame for all to see!",
        PINECONE = "To plant a tree!",
        PINECONE_SAPLING = "A tiny little baby tree!",
        LUMPY_SAPLING = "A tiny little baby tree!",
        PITCHFORK = "I do believe it suits me!",
        PLANTMEAT = "I don't like it, no siree.",
        PLANTMEAT_COOKED = "I'll leave it to the mortals.",
        PLANT_NORMAL =
        {
            GENERIC = "A leafy little plant I see.",
            GROWING = "Grow big, grow tall, or not at all!",
            READY = "The mortals want your tasty eats.",
            WITHERED = "It does not seem to be in the highest spirits.",
        },
        POMEGRANATE = "You need only eat one seed. Hyuyu!",
        POMEGRANATE_COOKED = "The underworld can wait.",
        POMEGRANATE_SEEDS = "Let's give them some soil, before they spoil.",
        POND = "I could gaze upon my reflection all day!",
        POOP = "Physical digestion is very unpleasant.",
        FERTILIZER = "Hyuyu! That's some poo!",
        PUMPKIN = "How nice and how spooky!",
        PUMPKINCOOKIE = "Real food is a bit hard on my stomach.",
        PUMPKIN_COOKED = "Slightly easier on my impish tum.",
        PUMPKIN_LANTERN = "How delightfully spooky! Hyuyu!",
        PUMPKIN_SEEDS = "Let's give them some soil, before they spoil.",
        PURPLEAMULET = "I deserve these jewels, I think.",
        PURPLEGEM = "Dark amethyst wrenched from shadows' midst.",
        RABBIT =
        {
            GENERIC = "A fellow hopper.",
            HELD = "Do not touch my paws or claws.",
        },
        RABBITHOLE =
        {
            GENERIC = "Hopping wonders live within.",
            SPRING = "You'll not be hopping through that hole!",
        },
        RAINOMETER =
        {
            GENERIC = "Will it rain? Or will it shine?",
            BURNT = "A silly prank to be sure.",
        },
        RAINCOAT = "The puddles wait out there for me!",
        RAINHAT = "Splish and splash!",
        RATATOUILLE = "Physical food doesn't sit well with me.",
        RAZOR = "I do not shave.",
        REDGEM = "Deepest red, from golems bled.",
        RED_CAP = "Oh, no thank you.",
        RED_CAP_COOKED = "My head aches just looking at it!",
        RED_MUSHROOM =
        {
            GENERIC = "Hyuyu! Do not think to poison me!",
            INGROUND = "It's playing hide and seek!",
            PICKED = "Gone, all gone.",
        },
        REEDS =
        {
            BURNING = "Whoops-a-doodle.",
            GENERIC = "Just my luck! There's reeds to pluck!",
            PICKED = "Gone, all gone.",
        },
        RELIC = "It's just a bunch of unfun stuff!",
        RUINS_RUBBLE = "Broken all up!",
        RUBBLE = "Useless rocks, they seem to be.",
        RESEARCHLAB =
        {
            GENERIC = "Mortals play such silly games.",
            BURNT = "Well, that was fun.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "Oh, how amusing!",
            BURNT = "Well, that was fun.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "There's magic fun to be had here.",
            BURNT = "That's one way to nullify magic.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "It runs on silly trick power.",
            BURNT = "That's one way to nullify magic.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "I can never die! Hyuyu!",
            BURNT = "Delayed gratification imp banishment.",
        },
        RESURRECTIONSTONE = "Bring me back from death's dark planes!",
        ROBIN =
        {
            GENERIC = "What a fun shade of red.",
            HELD = "Mind my fingers.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "That's a bird, or so I've heard.",
            HELD = "Mind my fingers.",
        },
        ROBOT_PUPPET = "Greetings and salutations, sweet compeer.", --single player
        ROCK_LIGHT =
        {
            GENERIC = "A wisecracker like myself could crack it!",--removed
            OUT = "A wisecracker like myself could crack it!",--removed
            LOW = "The pool's begun to cool!",--removed
            NORMAL = "How warm!",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "I could move it if I pleased!",
            RAISED = "A hop, skip and a jump too far!",
        },
        ROCK = "What a shock! It's a rock!",
        PETRIFIED_TREE = "Fweeheehee! A stone cold tree!",
        ROCK_PETRIFIED_TREE = "Fweeheehee! A stone cold tree!",
        ROCK_PETRIFIED_TREE_OLD = "Fweeheehee! A stone cold tree!",
        ROCK_ICE =
        {
            GENERIC = "Who knew water could do that!",
            MELTED = "Ooo, a puddle.",
        },
        ROCK_ICE_MELTED = "Ooo, a puddle.",
        ICE = "It's such a novelty, hyuyu.",
        ROCKS = "Maybe they're boulders and I just grew really big.",
        ROOK = "A scary rook! I sure am shook!",
        ROPE = "I hope it's not for binding imps.",
        ROTTENEGG = "A powerful stink. How fun!",
        ROYAL_JELLY = "No thank you.",
        JELLYBEAN = "I do not want those in my bellybean!",
        SADDLE_BASIC = "Hyuyu, carry me!",
        SADDLE_RACE = "Let's fly! Hyuyu!",
        SADDLE_WAR = "I am an imp of war!",
        SADDLEHORN = "Off it comes, hyuyu!",
        SALTLICK = "I've been told I don't make a lick of sense.",
        BRUSH = "Keeps imp chest tufts plush.",
		SANITYROCK =
		{
			ACTIVE = "Harumpf! I go where I please!",
			INACTIVE = "Hyuyu! I'm as insane as you!",
		},
		SAPLING =
		{
			BURNING = "And here I didn't bring marshmallows!",
			WITHERED = "Feeling down, are you?",
			GENERIC = "It has delusions of being a tree.",
			PICKED = "Gone, all gone.",
			DISEASED = "Now it stinks really good!", --removed
			DISEASING = "It's started to stink.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Good day to you, sir!",
			BURNING = "That's sort of a mean prank.",
			BURNT = "You hardly deserved that.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "I can't create something from nothing.",
			BLOCK = "Artist's block. Hyuyu!",
			SCULPTURE = "I made it.",
			BURNT = "A silly prank to be sure.",
   		},
        SCULPTURE_KNIGHTHEAD = "Heave, ho, let's go!",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "Something fun is hiding inside!",
			UNCOVERED = "That's a knight alright!",
			FINISHED = "I do say that did the trick!",
			READY = "C'mon, let's play!",
		},
        SCULPTURE_BISHOPHEAD = "Heave, ho, let's go!",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Something fun is hiding inside!",
			UNCOVERED = "Time to fix-up this here bish-up.",
			FINISHED = "I do say that did the trick!",
			READY = "C'mon, let's play!",
		},
        SCULPTURE_ROOKNOSE = "Heave, ho, let's go!",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Something fun is hiding inside!",
			UNCOVERED = "Look! It's a rook!",
			FINISHED = "I do say that did the trick!",
			READY = "C'mon, let's play!",
		},
        GARGOYLE_HOUND = "I hope that hellhound's in on the prank.",
        GARGOYLE_WEREPIG = "Let's not be here when that wakes up!",
		SEEDS = "Let's give them some soil, before they spoil.",
		SEEDS_COOKED = "The seeds have been cooked.",
		SEWING_KIT = "Sew and stitch, it's quite the fix!",
		SEWING_TAPE = "Are you sure it's not magic?",
		SHOVEL = "I could dig a hole where I belong!",
		SILK = "A present from the spider's ilk.",
		SKELETON = "The soul is long gone.",
		SCORCHED_SKELETON = "Someone had a whoopsie.",
		SKULLCHEST = "Let me take a peek inside!", --removed
		SMALLBIRD =
		{
			GENERIC = "The apple of my eye.",
			HUNGRY = "Would you like a nice soul to nibble on?",
			STARVING = "Goodness gracious, you're really hungry.",
			SLEEPING = "Night night, sleep tight.",
		},
		SMALLMEAT = "Poor little creature.",
		SMALLMEAT_DRIED = "Not to my taste.",
		SPAT = "Ptoo to you too!",
		SPEAR = "For defense only, I promise.",
		SPEAR_WATHGRITHR = "The Viking woman wields it well.",
		WATHGRITHRHAT = "I hope it fits over my horns.",
		SPIDER =
		{
			DEAD = "Sorry! I'm sorry.",
			GENERIC = "Gracious, you have many legs!",
			SLEEPING = "Sweetest dreams now.",
		},
		SPIDERDEN = "A leggy surprise awaits inside!",
		SPIDEREGGSACK = "They wiggle, wriggle, 'round inside.",
		SPIDERGLAND = "It's squishy, yes oh yes it is!",
		SPIDERHAT = "Hyuyu, this is grotesque!",
		SPIDERQUEEN = "Your majesty, please don't hurt me!",
		SPIDER_WARRIOR =
		{
			DEAD = "Sorry! I'm sorry.",
			GENERIC = "I'd be okay eating his soul, I think.",
			SLEEPING = "Sweetest dreams now.",
		},
		SPOILED_FOOD = "Oh jeez, oh yuck, a pile of muck.",
        STAGEHAND =
        {
			AWAKE = "Well hello there little friend.",
			HIDING = "I see you!",
        },
        STATUE_MARBLE =
        {
            GENERIC = "A statue made of cold, cold stone.",
            TYPE1 = "Hyuyu, she's gone and lost her head!",
            TYPE2 = "Hyuyu, she's gone and lost her head!",
            TYPE3 = "I feel compelled to knock it over.", --bird bath type statue
        },
		STATUEHARP = "Little cherub, little harp.",
		STATUEMAXWELL = "My old imp friends would like this, I think.",
		STEELWOOL = "Oh my, that's scratchy!",
		STINGER = "Careful where you point that thing.",
		STRAWHAT = "It'll be uncomfortable to wear on my horns.",
		STUFFEDEGGPLANT = "This is my first time encountering such a texture.",
		SWEATERVEST = "I'm not against trying new looks.",
		REFLECTIVEVEST = "It's bright like my personality.",
		HAWAIIANSHIRT = "Oh no, that's not really my style.",
		TAFFY = "It's very chewy and sweet.",
		TALLBIRD = "Legs that go from here to there!",
		TALLBIRDEGG = "To mortals it's a tasty treat.",
		TALLBIRDEGG_COOKED = "So sorry, Ms. Bird.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "You seem chilly, silly billy.",
			GENERIC = "They grow up so fast, or so I hear.",
			HOT = "Ooo, ouch, much too hot!",
			LONG = "It isn't ready to come out and play.",
			SHORT = "Oh dear, oh dear, it's almost here!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "A pretty egg in mother's nest.",
			PICKED = "Her baby is gone. That's just wrong.",
		},
		TEENBIRD =
		{
			GENERIC = "It will turn traitor sometime later.",
			HUNGRY = "Would you like a snack from my backpack?",
			STARVING = "Awkward even in starvation.",
			SLEEPING = "They grow so fast, wouldn't you say?",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Let's hop!", --single player
			GENERIC = "Automatic hopper.", --single player
			LOCKED = "Why won't you work for this nice imp?", --single player
			PARTIAL = "It's almost done I'd say, I'd say!", --single player
		},
		TELEPORTATO_BOX = "It's a thing. For the thing!", --single player
		TELEPORTATO_CRANK = "It's a thing. For the thing!", --single player
		TELEPORTATO_POTATO = "It's a thing. For the thing!", --single player
		TELEPORTATO_RING = "It's a thing. For the thing!", --single player
		TELESTAFF = "Hassle-free hopping.",
		TENT =
		{
			GENERIC = "I could catch a wink, I think.",
			BURNT = "Burnt down, down to the ground.",
		},
		SIESTAHUT =
		{
			GENERIC = "I could catch a wink, I think.",
			BURNT = "Burnt down, down to the ground.",
		},
		TENTACLE = "Just try and catch me!",
		TENTACLESPIKE = "Ooo, looks dangerous!",
		TENTACLESPOTS = "Hoohoo, how naughty!",
		TENTACLE_PILLAR = "Slippery!",
        TENTACLE_PILLAR_HOLE = "Hyuyu.",
		TENTACLE_PILLAR_ARM = "It doesn't have anything to prove.",
		TENTACLE_GARDEN = "Also slippery!",
		TOPHAT = "A stylish imp I'm fit to be!",
		TORCH = "I won't go astray if this lights my way.",
		TRANSISTOR = "I do not know what this does.",
		TRAP = "I'm a very patient imp.",
		TRAP_TEETH = "I hope this isn't too cruel.",
		TRAP_TEETH_MAXWELL = "What a rude thing to leave lying around.", --single player
		TREASURECHEST =
		{
			GENERIC = "A storage place for bits and bobs.",
			BURNT = "Oh no, our treasure!",
		},
		TREASURECHEST_TRAP = "What have we here?",
		SACRED_CHEST =
		{
			GENERIC = "Ooohoohoo, it's probably cursed!",
			LOCKED = "Open up, already!",
		},
		TREECLUMP = "Hey! Don't bar the way!", --removed

		TRINKET_1 = "Somebody finally lost them.", --Melted Marbles
		TRINKET_2 = "What might I do with a fake kazoo?", --Fake Kazoo
		TRINKET_3 = "Tied like my tongue!", --Gord's Knot
		TRINKET_4 = "I see no soul within, no no.", --Gnome
		TRINKET_5 = "Nyooooom!", --Toy Rocketship
		TRINKET_6 = "Frizzle-frazzled like my mind!", --Frazzled Wires
		TRINKET_7 = "Oh, humans play such funny games!", --Ball and Cup
		TRINKET_8 = "I have no idea what it is, but it sure is funny!", --Rubber Bung
		TRINKET_9 = "No \"if\"s, \"and\"s or \"but\"-tons.", --Mismatched Buttons
		TRINKET_10 = "Humans are so funny.", --Dentures
		TRINKET_11 = "Do you have a riddle for me?", --Lying Robot
		TRINKET_12 = "I kind of like it, yes I do.", --Dessicated Tentacle
		TRINKET_13 = "I see no soul within, no no.", --Gnomette
		TRINKET_14 = "Tea's always spilling through the cracks!", --Leaky Teacup
		TRINKET_15 = "A little piece from off the board.", --Pawn
		TRINKET_16 = "A little piece from off the board.", --Pawn
		TRINKET_17 = "I haven't got the tine for that!", --Bent Spork
		TRINKET_18 = "Tiny little pranksters surely wait inside. Surprise!", --Trojan Horse
		TRINKET_19 = "I feel unbalanced too!", --Unbalanced Top
		TRINKET_20 = "Much less satisfying than big sharp claws!", --Backscratcher
		TRINKET_21 = "I have no idea what it does.", --Egg Beater
		TRINKET_22 = "Fried and frayed, just like my brain!", --Frayed Yarn
		TRINKET_23 = "Not to toot my own shoehorn, but I'm great at collecting soles!", --Shoehorn
		TRINKET_24 = "Perhaps a cat genie awaits inside?", --Lucky Cat Jar
		TRINKET_25 = "A lovely scent upon the breeze!", --Air Unfreshener
		TRINKET_26 = "I don't think I get this joke.", --Potato Cup
		TRINKET_27 = "I don't wear clothes.", --Coat Hanger
		TRINKET_28 = "A little piece from off the board.", --Rook
        TRINKET_29 = "A little piece from off the board.", --Rook
        TRINKET_30 = "A little piece from off the board.", --Knight
        TRINKET_31 = "A little piece from off the board.", --Knight
        TRINKET_32 = "If I look inside what will I see?", --Cubic Zirconia Ball
        TRINKET_33 = "No fun! It won't fit over my claw.", --Spider Ring
        TRINKET_34 = "I like my claws much better.", --Monkey Paw
        TRINKET_35 = "The drink's been drunk, so now it's junk!", --Empty Elixir
        TRINKET_36 = "Mine are much more impressive.", --Faux fangs
        TRINKET_37 = "Heehee, you couldn't kill me!", --Broken Stake
        TRINKET_38 = "The size of the world is a matter of perspective.", -- Binoculars Griftlands trinket
        TRINKET_39 = "I don't usually wear gloves.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Snips and snails and puppydog scales.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Without a doubt, the goop's spilled out.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Thank goodness this snake is just a fake.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Oh joy, oh boy! A wheely toy!", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "There's cracks in it for pests to get into.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Though you may think me quite a loon, I swear I hear a little tune.", -- Odd Radio ONI trinket
        TRINKET_46 = "We don't have these on my plane.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "You're not from around this plane, are you?",
        LOST_TOY_2  = "You're not from around this plane, are you?",
        LOST_TOY_7  = "You're not from around this plane, are you?",
        LOST_TOY_10 = "You're not from around this plane, are you?",
        LOST_TOY_11 = "You're not from around this plane, are you?",
        LOST_TOY_14 = "You're not from around this plane, are you?",
        LOST_TOY_18 = "You're not from around this plane, are you?",
        LOST_TOY_19 = "You're not from around this plane, are you?",
        LOST_TOY_42 = "You're not from around this plane, are you?",
        LOST_TOY_43 = "You're not from around this plane, are you?",

        HALLOWEENCANDY_1 = "Something to sink my fangs into!",
        HALLOWEENCANDY_2 = "I suppose I could eat a delightful treat.",
        HALLOWEENCANDY_3 = "It's just human corn.",
        HALLOWEENCANDY_4 = "I could be persuaded to try a taste.",
        HALLOWEENCANDY_5 = "Fweehee! Little kitties!",
        HALLOWEENCANDY_6 = "This prank is ingenious!",
        HALLOWEENCANDY_7 = "Hm... I don't think I'll like that.",
        HALLOWEENCANDY_8 = "Hyuyu, a candied soul!",
        HALLOWEENCANDY_9 = "Hyuyu, it slithers all the way down!",
        HALLOWEENCANDY_10 = "First time for everything, they say, they say.",
        HALLOWEENCANDY_11 = "Harumpf, it melts all over my claws.",
        HALLOWEENCANDY_12 = "How delightfully disgusting!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "I'll try a nibble, I will, I will.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Ooo hoo hoo, spicy!", --Hot Lava pepper candy
        CANDYBAG = "It's a Wortox Sack!",

		HALLOWEEN_ORNAMENT_1 = "It makes me hungry, yes indeed!",
		HALLOWEEN_ORNAMENT_2 = "Absolutely batty!",
		HALLOWEEN_ORNAMENT_3 = "A creepy crawler for the tree.",
		HALLOWEEN_ORNAMENT_4 = "A swirly whirly tentacle!",
		HALLOWEEN_ORNAMENT_5 = "Made to dangle from the tree.",
		HALLOWEEN_ORNAMENT_6 = "I do believe it is quite dead!",

		HALLOWEENPOTION_DRINKS_WEAK = "How tame and timid!",
		HALLOWEENPOTION_DRINKS_POTENT = "Hyuyu! This'll put tufts on your chest!",
        HALLOWEENPOTION_BRAVERY = "Tonic of anti-battiness!",
		HALLOWEENPOTION_MOON = "A brew of switcheroo!",
		HALLOWEENPOTION_FIRE_FX = "Firewater!",
		MADSCIENCE_LAB = "A place to stew my magic brew.",
		LIVINGTREE_ROOT = "Rooty toot toot!",
		LIVINGTREE_SAPLING = "Hyuyu, what a cutie!",

        DRAGONHEADHAT = "Me and my horns should be the head!",
        DRAGONBODYHAT = "Let's play imp in the middle!",
        DRAGONTAILHAT = "Put my tail at the tail end!",
        PERDSHRINE =
        {
            GENERIC = "Let us celebrate!",
            EMPTY = "Rumble and grumble, it wants a bush!",
            BURNT = "That's that.",
        },
        REDLANTERN = "What a pretty sight to see!",
        LUCKY_GOLDNUGGET = "Oh what luck I feel, I feel.",
        FIRECRACKERS = "Pop, pop!",
        PERDFAN = "A gust of luck from feathers plucked!",
        REDPOUCH = "The luck magic is practically radiating off it.",
        WARGSHRINE =
        {
            GENERIC = "Let us celebrate!",
            EMPTY = "Rumble and grumble, it wants to eat meat!",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "That's that.",
        },
        CLAYWARG =
        {
        	GENERIC = "Growl and bark, teeth like a shark!",
        	STATUE = "Petrified from toe to tip!",
        },
        CLAYHOUND =
        {
        	GENERIC = "Yip yap yelp, I need help!",
        	STATUE = "Petrified from toe to tip!",
        },
        HOUNDWHISTLE = "Ooo, ouch! My ears!",
        CHESSPIECE_CLAYHOUND = "A clay hound made from that sketch we found!",
        CHESSPIECE_CLAYWARG = "So scary, rendered still in stone.",

		PIGSHRINE =
		{
            GENERIC = "Let us celebrate!",
            EMPTY = "Rumble and grumble, it wants a torch!",
            BURNT = "That's that.",
		},
		PIG_TOKEN = "Let's start the game, oh please, oh please!",
		PIG_COIN = "A punchy pig for me? Yes please!",
		YOTP_FOOD1 = "I'll take a little tiny nibble.",
		YOTP_FOOD2 = "I'll try it, if you insist.",
		YOTP_FOOD3 = "Maybe just a little bite.",

		PIGELITE1 = "You won't beat me, no siree!", --BLUE
		PIGELITE2 = "You won't beat me, no siree!", --RED
		PIGELITE3 = "You won't beat me, no siree!", --WHITE
		PIGELITE4 = "You won't beat me, no siree!", --GREEN

		PIGELITEFIGHTER1 = "You won't beat me, no siree!", --BLUE
		PIGELITEFIGHTER2 = "You won't beat me, no siree!", --RED
		PIGELITEFIGHTER3 = "You won't beat me, no siree!", --WHITE
		PIGELITEFIGHTER4 = "You won't beat me, no siree!", --GREEN

		CARRAT_GHOSTRACER = "I had a feeling she liked to play games too, hyuyu!",

        YOTC_CARRAT_RACE_START = "Hyuyu, what fun!",
        YOTC_CARRAT_RACE_CHECKPOINT = "I make a point of checking checkpoints, hyuyu.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "Surely the cleverest will win.",
            BURNT = "How silly!",
            I_WON = "We won with wit and cunning (and a little bit of running).",
            SOMEONE_ELSE_WON = "{winner} put us to the test, and it turns out they're the best.",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Let the races begin!",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Mark the way!",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Where to put the finish line...",

		YOTC_SEEDPACKET = "A packet of seeds, to do with as I please.",
		YOTC_SEEDPACKET_RARE = "Perhaps it contains magic beans? Hyuyu!",

		MINIBOATLANTERN = "I'm sorry, but the souls I take cannot follow you.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "Hyuyu, I know a trickster when I see one!",
            EMPTY = "What is it you need? Perhaps carrots and seeds?",
            BURNT = "Well, that's that.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "North, South, East, West, your sense of direction we'll put to the test!",
            RAT = "Clever creature.",
            BURNT = "That prank went a bit too far.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Spin, spin, spin the wheel of fate!",
            RAT = "You're getting fast, indeed!",
            BURNT = "That prank went a bit too far.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "I just wanted to see how you'd react, hyuyu!",
            RAT = "Your reflexes are quite good, for a vegetable.",
            BURNT = "That prank went a bit too far.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "My, that looks strenuous.",
            RAT = "Such determination for one so small!",
            BURNT = "That prank went a bit too far.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "A bit of this, a bit of that, all to train my dear Carrat!",
        YOTC_CARRAT_GYM_SPEED_ITEM = "A bit of this, a bit of that, all to train my dear Carrat!",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "A bit of this, a bit of that, all to train my dear Carrat!",
        YOTC_CARRAT_GYM_REACTION_ITEM = "A bit of this, a bit of that, all to train my dear Carrat!",

        YOTC_CARRAT_SCALE_ITEM = "To win the race, I need a Carrat that can keep up the pace!",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "I hope I get a high score, hyuyu!",
            CARRAT = "I think we can do better than that.",
            CARRAT_GOOD = "A veritable virtuoso of a vegetable!",
            BURNT = "Hyuyu, what fun!",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Let us celebrate!",
            EMPTY = "This beefalo looks a little bare.",
            BURNT = "Oh my, was that supposed to happen?",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "I'll groom beefalo hair with my signature flair.",
            OCCUPIED = "Fancy some fancying up? Hyuyu!",
            BURNT = "Hyuyuyu how silly!",
        },
        BEEFALO_GROOMER_ITEM = "Let's prepare to style beefalo hair!",

		BISHOP_CHARGE_HIT = "Hyuyu! Owie!",
		TRUNKVEST_SUMMER = "It's my very best vest!",
		TRUNKVEST_WINTER = "A puffy, poofy vest, oh yes.",
		TRUNK_COOKED = "Goodness, no thank you.",
		TRUNK_SUMMER = "I'll pass, I say!",
		TRUNK_WINTER = "No, no, no, not my taste at all.",
		TUMBLEWEED = "Does it know where it wants to go?",
		TURKEYDINNER = "A very hearty mortal feast.",
		TWIGS = "Little twigs that bend and snap!",
		UMBRELLA = "No soggy imps on this fine day!",
		GRASS_UMBRELLA = "A tool to keep the rain away.",
		UNIMPLEMENTED = "What on earth is that?",
		WAFFLES = "The mortals like these a lot.",
		WALL_HAY =
		{
			GENERIC = "To keep you out, or keep me in?",
			BURNT = "A silly prank to be sure.",
		},
		WALL_HAY_ITEM = "It's of no use there on the ground.",
		WALL_STONE = "To keep you out, or keep me in?",
		WALL_STONE_ITEM = "It's of no use there on the ground.",
		WALL_RUINS = "To keep you out, or keep me in?",
		WALL_RUINS_ITEM = "It's of no use there on the ground.",
		WALL_WOOD =
		{
			GENERIC = "To keep you out, or keep me in?",
			BURNT = "A silly prank to be sure.",
		},
		WALL_WOOD_ITEM = "It's of no use there on the ground.",
		WALL_MOONROCK = "To keep you out, or keep me in?",
		WALL_MOONROCK_ITEM = "It's of no use there on the ground.",
		FENCE = "To keep you out, or keep me in?",
        FENCE_ITEM = "It's of no use there on the ground.",
        FENCE_GATE = "For temporary visiting.",
        FENCE_GATE_ITEM = "It's of no use there on the ground.",
		WALRUS = "His horns are on the wrong way.",
		WALRUSHAT = "Do I look good in plaid?",
		WALRUS_CAMP =
		{
			EMPTY = "The walruses aren't too keen. There's none here to be seen!",
			GENERIC = "They would not roam, too far from home.",
		},
		WALRUS_TUSK = "A sideways horn for a wizened face.",
		WARDROBE =
		{
			GENERIC = "A portal to the fashion dimension.",
            BURNING = "Someone's playing a funny prank.",
			BURNT = "The fashion dimension has been sealed off.",
		},
		WARG = "I'll not be a feast for that beast!",
        WARGLET = "You wouldn't want to eat me, imps give terrible indigestion!",
        
		WASPHIVE = "Do I want to start some mischief?",
		WATERBALLOON = "You'd never see me coming!",
		WATERMELON = "I do not want it.",
		WATERMELON_COOKED = "Goodness, gracious, no no no!",
		WATERMELONHAT = "Sticky horns await.",
		WAXWELLJOURNAL = "I don't think he knows how to use it.",
		WETGOOP = "Hyuyu! How repulsive.",
        WHIP = "Well this just seems cruel.",
		WINTERHAT = "It'll keep my horns warm.",
		WINTEROMETER =
		{
			GENERIC = "What do you say of the weather today?",
			BURNT = "I do suppose it's hot out today!",
		},

        WINTER_TREE =
        {
            BURNT = "This will make the mortals sad.",
            BURNING = "I don't think this is part of the festivities.",
            CANDECORATE = "So I just place the baubles right on it?",
            YOUNG = "Mortal tradition says it's much too small.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "A tree is meant to be inside.",
            BURNT = "This will make the mortals sad.",
		},
        WINTER_ORNAMENT = "Bibblity baublety boo.",
        WINTER_ORNAMENTLIGHT = "A light to shine bright in the night.",
        WINTER_ORNAMENTBOSS = "Memories of a fun time.",
		WINTER_ORNAMENTFORGE = "I remember when we played there!",
		WINTER_ORNAMENTGORGE = "Adornment from the land of goats!",

        WINTER_FOOD1 = "It looks like a little mortal! Hyuyu!", --gingerbread cookie
        WINTER_FOOD2 = "I might try one today.", --sugar cookie
        WINTER_FOOD3 = "The children hang them on my horns.", --candy cane
        WINTER_FOOD4 = "How deliciously evil!", --fruitcake
        WINTER_FOOD5 = "Mortal food shaped like a log! How silly.", --yule log cake
        WINTER_FOOD6 = "Hyuyu! The mortals liquefied these plums!", --plum pudding
        WINTER_FOOD7 = "I believe I can stomach liquids.", --apple cider
        WINTER_FOOD8 = "Maybe just a sip.", --hot cocoa
        WINTER_FOOD9 = "I might try this mortal treat.", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Oh ho! What magic conjured you up?",
			COOKING = "Just what are you cooking up?",
			ALMOST_DONE_COOKING = "It's nearly time.",
			DISH_READY = "Culinary alchemy!",
		},
		BERRYSAUCE = "Hyuyuyu, what a fun trick!",
		BIBINGKA = "I would've made a great Ani-ani.",
		CABBAGEROLLS = "They look so real!",
		FESTIVEFISH = "Nothing fishy here at all, hyuyu!",
		GRAVY = "It sits in a boat that doesn't float.",
		LATKES = "I wonder what would happen if I took a bite.",
		LUTEFISK = "It smells real enough.",
		MULLEDDRINK = "Perhaps I'll mull it over, hyuyu!",
		PANETTONE = "This holiday bread is all in your head!",
		PAVLOVA = "I'm afraid you can't fool me.",
		PICKLEDHERRING = "Shall I pick a peck of pickled herring?",
		POLISHCOOKIE = "You can't prank a prankster, hyuyu!",
		PUMPKINPIE = "Don't be shy, try the pie!",
		ROASTTURKEY = "It certainly looks like a turkey.",
		STUFFING = "Why fill yourself with dread when you could fill yourself with bread?",
		SWEETPOTATO = "Should I tell them it's a prank? Hyuyu!",
		TAMALES = "Very convincing.",
		TOURTIERE = "A pie, not sweet, but filled with meat.",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "A special place to stuff your face!",
			HAS_FOOD = "The stage is set!",
			WRONG_TYPE = "Best not to break the illusion.",
			BURNT = "Double the pranks!",
		},

		GINGERBREADWARG = "That cookie wants to sink its teeth into me!",
		GINGERBREADHOUSE = "What a charming cookie cottage.",
		GINGERBREADPIG = "Here little piggy!",
		CRUMBS = "That's the way the cookie crumbles, hyuyu!",
		WINTERSFEASTFUEL = "Ah, are you the source of this magic?",

        KLAUS = "Are we not brethren?",
        KLAUS_SACK = "What tasty treats lie within?",
		KLAUSSACKKEY = "Now where oh where did he leave that stash.",
		WORMHOLE =
		{
			GENERIC = "That looks like it could be my ride!",
			OPEN = "Watch my impression of mortal food.",
		},
		WORMHOLE_LIMITED = "I think its throat is getting sore.",
		ACCOMPLISHMENT_SHRINE = "I did indeed do that!", --single player
		LIVINGTREE = "A tree as perplexing as it is vexing.",
		ICESTAFF = "I'll freeze who I please.",
		REVIVER = "So my friends might live to tell the tale!",
		SHADOWHEART = "Oh, how neat! It continues to beat.",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "A bunch of mortals. They look very bored.",
			LINE_2 = "There's some magic residue on the stone. Not much else.",
			LINE_3 = "Ooo, it's about to get good!",
			LINE_4 = "What a hoot! The mortals are slithering out their skins!",
			LINE_5 = "They probably shouldn't have used that much magic.",
		},
        ATRIUM_STATUE = "Hyuyu, did you lose a game?",
        ATRIUM_LIGHT =
        {
			ON = "Ooo, it turned on!",
			OFF = "I'm not sure how to play with this.",
		},
        ATRIUM_GATE =
        {
			ON = "That's how you get imps. Hyuyu!",
			OFF = "The thing I hopped through!",
			CHARGING = "Oh, we're going to have some fun!",
			DESTABILIZING = "Hyuyu, it's getting weird!",
			COOLDOWN = "Playtime's over.",
        },
        ATRIUM_KEY = "An imp could do mischievous things with this.",
		LIFEINJECTOR = "On further reflection, I don't want an injection.",
		SKELETON_PLAYER =
		{
			MALE = "%s's soul is long gone thanks to %s.",
			FEMALE = "%s's soul is long gone thanks to %s.",
			ROBOT = "%s's soul is long gone thanks to %s.",
			DEFAULT = "%s's soul is long gone thanks to %s.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "The sky has fallen.",
		MOONROCKNUGGET = "It was hewn from solid moon.",
		MOONROCKCRATER = "It might be an eye, were gems in supply.",
		MOONROCKSEED = "I bet you know some fun secrets.",

        REDMOONEYE = "Red, so red. Like the fur I shed.",
        PURPLEMOONEYE = "Jeepers peepers!",
        GREENMOONEYE = "This eye of green wishes to be seen!",
        ORANGEMOONEYE = "My oh my, what a lovely eye.",
        YELLOWMOONEYE = "To make our mark once we embark.",
        BLUEMOONEYE = "It's visible from any nook or crook.",

        --Arena Event
        LAVAARENA_BOARLORD = "I have no real quest, I'm just here to jest!",
        BOARRIOR = "Catch me if you can!",
        BOARON = "Who invited a pig to this shindig?",
        PEGHOOK = "This will be a cinch if I don't get pinched!",
        TRAILS = "You wouldn't pummel a tiny imp, would you?!",
        TURTILLUS = "We can't fight well when it's in its shell.",
        SNAPPER = "I'll have a fit if I touch that spit!",
		RHINODRILL = "Is that double I do see?",
		BEETLETAUR = "My oh my, you're a big guy!",

        LAVAARENA_PORTAL =
        {
            ON = "Hop, skip and a jump! Hyuyu!",
            GENERIC = "A fire-powered hopper.",
        },
        LAVAARENA_KEYHOLE = "It's a one-piece puzzle.",
		LAVAARENA_KEYHOLE_FULL = "And away I go!",
        LAVAARENA_BATTLESTANDARD = "Break that stake!",
        LAVAARENA_SPAWNER = "Short range hoppery!",

        HEALINGSTAFF = "A little heal will improve how you feel.",
        FIREBALLSTAFF = "Ooohoo, how delightfully chaotic!",
        HAMMER_MJOLNIR = "Clamor for the hammer!",
        SPEAR_GUNGNIR = "Live in fear of the spear!",
        BLOWDART_LAVA = "A gust of breath means flaming death!",
        BLOWDART_LAVA2 = "A gust of breath means flaming death!",
        LAVAARENA_LUCY = "Axe to the max!",
        WEBBER_SPIDER_MINION = "The itsy-iest bitsy-iest spiders!!",
        BOOK_FOSSIL = "Rock their socks off.",
		LAVAARENA_BERNIE = "How do you do, fine sir?",
		SPEAR_LANCE = "Live in fear of the spear!",
		BOOK_ELEMENTAL = "Well, it won't summon an imp!",
		LAVAARENA_ELEMENTAL = "Hyuyu, what are you!",

   		LAVAARENA_ARMORLIGHT = "So light and breezy!",
		LAVAARENA_ARMORLIGHTSPEED = "Skittery imp!",
		LAVAARENA_ARMORMEDIUM = "Knock on wood for protection!",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Covered in claws!",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Better! Faster!",
		LAVAARENA_ARMORHEAVY = "Hyuyu, that looks heavy!",
		LAVAARENA_ARMOREXTRAHEAVY = "I can barely move my little imp legs in it!",

		LAVAARENA_FEATHERCROWNHAT = "It tickles my horns!",
        LAVAARENA_HEALINGFLOWERHAT = "I don't want to die, hyuyu!",
        LAVAARENA_LIGHTDAMAGERHAT = "Gives me a bit of extra bite!",
        LAVAARENA_STRONGDAMAGERHAT = "Gives me a lot of extra bite!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "This imp is here to help!",
        LAVAARENA_EYECIRCLETHAT = "Ooo, I feel so fancy!",
        LAVAARENA_RECHARGERHAT = "More power, faster!",
        LAVAARENA_HEALINGGARLANDHAT = "A bloom to do a bit of good!",
        LAVAARENA_CROWNDAMAGERHAT = "Hyuyu, oh the magic!",

		LAVAARENA_ARMOR_HP = "Fortified imp!",

		LAVAARENA_FIREBOMB = "Boom! Kabloom! Doom!!",
		LAVAARENA_HEAVYBLADE = "A giant sword to cut down this horde!",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "A place to place a plate!",
        	FULL = "It's full as full can be!",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "A monumental statue! Hyuyu!",
		QUAGMIRE_PARK_FOUNTAIN = "How disappointing, it's all dried up.",

        QUAGMIRE_HOE = "To turn the soil, row by row.",

        QUAGMIRE_TURNIP = "That's a tiny turnip.",
        QUAGMIRE_TURNIP_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_TURNIP_SEEDS = "Strange little seeds, indeed, indeed.",

        QUAGMIRE_GARLIC = "Hissss!",
        QUAGMIRE_GARLIC_COOKED = "Hissssss!",
        QUAGMIRE_GARLIC_SEEDS = "Strange little seeds, indeed, indeed.",

        QUAGMIRE_ONION = "You'll see no tears from my eye. I cannot cry!",
        QUAGMIRE_ONION_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_ONION_SEEDS = "Strange little seeds, indeed, indeed.",

        QUAGMIRE_POTATO = "Mortals like this in all its forms. Will a wyrm?",
        QUAGMIRE_POTATO_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_POTATO_SEEDS = "Strange little seeds, indeed, indeed.",

        QUAGMIRE_TOMATO = "I could throw it at the wyrm!",
        QUAGMIRE_TOMATO_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_TOMATO_SEEDS = "Strange little seeds, indeed, indeed.",

        QUAGMIRE_FLOUR = "Mortal food powder!",
        QUAGMIRE_WHEAT = "The mortals grind it up with big rocks.",
        QUAGMIRE_WHEAT_SEEDS = "Strange little seeds, indeed, indeed.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Strange little seeds, indeed, indeed.",

        QUAGMIRE_ROTTEN_CROP = "Yuck, muck.",

		QUAGMIRE_SALMON = "It doesn't like the air, oh no.",
		QUAGMIRE_SALMON_COOKED = "So long, sweet fish soul.",
		QUAGMIRE_CRABMEAT = "The humans like it, they do, they do!",
		QUAGMIRE_CRABMEAT_COOKED = "They like it more like this, I hear!",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "Fweehee, what a special tree!",
			STUMP = "That's a wrap on the sap.",
			TAPPED_EMPTY = "The tap will soon make sap!",
			TAPPED_READY = "Sweet, sugary sap!",
			TAPPED_BUGS = "Those bugs are tree thugs!",
			WOUNDED = "An unfortunate mishap befell the tree sap.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "I bet the mortals would like some of that.",
			PICKED = "Gone, all gone.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Spice! ...How nice!",
		QUAGMIRE_SPOTSPICE_GROUND = "Mortals say grinding it brings out the flavor.",
		QUAGMIRE_SAPBUCKET = "It's for filling up with sap.",
		QUAGMIRE_SAP = "Sticky, icky sap!",
		QUAGMIRE_SALT_RACK =
		{
			READY = "The minerals are ready.",
			GENERIC = "The mortals crave these minerals.",
		},

		QUAGMIRE_POND_SALT = "It's very salty water.",
		QUAGMIRE_SALT_RACK_ITEM = "It's meant to go above a pond.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "None can impede this imp!",
			LOCKED = "Oh whiskers. It's locked tight.",
		},

		QUAGMIRE_KEY = "I wish to pry into hidden supplies.",
		QUAGMIRE_KEY_PARK = "No gate can stop a sneaky imp!",
        QUAGMIRE_PORTAL_KEY = "Hyuyu! Let us hop away!",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "A mushroom metropolis!",
			PICKED = "It's been picked clean.",
		},
		QUAGMIRE_MUSHROOMS = "There's morel where that came from, hyuyu!",
        QUAGMIRE_MEALINGSTONE = "I do enjoy this mortal chore.",
		QUAGMIRE_PEBBLECRAB = "What a funny creature!",


		QUAGMIRE_RUBBLE_CARRIAGE = "Which squeaky wheel will get the grease?",
        QUAGMIRE_RUBBLE_CLOCK = "Hickory dickory dock, hyuyu!",
        QUAGMIRE_RUBBLE_CATHEDRAL = "It all comes tumbling down.",
        QUAGMIRE_RUBBLE_PUBDOOR = "A door to nowhere, hyuyu!",
        QUAGMIRE_RUBBLE_ROOF = "It all comes tumbling down.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "The hands have stopped. Time is difficult to grasp.",
        QUAGMIRE_RUBBLE_BIKE = "Cycles spinning round and round. Bicycles double the spinning!",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Rubble, ruin!",
            "No souls to see.",
            "Huff and puff, and blow your house down!",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "It all comes tumbling down.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Tumbley, rumbley, falling right down.",
        QUAGMIRE_MERMHOUSE = "Looks a bit run-down.",
        QUAGMIRE_SWAMPIG_HOUSE = "A house that's cobbled from bits and bobs.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Nothing but bits and bobs left.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "My oh my, you look ill! Low of spirit, green 'round the gill.",
            SLEEPING = "Sleeping like the fishes. Hyuyu!",
        },
        QUAGMIRE_SWAMPIG = "Do you feel it loom? Your impending doom?",

        QUAGMIRE_PORTAL = "A way out or in, depending who you are.",
        QUAGMIRE_SALTROCK = "Humans use it as a \"spice\".",
        QUAGMIRE_SALT = "Mortals tongues seem to like it.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Oospadoodle.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Let's roll the dice with this sacrifice!",
            MISMATCH = "This meal looks wrong, but we don't have long.",
            MATCH = "This meal is splendid, just as intended!",
            MATCH_BUT_SNACK = "Better to serve something small than nothing at all.",
        },

        QUAGMIRE_FERN = "I wonder what it tastes like.",
        QUAGMIRE_FOLIAGE_COOKED = "Humans have odd palates.",
        QUAGMIRE_COIN1 = "Pithy pennies.",
        QUAGMIRE_COIN2 = "The Gnaw expelled it from its craw.",
        QUAGMIRE_COIN3 = "The Gnaw has spoken. We've earned its token.",
        QUAGMIRE_COIN4 = "It's a big hop token.",
        QUAGMIRE_GOATMILK = "Hyuyu! Fresh from the source.",
        QUAGMIRE_SYRUP = "For making sweet treats.",
        QUAGMIRE_SAP_SPOILED = "Whoops-a-doodle!",
        QUAGMIRE_SEEDPACKET = "Plant them in a plot of land.",

        QUAGMIRE_POT = "Mortals don't like it when you burn the things inside.",
        QUAGMIRE_POT_SMALL = "A little vessel for mortal food.",
        QUAGMIRE_POT_SYRUP = "Mortals don't like raw tree insides.",
        QUAGMIRE_POT_HANGER = "You can hang a pot on it.",
        QUAGMIRE_POT_HANGER_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_GRILL = "Mortals have lots of different cooking things.",
        QUAGMIRE_GRILL_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_GRILL_SMALL = "Mortals cook stuff on it.",
        QUAGMIRE_GRILL_SMALL_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_OVEN = "It's a thing mortals cook with.",
        QUAGMIRE_OVEN_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_CASSEROLEDISH = "I wonder how the wyrm got a taste for mortal food.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "This dish is so itty bitty!",
        QUAGMIRE_PLATE_SILVER = "Are there any souls on the menu?",
        QUAGMIRE_BOWL_SILVER = "The mortals like it when food looks nice.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Anything fun inside?", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Mind if I take a little peek?", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "I could draw a little moustache on it when no one's looking.",
        QUAGMIRE_PARK_ANGEL2 = "This one's already got a beard.",
        QUAGMIRE_PARK_URN = "There's probably nothing fun inside.",
        QUAGMIRE_PARK_OBELISK = "Nothing fun to find here.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "This way to the park!",
            LOCKED = "Let me out! Hyuyu, just kidding.",
        },
        QUAGMIRE_PARKSPIKE = "A wall, a wall, so very tall.",
        QUAGMIRE_CRABTRAP = "They'll feel so silly once I catch them!",
        QUAGMIRE_TRADER_MERM = "What a funny face you have!",
        QUAGMIRE_TRADER_MERM2 = "Hyuyu, what a funny moustache!",

        QUAGMIRE_GOATMUM = "I'd ask hircine, but I think it's Capricorn.",
        QUAGMIRE_GOATKID = "And who might you be?",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Oh goodness, oh gracious.",
            GENERIC = "I've heard they make good pie.",
            SLEEPING = "Sleep and dream, little wing.",
        },
        QUAGMIRE_LAMP_POST = "If it were raining I could sing!",

        QUAGMIRE_BEEFALO = "I'll take the beef, you keep the \"lo\"!",
        QUAGMIRE_SLAUGHTERTOOL = "I don't like this sort of prank.",

        QUAGMIRE_SAPLING = "Tiny little baby tree.",
        QUAGMIRE_BERRYBUSH = "Mortals like berries, I think.",

        QUAGMIRE_ALTAR_STATUE2 = "No relation.",
        QUAGMIRE_ALTAR_QUEEN = "My vessel is not her vassal.",
        QUAGMIRE_ALTAR_BOLLARD = "Nothing of interest to me, I see.",
        QUAGMIRE_ALTAR_IVY = "Creeping ivy, growing strong.",

        QUAGMIRE_LAMP_SHORT = "If it were raining I could sing!",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "It's sure to entertain our guests!",
        	OFF = "Doesn't look too lively!",
        	BURNING = "Hoohoohoo!",
        	BURNT = "How hilarious!",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "What a funny thing!",
        	OFF = "Doesn't look too lively!",
        	BURNING = "Hoohoohoo!",
        	BURNT = "How hilarious!",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "Hyuyu. Mortals don't know magic.",
        	LOWPOWER = "Winding down, waning.",
        	OFF = "Playtime's over!",
        	BURNING = "Hoohoohoo!",
        	BURNT = "How hilarious!",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "Ooohoohoo! The mortal learned magic!",
        	LOWPOWER = "Winding down, waning.",
        	OFF = "Playtime's over!",
        	BURNING = "Hoohoohoo!",
        	BURNT = "How hilarious!",
        },

        --Wormwood
        COMPOSTWRAP = "It's poop. So the plants won't droop.",
        ARMOR_BRAMBLE = "Who'd like to give an imp a hug? Hyuyu!",
        TRAP_BRAMBLE = "Spiky, pointy, green and thorny!",

        BOATFRAGMENT03 = "Flotsam and jetsam, bits and bobs.",
        BOATFRAGMENT04 = "Flotsam and jetsam, bits and bobs.",
        BOATFRAGMENT05 = "Flotsam and jetsam, bits and bobs.",
		BOAT_LEAK = "Things look bleak - we have a leak!",
        MAST = "A sail on the mast will move our boat fast.",
        SEASTACK = "It would be quite a shock to hit that rock.",
        FISHINGNET = "A riddle! What might one cast that's not a spell?", --unimplemented
        ANTCHOVIES = "Squirmy, wormy, fishy food.", --unimplemented
        STEERINGWHEEL = "A big wheel to guide a keel.",
        ANCHOR = "Drop it to stop it.",
        BOATPATCH = "Plugging a hole sounds quite droll.",
        DRIFTWOOD_TREE =
        {
            BURNING = "Burning, burning, burning down.",
            BURNT = "So much tinder, burnt to cinder.",
            CHOPPED = "It is no more.",
            GENERIC = "An old, dead tree, beached and bleached.",
        },

        DRIFTWOOD_LOG = "Naught but a log.",

        MOON_TREE =
        {
            BURNING = "Burning, burning, burning down.",
            BURNT = "So much tinder, burnt to cinder.",
            CHOPPED = "It is no more.",
            GENERIC = "Glimmering tree of lunar light.",
        },
		MOON_TREE_BLOSSOM = "Look how it gleams in the moonlight!",

        MOONBUTTERFLY =
        {
        	GENERIC = "A glimmering moth on wings alight.",
        	HELD = "Watch my claws now, dearest friend.",
        },
		MOONBUTTERFLYWINGS = "Gossamer wings of pale, pale green.",
        MOONBUTTERFLY_SAPLING = "Grow now, safe and sound.",
        ROCK_AVOCADO_FRUIT = "I don't mean to balk, but that looks like a rock.",
        ROCK_AVOCADO_FRUIT_RIPE = "My mortal friends would find it tasty now.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "A meal fit for a mortal.",
        ROCK_AVOCADO_FRUIT_SPROUT = "How it grows, nobody knows.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It won't be returning to this plane.",
			WITHERED = "Feeling down, are you?",
			GENERIC = "It's chock a block with little rocks!",
			PICKED = "Gone, all gone.",
			DISEASED = "Now it stinks really good!", --unimplemented
            DISEASING = "It's started to stink.", --unimplemented
			BURNING = "Burning, burning, burning down.",
		},
        DEAD_SEA_BONES = "Bones from the sea, these look to be!",
        HOTSPRING =
        {
        	GENERIC = "I don't want to get my fur wet.",
        	BOMBED = "Mortals love good smells.",
        	GLASS = "All that glass sure froze fast!",
			EMPTY = "Oh me, oh my, the spring's run dry.",
        },
        MOONGLASS = "In its green sheen I see selene.",
        MOONGLASS_CHARGED = "I should make haste before they go to waste.",
        MOONGLASS_ROCK = "A handsome devil is reflected back at me! Hyuyu!",
        BATHBOMB = "Sweetly stinking, bombs for bathing.",
        TRAP_STARFISH =
        {
            GENERIC = "Careful where you tread, lest you end up dead!",
            CLOSED = "Jaws that snap! It was a trap.",
        },
        DUG_TRAP_STARFISH = "Planting this would be a devilish trick.",
        SPIDER_MOON =
        {
        	GENERIC = "Sharpest spider, soon to strike.",
        	SLEEPING = "Get some rest, little pest.",
        	DEAD = "Dead as dead as dead could be!",
        },
        MOONSPIDERDEN = "I should not like to see inside!",
		FRUITDRAGON =
		{
			GENERIC = "Little lizard, sharp and pointy!",
			RIPE = "That color looks great on you, hyuyu!",
			SLEEPING = "Hyuyu, catching some shuteye are we?",
		},
        PUFFIN =
        {
            GENERIC = "I'll tell you nothin', puffin.",
            HELD = "Stay calm, little soul.",
            SLEEPING = "Hyuyu, catching some shuteye are we?",
        },

		MOONGLASSAXE = "Swing and a chop, all the trees drop!",
		GLASSCUTTER = "Oh, I'm sure I'll have fun with this. Hyuyu!",

        ICEBERG =
        {
            GENERIC = "Glistening ice, it looks quite nice.", --unimplemented
            MELTED = "Teeny tiny, drippy droppy iceberg.", --unimplemented
        },
        ICEBERG_MELTED = "Teeny tiny, drippy droppy iceberg.", --unimplemented

        MINIFLARE = "Mortals get lost sometimes, hyuyu.",

		MOON_FISSURE =
		{
			GENERIC = "This magic makes my brain so soft and floaty!",
			NOLIGHT = "A deep, dark hole that knows no end!",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Hyuyu, you'll owe me one after this!",
            GENERIC = "Hyuyu, moon secrets are so fun!",
        },

        MOON_ALTAR_IDOL = "You've really fallen apart, huh?",
        MOON_ALTAR_GLASS = "Let's see if we can put you back together again.",
        MOON_ALTAR_SEED = "What a funny voice you have. How it rattles around in my head!",

        MOON_ALTAR_ROCK_IDOL = "There's a surprise inside!",
        MOON_ALTAR_ROCK_GLASS = "There's a surprise inside!",
        MOON_ALTAR_ROCK_SEED = "There's a surprise inside!",

        MOON_ALTAR_CROWN = "Well, you've had quite the adventure, hyuyu!",
        MOON_ALTAR_COSMIC = "The stage is nearly set!",

        MOON_ALTAR_ASTRAL = "All together again. You must be over the moon, hyuyu!",
        MOON_ALTAR_ICON = "You hid away with quite some skill, you're lucky that I had a drill!",
        MOON_ALTAR_WARD = "Lost, found, now homeward bound!",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "For a mind as vast as the sea is deep!",
            BURNT = "The fire caused it to expire!",
        },
        BOAT_ITEM = "Let's craft a raft!",
        STEERINGWHEEL_ITEM = "I can see the appeal of a steering wheel.",
        ANCHOR_ITEM = "Such funny ship things I could build.",
        MAST_ITEM = "A mast to sail the ocean vast.",
        MUTATEDHOUND =
        {
        	DEAD = "I'm surprised it had a soul!",
        	GENERIC = "What if I'm actually inside out, and it's rightside in?",
        	SLEEPING = "Its mind has fled far from here, hyuyu.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Dead as dead as dead could be!",
			GENERIC = "Hyuyu! What a horrible face you have!",
			SLEEPING = "Its mind has fled far from here, hyuyu.",
		},
        CARRAT =
        {
        	DEAD = "Ding-dong, the carrot's dead.",
        	GENERIC = "Does it have a soul, one wonders?",
        	HELD = "Hello hello, strange orange soul.",
        	SLEEPING = "Good night, sleep tight, don't let the humans bite.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "And so it grows from out the sea.",
            PICKED = "The mortals picked it with such glee.",
        },
		BULLKELP_ROOT = "We plucked this whip from the side of the ship.",
        KELPHAT = "To rest uncomfortably upon my horns.",
		KELP = "Kelp would be of no help.",
		KELP_COOKED = "Mortals have such funny tastes.",
		KELP_DRIED = "I do not want it, no siree.",

		GESTALT = "Good evening, children!",
        GESTALT_GUARD = "They grow up so fast!",

		COOKIECUTTER = "Well, aren't you a funny fellow!",
		COOKIECUTTERSHELL = "The creature fell, now I take its shell!",
		COOKIECUTTERHAT = "With this spiny gear, I've nothing to fear!",
		SALTSTACK =
		{
			GENERIC = "Interesting.",
			MINED_OUT = "Heehee, hoho, it had to go.",
			GROWING = "Oh joyous day. More salt.",
		},
		SALTROCK = "Hissss!",
		SALTBOX = "You needn't worry about protecting your food from me.",

		TACKLESTATION = "Let's build a better fish trap, hyuyu!",
		TACKLESKETCH = "Some cunning plans to put fish in our hands!",

        MALBATROSS = "It's bad luck to shoot it down, but what do I know? Hyuyu!",
        MALBATROSS_FEATHER = "A feather for me, from the bird of the sea.",
        MALBATROSS_BEAK = "It squawks no more.",
        MAST_MALBATROSS_ITEM = "Ah at last, a fancy new mast!",
        MAST_MALBATROSS = "It fought to no avail, and became our sail!",
		MALBATROSS_FEATHERED_WEAVE = "This fabric tickles, hyuyu.",

        GNARWAIL =
        {
            GENERIC = "Now now, no need to put a dent in my dinghy.",
            BROKENHORN = "I don't see your point, hyuyu!",
            FOLLOWER = "Come along, there's a sea full of mischief to be had!",
            BROKENHORN_FOLLOWER = "I'm afraid I don't have any spare horns.",
        },
        GNARWAIL_HORN = "It makes a compelling point, hyuyu!",

        WALKINGPLANK = "It's just a last resort, worrywart!",
        OAR = "I'll splash all my friends with this!",
		OAR_DRIFTWOOD = "It's an oar, for shore!",

		OCEANFISHINGROD = "I'd rather catch a soul than a sole.",
		OCEANFISHINGBOBBER_NONE = "A piece of this fishing puzzle is missing.",
        OCEANFISHINGBOBBER_BALL = "I'm just having a ball! Hyuyu!",
        OCEANFISHINGBOBBER_OVAL = "This doesn't look so hard!",
		OCEANFISHINGBOBBER_CROW = "Never underestimate the power of a strong quill.",
		OCEANFISHINGBOBBER_ROBIN = "Never underestimate the power of a strong quill.",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "Never underestimate the power of a strong quill.",
		OCEANFISHINGBOBBER_CANARY = "Never underestimate the power of a strong quill.",
		OCEANFISHINGBOBBER_GOOSE = "A fearsome feathery float!",
		OCEANFISHINGBOBBER_MALBATROSS = "A fearsome feathery float!",

		OCEANFISHINGLURE_SPINNER_RED = "What a fun prank for the fish!",
		OCEANFISHINGLURE_SPINNER_GREEN = "What a fun prank for the fish!",
		OCEANFISHINGLURE_SPINNER_BLUE = "What a fun prank for the fish!",
		OCEANFISHINGLURE_SPOON_RED = "What a fun prank for the fish!",
		OCEANFISHINGLURE_SPOON_GREEN = "What a fun prank for the fish!",
		OCEANFISHINGLURE_SPOON_BLUE = "What a fun prank for the fish!",
		OCEANFISHINGLURE_HERMIT_RAIN = "Rain or shine, the fish will be mine!",
		OCEANFISHINGLURE_HERMIT_SNOW = "How fun to go and fish in the snow!",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Oh, the pranks I could pull with this!",
		OCEANFISHINGLURE_HERMIT_HEAVY = "An enticing bait for a fish of great weight!",

		OCEANFISH_SMALL_1 = "Splash, splish, it's a tiny fish!",
		OCEANFISH_SMALL_2 = "This soul is so small it's hardly worth snatching.",
		OCEANFISH_SMALL_3 = "You took the bait, now suffer your fate!",
		OCEANFISH_SMALL_4 = "It's hardly bigger than a minnow!",
		OCEANFISH_SMALL_5 = "This one really pops, hyuyu!",
		OCEANFISH_SMALL_6 = "I'm afraid it's time for you to leaf, hyuyu!",
		OCEANFISH_SMALL_7 = "What might happen if I planted it in the garden?",
		OCEANFISH_SMALL_8 = "It has such a sunny disposition! Hyuyu!",
        OCEANFISH_SMALL_9 = "A fellow prankster, I see!",

		OCEANFISH_MEDIUM_1 = "Your name is mud, fish!",
		OCEANFISH_MEDIUM_2 = "If I hold it up, it becomes an upright bass!",
		OCEANFISH_MEDIUM_3 = "How dandy indeed! You've a soul that I need.",
		OCEANFISH_MEDIUM_4 = "Oooh, how delightfully superstitious!",
		OCEANFISH_MEDIUM_5 = "It looks like nature played quite the prank on this one.",
		OCEANFISH_MEDIUM_6 = "I'm afraid your journey has been cut short.",
		OCEANFISH_MEDIUM_7 = "I'm afraid your journey has been cut short.",
		OCEANFISH_MEDIUM_8 = "What a chilly reception!",
        OCEANFISH_MEDIUM_9 = "Purple, but not a people eater.",

		PONDFISH = "You are quite fragrant.",
		PONDEEL = "A slippery soul, that one.",

        FISHMEAT = "Looks like the soul's already left this one.",
        FISHMEAT_COOKED = "I do not wish to eat this fish.",
        FISHMEAT_SMALL = "Looks like the soul's already left this one.",
        FISHMEAT_SMALL_COOKED = "I do not wish to eat this fish.",
		SPOILED_FISH = "It's spoiled rotten!",

		FISH_BOX = "Fill it to the brim with bream!",
        POCKET_SCALE = "Allow me to quickly weigh in, hyuyu!",

		TACKLECONTAINER = "Hoohoo! What mysteries of fisheries does it hold?",
		SUPERTACKLECONTAINER = "That's quite a lot to tackle, hyuyu!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "For a fish it must be quite ideal, to be a prize and not a meal!",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nJust look at the size of this fishy prize!",
			BURNING = "Double, double toil and trouble, fire burn and fishbowl bubble!",
			BURNT = "How fun!",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nMy fish is best, as this scale can attest!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nYour impressive weight saved you from landing on a plate!",
		},

		OCEANFISHABLEFLOTSAM = "I will shape it into a delicious mud pie! Hyuyu.",

		CALIFORNIAROLL = "We're on a roll! Hyuyu!",
		SEAFOODGUMBO = "Gleefully gilly gumbo!",
		SURFNTURF = "My my, what an odd pair!",

        WOBSTER_SHELLER = "Hyuyu, it's a creature I shelldom care to sea!",
        WOBSTER_DEN = "Even crustaceans need a place to sleep now and den.",
        WOBSTER_SHELLER_DEAD = "It is quite thoroughly dead.",
        WOBSTER_SHELLER_DEAD_COOKED = "Oh dear, the best part's already gone.",

        LOBSTERBISQUE = "Mortals seem to enjoy turning anything into a soup.",
        LOBSTERDINNER = "I'm afraid I don't seafood the way most do.",

        WOBSTER_MOONGLASS = "That will be a hard shell to crack, hyuyu!",
        MOONGLASS_WOBSTER_DEN = "A home made of glass? I think I'll pass.",

		TRIDENT = "Holding a pitchfork feels disturbingly natural.",

		WINCH =
		{
			GENERIC = "Hoohoo! The mortals invented a snatching machine!",
			RETRIEVING_ITEM = "Hyuyu! My treasure will soon be revealed!",
			HOLDING_ITEM = "I always enjoy the game more than the prize, hyuyu!",
		},

        HERMITHOUSE = {
            GENERIC = "What a sad little house for that cranky old louse.",
            BUILTUP = "A little care can cause remarkable transformations.",
        },

        SHELL_CLUSTER = "I wonder if there's any goodies inside?",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "A barnacled baritone!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Sweet singing seashells!",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Such a high pitch, it makes my ears itch...",
        },

        CHUM = "Shall we try to get chummy with the fish? Hyuyu!",

        SUNKENCHEST =
        {
            GENERIC = "I fear it's only a shell of its former self.",
            LOCKED = "We need a key for this gift from the sea!",
        },

        HERMIT_BUNDLE = "A bundle of goodies for our good deeds!",
        HERMIT_BUNDLE_SHELLS = "Oh swell, a bundle of shells.",

        RESKIN_TOOL = "Oooh, the pranks I could pull with this!",
        MOON_FISSURE_PLUGGED = "Hyuyu! Can you not get out, little ones?",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Hyuyu! I must say, she's growing on me!",
            "Hyuyu! I must say, she's growing on me!",
        },
        WOBYSMALL =
        {
            "Hello, my small furry friend!",
            "Hello, my small furry friend!",
        },
		WALTERHAT = "Imps and uniforms rarely mix.",
		SLINGSHOT = "Now this could cause some mischief!",
		SLINGSHOTAMMO_ROCK = "Oooh, how fun!",
		SLINGSHOTAMMO_MARBLE = "Oooh, how fun!",
		SLINGSHOTAMMO_THULECITE = "Oooh, how fun!",
        SLINGSHOTAMMO_GOLD = "Oooh, how fun!",
        SLINGSHOTAMMO_SLOW = "Oooh, how fun!",
        SLINGSHOTAMMO_FREEZE = "Oooh, how fun!",
		SLINGSHOTAMMO_POOP = "Oooh, how fun!",
        PORTABLETENT = "So many pranks to pull! Do I push it in the lake? Toss in a snake?",
        PORTABLETENT_ITEM = "Round and round, tent goes up and then comes down!",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Singing is good for the soul.",
        BATTLESONG_HEALTHGAIN = "Singing is good for the soul.",
        BATTLESONG_SANITYGAIN = "Singing is good for the soul.",
        BATTLESONG_SANITYAURA = "Singing is good for the soul.",
        BATTLESONG_FIRERESISTANCE = "Singing is good for the soul.",
        BATTLESONG_INSTANT_TAUNT = "Oooh, yay! Are we putting on a play?",
        BATTLESONG_INSTANT_PANIC = "Oooh, yay! Are we putting on a play?",

        -- Webber
        MUTATOR_WARRIOR = "A tasty treat for those tiny terrors!",
        MUTATOR_DROPPER = "A tasty treat for those tiny terrors!",
        MUTATOR_HIDER = "A tasty treat for those tiny terrors!",
        MUTATOR_SPITTER = "A tasty treat for those tiny terrors!",
        MUTATOR_MOON = "A tasty treat for those tiny terrors!",
        MUTATOR_HEALER = "A tasty treat for those tiny terrors!",
        SPIDER_WHISTLE = "Hyuyu! Who knew spiders liked to whistle?",
        SPIDERDEN_BEDAZZLER = "I should paint mustaches on the mortals while they're sleeping...",
        SPIDER_HEALER = "I'm not sure I trust that strange orange dust.",
        SPIDER_REPELLENT = "The easiest way to get rid of a spider is with a big shoo, hyuyu!",
        SPIDER_HEALER_ITEM = "I think I'll make do without eating that goo.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "Hyuyu! Someone's getting crafty!",
		GHOSTLYELIXIR_FASTREGEN = "Hyuyu! Someone's getting crafty!",
		GHOSTLYELIXIR_SHIELD = "Hyuyu! Someone's getting crafty!",
		GHOSTLYELIXIR_ATTACK = "Hyuyu! Someone's getting crafty!",
		GHOSTLYELIXIR_SPEED = "Hyuyu! Someone's getting crafty!",
		GHOSTLYELIXIR_RETALIATION = "Hyuyu! Someone's getting crafty!",
		SISTURN =
		{
			GENERIC = "A touching tribute to a treasured twin.",
			SOME_FLOWERS = "A flowery addition for our apparition!",
			LOTS_OF_FLOWERS = "Maybe I should keep my distance...",
		},

        --Wortox
        WORTOX_SOUL = "Hyuyu! It looks tasty.", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Does it make soul food?",
            DONE = "A mortal meal is not really my deal.",

			COOKING_LONG = "I suppose I've wasted time in worse ways.",
			COOKING_SHORT = "A meal made in haste, but not lacking in taste.",
			EMPTY = "All the food has been spirited away.",
        },

        PORTABLEBLENDER_ITEM = "All that chopping and no souls.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Grind, grind, grind away.",
            DONE = "Mortals are so strange.",
        },
        SPICEPACK = "What a cute little pack. Hyuyu!",
        SPICE_GARLIC = "Hissss!",
        SPICE_SUGAR = "A saccharine collection of liquefied confection.",
        SPICE_CHILI = "I'll spike some mortal's food. Hyuyu!",
        SPICE_SALT = "Careful with that stuff!",
        MONSTERTARTARE = "Monster flesh that's very fresh. ",
        FRESHFRUITCREPES = "Fruits and berries put to bed.",
        FROGFISHBOWL = "I'd rather have a nice fresh soul.",
        POTATOTORNADO = "I think I remember when I used to eat food. Maybe.",
        DRAGONCHILISALAD = "Warly spends a lot of time on this stuff.",
        GLOWBERRYMOUSSE = "Seems like a lot of effort for something you eat.",
        VOLTGOATJELLY = "Hyuyu, it looks interesting at least.",
        NIGHTMAREPIE = "Hyuyu, humans sure are strange.",
        BONESOUP = "They spend all day cooking and then devour it in minutes.",
        MASHEDPOTATOES = "Humans mush stuff up sometimes. That's just how it is.",
        POTATOSOUFFLE = "I'm sure it's good, but it's not for me.",
        MOQUECA = "I don't really like human food.",
        GAZPACHO = "This human food stuff seems more watery than usual.",
        ASPARAGUSSOUP = "Even for human food, this is odd.",
        VEGSTINGER = "I can't decide if it's for sipping or souping.",
        BANANAPOP = "Hyuyu, what will the mortals think of next?",
        CEVICHE = "I'd rather leave this for the humans.",
        SALSA = "A spicy treat for mortals to eat.",
        PEPPERPOPPER = "I'll stuff them with toothpaste when Warly's not looking. Hyuyu!",

        TURNIP = "That's a tiny turnip.",
        TURNIP_COOKED = "Cooked, but not into a dish.",
        TURNIP_SEEDS = "Strange little seeds, indeed, indeed.",

        GARLIC = "Hissss!",
        GARLIC_COOKED = "Hissssss!",
        GARLIC_SEEDS = "Strange little seeds, indeed, indeed.",

        ONION = "You'll see no tears from my eye. I cannot cry!",
        ONION_COOKED = "Like tiny circles descending.",
        ONION_SEEDS = "Strange little seeds, indeed, indeed.",

        POTATO = "Mortals like this in all its forms.",
        POTATO_COOKED = "A roasted mortal food.",
        POTATO_SEEDS = "Strange little seeds, indeed, indeed.",

        TOMATO = "Who shall I throw this at?",
        TOMATO_COOKED = "Squishy, squishy.",
        TOMATO_SEEDS = "Strange little seeds, indeed, indeed.",

        ASPARAGUS = "A spear I guess. Hyuyu!",
        ASPARAGUS_COOKED = "I'd rather not.",
        ASPARAGUS_SEEDS = "Strange little seeds, indeed, indeed.",

        PEPPER = "An impy little vegetable.",
        PEPPER_COOKED = "Tiny toasted twisty things.",
        PEPPER_SEEDS = "Strange little seeds, indeed, indeed.",

        WEREITEM_BEAVER = "I do love a cursed trinket!",
        WEREITEM_GOOSE = "Let loose the goose!",
        WEREITEM_MOOSE = "Weremoose? There moose!",

        MERMHAT = "Some would call me two-faced, hyuyu!",
        MERMTHRONE =
        {
            GENERIC = "A mat made for a monarch.",
            BURNT = "A little rain could have saved their reign.",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "My my, what mischief are you making?",
            BURNT = "Looks like someone played a little prank!",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "An abode fit for a toad, hyuyu!",
            BURNT = "Someone's already had their fun.",
        },

        MERMWATCHTOWER_REGULAR = "There's a terrible stench of fish...",
        MERMWATCHTOWER_NOKING = "Guards with no king, like puppets with no string.",
        MERMKING = "Slimy is the head that wears the crown.",
        MERMGUARD = "The horns are an improvement.",
        MERM_PRINCE = "Hyuyuyu, a prince! Charming!",

        SQUID = "An eerie eye to see the sea.",

		GHOSTFLOWER = "What a fetching phantom flower.",
        SMALLGHOST = "I prefer souls with more meat on their bones... metaphorically speaking.",

        CRABKING =
        {
            GENERIC = "Another cursed soul.",
            INERT = "This castle is missing its crown jewels.",
        },
		CRABKING_CLAW = "Now that's claws for alarm, hyuyuyu!",

		MESSAGEBOTTLE = "I'm tempted to take a peek!",
		MESSAGEBOTTLEEMPTY = "An empty vessel.",

        MEATRACK_HERMIT =
        {
            DONE = "The jerky is ready.",
            DRYING = "It's drying.",
            DRYINGINRAIN = "It's undrying day.",
            GENERIC = "Her hooks are bare, but should I care?",
            BURNT = "A silly prank to be sure.",
            DONE_NOTMEAT = "The food's ready.",
            DRYING_NOTMEAT = "It's drying.",
            DRYINGINRAIN_NOTMEAT = "It's undrying day.",
        },
        BEEBOX_HERMIT =
        {
            READY = "So much honey! That crabby mortal might crack a smile!",
            FULLHONEY = "So much honey! That crabby mortal might crack a smile!",
            GENERIC = "The whole hive is abuzz!",
            NOHONEY = "Nothing inside but bees, oh yes!",
            SOMEHONEY = "We could scrape a bit of honey out.",
            BURNT = "Mayhaps it's caramelized within!",
        },

        HERMITCRAB = "Hyuyu, let's see if we can't coax this crab out of her shell!",

        HERMIT_PEARL = "A treasured treasure.",
        HERMIT_CRACKED_PEARL = "A shattered hope.",

        -- DSEAS
        WATERPLANT = "I feel as though I've ended up in Wonderland, hyuyu!",
        WATERPLANT_BOMB = "That plant is so selfish, it won't share its shellfish!",
        WATERPLANT_BABY = "I surmise it's not yet at full size.",
        WATERPLANT_PLANTER = "A bouncing baby bulb.",

        SHARK = "Don't eat me, you'll get fur stuck in your teeth!",

        MASTUPGRADE_LAMP_ITEM = "A light to lead us through the night.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "Now mayhaps, we won't get zapped!",

        WATERPUMP = "This will put a swift end to fiery pranks...",

        BARNACLE = "A briny bunch of barnacles.",
        BARNACLE_COOKED = "I'd rather not.",

        BARNACLEPITA = "Unless this pocket is filled with souls, I'll pass.",
        BARNACLESUSHI = "Perhaps one of the mortals will enjoy it.",
        BARNACLINGUINE = "Oodles of fishy noodles.",
        BARNACLESTUFFEDFISHHEAD = "Hyuyu, no talking with your mouth full!",

        LEAFLOAF = "Even the mortals don't seem to care for it.",
        LEAFYMEATBURGER = "Mortals seem to get quite irritated when you mess with their food.",
        LEAFYMEATSOUFFLE = "I'll stick to souls, thank you.",
        MEATYSALAD = "Hyuyuyu! What a deliciously deceptive prank!",

        -- GROTTO

		MOLEBAT = "Hyuyu, what a nosy creature!",
        MOLEBATHILL = "This snotty collection needs further inspection.",

        BATNOSE = "Oh my, looks like somebody blew it.",
        BATNOSE_COOKED = "This smells! I think it's gone off!",
        BATNOSEHAT = "What will the mortals cook up next.",

        MUSHGNOME = "I mistook that portly fellow for a Portobello! Hyuyu!",

        SPORE_MOON = "Don't get too close or you'll be feeling awfully spore.",

        MOON_CAP = "Why not cap the day off with a little snooze? Hyuyuyu!",
        MOON_CAP_COOKED = "Why you tricky thing, you've changed!",

        MUSHTREE_MOON = "Someone played a prank on it.",

        LIGHTFLIER = "Bloom and glow!",

        GROTTO_POOL_BIG = "Perhaps it is home to a nymph.",
        GROTTO_POOL_SMALL = "Perhaps it is home to a very tiny nymph.",

        DUSTMOTH = "That charming creature nearly swept me off my feet, hyuyu!",

        DUSTMOTHDEN = "I'm afraid their nest has something I wish to possess.",

        ARCHIVE_LOCKBOX = "Oh ho! A puzzling piece indeed!",
        ARCHIVE_CENTIPEDE = "The message is clear, it does not want me here.",
        ARCHIVE_CENTIPEDE_HUSK = "An empty, soulless shell.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "It will take quite some time.",
            COOKING_SHORT = "I'm shivering with anticipation!",
            DONE = "Looks like my treat is ready to eat!",
            EMPTY = "I think whatever was cooking has gone cold.",
            BURNT = "I don't understand how to make mortal food.",
        },

        ARCHIVE_MOON_STATUE = "My, that looks heavy.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "Oh, what's this? A bit of light reading?",
            LINE_2 = "It seems they were quite enamoured with our fickle moon once.",
            LINE_3 = "Now this one doesn't make much sense at all. Unless...",
            LINE_4 = "Oh my! My, my my!",
            LINE_5 = "Hyuyu, I shouldn't spoil the surprise!",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "There's something hidden that it seeks.",
            IDLE = "We've finished the deed, nowhere left to lead.",
        },

        ARCHIVE_RESONATOR_ITEM = "What a curious contraption!",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "What a shame, these machines have no souls to claim.",
          GENERIC =  "Do you have any secrets for me?",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "Now what are you, and what did you do?",
            GENERIC = "Oooh how fun! A trap!",
        },

        ARCHIVE_SECURITY_PULSE = "A fellow fae come to show me the way? I think not, hyuyu!",

        ARCHIVE_SWITCH = {
            VALID = "It's clutching tightly to that treasure.",
            GEMS = "It craves something glittery.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "I won't tell the mortals it's here, it'll just get their poor hopes up.",
            GENERIC = "My my, someone didn't want this door opened.",
        },

        WALL_STONE_2 = "To keep you out, or keep me in?",
        WALL_RUINS_2 = "To keep you out, or keep me in?",

        REFINED_DUST = "Just a bit of faith, trust, and assorted dust.",
        DUSTMERINGUE = "Hyuyuyu! The pranks I could pull with these!",

        SHROOMCAKE = "There's no room in my stomach, I'm afraid.",

        NIGHTMAREGROWTH = "Methinks we'd best be on our way!",

        TURFCRAFTINGSTATION = "Mortals just love to change the world to suit them.",

        MOON_ALTAR_LINK = "Oh, this is going to be fun! Hyuyuyu!",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Not exactly a barrel of laughs.",
            WET = "I tried and yet, it's far too wet.",
            DRY = "Nice try, but it's too dry.",
            BALANCED = "What a delight, it turned out just right!",
            BURNT = "How silly!",
        },
        COMPOST = "Oh, I could pull some fun pranks with this.",
        SOIL_AMENDER =
		{
			GENERIC = "This kelp should help our garden grow, hyuyu!",
			STALE = "This planty drink is starting to stink.",
			SPOILED = "This bubbling brew will make the plants good as new.",
		},

		SOIL_AMENDER_FERMENTED = "A most potent plant potion indeed!",

        WATERINGCAN =
        {
            GENERIC = "A watering can, what an excellent plan!",
            EMPTY = "The water was spilled, it must be refilled!",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "This reminds me of a certain bird we ran afowl of.",
            EMPTY = "The water was spilled, it must be refilled!",
        },

		FARM_PLOW = "Plowing a plot for picky plants.",
		FARM_PLOW_ITEM = "All work and no play makes for one unhappy imp.",
		FARM_HOE = "I've about had my fill of tilling and toiling.",
		GOLDEN_FARM_HOE = "How splendidly excessive! Hyuyu!",
		NUTRIENTSGOGGLESHAT = "The gardener's crown to set upon my furry brow.",
		PLANTREGISTRYHAT = "I beg your pardon, is that a hat for the garden?",

        FARM_SOIL_DEBRIS = "I'm afraid I'll have to banish it from the garden.",

		FIRENETTLES = "Oh ho! Fiery indeed!",
		FORGETMELOTS = "They seems to have a tinge of magic about them.",
		SWEETTEA = "A little sip will do the trick.",
		TILLWEED = "Till what, weed?",
		TILLWEEDSALVE = "A welcome break from pains and aches.",
        WEED_IVY = "It seems a little wound up.",
        IVY_SNARE = "That seemed like an overreaction.",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Hoohoo, a game!",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nBut is it worth the weight? Hyuyu!",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nI say, what a nice display!",
            HAS_ITEM_LIGHT = "It's not enough to tip the scale, hyuyu!",
			BURNING = "What fun!",
			BURNT = "Let's do it again, hyuyu!",
        },

        CARROT_OVERSIZED = "I suppose the mortals might enjoy something like that.",
        CORN_OVERSIZED = "Lend me your ear, hyuyu!",
        PUMPKIN_OVERSIZED = "Quite the plump pumpkin.",
        EGGPLANT_OVERSIZED = "How strange!",
        DURIAN_OVERSIZED = "It gives off such a stink, it's hard to think!",
        POMEGRANATE_OVERSIZED = "How in the underworld did you grow so big?",
        DRAGONFRUIT_OVERSIZED = "A giant fruit, and a dragon's to boot!",
        WATERMELON_OVERSIZED = "If only it had a soul!",
        TOMATO_OVERSIZED = "Hyuyu, I'll have to find something very big to throw it at!",
        POTATO_OVERSIZED = "Oh, the mortals will be thrilled!",
        ASPARAGUS_OVERSIZED = "None for me, thank you.",
        ONION_OVERSIZED = "An ourageously large onion!",
        GARLIC_OVERSIZED = "Hissssss!",
        PEPPER_OVERSIZED = "That will put some pep in someone's step, hyuyuyu!",

        VEGGIE_OVERSIZED_ROTTEN = "This one's spoiled rotten!",

		FARM_PLANT =
		{
			GENERIC = "A plant!",
			SEED = "Come out and join us, little one!",
			GROWING = "Grow big and tall, or not at all.",
			FULL = "Oh what a sight, the crops are ripe!",
			ROTTEN = "Even the mortals won't eat this one.",
			FULL_OVERSIZED = "If only I cared to eat mortal food!",
			ROTTEN_OVERSIZED = "This one's spoiled rotten!",
			FULL_WEED = "It's a weed indeed! Hyuyuyu!",

			BURNING = "Hyuyuyu, whoopsie!",
		},

        FRUITFLY = "Pulling pranks on the plants, I see!",
        LORDFRUITFLY = "Hyuyu! I would expect more civility from the nobility!",
        FRIENDLYFRUITFLY = "This fly has a much more tempered temper.",
        FRUITFLYFRUIT = "I'll just put that in my pocket and see what happens!",

        SEEDPOUCH = "For my gardening needs, a place to store seeds!",

		-- Crow Carnival
		CARNIVAL_HOST = "How now, spirit? Whither wander you?",
		CARNIVAL_CROWKID = "Hyuyu, so nice to see these fine folk out and about!",
		CARNIVAL_GAMETOKEN = "Who could resist such a shiny trinket?",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "One ticket please, hyuyu!",
			GENERIC_SMALLSTACK = "A pretty pile of prize tickets.",
			GENERIC_LARGESTACK = "I can almost see the prize before my eyes.",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "A small trap door is set in the floor.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "Allow me to propose a trade: one shiny trinket to play your game.",
			PLAYING = "You must be quick to feed the chicks.",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "We're almost ready for the fun to begin!",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Imagine what a fun prank it would be to replace these with real worms...",

		CARNIVALGAME_MEMORY_KIT = "We're almost ready for the fun to begin!",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "Allow me to propose a trade: one shiny trinket to play your game.",
			PLAYING = "This game is sure to test one's brain.",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "A small trap door is set in the floor.",
			PLAYING = "This one or that one?",
		},

		CARNIVALGAME_HERDING_KIT = "We're almost ready for the fun to begin!",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "Allow me to propose a trade: one shiny trinket to play your game.",
			PLAYING = "It's quite fun, or so I herd. Hyuyuyu!",
		},
		CARNIVALGAME_HERDING_CHICK = "To the center, if you please.",

		CARNIVAL_PRIZEBOOTH_KIT = "What kind of goodies will it have, I wonder?",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "What to choose, what to choose...",
		},

		CARNIVALCANNON_KIT = "Let's start things off with a bang, shall we? Hyuyuyu!",
		CARNIVALCANNON =
		{
			GENERIC = "Oh the pranks I could pull with this!",
			COOLDOWN = "Hyuyuyu, what fun!",
		},

		CARNIVAL_PLAZA_KIT = "Now if I were a crow, where would I think it should go?",
		CARNIVAL_PLAZA =
		{
			GENERIC = "This place could use some sprucing up, don't you think?",
			LEVEL_2 = "It's fine, but this place could use more sparkle and shine.",
			LEVEL_3 = "Fittingly fancified for our fine feathered friends.",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "Nearly there.",
		CARNIVALDECOR_EGGRIDE = "On and on and on it goes!",

		CARNIVALDECOR_LAMP_KIT = "Nearly there.",
		CARNIVALDECOR_LAMP = "A fairy light to glow in the night.",
		CARNIVALDECOR_PLANT_KIT = "Nearly there.",
		CARNIVALDECOR_PLANT = "We can take a small bit of the Cawnival wherever we go.",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "The rarest of trinkets!",
			UNCOMMON = "Hyuyu, a fine find indeed!",
			GENERIC = "Mortals do love their trinkets.",
		},
		CARNIVALDECOR_FIGURE_KIT = "Hyuyu, how very mysterious!",

        CARNIVAL_BALL = "It goes quite nicely with my fur!", --unimplemented
		CARNIVAL_SEEDPACKET = "I'm sure they won't be offended if I dump these on the ground.",
		CARNIVALFOOD_CORNTEA = "I think I'll go find a nice refreshing soul instead.",

        CARNIVAL_VEST_A = "I'm quite partial to the style.",
        CARNIVAL_VEST_B = "A cloak of leaves to drape around my impish frame.",
        CARNIVAL_VEST_C = "Short and sweet, hyuyu!",

        -- YOTB
        YOTB_SEWINGMACHINE = "It's all connected by a common thread, hyuyu!",
        YOTB_SEWINGMACHINE_ITEM = "I do believe there's a needle in that haystack.",
        YOTB_STAGE = "Hyuyu! How interesting!",
        YOTB_POST =  "A stage to show my beefalo.",
        YOTB_STAGE_ITEM = "The excitement is building, hyuyuyu!",
        YOTB_POST_ITEM =  "Let's get it done so we can have fun!",


        YOTB_PATTERN_FRAGMENT_1 = "A puzzling piece of a pattern.",
        YOTB_PATTERN_FRAGMENT_2 = "A puzzling piece of a pattern.",
        YOTB_PATTERN_FRAGMENT_3 = "A puzzling piece of a pattern.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "Enjoying the plush life? Hyuyuyu!",
            YOTB = "Our judge just may have something to say.",
        },

        WAR_BLUEPRINT = "Fit for a fearsome fellow.",
        DOLL_BLUEPRINT = "Oh what a dollight! Hyuyu!",
        FESTIVE_BLUEPRINT = "My friend can frolic in this festive frock!",
        ROBOT_BLUEPRINT = "This outfit might require a lot of ironing, hyuyu!",
        NATURE_BLUEPRINT = "I suppose I'll reap what I sew, hyuyu!",
        FORMAL_BLUEPRINT = "But will it really suit my beefalo? Hyuyu!",
        VICTORIAN_BLUEPRINT = "Fancy, that!",
        ICE_BLUEPRINT = "I just got chills! Hyuyuyu!",
        BEAST_BLUEPRINT = "Lucky, hm? Perhaps it's made with fairy gold.",

        BEEF_BELL = "What a strange enchantment!",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "Where all the furry mortals go.",
            BURNT = "Just a little prank, hyuyu!",
			PLAYING_HIDEANDSEEK = "They've gone out to play!",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "Playtime's almost over, hyuyu!",
		},

		KITCOONDEN_KIT = "They're here to play, or so they say, hyuyu!",

		TICOON = 
		{
			GENERIC = "I've set my worries to the side, they'll be my guide!",
			ABANDONED = "All alone, no mortal to play with.",
			SUCCESS = "It found all the little pranksters!",
			LOST_TRACK = "Fee-fi-fo-fum, where have they gone?",
			NEARBY = "They too can feel a trickster's around, hyuyu!",
			TRACKING = "Oh where, where could they be, hyuyu.",
			TRACKING_NOT_MINE = "They're not looking for who I'm looking for.",
			NOTHING_TO_TRACK = "No one to find, oh my, oh my.",
			TARGET_TOO_FAR_AWAY = "They're far far away, yet here I stay.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "Such a pretty little kitty!",
            EMPTY = "Whatever was here, disappeared!",
            BURNT = "Well, that's that.",
        },

		KITCOON_FOREST = "They could prank, hide around, and never be found!",
		KITCOON_SAVANNA = "Your stripes can't trick my eyes!",
		KITCOON_MARSH = "There's no tentacle in that fur, right? Hyuyu.",
		KITCOON_DECIDUOUS = "I prefer playing with smarter mortals.",
		KITCOON_GRASS = "Ooo, the fingers your fur could prick, hyuyu.",
		KITCOON_ROCKY = "Oh my friend, why the stone face?",
		KITCOON_DESERT = "Oh kitty, what big ears you have!",
		KITCOON_MOON = "The kit jumped over the moon, hyuyu!",
		KITCOON_YOT = "Oh what a date, let's celebrate!",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "We got off to a rocky start, didn't we? Hyuyu!",
            DEAD = "Send my regards to your master!",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "Hoohoo! It seems there's more in store!",
            DEAD = "Now with any luck it kicked the bucket.",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "This imp will not be contained so easily.",
        ALTERGUARDIAN_PHASE3 = "The time is right to end this fight!",
        ALTERGUARDIAN_PHASE3TRAP = "Hoohoo, this imp knows a trick when he sees one.",
        ALTERGUARDIAN_PHASE3DEADORB = "Energy, but no soul to snack on. A pity.",
        ALTERGUARDIAN_PHASE3DEAD = "Shall we see what's left behind?",

        ALTERGUARDIANHAT = "It tells me the most delicious secrets, hyuyu!",
        ALTERGUARDIANHATSHARD = "It won't be too hard to find a use for this shard.",

        MOONSTORM_GLASS = {
            GENERIC = "Shiny and sharp.",
            INFUSED = "Ah, what a healthy glow!"
        },

        MOONSTORM_STATIC = "Best stay back if I don't want to get zapped!",
        MOONSTORM_STATIC_ITEM = "It makes my fur stand on end.",
        MOONSTORM_SPARK = "Hyuyu, it tickles!",

        BIRD_MUTANT = "My my, you're looking rather pale!",
        BIRD_MUTANT_SPITTER = "This peculiar storm has changed its form.",

        WAGSTAFF_NPC = "Hyuyuyu! He's not all there!",
        ALTERGUARDIAN_CONTAINED = "Oh ho! It seems he has some tricks up his sleeve.",

        WAGSTAFF_TOOL_1 = "Hoohoo! You're not from around this plane, are you?",
        WAGSTAFF_TOOL_2 = "You belong in the hand of that old man.",
        WAGSTAFF_TOOL_3 = "This may be what I'm looking for, or not!",
        WAGSTAFF_TOOL_4 = "Oooh how fun! I can't be sure if that's the right one!",
        WAGSTAFF_TOOL_5 = "What a fun game, finding tools from another plane!",

        MOONSTORM_GOGGLESHAT = "What a lune-y invention, hyuyu!",

        MOON_DEVICE = {
            GENERIC = "Hyuyuyu, I don't think they'll like that...",
            CONSTRUCTION1 = "I'll help a bit, but if it's no fun I'll quit!",
            CONSTRUCTION2 = "What mysterious machinations!",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Mortals keep coming up with such funny tricks!",
			RECHARGING = "These clocks, you will find, need some time to unwind.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Mortals keep coming up with such funny tricks!",
			RECHARGING = "These clocks, you will find, need some time to unwind.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Mortals keep coming up with such funny tricks!",
			RECHARGING = "These clocks, you will find, need some time to unwind.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Mortals keep coming up with such funny tricks!",
			RECHARGING = "These clocks, you will find, need some time to unwind.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Mortals keep coming up with such funny tricks!",
			RECHARGING = "These clocks, you will find, need some time to unwind.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Did I hear \"one o'clock sharp\", or \"one sharp clock\"? Hyuyu!",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Ooohoohoo, someone's been naughty!",
        POCKETWATCH_DISMANTLER = "The tools of a time tinkerer.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Hyuyuyu, we'll be sure to get there in a timely manner!",
			DIFFERENTSHARD = "Hyuyuyu, we'll be sure to get there in a timely manner!",
		},
        POCKETWATCH_PORTAL_EXIT = "You can always count on the mortals to make things needlessly complicated.",

        -- Waterlog
        WATERTREE_PILLAR = "It seems we've found safe arbor, hyuyu!",
        OCEANTREE = "How is ocean life treating you?",
        OCEANTREENUT = "The sea is a nutty place to plant a tree.",
        WATERTREE_ROOT = "Hyuyuyu! You won't trip me up with your tricky roots!",

        OCEANTREE_PILLAR = "They grow up so fast!",
        
        OCEANVINE = "A fine enough vine.",
        FIG = "They say the low hanging fruit is the sweetest!",
        FIG_COOKED = "The mortals seem to prefer it this way.",

        SPIDER_WATER = "They're just getting their feet wet.",
        MUTATOR_WATER = "A tasty treat for those tiny terrors!",
        OCEANVINE_COCOON = "Rock-a-bye spiders, in the treetop...",
        OCEANVINE_COCOON_BURNT = "What a shame, it went up in flames.",

        GRASSGATOR = "See you later, gator.",

        TREEGROWTHSOLUTION = "It'll really rib to your sticks.",

        FIGATONI = "I'll pass.",
        FIGKABAB = "Food on a stick won't do the trick.",
        KOALEFIG_TRUNK = "As mortal dishes go, that looks particularly revolting.",
        FROGNEWTON = "How do the mortals come up with these things?",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "A souvenir of sorts, hyuyu!",
            CRIMSON = "Oh dear, perhaps I've taken this prank too far...",
            ENABLED = "Hyuyu... whoopsie...",
			WAITING_FOR_DARK = "I can't tell if that bodes well.",
			COOLDOWN = "Its power's gone, but not for long.",
			SPAWN_DISABLED = "It seems nobody here likes pranks.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Mortals have such curious ways.",
            BURNT = "The exercise has been exorcised.",
        },

        DUMBBELL = "It's neither dumb, nor a bell. Mortals are strange, indeed.",
        DUMBBELL_GOLDEN = "It's neither dumb, nor a bell. Mortals are strange, indeed.",
		DUMBBELL_MARBLE = "Marbellous, simply marbellous!",
        DUMBBELL_GEM = "He's turned those gemstones into gymstones, hyuyu!",
        POTATOSACK = "Hyuyuyu, wouldn't it be fun to hide inside and give him a scare?",


        TERRARIUMCHEST = 
		{
			GENERIC = "Extraordinarily ordinary!",
			BURNT = "Hyuyu, someone's been playing pranks.",
			SHIMMER = "Oh, pay it no mind!",
		},

		EYEMASKHAT = "Well, isn't this a sight for sore eyes. Hyuyuyu!",

        EYEOFTERROR = "Whatever he says I did, it's a lie!",
        EYEOFTERROR_MINI = "I feel positively terror eyes'd!",
        EYEOFTERROR_MINI_GROUNDED = "Oh my, won't you open your eye?",

        FROZENBANANADAIQUIRI = "Don't the mortals like to innovate? Hyuyu.",
        BUNNYSTEW = "Are mortals attracted to this smell?",
        MILKYWHITES = "This loot from our fight does not bring delight. ",

        CRITTER_EYEOFTERROR = "I'm glad we could make amends, my ocular friend!",

        SHIELDOFTERROR ="I stole the grin right off of him, hyuyu!",
        TWINOFTERROR1 = "Double double, we're in trouble!",
        TWINOFTERROR2 = "Double double, we're in trouble!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "Wind the bobbin up, pull, pull!",
        KITCOON_NAMETAG = "To help identify who's theirs and who's mine.",

		KITCOONDECOR1 =
        {
            GENERIC = "Let it spin and wobble if it doesn't squabble.",
            BURNT = "A burnt toy brings no fun.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "This fish will be no dish, hyuyu.",
            BURNT = "A burnt toy brings no fun.",
        },

		KITCOONDECOR1_KIT = "To make a toy is such a joy!",
		KITCOONDECOR2_KIT = "To make a toy is such a joy!",

        -- WX78
        WX78MODULE_MAXHEALTH = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MAXSANITY1 = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MAXSANITY = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MOVESPEED = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MOVESPEED2 = "Are you the brightest bulb of the bunch?",
        WX78MODULE_HEAT = "Are you the brightest bulb of the bunch?",
        WX78MODULE_NIGHTVISION = "Are you the brightest bulb of the bunch?",
        WX78MODULE_COLD = "Are you the brightest bulb of the bunch?",
        WX78MODULE_TASER = "Are you the brightest bulb of the bunch?",
        WX78MODULE_LIGHT = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MAXHUNGER1 = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MAXHUNGER = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MUSIC = "Are you the brightest bulb of the bunch?",
        WX78MODULE_BEE = "Are you the brightest bulb of the bunch?",
        WX78MODULE_MAXHEALTH2 = "Are you the brightest bulb of the bunch?",

        WX78_SCANNER = 
        {
            GENERIC ="My my, how the tin flies!",
            HUNTING = "My my, how the tin flies!",
            SCANNING = "My my, how the tin flies!",
        },

        WX78_SCANNER_ITEM = "The tiny tin terror's tuckered out!",
        WX78_SCANNER_SUCCEEDED = "It's done its toil, now our friend must collect the spoils.",

        WX78_MODULEREMOVER = "It'll work in a pinch, hyuyu!",

        SCANDATA = "Hyuyuyu, I think our friend has some tricks up those tin sleeves!",
    },

    DESCRIBE_GENERIC = "Ooo, a mystery!",
    DESCRIBE_TOODARK = "I can't see the physical plane!",
    DESCRIBE_SMOLDERING = "Some fiery fun is about to begin!",

    DESCRIBE_PLANTHAPPY = "Well well, this plant looks swell!",
    DESCRIBE_PLANTVERYSTRESSED = "With much regret, I'd say this plant is upset.",
    DESCRIBE_PLANTSTRESSED = "Something's bothering our budding buddy.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Something around needs to be pulled from the ground.",
    DESCRIBE_PLANTSTRESSORFAMILY = "It's feeling quite down with no plants like it around.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "From the looks of this place, I'd say it needs more space.",
    DESCRIBE_PLANTSTRESSORSEASON = "This plant could be better, it doesn't like the weather.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "It needs a drink, I think.",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "It needs better soil or our hard work will be spoiled!",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "What's that? You'd like to chat?",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Doing that hurt my feelings.",
		WINTERSFEASTFUEL = "Hyuyu, how fun!",
    },
}
