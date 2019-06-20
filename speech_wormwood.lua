return {

	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "Wrong one",
        },
        BUILD =
        {
            MOUNTED = "Not up here",
            HASPET = "Already have Care Friend",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Too awake",
			GENERIC = "Hmmm... Can't do",
			NOBITS = "Nothing there",
		},
		STORE =
		{
			GENERIC = "Too full",
			NOTALLOWED = "Why can't it go?",
			INUSE = "Someone else's",
		},
		CONSTRUCT =
        {
            INUSE = "Someone else's",
            NOTALLOWED = "Nope",
            EMPTY = "Nothing to build with",
            MISMATCH = "Nope",
        },
		RUMMAGE =
		{	
			GENERIC = "Nope",
			INUSE = "Friends doing it",
		},
		UNLOCK =
        {
        	WRONGKEY = "Wrong key. Oops",
        },
        USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Wrong key. Oops",
        	KLAUS = "Too much danger now!",
        	QUAGMIRE_WRONGKEY = "Wrong key. Oops",
        },
        ACTIVATE = 
		{
			LOCKED_GATE = "Nope. Locked",
		},
        COOK =
        {
            GENERIC = "Can't cook now",
            INUSE = "Someone else using it",
            TOOFAR = "Get closer. Not too close",
        },
        GIVE =
        {
            DEAD = "They are dead",
            SLEEPING = "Shhh...",
            BUSY = "Busy",
            ABIGAILHEART = "Nope",
            GHOSTHEART = "Not alive",
            NOTGEM = "Won't work",
            WRONGGEM = "Wrong sparkly. Oops",
            NOTSTAFF = "Wrong one. Oops",
            MUSHROOMFARM_NEEDSSHROOM = "Needs Fun Guy Friends",
            MUSHROOMFARM_NEEDSLOG = "Needs friends",
            SLOTFULL = "Too full",
            FOODFULL = "Already has belly stuff",
            NOTDISH = "Not belly stuff",
            DUPLICATE = "Already know it",
            NOTSCULPTABLE = "Can't make with it",
            CANTSHADOWREVIVE = "Nope",
            WRONGSHADOWFORM = "Can't do it",
            NOMOON = "Needs Night Ball",
            PIGKINGGAME_MESSY = "Have to clean first",
			PIGKINGGAME_DANGER = "Too much danger!",
			PIGKINGGAME_TOOLATE = "Too late!",
        },
        GIVETOPLAYER =
        {
        	FULL = "Nope. Too much stuff",
            DEAD = "Nope. Dead now",
            SLEEPING = "After sleeping",
            BUSY = "Nope. Too busy",
    	},
    	GIVEALLTOPLAYER =
        {
        	FULL = "Nope. Too much stuff",
            DEAD = "Nope. Dead now",
            SLEEPING = "After sleeping",
            BUSY = "Nope. Too busy",
    	},
        WRITE =
        {
            GENERIC = "Can't write",
            INUSE = "Someone else's",
        },
        DRAW =
        {
            NOIMAGE = "Draw what?",
        },
        CHANGEIN =
        {
            GENERIC = "Not now",
            BURNING = "Fire! Don't like fire!",
            INUSE = "Someone else's",
        },
        ATTUNE =
        {
            NOHEALTH = "Oooooh. Feeling sick",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Too much fighting!",
            INUSE = "Someone else's",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "Too much fighting!",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Know that already",
            CANTLEARN = "Don't get it",

            --MapRecorder/MapExplorer
            WRONGWORLD = "Not for here",
        },
        WRAPBUNDLE =
        {
            EMPTY = "What to wrap... What to wrap...",
        },
        PICKUP =
        {
			RESTRICTION = "Nope. Can't use it",
			INUSE = "Someone else's",
        },
        REPLATE =
        {
            MISMATCH = "Oops. Wrong food holder", 
            SAMEDISH = "Already has food holder", 
        },
        SAIL =
        {
            NOWHEEL = "Needs steerer",
            REPAIR = "Already good",
        },
        BATHBOMB =
        {
            GLASSED = "Water too hard",
            ALREADY_BOMBED = "Already has friends",
        },
	},
	ACTIONFAIL_GENERIC = "Nope",
	ANNOUNCE_BOAT_LEAK = "Water! Water coming!",
    ANNOUNCE_BOAT_SINK = "Why sinking, Floater?",
	ANNOUNCE_DIG_DISEASE_WARNING = "Poor sick friend",
	ANNOUNCE_PICK_DISEASE_WARNING = "Ooh. Smells sick",
	ANNOUNCE_ADVENTUREFAIL = "Try again",
    ANNOUNCE_MOUNT_LOWHEALTH = "Riding friend is hurt",
	ANNOUNCE_BEES = "Buzz! Buzz!",
	ANNOUNCE_BOOMERANG = "Whoops. Missed it",
	ANNOUNCE_CHARLIE = "Someone here?",
	ANNOUNCE_CHARLIE_ATTACK = "Ouch!",
	ANNOUNCE_COLD = "Brrr... Cold!",
	ANNOUNCE_HOT = "Woo-wee, it's hot!",
	ANNOUNCE_CRAFTING_FAIL = "Failed",
	ANNOUNCE_DEERCLOPS = "Eyeball Branch Head near!",
	ANNOUNCE_CAVEIN = "Sky is falling!",
	ANNOUNCE_ANTLION_SINKHOLE = 
	{
		"Sinking!",
		"Ground going!",
		"Dirt sinking!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Here you go",
        "For you",
        "Happy? Yes, happy",
	},
	ANNOUNCE_DUSK = "Light ball is sleepy",
	ANNOUNCE_EAT =
	{
		GENERIC = "Tasty",
		PAINFUL = "Ouch",
		SPOILED = "Oooh... hurts",
		STALE = "Food!",
		INVALID = "Can't",
		YUCKY = "Nope",
	},
	ANNOUNCE_ENCUMBERED =
    {
        "Getting heavy...",
        "Little bit further...",
        "Don't give up...",
		"So... heavy",
		"ugh",
		"(grunt, grunt)",
		"oof. Heavy...",
		"Need rest... soon",
		"Keep going...",
    },

	ANNOUNCE_ATRIUM_DESTABILIZING = 
    {
		"Ground shaky",
		"Sky falling!",
		"Not safe!",
	},	
	ANNOUNCE_RUINS_RESET = "Oh. Everything back",
    ANNOUNCE_SNARED = "Oh! Caught!",
	ANNOUNCE_ENTER_DARK = "Too dark",
	ANNOUNCE_ENTER_LIGHT = "It's light again",
	ANNOUNCE_FREEDOM = "Free!",
	ANNOUNCE_HIGHRESEARCH = "Smarter now",
	ANNOUNCE_HOUNDS = "Woofers!",
	ANNOUNCE_WORMS = "Wigglies are coming",
	ANNOUNCE_HUNGRY = "Need stuff for belly",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Prints!",
	ANNOUNCE_HUNT_LOST_TRAIL = "Prints gone",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Prints gone",
	ANNOUNCE_INV_FULL = "Too much stuff",
	ANNOUNCE_KNOCKEDOUT = "Wha--?",
	ANNOUNCE_LOWRESEARCH = "Learned stuff",
	ANNOUNCE_MOSQUITOS = "Bzzt! Bzzt!",
    ANNOUNCE_NOWARDROBEONFIRE = "Fire! Fire!",
    ANNOUNCE_NODANGERGIFT = "Too scary!",
    ANNOUNCE_NOMOUNTEDGIFT = "Get down first",
	ANNOUNCE_NODANGERSLEEP = "Too much danger",
	ANNOUNCE_NODAYSLEEP = "Too bright!",
	ANNOUNCE_NODAYSLEEP_CAVE = "Can't",
	ANNOUNCE_NOHUNGERSLEEP = "Too hungry",
	ANNOUNCE_NOSLEEPONFIRE = "Burning!",
	ANNOUNCE_NODANGERSIESTA = "Too dangerous",
	ANNOUNCE_NONIGHTSIESTA = "Can't. It's nighttime",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Not in caves",
	ANNOUNCE_NOHUNGERSIESTA = "Too hungry",
	ANNOUNCE_NODANGERAFK ="Too scary!",
	ANNOUNCE_NO_TRAP = "Lucky!",
	ANNOUNCE_PECKED = "Ouch!",
	ANNOUNCE_QUAKE = "Rumbles!",
	ANNOUNCE_RESEARCH = "Smart now",
	ANNOUNCE_SHELTER = "Nice under here",
	ANNOUNCE_THORNS = "Hey! Spiky friends!",
	ANNOUNCE_BURNT ="Agghh! Too much hot!",
	ANNOUNCE_TORCH_OUT = "Oh. Fire stick is out",
	ANNOUNCE_FAN_OUT = "Wind gone",
    ANNOUNCE_COMPASS_OUT = "Direction Thing broke",
	ANNOUNCE_TRAP_WENT_OFF = "Trap snapped!",
	ANNOUNCE_UNIMPLEMENTED = "Can't do it",
	ANNOUNCE_WORMHOLE = "Urgh",
	ANNOUNCE_TOWNPORTALTELEPORT = "Made it!",
	ANNOUNCE_CANFIX = "\nCan fix it!",
	ANNOUNCE_ACCOMPLISHMENT = "A game!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "Did it! Yay!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Need more poop",
	ANNOUNCE_TOOL_SLIP = "Whoops",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Too close!",
	ANNOUNCE_TOADESCAPING = "Getting away!",
	ANNOUNCE_TOADESCAPED = "Ribbit! Come back!",

	ANNOUNCE_DAMP = "Rain!",
	ANNOUNCE_WET = "Little wet",
	ANNOUNCE_WETTER = "Really wet",
	ANNOUNCE_SOAKED = "Too wet!",

	ANNOUNCE_DESPAWN = "Don't want to go!",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!",
	ANNOUNCE_GHOSTDRAIN = "What happening?",
	ANNOUNCE_PETRIFED_TREES = "Friends! Friends talking!",
	ANNOUNCE_KLAUS_ENRAGE ="Agh! Run away!",
	ANNOUNCE_KLAUS_UNCHAINED = "Agh! Scary belly mouth!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Oh. Needs friends",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Need to help!",
		GLASS_LOW = "Almost...",
		GLASS_REVEAL = "Free!",
		IDOL_MED = "Need to help!",
		IDOL_LOW = "Almost...",
		IDOL_REVEAL = "Free!",
		SEED_MED = "Need to help!",
		SEED_LOW = "Almost...",
		SEED_REVEAL = "Free!",
	},

	--hallowed nights
    ANNOUNCE_SPOOKED = "Scary!",
    ANNOUNCE_BRAVERY_POTION = "Feeling strong!",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Helping...",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Made better",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Thank you!",
    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Oops. Not good belly stuff",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Burnt. Oh",
    QUAGMIRE_ANNOUNCE_LOSE = "Didn't win. Oh",
    QUAGMIRE_ANNOUNCE_WIN = "Yay! Did it!",

    --WORMWOOD
    ANNOUNCE_KILLEDPLANT = {"Sorry, friend", "Don't like hurting friend", "Friends don't like that"},
    ANNOUNCE_GROWPLANT = {"Grow!","New friend!","Happy Birthday!"},

    ANNOUNCE_BLOOMING = {"Feeling bloomy!"},

	BATTLECRY =
	{
		GENERIC = "Attack!",
		PIG = "Attack!",
		PREY = "Attack!",
		SPIDER = "Attack!",
		SPIDER_WARRIOR = "Attack!",
		DEER = "Attack!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Don't want to fight",
		PIG = "Don't want to fight",
		PREY = "Don't want to fight",
		SPIDER = "Don't want to fight",
		SPIDER_WARRIOR = "Don't want to fight",
	},
	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Hmm... new door",
		MULTIPLAYER_PORTAL_MOONROCK = "Glowy. Like Night Ball",
        CONSTRUCTION_PLANS = "Door plans",
        MOONROCKIDOL = "Oh. Hello",
        MOONROCKSEED = "Makes Night Ball things",
		ANTLION = 
		{
			GENERIC = "Hello!",
			VERYHAPPY = "Happy Roar Bug!",
			UNHAPPY = "Oh no. Needs gifts",
		},
		ANTLIONTRINKET = "Gift!",
		SANDSPIKE = "Oh. Ouch!",
        SANDBLOCK = "Can play with it?",
        GLASSSPIKE = "Clear Rock Pricker",
        GLASSBLOCK = "Pretty burnt sand",
		ABIGAIL_FLOWER = 
		{ 
			GENERIC = "Friend?",
			LONG = "Sleeping",
			MEDIUM = "Hello there!",
			SOON = "Ready!",
			HAUNTED_POCKET = "Jumpy pocket",
			HAUNTED_GROUND = "Ghost friend",
		},

		BALLOONS_EMPTY = "Needs air",
		BALLOON = "Boop",

		BERNIE_INACTIVE =
		{
			BROKEN = "What happened?",
			GENERIC = "Hello, Squishy Friend!",
		},

		BERNIE_ACTIVE = "Yay! Squishy Friend can play!",
		
		BOOK_BIRDS ="Pretty pictures",
		BOOK_TENTACLES = "About Scary Arms",
		BOOK_GARDENING = "This one's nice",
		BOOK_SLEEP = "(yawn)",
		BOOK_BRIMSTONE = "Fire!",

        PLAYER =
        {
            GENERIC = "Hello, %s!",
            ATTACKER = "Bad! Bad &s!",
            MURDERER = "Killing bad!",
            REVIVER = "Good helper",
            GHOST = "Need help?",
            FIRESTARTER = "Fire maker! Fire bad!",
        },
        WILSON =
        {
            GENERIC = "Hello, Science man!",
            ATTACKER = "%s! Stop hurting!",
            MURDERER = "Bad %s. Don't kill!",
            REVIVER = "Yay! Made Floaty Friend solid again!",
            GHOST = "You okay, %s?",
            FIRESTARTER = "No! No fire!",
        },
        WOLFGANG =
        {
            GENERIC = "%s is big muscle man!",
            ATTACKER = "Don't hurt! Hurting bad!",
            MURDERER = "Killer! Bad!",
            REVIVER = "Good, %s!",
            GHOST = "Oh. %s is Floaty Friend now",
            FIRESTARTER = "Fire! Don't like fire!",
        },
        WAXWELL =
        {
            GENERIC = "Oh. %s looks frowny",
            ATTACKER = "Not nice, %s!",
            MURDERER = "Bad %s. Make not alive!",
            REVIVER = "Thank you, %s!",
            GHOST = "You okay, %s?",
            FIRESTARTER = "%s made too much fire!",
        },
        WX78 =
        {
            GENERIC = "%s is robot friend",
            ATTACKER = "Bad %s likes to hurt!",
            MURDERER = "%s is bad robot. Bad!",
            REVIVER = "%s is nice robot",
            GHOST = "Like being floaty, %s?",
            FIRESTARTER = "%s made too much fire!",
        },
        WILLOW =
        {
            GENERIC = "Oh. %s likes fire",
            ATTACKER = "Don't hurt, %s!",
            MURDERER = "Killing bad, %s!",
            REVIVER = "%s is helping friend",
            GHOST = "Oh. Need help?",
            FIRESTARTER = "Made too much fire, $s!",
        },
        WENDY =
        {
            GENERIC = "%s has Floaty Sister friend",
            ATTACKER ="Why, %s? Why hurting?!",
            MURDERER = "No! Making dead friends is bad!",
            REVIVER = "Friend %s is good",
            GHOST = "Now %s is like Floaty Sister",
            FIRESTARTER = "Don't like fire!",
        },
        WOODIE =
        {
            GENERIC = "Keep axe friend away, please",
            ATTACKER = "Bad %s!",
            MURDERER = "No killing!",
            REVIVER = "%s is a make betterer",
            GHOST = "Hello, Floaty Friend",
            BEAVER ="Friend Eater! Keep away!",
            BEAVERGHOST = "Can't eat friends anymore",
            FIRESTARTER = "No! Fire hurts!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "%s is good book friend",
            ATTACKER = "%s is bad book friend",
            MURDERER = "No! Don't make friends dead!",
            REVIVER = "%s is good",
            GHOST = "Like floating, %s?",
            FIRESTARTER = "Aggh! Made too much fire!",
        },
        WES =
        {
            GENERIC = "%s is quiet friend",
            ATTACKER = "Bad %s! Don't hurt!",
            MURDERER = "%s is silent dead maker",
            REVIVER = "%s is a good friend",
            GHOST = "%s is a quiet floaty",
            FIRESTARTER = "Aggh! %s made too much fire!",
        },
        WEBBER =
        {
            GENERIC = "Hello Leggy Bug friend!",
            ATTACKER = "No! Hurting bad!",
            MURDERER = "Bad! Made friends not alive",
            REVIVER = "%s is friend fixer",
            GHOST = "Like being floaty, %s?",
            FIRESTARTER ="Fire bad, %s! Fire bad!",
        },
        WATHGRITHR =
        {
            GENERIC = "%s is strong friend",
            ATTACKER = "Bad %s! Don't hurt!",
            MURDERER = "%s is bad!",
            REVIVER = "%s is good Floaty Friend fixer",
            GHOST = "Oh. Hello, Floaty Friend!",
            FIRESTARTER = "Too much fire! Too much!",
        },
        WINONA =
        {
            GENERIC = "%s is good Fixer",
            ATTACKER = "No! Hurt too much!",
            MURDERER = "Aggh! %s is a dead maker!",
            REVIVER = "Good friend. Helping",
            GHOST = "Need help, %s?",
            FIRESTARTER = "Too much fire, %s!",
        },
        WORTOX =
        {
            GENERIC = "Nice head branches %s!",
            ATTACKER = "Bad! Hurt too much!",
            MURDERER = "%s made friends dead!",
            REVIVER = "%s is good friend",
            GHOST = "Oh. Need help?",
            FIRESTARTER = "Agh! Fire maker!",
        },
        WORMWOOD =
        {
            GENERIC = "Looking good, Friend!",
            ATTACKER = "Why so hurty, %s?",
            MURDERER = "No! Bad %s!",
            REVIVER = "%s makes friends well again!",
            GHOST = "Oh. That you, %s?",
            FIRESTARTER = "Why make so much fire?!",
        },

        MIGRATION_PORTAL = 
        {
            GENERIC = "Door to friends",
            OPEN = "Can go through",
            FULL = "Oh. Full",
        },
		GLOMMER = 
		{
			GENERIC = "You're nice. Stay close",
			SLEEPING = "Shh...",
		},
		GLOMMERFLOWER = 
		{
			GENERIC = "Moon Flower",
			DEAD = "Poor friend...",
		},
		GLOMMERWINGS = "So teeny",
		GLOMMERFUEL = "Yum! (urp)",
		BELL = "Ding! Dong!",
		STATUEGLOMMER = 
		{	
			GENERIC = "That you, nice friend?",
			EMPTY = "Gone",
		},

		LAVA_POND_ROCK = "Rock",
		LAVA_POND_ROCK2 = "Rock",
		LAVA_POND_ROCK3 = "Rock",
		LAVA_POND_ROCK4 = "Rock",
		LAVA_POND_ROCK5 = "Rock",
		LAVA_POND_ROCK6 = "Rock",
		LAVA_POND_ROCK7 = "Rock",

		WEBBERSKULL = "Oh. Oh dear",
		WORMLIGHT = "Shiny...",
		WORMLIGHT_LESSER = "Still good",
		WORM =
		{
		    PLANT = "Hmm... not safe",
		    DIRT = "Something hiding",
		    WORM = "Hello, Wiggly!",
		},
        WORMLIGHT_PLANT = "Hmm... not safe",
		MOLE =
		{
			HELD = "It's wiggling",
			UNDERGROUND = "Smelly Digger is hiding",
			ABOVEGROUND = "Smelly Digger!",
		},
		MOLEHILL = "You okay, dirt?",
		MOLEHAT = "A Smelly Digger hat",

		EEL = "Sea Wiggly",
		EEL_COOKED = "Not wiggly anymore",
		UNAGI = "Sea Wiggly wiggles in belly",
		EYETURRET = "Pew!",
		EYETURRET_ITEM = "Pew Pew rock",
		MINOTAURHORN = "Ouch!",
		MINOTAURCHEST = "Lots of stuff!",
		THULECITE_PIECES = "Old rocks",
		POND_ALGAE = "Nice day for a swim?",
		GREENSTAFF = "A Take Apart Stick",
		POTTEDFERN = "Stay. Good boy",
		SUCCULENT_POTTED = "Found friend a home",
		SUCCULENT_PLANT = "Friend! Good to see you!",
		SUCCULENT_PICKED = "Keep you safe, friend",
		GIFT = "Give to friends!",
        GIFTWRAP = "Fun wrapping time!",
		SENTRYWARD = "Sparkly Stone see far!",
		TOWNPORTAL =
        {
			GENERIC = "Friend poofer",
			ACTIVE = "Can poof to friends now!",
		},
        TOWNPORTALTALISMAN = 
        {
			GENERIC = "Sandy rock",
			ACTIVE = "Can poof now!",
		},
		WETPAPER = "Soppy paper",
		WETPOUCH ="Soppy pocket",
        MOONROCK_PIECES ="From Night ball?",
        MOONBASE =
        {
            GENERIC = "Does it work?",
            BROKEN = "Needs fixes",
            STAFFED = "Hmm... What's happening?",
            WRONGSTAFF = "Nope",
            MOONSTAFF = "Stick makes light!",
        },
        MOONDIAL = 
        {
			GENERIC = "Night Ball looker",
			NIGHT_NEW = "No Night Ball",
			NIGHT_WAX ="Night Ball getting bigger",
			NIGHT_FULL ="Big Night Ball!",
			NIGHT_WANE = "Night Ball getting smaller",
			CAVE = "Oh. No Night Ball here",
        },
		THULECITE = "Rocks from old times",
		ARMORRUINS = "Heavy clothes",
		ARMORSKELETON ="Magic bones",
        SKELETONHAT = "Scary head",
		RUINS_BAT = "Old Rock Whacker",
		RUINSHAT = "Weighs down head",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Quiet now",	--calm phase
			WARN = "Something happening...",	--Before nightmare
			WAXING = "Getting scary", --Nightmare Phase first 33%
			STEADY = "Bad! Really bad!", --Nightmare 33% - 66%
			WANING = "Getting better", --Nightmare 66% +
			DAWN = "Whew", --After nightmare
			NOMAGIC = "Safe here", --Place with no nightmare cycle.
		},
		BISHOP_NIGHTMARE = "Hurt",
		ROOK_NIGHTMARE = "Run down",
		KNIGHT_NIGHTMARE = "Busted",
		MINOTAUR = "Don't want to fight!",
		SPIDER_DROPPER = "Aggh! Scary!",
		NIGHTMARELIGHT = "Night light for scary times",
		NIGHTSTICK = "A Light Ball Stick",
		GREENGEM = "Looks familiar...",
		RELIC = "Old rock",
		MULTITOOL_AXE_PICKAXE = "Handy stick",
		ORANGESTAFF = "Poof stick",
		YELLOWAMULET = "Can go zoomy now!",
		GREENAMULET = "Helps for building",
		SLURPERPELT = "(sigh) Sad",

		SLURPER = "Furry Head Eater",
		SLURPER_PELT = "(sigh) Sad",
		ARMORSLURPER = "Furry Belt. Looks good",
		ORANGEAMULET = "Picker Upper",
		YELLOWSTAFF = "Zoom Stick",
		YELLOWGEM = "Ohhh. Shiny...",
		ORANGEGEM = "Helper Shiny",
        OPALSTAFF ="Oh! Stick is cold",
        OPALPRECIOUSGEM = "Pretty, pretty shiny",
        TELEBASE = 
		{
			VALID = "Ready",
			GEMS = "Needs Purple Shiny",
		},
		GEMSOCKET = 
		{
			VALID = "Ready",
			GEMS = "Where shiny things?",
		},
		STAFFLIGHT = "Bright!! Very bright!",
        STAFFCOLDLIGHT = "Oh! Cold stick makes light!",

        ANCIENT_ALTAR = "Makes more things!",

        ANCIENT_ALTAR_BROKEN = "Broken. Needs old stones",

        ANCIENT_STATUE = "Alive? Hmmm...",

        LICHEN = "Rock belly stuff",
		CUTLICHEN = "Smells good",
		CAVE_BANANA = "Mmmmm...",
		CAVE_BANANA_COOKED = "Smokey",
		CAVE_BANANA_TREE = "Friend with Sweet Hair",
		ROCKY = "Rock Pinchy",
		
		COMPASS =
		{
			GENERIC= "Which way?",
			N = "North",
			S = "South",
			E = "East",
			W = "West",
			NE = "Northeast",
			SE = "Southeast",
			NW = "Northwest",
			SW = "Southwest",
		},

		HOUNDSTOOTH= "Sharp. Ouch!",
		ARMORSNURTLESHELL= "Anyone hiding?",
		BAT= "Flying Claws!",
        BATBAT = "Flying Claw Whacker",
		BATWING="Can't fly anymore",
		BATWING_COOKED= "Little chewy. And claw-y",
        BATCAVE = "Smells good!",
		BEDROLL_FURRY= "Furry for sleepytime",
		BUNNYMAN= "Wants belly things",
		FLOWER_CAVE= "Glowy Friend",
		FLOWER_CAVE_DOUBLE= "Glowy Friends",
		FLOWER_CAVE_TRIPLE= "Glowy party!",
		GUANO= "Good poop!",
		LANTERN= "Carry light",
		LIGHTBULB= "Glowy food",
		MANRABBIT_TAIL= "Fluffy. And soft",
		MUSHROOMHAT = "Haha! Friend hat!",
		MUSHROOM_LIGHT2 =
        {
            ON = "Oh! Colors pretty",
            OFF = "Hello friends!",
            BURNT = "Oh. Oh dear",
        },
        MUSHROOM_LIGHT =
        {
        	ON = "Glow friends! Hi!",
        	OFF = "Oh. Where's light?",
        	BURNT = "Oh. Oh dear",
    	},
        SHROOM_SKIN = "Oh. Friends missing clothes",
    	TOADSTOOL_CAP =
        {
            EMPTY = "Gone",
            INGROUND = "Hiding",
            GENERIC = "Hi friend!",
        },
		TOADSTOOL = 
        {
        	GENERIC = "Ribbit giving friends a ride!",
        	RAGE = "Uh oh",
        },
        MUSHROOMBOMB = "Oh. Smells explody",
        SLEEPBOMB = "Bag of sleepytime",
		MUSHTREE_TALL =
		{
            GENERIC = "Growing nicely",
            BLOOM = "Pretty!",
        },
		MUSHTREE_MEDIUM = 
		{
            GENERIC = "Fun guy",
            BLOOM = "Fancy!",
        },
		MUSHTREE_SMALL = 
		{
            GENERIC = "Hi there!",
            BLOOM ="Looking good",
        },
        MUSHTREE_TALL_WEBBED = "It's trapped!",
        SPORE_TALL = "Where you going?",
        SPORE_MEDIUM = "So cute!",
        SPORE_SMALL = "Hey little guys!",
        SPORE_TALL_INV = "Glowing babies",
        SPORE_MEDIUM_INV = "Coochy-coo!",
        SPORE_SMALL_INV = "Safe now",
		RABBITHOUSE=
		{
			GENERIC = "Big Squee Hopper home",
			BURNT = "Bad fire! Bad!",
		},
		SLURTLE="Shy Spiky Shell",
		SLURTLE_SHELLPIECES="Spiky Shell bits",
		SLURTLEHAT= "Hard Head Thing",
		SLURTLEHOLE= "Spiky Shell home",
		SLURTLESLIME= "For hungry machines",
		SNURTLE= "Not Spiky Shell",
		SPIDER_HIDER= "Shy?",
		SPIDER_SPITTER= "Patuey!",
		SPIDERHOLE= "Something hiding?",
		SPIDERHOLE_ROCK = "What's in there?",
		STALAGMITE= "Rocks",
		STALAGMITE_FULL= "Rock",
		STALAGMITE_LOW= "Rock",
		STALAGMITE_MED= "Rock",
		STALAGMITE_TALL= "Rock",
		STALAGMITE_TALL_FULL= "Rock",
		STALAGMITE_TALL_LOW= "Rock",
		STALAGMITE_TALL_MED= "Rock",
		TREASURECHEST_TRAP = "Hmm...",
		
        TURF_CARPETFLOOR = "Not dirt",
        TURF_CHECKERFLOOR = "Not dirt",
        TURF_DIRT = "Dirt!",
        TURF_FOREST = "Dirt!",
        TURF_GRASS = "Soft!",
        TURF_MARSH = "Squishy",
        TURF_ROAD = "Not dirt",
        TURF_ROCKY = "Not dirt",
        TURF_SAVANNA = "Full of friends",
        TURF_WOODFLOOR = "Not dirt",

		TURF_CAVE="Rocky",
		TURF_FUNGUS="Mushy",
		TURF_SINKHOLE="Slimy",
		TURF_UNDERROCK="Too rocky",
		TURF_MUD="Sticky",

		TURF_DECIDUOUS = "Nice dirt",
		TURF_SANDY = "Sandy",
		TURF_BADLANDS = "Dirt",
		TURF_DESERTDIRT = "Sand",
		TURF_FUNGUS_GREEN = "Squishy",
		TURF_FUNGUS_RED = "Squashy",
		TURF_DRAGONFLY = "Fire can't come here!",

		POWCAKE = "Ka-pow!",
        CAVE_ENTRANCE = "Goes somewhere",
        CAVE_ENTRANCE_RUINS = "Goes somewhere",
       
       	CAVE_ENTRANCE_OPEN = 
        {
            GENERIC = "Closed",
            OPEN = "Open now",
            FULL = "Can't go there",
        },
        CAVE_EXIT = 
        {
            GENERIC = "Closed",
            OPEN = "Open",
            FULL = "Can't go there",
        },

		MAXWELLPHONOGRAPH = "Can't dance to it",
		BOOMERANG = "Returny Stick",
		PIGGUARD = "Twirly Tail Tough Guy",
		ABIGAIL = "Floaty Friend",
		ADVENTURE_PORTAL = "Adventure?",
		AMULET = "Yay! More life!",
		ANIMAL_TRACK = "Mystery Prints!",
		ARMORGRASS = "Friend Hair made clothes",
		ARMORMARBLE = "Heavy",
		ARMORWOOD = "Friend Shirt",
		ARMOR_SANITY = "Brain Guard",
		ASH =
		{
			GENERIC = "Something burned",
			REMAINS_GLOMMERFLOWER = "Oh",
			REMAINS_EYE_BONE = "All gone",
			REMAINS_THINGIE = "Gone",
		},
		AXE = "Hurts friends (sob)",
		BABYBEEFALO = 
		{
			GENERIC = "Needs more fur",
		    SLEEPING = "Shh...",
        },
        BUNDLE = "Stuff inside",
        BUNDLEWRAP = "Put stuff inside",
		BACKPACK = "For more things carrying",
		BACONEGGS = "Belly filler",
		BANDAGE = "Sweet Heal Paper",
		BASALT = "Too heavy",
		BEARDHAIR = "Fuzzy",
		BEARGER = "Mad Molter",
		BEARGERVEST = "Warm. Cozy",
		ICEPACK = "Not good for rot",
		BEARGER_FUR = "Poor guy",
		BEDROLL_STRAW = "For sleepytime",
		BEEQUEEN = "Big Mommy Buzz!",
		BEEQUEENHIVE = 
		{
			GENERIC = "Full of Buzz Juice",
			GROWING = "Getting bigger!",
		},
        BEEQUEENHIVEGROWN = "Big Buzz home!",
        BEEGUARD = "Oh. Scary Buzz",
        HIVEHAT = "Hehe. Funny Branch Hat",
        MINISIGN =
        {
            GENERIC = "Pretty picture",
            UNDRAWN = "Needs pretty picture",
        },
        MINISIGN_ITEM = "Needs ground",
		BEE =
		{
			GENERIC = "Buzz!",
			HELD = "Needs home",
		},
		BEEBOX =
		{
			READY = "Buzz Juice ready!",
			FULLHONEY = "Buzz Juice ready!",
			GENERIC = "Buzz home!",
			NOHONEY = "Empty",
			SOMEHONEY = "Wait",
			BURNT = "Fire breaks everything",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Party!",
			LOTS = "Lots of new friends!",
			SOME = "Hello, little friends!",
			EMPTY = "What happened, friend?",
			ROTTEN = "Oh. So sorry",
			BURNT = "Fire is bad",
			SNOWCOVERED = "Too cold?",
		},
		BEEFALO =
		{
			FOLLOWER = "Looking for belly stuff",
			GENERIC = "Shaggy Buddy",
			NAKED = "Bald",
			SLEEPING = "Shh... Don't wake it",
            --Domesticated states:
            DOMESTICATED = "A pet now",
            ORNERY = "Cranky",
            RIDER = "Can ride now",
            PUDGY = "Full belly",
		},
		BEEFALOHAT = "Warm",
		BEEFALOWOOL = "Buddy hair",
		BEEHAT = "Looks good",
		BEESWAX = "Buzz Blocks",
		BEEHIVE = "Buzz Home",
		BEEMINE = "Buzz Ka-bloey",
		BEEMINE_MAXWELL = "It's buzzing...",
		BERRIES = "Tiny little belly fillers",
		BERRIES_COOKED = "Slurp!",
        BERRIES_JUICY = "Tiny squishy belly fillers",
        BERRIES_JUICY_COOKED = "Squish, squish!",
		BERRYBUSH =
		{
			BARREN = "Needs poop",
			WITHERED = "Poor guy",
			GENERIC = "Full of stuff for belly",
			PICKED = "Belly fillers will grow back",
			DISEASED = "Sick! Very, very sick!",
			DISEASING = "You sick, friend?",
			BURNING = "Oh! Oh no!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Needs poop",
			WITHERED = "Too hot, friend?",
			GENERIC = "Full of belly fillers!",
			PICKED = "Oh. Out of belly fillers",
			DISEASED = "Oh! Friend got sick!",
			DISEASING = "Get well soon",
			BURNING = "Oh! Stop! Stop!",
		},
		BIGFOOT = "Smelly Stomper",
		BIRDCAGE =
		{
			GENERIC = "Needs a friend",
			OCCUPIED = "Tweet! Tweet!",
			SLEEPING = "Sleep well, Tweeter",
			HUNGRY = "Hungry?",
			STARVING = "Needs food!",
			DEAD = "Oh. Whoops",
			SKELETON = "(sigh)",
		},
		BIRDTRAP = "Tweeter Nabber",
		CAVE_BANANA_BURNT = "Smokey",
		BIRD_EGG = "Baby Tweeter",
		BIRD_EGG_COOKED = "Goes in belly",
		BISHOP = "A Pointy Hat Machine Man!",
		BLOWDART_FIRE = "Fire Ptooey",
		BLOWDART_SLEEP = "Sleepytime Ptooey",
		BLOWDART_PIPE = "Ptooey stick",
		BLOWDART_YELLOW = "Zzzt Ptooey",
		BLUEAMULET = "Cold Neck Thing",
		BLUEGEM = "Makes the cold",
		BLUEPRINT = 
		{ 
            COMMON = "Paper for stuff making",
            RARE = "Ohhhh... Looks important",
        },
        SKETCH = "Pretty picture",
		--BELL_BLUEPRINT = "Progress on paper!",
		BLUEPRINT = "Paper for stuff making",
		BELL_BLUEPRINT = "Makes Ding Dong bell",
		BLUE_CAP = "Hurts head. Ow!",
		BLUE_CAP_COOKED = "Helps head. Ahhh...",
		BLUE_MUSHROOM =
		{
			GENERIC = "Little blue friend!",
			INGROUND = "He's shy",
			PICKED = "All gone",
		},
		BOARDS = "Fallen friends",
		BONESHARD = "Sharp. Ouch!",
		BONESTEW = "Pot of lots of meat",
		BUGNET = "Bzzt Catcher",
		BUSHHAT = "Friend costume",
		BUTTER = "Where are wings?",
		BUTTERFLY =
		{
			GENERIC = "A friend for friends",
			HELD = "Flappy",
		},
		BUTTERFLYMUFFIN ="Yummm...",
		BUTTERFLYWINGS = "Can fly with it? No",
		BUZZARD = "Meat Tweeter",

		SHADOWDIGGER = "Dark Floaty Digger",

		CACTUS = 
		{
			GENERIC = "Ouch Friend",
			PICKED = "Grow, Ouch Friend! Grow!",
		},
		CACTUS_MEAT_COOKED = "Will eat it",
		CACTUS_MEAT = "Mmm... belly stuff",
		CACTUS_FLOWER = "Yum",

		COLDFIRE =
		{
			EMBERS = "Almost gone",
			GENERIC = "Chilly",
			HIGH = "Really big!",
			LOW = "Getting warmer",
			NORMAL = "Cooling",
			OUT = "Needs food",
		},
		CAMPFIRE =
		{
			EMBERS = "Dying",
			GENERIC = "Not too close",
			HIGH = "Too high!",
			LOW = "Stay back",
			NORMAL = "Not too close",
			OUT ="Whew!",
		},
		CANE = "Friend for walking",
		CATCOON = "Hello, Kitty!",
		CATCOONDEN = 
		{
			GENERIC ="Anyone home?",
			EMPTY = "No more Kitties",
		},
		CATCOONHAT = "Kitty thing for head",
		COONTAIL = "Poor little Kitty",
		CARROT = "Thanks, dirt!",
		CARROT_COOKED = "Tiny circles for belly",
		CARROT_PLANTED = "Nice growing! Keep going!",
		CARROT_SEEDS = "Makes the orange belly stuff",
		CARTOGRAPHYDESK = 
		{	
			GENERIC = "Needs Findy Paper",
			BURNING = "No! Fire! Fire!",
			BURNT = "Oh. Oh no",
		},
		WATERMELON_SEEDS = "Makes Water Fruit!",
		CAVE_FERN = "How you doing?",
		CHARCOAL = "Burnt rock",
		CHESSPIECE_PAWN = 
        {
			GENERIC ="Nice head thing!",
		},
        CHESSPIECE_ROOK = 
        {
			GENERIC = "Home? Not home",
			STRUGGLE = "Alive?",
		},
        CHESSPIECE_KNIGHT = 
        {
			GENERIC ="Stone Neigher!",
			STRUGGLE = "What's happening?",
		},
        CHESSPIECE_BISHOP = 
        {
			GENERIC ="Like Pointy Head thing",
			STRUGGLE = "Strange things happening!",
		},
        CHESSPIECE_MUSE = 
        {
			GENERIC = "Pretty Stone",
		},
        CHESSPIECE_FORMAL = 
        {
			GENERIC = "Where head?",
		},
        CHESSPIECE_HORNUCOPIA = 
        {
			GENERIC = "Not for belly",
		},
        CHESSPIECE_PIPE = 
        {
 		},
        CHESSJUNK1 = "Machine stuff",
        CHESSJUNK2 = "Lots of machine stuff",
        CHESSJUNK3 = "Full of machine stuff",
		CHESTER = "Carries stuff. Thank you!",
		CHESTER_EYEBONE =
		{
			GENERIC ="Blinky!",
			WAITING = "Sleeping. Shh...",
		},
		COOKEDMANDRAKE ="Smells sleepy",
		COOKEDMEAT = "Yummm",
		COOKEDMONSTERMEAT = "Smells bad",
		COOKEDSMALLMEAT = "Little belly stuff",
		COOKPOT =
		{
			COOKING_LONG ="Waiting...",
			COOKING_SHORT = "Done soon",
			DONE ="Done!",
			EMPTY = "Nothing there",
			BURNT = "Oh",
		},
		CORN = "Tiny seeds good for belly",
		CORN_COOKED = "Pop! Pop!",
		CORN_SEEDS ="Dirt likes these",
		CANARY =
		{
			GENERIC = "Boom Tweeter",
			HELD = "Hello. Friend?",
		},
		CANARY_POISONED = "Oh. Oh no",

		CRITTERLAB = "Little friends hiding inside",
        CRITTER_GLOMLING = "Little Bounce Bounce Friend",
        CRITTER_DRAGONLING = "Hi, Little Patuey!",
		CRITTER_LAMB = "Tiny Horkbeast is friend",
        CRITTER_PUPPY = "Little Woofer! Woof!",
        CRITTER_KITTEN = "Me-Raow, Teeny Kitkit",
        CRITTER_PERDLING = "Wee Tweeter is friend now",

		CROW =
		{
			GENERIC = "Caw Tweeter!",
			HELD = "Needs a home",
		},
		CUTGRASS = "Hair from friends!",
		CUTREEDS = "Hair cut",
		CUTSTONE = "Square stones",
		DEADLYFEAST = "Nope",
		DEER =
		{
			GENERIC = "Where eyes?",
			ANTLER = "Like your branches!",
		},
        DEER_ANTLER = "Like your branches!",
        DEER_GEMMED = "Ohhh... Sparkly eye",
		DEERCLOPS = "Branch Head",
		DEERCLOPS_EYEBALL = "(poke)",
		EYEBRELLAHAT =	"Peeping Rain Taker",
		DEPLETED_GRASS =
		{
			GENERIC = "Needs poop",
		},
		GOGGLESHAT = "More eyes for head?",
        DESERTHAT = "Funny eyes. Like it",
		DEVTOOL ="Strange",
		DEVTOOL_NODEV = "Can't",
		DIRTPILE = "What's hiding?",
		DIVININGROD =
		{
			COLD = "It's quiet",
			GENERIC = "Leads to somewhere",
			HOT = "It's LOUD!",
			WARM = "Humming",
			WARMER = "More humming!",
		},
		DIVININGRODBASE =
		{
			GENERIC = "Hmm...",
			READY = "Needs key",
			UNLOCKED ="Works!",
		},
		DIVININGRODSTART = "Stick",
		DRAGONFLY = "Patuey Fly",
		ARMORDRAGONFLY = "Fire Keeper Outer",
		DRAGON_SCALES = "Fiery clothes",
		DRAGONFLYCHEST = "Fire Safe",
		DRAGONFLYFURNACE = 
		{
		    HAMMERED = "Just stuff now",
			GENERIC = "Not working", --no gems
			NORMAL = "Needs more sparkly", --one gem
			HIGH = "Hot! So hot!", --two gems
		},
        
        HUTCH = "Glub Glub Lugger",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Making friends!",
            WAITING = "Can swim on back?",
        },
		LAVASPIT = 
		{
			HOT = "Yeouch!",
			COOL = "Cooled down",
		},
		LAVA_POND ="Earth Blood. Hot!",
		LAVAE = "Too hot!",
		LAVAE_COCOON = "Nice and warm?",
		LAVAE_PET = 
		{
			STARVING = "Needs ashes",
			HUNGRY = "Hungry?",
			CONTENT = "Happy",
			GENERIC = "Hot!",
		},
		LAVAE_EGG = 
		{
			GENERIC = "Baby Patuey Fly",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Too cold!",
			COMFY = "Warm inside",
		},
		LAVAE_TOOTH = "Patuey Fly is teething?",

		DRAGONFRUIT ="Pretty fruit",
		DRAGONFRUIT_COOKED = "Mmm...",
		DRAGONFRUIT_SEEDS = "Grows the pretty fruit",
		DRAGONPIE = "Pie. Yummy pie",
		DRUMSTICK = "Not friend stick",
		DRUMSTICK_COOKED = "A stick for belly",
		DUG_BERRYBUSH = "Needs dirt",
		DUG_BERRYBUSH_JUICY ="Needs dirt",
		DUG_GRASS = "Needs dirt",
		DUG_MARSH_BUSH = "Needs dirt",
		DUG_SAPLING = "Needs dirt",
		DURIAN = "Smelly belly stuff",
		DURIAN_COOKED = "Still smells",
		DURIAN_SEEDS = "Want this, dirt?",
		EARMUFFSHAT = "Squee Hopper ears",
		EGGPLANT = "Mmm...",
		EGGPLANT_COOKED ="Belly likes it",
		EGGPLANT_SEEDS = "Grows the purple belly stuff",
		
		ENDTABLE = 
		{
			BURNT = "No! NOOOOO!",
			GENERIC = "Ohh! Table friend!",
			EMPTY = "Needs friend for cup",
			WILTED ="Sick, Friend?",
			FRESHLIGHT = "Light Friend looks good!",
			OLDLIGHT = "Sick, Light Friend?",
		},
		DECIDUOUSTREE = 
		{
			BURNING = "No!",
			BURNT = "Sorry",
			CHOPPED = "Oh!",
			POISON = "Hello! Friend?",
			GENERIC = "Sleeping?",
		},
		ACORN = "So cute!",
        ACORN_SAPLING = "Grow big and strong!",
		ACORN_COOKED = "For belly now",
		BIRCHNUTDRAKE = "So cute",
		EVERGREEN =
		{
			BURNING = "Nonononono!",
			BURNT = "(sob)",
			CHOPPED = "Sorry",
			GENERIC = "How doing, friend?",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Fire!",
			BURNT = "Oh",
			CHOPPED = "Sad. So sad",
			GENERIC = "Shh... Sleeping",
		},
		TWIGGYTREE = 
		{
			BURNING = "No! NOOOOOOO!",
			BURNT = "So young...",
			CHOPPED = "Keep growing, friend!",
			GENERIC = "Skinny friend!",			
			DISEASED = "Sick?",
		},
		TWIGGY_NUT_SAPLING = "Cute little friend",
        TWIGGY_OLD = "Wise old friend",
		TWIGGY_NUT ="Needs dirt",
		EYEPLANT = "Blinky friend",
		INSPECTSELF = "Looking nice",
		FARMPLOT =
		{
			GENERIC = "Good soil",
			GROWING = "Growing stuff for belly",
			NEEDSFERTILIZER = "Needs poop",
			BURNT = "Oh",
		},
		FEATHERHAT = "Tweeter disguise",
		FEATHER_CANARY = "Tweeter clothes",
		FEATHER_CROW = "Caw Tweeter clothes",
		FEATHER_ROBIN = "Red Tweeter clothes",
		FEATHER_ROBIN_WINTER = "Snow Tweeter clothes",
		FEATHERPENCIL = "Draws pretty pictures",
		FEM_PUPPET = "Friend?",
		FIREFLIES =
		{
			GENERIC ="Glow Bums",
			HELD = "Needs home",
		},
		FIREHOUND = "Fire Woofers",
		FIREPIT =
		{
			EMBERS = "Dying",
			GENERIC = "Not too close",
			HIGH = "Too high!",
			LOW = "Stay back",
			NORMAL = "Not too close",
			OUT = "Whew. No fire",
		},
		COLDFIREPIT =
		{
			EMBERS ="Almost gone",
			GENERIC = "Chilly",
			HIGH ="Pretty",
			LOW = "Getting warmer",
			NORMAL = "Cooling",
			OUT ="Needs food",
		},
		FIRESTAFF = "Hot Pew Stick",
		FIRESUPPRESSOR = 
		{	
			ON = "Good machine",
			OFF ="Keep fire away",
			LOWFUEL = "Needs food",
		},

		FISH = "Glub Glub",
		FISHINGROD = "Glub Glub Stick",
		FISHSTICKS = "Glub Glub on a friend",
		FISHTACOS = "What's wrong with eyes, Glub Glub?",
		FISH_COOKED = "Watch for bones",
		FLINT = "Sharp stone",
		FLOWER = 
		{
            GENERIC = "Friend!",
            ROSE = "Pretty! Pretty friend!",
        },
        FLOWER_WITHERED = "Oh, friend. What's wrong?",
		FLOWERHAT = "Friends for head",
		FLOWER_EVIL = "What happened, friend?",
		FOLIAGE = "Friend. Good friend",
		FOOTBALLHAT = "Twirly Tail head thing",
		FOSSIL_PIECE = "Where the rest?",
        FOSSIL_STALKER =
        {
			GENERIC = "Not done yet",
			FUNNY = "Oops. Made wrong",
			COMPLETE = "All better",
        },
        STALKER = "Branches? Or bones?",
        STALKER_ATRIUM = "Aggh! Big Bone Roarer!",
        STALKER_MINION = "Big Bone Roarer has tiny pals!",
        THURIBLE = "Burns dark fire",
        ATRIUM_OVERGROWTH = "Don't know those scribbles",
		FROG =
		{
			DEAD ="Oh",
			GENERIC ="Ribbit",
			SLEEPING = "Tired",
		},
		FROGGLEBUNWICH = "Fills belly",
		FROGLEGS = "Ribbit legs",
		FROGLEGS_COOKED = "Legs for belly",
		FRUITMEDLEY = "Fruit party!",
		FURTUFT = "Molt (sniff sniff) Smells good",
		GEARS = "Machine food",
		GHOST = "Floaty man!",
		GOLDENAXE = "Pretty. Pretty scary",
		GOLDENPICKAXE = "Pretty Pokey",
		GOLDENPITCHFORK = "Pretty Ground Getter",
		GOLDENSHOVEL ="Pretty Digger",
		GOLDNUGGET = "Little Yellow Stone",
		GRASS =
		{
			BARREN = "Needs poop",
			WITHERED = "Too hot!",
			BURNING = "Agghh!",
			GENERIC = "Smells nice",
			PICKED = "Nice trim!",
			DISEASED = "Sick! Sick friend!",
			DISEASING = "Get better soon",
		},
		GRASSGEKKO = 
		{
			GENERIC = "Looking good. Like hair",
			DISEASED = "Sick?",
		},
		GREEN_CAP = "Hurts head",
		GREEN_CAP_COOKED ="Helps head",
		GREEN_MUSHROOM =
		{
			GENERIC = "Green mushy",
			INGROUND = "Hiding",
			PICKED = "Gone",
		},
		GUNPOWDER = "BOOM!",
		HAMBAT = "Twirly Tail Whacker",
		HAMMER = "Smasher",
		HEALINGSALVE = "Boo Boo Gloop",
		HEATROCK =
		{
			FROZEN = "Brrrr...",
			COLD = "Cold",
			GENERIC = "Hot cold rock",
			WARM = "Warm",
			HOT = "Yeeouch!",
		},
		HOME = "Home",
		HOMESIGN =
		{
			GENERIC = "Scribbles on friends",
            UNWRITTEN = "Needs scribbles",
			BURNT = "(sigh)",
		},
		ARROWSIGN_POST =
		{
			GENERIC ="Pointy friend",
            UNWRITTEN = "Needs scribbles",
			BURNT = "oh. (sob)",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Pointy friend",
            UNWRITTEN = "Needs scribbles",
			BURNT = "oh. (sob)",
		},
		HONEY ="Buzz Juice",
		HONEYCOMB ="From Buzz home",
		HONEYHAM = "Poor Twirly Tail...",
		HONEYNUGGETS = "Buzz Juice and Twirly Tails",
		HORN = "Branch?",
		HOUND = "Woofer! Woof! Woof!",
		HOUNDBONE = "Sharp!",
		HOUNDMOUND = "Woofers around?",
		ICEBOX = "Keeps belly stuff cold",
		ICEHAT ="Cool hat!",
		ICEHOUND = "Brrr Woofer",
		INSANITYROCK =
		{
			ACTIVE = "Ow. Hurts head...",
			INACTIVE = "Hiding",
		},
		JAMMYPRESERVES = "Sweet belly stuff",
		KABOBS = "Meat is belly stuff. Stick is not",
		KILLERBEE =
		{
			GENERIC = "Bad Buzz! Bad!",
			HELD = "Needs home",
		},
		KNIGHT = "Neigh machine",
		KOALEFANT_SUMMER = "Bruamp! Bruamp!",
		KOALEFANT_WINTER = "Bruamp! Bruamp!",
		KRAMPUS = "Mean Branch Head",
		KRAMPUS_SACK = "Full of stuff?",
		LEIF = "Hello!... Hello?",
		LEIF_SPARSE = "Friend?",
		LIGHTER  = "Fire box!",
		LIGHTNING_ROD =
		{
			CHARGED = "Zzzzt! Zzzzt!",
			GENERIC = "Zzzzt Stick",
		},
		LIGHTNINGGOAT = 
		{
			GENERIC = "Lovely head branches",
			CHARGED = "Yaaah!",
		},
		LIGHTNINGGOATHORN ="From Twirly Branch Head",
		GOATMILK = "Mmmm...",
		LITTLE_WALRUS = "Teeth Branches",
		LIVINGLOG = "Friend. Nice friend",
		LOG =
		{
			BURNING = "AAAHHHHHH!",
			GENERIC = "Sorry. So sorry",
		},
		LUCY = "Aggah! Stay back, please!",
		LUREPLANT = "Careful!",
		LUREPLANTBULB = "For dirt",
		MALE_PUPPET = "Friend?",

		MANDRAKE_ACTIVE = "Merp! Merp! Meep! Merp!",
		MANDRAKE_PLANTED = "Hiding",
		MANDRAKE = "Need friend?",

		MANDRAKESOUP = "Sleepytime soup",
		MANDRAKE_COOKED = "Smells sleepy",
		MAPSCROLL = "Findy Paper!",
		MARBLE = "Solid",
		MARBLEBEAN = "Baby Stone Friend!",
		MARBLEBEAN_SAPLING = "So cute...",
        MARBLESHRUB = "Stone? Stone friend?",
		MARBLEPILLAR = "Good trunk. Solid",
		MARBLETREE = "Friend? Solid friend",
		MARSH_BUSH =
		{
			BURNING = "AGGGH!!!",
			GENERIC = "Twisty friend",
			PICKED = "Keep growing!",
		},
		BURNT_MARSH_BUSH = "oh. (sob)",
		MARSH_PLANT = "Hello, little guy",
		MARSH_TREE =
		{
			BURNING = "YAAAAAAHH!",
			BURNT = "Oh",
			CHOPPED = "(sob)",
			GENERIC = "Sleeping. Shh...",
		},
		MAXWELL = "Not friend",
		MAXWELLHEAD = "Not friend head",
		MAXWELLLIGHT = "Bright rock",
		MAXWELLLOCK = "Needs key",
		MAXWELLTHRONE = "Smells bad",
		MEAT = "For belly",
		MEATBALLS = "Balls of belly stuff",
		MEATRACK =
		{
			DONE = "Done",
			DRYING = "Getting unwet",
			DRYINGINRAIN = "Rain can't help",
			GENERIC = "Takes out wet",
			BURNT = "Oh",
		},
		MEAT_DRIED = "Dried up belly stuff",
		MERM = "Glub Glub Man",
		MERMHEAD = 
		{
			GENERIC = "Rotten",
			BURNT = "Just ashes",
		},
		MERMHOUSE = 
		{
			GENERIC = "Glub Glub Man home",
			BURNT = "Fire is bad",
		},
		MINERHAT = "Fits",
		MONKEY = "Cheeky",
		MONKEYBARREL = "Full of Cheekies",
		MONSTERLASAGNA = "For belly?",
		FLOWERSALAD = "Want to eat it",
        ICECREAM = "Keeps belly cold",
        WATERMELONICLE = "Keeping cool, stick?",
        TRAILMIX = "Belly stuff for belly",
        HOTCHILI = "Hot! It's hot!",
        GUACAMOLE = "Cute!",
		MONSTERMEAT = "Belly stuff?",
		MONSTERMEAT_DRIED = "Hmmm...",
		MOOSE = "Branch Head Tweeter",
		MOOSE_NESTING_GROUND = "Sticks!",
		MOOSEEGG = "Tweeter inside",
		MOSSLING = "Why so hungry?",
		FEATHERFAN = "Fire Outer",
        MINIFAN = "Wheeee!",
		GOOSE_FEATHER = "Tickles. Hehe!",
		STAFF_TORNADO = "Makes big winds!",
		MOSQUITO =
		{
			GENERIC = "Bzzt",
			HELD = "It's bzzt-ing",
		},
		MOSQUITOSACK = "Bzzt Bum",
		MOUND =
		{
			DUG = "Dug up",
			GENERIC = "Dirt hill",
		},
		NIGHTLIGHT = "Glowy",
		NIGHTMAREFUEL = "Dark Floaty Man",
		NIGHTSWORD = "Dark Floaty Swoosh Stick",
		NITRE = "Pow Rock",
		ONEMANBAND = "Boom! Boom! Crash!",
		OASISLAKE = 
		{
			GENERIC = "Water! Water!",
			EMPTY = "Oh. Empty",
		},
		PANDORASCHEST = "Stuff!",
		PANFLUTE = "Toot!",
		PAPYRUS = "Flat friends",
		WAXPAPER = "Shiny paper. So shiny...",
		PENGUIN = "Woddle Woddle",
		PERD = "Hidey Tweeter",
		PEROGIES = "Good belly stuff",
		PETALS = "Smells good",
		PETALS_EVIL = "Hmmm... smells bad",
		PHLEGM = "Hork",
		PICKAXE = "Pokey",
		PIGGYBACK = "Carries stuff",
		PIGHEAD = 
		{	
			GENERIC = "Rot inside",
			BURNT = "Ashes",
		},
		PIGHOUSE =
		{
			FULL = "Hello?",
			GENERIC = "Twirly Tail home",
			LIGHTSOUT = "Twirly Tail not home",
			BURNT = "Oh. Don't like fire",
		},
		PIGKING = "Twirly Tail Boss",
		PIGMAN =
		{
			DEAD = "Aww...",
			FOLLOWER = "Twirly Tail friend",
			GENERIC = "Hello Twirly Tail!",
			GUARD = "Twirly Tail Tough Guy",
			WEREPIG = "Twirly Tail Woofer",
		},
		PIGSKIN = "Twirly Tail Bum",
		PIGTORCH = "Hello! Hello! Hello! Hello!",
		PINECONE = "Aw... Little baby friends",
        PINECONE_SAPLING = "Getting big!",
        LUMPY_SAPLING = "Keep growing!",
		PITCHFORK = "Dirt Getter",
		PLANTMEAT = "Meat from dirt",
		PLANTMEAT_COOKED = "Good for belly",
		PLANT_NORMAL =
		{
			GENERIC = "Dirt stuff for belly",
			GROWING = "Almost there!",
			READY = "Thank you, dirt!",
			WITHERED = "Sick?",
		},
		POMEGRANATE = "Seedy fruit",
		POMEGRANATE_COOKED = "Good belly stuff",
		POMEGRANATE_SEEDS = "Needs dirt",
		POND = "Big puddle",
		POOP = "Mmm... Smells good!",
		FERTILIZER = "Poop! Yay!",
		PUMPKIN = "Good for belly",
		PUMPKINCOOKIE = "Belly wants it",
		PUMPKIN_COOKED = "Slurpy",
		PUMPKIN_LANTERN = "Spooky...",
		PUMPKIN_SEEDS = "For dirt",
		PURPLEAMULET ="Brain Neck Thing",
		PURPLEGEM = "Shiny",
		RABBIT =
		{
			GENERIC ="Bouncy Squee Hopper",
			HELD = "So soft",
		},
		RABBITHOLE = 
		{
			GENERIC = "Bouncy Squee Hopper home?",
			SPRING = "Where'd they go?",
		},
		RAINOMETER = 
		{	
			GENERIC ="Rain?",
			BURNT ="Ashes. Only ashes",
		},
		RAINCOAT = "Rain Taker Coat",
		RAINHAT = "Looks good?",
		RATATOUILLE = "Belly party!",
		RAZOR ="Sharp",
		REDGEM = "Red Shiny",
		RED_CAP = "Yummy friend hat",
		RED_CAP_COOKED = "Hurts head",
		RED_MUSHROOM =
		{
			GENERIC = "Squishy friend",
			INGROUND = "Hiding",
			PICKED = "Gone",
		},
		REEDS =
		{
			BURNING = "Save them!",
			GENERIC = "Water friends",
			PICKED = "Keep growing",
		},
        RELIC = 
        {
            GENERIC = "Old",
            BROKEN = "Broken",
        },
        RUINS_RUBBLE = "Can fix it?",
        RUBBLE = "Rocks",
		RESEARCHLAB = 
		{	
			GENERIC = "Makes more things!",
			BURNT = "Fire hurts everything",
		},
		RESEARCHLAB2 = 
		{
			GENERIC = "More things to make!",
			BURNT = "Too bad",
		},
		RESEARCHLAB3 = 
		{
			GENERIC = "More magics",
			BURNT = "Gone",
		},
		RESEARCHLAB4 = 
		{
			GENERIC ="Makes magics things",
			BURNT = "Why, fire? Why?!",
		},
		RESURRECTIONSTATUE = 
		{
			GENERIC = "Regrowing friends",
			BURNT = "Fire hurts everything",
		},		
		RESURRECTIONSTONE = "Life Rock",
		ROBIN =
		{
			GENERIC = "Red Tweeter",
			HELD ="Needs home",
		},
		ROBIN_WINTER =
		{
			GENERIC ="Snow Tweeter",
			HELD = "Needs home",
		},
		ROBOT_PUPPET = "Friend?",
		ROCK_LIGHT =
		{
			GENERIC = "Dirt is bleeding",
			OUT = "All better",
			LOW = "Healing",
			NORMAL = "Earth blood",
		},
		CAVEIN_BOULDER =
        {
            GENERIC ="Raining rocks?",
            RAISED = "Can't reach. Oh",
        },
		ROCK ="Rock. Hello",
		PETRIFIED_TREE = "Friend made of rock",
		ROCK_PETRIFIED_TREE = "Strong friend!",
		ROCK_PETRIFIED_TREE_OLD ="Hello, old friend!",
		ROCK_ICE = 
		{
			GENERIC = "Big, cold rock",
			MELTED ="Water now",
		},
		ROCK_ICE_MELTED = "Water now",
		ICE = "Cold. Really cold",
		ROCKS = "Rocks",
        ROOK = "Rock machine",
		ROPE = "Friends made string!",
		ROTTENEGG ="Smells good!",
		ROYAL_JELLY = "Bloopy belly stuff",
        JELLYBEAN = "Mmmmm!",
        SADDLE_BASIC = "Shaggy Buddy Sitting Thing",
        SADDLE_RACE = "Shaggy Buddy Zoomer!",
        SADDLE_WAR = "Shaggy Buddy Fight Thing",
        SADDLEHORN = "Sitting Thing Getter Offer",
        SALTLICK = "Lick rock. For Shaggy Buddy",
        BRUSH = "Buddies like the brushing",
		SANITYROCK =
		{
			ACTIVE = "Helps head",
			INACTIVE = "Hiding",
		},
		SAPLING =
		{
			BURNING = "NOOO!",
			WITHERED = "Poor friend",
			GENERIC = "Hello? Little friend?",
			PICKED = "Keep growing, friend!",
			DISEASED = "Sick. Very, very sick",
			DISEASING = "Looks sick. Poor little guy",
		},
		SCARECROW = 
   		{
			GENERIC ="Tweeter Friend",
			BURNING = "No! Save him!",
			BURNT = "Oh",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "No rock yet",
			BLOCK = "What to make?",
			SCULPTURE ="Fun! Want to do again!",
			BURNT = "Nooooo!",
   		},
        SCULPTURE_KNIGHTHEAD = "Hello Neigher!",
		SCULPTURE_KNIGHTBODY = 
		{
			COVERED = "Like it!",
			UNCOVERED = "Needs help?",
			FINISHED = "Looks good!",
			READY = "Something moving?",
		},
        SCULPTURE_BISHOPHEAD = "Where's rest?",
		SCULPTURE_BISHOPBODY = 
		{
			COVERED = "Looks good!",
			UNCOVERED = "Broken?",
			FINISHED = "Fixed now",
			READY = "Hello? Anyone there?",
		},
        SCULPTURE_ROOKNOSE = "Can lift it?",
		SCULPTURE_ROOKBODY = 
		{
			COVERED = "Nice looking rock",
			UNCOVERED = "Needs fixing",
			FINISHED = "Better now",
			READY = "Something moving?",
		},
        GARGOYLE_HOUND = "Just stone",
        GARGOYLE_WEREPIG = "Arrrooooo!",
		SEEDS = "Wants dirt",
		SEEDS_COOKED = "Mmmm...",
		SEWING_KIT = "Fixey kit",
		SEWING_TAPE ="Sticky ribbon",
		SHOVEL = "Digger",
		SILK = "Soft",
		SKELETON = "Still alive?",
		SCORCHED_SKELETON = "Oh. Oh no",
		SKULLCHEST = "Stuff inside",
		SMALLBIRD =
		{
			GENERIC = "Baby Eye Tweeter",
			HUNGRY = "Hungry?",
			SLEEPING = "Shh... Sleeping",
			STARVING = "Needs stuff for belly!!",
		},
		SMALLMEAT = "Little belly thing",
		SMALLMEAT_DRIED = "Chewy",
		SPAT ="Horkbeast",
		SPEAR = "Sharp stick",
		SPEAR_WATHGRITHR = "Sharp",
		WATHGRITHRHAT = "Pokey branch hat",
		SPIDER =
		{
			DEAD = "Oh",
			GENERIC ="Leggy Bug",
			SLEEPING = "Shh...",
		},
		SPIDERDEN = "Home for Leggy Bugs",
		SPIDEREGGSACK = "Leggy Bug Babies inside",
		SPIDERGLAND = "Good for heart",
		SPIDERHAT = "Leggy Bug head thing",
		SPIDERQUEEN = "Leggy Bug Mommy",
		SPIDER_WARRIOR =
		{
			DEAD = "Oh",
			GENERIC = "Angry Leggy Bug",
			SLEEPING = "Sleepytime",
		},
		SPOILED_FOOD = "Yum",
        STAGEHAND =
        {
			AWAKE ="Ohh! Table friend!",
			HIDING ="Too shy?",
        },
        STATUE_MARBLE = 
        {
            GENERIC = "Like it",
            TYPE2 = "No head? Where's head?",
            TYPE1 = "Why so sad?",
        },
		STATUEHARP = "Where'd head go?",
		STATUEMAXWELL ="Alive?",
		--...
		STEELWOOL = "Horkbeast clothes",
		STINGER ="Youchy!",
		STRAWHAT = "Friend hat",
		STUFFEDEGGPLANT = "Stuffed belly stuff",
		SWEATERVEST = "Warm",
		REFLECTIVEVEST = "For the hot times",
		HAWAIIANSHIRT = "Breezy",
		TAFFY = "Chewy goo",
		TALLBIRD = "Big Eye Tweeter",
		TALLBIRDEGG = "Eye Tweeter inside?",
		TALLBIRDEGG_COOKED = "For belly",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Needs warm",
			GENERIC = "Tweet! ",
			HOT = "Too hot!",
			LONG = "(yawn)",
			SHORT ="Tweeter coming soon!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "Tweet! Tweet!",
			PICKED = "Eye Tweeter sticks",
		},
		TEENBIRD =
		{
			GENERIC = "Eye Tweeter is growing!",
			HUNGRY = "Hungry?",
			SLEEPING = "Shh... Sleepytime",
			STARVING = "Needs belly stuff",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Open",
			GENERIC = "Hmm...",
			LOCKED = "Key?",
			PARTIAL = "Needs more things",
		},
		TELEPORTATO_BOX = "Box",
		TELEPORTATO_CRANK = "Crank",
		TELEPORTATO_POTATO = "Thing",
		TELEPORTATO_RING = "Ring",
		TELESTAFF = "Poof stick",
		TENT = 
		{
			GENERIC = "Little home",
			BURNT = "Turned to ash",
		},
		SIESTAHUT = 
		{
			GENERIC = "Nap time?",
			BURNT = "No more naptime",
		},
		TENTACLE = "Arms from the dirt",
		TENTACLESPIKE = "Spiky Whacker",
		TENTACLESPOTS = "Spots. Pretty spots",
		TENTACLE_PILLAR = "Sleeping",
        TENTACLE_PILLAR_HOLE = "Hello?",
		TENTACLE_PILLAR_ARM = "Little Dirt Arms",
		TENTACLE_GARDEN = "Sleeping",
		TOPHAT = "Soft head thing",
		TORCH = "Fire Stick",
		TRANSISTOR = "It's humming! Hummm...",
		TRAP = "Snap!",
		TRAP_TEETH = "Hurty Spikes",
		TRAP_TEETH_MAXWELL = "Hurty Spikes",
		TREASURECHEST = 
		{
			GENERIC = "Stuff!",
			BURNT = "(sigh)",
		},
		TREASURECHEST_TRAP = "Hmm...",
		SACRED_CHEST = 
		{
			GENERIC = "Put stuff in there!",
			LOCKED = "Stuff is gone",
		},
		TREECLUMP = "Party!",
		
		TRINKET_1 = "Swirly rocks",
		TRINKET_2 = "Hummm...",
		TRINKET_3 = "Twisty string",
		TRINKET_4 = "Pointy hat little man",
		TRINKET_5 = "Pakow!",
		TRINKET_6 = "Zzzt",
		TRINKET_7 = "Wood?",
		TRINKET_8 = "Pretty",
		TRINKET_9 = "Rocks?",
		TRINKET_10 = "Chatters",
		TRINKET_11 = "Hello!",
		TRINKET_12 = "Sticky",
		TRINKET_13 = "Hello!... Hello?",
		TRINKET_14 = "Can't drink from it",
		TRINKET_15 = "Can't play",
		TRINKET_16 = "Can't play",
		TRINKET_17 = "Pokey shiny thing",
		TRINKET_18 = "Wheee!",
		TRINKET_19 = "Twirly!",
		TRINKET_20 = "(scritch, scritch)",
		TRINKET_21 = "Hmm... Can't use it",
		TRINKET_22 = "Ball!",
		TRINKET_23 = "What's this?",
		TRINKET_24 = "Me-Raow? Oh. Not alive",
		TRINKET_25 = "Little friend?",
		TRINKET_26 = "Hmm... What's this for?",
		TRINKET_27 = "Stick? No not stick",
		TRINKET_28 = "Can't play", --Rook
        TRINKET_29 = "Anyone to play with?", --Rook
        TRINKET_30 = "Little Neigher", --Knight
        TRINKET_31 = "Little Neigher", --Knight
        TRINKET_32 = "Ball!", --Cubic Zirconia Ball
        TRINKET_33 = "Hello? Oh. Not alive", --Spider Ring
        TRINKET_34 = "Where's rest?", --Monkey Paw
        TRINKET_35 = "Empty", --Empty Elixir
		TRINKET_36 = "Pokey teeth", --Faux fangs
		TRINKET_37 = "Oh. What happened?", --Broken Stake
		TRINKET_38 = "Makes things big!",-- Binoculars Griftlands trinket
        TRINKET_39 = "Doesn't fit", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Can't use it", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Goop inside", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Aggh! Oh. Not real", -- Toy Cobra Hot Lava trinket
        TRINKET_43 = "Wheeee!", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Friend has broken home", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Not working", -- Odd Radio ONI trinket
        TRINKET_46 = "What's this?", -- Hairdryer ONI trinket

		HALLOWEENCANDY_1 = "Careful! Don't eat stick", --Candy Apple
        HALLOWEENCANDY_2 = "Not for dirt",--Candy Corn
        HALLOWEENCANDY_3 = "Yum!", --Not-So-Candy Corn
        HALLOWEENCANDY_4 = "Squishy", --Gummy Spider
        HALLOWEENCANDY_5 = "Hehe!", --Catcoon Candy
        HALLOWEENCANDY_6 = "Sweet stuff for belly", --\"Raisins\"
        HALLOWEENCANDY_7 = "Belly stuff", --Raisins
        HALLOWEENCANDY_8 = "Sad?", --Ghost Pop
        HALLOWEENCANDY_9 = "Wiggly!", --Jelly Worm
        HALLOWEENCANDY_10 = "Mmm...", --Tentacle Lolli
        HALLOWEENCANDY_11 = "Twirly Tail?", --Choco Pigs
        HALLOWEENCANDY_12 = "Yum!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Ball of belly stuff!",	--Griftlands themed candy
        HALLOWEENCANDY_14 = "Ho! Ha! Hot belly stuff!",	--Hot Lava pepper candy
        CANDYBAG = "Holds sweet belly stuff!",

        HALLOWEEN_ORNAMENT_1 = "Ooooooo!",
		HALLOWEEN_ORNAMENT_2 = "Not flapping",
		HALLOWEEN_ORNAMENT_3 = "Not alive",
		HALLOWEEN_ORNAMENT_4 = "Spiky pretty thing", 
		HALLOWEEN_ORNAMENT_5 = "Haha! Wrong way Leggy Bug", 
		HALLOWEEN_ORNAMENT_6 = "Alive, Tweeter? Nope",

		HALLOWEENPOTION_DRINKS_WEAK = "Little thing for belly",
		HALLOWEENPOTION_DRINKS_POTENT = "Big thing for belly",
		HALLOWEENPOTION_FIRE_FX ="Ka-POW! inside",
		HALLOWEENPOTION_BRAVERY = "Makes strong!",
		MADSCIENCE_LAB = "For making scaries",
		LIVINGTREE_ROOT = "Needs dirt",
		LIVINGTREE_SAPLING = "Keep growing, friend!",

        DRAGONHEADHAT = "Patuey Head looks good!",
        DRAGONBODYHAT = "Where's rest?",
        DRAGONTAILHAT = "Can wear bottom for head",
        PERDSHRINE =
        {
            GENERIC = "Found a Hidey Tweeter!",
            EMPTY = "Needs belly stuff",
            BURNT = "No! AGGGH!",
        },
        REDLANTERN = "Pretty light",
        LUCKY_GOLDNUGGET = "Yellow Rock Round Thing",
        FIRECRACKERS = "POP! POP!",
        PERDFAN = "Makes wind",
        REDPOUCH = "What's inside?",
        WARGSHRINE = 
        {
            GENERIC = "Yellow Woofer has house",
            EMPTY = "Needs fire",
            BURNT = "Too much fire",
        },
        CLAYWARG = 
        {
        	GENERIC = "Aggh! Alive now!",
        	STATUE = "Real Woofer?",
        },
        CLAYHOUND = 
        {
        	GENERIC = "Too much moving now!",
        	STATUE = "Good Woofer. Stay",
        },
        HOUNDWHISTLE = "Tweet Tweet for Woofer",
        CHESSPIECE_CLAYHOUND = "Alive? Hmmm...",
        CHESSPIECE_CLAYWARG = "Stay stone, please",

        PIGSHRINE =
		{
            GENERIC = "Little Twirly Tail House",
            EMPTY = "Needs belly stuff",
            BURNT = "Why, fire? Why?",
		},
		PIG_TOKEN = "Oh. Doesn't fit",
		YOTP_FOOD1 = "You okay, Twirly Tail?",
		YOTP_FOOD2 = "Oh... can't eat it",
		YOTP_FOOD3 = "Glub Glub on friends",

		PIGELITE1 = "Hello, Twirly Tail!", --BLUE
		PIGELITE2 = "Angry Twirly Tail", --RED
		PIGELITE3 = "Friend?", --WHITE
		PIGELITE4 = "Like him", --GREEN
		
		BISHOP_CHARGE_HIT = "Aggh!",
		TRUNKVEST_SUMMER = "Cool",
		TRUNKVEST_WINTER = "Warm",
		TRUNK_COOKED = "For belly?",
		TRUNK_SUMMER = "Bruamp nose",
		TRUNK_WINTER = "Bruamp nose",
		TUMBLEWEED = "Come back!",
		TURKEYDINNER = "Lots of belly stuff",
		TWIGS = "Little friends! Hi!",
		UMBRELLA = "Rain Taker",
		GRASS_UMBRELLA = "Friend hair keeps rain away",
		UNIMPLEMENTED = "Hmm...",
		WAFFLES = "Yum",
		WALL_HAY = 
		{	
			GENERIC = "Wall of friends",
			BURNT = "Bye bye, friends",
		},
		WALL_HAY_ITEM = "Hi, friends!",
		WALL_STONE = "Solid",
		WALL_STONE_ITEM = "For the ground",
		WALL_RUINS = "Strong",
		WALL_RUINS_ITEM = "For the ground",
		WALL_WOOD = 
		{
			GENERIC = "So many friends",
			BURNT = "Noo!!",
		},
		WALL_WOOD_ITEM = "Friends!",
		WALL_MOONROCK = "Hard",
		WALL_MOONROCK_ITEM = "For the ground",
		FENCE = "Made of friends",
        FENCE_ITEM = "Put in ground",
        FENCE_GATE = "Door made of friends",
        FENCE_GATE_ITEM = "Put in ground",
		WALRUS = "Grows mouth branches?",
		WALRUSHAT = "Floppy head thing",
		WALRUS_CAMP =
		{
			EMPTY = "No one here",
			GENERIC = "Ball home",
		},
		WALRUS_TUSK = "Tooth branch",
		WARDROBE = 
		{
			GENERIC = "Friends holding clothes",
            BURNING = "AGHHH!",
			BURNT = "Fire bad",
		},
		WARG = "Big Bad Woofer",
		WASPHIVE = "Bad Buzz home",
		WATERBALLOON = "Water Booper",
		WATERMELON = "Watery Sweet belly stuff",
		WATERMELON_COOKED = "Slurpy",
		WATERMELONHAT = "Watery head thing",
		WAXWELLJOURNAL = "Nope",
		WETGOOP = "Yum",
        WHIP = "Snappy Kitty Tail",
		WINTERHAT = "Looks good",
		WINTEROMETER = 
		{
			GENERIC = "Warm? Cold?",
			BURNT = "Noo!",
		},

		WINTER_TREE =
        {
			BURNT = "NOOOOOO!",
			BURNING = "Help! Help!",
			CANDECORATE = "Make pretty!",
			YOUNG = "So cute...",
        },
        WINTER_TREESTAND = 
        {
	        GENERIC = "For friends",
	        BURNT = "So sad...",
		},
        WINTER_ORNAMENT = "So pretty",
        WINTER_ORNAMENTLIGHT = "Shiny thing...",
        WINTER_ORNAMENTBOSS = "Put on friends",
        WINTER_ORNAMENTFORGE = "It goes on friend",
		WINTER_ORNAMENTGORGE = "For friends to feel pretty",
        
        WINTER_FOOD1 = "Friend?", --gingerbread cookie
        WINTER_FOOD2 = "Oh. Didn't fall from sky", --sugar cookie
        WINTER_FOOD3 = "Mmm... Sweet belly thing", --candy cane
        WINTER_FOOD4 = "So many little colors!", --fruitcake
        WINTER_FOOD5 = "Friend?!... Oh. Nope", --yule log cake
        WINTER_FOOD6 = "Ball goes in belly", --plum pudding
        WINTER_FOOD7 = "Haha! Friend made a drink!", --apple cider
        WINTER_FOOD8 = "Mmm... Makes belly warm", --hot cocoa
        WINTER_FOOD9 = "Makes belly full", --eggnog

        KLAUS = "Hello! Friend?",
        KLAUS_SACK = "Prize inside?",
		KLAUSSACKKEY = "Branch? No",
		WORMHOLE =
		{
			GENERIC = "Sharp hole",
			OPEN = "Deep. Dark",
		},
		WORMHOLE_LIMITED = "Get well soon",
		ACCOMPLISHMENT_SHRINE = "Pretty!",       
		LIVINGTREE = "Friend?",
		ICESTAFF = "Chilly stick",
		REVIVER = "Ba-bum. Ba-bum",
		SHADOWHEART = "Cold. But still beating...",
		ATRIUM_RUBBLE = 
        {
			LINE_1 = "Story!",
			LINE_2 = "Can't read it",
			LINE_3 = "Black. Lots of black",
			LINE_4 = "Oh! People changing!",
			LINE_5 = "Pretty picture!",
		},
        ATRIUM_STATUE = "Still alive?",
        ATRIUM_LIGHT = 
        {
			ON = "Light!",
			OFF = "Not working",
		},
        ATRIUM_GATE =
        {
			ON = "Working now!",
			OFF = "Needs fixing",
			CHARGING = "Oh. What's it doing?",
            DESTABILIZING = "Looks sick",
            COOLDOWN = "Tired?",
        },
        ATRIUM_KEY = "Goes where?",
		LIFEINJECTOR = "Makes strong!",
		SKELETON_PLAYER =
		{
			MALE = "Oh. Friend not alive",
			FEMALE = "Still alive? No",
			ROBOT = "Oh. Not alive",
			DEFAULT = "Oh. Friend not alive",
		},
		HUMANMEAT = "Belly stuff",
		HUMANMEAT_COOKED = "Mmmm...",
		HUMANMEAT_DRIED = "Chewy",
		ROCK_MOON = "Night Ball inside?",
		MOONROCKNUGGET = "Piece of Night Ball",
		MOONROCKCRATER = "Big bump in it",
		MOONROCKSEED = "Makes Night Ball things",

        REDMOONEYE = "Ball with Shiny",
        PURPLEMOONEYE = "Shows on Findy Paper",
        GREENMOONEYE = "Like this one",
        ORANGEMOONEYE = "Shiny shows on Findy Paper",
        YELLOWMOONEYE = "Ooooh. Shiny",
        BLUEMOONEYE = "Glowy ball",

        --Arena Event
        LAVAARENA_BOARLORD = "Nice head branches, boss guy!",
        BOARRIOR = "Twirly Tail is mad",
        BOARON = "Little crawling Twirly Tails",
        PEGHOOK = "Tail Patoo-ies! Watch out!",
        TRAILS = "Likes to hide",
        TURTILLUS = "Spiny Shell likes the spins",
        SNAPPER = "No biting! Bad!",
        RHINODRILL = "Aww... bro love",
		BEETLETAUR = "Where's other eye?",
        
        LAVAARENA_PORTAL = 
        {
            ON = "Can go now",
            GENERIC = "Not working",
        },
        LAVAARENA_KEYHOLE = "Where's key?",
        LAVAARENA_KEYHOLE_FULL = "Open now",
        LAVAARENA_BATTLESTANDARD = "Break it!",
        LAVAARENA_SPAWNER = "Makes the bad guys",

        HEALINGSTAFF = "Make friends better",
        FIREBALLSTAFF = "Fire Pew-er",
        HAMMER_MJOLNIR = "Ugh! Can't lift it",
        SPEAR_GUNGNIR = "Don't like it",
        BLOWDART_LAVA = "Makes lots of patoo-eys",
        BLOWDART_LAVA2 = "Fire!",
        LAVAARENA_LUCY = "Ugh! Don't like chopping!",
        WEBBER_SPIDER_MINION = "Baby Leggy Bugs like helping",
        BOOK_FOSSIL = "Can't read",
		LAVAARENA_BERNIE = "So cute!",
		SPEAR_LANCE = "Pokey stick",
		BOOK_ELEMENTAL = "Calls little Fire Friends",
		LAVAARENA_ELEMENTAL = "Watch out for Fire Friends!",

        LAVAARENA_ARMORLIGHT = "Clothes make safer",
		LAVAARENA_ARMORLIGHTSPEED = "Zoomy clothes!",
		LAVAARENA_ARMORMEDIUM = "Friends made Safe Clothes!",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Oh! Pokey Clothes!",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Pretty Friend clothes",
		LAVAARENA_ARMORHEAVY = "Really Safe Clothes!",
		LAVAARENA_ARMOREXTRAHEAVY = "Heavy clothes make safe",

		LAVAARENA_FEATHERCROWNHAT = "Zoomy Head Thing",
        LAVAARENA_HEALINGFLOWERHAT = "Oooh! Hello, pretty friend!",
        LAVAARENA_LIGHTDAMAGERHAT = "For safe head keeping",
        LAVAARENA_STRONGDAMAGERHAT = "Branches! Metal branches!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Like this one!",
        LAVAARENA_EYECIRCLETHAT = "Head Thing has the magics!",
        LAVAARENA_RECHARGERHAT = "Pretty head thing!",
        LAVAARENA_HEALINGGARLANDHAT = "Friends! Lots of friends!",
        LAVAARENA_CROWNDAMAGERHAT = "Big branches for head!",

        LAVAARENA_ARMOR_HP = "Safe clothes!",

		LAVAARENA_FIREBOMB = "Scary boomer",
		LAVAARENA_HEAVYBLADE = "Chop cutter",

        --Quagmire
        QUAGMIRE_ALTAR = 
        {
        	GENERIC = "Needs belly stuff",
            FULL = "For you, Sky Mouth!",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Oh. Not alive",
		QUAGMIRE_PARK_FOUNTAIN = "Where's water?",
		--
        QUAGMIRE_HOE = "Dirt comber",
        --
        QUAGMIRE_TURNIP = "Cute little dirt friend",
        QUAGMIRE_TURNIP_COOKED = "Makes good belly stuff",
        QUAGMIRE_TURNIP_SEEDS = "Mystery baby",
        --
        QUAGMIRE_GARLIC = "Mmm... Smelly Dirt thing!",
        QUAGMIRE_GARLIC_COOKED = "Mmm... Smells good",
        QUAGMIRE_GARLIC_SEEDS = "Mystery baby",
        --
        QUAGMIRE_ONION = "Makes wet eyes",
        QUAGMIRE_ONION_COOKED = "Sky Belly will like this",
        QUAGMIRE_ONION_SEEDS = "Mystery baby",
        --
        QUAGMIRE_POTATO = "Thanks, dirt!",
        QUAGMIRE_POTATO_COOKED = "Dirt makes good belly stuff",
        QUAGMIRE_POTATO_SEEDS = "Mystery baby",
        --
        QUAGMIRE_TOMATO = "Oh! Squishy ball",
        QUAGMIRE_TOMATO_COOKED = "Made little red circles",
        QUAGMIRE_TOMATO_SEEDS = "Mystery baby",
        --
        QUAGMIRE_FLOUR = "Dust for belly stuff",
        QUAGMIRE_WHEAT = "Oh! Pretty seeds!",
        QUAGMIRE_WHEAT_SEEDS = "Mystery baby",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Mystery baby",
        --
        QUAGMIRE_ROTTEN_CROP = "Mmm...Smells good",
        --
		QUAGMIRE_SALMON = "Glub Glub from ground",
		QUAGMIRE_SALMON_COOKED = "Sky Belly will like it",
		QUAGMIRE_CRABMEAT = "Branch from Ground Pinchy",
		QUAGMIRE_CRABMEAT_COOKED = "Pinchy makes good belly stuff",
		QUAGMIRE_SUGARWOODTREE = 
		{
			GENERIC = "Sweet Friend!",
			STUMP = "Sorry",
			TAPPED_EMPTY = "Oh, friend. Sorry",
			TAPPED_READY = "Full of friend insides",
			TAPPED_BUGS = "Bugs hurt friend!",
			WOUNDED = "OUCH! Friend hurt",
		},
		QUAGMIRE_SPOTSPICE_SHRUB = 
		{
			GENERIC = "What's on hair, friend?",
			PICKED = "Hair cut already",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Hair from friend",
		QUAGMIRE_SPOTSPICE_GROUND = "Makes belly stuff good",
		QUAGMIRE_SAPBUCKET = "Mean Metal Thing",
		QUAGMIRE_SAP = "Friend insides are out now",
		QUAGMIRE_FERN = "Sky Belly will like it?",
        QUAGMIRE_FOLIAGE_COOKED = "Little belly stuff",
		
		QUAGMIRE_SALT_RACK =
		{
			READY = "Done!",
			GENERIC = "Getting Tasty Rocks",
		},

		QUAGMIRE_SALT_RACK_ITEM = "Gets the Tasty Rocks",

		QUAGMIRE_SAFE = 
		{
			GENERIC = "What's inside?",
			LOCKED = "Where's key?",
		},
		
		QUAGMIRE_KEY = "Where's lock?",
		QUAGMIRE_KEY_PARK = "Needs lock",
        QUAGMIRE_PORTAL_KEY = "Where's it go?",

		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Friends! Party!",
			PICKED = "Oh. Friends gone",
		},
		QUAGMIRE_MUSHROOMS = "Hello, friends!",
        QUAGMIRE_MEALINGSTONE = "Crushy rock",

		QUAGMIRE_PEBBLECRAB = "Ground Pinchy!",

		QUAGMIRE_POND_SALT = "Full of Tasty Rocks",
		--
		QUAGMIRE_RUBBLE_CARRIAGE = "Where going?",
        QUAGMIRE_RUBBLE_CLOCK = "Tic! Tic! Tic!",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Oh. Fell down",
        QUAGMIRE_RUBBLE_PUBDOOR = "Go anywhere? No",
        QUAGMIRE_RUBBLE_ROOF = "No one home",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "Broken",
        QUAGMIRE_RUBBLE_BIKE = "Can ride it?... Nope",
        QUAGMIRE_RUBBLE_HOUSE = {"Hello?", "Anyone home?", "Oh. No one here",},
        QUAGMIRE_RUBBLE_CHIMNEY = "What's happened?",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Not working",
        QUAGMIRE_MERMHOUSE = "You home, Glub Glub?",
        QUAGMIRE_SWAMPIG_HOUSE = "Anyone home?",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Oh. Broken",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Wrapped Arm Twirly Tail",
            SLEEPING = "Shhh",
        },
        QUAGMIRE_SWAMPIG = "Fuzzy Wuzzy Twirly Tail",
        --
        QUAGMIRE_PORTAL = "Can't go out",
        QUAGMIRE_SALTROCK = "Rock Tongue Stinger",
        QUAGMIRE_SALT = "Tasty Rocks. Mmmmm...",
        --food--
        QUAGMIRE_FOOD_BURNT = "Oh. Not good",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Made thing for Sky Belly",
            MISMATCH = "Not good",
            MATCH = "Good belly stuff",
            MATCH_BUT_SNACK = "Small belly stuff",
        },
        --
        QUAGMIRE_COIN1 = "Disc for spending",
        QUAGMIRE_COIN2 = "Can buy things now!",
        QUAGMIRE_COIN3 = "Sky Belly says \"Good Job\"",
        QUAGMIRE_COIN4 = "Big fancy spend disc!",
        QUAGMIRE_GOATMILK = "Floppy Ear Soup",
        QUAGMIRE_SYRUP = "Makes the sweet stuff",
        QUAGMIRE_SAP_SPOILED = "No no no!",
        QUAGMIRE_SEEDPACKET = "Aw... Babies!",
        ---
        QUAGMIRE_OVEN_ITEM = "Makes belly stuff hot",
        QUAGMIRE_OVEN = "Gives food fire bath",
        QUAGMIRE_POT = "BIG bubbly water place",
        QUAGMIRE_POT_SMALL = "Hoo! Makes water bubbly!",
        QUAGMIRE_POT_SYRUP = "Makes sweet blubbly",
        QUAGMIRE_POT_HANGER = "Holds clinky thing",
        QUAGMIRE_POT_HANGER_ITEM = "Needs fire",
        QUAGMIRE_GRILL = "Hot bars!",
        QUAGMIRE_GRILL_ITEM = "Needs fire",
        QUAGMIRE_GRILL_SMALL = "Teeny Hot Bars",
        QUAGMIRE_GRILL_SMALL_ITEM = "Needs fire",
        QUAGMIRE_CASSEROLEDISH = "Make belly stuff pretty",
        QUAGMIRE_CASSEROLEDISH_SMALL = "Put belly stuff here",
        QUAGMIRE_PLATE_SILVER = "Pretty food holder",
        QUAGMIRE_BOWL_SILVER = "Shiny food place",

        --
        QUAGMIRE_MERM_CART1 = "Junk trunk", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Wheely Push Thing", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Scary Floppy Ear",
        QUAGMIRE_PARK_ANGEL2 = "Scary Floppy Ear",
        QUAGMIRE_PARK_URN = "Smooth Dust Holder",
        QUAGMIRE_PARK_OBELISK = "Tall sharp stone",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Open now",
            LOCKED = "Where key?",
        },
        QUAGMIRE_PARKSPIKE = "Clinky sharp!",
        QUAGMIRE_CRABTRAP = "Ground Pinchy jail",
        QUAGMIRE_TRADER_MERM = "Gives good things",
        QUAGMIRE_TRADER_MERM2 = "Gives stuff for spend disc",
        --
        QUAGMIRE_GOATMUM = "Soft Floppy Ear Mommy",
        QUAGMIRE_GOATKID = "Small Floppy Ear Sprout",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Oh. Dead",
            GENERIC = "Grey Flap Tweeter",
            SLEEPING = "Sleeper Tweeter",
        },
        QUAGMIRE_LAMP_POST = "Bright light!",

        QUAGMIRE_BEEFALO = "Shaggy Buddy",
        QUAGMIRE_SLAUGHTERTOOL = "Mean things",

        QUAGMIRE_SAPLING = "Small cute!",
        QUAGMIRE_BERRYBUSH = "Sweet friend",

        QUAGMIRE_ALTAR_STATUE2 = "Moss friend house",
        QUAGMIRE_ALTAR_QUEEN = "Tall Still Floppy Ear",
        QUAGMIRE_ALTAR_BOLLARD = "Clinky stump",
        QUAGMIRE_ALTAR_IVY = "Frizzy hair friend",

        QUAGMIRE_LAMP_SHORT = "Light stick",

        --v2 Winona
        WINONA_CATAPULT =
        {
            GENERIC = "Big Rock Flinger!",
            OFF = "Not on",
            BURNING = "AGGGHH!",
            BURNT = "Fire bad",
        },
        WINONA_SPOTLIGHT =
        {
            GENERIC = "Friend made Followy Light!",
            OFF = "Where's light?",
            BURNING = "Help! Help!",
            BURNT = "Oh. So sad",
        },
        WINONA_BATTERY_LOW =
        {
            GENERIC = "Friends made machine feeder",
            LOWPOWER = "Getting tired",
            OFF = "Not working",
            BURNING = "No fire! No!",
            BURNT = "Fire hurt it",
        },
        WINONA_BATTERY_HIGH =
        {
            GENERIC = "Big Machine Feeder!",
            LOWPOWER = "Sleepy?",
            OFF = "Oh. Needs sparkly",
            BURNING = "No fire! No!",
            BURNT = "Fire hurt it",
        },

        BOATFRAGMENT01 = "Floaty got broken",
        BOATFRAGMENT02 = "Floaty got broken",
        BOATFRAGMENT03 = "Floaty got broken",
        BOATFRAGMENT04 = "Floaty got broken",
        BOATFRAGMENT05 = "Floaty got broken",
		BOAT_LEAK = "Floaty is spitting!",
        MAST = "Hello! Helping, Friend?",
        SEASTACK = "Oops! Watch out!",
        FISHINGNET = "Catches Glub Glubs",
        ANTCHOVIES = "Aww... so cute!",
        STEERINGWHEEL = "Which way?",
        ANCHOR = "Won't let Floaty move",
        BOATPATCH = "Floaty Fixer",
        DRIFTWOOD_TREE = 
        {
            BURNING = "No!!! Stop!",
            BURNT = "So sad. So sad",
            CHOPPED = "Oh. Sorry",
            GENERIC = "Hello, Watery Friend!",
        },

        DRIFTWOOD_LOG = "Going for swim, friend?",

        MOON_TREE = 
        {
            BURNING = "HELP!! HELP!!",
            BURNT = "(sob)",
            CHOPPED = "So sad",
            GENERIC = "Friend likes Night Ball",
        },
		MOON_TREE_BLOSSOM = "Lost?",

        MOONBUTTERFLY = 
        {
        	GENERIC = "Hehe! Glowy!",
        	HELD = "Hello, Flappy friend!",
        },
		MOONBUTTERFLYWINGS = "Can't fly with them",
        MOONBUTTERFLY_SAPLING = "Keep growing! You can do it!",
        ROCK_AVOCADO_FRUIT = "Too crusty",
        ROCK_AVOCADO_FRUIT_RIPE = "Rocks for belly",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Cooked belly stuff",
        ROCK_AVOCADO_FRUIT_SPROUT = "Baby friend needs dirt",
        ROCK_AVOCADO_BUSH = 
        {
        	BARREN = "Rest well, old friend",
			WITHERED = "Hot enough for you?",
			GENERIC = "Grows rocks for belly",
			PICKED = "No belly rocks yet",
			DISEASED = "Oh no! Friend is sick!",
			DISEASING = "Feeling okay, friend?",
			BURNING = "NOOO! AGH! HELP!",
		},
        DEAD_SEA_BONES = "Dead?",
        HOTSPRING = 
        {
        	GENERIC = "Pool party!",
        	BOMBED = "Warm now. Glowy",
        	GLASS = "Ice? Nope",
        },
        MOONGLASS = "Ouch! Sharp!",
        MOONGLASS_ROCK = "Clear Rock",
        BATHBOMB = "Friends made a ball!",
        TRAP_STARFISH =
        {
            GENERIC = "Nice teeth!",
            CLOSED = "Snap!",
        },
        DUG_TRAP_STARFISH = "Got it!",
        SPIDER_MOON = 
        {
        	GENERIC = "Night Ball make you mad?",
        	SLEEPING = "Shh... sleepy",
        	DEAD = "Oh. So sorry",
        },
        MOONSPIDERDEN = "Hello? Anyone here?",
		FRUITDRAGON =
		{
			GENERIC = "Growing belly stuff",
			RIPE = "Feeling warm...",
			SLEEPING = "Naptime",
		},
        PUFFIN =
        {
            GENERIC = "Swimmy Tweeter",
            HELD = "Hello there!",
            SLEEPING = "Night night",
        },

		MOONGLASSAXE = "Clear Rock Chopper",
		GLASSCUTTER = "Swoosh!",

        ICEBERG =
        {
            GENERIC = "Big Cold Water Rock!",
            MELTED = "Oh. Water now",
        },
        ICEBERG_MELTED = "Oh. Water now",

        MINIFLARE = "Makes pretty lights",

		MOON_FISSURE = 
		{
			GENERIC = "Makes head say 'Wee-aow, Wee-aow'", 
			NOLIGHT = "Hello? No one there",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Needs more things",
            GENERIC = "Saying stuff",
        },

        MOON_ALTAR_IDOL = "Oh... glowy!",
        MOON_ALTAR_GLASS = "What's this for?",
        MOON_ALTAR_SEED = "Glow ball! Fun!",

        MOON_ALTAR_ROCK_IDOL = "Trapped?",
        MOON_ALTAR_ROCK_GLASS = "Trapped?",
        MOON_ALTAR_ROCK_SEED = "Trapped?",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Can build Floaty stuff",
            BURNT = "Fire... (sigh)",
        },
        SEAFARER_KIT = "Makes the Floaty",
        BOAT_ITEM = "Needs water",
        STEERINGWHEEL_ITEM = "For pointing Floaty",
        ANCHOR_ITEM = "Heavy...",
        MUTATEDHOUND = 
        {
        	DEAD = "Dead now?",
        	GENERIC = "Where clothes, Woofer?",
        	SLEEPING = "Shh... Sleepytime",
        },

        MUTATED_PENGUIN = 
        {
			DEAD = "Oh. Dead",
			GENERIC = "You okay, Woddle Woddle?",
			SLEEPING = "Naptime",
		},
        CARRAT = 
        {
        	DEAD = "Oh. Dead",
        	GENERIC = "Belly stuff running away!",
        	HELD = "He he. Funny little tail",
        	SLEEPING = "Sleepytime",
        },

		BULLKELP_PLANT = 
         {
            GENERIC = "Water friends!",
            PICKED = "Yum!",
        },
		BULLKELP_ROOT = "Friends made a Snappy!",
		KELPHAT = "Slimy Head Thing looks good",
        KELP = "Belly stuff?",
		KELP_COOKED = "Mmmm... slimy!",
		KELP_DRIED = "Crunchy",

		GESTALT = "Saying something?",

        WALKINGPLANK = "Splashy jump spot",
        OAR = "Friend helps push water",

        -------------Wormwood Specific-------

        COMPOSTWRAP = "Poop good for heart",
        ARMOR_BRAMBLE = "Pokey protection",
        TRAP_BRAMBLE = "Friends made a trap!",

    },
    DESCRIBE_GENERIC = "Friend?",
    DESCRIBE_TOODARK = "Where is light?",
    DESCRIBE_SMOLDERING = "Uh oh...",
    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Don't feel good",
    },
}
