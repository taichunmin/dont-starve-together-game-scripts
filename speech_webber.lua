return {
	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "This two piece puzzle sure is hard!",
        },
        BUILD =
        {
            MOUNTED = "All our arms can't quite reach from up here.",
            HASPET = "I like the pet we've got.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "It's hairy like us, but I don't think it likes shaving.",
			GENERIC = "It's not shaving time!",
			NOBITS = "Clean as a whistle.",
		},
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "That doesn't go there!",
        	KLAUS = "It's too dangerous!",
        	QUAGMIRE_WRONGKEY = "Aw... It's the wrong one.",
        },
        ACTIVATE = 
		{
			LOCKED_GATE = "Aww. We want in there.",
		},
		STORE =
		{
			GENERIC = "All full!",
			NOTALLOWED = "That's against the rules.",
			INUSE = "Are you finding everything okay in there?",
		},
		CONSTRUCT =
        {
            INUSE = "Aw, we don't wanna mess up someone else's stuff.",
            NOTALLOWED = "It doesn't go there.",
            EMPTY = "We need stuff to build with.",
            MISMATCH = "I don't think these are the right plans.",
        },
		WRITE =
        {
            GENERIC = "We can't write on that now.",
            INUSE = "We'll get our crayons ready while they finish up!",
        },
		RUMMAGE =
        {   
            GENERIC = "That's off-limits.",
            INUSE = "It's okay, we can wait for you to finish!",   
        },
		COOK =
        {
            GENERIC = "I don't want to. Mom always said the kitchen was dangerous!",
            INUSE = "Ooo, make something tasty!",
            TOOFAR = "Let's scurry closer!",
        },
        MOUNT =
        {
            INUSE = "We didn't climb into the saddle in time!",
            TARGETINCOMBAT = "It's too angry!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "It's too angry!",
        },
        GIVE =
        {
            GENERIC = "Nope, don't think so!",
            DEAD = "Um. We should probably keep it.",
            SLEEPING = "Aww... It's sleepy-snoozy right now!",
            BUSY = "We can try again when it's finished.",
            ABIGAILHEART = "Wendy would've been so happy if it worked.",
            GHOSTHEART = "We don't think we even want them to come back.",
            NOTGEM = "It doesn't fit right!",
            WRONGGEM = "We'd rather keep this one for ourselves.",
            NOTSTAFF = "I think that'd make it angry.",
            MUSHROOMFARM_NEEDSSHROOM = "It needs a mushroom!",
            MUSHROOMFARM_NEEDSLOG = "It needs a special kind of log!",
            SLOTFULL = "Mom said to always finish my plate before seconds.",
            FOODFULL = "It's still working on the first one.",
            NOTDISH = "I don't think we should offer that.",
            DUPLICATE = "We don't need two!",
            NOTSCULPTABLE = "Eight legs isn't nearly enough to sculpt with THAT.",
            CANTSHADOWREVIVE = "It's not waking up.",
            WRONGSHADOWFORM = "We put the bones together wrong.",
            NOMOON = "Doesn't work. We probably need to see the moon or something.",
            PIGKINGGAME_MESSY = "We need to clean up before we can play.",
			PIGKINGGAME_DANGER = "Lets wait until the danger passes before we play.",
			PIGKINGGAME_TOOLATE = "It's too close to bedtime to start another game.",
        },
        GIVETOPLAYER = 
        {
        	FULL = "Hey! Make room!",
            DEAD = "Um. We should probably keep it.",
            SLEEPING = "Aww... They're getting their snoozies right now!",
            BUSY = "We have something for you!",
    	},
    	GIVEALLTOPLAYER = 
        {
        	FULL = "Hey! Make room!",
            DEAD = "Um. We should probably keep it.",
            SLEEPING = "Aww... They're getting their snoozies right now!",
            BUSY = "We have something for you!",
    	},
    	ATTUNE =
        {
            NOHEALTH = "We don't feel so good right now. Maybe later?",
        },
        DRAW =
        {
            NOIMAGE = "But what should we draw?!",
        },
        CHANGEIN =
        {
            GENERIC = "Not right now, we're comfy.",
            BURNING = "Woah! Hot fashions!",
            INUSE = "We'll give them some privacy while they change.",
        },
        TEACH =
        {
            KNOWN = "I'm pretty sure one of us knows that one.",
            CANTLEARN = "Ms. Wickerbottom will have to explain this one.",
            WRONGWORLD = "Is it upside down? Nope. It's just wrong.",
        },
        WRAPBUNDLE =
        {
            EMPTY = "But what should we wrap up?",
        },
        PICKUP =
        {
			RESTRICTION = "We don't want to use that.",
			INUSE = "Oops. Someone else is using that.",
        },
        REPLATE =
        {
            MISMATCH = "Hmmm... I think we need a different dish for this.", 
            SAMEDISH = "We already put this on a dish.", 
        },
	},
	ACTIONFAIL_GENERIC = "Mom told me never to do that.",

--boarlord event
	ANNOUNCE_REVIVING_CORPSE = "Hold on, we'll help!",
	ANNOUNCE_REVIVED_OTHER_CORPSE = "There you go!",
	ANNOUNCE_REVIVED_FROM_CORPSE = "All better!",

	ANNOUNCE_DIG_DISEASE_WARNING = "Doesn't that feel better!",
	ANNOUNCE_PICK_DISEASE_WARNING = "Yuck!",
	ANNOUNCE_MOUNT_LOWHEALTH = "Our hairy friend is hurt!",
	ANNOUNCE_ADVENTUREFAIL = "Play time is over.",
	ANNOUNCE_BEES = "Flying ouchies!",
	ANNOUNCE_BOOMERANG = "It hurts us when we don't catch it.",
	ANNOUNCE_CHARLIE = "Is somebody there?!",
	ANNOUNCE_CHARLIE_ATTACK = "Aah! Monsters in the dark!",
	ANNOUNCE_COLD = "Brrr... spider hair isn't very warm.",
	ANNOUNCE_HOT = "Hot as heck!",
	ANNOUNCE_ANTLION_SINKHOLE = 
	{
		"The ground's giving way!",
		"It's rumble-y!",
		"What's that?",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "For you!",
        "Maybe it'll be happier now.",
        "I hope you like our tribute!",
	},
	ANNOUNCE_SACREDCHEST_YES = "It likes us!",
	ANNOUNCE_SACREDCHEST_NO = "But those were presents!",
	ANNOUNCE_CRAFTING_FAIL = "We're missing something.",
	ANNOUNCE_DEERCLOPS = "That sounded like a big meanie.",
	ANNOUNCE_CAVEIN = "I think the sky is falling!",
	ANNOUNCE_DUSK = "Almost time for bed.",
	ANNOUNCE_NODANGERAFK = "Can't! There's scary-biteys about!",
	ANNOUNCE_NODANGERGIFT = "We'll open it later as a celebration of surviving this!",
	ANNOUNCE_NOMOUNTEDGIFT = "I promise I'll ride you again after I open my present!",
	ANNOUNCE_NOWARDROBEONFIRE = "I can't! It's all burny!",
	ANNOUNCE_WORMS = "Ohhh nooo. We're not friends with worms!",
	ANNOUNCE_EAT =
	{
		GENERIC = "Yummy in our tummy!",
		PAINFUL = "Our tummy hurts.",
		SPOILED = "Past its date.",
		STALE = "Stale like mum's leftovers.",
		INVALID = "That doesn't look like food to us.",
		YUCKY = "We can't, we won't, we refuse to eat that.",
	},
    ANNOUNCE_ENCUMBERED =
    {
        "Ughh!",
        "So heavy...!",
        "Left foot... Right foot...",
        "We... can do it!",
        "Are... we there yet...",
        "Chugga chugga chugga chugga...",
        "Not enough... legs... to lift...",
        "Hhhhfn!",
        "Oof...!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING = 
    {
        "That gateway did something weird.",
        "Something's happening.",
        "Let's get out of here.",
    },
    ANNOUNCE_RUINS_RESET = "Everything's back!",

	ANNOUNCE_DESPAWN = "Everything's getting fuzzy!",
	ANNOUNCE_BECOMEGHOST = "oOooOooO!!",
	ANNOUNCE_GHOSTDRAIN = "We're becoming... even more monstrous!",
	ANNOUNCE_PETRIFED_TREES = "The trees are yelling at us!!",
	ANNOUNCE_KLAUS_ENRAGE = "Ah! I'm sorry we killed your deer!!",
	ANNOUNCE_KLAUS_UNCHAINED = "Its belly looks hungry!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Uh-oh, its got friends coming!",

	ANNOUNCE_SNARED = "Hey! Meanie!",
	ANNOUNCE_REPELLED = "We can't hit it.",
	ANNOUNCE_ENTER_DARK = "We can't see! I want my nightlight.",
	ANNOUNCE_ENTER_LIGHT = "Phew, light!",
	ANNOUNCE_FREEDOM = "We made it!",
	ANNOUNCE_HIGHRESEARCH = "I'm learning so much!",
	ANNOUNCE_HOUNDS = "Doggies are coming!",
	ANNOUNCE_HUNGRY = "It's time for a snack!",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Fresh tracks!",
	ANNOUNCE_HUNT_LOST_TRAIL = "Animal went bye-bye.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "It's too muddy to track.",
	ANNOUNCE_INV_FULL = "Our pockets are full!",
	ANNOUNCE_KNOCKEDOUT = "Ow, our head!",
	ANNOUNCE_LOWRESEARCH = "That might've taught a toddler something.",
	ANNOUNCE_MOSQUITOS = "Suck someone else's blood!",
	ANNOUNCE_NODANGERSLEEP = "Can't sleep with monsters nearby!",
	ANNOUNCE_NODAYSLEEP = "It's daytime, not bedtime.",
	ANNOUNCE_NODAYSLEEP_CAVE = "We're not ready for bed.",
	ANNOUNCE_NOHUNGERSLEEP = "Our tummy is rumbling, we can't sleep.",
	ANNOUNCE_NOSLEEPONFIRE = "Mum always said \"Don't sleep in a burning building.\"",
	ANNOUNCE_NODANGERSIESTA = "Can't nap with monsters nearby!",
	ANNOUNCE_NONIGHTSIESTA = "We can't take a nap, it's nighttime!",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "No naps til daybreak!",
	ANNOUNCE_NOHUNGERSIESTA = "Won't be able to nap with a rumbling tummy.",
	ANNOUNCE_NO_TRAP = "Easy peasy.",
	ANNOUNCE_PECKED = "Bad bird!",
	ANNOUNCE_QUAKE = "I don't think that was our tummy.",
	ANNOUNCE_RESEARCH = "It's almost like being back in school.",
	ANNOUNCE_SHELTER = "Protect us, tree!",
	ANNOUNCE_THORNS = "Yowch!",
	ANNOUNCE_BURNT = "Jeepers, that was hot!",
	ANNOUNCE_TORCH_OUT = "Waah, our light went out!",
    ANNOUNCE_FAN_OUT = "Aaw, the twirly is gone.",
    ANNOUNCE_THURIBLE_OUT = "Aw, there goes our lure.",
    ANNOUNCE_COMPASS_OUT = "Uh oh, I broke it.",
	ANNOUNCE_TRAP_WENT_OFF = "Eek!",
	ANNOUNCE_UNIMPLEMENTED = "Gah! It needs more time.",
	ANNOUNCE_WORMHOLE = "That was a scary hole!",
	ANNOUNCE_TOWNPORTALTELEPORT = "We're here!",
	ANNOUNCE_CANFIX = "\nWe can repair it.",
	ANNOUNCE_ACCOMPLISHMENT = "We're so capable!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "We're a super hero!",	
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Not good enough for you, plant?",
	ANNOUNCE_TOOL_SLIP = "Hey! We were using that!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "We're invincible!",
	ANNOUNCE_TOADESCAPING = "It's looking around for a way out.",
	ANNOUNCE_TOADESCAPED = "Aww, the frog left!",

	ANNOUNCE_DAMP = "Splishy splashy.",
	ANNOUNCE_WET = "We're unpleasantly moist.",
	ANNOUNCE_WETTER = "Wet as a bathtub we can't crawl out of.",
	ANNOUNCE_SOAKED = "We're drenched!",

	--hallowed nights
    ANNOUNCE_SPOOKED = "Are we seeing things?!",
    ANNOUNCE_BRAVERY_POTION = "Hey, those trees aren't so scary anymore!",

    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Oh no! That wasn't a recipe!",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Oh no! We burnt it!",
    QUAGMIRE_ANNOUNCE_LOSE = "Don't eat us!",
    QUAGMIRE_ANNOUNCE_WIN = "I'm ready to go home now!",

    --YOTP--
    ANNOUNCE_LEAVE_MINIGAME = "We'll leave this sign for someone else.",

    BATTLECRY =
    {
        GENERIC = "En garde!",
        PIG = "We hate it! Horrible pig!",
        PREY = "We will put you in our web!",
        SPIDER = "Hey, wanna play?",
        SPIDER_WARRIOR = "Why can't we just get along?!",
        DEER = "Hopefully we're venomous!",
    },
    COMBAT_QUIT =
    {
        GENERIC = "Well, we would have won!",
        PIG = "Another day, pig.",
        PREY = "Speedy thing!",
        SPIDER = "We didn't actually want to hurt you.",
        SPIDER_WARRIOR = "Simmer down, friend.",
    },

    DESCRIBE =
    {
        PLAYER =
        {
            GENERIC = "Hey! Hi %s!",
            ATTACKER = "%s looks mean.",
            MURDERER = "Meanie! Get'em!",
            REVIVER = "%s is super nice to ghosts.",
            GHOST = "Don't worry, %s, we'll find you a heart!",
            FIRESTARTER = "%s, you lit a fire!",
        },
        WILSON =
        {
            GENERIC = "Hi %s! Nice weather we're having!",
            ATTACKER = "Why are you being so mean, %s?",
            MURDERER = "Meanie! We will stop you no matter what!",
            REVIVER = "%s doesn't believe in ghosts, but he believes in us!",
            GHOST = "You're looking much paler than usual, %s!",
            FIRESTARTER = "Uh... Is your hair smoking, %s?",
        },
        WOLFGANG =
        {
            GENERIC = "Hi %s! Have you been working out?",
            ATTACKER = "Hey %s, you look upset about something.",
            MURDERER = "You're just a big bully!",
            REVIVER = "%s's nice! I wish he'd stop messing up our head fur, though.",
            GHOST = "I'm sure you're the strongest ghost. Let's get a heart though.",
            FIRESTARTER = "%s, no!! Fire can hurt you!",
        },
        WAXWELL =
        {
            GENERIC = "Hi %s! Lookin' dapper!",
            ATTACKER = "%s looks eviler than usual...",
            MURDERER = "You're the real monster, %s!",
            REVIVER = "Wow, %s is really nice! He's helping people!",
            GHOST = "Aw %s, no one deserves to be stuck like that!",
            FIRESTARTER = "Don't burn our things please. We like them.",
        },
        WX78 =
        {
            GENERIC = "Hi %s! You look very non-organic today!",
            ATTACKER = "We thought you were a friendly robot, %s!",
            MURDERER = "Let us introduce you to our world wide web! Sh-sha!",
            REVIVER = "Aww. We'd beep-boop %s on the nose if they had one!",
            GHOST = "Bad day destroying humans, %s? Tomorrow will be better!",
            FIRESTARTER = "Maybe they didn't know fire is dangerous to us.",
        },
        WILLOW =
        {
            GENERIC = "Hi %s! How's Bernie?",
            ATTACKER = "%s's playing with fire. Err...",
            MURDERER = "You're gonna get burned, %s!",
            REVIVER = "She's like a burnt marshmallow. Crispy outside, super mushy inside!",
            GHOST = "Uh-oh! Does that hurt, %s?",
            FIRESTARTER = "Another fire? Well, as long as you're happy...",
        },
        WENDY =
        {
            GENERIC = "Hi %s! Let's play, okay?",
            ATTACKER = "Are you angry at me, %s?",
            MURDERER = "We're taking my friendship bracelet back!",
            REVIVER = "%s always plays nice with ghosts.",
            GHOST = "Don't worry! Our spider friends will help bring you back!",
            FIRESTARTER = "Uhh, uh-oh, let's play a different game, %s.",
        },
        WOODIE =
        {
            GENERIC = "Hi %s, hi Lucy!",
            ATTACKER = "%s looks angry today.",
            MURDERER = "You need to treat people nicer, %s!",
            REVIVER = "%s is gruff, but nice.",
            GHOST = "Wanna go heart-hunting with us, %s?",
            BEAVER = "%s's being gnawghty.",
            BEAVERGHOST = "Can I pet your ears or will our claws swish through?",
            FIRESTARTER = "Um. I think you lit a fire, %s.",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Hello Ms. %s!",
            ATTACKER = "Uh-oh! We're in trouble with Ms. %s!",
            MURDERER = "Killer! Does this mean we don't have to do our homework?!",
            REVIVER = "Ms. %s is very smart and wise. She's neat!",
            GHOST = "Don't worry Ms. %s, we'll find you a heart!",
            FIRESTARTER = "Ms. %s! We already had our combustion lessons!",
        },
        WES =
        {
            GENERIC = "Hey! Hi %s!",
            ATTACKER = "Maybe we can talk this out?",
            MURDERER = "You're supposed to play nice!",
            REVIVER = "%s is super nice. And his makeup's cool!",
            GHOST = "We'll help you get back on your feet, %s!",
            FIRESTARTER = "You were just supposed to mime lighting it!",
        },
        WEBBER =
        {
            GENERIC = "A spiderfriend! Hi %s!",
            ATTACKER = "Ah! We look scary when we're mad!",
            MURDERER = "We won't let you hurt our friends!",
            REVIVER = "%s likes helping ghosts, just like us.",
            GHOST = "Oh no! We should help ourselves!",
            FIRESTARTER = "Spiderfriend, why did you light that fire?",
        },
        WATHGRITHR =
        {
            GENERIC = "Wow, %s! You're lookin' tough!",
            ATTACKER = "%s looks really mean. And tough.",
            MURDERER = "We're not scared of pointy spearsticks! Fight!",
            REVIVER = "%s is a super valiant lady.",
            GHOST = "Wow! Even as a ghost you're super tough, %s!",
            FIRESTARTER = "You're supposed to put fires out when you're finished.",
        },
        WINONA =
        {
            GENERIC = "Hi %s! Build anything neat today?",
            ATTACKER = "Don't do hits, %s!",
            MURDERER = "Murderer! We didn't wanna have to do this!",
            REVIVER = "%s keeps us all together.",
            GHOST = "Aw, I'm sorry that happened to you, %s.",
            FIRESTARTER = "Don't light fires, %s!",
        },
        WORTOX =
        {
            GENERIC = "Hey %s! Your horns look nice!",
            ATTACKER = "Hey, play nice, %s!",
            MURDERER = "Oh no! %s, what did you do!",
            REVIVER = "Grandpa always said laughter was the best medicine!",
            GHOST = "Oh no, %s! You're hurt!",
            FIRESTARTER = "Don't play tricks, Mr. Imp!",
        },
        WORMWOOD =
        {
            GENERIC = "Hey, it's my good friend, %s!",
            ATTACKER = "Hey, %s! Friends don't hit friends!",
            MURDERER = "Wickerbottom says we can't be friends anymore!",
            REVIVER = "%s is really rooting for us!",
            GHOST = "Poor %s! He died of loneliness!",
            FIRESTARTER = "I don't think it's safe for you to be around fire.",
        },

        MULTIPLAYER_PORTAL = "It's pretty... pretty scary!",
        MULTIPLAYER_PORTAL_MOONROCK = "Gosh. It's so sparkly!",
        CONSTRUCTION_PLANS = "We should build this.",
        MOONROCKIDOL = "It looks kinda like an alien.",
        MOONROCKSEED = "Neat, it's a ball that floats by itself!",

        BERNIE_INACTIVE =
        {
            BROKEN = "It's all busted up.",
            GENERIC = "A teddy bear.",
        },
        BERNIE_ACTIVE = "That teddy bear is moving!",
        BERNIE_BIG = "It's creepy and cute at the same time!!",

        LAVA_POND_ROCK = "Wow! A rock!",

        GLOMMER = "Nice eyes.",
        GLOMMERFLOWER =
        {
            GENERIC = "It doesn't smell very nice.",
            DEAD = "I spoke too soon. It smells worse now.",
        },
        GLOMMERWINGS = "I wish I'd at least ended up with wings. Sigh.",
        GLOMMERFUEL = "Yucky muck!",
        BELL = "Exactly the right amount of bell.",
        STATUEGLOMMER =
        {
            GENERIC = "A statue of some weird bug.",
            EMPTY = "Take that, rock bug!",
        },

		WEBBERSKULL = "How did this get here?",
		WORMLIGHT = "It's gushing with light.",
        WORMLIGHT_LESSER = "I dare you to eat it!",
		WORM =
		{
		    PLANT = "What could possibly go wrong?",
		    DIRT = "Some dirt, big whoop.",
		    WORM = "Creepy crawly!",
		},
        WORMLIGHT_PLANT = "What could possibly go wrong?",
		MOLE =
		{
			HELD = "Are you comfy?",
			UNDERGROUND = "Come out and play!",
			ABOVEGROUND = "Hello little guy!",
		},
		MOLEHILL = "Hidey-hole.",
		MOLEHAT = "It sees for miles and miles.",

		EEL = "Fresh water-snake.",
		EEL_COOKED = "We could slurp this down.",
		UNAGI = "It was easy to make with all our arms.",
		EYETURRET = "Stop looking at me!",
		EYETURRET_ITEM = "Wakey wakey!",
		MINOTAURHORN = "It's quite tender.",
		MINOTAURCHEST = "What a big treasure box!",
		THULECITE_PIECES = "Small bits of fancy rock.",
		POND_ALGAE = "Just a normal pond plant.",
		GREENSTAFF = "Magic taker-apart-er.",
		GIFT = "Oh! What is it?!",
        GIFTWRAP = "I want to give someone something nice!",
		POTTEDFERN = "Mum would like this nice fern.",
		SUCCULENT_POTTED = "I wonder if mum's ever seen one.",
        SUCCULENT_PLANT = "We think it's a cactus.",
        SUCCULENT_PICKED = "It got picked.",
		SENTRYWARD = "Woah! I bet it sees so far!",
		TOWNPORTAL =
        {
			GENERIC = "Floaty and weird.",
			ACTIVE = "I hope no one gets a headache.",
		},
        TOWNPORTALTALISMAN = 
        {
			GENERIC = "We didn't know rocks could smell.",
			ACTIVE = "I think it's ready!",
		},
		WETPAPER = "It'll probably dry off soon. Maybe.",
		WETPOUCH = "We hope the stuff inside didn't get smushed.",
        MOONROCK_PIECES = "Oh... We don't like this!",
        MOONBASE =
        {
            GENERIC = "I wonder what it wants?",
            BROKEN = "It's broke.",
            STAFFED = "Something else needs to happen, right?",
            WRONGSTAFF = "I don't think it wanted that.",
            MOONSTAFF = "Bright sticky stick!",
        },
        MOONDIAL = 
        {
			GENERIC = "Hey, Ms. Wicker! How come we can still see the moon?",
			NIGHT_NEW = "New moon! Neat!",
			NIGHT_WAX = "The moon is growing!",
			NIGHT_FULL = "Wow! Full moon!",
			NIGHT_WANE = "The moon is shrinking!",
			CAVE = "The moon can't fit in a cave! I think.",
        },

		LIGHTER = "Lighter than what?",
		ANTLION = 
		{
			GENERIC = "You're fuzzy. We like that.",
			VERYHAPPY = "It's always nice to have more bug friends.",
			UNHAPPY = "I think it's upset.",
		},
		ANTLIONTRINKET = "Sand castles!!",
		SANDSPIKE = "Ouchie!",
        SANDBLOCK = "Not like this!!",
        GLASSSPIKE = "Careful, it's fragile.",
        GLASSBLOCK = "We think it's great and we love it.",
		ABIGAIL_FLOWER =
		{
			GENERIC = "Pretty petals!",
			LONG = "I think it's listening to us!",
			MEDIUM = "It's getting creepy!",
			SOON = "It gives us itches and skritches up our spine!",
			HAUNTED_POCKET = "Put it down! Put it down!",
			HAUNTED_GROUND = "Scary blossoms!",
		},

		BOOK_BIRDS = "This one has pictures!",
		BOOK_TENTACLES = "Why are the pages all slimy?",
		BOOK_GARDENING = "Why should we read about flowers when we can pick them?",
		BOOK_SLEEP = "It's... beddy-bye time...",
		BOOK_BRIMSTONE = "We don't like how that one ends!",
		--BOOK_METEOR = "I'm not a good reader, but he is!",
		LUCY = "If we talk to it will it talk back?",
		BALLOONS_EMPTY = "Is there going to be a party?!",
		BALLOON = "Balloon animals! Balloon animals!!",
		SPEAR_WATHGRITHR = "Pointy ouchies!",
		WATHGRITHRHAT = "Haha! It's way too big for us!",
		WAXWELLJOURNAL = "I don't think we should play with that...",
		ROCK_MOON = "Neat!",
		MOONROCKNUGGET = "Neat!",
        MOONROCKCRATER = "Haha. It's heavy!",

        REDMOONEYE = "That rock needs a nap. Its eye is all red!",
        PURPLEMOONEYE = "Now we won't need to leave a trail of breadcrumbs!",
        GREENMOONEYE = "We could always use more eyes!",
        ORANGEMOONEYE = "This rock helps me find my friends!",
        YELLOWMOONEYE = "Even with all our eyes, we'd still lose in a staring contest.",
        BLUEMOONEYE = "Hey! Did anyone lose an eye?",

		--OBSIDIANMACHETE = "It cooks with every cut!",
		--MACHETE = "Hyah! Hyah!",
		--MOWER = "Hyah! Hyah!",
		--GOLDENMACHETE = "What a beautiful blade!",
		THULECITE = "Fancy rocks!",
		ARMORRUINS = "Nice and lightweight.",
		ARMORSKELETON = "Rattle rattle.",
		SKELETONHAT = "It's not very comfy.",
		RUINS_BAT = "We will, we will, smash you!",
		RUINSHAT = "And now we are king.",

		BISHOP_NIGHTMARE = "Bishop of bad dreams.",
		ROOK_NIGHTMARE = "You can't rook us.",
		KNIGHT_NIGHTMARE = "Goodnight, good knight.",
		MINOTAUR = "Wear that frown upside down.",
		SPIDER_DROPPER = "Our friends live up there.",
		NIGHTMARELIGHT = "Not exactly my kind of nightlight.",
		NIGHTSTICK = "Night light, night bright!",
		GREENGEM = "I'm absolutely green with envy.",
		MULTITOOL_AXE_PICKAXE = "Double duty.",
		ORANGESTAFF = "Teleportation gives us a chance to rest all our feet.",
		YELLOWAMULET = "Nice and glowy.",
		GREENAMULET = "Time to build!",
		SLURPERPELT = "It's like a tiny rug.",	

		SLURPER = "Hairy tongue thing!",
		SLURPER_PELT = "It's like a tiny rug.",
		ARMORSLURPER = "Squeeze our tummy tight!",
		ORANGEAMULET = "Many legs make light work, and so does this.",
		YELLOWSTAFF = "We summon you, warm ball of light!",
		YELLOWGEM = "Yellow-bellied gem.",
		ORANGEGEM = "Orange you glad we found you, gem?",
        OPALSTAFF = "Whew. Gotta be careful where you point it!",
        OPALPRECIOUSGEM = "We see eight million eyes reflecting back at us. Neat!",
		TELEBASE = 
		{
			VALID = "Teleportation, away!",
			GEMS = "It needs s'more purple gems.",
		},
		GEMSOCKET = 
		{
			VALID = "Looks prepped.",
			GEMS = "Still needs a gem.",
		},
		STAFFLIGHT = "Cozy.",
        STAFFCOLDLIGHT = "Woah! The cold makes all our hairs stand up!",
	
        ANCIENT_ALTAR = "Old and full of mysteries.",

        ANCIENT_ALTAR_BROKEN = "It's been busted up.",

        ANCIENT_STATUE = "It's throbbing strangely.",

        LICHEN = "It likes it down here.",
		CUTLICHEN = "I like me a lichen.",

		CAVE_BANANA = "A bundle of bananas.",
		CAVE_BANANA_COOKED = "Hot mush.",
		CAVE_BANANA_TREE = "It's a tropical cave tree, of course.",
		ROCKY = "Snip snap!",
		
		NIGHTMARE_TIMEPIECE =
		{
			CALM = "Everything's dandy.",
			WARN = "Something's brewing.",
			WAXING = "It's getting magickier!",
			STEADY = "Stable, for now.",
			WANING = "Magic go down the hole.",
			DAWN = "Return to us, day!",
			NOMAGIC = "Not much magic here.",
		},
		COMPASS =
		{
			GENERIC= "No reading!",
			N = "North!",
			S = "South!",
			E = "East!",
			W = "West!",
			NE = "Northeast!",
			SE = "Southeast!",
			NW = "Northwest!",
			SW = "Southwest!",
		},
        HOUNDSTOOTH = "It's the perfect tooth to gnash.",
        ARMORSNURTLESHELL = "It didn't protect the last guy.",
        BAT = "Screechy mean guy!",
        BATBAT = "Flap that bat like you were born to do it.",
        BATWING = "This thing drives me batty.",
        BATWING_COOKED = "Tastes like chicken.",
        BATCAVE = "Oooh they're hiding in there!",
        BEDROLL_FURRY = "I miss being able to properly feel a nice bedroll.",
        BUNNYMAN = "Hop along, lil bunny.",
        FLOWER_CAVE = "Oooh, a glowing ball of flower!",
        GUANO = "Bat doodoo.",
        LANTERN = "The sun's trapped in there.",
        LIGHTBULB = "Bright and delicious.",
        MANRABBIT_TAIL = "We feel lucky, oh so lucky.",
        MUSHROOMHAT = "It's a cap cap!",
        MUSHROOM_LIGHT2 =
        {
            ON = "We love all the colors!",
            OFF = "Maybe the night won't be as scary now.",
            BURNT = "Aw. It was kinda growing on us.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "It's giving off a nice light.",
            OFF = "It still needs to be turned on.",
            BURNT = "Well that's no fun-gus.",
        },
        SLEEPBOMB = "Throwable nap time!",
        MUSHROOMBOMB = "Explodey fungus!",
        SHROOM_SKIN = "Haha! Yuck!",
        TOADSTOOL_CAP =
        {
            EMPTY = "Do you think we'd fit?",
            INGROUND = "I think it needs help getting out.",
            GENERIC = "Mushroom! It's a mushroom!",
        },
        TOADSTOOL =
        {
            GENERIC = "Yikes! That's a big frog!",
            RAGE = "Toadally terrifying!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "I think it's doing something bad!",
            BURNT = "We should have chopped it!",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "How did it get so big?",
            BLOOM = "It sounds so funny!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "It's upsettingly large.",
            BLOOM = "Hahah! Wow, it smells so bad!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Bigger than a normal mushroom.",
            BLOOM = "It's all round and squishy now!",
        },
        MUSHTREE_TALL_WEBBED = "This one looks friendly!",
        SPORE_TALL =
        {
            GENERIC = "Blue! That's our favorite color!",
            HELD = "If we eat it we'll turn to water!",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Our favorite color! Red!",
            HELD = "If we stare at it we'll turn to stone!",
        },
        SPORE_SMALL =
        {
            GENERIC = "That's green, our favoritest color!",
            HELD = "If we lick it we'll turn to wood!",
        },
        RABBITHOUSE =
        {
            GENERIC = "Just like grandpa said, \"You live in what you eat.\"",
            BURNT = "A little overdone and overlarge.",
        },
        SLURTLE = "We'll slaughter that slurtle.",
        SLURTLE_SHELLPIECES = "Maybe that was a little too rough.",
        SLURTLEHAT = "A solid helmet.",
        SLURTLEHOLE = "Slimy and rocky.",
        SLURTLESLIME = "Slime-time!",
        BURNT_MARSH_BUSH = "All burned up.",
        SNURTLE = "Let's snuff out that snurtle.",
        SPIDER_HIDER = "Friends!",
        SPIDER_SPITTER = "Lay down some web for us.",
        SPIDERHOLE = "We could stand to live there.",
        TREECLUMP = "It's in our way!",
        MAXWELLHEAD = "Imagine the trouble he has buying hats!",
        WATERMELON_SEEDS = "If we eat these will they grow inside us?",
        SPIDERHOLE_ROCK = "We could stand to live there.",
        STALAGMITE = "Rocks, underground?! Shocking.",
        STALAGMITE_TALL = "Pointy rocks, underground?! Simply stunning.",

		TURF_CARPETFLOOR = "Soft like our body.",
		TURF_CHECKERFLOOR = "Our feet go click-clack on this.",
		TURF_DIRT = "Some pretty average earth.",
		TURF_FOREST = "Some pretty average earth.",
		TURF_GRASS = "Some pretty average earth.",
		TURF_MARSH = "Some pretty average earth.",
		TURF_ROAD = "Some pretty average earth.",
		TURF_ROCKY = "Some pretty average earth.",
		TURF_SAVANNA = "Some pretty average earth.",
		TURF_WOODFLOOR = "Some pretty average earth.",

		TURF_CAVE="Some pretty average earth.",
		TURF_FUNGUS="Some pretty average earth.",
		TURF_SINKHOLE="Some pretty average earth.",
		TURF_UNDERROCK="Some pretty average earth.",
		TURF_MUD="Some pretty average earth.",

		POWCAKE = "Mum never let me have these.",
        CAVE_ENTRANCE = "It's plugged up.",
        CAVE_ENTRANCE_RUINS = "It's plugged up.",

		CAVE_ENTRANCE_OPEN = 
        {
            GENERIC = "We'd rather visit our spider friends on the surface.",
            OPEN = "I can hear some spider friends down there.",
            FULL = "We'll explore when everyone else has had their turn!",
        },
        CAVE_EXIT = 
        {
            GENERIC = "We like it down here.",
            OPEN = "It leads back to the light.",
            FULL = "They don't have enough space for us!",
        },

		MAXWELLPHONOGRAPH = "We could listen to that forever!",
		BOOMERANG = "Boomerangarangarang!",
		PIGGUARD = "We wouldn't want to cross that one.",
		ABIGAIL = "That's no party poltergeist!",
		ADVENTURE_PORTAL = "Something wicked this way comes.",
		AMULET = "It's a fine necklace, I suppose.",
		ANIMAL_TRACK = "Whatever it is, it travels single file.",
		ARMORGRASS = "It just feels like more hair.",
		ARMORMARBLE = "Marbelous protection!",
		ARMORWOOD = "Wood you like to fight?",
		ARMOR_SANITY = "It's a bit uneasy wearing this, but so effective.",
		ASH =
		{
			GENERIC = "Funk to funky.",
			REMAINS_GLOMMERFLOWER = "The flower didn't make it.",
			REMAINS_EYE_BONE = "The eyebone didn't survive the trip.",
			REMAINS_THINGIE = "Whatever it was, it's gone back to the earth.",
		},
		AXE = "Chop and chop.",
		BABYBEEFALO = 
		{
			GENERIC = "Get busy, child.",
		    SLEEPING = "That's the opposite of busy.",
        },
        BUNDLE = "That's one of my favorite things!",
		BUNDLEWRAP = "Let's cocoon something for later!",
		BACKPACK = "It's like a second abdomen we can store things in.",
		BACONEGGS = "I'd rather have sugary cereal. Oh well.",
		BANDAGE = "Bandages for booboos.",
		BASALT = "Impenetrable.",
		BEARDHAIR = "In another life, I could've grown this.",
		BEARGER = "Run for the hills!",
		BEARGERVEST = "We'll be the hairiest spider ever.",
		ICEPACK = "It's fuzzy!",
		BEARGER_FUR = "It's so thick!",
		FURTUFT = "Fluffy, and not from a spider.",		
		BEDROLL_STRAW = "Musty but relaxing.",
		BEEQUEEN = "Bees aren't our friends!",
		BEEQUEENHIVE = 
		{
			GENERIC = "Not web. We can't walk on it.",
			GROWING = "I wonder what the bees are making!",
		},
		BEEQUEENHIVEGROWN = "Oh, bother!",
        BEEGUARD = "So fluffy but so mean!!",
        HIVEHAT = "We could be part bee now too!",
        MINISIGN =
        {
            GENERIC = "That looks nice!",
            UNDRAWN = "Can someone lend us a pencil?",
        },
        MINISIGN_ITEM = "Let's build it!",
		BEE =
		{
			GENERIC = "Always Be Pollinating.",
			HELD = "Ours now!",
		},
		BEEBOX =
		{
			FULLHONEY = "It's full to brimming.",
			READY = "It's full to brimming.",
			GENERIC = "It's a box with bees in it.",
			NOHONEY = "There's no honey inside.",
			SOMEHONEY = "Work faster, bees!",
			BURNT = "The site of The Great Honey Fire.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Wow! So many mushrooms!",
			LOTS = "They look happy.",
			SOME = "Aw, they're so little.",
			EMPTY = "There aren't any mushrooms.", -- tell the player to put a mushroom or spore into the farm to get things started
			ROTTEN = "It's all yucky.", -- tell the player to put a log into the farm to restore it
			BURNT = "Fire's dangerous, I guess.",
			SNOWCOVERED = "You look chilly.",
		},
		BEEFALO =
		{
			FOLLOWER = "He seems to want to stick around.",
			GENERIC = "Big big beefalo!",
			NAKED = "Shaved you good!",
			SLEEPING = "Slumber deep, beefalo.",
            --Domesticated states:
            DOMESTICATED = "This one likes us!",
            ORNERY = "We're kind of scared of this one.",
            RIDER = "This one looks fast.",
            PUDGY = "We like to cuddle this one!",
		},
		BEEFALOHAT = "The wearer will blend in perfectly.",
		BEEFALOWOOL = "Thick fur.",
		BEEHAT = "It's a face fortress!",
		BEESWAX = "This stuff gives me hives.",
		BEEHIVE = "It's a hive of activity.",
		BEEMINE = "Would you bee mine?",
		BEEMINE_MAXWELL = "I just can't mosquito you.",
		BERRIES = "Juice sacks.",
		BERRIES_COOKED = "Warm juice sacks.",
        BERRIES_JUICY = "Yum! Let's find more!",
        BERRIES_JUICY_COOKED = "They're so filling!",
		BERRYBUSH =
		{
			BARREN = "It's run out of plant food.",
			WITHERED = "Heat too intense for ya?",
			GENERIC = "Ripe for the pickin'.",
			PICKED = "See you soon, berries!",
			DISEASED = "Maybe it needs some chicken soup?",
			DISEASING = "Are you okay, lil bush?",
			BURNING = "Uh-oh! Burnies!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "It needs some poops!",
			WITHERED = "Aww, are you sad?",
			GENERIC = "Those berries look so juicy!",
			PICKED = "It's taking a nap.",
			DISEASED = "Maybe it needs some chicken soup?",
			DISEASING = "Are you okay, lil bush?",
			BURNING = "Uh-oh! Burnies!",
		},
		BIGFOOT = "AAAAAAAAAAH!",
		--SUNKBOAT = "So close, so far away.",
		BIRDCAGE =
		{
			GENERIC = "It's the jail.",
			OCCUPIED = "Jailbird.",
			SLEEPING = "You have to sleep to survive in the jail.",
			HUNGRY = "He looks hungry.",
			STARVING = "We need to feed him.",
			DEAD = "We weren't very good wardens.",
			SKELETON = "Eww.",
		},
		BIRDTRAP = "Come to our web trap, birds!",
		BIRD_EGG = "A hard shelled egg.",
		PANDORASCHEST = "Stylish storage.",
		SCORCHED_SKELETON = "They're probably fine.",
		CAVE_BANANA_BURNT = "Oopsie doodle.",
		BIRD_EGG_COOKED = "Fried just like mum did.",
		BISHOP = "You don't play by the chess rules grandpa taught me.",
		BLOWDART_FIRE = "One step above blowing hot air.",
		BLOWDART_SLEEP = "Airborne sleeping agent.",
		BLOWDART_PIPE = "Same as blowing bubbles.",
		BLOWDART_YELLOW = "It's a shock to the system.",
		BLUEAMULET = "I guess it's nice.",
		BLUEGEM = "Glittering and cool.",
		BLUEPRINT =
		{ 
            COMMON = "\"Follow the instructions\", mum always said.",
            RARE = "This one feels special.",
        },
        SKETCH = "We need somewhere to make it!",
		--BELL_BLUEPRINT = "We're ankle-deep in knowledge!",
		BLUE_CAP = "You'd have to be crazy...",
		BLUE_CAP_COOKED = "Good thing we're feeling healthy.",
		BLUE_MUSHROOM =
		{
			GENERIC = "Vroom vroom, mushroom.",
			INGROUND = "Hiding, are we?",
			PICKED = "Maybe it will regrow.",
		},
		BOARDS = "Logs, but flat.",
		BOAT = "All these legs, but we don't row.",
		BONESHARD = "Boney bits.",
		BONESTEW = "Smells like Sunday supper.",
		BUGNET = "I'm not a bug! We're an arachnid!",
		BUSHHAT = "For looking bushier!",
		BUTTER = "Butter is better.",
		BUTTERFLY =
		{
			GENERIC = "Look at it, flitting around happily.",
			HELD = "Not so happy now, are we?",
		},
		BUTTERFLYMUFFIN = "Do you know the muffin spider?",
		BUTTERFLYWINGS = "Pick our teeth with butterfly bones.",
		BUZZARD = "You won't find any carrion here. We're stuck like this.",
		CACTUS = 
		{
			GENERIC = "It's got more things coming out of it than we do.",
			PICKED = "It's got no meat left in it.",
		},
		CACTUS_MEAT_COOKED = "Take that, pokey things!",
		CACTUS_MEAT = "Haven't had enough, huh?",
		CACTUS_FLOWER = "This part is nice.",
		COLDFIRE =
		{
			EMBERS = "We should put something on the fire before it goes out.",
			GENERIC = "Sure beats the heat. And darkness.",
			HIGH = "That fire is huge!",
			LOW = "The fire's getting a touch low.",
			NORMAL = "Nice and cool.",
			OUT = "Well, that's done.",
		},
		CAMPFIRE =
		{
			EMBERS = "We should put something on the fire before it goes out.",
			GENERIC = "Sure beats the cold. And darkness.",
			HIGH = "That fire is huge!",
			LOW = "The fire's getting a touch low.",
			NORMAL = "Nice and warm.",
			OUT = "Well, that's done.",
		},
		CANE = "One more point of contact couldn't slow us down.",
		CATCOON = "A bit more feral than grandpa's cat.",
		CATCOONDEN = 
		{
			GENERIC = "Trunk house.",
			EMPTY = "The nine lives thing is true!",
		},
		CATCOONHAT = "Hat of a cat.",
		COONTAIL = "I always liked pulling Whiskers' tail.",
		CARROT = "I sort of miss being forced to eat these.",
		CARROT_COOKED = "Easier for us both.",
		CARROT_PLANTED = "Bury your head, carrot.",
		CARROT_SEEDS = "We could grow something with these.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Heh heh. I was never allowed in father's study.",
			BURNING = "Ohh no, uh, oh no!",
			BURNT = "That's probably why I wasn't allowed in father's study.",
		},
		CAVE_FERN = "Swirly plants.",
		CHARCOAL = "Hard and black, like my better half.",

        CHESSPIECE_PAWN = "Pawns are just as important as the rest of the pieces.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Where's the king of the castle?",
            STRUGGLE = "It's... alive?!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "We could sculpt a stallion battalion!",
            STRUGGLE = "It's... alive?!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "We've never seen toys so big.",
            STRUGGLE = "It's... alive?!",
        },
        CHESSPIECE_MUSE = "We're sure she's nicer than she looks.",
        CHESSPIECE_FORMAL = "Reminds me of grandpa.",
        CHESSPIECE_HORNUCOPIA = "Boy, I wish we could eat it.",
        CHESSPIECE_PIPE = "Bubbles!",
        CHESSPIECE_DEERCLOPS = "This is a really good sculpture.",
        CHESSPIECE_BEARGER = "The fur looks so real!",
        CHESSPIECE_MOOSEGOOSE = "She doesn't look so mean.",
        CHESSPIECE_DRAGONFLY = "We can practically feel the fire!",
        CHESSJUNK1 = "A mess of chess.",
        CHESSJUNK2 = "A mess of chess.",
        CHESSJUNK3 = "A mess of chess.",
		CHESTER = "Haha. You make all our stuff slobbery.",
		CHESTER_EYEBONE =
		{
			GENERIC = "Peekaboo.",
			WAITING = "We spy a tired eye.",
		},
		COOKEDMANDRAKE = "Cooked to death.",
		COOKEDMEAT = "Can't have any pudding if we don't eat it.",
		COOKEDMONSTERMEAT = "I don't know what everyone's complaining about.",
		COOKEDSMALLMEAT = "Meat treat.",
		COOKPOT =
		{
			COOKING_LONG = "It won't be done for a while.",
			COOKING_SHORT = "Almost ready!",
			DONE = "Supper is served.",
			EMPTY = "Food goes in, other food comes out.",
			BURNT = "Someone must have left the fire going.",
		},
		CORN = "Corn in the raw.",
		CORN_COOKED = "Popping corn.",
		CORN_SEEDS = "We could grow something with these.",
		CANARY =
		{
			GENERIC = "That's a yellow bird.",
			HELD = "Caught you!",
		},
		CANARY_POISONED = "Uh, are you feeling okay?",

		CRITTERLAB = "It looks warm in there.",
        CRITTER_GLOMLING = "He gives the fuzziest hugs.",
        CRITTER_DRAGONLING = "She's a monster just like me!",
		CRITTER_LAMB = "Father taught me how to take care of goats!",
        CRITTER_PUPPY = "We're best friends.",
        CRITTER_KITTEN = "You look like grandpa's cat!",
        CRITTER_PERDLING = "Gobble gobble!",

		CROW =
		{
			GENERIC = "Oh, you look like you're having a grand time, flying about.",
			HELD = "We all want a bit of freedom.",
		},
		CUTGRASS = "We should be able to weave this, too.",
		CUTREEDS = "Reeds, web, what's the difference.",
		CUTSTONE = "Squared rocks.",
		DEADLYFEAST = "Scent of doom.",
		DEER = 
		{
			GENERIC = "It looks soft.",
			ANTLER = "Did you change your hair? Looks good!",
		},
		DEER_ANTLER = "Haha, weird.",
		DEER_GEMMED = "Don't hurt us and we won't hurt you!",
		KLAUSSACKKEY = "I think maybe this goes somewhere.",
		DEERCLOPS = "He might be able to digest me!",
		DEERCLOPS_EYEBALL = "Yucktastic.",
		EYEBRELLAHAT =	"Disturbing, but it'll keep us dry.",
		DEPLETED_GRASS =
		{
			GENERIC = "It was once grass.",
		},
		GOGGLESHAT = "We wish it had eight lenses.",
        DESERTHAT = "It covers our biggest eyes, anyway.",
		DEVTOOL = "Axe me a question!",
		DEVTOOL_NODEV = "I can't wield that.",
		DIRTPILE = "A pile of dirt. I bet it's hiding something.",
		DIVININGROD =
		{
			COLD = "Nothing nearby.",
			GENERIC = "Lead and I shall follow.",
			HOT = "We are close!",
			WARM = "Going the right way.",
			WARMER = "Something must be near.",
		},
		DIVININGRODBASE =
		{
			GENERIC = "It's a mystery.",
			READY = "Looks like there's a hole for an oversized key.",
			UNLOCKED = "It's ready to go.",
		},
		DIVININGRODSTART = "Radical rod!",
		DRAGONFLY = "Oh, don't you just drag on.",
		ARMORDRAGONFLY = "Another creature casing.",
		DRAGON_SCALES = "They don't weigh much for scales.",
		DRAGONFLYCHEST = "It looks like my old toy chest!",
		DRAGONFLYFURNACE = 
		{
		    HAMMERED = "What happened to your face?",
			GENERIC = "It's a fancy furnace!", --no gems
			NORMAL = "Warmish furnace.", --one gem
			HIGH = "Hot hot furnace!", --two gems
		},

		HUTCH = "Give us a Huggy!",
        HUTCH_FISHBOWL =
        {
            GENERIC = "He's our new friend.",
            WAITING = "He was our new friend.",
        },

		LAVASPIT = 
		{
			HOT = "Too hot for us!",
			COOL = "Looks safe now.",
		},
		LAVA_POND = "Ouch! Burnies!",
		LAVAE = "Sizzling hot!",
		LAVAE_COCOON = "Being all froze up probably isn't comfy.",
		LAVAE_PET = 
		{
			STARVING = "It looks starving!",
			HUNGRY = "Poor hungry lavae.",
			CONTENT = "Happy lavae!",
			GENERIC = "It's my friend.",
		},
		LAVAE_EGG = 
		{
			GENERIC = "Maybe I can make it hatch?",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Poor egg. It looks cold.",
			COMFY = "The egg seems happy.",
		},
		LAVAE_TOOTH = "What a weird tooth.",

		DRAGONFRUIT = "It looks suspect.",
		DRAGONFRUIT_COOKED = "It looks tastier now.",
		DRAGONFRUIT_SEEDS = "We could grow something with these.",
		DRAGONPIE = "Oh! Sweet and tasty!!",
		DRUMSTICK = "I just want to bang on my drum.",
		DRUMSTICK_COOKED = "We love finger food.",
		DUG_BERRYBUSH = "Into the ground with you!",
		DUG_BERRYBUSH_JUICY = "Into the ground with you!",
		DUG_GRASS = "Into the ground with you!",
		DUG_MARSH_BUSH = "Into the ground with you!",
		DUG_SAPLING = "Into the ground with you!",
		DURIAN = "Pungent.",
		DURIAN_COOKED = "No sir, I don't like it.",
		DURIAN_SEEDS = "We could grow something with these.",
		EARMUFFSHAT = "Strap some rabbits to your head, good idea.",
		EGGPLANT = "Blech, eggplant.",
		EGGPLANT_COOKED = "Mum knew I liked it braised.",
		EGGPLANT_SEEDS = "We could grow something with these.",

		ENDTABLE = 
		{
			BURNT = "Antiques are dumb, anyway.",
			GENERIC = "Looks great!",
			EMPTY = "Reminds me of antique shopping with mother.",
			WILTED = "They look sad.",
			FRESHLIGHT = "Nice and bright!",
			OLDLIGHT = "It's gonna go out soon.",
		},
		DECIDUOUSTREE = 
		{
			BURNING = "What a senseless waste of firewood.",
			BURNT = "Only we can prevent forest fires.",
			CHOPPED = "Would a cool bandage make it better, Mr. Tree?",
			POISON = "What're you so mad about?",
			GENERIC = "My, what nice foliage you have.",
		},
		ACORN = "Tree or food, there's something inside.",
        ACORN_SAPLING = "May you have a long and free life.",
		ACORN_COOKED = "Roasted on an open fire.",
		BIRCHNUTDRAKE = "So that's what's inside!",
		EVERGREEN =
		{
			BURNING = "What a senseless waste of firewood.",
			BURNT = "Only we can prevent forest fires.",
			CHOPPED = "Would a cool bandage make it better, Mr. Tree?",
			GENERIC = "Pines are always greener on the other side of the fence.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "What a senseless waste of firewood.",
			BURNT = "Only we can prevent forest fires.",
			CHOPPED = "Would a cool bandage make it better, Mr. Tree?",
			GENERIC = "A dying breed.",
		},
		EYEPLANT = "Ever vigilant.",
		FARMPLOT =
		{
			GENERIC = "I'll have a go at this farming thing.",
			GROWING = "C'mooon, plants!",
			NEEDSFERTILIZER = "The soil is dried up.",
			BURNT = "A razed farm is no farm at all.",
		},
		FEATHERHAT = "It looks like it took a whole flock to make that hat!",
		FEATHER_CANARY = "Feather of yellow.",
		FEATHER_CROW = "Feather of black.",
		FEATHER_ROBIN = "Feather of red.",
		FEATHER_ROBIN_WINTER = "Feather of white.",
		FEATHERPENCIL = "Haha! It tickles!",
		FEM_PUPPET = "She's locked up!",
		FIREFLIES =
		{
			GENERIC = "Elusive little buggies.",
			HELD = "Going on an adventure, got some fireflies in our pocket!",
		},
		FIREHOUND = "He's got a fire under his feet. And all inside him.",
		FIREPIT =
		{
			EMBERS = "We should put something on the fire before it goes out.",
			GENERIC = "Sure beats the cold. And darkness.",
			HIGH = "That fire is huge!",
			LOW = "The fire's getting a touch low.",
			NORMAL = "Nice and warm.",
			OUT = "Well, that's done. But not forever!",
		},
		COLDFIREPIT =
		{
			EMBERS = "We should put something on the fire before it goes out.",
			GENERIC = "Sure beats the heat. And darkness.",
			HIGH = "That fire is huge!",
			LOW = "The fire's getting a touch low.",
			NORMAL = "Nice and cool.",
			OUT = "Well, that's done. But not forever!",
		},
		FIRESTAFF = "We didn't start the fire.",
		FIRESUPPRESSOR = 
		{	
			ON = "This would come in handy in a snowball fight.",
			OFF = "It's off.",
			LOWFUEL = "Running low on fuel.",
		},

		FISH = "It could stand to be fried.",
		FISHINGROD = "I miss grandpa's fishing trips.",
		FISHSTICKS = "One of my favorite foods! Just me though.",
		FISHTACOS = "Taco Tuesday!",
		FISH_COOKED = "Flaky and moist. Delicious.",
		FLINT = "Oh, to feel a sharp edge against my skin.",
		FLOWER =
		{
            GENERIC = "We agree that flowers are nice.",
            ROSE = "Bright red petals! We love it!",
        },
        FLOWER_WITHERED = "Aww so sad!",
		FLOWERHAT = "Colorful crown.",
		FLOWER_EVIL = "This flower is decidedly not nice!",
		FOLIAGE = "Soft and leafy.",
		FOOTBALLHAT = "We could be good at football, much better than I was!",
		FOSSIL_PIECE = "We want to play archaeologist!",
        FOSSIL_STALKER =
        {
			GENERIC = "Needs more bones!",
			FUNNY = "Maybe we shouldn't play with bones.",
			COMPLETE = "That looks real good!",
        },
        STALKER = "I don't think it's friendly.",
        STALKER_ATRIUM = "We'll defend ourselves if we have to.",
        STALKER_MINION = "Creepy!",
        THURIBLE = "It gets really hot.",
        ATRIUM_OVERGROWTH = "We never learned those letters.",
		FROG =
		{
			DEAD = "A hop too far.",
			GENERIC = "Ack! Sticky tongue!",
			SLEEPING = "Oblivious amphibious.",
		},
		FROGGLEBUNWICH = "Sandwich for me, frog legs for him.",
		FROGLEGS = "A fraction of a frog.",
		FROGLEGS_COOKED = "I admit, we've acquired a taste for those.",
		FRUITMEDLEY = "Pile o'fruit.",
		GEARS = "WX eats them by the fistful!",
		GHOST = "That's not a fun ghost!",
		GOLDENAXE = "Life is okay when you've got a golden axe.",
		GOLDENPICKAXE = "The finest pickaxe of them all.",
		GOLDENPITCHFORK = "We can do some fancy forking with this.",
		GOLDENSHOVEL = "We're gonna dig so many holes.",
		GOLDNUGGET = "We definitely like shiny.",
		GRASS =
		{
			BARREN = "It could use some perking up.",
			WITHERED = "The heat wave bested it.",
			BURNING = "Fire, fire, fire!",
			GENERIC = "Grass, next best thing to silk.",
			PICKED = "Picked down to the stems.",
			DISEASED = "Maybe it needs some chicken soup?",
			DISEASING = "Are you okay, lil tuft?",
		},
		GREEN_CAP = "Smells really earthy.",
		GREEN_CAP_COOKED = "Heat really brings out the juices.",
		GREEN_MUSHROOM =
		{
			GENERIC = "Ready for harvest.",
			INGROUND = "We can't get at it!",
			PICKED = "It's gone now.",
		},
		GUNPOWDER = "This black powder stuff packs a punch.",
		HAMBAT = "An interesting way to use food.",
		HAMMER = "Chaos and destruction!",
		HEALINGSALVE = "Soothing.",
		HEATROCK =
		{
			FROZEN = "It's cold to the touch.",
			COLD = "It's getting chilly.",
			GENERIC = "It's a rock.",
			WARM = "It's getting hot!",
			HOT = "It's hot to the touch!",
		},
		HOME = "Hellooo? We're here!",
		HOMESIGN =
		{
			GENERIC = "We could write on that if only we had a pen!",
            UNWRITTEN = "Ooooh, what should we say?",
			BURNT = "The lettering burnt off.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "We could write on that if only we had a pen!",
            UNWRITTEN = "Ooooh, what should we say?",
			BURNT = "The lettering burnt off.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "We could write on that if only we had a pen!",
            UNWRITTEN = "Ooooh, what should we say?",
			BURNT = "The lettering burnt off.",
		},
		HONEY = "Sticky and sweet.",
		HONEYCOMB = "Honey pods!",
		HORN = "If this makes a mating call we're all in trouble.",
		HOUND = "That's an angry puppy!",
		HOUNDBONE = "There isn't much left.",
		HOUNDMOUND = "This place scares us.",
		ICEBOX = "Spoil not, food supplies!",
		ICEHAT = "This should keep us cool.",
		ICEHOUND = "He has a chilling look in his eyes.",
		INSANITYROCK =
		{
			ACTIVE = "Move, stupid rock!",
			INACTIVE = "I wonder what that does.",
		},
		HONEYHAM = "Ooo, tasty!",
		HONEYNUGGETS = "We wish they were shaped like dinosaurs.",
		JAMMYPRESERVES = "Ew... sticky fingies.",
		KABOBS = "Foods on a stick!",
		KILLERBEE =
		{
			GENERIC = "Uh oh, run!",
			HELD = "I hope it doesn't escape.",
		},
		KNIGHT = "Wow! That's complicated clockwork.",
		KOALEFANT_SUMMER = "Maybe it's lost.",
		KOALEFANT_WINTER = "We finally found it!",
		KRAMPUS = "Give us back our things!",
		KRAMPUS_SACK = "We could put more in but we're scared to touch the stuff he left inside.",
		LEIF = "Where did that come from?!",
		LEIF_SPARSE = "Where did that come from?!",
		LIGHTNING_ROD =
		{
			CHARGED = "It looks all glowy!",
			GENERIC = "This might keep us safe.",
		},
		LIGHTNINGGOAT = 
		{
			GENERIC = "My father kept goats.",
			CHARGED = "It's all glowy.",
		},
		LIGHTNINGGOATHORN = "This might make a good weapon.",
		GOATMILK = "A glass of milk with every supper.",
		LITTLE_WALRUS = "He has anger in his eyes.",
		LIVINGLOG = "This log has a face.",
		LOG =
		{
			BURNING = "So much for our arts and crafts!",
			GENERIC = "That's a log of wood.",
		},
		LUREPLANT = "What a colorful plant.",
		LUREPLANTBULB = "I wish we could learn to generate meat.",
		MALE_PUPPET = "He doesn't look like he's having much fun.",
        MANDRAKE_ACTIVE = "You're a bad friend!",
        MANDRAKE_PLANTED = "That's a funny looking plant.",
        MANDRAKE = "The skin is all seared.",

		MANDRAKESOUP = "We fall asleep in the bath too!",
		MANDRAKE_COOKED = "The meeping had to stop.",
		MAPSCROLL = "There's nothing on it.",
		MARBLE = "Maybe we should take up sculpting.",
		MARBLEBEAN = "Bean there, done that!",
		MARBLEBEAN_SAPLING = "You can plant anything in the ground!",
        MARBLESHRUB = "That's a weird shape for a bush.",
		MARBLEPILLAR = "Nothing lasts forever on its own.",
		MARBLETREE = "I hope it doesn't fall on us.",
		MARSH_BUSH =
		{
			BURNING = "It will be gone soon!",
			GENERIC = "Hope we don't fall on that.",
			PICKED = "That hurt our hands.",
		},
		MARSH_PLANT = "That's a thirsty plant.",
		MARSH_TREE =
		{
			BURNING = "It's extra dangerous now!",
			BURNT = "Its growing days are over.",
			CHOPPED = "Axes can solve all tree-related problems!",
			GENERIC = "A harsh tree for harsh conditions.",
		},
		MAXWELL = "That jerk tricked us.",
		MAXWELLLIGHT = "Well, these would've been handy before.",
		MAXWELLLOCK = "It's missing something.",
		MAXWELLTHRONE = "That throne makes our skin crawl.",
		MEAT = "Some fire would spice this up.",
		MEATBALLS = "I used to make these with grandpa!",
		MEATRACK =
		{
			DONE = "Food time!",
			DRYING = "Is it done yet? I'm hungry.",
			DRYINGINRAIN = "It's hard to dry when it's raining.",
			GENERIC = "It's not doing us much good empty!",
			BURNT = "Fire takes all.",
		},

		MEAT_DRIED = "That worked better than expected.",
		MERM = "I would've thought they would bathe more often!",
		MERMHEAD = 
		{
			GENERIC = "A waste of food.",
			BURNT = "I wonder who that was.",
		},
		MERMHOUSE = 
		{
			GENERIC = "Smells fishy.",
			BURNT = "It's in worse shape than before!",
		},
		MINERHAT = "A handy light for our head.",
		MONKEY = "He just wants to learn!",

		MONKEYBARREL = "Did you hear something?",
		MONSTERLASAGNA = "Mmm!",
		FLOWERSALAD = "Five servings a day.",
        ICECREAM = "We dream of ice cream.",
        WATERMELONICLE = "Just the thing for a hot summer day.",
        TRAILMIX = "Crunchy and healthy.",
        HOTCHILI = "Flavor bombs!",
        GRASSGEKKO = 
		{
			GENERIC = "Hey! You dropped something!",	
			DISEASED = "It's got ouchies in its tummy.",
		},
        GUACAMOLE = "Holy moley, this is tasty.",
		MONSTERMEAT = "Smells foul.",
		MONSTERMEAT_DRIED = "It's really chewy.",
		MOOSE = "She doesn't look at all pleased to see us.",
		MOOSEEGG = "That would make a huge breakfast!",
		MOSSLING = "Hungry little guys.",
		FEATHERFAN = "This thing is huge!",
        MINIFAN = "It cools us when we run, how nice.",
		GOOSE_FEATHER = "Tickle torture.",
		STAFF_TORNADO = "We'll huff and we'll puff.",
		MOSQUITO =
		{
			GENERIC = "Shoo!",
			HELD = "We should just squish you.",
		},
		MOSQUITOSACK = "Maybe we can put the blood back in?",
		MOUND =
		{
			DUG = "Maybe that was too mean.",
			GENERIC = "Our loot sense is tingling.",
		},
		NIGHTLIGHT = "It makes our skin crawl.",
		NIGHTMAREFUEL = "It's cold and slippery.",
		NIGHTSWORD = "Are you seeing this too?",
		NITRE = "What are we supposed to do with this?",
		ONEMANBAND = "We need to practice more.",
		OASISLAKE = "That's a pretty lake!",
		PANFLUTE = "A well constructed instrument.",
		PAPYRUS = "We could do our homework.",
		WAXPAPER = "Why have paper you can't draw on?",
		PHLEGM = "It's a boogie!",
		PENGUIN = "Where do they live the rest of the year?",
		PERD = "Come back! I just want to eat you!",
		PEROGIES = "It does not look like pie...",
		PETALS = "How colorful.",
		PETALS_EVIL = "They make our head hurt.",
		PETRIFIED_TREE = "It's all stone and no bark.",
		ROCK_PETRIFIED_TREE = "It's all stone and no bark.",
		ROCK_PETRIFIED_TREE_OLD = "It's all stone and no bark.",
		PICKAXE = "Rocks will be ours!",
		PIGGYBACK = "It holds so much stuff!",
		PIGHEAD = 
		{	
			GENERIC = "We just wanted to be friends.",
			BURNT = "Gross.",
		},
		PIGHOUSE =
		{
			GENERIC = "A tall skinny house for a short fat pig.",
			FULL = "I can see a pig through the window!",
			LIGHTSOUT = "Why do they hate me?",
			BURNT = "Not so fancy now, pig!",
		},
		PIGKING = "King of the bullies!",
		PIGMAN =
		{
			DEAD = "He won't bully us any more.",
			GENERIC = "Aw, you're no fun.",
			GUARD = "They look angry.",
			WEREPIG = "He's all furry now!",
			FOLLOWER = "I never knew we could be friends!",
		},
		PIGSKIN = "Take that!",
		PIGTORCH = "If only we could get closer.",
		PINECONE = "It's bursting with life.",
        PINECONE_SAPLING = "Grow, grow!",
        LUMPY_SAPLING = "Weird little plant.",
		PITCHFORK = "A good tool to play in the dirt.",
		PLANTMEAT = "It's all squishy.",
		PLANTMEAT_COOKED = "It smells kind of rotten.",
		PLANT_NORMAL =
		{
			GENERIC = "What will blossom?",
			GROWING = "Is it done yet?",
			READY = "We grew it together!",
			WITHERED = "It's all dried out and dead.",
		},
		POMEGRANATE = "I didn't expect this to grow.",
		POMEGRANATE_COOKED = "It's good for us!",
		POMEGRANATE_SEEDS = "We could grow something with these.",
		POND = "Water doesn't go well with our fur.",
		POOP = "Doodoo.",
		--PORTABLECOOKPOT_ITEM = "Makes yummies!",
		FERTILIZER = "I saw mum use this in her gardens.",
		PUMPKIN = "That's a huge pumpkin!",
		PUMPKINCOOKIE = "Yum!",
		PUMPKIN_COOKED = "It's all warm now.",
		PUMPKIN_LANTERN = "Just like we used to make at home!",
		PUMPKIN_SEEDS = "We could grow something with these.",
		PURPLEAMULET = "Did you hear something?",
		PURPLEGEM = "I can see knowledge swimming inside.",
		RABBIT =
		{
			GENERIC = "We just want to play!",
			HELD = "He's ours now.",
		},
		RABBITHOLE = 
		{
			GENERIC = "Come out! We just want to be friends.",
			SPRING = "I hope they're okay in there.",
		},
		RAINOMETER = 
		{	
			GENERIC = "It must be powered by magic.",
			BURNT = "I don't think that's accurate.",
		},
		RAINCOAT = "Dry fur is the best fur.",
		RAINHAT = "It'll keep the water out of your fur.",
		RATATOUILLE = "Do we have to eat our veggies?",
		RAZOR = "I watched my father use one of these.",
		REDGEM = "It feels warm, even on the coldest nights.",
		RED_CAP = "It smells funny.",
		RED_CAP_COOKED = "It smells better now.",
		RED_MUSHROOM =
		{
			GENERIC = "Ready for the taking!",
			INGROUND = "We can't get at it like that.",
			PICKED = "I think some spores remain.",
		},
		REEDS =
		{
			BURNING = "Those burn quickly!",
			GENERIC = "I bet those would be useful.",
			PICKED = "Only stems remain.",
		},
        RELIC = "These haven't been used in a while.",
        RUINS_RUBBLE = "It looks broken.",
        RUBBLE = "Rocks from an old city.",
		RESEARCHLAB = 
		{	
			GENERIC = "It's like a science lab in here!",
			BURNT = "I think it's broken.",
		},
		RESEARCHLAB2 = 
		{
			GENERIC = "Father used to work on something like that.",
			BURNT = "All our work... gone.",
		},
		RESEARCHLAB3 = 
		{
			GENERIC = "We should be careful around that.",
			BURNT = "The fires care not for magic.",
		},
		RESEARCHLAB4 = 
		{
			GENERIC = "Did I just hear a squeak?",
			BURNT = "Smells like cooking.",
		},
		RESURRECTIONSTATUE = 
		{
			GENERIC = "It's a giant doll of our friend!!",
			BURNT = "It will be of no use to us in that state.",
		},
		RESURRECTIONSTONE = "Some sort of religious monument maybe?",
		ROBIN =
		{
			GENERIC = "Red is my favorite color!",
			HELD = "Held snug in our pockets.",
		},
		ROBIN_WINTER =
		{
			GENERIC = "What pretty white feathers.",
			HELD = "Let's name it \"Francis\".",
		},
		ROBOT_PUPPET = "I don't think they're having fun.",
		ROCK = "We'll need to mine it before we can use it.",
		ROCK_CHARCOAL = "Big, crumbly rock.",
		MOOSE_NESTING_GROUND = "For its babies' sleepytime.",
		PIGTENT = "Little pig, little pig, let me in!",
		ROCK_LIGHT =
		{
			GENERIC = "This lava's all dried up.",
			LOW = "It's a little less cozy.",
			NORMAL = "Cozy!",
			OUT = "It looks like it might break.",
		},
		CAVEIN_BOULDER =
        {
            GENERIC = "We'll need to mine it down, I guess.",
            RAISED = "Gotta get rid of the other boulders first.",
        },
		ROCK_ICE = 
		{
			GENERIC = "Ice can be useful.",
			MELTED = "Puddle!",
		},
		ROCK_ICE_MELTED = "Puddle!",
		ICE = "Chilling.",
		ROCKS = "None of these look like they would skip well.",
        ROOK = "Who made these things!?",
		ROPE = "We could tie stuff up with this.",
		ROTTENEGG = "Ew!",
		ROYAL_JELLY = "It's goopy.",
		JELLYBEAN = "Will they grow into candy beanstalks?",
		SADDLE_RACE = "It's a saddle made out of spidersnacks!",
        SADDLE_BASIC = "We ride!",
        SADDLE_WAR = "We'll have lots of fun riding on this.",
        SADDLEHORN = "Leaves the beast nakey.",
        SALTLICK = "We really regret licking it. Blech.",
        BRUSH = "It's more scratchy than anything.",
		SANITYROCK =
		{
			ACTIVE = "It's in our way.",
			INACTIVE = "Something about this rock feels off.",
		},
		SAPLING =
		{
			BURNING = "So bright!",
			WITHERED = "I think the heat broke it.",
			GENERIC = "These sure grow slowly.",
			PICKED = "Don't worry lil guy, it'll grow back!",
			DISEASED = "Maybe it needs some chicken soup?",
			DISEASING = "Are you okay, lil sapling?",
		},
		SCARECROW = 
   		{
			GENERIC = "Let's play dress up!",
			BURNING = "Someone should address this.",
			BURNT = "He got dressed down.",
   		},
   		SCULPTINGTABLE=
        {
            EMPTY = "I always wanted pottery lessons!",
            BLOCK = "Oh! There's so many possibilities!",
            SCULPTURE = "Wow! It looks great!",
            BURNT = "Aww. Can we make another one?",
        },
		SCULPTURE_KNIGHTHEAD = "Did someone lose this?",
		SCULPTURE_KNIGHTBODY = 
		{
			COVERED = "I think it really ties the island together.",
			UNCOVERED = "Peekaboo, monster!",
			FINISHED = "You look great!",
			READY = "I think it's stuck in there.",
		},
        SCULPTURE_BISHOPHEAD = "I think it's looking at us!",
		SCULPTURE_BISHOPBODY = 
		{
			COVERED = "That looks really nice!",
			UNCOVERED = "Where's your head, mister?",
			FINISHED = "There! All better!",
			READY = "I think it's stuck in there.",
		},
        SCULPTURE_ROOKNOSE = "Looks like a... cactus? No, that's not right.",
		SCULPTURE_ROOKBODY = 
		{
			COVERED = "It's a bit scary, but we don't like to judge.",
			UNCOVERED = "It was hiding!",
			FINISHED = "Oh! That piece was his nose.",
			READY = "I think it's stuck in there.",
		},
		GARGOYLE_HOUND = "Haha. We can stack things on its head and it won't even move.",
        GARGOYLE_WEREPIG = "Yikes.",
		SEEDS = "A small life trapped within. My sympathies.",
		SEEDS_COOKED = "Their growing days are over.",
		SEWING_KIT = "Mum used to handle all of our sewing.",
		SEWING_TAPE = "It's sticky, like a web.",
		SHOVEL = "Maybe we can tunnel our way out?",
		SILK = "It's so smooth!",
		SKELETON = "Hello? Are you alright?",
		--SKELETON_PLAYER = "Er, where did the spider parts go?",

		SKELETON_PLAYER =
		{
			MALE = "Oh no, %s! %s must have really hurt him!",
			FEMALE = "Oh no, %s! %s must have really hurt her!",
			ROBOT = "Oh no, %s! %s must have really hurt them!",
			DEFAULT = "Oh no, %s! %s must have really hurt them!",
		},

		SKULLCHEST = "Who knows what could be hiding in there!",
		SMALLBIRD =
		{
			GENERIC = "Could this be a friend for us?",
			HUNGRY = "I can see its tummy rumble.",
			STARVING = "Poor thing. It looks so hungry!",
		},
		SMALLMEAT = "A couple more'll make a morsel meal!",
		SMALLMEAT_DRIED = "It'll keep longer this way.",
		SPEAR = "We should stick things with the pointy part.",
		SPIDER =
		{
			DEAD = "Another lost friend.",
			GENERIC = "Spiders understand us.",
            SLEEPING = "Aww! I think it's having a dream.",
		},
		SPIDERDEN = "Looks cozy in there.",
		SPIDEREGGSACK = "A portable friendship pod!",
		SPIDERGLAND = "I won't think about where it came from.",
		SPIDERHAT = "Very upsetting...",
		SPIDERQUEEN = "Mommy-Longlegs?",
		SPIDER_WARRIOR =
		{
			GENERIC = "He will protect us!",
			SLEEPING = "They're so cute when they sleep.",
			DEAD = "Forgive us, brother.",
		},
		SPOILED_FOOD = "Blech!",
        STAGEHAND =
        {
			AWAKE = "Definitely not a spider!",
			HIDING = "Is there a spider friend rustling beneath?",
        },
        STATUE_MARBLE = 
        {
            GENERIC = "Solid marble!",
            TYPE1 = "Nice sword!",
            TYPE2 = "It looks real lifelike, but it's all cold to touch.",
        },
		STATUEHARP = "Someone took the head.",
		STATUEMAXWELL = "We're still a little mad at him. But only a little.",
		STINGER = "We should be careful, we could poke an eye out!",
		STRAWHAT = "Keeps the sun out of all eight of your eyes.",
		STUFFEDEGGPLANT = "We will stuff ourself with eggyplants!",
		SWEATERVEST = "It itches and fits funny.",
		REFLECTIVEVEST = "Safety first!",
		HAWAIIANSHIRT = "Grandpa's style, definitely.",
		TAFFY = "Candy!",
		TALLBIRD = "Look at those legs!",
		TALLBIRDEGG = "Did I hear a meep?",
		TALLBIRDEGG_COOKED = "Smells great!",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "It's shivering!",
			GENERIC = "I think it's hatching!",
			HOT = "It'll boil if it doesn't cool down soon.",
			LONG = "Looks like an egg.",
			SHORT = "Did that egg just move?",
		},
		TALLBIRDNEST =
		{
			GENERIC = "This could feed us for days!",
			PICKED = "Where is the egg?",
		},
		TEENBIRD =
		{
			GENERIC = "It's getting old so fast!",
			HUNGRY = "It looks hungry!",
			STARVING = "I think it's starving!",
		},
		TELEBASE =
		{
			VALID = "Seems ready to use.",
			GEMS = "It needs something to focus the power.",
		},
		GEMSOCKET = 
		{
			VALID = "Looks good.",
			GEMS = "Looks empty.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "We could use this to visit new worlds!",
			GENERIC = "I can hear the sounds of another world!",
			LOCKED = "It still won't work!",
			PARTIAL = "I don't think we're done yet!",
		},
		TELEPORTATO_BOX = "The power in this box is unimaginable.",
		TELEPORTATO_CRANK = "A crank that will stand up to punishment.",
		TELEPORTATO_POTATO = "It looks like this goes with something...",
		TELEPORTATO_RING = "I think there are more parts.",
		TELESTAFF = "Just looking at it makes my brain feel fuzzy.",
		TENT = 
		{
			GENERIC = "It's way past our bedtime!",
			BURNT = "The fire destroyed it.",
		},
		SIESTAHUT = 
		{
			GENERIC = "Is it nap time?",
			BURNT = "We can't take a nap in that!",
		},
		TENTACLE = "We would be mad if something stepped on us, too.",
		TENTACLESPIKE = "We could hit stuff with the pointy bits!",
		TENTACLESPOTS = "Spotty!",
		TENTACLE_PILLAR = "It's huge!",
        TENTACLE_PILLAR_HOLE = "Oooh let's jump in!",
		TENTACLE_PILLAR_ARM = "Aw, it's just a baby!",
		TENTACLE_GARDEN = "It's huge!",
		TOPHAT = "Like father used to wear.",
		TORCH = "This should keep us safe.",
		TRANSISTOR = "A very well crafted doodad!",
		TRAP = "Now we can catch some food!",
		TRAP_TEETH = "This will hurt our enemies.",
		TRAP_TEETH_MAXWELL = "Who would put this here? We could get hurt!",
		TREASURECHEST = 
		{
			GENERIC = "We could keep our toys in it!",
			BURNT = "It won't be very useful to us now.",
		},
		SACRED_CHEST = 
		{
			GENERIC = "We feel cold.",
			LOCKED = "It's judging us.",
		},
		TRINKET_1 = "We could still play with these, if we're extra creative.", --Melted Marbles
		TRINKET_2 = "A voiceless instrument.", --Fake Kazoo
		TRINKET_3 = "It won't come undone!", --Gord's Knot
		TRINKET_4 = "It's watching us.", --Gnome
		TRINKET_5 = "Yay, a new toy!", --Toy Rocketship
		TRINKET_6 = "Maybe we'll find a use for these.", --Frazzled Wires
		TRINKET_7 = "Another toy!", --Ball and Cup
		TRINKET_8 = "I miss bath toys.", --Rubber Bung
		TRINKET_9 = "None of them match!", --Mismatched Buttons
		TRINKET_10 = "Just like grandpa wears!", --Dentures
		TRINKET_11 = "Beep boop!", --Lying Robot
		TRINKET_12 = "Feels leathery.", --Dessicated Tentacle
		TRINKET_13 = "It's watching us.", --Gnomette
        TRINKET_14 = "We want some hot cocoa.", --Leaky Teacup
        TRINKET_15 = "We don't know how to play this game.", --Pawn
        TRINKET_16 = "We don't know how to play this game.", --Pawn
        TRINKET_17 = "Spork. Spork. Spork. Hahaha!", --Bent Spork
        TRINKET_18 = "We like toys.", --Trojan Horse
        TRINKET_19 = "This toy doesn't work very well.", --Unbalanced Top
        TRINKET_20 = "Can we dig in the dirt with this?", --Backscratcher
        TRINKET_21 = "Mom had one of these.", --Egg Beater
        TRINKET_22 = "It's kinda like our webbing!", --Frayed String
        TRINKET_23 = "Are we supposed to blow on it?",
        TRINKET_24 = "No cookies. Yet!", --Lucky Cat Jar
        TRINKET_25 = "It's stinky.", --Air Unfreshener
		TRINKET_26 = "You're our cuppy cup!", --Potato Cup
		TRINKET_27 = "This is stupid.", --Coat Hanger
		TRINKET_28 = "Maybe Maxwell will teach us how to play.", --Knight
        TRINKET_29 = "Maybe Maxwell will teach us how to play.", --Knight
        TRINKET_30 = "We can't follow the rules if we don't know them.", --Rook
        TRINKET_31 = "We can't follow the rules if we don't know them.", --Rook
        TRINKET_32 = "It's not bouncy. What's the point?", --Cubic Zirconia Ball
        TRINKET_33 = "It's a friend for our finger!!", --Spider Ring
        TRINKET_34 = "The monkey probably needed that.", --Monkey Paw
        TRINKET_35 = "I kinda wanna drink what's left, but he won't let me.", --Empty Elixir
        TRINKET_36 = "We've already got some, thanks.", --Faux Fangs
        TRINKET_37 = "Maybe we should hide this before someone gets hurt.", --Broken Stake
        TRINKET_38 = "Haha! Everything looks so small!", -- Binoculars Griftlands trinket
        TRINKET_39 = "That's boring.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Haha, it looks like a snail shell.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Haha! Weird!", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Neat!!", -- Toy Cobra Hot Lava trinket
        TRINKET_43 = "C'mon little croc! Let's adventure!", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "The plant is so pretty!", -- Broken Terrarium ONI trinket
        TRINKET_45 = "It doesn't get any good channels.", -- Odd Radio ONI trinket
        TRINKET_46 = "What's it for?", -- Hairdryer ONI trinket

        HALLOWEENCANDY_1 = "Oh, Wendy! We'll trade you for your choco pigs!", --Candy Apple
        HALLOWEENCANDY_2 = "Haha ew! It's weird!", --Candy Corn
        HALLOWEENCANDY_3 = "Haha, that's not candy!", --Not-So-Candy Corn
        HALLOWEENCANDY_4 = "We aren't totally comfortable with this.", --Gummy Spider
        HALLOWEENCANDY_5 = "We forgot what good things tasted like!", --Catcoon Candy
        HALLOWEENCANDY_6 = "No worse than the other stuff we've eaten out here!", --"Raisins"
        HALLOWEENCANDY_7 = "Oh, Ms. Wicker! We saved these for you!", --Raisins
        HALLOWEENCANDY_8 = "Candy candy candy!", --Ghost Pop
        HALLOWEENCANDY_9 = "Gummy worms, yummy worms!", --Jelly Worm
        HALLOWEENCANDY_10 = "Candy candy candy!", --Tentacle Lolli
        HALLOWEENCANDY_11 = "Mmm! Sweet revenge!", --Choco Pigs
        HALLOWEENCANDY_12 = "Wriggly, yet satisfying.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "We like these a lot.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Gosh, it's spicy.", --Hot Lava pepper candy
        CANDYBAG = "Treats, treats, treats!",

        HALLOWEEN_ORNAMENT_1 = "Oooh. Spooky. We should decorate!",
		HALLOWEEN_ORNAMENT_2 = "Gosh. That almost looks real.",
		HALLOWEEN_ORNAMENT_3 = "Aw. It's not real. Let's hang it somewhere.",
		HALLOWEEN_ORNAMENT_4 = "Let's hang it somewhere for Halloween!",
		HALLOWEEN_ORNAMENT_5 = "We should put this guy in a tree!",
		HALLOWEEN_ORNAMENT_6 = "If we put it in a tree it'd look almost real.",

		HALLOWEENPOTION_DRINKS_WEAK = "It's only a little powerful.",
		HALLOWEENPOTION_DRINKS_POTENT = "It's pretty powerful.",
		HALLOWEENPOTION_FIRE_FX = "Neat! It's like firecrackers.",
		HALLOWEENPOTION_BRAVERY = "Makes us feel big and strong!",
		MADSCIENCE_LAB = "Wow. Look at it bubble.",
		LIVINGTREE_ROOT = "We should plant this somewhere.",
		LIVINGTREE_SAPLING = "It's a monster kid. Like me!",

        DRAGONHEADHAT = "The front part's sort of scary.",
        DRAGONBODYHAT = "I'm not sure I want to be in *another* belly.",
        DRAGONTAILHAT = "We like the tail!",
        PERDSHRINE =
        {
            GENERIC = "We wanna give it something!",
            EMPTY = "The pot's empty.",
            BURNT = "The fire destroyed it.",
        },
        REDLANTERN = "Our own personal night light!",
        LUCKY_GOLDNUGGET = "So shiny!",
        FIRECRACKERS = "Don't worry Ms. Wicker, we'll be careful.",
        PERDFAN = "It's so big!!",
        REDPOUCH = "We're so lucky!",
        WARGSHRINE = 
        {
            GENERIC = "It wants to give us presents!",
            EMPTY = "Let's put the torch in!",
            BURNT = "The fire destroyed it.",
        },
        CLAYWARG = 
        {
        	GENERIC = "N-nice puppy!",
        	STATUE = "It's got no eyes. Creepy!",
        },
        CLAYHOUND = 
        {
        	GENERIC = "Sit! Stay?",
        	STATUE = "It looks like a big puppy.",
        },
        HOUNDWHISTLE = "Our head buzzes when we blow it.",
        CHESSPIECE_CLAYHOUND = "Puppy!",
        CHESSPIECE_CLAYWARG = "That's a big, bad dog.",

        PIGSHRINE =
		{
            GENERIC = "We can make some fun stuff now!",
            EMPTY = "We should find some meat for it.",
            BURNT = "Aww... that's too bad.",
		},
		PIG_TOKEN = "Neat! The Pig King would like that.",
		YOTP_FOOD1 = "Yummy!",
		YOTP_FOOD2 = "Mmmmmm.",
		YOTP_FOOD3 = "Smells good.",

		PIGELITE1 = "Cool tattoos!", --BLUE
		PIGELITE2 = "Yikes! He's angry.", --RED
		PIGELITE3 = "Leave us alone!", --WHITE
		PIGELITE4 = "Wish he wouldn't hit us so much.", --GREEN

		TRUNKVEST_SUMMER = "It's so puffy!",
		TRUNKVEST_WINTER = "You're always supposed to wear a jacket!",
		TRUNK_COOKED = "Looks filling!",
		TRUNK_SUMMER = "We took his nose!",
		TRUNK_WINTER = "He blue his nose.",
		TUMBLEWEED = "Who knows what that tumbleweed has picked up.",
		TURF_CARPETFLOOR = "Carpets! Just like in our old house.",
		TURF_CHECKERFLOOR = "Fancy.",
		TURF_DIRT = "Some ground that we dug up.",
		TURF_FOREST = "Some ground that we dug up.",
		TURF_GRASS = "Some ground that we dug up.",
		TURF_MARSH = "Some ground that we dug up.",
		TURF_ROAD = "Some ground that we dug up.",
		TURF_ROCKY = "Some ground that we dug up.",
		TURF_SAVANNA = "Some grassy dirt.",
		TURF_DRAGONFLY = "Warm and cozy ground!",
		TURF_BADLANDS = "Some ground that we dug up.",
		TURF_DECIDUOUS = "Some ground that we dug up.",
		TURF_DESERTDIRT = "Some ground that we dug up.",
		TURF_FUNGUS_GREEN = "Some ground that we dug up.",
		TURF_FUNGUS_RED = "Some ground that we dug up.",
		TURF_SANDY = "Some ground that we dug up.",
		
		SHADOWDIGGER = "Sometimes scary things are nice.",

		BISHOP_CHARGE_HIT = "Owie!",
		TURF_WOODFLOOR = "If we put these on the ground we'll have a floor!",
		TURKEYDINNER = "Like mother used to make, in the before time!",
		TWIGS = "Does anyone want to play stick swords with us??",
		INSPECTSELF = "Ah! I'm a monster! Haha, we're just kidding.",
		TWIGGYTREE = 
        {
            BURNING = "What a senseless waste of firewood.",
			BURNT = "Only we can prevent forest fires.",
			CHOPPED = "Would a cool bandage make you feel better, Mr. Tree?",
            GENERIC = "We want to climb it!",           
            DISEASED = "Maybe it needs some chicken soup?",
        },
        TWIGGY_NUT_SAPLING = "Little tree!",
        TWIGGY_OLD = "It's too flimsy to climb.",
        TWIGGY_NUT = "The tree wants to come out and play!",
		STEELWOOL = "Scratchy, like father's beard!",
		SPAT = "Maybe it just needs a cuddle!",
		UMBRELLA = "Should keep some of the rain out.",
		GRASS_UMBRELLA = "Rain won't keep us from playing in puddles!",
		UNIMPLEMENTED = "What a crummy item.",
		WAFFLES = "Yummy!",
		WALL_HAY = 
		{	
			GENERIC = "This will keep all sorts of things out!",
			BURNT = "It didn't keep the fire out.",
		},
		WALL_HAY_ITEM = "Some grass tied together.",
		WALL_STONE = "Bow to the base-building masters!",
		WALL_STONE_ITEM = "These should come in handy.",
		WALL_RUINS = "Looks sturdy.",
		WALL_RUINS_ITEM = "Wow, these are really heavy.",
		WALL_WOOD = 
		{
			GENERIC = "Like a pillow fort, but wood!",
			BURNT = "Turns out wood burns really well.",
		},
		WALL_WOOD_ITEM = "They won't keep us safe if we keep holding them.",
		WALL_MOONROCK = "We feel safe behind this wall... it makes us sleepy...",
		WALL_MOONROCK_ITEM = "We thought \"moon\" meant something totally different!",
		FENCE = "I don't think we can jump over that.",
        FENCE_ITEM = "Let's build a fence!",
        FENCE_GATE = "The hinges are a little squeaky.",
        FENCE_GATE_ITEM = "Let's build a gate!",
		WALRUS = "I don't think he wants to be friends with us.",
		WALRUSHAT = "Reminds me of grandpa.",
		WALRUS_CAMP =
		{
			EMPTY = "I think someone was here.",
			GENERIC = "Maybe they'll invite us in?",
		},
		WALRUS_TUSK = "Maybe we can use it for arts and crafts.",
		WARDROBE = 
		{
			GENERIC = "We like to pop out and scare our friends sometimes. Haha!",
            BURNING = "Fire fire fire!",
			BURNT = "We can't hide in there any more.",
		},
		WARG = "I don't think that puppy is very happy.",
		WASPHIVE = "Sounds like anger!",
		WATERBALLOON = "We have to be gentle with our claws if we try to hold it!",
		WATERMELON = "Looks tasty!",
		WATERMELON_COOKED = "Anything can be cooked!",
		WATERMELONHAT = "This is the best idea anyone's ever had.",
		WETGOOP = "Experimenting is fun!",
        WHIP = "Oooh, it makes so much noise!",
		WINTERHAT = "Mum always said I should take a cap with me.",
		WINTEROMETER = 
		{
			GENERIC = "How hot is it, Mr. Thermal Measurer?",
			BURNT = "How come everything turns to ashes? It's sad.",
		},

        WINTER_TREE =
        {
            BURNT = "Aw... Why...",
            BURNING = "Nooo! The tree!",
            CANDECORATE = "Winter's Feast! It's Winter's Feast!",
            YOUNG = "It still needs to grow some more.",
        },
		WINTER_TREESTAND = 
		{
			GENERIC = "It's just a boring planter without a tree.",
            BURNT = "Aw... Why...",
		},
        WINTER_ORNAMENT = "Can we get a boost? We can't reach the treetop.",
        WINTER_ORNAMENTLIGHT = "We want to keep one for ourselves.",
        WINTER_ORNAMENTBOSS = "Wow, that one looks great!",
        WINTER_ORNAMENTFORGE = "Not so scary when they're like this.",
		WINTER_ORNAMENTGORGE = "Huh. It kinda looks...goaty!",

        WINTER_FOOD1 = "I won't eat it. It's our friend now.", --gingerbread cookie
        WINTER_FOOD2 = "Icy icy icing!", --sugar cookie
        WINTER_FOOD3 = "Eat twenty candy canes! There's no candy shame!", --candy cane
        WINTER_FOOD4 = "Yuck! What is that??", --fruitcake
        WINTER_FOOD5 = "Haha, Wendy! Watch our Woodie impression!", --yule log cake
        WINTER_FOOD6 = "Where are the plums?", --plum pudding
        WINTER_FOOD7 = "Apple juice?! Yes!!", --apple cider
        WINTER_FOOD8 = "It makes our claws and tummy so warm.", --hot cocoa
        WINTER_FOOD9 = "It's really, really good!", --eggnog

        KLAUS = "That meanie imprisoned those deer!",
        KLAUS_SACK = "Presents?!",
		WORMHOLE =
		{
			GENERIC = "I think that thing is alive.",
			OPEN = "I've been in worse.",
		},
		WORMHOLE_LIMITED = "Gross, that one looks sick!",
		ACCOMPLISHMENT_SHRINE = "It gives me a goal in life.",        
		LIVINGTREE = "Hello, Mr. Tree!",
		ICESTAFF = "It makes me feel funny.",
        REVIVER = "I think it loves me.",
        SHADOWHEART = "Why does it make me feel so bad?",
        ATRIUM_RUBBLE = 
        {
			LINE_1 = "It's a picture of some bug people.",
			LINE_2 = "This picture's all messed up.",
			LINE_3 = "There's a lot of black goop in this picture.",
			LINE_4 = "A picture of bug people escaping their bug outsides!",
			LINE_5 = "A picture of a city. It looks like a nice place to live.",
		},
        ATRIUM_STATUE = "They look sick.",
        ATRIUM_LIGHT = 
        {
			ON = "We don't like it.",
			OFF = "No light.",
		},
        ATRIUM_GATE =
        {
			ON = "Does this mean we get to go home?",
			OFF = "We need another piece to turn it on.",
			CHARGING = "What's it doing?",
            DESTABILIZING = "It looks like it's gonna blow up!",
            COOLDOWN = "It wasn't a way home, anyway.",
        },
        ATRIUM_KEY = "This key is REALLY old.",
        LIFEINJECTOR = "I hate taking my medicine!",

        --Arena Event
        LAVAARENA_BOARLORD = "Maybe he's nice?",
        BOARRIOR = "You don't look so tough!",
        BOARON = "Leave us alone!",
        PEGHOOK = "Wouldn't you rather be bug friends with us?",
        TRAILS = "No monkey business, mister!",
        TURTILLUS = "That turtle's huge!",
        SNAPPER = "Don't bite us!",
        RHINODRILL = "Looks like a big bully!",
		BEETLETAUR = "All that armor must be heavy.",
        
        LAVAARENA_PORTAL = 
        {
            ON = "Time to go... \"home\".",
            GENERIC = "This isn't home!",
        },
        LAVAARENA_KEYHOLE = "It doesn't have its key.",
        LAVAARENA_KEYHOLE_FULL = "That looks much better!",
        LAVAARENA_BATTLESTANDARD = "Hey, help me break this Battle Standard!",
        LAVAARENA_SPAWNER = "That's the bad guy portal!",

        HEALINGSTAFF = "That uses magic to hurt people.",
        FIREBALLSTAFF = "It hurts people with magic.",
        HAMMER_MJOLNIR = "We're not strong enough to use it.",
        SPEAR_GUNGNIR = "Wigfrid makes it look so cool!",
        BLOWDART_LAVA = "We like fighting from far away.",
        BLOWDART_LAVA2 = "Those look like fun!",
        LAVAARENA_LUCY = "You look different, Lucy. Did you get a haircut?",
        WEBBER_SPIDER_MINION = "We'll protect each other, spider babies!",
        BOOK_FOSSIL = "We can read the words but we can't make them work.",
		LAVAARENA_BERNIE = "Oh! Willow brought Bernie!",
		SPEAR_LANCE = "I don't really want it.",
		BOOK_ELEMENTAL = "Are those even words in there?",
		LAVAARENA_ELEMENTAL = "Hey hi, rock-person!",

        LAVAARENA_ARMORLIGHT = "Uhh, I don't think that's very safe.",
		LAVAARENA_ARMORLIGHTSPEED = "We'd skitter really fast with that.",
		LAVAARENA_ARMORMEDIUM = "Safety first!",
		LAVAARENA_ARMORMEDIUMDAMAGER = "We like this armor a lot.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "This armor seems pretty good!",
		LAVAARENA_ARMORHEAVY = "We'll be an impervious spider!",
		LAVAARENA_ARMOREXTRAHEAVY = "Maybe we should let someone tougher have it.",

		LAVAARENA_FEATHERCROWNHAT = "That might make us scuttle faster.",
        LAVAARENA_HEALINGFLOWERHAT = "It makes your day a little brighter.",
        LAVAARENA_LIGHTDAMAGERHAT = "That looks like it was made for spiders.",
        LAVAARENA_STRONGDAMAGERHAT = "We like that hat!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "I don't think we should wear that.",
        LAVAARENA_EYECIRCLETHAT = "It looks neat, but we don't want it.",
        LAVAARENA_RECHARGERHAT = "It sure is sparkly.",
        LAVAARENA_HEALINGGARLANDHAT = "It makes you feel a little better when you wear it.",
        LAVAARENA_CROWNDAMAGERHAT = "That helmet is really something!",

        LAVAARENA_ARMOR_HP = "We should armor up to be safe.",

		LAVAARENA_FIREBOMB = "It's like fiery spit balls.",
		LAVAARENA_HEAVYBLADE = "That sword is too big for us to carry!",

        --Quagmire
        QUAGMIRE_ALTAR = 
        {
        	GENERIC = "I think it's hungry.",
        	FULL = "We hope it's good.",
        },
		QUAGMIRE_ALTAR_STATUE1 = "It looks like the friendly goat we met.",
		QUAGMIRE_PARK_FOUNTAIN = "No coins in it. I guess no one made wishes.",
		--
        QUAGMIRE_HOE = "I know how to use this!",
        --
        QUAGMIRE_TURNIP = "Wow! It's a turnip!",
        QUAGMIRE_TURNIP_COOKED = "We cooked the turnip.",
        QUAGMIRE_TURNIP_SEEDS = "We can find out what they are by planting them.",
        --
        QUAGMIRE_GARLIC = "Maxwell says you ward monsters away with it.",
        QUAGMIRE_GARLIC_COOKED = "It didn't ward us off!",
        QUAGMIRE_GARLIC_SEEDS = "We can find out what they are by planting them.",
        --
        QUAGMIRE_ONION = "It makes all our eyes water!",
        QUAGMIRE_ONION_COOKED = "Our eyes don't water any more.",
        QUAGMIRE_ONION_SEEDS = "We can find out what they are by planting them.",
        --
        QUAGMIRE_POTATO = "Woah! A potato!",
        QUAGMIRE_POTATO_COOKED = "It's a cooked potato now.",
        QUAGMIRE_POTATO_SEEDS = "We can find out what they are by planting them.",
        --
        QUAGMIRE_TOMATO = "Is it a fruit or a vegetable?",
        QUAGMIRE_TOMATO_COOKED = "It's a cooked fregetable. Vruit?",
        QUAGMIRE_TOMATO_SEEDS = "We can find out what they are by planting them.",
        --
        QUAGMIRE_FLOUR = "It's no good by itself.",
        QUAGMIRE_WHEAT = "If only I were back at the mill.",
        QUAGMIRE_WHEAT_SEEDS = "We can find out what they are by planting them.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "We can find out what they are by planting them.",
        --
        QUAGMIRE_ROTTEN_CROP = "That one got a bit squishy.",
        --
		QUAGMIRE_SALMON = "Mom said fish oil is good for our brain.",
		QUAGMIRE_SALMON_COOKED = "Smells good!",
		QUAGMIRE_CRABMEAT = "Crabs kinda look like spiders.",
		QUAGMIRE_CRABMEAT_COOKED = "We don't want to eat it.",
        QUAGMIRE_POT = "This pot's a bit bigger than the other one.",
        QUAGMIRE_POT_SMALL = "You cook stuff in it.",
        QUAGMIRE_POT_HANGER_ITEM = "We should put it together.",
        QUAGMIRE_OVEN_ITEM = "We gotta set this up.",
        QUAGMIRE_OVEN = "Mom said I should be careful around the oven.",
		QUAGMIRE_SUGARWOODTREE = 
		{
			GENERIC = "I wonder why the people left this nice place.",
			STUMP = "Why would anyone do that?",
			TAPPED_EMPTY = "There isn't any sap yet.",
			TAPPED_READY = "Sticky, sticky sap!",
			TAPPED_BUGS = "Ew... The bugs got in it.",
			WOUNDED = "Aw, now it's not as pink.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB = 
		{
			GENERIC = "What a cool purple shrub.",
			PICKED = "All the good stuff's gone.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "It doesn't taste very good on its own.",
		QUAGMIRE_SPOTSPICE_GROUND = "We ground it all up.",
		QUAGMIRE_SAPBUCKET = "It's a big ol'bucket.",
		QUAGMIRE_SAP = "Sticky, gooey sap.",
		
		QUAGMIRE_SALT_RACK =
		{
			READY = "Salt's ready.",
			GENERIC = "We have to wait for more salt.",
		},

		QUAGMIRE_SALT_RACK_ITEM = "We should set it up at the crusty pond.",

		QUAGMIRE_SAFE = 
		{
			GENERIC = "Well, it wouldn't hurt to take a look.",
			LOCKED = "Someone's precious things are probably inside.",
		},

		QUAGMIRE_KEY = "Cool! I wonder what it unlocks?",
		QUAGMIRE_KEY_PARK = "We wanna go to the park.",
        QUAGMIRE_PORTAL_KEY = "I wonder where this takes us.",

		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Those mushrooms are tiny.",
			PICKED = "No more little mushrooms.",
		},

		QUAGMIRE_MUSHROOMS = "I don't like mushrooms.",
        QUAGMIRE_MEALINGSTONE = "We want to do the grinding!",

		QUAGMIRE_PEBBLECRAB = "Don't be afraid!",

		QUAGMIRE_POND_SALT = "It's all crusty around the edges.",
		--
		QUAGMIRE_RUBBLE_CARRIAGE = "I wish we could ride in that.",
        QUAGMIRE_RUBBLE_CLOCK = "Does it still tell the right time?",
        QUAGMIRE_RUBBLE_CATHEDRAL = "We can't even fix it.",
        QUAGMIRE_RUBBLE_PUBDOOR = "It doesn't lead anywhere anymore.",
        QUAGMIRE_RUBBLE_ROOF = "Too bad.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "I don't think that clock works anymore.",
        QUAGMIRE_RUBBLE_BIKE = "Aww... It's broken.",
        QUAGMIRE_RUBBLE_HOUSE = {"Where did everyone go?", "I wonder what happened here?", "Looks like everyone left.",},
        QUAGMIRE_RUBBLE_CHIMNEY = "Bummer.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Aw. That's too bad.",
        QUAGMIRE_MERMHOUSE = "It doesn't look very cozy.",
        QUAGMIRE_SWAMPIG_HOUSE = "I've never seen their houses up close!",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "No one lives in it anymore.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Hi, Mr. Pig!",
            SLEEPING = "It's sleeping.",
        },
        QUAGMIRE_SWAMPIG = "They're not afraid of us!!",
        --
        QUAGMIRE_PORTAL = "At least it took us somewhere different.",
        QUAGMIRE_SALTROCK = "We're gonna crunch them all up.",
        QUAGMIRE_SALT = "We don't use a lot of salt on our food.",
        --food--
        QUAGMIRE_FOOD_BURNT = "It's okay. The next one will be better.",
        --QUAGMIRE_FOOD_PLATE = "We know how to dish it out!",
       	--QUAGMIRE_FOOD_SOUP = "Nice and warm.",
        --QUAGMIRE_FOOD_SNACK = "Just a little snack.",
        --QUAGMIRE_FOOD_BREAD = "Yay! Bread!",
        --QUAGMIRE_FOOD_PASTA = "Pass the pasta!",
        --QUAGMIRE_FOOD_VEGGIE = "Mom said we should always eat our vegetables.",
        --QUAGMIRE_FOOD_MEAT = "Mmmm...I'm hungry.",
        --QUAGMIRE_FOOD_FISH = "Still smells a little.",
        --QUAGMIRE_FOOD_CRAB = "I bet this tastes great.",
        --QUAGMIRE_FOOD_CHEESE = "Cheese is good for the bones.",
        --QUAGMIRE_FOOD_SWEET = "Sweet!",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "We can put it on the altar now.",
            MISMATCH = "We think the Gnaw wants something different.",
            MATCH = "The goat lady said this was what the Gnaw wanted.",
            MATCH_BUT_SNACK = "This is what it wants, but it's kinda puny.",
        },
        --
        QUAGMIRE_COIN1 = "We could trade it for something small.",
        QUAGMIRE_COIN2 = "I wonder what we can buy with this.",
        QUAGMIRE_COIN3 = "We can buy a whole bunch of stuff with this.",
        QUAGMIRE_COIN4 = "The nice lady said we need three of them.",
        QUAGMIRE_GOATMILK = "Milk is good for our bones. Endo and exo!",
        QUAGMIRE_SYRUP = "Sweet!",
        QUAGMIRE_SAP_SPOILED = "Aw... It's no good anymore.",
        QUAGMIRE_SEEDPACKET = "We can plant a whole bunch of food with this.",
        --QUAGMIRE_SEEDPACKET_SMALL = "These will grow a little bit of food.",
        --QUAGMIRE_SEEDPACKET_MEDIUM = "These seeds are a good start.",
        --QUAGMIRE_SEEDPACKET_LARGE = "We can plant a whole bunch of food with this.",
        --QUAGMIRE_SEEDPACKET_MIX_SMALL = "Wow. There's a few different seeds in here.",
        --QUAGMIRE_SEEDPACKET_MIX_MEDIUM = "We can grow a bunch of things from these seeds.",
        --QUAGMIRE_SEEDPACKET_MIX_LARGE = "Wow. A big mix of different food to plant.",
        ---
        QUAGMIRE_POT = "This pot's a bit bigger than the other one.",
        QUAGMIRE_POT_SMALL = "You cook stuff in it.",
        QUAGMIRE_POT_SYRUP = "Sweet pot!",
        QUAGMIRE_POT_HANGER = "We can hang a pot off this.",
        QUAGMIRE_POT_HANGER_ITEM = "We should put it together.",
        QUAGMIRE_GRILL = "We have to be careful when we cook.",
        QUAGMIRE_GRILL_ITEM = "We could use it to make yummy food.",
        QUAGMIRE_GRILL_SMALL = "What should we cook?",
        QUAGMIRE_GRILL_SMALL_ITEM = "Let's find a place to put it.",
        QUAGMIRE_OVEN = "Mom said I should be careful around the oven.",
        QUAGMIRE_OVEN_ITEM = "We gotta set this up.",
        QUAGMIRE_CASSEROLEDISH = "We can cooks stuff in it.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "It's kinda small.",
        QUAGMIRE_PLATE_SILVER = "Now we don't have to eat off the floor.",
        QUAGMIRE_BOWL_SILVER = "Now we have somewhere to put food.",
        ---
        QUAGMIRE_MERM_CART1 = "Do they have any toys?", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "That's full of good stuff.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "I think it's sort of pretty.",
        QUAGMIRE_PARK_ANGEL2 = "It almost looks real.",
        QUAGMIRE_PARK_URN = "Aw. Someone died.",
        QUAGMIRE_PARK_OBELISK = "It's a monument or something.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Park. Park. Park!",
            LOCKED = "It's locked. I think we need a key.",
        },
        QUAGMIRE_PARKSPIKE = "It looks sharp.",
        QUAGMIRE_CRABTRAP = "We can trap little crabs in this.",
        QUAGMIRE_TRADER_MERM = "Hi there! Wanna trade?",
        QUAGMIRE_TRADER_MERM2 = "Hey. You look nice.",
        QUAGMIRE_FERN = "Maybe we could make a salad.",
        QUAGMIRE_FOLIAGE_COOKED = "This probably doesn't count as a salad, huh.",
        --
        QUAGMIRE_GOATMUM = "Does your kid want to play?",
        QUAGMIRE_GOATKID = "Hi! I'm Webber!",
        QUAGMIRE_PIGEON =
        {
            DEAD = "It's not moving.",
            GENERIC = "I should leave it alone.",
            SLEEPING = "It's sleeping.",
        },
        QUAGMIRE_LAMP_POST = "It's the kind of lamp they have in the city.",

        QUAGMIRE_BEEFALO = "Take it easy, grandpa.",
        QUAGMIRE_SLAUGHTERTOOL = "I don't wanna use this.",

        QUAGMIRE_SAPLING = "It's gonna take too long to grow back.",
        QUAGMIRE_BERRYBUSH = "Aww... all the berries are gone now.",

        QUAGMIRE_ALTAR_STATUE2 = "A lotta goat statues around here.",
        QUAGMIRE_ALTAR_QUEEN = "Wow. She looks beautiful.",
        QUAGMIRE_ALTAR_BOLLARD = "It's nice enough.",
        QUAGMIRE_ALTAR_IVY = "Ivy grows everywhere.",

        QUAGMIRE_LAMP_SHORT = "We're almost as tall as this lamp.",

        --v2 Winona
        WINONA_CATAPULT =
        {
            GENERIC = "We feel safer already!",
            OFF = "How come it's not on?",
            BURNING = "Oh, oh!",
            BURNT = "Oh no! It got burnt!",
        },
        WINONA_SPOTLIGHT =
        {
            GENERIC = "She made us a nightlight!",
            OFF = "How come it's not on?",
            BURNING = "Oh, oh!",
            BURNT = "Oh no! It got burnt!",
        },
        WINONA_BATTERY_LOW =
        {
            GENERIC = "It feeds hungry machines.",
            LOWPOWER = "We think it's running low.",
            OFF = "Hey Winona! How do we fix it?",
            BURNING = "Oh, oh!",
            BURNT = "Oh no! It got burnt!",
        },
        WINONA_BATTERY_HIGH =
        {
            GENERIC = "Machines think gem power is really tasty.",
            LOWPOWER = "We think it's running low.",
            OFF = "Winoooona! The thing broke!",
            BURNING = "Oh, oh!",
            BURNT = "Oh no! It got burnt!",
        },

        --Wormwood
        COMPOSTWRAP = "Double doodoo.",
        ARMOR_BRAMBLE = "We're ready to let spikes fly!",
        TRAP_BRAMBLE = "It's a very pointy planty trap!",
    },
    DESCRIBE_GENERIC = "Can we play with it?",
    DESCRIBE_TOODARK = "All our eyes stopped working!",
    DESCRIBE_SMOLDERING = "Uh-oh. I smell burning!",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "What if it hatches in our belly?",
    },
}
