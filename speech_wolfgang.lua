--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        REPAIR =
        {
            WRONGPIECE = "Is wrong piece for little statue!",
        },
        BUILD =
        {
            MOUNTED = "Hair-cow is too tall. I can't reach.",
            HASPET = "Wolfgang has animal friend already!",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I will wait until he is not looking.",
			GENERIC = "That cannot be shaved.",
			NOBITS = "I cannot shave when there are no hairs.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
		},
		STORE =
		{
			GENERIC = "I will make it fit!",
			NOTALLOWED = "Bah! Useless.",
			INUSE = "Wolfgang can share!",
            NOTMASTERCHEF = "Warly is very nice to cook. Wolfgang will not get in way.",
		},
        CONSTRUCT =
        {
            INUSE = "Wolfgang can share?",
            NOTALLOWED = "Is not right place for that.",
            EMPTY = "Wolfgang needs something to put here.",
            MISMATCH = "Wolfgang have wrong plans.",
        },
		RUMMAGE =
		{	
			GENERIC = "Maybe Wolfgang do later.",
			INUSE = "Wolfgang would like to use after you, if okay.",
            NOTMASTERCHEF = "Warly is very nice to cook. Wolfgang will not get in way.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "Is not right key!",
        	KLAUS = "Later! Now we FIGHT!",
			QUAGMIRE_WRONGKEY = "Is wrong key.",
        },
		ACTIVATE = 
		{
			LOCKED_GATE = "Let Wolfgang in!",
		},
        COOK =
        {
            GENERIC = "Wolfgang not in cooking mood.",
            INUSE = "Oh, smells good, friend!",
            TOOFAR = "Is pot very small, or just far away?",
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
            GENERIC = "Wolfgang does not think that goes there.",
            DEAD = "You know is dead, yes?",
            SLEEPING = "Is sleeping now!",
            BUSY = "The Mighty Wolfgang will try again soon!",
            ABIGAILHEART = "Wolfgang smush heart into ghost girl but nothing happen!",
            GHOSTHEART = "No!",
            NOTGEM = "Not even mighty muscles can make fit!",
            WRONGGEM = "Little rock does not want to go there.",
            NOTSTAFF = "I do not think little platform would like that.",
            MUSHROOMFARM_NEEDSSHROOM = "Is needing tiny mushy-room, I think.",
            MUSHROOMFARM_NEEDSLOG = "Is needing tiny log with face.",
            SLOTFULL = "Something is already put!",
            FOODFULL = "It must enjoy first yummy food from Wolfgang first!",
            NOTDISH = "Wolfgang serves only best dishes!",
            DUPLICATE = "Little recipe is already in there!",
            NOTSCULPTABLE = "Material is not mighty enough for strong statues!",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "Is not working.",
            WRONGSHADOWFORM = "Bones is wrong shape.",
            NOMOON = "Is too scary in here for funny man to work.",
			PIGKINGGAME_MESSY = "Wolfgang clean first.",
			PIGKINGGAME_DANGER = "Is too scary for that now!",
			PIGKINGGAME_TOOLATE = "Is dark. No games now.",
        },
        GIVETOPLAYER =
        {
            FULL = "Make room for Wolfgang's presents!",
            DEAD = "You know is dead, yes?",
            SLEEPING = "Friend is sleeping now!",
            BUSY = "Please give Mighty Wolfgang your attention!",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "Make room for Wolfgang's presents!",
            DEAD = "You know is dead, yes?",
            SLEEPING = "Friend is sleeping now!",
            BUSY = "Please give Mighty Wolfgang your attention!",
        },
        WRITE =
        {
            GENERIC = "Wolfgang not good with tiny letters.",
            INUSE = "Can Wolfgang help make scribblemarks when you're done?",
        },
        DRAW =
        {
            NOIMAGE = "Wolfgang no good at drawing pictures from head.",
        },
        CHANGEIN =
        {
            GENERIC = "Clothes only good for ripping with strong muscles!",
            BURNING = "Wolfgang's weekday undergarments burning? Wolfgang is sad.",
            INUSE = "Wolfgang will wait til they leave to change. He is shy.",
        },
        ATTUNE =
        {
            NOHEALTH = "Wolfgang is too woozy to do this.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I cannot ride it now! Hair-cow is proving itself in battle!",
            INUSE = "Hair-cow is occupied by another.",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I cannot ride it now! Hair-cow is proving itself in battle!",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Wolfgang already knows this!",
            CANTLEARN = "I do not get it.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "Little paper is not for here!",
        },
        WRAPBUNDLE =
        {
            EMPTY = "Wolfgang has no little things to wrap!",
        },
        PICKUP =
        {
			RESTRICTION = "That is not mighty weapon!",
			INUSE = "Wolfgang will wait for friend to finish.",
        },
        SLAUGHTER =
        {
            TOOFAR = "Come back so Wolfgang can eat you!",
        },
        REPLATE =
        {
            MISMATCH = "Food need different dish.", 
            SAMEDISH = "Wolfgang already put on dish.", 
        },
        SAIL =
        {
        	REPAIR = "Tiny boat is strong, no need.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Need to paddle at right time!",
            BAD_TIMING1 = "Wolfgang need to concentrate.",
            BAD_TIMING2 = "Is easy! That was just practice run.",
        },
        LOWER_SAIL_FAIL =
        {
            "Tiny wind cloth not listening to Wolfgang!",
            "Wolfgang will show tiny boat who's mightier!",
            "Argh! Taking down big circus tent was easier than this!",
        },
        BATHBOMB =
        {
            GLASSED = "Is covered in see-through sharp stuff!",
            ALREADY_BOMBED = "Is already prettified.",
        },
	},
	ACTIONFAIL_GENERIC = "I am not mighty enough to do that.",
	ANNOUNCE_BOAT_LEAK = "Drippy drops is come through boat!",
	ANNOUNCE_BOAT_SINK = "Wolfgang cannot swim!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Ha! Dirt spoon fix it!",
	ANNOUNCE_PICK_DISEASE_WARNING = "Bah! Tiny plant is smell terrible!",
	ANNOUNCE_ADVENTUREFAIL = "Next time I will be mightier!",
    ANNOUNCE_MOUNT_LOWHEALTH = "What is wrong, hair beast? Feeling not-so-mighty?",

    --waxwell and wickerbottom specific strings
--fallback to speech_wilson.lua     ANNOUNCE_TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
--fallback to speech_wilson.lua     ANNOUNCE_WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",

    --wolfgang specific
    ANNOUNCE_NORMALTOMIGHTY = "I AM MIGHTY!",
    ANNOUNCE_NORMALTOWIMPY = "I am not feeling so good.",
    ANNOUNCE_WIMPYTONORMAL = "Wolfgang is better.",
    ANNOUNCE_MIGHTYTONORMAL = "I need to fill my mighty belly again!",

	ANNOUNCE_BEES = "Bees! Nasty stinging bug men!",
	ANNOUNCE_BOOMERANG = "Ow! Why did you hurt me, throwy stick?",
	ANNOUNCE_CHARLIE = "Show yourself!",
	ANNOUNCE_CHARLIE_ATTACK = "Ow! It got me!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific 
	ANNOUNCE_COLD = "Brrrrrrr! Is frosty!",
	ANNOUNCE_HOT = "Hah, is sticky and hot!",
	ANNOUNCE_CRAFTING_FAIL = "I need to gather more things to make that.",
	ANNOUNCE_DEERCLOPS = "Sound like big strong man coming.",
	ANNOUNCE_CAVEIN = "Sky is fall soon.",
	ANNOUNCE_ANTLION_SINKHOLE = 
	{
		"Ground is crumble beneath might of Wolfgang!",
		"Wolfgang broke the ground!",
		"That rumble is not stomach!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Please do not eat me.",
        "Is tribute for a mighty... f-friend.",
        "Do not eat Wolfgang's friends, please?",
	},
	ANNOUNCE_SACREDCHEST_YES = "Chest is happy!",
	ANNOUNCE_SACREDCHEST_NO = "It did not like me.",
    ANNOUNCE_DUSK = "The scary time is coming soon.",
    
    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Good food make Wolfgang strong!",
		PAINFUL = "Ooooh. I have belly ache.",
		SPOILED = "Ew! Tastes like garbage!",
		STALE = "Tastes funny.",
		INVALID = "Hahah! That's not food!",
        YUCKY = "Stomach is not strong enough for that.",
        
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
        "Is good... for muscles...",
        "Lift... with legs...",
        "Feel... good burn!",
        "Raa! Huff!",
        "Muscles... will be sore tomorrow!",
        "Ha ha...! Weight... is nothing!",
        "Little stone... cannot stop Wolfgang!",
        "Hngh...!",
        "Witness... Wolfgang strength!",
        "Wolfgang is mighty...!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING = 
    {
		"Monsters is coming!",
		"Wolfgang wants out of cave!",
		"Wolfgang does not like dark cave.",
	},
    ANNOUNCE_RUINS_RESET = "Monsters is back!",
    ANNOUNCE_SNARED = "Wolfgang does not like bones!",
    ANNOUNCE_REPELLED = "Strong bubble protects beast!",
	ANNOUNCE_ENTER_DARK = "I cannot see! I am scared!",
	ANNOUNCE_ENTER_LIGHT = "I can see again!",
	ANNOUNCE_FREEDOM = "I am free! Strong freedom!",
	ANNOUNCE_HIGHRESEARCH = "Is maybe too much information.",
	ANNOUNCE_HOUNDS = "I hear puppies!",
	ANNOUNCE_WORMS = "Earth is tremble beneath Wolfgang's mighty feet!",
	ANNOUNCE_HUNGRY = "My mighty belly is empty!",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Animal is close!",
	ANNOUNCE_HUNT_LOST_TRAIL = "No animal here.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Animal tracks is mud now.",
	ANNOUNCE_INV_FULL = "My mighty arms can carry no more.",
	ANNOUNCE_KNOCKEDOUT = "Ugh, I must have hit head.",
	ANNOUNCE_LOWRESEARCH = "Is tiny information.",
	ANNOUNCE_MOSQUITOS = "Wolfgang need blood, get away sucking bugs!",
    ANNOUNCE_NOWARDROBEONFIRE = "Ehh, Wolfgang do that later...",
    ANNOUNCE_NODANGERGIFT = "Fight is better than present!",
    ANNOUNCE_NOMOUNTEDGIFT = "Wolfgang will fall if try to open on top of hair cow!",
	ANNOUNCE_NODANGERSLEEP = "Wolfgang prefer fight to sleep.",
	ANNOUNCE_NODAYSLEEP = "Is too bright for sleep.",
	ANNOUNCE_NODAYSLEEP_CAVE = "Is creepy in cave.",
	ANNOUNCE_NOHUNGERSLEEP = "Wolfgang say never sleep with empty stomach.",
	ANNOUNCE_NOSLEEPONFIRE = "Is too hot for sleeping.",
	ANNOUNCE_NODANGERSIESTA = "I prefer fighting to napping!",
	ANNOUNCE_NONIGHTSIESTA = "Wolfgang have principles against siesta at night.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "Wolfgang is tense. Too tense to relax.",
	ANNOUNCE_NOHUNGERSIESTA = "Wolfgang take siesta after eating time.",
	ANNOUNCE_NODANGERAFK = "Wolfgang will not abandon the fight!",
	ANNOUNCE_NO_TRAP = "Easy like lift weights.",
	ANNOUNCE_PECKED = "What I do to deserve this?",
	ANNOUNCE_QUAKE = "Ground is shake. Wolfgang hate shaking ground.",
	ANNOUNCE_RESEARCH = "Is lot of information.",
	ANNOUNCE_SHELTER = "Wolfgang hide under tree.",
	ANNOUNCE_THORNS = "Pointy is not fair!",
	ANNOUNCE_BURNT = "Burny is not fair!",
	ANNOUNCE_TORCH_OUT = "Oh no! The light is gone!",
	ANNOUNCE_THURIBLE_OUT = "Swingy burnies has gone out!",
	ANNOUNCE_FAN_OUT = "Tiny fan is broken!",
    ANNOUNCE_COMPASS_OUT = "Little needle broke off!",
	ANNOUNCE_TRAP_WENT_OFF = "Ack! Do not surprise Wolfgang!",
	ANNOUNCE_UNIMPLEMENTED = "Is not ready.",
	ANNOUNCE_WORMHOLE = "It makes me feel alive!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Wolfgang is here!",
	ANNOUNCE_CANFIX = "\nMighty brain could make this better!",
	ANNOUNCE_ACCOMPLISHMENT = "I am doing great things with tiny arrow!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I have defeated the tiny arrow!",	
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Is not enough poop.",
	ANNOUNCE_TOOL_SLIP = "Is too slippery for holding!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Lightning is weak compared to Wolfgang clothes!",
	ANNOUNCE_TOADESCAPING = "Is looking skittery!",
	ANNOUNCE_TOADESCAPED = "Scary frog got scared and left.",


	ANNOUNCE_DAMP = "Water time.",
	ANNOUNCE_WET = "Wolfgang does not like bath time.",
	ANNOUNCE_WETTER = "It is like sitting in pond.",
	ANNOUNCE_SOAKED = "Wolfgang is maybe now made of water.",

	ANNOUNCE_WASHED_ASHORE = "Wolfgang lucky to be alive.",

    ANNOUNCE_DESPAWN = "Wolfgang is scared!",
	ANNOUNCE_BECOMEGHOST = "oOooOOoo!!",
	ANNOUNCE_GHOSTDRAIN = "They are coming... for Wolfgang!",
	ANNOUNCE_PETRIFED_TREES = "Trees! Getting! STRONG!",
	ANNOUNCE_KLAUS_ENRAGE = "Wolfgang is sorry about little deer friends!",
	ANNOUNCE_KLAUS_UNCHAINED = "Do not hold back! Wolfgang can take you!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Wimpy monster has called for help!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Do not fear! Wolfgang will save you!",
		GLASS_LOW = "Wolfgang is close!",
		GLASS_REVEAL = "You have been saved! By Wolfgang!",
		IDOL_MED = "Do not fear! Wolfgang will save you!",
		IDOL_LOW = "Wolfgang is close!",
		IDOL_REVEAL = "You have been saved! By Wolfgang!",
		SEED_MED = "Do not fear! Wolfgang will save you!",
		SEED_LOW = "Wolfgang is close!",
		SEED_REVEAL = "You have been saved! By Wolfgang!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Wolfgang's eyes is playing tricky!",
	ANNOUNCE_BRAVERY_POTION = "Wolfgang is brave! Not scared of spooky tree!",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Up now, friend!",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Go! Fight many things!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Thank-you, friend!",

    ANNOUNCE_FLARE_SEEN = "Sky fire! Wolfgang is coming, dear friend!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Wolfgang does not like scary shadow!",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "That was not good recipe!",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Little meal cooked too long.",
    QUAGMIRE_ANNOUNCE_LOSE = "Sky beast is mad!",
    QUAGMIRE_ANNOUNCE_WIN = "Is time to leave. Goodbye, good food!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "Sparky! I like!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Wolfgang even mightier than was before!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "Ha! Wimpy blows bounce right off Wolfgang!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "You watch, let Wolfgang take care of this!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Water will not bother Wolfgang!",
    
    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Lightning magic gone.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Wolfgang still strong! Just little less strong!",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Wolfgang will need new defensive strategy.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Time for little break.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Feels damp... Wolfgang hope not to catch cold.",
    
	BATTLECRY =
	{
		GENERIC = "I will punch you!",
		PIG = "I am sorry, my friend!",
		PREY = "Stomp! Stomp! Stomp!",
		SPIDER = "Die, evil scary bug!",
		SPIDER_WARRIOR = "I am still stronger, scary bug!",
		DEER = "I will make fight quick!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Ha! I win!",
		PIG = "I forgive you, pig man.",
		PREY = "You keep running!",
		SPIDER = "He ran away from me.",
		SPIDER_WARRIOR = "He knows I am stronger.",
	},
	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Why door not crumble under mighty Wolfgang punches?!",
        MULTIPLAYER_PORTAL_MOONROCK = "Is strong like Wolfgang.",
        MOONROCKIDOL = "Hehe. Is funny little moon man.",
        CONSTRUCTION_PLANS = "If Wolfgang build it, they will come.",

        ANTLION =
        {
            GENERIC = "Scary monster is friend?",
            VERYHAPPY = "Monster does not look hungry today.",
            UNHAPPY = "Monster is looking very scary!",
        },
        ANTLIONTRINKET = "Is not for head.",
        SANDSPIKE = "Spike is made of sand!",
        SANDBLOCK = "Is very sandy.",
        GLASSSPIKE = "Spike is glass now.",
        GLASSBLOCK = "Wolfgang could crush little castle.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Is pretty.",
            LONG = "Is pretty.",
            MEDIUM = "Little flower gives Wolfgang the \"heebie jeebies\".",
            SOON = "I do not like.",
            HAUNTED_POCKET = "Is making Wolfgang scared!",
            HAUNTED_GROUND = "Does it want to fight?",
        },

        BALLOONS_EMPTY = "Wolfgang will make balloon muscles.",
        BALLOON = "Is full of clown breath!",

        BERNIE_INACTIVE =
        {
            BROKEN = "Is so broken.",
            GENERIC = "Is so cuddly!",
        },

        BERNIE_ACTIVE = "Is so brave!",
        BERNIE_BIG = "Oh no! Wolfgang has shrunken!",

        BOOK_BIRDS = "Book is for the birds!",
        BOOK_TENTACLES = "Wolfgang wants many foes to fight!",
        BOOK_GARDENING = "Wolfgang rather grow muscle than flowers.",
        BOOK_SLEEP = "Wolfgang's eyes feel heavy like dumbbells.",
        BOOK_BRIMSTONE = "Tiny book scares Wolfgang!",

        PLAYER =
        {
            GENERIC = "Is tiny %s! Hello!",
            ATTACKER = "Does %s want to fight?",
            MURDERER = "%s is killer!",
            REVIVER = "%s is nice person.",
            GHOST = "Wolfgang will get raw pump-y heart for you!",
            FIRESTARTER = "%s is lighting burny fires!",
        },
        WILSON =
        {
            GENERIC = "Is tiny egghead man, %s! Hello!",
            ATTACKER = "Does weak science man want to fight?",
            MURDERER = "%s stands no chance against Wolfgang!",
            REVIVER = "%s is nice, crazy man.",
            GHOST = "Ha ha! Big brain did not save you. I will get heart.",
            FIRESTARTER = "Wolfgang thought he could trust %s!",
        },
        WOLFGANG =
        {
            GENERIC = "Hello friend %s! We must arm wrestle!",
            ATTACKER = "%s will make a worthy fight!",
            MURDERER = "We will see who is best Wolfgang! Raaa!",
            REVIVER = "%s is nice man. Like me! Ha ha.",
            GHOST = "World needs more %s! I will get heart!",
            FIRESTARTER = "Wolfgang cannot trust even himself not to light fire!",
        },
        WAXWELL =
        {
            GENERIC = "Is tiny frailman, %s! Hello!",
            ATTACKER = "Does fragile %s want to fight? Ha ha! Is funny.",
            MURDERER = "%s has not changed. Killer!",
            REVIVER = "%s is one of us. Ha ha! Yes!",
            GHOST = "%s is friend of Wolfgang. He will get raw heart.",
            FIRESTARTER = "Is dastardly plan with fire, %s?",
        },
        WX78 =
        {
            GENERIC = "Is tiny robot, %s! Hello!",
            ATTACKER = "Ha! Metal can is want to rock'em and sock'em!",
            MURDERER = "%s is killer robot!",
            REVIVER = "%s is nice person. Deep down.",
            GHOST = "Robot %s is broken! Wolfgang rub heart on problem.",
            FIRESTARTER = "Robot trying to kill fleshypeople again, maybe?",
        },
        WILLOW =
        {
            GENERIC = "Is tiny torchlady, %s! Hello!",
            ATTACKER = "Wolfgang is burning to fight!",
            MURDERER = "%s is no match for Wolfgang!",
            REVIVER = "%s is very nice, when not light moustache on fire.",
            GHOST = "Do not hurt, torchlady. Wolfgang get heart!",
            FIRESTARTER = "Is not big surprise.",
        },
        WENDY =
        {
            GENERIC = "Is very tiny, scary %s! H-hello!",
            ATTACKER = "Ah! Creepy girl is try to fight me!",
            MURDERER = "Creepy girl is killer! Attack!",
            REVIVER = "%s is nice little lady. But still scare Wolfgang.",
            GHOST = "Please no hauntings, %s! Wolfgang will get you heart!",
            FIRESTARTER = "Oh no. Creepy girl is trying to burn us!",
        },
        WOODIE =
        {
            GENERIC = "Is beard! Hello!",
            ATTACKER = "Does beardman %s want to fight?",
            MURDERER = "Drop axe and fight, beardman!",
            REVIVER = "%s is nice man with magnificent beard.",
            GHOST = "Wolfgang will get heart for you, beard!",
            BEAVER = "The beard ate %s!",
            BEAVERGHOST = "Still have good moustache, %s.",
            MOOSE = "Something different about beardman today.",
            MOOSEGHOST = "Wolfgang will find heart for antlered beard.",
            GOOSE = "Beardman become birdman! Ha ha!",
            GOOSEGHOST = "No fear birdman, Wolfgang will help!",
            FIRESTARTER = "Be careful! Do not burn, beard!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Is strong brainlady! Hello, tiny %s!",
            ATTACKER = "Ha ha! %s should not pick fight with dumb books!",
            MURDERER = "%s is killer!",
            REVIVER = "%s smell like mothballs and kindness.",
            GHOST = "Wolfgang will get raw pump-y heart for you!",
            FIRESTARTER = "Strong brainlady probably know what she's doing with fire.",
        },
        WES =
        {
            GENERIC = "Is tiny oddman, %s! Hello!",
            ATTACKER = "Wolfgang does not trust your rosy cheeks, %s.",
            MURDERER = "Ah! Is killer clown! %s!",
            REVIVER = "%s is nice, weird little man.",
            GHOST = "Wolfgang will go get heart for odd clownman!",
            FIRESTARTER = "You are looking very guilty, clownman.",
        },
        WEBBER =
        {
            GENERIC = "Is tiny monsterchild, %s! H-hello!",
            ATTACKER = "Ah! Tiny child is try to fight me!",
            MURDERER = "Monsterchild %s is killer! Wolfgang is run!",
            REVIVER = "Creepy monster %s is nice kid.",
            GHOST = "Who squish small bug boy? Wolfgang will smash back!",
            FIRESTARTER = "Please no. Please no burnings!",
        },
        WATHGRITHR =
        {
            GENERIC = "Is very strong %s! Hello!",
            ATTACKER = "%s will make a worthy fight!",
            MURDERER = "Stronglady %s is killer!",
            REVIVER = "%s is nice, strong lady.",
            GHOST = "World needs stronglady! Wolfgang will get heart!",
            FIRESTARTER = "Why starting fires, stronglady? To fight them?",
        },
        WINONA =
        {
            GENERIC = "Is fixing lady, %s! Hello!",
            ATTACKER = "%s is breaking things!",
            MURDERER = "%s broke our friend!",
            REVIVER = "%s is kind lady.",
            GHOST = "Wolfgang will fix little %s with heart.",
            FIRESTARTER = "%s's fires is make Wolfgang nervous.",
        },
        WORTOX =
        {
            GENERIC = "Is scary horn man, %s! H-hello!",
            ATTACKER = "Your game is not nice, little horn man!",
            MURDERER = "Horn man is evil!",
            REVIVER = "Scary horn man is nice sometimes.",
            GHOST = "Fluffy ghost!",
            FIRESTARTER = "Fire is not game, horn man.",
        },
        WORMWOOD =
        {
            GENERIC = "Is leafy green man, %s! Hello!",
            ATTACKER = "%s is all bark AND all bite.",
            MURDERER = "%s is scary killer tree!",
            REVIVER = "%s is Wolfgang's best friend.",
            GHOST = "Little plant was overwatered, maybe?",
            FIRESTARTER = "Leafy green man did a fire booboo.",
        },
        WARLY =
        {
            GENERIC = "Is tasty-making man, %s! Hello!",
            ATTACKER = "Why not use fists for bread making, yes?",
            MURDERER = "Tasty-making man is murderer!",
            REVIVER = "%s has nice big heart.",
            GHOST = "Does tiny man %s need Mighty Wolfgang's help?",
            FIRESTARTER = "Tasty-making man was probably cook with big fire.",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua             OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua             FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER = 
        {
            GENERIC = "Why you follow, weird bug?",
            SLEEPING = "Time for Wolfgang to make escape!",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "Is shiny flower.",
            DEAD = "Is sad and shiny flower.",
        },
        GLOMMERWINGS = "Small like fairy wings.",
        GLOMMERFUEL = "Weird bug make weird poop.",
        BELL = "Bell make dainty sound.",
        STATUEGLOMMER =
        {
            GENERIC = "Why statue is not flying?",
            EMPTY = "Smash!",
        },

        LAVA_POND_ROCK = "Is just small rock.",

		WEBBERSKULL = "I crush skull!",
		WORMLIGHT = "Pretty light.",
		WORMLIGHT_LESSER = "Nice little light.",
		WORM =
		{
		    PLANT = "Pretty light.",
		    DIRT = "Is dirt moving?",
		    WORM = "Did not expect this!",
		},
        WORMLIGHT_PLANT = "Pretty light.",
		MOLE =
		{
			HELD = "Wolfgang have mercy for tiny soft animal.",
			UNDERGROUND = "Stay underground where you are safe from Wolfgang.",
			ABOVEGROUND = "Now you will know Wolfgang's strength!",
		},
		MOLEHILL = "Mole hole.",
		MOLEHAT = "Mole skin is stretchy.",

		EEL = "Eel needs cooking!",
		EEL_COOKED = "Eel has been cooked.",
		UNAGI = "Food makes me mighty!",
		EYETURRET = "Mighty structure will help me fight!",
		EYETURRET_ITEM = "It needs strong placing.",
		MINOTAURHORN = "Is trophy from mighty foe.",
		MINOTAURCHEST = "Chest have big strong horns.",
		THULECITE_PIECES = "Can smash together to make bigger piece!",
		POND_ALGAE = "Plant is so small! Is funny to me.",
		GREENSTAFF = "This stick has green gem in it.",
		GIFT = "Is nice little present!",
        GIFTWRAP = "Wolfgang needs help tying little bow.",
		POTTEDFERN = "Wolfgang worry greenthumb is gangrene.",
        SUCCULENT_POTTED = "Tough plant is mine.",
		SUCCULENT_PLANT = "Is tough plant.",
		SUCCULENT_PICKED = "Tough plant is not dead yet.",
		SENTRYWARD = "Wolfgang thinks is full of secrets.",
        TOWNPORTAL =
        {
			GENERIC = "Is friend-bringer!",
			ACTIVE = "Is ready now.",
		},
        TOWNPORTALTALISMAN = 
        {
			GENERIC = "Is rock for quick trip.",
			ACTIVE = "Is time to go.",
		},
        WETPAPER = "Wolfgang can rip like wet paper!",
        WETPOUCH = "Is treasure from pool.",
        MOONROCK_PIECES = "Is little pieces from moon!",
        MOONBASE =
        {
            GENERIC = "Little platform is still missing pieces.",
            BROKEN = "Tiny platform is broken!",
            STAFFED = "Is ready for good fight!",
            WRONGSTAFF = "Feels wrong to Wolfgang.",
            MOONSTAFF = "Sickly little light is not run out.",
        },
        MOONDIAL = 
        {
			GENERIC = "Wolfgang see moon reflection, but not his mighty self!",
			NIGHT_NEW = "Moon is hiding.",
			NIGHT_WAX = "Tiny moon is get bigger!",
			NIGHT_FULL = "Moon is very mighty!",
			NIGHT_WANE = "Moon is get sleepy.",
			CAVE = "Moon is shy in cave!",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
        },
		THULECITE = "Is pretty rock.",
		ARMORRUINS = "Protect me? I don't need it!",
		ARMORSKELETON = "Is scary strong bones.",
		SKELETONHAT = "Puts scary pictures in Wolfgang's head.",
		RUINS_BAT = "Is creepy.",
		RUINSHAT = "Is hat for king.",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "No bad light.",
            WARN = "The bad light comes soon.",
            WAXING = "The bad light is here and getting stronger.",
            STEADY = "I think bad light not get stronger.",
            WANING = "Bad light time is ending.",
            DAWN = "Good time is soon.",
            NOMAGIC = "Is safe from bad light.",
		},
		BISHOP_NIGHTMARE = "Is angry man. Should relax.",
		ROOK_NIGHTMARE = "Is no match for my mighty chest!",
		KNIGHT_NIGHTMARE = "Funny metal man.",
		MINOTAUR = "Strong! Like me! I like him!",
		SPIDER_DROPPER = "Scary spider from above.",
		NIGHTMARELIGHT = "Is light, but not good light.",
		NIGHTSTICK = "Wolfgang like fists better.",
		GREENGEM = "Is pretty and cannot be crushed. Like me!",
		MULTITOOL_AXE_PICKAXE = "Chop and dig! I can do that all day.",
		ORANGESTAFF = "Better to walk I think.",
		YELLOWAMULET = "Is glowing yellow.",
		GREENAMULET = "Is so light! Feels like nothingness!",
		SLURPERPELT = "Strange fur clump.",	

		SLURPER = "No! No! Stay off head!",
		SLURPER_PELT = "It's still moving!",
		ARMORSLURPER = "Is causing hunger or stopping it?",
		ORANGEAMULET = "For wearing around strong necks.",
		YELLOWSTAFF = "Pretty gem sits in stick.",
		YELLOWGEM = "Pretty rock.",
		ORANGEGEM = "Pretty rock.",
        OPALSTAFF = "Tiny stick make big cold!",
        OPALPRECIOUSGEM = "Is very nice little stone.",
        TELEBASE = 
		{
			VALID = "Glow is good sign.",
			GEMS = "Do not think it working.",
		},
		GEMSOCKET = 
		{
			VALID = "Pretty rock now hovers.",
			GEMS = "Is empty.",
		},
		STAFFLIGHT = "It hurts to touch.",
        STAFFCOLDLIGHT = "Is cold! Wolfgang will punch!",

        ANCIENT_ALTAR = "Is nasty, creepy altar.",

        ANCIENT_ALTAR_BROKEN = "Is broken altar.",

        ANCIENT_STATUE = "Ugly, ugly, ugly.",

        LICHEN = "I'm lichen this!",
		CUTLICHEN = "Tastes terrible.",

		CAVE_BANANA = "Is tasty!",
		CAVE_BANANA_COOKED = "Is warm and tasty!",
		CAVE_BANANA_TREE = "Hello, upside-down tree.",
		ROCKY = "He is mighty! Like me!",
		
		COMPASS =
		{
			GENERIC="Is all directions, but no directions.",
			N = "Is North.",
			S = "Is South.",
			E = "Is East.",
			W = "Is West.",
			NE = "Is Northeast.",
			SE = "Is Southeast.",
			NW = "Is Northwest.",
			SW = "Is Southwest.",
		},

        HOUNDSTOOTH = "Puppy tooth!",
        ARMORSNURTLESHELL = "Is sticky inside.",
        BAT = "Flying mousey!",
        BATBAT = "This club makes me feel funny.",
        BATWING = "Is all hairy and gross.",
        BATWING_COOKED = "Crispy!",
        BATCAVE = "It's the hidey hole for the flying mousies!",
        BEDROLL_FURRY = "So comfy!",
        BUNNYMAN = "Hello rabbit!",
        FLOWER_CAVE = "Is light plant.",
        GUANO = "More poop.",
        LANTERN = "It keeps me safe from dark.",
        LIGHTBULB = "Is food?",
        MANRABBIT_TAIL = "Puffy!",
        MUSHROOMHAT = "Is mushy-room... for head!",
        MUSHROOM_LIGHT2 =
        {
            ON = "Tall mushy-room make very pretty light!",
            OFF = "How Wolfgang turn on mushy-room light?",
            BURNT = "No more little lights.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Is nice light. Soft.",
            OFF = "Big mushy-room make little light, maybe.",
            BURNT = "Little light burnt too bright?",
        },
        SLEEPBOMB = "Is bedtime for flinging.",
        MUSHROOMBOMB = "Is dangerous mushy-boom!",
        SHROOM_SKIN = "Is squishy yucky frogman skin!",
        TOADSTOOL_CAP =
        {
            EMPTY = "Is little dirt hole.",
            INGROUND = "Squishy thing in ground.",
            GENERIC = "Tiny mushy-room is no threat to Wolfgang!",
        },
        TOADSTOOL =
        {
            GENERIC = "Bah! Frogman was hiding like coward!",
            RAGE = "Frogman is very strong now!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Tall mushy-room looks very bad!",
            BURNT = "Tall mushy-room is burnt now!",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "Big mushtree is big.",
            BLOOM = "Woah! It's even bigger!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "Mushy bush.",
            BLOOM = "It's having fun!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Mushy shrub.",
            BLOOM = "Even smell is strong!",
        },
        MUSHTREE_TALL_WEBBED = "Aw, cheer up!",
        SPORE_TALL =
        {
            GENERIC = "Little blue bug has no wings.",
            HELD = "I make it my pet.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Is tiny red bug?",
            HELD = "I make it my pet.",
        },
        SPORE_SMALL =
        {
            GENERIC = "Nice green bug. Wolfgang will not swat.",
            HELD = "I make it my pet.",
        },
        RABBITHOUSE =
        {
            GENERIC = "I hear nomming inside.",
            BURNT = "Nomming is over.",
        },
        SLURTLE = "Ha! You are slow!",
        SLURTLE_SHELLPIECES = "Is broken.",
        SLURTLEHAT = "Keeps head safe.",
        SLURTLEHOLE = "Hole full of slugs.",
        SLURTLESLIME = "Boom snot!",
        SNURTLE = "Spirally!",
        SPIDER_HIDER = "Is scared spider!",
        SPIDER_SPITTER = "Ptoo! Ptoo!",
        SPIDERHOLE = "Spiders everywhere.",
        SPIDERHOLE_ROCK = "Spiders everywhere.",
        STALAGMITE = "Is pointy.",
        STALAGMITE_TALL = "Rock, reaching for the roof.",
        TREASURECHEST_TRAP = "Raagh!",

        TURF_CARPETFLOOR = "Step stones.",
        TURF_CHECKERFLOOR = "Step stones.",
        TURF_DIRT = "Step stones.",
        TURF_FOREST = "Step stones.",
        TURF_GRASS = "Step stones.",
        TURF_MARSH = "Step stones.",
        TURF_METEOR = "Step stones.",
        TURF_PEBBLEBEACH = "Step stones.",
        TURF_ROAD = "Step stones.",
        TURF_ROCKY = "Step stones.",
        TURF_SAVANNA = "Step stones.",
        TURF_WOODFLOOR = "Step stones.",

		TURF_CAVE="Step stones.",
		TURF_FUNGUS="Step stones.",
		TURF_SINKHOLE="Step stones.",
		TURF_UNDERROCK="Step stones.",
		TURF_MUD="Step stones.",

		TURF_DECIDUOUS = "Step stones.",
		TURF_SANDY = "Step stones.",
		TURF_BADLANDS = "Step stones.",
		TURF_DESERTDIRT = "Step stones.",
		TURF_FUNGUS_GREEN = "Step stones.",
		TURF_FUNGUS_RED = "Step stones.",
		TURF_DRAGONFLY = "Hot step stones.",

		POWCAKE = "Is made of nothings!",
        CAVE_ENTRANCE = "Even I am not that mighty.",
        CAVE_ENTRANCE_RUINS = "Even I am not that mighty.",
       
       	CAVE_ENTRANCE_OPEN = 
        {
            GENERIC = "Who wants to go in scary cave hole, anyway!",
            OPEN = "World has belly button!",
            FULL = "Too many peoples stuffed in there.",
        },
        CAVE_EXIT = 
        {
            GENERIC = "Please let Wolfgang out!",
            OPEN = "Is dark and scary down here.",
            FULL = "Please make room! Mighty Wolfgang is scared!",
        },

		MAXWELLPHONOGRAPH = "Is box that sings!",
		BOOMERANG = "Boom! A rang! Ha!",
		PIGGUARD = "Is bad piggie!",
		ABIGAIL = "Are you friendly ghost?",
		ADVENTURE_PORTAL = "Is mouth door! Say Ahhhhh!",
		AMULET = "Is very pretty.",
		ANIMAL_TRACK = "Animal went this way.",
		ARMORGRASS = "Is prickly.",
		ARMORMARBLE = "Tie rocks to many muscles.",
		ARMORWOOD = "Is almost strong as belly!",
		ARMOR_SANITY = "Is like wearing scary little rag!",
		ASH =
		{
			GENERIC = "Is skeleton of fire.",
			REMAINS_GLOMMERFLOWER = "Is burned pieces of flower from teleport!",
			REMAINS_EYE_BONE = "Is burned pieces of eyebone from teleport!",
			REMAINS_THINGIE = "Is burned pieces of some thing. Is dead now...",
		},
		AXE = "Chop!",
		BABYBEEFALO = 
		{
			GENERIC = "Baby hair-cow!",
		    SLEEPING = "Sleepy baby hair-cow!",
        },
        BUNDLE = "Is little surprise inside, maybe.",
        BUNDLEWRAP = "Is for hiding goodies.",
		BACKPACK = "Is for carry more thing.",
		BACONEGGS = "Food has yolk! And meat! More strong!",
		BANDAGE = "Can fix people!",
		BASALT = "Is stronger even than me!",
		BEARDHAIR = "Gross. These are not from my face.",
		BEARGER = "Wolfgang not want to fight big bear.",
		BEARGERVEST = "Big bear shirt.",
		ICEPACK = "Furry bag.",
		BEARGER_FUR = "Is like hair on Wolfgang chest.",
		BEDROLL_STRAW = "Nap time!",
		BEEQUEEN = "Is giant lady bee!",
		BEEQUEENHIVE = 
		{
			GENERIC = "Sticky stompy patch of muck!",
			GROWING = "Little hive is get bigger!",
		},
        BEEQUEENHIVEGROWN = "Wolfgang's mighty punches do nothing.",
        BEEGUARD = "Busy buzzy needle men!",
        HIVEHAT = "Makes Wolfgang feel special.",
        MINISIGN =
        {
            GENERIC = "Tiny picture is worth many, tinier words.",
            UNDRAWN = "Sign needs little scribbles!",
        },
        MINISIGN_ITEM = "Wolfgang will help punch into ground!",
		BEE =
		{
			GENERIC = "Is fat and angry-looking.",
			HELD = "Is safely in my pocket.",
		},
		BEEBOX =
		{
			READY = "Is ready for harvest!",
			FULLHONEY = "Is ready for harvest!",
			GENERIC = "Many bees!",
			NOHONEY = "It has no honey.",
			SOMEHONEY = "Bees are busy.",
			BURNT = "Bees are burned.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Is no more room for more mushy-rooms!",
			LOTS = "So many little mushy-rooms!",
			SOME = "Little mushy-rooms is start to grow.",
			EMPTY = "Is nothing.",
			ROTTEN = "Dead log is need to be replaced.",
			BURNT = "Log is not looking mighty!",
			SNOWCOVERED = "Mushy-rooms not mighty enough to fight snow!",
		},
		BEEFALO =
		{
			FOLLOWER = "Hair-cow follow me!",
			GENERIC = "Is hair-cow thing!",
			NAKED = "Hair-cow has no more hair.",
			SLEEPING = "Hair-cow is sleeping.",
            --Domesticated states:
            DOMESTICATED = "Hair-cow so fluffy and nice!",
            ORNERY = "You are feisty!",
            RIDER = "Like I'm back in cavalry!",
            PUDGY = "A critter after own heart!",
		},

		BEEFALOHAT = "Is good hat!",
		BEEFALOWOOL = "Clothes made of hair-cow.",
		BEEHAT = "Is hat for to protect from stinger bees.",
        BEESWAX = "Bee goop is smell nice.",
		BEEHIVE = "Oh, beehive!",
		BEEMINE = "Is ball full of angry bees.",
		BEEMINE_MAXWELL = "Is ball full of angry bitebugs.",
		BERRIES = "Is tasty!",
		BERRIES_COOKED = "Is more tasty!",
        BERRIES_JUICY = "Is extra sweet and juicy!",
        BERRIES_JUICY_COOKED = "Sweet, juicy berries is ready for eating!",
		BERRYBUSH =
		{
			BARREN = "I need to poop on it.",
			WITHERED = "Is too hot for bush.",
			GENERIC = "Is full of food-balls!",
			PICKED = "Eating part is gone.",
			DISEASED = "Is weak. Sickly!",
			DISEASING = "Is looking shrivelly.",
			BURNING = "Ah! Is burning!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "I need to poop on it to make juicy again.",
			WITHERED = "Is it dead?",
			GENERIC = "I will eat you!",
			PICKED = "Eating part is gone.",
			DISEASED = "Is weak. Sickly!",
			DISEASING = "Is looking shrivelly.",
			BURNING = "Ah! Is burning!",
		},
		BIGFOOT = "Foot is too big!",
		BIRDCAGE =
		{
			GENERIC = "Is home for birdies.",
			OCCUPIED = "Hello birdie!",
			SLEEPING = "I should be quiet!",
			HUNGRY = "I hear tiny grumbles!",
			STARVING = "His tiny stomach is empty!",
			DEAD = "Birdie? Are you okay?",
			SKELETON = "He is not okay.",
		},
		BIRDTRAP = "This will catch bird!",
		CAVE_BANANA_BURNT = "Is crisp.",
		BIRD_EGG = "Poor birdy.",
		BIRD_EGG_COOKED = "Yum!",
		BISHOP = "Padre!",
		BLOWDART_FIRE = "Careful, Wolfgang.",
		BLOWDART_SLEEP = "Dart do sleeping to enemies.",
		BLOWDART_PIPE = "Dart do pain to enemies.",
		BLOWDART_YELLOW = "Do not know if Wolfgang should be allowed to have this.",
		BLUEAMULET = "Would make good ice cube!",
		BLUEGEM = "Pretty rock.",
		BLUEPRINT = 
		{ 
            COMMON = "Pretty pictures!",
            RARE = "Very, very fancy pictures!",
        },
        SKETCH = "Picture will help Wolfgang carve nice rocks!",
		BLUE_CAP = "Is good for tired muscles, I think.",
		BLUE_CAP_COOKED = "Is not same.",
		BLUE_MUSHROOM =
		{
			GENERIC = "Is mushy room.",
			INGROUND = "Mushy room is hiding!",
			PICKED = "Is taken already.",
		},
		BOARDS = "Log was broken to make board!",
		BONESHARD = "Wolfgang crush into even smaller bones!",
		BONESTEW = "Is stew full of strong meat.",
		BUGNET = "Catch bugs.",
		BUSHHAT = "So sneaky!",
		BUTTER = "Is buttery, and taste like insect.",
		BUTTERFLY =
		{
			GENERIC = "Is pretty flutterby!",
			HELD = "My pet!",
		},
		BUTTERFLYMUFFIN = "Wolfgang did not know about bug muffin. Would like to taste.",
		BUTTERFLYWINGS = "No fly without wings!",
		BUZZARD = "Carry on.",

		SHADOWDIGGER = "Ha ha! Tiny men should dance for amusement!",

		CACTUS = 
		{
			GENERIC = "Wolfgang not like sharp plant.",
			PICKED = "Ha! Is flat plant.",
		},
		CACTUS_MEAT_COOKED = "Is safe now.",
		CACTUS_MEAT = "Spiky plant meat.",
		CACTUS_FLOWER = "Is not worth it.",

		COLDFIRE =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Good bye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not cold enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		CAMPFIRE =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Goodbye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not hot enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		CANE = "To walk AND hit things!",
		CATCOON = "Wolfgang does not trust it.",
		CATCOONDEN = 
		{
			GENERIC = "Stump is suspicious.",
			EMPTY = "Wolfgang more comfortable now that stump is empty.",
		},
		CATCOONHAT = "Hat of untrust-y-ness.",
		COONTAIL = "Wiggly cat part!",
		CARROT = "Is food. I guess.",
		CARROT_COOKED = "Is not more like meat after do cooking.",
		CARROT_PLANTED = "Is hiding?",
		CARROT_SEEDS = "Seeds is too small.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "Friends make little pictures to help Wolfgang not get lost!",
			BURNING = "Is no good!",
			BURNT = "No more little pictures.",
		},
		WATERMELON_SEEDS = "Maybe will grow into tasty snacks?",
		CAVE_FERN = "Pretty plant!",
		CHARCOAL = "Is like holding tiny dead tree.",
        CHESSPIECE_PAWN = "Little man is wearing little hat!",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Does not look like castle to Wolfgang.",
            STRUGGLE = "Wolfgang does not like moving statues!!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "Is good horsey, Wolfgang thinks.",
            STRUGGLE = "Wolfgang does not like moving statues!!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Weak little rock man looks nice.",
            STRUGGLE = "Wolfgang does not like moving statues!!",
        },
        CHESSPIECE_MUSE = "Faceless lady make Wolfgang uncomfortable.",
        CHESSPIECE_FORMAL = "Looks very not-mighty.",
        CHESSPIECE_HORNUCOPIA = "Why stone food hurt mouth?",
        CHESSPIECE_PIPE = "Might be good for lifting!",
        CHESSPIECE_DEERCLOPS = "Is scary monster statue.",
        CHESSPIECE_BEARGER = "Terrifying beast statue!",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Bad monster made of stone.",
        },
        CHESSPIECE_DRAGONFLY = "Is fiery killbeast, but stone.",
        CHESSPIECE_BUTTERFLY = "Is look like little flutterby, but bigger!",
        CHESSPIECE_ANCHOR = "Is big. And heavy. Wolfgang would like to lift.",
        CHESSPIECE_MOON = "Is look just like sky cheese!",
        CHESSJUNK1 = "Metal junk.",
        CHESSJUNK2 = "Metal junk.",
        CHESSJUNK3 = "Metal junk.",
		CHESTER = "Strange box with legs.",
		CHESTER_EYEBONE =
		{
			GENERIC = "It is eyebone. Eyebone connect to facebone.",
			WAITING = "It sleeps now.",
		},
		COOKEDMANDRAKE = "Little plant man is food?",
		COOKEDMEAT = "I made meat good with fire!",
		COOKEDMONSTERMEAT = "I still do not want to eat this.",
		COOKEDSMALLMEAT = "It is even smaller cooked!",
		COOKPOT =
		{
			COOKING_LONG = "This take long time.",
			COOKING_SHORT = "Is almost cook!",
			DONE = "Is time to eat!",
			EMPTY = "Wolfgang will cook good meal for friends, meal like home!",
			BURNT = "Pot is dead.",
		},
		CORN = "Is corn. What expect?",
		CORN_COOKED = "Pop pop pop! Ha ha, funny corn.",
		CORN_SEEDS = "Is seeds for grow corn.",
        CANARY =
		{
			GENERIC = "Is small yellow bird!",
			HELD = "Small bird fit easily in big Wolfgang hands.",
		},
        CANARY_POISONED = "Bird is okay?",

		CRITTERLAB = "Wolfgang hear little noises inside.",
        CRITTER_GLOMLING = "Flying bug friend!",
        CRITTER_DRAGONLING = "Mighty pet! Very good!",
		CRITTER_LAMB = "Is walking fluff!",
        CRITTER_PUPPY = "I am call him Pupgang!",
        CRITTER_KITTEN = "Small fur is Wolfgang's friend.",
        CRITTER_PERDLING = "Bird baby is weak, but good.",
		CRITTER_LUNARMOTHLING = "Strong Wolfgang will protect soft flutterby.",

		CROW =
		{
			GENERIC = "I do not like birds. Too fragile.",
			HELD = "He is squawky.",
		},
		CUTGRASS = "Is pile of grass.",
		CUTREEDS = "Is clump of reeds.",
		CUTSTONE = "Rock was crushed to make brick!",
		DEADLYFEAST = "Look like evil food.",
		DEER =
		{
			GENERIC = "Not very mighty. More fragile.",
			ANTLER = "Fuzzy fragile beast got mightier.",
		},
        DEER_ANTLER = "Is only mighty part of fragile beast.",
        DEER_GEMMED = "You stand no chance in fight with Wolfgang!",
		DEERCLOPS = "He looks mightier than me!",
		DEERCLOPS_EYEBALL = "Yuck yuck yuck!",
		EYEBRELLAHAT =	"Is always looking up.",
		DEPLETED_GRASS =
		{
			GENERIC = "Is tuft of grass.",
		},
        GOGGLESHAT = "Makes Wolfgang look very mighty.",
        DESERTHAT = "Sand cannot stop Wolfgang!",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "Dirty dirt.",
		DIVININGROD =
		{
			COLD = "The robot box is talking.",
			GENERIC = "Is robot box.",
			HOT = "Robot box is scaring me!",
			WARM = "Ha! That is good one, robot box!",
			WARMER = "Robot box is getting angry...",
		},
		DIVININGRODBASE =
		{
			GENERIC = "What is purpose?",
			READY = "Rod thing need key to make start.",
			UNLOCKED = "Rod thing is on!",
		},
		DIVININGRODSTART = "Is funny rod thing.",
		DRAGONFLY = "I confuse... Is dragonfly, or dragon-fly?",
		ARMORDRAGONFLY = "Wolfgang not need protection.",
		DRAGON_SCALES = "Glowy scales.",
		DRAGONFLYCHEST = "Chest is not afraid of fire.",
		DRAGONFLYFURNACE = 
		{
			HAMMERED = "Is very cute!",
			GENERIC = "Scaly pot for making hotness.", --no gems
			NORMAL = "Brainlady warned not to touch pot with bare hands.", --one gem
			HIGH = "Wolfgang hope does not burn moustache.", --two gems
		},
        
        HUTCH = "You are creepy.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Is tiny swimming teeth.",
            WAITING = "Is tiny floating teeth.",
        },
		LAVASPIT = 
		{
			HOT = "Is hot mouth germs.",
			COOL = "Is cold, hard mouth germs.",
		},
		LAVA_POND = "Is not time for swimming!",
		LAVAE = "I must run!",
		LAVAE_COCOON = "Maybe cold bug is friend?",
		LAVAE_PET = 
		{
			STARVING = "Tiny baby is starving!",
			HUNGRY = "Tiny baby is hungry.",
			CONTENT = "Tiny baby looks content.",
			GENERIC = "Tiny baby seems happy.",
		},
		LAVAE_EGG = 
		{
			GENERIC = "Is made of rock?",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "Little egg is shivering.",
			COMFY = "Little egg... seems comfortable.",
		},
		LAVAE_TOOTH = "What a mighty tooth!",

		DRAGONFRUIT = "Is funny-looking fruit.",
		DRAGONFRUIT_COOKED = "Is cooked but still look funny.",
		DRAGONFRUIT_SEEDS = "Could use to grow funny fruit, maybe.",
		DRAGONPIE = "Pie made of funny red fruit.",
		DRUMSTICK = "Leg meat for make legs more strong.",
		DRUMSTICK_COOKED = "Eat off bone is good.",
		DUG_BERRYBUSH = "He is cold and lonely.",
		DUG_BERRYBUSH_JUICY = "He is cold, and juicy.",
		DUG_GRASS = "He is cold and lonely.",
		DUG_MARSH_BUSH = "He is cold and lonely.",
		DUG_SAPLING = "He is cold and lonely.",
		DURIAN = "Is spiky smelly fruit.",
		DURIAN_COOKED = "Now is hot spiky smelly fruit.",
		DURIAN_SEEDS = "Tiny baby spiky fruit plant.",
		EARMUFFSHAT = "Is could make me look like little bunny!",
		EGGPLANT = "Is not egg!",
		EGGPLANT_COOKED = "Has no yolk! Yolk is strongest part!",
		EGGPLANT_SEEDS = "Teensy fake egg plant.",
		
		ENDTABLE = 
		{
			BURNT = "Is burny bits.",
			GENERIC = "Little flowers are weak, but look nice.",
			EMPTY = "Puny table will not hold Wolfgang's weight.",
			WILTED = "Little flowers are weaker than usual.",
			FRESHLIGHT = "Wolfgang does not like dark.",
			OLDLIGHT = "Please do not go out, little light.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE = 
		{
			BURNING = "Broke it.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You lose, tiny tree!",
			POISON = "Is big and angry tree.",
			GENERIC = "Hello, tree!",
		},
		ACORN = "I could crush the tree-seed with my hands!",
        ACORN_SAPLING = "It will be tree soon.",
		ACORN_COOKED = "Tree has been cooked out of nut.",
		BIRCHNUTDRAKE = "Is small and angry nut.",
		EVERGREEN =
		{
			BURNING = "Is broke.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You stood no chance!",
			GENERIC = "Hello, tree!",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Is broke.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You stood no chance!",
			GENERIC = "Cheer up, tree!",
		},
		TWIGGYTREE = 
		{
			BURNING = "Is broke.",
			BURNT = "Is small and broken now.",
			CHOPPED = "Ha! You stood no chance!",
			GENERIC = "Wolfgang will snap like toothpick!",			
			DISEASED = "Is weak. Sickly!",
		},
		TWIGGY_NUT_SAPLING = "Grow, grow little tree!",
        TWIGGY_OLD = "Wolfgang wishes to put weak tree out of misery!",
		TWIGGY_NUT = "Little cone make big tree!",
		EYEPLANT = "They are not what they seem.",
		INSPECTSELF = "Everyone! Come watch Wolfgang flex!",
		FARMPLOT =
		{
			GENERIC = "Will grow mighty crops here!",
			GROWING = "Grow my little friends! Grow!",
			NEEDSFERTILIZER = "Dirt is not dirty enough to make plants.",
			BURNT = "No more growing.",
		},
		FEATHERHAT = "Is silly hat of feather. Could make Wolfgang bird?",
		FEATHER_CROW = "Is feather of bird black.",
		FEATHER_ROBIN = "Is feather of bird red.",
		FEATHER_ROBIN_WINTER = "Is feather of bird white.",
		FEATHER_CANARY = "Is feather of bird yellow.",
		FEATHERPENCIL = "Wolfgang must stick pinky out when holding it.",
		FEM_PUPPET = "Scary chair scares her!",
		FIREFLIES =
		{
			GENERIC = "Sparkly!",
			HELD = "My pocket is sparkles!",
		},
		FIREHOUND = "Bark!",
		FIREPIT =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Good bye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not hot enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		COLDFIREPIT =
		{
			EMBERS = "The darkness is coming!",
			GENERIC = "Good bye dark times!",
			HIGH = "Is too much fire!",
			LOW = "The fire is not cold enough.",
			NORMAL = "Is good fire!",
			OUT = "Uh oh. It turned off.",
		},
		FIRESTAFF = "Is staff for make fire. Careful, Wolfgang.",
		FIRESUPPRESSOR = 
		{	
			ON = "I can throw better.",
			OFF = "Machine know Wolfgang is stronger.",
			LOWFUEL = "Are you hungry, machine?",
		},

		FISH = "Is fishy.",
		FISHINGROD = "Is for get fishy from pond place.",
		FISHSTICKS = "Ha ha, is funny name.",
		FISHTACOS = "Wolfgang hope is not too spicy.",
		FISH_COOKED = "Meat from water still make Wolfgang strong.",
		FLINT = "Is rock, but eh, pointy.",
		FLOWER = 
		{
            GENERIC = "They are very pretty.",
            ROSE = "Wolfgang tried to crush it, but it pricked him.",
        },
        FLOWER_WITHERED = "Aw, this one is sad.",
		FLOWERHAT = "Is so pretty!",
		FLOWER_EVIL = "Is not potato.",
		FOLIAGE = "Pretty plant is dead now.",
		FOOTBALLHAT = "To protect head!",
        FOSSIL_PIECE = "Is tiny bone!",
        FOSSIL_STALKER =
        {
			GENERIC = "Is not look done yet.",
			FUNNY = "Eh, maybe we take apart.",
			COMPLETE = "Is look good! Mighty!",
        },
        STALKER = "Skeleton should not be walking!",
        STALKER_ATRIUM = "Scary man!",
        STALKER_MINION = "I do not like it!",
        THURIBLE = "Is for monster control.",
        ATRIUM_OVERGROWTH = "Wolfgang cannot read.",
		FROG =
		{
			DEAD = "Is delicacy in my country.",
			GENERIC = "Hey little froggy, froggy.",
			SLEEPING = "Is asleep.",
		},
		FROGGLEBUNWICH = "Is sandwich with tasty leg meat.",
		FROGLEGS = "Is delicacy in my country!",
		FROGLEGS_COOKED = "Is mostly taste like chicken.",
		FRUITMEDLEY = "Is cup of teensy fruits.",
		FURTUFT = "Fur from bear?", 
		GEARS = "Ah ha! Who is bigger muscles now?",
		GHOST = "Aaaaaaaaaaah!",
		GOLDENAXE = "Fancy axe more good for chop.",
		GOLDENPICKAXE = "Fancy pickaxe do better smash.",
		GOLDENPITCHFORK = "Fancy pitchfork good for stab ground.",
		GOLDENSHOVEL = "Fancy shovel is good hole maker.",
		GOLDNUGGET = "Money is for tiny men!",
		GRASS =
		{
			BARREN = "It needs poop.",
			WITHERED = "Grass has been defeated by heat.",
			BURNING = "Not good!",
			GENERIC = "Is grass.",
			PICKED = "The grass has been defeated!",
			DISEASED = "Is weak. Sickly!",
			DISEASING = "Is looking shrivelly.",
		},
		GRASSGEKKO = 
		{
			GENERIC = "Lizard looks flimsy.",	
			DISEASED = "It looks worst than before.",
		},
		GREEN_CAP = "Is for salads. Blech.",
		GREEN_CAP_COOKED = "Is not same.",
		GREEN_MUSHROOM =
		{
			GENERIC = "Is mushy room.",
			INGROUND = "Mushy room is hiding!",
			PICKED = "Is taken already.",
		},
		GUNPOWDER = "Boom pepper!",
		HAMBAT = "Is still good.",
		HAMMER = "Needs sickle!",
		HEALINGSALVE = "Helps friends with boo-boos.",
		HEATROCK =
		{
			FROZEN = "Brrr! Is cold rock!",
			COLD = "Rock is a little bit cold.",
			GENERIC = "This round rock is like my head!",
			WARM = "Is pretty normal rock.",
			HOT = "Is hot enough for Wolfgang!",
		},
		HOME = "Tiny house for weaklings!",
		HOMESIGN =
		{
			GENERIC = "Is no time for reading signs!",
            UNWRITTEN = "Practice my letters!",
			BURNT = "Sign can't be read.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "Is no time for reading signs!",
            UNWRITTEN = "Practice my letters!",
			BURNT = "Sign can't be read.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Is no time for reading signs!",
            UNWRITTEN = "Practice my letters!",
			BURNT = "Sign can't be read.",
		},
		HONEY = "Is yum!",
		HONEYCOMB = "Bee used to live inside.",
		HONEYHAM = "Big meat with sweet is good meat.",
		HONEYNUGGETS = "Small meats with sweet still is good meat.",
		HORN = "Is hair-cow horn. Wolfgang hear hair-cow.",
		HOUND = "Woof!",
		HOUNDCORPSE =
		{
			GENERIC = "Wolfgang does not like look of this.",
			BURNING = "Fire is make yucky puppy go away.",
			REVIVING = "Wolfgang would like to run now!",
		},
		HOUNDBONE = "Wimpy woof dog was not strong enough.",
		HOUNDMOUND = "Is house of bones.",
		ICEBOX = "Box what makes cold!",
		ICEHAT = "Why put big ice on head?",
		ICEHOUND = "Bow wow!",
		INSANITYROCK =
		{
			ACTIVE = "Is in my way.",
			INACTIVE = "Hah. I step over tiny obstacle.",
		},
		JAMMYPRESERVES = "Oozes like tiny enemy I crush in hand.",

		KABOBS = "Eat off stick is good.",
		KILLERBEE =
		{
			GENERIC = "Angry bee!",
			HELD = "My angry bee!",
		},
		KNIGHT = "Horsey horse!",
		KOALEFANT_SUMMER = "Nose meat!",
		KOALEFANT_WINTER = "So soft, I want to squish it!",
		KRAMPUS = "Scary goat man! Run!",
		KRAMPUS_SACK = "Goat man finally give up his sack!",
		LEIF = "Wood man!",
		LEIF_SPARSE = "Wood man!",
		LIGHTER  = "Is tiny firebox!",
		LIGHTNING_ROD =
		{
			CHARGED = "Ooooh, sparks!",
			GENERIC = "Is wire in sky!",
		},
		LIGHTNINGGOAT = 
		{
			GENERIC = "Hello, goat.",
			CHARGED = "Is flash before eyes.",
		},
		LIGHTNINGGOATHORN = "Tiny lightning bone.",
		GOATMILK = "Milk for muscles!",
		LITTLE_WALRUS = "You think you are mightier than old man?",
		LIVINGLOG = "Creepy face log!",
		LOG =
		{
			BURNING = "When I stick my hand over it, it tickles.",
			GENERIC = "Remains of tree-fights!",
		},
		LUCY = "Wolfgang like a sharp missus.",
		LUREPLANT = "You cannot fool Wolfgang!",
		LUREPLANTBULB = "Ah ha! Who is tricky now?",
		MALE_PUPPET = "Scary chair scares him!",

		MANDRAKE_ACTIVE = "Little plant man friend!",
		MANDRAKE_PLANTED = "Is strange plant.",
		MANDRAKE = "Little plant man is died!",

        MANDRAKESOUP = "Little plant man is for make soup!",
        MANDRAKE_COOKED = "Little plant man is ready for eating!",
        MAPSCROLL = "No little pictures! Just paper.",
        MARBLE = "I can lift!",
        MARBLEBEAN = "Brainlady says is not for eat.",
        MARBLEBEAN_SAPLING = "Rock bush is growing!",
        MARBLESHRUB = "Rock is strongest bush!",
        MARBLEPILLAR = "Is too heavy to lift.",
        MARBLETREE = "Do not try punch tree.",
        MARSH_BUSH =
        {
			BURNT = "Spiky bush is gone now.",
            BURNING = "Uh oh. Spiky fire.",
            GENERIC = "Is thorny.",
            PICKED = "Thorns hurt.",
        },
        BURNT_MARSH_BUSH = "Is burnt now.",
        MARSH_PLANT = "Is plant.",
        MARSH_TREE =
        {
            BURNING = "Spikes is burned now!",
            BURNT = "Is spiky and black now.",
            CHOPPED = "Spikes is chopped now!",
            GENERIC = "Is spiky.",
        },
        MAXWELL = "A fancy suit is no match for my muscles!",
        MAXWELLHEAD = "Scary head is twelve feet tall!",
        MAXWELLLIGHT = "Scary light!",
        MAXWELLLOCK = "Scary lock!",
        MAXWELLTHRONE = "Scary chair!",
        MEAT = "Meat makes me strong!",
        MEATBALLS = "Ball of meats make me strong!",
        MEATRACK =
        {
            DONE = "Yum, meaty leather!",
            DRYING = "Dry meaty things! Dry!",
            DRYINGINRAIN = "Go away, rain! Meat is drying!",
            GENERIC = "For drying many meats!",
            BURNT = "Cannot dry meat now.",
            DONE_NOTMEAT = "Is very good and dry now!",
            DRYING_NOTMEAT = "Wolfgang could punch water out, maybe?",
            DRYINGINRAIN_NOTMEAT = "Sky tears is re-wetting Wolfgang's dry things!",
        },
        MEAT_DRIED = "Look like leather, taste like meat.",
        MERM = "Is fishy man!",
        MERMHEAD =
        {
            GENERIC = "What a handsome devil!",
            BURNT = "Not so nice looking now.",
        },
        MERMHOUSE =
        {
            GENERIC = "The house was not strong enough.",
            BURNT = "The house was really not strong enough.",
        },
        MINERHAT = "Lamp for put on head.",
        MONKEY = "Ugly monkey man!",
        MONKEYBARREL = "This... thing. It smells not so good.",
        MONSTERLASAGNA = "Taste like hairs and meats with noodle.",
        FLOWERSALAD = "Is not spinach, but maybe still work!",
        ICECREAM = "Well, is Sunday after all.",
        WATERMELONICLE = "Ha! Melon on a stick.",
        TRAILMIX = "Berries and nuts, berries and nuts!",
        HOTCHILI = "Haha, nothing is too spicy for Wolfgang!",
        GUACAMOLE = "Wolfgang does not trust green mush.",
        MONSTERMEAT = "It is not looking like food.",
        MONSTERMEAT_DRIED = "Look like leather, taste like leather.",
        MOOSE = "Very strange creature.",
        MOOSE_NESTING_GROUND = "Is big bird baby bed!",
        MOOSEEGG = "Breakfast for whole family!",
        MOSSLING = "Mmmm. Is still breakfast, I think.",
        FEATHERFAN = "Ha! Is as big as head!",
        MINIFAN = "It's so twirly when I run! Haha!",
        GOOSE_FEATHER = "Tickle tickle tickle!",
        STAFF_TORNADO = "Spin and spin!",
        MOSQUITO =
        {
            GENERIC = "Reminds me of uncle!",
            HELD = "No more blood for you!",
        },
        MOSQUITOSACK = "Uncle did not have gut like this.",
        MOUND =
        {
            DUG = "Sorry, dead peoples.",
            GENERIC = "Scary! Is probably full of bones!",
        },
        NIGHTLIGHT = "Is strange glow.",
        NIGHTMAREFUEL = "Scary stuff.",
        NIGHTSWORD = "Is real? Is not real? Is sharp!",
        NITRE = "Is rock, but different.",
        ONEMANBAND = "Is big and loud. I like!",
        OASISLAKE =
		{
			GENERIC = "Splishes and splashes.",
			EMPTY = "Lake should be here!",
		},
        PANDORASCHEST = "Fancy box!",
        PANFLUTE = "You want Wolfgang play folk song?",
        PAPYRUS = "Is like paper.",
        WAXPAPER = "Strange paper not for make scribblemarks.",
        PENGUIN = "Funny walking birds!",
        PERD = "Dumb bird is take all berries!",
        PEROGIES = "Wolfgang love pierogi!",
        PETALS = "These smell nice.",
        PETALS_EVIL = "They make my brain hurt.",
        PHLEGM = "Aha ha ha! Boogers! Oh ho ho!",
        PICKAXE = "Pick!",
        PIGGYBACK = "Smelly bag!",
        PIGHEAD =
        {
            GENERIC = "Why long face?",
            BURNT = "Why no face?",
        },
        PIGHOUSE =
        {
            FULL = "Come out and fight, pig man!",
            GENERIC = "Door is too small for my broad shoulders.",
            LIGHTSOUT = "Where did he go?",
            BURNT = "Pig home is gone.",
        },
        PIGKING = "Ha! Is good people!",
        PIGMAN =
        {
            DEAD = "No! The pig is dead!",
            FOLLOWER = "Is friend now!",
            GENERIC = "Hello pig. How are you?",
            GUARD = "Does he even lift?",
            WEREPIG = "Angry piggie!",
        },
        PIGSKIN = "Why long butt? Ha ha, Wolfgang is funny man.",
        PIGTENT = "Is tent of pigs.",
        PIGTORCH = "How is fire made?",
        PINECONE = "I could crush the tree-seed with my hands!",
        PINECONE_SAPLING = "It will be tree soon.",
        LUMPY_SAPLING = "It pushed right up from the dirt!",
        PITCHFORK = "Reminds me of childhood.",
        PLANTMEAT = "What is this? Meat for baby man?",
        PLANTMEAT_COOKED = "Is slightly better now.",
        PLANT_NORMAL =
        {
            GENERIC = "Leafy!",
            GROWING = "Is still growing.",
            READY = "Mmmm. Is tasty now.",
            WITHERED = "Is sad and dried plant.",
        },
        POMEGRANATE = "Look like smartypants brain.",
        POMEGRANATE_COOKED = "Ha ha ha! Brain is cooked! Not so smart now.",
        POMEGRANATE_SEEDS = "Is piece of brain?",
        POND = "Is all wet.",
        POOP = "Smelly!",
        FERTILIZER = "Bucket full of smelly.",
        PUMPKIN = "Is big as head of weakling man! Not Wolfgang head.",
        PUMPKINCOOKIE = "Is tasty cookie.",
        PUMPKIN_COOKED = "Very gourd!",
        PUMPKIN_LANTERN = "Now is actual head! Wolfgang afraid!",
        PUMPKIN_SEEDS = "This grow food size of wimpy head.",
        PURPLEAMULET = "This amulet... it frightens Wolfgang.",
        PURPLEGEM = "Prettier rock.",
        RABBIT =
        {
            GENERIC = "Tiny rabbit! Hide from me!",
            HELD = "He is my friend.",
        },
        RABBITHOLE =
        {
            GENERIC = "You can not hide forever, jumping meat!",
            SPRING = "Is busy time in rabbit home.",
        },
        RAINOMETER =
        {
            GENERIC = "Splish! Splash!",
            BURNT = "Crackle!",
        },
        RAINCOAT = "Dry is nice.",
        RAINHAT = "Is like water off mole's back.",
        RATATOUILLE = "Is food. Sort of.",
        RAZOR = "My skin is too strong for hairs!",
        REDGEM = "Pretty rock.",
        RED_CAP = "Oh! Is pretty and shiny!",
        RED_CAP_COOKED = "Is not same.",
        RED_MUSHROOM =
        {
            GENERIC = "Is mushy room.",
            INGROUND = "Mushy room is hiding!",
            PICKED = "Is taken already.",
        },
        REEDS =
        {
            BURNING = "Not good!",
            GENERIC = "Is watery grass.",
            PICKED = "Watery grass has been beaten!",
        },
        RELIC = "Is junk?",
        RUINS_RUBBLE = "I will make better with crushing.",
        RUBBLE = "Broken house stuff.",
        RESEARCHLAB =
        {
            GENERIC = "I am not sure how I feel about... science.",
            BURNT = "Science not so strong after all.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "I am not sure how I feel about... science.",
            BURNT = "Science not so strong after all.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "What has Wolfgang done?",
            BURNT = "Well, is over now.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "Hat not just for head.",
            BURNT = "Hat also for burning.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "I'm not going to die.",
            BURNT = "Better him than Wolfgang.",
        },
        RESURRECTIONSTONE = "Hop on rock!",
        ROBIN =
        {
            GENERIC = "Is pretty red color bird.",
            HELD = "Is happy bird in pocket.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Is pretty white color bird.",
            HELD = "Is fluffy bird. Nice bird.",
        },
        ROBOT_PUPPET = "Scary chair scares them!",
        ROCK_LIGHT =
        {
            GENERIC = "A pile of crusty rocks!",
            OUT = "Ha! More thing to smash!",
            LOW = "Is getting cold.",
            NORMAL = "Liquid fire!",
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Is no trouble to lift boulder.",
            RAISED = "Wolfgang must move other rocks.",
        },
        ROCK = "Everyone watch! Wolfgang will deadlift!",
        PETRIFIED_TREE = "Now I punch it apart!",
        ROCK_PETRIFIED_TREE = "Now I punch it apart!",
        ROCK_PETRIFIED_TREE_OLD = "Now I punch it apart!",
        ROCK_ICE =
        {
            GENERIC = "Rocks made of water.",
            MELTED = "I cannot grab water.",
        },
        ROCK_ICE_MELTED = "I cannot grab water.",
        ICE = "Good for refreshing snack.",
        ROCKS = "Is rock. What you not get?",
        ROOK = "This one jumps the queen!",
        ROPE = "Strong! Like me!",
        ROTTENEGG = "Stinky!",
        ROYAL_JELLY = "Sticky power goo!",
        JELLYBEAN = "Little tiny taste beans.",
        SADDLE_BASIC = "Just need creature mighty enough to hold me!",
        SADDLE_RACE = "Butterflies feel soft under Wolfgang's strong butt!",
        SADDLE_WAR = "We ride like kings!",
        SADDLEHORN = "I won't hurt you, hair cow!",
        SALTLICK = "Heh heh. Hair cow has funny tongue!",
        BRUSH = "For brush really strong hair!",
		SANITYROCK =
		{
			ACTIVE = "Is beautiful!",
			INACTIVE = "Is hiding underground.",
		},
		SAPLING =
		{
			BURNING = "Oops.",
			WITHERED = "Puny tree could not take heat.",
			GENERIC = "Puny tree! I am stronger than you!",
			PICKED = "Ha! Ha! Ha! Tree is floppy!",
			DISEASED = "Is weak. Sickly!",
			DISEASING = "Is look even more puny.",
		},
   		SCARECROW = 
   		{
			GENERIC = "Ha! Is not man! Is straw!",
			BURNING = "Little straw man is burning!",
			BURNT = "Little straw man is dead.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Is table for rocks!",
			BLOCK = "Is time for arts and crafts!",
			SCULPTURE = "Does not compare to chiseled jaw of Wolfgang!",
			BURNT = "Is burny bits.",
   		},
        SCULPTURE_KNIGHTHEAD = "Everyone! Watch Wolfgang carry horse head!",
		SCULPTURE_KNIGHTBODY = 
		{
			COVERED = "Is big fancy rock!",
			UNCOVERED = "Hidden marble man has big booboo.",
			FINISHED = "Booboo is all better!",
			READY = "Stone is getting scarier!",
		},
        SCULPTURE_BISHOPHEAD = "Watch Wolfgang lift little marble head!",
		SCULPTURE_BISHOPBODY = 
		{
			COVERED = "Lumpy, bumpy rock!",
			UNCOVERED = "Strange little man was in big rock!",
			FINISHED = "Marble man is fixed!",
			READY = "Stone is getting scarier!",
		},
        SCULPTURE_ROOKNOSE = "Wolfgang will carry long rock, is no problem!",
		SCULPTURE_ROOKBODY = 
		{
			COVERED = "Does not budge, even under Wolfgang's mighty strength!",
			UNCOVERED = "Is many big rocks!",
			FINISHED = "Rock has all pieces now.",
			READY = "Stone is getting scarier!",
		},
        GARGOYLE_HOUND = "Is make Wolfgang uncomfortable!",
        GARGOYLE_WEREPIG = "Wolfgang does not like that.",
		SEEDS = "Too small to eat.",
		SEEDS_COOKED = "Fire make bigger, can eat now.",
		SEWING_KIT = "Is pokey!",
		SEWING_TAPE = "Is sticky and good for mending!",
		SHOVEL = "Dirt spoon!",
		SILK = "Is too fancy.",
		SKELETON = "Not enough muscle.",
		SCORCHED_SKELETON = "Wolfgang does not like this!!",
		SKULLCHEST = "This man had big head!",
		SMALLBIRD =
		{
			GENERIC = "Is very small bird.",
			HUNGRY = "Small bird is hungry.",
			STARVING = "Small bird will die from starving.",
			SLEEPING = "Small bird sleeps now.",
		},
		SMALLMEAT = "Too small! Need bigger meat!",
		SMALLMEAT_DRIED = "Look like leather, taste like meat.",
		SPAT = "Look so friendly and cuddly.",
		SPEAR = "It gave me a sliver.",
		SPEAR_WATHGRITHR = "Is a good weapon.",
		WATHGRITHRHAT = "Is strong helm for strong warrior!",
		SPIDER =
		{
			DEAD = "Is made of sticky goo!",
			GENERIC = "He has scary face!",
			SLEEPING = "Walk quiet, he might not see me.",
		},
		SPIDERDEN = "The bugs are hiding in there.",
		SPIDEREGGSACK = "Nasty spider eggs.",
		SPIDERGLAND = "Squishy and wobbly!",
		SPIDERHAT = "Is like smooch from giant bug.",
		SPIDERQUEEN = "Oh no! Walking bug-house!",
		SPIDER_WARRIOR =
		{
			DEAD = "Not scary now!",
			GENERIC = "This one extra scary.",
			SLEEPING = "I think not smart to poke it.",
		},
		SPOILED_FOOD = "Is ball of yuck!",
        STAGEHAND =
        {
			AWAKE = "GAH! Table is creepy walking fist!",
			HIDING = "Wolfgang has no use for tiny table.",
        },
        STATUE_MARBLE = 
        {
            GENERIC = "Wolfgang does not know what to do with pretty statues.",
            TYPE1 = "Has funny little hat.",
            TYPE2 = "She seems like happy lady.",
            TYPE3 = "Is manly spittoon?", --bird bath type statue
        },
		STATUEHARP = "Where is pretty music?",
		STATUEMAXWELL = "Ha ha! Looks just like Wolfgang's new friend!",
		STEELWOOL = "Is like my arm hair.",
		STINGER = "Is sharp like skewer!",
		STRAWHAT = "Is good hat!",
		STUFFEDEGGPLANT = "Make yolk of other foods.",
		SWEATERVEST = "Is vest with pattern for fancy man.",
		REFLECTIVEVEST = "A vest's a vest.",
		HAWAIIANSHIRT = "Is vacation shirt.",
		TAFFY = "Is taffy for crushing!",
		TALLBIRD = "Is tallest bird!",
		TALLBIRDEGG = "There is bird inside.",
		TALLBIRDEGG_COOKED = "Cooked bird. Good for breakfast!",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Bird is like ice cube!",
			GENERIC = "Little bird is trying to get out.",
			HOT = "Is too hot for little bird!",
			LONG = "I wait for bird.",
			SHORT = "Bird comes soon.",
		},
		TALLBIRDNEST =
		{
			GENERIC = "Is big egg!",
			PICKED = "Is nest of emptiness.",
		},
		TEENBIRD =
		{
			GENERIC = "Hah! Not so tall.",
			HUNGRY = "Is hungry, and noisy.",
			STARVING = "Is hungry, noisy, and angry!",
			SLEEPING = "Bird is sleeping.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "I do not fear what lies beyond!",
			GENERIC = "Strange rock. Do I sit on?",
			LOCKED = "Something missing still.",
			PARTIAL = "Is coming together now.",
		},
		TELEPORTATO_BOX = "Has little lever.",
		TELEPORTATO_CRANK = "Bendy thing is made of metal!",
		TELEPORTATO_POTATO = "Ha ha! Ha ha! What ugly potato!",
		TELEPORTATO_RING = "I can bend into perfect circle!",
		TELESTAFF = "Fancy headache stick.",
		TENT = 
		{
			GENERIC = "It is time for a mighty nap.",
			BURNT = "Nothing left to nap in.",
		},
		SIESTAHUT = 
		{
			GENERIC = "Napping place.",
			BURNT = "Napping place is gone.",
		},
		TENTACLE = "Skinny monster!",
		TENTACLESPIKE = "Perfect for sticking!",
		TENTACLESPOTS = "Yuck! Slimy!",
		TENTACLE_PILLAR = "Lots of little friends!",
        TENTACLE_PILLAR_HOLE = "You run away from mighty Wolfgang?",
		TENTACLE_PILLAR_ARM = "Tiny tentacle baby thing! Ha!",
		TENTACLE_GARDEN = "Hmmmm, suspicious!",
		TOPHAT = "Is good hat!",
		TORCH = "Attack night with fire stick!",
		TRANSISTOR = "Science bean.",
		TRAP = "No trap can hold me!",
		TRAP_TEETH = "It bites bottoms from below!",
		TRAP_TEETH_MAXWELL = "Whoever put this is bad fella!",
		TREASURECHEST = 
		{
			GENERIC = "I put stuff there!",
			BURNT = "Nothing will stay inside.",
		},
		TREASURECHEST_TRAP = "Raagh!",
		SACRED_CHEST = 
		{
			GENERIC = "Is little scare-chest.",
			LOCKED = "Is thinking.",
		},
		TREECLUMP = "Do not block Wolfgang's way!",
		
		TRINKET_1 = "Glob of glass!", --Melted Marbles
		TRINKET_2 = "Fake bless you.", --Fake Kazoo
		TRINKET_3 = "Is knot what Wolfgang expected.", --Gord's Knot
		TRINKET_4 = "Ha ha! Is tiny man!", --Gnome
		TRINKET_5 = "What is do?", --Toy Rocketship
		TRINKET_6 = "Robot bits.", --Frazzled Wires
		TRINKET_7 = "Tiny torchlady Willow start firepits with toy! Very impressive.", --Ball and Cup
		TRINKET_8 = "Hardened, like Wolfgang.", --Rubber Bung
		TRINKET_9 = "Strong brainlady Wickerbottom maybe need for repair cardigans.", --Mismatched Buttons
		TRINKET_10 = "Is pearly chompers!", --Dentures
		TRINKET_11 = "Angry metal friend WX would like this, yes!", --Lying Robot
		TRINKET_12 = "Yuck.", --Dessicated Tentacle
		TRINKET_13 = "Ah! Is scary Wendy girl! ...No, wait, is just toy.", --Gnomette
		TRINKET_14 = "Beard will not like such pictures.", --Leaky Teacup
		TRINKET_15 = "Junk from braingame!", --Pawn
		TRINKET_16 = "Junk from braingame!", --Pawn
		TRINKET_17 = "Is still good!", --Bent Spork
		TRINKET_18 = "Wheeled horsey!", --Trojan Horse
		TRINKET_19 = "Could give it a spin.", --Unbalanced Top
		TRINKET_20 = "Wolfgang's arms too thick to reach back.", --Backscratcher
		TRINKET_21 = "Is fun to crank.", --Egg Beater
		TRINKET_22 = "Will take to fragile man Maxwell. He always talk about \"pulling strings\".", --Frayed Yarn
		TRINKET_23 = "Wolfgang does not know which end to blow.", --Shoehorn
		TRINKET_24 = "Wolfgang does not like even fake cat.", --Lucky Cat Jar
		TRINKET_25 = "Smell like laundry.", --Air Unfreshener
		TRINKET_26 = "Is cup made of potato, I think.", --Potato Cup
		TRINKET_27 = "Is skinny and bendy, like clownman Wes.", --Coat Hanger
		TRINKET_28 = "Junk from braingame!", --Rook
        TRINKET_29 = "Junk from braingame!", --Rook
        TRINKET_30 = "Junk from braingame!", --Knight
        TRINKET_31 = "Junk from braingame!", --Knight
        TRINKET_32 = "Wolfgang does not like spooky magics.", --Cubic Zirconia Ball
        TRINKET_33 = "Wolfgang not wear creepy finger-spider.", --Spider Ring
        TRINKET_34 = "Is soft, but spooky.", --Monkey Paw
        TRINKET_35 = "Little potion make Wolfgang mighty?", --Empty Elixir
        TRINKET_36 = "Gah! Do not scare Wolfgang!", --Faux fangs
        TRINKET_37 = "Stab-stick is useless now.", --Broken Stake
        TRINKET_38 = "Is making tiny friends look tinier!", -- Binoculars Griftlands trinket
        TRINKET_39 = "Is just one glove.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Wolfgang has no use for tiny garbage.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Wolfgang will crush it!", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Is tiny scary thing.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Is tiny toy monster.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Is very broke.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Wolfgang can barely hear this.", -- Odd Radio ONI trinket
        TRINKET_46 = "Is useless thing, I think.", -- Hairdryer ONI trinket
        
        HALLOWEENCANDY_1 = "Wolfgang eat many bushels!",
        HALLOWEENCANDY_2 = "Little corns get stuck in Wolfgang's mighty moustache!",
        HALLOWEENCANDY_3 = "Very bland. Reminds Wolfgang of back home candy!",
        HALLOWEENCANDY_4 = "Wolfgang feel strong when mashing tiny spiders between teeth!",
        HALLOWEENCANDY_5 = "Wolfgang not sure he has heart to eat.",
        HALLOWEENCANDY_6 = "Maybe is chocolate?",
        HALLOWEENCANDY_7 = "Little shrivelly sadlumps.",
        HALLOWEENCANDY_8 = "Is tasty little treat!",
        HALLOWEENCANDY_9 = "Is look yucky, but taste okay.",
        HALLOWEENCANDY_10 = "Is tasty little treat!",
        HALLOWEENCANDY_11 = "Little men of chocolate stand no chance against Wolfgang!",
        HALLOWEENCANDY_12 = "Is gross little candy bugs!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Hard candy is strong like Wolfgang!", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Is too hot for Wolfgang!!", --Hot Lava pepper candy
        CANDYBAG = "Is little bag for scary goodies!",

		HALLOWEEN_ORNAMENT_1 = "Wolfgang should be hanging it somewhere.",
		HALLOWEEN_ORNAMENT_2 = "Is real bat?! Is not real bat.",
		HALLOWEEN_ORNAMENT_3 = "Is for decorating.", 
		HALLOWEEN_ORNAMENT_4 = "Wolfgang needs to be decorating.",
		HALLOWEEN_ORNAMENT_5 = "Wolfgang could hang somewheres.",
		HALLOWEEN_ORNAMENT_6 = "Little fake birdy is needing tree!", 

		HALLOWEENPOTION_DRINKS_WEAK = "Is okay, but big Wolfgang need big drink!",
		HALLOWEENPOTION_DRINKS_POTENT = "Is strong like Wolfgang!",
        HALLOWEENPOTION_BRAVERY = "Wolfgang is brave. Is making Wolfgang braver.",
		HALLOWEENPOTION_FIRE_FX = "Is making fire go boom boom!", 
		MADSCIENCE_LAB = "Is making Wolfgang brain hurt.",
		LIVINGTREE_ROOT = "Hello little sticky!", 
		LIVINGTREE_SAPLING = "Grow big and strong so Wolfgang can decorate!",

        DRAGONHEADHAT = "Wolfgang will be mighty beast!",
        DRAGONBODYHAT = "Is tums of big scarebeast.",
        DRAGONTAILHAT = "Mighty rear!",
        PERDSHRINE =
        {
            GENERIC = "Top is look like berry bird.",
            EMPTY = "Is wanting little bush plant?",
            BURNT = "Is small and broken now.",
        },
        REDLANTERN = "Wolfgang does not like the dark.",
        LUCKY_GOLDNUGGET = "Is money?",
        FIRECRACKERS = "Crackle bangs!",
        PERDFAN = "Wolfgang feel very lucky!",
        REDPOUCH = "Is good color!",
        WARGSHRINE = 
        {
            GENERIC = "Stick made shiny puppy happy!",
            EMPTY = "Shiny puppy is wanting to play fetch.",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Puppy box is burned.",
        },
        CLAYWARG = 
        {
        	GENERIC = "Big clay puppy!",
        	STATUE = "Is scary statue.",
        },
        CLAYHOUND = 
        {
        	GENERIC = "Ruff, ruff!",
        	STATUE = "Little dog does not bark!",
        },
        HOUNDWHISTLE = "Tiny whistle stick makes no noise!",
        CHESSPIECE_CLAYHOUND = "Is nice little doggy.",
        CHESSPIECE_CLAYWARG = "It looks like scary monster!",

		PIGSHRINE =
		{
            GENERIC = "Is pretty piggy.",
            EMPTY = "Wolfgang give it meat.",
            BURNT = "Poor little piggy.",
		},
		PIG_TOKEN = "Is not fitting Wolfgang.",
		YOTP_FOOD1 = "Make Wolfgang mighty!",
		YOTP_FOOD2 = "Is not for Wolfgang.",
		YOTP_FOOD3 = "Is for making Wolfgang little bit mighty.",

		PIGELITE1 = "Wolfgang wave to little piggy!", --BLUE
		PIGELITE2 = "He is having nasty temper.", --RED
		PIGELITE3 = "Is dirty fighter.", --WHITE
		PIGELITE4 = "Is mighty. Wolfgang mightier.", --GREEN

		BISHOP_CHARGE_HIT = "Rrrraa!",
		TRUNKVEST_SUMMER = "Is warm fuzzy nose.",
		TRUNKVEST_WINTER = "Cozy nosy!",
		TRUNK_COOKED = "Is cooked nose.",
		TRUNK_SUMMER = "Is floppy nose.",
		TRUNK_WINTER = "Is floppy hairy nose.",
		TUMBLEWEED = "Come back little tumbling ball!",
		TURKEYDINNER = "Is good feast of bird meat.",
		TWIGS = "Puny twigs! I will break them!",
		UMBRELLA = "The rain hurts my mighty skin.",
		GRASS_UMBRELLA = "I do not like tiny umbrella.",
		UNIMPLEMENTED = "I do not trust unfinished business.",
		WAFFLES = "Why does bread have holes?",
		WALL_HAY = 
		{	
			GENERIC = "Wall is made of grass!",
			BURNT = "Grass burned up!",
		},
		WALL_HAY_ITEM = "Scratchy straws!",
		WALL_STONE = "Wall is strong like me!",
		WALL_STONE_ITEM = "Piles of rocks!",
		WALL_RUINS = "Old wall is strong!",
		WALL_RUINS_ITEM = "Stack of old rocks!",
		WALL_WOOD = 
		{
			GENERIC = "Hello, pointy sticks!",
			BURNT = "Goodbye, pointy sticks!",
		},
		WALL_WOOD_ITEM = "Pokey sticks!",
		WALL_MOONROCK = "Rock of moon protects Wolfgang.",
		WALL_MOONROCK_ITEM = "Can build with power of moon!",
		FENCE = "I do not like trapping little animals.",
        FENCE_ITEM = "Wolfgang will help make fence!",
        FENCE_GATE = "Is little flimsy swingboards.",
        FENCE_GATE_ITEM = "Wolfgang will help make swingboards!",
		WALRUS = "Ha ha. Is blubbery flubbery man.",
		WALRUSHAT = "Sea cow man hat!",
		WALRUS_CAMP =
		{
			EMPTY = "Is locked.",
			GENERIC = "How do they all fit?",
		},
		WALRUS_TUSK = "Sea cow man tooth!",
		WARDROBE = 
		{
			GENERIC = "Box of clothes!",
            BURNING = "Box of fire!",
			BURNT = "Box all gone.",
		},
		WARG = "Big puppy!",
		WASPHIVE = "Mind says no. Muscles say yes!",
		WATERBALLOON = "Is very squishy-wobbly!",
		WATERMELON = "So many seeds.",
		WATERMELON_COOKED = "Seeds is cooked out of melon now.",
		WATERMELONHAT = "Why not wear melon on head! Haha!",
		WAXWELLJOURNAL = "Wolfgang is glad he cannot read!",
		WETGOOP = "Is not bad to eat, but is not good.",
        WHIP = "Good to floss teeth with.",
		WINTERHAT = "It make ears happy in cold!",
		WINTEROMETER = 
		{
			GENERIC = "Cold go up! Red go down!",
			BURNT = "Flames go up! Measure machine go down!",
		},

        WINTER_TREE =
        {
            BURNT = "Happy tree is burn now.",
            BURNING = "Tree is not fireproof!",
            CANDECORATE = "Tree looks very happy!",
            YOUNG = "Is growing.",
        },
		WINTER_TREESTAND = 
		{
			GENERIC = "Very nice little pot!",
            BURNT = "Happy tree is burn now.",
		},
        WINTER_ORNAMENT = "Is so small in Wolfgang's hand.",
        WINTER_ORNAMENTLIGHT = "Glass ball of twinkly light!",
        WINTER_ORNAMENTBOSS = "Pretty little token of mightiness!",
		WINTER_ORNAMENTFORGE = "Decoration of mighty enemy.",
		WINTER_ORNAMENTGORGE = "Hello, little friend!",

        WINTER_FOOD1 = "Little man will crumble under my mighty teeth!", --gingerbread cookie
        WINTER_FOOD2 = "Does Wolfgang have sugar in moustache?", --sugar cookie
        WINTER_FOOD3 = "Little sugar stick.", --candy cane
        WINTER_FOOD4 = "Wolfgang does not trust little fruit loaf.", --fruitcake
        WINTER_FOOD5 = "Ha! Wolfgang will eat log, just like beardman!", --yule log cake
        WINTER_FOOD6 = "Tiny yummy cakething make strong Wolfgang.", --plum pudding
        WINTER_FOOD7 = "Little fruit is sweet and tasty!", --apple cider
        WINTER_FOOD8 = "Wolfgang likes feeling cozy.", --hot cocoa
        WINTER_FOOD9 = "Is much protein inside, yes?", --eggnog

        KLAUS = "If Wolfgang had no eyes, he would not see terrible beast!",
        KLAUS_SACK = "Something inside for Wolfgang, maybe?",
		KLAUSSACKKEY = "Is very special antler!",
		WORMHOLE =
		{
			GENERIC = "Like soft pillow, growing on ground.",
			OPEN = "It can not harm this man!",
		},
		WORMHOLE_LIMITED = "Is not looking very good.",
		ACCOMPLISHMENT_SHRINE = "I will defeat you, tiny arrow!",        
		LIVINGTREE = "I do not like tree with eyes.",
		ICESTAFF = "Frosted tip.",
		REVIVER = "Blib blup! Blib blup! Blib blup!",
		SHADOWHEART = "Wolfgang is not shaking! Is manly flexing!!",
        ATRIUM_RUBBLE = 
        {
			LINE_1 = "Is picture of many sad, weak people.",
			LINE_2 = "Cannot tell what was picture of.",
			LINE_3 = "In picture darkness covers sad, weak people.",
			LINE_4 = "Monsters is bursting out of them!",
			LINE_5 = "Is picture of very pretty place.",
		},
        ATRIUM_STATUE = "Statue make Wolfgang's tummy do flip.",
        ATRIUM_LIGHT = 
        {
			ON = "This light is scarier than the dark.",
			OFF = "Is place for light.",
		},
        ATRIUM_GATE =
        {
			ON = "Little lights is on now.",
			OFF = "Is very old thing.",
			CHARGING = "Looks very scary now!",
			DESTABILIZING = "Is going to blow!",
			COOLDOWN = "Is needing to recharge.",
        },
        ATRIUM_KEY = "Little key is for make door.",
		LIFEINJECTOR = "EeeeEEeeEEE!!",
		SKELETON_PLAYER =
		{
			MALE = "Hah. %s did not have enough muscle to survive %s.",
			FEMALE = "Hah. %s did not have enough muscle to survive %s.",
			ROBOT = "Hah. %s did not have enough muscle to survive %s.",
			DEFAULT = "Hah. %s did not have enough muscle to survive %s.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "But is not cheese?",
		MOONROCKNUGGET = "But is not cheese?",
		MOONROCKCRATER = "Rock from moon has hole. Like a cheese!",
		MOONROCKSEED = "Is ball not for throwing.",

        REDMOONEYE = "Marks Wolfgang's way, and good weight for squats!",
        PURPLEMOONEYE = "Is creepy, but maybe Wolfgang not get lost so much now.",
        GREENMOONEYE = "Is never blinking.",
        ORANGEMOONEYE = "Tiny rock watches Wolfgang wherever he go.",
        YELLOWMOONEYE = "Hmm, maybe Wolfgang try shotput?",
        BLUEMOONEYE = "Is small, but not crushable.",

        --Arena Event
        LAVAARENA_BOARLORD = "Is important-looking man.",
        BOARRIOR = "Large pig man cannot out-muscle Wolfgang!",
        BOARON = "Tiny pig cannot hurt Wolfgang.",
        PEGHOOK = "Wolfgang will beat you with fists!",
        TRAILS = "Wolfgang is stronger than you!",
        TURTILLUS = "Armor is for tiny men!",
        SNAPPER = "I will smush lizard man!",
		RHINODRILL = "Wolfgang is more macho.",
		BEETLETAUR = "Is not scaring Wolfgang.",

        LAVAARENA_PORTAL = 
        {
            ON = "Goodbye, puny fire world!",
            GENERIC = "Is how Wolfgang got here.",
        },
        LAVAARENA_KEYHOLE = "Nothing here.",
		LAVAARENA_KEYHOLE_FULL = "Is ready now.",
        LAVAARENA_BATTLESTANDARD = "We must all smash little flag!",
        LAVAARENA_SPAWNER = "Little circle! Give me many things to fight!",

        HEALINGSTAFF = "Wolfgang cannot fight with twig.",
        FIREBALLSTAFF = "Puny stick is not for Wolfgang.",
        HAMMER_MJOLNIR = "Wolfgang is ready for high striker!",
        SPEAR_GUNGNIR = "Wolfgang will stab many foes!",
        BLOWDART_LAVA = "Wolfgang does not fight from afar.",
        BLOWDART_LAVA2 = "Wolfgang will not use wimpy weapon.",
        LAVAARENA_LUCY = "Is beard's axe.",
        WEBBER_SPIDER_MINION = "Is tiny monsters!",
        BOOK_FOSSIL = "Is look very hard to read.",
		LAVAARENA_BERNIE = "Nice little creepy bear.",
		SPEAR_LANCE = "Wolfgang likes swirly stab-stick.",
		BOOK_ELEMENTAL = "Wolfgang does not understand little letters.",
		LAVAARENA_ELEMENTAL = "Is rock friend.",

   		LAVAARENA_ARMORLIGHT = "Wolfgang does not want flimsy thing.",
		LAVAARENA_ARMORLIGHTSPEED = "Only cowards run from fights!",
		LAVAARENA_ARMORMEDIUM = "Is not very thick.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Wolfgang does not like weak armor.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Is too weak for Wolfgang.",
		LAVAARENA_ARMORHEAVY = "Armor is strong, like Wolfgang.",
		LAVAARENA_ARMOREXTRAHEAVY = "Is perfect fit for Wolfgang.",

		LAVAARENA_FEATHERCROWNHAT = "Silly little feather hat.",
        LAVAARENA_HEALINGFLOWERHAT = "It would make Wolfgang look nice.",
        LAVAARENA_LIGHTDAMAGERHAT = "Mighty little spike hat!",
        LAVAARENA_STRONGDAMAGERHAT = "Wolfgang would like to wear it.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Is useless leaf hat.",
        LAVAARENA_EYECIRCLETHAT = "Is no-good creepy hat.",
        LAVAARENA_RECHARGERHAT = "Nice little head rocks.",
        LAVAARENA_HEALINGGARLANDHAT = "Is many little fast flowers.",
        LAVAARENA_CROWNDAMAGERHAT = "Is so mighty!",

		LAVAARENA_ARMOR_HP = "Is mighty like Wolfgang.",

		LAVAARENA_FIREBOMB = "Wolfgang doesn't like.",
		LAVAARENA_HEAVYBLADE = "Is might sword for mighty Wolfgang!",

        --Quagmire
        QUAGMIRE_ALTAR = 
        {
        	GENERIC = "Little stone. Wolfgang will cook for you.",
        	FULL = "Enjoy hearty meal from Wolfgang!",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Nice stone lady.",
		QUAGMIRE_PARK_FOUNTAIN = "There is no water for little birdies.",
		
        QUAGMIRE_HOE = "Wolfgang must do farmwork for tastiest veggies.",
        
        QUAGMIRE_TURNIP = "I will use in many dishes! Yes!",
        QUAGMIRE_TURNIP_COOKED = "Smell is very good.",
        QUAGMIRE_TURNIP_SEEDS = "Is little tiny seeds for burying.",
        
        QUAGMIRE_GARLIC = "Is good flavor for stewing.",
        QUAGMIRE_GARLIC_COOKED = "Flavor is good now.",
        QUAGMIRE_GARLIC_SEEDS = "Is little tiny seeds for burying.",
        
        QUAGMIRE_ONION = "Wolfgang eats like apple when not cooking.",
        QUAGMIRE_ONION_COOKED = "Crispy, brown, sweet.",
        QUAGMIRE_ONION_SEEDS = "Is little tiny seeds for burying.",
        
        QUAGMIRE_POTATO = "Wolfgang's favorite veggie.",
        QUAGMIRE_POTATO_COOKED = "Is golden brown! Texture like sun!",
        QUAGMIRE_POTATO_SEEDS = "Is little tiny seeds for burying.",
        
        QUAGMIRE_TOMATO = "Is good for sauce makings.",
        QUAGMIRE_TOMATO_COOKED = "Roasty and toasty.",
        QUAGMIRE_TOMATO_SEEDS = "Is little tiny seeds for burying.",
        
        QUAGMIRE_FLOUR = "Is for dough and many good noodles.",
        QUAGMIRE_WHEAT = "Flour! Wolfgang will grind with bare hands!",
        QUAGMIRE_WHEAT_SEEDS = "Is little tiny seeds for burying.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "Is little tiny seeds for burying.",
        
        QUAGMIRE_ROTTEN_CROP = "Ground turned veggie to gunk.",
        
		QUAGMIRE_SALMON = "Is floppy, floppy fish.",
		QUAGMIRE_SALMON_COOKED = "Fish is cooked now.",
		QUAGMIRE_CRABMEAT = "Is meat of tiny pincher.",
		QUAGMIRE_CRABMEAT_COOKED = "Yummy, yummy pincher.",
        QUAGMIRE_POT = "Wolfgang put this over fire.",
        QUAGMIRE_POT_SMALL = "Friends, do not look! Pot needs to boil.",
        QUAGMIRE_POT_HANGER_ITEM = "Is make pot hang over fire.",
		QUAGMIRE_SUGARWOODTREE = 
		{
			GENERIC = "Is little tree of yummy goop.",
			STUMP = "Tree has been cut down!",
			TAPPED_EMPTY = "Little bucket needs to fill up.",
			TAPPED_READY = "Little bucket is full!",
			TAPPED_BUGS = "Wolfgang will crush tiny creatures.",
			WOUNDED = "Little tree has boo-boo.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB = 
		{
			GENERIC = "Is little shrub for eating.",
			PICKED = "We took the food bits.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "Is nice little garnish.",
		QUAGMIRE_SPOTSPICE_GROUND = "Wolfgang will cook delicious things.",
		QUAGMIRE_SAPBUCKET = "Is for get yummy tree goop.",
		QUAGMIRE_SAP = "Is yummy tree goop!",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Is ready!",
			GENERIC = "Is not ready yet.",
		},
		
		QUAGMIRE_POND_SALT = "Is tiny ocean.",
		QUAGMIRE_SALT_RACK_ITEM = "Mighty hands make quick work.",

		QUAGMIRE_SAFE = 
		{
			GENERIC = "What is inside?",
			LOCKED = "Punches do nothing.",
		},

		QUAGMIRE_KEY = "Wolfgang have key to treasure.",
		QUAGMIRE_KEY_PARK = "Haha! Wolfgang open gate now!",
        QUAGMIRE_PORTAL_KEY = "Is heavy key but Wolfgang strong!",

		
		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Wolfgang could use in soups.",
			PICKED = "No more for Wolfgang.",
		},
		QUAGMIRE_MUSHROOMS = "Mushrooms need cooking!",
        QUAGMIRE_MEALINGSTONE = "We must grind grain for bread!",
		QUAGMIRE_PEBBLECRAB = "Hello, itty bitty pincher!",

		
		QUAGMIRE_RUBBLE_CARRIAGE = "Is not work.",
        QUAGMIRE_RUBBLE_CLOCK = "Wolfgang cannot tell time.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Someone is smashed it.",
        QUAGMIRE_RUBBLE_PUBDOOR = "Is not going nowhere.",
        QUAGMIRE_RUBBLE_ROOF = "Wolfgang lift it, then Wolfgang have roof over head.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "Is working? No is not working.",
        QUAGMIRE_RUBBLE_BIKE = "Is busted.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Is no one here.",
            "Someone crushed homes.",
            "Must have made something angry.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Wolfgang will punch whatever did this.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Wolfgang not do this. But Wolfgang could.",
        QUAGMIRE_MERMHOUSE = "That house is for smelly fish men.",
        QUAGMIRE_SWAMPIG_HOUSE = "Wimpy house for hairy pigs.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Little house is ruined.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "He seems like good fellow!",
            SLEEPING = "Gone beddy-bye.",
        },
        QUAGMIRE_SWAMPIG = "Is big teeth you have!",
        
        QUAGMIRE_PORTAL = "It did not go home. Is no surprise.",
        QUAGMIRE_SALTROCK = "Wolfgang will crush bits into salt shaker.",
        QUAGMIRE_SALT = "Is make food taste good.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Is sad sight.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "Wolfgang will feed big sky beast!",
            MISMATCH = "Is not what sky beast wants.",
            MATCH = "Is good for sky beast.",
            MATCH_BUT_SNACK = "Is tiny food, but good for sky beast.",
        },
        
        QUAGMIRE_FERN = "Is tiny leaf plant.",
        QUAGMIRE_FOLIAGE_COOKED = "Is garnish now.",
        QUAGMIRE_COIN1 = "Goat lady and fish men would like.",
        QUAGMIRE_COIN2 = "Goat lady and fish men would like.",
        QUAGMIRE_COIN3 = "Goat lady and fish men would like.",
        QUAGMIRE_COIN4 = "Sky beast liked Wolfgang's cookings!",
        QUAGMIRE_GOATMILK = "Maybe goat lady got from hair cows?",
        QUAGMIRE_SYRUP = "Yummy sugar goop!",
        QUAGMIRE_SAP_SPOILED = "Wolfgang cannot cook with yuck sludge.",
        QUAGMIRE_SEEDPACKET = "Give your seeds to Wolfgang, tiny paper!",
        
        QUAGMIRE_POT = "Wolfgang put this over fire.",
        QUAGMIRE_POT_SMALL = "Friends, do not look! Pot needs to boil.",
        QUAGMIRE_POT_SYRUP = "Wolfgang put in sugar goop. New sugar goop come out.",
        QUAGMIRE_POT_HANGER = "Wolfgang hang things over fire.",
        QUAGMIRE_POT_HANGER_ITEM = "Is make pot hang over fire.",
        QUAGMIRE_GRILL = "Is put fire to food.",
        QUAGMIRE_GRILL_ITEM = "Where will Wolfgang put this?",
        QUAGMIRE_GRILL_SMALL = "Is put fire on tiny food.",
        QUAGMIRE_GRILL_SMALL_ITEM = "Wolfgang needs put this down some place.",
        QUAGMIRE_OVEN = "Friends! Wolfgang will cook for you!",
        QUAGMIRE_OVEN_ITEM = "Is fire box bits.",
        QUAGMIRE_CASSEROLEDISH = "Is shame Wolfgang forget cabbage casserole recipe.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "Is making of small foods.",
        QUAGMIRE_PLATE_SILVER = "Is for fancy eating.",
        QUAGMIRE_BOWL_SILVER = "Is for fancy eating.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",
        
        QUAGMIRE_MERM_CART1 = "Wolfgang could lift it.", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "Wolfgang could lift it.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Is scary.",
        QUAGMIRE_PARK_ANGEL2 = "Wolfgang don't like.",
        QUAGMIRE_PARK_URN = "Is burned dead person pieces.",
        QUAGMIRE_PARK_OBELISK = "Wolfgang could lift it.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "What nice things is in pink park?",
            LOCKED = "Is needing key.",
        },
        QUAGMIRE_PARKSPIKE = "Is pointy spiky thing.",
        QUAGMIRE_CRABTRAP = "Is for catching tiny pinchers.",
        QUAGMIRE_TRADER_MERM = "Is having things for Wolfgang?",
        QUAGMIRE_TRADER_MERM2 = "Is having things for Wolfgang?",
        
        QUAGMIRE_GOATMUM = "Is fluffy goat lady!",
        QUAGMIRE_GOATKID = "You grow up strong like Wolfgang, yes?",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Is dead.",
            GENERIC = "Silly bird does not matter to Wolfgang.",
            SLEEPING = "Gone beddy-bye.",
        },
        QUAGMIRE_LAMP_POST = "Wolfgang loves lamp.",

        QUAGMIRE_BEEFALO = "Is old.",
        QUAGMIRE_SLAUGHTERTOOL = "Wolfgang use to kill things.",

        QUAGMIRE_SAPLING = "Is broken.",
        QUAGMIRE_BERRYBUSH = "Is all gone.",

        QUAGMIRE_ALTAR_STATUE2 = "Is silly statue. Wolfgang not afraid.",
        QUAGMIRE_ALTAR_QUEEN = "Is big lady.",
        QUAGMIRE_ALTAR_BOLLARD = "Is post.",
        QUAGMIRE_ALTAR_IVY = "Is plant.",

        QUAGMIRE_LAMP_SHORT = "Wolfgang loves lamp.",

        --v2 Winona
        WINONA_CATAPULT = 
        {
        	GENERIC = "Little fixing lady has very big brainmeats.",
        	OFF = "Is not working.",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },
        WINONA_SPOTLIGHT = 
        {
        	GENERIC = "Fixing lady knows Wolfgang not like dark.",
        	OFF = "Is not working.",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },
        WINONA_BATTERY_LOW = 
        {
        	GENERIC = "Thingamabob made by fixing lady.",
        	LOWPOWER = "Is supposed to look like that?",
        	OFF = "Thingamabob is dead!",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },
        WINONA_BATTERY_HIGH = 
        {
        	GENERIC = "Fixing lady doohickeys.",
        	LOWPOWER = "It does not look so good.",
        	OFF = "Fixing lady, quick, come fix!",
        	BURNING = "Is burning!",
        	BURNT = "Is all burned up.",
        },

        --Wormwood
        COMPOSTWRAP = "Is very mighty poop.",
        ARMOR_BRAMBLE = "Mighty Wolfgang does not need armor!",
        TRAP_BRAMBLE = "Is sharp plant for hurting feets.",

        BOATFRAGMENT03 = "Weak boat is woodchips now!",
        BOATFRAGMENT04 = "Weak boat is woodchips now!",
        BOATFRAGMENT05 = "Weak boat is woodchips now!",
		BOAT_LEAK = "Wolfgang will plug hole with mighty fists!",
        MAST = "Wooden wind catcher!",
        SEASTACK = "Is a big watery rock.",
        FISHINGNET = "I will catch many tasty fish!",
        ANTCHOVIES = "Is little squirmy sea bug.",
        STEERINGWHEEL = "Wolfgang does not know where he is going.",
        ANCHOR = "Is good for weightlift. Build muscle.",
        BOATPATCH = "Mighty Wolfgang will fix all boats!",
        DRIFTWOOD_TREE = 
        {
            BURNING = "Is burning!",
            BURNT = "Is burnt up.",
            CHOPPED = "All chopped up.",
            GENERIC = "Is tree from the sea.",
        },

        DRIFTWOOD_LOG = "Small log is practically fit in palm of my hand!",

        MOON_TREE = 
        {
            BURNING = "Is burning!",
            BURNT = "Is burnt up.",
            CHOPPED = "Is stumpy stump now.",
            GENERIC = "Roly poly weird tree.",
        },
		MOON_TREE_BLOSSOM = "It come from weird tree.",

        MOONBUTTERFLY = 
        {
        	GENERIC = "Flutterby is big and green!",
        	HELD = "Green flutterby is soft.",
        },
		MOONBUTTERFLYWINGS = "Flutterby flappers.",
        MOONBUTTERFLY_SAPLING = "Puny little tree!",
        ROCK_AVOCADO_FRUIT = "Why little fruit hurt mouth?",
        ROCK_AVOCADO_FRUIT_RIPE = "Is soft for the eatings now.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "Mushy and warm. Yum.",
        ROCK_AVOCADO_FRUIT_SPROUT = "Little bush is tiny and weak.",
        ROCK_AVOCADO_BUSH = 
        {
        	BARREN = "It no longer makes the tiny fruits.",
			WITHERED = "Is very hot out.",
			GENERIC = "No fruit is too strong for Wolfgang's mighty jaw!",
			PICKED = "No little fruits today.",
			DISEASED = "Little bush is sick!",
            DISEASING = "Is not look very good.",
			BURNING = "Is burning!",
		},
        DEAD_SEA_BONES = "Big fish is very dead.",
        HOTSPRING = 
        {
        	GENERIC = "Is hot puddle.",
        	BOMBED = "Puddle stinks with good smells now.",
        	GLASS = "Mighty Wolfgang will punch through silly glass!",
        },
        MOONGLASS = "Is clear green sharp-stuff.",
        MOONGLASS_ROCK = "Sharp stuff that fell from sky cheese.",
        BATHBOMB = "Is for prettifying little hotbath.",
        TRAP_STARFISH =
        {
            GENERIC = "Wolfgang be careful not to step on.",
            CLOSED = "Ha ha! You is no match for mighty Wolfgang!",
        },
        DUG_TRAP_STARFISH = "Is not bite Wolfgang toesies now.",
        SPIDER_MOON = 
        {
        	GENERIC = "Wolfgang does not like that!",
        	SLEEPING = "Wolfgang will not disturb.",
        	DEAD = "Goodbye!",
        },
        MOONSPIDERDEN = "Scary things is inside maybe.",
		FRUITDRAGON =
		{
			GENERIC = "Is little planty scrambler!",
			RIPE = "Planty scrambler smells delicious today.",
			SLEEPING = "Wolfgang will not disturb.",
		},
        PUFFIN =
        {
            GENERIC = "Feather bird likes water.",
            HELD = "You is small, feather friend.",
            SLEEPING = "Wolfgang will not disturb.",
        },

		MOONGLASSAXE = "Is for swing and chop.",
		GLASSCUTTER = "My new friend taught me how to make.",

        ICEBERG =
        {
            GENERIC = "Is big freezy cube.",
            MELTED = "Is all melty!",
        },
        ICEBERG_MELTED = "Is all melty!",

        MINIFLARE = "Is tiny sky boom!",

		MOON_FISSURE = 
		{
			GENERIC = "Wolfgang is frighten, but happy.", 
			NOLIGHT = "Tiny ground is crack apart!",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Wolfgang like to help new friends.",
            GENERIC = "You have secrets for Wolfgang, friend?",
        },

        MOON_ALTAR_IDOL = "Wolfgang is here to help, yes.",
        MOON_ALTAR_GLASS = "Tell Wolfgang where you go and he will take you.",
        MOON_ALTAR_SEED = "Yes, Wolfgang will carry you.",

        MOON_ALTAR_ROCK_IDOL = "Special things is trapped inside!",
        MOON_ALTAR_ROCK_GLASS = "Special things is trapped inside!",
        MOON_ALTAR_ROCK_SEED = "Special things is trapped inside!",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "Wolfgang need help thinking on scary water.",
            BURNT = "Is burny stuff now.",
        },
        BOAT_ITEM = "Is for making very nice boat.",
        STEERINGWHEEL_ITEM = "Is for making little whirly steer-wheel.",
        ANCHOR_ITEM = "Is for making big boat weight.",
        MAST_ITEM = "Is for making big sail-stick.",
        MUTATEDHOUND = 
        {
        	DEAD = "Wolfgang would like to stay far away.",
        	GENERIC = "Meaty puppy is very scary!",
        	SLEEPING = "Wolfgang does not like meaty puppy.",
        },

        MUTATED_PENGUIN = 
        {
			DEAD = "Is dead, but still scary.",
			GENERIC = "Is too scary!",
			SLEEPING = "Please do not wake up.",
		},
        CARRAT = 
        {
        	DEAD = "Is dead.",
        	GENERIC = "Leggy carrot is getting away!",
        	HELD = "You are safe now, leggy carrot.",
        	SLEEPING = "Leggy carrot is sleeping.",
        },

		BULLKELP_PLANT = 
        {
            GENERIC = "Big pond is growing hair.",
            PICKED = "All gone.",
        },
		BULLKELP_ROOT = "Is not very good weapon, I think.",
        KELPHAT = "This make Wolfgang uneasy.",
		KELP = "Slimy sea spinach!",
		KELP_COOKED = "Sea spinach make Wolfgang strong to the finish.",
		KELP_DRIED = "Little sea flakes make Wolfgang grow strong!",

		GESTALT = "Wolfgang's brainmeats have never been so mighty!",

        WALKINGPLANK = "Maybe Wolfgang go for dip.",
        OAR = "Wolfgang will be mighty rower!",
		OAR_DRIFTWOOD = "Oar feels so light in Wolfgang's mighty hands!",

		----------------------- ROT STRINGS GO ABOVE HERE ------------------

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        --v2 Warly
        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Wolfgang will cook good meal for friends, meal like home!",
            DONE = "A meal with friends!",

            --Warly specific PORTABLECOOKPOT_ITEM strings
--fallback to speech_wilson.lua 			COOKING_LONG = "only_used_by_warly",
--fallback to speech_wilson.lua 			COOKING_SHORT = "only_used_by_warly",
--fallback to speech_wilson.lua 			EMPTY = "only_used_by_warly",
        },
        
        PORTABLEBLENDER_ITEM = "Wolfgang could smash food like that if he wanted.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Wolfgang will turn grinder with his mighty muscles!",
            DONE = "Is little pile with mighty taste.",
        },
        SPICEPACK = "Wolfgang will carry all the food!",
        SPICE_GARLIC = "Smells like mama used to make.",
        SPICE_SUGAR = "Fruit smashing made sweet sauce.",
        SPICE_CHILI = "Is mighty spicy, but Wolfgang can take it.",
        MONSTERTARTARE = "Blech!",
        FRESHFRUITCREPES = "Manly midmorning brunch.",
        FROGFISHBOWL = "Food will make Wolfgang very strong!",
        POTATOTORNADO = "Wolfgang loves potato.",
        DRAGONCHILISALAD = "Vegetables help Wolfgang grow big and strong.",
        GLOWBERRYMOUSSE = "Tasty-making friend has made thing very tasty.",
        VOLTGOATJELLY = "Is look very nice, tasty-making friend!",
        NIGHTMAREPIE = "Wolfgang must eat with eyes closed.",
        BONESOUP = "Wolfgang will be so mighty!",
        MASHEDPOTATOES = "Friend has made Wolfgang delicious potatoes.",
        POTATOSOUFFLE = "Wolfgang is very proud of tiny cooking friend.",
        MOQUECA = "Made by Wolfgang's friend. Mmm.",
        GAZPACHO = "Is tasting very good!",
        ASPARAGUSSOUP = "Is warm in Wolfgang's belly.",
        VEGSTINGER = "Hoo! Is spicy!",
        BANANAPOP = "Wolfgang can eat in one bite!",
        CEVICHE = "It will be better in Wolfgang's belly!",
        SALSA = "Is a tasty sauce!",
        PEPPERPOPPER = "Wolfgang like a spicy challenge!",

        TURNIP = "I will use in many dishes! Yes!",
        TURNIP_COOKED = "Smell is very good.",
        TURNIP_SEEDS = "Is little tiny seeds for burying.",
        
        GARLIC = "Is good flavor for stewing.",
        GARLIC_COOKED = "Flavor is good now.",
        GARLIC_SEEDS = "Is little tiny seeds for burying.",
        
        ONION = "Wolfgang eats like apple when not cooking.",
        ONION_COOKED = "Crispy, brown, sweet.",
        ONION_SEEDS = "Is little tiny seeds for burying.",
        
        POTATO = "Wolfgang's favorite veggie.",
        POTATO_COOKED = "Is golden brown! Texture like sun!",
        POTATO_SEEDS = "Is little tiny seeds for burying.",
        
        TOMATO = "Is good for sauce makings.",
        TOMATO_COOKED = "Roasty and toasty.",
        TOMATO_SEEDS = "Is little tiny seeds for burying.",

        ASPARAGUS = "Wolfgang always eat his vegetables.", 
        ASPARAGUS_COOKED = "Vegetables make me big and strong.",
        ASPARAGUS_SEEDS = "It grows up to make food.",

        PEPPER = "Hehe! Is little tiny vegetable.",
        PEPPER_COOKED = "Teeny vegetable smashes Wolfgang's tastebuds.",
        PEPPER_SEEDS = "It grows up to make food.",

        WEREITEM_BEAVER = "Beard is making crafts?",
        WEREITEM_GOOSE = "Wolfgang getting a bit worried about beardy friend...",
        WEREITEM_MOOSE = "This make beardman mighty like Wolfgang?",
    },

    DESCRIBE_GENERIC = "What is this thing?",
    DESCRIBE_TOODARK = "Help friends! Save Wolfgang from dark!",
    DESCRIBE_SMOLDERING = "Is almost fire.",
    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "This egg too crunchy.",
    },
}
