--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "He's attending to some other business, presently.",
        },
        REPAIR =
        {
            WRONGPIECE = "I could have told you that wouldn't fit.",
        },
        BUILD =
        {
            MOUNTED = "Even with my long arms, I still can't reach.",
            HASPET = "One pet is enough responsibility.",
			TICOON = "I've already recruited a ticoon.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I don't think she'd take kindly to that.",
			GENERIC = "To what end?",
			NOBITS = "But it's already as smooth as a baby's rear end.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "Let someone else do it.",
		},
		STORE =
		{
			GENERIC = "It wouldn't fit.",
			NOTALLOWED = "That can't go in there.",
			INUSE = "Worry not, pal. I've the patience of a saint.",
            NOTMASTERCHEF = "I have more important things to do than that.",
		},
        CONSTRUCT =
        {
            INUSE = "I don't like sharing.",
            NOTALLOWED = "That's the wrong part.",
            EMPTY = "Well I need something to build with.",
            MISMATCH = "It needs completely different plans.",
        },
		RUMMAGE =
		{
			GENERIC = "Curses.",
			INUSE = "I'm quite adept at waiting. I've had a lot of practice.",
            NOTMASTERCHEF = "I have more important things to do than that.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Blast! Wrong key.",
        	KLAUS = "I'll not be done in by an overgrown Krampus.",
			QUAGMIRE_WRONGKEY = "It appears there's another key around here.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "I shall have to find the key.",
            HOSTBUSY = "Apparently he has more pressing matters to attend to.",
            CARNIVAL_HOST_HERE = "I thought I saw that feathered charlatan around here...",
            NOCARNIVAL = "Finally. It looks like the birds have dispersed.",
			EMPTY_CATCOONDEN = "It's vacant.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "It seems we are lacking in participants.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "This environment is not suitable for a fair game.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "Playtime is over for now.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "I have more important things to do than that.",
			SHADOWMAGIC = "unused_by_waxwell",
		},
        COOK =
        {
            GENERIC = "Nothing ever goes as planned.",
            INUSE = "Hmph. You're adding too much salt.",
            TOOFAR = "I must get closer.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "This race seems to be decidedly lacking in racers.",
        },

		DISMANTLE =
		{
			COOKING = "I'd rather not lay my hands on a hot stove, thank you very much.",
			INUSE = "It's occupied.",
			NOTEMPTY = "First I must remove its contents.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Blast! This is hopeless.",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "I won't use my good fishing rod in this stagnant pond.",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "I should think not.",
            DEAD = "The dead have no need of such things.",
            SLEEPING = "It's thoroughly unconscious.",
            BUSY = "It's busy, currently.",
            ABIGAILHEART = "I had to try.",
            GHOSTHEART = "I don't think so. They might still be mad.",
            NOTGEM = "Even The Amazing Maxwell couldn't wring magic from that.",
            WRONGGEM = "That would be an amateurish misuse of its magic.",
            NOTSTAFF = "Hm. No, that's not right.",
            MUSHROOMFARM_NEEDSSHROOM = "A mushroom would be more suited to this.",
            MUSHROOMFARM_NEEDSLOG = "A living log would be more suited to this.",
            MUSHROOMFARM_NOMOONALLOWED = "The blasted thing refuses to grow!",
            SLOTFULL = "Occupied.",
            FOODFULL = "We've already placed something on the altar.",
            NOTDISH = "That wouldn't be a very good sacrifice, now would it?",
            DUPLICATE = "That can already be made here.",
            NOTSCULPTABLE = "That is certainly not for sculpting with.",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "It refuses to bend to my will.",
            WRONGSHADOWFORM = "The bones were too amateurishly assembled.",
            NOMOON = "It's not going to work in here.",
			PIGKINGGAME_MESSY = "Ugh. I'm not doing anything in that mess.",
			PIGKINGGAME_DANGER = "I have bigger things to worry about right now.",
			PIGKINGGAME_TOOLATE = "It's much too late for that.",
			CARNIVALGAME_INVALID_ITEM = "Hmph. Picky.",
			CARNIVALGAME_ALREADY_PLAYING = "It seems I'll have to bide my time.",
            SPIDERNOHAT = "Its dapperness would be wasted in my pocket.",
            TERRARIUM_REFUSE = "Nothing. I wonder how it might respond to the fuel...",
            TERRARIUM_COOLDOWN = "There's nothing in there to receive our offering. Yet.",
        },
        GIVETOPLAYER =
        {
            FULL = "No sense giving them more than they can carry.",
            DEAD = "The dead have no need of such things.",
            SLEEPING = "Err... I'll let you rest.",
            BUSY = "When you have a moment.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "No sense giving them more than they can carry.",
            DEAD = "The dead have no need of such things.",
            SLEEPING = "Err... I'll let you rest.",
            BUSY = "When you have a moment.",
        },
        WRITE =
        {
            GENERIC = "I'm unable to do that right now.",
            INUSE = "I can wait... it's the courteous thing to do.",
        },
        DRAW =
        {
            NOIMAGE = "My memory isn't good enough to draw from it.",
        },
        CHANGEIN =
        {
            GENERIC = "How could you improve on perfection?",
            BURNING = "Oh. There go all my good pocket squares.",
            INUSE = "They're in much more dire need of it.",
            NOTENOUGHHAIR = "There's nothing for me to work with.",
            NOOCCUPANT = "I think you're forgetting something, pal...",
        },
        ATTUNE =
        {
            NOHEALTH = "I must wait and regain my strength.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Perhaps I should take a step back.",
            INUSE = "Once again the seat of power is stolen from me!",
			SLEEPING = "Get up, you lazy beast.",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "Perhaps I should take a step back.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "I am far too advanced for this.",
            CANTLEARN = "There's a lesson to be learned about tampering with secret knowledge.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "I seem to be in the wrong place to use this.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "I'll extract its secrets once I find some suitable lighting.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "I don't know what to wrap.",
        },
        PICKUP =
        {
			RESTRICTION = "I have no use of such things.",
			INUSE = "It's unavailable.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Say, pal, why don't you come work for me?",
                "Its allegiance lies elsewhere.",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "It has escaped my clutches.",
        },
        REPLATE =
        {
            MISMATCH = "Clearly this is the wrong dish.",
            SAMEDISH = "I've already put this on a dish.",
        },
        SAIL =
        {
        	REPAIR = "It looks fine to me as is.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "I must time this perfectly if I'm to succeed.",
            BAD_TIMING1 = "This isn't exactly my forte.",
            BAD_TIMING2 = "Hmph. Physical labor is more suited to underlings.",
        },
        LOWER_SAIL_FAIL =
        {
            "Well, that didn't quite work as I planned.",
            "How inconvenient.",
            "Blast it!",
        },
        BATHBOMB =
        {
            GLASSED = "I can't do that while it's covered in moon glass.",
            ALREADY_BOMBED = "No need to do it twice.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "That can already be made here.",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "It's not worth my time.",
            OVERSIZEDVEGGIES_TOO_SMALL = "This one is insignificant in comparison.",
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
            GENERIC = "I have the information I need.",
            FERTILIZER = "I think I know quite enough.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Why must the plants be so picky?",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "I've run out.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "There's no more water.",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "I think not.",
            BEEF_BELL_ALREADY_USED = "This one's already been claimed.",
            BEEF_BELL_HAS_BEEF_ALREADY = "One smelly beast following me around is more than enough.",
        },
        HITCHUP =
        {
            NEEDBEEF = "Here's the hitch pal, I'm going to need a beefalo.",
            NEEDBEEF_CLOSER = "Get over here, you hairy imbecile!",
            BEEF_HITCHED = "The beast is ready to be judged.",
            INMOOD = "Perhaps once the beast has settled down and is willing to be reasonable.",
        },
        MARK =
        {
            ALREADY_MARKED = "My choice has been made. No going back.",
            NOT_PARTICIPANT = "I'll bide my time until the next competition.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Where is that incompetent judge?",
            ALREADYACTIVE = "There must be a competition going on elsewhere...",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "An old pattern. I've no use for it.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Those blasted things move too fast!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "I don't hold any power over them.",
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
            DOER_ISNT_MODULE_OWNER = "Hmph. It's not worth my time.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "I don't have everything I need.",
		NO_TECH = "Don't look at me, I've never made one before in my life.",
		NO_STATION = "I can't make that here, pal.",
	},

	ACTIONFAIL_GENERIC = "That didn't work.",
	ANNOUNCE_BOAT_LEAK = "We've sprung a leak!",
	ANNOUNCE_BOAT_SINK = "Oh dear.",
	ANNOUNCE_DIG_DISEASE_WARNING = "That takes care of that.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "How putrid!", --removed
	ANNOUNCE_ADVENTUREFAIL = "I of all people should be able to do this.",
    ANNOUNCE_MOUNT_LOWHEALTH = "Say, pal, you don't look so good.",

    --waxwell and wickerbottom specific strings
    ANNOUNCE_TOOMANYBIRDS = "There are plenty of birds here already.",
    ANNOUNCE_WAYTOOMANYBIRDS = "I must wait before I summon the birds again.",

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

	ANNOUNCE_BEES = "Killing me won't bring back your honey!",
	ANNOUNCE_BOOMERANG = "Ow! Blasted... clumsy hands!",
	ANNOUNCE_CHARLIE = "Charlie? It's me! Maxwell!",
	ANNOUNCE_CHARLIE_ATTACK = "Ow! Be gentle, Charlie!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "My heart grows cold.",
	ANNOUNCE_HOT = "My heart can't stand the heat!",
	ANNOUNCE_CRAFTING_FAIL = "Er... I can't do that.",
	ANNOUNCE_DEERCLOPS = "I hear one of them coming.",
	ANNOUNCE_CAVEIN = "The ceiling is going to collapse!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"My world is crumbling!",
		"I am attacked by my own world!",
		"An earthquake!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "May this tribute sate the beast.",
        "Does this entertain you, beast?",
        "What a chore.",
	},
	ANNOUNCE_SACREDCHEST_YES = "Was there ever a doubt?",
	ANNOUNCE_SACREDCHEST_NO = "It's deemed me unworthy.",
    ANNOUNCE_DUSK = "It'll be dark soon. Charlie will be waking up.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "(Gulp!)",
		PAINFUL = "Ow! That hurt my mouth!",
		SPOILED = "That was putrid.",
		STALE = "That was past its expiration date.",
		INVALID = "I won't let that anywhere near my mouth.",
        YUCKY = "A civilized man does not eat such things.",

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
        "Reduced... to this...",
        "Huff... huff...",
        "This is... peasant... work...",
        "Oh... my back...",
        "I wasn't... built for this...",
        "All my joints... are cracking!",
        "I... was a king, you know..!",
        "Oof... huff...",
        "This... better not ruin... my suit.",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Dark magics are returning.",
		"Here we go again.",
		"The power's growing.",
	},
    ANNOUNCE_RUINS_RESET = "The cycle begins again.",
    ANNOUNCE_SNARED = "How dare you!",
    ANNOUNCE_SNARED_IVY = "Wretched greenery! Release me at once!",
    ANNOUNCE_REPELLED = "What trickery is this!",
	ANNOUNCE_ENTER_DARK = "That smell... both nostalgic and terrifying!",
	ANNOUNCE_ENTER_LIGHT = "Thank goodness for the light.",
	ANNOUNCE_FREEDOM = "Freedom, at last!",
	ANNOUNCE_HIGHRESEARCH = "My brain swells with power!",
	ANNOUNCE_HOUNDS = "The hounds are growing restless.",
	ANNOUNCE_WORMS = "Oh dear. I know what's making that sound.",
	ANNOUNCE_HUNGRY = "I am empty inside.",
	ANNOUNCE_HUNT_BEAST_NEARBY = "I smell dung and beast sweat.",
	ANNOUNCE_HUNT_LOST_TRAIL = "Drat! It got away.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "I can't follow it in these conditions!",
	ANNOUNCE_INV_FULL = "My pockets are full.",
	ANNOUNCE_KNOCKEDOUT = "Ugh. My head hurts.",
	ANNOUNCE_LOWRESEARCH = "That wasn't very informative.",
	ANNOUNCE_MOSQUITOS = "What annoying little bugs.",
    ANNOUNCE_NOWARDROBEONFIRE = "You're kidding right?",
    ANNOUNCE_NODANGERGIFT = "That's a terrible idea right now.",
    ANNOUNCE_NOMOUNTEDGIFT = "I'm not opening that on top of this thing.",
	ANNOUNCE_NODANGERSLEEP = "Not while there's danger afoot!",
	ANNOUNCE_NODAYSLEEP = "I can't sleep during daylight hours.",
	ANNOUNCE_NODAYSLEEP_CAVE = "Sleeping now would mess up my sleep schedule!",
	ANNOUNCE_NOHUNGERSLEEP = "I'm too hungry. I can't sleep.",
	ANNOUNCE_NOSLEEPONFIRE = "That might not be the best idea.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Oh for... would you turn that blasted light off?!",
	ANNOUNCE_NODANGERSIESTA = "They're hot on my heels!",
	ANNOUNCE_NONIGHTSIESTA = "It's sleep time, not siesta time.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "It's a bit creepy out for that.",
	ANNOUNCE_NOHUNGERSIESTA = "Traditionally, a siesta comes after eating, not before.",
	ANNOUNCE_NO_TRAP = "Odd. They forgot to set it.",
	ANNOUNCE_PECKED = "Have patience!",
	ANNOUNCE_QUAKE = "That rumbling can't be good.",
	ANNOUNCE_RESEARCH = "Knowledge is power. And power is... well, power.",
	ANNOUNCE_SHELTER = "Protect me, cursed tree!",
	ANNOUNCE_THORNS = "I scratched my arms up doing that.",
	ANNOUNCE_BURNT = "It burns!",
	ANNOUNCE_TORCH_OUT = "Curses. Another light down.",
	ANNOUNCE_THURIBLE_OUT = "A shame.",
	ANNOUNCE_FAN_OUT = "There goes my respite.",
    ANNOUNCE_COMPASS_OUT = "The compass has fallen to pieces.",
	ANNOUNCE_TRAP_WENT_OFF = "Ack!",
	ANNOUNCE_UNIMPLEMENTED = "Hmm, not quite done.",
	ANNOUNCE_WORMHOLE = "Yech. It's horrible in there.",
	ANNOUNCE_TOWNPORTALTELEPORT = "It's about time.",
	ANNOUNCE_CANFIX = "\nI think I can fix this!",
	ANNOUNCE_ACCOMPLISHMENT = "I need to pass the time somehow.",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "Ah. The satisfaction of a job well done.",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It perked up just a tiny bit.",
	ANNOUNCE_TOOL_SLIP = "Drat.",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Can't touch this!",
	ANNOUNCE_TOADESCAPING = "Now is the time to strike!",
	ANNOUNCE_TOADESCAPED = "It fled back into the earth.",


	ANNOUNCE_DAMP = "Damp is not dapper.",
	ANNOUNCE_WET = "Water'll ruin a good suit, you know?",
	ANNOUNCE_WETTER = "I don't think I'll ever be dry again.",
	ANNOUNCE_SOAKED = "Wetter than water itself.",

	ANNOUNCE_WASHED_ASHORE = "My suit is drenched in salt water.",

    ANNOUNCE_DESPAWN = "Say, pal, I don't look so good...",
	ANNOUNCE_BECOMEGHOST = "oOooooOO!!",
	ANNOUNCE_GHOSTDRAIN = "They're whispering through the core of my mind...!",
	ANNOUNCE_PETRIFED_TREES = "Oh, this should be good.",
	ANNOUNCE_KLAUS_ENRAGE = "Time to beat a hasty retreat!",
	ANNOUNCE_KLAUS_UNCHAINED = "Its true power has been unlocked!",
	ANNOUNCE_KLAUS_CALLFORHELP = "The coward has summoned its minions.",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "I hear you in there.",
		GLASS_LOW = "I must have your knowledge.",
		GLASS_REVEAL = "A-ha!",
		IDOL_MED = "I hear you in there.",
		IDOL_LOW = "I must have your knowledge.",
		IDOL_REVEAL = "A-ha!",
		SEED_MED = "I hear you in there.",
		SEED_LOW = "I must have your knowledge.",
		SEED_REVEAL = "A-ha!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Quite an expert illusion.",
	ANNOUNCE_BRAVERY_POTION = "I was never really scared of those trees anyhow.",
	ANNOUNCE_MOONPOTION_FAILED = "How disappointing.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "I suppose it's only right to share this with the others.",
	ANNOUNCE_WINTERS_FEAST_BUFF = "That food seems to have had an odd affect on me...",
	ANNOUNCE_IS_FEASTING = "At last, a decent meal.",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Its power was short-lived.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Allow me to assist.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "No need to thank me.",
    ANNOUNCE_REVIVED_FROM_CORPSE = "That was simply undignified.",

    ANNOUNCE_FLARE_SEEN = "Am I supposed to come running every time I spot a flare?",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "We're in for some trouble.",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "This combination of food was ill-advised.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Curses! Too slow.",
    QUAGMIRE_ANNOUNCE_LOSE = "This may be the end.",
    QUAGMIRE_ANNOUNCE_WIN = "The Gateway is ready!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "Unlimited power!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "I'm not afraid of some fisticuffs!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I feel protected by an unseen force.",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "My focus feels heightened!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Finally, some respite from the dampness.",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "This will serve as a suitable ward against drowsiness.",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Shame. I was starting to enjoy that.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "My strength has left me.",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "I've been left vulnerable!",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "My enthusiasm for this has run dry.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "I'm exposed to the elements!",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "I'm growing tired.",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Blast! That cad-fish got away with my tackle!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "The line needs more tension.",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "We will meet again, mark my words...",
	ANNOUNCE_OCEANFISHING_BADCAST = "That was, of course, just a warm up...",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"I must exercise patience.",
		"I daresay, this is almost relaxing.",
		"Why won't they take the bait? Perhaps I should offer secret knowledge...",
		"I am beginning to tire of all this waiting",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nEr... I don't suppose anyone would help me carry this?",

	ANNOUNCE_WINCH_CLAW_MISS = "Foiled again!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "I don't know what I expected.",

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
    ANNOUNCE_WEAK_RAT = "The creature is past its prime.",

    ANNOUNCE_CARRAT_START_RACE = "Begin!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "You fool! You're going the wrong way!",
        "No! The other way!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Wake up, you useless vermin!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Faster! Faster I say!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "What's the matter? Get going!",

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

	ANNOUNCE_POCKETWATCH_PORTAL = "Oh ha-ha, laugh it up. I wouldn't have landed on my rump if the witch knew how to navigate!",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "This knowledge... it was hidden even from me.",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "A waste of my time. This knowledge is already mine.",
    ANNOUNCE_ARCHIVE_NO_POWER = "It doesn't respond to shadow magic. Perhaps another power source...",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "This plant's secrets are revealing themselves to me.",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "It had better grow into something worthwhile.",

    ANNOUNCE_FERTILIZER_RESEARCHED = "I'm growing more knowledgeable than I'd care to be about this stuff.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Ack, those infernal nettles!",
		"The nettle's poison is burning in my veins!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "The worst has passed.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "I feel ridiculous. Is this really supposed to help it grow?",
        "Grow faster, you blasted thing! There, did that help?",
		"You know, I ruled over this entire world once. Now I'm talking to a plant.",
        "Say pal, do you like magic tricks? This is the one where I talk and you grow.",
        "Here I am, chatting it up with the vegetation.",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "I suppose we shall begin this ridiculous game.",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Of course you need my help.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"A-ha! Not sneaky enough!",
		"Found you!",
		"You were not clever enough to best the great Maxwell!!",
		"Your attempt to escape me has been thwarted, child!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "Only one remains.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "A-ha! That was the last one! I win!!!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "I had seen it already, but {name} got to it first, I suppose.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Where are those blasted kittens!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Blast it!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "I doubt those tiny, pathetic legs would carry them this far.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "This seems much more likely an area to find the kitcoons.",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "So you're the source of that pathetic mewling. I'll have to apologize to the strongman.",

	ANNOUNCE_TICOON_START_TRACKING	= "Yes, good... lead me to the kitcoons.",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "Nothing??? Useless animal!",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Even a creature of your stature knows to wait for its superiors.",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Can't you see I'm busy, rodent!? ...My apologies. Where were we?",
	ANNOUNCE_TICOON_NEAR_KITCOON = "Ah, we must be near a kitcoon...",
	ANNOUNCE_TICOON_LOST_KITCOON = "Drat, someone found this kitcoon before us.",
	ANNOUNCE_TICOON_ABANDONED = "Fine! Begone! The Great Maxwell doesn't need help for a simple child's game.",
	ANNOUNCE_TICOON_DEAD = "That foolish creature! This may prove to be a setback...",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "And here comes my... er, \"beautiful\" assistant.",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "This seems a bit far from the festivities, don't you think?",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "At last, something new.",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Oh, what a magnificent horror.",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "I've been awaiting your return. Let's end this.",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "It'll be back.",

	BATTLECRY =
	{
		GENERIC = "To arms!",
		PIG = "Brains over brawn!",
		PREY = "Sacrifice yourself for my comfort!",
		SPIDER = "I'll not be made a fool of!",
		SPIDER_WARRIOR = "You've forced my hand!",
		DEER = "You do not belong in MY world!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "And stay away!",
		PIG = "Next time, pig!",
		PREY = "You're not worth my time!",
		SPIDER = "I won't be made a fool of... next time!",
		SPIDER_WARRIOR = "Next time the gloves come off!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Always did have a flair for the dramatic...",
        MULTIPLAYER_PORTAL_MOONROCK = "A bit ominous looking.",
        MOONROCKIDOL = "They always need an offering.",
        CONSTRUCTION_PLANS = "I suppose I should build this.",

        ANTLION =
        {
            GENERIC = "Have you no pride?",
            VERYHAPPY = "We've placated it for now.",
            UNHAPPY = "It's going to wreak havoc on my world.",
        },
        ANTLIONTRINKET = "I'll cross it off my bucket list.",
        SANDSPIKE = "That was quite impolite.",
        SANDBLOCK = "Impressive.",
        GLASSSPIKE = "I hope I'm not so transparent.",
        GLASSBLOCK = "Not the castle I had in mind for myself.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Hm? What a familiar presence.",
			LEVEL1 = "I can sense strong magic within it.",
			LEVEL2 = "A powerful bond tethers this spirit to our world.",
			LEVEL3 = "...I wonder how my brother is doing.",

			-- deprecated
            LONG = "I can sense strong magic within it.",
            MEDIUM = "This enchantment is not of my doing.",
            SOON = "Whatever it is will be arriving soon.",
            HAUNTED_POCKET = "I should quit toying with this now.",
            HAUNTED_GROUND = "It demands a sacrifice.",
        },

        BALLOONS_EMPTY = "Those look much too jovial for my liking.",
        BALLOON = "This seems out of place here. Too cheery.",
		BALLOONPARTY = "Oh no... he's managed to make them even more cheerful.",
		BALLOONSPEED =
        {
            DEFLATED = "Its power is spent. Now it's just garishly cheery.",
            GENERIC = "The mime's power unsettles me.",
        },
		BALLOONVEST = "I think I'd rather drown.",
		BALLOONHAT = "Would I really stoop so low as to wear such a thing?",

        BERNIE_INACTIVE =
        {
            BROKEN = "It's seen better days.",
            GENERIC = "It makes me a little nostalgic.",
        },

        BERNIE_ACTIVE = "Just what am I looking at here?",
        BERNIE_BIG = "How truly unnerving.",

        BOOK_BIRDS = "What a wasteful misuse of magic.",
        BOOK_TENTACLES = "What horrors shall be summoned from the depths?",
        BOOK_GARDENING = "It's not wise to toy with forces beyond your comprehension.",
		BOOK_SILVICULTURE = "It's not wise to toy with forces beyond your comprehension.",
		BOOK_HORTICULTURE = "Hopefully this version is less wordy.",
        BOOK_SLEEP = "I haven't had a real sleep in... ages.",
        BOOK_BRIMSTONE = "I've had enough fire and brimstone for one eternity.",

        PLAYER =
        {
            GENERIC = "Greetings, %s.",
            ATTACKER = "%s seems untrustworthy...",
            MURDERER = "Murderous fiend! I'll stop at nothing!",
            REVIVER = "%s tethers lost spirits to this world.",
            GHOST = "%s needs heart-shaped assistance.",
            FIRESTARTER = "%s has been lighting fires.",
        },
        WILSON =
        {
            GENERIC = "Err, greetings, Mr. %s.",
            ATTACKER = "You're going off the deep end, pal.",
            MURDERER = "Our truce ends here, murderer!",
            REVIVER = "%s is a real pal...",
            GHOST = "Are you certain you wish to return to this world?",
            FIRESTARTER = "The fire is supposed to go in the pit, Higgsbury.",
        },
        WOLFGANG =
        {
            GENERIC = "Good day to you, Mr. %s.",
            ATTACKER = "The strongman %s seems a little unhinged.",
            MURDERER = "Murderous fiend! Behold my power!",
            REVIVER = "%s tethers lost spirits to this world.",
            GHOST = "Let's find a heart. I'll prepare my incantations.",
            FIRESTARTER = "Did you intend to burn that, %s?",
        },
        WAXWELL =
        {
            GENERIC = "What a dapper fellow!",
            ATTACKER = "I know that look, %s. What are you up to?",
            MURDERER = "Old habits die hard... and so will you!",
            REVIVER = "Trust only yourself, hey %s?",
            GHOST = "I'll have to pay in blood to bring you back, %s.",
            FIRESTARTER = "Do not blow this for us, %s.",
        },
        WX78 =
        {
            GENERIC = "Greetings, Mx. %s.",
            ATTACKER = "If you're going to attack, at least finish the job!",
            MURDERER = "Murderous fiend! This will be your destruction!",
            REVIVER = "%s never did respect human mortality.",
            GHOST = "A shame about your death. You were the only one I half-liked.",
            FIRESTARTER = "Mx. %s is making good on their promises of mayhem.",
        },
        WILLOW =
        {
            GENERIC = "Greetings, Ms. %s.",
            ATTACKER = "%s is not my ally...",
            MURDERER = "Murderous fiend! Taste my wrath!",
            REVIVER = "%s has bent reality to her fiery will.",
            GHOST = "We will require a heart to bring you back, %s.",
            FIRESTARTER = "She's a firestarter. And a twisted one, at that.",
        },
        WENDY =
        {
            GENERIC = "Greetings, Miss %s. How are you?",
            ATTACKER = "%s has been corrupted...",
            MURDERER = "Don't think I'll hesitate, murderous fiend!",
            REVIVER = "%s is a true death defier.",
            GHOST = "%s is looking a bit too much like her sister.",
            FIRESTARTER = "Don't play with fire, Ms. %s.",
        },
        WOODIE =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "%s is going against the grain...",
            MURDERER = "Fiend! Time to make like a tree...!",
            REVIVER = "%s seems very in touch with the spirits of the forest.",
            GHOST = "That blockhead could use a heart.",
            BEAVER = "Ha! What a delightful curse.",
            BEAVERGHOST = "Yew don't look so wood.",
            MOOSE = "Wonderful. A screw-loose moose.",
            MOOSEGHOST = "I'll leave you to you moose-ings while I seek out a heart.",
            GOOSE = "Not the most dignified form you've taken.",
            GOOSEGHOST = "It seems you've run a-fowl of something, pal.",
            FIRESTARTER = "Is it wise to start fires, given your predilections?",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Good day, Ms. %s.",
            ATTACKER = "%s is withholding information...",
            MURDERER = "Do not start fights you cannot win!",
            REVIVER = "%s has excellent command of the dark arts.",
            GHOST = "You know the price of revival as well as I do, %s.",
            FIRESTARTER = "Never pinned you for the wanton destruction type.",
        },
        WES =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "%s is giving me the creeps...",
            MURDERER = "Murderous fiend! You cannot escape!",
            REVIVER = "%s is an effective ally.",
            GHOST = "I could get you a heart, %s... for a price.",
            FIRESTARTER = "Stop burning things, mime.",
        },
        WEBBER =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "%s is looking downright feral...",
            MURDERER = "So, %s, you're a monster after all!",
            REVIVER = "This child, %s, doesn't have a mean bone in his body.",
            GHOST = "Looks like you got squashed, %s.",
            FIRESTARTER = "Like a moth to flame. Or a spider, maybe.",
        },
        WATHGRITHR =
        {
            GENERIC = "Greetings, Ms. %s.",
            ATTACKER = "What is %s's motivation?",
            MURDERER = "Bloodthirsty warrior! This ends now!",
            REVIVER = "%s has excellent command of the spirit realm.",
            GHOST = "Do you desire a heart, %s?",
            FIRESTARTER = "The next fire you start will be a funeral pyre.",
        },
        WINONA =
        {
            GENERIC = "Greetings, Ms. %s.",
            ATTACKER = "%s has been roughhousing like a commoner.",
            MURDERER = "You've engineered your own demise!",
            REVIVER = "%s expertly uses all tools at her disposal.",
            GHOST = "My, you're looking spirited today, %s.",
            FIRESTARTER = "You were the last one I expected to start fires, %s.",
        },
        WORTOX =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "Do not make me bind you with magic, imp.",
            MURDERER = "Enough is enough! Prepare to be banished, imp!",
            REVIVER = "Hm. I'll allow you to stay on this plane awhile longer.",
            GHOST = "Serves you right, meddling imp.",
            FIRESTARTER = "Do I smell fire and brimstone?",
        },
        WORMWOOD =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "It's time you make like a tree and leaf.",
            MURDERER = "Don't worry, %s. I'll make it a clear cut.",
            REVIVER = "I suppose he has his uses.",
            GHOST = "What a shame. Now I'll never know what that gem does.",
            FIRESTARTER = "%s has been starting fires, now hasn't he?",
        },
        WARLY =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "%s seems out of sorts today.",
            MURDERER = "Eat this!",
            REVIVER = "Thank-you for the assistance, %s.",
            GHOST = "Oh, what a shame.",
            FIRESTARTER = "%s's started some suspicious fires recently.",
        },

        WURT =
        {
            GENERIC = "Greetings, Miss %s.",
            ATTACKER = "This is no time for childishness!",
            MURDERER = "%s has revealed her true nature!",
            REVIVER = "Ah, thank you, %s.",
            GHOST = "Oh dear, whatever will become of your kingdom now?",
            FIRESTARTER = "Who left the tiny green demon unsupervised?!",
        },

        WALTER =
        {
            GENERIC = "Greetings, Mr. %s.",
            ATTACKER = "I do not wish to quarrel!",
            MURDERER = "Interesting, %s. I didn't think you had it in you.",
            REVIVER = "I'm afraid I can't give you a badge, only my thanks.",
            GHOST = "Perhaps you can add this to your roster of ghost stories.",
            FIRESTARTER = "Wasn't it you who was railing on about fire safety?",
        },

        WANDA =
        {
            GENERIC = "Good day, Ms. %s.",
            ATTACKER = "Did someone tick you off, %s?",
            MURDERER = "Murderous fiend! I'll show you true power!",
            REVIVER = "Your assistance was quite timely, %s.",
            GHOST = "Time finally caught up to you, did it?",
            FIRESTARTER = "Far be it for me to question your methods, %s.",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "A flying goop factory.",
            SLEEPING = "It's drooling in its sleep.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Flower power.",
            DEAD = "Flower power forever.",
        },
        GLOMMERWINGS = "They're sticky.",
        GLOMMERFUEL = "Well, that's rank.",
        BELL = "More bell.",
        STATUEGLOMMER =
        {
            GENERIC = "Thank goodness, I thought it was another wretched statue of me.",
            EMPTY = "The fewer statues the better, I say.",
        },

        LAVA_POND_ROCK = "With each day I get a little boulder.",

		WEBBERSKULL = "Reminds me of the good ol' days.",
		WORMLIGHT = "What a neat trick.",
		WORMLIGHT_LESSER = "This one isn't very good.",
		WORM =
		{
		    PLANT = "You aren't fooling me, plant.",
		    DIRT = "Something stirs.",
		    WORM = "I didn't make that one! Honest!",
		},
        WORMLIGHT_PLANT = "You aren't fooling me, plant.",
		MOLE =
		{
			HELD = "End of the line.",
			UNDERGROUND = "Are you picking up what I'm putting down? Do you dig it?",
			ABOVEGROUND = "I'll take that as a \"yes\".",
		},
		MOLEHILL = "Burrow deep, I'm coming for you.",
		MOLEHAT = "No wonder they can dig for hours.",

		EEL = "It slithers all the way down.",
		EEL_COOKED = "Still rather grotesque.",
		UNAGI = "It will have to do.",
		EYETURRET = "Some of my better work.",
		EYETURRET_ITEM = "Now it just needs to be set up.",
		MINOTAURHORN = "A regrettable end, my old friend.",
		MINOTAURCHEST = "It's almost like he's still alive.",
		THULECITE_PIECES = "Several of these piles could be combined to form a bigger piece.",
		POND_ALGAE = "It's some algae.",
		GREENSTAFF = "It is a focusing tool.",
		GIFT = "An elegantly wrapped social obligation.",
        GIFTWRAP = "For wrapping odds and ends...",
		POTTEDFERN = "How quaint.",
        SUCCULENT_POTTED = "You're hard to kill. I respect that.",
		SUCCULENT_PLANT = "Doesn't look that succulent to me.",
		SUCCULENT_PICKED = "It didn't put up much of a fight.",
		SENTRYWARD = "This is a conduit for strong revelatory magicks.",
        TOWNPORTAL =
        {
			GENERIC = "Walking gets tiresome, you know.",
			ACTIVE = "The magic beckons!",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "An impure orange gem.",
			ACTIVE = "The magic beckons!",
		},
        WETPAPER = "It's absorbent, at any rate.",
        WETPOUCH = "There's something inside it.",
        MOONROCK_PIECES = "This might be bad.",
        MOONBASE =
        {
            GENERIC = "I had thought these all destroyed eons ago.",
            BROKEN = "Ruins of an ancient relic.",
            STAFFED = "Something magic-y needs to happen, I think.",
            WRONGSTAFF = "Waste of a good staff.",
            MOONSTAFF = "The staff is powered by the \"moon's\" energy.",
        },
        MOONDIAL =
        {
			GENERIC = "The gem conjures water springs in conjunction with the \"moon's\" cycles.",
			NIGHT_NEW = "The... \"moon\"... has retreated for now.",
			NIGHT_WAX = "The \"moon\" is waxing.",
			NIGHT_FULL = "The \"moon\" is full in the sky.",
			NIGHT_WANE = "The \"moon\" is on the wane.",
			CAVE = "The cave provides sanctuary from the \"moon's\" prying eyes.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "I can feel its eye upon me... watching...",
        },
		THULECITE = "An exceedingly rare but useful material.",
		ARMORRUINS = "Thulecite meshes so well with nightmare fuel.",
		ARMORSKELETON = "Like all things, it craves the fuel.",
		SKELETONHAT = "A most tragic and unfitting end.",
		RUINS_BAT = "The fuel runs deep in this.",
		RUINSHAT = "Fuel must flow.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "The heart of the city is still.",
            WARN = "It beats once again.",
            WAXING = "The pulse is quickening.",
            STEADY = "The pulse is holding steady.",
            WANING = "The pulse is waning.",
            DAWN = "It calms once more.",
            NOMAGIC = "The pulse has no influence here.",
		},
		BISHOP_NIGHTMARE = "They degrade without proper upkeep.",
		ROOK_NIGHTMARE = "The builders have left it in a state of abandonment.",
		KNIGHT_NIGHTMARE = "It looks beyond repair.",
		MINOTAUR = "My my, the fuel has changed you.",
		SPIDER_DROPPER = "Creatures in this world evolve at a terrifying rate.",
		NIGHTMARELIGHT = "The overuse of fuel was their downfall.",
		NIGHTSTICK = "Good morning.",
		GREENGEM = "Only the nightmare fuel will unlock its true potential.",
		MULTITOOL_AXE_PICKAXE = "The duality of mine.",
		ORANGESTAFF = "It's a focusing tool.",
		YELLOWAMULET = "This will make me stand out.",
		GREENAMULET = "A crutch for pitiful mortals without godlike powers. What?",
		SLURPERPELT = "In death, this creature will serve me!",

		SLURPER = "Simple creatures. They exist only to sleep and feed.",
		SLURPER_PELT = "In death, this creature will serve me!",
		ARMORSLURPER = "Wet, soggy, and oddly filling.",
		ORANGEAMULET = "Simple magic is often the best.",
		YELLOWSTAFF = "With a bigger gem it would be so much more powerful.",
		YELLOWGEM = "I can sense magic in it.",
		ORANGEGEM = "This will be quite powerful with some fuel.",
        OPALSTAFF = "The charge has made it incredibly powerful.",
        OPALPRECIOUSGEM = "A sizable magic gem.",
        TELEBASE =
		{
			VALID = "That should do the trick.",
			GEMS = "The fuel needs more focal points.",
		},
		GEMSOCKET =
		{
			VALID = "This one's ready.",
			GEMS = "The fuel needs a focus.",
		},
		STAFFLIGHT = "That should chase the shadows away.",
        STAFFCOLDLIGHT = "An impressively condensed point of freezing magic.",

        ANCIENT_ALTAR = "Where are their gods now?",

        ANCIENT_ALTAR_BROKEN = "This can be partially restored.",

        ANCIENT_STATUE = "A once proud race.",

        LICHEN = "This fungus survived the downfall.",
		CUTLICHEN = "Dry, crumbly, sustaining.",

		CAVE_BANANA = "Ashes in one's mouth.",
		CAVE_BANANA_COOKED = "Even worse than raw.",
		CAVE_BANANA_TREE = "It looks like a banana, but I'm not buying it.",
		ROCKY = "I banished these guys down here for a reason.",

		COMPASS =
		{
			GENERIC="I've lost my way.",
			N = "North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "It could be used for fashion.",
        ARMORSNURTLESHELL = "That is not dapper at all.",
        BAT = "Ugh. Ugly beasts.",
        BATBAT = "Violence has never felt better.",
        BATWING = "I'm not eating that.",
        BATWING_COOKED = "I'm still not eating that.",
        BATCAVE = "Ugh. It stinks.",
        BEDROLL_FURRY = "At least they're good for something.",
        BUNNYMAN = "It reminds me of my old act.",
        FLOWER_CAVE = "It's so dark down here.",
        GUANO = "Disgusting!",
        LANTERN = "I hope it keeps Them away.",
        LIGHTBULB = "It will run out eventually.",
        MANRABBIT_TAIL = "Silly rabbit.",
        MUSHROOMHAT = "It possesses a spritely magic.",
        MUSHROOM_LIGHT2 =
        {
            ON = "A light to repel the encroaching shadow.",
            OFF = "I'm partial to the lavender shade, myself.",
            BURNT = "Who ordered the mushroom flambe?",
        },
        MUSHROOM_LIGHT =
        {
            ON = "A rather pale light.",
            OFF = "I suppose we're decorating with fungus now.",
            BURNT = "C'est la vie.",
        },
        SLEEPBOMB = "It appears to be a sleeping bag.",
        MUSHROOMBOMB = "It's gonna blow!",
        SHROOM_SKIN = "I hope the warts are not contagious.",
        TOADSTOOL_CAP =
        {
            EMPTY = "It's a dirt hole.",
            INGROUND = "That looks filthy.",
            GENERIC = "Pitiful. I'll make short work of that 'shroom.",
        },
        TOADSTOOL =
        {
            GENERIC = "What an abomination!",
            RAGE = "It is coursing with fungal power!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "I don't like how much magic is collecting in that.",
            BURNT = "Singing it released the toxic cloud!",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "It smells of rot and failure.",
            BLOOM = "It's spawning.",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Where's Waldo?",
            BLOOM = "I hope I'm not standing next to it when it goes off.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Ugh, it smells bad.",
            BLOOM = "Oh fine, do what you like.",
        },
        MUSHTREE_TALL_WEBBED = "Could it get any less appealing?",
        SPORE_TALL =
        {
            GENERIC = "How can a seed be so cheerful?",
            HELD = "I hope it doesn't stain my jacket.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Magical red, and yet it holds no power of use to me.",
            HELD = "I hope it doesn't stain my jacket.",
        },
        SPORE_SMALL =
        {
            GENERIC = "Hateful, ambulatory whimsy.",
            HELD = "I hope it doesn't stain my jacket.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Oh, isn't that clever.",
            BURNT = "Cleverness killed the carrot.",
        },
        SLURTLE = "I don't remember those...",
        SLURTLE_SHELLPIECES = "Some cracks can't be mended.",
        SLURTLEHAT = "This will keep me standing, if I need to fight.",
        SLURTLEHOLE = "That's revolting.",
        SLURTLESLIME = "There must be a better way.",
        SNURTLE = "That's strange. They must be new.",
        SPIDER_HIDER = "It's a tricky one.",
        SPIDER_SPITTER = "Aggressive little thing, isn't it?",
        SPIDERHOLE = "How did that get down here?",
        SPIDERHOLE_ROCK = "How did that get down here?",
        STALAGMITE = "Rocks. How dull.",
        STALAGMITE_TALL = "Stalagmite. How dull.",

        TURF_CARPETFLOOR = "That's a quality, high-pile carpet sample!",
        TURF_CHECKERFLOOR = "That's my natural habitat.",
        TURF_DIRT = "Dusty.",
        TURF_FOREST = "Smells like mud.",
        TURF_GRASS = "Scratchy.",
        TURF_MARSH = "It's dripping all over.",
        TURF_METEOR = "Turf.",
        TURF_PEBBLEBEACH = "Turf.",
        TURF_ROAD = "At least this one is useful.",
        TURF_ROCKY = "Kinda rough.",
        TURF_SAVANNA = "Dirty.",
        TURF_WOODFLOOR = "I prefer hardwoods.",

		TURF_CAVE="Turf.",
		TURF_FUNGUS="Turf.",
		TURF_FUNGUS_MOON = "Turf.",
		TURF_ARCHIVE = "A stone floor.",
		TURF_SINKHOLE="Turf.",
		TURF_UNDERROCK="Turf.",
		TURF_MUD="Turf.",

		TURF_DECIDUOUS = "Turf.",
		TURF_SANDY = "Turf.",
		TURF_BADLANDS = "Turf.",
		TURF_DESERTDIRT = "Turf.",
		TURF_FUNGUS_GREEN = "Turf.",
		TURF_FUNGUS_RED = "Turf.",
		TURF_DRAGONFLY = "It's warm, but quells flame.",

        TURF_SHELLBEACH = "Turf.",

		POWCAKE = "What foul manifestation of evil is this?",
        CAVE_ENTRANCE = "I plugged it a long time ago.",
        CAVE_ENTRANCE_RUINS = "Probably shouldn't venture any deeper.",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "That was not a good idea!",
            OPEN = "Off to plunder the depths.",
            FULL = "When it's less claustrophobic, perhaps.",
        },
        CAVE_EXIT =
        {
            GENERIC = "Get me out of here!",
            OPEN = "Onward to the next thing.",
            FULL = "I'd rather stay here than mingle with the crowds above.",
        },

		MAXWELLPHONOGRAPH = "That accursed thing!",--single player
		BOOMERANG = "Beats getting your hands dirty.",
		PIGGUARD = "Blech. Disgusting brute.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Quite the precocious poltergeist, aren't you?",
                "Quite the precocious poltergeist, aren't you?",
            },
            LEVEL2 =
            {
                "Quite the precocious poltergeist, aren't you?",
                "Quite the precocious poltergeist, aren't you?",
            },
            LEVEL3 =
            {
                "Quite the precocious poltergeist, aren't you?",
                "Quite the precocious poltergeist, aren't you?",
            },
		},
		ADVENTURE_PORTAL = "So that's where I left that thing!",
		AMULET = "It channels the darkest energies of the universe.",
		ANIMAL_TRACK = "Some dumb beast passed through here.",
		ARMORGRASS = "Direct confrontation is quite gauche.",
		ARMORMARBLE = "That really isn't my style.",
		ARMORWOOD = "Ugh. I'm not typically one for vulgar fisticuffs.",
		ARMOR_SANITY = "Wrap yourself in the nightmare. Embrace it.",
		ASH =
		{
			GENERIC = "A fine powder that smells of destruction.",
			REMAINS_GLOMMERFLOWER = "There's always another Glommer.",
			REMAINS_EYE_BONE = "Don't worry. There will be more Chesters.",
			REMAINS_THINGIE = "My trip through the portal made it unrecognizable.",
		},
		AXE = "Sometimes the direct approach is best.",
		BABYBEEFALO =
		{
			GENERIC = "They're even ugly as infants.",
		    SLEEPING = "Seems we've a few hours of reprieve.",
        },
        BUNDLE = "Nice and snug.",
        BUNDLEWRAP = "I guess we could wrap a few things up.",
		BACKPACK = "I wish there were porters around here.",
		BACONEGGS = "Now that is a proper breakfast.",
		BANDAGE = "Sticky and gooey and good for putting on booboos.",
		BASALT = "I made a rock so heavy that even I can't lift it.", --removed
		BEARDHAIR = "Hirsute.",
		BEARGER = "Take whatever you want.",
		BEARGERVEST = "See my vest.",
		ICEPACK = "Its contents are hibernating.",
		BEARGER_FUR = "This would make a nice rug.",
		BEDROLL_STRAW = "I don't like sleeping rough.",
		BEEQUEEN = "I didn't make that one! Really!",
		BEEQUEENHIVE =
		{
			GENERIC = "I am not getting that on my shoes.",
			GROWING = "Now what are those bees up to?",
		},
        BEEQUEENHIVEGROWN = "I don't see what all the buzz is about.",
        BEEGUARD = "Keep your backside to yourself, madam!",
        HIVEHAT = "Makes one feel like royalty.",
        MINISIGN =
        {
            GENERIC = "It was drawn in a steady hand.",
            UNDRAWN = "There's nothing on it, currently.",
        },
        MINISIGN_ITEM = "A sign is useless if it has nothing to mark.",
		BEE =
		{
			GENERIC = "They work so hard, the fools.",
			HELD = "Now what do I do with it?",
		},
		BEEBOX =
		{
			READY = "So tempting, but so full of bees.",
			FULLHONEY = "So tempting, but so full of bees.",
			GENERIC = "It holds the bees.",
			NOHONEY = "Why do the bees not serve me?",
			SOMEHONEY = "I should wait a bit longer.",
			BURNT = "Honey roasted.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "It's so full it's almost obscene.",
			LOTS = "The mushrooms have really taken to the log.",
			SOME = "They seem to be doing well.",
			EMPTY = "Smells... \"piney\".",
			ROTTEN = "Rotten, all the way through. I relate.",
			BURNT = "Only ash and ruin remain here.",
			SNOWCOVERED = "Nothing grows in these frigid wastes.",
		},
		BEEFALO =
		{
			FOLLOWER = "Aw nuts, it's following me.",
			GENERIC = "Just look at that stupid beast.",
			NAKED = "Now it looks dumb AND pathetic.",
			SLEEPING = "It's only marginally less stupid when it's asleep.",
            --Domesticated states:
            DOMESTICATED = "I like a creature that knows its place.",
            ORNERY = "Yes, you understand how this works.",
            RIDER = "I'd only ride you if I was desperate.",
            PUDGY = "I suppose some people might find that charming.",
            MYPARTNER = "I suppose I'm saddled with this creature now.",
		},

		BEEFALOHAT = "How unfashionable.",
		BEEFALOWOOL = "It smells like a barn.",
		BEEHAT = "I'll wear it if I have to.",
        BEESWAX = "I miss sealing a good letter.",
		BEEHIVE = "Not the bees!",
		BEEMINE = "They wait so patiently.",
		BEEMINE_MAXWELL = "Maybe I shouldn't have put that there.",--removed
		BERRIES = "Sigh. If I have to.",
		BERRIES_COOKED = "A little more refined, at least.",
        BERRIES_JUICY = "Delightfully sweet with a subtle hint of tartness.",
        BERRIES_JUICY_COOKED = "They're quite delicious, actually.",
		BERRYBUSH =
		{
			BARREN = "It needs manure.",
			WITHERED = "Too hot for that little bush.",
			GENERIC = "Reduced to eating berries. Sigh.",
			PICKED = "And now we wait.",
			DISEASED = "What has brought this blight upon my world?",--removed
			DISEASING = "Looks a little off, if you ask me.",--removed
			BURNING = "It better not start talking to me.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "It looks to be in need of assistance. Fertilizer, perhaps?",
			WITHERED = "I know the feeling.",
			GENERIC = "The berries will stay fresh as long as I leave them there.",
			PICKED = "I fear I'll have to wait.",
			DISEASED = "What has brought this blight upon my world?",--removed
			DISEASING = "Looks a little off, if you ask me.",--removed
			BURNING = "It better not start talking to me.",
		},
		BIGFOOT = "Now that is surely fuel for nightmares.",--removed
		BIRDCAGE =
		{
			GENERIC = "You'll never get me behind bars again.",
			OCCUPIED = "I feel for ya, feathers.",
			SLEEPING = "You'll still be in there when you wake up.",
			HUNGRY = "What's all the fuss about, feathers?",
			STARVING = "Oh, come on. I fed you last week.",
			DEAD = "That's a deep sleep.",
			SKELETON = "Maybe he wasn't sleeping.",
		},
		BIRDTRAP = "They keep falling for it!",
		CAVE_BANANA_BURNT = "I refuse to be held responsible for that.",
		BIRD_EGG = "I like to think of it as baby bird prison.",
		BIRD_EGG_COOKED = "Sunny side up.",
		BISHOP = "I'm especially proud of that piece.",
		BLOWDART_FIRE = "Just make sure to breathe out.",
		BLOWDART_SLEEP = "Call me \"Mr. Sandman\".",
		BLOWDART_PIPE = "A glorious tube of pain!",
		BLOWDART_YELLOW = "Never strikes the same place twice, except when it does.",
		BLUEAMULET = "It's frosted over.",
		BLUEGEM = "Blue brings ice.",
		BLUEPRINT =
		{
            COMMON = "I know all about that. I... just forgot.",
            RARE = "A rare blueprint, indeed.",
        },
        SKETCH = "I'll need somewhere to sculpt it.",
		BLUE_CAP = "What could go wrong?",
		BLUE_CAP_COOKED = "Umami!",
		BLUE_MUSHROOM =
		{
			GENERIC = "The blue ones are good for, uh, something.",
			INGROUND = "It's not ready.",
			PICKED = "Another time, maybe?",
		},
		BOARDS = "Roughly hewn.",
		BONESHARD = "Grind them bones.",
		BONESTEW = "Leave no scrap unused.",
		BUGNET = "Good for capturing defenseless insects.",
		BUSHHAT = "There's room in there for me.",
		BUTTER = "Some puns are irresistible.",
		BUTTERFLY =
		{
			GENERIC = "It's a flying flower.",
			HELD = "It would be a shame if someone ripped the wings off of it.",
		},
		BUTTERFLYMUFFIN = "That should stop its incessant flapping.",
		BUTTERFLYWINGS = "Ha ha ha. I got him!",
		BUZZARD = "Carrion connoisseur.",

		SHADOWDIGGER = "I'm a shadow of myself. Ha-ha!",

		CACTUS =
		{
			GENERIC = "Puffer plant.",
			PICKED = "Cactus? More like flat-tus!",
		},
		CACTUS_MEAT_COOKED = "Cactus comestible.",
		CACTUS_MEAT = "It would be unwise to put that in my mouth.",
		CACTUS_FLOWER = "This part of the cactus is always nice.",

		COLDFIRE =
		{
			EMBERS = "I'm going to lose it.",
			GENERIC = "How comforting.",
			HIGH = "That will keep Charlie away for now.",
			LOW = "It needs fuel.",
			NORMAL = "Cold and fiery.",
			OUT = "That's not coming back.",
		},
		CAMPFIRE =
		{
			EMBERS = "I'm going to lose it.",
			GENERIC = "How comforting.",
			HIGH = "That will keep Charlie away for now.",
			LOW = "It needs fuel.",
			NORMAL = "Fiery.",
			OUT = "That's not coming back.",
		},
		CANE = "It has pictures of fast things carved into it.",
		CATCOON = "Catty vermin.",
		CATCOONDEN =
		{
			GENERIC = "Vermin housing.",
			EMPTY = "Well, I guess that's that.",
		},
		CATCOONHAT = "Dead head.",
		COONTAIL = "Tale of tails.",
		CARROT = "I'm not a fan of vegetables.",
		CARROT_COOKED = "A little more refined, at least.",
		CARROT_PLANTED = "How mundane.",
		CARROT_SEEDS = "Such labor is beneath me.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Mapmaking is a soothing pastime. Methodical.",
			BURNING = "Such directionless destruction.",
			BURNT = "Useless.",
		},
		WATERMELON_SEEDS = "I could probably plant these.",
		CAVE_FERN = "I'd like to step on it.",
		CHARCOAL = "Nothing will steal my carbon!",
        CHESSPIECE_PAWN = "I have no idea what that is.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "It's nice, but where's the rust? The exhaust pipes?",
            STRUGGLE = "The pieces are in motion!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "A dreadful lack of accordions.",
            STRUGGLE = "And I thought chivalry was dead!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Could use a few more mechanical bits in my opinion.",
            STRUGGLE = "The pieces are in motion!",
        },
        CHESSPIECE_MUSE = "Must everything be about my shortcomings?",
        CHESSPIECE_FORMAL = "What a well-dressed figure!",
        CHESSPIECE_HORNUCOPIA = "This seems cruel.",
        CHESSPIECE_PIPE = "Ceci n'est pas une pipe. Pity.",
        CHESSPIECE_DEERCLOPS = "I don't like winters.",
        CHESSPIECE_BEARGER = "A brute.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "What an imbecilic expression.",
        },
        CHESSPIECE_DRAGONFLY = "It never stood a chance.",
		CHESSPIECE_MINOTAUR = "Always keep things close to the chest, right pal?",
        CHESSPIECE_BUTTERFLY = "Rather elegant, I'd say.",
        CHESSPIECE_ANCHOR = "How kitsch.",
        CHESSPIECE_MOON = "I'm fairly partial to this one.",
        CHESSPIECE_CARRAT = "If only I had a mantle to set it on.",
        CHESSPIECE_MALBATROSS = "Such a fowl-tempered bird.",
        CHESSPIECE_CRABKING = "I am not that crabby!",
        CHESSPIECE_TOADSTOOL = "At least the statue doesn't smell as bad as the original.",
        CHESSPIECE_STALKER = "I do like this one.",
        CHESSPIECE_KLAUS = "Why bother?",
        CHESSPIECE_BEEQUEEN = "Does she really need a statue?",
        CHESSPIECE_ANTLION = "Is there a sinkhole I can bury this in?",
        CHESSPIECE_BEEFALO = "At least this version doesn't shed all over my poor suit.",
		CHESSPIECE_KITCOON = "This is a rather precarious design.",
		CHESSPIECE_CATCOON = "This animal commands respect through violence.",
        CHESSPIECE_GUARDIANPHASE3 = "How could I not have seen...",
        CHESSPIECE_EYEOFTERROR = "An eye could never best a master of illusion such as I.",
        CHESSPIECE_TWINSOFTERROR = "The most troublesome pair I've ever seen.",

        CHESSJUNK1 = "There's a reason I never finished that.",
        CHESSJUNK2 = "That one was a jerk.",
        CHESSJUNK3 = "Didn't like that one's face.",
		CHESTER = "Annoying little monster. Has his uses, though.",
		CHESTER_EYEBONE =
		{
			GENERIC = "Stop looking at me!",
			WAITING = "What is it waiting for?",
		},
		COOKEDMANDRAKE = "It has lost a lot of its power.",
		COOKEDMEAT = "It smells less like barnyard, now.",
		COOKEDMONSTERMEAT = "It's still filthy.",
		COOKEDSMALLMEAT = "Well, at least it's not moving anymore.",
		COOKPOT =
		{
			COOKING_LONG = "Wait for it...",
			COOKING_SHORT = "Here it comes!",
			DONE = "Finally, some quality grub.",
			EMPTY = "Just the thought makes my mouth water.",
			BURNT = "A bit overdone for my tastes.",
		},
		CORN = "High in fructose.",
		CORN_COOKED = "A little more refined, at least.",
		CORN_SEEDS = "Such labor is beneath me.",
        CANARY =
		{
			GENERIC = "How do these things keep getting into my world?",
			HELD = "Bait.",
		},
        CANARY_POISONED = "You look atrocious.",

		CRITTERLAB = "Am I being watched by that rock?",
        CRITTER_GLOMLING = "You are much too trusting, friend.",
        CRITTER_DRAGONLING = "Just like old times.",
		CRITTER_LAMB = "Quit nibbling my coattails.",
        CRITTER_PUPPY = "You're a slobbery little chap, aren't you?",
        CRITTER_KITTEN = "A wholly agreeable animal.",
        CRITTER_PERDLING = "You're as fowl as I am!",
		CRITTER_LUNARMOTHLING = "You had better not chew holes in my suit.",

		CROW =
		{
			GENERIC = "I don't know how they got here.",
			HELD = "Shhhh... My pretty.",
		},
		CUTGRASS = "The mundane stuff of the earth.",
		CUTREEDS = "I think I could build something useful from this.",
		CUTSTONE = "The building blocks of civilization.",
		DEADLYFEAST = "It smells... noxious.", --unimplemented
		DEER =
		{
			GENERIC = "Well it's certainly not deer to me.",
			ANTLER = "What a staggering sight!",
		},
        DEER_ANTLER = "Filthy.",
        DEER_GEMMED = "The gem imbues its attacks with a fearsome power.",
		DEERCLOPS = "Even I'm afraid of that guy.",
		DEERCLOPS_EYEBALL = "Deerclops are so myopic.",
		EYEBRELLAHAT =	"Eye to the sky.",
		DEPLETED_GRASS =
		{
			GENERIC = "That's not doing anyone any good.",
		},
        GOGGLESHAT = "Not my sort of fashion.",
        DESERTHAT = "Function over form.",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "That looks out-of-place.",
		DIVININGROD =
		{
			COLD = "Mostly just background noise.", --singleplayer
			GENERIC = "I can use this to find my missing parts.", --singleplayer
			HOT = "It must be right under my nose!", --singleplayer
			WARM = "This is the right direction.", --singleplayer
			WARMER = "I should keep my eyes peeled.", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "It's the starting mechanism.", --singleplayer
			READY = "I need to insert the divining rod.", --singleplayer
			UNLOCKED = "Progress!", --singleplayer
		},
		DIVININGRODSTART = "The portals lead to the next rod.", --singleplayer
		DRAGONFLY = "A fiery fly.",
		ARMORDRAGONFLY = "That's some fly mail.",
		DRAGON_SCALES = "Fiery.",
		DRAGONFLYCHEST = "Those scales sure are nifty.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "How undignified.",
			GENERIC = "Such a spiffy design!", --no gems
			NORMAL = "With only one gem it is only moderately scorching.", --one gem
			HIGH = "The red gems are producing a sweltering heat.", --two gems
		},

        HUTCH = "Stick your tongue in. You're getting slobber on my pantlegs.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Better him in that bowl than me.",
            WAITING = "His spirit is free now.",
        },
		LAVASPIT =
		{
			HOT = "Spitfire.",
			COOL = "It's cold and dry now.",
		},
		LAVA_POND = "A touch hot, but it could cook my food in a pinch.",
		LAVAE = "Foul beast! Know your place!",
		LAVAE_COCOON = "It's no threat in this state.",
		LAVAE_PET =
		{
			STARVING = "I think it's going to die!",
			HUNGRY = "It's hungry. Why is it hungry?",
			CONTENT = "It's happy with me, and I with it.",
			GENERIC = "You're not a hellbeast, are you? Nooo. Just misunderstood!",
		},
		LAVAE_EGG =
		{
			GENERIC = "It's alive in there.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "I knew I would make a terrible pa-pa.",
			COMFY = "I can say with pride that it is comfy and cozy.",
		},
		LAVAE_TOOTH = "The lavae's baby tooth.",

		DRAGONFRUIT = "Exotic and delicious.",
		DRAGONFRUIT_COOKED = "A little more refined, at least.",
		DRAGONFRUIT_SEEDS = "Such labor is beneath me.",
		DRAGONPIE = "Simply exquisite.",
		DRUMSTICK = "It tastes strangely like berries.",
		DRUMSTICK_COOKED = "Still tastes like berries.",
		DUG_BERRYBUSH = "Do I look like a gardener?",
		DUG_BERRYBUSH_JUICY = "I could find a much better place for it.",
		DUG_GRASS = "Do I look like a gardener?",
		DUG_MARSH_BUSH = "Do I look like a gardener?",
		DUG_SAPLING = "I can't believe I'm reduced to this.",
		DURIAN = "It's an acquired taste.",
		DURIAN_COOKED = "A little more refined, at least.",
		DURIAN_SEEDS = "Such labor is beneath me.",
		EARMUFFSHAT = "They are at least warm.",
		EGGPLANT = "Just another boring plant.",
		EGGPLANT_COOKED = "A little more refined, at least.",
		EGGPLANT_SEEDS = "Such labor is beneath me.",

		ENDTABLE =
		{
			BURNT = "That was uncalled for.",
			GENERIC = "Purely decorative.",
			EMPTY = "An empty vessel awaiting decoration or light.",
			WILTED = "Every lovely flower must one day wilt.",
			FRESHLIGHT = "A temporary reprieve from the shadow.",
			OLDLIGHT = "I believe it is Wilson's turn to fetch bulbs.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "Oops.",
			BURNT = "Bathed in fire.",
			CHOPPED = "That's not about to grow back.",
			POISON = "Shut your maw!",
			GENERIC = "An acquaintance of mine describes them as \"leafy\".",
		},
		ACORN = "A more outdoorsy type might be able to make something of this.",
        ACORN_SAPLING = "Huh, it seems to belong in the ground.",
		ACORN_COOKED = "Over an open fire.",
		BIRCHNUTDRAKE = "A nut with legs! How terrifying!",
		EVERGREEN =
		{
			BURNING = "Oops.",
			BURNT = "Bathed in fire.",
			CHOPPED = "That's not about to grow back.",
			GENERIC = "An acquaintance of mine describes them as \"piney\".",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Oops.",
			BURNT = "Dust to dust.",
			CHOPPED = "I put it out of its misery.",
			GENERIC = "It looks sickly.",
		},
		TWIGGYTREE =
		{
			BURNING = "Oops.",
			BURNT = "Bathed in fire.",
			CHOPPED = "That's not about to grow back.",
			GENERIC = "The tree of an amateur.",
			DISEASED = "What has brought this blight upon my world?", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "It's of no use in it's current state. Only time will tell.",
        TWIGGY_OLD = "Look at you. You're useless.",
		TWIGGY_NUT = "I could plant it... but why?",
		EYEPLANT = "The Meat Bulb's pawns.",
		INSPECTSELF = "I still look dapper, right? As if I need to check.",
		FARMPLOT =
		{
			GENERIC = "Do I look like a farmer?",
			GROWING = "I have better things to do than watch plants grow.",
			NEEDSFERTILIZER = "It needs to be... refreshed.",
			BURNT = "A harvest of ashes.",
		},
		FEATHERHAT = "I always considered myself the peacock of people.",
		FEATHER_CROW = "Black is the color of sleep.",
		FEATHER_ROBIN = "Red is the color of fire.",
		FEATHER_ROBIN_WINTER = "Grey is the color of pain.",
		FEATHER_CANARY = "Yellow is the color of naivety.",
		FEATHERPENCIL = "Not as elegant as a quill and inkwell, but it'll do.",
        COOKBOOK = "Very well. If I can master the dark arts, how hard could cooking be?",
		FEM_PUPPET = "Better her than me.", --single player
		FIREFLIES =
		{
			GENERIC = "How pretty.",
			HELD = "I could squish them if I wanted to.",
		},
		FIREHOUND = "I put fire gems in there as a joke.",
		FIREPIT =
		{
			EMBERS = "I should attend to that.",
			GENERIC = "A fire pit.",
			HIGH = "A roaring fire.",
			LOW = "It's getting low.",
			NORMAL = "It's hot.",
			OUT = "It's gone cold.",
		},
		COLDFIREPIT =
		{
			EMBERS = "Someone should attend to that.",
			GENERIC = "A fire pit.",
			HIGH = "A roaring, cold fire.",
			LOW = "It's getting low.",
			NORMAL = "It's cold.",
			OUT = "It's gone warm.",
		},
		FIRESTAFF = "A basic enchantment, but effective.",
		FIRESUPPRESSOR =
		{
			ON = "Begone, fire!",
			OFF = "Quiet before the storm.",
			LOWFUEL = "Not much fuel left.",
		},

		FISH = "Fresh from the murky depths.",
		FISHINGROD = "I will eat for a lifetime.",
		FISHSTICKS = "These should tide me over.",
		FISHTACOS = "Cooked fish in a crunchy shell.",
		FISH_COOKED = "It still stinks.",
		FLINT = "Ow! I cut my finger!",
		FLOWER =
		{
            GENERIC = "I am filled with the irrational urge to stomp upon it.",
            ROSE = "This is wrong.",
        },
        FLOWER_WITHERED = "It got what it deserved.",
		FLOWERHAT = "Definitely not my style.",
		FLOWER_EVIL = "I like that flower.",
		FOLIAGE = "A meal fit for a peasant.",
		FOOTBALLHAT = "Ready for the scrimmage.",
        FOSSIL_PIECE = "Perhaps it is best left in pieces.",
        FOSSIL_STALKER =
        {
			GENERIC = "The beginnings of some demonic beast.",
			FUNNY = "It will be the laughingstock of the demon community.",
			COMPLETE = "Was it wise to unleash this upon the world?",
        },
        STALKER = "There is no limit to the power of shadows.",
        STALKER_ATRIUM = "The Atrium's power restored his mind.",
        STALKER_MINION = "A being of living fuel.",
        THURIBLE = "Curious. It smells like roses.",
        ATRIUM_OVERGROWTH = "I can't believe I've forgotten how to read this.",
		FROG =
		{
			DEAD = "It croaked.",
			GENERIC = "It jumps and licks things.",
			SLEEPING = "It looks tired.",
		},
		FROGGLEBUNWICH = "Has a bit of a kick to it.",
		FROGLEGS = "Muscular.",
		FROGLEGS_COOKED = "Stringy.",
		FRUITMEDLEY = "This would be great with a simple cheese plate.",
		FURTUFT = "Not quite enough for a rug.",
		GEARS = "My pets! What has become of you?",
		GHOST = "It remembers me!",
		GOLDENAXE = "It gets sharper with every cut.",
		GOLDENPICKAXE = "This must be game logic.",
		GOLDENPITCHFORK = "I'm not sure this was a good investment.",
		GOLDENSHOVEL = "This shovel is worth a princely sum.",
		GOLDNUGGET = "This was important to me once.",
		GRASS =
		{
			BARREN = "Needs manure.",
			WITHERED = "You'd think grass could withstand this heat...",
			BURNING = "Oops.",
			GENERIC = "Tufty.",
			PICKED = "Nothing to harvest.",
			DISEASED = "What has brought this blight upon my world?", --unimplemented
			DISEASING = "Looks a little off, if you ask me.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "I'm sure its tail grows back.",
			DISEASED = "It's sickly and frail.", --unimplemented
		},
		GREEN_CAP = "I should eat it.",
		GREEN_CAP_COOKED = "Salty!",
		GREEN_MUSHROOM =
		{
			GENERIC = "Green fungus.",
			INGROUND = "When do those ones come up?",
			PICKED = "Been there. Done that.",
		},
		GUNPOWDER = "Now THIS I like.",
		HAMBAT = "An undignified weapon for a less refined time.",
		HAMMER = "It feels good to undo the work of others.",
		HEALINGSALVE = "Just a bit of venom and some dirty old ash.",
		HEATROCK =
		{
			FROZEN = "It's almost too cold to hold.",
			COLD = "Pleasantly cool.",
			GENERIC = "A pocketful of stone and temperature.",
			WARM = "Comfortably lukewarm.",
			HOT = "It's almost too hot to hold.",
		},
		HOME = "There's no place like it.",
		HOMESIGN =
		{
			GENERIC = "\"You are here\"... I wish I wasn't!",
            UNWRITTEN = "This requires profundity.",
			BURNT = "Somehow, it says even less now.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "\"Thataway\"... Ugh!",
            UNWRITTEN = "This requires profundity.",
			BURNT = "Somehow, it says even less now.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "\"Thataway\"... Ugh!",
            UNWRITTEN = "This requires profundity.",
			BURNT = "Somehow, it says even less now.",
		},
		HONEY = "Sticky and sweet.",
		HONEYCOMB = "It's full of bee maggots.",
		HONEYHAM = "Tender.",
		HONEYNUGGETS = "These look childish, but they're delicious.",
		HORN = "Call forth the beasts!",
		HOUND = "They don't recognize me!",
		HOUNDCORPSE =
		{
			GENERIC = "I wish we'd get rid of that.",
			BURNING = "Good riddance.",
			REVIVING = "It's coming alive again!",
		},
		HOUNDBONE = "Hungry devils, aren't they?",
		HOUNDMOUND = "It's a tunnel down to the hounds' nest.",
		ICEBOX = "A little piece of winter in a box.",
		ICEHAT = "Strap some ice on your head.",
		ICEHOUND = "I had a lot of surplus gems!",
		INSANITYROCK =
		{
			ACTIVE = "I can see its true nature now!",
			INACTIVE = "It only half-exists on this plane.",
		},
		JAMMYPRESERVES = "It's soiled my good gloves.",

		KABOBS = "Cooked to perfection.",
		KILLERBEE =
		{
			GENERIC = "What is that bee so angry about?",
			HELD = "I've caught a tiger by the tail.",
		},
		KNIGHT = "Such quality workmanship!",
		KOALEFANT_SUMMER = "A distant cousin of the beefalo.",
		KOALEFANT_WINTER = "It has its winter coat on.",
		KRAMPUS = "You won't catch me!",
		KRAMPUS_SACK = "It's really light.",
		LEIF = "Disgusting creature!",
		LEIF_SPARSE = "Disgusting creature!",
		LIGHTER  = "It does the job, I suppose.",
		LIGHTNING_ROD =
		{
			CHARGED = "Energy flows through it.",
			GENERIC = "A little bit of protection.",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "What's it always chewing on?",
			CHARGED = "Chaaarge!",
		},
		LIGHTNINGGOATHORN = "It'd make a nice horn.",
		GOATMILK = "It's charged with nutrients.",
		LITTLE_WALRUS = "A chip off the old block.",
		LIVINGLOG = "I like the noise they make when you burn them.",
		LOG =
		{
			BURNING = "Well. That was fun while it lasted.",
			GENERIC = "It's a piece of wood. What more is there to say?",
		},
		LUCY = "Ah. How have you been, Lucy?",
		LUREPLANT = "A vicious plant.",
		LUREPLANTBULB = "Perhaps I can use this to my advantage.",
		MALE_PUPPET = "Better him than me.", --single player

		MANDRAKE_ACTIVE = "Oh shut UP, will you?",
		MANDRAKE_PLANTED = "What a disturbing root.",
		MANDRAKE = "My ears are still ringing.",

        MANDRAKESOUP = "There'll be no more crying out of you.",
        MANDRAKE_COOKED = "Looks like I got the last meep.",
        MAPSCROLL = "There's nothing to be gleaned from this.",
        MARBLE = "It's strong stuff.",
        MARBLEBEAN = "Let me guess, it grows a marble stalk?",
        MARBLEBEAN_SAPLING = "Stone cold growth.",
        MARBLESHRUB = "I've found a shrubbery.",
        MARBLEPILLAR = "I've always wondered who built those.",
        MARBLETREE = "How whimsical.",
        MARSH_BUSH =
        {
			BURNT = "It is finished.",
            BURNING = "I should ask it questions.",
            GENERIC = "It's twisted and prickly, just like me!",
            PICKED = "That was painful.",
        },
        BURNT_MARSH_BUSH = "Utterly destroyed.",
        MARSH_PLANT = "What a generic little plant.",
        MARSH_TREE =
        {
            BURNING = "There it goes.",
            BURNT = "It's no use to anyone now.",
            CHOPPED = "Tree 0, Maxwell 1.",
            GENERIC = "A tree with a foul demeanor.",
        },
        MAXWELL = "Looking good!",--single player
        MAXWELLHEAD = "Hey, handsome.",--removed
        MAXWELLLIGHT = "Aw, it remembers me.",--single player
        MAXWELLLOCK = "It keeps the master in the chair.",--single player
        MAXWELLTHRONE = "It's less painful than it looks. Barely.",--single player
        MEAT = "I'm used to much finer fare.",
        MEATBALLS = "My compliments to the chef!",
        MEATRACK =
        {
            DONE = "Like the desert.",
            DRYING = "Still moist.",
            DRYINGINRAIN = "Moist and staying that way.",
            GENERIC = "It can dry meats so they'll last longer.",
            BURNT = "It's too brittle to hang meat on now.",
            DONE_NOTMEAT = "Like the desert.",
            DRYING_NOTMEAT = "Still moist.",
            DRYINGINRAIN_NOTMEAT = "Moist and staying that way.",
        },
        MEAT_DRIED = "My teeth are getting too old for this.",
        MERM = "They were already here when I arrived.",
        MERMHEAD =
        {
            GENERIC = "The eyes follow you around.",
            BURNT = "Roasted merm head. Delicious.",
        },
        MERMHOUSE =
        {
            GENERIC = "They copied the pigs, but they're even less intelligent.",
            BURNT = "Well, it burns just as well as the pigs' version.",
        },
        MINERHAT = "Eventually the firefly will starve.",
        MONKEY = "I don't have time for you!",
        MONKEYBARREL = "What a disgusting home.",
        MONSTERLASAGNA = "It would be unwise to ingest this.",
        FLOWERSALAD = "Leafy goodness.",
        ICECREAM = "Sundae, sundae, sundae!",
        WATERMELONICLE = "The case is cold on the melon.",
        TRAILMIX = "Nuts and berries. No bolts.",
        HOTCHILI = "Hot as heck!",
        GUACAMOLE = "There's a mole in the mix.",
        MONSTERMEAT = "How revolting.",
        MONSTERMEAT_DRIED = "My teeth are getting too old for this.",
        MOOSE = "It's definitely from the North, whatever that is.",
        MOOSE_NESTING_GROUND = "Filthy.",
        MOOSEEGG = "Ride the lightning, you big egg.",
        MOSSLING = "That's a fluffy... thing.",
        FEATHERFAN = "Is it windy out or is it just this fan?",
        MINIFAN = "This pathetic device... gets the job done.",
        GOOSE_FEATHER = "I could use a pillow filled with these.",
        STAFF_TORNADO = "Wind power.",
        MOSQUITO =
        {
            GENERIC = "Bloody bloodsucking bloodsuckers.",
            HELD = "I got him.",
        },
        MOSQUITOSACK = "A bloody sack. With blood in it.",
        MOUND =
        {
            DUG = "That one's already been done in.",
            GENERIC = "What lies beneath?",
        },
        NIGHTLIGHT = "It burns with a beautiful glow.",
        NIGHTMAREFUEL = "Ahhh. Refreshing.",
        NIGHTSWORD = "Snicker-snack!",
        NITRE = "One third of the way there...",
        ONEMANBAND = "It has a good beat, and you can dance to it.",
        OASISLAKE =
		{
			GENERIC = "Didn't think I'd ever come back here.",
			EMPTY = "It's not in season.",
		},
        PANDORASCHEST = "It's a trap.",
        PANFLUTE = "I'm going to sing a song of madness.",
        PAPYRUS = "A blank canvas.",
        WAXPAPER = "My interest in this wax paper wanes....",
        PENGUIN = "Nice tux.",
        PERD = "It is addicted to fermented berries.",
        PEROGIES = "They look superb.",
        PETALS = "I've a habit of destroying beautiful things, don't I?",
        PETALS_EVIL = "It's dripping with nightmare essence.",
        PHLEGM = "I need to put on gloves for this.",
        PICKAXE = "Everybody loves a little mining.",
        PIGGYBACK = "Oh, that's just demeaning.",
        PIGHEAD =
        {
            GENERIC = "Er... charming.",
            BURNT = "Pig roast!",
        },
        PIGHOUSE =
        {
            FULL = "I'd go inside too, if I was him.",
            GENERIC = "It is not a sound structure.",
            LIGHTSOUT = "I'll huff and I'll puff!",
            BURNT = "Let's see you hide in there now.",
        },
        PIGKING = "That's a man with his priorities in order!",
        PIGMAN =
        {
            DEAD = "I dub thee, \"Bacon\".",
            FOLLOWER = "He's simple, but he's mine.",
            GENERIC = "What a slobbering fool.",
            GUARD = "They're starting to organize.",
            WEREPIG = "That one's gone feral.",
        },
        PIGSKIN = "It was him or me.",
        PIGTENT = "That's just nasty.",
        PIGTORCH = "Great. Now they have fire.",
        PINECONE = "A more outdoorsy type might be able to make something of this.",
        PINECONE_SAPLING = "Huh, it seems to belong in the ground.",
        LUMPY_SAPLING = "Where did this appear from?",
        PITCHFORK = "The tool of choice for perfectionists.",
        PLANTMEAT = "A feeble attempt to trick the weak minded.",
        PLANTMEAT_COOKED = "The heat has made this a suitable meal.",
        PLANT_NORMAL =
        {
            GENERIC = "That is a generic plant.",
            GROWING = "It's growing.",
            READY = "It's ready.",
            WITHERED = "It wasn't hardy enough for the heat.",
        },
        POMEGRANATE = "Usually I'd get someone to seed this for me.",
        POMEGRANATE_COOKED = "A little more refined, at least.",
        POMEGRANATE_SEEDS = "Such labor is beneath me.",
        POND = "I can see my face reflected off the top.",
        POOP = "It's the way of all mortal life.",
        FERTILIZER = "It's not gentlemanly to carry manure in one's hands.",
        PUMPKIN = "Hallowe'en was always my favorite.",
        PUMPKINCOOKIE = "It's been eons since I had a good biscuit.",
        PUMPKIN_COOKED = "A little more refined, at least.",
        PUMPKIN_LANTERN = "Why hello, Mr. Crane.",
        PUMPKIN_SEEDS = "Such labor is beneath me.",
        PURPLEAMULET = "It speaks with the shadow.",
        PURPLEGEM = "Purple brings great power.",
        RABBIT =
        {
            GENERIC = "I've been here too long... it actually looks tasty.",
            HELD = "Don't worry, rabbit. Everything is under control.",
        },
        RABBITHOLE =
        {
            GENERIC = "There's a world going on under there.",
            SPRING = "The entrance has collapsed in on itself.",
        },
        RAINOMETER =
        {
            GENERIC = "I could just look up and learn the same thing.",
            BURNT = "The rain did not come in time.",
        },
        RAINCOAT = "Out, out rain!",
        RAINHAT = "Not the most dapper of hats, but quite necessary.",
        RATATOUILLE = "Roughage.",
        RAZOR = "If only the world had a single neck.",
        REDGEM = "Red brings fire.",
        RED_CAP = "I forget what this one does.",
        RED_CAP_COOKED = "Kind of bitter.",
        RED_MUSHROOM =
        {
            GENERIC = "It's a red mushroom.",
            INGROUND = "It'll have to come back for it.",
            PICKED = "It's all used up.",
        },
        REEDS =
        {
            BURNING = "Oops.",
            GENERIC = "There's wind in them there willows.",
            PICKED = "No more tubes.",
        },
        RELIC = "Remnants of an extinct civilization.",
        RUINS_RUBBLE = "A broken relic.",
        RUBBLE = "Everything eventually turns to dust.",
        RESEARCHLAB =
        {
            GENERIC = "I can't believe I forgot how to build those things.",
            BURNT = "The fire learned how to burn it down.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "It unlocks recipes of middling utility.",
            BURNT = "Flames have swallowed it whole.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "This is where I do my own personal research.",
            BURNT = "Research complete.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "Quite a dapper machine.",
            BURNT = "That was its final act.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "I'm not above using this.",
            BURNT = "No one will be using that any longer.",
        },
        RESURRECTIONSTONE = "There's a story behind that...",
        ROBIN =
        {
            GENERIC = "The redbird comes from the fire lands.",
            HELD = "Silence, bird!",
        },
        ROBIN_WINTER =
        {
            GENERIC = "You're new.",
            HELD = "Nothing up my sleeve...",
        },
        ROBOT_PUPPET = "Better them than me.", --single player
        ROCK_LIGHT =
        {
            GENERIC = "The top of this lava pit has cooled into a fine crust.",--removed
            OUT = "It looks harmless.",--removed
            LOW = "The fires are cooling.",--removed
            NORMAL = "It's hot.",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Well it's not going to move itself.",
            RAISED = "We must deal with the others first.",
        },
        ROCK = "It's a rock.",
        PETRIFIED_TREE = "I think it looks much better this way.",
        ROCK_PETRIFIED_TREE = "I think it looks much better this way.",
        ROCK_PETRIFIED_TREE_OLD = "I think it looks much better this way.",
        ROCK_ICE =
        {
            GENERIC = "I could get a chip of ice off the old block.",
            MELTED = "It's just a puddle.",
        },
        ROCK_ICE_MELTED = "It's just a puddle.",
        ICE = "Baby glaciers.",
        ROCKS = "Hmmm. Now what do I do with them?",
        ROOK = "A castle for my home.",
        ROPE = "You'd think this would have more uses.",
        ROTTENEGG = "Disgusting. Why keep this around?",
        ROYAL_JELLY = "Unsettlingly wobbly.",
        JELLYBEAN = "I think there's seventeen in there.",
        SADDLE_BASIC = "But that means I'd have to touch the smelly thing.",
        SADDLE_RACE = "But is it fast enough to escape the judgmental stares?",
        SADDLE_WAR = "At least it affords some dignity to the rider.",
        SADDLEHORN = "And I may never put it back on.",
        SALTLICK = "So salty.",
        BRUSH = "It's like showing affection, without actually touching it.",
		SANITYROCK =
		{
			ACTIVE = "I can see its true nature now!",
			INACTIVE = "There are two ways to see that obstacle.",
		},
		SAPLING =
		{
			BURNING = "Oops.",
			WITHERED = "Nothing survives in this heat.",
			GENERIC = "A supple, woody stem.",
			PICKED = "It'll grow back.",
			DISEASED = "What has brought this blight upon my world?", --removed
			DISEASING = "Looks a little off, if you ask me.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "It's an empty shell of a man.",
			BURNING = "Nothing is safe.",
			BURNT = "The scarecrow has gone to a place where there is no fear.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "A block of marble might suffice.",
			BLOCK = "How I've missed the act of creation.",
			SCULPTURE = "Ah, yes. Not terrible.",
			BURNT = "To sculpt, to carve, no more.",
   		},
        SCULPTURE_KNIGHTHEAD = "That looks... familiar...",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "Waste of good marble if you ask me.",
			UNCOVERED = "My creations! How rude.",
			FINISHED = "Back as intended.",
			READY = "We'll get you out in a tick, friend.",
		},
        SCULPTURE_BISHOPHEAD = "I've seen that head before... but never in marble.",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Hmph. I was never a fan of the Grecian look.",
			UNCOVERED = "Come now! I liked that one.",
			FINISHED = "That looks much better.",
			READY = "We'll get you out in a tick, friend.",
		},
        SCULPTURE_ROOKNOSE = "That's quite the schnozz.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Some truly questionable taste in decor.",
			UNCOVERED = "Why would anyone want to cover this up?",
			FINISHED = "Doesn't that feel better now?",
			READY = "We'll get you out in a tick, friend.",
		},
        GARGOYLE_HOUND = "Try and get me now. Ha!",
        GARGOYLE_WEREPIG = "Not so tough.",
		SEEDS = "I suppose these won't plant themselves.",
		SEEDS_COOKED = "Broiled the life out of 'em.",
		SEWING_KIT = "A fine and noble endeavor.",
		SEWING_TAPE = "The wilderness is tough on a tailor made suit.",
		SHOVEL = "This is some real advanced technology.",
		SILK = "Despite its origin, it could make some fine garments.",
		SKELETON = "Ha! I remember that one.",
		SCORCHED_SKELETON = "At least the fire cut down on the smell.",
		SKULLCHEST = "That chest is calling to me.", --removed
		SMALLBIRD =
		{
			GENERIC = "What!? What do you want?",
			HUNGRY = "You want some food?",
			STARVING = "He's so hungry!",
			SLEEPING = "He's finally asleep.",
		},
		SMALLMEAT = "This is barely a mouthful.",
		SMALLMEAT_DRIED = "My teeth are getting too old for this.",
		SPAT = "Ornery and tough as nails.",
		SPEAR = "It's a spear. Yup.",
		SPEAR_WATHGRITHR = "I can appreciate a finely crafted weapon.",
		WATHGRITHRHAT = "Well... it's no crown.",
		SPIDER =
		{
			DEAD = "Splat.",
			GENERIC = "It's mostly digestive system.",
			SLEEPING = "Shhhh! It will wake up hungry.",
		},
		SPIDERDEN = "They grow big here.",
		SPIDEREGGSACK = "Squishy.",
		SPIDERGLAND = "Distasteful.",
		SPIDERHAT = "Spiders have such malleable wills.",
		SPIDERQUEEN = "Maybe I'll just get out of her way.",
		SPIDER_WARRIOR =
		{
			DEAD = "Splat.",
			GENERIC = "It's a specialized form.",
			SLEEPING = "I don't want to wake that one.",
		},
		SPOILED_FOOD = "That used to be food until I wasted it.",
        STAGEHAND =
        {
			AWAKE = "Hmph. Impressive sleight of hand.",
			HIDING = "This must be the work of an unseen hand.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "Hm. Stately.",
            TYPE1 = "Her tragedy does not define her.",
            TYPE2 = "She's still in there somewhere. I know it.",
            TYPE3 = "Needs something. Perhaps some long-stemmed roses...", --bird bath type statue
        },
		STATUEHARP = "Not my best work.",
		STATUEMAXWELL = "It seems silly now...",
		STEELWOOL = "Someone should use this to clean something.",
		STINGER = "It's dripping with venom.",
		STRAWHAT = "A hat fit for a peasant.",
		STUFFEDEGGPLANT = "A meal fit for a king... or at least someone with a throne.",
		SWEATERVEST = "It's no three-piece, but it's dapper enough.",
		REFLECTIVEVEST = "Safety before dapperness.",
		HAWAIIANSHIRT = "The dapperest of them all.",
		TAFFY = "It's almost entirely sugar.",
		TALLBIRD = "These were a failed experiment.",
		TALLBIRDEGG = "Tallbirds are territorial because of these things.",
		TALLBIRDEGG_COOKED = "It tastes like broken dreams.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "It's getting tepid.",
			GENERIC = "We've got a live one here.",
			HOT = "Hot enough for ya?",
			LONG = "It's going to be a while.",
			SHORT = "Any moment now...",
		},
		TALLBIRDNEST =
		{
			GENERIC = "Well. That's tempting.",
			PICKED = "It's made of dirty beefalo hair.",
		},
		TEENBIRD =
		{
			GENERIC = "It's less cute now that it's grown up.",
			HUNGRY = "They sure do eat a lot.",
			STARVING = "A hungry beast is a dangerous beast.",
			SLEEPING = "It's much easier to deal with like this.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "It's alive!", --single player
			GENERIC = "My beautiful machine is in pieces!", --single player
			LOCKED = "Now to turn it on.", --single player
			PARTIAL = "It is still incomplete.", --single player
		},
		TELEPORTATO_BOX = "This is a box full of sadness and woe.", --single player
		TELEPORTATO_CRANK = "This is used to agitate the humors.", --single player
		TELEPORTATO_POTATO = "The gears in here are so small they turn the fabric of reality.", --single player
		TELEPORTATO_RING = "This is the quantum field guard band.", --single player
		TELESTAFF = "Magic can do amazing things, when funneled through the right channels.",
		TENT =
		{
			GENERIC = "That's a bit rustic for my taste.",
			BURNT = "That's a bit burned for my taste.",
		},
		SIESTAHUT =
		{
			GENERIC = "Rustic, but excellent shade.",
			BURNT = "So much for the shade thing.",
		},
		TENTACLE = "I'm glad the rest of it is still down there.",
		TENTACLESPIKE = "Ugh. This is so revolting.",
		TENTACLESPOTS = "This is how they reproduce.",
		TENTACLE_PILLAR = "How deep does this go?",
        TENTACLE_PILLAR_HOLE = "Ugh! How can it live down there?",
		TENTACLE_PILLAR_ARM = "Babies?",
		TENTACLE_GARDEN = "This one is odd.",
		TOPHAT = "Some fine haberdashery.",
		TORCH = "It keeps Charlie at bay.",
		TRANSISTOR = "I don't understand how it works, but it does.",
		TRAP = "Only the dumbest animals will fall for this.",
		TRAP_TEETH = "This one packs a wallop.",
		TRAP_TEETH_MAXWELL = "I'm... sure I had my reasons when I placed this.", --single player
		TREASURECHEST =
		{
			GENERIC = "A place to store loot.",
			BURNT = "It won't store anything now.",
		},
		TREASURECHEST_TRAP = "Hmmm. Looks suspicious.",
		SACRED_CHEST =
		{
			GENERIC = "A relic best forgotten.",
			LOCKED = "It seems I am to be judged.",
		},
		TREECLUMP = "I can't get through there.", --removed

		TRINKET_1 = "These must have been heated to an incredible temperature.", --Melted Marbles
		TRINKET_2 = "A complete and utter fraud...", --Fake Kazoo
		TRINKET_3 = "A tangled mess. Like life.", --Gord's Knot
		TRINKET_4 = "Don't look at me like that.", --Gnome
		TRINKET_5 = "A toy for a child's mind.", --Toy Rocketship
		TRINKET_6 = "I might hide those in the robot's bedroll if I get bored.", --Frazzled Wires
		TRINKET_7 = "Not something a grown man should be caught playing with.", --Ball and Cup
		TRINKET_8 = "I'd prefer a pocketwatch on a chain.", --Rubber Bung
		TRINKET_9 = "My suits don't deserve to be defaced with these tacky atrocities.", --Mismatched Buttons
		TRINKET_10 = "Is that a crack about my age?", --Dentures
		TRINKET_11 = "I'm not listening.", --Lying Robot
		TRINKET_12 = "I'm not touching that without several pairs of gloves.", --Dessicated Tentacle
		TRINKET_13 = "Don't look at me like that.", --Gnomette
		TRINKET_14 = "Perhaps I'll invite the librarian for a nice mandrake tea.", --Leaky Teacup
		TRINKET_15 = "Charlie was the only one who ever kept me in check.", --Pawn
		TRINKET_16 = "Charlie was the only one who ever kept me in check.", --Pawn
		TRINKET_17 = "The product of a very immature magician, perhaps.", --Bent Spork
		TRINKET_18 = "A metaphor, perhaps.", --Trojan Horse
		TRINKET_19 = "Admittedly, it's difficult to maintain balance when you're on top.", --Unbalanced Top
		TRINKET_20 = "Eliminates the use of the phrase \"You scratch my back, I'll scratch yours.\"", --Backscratcher
		TRINKET_21 = "I know when I've been beaten.", --Egg Beater
		TRINKET_22 = "The monster child gets tangled in this frequently.", --Frayed Yarn
		TRINKET_23 = "I was looking for that.", --Shoehorn
		TRINKET_24 = "It's been beheaded.", --Lucky Cat Jar
		TRINKET_25 = "The strongman's wardrobe is brimming with them, judging from the odor.", --Air Unfreshener
		TRINKET_26 = "This was important to one very specific person once.", --Potato Cup
		TRINKET_27 = "Finally. My suits were getting wrinkles. Wrinkles!", --Coat Hanger
		TRINKET_28 = "It is still beholden to the king.", --Rook
        TRINKET_29 = "It is still beholden to the king.", --Rook
        TRINKET_30 = "Not a pawn, but still a minion.", --Knight
        TRINKET_31 = "Not a pawn, but still a minion.", --Knight
        TRINKET_32 = "Amateur magic for children.", --Cubic Zirconia Ball
        TRINKET_33 = "The opposite of dapper.", --Spider Ring
        TRINKET_34 = "I'm done tampering with magical oddities, thank-you.", --Monkey Paw
        TRINKET_35 = "I'm not in the habit of imbibing strange liquids.", --Empty Elixir
        TRINKET_36 = "Permanently bared.", --Faux fangs
        TRINKET_37 = "I told you people, I am *not* a vampire!", --Broken Stake
        TRINKET_38 = "You are all ants in my eyes already.", -- Binoculars Griftlands trinket
        TRINKET_39 = "What a tacky glove.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "One hundred percent to scale.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "I've no idea what that is.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "It looks cheap.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "What use would I have of such a thing?", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Rosebud.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "At least it's not ragtime.", -- Odd Radio ONI trinket
        TRINKET_46 = "Some harebrained invention of the scientist's, perhaps?", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "I'd better leave that be.",
        LOST_TOY_2  = "I'd better leave that be.",
        LOST_TOY_7  = "I'd better leave that be.",
        LOST_TOY_10 = "I'd better leave that be.",
        LOST_TOY_11 = "I'd better leave that be.",
        LOST_TOY_14 = "I'd better leave that be.",
        LOST_TOY_18 = "I'd better leave that be.",
        LOST_TOY_19 = "I'd better leave that be.",
        LOST_TOY_42 = "I'd better leave that be.",
        LOST_TOY_43 = "I'd better leave that be.",

        HALLOWEENCANDY_1 = "Oh good, it's solid candy. I feared something healthy had snuck in.",
        HALLOWEENCANDY_2 = "Waxy, just like me.",
        HALLOWEENCANDY_3 = "Who is making all this candy, exactly?",
        HALLOWEENCANDY_4 = "Black licorice, my favorite.",
        HALLOWEENCANDY_5 = "Almost endearing. Almost.",
        HALLOWEENCANDY_6 = "A mystery I'm not keen on solving.",
        HALLOWEENCANDY_7 = "I am much more disappointed than I thought I'd be.",
        HALLOWEENCANDY_8 = "No one is above enjoying a good lollipop.",
        HALLOWEENCANDY_9 = "How the tables have turned, worm.",
        HALLOWEENCANDY_10 = "No one is above enjoying a good lollipop.",
        HALLOWEENCANDY_11 = "Eating them makes me feel powerful.",
        HALLOWEENCANDY_12 = "Ah, maggots... how novel.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "It's not terrible.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Only ruffians enjoy torturing themselves like this.", --Hot Lava pepper candy
        CANDYBAG = "That's our sugar-sack.",

		HALLOWEEN_ORNAMENT_1 = "Oh joy. Is there really need for decoration?",
		HALLOWEEN_ORNAMENT_2 = "Such a burden to carry it. If only there were a place to leave it.",
		HALLOWEEN_ORNAMENT_3 = "I like the real ones better.",
		HALLOWEEN_ORNAMENT_4 = "Shouldn't it be hanging from somewhere.",
		HALLOWEEN_ORNAMENT_5 = "Ugh. These guys again.",
		HALLOWEEN_ORNAMENT_6 = "Why do I hear \"Nevermore\"?",

		HALLOWEENPOTION_DRINKS_WEAK = "Could be a little stronger.",
		HALLOWEENPOTION_DRINKS_POTENT = "Ah. This'll do the trick.",
        HALLOWEENPOTION_BRAVERY = "Takes away the horrors. But who would want that?",
		HALLOWEENPOTION_MOON = "A fine pot of tea, with a side of mutation.",
		HALLOWEENPOTION_FIRE_FX = "Might as well throw it in the fire.",
		MADSCIENCE_LAB = "How maddening.",
		LIVINGTREE_ROOT = "Ah. A chance to grow something horrible.",
		LIVINGTREE_SAPLING = "Just days away from dreadful.",

        DRAGONHEADHAT = "Quite formidable looking.",
        DRAGONBODYHAT = "I'm no middleman.",
        DRAGONTAILHAT = "The back end of a terrible beast.",
        PERDSHRINE =
        {
            GENERIC = "It seems my fortune's changing.",
            EMPTY = "Something else seems to be required.",
            BURNT = "It's no use to anyone now.",
        },
        REDLANTERN = "Not having a light would certainly be unlucky.",
        LUCKY_GOLDNUGGET = "Gold's gold as far as I'm concerned.",
        FIRECRACKERS = "Great for magic tricks.",
        PERDFAN = "Now I'll have no problem keeping my cool.",
        REDPOUCH = "A spot of luck.",
        WARGSHRINE =
        {
            GENERIC = "The preparations have been made.",
            EMPTY = "It requires a torch.",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Burnt to cinders.",
        },
        CLAYWARG =
        {
        	GENERIC = "This earthen beast's all fired up.",
        	STATUE = "How delightfully disconcerting.",
        },
        CLAYHOUND =
        {
        	GENERIC = "I was wise to be suspicious.",
        	STATUE = "I don't trust it.",
        },
        HOUNDWHISTLE = "Howl I ever find a use for this?",
        CHESSPIECE_CLAYHOUND = "It's quite fetching.",
        CHESSPIECE_CLAYWARG = "What a gruesome maw.",

		PIGSHRINE =
		{
            GENERIC = "How quaint.",
            EMPTY = "It needs some kind of meat.",
            BURNT = "Not useful like this.",
		},
		PIG_TOKEN = "Those pigs are getting more and more clever.",
		PIG_COIN = "Perfect. I'll try not to spend it all in one place.",
		YOTP_FOOD1 = "Ah. I do enjoy a nice meal.",
		YOTP_FOOD2 = "Ugh. More fit for a creature than for me.",
		YOTP_FOOD3 = "Nothing fancy, but it will do.",

		PIGELITE1 = "He's a slippery fellow.", --BLUE
		PIGELITE2 = "A fiery one.", --RED
		PIGELITE3 = "Filthy.", --WHITE
		PIGELITE4 = "Rotten to the core.", --GREEN

		PIGELITEFIGHTER1 = "He's a slippery fellow.", --BLUE
		PIGELITEFIGHTER2 = "A fiery one.", --RED
		PIGELITEFIGHTER3 = "Filthy.", --WHITE
		PIGELITEFIGHTER4 = "Rotten to the core.", --GREEN

		CARRAT_GHOSTRACER = "Starting to feel left out?",

        YOTC_CARRAT_RACE_START = "I suppose this is what I must do for entertainment now.",
        YOTC_CARRAT_RACE_CHECKPOINT = "These posts will serve as adequate route markers.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "Such frivolity.",
            BURNT = "I've no use for it anymore.",
            I_WON = "I'd almost forgotten the sweet taste of victory.",
            SOMEONE_ELSE_WON = "{winner}'s racer was... superior to mine...",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Might as well start things off with a bang. Or a gong.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "The dumb little creatures would be lost without them.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "End of the line, pal.",

		YOTC_SEEDPACKET = "I will reap what I sow.",
		YOTC_SEEDPACKET_RARE = "This should yield a higher quality crop.",

		MINIBOATLANTERN = "It's oddly beautiful.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "It's ready.",
            EMPTY = "It requires an offering.",
            BURNT = "It's of no use to me like this.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "An underling must be able to follow directions.",
            RAT = "The training seems to be progressing well.",
            BURNT = "Useless.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Athletics were never my strong suit.",
            RAT = "It's rather amusing to watch it scurry.",
            BURNT = "Useless.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "You never know what might pop up on the race track.",
            RAT = "Hm. I'm getting a sudden craving for popcorn...",
            BURNT = "Useless.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "An exercise machine... the most dastardly of inventions.",
            RAT = "You will thank me for making you stronger.",
            BURNT = "Useless.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "My Carrat requires some direction.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "I should construct this, posthaste.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "I tire of lugging this around.",
        YOTC_CARRAT_GYM_REACTION_ITEM = "It would be prudent to place this somewhere.",

        YOTC_CARRAT_SCALE_ITEM = "It seems some assembly is required.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "I will only accept the finest Carrat.",
            CARRAT = "A disappointing performance.",
            CARRAT_GOOD = "Excellent. You've done well.",
            BURNT = "It's worthless now.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "Let's get on with it then.",
            EMPTY = "It will require an offering.",
            BURNT = "Pity.",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "How ridiculous.",
            OCCUPIED = "I suppose I'll have to try to make this creature less homely.",
            BURNT = "What a shame.",
        },
        BEEFALO_GROOMER_ITEM = "Do I look like a common construction worker? Oh very well...",

		BISHOP_CHARGE_HIT = "How DARE you!",
		TRUNKVEST_SUMMER = "It's more of a fall vest.",
		TRUNKVEST_WINTER = "It's so hard to look fashionable in the winter.",
		TRUNK_COOKED = "At least the mucus burned off.",
		TRUNK_SUMMER = "Full of summer mucus.",
		TRUNK_WINTER = "The trunk thickens in the winter to hold more mucus.",
		TUMBLEWEED = "Tumble on, weed.",
		TURKEYDINNER = "How festive.",
		TWIGS = "Common, but useful.",
		UMBRELLA = "It's crooked!",
		GRASS_UMBRELLA = "It's more \"pretty\" than \"dapper\".",
		UNIMPLEMENTED = "Just what are you up to now, Charlie?",
		WAFFLES = "An excellent start to the morning. Or evening.",
		WALL_HAY =
		{
			GENERIC = "It's a tinderbox.",
			BURNT = "I told you so.",
		},
		WALL_HAY_ITEM = "Pocket-sized wall pieces. Yup.",
		WALL_STONE = "This will keep the riff-raff out.",
		WALL_STONE_ITEM = "Pocket-sized wall pieces. Yup.",
		WALL_RUINS = "An ancient wall.",
		WALL_RUINS_ITEM = "Pocket-sized wall pieces. Yup.",
		WALL_WOOD =
		{
			GENERIC = "Moderately tough, but flammable.",
			BURNT = "Not tough, nor flammable.",
		},
		WALL_WOOD_ITEM = "Pocket-sized wall pieces. Yup.",
		WALL_MOONROCK = "I like to build walls between myself and the world.",
		WALL_MOONROCK_ITEM = "Where should I put this?",
		FENCE = "My life is one obstacle after another.",
        FENCE_ITEM = "A fence for your pocket.",
        FENCE_GATE = "When one gate closes...",
        FENCE_GATE_ITEM = "A gate for your pocket.",
		WALRUS = "Don't you recognize me?",
		WALRUSHAT = "Made in Scotland.",
		WALRUS_CAMP =
		{
			EMPTY = "I best not linger when winter comes.",
			GENERIC = "The Walrusser can't be far.",
		},
		WALRUS_TUSK = "I'll put this to better use.",
		WARDROBE =
		{
			GENERIC = "Fashion without function.",
            BURNING = "Oops.",
			BURNT = "Dapperness is a state of mind.",
		},
		WARG = "The alpha!",
        WARGLET = "They're smaller than I remember... going soft on us, Charlie?",
        
		WASPHIVE = "That looks dangerous.",
		WATERBALLOON = "Do you have any idea how much this suit cost?",
		WATERMELON = "It's mostly water. Fibrous, sweet water.",
		WATERMELON_COOKED = "Grillermelon.",
		WATERMELONHAT = "This is one way to keep cool. And sticky.",
		WAXWELLJOURNAL = "I'm so sorry, Charlie.",
		WETGOOP = "How uncultured.",
        WHIP = "Makes me feel like the master again.",
		WINTERHAT = "How disappointingly rustic.",
		WINTEROMETER =
		{
			GENERIC = "Not the most useful invention, is it?",
			BURNT = "Who cares?",
		},

        WINTER_TREE =
        {
            BURNT = "That's that, it seems.",
            BURNING = "It's a Winter's Feast miracle.",
            CANDECORATE = "How wretchedly jolly.",
            YOUNG = "Have we nothing better to do with our time?",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "How repulsively festive.",
            BURNT = "That's that, it seems.",
		},
        WINTER_ORNAMENT = "Gaudy, like the rest of this shindig.",
        WINTER_ORNAMENTLIGHT = "How frivolous.",
        WINTER_ORNAMENTBOSS = "What a thing to risk one's life for.",
		WINTER_ORNAMENTFORGE = "A volatile decoration.",
		WINTER_ORNAMENTGORGE = "There's something familiar about this...",

        WINTER_FOOD1 = "Stop looking at me, cookie fiend.", --gingerbread cookie
        WINTER_FOOD2 = "We're celebrating freezing to death, I see.", --sugar cookie
        WINTER_FOOD3 = "I don't even use a cane.", --candy cane
        WINTER_FOOD4 = "It is unbound from time.", --fruitcake
        WINTER_FOOD5 = "How, err... traditional.", --yule log cake
        WINTER_FOOD6 = "It's extremely rich.", --plum pudding
        WINTER_FOOD7 = "Glorified apple juice.", --apple cider
        WINTER_FOOD8 = "Such a decadent beverage.", --hot cocoa
        WINTER_FOOD9 = "My... favorite... she remembered.", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Something about it... ah, I'm sure it's nothing.",
			COOKING = "What's it cooking up now?",
			ALMOST_DONE_COOKING = "I do wish it would hurry up.",
			DISH_READY = "Finally!",
		},
		BERRYSAUCE = "This seems like a lot of fuss for some mashed berries.",
		BIBINGKA = "It has a unique spongy texture.",
		CABBAGEROLLS = "Meat rolled in cabbage. How exciting.",
		FESTIVEFISH = "I don't know what's so festive about it.",
		GRAVY = "I have a tendency to overdo it on the gravy.",
		LATKES = "They're acceptable.",
		LUTEFISK = "It has an odd, yet strangely mouthwatering aroma.",
		MULLEDDRINK = "It brings a small respite from this wretched cold.",
		PANETTONE = "Fruitcake's more agreeable cousin.",
		PAVLOVA = "It has a certain elegance to it.",
		PICKLEDHERRING = "I suppose I can't be picky.",
		POLISHCOOKIE = "How quaint.",
		PUMPKINPIE = "Well... perhaps just a slice.",
		ROASTTURKEY = "I myself will carve this roast beast.",
		STUFFING = "Something to fill the void in my stomach.",
		SWEETPOTATO = "How very... rustic.",
		TAMALES = "They've got a bit of kick to them.",
		TOURTIERE = "I haven't had a meat pie since I left Liverpool.",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "Must we go through this production for a little food?",
			HAS_FOOD = "I suppose I'll have to share.",
			WRONG_TYPE = "The wrong place for this.",
			BURNT = "Humbug.",
		},

		GINGERBREADWARG = "Pretty brash for something so edible.",
		GINGERBREADHOUSE = "Entirely too gaudy.",
		GINGERBREADPIG = "Must you make me chase you?",
		CRUMBS = "It's falling apart.",
		WINTERSFEASTFUEL = "I prefer my fuel more nightmarish.",

        KLAUS = "My, what a magnificently horrific creature.",
        KLAUS_SACK = "What dark treasures lie within?",
		KLAUSSACKKEY = "Magic has done things to this beast's horn.",
		WORMHOLE =
		{
			GENERIC = "It's worse knowing what the other part looks like.",
			OPEN = "I assure you that it smells worse than it looks.",
		},
		WORMHOLE_LIMITED = "It looks ill.",
		ACCOMPLISHMENT_SHRINE = "Even They couldn't build something so devious.", --single player
		LIVINGTREE = "It's got a face.",
		ICESTAFF = "Cool staff.",
		REVIVER = "I'm not sure I really want to give this up.",
		SHADOWHEART = "A pulse of malice and betrayal beats within.",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "A picture of the city, before the fuel.",
			LINE_2 = "We all know what happens next.",
			LINE_3 = "They gained such an enviable power...",
			LINE_4 = "I know why you led me back here.",
			LINE_5 = "But it won't work.",
		},
        ATRIUM_STATUE = "There's a dreamlike quality to the material.",
        ATRIUM_LIGHT =
        {
			ON = "It feeds off the nightmare.",
			OFF = "No fuel, no power.",
		},
        ATRIUM_GATE =
        {
			ON = "This is a most wretched idea.",
			OFF = "It lacks a key.",
			CHARGING = "It is feeding off the dark energy.",
			DESTABILIZING = "Now we've gone and done it.",
			COOLDOWN = "Best not to overuse this power.",
        },
        ATRIUM_KEY = "It's strange to see it.",
		LIFEINJECTOR = "Who would put this filth in their veins?",
		SKELETON_PLAYER =
		{
			MALE = "A pity, %s. He was not prepared for %s.",
			FEMALE = "A pity, %s. She was not prepared for %s.",
			ROBOT = "A pity, %s. They were not prepared for %s.",
			DEFAULT = "A pity, %s. So ill-prepared for %s.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "\"Moon\" rock.",
		MOONROCKNUGGET = "\"Moon\" rock.",
		MOONROCKCRATER = "This will make a decent magical vessel.",
		MOONROCKSEED = "Oooh, some new knowledge.",

        REDMOONEYE = "Its aura can be felt from anywhere. Quite useful.",
        PURPLEMOONEYE = "A decent enough use of the gem's power, I suppose.",
        GREENMOONEYE = "It's useful for keeping in contact with my... acquaintances.",
        ORANGEMOONEYE = "I have a feeling of being watched, even from a considerable distance away.",
        YELLOWMOONEYE = "A conveniently color-coded place marker.",
        BLUEMOONEYE = "That reminds me, I must practice my cold glare tonight!",

        --Arena Event
        LAVAARENA_BOARLORD = "You seem severely deluded, good sir.",
        BOARRIOR = "Well he's certainly no slouch.",
        BOARON = "Begone, swine.",
        PEGHOOK = "I should like to avoid a pinch from that, I think.",
        TRAILS = "What a brute!",
        TURTILLUS = "He's rather thick-headed.",
        SNAPPER = "I don't fear you, scoundrel.",
		RHINODRILL = "Brutish grotesquerie.",
		BEETLETAUR = "Back to the dungeons with you!",

        LAVAARENA_PORTAL =
        {
            ON = "Let us end this chapter of our journey.",
            GENERIC = "Meddling with it will only cause further trouble.",
        },
        LAVAARENA_KEYHOLE = "A key is key.",
		LAVAARENA_KEYHOLE_FULL = "Right as rain.",
        LAVAARENA_BATTLESTANDARD = "We must destroy that Battle Standard.",
        LAVAARENA_SPAWNER = "It's a one-way portal.",

        HEALINGSTAFF = "I could be persuaded to dabble in white magicks.",
        FIREBALLSTAFF = "A staff after my own heart!",
        HAMMER_MJOLNIR = "I would never resort to something so brutish.",
        SPEAR_GUNGNIR = "I would never stoop to such things.",
        BLOWDART_LAVA = "That is not my style.",
        BLOWDART_LAVA2 = "I'm no blowhard.",
        LAVAARENA_LUCY = "I have no desire to use that.",
        WEBBER_SPIDER_MINION = "Disgusting.",
        BOOK_FOSSIL = "I could stop a fiend in its tracks with this.",
		LAVAARENA_BERNIE = "That thing's still shambling about, I see.",
		SPEAR_LANCE = "How churlish.",
		BOOK_ELEMENTAL = "The words within evoke an unknown force.",
		LAVAARENA_ELEMENTAL = "You shall serve us.",

   		LAVAARENA_ARMORLIGHT = "It is nearly useless.",
		LAVAARENA_ARMORLIGHTSPEED = "Swiftly useless.",
		LAVAARENA_ARMORMEDIUM = "It offers a serviceable amount of protection.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "This was intended for someone physically-inclined.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Decent protection that will enhance my power.",
		LAVAARENA_ARMORHEAVY = "Seems heavy.",
		LAVAARENA_ARMOREXTRAHEAVY = "Quite a clunky looking thing.",

		LAVAARENA_FEATHERCROWNHAT = "Horsefeathers.",
        LAVAARENA_HEALINGFLOWERHAT = "I could use the invigoration.",
        LAVAARENA_LIGHTDAMAGERHAT = "That is not suited to me.",
        LAVAARENA_STRONGDAMAGERHAT = "I'd never wear such an undapper thing.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "A decent wreath, should I feel like healing.",
        LAVAARENA_EYECIRCLETHAT = "I must have it.",
        LAVAARENA_RECHARGERHAT = "It will quickly restore my powers.",
        LAVAARENA_HEALINGGARLANDHAT = "Self sufficiency in wreath form.",
        LAVAARENA_CROWNDAMAGERHAT = "You'd need a thick neck to wear such a thing.",

		LAVAARENA_ARMOR_HP = "A little extra armor never hurt.",

		LAVAARENA_FIREBOMB = "Not really my style.",
		LAVAARENA_HEAVYBLADE = "Too brutish for my tastes.",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "Best offer it something if we enjoy living.",
        	FULL = "I'm not sure how it draws magic from this.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "I do like a good statue.",
		QUAGMIRE_PARK_FOUNTAIN = "Just useless rubble now.",

        QUAGMIRE_HOE = "This is so very beneath me.",

        QUAGMIRE_TURNIP = "It's a big, bulbous turnip.",
        QUAGMIRE_TURNIP_COOKED = "Hardly improves the taste.",
        QUAGMIRE_TURNIP_SEEDS = "Am I supposed to plant these?",

        QUAGMIRE_GARLIC = "I suppose that's why there are no vampires around.",
        QUAGMIRE_GARLIC_COOKED = "I wonder if it still wards away the undead.",
        QUAGMIRE_GARLIC_SEEDS = "Am I supposed to plant these?",

        QUAGMIRE_ONION = "It's a pungent onion.",
        QUAGMIRE_ONION_COOKED = "Take that, onion.",
        QUAGMIRE_ONION_SEEDS = "Am I supposed to plant these?",

        QUAGMIRE_POTATO = "It is in the nightshade family, you know.",
        QUAGMIRE_POTATO_COOKED = "The potato may be eaten now.",
        QUAGMIRE_POTATO_SEEDS = "Am I supposed to plant these?",

        QUAGMIRE_TOMATO = "It's a red, red tomato.",
        QUAGMIRE_TOMATO_COOKED = "It's a red, red roasted tomato.",
        QUAGMIRE_TOMATO_SEEDS = "Am I supposed to plant these?",

        QUAGMIRE_FLOUR = "I suppose one could make baked goods with this.",
        QUAGMIRE_WHEAT = "This would be more useful as flour.",
        QUAGMIRE_WHEAT_SEEDS = "Am I supposed to plant these?",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Am I supposed to plant these?",

        QUAGMIRE_ROTTEN_CROP = "Foul.",

		QUAGMIRE_SALMON = "Foul smelling, but delicious.",
		QUAGMIRE_SALMON_COOKED = "I do enjoy a good smoked salmon.",
		QUAGMIRE_CRABMEAT = "Ah, how refined.",
		QUAGMIRE_CRABMEAT_COOKED = "Perfect with a bit of butter.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "A sickly sweet aroma wafts from its branches.",
			STUMP = "It won't produce sap now.",
			TAPPED_EMPTY = "It is filling. Ever so slowly.",
			TAPPED_READY = "The sap is ready for collection.",
			TAPPED_BUGS = "Well it's ruined now.",
			WOUNDED = "This tree has seen better days.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "Aromatic.",
			PICKED = "That's not growing back anytime soon.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "That will spice things up.",
		QUAGMIRE_SPOTSPICE_GROUND = "Spicy.",
		QUAGMIRE_SAPBUCKET = "It's already sticky.",
		QUAGMIRE_SAP = "I would rather not get that on my gloves.",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Ah. It's ready.",
			GENERIC = "Any method to improve the food around here is welcome.",
		},

		QUAGMIRE_POND_SALT = "Brackish.",
		QUAGMIRE_SALT_RACK_ITEM = "Just useless sticks until we assemble it.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "Now for some expert-level rummaging.",
			LOCKED = "I cannot open it.",
		},

		QUAGMIRE_KEY = "And they thought their things were safe.",
		QUAGMIRE_KEY_PARK = "This should open some doors.",
        QUAGMIRE_PORTAL_KEY = "Good. I can get out of here.",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "I could, perhaps, produce a makeshift garnish.",
			PICKED = "It's as hollow as this withered world.",
		},
		QUAGMIRE_MUSHROOMS = "Fungus has its uses.",
        QUAGMIRE_MEALINGSTONE = "This looks like it requires hard labor.",
		QUAGMIRE_PEBBLECRAB = "You can't hide from me.",


		QUAGMIRE_RUBBLE_CARRIAGE = "Carriage carnage.",
        QUAGMIRE_RUBBLE_CLOCK = "Time's up.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "They didn't pray hard enough.",
        QUAGMIRE_RUBBLE_PUBDOOR = "If only it lead somewhere.",
        QUAGMIRE_RUBBLE_ROOF = "It's no longer over anyone's head.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "A late clocktower.",
        QUAGMIRE_RUBBLE_BIKE = "A bicycle built askew.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "No one's living there anymore.",
            "Such destruction.",
            "Nothing like the decline of a civilization.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Something has happened here.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Nobody has kept up with repairs.",
        QUAGMIRE_MERMHOUSE = "The stinking abode of those filthy fish creatures.",
        QUAGMIRE_SWAMPIG_HOUSE = "It could use renovations.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "It's been a long time since this stood properly.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Charmed, I'm sure.",
            SLEEPING = "Fast asleep.",
        },
        QUAGMIRE_SWAMPIG = "Don't touch the suit.",

        QUAGMIRE_PORTAL = "Nobody listens to me.",
        QUAGMIRE_SALTROCK = "It must be ground down before we use it.",
        QUAGMIRE_SALT = "Adding too much is an a-salt on the senses.",
        --food--
        QUAGMIRE_FOOD_BURNT = "I didn't cook that one.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Let's see how the wyrm likes this.",
            MISMATCH = "Nope. It won't eat that.",
            MATCH = "This is exactly what the wyrm wants.",
            MATCH_BUT_SNACK = "Well, I suppose it will tide the wyrm over.",
        },

        QUAGMIRE_FERN = "Perhaps it has some flavor to it.",
        QUAGMIRE_FOLIAGE_COOKED = "I ought to mix it in with something else.",
        QUAGMIRE_COIN1 = "Well, well, well...",
        QUAGMIRE_COIN2 = "I'll have use for this.",
        QUAGMIRE_COIN3 = "On my way up in the world.",
        QUAGMIRE_COIN4 = "We may wyrm our way out of this predicament yet.",
        QUAGMIRE_GOATMILK = "My bones are naturally fragile, I'm afraid.",
        QUAGMIRE_SYRUP = "Cooking syrup. Of course.",
        QUAGMIRE_SAP_SPOILED = "Bittersweet.",
        QUAGMIRE_SEEDPACKET = "Instruments of toil.",

        QUAGMIRE_POT = "Magic could bring it to a boil faster, you know.",
        QUAGMIRE_POT_SMALL = "I shalln't let it speak with the kettle.",
        QUAGMIRE_POT_SYRUP = "I need to sweeten the pot.",
        QUAGMIRE_POT_HANGER = "I can put this to good use.",
        QUAGMIRE_POT_HANGER_ITEM = "Well I'M not setting it up.",
        QUAGMIRE_GRILL = "I believe I can barbeque.",
        QUAGMIRE_GRILL_ITEM = "No use to me here.",
        QUAGMIRE_GRILL_SMALL = "I'd prefer a larger grill.",
        QUAGMIRE_GRILL_SMALL_ITEM = "At least it's portable.",
        QUAGMIRE_OVEN = "This makes things much more convenient.",
        QUAGMIRE_OVEN_ITEM = "It's an oven. For cooking.",
        QUAGMIRE_CASSEROLEDISH = "Homey.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "A tiny bit of domestication.",
        QUAGMIRE_PLATE_SILVER = "Suitable lavishness.",
        QUAGMIRE_BOWL_SILVER = "Refined dishware.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Let's see what they have today.", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Well what do we have here?", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Some kind of gargoyle.",
        QUAGMIRE_PARK_ANGEL2 = "Well that's attractive.",
        QUAGMIRE_PARK_URN = "Yes yes, ashes to ashes and all that.",
        QUAGMIRE_PARK_OBELISK = "It's a monument to death.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Seems we've got it open.",
            LOCKED = "It needs a key.",
        },
        QUAGMIRE_PARKSPIKE = "Spikey. Like me.",
        QUAGMIRE_CRABTRAP = "Dinner should be arriving any moment.",
        QUAGMIRE_TRADER_MERM = "Good day to you, sir.",
        QUAGMIRE_TRADER_MERM2 = "I tip my hat to you sir.",

        QUAGMIRE_GOATMUM = "May I peruse your wares, ma'am?",
        QUAGMIRE_GOATKID = "He has no future ahead of him. A shame.",
        QUAGMIRE_PIGEON =
        {
            DEAD = "It is no more.",
            GENERIC = "How are birds getting in here?",
            SLEEPING = "Fast asleep.",
        },
        QUAGMIRE_LAMP_POST = "A touch of civility.",

        QUAGMIRE_BEEFALO = "It's seen better days.",
        QUAGMIRE_SLAUGHTERTOOL = "I don't mind getting my hands dirty with this.",

        QUAGMIRE_SAPLING = "I don't have time to watch twigs grow.",
        QUAGMIRE_BERRYBUSH = "Those are never growing back.",

        QUAGMIRE_ALTAR_STATUE2 = "Misdirected dedication.",
        QUAGMIRE_ALTAR_QUEEN = "A bit excessive...",
        QUAGMIRE_ALTAR_BOLLARD = "It's a post.",
        QUAGMIRE_ALTAR_IVY = "Creeping ivy.",

        QUAGMIRE_LAMP_SHORT = "A little civility.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "I could have thought of that.",
        	OFF = "It's useless out here without power.",
        	BURNING = "I'm going to pretend I don't see it.",
        	BURNT = "Oh. What a pity.",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "Well sure, if you want to take the easy way out.",
        	OFF = "It's useless out here without power.",
        	BURNING = "I'm going to pretend I don't see it.",
        	BURNT = "Oh. What a pity.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "Where does she find the time to build all this.",
        	LOWPOWER = "I think it's losing power.",
        	OFF = "See? It wasn't so great after all.",
        	BURNING = "I'm going to pretend I don't see it.",
        	BURNT = "Oh. What a pity.",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "At least she has the sense to use gems.",
        	LOWPOWER = "I think it's losing power.",
        	OFF = "Magic isn't so easy, is it?",
        	BURNING = "I'm going to pretend I don't see it.",
        	BURNT = "Oh. What a pity.",
        },

        --Wormwood
        COMPOSTWRAP = "I'm utterly dung with all of this.",
        ARMOR_BRAMBLE = "Who's frail now?",
        TRAP_BRAMBLE = "Best laid traps.",

        BOATFRAGMENT03 = "Merely smithereens.",
        BOATFRAGMENT04 = "Merely smithereens.",
        BOATFRAGMENT05 = "Merely smithereens.",
		BOAT_LEAK = "Oh, great. Now we're going to drown.",
        MAST = "Every vessel mast have one.",
        SEASTACK = "It would be easy to wreck a vessel on one of those.",
        FISHINGNET = "Not my preferred way to ensnare enemies.", --unimplemented
        ANTCHOVIES = "What a miserable thing.", --unimplemented
        STEERINGWHEEL = "Why yes, you may call me the \"Captain\".",
        ANCHOR = "I can drop it to keep the boat in place.",
        BOATPATCH = "I detest such work.",
        DRIFTWOOD_TREE =
        {
            BURNING = "It seems to be burning.",
            BURNT = "It's in utter ruin.",
            CHOPPED = "We've chopped it up already.",
            GENERIC = "It appears to be a piece of drifted wood.",
        },

        DRIFTWOOD_LOG = "Oh good. More wood.",

        MOON_TREE =
        {
            BURNING = "It's burning.",
            BURNT = "A burnt tree stump.",
            CHOPPED = "Someone's chopped it down already.",
            GENERIC = "It's a moon tree.",
        },
		MOON_TREE_BLOSSOM = "It came from that odd tree.",

        MOONBUTTERFLY =
        {
        	GENERIC = "How wretchedly graceful.",
        	HELD = "You can't escape my villainous grasp!",
        },
		MOONBUTTERFLYWINGS = "What am I supposed to do with these?",
        MOONBUTTERFLY_SAPLING = "It's a small moon tree.",
        ROCK_AVOCADO_FRUIT = "I'd rather not shatter my teeth on that.",
        ROCK_AVOCADO_FRUIT_RIPE = "It's ripe enough to eat now.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "It looks almost appetizing.",
        ROCK_AVOCADO_FRUIT_SPROUT = "How off-putting. It's grown a sprout.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "It is fruitless and useless now.",
			WITHERED = "It resembles Woodie, does it not?",
			GENERIC = "It labors to make my dinner.",
			PICKED = "What use are you to me if you don't have fruit?",
			DISEASED = "It's ill.", --unimplemented
            DISEASING = "I think it's sick or something.", --unimplemented
			BURNING = "Well that's a shame.",
		},
        DEAD_SEA_BONES = "Adapt or perish.",
        HOTSPRING =
        {
        	GENERIC = "I miss a good long bath.",
        	BOMBED = "How posh.",
        	GLASS = "I could make use of that glass.",
			EMPTY = "It's of no use to me like this.",
        },
        MOONGLASS = "But does it look as sharp as me?",
        MOONGLASS_CHARGED = "Nearly as sharp as I am, but with a garish glow.",
        MOONGLASS_ROCK = "\"Moon\" detritus.",
        BATHBOMB = "It smells quite nice, if I'm honest.",
        TRAP_STARFISH =
        {
            GENERIC = "It's just a silly starfish.",
            CLOSED = "Devious thing.",
        },
        DUG_TRAP_STARFISH = "What would be the most devilish place to put it?",
        SPIDER_MOON =
        {
        	GENERIC = "How monstrous.",
        	SLEEPING = "I'd rather not wake it.",
        	DEAD = "Good riddance.",
        },
        MOONSPIDERDEN = "I'd rather not peek inside.",
		FRUITDRAGON =
		{
			GENERIC = "They aren't very sociable.",
			RIPE = "I bet it's delicious.",
			SLEEPING = "Sleep is only a temporary escape.",
		},
        PUFFIN =
        {
            GENERIC = "It's a puffin.",
            HELD = "I'm gonna turn you into puffin' stuff.",
            SLEEPING = "Sleep is only a temporary escape.",
        },

		MOONGLASSAXE = "Go on. Axe me what the moon's made of.",
		GLASSCUTTER = "Sharp like my wit.",

        ICEBERG =
        {
            GENERIC = "Ice, ice, maybe.", --unimplemented
            MELTED = "It's melted.", --unimplemented
        },
        ICEBERG_MELTED = "It's melted.", --unimplemented

        MINIFLARE = "For those with a flare for the dramatic.",

		MOON_FISSURE =
		{
			GENERIC = "It's not shadow magic.",
			NOLIGHT = "I've more important things to deal with than holes in the ground.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "There is powerful energy pouring out of it.",
            GENERIC = "Yes. I desire the knowledge of the moon.",
        },

        MOON_ALTAR_IDOL = "Let me know your wishes, and I will oblige.",
        MOON_ALTAR_GLASS = "This is not its desired destination.",
        MOON_ALTAR_SEED = "Where shall I take you?",

        MOON_ALTAR_ROCK_IDOL = "The thing inside wants out.",
        MOON_ALTAR_ROCK_GLASS = "The thing inside wants out.",
        MOON_ALTAR_ROCK_SEED = "The thing inside wants out.",

        MOON_ALTAR_CROWN = "This powerful energy... I've seen it before.",
        MOON_ALTAR_COSMIC = "It is not yet time?",

        MOON_ALTAR_ASTRAL = "Why do I get the sense... ah, I'm sure it's nothing.",
        MOON_ALTAR_ICON = "I know where you need to be.",
        MOON_ALTAR_WARD = "I'll take you to the others.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Now to see if Higgsbury's ideas hold water.",
            BURNT = "Well, it's useless now.",
        },
        BOAT_ITEM = "I've been reduced to a common shipyard laborer.",
        STEERINGWHEEL_ITEM = "Hard labor? Isn't that Winona's forte?",
        ANCHOR_ITEM = "Can't someone else assemble it?",
        MAST_ITEM = "Do I look like a shipyard laborer?",
        MUTATEDHOUND =
        {
        	DEAD = "That is probably for the best.",
        	GENERIC = "If anything ever looked evil, it's that.",
        	SLEEPING = "I don't desire to rouse it.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Good riddance.",
			GENERIC = "What an atrocious beast.",
			SLEEPING = "May you never wake.",
		},
        CARRAT =
        {
        	DEAD = "Disgusting.",
        	GENERIC = "That carrot is revolting!",
        	HELD = "You thought you could fool me?",
        	SLEEPING = "I'm sure it is diseased.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Disgusting. I'll have someone else pick it.",
            PICKED = "We already took the food parts.",
        },
		BULLKELP_ROOT = "For keeping the peasantry in line.",
        KELPHAT = "You really expect me to wear this?",
		KELP = "Can I eat something that's not slimy for once?",
		KELP_COOKED = "This was not an improvement.",
		KELP_DRIED = "Sadly, I've eaten worse out here.",

		GESTALT = "It communes with us through them.",
        GESTALT_GUARD = "I think it would be best to keep my distance.",

		COOKIECUTTER = "Stay back, you!",
		COOKIECUTTERSHELL = "Hmph. I suppose this could be useful.",
		COOKIECUTTERHAT = "This doesn't look dapper at all.",
		SALTSTACK =
		{
			GENERIC = "Odd...",
			MINED_OUT = "It's been mined down to nothing.",
			GROWING = "It seems to be growing back...",
		},
		SALTROCK = "Am I to be a salt miner now?",
		SALTBOX = "This will extend the life of our supplies somewhat.",

		TACKLESTATION = "I suppose I could use a relaxing day of fishing.",
		TACKLESKETCH = "What forbidden fishing knowledge do you hold?",

        MALBATROSS = "I've no desire to do battle with that thing.",
        MALBATROSS_FEATHER = "This would be a nice feather in my cap.",
        MALBATROSS_BEAK = "Ugh, I don't want to touch that.",
        MAST_MALBATROSS_ITEM = "Must I do everything?",
        MAST_MALBATROSS = "A warning to any waterfowl that cross us.",
		MALBATROSS_FEATHERED_WEAVE = "Hopefully it catches the wind as well as the eye.",

        GNARWAIL =
        {
            GENERIC = "Perhaps it could be reasoned with.",
            BROKENHORN = "It seems you've lost something, pal.",
            FOLLOWER = "We've come to an agreement.",
            BROKENHORN_FOLLOWER = "Shame about your horn, pal.",
        },
        GNARWAIL_HORN = "Impressive.",

        WALKINGPLANK = "Jumping off would ruin what's left of my suit.",
        OAR = "I have no desire to toil like a common sailor.",
		OAR_DRIFTWOOD = "Hmph. I've never been one for manual lab-oar.",

		OCEANFISHINGROD = "A more in-depth approach to fishing.",
		OCEANFISHINGBOBBER_NONE = "It seems to be missing something.",
        OCEANFISHINGBOBBER_BALL = "How quaint.",
        OCEANFISHINGBOBBER_OVAL = "It's made of tougher stuff.",
		OCEANFISHINGBOBBER_CROW = "I used to see quill floats like this back in England.",
		OCEANFISHINGBOBBER_ROBIN = "I used to see quill floats like this back in England.",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "I used to see quill floats like this back in England.",
		OCEANFISHINGBOBBER_CANARY = "I used to see quill floats like this back in England.",
		OCEANFISHINGBOBBER_GOOSE = "A bit of extra flair goes a long way.",
		OCEANFISHINGBOBBER_MALBATROSS = "A bit of extra flair goes a long way.",

		OCEANFISHINGLURE_SPINNER_RED = "At least I don't have to use worms.",
		OCEANFISHINGLURE_SPINNER_GREEN = "At least I don't have to use worms.",
		OCEANFISHINGLURE_SPINNER_BLUE = "At least I don't have to use worms.",
		OCEANFISHINGLURE_SPOON_RED = "At least I don't have to use worms.",
		OCEANFISHINGLURE_SPOON_GREEN = "At least I don't have to use worms.",
		OCEANFISHINGLURE_SPOON_BLUE = "At least I don't have to use worms.",
		OCEANFISHINGLURE_HERMIT_RAIN = "Go fishing in the rain? And ruin my last good suit?",
		OCEANFISHINGLURE_HERMIT_SNOW = "Why would anyone want to fish while it's snowing?",
		OCEANFISHINGLURE_HERMIT_DROWSY = "I think Higgsbury already got too close to one of these.",
		OCEANFISHINGLURE_HERMIT_HEAVY = "I'm reluctant to see what manner of fish would bite THAT.",

		OCEANFISH_SMALL_1 = "This was barely worth my time.",
		OCEANFISH_SMALL_2 = "Hardly bigger than a minnow.",
		OCEANFISH_SMALL_3 = "I was hoping for something bigger.",
		OCEANFISH_SMALL_4 = "Just a cold fish.",
		OCEANFISH_SMALL_5 = "Its smell oddly reminds me of the theater house...",
		OCEANFISH_SMALL_6 = "What an ugly thing.",
		OCEANFISH_SMALL_7 = "It seems more plant than fish.",
		OCEANFISH_SMALL_8 = "The sunfish! It burns!",
        OCEANFISH_SMALL_9 = "How vulgar.",

		OCEANFISH_MEDIUM_1 = "It looks positively revolting.",
		OCEANFISH_MEDIUM_2 = "It has a rather unsettling stare.",
		OCEANFISH_MEDIUM_3 = "I'd best take care to avoid those spines.",
		OCEANFISH_MEDIUM_4 = "I'm not sure it was worth the effort.",
		OCEANFISH_MEDIUM_5 = "What an odd creature.",
		OCEANFISH_MEDIUM_6 = "Don't be koi with me.",
		OCEANFISH_MEDIUM_7 = "Don't be koi with me.",
		OCEANFISH_MEDIUM_8 = "Stay frosty, pal.",
        OCEANFISH_MEDIUM_9 = "It seems we share an appreciation for figs.",

		PONDFISH = "Fresh from the murky depths.",
		PONDEEL = "It slithers all the way down.",

        FISHMEAT = "Ugh, it's still twitching.",
        FISHMEAT_COOKED = "Bland... but acceptable.",
        FISHMEAT_SMALL = "I'm reduced to scavenging scraps.",
        FISHMEAT_SMALL_COOKED = "That was barely an appetizer.",
		SPOILED_FISH = "How vile.",

		FISH_BOX = "Ugh, the smell... the things I do for a decent meal.",
        POCKET_SCALE = "I keep it next to my pocket watch and my pocket comb.",

		TACKLECONTAINER = "Can I really even call it a \"box\"?",
		SUPERTACKLECONTAINER = "Not the most refined design, but it's functional.",

		TROPHYSCALE_FISH =
		{
			GENERIC = "Perhaps I might reign again... as the king of fishing!",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nEnjoy your moment while it lasts...",
			BURNING = "No! NOO!",
			BURNT = "All my ambitions go up in smoke.",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nBow down before your fishing master!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nImpressive, isn't it?",
		},

		OCEANFISHABLEFLOTSAM = "Disappointing.",

		CALIFORNIAROLL = "I don't think I truly appreciated those sunny shores.",
		SEAFOODGUMBO = "It looks passable.",
		SURFNTURF = "A very balanced meal, I suppose.",

        WOBSTER_SHELLER = "I'd prefer it without the sharp, pinching claws.",
        WOBSTER_DEN = "What manner of creature lives in there?",
        WOBSTER_SHELLER_DEAD = "Excellent.",
        WOBSTER_SHELLER_DEAD_COOKED = "I forgot my bib.",

        LOBSTERBISQUE = "Ah, I do enjoy the finer things.",
        LOBSTERDINNER = "Finally, something to suit my refined palate.",

        WOBSTER_MOONGLASS = "They didn't look like that when I was in charge.",
        MOONGLASS_WOBSTER_DEN = "I suppose life finds a way.",

		TRIDENT = "It seems to have struck a chord.",

		WINCH =
		{
			GENERIC = "We are to start dredging up what lies beneath now, are we?",
			RETRIEVING_ITEM = "It seems I've gotten a hold of something.",
			HOLDING_ITEM = "Interesting.",
		},

        HERMITHOUSE = {
            GENERIC = "What a sad little hovel.",
            BUILTUP = "It's an improvement.",
        },

        SHELL_CLUSTER = "That was not worth the effort.",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "Hm?",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "No, go on, keep playing that same note. It's not irritating at all.",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "I've quite lost my taste for music.",
        },

        CHUM = "Say, that chum doesn't look so good.",

        SUNKENCHEST =
        {
            GENERIC = "How whimsical.",
            LOCKED = "How annoying. It's locked.",
        },

        HERMIT_BUNDLE = "How... quaint.",
        HERMIT_BUNDLE_SHELLS = "Nautical decor was never my style.",

        RESKIN_TOOL = "Presto change-o! Ahem... old habit.",
        MOON_FISSURE_PLUGGED = "It's almost genius in its simplicity... but it does smell.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "I'd rather not get hair all over my suit.",
            "I'd rather not get hair all over my suit.",
        },
        WOBYSMALL =
        {
            "She slobbers...",
            "She slobbers...",
        },
		WALTERHAT = "It's not quite my style.",
		SLINGSHOT = "A rather childish weapon, but quite effective in the right hands.",
		SLINGSHOTAMMO_ROCK = "Not particularly creative.",
		SLINGSHOTAMMO_MARBLE = "Not particularly creative.",
		SLINGSHOTAMMO_THULECITE = "Ah, now that might be interesting.",
        SLINGSHOTAMMO_GOLD = "Ah, now that might be interesting.",
        SLINGSHOTAMMO_SLOW = "Ah, now that might be interesting.",
        SLINGSHOTAMMO_FREEZE = "Ah, now that might be interesting.",
		SLINGSHOTAMMO_POOP = "Must he leave that lying around? I nearly ruined my shoes.",
        PORTABLETENT = "Oh, how I miss sleeping indoors.",
        PORTABLETENT_ITEM = "Surely someone else can set it up.",

        -- Wigfrid
        BATTLESONG_DURABILITY = "No. I do NOT sing.",
        BATTLESONG_HEALTHGAIN = "No. I do NOT sing.",
        BATTLESONG_SANITYGAIN = "No. I do NOT sing.",
        BATTLESONG_SANITYAURA = "No. I do NOT sing.",
        BATTLESONG_FIRERESISTANCE = "No. I do NOT sing.",
        BATTLESONG_INSTANT_TAUNT = "My acts were always a bit more improvisational.",
        BATTLESONG_INSTANT_PANIC = "My acts were always a bit more improvisational.",

        -- Webber
        MUTATOR_WARRIOR = "I'm not eating that.",
        MUTATOR_DROPPER = "How sickeningly endearing.",
        MUTATOR_HIDER = "I'm not eating that.",
        MUTATOR_SPITTER = "How sickeningly endearing.",
        MUTATOR_MOON = "I'm not eating that.",
        MUTATOR_HEALER = "How sickeningly endearing.",
        SPIDER_WHISTLE = "It's probably covered in spider spit.",
        SPIDERDEN_BEDAZZLER = "Careful child, it's a slippery slope towards a career in the arts.",
        SPIDER_HEALER = "I don't think that's one of mine.",
        SPIDER_REPELLENT = "If only loud noises were really enough to deter them.",
        SPIDER_HEALER_ITEM = "Just in case I lose my mind entirely and want to heal those little pests.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "It appears someone has been toying with the dark arts and crafts.",
		GHOSTLYELIXIR_FASTREGEN = "It appears someone has been toying with the dark arts and crafts.",
		GHOSTLYELIXIR_SHIELD = "It appears someone has been toying with the dark arts and crafts.",
		GHOSTLYELIXIR_ATTACK = "It appears someone has been toying with the dark arts and crafts.",
		GHOSTLYELIXIR_SPEED = "It appears someone has been toying with the dark arts and crafts.",
		GHOSTLYELIXIR_RETALIATION = "It appears someone has been toying with the dark arts and crafts.",
		SISTURN =
		{
			GENERIC = "I can't help but wonder... no, it couldn't be.",
			SOME_FLOWERS = "Perhaps I should pay my respects as well.",
			LOTS_OF_FLOWERS = "It has a strangely calming effect.",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "An instrument of the dark culinary arts.",
            DONE = "Let's hope something palatable has come of it.",

			COOKING_LONG = "I must exercise patience...",
			COOKING_SHORT = "It will be finished shortly.",
			EMPTY = "Dismally devoid of foodstuffs.",
        },

        PORTABLEBLENDER_ITEM = "Does it have to make such a horrible racket?",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Ah. The daily grind.",
            DONE = "Finally something with some taste.",
        },
        SPICEPACK = "I've been reduced to hauling my own foodstuffs.",
        SPICE_GARLIC = "Keeps everyone from getting too close.",
        SPICE_SUGAR = "I never was one for syrupy mush.",
        SPICE_CHILI = "Bit of a kick in the pants.",
        SPICE_SALT = "My doctor said I shouldn't have too much.",
        MONSTERTARTARE = "It's less than appetizing.",
        FRESHFRUITCREPES = "Deserves to be eaten with fine silverware. Sadly, I've just my hands.",
        FROGFISHBOWL = "At the end of the day, it's still frog.",
        POTATOTORNADO = "What an odd way to serve potatoes.",
        DRAGONCHILISALAD = "I'll permit him to stay so long as he keeps cooking.",
        GLOWBERRYMOUSSE = "What a nice change it is to know someone who cooks.",
        VOLTGOATJELLY = "Just because I'm old doesn't mean I like gelatin.",
        NIGHTMAREPIE = "I'm going to have dreams about this pie nightmare.",
        BONESOUP = "It's hearty and filling.",
        MASHEDPOTATOES = "I do love mashed potatoes.",
        POTATOSOUFFLE = "It's so delicate.",
        MOQUECA = "I've never had it before.",
        GAZPACHO = "It smells much nicer going in than coming back out.",
        ASPARAGUSSOUP = "I suppose you can make soup from anything.",
        VEGSTINGER = "I do enjoy a drink.",
        BANANAPOP = "Hm... I don't know what I was expecting.",
        CEVICHE = "A delightful, cultured dish.",
        SALSA = "A bit spicy for my delicate palate.",
        PEPPERPOPPER = "Pops right into my mouth!",

        TURNIP = "It's a big, bulbous turnip.",
        TURNIP_COOKED = "Hardly improves the taste.",
        TURNIP_SEEDS = "Am I supposed to plant these?",

        GARLIC = "I suppose that's why there are no vampires around.",
        GARLIC_COOKED = "I wonder if it still wards away the undead.",
        GARLIC_SEEDS = "Am I supposed to plant these?",

        ONION = "It's a pungent onion.",
        ONION_COOKED = "Take that, onion.",
        ONION_SEEDS = "Am I supposed to plant these?",

        POTATO = "It is in the nightshade family, you know.",
        POTATO_COOKED = "The potato may be eaten now.",
        POTATO_SEEDS = "Am I supposed to plant these?",

        TOMATO = "It's a red, red tomato.",
        TOMATO_COOKED = "It's a red, red roasted tomato.",
        TOMATO_SEEDS = "Am I supposed to plant these?",

        ASPARAGUS = "We must always eat our vegetables.",
        ASPARAGUS_COOKED = "Smells terrible.",
        ASPARAGUS_SEEDS = "Such labor is beneath me.",

        PEPPER = "Looks like the spicy kind.",
        PEPPER_COOKED = "Slightly more exciting than the usual vegetable.",
        PEPPER_SEEDS = "Am I supposed to plant these?",

        WEREITEM_BEAVER = "It seems he's learning to bend the curse to his will.",
        WEREITEM_GOOSE = "Ugh, it offends my eyes.",
        WEREITEM_MOOSE = "Almost as powerful as it is tacky.",

        MERMHAT = "This seems rather... fishy.",
        MERMTHRONE =
        {
            GENERIC = "Not especially impressive for a \"throne\".",
            BURNT = "Someone finally took care of that hideous throw rug.",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "What is that little creature up to?",
            BURNT = "Such a waste of time and energy.",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "It's slightly less offensive to my eyes than the others.",
            BURNT = "It's been burned to the ground.",
        },

        MERMWATCHTOWER_REGULAR = "They're flying the royal banner.",
        MERMWATCHTOWER_NOKING = "A kingdom without a king.",
        MERMKING = "A crown can be a heavy burden...",
        MERMGUARD = "I'd best try to stay on their good side.",
        MERM_PRINCE = "Kings are easily made around here.",

        SQUID = "I hope they stay close. But not too close.",

		GHOSTFLOWER = "I hope they found peace.",
        SMALLGHOST = "I'm so sorry.",

        CRABKING =
        {
            GENERIC = "Say, pal, why don't we try to work this out?",
            INERT = "I suppose we can't just leave well enough alone, can we?",
        },
		CRABKING_CLAW = "Best to avoid that.",

		MESSAGEBOTTLE = "Someone sensibly bottled up their feelings and tossed them out to sea.",
		MESSAGEBOTTLEEMPTY = "It's empty inside.",

        MEATRACK_HERMIT =
        {
            DONE = "Does she even have teeth?",
            DRYING = "Still moist.",
            DRYINGINRAIN = "Moist and staying that way.",
            GENERIC = "Perhaps if she were fed, she'd be less ill-tempered.",
            BURNT = "It's too brittle to hang meat on now.",
            DONE_NOTMEAT = "Like the desert.",
            DRYING_NOTMEAT = "Still moist.",
            DRYINGINRAIN_NOTMEAT = "Moist and staying that way.",
        },
        BEEBOX_HERMIT =
        {
            READY = "I've done enough, the old woman can brave the bees herself.",
            FULLHONEY = "I've done enough, the old woman can brave the bees herself.",
            GENERIC = "I think she made this herself.",
            NOHONEY = "Why do the bees not serve me?",
            SOMEHONEY = "I should wait a bit longer.",
            BURNT = "Honey roasted.",
        },

        HERMITCRAB = "I have better things to do than being berated by an old crab.",

        HERMIT_PEARL = "It's... strange to be so trusted.",
        HERMIT_CRACKED_PEARL = "Ah. I thought I'd run out of people to disappoint.",

        -- DSEAS
        WATERPLANT = "I'm sure its delicate appearance is just a ruse for us to let our guard down.",
        WATERPLANT_BOMB = "I was right.",
        WATERPLANT_BABY = "I should pluck you like the weed you are.",
        WATERPLANT_PLANTER = "Why would I want these to spread?",

        SHARK = "What a nasty creature. I wish I'd thought of it.",

        MASTUPGRADE_LAMP_ITEM = "Far more practical than setting a fire on our boat.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "Very prudent.",

        WATERPUMP = "Higgsbury, I think a bucket would have sufficed...",

        BARNACLE = "I wish they were oysters.",
        BARNACLE_COOKED = "It's an acquired taste.",

        BARNACLEPITA = "I suppose I'll eat it if there's nothing else.",
        BARNACLESUSHI = "At least it's an attempt at sophistication.",
        BARNACLINGUINE = "It's surprisingly delicious.",
        BARNACLESTUFFEDFISHHEAD = "I suppose anything is \"food\" now.",

        LEAFLOAF = "Exceptionally mediocre.",
        LEAFYMEATBURGER = "How pedestrian.",
        LEAFYMEATSOUFFLE = "I appreciate the attempt at presentation.",
        MEATYSALAD = "This seems suspect.",

        -- GROTTO

		MOLEBAT = "Indecent.",
        MOLEBATHILL = "Do I even want anything I find in there, knowing its spent time in a rodent's nostrils?",

        BATNOSE = "It smells.",
        BATNOSE_COOKED = "The things I must do to survive...",
        BATNOSEHAT = "Do I have no dignity left?",

        MUSHGNOME = "I don't trust anyone who walks so jauntily.",

        SPORE_MOON = "It reminds me of those infernal balloons.",

        MOON_CAP = "Strange, my eyelids are getting heavy just looking at it.",
        MOON_CAP_COOKED = "Odd, but not unpleasant.",

        MUSHTREE_MOON = "How garish.",

        LIGHTFLIER = "Finally, a mutation that's actually useful.",

        GROTTO_POOL_BIG = "Don't expect me to wade in there for some wretched moon glass.",
        GROTTO_POOL_SMALL = "I suppose it is quite picturesque.",

        DUSTMOTH = "Hmph. Just stay away from my suit, pal.",

        DUSTMOTHDEN = "So this is the source of the Thulecite... I must say, I'm underwhelmed.",

        ARCHIVE_LOCKBOX = "Impossible... I thought I was privy to all of Their secrets.",
        ARCHIVE_CENTIPEDE = "I get the sensation that we are not welcome here.",
        ARCHIVE_CENTIPEDE_HUSK = "A pile of worthless parts.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "Wait for it...",
            COOKING_SHORT = "Here it comes!",
            DONE = "Finally, some quality grub.",
            EMPTY = "They didn't always live off of the fuel.",
            BURNT = "A bit overdone for my tastes.",
        },

        ARCHIVE_MOON_STATUE = "How did I not know of this place? Did They know?",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "These runes are... different.",
            LINE_2 = "I can only glean a hint of their meaning.",
            LINE_3 = "This symbol here keeps repeating...",
            LINE_4 = "\"To change?\" No. It's a name...",
            LINE_5 = "\"Alter\"?",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "It's leading us to something...",
            IDLE = "It fulfilled its purpose.",
        },

        ARCHIVE_RESONATOR_ITEM = "I have many questions.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "I always wondered where those parts came from.",
          GENERIC =  "Ah. I suppose I misinterpreted the original design.",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "It's powerless.",
            GENERIC = "Hm. I have a bad feeling...",
        },

        ARCHIVE_SECURITY_PULSE = "Don't let it escape!",

        ARCHIVE_SWITCH = {
            VALID = "It saps power from the gems.",
            GEMS = "I suppose I'll need to find a suitable gem.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "It couldn't be...",
            GENERIC = "Still inactive. Curious.",
        },

        WALL_STONE_2 = "This will keep the riff-raff out.",
        WALL_RUINS_2 = "An ancient wall.",

        REFINED_DUST = "It may have some alchemical uses.",
        DUSTMERINGUE = "I'll pass.",

        SHROOMCAKE = "I suppose I've eaten worse.",

        NIGHTMAREGROWTH = "Charlie... what are you planning?",

        TURFCRAFTINGSTATION = "I despise getting my hands dirty.",

        MOON_ALTAR_LINK = "Events have been set into motion...",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Disgusting.",
            WET = "It's nothing but foul wet slop.",
            DRY = "Positively arid.",
            BALANCED = "This should suffice.",
            BURNT = "It smells about as bad as you'd imagine.",
        },
        COMPOST = "I'd rather not get my hands dirty.",
        SOIL_AMENDER =
		{
			GENERIC = "It looks more like a science experiment than a fertilizer.",
			STALE = "Wonderful, it's putrefying.",
			SPOILED = "Ugh, the smell... can we just put it in the ground already?",
		},

		SOIL_AMENDER_FERMENTED = "It's reached the peak of its power... and its stench.",

        WATERINGCAN =
        {
            GENERIC = "Surely someone else can do these menial tasks?",
            EMPTY = "So I'm to traipse around looking for water, then?",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "I really don't care for gardening.",
            EMPTY = "Surely there must be some water nearby.",
        },

		FARM_PLOW = "Thankfully it seems capable of doing the work itself.",
		FARM_PLOW_ITEM = "Some kind of farming implement? I've no interest in such things.",
		FARM_HOE = "Am I to be reduced to a common farmhand?",
		GOLDEN_FARM_HOE = "A bit extravagant, don't you think?",
		NUTRIENTSGOGGLESHAT = "I suppose the Ancients were farmers once, before they turned to the fuel.",
		PLANTREGISTRYHAT = "I'm really supposed to put that contraption on my head?",

        FARM_SOIL_DEBRIS = "The blasted things spring up again just as fast as I can remove them.",

		FIRENETTLES = "Blasted nettles!",
		FORGETMELOTS = "Nothing but a common weed.",
		SWEETTEA = "I can't even remember the last time I had a decent cup of tea.",
		TILLWEED = "Nuisance.",
		TILLWEEDSALVE = "This will have to do.",
        WEED_IVY = "You have no place here.",
        IVY_SNARE = "I nearly got my suit caught on those thorns!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Do we not have infinitely more pressing things to do?",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nA moderately impressive display",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nI suppose it's an accomplishment.",
            HAS_ITEM_LIGHT = "The bar has been set low, I see.",
			BURNING = "...And now it's on fire.",
			BURNT = "Reduced to dust.",
        },

        CARROT_OVERSIZED = "A ludicrously oversized carrot.",
        CORN_OVERSIZED = "That's far too much corn for any reasonable person.",
        PUMPKIN_OVERSIZED = "How very spooky.",
        EGGPLANT_OVERSIZED = "An absurdly large eggplant.",
        DURIAN_OVERSIZED = "Far more than I'd like to have, quite honestly.",
        POMEGRANATE_OVERSIZED = "I'd imagine it would take quite a while to eat.",
        DRAGONFRUIT_OVERSIZED = "Utterly enormous.",
        WATERMELON_OVERSIZED = "Entirely too much watermelon.",
        TOMATO_OVERSIZED = "A preposterously sized tomato.",
        POTATO_OVERSIZED = "It has more starch than my best suit.",
        ASPARAGUS_OVERSIZED = "What am I supposed to do with all this asparagus?",
        ONION_OVERSIZED = "An unnecessarily large onion.",
        GARLIC_OVERSIZED = "An unreasonably enormous clump of garlic.",
        PEPPER_OVERSIZED = "It looks horribly spicy.",

        VEGGIE_OVERSIZED_ROTTEN = "It's no good to anyone now.",

		FARM_PLANT =
		{
			GENERIC = "Merely a plant.",
			SEED = "I'll have to be patient.",
			GROWING = "Nearly there.",
			FULL = "It's time to reap what I've sown.",
			ROTTEN = "Rotten.",
			FULL_OVERSIZED = "At last, my efforts are rewarded.",
			ROTTEN_OVERSIZED = "It's no good to anyone now.",
			FULL_WEED = "Not another blasted weed!",

			BURNING = "Not the garden!",
		},

        FRUITFLY = "Begone, pest!",
        LORDFRUITFLY = "Hmph, they let just anyone be a lord these days.",
        FRIENDLYFRUITFLY = "As long as it tends to the garden I'll leave it be.",
        FRUITFLYFRUIT = "So this is all it takes to lead.",

        SEEDPOUCH = "One more thing to lug from place to place.",

		-- Crow Carnival
		CARNIVAL_HOST = "Just look at him, strutting around like he owns the place.",
		CARNIVAL_CROWKID = "We're being overrun.",
		CARNIVAL_GAMETOKEN = "Fine. I'll play your silly little games.",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "A prize ticket. How exciting.",
			GENERIC_SMALLSTACK = "I don't know why I'm dedicating so much time to this.",
			GENERIC_LARGESTACK = "Oh good. Now I can get some useless trinket from the Prize Booth.",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "What are they hiding down there...",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "It requires payment.",
			PLAYING = "I'll play it, but I won't enjoy it.",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "I suppose I'm expected to set this up myself?",
		CARNIVALGAME_FEEDCHICKS_FOOD = "These props leave something to be desired.",

		CARNIVALGAME_MEMORY_KIT = "I suppose I'm expected to set this up myself?",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "It requires payment.",
			PLAYING = "A simple matter of memorization. I'll show you just how easy it is.",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "What are they hiding down there...",
			PLAYING = "I'm almost certain it was this one...",
		},

		CARNIVALGAME_HERDING_KIT = "I suppose I'm expected to set this up myself?",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "It requires payment.",
			PLAYING = "Such pointless frivolity...",
		},
		CARNIVALGAME_HERDING_CHICK = "Get back here, you blasted contraption!",

		CARNIVAL_PRIZEBOOTH_KIT = "Must I do everything around here?",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "I somehow doubt they'd have anything I want.",
		},

		CARNIVALCANNON_KIT = "Must I do everything around here?",
		CARNIVALCANNON =
		{
			GENERIC = "This place is turning into a circus.",
			COOLDOWN = "That's more than enough cheer for one day.",
		},

		CARNIVAL_PLAZA_KIT = "It's so... ugh... whimsical.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "It's about as festive as I like it. Which is not at all.",
			LEVEL_2 = "The birds seem to enjoy it. Some creatures just lack any taste.",
			LEVEL_3 = "I think that's about as much clutter as one could possibly throw on a tree.",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "There's no end to the work around here, it seems.",
		CARNIVALDECOR_EGGRIDE = "Wonderful. It's even tackier than I imagined it would be.",

		CARNIVALDECOR_LAMP_KIT = "There's no end to the work around here, it seems.",
		CARNIVALDECOR_LAMP = "A paltry light source. But it will do.",
		CARNIVALDECOR_PLANT_KIT = "There's no end to the work around here, it seems.",
		CARNIVALDECOR_PLANT = "At least it's small and somewhat manageable.",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "What exactly is so fantastic about it?",
			UNCOMMON = "Measly things. In my time I made proper statues...",
			GENERIC = "One more thing to clutter the ground.",
		},
		CARNIVALDECOR_FIGURE_KIT = "Curiosity always seems to get the better of me.",

        CARNIVAL_BALL = "How novel.", --unimplemented
		CARNIVAL_SEEDPACKET = "About as pleasant as you'd expect.",
		CARNIVALFOOD_CORNTEA = "Surely you're not serious?",

        CARNIVAL_VEST_A = "Far too jaunty for my taste.",
        CARNIVAL_VEST_B = "At least it will give me some respite from this wretched heat.",
        CARNIVAL_VEST_C = "It affords some protection from the sun's burning rays.",

        -- YOTB
        YOTB_SEWINGMACHINE = "I'm more of an appreciator of fine clothes than a maker of them.",
        YOTB_SEWINGMACHINE_ITEM = "Why must these things come unassembled?",
        YOTB_STAGE = "Hmph. What makes him think he's qualified to pass judgement?",
        YOTB_POST =  "Enjoy your time in the spotlight while you can.",
        YOTB_STAGE_ITEM = "Oh good, something more to build.",
        YOTB_POST_ITEM =  "This seems like a dreadful amount of effort.",


        YOTB_PATTERN_FRAGMENT_1 = "I'll have to combine them before they'll reveal their secrets.",
        YOTB_PATTERN_FRAGMENT_2 = "I'll have to combine them before they'll reveal their secrets.",
        YOTB_PATTERN_FRAGMENT_3 = "I'll have to combine them before they'll reveal their secrets.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "I've no need for such things. Perhaps one of the children might take it.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "I've no need for such things.",
            YOTB = "This might be of interest to the judge.",
        },

        WAR_BLUEPRINT = "This could be useful.",
        DOLL_BLUEPRINT = "I can only imagine how grotesque this will look...",
        FESTIVE_BLUEPRINT = "Positively garish.",
        ROBOT_BLUEPRINT = "Is this the robot's doing?",
        NATURE_BLUEPRINT = "Florals. How saccharine.",
        FORMAL_BLUEPRINT = "These garments are absolutely wasted on such base creatures.",
        VICTORIAN_BLUEPRINT = "Hmph. Rather outdated.",
        ICE_BLUEPRINT = "Chilling.",
        BEAST_BLUEPRINT = "I'd say luck is in rather short supply around here.",

        BEEF_BELL = "It appears to have some kind of hypnotic effect on beefalo.",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "A house for kitcoons? Can the pitiful little things not climb trees yet?",
            BURNT = "No place to hide anymore.",
			PLAYING_HIDEANDSEEK = "They are not here, they are out hiding.",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "We are nearly out of time to find all of the rascals.",
		},

		KITCOONDEN_KIT = "I don't see why I need to build them a house. They need to learn to climb trees like adults.",

		TICOON = 
		{
			GENERIC = "This high status catcoon has a talent for finding the kits. I respect him only marginally more.",
			ABANDONED = "I didn't need his help anyway.",
			SUCCESS = "Well done, great beast!",
			LOST_TRACK = "Blasted, we weren't fast enough! Sniff faster, beast!",
			NEARBY = "A-ha... there's a kitcoon afoot.",
			TRACKING = "He seems onto something. I shall let him take the lead.",
			TRACKING_NOT_MINE = "That ticoon is not working for me. Yet.",
			NOTHING_TO_TRACK = "There's nothing left to find.",
			TARGET_TOO_FAR_AWAY = "His nose may be good, but I doubt it's good enough to track that far.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "I suppose even a thief has its admirers.",
            EMPTY = "It seems we're supposed to offer it something.",
            BURNT = "Seems not everyone appreciates the little thieves.",
        },

		KITCOON_FOREST = "What a pathetic little creature. It's encumbered by excess fur.",
		KITCOON_SAVANNA = "What a pathetic little creature. It's pretending to be a much more respectable beast.",
		KITCOON_MARSH = "What a pathetic little creature. It smells of sulphur.",
		KITCOON_DECIDUOUS = "What a pathetic little creature. It will likely grow up to pick my pockets.",
		KITCOON_GRASS = "What a pathetic little creature. Just looking at it makes me itch.",
		KITCOON_ROCKY = "What a pathetic little creature. It doesn't even have the grace of a catcoon.",
		KITCOON_DESERT = "What a pathetic little creature. Those ears are ridiculous.",
		KITCOON_MOON = "What a pathetic little creature. It requires dental work.",
		KITCOON_YOT = "What a pathetic little creature, and in such a gaudy outfit.",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "It seems our actions have been noticed.",
            DEAD = "Something doesn't feel right...",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "It toys with us.",
            DEAD = "Come on now. You're not fooling anyone.",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "It's trying to ensnare us.",
        ALTERGUARDIAN_PHASE3 = "At last you reveal your true self.",
        ALTERGUARDIAN_PHASE3TRAP = "I'd do well to avoid those.",
        ALTERGUARDIAN_PHASE3DEADORB = "This power, it feels like... but it couldn't be...",
        ALTERGUARDIAN_PHASE3DEAD = "I don't know what to believe. All this time, I thought that They were...",

        ALTERGUARDIANHAT = "It makes me uneasy... but I can't deny its power.",
        ALTERGUARDIANHATSHARD = "Even shattered, it holds power.",

        MOONSTORM_GLASS = {
            GENERIC = "It's been turned to glass.",
            INFUSED = "Hm. This may be useful."
        },

        MOONSTORM_STATIC = "What is he meddling with?",
        MOONSTORM_STATIC_ITEM = "There's power trapped inside.",
        MOONSTORM_SPARK = "They give off a rather unsettling sensation.",

        BIRD_MUTANT = "That creature has seen better days.",
        BIRD_MUTANT_SPITTER = "You dare spit at me?!",

        WAGSTAFF_NPC = "What is he up to now?",
        ALTERGUARDIAN_CONTAINED = "Ah, now I see...",

        WAGSTAFF_TOOL_1 = "Hmph. So I'm to fetch his tools for him now?",
        WAGSTAFF_TOOL_2 = "I suppose that must be what he's looking for.",
        WAGSTAFF_TOOL_3 = "Finally. That must be what he's looking for.",
        WAGSTAFF_TOOL_4 = "Is this what he wants? Why couldn't that old fool have been more descriptive?!",
        WAGSTAFF_TOOL_5 = "Could this be what he's looking for?",

        MOONSTORM_GOGGLESHAT = "There are hardly enough inventors brave enough to harness the power of potatoes.",

        MOON_DEVICE = {
            GENERIC = "That old fool...",
            CONSTRUCTION1 = "I don't see why I must be the one to do all the work.",
            CONSTRUCTION2 = "How odd to be the one laboring on a machine for an unknown purpose...",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Careful, madam. I know where this trail ultimately leads.",
			RECHARGING = "It looks like she'll have to wait, for once.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Careful, madam. I know where this trail ultimately leads.",
			RECHARGING = "It looks like she'll have to wait, for once.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Careful, madam. I know where this trail ultimately leads.",
			RECHARGING = "It looks like she'll have to wait, for once.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Careful, madam. I know where this trail ultimately leads.",
			RECHARGING = "It looks like she'll have to wait, for once.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Careful, madam. I know where this trail ultimately leads.",
			RECHARGING = "It looks like she'll have to wait, for once.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "That... looks like it would hurt.",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "She doesn't understand the full extent of the power she's toying with.",
        POCKETWATCH_DISMANTLER = "Little hand tools, how quaint.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "At least it doesn't smell, like some other modes of transportation.",
			DIFFERENTSHARD = "At least it doesn't smell, like some other modes of transportation.",
		},
        POCKETWATCH_PORTAL_EXIT = "Hmph. I think she puts it up there on purpose.",

        -- Waterlog
        WATERTREE_PILLAR = "When did this get here?",
        OCEANTREE = "An aquatic tree, what next?",
        OCEANTREENUT = "I have no interest in lugging that thing around. Back in the drink you go.",
        WATERTREE_ROOT = "I've found the root of the problem.",

        OCEANTREE_PILLAR = "It could use a good pruning.",
        
        OCEANVINE = "It's just hanging around.",
        FIG = "A fruit for more refined tastes.",
        FIG_COOKED = "Quite decadent.",

        SPIDER_WATER = "Well aren't you a delight!",
        MUTATOR_WATER = "I'm not eating that.",
        OCEANVINE_COCOON = "It looks like someone's already made themselves comfortable here.",
        OCEANVINE_COCOON_BURNT = "Not quite so comfortable anymore.",

        GRASSGATOR = "Quite a skittish creature.",

        TREEGROWTHSOLUTION = "Looks like you're in a bit of a jam, pal.",

        FIGATONI = "Exquisite.",
        FIGKABAB = "Pleasantly sweet.",
        KOALEFIG_TRUNK = "I hope it was well cleaned before we stuffed the figs inside.",
        FROGNEWTON = "This recipe has legs.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "My, this is some strange magic, even for me.",
            CRIMSON = "The fuel has taken hold.",
            ENABLED = "Just what manner of magic is this?!",
			WAITING_FOR_DARK = "It's power is coalescing.",
			COOLDOWN = "I'd bet it was that insufferable imp who brought it here.",
			SPAWN_DISABLED = "Let it stay banished.",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Hmph. I suppose some people are impressed by shows of brute strength.",
            BURNT = "The show's over.",
        },

        DUMBBELL = "I have no interest in such things.",
        DUMBBELL_GOLDEN = "It's not that impressive.",
		DUMBBELL_MARBLE = "It's not that impressive.",
        DUMBBELL_GEM = "It's not that impressive.",
        POTATOSACK = "Potatoes are powerful things, not to be underestimated.",


        TERRARIUMCHEST = 
		{
			GENERIC = "It's just my style.",
			BURNT = "That seemed unnecessary.",
			SHIMMER = "How... unusual.",
		},

		EYEMASKHAT = "How deliciously macabre.",

        EYEOFTERROR = "Don't look at me, it's definitely not one of mine.",
        EYEOFTERROR_MINI = "We're going to be up to our eyeballs in... eyeballs.",
        EYEOFTERROR_MINI_GROUNDED = "I should dispose of it before it hatches.",

        FROZENBANANADAIQUIRI = "There are better beverages to make.",
        BUNNYSTEW = "Good until the last hop.",
        MILKYWHITES = "Nauseating. It must still contain some evil energy.",

        CRITTER_EYEOFTERROR = "Tell me, what is it you see, little one?",

        SHIELDOFTERROR ="At least dealing with that monstrosity was good for something.",
        TWINOFTERROR1 = "Ah. Just what we needed, a fresh pair of eyes...",
        TWINOFTERROR2 = "Ah. Just what we needed, a fresh pair of eyes...",

        -- Year of the Catcoon
        CATTOY_MOUSE = "The classic game of catcoon and mechnical mouse.",
        KITCOON_NAMETAG = "I've named so many creatures at this point, the novelty has worn off.",

		KITCOONDECOR1 =
        {
            GENERIC = "Those creatures are so feeble of mind they can't tell a real bird from a wooden one.",
            BURNT = "Whatever will we do without it.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "At least it should keep them occupied.",
            BURNT = "A pity.",
        },

		KITCOONDECOR1_KIT = "Surely someone else can set it up.",
		KITCOONDECOR2_KIT = "Physical labor is what underlings are for.",

        -- WX78
        WX78MODULE_MAXHEALTH = "That robot needs to pull themselves together.",
        WX78MODULE_MAXSANITY1 = "That robot needs to pull themselves together.",
        WX78MODULE_MAXSANITY = "That robot needs to pull themselves together.",
        WX78MODULE_MOVESPEED = "That robot needs to pull themselves together.",
        WX78MODULE_MOVESPEED2 = "That robot needs to pull themselves together.",
        WX78MODULE_HEAT = "That robot needs to pull themselves together.",
        WX78MODULE_NIGHTVISION = "That robot needs to pull themselves together.",
        WX78MODULE_COLD = "That robot needs to pull themselves together.",
        WX78MODULE_TASER = "That robot needs to pull themselves together.",
        WX78MODULE_LIGHT = "That robot needs to pull themselves together.",
        WX78MODULE_MAXHUNGER1 = "That robot needs to pull themselves together.",
        WX78MODULE_MAXHUNGER = "That robot needs to pull themselves together.",
        WX78MODULE_MUSIC = "They wouldn't...",
        WX78MODULE_BEE = "That robot needs to pull themselves together.",
        WX78MODULE_MAXHEALTH2 = "That robot needs to pull themselves together.",

        WX78_SCANNER = 
        {
            GENERIC ="I feel like it's watching me...",
            HUNTING = "Where does it think it's going?",
            SCANNING = "Hmph. Good luck unraveling the mysteries of my creations.",
        },

        WX78_SCANNER_ITEM = "Something about it is just so temptingly kickable.",
        WX78_SCANNER_SUCCEEDED = "That constant blinking light is testing my patience.",

        WX78_MODULEREMOVER = "Nerves of steel, that one.",

        SCANDATA = "Well... fine. I suppose that sums it all up, more or less.",
    },

    DESCRIBE_GENERIC = "You tell me.",
    DESCRIBE_TOODARK = "I can't see in the dark!",
    DESCRIBE_SMOLDERING = "Won't be long before it lights on fire.",

    DESCRIBE_PLANTHAPPY = "It seems reasonably healthy.",
    DESCRIBE_PLANTVERYSTRESSED = "Just what do you have to be upset about?",
    DESCRIBE_PLANTSTRESSED = "Everyone's got problems, pal.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Maybe if the garden wasn't filled with weeds...",
    DESCRIBE_PLANTSTRESSORFAMILY = "It needs to be surrounded by others of its ilk.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "The garden might be overcrowded. Perhaps I should thin it out a bit.",
    DESCRIBE_PLANTSTRESSORSEASON = "The weather is too harsh for it.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "It needs water again? Ugh, the toiling never ends.",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Richer soil might be needed.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "I'd better have a word with that underperforming plant...",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "That tasted about as good as you'd expect.",
		WINTERSFEASTFUEL = "It tastes bitter.",
    },
}
