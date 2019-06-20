return {

	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "That is incorrect!",
        },
        BUILD =
        {
            MOUNTED = "Either I must get down, or the world must come up.",
            HASPET = "I've made my pact with a beast already.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I may only do that while it sleeps.",
			GENERIC = "I can't, I won't, I shan't.",
			NOBITS = "Instead of hair, there's nothing there!",
		},
		STORE =
		{
			GENERIC = "It's full, full, full.",
			NOTALLOWED = "Oh I simply couldn't.",
			INUSE = "Another soul has use of it right now.",
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
		},
        COOK =
        {
            GENERIC = "I'd rather snack on a soul no one's using.",
            INUSE = "Mortals need physical food more than I do.",
            TOOFAR = "I could hop over, I suppose.",
        },
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
            SLOTFULL = "It is full already.",
            FOODFULL = "There's already a dish, and it looks delish!",
            NOTDISH = "It would be in our best interest to not.",
            DUPLICATE = "We cannot learn what we already know!",
            NOTSCULPTABLE = "I do not think so, no no no!",
            CANTSHADOWREVIVE = "Its soul is prevented from returning here.",
            WRONGSHADOWFORM = "It looks downright silly, hyuyu!",
            NOMOON = "The light of the moon, I hope it comes soon!",
            PIGKINGGAME_MESSY = "This beautiful chaos inhibits me.",
			PIGKINGGAME_DANGER = "Our souls are in mortal danger right now!",
			PIGKINGGAME_TOOLATE = "The night is upon us!",
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
        },
        ATTUNE =
        {
            NOHEALTH = "My body would surely die.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Its focus is elsewhere.",
            INUSE = "It has made a pact with another.",
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
        },
        WRAPBUNDLE =
        {
            EMPTY = "I need something to bind within.",
        },
        PICKUP =
        {
			RESTRICTION = "I am cautious about touching it.",
			INUSE = "Another soul has use of it.",
        },
        REPLATE =
        {
            MISMATCH = "Hyuyu! They all look the same to me!", 
            SAMEDISH = "I cannot redo what's already been done!", 
        },
	},
	ACTIONFAIL_GENERIC = "No, no, no.",
	ANNOUNCE_DIG_DISEASE_WARNING = "I've helped it!",
	ANNOUNCE_PICK_DISEASE_WARNING = "Its soul has not left its body, yet still it stinks.",
	ANNOUNCE_ADVENTUREFAIL = "I've had enough plane hopping.",
    ANNOUNCE_MOUNT_LOWHEALTH = "Its soul hangs by a thread.",
	ANNOUNCE_BEES = "Fiddle dee dee, HERE COMES A BEE!",
	ANNOUNCE_BOOMERANG = "Hyuyu!",
	ANNOUNCE_CHARLIE = "What manner of imp was that??",
	ANNOUNCE_CHARLIE_ATTACK = "OWIE-HEE-HEE!",
	ANNOUNCE_COLD = "It's finally frozen over!",
	ANNOUNCE_HOT = "Hot, hot, hot!",
	ANNOUNCE_CRAFTING_FAIL = "My hands are truly cursed.",
	ANNOUNCE_DEERCLOPS = "Clipping and clopping, here comes a stomping!",
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
	ANNOUNCE_DUSK = "The night soon approaches. Hyuyu!",
	ANNOUNCE_EAT =
	{
		GENERIC = "Mmm! Soul free!",
		PAINFUL = "Ouch! Hyuyu!",
		SPOILED = "Blech! At least souls never spoil.",
		STALE = "How unpleasant!",
		INVALID = "Not even I could eat that.",
		YUCKY = "I'd rather eat my own tail!",
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
    },

    ANNOUNCE_SNARED = "I've been bound!",
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
	ANNOUNCE_NODANGERSIESTA = "Why sleep when there's fun afoot?",
	ANNOUNCE_NONIGHTSIESTA = "No honorable imp would siesta at night.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "An imp must stay on guard when underground.",
	ANNOUNCE_NOHUNGERSIESTA = "I'm too soul-famished to siesta.",
	ANNOUNCE_NODANGERAFK = "I am in grave danger right now!",
	ANNOUNCE_NO_TRAP = "Can't catch me!",
	ANNOUNCE_PECKED = "But why!",
	ANNOUNCE_QUAKE = "Shiver and shake, that's a quake!",
	ANNOUNCE_RESEARCH = "My mind has expanded!",
	ANNOUNCE_SHELTER = "Ah, much better!",
	ANNOUNCE_THORNS = "It pricked me!",
	ANNOUNCE_BURNT = "Too hot for my impish paws!",
	ANNOUNCE_TORCH_OUT = "Farewell, sweet flame!",
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

	ANNOUNCE_DESPAWN = "Hyuyu, fare thee well!",
	ANNOUNCE_BECOMEGHOST = "ooOooooO!",
	ANNOUNCE_GHOSTDRAIN = "Ghosts play... strange games...",
	ANNOUNCE_PETRIFED_TREES = "The trees are playing a funny prank!",
	ANNOUNCE_KLAUS_ENRAGE = "Time to hop out of here!",
	ANNOUNCE_KLAUS_UNCHAINED = "Shall we dance?",
	ANNOUNCE_KLAUS_CALLFORHELP = "Well that's no fun, friend!",

    --Wortox
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
    --[[ANNOUNCE_SOUL_RELEASE =
    {
        "Be free!",
        "I simply couldn't bear the guilt.",
        "Sorry, little soul.",
        "I didn't want to do it!",
        "I can't bring myself to eat it.",
        "Goodbye, sweet soul.",
        "I'm too squeamish to eat it anyway.",
        "My existence is a curse.",
    },]]

    --hallowed nights
    ANNOUNCE_SPOOKED = "What a s-silly prank!",
    ANNOUNCE_BRAVERY_POTION = "Okay, let's play!",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "C'mon back, silly goose.",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Up and at'em!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "The imp returns!",
    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "That was nothing! Nothing!",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Well it's not raw! Hyuyu!",
    QUAGMIRE_ANNOUNCE_LOSE = "Oh dear.",
    QUAGMIRE_ANNOUNCE_WIN = "Must be off now!",

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
		PIG = "Nevermind, I've forgotten my dancing shoes.",
		PREY = "You no longer entertain me.",
		SPIDER = "I am the wimp imp!",
		SPIDER_WARRIOR = "I'll take my leave. Hyuyu!",
	},
	DESCRIBE =
	{
        MULTIPLAYER_PORTAL = "I can come and go as I please.",
        MULTIPLAYER_PORTAL_MOONROCK = "Ooo, what delightful games we might play in there!",
        CONSTRUCTION_PLANS = "But it's more fun to wing it!",
        MOONROCKIDOL = "What, pray tell, do you desire?",
        MOONROCKSEED = "I bet you know some fun secrets.",
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
            GENERIC = "I think it eats souls, too.",
            LONG = "It's very sad. Full of regrets.",
            MEDIUM = "Waking up, are we?",
            SOON = "It seems the fun will soon begin.",
            HAUNTED_POCKET = "Sadly, it is not mine to keep.",
            HAUNTED_GROUND = "Ohh, you're hungry too.",
        },

        BALLOONS_EMPTY = "Stores one's breath for later spells.",
        BALLOON = "I often feel like I might float away. Hyuyu!",

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
            GHOST = "You wouldn't even noticed if I took a bite.",
            BEAVER = "Hyuyu, you're so funny, %s!",
            BEAVERGHOST = "What a funny soul! I wonder what it tastes like.",
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
            REVIVER = "I guess %s doesn't have a taste for souls.",
            GHOST = "Finally, a break from his poop jokes.",
            FIRESTARTER = "Ooo, there's an ember of fun in you yet.",
        },
        NEXTCHARACTER =
        {
            GENERIC = "Hyuyu, what are you up to %s?",
            ATTACKER = "Don't get my goat, little %s!",
            MURDERER = "Eep! Don't slaughter me!",
            REVIVER = "Thank-you, thank-you, little goat!",
            GHOST = "Don't worry, I'm not hungry.",
            FIRESTARTER = "Little goat! You played pranks without me!",
        },

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
		LAVA_POND_ROCK2 = "Cold lava.",
		LAVA_POND_ROCK3 = "Cold lava.",
		LAVA_POND_ROCK4 = "Cold lava.",
		LAVA_POND_ROCK5 = "Cold lava.",
		LAVA_POND_ROCK6 = "Cold lava.",
		LAVA_POND_ROCK7 = "Cold lava.",

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
		POTTEDFERN = "A plant, imprisoned for eternity.",
		SUCCULENT_POTTED = "A plant, imprisoned for eternity.",
		SUCCULENT_PLANT = "A strong willed plant, desert born.",
		SUCCULENT_PICKED = "Leaves of a plant we picked.",
		GIFT = "Presents! How fun!",
        GIFTWRAP = "That's a wrap!",
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
        },
		THULECITE = "I'll use the nearest shrine to produce a design.",
		ARMORRUINS = "This thulecite sure is a delight!",
		ARMORSKELETON = "This fashion's all the rage... it's an external rib cage!",
        SKELETONHAT = "Ooohoo, it tickles my little imp-y brain!",
		RUINS_BAT = "A spiked hunk of ill intent!",
		RUINSHAT = "Jewelry to emphasize my fantastic horns!",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "No games to play today.",	--calm phase
			WARN = "I'm getting so excited!",	--Before nightmare
			WAXING = "Ooo, it's picking up!", --Nightmare Phase first 33%
			STEADY = "Hyuyu! What fun!", --Nightmare 33% - 66%
			WANING = "Aw, the chaos is dissipating.", --Nightmare 66% +
			DAWN = "Playtime's almost over.", --After nightmare
			NOMAGIC = "A fun medallion for a more fun rapscallion!", --Place with no nightmare cycle.
		},
		BISHOP_NIGHTMARE = "Eep! Play nice with the imp!",
		ROOK_NIGHTMARE = "Eep! Play nice with the imp!",
		KNIGHT_NIGHTMARE = "Eep! Play nice with the imp!",
		MINOTAUR = "Goodness gracious, aren't you fearsome.",
		SPIDER_DROPPER = "You look like you want to play!",
		NIGHTMARELIGHT = "Beware, beware, it says to me.",
		NIGHTSTICK = "Shed some light on any fight.",
		GREENGEM = "Gentlest green from lush vales gleaned.",
		RELIC = "Stuff from the mortals who fell through the portals!",
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
			GENERIC= "For when up is down and down is out.",
			N = "North!",
			S = "South!",
			E = "East!",
			W = "West!",
			NE = "Northeast!",
			SE = "Southeast!",
			NW = "Northwest!",
			SW = "Southwest!",
		},

		HOUNDSTOOTH= "You cannot compete with my fangs, no, no.",
		ARMORSNURTLESHELL= "Little bits of snurtle, yes.",
		BAT= "I'm quite batty myself! Hyuyu!",
        BATBAT = "Extra batty!",
		BATWING= "Look at that! The wing of a bat.",
		BATWING_COOKED= "Perhaps I'll find a hungry mortal to give it to.",
        BATCAVE = "Where the bats lie in wait.",
		BEDROLL_FURRY= "Fur upon fur!",
		BUNNYMAN= "You hop just like me!",
		FLOWER_CAVE= "How kind of you to light my way.",
		FLOWER_CAVE_DOUBLE= "How kind of you to light my way.",
		FLOWER_CAVE_TRIPLE= "How kind of you to light my way.",
		GUANO= "It came from a bat, and that is that.",
		LANTERN= "Guide my way!",
		LIGHTBULB= "Magnificent, I do dare say.",
		MANRABBIT_TAIL= "A tail from those great big bunnies.",
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
        MUSHROOMBOMB = "I will stay far away!",
        SLEEPBOMB = "I'll throw it, then you'll catch some ZZZs!",
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
        SPORE_TALL = "Dazzling!",
        SPORE_MEDIUM = "Dazzling!",
        SPORE_SMALL = "Dazzling!",
        SPORE_TALL_INV = "My beautiful spores.",
        SPORE_MEDIUM_INV = "My beautiful spores.",
        SPORE_SMALL_INV = "My beautiful spores.",
		RABBITHOUSE=
		{
			GENERIC = "Hyuyu! How whimsical.",
			BURNT = "Burnt down to the ground.",
		},
		SLURTLE= "Slinky, slurp and slime.",
		SLURTLE_SHELLPIECES= "Shards of shell I do see here.",
		SLURTLEHAT= "Oh how safe I do feel!",
		SLURTLEHOLE= "The hole where all the slurtles go!",
		SLURTLESLIME= "A useful slime, I think, I say.",
		SNURTLE= "Slink and slither, little snurtle.",
		SPIDER_HIDER= "Spindly spider, begone, begone!",
		SPIDER_SPITTER= "Do you spit your goop at me sir?",
		SPIDERHOLE= "All webbed up!",
		SPIDERHOLE_ROCK = "All webbed up!",
		STALAGMITE= "It's just a rock.",
		STALAGMITE_FULL= "It's just a rock.",
		STALAGMITE_LOW= "It's just a rock.",
		STALAGMITE_MED= "It's just a rock.",
		STALAGMITE_TALL= "It's just a rock.",
		STALAGMITE_TALL_FULL= "It's just a rock.",
		STALAGMITE_TALL_LOW= "It's just a rock.",
		STALAGMITE_TALL_MED= "It's just a rock.",
		TREASURECHEST_TRAP = "Ooo, what have we here?",
		
        TURF_CARPETFLOOR = "Floor or ceiling, depending on your perspective.",
        TURF_CHECKERFLOOR = "Floor or ceiling, depending on your perspective.",
        TURF_DIRT = "Floor or ceiling, depending on your perspective.",
        TURF_FOREST = "Floor or ceiling, depending on your perspective.",
        TURF_GRASS = "Floor or ceiling, depending on your perspective.",
        TURF_MARSH = "Floor or ceiling, depending on your perspective.",
        TURF_ROAD = "Floor or ceiling, depending on your perspective.",
        TURF_ROCKY = "Floor or ceiling, depending on your perspective.",
        TURF_SAVANNA = "Floor or ceiling, depending on your perspective.",
        TURF_WOODFLOOR = "Floor or ceiling, depending on your perspective.",

		TURF_CAVE= "Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS= "Floor or ceiling, depending on your perspective.",
		TURF_SINKHOLE= "Floor or ceiling, depending on your perspective.",
		TURF_UNDERROCK= "Floor or ceiling, depending on your perspective.",
		TURF_MUD= "Floor or ceiling, depending on your perspective.",

		TURF_DECIDUOUS = "Floor or ceiling, depending on your perspective.",
		TURF_SANDY = "Floor or ceiling, depending on your perspective.",
		TURF_BADLANDS = "Floor or ceiling, depending on your perspective.",
		TURF_DESERTDIRT = "Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS_GREEN = "Floor or ceiling, depending on your perspective.",
		TURF_FUNGUS_RED = "Floor or ceiling, depending on your perspective.",
		TURF_DRAGONFLY = "Floor or ceiling, depending on your perspective.",

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

		MAXWELLPHONOGRAPH = "Ooo, music! I'm practically giddy!",
		BOOMERANG = "What goes around comes around, they say, they say!",
		PIGGUARD = "We don't have to fight, you know.",
		ABIGAIL = "Poor soul.",
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
		BASALT = "Big, big rock, for sure, for sure.",
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
		},
		BEEFALOHAT = "Horn replacements.",
		BEEFALOWOOL = "Ex-beefalo.",
		BEEHAT = "What if my horns get stung?",
		BEESWAX = "None of mine!",
		BEEHIVE = "One swift kick and it becomes a great prank.",
		BEEMINE = "This will be a funny prank.",
		BEEMINE_MAXWELL = "That's not a funny prank at all!",
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
			DISEASED = "Now it stinks really good!",
			DISEASING = "It's started to stink.",
			BURNING = "Whoops-a-doodle.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Salted earth, none will return.",
			WITHERED = "Feeling down, are you?",
			GENERIC = "The humans like them, yes indeed.",
			PICKED = "Gone, all gone.",
			DISEASED = "Now it stinks really good!",
			DISEASING = "It's started to stink.",
			BURNING = "Whoops-a-doodle.",
		},
		BIGFOOT = "Do not step on little old me!",
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
		--BELL_BLUEPRINT = "Progress on paper!",
		BLUEPRINT = "What might it make? Oh let us see!",
		BELL_BLUEPRINT = "What might it make? Oh let us see!",
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
		CHESSPIECE_CLAYHOUND = "A clay hound made from that sketch we found!",
        CHESSPIECE_CLAYWARG = "So scary, rendered still in stone.",
        CHESSPIECE_DEERCLOPS = "That was such a fun day!",
        CHESSPIECE_BEARGER = "I'll say a prayer for this slain bear.",
        CHESSPIECE_MOOSEGOOSE = 
        {
        	"We've established a stone goose truce.",
        	"We've established a stone moose truce.",
        },
        CHESSPIECE_DRAGONFLY = "Bye bye, dear dragonfly.",
		CHESSPIECE_PAWN ="Would you like to play?",
        CHESSPIECE_ROOK = 
        {
			GENERIC = "We carved this from the rock ourselves.",
			STRUGGLE = "Yes, yes, come play!",
		},
        CHESSPIECE_KNIGHT = 
        {
			GENERIC ="Let's play a game, you and I!",
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

		CROW =
		{
			GENERIC = "Clever trickster.",
			HELD = "Careful, don't touch my hands.",
		},
		CUTGRASS = "Oh, what I could weave!",
		CUTREEDS = "One swift yank was all it took.",
		CUTSTONE = "Brick by brick, they say, they say.",
		DEADLYFEAST = "I desire this even less than regular food.",
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
			COLD = "The trail's gone cold, I feel cajoled.",
			GENERIC = "It will guide me where I wish to go.",
			HOT = "Red hot! We're near the spot!",
			WARM = "Hey, hey, hey! We're on our way!",
			WARMER = "I have to boast, we're getting close!",
		},
		DIVININGRODBASE =
		{
			GENERIC = "How very, very curious!",
			READY = "Let's hop, skip and jump out of here!",
			UNLOCKED = "Ooo, my fur's standing on end in anticipation!",
		},
		DIVININGRODSTART = "And now begins a thrilling game!",
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
		EGGPLANT_COOKED ="My favourite treat... it can't be beat!",
		EGGPLANT_SEEDS = "Let's give them some soil, before they spoil.",
		
		ENDTABLE = 
		{
			BURNT = "That was hardly necessary.",
			GENERIC = "I never learned my table manners.",
			EMPTY = "Now now, let's set the table.",
			WILTED = "Tiny flower on the table... you aren't looking very stable.",
			FRESHLIGHT = "A light so bright I might still see at night!",
			OLDLIGHT = "I'll try not to pout when that light soon goes out.",
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
			DISEASED = "Oh jeez, oh ick, that tree looks sick!",
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
		FEATHER_CANARY = "A token, to remember its sweet song by.",
		FEATHER_CROW = "A memento of my jet feathered friend.",
		FEATHER_ROBIN = "To remind myself of its sweet beaky face.",
		FEATHER_ROBIN_WINTER = "A keepsake of a gentle blue friend.",
		FEATHERPENCIL = "Use this quill, I will, I will.",
		FEM_PUPPET = "Greetings and salutations, ma'am.",
		FIREFLIES =
		{
			GENERIC ="Some natural light to grant me sight.",
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
        STALKER_FOREST = "Hyuyu, sorry to wake you!",
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
			DISEASED = "Now it stinks really good!",
			DISEASING = "It's started to stink.",
		},
		GRASSGEKKO = 
		{
			GENERIC = "Hello dear friend! No need to drop your tail.",
			DISEASED = "I can see the disease creeping into your soul.",
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
			GENERIC ="It really doesn't matter which way I go!",
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
		HOUNDBONE = "Short work made by gnashing teeth.",
		HOUNDMOUND = "It's the dog house!",
		ICEBOX = "Freeze mortal foods for midday feasts.",
		ICEHAT ="Horns on ice!",
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
		MALE_PUPPET = "Greetings and salutations, sir.",

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
		MAXWELL = "You have no power over me, heehee!",
		MAXWELLHEAD = "Hyuyu, that's a good trick!",
		MAXWELLLIGHT = "Ooohoohoo, it warms in my presence!",
		MAXWELLLOCK = "Now let's see, where is the key?",
		MAXWELLTHRONE = "A precarious place to rest one's rump.",
		MEAT = "Ex-animal.",
		MEATBALLS = "Physical food is so hilarious.",
		MEATRACK =
		{
			DONE = "The jerky is ready.",
			DRYING = "It's drying.",
			DRYINGINRAIN = "It's undrying day.",
			GENERIC = "I don't have much use for this.",
			BURNT = "A silly prank to be sure.",
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
			GENERIC ="A fellow hopper.",
			HELD = "Do not touch my paws or claws.",
		},
		RABBITHOLE = 
		{
			GENERIC = "Hopping wonders live within.",
			SPRING = "You'll not be hopping through that hole!",
		},
		RAINOMETER = 
		{	
			GENERIC ="Will it rain? Or will it shine?",
			BURNT = "A silly prank to be sure.",
		},
		RAINCOAT = "The puddles wait out there for me!",
		RAINHAT = "Splish and splash!",
		RATATOUILLE = "Physical food doesn't sit well with me.",
		RAZOR ="I do not shave.",
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
        RELIC = 
        {
            GENERIC = "It's just a bunch of unfun stuff!",
            BROKEN = "It broke, it broke, it did, it did.",
        },
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
		ROBOT_PUPPET = "Greetings and salutations, sweet compeer.",
		ROCK_LIGHT =
		{
			GENERIC = "A wisecracker like myself could crack it!",
			OUT = "A wisecracker like myself could crack it!",
			LOW = "The pool's begun to cool!",
			NORMAL = "How warm!",
		},
		CAVEIN_BOULDER =
        {
            GENERIC = "I could move it if I pleased!",
            RAISED = "A hop, skip and a jump too far!",
        },
		ROCK = "What a shock! It's a rock!",
		PETRIFIED_TREE = "Fweeheehee! A stone cold tree!",
		ROCK_PETRIFIED_TREE = "Fweeheehee! A stone cold tree!",
		ROCK_PETRIFIED_TREE_OLD ="Fweeheehee! A stone cold tree!",
		ROCK_ICE = 
		{
			GENERIC = "Who knew water could do that!",
			MELTED ="Ooo, a puddle.",
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
			DISEASED = "Now it stinks really good!",
			DISEASING = "It's started to stink.",
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
		SKULLCHEST = "Let me take a peek inside!",
		SMALLBIRD =
		{
			GENERIC = "The apple of my eye.",
			HUNGRY = "Would you like a nice soul to nibble on?",
			SLEEPING = "Night night, sleep tight.",
			STARVING = "Goodness gracious, you're really hungry.",
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
            TYPE2 = "Hyuyu, she's gone and lost her head!",
            TYPE1 = "Hyuyu, she's gone and lost her head!",
        },
		STATUEHARP = "Little cherub, little harp.",
		STATUEMAXWELL ="My old imp friends would like this, I think.",
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
			SHORT ="Oh dear, oh dear, it's almost here!",
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
			SLEEPING = "They grow so fast, wouldn't you say?",
			STARVING = "Awkward even in starvation.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Let's hop!",
			GENERIC = "Automatic hopper.",
			LOCKED = "Why won't you work for this nice imp?",
			PARTIAL = "It's almost done I'd say, I'd say!",
		},
		TELEPORTATO_BOX = "It's a thing. For the thing!",
		TELEPORTATO_CRANK = "It's a thing. For the thing!",
		TELEPORTATO_POTATO = "It's a thing. For the thing!",
		TELEPORTATO_RING = "It's a thing. For the thing!",
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
		TRAP_TEETH_MAXWELL = "What a rude thing to leave lying around.",
		TREASURECHEST = 
		{
			GENERIC = "A storage place for bits and bobs.",
			BURNT = "Oh no, our treasure!",
		},
		TREASURECHEST_TRAP = "What have we here?",
		TREECLUMP = "Hey! Don't bar the way!",
		
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
        TRINKET_29 = "A little piece from off the board.",--Rook
        TRINKET_30 = "A little piece from off the board.", --Knight
        TRINKET_31 = "A little piece from off the board.", --Knight
        TRINKET_32 = "If I look inside what will I see?", --Cubic Zirconia Ball
        TRINKET_33 = "No fun! It won't fit over my claw.", --Spider Ring
        TRINKET_34 = "I like my claws much better.", --Monkey Paw
        TRINKET_35 = "The drink's been drunk, so now it's junk!", --Empty Elixir
		TRINKET_36 = "Mine are much more impressive.", --Faux fangs
		TRINKET_37 = "Heehee, you couldn't kill me!", --Broken Stake
		TRINKET_38 = "The size of the world is a matter of perspective.",-- Binoculars Griftlands trinket
        TRINKET_39 = "I don't usually wear gloves.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Snips and snails and puppydog scales.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Without a doubt, the goop's spilled out.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Thank goodness this snake is just a fake.", -- Toy Cobra Hot Lava trinket
        TRINKET_43 = "Oh joy, oh boy! A wheely toy!", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "There's cracks in it for pests to get into.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Though you may think me quite a loon, I swear I hear a little tune.", -- Odd Radio ONI trinket
        TRINKET_46 = "We don't have these on my plane.", -- Hairdryer ONI trinket

		HALLOWEENCANDY_1 = "Something to sink my fangs into!", --Candy Apple
        HALLOWEENCANDY_2 = "I suppose I could eat a delightful treat.",--Candy Corn
        HALLOWEENCANDY_3 = "It's just human corn.", --Not-So-Candy Corn
        HALLOWEENCANDY_4 = "I could be persuaded to try a taste.", --Gummy Spider
        HALLOWEENCANDY_5 = "Fweehee! Little kitties!", --Catcoon Candy
        HALLOWEENCANDY_6 = "This prank is ingenious!", --\"Raisins\"
        HALLOWEENCANDY_7 = "Hm... I don't think I'll like that.", --Raisins
        HALLOWEENCANDY_8 = "Hyuyu, a candied soul!", --Ghost Pop
        HALLOWEENCANDY_9 = "Hyuyu, it slithers all the way down!", --Jelly Worm
        HALLOWEENCANDY_10 = "First time for everything, they say, they say.", --Tentacle Lolli
        HALLOWEENCANDY_11 = "Harumpf, it melts all over my claws.", --Choco Pigs
        HALLOWEENCANDY_12 = "How delightfully disgusting!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "I'll try a nibble, I will, I will.",	--Griftlands themed candy
        HALLOWEENCANDY_14 = "Ooo hoo hoo, spicy!",	--Hot Lava pepper candy
        CANDYBAG = "It's a Wortox Sack!",

        HALLOWEEN_ORNAMENT_1 = "It makes me hungry, yes indeed!", --ghost decoration
		HALLOWEEN_ORNAMENT_2 = "Absolutely batty!", --bat decoration
		HALLOWEEN_ORNAMENT_3 = "A creepy crawler for the tree.", --spider decoration
		HALLOWEEN_ORNAMENT_4 = "A swirly whirly tentacle!", --tentacle decoration
		HALLOWEEN_ORNAMENT_5 = "Made to dangle from the tree.", --dangling depth dweller decoration
		HALLOWEEN_ORNAMENT_6 = "I do believe it is quite dead!", --crow decoration

		HALLOWEENPOTION_DRINKS_WEAK = "How tame and timid!",
		HALLOWEENPOTION_DRINKS_POTENT = "Hyuyu! This'll put tufts on your chest!",
		HALLOWEENPOTION_FIRE_FX = "Firewater!",
		HALLOWEENPOTION_BRAVERY = "Tonic of anti-battiness!",
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

        PIGSHRINE =
		{
            GENERIC = "Let us celebrate!",
            EMPTY = "Rumble and grumble, it wants to eat meat!",
            BURNT = "That's that.",
		},
		PIG_TOKEN = "Let's start the game, oh please, oh please!",
		YOTP_FOOD1 = "I'll take a little tiny nibble.",
		YOTP_FOOD2 = "I'll try it, if you insist.",
		YOTP_FOOD3 = "Maybe just a little bite.",

		PIGELITE1 = "You won't beat me, no siree!", --BLUE
		PIGELITE2 = "You won't beat me, no siree!", --RED
		PIGELITE3 = "You won't beat me, no siree!", --WHITE
		PIGELITE4 = "You won't beat me, no siree!", --GREEN
		
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

        KLAUS = "Are we not brethren?",
        KLAUS_SACK = "What tasty treats lie within?",
		KLAUSSACKKEY = "Now where oh where did he leave that stash.",
		WORMHOLE =
		{
			GENERIC = "That looks like it could be my ride!",
			OPEN = "Watch my impression of mortal food.",
		},
		WORMHOLE_LIMITED = "I think its throat is getting sore.",
		ACCOMPLISHMENT_SHRINE = "I did indeed do that!",       
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
		ROCK_MOON = "The sky has fallen.",
		MOONROCKNUGGET = "It was hewn from solid moon.",
		MOONROCKCRATER = "It might be an eye, were gems in supply.",

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
		--
        QUAGMIRE_HOE = "To turn the soil, row by row.",
        --
        QUAGMIRE_TURNIP = "That's a tiny turnip.",
        QUAGMIRE_TURNIP_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_TURNIP_SEEDS = "Strange little seeds, indeed, indeed.",
        --
        QUAGMIRE_GARLIC = "Hissss!",
        QUAGMIRE_GARLIC_COOKED = "Hissssss!",
        QUAGMIRE_GARLIC_SEEDS = "Strange little seeds, indeed, indeed.",
        --
        QUAGMIRE_ONION = "You'll see no tears from my eye. I cannot cry!",
        QUAGMIRE_ONION_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_ONION_SEEDS = "Strange little seeds, indeed, indeed.",
        --
        QUAGMIRE_POTATO = "Mortals like this in all its forms. Will a wyrm?",
        QUAGMIRE_POTATO_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_POTATO_SEEDS = "Strange little seeds, indeed, indeed.",
        --
        QUAGMIRE_TOMATO = "I could throw it at the wyrm!",
        QUAGMIRE_TOMATO_COOKED = "Cooked, but not into a dish.",
        QUAGMIRE_TOMATO_SEEDS = "Strange little seeds, indeed, indeed.",
        --
        QUAGMIRE_FLOUR = "Mortal food powder!",
        QUAGMIRE_WHEAT = "The mortals grind it up with big rocks.",
        QUAGMIRE_WHEAT_SEEDS = "Strange little seeds, indeed, indeed.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Strange little seeds, indeed, indeed.",
        --
        QUAGMIRE_ROTTEN_CROP = "Yuck, muck.",
        --
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
		QUAGMIRE_FERN = "I wonder what it tastes like.",
        QUAGMIRE_FOLIAGE_COOKED = "Humans have odd palates.",
		
		QUAGMIRE_SALT_RACK =
		{
			READY = "The minerals are ready.",
			GENERIC = "The mortals crave these minerals.",
		},

		QUAGMIRE_SALT_RACK_ITEM = "It's meant to go above a pond.",

		QUAGMIRE_SAFE = 
		{
			GENERIC = "None can impede this imp!",
			LOCKED = "Oh whiskers. It's locked tight.",
		},
		
		QUAGMIRE_KEY = "I wish to pry into hidden supplies.",
		QUAGMIRE_KEY_PARK = "No gate can stop a sneaky imp!",
        QUAGMIRE_PORTAL_KEY = "Hyuyu! Let us hop away!",

		-- QUAGMIRE_MUSHROOMSTUMP =
		-- {
		-- 	GENERIC = "Should I take some mushrooms to the mortals?",
		-- 	PICKED = "Gone, all gone.",
		-- },
		-- QUAGMIRE_MUSHROOMS = ".",
        QUAGMIRE_MEALINGSTONE = "I do enjoy this mortal chore.",

		QUAGMIRE_PEBBLECRAB = "What a funny creature!",

		QUAGMIRE_POND_SALT = "It's very salty water.",
		--
		QUAGMIRE_RUBBLE_CARRIAGE = "Which squeaky wheel will get the grease?",
        QUAGMIRE_RUBBLE_CLOCK = "Hickory dickory dock, hyuyu!",
        QUAGMIRE_RUBBLE_CATHEDRAL = "It all comes tumbling down.",
        QUAGMIRE_RUBBLE_PUBDOOR = "A door to nowhere, hyuyu!",
        QUAGMIRE_RUBBLE_ROOF = "It all comes tumbling down.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "The hands have stopped. Time is difficult to grasp.",
        QUAGMIRE_RUBBLE_BIKE = "Cycles spinning round and round. Bicycles double the spinning!",
        QUAGMIRE_RUBBLE_HOUSE = {"Rubble, ruin!", "No souls to see.", "Huff and puff, and blow your house down!",},
        QUAGMIRE_RUBBLE_CHIMNEY = "It all comes tumbling down.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Tumbley, rumbley, falling right down.",
        QUAGMIRE_SWAMPIG_HOUSE = "A house that's cobbled from bits and bobs.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Nothing but bits and bobs left.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "My oh my, you look ill! Low of spirit, green 'round the gill.",
            SLEEPING = "Sleeping like the fishes. Hyuyu!",
        },
        QUAGMIRE_SWAMPIG = "Do you feel it loom? Your impending doom?",
        --
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
        --
        QUAGMIRE_COIN1 = "Pithy pennies.",
        QUAGMIRE_COIN2 = "The Gnaw expelled it from its craw.",
        QUAGMIRE_COIN3 = "The Gnaw has spoken. We've earned its token.",
        QUAGMIRE_COIN4 = "It's a big hop token.",
        QUAGMIRE_GOATMILK = "Hyuyu! Fresh from the source.",
        QUAGMIRE_SYRUP = "For making sweet treats.",
        QUAGMIRE_SAP_SPOILED = "Whoops-a-doodle!",
        QUAGMIRE_SEEDPACKET = "Plant them in a plot of land.",
        ---
        QUAGMIRE_OVEN_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_OVEN = "It's a thing mortals cook with.",
        QUAGMIRE_POT = "Mortals don't like it when you burn the things inside.",
        QUAGMIRE_POT_SMALL = "A little vessel for mortal food.",
        QUAGMIRE_POT_SYRUP = "Mortals don't like raw tree insides.",
        QUAGMIRE_POT_HANGER = "You can hang a pot on it.",
        QUAGMIRE_POT_HANGER_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_GRILL = "Mortals have lots of different cooking things.",
        QUAGMIRE_GRILL_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_GRILL_SMALL = "Mortals cook stuff on it.",
        QUAGMIRE_GRILL_SMALL_ITEM = "We need to build that, yes indeed.",
        QUAGMIRE_CASSEROLEDISH = "I wonder how the wyrm got a taste for mortal food.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "This dish is so itty bitty!",
        QUAGMIRE_PLATE_SILVER = "Are there any souls on the menu?",
        QUAGMIRE_BOWL_SILVER = "The mortals like it when food looks nice.",

        --
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
        --
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

        --Wortox
        WORTOX_SOUL = "Hyuyu! It looks tasty.", --only wortox can inspect souls

        --Wormwood
        COMPOSTWRAP = "It's poop. So the plants won't droop.",
        ARMOR_BRAMBLE = "Who'd like to give an imp a hug? Hyuyu!",
        TRAP_BRAMBLE = "Spiky, pointy, green and thorny!",
    },
    DESCRIBE_GENERIC = "Ooo, a mystery!",
    DESCRIBE_TOODARK = "I can't see the physical plane!",
    DESCRIBE_SMOLDERING = "Some fiery fun is about to begin!",
    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Doing that hurt my feelings.",
    },
}
