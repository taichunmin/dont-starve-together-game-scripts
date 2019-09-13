--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "That is clearly the incorrect piece.",
        },
        BUILD =
        {
            MOUNTED = "In this elevated position, I can't reach the ground.",
            HASPET = "One domestic creature is enough for me.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I think he might object to that.",
			GENERIC = "I would really rather not.",
			NOBITS = "It's already smooth, dear.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
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
			LOCKED_GATE = "I appears to be locked.",
		},
        COOK =
        {
            GENERIC = "Perhaps later. Not all old ladies enjoy cooking, you know.",
            INUSE = "Mmm, smells lovely, dear.",
            TOOFAR = "It is not within my reach.",
        },
        
        --warly specific action
--fallback to speech_wilson.lua 		DISMANTLE =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			COOKING = "only_used_by_warly",
--fallback to speech_wilson.lua 			INUSE = "only_used_by_warly",
--fallback to speech_wilson.lua 			NOTEMPTY = "only_used_by_warly",
--fallback to speech_wilson.lua         },
        
        --wickerbottom specific action
        READ =
        {
            GENERIC = "Other matters await.",
            NOBIRDS = "The birds are not keen on this weather."
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
        },
        ATTUNE =
        {
            NOHEALTH = "I'm feeling too ill for that.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "It would be ill-advised to approach that scuffle.",
            INUSE = "Patience is required. I can ride this beefalo later.",
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
        },
        WRAPBUNDLE =
        {
            EMPTY = "I have to know what to wrap, dear.",
        },
        PICKUP =
        {
			RESTRICTION = "That's not my area of expertise.",
			INUSE = "It's already in use.",
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
	},
	ACTIONFAIL_GENERIC = "It seems I can't do that.",
	ANNOUNCE_BOAT_LEAK = "The boat has fallen into dangerous disrepair.",
	ANNOUNCE_BOAT_SINK = "Goodness, we're sinking!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Caught it just in time. The roots were nearly rotten.",
	ANNOUNCE_PICK_DISEASE_WARNING = "This plant is exhibiting concerning signs.",
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
	ANNOUNCE_NODAYSLEEP = "I can hardly get to sleep at night, nevermind during the day.",
	ANNOUNCE_NODAYSLEEP_CAVE = "These caves don't make it any easier to sleep.",
	ANNOUNCE_NOHUNGERSLEEP = "I can barely sleep even when I'm not starving!",
	ANNOUNCE_NOSLEEPONFIRE = "Even if I could sleep, these temperatures are highly unsafe.",
	ANNOUNCE_NODANGERSIESTA = "I can't lie down when I'm in danger!",
	ANNOUNCE_NONIGHTSIESTA = "I can't sleep, no matter where I lie down.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "I couldn't possibly relax in these caves.",
	ANNOUNCE_NOHUNGERSIESTA = "My hunger won't make relaxing any easier!",
	ANNOUNCE_NODANGERAFK = "Were I to lose focus now I'd be sure to sustain bodily injury.",
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
    
    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Back to the the natural state of things",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Oh my, what came over me?",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "It appears my defense has weakened.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "I can only work tirelessly for so long.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Did I just feel a raindrop?",
    
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
            LONG = "Odd...",
            MEDIUM = "It's emitting a strange energy.",
            SOON = "The flower's energy is growing powerful.",
            HAUNTED_POCKET = "I feel I should set it down now.",
            HAUNTED_GROUND = "Does it expect something of me?",
        },

        BALLOONS_EMPTY = "These seem frivolous.",
        BALLOON = "Could serve as a suitable diversion.",

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

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua             OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua             FULL = "It seems to be popular over there.",
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
        TREASURECHEST_TRAP = "Looks suspicious...",

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

		MAXWELLPHONOGRAPH = "It appears to have no power source.",
		BOOMERANG = "It is a flat aerofoil.",
		PIGGUARD = "One of the warrior caste.",
		ABIGAIL = "Fascinating. Can you speak, specter?",
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
		BASALT = "Material of great density!",
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
		},

		BEEFALOHAT = "This hat is hideous.",
		BEEFALOWOOL = "Long follicles harvested from the beefalo.",
		BEEHAT = "Appropriate protective equipment is a must!",
        BEESWAX = "Naturally antibacterial. Could slow food decay if we use it properly.",
		BEEHIVE = "The natural home of the bee.",
		BEEMINE = "A dangerous mine filled with Antophila.",
		BEEMINE_MAXWELL = "A dangerous mine filled with Culicidae.",
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
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",
			DISEASING = "Hm... The leaves are curling at the edges.",
			BURNING = "Combustion!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "It needs some agricultural attention.",
			WITHERED = "The Ardisia crenata variant has shriveled in the heat.",
			GENERIC = "That bush looks ready for harvest.",
			PICKED = "It will have to wait.",
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",
			DISEASING = "Hm... The leaves are curling at the edges.",
			BURNING = "Combustion!",
		},
		BIGFOOT = "Prehistoric!",
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
		CARROT_SEEDS = "Seed of Daucus carota.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Ah! A proper desk! Just look at the finish on that wood!",
			BURNING = "Can we have nothing decent?",
			BURNT = "The destruction of knowledge is such a difficult thing to stomach.",
		},
		WATERMELON_SEEDS = "Plant them to grow a lanatus.",
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
        CHESSPIECE_BUTTERFLY = "Carved in the lunar moth's likeness.",
        CHESSPIECE_ANCHOR = "Artists tend to reference what they're familiar with.",
        CHESSPIECE_MOON = "The missing chunk is a recent development.",
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
		CORN_SEEDS = "These maize seeds will grow in many climates.",
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
		DEADLYFEAST = "I'm not sure that's good to eat.",
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
			COLD = "The dial is moving faintly.",
			GENERIC = "It is a magitechnical homing device.",
			HOT = "Here we are!",
			WARM = "This is definitely the right track.",
			WARMER = "Must be getting close.",
		},
		DIVININGRODBASE =
		{
			GENERIC = "It will need some work before it can function.",
			READY = "It simply needs a key now.",
			UNLOCKED = "Ah. The beauty of functionality.",
		},
		DIVININGRODSTART = "This rod could be useful!",
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
		DRAGONFRUIT_SEEDS = "A seed for the magnificently mild Hylocereus undatus.",
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
		DURIAN_SEEDS = "Even the seeds of the Durio zibethinus smell a bit.",
		EARMUFFSHAT = "Poor Leporidae. At least it's warm.",
		EGGPLANT = "A nightshade. Solanum melongena, specifically.",
		EGGPLANT_COOKED = "For your enjoyment: Braised Solanum melongena.",
		EGGPLANT_SEEDS = "Seed of aubergine.",
		
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
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",
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
		FEM_PUPPET = "Poor girl.",
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
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",
			DISEASING = "Hm... There are spots of discoloration here.",
		},
		GRASSGEKKO = 
		{
			GENERIC = "I've never encountered this species before. Seems harmless.",	
			DISEASED = "It appears to be infected by some unknown pathogen.",
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
		MALE_PUPPET = "Poor boy.",

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
        MAXWELL = "Get down from there this instant!",
        MAXWELLHEAD = "I wish he wouldn't do that.",
        MAXWELLLIGHT = "How magical!",
        MAXWELLLOCK = "Now I just need a key.",
        MAXWELLTHRONE = "What an intimidating chair.",
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
        POMEGRANATE_SEEDS = "Seeds of Punica granatum, separated from their arils.",
        POND = "A small but deep freshwater pond.",
        POOP = "A quantity of animal feces. How fragrant.",
        FERTILIZER = "A bucket of animal feces. Pungent.",
        PUMPKIN = "Cucurbita pepo.",
        PUMPKINCOOKIE = "Pumpkin biscuits, goody!",
        PUMPKIN_COOKED = "Cooked Cucurbita pepo. Gooey and delicious.",
        PUMPKIN_LANTERN = "Carving the Cucurbita pepo is such a nice pastime.",
        PUMPKIN_SEEDS = "Pepitas.",
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
        ROBOT_PUPPET = "Poor child.",
        ROCK_LIGHT =
        {
            GENERIC = "A capped lava pit.",
            OUT = "Nothing but a sheath of igneous rock now.",
            LOW = "The cooling process has begun.",
            NORMAL = "Much too hot to touch.",
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
			DISEASED = "It's afflicted with an agrarian disease beyond my curing.",
			DISEASING = "Hm... Seems more brittle than is usual.",
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
		SKULLCHEST = "A container resembling a cranium.",
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
			ACTIVE = "This machine can be used to travel between worlds.",
			GENERIC = "This runestone has unique geometric properties!",
			LOCKED = "The device needs to be activated.",
			PARTIAL = "The device is in a partial state of completion.",
		},
		TELEPORTATO_BOX = "An electrical charge regulator.",
		TELEPORTATO_CRANK = "It applies basic mechanical principles.",
		TELEPORTATO_POTATO = "Neither fully organic nor inorganic!",
		TELEPORTATO_RING = "A torus of alloys and wiring.",
		TELESTAFF = "The gem appears to focus the nightmare fuel.",
		TENT = 
		{
			GENERIC = "Sleeping in there would give me a stiff neck.",
			BURNT = "It wasn't doing me much good anyhow.",
		},
		SIESTAHUT = 
		{
			GENERIC = "I can barely sleep on a bed, nevermind the ground.",
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
		TRAP_TEETH_MAXWELL = "A crude attempt at tricking me.",
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
		TREECLUMP = "The flora grows thick here.",
		
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
		YOTP_FOOD1 = "A feast fit for a festival!",
		YOTP_FOOD2 = "Not fit for human consumption.",
		YOTP_FOOD3 = "I do enjoy a snack now and then.",

		PIGELITE1 = "He's saturated with markings.", --BLUE
		PIGELITE2 = "Rather hot-tempered.", --RED
		PIGELITE3 = "Has an earthy musk to him.", --WHITE
		PIGELITE4 = "I wonder what those green markings signify.", --GREEN

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

        KLAUS = "It uses its powerful olfactory sense to locate prey.",
        KLAUS_SACK = "How curious.",
		KLAUSSACKKEY = "Hmm. Quite a sturdy antler.",
		WORMHOLE =
		{
			GENERIC = "The sleeping Megadrilacea Oraduos.",
			OPEN = "Concentric rings of teeth for rapid ingestion.",
		},
		WORMHOLE_LIMITED = "It will only last a few trips.",
		ACCOMPLISHMENT_SHRINE = "I feel a compulsive urge to activate it, again and again.",        
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
        
        QUAGMIRE_GARLIC = "Edible bulb of Allium cepa.",
        QUAGMIRE_GARLIC_COOKED = "Roast Allium cepa.",
        QUAGMIRE_GARLIC_SEEDS = "Mutated seed of Allium cepa.",
        
        QUAGMIRE_ONION = "Allium sativum, a close relative of Allium cepa.",
        QUAGMIRE_ONION_COOKED = "Roast Allium sativum.",
        QUAGMIRE_ONION_SEEDS = "Mutated seed of Allium sativum.",
        
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
        QUAGMIRE_POT = "A larger pot takes longer to boil.",
        QUAGMIRE_POT_SMALL = "Hmmm, what shall we make next?",
        QUAGMIRE_POT_HANGER_ITEM = "The old fashioned way to cook over a fire.",
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
        FISHINGNET = "The sea is a treasure trove of survival resources.",
        ANTCHOVIES = "Ah, I see! A brand new oceanic species!",
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
			DISEASED = "I fear it has contracted a disease.",
            DISEASING = "Hm, I see browning at the leaves' edges.",
			BURNING = "Tsk. Such a waste of resources.",
		},
        DEAD_SEA_BONES = "What curious skeletal structures.",
        HOTSPRING = 
        {
        	GENERIC = "My old feet could use a good soak.",
        	BOMBED = "Yes, I'll definitely soak my feet later.",
        	GLASS = "I strongly suspect moon glass is organic in composition now.",
        },
        MOONGLASS = "Perhaps I could keep a sample and study the composition.",
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
            GENERIC = "We ought to steer the ships clear of that.",
            MELTED = "From dangerous solid to harmless liquid. Thank-you, heat.",
        },
        ICEBERG_MELTED = "From dangerous solid to harmless liquid. Thank-you, heat.",

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

        WALKINGPLANK = "A dangerous escape route for one stranded at sea.",
        OAR = "One and two, and one and two!",
		OAR_DRIFTWOOD = "A much more efficient, lighter design.",

		----------------------- ROT STRINGS GO ABOVE HERE ------------------

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        --v2 Warly
        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "It will be nice to eat some properly prepared food.",
            DONE = "Smells nourishing.",

            --Warly specific PORTABLECOOKPOT_ITEM strings
--fallback to speech_wilson.lua 			COOKING_LONG = "only_used_by_warly",
--fallback to speech_wilson.lua 			COOKING_SHORT = "only_used_by_warly",
--fallback to speech_wilson.lua 			EMPTY = "only_used_by_warly",
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
        TURNIP_SEEDS = "Mutated seed of Brassica rapa.",
        
        GARLIC = "Edible bulb of Allium cepa.",
        GARLIC_COOKED = "Roast Allium cepa.",
        GARLIC_SEEDS = "Mutated seed of Allium cepa.",
        
        ONION = "Allium sativum, a close relative of Allium cepa.",
        ONION_COOKED = "Roast Allium sativum.",
        ONION_SEEDS = "Mutated seed of Allium sativum.",
        
        POTATO = "Solanum tuberosum, a staple in some cultures.",
        POTATO_COOKED = "Roasted Solanum tuberosum.",
        POTATO_SEEDS = "Mutated seed of Solanum tuberosum.",
        
        TOMATO = "Fruit of Solanum lycopersicum.",
        TOMATO_COOKED = "Roasted Solanum lycopersicum.",
        TOMATO_SEEDS = "Mutated seed of Solanum lycopersicum.",

        ASPARAGUS = "A great source of dietary fiber.", 
        ASPARAGUS_COOKED = "It releases sulfur compounds when it's digested.",
        ASPARAGUS_SEEDS = "Ah. This will grow some fresh vegetables.",

        PEPPER = "Of the genus Capsicum, if I'm not mistaken.",
        PEPPER_COOKED = "I must be careful not to rub my eyes.",
        PEPPER_SEEDS = "A Capsicum seed.",

        WEREITEM_BEAVER = "It appears to induce a Castorthropic state.",
        WEREITEM_GOOSE = "An... artistic representation of the Branta canadensis.",
        WEREITEM_MOOSE = "Someone's going to trip on this, dear.",
    },

    DESCRIBE_GENERIC = "A rare occurrence. I don't know what that is.",
    DESCRIBE_TOODARK = "I can't see in the dark.",
    DESCRIBE_SMOLDERING = "Seems it's about to ignite from the heat.",
    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Al dente.",
    },
}
