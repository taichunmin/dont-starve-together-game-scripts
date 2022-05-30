--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Finish thine business with haste! I have glory to attain!",
        },
        REPAIR =
        {
            WRONGPIECE = "It will not stay in place!",
        },
        BUILD =
        {
            MOUNTED = "I must first dismount from my mighty steed.",
            HASPET = "I can only command one beastie!",
			TICOON = "I hath already found a guide.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Let him sleep. Then I'll prune him.",
			GENERIC = "Unshaveworthy.",
			NOBITS = "But there's nothing to trim!",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "This beast doth not belong to me.",
		},
		STORE =
		{
			GENERIC = "It is already brimming with goods.",
			NOTALLOWED = "I fear that does not go there.",
			INUSE = "My stalwart companion currently has use of that.",
            NOTMASTERCHEF = "T'would not do to meddle with my ally's effects.",
		},
        CONSTRUCT =
        {
            INUSE = "'Tis in use, and not by me.",
            NOTALLOWED = "Alas! It doth not go there!",
            EMPTY = "It requireth materials.",
            MISMATCH = "Alas! 'Tis the wrong plans.",
        },
		RUMMAGE =
		{
			GENERIC = "That is not a job for a warrior!",
			INUSE = "True warriors wait their turn.",
            NOTMASTERCHEF = "T'would not do to meddle with my ally's effects.",
		},
		UNLOCK =
        {
--fallback to speech_wilson.lua         	WRONGKEY = "I can't do that.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "The true key must be out there somewhere.",
        	KLAUS = "Not when there is battle to be won!",
			QUAGMIRE_WRONGKEY = "By Odin's beard, I shall find the right key!",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Thou shalt not keep me out!",
            HOSTBUSY = "His attention lies elsewhere.",
            CARNIVAL_HOST_HERE = "Where art though, raven? Do show yourself!",
            NOCARNIVAL = "It seems the ravens hath returned to Odin.",
			EMPTY_CATCOONDEN = "Fie! There's naught to pillage!",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "This hunt will require more players.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "This is not a worthy stage for our players!",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "Let us reprise another time.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "T'would not do to meddle with my ally's effects.",
			SHADOWMAGIC = "A tragic tale of woe and misery!",
		},
        COOK =
        {
            GENERIC = "Alas! Bested by cookware!",
            INUSE = "I shall wait whilst my allies plan their feast.",
            TOOFAR = "I must close the gap between us!",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "The veggie beasts must take their places for the race to commence!",
        },

		DISMANTLE =
		{
			COOKING = "I will let it finish its work.",
			INUSE = "I shall valiantly wait my turn.",
			NOTEMPTY = "First, it must be emptied!",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Come closer, ye wee fishy cowards!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Tis not the rod I require.",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "T'will not work.",
            DEAD = "They'll have better things in Valhalla.",
            SLEEPING = "Such sweet slumber... Maybe later.",
            BUSY = "I'll try once more when it's done.",
            ABIGAILHEART = "The girl's spirit cannot be returned.",
            GHOSTHEART = "The spirit cannot be returned.",
            NOTGEM = "This object is not blessed with the power of the gods.",
            WRONGGEM = "This gem was not chosen for this purpose.",
            NOTSTAFF = "The gods may frown were I to do that.",
            MUSHROOMFARM_NEEDSSHROOM = "Forest sprites have no need of that.",
            MUSHROOMFARM_NEEDSLOG = "The sprite home requires sprucing up. With magical spruce!",
            MUSHROOMFARM_NOMOONALLOWED = "It longs for its homeland. It will not grow here.",
            SLOTFULL = "One material at a time!",
            FOODFULL = "One sacrifice at a time!",
            NOTDISH = "That's not worthy to grace the mouth of the gods!",
            DUPLICATE = "We have already conquered this knowledge.",
            NOTSCULPTABLE = "That material is not befitting a work of art.",
--fallback to speech_wilson.lua             NOTATRIUMKEY = "It's not quite the right shape.",
            CANTSHADOWREVIVE = "T'will not raise from death, it seems.",
            WRONGSHADOWFORM = "We must rearrange the bones of the beast.",
            NOMOON = "Needs the gaze of Mani to work.",
			PIGKINGGAME_MESSY = "I must clear the battlefield first!",
			PIGKINGGAME_DANGER = "Danger is near! 'Tis no time for games.",
			PIGKINGGAME_TOOLATE = "'Tis too late for revelry!",
			CARNIVALGAME_INVALID_ITEM = "'Tis not to its liking.",
			CARNIVALGAME_ALREADY_PLAYING = "A warrior must be patient.",
            SPIDERNOHAT = "It hath no use for such things while it's in my pocket.",
            TERRARIUM_REFUSE = "Perhaps it shall accept a different offering.",
            TERRARIUM_COOLDOWN = "I shall await the small tree's return before presenting it with another offering.",
        },
        GIVETOPLAYER =
        {
            FULL = "They're not strong enough to carry more!",
            DEAD = "They'll have better things in Valhalla.",
            SLEEPING = "Such sweet slumber graces thy face... Maybe later.",
            BUSY = "I'll try once more when they're free.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "They're not strong enough to carry more!",
            DEAD = "They'll have better things in Valhalla.",
            SLEEPING = "Such sweet slumber graces thy face... Maybe later.",
            BUSY = "I'll try once more when they're free.",
        },
        WRITE =
        {
            GENERIC = "I fear I cannot!",
            INUSE = "I shall valiantly wait my turn.",
        },
        DRAW =
        {
            NOIMAGE = "The muses will not visit me if I do not place an item first.",
        },
        CHANGEIN =
        {
            GENERIC = "That's where I keep all my favorite furs and pelts.",
            BURNING = "Gasp! My furs!",
            INUSE = "I shall let them select their garments first.",
            NOTENOUGHHAIR = "First the beast must grow back its mane.",
            NOOCCUPANT = "I cannot groom without a beast.",
        },
        ATTUNE =
        {
            NOHEALTH = "Alas, I am too stricken.",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I'll only ride it if it's the victor.",
            INUSE = "I'll need to be faster than that in battle!",
			SLEEPING = "Rise, beastie! We ride!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I'll only ride it if it's the victor.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "I already wield such knowledge.",
            CANTLEARN = "That knowledge is forbidden by the gods.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "This map is for some distant land...",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "This is nary the time nor place.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "I cannot wrap that which does not exist!",
        },
        PICKUP =
        {
			RESTRICTION = "There is no glory in that weapon!",
			INUSE = "Someone hath beat me to it!",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Thou art not the one I seek.",
                "Where is your master, veggie beast?",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Alas, it hath escaped my fury.",
        },
        REPLATE =
        {
            MISMATCH = "This food doth need a different dish.",
            SAMEDISH = "I hath used a dish already.",
        },
        SAIL =
        {
        	REPAIR = "No need, the ship's spirit is strong.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "I must take heed of the ocean's rhythm.",
            BAD_TIMING1 = "A Viking never gives up!",
            BAD_TIMING2 = "Patience is a warrior's friend!",
        },
        LOWER_SAIL_FAIL =
        {
            "By Aegir, you will bend to my will!",
            "Oh-ho! Feisty, are we?",
            "I will not be defeated by my own vessel!",
        },
        BATHBOMB =
        {
            GLASSED = "'Tis shielded!",
            ALREADY_BOMBED = "Someone has enchanted it already.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "We have already conquered this knowledge.",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "This wee beastie will not bring me glory.",
            OVERSIZEDVEGGIES_TOO_SMALL = "This non-meat isn't even worthy of competing!",
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
            SAMESONG = "Again, from the top? Nay! The show must go on!",
        },
        PLANTREGISTRY_RESEARCH_FAIL =
        {
            GENERIC = "Its ways are already known to me.",
            FERTILIZER = "I need not know more.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "The plants will like this about as much as I like them.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Empty.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Nary a drop left.",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "I cannot.",
            BEEF_BELL_ALREADY_USED = "That beast belongs to another.",
            BEEF_BELL_HAS_BEEF_ALREADY = "I've already chosen my beast.",
        },
        HITCHUP =
        {
            NEEDBEEF = "I have a hitching post, but no beast.",
            NEEDBEEF_CLOSER = "I shall have to coax the beast closer.",
            BEEF_HITCHED = "The beast hath already been secured to its post.",
            INMOOD = "The beast is in a foul temper.",
        },
        MARK =
        {
            ALREADY_MARKED = "I must stand by my choice, even in the heat of competition!",
            NOT_PARTICIPANT = "I cannot join in the competition without a beastie of my own.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Where is he hiding?",
            ALREADYACTIVE = "Mayhaps there is another competition elsewhere.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "This is known to me.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "I must move with greater haste!",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "The spiderchild is the only one who can tame those little beasts!",
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
            DOER_ISNT_MODULE_OWNER = "I respect thine loyalty to our metal warrior, scout.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "I must seek out more ingredients!",
		NO_TECH = "I hath not yet discovered how to make such a thing.",
		NO_STATION = "I fear 'tis beyond me at this time.",
	},

	ACTIONFAIL_GENERIC = "If I can't do it, it can't be done!",
	ANNOUNCE_BOAT_LEAK = "Our vessel hath sprung a leak!",
	ANNOUNCE_BOAT_SINK = "A Viking shalln't abandon her ship!",
	ANNOUNCE_DIG_DISEASE_WARNING = "Be banished, beastly blight!", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Foul!", --removed
	ANNOUNCE_ADVENTUREFAIL = "Back to the Otherworld, victory shall be mine!",
    ANNOUNCE_MOUNT_LOWHEALTH = "Don't give up, beast! Fight!",

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

	ANNOUNCE_BEES = "Back, wee speared creatures!",
	ANNOUNCE_BOOMERANG = "Urg! I must master the curved weapon.",
	ANNOUNCE_CHARLIE = "Show yourself!",
	ANNOUNCE_CHARLIE_ATTACK = "Coward!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "Brrr! Where are my furs!",
	ANNOUNCE_HOT = "The hot sun tires me.",
	ANNOUNCE_CRAFTING_FAIL = "I lack the provisions.",
	ANNOUNCE_DEERCLOPS = "A worthy foe approaches.",
	ANNOUNCE_CAVEIN = "Rocks shall rain from on high!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"The earth rebels against us!",
		"Tis the footsteps of a giant!",
		"What plagues you, mother Gaia?",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "A gift, that you may not devour us.",
        "A tribute for thee, great lion!",
        "O great lion, we pay tribute this day!",
	},
	ANNOUNCE_SACREDCHEST_YES = "I have gained the gods' favor!",
	ANNOUNCE_SACREDCHEST_NO = "Alas! I am unworthy!",
    ANNOUNCE_DUSK = "The sun is setting, darkness waits nearby.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Meat makes my heart sing!",
		PAINFUL = "Ohh, I don't feel well.",
		SPOILED = "Ugh, fresh is better.",
		STALE = "That was stale beast.",
		INVALID = "This is not food befitting a warrior.",
        YUCKY = "This food is not befitting a warrior.",

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
        "Hff... Nothing can weigh a warrior down!",
        "Huff... Huff...",
        "Tis... nothing...",
        "Heave... ho...!",
        "Gnnngh...",
        "Swift... as Sleipnir...",
        "Strong... like Thor...",
        "Enduring... like Freya...",
        "I will be... victorious!",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"The beasts shalt soon reemerge!",
		"The gods are angered!",
		"There is danger on the wind!",
	},
    ANNOUNCE_RUINS_RESET = "I will fight my way out!",
    ANNOUNCE_SNARED = "No cage can hold me!",
    ANNOUNCE_SNARED_IVY = "You would defend your vegetable kin against me? Have at thee!",
    ANNOUNCE_REPELLED = "Foul magics block mine blows!",
	ANNOUNCE_ENTER_DARK = "And the curtain falls.",
	ANNOUNCE_ENTER_LIGHT = "I step into the light!",
	ANNOUNCE_FREEDOM = "Freedom! The saga continues!",
	ANNOUNCE_HIGHRESEARCH = "I am an excellent craftswoman.",
	ANNOUNCE_HOUNDS = "The beasts are approaching...",
	ANNOUNCE_WORMS = "The earth quakes with the approach of a foe!",
	ANNOUNCE_HUNGRY = "How I long for a feast!",
	ANNOUNCE_HUNT_BEAST_NEARBY = "Hush... The creature is near.",
	ANNOUNCE_HUNT_LOST_TRAIL = "I've lost the tracks.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "It's too muddy for trailing.",
	ANNOUNCE_INV_FULL = "I'm carrying all I can!",
	ANNOUNCE_KNOCKEDOUT = "Ugh, my head.",
	ANNOUNCE_LOWRESEARCH = "That wasn't very exciting.",
	ANNOUNCE_MOSQUITOS = "Away, tiny demons!",
    ANNOUNCE_NOWARDROBEONFIRE = "I fear I cannot. It is being razed.",
    ANNOUNCE_NODANGERGIFT = "Not with the gift of battle before me!",
    ANNOUNCE_NOMOUNTEDGIFT = "I must dismount my mighty steed!",
	ANNOUNCE_NODANGERSLEEP = "It's not safe to sleep. Use the spear!",
	ANNOUNCE_NODAYSLEEP = "The sun is high, journey on!",
	ANNOUNCE_NODAYSLEEP_CAVE = "I'll not rest yet.",
	ANNOUNCE_NOHUNGERSLEEP = "I'll starve overnight! Feast first.",
	ANNOUNCE_NOSLEEPONFIRE = "I'll not sleep in the flames.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "'Tis too bright for sleep!",
	ANNOUNCE_NODANGERSIESTA = "Battle is upon us, there'll be no rest!",
	ANNOUNCE_NONIGHTSIESTA = "No napping in the moonlight.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "This doesn't feel like the time for a nap.",
	ANNOUNCE_NOHUNGERSIESTA = "I'd like a meat snack first.",
	ANNOUNCE_NO_TRAP = "Thankfully, I am light of foot.",
	ANNOUNCE_PECKED = "Away, feisty beaker!",
	ANNOUNCE_QUAKE = "The world shudders!",
	ANNOUNCE_RESEARCH = "The power of knowledge is great.",
	ANNOUNCE_SHELTER = "Aha! Shelter!",
	ANNOUNCE_THORNS = "Arg, I've been poked!",
	ANNOUNCE_BURNT = "By Hel's fire!",
	ANNOUNCE_TORCH_OUT = "My light is quenched!",
	ANNOUNCE_THURIBLE_OUT = "Alas, it is no more.",
	ANNOUNCE_FAN_OUT = "I've lost another fan!",
    ANNOUNCE_COMPASS_OUT = "I fear I'm going to lose my way!",
	ANNOUNCE_TRAP_WENT_OFF = "That wasn't part of the plan.",
	ANNOUNCE_UNIMPLEMENTED = "It is not of this world.",
	ANNOUNCE_WORMHOLE = "That was a sloppy adventure.",
	ANNOUNCE_TOWNPORTALTELEPORT = "Fear not! I have arrived!",
	ANNOUNCE_CANFIX = "\nI can repair this.",
	ANNOUNCE_ACCOMPLISHMENT = "May I return to battle now?",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "Victory! Alright, let us away.",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "More droppings for you?",
	ANNOUNCE_TOOL_SLIP = "Slippery devil!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "I rode in on a bolt lightning.",
	ANNOUNCE_TOADESCAPING = "Don't let the beast entertain thoughts of escape.",
	ANNOUNCE_TOADESCAPED = "The beast returned from whence it came.",


	ANNOUNCE_DAMP = "Slick for battle.",
	ANNOUNCE_WET = "I am a wet warrior.",
	ANNOUNCE_WETTER = "Does this count as a bath?",
	ANNOUNCE_SOAKED = "I'm nearly drowned!",

	ANNOUNCE_WASHED_ASHORE = "The sea did not claim me this day.",

    ANNOUNCE_DESPAWN = "'Tis the lights of Valhalla?",
	ANNOUNCE_BECOMEGHOST = "oOooOOOo!!",
	ANNOUNCE_GHOSTDRAIN = "They're driving me mad...!",
	ANNOUNCE_PETRIFED_TREES = "I sense Loki's mischievous hand in the shadows.",
	ANNOUNCE_KLAUS_ENRAGE = "RUN AWAY!",
	ANNOUNCE_KLAUS_UNCHAINED = "Now the true battle begins!",
	ANNOUNCE_KLAUS_CALLFORHELP = "Call thy hordes, they shan't protect thee!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "It calls from within!",
		GLASS_LOW = "Thy form takes shape!",
		GLASS_REVEAL = "Taste thy freedom!",
		IDOL_MED = "It calls from within!",
		IDOL_LOW = "Thy form takes shape!",
		IDOL_REVEAL = "Taste thy freedom!",
		SEED_MED = "It calls from within!",
		SEED_LOW = "Thy form takes shape!",
		SEED_REVEAL = "Taste thy freedom!",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Doth mine eyes deceive me?",
	ANNOUNCE_BRAVERY_POTION = "Fear! I hath bested you!",
	ANNOUNCE_MOONPOTION_FAILED = "Twas all in vain!",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Tis more than enough to share!",
	ANNOUNCE_WINTERS_FEAST_BUFF = "I feel Odin's blessing upon me!",
	ANNOUNCE_IS_FEASTING = "My friends, let us celebrate this great bounty!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "The blessing hath faded.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Rise, my ally!",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "To battle!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "I am restored!",

    ANNOUNCE_FLARE_SEEN = "My allies beckon me!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "A gargantuan foe approaches!",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "T'were not meant to be a meal.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Alas! If I'd only grabbed it sooner.",
    QUAGMIRE_ANNOUNCE_LOSE = "The god of the sky has been angered!",
    QUAGMIRE_ANNOUNCE_WIN = "We shall live to fight another day!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I've been granted the power of Thor!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "My warrior's spirit is invigorated!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "Ha! No attack frightens me!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Stand aside, I'll have this done in no time!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "A little water is nothing to a Viking!",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Sleep can no longer claim me!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "I... suppose I was unworthy.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Back to merely my usual level of fearsomeness.",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "I've lost my defensive advantage!",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "I think I've done my share.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "The tides have turned for the wetter.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "I fear my defense against sleep hath weakened.",

	ANNOUNCE_OCEANFISHING_LINESNAP = "By Freya, the little fiend snapped my line!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "The line has gone slack, tis time to reel!",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "It lives to fight another day.",
	ANNOUNCE_OCEANFISHING_BADCAST = "I'm more suited to fighting than fishing.",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"I tire of waiting!",
		"I'm tempted to simply wade in with my spear...",
		"Come to me, delicious sea meats!",
		"It's not befitting of a warrior to just stand around waiting!",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nBy the gods, I've netted a monster!",

	ANNOUNCE_WINCH_CLAW_MISS = "My aim wasn't true...",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "My efforts were for naught.",

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
    ANNOUNCE_WEAK_RAT = "The wee beast is on death's door.",

    ANNOUNCE_CARRAT_START_RACE = "Onward, to victory!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Foolish vegetable, the race is that way!",
        "Thou cannot trust a vegetable to do anything right.",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "By Odin, wake up!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "Quicken thine step, rodent!",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "No! You musn't hesitate!",

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

    ANNOUNCE_NOINSPIRATION = "I must warm up my voice... in the heat of battle!",
    ANNOUNCE_BATTLESONG_INSTANT_TAUNT_BUFF = "\"You scullion! You rampallian! You fustilarian! I'll tickle your catastrophe!\"",
    ANNOUNCE_BATTLESONG_INSTANT_PANIC_BUFF = "\"By the pricking of my thumbs, something wicked this way comes!\"",

--fallback to speech_wilson.lua     ANNOUNCE_WANDA_YOUNGTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOOLD = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_OLDTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOYOUNG = "only_used_by_wanda",

	ANNOUNCE_POCKETWATCH_PORTAL = "T'was not one of my more graceful exits...",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "The gods have given me a vision... some kind of machine?",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "I've already seen this vision.",
    ANNOUNCE_ARCHIVE_NO_POWER = "It hath not the energy to perform its task.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "My head hath been filled with useless knowledge about non-meat!",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "I care not what shall emerge.",

    ANNOUNCE_FERTILIZER_RESEARCHED = "What need hath a warrior of this knowledge?",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"I feel as though my body's aflame!",
		"Accursed plant with your fiery barbs! Fight me properly!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "The fiery curse has passed.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "I care naught for these plants or the veggies they produce.",
        "Grow, or do not.",
		"Perhaps someone more weak and feeble might talk to the plants, while I hunt.",
        "No fearsome warrior should be caught talking to plants.",
        "I should be hunting, not gardening!",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Let our glorious hunt commence!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "A hunt is always better with more warriors!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"You've been found, little beast!",
		"You would make a fine stagehand, I hardly saw ye!",
		"You were good, but not good enough!",
		"You cannot escape my keen eye!",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "Only one remains! Victory is imminent!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "Glorious victory!!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "{name} has lead us to glorious victory!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Alas! We need to find the last of them soon!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Arrgh! The little beasties were too clever.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "Perhaps we're too far to find the little beasties.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "We have returned to the hunting grounds.",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Hail, tiny beastie!",

	ANNOUNCE_TICOON_START_TRACKING	= "Onward, great beast!!",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "No little beasties in this area.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Let us proceed!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "It is vying for my attention.",
	ANNOUNCE_TICOON_NEAR_KITCOON = "I sense there's a little beastie afoot...",
	ANNOUNCE_TICOON_LOST_KITCOON = "Someone was swifter than I!",
	ANNOUNCE_TICOON_ABANDONED = "I will finish this hunt solo!",
	ANNOUNCE_TICOON_DEAD = "My guide hath fallen, and I am left directionless!",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "To me, beastie!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "'Tis too far from the festivities!",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Aha! A new plan has revealed itself before mine eyes!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "Away, spying demon. To arms!",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Thou hast returned, now let us finish this battle!",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "You would flee this fight? Asgard does not honor cowards!",

	BATTLECRY =
	{
		GENERIC = "Valhalla awaits!",
		PIG = "I'm having pig tonight!",
		PREY = "Die bravely, little foe!",
		SPIDER = "Spider, meet my spear!",
		SPIDER_WARRIOR = "Prepare to be slain!",
		DEER = "I shall send you to the unicorn!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Odin will have you yet!",
		PIG = "I'll be back, pigskin!",
		PREY = "I let you go this time!",
		SPIDER = "Leggy coward.",
		SPIDER_WARRIOR = "Flee, monster! I will return.",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "It makes me long for the stage!",
        MULTIPLAYER_PORTAL_MOONROCK = "It hath a glow about it.",
        MOONROCKIDOL = "I shall make an offering!",
        CONSTRUCTION_PLANS = "Portal! Prepare to be built!",

        ANTLION =
        {
            GENERIC = "Tis the mighty lion!",
            VERYHAPPY = "The lion smiles upon us.",
            UNHAPPY = "We've incurred its wrath!",
        },
        ANTLIONTRINKET = "A fitting tribute!",
        SANDSPIKE = "The earth itself dares to fight me!",
        SANDBLOCK = "Tis a castle of sand!",
        GLASSSPIKE = "Twas forged in flame.",
        GLASSBLOCK = "Such beauty!",
        ABIGAIL_FLOWER =
        {
            GENERIC ="For me?",
			LEVEL1 = "My warrior's sense tells me it's not to be trifled with.",
			LEVEL2 = "It's gathering its strength.",
			LEVEL3 = "What strange magic!",

			-- deprecated
            LONG = "For me?",
            MEDIUM = "What is it doing?",
            SOON = "Something wicked this way comes.",
            HAUNTED_POCKET = "Perhaps it's best we part ways...",
            HAUNTED_GROUND = "What is it waiting for?!",
        },

        BALLOONS_EMPTY = "Such colors! I could sing!",
        BALLOON = "Fie! Foul beast!",
		BALLOONPARTY = "It hath swallowed the wee ones whole!",
		BALLOONSPEED =
        {
            DEFLATED = "Its strange power hath faded.",
            GENERIC = "Grant me the speed of Hermod!",
        },
		BALLOONVEST = "Tis only good for floating, not fighting.",
		BALLOONHAT = "A rubbery mockery of life.",

        BERNIE_INACTIVE =
        {
            BROKEN = "It has gone to Valhalla.",
            GENERIC = "It's a stuffed beast.",
        },

        BERNIE_ACTIVE = "What a brave beast!",
        BERNIE_BIG = "The beast hath been imbued with a fighting spirit!",

        BOOK_BIRDS = "To rule the skies!",
        BOOK_TENTACLES = "Knowledge grants great power!",
        BOOK_GARDENING = "But can it tend the garden of mine soul?",
		BOOK_SILVICULTURE = "A tome of the ways of the forest!",
		BOOK_HORTICULTURE = "But can it tend the garden of mine soul?",
        BOOK_SLEEP = "Where's the drama? The suspense?",
        BOOK_BRIMSTONE = "This tome is brimming with Hel's fire!",

        PLAYER =
        {
            GENERIC = "Good health to you, %s!",
            ATTACKER = "If %s is looking for trouble, I shall give it to them!",
            MURDERER = "Murderer! To battle!",
            REVIVER = "Freya smiles on %s.",
            GHOST = "%s's restless spirit could be revived with a heart.",
            FIRESTARTER = "Forged in flame!",
        },
        WILSON =
        {
            GENERIC = "Wisdom guide you, %s!",
            ATTACKER = "Your honor wavers, %s.",
            MURDERER = "%s! Let us settle this in battle!",
            REVIVER = "%s protects our people.",
            GHOST = "The fate of the Draugr is not yours, %s. A heart!",
            FIRESTARTER = "Hm. I worry about you sometimes, %s.",
        },
        WOLFGANG =
        {
            GENERIC = "Health and strength to you, %s!",
            ATTACKER = "%s packs a punch to rival a frost giant.",
            MURDERER = "You will pay for your heinous deeds, brute!",
            REVIVER = "%s, son of Magni.",
            GHOST = "A valiant warrior should not be wasted. A heart, a heart!",
            FIRESTARTER = "%s seems to have mistakenly fumbled a torch.",
        },
        WAXWELL =
        {
            GENERIC = "Greetings, %s, my ally!",
            ATTACKER = "I sense Loki's influence in %s.",
            MURDERER = "%s! Back to your old tricks, I see!",
            REVIVER = "%s has uncovered the kindness buried within his heart.",
            GHOST = "A heart could return %s to this realm if we so wished.",
            FIRESTARTER = "Loki has brought %s into a world of flame.",
        },
        WX78 =
        {
            GENERIC = "May Thor's bolts energize you, %s!",
            ATTACKER = "%s! You insult my honor!",
            MURDERER = "We shall see whose steel is stronger, %s!",
            REVIVER = "%s is brimming with honor.",
            GHOST = "Metal warrior, it is not your time. A heart!",
            FIRESTARTER = "That metal warrior would see this world burn.",
        },
        WILLOW =
        {
            GENERIC = "Greetings, %s, the Inflammable!",
            ATTACKER = "Should it come to blows, may the best maiden triumph.",
            MURDERER = "My spear was forged in passionate fires, %s!",
            REVIVER = "%s has a noble heart.",
            GHOST = "A heart shall wrench %s back from the jaws of death!",
            FIRESTARTER = "%s has more fire in her eyes than usual.",
        },
        WENDY =
        {
            GENERIC = "Spirits be with you, %s!",
            ATTACKER = "Do not test me, fair maiden!",
            MURDERER = "%s, your body is weak but your heart is strong! Fight!",
            REVIVER = "%s is channeling the spirit of Eir.",
            GHOST = "%s's restless spirit could be revived with a heart.",
            FIRESTARTER = "Ah. Have you singed your dress, fair maiden?",
        },
        WOODIE =
        {
            GENERIC = "May Yggdrasil bind us as the nine worlds, %s!",
            ATTACKER = "I could fell you like so many trees, %s.",
            MURDERER = "By Yggdrasil, I will cut you down!",
            REVIVER = "%s's heart is as mighty as his beard.",
            GHOST = "The worldtree watches over you, %s.",
            BEAVER = "I did not know %s possessed such power!",
            BEAVERGHOST = "You went out in a blaze of glory, %s.",
            MOOSE = "By the gods, I mistook you for a jötunn!",
            MOOSEGHOST = "Never fear, I'll return you to this realm!",
            GOOSE = "%s, you've become a fowl beast!",
            GOOSEGHOST = "Worry not, I won't let you leave for Valhalla looking like that!",
            FIRESTARTER = "Did he mistake \"Loge\" for \"log\"?",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Good health and wisdom to you, elder %s!",
            ATTACKER = "If %s is looking for trouble, I shall oblige!",
            MURDERER = "Murderer! Face me in battle!",
            REVIVER = "The wisdom of Wotan dwells within you, %s.",
            GHOST = "A heart! A heart! My base for a heart!",
            FIRESTARTER = "I'll not question your wisdom, %s.",
        },
        WES =
        {
            GENERIC = "Good health to you, %s!",
            ATTACKER = "Do you bite your thumb at me, mime?",
            MURDERER = "May we meet again in Valhalla!",
            REVIVER = "%s has Hoenir's blessing.",
            GHOST = "Meditate on Hoenir's blessings, %s. I'll find a heart.",
            FIRESTARTER = "Don't ruin your fair makeup with ashes, %s.",
        },
        WEBBER =
        {
            GENERIC = "Blessings upon you, spiderchild %s!",
            ATTACKER = "There's a new hunger in %s's eyes.",
            MURDERER = "I've felled greater monsters than you, %s!",
            REVIVER = "%s's spirit burns brighter than Sol.",
            GHOST = "Return with Sleipnir's swiftness, many-legged one.",
            FIRESTARTER = "His flames are as open as his heart.",
        },
        WATHGRITHR =
        {
            GENERIC = "Hail, %s, fellow shieldmaiden!",
            ATTACKER = "%s is tempting fate.",
            MURDERER = "There can be only one!",
            REVIVER = "%s, the perfect warrior!",
            GHOST = "You'll not away to Valhalla yet, %s. A heart!",
            FIRESTARTER = "A fellow Viking, forged in flames!",
        },
        WINONA =
        {
            GENERIC = "Greetings, brave %s!",
            ATTACKER = "Dost thou test me, %s?",
            MURDERER = "I shall unleash Ragnarok upon thee!",
            REVIVER = "%s is guided by Brokkr.",
            GHOST = "%s hath fallen! A heart!",
            FIRESTARTER = "%s's flames could temper steel.",
        },
        WORTOX =
        {
            GENERIC = "Hail, fire giant %s!",
            ATTACKER = "Back! Back, beast!",
            MURDERER = "%s will pay for his trespasses!",
            REVIVER = "%s abides by a warrior's code.",
            GHOST = "An honorable Viking leaves no one behind!",
            FIRESTARTER = "%s stepped forth from Hel's flames!",
        },
        WORMWOOD =
        {
            GENERIC = "Greetings, %s, touched by Yggdrasil!",
            ATTACKER = "Rumors of %s's terrible act have spread like weeds.",
            MURDERER = "I will root you out, monstrous plant!",
            REVIVER = "%s is a kind and formidable healer.",
            GHOST = "My dear friend hath fallen in battle!",
            FIRESTARTER = "%s is sure to be scalded by Hel's flames!",
        },
        WARLY =
        {
            GENERIC = "Hail, %s, blessed feast-forge!",
            ATTACKER = "What nefarious plots doth %s stew upon?",
            MURDERER = "We will hold a valorous feast at your defeat!",
            REVIVER = "%s's heart is as full as his belly.",
            GHOST = "The feast hall of Valhalla will one day welcome you. But not today.",
            FIRESTARTER = "%s's summoned Hel's flames this day!",
        },

        WURT =
        {
            GENERIC = "Hail, %s, small beastie of the marshlands!",
            ATTACKER = "Ah, you wish to test your mettle in combat? As you wish!",
            MURDERER = "I will not be defeated so easily, beastie!",
            REVIVER = "It seems you have a kind heart 'neath that scaly hide.",
            GHOST = "You've a warrior's spirit, but you're not ready for Valhalla yet!",
            FIRESTARTER = "%s toys with Hel's flames!",
        },

        WALTER =
        {
            GENERIC = "Good health to you, %s, and to your loyal beast!",
            ATTACKER = "Consider your actions wisely, %s.",
            MURDERER = "Have at thee, you and your wicked beast!",
            REVIVER = "%s carries with him a true sense of honor.",
            GHOST = "By my honor, I will bring you back to this world!",
            FIRESTARTER = "%s, why do you break your cherished code?",
        },

        WANDA =
        {
            GENERIC = "Good health to you through the ages, %s!",
            ATTACKER = "You think it wise to test me, %s?",
            MURDERER = "Thou shall answer for this betrayal, %s! Meet my spear!",
            REVIVER = "%s is a powerful ally indeed.",
            GHOST = "Fear not! I will find you a heart, with utmost haste!",
            FIRESTARTER = "I don't wish to question your intentions, %s...",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "A majestic goober.",
            SLEEPING = "It slumbers.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "A wonder of the woods.",
            DEAD = "It was once a wonder of the woods.",
        },
        GLOMMERWINGS = "Ohh, look what the goober left for me.",
        GLOMMERFUEL = "This slop could be useful.",
        BELL = "I prefer the ringing resonance of clashing blades.",
        STATUEGLOMMER =
        {
            GENERIC = "A curious homage to the gods.",
            EMPTY = "That wasn't very respectful.",
        },

        LAVA_POND_ROCK = "Stone belched forth by the earth's fiery heart!",

		WEBBERSKULL = "He fought boldly, but his burial will not be that of a Viking.",
		WORMLIGHT = "Glowing treasure, I can't resist!",
		WORMLIGHT_LESSER = "Glow! Glow with all your might!",
		WORM =
		{
		    PLANT = "I smell a trap.",
		    DIRT = "What's under that dirt?",
		    WORM = "A snake beast from the depths!",
		},
        WORMLIGHT_PLANT = "I smell a trap.",
		MOLE =
		{
			HELD = "A friend for my pocket.",
			UNDERGROUND = "Who's under there?",
			ABOVEGROUND = "He burrows with reckless abandon.",
		},
		MOLEHILL = "Something fiendish lives down there.",
		MOLEHAT = "It's best to use every part of the animal.",

		EEL = "Delicious slimy snake fish.",
		EEL_COOKED = "Hot eel!",
		UNAGI = "No need for food to be so fancy.",
		EYETURRET = "The eye of the laser god stares into my soul.",
		EYETURRET_ITEM = "An ancient eyeball of protection!",
		MINOTAURHORN = "Can I add it to my helmet?",
		MINOTAURCHEST = "The conquest chest!",
		THULECITE_PIECES = "Looks like shiny popped corn.",
		POND_ALGAE = "Ancient flora.",
		GREENSTAFF = "Twirly green power.",
		GIFT = "A gift! From... the gods?",
        GIFTWRAP = "I must show my allies how much they are valued!",
		POTTEDFERN = "What are you meant to do with such a thing?",
        SUCCULENT_POTTED = "A feast for mine eyes!",
		SUCCULENT_PLANT = "Hearty greenery.",
		SUCCULENT_PICKED = "Tis not foodstuff.",
		SENTRYWARD = "May the secrets of this land be divulged by the gods.",
        TOWNPORTAL =
        {
			GENERIC = "To save my allies the journey.",
			ACTIVE = "By the power of the sand!",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "A present from the mighty lion!",
			ACTIVE = "I shall desert this foul place!",
		},
        WETPAPER = "Tis drenched.",
        WETPOUCH = "A treasure lies within!",
        MOONROCK_PIECES = "It has faced Mani's wrath.",
        MOONBASE =
        {
            GENERIC = "What dost thou want, altar?",
            BROKEN = "Perhaps it crashed from the heavens.",
            STAFFED = "Prepare for glorious battle!",
            WRONGSTAFF = "This shall not please the gods.",
            MOONSTAFF = "It feeds from the power of Mani!",
        },
        MOONDIAL =
        {
			GENERIC = "Mani's visage remains, even in the light of day.",
			NIGHT_NEW = "Mani's retired to his realm for the eve.",
			NIGHT_WAX = "Mani's power grows!",
			NIGHT_FULL = "Mani claims the skies!",
			NIGHT_WANE = "Mani's power is on the wane.",
			CAVE = "Mani cannot see us here.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "By the gods! The water hath turned to solid glass!",
        },
		THULECITE = "This material possesses gargantuan strength!",
		ARMORRUINS = "Armor fit for Odin himself!",
		ARMORSKELETON = "What devilish armor!",
		SKELETONHAT = "Immortal's sight was not meant for thee.",
		RUINS_BAT = "A warrior's wand!",
		RUINSHAT = "A crown... that fights!",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Nothing stirs.",
            WARN = "It's starting...",
            WAXING = "The magic is heightening!",
            STEADY = "The magic power holds steady.",
            WANING = "It's starting to retreat!",
            DAWN = "Barely any magic remains.",
            NOMAGIC = "The magic slumbers far from here.",
		},
		BISHOP_NIGHTMARE = "Be wary of his blasts!",
		ROOK_NIGHTMARE = "You don't frighten me!",
		KNIGHT_NIGHTMARE = "I don't think I'd ride that horse.",
		MINOTAUR = "What wonders. Let us duel!",
		SPIDER_DROPPER = "You are so sneaky!",
		NIGHTMARELIGHT = "It harnesses dark powers from beneath.",
		NIGHTSTICK = "A weapon worthy of Thor.",
		GREENGEM = "An emerald stone.",
		MULTITOOL_AXE_PICKAXE = "A warrior's tool!",
		ORANGESTAFF = "A staff of magical movement.",
		YELLOWAMULET = "A star, captured within an amulet.",
		GREENAMULET = "Enhanced emerald crafting skills!",
		SLURPERPELT = "I do love furs.",

		SLURPER = "The fur foe thinks she's a hat!",
		SLURPER_PELT = "I do love furs.",
		ARMORSLURPER = "She ebbs the ache of hunger. Good fur.",
		ORANGEAMULET = "Gathering has never been so easy.",
		YELLOWSTAFF = "It summons the stars!",
		YELLOWGEM = "A yellow beauty.",
		ORANGEGEM = "A stone of orange.",
        OPALSTAFF = "It weaves the cold from thin air!",
        OPALPRECIOUSGEM = "The spoils of war!",
        TELEBASE =
		{
			VALID = "It will harness my awesome speed.",
			GEMS = "It requires purple gems.",
		},
		GEMSOCKET =
		{
			VALID = "Showtime!",
			GEMS = "It lacks its gem.",
		},
		STAFFLIGHT = "Behold! A gift from Wotan!",
        STAFFCOLDLIGHT = "Frigid as a frost giant's heart.",

        ANCIENT_ALTAR = "These crafts had better be good.",

        ANCIENT_ALTAR_BROKEN = "This one is not in working order.",

        ANCIENT_STATUE = "Treasure with a mysterious aura.",

        LICHEN = "Sky blue nonsense plant.",
		CUTLICHEN = "Even if I ate plants, I wouldn't eat THAT plant.",

		CAVE_BANANA = "Monkey food.",
		CAVE_BANANA_COOKED = "Warmed monkey food.",
		CAVE_BANANA_TREE = "A flimsy monkey tree.",
		ROCKY = "He may be a worthy combat comrade.",

		COMPASS =
		{
			GENERIC="A reading cannot be gleaned.",
			N = "North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "A token of a successful conquest.",
        ARMORSNURTLESHELL = "A shield of sorts.",
        BAT = "Dark winged meat.",
        BATBAT = "Winged spear!",
        BATWING = "Like the wings of my helm, only meatier.",
        BATWING_COOKED = "Cooked dark wing.",
        BATCAVE = "They're hiding under the stage.",
        BEDROLL_FURRY = "A luxury fur bed!",
        BUNNYMAN = "I want to eat you.",
        FLOWER_CAVE = "And it lit up the night, upon the darkest hour.",
        GUANO = "Hmm, dark wing turds.",
        LANTERN = "A lantern to hold back the night.",
        LIGHTBULB = "Glow!",
        MANRABBIT_TAIL = "The fuzzy trophy of a successful battle.",
        MUSHROOMHAT = "This helm runs flush with the forest's magic!",
        MUSHROOM_LIGHT2 =
        {
            ON = "Behold! It blazes bright!",
            OFF = "I demand strong, passionate colors. Red!",
            BURNT = "Twas consumed by Hel's fire.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Tis a spotted spotlight!",
            OFF = "A gift from the earth.",
            BURNT = "Laid to waste.",
        },
        SLEEPBOMB = "Those who enter thy circle shalt know rest.",
        MUSHROOMBOMB = "Defend thyselves, my allies!",
        SHROOM_SKIN = "A trophy of our battles!",
        TOADSTOOL_CAP =
        {
            EMPTY = "A cleft in the earth.",
            INGROUND = "Something emerges!",
            GENERIC = "You will bend to my blade, toadstool!",
        },
        TOADSTOOL =
        {
            GENERIC = "Ha! Finally, a worthy foe!",
            RAGE = "Give me your best shot, I'll not hold back!",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Destroy the source of its unholy power!",
            BURNT = "Naught but ash.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "What magic is this?",
            BLOOM = "An enthusiastic performance!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "I do like its glow.",
            BLOOM = "What a great effect!",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "I don't care for mushrooms.",
            BLOOM = "I'll fight alongside you any day!",
        },
        MUSHTREE_TALL_WEBBED = "This mushroom needs to be retired.",
        SPORE_TALL =
        {
            GENERIC = "At peace, benevolent river spirit.",
            HELD = "I'll direct this light where I please.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "At peace, benevolent flame spirit.",
            HELD = "I'll direct this light where I please.",
        },
        SPORE_SMALL =
        {
            GENERIC = "At peace, benevolent forest spirit.",
            HELD = "I'll direct this light where I please.",
        },
        RABBITHOUSE =
        {
            GENERIC = "What's to be done with a carrot that big?",
            BURNT = "Good riddance, giant carrot.",
        },
        SLURTLE = "You are an angel. Of nasty.",
        SLURTLE_SHELLPIECES = "They're smashed up good.",
        SLURTLEHAT = "A fine battle helm!",
        SLURTLEHOLE = "Not where I'd choose to hang my helm.",
        SLURTLESLIME = "Yes. Slime.",
        SNURTLE = "I like his helmet.",
        SPIDER_HIDER = "I'll smash you!",
        SPIDER_SPITTER = "That one's feisty.",
        SPIDERHOLE = "Webbing. Never a good sign.",
        SPIDERHOLE_ROCK = "Webbing. Never a good sign.",
        STALAGMITE = "Cave boulder.",
        STALAGMITE_TALL = "A pointy rock of sorts.",

        TURF_CARPETFLOOR = "It soaks up the blood of battle.",
        TURF_CHECKERFLOOR = "Fancy floor.",
        TURF_DIRT = "A piece of the battlefield.",
        TURF_FOREST = "A piece of the battlefield.",
        TURF_GRASS = "A piece of the battlefield.",
        TURF_MARSH = "A piece of the battlefield.",
        TURF_METEOR = "A piece of the battlefield.",
        TURF_PEBBLEBEACH = "A piece of the battlefield.",
        TURF_ROAD = "The road to battle leads wherever we will it.",
        TURF_ROCKY = "A piece of the battlefield.",
        TURF_SAVANNA = "A piece of the battlefield.",
        TURF_WOODFLOOR = "Wooden flooring, a fine surface for mortal combat.",

		TURF_CAVE="A piece of the battlefield.",
		TURF_FUNGUS="A piece of the battlefield.",
		TURF_FUNGUS_MOON = "A piece of the battlefield.",
		TURF_ARCHIVE = "A piece of the battlefield.",
		TURF_SINKHOLE="A piece of the battlefield.",
		TURF_UNDERROCK="A piece of the battlefield.",
		TURF_MUD="A piece of the battlefield.",

		TURF_DECIDUOUS = "A piece of the battlefield.",
		TURF_SANDY = "A piece of the battlefield.",
		TURF_BADLANDS = "A piece of the battlefield.",
		TURF_DESERTDIRT = "A piece of the battlefield.",
		TURF_FUNGUS_GREEN = "A piece of the battlefield.",
		TURF_FUNGUS_RED = "A piece of the battlefield.",
		TURF_DRAGONFLY = "A warm piece of the battlefield.",

        TURF_SHELLBEACH = "A piece of the battlefield.",

		POWCAKE = "What in the name of the unicorn is this?",
        CAVE_ENTRANCE = "What treasures lie beneath?",
        CAVE_ENTRANCE_RUINS = "What treasures lie beneath?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "I've no desire to visit Hel today.",
            OPEN = "To the underworld!",
            FULL = "It's more packed than the Thingvellir!",
        },
        CAVE_EXIT =
        {
            GENERIC = "I've had enough of Sol's shining face for one day.",
            OPEN = "Back to open skies!",
            FULL = "There are too many people up there.",
        },

		MAXWELLPHONOGRAPH = "A mechanical songstress.",--single player
		BOOMERANG = "For flinging at foes!",
		PIGGUARD = "He is battle ready, I can tell.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "What do you desire, apparition?",
                "What do you desire, apparition?",
            },
            LEVEL2 =
            {
                "What do you desire, apparition?",
                "What do you desire, apparition?",
            },
            LEVEL3 =
            {
                "What do you desire, apparition?",
                "What do you desire, apparition?",
            },
		},
		ADVENTURE_PORTAL = "Adventure is calling.",
		AMULET = "It's red, and a fighter. Just like me!",
		ANIMAL_TRACK = "Oh! I love a good hunt.",
		ARMORGRASS = "Grass protection. That's not going to last long.",
		ARMORMARBLE = "Near impenetrable!",
		ARMORWOOD = "A borrowed tree vest.",
		ARMOR_SANITY = "Strong, but such a headache it gives...",
		ASH =
		{
			GENERIC = "The flames' remains.",
			REMAINS_GLOMMERFLOWER = "The flower must remain in its home world.",
			REMAINS_EYE_BONE = "The eyebone could not pass to this world.",
			REMAINS_THINGIE = "It's burnt. Gone.",
		},
		AXE = "To chop and destroy!",
		BABYBEEFALO =
		{
			GENERIC = "Mini beastie.",
		    SLEEPING = "The mini beast slumbers.",
        },
        BUNDLE = "Ready to take on an epic saga.",
        BUNDLEWRAP = "That's a wrap.",
		BACKPACK = "A portable armory.",
		BACONEGGS = "Pig and eggs!",
		BANDAGE = "To heal even the deepest of battle wounds.",
		BASALT = "A thousand mortals couldn't break through this stone.", --removed
		BEARDHAIR = "Fur of the crazies.",
		BEARGER = "Beast or berserker?",
		BEARGERVEST = "BEAR-SERKER!",
		ICEPACK = "A backpack of the beast.",
		BEARGER_FUR = "It fought bravely, but its hide is now forfeit.",
		BEDROLL_STRAW = "A tool for valiant naps.",
		BEEQUEEN = "Your monarchy shall topple this day!",
		BEEQUEENHIVE =
		{
			GENERIC = "A land not of milk, but of honey.",
			GROWING = "The bees are expanding their domain.",
		},
        BEEQUEENHIVEGROWN = "A hive of winged warriors.",
        BEEGUARD = "En guarde!",
        HIVEHAT = "Vikings do not wear horns.",
        MINISIGN =
        {
            GENERIC = "The runes hath been drawn!",
            UNDRAWN = "Tis blank as the cloudless sky.",
        },
        MINISIGN_ITEM = "A surface on which to inscribe ancient runes.",
		BEE =
		{
			GENERIC = "Wee warriors! I don't know if I like them.",
			HELD = "Easy now!",
		},
		BEEBOX =
		{
			READY = "It's a honey treasure trove!",
			FULLHONEY = "It's a honey treasure trove!",
			GENERIC = "A sweet box of wee warriors.",
			NOHONEY = "Where's the honey?",
			SOMEHONEY = "Pithy honey. More patience is needed.",
			BURNT = "The hive is silent.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "The forest sprite has returned a glorious bounty!",
			LOTS = "It is growing strong and hearty.",
			SOME = "The forest sprite has taken root.",
			EMPTY = "An empty home for forest sprites.",
			ROTTEN = "A blight has beset this log. Another!",
			BURNT = "Twas consumed by a mighty inferno!",
			SNOWCOVERED = "Not all can withstand the frost giant's touch.",
		},
		BEEFALO =
		{
			FOLLOWER = "Come along beastie.",
			GENERIC = "Ancient woolen beasts!",
			NAKED = "Are you cold without your wools?",
			SLEEPING = "Sounds like Aunt Hilda.",
            --Domesticated states:
            DOMESTICATED = "The critter has finally learned its role.",
            ORNERY = "The noble steed of a mighty warrior!",
            RIDER = "With the stalwart beast at my side, we ride tonight!",
            PUDGY = "My mouth's watering just looking at it...",
            MYPARTNER = "A proud an noble beast, bonded to a proud and noble warrior.",
		},

		BEEFALOHAT = "That would suit me.",
		BEEFALOWOOL = "I do love woolly things.",
		BEEHAT = "A bee helm, of course.",
        BEESWAX = "The stuff of candlemakers.",
		BEEHIVE = "Always buzzing, always plotting.",
		BEEMINE = "It sounds suspicious.",
		BEEMINE_MAXWELL = "Watch your step!",--removed
		BERRIES = "Fruits. I don't like 'em.",
		BERRIES_COOKED = "Warm red mush.",
        BERRIES_JUICY = "I'd prefer a juicy steak.",
        BERRIES_JUICY_COOKED = "You're not meat.",
		BERRYBUSH =
		{
			BARREN = "Should we put some turds on it?",
			WITHERED = "It's too hot to grow.",
			GENERIC = "A fruit bush.",
			PICKED = "The fruits have been snatched.",
			DISEASED = "Disease festers within its soul.",--removed
			DISEASING = "It is weakening before mine eyes!",--removed
			BURNING = "Consumed by passionate flame!",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "Good.",
			WITHERED = "It looks atrocious.",
			GENERIC = "It's covered in rabbit food.",
			PICKED = "The rabbit food is all gone.",
			DISEASED = "Disease festers within its soul.",--removed
			DISEASING = "It is weakening before mine eyes!",--removed
			BURNING = "Consumed by passionate flame!",
		},
		BIGFOOT = "That's something completely different!",--removed
		BIRDCAGE =
		{
			GENERIC = "A home for my ravens!",
			OCCUPIED = "Are you having a nice time?",
			SLEEPING = "Sweet dreams, raven friend.",
			HUNGRY = "What do you want, little friend?",
			STARVING = "The raven wishes to feast!",
			DEAD = "You can feast in Valhalla now, friend.",
			SKELETON = "The cage is soiled.",
		},
		BIRDTRAP = "I'm a cunning raven catcher!",
		CAVE_BANANA_BURNT = "Thoroughly vanquished.",
		BIRD_EGG = "Eggy.",
		BIRD_EGG_COOKED = "Hot egg.",
		BISHOP = "This one needs a good smack.",
		BLOWDART_FIRE = "Like the breath of a dragon.",
		BLOWDART_SLEEP = "Goodnight to our foes.",
		BLOWDART_PIPE = "Projectile weaponry!",
		BLOWDART_YELLOW = "A face-to-face fight would be more honorable.",
		BLUEAMULET = "Cold jewelery.",
		BLUEGEM = "An icy blue sapphire.",
		BLUEPRINT =
		{
            COMMON = "Oh, a map! No, wait. That's wrong.",
            RARE = "Tis a blessed scroll.",
        },
        SKETCH = "The muses' knowledge, inscribed upon an ancient scroll!",
		BLUE_CAP = "Hmm, a blue one.",
		BLUE_CAP_COOKED = "I have no desire to eat it.",
		BLUE_MUSHROOM =
		{
			GENERIC = "It's mold, really.",
			INGROUND = "Good, it's hiding.",
			PICKED = "I hope it doesn't grow again.",
		},
		BOARDS = "Grandfather logs.",
		BONESHARD = "Bits of our enemies.",
		BONESTEW = "Delicious!",
		BUGNET = "To snatch insects from the air.",
		BUSHHAT = "For the hunt.",
		BUTTER = "Butter. Might it be good on steak?",
		BUTTERFLY =
		{
			GENERIC = "It is sort of nice.",
			HELD = "Caught!",
		},
		BUTTERFLYMUFFIN = "Muffin, smuffin.",
		BUTTERFLYWINGS = "A pretty souvenir.",
		BUZZARD = "You and I, we meat feast together.",

		SHADOWDIGGER = "I hope this serf is being treated with dignity.",

		CACTUS =
		{
			GENERIC = "It does have admirable armor.",
			PICKED = "It will return.",
		},
		CACTUS_MEAT_COOKED = "Toasted sword plant meat.",
		CACTUS_MEAT = "Sword plant meat.",
		CACTUS_FLOWER = "Beauty from brawn.",

		COLDFIRE =
		{
			EMBERS = "That fire's nearly dead.",
			GENERIC = "A cold comfort.",
			HIGH = "The fire roars!",
			LOW = "Fire's slowly dying.",
			NORMAL = "A cold comfort.",
			OUT = "And the light flickers out.",
		},
		CAMPFIRE =
		{
			EMBERS = "That fire's nearly dead.",
			GENERIC = "Warm fire, warm Wigfrid.",
			HIGH = "The fire roars!",
			LOW = "Fire's slowly dying.",
			NORMAL = "Warm fire, warm Wigfrid.",
			OUT = "And the light flickers out.",
		},
		CANE = "Turns \"walk\" to \"trot\".",
		CATCOON = "Oh! Cute meat with fur.",
		CATCOONDEN =
		{
			GENERIC = "Cute meat lives there.",
			EMPTY = "She fought bravely. Alas, she is gone.",
		},
		CATCOONHAT = "A furry cap! Blessings to you, cute meat.",
		COONTAIL = "It is the tail of cute meat.",
		CARROT = "Where's the protein?",
		CARROT_COOKED = "Sad cooked carrots.",
		CARROT_PLANTED = "A wee root vegetable.",
		CARROT_SEEDS = "Tiny nature bits.",
		CARTOGRAPHYDESK =
		{
			GENERIC = "What legends might I find within these maps?",
			BURNING = "Alas! My hunting excursions will go unregaled!",
			BURNT = "I've no choice but to act out my directions now.",
		},
		WATERMELON_SEEDS = "Seedy.",
		CAVE_FERN = "Foliage from the dark ages.",
		CHARCOAL = "Loot from Loge, the demigod.",
        CHESSPIECE_PAWN = "Tis a noble foot soldier.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "A castle fit for a queen.",
            STRUGGLE = "Battle is nigh!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "The figure of a fellow warrior!",
            STRUGGLE = "Battle is nigh!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "This warrior does battle in the mind.",
            STRUGGLE = "Battle is nigh!",
        },
        CHESSPIECE_MUSE = "A Valkyrie's spirit dwells within.",
        CHESSPIECE_FORMAL = "Not a man fit for battle.",
        CHESSPIECE_HORNUCOPIA = "Feasts, feasts, everywhere, and not a ham to eat.",
        CHESSPIECE_PIPE = "Tis but a jest.",
        CHESSPIECE_DEERCLOPS = "Our fight shall be made ballad.",
        CHESSPIECE_BEARGER = "Twas a battle to sing of.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Twas an honor to fight thee.",
        },
        CHESSPIECE_DRAGONFLY = "Tis the trophy of glorious battle!",
		CHESSPIECE_MINOTAUR = "The beast guarded its treasure well, but not well enough.",
        CHESSPIECE_BUTTERFLY = "To celebrate the moon's messenger!",
        CHESSPIECE_ANCHOR = "'Twas made in honor of our stalwart vessel!",
        CHESSPIECE_MOON = "Offered in honor of our beauteous moon!",
        CHESSPIECE_CARRAT = "I'm not keen on honoring a vegetable so.",
        CHESSPIECE_MALBATROSS = "To honor our victory at sea!",
        CHESSPIECE_CRABKING = "'Twas a hard-fought battle, but we prevailed!",
        CHESSPIECE_TOADSTOOL = "An honorable yet odious creature!",
        CHESSPIECE_STALKER = "A hard stone monument to a hard fought battle.",
        CHESSPIECE_KLAUS = "A tribute to the festive warrior spirit.",
        CHESSPIECE_BEEQUEEN = "I honor this warrior queen!",
        CHESSPIECE_ANTLION = "The artist hath captured her noble mane perfectly.",
        CHESSPIECE_BEEFALO = "A stone tribute to my faithful steed.",
		CHESSPIECE_KITCOON = "A mighty pillar for a mighty family!",
		CHESSPIECE_CATCOON = "You have my respect, fellow hunter.",
        CHESSPIECE_GUARDIANPHASE3 = "You fought well, Champion of Mani.",
        CHESSPIECE_EYEOFTERROR = "I shall feast my eyes upon this trophy!",
        CHESSPIECE_TWINSOFTERROR = "A battle I shan't soon forget.",

        CHESSJUNK1 = "It's only a pile of fallen warriors.",
        CHESSJUNK2 = "More fallen mechanical warriors.",
        CHESSJUNK3 = "Someone should really clean this place up.",
		CHESTER = "Don't worry, I won't eat him.",
		CHESTER_EYEBONE =
		{
			GENERIC = "Who are you?",
			WAITING = "The eyeball is tired.",
		},
		COOKEDMANDRAKE = "She's definitely dead.",
		COOKEDMEAT = "Meeeat!",
		COOKEDMONSTERMEAT = "Monster beast steak.",
		COOKEDSMALLMEAT = "Yum, yum, meat snacks.",
		COOKPOT =
		{
			COOKING_LONG = "Might as well do something whilst I wait.",
			COOKING_SHORT = "Shouldn't be long now!",
			DONE = "What have we here?",
			EMPTY = "Nothing in there.",
			BURNT = "The fire reigned supreme.",
		},
		CORN = "A vegetable sword!",
		CORN_COOKED = "Popped corn smells good.",
		CORN_SEEDS = "Tiny nature bits.",
        CANARY =
		{
			GENERIC = "Oh sweet songbird, sing me thy tune!",
			HELD = "Freedom has been wrenched from thy grasp by mine own.",
		},
        CANARY_POISONED = "What plague has besieged this innocent woodland creature?",

		CRITTERLAB = "Tis a peculiar boulder.",
        CRITTER_GLOMLING = "A warrior's faithful companion!",
        CRITTER_DRAGONLING = "By the unicorn! A dragon!",
		CRITTER_LAMB = "I wouldst turn farmer for thee.",
        CRITTER_PUPPY = "I shall defend this hound to the death.",
        CRITTER_KITTEN = "She is a magnificent hunter!",
        CRITTER_PERDLING = "Not a raven, but wise nonetheless.",
		CRITTER_LUNARMOTHLING = "Mine lunar friend!",

		CROW =
		{
			GENERIC = "Raven friend!",
			HELD = "Together again.",
		},
		CUTGRASS = "A craftwoman's most elemental resource.",
		CUTREEDS = "I cleaned all the bugs out! Then I ate them.",
		CUTSTONE = "Solid stone!",
		DEADLYFEAST = "A most potent dish.", --unimplemented
		DEER =
		{
			GENERIC = "The beauty of Freya dwells in all creatures!",
			ANTLER = "Skadi has bestowed a gift on Freya's creature.",
		},
        DEER_ANTLER = "The unicorn's horn, in the flesh!",
        DEER_GEMMED = "Tis a magical woodland creature!",
		DEERCLOPS = "Rays will shine through my spear and poke out your eyeball!",
		DEERCLOPS_EYEBALL = "Delicious! I should like to share it with my new allies.",
		EYEBRELLAHAT =	"Don't get rain in your eye!",
		DEPLETED_GRASS =
		{
			GENERIC = "It's probably a tuft of grass.",
		},
        GOGGLESHAT = "T'would be no help in battle.",
        DESERTHAT = "Tis no helm.",
		DEVTOOL = "It smells of bacon!",
		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "A small hill of earth.",
		DIVININGROD =
		{
			COLD = "All is quiet.", --singleplayer
			GENERIC = "A mechanical hunting hound. For the hunt.", --singleplayer
			HOT = "Sound the horns! We've arrived!", --singleplayer
			WARM = "We've got the scent!", --singleplayer
			WARMER = "The hound is excited. We're getting close.", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "What cryptic ruins.", --singleplayer
			READY = "Seems it's missing a piece...", --singleplayer
			UNLOCKED = "Ready! The saga continues!", --singleplayer
		},
		DIVININGRODSTART = "This mysterious sword feels important.", --singleplayer
		DRAGONFLY = "Ah, dragon! At last we meet!",
		ARMORDRAGONFLY = "Excellent armor for the heat of battle.",
		DRAGON_SCALES = "Mystical scales.",
		DRAGONFLYCHEST = "This chest is worthy of my weapons.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "It has seen much battle.",
			GENERIC = "It retains the heat of the fallen beast.", --no gems
			NORMAL = "A small inferno burns within.", --one gem
			HIGH = "Its belly is alight with fearsome dragonfire.", --two gems
		},

        HUTCH = "A loyal companion, if ever there were one.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "An ensconced water sprite!",
            WAITING = "An unfortunate casualty of battle.",
        },
		LAVASPIT =
		{
			HOT = "Your fiery pools are no match for me!",
			COOL = "It's not very scary now, is it?",
		},
		LAVA_POND = "I shall not surrender to the fiery pits!",
		LAVAE = "A fiery foe!",
		LAVAE_COCOON = "The best allies are made in the heat of battle.",
		LAVAE_PET =
		{
			STARVING = "Its fires are dying out.",
			HUNGRY = "You must eat to keep your fires burning.",
			CONTENT = "It glows contentedly.",
			GENERIC = "A faithful, fiery friend.",
		},
		LAVAE_EGG =
		{
			GENERIC = "A dragon egg!",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "This egg looks chilly.",
			COMFY = "It's warm and toasty.",
		},
		LAVAE_TOOTH = "A fearsome eggy fang!",

		DRAGONFRUIT = "It's very fancy.",
		DRAGONFRUIT_COOKED = "Grilled fancy fruit.",
		DRAGONFRUIT_SEEDS = "Tiny nature bits.",
		DRAGONPIE = "Why isn't this a meat pie? Meat, meeeat!",
		DRUMSTICK = "Leg of beastie.",
		DRUMSTICK_COOKED = "Hooooot meat!",
		DUG_BERRYBUSH = "I should like to see that returned to the earth goddess.",
		DUG_BERRYBUSH_JUICY = "I should like to see that returned to the earth goddess.",
		DUG_GRASS = "I should like to see that returned to the earth goddess.",
		DUG_MARSH_BUSH = "I should like to see that returned to the earth goddess.",
		DUG_SAPLING = "I should like to see that returned to the earth goddess.",
		DURIAN = "Smells like my battle boots.",
		DURIAN_COOKED = "What was the purpose of cooking this?",
		DURIAN_SEEDS = "Tiny nature bits.",
		EARMUFFSHAT = "Yes, most practical!",
		EGGPLANT = "Purple and bulbous.",
		EGGPLANT_COOKED = "Food for the weak.",
		EGGPLANT_SEEDS = "Tiny nature bits.",

		ENDTABLE =
		{
			BURNT = "It was no challenge at all.",
			GENERIC = "Tis a tribute to Freya's beauty.",
			EMPTY = "There is no beast beneath.",
			WILTED = "Their beauty fades.",
			FRESHLIGHT = "The light burns bright.",
			OLDLIGHT = "The light wanes.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "The wood's ablaze!",
			BURNT = "Loge took that one.",
			CHOPPED = "Chopped by the warrior of the woods!",
			POISON = "This firewood will take a bit of extra work.",
			GENERIC = "Future firewood!",
		},
		ACORN = "There's a tree hiding within.",
        ACORN_SAPLING = "Grow strong, young twigs!",
		ACORN_COOKED = "The young tree has been cooked.",
		BIRCHNUTDRAKE = "A young tree warrior!",
		EVERGREEN =
		{
			BURNING = "The wood's ablaze!",
			BURNT = "Loge took that one.",
			CHOPPED = "Chopped by the warrior of the woods!",
			GENERIC = "I feel at home in the woods.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "The wood's ablaze!",
			BURNT = "Loge took that one.",
			CHOPPED = "Chopped by the warrior of the woods!",
			GENERIC = "A good sturdy tree.",
		},
		TWIGGYTREE =
		{
			BURNING = "The wood's ablaze!",
			BURNT = "Loge took that one.",
			CHOPPED = "Chopped by the warrior in the woods!",
			GENERIC = "Triumph will accompany its many resources.",
			DISEASED = "Disease festers within its soul.", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Grow tall and strong.",
        TWIGGY_OLD = "It will soon return to the earth.",
		TWIGGY_NUT = "It will one day rival Yggdrasil!",
		EYEPLANT = "Don't point your eyeball at me, foliage!",
		INSPECTSELF = "Who is that incredible warrior in the mirror?",
		FARMPLOT =
		{
			GENERIC = "I can't grow meat, what's the point?",
			GROWING = "They're growing stronger.",
			NEEDSFERTILIZER = "It wants a turd feast.",
			BURNT = "Serves you right for not growing meats!",
		},
		FEATHERHAT = "Seems a bit flashy for battle.",
		FEATHER_CROW = "A token from the ravens!",
		FEATHER_ROBIN = "Red as my hair.",
		FEATHER_ROBIN_WINTER = "Winter's feather.",
		FEATHER_CANARY = "In remembrance of a songbird.",
		FEATHERPENCIL = "Perhaps I'll pen a saga of my journeys!",
        COOKBOOK = "'Tis filled with too many non-meat dishes if you ask me.",
		FEM_PUPPET = "She looks unhappy upon her throne.", --single player
		FIREFLIES =
		{
			GENERIC = "Tiny fairy lights aglow!",
			HELD = "I hold the light!",
		},
		FIREHOUND = "The flamed one has no mercy.",
		FIREPIT =
		{
			EMBERS = "That fire's nearly dead.",
			GENERIC = "Warm fire, warm Wigfrid.",
			HIGH = "The fire roars!",
			LOW = "Fire's slowly dying.",
			NORMAL = "Warm fire, warm Wigfrid.",
			OUT = "And the light flickers out.",
		},
		COLDFIREPIT =
		{
			EMBERS = "That fire's nearly dead.",
			GENERIC = "A cold comfort.",
			HIGH = "The fire roars!",
			LOW = "Fire's slowly dying.",
			NORMAL = "A cold comfort.",
			OUT = "And the light flickers out.",
		},
		FIRESTAFF = "That we might become Masters of Fire!",
		FIRESUPPRESSOR =
		{
			ON = "Catapult engaged for battle!",
			OFF = "Time to rest, flinging warrior.",
			LOWFUEL = "The catapult grows weak and tired.",
		},

		FISH = "Meat of the sea!",
		FISHINGROD = "I'm a ruthless fisherwoman.",
		FISHSTICKS = "Spears of sea meat.",
		FISHTACOS = "Fish in a blanket!",
		FISH_COOKED = "Joy!",
		FLINT = "Vital for spear construction.",
		FLOWER =
		{
            GENERIC = "A flower from Freya.",
            ROSE = "Were that I smelled half as sweet.",
        },
        FLOWER_WITHERED = "Not enough time in the limelight.",
		FLOWERHAT = "Flimsy for the fight, enchanting on one's head.",
		FLOWER_EVIL = "A terrible evil plagues this flora.",
		FOLIAGE = "A collection of ferns.",
		FOOTBALLHAT = "A pig's bottom made this helmet.",
        FOSSIL_PIECE = "Bones of a dark and ancient foe.",
        FOSSIL_STALKER =
        {
			GENERIC = "All that remains of a terrible beast.",
			FUNNY = "Tis not as majestic as I once pictured.",
			COMPLETE = "It looks as though it might roam the earth any moment!",
        },
        STALKER = "It lives to battle once more!",
        STALKER_ATRIUM = "Tis no mindless beast!",
        STALKER_MINION = "A fiend woven from the night!",
        THURIBLE = "Tis Loki's frost giant lure.",
        ATRIUM_OVERGROWTH = "The writings of the gods t'were not meant for us.",
		FROG =
		{
			DEAD = "You're a bit slimy for Valhalla.",
			GENERIC = "I'd like some frog boots someday.",
			SLEEPING = "It sleeps.",
		},
		FROGGLEBUNWICH = "What a treat!",
		FROGLEGS = "Filled with rubbery protein!",
		FROGLEGS_COOKED = "I like when I can see the bones sticking out.",
		FRUITMEDLEY = "Ugh! Putting it into a cup doesn't fool me.",
		FURTUFT = "Fur from a large beastie.",
		GEARS = "Those might look nice glued to my helm.",
		GHOST = "A spirit trapped between worlds.",
		GOLDENAXE = "A tool of gold!",
		GOLDENPICKAXE = "Gold for gold.",
		GOLDENPITCHFORK = "A weapon of very wealthy farmers.",
		GOLDENSHOVEL = "Digging like a king!",
		GOLDNUGGET = "Such a pleasing gold piece.",
		GRASS =
		{
			BARREN = "The life has gone from it.",
			WITHERED = "The heat has defeated this plant.",
			BURNING = "Loge looks upon you!",
			GENERIC = "That could be useful.",
			PICKED = "I eagerly await the next harvest.",
			DISEASED = "Disease festers within its soul.", --unimplemented
			DISEASING = "It is weakening before mine eyes!", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "What flaxen scales.",
			DISEASED = "Alas! It is stricken.", --unimplemented
		},
		GREEN_CAP = "Terrible!",
		GREEN_CAP_COOKED = "Charred by flame or not, that will not touch my lips!",
		GREEN_MUSHROOM =
		{
			GENERIC = "It has risen!",
			INGROUND = "Hide, coward.",
			PICKED = "I see fungal spores.",
		},
		GUNPOWDER = "Such energy!",
		HAMBAT = "A weapon fit for the great dining halls!",
		HAMMER = "More fit for labor than battle.",
		HEALINGSALVE = "Be filled with life!",
		HEATROCK =
		{
			FROZEN = "Cold teeth bite at me!",
			COLD = "The stone has taken on cold!",
			GENERIC = "A stone of great use!",
			WARM = "The stone has taken on warmth!",
			HOT = "Loge would be proud.",
		},
		HOME = "Home is where the hearth is!",
		HOMESIGN =
		{
			GENERIC = "A most well placed sign.",
            UNWRITTEN = "I shall write a tale of triumph!",
			BURNT = "Signs of a battle past.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "A most well placed sign.",
            UNWRITTEN = "I shall point the way to triumph!",
			BURNT = "Signs of a battle past.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "A most well placed sign.",
            UNWRITTEN = "I shall point the way to triumph!",
			BURNT = "Signs of a battle past.",
		},
		HONEY = "Sticky and gross.",
		HONEYCOMB = "Wouldn't make much of a comb.",
		HONEYHAM = "A feast!",
		HONEYNUGGETS = "A feast!",
		HORN = "How I long for battle.",
		HOUND = "Fenrir's spawn!",
		HOUNDCORPSE =
		{
			GENERIC = "Rest well, fallen foe.",
			BURNING = "Burial by fire.",
			REVIVING = "The dead walk again!",
		},
		HOUNDBONE = "A fallen foe.",
		HOUNDMOUND = "These hounds are true warriors.",
		ICEBOX = "Winter dwells inside!",
		ICEHAT = "A chunk of cold.",
		ICEHOUND = "Teeth of frost!",
		INSANITYROCK =
		{
			ACTIVE = "Woah!",
			INACTIVE = "I suspect nothing of this rock.",
		},
		JAMMYPRESERVES = "Sticky and gross.",

		KABOBS = "A feast!",
		KILLERBEE =
		{
			GENERIC = "A challenger!",
			HELD = "A conquered foe.",
		},
		KNIGHT = "I taste a battle on the breeze!",
		KOALEFANT_SUMMER = "Dearest creature... I am going to eat you.",
		KOALEFANT_WINTER = "Poor unsuspecting meat beast.",
		KRAMPUS = "You don't scare me, goat!",
		KRAMPUS_SACK = "The sack itself is the present.",
		LEIF = "That is an ancient woodland being.",
		LEIF_SPARSE = "That is an ancient woodland being.",
		LIGHTER  = "It lights the fires of mine heart!",
		LIGHTNING_ROD =
		{
			CHARGED = "Oh, great lightning!",
			GENERIC = "Bring with you lightning, Donner!",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "May I call you Unicorn?",
			CHARGED = "The lightning has made you a unicorn warrior!",
		},
		LIGHTNINGGOATHORN = "This could deal a lasting blow.",
		GOATMILK = "This is powerful milk.",
		LITTLE_WALRUS = "A spawn of the evil toothed seal.",
		LIVINGLOG = "Burning such magic would seem a waste.",
		LOG =
		{
			BURNING = "Flaming log!",
			GENERIC = "Wood is always of value.",
		},
		LUCY = "It's nice, but it's no spear.",
		LUREPLANT = "Finally! A useful vegetable.",
		LUREPLANTBULB = "Perhaps I will be a meat farmer after all!",
		MALE_PUPPET = "He looks unhappy upon his throne.", --single player

		MANDRAKE_ACTIVE = "She just wants to go on a rutabaga saga.",
		MANDRAKE_PLANTED = "A rutabaga!",
		MANDRAKE = "The corpse of the rutabaga still retains its magic.",

        MANDRAKESOUP = "A stew of magic!",
        MANDRAKE_COOKED = "Grilled rutabaga.",
        MAPSCROLL = "Mayhaps the ink is invisible!",
        MARBLE = "The warrior stone!",
        MARBLEBEAN = "Fee fi fo fum!",
        MARBLEBEAN_SAPLING = "How dost thou grow?",
        MARBLESHRUB = "Tis a shrub of stone!",
        MARBLEPILLAR = "Fit for a palace!",
        MARBLETREE = "Even the winds cannot knock this tree down.",
        MARSH_BUSH =
        {
			BURNT = "Burnt down to nothing.",
            BURNING = "Hot log!",
            GENERIC = "A shrub on guard.",
            PICKED = "What a nuisance.",
        },
        BURNT_MARSH_BUSH = "Razed to the ground.",
        MARSH_PLANT = "Pond foliage.",
        MARSH_TREE =
        {
            BURNING = "It's ablaze!",
            BURNT = "Burnt.",
            CHOPPED = "Another must be planted to maintain the balance of this realm.",
            GENERIC = "A warrior tree.",
        },
        MAXWELL = "Arrg! Is that the antagonist to my saga?!",--single player
        MAXWELLHEAD = "I can see into his pores.",--removed
        MAXWELLLIGHT = "Dark magic lives here.",--single player
        MAXWELLLOCK = "Shall I unlock it?",--single player
        MAXWELLTHRONE = "I prefer to roam free, my unicorn and I.",--single player
        MEAT = "The true fruit of the earth!",
        MEATBALLS = "Tiny feast balls.",
        MEATRACK =
        {
            DONE = "Let's eat!",
            DRYING = "It's being prepared just the way I like it.",
            DRYINGINRAIN = "All this rain isn't helping.",
            GENERIC = "Ah! A dangly rack for my meats!",
            BURNT = "Such a shame.",
            DONE_NOTMEAT = "Tis as dry as an empty well!",
            DRYING_NOTMEAT = "It's drying out nicely.",
            DRYINGINRAIN_NOTMEAT = "All this rain isn't helping.",
        },
        MEAT_DRIED = "Excellent battle provisions.",
        MERM = "Die soggy beast fish!",
        MERMHEAD =
        {
            GENERIC = "I could smell it from back there!",
            BURNT = "Beheaded. Burnt. Stinky.",
        },
        MERMHOUSE =
        {
            GENERIC = "Is this dwelling made of fish?",
            BURNT = "I won't miss it.",
        },
        MINERHAT = "A lighted helm! For the darkness.",
        MONKEY = "I don't trust you.",
        MONKEYBARREL = "What horrors dwell within?",
        MONSTERLASAGNA = "Monster casserole.",
        FLOWERSALAD = "Leaves are for animals. Animals are for eating.",
        ICECREAM = "That stuff hurts my teeth.",
        WATERMELONICLE = "You cannot fool me by hiding in frozen fruit, stick.",
        TRAILMIX = "Meat of the nut is not true meat.",
        HOTCHILI = "A true test of willpower.",
        GUACAMOLE = "Yum, creamy!",
        MONSTERMEAT = "Meat of the dark beasts.",
        MONSTERMEAT_DRIED = "All dried up.",
        MOOSE = "I wish I could ride it into battle.",
        MOOSE_NESTING_GROUND = "A nest of adorable villainy.",
        MOOSEEGG = "Something is bouncing around inside.",
        MOSSLING = "You are not large enough to be a steed.",
        FEATHERFAN = "The luxuries of camp, on the go.",
        MINIFAN = "The chilling breeze reminds me of my frigid home.",
        GOOSE_FEATHER = "A shieldmaiden deserves a soft bed of dunn.",
        STAFF_TORNADO = "A storm of pain.",
        MOSQUITO =
        {
            GENERIC = "Ugh! These things are useless!",
            HELD = "Settle demon fury!",
        },
        MOSQUITOSACK = "The blood will make me strong.",
        MOUND =
        {
            DUG = "Loot trumped desecration!",
            GENERIC = "Are there treasures beneath the gravestones?",
        },
        NIGHTLIGHT = "I'm more comfortable around my own fire.",
        NIGHTMAREFUEL = "The fuel of darkness!",
        NIGHTSWORD = "It takes a brave warrior to wield this sword.",
        NITRE = "It contains explosive components.",
        ONEMANBAND = "Sing with me! We are the guardians of Asgard!",
        OASISLAKE =
		{
			GENERIC = "Perhaps a sword-wielding maiden lies beneath.",
			EMPTY = "Naught but a barren basin.",
		},
        PANDORASCHEST = "It contains a mystery.",
        PANFLUTE = "I prefer to face my enemies awake.",
        PAPYRUS = "May it carry forth the record of my saga.",
        WAXPAPER = "Waxen to the touch.",
        PENGUIN = "Birds of the sea, come from afar.",
        PERD = "You cannot run forever!",
        PEROGIES = "Pockets of meat.",
        PETALS = "Thank you Froh for this gift!",
        PETALS_EVIL = "These were not made by Froh.",
        PHLEGM = "The secretions of a terrible beast!",
        PICKAXE = "A trusty tool for securing spear and helm materials.",
        PIGGYBACK = "The pig died with honor, then gave to me this pack.",
        PIGHEAD =
        {
            GENERIC = "This is savagery.",
            BURNT = "Normally I like a good roast, but this is not right.",
        },
        PIGHOUSE =
        {
            FULL = "Come out and go to war with me!",
            GENERIC = "I did not think pigs could make houses.",
            LIGHTSOUT = "Do you not hunger for battle, pig?",
            BURNT = "Loge did not smile upon you this day.",
        },
        PIGKING = "Is it pig-Odin?",
        PIGMAN =
        {
            DEAD = "He died with honor.",
            FOLLOWER = "We ride to battle!",
            GENERIC = "Will you fight alongside me, pig?",
            GUARD = "That pig looks brave.",
            WEREPIG = "It has been tainted by Fenrir.",
        },
        PIGSKIN = "The hide of a pig creature.",
        PIGTENT = "It smells of breakfast!",
        PIGTORCH = "Do these pigs worship Loge?",
        PINECONE = "This baby tree is well protected by spiky armor.",
        PINECONE_SAPLING = "It has shed its armor. Grow, baby tree!",
        LUMPY_SAPLING = "It brings shame to the might of Yggdrasil.",
        PITCHFORK = "A weapon for farmers.",
        PLANTMEAT = "I suppose it's close enough.",
        PLANTMEAT_COOKED = "Still green, but it'll do.",
        PLANT_NORMAL =
        {
            GENERIC = "A plant.",
            GROWING = "I am a shieldmaiden, not a farmer!",
            READY = "Ugh, vegetables. I'm not sure what I expected...",
            WITHERED = "Bested by the sun.",
        },
        POMEGRANATE = "Fruity flesh.",
        POMEGRANATE_COOKED = "Seared fruit flesh.",
        POMEGRANATE_SEEDS = "Tiny nature bits.",
        POND = "Something lurks in the deep.",
        POOP = "If only I could use it as camouflage from predators.",
        FERTILIZER = "Its stench could raise the fallen.",
        PUMPKIN = "It might make a good bludgeon, at least.",
        PUMPKINCOOKIE = "Baked all the life out of it.",
        PUMPKIN_COOKED = "Piping hot orange mush.",
        PUMPKIN_LANTERN = "Do you wish to fight, vegetable?",
        PUMPKIN_SEEDS = "Tiny nature bits.",
        PURPLEAMULET = "An amulet of dark powers.",
        PURPLEGEM = "It is clouded by a mysterious energy.",
        RABBIT =
        {
            GENERIC = "Jump into my mouth!",
            HELD = "There is no escape!",
        },
        RABBITHOLE =
        {
            GENERIC = "Showtime, rabbits!",
            SPRING = "It must be intermission for the rabbits.",
        },
        RAINOMETER =
        {
            GENERIC = "It foretells the coming of rains.",
            BURNT = "Its prophecy days are done.",
        },
        RAINCOAT = "Armor for rain.",
        RAINHAT = "We will fight in the rain.",
        RATATOUILLE = "A pile of vegetables. No thanks.",
        RAZOR = "A small blade, but a blade nonetheless.",
        REDGEM = "It is hot to the touch.",
        RED_CAP = "Umami or not, I don't want it.",
        RED_CAP_COOKED = "I don't want it, but I'm glad it survived trial by fire.",
        RED_MUSHROOM =
        {
            GENERIC = "At least it's got a nice color.",
            INGROUND = "And stay down there!",
            PICKED = "Good riddance.",
        },
        REEDS =
        {
            BURNING = "See you in Asgard, reeds!",
            GENERIC = "Those are some hardy reeds.",
            PICKED = "Cut down in their prime.",
        },
        RELIC = "Fit for Asgard.",
        RUINS_RUBBLE = "Its days are not done.",
        RUBBLE = "A pile of ancient rocks.",
        RESEARCHLAB =
        {
            GENERIC = "I prefer battle to science.",
            BURNT = "Ashes to ashes.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "Perhaps science can enhance my combat skills.",
            BURNT = "Dust to dust.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "A mystical thing.",
            BURNT = "Its strange power did not protect it from fire.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "It is an absurd machine that makes meat.",
            BURNT = "No more meat will come from here!",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "Might the gods witness this visage and offer protection.",
            BURNT = "Valhalla, we come!",
        },
        RESURRECTIONSTONE = "It holds me back from Valhalla.",
        ROBIN =
        {
            GENERIC = "Red like blood.",
            HELD = "I prefer your black brethren.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "This bird knows about the cold.",
            HELD = "Such fluffy feathers.",
        },
        ROBOT_PUPPET = "A prisoner!", --single player
        ROCK_LIGHT =
        {
            GENERIC = "The lava crust is firm.",--removed
            OUT = "Looks delicate.",--removed
            LOW = "The lava crust is reforming.",--removed
            NORMAL = "Beautiful light!",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "A feat of strength in the making.",
            RAISED = "I will clear the way!",
        },
        ROCK = "Smash!",
        PETRIFIED_TREE = "My mere presence struck terror into their tree-hearts!",
        ROCK_PETRIFIED_TREE = "My mere presence struck terror into their tree-hearts!",
        ROCK_PETRIFIED_TREE_OLD = "My mere presence struck terror into their tree-hearts!",
        ROCK_ICE =
        {
            GENERIC = "A miniature frozen mountain.",
            MELTED = "Poor glacier!",
        },
        ROCK_ICE_MELTED = "Poor glacier!",
        ICE = "Reminds me of home.",
        ROCKS = "Some pretty normal rocks.",
        ROOK = "Chaaaarge!",
        ROPE = "Strong enough to bind the sails of my longship.",
        ROTTENEGG = "Ruined for eating, but primed for battle.",
        ROYAL_JELLY = "To absorb the felled queen's power!",
        JELLYBEAN = "The yield of an industrious candy farmer.",
        SADDLE_BASIC = "Now to find a faithful steed.",
        SADDLE_RACE = "Oh to fly on the wings of Valkyrie!",
        SADDLE_WAR = "I ride to victory or death!",
        SADDLEHORN = "Mighty steeds can be unsaddled with this.",
        SALTLICK = "Minerals, not meat.",
        BRUSH = "Time for hair and makeup!",
		SANITYROCK =
		{
			ACTIVE = "I do not think I can best this rock in combat.",
			INACTIVE = "Clever rock, you cannot surprise a warrior!",
		},
		SAPLING =
		{
			BURNING = "Nooo! My spears!",
			WITHERED = "It has been shriveled by the heat.",
			GENERIC = "It longs to be a spear.",
			PICKED = "The small tree has been slain!",
			DISEASED = "Disease festers within its soul.", --removed
			DISEASING = "It is weakening before mine eyes!", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Dost thou yearn for a brain?",
			BURNING = "The scarecrow burns.",
			BURNT = "The scarecrow dost yearn for nothing, now.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "A transformative altar for the stone gods.",
			BLOCK = "May the muses guide our hands!",
			SCULPTURE = "The muses have been kind this day.",
			BURNT = "Lain to waste.",
   		},
        SCULPTURE_KNIGHTHEAD = "Dost thou yearn for a body?",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "An abandoned monument to the gods?",
			UNCOVERED = "An icon of evil, surely!",
			FINISHED = "Might we come to regret this action?",
			READY = "The beast has been roused beneath!",
		},
        SCULPTURE_BISHOPHEAD = "A follower of Mimir, mayhaps?",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "More apt for the halls of Valhalla.",
			UNCOVERED = "We've freed the figure slumbering in the stone.",
			FINISHED = "Will this please the gods? Or anger them?",
			READY = "The beast has been roused beneath!",
		},
        SCULPTURE_ROOKNOSE = "It has strayed from the warrior's path.",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "Warriors are not concerned with decorative sculptures.",
			UNCOVERED = "I fear we've unleashed a great evil.",
			FINISHED = "Gods help us on Mani's night.",
			READY = "The beast has been roused beneath!",
		},
        GARGOYLE_HOUND = "Shed your stone form and fight, beast!",
        GARGOYLE_WEREPIG = "Do not cower behind your carapace of rock! Fight!",
		SEEDS = "Tiny nature bits.",
		SEEDS_COOKED = "Tiny nature bits, cooked to death.",
		SEWING_KIT = "I am no seamstress, but repairs are sometimes necessary.",
		SEWING_TAPE = "Luckily I need be no seamstress with this!",
		SHOVEL = "I'd prefer a ship burial, though this might have its uses.",
		SILK = "Useful for binding, and for remembering victories past.",
		SKELETON = "Rest easy in Valhalla.",
		SCORCHED_SKELETON = "Rest easy, spirit. Your fight is over.",
		SKULLCHEST = "Ah, that was a good battle.", --removed
		SMALLBIRD =
		{
			GENERIC = "You are not fierce yet, bird.",
			HUNGRY = "You must eat to grow strong.",
			STARVING = "The small bird looks famished.",
			SLEEPING = "Rest now, young one.",
		},
		SMALLMEAT = "A nice meaty snack.",
		SMALLMEAT_DRIED = "A small provision for a long campaign.",
		SPAT = "How much meat is hiding under there?",
		SPEAR = "That is not my favored spear, but it will do the trick.",
		SPEAR_WATHGRITHR = "My comrade in arms!",
		WATHGRITHRHAT = "The power of the unicorn is great.",
		SPIDER =
		{
			DEAD = "Cut down in battle, like so many before it.",
			GENERIC = "Eight legs and still no match for me!",
			SLEEPING = "I will give it a fair fight by waiting til it awakes.",
		},
		SPIDERDEN = "Crush them at the source!",
		SPIDEREGGSACK = "Squashing these would be a waste of future battles.",
		SPIDERGLAND = "Ripped from the abdomen of a slain spider.",
		SPIDERHAT = "A perfect way to infiltrate the enemy camp.",
		SPIDERQUEEN = "Finally, a true test of my abilities.",
		SPIDER_WARRIOR =
		{
			DEAD = "Victory once again!",
			GENERIC = "The champion of the spiders. To battle!",
			SLEEPING = "It is cowardly to attack a sleeping enemy.",
		},
		SPOILED_FOOD = "Age has only made this food gross, not wise.",
        STAGEHAND =
        {
			AWAKE = "Keep thy hand from out mine fires!",
			HIDING = "Merely a table.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "Delicate appearance, but hard as stone. Admirable.",
            TYPE1 = "What plagues you, fair maiden?",
            TYPE2 = "A sturdy little warrior.",
            TYPE3 = "Tis a stone basin!", --bird bath type statue
        },
		STATUEHARP = "It must be Gunnar. The snakes took his head.",
		STATUEMAXWELL = "The villain turns hero!",
		STEELWOOL = "It could easily best regular wool in combat.",
		STINGER = "The sword on the back of a bee.",
		STRAWHAT = "A hat for cooling after a raucous battle.",
		STUFFEDEGGPLANT = "Filling the vegetable does not make it meat.",
		SWEATERVEST = "It is a handsome vest, but it offers no protection.",
		REFLECTIVEVEST = "Ha! The sun is no warrior if it cannot penetrate this.",
		HAWAIIANSHIRT = "Flowers cannot stop a spear.",
		TAFFY = "Long will the saga of this taffy be told.",
		TALLBIRD = "A fearsome bird! But I am not afraid.",
		TALLBIRDEGG = "It will grow into a formidable foe.",
		TALLBIRDEGG_COOKED = "It was you or me, bird.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "This egg would not survive a Norse winter.",
			GENERIC = "Fight your way out, bird!",
			HOT = "Borne of flame! Unless it cooks to death.",
			LONG = "A time remains before this bird is to be born.",
			SHORT = "It will soon wake to this world.",
		},
		TALLBIRDNEST =
		{
			GENERIC = "A feathered warrior lurks inside.",
			PICKED = "A young bird of war will soon be born.",
		},
		TEENBIRD =
		{
			GENERIC = "You are not yet ready for battle, bird.",
			HUNGRY = "I hope you like vegetables... the meat is for me.",
			STARVING = "To enter battle with me is your choice, bird.",
			SLEEPING = "It's gathering its strength.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "To Asgard!", --single player
			GENERIC = "A bridge to another world.", --single player
			LOCKED = "The bridge is unstable yet.", --single player
			PARTIAL = "The bridge is incomplete.", --single player
		},
		TELEPORTATO_BOX = "Perhaps it holds the secret to this land's Bifrost.", --single player
		TELEPORTATO_CRANK = "A sturdy crank.", --single player
		TELEPORTATO_POTATO = "No decency. It's not even metal meat.", --single player
		TELEPORTATO_RING = "It appears to be similar to the Bifrost.", --single player
		TELESTAFF = "Ride through the air and the sea!",
		TENT =
		{
			GENERIC = "Sleep this night, and prepare for battle on the morrow.",
			BURNT = "It has been razed.",
		},
		SIESTAHUT =
		{
			GENERIC = "A place to rest one's battle-weary head.",
			BURNT = "It has been razed.",
		},
		TENTACLE = "It looks fierce. Into the fray!",
		TENTACLESPIKE = "Gooey, but dangerous. I like it.",
		TENTACLESPOTS = "A tough hide.",
		TENTACLE_PILLAR = "A towering tentacled foe.",
        TENTACLE_PILLAR_HOLE = "The lair of my tallest foe!",
		TENTACLE_PILLAR_ARM = "A gross, grasping appendage.",
		TENTACLE_GARDEN = "I will thrust my spear into that mass of tentacles!",
		TOPHAT = "It doesn't match my costume.",
		TORCH = "Perfect for a nighttime assault.",
		TRANSISTOR = "A marvel of science.",
		TRAP = "A well constructed trap. Tonight we feast!",
		TRAP_TEETH = "A treacherous trap.",
		TRAP_TEETH_MAXWELL = "An excellent mace wasted, buried in the ground.", --single player
		TREASURECHEST =
		{
			GENERIC = "A place to store my helm and spear whilst I rest.",
			BURNT = "Its walls were torn down by fire.",
		},
		TREASURECHEST_TRAP = "I am always ready.",
		SACRED_CHEST =
		{
			GENERIC = "What foul manner of chest is this?",
			LOCKED = "I shall submit to the gods' judgment.",
		},
		TREECLUMP = "A dead end! I must stand and fight.", --removed

		TRINKET_1 = "Toys do not interest a great warrior such as I.", --Melted Marbles
		TRINKET_2 = "Accompaniment for my ballad of triumphs.", --Fake Kazoo
		TRINKET_3 = "Even my spear cannot undo this knot.", --Gord's Knot
		TRINKET_4 = "A small, peculiar man.", --Gnome
		TRINKET_5 = "Will it take me to Asgard?", --Toy Rocketship
		TRINKET_6 = "Useless technology.", --Frazzled Wires
		TRINKET_7 = "No time for games! I must train my new allies!", --Ball and Cup
		TRINKET_8 = "It would make an okay weapon in a pinch.", --Rubber Bung
		TRINKET_9 = "No decent armor could be made with these.", --Mismatched Buttons
		TRINKET_10 = "A token of victory.", --Dentures
		TRINKET_11 = "A warrior encased in armor. I'm told its name is \"Hal.\"", --Lying Robot
		TRINKET_12 = "Remnants of Ms. Wicker's summons? Truly a fierce woman.", --Dessicated Tentacle
		TRINKET_13 = "A small, peculiar woman.", --Gnomette
		TRINKET_14 = "Tea is a luxury that warriors cannot afford.", --Leaky Teacup
		TRINKET_15 = "A noble fighter.", --Pawn
		TRINKET_16 = "A noble fighter.", --Pawn
		TRINKET_17 = "A poor weapon.", --Bent Spork
		TRINKET_18 = "I must mentor the young one in battle strategy.", --Trojan Horse
		TRINKET_19 = "A useless toy.", --Unbalanced Top
		TRINKET_20 = "Finally, a safe weapon with which to spar with my new allies.", --Backscratcher
		TRINKET_21 = "Cooking utensils do not interest me.", --Egg Beater
		TRINKET_22 = "It won't stand up to the rigors of battle.", --Frayed Yarn
		TRINKET_23 = "Not as useful as a battle horn.", --Shoehorn
		TRINKET_24 = "Grant me luck on the battlefield!", --Lucky Cat Jar
		TRINKET_25 = "Perhaps the stench will drive the enemy away.", --Air Unfreshener
		TRINKET_26 = "My allies will appreciate the survival training I've bestowed.", --Potato Cup
		TRINKET_27 = "This weak, flimsy wire reminds me... I must toughen Maxwell up!", --Coat Hanger
		TRINKET_28 = "Even the feeble can wage mighty battle upon the board.", --Rook
        TRINKET_29 = "Even the feeble can wage mighty battle upon the board.", --Rook
        TRINKET_30 = "Tis not a unicorn.", --Knight
        TRINKET_31 = "Tis not a unicorn.", --Knight
        TRINKET_32 = "Reveal mine destiny, oh great fates!", --Cubic Zirconia Ball
        TRINKET_33 = "The creature has been forever imprisoned upon the ring.", --Spider Ring
        TRINKET_34 = "Begone, foul magic!", --Monkey Paw
        TRINKET_35 = "Twas a poison, most assuredly.", --Empty Elixir
        TRINKET_36 = "Evidence of the undead. Stay wary, my allies!", --Faux fangs
        TRINKET_37 = "For warding off Loki's minions.", --Broken Stake
        TRINKET_38 = "There is a tiny world trapped within!", -- Binoculars Griftlands trinket
        TRINKET_39 = "To arms! The gauntlet has been thrown down!", -- Lone Glove Griftlands trinket
        TRINKET_40 = "I have no use for such things.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Perhaps some sort of elixir lies within?", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Tis no foe worthy of I.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "What manner of creature be this?", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "It has fallen in battle.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "What stories might you tell, trapped spirit?", -- Odd Radio ONI trinket
        TRINKET_46 = "Tis a suspicious contraption!", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "It hath the stench of death upon it.",
        LOST_TOY_2  = "It hath the stench of death upon it.",
        LOST_TOY_7  = "It hath the stench of death upon it.",
        LOST_TOY_10 = "It hath the stench of death upon it.",
        LOST_TOY_11 = "It hath the stench of death upon it.",
        LOST_TOY_14 = "It hath the stench of death upon it.",
        LOST_TOY_18 = "It hath the stench of death upon it.",
        LOST_TOY_19 = "It hath the stench of death upon it.",
        LOST_TOY_42 = "It hath the stench of death upon it.",
        LOST_TOY_43 = "It hath the stench of death upon it.",

        HALLOWEENCANDY_1 = "How sinister! I nearly mistook it for a true apple!",
        HALLOWEENCANDY_2 = "A clever ruse. It is not corn at all.",
        HALLOWEENCANDY_3 = "A confection to strike terror into any warrior's heart!",
        HALLOWEENCANDY_4 = "Monsters, prepare to do battle with a Viking's teeth!",
        HALLOWEENCANDY_5 = "The perfect treat!",
        HALLOWEENCANDY_6 = "What have I done to anger the gods so?",
        HALLOWEENCANDY_7 = "That monarch swine insults me.",
        HALLOWEENCANDY_8 = "I shall uncover its secret center!",
        HALLOWEENCANDY_9 = "The battle was mighty, yet in the end the worm was consumed!",
        HALLOWEENCANDY_10 = "I shall uncover its secret center!",
        HALLOWEENCANDY_11 = "Tis not meat, but tis close enough!",
        HALLOWEENCANDY_12 = "They look like that which writhe and crawl.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "You shalt not break me, confection!", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Wretched Hel's fire!", --Hot Lava pepper candy
        CANDYBAG = "That we might carry our sweetest plunders!",

		HALLOWEEN_ORNAMENT_1 = "Meant to hang from Yggdrasil's kin!",
		HALLOWEEN_ORNAMENT_2 = "Decoration! Prepare to be hung from something!",
		HALLOWEEN_ORNAMENT_3 = "It shall strike fear unto the hearts of mine foes!",
		HALLOWEEN_ORNAMENT_4 = "'tis but a decoration!",
		HALLOWEEN_ORNAMENT_5 = "It shalt be hung from the highest branch!",
		HALLOWEEN_ORNAMENT_6 = "Huginn? Or Muninn?",

		HALLOWEENPOTION_DRINKS_WEAK = "A meager reward for my troubles.",
		HALLOWEENPOTION_DRINKS_POTENT = "Fortune hath smiled upon me today!",
        HALLOWEENPOTION_BRAVERY = "Tis Berserker magic.",
		HALLOWEENPOTION_MOON = "Changeling elixir.",
		HALLOWEENPOTION_FIRE_FX = "Hel's fuel.",
		MADSCIENCE_LAB = "Be there method to this madness?",
		LIVINGTREE_ROOT = "I hath birthed the root of terror!",
		LIVINGTREE_SAPLING = "It bears the promise of horridness!",

        DRAGONHEADHAT = "The head of a great and merciful beast!",
        DRAGONBODYHAT = "It's the beast's back.",
        DRAGONTAILHAT = "A beast is no beast without a tail.",
        PERDSHRINE =
        {
            GENERIC = "What treasures shall I bestow upon thee?",
            EMPTY = "We must give it the gift of life.",
            BURNT = "Laid to waste.",
        },
        REDLANTERN = "A lucky ward to guard against the night.",
        LUCKY_GOLDNUGGET = "The unicorn smiles upon me this day!",
        FIRECRACKERS = "To strike fear into the hearts of mine enemies!",
        PERDFAN = "Tis a fan for mine hand.",
        REDPOUCH = "A blessing of good fortune!",
        WARGSHRINE =
        {
            GENERIC = "The gods are pleased!",
            EMPTY = "What doth thou need?",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "Laid to waste.",
        },
        CLAYWARG =
        {
        	GENERIC = "Lo! What terrible beast!",
        	STATUE = "T'would be a glorious battle, were it alive.",
        },
        CLAYHOUND =
        {
        	GENERIC = "I shall fell you swiftly!",
        	STATUE = "Tis a terrible wolf, turned to stone.",
        },
        HOUNDWHISTLE = "It casts a spell upon the dogged beasts.",
        CHESSPIECE_CLAYHOUND = "A hound of the hunt!",
        CHESSPIECE_CLAYWARG = "A testament to a worthy foe.",

		PIGSHRINE =
		{
            GENERIC = "'Tis a tribute worthy of the Pig Gods.",
            EMPTY = "Like me, it hungers only for meat.",
            BURNT = "Laid to waste.",
		},
		PIG_TOKEN = "The belt of a mighty pig warrior.",
		PIG_COIN = "The king of pigs hath granted me this favor.",
		YOTP_FOOD1 = "A meaty feast!",
		YOTP_FOOD2 = "'Tis fit only for the beasts.",
		YOTP_FOOD3 = "I shall consume it!",

		PIGELITE1 = "The warrior spirit runs deep within him.", --BLUE
		PIGELITE2 = "He rages with berserker fury.", --RED
		PIGELITE3 = "He shall not soil mine warrior reputation!", --WHITE
		PIGELITE4 = "Hath the strength of Yggdrasil.", --GREEN

		PIGELITEFIGHTER1 = "The warrior spirit runs deep within him.", --BLUE
		PIGELITEFIGHTER2 = "He rages with berserker fury.", --RED
		PIGELITEFIGHTER3 = "He shall not soil mine warrior reputation!", --WHITE
		PIGELITEFIGHTER4 = "Hath the strength of Yggdrasil.", --GREEN

		CARRAT_GHOSTRACER = "This shadowy creature seeks to challenge me.",

        YOTC_CARRAT_RACE_START = "We shall see which vegetable beast prevails!",
        YOTC_CARRAT_RACE_CHECKPOINT = "A waypoint to guide our vegetable beasts.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "Who shall claim this noble victory?",
            BURNT = "Alas, it is no more.",
            I_WON = "The day is won!",
            SOMEONE_ELSE_WON = "{winner}'s vegetable champion has seized victory.",
        },

		YOTC_CARRAT_RACE_START_ITEM = "The race cannot commence without it!",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "A waypoint to guide our vegetable beasts.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "This shall mark the race's end point.",

		YOTC_SEEDPACKET = "I care not for growing vegetables.",
		YOTC_SEEDPACKET_RARE = "The rarity of these non-meats doth not impress me.",

		MINIBOATLANTERN = "The small vessel shall light my way.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "It irks me to honor a vegetable.",
            EMPTY = "What dost thou need?",
            BURNT = "Tis naught but ashes now.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "I must ensure my veggie beast is quick-witted!",
            RAT = "You must train harder!",
            BURNT = "Reduced to cinders.",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "We shall test thine speed.",
            RAT = "Run! Run as if thine life depends on it!",
            BURNT = "Reduced to cinders.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "Reflexes are key in battle, and racing!",
            RAT = "Too slow!",
            BURNT = "Reduced to cinders.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "This odd training ground will suffice.",
            RAT = "Feel the warrior's spirit within you!",
            BURNT = "Reduced to cinders.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "A trial of wit.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "A trial of speed.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "A trial of endurance.",
        YOTC_CARRAT_GYM_REACTION_ITEM = "A trial of reflexes.",

        YOTC_CARRAT_SCALE_ITEM = "It's time to put my veggie beast to the test.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "We shall see just how strong my veggie beast truly is.",
            CARRAT = "You are not yet ready!",
            CARRAT_GOOD = "This beast will serve me well in the coming battle.",
            BURNT = "Naught but ash.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "My offering seems to have pleased the gods.",
            EMPTY = "It requires a sacrifice.",
            BURNT = "I hope the gods did not see that...",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Preparing for the stage is nearly as exhilarating as preparing for battle!",
            OCCUPIED = "This beastie is ready for its dress rehearsal.",
            BURNT = "The show must go on!",
        },
        BEEFALO_GROOMER_ITEM = "I must prepare!",

		BISHOP_CHARGE_HIT = "Rrraugh!",
		TRUNKVEST_SUMMER = "It will not suffice in the frozen wastes.",
		TRUNKVEST_WINTER = "The warm pelt of a bested creature. A fine garment.",
		TRUNK_COOKED = "A juicy reward after a hard battle.",
		TRUNK_SUMMER = "A powerful trunk of a fallen not-so-hairy beast.",
		TRUNK_WINTER = "A powerful trunk of a fallen hairy beast.",
		TUMBLEWEED = "Flee, bouncing coward!",
		TURKEYDINNER = "A true feast.",
		TWIGS = "Good for making spears.",
		UMBRELLA = "Rain protection made from the trophy of a hunt.",
		GRASS_UMBRELLA = "Flowers are not befitting a warrior, but wet armor is even worse.",
		UNIMPLEMENTED = "A mysterious relic, sure to contain great power.",
		WAFFLES = "Waffles are no way to prepare for battle!",
		WALL_HAY =
		{
			GENERIC = "A minor deterrent to attackers.",
			BURNT = "That won't do at all.",
		},
		WALL_HAY_ITEM = "Perhaps my foes will get lost in this hay.",
		WALL_STONE = "My enemies will dash themselves on these rocks.",
		WALL_STONE_ITEM = "A sturdy wall, fashioned from the earth.",
		WALL_RUINS = "Nigh impenetrable.",
		WALL_RUINS_ITEM = "Only the finest barriers for my fort.",
		WALL_WOOD =
		{
			GENERIC = "It may impale a foe.",
			BURNT = "Fire, wood's only weakness!",
		},
		WALL_WOOD_ITEM = "A mediocre fortification.",
		WALL_MOONROCK = "Wholly impregnable, a worthy fortification!",
		WALL_MOONROCK_ITEM = "Our fortress shall be impenetrable!",
		FENCE = "Tis not my kind of fencing.",
        FENCE_ITEM = "Not for fortification. Merely the farm.",
        FENCE_GATE = "A tiny replica of Valhalla's gates.",
        FENCE_GATE_ITEM = "Not for fortification. Merely the farm.",
		WALRUS = "Those tusks could pierce even the finest armor.",
		WALRUSHAT = "Highland filth!",
		WALRUS_CAMP =
		{
			EMPTY = "They have departed for a great journey.",
			GENERIC = "A proper winter camp.",
		},
		WALRUS_TUSK = "Rended from the mouth of the sea beast.",
		WARDROBE =
		{
			GENERIC = "That's where I keep my furs and cloaks.",
            BURNING = "No, my furs and cloaks!",
			BURNT = "No use crying over burnt pelts.",
		},
		WARG = "Be that you, Fenrir?",
        WARGLET = "Ha! I've felled more fearsome beasts than ye!",
        
		WASPHIVE = "Bees of war!",
		WATERBALLOON = "Prepare to engage in water-y battle!",
		WATERMELON = "It makes a good sound when you hit it.",
		WATERMELON_COOKED = "Warm and red, but it doesn't flow.",
		WATERMELONHAT = "It's almost like wearing a pelt.",
		WAXWELLJOURNAL = "A tragic tale of woe and misery!",
		WETGOOP = "Slop.",
        WHIP = "Loud and powerful!",
		WINTERHAT = "Warm, but not suited for combat.",
		WINTEROMETER =
		{
			GENERIC = "If only it measured the heat of battle.",
			BURNT = "The measuring device has been slain by Loge.",
		},

        WINTER_TREE =
        {
            BURNT = "Its beauty lives on in our hearts.",
            BURNING = "Woe! Misery!",
            CANDECORATE = "A majestic pine, worthy of celebration!",
            YOUNG = "Grow strong, young one! It is your destiny!",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "It awaits a grand tree!",
            BURNT = "Its beauty lives on in our hearts.",
		},
        WINTER_ORNAMENT = "A fragile beauty that must be protected.",
        WINTER_ORNAMENTLIGHT = "Tis a light enchantment, trapped inside a glass ball.",
        WINTER_ORNAMENTBOSS = "Tis not a celebration without a good battle!",
		WINTER_ORNAMENTFORGE = "Hath been forged in fires.",
		WINTER_ORNAMENTGORGE = "It feeds the festive spirit.",

        WINTER_FOOD1 = "How dost I free you from the bread, man of ginger??", --gingerbread cookie
        WINTER_FOOD2 = "Like a snowflake, it is a gift from the heavens!", --sugar cookie
        WINTER_FOOD3 = "T'would look as divine on the tree as in mine mouth!", --candy cane
        WINTER_FOOD4 = "Stay back, foul creation!", --fruitcake
        WINTER_FOOD5 = "We feast tonight!", --yule log cake
        WINTER_FOOD6 = "Twas plucked straight from my nightmares!", --plum pudding
        WINTER_FOOD7 = "Something so foul shall never pass my lips!", --apple cider
        WINTER_FOOD8 = "Warms the soul.", --hot cocoa
        WINTER_FOOD9 = "Imbibable eggs!", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "A hearth for cooking a glorious feast!",
			COOKING = "Locked in a glorious cooking battle.",
			ALMOST_DONE_COOKING = "The wait is almost at an end.",
			DISH_READY = "At long last, we feast!",
		},
		BERRYSAUCE = "It looks like vile berries but... that smell... could it be meat?",
		BIBINGKA = "Surely this loaf must be made of meat!",
		CABBAGEROLLS = "Begone foul cabbage, I shall feast on the meat within.",
		FESTIVEFISH = "Let us celebrate the season by feasting on fish flesh!",
		GRAVY = "A sauce worthy of the gods themselves!",
		LATKES = "My eyes see foul potatoes, but the taste of meat is unmistakable!",
		LUTEFISK = "A true Viking delicacy!",
		MULLEDDRINK = "Ha ha! Another!",
		PANETTONE = "My eyes doth deceive me, tis surely meat.",
		PAVLOVA = "Once the berries hath been removed, tis a fine dessert indeed.",
		PICKLEDHERRING = "A briny taste of the sea!",
		POLISHCOOKIE = "My nose shall not be deceived, these are surely meat!",
		PUMPKINPIE = "Tis surely a delicious meat pie in disguise!",
		ROASTTURKEY = "A glorious feast indeed!",
		STUFFING = "It bears the scent of meat. I will sample a morsel.",
		SWEETPOTATO = "Marshmallows on meat... tis an odd choice, but somehow delicious!",
		TAMALES = "Oh ho! This bready wrap hides a morsel of spiced meat!",
		TOURTIERE = "Pie hath redeemed itself!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "A feast table worthy of Valhalla!",
			HAS_FOOD = "A feast fit for The Great Hall!",
			WRONG_TYPE = "It is not worthy of a place here.",
			BURNT = "It's been consumed by fire.",
		},

		GINGERBREADWARG = "I will fight thee for defying thy meaty origins.",
		GINGERBREADHOUSE = "Neither a house nor a meal I will enjoy.",
		GINGERBREADPIG = "You shall not escape me!!",
		CRUMBS = "Telltale spoor left by a festive foe.",
		WINTERSFEASTFUEL = "The essence of Jol!",

        KLAUS = "I shall free thy deer this day!",
        KLAUS_SACK = "A secret, kept under lock and key!",
		KLAUSSACKKEY = "What wonders will you reveal?",
		WORMHOLE =
		{
			GENERIC = "Does it swallow those fallen in battle?",
			OPEN = "Its maw welcomes me.",
		},
		WORMHOLE_LIMITED = "It is sickly and weak.",
		ACCOMPLISHMENT_SHRINE = "My victories shall be remembered!", --single player
		LIVINGTREE = "A tree of life, but it is not Yggdrasil.",
		ICESTAFF = "A gift from Ullr!",
		REVIVER = "Feel the passion inside!",
		SHADOWHEART = "Blackest hearts. Darkest omens.",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "Tis a portrait of an ancient people. They live in wretchedness.",
			LINE_2 = "There is no painting here. Only stone.",
			LINE_3 = "A great evil sweeps across the land.",
			LINE_4 = "Many of the people are cleaved in two!",
			LINE_5 = "A glittering city, blessed by the gods.",
		},
        ATRIUM_STATUE = "I doth smell their fear!",
        ATRIUM_LIGHT =
        {
			ON = "An unholy flame.",
			OFF = "An ancient basin to house flames.",
		},
        ATRIUM_GATE =
        {
			ON = "A light to guide the way!",
			OFF = "Tis the Bifrost!",
			CHARGING = "Soon it will open the path!",
			DESTABILIZING = "Trickery! The Bifrost was of Loki!",
			COOLDOWN = "It shan't work again for some time.",
        },
        ATRIUM_KEY = "Heimdallr's key to the Bifrost.",
		LIFEINJECTOR = "This will return me to top form.",
		SKELETON_PLAYER =
		{
			MALE = "%s was felled by %s. He will live on in Valhalla.",
			FEMALE = "%s was felled by %s. She will live on in Valhalla.",
			ROBOT = "%s was felled by %s. They will live on in Valhalla.",
			DEFAULT = "%s was felled by %s. Live on in Valhalla.",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "A gift from Mani.",
		MOONROCKNUGGET = "A gift from Mani.",
		MOONROCKCRATER = "Mani's gift may have some use yet!",
		MOONROCKSEED = "It hath knowledge within!",

        REDMOONEYE = "Odin's eye, grant us wisdom!",
        PURPLEMOONEYE = "Odin's eye guides our path.",
        GREENMOONEYE = "Odin gave his eye that we might see.",
        ORANGEMOONEYE = "May Odin guide us.",
        YELLOWMOONEYE = "Odin, lend us your sight!",
        BLUEMOONEYE = "Odin's eye!",

        --Arena Event
        LAVAARENA_BOARLORD = "Tis a coward who watches the fight.",
        BOARRIOR = "You shall be a worthy opponent!",
        BOARON = "Tis barely a fight.",
        PEGHOOK = "You will be felled this day.",
        TRAILS = "Let us battle with honor!",
        TURTILLUS = "Your armor shalln't stop my spear.",
        SNAPPER = "I shall best you, foe!",
		RHINODRILL = "Thy machismo frighten me not!",
		BEETLETAUR = "You shall be chained again, foe!",

        LAVAARENA_PORTAL =
        {
            ON = "We dive, back into the ether!",
            GENERIC = "Tis a gate betwixt realms.",
        },
        LAVAARENA_KEYHOLE = "The Rainbow Bridge conceals itself.",
		LAVAARENA_KEYHOLE_FULL = "The Rainbow Bridge opens!",
        LAVAARENA_BATTLESTANDARD = "Let us down the enemy's standard!",
        LAVAARENA_SPAWNER = "Tis most heinous magic!",

        HEALINGSTAFF = "Blessings of magicks within.",
        FIREBALLSTAFF = "The gods did not mean thy magic for me.",
        HAMMER_MJOLNIR = "I am worthy!",
        SPEAR_GUNGNIR = "The weapon of a brazen Valkyrie!",
        BLOWDART_LAVA = "Njord guide my blows!",
        BLOWDART_LAVA2 = "Njord, lend me thy strength!",
        LAVAARENA_LUCY = "Thy axe is filled with burning passion this day!",
        WEBBER_SPIDER_MINION = "I see naught but allies.",
        BOOK_FOSSIL = "The curse of Alviss dwells within.",
		LAVAARENA_BERNIE = "The call of battle has arisen in thee!",
		SPEAR_LANCE = "Tis a divine spear!",
		BOOK_ELEMENTAL = "Twas not meant for mortal eyes.",
		LAVAARENA_ELEMENTAL = "Thy fire giant shall fight by our side.",

   		LAVAARENA_ARMORLIGHT = "That is not fit for a warrior!",
		LAVAARENA_ARMORLIGHTSPEED = "The wearer shalt be fleet of foot.",
		LAVAARENA_ARMORMEDIUM = "Tis not as sturdy as a warrior would hope.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "Makes the wearer sharp of tooth.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "Makes the wearer keen of mind.",
		LAVAARENA_ARMORHEAVY = "Tis a worthy suit of armor.",
		LAVAARENA_ARMOREXTRAHEAVY = "I shall not bend to whims of my foes.",

		LAVAARENA_FEATHERCROWNHAT = "Sleipnir bestowed it with swiftness.",
        LAVAARENA_HEALINGFLOWERHAT = "A blessing from Freya is contained within.",
        LAVAARENA_LIGHTDAMAGERHAT = "Horns, sharp as the spear of the Valkyrie.",
        LAVAARENA_STRONGDAMAGERHAT = "Empower me with thy Nox strength!",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Twas not made for a warrior.",
        LAVAARENA_EYECIRCLETHAT = "I'd not dabble in thy horrid magic.",
        LAVAARENA_RECHARGERHAT = "Magic stone, empower my spirit!",
        LAVAARENA_HEALINGGARLANDHAT = "Tis heavily laden with Freya's blessings.",
        LAVAARENA_CROWNDAMAGERHAT = "Be still my heart! Tis the king of battle helms!",

		LAVAARENA_ARMOR_HP = "I shall armor myself for battle!",

		LAVAARENA_FIREBOMB = "A barrage of Hel's fire.",
		LAVAARENA_HEAVYBLADE = "A mighty blade for a mighty battle!",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "The beast grows restless when tis not fed.",
        	FULL = "Accept my offering, oh mighty gods.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "Servant of a terrible god.",
		QUAGMIRE_PARK_FOUNTAIN = "Water of life! But no water!",

        QUAGMIRE_HOE = "Tis a farming weapon.",

        QUAGMIRE_TURNIP = "The gods have strange tastes.",
        QUAGMIRE_TURNIP_COOKED = "Ach! I shall not eat thee!",
        QUAGMIRE_TURNIP_SEEDS = "'Tis a handful of seeds, for not-meat.",

        QUAGMIRE_GARLIC = "Foul ingredient for sacrificial foods!",
        QUAGMIRE_GARLIC_COOKED = "The stench!",
        QUAGMIRE_GARLIC_SEEDS = "'Tis a handful of seeds, for not-meat.",

        QUAGMIRE_ONION = "I dare thee, provoke tears from mine eyes!",
        QUAGMIRE_ONION_COOKED = "The gods shall deal with thee!",
        QUAGMIRE_ONION_SEEDS = "'Tis a handful of seeds, for not-meat.",

        QUAGMIRE_POTATO = "Vileness emerged from the earth.",
        QUAGMIRE_POTATO_COOKED = "Useful only for sacrifice.",
        QUAGMIRE_POTATO_SEEDS = "'Tis a handful of seeds, for not-meat.",

        QUAGMIRE_TOMATO = "Will this not anger the gods?",
        QUAGMIRE_TOMATO_COOKED = "It boasts reddest guts, yet 'tis not meat!",
        QUAGMIRE_TOMATO_SEEDS = "'Tis a handful of seeds, for not-meat.",

        QUAGMIRE_FLOUR = "The wheat hath fallen in battle.",
        QUAGMIRE_WHEAT = "O, glorious wheat!",
        QUAGMIRE_WHEAT_SEEDS = "'Tis a handful of seeds, for not-meat.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "'Tis a handful of seeds, for not-meat.",

        QUAGMIRE_ROTTEN_CROP = "T'would never grace a hall in Valhalla.",

		QUAGMIRE_SALMON = "Tis a most delicious fish!",
		QUAGMIRE_SALMON_COOKED = "A feast from the sea.",
		QUAGMIRE_CRABMEAT = "T'would be an honor to be fed to the sky god, beast.",
		QUAGMIRE_CRABMEAT_COOKED = "Tis a delicacy!",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "The nectar of the gods dwells within.",
			STUMP = "It has been chopped.",
			TAPPED_EMPTY = "I've no patience for thee, sap!",
			TAPPED_READY = "I have acquired the nectar!",
			TAPPED_BUGS = "It hath been fouled by tiny beasts!",
			WOUNDED = "It hath been wounded!",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "Spice for the fanciest of foods.",
			PICKED = "Thine growing taketh too long!",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "'Tis a flavoring sprig.",
		QUAGMIRE_SPOTSPICE_GROUND = "It contains the flavoring!",
		QUAGMIRE_SAPBUCKET = "For pillaging from the trees.",
		QUAGMIRE_SAP = "Nectar of the gods.",
		QUAGMIRE_SALT_RACK =
		{
			READY = "'Tis ready to be pillaged!",
			GENERIC = "An ally to meat!",
		},

		QUAGMIRE_POND_SALT = "Be it a hot spring?",
		QUAGMIRE_SALT_RACK_ITEM = "I shall put thee to good use.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "Twas left by cities past.",
			LOCKED = "Tis sealed away from prying eyes and prying hands.",
		},

		QUAGMIRE_KEY = "'Tis the key to treasure!",
		QUAGMIRE_KEY_PARK = "Tis the key to Valhalla's gates.",
        QUAGMIRE_PORTAL_KEY = "'Tis the key to another world.",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Growing non-meat fungus.",
			PICKED = "'Tis vanquished.",
		},
		QUAGMIRE_MUSHROOMS = "Non-meat, I shall not consume thee!",
        QUAGMIRE_MEALINGSTONE = "A weapon for wheat!",
		QUAGMIRE_PEBBLECRAB = "Thou cannot hide from me!",


		QUAGMIRE_RUBBLE_CARRIAGE = "Twas pillaged long ago.",
        QUAGMIRE_RUBBLE_CLOCK = "The time is nigh!",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Twas the site of a vicious raid.",
        QUAGMIRE_RUBBLE_PUBDOOR = "It once led to adventure. Alas, no more.",
        QUAGMIRE_RUBBLE_ROOF = "It offers no sanctuary.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "The time is nigh!",
        QUAGMIRE_RUBBLE_BIKE = "A felled metal steed.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "Pillaged. But by what?",
            "If only they'd had a warrior to fight for them.",
            "What foul being caused such destruction?",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "It hath fallen.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Nothing of value remains.",
        QUAGMIRE_MERMHOUSE = "What horrid home!",
        QUAGMIRE_SWAMPIG_HOUSE = "Lodgings of mine enemy.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Laid to ruin.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "Your liege.",
            SLEEPING = "It slumbers soundly.",
        },
        QUAGMIRE_SWAMPIG = "You would make a most honorable warrior.",

        QUAGMIRE_PORTAL = "Tis closed to us.",
        QUAGMIRE_SALTROCK = "Tis the salt of the earth.",
        QUAGMIRE_SALT = "Twill make the meat even more divine.",
        --food--
        QUAGMIRE_FOOD_BURNT = "Consumed by Hel's fire.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "I shall offer it to the great god!",
            MISMATCH = "The Gnaw desires... not this.",
            MATCH = "This shall quench the god's appetite.",
            MATCH_BUT_SNACK = "'Tis what the Gnaw desires, paltry though it is.",
        },

        QUAGMIRE_FERN = "Tis not food fit for a god.",
        QUAGMIRE_FOLIAGE_COOKED = "This is certain to anger the god.",
        QUAGMIRE_COIN1 = "Treasure!",
        QUAGMIRE_COIN2 = "Coin! Prepare to be spent!",
        QUAGMIRE_COIN3 = "Fortune is mine!",
        QUAGMIRE_COIN4 = "I have earned the god's favor!",
        QUAGMIRE_GOATMILK = "It came from an animal, yet is still not meat!",
        QUAGMIRE_SYRUP = "Nectar of the gods, for the gods.",
        QUAGMIRE_SAP_SPOILED = "Alas, the nectar 'tis no longer sweet!",
        QUAGMIRE_SEEDPACKET = "Baby non-meats.",

        QUAGMIRE_POT = "Room for more meat!",
        QUAGMIRE_POT_SMALL = "We shall fill thee with meat!",
        QUAGMIRE_POT_SYRUP = "For the making of godly nectars!",
        QUAGMIRE_POT_HANGER = "It hangeth pots.",
        QUAGMIRE_POT_HANGER_ITEM = "'Tis no use to me in this form.",
        QUAGMIRE_GRILL = "It touches meat with the fires of Hel.",
        QUAGMIRE_GRILL_ITEM = "An instrument of the savory.",
        QUAGMIRE_GRILL_SMALL = "It touches meat with the fires of Hel.",
        QUAGMIRE_GRILL_SMALL_ITEM = "It doth not work like this.",
        QUAGMIRE_OVEN = "I shall cook things in thee!",
        QUAGMIRE_OVEN_ITEM = "'Tis an instrument to vanquish food.",
        QUAGMIRE_CASSEROLEDISH = "It will hold much meat.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "A container for food.",
        QUAGMIRE_PLATE_SILVER = "'Tis a fancy plate.",
        QUAGMIRE_BOWL_SILVER = "'Tis a fancy bowl.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "'Tis full of goods.", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "'Tis full of goods.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "'Tis a Valkyrie.",
        QUAGMIRE_PARK_ANGEL2 = "'Tis a Valkyrie.",
        QUAGMIRE_PARK_URN = "Remnants of a Viking funeral.",
        QUAGMIRE_PARK_OBELISK = "'Tis a runestone.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Valhalla's gate is opened to me.",
            LOCKED = "Thou shalt not keep me out!",
        },
        QUAGMIRE_PARKSPIKE = "'Tis a fencing spear.",
        QUAGMIRE_CRABTRAP = "It doth trap sea-meat.",
        QUAGMIRE_TRADER_MERM = "Prepare to barter!",
        QUAGMIRE_TRADER_MERM2 = "'Tis a jaunty-hatted beast.",

        QUAGMIRE_GOATMUM = "A woman of good taste, like mineself!",
        QUAGMIRE_GOATKID = "Ah, the sweet innocence of youth.",
        QUAGMIRE_PIGEON =
        {
            DEAD = "Tis slain.",
            GENERIC = "Be you tasty?",
            SLEEPING = "It slumbers soundly.",
        },
        QUAGMIRE_LAMP_POST = "Tis a magic light, surely.",

        QUAGMIRE_BEEFALO = "Its days of war are past.",
        QUAGMIRE_SLAUGHTERTOOL = "'Tis a weapon of beastly slaughter!",

        QUAGMIRE_SAPLING = "'Twill never again grow to its former glory.",
        QUAGMIRE_BERRYBUSH = "'Tis barren.",

        QUAGMIRE_ALTAR_STATUE2 = "'Tis dedicated to its god.",
        QUAGMIRE_ALTAR_QUEEN = "A colossal queen.",
        QUAGMIRE_ALTAR_BOLLARD = "'Tis a post. Unworthy of mine attention.",
        QUAGMIRE_ALTAR_IVY = "It climbeth the walls.",

        QUAGMIRE_LAMP_SHORT = "'Tis a magic light of short stature.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "Reinforcements hath arrived! To battle!",
        	OFF = "It has no fighting spirit.",
        	BURNING = "Tis engulfed in flame!",
        	BURNT = "Twas devoured by Hel's fire!",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "It can't get enough of me!",
        	OFF = "It has no fighting spirit.",
        	BURNING = "Tis engulfed in flame!",
        	BURNT = "Twas devoured by Hel's fire!",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "The tinkerer hath many tricks.",
        	LOWPOWER = "T'will not hold out much longer!",
        	OFF = "It hath lost its incredible power!",
        	BURNING = "Tis engulfed in flame!",
        	BURNT = "Twas devoured by Hel's fire!",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "Tis fueled by glorious magic.",
        	LOWPOWER = "T'will not hold out much longer!",
        	OFF = "It hath lost its incredible power!",
        	BURNING = "Tis engulfed in flame!",
        	BURNT = "Twas devoured by Hel's fire!",
        },

        --Wormwood
        COMPOSTWRAP = "I question my ally's tastes.",
        ARMOR_BRAMBLE = "My ally is surely a strong warrior.",
        TRAP_BRAMBLE = "A most clever trap for one's foes.",

        BOATFRAGMENT03 = "The ship hath met a valiant end.",
        BOATFRAGMENT04 = "The ship hath met a valiant end.",
        BOATFRAGMENT05 = "The ship hath met a valiant end.",
		BOAT_LEAK = "My vessel hath been wounded!",
        MAST = "T'will harness Njord's mighty breath.",
        SEASTACK = "I shall not dash mine ship upon thee!",
        FISHINGNET = "I shall feed all my allies for a day!", --unimplemented
        ANTCHOVIES = "I wrested them from the sea.", --unimplemented
        STEERINGWHEEL = "Njord guide our journey.",
        ANCHOR = "Tis light as a feather thanks to my Viking's strength!",
        BOATPATCH = "If a Viking cares for her vessel, t'will do the same in return.",
        DRIFTWOOD_TREE =
        {
            BURNING = "Tis consumed by flame!",
            BURNT = "Consumed by Hel's flames.",
            CHOPPED = "Thank you for your bounty, tree.",
            GENERIC = "A rare beauty to be sure, but tis no Yggdrasil.",
        },

        DRIFTWOOD_LOG = "'Tis wood, forged in the sea's depths!",

        MOON_TREE =
        {
            BURNING = "Tis consumed by flame!",
            BURNT = "This tree, twas burnt to the ground.",
            CHOPPED = "Chopped by the warrior of the woods!",
            GENERIC = "Tis lovely as Yggdrasil's picture in my mind.",
        },
		MOON_TREE_BLOSSOM = "Tis most beauteous in the moonlight.",

        MOONBUTTERFLY =
        {
        	GENERIC = "Tis light as a feather on the breeze!",
        	HELD = "It is my ward, now.",
        },
		MOONBUTTERFLYWINGS = "Fare thee well, little moth.",
        MOONBUTTERFLY_SAPLING = "Tis but a small tree.",
        ROCK_AVOCADO_FRUIT = "Tis either a rock or vegetable. Neither are food.",
        ROCK_AVOCADO_FRUIT_RIPE = "Yuck.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "I shall not eat that.",
        ROCK_AVOCADO_FRUIT_SPROUT = "The rock veggie is sprouting.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "Tis barren as the rainless desert.",
			WITHERED = "It had not the strength to withstand this heat.",
			GENERIC = "Hark, be wary! Tis fruit I see.",
			PICKED = "It hath been stripped of its bounty.",
			DISEASED = "The plague hath overwhelmed it completely!", --unimplemented
            DISEASING = "A plague festers within it!", --unimplemented
			BURNING = "Tis consumed by flame!",
		},
        DEAD_SEA_BONES = "Njord's depths hold many secrets.",
        HOTSPRING =
        {
        	GENERIC = "Perhaps a fire giant slumbers beneath!",
        	BOMBED = "'Tis imbued with the power of the moon!",
        	GLASS = "Oh no! The giant is trapped!",
			EMPTY = "Odd, I do not see the fire giant...",
        },
        MOONGLASS = "Tis a most divine substance.",
        MOONGLASS_CHARGED = "Tis lit by a strange power.",
        MOONGLASS_ROCK = "Mani sent it down himself.",
        BATHBOMB = "I shall toss thee in the earth's cauldron!",
        TRAP_STARFISH =
        {
            GENERIC = "My warrior's instinct sounds - but why!",
            CLOSED = "I shalln't be vanquished that easily.",
        },
        DUG_TRAP_STARFISH = "A most wicked trap I could set for my foes.",
        SPIDER_MOON =
        {
        	GENERIC = "One of Hel's beasts, surely!",
        	SLEEPING = "It slumbers.",
        	DEAD = "It has breathed its last.",
        },
        MOONSPIDERDEN = "I sense battle on the horizon.",
		FRUITDRAGON =
		{
			GENERIC = "Meat impostor!",
			RIPE = "I have no need for your fake meat.",
			SLEEPING = "Grabbest thy shut eye!",
		},
        PUFFIN =
        {
            GENERIC = "Cutest flying meat.",
            HELD = "Thou art safe with me, sea meat.",
            SLEEPING = "Grabbest thy shut eye!",
        },

		MOONGLASSAXE = "Spirits of the woods stand no chance against me.",
		GLASSCUTTER = "T'will win any battle, surely!",

        ICEBERG =
        {
            GENERIC = "A trap left by the dastardly ice giants, no doubt.", --unimplemented
            MELTED = "Twas no match for this great heat.", --unimplemented
        },
        ICEBERG_MELTED = "Twas no match for this great heat.", --unimplemented

        MINIFLARE = "Never split thy party!",

		MOON_FISSURE =
		{
			GENERIC = "An eternal light shines from within!",
			NOLIGHT = "But a crack in the earth.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "You shall soon be complete once more.",
            GENERIC = "Tis a direct line to Mani himself!",
        },

        MOON_ALTAR_IDOL = "Make thy will known to me, idol!",
        MOON_ALTAR_GLASS = "What doth thou want, fair jewel?",
        MOON_ALTAR_SEED = "The gods commune to me through thee.",

        MOON_ALTAR_ROCK_IDOL = "The gods call me to it, I shall not resist.",
        MOON_ALTAR_ROCK_GLASS = "The gods call me to it, I shall not resist.",
        MOON_ALTAR_ROCK_SEED = "The gods call me to it, I shall not resist.",

        MOON_ALTAR_CROWN = "I wonder how that creature got his claws on this?",
        MOON_ALTAR_COSMIC = "It is grateful, but my work is not yet done.",

        MOON_ALTAR_ASTRAL = "I hear the whispers of Mani.",
        MOON_ALTAR_ICON = "It calls out to me, I must take heed.",
        MOON_ALTAR_WARD = "It has chosen me to safeguard its passage home.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "A seafaring Viking is keen of mind and sharp of wit.",
            BURNT = "Tis no more.",
        },
        BOAT_ITEM = "Ship building is in my bones!",
        STEERINGWHEEL_ITEM = "A vital piece of a glorious vessel.",
        ANCHOR_ITEM = "I will craft the finest ship in the land!",
        MAST_ITEM = "To harness the winds upon mine vessel!",
        MUTATEDHOUND =
        {
        	DEAD = "May you find rest.",
        	GENERIC = "What infernal creature doth mine eyes see!",
        	SLEEPING = "The beast slumbers soundly.",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Rest well, wicked spirit.",
			GENERIC = "Hel's influence has corrupted thee, no doubt!",
			SLEEPING = "It slumbers soundly.",
		},
        CARRAT =
        {
        	DEAD = "It has breathed its last.",
        	GENERIC = "Vegetables are not to be trusted!",
        	HELD = "I have you now, wicked vegetable.",
        	SLEEPING = "A deceptive vegetable with no honor.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Ah! The sea hath sent its foul veggies!",
            PICKED = "It is defeated.",
        },
		BULLKELP_ROOT = "I'll turn the sea's dark forces against it!",
        KELPHAT = "I'd never trade mine helm for this.",
		KELP = "Ridiculous sea vegetable.",
		KELP_COOKED = "Tis even worse than before.",
		KELP_DRIED = "I despise it.",

		GESTALT = "God of the moon, shine thy smile upon me!",
        GESTALT_GUARD = "Aha, there are warriors among you!",

		COOKIECUTTER = "It seeks to make a meal of my vessel!",
		COOKIECUTTERSHELL = "Twas a spiky foe.",
		COOKIECUTTERHAT = "Tis a helm fit for a warrior of the deep.",
		SALTSTACK =
		{
			GENERIC = "Tis the form of a sea nymph!",
			MINED_OUT = "Naught but a stump!",
			GROWING = "Formed as if by Odin's hand!",
		},
		SALTROCK = "It hath a strange shape to it.",
		SALTBOX = "A fine place to store meats!",

		TACKLESTATION = "I shall create a fishing weapon like no other!",
		TACKLESKETCH = "This scroll bears hidden secrets of fishing!",

        MALBATROSS = "I will slay the four-winged beast!",
        MALBATROSS_FEATHER = "The plume of a fallen foe.",
        MALBATROSS_BEAK = "A trophy from my victory!",
        MAST_MALBATROSS_ITEM = "A winged sail for my vessel.",
        MAST_MALBATROSS = "Let us be off, with the speed of the Valkyrie!",
		MALBATROSS_FEATHERED_WEAVE = "A bolt of thine finest bird-cloth!",

        GNARWAIL =
        {
            GENERIC = "Draw your weapon and fight me, beastie!",
            BROKENHORN = "The beast's been disarmed!",
            FOLLOWER = "Tis a fair and noble beast!",
            BROKENHORN_FOLLOWER = "You are still a great warrior!",
        },
        GNARWAIL_HORN = "A fine horn, indeed!",

        WALKINGPLANK = "I shall never abandon my vessel!",
        OAR = "The Norseman's way to sail!",
		OAR_DRIFTWOOD = "Back to the sea!",

		OCEANFISHINGROD = "Tremble before me, creatures of the deep!",
		OCEANFISHINGBOBBER_NONE = "The line hath need of a float.",
        OCEANFISHINGBOBBER_BALL = "My keen hunter's eyes can detect the smallest nibble!",
        OCEANFISHINGBOBBER_OVAL = "My keen hunter's eyes can detect the smallest nibble!",
		OCEANFISHINGBOBBER_CROW = "Fly straight and true!",
		OCEANFISHINGBOBBER_ROBIN = "Fly straight and true!",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "Fly straight and true!",
		OCEANFISHINGBOBBER_CANARY = "Fly straight and true!",
		OCEANFISHINGBOBBER_GOOSE = "Njoror, guide my line!",
		OCEANFISHINGBOBBER_MALBATROSS = "Njoror, guide my line!",

		OCEANFISHINGLURE_SPINNER_RED = "A cunning ruse, indeed.",
		OCEANFISHINGLURE_SPINNER_GREEN = "A cunning ruse, indeed.",
		OCEANFISHINGLURE_SPINNER_BLUE = "A cunning ruse, indeed.",
		OCEANFISHINGLURE_SPOON_RED = "This should attract their attention!",
		OCEANFISHINGLURE_SPOON_GREEN = "This should attract their attention!",
		OCEANFISHINGLURE_SPOON_BLUE = "This should attract their attention!",
		OCEANFISHINGLURE_HERMIT_RAIN = "The old crone has enchanted it to work best in the rain.",
		OCEANFISHINGLURE_HERMIT_SNOW = "The old crone has enchanted it to work best in the snow.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "It doth feel a bit like cheating...",
		OCEANFISHINGLURE_HERMIT_HEAVY = "Only the greatest of fish will dare take a bite!",

		OCEANFISH_SMALL_1 = "Tis barely a morsel!",
		OCEANFISH_SMALL_2 = "There's barely any meat on these fishbones!",
		OCEANFISH_SMALL_3 = "Tis only a wee beastie.",
		OCEANFISH_SMALL_4 = "This amount of meat will hardly satisfy a Viking!",
		OCEANFISH_SMALL_5 = "Tis naught but a small snack.",
		OCEANFISH_SMALL_6 = "It is suspiciously leafy.",
		OCEANFISH_SMALL_7 = "Are ye fish or flower?",
		OCEANFISH_SMALL_8 = "By Sól! It wields the power of the sun!",
        OCEANFISH_SMALL_9 = "You dare spit at a Viking warrior?",

		OCEANFISH_MEDIUM_1 = "Meat is meat.",
		OCEANFISH_MEDIUM_2 = "You will make a fine meal!",
		OCEANFISH_MEDIUM_3 = "The beastie put up an admirable fight.",
		OCEANFISH_MEDIUM_4 = "There's an air of ill luck around this one...",
		OCEANFISH_MEDIUM_5 = "This looks suspiciously veggie-like.",
		OCEANFISH_MEDIUM_6 = "Your bad luck is my good fortune, beastie.",
		OCEANFISH_MEDIUM_7 = "Your bad luck is my good fortune, beastie.",
		OCEANFISH_MEDIUM_8 = "It must hail from the icy waters of Niflheim.",
        OCEANFISH_MEDIUM_9 = "Are ye fish or fruit? My eyes hath been decieved before!",

		PONDFISH = "Pond meat!",
		PONDEEL = "Delicious slimy snake fish.",

        FISHMEAT = "This sea meat will serve me well.",
        FISHMEAT_COOKED = "Joy!",
        FISHMEAT_SMALL = "This sea meat will serve me well.",
        FISHMEAT_SMALL_COOKED = "This meat will swim in my belly!",
		SPOILED_FISH = "You smell of your failure.",

		FISH_BOX = "Meat is best when it's fresh!",
        POCKET_SCALE = "How did I fare with my catch?",

		TACKLECONTAINER = "A wise hunter treats their tools with care.",
		SUPERTACKLECONTAINER = "A bounty of space for my bait!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "I will stand victorious!",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nA most glorious catch indeed!",
			BURNING = "By the gods, that fishbowl's ablaze!",
			BURNT = "Tis naught but cinders.",
			OWNER = "Weight: {weight}\nCaught by: {owner}\nTake heed of my fishing prowess!",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nT'was nothing for a skilled hunter!",
		},

		OCEANFISHABLEFLOTSAM = "Tis naught but a clump of mud and grass!",

		CALIFORNIAROLL = "That's just a morsel of fish food.",
		SEAFOODGUMBO = "A meal fit for a Viking queen.",
		SURFNTURF = "Nothing goes better with meat than more meat!",

        WOBSTER_SHELLER = "Have at thee, morsel!",
        WOBSTER_DEN = "The lair of the pinchy beasts.",
        WOBSTER_SHELLER_DEAD = "Sleep in Valhalla, armored one.",
        WOBSTER_SHELLER_DEAD_COOKED = "Your armor hides tasty meat.",

        LOBSTERBISQUE = "That's more like it.",
        LOBSTERDINNER = "I triumphed over my wobster foe.",

        WOBSTER_MOONGLASS = "The little beasties have acquired new armor!",
        MOONGLASS_WOBSTER_DEN = "That must be their fortress.",

		TRIDENT = "I shall lay waste to my enemies with the weapon of Poseidon!",

		WINCH =
		{
			GENERIC = "The ocean is mine to pillage.",
			RETRIEVING_ITEM = "And to the victor, the spoils!",
			HOLDING_ITEM = "Behold, my prize!",
		},

        HERMITHOUSE = {
            GENERIC = "The sea witch seems to be pleased with it.",
            BUILTUP = "The old crone resides here?",
        },

        SHELL_CLUSTER = "Tis naught but a clump of shells.",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "{note}? I expected it to sound more like a war bugle.",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "It sings a siren's song. In {note}.",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "{note}... an impressively high register for a wee sea beast.",
        },

        CHUM = "A banquet for the sea beasties!",

        SUNKENCHEST =
        {
            GENERIC = "Perhaps it was a gift from Venus?",
            LOCKED = "Fie! Locked tight!",
        },

        HERMIT_BUNDLE = "Our labor hath been rewarded!",
        HERMIT_BUNDLE_SHELLS = "A fresh bounty of shells to adorn our battlements.",

        RESKIN_TOOL = "In the blink of an eye, what once was is no more!",
        MOON_FISSURE_PLUGGED = "The old crone has been waging war against the moon's apparitions.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Hail, beastie!",
            "Hail, beastie!",
        },
        WOBYSMALL =
        {
            "Wouldst thou like a skritch behind thine ears?",
            "Wouldst thou like a skritch behind thine ears?",
        },
		WALTERHAT = "The helm of the \"Pinetree Pioneer\" clan.",
		SLINGSHOT = "I prefer weapons at close range.",
		SLINGSHOTAMMO_ROCK = "What fun is a battle without hand to hand combat?",
		SLINGSHOTAMMO_MARBLE = "What fun is a battle without hand to hand combat?",
		SLINGSHOTAMMO_THULECITE = "What fun is a battle without hand to hand combat?",
        SLINGSHOTAMMO_GOLD = "What fun is a battle without hand to hand combat?",
        SLINGSHOTAMMO_SLOW = "What fun is a battle without hand to hand combat?",
        SLINGSHOTAMMO_FREEZE = "What fun is a battle without hand to hand combat?",
		SLINGSHOTAMMO_POOP = "I could do without the stench...",
        PORTABLETENT = "'Tis a finely made shelter indeed!",
        PORTABLETENT_ITEM = "My talent lies in battle, not in building.",

        -- Wigfrid
        BATTLESONG_DURABILITY = "The notes doth imbue my weapons with their sharpness!",
        BATTLESONG_HEALTHGAIN = "I will serenade my enemies on their journey to Valhalla!",
        BATTLESONG_SANITYGAIN = "A stirring battle song to clear the head.",
        BATTLESONG_SANITYAURA = "A rousing anthem to inspire bravery in battle!",
        BATTLESONG_FIRERESISTANCE = "A fiery performance shalt shield me from the foul burn of my enemy's gaze.",
        BATTLESONG_INSTANT_TAUNT = "A well aimed insult can turn the tide in battle.",
        BATTLESONG_INSTANT_PANIC = "My very words art enough to make my foes tremble!",

        -- Webber
        MUTATOR_WARRIOR = "They look like the little beasts, but lack the ferocity.",
        MUTATOR_DROPPER = "They look like the little beasts, but lack the ferocity.",
        MUTATOR_HIDER = "They look like the little beasts, but lack the ferocity.",
        MUTATOR_SPITTER = "They look like the little beasts, but lack the ferocity.",
        MUTATOR_MOON = "They look like the little beasts, but lack the ferocity.",
        MUTATOR_HEALER = "They look like the little beasts, but lack the ferocity.",
        SPIDER_WHISTLE = "'Tis a spider war horn.",
        SPIDERDEN_BEDAZZLER = "The spiderchild has taken up the arts, has he?",
        SPIDER_HEALER = "Be you the healer of your clan?",
        SPIDER_REPELLENT = "The spiderchild uses it to manage his horde.",
        SPIDER_HEALER_ITEM = "It is only fit for the small toothy beasts.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "'Tis a powerful elixir!",
		GHOSTLYELIXIR_FASTREGEN = "'Tis a powerful elixir!",
		GHOSTLYELIXIR_SHIELD = "'Tis a powerful elixir!",
		GHOSTLYELIXIR_ATTACK = "'Tis a powerful elixir!",
		GHOSTLYELIXIR_SPEED = "'Tis a powerful elixir!",
		GHOSTLYELIXIR_RETALIATION = "'Tis a powerful elixir!",
		SISTURN =
		{
			GENERIC = "A small langhús for the ghostly warrior to regain her strength.",
			SOME_FLOWERS = "Flowers doth please this spirit.",
			LOTS_OF_FLOWERS = "'Tis a fine monument indeed.",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "Cooking, a noble profession.",
            DONE = "Is there meat to be consumed?",

			COOKING_LONG = "My belly rumbles... make haste, cookpot!",
			COOKING_SHORT = "This will be done swiftly!",
			EMPTY = "Not even a morsel left inside...",
        },

        PORTABLEBLENDER_ITEM = "It does battle with food.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "A formidable weapon against bad meals.",
            DONE = "Its task has come to an end.",
        },
        SPICEPACK = "I'll use this to carry delicious meats!",
        SPICE_GARLIC = "Its pungent smell offends mine nostrils.",
        SPICE_SUGAR = "The sweet juice of an enemy.",
        SPICE_CHILI = "Full of a fiery extract.",
        SPICE_SALT = "It has the briny taste of the sea.",
        MONSTERTARTARE = "Still quivering.",
        FRESHFRUITCREPES = "So light and airy!",
        FROGFISHBOWL = "My ally is a god among men.",
        POTATOTORNADO = "Blech.",
        DRAGONCHILISALAD = "Yeuch! I was promised a feast!",
        GLOWBERRYMOUSSE = "A repulsive vegetable concoction.",
        VOLTGOATJELLY = "Well, it is technically made from a beast.",
        NIGHTMAREPIE = "I am wary of this pie.",
        BONESOUP = "A feast fit for the gods!",
        MASHEDPOTATOES = "I'll not be fooled by your new mash-ed form, vegetable!",
        POTATOSOUFFLE = "What treachery is this?",
        MOQUECA = "A treat for mine senses!",
        GAZPACHO = "My mind doth question Warly's allegiances.",
        ASPARAGUSSOUP = "I shall not consume it!",
        VEGSTINGER = "Its spiciness intrigues me not!",
        BANANAPOP = "I've somehow found a way to make it even LESS appealing!",
        CEVICHE = "Fancy for my taste, but it'll do.",
        SALSA = "A disappointing mush.",
        PEPPERPOPPER = "Back, vile vegetables!",

        TURNIP = "I shall not consume it!",
        TURNIP_COOKED = "Ach! I shall not eat thee!",
        TURNIP_SEEDS = "'Tis a handful of seeds, for not-meat.",

        GARLIC = "Foul ingredient!",
        GARLIC_COOKED = "The stench!",
        GARLIC_SEEDS = "'Tis a handful of seeds, for not-meat.",

        ONION = "I dare thee, provoke tears from mine eyes!",
        ONION_COOKED = "It has been vanquished with fire.",
        ONION_SEEDS = "'Tis a handful of seeds, for not-meat.",

        POTATO = "Vileness emerged from the earth.",
        POTATO_COOKED = "It is of no use to me.",
        POTATO_SEEDS = "'Tis a handful of seeds, for not-meat.",

        TOMATO = "It will not pass my lips!",
        TOMATO_COOKED = "It boasts reddest guts, yet 'tis not meat!",
        TOMATO_SEEDS = "'Tis a handful of seeds, for not-meat.",

        ASPARAGUS = "Vegetable! I will not consume you!",
        ASPARAGUS_COOKED = "Fire does not make it more palatable.",
        ASPARAGUS_SEEDS = "These serve me no purpose!",

        PEPPER = "Its mere presence offends me.",
        PEPPER_COOKED = "It is not worthy of my consumption.",
        PEPPER_SEEDS = "Smaller versions of vegetables still offend me.",

        WEREITEM_BEAVER = "Is this meant to summon your fylgja?",
        WEREITEM_GOOSE = "It's... er... very fearsome!",
        WEREITEM_MOOSE = "It represents a warrior's spirit!",

        MERMHAT = "'Tis a deceitful mask.",
        MERMTHRONE =
        {
            GENERIC = "Have you chosen a chieftain?",
            BURNT = "The throne hath been set ablaze!",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "The little beast toils away.",
            BURNT = "'Tis a sad day for the fish beasts.",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "A home fit for a fish beast.",
            BURNT = "'Tis the way of things.",
        },

        MERMWATCHTOWER_REGULAR = "'Tis a fine fortress for a fish beast.",
        MERMWATCHTOWER_NOKING = "They are lost without their chieftain.",
        MERMKING = "Lord of the fish beasts!",
        MERMGUARD = "A formidable warrior, to be sure.",
        MERM_PRINCE = "Thou art certain he is fit to be leader?",

        SQUID = "It lights my voyage through murky waters.",

		GHOSTFLOWER = "'Tis all that remains.",
        SMALLGHOST = "Such a wee specter!",

        CRABKING =
        {
            GENERIC = "Have at thee, cursed crustacean!",
            INERT = "A barren, sandy fortress.",
        },
		CRABKING_CLAW = "Prepare thyself to be de-clawed!",

		MESSAGEBOTTLE = "What's this? Battle plans?",
		MESSAGEBOTTLEEMPTY = "This vessel might have some use.",

        MEATRACK_HERMIT =
        {
            DONE = "The moisture has been vanquished!",
            DRYING = "It's being prepared just the way I like it.",
            DRYINGINRAIN = "All this rain isn't helping.",
            GENERIC = "I'd be cantankerous too if I were left without meat!",
            BURNT = "Such a shame.",
            DONE_NOTMEAT = "'Tis as dry as an empty well!",
            DRYING_NOTMEAT = "It's drying out nicely.",
            DRYINGINRAIN_NOTMEAT = "All this rain isn't helping.",
        },
        BEEBOX_HERMIT =
        {
            READY = "It's a honey treasure trove!",
            FULLHONEY = "It's a honey treasure trove!",
            GENERIC = "The old crone would take my head if I dared steal a drop of honey.",
            NOHONEY = "Where's the honey?",
            SOMEHONEY = "Pithy honey. More patience is needed.",
            BURNT = "The hive is silent.",
        },

        HERMITCRAB = "Be ye a sea witch? Or just an old crone?",

        HERMIT_PEARL = "I shall protect it with my life!",
        HERMIT_CRACKED_PEARL = "The battle is won, but at what cost?",

        -- DSEAS
        WATERPLANT = "Have we entered the realm of giants?",
        WATERPLANT_BOMB = "Have at thee, plant!",
        WATERPLANT_BABY = "Grow fast and strong, young one.",
        WATERPLANT_PLANTER = "Fear not, I shall return you to the sea in time.",

        SHARK = "Do you come to challenge me, sea beast?",

        MASTUPGRADE_LAMP_ITEM = "We shall keep the flame burning bright!",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "You may do your worst, oh mighty Thor!",

        WATERPUMP = "We hath safeguarded our vessel against a fiery end.",

        BARNACLE = "'Tis a paltry bit of sea meat.",
        BARNACLE_COOKED = "You will find a new home in my belly.",

        BARNACLEPITA = "Why hide the meat within this bready pocket?",
        BARNACLESUSHI = "I hunger for more!",
        BARNACLINGUINE = "It slays my hunger soundly!",
        BARNACLESTUFFEDFISHHEAD = "For those who are strong of will, and strong of stomach.",

        LEAFLOAF = "It has a suspiciously non-meat smell to it.",
        LEAFYMEATBURGER = "This will suffice until I find real meat.",
        LEAFYMEATSOUFFLE = "A nightmarish vision... but food nonetheless.",
        MEATYSALAD = "My instincts scream against this.",

        -- GROTTO

		MOLEBAT = "Have at thee, rodent!",
        MOLEBATHILL = "Your mucousy defenses will not deter me, morsel!",

        BATNOSE = "A trophy from the hunt.",
        BATNOSE_COOKED = "If it's meat, I shall eat it!",
        BATNOSEHAT = "A warrior would never deign to wear such a thing!",

        MUSHGNOME = "Foul vegetable, you will taste my spear!",

        SPORE_MOON = "It carries an explosive power...",

        MOON_CAP = "Despicable non-meat!",
        MOON_CAP_COOKED = "Such a thing will never pass my lips!",

        MUSHTREE_MOON = "Strange magic indeed.",

        LIGHTFLIER = "Light the way, noble insect.",

        GROTTO_POOL_BIG = "The pools hath been enchanted.",
        GROTTO_POOL_SMALL = "The pools hath been enchanted.",

        DUSTMOTH = "This creature has no fight in it.",

        DUSTMOTHDEN = "Sorry beasties, but your home is ripe for the pillaging!",

        ARCHIVE_LOCKBOX = "Will you whisper truths to me, as Mímir did to Odin?",
        ARCHIVE_CENTIPEDE = "I fear no beast, mortal or metal!",
        ARCHIVE_CENTIPEDE_HUSK = "This sentry seems to be asleep at its post.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "Might as well do something whilst I wait.",
            COOKING_SHORT = "Shouldn't be long now!",
            DONE = "What have we here?",
            EMPTY = "There is no meat inside, so I care not.",
            BURNT = "The fire reigned supreme.",
        },

        ARCHIVE_MOON_STATUE = "These people once praised Mani.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "These runes are foreign to me.",
            LINE_2 = "Perhaps they speak of ancient battles.",
            LINE_3 = "These runes are foreign to me.",
            LINE_4 = "Perhaps they speak of ancient battles.",
            LINE_5 = "These runes are foreign to me.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "It calls down a sign from Mani himself!",
            IDLE = "Its quest is complete.",
        },

        ARCHIVE_RESONATOR_ITEM = "'Tis the machine from my vision.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "This place has been long forgotten.",
          GENERIC =  "Reveal thine secrets to me, O strange machine!",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "It is at rest.",
            GENERIC = "It guards these halls.",
        },

        ARCHIVE_SECURITY_PULSE = "Where are you going, O will-o'-wisp?",

        ARCHIVE_SWITCH = {
            VALID = "This one has been given an offering.",
            GEMS = "It requires an offering.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Another gate betwixt worlds?",
            GENERIC = "If it is a gate, it hath been firmly shut.",
        },

        WALL_STONE_2 = "My enemies will dash themselves on these rocks.",
        WALL_RUINS_2 = "Nigh impenetrable.",

        REFINED_DUST = "The dust hath been forged into a solid block.",
        DUSTMERINGUE = "This food is not fit for a warrior, it's fit for the floor!",

        SHROOMCAKE = "A Viking would never stoop to eat such an unworthy thing.",

        NIGHTMAREGROWTH = "The very ground hath split and released nightmares upon us!",

        TURFCRAFTINGSTATION = "The very ground shall heed my will!",

        MOON_ALTAR_LINK = "What have we summoned forth?",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "A barrel of stink.",
            WET = "Soggy muck.",
            DRY = "It's so dry it's nearly dust.",
            BALANCED = "That shall do.",
            BURNT = "Reduced to ash.",
        },
        COMPOST = "'Tis naught but food for worms.",
        SOIL_AMENDER =
		{
			GENERIC = "A weak brew for the non-meats.",
			STALE = "It's beginning to take on a powerful odor.",
			SPOILED = "By the gods, the stench!",
		},

		SOIL_AMENDER_FERMENTED = "Perhaps the non-meats are stronger that I thought, to consume such a thing...",

        WATERINGCAN =
        {
            GENERIC = "Watering the garden is not a task befitting a warrior.",
            EMPTY = "The plants expect me to fetch water for them as well?",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "Why must we coddle the plants thus?",
            EMPTY = "There is no water to be found within.",
        },

		FARM_PLOW = "I claim this soil for the garden!",
		FARM_PLOW_ITEM = "A ferocious weapon against untamed soil.",
		FARM_HOE = "To bury those useless seeds deep in the ground.",
		GOLDEN_FARM_HOE = "A tool far too magnificent for those worthless seeds.",
		NUTRIENTSGOGGLESHAT = "I care not for learning about that which sprouts from the dirt.",
		PLANTREGISTRYHAT = "This is no helm for a warrior!",

        FARM_SOIL_DEBRIS = "You dare tresspass upon my garden?",

		FIRENETTLES = "They fight like cowards.",
		FORGETMELOTS = "I do not trust them.",
		SWEETTEA = "A warrior does not partake in \"tea time\".",
		TILLWEED = "Remove yourself from my sight, cowardly weed!",
		TILLWEEDSALVE = "Hmm, it doth appear that foul weed has a use after all.",
        WEED_IVY = "This weed is armed with thorns.",
        IVY_SNARE = "Ha! At least this plant hath some spirit!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Vile veggies! Bring out the best among you to be judged!",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nI care not.",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\n'Tis vile, but robust.",
            HAS_ITEM_LIGHT = "Ha! The machine does not even deem it worthy enough to reveal its weight!",
			BURNING = "It hath been set ablaze!",
			BURNT = "T'was of little use anyway.",
        },

        CARROT_OVERSIZED = "If only you were meat...",
        CORN_OVERSIZED = "Sadly, it is not meat.",
        PUMPKIN_OVERSIZED = "Quite formidable, for a vegetable.",
        EGGPLANT_OVERSIZED = "I've no use for vegetables, big or small.",
        DURIAN_OVERSIZED = "It gives off a powerful stink.",
        POMEGRANATE_OVERSIZED = "Its great size impresses me naught.",
        DRAGONFRUIT_OVERSIZED = "Alas, you are fruit, not meat.",
        WATERMELON_OVERSIZED = "Was this grown by a jotunn?",
        TOMATO_OVERSIZED = "It's only good for throwing.",
        POTATO_OVERSIZED = "An embarrassment of non-meat.",
        ASPARAGUS_OVERSIZED = "This spear will never match up to mine.",
        ONION_OVERSIZED = "You will draw no tears from my eyes on this day!",
        GARLIC_OVERSIZED = "Its enlarged form offends my eyes.",
        PEPPER_OVERSIZED = "You are the champion of the peppers, then?",

        VEGGIE_OVERSIZED_ROTTEN = "Good! Let it rot!",

		FARM_PLANT =
		{
			GENERIC = "A plant.",
			SEED = "I've no use for you.",
			GROWING = "I care not.",
			FULL = "Begone, non-meat!",
			ROTTEN = "It is even more foul than usual.",
			FULL_OVERSIZED = "It's about time I cut you back down to size.",
			ROTTEN_OVERSIZED = "Good! Let it rot!",
			FULL_WEED = "Weed, vegetable or fruit, all are the same to me.",

			BURNING = "Good riddance.",
		},

        FRUITFLY = "Intruder! Taste my blade!",
        LORDFRUITFLY = "Thou art no lord!",
        FRIENDLYFRUITFLY = "It seems this one is not an enemy.",
        FRUITFLYFRUIT = "Now I am chieftain of the wee winged garden beasts!",

        SEEDPOUCH = "For carrying worthless seeds.",

		-- Crow Carnival
		CARNIVAL_HOST = "He must be the leader of the ravens.",
		CARNIVAL_CROWKID = "Noble ravens! How fare thee?",
		CARNIVAL_GAMETOKEN = "A gleaming token of friendship.",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "I am rewarded for completing the test of skill.",
			GENERIC_SMALLSTACK = "The ravens recognize my unrivaled skill.",
			GENERIC_LARGESTACK = "A great pile indeed!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "The home of the wood-hewn birds.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "It requires a token to prove my worthiness.",
			PLAYING = "A test of reflexes!",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "It will be built with utmost speed.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "A meal fit for wooden birds.",

		CARNIVALGAME_MEMORY_KIT = "It will be built with utmost speed.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "It requires a token to prove my worthiness.",
			PLAYING = "A test of one's mental prowess!",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "The home of the wood-hewn eggs.",
			PLAYING = "Aha! It must be this one!",
		},

		CARNIVALGAME_HERDING_KIT = "It will be built with utmost speed.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "It requires a token to prove my worthiness.",
			PLAYING = "A test of speed and stamina!",
		},
		CARNIVALGAME_HERDING_CHICK = "Try to flee all you want, you will not escape me!",

		CARNIVAL_PRIZEBOOTH_KIT = "I must construct it before my efforts can be rewarded.",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "To the victor go the spoils!",
		},

		CARNIVALCANNON_KIT = "It will be built with utmost speed.",
		CARNIVALCANNON =
		{
			GENERIC = "Be this a weapon of sorts?",
			COOLDOWN = "'Tis sadly not a weapon, but I enjoy it nonetheless.",
		},

		CARNIVAL_PLAZA_KIT = "Perhaps it will grow as tall as Yggdrasil.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Methinks these grounds are in need of adornment.",
			LEVEL_2 = "Make haste! The great Tree demands offerings of decorations!",
			LEVEL_3 = "A glorious sight to behold.",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "It shall be done at once.",
		CARNIVALDECOR_EGGRIDE = "How cruel to be tormented by the sight of eggs I cannot eat!",

		CARNIVALDECOR_LAMP_KIT = "It shall be done at once.",
		CARNIVALDECOR_LAMP = "It hath a feeling of magic about it.",
		CARNIVALDECOR_PLANT_KIT = "It shall be done at once.",
		CARNIVALDECOR_PLANT = "What use is a tree of such small stature?",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "I shall treasure it always.",
			UNCOMMON = "A good luck charm from the ravens!",
			GENERIC = "A wooden idol to remind me of this day!",
		},
		CARNIVALDECOR_FIGURE_KIT = "A box of mystery.",

        CARNIVAL_BALL = "This may be useful for testing my companions' reflexes.", --unimplemented
		CARNIVAL_SEEDPACKET = "'Tis food for birds, not Vikings.",
		CARNIVALFOOD_CORNTEA = "Nay.",

        CARNIVAL_VEST_A = "Blood red, to strike fear into the hearts of our enemies!",
        CARNIVAL_VEST_B = "'Tis not unlike the garb of a forest nymph.",
        CARNIVAL_VEST_C = "'Tis a tree pelt.",

        -- YOTB
        YOTB_SEWINGMACHINE = "The competition will be fierce, thus my beast's outfits must be fiercer!",
        YOTB_SEWINGMACHINE_ITEM = "Quickly, the competition awaits!",
        YOTB_STAGE = "The lair of our judge.",
        YOTB_POST =  "Now to present my beast for all to see!",
        YOTB_STAGE_ITEM = "Where to set the battleground of competition...",
        YOTB_POST_ITEM =  "It shall be raised forthwith!",


        YOTB_PATTERN_FRAGMENT_1 = "'Tis but a fragment of a complete pattern.",
        YOTB_PATTERN_FRAGMENT_2 = "'Tis but a fragment of a complete pattern.",
        YOTB_PATTERN_FRAGMENT_3 = "'Tis but a fragment of a complete pattern.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "A stuffed effigy of a valiant steed!",
            YOTB = "Mayhaps the judge would like to look upon it.",
        },

        WAR_BLUEPRINT = "Garb befitting a warrior's steed!",
        DOLL_BLUEPRINT = "Who would wear this into battle?",
        FESTIVE_BLUEPRINT = "The bright colors could be useful for distracting enemies.",
        ROBOT_BLUEPRINT = "Armor of iron for my steed!",
        NATURE_BLUEPRINT = "Flowers won't protect you in battle!",
        FORMAL_BLUEPRINT = "My fearsome steed has no use for such a thing!",
        VICTORIAN_BLUEPRINT = "Odd looking armor for a beast...",
        ICE_BLUEPRINT = "My beast will not fear the cold.",
        BEAST_BLUEPRINT = "No luck is needed for one who's skilled in battle.",

        BEEF_BELL = "This bell commands loyalty from the woolen beasts.",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "A penthouse for wee beasties.",
            BURNT = "Not great as a hideaway now.",
			PLAYING_HIDEANDSEEK = "The wee beasties are out, let us find them!",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "We must bring them home quickly!",
		},

		KITCOONDEN_KIT = "Everything one needs to build a hideaway for tiny beasts.",

		TICOON = 
		{
			GENERIC = "A mighty beast worthy of his crown. He will lead us to victory!",
			ABANDONED = "Curses! We will commence this hunt without your assistance.",
			SUCCESS = "Glory to you, mighty beast!",
			LOST_TRACK = "We were not swift enough.",
			NEARBY = "Do you sense the presence of a wee beast around here?",
			TRACKING = "He's on the case!",
			TRACKING_NOT_MINE = "He's on another's case!",
			NOTHING_TO_TRACK = "Seems there's no beasties to be found.",
			TARGET_TOO_FAR_AWAY = "They must be too far for him to catch the scent.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "Let the festive crafting commence!",
            EMPTY = "Perhaps it would enjoy a feather?",
            BURNT = "It seems someone offered it a flame. I do not think it liked it.",
        },

		KITCOON_FOREST = "A wee beastie that's particularly excellent at hiding.",
		KITCOON_SAVANNA = "A wee beastie with the heart of a mighty beastie.",
		KITCOON_MARSH = "A wee beastie with a weapon equipped to its tail. Ferocious!",
		KITCOON_DECIDUOUS = "A wee beastie with a talent for mischief.",
		KITCOON_GRASS = "A fairly flammable looking wee beastie.",
		KITCOON_ROCKY = "A very serious wee beastie.",
		KITCOON_DESERT = "A wee beastie with not-so-wee ears.",
		KITCOON_MOON = "A wee beastie imbued with a third eye for finding more hiding spots.",
		KITCOON_YOT = "A wee beastie with an excellent costume.",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Mani hath sent forth his greatest warrior to challenge me!",
            DEAD = "Surely the battle is not over already?",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "It seems you are a worthy foe indeed...",
            DEAD = "Is that all you've got, Champion?",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "You think I'm trapped here with you? Ha! It is you who are trapped with me!",
        ALTERGUARDIAN_PHASE3 = "Come, let us finish this!",
        ALTERGUARDIAN_PHASE3TRAP = "Only a coward would strike a foe down while they sleep!",
        ALTERGUARDIAN_PHASE3DEADORB = "Beware, stranger! The beast may yet rise again!",
        ALTERGUARDIAN_PHASE3DEAD = "It seems I've bested it after all.",

        ALTERGUARDIANHAT = "A boon from Mani's defeated Champion.",
        ALTERGUARDIANHATSHARD = "Even a single shard holds a measure of Mani's power.",

        MOONSTORM_GLASS = {
            GENERIC = "The power hath faded from it.",
            INFUSED = "It hath been imbued with a strange power."
        },

        MOONSTORM_STATIC = "Tis a strange kind of power.",
        MOONSTORM_STATIC_ITEM = "A strange power rests inside.",
        MOONSTORM_SPARK = "It sends a curious tickle through my bones.",

        BIRD_MUTANT = "The beasts are changed by the storm!",
        BIRD_MUTANT_SPITTER = "You think you can challenge me, winged fiend?",

        WAGSTAFF_NPC = "Hail stranger! Are ye friend or foe?",
        ALTERGUARDIAN_CONTAINED = "It's ferrying this warrior's soul to the next realm.",

        WAGSTAFF_TOOL_1 = "Mayhaps this is what I seek.",
        WAGSTAFF_TOOL_2 = "The odd stranger requested a tool, mayhaps this is it.",
        WAGSTAFF_TOOL_3 = "Is this what the odd stranger seeks?",
        WAGSTAFF_TOOL_4 = "Mayhaps this is what the odd stranger lost.",
        WAGSTAFF_TOOL_5 = "How strange. Perhaps it belongs to that odd stranger.",

        MOONSTORM_GOGGLESHAT = "No mere storm can stop me!",

        MOON_DEVICE = {
            GENERIC = "Mere mortals were not meant to tamper so with the power of the gods...",
            CONSTRUCTION1 = "I know not its purpose. A tribute to Mani, perhaps?",
            CONSTRUCTION2 = "The more I build, the stranger it appears.",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "A Viking warrior can tell the time by the position of the sun.",
			RECHARGING = "'Tis merely biding its time.",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "A Viking warrior can tell the time by the position of the sun.",
			RECHARGING = "'Tis merely biding its time.",
		},

        POCKETWATCH_WARP = {
			GENERIC = "A Viking warrior can tell the time by the position of the sun.",
			RECHARGING = "'Tis merely biding its time.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "A Viking warrior can tell the time by the position of the sun.",
			RECHARGING = "'Tis merely biding its time.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "A Viking warrior can tell the time by the position of the sun.",
			RECHARGING = "'Tis merely biding its time.",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Aha! 'Tis not a time-teller, but a weapon in disguise!",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Be this the work of dark magic?",
        POCKETWATCH_DISMANTLER = "The tools of a craftswoman.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Charge!!",
			DIFFERENTSHARD = "Charge!!",
		},
        POCKETWATCH_PORTAL_EXIT = "Be it up so high to test our landing prowess?",

        -- Waterlog
        WATERTREE_PILLAR = "By the gods, have I found Yggdrasil itself?",
        OCEANTREE = "It hath been hardened by the sea.",
        OCEANTREENUT = "May the roots of the worldtree spread far and wide!",
        WATERTREE_ROOT = "What is it you seek, yon root?",

        OCEANTREE_PILLAR = "Yon tree shall guard us from the treacherous sun.",
        
        OCEANVINE = "Ropes from the branches of Yggdrasil.",
        FIG = "Bah! Foul non-meat!",
        FIG_COOKED = "Roasted fig flesh.",

        SPIDER_WATER = "Have at thee, water walkers!",
        MUTATOR_WATER = "They look like the little beasts, but lack the ferocity.",
        OCEANVINE_COCOON = "The nest of the water walking beasts!",
        OCEANVINE_COCOON_BURNT = "T'was consumed by flames.",

        GRASSGATOR = "What fine flaxen hair.",

        TREEGROWTHSOLUTION = "An offering to the trees, may they carry it on to great Yggdrasil itself.",

        FIGATONI = "I will not sully my warrior tastebuds with such filth.",
        FIGKABAB = "Food with a wooden spear lanced through it!",
        KOALEFIG_TRUNK = "The trunk hath been fattened up.",
        FROGNEWTON = "Into my belly with ye!",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "I can feel the Bifrost's warmth from inside it!",
            CRIMSON = "Something foul hath taken hold...",
            ENABLED = "Behold! The glory of the Bifrost!!",
			WAITING_FOR_DARK = "Something draws near...",
			COOLDOWN = "The Bifrost is sealed, but for how long?",
			SPAWN_DISABLED = "The monster shall not terrorize this realm again!",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "My friend doth possess strength that could rival mighty Thor's!",
            BURNT = "T'was a fiery display indeed!",
        },

        DUMBBELL = "'Tis not just strength, but cunning that makes a warrior!",
        DUMBBELL_GOLDEN = "He hath strength, next we must work on his bravery!",
		DUMBBELL_MARBLE = "Train well my friend, and join me in glorious battle!",
        DUMBBELL_GEM = "My friend, if you want to be fighting fit you must join me in combat!",
        POTATOSACK = "I have no use for a sack of non-meats.",


        TERRARIUMCHEST = 
		{
			GENERIC = "T'would be a fine place to keep my weapons.",
			BURNT = "Consumed by flames.",
			SHIMMER = "Doth my eyes deceive me? The chest casts jagged light!",
		},

		EYEMASKHAT = "Follower of Heimdall, watch over my path!",

        EYEOFTERROR = "Be it the plucked eye of Odin, returned for revenge?",
        EYEOFTERROR_MINI = "I hath no fear of having all eyes upon me!",
        EYEOFTERROR_MINI_GROUNDED = "I will prepare myself for the coming challenge!",

        FROZENBANANADAIQUIRI = "Monkey drink.",
        BUNNYSTEW = "A hearty meal worthy of praise!",
        MILKYWHITES = "The goopy spoils of victory!",

        CRITTER_EYEOFTERROR = "They shall watch and learn from my battles!",

        SHIELDOFTERROR ="Why cower behind a shield when you can strike with it!",
        TWINOFTERROR1 = "Do thine worst, foul metal fiend!",
        TWINOFTERROR2 = "Do thine worst, foul metal fiend!",

        -- Year of the Catcoon
        CATTOY_MOUSE = "T'would make for excellent target practice!",
        KITCOON_NAMETAG = "To me, tiny beastie! I shall gift thee with a warrior's name!",

		KITCOONDECOR1 =
        {
            GENERIC = "A sparring partner for the wee beasties.",
            BURNT = "Alas, it shall wobble no more.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "The beasties must learn to hunt!",
            BURNT = "It seems the hunt is over.",
        },

		KITCOONDECOR1_KIT = "Fear not beasties, it will be constructed forthwith!",
		KITCOONDECOR2_KIT = "I will construct it with the speed of Hermod!",

        -- WX78
        WX78MODULE_MAXHEALTH = "These boons shall empower our metal warrior.",
        WX78MODULE_MAXSANITY1 = "These boons shall empower our metal warrior.",
        WX78MODULE_MAXSANITY = "These boons shall empower our metal warrior.",
        WX78MODULE_MOVESPEED = "These boons shall empower our metal warrior.",
        WX78MODULE_MOVESPEED2 = "These boons shall empower our metal warrior.",
        WX78MODULE_HEAT = "These boons shall empower our metal warrior.",
        WX78MODULE_NIGHTVISION = "These boons shall empower our metal warrior.",
        WX78MODULE_COLD = "These boons shall empower our metal warrior.",
        WX78MODULE_TASER = "These boons shall empower our metal warrior.",
        WX78MODULE_LIGHT = "These boons shall empower our metal warrior.",
        WX78MODULE_MAXHUNGER1 = "These boons shall empower our metal warrior.",
        WX78MODULE_MAXHUNGER = "These boons shall empower our metal warrior.",
        WX78MODULE_MUSIC = "These boons shall empower our metal warrior.",
        WX78MODULE_BEE = "These boons shall empower our metal warrior.",
        WX78MODULE_MAXHEALTH2 = "These boons shall empower our metal warrior.",

        WX78_SCANNER = 
        {
            GENERIC ="Hail, wee metal scout!",
            HUNTING = "Aha! Thou art on the hunt!",
            SCANNING = "Thou hast the prey in thine sights.",
        },

        WX78_SCANNER_ITEM = "Rest well, noble scout.",
        WX78_SCANNER_SUCCEEDED = "Metal warrior! The scout's report is complete!",

        WX78_MODULEREMOVER = "I trust my ally knows what they are doing.",

        SCANDATA = "The metal scout's report!",
    },

    DESCRIBE_GENERIC = "It is an artifact of this realm.",
    DESCRIBE_TOODARK = "Too dark, even for battle.",
    DESCRIBE_SMOLDERING = "Flames will soon consume it.",

    DESCRIBE_PLANTHAPPY = "The foul plant thrives.",
    DESCRIBE_PLANTVERYSTRESSED = "It is beset by multiple afflictions.",
    DESCRIBE_PLANTSTRESSED = "Something hinders its growth.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "It seems to harbor resentment for its weed brethren.",
    DESCRIBE_PLANTSTRESSORFAMILY = "Perhaps it needs the company of its kin.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "This small patch of dirt cannot sustain all these non-meats.",
    DESCRIBE_PLANTSTRESSORSEASON = "It doesn't have what it takes to brave the seasonal elements.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "It thirsts for water.",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "You are unhappy with the dirt you have? Do not look to me to help you!",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "The feeble thing needs conversation to grow? Vikings thrive in stoic silence!",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Bones and all.",
		WINTERSFEASTFUEL = "It doth taste just like chicken!",
    },
}
