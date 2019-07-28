return {

	ACTIONFAIL = 
	{
		ACTIVATE = 
		{
			LOCKED_GATE = "I'll need a key to get through.",
		},
		ATTUNE = 
		{
			NOHEALTH = "I would seriously hurt myself if I did.",
		},
		BUILD = 
		{
			HASPET = "I already have a little companion.",
			MOUNTED = "Mon dieu, that's far away.",
		},
		CHANGEIN = 
		{
			BURNING = "It, oh, it appears to be on fire.",
			GENERIC = "I guess it never occurred to me I'd need to change.",
			INUSE = "I should give them their privacy.",
		},
		CONSTRUCT = 
		{
			EMPTY = "I'm missing some ingredients.",
			INUSE = "Pardonnez-moi! Someone's already doing that.",
			MISMATCH = "I think I've gotten something mixed up.",
			NOTALLOWED = "This isn't the best place for it.",
		},
		COOK = 
		{
			GENERIC = "I'm not quite ready yet.",
			INUSE = "Pardonnez-moi! I shouldn't backseat cook.",
			TOOFAR = "I'll need to get a little closer to cook with that.",
		},
		DRAW = 
		{
			NOIMAGE = "What should I draw?",
		},
		GIVE = 
		{
			ABIGAILHEART = "Apologies, ma petite choux-fleur.",
			BUSY = "Pardonnez-moi, they seem busy right now.",
			CANTSHADOWREVIVE = "It doesn't seem to be working.",
			DEAD = "Oh dear...",
			DUPLICATE = "We've learned that already.",
			FOODFULL = "Let them enjoy their meal first.",
			GENERIC = "Non.",
			GHOSTHEART = "I don't think they would appreciate it.",
			MUSHROOMFARM_NEEDSLOG = "It needs a dash of something else.",
			MUSHROOMFARM_NEEDSSHROOM = "It needs a dash of something else.",
			NOMOON = "I imagine I'll need to see the moon for this.",
			NOTATRIUMKEY = "It's not quite right.",
			NOTDISH = "It would tarnish my reputation to serve that.",
			NOTGEM = "Hmm... Non.",
			NOTSCULPTABLE = "That doesn't seem right.",
			NOTSTAFF = "I need something long and thin, like a wooden spoon.",
			PIGKINGGAME_DANGER = "It wouldn't be safe right now.",
			PIGKINGGAME_MESSY = "We should sort out this mess first.",
			PIGKINGGAME_TOOLATE = "It's a bit late in the evening for that.",
			SLEEPING = "It's sleeping.",
			SLOTFULL = "I'd have to take the other object out first.",
			WRONGGEM = "It wants a different gem.",
			WRONGSHADOWFORM = "It looks a little funny, doesn't it?",
		},
		GIVEALLTOPLAYER = 
		{
			BUSY = "They've got other pans in the fire.",
			DEAD = "Sadly it won't do them much good.",
			FULL = "Fuller than a belly at a six course meal.",
			SLEEPING = "They're snoozing right now.",
		},
		GIVETOPLAYER = 
		{
			BUSY = "They've got other pans in the fire.",
			DEAD = "Sadly it won't do them much good.",
			FULL = "Fuller than a belly at a six course meal.",
			SLEEPING = "They're snoozing right now.",
		},
		MOUNT = 
		{
			INUSE = "Oh. It must belong to someone else.",
			TARGETINCOMBAT = "Mon dieu. It's busy just now.",
		},
		PICKUP = 
		{
			INUSE = "Excusez-moi.",
			RESTRICTION = "I don't think that's for me.",
		},
		REPAIR = 
		{
			WRONGPIECE = "It needs something else.",
		},
		REPLATE = 
		{
			MISMATCH = "Non! I can't plate it with this!",
			SAMEDISH = "It's already beautifully plated.",
		},
		RUMMAGE = 
		{
			GENERIC = "I cannot right now.",
			INUSE = "Pardonnez-moi, I'll let you finish.",
            --NOTMASTERCHEF = "", --warly doesn't need this
		},
		SADDLE = 
		{
			TARGETINCOMBAT = "It's too angry to do that.",
		},
		SHAVE = 
		{
			AWAKEBEEFALO = "It would be unwise to attempt this while the animal is awake.",
			GENERIC = "Not a shaveable beast.",
			NOBITS = "Nothing to shave.",
		},
		SLAUGHTER = 
		{
			TOOFAR = "I don't know if I can catch up.",
		},
		STORE = 
		{
			GENERIC = "It is too full.",
			INUSE = "Pardonnez-moi, I'll let you finish.",
			NOTALLOWED = "This is not the place for it.",
            --NOTMASTERCHEF = "", --warly doesn't need this
		},
		TEACH = 
		{
			CANTLEARN = "That might be a bit beyond me.",
			KNOWN = "Ah. I already knew that.",
			WRONGWORLD = "That doesn't belong in this world, much like myself.",
		},
		USEKLAUSSACKKEY = 
		{
			KLAUS = "I'd like to get to safety first!",
			QUAGMIRE_WRONGKEY = "There must be another key somewhere.",
			WRONGKEY = "This key doesn't fit here.",
		},
		WRAPBUNDLE = 
		{
			EMPTY = "There's nothing to wrap.",
		},
		WRITE = 
		{
			GENERIC = "Maybe later. My hands are covered in cooking oil.",
			INUSE = "Oh, excusez-moi.",
		},
        DISMANTLE =
        {
            INUSE = "Oh, excusez-moi.", --someone is using it
            NOTEMPTY = "Oops, I've left some ingredients inside.", --has ingredients or cooked product
            COOKING = "Just a little longer... It's almost done.", --is currently cooking
        },
	},
	ACTIONFAIL_GENERIC = "I cannot do that.",
	ANNOUNCE_ACCOMPLISHMENT = "I am triumphant!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I hope this feeling lasts forever...",
	ANNOUNCE_ADVENTUREFAIL = "I shall have to attempt that again.",
	ANNOUNCE_ANTLION_SINKHOLE = 
	{
		"My soufflé!",
		"Was that my stomach rumbling?",
		"The earth must be very hungry.",
	},
	ANNOUNCE_ANTLION_TRIBUTE = 
	{
		"Pour vous.",
		"I hope you like it.",
		"For you, mon amie.",
	},
	ANNOUNCE_ATRIUM_DESTABILIZING = 
	{
		"I should like to head for the surface now!",
		"I think it's about time we left!",
		"Time to pack up and go.",
	},
	ANNOUNCE_BECOMEGHOST = "oOooOooo!!",
	ANNOUNCE_BEES = "The honeymakers are upon me!",
	ANNOUNCE_BOOMERANG = "Ouch! Damnable thing!",
	ANNOUNCE_BRAVERY_POTION = "I feel bold as a sharp cheddar!",
	ANNOUNCE_BURNT = "Charred...",
	ANNOUNCE_CANFIX = "\nI believe I could repair that.",
	ANNOUNCE_CAVEIN = "This place is crumbling like a dry cookie!",
	ANNOUNCE_CHARLIE = "What the devil!",
	ANNOUNCE_CHARLIE_ATTACK = "Gah! I do believe something bit me!",
	ANNOUNCE_COLD = "I'm... getting freezer burn...",
	ANNOUNCE_COMPASS_OUT = "Oh. I believe it broke.",
	ANNOUNCE_CRAFTING_FAIL = "I am lacking the required ingredients.",
	ANNOUNCE_DAMP = "I've been lightly spritzed.",
	ANNOUNCE_DEERCLOPS = "I do not like that sound one bit!",
	ANNOUNCE_DESPAWN = "I'm going to the kitchen in the sky.",
	ANNOUNCE_DIG_DISEASE_WARNING = "I hope that helps.",
	ANNOUNCE_DUSK = "The dinner hour approaches.",
	ANNOUNCE_EAT = 
	{
		GENERIC = "Magnifique!",
		INVALID = "Clearly inedible.",
		PAINFUL = "Aarg! My stomach...",
		SPOILED = "Blech! Why did I allow that to cross my lips?",
		STALE = "That was past its best-by date...",
		YUCKY = "I'm frankly offended by the mere suggestion.",
        --warly specific
        PREPARED = "Delectable!",
        SAME_OLD_1 = "I'd prefer some variety.",
        SAME_OLD_2 = "So bland.",
        SAME_OLD_3 = "I want to eat something different.",
        SAME_OLD_4 = "I can't stand this food.",
        SAME_OLD_5 = "Enough already!",
        TASTY = "Tres magnifique!",
        COOKED = "Not very palatable.",
        DRIED = "A bit dry.",
        RAW = "Blech. Completely lacking in every way.",
	},
	ANNOUNCE_ENCUMBERED = 
	{
		"I'm not... built for this...",
		"I bet... this is burning some calories...",
		"Oof!",
		"Hrrrr...",
		"Mon dieu!",
		"I'm working up... an appetite!",
		"So... heavy!",
		"I am strong... like flour!",
		"HRR!",
	},
	ANNOUNCE_ENTER_DARK = "Darkness, darkness.",
	ANNOUNCE_ENTER_LIGHT = "A new day comes with the dawning light.",
	ANNOUNCE_FAN_OUT = "It fell apart in my hands!",
	ANNOUNCE_FREEDOM = "Freeeeeeee!",
	ANNOUNCE_GHOSTDRAIN = "My, I have a headache.",
	ANNOUNCE_HIGHRESEARCH = "My brain is tingling!",
	ANNOUNCE_HOT = "I'm baking like a soufflé here...",
	ANNOUNCE_HOUNDS = "I recognize that sound. Hunger.",
	ANNOUNCE_HUNGRY = "I need food...",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Game is close at hand...",
	ANNOUNCE_HUNT_LOST_TRAIL = "I have lost the trail.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "The trail has been washed out.",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "It requires more manure.",
	ANNOUNCE_INV_FULL = "I cannot carry another stitch.",
	ANNOUNCE_KLAUS_CALLFORHELP = "Something's coming!",
	ANNOUNCE_KLAUS_ENRAGE = "Our egg's been beat! Run!",
	ANNOUNCE_KLAUS_UNCHAINED = "Its shackles fell away!",
	ANNOUNCE_KNOCKEDOUT = "My head... spinning...",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "That was much too close!",
	ANNOUNCE_LOWRESEARCH = "I did not learn any new tricks from that.",
	ANNOUNCE_MOSQUITOS = "Disease with wings!",
	ANNOUNCE_MOUNT_LOWHEALTH = "My poor sirloin's not looking so good!",
	ANNOUNCE_NODANGERAFK = "Non, I must defend myself!",
	ANNOUNCE_NODANGERGIFT = "I would like to not die first.",
	ANNOUNCE_NODANGERSIESTA = "This is no time to close my eyes!",
	ANNOUNCE_NODANGERSLEEP = "In this particular instance I'd prefer not to die in my sleep!",
	ANNOUNCE_NODAYSLEEP = "It is too bright to sleep.",
	ANNOUNCE_NODAYSLEEP_CAVE = "I'm not tired.",
	ANNOUNCE_NOHUNGERSIESTA = "I could use a nice meal first.",
	ANNOUNCE_NOHUNGERSLEEP = "My hunger trumps my exhaustion.",
	ANNOUNCE_NOMOUNTEDGIFT = "First I should get down from this big sirloin here.",
	ANNOUNCE_NONIGHTSIESTA = "Siesta in the dark? I think not.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "This does not strike me as a relaxing place for siesta.",
	ANNOUNCE_NOSLEEPONFIRE = "I think not! That's a hotbed for danger!",
	ANNOUNCE_NOWARDROBEONFIRE = "Fire!",
	ANNOUNCE_NO_TRAP = "Went off without a hitch.",
	ANNOUNCE_PECKED = "Gah! Enough!",
	ANNOUNCE_PETRIFED_TREES = "Are the trees making that sound?",
	ANNOUNCE_PICK_DISEASE_WARNING = "It has a most un-delicious smell.",
	ANNOUNCE_QUAKE = "That is not a comforting sound...",
	ANNOUNCE_REPELLED = "I can't get through!",
	ANNOUNCE_RESEARCH = "Education is a lifelong process.",
	ANNOUNCE_REVIVED_FROM_CORPSE = "Do I smell pie?",
	ANNOUNCE_REVIVED_OTHER_CORPSE = "Et voilà!",
	ANNOUNCE_REVIVING_CORPSE = "Hold on, mon amie.",

	ANNOUNCE_RUINS_RESET = "The terrible monsters are back!",
	ANNOUNCE_SACREDCHEST_NO = "Apologies for my shortcomings.",
	ANNOUNCE_SACREDCHEST_YES = "Merci beacoup!",
	ANNOUNCE_SHELTER = "I am thankful for this tree's protective buffer.",
	ANNOUNCE_SNARED = "Ouch! How rude!",
	ANNOUNCE_SOAKED = "I'm wetter than a dish rag!",
	ANNOUNCE_SPOOKED = "Eee!",
	ANNOUNCE_THORNS = "Gah!",
	ANNOUNCE_THURIBLE_OUT = "Out of fuel.",
	ANNOUNCE_TOADESCAPED = "It's going to leave soon.",
	ANNOUNCE_TOADESCAPING = "Was it something I said?",
	ANNOUNCE_TOOL_SLIP = "Everything is slick...",
	ANNOUNCE_TORCH_OUT = "Come back, light!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Bonjour! I've arrived!",
	ANNOUNCE_TRAP_WENT_OFF = "Darn!",
	ANNOUNCE_UNIMPLEMENTED = "It is not operational yet.",
	ANNOUNCE_WET = "I am getting positively drenched.",
	ANNOUNCE_WETTER = "I fear I may be water soluble!",
	ANNOUNCE_WORMHOLE = "I must be unhinged to travel so...",
	ANNOUNCE_WORMS = "Huh? What's that?",

	ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I'll zap you to a nice, even crisp!",
	ANNOUNCE_ATTACH_BUFF_ATTACK   		   = "Try my new specialty - an open-faced knuckle sandwich!",
	ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I feel très formidable!",
	ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Now we're cooking!",
	ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Ah, nice and dry!",
	
	ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Oh well, I prefer natural gas over electric anyway.",
	ANNOUNCE_DETACH_BUFF_ATTACK 		   = "Erm... I think I'm more of a food lover than a fighter after all.",
	ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Ah... I've gone from tough to tender.",
	ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Ah non, I think I'm losing steam.",
	ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Is it getting a bit soggy in here?",

	BATTLECRY = 
	{
		DEER = "Oh, it's venisON!",
		GENERIC = "I'm also an accomplished butcher!",
		PIG = "No part of you will go to waste, cochon!",
		PREY = "You look delicious!",
		SPIDER = "I hope it does not rain after I kill you!",
		SPIDER_WARRIOR = "You will die, pest!",
	},
	COMBAT_QUIT = 
	{
		GENERIC = "There's no shame in running!",
		PIG = "Noooo, those hocks, those chops...",
		PREY = "Whew. I'm out of breath.",
		SPIDER = "I hope it didn't take any bites out of me.",
		SPIDER_WARRIOR = "That could have been worse.",
	},
	DESCRIBE = 
	{
		ABIGAIL = "Bonjour, Mademoiselle Abigail!",
		ABIGAIL_FLOWER = 
		{
			GENERIC = "I don't think it's edible.",
			HAUNTED_GROUND = "What now, Mademoiselle Wendy?",
			HAUNTED_POCKET = "I don't think it's my place to be holding this.",
			LONG = "Something's stirring inside.",
			MEDIUM = "I think it's waking up.",
			SOON = "I get the feeling something will happen soon.",
		},
		ACCOMPLISHMENT_SHRINE = "I always wished to make a name for myself.",
		ACORN = 
		{
			GENERIC = "It rattles.",
			PLANTED = "A new beginning...",
		},
		ACORN_COOKED = "This could use something... Anything.",
		ACORN_SAPLING = "Just a petite bébé.",
		ADVENTURE_PORTAL = "What fresh devilment is this?",
		AMULET = "I wear safety.",
		ANCIENT_ALTAR = "A structure from antiquity.",
		ANCIENT_ALTAR_BROKEN = "It is broken.",
		ANCIENT_STATUE = "It gives off strange vibrations.",
		ANIMAL_TRACK = "These tracks point to fresh game.",
		ANTLION = 
		{
			GENERIC = "I think it's friendly.",
			UNHAPPY = "Oh no, don't be mad.",
			VERYHAPPY = "Life is good right now.",
		},
		ANTLIONTRINKET = "I think I know someone who would want this.",
		ARMORDRAGONFLY = "Heavy and hot.",
		ARMORGRASS = "How much protection can grass really provide?",
		ARMORMARBLE = "Weighs a ton.",
		ARMORRUINS = "Ancient armor.",
		ARMORSKELETON = "I'm supposed to put that on?",
		ARMORSLURPER = "Ah. My appetite wanes under its protection.",
		ARMORSNURTLESHELL = "It allows me to turtle.",
		ARMORWOOD = "Sturdy, but quite flammable.",
		ARMOR_BRAMBLE = "I'll have to be very careful putting it on.",
		ARMOR_SANITY = "Am I crazy to wear this?",
		ARROWSIGN_PANEL = 
		{
			BURNT = "Crisp, non?",
			GENERIC = "This must be a sign.",
			UNWRITTEN = "I'll write a nice note for the next person.",
		},
		ARROWSIGN_POST = 
		{
			BURNT = "Overcooked.",
			GENERIC = "This must be a sign.",
			UNWRITTEN = "I'll write a nice note for the next person.",
		},
		ASH = 
		{
			GENERIC = "I miss ash covered cheeses. I miss cheeses, period.",
			REMAINS_EYE_BONE = "The eyebone was sacrificed in my travels.",
			REMAINS_GLOMMERFLOWER = "The unusual flower is but ash now.",
			REMAINS_THINGIE = "It is no more.",
		},
		ATRIUM_GATE = 
		{
			CHARGING = "I think it's charging up.",
			COOLDOWN = "It's in a recovery period.",
			DESTABILIZING = "Something unsafe is happening.",
			OFF = "All the pieces are back in place.",
			ON = "It's ready.",
		},
		ATRIUM_KEY = "This seems very precious.",
		ATRIUM_LIGHT = 
		{
			OFF = "Off, for now.",
			ON = "There's a strange force behind this.",
		},
		ATRIUM_OVERGROWTH = "Is this a language of some sort?",
		ATRIUM_RUBBLE = 
		{
			LINE_1 = "A picture of lots of unprepared seafood. I'm hungry.",
			LINE_2 = "This tablet's all worn down.",
			LINE_3 = "The world is flooded by a finely fermented black bean sauce.",
			LINE_4 = "The prawns being de-shelled.",
			LINE_5 = "The prawns have ascended into deliciousness.",
		},
		ATRIUM_STATUE = "When I turn my back, I imagine I hear it breathing.",
		AXE = "A trusty companion in these environs.",
		BABYBEEFALO = 
		{
			GENERIC = "I have mixed feelings about veal.",
			SLEEPING = "Bonne nuit, baby steak.",
		},
		BACKPACK = "It has my back.",
		BACONEGGS = "Runny eggs... crisp bacon... I could die happy now...",
		BALLOON = "How colorful!",
		BALLOONS_EMPTY = "It's been left completely breathless.",
		BANDAGE = "First aid.",
		BASALT = "Made of strong stuff!",
		BAT = "If I only had a bat...",
		BATBAT = "A gruesome implement.",
		BATCAVE = "I wouldn't want to disturb their peaceful slumber.",
		BATWING = "Hmmm, maybe a soup stock of batwings?",
		BATWING_COOKED = "Needs garlic...",
		BEARDHAIR = "Disgusting.",
		BEARGER = "Oh, I don't like you one bit!",
		BEARGERVEST = "Furry refuge from the elements.",
		BEARGER_FUR = "Feels warm.",
		BEDROLL_FURRY = "Cozy.",
		BEDROLL_STRAW = "A little better than bare ground. Scratchy.",
		BEE = 
		{
			GENERIC = "Where there are bees, there is honey!",
			HELD = "Hi, honey.",
		},
		BEEBOX = 
		{
			BURNT = "Disastrously caramelized.",
			FULLHONEY = "Honey jackpot!",
			GENERIC = "Home of the honeymakers!",
			NOHONEY = "No more honey...",
			READY = "Honey jackpot!",
			SOMEHONEY = "There is a little honey.",
		},
		BEEFALO = 
		{
			DOMESTICATED = "This one's quite calm.",
			FOLLOWER = "That's it, my friend. I lead, you follow.",
			GENERIC = "Here's the beef.",
			NAKED = "Chin up, it'll grow back.",
			ORNERY = "It's boiling up!",
			PUDGY = "You enjoy food as much as me.",
			RIDER = "I think I could actually handle this one.",
			SLEEPING = "The sirloin slumbers...",
		},
		BEEFALOHAT = "Fits perfectly.",
		BEEFALOWOOL = "The beast's loss is my gain.",
		BEEGUARD = "Oh non non non, I hate being stung!",
		BEEHAT = "Essential honey harvesting attire.",
		BEEHIVE = "I can hear the activity within.",
		BEEMINE = "Weaponized bees.",
		BEEMINE_MAXWELL = "I pity whoever trips this.",
		BEEQUEEN = "Your honey was too delicious not to steal!",
		BEEQUEENHIVE = 
		{
			GENERIC = "I don't think that honey would taste very good.",
			GROWING = "I don't remember this being here.",
		},
		BEEQUEENHIVEGROWN = "That's almost definitely bigger than before.",
		BEESWAX = "A first-rate preservative.",
		BEETLETAUR = "We don't really have to fight, do we?",
		BELL = "Should I ring it?",
		BERNIE_ACTIVE = "What a silly fellow.",
		BERNIE_BIG = "Tres géant!",
		BERNIE_INACTIVE = 
		{
			BROKEN = "Poor little fellow.",
			GENERIC = "I've been told his name is \"Bernie\".",
		},
		BERRIES = "Fresh fruit!",
		BERRIES_COOKED = "Could use a pinch of sugar...",
		BERRIES_JUICY = "What a unique, tangy flavor.",
		BERRIES_JUICY_COOKED = "I'd have preferred to cook them into a proper dish.",
		BERRYBUSH = 
		{
			BARREN = "They require care and fertilizer.",
			BURNING = "It's burning down!",
			DISEASED = "It's got food poisoning.",
			DISEASING = "I think it's coming down with a little something.",
			GENERIC = "Berries!",
			PICKED = "More will return.",
			WITHERED = "The heat has stifled these berries.",
		},
		BERRYBUSH_JUICY = 
		{
			BARREN = "No more fresh berries for my desserts.",
			BURNING = "It's burning down!",
			DISEASED = "It's got food poisoning.",
			DISEASING = "I think it's coming down with a little something.",
			GENERIC = "Berries!",
			PICKED = "I can't wait for more.",
			WITHERED = "It's much too hot, I agree.",
		},
		BIGFOOT = "Please do not squish me!",
		BIRCHNUTDRAKE = "What madness is this?",
		BIRDCAGE = 
		{
			DEAD = "Maybe it will wake up.",
			GENERIC = "Suitable lodgings for a feathered beast.",
			HUNGRY = "Let me cook something nice up for you.",
			OCCUPIED = "I now have an egg farm!",
			SKELETON = "It is not waking up. Oh dear.",
			SLEEPING = "Sleep now, lay later.",
			STARVING = "Oh, what do birds eat? A nice brisket?",
		},
		BIRDTRAP = "Oh, roast bird! Hm, don't get ahead of yourself, Warly...",
		BIRD_EGG = "Nature's perfect food.",
		BIRD_EGG_COOKED = "Could use a few different herbs...",
		BISHOP = "You don't strike me as particularly spiritual.",
		BISHOP_CHARGE_HIT = "Mon dieu!",
		BISHOP_NIGHTMARE = "You are grinding my gears, dear fellow.",
		BLOWDART_FIRE = "Breathing fire!",
		BLOWDART_LAVA = "That might hurt somebody.",
		BLOWDART_LAVA2 = "That looks very dangerous.",
		BLOWDART_PIPE = "They won't know what hit them.",
		BLOWDART_SLEEP = "A sleep aid!",
		BLOWDART_YELLOW = "It's positively electric.",
		BLUEAMULET = "Brrrrrr!",
		BLUEGEM = "Such a cool blue.",
		BLUEMOONEYE = "It should keep watch for us.",
		BLUEPRINT = 
		{
			COMMON = "Time to stretch the brain muscles.",
			RARE = "This one looks complicated.",
		},
		BLUE_CAP = "What deliciousness shall you yield?",
		BLUE_CAP_COOKED = "Could use a dash of smoked salt and balsamic vinegar...",
		BLUE_MUSHROOM = 
		{
			GENERIC = "Ah, a blue truffle!",
			INGROUND = "It retreats from the light.",
			PICKED = "I hope the truffles are restocked soon.",
		},
		BOARDS = "Sigh. It would be so perfect for grilling salmon.",
		BOARON = "Begone, cochon!",
		BOARRIOR = "Bring it on, géant cochon!",
		BONESHARD = "I could make a hearty stock with these.",
		BONESTEW = "Warms my soul!",
		BOOK_BIRDS = "I had hoped it was a poultry cookbook.",
		BOOK_BRIMSTONE = "I don't think that's my forte.",
		BOOK_ELEMENTAL = "I don't think that's my forte.",
		BOOK_FOSSIL = "I don't think that's my forte.",
		BOOK_GARDENING = "Maybe Mme. Wickerbottom would be interested in starting a herb garden.",
		BOOK_SLEEP = "It's tradition to nap after a good meal.",
		BOOK_TENTACLES = "I don't see any recipes in this at all.",
		BOOMERANG = "Oh good. I have separation anxiety.",
		BRUSH = "For tidying unkempt beast hair.",
		BUGNET = "For catching alternative protein.",
		BUNDLE = "A cool dry place to keep food.",
		BUNDLEWRAP = "A good food wrap.",
		BUNNYMAN = "I have so many good rabbit recipes...",
		BURNT_MARSH_BUSH = "What a shame.",
		BUSHHAT = "Snacks to go?",
		BUTTER = "I thought I would never see you again, old friend!",
		BUTTERFLY = 
		{
			GENERIC = "Your aerial dance is so soothing to behold...",
			HELD = "Don't slip from my butterfingers.",
		},
		BUTTERFLYMUFFIN = "Delectable!",
		BUTTERFLYWINGS = "I wonder what dishes I could create with these?",
		BUZZARD = "If only you were more turkey than vulture...",
		CACTUS = 
		{
			GENERIC = "I bet it has a sharp flavor.",
			PICKED = "It will live to prick again.",
		},
		CACTUS_FLOWER = "Such a pretty flower from such a prickly customer!",
		CACTUS_MEAT = "I hope it does not prickle going down.",
		CACTUS_MEAT_COOKED = "Could use some tortillas and melted queso...",
		CAMPFIRE = 
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "To keep the dark at bay.",
			HIGH = "Rivals a grease fire!",
			LOW = "It is getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		CANARY = 
		{
			GENERIC = "Sing me your sweet song, mon amie.",
			HELD = "Bonjour monsieur.",
		},
		CANARY_POISONED = "The poor thing!",
		CANDYBAG = "Where I keep all my confections!",
		CANE = "Now we are cooking with gas!",
		CARROT = "Fresh picked produce!",
		CARROT_COOKED = "Could use a dash of olive oil and cilantro...",
		CARROT_PLANTED = "Ah, a fresh carrot!",
		CARROT_SEEDS = "Future carrots!",
		CARTOGRAPHYDESK = 
		{
			BURNING = "Oh dear!",
			BURNT = "Well, that won't help our explorations much.",
			GENERIC = "I hope my penmanship is legible.",
		},
		CATCOON = "What perky little ears.",
		CATCOONDEN = 
		{
			EMPTY = "Vacant of critters.",
			GENERIC = "How many critters can fit in there?",
		},
		CATCOONHAT = "Not quite my style.",
		CAVEIN_BOULDER = 
		{
			GENERIC = "I'm sure I'm strong enough to move it.",
			RAISED = "I can't get at it.",
		},
		CAVE_BANANA = "Bananas! Just the flavor I needed!",
		CAVE_BANANA_BURNT = "I would have liked more fresh bananas.", -- this is a burnt banana tree, not a burnt banana
		CAVE_BANANA_COOKED = "Could use some oats and a few chocolate chips...",
		CAVE_BANANA_TREE = "There must be monkeys close by.",
		CAVE_ENTRANCE = 
		{
			GENERIC = "I wonder what is underneath that?",
			OPEN = "Dare I?",
		},
		CAVE_ENTRANCE_OPEN = 
		{
			FULL = "Someone else is having their turn in there.",
			GENERIC = "I wonder what is underneath that?",
			OPEN = "Dare I?",
		},
		CAVE_ENTRANCE_RUINS = "What is within?",
		CAVE_EXIT = 
		{
			FULL = "I'll wait til there's a little more room.",
			GENERIC = "Now isn't a good time to leave.",
			OPEN = "I should like to see the surface again.",
		},
		CAVE_FERN = "How does anything grow down here?",
		CHARCOAL = "This, a grill and some meat and I'd have dinner.",
		CHESSJUNK1 = "Broken chess pieces?",
		CHESSJUNK2 = "More broken chess pieces?",
		CHESSJUNK3 = "And yet more broken chess pieces?",
		CHESSPIECE_BEARGER = "I can't believe we survived that beast!",
		CHESSPIECE_BISHOP = 
		{
			GENERIC = "It looks a bit like a bishop.",
			STRUGGLE = "Mon dieu! It's moving!",
		},
		CHESSPIECE_CLAYHOUND = "I'm glad it's not trying to bite me.",
		CHESSPIECE_CLAYWARG = "I'm not sure why we memorialized this very scary creature.",
		CHESSPIECE_DEERCLOPS = "It was much scarier in the flesh.",
		CHESSPIECE_DRAGONFLY = "I was afraid I was going to be broiled alive!",
		CHESSPIECE_FORMAL = "This must be the king?",
		CHESSPIECE_HORNUCOPIA = "One can dream.",
		CHESSPIECE_KNIGHT = 
		{
			GENERIC = "It looks a bit like a knight.",
			STRUGGLE = "Mon dieu! It's moving!",
		},
		CHESSPIECE_MOOSEGOOSE = "I should whip up some roast goose with cranberry sauce.",
		CHESSPIECE_MUSE = "This one looks like a queen.",
		CHESSPIECE_PAWN = "It looks a bit like a pawn.",
		CHESSPIECE_PIPE = "I hope it doesn't set a bad example for the little ones.",
		CHESSPIECE_ROOK = 
		{
			GENERIC = "It looks a bit like a rook.",
			STRUGGLE = "Mon dieu! It's moving!",
		},
		CHESTER = "You look cute and inedible.",
		CHESTER_EYEBONE = 
		{
			GENERIC = "The eye follows me wherever I go...",
			WAITING = "It sleeps.",
		},
		CLAYHOUND = 
		{
			GENERIC = "Don't eat me, I'm unseasoned!",
			STATUE = "Someone's a very talented sculptor.",
		},
		CLAYWARG = 
		{
			GENERIC = "I'm not on the menu!",
			STATUE = "It looks quite nice.",
		},
		COLDFIRE = 
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "Fire that cools?",
			HIGH = "The flames climb higher!",
			LOW = "It's getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		COLDFIREPIT = 
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "Fire that cools?",
			HIGH = "The flames climb higher!",
			LOW = "It's getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		COMPASS = 
		{
			E = "East.",
			GENERIC = "Hmm, no reading.",
			N = "North.",
			NE = "Northeast.",
			NW = "Northwest.",
			S = "South.",
			SE = "Southeast.",
			SW = "Southwest.",
			W = "West.",
		},
		COMPOSTWRAP = "I'm frankly offended.",
		--CONSTRUCTION_PLANS = "",
		COOKEDMANDRAKE = "Could use horseradish...",
		COOKEDMEAT = "Could use a chimichurri sauce...",
		COOKEDMONSTERMEAT = "Could use... uh... I don't even...",
		COOKEDSMALLMEAT = "Could use sea salt...",
		COOKPOT = 
		{
			BURNT = "Tragique.",
			COOKING_LONG = "A masterpiece takes time.",
			COOKING_SHORT = "Nearly there...",
			DONE = "Ahh, fini!",
			EMPTY = "Empty pot, empty heart.",
		},
		COONTAIL = "Chat noodle.",
		CORN = "Corn! Sweet, sweet corn!",
		CORN_COOKED = "Could use miso and lardons...",
		CORN_SEEDS = "The promise of so many more corn dishes!",
		CRITTERLAB = "I could use a friend in this difficult world.",
		CRITTER_DRAGONLING = "Her name is \"Flambé\" and she is precious.",
		CRITTER_GLOMLING = "She's a great comfort in times of stress.",
		CRITTER_KITTEN = "Sweet petite chat.",
		CRITTER_LAMB = "This is Lambchop, my little kitchen helper.",
		CRITTER_PERDLING = "I would never eat you.",
		CRITTER_PUPPY = "Le petit chien!",
		CROW = 
		{
			GENERIC = "Raven stew perhaps?",
			HELD = "Hush, my pet.",
		},
		CUTGRASS = "What shall I craft?",
		CUTLICHEN = "Hmm, odd.",
		CUTREEDS = "Smells like greenery.",
		CUTSTONE = "Compressed stones, nice presentation.",
		DEADLYFEAST = "I would not recommend this.",
		DECIDUOUSTREE = 
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A bouquet of leaves.",
			POISON = "No thank you!",
		},
		DEER = 
		{
			ANTLER = "Shouldn't they have two antlers?",
			GENERIC = "Imagine... succulent venison bourguignon.",
		},
		DEERCLOPS = "I once had a saucier who looked like that.",
		DEERCLOPS_EYEBALL = "Giant eyeball... soup?",
		DEER_ANTLER = "It looks like a key, does it not?",
		--DEER_GEMMED = "",
		DEPLETED_GRASS = 
		{
			GENERIC = "Well past its expiry date.",
		},
		DESERTHAT = "Goggles would be quite useful. I need my eyes.",
		DEVTOOL = "Efficient, oui?",
		DEVTOOL_NODEV = "No, I am a traditionalist.",
		DIRTPILE = "It's making a bit of a mess, isn't it?",
		DIVININGROD = 
		{
			COLD = "Hmm, keep looking.",
			GENERIC = "A finely tuned radar stick.",
			HOT = "I can almost smell it!",
			WARM = "I've caught onto something!",
			WARMER = "Warmer, warmer...!",
		},
		DIVININGRODBASE = 
		{
			GENERIC = "Is it a chopping block?",
			READY = "How do I turn it on?",
			UNLOCKED = "Preparation complete!",
		},
		DIVININGRODSTART = "That looks important.",
		DRAGONBODYHAT = "I can be the middle of the dragon.",
		DRAGONFLY = "I'm not cut out for this.",
		DRAGONFLYCHEST = "Ooh la la, burnproof storage.",
		DRAGONFLYFURNACE = 
		{
			GENERIC = "It's a gilded furnace.",
			HAMMERED = "Is it reparable?",
			HIGH = "What a handsome fire!",
			NORMAL = "I believe it's giving me the \"eye\".",
		},
		DRAGONFRUIT = "So exotic!",
		DRAGONFRUIT_COOKED = "Could use a spread of pudding and chia seeds...",
		DRAGONFRUIT_SEEDS = "They hatch dragonfruits.",
		DRAGONHEADHAT = "Oh! Do I get to be the head?",
		DRAGONPIE = "Flaky crust, tart filling... heavenly!",
		DRAGONTAILHAT = "I'm just happy to be part of the festivities.",
		DRAGON_SCALES = "Hot to the touch!",
		DRUMSTICK = "Dark meat!",
		DRUMSTICK_COOKED = "Could use a light honey garlic glaze...",
		DUG_BERRYBUSH = "Should I bring it back to life?",
		DUG_BERRYBUSH_JUICY = "Now I can have fresh berries wherever I please!",
		DUG_GRASS = "Should I bring it back to life?",
		DUG_MARSH_BUSH = "Should I bring it back to life?",
		DUG_SAPLING = "Should I bring it back to life?",
		DURIAN = "That odor...",
		DURIAN_COOKED = "Could use onions and chili...",
		DURIAN_SEEDS = "Even these smell...",
		EARMUFFSHAT = "Ahh, fuzzy!",
		EEL = "Anguille.",
		EEL_COOKED = "Could use some Cajun spices...",
		EGGPLANT = "Aubergine!",
		EGGPLANT_COOKED = "Could use tomato sauce and Parmesan...",
		EGGPLANT_SEEDS = "Hatches more eggplants!",
		ENDTABLE = 
		{
			BURNT = "Should have taken it out of the oven sooner.",
			EMPTY = "It could use a little something.",
			FRESHLIGHT = "Now we can all shine a little brighter.",
			GENERIC = "I miss table settings.",
			OLDLIGHT = "It's looking pretty dim.",
			WILTED = "I hope Maman Angeline is eating well without me.",
		},
		EVERGREEN = 
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A soldier of the exotic forest.",
		},
		EVERGREEN_SPARSE = 
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A coneless arbre.",
		},
		EYEBRELLAHAT = "\"Eye\" like it!",
		EYEPLANT = "Is that a mouth?",
		EYETURRET = "This is my friend, Lazer Oeil!",
		EYETURRET_ITEM = "Wake up!",
		FARMPLOT = 
		{
			BURNT = "Stayed in the oven a tad too long.",
			GENERIC = "I can grow my own ingredients!",
			GROWING = "Ah, couldn't be more fresh!",
			NEEDSFERTILIZER = "Needs to be fertilized.",
		},
		FEATHERFAN = "Why is it so big?",
		FEATHERHAT = "What am I supposed to do with this?",
		FEATHERPENCIL = "Lighter than my meringue.",
		FEATHER_CANARY = "A bird's feather, in lemon yellow.",
		FEATHER_CROW = "A bird's feather, in truffle black.",
		FEATHER_ROBIN = "A bird's feather, in cherry red.",
		FEATHER_ROBIN_WINTER = "A bird's feather, in tuna blue.",
		FEM_PUPPET = "She's trapped!",
		FENCE = "A fence.",
		FENCE_GATE = "Like an oven door.",
		FENCE_GATE_ITEM = "The ingredients for a gate.",
		FENCE_ITEM = "The ingredients for a fence.",
		FERTILIZER = "Sauce for my garden!",
		FIREBALLSTAFF = "A portable stovetop.",
		FIRECRACKERS = "Like oil splattering in a hot pan.",
		FIREFLIES = 
		{
			GENERIC = "A dash of glow.",
			HELD = "My petit lightbulb pets.",
		},
		FIREHOUND = "Chien, on fire!",
		FIREPIT = 
		{
			EMBERS = "That fire's almost out!",
			GENERIC = "To warm my fingers and roast sausages.",
			HIGH = "Maximum heat!",
			LOW = "It's getting low.",
			NORMAL = "Parfait.",
			OUT = "I like when it's warm and toasty.",
		},
		FIRESTAFF = "Oven on a stick!",
		FIRESUPPRESSOR = 
		{
			LOWFUEL = "Shall I fuel it up?",
			OFF = "He's sleeping.",
			ON = "Make it snow!",
		},
		FISH = "Poisson!",
		FISHINGROD = "I believe I prefer the fish market.",
		FISHSTICKS = "Crunchy and golden outside, flaky and moist inside!",
		FISHTACOS = "Takes me south of the border!",
		FISH_COOKED = "Could use a squeeze of lemon...",
		FLINT = "Sharp as can be!",
		FLOWER = 
		{
			GENERIC = "I love to garnish with edible flowers.",
			ROSE = "Confections flavored with rose water, perhaps?",
		},
		FLOWERHAT = "Who doesn't look good in this?!",
		FLOWERSALAD = "Edible art!",
		FLOWER_CAVE = "Ah, a light in the dark.",
		FLOWER_EVIL = "A terrible omen if I ever saw one.",
		FLOWER_WITHERED = "I only use fresh ingredients in my cooking.",
		FOLIAGE = "Feuillage.",
		FOOTBALLHAT = "Made from pork, to protect my melon.",
		FOSSIL_PIECE = "No marrow left in it.",
		FOSSIL_STALKER = 
		{
			COMPLETE = "That looks about right. Now, what's the secret ingredient?",
			FUNNY = "At least it's good for a chuckle.",
			GENERIC = "There are still a few bits missing.",
		},
		FROG = 
		{
			DEAD = "I'll eat your legs for dinner!",
			GENERIC = "Frog. A delicacy.",
			SLEEPING = "Bonne nuit, little snack.",
		},
		FROGGLEBUNWICH = "Ah, French cuisine!",
		FROGLEGS = "I am hopping with excitement!",
		FROGLEGS_COOKED = "Could use garlic and clarified butter...",
		FRUITMEDLEY = "Invigorating!",
		FURTUFT = "Plush and soft, if a bit dirty.",
		GARGOYLE_HOUND = "I feel strangely uneasy.",
		GARGOYLE_WEREPIG = "It won't begin to move, will it?",
		GEARS = "The insides of those naughty machines.",
		GEMSOCKET = 
		{
			GEMS = "Gem it!",
			VALID = "Voilà!",
		},
		GHOST = "Could I offer you a ghost pepper?",
		GIFT = "Pour moi?",
		GIFTWRAP = "I could hide some cookies inside for the little ones.",
		GLASSBLOCK = "Reminds me of the ice sculptures in the ship's dining hall.",
		GLASSSPIKE = "I prefer my decor a smidge less... stabby.",
		GLOMMER = "I think I like it.",
		GLOMMERFLOWER = 
		{
			DEAD = "What a waste.",
			GENERIC = "Tres beau!",
		},
		GLOMMERFUEL = "Looks like bubblegum, tastes like floor.",
		GLOMMERWINGS = "A tiny delicacy.",
		GOATMILK = "Can I make this into cheese?",
		GOGGLESHAT = "Oh. I've never considered myself fashionable before!",
		GOLDENAXE = "A golden chopper!",
		GOLDENPICKAXE = "That looks nice.",
		GOLDENPITCHFORK = "A golden fork for a giant, oui?",
		GOLDENSHOVEL = "Shiny.",
		GOLDNUGGET = "Yolk yellow, glowing gold!",
		GOOSE_FEATHER = "A plucked goose was here.",
		GRASS = 
		{
			BARREN = "Could I get some fertilizer over here?",
			BURNING = "I never burn anything in the kitchen.",
			DISEASED = "It's under the weather.",
			DISEASING = "It's starting to look a little funny.",
			GENERIC = "A common ingredient for success around here.",
			PICKED = "Plucked clean!",
			WITHERED = "Too hot for you.",
		},
		GRASSGEKKO = 
		{
			DISEASED = "Would some nice soup make you feel better?",
			GENERIC = "It doesn't seem dangerous.",
		},
		GRASS_UMBRELLA = "A bit of shade is better than none.",
		GREENAMULET = "For more savvy construction!",
		GREENGEM = "Ahh, a rare attraction!",
		GREENMOONEYE = "So long as it doesn't blink.",
		GREENSTAFF = "I probably shouldn't stir soup with this.",
		GREEN_CAP = "Don't crowd the mushrooms.",
		GREEN_CAP_COOKED = "Could use a slathering of butter and chives...",
		GREEN_MUSHROOM = 
		{
			GENERIC = "Little champignon!",
			INGROUND = "Did it eat itself...?",
			PICKED = "I eagerly await its rebirth!",
		},
		GUACAMOLE = "More like Greatamole!",
		GUANO = "Poop of the bat.",
		GUNPOWDER = "Boom!",
		HALLOWEENCANDY_1 = "These can be enjoyable, now and then.", --candy apple
		HALLOWEENCANDY_2 = "There are better confections available, in my professional opinion.", --candy corn
		HALLOWEENCANDY_3 = "It could use some butter and salt.", --not-so-candy corn
		HALLOWEENCANDY_4 = "Licorice is only for the most refined palates.", --gummy spider
		HALLOWEENCANDY_5 = "The closest thing I've found to an after dinner mint.", --catcoon candy
		HALLOWEENCANDY_6 = "I don't think those are fit to eat.", --"raisins"
		HALLOWEENCANDY_7 = "Real raisins! Think of the culinary potential.", --raisins
		HALLOWEENCANDY_8 = "I don't need the whole thing, just a couple licks.", --ghost pop
		HALLOWEENCANDY_9 = "I wouldn't want to ruin my dinner.", --jelly worm
		HALLOWEENCANDY_10 = "The younger among us would enjoy it more than me.", --tentacle lolli
		HALLOWEENCANDY_11 = "There are few things I love more than milk chocolate.", --choco pigs
		HALLOWEENCANDY_12 = "I'm sure it tastes better than it looks.", --candy lice
		HALLOWEENCANDY_13 = "It's a little too sweet for my taste.", --otherworldly jawbreaker
		HALLOWEENCANDY_14 = "It sticks in my teeth, but it's well worth it.", --lava pepper
		HALLOWEENPOTION_BRAVERY = "I'm not convinced I want to drink it.",
		HALLOWEENPOTION_DRINKS_POTENT = "Oof, smells strong.",
		HALLOWEENPOTION_DRINKS_WEAK = "I don't think it'll do much.",
		HALLOWEENPOTION_FIRE_FX = "The fire has caramelized.",
		HALLOWEEN_ORNAMENT_1 = "Fear upsets my stomach.", --ghost decoration
		HALLOWEEN_ORNAMENT_2 = "Its wings are so... leathery.", --bat decoration
		HALLOWEEN_ORNAMENT_3 = "I'm afraid to touch it.", --spider decoration
		HALLOWEEN_ORNAMENT_4 = "I miss calamari.", --tentacle decoration
		HALLOWEEN_ORNAMENT_5 = "How creepy.", --dangling depth dweller decoration
		HALLOWEEN_ORNAMENT_6 = "I'd rather not eat crow.", --crow decoration
		HAMBAT = "Mmm, ham popsicle!",
		HAMMER = "For tenderizing boeuf!",
		HAMMER_MJOLNIR = "It's a heavy duty tenderizer.",
		HAWAIIANSHIRT = "When in Rome...",
		HEALINGSALVE = "Soothing.",
		HEALINGSTAFF = "I like this.",
		HEATROCK = 
		{
			COLD = "Still cold.",
			FROZEN = "Vanilla ice.",
			GENERIC = "A temperature stone.",
			HOT = "Hot!",
			WARM = "It's warming up nicely.",
		},
		HIVEHAT = "The stickiness is mostly gone. Mostly.",
		HOME = "Who lives here?",
		HOMESIGN = 
		{
			BURNT = "Overcooked.",
			GENERIC = "What's the use in a sign around here?",
			UNWRITTEN = "I'll write a nice note for the next person.",
		},
		HONEY = "Nectar of the gods!",
		HONEYCOMB = "Just add milk!",
		HONEYHAM = "Comfort food!",
		HONEYNUGGETS = "Junk food is my guilty pleasure. Shh!",
		HORN = "There's still some hairs inside.",
		HOTCHILI = "Spice up my life!",
		HOUND = "Angry chien!",
		HOUNDBONE = "Hmm, soup stock...",
		HOUNDMOUND = "It smells wet.",
		HOUNDSTOOTH = "Better to lose a tooth than your tongue!",
		HOUNDWHISTLE = "I think I'm too old to hear it.",

		HUTCH = "Just my cute little breadbox.",
		HUTCH_FISHBOWL = 
		{
			GENERIC = "He's a cheery little fishstick.",
			WAITING = "He's missing his other half.",
		},
		ICE = "That's ice.",
		ICEBOX = "The ice box, my second-most loyal culinary companion.",
		ICECREAM = "The heat is sweetly beat!",
		ICEHAT = "Must I wear it?",
		ICEHOUND = "Away, frozen diable!",
		ICEPACK = "Now this I can use!",
		ICESTAFF = "It flash freezes poulet!",
		INSANITYROCK = 
		{
			ACTIVE = "And I'm in!",
			INACTIVE = "Do not lick it. Your tongue will get stuck.",
		},
		INSPECTSELF = "What a tasty dish!",
		JAMMYPRESERVES = "Simple, sweet, parfait.",
		JELLYBEAN = "A little something sweet to brighten the day.",
		KABOBS = "Opa!",
		KILLERBEE = 
		{
			GENERIC = "Almost not worth the honey!",
			HELD = "So sassy!",
		},
		KLAUS = "He doesn't look very jolly.",
		KLAUSSACKKEY = "Well, it's the key to something.",
		KLAUS_SACK = "There might be all sorts of treats inside.",
		KNIGHT = "A tricky cheval!",
		KNIGHT_NIGHTMARE = "Effroyable!",
		KOALEFANT_SUMMER = "Ah, you have fattened up nicely!",
		KOALEFANT_WINTER = "You can't get attached to cute cuts of meat.",
		KRAMPUS = "What the devil!",
		KRAMPUS_SACK = "Infinite pocket space!",
		LANTERN = "It is my night light.",
		LAVAARENA_ARMOREXTRAHEAVY = "PLACEHOLDER",
		LAVAARENA_ARMORHEAVY = "PLACEHOLDER",
		LAVAARENA_ARMORLIGHT = "PLACEHOLDER",
		LAVAARENA_ARMORLIGHTSPEED = "PLACEHOLDER",
		LAVAARENA_ARMORMEDIUM = "PLACEHOLDER",
		LAVAARENA_ARMORMEDIUMDAMAGER = "PLACEHOLDER",
		LAVAARENA_ARMORMEDIUMRECHARGER = "PLACEHOLDER",
		LAVAARENA_ARMOR_HP = "PLACEHOLDER",
		LAVAARENA_BATTLESTANDARD = "PLACEHOLDER",
		LAVAARENA_BERNIE = "PLACEHOLDER",
		LAVAARENA_BOARLORD = "PLACEHOLDER",
		LAVAARENA_CROWNDAMAGERHAT = "PLACEHOLDER",
		LAVAARENA_ELEMENTAL = "PLACEHOLDER",
		LAVAARENA_EYECIRCLETHAT = "PLACEHOLDER",
		LAVAARENA_FEATHERCROWNHAT = "PLACEHOLDER",
		LAVAARENA_FIREBOMB = "PLACEHOLDER",
		LAVAARENA_HEALINGFLOWERHAT = "PLACEHOLDER",
		LAVAARENA_HEALINGGARLANDHAT = "PLACEHOLDER",
		LAVAARENA_HEAVYBLADE = "PLACEHOLDER",
		LAVAARENA_KEYHOLE = "That's our way back.",
		LAVAARENA_KEYHOLE_FULL = "Time to leave, oui?",
		LAVAARENA_LIGHTDAMAGERHAT = "PLACEHOLDER",
		LAVAARENA_LUCY = "Lucy looks a little different, non?",
		LAVAARENA_PORTAL = 
		{
			GENERIC = "PLACEHOLDER",
			ON = "PLACEHOLDER",
		},
		LAVAARENA_RECHARGERHAT = "PLACEHOLDER",
		LAVAARENA_SPAWNER = "PLACEHOLDER",
		LAVAARENA_STRONGDAMAGERHAT = "PLACEHOLDER",
		LAVAARENA_TIARAFLOWERPETALSHAT = "PLACEHOLDER",
		LAVAE = "You're a pretty cute little sausage link.",
		LAVAE_COCOON = "Yuck. I should wash my hands before I prepare food.",
		LAVAE_EGG = 
		{
			GENERIC = "Is its flavor profile comparable to a regular egg?",
		},
		LAVAE_EGG_CRACKED = 
		{
			COLD = "Are you chilly, ma petite choux-fleur?",
			COMFY = "Nice and cozy.",
		},
		LAVAE_PET = 
		{
			CONTENT = "Happy as a deliciously seasoned clam.",
			GENERIC = "She's a fiery little one.",
			HUNGRY = "You are hungry, non? Let me whip something up.",
			STARVING = "I should cook something for her, fast!",
		},
		LAVAE_TOOTH = "It came off my petite fiery friend.",
		LAVASPIT = 
		{
			COOL = "The top has cooled like a barfy crème brûlée!",
			HOT = "A chef-cuisinier never burns his fingers.",
		},
		LAVA_POND = "That looks a little toasty.",
		LAVA_POND_ROCK = "Looks like a rock to me.",
		LEIF = "I'm out of my element!",
		LEIF_SPARSE = "I'm out of my element!",
		LICHEN = "Really scraping the barrel for produce here.",
		LIFEINJECTOR = "It's not so bad, if you close your eyes.",
		LIGHTBULB = "Looks like candy.",
		LIGHTER = "This is Willow's.",
		LIGHTNINGGOAT = 
		{
			CHARGED = "Goat milkshake!",
			GENERIC = "I had a goat once.",
		},
		LIGHTNINGGOATHORN = "For kabobs, perhaps?",
		LIGHTNING_ROD = 
		{
			CHARGED = "Electricity!",
			GENERIC = "I do feel a bit safer now.",
		},
		LITTLE_WALRUS = "Oh, there's a little one!",
		LIVINGLOG = "Magic building blocks!",
		LIVINGTREE = "Tres suspicious...",
		LIVINGTREE_ROOT = "Edible roots, perhaps?",
		LIVINGTREE_SAPLING = "Just a petite bébé.",
		LOG = 
		{
			BURNING = "Soon it won't be good for much.",
			GENERIC = "An important aspect of my art.",
		},
		LUCKY_GOLDNUGGET = "It's nice to have a bit of luck.",
		LUCY = "Bonjour, mademoiselle.",
		LUMPY_SAPLING = "Just a petite bébé.",
		LUREPLANT = "How alluring.",
		LUREPLANTBULB = "Growing meat from the ground? Now I've seen it all...",
		MADSCIENCE_LAB = "Chemistry is just fancy cooking, non?",
		MALE_PUPPET = "Free him!",
		MANDRAKE = 
		{
			DEAD = "I should like to get to the root of this mystery...",
			GENERIC = "Have I discovered a new root vegetable?!",
			PICKED = "Do not pick! Do not pick!",
		},
		MANDRAKESOUP = "What an otherworldly flavor!",
		MANDRAKE_ACTIVE = "How chatty you are, hm, bébé?",
		MANDRAKE_COOKED = "Could use... an explanation...",
		MANDRAKE_PLANTED = "I could always use more fresh veg.",
		MANRABBIT_TAIL = "The texture is exceptionally comforting.",
		MAPSCROLL = "A blank map. Full of potential.",
		MARBLE = "Would make a nice counter top.",
		MARBLEBEAN = "I don't think this bean is edible.",
		MARBLEBEAN_SAPLING = "Just a petite marble bébé.",
		MARBLEPILLAR = "I wonder how many counter tops I could get out of this...",
		MARBLESHRUB = "If marble beans can grow, maybe they can be eaten.",
		MARBLETREE = "How supremely unnatural!",
		MARSH_BUSH = 
		{
			BURNING = "It burns like any other bush.",
			GENERIC = "A prickly customer.",
			PICKED = "Not sure I want to do that again.",
		},
		MARSH_PLANT = "I wonder if it is edible.",
		MARSH_TREE = 
		{
			BURNING = "You will not be missed.",
			BURNT = "The wood gives off a unique aroma when burned.",
			CHOPPED = "There. Now you cannot prick anyone.",
			GENERIC = "I am ever so glad I'm not a tree hugger.",
		},
		MAXWELL = "You! You... villain!",
		MAXWELLHEAD = "He must eat massive sandwiches.",
		MAXWELLLIGHT = "A light is always welcome.",
		MAXWELLLOCK = "But where is the key?",
		MAXWELLPHONOGRAPH = "I wonder what is in his record collection?",
		MAXWELLTHRONE = "Heavy is the bum that sits on the throne...",
		MEAT = "I must remember to cut across the grain.",
		MEATBALLS = "I'm having a ball!",
		MEATRACK = 
		{
			BURNT = "Too dry! Too dry!",
			DONE = "Ready to test on my teeth!",
			DRYING = "Not quite dry enough.",
			DRYINGINRAIN = "Now it is more like a rehydrating rack...",
			GENERIC = "Just like the chefs of the stone age!",
		},
		MEAT_DRIED = "Could use chipotle...",
		MERM = "Fishmongers!",
		MERMHEAD = 
		{
			BURNT = "I think it needs to burned again! Pee-eew!",
			GENERIC = "Its odor is not improving with time...",
		},
		MERMHOUSE = 
		{
			BURNT = "That fire got the smell out.",
			GENERIC = "Fisherfolk live here. I can smell it.",
		},
		MIGRATION_PORTAL = 
		{
			FULL = "It's a little crowded for my taste.",
			GENERIC = "I think I'd like the company.",
			OPEN = "It's ready, if I wish to go.",
		},
		MINERHAT = "Aha! Now that is using my head!",
		MINIFAN = "Like a cool ocean breeze.",
		MINISIGN = 
		{
			GENERIC = "Too small for a restaurant sign.",
			UNDRAWN = "I could draw the specials on there.",
		},
		MINISIGN_ITEM = "This would be better off in the ground.",
		MINOTAUR = "Stay away!",
		MINOTAURCHEST = "I appreciate the attention to its aesthetic detail.",
		MINOTAURHORN = "I wonder, if ground up into a powder...",
		MOLE = 
		{
			ABOVEGROUND = "Are you spying on me?",
			HELD = "Do you \"dig\" your new surroundings?",
			UNDERGROUND = "Something dwells beneath.",
		},
		MOLEHAT = "Neat vision!",
		MOLEHILL = "It is a nice hill, but I won't make a mountain of it.",
		MONKEY = "A new species of irritation.",
		MONKEYBARREL = "An absolute madhouse.",
		MONSTERLASAGNA = "What a wasted effort...",
		MONSTERMEAT = "Hmmm, nice marbling...",
		MONSTERMEAT_DRIED = "Could use... better judgment...",
		MOONBASE = 
		{
			BROKEN = "My mechanical friend seems intent on fixing it.",
			GENERIC = "What goes in the middle, I wonder?",
			MOONSTAFF = "That looks ripe for the taking.",
			STAFFED = "I thought something would have happened.",
			WRONGSTAFF = "I think it wants something else.",
		},
		MOONDIAL = 
		{
			CAVE = "It doesn't seem very useful down here.",
			GENERIC = "I hope the birds get to enjoy it, too.",
			NIGHT_FULL = "The full moon's arrived.",
			NIGHT_NEW = "The new moon's arrive.",
			NIGHT_WANE = "The moon is waning.",
			NIGHT_WAX = "The moon is waxing.",
		},
		MOONROCKCRATER = "An eye without an iris.",
		MOONROCKIDOL = "It's very enchanting.",
		MOONROCKNUGGET = "A little piece of sky to hold in my hand.",
		MOONROCKSEED = "It's beautiful, isn't it?",
		MOONROCK_PIECES = "I think it's breakable.",
		MOOSE = "I wish you were a bit less moose-y and a lot more goose-y!",
		MOOSEEGG = "I think I'll leave this egg quite alone!",
		MOOSE_NESTING_GROUND = "Imagine how many omelets I could make with one of those eggs.",
		MOSQUITO = 
		{
			GENERIC = "We disagree on where my blood is best used.",
			HELD = "I do not care to be this close to it! Vile!",
		},
		MOSQUITOSACK = "Ugh! It can only be filled with one thing.",
		MOSSLING = "Looking for your momma? Apologies, but I hope you do not find her.",
		MOUND = 
		{
			DUG = "What have I become?",
			GENERIC = "I cannot help wondering what might be down there.",
		},
		MULTIPLAYER_PORTAL = "Is anyone else coming for dinner?",
		MULTIPLAYER_PORTAL_MOONROCK = "It seems dangerous, but it's oddly calming.",
		MULTITOOL_AXE_PICKAXE = "Oh, I get it! Kind of like a spork!",
		MUSHROOMBOMB = "We should get far away from that.",
		MUSHROOMHAT = "Wearing mushrooms is the next best thing to eating them.",
		MUSHROOMSPROUT = 
		{
			BURNT = "Mmm, smells like fried mushrooms.",
			GENERIC = "I wonder if it's edible.",
		},
		MUSHROOM_FARM = 
		{
			BURNT = "Mmm, smells like fried mushrooms.",
			EMPTY = "I could grow some fresh mushrooms here.",
			LOTS = "It's nice not to have to forage for the basics.",
			ROTTEN = "I'll need to find a replacement if I want fresh mushrooms.",
			SNOWCOVERED = "Mushrooms are out of season right now.",
			SOME = "Oh, my mushrooms are beginning to grow!",
			STUFFED = "My days of wild mushroom hunting are over!",
		},
		MUSHROOM_LIGHT = 
		{
			BURNT = "Mmm, smells like fried mushrooms.",
			OFF = "Sometimes, you need a break.",
			ON = "I do like being able to see.",
		},
		MUSHROOM_LIGHT2 = 
		{
			BURNT = "Mmm, smells like fried mushrooms.",
			OFF = "Sometimes, you need a break.",
			ON = "I like a nice pale blue, personally.",
		},
		MUSHTREE_MEDIUM = 
		{
			BLOOM = "What an un-delicious stench!",
			GENERIC = "Fresh ingredients, ripe for the taking.",
		},
		MUSHTREE_SMALL = 
		{
			BLOOM = "What an un-delicious stench!",
			GENERIC = "I can't wait to harvest it.",
		},
		MUSHTREE_TALL = 
		{
			BLOOM = "What an un-delicious stench!",
			GENERIC = "There's simply no reason for it to be that big.",
		},
		MUSHTREE_TALL_WEBBED = "I hope I don't run into any spiders.",
		NIGHTLIGHT = "And I thought fluorescent tubes were a bad invention!",
		NIGHTMAREFUEL = "Who in their right mind would want to fuel MORE nightmares?",
		NIGHTMARELIGHT = "Am I crazy or is this light not helping my situation?",
		NIGHTMARE_TIMEPIECE = 
		{
			CALM = "It appears that all is well.",
			DAWN = "This nightmare is almost over!",
			NOMAGIC = "Magicless.",
			STEADY = "Steady on.",
			WANING = "Subsiding.",
			WARN = "I feel some magic coming on!",
			WAXING = "Magic hour!",
		},
		NIGHTSTICK = "I feel electric!",
		NIGHTSWORD = "This thing slices like a dream!",
		NITRE = "How curious.",
		OASISLAKE = "I could use a little break.",
		ONEMANBAND = "What a racket!",
		OPALPRECIOUSGEM = "It glimmers like maman's eyes.",
		OPALSTAFF = "It makes me feel magical.",
		ORANGEAMULET = "Here one minute, gone the next!",
		ORANGEGEM = "I miss oranges...",
		ORANGEMOONEYE = "This eye will keep an eye on things.",
		ORANGESTAFF = "When I hold it it makes the world feel... fast.",
		PANDORASCHEST = "It's quite magnificent.",
		PANFLUTE = "This will be music to something's ears.",
		PAPYRUS = "I could write down my recipes on this.",
		PEGHOOK = "Not a very polite gentleman.",
		PENGUIN = "A cool customer.",
		PERD = "A fellow with excellent taste.",
		PERDFAN = "Would anyone like me to cool them down?",
		PERDSHRINE = 
		{
			BURNT = "Overcooked.",
			EMPTY = "I should give it something special.",
			GENERIC = "I should show some appreciation. I've eaten a lot of turkey legs.",
		},
		PEROGIES = "Mmmmm, pockets of palate punching pleasure!",
		PETALS = "Great in salads.",
		PETALS_EVIL = "Not so great in salads.",
		PETRIFIED_TREE = "This tree is made of stone.",
		PHLEGM = "Ugh. Not food safe!",
		PICKAXE = "For those tough to crack nuts.",
		PIGGUARD = "What are you guarding, besides your own deliciousness?",
		PIGGYBACK = "Cochon bag!",
		PIGHEAD = 
		{
			BURNT = "Not even the cheeks are left...",
			GENERIC = "Ooh la la, the things I could do with you!",
		},
		PIGHOUSE = 
		{
			BURNT = "Mmmm, barbecue!",
			FULL = "Looks like more than three little piggies in there.",
			GENERIC = "Can I blow this down?",
			LIGHTSOUT = "Yoo hoo! Anybody home?",
		},
		PIGKING = "Well, you've got the chops for it.",
		PIGMAN = 
		{
			DEAD = "He wouldn't want himself to go to waste, would he?",
			FOLLOWER = "I do have a magnetic presence, do I not?",
			GENERIC = "Who bred you to walk upright like that? Deuced unsettling...",
			GUARD = "Alright, alright, moving along.",
			WEREPIG = "Aggression spoils the meat.",
		},
		PIGSHRINE = 
		{
			BURNT = "It spent a second too long in the oven.",
			EMPTY = "I think I should give it a gift.",
			GENERIC = "I should show my appreciation for delicious, tender pork.",
		},
		PIGSKIN = "Crackling!",
		PIGTENT = "Sure to deliver sweet dreams.",
		PIGTORCH = "I wonder what it means?",
		PIG_TOKEN = "I'll try not to spend it all in one place.",
		PINECONE = 
		{
			GENERIC = "Pine-scented!",
			PLANTED = "One day you'll be a tree.",
		},
		PINECONE_SAPLING = "Just a petite bébé.",
		PITCHFORK = "Proper farm gear.",
		PLANTMEAT = "Meaty leaves? I'm so confused...",
		PLANTMEAT_COOKED = "Could use less oxymorons...",
		PLANT_NORMAL = 
		{
			GENERIC = "The miracle of life!",
			GROWING = "That is it, just a little more...",
			READY = "Fresh-picked produce!",
			WITHERED = "Oh dear me, the crop has failed...",
		},
		PLAYER = 
		{
			ATTACKER = "Let's all calm down with a nice bowl of soup.",
			FIRESTARTER = "I don't want to nitpick how you light fires, but...",
			GENERIC = "Bonjour, %s!",
			GHOST = "Oh my. Does that hurt?",
			MURDERER = "Mon dieu! You're a murderer!",
			REVIVER = "You've been a big help, %s.",
		},
		POMEGRANATE = "Wonderful!",
		POMEGRANATE_COOKED = "Could use tahini and mint...",
		POMEGRANATE_SEEDS = "Seedy seeds!",
		POND = "I can't see the bottom...",
		POND_ALGAE = "I can't see the bottom...",
		POOP = "The end result of a fine meal.",
		POTTEDFERN = "Nature. Tamed.",
		POWCAKE = "I would not feed this to my worst enemies. Or would I...",
		PUMPKIN = "I'm the pumpking of the world!",
		PUMPKINCOOKIE = "I've outdone myself this time.",
		PUMPKIN_COOKED = "Could use some pie crust and nutmeg...",
		PUMPKIN_LANTERN = "Trick 'r' neat!",
		PUMPKIN_SEEDS = "Seed saver!",
		PURPLEAMULET = "I must be crazy to fool around with this.",
		PURPLEGEM = "It holds deep secrets.",
		PURPLEMOONEYE = "It's a purple stone eye.",
		QUAGMIRE_ALTAR = 
		{
			FULL = "PLACEHOLDER",
			GENERIC = "PLACEHOLDER",
		},
		QUAGMIRE_ALTAR_BOLLARD = "PLACEHOLDER",
		QUAGMIRE_ALTAR_IVY = "PLACEHOLDER",
		QUAGMIRE_ALTAR_QUEEN = "PLACEHOLDER",
		QUAGMIRE_ALTAR_STATUE1 = "PLACEHOLDER",
		QUAGMIRE_ALTAR_STATUE2 = "PLACEHOLDER",
		QUAGMIRE_BEEFALO = "PLACEHOLDER",
		QUAGMIRE_BERRYBUSH = "PLACEHOLDER",
		QUAGMIRE_BOWL_SILVER = "PLACEHOLDER",
		QUAGMIRE_CARROT_SEEDS = "PLACEHOLDER",
		QUAGMIRE_CASSEROLEDISH = "PLACEHOLDER",
		QUAGMIRE_CASSEROLEDISH_SMALL = "PLACEHOLDER",
		QUAGMIRE_COIN1 = "PLACEHOLDER",
		QUAGMIRE_COIN2 = "PLACEHOLDER",
		QUAGMIRE_COIN3 = "PLACEHOLDER",
		QUAGMIRE_COIN4 = "PLACEHOLDER",
		QUAGMIRE_CRABMEAT = "PLACEHOLDER",
		QUAGMIRE_CRABMEAT_COOKED = "PLACEHOLDER",
		QUAGMIRE_CRABTRAP = "PLACEHOLDER",
		QUAGMIRE_CRATE = "PLACEHOLDER",
		QUAGMIRE_FERN = "PLACEHOLDER",
		QUAGMIRE_FLOUR = "PLACEHOLDER",
		QUAGMIRE_FOLIAGE_COOKED = "PLACEHOLDER",
		QUAGMIRE_FOOD = 
		{
			GENERIC = "PLACEHOLDER",
			MATCH = "PLACEHOLDER",
			MATCH_BUT_SNACK = "PLACEHOLDER",
			MISMATCH = "PLACEHOLDER",
		},
		QUAGMIRE_FOOD_BURNT = "PLACEHOLDER",
		QUAGMIRE_GARLIC = "PLACEHOLDER",
		QUAGMIRE_GARLIC_COOKED = "PLACEHOLDER",
		QUAGMIRE_GARLIC_SEEDS = "PLACEHOLDER",
		QUAGMIRE_GOATKID = "PLACEHOLDER",
		QUAGMIRE_GOATMILK = "PLACEHOLDER",
		QUAGMIRE_GOATMUM = "PLACEHOLDER",
		QUAGMIRE_GRILL = "PLACEHOLDER",
		QUAGMIRE_GRILL_ITEM = "PLACEHOLDER",
		QUAGMIRE_GRILL_SMALL = "PLACEHOLDER",
		QUAGMIRE_GRILL_SMALL_ITEM = "PLACEHOLDER",
		QUAGMIRE_HOE = "PLACEHOLDER",
		QUAGMIRE_KEY = "PLACEHOLDER",
		QUAGMIRE_KEY_PARK = "PLACEHOLDER",
		QUAGMIRE_LAMP_POST = "PLACEHOLDER",
		QUAGMIRE_LAMP_SHORT = "PLACEHOLDER",
		QUAGMIRE_MEALINGSTONE = "PLACEHOLDER",
		QUAGMIRE_MERMHOUSE = "PLACEHOLDER",
		QUAGMIRE_MERM_CART1 = "PLACEHOLDER",
		QUAGMIRE_MERM_CART2 = "PLACEHOLDER",
		QUAGMIRE_MUSHROOMS = "PLACEHOLDER",
		QUAGMIRE_MUSHROOMSTUMP = 
		{
			GENERIC = "PLACEHOLDER",
			PICKED = "PLACEHOLDER",
		},
		QUAGMIRE_ONION = "PLACEHOLDER",
		QUAGMIRE_ONION_COOKED = "PLACEHOLDER",
		QUAGMIRE_ONION_SEEDS = "PLACEHOLDER",
		QUAGMIRE_OVEN = "PLACEHOLDER",
		QUAGMIRE_OVEN_ITEM = "PLACEHOLDER",
		QUAGMIRE_PARKSPIKE = "PLACEHOLDER",
		QUAGMIRE_PARK_ANGEL = "PLACEHOLDER",
		QUAGMIRE_PARK_ANGEL2 = "PLACEHOLDER",
		QUAGMIRE_PARK_FOUNTAIN = "PLACEHOLDER",
		QUAGMIRE_PARK_GATE = 
		{
			GENERIC = "PLACEHOLDER",
			LOCKED = "PLACEHOLDER",
		},
		QUAGMIRE_PARK_OBELISK = "PLACEHOLDER",
		QUAGMIRE_PARK_URN = "PLACEHOLDER",
		QUAGMIRE_PEBBLECRAB = "PLACEHOLDER",
		QUAGMIRE_PIGEON = 
		{
			DEAD = "PLACEHOLDER",
			GENERIC = "PLACEHOLDER",
			SLEEPING = "Bonne nuit.",
		},
		QUAGMIRE_PLATE_SILVER = "PLACEHOLDER",
		QUAGMIRE_POND_SALT = "PLACEHOLDER",
		QUAGMIRE_PORTAL = "PLACEHOLDER",
		QUAGMIRE_PORTAL_KEY = "PLACEHOLDER",
		QUAGMIRE_POT = "PLACEHOLDER",
		QUAGMIRE_POTATO = "PLACEHOLDER",
		QUAGMIRE_POTATO_COOKED = "PLACEHOLDER",
		QUAGMIRE_POTATO_SEEDS = "PLACEHOLDER",
		QUAGMIRE_POT_HANGER = "PLACEHOLDER",
		QUAGMIRE_POT_HANGER_ITEM = "PLACEHOLDER",
		QUAGMIRE_POT_SMALL = "PLACEHOLDER",
		QUAGMIRE_POT_SYRUP = "PLACEHOLDER",
		QUAGMIRE_ROTTEN_CROP = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_BIKE = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_CARRIAGE = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_CATHEDRAL = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_CHIMNEY = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_CHIMNEY2 = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_CLOCK = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_CLOCKTOWER = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_HOUSE = 
		{
			"PLACEHOLDER",
			"PLACEHOLDER",
			"PLACEHOLDER",
		},
		QUAGMIRE_RUBBLE_PUBDOOR = "PLACEHOLDER",
		QUAGMIRE_RUBBLE_ROOF = "PLACEHOLDER",
		QUAGMIRE_SAFE = 
		{
			GENERIC = "PLACEHOLDER",
			LOCKED = "PLACEHOLDER",
		},
		QUAGMIRE_SALMON = "PLACEHOLDER",
		QUAGMIRE_SALMON_COOKED = "PLACEHOLDER",
		QUAGMIRE_SALT = "PLACEHOLDER",
		QUAGMIRE_SALTROCK = "PLACEHOLDER",
		QUAGMIRE_SALT_RACK = 
		{
			GENERIC = "PLACEHOLDER",
			READY = "PLACEHOLDER",
		},
		QUAGMIRE_SALT_RACK_ITEM = "PLACEHOLDER",
		QUAGMIRE_SAP = "PLACEHOLDER",
		QUAGMIRE_SAPBUCKET = "PLACEHOLDER",
		QUAGMIRE_SAPLING = "PLACEHOLDER",
		QUAGMIRE_SAP_SPOILED = "PLACEHOLDER",
		QUAGMIRE_SEEDPACKET = "PLACEHOLDER",
		QUAGMIRE_SLAUGHTERTOOL = "PLACEHOLDER",
		QUAGMIRE_SPOTSPICE_GROUND = "PLACEHOLDER",
		QUAGMIRE_SPOTSPICE_SHRUB = 
		{
			GENERIC = "PLACEHOLDER",
			PICKED = "PLACEHOLDER",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "PLACEHOLDER",
		QUAGMIRE_SUGARWOODTREE = 
		{
			GENERIC = "PLACEHOLDER",
			STUMP = "PLACEHOLDER",
			TAPPED_BUGS = "PLACEHOLDER",
			TAPPED_EMPTY = "PLACEHOLDER",
			TAPPED_READY = "PLACEHOLDER",
			WOUNDED = "PLACEHOLDER",
		},
		QUAGMIRE_SWAMPIG = "PLACEHOLDER",
		QUAGMIRE_SWAMPIGELDER = 
		{
			GENERIC = "PLACEHOLDER",
			SLEEPING = "Bonne nuit. Feel better soon.",
		},
		QUAGMIRE_SWAMPIG_HOUSE = "PLACEHOLDER",
		QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "PLACEHOLDER",
		QUAGMIRE_SYRUP = "PLACEHOLDER",
		QUAGMIRE_TOMATO = "PLACEHOLDER",
		QUAGMIRE_TOMATO_COOKED = "PLACEHOLDER",
		QUAGMIRE_TOMATO_SEEDS = "PLACEHOLDER",
		QUAGMIRE_TRADER_MERM = "PLACEHOLDER",
		QUAGMIRE_TRADER_MERM2 = "PLACEHOLDER",
		QUAGMIRE_TURNIP = "PLACEHOLDER",
		QUAGMIRE_TURNIP_COOKED = "PLACEHOLDER",
		QUAGMIRE_TURNIP_SEEDS = "PLACEHOLDER",
		QUAGMIRE_WHEAT = "PLACEHOLDER",
		QUAGMIRE_WHEAT_SEEDS = "PLACEHOLDER",
		RABBIT = 
		{
			GENERIC = "I haven't had rabbit in awhile...",
			HELD = "Your little heart is beating so fast.",
		},
		RABBITHOLE = 
		{
			GENERIC = "Thump twice if you are fat and juicy.",
			SPRING = "What a pity rabbit season has ended.",
		},
		RABBITHOUSE = 
		{
			BURNT = "That was no carrot!",
			GENERIC = "Do my eyes deceive me?",
		},
		RAINCOAT = "For a foggy Paris evening.",
		RAINHAT = "Better than a newspaper.",
		RAINOMETER = 
		{
			BURNT = "It measures nothing now...",
			GENERIC = "It measures moisture in the clouds.",
		},
		RATATOUILLE = "A veritable village of vegetables!",
		RAZOR = "If only I had aftershave.",
		REDGEM = "A deep fire burns within.",
		REDLANTERN = "I do like festivals like this.",
		REDMOONEYE = "It looks a bit like an eye with a gem inside, non?",
		REDPOUCH = "How nice it is to have luck on my side!",
		RED_CAP = "Could use cream and salt... And less poison.",
		RED_CAP_COOKED = "Perhaps I could make a good soup.",
		RED_MUSHROOM = 
		{
			GENERIC = "Can't get fresher than that!",
			INGROUND = "It'll be hard to harvest like that.",
			PICKED = "There's nothing left.",
		},
		REEDS = 
		{
			BURNING = "The fire took to those quite nicely.",
			GENERIC = "A small clump of reeds.",
			PICKED = "There's nothing left to pick.",
		},
		REFLECTIVEVEST = "Well, it should be hard to lose.",
		RELIC = 
		{
			BROKEN = "A piece of culinary history has been lost.",
			GENERIC = "Ancient kitchenware.",
		},
		RESEARCHLAB = 
		{
			BURNT = "That didn't cook very well.",
			GENERIC = "A center for learning.",
		},
		RESEARCHLAB2 = 
		{
			BURNT = "The fire seemed to find it quite tasty.",
			GENERIC = "Oh, the things I'll learn!",
		},
		RESEARCHLAB3 = 
		{
			BURNT = "The darkness is all burnt up.",
			GENERIC = "It boggles the mind.",
		},
		RESEARCHLAB4 = 
		{
			BURNT = "Nothing but ashes.",
			GENERIC = "I won't even try to pronounce it...",
		},
		RESURRECTIONSTATUE = 
		{
			BURNT = "It won't be much good now.",
			GENERIC = "Part of my soul is within.",
		},
		RESURRECTIONSTONE = "Looks like some sort of ritual stone.",
		REVIVER = "I don't like that it's still beating.",
		RHINODRILL = "Can't we just talk?",
		ROBIN = 
		{
			GENERIC = "Good afternoon, sir or madam!",
			HELD = "It's soft, and surprisingly calm.",
		},
		ROBIN_WINTER = 
		{
			GENERIC = "This little fellow seems quite frigid.",
			HELD = "Let me lend you my warmth, feathered friend.",
		},
		ROBOT_PUPPET = "Surely no one deserves such treatment!",
		ROCK = "Don't you go rolling off on me.",
		ROCKS = "Bite-sized boulders.",
		ROCKY = "Hmm... I would have to be careful to not chip a tooth.",
		ROCK_ICE = 
		{
			GENERIC = "Brr!",
			MELTED = "It's just liquid now.",
		},
		ROCK_ICE_MELTED = "It's just liquid now.",
		ROCK_LIGHT = 
		{
			GENERIC = "The lava has crusted over.",
			LOW = "Like a pie on a proverbial windowsill, it will soon cool.",
			NORMAL = "Nature's fiery fondue pot.",
			OUT = "It has no heat left to give.",
		},
		ROCK_MOON = "It has a very peaceful energy.",
		ROCK_PETRIFIED_TREE = "Did someone sculpt that?",
		ROCK_PETRIFIED_TREE_OLD = "Did someone sculpt that?",
		ROOK = "What a rude contraption.",
		ROOK_NIGHTMARE = "What a monstrosity!",
		ROPE = "A bit too thick to tie up a roast.",
		ROTTENEGG = "Pee-eew!",
		ROYAL_JELLY = "I feel inspired to try my hand at confections!",
		RUBBLE = "Delicious destruction.",
		RUINSHAT = "Seems unnecessarily fancy.",
		RUINS_BAT = "I could tenderize some meat with this.",
		RUINS_RUBBLE = "Delicious destruction.",
		SACRED_CHEST = 
		{
			GENERIC = "Now to add the final ingredients.",
			LOCKED = "Have I not been found worthy?",
		},
		SADDLEHORN = "It's like a spatula for a saddle.",
		SADDLE_BASIC = "Let's see if I can ride on this.",
		SADDLE_RACE = "Adds a little spice to my ride.",
		SADDLE_WAR = "Durable.",
		SALTLICK = "Too salty.",
		SANDBLOCK = "Very thick sand.",
		SANDSPIKE = "Watch yourself, it's quite sharp.",
		SANITYROCK = 
		{
			ACTIVE = "It's tugging on my mind.",
			INACTIVE = "The darkness lurks within.",
		},
		SAPLING = 
		{
			BURNING = "Those burn quite dramatically.",
			DISEASED = "Would some nice soup make you feel better?",
			DISEASING = "It's coming down with something.",
			GENERIC = "Those could be key to my continued survival.",
			PICKED = "There is nothing left for me to grasp!",
			WITHERED = "It could use some love.",
		},
		SCARECROW = 
		{
			BURNING = "What a tragedy.",
			BURNT = "Overcooked.",
			GENERIC = "He seems nice.",
		},
		SCORCHED_SKELETON = "A kitchen mishap, maybe?",
		SCULPTINGTABLE = 
		{
			BLOCK = "Ready for the chisel.",
			BURNT = "Overcooked.",
			EMPTY = "Just need some stone to get cooking.",
			SCULPTURE = "Someone's a very talented artist.",
		},
		SCULPTURE_BISHOPBODY = 
		{
			COVERED = "Some old, worn stone.",
			FINISHED = "It looks much better.",
			READY = "I think... it's stirring!",
			UNCOVERED = "It looks incomplete.",
		},
		SCULPTURE_BISHOPHEAD = "I think it was part of a statue.",
		SCULPTURE_KNIGHTBODY = 
		{
			COVERED = "What an odd shape for a rock.",
			FINISHED = "Well, it's fixed now.",
			READY = "I think... it's stirring!",
			UNCOVERED = "It's looking for its missing piece.",
		},
		SCULPTURE_KNIGHTHEAD = "Looks like it came off a sculpture somewhere.",
		SCULPTURE_ROOKBODY = 
		{
			COVERED = "Parts of it look like they were sculpted.",
			FINISHED = "That looks nice.",
			READY = "I think... it's stirring!",
			UNCOVERED = "Where is your nose?",
		},
		SCULPTURE_ROOKNOSE = "That doesn't look like a natural rock.",
		SEEDS = "You may grow up to be delicious one day.",
		SEEDS_COOKED = "Could use smoked paprika...",
		SENTRYWARD = "It's watching over us.",
		SEWING_KIT = "Not exactly my specialty.",
		SEWING_TAPE = "Winona is really very resourceful.",
		SHADOWDIGGER = "Oh, how odd.",
		SHADOWHEART = "That beef heart is almost certainly past its prime.",
		SHOVEL = "I'm not the landscaping type.",
		SHROOM_SKIN = "Oh dear. I'm not sure I like that.",
		SIESTAHUT = 
		{
			BURNT = "Overcooked.",
			GENERIC = "Comes in handy after a big lunch.",
		},
		SILK = "Is that sanitary?",
		SKELETON = "I have a bone to pick with you.",
		SKELETONHAT = "Un chapeau effrayant.",
		SKELETON_PLAYER = 
		{
			DEFAULT = "Poor %s was overcome by %s.",
			FEMALE = "Poor %s was overcome by %s.",
			MALE = "Poor %s was overcome by %s.",
			ROBOT = "Poor %s was overcome by %s.",
		},
		SKETCH = "Oh! I could sculpt something based off this.",
		SKULLCHEST = "What an ominous container.",
		SLEEPBOMB = "Bonne nuit, everybody.",
		SLURPER = "It is not polite to slurp.",
		SLURPERPELT = "Wear this? What in heavens for?",
		SLURPER_PELT = "Wear this? What in heavens for?",
		SLURTLE = "You would flavor a soup nicely. Your shell could be the bowl!",
		SLURTLEHAT = "Be the snail.",
		SLURTLEHOLE = "Yuck!",
		SLURTLESLIME = "Nature giveth, and nature grosseth.",
		SLURTLE_SHELLPIECES = "If only I had crazy glue.",
		SMALLBIRD = 
		{
			GENERIC = "Hello food... uh, friend.",
			HUNGRY = "I suppose I could whip something up for you.",
			STARVING = "You look famished!",
		},
		SMALLMEAT = "Fresh protein!",
		SMALLMEAT_DRIED = "Could use a teriyaki glaze...",
		SNAPPER = "Please don't take any bites out of me.",
		SNURTLE = "Escar-goodness gracious!",
		SPAT = "I do enjoy a good mutton.",
		SPEAR = "For kebab-ing.",
		SPEAR_GUNGNIR = "That's just a big skewer.",
		SPEAR_LANCE = "Maybe I could make kabobs?",
		SPEAR_WATHGRITHR = "I'm better with a spatula.",
		SPIDER = 
		{
			DEAD = "Please no rain!",
			GENERIC = "You are not for eating.",
			SLEEPING = "It should make itself a silk pillow.",
		},
		SPIDERDEN = "A spider has to live somewhere, I suppose.",
		SPIDEREGGSACK = "This is probably a delicacy somewhere.",
		SPIDERGLAND = "Alternative medicine.",
		SPIDERHAT = "Well, it is on my head now. Best make the most of it.",
		SPIDERHOLE = "I have no reason to investigate any further.",
		SPIDERHOLE_ROCK = "I'd prefer not to get closer.",
		SPIDERQUEEN = "I will not bend the knee to the likes of you!",
		SPIDER_DROPPER = "Ah, the old \"drop from the ceiling and commit violent acts\" act.",
		SPIDER_HIDER = "A spider that turtles!",
		SPIDER_SPITTER = "So many spiders!",
		SPIDER_WARRIOR = 
		{
			DEAD = "It knew the risks.",
			GENERIC = "Does this mean you are even more warlike than the others?",
			SLEEPING = "It is having a flashback to the spider war...",
		},
		SPOILED_FOOD = "It is a sin to waste food...",
		SPORE_MEDIUM = 
		{
			GENERIC = "Something that pretty must taste good, right?",
			HELD = "How precious.",
		},
		SPORE_SMALL = 
		{
			GENERIC = "It looks like floating candy.",
			HELD = "How precious.",
		},
		SPORE_TALL = 
		{
			GENERIC = "I can't believe mushrooms made something so pretty.",
			HELD = "How precious.",
		},
		STAFFCOLDLIGHT = "I appreciate it on sweltering afternoons.",
		STAFFLIGHT = "Too much power to hold in one hand.",
		STAFF_TORNADO = "Does nature like being tamed?",
		STAGEHAND = 
		{
			AWAKE = "I've got to hand it to you, I was startled!",
			HIDING = "Oh, what a nice table setting.",
		},
		STALAGMITE = "I always get you upside down with stalactites...",
		STALAGMITE_TALL = "Rocks to be had.",
		STALKER = "We should have left it sleeping!",
		STALKER_ATRIUM = "This won't be an easy fight.",
		STALKER_MINION = "What creeps!",
		STATUEGLOMMER = 
		{
			EMPTY = "Oops.",
			GENERIC = "Must have been a pretty important, uh, thingy...",
		},
		STATUEHARP = "Headless harpsmen.",
		STATUEMAXWELL = "He is literally made of stone.",
		STATUE_MARBLE = 
		{
			GENERIC = "A lovely marble statue.",
			TYPE1 = "Well, as they say, if it ain't baroque!",
			TYPE2 = "She seems regal.",
		},
		STEELWOOL = "I used to use this to scrub dishes.",
		STINGER = "It would really sting to not have a use for this.",
		STRAWHAT = "Now I am on island time.",
		STUFFEDEGGPLANT = "Slightly smoky flesh, savory filling. Ah!",
		SUCCULENT_PICKED = "I wonder if I can find some culinary use for this.",
		SUCCULENT_PLANT = "What an adorable little plant.",
		SUCCULENT_POTTED = "I would have preferred to cook it, but c'est la vie.",
		SWEATERVEST = "I feel so much better all of the sudden.",
		TAFFY = "I hope it never dislodges from my teeth!",
		TALLBIRD = "Leggy.",
		TALLBIRDEGG = "I wonder what its incubation period is?",
		TALLBIRDEGG_COOKED = "Could use sliced fried tomatoes and beans...",
		TALLBIRDEGG_CRACKED = 
		{
			COLD = "Oh, you poor egg, you are so cold!",
			GENERIC = "There is activity!",
			HOT = "I hope you don't hardboil.",
			LONG = "This is going to take some dedication.",
			SHORT = "A hatching is in the offing!",
		},
		TALLBIRDNEST = 
		{
			GENERIC = "No vacancy here.",
			PICKED = "Empty nest syndrome is setting in.",
		},
		TEENBIRD = 
		{
			GENERIC = "You are sort of tall, I guess...",
			HUNGRY = "Teenagers, always hungry!",
			STARVING = "Are you trying to eat me out of base and home?",
		},
		TELEBASE = 
		{
			GEMS = "It requires more purple gems.",
			VALID = "It is operational.",
		},
		TELEPORTATO_BASE = 
		{
			ACTIVE = "Where shall we go, thing?",
			GENERIC = "It leads somewhere. And that is what I am afraid of.",
			LOCKED = "It denies my access.",
			PARTIAL = "It requires something additional.",
		},
		TELEPORTATO_BOX = "\"This\" likely connects to a \"that.\"",
		TELEPORTATO_CRANK = "Definitely for a cranking action of some kind.",
		TELEPORTATO_POTATO = "This, I do not even...",
		TELEPORTATO_RING = "One ring to teleport them all!",
		TELESTAFF = "Let us take a trip. I am not picky as to where.",
		TENT = 
		{
			BURNT = "A good night's sleep, up in smoke.",
			GENERIC = "For roughing it.",
		},
		TENTACLE = "Calamari?",
		TENTACLESPIKE = "This would stick in my throat.",
		TENTACLESPOTS = "Would make a decent kitchen rag.",
		TENTACLE_GARDEN = "If only it were squid and not... whatever it is...",
		TENTACLE_PILLAR = "If only it were squid and not... whatever it is...",
		TENTACLE_PILLAR_ARM = "If only it were squid and not... whatever it is...",
		TENTACLE_PILLAR_HOLE = "I'm ready to take the plunge.",
		THULECITE = "Thule-... thulec-... it rolls off the tongue, does it not?",
		THULECITE_PIECES = "A pocketful of thule.",
		THURIBLE = "It smells like a dish that's begun to burn.",
		TOADSTOOL = 
		{
			GENERIC = "What massive legs you have!",
			RAGE = "It seems quite mad now!",
		},
		TOADSTOOL_CAP = 
		{
			EMPTY = "Was there supposed to be something here?",
			GENERIC = "How delectable! I should chop it down.",
			INGROUND = "What's that poking out?",
		},
		TOPHAT = "For a night out on the town...?",
		TORCH = "Not great for caramelizing crème brûlée, but it will do for seeing.",
		TOWNPORTAL = 
		{
			ACTIVE = "Ready to receive the dinner guests.",
			GENERIC = "Is someone coming for dinner?",
		},
		TOWNPORTALTALISMAN = 
		{
			ACTIVE = "Well, it will be quicker at least.",
			GENERIC = "The sensation takes some getting used to.",
		},
		TRAILMIX = "Energy food!",
		TRAILS = "Be gentle, please!",
		TRANSISTOR = "Positively charged to get my hands on one!",
		TRAP = "I do not wish to be so tricky, but the dinner bell calls me.",
		TRAP_BRAMBLE = "My salady friend made this.",
		TRAP_TEETH = "This is not a cruelty-free trap.",
		TRAP_TEETH_MAXWELL = "I must remember where this is...",
		TREASURECHEST = 
		{
			BURNT = "Its treasure-chesting days are over.",
			GENERIC = "Treasure!",
		},
		TREASURECHEST_TRAP = "Hmmm, something does not feel right about this...",
		TREECLUMP = "Someone or something does not want me to tree-spass.",
		TRINKET_1 = "Someone must have really lost their marbles.",
		TRINKET_2 = "I'll hum my own tune.",
		TRINKET_3 = "Some things can't be undone.",
		TRINKET_4 = "Somewhere there's a lawn that misses you.",
		TRINKET_5 = "A rocketship for ants?",
		TRINKET_6 = "These almost look dangerous.",
		TRINKET_7 = "A distraction of little substance.",
		TRINKET_8 = "Ah, memories of bathing.",
		TRINKET_9 = "Buttons that are not so cute.",
		TRINKET_10 = "Manmade masticators.",
		TRINKET_11 = "He doesn't seem trustworthy to me.",
		TRINKET_12 = "I know of no recipe that calls for this.",
		TRINKET_13 = "I'd prefer switcha... With a piece of duff.",
		TRINKET_14 = "Do they work with paring knives?",
		TRINKET_15 = "I prefer the lute, myself.",
		TRINKET_16 = "This has no business calling itself a plate.",
		TRINKET_17 = "I wouldn't wear this, even if it were my size.",
		TRINKET_18 = "I should be careful with this.",
		TRINKET_19 = "An odd prescription.",
		TRINKET_20 = "It looks expectant.",
		TRINKET_21 = "I'm afraid I won't fit.",
		TRINKET_22 = "Perfect for a candlelit dinner!",
		TRINKET_23 = "What an interesting contraption.",
		TRINKET_24 = "I think Mme. Wickerbottom had a cat.", --Lucky Cat Jar
		TRINKET_25 = "It's not a very pleasant smell.", --Air Unfreshener
		TRINKET_26 = "Who hurt you, sweet tuber.", --Potato Cup
		TRINKET_27 = "I don't have much to hang up anymore.", --Coat Hanger
		TRINKET_28 = "A little, tiny rook.", --Rook
        TRINKET_29 = "A little, tiny rook.", --Rook
		TRINKET_30 = "It looks all knight to me.", --Knight
        TRINKET_31 = "It looks all knight to me.", --Knight
        TRINKET_32 = "I see right through this sort of stuff.", --Cubic Zirconia Ball
        TRINKET_33 = "It wouldn't go with my look.", --Spider Ring
        TRINKET_34 = "I know better than to mess with this.", --Monkey Paw
        TRINKET_35 = "Whatever was inside is gone now.", --Empty Elixir
        TRINKET_36 = "Oh dear, how spooky!", --Faux fangs
        TRINKET_37 = "How ominous.", --Broken Stake
        TRINKET_38 = "I don't want that near my eyes.", -- Binoculars Griftlands trinket
        TRINKET_39 = "It must be so lonely.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Mm. Escargot.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "I'm not going to mess with it. It seems dangerous.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "How cute.", -- Toy Cobra Hot Lava trinket
        TRINKET_43 = "What a fun little toy.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Hm. Not edible.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "You'd have to be a real dupe to think you could get that working.", -- Odd Radio ONI trinket
        TRINKET_46 = "Hm, what's that? I spaced out.", -- Hairdryer ONI trinket
		TRUNKVEST_SUMMER = "Fashionably refreshing.",
		TRUNKVEST_WINTER = "Toasty and trendy.",
		TRUNK_COOKED = "Could use... Hm... I'm stumped...",
		TRUNK_SUMMER = "This meat has a gamey odor.",
		TRUNK_WINTER = "Not the finest cut of meat.",
		TUMBLEWEED = "What secrets do you hold?",
		TURF_BADLANDS = "It's like an ingredient for the ground.",
		TURF_CARPETFLOOR = "Make fists with your toes...",
		TURF_CAVE = "It's like an ingredient for the ground.",
		TURF_CHECKERFLOOR = "It's like an ingredient for the ground.",
		TURF_DECIDUOUS = "It's like an ingredient for the ground.",
		TURF_DESERTDIRT = "It's like an ingredient for the ground.",
		TURF_DIRT = "It's like an ingredient for the ground.",
		TURF_DRAGONFLY = "It's like an ingredient for the ground.",
		TURF_FOREST = "It's like an ingredient for the ground.",
		TURF_FUNGUS = "It's like an ingredient for the ground.",
		TURF_FUNGUS_GREEN = "It's like an ingredient for the ground.",
		TURF_FUNGUS_RED = "It's like an ingredient for the ground.",
		TURF_GRASS = "Will I need to cut this?",
		TURF_MARSH = "It's like an ingredient for the ground.",
		TURF_MUD = "It's like an ingredient for the ground.",
		TURF_ROAD = "It's like an ingredient for the ground.",
		TURF_ROCKY = "It's like an ingredient for the ground.",
		TURF_SANDY = "It's like an ingredient for the ground.",
		TURF_SAVANNA = "It's like an ingredient for the ground.",
		TURF_SINKHOLE = "It's like an ingredient for the ground.",
		TURF_UNDERROCK = "It's like an ingredient for the ground.",
		TURF_WOODFLOOR = "It's like an ingredient for the ground.",
		TURKEYDINNER = "I'm getting sleepy just looking at it!",
		TURTILLUS = "They seem a bit prickly, non?",
		TWIGGYTREE = 
		{
			BURNING = "It, oh, it appears to be on fire.",
			BURNT = "Crisp, no?",
			CHOPPED = "No more for now.",
			DISEASED = "It's under the weather.",
			GENERIC = "It's a tree made of kabob sticks.",
		},
		TWIGGY_NUT = "It will grow into a fine tree.",
		TWIGGY_NUT_SAPLING = "Just a petite bébé.",
		TWIGGY_OLD = "That tree looks like it's on its way out.",
		TWIGS = "The start of a good cooking fire.",
		UMBRELLA = "I will try to remember not to open indoors.",
		UNAGI = "More like \"umami\"! Ooooh, mommy!",
		UNIMPLEMENTED = "It appears unfinished.",
		WAFFLES = "Oh, brunch, I have missed you so!",
		WALL_HAY = 
		{
			BURNT = "That is what I expected.",
			GENERIC = "Calling it a \"wall\" is kind of a stretch.",
		},
		WALL_HAY_ITEM = "Hay look, a wall!",
		WALL_MOONROCK = "I do kind of wish it was made of cheese.",
		WALL_MOONROCK_ITEM = "I can't believe this was once on the moon.",
		WALL_RUINS = "Look at the carvings...",
		WALL_RUINS_ITEM = "The stories these tell... fascinating...",
		WALL_STONE = "Good stone work.",
		WALL_STONE_ITEM = "I feel secure behind this.",
		WALL_WOOD = 
		{
			BURNT = "Wood burns. Who knew? ...Me!?",
			GENERIC = "Putting down stakes.",
		},
		WALL_WOOD_ITEM = "Delivers a rather wooden performance as a wall.",
		WALRUS = "They move faster than you'd think.",
		WALRUSHAT = "Smells a little musty...",
		WALRUS_CAMP = 
		{
			EMPTY = "Yes, vacancy.",
			GENERIC = "Some outdoorsy types made this.",
		},
		WALRUS_TUSK = "It won't be needing this anymore.",
		WARDROBE = 
		{
			BURNING = "The wardrobe is burning!",
			BURNT = "We had some nice things in there.",
			GENERIC = "I wish I'd had the chance to bring more clothes with me.",
		},
		WARG = "Leader of the pack.",
		WARGSHRINE = 
		{
			BURNT = "Overcooked.",
			EMPTY = "Maybe it's hungry.",
			GENERIC = "Dogs are nice. I should pay tribute to them.",
		},
		WASPHIVE = "Not your average bees.",
		WATERBALLOON = "A balloon, filled with water? What a funny idea.",
		WATERMELON = "Despite its name, it is mostly filled with deliciousness!",
		WATERMELONHAT = "Aaaahhhhhh sweet relief...",
		WATERMELONICLE = "I feel like a kid again!",
		WATERMELON_COOKED = "Could use mint and feta...",
		WATERMELON_SEEDS = "More watermelon, anyone?",
		WATHGRITHR = 
		{
			ATTACKER = "I fear %s more than anyone here.",
			FIRESTARTER = "%s's fires burn as wildly as her passions.",
			GENERIC = "Bonjour, %s!",
			GHOST = "I'm surprised I outlived %s, frankly.",
			MURDERER = "%s has done something truly abominable.",
			REVIVER = "%s is a great ally, indeed.",
		},
		WATHGRITHRHAT = "I don't have the confidence to pull it off like she does.",
		WAXPAPER = "Wax paper! Always useful in the kitchen.",
		WAXWELL = 
		{
			ATTACKER = "%s has been irritable lately.",
			FIRESTARTER = "Let's not trust %s with flammable things for now.",
			GENERIC = "Salut, %s.",
			GHOST = "That looks very uncomfortable.",
			MURDERER = "I may not have it in me to forgive %s.",
			REVIVER = "%s isn't bad, just a little crunchy on the outside.",
		},
		WAXWELLJOURNAL = "Maman used to keep a journal, before her memory went.",
		WEBBER = 
		{
			ATTACKER = "What have you been up to, petit monsieur?",
			FIRESTARTER = "Fire is dangerous you know, petit monsieur.",
			GENERIC = "Salut, petit monsieur %s.",
			GHOST = "Oh, you poor thing.",
			MURDERER = "What a terrible creature.",
			REVIVER = "I should make him a little treat later.",
		},
		WEBBERSKULL = "Stop staring at me or I'll bury you!",
		WEBBER_SPIDER_MINION = "Oh, my. Bonjour, petit araignée.",
		WENDY = 
		{
			ATTACKER = "Have you been up to mischief, Mademoiselle %s?",
			FIRESTARTER = "You know better than to set flames, Mademoiselle %s.",
			GENERIC = "Salut, Mademoiselle %s.",
			GHOST = "Oh non, non, non. Let's get you fixed up.",
			MURDERER = "She's inflicted her grief upon others. Abominable.",
			REVIVER = "I'll cook her favorite dish for supper tonight.",
		},
		WES = 
		{
			ATTACKER = "I didn't expect him to be the violent sort.",
			FIRESTARTER = "Watch where you light those fires, %s.",
			GENERIC = "Bonjour, %s!",
			GHOST = "Is there a medic on this island?",
			MURDERER = "What a terrible act you've committed.",
			REVIVER = "I love your act, by the way.",
		},
		WETGOOP = "Thankfully my sous chefs aren't here to witness this abomination...",
		WETPAPER = "It's a tiny bit soggy.",
		WETPOUCH = "I hope the contents don't fall out.",
		--WHIP = "",
		WICKERBOTTOM = 
		{
			ATTACKER = "I thought you were more responsible that that, Mme. %s.",
			FIRESTARTER = "I assume she meant it to be a controlled burn.",
			GENERIC = "Bonjour, Mme. %s!",
			GHOST = "It's not your time to go quite yet, Mme. %s.",
			MURDERER = "Mme. %s has done an unthinkable deed.",
			REVIVER = "Mme. %s is a reliable sort.",
		},
		WILLOW = 
		{
			ATTACKER = "Been in a tussle recently, %s?",
			FIRESTARTER = "She was bound to start a fire sometime.",
			GENERIC = "Salut, %s!",
			GHOST = "Would a nice bowl of hot soup help?",
			MURDERER = "I've burned my bridges with that one.",
			REVIVER = "You can rely on %s when it's important.",
		},
		WILSON = 
		{
			ATTACKER = "Let's all calm down with a nice bowl of soup.",
			FIRESTARTER = "I don't want to nitpick how you light fires, but...",
			GENERIC = "Bonjour, %s!",
			GHOST = "Oh my. Does that hurt?",
			MURDERER = "Mon dieu! You're a murderer!",
			REVIVER = "You've been a big help, %s.",
		},
		WINONA = 
		{
			ATTACKER = "You've been much too rough lately, %s.",
			FIRESTARTER = "%s started quite the fire recently.",
			GENERIC = "Bonjour, %s!",
			GHOST = "Let's fix you up, alright?",
			MURDERER = "She's done a truly awful thing.",
			REVIVER = "I admire %s's sense of duty.",
		},
		WOLFGANG = 
		{
			ATTACKER = "%s's fists are weapons.",
			FIRESTARTER = "Surely he didn't know what he was doing when he set the flames.",
			GENERIC = "Salut, %s!",
			GHOST = "Don't be scared, mon amie. I will help.",
			MURDERER = "What a heinous act you've committed.",
			REVIVER = "%s is very strong indeed.",
		},
		WOODIE = 
		{
			ATTACKER = "I don't trust him with that axe right now.",
			BEAVER = "What on earth have you been eating?",
			BEAVERGHOST = "My friends are very strange.",
			FIRESTARTER = "I thought you disliked forest fires?",
			GENERIC = "Bonjour, %s!",
			GHOST = "Would some comfort food help?",
			MURDERER = "%s did something unforgivable.",
			REVIVER = "%s has a soft spot a mile wide.",
		},
		WARLY = 
		{
			GENERIC = "Heh. Bonjour, mon a-ME.",
            ATTACKER = "%s, why fight when we can cook?",
            MURDERER = "Mon dieu! I'm a monster!",
            REVIVER = "It's quite nice to have myself around.",
            GHOST = "I cook so I don't have to think about my own mortality.",
            FIRESTARTER = "Mon dieu! Watch the fire!",
		},
		WORMWOOD = 
		{
			ATTACKER = "You won't make friends that way, %s.",
			FIRESTARTER = "Fire isn't safe for you, %s.",
			GENERIC = "Bonjour, %s!",
			GHOST = "Hold on, mon amie, I will find a heart.",
			MURDERER = "I could never be friends with such a creature.",
			REVIVER = "%s is a kind little veg.",
		},
		WORTOX = 
		{
			ATTACKER = "I don't find %s's pranks very funny.",
			FIRESTARTER = "It makes sense that he'd like fire.",
			GENERIC = "Salut, my fuzzy red friend!",
			GHOST = "I don't think it bothers him as much as it does mortals.",
			MURDERER = "%s did something very, very cruel.",
			REVIVER = "%s is a trickster, but he helps sometimes too.",
		},
		WX78 = 
		{
			ATTACKER = "%s seems to be on the fritz today.",
			FIRESTARTER = "They overheated, perhaps?",
			GENERIC = "Bonjour, my metal friend!",
			GHOST = "Excusez-moi? How is it possible they have a ghost?",
			MURDERER = "%s did something truly vile.",
			REVIVER = "%s did a kind thing today.",
		},
		WINONA_BATTERY_HIGH = 
		{
			BURNING = "It, oh, it appears to be on fire.",
			BURNT = "Crisp, non?",
			GENERIC = "It's nice to have Winona around.",
			LOWPOWER = "It's getting a bit low, Winona.",
			OFF = "What sort of fuel does this take?",
		},
		WINONA_BATTERY_LOW = 
		{
			BURNING = "It, oh, it appears to be on fire.",
			BURNT = "Crisp, non?",
			GENERIC = "It's working really well!",
			LOWPOWER = "It's getting a bit low, Winona.",
			OFF = "I suppose it needs fuel.",
		},
		WINONA_CATAPULT = 
		{
			BURNING = "It, oh, it appears to be on fire.",
			BURNT = "Crisp, non?",
			GENERIC = "I feel so safe now.",
			OFF = "It's not on.",
		},
		WINONA_SPOTLIGHT = 
		{
			BURNING = "It, oh, it appears to be on fire.",
			BURNT = "Crisp, non?",
			GENERIC = "Oh good. I don't much like the dark out here.",
			OFF = "Is it out of power?",
		},
		WINTERHAT = "I know when to don this, and not a minute sooner.",
		WINTEROMETER = 
		{
			BURNT = "Foresight is 0/0.",
			GENERIC = "Splendid. I should like to know when the worm is going to turn.",
		},
		WINTER_FOOD1 = "It has that \"homecooked\" charm.", --gingerbread cookie
        WINTER_FOOD2 = "Cooking is a way of expressing love.", --sugar cookie
        WINTER_FOOD3 = "The candy strands are expertly entwined.", --candy cane
        WINTER_FOOD4 = "It grows on you.", --fruitcake
        WINTER_FOOD5 = "I wouldn't turn down a slice.", --yule log cake
        WINTER_FOOD6 = "Just like maman used to make.", --plum pudding
        WINTER_FOOD7 = "Just the right amount of sweetness.", --apple cider
        WINTER_FOOD8 = "It smells like comfort and contentment.", --hot cocoa
        WINTER_FOOD9 = "I'm so happy I could weep.", --eggnog
		WINTER_ORNAMENT = "How festive!",
		WINTER_ORNAMENTBOSS = "We've earned a moment to celebrate.",
		WINTER_ORNAMENTFORGE = "It's nice to be alive and safe.",
		WINTER_ORNAMENTGORGE = "I feel like cooking something.",
		WINTER_ORNAMENTLIGHT = "I love seeing the forest lit up at night.",
		WINTER_TREE = 
		{
			BURNING = "It's burning!",
			BURNT = "Now we'll have to grow another.",
			CANDECORATE = "Shall we \"spruce\" it up a little? Hm?",
			YOUNG = "It's coming along nicely.",
		},
		WINTER_TREESTAND = 
		{
			BURNT = "That won't kill my spirit.",
			GENERIC = "A pinecone should get things rolling.",
		},
		WORM = 
		{
			DIRT = "Dirty.",
			PLANT = "I see nothing amiss here.",
			WORM = "Worm!",
		},
		WORMHOLE = 
		{
			GENERIC = "That is no ordinary tooth-lined hole in the ground!",
			OPEN = "Am I really doing this?",
		},
		WORMHOLE_LIMITED = "These things can look worse?",
		WORMLIGHT = "Radiates deliciousness.",
		WORMLIGHT_LESSER = "Not as fresh, but I imagine the flavor is still good.",
		WORMLIGHT_PLANT = "I see nothing amiss here.",
		YELLOWAMULET = "Puts some pep in my step!",
		YELLOWGEM = "I miss lemons...",
		YELLOWMOONEYE = "Keep an eye out for me, oui?",
		YELLOWSTAFF = "I could stir a huge pot with this thing!",
		YOTP_FOOD1 = "What a treat it is to be cooked for for a change!",
		YOTP_FOOD2 = "Respectfully I think I may pass on this course.",
		YOTP_FOOD3 = "I'd never turn my nose up at street food.",

        --v2 Warly
        PORTABLECOOKPOT_ITEM =
        {
            --item state
            GENERIC = "What new culinary adventures shall we undertake, old friend?",
            --placed state
            --BURNT = "Nononononono whyyyyyyyyyyyyyyy!?", --not used in DST, it auto crumbles when burnt
            COOKING_LONG = "The flavors need time to meld.",
            COOKING_SHORT = "I threw that meal together!",
            DONE = "Pickup! Oh, old habits...",
            EMPTY = "I would never leave home without it!",
        },
        PORTABLEBLENDER_ITEM = "It has greatly improved my culinary adventures.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Fresh spices! Oh, how I have missed you!",
            DONE = "Pickup! Oh, old habits...",
        },
        SPICE_GARLIC = "Without garlic powder, life is not worth living.",
        SPICE_SUGAR = "The original all natural sweetener.",
        SPICE_CHILI = "My own special recipe.",
        SPICEPACK = "My bag of chef's tricks!",
        MONSTERTARTARE = "This is a culinary abomination. I'm appalled.",
        FRESHFRUITCREPES = "Is this not a thing of beauty?",
        FROGFISHBOWL = "I think I've outdone myself, given the available ingredients.",
        POTATOTORNADO = "Junk food can be as enjoyable as anything gourmet.",
        DRAGONCHILISALAD = "A hint of spice to awaken the tastebuds.",
        GLOWBERRYMOUSSE = "My own special recipe!",
        VOLTGOATJELLY = "I ground the horns up myself.",
        NIGHTMAREPIE = "It's really not as scary as it sounds.",
        BONESOUP = "Bone appétit!",
        MASHEDPOTATOES = "The secret is to use a whole stick of butter.",
        POTATOSOUFFLE = "It came out just right.",
        MOQUECA = "I'm quite proud of how it turned out.",
        GAZPACHO = "Ah. Perfect on a hot day.",
        ASPARAGUSSOUP = "Ah, a special dish.",
        VEGSTINGER = "Add a little spice.",
        BANANAPOP = "Perhaps not my most complicated dish, but no less tasty.",
        CEVICHE = "Truly what I live for!",
        SALSA = "I like to spice things up!",
        PEPPERPOPPER = "I like to make my dishes pop!",

        TURNIP = "Root vegetables are at the root of all good meals.",
        TURNIP_COOKED = "It will do in a pinch, but I can do better.",
        TURNIP_SEEDS = "What fresh ingredients will grow from these?",
        --
        GARLIC = "Ah! The smell of fresh garlic!",
        GARLIC_COOKED = "What can I add this to?",
        GARLIC_SEEDS = "What fresh ingredients will grow from these?",
        --
        ONION = "Boasts as many uses as it has layers.",
        ONION_COOKED = "I would prefer to put this to better use.",
        ONION_SEEDS = "What fresh ingredients will grow from these?",
        --
        POTATO = "Ah, the mighty potato!",
        POTATO_COOKED = "Golden brown. Simplicity at its finest.",
        POTATO_SEEDS = "What fresh ingredients will grow from these?",
        --
        TOMATO = "Mmm... I can smell the sauces already.",
        TOMATO_COOKED = "A nice light snack.",
        TOMATO_SEEDS = "What fresh ingredients will grow from these?",

        ASPARAGUS = "Sparrow grass!", 
        ASPARAGUS_COOKED = "Roasted asparagus. What a treat!",
        ASPARAGUS_SEEDS = "These will grow some nice fresh vegetables.",

        PEPPER = "Finally, I can make my famous hot sauce!",
        PEPPER_COOKED = "The roasting really brings out the flavors.",
        PEPPER_SEEDS = "What fresh ingredients will grow from this?",
	},
	DESCRIBE_GENERIC = "It is what it is...",
	DESCRIBE_SMOLDERING = "I fear that that is about to cook itself.",
	DESCRIBE_TOODARK = "I cannot see a thing!",
	EAT_FOOD = 
	{
		TALLBIRDEGG_CRACKED = "Fresh! Err... perhaps too fresh.",
	},
	QUAGMIRE_ANNOUNCE_LOSE = "This doesn't look good.",
	QUAGMIRE_ANNOUNCE_MEALBURNT = "I should have taken that off sooner.",
	QUAGMIRE_ANNOUNCE_NOTRECIPE = "As a chef, I am quite embarrassed.",
	QUAGMIRE_ANNOUNCE_WIN = "I'm almost sorry to leave!",
}