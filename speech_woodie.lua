--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "That piece ain't right.",
        },
        BUILD =
        {
            MOUNTED = "Not as tall as a moose, but still too high to place that.",
            HASPET = "I need to take care of the pet I have.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I don't think she'd like that.",
			GENERIC = "You can't shave what's not hair.",
			NOBITS = "It's already shorn, eh?",
            REFUSE = "I like my beard.",
		},
		STORE =
		{
			GENERIC = "It's already packed tighter than a Toronto streetcar.",
			NOTALLOWED = "I could probably find a better place to put that.",
			INUSE = "Oh, sorry. I didn't mean to hover over your shoulder.",
            NOTMASTERCHEF = "I wouldn't wanna muddle it up.",
		},
        CONSTRUCT =
        {
            INUSE = "Oops, sorry. Someone's using it already.",
            NOTALLOWED = "Well, it doesn't go there.",
            EMPTY = "I need to put something there.",
            MISMATCH = "Sorry. Wrong plans.",
        },
		RUMMAGE =
		{	
			GENERIC = "I can't right now. Sorry!",
			INUSE = "Sorry! I'll wait til you're finished there.",
            NOTMASTERCHEF = "I wouldn't wanna muddle it up.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "That was the wrong key, eh?",
        	KLAUS = "Now's not the time, eh?",
			QUAGMIRE_WRONGKEY = "You see another key around here, Lucy?",
        },
		ACTIVATE = 
		{
			LOCKED_GATE = "Guess we need a key.",
		},
        COOK =
        {
            GENERIC = "That's not really in my wheelhouse, sorry.",
            INUSE = "Careful now, don't burn it.",
            TOOFAR = "I gotta get closer, eh?",
        },
        
        --warly specific action
--fallback to speech_wilson.lua 		DISMANTLE =
--fallback to speech_wilson.lua 		{
--fallback to speech_wilson.lua 			COOKING = "only_used_by_warly",
--fallback to speech_wilson.lua 			INUSE = "only_used_by_warly",
--fallback to speech_wilson.lua 			NOTEMPTY = "only_used_by_warly",
--fallback to speech_wilson.lua         },
        
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom"
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "Nah, that ain't right.",
            DEAD = "I don't think they... um...",
            SLEEPING = "It's sleeping.",
            BUSY = "I'll try again in a mo'.",
            ABIGAILHEART = "I'd never hear the end of it from 'Luce if I didn't try.",
            GHOSTHEART = "Not today.",
            NOTGEM = "That doesn't look like a magic rock to me.",
            WRONGGEM = "I don't think that one'll work here.",
            NOTSTAFF = "Nah. Something long and thin goes there, but not this.",
            MUSHROOMFARM_NEEDSSHROOM = "That needs a mushroom spore, eh?",
            MUSHROOMFARM_NEEDSLOG = "That needs a magic log, eh?",
            SLOTFULL = "I should probably use what's up there first.",
            FOODFULL = "There's already something there.",
            NOTDISH = "That doesn't seem smart.",
            DUPLICATE = "No sense having two of the same recipe.",
            NOTSCULPTABLE = "I'd prefer wood, personally.",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Didn't work. Probably for the best.",
            WRONGSHADOWFORM = "That's gotta be rebuilt, eh?",
            NOMOON = "Looks like it doesn't work in the caves, eh.",
			PIGKINGGAME_MESSY = "Could use a cleaning first.",
			PIGKINGGAME_DANGER = "I'll wait until the danger's passed.",
			PIGKINGGAME_TOOLATE = "Can't do that now. It'll be dark soon.",
        },
        GIVETOPLAYER =
        {
            FULL = "They need to make room for my present, eh?",
            DEAD = "I don't think they... um...",
            SLEEPING = "Let them get some shut eye.",
            BUSY = "I've something for you when you've got a mo'.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "They need to make room for my present, eh?",
            DEAD = "I don't think they... um...",
            SLEEPING = "Let them get some shut eye.",
            BUSY = "I've something for you when you've got a mo'.",
        },
        WRITE =
        {
            GENERIC = "No thanks. I have terrible writing.",
            INUSE = "If I could just... scooch in there after you...",
        },
        DRAW =
        {
            NOIMAGE = "I won't get it right unless I have the item in front of me.",
        },
        CHANGEIN =
        {
            GENERIC = "Ouch. Do I not look skookum enough already?",
            BURNING = "Better it than a tree.",
            INUSE = "Could you hand me my plaid shirt while you're in there?",
        },
        ATTUNE =
        {
            NOHEALTH = "I feel worse than a used roll of duct tape. Maybe later?",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I should wait for the dust to settle, eh?",
            INUSE = "Maybe I can find a caribou to ride instead.",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I should wait for the dust to settle, eh?",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "I know that already, eh?",
            CANTLEARN = "Err... do you understand this one, 'Luce?",

            --MapRecorder/MapExplorer
            WRONGWORLD = "I don't think I'm in the right place for this.",
        },
        WRAPBUNDLE =
        {
            EMPTY = "I need some things to wrap first, eh?",
        },
        PICKUP =
        {
			RESTRICTION = "I ain't too keen on that, eh?",
			INUSE = "Oops! Sorry. Someone's using that.",
        },
        SLAUGHTER =
        {
            TOOFAR = "Sorry, it got away.",
        },
        REPLATE =
        {
            MISMATCH = "Whoops. I used the wrong dish.", 
            SAMEDISH = "This food is already on a dish.", 
        },
        SAIL =
        {
        	REPAIR = "The boat's not damaged yet.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Dangit! Messed up the timing.",
            BAD_TIMING1 = "Gotta keep it steady.",
            BAD_TIMING2 = "Let's give that another go, eh?",
        },
        LOWER_SAIL_FAIL =
        {
            "How aboot we try that again?",
            "No makin' fun of me, Lucy.",
            "A lot harder than it looks, eh?",
        },
        BATHBOMB =
        {
            GLASSED = "There's glass in the way, eh?",
            ALREADY_BOMBED = "Somebody beat me to it.",
        },
	},
	ACTIONFAIL_GENERIC = "Sorry, I can't do that.",
	ANNOUNCE_BOAT_LEAK = "All this water is making me very anxious.",
	ANNOUNCE_BOAT_SINK = "Hold on, Lucy!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Fixed'r right up.",
	ANNOUNCE_PICK_DISEASE_WARNING = "Well, that's not right.",
	ANNOUNCE_ADVENTUREFAIL = "Oh well. I gave it a good try.",
    ANNOUNCE_MOUNT_LOWHEALTH = "This beast looks in a bad way, eh.",

    --waxwell and wickerbottom specific strings
--fallback to speech_wilson.lua     ANNOUNCE_TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua     ANNOUNCE_WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",

    --wolfgang specific
--fallback to speech_wilson.lua     ANNOUNCE_NORMALTOMIGHTY = "only_used_by_wolfang",
--fallback to speech_wilson.lua     ANNOUNCE_NORMALTOWIMPY = "only_used_by_wolfang",
--fallback to speech_wilson.lua     ANNOUNCE_WIMPYTONORMAL = "only_used_by_wolfang",
--fallback to speech_wilson.lua     ANNOUNCE_MIGHTYTONORMAL = "only_used_by_wolfang",

	ANNOUNCE_BEES = "Bees! Bees!",
	ANNOUNCE_BOOMERANG = "Sorry! Clumsy me!",
	ANNOUNCE_CHARLIE = "Who's there, eh?",
	ANNOUNCE_CHARLIE_ATTACK = "Yeouch! That was rough!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific 
	ANNOUNCE_COLD = "It's a bit chilly out here!",
	ANNOUNCE_HOT = "It's so hot out here!",
	ANNOUNCE_CRAFTING_FAIL = "I can't do that right now.",
	ANNOUNCE_DEERCLOPS = "What was that?",
	ANNOUNCE_CAVEIN = "Sounds like some trouble up above.",
	ANNOUNCE_ANTLION_SINKHOLE = 
	{
		"Pothole incoming.",
		"Take cover!",
		"Dangerous 'round here.",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Maybe put the sinkholes on pause, eh?",
        "I got a tribute for you, eh?",
        "This here's for you, eh?",
	},
	ANNOUNCE_SACREDCHEST_YES = "Thanks'm.",
	ANNOUNCE_SACREDCHEST_NO = "We didn't cut it, Lucy.",
    ANNOUNCE_DUSK = "It's almost my bedtime.",
    
    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Tasty!",
		PAINFUL = "That was past the expiry date.",
		SPOILED = "That was a wee bit manky.",
		STALE = "I got to that one just in time.",
		INVALID = "I don't think my teeth could cut through that.",
        YUCKY = "I'd rather chew on blubber balls.",
        
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
        "Hnff...",
        "No... Don't get up... Lucy...",
        "Heavy... Eh...?",
        "...oof...",
        "I'll keep... lumberin' along...",
        "No point... complainin'...",
        "Work's... gotta get done...",
        "Nothin' like... honest work...",
        "I'm more of a chopper than a lifter...",
        "Huff... huff...",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING = 
    {
		"We better hightail it out of here.",
		"Let's skedaddle!",
		"There'll be trouble if we don't leave.",
	},
    ANNOUNCE_RUINS_RESET = "All that hard work gone to waste.",
    ANNOUNCE_SNARED = "You'll have to do better than that.",
    ANNOUNCE_REPELLED = "That's just impolite, eh.",
	ANNOUNCE_ENTER_DARK = "Who turned out the lights?",
	ANNOUNCE_ENTER_LIGHT = "Brilliance!",
	ANNOUNCE_FREEDOM = "I got out!",
	ANNOUNCE_HIGHRESEARCH = "Informative.",
	ANNOUNCE_HOUNDS = "There's something out there.",
	ANNOUNCE_WORMS = "Oh geez. I hope you're ready, Lucy.",
	ANNOUNCE_HUNGRY = "I'm getting peckish.",
	ANNOUNCE_HUNT_BEAST_NEARBY = "The beastie is nearby.",
	ANNOUNCE_HUNT_LOST_TRAIL = "I'm more of a woodsman than a hunter anyway.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "The beastie's tracks washed away.",
	ANNOUNCE_INV_FULL = "I can't carry any more kit.",
	ANNOUNCE_KNOCKEDOUT = "Ow. What was that?",
	ANNOUNCE_LOWRESEARCH = "That was barely even worth it, eh?",
	ANNOUNCE_MOSQUITOS = "Skeeters!",
    ANNOUNCE_NOWARDROBEONFIRE = "That's okay. I just need a good flannel, anyway.",
    ANNOUNCE_NODANGERGIFT = "Now's definitely the wrong time to be celebratin' Christmas.",
    ANNOUNCE_NOMOUNTEDGIFT = "I'd rather open that with my feet on the ground.",
	ANNOUNCE_NODANGERSLEEP = "It's too scary out to sleep.",
	ANNOUNCE_NODAYSLEEP = "Only a hoser sleeps during the day.",
	ANNOUNCE_NODAYSLEEP_CAVE = "I'm not feelin' too restful right now.",
	ANNOUNCE_NOHUNGERSLEEP = "My belly is too empty to fall asleep.",
	ANNOUNCE_NOSLEEPONFIRE = "Not sure that's entirely safe.",
	ANNOUNCE_NODANGERSIESTA = "Can't siesta, something's chasing me.",
	ANNOUNCE_NONIGHTSIESTA = "I prefer to siesta between chopping sessions, not at night.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "I prefer to siesta between chopping sessions, not at night.",
	ANNOUNCE_NOHUNGERSIESTA = "My belly is rumbling. I'd never be able to relax.",
	ANNOUNCE_NODANGERAFK = "I better deal with these hosers first.",
	ANNOUNCE_NO_TRAP = "Close one!",
	ANNOUNCE_PECKED = "Sorry! I'll try harder!",
	ANNOUNCE_QUAKE = "The ground is heaving!",
	ANNOUNCE_RESEARCH = "Learnin' keeps your mind sharp. Like an axe.",
	ANNOUNCE_SHELTER = "Thanks for the shelter, buddy. I'm still gonna chop you.",
	ANNOUNCE_THORNS = "Ouch!",
	ANNOUNCE_BURNT = "Ouch, that's hot!",
	ANNOUNCE_TORCH_OUT = "My light ran out!",
	ANNOUNCE_THURIBLE_OUT = "No more luring, I guess.",
	ANNOUNCE_FAN_OUT = "I guess I'll just have to suffer now.",
    ANNOUNCE_COMPASS_OUT = "I'll always have the North in my heart.",
	ANNOUNCE_TRAP_WENT_OFF = "Oops!",
	ANNOUNCE_UNIMPLEMENTED = "Ouch! That wasn't very polite.",
	ANNOUNCE_WORMHOLE = "It was gross in there!",
	ANNOUNCE_TOWNPORTALTELEPORT = "I got sand in my beard.",
	ANNOUNCE_CANFIX = "\nI think I can fix this!",
	ANNOUNCE_ACCOMPLISHMENT = "Lucy is going to be so proud of me!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "That's a wrap, eh!",	
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Need more poop, eh?",
	ANNOUNCE_TOOL_SLIP = "The stuff of nightmares!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "That tickled a bit, eh?",
	ANNOUNCE_TOADESCAPING = "It's gonna turn tail soon.",
	ANNOUNCE_TOADESCAPED = "The warty hoser ran away!",


	ANNOUNCE_DAMP = "A bit damp, eh?",
	ANNOUNCE_WET = "Plaid's warm, even when wet.",
	ANNOUNCE_WETTER = "I'm getting quite wet, eh?",
	ANNOUNCE_SOAKED = "Better hold on tight, Lucy.",

	ANNOUNCE_WASHED_ASHORE = "Well, that'll wake you up. Brr.",

    ANNOUNCE_DESPAWN = "This feels strangely familiar...",
	ANNOUNCE_BECOMEGHOST = "oOooOOOO!!",
	ANNOUNCE_GHOSTDRAIN = "I'm goin', like, nutso over here...",
	ANNOUNCE_PETRIFED_TREES = "No! Not the wood!",
	ANNOUNCE_KLAUS_ENRAGE = "I think it's time to run.",
	ANNOUNCE_KLAUS_UNCHAINED = "You shoulda stayed down.",
	ANNOUNCE_KLAUS_CALLFORHELP = "Monster hosers, incoming.",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "I hear something inside.",
		GLASS_LOW = "Hang on, I'll get you out.",
		GLASS_REVEAL = "There! How's that, buddy?",
		IDOL_MED = "I hear something inside.",
		IDOL_LOW = "Hang on, I'll get you out.",
		IDOL_REVEAL = "There! How's that, buddy?",
		SEED_MED = "I hear something inside.",
		SEED_LOW = "Hang on, I'll get you out.",
		SEED_REVEAL = "There! How's that, buddy?",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "You see that, Lucy?",
	ANNOUNCE_BRAVERY_POTION = "Glad that's over. Never thought I'd be scared of trees.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "You fell like a tree, eh?",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "There we go.",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Lucy'll never let me live that down.",

    ANNOUNCE_FLARE_SEEN = "I should go check out that flare, eh?",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Watch out, something's coming!",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Guess those ingredients don't go together.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Too long on the fire.",
    QUAGMIRE_ANNOUNCE_LOSE = "It's over for us, eh.",
    QUAGMIRE_ANNOUNCE_WIN = "We done did it.",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "Careful you don't get zapped, eh!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "I feel strong as a grizzly bear!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I'm feelin' a heckuva lot tougher now!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Time to roll up our sleeves, eh Lucy?",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "I could stand under Niagara Falls and stay dry!",
    
    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Power's out, eh?",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Sorry, all the fight's gone out of me.",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Anyone got a spare hockey helmet?",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "That's enough hustlin' around for now.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "I can feel the dampness creepin' back in.",
    
	BATTLECRY =
	{
		GENERIC = "Get over here, eh!",
		PIG = "I'll make bacon of you yet!",
		PREY = "This here's the end for you!",
		SPIDER = "For the North!",
		SPIDER_WARRIOR = "Prepare for a choppin'!",
		DEER = "Hunting season's open!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "I think that's enough.",
		PIG = "I thought that would go better.",
		PREY = "Sorry, sorry!",
		SPIDER = "Sorry!",
		SPIDER_WARRIOR = "Same time again tomorrow, eh?",
	},
	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "That'd be the thing I fell through, eh.",
        MULTIPLAYER_PORTAL_MOONROCK = "Wonder where it goes.",
        MOONROCKIDOL = "Looks kinda loonie.",
        CONSTRUCTION_PLANS = "Well, better get building.",

        ANTLION =
        {
            GENERIC = "They grow'em big out here, eh?",
            VERYHAPPY = "It seems agreeable.",
            UNHAPPY = "That critter's in a real bad mood.",
        },
        ANTLIONTRINKET = "Could give it to some sandy hoser.",
        SANDSPIKE = "That's something else, eh?",
        SANDBLOCK = "Some good craftsmanship.",
        GLASSSPIKE = "I wonder if it chops.",
        GLASSBLOCK = "Well, it ain't wood.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="It's a flower? I guess.",
            LONG = "Yup. It's a flower.",
            MEDIUM = "That flower's acting funny...",
            SOON = "Did it just move?",
            HAUNTED_POCKET = "I'm not comfortable with this.",
            HAUNTED_GROUND = "Maybe we should split, eh?",
        },

        BALLOONS_EMPTY = "Are those balloons?",
        BALLOON = "It's squeaky. Just like a real woodland creature.",

        BERNIE_INACTIVE =
        {
            BROKEN = "Poor lil thing.",
            GENERIC = "Cute, isn't it 'Luce?",
        },

        BERNIE_ACTIVE = "I guess I should be used to weird stuff by now.",
        BERNIE_BIG = "Hm. Yep. Just another day.",

        BOOK_BIRDS = "I already know more than enough aboot those things.",
        BOOK_TENTACLES = "They don't have tentacles in Canada.",
        BOOK_GARDENING = "Does it grow trees?",
        BOOK_SLEEP = "The perfect book for a full moon.",
        BOOK_BRIMSTONE = "I know better than to mess with that, eh.",

        PLAYER =
        {
            GENERIC = "Look who it is! %s!",
            ATTACKER = "%s isn't very polite...",
            MURDERER = "Enemy of the forest!",
            REVIVER = "%s, you're an alright sort.",
            GHOST = "Someone should rub a heart on %s.",
            FIRESTARTER = "Knock off the fire starting there, bud.",
        },
        WILSON =
        {
            GENERIC = "%s! Hey buddy!",
            ATTACKER = "You haven't been very gentlemanly lately, %s.",
            MURDERER = "Enemy of the forest!",
            REVIVER = "%s, you're an alright guy.",
            GHOST = "Someone should rub a heart on %s.",
            FIRESTARTER = "Was that blaze some sort of experiment, %s?",
        },
        WOLFGANG =
        {
            GENERIC = "That's my buddy, %s! Hey!",
            ATTACKER = "%s could be a bit more considerate...",
            MURDERER = "You'll not strong arm me, %s!",
            REVIVER = "%s has a big, squishy heart under those muscles.",
            GHOST = "C'mon, bud, let's get you on your feet.",
            FIRESTARTER = "Don't singe your moustache, %s.",
        },
        WAXWELL =
        {
            GENERIC = "Hey %s, how you doin' ya big hoser?",
            ATTACKER = "%s'll end up on the wrong end of my axe if he's not careful...",
            MURDERER = "Yer still a hoser! Now it's choppin' time!",
            REVIVER = "You're growin' on me, %s. Like a fungus.",
            GHOST = "Lucy says I have to help you, %s. Let's get goin'.",
            FIRESTARTER = "You'll not want to be burning things, bud.",
        },
        WX78 =
        {
            GENERIC = "It's my metal buddy, %s!",
            ATTACKER = "%s is cruisin' for a bruisin'...",
            MURDERER = "It's time to power DOWN, %s!",
            REVIVER = "%s, you're an alright sort.",
            GHOST = "Huh, I guess %s had a soul after all.",
            FIRESTARTER = "You're gonna singe your chassis, %s.",
        },
        WILLOW =
        {
            GENERIC = "Look who it is! %s!",
            ATTACKER = "You're tempting a forest fire, %s...",
            MURDERER = "Here comes the wildfire!",
            REVIVER = "You're on fire today, %s. No... actually.",
            GHOST = "Just don't haunt anything while I look for a heart, %s.",
            FIRESTARTER = "Business as usual, I see.",
        },
        WENDY =
        {
            GENERIC = "%s! Hi little buddy!",
            ATTACKER = "%s, I can't believe what I just SAW! Wait, no...",
            MURDERER = "Hereeee's Woodie!",
            REVIVER = "%s! You're doin' great, little buddy.",
            GHOST = "With a heart you'll be tip-top in no time, %s.",
            FIRESTARTER = "Should you be setting fires, little buddy?",
        },
        WOODIE =
        {
            GENERIC = "%s! Fancy seeing another Canadian here.",
            ATTACKER = "%s isn't a true Canadian...",
            MURDERER = "Hey, c'mere %s! I've gotta AXE you question!",
            REVIVER = "%s is a Canadian patriot, eh.",
            GHOST = "Canadians gotta stick together, %s. Let's get a heart.",
            BEAVER = "Been there, bud.",
            BEAVERGHOST = "You're gonna have one monster headache after this, buddy.",
            MOOSE = "Yeesh, is that really what I look like?",
            MOOSEGHOST = "Hang on bud, we'll get you sorted out.",
            GOOSE = "Truly Canada's most ferocious beast.",
            GOOSEGHOST = "Whew... I mean, let's find you a heart, eh?",
            FIRESTARTER = "Those fires are kind of counterproductive now, eh?",
        },
        WICKERBOTTOM =
        {
            GENERIC = "%s. Ma'am.",
            ATTACKER = "%s should read an etiquette book once in awhile.",
            MURDERER = "This is gonna be a clear cut!",
            REVIVER = "That's some good work ya did, Ma'am.",
            GHOST = "You know where I can get a heart, %s?",
            FIRESTARTER = "Careful around those open flames, Ma'am.",
        },
        WES =
        {
            GENERIC = "%s! How ya doin', buddy?",
            ATTACKER = "%s could learn some manners...",
            MURDERER = "You're MIME now, %s!",
            REVIVER = "%s, you're an alright guy.",
            GHOST = "First we'll get you a heart, then we'll get you some bacon, eh %s?",
            FIRESTARTER = "Keep those flames away from my trees!",
        },
        WEBBER =
        {
            GENERIC = "%s! Hi little buddy!",
            ATTACKER = "Hey %s, can't we all just get a-log?",
            MURDERER = "'Luce gave me the go-ahead! You're in trouble now, %s!",
            REVIVER = "You're an alright spider, kiddo.",
            GHOST = "We better get you a heart, hey kiddo?",
            FIRESTARTER = "I better not see anymore fires, little buddy.",
        },
        WATHGRITHR =
        {
            GENERIC = "%s! Hey bud!",
            ATTACKER = "%s has raiding and looting on the brain...",
            MURDERER = "Your spear versus my axe, let's see whatcha got, eh!",
            REVIVER = "I'm glad you're on our side, %s.",
            GHOST = "With a heart you'll be feelin' like your mighty self in no time.",
            FIRESTARTER = "What's with the fires lately, bud?",
        },
        WINONA =
        {
            GENERIC = "%s! Hey there bud!",
            ATTACKER = "%s is getting too big for her britches.",
            MURDERER = "You're on the chopping block now, %s!",
            REVIVER = "I knew we were gonna get along.",
            GHOST = "Yer looking a little pale, %s.",
            FIRESTARTER = "%s betrays the forest!",
        },
        WORTOX =
        {
            GENERIC = "%s, buddy, hey!",
            ATTACKER = "Trust me, you ain't got the chops, %s.",
            MURDERER = "I'll hang those horns on the wall of my cabin!",
            REVIVER = "That was mighty kind of you, %s.",
            GHOST = "That soul sapper's lookin' like a real sap now.",
            FIRESTARTER = "You better not burn any of my precious trees!",
        },
        WORMWOOD =
        {
            GENERIC = "%s, hey there budding bud!",
            ATTACKER = "Why don't you leaf the fighting to the professionals?",
            MURDERER = "I'll wear that gem like a brooch, y'hear!",
            REVIVER = "You're a good sapling, %s.",
            GHOST = "C'mon, let's getcha replanted.",
            FIRESTARTER = "I thought you of all people would prevent forest fires.",
        },
        WARLY =
        {
            GENERIC = "%s, buddy! How you doing?",
            ATTACKER = "Careful where you're swingin', %s.",
            MURDERER = "I'm gonna soufflé you alive!",
            REVIVER = "%s is a stand up kinda guy.",
            GHOST = "Welp, that's the way the cookie crumbles.",
            FIRESTARTER = "Watch that fire now, %s.",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua             OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua             FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER = 
        {
            GENERIC = "Keep flapping, little guy!",
            SLEEPING = "Snooze away, bud.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Even the flower is slimy.",
            DEAD = "Dead and still slimy.",
        },
        GLOMMERWINGS = "Unsurprisingly, the wings are slimy.",
        GLOMMERFUEL = "Yep, his slime is slimy too.",
        BELL = "I'm amazed it makes such a crisp sound.",
        STATUEGLOMMER =
        {
            GENERIC = "That's a curious statue, eh?",
            EMPTY = "It had some cool things inside, eh?",
        },

        LAVA_POND_ROCK = "Boulder-dash.",

		WEBBERSKULL = "The skull gives me the willies, too.",
		WORMLIGHT = "This thing will be useful.",
		WORMLIGHT_LESSER = "Wrinklier than the underside of a beaver.",
		WORM =
		{
		    PLANT = "I know a plant when I see one. This's an impostor!",
		    DIRT = "Be wary of the moving ground.",
		    WORM = "WOOORM!",
		},
        WORMLIGHT_PLANT = "Just a regular old plant.",
		MOLE =
		{
			HELD = "Want some rocks?",
			UNDERGROUND = "Dig, dig, dig.",
			ABOVEGROUND = "It feels aboot rocks the way I feel aboot trees.",
		},
		MOLEHILL = "I bet it's just a pile of rocks inside.",
		MOLEHAT = "Now featuring night-time chopping!",

		EEL = "This should cook up nicely.",
		EEL_COOKED = "This cooked up nicely.",
		UNAGI = "It'll fill ya up.",
		EYETURRET = "That'll drive the hosers off.",
		EYETURRET_ITEM = "This needs to be installed properly.",
		MINOTAURHORN = "That's a nice horn, eh.",
		MINOTAURCHEST = "That's a nice chest with horns, eh.",
		THULECITE_PIECES = "It's not wood but it'll do.",
		POND_ALGAE = "Doesn't look edible.",
		GREENSTAFF = "This'll help me dismantle stuff!",
		GIFT = "They're just as fun to give as they are to receive.",
        GIFTWRAP = "Should we do something nice today, Lucy?",
		POTTEDFERN = "I do love me some plant life.",
        SUCCULENT_POTTED = "Ain't a tree, but ain't bad.",
		SUCCULENT_PLANT = "That's a plant, eh?",
		SUCCULENT_PICKED = "There's a lot of water in there for such a tiny plant.",
		SENTRYWARD = "That's an odd looking tree.",
        TOWNPORTAL =
        {
			GENERIC = "Some sort of sandy transportation.",
			ACTIVE = "Get a move on.",
		},
        TOWNPORTALTALISMAN = 
        {
			GENERIC = "S'got a powerful stink, eh?",
			ACTIVE = "Time to get a move on.",
		},
        WETPAPER = "Damp.",
        WETPOUCH = "Doesn't look useful, but I could be wrong.",
        MOONROCK_PIECES = "That's in a pretty sorry state, eh?",
        MOONBASE =
        {
            GENERIC = "I'd rather not muck with that if I can help it.",
            BROKEN = "That'll need more than a roll of duct tape to fix.",
            STAFFED = "I'm happy to just leave it there for now.",
            WRONGSTAFF = "Looks a little off.",
            MOONSTAFF = "That oughta keep us cool.",
        },
        MOONDIAL = 
        {
			GENERIC = "Do I really need to be reminded of the moon during the day?",
			NIGHT_NEW = "The moon's gone for now. Phew.",
			NIGHT_WAX = "The moon's waxing again.",
			NIGHT_FULL = "Not a good night to have a curse, but then when's it ever?",
			NIGHT_WANE = "The moon's waning. Time for some peace and quiet.",
			CAVE = "We're free from the moon's reach down here.",
			WEREBEAVER = "Just aboot time again, Lucy.", --woodie specific
        },
		THULECITE = "It's the wood of the caves!",
		ARMORRUINS = "That'll stop the hurt.",
		ARMORSKELETON = "Sticks to yer ribs.",
		SKELETONHAT = "That right there's a cursed object, eh?",
		RUINS_BAT = "Metal on a stick.",
		RUINSHAT = "It's no toque, but it'll do.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "I think it's off.",
            WARN = "This thing just turned on!",
            WAXING = "It's vibrating!",
            STEADY = "It's going crazy!",
            WANING = "It's settling down.",
            DAWN = "It's nearly still.",
            NOMAGIC = "I think it's off.",
		},
		BISHOP_NIGHTMARE = "I can see the internal workings!",
		ROOK_NIGHTMARE = "The gears are spilling out.",
		KNIGHT_NIGHTMARE = "Doesn't look to be in the best of shape.",
		MINOTAUR = "Another poor soul with a curse.",
		SPIDER_DROPPER = "They're smart to live away from the corruption.",
		NIGHTMARELIGHT = "They should have used wood.",
		NIGHTSTICK = "That's mighty nifty.",
		GREENGEM = "How flashy.",
		MULTITOOL_AXE_PICKAXE = "It's... it's beautiful.",
		ORANGESTAFF = "This will help me get around quickly.",
		YELLOWAMULET = "I could cut wood at night with this.",
		GREENAMULET = "I get a bit of a weird feeling around these things.",
		SLURPERPELT = "Where's the nearest fur trader?",	

		SLURPER = "I think it's living hair.",
		SLURPER_PELT = "Looks like a dead beaver.",
		ARMORSLURPER = "It tickles. I think it's still alive.",
		ORANGEAMULET = "This'll make the chores go by quicker!",
		YELLOWSTAFF = "Useful in a pinch!",
		YELLOWGEM = "I can see the stars in it.",
		ORANGEGEM = "It's shimmering.",
        OPALSTAFF = "Err, moon magic isn't really... my thing... Heh.",
        OPALPRECIOUSGEM = "You're fond of it, aren'tcha Lucy?",
        TELEBASE = 
		{
			VALID = "It's ready, but am I?",
			GEMS = "Needs gems, eh?",
		},
		GEMSOCKET = 
		{
			VALID = "Looks ready.",
			GEMS = "It'll need a gem.",
		},
		STAFFLIGHT = "Well, ain't that something.",
        STAFFCOLDLIGHT = "At least it won't start a forest fire.",

        ANCIENT_ALTAR = "There's axe marks on these altar stones.",

        ANCIENT_ALTAR_BROKEN = "Looks a little worn out.",

        ANCIENT_STATUE = "Another hoser.",

        LICHEN = "Looks barely edible.",
		CUTLICHEN = "Yum! Tastes woody!",

		CAVE_BANANA = "It tastes tropical.",
		CAVE_BANANA_COOKED = "Now it's a warm mush.",
		CAVE_BANANA_TREE = "They don't have those back home.",
		ROCKY = "Lobster supper time!",
		
		COMPASS =
		{
			GENERIC="Points to the True North.",
			N = "True North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "It's a beaut.",
        ARMORSNURTLESHELL = "You can never be too safe.",
        BAT = "Who taught that rat to fly?",
        BATBAT = "A mouse with wings?",
        BATWING = "Gross!",
        BATWING_COOKED = "Gross! And tasty! So confusing!",
        BATCAVE = "Full of the little critters!",
        BEDROLL_FURRY = "I love camping.",
        BUNNYMAN = "He looks friendly enough.",
        FLOWER_CAVE = "Shiny!",
        GUANO = "It stinks less than the other kind.",
        LANTERN = "Well, that's enlightening, eh?",
        LIGHTBULB = "It looks chewy.",
        MANRABBIT_TAIL = "I feel sorry for it.",
        MUSHROOMHAT = "That there'll make you one with the forest.",
        MUSHROOM_LIGHT2 =
        {
            ON = "It illuminates with all the colours of the wind.",
            OFF = "It oughta be green like a lush, choppable forest.",
            BURNT = "That got charred real good.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Soak in that all-natural light, Lucy.",
            OFF = "My kind of decor.",
            BURNT = "Whose bright idea was it to kill the lights?",
        },
        SLEEPBOMB = "Some folks around here could use the shuteye.",
        MUSHROOMBOMB = "I don't like the look of that.",
        SHROOM_SKIN = "That's gross.",
        TOADSTOOL_CAP =
        {
            EMPTY = "It's a hole.",
            INGROUND = "Is that how trees are born?",
            GENERIC = "It isn't polypore-sonal, I just gotta chop you.",
        },
        TOADSTOOL =
        {
            GENERIC = "I'm gonna need a bigger axe.",
            RAGE = "Alright, enough playin' around! Get'em Lucy!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Mushrooms don't have no reason to be that big.",
            BURNT = "Don't breathe it in, Lucy!",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "I can't let that stand.",
            BLOOM = "Chop it down before it spreads!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Maybe I should chop it.",
            BLOOM = "I like the colour of this one.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "It's made of wood.",
            BLOOM = "Well, I can't cut it down now...",
        },
        MUSHTREE_TALL_WEBBED = "This one needs pruning, at least.",
        SPORE_TALL =
        {
            GENERIC = "A flying green pinecone!",
            HELD = "One day this might be a tree.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "A floating red pinecone!",
            HELD = "One day this might be a tree.",
        },
        SPORE_SMALL =
        {
            GENERIC = "We've been visited by a forest sprite, Lucy!",
            HELD = "One day this might be a tree.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Is it carrot flavoured?",
            BURNT = "Is it roasted carrot flavoured?",
        },
        SLURTLE = "He's just misunderstood.",
        SLURTLE_SHELLPIECES = "His home is broken now. Oh.",
        SLURTLEHAT = "That could sure keep a noggin safe.",
        SLURTLEHOLE = "Are you guys doing okay in there?",
        SLURTLESLIME = "Someone needs a tissue.",
        SNURTLE = "Spirals!",
        SPIDER_HIDER = "Tricky devil!",
        SPIDER_SPITTER = "Spitting is rude!",
        SPIDERHOLE = "I should skedaddle before they come out of there.",
        SPIDERHOLE_ROCK = "I should skedaddle before they come out of there.",
        STALAGMITE = "I'm not too interested in rocks.",
        STALAGMITE_TALL = "I'm not too interested in rocks.",
        TREASURECHEST_TRAP = "Something is not quite right aboot that chest.",

        TURF_CARPETFLOOR = "Too classy for my tastes.",
        TURF_CHECKERFLOOR = "Looks like one of those city-people outhouses.",
        TURF_DIRT = "Just some ground, eh?",
        TURF_FOREST = "Just some ground, eh?",
        TURF_GRASS = "Just some ground, eh?",
        TURF_MARSH = "Just some ground, eh?",
        TURF_METEOR = "Just some ground, eh?",
        TURF_PEBBLEBEACH = "Just some ground, eh?",
        TURF_ROAD = "Just some ground, eh?",
        TURF_ROCKY = "Just some ground, eh?",
        TURF_SAVANNA = "Just some ground, eh?",
        TURF_WOODFLOOR = "Flooring fit for a king!",

		TURF_CAVE="Some ground.",
		TURF_FUNGUS="It's mushy, like peas.",
		TURF_SINKHOLE="I found this underground.",
		TURF_UNDERROCK="Rocks. Bleh.",
		TURF_MUD="At least you don't have to clean it.",

		TURF_DECIDUOUS = "Just some ground, eh?",
		TURF_SANDY = "Just some ground, eh?",
		TURF_BADLANDS = "Just some ground, eh?",
		TURF_DESERTDIRT = "Just some ground, eh?",
		TURF_FUNGUS_GREEN = "Just some ground, eh?",
		TURF_FUNGUS_RED = "Just some ground, eh?",
		TURF_DRAGONFLY = "Fire doesn't quite take here, eh?",

		POWCAKE = "I like the ones made with real sugar better.",
        CAVE_ENTRANCE = "It's all bunged up.",
        CAVE_ENTRANCE_RUINS = "It's all bunged up.",
       
       	CAVE_ENTRANCE_OPEN = 
        {
            GENERIC = "There're probably no trees down there anyway.",
            OPEN = "It looks like Sudbury down there.",
            FULL = "More crowded than a Toronto subway!",
        },
        CAVE_EXIT = 
        {
            GENERIC = "Maybe later. I've gotten cozy down here.",
            OPEN = "There are probably trees up there.",
            FULL = "Sorry! I'll wait til you're all done up there!",
        },

		MAXWELLPHONOGRAPH = "Better than most of the stuff on the radio.",
		BOOMERANG = "That looks hard to throw.",
		PIGGUARD = "I don't want to make him mad.",
		ABIGAIL = "That ain't right.",
		ADVENTURE_PORTAL = "I wonder if that's the way out of here.",
		AMULET = "Always have a backup plan.",
		ANIMAL_TRACK = "A large woodland creature passed this way!",
		ARMORGRASS = "It's better than nothing.",
		ARMORMARBLE = "It's hard to swing an axe while wearing this.",
		ARMORWOOD = "It fits me so well!",
		ARMOR_SANITY = "It makes me queasy to look at.",
		ASH =
		{
			GENERIC = "It's all burnt up.",
			REMAINS_GLOMMERFLOWER = "This used to be a slimy flower.",
			REMAINS_EYE_BONE = "This used to be an eyebone.",
			REMAINS_THINGIE = "Well, that's a shame.",
		},
		AXE = "It's not as nice as Lucy.",
		BABYBEEFALO = 
		{
			GENERIC = "A face only a mother could love.",
		    SLEEPING = "I enjoy sleeping outside, too.",
        },
        BUNDLE = "What's inside? Hope it's logs.",
        BUNDLEWRAP = "The paper's brown. Like wood.",
		BACKPACK = "That's a decent looking rucksack.",
		BACONEGGS = "Awww. It's just front bacon.",
		BANDAGE = "At least I didn't have to pay for it.",
		BASALT = "That rock ain't going to move.",
		BEARDHAIR = "My hair's not that colour. Not my beard, anyway.",
		BEARGER = "That's a big bear!",
		BEARGERVEST = "Now this is some proper winter gear.",
		ICEPACK = "Good for long hikes.",
		BEARGER_FUR = "It's as thick as my head!",
		BEDROLL_STRAW = "I slept on worse back at the lumber camp.",
		BEEQUEEN = "Bees got no business getting that big.",
		BEEQUEENHIVE = 
		{
			GENERIC = "I'm not eating honey off the ground.",
			GROWING = "The bees are planning something.",
		},
        BEEQUEENHIVEGROWN = "Nature is something else, eh?",
        BEEGUARD = "Hopefully no one's allergic, eh?",
        HIVEHAT = "Hmph. Real regal.",
        MINISIGN =
        {
            GENERIC = "Is there anything wood can't do?",
            UNDRAWN = "What is this... some sort of sign?",
        },
        MINISIGN_ITEM = "Good, sturdy wood.",
		BEE =
		{
			GENERIC = "She's making the flowers grow.",
			HELD = "Now what do I do with her?",
		},
		BEEBOX =
		{
			READY = "Maple syrup substitute!",
			FULLHONEY = "Maple syrup substitute!",
			GENERIC = "Buzzers!",
			NOHONEY = "I'm getting hungry just looking at it.",
			SOMEHONEY = "I could get more if I waited.",
			BURNT = "No, not the bees!",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Doesn't need us no more.",
			LOTS = "It's doing real well on its own.",
			SOME = "There we go. Everyone needs a bit of help sometimes.",
			EMPTY = "It needs a bit of help getting started.",
			ROTTEN = "That rotten log needs replacing.",
			BURNT = "If a log burns in the forest does it hurt my feelings? Yes. It does.",
			SNOWCOVERED = "Everybody's got hardships, eh?",
		},
		BEEFALO =
		{
			FOLLOWER = "I think he likes me.",
			GENERIC = "He smells like a sod house.",
			NAKED = "Cheer up, eh?",
			SLEEPING = "He's catching some zeds.",
            --Domesticated states:
            DOMESTICATED = "I like this one's attitude.",
            ORNERY = "Why so glum, chum?",
            RIDER = "I'm sorry, want to go for a ride?",
            PUDGY = "You're almost as big as a moose!",
		},

		BEEFALOHAT = "Now I'm the king of the beefalo!",
		BEEFALOWOOL = "It feels like my beard.",
		BEEHAT = "That'll keep the bees out of yer eyes.",
        BEESWAX = "Yeesh, that's waxy.",
		BEEHIVE = "They're all comfy-cozy in there.",
		BEEMINE = "I don't know if the bees like this.",
		BEEMINE_MAXWELL = "Hey! That's just mean!",
		BERRIES = "I have a heartier appetite than that.",
		BERRIES_COOKED = "Tastes like warm berries.",
        BERRIES_JUICY = "That's good eatin', eh?",
        BERRIES_JUICY_COOKED = "Mmm. These'd be perfect with some syrup.",
		BERRYBUSH =
		{
			BARREN = "It needs a good poopin'.",
			WITHERED = "It's perished from the heat, eh?",
			GENERIC = "Saskatoon berries?",
			PICKED = "No berries left!",
			DISEASED = "It's caught a bit of a bug.",
			DISEASING = "Lookin' a bit down.",
			BURNING = "Can't save it now.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Lookin' pretty barren.",
			WITHERED = "Dry as the Alberta plains.",
			GENERIC = "I see a snack.",
			PICKED = "Eh, they'll be back.",
			DISEASED = "It's caught a bit of a bug.",
			DISEASING = "Lookin' a bit down.",
			BURNING = "Can't save it now.",
		},
		BIGFOOT = "Watch where you're stepping!",
		BIRDCAGE =
		{
			GENERIC = "Where I try to make birds reform their evil ways.",
			OCCUPIED = "Think aboot what you've done, bird!",
			SLEEPING = "They look so innocent when they dream.",
			HUNGRY = "I'll get you something to eat soon, buddy.",
			STARVING = "He's got a hankering for some poutine!",
			DEAD = "I'm sorry. I failed you.",
			SKELETON = "That's starting to smell.",
		},
		BIRDTRAP = "I'll show those birds yet!",
		CAVE_BANANA_BURNT = "Such a waste.",
		BIRD_EGG = "There's a bird in there, thinking evil bird thoughts.",
		BIRD_EGG_COOKED = "Well, at least it never became a bird.",
		BISHOP = "It's been a while since my last confession.",
		BLOWDART_FIRE = "This seems a bit aggressive.",
		BLOWDART_SLEEP = "A couple blows on that and you can escape just aboot anything!",
		BLOWDART_PIPE = "Anyone want a demonstration of my impressive lungpower?",
		BLOWDART_YELLOW = "Gross bird parts made an okay weapon, I guess.",
		BLUEAMULET = "Just need a tasty beverage to cool now, eh?",
		BLUEGEM = "It's very cold.",
		BLUEPRINT = 
		{ 
            COMMON = "I'm not one for book learning.",
            RARE = "Looks real complicated, that one.",
        },
        SKETCH = "Some plans for a fancy stone carving.",
		BLUE_CAP = "That's not meat.",
		BLUE_CAP_COOKED = "That's not meat.",
		BLUE_MUSHROOM =
		{
			GENERIC = "I can never remember which ones you can eat.",
			INGROUND = "I'll come back later.",
			PICKED = "Well, that's over.",
		},
		BOARDS = "So smooth. You can really see the grain.",
		BONESHARD = "I wish I knew how to make bread.",
		BONESTEW = "Sticks to your ribs.",
		BUGNET = "It can collect skeeters.",
		BUSHHAT = "It's good for hiding from nature.",
		BUTTER = "I prefer margarine.",
		BUTTERFLY =
		{
			GENERIC = "I never trusted those things, eh?",
			HELD = "Where are you going to run?",
		},
		BUTTERFLYMUFFIN = "Crunchy! ...But soft?",
		BUTTERFLYWINGS = "Sorry! Sorry. How awful!",
		BUZZARD = "Stay away from those meat snacks!",

		SHADOWDIGGER = "Are your little buddies, uh... alive?",

		CACTUS = 
		{
			GENERIC = "That's gonna hurt.",
			PICKED = "Called it.",
		},
		CACTUS_MEAT_COOKED = "Much better.",
		CACTUS_MEAT = "Would you put nails in your mouth?",
		CACTUS_FLOWER = "It's a wonder anything grows in this climate at all.",

		COLDFIRE =
		{
			EMBERS = "It's almost gone.",
			GENERIC = "This'll make it feel more like home.",
			HIGH = "Uh oh! It's bit high!",
			LOW = "I should probably do something aboot that, eh?",
			NORMAL = "I love a cold fire in the evening.",
			OUT = "It was good while it lasted.",
		},
		CAMPFIRE =
		{
			EMBERS = "It's almost gone.",
			GENERIC = "Where's my guitar?",
			HIGH = "Uh oh! It's bit high!",
			LOW = "I should probably do something aboot that, eh?",
			NORMAL = "I love a fire in the evening.",
			OUT = "It was good while it lasted.",
		},
		CANE = "It's good for the back country.",
		CATCOON = "Pests.",
		CATCOONDEN = 
		{
			GENERIC = "Ugh, how many more lives do you have?",
			EMPTY = "Good riddance.",
		},
		CATCOONHAT = "The traditional garb of the woodsman.",
		COONTAIL = "That's the end of that cat's tale.",
		CARROT = "That's rabbit food.",
		CARROT_COOKED = "That's cooked rabbit food.",
		CARROT_PLANTED = "I'm not one for vegetables, eh?",
		CARROT_SEEDS = "Tiny carrots.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Heh. Has a little compass and everything.",
			BURNING = "Looks like the map ends here.",
			BURNT = "Eh, I prefer to just wander around the woods anyway.",
		},
		WATERMELON_SEEDS = "Maybe I could plant them?",
		CAVE_FERN = "Hey! It's a fern!",
		CHARCOAL = "This makes me a bit sad.",
        CHESSPIECE_PAWN = "Just a humble peasant, really.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Pfft, tacky.",
            STRUGGLE = "Get ready, Lucy.",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "I miss horses.",
            STRUGGLE = "Get ready, Lucy.",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "That's not really my sort of thing, eh?",
            STRUGGLE = "Get ready, Lucy.",
        },
        CHESSPIECE_MUSE = "I don't tend to trust anyone without a face. Lucy excluded, of course.",
        CHESSPIECE_FORMAL = "Looks like a bit of a hoser.",
        CHESSPIECE_HORNUCOPIA = "Well, I did say I had a hankering for \"stone fruit\".",
        CHESSPIECE_PIPE = "Kitschy. Just how Lucy and I like it.",
        CHESSPIECE_DEERCLOPS = "Fine detail on that base.",
        CHESSPIECE_BEARGER = "Good use of stone.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Looks sturdy.",
        },
        CHESSPIECE_DRAGONFLY = "Good stonework.",
        CHESSPIECE_BUTTERFLY = "Reminds me of nature.",
        CHESSPIECE_ANCHOR = "Looks good to me.",
        CHESSPIECE_MOON = "Someone did a good job on this.",
        CHESSJUNK1 = "Dead metal.",
        CHESSJUNK2 = "Dead metal.",
        CHESSJUNK3 = "Dead metal.",
		CHESTER = "He's doing his best!",
		CHESTER_EYEBONE =
		{
			GENERIC = "No one ever told him it was rude to stare.",
			WAITING = "I wonder if it will ever wake up again.",
		},
		COOKEDMANDRAKE = "Was that a bad thing to do?",
		COOKEDMEAT = "Just like my dear old ma used to make.",
		COOKEDMONSTERMEAT = "I still don't want to eat it.",
		COOKEDSMALLMEAT = "That'll just make me hungrier!",
		COOKPOT =
		{
			COOKING_LONG = "It'll be a bit longer, eh?",
			COOKING_SHORT = "Oh boy! Here it comes!",
			DONE = "Time for supper!",
			EMPTY = "It seems a waste to just leave it sitting there, empty.",
			BURNT = "Burned to a crisp.",
		},
		CORN = "I like it, but not in everything that I eat.",
		CORN_COOKED = "Cooked with the goodness of corn.",
		CORN_SEEDS = "I'm more of a hewer of wood than a tiller of soil.",
        CANARY =
		{
			GENERIC = "Degenerate.",
			HELD = "Want a peek at our prisoner, Lucy?",
		},
        CANARY_POISONED = "Diseased vermin.",

		CRITTERLAB = "Anyone home?",
        CRITTER_GLOMLING = "Charmingly chubby.",
        CRITTER_DRAGONLING = "Don't start no forest fires now, buddy.",
		CRITTER_LAMB = "Heh, it feels like a beard.",
        CRITTER_PUPPY = "Man and robot's best friend.",
        CRITTER_KITTEN = "Giving it pats is relaxing.",
        CRITTER_PERDLING = "Look, it's not you. It's me.",
		CRITTER_LUNARMOTHLING = "That's my little forest buddy.",

		CROW =
		{
			GENERIC = "He's planning something. I can tell.",
			HELD = "You'll pay for your crimes, crow!",
		},
		CUTGRASS = "I think I might be allergic to this.",
		CUTREEDS = "Want to hear my loon call?",
		CUTSTONE = "Part of the Canadian shield.",
		DEADLYFEAST = "That doesn't smell quite right, eh.",
		DEER =
		{
			GENERIC = "That's a creature of the woods, eh?",
			ANTLER = "Something's different aboot you...",
		},
        DEER_ANTLER = "Wish I still had a cabin I could mount these things in.",
        DEER_GEMMED = "That ain't natural.",
		DEERCLOPS = "That's a big moose!",
		DEERCLOPS_EYEBALL = "Now what is this good for?",
		EYEBRELLAHAT =	"Always good to have something watching over you.",
		DEPLETED_GRASS =
		{
			GENERIC = "It's probably a tuft of grass.",
		},
        GOGGLESHAT = "Seems pretty useless.",
        DESERTHAT = "That's easy on the eyes.",
		DEVTOOL = "I'm not commenting on that.",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "Hey! A clue!",
		DIVININGROD =
		{
			COLD = "It's really fuzzy from here.",
			GENERIC = "I wonder if it gets the hockey game.",
			HOT = "Loud and clear! Something's near!",
			WARM = "I think I'm getting closer.",
			WARMER = "Woah, careful there, bud.",
		},
		DIVININGRODBASE =
		{
			GENERIC = "It looks like something should plug in.",
			READY = "It's ready to be unlocked.",
			UNLOCKED = "Now all it needs is to be turned on.",
		},
		DIVININGRODSTART = "That's a weird looking rod.",
		DRAGONFLY = "She'll burn all the trees before I can chop them!",
		ARMORDRAGONFLY = "Plaid is all the armour I need.",
		DRAGON_SCALES = "I still don't believe in dragons.",
		DRAGONFLYCHEST = "Gaudy if you ask me.",
		DRAGONFLYFURNACE = 
		{
			HAMMERED = "It got even tackier, eh?",
			GENERIC = "Tacky taxidermy.", --no gems
			NORMAL = "Just bask in that warm glow.", --one gem
			HIGH = "I'm sweaty enough without help from a furnace.", --two gems
		},
        
        HUTCH = "Friendly lil guy, eh?",
        HUTCH_FISHBOWL =
        {
            GENERIC = "I've never had one of these before.",
            WAITING = "It was bound to happen.",
        },
		LAVASPIT = 
		{
			HOT = "Aaaah! Tree killer!",
			COOL = "My trees are safe now.",
		},
		LAVA_POND = "I wouldn't get too close to that, eh?",
		LAVAE = "Death by axe!",
		LAVAE_COCOON = "Lil buddy cooled right off.",
		LAVAE_PET = 
		{
			STARVING = "Skinnier than a blue heron's legs.",
			HUNGRY = "Poor gal's getting hungry.",
			CONTENT = "Look how happy she is!",
			GENERIC = "That's my lil critter.",
		},
		LAVAE_EGG = 
		{
			GENERIC = "There's a fire burning in there.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "She could use a parka.",
			COMFY = "Cozier than a moose wrapped in duct tape!",
		},
		LAVAE_TOOTH = "Not as sharp as Lucy!",

		DRAGONFRUIT = "I've never seen one of those before.",
		DRAGONFRUIT_COOKED = "It tastes like maple syrup.",
		DRAGONFRUIT_SEEDS = "Maybe I can grow more.",
		DRAGONPIE = "Almost as good as butter tarts!",
		DRUMSTICK = "October food.",
		DRUMSTICK_COOKED = "Thanks, turkey.",
		DUG_BERRYBUSH = "Time for a little landscaping.",
		DUG_BERRYBUSH_JUICY = "This would be more useful somewhere else, eh?",
		DUG_GRASS = "It makes my eyes water.",
		DUG_MARSH_BUSH = "I should plant this.",
		DUG_SAPLING = "Mmmmm. It's all twiggy.",
		DURIAN = "It smells bad.",
		DURIAN_COOKED = "It smells even worse.",
		DURIAN_SEEDS = "Why would I want to grow more of those things?",
		EARMUFFSHAT = "Where I'm from these'd only work in the fall.",
		EGGPLANT = "I bet the birds have something to do with this.",
		EGGPLANT_COOKED = "Suspiciously birdy.",
		EGGPLANT_SEEDS = "Hmmm. I'm not sure.",
		
		ENDTABLE = 
		{
			BURNT = "A burnt wood table.",
			GENERIC = "A little bit of nature makes everything nicer.",
			EMPTY = "Such a beaut of a wood table shouldn't be hidden by a cloth.",
			WILTED = "Well, that's that.",
			FRESHLIGHT = "Aboot time we brightened this place up, eh?",
			OLDLIGHT = "We need bulbs, eh.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE = 
		{
			BURNING = "Nooo! I could have chopped it!",
			BURNT = "What a waste.",
			CHOPPED = "Ahhhh!",
			POISON = "You're due for a chopping.",
			GENERIC = "It's calling to me!",
		},
		ACORN = "I should grow it and then chop it down!",
        ACORN_SAPLING = "Here comes a tree!",
		ACORN_COOKED = "What a waste of a perfectly good tree.",
		BIRCHNUTDRAKE = "I'll chop you too!",
		EVERGREEN =
		{
			BURNING = "Nooo! I could have chopped it!",
			BURNT = "What a waste.",
			CHOPPED = "Ahhhh!",
			GENERIC = "It's calling to me!",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Sorry!",
			BURNT = "How terrible!",
			CHOPPED = "Another one!",
			GENERIC = "Lucy would want me to chop it down.",
		},
		TWIGGYTREE = 
		{
			BURNING = "Sorry!",
			BURNT = "How terrible!",
			CHOPPED = "Another one!",
			GENERIC = "Choppin's choppin'.",			
			DISEASED = "It's caught a bit of a bug.",
		},
		TWIGGY_NUT_SAPLING = "One day it'll make good chopping.",
        TWIGGY_OLD = "I'd be lucky to get two chops out of that thing.",
		TWIGGY_NUT = "With a little care, this could make fer some good choppin'.",
		EYEPLANT = "It needs to mind its own business.",
		INSPECTSELF = "Beard's growing out nicely.",
		FARMPLOT =
		{
			GENERIC = "I prefer larger plants.",
			GROWING = "They'll never reach chopping size.",
			NEEDSFERTILIZER = "I think it needs some poop.",
			BURNT = "If it was a tree farm, I'd be sad.",
		},
		FEATHERHAT = "I want nothing to do with that... thing.",
		FEATHER_CROW = "A gross feather.",
		FEATHER_ROBIN = "A disgusting feather.",
		FEATHER_ROBIN_WINTER = "A stupid feather.",
		FEATHER_CANARY = "A grody feather.",
		FEATHERPENCIL = "The bird murder wasn't even necessary. Heh.",
		FEM_PUPPET = "She's trapped!",
		FIREFLIES =
		{
			GENERIC = "Reminds me of Algonquin park.",
			HELD = "I've got a pocket full of sunshine!",
		},
		FIREHOUND = "Hot hound!",
		FIREPIT =
		{
			EMBERS = "I should go chop some wood for that, eh?",
			GENERIC = "It uses wood.",
			HIGH = "Too much wood, too fast!",
			LOW = "There should be some wood around here somewhere.",
			NORMAL = "Mmmm. Smells woody.",
			OUT = "If only I had some wood.",
		},
		COLDFIREPIT =
		{
			EMBERS = "I should go chop some wood for that, eh?",
			GENERIC = "It uses wood.",
			HIGH = "That's too much wood too fast!",
			LOW = "There should be some wood around here somewhere.",
			NORMAL = "Mmmm. Smells woody.",
			OUT = "If only I had some wood.",
		},
		FIRESTAFF = "I don't trust any sort of magic business.",
		FIRESUPPRESSOR = 
		{	
			ON = "Save the trees!",
			OFF = "Lazy thing.",
			LOWFUEL = "It craves wood.",
		},

		FISH = "Looks like a cod.",
		FISHINGROD = "I should spend some time at the lake.",
		FISHSTICKS = "Elegant dining in a box.",
		FISHTACOS = "Tastes like the sea, eh?",
		FISH_COOKED = "Could use some chips.",
		FLINT = "This could be an axe head.",
		FLOWER = 
		{
            GENERIC = "That's nice.",
            ROSE = "Not very satisfying chopping, that.",
        },
        FLOWER_WITHERED = "Someone's got a brown thumb.",
		FLOWERHAT = "I think wildflowers look nice with my red hair.",
		FLOWER_EVIL = "Something is wrong with that flower.",
		FOLIAGE = "Looks like a salad.",
		FOOTBALLHAT = "Will this give me hockey hair?",
        FOSSIL_PIECE = "Brittle.",
        FOSSIL_STALKER =
        {
			GENERIC = "Still got some work to do, looks like.",
			FUNNY = "Eh... Should we try again, Lucy?",
			COMPLETE = "One hundred percent assembled beastie.",
        },
        STALKER = "It's a walking anatomy lesson.",
        STALKER_ATRIUM = "That fuel stuff's gone to its head.",
        STALKER_MINION = "Ain't no reason for that to exist.",
        THURIBLE = "Someone's trying to give us a leg up.",
        ATRIUM_OVERGROWTH = "It probably said something important. Oh well.",
		FROG =
		{
			DEAD = "Ex-frog.",
			GENERIC = "I don't trust anything that can't decide between air and water.",
			SLEEPING = "It's tired.",
		},
		FROGGLEBUNWICH = "You can really taste the swamp.",
		FROGLEGS = "They're still jumping!",
		FROGLEGS_COOKED = "At least they stopped moving.",
		FRUITMEDLEY = "In syrup!",
		FURTUFT = "Shh! The creature might still be around.", 
		GEARS = "I never could figure these things out.",
		GHOST = "Boo! Ha ha!",
		GOLDENAXE = "It's almost as nice as Lucy.",
		GOLDENPICKAXE = "It's pretty, but it can't chop down trees.",
		GOLDENPITCHFORK = "Welp. I can't unmake it, so...",
		GOLDENSHOVEL = "Time to dig golden holes.",
		GOLDNUGGET = "You can't make a coffee table out of gold.\nWell, maybe you can. But you shouldn't.",
		GRASS =
		{
			BARREN = "I need to poop on it.",
			WITHERED = "Maybe it'd thrive if it was cooler out?",
			BURNING = "I hope that doesn't spread to the trees.",
			GENERIC = "Looks like kindling.",
			PICKED = "It's gone all nubbly.",
			DISEASED = "It's caught a bit of a bug.",
			DISEASING = "Lookin' a bit down.",
		},
		GRASSGEKKO = 
		{
			GENERIC = "Where's the log lizard?",	
			DISEASED = "It's lookin' pretty unhealthy.",
		},
		GREEN_CAP = "I've eaten stranger things in the woods.",
		GREEN_CAP_COOKED = "I don't trust it.",
		GREEN_MUSHROOM =
		{
			GENERIC = "It's a green mushroom.",
			INGROUND = "They have their own schedule.",
			PICKED = "I'll have to be patient.",
		},
		GUNPOWDER = "Never did like this stuff.",
		HAMBAT = "What a waste of good ham.",
		HAMMER = "Everyone makes mistakes, eh?",
		HEALINGSALVE = "Healthiness in goo form.",
		HEATROCK =
		{
			FROZEN = "Brrr! It's frozen.",
			COLD = "It's gone cold, eh?",
			GENERIC = "We call those \"night rocks\" back home.",
			WARM = "It's getting a bit... tepid.",
			HOT = "I could chop all winter with that in my pocket!",
		},
		HOME = "Who's there?",
		HOMESIGN =
		{
			GENERIC = "Is there anything wood can't do?",
            UNWRITTEN = "Let's give our neighbours some guidance.",
			BURNT = "Wood is the best at burning.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "Let the wood guide the way.",
            UNWRITTEN = "Let's give our neighbours some guidance.",
			BURNT = "Wood is the best at burning.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Let the wood guide the way.",
            UNWRITTEN = "Let's give our neighbours some guidance.",
			BURNT = "Wood is the best at burning.",
		},
		HONEY = "Mmmmmm-mmmm. Bee syrup.",
		HONEYCOMB = "The poor bees probably worked their stingers off on this.",
		HONEYHAM = "But it's not a holiday...",
		HONEYNUGGETS = "That's one of my favourite meals!",
		HORN = "I don't know if anyone should put their mouth on that.",
		HOUND = "They'd be good at pulling a sled.",
		HOUNDCORPSE =
		{
			GENERIC = "I don't like the looks of that.",
			BURNING = "It's better this way.",
			REVIVING = "What on earth is happening?!",
		},
		HOUNDBONE = "It's covered with dog spit, eh?",
		HOUNDMOUND = "I know better than to mess with that.",
		ICEBOX = "Ahhhh. Reminds me of home.",
		ICEHAT = "I could chop it if I had to.",
		ICEHOUND = "Arctic hounds?",
		INSANITYROCK =
		{
			ACTIVE = "Where did it go?!",
			INACTIVE = "I don't know how to move that.",
		},
		JAMMYPRESERVES = "Now to find peanut butter.",

		KABOBS = "The stick really adds to the flavour.",
		KILLERBEE =
		{
			GENERIC = "That bee doesn't seem as friendly.",
			HELD = "She's none too pleased with her situation.",
		},
		KNIGHT = "Never did care for horses.",
		KOALEFANT_SUMMER = "He looks tasty.",
		KOALEFANT_WINTER = "They get tastier in the winter.",
		KRAMPUS = "Back off, hoser!",
		KRAMPUS_SACK = "Seems wrong to take someone else's sack.",
		LEIF = "I'm sorry aboot all of those trees!",
		LEIF_SPARSE = "I'm sorry aboot all of those trees!",
		LIGHTER  = "Keep it away from the trees!",
		LIGHTNING_ROD =
		{
			CHARGED = "It's pretty as the Northern lights.",
			GENERIC = "Weather's not going to get the drop on me now.",
		},
		LIGHTNINGGOAT = 
		{
			GENERIC = "That's a nice pair of horns you've got there.",
			CHARGED = "Nice goat, nice goat!",
		},
		LIGHTNINGGOATHORN = "I'm sure the goat didn't need it.",
		GOATMILK = "I think the electricity curdled it.",
		LITTLE_WALRUS = "Why are they so far south?",
		LIVINGLOG = "I want to keep you, and call you \"Frank\".",
		LOG =
		{
			BURNING = "Oh no! Don't put another log on the fire!",
			GENERIC = "It makes it all worthwhile.",
		},
		LUCY = "I love Lucy!",
		LUREPLANT = "Is that meat?",
		LUREPLANTBULB = "It's warm and lumpy.",
		MALE_PUPPET = "Do you need help?",

		MANDRAKE_ACTIVE = "This is the worst thing.",
		MANDRAKE_PLANTED = "It's looking at me.",
		MANDRAKE = "Sorry, little buddy.",

        MANDRAKESOUP = "It's a tiring soup.",
        MANDRAKE_COOKED = "Sorry!",
        MAPSCROLL = "Is it still a map if nothing's on it?",
        MARBLE = "Feels like a government building.",
        MARBLEBEAN = "The magical fruit.",
        MARBLEBEAN_SAPLING = "Well, lookit that. It sprouted.",
        MARBLESHRUB = "Defo can't chop that.",
        MARBLEPILLAR = "Somebody must have built that.",
        MARBLETREE = "Even Lucy can't chop that one down.",
        MARSH_BUSH =
        {
			BURNT = "Well, it's gone now.",
            BURNING = "Foomph!",
            GENERIC = "That's a bramble.",
            PICKED = "Was that worth it?",
        },
        BURNT_MARSH_BUSH = "Done for.",
        MARSH_PLANT = "Plant.",
        MARSH_TREE =
        {
            BURNING = "That's what you get for being spiky!",
            BURNT = "It deserved it.",
            CHOPPED = "It was a hard battle, but I won.",
            GENERIC = "Trees shouldn't fight back!",
        },
        MAXWELL = "Why does he hate me?",
        MAXWELLHEAD = "Just a head, eh?",
        MAXWELLLIGHT = "That's unnatural.",
        MAXWELLLOCK = "Where is the key?",
        MAXWELLTHRONE = "I've seen nicer chairs.",
        MEAT = "Tastes like moose.",
        MEATBALLS = "All the meats!",
        MEATRACK =
        {
            DONE = "That looks done.",
            DRYING = "This is like watching meat dry.",
            DRYINGINRAIN = "This is like watching meat dry... in the rain.",
            GENERIC = "It's all set up. Just add meat.",
            BURNT = "Its usefulness has dried up.",
            DONE_NOTMEAT = "That looks done.",
            DRYING_NOTMEAT = "Watching stuff dry passes for entertainment 'round here.",
            DRYINGINRAIN_NOTMEAT = "Pretty wet out today, eh?",
        },
        MEAT_DRIED = "It tastes like survival.",
        MERM = "What foul sea did that crawl out of?",
        MERMHEAD =
        {
            GENERIC = "Smells like a factory trawler.",
            BURNT = "Amazingly, it smells even worse now.",
        },
        MERMHOUSE =
        {
            GENERIC = "They're not the handiest.",
            BURNT = "Couldn't even build a fireproof house.",
        },
        MINERHAT = "Down deep in a coal mine.",
        MONKEY = "Well then. That's a new one.",
        MONKEYBARREL = "What a fine choice of building material.",
        MONSTERLASAGNA = "This is cat food!",
        FLOWERSALAD = "Healthy, but not very hardy.",
        ICECREAM = "Only after I've chopped enough!",
        WATERMELONICLE = "Wood AND food?!",
        TRAILMIX = "The perfect snack for a day of chopping.",
        HOTCHILI = "Good after a long day of chopping in the cold.",
        GUACAMOLE = "I'm not sure I trust it.",
        MONSTERMEAT = "I'm not hungry enough for that.",
        MONSTERMEAT_DRIED = "I still don't want to eat it.",
        MOOSE = "Whatever it is, it's definitely Canadian.",
        MOOSE_NESTING_GROUND = "Where's the pyromaniac? This needs to burn.",
        MOOSEEGG = "Well, it lays eggs, apparently.",
        MOSSLING = "Feathery moose baby!",
        FEATHERFAN = "A traditional Canadian fan.",
        MINIFAN = "I'm not used to the heat in this place!",
        GOOSE_FEATHER = "Pillowy plumage.",
        STAFF_TORNADO = "I prefer to chop the trees myself.",
        MOSQUITO =
        {
            GENERIC = "That'll take a pint out of me!",
            HELD = "What do I do with this, eh?",
        },
        MOSQUITOSACK = "Blood and guts, eh?",
        MOUND =
        {
            DUG = "Don't be mad!",
            GENERIC = "I should probably leave that alone.",
        },
        NIGHTLIGHT = "What kind of darkness is that?",
        NIGHTMAREFUEL = "All of my fears in liquid form, eh?",
        NIGHTSWORD = "Nightmares can't hurt ya!",
        NITRE = "It's how we built the railway.",
        ONEMANBAND = "I stand on guard for thee!",
        OASISLAKE =
		{
			GENERIC = "That's a whole lotta wet.",
			EMPTY = "There's nothin' but dirt here.",
		},
        PANDORASCHEST = "What's in the box?!",
        PANFLUTE = "I only sing for Lucy.",
        PAPYRUS = "I'd rather chop than write.",
        WAXPAPER = "A good place to spit out your gum.",
        PENGUIN = "Doesn't matter if you're from the Great White North. Still a bird.",
        PERD = "More birds! Why is it always birds?",
        PEROGIES = "I call them \"yum pockets\".",
        PETALS = "I wonder if Lucy would like these.",
        PETALS_EVIL = "They're frowning at me with little evil faces.",
        PHLEGM = "I wouldn't want that in my moustache.",
        PICKAXE = "Almost an axe, but not quite.",
        PIGGYBACK = "Used all the parts of the pig.",
        PIGHEAD =
        {
            GENERIC = "What a waste of good pork.",
            BURNT = "I'd like to complain to the chef. Politely.",
        },
        PIGHOUSE =
        {
            FULL = "It's bacon-stuffed.",
            GENERIC = "A little duct tape would fix that right up.",
            LIGHTSOUT = "Sorry! I'm not peeping, I swear!",
            BURNT = "A mere shell of its former glory.",
        },
        PIGKING = "He's not MY king.",
        PIGMAN =
        {
            DEAD = "Not a pig anymore.",
            FOLLOWER = "We're a team! Yah!",
            GENERIC = "Walking back bacon!",
            GUARD = "That one looks like he means business.",
            WEREPIG = "Happens to the best of us.",
        },
        PIGSKIN = "Bacon with a tail.",
        PIGTENT = "Looks to be some sort of tent.",
        PIGTORCH = "How did they do that without thumbs?",
        PINECONE = "I should grow it and then chop it down!",
        PINECONE_SAPLING = "Here comes a tree!",
        LUMPY_SAPLING = "Shucks, I'm gonna have to chop it again.",
        PITCHFORK = "That really isn't my style.",
        PLANTMEAT = "That's gross!",
        PLANTMEAT_COOKED = "Cooking it didn't help much.",
        PLANT_NORMAL =
        {
            GENERIC = "I wonder what it will be.",
            GROWING = "A watched plant never grows.",
            READY = "Time for grub.",
            WITHERED = "It's got no life left, eh?",
        },
        POMEGRANATE = "That's too fancy for me.",
        POMEGRANATE_COOKED = "This would go good on flapjacks.",
        POMEGRANATE_SEEDS = "Seedy.",
        POND = "I can't swim!",
        POOP = "Don't poop in camp!",
        FERTILIZER = "Poop belongs in a bucket, not on the ground.",
        PUMPKIN = "I don't like to eat things that grow on the ground.",
        PUMPKINCOOKIE = "This will keep me chopping.",
        PUMPKIN_COOKED = "Pies are good.",
        PUMPKIN_LANTERN = "It'd better not tip over.",
        PUMPKIN_SEEDS = "It's a seed.",
        PURPLEAMULET = "The sparkle is gone from the gem.",
        PURPLEGEM = "It's nothing a good chopping wouldn't fix.",
        RABBIT =
        {
            GENERIC = "Dang ground squirrels...",
            HELD = "I'd feel bad eating him.",
        },
        RABBITHOLE =
        {
            GENERIC = "I doubt there are trees down there.",
            SPRING = "Nothing going in or out.",
        },
        RAINOMETER =
        {
            GENERIC = "Rain makes the trees grow.",
            BURNT = "Its knowledge of rain didn't keep it from being burned.",
        },
        RAINCOAT = "For chopping in the rain.",
        RAINHAT = "Always keep a dry head while chopping.",
        RATATOUILLE = "It's like a forest in a bowl.",
        RAZOR = "A true lumberjack never shaves.",
        REDGEM = "I see within it the fiery death of a thousand trees.",
        RED_CAP = "I don't know...",
        RED_CAP_COOKED = "You'd have to be really, really hungry.",
        RED_MUSHROOM =
        {
            GENERIC = "It's a red mushroom.",
            INGROUND = "They have their own schedule.",
            PICKED = "I'll have to be patient.",
        },
        REEDS =
        {
            BURNING = "Fire makes me nervous.",
            GENERIC = "Reeds.",
            PICKED = "They'll be back.",
        },
        RELIC = "I don't plan on fixin' that.",
        RUINS_RUBBLE = "All busted up.",
        RUBBLE = "Broken furniture.",
        RESEARCHLAB =
        {
            GENERIC = "I don't trust all this science stuff.",
            BURNT = "How did it get burned?!",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "This is getting strange.",
            BURNT = "Well, it obeys some basic laws of physics.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "Okay, I kind of get it now.",
            BURNT = "Nope, lost it.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "I like to call it the \"Hat Machine\"!",
            BURNT = "This is why I don't use hat warmers.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "All my buddies could be improved with wood.",
            BURNT = "That's a shame, that.",
        },
        RESURRECTIONSTONE = "I don't know if I should touch that.",
        ROBIN =
        {
            GENERIC = "What a snotty little jerk.",
            HELD = "Don't get comfortable, birdie.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Go fly south or something!",
            HELD = "It's stealing my warmth.",
        },
        ROBOT_PUPPET = "They're trapped!",
        ROCK_LIGHT =
        {
            GENERIC = "It's looking a tad crusty.",
            OUT = "It looks like it could break.",
            LOW = "Needs more... wood?",
            NORMAL = "A fire that needs no wood? Unnn-natural!",
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Some elbow grease'll move those, easy.",
            RAISED = "Can't reach that one.",
        },
        ROCK = "I could break it down if I tried hard enough.",
        PETRIFIED_TREE = "So... senseless.",
        ROCK_PETRIFIED_TREE = "So... senseless.",
        ROCK_PETRIFIED_TREE_OLD = "So... senseless.",
        ROCK_ICE =
        {
            GENERIC = "Home sweet home!",
            MELTED = "Back home, they never melt.",
        },
        ROCK_ICE_MELTED = "Back home, they never melt.",
        ICE = "A tiny reminder of home.",
        ROCKS = "Could make a decent little inukshuk with these.",
        ROOK = "Hmm... does the rook move in a straight line? I forget.",
        ROPE = "Good for holding stuff to other stuff.",
        ROTTENEGG = "One less bird. Good.",
        ROYAL_JELLY = "I'm majestic enough as is.",
        JELLYBEAN = "You can barely taste the bean!",
        SADDLE_BASIC = "Yep, that'll get us there.",
        SADDLE_RACE = "Makes me feel like some sorta woodland nymph, eh?",
        SADDLE_WAR = "Makes me feel like a Mountie.",
        SADDLEHORN = "Puts the critter back to how nature intended.",
        SALTLICK = "My mouth's dry just looking at it.",
        BRUSH = "You could debark a log with this thing.",
		SANITYROCK =
		{
			ACTIVE = "Something is off aboot that rock, eh?",
			INACTIVE = "That makes sense.",
		},
		SAPLING =
		{
			BURNING = "Aw! He barely had a chance!",
			WITHERED = "With this heat it'll never grow to chopping size!",
			GENERIC = "I want to see it grow so I can chop it down.",
			PICKED = "Picking isn't as fun as chopping.",
			DISEASED = "It's caught a bit of a bug.",
			DISEASING = "A poor excuse for wood.",
		},
   		SCARECROW = 
   		{
			GENERIC = "He's doing the world a service.",
			BURNING = "Glad that's not me.",
			BURNT = "Great, now those feathered hosers are gonna run wild.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Oughta put a block of cut stone up there.",
			BLOCK = "I'm really more of a whittler.",
			SCULPTURE = "Hm. Not bad, eh?",
			BURNT = "Back to whittling.",
   		},
        SCULPTURE_KNIGHTHEAD = "That's a heavy lookin' hoser.",
		SCULPTURE_KNIGHTBODY = 
		{
			COVERED = "Once you've seen one weird statue, you've seen'em all.",
			UNCOVERED = "Yikes. Put it back in.",
			FINISHED = "Just needed a little duct tape.",
			READY = "Is stone supposed to move like that?",
		},
        SCULPTURE_BISHOPHEAD = "That doesn't seem right.",
		SCULPTURE_BISHOPBODY = 
		{
			COVERED = "I don't get art. Whattaya think Lucy?",
			UNCOVERED = "Creepy.",
			FINISHED = "Whose bright idea was it to fix this thing?",
			READY = "Is stone supposed to move like that?",
		},
        SCULPTURE_ROOKNOSE = "Just a big hunk of marble, that.",
		SCULPTURE_ROOKBODY = 
		{
			COVERED = "Just a big hunk of stone, as far as I'm concerned.",
			UNCOVERED = "Looks a bit like one of them chargin' hosers.",
			FINISHED = "As if I didn't have enough reasons to hate full moons.",
			READY = "Is stone supposed to move like that?",
		},
        GARGOYLE_HOUND = "That's unfortunate there, buddy.",
        GARGOYLE_WEREPIG = "Hmph. Maybe I don't got it so bad.",
		SEEDS = "Not trees.",
		SEEDS_COOKED = "We call this \"lumberjack surprise\".",
		SEWING_KIT = "I'm pretty good at sewing.",
		SEWING_TAPE = "Makes me feel right at home.",
		SHOVEL = "Dig a hole. Plant a tree!",
		SILK = "Spiders give me the willies.",
		SKELETON = "Sorry, friend.",
		SCORCHED_SKELETON = "Yikes.",
		SKULLCHEST = "That's scary!",
		SMALLBIRD =
		{
			GENERIC = "What do you want?",
			HUNGRY = "It wants something.",
			STARVING = "I think it's starving.",
			SLEEPING = "It's finally asleep.",
		},
		SMALLMEAT = "I wish this were bigger.",
		SMALLMEAT_DRIED = "Just a bite.",
		SPAT = "Reminds me of momma!",
		SPEAR = "It lacks the heft of a good solid axe.",
		SPEAR_WATHGRITHR = "Who needs a spear when you got ol'Luce?",
		WATHGRITHRHAT = "Pretty snappy looking.",
		SPIDER =
		{
			DEAD = "Good!",
			GENERIC = "That's the biggest spider I've ever seen!",
			SLEEPING = "Careful, now, eh?",
		},
		SPIDERDEN = "Holy Mackinaw! Look at that thing!",
		SPIDEREGGSACK = "Why would I want to carry that around?",
		SPIDERGLAND = "I think it's poison.",
		SPIDERHAT = "She's a real beaut, ain't she?",
		SPIDERQUEEN = "You're not MY queen!",
		SPIDER_WARRIOR =
		{
			DEAD = "Great!",
			GENERIC = "They come in yellow now?",
			SLEEPING = "You're snoozin' fer a bruisin'.",
		},
		SPOILED_FOOD = "Aw, it's Diefenbakered.",
        STAGEHAND =
        {
			AWAKE = "I really wish I hadn't seen that.",
			HIDING = "Not my style.",
        },
        STATUE_MARBLE = 
        {
            GENERIC = "Looks pretty fancy.",
            TYPE1 = "She's a real tall one, eh?",
            TYPE2 = "I'm not sure I get it.",
            TYPE3 = "Could make a nice planter outta that.", --bird bath type statue
        },
		STATUEHARP = "You lost your head, eh?",
		STATUEMAXWELL = "I'm gonna make fun of him for this later, eh?",
		STEELWOOL = "That'll put the shine back on yer axe.",
		STINGER = "Ouch! It's pointy.",
		STRAWHAT = "It'll keep the sun off yer head.",
		STUFFEDEGGPLANT = "I'm getting better at cooking.",
		SWEATERVEST = "It's not plaid, but it'll do.",
		REFLECTIVEVEST = "I'm still not convinced plaid isn't all-weather wear.",
		HAWAIIANSHIRT = "I really prefer plaid.",
		TAFFY = "Sugary good.",
		TALLBIRD = "I don't trust birds that can't fly, either.",
		TALLBIRDEGG = "What's in here?",
		TALLBIRDEGG_COOKED = "It tastes like justice.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Too cold for you?",
			GENERIC = "It's hatching.",
			HOT = "Is it crying?",
			LONG = "Birds are never prompt.",
			SHORT = "Anytime now.",
		},
		TALLBIRDNEST =
		{
			GENERIC = "I should steal its egg to teach it a lesson.",
			PICKED = "Nothing there.",
		},
		TEENBIRD =
		{
			GENERIC = "It's growing up to be a jerk, just like its parents.",
			HUNGRY = "Are you ALWAYS hungry?",
			STARVING = "It getting wild with hunger.",
			SLEEPING = "Finally some peace and quiet.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Ready to go, eh?",
			GENERIC = "It's a... magic thing, I think.",
			LOCKED = "There are bits missing, eh?",
			PARTIAL = "It's almost ready, eh?",
		},
		TELEPORTATO_BOX = "Box-y, eh?",
		TELEPORTATO_CRANK = "Crank-y, eh?",
		TELEPORTATO_POTATO = "Potato-y, eh?",
		TELEPORTATO_RING = "Ring-y, eh?",
		TELESTAFF = "I wonder what this thing does.",
		TENT = 
		{
			GENERIC = "I'm used to sleeping in worse.",
			BURNT = "I don't think it can still be considered a tent.",
		},
		SIESTAHUT = 
		{
			GENERIC = "Naps are important during a long day of chopping.",
			BURNT = "It's a husk.",
		},
		TENTACLE = "There a squid down there?",
		TENTACLESPIKE = "It wobbles when you wave it.",
		TENTACLESPOTS = "I'm blushing!",
		TENTACLE_PILLAR = "It's so big!",
        TENTACLE_PILLAR_HOLE = "Not even a stump left behind!",
		TENTACLE_PILLAR_ARM = "Are those squid babies?",
		TENTACLE_GARDEN = "I'm tired of these squids!",
		TOPHAT = "It's too fancy.",
		TORCH = "Trees by torchlight.",
		TRANSISTOR = "I won't even pretend to know how that works.",
		TRAP = "Work smarter, eh?",
		TRAP_TEETH = "This seems a bit rough.",
		TRAP_TEETH_MAXWELL = "That's not playing fair, eh?",
		TREASURECHEST = 
		{
			GENERIC = "Wood is so handy! Look at all the things you can make!",
			BURNT = "I guess wood does have a downside...",
		},
		TREASURECHEST_TRAP = "Something is not quite right aboot that chest.",
		SACRED_CHEST = 
		{
			GENERIC = "It makes my beard hair stand on end.",
			LOCKED = "It's thinkin' real hard.",
		},
		TREECLUMP = "You're asking for a good chop, bud.",
		
		TRINKET_1 = "I used to play that game.", --Melted Marbles
		TRINKET_2 = "Much kazoo aboot nothing.", --Fake Kazoo
		TRINKET_3 = "Reminds me of a story I heard once.", --Gord's Knot
		TRINKET_4 = "Wolfgang would appreciate that moustache.", --Gnome
		TRINKET_5 = "It needs a robot arm, eh?", --Toy Rocketship
		TRINKET_6 = "They're not good any more, eh?", --Frazzled Wires
		TRINKET_7 = "'Might take it to the kid.", --Ball and Cup
		TRINKET_8 = "Reminds me... gotta convince Willow to take a *real* bath.", --Rubber Bung
		TRINKET_9 = "I just sew my clothing shut around me when I put it on.", --Mismatched Buttons
		TRINKET_10 = "Choppers for old folks.", --Dentures
		TRINKET_11 = "Quiet, you!", --Lying Robot
		TRINKET_12 = "It's all withered.", --Dessicated Tentacle
		TRINKET_13 = "She looks friendly.", --Gnomette
		TRINKET_14 = "Gaudy as all get-out.", --Leaky Teacup
		TRINKET_15 = "And here I am just a pawn, eh?", --Pawn
		TRINKET_16 = "And here I am just a pawn, eh?", --Pawn
		TRINKET_17 = "It needs to be straightened, eh?", --Bent Spork
		TRINKET_18 = "I would have liked this when I was a boy.", --Trojan Horse
		TRINKET_19 = "It keeps falling over, eh?", --Unbalanced Top
		TRINKET_20 = "Wigfrid keeps using it to \"spar\" with me and Lucy. We're afraid.", --Backscratcher
		TRINKET_21 = "It belongs in a kitchen, not in the woods.", --Egg Beater
		TRINKET_22 = "I'd rather have some proper rope.", --Frayed Yarn
		TRINKET_23 = "Maxwell probably needs that for his fancy shoes.", --Shoehorn
		TRINKET_24 = "We should whip up some pumpkin cookies to put in it, eh?", --Lucky Cat Jar
		TRINKET_25 = "I already smell like pine and woodchips, according to Lucy.", --Air Unfreshener
		TRINKET_26 = "Genius! A cup for a proper woodsman.", --Potato Cup
		TRINKET_27 = "No point hanging clothes in the woods.", --Coat Hanger
		TRINKET_28 = "That one moves diagonally, I think.", --Rook
        TRINKET_29 = "That's, uh, the rook piece.", --Rook
        TRINKET_30 = "That one can only move one square at time.", --Knight
        TRINKET_31 = "That's the, uh, horse piece.", --Knight
        TRINKET_32 = "I'd rather my future be a surprise.", --Cubic Zirconia Ball
        TRINKET_33 = "Creepy.", --Spider Ring
        TRINKET_34 = "That right there's a bad time waitin' to happen.", --Monkey Paw
        TRINKET_35 = "Doesn't even have a label.", --Empty Elixir
        TRINKET_36 = "More intimidating than beaver teeth.", --Faux fangs
        TRINKET_37 = "What a waste of wood, eh?", --Broken Stake
        TRINKET_38 = "Looks like a pair of binoculars.", -- Binoculars Griftlands trinket
        TRINKET_39 = "Oh, the gloves're comin' off now!", -- Lone Glove Griftlands trinket
        TRINKET_40 = "It's a snail-shaped scale, eh?", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Got no idea what that's for.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Better than meeting a real one, eh?", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Get along, lil gator.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Smashed to bits.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "What sorta shows d'you think it gets?", -- Odd Radio ONI trinket
        TRINKET_46 = "I prefer to let mine air dry.", -- Hairdryer ONI trinket
        
        HALLOWEENCANDY_1 = "Even the stick is delicious.",
        HALLOWEENCANDY_2 = "Don't worry, I'll eat enough for the both of us, Lucy.",
        HALLOWEENCANDY_3 = "Just a regular ol' cob of corn.",
        HALLOWEENCANDY_4 = "Yeesh. That's a lot of candy legs.",
        HALLOWEENCANDY_5 = "These ones don't puke. I like 'em.",
        HALLOWEENCANDY_6 = "Not sure that's food, eh?",
        HALLOWEENCANDY_7 = "Eh. I don't mind 'em.",
        HALLOWEENCANDY_8 = "I'll tell you what it tastes like, Lucy.",
        HALLOWEENCANDY_9 = "Not too bad, eh?",
        HALLOWEENCANDY_10 = "I'll tell you what it tastes like, Lucy.",
        HALLOWEENCANDY_11 = "Melts in your mouth, not in your hand.",
        HALLOWEENCANDY_12 = "Not the biggest fan of bugs.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "It's pretty good stuff.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Lucy doesn't like it when I eat spice.", --Hot Lava pepper candy
        CANDYBAG = "That there bag could hold a whole heap of candy.",

		HALLOWEEN_ORNAMENT_1 = "It's just fake, eh.",
		HALLOWEEN_ORNAMENT_2 = "That's nice. I should hang it somewhere.",
		HALLOWEEN_ORNAMENT_3 = "This would look good in a tree somewhere.", 
		HALLOWEEN_ORNAMENT_4 = "You wanna decorate, Lucy?",
		HALLOWEEN_ORNAMENT_5 = "Hang in there, eh.",
		HALLOWEEN_ORNAMENT_6 = "Argh! I'd sure like to hang a real one like that.", 

		HALLOWEENPOTION_DRINKS_WEAK = "Not bad.",
		HALLOWEENPOTION_DRINKS_POTENT = "That's a lot, eh.",
        HALLOWEENPOTION_BRAVERY = "A good hardy drink.",
		HALLOWEENPOTION_FIRE_FX = "It'll never replace a good hunk of wood.", 
		MADSCIENCE_LAB = "I prefer simpler things.",
		LIVINGTREE_ROOT = "Hey there's a piece of wood in there.", 
		LIVINGTREE_SAPLING = "Yep. That'll be a fine tree one day.",

        DRAGONHEADHAT = "That's a sight, eh?",
        DRAGONBODYHAT = "Nice needlework.",
        DRAGONTAILHAT = "Well, somebody's gotta do it.",
        PERDSHRINE =
        {
            GENERIC = "I'm not giving anything to those birds!",
            EMPTY = "Could use a touch of green.",
            BURNT = "It's all burnt up.",
        },
        REDLANTERN = "This little light of mine.",
        LUCKY_GOLDNUGGET = "I could use a bit of luck.",
        FIRECRACKERS = "Let's not set them off in the forest.",
        PERDFAN = "It had to be birds, didn't it?",
        REDPOUCH = "It's Lucy-colour.",
        WARGSHRINE = 
        {
            GENERIC = "Nice and toasty.",
            EMPTY = "Gotta warm this doghouse up, eh?",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Burned up.",
        },
        CLAYWARG = 
        {
        	GENERIC = "Look at the size of you.",
        	STATUE = "Wonder where that sculpture came from.",
        },
        CLAYHOUND = 
        {
        	GENERIC = "Earth hounds!",
        	STATUE = "Someone carved each individual hair.",
        },
        HOUNDWHISTLE = "I usually do my own animal calls.",
        CHESSPIECE_CLAYHOUND = "All the dog, none of the smell.",
        CHESSPIECE_CLAYWARG = "Not a wood sculpture, but it'll do.",

		PIGSHRINE =
		{
            GENERIC = "Would ya look at that.",
            EMPTY = "I think it needs meat, Lucy.",
            BURNT = "Burnt.",
		},
		PIG_TOKEN = "Looks like something those pigs would make.",
		YOTP_FOOD1 = "Want some, Lucy?",
		YOTP_FOOD2 = "Doesn't look to appetizing. Sorry.",
		YOTP_FOOD3 = "I don't need nothin' fancy.",

		PIGELITE1 = "Looks a little blue.", --BLUE
		PIGELITE2 = "Too hot-headed if you ask me.", --RED
		PIGELITE3 = "Sure likes that gold.", --WHITE
		PIGELITE4 = "Something aboot that guy I like.", --GREEN

		BISHOP_CHARGE_HIT = "Hey now!",
		TRUNKVEST_SUMMER = "Nice and breezy.",
		TRUNKVEST_WINTER = "This could stand up to the winters back home, eh?",
		TRUNK_COOKED = "I think it boiled off all of the nose cheese.",
		TRUNK_SUMMER = "It's pretty thin.",
		TRUNK_WINTER = "It's thick and hairy.",
		TUMBLEWEED = "I wish it was sturdier so I could chop it.",
		TURKEYDINNER = "Turkey day is here again!",
		TWIGS = "I should build a tiny axe to chop these.",
		UMBRELLA = "Something like that'd keep my beard dry, eh?",
		GRASS_UMBRELLA = "That there could keep my beard moderately dry, eh?",
		UNIMPLEMENTED = "It doesn't look safe.",
		WAFFLES = "I prefer flapjacks.",
		WALL_HAY = 
		{	
			GENERIC = "You could sneeze it down.",
			BURNT = "Well, that escalated quickly.",
		},
		WALL_HAY_ITEM = "I could sneeze it apart.",
		WALL_STONE = "Safe and secure, eh?",
		WALL_STONE_ITEM = "Safe and secure, eh?",
		WALL_RUINS = "Crumbling, but still secure, eh?",
		WALL_RUINS_ITEM = "Heh, stoned again, eh?",
		WALL_WOOD = 
		{
			GENERIC = "I like the look of that!",
			BURNT = "I miss the old you.",
		},
		WALL_WOOD_ITEM = "I like the look of that!",
		WALL_MOONROCK = "Looks nice'n'sturdy.",
		WALL_MOONROCK_ITEM = "It's not much use like that.",
		FENCE = "That's a good lookin' fence.",
        FENCE_ITEM = "A good project for a lazy afternoon.",
        FENCE_GATE = "Some nice woodwork there.",
        FENCE_GATE_ITEM = "A good project for a lazy afternoon.",
		WALRUS = "Oh no. Walruses again!",
		WALRUSHAT = "My granddad wore a hat like that.",
		WALRUS_CAMP =
		{
			EMPTY = "This won't be safe come winter.",
			GENERIC = "Walruses are nearby, eh?",
		},
		WALRUS_TUSK = "He had a cavity, eh?",
		WARDROBE = 
		{
			GENERIC = "It's hard to stay neat and tidy in the woods.",
            BURNING = "Wood is the best at burning.",
			BURNT = "Not so useful now, eh?",
		},
		WARG = "That thing could pull a sled by its lonesome.",
		WASPHIVE = "Why are those bees so angry?",
		WATERBALLOON = "Could be fun times lobbin' these around.",
		WATERMELON = "How can it be both water and melon?",
		WATERMELON_COOKED = "I'm not sure aboot grilled fruit...",
		WATERMELONHAT = "Well, points for creativity.",
		WAXWELLJOURNAL = "Trees made into... paper? How unholy!",
		WETGOOP = "Better than some of the things I've eaten!",
        WHIP = "I hope that doesn't end up hurtin' any lil critters.",
		WINTERHAT = "It's a nice toque, eh?",
		WINTEROMETER = 
		{
			GENERIC = "We can build these half as tall back home.",
			BURNT = "The ones from home don't burn.",
		},

        WINTER_TREE =
        {
            BURNT = "Too bad. Made the place feel real cozy.",
            BURNING = "Such senseless violence.",
            CANDECORATE = "Must... not chop...",
            YOUNG = "All holidays should revolve around trees.",
        },
		WINTER_TREESTAND = 
		{
			GENERIC = "I'm sure I have an extra pine cone somewhere.",
            BURNT = "Too bad. Made the place feel real cozy.",
		},
        WINTER_ORNAMENT = "For hanging on the unchopped tree with care.",
        WINTER_ORNAMENTLIGHT = "What do you think, Lucy? Decorate, or chop?",
        WINTER_ORNAMENTBOSS = "Y'know, I do believe that was worth it.",
		WINTER_ORNAMENTFORGE = "Kinda familiar eh, Lucy?",
		WINTER_ORNAMENTGORGE = "That's nice.",

        WINTER_FOOD1 = "It's a gingerbread lumberjack.", --gingerbread cookie
        WINTER_FOOD2 = "Always had a soft spot for a good holiday cookie.", --sugar cookie
        WINTER_FOOD3 = "Satisfies the sweet tooth.", --candy cane
        WINTER_FOOD4 = "That thing just ain't right.", --fruitcake
        WINTER_FOOD5 = "All the taste and none of the splinters!", --yule log cake
        WINTER_FOOD6 = "Hard to complain aboot this whole \"Feast\" business.", --plum pudding
        WINTER_FOOD7 = "Doesn't fall far from the cider tree.", --apple cider
        WINTER_FOOD8 = "Perfect for drinking next to a good fire, eh?", --hot cocoa
        WINTER_FOOD9 = "Psst, Lucy. Do I have a 'nog moustache?", --eggnog

        KLAUS = "Thing's got no eyes, eh?",
        KLAUS_SACK = "Something good's in there, eh?",
		KLAUSSACKKEY = "Gotta be some use for that.",
		WORMHOLE =
		{
			GENERIC = "That looks like a bum!",
			OPEN = "I'm not sure I want to look at that, eh?",
		},
		WORMHOLE_LIMITED = "It smells a bit off, eh?",
		ACCOMPLISHMENT_SHRINE = "It seems a bit show-offy to me.",        
		LIVINGTREE = "I feel conflicted, eh?",
		ICESTAFF = "It reminds me of home.",
		REVIVER = "I need to share this with somebody!",
		SHADOWHEART = "Yeesh. Don't get that near me.",
        ATRIUM_RUBBLE = 
        {
			LINE_1 = "It's an old drawing of strange creatures.",
			LINE_2 = "Nothin' of interest left here.",
			LINE_3 = "Black muck is covering everything in this drawing.",
			LINE_4 = "Don't look at this one, Lucy.",
			LINE_5 = "Looks like a bustling city.",
		},
        ATRIUM_STATUE = "Was it supposed to be holding something?",
        ATRIUM_LIGHT = 
        {
			ON = "What a nightmare.",
			OFF = "Gotta be a way to turn it on.",
		},
        ATRIUM_GATE =
        {
			ON = "That oughta do it.",
			OFF = "Where d'you think it goes, Lucy?",
			CHARGING = "It's soaking up energy, hey?",
			DESTABILIZING = "That'd be my cue to leave.",
			COOLDOWN = "Don't wanna overdo it.",
        },
        ATRIUM_KEY = "Got it from that big bony hoser.",
		LIFEINJECTOR = "This should cure those sniffles.",
		SKELETON_PLAYER =
		{
			MALE = "Poor %s. %s got him, eh?",
			FEMALE = "Poor %s. %s got her, eh?",
			ROBOT = "Poor %s. %s got them, eh?",
			DEFAULT = "Poor %s. I should watch out for %s, eh?",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "It's uh, a moon rock.",
		MOONROCKNUGGET = "It's uh, a moon rock.",
		MOONROCKCRATER = "I think it's missing something.",
		MOONROCKSEED = "I should probably put this down somewhere, eh?",

        REDMOONEYE = "A true woodsman knows his own way around the forest.",
        PURPLEMOONEYE = "A pretty useful guide in this neck of the woods.",
        GREENMOONEYE = "That should help everyone get the lay of the land.",
        ORANGEMOONEYE = "Makes the hairs on the back of my neck stand up.",
        YELLOWMOONEYE = "It's rude to stare.",
        BLUEMOONEYE = "It sees all with the cold sight of the North.",

        --Arena Event
        LAVAARENA_BOARLORD = "He seems confused, eh?",
        BOARRIOR = "Tough guy, eh?",
        BOARON = "I feel bad beatin' up such a little thing.",
        PEGHOOK = "That acid'll be a problem, eh?",
        TRAILS = "Mighty powerful right hook on that hoser.",
        TURTILLUS = "Gotta keep that one from hiding, eh?",
        SNAPPER = "Keep them chompers to yourself.",
		RHINODRILL = "They really like bumping chests like that, eh?",
		BEETLETAUR = "Gotta chop that armor up.",

        LAVAARENA_PORTAL = 
        {
            ON = "Let's head back to camp, Lucy.",
            GENERIC = "Don't trust that as far as I can throw it.",
        },
        LAVAARENA_KEYHOLE = "Needs another piece.",
		LAVAARENA_KEYHOLE_FULL = "Looks good.",
        LAVAARENA_BATTLESTANDARD = "Let's chop that Battle Standard!",
        LAVAARENA_SPAWNER = "Better keep an eye on that.",

        HEALINGSTAFF = "Someone else'd put that to better use.",
        FIREBALLSTAFF = "I'll leave it to someone more magic-inclined.",
        HAMMER_MJOLNIR = "Packs a wallop.",
        SPEAR_GUNGNIR = "I'd take a stab at it.",
        BLOWDART_LAVA = "I'm not much of a shot.",
        BLOWDART_LAVA2 = "Someone else'll make better use of it.",
        LAVAARENA_LUCY = "Something's different aboot you, Lucy.",
        WEBBER_SPIDER_MINION = "Better small spiders than big, I suppose.",
        BOOK_FOSSIL = "I'm leaving that to the experts.",
		LAVAARENA_BERNIE = "Hey there little fella.",
		SPEAR_LANCE = "I could give it a whirl.",
		BOOK_ELEMENTAL = "I'd rather stick with my axe, thanks.",
		LAVAARENA_ELEMENTAL = "What an odd little fellow.",

   		LAVAARENA_ARMORLIGHT = "Won't do anyone much good.",
		LAVAARENA_ARMORLIGHTSPEED = "Does nothing fast.",
		LAVAARENA_ARMORMEDIUM = "Better wood armor than nothin'.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Looks sharp, eh?",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Good for a little recharge.",
		LAVAARENA_ARMORHEAVY = "Looks pretty safe, eh?",
		LAVAARENA_ARMOREXTRAHEAVY = "No one'd push you around in that.",

		LAVAARENA_FEATHERCROWNHAT = "I don't think agility is my thing, eh?",
        LAVAARENA_HEALINGFLOWERHAT = "That flower'd look nice with my beard.",
        LAVAARENA_LIGHTDAMAGERHAT = "I'd swing an axe a little harder with that.",
        LAVAARENA_STRONGDAMAGERHAT = "I could do some real damage with that.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "I oughta leave that for someone else.",
        LAVAARENA_EYECIRCLETHAT = "I don't see much use for that.",
        LAVAARENA_RECHARGERHAT = "They're reinvigorating rocks.",
        LAVAARENA_HEALINGGARLANDHAT = "That'll make ya quick on yer feet.",
        LAVAARENA_CROWNDAMAGERHAT = "Get a loada that hat!",

		LAVAARENA_ARMOR_HP = "Better armor up.",

		LAVAARENA_FIREBOMB = "I'll leave that for someone else.",
		LAVAARENA_HEAVYBLADE = "I could use that.",

        --Quagmire
        QUAGMIRE_ALTAR = 
        {
        	GENERIC = "We gotta load it up with good eats.",
        	FULL = "It hasn't finished the food we gave it.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "I'm not huge on art.",
		QUAGMIRE_PARK_FOUNTAIN = "This fountain's really old.",
		
        QUAGMIRE_HOE = "It's a farmer's life for me.",
        
        QUAGMIRE_TURNIP = "From the community garden.",
        QUAGMIRE_TURNIP_COOKED = "Cooked real nice.",
        QUAGMIRE_TURNIP_SEEDS = "Looks like new crop seeds to me.",
        
        QUAGMIRE_GARLIC = "Homegrown.",
        QUAGMIRE_GARLIC_COOKED = "Lucy helped.",
        QUAGMIRE_GARLIC_SEEDS = "Looks like new crop seeds to me.",
        
        QUAGMIRE_ONION = "I only cry tears of joy.",
        QUAGMIRE_ONION_COOKED = "Perfectly roasted.",
        QUAGMIRE_ONION_SEEDS = "Looks like new crop seeds to me.",
        
        QUAGMIRE_POTATO = "I love good local produce.",
        QUAGMIRE_POTATO_COOKED = "It cooked up real nice.",
        QUAGMIRE_POTATO_SEEDS = "Looks like new crop seeds to me.",
        
        QUAGMIRE_TOMATO = "That's a nice looking tomato.",
        QUAGMIRE_TOMATO_COOKED = "Heartburn city.",
        QUAGMIRE_TOMATO_SEEDS = "Looks like new crop seeds to me.",
        
        QUAGMIRE_FLOUR = "Don't look like no flower to me.",
        QUAGMIRE_WHEAT = "Such a fancy shade of gold.",
        QUAGMIRE_WHEAT_SEEDS = "Looks like new crop seeds to me.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Looks like new crop seeds to me.",
        
        QUAGMIRE_ROTTEN_CROP = "The soil ain't right here.",
        
		QUAGMIRE_SALMON = "Need a good cedar plank to cook it on.",
		QUAGMIRE_SALMON_COOKED = "Tastes like home.",
		QUAGMIRE_CRABMEAT = "That'll cook up real good.",
		QUAGMIRE_CRABMEAT_COOKED = "I wouldn't mind a taste of that.",
        QUAGMIRE_POT = "What do ya wanna make, Lucy?",
        QUAGMIRE_POT_SMALL = "I only know a handful of recipes, but I'm real good at them.",
        QUAGMIRE_POT_HANGER_ITEM = "Gotta hang the pot on the fire somehow.",
		QUAGMIRE_SUGARWOODTREE = 
		{
			GENERIC = "It's beautiful!",
			STUMP = "Cut down in its prime.",
			TAPPED_EMPTY = "Fillin' up, slow as molasses.",
			TAPPED_READY = "Thanks for the sap, tree.",
			TAPPED_BUGS = "Hey, get away from that tree will ya!",
			WOUNDED = "What troubles you, sister?",
		},
		QUAGMIRE_SPOTSPICE_SHRUB = 
		{
			GENERIC = "Looks real flavourful.",
			PICKED = "That's been picked already.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "It makes my fingers smell like pepper.",
		QUAGMIRE_SPOTSPICE_GROUND = "You only need a pinch to get the flavour.",
		QUAGMIRE_SAPBUCKET = "Didn't I tell everybody trees were delicious?",
		QUAGMIRE_SAP = "Tree sap. From a tree.",
		QUAGMIRE_SALT_RACK =
		{
			READY = "It's ready.",
			GENERIC = "Gonna be a bit longer.",
		},
		
		QUAGMIRE_POND_SALT = "Wouldn't wanna swim in it, that's fer sure.",
		QUAGMIRE_SALT_RACK_ITEM = "Gotta set'er up.",

		QUAGMIRE_SAFE = 
		{
			GENERIC = "No one'll miss it.",
			LOCKED = "Locked tight.",
		},

		QUAGMIRE_KEY = "Think it's for a safe.",
		QUAGMIRE_KEY_PARK = "Oh beauty, now we can open the gate.",
        QUAGMIRE_PORTAL_KEY = "Looks important.",

		
		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Those mushrooms look mighty tasty.",
			PICKED = "Thank you for your sacrifice, tree.",
		},
		QUAGMIRE_MUSHROOMS = "We're gonna eat you.",
        QUAGMIRE_MEALINGSTONE = "We just gotta grind and bear it.",
		QUAGMIRE_PEBBLECRAB = "I don't see any reason to bother the poor fella.",

		
		QUAGMIRE_RUBBLE_CARRIAGE = "Huh. Wonder what happened here?",
        QUAGMIRE_RUBBLE_CLOCK = "Is that the right time?",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Kinda scary, eh?",
        QUAGMIRE_RUBBLE_PUBDOOR = "Such a shame.",
        QUAGMIRE_RUBBLE_ROOF = "That doesn't look right.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "That's a shame.",
        QUAGMIRE_RUBBLE_BIKE = "It's not gonna work like that.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Somethin' happened here, Lucy.",
            "I wonder what they did wrong.",
            "Gotta be pretty angry to destroy someone's home.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Nothing left of a fireplace.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Too bad, eh?",
        QUAGMIRE_MERMHOUSE = "Those scaly folks live in there.",
        QUAGMIRE_SWAMPIG_HOUSE = "Home sweet home, eh?",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Just rocks, now.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Every society's gotta have a leader, I guess.",
            SLEEPING = "It's getting some shut-eye.",
        },
        QUAGMIRE_SWAMPIG = "They seem like an alright sort.",
        
        QUAGMIRE_PORTAL = "Looks like we're going nowhere fast, Lucy.",
        QUAGMIRE_SALTROCK = "Maybe I could chop it into smaller bits.",
        QUAGMIRE_SALT = "It's salty.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Heh, whoops.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "I'd say it looks good enough to offer.",
            MISMATCH = "I don't think it wants this.",
            MATCH = "Yep. That's what it wants.",
            MATCH_BUT_SNACK = "Is this gonna be enough food?",
        },
        
        QUAGMIRE_FERN = "Fresh underbrush.",
        QUAGMIRE_FOLIAGE_COOKED = "Probably won't taste great on its own.",
        QUAGMIRE_COIN1 = "This coin could use a polish.",
        QUAGMIRE_COIN2 = "I'm gonna buy something nice for Lucy.",
        QUAGMIRE_COIN3 = "Not a Looney but I guess it works around here.",
        QUAGMIRE_COIN4 = "Nothin' like being owed a favour.",
        QUAGMIRE_GOATMILK = "Builds your bones.",
        QUAGMIRE_SYRUP = "Not quite maple.",
        QUAGMIRE_SAP_SPOILED = "That's a shame, eh?",
        QUAGMIRE_SEEDPACKET = "This will keep us busy for a while.",
        
        QUAGMIRE_POT = "What do ya wanna make, Lucy?",
        QUAGMIRE_POT_SMALL = "I only know a handful of recipes, but I'm real good at them.",
        QUAGMIRE_POT_SYRUP = "You have to have sap to make syrup.",
        QUAGMIRE_POT_HANGER = "It's all set up.",
        QUAGMIRE_POT_HANGER_ITEM = "Gotta hang the pot on the fire somehow.",
        QUAGMIRE_GRILL = "Ready for the May two-four.",
        QUAGMIRE_GRILL_ITEM = "Better set this up.",
        QUAGMIRE_GRILL_SMALL = "Wanna BBQ, Lucy?",
        QUAGMIRE_GRILL_SMALL_ITEM = "Better set this up.",
        QUAGMIRE_OVEN = "That better not run on trees.",
        QUAGMIRE_OVEN_ITEM = "Be careful around that fire, Lucy.",
        QUAGMIRE_CASSEROLEDISH = "It's good for the oven.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "I'll just make something small.",
        QUAGMIRE_PLATE_SILVER = "Kinda fancy eh, Lucy?",
        QUAGMIRE_BOWL_SILVER = "That's a fancy way to eat.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",
        
        QUAGMIRE_MERM_CART1 = "What's for sale today?", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Need some supplies, Lucy?", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Not as pretty as Lucy.",
        QUAGMIRE_PARK_ANGEL2 = "To each his own.",
        QUAGMIRE_PARK_URN = "Aw. Sorry, eh.",
        QUAGMIRE_PARK_OBELISK = "A fine monument to something.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "In we go.",
            LOCKED = "We need a key to open it.",
        },
        QUAGMIRE_PARKSPIKE = "Yeesh.",
        QUAGMIRE_CRABTRAP = "Let's trap some crabs.",
        QUAGMIRE_TRADER_MERM = "Hey there!",
        QUAGMIRE_TRADER_MERM2 = "How ya doin'?",
        
        QUAGMIRE_GOATMUM = "We're in for a baa'd time.",
        QUAGMIRE_GOATKID = "How ya doing, kid?",
        QUAGMIRE_PIGEON =
        {
            DEAD = "It ain't living no more.",
            GENERIC = "It's a filthy pigeon.",
            SLEEPING = "It's getting some shut-eye.",
        },
        QUAGMIRE_LAMP_POST = "It don't have an off switch.",

        QUAGMIRE_BEEFALO = "Take it easy, eh?",
        QUAGMIRE_SLAUGHTERTOOL = "No use gettin' Lucy dirty.",

        QUAGMIRE_SAPLING = "It's not growing back.",
        QUAGMIRE_BERRYBUSH = "No more berries.",

        QUAGMIRE_ALTAR_STATUE2 = "Sure are a lot of statues around here.",
        QUAGMIRE_ALTAR_QUEEN = "That must have taken some time to make.",
        QUAGMIRE_ALTAR_BOLLARD = "Can't chop that.",
        QUAGMIRE_ALTAR_IVY = "Pretty enough.",

        QUAGMIRE_LAMP_SHORT = "Just wastes electricity.",

        --v2 Winona
        WINONA_CATAPULT = 
        {
        	GENERIC = "Looks kinda fun if I'm honest.",
        	OFF = "Does it look like it's working, Lucy?",
        	BURNING = "Woah! Careful, Lucy!",
        	BURNT = "That's a right shame.",
        },
        WINONA_SPOTLIGHT = 
        {
        	GENERIC = "Fine, as long as it don't start no forest fires.",
        	OFF = "Does it look like it's working, Lucy?",
        	BURNING = "Woah! Careful, Lucy!",
        	BURNT = "That's a right shame.",
        },
        WINONA_BATTERY_LOW = 
        {
        	GENERIC = "Looks like Winona's work.",
        	LOWPOWER = "Just aboot dead.",
        	OFF = "Plum tuckered.",
        	BURNING = "Woah! Careful, Lucy!",
        	BURNT = "That's a right shame.",
        },
        WINONA_BATTERY_HIGH = 
        {
        	GENERIC = "Pretty odd looking gadget there.",
        	LOWPOWER = "Just aboot dead.",
        	OFF = "Plum tuckered.",
        	BURNING = "Woah! Careful, Lucy!",
        	BURNT = "That's a right shame.",
        },

        --Wormwood
        COMPOSTWRAP = "Well. Plants gotta fertilize.",
        ARMOR_BRAMBLE = "All natural safety precautions.",
        TRAP_BRAMBLE = "A trap for the forest, by the forest.",

        BOATFRAGMENT03 = "Waste of good wood.",
        BOATFRAGMENT04 = "Waste of good wood.",
        BOATFRAGMENT05 = "Waste of good wood.",
		BOAT_LEAK = "Better plug that up soon or we'll be swimmin'.",
        MAST = "Must... not... chop...!",
        SEASTACK = "It's a sea stack.",
        FISHINGNET = "I cast a wide net.",
        ANTCHOVIES = "They just ain't right.",
        STEERINGWHEEL = "I like to know where I'm going.",
        ANCHOR = "Real heavy one there.",
        BOATPATCH = "This'll fix her right up.",
        DRIFTWOOD_TREE = 
        {
            BURNING = "Hasn't it been through enough.",
            BURNT = "It's over now.",
            CHOPPED = "Put it out of its misery.",
            GENERIC = "The sea sucked all the good tree juice out of it.",
        },

        DRIFTWOOD_LOG = "You poor log.",

        MOON_TREE = 
        {
            BURNING = "Yeesh, that's a big blaze.",
            BURNT = "It burnt down, eh?",
            CHOPPED = "I might have chopped more than once.",
            GENERIC = "Measure twice, chop once.",
        },
		MOON_TREE_BLOSSOM = "That's an awfully pretty blossom.",

        MOONBUTTERFLY = 
        {
        	GENERIC = "Pixie dust tickles my nose.",
        	HELD = "I sure do like nature.",
        },
		MOONBUTTERFLYWINGS = "Fancy butterfly wings.",
        MOONBUTTERFLY_SAPLING = "Welcome to the world.",
        ROCK_AVOCADO_FRUIT = "Too hard to eat, but at least it smells nice.",
        ROCK_AVOCADO_FRUIT_RIPE = "I think I could sink my teeth into it now.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Wish I had some toast.",
        ROCK_AVOCADO_FRUIT_SPROUT = "Guess we didn't eat that one in time.",
        ROCK_AVOCADO_BUSH = 
        {
        	BARREN = "Ain't got nothing left in it.",
			WITHERED = "It's pretty hot out.",
			GENERIC = "Is that fruit?",
			PICKED = "It's a nondescript bush.",
			DISEASED = "That one might be a goner.",
            DISEASING = "It's smelling a little stinky.",
			BURNING = "Well, that's no good.",
		},
        DEAD_SEA_BONES = "Smells ripe.",
        HOTSPRING = 
        {
        	GENERIC = "Careful Lucy, wouldn't want you to rust.",
        	BOMBED = "Lookin' purdy.",
        	GLASS = "Wonder if I could bust through that.",
        },
        MOONGLASS = "It's green, like a nice leaf.",
        MOONGLASS_ROCK = "That's a big hunk of moon stuff.",
        BATHBOMB = "Smells nice, like wildflowers.",
        TRAP_STARFISH =
        {
            GENERIC = "Just a little starfish, eh?",
            CLOSED = "Well, that's just dangerous.",
        },
        DUG_TRAP_STARFISH = "I should find a place to put it.",
        SPIDER_MOON = 
        {
        	GENERIC = "I don't want nothing to do with whatever that is.",
        	SLEEPING = "Let sleeping dogs lie, eh?",
        	DEAD = "It's dead, eh?",
        },
        MOONSPIDERDEN = "Better not disturb it.",
		FRUITDRAGON =
		{
			GENERIC = "Just a sweet little critter.",
			RIPE = "Were you always that colourful?",
			SLEEPING = "I'll let it rest.",
		},
        PUFFIN =
        {
            GENERIC = "Filthy feathered menace.",
            HELD = "It's my prisoner.",
            SLEEPING = "Do you think you're cute? You're not.",
        },

		MOONGLASSAXE = "Still not as good as Lucy.",
		GLASSCUTTER = "I feel pretty safe with it in my hand.",

        ICEBERG =
        {
            GENERIC = "Reminds me of home.",
            MELTED = "It's looking a bit drippy.",
        },
        ICEBERG_MELTED = "It's looking a bit drippy.",

        MINIFLARE = "Just needs a light.",

		MOON_FISSURE = 
		{
			GENERIC = "Oddly inviting, isn't it?", 
			NOLIGHT = "That's a crack in the ground, eh?",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Oh great, now I'm really hearing voices.",
            GENERIC = "It wants to show me something.",
        },

        MOON_ALTAR_IDOL = "It wants me to carry it somewhere.",
        MOON_ALTAR_GLASS = "I think it wants one of those moon fissures.",
        MOON_ALTAR_SEED = "It wants me to take it to one of those cracks in the ground.",

        MOON_ALTAR_ROCK_IDOL = "There's a little whisper coming from inside.",
        MOON_ALTAR_ROCK_GLASS = "There's a little whisper coming from inside.",
        MOON_ALTAR_ROCK_SEED = "There's a little whisper coming from inside.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "It's good to be ready for anything at sea.",
            BURNT = "It looks a bit crispier than usual.",
        },
        BOAT_ITEM = "It contains the base of the boat.",
        STEERINGWHEEL_ITEM = "We should set up the base of the boat first.",
        ANCHOR_ITEM = "'Little elbow grease and we'll have an anchor.",
        MAST_ITEM = "Better build it if we don't wanna row all day.",
        MUTATEDHOUND = 
        {
        	DEAD = "It's dead.",
        	GENERIC = "That just ain't right.",
        	SLEEPING = "Let's not wake it.",
        },

        MUTATED_PENGUIN = 
        {
			DEAD = "Good riddance.",
			GENERIC = "It's like a bird, but worse.",
			SLEEPING = "Let's not wake it.",
		},
        CARRAT = 
        {
        	DEAD = "It's dead.",
        	GENERIC = "That carrot's a rat!",
        	HELD = "I gotcha now.",
        	SLEEPING = "Huh. It's sleeping.",
        },

		BULLKELP_PLANT = 
        {
            GENERIC = "Look, sea plants.",
            PICKED = "Picked clean.",
        },
		BULLKELP_ROOT = "Seems a bit cruel, doesn't it?",
        KELPHAT = "Even when I take it off I can still imagine the texture.",
		KELP = "Could cook it up real nice.",
		KELP_COOKED = "Good eatin' right there, if you ask me.",
		KELP_DRIED = "It's a nice light snack.",

		GESTALT = "We're all connected, eh?",

        WALKINGPLANK = "Hopefully we don't have to abandon ship.",
        OAR = "I wouldn't mind taking the boat out on the lake today.",
		OAR_DRIFTWOOD = "Nice day for rowin', eh?.",

		----------------------- ROT STRINGS GO ABOVE HERE ------------------

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        --v2 Warly
        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Sure makes the camp smell nice.",
            DONE = "Well, should we eat?",

            --Warly specific PORTABLECOOKPOT_ITEM strings
--fallback to speech_wilson.lua 			COOKING_LONG = "only_used_by_warly",
--fallback to speech_wilson.lua 			COOKING_SHORT = "only_used_by_warly",
--fallback to speech_wilson.lua 			EMPTY = "only_used_by_warly",
        },
        
        PORTABLEBLENDER_ITEM = "Chops up food pretty good.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "I'm not usually one for fancy spices.",
            DONE = "All ground up.",
        },
        SPICEPACK = "A handy knapsack for conserving food!",
        SPICE_GARLIC = "I suppose some spice couldn't hurt.",
        SPICE_SUGAR = "I prefer my syrup to be maple.",
        SPICE_CHILI = "Yep. That's a spicy sauce.",
        MONSTERTARTARE = "Isn't there anything else to eat?",
        FRESHFRUITCREPES = "I can get maple syrup on that?",
        FROGFISHBOWL = "I'm not one to turn my nose up at a meal.",
        POTATOTORNADO = "I'll eat a tater in any form.",
        DRAGONCHILISALAD = "Looks real good, buddy.",
        GLOWBERRYMOUSSE = "Boy would I ever like to dig into that.",
        VOLTGOATJELLY = "Can't remember the last time I had dessert.",
        NIGHTMAREPIE = "Whatcha think, Lucy? Should we try a bite?",
        BONESOUP = "I could always go for a nice hearty soup.",
        MASHEDPOTATOES = "A nice change of pace from meatballs.",
        POTATOSOUFFLE = "Lucy and I will clean up, since Warly did the cooking.",
        MOQUECA = "My mouth is watering just looking at it.",
        GAZPACHO = "Really cools a fella down.",
        ASPARAGUSSOUP = "It's a soup made out of those little trees.",
        VEGSTINGER = "Hoo! Spicy!",
        BANANAPOP = "I'd prefer maple taffy...",
        CEVICHE = "I'd be loonie not to eat this.",
        SALSA = "Lucy'll give ya a hand chopping veggies next time, eh bud?",
        PEPPERPOPPER = "Hoo! That's a hot one, eh?",

        TURNIP = "From the community garden.",
        TURNIP_COOKED = "Cooked real nice.",
        TURNIP_SEEDS = "Looks like new crop seeds to me.",
        
        GARLIC = "Homegrown.",
        GARLIC_COOKED = "Lucy helped.",
        GARLIC_SEEDS = "Looks like new crop seeds to me.",
        
        ONION = "I only cry tears of joy.",
        ONION_COOKED = "Perfectly roasted.",
        ONION_SEEDS = "Looks like new crop seeds to me.",
        
        POTATO = "I love good local produce.",
        POTATO_COOKED = "It cooked up real nice.",
        POTATO_SEEDS = "Looks like new crop seeds to me.",
        
        TOMATO = "That's a nice looking tomato.",
        TOMATO_COOKED = "Heartburn city.",
        TOMATO_SEEDS = "Looks like new crop seeds to me.",

        ASPARAGUS = "When it's raw, it's almost as tough as trees.", 
        ASPARAGUS_COOKED = "Little easier to eat them cooked.",
        ASPARAGUS_SEEDS = "I should plant this.",

        PEPPER = "Funny looking vegetable.",
        PEPPER_COOKED = "Pretty tiny but it packs a punch, eh?",
        PEPPER_SEEDS = "I should plant this.",

        WEREITEM_BEAVER = "Think I'm finally getting the hang of this, eh Lucy?",
        WEREITEM_GOOSE = "What's good for the goose is good for the woodsman!",
        WEREITEM_MOOSE = "Not bad, if I do say so mooself.",
    },

    DESCRIBE_GENERIC = "What's that, eh?",
    DESCRIBE_TOODARK = "It's too dark, eh!",
    DESCRIBE_SMOLDERING = "It's aboot to go up in flames, eh?",
    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "You can taste the beak, eh?",
    },
}
