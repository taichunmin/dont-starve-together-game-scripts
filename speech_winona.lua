return {

	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "That'd clog the assembly line.",
        },
        BUILD =
        {
            MOUNTED = "Can't assemble anything from up here.",
            HASPET = "Nah. I'm a one-pet gal.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Dirty work's not for broad daylight.",
			GENERIC = "I'd NEVER misuse a tool.",
			NOBITS = "Smooth as sheet metal.",
		},
		STORE =
		{
			GENERIC = "It's full to bursting.",
			NOTALLOWED = "That's just impractical.",
			INUSE = "No rush.",
		},
		CONSTRUCT =
        {
            INUSE = "Aw someone else is building it already.",
            NOTALLOWED = "Square peg in a round hole.",
            EMPTY = "I gotta have something to build with.",
            MISMATCH = "Oops! Wrong plans.",
        },
		RUMMAGE =
		{	
			GENERIC = "I can't right now.",
			INUSE = "No rush.",
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
		},
        COOK =
        {
            GENERIC = "I'm not really in a cooking mood.",
            INUSE = "How's the grub coming?",
            TOOFAR = "I gotta get closer. Or grow longer arms.",
        },
        GIVE =
        {
            DEAD = "They appear to be dead. Very dead.",
            SLEEPING = "They're off the clock.",
            BUSY = "They're busy working.",
            ABIGAILHEART = "No one should ever lose a sister.",
            --...
            GHOSTHEART = "Some things even I can't fix.",
            NOTGEM = "What sort of worker do you take me for?",
            WRONGGEM = "Nn-nn. That doesn't go there.",
            NOTSTAFF = "It doesn't fit together like that.",
            MUSHROOMFARM_NEEDSSHROOM = "It doesn't need this.",
            MUSHROOMFARM_NEEDSLOG = "It needs something else.",
            SLOTFULL = "No sense wasting materials.",
            FOODFULL = "Ah, a wonderful bird, the peli-can.", --it's beak can hold more than its belly-can!
            NOTDISH = "I don't wanna go angering no demons.",
            DUPLICATE = "We already got these schematics.",
            NOTSCULPTABLE = "That ain't for sculpting.",
            CANTSHADOWREVIVE = "Don't think that'll work.",
            WRONGSHADOWFORM = "I gotta disassemble it and try again.",
            NOMOON = "Gonna have to make this under the influence of the moon.",
            PIGKINGGAME_MESSY = "Gotta clean up first.",
			PIGKINGGAME_DANGER = "Nah. It ain't safe for that now.",
			PIGKINGGAME_TOOLATE = "Nah. I'll wait until morning.",
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
        },
        ATTUNE =
        {
            NOHEALTH = "I don't have it in me right now.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "It's a bit preoccupied.",
            INUSE = "Only one to a beef, hey?",
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
        },
        WRAPBUNDLE =
        {
            EMPTY = "I can't wrap up thin air.",
        },
        PICKUP =
        {
			RESTRICTION = "That's not really my forte.",
			INUSE = "Shucks. Someone beat me to it.",
        },
        REPLATE =
        {
            MISMATCH = "I always get my dishes mixed up.", 
            SAMEDISH = "It's on a dish already.", 
        },
	},
	ACTIONFAIL_GENERIC = "I sure gummed the works there.",
	ANNOUNCE_DIG_DISEASE_WARNING = "That helped a bit.",
	ANNOUNCE_PICK_DISEASE_WARNING = "Whew! If that isn't the mightiest smell.",
	ANNOUNCE_ADVENTUREFAIL = "Yeow. Don't make me come back in there!",
    ANNOUNCE_MOUNT_LOWHEALTH = "You're not looking too good, big guy.",
	ANNOUNCE_BEES = "BEEEES!",
	ANNOUNCE_BOOMERANG = "I'll catch you next time! Ow...",
	ANNOUNCE_CHARLIE = "C-Charlie?",
    --...I'm so sorry, I never meant for you to come here.
	ANNOUNCE_CHARLIE_MISSED = "Ha! I know all your moves!",
    --This wasn't a part of my plan, but as you're here now...
	ANNOUNCE_CHARLIE_ATTACK = "Yeow! Rude!",
    --...I suppose I'll have to make do.
	ANNOUNCE_COLD = "Brr! Cold as frozen steel out here!",
	ANNOUNCE_HOT = "It's hotter than a tin smelter in July!",
	ANNOUNCE_CRAFTING_FAIL = "How did I junk that up?!",
	ANNOUNCE_DEERCLOPS = "Democrew incoming!",
	ANNOUNCE_CAVEIN = "Uh... I hope everyone brought hardhats.",
	ANNOUNCE_ANTLION_SINKHOLE = "Earthquake! I think?",
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Get a load of this!",
        "Hope it's to your likin'!",
        "Here ya go!",
	},
	ANNOUNCE_DUSK = "There's the quittin' bell.",
	ANNOUNCE_EAT =
	{
		GENERIC = "That hits the spot.",
		PAINFUL = "Yeow! That one bit back!",
		SPOILED = "I am full of regret.",
		STALE = "I've had worse.",
		INVALID = "Pretty sure that's not food.",
		YUCKY = "Blech! Even I got limits!",
	},
	ANNOUNCE_ENCUMBERED =
    {
        "Hhff!",
        "Easy as pie! Hff!",
        "Like eggs in coffee!",
        "Hhngh!",
        "I... *huff* I got it!",
        "Ha! I'm plenty rugged! *huff*",
        "Ooff...",
    },

    ANNOUNCE_SNARED = "Hey!",
	ANNOUNCE_ENTER_DARK = "I can't see!",
	ANNOUNCE_ENTER_LIGHT = "Whew! I can see!",
	ANNOUNCE_FREEDOM = "Ha! Outsmarted!",
	ANNOUNCE_HIGHRESEARCH = "Cutting edge!",
	ANNOUNCE_HOUNDS = "Are those dogs I hear?",
	ANNOUNCE_WORMS = "Was that a tremor?",
	ANNOUNCE_HUNGRY = "When's lunch?",
	ANNOUNCE_HUNT_BEAST_NEARBY = "I didn't order lunch to go. Get'em!",
	ANNOUNCE_HUNT_LOST_TRAIL = "Gah! I lost it.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Err, are those my footprints? Shoot!",
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
	ANNOUNCE_NODANGERSIESTA = "But I'm in danger!",
	ANNOUNCE_NONIGHTSIESTA = "I'd rather sleep than nap.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Sleeping down here ain't a bright idea.",
	ANNOUNCE_NOHUNGERSIESTA = "I'd rather whip up some grub.",
	ANNOUNCE_NODANGERAFK = "I gotta stay alert!",
	ANNOUNCE_NO_TRAP = "That was a cinch.",
	ANNOUNCE_PECKED = "Yeow! Lay off!",
	ANNOUNCE_QUAKE = "Earthquake!",
	ANNOUNCE_RESEARCH = "I can build even MORE things!",
	ANNOUNCE_SHELTER = "Ah, that's better.",
	ANNOUNCE_THORNS = "Yeow! That smarts!",
	ANNOUNCE_BURNT = "Ow! Ow! Ow!",
	ANNOUNCE_TORCH_OUT = "Out like a light.",
	ANNOUNCE_FAN_OUT = "Useless handmade junk!",
    ANNOUNCE_COMPASS_OUT = "Shoddy handmade junk!",
	ANNOUNCE_TRAP_WENT_OFF = "Heh, whoops.",
	ANNOUNCE_UNIMPLEMENTED = "Yeow! That still needs some tinkering!",
	ANNOUNCE_WORMHOLE = "That'll get the adrenaline pumping!",
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

	ANNOUNCE_DESPAWN = "Good thing I got all my affairs in order.",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!",
	ANNOUNCE_GHOSTDRAIN = "My head's all fuzzy...",
	ANNOUNCE_PETRIFED_TREES = "Do these trees seem shadier?",
	ANNOUNCE_KLAUS_ENRAGE = "HOLY RIVETS! Time to make tracks!",
	ANNOUNCE_KLAUS_UNCHAINED = "The mitts are coming off!",
	ANNOUNCE_KLAUS_CALLFORHELP = "He called his goons!",

    ANNOUNCE_HUNGRY_SLOWBUILD = 
    {
	    "My head's all clouded by hunger!",
	    "Oof. I got the brainfog.",
	    "Maybe I could take a snack break?",
	    "I could sure go for some grub."
    },
    ANNOUNCE_HUNGRY_FASTBUILD = 
    {
    	"This's hungry work.",
    	"I'm working up an appetite.",
    	"That made me a lil hungry.",
    	"I'll need some brainfood at this rate.",
    },

	--hallowed nights
    ANNOUNCE_SPOOKED = "I'm seein' things!",
    ANNOUNCE_BRAVERY_POTION = "I got my moxie back. Now to tackle those trees.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Up'n'attem now.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Back to work!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "I'm back on the clock!",
    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "The ingredients didn't assemble right.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "What a waste of food!",
    QUAGMIRE_ANNOUNCE_LOSE = "N-nice sky wyrm... Uh-oh.",
    QUAGMIRE_ANNOUNCE_WIN = "Better leave while we can!",

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
        CONSTRUCTION_PLANS = "Let's get building.",
        MOONROCKIDOL = "Do I gotta offer it up to something?",
        MOONROCKSEED = "I could learn a thing or two from this.",
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
			GENERIC = "What a nice little flower.",
			LONG = "What a nice little flower.",
			MEDIUM = "It's getting antsy.",
			SOON = "Something's coming.",
			HAUNTED_POCKET = "It wants down.",
			HAUNTED_GROUND = "What do you want? Water?",
		},

		BALLOONS_EMPTY = "No fun without Wes.",
		BALLOON = "Oh! A balloon.",

		BERNIE_INACTIVE =
		{
			BROKEN = "He's a bit of a fixer-upper.",
			GENERIC = "This little guy's been well loved.",
		},

		BERNIE_ACTIVE = "Is he clockwork? Can I peek inside?",
		
		BOOK_BIRDS = "I was never much of a book learner.",
		BOOK_TENTACLES = "I'm not really a \"book smarts\" kind of gal.",
		BOOK_GARDENING = "I prefer to learn from experience.",
		BOOK_SLEEP = "I already know how to sleep, thanks.",
		BOOK_BRIMSTONE = "I prefer hands-on learning.",

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
        MIGRATION_PORTAL = 
        {
            GENERIC = "Hellooo? Anyone in there?",
            OPEN = "Make way! I'm coming through!",
            FULL = "It's packed. I'll stay put.",
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
		LAVA_POND_ROCK2 = "That... is a rock.",
		LAVA_POND_ROCK3 = "That... is a rock.",
		LAVA_POND_ROCK4 = "That... is a rock.",
		LAVA_POND_ROCK5 = "That... is a rock.",
		LAVA_POND_ROCK6 = "That... is a rock.",
		LAVA_POND_ROCK7 = "That... is a rock.",

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
		POTTEDFERN = "That's my kind of decor. Simple.",
		SUCCULENT_POTTED = "It's in a pot now.",
		SUCCULENT_PLANT = "This plant don't give up easy.",
		SUCCULENT_PICKED = "It's been picked.",
		GIFT = "My presence is a gift. Ha.",
        GIFTWRAP = "I could wrap stuff up real nice.",
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
        },
		THULECITE = "I love working with new materials.",
		ARMORRUINS = "Not a bad piece of work.",
		ARMORSKELETON = "A bit creepy, isn't it?",
        SKELETONHAT = "Makes me a little uneasy. Heh heh...",
		RUINS_BAT = "This thulecite stuff is incredible!",
		RUINSHAT = "Transforms the wearer into the \"King of Snoot\".",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Nothing out of place here.",	--calm phase
			WARN = "I feel uneasy for some reason.",	--Before nightmare
			WAXING = "The air's all prickly.", --Nightmare Phase first 33%
			STEADY = "It can't possibly get worse.", --Nightmare 33% - 66%
			WANING = "My head's starting to clear a bit.", --Nightmare 66% +
			DAWN = "I'm feeling much better.", --After nightmare
			NOMAGIC = "Things seem pretty normal.", --Place with no nightmare cycle.
		},
		BISHOP_NIGHTMARE = "You look awful!",
		ROOK_NIGHTMARE = "Get a load of this spalder.",
		KNIGHT_NIGHTMARE = "You're in rough shape, hey?",
		MINOTAUR = "I've had about enough of terrible beasts!",
		SPIDER_DROPPER = "That's a nasty looking spider!",
		NIGHTMARELIGHT = "I regret poking my nose so far down here.",
		NIGHTSTICK = "Electricity at my fingertips.",
		GREENGEM = "Now that's a proper gem.",
		RELIC = "Hand craftsmanship is old hat. Mass production is the future.",
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
			GENERIC= "I'm pretty good with directions.",
			N = "South.",
			S = "North.",
			E = "West.",
			W = "East.",
			NE = "Southwest",
			SE = "Northwest",
			NW = "Southeast",
			SW = "Northeast",
		},

		HOUNDSTOOTH= "Sure hope no one comes back for it.",
		ARMORSNURTLESHELL= "Go ahead, give'it a punch.",
		BAT= "Flyin' rodent.",
        BATBAT = "Ha! Clever.",
		BATWING="Surprisingly meaty.",
		BATWING_COOKED= "Meat's meat.",
        BATCAVE = "I'm gonna leave that right alone.",
		BEDROLL_FURRY= "Better to hit the fur than the hay.",
		BUNNYMAN= "You really oughta get some sun.",
		FLOWER_CAVE= "Woah! It doesn't even need electricity!",
		FLOWER_CAVE_DOUBLE= "Woah! It doesn't even need electricity!",
		FLOWER_CAVE_TRIPLE= "Woah! It doesn't even need electricity!",
		GUANO= "What? We all do it.",
		LANTERN= "Who'd want a non-electric lamp?",
		LIGHTBULB= "Not at all like the lightbulbs I'm used to.",
		MANRABBIT_TAIL= "This piece fell off. Shoddy craftsmanship.",
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
        MUSHROOMBOMB = "Fire in the hole!",
        SLEEPBOMB = "An unethical weapon, plain and simple.",
		MUSHTREE_TALL =
		{
            GENERIC = "It's huge!",
            BLOOM = "Whew. That's an odor.",
        },
		MUSHTREE_MEDIUM = 
		{
            GENERIC = "That's a big mushroom!",
            BLOOM = "Stink.",
        },
		MUSHTREE_SMALL = 
		{
            GENERIC = "I guess they grow better down here?",
            BLOOM = "Not a fan of the smell.",
        },
        MUSHTREE_TALL_WEBBED = "There's spiders in the crawlspace.",
        SPORE_TALL = "I've breathed in worse stuff at work.",
        SPORE_MEDIUM = "I've breathed in worse stuff at work.",
        SPORE_SMALL = "I've breathed in worse stuff at work.",
        SPORE_TALL_INV = "Never hurts to have extra light.",
        SPORE_MEDIUM_INV = "Never hurts to have extra light.",
        SPORE_SMALL_INV = "Never hurts to have extra light.",
		RABBITHOUSE=
		{
			GENERIC = "How'd they build these with no thumbs?",
			BURNT = "Welp.",
		},
		SLURTLE="Just don't seem right.",
		SLURTLE_SHELLPIECES="Broke, but I might salvage something useful.",
		SLURTLEHAT= "Gotta protect my noggin! I keep my ideas in there.",
		SLURTLEHOLE= "There's something gross in there.",
		SLURTLESLIME= "I hock those up after a long day at the factory.",
		SNURTLE= "Get along, little snurtle.",
		SPIDER_HIDER= "You know I can see you, right?",
		SPIDER_SPITTER= "Pfft, I can spit further than that!",
		SPIDERHOLE= "A rock filled with spiders. Great.",
		SPIDERHOLE_ROCK = "A rock filled with spiders. Great.",
		STALAGMITE= "Yep, yep. It's a rock.",
		STALAGMITE_FULL= "Ah! It's a rock.",
		STALAGMITE_LOW= "It's a rock! Yep, yep.",
		STALAGMITE_MED= "Yep! A rock.",
		STALAGMITE_TALL= "Ah! A rock.",
		STALAGMITE_TALL_FULL= "A rock! Yep.",
		STALAGMITE_TALL_LOW= "It's a rock! Yep, yep.",
		STALAGMITE_TALL_MED= "Yep! A rock.",
		TREASURECHEST_TRAP = "Hmm... I'm not sure about that.",
		
        TURF_CARPETFLOOR = "That's a chunk of ground.",
        TURF_CHECKERFLOOR = "That's a chunk of ground.",
        TURF_DIRT = "That's a chunk of ground.",
        TURF_FOREST = "That's a chunk of ground.",
        TURF_GRASS = "That's a chunk of grassy ground.",
        TURF_MARSH = "That's a chunk of squishy ground.",
        TURF_ROAD = "That's a chunk of road.",
        TURF_ROCKY = "That's a chunk of rocky ground.",
        TURF_SAVANNA = "That's a chunk of ground.",
        TURF_WOODFLOOR = "That's a chunk of ground.",

		TURF_CAVE="That's a chunk of mineshaft.",
		TURF_FUNGUS="That's a chunk of weird ground.",
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

		MAXWELLPHONOGRAPH = "I prefer blues.",
		BOOMERANG = "It's great at comebacks. Ha!",
		PIGGUARD = "You don't look so tough.",
		ABIGAIL = "How are you, boo?",
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
		BASALT = "Great, it's a rock.",
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
		},
		BEEFALOHAT = "Seem secretive.",
		BEEFALOWOOL = "Smelly, but warm.",
		BEEHAT = "Respecting bees means respecting stingers.",
		BEESWAX = "It smells kinda alright.",
		BEEHIVE = "Hard at work.",
		BEEMINE = "Sounds like the hum of an engine.",
		BEEMINE_MAXWELL = "That guy's got no concern for others. Pfft.",
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
			DISEASED = "Maybe you oughta take a sick day...",
			DISEASING = "Yeuch! Is it supposed to smell like that?",
			BURNING = "Not much I can do now.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Totally pooped. Or unpooped?",
			WITHERED = "Pssh. This heat's nothing.",
			GENERIC = "Looks tasty. Hope they're not poison.",
			PICKED = "Picked it right clean.",
			DISEASED = "Maybe you oughta take a sick day...",
			DISEASING = "Yeuch! Is it supposed to smell like that?",
			BURNING = "Not much I can do now.",
		},
		BIGFOOT = "At least it doesn't have steel-toed workboots!",
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
		--BELL_BLUEPRINT = "Progress on paper!",
		BLUEPRINT = "Blueprint paper just smells right.",
		BELL_BLUEPRINT = "Ahh, interesting!",
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
            --You've changed so much.
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
		CARROT_SEEDS = "Some carrot seeds.",
		CARTOGRAPHYDESK = 
		{	
			GENERIC = "Good place to kick your feet up, if nothin' else.",
			BURNING = "Welp.",
			BURNT = "It's okay. I'll assemble another.",
		},
		WATERMELON_SEEDS = "Some watermelon seeds.",
		CAVE_FERN = "Take a gander at this tiny fern!",
		CHARCOAL = "It gets everywhere.",
		CHESSPIECE_PAWN = 
        {
			GENERIC = "Nice hat.",
		},
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
        CHESSPIECE_MUSE = 
        {
			GENERIC = "I've got a bad feeling about this one.",
			--STRUGGLE = "...H-hello?",
		},
        CHESSPIECE_FORMAL = 
        {
			GENERIC = "It's BUSTed. Ha!",
		},
        CHESSPIECE_HORNUCOPIA = 
        {
			GENERIC = "Ugh, don't remind me of food.",
		},
        CHESSPIECE_PIPE = 
        {
			GENERIC = "It's got bubbles coming out the top.",
		},
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
		CORN_SEEDS = "Some corn seeds.",
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

		CROW =
		{
			GENERIC = "Looks a bit flighty. Ha!",
			HELD = "Hauling you around is murder on the feet! Ha!",
		},
		CUTGRASS = "A fire waiting to happen.",
		CUTREEDS = "Doesn't hold a candle to steel pipe.",
		CUTSTONE = "Prepped and ready for the assembly line.",
		DEADLYFEAST = "Food poisoning and a half.",
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
		DEVTOOL = "What an incredible tool!",
		DEVTOOL_NODEV = "Lazy builders.",
		DIRTPILE = "Time to get my hands dirty.",
		DIVININGROD =
		{
			COLD = "S'not picking anything up.",
			GENERIC = "I'm probably one of the few left that knows how to use these.",
			HOT = "I'm sitting right on top of... something.",
			WARM = "It's getting something.",
			WARMER = "Gonna hit paydirt any second now.",
		},
		DIVININGRODBASE =
		{
			GENERIC = "Just like in the bossman's workshop.",
			READY = "I guess it wants the Voxola?",
			UNLOCKED = "At least I assembled it right.",
		},
		DIVININGRODSTART = "That's a Voxola! What's it doing here?",
		DRAGONFLY = "Get a load of this flying welding torch!",
		ARMORDRAGONFLY = "Bit flashy, hey?",
		DRAGON_SCALES = "Showy.",
		DRAGONFLYCHEST = "For the snootiest of snoots.",
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
		DRAGONFRUIT_SEEDS = "Some dragonfruit seeds.",
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
		DURIAN_SEEDS = "Some durian seeds.",
		EARMUFFSHAT = "I hate cold weather.",
		EGGPLANT = "Look how weird it is! Ha!",
		EGGPLANT_COOKED = "Did that make it better? I don't know.",
		EGGPLANT_SEEDS = "Some eggplant seeds.",
		
		ENDTABLE = 
		{
			BURNT = "That's a shame.",
			GENERIC = "Pretty sure this one won't move.",
			EMPTY = "Sturdily built.",
			WILTED = "That bouquet's seen better days.",
			FRESHLIGHT = "I miss lamps.",
			OLDLIGHT = "That's not gonna last much longer.",
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
			DISEASED = "Doesn't look great.",
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
		FEATHER_CANARY = "That's not a good sign.",
		FEATHER_CROW = "Not a whole lotta use for that.",
		FEATHER_ROBIN = "Kinda useless. Looks nice, anyway.",
		FEATHER_ROBIN_WINTER = "If only I had a cap to put it in.",
		FEATHERPENCIL = "I've got ugly handwriting.",
		FEM_PUPPET = "She doesn't look none too happy.",
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
            --How much time has passed for you?
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
			DISEASED = "You should see a doctor.",
			DISEASING = "Not lookin' too lush.",
		},
		GRASSGEKKO = 
		{
			GENERIC = "Is that lizard made of grass?",	
			DISEASED = "I didn't know lizards could wilt.",
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
		MALE_PUPPET = "He doesn't look none too happy.",

		MANDRAKE_ACTIVE = "This is exactly what having a little sister's like.",
        --I should like to speak, face to face.
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
		MAXWELL = "Well, you're a tall piece of work.",
		MAXWELLHEAD = "You don't scare me.",
		MAXWELLLIGHT = "How does that even work?",
		MAXWELLLOCK = "Neat contraption. Can I take a look at it?",
		MAXWELLTHRONE = "Who'd wanna to sit on THAT?",
		MEAT = "Someone's eatin' good tonight!",
		MEATBALLS = "Don't mind if I do.",
		MEATRACK =
		{
			DONE = "Ready for eatin'.",
			DRYING = "It's well on its way.",
			DRYINGINRAIN = "Not gonna make much progress like that.",
			GENERIC = "A rack for drying meat.",
			BURNT = "Well, it's dry.",
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
		POMEGRANATE_SEEDS = "Some pomegranate seeds.",
		POND = "I can't see the bottom.",
		POOP = "Nothing to be ashamed of.",
		FERTILIZER = "Plants can't get enough.",
		PUMPKIN = "Hey there, pumpkin.",
		PUMPKINCOOKIE = "Gotta indulge sometimes, hey?",
		PUMPKIN_COOKED = "Not bad! Kind of sweet.",
		PUMPKIN_LANTERN = "It's childish, but in a nice way.",
		PUMPKIN_SEEDS = "Some pumpkin seeds.",
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
        RELIC = 
        {
            GENERIC = "Hand craftsmanship is old hat. Mass production is the future.",
            BROKEN = "Broken and waiting for a handywoman to come along.",
        },
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
		ROBOT_PUPPET = "They don't look none too happy.",
		ROCK_LIGHT =
		{
			GENERIC = "Some sorta crusty rock.",
			OUT = "That ain't burning no one.",
			LOW = "It's losing heat.",
			NORMAL = "A real scorcher!",
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
			DISEASED = "That thing does not look good.",
			DISEASING = "You're smelling a little funky.",
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
		SKULLCHEST = "Is that supposed to scare me?",
		SMALLBIRD =
		{
			GENERIC = "Ha! You're so tiny!",
			HUNGRY = "You feelin' a bit peckish? Ha!",
			SLEEPING = "Sleep well, fluffnugget.",
			STARVING = "Yeesh, you ain't lookin' so good.",
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
            TYPE2 = "We thought she was gone...",
            TYPE1 = "This is too strange.",
        },
		STATUEHARP = "I don't know. Some fancy thing.",
		STATUEMAXWELL = "So THIS is \"Maxy\".",
		--...
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
			SLEEPING = "Sleep well, awkward fluffnugget.",
			STARVING = "Stop whining, I'll feed you when I can!",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "That did it.",
			GENERIC = "That gadget has my name on it.",
			LOCKED = "Still needs a bit of tinkering.",
			PARTIAL = "Coming along real nice.",
		},
		TELEPORTATO_BOX = "Pulling the lever makes me feel better.",
		TELEPORTATO_CRANK = "Let's get cranky. Ha!",
		TELEPORTATO_POTATO = "Yuck. Handmade.",
		TELEPORTATO_RING = "Nice little metal doodad.",
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
		TRAP_TEETH_MAXWELL = "That's a safety hazard.",
		TREASURECHEST = 
		{
			GENERIC = "Handmade, so you know it's not up to snuff.",
			BURNT = "Hope there was nothin' good inside.",
		},
		TREASURECHEST_TRAP = "I don't need to be concerned about that.",
		TREECLUMP = "A big clump of tree.",
		
		TRINKET_1 = "I was never much into marbles.",
		TRINKET_2 = "It's got no film to make a sound.",
		TRINKET_3 = "Everyone's been real good at showin' me the ropes. Ha!",
		TRINKET_4 = "We're not goin' gnome anytime soon. Ha! ...Oh.",
		TRINKET_5 = "Handcrafted. Yuck.",
		TRINKET_6 = "The copper's probably valuable.",
		TRINKET_7 = "Was this whittled... by hand? Blech!",
		TRINKET_8 = "No bathtub in sight.",
		TRINKET_9 = "Where's all this junk coming from?",
		TRINKET_10 = "All bite and no bark. Ha!",
		TRINKET_11 = "Maybe this bot'll let me poke around its insides.",
		TRINKET_12 = "Hey Willow! Dare ya ta eat it!",
		TRINKET_13 = "Looks like my old landlord. Ha!",
		TRINKET_14 = "Tea's not really my taste.",
		TRINKET_15 = "A bit highbrow, don'tcha think?",
		TRINKET_16 = "A bit highbrow, don'tcha think?",
		TRINKET_17 = "A waste of good metal.",
		TRINKET_18 = "Handcrafted. Blech.",
		TRINKET_19 = "This is why we need production standards.",
		TRINKET_20 = "I can reach my own back! Watch!",
		TRINKET_21 = "Nice and mechanical.",
		TRINKET_22 = "I got no use for that.",
		TRINKET_23 = "I prefer to break workboots in myself.",
		TRINKET_24 = "The reliable quality of a mass manufactured product!",
		TRINKET_25 = "Ha! Nasty!",
		TRINKET_26 = "That thing's an affront to manufacturing.",
		TRINKET_27 = "Not a lotta use for that out here.",
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
        TRINKET_43 = "Blech. Handmade.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Nope. Can't fix that.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "I'm not messing with anymore radios.", -- Odd Radio ONI trinket
        TRINKET_46 = "That might be fun to take apart.", -- Hairdryer ONI trinket

		HALLOWEENCANDY_1 = "A nice change from baked apples.", --Candy Apple
        HALLOWEENCANDY_2 = "Is this even food?", --Candy Corn
        HALLOWEENCANDY_3 = "That's no treat.", --Not-So-Candy Corn
        HALLOWEENCANDY_4 = "That gummy has too many legs for my taste.", --Gummy Spider
        HALLOWEENCANDY_5 = "Not made of catcoons, thankfully.", --Catcoon Candy
        HALLOWEENCANDY_6 = "Not sure anyone should eat those.", --\"Raisins\"
        HALLOWEENCANDY_7 = "That's just regular food.", --Raisins
        HALLOWEENCANDY_8 = "How spooky.", --Ghost Pop
        HALLOWEENCANDY_9 = "Real gelatinous.", --Jelly Worm
        HALLOWEENCANDY_10 = "Curious flavor.", --Tentacle Lolli
        HALLOWEENCANDY_11 = "Best eaten by the handful.", --Choco Pigs
        HALLOWEENCANDY_12 = "Ha, yuck! Everyone watch me eat'em!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "I ain't patient enough to eat these.",	--Griftlands themed candy
        HALLOWEENCANDY_14 = "Whew! That's the kick y'need!",	--Hot Lava pepper candy
        CANDYBAG = "It's a goodybag.",

        HALLOWEEN_ORNAMENT_1 = "Ha! Ya almost fooled me.",
		HALLOWEEN_ORNAMENT_2 = "I should hang this somewhere.",
		HALLOWEEN_ORNAMENT_3 = "Time to decorate.",
		HALLOWEEN_ORNAMENT_4 = "Time for decoratin'!", 
		HALLOWEEN_ORNAMENT_5 = "Hey, it's them hanging guys.", 
		HALLOWEEN_ORNAMENT_6 = "It needs to be in a tree.",

		HALLOWEENPOTION_DRINKS_WEAK = "Aw, I was hoping for a little more.",
		HALLOWEENPOTION_DRINKS_POTENT = "I got lucky and got the big bottle.",
		HALLOWEENPOTION_FIRE_FX = "Ohh. This'll make a spark.", 
		HALLOWEENPOTION_BRAVERY = "Makes ya plucky.",
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
		YOTP_FOOD1 = "Now that's a feast!",
		YOTP_FOOD2 = "I'll give it to a pig or somethin'.",
		YOTP_FOOD3 = "Somethin' to chew on.",

		PIGELITE1 = "Swell tattoos you got there.", --BLUE
		PIGELITE2 = "Chill out, red.", --RED
		PIGELITE3 = "He's giving me a dirty look.", --WHITE
		PIGELITE4 = "Stand still so I can hit you with a sign.", --GREEN
		
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
		WALRUS_TUSK = "Get a load of this chomper!",
		WARDROBE = 
		{
			GENERIC = "I could build a million of these.",
            BURNING = "And up it goes.",
			BURNT = "So who wants to build another one?",
		},
		WARG = "Quite the set of chompers on that one.",
		WASPHIVE = "Wouldn't mess with that without good reason.",
		WATERBALLOON = "I throw a killer curveball.",
		WATERMELON = "We used to slice these up on hot summer days.",
		WATERMELON_COOKED = "This was an odd choice.",
		WATERMELONHAT = "A melon for your melon.",
		WAXWELLJOURNAL = "I don't trust that thing one bit.",
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

        KLAUS = "Get out of here ya big creep.",
        KLAUS_SACK = "There's gotta be something good in there.",
		KLAUSSACKKEY = "This must be the actual key.",
		WORMHOLE =
		{
			GENERIC = "I'm not one to shy away from a dirty job.",
			OPEN = "Here we go!",
		},
		WORMHOLE_LIMITED = "That thing can't take much more.",
		ACCOMPLISHMENT_SHRINE = "A testament to my achievements. Or lack of them.",        
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
		--
        QUAGMIRE_HOE = "I never done farmwork.",
        --
        QUAGMIRE_TURNIP = "A fresh, ripe turnip.",
        QUAGMIRE_TURNIP_COOKED = "I'd rather not eat them on their own.",
        QUAGMIRE_TURNIP_SEEDS = "I got no idea what they'd grow into.",
        --
        QUAGMIRE_GARLIC = "Makes everything taste better.",
        QUAGMIRE_GARLIC_COOKED = "Bet that brought out the flavor.",
        QUAGMIRE_GARLIC_SEEDS = "I got no idea what they'd grow into.",
        --
        QUAGMIRE_ONION = "I hate chopping vegetables.",
        QUAGMIRE_ONION_COOKED = "Done and done.",
        QUAGMIRE_ONION_SEEDS = "I got no idea what they'd grow into.",
        --
        QUAGMIRE_POTATO = "I just think they're neat.",
        QUAGMIRE_POTATO_COOKED = "I've always been a meat and potatoes gal.",
        QUAGMIRE_POTATO_SEEDS = "I got no idea what they'd grow into.",
        --
        QUAGMIRE_TOMATO = "Gotta appreciate havin' fresh vegetables.",
        QUAGMIRE_TOMATO_COOKED = "I prefer'em fried and green.",
        QUAGMIRE_TOMATO_SEEDS = "I got no idea what they'd grow into.",
        --
        QUAGMIRE_FLOUR = "I ain't much of a baker.",
        QUAGMIRE_WHEAT = "I go against the grain whenever possible. Ha!",
        QUAGMIRE_WHEAT_SEEDS = "I got no idea what they'd grow into.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "I got no idea what they'd grow into.",
        --
        QUAGMIRE_ROTTEN_CROP = "I am not a good farmer.",
        --
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
		QUAGMIRE_FERN = "Fresh roughage.",
        QUAGMIRE_FOLIAGE_COOKED = "Cooked roughage.",
		
		QUAGMIRE_SALT_RACK =
		{
			READY = "Salt's ready for minin'.",
			GENERIC = "It needs a bit more time.",
		},

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

		QUAGMIRE_POND_SALT = "It's a bit salty, hey?",
		--
		QUAGMIRE_RUBBLE_CARRIAGE = "Never thought I'd say this, but it's beyond repair.",
        QUAGMIRE_RUBBLE_CLOCK = "Something muddled this clockwork real good.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Well I sure ain't goin' in it now.",
        QUAGMIRE_RUBBLE_PUBDOOR = "Even I can't fix it.",
        QUAGMIRE_RUBBLE_ROOF = "I've repaired roofs before but this is a lost cause.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "Looks like something destroyed it.",
        QUAGMIRE_RUBBLE_BIKE = "It's busted.",
        QUAGMIRE_RUBBLE_HOUSE = {"Something happened here.", "Ain't no one here anymore.", "Something busted this town.",},
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
        --
        QUAGMIRE_PORTAL = "I might not be good at rescue missions.",
        QUAGMIRE_SALTROCK = "It's a big ol' eatin' rock.",
        QUAGMIRE_SALT = "But where's the pepper?",
        --food--
        QUAGMIRE_FOOD_BURNT = "It's a little toastier than normal.",
        --QUAGMIRE_FOOD_PLATE = "It's a ceramic dish.",
        --QUAGMIRE_FOOD_BOWL = "Makes eatin' soup a lot easier.",
        --QUAGMIRE_FOOD_SOUP = "Warm soup. Nothin' better.",
        --QUAGMIRE_FOOD_SNACK = "A lip smackin' snack.",
        --QUAGMIRE_FOOD_BREAD = "Bread is the best foundation for every meal.",
        --QUAGMIRE_FOOD_PASTA = "Fancy pasta dish.",
        --QUAGMIRE_FOOD_VEGGIE = "Full o' veggies to make me big and strong.",
        --QUAGMIRE_FOOD_MEAT = "A hearty meat meal.",
        --QUAGMIRE_FOOD_FISH = "Still got that fish smell.",
        --QUAGMIRE_FOOD_CRAB = "Ohh... a fancy dish.",
        --QUAGMIRE_FOOD_CHEESE = "You gotta love cheese.",
        --QUAGMIRE_FOOD_SWEET = "Good for someone with a sweet tooth. Like me!",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Let's throw it up on that altar, hey?",
            MISMATCH = "Well this ain't right.",
            MATCH = "Perfect.",
            MATCH_BUT_SNACK = "It's the right food, but it don't look too filling.",
        },
        --
        QUAGMIRE_COIN1 = "A lucky coin.",
        QUAGMIRE_COIN2 = "Save this for a rainy day.",
        QUAGMIRE_COIN3 = "Gotta watch I don't turn into a rich dope.",
        QUAGMIRE_COIN4 = "We could bust outta here with enough of these.",
        QUAGMIRE_GOATMILK = "I try to support local artisans.",
        QUAGMIRE_SYRUP = "It's like honey from a tree.",
        QUAGMIRE_SAP_SPOILED = "It's no good now.",
        QUAGMIRE_SEEDPACKET = "Better than a market.",
        --QUAGMIRE_SEEDPACKET_SMALL = "I could start a small garden with this.",
        --QUAGMIRE_SEEDPACKET_MEDIUM = "A good start.",
        --QUAGMIRE_SEEDPACKET_LARGE = "Better than a market.",
        --QUAGMIRE_SEEDPACKET_MIX_SMALL = "There's a whole mix of seeds in here.",
        --QUAGMIRE_SEEDPACKET_MIX_MEDIUM = "Bunch o' different seeds.",
        --QUAGMIRE_SEEDPACKET_MIX_LARGE = "A lotta variety in here.",
        ---
        QUAGMIRE_OVEN_ITEM = "Welp. Another day, another project.",
        QUAGMIRE_OVEN = "It's a regular ol' oven.",
        QUAGMIRE_POT = "Could make a real big stew in that pot.",
        QUAGMIRE_POT_SMALL = "I only ever made stew before this.",
        QUAGMIRE_POT_SYRUP = "Syrup makes me sappy. Ha!",
        QUAGMIRE_POT_HANGER = "Needs a pot in there or somethin'.",
        QUAGMIRE_POT_HANGER_ITEM = "Ready for assembly.",
        QUAGMIRE_GRILL = "Time for a cookout!",
        QUAGMIRE_GRILL_ITEM = "I need to to find a firepit for this to work.",
        QUAGMIRE_GRILL_SMALL = "Big enough for a small cookout. ",
        QUAGMIRE_GRILL_SMALL_ITEM = "Now where can I put this...",
        QUAGMIRE_CASSEROLEDISH = "I'll need to bake it.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "For making little stews and stuff.",
        QUAGMIRE_PLATE_SILVER = "Little too fancy for my tastes.",
        QUAGMIRE_BOWL_SILVER = "Fancy lookin' but it still just holds food.",

        --
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
        --
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
        },
        WINONA_SPOTLIGHT = 
        {
        	GENERIC = "Sorry, Charlie.",
        	OFF = "Gotta hook it up to the generator.",
        	BURNING = "Quick! Put it out!",
        	BURNT = "Criminy! My machine!",
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
        },
    },
    DESCRIBE_GENERIC = "Incredible! I have no idea what that is.",
    DESCRIBE_TOODARK = "Low visibility causes workplace accidents!",
    DESCRIBE_SMOLDERING = "That's gonna start a fire!",
    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "That crunch was upsetting.",
    },
}
