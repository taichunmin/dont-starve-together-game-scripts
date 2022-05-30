--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "I need you to look at this, time is of the essence!",
        },
        REPAIR =
        {
            WRONGPIECE = "Oh botheration. I need something else.",
        },
        BUILD =
        {
            MOUNTED = "I'm going to pull a muscle if I try grabbing that from up here.",
            HASPET = "I can't divide my time between any more pets!",
			TICOON = "Wait a tick, wasn't I already following one?",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "I'm not meeting my end under the hooves of an angry beefalo, thank you.",
			GENERIC = "That's not going to work.",
			NOBITS = "Their hair takes such a long time to grow back.",
            REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "I don't have time to waste on shaving other people's beefalo!",
		},
		STORE =
		{
			GENERIC = "There's only so much space.",
			NOTALLOWED = "I don't have time to fuss with this!",
			INUSE = "Please hurry, I have so much to do!",
            NOTMASTERCHEF = "It takes too long to cook a fancy meal.",
		},
        CONSTRUCT =
        {
            INUSE = "Waiting is so tedious!",
            NOTALLOWED = "These won't fit together.",
            EMPTY = "I thought I'd already put... ah, I must've done it later.",
            MISMATCH = "Hold on... these are the wrong plans! What a waste of time!",
        },
		RUMMAGE =
		{
			GENERIC = "This is a waste of my time.",
			INUSE = "I'll have to check it later. Or earlier?",
            NOTMASTERCHEF = "It takes too long to cook a fancy meal.",
		},
		UNLOCK =
        {
        	WRONGKEY = "Oh botheration, this isn't going to work.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "I could have sworn that was the right key...",
        	KLAUS = "I'll come back to that when I'm not fighting for my life!",
			QUAGMIRE_WRONGKEY = "Wait a tick... this isn't even the right key!",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "Could I pick the lock? Locks and clocks are only a letter apart, after all.",
            HOSTBUSY = "Ugh, I should come back sooner... or maybe later.",
            CARNIVAL_HOST_HERE = "Didn't I see Goodfeather around here? I could have sworn I did...",
            NOCARNIVAL = "Gone already? Time sure flies when you're having fun.",
			EMPTY_CATCOONDEN = "Oh botheration! Looks like this was a waste of time.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "It would be quite a short game, not that I'd mind...",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "There's nowhere to hide around here.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "I think I've spent quite enough time wrangling these tiny terrors today.",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "It takes too long to cook a fancy meal.",
			SHADOWMAGIC = "Hm.",
		},
        COOK =
        {
            GENERIC = "This is no time for cooking.",
            INUSE = "I should've gotten here sooner.",
            TOOFAR = "It's out of my reach.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "What am I forgetting? Oh! The carrats!",
        },

		DISMANTLE =
		{
			COOKING = "I'll have to be patient... just be patient... I can be patient!",
			INUSE = "Could you hurry it up a little?",
			NOTEMPTY = "Oh! I forgot to check if there was anything still inside.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "Ha! That would be like trying to use a pinion for a wheel!",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Ha! That would be like trying to use a wheel for a pinion!",
		},
        --wickerbottom specific action
        READ =
        {
            GENERIC = "only_used_by_wickerbottom",
            NOBIRDS = "only_used_by_wickerbottom",
        },

        GIVE =
        {
            GENERIC = "Hm, nope. That's not going to work.",
            DEAD = "Maybe in a different timeline...",
            SLEEPING = "Oooooh can't you sleep any faster?",
            BUSY = "Please stop what you're doing, this is important!",
            ABIGAILHEART = "I was hoping this timeline might be different.",
            GHOSTHEART = "Oh. My mistake, I thought you were a friend of mine.",
            NOTGEM = "Please. That would be like trying to put a pendulum on a watch.",
            WRONGGEM = "I could've sworn this was the right gem.",
            NOTSTAFF = "I need something that fits perfectly for the mechanism to work.",
            MUSHROOMFARM_NEEDSSHROOM = "Whoops, almost put that in the mushroom planter.",
            MUSHROOMFARM_NEEDSLOG = "I'll have to get one of those horrible logs...",
            MUSHROOMFARM_NOMOONALLOWED = "It won't grow here. I'm not wasting any more time on it.",
            SLOTFULL = "I can't fit anything else in there.",
            FOODFULL = "Oh what luck, someone already made food ahead of time!",
            NOTDISH = "Well... that was a waste of time.",
            DUPLICATE = "I'm having deja vu... didn't we already make this? Or will we...",
            NOTSCULPTABLE = "I'm not wasting one more second trying to work with this material.",
            NOTATRIUMKEY = "I need something that fits perfectly, or the mechanism won't work.",
            CANTSHADOWREVIVE = "It's not coming back. Maybe this time that's a good thing?",
            WRONGSHADOWFORM = "Oooh, now this is a puzzle...",
            NOMOON = "This isn't going to work if I can't see the moon.",
			PIGKINGGAME_MESSY = "It kind of reminds me of my old workshop... a pigsty.",
			PIGKINGGAME_DANGER = "I'm not putting my life in danger for a game!",
			PIGKINGGAME_TOOLATE = "It's getting dark. Maybe another time.",
			CARNIVALGAME_INVALID_ITEM = "It needs something that will fit into this small slot...",
			CARNIVALGAME_ALREADY_PLAYING = "I'll just come back later. Or earlier.",
            SPIDERNOHAT = "As whimsical as that would be, there isn't enough space in my pocket.",
            TERRARIUM_REFUSE = "I wonder how the magic from this world might affect it?",
            TERRARIUM_COOLDOWN = "It isn't ready yet? Botheration, even tiny trees take ages to grow!",
        },
        GIVETOPLAYER =
        {
            FULL = "If you want this, you'd better drop something fast.",
            DEAD = "No, no, I'm doing this out of order!",
            SLEEPING = "You couldn't sleep a little faster, could you?",
            BUSY = "I don't have time to wait around!",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "If you want this, you'd better drop something fast.",
            DEAD = "No, no, I'm doing this out of order!",
            SLEEPING = "You couldn't sleep a little faster, could you?",
            BUSY = "I don't have time to wait around!",
        },
        WRITE =
        {
            GENERIC = "I don't have time to fuss with that.",
            INUSE = "Are you writing a novel? What is taking so long?",
        },
        DRAW =
        {
            NOIMAGE = "Hm. I can't quite remember what it looks like...",
        },
        CHANGEIN =
        {
            GENERIC = "Now's not the time.",
            BURNING = "I'm not meeting a fiery demise for a change of clothes, thank you!",
            INUSE = "Would you hurry it up a bit in there?",
            NOTENOUGHHAIR = "Oh botheration, it hasn't grown enough hair yet.",
            NOOCCUPANT = "I thought I'd hitched up a... must've been in a different timeline.",
        },
        ATTUNE =
        {
            NOHEALTH = "I feel the darkness coming for me... I need more time!",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "I will not meet my end trampled beneath the hooves of an angry beefalo!",
            INUSE = "Oh botheration. I was going to use that, you know!",
			SLEEPING = "Wake up! There are places to go, things to be done!",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I'm in a hurry, but not that much of a hurry.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Yes yes, I know that one already.",
            CANTLEARN = "I just can't puzzle that one out...",

            --MapRecorder/MapExplorer
            WRONGWORLD = "I'm in the right time, but the wrong place.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "It's too dark in here... I can't make anything out.",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "I'm getting this out of order, I need something to wrap first.",
        },
        PICKUP =
        {
			RESTRICTION = "That's a little outside my area of expertise.",
			INUSE = "Please hurry up, I need that!",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Wait a minute... I don't remember my carrat looking like this.",
                "Oh botheration, I think I grabbed the wrong carrat.",
            },
			NO_HEAVY_LIFTING = "I might be able to manage it... if I was just a bit younger.",
        },
        SLAUGHTER =
        {
            TOOFAR = "It gets to live another day.",
        },
        REPLATE =
        {
            MISMATCH = "This isn't the right dish!",
            SAMEDISH = "I don't need two of the same plate.",
        },
        SAIL =
        {
        	REPAIR = "It doesn't need any fixing.",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "My timing must be precise!",
            BAD_TIMING1 = "No! I'm losing speed!",
            BAD_TIMING2 = "I thought I'd be better at timing...",
        },
        LOWER_SAIL_FAIL =
        {
            "Ohhh botheration!!",
            "Why can't this sail just lower properly when I tell it to?",
            "Ack! I think I pulled something in my back!",
        },
        BATHBOMB =
        {
            GLASSED = "Maybe in another timeline.",
            ALREADY_BOMBED = "It's so much fun, maybe I should go back and do it again!",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "I'm pretty sure I've seen this before. Or maybe I will see it soon?",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "It's too small to measure.",
            OVERSIZEDVEGGIES_TOO_SMALL = "Too small. I guess I shouldn't have picked it so early...",
		},
        BEGIN_QUEST =
        {
            ONEGHOST = "only_used_by_wendy",
        },
		TELLSTORY =
		{
			GENERIC = "only_used_by_walter",
			NOT_NIGHT = "only_used_by_walter",
			NO_FIRE = "only_used_by_walter",
		},
        SING_FAIL =
        {
            SAMESONG = "only_used_by_wathgrithr",
        },
        PLANTREGISTRY_RESEARCH_FAIL =
        {
            GENERIC = "This isn't the first time I've seen it.",
            FERTILIZER = "Honestly, I'm debating going back and unlearning what I know about it.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Whoops, almost gave the plants sea water!",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Didn't I just fill this up? Gardening is so tedious...",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "Didn't I just fill this up? Gardening is so tedious...",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "Oh, that's not... well this is embarrassing.",
            BEEF_BELL_ALREADY_USED = "I guess we weren't meant to be partners this time around.",
            BEEF_BELL_HAS_BEEF_ALREADY = "I don't have time to take care of all these beefalo!",
        },
        HITCHUP =
        {
            NEEDBEEF = "What am I forgetting? Something's ringing a bell...",
            NEEDBEEF_CLOSER = "Come on now, trot your way over here.",
            BEEF_HITCHED = "Wait, I already did that!",
            INMOOD = "I don't have the patience to deal with a mean-tempered beefalo.",
        },
        MARK =
        {
            ALREADY_MARKED = "Did I already pick this one? Yes, I'm pretty sure I did.",
            NOT_PARTICIPANT = "I can join in later. Or maybe earlier.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Well, if he's not going to start the contest I'm not waiting around.",
            ALREADYACTIVE = "It doesn't look like anyone's here.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "I'm sure I've seen this before.",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Oh come on, you want these worms don't you?",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "They have no interest in listening to me, and I have no interest in them.",
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
			GENERIC = "It'd be too risky.",
			REVIVE_FAILED = "It looks like I was too late...",
			WARP_NO_POINTS_LEFT = "That's enough backtracking for now.",
			SHARD_UNAVAILABLE = "There's too much wobble wibbling the timestream.",
		},
        DISMANTLE_POCKETWATCH =
        {
            ONCOOLDOWN = "It needs a bit of time to unwind.",
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
            DOER_ISNT_MODULE_OWNER = "Fine then, keep your secrets to yourself!",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "Oh botheration, I'll have to pick up a few things first.",
		NO_TECH = "I haven't quite figured that one out yet.",
		NO_STATION = "I won't be able to make it without a proper workstation.",
	},

	ACTIONFAIL_GENERIC = "Not in this timeline.",
	ANNOUNCE_BOAT_LEAK = "Oh no no no! T-the boat's taking on water!!",
	ANNOUNCE_BOAT_SINK = "No, wait! I need more time!!",
	ANNOUNCE_DIG_DISEASE_WARNING = "It looks better already.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "Uh, is it supposed to smell like that?", --removed
	ANNOUNCE_ADVENTUREFAIL = "If at first you don't succeed, reverse time and try again.",
    ANNOUNCE_MOUNT_LOWHEALTH = "I think its time in this world is almost over.",

    --waxwell and wickerbottom specific strings
    ANNOUNCE_TOOMANYBIRDS = "only_used_by_waxwell_and_wicker",
    ANNOUNCE_WAYTOOMANYBIRDS = "only_used_by_waxwell_and_wicker",

    --wolfgang specific
    ANNOUNCE_NORMALTOMIGHTY = "only_used_by_wolfang",
    ANNOUNCE_NORMALTOWIMPY = "only_used_by_wolfang",
    ANNOUNCE_WIMPYTONORMAL = "only_used_by_wolfang",
    ANNOUNCE_MIGHTYTONORMAL = "only_used_by_wolfang",
    ANNOUNCE_EXITGYM = {
--fallback to speech_wilson.lua         MIGHTY = "only_used_by_wolfang",
--fallback to speech_wilson.lua         NORMAL = "only_used_by_wolfang",
--fallback to speech_wilson.lua         WIMPY = "only_used_by_wolfang",
    },

	ANNOUNCE_BEES = "Oh botheration. Those bees really tick me off!",
	ANNOUNCE_BOOMERANG = "What goes around comes around.",
	ANNOUNCE_CHARLIE = "They found me... N-no! Stay away!",
	ANNOUNCE_CHARLIE_ATTACK = "Leave me alone!",
	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "Brrr... w-when did it get so cold?",
	ANNOUNCE_HOT = "I've got to get out of this heat...",
	ANNOUNCE_CRAFTING_FAIL = "Oh botheration. I forgot something again, didn't I?",
	ANNOUNCE_DEERCLOPS = "Oh botheration, is it that time of year already?",
	ANNOUNCE_CAVEIN = "No no no! Everything's falling apart!",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"The ground is trying to swallow me!",
		"What is that horrible rumble?",
		"Something's shifting!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "Here, take this and let me leave in peace!",
        "Just take this and I'll be on my way.",
        "Time to move on.",
	},
	ANNOUNCE_SACREDCHEST_YES = "I knew I could puzzle it out!",
	ANNOUNCE_SACREDCHEST_NO = "This was all just a waste of time!",
    ANNOUNCE_DUSK = "I need to hurry, I'm losing daylight.",

    --wx-78 specific
    ANNOUNCE_CHARGE = "only_used_by_wx78",
	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Mmm!",
		PAINFUL = "Ohh... I don't feel well...",
		SPOILED = "Can I go back to a time before I ate that?",
		STALE = "I think that was getting a bit old.",
		INVALID = "I'm not eating that!",
        YUCKY = "This may be a matter of survival, but I do have SOME standards left.",

        --Warly specific ANNOUNCE_EAT strings
		COOKED = "only_used_by_warly",
		DRIED = "only_used_by_warly",
        PREPARED = "only_used_by_warly",
        RAW = "only_used_by_warly",
		SAME_OLD_1 = "only_used_by_warly",
		SAME_OLD_2 = "only_used_by_warly",
		SAME_OLD_3 = "only_used_by_warly",
		SAME_OLD_4 = "only_used_by_warly",
        SAME_OLD_5 = "only_used_by_warly",
		TASTY = "only_used_by_warly",
    },

    ANNOUNCE_ENCUMBERED =
    {
        "Oof...",
        "I'm getting... too old for this...",
        "Huff... hoo...",
        "I usually... work with... smaller things...",
        "Hrrrrgh!",
        "Come... on...! I... have things... to do...!",
        "Oh yes... let's let the clockmaker... do the heavy lifting...!",
        "I'd better not... sprain anything...",
        "So... huff... heavy...",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Time to move!",
		"I need to get out of here!",
		"Something's happening... I can't stay here!",
	},
    ANNOUNCE_RUINS_RESET = "I felt a temporal wobble... a part of this timeline just reset itself!",
    ANNOUNCE_SNARED = "Ack! Let me go!!",
    ANNOUNCE_SNARED_IVY = "Ow! Oooh, I never liked gardening...",
    ANNOUNCE_REPELLED = "I can't get through!",
	ANNOUNCE_ENTER_DARK = "No! I won't let the darkness take me!!",
	ANNOUNCE_ENTER_LIGHT = "Whew...",
	ANNOUNCE_FREEDOM = "I-I'm free... I'm alive... h-ha! Ha h-haha! Hahahaha!!",
	ANNOUNCE_HIGHRESEARCH = "That really got the gears in my head turning!",
	ANNOUNCE_HOUNDS = "Wait a tick... did you hear something?",
	ANNOUNCE_WORMS = "That rumble felt... ominous.",
	ANNOUNCE_HUNGRY = "How long has it been since I last ate?",
	ANNOUNCE_HUNT_BEAST_NEARBY = "An animal must've been through here just moments ago.",
	ANNOUNCE_HUNT_LOST_TRAIL = "Lost it. Maybe I should retrace my steps.",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "Everything's too soggy, I'm not wasting my time with this.",
	ANNOUNCE_INV_FULL = "I'll have to come back for it later. Or earlier.",
	ANNOUNCE_KNOCKEDOUT = "How long have I been out? How much time did I lose?!",
	ANNOUNCE_LOWRESEARCH = "Well I learned a bit, but not much.",
	ANNOUNCE_MOSQUITOS = "Of course there would be mosquitoes here.",
    ANNOUNCE_NOWARDROBEONFIRE = "I'm not meeting a fiery demise for a change of clothes, thank you!",
    ANNOUNCE_NODANGERGIFT = "I'd like to stay focused on not dying, thank you very much!",
    ANNOUNCE_NOMOUNTEDGIFT = "I'll just quickly hop off my beefalo first.",
	ANNOUNCE_NODANGERSLEEP = "Sorry, the threat of imminent death is making it a bit hard to sleep!",
	ANNOUNCE_NODAYSLEEP = "The sun's shining in my eyes...",
	ANNOUNCE_NODAYSLEEP_CAVE = "I don't have time to waste on sleeping right now.",
	ANNOUNCE_NOHUNGERSLEEP = "I need to find something to eat first, quickly.",
	ANNOUNCE_NOSLEEPONFIRE = "It might be hard to sleep while I'm being roasted alive.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Botheration... it's too bright to sleep while that automaton's about.",
	ANNOUNCE_NODANGERSIESTA = "There's more important things to worry about at the moment!",
	ANNOUNCE_NONIGHTSIESTA = "Now is not the time for a siesta.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "I'll take a break when I'm on the surface where it's safe...er.",
	ANNOUNCE_NOHUNGERSIESTA = "I can't rest! I need to find something to eat, quickly!",
	ANNOUNCE_NO_TRAP = "That was easy enough.",
	ANNOUNCE_PECKED = "Alright, I'm going, I'm going!",
	ANNOUNCE_QUAKE = "The timeline's collapsing! No, worse, it's the ground!",
	ANNOUNCE_RESEARCH = "I'm a quick learner.",
	ANNOUNCE_SHELTER = "I should be protected here for now.",
	ANNOUNCE_THORNS = "Ack! I've got a thorn in my side!",
	ANNOUNCE_BURNT = "I was almost burnt to a crisp!",
	ANNOUNCE_TORCH_OUT = "My torch! I need to find another one quickly!",
	ANNOUNCE_THURIBLE_OUT = "It's run its course.",
	ANNOUNCE_FAN_OUT = "This fan's time has passed.",
    ANNOUNCE_COMPASS_OUT = "I'm not sure how this simple mechanism managed to break, but...",
	ANNOUNCE_TRAP_WENT_OFF = "Ack! That wasn't meant to happen!",
	ANNOUNCE_UNIMPLEMENTED = "I don't think that belongs in this timeline.",
	ANNOUNCE_WORMHOLE = "I can't believe I just did that...",
	ANNOUNCE_TOWNPORTALTELEPORT = "I've jumped through time and space enough to be used to this sort of thing.",
	ANNOUNCE_CANFIX = "\nI've repaired complicated timepieces, fixing this should be easy!",
	ANNOUNCE_ACCOMPLISHMENT = "Ha! Success!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "I think I've accomplished everything I needed to do.",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "Hm, did I remember to give it fertilizer?",
	ANNOUNCE_TOOL_SLIP = "I'm usually not such a butterfingers.",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "I was almost struck down!",
	ANNOUNCE_TOADESCAPING = "M-maybe I should just let it go.",
	ANNOUNCE_TOADESCAPED = "It's finally gone.",


	ANNOUNCE_DAMP = "A little water shouldn't be anything to worry about.",
	ANNOUNCE_WET = "It's getting uncomfortably damp around here.",
	ANNOUNCE_WETTER = "Oooh, my pocket watches are going to rust if this keeps up!",
	ANNOUNCE_SOAKED = "I'm going to catch my death if I don't dry off soon!",

	ANNOUNCE_WASHED_ASHORE = "I-I don't think I'm going on another boat for a while.",

    ANNOUNCE_DESPAWN = "Wait, stop! I need more time--!",
	ANNOUNCE_BECOMEGHOST = "oOooOooo!!",
	ANNOUNCE_GHOSTDRAIN = "Stop it, I refuse to accept mortality!",
	ANNOUNCE_PETRIFED_TREES = "What was that horrible sound? Did it come from the trees?",
	ANNOUNCE_KLAUS_ENRAGE = "I think it's time for me to leave!",
	ANNOUNCE_KLAUS_UNCHAINED = "That can't be good...",
	ANNOUNCE_KLAUS_CALLFORHELP = "How does someone like that have friends to call on for help?",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "There's something suspended inside.",
		GLASS_LOW = "Just a bit longer...",
		GLASS_REVEAL = "I wonder how long it was stuck in there.",
		IDOL_MED = "There's something suspended inside.",
		IDOL_LOW = "Just a bit longer...",
		IDOL_REVEAL = "I wonder how long it was stuck in there.",
		SEED_MED = "There's something suspended inside.",
		SEED_LOW = "Just a bit longer...",
		SEED_REVEAL = "I wonder how long it was stuck in there.",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Ack! Leave me alone!!",
	ANNOUNCE_BRAVERY_POTION = "It doesn't seem quite as scary this time around.",
	ANNOUNCE_MOONPOTION_FAILED = "Well that didn't work out like I hoped.",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Maybe I should offer some to the others...",
	ANNOUNCE_WINTERS_FEAST_BUFF = "All this excitement is kind of infectious!",
	ANNOUNCE_IS_FEASTING = "I guess it is nice to slow down every once in a while.",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "That was fun... maybe I'll go back and re-live it sometime.",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Not on my watch!!",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "Whew... I got here just in time.",
    ANNOUNCE_REVIVED_FROM_CORPSE = "F-for a moment, I thought I was done for...",

    ANNOUNCE_FLARE_SEEN = "Was that a flare? I'd better hurry and see what's going on!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "I don't like the looks of that shadow...",

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
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Those ingredients didn't make anything.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "I left it on too long.",
    QUAGMIRE_ANNOUNCE_LOSE = "I have a bad feeling about this.",
    QUAGMIRE_ANNOUNCE_WIN = "Time to go!",

--fallback to speech_wilson.lua     ANNOUNCE_ROYALTY =
--fallback to speech_wilson.lua     {
--fallback to speech_wilson.lua         "Your majesty.",
--fallback to speech_wilson.lua         "Your highness.",
--fallback to speech_wilson.lua         "My liege!",
--fallback to speech_wilson.lua     },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "I've never felt so full of energy!",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "I want to punch something!!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I feel a bit safer, strangely.",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "This is more like it! I'll have everything done in no time at all!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "I feel thoroughly waterproofed.",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Finally, I don't have to waste time sleeping!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "I'll miss having electricity at my fingertips.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Whew, I don't know what came over me...",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "I'm suddenly feeling a bit unprotected...",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "No! I can't slow down now!",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Oh botheration, I was getting used to being waterproof.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "I guess I can't avoid sleeping forever.",

	ANNOUNCE_OCEANFISHING_LINESNAP = "No! I was so close!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "I need to keep the line taut.",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "I'll get you last time! Err, next time!",
	ANNOUNCE_OCEANFISHING_BADCAST = "Maybe I should go back and try that again...",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"The fish aren't biting, why am I wasting time here?",
		"Couldn't the fish have the decency to let themselves be caught faster?",
		"Do I really have time to waste on this?",
		"Maybe I should try fishing later. Or earlier.",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nHa! I've impressed myself!",

	ANNOUNCE_WINCH_CLAW_MISS = "Oh botheration, let's try that again.",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "I wasted my precious time for nothing.",

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
    ANNOUNCE_WEAK_RAT = "Poor thing, I think it's gotten stale.",

    ANNOUNCE_CARRAT_START_RACE = "On my mark, three, one, two-- GO!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Oh no... my bad sense of direction must've rubbed off on it.",
        "Wrong way, go back!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "There's no time for sleeping!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "How did I end up with such a slow carrat?",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "This is no time to stand around!",

--fallback to speech_wilson.lua     ANNOUNCE_GHOST_QUEST = "only_used_by_wendy",
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

    ANNOUNCE_WANDA_YOUNGTONORMAL = "It's alright, I still have time...",
    ANNOUNCE_WANDA_NORMALTOOLD = "I don't have much time left!",
    ANNOUNCE_WANDA_OLDTONORMAL = "Death will never catch me!",
    ANNOUNCE_WANDA_NORMALTOYOUNG = "Ha! Full of youthful vigor once again!",

	ANNOUNCE_POCKETWATCH_PORTAL = "We're here! Don't be alarmed, a bit of time sickness is completely normal.",

	ANNOUNCE_POCKETWATCH_MARK = "That will make a fine anchor point.",
	ANNOUNCE_POCKETWATCH_RECALL = "Nothing like a jaunt through time to get the old heart pumping!",
	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "Alright everyone, quickly now!",
	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "Keep your wits about you, this is going to be a big jump!",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "It's showing me strange designs... I don't think I've seen them before.",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "I know this. Or maybe I will know it soon.",
    ANNOUNCE_ARCHIVE_NO_POWER = "This place is like a clock that's been left unwound.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "I learned something new! Or at least remembered something I forgot...",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "I wonder what it'll be? Maybe I should jump ahead and sneak a peek...",

    ANNOUNCE_FERTILIZER_RESEARCHED = "I think I know enough about fertilizer to last me a lifetime.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Oooh, I don't feel well at all...",
		"Help! I've been poisoned!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Whew... it looks like the effects aren't permanent.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "I can't afford to waste time talking to a plant!",
        "I don't really know what to say...",
		"Err... can you grow faster, please?",
        "I don't have time for this!",
        "Maybe I could speed this up a little... you wouldn't mind that, would you?",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Alright go on now, let's make this quick.",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Perhaps I have time for one quick game...",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"Finally!",
		"Found you at last.",
		"So that's where you were hiding this whole time!",
		"I knew you couldn't hide forever.",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "I seem to recall there being one more to find...",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "That has to be the last one.",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "Oh good, {name} finally found the last one.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Better hurry, our time's almost up!",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Oh botheration, I wasn't quick enough.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "Surely they wouldn't have gone all the way out here?",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "Yes, this looks more familiar, I'm sure I'll find them here!",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "I thought I might find something hiding there!",

	ANNOUNCE_TICOON_START_TRACKING	= "He's certainly in a rush to get somewhere.",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "Nothing seems to be catching its attention.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Are you waiting for me? What an odd turn of events.",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Yes yes, I'm coming!",
	ANNOUNCE_TICOON_NEAR_KITCOON = "Did I just hear a rustle? Perhaps it's nearby...",
	ANNOUNCE_TICOON_LOST_KITCOON = "Oh botheration, I didn't find it quick enough.",
	ANNOUNCE_TICOON_ABANDONED = "I've spent enough time following you around for one day.",
	ANNOUNCE_TICOON_DEAD = "His time was cut short... and my time's been wasted!",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Over here!",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "It'd be more efficient to put it closer to the judge's booth.",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Something new, how exciting!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "I feel a chill, did someone leave an interdimensional door open?",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Well, it's about time!",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "I suppose we must wait until sundown to finish this squabble.",

	BATTLECRY =
	{
		GENERIC = "You ruffian! I'll clean your clock!",
		PIG = "Your time ends now, pig!",
		PREY = "It's nothing personal!",
		SPIDER = "Dial it back a notch, would you?",
		SPIDER_WARRIOR = "Did I insult you in some other timeline?",
		DEER = "This won't go well for you!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "I've got better things to do.",
		PIG = "At least they're gone now.",
		PREY = "All that time I spent, down the drain.",
		SPIDER = "I hope I don't run into him again.",
		SPIDER_WARRIOR = "And don't come back!",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Parts of this mechanism look... familiar...",
        MULTIPLAYER_PORTAL_MOONROCK = "I feel like I'm being watched...",
        MOONROCKIDOL = "It looks a bit like a key, doesn't it?",
        CONSTRUCTION_PLANS = "What's a little more tampering going to hurt?",

        ANTLION =
        {
            GENERIC = "Oh botheration, I hope I remembered to bring a gift.",
            VERYHAPPY = "Oh now you're in a good mood?",
            UNHAPPY = "There's no need to get yourself so worked up!",
        },
        ANTLIONTRINKET = "This might make a good gift for someone.",
        SANDSPIKE = "I won't have my time cut short by the likes of you!",
        SANDBLOCK = "The sands of time are so fickle!",
        GLASSSPIKE = "It looks nice now that it's not trying to impale me.",
        GLASSBLOCK = "Nothing is permanent, eventually it might be sand again.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="There's something about that flower...",
			LEVEL1 = "There's something about that flower...",
			LEVEL2 = "There's energy building around it.",
			LEVEL3 = "Something's about to happen!",

			-- deprecated
            LONG = "It hurts my soul to look at that thing.",
            MEDIUM = "It's giving me the creeps.",
            SOON = "Something is up with that flower!",
            HAUNTED_POCKET = "I don't think I should hang on to this.",
            HAUNTED_GROUND = "I'd die to find out what it does.",
        },

        BALLOONS_EMPTY = "Everyone has their forte. Some bend time, others bend balloons.",
        BALLOON = "Balloons have such a short lifespan.",
		BALLOONPARTY = "Balloons within balloons.",
		BALLOONSPEED =
        {
            DEFLATED = "Well, that was short-lived.",
            GENERIC = "Just the extra bit of speed I've been looking for!",
        },
		BALLOONVEST = "If it keeps me from drowning, I'll wear it.",
		BALLOONHAT = "Ha, I'd look ridiculous in that! Let me try it on.",

        BERNIE_INACTIVE =
        {
            BROKEN = "This can't be the end. We'll fix this!",
            GENERIC = "It looks well-loved.",
        },

        BERNIE_ACTIVE = "How incredible that this isn't even the strangest thing I've seen.",
        BERNIE_BIG = "I could've sworn you were smaller...",

        BOOK_BIRDS = "Time and birds sure do fly.",
        BOOK_TENTACLES = "It's enough having to deal with them in person, why read about them too?",
        BOOK_GARDENING = "Do I even want to know how long the unabridged version was?",
		BOOK_SILVICULTURE = "Say Wickerbottom, do you dabble in temporal magic as well?",
		BOOK_HORTICULTURE = "Say Wickerbottom, do you dabble in temporal magic as well?",
        BOOK_SLEEP = "Not to critique the writing, but that nearly put me to sleep.",
        BOOK_BRIMSTONE = "Hmph. Not if I can help it.",

        PLAYER =
        {
            GENERIC = "Sorry %s, I have no time to stay and chat!",
            ATTACKER = "I'm keeping my eye on you, %s...",
            MURDERER = "%s! What have you done?!",
            REVIVER = "Th-thank you %s, I won't be so careless again.",
            GHOST = "%s! Don't worry, I can fix this!",
            FIRESTARTER = "I see, in this timeline you fancy yourself an arsonist?",
        },
        WILSON =
        {
            GENERIC = "%s! I think I was supposed to tell you something, now what was it...",
            ATTACKER = "So much for \"gentleman\" scientist, %s.",
            MURDERER = "%s! What have you done?!",
            REVIVER = "Was that really science, %s? Ah, who am I to question it.",
            GHOST = "Don't fret, a little isolated time flippery will make you right as rain.",
            FIRESTARTER = "Is that what passes for \"science\" now, %s?",
        },
        WOLFGANG =
        {
            GENERIC = "Sorry %s, no time to chat.",
            ATTACKER = "Nobody likes a bully, %s!",
            MURDERER = "%s! How could you?!",
            REVIVER = "We should all remember to be more cautious next time.",
            GHOST = "%s! When did this happen?!",
            FIRESTARTER = "I don't think that's the best use of your time, %s...",
        },
        WAXWELL =
        {
            GENERIC = "Goodness %s, have you aged since the last time I saw you?",
            ATTACKER = "I knew there was something dark about you, %s!",
            MURDERER = "The shadows poisoned your mind, %s! Now you need to be dealt with!",
            REVIVER = "There is goodness in you yet, %s. Oh, don't look so embarrassed!",
            GHOST = "Don't fret %s, I can fix this! Just give me a moment.",
            FIRESTARTER = "Honestly! Throwing a tantrum won't solve anything.",
        },
        WX78 =
        {
            GENERIC = "Oh, it's the funny little automaton! Hello %s!",
            ATTACKER = "%s is looking a bit wound up...",
            MURDERER = "Why you're nothing but a murderous pile of cogs and gears!",
            REVIVER = "I think deep down you value life as much as I do, %s.",
            GHOST = "Don't you fret, I'll get you fixed up in no time at all!",
            FIRESTARTER = "I can see your gears turning, %s. Just what are you up to?",
        },
        WILLOW =
        {
            GENERIC = "There you are %s! Whatever you do, don't... oh botheration, I forgot.",
            ATTACKER = "Now's not the time to turn on each other, %s!",
            MURDERER = "Is this the timeline where you go on a killing spree, %s?",
            REVIVER = "Thank goodness our timelines converged, %s!",
            GHOST = "Your time isn't over yet %s, not if I have anything to say about it!",
            FIRESTARTER = "Some things stay consistent between timelines...",
        },
        WENDY =
        {
            GENERIC = "Ah, hello %s... sorry, but I'm in a bit of a hurry'.",
            ATTACKER = "Hold on now, there's no need for that, %s.",
            MURDERER = "You stay back! I mean it!",
            REVIVER = "It must be hard for her...",
            GHOST = "If only I could turn the clock back for both of you.",
            FIRESTARTER = "Children these days, always playing with fire.",
        },
        WOODIE =
        {
            GENERIC = "Sorry %s, no time for pleasantries!",
            ATTACKER = "That was just mean and unnecessary, %s!",
            MURDERER = "You cut their life short! Why?!",
            REVIVER = "You really do have a heart as big as your beard, %s.",
            GHOST = "Don't worry, I'll have you back to your old self in no time!",
            BEAVER = "Hmm. I could have sworn he turned into a moose.",
            BEAVERGHOST = "Give me a moment %s, it'll be like this never happened!",
            MOOSE = "Hmm. I could have sworn he turned into a goose.",
            MOOSEGHOST = "Don't worry %s, I won't let things end for you like this!",
            GOOSE = "Hmm. I could have sworn he turned into a beaver.",
            GOOSEGHOST = "This isn't the end for you, %s. Not if I can help it!",
            FIRESTARTER = "Well it's hard to surprise me %s, but you managed it.",
        },
        WICKERBOTTOM =
        {
            GENERIC = "You're looking well, %s!",
            ATTACKER = "%s! What's gotten into you?",
            MURDERER = "Murderer! Your time ends now!",
            REVIVER = "We should all be more cautious in the future.",
            GHOST = "Your time isn't over yet %s, not on my watch!",
            FIRESTARTER = "Really, %s. You should know better at your age!",
        },
        WES =
        {
            GENERIC = "Sorry %s, I have no time for charades!",
            ATTACKER = "Now hold on just one minute, I don't think that's part of the act!",
            MURDERER = "Murderer! Do you have nothing to say for yourself?!",
            REVIVER = "%s's actions speak louder than his words.",
            GHOST = "Don't you fret, soon it'll be like this never even happened!",
            FIRESTARTER = "Ah... it looks like I'm in the bad timeline again.",
        },
        WEBBER =
        {
            GENERIC = "Oh, %s! I think I have some candy in my pocket, though it might be a tad stale...",
            ATTACKER = "Someone needs to give that child a time out.",
            MURDERER = "You monster! I'll erase you from this timeline!",
            REVIVER = "Children today are quite dependable.",
            GHOST = "Don't fret %s, I'll have you right as rain in no time at all!",
            FIRESTARTER = "All children want to do these days is set fire to everything.",
        },
        WATHGRITHR =
        {
            GENERIC = "Nice to see you again %s, but I'm afraid I can't stay long.",
            ATTACKER = "It was only a matter of time until she turned her spear against us.",
            MURDERER = "You're not taking MY soul to Val-whatever-you-call-it!",
            REVIVER = "I think I'm quite glad to have you around after all, %s.",
            GHOST = "Give me a moment, you'll be yodeling... or whatever it is, again in no time!",
            FIRESTARTER = "Why does this always seem to happen...",
        },
        WINONA =
        {
            GENERIC = "Sorry %s, things to do, places to be. You know how it is!",
            ATTACKER = "Come on now %s, you're better than that!",
            MURDERER = "I don't know what this is all about %s, but leave me out of it!",
            REVIVER = "I'm glad I can count on you in times of need, %s.",
            GHOST = "It's about time I showed you what my own little gadgets can do!",
            FIRESTARTER = "Huh. You weren't such a firebug in the last timeline.",
        },
        WORTOX =
        {
            GENERIC = "I get the sense you're even more well-traveled than I am, %s.",
            ATTACKER = "Was that really necessary, %s?",
            MURDERER = "You've taken things too far %s, this isn't a game!",
            REVIVER = "You didn't take a nibble while I wasn't looking, did you?",
            GHOST = "A little bit of time re-shapery and you'll be good as new!",
            FIRESTARTER = "%s is a hard imp to predict...",
        },
        WORMWOOD =
        {
            GENERIC = "%s! Have you grown since I last saw you?",
            ATTACKER = "Oh of all the... would you settle down?!",
            MURDERER = "Killer! I'll put you back in the ground you sprung from!",
            REVIVER = "Remind me never to die again.",
            GHOST = "Don't you fret %s, I've got everything under control!",
            FIRESTARTER = "%s might not be very bright...",
        },
        WARLY =
        {
            GENERIC = "How good it is to see you, %s! Tell me, have we met yet?",
            ATTACKER = "I don't like the look on your face, %s...",
            MURDERER = "It's hard to fool me %s, did you have this plot cooked up all along?!",
            REVIVER = "I'm glad to have someone like you around, %s.",
            GHOST = "Give me a minute, I can fix this!",
            FIRESTARTER = "Not everything needs to be cooked, %s...",
        },

        WURT =
        {
            GENERIC = "Sorry %s, I can't stay and chat!",
            ATTACKER = "Are you getting up to some trouble, %s?",
            MURDERER = "Stay back! If it's you or me, I'm picking me!",
            REVIVER = "I think you and I are going to get along quite well, %s.",
            GHOST = "Stop pestering me, I'll have you back as quickly as I can!",
            FIRESTARTER = "This won't end well...",
        },

        WALTER =
        {
            GENERIC = "%s, why do you keep looking at my hands...?",
            ATTACKER = "You were much more polite in the last timeline.",
            MURDERER = "I know what you did %s, you can't talk your way out of this one!",
            REVIVER = "That was some quick thinking, %s!",
            GHOST = "I'll have you back on your feet before you can say temporal squiggle!",
            FIRESTARTER = "Honestly, nothing really surprises me anymore.",
        },

        WANDA =
        {
            GENERIC = "Well, fancy running into me here!",
            ATTACKER = "Well... they must've deserved it.",
            MURDERER = "It looks like there's only room for one of us in this timeline!",
            REVIVER = "I'm glad one of us was able to act in time!",
            GHOST = "I'm not letting things end for us here!",
            FIRESTARTER = "Hm. I must have my reasons...",
        },

--fallback to speech_wilson.lua         MIGRATION_PORTAL =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua         --    GENERIC = "If I had any friends, this could take me to them.",
--fallback to speech_wilson.lua         --    OPEN = "If I step through, will I still be me?",
--fallback to speech_wilson.lua         --    FULL = "It seems to be popular over there.",
--fallback to speech_wilson.lua         },
        GLOMMER =
        {
            GENERIC = "Who's a cute little bug thing? You are!",
            SLEEPING = "Sleeping again?",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "I like anything that can make its own light.",
            DEAD = "Why must life be so fleeting for some?",
        },
        GLOMMERWINGS = "I'm just not going to think about where they came from!",
        GLOMMERFUEL = "Oh. Droppings. How lovely.",
        BELL = "What's the worst that could happen?",
        STATUEGLOMMER =
        {
            GENERIC = "I still haven't figured out who made this...",
            EMPTY = "It seemed like a good idea at the time.",
        },

        LAVA_POND_ROCK = "You've seen one rock, you've seen them all.",

		WEBBERSKULL = "Poor little guy. He deserves a proper funeral.",
		WORMLIGHT = "A nice light snack!",
		WORMLIGHT_LESSER = "There's nothing wrong with a few wrinkles!",
		WORM =
		{
		    PLANT = "Something's nagging at my memory... ah, it's probably nothing.",
		    DIRT = "About as boring as you'd expect a pile of dirt to be.",
		    WORM = "Now I remember!",
		},
        WORMLIGHT_PLANT = "Something's nagging at my memory... ah, it's probably nothing.",
		MOLE =
		{
			HELD = "Got you at last, you little vermin!",
			UNDERGROUND = "It's one of those little pests.",
			ABOVEGROUND = "I've spent enough time dealing with your shenanigans!",
		},
		MOLEHILL = "I thought they were bigger... my memory must've exaggerated it.",
		MOLEHAT = "What a funny looking hat. Let me try it on!",

		EEL = "I think I just saw it wriggle...",
		EEL_COOKED = "Oh good. My favorite.",
		UNAGI = "It makes the eel slightly better.",
		EYETURRET = "Ooooh, I LIKE this thing!",
		EYETURRET_ITEM = "Where to put it, where to put it...",
		MINOTAURHORN = "I'm glad I managed to not meet my end at the business end of this horn.",
		MINOTAURCHEST = "Did I open it last time around? I can't recall...",
		THULECITE_PIECES = "Just what I was looking for!",
		POND_ALGAE = "I can't spend my time looking at every old pond plant.",
		GREENSTAFF = "It's cruder than my pocket watch, but it follows the same basic principles.",
		GIFT = "Oh! Uh... was I supposed to bring a present too?",
        GIFTWRAP = "Wouldn't it be quicker to just put it in a nice bag?",
		POTTEDFERN = "I can never seem to keep them alive for long.",
        SUCCULENT_POTTED = "I can never seem to keep them alive for long.",
		SUCCULENT_PLANT = "I'm afraid I can't stop to admire every bit of scenery.",
		SUCCULENT_PICKED = "I guess it's technically edible.",
		SENTRYWARD = "Good, this will help me get the lay of the land quicker.",
        TOWNPORTAL =
        {
			GENERIC = "A bit redundant, but it'll work in a pinch.",
			ACTIVE = "Looks like it's ready to go.",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "It positively reeks of spacial wib-wobblery.",
			ACTIVE = "I might as well use it.",
		},
        WETPAPER = "This is going to take forever to dry...",
        WETPOUCH = "It's a soggy mess.",
        MOONROCK_PIECES = "I wonder who made these?",
        MOONBASE =
        {
            GENERIC = "I'm pretty sure that's important for something.",
            BROKEN = "Someone didn't want us to use this.",
            STAFFED = "Was something else supposed to happen? I can't remember...",
            WRONGSTAFF = "I've got a nagging feeling it's not supposed to look like that.",
            MOONSTAFF = "Of course! Now I remember!",
        },
        MOONDIAL =
        {
			GENERIC = "Why worry about the moon? I've got enough to contend with down here.",
			NIGHT_NEW = "It's a new moon. I'd best keep my wits about me...",
			NIGHT_WAX = "The moon is waxing.",
			NIGHT_FULL = "Oh good, a full moon!",
			NIGHT_WANE = "The moon is waning.",
			CAVE = "I won't waste my time trying to see the moon down here.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "Oh botheration, THIS timeline again...",
        },
		THULECITE = "If I could just break it down into more manageable pieces...",
		ARMORRUINS = "I'm all for anything that'll keep me safe.",
		ARMORSKELETON = "Nope. Nope nope nope.",
		SKELETONHAT = "I don't want to put a dead thing on my head!",
		RUINS_BAT = "It's a bit unwieldy, don't you think?",
		RUINSHAT = "I'm never taking it off!",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Things seem quiet for the time being.",
            WARN = "Oh no no no, don't you dare!",
            WAXING = "They're everywhere! I-I need to get out of here!!",
            STEADY = "Stay away from me!!",
            WANING = "I just need to hold out a little longer--!",
            DAWN = "It's almost over... I can do this!",
            NOMAGIC = "Looks like I'm free of any magical flapdoodle.",
		},
		BISHOP_NIGHTMARE = "It's been completely taken over...",
		ROOK_NIGHTMARE = "How is it still going?",
		KNIGHT_NIGHTMARE = "I... I don't want to look at it.",
		MINOTAUR = "Ohhhh. Right. You.",
		SPIDER_DROPPER = "You think you can get the drop on me?",
		NIGHTMARELIGHT = "I'd better not get too close.",
		NIGHTSTICK = "A light up weapon? What will they think of next!",
		GREENGEM = "If only I could've gotten my hands on one of these before... well never mind.",
		MULTITOOL_AXE_PICKAXE = "This will save me precious time!",
		ORANGESTAFF = "Really? We're just putting the gem on a stick and calling it a day?",
		YELLOWAMULET = "Just the boost I needed.",
		GREENAMULET = "Beautifully efficient.",
		SLURPERPELT = "Yuck.",

		SLURPER = "I can't decide how I feel about them...",
		SLURPER_PELT = "Yuck.",
		ARMORSLURPER = "I guess I'll swallow my pride and wear it...",
		ORANGEAMULET = "I can save so much time if I don't have to stop and pick things up!",
		YELLOWSTAFF = "Does no one else think summoning a small STAR might be dangerous?",
		YELLOWGEM = "It won't do much good by itself.",
		ORANGEGEM = "It's beautiful, but more or less useless as it is.",
        OPALSTAFF = "Brrr, I just got chills.",
        OPALPRECIOUSGEM = "It's distractingly beautiful.",
        TELEBASE =
		{
			VALID = "Well, might as well put it to use.",
			GEMS = "I can't believe how much energy this thing requires to work.",
		},
		GEMSOCKET =
		{
			VALID = "This thing sure takes up a lot of space.",
			GEMS = "It needs THREE gems to work?!",
		},
		STAFFLIGHT = "A tiny star, what could go wrong?",
        STAFFCOLDLIGHT = "If it keeps me from dying of heat exposure, I'm happy.",

        ANCIENT_ALTAR = "It seems like they were a clever bunch. Just not clever enough.",

        ANCIENT_ALTAR_BROKEN = "Time has worn it away.",

        ANCIENT_STATUE = "What's left from a time long ago.",

        LICHEN = "I'm not stopping to gawk at every plant I see!",
		CUTLICHEN = "Its time is running out quickly.",

		CAVE_BANANA = "I like a quick snack with no fuss.",
		CAVE_BANANA_COOKED = "Why did I spend time cooking it?",
		CAVE_BANANA_TREE = "You can barely call it a tree.",
		ROCKY = "You keep those claws far away from me!",

		COMPASS =
		{
			GENERIC="If only it could tell me which way is past and which way is future.",
			N = "North. That's \"up\" on the map, right?",
			S = "South. That's \"down\" on the map, right?",
			E = "East. It's definitely East!",
			W = "West. That'd be left, right?",
			NE = "Northeast. I think.",
			SE = "Southeast. Probably.",
			NW = "Northwest. Maybe?",
			SW = "Southwest. Or not, who really knows?",
		},

        HOUNDSTOOTH = "I could have been eaten!",
        ARMORSNURTLESHELL = "It's not pleasant, but I do feel a bit safer.",
        BAT = "Stay out of my hair, it's enough of a bat's nest already!",
        BATBAT = "I can take a bit of my enemy's lifespan and add it to my own.",
        BATWING = "That'll teach those bats.",
        BATWING_COOKED = "I don't know what flavor I expected, but it wasn't that.",
        BATCAVE = "Don't mind me... just passing through...",
        BEDROLL_FURRY = "If I have to spend time sleeping, at least I can do it comfortably.",
        BUNNYMAN = "I don't trust those things.",
        FLOWER_CAVE = "I don't have time to stop and smell the flowers.",
        GUANO = "Bat droppings. Lovely.",
        LANTERN = "I'd better keep this close, just in case.",
        LIGHTBULB = "It will give me a few precious minutes of light.",
        MANRABBIT_TAIL = "It's nice, so long as I don't think about where it came from.",
        MUSHROOMHAT = "I don't like the idea of a mushroom growing on my head.",
        MUSHROOM_LIGHT2 =
        {
            ON = "Alright, glowing mushrooms I can appreciate.",
            OFF = "Adding some colored spores might brighten this place up.",
            BURNT = "I guess it's time to find a new light.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "Light made without oil or matches never ceases to amaze me.",
            OFF = "What a strangely shaped mushroom.",
            BURNT = "I guess it's time to find a new light.",
        },
        SLEEPBOMB = "Who would want to spend precious time napping?",
        MUSHROOMBOMB = "I knew there was a reason I don't like mushrooms!",
        SHROOM_SKIN = "That creature must've been half decayed. How horrible!",
        TOADSTOOL_CAP =
        {
            EMPTY = "Wasn't there something here before? Or maybe that's later.",
            INGROUND = "Come on out, don't be shy!",
            GENERIC = "This feels strangely familiar.",
        },
        TOADSTOOL =
        {
            GENERIC = "I really should have remembered something like you!",
            RAGE = "I think the pendulum just swung in his favor...",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Yuck. They smell like decay.",
            BURNT = "Now they smell like burnt decay.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "I wonder how it got so big? Rather, I wonder what it's been feeding on...",
            BLOOM = "Don't you dare get any of those spores on me!",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "I never did like mushrooms.",
            BLOOM = "Ugh, it's trying to grow more mushrooms.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "I'm going to trip over one of these if I'm not careful.",
            BLOOM = "Is it spore season again?",
        },
        MUSHTREE_TALL_WEBBED = "A particularly bad mushroom.",
        SPORE_TALL =
        {
            GENERIC = "They're looking for a place to latch onto.",
            HELD = "I hope it doesn't start growing in there.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "At least they brighten things up a bit.",
            HELD = "I hope it doesn't start growing in there.",
        },
        SPORE_SMALL =
        {
            GENERIC = "Float along now.",
            HELD = "I hope it doesn't start growing in there.",
        },
        RABBITHOUSE =
        {
            GENERIC = "These carrots stuff themselves full of rabbits.",
            BURNT = "Something smells good!",
        },
        SLURTLE = "How do they stand being so slow?",
        SLURTLE_SHELLPIECES = "A handful of shattered shell bits.",
        SLURTLEHAT = "As long as it protects me, I don't care what it looks like.",
        SLURTLEHOLE = "Strange. Anyway, moving on...",
        SLURTLESLIME = "Oh botheration, I think I got some on the bottom of my shoe...",
        SNURTLE = "It's just as slow as the other kind.",
        SPIDER_HIDER = "Why don't you just skitter around the other way?",
        SPIDER_SPITTER = "Leave me alone!",
        SPIDERHOLE = "I can hear them skittering inside...",
        SPIDERHOLE_ROCK = "I can hear them skittering inside...",
        STALAGMITE = "You've seen one rock, you've seen them all.",
        STALAGMITE_TALL = "Wow, amazing. Let's keep moving shall we?",

        TURF_CARPETFLOOR = "I've missed carpet...",
        TURF_CHECKERFLOOR = "Why am I wasting time staring at the ground?",
        TURF_DIRT = "Why am I wasting time staring at the ground?",
        TURF_FOREST = "Why am I wasting time staring at the ground?",
        TURF_GRASS = "Why am I wasting time staring at the ground?",
        TURF_MARSH = "Why am I wasting time staring at the ground?",
        TURF_METEOR = "Slightly more interesting to look at, but still just ground.",
        TURF_PEBBLEBEACH = "Why am I wasting time staring at the ground?",
        TURF_ROAD = "A road to where, exactly?",
        TURF_ROCKY = "Why am I wasting time staring at the ground?",
        TURF_SAVANNA = "Why am I wasting time staring at the ground?",
        TURF_WOODFLOOR = "I missed the comforting creak of floorboards beneath my feet.",

		TURF_CAVE="Why am I wasting time staring at the ground?",
		TURF_FUNGUS="Why am I wasting time staring at the ground?",
		TURF_FUNGUS_MOON = "Why am I wasting time staring at the ground?",
		TURF_ARCHIVE = "Slightly more interesting to look at, but still just ground.",
		TURF_SINKHOLE="Why am I wasting time staring at the ground?",
		TURF_UNDERROCK="Why am I wasting time staring at the ground?",
		TURF_MUD="Why am I wasting time staring at the ground?",

		TURF_DECIDUOUS = "Why am I wasting time staring at the ground?",
		TURF_SANDY = "Why am I wasting time staring at the ground?",
		TURF_BADLANDS = "Why am I wasting time staring at the ground?",
		TURF_DESERTDIRT = "Why am I wasting time staring at the ground?",
		TURF_FUNGUS_GREEN = "Why am I wasting time staring at the ground?",
		TURF_FUNGUS_RED = "Why am I wasting time staring at the ground?",
		TURF_DRAGONFLY = "This might actually be useful.",

        TURF_SHELLBEACH = "Why am I wasting time staring at the ground?",

		POWCAKE = "This never ends well.",
        CAVE_ENTRANCE = "I never was good at leaving well enough alone.",
        CAVE_ENTRANCE_RUINS = "Someone probably plugged it for a reason. I wonder what it was?",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Well, this isn't working.",
            OPEN = "Nothing ventured, nothing gained. Famous last words...",
            FULL = "Finish up in there, I don't have all day to wait!",
        },
        CAVE_EXIT =
        {
            GENERIC = "Looks like I'm stuck down here for the time being.",
            OPEN = "That's enough of this place!",
            FULL = "Would someone please move? You're blocking the exit!",
        },

		MAXWELLPHONOGRAPH = "So that's where the music was coming from.",--single player
		BOOMERANG = "I think I remember how to use this... yes, it's coming back to me!",
		PIGGUARD = "He looks particularly unpleasant.",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Poor thing. Her time came too soon.",
                "Poor thing. Her time came too soon.",
            },
            LEVEL2 =
            {
                "Poor thing. Her time came too soon.",
                "Poor thing. Her time came too soon.",
            },
            LEVEL3 =
            {
                "Poor thing. Her time came too soon.",
                "Poor thing. Her time came too soon.",
            },
		},
		ADVENTURE_PORTAL = "What's the worst that could happen?",
		AMULET = "I'll breathe easier knowing I have a backup plan.",
		ANIMAL_TRACK = "Something went that way... hopefully something tasty.",
		ARMORGRASS = "Isn't there anything a bit more sturdy?",
		ARMORMARBLE = "Well it's definitely sturdy, but why does it have to be so heavy?!",
		ARMORWOOD = "Good enough for now.",
		ARMOR_SANITY = "Shadow magic is just a tool after all, I can use it to my advantage.",
		ASH =
		{
			GENERIC = "What a mess.",
			REMAINS_GLOMMERFLOWER = "It couldn't withstand the trip.",
			REMAINS_EYE_BONE = "It couldn't withstand the trip.",
			REMAINS_THINGIE = "Oh. I don't even remember what that was.",
		},
		AXE = "I'm used to using more delicate tools.",
		BABYBEEFALO =
		{
			GENERIC = "So young, so full of life.",
		    SLEEPING = "Who has time to sleep?",
        },
        BUNDLE = "Bundled up for quick and efficient carrying.",
        BUNDLEWRAP = "It'll keep my things safe from the ravages of time.",
		BACKPACK = "I could always use the extra pocket space.",
		BACONEGGS = "Who has time to sit and eat breakfast?",
		BANDAGE = "I just need a little time and I'll be right as rain.",
		BASALT = "That's too strong to break through!", --removed
		BEARDHAIR = "I know it's the wilderness, but does he have to leave whiskers everywhere?",
		BEARGER = "All the worst parts of a bear and a badger rolled into one.",
		BEARGERVEST = "It reminds me of that time I was almost eaten by a bearger, but it's cozy.",
		ICEPACK = "It'll give my food a longer lifespan.",
		BEARGER_FUR = "It was either him or me.",
		BEDROLL_STRAW = "That doesn't look comfortable at all.",
		BEEQUEEN = "This was a terrible idea!",
		BEEQUEENHIVE =
		{
			GENERIC = "I'm done messing around with beehives.",
			GROWING = "Has it grown since I last saw it?",
		},
        BEEQUEENHIVEGROWN = "This is giving me a bad feeling...",
        BEEGUARD = "If only I had a little army that would protect me this fiercely!",
        HIVEHAT = "How delightfully strange!",
        MINISIGN =
        {
            GENERIC = "Someone obviously thought it was important enough to put on a sign.",
            UNDRAWN = "Maybe I'll just draw something quick.",
        },
        MINISIGN_ITEM = "I'd better put it somewhere.",
		BEE =
		{
			GENERIC = "It's thinking about stinging me, I can see it in its beady eyes.",
			HELD = "It seemed like a good idea at the time.",
		},
		BEEBOX =
		{
			READY = "Finally!",
			FULLHONEY = "Finally!",
			GENERIC = "I thought I heard some buzzing coming from over here.",
			NOHONEY = "Not even a drop of honey inside.",
			SOMEHONEY = "Why does honey take so long to make?",
			BURNT = "It looks like its honey making days are behind it.",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "What am I going to do with all these mushrooms?",
			LOTS = "The mushrooms are multiplying.",
			SOME = "Oh good... mushrooms.",
			EMPTY = "I'm surprised there's no mushrooms growing out of this rotten log.",
			ROTTEN = "It's well past its prime.",
			BURNT = "In the end, it made for a nice little campfire.",
			SNOWCOVERED = "I think it's frozen solid.",
		},
		BEEFALO =
		{
			FOLLOWER = "It took long enough, but we're finally getting along.",
			GENERIC = "Not exactly majestic, are they?",
			NAKED = "Sorry, I needed that fur.",
			SLEEPING = "Look at him, snoring away precious hours!",
            --Domesticated states:
            DOMESTICATED = "We've come to an understanding.",
            ORNERY = "I don't like the look on his face...",
            RIDER = "With his help, I'll shave precious minutes off my traveling time!",
            PUDGY = "He's gotten a little soft around the edges.",
            MYPARTNER = "He seems to like me.",
		},

		BEEFALOHAT = "I kind of imagined a fur hat would feel fancier.",
		BEEFALOWOOL = "The beefalo will grow it back.",
		BEEHAT = "I like having a layer of netting between the bees and my face.",
        BEESWAX = "If only I knew how to make candles.",
		BEEHIVE = "I'm sure the bees are working like clockwork in there.",
		BEEMINE = "You come after me, you get the bees!",
		BEEMINE_MAXWELL = "Bottled mosquito rage!",--removed
		BERRIES = "These will keep me going a while longer.",
		BERRIES_COOKED = "Well, now they're kind of a hot mush...",
        BERRIES_JUICY = "Their time is fleeting, and they taste all the sweeter for it.",
        BERRIES_JUICY_COOKED = "That turned out better than I expected.",
		BERRYBUSH =
		{
			BARREN = "It needs something to get it growing again.",
			WITHERED = "Everything is withering away in this heat.",
			GENERIC = "Aha! A ready supply of food!",
			PICKED = "Why do berries take so long to grow back?",
			DISEASED = "It looks pretty sick.",--removed
			DISEASING = "Err, something's not right.",--removed
			BURNING = "That's not good.",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "What do berry bushes need to grow again?",
			WITHERED = "Oh, it's so sad!",
			GENERIC = "I can hear my stomach growling, and those berries look so tasty...",
			PICKED = "Berries grow so frustratingly slow!",
			DISEASED = "It looks pretty sick.",--removed
			DISEASING = "Err, something's not right.",--removed
			BURNING = "That's not good.",
		},
		BIGFOOT = "That is one biiig foot.",--removed
		BIRDCAGE =
		{
			GENERIC = "All it needs now is a little cuckoo bird.",
			OCCUPIED = "Not a cuckoo, but close enough.",
			SLEEPING = "You could be spending this time laying eggs!",
			HUNGRY = "Is it feeding time?",
			STARVING = "Oh botheration, I forgot to feed you again, didn't I?",
			DEAD = "It was... probably just his time.",
			SKELETON = "Oh botheration, I forgot all about him!",
		},
		BIRDTRAP = "Thankfully, birds are stupid.",
		CAVE_BANANA_BURNT = "It's fine! Just scrape off the burnt edges!",
		BIRD_EGG = "What, you egg?",
		BIRD_EGG_COOKED = "Whenever I make eggs they end up either undercooked or burnt.",
		BISHOP = "What an irresponsible use of clockwork!",
		BLOWDART_FIRE = "This is playing with fire...",
		BLOWDART_SLEEP = "This should help me avoid some conflict.",
		BLOWDART_PIPE = "I like a weapon you can shoot from far away. Preferably while running.",
		BLOWDART_YELLOW = "That'll give them a shock!",
		BLUEAMULET = "Just looking at it chills me to the bone.",
		BLUEGEM = "Why do people say things are as blue as the sea? The sea isn't very blue at all!",
		BLUEPRINT =
		{
            COMMON = "This looks interesting.",
            RARE = "Oooh, this looks very interesting!",
        },
        SKETCH = "An art project? Do I really have time for that?",
		BLUE_CAP = "It's... probably edible. If I'm desperate.",
		BLUE_CAP_COOKED = "I think I made it worse.",
		BLUE_MUSHROOM =
		{
			GENERIC = "A blue mushroom. Moving on.",
			INGROUND = "Something or other tucked in the ground.",
			PICKED = "No sense waiting around for it to grow back.",
		},
		BOARDS = "I'm already bored of looking at them.",
		BONESHARD = "Whatever these bones belonged to is lost to time.",
		BONESTEW = "Was leaving the bone in really necessary?",
		BUGNET = "It'll be faster than trying to catch them with my hands.",
		BUSHHAT = "Hiding is always preferable to fighting.",
		BUTTER = "If only I had some tea and toast.",
		BUTTERFLY =
		{
			GENERIC = "Don't go causing any tornadoes!",
			HELD = "Crisis averted.",
		},
		BUTTERFLYMUFFIN = "It has a subtle taste, light and fleeting.",
		BUTTERFLYWINGS = "Careful with those!",
		BUZZARD = "You're wasting your time following me, buzzard.",

		SHADOWDIGGER = "Those things make me nervous...",

		CACTUS =
		{
			GENERIC = "I wonder if it's really worth the bother.",
			PICKED = "Now to pick out all the spines. What a tedious vegetable.",
		},
		CACTUS_MEAT_COOKED = "Finally, I can eat it!",
		CACTUS_MEAT = "Now to pick out all the spines. What a tedious vegetable.",
		CACTUS_FLOWER = "I'm not stopping to smell it.",

		COLDFIRE =
		{
			EMBERS = "I need to give it something to burn, quickly!",
			GENERIC = "It keeps the shadows at bay.",
			HIGH = "Oh botheration, I got carried away with the kindling!",
			LOW = "It needs more to burn if I want it to last.",
			NORMAL = "That feels better.",
			OUT = "That was nice while it lasted.",
		},
		CAMPFIRE =
		{
			EMBERS = "I need to give it something to burn, quickly!",
			GENERIC = "It keeps the shadows at bay.",
			HIGH = "Oh botheration, I got carried away with the kindling!",
			LOW = "It needs more to burn if I want it to last.",
			NORMAL = "That feels better.",
			OUT = "That was nice while it lasted.",
		},
		CANE = "I don't need a cane yet! I feel fit as a fiddle!",
		CATCOON = "I don't have time to play with you.",
		CATCOONDEN =
		{
			GENERIC = "It looks like something's been living in there for a while.",
			EMPTY = "It's deserted.",
		},
		CATCOONHAT = "Their sacrifice will keep me warm and alive.",
		COONTAIL = "I did what I had to do.",
		CARROT = "From the ground, straight to my mouth.",
		CARROT_COOKED = "I didn't bother seasoning it.",
		CARROT_PLANTED = "I can take it now or come back for it later.",
		CARROT_SEEDS = "Why waste time growing them when I can just eat them now?",
		CARTOGRAPHYDESK =
		{
			GENERIC = "We'll be able to explore a lot faster if we map out where we've already been.",
			BURNING = "That's not good.",
			BURNT = "All that's left are the memories. And some soot.",
		},
		WATERMELON_SEEDS = "Why waste time growing them when I can just eat them now?",
		CAVE_FERN = "How very interesting. Anyway...",
		CHARCOAL = "It burned once and it can burn again.",
        CHESSPIECE_PAWN = "Even a common pawn can become powerful if it's clever enough.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "Who sculpted these?",
            STRUGGLE = "What's happening? It can't be!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "It looks like an oversized chess piece.",
            STRUGGLE = "What's happening? It can't be!",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "I'm guessing there's a big chessboard somewhere nearby.",
            STRUGGLE = "What's happening? It can't be!",
        },
        CHESSPIECE_MUSE = "She went and lost her head.",
        CHESSPIECE_FORMAL = "Looks like he lost his head too.",
        CHESSPIECE_HORNUCOPIA = "I feel like we're being mocked.",
        CHESSPIECE_PIPE = "A still life. How riveting.",
        CHESSPIECE_DEERCLOPS = "I'd be happy if I never have to see it again.",
        CHESSPIECE_BEARGER = "Not one of my fondest memories.",
        CHESSPIECE_MOOSEGOOSE =
        {
            "Oh good, a reminder of another unpleasant encounter.",
        },
        CHESSPIECE_DRAGONFLY = "A monument to a very trying day.",
		CHESSPIECE_MINOTAUR = "This will help remind me not to venture too far in the caves...",
        CHESSPIECE_BUTTERFLY = "Its beauty is captured forever.",
        CHESSPIECE_ANCHOR = "It's not going anywhere. I can look at it later.",
        CHESSPIECE_MOON = "Just look up if you want to see the moon. Actually, better not.",
        CHESSPIECE_CARRAT = "I don't think this really warranted a statue.",
        CHESSPIECE_MALBATROSS = "Why are there so many unpleasant statues?",
        CHESSPIECE_CRABKING = "Oh yes, I remember. I was nearly drowned.",
        CHESSPIECE_TOADSTOOL = "Such fun memories of almost being killed by a giant toad.",
        CHESSPIECE_STALKER = "Still unsettling.",
        CHESSPIECE_KLAUS = "Why would I want to remember him?",
        CHESSPIECE_BEEQUEEN = "This will remind me not to go poking around beehives.",
        CHESSPIECE_ANTLION = "Right. That time I was almost impaled by spikes.",
        CHESSPIECE_BEEFALO = "A real one would be marginally more interesting to look at.",
		CHESSPIECE_KITCOON = "Oh, a precariously tall statue, what could go wrong?",
		CHESSPIECE_CATCOON = "I guess I did have time to play with you after all.",
        CHESSPIECE_GUARDIANPHASE3 = "I hope I won't have to do that again.",
        CHESSPIECE_EYEOFTERROR = "Certainly an eye to behold.",
        CHESSPIECE_TWINSOFTERROR = "I'd be quite happy to never lay eyes on them again.",

        CHESSJUNK1 = "I don't see much in the way of proper clockwork in there.",
        CHESSJUNK2 = "I have a suspicion these were held together with more magic than craftsmanship.",
        CHESSJUNK3 = "Not so much as a pinion or pendulum in sight. Disgraceful!",
		CHESTER = "Yes, yes, you're very cute. Just be careful with my things please.",
		CHESTER_EYEBONE =
		{
			GENERIC = "Do you ever blink?",
			WAITING = "Did it fall asleep?",
		},
		COOKEDMANDRAKE = "It was a matter of survival.",
		COOKEDMEAT = "Alright, I guess it was worth taking the time to cook it.",
		COOKEDMONSTERMEAT = "Somehow cooking it didn't make it much better.",
		COOKEDSMALLMEAT = "It's at least enough to hold me over for the time being.",
		COOKPOT =
		{
			COOKING_LONG = "This is why I hate cooking. Cooking takes forever!",
			COOKING_SHORT = "It has to be almost done by now, right?",
			DONE = "At long last, food!",
			EMPTY = "I guess I'll just... find some seeds to eat or something.",
			BURNT = "Well that's a setback.",
		},
		CORN = "The nice thing about corn is you don't have to fuss with cooking it.",
		CORN_COOKED = "It could really use some butter.",
		CORN_SEEDS = "Why waste time growing them when I can just eat them now?",
        CANARY =
		{
			GENERIC = "Some kind of yellow bird.",
			HELD = "Alright, I'm holding a bird... carefully holding a bird...",
		},
        CANARY_POISONED = "I think I should take that as a sign to leave.",

		CRITTERLAB = "Shadow creatures! No, wait a tick, it's something else...",
        CRITTER_GLOMLING = "Okay, okay. You're very cute.",
        CRITTER_DRAGONLING = "I'm not really a pet person... but I'll make an exception for you.",
		CRITTER_LAMB = "Ohhhh look at that wrinkly little face!",
        CRITTER_PUPPY = "I think he wants belly rubs.",
        CRITTER_KITTEN = "Curious little thing, aren't you?",
        CRITTER_PERDLING = "I'm teaching her to chirp the hour.",
		CRITTER_LUNARMOTHLING = "Time flies, and so do you!",

		CROW =
		{
			GENERIC = "As long as you don't come with any bad omens, we'll get along fine.",
			HELD = "Don't you dare peck at my pocket watches while you're in there!",
		},
		CUTGRASS = "It's about as interesting as you'd imagine cut grass to be.",
		CUTREEDS = "I'll put it in my pocket and use it for something later.",
		CUTSTONE = "Humans have been building with stone blocks for centuries.",
		DEADLYFEAST = "A most potent dish.", --unimplemented
		DEER =
		{
			GENERIC = "It could use a haircut, though I'm not one to talk...",
			ANTLER = "Just keep your antler to yourself!",
		},
        DEER_ANTLER = "This looks like a key piece to a puzzle...",
        DEER_GEMMED = "It's being controlled by that beast!",
		DEERCLOPS = "Do we really have to do this again?",
		DEERCLOPS_EYEBALL = "I'll bet that creature didn't foresee its day ending like this.",
		EYEBRELLAHAT =	"I don't like having eyes on me...",
		DEPLETED_GRASS =
		{
			GENERIC = "It hasn't had enough time to grow back yet.",
		},
        GOGGLESHAT = "I think they go nicely with what I'm wearing.",
        DESERTHAT = "It's no good against the sands of time, unfortunately.",
--fallback to speech_wilson.lua 		DEVTOOL = "It smells of bacon!",
--fallback to speech_wilson.lua 		DEVTOOL_NODEV = "I'm not strong enough to wield it.",
		DIRTPILE = "There's something just irresistibly suspicious about it...",
		DIVININGROD =
		{
			COLD = "The signal is very faint.", --singleplayer
			GENERIC = "It's some kind of homing device.", --singleplayer
			HOT = "This thing's going crazy!", --singleplayer
			WARM = "I'm headed in the right direction.", --singleplayer
			WARMER = "Must be getting pretty close.", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "I wonder what it does.", --singleplayer
			READY = "It looks like it needs a large key.", --singleplayer
			UNLOCKED = "Now the machine can work!", --singleplayer
		},
		DIVININGRODSTART = "That rod looks useful!", --singleplayer
		DRAGONFLY = "Ohhhh I was really hoping to avoid dodging fiery bug monsters today.",
		ARMORDRAGONFLY = "I think it looks better on me than it did on the bug.",
		DRAGON_SCALES = "Fireproof material has served me well in the past. And future, come to think of it.",
		DRAGONFLYCHEST = "Now that I'm not worried about my things burning up, I can worry about everything else.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "If only I could go back in time and undo that decision. If only.",
			GENERIC = "Maybe I'll just take a moment to warm up these old bones of mine.", --no gems
			NORMAL = "Maybe I'll just take a moment to warm up these old bones of mine.", --one gem
			HIGH = "Maybe I'll just take a moment to warm up these old bones of mine.", --two gems
		},

        HUTCH = "You come with your own lamp? I'm impressed!",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Who would leave a fishbowl in a cave? I hope it wasn't me...",
            WAITING = "I think his time might've run out...",
        },
		LAVASPIT =
		{
			HOT = "Hot!!",
			COOL = "I think it's safe to touch. But why would I want to?",
		},
		LAVA_POND = "Not for swimming.",
		LAVAE = "Tsk, she just lets her children run wild!",
		LAVAE_COCOON = "Is it... dead?",
		LAVAE_PET =
		{
			STARVING = "Oh botheration, did I forget to feed you again?",
			HUNGRY = "Is it feeding time again already?",
			CONTENT = "She looks about as happy as a bug covered in lava can look.",
			GENERIC = "She seems to like me for some reason.",
		},
		LAVAE_EGG =
		{
			GENERIC = "It's warm, I think this egg has already been cooked.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "It's cooling off, I don't think that's good.",
			COMFY = "I can almost imagine it smiling.",
		},
		LAVAE_TOOTH = "Well this feels vaguely threatening.",

		DRAGONFRUIT = "Not even close to the weirdest thing I've eaten around here.",
		DRAGONFRUIT_COOKED = "I always forget it looks like that on the inside.",
		DRAGONFRUIT_SEEDS = "Why waste time growing them when I can just eat them now?",
		DRAGONPIE = "When in doubt, bake it into a pie.",
		DRUMSTICK = "I'm in a hurry, it's fine enough as it is.",
		DRUMSTICK_COOKED = "Why do I always forget how much better cooked meat tastes...",
		DUG_BERRYBUSH = "No time for picking, I'll just take it all with me!",
		DUG_BERRYBUSH_JUICY = "It'll save me precious time if I bring this closer to camp.",
		DUG_GRASS = "I can think of a better place for it.",
		DUG_MARSH_BUSH = "I can put it somewhere later. Or maybe even earlier.",
		DUG_SAPLING = "I can put it somewhere later. Or maybe even earlier.",
		DURIAN = "I could never forget a smell like that.",
		DURIAN_COOKED = "It tastes better than it smells, but that's not saying much.",
		DURIAN_SEEDS = "Why waste time growing them when I can just eat them now?",
		EARMUFFSHAT = "If the rest of me freezes, at least my ears will be cozy.",
		EGGPLANT = "It kind of looks like a giant jellybean if you squint.",
		EGGPLANT_COOKED = "Well, the illusion is ruined.",
		EGGPLANT_SEEDS = "Why waste time growing them when I can just eat them now?",

		ENDTABLE =
		{
			BURNT = "That could have gone better.",
			GENERIC = "I make it a rule not to trust fancy tables I find in the wilderness.",
			EMPTY = "Someone forgot to put flowers in the vase. Maybe it was me...",
			WILTED = "Its age is starting to show.",
			FRESHLIGHT = "As good as new.",
			OLDLIGHT = "Oh no, did I forget to replace the bulb again?", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "Maybe that was supposed to happen.",
			BURNT = "Well, what's done is done. For now anyway.",
			CHOPPED = "Its time in this world was cut short.",
			POISON = "Mind your own business, you pesky tree!",
			GENERIC = "It's certainly a tree.",
		},
		ACORN = "In time, it'll be a new tree.",
        ACORN_SAPLING = "Trees are so painfully slow to grow.",
		ACORN_COOKED = "Maybe in another timeline it grew to be a tree.",
		BIRCHNUTDRAKE = "I'll stomp you back into the ground, you overgrown seedling!",
		EVERGREEN =
		{
			BURNING = "Maybe that was supposed to happen.",
			BURNT = "Well, what's done is done. For now anyway.",
			CHOPPED = "Its time in this world was cut short.",
			GENERIC = "Just another tree.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Maybe that was supposed to happen.",
			BURNT = "Well, what's done is done. For now anyway.",
			CHOPPED = "Its time in this world was cut short.",
			GENERIC = "It looks sickly.",
		},
		TWIGGYTREE =
		{
			BURNING = "Maybe that was supposed to happen.",
			BURNT = "Well, what's done is done. For now anyway.",
			CHOPPED = "Its time in this world was cut short.",
			GENERIC = "It's barely a tree, more like a sad collection of sticks.",
			DISEASED = "It looks sick. More so than usual.", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "Good luck, scraggly little tree.",
        TWIGGY_OLD = "It's aged past its prime.",
		TWIGGY_NUT = "The beginnings of a tree.",
		EYEPLANT = "Oh stop staring! Mind your own business!",
		INSPECTSELF = "Ha! Still kicking!",
		FARMPLOT =
		{
			GENERIC = "Gardening is so time consuming.",
			GROWING = "Why can't you just grow faster?",
			NEEDSFERTILIZER = "A bit of fertilizer should speed things up.",
			BURNT = "All that time, wasted!",
		},
		FEATHERHAT = "Oooh, how eclectic!",
		FEATHER_CROW = "A black feather.",
		FEATHER_ROBIN = "A red feather.",
		FEATHER_ROBIN_WINTER = "A white-ish feather.",
		FEATHER_CANARY = "A yellow feather.",
		FEATHERPENCIL = "Good for jotting down notes in a hurry.",
        COOKBOOK = "Cooking is so time consuming, look at all these ingredients and methods!",
		FEM_PUPPET = "She's trapped!", --single player
		FIREFLIES =
		{
			GENERIC = "I'll take some light wherever I can get it.",
			HELD = "It never hurts to carry a little emergency light.",
		},
		FIREHOUND = "I won't meet a fiery end from the likes of you!",
		FIREPIT =
		{
			EMBERS = "I need to give it something to burn, quickly!",
			GENERIC = "It keeps the shadows at bay.",
			HIGH = "Oh botheration, I got carried away with the kindling!",
			LOW = "It needs more to burn if I want it to last.",
			NORMAL = "That feels better.",
			OUT = "I could get it going again in no time at all.",
		},
		COLDFIREPIT =
		{
			EMBERS = "I need to give it something to burn, quickly!",
			GENERIC = "It keeps the shadows at bay.",
			HIGH = "Oh botheration, I got carried away with the kindling!",
			LOW = "It needs more to burn if I want it to last.",
			NORMAL = "That feels better.",
			OUT = "I could get it going again in no time at all.",
		},
		FIRESTAFF = "Better be careful with that, we don't want a repeat of last time.",
		FIRESUPPRESSOR =
		{
			ON = "It's a good thing we prepared for just such an eventuality.",
			OFF = "Ready to fling at a moment's notice.",
			LOWFUEL = "It's starting to wind down.",
		},

		FISH = "That's a fish alright.",
		FISHINGROD = "I don't know if I'm patient enough to be a fisherwoman...",
		FISHSTICKS = "If only I had something to dip them in.",
		FISHTACOS = "I'll get a taco to go!",
		FISH_COOKED = "If only I had a bit of vinegar to go with it.",
		FLINT = "Aha, I've found some flint!",
		FLOWER =
		{
            GENERIC = "I have far more pressing things to do than pick flowers.",
            ROSE = "I don't have time to stop and smell the roses.",
        },
        FLOWER_WITHERED = "Time has claimed it.",
		FLOWERHAT = "Oooh, how whimsical!",
		FLOWER_EVIL = "I don't have time to stop and smell the-- hold on, what's wrong with that one?",
		FOLIAGE = "Am I going to stop and examine every bit of greenery I find?",
		FOOTBALLHAT = "I don't want my brain scrambled, I'm forgetful enough as it is.",
        FOSSIL_PIECE = "These bones are too old for my magic to work. However...",
        FOSSIL_STALKER =
        {
			GENERIC = "It's missing something.",
			FUNNY = "Oh botheration, that doesn't look right at all.",
			COMPLETE = "I did it! Why did I do that again?",
        },
        STALKER = "This was a bad idea. I have regrets.",
        STALKER_ATRIUM = "This was a VERY bad idea.",
        STALKER_MINION = "Ack! Get out of here!",
        THURIBLE = "I don't trust it.",
        ATRIUM_OVERGROWTH = "It probably says something like \"turn back while you can\".",
		FROG =
		{
			DEAD = "He's leapt his last.",
			GENERIC = "Don't even try it frogs, I'm one step ahead of you.",
			SLEEPING = "Look at him sleeping away.",
		},
		FROGGLEBUNWICH = "I've been told it's a local delicacy.",
		FROGLEGS = "The frog isn't kicking anymore.",
		FROGLEGS_COOKED = "At least they stopped twitching.",
		FRUITMEDLEY = "Refreshing.",
		FURTUFT = "Hold on a tick, is my hair falling out?!",
		GEARS = "They're too big for pocket watches, unfortunately.",
		GHOST = "Stay away from me! I won't become like you!",
		GOLDENAXE = "What else will I use gold for around here?",
		GOLDENPICKAXE = "Just don't think about it and it'll make sense.",
		GOLDENPITCHFORK = "I wouldn't want that gold to go to waste.",
		GOLDENSHOVEL = "If I have to spend time digging holes, I can at least be fancy.",
		GOLDNUGGET = "Hmm... would a solid gold pocket watch be too much?",
		GRASS =
		{
			BARREN = "I could probably find something to help speed up its growth.",
			WITHERED = "Nothing will grow in this heat.",
			BURNING = "That's not good...",
			GENERIC = "Grass. You do tend to find a lot of it outside.",
			PICKED = "And now it'll begin the painfully slow process of growing back.",
			DISEASED = "It looks pretty sick.", --unimplemented
			DISEASING = "Err, something's not right.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "Jumpy little things, aren't they? That's probably wise.",
			DISEASED = "It looks really sick.", --unimplemented
		},
		GREEN_CAP = "Ugh, mushrooms...",
		GREEN_CAP_COOKED = "For some reason the thought of eating it isn't so repulsive now.",
		GREEN_MUSHROOM =
		{
			GENERIC = "Just a green mushroom.",
			INGROUND = "It's probably just some kind of mushroom.",
			PICKED = "No sense waiting around for it to grow back.",
		},
		GUNPOWDER = "There's an infinite number of ways this could go very badly.",
		HAMBAT = "Well, the pig had it coming.",
		HAMMER = "Sometimes things need undoing.",
		HEALINGSALVE = "That won't help, what I need is time!",
		HEATROCK =
		{
			FROZEN = "It's ice cold.",
			COLD = "It's cool to the touch.",
			GENERIC = "This isn't an ordinary rock.",
			WARM = "Something to warm up these old bones.",
			HOT = "I almost singed my fingers!",
		},
		HOME = "I've stumbled into someone's home.",
		HOMESIGN =
		{
			GENERIC = "That must be some kind of sign.",
            UNWRITTEN = "There's nothing written here. What an unhelpful sign!",
			BURNT = "That's a bad sign.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "That must be some kind of sign.",
            UNWRITTEN = "There's nothing written here. What an unhelpful sign!",
			BURNT = "That's a bad sign.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "That must be some kind of sign.",
            UNWRITTEN = "There's nothing written here. What an unhelpful sign!",
			BURNT = "That's a bad sign.",
		},
		HONEY = "A little something to satisfy my sweet tooth.",
		HONEYCOMB = "It's much better once you pick out the bees.",
		HONEYHAM = "You can't go wrong dousing something in honey.",
		HONEYNUGGETS = "The dipping sauce is my favorite part.",
		HORN = "It belonged to a beefalo in the past.",
		HOUND = "Stay away! I refuse to be eaten by the likes of you!",
		HOUNDCORPSE =
		{
			GENERIC = "Ugh! I don't want to look at it!",
			BURNING = "It was the only way.",
			REVIVING = "I don't like it when THEY do it.",
		},
		HOUNDBONE = "Old bones. Let's not dwell on them.",
		HOUNDMOUND = "Ugh, a dwelling made of old bones!",
		ICEBOX = "I'm all for making things last longer.",
		ICEHAT = "Simple and effective.",
		ICEHOUND = "What did I ever do to you?!",
		INSANITYROCK =
		{
			ACTIVE = "This stinks of shadow magic shenanigans.",
			INACTIVE = "That looks awfully suspect.",
		},
		JAMMYPRESERVES = "A jar! That's what I forgot!",

		KABOBS = "No need for a plate or utensils, just grab it and go!",
		KILLERBEE =
		{
			GENERIC = "I won't be killed by the likes of you, bee!",
			HELD = "I'm not quite sure what my plan is here.",
		},
		KNIGHT = "Clockwork and I usually get along just fine...",
		KOALEFANT_SUMMER = "It's in the spring of its life.",
		KOALEFANT_WINTER = "It's grown a warm winter coat.",
		KRAMPUS = "He really puts a damper on this time of year.",
		KRAMPUS_SACK = "For me? You shouldn't have!",
		LEIF = "Even the trees are out to get me!",
		LEIF_SPARSE = "Even the trees are out to get me!",
		LIGHTER  = "Oh the havoc you've wreaked across timelines...",
		LIGHTNING_ROD =
		{
			CHARGED = "Yep, the lightning rod was a good idea.",
			GENERIC = "Just in case the sky starts getting any funny ideas.",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "Come here you old goat!",
			CHARGED = "What happened to you? You look a mess!",
		},
		LIGHTNINGGOATHORN = "Twisty, like time itself.",
		GOATMILK = "The flavor is indescribable.",
		LITTLE_WALRUS = "Ah, youth. Enjoy it while you can.",
		LIVINGLOG = "This log is a lot livelier than it should be.",
		LOG =
		{
			BURNING = "That seems like a good use for a log.",
			GENERIC = "It came from a tree, as you'd expect.",
		},
		LUCY = "\"Lucy\" was it? Oh botheration, now he's got ME talking to it!",
		LUREPLANT = "I'm not falling for that old trick!",
		LUREPLANTBULB = "It's unpleasantly squishy...",
		MALE_PUPPET = "He's trapped!", --single player

		MANDRAKE_ACTIVE = "You can stop chiming in any time!",
		MANDRAKE_PLANTED = "What is that, a turnip?",
		MANDRAKE = "Oh, I can't bear to look at it...",

        MANDRAKESOUP = "Maybe in another timeline we won't have to meet this way.",
        MANDRAKE_COOKED = "It's just a roasted vegetable, it's just a roasted vegetable...",
        MAPSCROLL = "It's not a map yet, but it will be in the future.",
        MARBLE = "A timeless building material.",
        MARBLEBEAN = "That bean looks fossilized.",
        MARBLEBEAN_SAPLING = "Are you supposed to water marble to make it grow?",
        MARBLESHRUB = "What a nicely sculpted topiary.",
        MARBLEPILLAR = "Whatever building it used to be a part of has been lost to time.",
        MARBLETREE = "What a delightfully odd tree.",
        MARSH_BUSH =
        {
			BURNT = "There's always something to be learned from mistakes.",
            BURNING = "That fire certainly isn't wasting any time!",
            GENERIC = "Calling it a bush is quite charitable.",
            PICKED = "That wasn't one of my smarter moments.",
        },
        BURNT_MARSH_BUSH = "Erased from the timeline.",
        MARSH_PLANT = "I can't stop for every bit of greenery I see.",
        MARSH_TREE =
        {
            BURNING = "It's burning away.",
            BURNT = "It was an ugly tree anyway.",
            CHOPPED = "Cut down in its prime.",
            GENERIC = "What a gnarled old tree.",
        },
        MAXWELL = "I hate that guy.",--single player
        MAXWELLHEAD = "I can see into his pores.",--removed
        MAXWELLLIGHT = "I wonder how they work.",--single player
        MAXWELLLOCK = "Looks almost like a key hole.",--single player
        MAXWELLTHRONE = "That doesn't look very comfortable.",--single player
        MEAT = "Well, a little raw meat never hurt anybody.",
        MEATBALLS = "Meat in a ball, quick and to the point.",
        MEATRACK =
        {
            DONE = "It's done! Finally!!",
            DRYING = "I'll be old and grey before it's done...",
            DRYINGINRAIN = "The weather is not cooperating.",
            GENERIC = "A horribly time consuming way to make meat last longer.",
            BURNT = "I spent so much time on that!!",
            DONE_NOTMEAT = "I think it's been aged enough.",
            DRYING_NOTMEAT = "It's like watching paint dry.",
            DRYINGINRAIN_NOTMEAT = "This isn't helping.",
        },
        MEAT_DRIED = "An old, tough piece of meat.",
        MERM = "You run along now, pay me no mind.",
        MERMHEAD =
        {
            GENERIC = "I wonder how long they've been at war.",
            BURNT = "Oh, that is vile.",
        },
        MERMHOUSE =
        {
            GENERIC = "Time has taken its toll on this house.",
            BURNT = "One moment it's there, the next it's gone.",
        },
        MINERHAT = "Quite an improvement on the classic handheld lantern.",
        MONKEY = "They're up to their old tricks.",
        MONKEYBARREL = "At least they make it easy to remember who lives here.",
        MONSTERLASAGNA = "Maybe I'm not so hungry after all...",
        FLOWERSALAD = "What a lovely bowl of yard clippings.",
        ICECREAM = "Alright, maybe just a bowl or two.",
        WATERMELONICLE = "It tastes like a frozen summer day.",
        TRAILMIX = "I prefer the version that has little bits of candy in it...",
        HOTCHILI = "Hoooo... I always forget just how spicy it is.",
        GUACAMOLE = "Guacamole, guac-guac-amole!",
        MONSTERMEAT = "If I ever want to poison myself with rancid meat, I'll be sure to try it.",
        MONSTERMEAT_DRIED = "All the life's dried out of it.",
        MOOSE = "I could never forget a face like that.",
        MOOSE_NESTING_GROUND = "Something's telling me I should tread carefully around here.",
        MOOSEEGG = "A brand new lifetime getting ready to start.",
        MOSSLING = "They're cute NOW...",
        FEATHERFAN = "I've never seen a feather so big! Or have I...",
        MINIFAN = "You're never too old for a bit of fun!",
        GOOSE_FEATHER = "I'm sure I'll find a use for it sooner or later.",
        STAFF_TORNADO = "Oh botheration, I thought it was a compass.",
        MOSQUITO =
        {
            GENERIC = "It's trying to drain the life right out of me!",
            HELD = "Serves you right!",
        },
        MOSQUITOSACK = "I think I might be sick...",
        MOUND =
        {
            DUG = "It's not like they were going to use any of that stuff.",
            GENERIC = "You'll never catch me in one of those.",
        },
        NIGHTLIGHT = "This feels like a trick.",
        NIGHTMAREFUEL = "A necessary evil.",
        NIGHTSWORD = "It's just a tool after all, why shouldn't I use it?",
        NITRE = "A rock of some sort.",
        ONEMANBAND = "I can play all these instruments at once, what a time saver!",
        OASISLAKE =
		{
			GENERIC = "Water! Finally!",
			EMPTY = "There might've been water here once... or maybe there will be.",
		},
        PANDORASCHEST = "What's the harm in taking an itty-bitty peek?",
        PANFLUTE = "I haven't spent much time practicing...",
        PAPYRUS = "I should really write things down before I forget them...",
        WAXPAPER = "With this, I can make time slow down for my food too!",
        PENGUIN = "Is it Winter again already?",
        PERD = "That bird's too quick!",
        PEROGIES = "Little pockets of food.",
        PETALS = "They wither away so quickly.",
        PETALS_EVIL = "Picking them seemed like a good idea at the time...",
        PHLEGM = "Ugh, even time doesn't want to touch it.",
        PICKAXE = "The quickest way to break stone.",
        PIGGYBACK = "Do I really want to lug this thing around?",
        PIGHEAD =
        {
            GENERIC = "Well that's not alarming at all.",
            BURNT = "It somehow managed to become even more dead.",
        },
        PIGHOUSE =
        {
            FULL = "They're awfully snobbish for a bunch of pigs.",
            GENERIC = "All this time and not once have I been invited in.",
            LIGHTSOUT = "You horrible pigs! You could at least leave your lights on!",
            BURNT = "Gone in an instant.",
        },
        PIGKING = "He can be reasonable enough once you get to know him.",
        PIGMAN =
        {
            DEAD = "His time ran out.",
            FOLLOWER = "Well, he's friendly enough for now.",
            GENERIC = "Carry on, pig.",
            GUARD = "It might be best to avoid him.",
            WEREPIG = "I hate it when they get like this!",
        },
        PIGSKIN = "What a sad end.",
        PIGTENT = "I don't want to spend too much time in it.",
        PIGTORCH = "Maybe those pigs are brighter than I give them credit for.",
        PINECONE = "The beginnings of a tree.",
        PINECONE_SAPLING = "I think it's growing slowly on purpose, just to annoy me.",
        LUMPY_SAPLING = "It seems determined to survive.",
        PITCHFORK = "I'm used to working with much smaller tools.",
        PLANTMEAT = "If I wasn't so hungry, I might have second thoughts.",
        PLANTMEAT_COOKED = "If you close your eyes it tastes much better.",
        PLANT_NORMAL =
        {
            GENERIC = "It's definitely a plant.",
            GROWING = "Grow faster! I have things to do!",
            READY = "Finally!",
            WITHERED = "Did I forget to water it again?",
        },
        POMEGRANATE = "Who wants to spend time picking out every individual seed?",
        POMEGRANATE_COOKED = "It seemed like a better idea in my head.",
        POMEGRANATE_SEEDS = "Why waste time growing them when I can just eat them now?",
        POND = "Has that pond always been there?",
        POOP = "That's one healthy bowel movement.",
        FERTILIZER = "Manure, conveniently stored in a bucket.",
        PUMPKIN = "A pumpkin that size should keep me fed for a while.",
        PUMPKINCOOKIE = "I can never turn down a cookie.",
        PUMPKIN_COOKED = "I don't know why I bothered cooking it.",
        PUMPKIN_LANTERN = "It's honestly one of the least spooky things around here.",
        PUMPKIN_SEEDS = "Why waste time growing them when I can just eat them now?",
        PURPLEAMULET = "Keep that thing away from me!",
        PURPLEGEM = "This could be useful.",
        RABBIT =
        {
            GENERIC = "A rabbit... or is it?",
            HELD = "What am I supposed to do with it now?",
        },
        RABBITHOLE =
        {
            GENERIC = "I'd better watch my step, wouldn't want to fall down a rabbit hole.",
            SPRING = "No more rabbit hole, for now.",
        },
        RAINOMETER =
        {
            GENERIC = "Pfft. I could just check the weather myself if I felt like it.",
            BURNT = "Maybe that was meant to happen.",
        },
        RAINCOAT = "It keeps me warm and dry.",
        RAINHAT = "What a charming rain bonnet!",
        RATATOUILLE = "That's a fun name for a bunch of chopped vegetables.",
        RAZOR = "This seems dangerous.",
        REDGEM = "It's amazing how many gems you can find just lying around here.",
        RED_CAP = "I'm pretty sure red is the bad color.",
        RED_CAP_COOKED = "This seems like a bad idea.",
        RED_MUSHROOM =
        {
            GENERIC = "Just another mushroom.",
            INGROUND = "It's just something or other.",
            PICKED = "Maybe it's best if it doesn't grow back.",
        },
        REEDS =
        {
            BURNING = "That's not good...",
            GENERIC = "I'm definitely in a marsh.",
            PICKED = "No sense in waiting around for it to grow back.",
        },
        RELIC = "People back then weren't all that different from us.",
        RUINS_RUBBLE = "Whatever it was has been lost to time.",
        RUBBLE = "Time has broken it down.",
        RESEARCHLAB =
        {
            GENERIC = "I really want to know what makes it tick...",
            BURNT = "I was too late to save it.",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "It turns out that science is a lot easier than I thought!",
            BURNT = "Oh drat.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "Shadow magic's just a tool, like anything else.",
            BURNT = "I'll have to be more careful next time.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "If it works, it works.",
            BURNT = "Now I'll have to spend time making another one...",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "I'm all for taking precautions, but does it have to look like that?",
            BURNT = "I'm trying not to take that as a bad omen.",
        },
        RESURRECTIONSTONE = "Hopefully I'll never have to use it.",
        ROBIN =
        {
            GENERIC = "Some kind of red bird.",
            HELD = "Well, it's in my pocket. Now what?",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Some kind of blueish white bird.",
            HELD = "Don't peck on my pocket watches while you're in there!",
        },
        ROBOT_PUPPET = "They're trapped!", --single player
        ROCK_LIGHT =
        {
            GENERIC = "A crusted over lava pit.",--removed
            OUT = "Looks fragile.",--removed
            LOW = "The lava's crusting over.",--removed
            NORMAL = "Nice and comfy.",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "I bet I could lift it. It... might take a while though.",
            RAISED = "I can't quite reach it.",
        },
        ROCK = "Ooooh a boulder, how unexpected.",
        PETRIFIED_TREE = "Frozen in time.",
        ROCK_PETRIFIED_TREE = "Frozen in time.",
        ROCK_PETRIFIED_TREE_OLD = "Frozen in time.",
        ROCK_ICE =
        {
            GENERIC = "A frozen chunk of future water.",
            MELTED = "A puddle of potential ice.",
        },
        ROCK_ICE_MELTED = "A puddle of potential ice.",
        ICE = "A frozen chunk of future water.",
        ROCKS = "A handful of stones, absolutely thrilling!",
        ROOK = "I'm not convinced that's proper clockwork.",
        ROPE = "I'm sure I'll find some use for it sooner or later.",
        ROTTENEGG = "It must've been the last one out.",
        ROYAL_JELLY = "Victory is sweet.",
        JELLYBEAN = "I like to keep a bit of candy in my pocket at all times.",
        SADDLE_BASIC = "I've got a saddle, now I just need an animal to ride...",
        SADDLE_RACE = "This should help my beefalo pick up the pace.",
        SADDLE_WAR = "Very imposing.",
        SADDLEHORN = "I'll finally be able to take the saddle off that poor beast!",
        SALTLICK = "Imagine getting so distracted by a chunk of salt.",
        BRUSH = "Caring for animals is so time consuming!",
		SANITYROCK =
		{
			ACTIVE = "What? I could have sworn it was shorter...",
			INACTIVE = "Hmm. I remembered it being taller...",
		},
		SAPLING =
		{
			BURNING = "That's not good...",
			WITHERED = "It won't survive long in this heat.",
			GENERIC = "For some reason, these ones don't seem to grow any bigger.",
			PICKED = "Now begins the painfully slow process of growing back.",
			DISEASED = "It looks pretty sick.", --removed
			DISEASING = "Err, something's not right.", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "I think our definition of \"friendly\" differs somewhat.",
			BURNING = "This might end up being an improvement.",
			BURNT = "I take back what I said, it's much worse this way.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "I've got more pressing things to do than arts and crafts.",
			BLOCK = "Chipping away at stone is not my idea of a good time.",
			SCULPTURE = "I don't even want to think about how much time was spent making it.",
			BURNT = "Well, time to move on.",
   		},
        SCULPTURE_KNIGHTHEAD = "Strange...",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "I can't quite tell what it's supposed to be.",
			UNCOVERED = "It's a little better, but there's something missing...",
			FINISHED = "Why did I spend so much time on this?",
			READY = "Did you hear that? It's like there's something scratching inside...",
		},
        SCULPTURE_BISHOPHEAD = "What is this doing way out here?",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "Strange... I don't think it's as old as it looks.",
			UNCOVERED = "Either the sculptor forgot something, or a piece has been removed.",
			FINISHED = "I can't believe I spent so much time on reuniting a couple pieces of marble.",
			READY = "Did you hear that? It's like there's something scratching inside...",
		},
        SCULPTURE_ROOKNOSE = "Where did this come from?",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "I'm not sure what to make of it.",
			UNCOVERED = "It still doesn't look right.",
			FINISHED = "It took me ages to put you together, at least look pleased about it!",
			READY = "Did you hear that? It's like there's something scratching inside...",
		},
        GARGOYLE_HOUND = "The attention to detail is incredible!",
        GARGOYLE_WEREPIG = "Something's nagging at the back of my brain... I'm sure it's nothing.",
		SEEDS = "Future plants, or a present snack.",
		SEEDS_COOKED = "I don't know why I bothered cooking them.",
		SEWING_KIT = "Who has patience for sewing?",
		SEWING_TAPE = "Now this is the way to mend clothes, no fussing with needles and thread!",
		SHOVEL = "My clocksmith hands weren't made for this kind of work...",
		SILK = "It's surprisingly durable.",
		SKELETON = "This one's beyond my power to save...",
		SCORCHED_SKELETON = "Their life was snuffed out long ago.",
		SKULLCHEST = "I'm not sure if I want to open it.", --removed
		SMALLBIRD =
		{
			GENERIC = "That's no spring chicken.",
			HUNGRY = "What is it? Do you need to be fed again already?",
			STARVING = "Oh no, I forgot to feed you again didn't I?",
			SLEEPING = "Thank goodness. I can finally do things uninterrupted.",
		},
		SMALLMEAT = "A little meat is better than none.",
		SMALLMEAT_DRIED = "A bite of tough, dry meat.",
		SPAT = "He's a tough old thing.",
		SPEAR = "Don't think I won't use it if I have to!",
		SPEAR_WATHGRITHR = "...I should try to stay on her good side.",
		WATHGRITHRHAT = "It's not historically accurate, but I'll just keep that to myself.",
		SPIDER =
		{
			DEAD = "I like them better this way.",
			GENERIC = "Why don't you just run along? Go do spider things.",
			SLEEPING = "At least it's not causing any trouble.",
		},
		SPIDERDEN = "I'm not in any hurry to tangle with spiders.",
		SPIDEREGGSACK = "I should squish them now, it'll save me the hassle later on...",
		SPIDERGLAND = "That spider left me a thoughtful parting gift.",
		SPIDERHAT = "A lovely reminder of that time I was almost eaten by a giant spider.",
		SPIDERQUEEN = "Just whose idea was it to make the spiders here so big?! I'd like to have a word.",
		SPIDER_WARRIOR =
		{
			DEAD = "I chose my survival over his.",
			GENERIC = "Oh botheration, I hate the stripy ones.",
			SLEEPING = "At least it's not causing any trouble.",
		},
		SPOILED_FOOD = "Food that once was.",
        STAGEHAND =
        {
			AWAKE = "You'll never catch me! I've outsmarted you and your ilk at every turn!",
			HIDING = "I know you're hiding in there.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "I can gawk at them later, they're not going anywhere.",
            TYPE1 = "I don't have much patience for art.",
            TYPE2 = "I've seen it before and I'll probably see it again.",
            TYPE3 = "I'm still not sure who left these here.", --bird bath type statue
        },
		STATUEHARP = "It's curious how they all seem to be broken in the same spot...",
		STATUEMAXWELL = "\"Someone\" had far too much time on his hands...",
		STEELWOOL = "Some things are taken very literally around here.",
		STINGER = "A bee sting that almost was.",
		STRAWHAT = "I could dress up like a farmer, how fun!",
		STUFFEDEGGPLANT = "Vegetables inside and out.",
		SWEATERVEST = "It looks like something a pretentious old professor might wear.",
		REFLECTIVEVEST = "I don't know if I want to be so easy to spot...",
		HAWAIIANSHIRT = "It might be nice to kick back and unwind... for a minute or two.",
		TAFFY = "I'll never forget, baba used to bring these home for us on special occasions.",
		TALLBIRD = "I wonder how they keep their balance.",
		TALLBIRDEGG = "A future bird.",
		TALLBIRDEGG_COOKED = "It tastes like stolen time.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "I shouldn't leave it out in the cold.",
			GENERIC = "Did that crack come from the outside or the inside?",
			HOT = "It's going to be a fried egg soon if I don't cool it down.",
			LONG = "Can you hatch any faster?",
			SHORT = "According to my egg timer, it could hatch any moment now!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "I spot an egg! Although it looks like it was spotted already.",
			PICKED = "Just an empty nest.",
		},
		TEENBIRD =
		{
			GENERIC = "When did you dye your feathers?",
			HUNGRY = "Oh botheration, I bet you're hungry.",
			STARVING = "I think she might actually eat me if I don't feed her soon.",
			SLEEPING = "This is no time for sleeping!",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "With this I can surely pass through space and time!", --single player
			GENERIC = "This appears to be a nexus to another world!", --single player
			LOCKED = "There's still something missing.", --single player
			PARTIAL = "Soon, the invention will be complete!", --single player
		},
		TELEPORTATO_BOX = "This may control the polarity of the whole universe.", --single player
		TELEPORTATO_CRANK = "Tough enough to handle the most intense experiments.", --single player
		TELEPORTATO_POTATO = "This metal potato contains great and fearful power...", --single player
		TELEPORTATO_RING = "A ring that could focus dimensional energies.", --single player
		TELESTAFF = "It's a bit clunky, but it'll do for now.",
		TENT =
		{
			GENERIC = "I guess it wouldn't hurt to take a quick little nap...",
			BURNT = "It looks like nap time is over, permanently.",
		},
		SIESTAHUT =
		{
			GENERIC = "I could stand to spend a moment or two out of the heat.",
			BURNT = "It won't do me much good now.",
		},
		TENTACLE = "I'll be avoiding that.",
		TENTACLESPIKE = "Quite a nasty weapon.",
		TENTACLESPOTS = "Such a nice pattern, if only it wasn't so slimy and disgusting.",
		TENTACLE_PILLAR = "I don't think I should touch that.",
        TENTACLE_PILLAR_HOLE = "There's a whole maze of tunnels down there.",
		TENTACLE_PILLAR_ARM = "Hateful little things!",
		TENTACLE_GARDEN = "Another thing I probably shouldn't touch.",
		TOPHAT = "I'd look like quite the gentlewoman in that!",
		TORCH = "It'll keep the darkness at bay. For a time, at least.",
		TRANSISTOR = "Is this one of those newfangled electric thinga-ma-whoosits?",
		TRAP = "The trap is fine, it's the part afterwards that makes me sad...",
		TRAP_TEETH = "That would be a painful misstep to make.",
		TRAP_TEETH_MAXWELL = "I'll want to avoid stepping on that!", --single player
		TREASURECHEST =
		{
			GENERIC = "Less cluttering up my pockets means less cluttering up my mind.",
			BURNT = "I probably should have seen that coming.",
		},
		TREASURECHEST_TRAP = "Did I leave this here? Hm...",
		SACRED_CHEST =
		{
			GENERIC = "An ancient puzzle! How exciting!",
			LOCKED = "You won't stay locked for long.",
		},
		TREECLUMP = "It's almost like someone is trying to prevent me from going somewhere.", --removed

		TRINKET_1 = "They look like candy that was left in someone's pocket for too long.", --Melted Marbles
		TRINKET_2 = "I can't get a single note out of it.", --Fake Kazoo
		TRINKET_3 = "I'm not going to bother trying to untangle it.", --Gord's Knot
		TRINKET_4 = "Oooh, I do love a good knickknack.", --Gnome
		TRINKET_5 = "How futuristic!", --Toy Rocketship
		TRINKET_6 = "One of those electrical doo-hickeys. I'll stick to my gears and pendulums.", --Frazzled Wires
		TRINKET_7 = "I have no time for distractions.", --Ball and Cup
		TRINKET_8 = "You never know what might come in handy later.", --Rubber Bung
		TRINKET_9 = "Each one is charmingly unique.", --Mismatched Buttons
		TRINKET_10 = "Thankfully my teeth seem to have stayed pretty sturdy in my older years.", --Dentures
		TRINKET_11 = "Oh you would look just darling on a shelf next to some porcelain figurines!", --Lying Robot
		TRINKET_12 = "It's stuck in a perpetual state of decay.", --Dessicated Tentacle
		TRINKET_13 = "Oooh, I do love a good knickknack.", --Gnomette
		TRINKET_14 = "It's just for display.", --Leaky Teacup
		TRINKET_15 = "I have no patience for chess, but it looks simple enough.", --Pawn
		TRINKET_16 = "I have no patience for chess, but it looks simple enough.", --Pawn
		TRINKET_17 = "Think about how much time I'll save if I only need to use one utensil!", --Bent Spork
		TRINKET_18 = "Has history taught us nothing?", --Trojan Horse
		TRINKET_19 = "Nobody's perfect.", --Unbalanced Top
		TRINKET_20 = "So this is when it ended up!", --Backscratcher
		TRINKET_21 = "It's seen better days.", --Egg Beater
		TRINKET_22 = "I'm neither a cat nor a knitter. Maybe someone else will want it.", --Frayed Yarn
		TRINKET_23 = "I'll be able to shave a few seconds off my shoe-changing time.", --Shoehorn
		TRINKET_24 = "I'm not much of a cat person.", --Lucky Cat Jar
		TRINKET_25 = "It smells like pine needles. Dead, rotten pine needles.", --Air Unfreshener
		TRINKET_26 = "Something to sip and snack on all at once!", --Potato Cup
		TRINKET_27 = "I would've rather found the coat.", --Coat Hanger
		TRINKET_28 = "It seems like you can't walk too far around here without tripping over a chess piece.", --Rook
        TRINKET_29 = "It seems like you can't walk too far around here without tripping over a chess piece.", --Rook
        TRINKET_30 = "I wonder whatever happened to the rest of the set. Or the players.", --Knight
        TRINKET_31 = "I wonder whatever happened to the rest of the set. Or the players.", --Knight
        TRINKET_32 = "It'll only show you one possible future.", --Cubic Zirconia Ball
        TRINKET_33 = "I keep forgetting it's not real!", --Spider Ring
        TRINKET_34 = "There's no need to be afraid of curses if you're clever enough to outsmart them.", --Monkey Paw
        TRINKET_35 = "Whatever it held, it's gone now.", --Empty Elixir
        TRINKET_36 = "I don't think it's a good idea to put things we find lying around here in our mouths.", --Faux fangs
        TRINKET_37 = "Somewhere there's a vampire having a very bad day.", --Broken Stake
        TRINKET_38 = "It helps me see the way ahead.", -- Binoculars Griftlands trinket
        TRINKET_39 = "I don't think it's from this timeline...", -- Lone Glove Griftlands trinket
        TRINKET_40 = "The needle moves rather sluggishly.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "This is definitely going to contaminate the timeline.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "...But why does it have a mouse head?", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Ah, youth...", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Is that plant still alive?", -- Broken Terrarium ONI trinket
        TRINKET_45 = "It keeps making strange sounds.", -- Odd Radio ONI trinket
        TRINKET_46 = "How did this get here?", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_2  = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_7  = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_10 = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_11 = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_14 = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_18 = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_19 = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_42 = "Oh botheration, I think I've started hallucinating.",
        LOST_TOY_43 = "Oh botheration, I think I've started hallucinating.",

        HALLOWEENCANDY_1 = "An apple improved by a delicious candy coating.",
        HALLOWEENCANDY_2 = "Delicious candied corn to munch on.",
        HALLOWEENCANDY_3 = "Who is trying to pass this ordinary corn cob off as candy?",
        HALLOWEENCANDY_4 = "That'll be something to chew on for a while.",
        HALLOWEENCANDY_5 = "I'll stash some extras in my pocket, I'm sure the children would love some hard candy.",
        HALLOWEENCANDY_6 = "Do you think I was born yesterday?",
        HALLOWEENCANDY_7 = "A little extra fiber never hurt anyone.",
        HALLOWEENCANDY_8 = "This little ghost I like.",
        HALLOWEENCANDY_9 = "Chewy, and only a little wormy.",
        HALLOWEENCANDY_10 = "Something sweet that never goes bad, what's not to love?",
        HALLOWEENCANDY_11 = "Oh alright, I'll take a nibble.",
        HALLOWEENCANDY_12 = "If nobody else wants them I'll happily take them.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "That seems like a self-fulfilling prophecy.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Sweet mixed with spicy!", --Hot Lava pepper candy
        CANDYBAG = "It holds more than I expected, as if it's bigger on the inside...",

		HALLOWEEN_ORNAMENT_1 = "What a gloomy way to celebrate.",
		HALLOWEEN_ORNAMENT_2 = "I guess I could spend a little time decorating.",
		HALLOWEEN_ORNAMENT_3 = "Ugh, I don't want to be reminded of them.",
		HALLOWEEN_ORNAMENT_4 = "I might as well put it up somewhere.",
		HALLOWEEN_ORNAMENT_5 = "It's meant to be displayed on a tree, if I recall.",
		HALLOWEEN_ORNAMENT_6 = "There's so many real ones flying about, it seems a bit redundant.",

		HALLOWEENPOTION_DRINKS_WEAK = "I'm a clocksmith, not a chemist.",
		HALLOWEENPOTION_DRINKS_POTENT = "I can feel the potential radiating out of it.",
        HALLOWEENPOTION_BRAVERY = "Fear keeps you safe, but bravery keeps you going.",
		HALLOWEENPOTION_MOON = "It smells like shifting possibilities.",
		HALLOWEENPOTION_FIRE_FX = "This might have been a frivolous use of my time...",
		MADSCIENCE_LAB = "This is a bit outside my area of expertise...",
		LIVINGTREE_ROOT = "The root inside is particularly lively.",
		LIVINGTREE_SAPLING = "That's starting to look unpleasant.",

        DRAGONHEADHAT = "What's that old saying? Two heads are better than one?",
        DRAGONBODYHAT = "I don't like the thought of being inside a dragon's stomach...",
        DRAGONTAILHAT = "Hmph, who wants to be last?",
        PERDSHRINE =
        {
            GENERIC = "This will be a giant time sink if I'm not careful...",
            EMPTY = "Now, what was the trick with this one?",
            BURNT = "Gone in an instant.",
        },
        REDLANTERN = "Luckily for me, the flame can't seem to reach the paper surrounding it.",
        LUCKY_GOLDNUGGET = "I won't say no to a little extra luck.",
        FIRECRACKERS = "Just in case things around here weren't already exciting enough.",
        PERDFAN = "I don't think it was very lucky for the poor bird.",
        REDPOUCH = "There's something jangling around inside.",
        WARGSHRINE =
        {
            GENERIC = "Well... I guess I have a little time to spare.",
            EMPTY = "Any bright ideas?",
--fallback to speech_wilson.lua             BURNING = "I should make something fun.", --for willow to override
            BURNT = "That's the end of that.",
        },
        CLAYWARG =
        {
        	GENERIC = "Not a statue!!",
        	STATUE = "Thankfully, it's just a statue.",
        },
        CLAYHOUND =
        {
        	GENERIC = "I really hoped it would be a bit more breakable!",
        	STATUE = "Was that a temporal blip, or did that statue just move?",
        },
        HOUNDWHISTLE = "It might be useful if I ever need to train some unruly dogs.",
        CHESSPIECE_CLAYHOUND = "Well, it hasn't sprung to life yet. So far so good.",
        CHESSPIECE_CLAYWARG = "I hope this doesn't come back to bite me.",

		PIGSHRINE =
		{
            GENERIC = "Well... there's probably time to make a few little trinkets.",
            EMPTY = "It's that time of the duodecennial orbital cycle again.",
            BURNT = "It burned away in no time at all.",
		},
		PIG_TOKEN = "Quite a fancy gold buckled belt for a pig!",
		PIG_COIN = "Oooh, I've never hired an assistant before.",
		YOTP_FOOD1 = "I wish it would stop glaring at me like that.",
		YOTP_FOOD2 = "...Maybe someone else will take it.",
		YOTP_FOOD3 = "This will fill me up for a while.",

		PIGELITE1 = "How did I get myself into this?", --BLUE
		PIGELITE2 = "Nice piggy...", --RED
		PIGELITE3 = "Let's just calm down for a minute...", --WHITE
		PIGELITE4 = "Wait, wait, time out!!", --GREEN

		PIGELITEFIGHTER1 = "How did I get myself into this?", --BLUE
		PIGELITEFIGHTER2 = "Nice piggy...", --RED
		PIGELITEFIGHTER3 = "Let's just calm down for a minute...", --WHITE
		PIGELITEFIGHTER4 = "Wait, wait, time out!!", --GREEN

		CARRAT_GHOSTRACER = "Nice try, but you won't fool me.",

        YOTC_CARRAT_RACE_START = "Everything has to start somewhere.",
        YOTC_CARRAT_RACE_CHECKPOINT = "A little milestone.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "I guess the race has to end sometime.",
            BURNT = "That's certainly one way to end a race.",
            I_WON = "I didn't even need to bend time or space to win!",
            SOMEONE_ELSE_WON = "Good job {winner}, but I'll win last time! I mean, next time!",
        },

		YOTC_CARRAT_RACE_START_ITEM = "The sooner I find a place for it, the sooner we can start.",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "I'll find a place for it sooner or later.",
		YOTC_CARRAT_RACE_FINISH_ITEM = "Where the race will come to an end.",

		YOTC_SEEDPACKET = "I guess I should plant them at some point.",
		YOTC_SEEDPACKET_RARE = "They're of a higher quality than the usual seeds.",

		MINIBOATLANTERN = "The ocean could use a bit more light.",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "I suppose there's time to fashion a trinket or two.",
            EMPTY = "Well this helps me narrow down my temporal location.",
            BURNT = "Gone too soon.",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "I wish I could improve my own sense of direction...",
            RAT = "I'm getting dizzy just watching it.",
            BURNT = "Oh botheration, now I'll have to build another!",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "Perfect!",
            RAT = "I wish it could get quicker faster...",
            BURNT = "That's a bit of a setback.",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "I want my carrat to be a quick thinker.",
            RAT = "It looks smarter already!",
            BURNT = "That sure burnt away quickly.",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "I'm starting to question if I'm spending my time wisely...",
            RAT = "It seems to be enjoying itself.",
            BURNT = "Sigh... now I'll have to build a new one from scratch.",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "The preparations are done, now to find a place for it.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "Time to get my carrat up and running.",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "This shouldn't take too long to piece together.",
        YOTC_CARRAT_GYM_REACTION_ITEM = "I hope training my carrat won't take too long.",

        YOTC_CARRAT_SCALE_ITEM = "I'd better start setting it up.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "It measures the weight of experience.",
            CARRAT = "Incredibly average.",
            CARRAT_GOOD = "This one might be a winner!",
            BURNT = "There isn't much left of it.",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "I do love to tinker with new things...",
            EMPTY = "Now what did this need? My memory's a bit fuzzy...",
            BURNT = "It sure burnt away quickly.",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Oh! I almost forgot to bring the beefalo!",
            OCCUPIED = "You'll be the most smartly dressed creature around!",
            BURNT = "Oh botheration, not again.",
        },
        BEEFALO_GROOMER_ITEM = "Did I not set that up already?",

		BISHOP_CHARGE_HIT = "Ack!!",
		TRUNKVEST_SUMMER = "Quite cozy.",
		TRUNKVEST_WINTER = "The hair is just as thick on the inside.",
		TRUNK_COOKED = "You get used to the flavor after a while.",
		TRUNK_SUMMER = "Thoroughly cleaned, I hope.",
		TRUNK_WINTER = "In the interest of time, I didn't bother removing the fur.",
		TUMBLEWEED = "I'm sure it's seen a lot during its travels.",
		TURKEYDINNER = "Oh, that smells good...",
		TWIGS = "Twigs always come in handy sooner or later.",
		UMBRELLA = "A handy little rain napper.",
		GRASS_UMBRELLA = "Quite the afternoonified rain napper, isn't it?",
		UNIMPLEMENTED = "A remnant from a collapsed timeline.",
		WAFFLES = "They're best when drenched in syrup.",
		WALL_HAY =
		{
			GENERIC = "I'm sure it'll fare better than last time.",
			BURNT = "I probably should have seen this coming.",
		},
		WALL_HAY_ITEM = "These walls always seem to catch fire at the most inopportune moments.",
		WALL_STONE = "It's not going anywhere anytime soon.",
		WALL_STONE_ITEM = "Stone is a very tried and true building material.",
		WALL_RUINS = "New and old at the same time... did I just create a paradox?",
		WALL_RUINS_ITEM = "It feels sturdy enough.",
		WALL_WOOD =
		{
			GENERIC = "Not exactly inviting, is it?",
			BURNT = "Next time I'll use something less flammable.",
		},
		WALL_WOOD_ITEM = "The sooner I can get it built, the better I'll feel.",
		WALL_MOONROCK = "I'd like to see anything break through that! Actually no, I wouldn't.",
		WALL_MOONROCK_ITEM = "I feel safer already.",
		FENCE = "An incredibly ordinary wooden fence.",
        FENCE_ITEM = "Didn't I build that already?",
        FENCE_GATE = "An incredibly ordinary wooden gate.",
        FENCE_GATE_ITEM = "If I don't build it now I'll just have to do it later.",
		WALRUS = "He's a mean old thing.",
		WALRUSHAT = "It still smells like walrus.",
		WALRUS_CAMP =
		{
			EMPTY = "They'll be back.",
			GENERIC = "Nobody ever invites me in. I'm starting to take it personally!",
		},
		WALRUS_TUSK = "I should pocket it for future tinkering.",
		WARDROBE =
		{
			GENERIC = "I could always change my look this time around.",
            BURNING = "Are these the \"hot styles\" young people are always talking about?",
			BURNT = "One less distraction, I suppose.",
		},
		WARG = "I guess I was bound to run into you sooner or later.",
        WARGLET = "I could have sworn they were bigger...",
        
		WASPHIVE = "I'd rather not be stung within an inch of my life, thank you.",
		WATERBALLOON = "Don't think I won't throw it!",
		WATERMELON = "Ahh, refreshing!",
		WATERMELON_COOKED = "Cooking it seems wholly unnecessary.",
		WATERMELONHAT = "Believe it or not, it's actually quite practical.",
		WAXWELLJOURNAL = "Hm.",
		WETGOOP = "I never claimed to be good at cooking!",
        WHIP = "This should keep most creatures at bay.",
		WINTERHAT = "What a funny little fuzzy hat. Mind if I try it on?",
		WINTEROMETER =
		{
			GENERIC = "It might be prudent to keep an eye on the temperature.",
			BURNT = "It can't be that hot out!",
		},

        WINTER_TREE =
        {
            BURNT = "I suppose that does happen to trees sometimes.",
            BURNING = "I'll bet it was one of those newfangled electric candles that started it.",
            CANDECORATE = "It's a fully grown pine tree.",
            YOUNG = "A young tree in a little wooden pail.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "It will only accept pine cones, apparently.",
            BURNT = "That puts a damper on the festivities.",
		},
        WINTER_ORNAMENT = "I just can't say no to collecting trinkets.",
        WINTER_ORNAMENTLIGHT = "Is this one of those electric candles I've heard about?",
        WINTER_ORNAMENTBOSS = "Ah. Memories.",
		WINTER_ORNAMENTFORGE = "I must have missed this one.",
		WINTER_ORNAMENTGORGE = "Such a lovely family.",

        WINTER_FOOD1 = "I half expect it to start running at any moment.", --gingerbread cookie
        WINTER_FOOD2 = "It's so hard to stop once you've eaten one.", --sugar cookie
        WINTER_FOOD3 = "Mmm, peppermint!", --candy cane
        WINTER_FOOD4 = "\"Eternal\"? Ha!", --fruitcake
        WINTER_FOOD5 = "I never understood the appeal of making a dessert that looks like a piece of wood.", --yule log cake
        WINTER_FOOD6 = "Alright, maybe just a bit of pudding.", --plum pudding
        WINTER_FOOD7 = "Something warm to sip on.", --apple cider
        WINTER_FOOD8 = "A hot cup of sweetness.", --hot cocoa
        WINTER_FOOD9 = "A nice cold glass of eggnog might do me some good.", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "Oh, don't tell me I'm the one who has to cook...",
			COOKING = "Why must cooking take so much time?",
			ALMOST_DONE_COOKING = "It has to be almost done by now!",
			DISH_READY = "At long last!",
		},
		BERRYSAUCE = "Why bother putting it on something when you can just eat it by itself?",
		BIBINGKA = "Bready and delicious.",
		CABBAGEROLLS = "Meat rolled in cabbage, simple as that.",
		FESTIVEFISH = "I didn't think nutmeg and cinnamon would go so well with fish!",
		GRAVY = "I don't need any turkey to pour it over, just hand me a spoon.",
		LATKES = "Delicious discs of crisp potatoes.",
		LUTEFISK = "This celebration involves a surprising amount of fish.",
		MULLEDDRINK = "It warms you from the inside out.",
		PANETTONE = "Mmmmm, bread.",
		PAVLOVA = "It's crispier than I expected, but not unpleasantly so.",
		PICKLEDHERRING = "It must be some sort of delicacy.",
		POLISHCOOKIE = "I'll just put a few extras in my pocket... don't mind me.",
		PUMPKINPIE = "Why waste time cutting it into slices when I can just eat the whole thing?",
		ROASTTURKEY = "What an enormous turkey leg!",
		STUFFING = "I'm never too full for a little extra stuffing.",
		SWEETPOTATO = "An odd recipe, but I can't say I don't enjoy it.",
		TAMALES = "They're piping hot!",
		TOURTIERE = "This is exactly what I first imagined a mincemeat pie would be.",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "An empty table isn't really much to look at.",
			HAS_FOOD = "A finely set table.",
			WRONG_TYPE = "Oh botheration, what time of year is it again?",
			BURNT = "Dinner might have to wait.",
		},

		GINGERBREADWARG = "I think I've lost my appetite...",
		GINGERBREADHOUSE = "It's so tastefully decorated!",
		GINGERBREADPIG = "Oh, these are the ones that run!",
		CRUMBS = "Poor thing, it's leading us right to its home.",
		WINTERSFEASTFUEL = "I'm not sure I trust that stuff.",

        KLAUS = "Is it that time of year again already?",
        KLAUS_SACK = "At least he left some goodies!",
		KLAUSSACKKEY = "This looks like just the piece I need.",
		WORMHOLE =
		{
			GENERIC = "It's resting, for the moment.",
			OPEN = "Not my preferred way to get around, but it'll do in a pinch.",
		},
		WORMHOLE_LIMITED = "I think I'd rather travel by my own means.",
		ACCOMPLISHMENT_SHRINE = "I want to use it, and I want the world to know that I did.", --single player
		LIVINGTREE = "Oh, what a horrible face it has!",
		ICESTAFF = "It'll freeze anything in its tracks.",
		REVIVER = "A bit of insurance, in the unlikely event my own powers aren't enough.",
		SHADOWHEART = "It's still beating...",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "A mural of an ancient civilization, but something is wrong...",
			LINE_2 = "Whatever was here has been lost to time.",
			LINE_3 = "It shows shadows descending on the city.",
			LINE_4 = "The people weren't quick enough to escape. They paid a price...",
			LINE_5 = "They had the right idea for a while, but they must have made a mistake.",
		},
        ATRIUM_STATUE = "A frozen moment in ancient history.",
        ATRIUM_LIGHT =
        {
			ON = "I should keep my distance.",
			OFF = "I don't know if I want those lights to turn on...",
		},
        ATRIUM_GATE =
        {
			ON = "It's radiating a strange energy, almost like...",
			OFF = "With a bit of tinkering, I could get it working again.",
			CHARGING = "Does anyone else feel a crackle of magic in the air?",
			DESTABILIZING = "The magical field is collapsing!",
			COOLDOWN = "For the time being, I think it should be left alone.",
        },
        ATRIUM_KEY = "Am I sure I want to take this?",
		LIFEINJECTOR = "I have no use for it, what I need is more time!",
		SKELETON_PLAYER =
		{
			MALE = "%s! There might still be time to bring him back!",
			FEMALE = "%s! You're not going out like this, not on my watch!",
			ROBOT = "%s! There might still be time to bring them back!",
			DEFAULT = "%s! You're not going out like this, not on my watch!",
		},
--fallback to speech_wilson.lua 		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
--fallback to speech_wilson.lua 		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
--fallback to speech_wilson.lua 		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "I never would have predicted I'd see a piece of the moon up close.",
		MOONROCKNUGGET = "I never would have predicted I'd see a piece of the moon up close.",
		MOONROCKCRATER = "Now, have I seen any gems lying about?",
		MOONROCKSEED = "It's like a pocket-sized moon.",

        REDMOONEYE = "I suppose it never hurts to keep an eye out.",
        PURPLEMOONEYE = "I think I can tinker with it even more.",
        GREENMOONEYE = "It'll help me keep track of where I've been.",
        ORANGEMOONEYE = "I could fashion even more interesting things with this.",
        YELLOWMOONEYE = "Knowing where everyone is saves me a lot of time.",
        BLUEMOONEYE = "I might tinker with it a bit more when I have the time.",

        --Arena Event
        LAVAARENA_BOARLORD = "That's the guy in charge here.",
        BOARRIOR = "You sure are big!",
        BOARON = "I can take him!",
        PEGHOOK = "That spit is corrosive!",
        TRAILS = "He's got a strong arm on him.",
        TURTILLUS = "Its shell is so spiky!",
        SNAPPER = "This one's got bite.",
		RHINODRILL = "He's got a nose for this kind of work.",
		BEETLETAUR = "I can smell him from here!",

        LAVAARENA_PORTAL =
        {
            ON = "I'll just be going now.",
            GENERIC = "That's how we got here. Hopefully how we get back, too.",
        },
        LAVAARENA_KEYHOLE = "It needs a key.",
		LAVAARENA_KEYHOLE_FULL = "That should do it.",
        LAVAARENA_BATTLESTANDARD = "Everyone, break the Battle Standard!",
        LAVAARENA_SPAWNER = "This is where those enemies are coming from.",

        HEALINGSTAFF = "It conducts regenerative energy.",
        FIREBALLSTAFF = "It calls a meteor from above.",
        HAMMER_MJOLNIR = "It's a heavy hammer for hitting things.",
        SPEAR_GUNGNIR = "I could do a quick charge with that.",
        BLOWDART_LAVA = "That's a weapon I could use from range.",
        BLOWDART_LAVA2 = "It uses a strong blast of air to propel a projectile.",
        LAVAARENA_LUCY = "That weapon's for throwing.",
        WEBBER_SPIDER_MINION = "I guess they're fighting for us.",
        BOOK_FOSSIL = "This'll keep those monsters held for a little while.",
		LAVAARENA_BERNIE = "He might make a good distraction for us.",
		SPEAR_LANCE = "It gets to the point.",
		BOOK_ELEMENTAL = "I can't make out the text.",
		LAVAARENA_ELEMENTAL = "It's a rock monster!",

   		LAVAARENA_ARMORLIGHT = "Light, but not very durable.",
		LAVAARENA_ARMORLIGHTSPEED = "Lightweight and designed for mobility.",
		LAVAARENA_ARMORMEDIUM = "It offers a decent amount of protection.",
		LAVAARENA_ARMORMEDIUMDAMAGER = "That could help me hit a little harder.",
		LAVAARENA_ARMORMEDIUMRECHARGER = "I'd have energy for a few more stunts wearing that.",
		LAVAARENA_ARMORHEAVY = "That's as good as it gets.",
		LAVAARENA_ARMOREXTRAHEAVY = "This armor has been petrified for maximum protection.",

		LAVAARENA_FEATHERCROWNHAT = "Those fluffy feathers make me want to run!",
        LAVAARENA_HEALINGFLOWERHAT = "The blossom interacts well with healing magic.",
        LAVAARENA_LIGHTDAMAGERHAT = "My strikes would hurt a little more wearing that.",
        LAVAARENA_STRONGDAMAGERHAT = "It looks like it packs a wallop.",
        LAVAARENA_TIARAFLOWERPETALSHAT = "Looks like it amplifies healing expertise.",
        LAVAARENA_EYECIRCLETHAT = "It has a gaze full of science.",
        LAVAARENA_RECHARGERHAT = "Those crystals will quicken my abilities.",
        LAVAARENA_HEALINGGARLANDHAT = "This garland will restore a bit of my vitality.",
        LAVAARENA_CROWNDAMAGERHAT = "That could cause some major destruction.",

		LAVAARENA_ARMOR_HP = "That should keep me safe.",

		LAVAARENA_FIREBOMB = "It smells like brimstone.",
		LAVAARENA_HEAVYBLADE = "A sharp looking instrument.",

        --Quagmire
        QUAGMIRE_ALTAR =
        {
        	GENERIC = "We'd better start cooking some offerings.",
        	FULL = "It's in the process of digestinating.",
    	},
		QUAGMIRE_ALTAR_STATUE1 = "It's an old statue.",
		QUAGMIRE_PARK_FOUNTAIN = "Been a long time since it was hooked up to water.",

        QUAGMIRE_HOE = "It's a farming instrument.",

        QUAGMIRE_TURNIP = "It's a raw turnip.",
        QUAGMIRE_TURNIP_COOKED = "Cooking is science in practice.",
        QUAGMIRE_TURNIP_SEEDS = "A handful of odd seeds.",

        QUAGMIRE_GARLIC = "The number one breath enhancer.",
        QUAGMIRE_GARLIC_COOKED = "Perfectly browned.",
        QUAGMIRE_GARLIC_SEEDS = "A handful of odd seeds.",

        QUAGMIRE_ONION = "Looks crunchy.",
        QUAGMIRE_ONION_COOKED = "A successful chemical reaction.",
        QUAGMIRE_ONION_SEEDS = "A handful of odd seeds.",

        QUAGMIRE_POTATO = "The apples of the earth.",
        QUAGMIRE_POTATO_COOKED = "A successful temperature experiment.",
        QUAGMIRE_POTATO_SEEDS = "A handful of odd seeds.",

        QUAGMIRE_TOMATO = "It's red because it's full of science.",
        QUAGMIRE_TOMATO_COOKED = "Cooking's easy if you understand chemistry.",
        QUAGMIRE_TOMATO_SEEDS = "A handful of odd seeds.",

        QUAGMIRE_FLOUR = "Ready for baking.",
        QUAGMIRE_WHEAT = "It looks a bit grainy.",
        QUAGMIRE_WHEAT_SEEDS = "A handful of odd seeds.",
        --NOTE: raw/cooked carrot uses regular carrot strings
        QUAGMIRE_CARROT_SEEDS = "A handful of odd seeds.",

        QUAGMIRE_ROTTEN_CROP = "I don't think the altar will want that.",

		QUAGMIRE_SALMON = "Mm, fresh fish.",
		QUAGMIRE_SALMON_COOKED = "Ready for the dinner table.",
		QUAGMIRE_CRABMEAT = "No imitations here.",
		QUAGMIRE_CRABMEAT_COOKED = "I can put a meal together in a pinch.",
		QUAGMIRE_SUGARWOODTREE =
		{
			GENERIC = "It's full of delicious, delicious sap.",
			STUMP = "Where'd the tree go? I'm stumped.",
			TAPPED_EMPTY = "Here sappy, sappy, sap.",
			TAPPED_READY = "Sweet golden sap.",
			TAPPED_BUGS = "That's how you get ants.",
			WOUNDED = "It looks ill.",
		},
		QUAGMIRE_SPOTSPICE_SHRUB =
		{
			GENERIC = "It reminds me of those tentacle monsters.",
			PICKED = "I can't get anymore out of that shrub.",
		},
		QUAGMIRE_SPOTSPICE_SPRIG = "I could grind it up to make a spice.",
		QUAGMIRE_SPOTSPICE_GROUND = "Flavorful.",
		QUAGMIRE_SAPBUCKET = "We can use it to gather sap from the trees.",
		QUAGMIRE_SAP = "It tastes sweet.",
		QUAGMIRE_SALT_RACK =
		{
			READY = "Salt has gathered on the rope.",
			GENERIC = "Science takes time.",
		},

		QUAGMIRE_POND_SALT = "A little salty spring.",
		QUAGMIRE_SALT_RACK_ITEM = "For harvesting salt from the pond.",

		QUAGMIRE_SAFE =
		{
			GENERIC = "It's a safe. For keeping things safe.",
			LOCKED = "It won't open without the key.",
		},

		QUAGMIRE_KEY = "Safe bet this'll come in handy.",
		QUAGMIRE_KEY_PARK = "I'll park it in my pocket until I get to the park.",
        QUAGMIRE_PORTAL_KEY = "This looks science-y.",


		QUAGMIRE_MUSHROOMSTUMP =
		{
			GENERIC = "Are those mushrooms? I'm stumped.",
			PICKED = "I don't think it's growing back.",
		},
		QUAGMIRE_MUSHROOMS = "These are edible mushrooms.",
        QUAGMIRE_MEALINGSTONE = "The daily grind.",
		QUAGMIRE_PEBBLECRAB = "That rock's alive!",


		QUAGMIRE_RUBBLE_CARRIAGE = "On the road to nowhere.",
        QUAGMIRE_RUBBLE_CLOCK = "Someone beat the clock. Literally.",
        QUAGMIRE_RUBBLE_CATHEDRAL = "Preyed upon.",
        QUAGMIRE_RUBBLE_PUBDOOR = "No longer a-door-able.",
        QUAGMIRE_RUBBLE_ROOF = "Someone hit the roof.",
        QUAGMIRE_RUBBLE_CLOCKTOWER = "That clock's been punched.",
        QUAGMIRE_RUBBLE_BIKE = "Must have mis-spoke.",
        QUAGMIRE_RUBBLE_HOUSE =
        {
            "No one's here.",
            "Something destroyed this town.",
            "I wonder who they angered.",
        },
        QUAGMIRE_RUBBLE_CHIMNEY = "Something put a damper on that chimney.",
        QUAGMIRE_RUBBLE_CHIMNEY2 = "Something put a damper on that chimney.",
        QUAGMIRE_MERMHOUSE = "What an ugly little house.",
        QUAGMIRE_SWAMPIG_HOUSE = "It's seen better days.",
        QUAGMIRE_SWAMPIG_HOUSE_RUBBLE = "Some pig's house was ruined.",
        QUAGMIRE_SWAMPIGELDER =
        {
            GENERIC = "I guess you're in charge around here?",
            SLEEPING = "It's sleeping, for now.",
        },
        QUAGMIRE_SWAMPIG = "It's a super hairy pig.",

        QUAGMIRE_PORTAL = "Another dead end.",
        QUAGMIRE_SALTROCK = "Salt. The tastiest mineral.",
        QUAGMIRE_SALT = "It's full of salt.",
        --food--
        QUAGMIRE_FOOD_BURNT = "That one was an experiment.",
        QUAGMIRE_FOOD =
        {
        	GENERIC = "I should offer it on the Altar of Gnaw.",
            MISMATCH = "That's not what it wants.",
            MATCH = "Science says this will appease the sky God.",
            MATCH_BUT_SNACK = "It's more of a light snack, really.",
        },

        QUAGMIRE_FERN = "Probably chock full of vitamins.",
        QUAGMIRE_FOLIAGE_COOKED = "We cooked the foliage.",
        QUAGMIRE_COIN1 = "I'd like more than a penny for my thoughts.",
        QUAGMIRE_COIN2 = "A decent amount of coin.",
        QUAGMIRE_COIN3 = "Seems valuable.",
        QUAGMIRE_COIN4 = "We can use these to reopen the Gateway.",
        QUAGMIRE_GOATMILK = "Good if you don't think about where it came from.",
        QUAGMIRE_SYRUP = "Adds sweetness to the mixture.",
        QUAGMIRE_SAP_SPOILED = "Might as well toss it on the fire.",
        QUAGMIRE_SEEDPACKET = "Sow what?",

        QUAGMIRE_POT = "This pot holds more ingredients.",
        QUAGMIRE_POT_SMALL = "Let's get cooking!",
        QUAGMIRE_POT_SYRUP = "I need to sweeten this pot.",
        QUAGMIRE_POT_HANGER = "It has hang-ups.",
        QUAGMIRE_POT_HANGER_ITEM = "For suspension-based cookery.",
        QUAGMIRE_GRILL = "Now all I need is a backyard to put it in.",
        QUAGMIRE_GRILL_ITEM = "I'll have to grill someone about this.",
        QUAGMIRE_GRILL_SMALL = "Barbecurious.",
        QUAGMIRE_GRILL_SMALL_ITEM = "For grilling small meats.",
        QUAGMIRE_OVEN = "It needs ingredients to make the science work.",
        QUAGMIRE_OVEN_ITEM = "For scientifically burning things.",
        QUAGMIRE_CASSEROLEDISH = "A dish for all seasonings.",
        QUAGMIRE_CASSEROLEDISH_SMALL = "For making minuscule motleys.",
        QUAGMIRE_PLATE_SILVER = "A silver plated plate.",
        QUAGMIRE_BOWL_SILVER = "A bright bowl.",
--fallback to speech_wilson.lua         QUAGMIRE_CRATE = "Kitchen stuff.",

        QUAGMIRE_MERM_CART1 = "Any science in there?", --sammy's wagon
        QUAGMIRE_MERM_CART2 = "I could use some stuff.", --pipton's cart
        QUAGMIRE_PARK_ANGEL = "Take that, creature!",
        QUAGMIRE_PARK_ANGEL2 = "So lifelike.",
        QUAGMIRE_PARK_URN = "Ashes to ashes.",
        QUAGMIRE_PARK_OBELISK = "A monumental monument.",
        QUAGMIRE_PARK_GATE =
        {
            GENERIC = "Turns out a key was the key to getting in.",
            LOCKED = "Locked tight.",
        },
        QUAGMIRE_PARKSPIKE = "The scientific term is: \"Sharp pointy thing\".",
        QUAGMIRE_CRABTRAP = "A crabby trap.",
        QUAGMIRE_TRADER_MERM = "Maybe they'd be willing to trade.",
        QUAGMIRE_TRADER_MERM2 = "Maybe they'd be willing to trade.",

        QUAGMIRE_GOATMUM = "Reminds me of my old nanny.",
        QUAGMIRE_GOATKID = "This goat's much smaller.",
        QUAGMIRE_PIGEON =
        {
            DEAD = "They're dead.",
            GENERIC = "He's just winging it.",
            SLEEPING = "It's sleeping, for now.",
        },
        QUAGMIRE_LAMP_POST = "Huh. Reminds me of home.",

        QUAGMIRE_BEEFALO = "Science says it should have died by now.",
        QUAGMIRE_SLAUGHTERTOOL = "Laboratory tools for surgical butchery.",

        QUAGMIRE_SAPLING = "I can't get anything else out of that.",
        QUAGMIRE_BERRYBUSH = "Those berries are all gone.",

        QUAGMIRE_ALTAR_STATUE2 = "What are you looking at?",
        QUAGMIRE_ALTAR_QUEEN = "A monumental monument.",
        QUAGMIRE_ALTAR_BOLLARD = "As far as posts go, this one is adequate.",
        QUAGMIRE_ALTAR_IVY = "Kind of clingy.",

        QUAGMIRE_LAMP_SHORT = "Enlightening.",

        --v2 Winona
        WINONA_CATAPULT =
        {
        	GENERIC = "She's put a modern spin on a medieval concept.",
        	OFF = "Maybe it needs winding?",
        	BURNING = "That doesn't bode well for us.",
        	BURNT = "I wonder how quickly she can build a new one...",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "That young lady is a genius!",
        	OFF = "Maybe it needs winding?",
        	BURNING = "That doesn't bode well for us.",
        	BURNT = "I wonder how quickly she can build a new one...",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "So this is one of those modern electrical thingies?",
        	LOWPOWER = "It's already losing steam? Clockwork is so much more reliable.",
        	OFF = "Did the electricity run out? Where do you get more?",
        	BURNING = "I probably should have warned her that was going to happen.",
        	BURNT = "I wonder how quickly she can build a new one...",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "I see she's also been incorporating gems into her designs.",
        	LOWPOWER = "A fresh gem should keep it going a while longer.",
        	OFF = "It ran out of magical energy.",
        	BURNING = "I probably should have warned her that was going to happen.",
        	BURNT = "I wonder how quickly she can build a new one...",
        },

        --Wormwood
        COMPOSTWRAP = "To each their own.",
        ARMOR_BRAMBLE = "Sometimes it pays to have a prickly exterior.",
        TRAP_BRAMBLE = "If any intruders come by, they'll be in for a thorny surprise.",

        BOATFRAGMENT03 = "Brrr... so many terrible things can happen out at sea.",
        BOATFRAGMENT04 = "Brrr... so many terrible things can happen out at sea.",
        BOATFRAGMENT05 = "Someone's boat met an untimely end.",
		BOAT_LEAK = "I need to stop that leak, quickly!",
        MAST = "That's the part that holds the sail.",
        SEASTACK = "Don't you dare hit my boat!",
        FISHINGNET = "Nothing but net.", --unimplemented
        ANTCHOVIES = "Yeesh. Can I toss it back?", --unimplemented
        STEERINGWHEEL = "My poor hands are going to get callouses from all this sea-faring.",
        ANCHOR = "I'm more suited to fine-tuning than heavy lifting.",
        BOATPATCH = "I hope I won't need them...",
        DRIFTWOOD_TREE =
        {
            BURNING = "That's an unfortunate turn of events.",
            BURNT = "It won't do me much good now.",
            CHOPPED = "I should check for roots while I'm here.",
            GENERIC = "That tree is long dead.",
        },

        DRIFTWOOD_LOG = "Who knows how long it's been floating out in the ocean?",

        MOON_TREE =
        {
            BURNING = "I guess that's just the way of things sometimes.",
            BURNT = "That's the end for this tree.",
            CHOPPED = "No sense waiting around for it to grow back.",
            GENERIC = "It looks like it's already gone grey.",
        },
		MOON_TREE_BLOSSOM = "It's gone completely white.",

        MOONBUTTERFLY =
        {
        	GENERIC = "It's simply not fair that they live such brief lives.",
        	HELD = "It's a bit cluttered in my pockets, please try not to get squished!",
        },
		MOONBUTTERFLYWINGS = "It's not like moths live very long anyway.",
        MOONBUTTERFLY_SAPLING = "A moth turning into a tree hardly feels out of the ordinary anymore.",
        ROCK_AVOCADO_FRUIT = "That looks like a quick way to chip a tooth.",
        ROCK_AVOCADO_FRUIT_RIPE = "After all that waiting, it's finally somewhat edible.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "I don't know if it was worth the time to cook it.",
        ROCK_AVOCADO_FRUIT_SPROUT = "There's a new little life forming.",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "I think it's well past its prime.",
			WITHERED = "I can't expect it to make fruit in this heat.",
			GENERIC = "I've seen a lot of strange things in my time. This is one of them.",
			PICKED = "I'll come back later when there's fruit to pick.",
			DISEASED = "It looks pretty sick.", --unimplemented
            DISEASING = "Err, something's not right.", --unimplemented
			BURNING = "Oh botheration, I needed that!",
		},
        DEAD_SEA_BONES = "Not what I was hoping to see on my stroll down the beach.",
        HOTSPRING =
        {
        	GENERIC = "It looks so warm and inviting.",
        	BOMBED = "There's no sense in questioning these things.",
        	GLASS = "A giant splash, frozen in time.",
			EMPTY = "No sense standing around an empty hole.",
        },
        MOONGLASS = "It would make a perfect watch crystal, if only it played nice with shadow magic.",
        MOONGLASS_CHARGED = "It's not going to stay charged for long.",
        MOONGLASS_ROCK = "Jagged glass coming from the ground, what could go wrong?",
        BATHBOMB = "It might be nice to have a warm bath and unwind for a moment or two.",
        TRAP_STARFISH =
        {
            GENERIC = "I'm not falling for that again.",
            CLOSED = "Ooooh you hateful thing!",
        },
        DUG_TRAP_STARFISH = "It's what it deserves.",
        SPIDER_MOON =
        {
        	GENERIC = "I don't think that spider was assembled properly.",
        	SLEEPING = "It's still, for the time being.",
        	DEAD = "That's the end of that.",
        },
        MOONSPIDERDEN = "They're not the best decorators, are they?",
		FRUITDRAGON =
		{
			GENERIC = "What a funny little creature.",
			RIPE = "It's a shame they're so delicious.",
			SLEEPING = "I guess it doesn't have anything better to do.",
		},
        PUFFIN =
        {
            GENERIC = "What a jolly looking bird.",
            HELD = "It's a bit awkward carrying such a large bird around with me...",
            SLEEPING = "It's fast asleep.",
        },

		MOONGLASSAXE = "A sharp tool makes for faster chopping!",
		GLASSCUTTER = "I'm impressed the glass doesn't shatter on impact.",

        ICEBERG =
        {
            GENERIC = "Let's steer clear of that.", --unimplemented
            MELTED = "It's completely melted.", --unimplemented
        },
        ICEBERG_MELTED = "It's completely melted.", --unimplemented

        MINIFLARE = "It'll show everyone where I am, when I am is another story.",

		MOON_FISSURE =
		{
			GENERIC = "The air around it tingles with potential.",
			NOLIGHT = "I'd better watch my step around here.",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "I just can't stand leaving anything unfinished.",
            GENERIC = "Nothing wrong with dabbling in strange mystical magics from time to time.",
        },

        MOON_ALTAR_IDOL = "I think I know where it wants to go.",
        MOON_ALTAR_GLASS = "It's showing me a place... is it a premonition or a memory?",
        MOON_ALTAR_SEED = "This isn't where it needs to be.",

        MOON_ALTAR_ROCK_IDOL = "There's definitely something stuck in there. I wonder...",
        MOON_ALTAR_ROCK_GLASS = "There's definitely something stuck in there. I wonder...",
        MOON_ALTAR_ROCK_SEED = "There's definitely something stuck in there. I wonder...",

        MOON_ALTAR_CROWN = "I'll make better use of it than that old crab did.",
        MOON_ALTAR_COSMIC = "If I could have discovered this power first... ah well, I suppose it's in the past.",

        MOON_ALTAR_ASTRAL = "The pieces are starting to come together.",
        MOON_ALTAR_ICON = "I do wish it would stop with all that frightful whispering.",
        MOON_ALTAR_WARD = "It feels like wheels have been set in motion...",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "The ocean is so much more finicky to navigate than the time stream.",
            BURNT = "Oh botheration, now I have to build another one!",
        },
        BOAT_ITEM = "Ohhh I hate the ocean, the time stream gets so wobbly around it.",
        STEERINGWHEEL_ITEM = "I hope I don't forget to add that to the boat.",
        ANCHOR_ITEM = "I guess it might be useful... but I'd rather not to stay in one place for too long.",
        MAST_ITEM = "That'll be the... sail holder bit.",
        MUTATEDHOUND =
        {
        	DEAD = "I certainly won't miss it.",
        	GENERIC = "What a terrible sight!",
        	SLEEPING = "I can't bear to look at that creature!",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "Maybe this time it's for the best.",
			GENERIC = "Is that creature actually alive?!",
			SLEEPING = "Is it asleep, or...?",
		},
        CARRAT =
        {
        	DEAD = "I think it's gone off.",
        	GENERIC = "That's the liveliest carrot I've ever seen.",
        	HELD = "Stop wriggling!",
        	SLEEPING = "It's taking a quick little nap.",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "Kelp is only slightly more interesting than grass.",
            PICKED = "It'll grow back eventually.",
        },
		BULLKELP_ROOT = "I could plant this somewhere more convenient.",
        KELPHAT = "It's not the craziest thing I've worn.",
		KELP = "It tastes about as good as it looks.",
		KELP_COOKED = "I don't know why I wasted time cooking it.",
		KELP_DRIED = "I don't know if it was worth the wait.",

		GESTALT = "Would making a deal with another mysterious entity be pushing my luck?",
        GESTALT_GUARD = "They're not too interested in talking.",

		COOKIECUTTER = "Oooh those things give me the shivers.",
		COOKIECUTTERSHELL = "Mind the spines.",
		COOKIECUTTERHAT = "If you step back a good ways and squint, it almost looks fashionable.",
		SALTSTACK =
		{
			GENERIC = "It's just salt! N-nothing to be bothered over.",
			MINED_OUT = "I feel a bit better now.",
			GROWING = "Oh goody, it's growing back.",
		},
		SALTROCK = "A bit of salt on my meals might be nice.",
		SALTBOX = "Some good old-fashioned food storage.",

		TACKLESTATION = "Fishing is so bothersome, it takes so much time and preparation!",
		TACKLESKETCH = "I don't think I've seen this type of tackle before. Or maybe I just forgot...",

        MALBATROSS = "Of course this couldn't be just a quiet, pleasant boat trip...",
        MALBATROSS_FEATHER = "At least I got a nice feather out of that whole debacle.",
        MALBATROSS_BEAK = "I don't think its owner will be missing it.",
        MAST_MALBATROSS_ITEM = "The sooner I put it on my boat the faster I'll be on my way.",
        MAST_MALBATROSS = "I can finally get this old boat up to speed!",
		MALBATROSS_FEATHERED_WEAVE = "Fabric from feathers, what will they think of next?",

        GNARWAIL =
        {
            GENERIC = "Another obviously made-up creature.",
            BROKENHORN = "I'll bet you feel pretty foolish now, don't you?",
            FOLLOWER = "Alright you can come along, just don't slow me down.",
            BROKENHORN_FOLLOWER = "I'm starting to feel a bit bad about taking its horn.",
        },
        GNARWAIL_HORN = "Who ever heard of a whale with a horn?",

        WALKINGPLANK = "Well that's ominous.",
        OAR = "Wouldn't a sail be much faster?",
		OAR_DRIFTWOOD = "Wouldn't a sail be much faster?",

		OCEANFISHINGROD = "I really don't care for fishing.",
		OCEANFISHINGBOBBER_NONE = "Oh, I've lost my bobber! Or maybe I didn't attach it yet...",
        OCEANFISHINGBOBBER_BALL = "It looks like a standard bobber to me.",
        OCEANFISHINGBOBBER_OVAL = "A slightly elongated bobber.",
		OCEANFISHINGBOBBER_CROW = "I knew I'd find a use for that feather eventually!",
		OCEANFISHINGBOBBER_ROBIN = "I knew I'd find a use for that feather eventually!",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "I knew I'd find a use for that feather eventually!",
		OCEANFISHINGBOBBER_CANARY = "I knew I'd find a use for that feather eventually!",
		OCEANFISHINGBOBBER_GOOSE = "I do like this part of fishing, fiddling with tiny bits and bobs!",
		OCEANFISHINGBOBBER_MALBATROSS = "I do like this part of fishing, fiddling with tiny bits and bobs!",

		OCEANFISHINGLURE_SPINNER_RED = "If it will help me catch a fish faster, I'm all for it.",
		OCEANFISHINGLURE_SPINNER_GREEN = "If it will help me catch a fish faster, I'm all for it.",
		OCEANFISHINGLURE_SPINNER_BLUE = "If it will help me catch a fish faster, I'm all for it.",
		OCEANFISHINGLURE_SPOON_RED = "If it will help me catch a fish faster, I'm all for it.",
		OCEANFISHINGLURE_SPOON_GREEN = "If it will help me catch a fish faster, I'm all for it.",
		OCEANFISHINGLURE_SPOON_BLUE = "If it will help me catch a fish faster, I'm all for it.",
		OCEANFISHINGLURE_HERMIT_RAIN = "I might as well keep it for a rainy day.",
		OCEANFISHINGLURE_HERMIT_SNOW = "I don't fancy catching my death of cold for a fish.",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Is it poisoned? Should I really be poisoning my dinner?",
		OCEANFISHINGLURE_HERMIT_HEAVY = "A quick way to catch big fish? Don't mind if I do!",

		OCEANFISH_SMALL_1 = "All that time spent just to catch this little fish?",
		OCEANFISH_SMALL_2 = "So much effort and so little to show for it.",
		OCEANFISH_SMALL_3 = "There's hardly enough meat on it to make it worth my time.",
		OCEANFISH_SMALL_4 = "At least it wasn't too difficult to catch.",
		OCEANFISH_SMALL_5 = "It comes pre-cooked? Perfect!",
		OCEANFISH_SMALL_6 = "Not exactly appetizing, is it?",
		OCEANFISH_SMALL_7 = "A garden-variety fish.",
		OCEANFISH_SMALL_8 = "I'd better take care not to scald my hands.",
        OCEANFISH_SMALL_9 = "It's full of spit and vinegar.",

		OCEANFISH_MEDIUM_1 = "I think I just fished up a clump of mud.",
		OCEANFISH_MEDIUM_2 = "Finally, dinner!",
		OCEANFISH_MEDIUM_3 = "I hope it's worth all the fuss!",
		OCEANFISH_MEDIUM_4 = "Maybe I should throw it back, just in case...",
		OCEANFISH_MEDIUM_5 = "It's not so strange if you don't think about it.",
		OCEANFISH_MEDIUM_6 = "It has a lovely shimmer to it, almost metallic.",
		OCEANFISH_MEDIUM_7 = "It has a lovely shimmer to it, almost metallic.",
		OCEANFISH_MEDIUM_8 = "Oh botheration, this might take a while to thaw out.",
        OCEANFISH_MEDIUM_9 = "I wish it was a little less eel-shaped.",

		PONDFISH = "Can I call it seafood? It's more of a pondfood, really.",
		PONDEEL = "I have half a mind to throw it back...",

        FISHMEAT = "Once a fish, now food.",
        FISHMEAT_COOKED = "It's been thoroughly cooked.",
        FISHMEAT_SMALL = "Not much more than a quick fishy snack.",
        FISHMEAT_SMALL_COOKED = "I don't know why I took the time to cook something so small.",
		SPOILED_FISH = "Oooh that's rotten!",

		FISH_BOX = "I suppose the best way to keep fish fresh is to keep them alive.",
        POCKET_SCALE = "In my opinion, everything should have a pocket-sized version.",

		TACKLECONTAINER = "Finally, my poor pockets can be free of hooks and fish bait.",
		SUPERTACKLECONTAINER = "I could fit an entire bait shop in there.",

		TROPHYSCALE_FISH =
		{
			GENERIC = "That's quite an extravagant fishbowl.",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nI'm amazed it fits in there!",
			BURNING = "I would've thought the water from the fishbowl would help douse the flames...",
			BURNT = "I was too late to save it.",
			OWNER = "It does give one a nice sense of achievement.\nWeight: {weight}\nCaught by: {owner}",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nSee? I can be patient sometimes!",
		},

		OCEANFISHABLEFLOTSAM = "There might be something interesting hiding in all that mud.",

		CALIFORNIAROLL = "Would this be the official dish of California, then?",
		SEAFOODGUMBO = "Again... is leaving the bones in really necessary?",
		SURFNTURF = "Perfect for people who can't make up their mind.",

        WOBSTER_SHELLER = "I'm sensing a pot of boiling water in your future.",
        WOBSTER_DEN = "Something's peering out from inside...",
        WOBSTER_SHELLER_DEAD = "If it's already dead, I shouldn't let it go to waste.",
        WOBSTER_SHELLER_DEAD_COOKED = "Time for dinner!",

        LOBSTERBISQUE = "Would it be a frivolous use of time travel to go back and eat it over and over again?",
        LOBSTERDINNER = "Mmmm, hot buttered wobster!",

        WOBSTER_MOONGLASS = "They make normal wobsters seem friendly in comparison.",
        MOONGLASS_WOBSTER_DEN = "Maybe I should take the glass spikes as a sign to stay away.",

		TRIDENT = "It makes such a racket!",

		WINCH =
		{
			GENERIC = "Thankfully, it saves me from having to dive down myself.",
			RETRIEVING_ITEM = "Hurry up now, I want to see what it is!",
			HOLDING_ITEM = "Ha! Got it!",
		},

        HERMITHOUSE = {
            GENERIC = "It was a fine home once, but it's fallen into disrepair.",
            BUILTUP = "Time well spent.",
        },

        SHELL_CLUSTER = "Now, what do we have here?",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "I love a good knickknack, and a musical one at that!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "I think that would fit nicely in my pocket.",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "What a nice little shell! I wish I had somewhere to display it.",
        },

        CHUM = "It's only fair to feed the fish before they feed me.",

        SUNKENCHEST =
        {
            GENERIC = "A shell this enormous must have something interesting inside.",
            LOCKED = "Oh botheration! Open up, you!",
        },

        HERMIT_BUNDLE = "Ooooh I wonder what fun knickknacks are inside!",
        HERMIT_BUNDLE_SHELLS = "A nice assortment of shells to add to my little collection.",

        RESKIN_TOOL = "It reveals the various possibilities across timelines.",
        MOON_FISSURE_PLUGGED = "It makes a delightful little toot sound from time to time.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "I'm amazed that young man can keep her under control.",
            "I'm amazed that young man can keep her under control.",
        },
        WOBYSMALL =
        {
            "Oh, please don't slobber on me...",
            "Oh, please don't slobber on me...",
        },
		WALTERHAT = "What a funny little hat! Sadly, I don't think it would suit me.",
		SLINGSHOT = "I think that young man might be more mischievous than he appears.",
		SLINGSHOTAMMO_ROCK = "These obviously weren't made with precision in mind.",
		SLINGSHOTAMMO_MARBLE = "These obviously weren't made with precision in mind.",
		SLINGSHOTAMMO_THULECITE = "These obviously weren't made with precision in mind.",
        SLINGSHOTAMMO_GOLD = "These obviously weren't made with precision in mind.",
        SLINGSHOTAMMO_SLOW = "Tampering with the timestream, are we? Good lad.",
        SLINGSHOTAMMO_FREEZE = "These obviously weren't made with precision in mind.",
		SLINGSHOTAMMO_POOP = "It seems sensible enough to me, if a bit unpleasant.",
        PORTABLETENT = "A safe place to spend the night would be a welcome change.",
        PORTABLETENT_ITEM = "Someone with more time on their hands should set it up.",

        -- Wigfrid
        BATTLESONG_DURABILITY = "Oh, you wouldn't want to hear me sing... would you?",
        BATTLESONG_HEALTHGAIN = "Oh, you wouldn't want to hear me sing... would you?",
        BATTLESONG_SANITYGAIN = "Oh, you wouldn't want to hear me sing... would you?",
        BATTLESONG_SANITYAURA = "Oh, you wouldn't want to hear me sing... would you?",
        BATTLESONG_FIRERESISTANCE = "Oh, you wouldn't want to hear me sing... would you?",
        BATTLESONG_INSTANT_TAUNT = "Insults are so much more scathing when they rhyme.",
        BATTLESONG_INSTANT_PANIC = "It's her delivery that really scares the Dickens out of you.",

        -- Webber
        MUTATOR_WARRIOR = "Those are definitely not cookies.",
        MUTATOR_DROPPER = "I don't think the poor child has a future in baking.",
        MUTATOR_HIDER = "Those are definitely not cookies.",
        MUTATOR_SPITTER = "I don't think the poor child has a future in baking.",
        MUTATOR_MOON = "Those are definitely not cookies.",
        MUTATOR_HEALER = "I don't think the poor child has a future in baking.",
        SPIDER_WHISTLE = "Oh, is he throwing a little spider party?",
        SPIDERDEN_BEDAZZLER = "He's certainly got a creative streak, doesn't he?",
        SPIDER_HEALER = "They have terrible bedside manner.",
        SPIDER_REPELLENT = "I wish he used it more often.",
        SPIDER_HEALER_ITEM = "I'm afraid that won't do me any good.",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "A little bit of metaphysical meddling never hurt anyone.",
		GHOSTLYELIXIR_FASTREGEN = "A little bit of metaphysical meddling never hurt anyone.",
		GHOSTLYELIXIR_SHIELD = "A little bit of metaphysical meddling never hurt anyone.",
		GHOSTLYELIXIR_ATTACK = "A little bit of metaphysical meddling never hurt anyone.",
		GHOSTLYELIXIR_SPEED = "A little bit of metaphysical meddling never hurt anyone.",
		GHOSTLYELIXIR_RETALIATION = "A little bit of metaphysical meddling never hurt anyone.",
		SISTURN =
		{
			GENERIC = "Death should be the farthest thing from a child's mind...",
			SOME_FLOWERS = "Well... I guess it wouldn't take too long to gather a few flowers.",
			LOTS_OF_FLOWERS = "I hope she finds some comfort in this.",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "I don't like to fuss around with fancy cooking.",
            DONE = "At long last, food!",

			COOKING_LONG = "Ohhh I wish it would just hurry up!",
			COOKING_SHORT = "Surely it won't take too much longer?",
			EMPTY = "I don't smell anything cooking.",
        },

        PORTABLEBLENDER_ITEM = "It does a lively little jig.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "Some flavor might be nice, but is it worth taking the extra time?",
            DONE = "I'll admit, it does look more appetizing than it did before.",
        },
        SPICEPACK = "I wonder if it makes time slow down, or if it's just well insulated.",
        SPICE_GARLIC = "Oh, that smell takes me back.",
        SPICE_SUGAR = "Delightfully sweet.",
        SPICE_CHILI = "Best used in minute amounts.",
        SPICE_SALT = "I'll just toss a pinch over my shoulder for good luck.",
        MONSTERTARTARE = "Just smelling it shaved a few years off my life.",
        FRESHFRUITCREPES = "Kids these days, with their fancy syrup-less pancakes...",
        FROGFISHBOWL = "It tastes better than it looks.",
        POTATOTORNADO = "Time is kind of like a swirly potato.",
        DRAGONCHILISALAD = "Warly always finds such unique combinations.",
        GLOWBERRYMOUSSE = "What a delightfully useful dessert!",
        VOLTGOATJELLY = "Oooh, what a fashionable flummery!",
        NIGHTMAREPIE = "I usually trust Warly's dishes, but this one seems suspect.",
        BONESOUP = "Was leaving a chunk of bone in it really necessary?",
        MASHEDPOTATOES = "\"Potato purée\" is so much more fun to say than \"mashed potatoes\".",
        POTATOSOUFFLE = "Light and airy.",
        MOQUECA = "I'm glad someone around here knows how to cook.",
        GAZPACHO = "It might help me stave off this terrible heat.",
        ASPARAGUSSOUP = "A nice warm bowl of soup.",
        VEGSTINGER = "A little something to sip on.",
        BANANAPOP = "There's nothing quicker and simpler than fruit on a stick.",
        CEVICHE = "Oddly refreshing!",
        SALSA = "I guess I could spare some time for a quick snack...",
        PEPPERPOPPER = "They took far too long to make... but they are tasty.",

        TURNIP = "A simple turnip.",
        TURNIP_COOKED = "The turnip's been thoroughly roasted.",
        TURNIP_SEEDS = "Why waste time growing them when I can just eat them now?",

        GARLIC = "Just pop it in your mouth, it's good for you!",
        GARLIC_COOKED = "Mmm, so fragrant!",
        GARLIC_SEEDS = "Why waste time growing them when I can just eat them now?",

        ONION = "I can smell the flavor!",
        ONION_COOKED = "I love the smell of cooked onion.",
        ONION_SEEDS = "Why waste time growing them when I can just eat them now?",

        POTATO = "One of the more dependable vegetables.",
        POTATO_COOKED = "Potatoes are much better cooked, I'll admit.",
        POTATO_SEEDS = "Why waste time growing them when I can just eat them now?",

        TOMATO = "A pleasantly plump, juicy tomato.",
        TOMATO_COOKED = "Oh, it's gone all mushy.",
        TOMATO_SEEDS = "Why waste time growing them when I can just eat them now?",

        ASPARAGUS = "One must stay healthy if they want to live to a ripe old age.",
        ASPARAGUS_COOKED = "Not quite as crisp anymore.",
        ASPARAGUS_SEEDS = "Why waste time growing them when I can just eat them now?",

        PEPPER = "A little spice might put a spring in my step.",
        PEPPER_COOKED = "An especially hot pepper.",
        PEPPER_SEEDS = "Why waste time growing them when I can just eat them now?",

        WEREITEM_BEAVER = "Ooooh, what a fun little trinket!",
        WEREITEM_GOOSE = "That lumberjack's an odd duck, isn't he?",
        WEREITEM_MOOSE = "I love a good magical knickknack.",

        MERMHAT = "It's not terribly hard to outwit those scaly creatures.",
        MERMTHRONE =
        {
            GENERIC = "It's... not exactly the nicest rug I've ever seen.",
            BURNT = "It looks like the monarchy came to an abrupt end.",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "This might take a while to piece together...",
            BURNT = "What a horrible waste of time and energy!",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "A bit ramshackle, but definitely an improvement!",
            BURNT = "Fate was unkind to it.",
        },

        MERMWATCHTOWER_REGULAR = "That little merm is really turning this place around.",
        MERMWATCHTOWER_NOKING = "The poor scaly things seem quite lost without a king.",
        MERMKING = "It might be wise to get in his good graces.",
        MERMGUARD = "I certainly hope they're fighting for our side.",
        MERM_PRINCE = "What a delightfully odd way to choose a king!",

        SQUID = "Could you light the way without being a nuisance, please?!",

		GHOSTFLOWER = "It's little more than a memory.",
        SMALLGHOST = "The poor little thing. It's too late for me to help them.",

        CRABKING =
        {
            GENERIC = "Ah! There you are, you old codger!",
            INERT = "Hmm, aren't there supposed to be gems on it? Or does that come later...",
        },
		CRABKING_CLAW = "You keep those big old snippers away from me!",

		MESSAGEBOTTLE = "Oh! There's a note inside!",
		MESSAGEBOTTLEEMPTY = "You never know when you might need an empty bottle.",

        MEATRACK_HERMIT =
        {
            DONE = "It's done! Finally!!",
            DRYING = "I'll be old and grey before it's done...",
            DRYINGINRAIN = "The weather is not cooperating.",
            GENERIC = "Maybe I could help the poor old thing, if I have a spare minute or two...",
            BURNT = "Oh botheration!",
            DONE_NOTMEAT = "I think it's been aged enough.",
            DRYING_NOTMEAT = "It's like watching paint dry.",
            DRYINGINRAIN_NOTMEAT = "This isn't helping.",
        },
        BEEBOX_HERMIT =
        {
            READY = "Finally!",
            FULLHONEY = "Finally!",
            GENERIC = "She's quite creative with her limited materials.",
            NOHONEY = "Not even a drop of honey inside.",
            SOMEHONEY = "Why does honey take so long to make?",
            BURNT = "It looks like its honey making days are behind it.",
        },

        HERMITCRAB = "Ha! She's just as crabby as ever.",

        HERMIT_PEARL = "I'll... do my best.",
        HERMIT_CRACKED_PEARL = "I was holding out hope things would go differently this time.",

        -- DSEAS
        WATERPLANT = "I seem to recall something... there was a trick with the barnacles...",
        WATERPLANT_BOMB = "Oh botheration, I have to contend with angry flower spittle?",
        WATERPLANT_BABY = "In time, it will grow as big as the others.",
        WATERPLANT_PLANTER = "If I come across a nice rock, I'll leave it there.",

        SHARK = "Ah, I almost forgot. Another reason to stay away from the ocean!",

        MASTUPGRADE_LAMP_ITEM = "I feel a little better now.",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "That seems wise.",

        WATERPUMP = "I'm sure I'll be needing it soon enough.",

        BARNACLE = "I had quite the time prying them free.",
        BARNACLE_COOKED = "Only marginally better than raw barnacles.",

        BARNACLEPITA = "The barnacles fit quite nicely in that bread pocket.",
        BARNACLESUSHI = "All wrapped up with a little bow.",
        BARNACLINGUINE = "That should keep me fed for a good while.",
        BARNACLESTUFFEDFISHHEAD = "I'm starting to feel bad for the fish...",

        LEAFLOAF = "The loaf has been set very fashionably in jelly.",
        LEAFYMEATBURGER = "It has a very interesting texture.",
        LEAFYMEATSOUFFLE = "This flummery has an odd taste to it.",
        MEATYSALAD = "I found a stick in it... or at least I hope it's a stick.",

        -- GROTTO

		MOLEBAT = "Hmph, and people call me batty!",
        MOLEBATHILL = "What a horrid place to call home.",

        BATNOSE = "That should teach it not to stick its nose where it doesn't belong!",
        BATNOSE_COOKED = "It hardly makes a difference whether it's raw or cooked.",
        BATNOSEHAT = "What a wonderful, time-saving design!",

        MUSHGNOME = "This mushroom manages to be worse than most.",

        SPORE_MOON = "Careful now...",

        MOON_CAP = "A mutated mushroom, what could go wrong?",
        MOON_CAP_COOKED = "Why does it have to smell like old cheese?",

        MUSHTREE_MOON = "More mushrooms. Lovely.",

        LIGHTFLIER = "I feel a bit reassured knowing it's nearby.",

        GROTTO_POOL_BIG = "It's not a pool I'd care to take a dip in.",
        GROTTO_POOL_SMALL = "It's not a pool I'd care to take a dip in.",

        DUSTMOTH = "I could have used one of you in my workshop back home.",

        DUSTMOTHDEN = "A cozy little dust bin.",

        ARCHIVE_LOCKBOX = "It's quite a puzzling piece, isn't it?",
        ARCHIVE_CENTIPEDE = "You mechanical menace!",
        ARCHIVE_CENTIPEDE_HUSK = "Not one usable bit of clockwork to be found.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "This is why I hate cooking. Cooking takes forever!",
            COOKING_SHORT = "It has to be almost done by now, right?",
            DONE = "At long last, food!",
            EMPTY = "I'd say it's been a few centuries since this was last used.",
            BURNT = "Well that's a setback.",
        },

        ARCHIVE_MOON_STATUE = "Relics from a distant time.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "I won't waste my time trying to decipher this gibberish.",
            LINE_2 = "I'd go back and ask what it means, but this time period is a bit beyond my reach.",
            LINE_3 = "I won't waste my time trying to decipher this gibberish.",
            LINE_4 = "I'd go back and ask what it means, but this time period is a bit beyond my reach.",
            LINE_5 = "I won't waste my time trying to decipher this gibberish.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "Finally, something to point me in the right direction!",
            IDLE = "It's finally found something!",
        },

        ARCHIVE_RESONATOR_ITEM = "I think I took it to the surface before, or maybe I'll do that soon.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "It looks like it needs a good winding.",
          GENERIC =  "How delightfully odd!",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "What a curious relic.",
            GENERIC = "Oh botheration, I think I just remembered something...",
        },

        ARCHIVE_SECURITY_PULSE = "Hurry, someone catch it before-!",

        ARCHIVE_SWITCH = {
            VALID = "Oh good, we got the lights working.",
            GEMS = "There's something missing here.",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "Hm, maybe this time...",
            GENERIC = "Well, it was worth a try.",
        },

        WALL_STONE_2 = "A design from long ago.",
        WALL_RUINS_2 = "How extravagant!",

        REFINED_DUST = "It's likely to crumble away at any moment.",
        DUSTMERINGUE = "Alright, dust was a poor ingredient choice. This is why I don't cook!",

        SHROOMCAKE = "If it's a cake it can't be too terrible... right?",

        NIGHTMAREGROWTH = "They're here! I need to leave, quickly!",

        TURFCRAFTINGSTATION = "I've tampered with time, I guess I could tamper with the ground a bit too.",

        MOON_ALTAR_LINK = "Can you feel that crackle of possibility in the air?",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Just how long is this going to take?",
            WET = "Oh botheration, it's turned into a wet muck!",
            DRY = "Oh. It's much dryer than I expected.",
            BALANCED = "Perfect! I hope I can remember how I did it...",
            BURNT = "A fine mess this is...",
        },
        COMPOST = "At least I won't have to touch it.",
        SOIL_AMENDER =
		{
			GENERIC = "Hopefully this won't take too long.",
			STALE = "This is taking an eternity!",
			SPOILED = "That's good enough, isn't it?",
		},

		SOIL_AMENDER_FERMENTED = "I think it's finally done.",

        WATERINGCAN =
        {
            GENERIC = "Gardens need so much attention.",
            EMPTY = "What? How is it empty already?",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "I knew that beak would come in handy.",
            EMPTY = "Right, I'm supposed to get the water first.",
        },

		FARM_PLOW = "It's so much faster than digging everything up by hand!",
		FARM_PLOW_ITEM = "Might as well get this started.",
		FARM_HOE = "Tilling is so tedious.",
		GOLDEN_FARM_HOE = "Why can't the dirt just move itself?",
		NUTRIENTSGOGGLESHAT = "It's given me a new perspective on gardening. Quite literally.",
		PLANTREGISTRYHAT = "What a funny little hat. Let me try!",

        FARM_SOIL_DEBRIS = "Didn't I pluck that out already?",

		FIRENETTLES = "I have a feeling I shouldn't touch that.",
		FORGETMELOTS = "Have I seen those before?",
		SWEETTEA = "Well... I guess there's time for a quick cup of tea.",
		TILLWEED = "That doesn't look like it belongs...",
		TILLWEEDSALVE = "This plant gunk isn't going to do me much good.",
        WEED_IVY = "I don't like the look of it one bit.",
        IVY_SNARE = "Oh botheration, now I'll have to clean all of this up!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "You would think weight would be easier to manipulate than time...",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nInteresting, there's a temporal bubble that keeps it from rotting.",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nInteresting, there's a temporal bubble that keeps it from rotting.",
            HAS_ITEM_LIGHT = "It won't even tell me the weight? Well that's just rude.",
			BURNING = "Oh! Where did that fire come from?",
			BURNT = "What a waste.",
        },

        CARROT_OVERSIZED = "I wonder if eating all those carrots would improve my eyesight.",
        CORN_OVERSIZED = "I never thought corn could be so colorful.",
        PUMPKIN_OVERSIZED = "It looks like it's ready to roll away.",
        EGGPLANT_OVERSIZED = "I'll be eating eggplant leftovers for weeks.",
        DURIAN_OVERSIZED = "Out of all the things I planted, this is the one that decides to grow well.",
        POMEGRANATE_OVERSIZED = "I hope the seeds inside grew bigger too.",
        DRAGONFRUIT_OVERSIZED = "I'll admit, it's an impressive sight.",
        WATERMELON_OVERSIZED = "It's so pleasantly round!",
        TOMATO_OVERSIZED = "I don't know if I can lift a tomato that size!",
        POTATO_OVERSIZED = "What a ridiculously enormous potato.",
        ASPARAGUS_OVERSIZED = "That might be altogether too much asparagus, even for me.",
        ONION_OVERSIZED = "It's glorious!",
        GARLIC_OVERSIZED = "It's still hard to believe garlic could grow so big.",
        PEPPER_OVERSIZED = "Ooooh, I get the feeling this one is going to be extra hot.",

        VEGGIE_OVERSIZED_ROTTEN = "Botheration! Time has gotten its claws into it!",

		FARM_PLANT =
		{
			GENERIC = "A plant.",
			SEED = "I hope it grows quickly.",
			GROWING = "Please hurry up!",
			FULL = "Finally!!",
			ROTTEN = "Ack! I misjudged its position on the timeline!",
			FULL_OVERSIZED = "I guess patience does pay off sometimes.",
			ROTTEN_OVERSIZED = "Botheration! Time has gotten its claws into it!",
			FULL_WEED = "Wait a tick, I don't think I meant to plant that!",

			BURNING = "All that time and energy... wasted...",
		},

        FRUITFLY = "Oh, shoo!",
        LORDFRUITFLY = "I have no patience for all your pestering!",
        FRIENDLYFRUITFLY = "Thank goodness, I don't have to entertain the garden anymore.",
        FRUITFLYFRUIT = "I'd rather not start attracting flies, but it could be useful.",

        SEEDPOUCH = "Extra pocket space is always welcome.",

		-- Crow Carnival
		CARNIVAL_HOST = "Hello there, Goodfeather. How long has it been?",
		CARNIVAL_CROWKID = "Look at them, so full of youthful vitality!",
		CARNIVAL_GAMETOKEN = "It's been meticulously polished.",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "Only one ticket?",
			GENERIC_SMALLSTACK = "A small pile of tickets.",
			GENERIC_LARGESTACK = "A respectable pile of tickets.",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "It leads down into the game's inner workings.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "The mechanism won't work without a token.",
			PLAYING = "Well... I guess I've got enough time for some nanty narking!",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "At least they're quick to assemble.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "A handful of colored paper? Oh! To represent worms, how clever!",

		CARNIVALGAME_MEMORY_KIT = "At least they're quick to assemble.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "The mechanism won't work without a token.",
			PLAYING = "This might be a tricky one.",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "It leads down into the game's inner workings.",
			PLAYING = "Oh botheration, was it this one...?",
		},

		CARNIVALGAME_HERDING_KIT = "At least they're quick to assemble.",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "The mechanism won't work without a token.",
			PLAYING = "Oooh, that does look like fun...",
		},
		CARNIVALGAME_HERDING_CHICK = "Just you wait, I'm more spry than I look!",

		CARNIVAL_PRIZEBOOTH_KIT = "At least they're quick to assemble.",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Oooooh, what a delightful assortment of knickknacks!",
		},

		CARNIVALCANNON_KIT = "I... guess I could spare a moment or two to set it up.",
		CARNIVALCANNON =
		{
			GENERIC = "I have so much to do, but... it's just such a delightful distraction!",
			COOLDOWN = "Oooh what fun!",
		},

		CARNIVAL_PLAZA_KIT = "I hope it doesn't take too long to grow.",
		CARNIVAL_PLAZA =
		{
			GENERIC = "It could use a little something or other.",
			LEVEL_2 = "Putting a few more trinkets around wouldn't hurt.",
			LEVEL_3 = "An impressive sight, if I do say so myself!",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "I can't resist a chance to tinker with tiny mechanisms.",
		CARNIVALDECOR_EGGRIDE = "What a delightful little mechanism!",

		CARNIVALDECOR_LAMP_KIT = "You can never have too many nightlights.",
		CARNIVALDECOR_LAMP = "Ah... I feel a bit better already.",
		CARNIVALDECOR_PLANT_KIT = "A pocket-sized tree? I'm intrigued.",
		CARNIVALDECOR_PLANT = "I guess some trees can be interesting to look at after all.",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "I should really find a nice cabinet to display it in.",
			UNCOMMON = "It would look lovely over a fireplace, perhaps next to a fine mantel clock.",
			GENERIC = "I feel as though I've seen it a few times before.",
		},
		CARNIVALDECOR_FIGURE_KIT = "I couldn't help it, I looked ahead and took a peek...",

        CARNIVAL_BALL = "A colorful child's toy.", --unimplemented
		CARNIVAL_SEEDPACKET = "A little snack to keep in my pocket.",
		CARNIVALFOOD_CORNTEA = "The taste is alright, but the texture...",

        CARNIVAL_VEST_A = "Wearing a scarf to fend off the heat? How delightfully paradoxical!",
        CARNIVAL_VEST_B = "How odd! A cloak to keep cool!",
        CARNIVAL_VEST_C = "Quite the afternoonified capelet!",

        -- YOTB
        YOTB_SEWINGMACHINE = "At least it's faster than sewing by hand.",
        YOTB_SEWINGMACHINE_ITEM = "Unfortunately, it didn't come preassembled.",
        YOTB_STAGE = "What a strange fellow. A shame he doesn't pop by more often.",
        YOTB_POST =  "A good place to secure a beefalo.",
        YOTB_STAGE_ITEM = "Unfortunately, it didn't come preassembled.",
        YOTB_POST_ITEM =  "Unfortunately, it didn't come preassembled.",


        YOTB_PATTERN_FRAGMENT_1 = "With a few more pieces, I could fashion a new pattern.",
        YOTB_PATTERN_FRAGMENT_2 = "With a few more pieces, I could fashion a new pattern.",
        YOTB_PATTERN_FRAGMENT_3 = "With a few more pieces, I could fashion a new pattern.",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "I love a nice memento, they help me keep track of when I am.",
            YOTB = "Where's that peculiar judge? He might have an appreciation for this.",
        },

        WAR_BLUEPRINT = "I wouldn't mind having a beefalo bodyguard.",
        DOLL_BLUEPRINT = "I don't remember the dolls from my childhood being quite so big and hairy.",
        FESTIVE_BLUEPRINT = "This outfit's louder than a chiming grandfather clock.",
        ROBOT_BLUEPRINT = "I might need a screwdriver instead of a sewing needle.",
        NATURE_BLUEPRINT = "A pretty garden-variety outfit, wouldn't you say?",
        FORMAL_BLUEPRINT = "My beefalo will look like the perfect gentleman.",
        VICTORIAN_BLUEPRINT = "Quite a fashionable design.",
        ICE_BLUEPRINT = "The poor beefalo's going to catch a chill wearing that!",
        BEAST_BLUEPRINT = "If it's so lucky, maybe I'll keep it for myself.",

        BEEF_BELL = "It makes taming beefalo so much faster!",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "What a charming little house.",
            BURNT = "Well, that's that.",
			PLAYING_HIDEANDSEEK = "Did I find them all? I think there are some still hiding.",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "Ugh, where are they? I'm running out of time!",
		},

		KITCOONDEN_KIT = "Did I not set that up already?",

		TICOON = 
		{
			GENERIC = "Aha! I knew I remembered seeing orange ones!",
			ABANDONED = "Oh don't look at me like that, it's nothing personal!",
			SUCCESS = "You've found something, have you?",
			LOST_TRACK = "Did he lose the trail? Ugh, what a waste of time!",
			NEARBY = "He seems particularly interested in that area.",
			TRACKING = "Having an expert around should speed things up.",
			TRACKING_NOT_MINE = "They seem preoccupied with helping someone else.",
			NOTHING_TO_TRACK = "Hmm, I suppose there's nothing around to track.",
			TARGET_TOO_FAR_AWAY = "Perhaps they're somewhere else.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "I suppose there's time to make one little trinket, or two.",
            EMPTY = "It's that time of the duodecennial orbital cycle again.",
            BURNT = "Oh well, nothing to be done now.",
        },

		KITCOON_FOREST = "Oh how adorable, and conveniently pocket-sized!",
		KITCOON_SAVANNA = "Oh how adorable, and conveniently pocket-sized!",
		KITCOON_MARSH = "Oh how adorable, and conveniently pocket-sized!",
		KITCOON_DECIDUOUS = "Oh how adorable, and conveniently pocket-sized!",
		KITCOON_GRASS = "Botheration, they're so distractingly cute!",
		KITCOON_ROCKY = "Botheration, they're so distractingly cute!",
		KITCOON_DESERT = "Botheration, they're so distractingly cute!",
		KITCOON_MOON = "Botheration, they're so distractingly cute!",
		KITCOON_YOT = "Botheration, they're so distractingly cute!",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Oh botheration, not you...",
            DEAD = "It's down... for the time being.",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "I'm already at the dizzy age, all that spinning is just making it worse!",
            DEAD = "Just give me a moment to catch my breath...",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "Nice try, but not even time can trap me!",
        ALTERGUARDIAN_PHASE3 = "Third time's a charm!",
        ALTERGUARDIAN_PHASE3TRAP = "I can't let myself fall asleep at a time like this!",
        ALTERGUARDIAN_PHASE3DEADORB = "The air around it is still crackling with potential.",
        ALTERGUARDIAN_PHASE3DEAD = "There isn't so much as a spark of possibility left in it.",

        ALTERGUARDIANHAT = "I-I can see now! The timelines are untangling before my eyes!",
        ALTERGUARDIANHATSHARD = "I wonder what else I could fashion with this.",

        MOONSTORM_GLASS = {
            GENERIC = "Oh wonderful, something sharp to trip on.",
            INFUSED = "It's brimming with untapped potential!"
        },

        MOONSTORM_STATIC = "Unbridled energy.",
        MOONSTORM_STATIC_ITEM = "Somewhat bridled energy.",
        MOONSTORM_SPARK = "A speck of powerful possibility.",

        BIRD_MUTANT = "What an awful sight!",
        BIRD_MUTANT_SPITTER = "Why don't you run along and spit somewhere else?",

        WAGSTAFF_NPC = "You, sir! There's a few things I'd like to discuss with you...",
        ALTERGUARDIAN_CONTAINED = "I should have known it would happen like this again.",

        WAGSTAFF_TOOL_1 = "His tools are quite interesting.",
        WAGSTAFF_TOOL_2 = "Is it a temporal projection? Planar? I wish he'd answer my questions!",
        WAGSTAFF_TOOL_3 = "Maybe I could take a peek at his notes... oh botheration, it won't open!",
        WAGSTAFF_TOOL_4 = "That must be one of the tools he's looking for.",
        WAGSTAFF_TOOL_5 = "Maybe if I return his tools he'll be more inclined to speak with me.",

        MOONSTORM_GOGGLESHAT = "Thankfully it's been designed with room for glasses underneath.",

        MOON_DEVICE = {
            GENERIC = "It's finished...",
            CONSTRUCTION1 = "I've got the uneasy feeling I've done this before...",
            CONSTRUCTION2 = "Progress is slowly being made.",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "I just need more time!",
			RECHARGING = "Come on, come on...",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "I like to be prepared for any eventuality.",
			RECHARGING = "This might take a moment. Nobody do anything dangerous in the meantime!",
		},

        POCKETWATCH_WARP = {
			GENERIC = "It's perfect for short trips, no muss or fuss.",
			RECHARGING = "It needs a bit of time to unwind.",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Ah, that takes me way back.",
			RECHARGING = "Hurry up now, tick-tock!",
			UNMARKED = "Ah, that takes me way back.",
			MARKED_SAMESHARD = "Is it time for me to take a dip in the timestream?",
			MARKED_DIFFERENTSHARD = "It'll be a big jump, but I can make it!",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Why don't we all take a little jaunt to the past? It'll be fun!",
			RECHARGING = "It's not ready yet? Botheration, the normal passage of time is so slow!",
			UNMARKED = "Why don't we all take a little jaunt to the past? It'll be fun!",
			MARKED_SAMESHARD = "Is it time for us to take a dip in the timestream?",
			MARKED_DIFFERENTSHARD = "It'll be a big jump, but we can make it! I think...",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "If anything threatens me, why I'll clock them without a second thought!",
			DEPLETED = "I need to get my hands on more of that dark fuel...",
		},

        POCKETWATCH_PARTS = "It's no small feat to recreate small, precise mechanisms out in the wilderness.",
        POCKETWATCH_DISMANTLER = "Everything I need for building and dismantling my lovely clocks.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "It won't stay open forever. Come along everyone, tick-tock!",
			DIFFERENTSHARD = "It won't stay open forever. Come along everyone, tick-tock!",
		},
        POCKETWATCH_PORTAL_EXIT = "Another flawless temporal excursion.",

        -- Waterlog
        WATERTREE_PILLAR = "What a magnificent old tree!",
        OCEANTREE = "It must have had a hard time of it, growing all the way out here.",
        OCEANTREENUT = "It's already started growing!",
        WATERTREE_ROOT = "I should steer clear of those if I don't want to meet a watery end.",

        OCEANTREE_PILLAR = "It provides a nice bit of shade.",
        
        OCEANVINE = "A vine. Not very noteworthy.",
        FIG = "A plump, sweet fig.",
        FIG_COOKED = "I'll admit, cooking it did help bring the sweetness out.",

        SPIDER_WATER = "Shoo! Why can't you just stay in your tree?",
        MUTATOR_WATER = "Those are definitely not cookies.",
        OCEANVINE_COCOON = "As long as I don't get too close...",
        OCEANVINE_COCOON_BURNT = "Thankfully the fire didn't spread to the tree.",

        GRASSGATOR = "It seems to want nothing to do with us, which is fine by me.",

        TREEGROWTHSOLUTION = "I can finally speed up those dreadfully slow trees!",

        FIGATONI = "Who knew pasta could be sweet?",
        FIGKABAB = "No plates, no cutlery, no fuss!",
        KOALEFIG_TRUNK = "It looks very filling.",
        FROGNEWTON = "It's very flavorful.",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "Does anyone else feel that shiver of interdimensionality in the air?",
            CRIMSON = "Oh, it didn't take well to shadow magic, did it?",
            ENABLED = "Being right all the time is getting old.",
			WAITING_FOR_DARK = "I have a rather terrible feeling about this...",
			COOLDOWN = "It's dormant, for the time being at least.",
			SPAWN_DISABLED = "It doesn't seem to be active, perhaps now I can tinker with it...",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "I don't know where he finds the time for such things.",
            BURNT = "Well, that's that. Time to move on.",
        },

        DUMBBELL = "What a dreadfully repetitive way to spend one's time.",
        DUMBBELL_GOLDEN = "What a dreadfully repetitive way to spend one's time.",
		DUMBBELL_MARBLE = "What a dreadfully repetitive way to spend one's time.",
        DUMBBELL_GEM = "What a dreadfully repetitive way to spend one's time.",
        POTATOSACK = "Who would want to lug this heavy thing around?",


        TERRARIUMCHEST = 
		{
			GENERIC = "Dimensional cross-contamination aside, it's quite a lovely chest.",
			BURNT = "Erased from the timeline.",
			SHIMMER = "That... seems suspect.",
		},

		EYEMASKHAT = "How bizarre... I simply must try it on!",

        EYEOFTERROR = "I don't think that's supposed to be here...",
        EYEOFTERROR_MINI = "My eyes aren't the best, but I'm not looking for replacements anytime soon!",
        EYEOFTERROR_MINI_GROUNDED = "It's trying to hatch! I should keep my eye on it.",

        FROZENBANANADAIQUIRI = "I'll be done with it in no time.",
        BUNNYSTEW = "This rabbit was too late.",
        MILKYWHITES = "The collagen in this is great for fighting aging. Magic watch is better, though.",

        CRITTER_EYEOFTERROR = "An all seeing eye will be quite a useful companion.",

        SHIELDOFTERROR ="Oh, how alarming... but I'm not one to look a gift shield in the mouth.",
        TWINOFTERROR1 = "That doesn't look like any clockwork I've ever seen.",
        TWINOFTERROR2 = "That doesn't look like any clockwork I've ever seen.",

        -- Year of the Catcoon
        CATTOY_MOUSE = "What a clever little clockwork contraption!",
        KITCOON_NAMETAG = "This will make it easier to remember who's who at least.",

		KITCOONDECOR1 =
        {
            GENERIC = "I don't have time to watch these kits play all day.",
            BURNT = "Playtime is over.",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "I can't keep getting distracted by those adorable antics!",
            BURNT = "No more playing, for the time being.",
        },

		KITCOONDECOR1_KIT = "Do I really have time to fuss with this?",
		KITCOONDECOR2_KIT = "Surely someone with more time on their hands could set it up.",

        -- WX78
        WX78MODULE_MAXHEALTH = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MAXSANITY1 = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MAXSANITY = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MOVESPEED = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MOVESPEED2 = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_HEAT = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_NIGHTVISION = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_COLD = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_TASER = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_LIGHT = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MAXHUNGER1 = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MAXHUNGER = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MUSIC = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_BEE = "Aha! I was wondering when they'd started making these.",
        WX78MODULE_MAXHEALTH2 = "Aha! I was wondering when they'd started making these.",

        WX78_SCANNER = 
        {
            GENERIC ="Please buzz around elsewhere, you're distracting me!",
            HUNTING = "Please buzz around elsewhere, you're distracting me!",
            SCANNING = "Please buzz around elsewhere, you're distracting me!",
        },

        WX78_SCANNER_ITEM = "It's biding its time.",
        WX78_SCANNER_SUCCEEDED = "I suppose you have nothing better to do than wait around?",

        WX78_MODULEREMOVER = "Did the automaton make off with one of my tools?",

        SCANDATA = "It's of no use to me, I won't waste time reading it.",
    },

    DESCRIBE_GENERIC = "A very particular something or other.",
    DESCRIBE_TOODARK = "I-I need a light, quickly!",
    DESCRIBE_SMOLDERING = "It'll burst into flames any moment now.",

    DESCRIBE_PLANTHAPPY = "I'd best leave well enough alone.",
    DESCRIBE_PLANTVERYSTRESSED = "I can feel the stress radiating off of it.",
    DESCRIBE_PLANTSTRESSED = "Something's making it unhappy.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "Something around here is stopping it from reaching its full potential.",
    DESCRIBE_PLANTSTRESSORFAMILY = "It wouldn't hurt to plant a few more to keep it company.",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "Oh botheration, I think I tried to fit too many plants in one spot.",
    DESCRIBE_PLANTSTRESSORSEASON = "This might not be the best time of year for it.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Oh botheration, did I forget to water it again?",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "I'm sure I gave it some fertilizer not too long ago... or maybe I will soon.",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "Do I really have to talk to it?",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "Oooh, that's... upsettingly crunchy.",
		WINTERSFEASTFUEL = "I can't explain why, but it reminds me of baba's cooking.",
    },
}
