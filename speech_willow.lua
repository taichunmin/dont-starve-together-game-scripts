--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Hey! Quit doing whatever you're doing and look at this!",
        },
        REPAIR =
        {
            WRONGPIECE = "We carried it all this way and it's not even the right one!",
        },
        BUILD =
        {
            MOUNTED = "I can't place anything from atop this big lout!",
            HASPET = "I've already got one!",
			TICOON = "Wait... you're not my ticoon!",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Maybe I should wait for it to be distracted...",
			GENERIC = "Nu-uh.",
			NOBITS = "It's already shaved!",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "Pfft, let someone else do it.",
		},
		STORE =
		{
			GENERIC = "It's full already.",
			NOTALLOWED = "They won't let me.",
			INUSE = "I'll use it after they're done.",
            NOTMASTERCHEF = "I'm not THAT good at cooking.",
		},
        CONSTRUCT =
        {
            INUSE = "Ugh. Someone's already using it.",
            NOTALLOWED = "It won't go in there.",
            EMPTY = "I need something to build with first!",
            MISMATCH = "It's the wrong plans. Jeez!",
        },
		RUMMAGE =
		{
			GENERIC = "Make someone else do it!",
			INUSE = "There must be something good in there if you want it so bad!",
            NOTMASTERCHEF = "I'm not THAT good at cooking.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Darn thing won't work!",
        	KLAUS = "But that big ugly thing is on my tail!",
			QUAGMIRE_WRONGKEY = "You mean there's another key?!",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "I can't even burn it!",
            HOSTBUSY = "Hey. Hey. Hey. Hey. I'm gonna keep going until you answer me!",
            CARNIVAL_HOST_HERE = "I know I saw that fancy bird guy around here.",
            NOCARNIVAL = "Aww, looks like they all left.",
			EMPTY_CATCOONDEN = "Anyone home? ...Guess not.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "It'd be more fun with more kitcoons.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "This place doesn't have a ton of hiding spots...",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "They look tired. Let's play again tomorrow!",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "I'm not THAT good at cooking.",
			SHADOWMAGIC = "Would make a great bedtime story... for nightmares!",
		},
        COOK =
        {
            GENERIC = "I'm not too big on cooking.",
            INUSE = "Hey! What're you making? Can I have it?",
            TOOFAR = "It's all the way over thereeeee!",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "A race isn't any fun without someone to beat.",
        },

		DISMANTLE =
		{
			COOKING = "I'm not going to interrupt it while it's cooking.",
			INUSE = "But I want to use it!",
			NOTEMPTY = "Hey, there's still stuff in here!",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Stupid fish. Get on my hook!!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Seems like overkill.",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "Noooope!",
            DEAD = "They won't fully appreciate my gift.",
            SLEEPING = "Not right now. It's sleeping.",
            BUSY = "It's busyyyy.",
            ABIGAILHEART = "Ugh, just come back already! Geez!",
            GHOSTHEART = "I'm not wasting this on them!",
            NOTGEM = "I can cram it in there but I dunno if I could get it back out.",
            WRONGGEM = "It's the wrong rock!",
            NOTSTAFF = "I don't have to jam stuff into every hole I see!",
            MUSHROOMFARM_NEEDSSHROOM = "Ughh, it doesn't need this! It needs a mushroom!",
            MUSHROOMFARM_NEEDSLOG = "Ughh, it doesn't need this! It needs a living log!",
            MUSHROOMFARM_NOMOONALLOWED = "These dumb mushrooms won't grow!",
            SLOTFULL = "Naw, can't make it fit.",
            FOODFULL = "I have to wait for it to eat this one first.",
            NOTDISH = "I wouldn't serve that to a dog!",
            DUPLICATE = "Awww, we already know that one!",
            NOTSCULPTABLE = "I'd like to see someone try to sculpt with that!",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "It's not working.",
            WRONGSHADOWFORM = "Nah. Skeleton's not right.",
            NOMOON = "Jerk! It won't work in here!",
			PIGKINGGAME_MESSY = "Aww... You mean I gotta clean up first?",
			PIGKINGGAME_DANGER = "Not now! There's big jerks around.",
			PIGKINGGAME_TOOLATE = "Naw. It's too late.",
			CARNIVALGAME_INVALID_ITEM = "I guess that won't work.",
			CARNIVALGAME_ALREADY_PLAYING = "Come on, hurry up!",
            SPIDERNOHAT = "Why does it need a hat when it's snug as a bug in my pocket?",
            TERRARIUM_REFUSE = "What, that wasn't good enough for it?",
            TERRARIUM_COOLDOWN = "It's not taking it, is it broken? Where'd that tree go?",
        },
        GIVETOPLAYER =
        {
            FULL = "They can't carry any more things.",
            DEAD = "They won't fully appreciate my gift.",
            SLEEPING = "I could leave it under their pillow...?",
            BUSY = "Hurry uppp! I have a sweet present for you!",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "They can't carry any more things.",
            DEAD = "They won't fully appreciate my gift.",
            SLEEPING = "I could leave it under their pillow...?",
            BUSY = "Hurry uppp! I have a sweet present for you!",
        },
        WRITE =
        {
            GENERIC = "I can't write on it.",
            INUSE = "I wanna write when you're done!",
        },
        DRAW =
        {
            NOIMAGE = "But what should I even draw??",
        },
        CHANGEIN =
        {
            GENERIC = "Nah, too much effort.",
            BURNING = "That's way better than some dumb dresses!",
            INUSE = "Stop hogging it, I wanna dress up too!",
            NOTENOUGHHAIR = "It might help if my beefalo had more hair.",
            NOOCCUPANT = "Just a wild guess, but I might need to hitch up a beefalo first.",
        },
        ATTUNE =
        {
            NOHEALTH = "Ughhhh, nooo... I don't feel good.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I'll ride it when it settles down.",
            INUSE = "They beat me to the hairy beast. Maybe it's for the best.",
			SLEEPING = "Oh good you're awake, now let's get going!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I'll ride it when it settles down.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "I knowwwww that already, geez!",
            CANTLEARN = "Ugh, whatever, I didn't wanna know anyway.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "What the... this map isn't right at all!",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "No point trying to read this here.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "I'm not just gonna wrap air!",
        },
        PICKUP =
        {
			RESTRICTION = "I'm not using that!",
			INUSE = "But I want to use it!",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Hey, you're not my Carrat!",
                "Mine is the little orange one, with whiskers.",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Hey! Get back here!",
        },
        REPLATE =
        {
            MISMATCH = "Ugh! I can't use that dish for that food!",
            SAMEDISH = "It's already on a dish!",
        },
        SAIL =
        {
        	REPAIR = "Why? It looks fine to me.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Don't think that was right.",
            BAD_TIMING1 = "Ugh, lost the rhythm.",
            BAD_TIMING2 = "Water's definitely not my thing.",
        },
        LOWER_SAIL_FAIL =
        {
            "Get down, you stupid sail!",
            "Oh man, I just love doing this over and over.",
            "Uuuuuuuuuugh.",
        },
        BATHBOMB =
        {
            GLASSED = "Pfft, that wouldn't work with glass in the way.",
            ALREADY_BOMBED = "Aww, someone did that one already!",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "Awww, we already know that one!",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "This thing's too small to even bother weighing.",
            OVERSIZEDVEGGIES_TOO_SMALL = "Nope. Not even gonna bother.",
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
            GENERIC = "Pfft, I already know what I need to know.",
            FERTILIZER = "Well, that's about all I ever want to know about this stuff.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Aw, come on! A little seawater would toughen them up!",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Oh nooo I'm out of water, how terrible.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Welp, I'm out of water. Can I go back to burning stuff now?",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Yeah... that's not going to work.",
            BEEF_BELL_ALREADY_USED = "Someone already got to it first.",
            BEEF_BELL_HAS_BEEF_ALREADY = "One beefalo is enough to deal with.",
        },
        HITCHUP =
        {
            NEEDBEEF = "Might help if I had a beefalo...",
            NEEDBEEF_CLOSER = "I need to get that beefalo over here.",
            BEEF_HITCHED = "Already done.",
            INMOOD = "Ugh, there's just no reasoning with them when they get like this.",
        },
        MARK =
        {
            ALREADY_MARKED = "No take backs!",
            NOT_PARTICIPANT = "I bet this would be a lot more exciting if I set something on fire.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Hey weird guy! Helloooo?",
            ALREADYACTIVE = "Guess he's somewhere else.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "Ugh, I already know this one!",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "I wasn't too slow, it was too fast.",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "These jerks won't listen to me.",
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
            DOER_ISNT_MODULE_OWNER = "Ha! Scan THAT!",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Uuugh I need more stuff!",
		NO_TECH = "Yeaahh, so... I haven't actually figured that one out yet.",
		NO_STATION = "I can't make it here!",
	},

	ACTIONFAIL_GENERIC = "I can'tttttt.",
	ANNOUNCE_BOAT_LEAK = "Gross, I hate water.",
	ANNOUNCE_BOAT_SINK = "I'm gonna drown!!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Pfft. Fire would've worked just as well.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Ugh, put it back!", --removed
	ANNOUNCE_ADVENTUREFAIL = "You win THIS time, Maxwell.",
    ANNOUNCE_MOUNT_LOWHEALTH = "This beast is looking pretty bad.",

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

	ANNOUNCE_BEES = "Aaaah! Pokey bugs!",
	ANNOUNCE_BOOMERANG = "Stupid boomerang!",
	ANNOUNCE_CHARLIE = "I'm not afraid of you!",
	ANNOUNCE_CHARLIE_ATTACK = "OUCH! You jerk!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "The cold! It burns!",
	ANNOUNCE_HOT = "The heat is too intense!",
	ANNOUNCE_CRAFTING_FAIL = "I'm missing something.",
	ANNOUNCE_DEERCLOPS = "That sounded like a big mean monster man!",
	ANNOUNCE_CAVEIN = "I better protect my head!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"The ground's cracking!",
		"Tread carefully!",
		"Earthquake!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Hey, I gotcha something!",
        "Dinnertime!",
        "Great Antlion! Take this tribute, or whatever.",
	},
	ANNOUNCE_SACREDCHEST_YES = "That did it!",
	ANNOUNCE_SACREDCHEST_NO = "Rude.",
    ANNOUNCE_DUSK = "Night is coming. I need fire!",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Yum!",
		PAINFUL = "Ugh! Nasty!",
		SPOILED = "That tasted terrible!",
		STALE = "That was kinda gross.",
		INVALID = "How would I even eat that!",
        YUCKY = "Eeeew, no way!",

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
        "Ughhh!",
        "Why am I doing this...?!",
        "Oooof!!",
        "Unghhh!",
        "There's... no way this is worth it!",
        "My arms feel like they're on fire!",
        "Ughhhh! I'm all sweaty!",
        "This... is... the worst...",
        "I can feel the burn... I hate it!",
        "Exercise... sucks!",
        "Hnnfhg!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"I probably shouldn't be here.",
		"This seems dangerous!",
		"What was that?!",
	},
    ANNOUNCE_RUINS_RESET = "Aw, everything I killed is back!",
    ANNOUNCE_SNARED = "Gross, ew! Bones!",
    ANNOUNCE_SNARED_IVY = "Hey, knock it off!",
    ANNOUNCE_REPELLED = "Hey! That's not fair!",
	ANNOUNCE_ENTER_DARK = "Where'd I put my lighter!?",
	ANNOUNCE_ENTER_LIGHT = "Oh, I can see! I thought I'd gone blind.",
	ANNOUNCE_FREEDOM = "I'm free! Time for fires!",
	ANNOUNCE_HIGHRESEARCH = "So much information!",
	ANNOUNCE_HOUNDS = "Show yourself!",
	ANNOUNCE_WORMS = "I do NOT wanna see what made that sound!",
	ANNOUNCE_HUNGRY = "I need food!",
	ANNOUNCE_HUNT_BEAST_NEARBY = "I'll find you!",
	ANNOUNCE_HUNT_LOST_TRAIL = "Ohh... he got away.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Boooo, I lost track of him in the mud.",
	ANNOUNCE_INV_FULL = "I can only carry so much!!",
	ANNOUNCE_KNOCKEDOUT = "Argh, my little head!",
	ANNOUNCE_LOWRESEARCH = "Boo, that was boring.",
	ANNOUNCE_MOSQUITOS = "Get away, you bloodsucking jerks!",
    ANNOUNCE_NOWARDROBEONFIRE = "Why? This is way better.",
    ANNOUNCE_NODANGERGIFT = "That dumb box can wait!",
    ANNOUNCE_NOMOUNTEDGIFT = "I gotta get down from this big oaf before opening that!",
	ANNOUNCE_NODANGERSLEEP = "No time for sleep, there's fighting to do!",
	ANNOUNCE_NODAYSLEEP = "Who would go inside when there's a great ball of fire in the sky?",
	ANNOUNCE_NODAYSLEEP_CAVE = "Too spooky down here to sleep.",
	ANNOUNCE_NOHUNGERSLEEP = "My tummy is grumbling, I can't sleep!",
	ANNOUNCE_NOSLEEPONFIRE = "It's just the collapsing that concerns me.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "It's kind of hard to sleep with a robot glowing in my face.",
	ANNOUNCE_NODANGERSIESTA = "It's not time for a siesta, it's time for fighting!",
	ANNOUNCE_NONIGHTSIESTA = "I couldn't get comfortable there.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "I'd really rather be inside.",
	ANNOUNCE_NOHUNGERSIESTA = "I can't take a siesta while my tummy is grumbling!",
	ANNOUNCE_NO_TRAP = "Like lighting a barrel of fish on fire.",
	ANNOUNCE_PECKED = "No! Bad birdy!",
	ANNOUNCE_QUAKE = "That sound probably doesn't mean good things.",
	ANNOUNCE_RESEARCH = "That was useful, even if it didn't have anything about fires.",
	ANNOUNCE_SHELTER = "You're good for something besides burning after all.",
	ANNOUNCE_THORNS = "Ouch!",
	ANNOUNCE_BURNT = "I wish I'd let it go up in flames...",
	ANNOUNCE_TORCH_OUT = "My precious light is gone!",
	ANNOUNCE_THURIBLE_OUT = "Awww! I liked that thing.",
	ANNOUNCE_FAN_OUT = "Stupid thing broke!",
    ANNOUNCE_COMPASS_OUT = "Arrgh the needle is stuck!",
	ANNOUNCE_TRAP_WENT_OFF = "Aah!",
	ANNOUNCE_UNIMPLEMENTED = "Gah! That stung ya jerk!",
	ANNOUNCE_WORMHOLE = "I'll have to burn these clothes!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Didja miss me?! Haha!",
	ANNOUNCE_CANFIX = "\nI think I can fix this!",
	ANNOUNCE_ACCOMPLISHMENT = "Move, arrow! MOVE!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I DID IT!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It looks slightly happier.",
	ANNOUNCE_TOOL_SLIP = "Still got my lighter!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "I'm safe from the sky-fire.",
	ANNOUNCE_TOADESCAPING = "Don't even think about running, toad!",
	ANNOUNCE_TOADESCAPED = "Ughh! But I was winning!",


	ANNOUNCE_DAMP = "Uh oh!",
	ANNOUNCE_WET = "This could be bad!",
	ANNOUNCE_WETTER = "I hate it!",
	ANNOUNCE_SOAKED = "Ugh, this is the WORST!",

	ANNOUNCE_WASHED_ASHORE = "Great, now I'm all wet.",

    ANNOUNCE_DESPAWN = "A burning light!",
	ANNOUNCE_BECOMEGHOST = "oOoOooOo!!",
	ANNOUNCE_GHOSTDRAIN = "Burn... It all must burn...",
	ANNOUNCE_PETRIFED_TREES = "Something weird is happening...!",
	ANNOUNCE_KLAUS_ENRAGE = "I'm NOT fighting THAT.",
	ANNOUNCE_KLAUS_UNCHAINED = "Why couldn't it just stay dead?!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Aww man, here come those weird goat things!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Don't worry, I'll get you out.",
		GLASS_LOW = "I can see you!",
		GLASS_REVEAL = "Gotcha!",
		IDOL_MED = "Don't worry, I'll get you out.",
		IDOL_LOW = "I can see you!",
		IDOL_REVEAL = "Gotcha!",
		SEED_MED = "Don't worry, I'll get you out.",
		SEED_LOW = "I can see you!",
		SEED_REVEAL = "Gotcha!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Were those bats, or am I just seeing things.",
	ANNOUNCE_BRAVERY_POTION = "Haha! Those bats don't scare me anymore!",
	ANNOUNCE_MOONPOTION_FAILED = "Huh. Alright then.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Fiiiiiine, I'll share with everyone else.",
	ANNOUNCE_WINTERS_FEAST_BUFF = "It's like there's little sparks flying around me!",
	ANNOUNCE_IS_FEASTING = "Can't talk, must eat.",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Aw man. Guess it's time to get some real sparks flying!",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Hey! Get back up!",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "You got this!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Thanks for the hand!",

    ANNOUNCE_FLARE_SEEN = "Woah, cool! Someone shot fire into the sky!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Something big's coming!",

    --willow specific
	ANNOUNCE_LIGHTFIRE =
	{
		"Tee hee!",
		"Pretty!",
		"Oops!",
		"I made a fire!",
		"Burn!",
		"I can't help myself!",
    },

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Okay, so that didn't work.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Whoops, burnt it. Heh heh.",
    QUAGMIRE_ANNOUNCE_LOSE = "I think it's angry!!",
    QUAGMIRE_ANNOUNCE_WIN = "Let's get out of here!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I've never tried using electricity to start fires!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "You wanna fight?!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "Come at me, jerks!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Where did all this motivation come from?!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Ha! Take that, water!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Yeah! I'll stay awake forever!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "I like setting fires the old fashioned way, anyhow.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Nooo I still had more hitting I wanted to do!",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Might not be the best time to pick a fight.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Welp. The motivation didn't last.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Ugh. Back to watching out for puddles.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "No! I don't wanna feel tired yet!",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Hey! That dumb fish stole my tackle!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "Better start reeling or it's gonna get away!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "Ugh! Stupid! Fish!",
	ANNOUNCE_OCEANFISHING_BADCAST = "This really isn't my thing.",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"This is BORING.",
		"Ugh. Can't this go any faster?",
		"Come on, you stupid fish!",
		"I could be setting so many fires right now.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nUgh, this thing's heavy!",

	ANNOUNCE_WINCH_CLAW_MISS = "Aw, come on! I was close enough!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "Looks like I caught a whole lot of nothing.",

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
    ANNOUNCE_WEAK_RAT = "That thing's looking kinda rough.",

    ANNOUNCE_CARRAT_START_RACE = "Alright, let's win that prize!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "You dumb Carrat, you're going the wrong way!",
        "Hey! The finish line's THAT way!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Hey! WAKE UP!!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Um, can we maybe go a bit faster?!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "Not so good with the reflexes, huh?",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Owww...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Ugh, it's filling my head with nerd junk!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "Meh. Seen it before.",
    ANNOUNCE_ARCHIVE_NO_POWER = "Well that was exciting.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "Greeaaat, more boring old plant facts.",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "I guess we'll see what happens.",

    ANNOUNCE_FERTILIZER_RESEARCHED = "Wow, so interesting. Glad I spent my time learning that and not doing literally anything else.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Argh, it burns!! But not in a fun way!",
		"There's fire in my veins!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Huh. I was kind of getting used to it.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Hey plants! How's it going?",
        "Feeling flammable today?",
		"So... plant stuff... man, this is boring.",
        "Anything interesting going on lately? Right, nope. Because you're a plant.",
        "Hey, rustle twice if you want to take a closer look at my lighter!",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Ready or not, here I come!!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Alright everyone, stand aside and watch the master work!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Found you!!",
		"Ha ha, your tail gave you away!",
		"Spotted!",
		"Gotcha!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "One more to go!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "That was the last of em'!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "Aw, {name} got to the last one before I did.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "We're about to lose, we gotta find the rest!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "I want a rematch!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "You really think those little guys would hide this far out?",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Seems more likely there'd be kitcoons hiding around here.",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Aww, what are you doing out here all alone?",

	ANNOUNCE_TICOON_START_TRACKING	= "He's got the scent! Go, big guy, go!",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "He's got nothin'.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Yeah, yeah, I'm comin'!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "What is it? Kit's stuck in a well?",
	ANNOUNCE_TICOON_NEAR_KITCOON = "Seems like he's onto somethin'...",
	ANNOUNCE_TICOON_LOST_KITCOON = "Guess we were a second too late to this one.",
	ANNOUNCE_TICOON_ABANDONED = "Ah, who needs ya! I can find them on my own.",
	ANNOUNCE_TICOON_DEAD = "Great. What am I supposed to do now?",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Hey beefalo! Get over here!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "How would the judge even see my beefalo this far away?",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "I think I could make a new beefalo costume now.",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Eww, it popped out!!",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Did you come back just to get BURNED?",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Coward, stop running away!!",

	BATTLECRY =
	{
		GENERIC = "It's you or me!",
		PIG = "Stupid pig!",
		PREY = "Get over here!",
		SPIDER = "Grrrrar!",
		SPIDER_WARRIOR = "Ew, kill iiiit!",
		DEER = "You're deer meat!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "That's what I thought!",
		PIG = "Get back here, pork chop!",
		PREY = "I'll get you next time!",
		SPIDER = "Bleh. I'll kill him later.",
		SPIDER_WARRIOR = "Not so tough now!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "The vines coil away from my lighter... weird!",
        MULTIPLAYER_PORTAL_MOONROCK = "It's made of some kind of jerk rock I can't burn.",
        MOONROCKIDOL = "Looks like a jerk.",
        CONSTRUCTION_PLANS = "I'd rather burn things down than build them up.",

        ANTLION =
        {
            GENERIC = "What do you want?!",
            VERYHAPPY = "You're in a good mood.",
            UNHAPPY = "There's gonna be tremors in our future.",
        },
        ANTLIONTRINKET = "Buncha junk.",
        SANDSPIKE = "Burn it!",
        SANDBLOCK = "Buuurn!",
        GLASSSPIKE = "I can't believe that worked!",
        GLASSBLOCK = "See? Fire solves everything.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Looks flammable.",
			LEVEL1 = "Ugh, it's weird!",
			LEVEL2 = "Burning is still an option.",
			LEVEL3 = "Yeah sure, it's floating now, why not.",

			-- deprecated
            LONG = "Looks flammable.",
            MEDIUM = "Ugh, it's weird!",
            SOON = "Burning is still an option.",
            HAUNTED_POCKET = "It's burning a hole in my pocket. Heh.",
            HAUNTED_GROUND = "I don't want to mess with that.",
        },

        BALLOONS_EMPTY = "I could fill them with flammable gas.",
        BALLOON = "That's just asking to be popped.",
		BALLOONPARTY = "Hey, when are you gonna make a hot air balloon? I could help!",
		BALLOONSPEED =
        {
            DEFLATED = "No flying away!",
            GENERIC = "Thanks! I'll be able to set fires twice as fast with this thing!",
        },
		BALLOONVEST = "Squeak-squeak-squeak! Ha ha where's Maxwell, this'll drive him crazy!",
		BALLOONHAT = "Hey, a rabbit! Not bad!",

        BERNIE_INACTIVE =
        {
            BROKEN = "I need to fix Bernie up.",
            GENERIC = "My childhood buddy - Bernie!",
        },

        BERNIE_ACTIVE = "Help me, Bernie!",
        BERNIE_BIG = "GET'EM, BERNIE!!",

        BOOK_BIRDS = "Less reading, more burning!",
        BOOK_TENTACLES = "Looks like kindling to me!",
        BOOK_GARDENING = "Ughh, who cares?",
		BOOK_SILVICULTURE = "Hey, it's a book about kindling!",
		BOOK_HORTICULTURE = "Ughh, who cares?",
        BOOK_SLEEP = "Bo-oring!",
        BOOK_BRIMSTONE = "That's my favorite book!",

        PLAYER =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Why, %s... that fire in your eyes!",
            MURDERER = "Burn the murderer!",
            REVIVER = "Who do ghosts call? %s!",
            GHOST = "I better get a heart for %s.",
            FIRESTARTER = "BUUURN!",
        },
        WILSON =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Why, %s... that fire in your eyes!",
            MURDERER = "Hey %s! Your hair is dumb! Raaaugh!",
            REVIVER = "%s won't leave anyone behind.",
            GHOST = "I better get a heart for %s.",
            FIRESTARTER = "Oh, %s!! Let me help with your next fire!!",
        },
        WOLFGANG =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "%s! Take it easy, big guy!",
            MURDERER = "Burn the murderer!",
            REVIVER = "Woah! %s ripped a spirit straight out of the afterlife!",
            GHOST = "Hey %s, did you know the heart's a muscle?",
            FIRESTARTER = "Don't hurt yourself, big guy.",
        },
        WAXWELL =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "There's evil in you, huh %s?!",
            MURDERER = "%s! I knew you couldn't be trusted! Burn!!",
            REVIVER = "Hahaha %s, you care about us!",
            GHOST = "Have a heart, %s! Heh heh.",
            FIRESTARTER = "Amateur.",
        },
        WX78 =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Better cool it before you blow a gasket, %s!",
            MURDERER = "Killer robot! Burn it!",
            REVIVER = "Hahaha %s, you care about us!",
            GHOST = "I better get a heart for %s.",
            FIRESTARTER = "Are we lighting fires?! I want in!",
        },
        WILLOW =
        {
            GENERIC = "Hey! That's my face, %s! Give it back!",
            ATTACKER = "You're makin' us look nuts, %s!",
            MURDERER = "Murderer! Burn the impostor!",
            REVIVER = "Haha, nice one %s.",
            GHOST = "Is that really what my ghost hair looks like?",
            FIRESTARTER = "Burny twins! High five.",
        },
        WENDY =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "I've never seen you so, uh, passionate... %s.",
            MURDERER = "She's gone nuts! Murderer!",
            REVIVER = "That girl really likes ghosts!",
            GHOST = "Isn't death kind of your thing, %s?",
            FIRESTARTER = "%s! Was that your fire? I'm so proud!",
        },
        WOODIE =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "You're only fueling the fire, %s!",
            MURDERER = "Murderer. BURN!",
            REVIVER = "Is there maple syrup in your veins, %s? You're so sweet!",
            GHOST = "I better get a heart for %s.",
            BEAVER = "Calm down, %s. Wanna borrow Bernie?",
            BEAVERGHOST = "%s! That was hilarious!",
            MOOSE = "You've gotta be kidding me.",
            MOOSEGHOST = "Why the long face? Ha!",
            GOOSE = "Ha! You're a hoot, %s. Or is it a honk?",
            GOOSEGHOST = "Don't be such a down-er, I'll get you a heart.",
            FIRESTARTER = "Burn it all, %s! Burn it!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Your bun too tight, %s?",
            MURDERER = "Time for a good ol' book burnin'! Murderer!",
            REVIVER = "%s is a big softie!",
            GHOST = "Did your heart give out, %s? Just kidding! Hey!",
            FIRESTARTER = "Didn't know you had it in you, %s.",
        },
        WES =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "That mime punch was really convincing! Haha, ow!",
            MURDERER = "Your actions speak louder than words! Murderer!",
            REVIVER = "Who do ghosts call? %s!",
            GHOST = "Just tell me whatcha need and I'll get it for you. Heheh!",
            FIRESTARTER = "Make it BURN!",
        },
        WEBBER =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Hey %s, you're not venomous, are you?",
            MURDERER = "Monster! Burn them!",
            REVIVER = "Who do ghosts call? %s!",
            GHOST = "Don't cry, %s, I'm getting you a heart.",
            FIRESTARTER = "Your fires are so cute, %s!",
        },
        WATHGRITHR =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Take it down a notch, %s!",
            MURDERER = "Woahh! That's not an act! Murderer!",
            REVIVER = "%s doesn't let anyone fall in battle!",
            GHOST = "Hey %s, I'll get you a heart if you let me wear your helm!",
            FIRESTARTER = "Yes, %s! Burn!!!",
        },
        WINONA =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Too rough, %s! Jeez!",
            MURDERER = "Murderer! Now you burn!",
            REVIVER = "%s never gives up on anyone.",
            GHOST = "A heart sure would come in handy!",
            FIRESTARTER = "Nice fire, %s!",
        },
        WORTOX =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "You're supposed to prank everyone else, not ME.",
            MURDERER = "Monster! Murderer! BURN!",
            REVIVER = "I guess %s isn't all mischief.",
            GHOST = "You're looking a little pale there, red.",
            FIRESTARTER = "Haha, YES! %s!!",
        },
        WORMWOOD =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Hey! Keep those creepin' vines to yourself!",
            MURDERER = "I'm gonna burn you like tinder!",
            REVIVER = "Hey, thanks a bunch there, %s!",
            GHOST = "I think %s needs some help.",
            FIRESTARTER = "You've got a lot of guts for a plant. I like that!",
        },
        WARLY =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "%s has been serving up knuckle sandwiches.",
            MURDERER = "I'm gonna smoke you like a ham!",
            REVIVER = "%s would never leave anyone behind.",
            GHOST = "Did you mean to do that?",
            FIRESTARTER = "Haha, nice one, %s!!",
        },

        WURT =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "You're a real little terror, aren't you?",
            MURDERER = "Don't make me snuff you out!",
            REVIVER = "Thanks for the hand, %s... or, uh, claw?",
            GHOST = "Yeesh, what happened to you?",
            FIRESTARTER = "Heh, 'attagirl!",
        },

        WALTER =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "That goody-goody finally snapped!",
            MURDERER = "Hey %s, let's talk about this...",
            REVIVER = "Alright, I'm sorry for calling you a goody-goody.",
            GHOST = "I think he's actually having fun.",
            FIRESTARTER = "Who \"doesn't know fire safety\" NOW, %s?",
        },

        WANDA =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Hey, watch it!",
            MURDERER = "Your future just went up in smoke, murderer!",
            REVIVER = "%s is always there when we need her.",
            GHOST = "Uh... I'm guessing something went wrong.",
            FIRESTARTER = "Hey %s! Leave some kindling for me!",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "It's fuzzy! And slimy...",
            SLEEPING = "Alright, I guess it's kind of cute.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Why does everything have to be a flower?!",
            DEAD = "I wonder if it burns...",
        },
        GLOMMERWINGS = "They're so small!",
        GLOMMERFUEL = "It's goopy and weird.",
        BELL = "Is it New Year's Eve? Are there FIREWORKS?!",
        STATUEGLOMMER =
        {
            GENERIC = "Is that supposed to be something?",
            EMPTY = "Looks about the same.",
        },

        LAVA_POND_ROCK = "Oh great, another stinkin' rock!",

		WEBBERSKULL = "It's not myyy way, but a burial will have to do.",
		WORMLIGHT = "Light without fire. Unnatural.",
		WORMLIGHT_LESSER = "It feels like grandma's hands.",
		WORM =
		{
		    PLANT = "Light without fire. Unnatural.",
		    DIRT = "Does dirt normally move around?",
		    WORM = "It's so furry!",
		},
        WORMLIGHT_PLANT = "Light without fire. Unnatural.",
		MOLE =
		{
			HELD = "Out of the ground, into the fire.",
			UNDERGROUND = "Hiding from the light, huh?",
			ABOVEGROUND = "Coming up for a peek!",
		},
		MOLEHILL = "It burrows away from the sun's skyfire. Unnatural.",
		MOLEHAT = "I'm not sure about this...",

		EEL = "I don't like the look it's giving me!",
		EEL_COOKED = "Fire improves everything.",
		UNAGI = "You can make it fancy but it's still an eel.",
		EYETURRET = "I wish it lit stuff on fire.",
		EYETURRET_ITEM = "It's no good until it's been placed.",
		MINOTAURHORN = "I wonder if the rings are an indication of age.",
		MINOTAURCHEST = "I want big horns like that!",
		THULECITE_PIECES = "This Thulecite crumbled to pieces.",
		POND_ALGAE = "It must need a lot of water.",
		GREENSTAFF = "It won't start a fire but I guess it's still useful.",
		GIFT = "It's for me right?!",
        GIFTWRAP = "Ribbons burn real good!",
		POTTEDFERN = "I'd rather burn them.",
        SUCCULENT_POTTED = "We're keeping it.",
		SUCCULENT_PLANT = "It's a small, unburned plant.",
		SUCCULENT_PICKED = "It's been picked.",
		SENTRYWARD = "Pfft. It'll burn like the rest.",
        TOWNPORTAL =
        {
			GENERIC = "Magic stuff.",
			ACTIVE = "Walking's for suckers.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "Yuck. It smells like sulfur.",
			ACTIVE = "I didn't wanna walk, anyway.",
		},
        WETPAPER = "I can think of a real quick way to dry it.",
        WETPOUCH = "There's something inside.",
        MOONROCK_PIECES = "Oh look! ROCKS! Ughhhhh!",
        MOONBASE =
        {
            GENERIC = "It's expecting something from me.",
            BROKEN = "Oh look, a bunch of smashed up rocks!",
            STAFFED = "Hurry up already, stupid rock!",
            WRONGSTAFF = "That's obviously completely wrong.",
            MOONSTAFF = "Ughh! It's doing the exact opposite of burning!",
        },
        MOONDIAL =
        {
			GENERIC = "What the heck? I can still see the moon!",
			NIGHT_NEW = "A new moon! Great, I hated the old one!",
			NIGHT_WAX = "The moon is waxing, unlike me.",
			NIGHT_FULL = "That's as full as it gets.",
			NIGHT_WANE = "The moon's outta here!",
			CAVE = "Doesn't work down here.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "I feel like it's staring at me.",
        },
		THULECITE = "I don't think it would burn.",
		ARMORRUINS = "Human beings probably shouldn't wear this.",
		ARMORSKELETON = "Can't hit me in this thing!",
		SKELETONHAT = "I've got a headache just looking at it.",
		RUINS_BAT = "This will keep the nasties at bay.",
		RUINSHAT = "It seems like there's something flowing through it.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Looks normal to me.",
            WARN = "It's warning me.",
            WAXING = "The fuel is coming to life!",
            STEADY = "It's almost humming.",
            WANING = "I think it's turning off.",
            DAWN = "I guess it's nearly over.",
            NOMAGIC = "I don't think it's working.",
		},
		BISHOP_NIGHTMARE = "Ahhh!",
		ROOK_NIGHTMARE = "It has a nasty smile.",
		KNIGHT_NIGHTMARE = "It looks pretty worn down.",
		MINOTAUR = "Poor thing. Trapped in this maze.",
		SPIDER_DROPPER = "They come from above.",
		NIGHTMARELIGHT = "Light without fire is unnatural.",
		NIGHTSTICK = "It'd be way cooler if it was on fire...",
		GREENGEM = "This one feels really light.",
		MULTITOOL_AXE_PICKAXE = "It's so useful!",
		ORANGESTAFF = "It gives me a headache.",
		YELLOWAMULET = "It seems to absorb the darkness around it.",
		GREENAMULET = "I feel my mind opening when I wear it.",
		SLURPERPELT = "Eeewwwww, it's still alive!",

		SLURPER = "Do they have little fires in their bellies?",
		SLURPER_PELT = "Eeewwwww, it's still alive!",
		ARMORSLURPER = "Oh, ick! Ick! Ick! Ick! Eeeeeewwwwww!",
		ORANGEAMULET = "It picks up burning materials!",
		YELLOWSTAFF = "It's magical.",
		YELLOWGEM = "It sparkles.",
		ORANGEGEM = "It'll make your fingers tingle.",
        OPALSTAFF = "Gotta hold it with my sleeve so my hands don't get cold.",
        OPALPRECIOUSGEM = "It's glittery and mesmerizing, like a fire!",
        TELEBASE =
		{
			VALID = "I can feel the magic!",
			GEMS = "It needs something more.",
		},
		GEMSOCKET =
		{
			VALID = "I wonder how they hover?",
			GEMS = "It's so empty!",
		},
		STAFFLIGHT = "It's so beautiful!",
        STAFFCOLDLIGHT = "Boo! Hissss!",

        ANCIENT_ALTAR = "Oooo! An afterlife intercom.",

        ANCIENT_ALTAR_BROKEN = "The dead can't get through here.",

        ANCIENT_STATUE = "Drat, won't burn.",

        LICHEN = "A gross, crusty plant.",
		CUTLICHEN = "Blah, tastes like sawdust.",

		CAVE_BANANA = "Bananas!",
		CAVE_BANANA_COOKED = "Yum!",
		CAVE_BANANA_TREE = "Looks burnable!",
		ROCKY = "We don't have much in common.",

		COMPASS =
		{
			GENERIC="Can't get a reading.",
			N = "North!",
			S = "South!",
			E = "East!",
			W = "West...",
			NE = "Northeast!",
			SE = "Southeast!",
			NW = "Northwest!",
			SW = "Southwest!",
		},

        HOUNDSTOOTH = "It's sharp. I like it!",
        ARMORSNURTLESHELL = "Less defense! More offense!",
        BAT = "Cute little guy!",
        BATBAT = "That thing's great for batting at enemies.",
        BATWING = "Yuck!",
        BATWING_COOKED = "Still yuck!",
        BATCAVE = "What would happen if I dropped a match in there?",
        BEDROLL_FURRY = "It's too frilly.",
        BUNNYMAN = "Ugh. They look so stupid.",
        FLOWER_CAVE = "It's burning inside.",
        GUANO = "It burns like normal poop.",
        LANTERN = "Fire is not meant to be contained like this!",
        LIGHTBULB = "It's called a \"lightbulb\" but it's kinda heavy.",
        MANRABBIT_TAIL = "The rabbits lost that argument.",
        MUSHROOMHAT = "I don't like having my head messed with.",
        MUSHROOM_LIGHT2 =
        {
            ON = "Pfft, well that was a bright idea.",
            OFF = "I've got a few ideas on how to light it. Heh heh.",
            BURNT = "Now what?",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Not as nice as a warm fire.",
            OFF = "This dumb mushroom's not lighting up.",
            BURNT = "C'mon, you saw that coming.",
        },
        SLEEPBOMB = "Who's ready for a nap!",
        MUSHROOMBOMB = "She's gonna blow!",
        SHROOM_SKIN = "Ew! Burn that!",
        TOADSTOOL_CAP =
        {
            EMPTY = "It's a hole, what do you want from me?",
            INGROUND = "What is that? It's smelly.",
            GENERIC = "A mutant mushroom! I want it!",
        },
        TOADSTOOL =
        {
            GENERIC = "It's covered in nasty warts and fungus!!",
            RAGE = "Woah! It's packing a punch now!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "A big gross mushroom! Burn it!",
            BURNT = "How could that not work?!",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "Gross. This tree is sick all over.",
            BLOOM = "Ack! It stinks!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Gross. It smells like leprechaun butt.",
            BLOOM = "It's spreading junk everywhere.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Gross. It's all mushroomy.",
            BLOOM = "Ew, I don't want to get too close.",
        },
        MUSHTREE_TALL_WEBBED = "That one got what it deserves.",
        SPORE_TALL =
        {
            GENERIC = "It's like colorful sparks!",
            HELD = "It feels flammable.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "It's like floating fire!",
            HELD = "It feels flammable.",
        },
        SPORE_SMALL =
        {
            GENERIC = "It has no idea where it's going.",
            HELD = "It feels flammable.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Ugh. Stupid rabbits.",
            BURNT = "Ha! Good result.",
        },
        SLURTLE = "I want to blow it up!",
        SLURTLE_SHELLPIECES = "Heh. It broke.",
        SLURTLEHAT = "It's perfectly head-shaped.",
        SLURTLEHOLE = "I should burn them out.",
        SLURTLESLIME = "I love this stuff!",
        SNURTLE = "Kaboom!",
        SPIDER_HIDER = "What a frustrating jerk!",
        SPIDER_SPITTER = "Get over here!",
        SPIDERHOLE = "It's full of spiders.",
        SPIDERHOLE_ROCK = "It's full of spiders.",
        STALAGMITE = "Rocks are boring.",
        STALAGMITE_TALL = "More boring rocks.",

        TURF_CARPETFLOOR = "The ground is boring.",
        TURF_CHECKERFLOOR = "The ground is boring.",
        TURF_DIRT = "The ground is boring.",
        TURF_FOREST = "The ground is boring.",
        TURF_GRASS = "The ground is boring.",
        TURF_MARSH = "The ground is boring.",
        TURF_METEOR = "The ground is boring.",
        TURF_PEBBLEBEACH = "The ground is boring.",
        TURF_ROAD = "The ground is boring.",
        TURF_ROCKY = "The ground is boring.",
        TURF_SAVANNA = "The ground is boring.",
        TURF_WOODFLOOR = "The ground is boring.",

		TURF_CAVE="The ground is boring.",
		TURF_FUNGUS="The ground is boring.",
		TURF_FUNGUS_MOON = "The ground is boring.",
		TURF_ARCHIVE = "The ground is boring.",
		TURF_SINKHOLE="The ground is boring.",
		TURF_UNDERROCK="The ground is boring.",
		TURF_MUD="The ground is boring.",

		TURF_DECIDUOUS = "The ground is boring.",
		TURF_SANDY = "The ground is boring.",
		TURF_BADLANDS = "The ground is boring.",
		TURF_DESERTDIRT = "The ground is boring.",
		TURF_FUNGUS_GREEN = "The ground is boring.",
		TURF_FUNGUS_RED = "The ground is boring.",
		TURF_DRAGONFLY = "My lighter doesn't work on it.",

        TURF_SHELLBEACH = "The ground is boring.",

		POWCAKE = "I wonder if it is flammable.",
        CAVE_ENTRANCE = "Who plugged that hole?",
        CAVE_ENTRANCE_RUINS = "Who plugged that hole?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "I don't want to go in that gross hole!",
            OPEN = "I hope there's lava down there somewhere.",
            FULL = "There's too many people down there.",
        },
        CAVE_EXIT =
        {
            GENERIC = "It's cooler down here, anyway.",
            OPEN = "It's too dark and stuffy down here.",
            FULL = "There's too many people up there.",
        },

		MAXWELLPHONOGRAPH = "I like more exciting music.",--single player
		BOOMERANG = "It's not the most exciting weapon.",
		PIGGUARD = "I like his attitude!",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "So, what happened to you?",
                "So, what happened to you?",
            },
            LEVEL2 =
            {
                "So, what happened to you?",
                "So, what happened to you?",
            },
            LEVEL3 =
            {
                "So, what happened to you?",
                "So, what happened to you?",
            },
		},
		ADVENTURE_PORTAL = "Maybe that leads home.",
		AMULET = "I have no idea what it does, but it feels good to wear it!",
		ANIMAL_TRACK = "It leads to my new friend.",
		ARMORGRASS = "A waste of flammable materials.",
		ARMORMARBLE = "If you're gonna fight you might as well be protected.",
		ARMORWOOD = "Now I can take on the world!",
		ARMOR_SANITY = "Like being wrapped in smoke.",
		ASH =
		{
			GENERIC = "Leftovers from a fire. I wish it was still here.",
			REMAINS_GLOMMERFLOWER = "I wish I saw the way that weird flower burned.",
			REMAINS_EYE_BONE = "I bet that eye thing was quite a sight wreathed in fire!",
			REMAINS_THINGIE = "I wish this thing was still burning, whatever it was.",
		},
		AXE = "It's very sharp.",
		BABYBEEFALO =
		{
			GENERIC = "Even the babies are ugly.",
		    SLEEPING = "WAKE UP!",
        },
        BUNDLE = "Now I can burn a bunch of things in one go!",
        BUNDLEWRAP = "We could hide some gross things, I guess.",
		BACKPACK = "You could fit like a million lighters in here.",
		BACONEGGS = "The yellow mucus-y part is gross, but the bacon is great!",
		BANDAGE = "Eww, no!",
		BASALT = "It's too hard to break!", --removed
		BEARDHAIR = "Clean up your gross hair guys! Ugh!",
		BEARGER = "Whoa! Niiiice bear...",
		BEARGERVEST = "It's like swimming in fur.",
		ICEPACK = "Fuzzy backpack!",
		BEARGER_FUR = "It's fur all the way down.",
		BEDROLL_STRAW = "Musty.",
		BEEQUEEN = "No amount of honey is worth THAT!",
		BEEQUEENHIVE =
		{
			GENERIC = "It all came from a bee's butt.",
			GROWING = "Ew, burn it before it gets any bigger!",
		},
        BEEQUEENHIVEGROWN = "Dare you guys to smack it with a hammer.",
        BEEGUARD = "Puffy flying jerk!",
        HIVEHAT = "That bee's head looks kinda tasty, doesn't it?",
        MINISIGN =
        {
            GENERIC = "Haha oh man, who drew THAT?",
            UNDRAWN = "Looks kinda bare.",
        },
        MINISIGN_ITEM = "It's like a sign, but smaller.",
		BEE =
		{
			GENERIC = "It's fat, but that stinger looks dangerous.",
			HELD = "Pocket full of bees!",
		},
		BEEBOX =
		{
			READY = "Yay! Let's steal honey!",
			FULLHONEY = "Yay! Let's steal honey!",
			GENERIC = "Come on fat bees, make honey!",
			NOHONEY = "Nothing to see here.",
			SOMEHONEY = "Patience.",
			BURNT = "Smoked you out!",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Geez, who even needs that many mushrooms?",
			LOTS = "Gross, they're taking over!",
			SOME = "There's mushrooms growing in it now.",
			EMPTY = "It's just a dumb log.",
			ROTTEN = "Nasty. Let's burn the rot out.",
			BURNT = "Mold problem's taken care of.",
			SNOWCOVERED = "I'm sure fire would fix that.",
		},
		BEEFALO =
		{
			FOLLOWER = "Er, are you following me?",
			GENERIC = "What a disgusting, hairy beast!",
			NAKED = "Ha! He's all naked now!",
			SLEEPING = "They look even dumber when they're sleeping.",
            --Domesticated states:
            DOMESTICATED = "It's lost the fire from its heart.",
            ORNERY = "I can see fire in its eyes.",
            RIDER = "Let's go!",
            PUDGY = "You need to burn some calories.",
            MYPARTNER = "It may be a dumb stinky beast, but it's my dumb stinky beast!",
		},

		BEEFALOHAT = "Beast hair to go over people hair!",
		BEEFALOWOOL = "Ha! Its owner is probably naked somewhere. Or dead.",
		BEEHAT = "This will keep the pokeys off of me.",
        BEESWAX = "That's none of my beeswax.",
		BEEHIVE = "It's full of bees!",
		BEEMINE = "Bees inside. Should've put some fire in there for good measure.",
		BEEMINE_MAXWELL = "Mosquitoes inside. They don't sound happy.",--removed
		BERRIES = "Red berries taste the best.",
		BERRIES_COOKED = "Red berries with fire somehow taste even better.",
        BERRIES_JUICY = "Mmm. They pop in your mouth.",
        BERRIES_JUICY_COOKED = "Fire improves everything.",
		BERRYBUSH =
		{
			BARREN = "Eat poop, stupid plant!",
			WITHERED = "All dried out. Primed for fire!",
			GENERIC = "Mmmmm. Berries.",
			PICKED = "But I want more berries!",
			DISEASED = "Burn the sick!",--removed
			DISEASING = "Blech. You smell.",--removed
			BURNING = "Yes!! Burn!!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Did I say you could stop growing?!",
			WITHERED = "It's burning up.",
			GENERIC = "Ready for picking!",
			PICKED = "Make mooooore!",
			DISEASED = "Burn the sick!",--removed
			DISEASING = "Blech. You smell.",--removed
			BURNING = "Yes!! Burn!!",
		},
		BIGFOOT = "What in the world!",--removed
		BIRDCAGE =
		{
			GENERIC = "Bird prison!",
			OCCUPIED = "Ha! Gotcha now!",
			SLEEPING = "Stupid bird. Wake up!",
			HUNGRY = "What's all the fuss about?",
			STARVING = "He won't be quiet!",
			DEAD = "At least he's quiet now.",
			SKELETON = "That should probably be cleaned up.",
		},
		BIRDTRAP = "Gonna catch those creepy birds.",
		CAVE_BANANA_BURNT = "That's all I wanted!",
		BIRD_EGG = "It smells like a bird's butt.",
		BIRD_EGG_COOKED = "Yuck. The yellow part is all runny.",
		BISHOP = "It's a bishop!",
		BLOWDART_FIRE = "That's my favorite thing in the whole wide world.",
		BLOWDART_SLEEP = "Tranquilized things are easier to light on fire.",
		BLOWDART_PIPE = "Good practice for blowing into a fire.",
		BLOWDART_YELLOW = "Lightning is sort of like fire.",
		BLUEAMULET = "Boo to this.",
		BLUEGEM = "Ugh. This one is ugly.",
		BLUEPRINT =
		{
            COMMON = "This will save some experimentation.",
            RARE = "Woah. It doesn't burn!!",
        },
        SKETCH = "Trading diagrams is for dorks.",
		BLUE_CAP = "It smells like a gym sock!",
		BLUE_CAP_COOKED = "Transformed by fire!",
		BLUE_MUSHROOM =
		{
			GENERIC = "Dumb mushroom.",
			INGROUND = "Hey! You! Get up here!",
			PICKED = "Maybe it will return some day.",
		},
		BOARDS = "Boards. They'll burn, same as other wood.",
		BONESHARD = "I don't think they make good tinder.",
		BONESTEW = "Just add fire to food and voila!",
		BUGNET = "Doesn't fit over Webber's big head.",
		BUSHHAT = "Too passive!",
		BUTTER = "Tasty, and just a little bit insecty.",
		BUTTERFLY =
		{
			GENERIC = "Flutter away, butterfly!",
			HELD = "I want to squish it.",
		},
		BUTTERFLYMUFFIN = "Heehee, look at that butterfly stuck in the muffin.",
		BUTTERFLYWINGS = "No more flying for that butterfly!",
		BUZZARD = "Your neck is gross.",

		SHADOWDIGGER = "Eww, it's even creepier than the real one.",

		CACTUS =
		{
			GENERIC = "Spines! My weakness! How did you know?",
			PICKED = "We'll call it a tie.",
		},
		CACTUS_MEAT_COOKED = "It seems fine now.",
		CACTUS_MEAT = "It still looks dangerous.",
		CACTUS_FLOWER = "Yet another flower.",

		COLDFIRE =
		{
			EMBERS = "Uh oh. It's almost gone!",
			GENERIC = "I like fire of all kinds.",
			HIGH = "BURN! BURN FASTER! AND BLUER!",
			LOW = "This fire is small and boring.",
			NORMAL = "Burn!",
			OUT = "Awww. It's all over.",
		},
		CAMPFIRE =
		{
			EMBERS = "Uh oh. It's almost gone!",
			GENERIC = "I like fire.",
			HIGH = "BURN! BURN FASTER!",
			LOW = "This fire is small and boring.",
			NORMAL = "Burn!",
			OUT = "Awww. It's all over.",
		},
		CANE = "It's way easier to cover ground with this!",
		CATCOON = "Here, kitty!",
		CATCOONDEN =
		{
			GENERIC = "I wouldn't burn it while someone lives there.",
			EMPTY = "It's all dried up and ready for burning.",
		},
		CATCOONHAT = "Cuddly hat.",
		COONTAIL = "I've kept stranger things than that.",
		CARROT = "Yuck. It's all vegetabley.",
		CARROT_COOKED = "Still vegetabley, but better for having been in fire.",
		CARROT_PLANTED = "Maybe its special carrot friend is in the ground.",
		CARROT_SEEDS = "Some seeds.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "I guess I could show everyone where I've been.",
			BURNING = "Yes!!",
			BURNT = "Scouts don't need maps, anyway.",
		},
		WATERMELON_SEEDS = "I could grow them, but that sounds boring.",
		CAVE_FERN = "Looks flammable.",
		CHARCOAL = "Mmmm. Smells like fire.",
        CHESSPIECE_PAWN = "What sort of peasant doesn't have a torch?!",
        CHESSPIECE_ROOK =
        {
            GENERIC = "That one looks like it could do some damage.",
            STRUGGLE = "I don't wanna see what comes outta that!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "A horse with no butt.",
            STRUGGLE = "I don't wanna see what comes outta that!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Just some dumb bishop piece.",
            STRUGGLE = "I don't wanna see what comes outta that!",
        },
        CHESSPIECE_MUSE = "Ewww, she doesn't have a head!",
        CHESSPIECE_FORMAL = "I'm not afraid of that guy. He doesn't even have arms!",
        CHESSPIECE_HORNUCOPIA = "Ouchhh! I think I chipped a tooth.",
        CHESSPIECE_PIPE = "I prefer smokey fires.",
        CHESSPIECE_DEERCLOPS = "We kicked its butt.",
        CHESSPIECE_BEARGER = "Those are some pointy teeth.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Looks as dumb as the real thing.",
        },
        CHESSPIECE_DRAGONFLY = "I think... I think I understand art.",
		CHESSPIECE_MINOTAUR = "Pfft, I never needed a guardian. And I turned out fine!",
        CHESSPIECE_BUTTERFLY = "Meh. I can't even burn it.",
        CHESSPIECE_ANCHOR = "It's hard to burn stuff at sea.",
        CHESSPIECE_MOON = "I guess it's nice.",
        CHESSPIECE_CARRAT = "Now all I can think of is roasted carrots.",
        CHESSPIECE_MALBATROSS = "She was a pretty tough old bird.",
        CHESSPIECE_CRABKING = "Was the treasure worth it?",
        CHESSPIECE_TOADSTOOL = "What are you looking at?",
        CHESSPIECE_STALKER = "Not so tough now, are you?",
        CHESSPIECE_KLAUS = "Haha, you can't get me now.",
        CHESSPIECE_BEEQUEEN = "Took the sting out of her stinger.",
        CHESSPIECE_ANTLION = "Can't shake anything up like that.",
        CHESSPIECE_BEEFALO = "Hey, they got his good side!",
		CHESSPIECE_KITCOON = "I wanna push it over.",
		CHESSPIECE_CATCOON = "Heh. I like this one.",
        CHESSPIECE_GUARDIANPHASE3 = "Ugh, I'd be happy never seeing that thing again.",
        CHESSPIECE_EYEOFTERROR = "I still feel an evil presence watching me...",
        CHESSPIECE_TWINSOFTERROR = "Great, another creepy statue.",

        CHESSJUNK1 = "Dead windup horsey.",
        CHESSJUNK2 = "Dead windup priest.",
        CHESSJUNK3 = "Dead windup castle.",
		CHESTER = "He's so fuzzy!",
		CHESTER_EYEBONE =
		{
			GENERIC = "It's rude to stare.",
			WAITING = "At least it's not looking at me anymore.",
		},
		COOKEDMANDRAKE = "The fire didn't get rid of its face. Gives me the willies.",
		COOKEDMEAT = "Unseasoned meat... great.",
		COOKEDMONSTERMEAT = "It's still gross.",
		COOKEDSMALLMEAT = "Gonna need a lot of appetizers to survive out here!",
		COOKPOT =
		{
			COOKING_LONG = "The fire still has quite a bit of work to do.",
			COOKING_SHORT = "The fire is doing its thing!",
			DONE = "Fire makes everything better. Mmm!",
			EMPTY = "All food must be cleansed with fire.",
			BURNT = "At least it went out in a blaze of glory.",
		},
		CORN = "A sweet vegetable, yum!",
		CORN_COOKED = "Ooh, this one explodes when it goes in fire!",
		CORN_SEEDS = "Some seeds.",
        CANARY =
		{
			GENERIC = "If it kicks the bucket I'm outta here.",
			HELD = "You still breathing? Just checking.",
		},
        CANARY_POISONED = "Is that infectious? We should burn it.",

		CRITTERLAB = "Is there anything cute in there??",
        CRITTER_GLOMLING = "Aww, I could just squish your gross lil face!",
        CRITTER_DRAGONLING = "We were made for each other.",
		CRITTER_LAMB = "Look at those creepy little eyes. Aww.",
        CRITTER_PUPPY = "Hah, you don't even know you're smelly.",
        CRITTER_KITTEN = "You're the perfect lapwarmer.",
        CRITTER_PERDLING = "I could just eat you up.",
		CRITTER_LUNARMOTHLING = "She loves flames!",

		CROW =
		{
			GENERIC = "I think it's waiting for me to die.",
			HELD = "Not so smart now, are you?",
		},
		CUTGRASS = "Cut grass, ready for burning. Or maybe crafting.",
		CUTREEDS = "Cut reeds, ready for burning. Or maybe crafting.",
		CUTSTONE = "Perfectly squared for maximum enjoyment.",
		DEADLYFEAST = "Fire didn't cure this dish of being nasty.", --unimplemented
		DEER =
		{
			GENERIC = "I wish everyone'd stop fawning over that smelly thing!",
			ANTLER = "Don't think that horn makes you special, deer.",
		},
        DEER_ANTLER = "It's a big, weird antler.",
        DEER_GEMMED = "Marginally better smelling than most animals here.",
		DEERCLOPS = "Holy crap!",
		DEERCLOPS_EYEBALL = "Stop staring at me!",
		EYEBRELLAHAT =	"Keeps the rain out your eyes and in someone else's.",
		DEPLETED_GRASS =
		{
			GENERIC = "What a sorry looking piece of... grass?",
		},
        GOGGLESHAT = "What a great look!",
        DESERTHAT = "Not very stylish.",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "Who just leaves dirt lying around in the forest?",
		DIVININGROD =
		{
			COLD = "It's making some kind of noise.", --singleplayer
			GENERIC = "It's full of electrical junk.", --singleplayer
			HOT = "Gah! Enough with the beeping!", --singleplayer
			WARM = "This thing is getting noisier.", --singleplayer
			WARMER = "Must be close!", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "Not sure what this does. Doesn't seem like it's fiery things.", --singleplayer
			READY = "Just needs to be unlocked with a key. Not fire, unfortunately.", --singleplayer
			UNLOCKED = "It's whirring now!", --singleplayer
		},
		DIVININGRODSTART = "I'll make something out of it.", --singleplayer
		DRAGONFLY = "It's filled with fire!",
		ARMORDRAGONFLY = "Yay! More FIRE!!!",
		DRAGON_SCALES = "Oooooooh! I LIKE those.",
		DRAGONFLYCHEST = "I'm not sure why you'd want something that DOESN'T burn...",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "That's certainly a look.",
			GENERIC = "Let's turn it back on!", --no gems
			NORMAL = "Stick another gem in there!", --one gem
			HIGH = "I think I'm in love.", --two gems
		},

        HUTCH = "What's your angle?",
        HUTCH_FISHBOWL =
        {
            GENERIC = "It's too wet to burn.",
            WAITING = "It's still too wet to burn.",
        },
		LAVASPIT =
		{
			HOT = "The coolest drool!",
			COOL = "Cool drool, literally.",
		},
		LAVA_POND = "Yes! Yessss!",
		LAVAE = "Why can't we be friends?",
		LAVAE_COCOON = "Aw, it lost its fiery personality.",
		LAVAE_PET =
		{
			STARVING = "I can see her ribs!",
			HUNGRY = "I think she wants some burnings.",
			CONTENT = "My own little burninator.",
			GENERIC = "She's... perfect.",
		},
		LAVAE_EGG =
		{
			GENERIC = "I think a fire is trying to escape.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "It has a chill.",
			COMFY = "That egg looks happy.",
		},
		LAVAE_TOOTH = "I hope she's not a biter.",

		DRAGONFRUIT = "It looks sort of like a fire!",
		DRAGONFRUIT_COOKED = "It looks more like a fruit that's been in a fire now.",
		DRAGONFRUIT_SEEDS = "Some seeds.",
		DRAGONPIE = "Fire fruit in a pie? Oh boy!",
		DRUMSTICK = "Bang on the drum all day!",
		DRUMSTICK_COOKED = "Hmm... Satisfy hunger, or bang on the drum?",
		DUG_BERRYBUSH = "What's the matter, got no dirt?",
		DUG_BERRYBUSH_JUICY = "What's the matter, got no dirt?",
		DUG_GRASS = "What's the matter, got no dirt?",
		DUG_MARSH_BUSH = "What's the matter, got no dirt?",
		DUG_SAPLING = "What's the matter, got no dirt?",
		DURIAN = "Ew, stinky!",
		DURIAN_COOKED = "Yuck, it smells just as bad cooked!",
		DURIAN_SEEDS = "Some seeds.",
		EARMUFFSHAT = "Smells like rabbit butt.",
		EGGPLANT = "Definitely not a bird.",
		EGGPLANT_COOKED = "Using fire on it made it a tastier eggplant.",
		EGGPLANT_SEEDS = "Some seeds.",

		ENDTABLE =
		{
			BURNT = "Alright, alright, so I was wrong about the hand!",
			GENERIC = "Just a bunch of dumb flowers.",
			EMPTY = "I'm telling you, there's a monsterhand under that thing!",
			WILTED = "Those need replacing.",
			FRESHLIGHT = "Not as good as a fire, but at least we won't be in the dark.",
			OLDLIGHT = "We're gonna be in the dark soon.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "YES! BURN!",
			BURNT = "I wish it was still burning.",
			CHOPPED = "One less tree in the world.",
			POISON = "A fire would set'em straight.",
			GENERIC = "It looks like it would burn well.",
		},
		ACORN = "Hey there, tree seed.",
        ACORN_SAPLING = "You'll be a real tree soon.",
		ACORN_COOKED = "Looks like you won't become a tree after all.",
		BIRCHNUTDRAKE = "Aaah! Set it on fire!",
		EVERGREEN =
		{
			BURNING = "YES! BURN!",
			BURNT = "I wish it was still burning.",
			CHOPPED = "One less tree in the world.",
			GENERIC = "It looks like it would burn well.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "YES! BURN!",
			BURNT = "I wish it was still burning.",
			CHOPPED = "One less tree in the world.",
			GENERIC = "Die in a fire!",
		},
		TWIGGYTREE =
		{
			BURNING = "YES! BURN!",
			BURNT = "I wish it was still burning.",
			CHOPPED = "One less tree in the world.",
			GENERIC = "How are you supposed to get the sticks from up there??",
			DISEASED = "Burn the sick!", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "It'll grow... unless something fiery happens to it.",
        TWIGGY_OLD = "Fire would release it from its torment.",
		TWIGGY_NUT = "Looks like campfire fuel to me!",
		EYEPLANT = "They spread like fire.",
		INSPECTSELF = "Why didn't anyone tell me I had ashes on my face?",
		FARMPLOT =
		{
			GENERIC = "Sigh. It's a pile of dirt.",
			GROWING = "Hurry up, dirtpile. Feed me!",
			NEEDSFERTILIZER = "Stupid thing needs poop.",
			BURNT = "It was a nice finale.",
		},
		FEATHERHAT = "A phoenix reborn!",
		FEATHER_CROW = "Black bird feather. It probably smells terrible on fire.",
		FEATHER_ROBIN = "Redbird feather. It probably smells terrible on fire.",
		FEATHER_ROBIN_WINTER = "Snowbird feather. It probably smells terrible on fire.",
		FEATHER_CANARY = "Canary feather. It probably smells terrible on fire.",
		FEATHERPENCIL = "So what does the feather do again?",
        COOKBOOK = "Uuugh, it's no fun cooking with instructions!",
		FEM_PUPPET = "She looks scared half to death.", --single player
		FIREFLIES =
		{
			GENERIC = "I wish they didn't run away!",
			HELD = "They're like little fires in my pocket!",
		},
		FIREHOUND = "I actually kind of like that one.",
		FIREPIT =
		{
			EMBERS = "Uh oh. It's almost gone!",
			GENERIC = "I could watch it for hours.",
			HIGH = "BURN! BURN FASTER!",
			LOW = "This fire is small and boring.",
			NORMAL = "Burn!",
			OUT = "Make the fire come back!",
		},
		COLDFIREPIT =
		{
			EMBERS = "Uh oh. It's almost gone!",
			GENERIC = "I could watch it for hours, even though it's cold.",
			HIGH = "BURN! BURN FASTER! AND BLUER!",
			LOW = "This fire is small and boring. And blue.",
			NORMAL = "Burn!",
			OUT = "Make the fire come back!",
		},
		FIRESTAFF = "That's my absolute favorite toy.",
		FIRESUPPRESSOR =
		{
			ON = "I wish you'd shut your lid and stop putting out fires.",
			OFF = "And stay off!",
			LOWFUEL = "Almost out.",
		},

		FISH = "Slippery fishy!",
		FISHINGROD = "Fishing for the answer with a hook, line and sinker.",
		FISHSTICKS = "What you see is what you get. Sticks of fish.",
		FISHTACOS = "Convenient taco-grip.",
		FISH_COOKED = "Less slippery now that it's found fire.",
		FLINT = "The poor man's fire-starter.",
		FLOWER =
		{
            GENERIC = "I don't have time to waste on flowers.",
            ROSE = "I'd like to burn this flower in particular.",
        },
        FLOWER_WITHERED = "Looks like good kindling.",
		FLOWERHAT = "A halo of flowers. Too bad it's not a burning halo of flowers.",
		FLOWER_EVIL = "Ugh, that smells terrible.",
		FOLIAGE = "Fuel for the fire.",
		FOOTBALLHAT = "Sports are hard.",
        FOSSIL_PIECE = "It's just nasty old bits of bones!",
        FOSSIL_STALKER =
        {
			GENERIC = "Needs more gross old bits.",
			FUNNY = "That looks absolutely ridiculous.",
			COMPLETE = "Looks passable.",
        },
        STALKER = "I brought you back so I could beat you up!",
        STALKER_ATRIUM = "It's just bones and shadow.",
        STALKER_MINION = "Yuck, it's barely even alive.",
        THURIBLE = "It smells like burnt hair!",
        ATRIUM_OVERGROWTH = "It's in some other language.",
		FROG =
		{
			DEAD = "Showed him!",
			GENERIC = "He's too damp to burn.",
			SLEEPING = "They're cute when they're sleeping.",
		},
		FROGGLEBUNWICH = "If you close your eyes it's a little easier to get it down.",
		FROGLEGS = "It still twitches every now and then. Freaky.",
		FROGLEGS_COOKED = "The fire made it stop twitching. Fire is the best.",
		FRUITMEDLEY = "Yum, fruit!",
		FURTUFT = "Black and white and fuzzy all over!",
		GEARS = "These must make them move.",
		GHOST = "You can't kill what's already dead.",
		GOLDENAXE = "It won't light trees on fire, but at least it's shiny.",
		GOLDENPICKAXE = "It won't light rocks on fire, but at least it's shiny.",
		GOLDENPITCHFORK = "It won't light the ground on fire, but at least it's shiny.",
		GOLDENSHOVEL = "It won't make flaming pits, but at least it's shiny.",
		GOLDNUGGET = "What should we spend it on??",
		GRASS =
		{
			BARREN = "It needs poop.",
			WITHERED = "Nice, dry, and ready to burn!",
			BURNING = "Fire! Wooo!",
			GENERIC = "It's a flammable tuft of grass.",
			PICKED = "Grass stubble is kind of useless.",
			DISEASED = "Burn the sick!", --unimplemented
			DISEASING = "Blech. You smell.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Ew.",
			DISEASED = "Double ew!", --unimplemented
		},
		GREEN_CAP = "Boring!",
		GREEN_CAP_COOKED = "It's been transformed by fire!",
		GREEN_MUSHROOM =
		{
			GENERIC = "Stupid mushroom.",
			INGROUND = "Hey! You! Get up here!",
			PICKED = "Maybe it will return some day.",
		},
		GUNPOWDER = "Oooooooooh! Shiny!",
		HAMBAT = "Pleased to meat you!",
		HAMMER = "I prefer sharp implements.",
		HEALINGSALVE = "It burns! But, where's the fire?",
		HEATROCK =
		{
			FROZEN = "Frozen solid.",
			COLD = "It's stone cold.",
			GENERIC = "A fire would liven this thing up!",
			WARM = "No flame, no real heat... what fun is that?",
			HOT = "Look at how it glows!",
		},
		HOME = "I'm gonna burn it.",
		HOMESIGN =
		{
			GENERIC = "Less reading! More burning!",
            UNWRITTEN = "I should burn something into it.",
			BURNT = "Hahaha, yesss!",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "Less reading! More burning!",
            UNWRITTEN = "I could doodle something rude here.",
			BURNT = "It said \"Don't play with matches\", but the \"Don't\" is crossed out now.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Less reading! More burning!",
            UNWRITTEN = "I could doodle something rude here.",
			BURNT = "It said \"Don't play with matches\", but the \"Don't\" is crossed out now.",
		},
		HONEY = "Sweet and delicious!",
		HONEYCOMB = "It's waxy.",
		HONEYHAM = "Fire, ham and honey go well together.",
		HONEYNUGGETS = "Honey-covered morsels that have met my friend, fire.",
		HORN = "I can hear those hairy beasts inside.",
		HOUND = "What a jerk!",
		HOUNDCORPSE =
		{
			GENERIC = "So... now what do we do with it?",
			BURNING = "The best way to solve any problem.",
			REVIVING = "BURN ITTTT!",
		},
		HOUNDBONE = "Gross.",
		HOUNDMOUND = "Uh oh, I don't like the look of that.",
		ICEBOX = "That is the opposite of fire.",
		ICEHAT = "It's a real mood dampener.",
		ICEHOUND = "Gross! Cold!",
		INSANITYROCK =
		{
			ACTIVE = "Am I seeing things?",
			INACTIVE = "Doesn't look flammable. How boring.",
		},
		JAMMYPRESERVES = "Wham, bam, jam! Thank you, ma'am.",

		KABOBS = "Meat and fire, now with a stick!",
		KILLERBEE =
		{
			GENERIC = "I like the cut of that bee's jib.",
			HELD = "Buzz!",
		},
		KNIGHT = "It's a pony!",
		KOALEFANT_SUMMER = "We will be great friends!",
		KOALEFANT_WINTER = "He sure looks warm...",
		KRAMPUS = "Stay back, you big jerk!",
		KRAMPUS_SACK = "The holidays came early this year!",
		LEIF = "He looks flammable!",
		LEIF_SPARSE = "He looks flammable!",
		LIGHTER  = "It's my lucky lighter!",
		LIGHTNING_ROD =
		{
			CHARGED = "Aww, all glow but no fire.",
			GENERIC = "All the lightning goes here!",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "Bouncy goat.",
			CHARGED = "You're crazy!",
		},
		LIGHTNINGGOATHORN = "I heard lightning when I held it to my ear.",
		GOATMILK = "It's fuzzy with electricity. Yuck.",
		LITTLE_WALRUS = "He looks tasty.",
		LIVINGLOG = "It looks upset.",
		LOG =
		{
			BURNING = "Burn, log, buuuurn!",
			GENERIC = "Wood! So flammable! Hooray!",
		},
		LUCY = "We could be good friends, you and I.",
		LUREPLANT = "I bet a quick fire would take care of this.",
		LUREPLANTBULB = "Gross! It's so meaty!",
		MALE_PUPPET = "He looks scared half to death.", --single player

		MANDRAKE_ACTIVE = "Now that's just creepy!",
		MANDRAKE_PLANTED = "That's not a normal plant.",
		MANDRAKE = "Why did this plant have a face?",

        MANDRAKESOUP = "The face doesn't wash away!!",
        MANDRAKE_COOKED = "The fire made this plant guy a lot quieter.",
        MAPSCROLL = "Nothing's on it? I can burn it then, right?",
        MARBLE = "It's heavy!",
        MARBLEBEAN = "I guess we just... plant it? In the dirt?",
        MARBLEBEAN_SAPLING = "That makes no sense!",
        MARBLESHRUB = "What sort of bush doesn't burn?!",
        MARBLEPILLAR = "I wonder if the rest burnt down.",
        MARBLETREE = "The worst kind of tree. The non-flammable kind.",
        MARSH_BUSH =
        {
			BURNT = "That burned way too quickly.",
            BURNING = "Burn, thorns!",
            GENERIC = "It looks sharp.",
            PICKED = "Those thorns hurt!",
        },
        BURNT_MARSH_BUSH = "That burned way too quickly.",
        MARSH_PLANT = "It's all plant-y.",
        MARSH_TREE =
        {
            BURNING = "YES! BURN!",
            BURNT = "I wish it was still burning.",
            CHOPPED = "Not so spiky now, are you?",
            GENERIC = "It looks dangerous!",
        },
        MAXWELL = "He's so condescending.",--single player
        MAXWELLHEAD = "He sure likes to talk.",--removed
        MAXWELLLIGHT = "These are no fun. They light themselves.",--single player
        MAXWELLLOCK = "It just needs a key.",--single player
        MAXWELLTHRONE = "Looks sticky.",--single player
        MEAT = "This could be made better with FIRE!",
        MEATBALLS = "Meat made into spheres and improved with fire.",
        MEATRACK =
        {
            DONE = "It's ready!",
            DRYING = "Come on meat, dry already!",
            DRYINGINRAIN = "Forget the rain! Dry!",
            GENERIC = "I want to hang some meat!",
            BURNT = "Maybe the fire wasn't the best drying method...",
            DONE_NOTMEAT = "It's ready!",
            DRYING_NOTMEAT = "How long does it take this stuff to dry?!",
            DRYINGINRAIN_NOTMEAT = "Forget the rain! Dry!",
        },
        MEAT_DRIED = "Chewy, but satisfying.",
        MERM = "Eww, it's all swampy.",
        MERMHEAD =
        {
            GENERIC = "That's what you get for being so stinky!",
            BURNT = "Double whammy!",
        },
        MERMHOUSE =
        {
            GENERIC = "No one would care if this burned down.",
            BURNT = "It's true, no one cares.",
        },
        MINERHAT = "It's not real fire, but it's still pretty fun.",
        MONKEY = "Joke's on you! I can burn this poo.",
        MONKEYBARREL = "What a wonderfully flammable home.",
        MONSTERLASAGNA = "Noodles, meat and clumps of hair. Nasty.",
        FLOWERSALAD = "I'd rather a bowl of flames.",
        ICECREAM = "Well, soooometimes cold things are okay.",
        WATERMELONICLE = "Why would you freeze a fruit when you could burn it?",
        TRAILMIX = "Crunch crunch crunch.",
        HOTCHILI = "Now that's my kind of heat!",
        GUACAMOLE = "Holy moley, that's tasty!",
        MONSTERMEAT = "Gross. It's full of hairs.",
        MONSTERMEAT_DRIED = "It's dry and smells strange.",
        MOOSE = "What in the world...",
        MOOSE_NESTING_GROUND = "Ugh, it smells like bird butts!",
        MOOSEEGG = "It's huuuuge!",
        MOSSLING = "Its feathers are frazzled.",
        FEATHERFAN = "I dunno... it could put out some fires...",
        MINIFAN = "No fun, making me exercise to stay cool!",
        GOOSE_FEATHER = "So snuggly!",
        STAFF_TORNADO = "Always whirling! Swirling towards destruction!",
        MOSQUITO =
        {
            GENERIC = "So annoying!",
            HELD = "Keep that mouth away from me!",
        },
        MOSQUITOSACK = "Blood must bubble in currents muggy and thick.",
        MOUND =
        {
            DUG = "Better it than me.",
            GENERIC = "It's full of dead stuff, I bet.",
        },
        NIGHTLIGHT = "It's like fire, but purple!",
        NIGHTMAREFUEL = "Eww, it's still warm!",
        NIGHTSWORD = "It's like dreams that can hurt real things!",
        NITRE = "There are tiny explosions trapped inside.",
        ONEMANBAND = "I can do the pyrotechnics too!",
        OASISLAKE =
		{
			GENERIC = "It's a bunch of water.",
			EMPTY = "It's a bunch of dirt.",
		},
        PANDORASCHEST = "Kind of tacky.",
        PANFLUTE = "Music is boring.",
        PAPYRUS = "I bet it'd burn!",
        WAXPAPER = "Heh, we rubbed a bunch of paper in beeswax.",
        PENGUIN = "Run away, tiny dancers.",
        PERD = "Evil bird! Get away from those yummy berries!",
        PEROGIES = "Tasty things, sealed with fire.",
        PETALS = "Stupid flowers. They're almost useless.",
        PETALS_EVIL = "Ew, they're sticky.",
        PHLEGM = "Gross! Let's burn it.",
        PICKAXE = "It's very pointy.",
        PIGGYBACK = "It's a backpack made out of butts!",
        PIGHEAD =
        {
            GENERIC = "I guess I have it alright.",
            BURNT = "It can always get worse, I guess.",
        },
        PIGHOUSE =
        {
            FULL = "He's doing pig things in there.",
            GENERIC = "These pigs have questionable taste in architecture.",
            LIGHTSOUT = "You jerk! Let me in!",
            BURNT = "Nice redecorating job!",
        },
        PIGKING = "Blech. What a slob.",
        PIGMAN =
        {
            DEAD = "I wonder how they taste.",
            FOLLOWER = "Ick. It's following me.",
            GENERIC = "Ugh. They're fragrant.",
            GUARD = "He's not the boss of me!",
            WEREPIG = "Bring it on, piggie!",
        },
        PIGSKIN = "Ha ha. A pig's butt.",
        PIGTENT = "It smells terrible!",
        PIGTORCH = "These pigs sure know how to have a good time.",
        PINECONE = "Hey there, tree seed.",
        PINECONE_SAPLING = "You'll be a real tree soon.",
        LUMPY_SAPLING = "I should burn that thing before it reaches full ugliness.",
        PITCHFORK = "Three times the pointiness.",
        PLANTMEAT = "Eww, it's all slimy.",
        PLANTMEAT_COOKED = "Fire makes everything better.",
        PLANT_NORMAL =
        {
            GENERIC = "I'd eat it if I had to.",
            GROWING = "Hurry up, you stupid plant!",
            READY = "Oh boy. Vegetables.",
            WITHERED = "It's crackly and dry. Good kindling!",
        },
        POMEGRANATE = "Is it supposed to have this many parts?",
        POMEGRANATE_COOKED = "Fire always makes things better.",
        POMEGRANATE_SEEDS = "Some seeds.",
        POND = "This pond will definitely not ignite. How dull.",
        POOP = "Ew. Nasty. But useful.",
        FERTILIZER = "A bucket full of nasty.",
        PUMPKIN = "I wonder what would happen if I applied fire.",
        PUMPKINCOOKIE = "Cookies!!!",
        PUMPKIN_COOKED = "Fire on the outside turned out pretty well.",
        PUMPKIN_LANTERN = "Fire on the inside is amazing!",
        PUMPKIN_SEEDS = "Some seeds.",
        PURPLEAMULET = "Has science gone too far?",
        PURPLEGEM = "Weird!",
        RABBIT =
        {
            GENERIC = "He looks tasty.",
            HELD = "I have him right where I want him!",
        },
        RABBITHOLE =
        {
            GENERIC = "Stupid rabbits. Come out so I can eat you.",
            SPRING = "Stupid rabbits must be stuck down there.",
        },
        RAINOMETER =
        {
            GENERIC = "Rain is the anti-fire. Boo!",
            BURNT = "Take that, rain!",
        },
        RAINCOAT = "That'll do the trick.",
        RAINHAT = "Anything to keep the water away.",
        RATATOUILLE = "Vegetables. So many vegetables.",
        RAZOR = "What's it even for?",
        REDGEM = "So pretty!",
        RED_CAP = "I like the color.",
        RED_CAP_COOKED = "It's been transformed by fire!",
        RED_MUSHROOM =
        {
            GENERIC = "Pretty!",
            INGROUND = "Hey! You! Get up here!",
            PICKED = "Maybe it will return some day.",
        },
        REEDS =
        {
            BURNING = "Burn! Yeah!",
            GENERIC = "It's a burnable clump of reeds.",
            PICKED = "It's just reed stubble.",
        },
        RELIC = "Old furniture.",
        RUINS_RUBBLE = "That could probably be fixed up.",
        RUBBLE = "Broken furniture.",
        RESEARCHLAB =
        {
            GENERIC = "Even I don't know everything... yet.",
            BURNT = "There's no learning from that now.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "Even I don't know everything... yet.",
            BURNT = "There's no learning from that now.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "A dark and powerful energy radiates from it.",
            BURNT = "Now it's dark and not very powerful.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "I can use the hat like a cauldron!",
            BURNT = "Double, double toil and... oh. It's burned.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "That's our insurance policy.",
            BURNT = "Our policy was canceled.",
        },
        RESURRECTIONSTONE = "I'll touch it when I'm good and ready.",
        ROBIN =
        {
            GENERIC = "A redbird. The color of fire, but not a phoenix.",
            HELD = "It's cozy in my pocket.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "It looks cold out here. I bet it wants a fire.",
            HELD = "It's so fluffy.",
        },
        ROBOT_PUPPET = "They look scared half to death.", --single player
        ROCK_LIGHT =
        {
            GENERIC = "There's heat in there, just waiting to get out!",--removed
            OUT = "Aww, it's cooled off.",--removed
            LOW = "The lava is cooling.",--removed
            NORMAL = "A pool of fire!",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Let's just smash it up.",
            RAISED = "I can't get up there!",
        },
        ROCK = "It's, like, a rock.",
        PETRIFIED_TREE = "How am I supposed to burn it now?",
        ROCK_PETRIFIED_TREE = "How am I supposed to burn it now?",
        ROCK_PETRIFIED_TREE_OLD = "How am I supposed to burn it now?",
        ROCK_ICE =
        {
            GENERIC = "I don't think there's any way it'd burn.",
            MELTED = "As useless as water ever was.",
        },
        ROCK_ICE_MELTED = "As useless as water ever was.",
        ICE = "Chilly.",
        ROCKS = "What's the point of collecting these again?",
        ROOK = "It's a castle!",
        ROPE = "What should we tie up??!",
        ROTTENEGG = "Ew! Why? Oh Why?!",
        ROYAL_JELLY = "It's so sweet!",
        JELLYBEAN = "Nothing better than a handful of jellybeans.",
        SADDLE_BASIC = "It's so uncomfortable.",
        SADDLE_RACE = "Was it worth it? I think it was worth it.",
        SADDLE_WAR = "I'm going to raze some villages!",
        SADDLEHORN = "I bet it stinks under the saddle.",
        SALTLICK = "It's a big block of slobbery salt.",
        BRUSH = "It smells like burnt hair.",
		SANITYROCK =
		{
			ACTIVE = "I wonder what these markings mean.",
			INACTIVE = "Where'd it go?",
		},
		SAPLING =
		{
			BURNING = "Burn! Yeah!",
			WITHERED = "It's so dry, it's like it WANTS to be on fire.",
			GENERIC = "It'd be worth it to pick that.",
			PICKED = "Poor little limp tree.",
			DISEASED = "Burn the sick!", --removed
			DISEASING = "Blech. You smell.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Ha! He thinks he's people!",
			BURNING = "It's a burning man.",
			BURNT = "Just burnt straw.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Hm... I could make things that DON'T burn?",
			BLOCK = "I'm gonna carve a stone butt.",
			SCULPTURE = "I guess that's good, too.",
			BURNT = "Haha!",
   		},
        SCULPTURE_KNIGHTHEAD = "Great, now we've irritated some marble crime boss!",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "It's a marble statue, I guess.",
			UNCOVERED = "That thing looks terrible.",
			FINISHED = "He didn't even say \"thank you\".",
			READY = "Ew! It's wriggling!",
		},
        SCULPTURE_BISHOPHEAD = "Gross. I don't think that was supposed to come off.",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Not burnable. Not interested.",
			UNCOVERED = "The crank doesn't even turn!",
			FINISHED = "Humpty Dumpty's back together again.",
			READY = "Ew! It's wriggling!",
		},
        SCULPTURE_ROOKNOSE = "Ha, falling to pieces. Rookie mistake.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Looks like a bunch of rubble to me.",
			UNCOVERED = "What a creepy load of junk!",
			FINISHED = "I'm more used to destroying things than fixing them.",
			READY = "Ew! It's wriggling!",
		},
        GARGOYLE_HOUND = "Lookit this big dumb lawn ornament!",
        GARGOYLE_WEREPIG = "At least it doesn't smell anymore.",
		SEEDS = "Farming is boring.",
		SEEDS_COOKED = "No good for farming now.",
		SEWING_KIT = "But destruction is so much more fun!",
		SEWING_TAPE = "At least something around here can hold it together.",
		SHOVEL = "Not great for fighting.",
		SILK = "Mmmmmm. Smooth.",
		SKELETON = "I hope you at least went out in a blaze of glory.",
		SCORCHED_SKELETON = "Ewwwwwwwwwww!",
		SKULLCHEST = "Ooooh, spooky!", --removed
		SMALLBIRD =
		{
			GENERIC = "Not quite a phoenix, but still cute. I guess.",
			HUNGRY = "Are you hungry?",
			STARVING = "Okay, okay! I get it, you're hungry.",
			SLEEPING = "It's asleep for now.",
		},
		SMALLMEAT = "This could be made better with FIRE!",
		SMALLMEAT_DRIED = "Chewy, but satisfying.",
		SPAT = "I don't like your face!",
		SPEAR = "That looks good for jabbin'!",
		SPEAR_WATHGRITHR = "I prefer a flame, but to each her own.",
		WATHGRITHRHAT = "It's got a name scratched on the inside... \"W\", uh...",
		SPIDER =
		{
			DEAD = "Ha! Showed you!",
			GENERIC = "He's nasty. I should kill him.",
			SLEEPING = "I could take him.",
		},
		SPIDERDEN = "That's just nasty.",
		SPIDEREGGSACK = "Tons of tiny disgusting spiders.",
		SPIDERGLAND = "Eeeeew, it's slimy and stinky!",
		SPIDERHAT = "Who's your mommy!",
		SPIDERQUEEN = "Kill it with fire!",
		SPIDER_WARRIOR =
		{
			DEAD = "He had it coming.",
			GENERIC = "Maybe I could kill it... with FIRE.",
			SLEEPING = "Maybe I should just leave that one alone.",
		},
		SPOILED_FOOD = "At least it's still flammable.",
        STAGEHAND =
        {
			AWAKE = "Gross! I told you we shoulda burned it!",
			HIDING = "What's a weird table doing out here? Let's burn it!",
        },
        STATUE_MARBLE =
        {
            GENERIC = "It's an okay statue, I guess.",
            TYPE1 = "Yikes. I'd cover that up too if I were her.",
            TYPE2 = "She hasn't put her face on for the day yet.",
            TYPE3 = "A brazier would be nicer.", --bird bath type statue
        },
		STATUEHARP = "Such a nice statue. Shame if something were to happen to it.",
		STATUEMAXWELL = "A big stone nerd.",
		STEELWOOL = "Make a spark, it'll still burn.",
		STINGER = "It's pokey!",
		STRAWHAT = "A hat made of straw. To think, it could've been tinder.",
		STUFFEDEGGPLANT = "It's still not a bird, but it's sure stuffed like one!",
		SWEATERVEST = "Not as nice as a flaming vest, but it'll do.",
		REFLECTIVEVEST = "Vests are so in.",
		HAWAIIANSHIRT = "I wonder if it'd burn as nicely as actual flowers do.",
		TAFFY = "Sugary things burn great, but best not waste food.",
		TALLBIRD = "I don't think it wants to be friends.",
		TALLBIRDEGG = "Does it like fire?",
		TALLBIRDEGG_COOKED = "Fire makes them so much better.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Needs more fire!",
			GENERIC = "Arise, my phoenix!",
			HOT = "Is there such a thing as too much fire?",
			LONG = "How long is this going to take?",
			SHORT = "I'm getting tired of waiting.",
		},
		TALLBIRDNEST =
		{
			GENERIC = "That egg could use some fire!",
			PICKED = "The nest is empty.",
		},
		TEENBIRD =
		{
			GENERIC = "I feel like he understands.",
			HUNGRY = "He sure eats a lot.",
			STARVING = "Don't look at me! Get your own food.",
			SLEEPING = "All you do is eat and sleep.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "I just want to see this world burn.", --single player
			GENERIC = "I like the way the symbols glow.", --single player
			LOCKED = "Needs to be unlocked somehow.", --single player
			PARTIAL = "I'm making a monstrosity!", --single player
		},
		TELEPORTATO_BOX = "It feels warm.", --single player
		TELEPORTATO_CRANK = "What's this part good for?", --single player
		TELEPORTATO_POTATO = "Perhaps it could be melted into a more pleasing shape.", --single player
		TELEPORTATO_RING = "This is too precious to burn!", --single player
		TELESTAFF = "It's quite a rush to use.",
		TENT =
		{
			GENERIC = "I got all the badges in Girl Scouts.",
			BURNT = "Well, I've still got my badges.",
		},
		SIESTAHUT =
		{
			GENERIC = "They taught us how to make these in Girl Scouts.",
			BURNT = "I always set them on fire.",
		},
		TENTACLE = "Not at all cuddly.",
		TENTACLESPIKE = "It's pointy and slimy.",
		TENTACLESPOTS = "Ewwwww.",
		TENTACLE_PILLAR = "It's quivering.",
        TENTACLE_PILLAR_HOLE = "What a smell! Light a match next time!",
		TENTACLE_PILLAR_ARM = "Awwww, they want hugs!",
		TENTACLE_GARDEN = "I hear little digging sounds.",
		TOPHAT = "A top hat and a lighter, a perfect combination.",
		TORCH = "Fire is so pretty.",
		TRANSISTOR = "Electrical doo-dah, doo-dah.",
		TRAP = "It's a bit passive aggressive, but it'll work.",
		TRAP_TEETH = "It would be better with fire.",
		TRAP_TEETH_MAXWELL = "I know exactly what kind of jerk leaves this lying around!", --single player
		TREASURECHEST =
		{
			GENERIC = "It's a trunk for my junk.",
			BURNT = "The trunk burned nicely.",
		},
		TREASURECHEST_TRAP = "Dirty trick!",
		SACRED_CHEST =
		{
			GENERIC = "A very very old chest.",
			LOCKED = "I think it's judging me.",
		},
		TREECLUMP = "Moooooooooooooove.", --removed

		TRINKET_1 = "That's how you play marbles, right? By burning them?", --Melted Marbles
		TRINKET_2 = "A cheap fake. It probably doesn't even burn properly.", --Fake Kazoo
		TRINKET_3 = "Why use a knife when you can use fire?", --Gord's Knot
		TRINKET_4 = "He looks like he was forged in flame.", --Gnome
		TRINKET_5 = "Check out those tiny thrusters. Such explosive power!", --Toy Rocketship
		TRINKET_6 = "These wires get WX all frazzled. Heh heh.", --Frazzled Wires
		TRINKET_7 = "Spinning the stick in the hole could start a fire. Thanks Girl Scouts!", --Ball and Cup
		TRINKET_8 = "I've never liked bathing with water.", --Rubber Bung
		TRINKET_9 = "Cute as Wendy's lil nose.", --Mismatched Buttons
		TRINKET_10 = "Hey Maxwell, I think you dropped these!", --Dentures
		TRINKET_11 = "Ooh, I wonder if he has a flamethrower!", --Lying Robot
		TRINKET_12 = "I bet Wilson would enjoy dissecting this.", --Dessicated Tentacle
		TRINKET_13 = "She looks like she was forged in flame.", --Gnomette
		TRINKET_14 = "They put a bird on it.", --Leaky Teacup
		TRINKET_15 = "What is it with megalomaniacs and chess?", --Pawn
		TRINKET_16 = "What is it with megalomaniacs and chess?", --Pawn
		TRINKET_17 = "Metal bends when it gets nice and hot.", --Bent Spork
		TRINKET_18 = "I bet Wigfrid would be into this.", --Trojan Horse
		TRINKET_19 = "Useful only for kindling.", --Unbalanced Top
		TRINKET_20 = "This looks a little like a fire iron.", --Backscratcher
		TRINKET_21 = "When I crank it Wes pretends to ride unicycle circles around me.", --Egg Beater
		TRINKET_22 = "I could use this as a very long fuse...", --Frayed Yarn
		TRINKET_23 = "It looks like it might melt in a fire.", --Shoehorn
		TRINKET_24 = "I don't want Ms. Wickerbottom to be sad. Let's burn it!", --Lucky Cat Jar
		TRINKET_25 = "I stuck one down Wolfgang's unitard when he wasn't looking. Haha.", --Air Unfreshener
		TRINKET_26 = "I would have roasted it.", --Potato Cup
		TRINKET_27 = "I want to stick it in a fire!", --Coat Hanger
		TRINKET_28 = "Chess is for pompous dorks.", --Rook
        TRINKET_29 = "Chess is for pompous dorks.", --Rook
        TRINKET_30 = "Probably the most boring game ever invented.", --Knight
        TRINKET_31 = "Probably the most boring game ever invented.", --Knight
        TRINKET_32 = "Just a big dumb ball.", --Cubic Zirconia Ball
        TRINKET_33 = "Ewww! Who would ever wear that!", --Spider Ring
        TRINKET_34 = "Ughhh! That's so nasty!", --Monkey Paw
        TRINKET_35 = "Hey Wes! Dare you to drink the last bit!", --Empty Elixir
        TRINKET_36 = "Pfft, they're not even sharp.", --Faux fangs
        TRINKET_37 = "Looks like firewood to me.", --Broken Stake
        TRINKET_38 = "It makes stuff look small no matter which way I turn it.", -- Binoculars Griftlands trinket
        TRINKET_39 = "Who needs just one glove?", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Snails are gross!", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Ooo, it's warm.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "I don't like snakes.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Yeesh. I can feel the nostalgia dripping off it.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "It's just junk.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "It's got kind of a dumb face, huh?", -- Odd Radio ONI trinket
        TRINKET_46 = "I never take my pigtails out anyway.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Something about it... gives me the creeps...",
        LOST_TOY_2  = "Something about it... gives me the creeps...",
        LOST_TOY_7  = "Something about it... gives me the creeps...",
        LOST_TOY_10 = "Something about it... gives me the creeps...",
        LOST_TOY_11 = "Something about it... gives me the creeps...",
        LOST_TOY_14 = "Something about it... gives me the creeps...",
        LOST_TOY_18 = "Something about it... gives me the creeps...",
        LOST_TOY_19 = "Something about it... gives me the creeps...",
        LOST_TOY_42 = "Something about it... gives me the creeps...",
        LOST_TOY_43 = "Something about it... gives me the creeps...",

        HALLOWEENCANDY_1 = "That's wayyyy better than a regular apple!",
        HALLOWEENCANDY_2 = "Do people actually eat these or are they just a bad joke?",
        HALLOWEENCANDY_3 = "Ewwww it's corn flavored!",
        HALLOWEENCANDY_4 = "Eww! I hate black licorice!",
        HALLOWEENCANDY_5 = "These are a meow-uthful.",
        HALLOWEENCANDY_6 = "Hey Wolfgang, eat one and tell us what it is!",
        HALLOWEENCANDY_7 = "Burn them!!!",
        HALLOWEENCANDY_8 = "Yesssss! Lollipops!",
        HALLOWEENCANDY_9 = "Why does something so yummy have to look so gross!",
        HALLOWEENCANDY_10 = "Yesssss! Lollipops!",
        HALLOWEENCANDY_11 = "I'm gonna need about a dozen of these.",
        HALLOWEENCANDY_12 = "Yuck! That's disgusting!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "It's sorta tangy.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Mmm! It burns my mouth so good!", --Hot Lava pepper candy
        CANDYBAG = "I'm gonna stuff so much candy in there!",

		HALLOWEEN_ORNAMENT_1 = "Can I set it on fire?",
		HALLOWEEN_ORNAMENT_2 = "I should decorate for Halloween.",
		HALLOWEEN_ORNAMENT_3 = "Ugh. I hate those jerks.",
		HALLOWEEN_ORNAMENT_4 = "Wish it was flammable.",
		HALLOWEEN_ORNAMENT_5 = "I should hang it somewhere and scare people.",
		HALLOWEEN_ORNAMENT_6 = "I'm gonna stick you in a tree.",

		HALLOWEENPOTION_DRINKS_WEAK = "I wish it was a little stronger.",
		HALLOWEENPOTION_DRINKS_POTENT = "Ah. The strong stuff.",
        HALLOWEENPOTION_BRAVERY = "It's like there's a fire in my belly.",
		HALLOWEENPOTION_MOON = "Piping hot mutation juice!",
		HALLOWEENPOTION_FIRE_FX = "I didn't think it was possible to make fire better.",
		MADSCIENCE_LAB = "I like the fire!",
		LIVINGTREE_ROOT = "It's a stick. But I can't even set it on fire.",
		LIVINGTREE_SAPLING = "Should I wait until it gets bigger to set it on fire?",

        DRAGONHEADHAT = "Sooo ferocious!",
        DRAGONBODYHAT = "Aww, I always get caught in the middle!",
        DRAGONTAILHAT = "I wanna be the caboose!",
        PERDSHRINE =
        {
            GENERIC = "I don't even like gobblers!",
            EMPTY = "What do we have to do now?",
            BURNT = "Well, that's burned now.",
        },
        REDLANTERN = "Anything with a fire in it is okay by me.",
        LUCKY_GOLDNUGGET = "I don't think I'm supposed to spend this.",
        FIRECRACKERS = "Light'em up!",
        PERDFAN = "It's a big ol' fan.",
        REDPOUCH = "What a great color!",
        WARGSHRINE =
        {
            GENERIC = "That looks WAY better!",
            EMPTY = "It's missing something. Like fire.",
            BURNING = "That's what we were supposed to do, right?", --for willow to override
            BURNT = "I may've misunderstood.",
        },
        CLAYWARG =
        {
        	GENERIC = "How'd you get your eyes to do that?!",
        	STATUE = "Did someone carve this thing?",
        },
        CLAYHOUND =
        {
        	GENERIC = "This dog is stone cold!",
        	STATUE = "Welp, that's a weird shape for a rock.",
        },
        HOUNDWHISTLE = "Heh heh. STAY.",
        CHESSPIECE_CLAYHOUND = "It almost looks friendly.",
        CHESSPIECE_CLAYWARG = "It doesn't look so tough now.",

		PIGSHRINE =
		{
            GENERIC = "Where's the shrine to me?",
            EMPTY = "Needs meat.",
            BURNT = "Burnt. I like it.",
		},
		PIG_TOKEN = "I'd burn it, but it might be worth something.",
		PIG_COIN = "Finally, someone to do my dirty work.",
		YOTP_FOOD1 = "I'm gonna eat it all!",
		YOTP_FOOD2 = "Nah. I'll feed it to something.",
		YOTP_FOOD3 = "A little snack to fill my belly.",

		PIGELITE1 = "All washed up.", --BLUE
		PIGELITE2 = "You, I like.", --RED
		PIGELITE3 = "Eat dirt!", --WHITE
		PIGELITE4 = "Sure does like using those signs.", --GREEN

		PIGELITEFIGHTER1 = "All washed up.", --BLUE
		PIGELITEFIGHTER2 = "You, I like.", --RED
		PIGELITEFIGHTER3 = "Eat dirt!", --WHITE
		PIGELITEFIGHTER4 = "Sure does like using those signs.", --GREEN

		CARRAT_GHOSTRACER = "That's a weird looking Carrat.",

        YOTC_CARRAT_RACE_START = "Mine's gonna win, obviously.",
        YOTC_CARRAT_RACE_CHECKPOINT = "Looks perfectly flammable to me.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "I should set it on fire, it'll be easier to see that way.",
            BURNT = "Now that's more like it.",
            I_WON = "Pfft, as if there was any doubt I'd win.",
            SOMEONE_ELSE_WON = "{winner} was just lucky, I'm winning the next one.",
        },

		YOTC_CARRAT_RACE_START_ITEM = "What a gong show.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "There's not nearly enough fire in those lanterns.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Let's see, where's a good spot for me to win?",

		YOTC_SEEDPACKET = "Just a bunch of seeds.",
		YOTC_SEEDPACKET_RARE = "Oh wow, special seeds, how exciting.",

		MINIBOATLANTERN = "Ha! Fire beats water!",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "How come the rat-thing gets a shrine and I don't?",
            EMPTY = "Let me guess, I've gotta give you something.",
            BURNT = "No regrets.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "This should be fun.",
            RAT = "Getting dizzy yet?",
            BURNT = "All's well that burns well.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "What if I just set it on fire a little bit? For motivation!",
            RAT = "Look at those little legs go!",
            BURNT = "All's well that burns well.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "Sure, why not.",
            RAT = "Ha! I could watch this all day.",
            BURNT = "All's well that burns well.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "Not my idea of \"feeling the burn\".",
            RAT = "Go on, get the berry!",
            BURNT = "All's well that burns well.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "A gym-shaped pile of potential kindling.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "A gym-shaped pile of potential kindling.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "A gym-shaped pile of potential kindling.",
        YOTC_CARRAT_GYM_REACTION_ITEM = "A gym-shaped pile of potential kindling.",

        YOTC_CARRAT_SCALE_ITEM = "A nice, scale-shaped pile of potential kindling.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "My Carrat's off the scale! I mean literally.",
            CARRAT = "Meh. I've seen better.",
            CARRAT_GOOD = "Now we're talking!",
            BURNT = "Ha! Nice.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Got any firecrackers?",
            EMPTY = "Guess I should give it something.",
            BURNT = "It was a celebratory burning!",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Come on beefalo, it's dress-up time!",
            OCCUPIED = "Honestly, anything I do will be an improvement.",
            BURNT = "Heh, well that was fun.",
        },
        BEEFALO_GROOMER_ITEM = "Uuuugh, why is everything so much work?",

		BISHOP_CHARGE_HIT = "Owwww!",
		TRUNKVEST_SUMMER = "Now my friend will never leave.",
		TRUNKVEST_WINTER = "Not as warm as a good fire, but still pretty good!",
		TRUNK_COOKED = "It still doesn't look totally edible.",
		TRUNK_SUMMER = "Well, part of him is still cuddly.",
		TRUNK_WINTER = "It's so soft and squishy!",
		TUMBLEWEED = "It looks highly flammable.",
		TURKEYDINNER = "A feast of burned bird!",
		TWIGS = "A bunch of small twigs. Good for fires, among other things.",
		UMBRELLA = "I love the color!",
		GRASS_UMBRELLA = "Pretty as can be!",
		UNIMPLEMENTED = "It's not finished. But I bet it still burns.",
		WAFFLES = "Hi, waffles!",
		WALL_HAY =
		{
			GENERIC = "That looks so flammable!",
			BURNT = "It was flammable!",
		},
		WALL_HAY_ITEM = "Hmmm. I wonder if these will burn.",
		WALL_STONE = "Eh. I guess that's okay.",
		WALL_STONE_ITEM = "These are surprisingly heavy.",
		WALL_RUINS = "And they'll huff and they'll puff!",
		WALL_RUINS_ITEM = "Will those fit in my pockets?",
		WALL_WOOD =
		{
			GENERIC = "That could totally catch on fire.",
			BURNT = "It did catch on fire!",
		},
		WALL_WOOD_ITEM = "I hate hiding.",
		WALL_MOONROCK = "Safe for now.",
		WALL_MOONROCK_ITEM = "I guess I could carry it.",
		FENCE = "I'm not painting that.",
        FENCE_ITEM = "No point just leaving it on the ground.",
        FENCE_GATE = "I guess we could pen stuff in with it.",
        FENCE_GATE_ITEM = "No point just leaving it on the ground.",
		WALRUS = "Stop following me!",
		WALRUSHAT = "I kind of like the look of it.",
		WALRUS_CAMP =
		{
			EMPTY = "I'm not going in there. Yuck!",
			GENERIC = "Why does everyone have a nicer house than me?",
		},
		WALRUS_TUSK = "Nom nom nom.",
		WARDROBE =
		{
			GENERIC = "I want to set it on fire.",
            BURNING = "Yes! Burn!",
			BURNT = "Aww, the fire burned out.",
		},
		WARG = "You're a big mean jerk!",
        WARGLET = "You big jerk!",
        
		WASPHIVE = "A cone full of jerks.",
		WATERBALLOON = "Boo! Hissss!",
		WATERMELON = "But where's the firemelon?",
		WATERMELON_COOKED = "I made my own firemelon.",
		WATERMELONHAT = "Well, that's one use for this fruit.",
		WAXWELLJOURNAL = "Would make a great bedtime story... for nightmares!",
		WETGOOP = "How did it go wrong?! It was engulfed in fire and everything.",
        WHIP = "This means I'm the boss now.",
		WINTERHAT = "It's not warm enough for my liking.",
		WINTEROMETER =
		{
			GENERIC = "It would be better if it measured fire.",
			BURNT = "If you'd measured fire, maybe you woulda been prepared!",
		},

        WINTER_TREE =
        {
            BURNT = "Happy Winter's Feast, everybody.",
            BURNING = "Now we're celebrating!",
            CANDECORATE = "Looks great!",
            YOUNG = "It's a bit shrimpy.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "Are we gonna grow a tree?",
            BURNT = "Happy Winter's Feast, everybody.",
		},
        WINTER_ORNAMENT = "Bibble-ty bauble-ty boo!",
        WINTER_ORNAMENTLIGHT = "It's like a fire, but without the burning!",
        WINTER_ORNAMENTBOSS = "Woah, shiny! Nice!",
		WINTER_ORNAMENTFORGE = "I should toast this over an open fire.",
		WINTER_ORNAMENTGORGE = "So cute I don't even wanna burn it.",

        WINTER_FOOD1 = "Honestly, who DOESN'T eat the head first?", --gingerbread cookie
        WINTER_FOOD2 = "Doesn't look too bad, considering!", --sugar cookie
        WINTER_FOOD3 = "Gimme two of 'em and I can do a MacTusk impression.", --candy cane
        WINTER_FOOD4 = "Anyone else sense the overpowering stench of evil?", --fruitcake
        WINTER_FOOD5 = "A log for eating, not for burning.", --yule log cake
        WINTER_FOOD6 = "I'm gonna totally stuff my face!!", --plum pudding
        WINTER_FOOD7 = "Sure beats rainwater!", --apple cider
        WINTER_FOOD8 = "I only like it when it's SCALDING.", --hot cocoa
        WINTER_FOOD9 = "Who knew stuff from a bird's butt could be so tasty?", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "I'm on board with anything that involves fire.",
			COOKING = "Ugh, this is the most boring part.",
			ALMOST_DONE_COOKING = "Is it done yet?!",
			DISH_READY = "Mmmm, you can still taste the fire!",
		},
		BERRYSAUCE = "This is the best part!",
		BIBINGKA = "Mmm, I can still smell the fire.",
		CABBAGEROLLS = "Yeah, I can roll with these.",
		FESTIVEFISH = "It's just so festive!",
		GRAVY = "Yeah! Pour on the gravy!",
		LATKES = "No skimping on the sour cream!",
		LUTEFISK = "It actually looks pretty tasty.",
		MULLEDDRINK = "Ahh, it's like there's a warm fire in my belly.",
		PANETTONE = "Am I just hungry, or does everything look extra tasty?",
		PAVLOVA = "It's so delicate looking, I just want to smush it.",
		PICKLEDHERRING = "How does it smell so good?",
		POLISHCOOKIE = "Yup, I'll be having ten more of those.",
		PUMPKINPIE = "Yep, I'm eating this whole thing.",
		ROASTTURKEY = "Everything tastes better with fire.",
		STUFFING = "Out of the turkey and into my stomach!",
		SWEETPOTATO = "Don't mind if I do.",
		TAMALES = "It's like a little bit of fire in my mouth!",
		TOURTIERE = "Get into my pie hole!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Are we having company?",
			HAS_FOOD = "Looks so good I almost don't want to burn it.",
			WRONG_TYPE = "Oops, wrong food. Burn the mistake.",
			BURNT = "Now I'm really feeling the holiday spirit!",
		},

		GINGERBREADWARG = "Desserts should not eat people!",
		GINGERBREADHOUSE = "I almost don't want to burn this one.",
		GINGERBREADPIG = "Hey get back here!",
		CRUMBS = "Haha. That little guy is losing his parts.",
		WINTERSFEASTFUEL = "Reminds me of sitting by the fire on cold winter nights.",

        KLAUS = "A lump of coal would be really useful, actually!",
        KLAUS_SACK = "Nothing says \"Open Me\" quite like a lock!!",
		KLAUSSACKKEY = "Ha! I wouldn't wanna get smacked with that thing!",
		WORMHOLE =
		{
			GENERIC = "Poke it with a stick!",
			OPEN = "I wonder if it likes spicy food?",
		},
		WORMHOLE_LIMITED = "Yuck. That won't hold long.",
		ACCOMPLISHMENT_SHRINE = "I hate that arrow!", --single player
		LIVINGTREE = "It might be alive, but it'll still burn.",
		ICESTAFF = "Booooring.",
		REVIVER = "I expected it to be blacker.",
		SHADOWHEART = "Oh, ewww! Who would ever touch that?!",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "It's got a picture of some gross looking people.",
			LINE_2 = "Can't tell what that was a picture of.",
			LINE_3 = "I think someone spilled ink on this picture.",
			LINE_4 = "Oh, gross! The people're losing their skin in this one!",
			LINE_5 = "It's just a picture of a city.",
		},
        ATRIUM_STATUE = "Eerily lifelike.",
        ATRIUM_LIGHT =
        {
			ON = "It's somehow even creepier when it's on.",
			OFF = "Ew, creepy.",
		},
        ATRIUM_GATE =
        {
			ON = "It lit up!",
			OFF = "Why would anyone want to live down here?",
			CHARGING = "Something weird's going on.",
			DESTABILIZING = "Is it gonna explode?!",
			COOLDOWN = "I'll come back another time.",
        },
        ATRIUM_KEY = "The horns make it really easy to turn.",
		LIFEINJECTOR = "Don't you dare stick that in me!",
		SKELETON_PLAYER =
		{
			MALE = "The fire of %s's life was extinguished by %s.",
			FEMALE = "The fire of %s's life was extinguished by %s.",
			ROBOT = "The fire of %s's life was extinguished by %s.",
			DEFAULT = "The fire of %s's life was extinguished by %s.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "Just another rock to me.",
		MOONROCKNUGGET = "Just another rock to me.",
		MOONROCKCRATER = "Great. A rock with a hole in it.",
		MOONROCKSEED = "Well I can't burn it.",

        REDMOONEYE = "This one's got fire in its eye!",
        PURPLEMOONEYE = "Some sort of weird rock.",
        GREENMOONEYE = "A big dumb rock.",
        ORANGEMOONEYE = "It's a rock. Ugh!",
        YELLOWMOONEYE = "Another rock!",
        BLUEMOONEYE = "That's not an eyeball! It's a rock!",

        --Arena Event
        LAVAARENA_BOARLORD = "Pfft, I bet he can't even fight.",
        BOARRIOR = "He looks pretty haggard.",
        BOARON = "Keep that snout to yourself!",
        PEGHOOK = "It's got a weaponized butt!",
        TRAILS = "You can't push me around.",
        TURTILLUS = "Hey! How am I s'pose to hit you with all that armor?",
        SNAPPER = "Jeez, what's his crocodeal?",
		RHINODRILL = "Pfft. Whatever Rhinocebros.",
		BEETLETAUR = "Bet you think you're safe in all that armor.",

        LAVAARENA_PORTAL =
        {
            ON = "Time to go.",
            GENERIC = "This is WAY better than our gate back home!",
        },
        LAVAARENA_KEYHOLE = "There's no key in it.",
		LAVAARENA_KEYHOLE_FULL = "Looks good.",
        LAVAARENA_BATTLESTANDARD = "Kill that flag!",
        LAVAARENA_SPAWNER = "Jerks come out of it.",

        HEALINGSTAFF = "I could take a crack at it.",
        FIREBALLSTAFF = "So I just wave it and FIRE APPEARS?",
        HAMMER_MJOLNIR = "That weapon looks boring.",
        SPEAR_GUNGNIR = "I don't want to use that.",
        BLOWDART_LAVA = "Ptoo! Now you're dead!",
        BLOWDART_LAVA2 = "Ooh, the firepower!",
        LAVAARENA_LUCY = "That's Woodie's axe.",
        WEBBER_SPIDER_MINION = "That spider's so tiny!",
        BOOK_FOSSIL = "Looks like kindling to me.",
		LAVAARENA_BERNIE = "You're always there for me, Bernie.",
		SPEAR_LANCE = "Looks cumbersome.",
		BOOK_ELEMENTAL = "Looks interesting, for a book.",
		LAVAARENA_ELEMENTAL = "Woah! I love it!",

   		LAVAARENA_ARMORLIGHT = "This armor isn't very good.",
		LAVAARENA_ARMORLIGHTSPEED = "It barely does anything.",
		LAVAARENA_ARMORMEDIUM = "This armor will stop a blow or two.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Good for smackin' stuff.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "I could do neat stuff more often with that.",
		LAVAARENA_ARMORHEAVY = "That armor looks pretty safe.",
		LAVAARENA_ARMOREXTRAHEAVY = "Nothing's gonna get through that!",

		LAVAARENA_FEATHERCROWNHAT = "It's a feather crown!",
        LAVAARENA_HEALINGFLOWERHAT = "That's a great wreath!",
        LAVAARENA_LIGHTDAMAGERHAT = "So pointy!",
        LAVAARENA_STRONGDAMAGERHAT = "I'd wear it if I felt like hitting stuff.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Comes with a matching staff!",
        LAVAARENA_EYECIRCLETHAT = "Ooo, gimme!",
        LAVAARENA_RECHARGERHAT = "Ohh, I want it!",
        LAVAARENA_HEALINGGARLANDHAT = "I don't even wanna burn it!",
        LAVAARENA_CROWNDAMAGERHAT = "Dibs!",

		LAVAARENA_ARMOR_HP = "Woohoo! I should put that on.",

		LAVAARENA_FIREBOMB = "FIRE! FIRE! FIRE!",
		LAVAARENA_HEAVYBLADE = "No way I can use that!",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "Don't. Look. Up.",
        	FULL = "I wonder where all the food goes. Probably somewhere gross.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Haha! Look at this dumb goat statue.",
		QUAGMIRE_PARK_FOUNTAIN = "A fountain with no water. Maybe that's a metaphor?",

        QUAGMIRE_HOE = "You mean I gotta do work?",

        QUAGMIRE_TURNIP = "Haha gross, I hate turnips.",
        QUAGMIRE_TURNIP_COOKED = "Take that, turnip.",
        QUAGMIRE_TURNIP_SEEDS = "It's just a bunch of seeds.",

        QUAGMIRE_GARLIC = "It's just a couple cloves of garlic.",
        QUAGMIRE_GARLIC_COOKED = "Fire made it better.",
        QUAGMIRE_GARLIC_SEEDS = "It's just a bunch of seeds.",

        QUAGMIRE_ONION = "It's so bulbous.",
        QUAGMIRE_ONION_COOKED = "Roasting. My favorite cooking method.",
        QUAGMIRE_ONION_SEEDS = "It's just a bunch of seeds.",

        QUAGMIRE_POTATO = "We grew it in that gross muck.",
        QUAGMIRE_POTATO_COOKED = "Cooking just means sticking stuff in fire.",
        QUAGMIRE_POTATO_SEEDS = "It's just a bunch of seeds.",

        QUAGMIRE_TOMATO = "Cutting these is a pain.",
        QUAGMIRE_TOMATO_COOKED = "It just needed a couple minutes on the fire.",
        QUAGMIRE_TOMATO_SEEDS = "It's just a bunch of seeds.",

        QUAGMIRE_FLOUR = "Can you just eat flour?",
        QUAGMIRE_WHEAT = "How on earth do you eat this?",
        QUAGMIRE_WHEAT_SEEDS = "It's just a bunch of seeds.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "It's just a bunch of seeds.",

        QUAGMIRE_ROTTEN_CROP = "That one stayed in the ground too long.",

		QUAGMIRE_SALMON = "Look at it, flopping around like that.",
		QUAGMIRE_SALMON_COOKED = "All it needed was some fire.",
		QUAGMIRE_CRABMEAT = "Needs more fire.",
		QUAGMIRE_CRABMEAT_COOKED = "I bet it's tasty.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "Aw! It's impervious to fire.",
			STUMP = "It's kinda useless now.",
			TAPPED_EMPTY = "It's taking forever!",
			TAPPED_READY = "Sap's ready!",
			TAPPED_BUGS = "Stupid bugs.",
			WOUNDED = "You don't look so hot, tree.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "It smells kind of pepper-y.",
			PICKED = "That's not growing back.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "It's a piece of that pepper-y bush.",
		QUAGMIRE_SPOTSPICE_GROUND = "Spices... the true spice of life.",
		QUAGMIRE_SAPBUCKET = "Now we can get sap out of the trees.",
		QUAGMIRE_SAP = "Mmm! Pure sugar!",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Gotta dredge the salt up.",
			GENERIC = "Grow faster, salt crystals!",
		},

		QUAGMIRE_POND_SALT = "Blech! Tastes like ocean.",
		QUAGMIRE_SALT_RACK_ITEM = "We can use it to get some cooking salt.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "Ha! Cracked it.",
			LOCKED = "I can't get it to open.",
		},

		QUAGMIRE_KEY = "I'll use this if I can't burn it open.",
		QUAGMIRE_KEY_PARK = "There's more stuff to burn in the park.",
        QUAGMIRE_PORTAL_KEY = "Fancy key.",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "They're so hideous they're almost cute.",
			PICKED = "Hey! Give me more mushrooms!",
		},
		QUAGMIRE_MUSHROOMS = "It's totally raw. Fire could fix that!",
        QUAGMIRE_MEALINGSTONE = "I can smash stuff down with it.",
		QUAGMIRE_PEBBLECRAB = "Don't worry, I won't kick you.",


		QUAGMIRE_RUBBLE_CARRIAGE = "It's so busted, I don't even wanna light it on fire.",
        QUAGMIRE_RUBBLE_CLOCK = "I'd love to burn that to ashes.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "What a waste. It could've burned down.",
        QUAGMIRE_RUBBLE_PUBDOOR = "It'd be better if it was burnt.",
        QUAGMIRE_RUBBLE_ROOF = "The roof isn't on fire.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "That would look better on fire.",
        QUAGMIRE_RUBBLE_BIKE = "Metal doesn't burn well.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "It's like there was a Great Fire, without the fire.",
            "There's no one here. Boring.",
            "I wish this would burn.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "What's a chimney without a fireplace?",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Ugh! It won't even burn.",
        QUAGMIRE_MERMHOUSE = "That's what passes for a village around here, I guess.",
        QUAGMIRE_SWAMPIG_HOUSE = "It's just asking to be burned down.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Hey pigs! Your house blew down!",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "They're not so different from the pigs back at our place.",
            SLEEPING = "It's taking a nap.",
        },
        QUAGMIRE_SWAMPIG = "Not the prettiest face.",

        QUAGMIRE_PORTAL = "I'm just gonna keep jumping through portals til I figure out a way home.",
        QUAGMIRE_SALTROCK = "I licked one. Had to.",
        QUAGMIRE_SALT = "I need a pinch or two on all my food.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Looks good to me.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Maybe that thing up there'll eat it.",
            MISMATCH = "It doesn't want that. Might as well burn it.",
            MATCH = "This should shut that thing up for a while.",
            MATCH_BUT_SNACK = "This won't shut it up for long.",
        },

        QUAGMIRE_FERN = "I can take my pick of them.",
        QUAGMIRE_FOLIAGE_COOKED = "Leaf this to a professional.",
        QUAGMIRE_COIN1 = "Wow. A coin. Pfft.",
        QUAGMIRE_COIN2 = "I can probably buy something good with this.",
        QUAGMIRE_COIN3 = "I'm rich!",
        QUAGMIRE_COIN4 = "Guess that thing liked what we gave it.",
        QUAGMIRE_GOATMILK = "What? We needed milk.",
        QUAGMIRE_SYRUP = "Mmmm...",
        QUAGMIRE_SAP_SPOILED = "Well that's dumb.",
        QUAGMIRE_SEEDPACKET = "Aw...I won't know what these are until I plant them.",

        QUAGMIRE_POT = "I should light a fire under its butt.",
        QUAGMIRE_POT_SMALL = "It goes with the fire.",
        QUAGMIRE_POT_SYRUP = "Sweet stuff goes in there.",
        QUAGMIRE_POT_HANGER = "I set it up. Now what?",
        QUAGMIRE_POT_HANGER_ITEM = "It needs to be set up in a firepit.",
        QUAGMIRE_GRILL = "Fire it up!",
        QUAGMIRE_GRILL_ITEM = "Ugh, I guess I should set it up.",
        QUAGMIRE_GRILL_SMALL = "If it was bigger I could use more fire.",
        QUAGMIRE_GRILL_SMALL_ITEM = "I should set it up over the firepit.",
        QUAGMIRE_OVEN = "Now we're cooking.",
        QUAGMIRE_OVEN_ITEM = "I can't wait to use it!",
        QUAGMIRE_CASSEROLEDISH = "Fancy.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "It's kinda small.",
        QUAGMIRE_PLATE_SILVER = "Ohh. Look who's fancy now!",
        QUAGMIRE_BOWL_SILVER = "Now I don't have to use my hands.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "There's a lot of stuff to burn in there.", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "I'd burn it, but I need the things in there.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Gross.",
        QUAGMIRE_PARK_ANGEL2 = "Ugly.",
        QUAGMIRE_PARK_URN = "Cremation is the only way to do it.",
        QUAGMIRE_PARK_OBELISK = "It's stone. I can't burn it.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Didn't even have to melt the locks.",
            LOCKED = "I can't even burn it open!",
        },
        QUAGMIRE_PARKSPIKE = "That looks sharp.",
        QUAGMIRE_CRABTRAP = "That'll show those crabs.",
        QUAGMIRE_TRADER_MERM = "Hey, what'dya got for me?",
        QUAGMIRE_TRADER_MERM2 = "Nice hat. Are you selling that, too?",

        QUAGMIRE_GOATMUM = "Her eyes creep me out.",
        QUAGMIRE_GOATKID = "He'll eat just about anything.",
        QUAGMIRE_PIGEON =
        {
            DEAD = "It's dead.",
            GENERIC = "I haven't got any crumbs for you.",
            SLEEPING = "It's taking a nap.",
        },
        QUAGMIRE_LAMP_POST = "Just an old lamp post.",

        QUAGMIRE_BEEFALO = "Haha. You're old.",
        QUAGMIRE_SLAUGHTERTOOL = "I'd rather burn things.",

        QUAGMIRE_SAPLING = "Well. Might as well burn it now.",
        QUAGMIRE_BERRYBUSH = "But I want more berries!",

        QUAGMIRE_ALTAR_STATUE2 = "Ew. It's ugly.",
        QUAGMIRE_ALTAR_QUEEN = "What's so great about her?",
        QUAGMIRE_ALTAR_BOLLARD = "Boring.",
        QUAGMIRE_ALTAR_IVY = "Yawn.",

        QUAGMIRE_LAMP_SHORT = "Whatever. It's a lamp.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "It flings big stinkin' rocks.",
        	OFF = "Is this thing on?",
        	BURNING = "Hehehe!",
        	BURNT = "Well, that was mildly entertaining.",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "So no more night fires then?",
        	OFF = "Is this thing on?",
        	BURNING = "Hehehe!",
        	BURNT = "Well, that was mildly entertaining.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "Iunno, it's Winona's junk.",
        	LOWPOWER = "It's on its last legs.",
        	OFF = "Oops. It broke.",
        	BURNING = "Hehehe!",
        	BURNT = "Well, that was mildly entertaining.",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "More of Winona's weird junk.",
        	LOWPOWER = "It's on its last legs.",
        	OFF = "Oops. It broke.",
        	BURNING = "Hehehe!",
        	BURNT = "Well, that was mildly entertaining.",
        },

        --Wormwood
        COMPOSTWRAP = "That's disgusting!",
        ARMOR_BRAMBLE = "I think Wormwood made it.",
        TRAP_BRAMBLE = "It's got really sharp thorns.",

        BOATFRAGMENT03 = "Welp, there goes that.",
        BOATFRAGMENT04 = "Welp, there goes that.",
        BOATFRAGMENT05 = "Welp, there goes that.",
		BOAT_LEAK = "I only know how to solve fire-based problems.",
        MAST = "Are we allowed to climb it?",
        SEASTACK = "It's just a big boring sea rock.",
        FISHINGNET = "I love throwing things to catch other things!", --unimplemented
        ANTCHOVIES = "They taste super salty and gross.", --unimplemented
        STEERINGWHEEL = "Check out how fast I can spin it!!",
        ANCHOR = "Dropping it is a lot more fun than pulling it back up.",
        BOATPATCH = "Fixing stuff is boring, but necessary.",
        DRIFTWOOD_TREE =
        {
            BURNING = "YES!",
            BURNT = "Well, that was fun.",
            CHOPPED = "I could still burn the stump.",
            GENERIC = "This tree looks super weird.",
        },

        DRIFTWOOD_LOG = "Perfect for burning.",

        MOON_TREE =
        {
            BURNING = "HAHA, YES!",
            BURNT = "I don't feel as bad as I thought I would.",
            CHOPPED = "It's not gonna grow back.",
            GENERIC = "It's so pretty, I might actually feel bad burning it!",
        },
		MOON_TREE_BLOSSOM = "This would look even prettier if it was on fire.",

        MOONBUTTERFLY =
        {
        	GENERIC = "Hey, come back here!",
        	HELD = "Got you now.",
        },
		MOONBUTTERFLYWINGS = "They came off a dead butterfly, gross.",
        MOONBUTTERFLY_SAPLING = "Just an un-burned baby tree.",
        ROCK_AVOCADO_FRUIT = "I bet it'll taste good when it's ripe.",
        ROCK_AVOCADO_FRUIT_RIPE = "It's ripe!",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "I like it with just a pinch of fire.",
        ROCK_AVOCADO_FRUIT_SPROUT = "Ewww it's got a little arm.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It's not going to grow fruit anymore.",
			WITHERED = "Pfft, it's barely even hot out.",
			GENERIC = "It's a fruit bush of some sort.",
			PICKED = "Someone took the fruit already.",
			DISEASED = "EW, it smells!!", --unimplemented
            DISEASING = "I think it's getting sick.", --unimplemented
			BURNING = "Yesss!",
		},
        DEAD_SEA_BONES = "GROSS! What if I'd stepped on it by accident?",
        HOTSPRING =
        {
        	GENERIC = "So toasty and warm!",
        	BOMBED = "The bombs are fun to throw in.",
        	GLASS = "Should we smash it up?",
			EMPTY = "What's better than a hotspring? A fire pit!",
        },
        MOONGLASS = "What do we need glass for anyway?",
        MOONGLASS_CHARGED = "It's like there's a little fire inside.",
        MOONGLASS_ROCK = "That's a big chunk of glass!",
        BATHBOMB = "I still don't want to take a bath.",
        TRAP_STARFISH =
        {
            GENERIC = "Do starfish usually have so many teeth?",
            CLOSED = "Jeez, that was rude!",
        },
        DUG_TRAP_STARFISH = "I knew I didn't like you.",
        SPIDER_MOON =
        {
        	GENERIC = "I DEFINITELY have to burn that thing.",
        	SLEEPING = "Now's the perfect time to burn it.",
        	DEAD = "We should burn it. Just to be sure.",
        },
        MOONSPIDERDEN = "I hope it burns.",
		FRUITDRAGON =
		{
			GENERIC = "They're pretty cute.",
			RIPE = "Mmm... Roast dragonfruit.",
			SLEEPING = "Good night, little guy.",
		},
        PUFFIN =
        {
            GENERIC = "A bird! I wonder if it's tasty.",
            HELD = "Haha, I got you.",
            SLEEPING = "I bet I could sneak up on it now.",
        },

		MOONGLASSAXE = "The moon HATES trees.",
		GLASSCUTTER = "Haha, this thing could take an arm off!",

        ICEBERG =
        {
            GENERIC = "That's a lot of ice.", --unimplemented
            MELTED = "It looks pretty melted.", --unimplemented
        },
        ICEBERG_MELTED = "It looks pretty melted.", --unimplemented

        MINIFLARE = "I can't WAIT to light it!",

		MOON_FISSURE =
		{
			GENERIC = "Ew, I think it's whispering to me.",
			NOLIGHT = "Iunno, maybe we can jam stuff in it.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Almost done, I swear.",
            GENERIC = "Doesn't it feel nice to be back in one piece?",
        },

        MOON_ALTAR_IDOL = "Okay, let me take you home.",
        MOON_ALTAR_GLASS = "Yeah, of course I'll lug you over there.",
        MOON_ALTAR_SEED = "Where do you want to go?",

        MOON_ALTAR_ROCK_IDOL = "Something inside is calling for me.",
        MOON_ALTAR_ROCK_GLASS = "Something inside is calling for me.",
        MOON_ALTAR_ROCK_SEED = "Something inside is calling for me.",

        MOON_ALTAR_CROWN = "Y'know, this would be a lot easier if you weren't so heavy.",
        MOON_ALTAR_COSMIC = "Why do I get the feeling we aren't done yet?",

        MOON_ALTAR_ASTRAL = "Back together again.",
        MOON_ALTAR_ICON = "Alright, alright, let's get going.",
        MOON_ALTAR_WARD = "You're right, I really am the best for helping you out.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Watery nerd stuff.",
            BURNT = "Heh heh. Whoops.",
        },
        BOAT_ITEM = "That's the boat part of the boat.",
        STEERINGWHEEL_ITEM = "Can't sail without that.",
        ANCHOR_ITEM = "Ooo, let's build an anchor.",
        MAST_ITEM = "You can't call it \"sailing\" if you don't have a sail.",
        MUTATEDHOUND =
        {
        	DEAD = "Good riddance.",
        	GENERIC = "YUCK! What is that?!",
        	SLEEPING = "Ewww I can see it breathing.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Ew, it's dead.",
			GENERIC = "BURN IT.",
			SLEEPING = "I don't wanna wake it.",
		},
        CARRAT =
        {
        	DEAD = "Ew, it's dead.",
        	GENERIC = "I wanna roast it!",
        	HELD = "It keeps squirming.",
        	SLEEPING = "It's snoring.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "I bet we could eat that.",
            PICKED = "Nothing left to take.",
        },
		BULLKELP_ROOT = "Haha! This thing's great.",
        KELPHAT = "Yuck, it feels like snot.",
		KELP = "HEY! Who dares me to eat it raw?",
		KELP_COOKED = "Great, now I don't have to chew.",
		KELP_DRIED = "It's not half bad.",

		GESTALT = "It feels like they're speaking inside my head!",
        GESTALT_GUARD = "They sure hate those shadow creeps.",

		COOKIECUTTER = "Hey! What are you lookin' at?!",
		COOKIECUTTERSHELL = "Ha, I stole its house.",
		COOKIECUTTERHAT = "Matches my prickly personality.",
		SALTSTACK =
		{
			GENERIC = "Huh. That's... weird.",
			MINED_OUT = "Someone got all the salt already.",
			GROWING = "Okay, hear me out... what if I tried burning it?",
		},
		SALTROCK = "I wonder if it's flammable.",
		SALTBOX = "It'll keep my stuff from rotting, for a little while.",

		TACKLESTATION = "Gross, it looks full of bugs.",
		TACKLESKETCH = "Who even reads fishing magazines? Uh, apart from me right now...",

        MALBATROSS = "Uh... nice bird?",
        MALBATROSS_FEATHER = "Ha! That thing was just a featherweight after all.",
        MALBATROSS_BEAK = "Nasty.",
        MAST_MALBATROSS_ITEM = "You can really make a sail out of anything.",
        MAST_MALBATROSS = "Just think how much cooler it'd look if I set it on fire.",
		MALBATROSS_FEATHERED_WEAVE = "That took way too much effort.",

        GNARWAIL =
        {
            GENERIC = "Geez, look at the nose on that thing!",
            BROKENHORN = "Not so tough without your horn, are you?",
            FOLLOWER = "Yeah, that's right! You work for ME now!",
            BROKENHORN_FOLLOWER = "Ha! You look kinda dumb without your horn.",
        },
        GNARWAIL_HORN = "Ha ha, cool.",

        WALKINGPLANK = "So, who're we gonna make walk it?",
        OAR = "Rowing's dumb. Why don't we just use a sail?",
		OAR_DRIFTWOOD = "Ugh. Can it be someone else's turn to row?",

		OCEANFISHINGROD = "Nowhere to hide now, fish!",
		OCEANFISHINGBOBBER_NONE = "Doesn't it need a float or something?",
        OCEANFISHINGBOBBER_BALL = "How am I supposed to burn it when it's in the water?",
        OCEANFISHINGBOBBER_OVAL = "How am I supposed to burn it when it's in the water?",
		OCEANFISHINGBOBBER_CROW = "How am I supposed to burn it when it's in the water?",
		OCEANFISHINGBOBBER_ROBIN = "How am I supposed to burn it when it's in the water?",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "How am I supposed to burn it when it's in the water?",
		OCEANFISHINGBOBBER_CANARY = "How am I supposed to burn it when it's in the water?",
		OCEANFISHINGBOBBER_GOOSE = "What if, now hear me out... I just set it on fire?",
		OCEANFISHINGBOBBER_MALBATROSS = "What if, now hear me out... I just set it on fire?",

		OCEANFISHINGLURE_SPINNER_RED = "Ha! Fish are so dumb- Ow! Man, that's sharp.",
		OCEANFISHINGLURE_SPINNER_GREEN = "Ha! Fish are so dumb- Ow! Man, that's sharp.",
		OCEANFISHINGLURE_SPINNER_BLUE = "Ha! Fish are so dumb- Ow! Man, that's sharp.",
		OCEANFISHINGLURE_SPOON_RED = "Ha! Fish are so dumb- Ow! Man, that's sharp.",
		OCEANFISHINGLURE_SPOON_GREEN = "Ha! Fish are so dumb- Ow! Man, that's sharp.",
		OCEANFISHINGLURE_SPOON_BLUE = "Ha! Fish are so dumb- Ow! Man, that's sharp.",
		OCEANFISHINGLURE_HERMIT_RAIN = "Ugh. Why would I wanna do anything in the rain?",
		OCEANFISHINGLURE_HERMIT_SNOW = "Guess I can catch a fish and a cold at the same time.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Wait, what was I doing? Oh cool, a new lure!",
		OCEANFISHINGLURE_HERMIT_HEAVY = "This lure's making a face at me...",

		OCEANFISH_SMALL_1 = "Just a dumb little fish.",
		OCEANFISH_SMALL_2 = "What the-? It's so small!",
		OCEANFISH_SMALL_3 = "Hey! I thought you were gonna be a big fish!",
		OCEANFISH_SMALL_4 = "Looks more like a shrimp to me.",
		OCEANFISH_SMALL_5 = "Weird...",
		OCEANFISH_SMALL_6 = "I get the feeling it would make great kindling.",
		OCEANFISH_SMALL_7 = "You've uh... got something growing on your forehead.",
		OCEANFISH_SMALL_8 = "It's so sad... a fellow firebug forced to live its life underwater!",
        OCEANFISH_SMALL_9 = "Hey! Go spit at somebody else!",

		OCEANFISH_MEDIUM_1 = "Ew, that thing looks nasty!",
		OCEANFISH_MEDIUM_2 = "Quit looking at me like that!",
		OCEANFISH_MEDIUM_3 = "What's so dandy about it?",
		OCEANFISH_MEDIUM_4 = "Ha! I'm not scared of a little bad luck.",
		OCEANFISH_MEDIUM_5 = "What... is it?",
		OCEANFISH_MEDIUM_6 = "It's kind of pretty for something that lives in the water.",
		OCEANFISH_MEDIUM_7 = "It's kind of pretty for something that lives in the water.",
		OCEANFISH_MEDIUM_8 = "I dare someone to lick it!",
        OCEANFISH_MEDIUM_9 = "Another stupid fish.",

		PONDFISH = "Slippery fishy!",
		PONDEEL = "I don't like the look it's giving me!",

        FISHMEAT = "Needs fire!",
        FISHMEAT_COOKED = "Less slippery now that it's found fire.",
        FISHMEAT_SMALL = "I like sushi, but I prefer it flame-broiled.",
        FISHMEAT_SMALL_COOKED = "Fish and fire go well together.",
		SPOILED_FISH = "Gross.",

		FISH_BOX = "Did we just... put a hole in the boat?",
        POCKET_SCALE = "Hey, now I can weigh my fish... not that I care.",

		TACKLECONTAINER = "I usually like my stuff in a state of organized chaos.",
		SUPERTACKLECONTAINER = "Bet I could cram a lot more stuff in there.",

		TROPHYSCALE_FISH =
		{
			GENERIC = "Who cares about weighing some dumb fish?",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nHow does it even fit in there?",
			BURNING = "Heh... wasn't sure if that would work.",
			BURNT = "Nice.",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nPfft, that wasn't even hard.",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nRead it and weep!",
		},

		OCEANFISHABLEFLOTSAM = "Just a big hunk of yuck.",

		CALIFORNIAROLL = "Oh, goody. Fish rolled in seaweed.",
		SEAFOODGUMBO = "Ew, what IS this?",
		SURFNTURF = "Ugh. This is old person food!",

        WOBSTER_SHELLER = "I could go for some flame-roasted wobster.",
        WOBSTER_DEN = "Come on out little guys, I just want to roast ya!",
        WOBSTER_SHELLER_DEAD = "Edible in a pinch.",
        WOBSTER_SHELLER_DEAD_COOKED = "Lobster for dinner! Pinch me!",

        LOBSTERBISQUE = "I'm gonna eat this entire thing!",
        LOBSTERDINNER = "Yummmmmmm!",

        WOBSTER_MOONGLASS = "They still taste the same, right? Right...?",
        MOONGLASS_WOBSTER_DEN = "We should try smoking them out.",

		TRIDENT = "It's three times as pokey.",

		WINCH =
		{
			GENERIC = "It's only good for grabbing junk from the bottom of the ocean.",
			RETRIEVING_ITEM = "Come on alreadyyyy...",
			HOLDING_ITEM = "Unless it's something flammable, I'm not that interested.",
		},

        HERMITHOUSE = {
            GENERIC = "What a dump.",
            BUILTUP = "I never needed a home, but some people do I guess.",
        },

        SHELL_CLUSTER = "Just a bunch of shells.",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "Ew, it's making noises!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Those things freak me out.",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Nope. No thanks.",
        },

        CHUM = "Ew, fish eat that nasty stuff?",

        SUNKENCHEST =
        {
            GENERIC = "Sooo... I can burn it now, right?",
            LOCKED = "Aw, c'mon!",
        },

        HERMIT_BUNDLE = "Nice, free stuff!",
        HERMIT_BUNDLE_SHELLS = "Great, more shells I can't burn. Why did I buy these again?",

        RESKIN_TOOL = "Oh yeah, I'm gonna have fun with this.",
        MOON_FISSURE_PLUGGED = "Ohh, so that's how she keeps those creeps away.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "She's just a big pushover.",
            "She's just a big pushover.",
        },
        WOBYSMALL =
        {
            "She's a smelly, weird little dog. I like her!",
            "She's a smelly, weird little dog. I like her!",
        },
		WALTERHAT = "Okay fine, so I wasn't \"in\" girl scouts so much as \"crashed\" girl scouts.",
		SLINGSHOT = "Oooh, now this could do some damage.",
		SLINGSHOTAMMO_ROCK = "Ever considered making your ammo a little more flammable?",
		SLINGSHOTAMMO_MARBLE = "Ever considered making your ammo a little more flammable?",
		SLINGSHOTAMMO_THULECITE = "Ever considered making your ammo a little more flammable?",
        SLINGSHOTAMMO_GOLD = "Ever considered making your ammo a little more flammable?",
        SLINGSHOTAMMO_SLOW = "Ever considered making your ammo a little more flammable?",
        SLINGSHOTAMMO_FREEZE = "Ever considered making your ammo a little more flammable?",
		SLINGSHOTAMMO_POOP = "Flammable enough for me!",
        PORTABLETENT = "I call dibs on the tent!",
        PORTABLETENT_ITEM = "I was never any good at setting these things up.",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Hey look, fancy kindling!",
        BATTLESONG_HEALTHGAIN = "Hey look, fancy kindling!",
        BATTLESONG_SANITYGAIN = "Hey look, fancy kindling!",
        BATTLESONG_SANITYAURA = "Hey look, fancy kindling!",
        BATTLESONG_FIRERESISTANCE = "Hey look, fancy kindling!",
        BATTLESONG_INSTANT_TAUNT = "Heh. Okay, I'm using that one.",
        BATTLESONG_INSTANT_PANIC = "Boring words I don't care about.",

        -- Webber
        MUTATOR_WARRIOR = "Give one to Wilson, I'm sure he'd loooove to try it! Heheh.",
        MUTATOR_DROPPER = "Eww, there's legs sticking out of it!",
        MUTATOR_HIDER = "Give one to Wilson, I'm sure he'd loooove to try it! Heheh.",
        MUTATOR_SPITTER = "Eww, there's legs sticking out of it!",
        MUTATOR_MOON = "Give one to Wilson, I'm sure he'd loooove to try it! Heheh.",
        MUTATOR_HEALER = "Eww, there's legs sticking out of it!",
        SPIDER_WHISTLE = "Nu-uh, I'm not putting that thing anywhere near my face.",
        SPIDERDEN_BEDAZZLER = "Hey Webber, it's way more fun to burn paper than to draw on it!",
        SPIDER_HEALER = "Ew, it stinks!",
        SPIDER_REPELLENT = "Well it might not work, but at least it makes noise!",
        SPIDER_HEALER_ITEM = "Ewww it's all goopy!",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "Someone should probably check if it's flammable. I volunteer!",
		GHOSTLYELIXIR_FASTREGEN = "Someone should probably check if it's flammable. I volunteer!",
		GHOSTLYELIXIR_SHIELD = "Someone should probably check if it's flammable. I volunteer!",
		GHOSTLYELIXIR_ATTACK = "Someone should probably check if it's flammable. I volunteer!",
		GHOSTLYELIXIR_SPEED = "Someone should probably check if it's flammable. I volunteer!",
		GHOSTLYELIXIR_RETALIATION = "Someone should probably check if it's flammable. I volunteer!",
		SISTURN =
		{
			GENERIC = "A pyre would've been more fun.",
			SOME_FLOWERS = "You're doing it wrong, those flowers aren't dry enough to burn!",
			LOTS_OF_FLOWERS = "I guess it's kind of pretty...",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Just a dumb pot.",
            DONE = "Good. Let's eat!",

			COOKING_LONG = "Ughhh, this is taking forever!",
			COOKING_SHORT = "Come on fire, do your thing!",
			EMPTY = "Stupid empty pot.",
        },

        PORTABLEBLENDER_ITEM = "Shakes things up a bit.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "All that work better be worth it.",
            DONE = "All that work for just a little bit of spice?",
        },
        SPICEPACK = "I'm sure Warly won't mind if I borrow this.",
        SPICE_GARLIC = "Powdered stink.",
        SPICE_SUGAR = "It's like drinking candy.",
        SPICE_CHILI = "I like the way it sets my mouth on fire.",
        SPICE_SALT = "People say I'M salty.",
        MONSTERTARTARE = "Gross!",
        FRESHFRUITCREPES = "Ooo la la.",
        FROGFISHBOWL = "Woah, that's a ton of frogs.",
        POTATOTORNADO = "Woah, I didn't know potatoes came in that shape!",
        DRAGONCHILISALAD = "I can't wait to eat it.",
        GLOWBERRYMOUSSE = "That's definitely going in my mouth.",
        VOLTGOATJELLY = "HEY WARLY! Can I eat this?",
        NIGHTMAREPIE = "I'm sure he wouldn't mind if I stole a nibble.",
        BONESOUP = "I would practically INHALE that!",
        MASHEDPOTATOES = "I LOVE mashed potatoes.",
        POTATOSOUFFLE = "MY stuff never comes out looking like THIS!",
        MOQUECA = "It looks soooo good!",
        GAZPACHO = "I prefer hot food.",
        ASPARAGUSSOUP = "Even water and vegetables taste better with fire.",
        VEGSTINGER = "Fire for my tongue.",
        BANANAPOP = "This is the opposite of burning.",
        CEVICHE = "It's still slimy.",
        SALSA = "Hey, this is great!",
        PEPPERPOPPER = "My mouth is on fire!",

        TURNIP = "Haha gross, I hate turnips.",
        TURNIP_COOKED = "Take that, turnip.",
        TURNIP_SEEDS = "It's just a bunch of seeds.",

        GARLIC = "It's just a couple cloves of garlic.",
        GARLIC_COOKED = "Fire made it better.",
        GARLIC_SEEDS = "It's just a bunch of seeds.",

        ONION = "It's so bulbous.",
        ONION_COOKED = "Roasting. My favorite cooking method.",
        ONION_SEEDS = "It's just a bunch of seeds.",

        POTATO = "We grew it in that gross muck.",
        POTATO_COOKED = "Cooking just means sticking stuff in fire.",
        POTATO_SEEDS = "It's just a bunch of seeds.",

        TOMATO = "Cutting these is a pain.",
        TOMATO_COOKED = "It just needed a couple minutes on the fire.",
        TOMATO_SEEDS = "It's just a bunch of seeds.",

        ASPARAGUS = "They're all chewy like this. They need fire.",
        ASPARAGUS_COOKED = "Not so chewy now, are you?",
        ASPARAGUS_SEEDS = "This'll make some food.",

        PEPPER = "Good. These are the hot ones.",
        PEPPER_COOKED = "First rule of vegetables: fire makes it better.",
        PEPPER_SEEDS = "It's just a bunch of seeds.",

        WEREITEM_BEAVER = "He wouldn't mind if I use this for kindling, right?",
        WEREITEM_GOOSE = "Burn it. BURN. IT.",
        WEREITEM_MOOSE = "Yup, looks cursed alright.",

        MERMHAT = "Yuck, who'd want a face like that?",
        MERMTHRONE =
        {
            GENERIC = "I shouldn't burn it... but I want to...",
            BURNT = "Did I do that? It's hard to keep track.",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "What's all this stuff for?",
            BURNT = "Hahaha-! Uh, I mean, oh no...",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Looks just as flammable as the old ones.",
            BURNT = "I feel a little bad... actually, no I don't.",
        },

        MERMWATCHTOWER_REGULAR = "Ugh, the SMELL coming from that thing!",
        MERMWATCHTOWER_NOKING = "I bet that would catch fire reeeal easy.",
        MERMKING = "Are you supposed to be important or something?",
        MERMGUARD = "I can't tell which way it's looking.",
        MERM_PRINCE = "What makes that guy so special?",

        SQUID = "No substitute for a good torch.",

		GHOSTFLOWER = "Great. Another spooky flower.",
        SMALLGHOST = "What are you looking at, pipsqueak?",

        CRABKING =
        {
            GENERIC = "He doesn't look too happy...",
            INERT = "I think it could use something glittery.",
        },
		CRABKING_CLAW = "Keep your claws off my boat!",

		MESSAGEBOTTLE = "Hey! It's a bottle of emergency kindling!",
		MESSAGEBOTTLEEMPTY = "Just a boring old bottle.",

        MEATRACK_HERMIT =
        {
            DONE = "Hey lady, your jerky's ready!",
            DRYING = "Come on meat, dry already!",
            DRYINGINRAIN = "Forget the rain! Dry!",
            GENERIC = "Maybe I'll leave some meat here before I leave...",
            BURNT = "Maybe the fire wasn't the best drying method...",
            DONE_NOTMEAT = "It's ready!",
            DRYING_NOTMEAT = "How long does it take this stuff to dry?!",
            DRYINGINRAIN_NOTMEAT = "Forget the rain! Dry!",
        },
        BEEBOX_HERMIT =
        {
            READY = "She won't be mad if I steal a liiiittle honey, right?",
            FULLHONEY = "She won't be mad if I steal a liiiittle honey, right?",
            GENERIC = "Wow, her bees are about as friendly as she is.",
            NOHONEY = "Nothing to see here.",
            SOMEHONEY = "Patience.",
            BURNT = "Smoked you out!",
        },

        HERMITCRAB = "Heh. I kinda like her.",

        HERMIT_PEARL = "Don't worry grams, it's safe with me!",
        HERMIT_CRACKED_PEARL = "Oops...",

        -- DSEAS
        WATERPLANT = "Just a big dumb flower.",
        WATERPLANT_BOMB = "Okay, I'm sorry I called you dumb!",
        WATERPLANT_BABY = "It's small now, but it'll get bigger.",
        WATERPLANT_PLANTER = "Do I really want to grow more of these things?",

        SHARK = "Uhh... nice fishy?",

        MASTUPGRADE_LAMP_ITEM = "Alternatively, I could just set the mast on fire.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "That's where the lightning goes.",

        WATERPUMP = "This thing's broken, it spouts water instead of fire!",

        BARNACLE = "Ew, it came from the water.",
        BARNACLE_COOKED = "Fire made it better.",

        BARNACLEPITA = "Pita pita, barnacle eater.",
        BARNACLESUSHI = "I can still see the barnacle hiding under there.",
        BARNACLINGUINE = "Don't mind if I do.",
        BARNACLESTUFFEDFISHHEAD = "You know, I don't think I'm that hungry after all.",

        LEAFLOAF = "Uh, is it supposed to be green?",
        LEAFYMEATBURGER = "Does this burger taste weird to anyone else?",
        LEAFYMEATSOUFFLE = "What kind of monster would combine dessert with vegetables?",
        MEATYSALAD = "Wait... what ARE these leaves?",

        -- GROTTO

		MOLEBAT = "Haha gross! I just saw it eat something through its nose!",
        MOLEBATHILL = "Ew, is it sleeping in its own snot?",

        BATNOSE = "Ewww.",
        BATNOSE_COOKED = "Is that supposed to make it better?",
        BATNOSEHAT = "Is that even a real hat?",

        MUSHGNOME = "Ew, it's dropping spores everywhere!",

        SPORE_MOON = "Alright, I get the message! I'll stay away!",

        MOON_CAP = "What a weird looking mushroom.",
        MOON_CAP_COOKED = "Once again, fire makes it better.",

        MUSHTREE_MOON = "Bet this would look really nice if I set it on fire.",

        LIGHTFLIER = "I'd rather use fire to light my way.",

        GROTTO_POOL_BIG = "Ugh, this whole place is damp and gross! I hate it!",
        GROTTO_POOL_SMALL = "Ugh, this whole place is damp and gross! I hate it!",

        DUSTMOTH = "They just clean all day? What a boring life.",

        DUSTMOTHDEN = "It's not flammable. Not that I tried or anything.",

        ARCHIVE_LOCKBOX = "Great. We turned on the mysterious thing and got another mysterious thing.",
        ARCHIVE_CENTIPEDE = "Burn, bug!",
        ARCHIVE_CENTIPEDE_HUSK = "Just a bunch of broken parts.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "The fire still has quite a bit of work to do.",
            COOKING_SHORT = "The fire is doing its thing!",
            DONE = "Fire makes everything better. Mmm!",
            EMPTY = "Fire's the best ancient invention there is!",
            BURNT = "At least it went out in a blaze of glory.",
        },

        ARCHIVE_MOON_STATUE = "Huh. These look different from the other statues down here.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "A bunch of old mumbo jumbo.",
            LINE_2 = "If it doesn't burn I don't care.",
            LINE_3 = "A bunch of old mumbo jumbo.",
            LINE_4 = "If it doesn't burn I don't care.",
            LINE_5 = "A bunch of old mumbo jumbo.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "Point the way!",
            IDLE = "Nothing left to find, I guess.",
        },

        ARCHIVE_RESONATOR_ITEM = "It's humming to itself.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "Looks like it's busted.",
          GENERIC =  "Ugh, I feel a puzzle coming on...",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "Whatever it is, it's not working.",
            GENERIC = "Yeah, that doesn't look suspicious.",
        },

        ARCHIVE_SECURITY_PULSE = "Hey! Get back here!",

        ARCHIVE_SWITCH = {
            VALID = "I'm sure nobody would mind if I borrowed one of those gems.",
            GEMS = "Something's missing here.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Another portal? You don't think...?",
            GENERIC = "Shoulda known it wouldn't be that easy.",
        },

        WALL_STONE_2 = "Eh. I guess that's okay.",
        WALL_RUINS_2 = "And they'll huff and they'll puff!",

        REFINED_DUST = "Great. What am I supposed to do with this stuff?",
        DUSTMERINGUE = "Yeah, I don't think I'm THAT hungry.",

        SHROOMCAKE = "Cake's cake, pass it here.",

        NIGHTMAREGROWTH = "That's probably not... great...",

        TURFCRAFTINGSTATION = "I guess I could use a change in scenery.",

        MOON_ALTAR_LINK = "Aw c'mon! What is it?!",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Ew, why do we have this?",
            WET = "It's all wet and gross.",
            DRY = "Is it supposed to be that dry?",
            BALANCED = "I guess it looks okay? For a pile of rotten dirt?",
            BURNT = "Nice.",
        },
        COMPOST = "Nah, I'm good.",
        SOIL_AMENDER =
		{
			GENERIC = "Gross.",
			STALE = "Yup, stuff's happening in there alright.",
			SPOILED = "Let's hope this works as well as it stinks.",
		},

		SOIL_AMENDER_FERMENTED = "Yeesh, plants actually like this stuff?",

        WATERINGCAN =
        {
            GENERIC = "Ugh, who put this water here?!",
            EMPTY = "That's more like it.",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "Ha. It looks stupid.",
            EMPTY = "Reassuringly dry.",
        },

		FARM_PLOW = "Yeah, fight that ground!",
		FARM_PLOW_ITEM = "Guess I better find a dumb spot to plant some dumb plants.",
		FARM_HOE = "Farming is so much work...",
		GOLDEN_FARM_HOE = "It won't help fires grow, but at least it's shiny.",
		NUTRIENTSGOGGLESHAT = "Wow, I always wanted dirt vision... said nobody ever.",
		PLANTREGISTRYHAT = "Nooo I don't want my head full of plant nerd facts!",

        FARM_SOIL_DEBRIS = "Get outta here!",

		FIRENETTLES = "What do you mean it's a weed? Looks like an improvement to me!",
		FORGETMELOTS = "Some more dumb flowers.",
		SWEETTEA = "What's so great about it? It's just leaf juice.",
		TILLWEED = "Stupid weed.",
		TILLWEEDSALVE = "I guess that weed was good for something.",
        WEED_IVY = "It's all spiny.",
        IVY_SNARE = "Get outta here you stupid weed!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Oooh, that basket looks flammable!",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nWow. Exciting.",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nMore to burn.",
            HAS_ITEM_LIGHT = "Hey is this thing broken? It's not even showing the weight!",
			BURNING = "Yeah, now we're talking!",
			BURNT = "Aw, over already?",
        },

        CARROT_OVERSIZED = "A big old carrot.",
        CORN_OVERSIZED = "Let's get this thing on the fire!",
        PUMPKIN_OVERSIZED = "I could stick the biggest candle in there! It'll be great!",
        EGGPLANT_OVERSIZED = "What am I supposed to do with all this eggplant?!",
        DURIAN_OVERSIZED = "Of course THIS is the one that grows well...",
        POMEGRANATE_OVERSIZED = "I bet it looks super gross inside!",
        DRAGONFRUIT_OVERSIZED = "I wish it was a fire-breathing Dragonfruit.",
        WATERMELON_OVERSIZED = "Ugh, way too much water!",
        TOMATO_OVERSIZED = "Ugh, it's going to be even harder to cut now...",
        POTATO_OVERSIZED = "Let's roast this thing!",
        ASPARAGUS_OVERSIZED = "I have a feeling it'll be asparagus leftovers for a long time...",
        ONION_OVERSIZED = "I've got to figure out what I'm gonna do with all this onion...",
        GARLIC_OVERSIZED = "I bet my breath would smell great if I ate the whole thing.",
        PEPPER_OVERSIZED = "That's a lot of hot stuff!",

        VEGGIE_OVERSIZED_ROTTEN = "A big pile of stinky mush.",

		FARM_PLANT =
		{
			GENERIC = "A dumb plant.",
			SEED = "Ugh, this is going to take ages.",
			GROWING = "Grow faster already!",
			FULL = "Took long enough.",
			ROTTEN = "Yeah... I'm not eating that.",
			FULL_OVERSIZED = "Well that looks kind of unnatural.",
			ROTTEN_OVERSIZED = "A big pile of stinky mush.",
			FULL_WEED = "Wait, what kind of vegetable is that supposed to be?",

			BURNING = "Heh heh.",
		},

        FRUITFLY = "Get lost, you dumb bugs!",
        LORDFRUITFLY = "You think you can barge in here and mess up the garden? That's my job!",
        FRIENDLYFRUITFLY = "Hey, this one's actually helping!",
        FRUITFLYFRUIT = "Now I'm the one giving the orders! To fruit flies, but still.",

        SEEDPOUCH = "It would be even easier to just set all the seeds on fire.",

		-- Crow Carnival
		CARNIVAL_HOST = "I like him.",
		CARNIVAL_CROWKID = "I wonder where they've been hiding all this time.",
		CARNIVAL_GAMETOKEN = "What is this, bird money?",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "Hey, kindling!",
			GENERIC_SMALLSTACK = "That'll make a nice little fire.",
			GENERIC_LARGESTACK = "What a perfectly flammable pile.",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "A little door to nowhere special.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "I've uh... never actually been to a carnival before. Do I give it something?",
			PLAYING = "Heh. This actually looks kinda fun.",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "Aw come on, I've got to set it up myself?",
		CARNIVALGAME_FEEDCHICKS_FOOD = "They're fake worms, but I could use them to set a real fire!",

		CARNIVALGAME_MEMORY_KIT = "Aw come on, I've got to set it up myself?",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "I've uh... never actually been to a carnival before. Do I give it something?",
			PLAYING = "Too much brain work, this one gets the torch.",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "A little door to nowhere special.",
			PLAYING = "Yeah, that's the one!",
		},

		CARNIVALGAME_HERDING_KIT = "Aw come on, I've got to set it up myself?",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "I've uh... never actually been to a carnival before. Do I give it something?",
			PLAYING = "Run eggs, run!",
		},
		CARNIVALGAME_HERDING_CHICK = "Hey! Get back here!",

		CARNIVAL_PRIZEBOOTH_KIT = "Uuuugh, one more thing to build.",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Ooooh, prizes!",
		},

		CARNIVALCANNON_KIT = "Hehehe, this will be fun.",
		CARNIVALCANNON =
		{
			GENERIC = "Let's liven things up a bit!",
			COOLDOWN = "I only wish it had a more fiery explosion.",
		},

		CARNIVAL_PLAZA_KIT = "Why don't I just burn it and call it a day?",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Hm, the ground around it does looks kind of empty...",
			LEVEL_2 = "I think those weird birds like the decorations.",
			LEVEL_3 = "Alright, I'm bored of decorating. Moving on.",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "Can somebody else put it together for me?",
		CARNIVALDECOR_EGGRIDE = "Can you imagine how great that would look if it was on fire?",

		CARNIVALDECOR_LAMP_KIT = "Can somebody else put it together for me?",
		CARNIVALDECOR_LAMP = "It makes light, but no fire. Creepy.",
		CARNIVALDECOR_PLANT_KIT = "Can somebody else put it together for me?",
		CARNIVALDECOR_PLANT = "Guess this tree never got its growth spurt.",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "Wow, a rare one! I bet it'll burn even better!",
			UNCOMMON = "If I gather enough of these I could make a pretty good bonfire.",
			GENERIC = "Aww, it's so cute and flammable!",
		},
		CARNIVALDECOR_FIGURE_KIT = "Ooooh what's in the box?",

        CARNIVAL_BALL = "Think fast, Maxwell!", --unimplemented
		CARNIVAL_SEEDPACKET = "Ugh, bird food.",
		CARNIVALFOOD_CORNTEA = "It keeps getting stuck in my teeth.",

        CARNIVAL_VEST_A = "Flaming red, just how I like it!",
        CARNIVAL_VEST_B = "Just don't wear that too close to an open flame. Or do... heh heh.",
        CARNIVAL_VEST_C = "Breezy.",

        -- YOTB
        YOTB_SEWINGMACHINE = "I never liked sewing.",
        YOTB_SEWINGMACHINE_ITEM = "What a nice pile of kindling!",
        YOTB_STAGE = "You think you can judge me?!",
        YOTB_POST =  "Setting one of these on fire would make the contest way more exciting.",
        YOTB_STAGE_ITEM = "Ughhh, so much wooorrkk...",
        YOTB_POST_ITEM =  "Here's an idea - instead of building it I just set it on fire!",


        YOTB_PATTERN_FRAGMENT_1 = "Looks like I'll have to put a few of these together to make anything worthwhile.",
        YOTB_PATTERN_FRAGMENT_2 = "Looks like I'll have to put a few of these together to make anything worthwhile.",
        YOTB_PATTERN_FRAGMENT_3 = "Looks like I'll have to put a few of these together to make anything worthwhile.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "You and Bernie will get along great!",
            YOTB = "Hey judge! Get a load of this!",
        },

        WAR_BLUEPRINT = "Ooooh, looks dangerous!",
        DOLL_BLUEPRINT = "Awww, my beefalo's gonna be so hideous and adorable!",
        FESTIVE_BLUEPRINT = "It needs more firecrackers before I'd call it \"festive\".",
        ROBOT_BLUEPRINT = "Uh, is this really a sewing pattern?",
        NATURE_BLUEPRINT = "Once the flowers dry out they'll make nice kindling.",
        FORMAL_BLUEPRINT = "Ugh, it looks so stuffy and proper.",
        VICTORIAN_BLUEPRINT = "Ha! This is gonna look hilarious!",
        ICE_BLUEPRINT = "Don't beefalo already have hairy winter coats?",
        BEAST_BLUEPRINT = "My beefalo's already a lucky beast. He gets to be my friend!",

        BEEF_BELL = "Wow, making friends is easy!",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "They're so small that they all fit.",
            BURNT = "Nice. Hope they evacuated, though. ",
			PLAYING_HIDEANDSEEK = "They're out playing, let's go find em'!",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "Time's almost up, they're not gonna hide at home!!! Or is that what they want me to think... nope, it's empty, aargh!",
		},

		KITCOONDEN_KIT = "Everything you need to build a precariously balanced house for kitcoons.",

		TICOON = 
		{
			GENERIC = "What a fancy, tired looking catcoon. Maybe he's a businessman.",
			ABANDONED = "I don't need your help!",
			SUCCESS = "Haha, he got you!",
			LOST_TRACK = "Drat, looks like someone beat me to it.",
			NEARBY = "There's a kitcoon around here, I can feel it...",
			TRACKING = "Looks like he's onto something!",
			TRACKING_NOT_MINE = "That's not my guy.",
			NOTHING_TO_TRACK = "Looks like he's not findin' anything.",
			TARGET_TOO_FAR_AWAY = "Don't think his nose can sniff that far.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "Alright, what festive goodies can we get from ya?",
            EMPTY = "You're askin' for donations now?",
            BURNT = "Heh.",
        },

		KITCOON_FOREST = "You're very small and squeaky.",
		KITCOON_SAVANNA = "You're very small and squeaky.",
		KITCOON_MARSH = "You're very small and squeaky.",
		KITCOON_DECIDUOUS = "You're very small and squeaky.",
		KITCOON_GRASS = "You're very small and squeaky.",
		KITCOON_ROCKY = "You're very small and squeaky.",
		KITCOON_DESERT = "You're very small and squeaky.",
		KITCOON_MOON = "You're very small and squeaky.",
		KITCOON_YOT = "You're very small and squeaky.",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Ugh, I KNEW we shouldn't have been messing with all that dumb science junk.",
            DEAD = "Heh. Take that moon, or whatever!",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "You think you're so tough?! Burn!",
            DEAD = "Got it for sure that time.",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "Ugh, get these things out of my way!",
        ALTERGUARDIAN_PHASE3 = "Pretty, but it'll be even prettier when it burns!",
        ALTERGUARDIAN_PHASE3TRAP = "Hey, that's just playing dirty!",
        ALTERGUARDIAN_PHASE3DEADORB = "Uh, hey old guy? You might not want to get that close...",
        ALTERGUARDIAN_PHASE3DEAD = "Guess it's finally done.",

        ALTERGUARDIANHAT = "It makes the inside of my head so noisy...",
        ALTERGUARDIANHATSHARD = "It was surprisingly hard to pull that thing apart.",

        MOONSTORM_GLASS = {
            GENERIC = "Hey, I can see my reflection!",
            INFUSED = "It's like there's a little fire inside."
        },

        MOONSTORM_STATIC = "Don't get zapped, old man.",
        MOONSTORM_STATIC_ITEM = "It crackles, almost like a fire.",
        MOONSTORM_SPARK = "I'm gonna touch it.",

        BIRD_MUTANT = "It looks like it wants to take a bite out of me.",
        BIRD_MUTANT_SPITTER = "Oh yeah?! Two can play at that game... PTOOEY!",

        WAGSTAFF_NPC = "Uuuugh, old people always seem to need help with something or other.",
        ALTERGUARDIAN_CONTAINED = "What's that weird machine?",

        WAGSTAFF_TOOL_1 = "I've got a feeling this belongs to that old guy.",
        WAGSTAFF_TOOL_2 = "Ugh, couldn't that old guy have just gotten it himself?",
        WAGSTAFF_TOOL_3 = "Yeah, that looks like a Whaddayacallit! Or was it a Whatchamahoosit...",
        WAGSTAFF_TOOL_4 = "Welp, it doesn't seem to be flammable. Might as well give it to that old guy.",
        WAGSTAFF_TOOL_5 = "Looks like some weird science junk. Maybe that's what the old guy's looking for?",

        MOONSTORM_GOGGLESHAT = "At least I'll be wearing it in the storm where nobody can see me.",

        MOON_DEVICE = {
            GENERIC = "Great! So what does it do?",
            CONSTRUCTION1 = "Uuuugh, why can't that old guy just build this thing himself?",
            CONSTRUCTION2 = "I guess I could just burn it and be done with it, but now I'm kinda curious...",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Why worry about the past or future? It'll all go up in flames eventually.",
			RECHARGING = "It's not doing much right now.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Why worry about the past or future? It'll all go up in flames eventually.",
			RECHARGING = "It's not doing much right now.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Why worry about the past or future? It'll all go up in flames eventually.",
			RECHARGING = "It's not doing much right now.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Why worry about the past or future? It'll all go up in flames eventually.",
			RECHARGING = "It's not doing much right now.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Why worry about the past or future? It'll all go up in flames eventually.",
			RECHARGING = "It's not doing much right now.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "That looks dangerous. I wanna try!",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Some weird clock junk.",
        POCKETWATCH_DISMANTLER = "A bunch of little tools.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Am I really just gonna jump into any old portal I see? Yep!",
			DIFFERENTSHARD = "Am I really just gonna jump into any old portal I see? Yep!",
		},
        POCKETWATCH_PORTAL_EXIT = "It's fun to watch OTHER people fall on their butts.",

        -- Waterlog
        WATERTREE_PILLAR = "The bigger the tree, the more there is to burn.",
        OCEANTREE = "Heh, you thought you'd be safe from my lighter out here on the water?",
        OCEANTREENUT = "Ugh, it's still wet.",
        WATERTREE_ROOT = "I bet it'll still burn.",

        OCEANTREE_PILLAR = "Hey, it's gonna stop the sun from burning things!",
        
        OCEANVINE = "Oh look, a really long wick!",
        FIG = "Looks like old people fruit.",
        FIG_COOKED = "As usual, fire made it better.",

        SPIDER_WATER = "Get outta the water so I can burn you!",
        MUTATOR_WATER = "Give one to Wilson, I'm sure he'd loooove to try it! Heheh.",
        OCEANVINE_COCOON = "Ewww look at it just dangling up there!",
        OCEANVINE_COCOON_BURNT = "Fire is a quick redecorator.",

        GRASSGATOR = "It needs a haircut.",

        TREEGROWTHSOLUTION = "Eww tree gunk!",

        FIGATONI = "I won't turn down a plate of pasta.",
        FIGKABAB = "When I'm done with the food I can burn the stick!",
        KOALEFIG_TRUNK = "Sweet and rubbery.",
        FROGNEWTON = "All that fig almost masks the frog flavor.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "What horrors will you unleash upon our world?",
            CRIMSON = "Oh yuck, it looks all gross inside!",
            ENABLED = "Oooh... Aaah...",
			WAITING_FOR_DARK = "Oooh, maybe it's getting ready to explode!",
			COOLDOWN = "I hope it does fireworks instead of rainbows next time.",
			SPAWN_DISABLED = "Looks like the fun's over.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "You know what this strongman show needs? Pyrotechnics!",
            BURNT = "I don't know what Wolfgang's so upset about, I thought the fire effects were great!",
        },

        DUMBBELL = "Quit making stuff I can't burn!",
        DUMBBELL_GOLDEN = "Did he really need to make it so fancy?",
		DUMBBELL_MARBLE = "Did he really need to make it so fancy?",
        DUMBBELL_GEM = "Did he really need to make it so fancy?",
        POTATOSACK = "I could make it a roasted potato sack, just say the word!",


        TERRARIUMCHEST = 
		{
			GENERIC = "It'll be a nice place to put my stuff while I'm out burning.",
			BURNT = "Do it again! Again!",
			SHIMMER = "Please have fireworks inside, pleeeease!",
		},

		EYEMASKHAT = "Well, looks aren't everything.",

        EYEOFTERROR = "What's your problem? Quit staring!",
        EYEOFTERROR_MINI = "Ew ew ew!!",
        EYEOFTERROR_MINI_GROUNDED = "Squish it!!",

        FROZENBANANADAIQUIRI = "Ew, it's cold.",
        BUNNYSTEW = "It warms from the inside out.",
        MILKYWHITES = "No thanks.",

        CRITTER_EYEOFTERROR = "Hey, looking good today!",

        SHIELDOFTERROR ="At least there's no eye gunk on it.",
        TWINOFTERROR1 = "Hey no fair, it brought backup!",
        TWINOFTERROR2 = "Hey no fair, it brought backup!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "I don't think I've ever actually seen a normal mouse around here.",
        KITCOON_NAMETAG = "I should test its fire resistance. Y'know, to make sure it's safe.",

		KITCOONDECOR1 =
        {
            GENERIC = "I wanna kick it!",
            BURNT = "Hahaha YES!!",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "Go on, get the fishy!",
            BURNT = "Nice.",
        },

		KITCOONDECOR1_KIT = "The kitcoons are waiting for their toys!",
		KITCOONDECOR2_KIT = "Alright, where's a good spot to put it...",

        -- WX78
        WX78MODULE_MAXHEALTH = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MAXSANITY1 = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MAXSANITY = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MOVESPEED = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MOVESPEED2 = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_HEAT = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_NIGHTVISION = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_COLD = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_TASER = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_LIGHT = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MAXHUNGER1 = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MAXHUNGER = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MUSIC = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_BEE = "Hey WX, when are you gonna install a flamethrower?",
        WX78MODULE_MAXHEALTH2 = "Hey WX, when are you gonna install a flamethrower?",

        WX78_SCANNER = 
        {
            GENERIC ="I can't decide if it's cute or creepy.",
            HUNTING = "I can't decide if it's cute or creepy.",
            SCANNING = "I can't decide if it's cute or creepy.",
        },

        WX78_SCANNER_ITEM = "Heh... how mad do you think WX would get if I painted a mustache on it?",
        WX78_SCANNER_SUCCEEDED = "What are you waiting for, a pat on the head?",

        WX78_MODULEREMOVER = "Let me try... hold still, WX!",

        SCANDATA = "Looks like dumb science stuff for nerds.",
    },

    DESCRIBE_GENERIC = "I have no idea what that is!",
    DESCRIBE_TOODARK = "I need more light!",
    DESCRIBE_SMOLDERING = "Hooray, it's about to light on fire!",

    DESCRIBE_PLANTHAPPY = "It looks... fine?",
    DESCRIBE_PLANTVERYSTRESSED = "Something's got it really upset.",
    DESCRIBE_PLANTSTRESSED = "I'd guess there's more than one thing bothering it.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Ugh, do I really have to weed the garden again?",
    DESCRIBE_PLANTSTRESSORFAMILY = "What's wrong? Don't tell me it's lonely?",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "These plants could use some more personal space.",
    DESCRIBE_PLANTSTRESSORSEASON = "Guess it doesn't like the weather.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Looking nice and crispy!",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Ms. Wickerbottom's always going on about nutrients in the soil. Maybe it needs that.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "What do you want from me?!",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Ugh. Crunchy.",
		WINTERSFEASTFUEL = "Does anyone else smell a campfire?",
    },
}
