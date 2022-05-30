--Layout generated from PropagateSpeech.bat via speech_tools.lua
return{
	ACTIONFAIL =
	{
        APPRAISE =
        {
            NOTNOW = "Let's come back later.",
        },
        REPAIR =
        {
            WRONGPIECE = "No, see? That doesn't fit together at all!",
        },
        BUILD =
        {
            MOUNTED = "I've got to get down if I'm going to do that properly.",
            HASPET = "I think Woby might get jealous if I keep collecting pets.",
			TICOON = "One of these guys is enough to keep track of.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "Wouldn't that be kind of rude?",
			GENERIC = "Maybe if I ask nicely...",
			NOBITS = "He's already had a close shave. Heh, good one Walter.",
--fallback to speech_wilson.lua             REFUSE = "only_used_by_woodie",
            SOMEONEELSESBEEFALO = "That doesn't seem very polite...",
		},
		STORE =
		{
			GENERIC = "I can't fit anything else in there.",
			NOTALLOWED = "That's against the rules.",
			INUSE = "\"A Pinetree Pioneer is patient and polite.\" But uh, hurry up please?",
            NOTMASTERCHEF = "I'd rather cook over a campfire, honestly...",
		},
        CONSTRUCT =
        {
            INUSE = "Are you busy? Wanna hear about the bug I found yesterday?",
            NOTALLOWED = "That doesn't make sense.",
            EMPTY = "I need some supplies!",
            MISMATCH = "Wait... these aren't even the right plans.",
        },
		RUMMAGE =
		{
			GENERIC = "That's against the rules.",
			INUSE = "Do you like radio shows? There was this great horror one I used to listen to-",
            NOTMASTERCHEF = "I'll go check on my own supplies.",
		},
		UNLOCK =
        {
        	WRONGKEY = "That's not right.",
        },
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "I don't think that's what I'm supposed to use in this situation.",
        	KLAUS = "Wait, I want to get a closer look at that monster!",
			QUAGMIRE_WRONGKEY = "I guess I need another key.",
        },
		ACTIVATE =
		{
			LOCKED_GATE = "I think it's locked.",
            HOSTBUSY = "Excuse me, mister...? Hm, looks like he's busy.",
            CARNIVAL_HOST_HERE = "I thought I saw him around here somewhere...",
            NOCARNIVAL = "Aw, looks like they all left...",
			EMPTY_CATCOONDEN = "It's empty? Well now I feel kind of bad...",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDERS = "It would be a pretty short game, maybe I should find more first.",
			KITCOON_HIDEANDSEEK_NOT_ENOUGH_HIDING_SPOTS = "Uhh, I'm not sure where they could even hide around here.",
			KITCOON_HIDEANDSEEK_ONE_GAME_PER_DAY = "Sorry kitties, I can't play with you all day!",
		},
		OPEN_CRAFTING = 
		{
            PROFESSIONALCHEF = "I should probably leave that alone.",
			SHADOWMAGIC = "Maybe you could teach me some magic tricks? I'm a quick learner!",
		},
        COOK =
        {
            GENERIC = "If only I had some marshmallows... oh well.",
            INUSE = "Hey while you're here, wanna hear a scary story I heard on the radio?",
            TOOFAR = "My arms aren't that long.",
        },
        START_CARRAT_RACE =
        {
            NO_RACERS = "Oh. I forgot the racers!",
        },

		DISMANTLE =
		{
			COOKING = "That seems kind of dangerous.",
			INUSE = "Guess I have to wait.",
			NOTEMPTY = "I should make sure it's empty first.",
        },
        FISH_OCEAN =
		{
			TOODEEP = "A Pinetree Pioneer knows to use the right equipment. And this isn't it.",
		},
        OCEAN_FISHING_POND =
		{
			WRONGGEAR = "Hm... my handbook says I need a different kind of fishing rod.",
		},
        --wickerbottom specific action
--fallback to speech_wilson.lua         READ =
--fallback to speech_wilson.lua         {
--fallback to speech_wilson.lua             GENERIC = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua             NOBIRDS = "only_used_by_wickerbottom",
--fallback to speech_wilson.lua         },

        GIVE =
        {
            GENERIC = "I don't think I should put that there... should I?",
            DEAD = "Oh, uh... I think they're busy. Being dead.",
            SLEEPING = "Hey Woby, should we wake them up?",
            BUSY = "I guess they're busy.",
            ABIGAILHEART = "If it makes you feel better, ghosts are way more interesting anyway.",
            GHOSTHEART = "They seem pretty committed to their lifestyle. Or lack of one?",
            NOTGEM = "That's probably not going to work.",
            WRONGGEM = "That doesn't look right.",
            NOTSTAFF = "That's not going to fit there.",
            MUSHROOMFARM_NEEDSSHROOM = "I need to forage for mushrooms! C'mon Woby!",
            MUSHROOMFARM_NEEDSLOG = "One of those haunted logs should do the trick.",
            MUSHROOMFARM_NOMOONALLOWED = "I don't think they'll grow here.",
            SLOTFULL = "It's already packed.",
            FOODFULL = "There's some provisions in there already.",
            NOTDISH = "That... doesn't look like something anyone would eat.",
            DUPLICATE = "I know that one already.",
            NOTSCULPTABLE = "I'm not even going to try sculpting that.",
            NOTATRIUMKEY = "I'll have to keep looking for the right key.",
            CANTSHADOWREVIVE = "Darnit. It's not working.",
            WRONGSHADOWFORM = "Did I put it together wrong? I wish it had instructions...",
            NOMOON = "I'll have to wait until the moon's out.",
			PIGKINGGAME_MESSY = "Can't do anything until the area's been cleared up!",
			PIGKINGGAME_DANGER = "Huh? My attention's kind of divided right now.",
			PIGKINGGAME_TOOLATE = "It's too late for that.",
			CARNIVALGAME_INVALID_ITEM = "I had a feeling that wouldn't work...",
			CARNIVALGAME_ALREADY_PLAYING = "We can wait till they're done. Right Woby?",
            SPIDERNOHAT = "I don't think that would be very comfy for the spider.",
            TERRARIUM_REFUSE = "I guess that was a silly thing to try...",
            TERRARIUM_COOLDOWN = "There's no tree to give anything to yet!",
        },
        GIVETOPLAYER =
        {
            FULL = "Looks like you've already got enough supplies.",
            DEAD = "Oh, uh... I think they're busy. Being dead.",
            SLEEPING = "Hey Woby, should we wake them up?",
            BUSY = "I guess they're busy.",
        },
        GIVEALLTOPLAYER =
        {
            FULL = "Looks like you've already got enough supplies.",
            DEAD = "Oh, uh... I think they're busy. Being dead.",
            SLEEPING = "Hey Woby, should we wake them up?",
            BUSY = "I guess they're busy.",
        },
        WRITE =
        {
            GENERIC = "I probably shouldn't...",
            INUSE = "Hey! What are you writing?",
        },
        DRAW =
        {
            NOIMAGE = "Wait... Woby, do you remember what it looked like?",
        },
        CHANGEIN =
        {
            GENERIC = "What I'm wearing is fine.",
            BURNING = "That goes against everything we learned about fire safety.",
            INUSE = "Did you get lost in there? Ha... ha... uh, that was a joke.",
            NOTENOUGHHAIR = "I'll have to wait till their hair grows back.",
            NOOCCUPANT = "Uh, I think we're forgetting something...",
        },
        ATTUNE =
        {
            NOHEALTH = "I can't! I need medical attention! Where's the first aid kit?!",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "Hey, calm down! Let me on!",
            INUSE = "I guess this seat's occupied.",
			SLEEPING = "Sorry to wake you, but could you give me a ride?",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "I'll... wait till you're done.",
        },
        TEACH =
        {
            --Recipes/Teacher
            KNOWN = "Heh. I already knew that.",
            CANTLEARN = "Sorry, I kind of lost interest.",

            --MapRecorder/MapExplorer
            WRONGWORLD = "Wait... this map looks all wrong.",

			--MapSpotRevealer/messagebottle
			MESSAGEBOTTLEMANAGER_NOT_FOUND = "Come on Walter, gotta focus! Don't get distracted!",--Likely trying to read messagebottle treasure map in caves
        },
        WRAPBUNDLE =
        {
            EMPTY = "Darnit, I forgot to get something to wrap.",
        },
        PICKUP =
        {
			RESTRICTION = "That's not mine.",
			INUSE = "Guess I have to wait.",
--fallback to speech_wilson.lua             NOTMINE_SPIDER = "only_used_by_webber",
            NOTMINE_YOTC =
            {
                "Wait... you're not my carrat!",
                "Mine was the OTHER orange one.",
            },
--fallback to speech_wilson.lua 			NO_HEAVY_LIFTING = "only_used_by_wanda",
        },
        SLAUGHTER =
        {
            TOOFAR = "Hey, slow down! I just want to eat you!",
        },
        REPLATE =
        {
            MISMATCH = "I need to use a different dish. Apparently.",
            SAMEDISH = "That just looks like the same dish...",
        },
        SAIL =
        {
        	REPAIR = "I already checked, it's in perfect sailing condition!",
        },
        ROW_FAIL =
        {
            BAD_TIMING0 = "Wait, I can do it! Just need to get the hang of it.",
            BAD_TIMING1 = "That was just practice!",
            BAD_TIMING2 = "Come on Walter, follow the timing, just like in the handbook.",
        },
        LOWER_SAIL_FAIL =
        {
            "One more time, just like in the handbook.",
            "Aah, rope burn!",
            "This is harder than the diagrams make it look...",
        },
        BATHBOMB =
        {
            GLASSED = "I don't think that's going to work.",
            ALREADY_BOMBED = "I don't want to waste supplies.",
        },
		GIVE_TACKLESKETCH =
		{
			DUPLICATE = "Heh. I learned that ages ago!",
		},
		COMPARE_WEIGHABLE =
		{
            FISH_TOO_SMALL = "This one's way too small.",
            OVERSIZEDVEGGIES_TOO_SMALL = "Nope. Not big enough.",
		},
        BEGIN_QUEST =
        {
--fallback to speech_wilson.lua             ONEGHOST = "only_used_by_wendy",
        },
		TELLSTORY =
		{
			GENERIC = "This isn't really the place for a scary story...",
			NOT_NIGHT = "I should wait until it's dark, for maximum spookiness.",
			NO_FIRE = "I need a fire, it adds to the atmosphere!",
		},
        SING_FAIL =
        {
--fallback to speech_wilson.lua             SAMESONG = "only_used_by_wathgrithr",
        },
        PLANTREGISTRY_RESEARCH_FAIL =
        {
            GENERIC = "I've already learned everything I need to know about that one.",
            FERTILIZER = "I think I know everything I need to.",
        },
        FILL_OCEAN =
        {
            UNSUITABLE_FOR_PLANTS = "Maybe if I was growing a garden full of seaweed.",
        },
        POUR_WATER =
        {
            OUT_OF_WATER = "Well, that's the last of the water.",
        },
        POUR_WATER_GROUNDTILE =
        {
            OUT_OF_WATER = "I'll need to get more water.",
        },
        USEITEMON =
        {
            --GENERIC = "I can't use this on that!",

            --construction is PREFABNAME_REASON
            BEEF_BELL_INVALID_TARGET = "I don't think that's going to work.",
            BEEF_BELL_ALREADY_USED = "I already rang it!",
            BEEF_BELL_HAS_BEEF_ALREADY = "I've already got as many big fuzzy friends as I can manage.",
        },
        HITCHUP =
        {
            NEEDBEEF = "Sorry Woby, I need a real beefalo for this.",
            NEEDBEEF_CLOSER = "I should call my beefalo over here.",
            BEEF_HITCHED = "Don't worry, my beefalo isn't going anywhere.",
            INMOOD = "Maybe we should wait for them to calm down...",
        },
        MARK =
        {
            ALREADY_MARKED = "I already picked one!",
            NOT_PARTICIPANT = "Woby and I will just watch for this round.",
        },
        YOTB_STARTCONTEST =
        {
            DOESNTWORK = "Maybe he took the day off?",
            ALREADYACTIVE = "There must be another contest going on somewhere else.",
        },
        YOTB_UNLOCKSKIN =
        {
            ALREADYKNOWN = "We already know this one, don't we Woby?",
        },
        CARNIVALGAME_FEED =
        {
            TOO_LATE = "Darnit! I wasn't fast enough.",
        },
        HERD_FOLLOWERS =
        {
            WEBBERONLY = "They're not listening to me! Maybe Webber can talk to them...",
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
            DOER_ISNT_MODULE_OWNER = "I was trying to scratch behind his ears... but I don't think he has any.",
        },
    },

	ANNOUNCE_CANNOT_BUILD =
	{
		NO_INGREDIENTS = "It looks like I need to find more supplies first.",
		NO_TECH = "Um... I don't think I know how to make one of those yet...",
		NO_STATION = "I could probably do it if I had a station with the right tools.",
	},

	ACTIONFAIL_GENERIC = "It won't work.",
	ANNOUNCE_BOAT_LEAK = "Um. That might be a problem.",
	ANNOUNCE_BOAT_SINK = "Better put my swimming badge to good use!",
	ANNOUNCE_DIG_DISEASE_WARNING = "That should help... I think.", --removed
	ANNOUNCE_PICK_DISEASE_WARNING = "I'm pretty sure that's not how it's supposed to look.", --removed
	ANNOUNCE_ADVENTUREFAIL = "Perseverance is the Pinetree Pioneer way!",
    ANNOUNCE_MOUNT_LOWHEALTH = "Oh. I think they're hurt.",

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

	ANNOUNCE_BEES = "I love bees! Too bad I'm uh... deathly allergic to them.",
	ANNOUNCE_BOOMERANG = "Hey, who threw that?! Oh, wait...",
	ANNOUNCE_CHARLIE = "Woah! What are you?",
	ANNOUNCE_CHARLIE_ATTACK = "Hey w-wait- I thought we could be friends!",
--fallback to speech_wilson.lua 	ANNOUNCE_CHARLIE_MISSED = "only_used_by_winona", --winona specific
	ANNOUNCE_COLD = "Brr... I sh-should find a way to w-warm up.",
	ANNOUNCE_HOT = "Whew... come on Woby, we'd better find some shade.",
	ANNOUNCE_CRAFTING_FAIL = "I don't have all the supplies I need.",
	ANNOUNCE_DEERCLOPS = "That has to be a Deerclops! I need to get a closer look!",
	ANNOUNCE_CAVEIN = "Wait. Is this... dangerous?",
	ANNOUNCE_ANTLION_SINKHOLE =
	{
		"Woah!",
		"I think there's something moving underground!",
		"Hang on, I'm sure my handbook says what to do in an earthquake!",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "I brought you something!",
        "This is for you!",
        "Woah... you're amazing!",
	},
	ANNOUNCE_SACREDCHEST_YES = "That wasn't hard at all.",
	ANNOUNCE_SACREDCHEST_NO = "This thing is impossible to open!",
    ANNOUNCE_DUSK = "It's getting late, better set up camp soon.",

    --wx-78 specific
--fallback to speech_wilson.lua     ANNOUNCE_CHARGE = "only_used_by_wx78",
--fallback to speech_wilson.lua 	ANNOUNCE_DISCHARGE = "only_used_by_wx78",

	ANNOUNCE_EAT =
	{
		GENERIC = "Being outdoors makes everything taste better!",
		PAINFUL = "Oooh... my stomach hurts...",
		SPOILED = "Ugh, what did I just eat?",
		STALE = "I think that was old...",
		INVALID = "I don't think that's safe to eat.",
        YUCKY = "Even Woby wouldn't eat that.",

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
        "A Pinetree Pioneer... never gives up...!",
        "This is... ergh... a little heavy...",
        "Woby... could you... help... at all...?",
        "I'll get it...! I just... need a minute...!",
        "This can't... be good... for my spine...",
        "Come on Wobyyyy... help me... out!",
        "I can... do it...!",
        "Errgh... just... give me a minute...",
        "Why am I... doing this... again...?",
    },
    ANNOUNCE_ATRIUM_DESTABILIZING =
    {
		"Woah! What's happening?",
		"Don't be scared, Woby!",
		"Hey... I think this might not be safe.",
	},
    ANNOUNCE_RUINS_RESET = "Hey Woby, look! The monsters are back!",
    ANNOUNCE_SNARED = "Hey!",
    ANNOUNCE_SNARED_IVY = "Hey, let me go!",
    ANNOUNCE_REPELLED = "Look at those defenses! how does he do that?",
	ANNOUNCE_ENTER_DARK = "Ohh, verrry spooooky!",
	ANNOUNCE_ENTER_LIGHT = "Oh, hey! I can see again!",
	ANNOUNCE_FREEDOM = "That wasn't nearly as fun as I thought it'd be...",
	ANNOUNCE_HIGHRESEARCH = "I know everything now! Mostly everything, at least.",
	ANNOUNCE_HOUNDS = "Woby? Do you hear something?",
	ANNOUNCE_WORMS = "Something's moving...",
	ANNOUNCE_HUNGRY = "Can we stop for a snack break?",
	ANNOUNCE_HUNT_BEAST_NEARBY = "I learned all about tracking in the Pioneers! It went thataway!",
	ANNOUNCE_HUNT_LOST_TRAIL = "I uh... think I lost the trail...",
	ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "There's too many footprints in this wet ground!",
	ANNOUNCE_INV_FULL = "I already have too many supplies to carry.",
	ANNOUNCE_KNOCKEDOUT = "W-Woby...? Oooh... what happened?",
	ANNOUNCE_LOWRESEARCH = "That wasn't very informative.",
	ANNOUNCE_MOSQUITOS = "Zhey vant to suck our bloood!",
    ANNOUNCE_NOWARDROBEONFIRE = "That seems like a bad idea.",
    ANNOUNCE_NODANGERGIFT = "There's monsters around! I don't want to miss anything!",
    ANNOUNCE_NOMOUNTEDGIFT = "I'll have to get down first.",
	ANNOUNCE_NODANGERSLEEP = "I'm not scared! I just can't sleep...",
	ANNOUNCE_NODAYSLEEP = "I can't sleep with the sun in my eyes.",
	ANNOUNCE_NODAYSLEEP_CAVE = "I can't sleep now!",
	ANNOUNCE_NOHUNGERSLEEP = "I can't sleep on an empty stomach...",
	ANNOUNCE_NOSLEEPONFIRE = "Um... that's on fire.",
    ANNOUNCE_NOSLEEPHASPERMANENTLIGHT = "Um, WX? Could you maybe turn the light down a bit?",
	ANNOUNCE_NODANGERSIESTA = "This isn't the best time for a siesta.",
	ANNOUNCE_NONIGHTSIESTA = "I'd rather just go to bed.",
	ANNOUNCE_NONIGHTSIESTA_CAVE = "I can't rest now! There's too much to look at down here!",
	ANNOUNCE_NOHUNGERSIESTA = "Maybe if I have a snack first.",
	ANNOUNCE_NO_TRAP = "Huh. I thought for sure there would be a trap.",
	ANNOUNCE_PECKED = "Ouch!! Th-that hurt!",
	ANNOUNCE_QUAKE = "Did you feel that, Woby?",
	ANNOUNCE_RESEARCH = "I memorized my Pinetree Pioneer handbook, I can memorize this!",
	ANNOUNCE_SHELTER = "What would we do without trees?",
	ANNOUNCE_THORNS = "Aaah!! Ow!! It hurts! Were those poisonous?!",
	ANNOUNCE_BURNT = "Ow, ow, ow! Does anyone know first aid? Is this a third degree burn?!",
	ANNOUNCE_TORCH_OUT = "Uh oh... this is usually the part when something bad happens.",
	ANNOUNCE_THURIBLE_OUT = "I think it's out of fuel.",
	ANNOUNCE_FAN_OUT = "Guess it's time for a new fan.",
    ANNOUNCE_COMPASS_OUT = "What...? I've never seen a compass do this before.",
	ANNOUNCE_TRAP_WENT_OFF = "It looked way easier in my handbook...",
	ANNOUNCE_UNIMPLEMENTED = "I don't think it's done yet.",
	ANNOUNCE_WORMHOLE = "That was amazing!!",
	ANNOUNCE_TOWNPORTALTELEPORT = "Do you think I'll be the same person when I come out the other side?",
	ANNOUNCE_CANFIX = "\nDon't worry, I know how to fix it!",
	ANNOUNCE_ACCOMPLISHMENT = "I did it!",
	ANNOUNCE_ACCOMPLISHMENT_DONE = "If I were back home, I'd get a badge for that!",
	ANNOUNCE_INSUFFICIENTFERTILIZER = "I think it needs more nutrients.",
	ANNOUNCE_TOOL_SLIP = "I- I meant to do that!",
	ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "Woah! I almost got zapped!",
	ANNOUNCE_TOADESCAPING = "Hey wait! Come back!",
	ANNOUNCE_TOADESCAPED = "Darnit... he got away.",


	ANNOUNCE_DAMP = "It's just a little water!",
	ANNOUNCE_WET = "This is starting to get uncomfortable.",
	ANNOUNCE_WETTER = "Did anyone remember to pack a towel?",
	ANNOUNCE_SOAKED = "I'm going to get all pruney!",

	ANNOUNCE_WASHED_ASHORE = "Woby...? Oh good, you're okay!",

    ANNOUNCE_DESPAWN = "I don't feel so good...",
	ANNOUNCE_BECOMEGHOST = "oOooOooo!!",
	ANNOUNCE_GHOSTDRAIN = "My head... I thought having ghosts around would be more fun.",
	ANNOUNCE_PETRIFED_TREES = "I scream, you scream, the trees scream!",
	ANNOUNCE_KLAUS_ENRAGE = "I think we made him angry.",
	ANNOUNCE_KLAUS_UNCHAINED = "Maybe he'll feel better with that chain gone.",
	ANNOUNCE_KLAUS_CALLFORHELP = "He's calling more monsters! YES!!",

	ANNOUNCE_MOONALTAR_MINE =
	{
		GLASS_MED = "Woby look! There's something in there!",
		GLASS_LOW = "Just a little more...",
		GLASS_REVEAL = "Got it! What is it?",
		IDOL_MED = "Woby look! There's something in there!",
		IDOL_LOW = "Just a little more...",
		IDOL_REVEAL = "Got it! What is it?",
		SEED_MED = "Woby look! There's something in there!",
		SEED_LOW = "Just a little more...",
		SEED_REVEAL = "Got it! What is it?",
	},

    --hallowed nights
    ANNOUNCE_SPOOKED = "Is... someone there?",
	ANNOUNCE_BRAVERY_POTION = "There's nothing to be afraid of!",
	ANNOUNCE_MOONPOTION_FAILED = "Darnit, I must've done something wrong...",

	--winter's feast
	ANNOUNCE_EATING_NOT_FEASTING = "Hey everybody! Time to eat!",
	ANNOUNCE_WINTERS_FEAST_BUFF = "It almost feels like I'm back home.",
	ANNOUNCE_IS_FEASTING = "Don't worry Woby, I'll save some for you!",
	ANNOUNCE_WINTERS_FEAST_BUFF_OVER = "Well, that was fun!",

    --lavaarena event
    ANNOUNCE_REVIVING_CORPSE = "Don't worry! I have a badge in first aid!",
    ANNOUNCE_REVIVED_OTHER_CORPSE = "You look better already!",
    ANNOUNCE_REVIVED_FROM_CORPSE = "Aaah... I don't want to do that again.",

    ANNOUNCE_FLARE_SEEN = "A signal! We should follow it!",
    ANNOUNCE_OCEAN_SILHOUETTE_INCOMING = "Is that a real sea monster?",

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
	ANNOUNCE_SLINGHSOT_OUT_OF_AMMO =
	{
		"Uh oh... I'm all out of ammo.",
		"Uh... just kidding!",
	},
	ANNOUNCE_STORYTELLING_ABORT_FIREWENTOUT =
	{
        "Darnit, the fire went out right at the best part!",
	},
	ANNOUNCE_STORYTELLING_ABORT_NOT_NIGHT =
	{
        "To be continued...",
	},

    -- wx specific
    ANNOUNCE_WX_SCANNER_NEW_FOUND = "only_used_by_wx78",
--fallback to speech_wilson.lua     ANNOUNCE_WX_SCANNER_FOUND_NO_DATA = "only_used_by_wx78",

    --quagmire event
    QUAGMIRE_ANNOUNCE_NOTRECIPE = "Huh. I thought that would go alright together.",
    QUAGMIRE_ANNOUNCE_MEALBURNT = "Darnit! It's uh... a bit crispy...",
    QUAGMIRE_ANNOUNCE_LOSE = "Oh well, we can just try again right? Right...?",
    QUAGMIRE_ANNOUNCE_WIN = "Aw, do we really have to leave?",

    ANNOUNCE_ROYALTY =
    {
        "Hey! Nice crown!",
        "Your royal crowned-ness.",
        "Your majesty.",
    },

    ANNOUNCE_ATTACH_BUFF_ELECTRICATTACK    = "This reminds me of a radio program I heard where a guy was hit by lightning and turned into pure electricity and-",
    ANNOUNCE_ATTACH_BUFF_ATTACK            = "Woah! I feel like I can take on the world!",
    ANNOUNCE_ATTACH_BUFF_PLAYERABSORPTION  = "I'm invincible!",
    ANNOUNCE_ATTACH_BUFF_WORKEFFECTIVENESS = "Come on Woby, let's get to work!",
    ANNOUNCE_ATTACH_BUFF_MOISTUREIMMUNITY  = "Nothing's going to rain on my parade! Because I'm waterproof, get it?",
    ANNOUNCE_ATTACH_BUFF_SLEEPRESISTANCE   = "Wide awake and ready for anything!",

    ANNOUNCE_DETACH_BUFF_ELECTRICATTACK    = "Darnit... guess the show's over.",
    ANNOUNCE_DETACH_BUFF_ATTACK            = "Huh? My punches feel wimpier... not that I was wimpy before!",
    ANNOUNCE_DETACH_BUFF_PLAYERABSORPTION  = "Back to regular Walter.",
    ANNOUNCE_DETACH_BUFF_WORKEFFECTIVENESS = "Alright, time for a break.",
    ANNOUNCE_DETACH_BUFF_MOISTUREIMMUNITY  = "Oh well. It's good to stay hydrated anyway.",
    ANNOUNCE_DETACH_BUFF_SLEEPRESISTANCE   = "I'm starting to get a bit tired...",

	ANNOUNCE_OCEANFISHING_LINESNAP = "Darnit!",
	ANNOUNCE_OCEANFISHING_LINETOOLOOSE = "Just reel it in a little... just like they taught us...",
	ANNOUNCE_OCEANFISHING_GOTAWAY = "Hey! No fair!",
	ANNOUNCE_OCEANFISHING_BADCAST = "Er... that was just for practice.",
	ANNOUNCE_OCEANFISHING_IDLE_QUOTE =
	{
		"Hmm-hm hmmm, hm-de-dum...",
		"Well. I'm kind of bored.",
		"Do you think we should try somewhere else Woby?",
		"I wonder if fish tell scary stories about us?",
	},

	ANNOUNCE_WEIGHT = "Weight: {weight}",
	ANNOUNCE_WEIGHT_HEAVY  = "Weight: {weight}\nIs there a badge for heaviest fish?",

	ANNOUNCE_WINCH_CLAW_MISS = "Next time I'll get it!",
	ANNOUNCE_WINCH_CLAW_NO_ITEM = "What? Nothing?",

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
    ANNOUNCE_WEAK_RAT = "This carrat doesn't look healthy...",

    ANNOUNCE_CARRAT_START_RACE = "READY-SET-GO!!",

    ANNOUNCE_CARRAT_ERROR_WRONG_WAY = {
        "Hey! You have to turn around!",
        "The finish line's the other way! The. Other. Way!!",
    },
    ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP = "Hey! We need to start over, mine's asleep!",
    ANNOUNCE_CARRAT_ERROR_WALKING = "You can go faster, we trained for this! Or did we...",
    ANNOUNCE_CARRAT_ERROR_STUNNED = "That sound means go! Go!!",

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

--fallback to speech_wilson.lua     ANNOUNCE_WANDA_YOUNGTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOOLD = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_OLDTONORMAL = "only_used_by_wanda",
--fallback to speech_wilson.lua     ANNOUNCE_WANDA_NORMALTOYOUNG = "only_used_by_wanda",

	ANNOUNCE_POCKETWATCH_PORTAL = "Look at us, Woby! We're officially time travelers!!",

--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_MARK = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_RECALL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL = "only_used_by_wanda",
--fallback to speech_wilson.lua 	ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD = "only_used_by_wanda",

    ANNOUNCE_ARCHIVE_NEW_KNOWLEDGE = "Huh? It's giving me instructions!",
    ANNOUNCE_ARCHIVE_OLD_KNOWLEDGE = "I knew that one already.",
    ANNOUNCE_ARCHIVE_NO_POWER = "Hm, it doesn't look like it's working.",

    ANNOUNCE_PLANT_RESEARCHED =
    {
        "More plant facts for my mental handbook!",
    },

    ANNOUNCE_PLANT_RANDOMSEED = "Let's see what grows, Woby!",

    ANNOUNCE_FERTILIZER_RESEARCHED = "I didn't know there was so much to learn about this stuff.",

	ANNOUNCE_FIRENETTLE_TOXIN =
	{
		"Ah! Ow! It burns!!",
		"Aaaah, it got me! It got me!",
	},
	ANNOUNCE_FIRENETTLE_TOXIN_DONE = "Whew... I-I think I'm okay now.",

	ANNOUNCE_TALK_TO_PLANTS =
	{
        "Hey! Do you guys want to hear a story?",
        "You're doing great, plants! Keep it up!",
		"Don't worry, I'll be here to talk to you whenever you get lonely.",
        "How are you doing today plants? Seen any new bugs lately?",
        "It's good to have someone to talk to. Thanks plants!",
	},

	ANNOUNCE_KITCOON_HIDEANDSEEK_START = "Alright, I'm closing my eyes! Three... two... one...!",
	ANNOUNCE_KITCOON_HIDEANDSEEK_JOIN = "Can I play too? Uh... I mean, use my Pioneer tracking expertise?",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND = 
	{
		"I knew I'd find you!",
		"There you are!",
		"Gotcha!",
		"That was too easy.",
	},
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_ONE_MORE = "There should be one more hiding somewhere...",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE = "I think that's all of them!",
	ANNOUNCE_KITCOON_HIDANDSEEK_FOUND_LAST_ONE_TEAM = "Good job {name}, I think that's the last one!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TIME_ALMOST_UP = "Uh oh, I think we're almost out of time.",
	ANNOUNCE_KITCOON_HIDANDSEEK_LOSEGAME = "Darnit, they're too good at hiding!",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR = "I don't think they'd be hiding way out here.",
	ANNOUNCE_KITCOON_HIDANDSEEK_TOOFAR_RETURN = "I think we're getting warmer, Woby!",
	ANNOUNCE_KITCOON_FOUND_IN_THE_WILD = "Woby! Look what I found!",

	ANNOUNCE_TICOON_START_TRACKING	= "I think he knows the way!",
	ANNOUNCE_TICOON_NOTHING_TO_TRACK = "It doesn't look like he's picking up any scents.",
	ANNOUNCE_TICOON_WAITING_FOR_LEADER = "Wait up! I'm coming!",
	ANNOUNCE_TICOON_GET_LEADER_ATTENTION = "Look Woby, I think he's trying to get our attention!",
	ANNOUNCE_TICOON_NEAR_KITCOON = "I think he smells something nearby!",
	ANNOUNCE_TICOON_LOST_KITCOON = "I guess he lost the scent.",
	ANNOUNCE_TICOON_ABANDONED = "I think Woby and I can sniff them out on our own.",
	ANNOUNCE_TICOON_DEAD = "I-it's okay Woby, he's just taking a nap! Let's keep going.",

    -- YOTB
    ANNOUNCE_CALL_BEEF = "Come here, girl! Or boy? It's hard to tell.",
    ANNOUNCE_CANTBUILDHERE_YOTB_POST = "It doesn't make sense to build it so far away...",
    ANNOUNCE_YOTB_LEARN_NEW_PATTERN =  "Hey, I think I can make a new beefalo costume!",

    -- AE4AE
    ANNOUNCE_EYEOFTERROR_ARRIVE = "I'm pretty sure that's supposed to be attached to something!",
    ANNOUNCE_EYEOFTERROR_FLYBACK = "Oh good, they came back!",
    ANNOUNCE_EYEOFTERROR_FLYAWAY = "Aww wait, come back!",

	BATTLECRY =
	{
		GENERIC = "Sorry!!",
		PIG = "It didn't have to be like this!",
		PREY = "Sorry, you're going to be dinner for me and Woby!",
		SPIDER = "This wouldn't be happening if you didn't try to eat me!",
		SPIDER_WARRIOR = "Take that! And that!",
		DEER = "Sorry deer!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "Y-yeah! You better run!",
		PIG = "Let's just take a minute to cool our heads.",
		PREY = "Darnit! They got away.",
		SPIDER = "I didn't really want to fight them anyway.",
		SPIDER_WARRIOR = "Nobody likes a bully.",
	},

	DESCRIBE =
	{
		MULTIPLAYER_PORTAL = "Too bad it can't get us home.",
        MULTIPLAYER_PORTAL_MOONROCK = "This one looks way fancier... but still can't get us home.",
        MOONROCKIDOL = "Usually these kind of things are locked in an ancient temple guarded by a monster.",
        CONSTRUCTION_PLANS = "I'm good at following instructions! I have a badge for it!",

        ANTLION =
        {
            GENERIC = "Hi!",
            VERYHAPPY = "We're becoming pals already.",
            UNHAPPY = "It's hard to read her expression...",
        },
        ANTLIONTRINKET = "Hm, I guess I could give it away as a gift?",
        SANDSPIKE = "Hey, careful! You almost hit me with that!",
        SANDBLOCK = "Woah! How do you do that?",
        GLASSSPIKE = "It looks like a giant tooth from a glass monster!",
        GLASSBLOCK = "It looks nice I guess.",
        ABIGAIL_FLOWER =
        {
            GENERIC ="Did that flower just whisper something?",
			LEVEL1 = "Oh, Abigail! I didn't recognize you.",
			LEVEL2 = "Don't eat the haunted flower, Woby!",
			LEVEL3 = "You're not really as spooky when you're a flower.",

			-- deprecated
            LONG = "It hurts my soul to look at that thing.",
            MEDIUM = "It's giving me the creeps.",
            SOON = "Something is up with that flower!",
            HAUNTED_POCKET = "I don't think I should hang on to this.",
            HAUNTED_GROUND = "I'd die to find out what it does.",
        },

        BALLOONS_EMPTY = "Someone left litter here!",
        BALLOON = "My keen tracking senses are telling me there's a clown nearby.",
		BALLOONPARTY = "Is someone having a party?",
		BALLOONSPEED =
        {
            DEFLATED = "It's pretty much just a regular balloon now.",
            GENERIC = "Clowns have strange and mysterious ways...",
        },
		BALLOONVEST = "I guess it's better than not having a life jacket at all...",
		BALLOONHAT = "I'm a bit too old for this kind of thing.",

        BERNIE_INACTIVE =
        {
            BROKEN = "I-I'm sure we can fix him.",
            GENERIC = "He burnt himself out.",
        },

        BERNIE_ACTIVE = "Woah! Is your bear haunted? Cursed?",
        BERNIE_BIG = "If you play with fire, you're gonna get Bernie'd. Heh...",

        BOOK_BIRDS = "I don't want to brag... but I do have a badge in birdwatching.",
        BOOK_TENTACLES = "Oooh, this reminds me of a radio play where a ship gets eaten by a giant squid!",
        BOOK_GARDENING = "I already have my gardening badge.",
		BOOK_SILVICULTURE = "There's so much to learn about the woods!",
		BOOK_HORTICULTURE = "I already have my gardening badge.",
        BOOK_SLEEP = "My idea of a bedtime story has a lot more monsters in it...",
        BOOK_BRIMSTONE = "Wendy already spoiled the ending for me...",

        PLAYER =
        {
            GENERIC = "Hello, %s!",
            ATTACKER = "%s doesn't seem trustworthy...",
            MURDERER = "You're not going to get away with this, %s!",
            REVIVER = "%s is definitely Pinetree Pioneer material.",
            GHOST = "Don't worry %s, I have a badge in first aid!",
            FIRESTARTER = "That's not how you build a campfire, %s!",
        },
        WILSON =
        {
            GENERIC = "Hey Mr. %s!",
            ATTACKER = "I thought he seemed alright... maybe I was wrong.",
            MURDERER = "Is it true, Mr. %s? Are you a scientist gone mad?",
            REVIVER = "Thanks Mr. %s! Did you take good care of Woby?",
            GHOST = "What's it like being a ghost, Mr. %s? Oh, right, I'll get you a heart.",
            FIRESTARTER = "Nobody here knows how to build a proper campfire.",
        },
        WOLFGANG =
        {
            GENERIC = "Hey Mr. %s!",
            ATTACKER = "Y-you stay away!",
            MURDERER = "There's a murderer in our midst, Woby!",
            REVIVER = "Mr. %s is just a big softy!",
            GHOST = "Maybe this will help get over your fear of ghosts! Or not...",
            FIRESTARTER = "Mr. %s, wait! The fire pit is over THERE!",
        },
        WAXWELL =
        {
            GENERIC = "Hey Mr. %s! Woby, stop growling at him!",
            ATTACKER = "Your dark side is showing, Mr. %s.",
            MURDERER = "You're a monster, and not the fun kind.",
            REVIVER = "I was kind of having fun being a ghost...",
            GHOST = "Don't worry, a Pinetree Pioneer doesn't leave anyone behind!",
            FIRESTARTER = "Doesn't anyone care about fire safety?",
        },
        WX78 =
        {
            GENERIC = "Hey %s!",
            ATTACKER = "Is... something wrong with %s?",
            MURDERER = "You're a killer robot? Amazing! Wait, no Walter, not amazing!",
            REVIVER = "Aw, you do care about us \"meatsacks\"!",
            GHOST = "See, you do have a soul! Now all you need is a heart.",
            FIRESTARTER = "Hey! You'll burn down the camp!",
        },
        WILLOW =
        {
            GENERIC = "Hey %s!",
            ATTACKER = "%s? Why are you looking at me like that...?",
            MURDERER = "Get her Woby! She's a killer!",
            REVIVER = "Now I know why Woby likes you!",
            GHOST = "Woby, fetch! A heart! ...Okay, I'll get it myself.",
            FIRESTARTER = "You said you were listening when I was talking about fire safety!",
        },
        WENDY =
        {
            GENERIC = "Hey %s!",
            ATTACKER = "You can't scare me... okay, maybe a little.",
            MURDERER = "You... how could you do that?",
            REVIVER = "Being a ghost isn't so bad, I can see why Abigail likes it!",
            GHOST = "Oh, it's... kind of hard to tell you two apart.",
            FIRESTARTER = "Fire safety isn't that hard!!",
        },
        WOODIE =
        {
            GENERIC = "Hey Mr. %s! How's Ms. Lucy?",
            ATTACKER = "I don't like the way he's gripping that axe...",
            MURDERER = "Really Mr. %s? An axe murderer? At least use some imagination.",
            REVIVER = "Us outdoorsy types have each other's backs! Right Mr. %s?",
            GHOST = "Don't worry, you'll have a heart in a jiffy!",
            BEAVER = "The Werebeaver! It's real!",
            BEAVERGHOST = "I can see your Canadian spirit! Er... I'll go get a heart.",
            MOOSE = "There's a Weremoose too?!",
            MOOSEGHOST = "Don't worry Mr. %s, Canadians stick together! I'll find you a heart!",
            GOOSE = "Mr. %s...? Is that you?",
            GOOSEGHOST = "A Pinetree Pioneer is a friend to all woodland creatures! I'll get a heart!",
            FIRESTARTER = "I thought for sure YOU'D know how to build a campfire!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "Hello Ms. %s! Need any help crossing the street?",
            ATTACKER = "Is this because I said the radio will make books obsolete?",
            MURDERER = "Attack of the killer librarian!",
            REVIVER = "Thanks Ms. %s!",
            GHOST = "Well, she lived a long life... okay, okay, stop glaring! I'll get a heart!",
            FIRESTARTER = "Not you too, Ms. %s!!",
        },
        WES =
        {
            GENERIC = "Uh... hi %s.",
            ATTACKER = "This is why I don't trust clowns!",
            MURDERER = "%s is a killer clown!",
            REVIVER = "I guess some clowns are okay.",
            GHOST = "A Pinetree Pioneer leaves no one behind! Even if they're a clown!",
            FIRESTARTER = "That's not a proper campfire, %s!",
        },
        WEBBER =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "I guess he IS a monster... it's only natural.",
            MURDERER = "Hey %s! That's going too far!",
            REVIVER = "Thanks for the help! You'll make a great Pinetree Pioneer someday!",
            GHOST = "Don't worry little guy, Woby and I will take care of it.",
            FIRESTARTER = "We need to have a group meeting about fire safety.",
        },
        WATHGRITHR =
        {
            GENERIC = "Hey Ms. %s!",
            ATTACKER = "Ms. %s seems even more combative than usual...",
            MURDERER = "Ms. %s went into a Viking rage!",
            REVIVER = "Thanks Ms. %s! You're the only Viking I know, but also the best one!",
            GHOST = "Don't worry Ms. %s! Woby and I will get a heart for you in no time.",
            FIRESTARTER = "Not everything needs to have a Viking funeral, Ms. %s!",
        },
        WINONA =
        {
            GENERIC = "Hey Ms. %s!",
            ATTACKER = "You're making Woby nervous, Ms. %s...",
            MURDERER = "Watch out Woby, she's a murderer!",
            REVIVER = "Thanks for patching me up, Ms. %s!",
            GHOST = "We didn't cover this in first aid, but I'm sure I can figure it out!",
            FIRESTARTER = "Uh, Ms. %s... that's not how you make a campfire.",
        },
        WORTOX =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Is this one of your pranks?",
            MURDERER = "Y-your prank went too far %s!",
            REVIVER = "Hey, thanks for not eating my soul %s! Not that I was worried...",
            GHOST = "Does this pose an interesting dilemma for you %s?",
            FIRESTARTER = "Well... I guess he IS an imp...",
        },
        WORMWOOD =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "Wait %s! Me... friend! See?",
            MURDERER = "A killer plant! This would make a great Midnight Broadcast episode...",
            REVIVER = "You good plant friend! Much thanks!",
            GHOST = "Do you need a heart? You know, uh... ba-bum?",
            FIRESTARTER = "%s! You're going to start a forest fire that way!",
        },
        WARLY =
        {
            GENERIC = "Hey Mr. %s!",
            ATTACKER = "You seem kind of cranky Mr. %s, maybe you should eat something?",
            MURDERER = "How long have you been cooking up this murderous scheme, Mr. %s?",
            REVIVER = "Thanks Mr. %s! That really hit the spot.",
            GHOST = "Hang on Mr. %s! You'll be back to cooking fancy food in no time.",
            FIRESTARTER = "You're burning it, Mr. %s!",
        },

        WURT =
        {
            GENERIC = "Hi %s!",
            ATTACKER = "She's just doing what comes naturally, I guess.",
            MURDERER = "Hey %s, no killing people! Killing bad!",
            REVIVER = "Thanks! Uh... florp?",
            GHOST = "Oh boy, what trouble did you get into this time, %s?",
            FIRESTARTER = "No, first you clear the area, then arrange the logs like this, then-",
        },

        WALTER =
        {
            GENERIC = "Hi %s! You kind of remind me of someone...",
            ATTACKER = "Hey, that's not how a Pinetree Pioneer acts!",
            MURDERER = "You'll be kicked out of the Pioneers for this, %s!",
            REVIVER = "I knew I could count on a fellow Pinetree Pioneer.",
            GHOST = "I'll get you fixed up lickety-split!",
            FIRESTARTER = "%s! Did you not get your fire safety badge yet?",
        },

        WANDA =
        {
            GENERIC = "Oh, sorry Ms. %s! I was just, uh... checking.",
            ATTACKER = "Ms. %s is acting pretty suspiciously...",
            MURDERER = "I knew it! She IS the killer!",
            REVIVER = "Thanks Ms. %s! I promise I'll be more careful.",
            GHOST = "Don't worry Ms. %s, we'll have you back to your old self in a jiffy!",
            FIRESTARTER = "It really doesn't take that long to build an actual campfire Ms. %s!",
        },

        MIGRATION_PORTAL =
        {
        --    GENERIC = "If I had any friends, this could take me to them.",
        --    OPEN = "If I step through, will I still be me?",
        --    FULL = "It seems to be popular over there.",
        },
        GLOMMER =
        {
            GENERIC = "Don't be jealous Woby, you'll always be my best friend.",
            SLEEPING = "He must be tired from doing... whatever he does all day.",
        },
        GLOMMERFLOWER =
        {
            GENERIC = "That flower isn't in my Pinetree Pioneer handbook.",
            DEAD = "Darnit... what did I do wrong?",
        },
        GLOMMERWINGS = "How did he fly with these little wings?",
        GLOMMERFUEL = "Don't eat it, Woby!",
        BELL = "What if we put it on your collar Woby?",
        STATUEGLOMMER =
        {
            GENERIC = "It looks just like him!",
            EMPTY = "Sorry...",
        },

        LAVA_POND_ROCK = "Sedimentary, my dear Woby! Well, igneous actually... never mind.",

		WEBBERSKULL = "No Woby, these bones aren't for chewing on!",
		WORMLIGHT = "We definitely don't have these back home.",
		WORMLIGHT_LESSER = "More like a glow raisin...",
		WORM =
		{
		    PLANT = "What's wrong Woby? It's just a plant!",
		    DIRT = "Just a pile of dirt.",
		    WORM = "Woah! That worm's enormous!",
		},
        WORMLIGHT_PLANT = "What's wrong Woby? It's just a plant!",
		MOLE =
		{
			HELD = "I got it! Guys, I actually got it!!",
			UNDERGROUND = "Is something moving underground?",
			ABOVEGROUND = "Get it, Woby!",
		},
		MOLEHILL = "I wonder what's in there...",
		MOLEHAT = "These work way better than the X-ray goggles I mailed in for back home!",

		EEL = "Look at the teeth it has!",
		EEL_COOKED = "That actually smells pretty good!",
		UNAGI = "Bite-sized deliciousness.",
		EYETURRET = "It's keeping an eye on me! Get it? Because it's... you know...",
		EYETURRET_ITEM = "Come on Woby, let's find a good place to put this!",
		MINOTAURHORN = "This is amazing! A real monster horn!",
		MINOTAURCHEST = "I have to know what's inside!",
		THULECITE_PIECES = "Woby, keep your eyes peeled for any more of these little pieces!",
		POND_ALGAE = "Pond monsters love algae!",
		GREENSTAFF = "I wish I had this when I had to break camp in the Pinetree Pioneers...",
		GIFT = "A present!",
        GIFTWRAP = "I'm not great at wrapping things... it always ends up a crumpled ball.",
		POTTEDFERN = "It's so... purple!",
        SUCCULENT_POTTED = "I guess it's nice. I prefer plants outdoors though.",
		SUCCULENT_PLANT = "They're from the cactus family!",
		SUCCULENT_PICKED = "They're pretty useful for minor cuts and burns.",
		SENTRYWARD = "Map making is so much more interesting here!",
        TOWNPORTAL =
        {
			GENERIC = "Ready for a journey into the unknown Woby?",
			ACTIVE = "Let's go!",
		},
        TOWNPORTALTALISMAN =
        {
			GENERIC = "No wonder she was grumpy, there was a pit in her stomach!",
			ACTIVE = "It's ready to take us somewhere!",
		},
        WETPAPER = "Better than a wet blanket! Heh... good one Walter.",
        WETPOUCH = "Ugh, it's falling apart!",
        MOONROCK_PIECES = "Should we try to break it apart Woby?",
        MOONBASE =
        {
            GENERIC = "It looks like something should go here...",
            BROKEN = "What a mess.",
            STAFFED = "Should... should something be happening?",
            WRONGSTAFF = "I don't think that works...",
            MOONSTAFF = "Woah! That did something!",
        },
        MOONDIAL =
        {
			GENERIC = "Huh? I can see the moon!",
			NIGHT_NEW = "I know all the moon phases, this one's a new moon.",
			NIGHT_WAX = "It's a waxing moon.",
			NIGHT_FULL = "The full moon, a.k.a. best time to spot a werewolf!",
			NIGHT_WANE = "It's a waning moon.",
			CAVE = "I can't see through stone... or can I? ...Nope.",
--fallback to speech_wilson.lua 			WEREBEAVER = "only_used_by_woodie", --woodie specific
			GLASSED = "Wait, this isn't ice... it's glass!",
        },
		THULECITE = "Rocks from an ancient civilization!",
		ARMORRUINS = "Woah! It's not even heavy!",
		ARMORSKELETON = "Yessss bone armor!!",
		SKELETONHAT = "Good thing they had such a thick skull, this makes a great helmet!",
		RUINS_BAT = "I was never great at baseball... but maybe I would be with a bat like this!",
		RUINSHAT = "I'm the king! You have to listen to what I say!",
		NIGHTMARE_TIMEPIECE =
		{
            CALM = "Nothing's really happening.",
            WARN = "Things are starting to get exciting!",
            WAXING = "I think the monsters are coming!",
            STEADY = "Just a steady stream of monsters!",
            WANING = "I think they're running out of energy...",
            DAWN = "They're going away!",
            NOMAGIC = "Aw, is it over?",
		},
		BISHOP_NIGHTMARE = "Oooh, look at that! What's that stuff oozing out of it?",
		ROOK_NIGHTMARE = "Wow! It looks even more dangerous than the usual ones!",
		KNIGHT_NIGHTMARE = "Heh, spooky!",
		MINOTAUR = "Aw, did someone leave you all alone down here?",
		SPIDER_DROPPER = "Woah! You startled me!",
		NIGHTMARELIGHT = "But can you roast marshmallows over it?",
		NIGHTSTICK = "Whose bright idea was this? Get it? Because it's bright? Never mind.",
		GREENGEM = "It's a great green gem!",
		MULTITOOL_AXE_PICKAXE = "It's two tools in one!",
		ORANGESTAFF = "I bet I could race you now, Woby!",
		YELLOWAMULET = "With this on, I'm invincible! Right?",
		GREENAMULET = "Great for when you're low on supplies!",
		SLURPERPELT = "Does anyone know taxidermy?",

		SLURPER = "Hey little guy!",
		SLURPER_PELT = "Does anyone know taxidermy?",
		ARMORSLURPER = "The smell kind of ruins my appetite.",
		ORANGEAMULET = "Getting there is half the fun!",
		YELLOWSTAFF = "It never hurts to have a little star power.",
		YELLOWGEM = "Is it supposed to feel warm?",
		ORANGEGEM = "Orange you glad I found this orange gem? Ha ha, nice one Walter.",
        OPALSTAFF = "No Woby, this stick isn't for fetching!",
        OPALPRECIOUSGEM = "So many colours!",
        TELEBASE =
		{
			VALID = "Everything's ready!",
			GEMS = "Come on Woby, let's find some purple gems.",
		},
		GEMSOCKET =
		{
			VALID = "Ready to go.",
			GEMS = "I need to put in the gems first.",
		},
		STAFFLIGHT = "Almost better than a campfire.",
        STAFFCOLDLIGHT = "I just got a chill up my spine.",

        ANCIENT_ALTAR = "Do you think aliens helped them make it?",

        ANCIENT_ALTAR_BROKEN = "It looks broken to me.",

        ANCIENT_STATUE = "Woah! Is this what they looked like?",

        LICHEN = "It grows in most caves.",
		CUTLICHEN = "This won't keep for long.",

		CAVE_BANANA = "I wouldn't mind stopping for a snack.",
		CAVE_BANANA_COOKED = "Well... it's a hot banana.",
		CAVE_BANANA_TREE = "I didn't know bananas could grow in caves.",
		ROCKY = "Wow! Look at you!",

		COMPASS =
		{
			GENERIC="The Pinetree Pioneer handbook says to always bring a compass!",
			N = "North.",
			S = "South.",
			E = "East.",
			W = "West.",
			NE = "Northeast.",
			SE = "Southeast.",
			NW = "Northwest.",
			SW = "Southwest.",
		},

        HOUNDSTOOTH = "They left a souvenir!",
        ARMORSNURTLESHELL = "I'm the terrifying snail boy! Part boy, part snail!",
        BAT = "Maybe if we're lucky it'll turn into a vampire!",
        BATBAT = "Bat 'er up!",
        BATWING = "Where did the rest of the bat go?",
        BATWING_COOKED = "Uh... Woby, do you want this?",
        BATCAVE = "Looks like they're sleeping. Should we wake them up?",
        BEDROLL_FURRY = "It feels nice, like cuddling up with Woby.",
        BUNNYMAN = "I've never heard of the Bunnyman before! Better make a note.",
        FLOWER_CAVE = "Pretty swell of those flowers to light the way for us!",
        GUANO = "My Pinetree Pioneer training is telling me there's bats nearby!",
        LANTERN = "Light the way, lantern.",
        LIGHTBULB = "Will I start glowing if I eat it?",
        MANRABBIT_TAIL = "Don't eat it Woby!",
        MUSHROOMHAT = "It's not made of the poisonous kind, right?",
        MUSHROOM_LIGHT2 =
        {
            ON = "Nature is full of surprises.",
            OFF = "It's pretty... but I can't roast marshmallows over it.",
            BURNT = "Not mush we can do now.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "My mom loves collecting odd lamps... I hope she's doing alright.",
            OFF = "It's easy to spot! You see, because it has spots! Heh...",
            BURNT = "Not mush we can do now.",
        },
        SLEEPBOMB = "It's more humane than a stink bomb.",
        MUSHROOMBOMB = "My handbook says not to pick mushrooms you don't recognize.",
        SHROOM_SKIN = "It's so weird! Can I keep it?",
        TOADSTOOL_CAP =
        {
            EMPTY = "What's wrong, Woby? It's just a normal hole in the ground.",
            INGROUND = "Hey! What's that in there?",
            GENERIC = "Don't be so skittish Woby, it's just a toadstool!",
        },
        TOADSTOOL =
        {
            GENERIC = "A real giant frog monster!",
            RAGE = "I don't think he likes us very much.",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "Woah! A giant mushroom!",
            BURNT = "What a waste.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "That one's not in my handbook...",
            BLOOM = "They only bloom spore-adically. Heh... nice one, Walter.",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "The mushrooms sure grow big down here...",
            BLOOM = "Looks like this one's in bloom.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "This one's kind of puny.",
            BLOOM = "It's making more mushrooms.",
        },
        MUSHTREE_TALL_WEBBED = "There must be spiders around here somewhere!",
        SPORE_TALL =
        {
            GENERIC = "Hope I don't accidentally swallow one.",
            HELD = "The bugs in my pocket might like some light.",
        },
        SPORE_MEDIUM =
        {
            GENERIC = "Don't eat the spores Woby, a mushtree might grow in your stomach!",
            HELD = "The bugs in my pocket might like some light.",
        },
        SPORE_SMALL =
        {
            GENERIC = "Swamp gas! Oh, it's just some more spores.",
            HELD = "The bugs in my pocket might like some light.",
        },
        RABBITHOUSE =
        {
            GENERIC = "Do they ever dream of eating carrots and wake up with their house missing?",
            BURNT = "That's what happens when you're irresponsible with fire.",
        },
        SLURTLE = "What is that slimy thing? I've gotta get a closer look!",
        SLURTLE_SHELLPIECES = "Sorry slurtle.",
        SLURTLEHAT = "This should keep my brain safe. Never know when you'll see a zombie.",
        SLURTLEHOLE = "I have to see what's in there!",
        SLURTLESLIME = "Slurtle snot!",
        SNURTLE = "Hey little guy!",
        SPIDER_HIDER = "Woah! You startled me!",
        SPIDER_SPITTER = "Ooooh! Look at you!",
        SPIDERHOLE = "Someone needs to dust more often, everything's covered in cobwebs!",
        SPIDERHOLE_ROCK = "Someone needs to dust more often, everything's covered in cobwebs!",
        STALAGMITE = "People get stalagmites and stalactites confused, but I know which is which!",
        STALAGMITE_TALL = "It's a really tall... one of these!",

        TURF_CARPETFLOOR = "This reminds me of my living room back home.",
        TURF_CHECKERFLOOR = "A patch of ground.",
        TURF_DIRT = "A patch of ground.",
        TURF_FOREST = "A patch of ground.",
        TURF_GRASS = "A patch of grass.",
        TURF_MARSH = "A patch of ground.",
        TURF_METEOR = "A patch of ground.",
        TURF_PEBBLEBEACH = "A patch of ground.",
        TURF_ROAD = "Some road.",
        TURF_ROCKY = "A patch of ground.",
        TURF_SAVANNA = "A patch of grass.",
        TURF_WOODFLOOR = "Some floorboards.",

		TURF_CAVE="A patch of... underground.",
		TURF_FUNGUS="A patch of ground.",
		TURF_FUNGUS_MOON = "A patch of ground.",
		TURF_ARCHIVE = "A patch of ground.",
		TURF_SINKHOLE="A patch of ground.",
		TURF_UNDERROCK="A patch of ground.",
		TURF_MUD="A patch of ground.",

		TURF_DECIDUOUS = "A patch of ground.",
		TURF_SANDY = "Some sand.",
		TURF_BADLANDS = "A patch of ground.",
		TURF_DESERTDIRT = "A patch of ground.",
		TURF_FUNGUS_GREEN = "A patch of ground.",
		TURF_FUNGUS_RED = "A patch of ground.",
		TURF_DRAGONFLY = "Finally something fireproof!",

        TURF_SHELLBEACH = "A patch of beach.",

		POWCAKE = "This could go badly.",
        CAVE_ENTRANCE = "That rock's blocking the entrance!",
        CAVE_ENTRANCE_RUINS = "There's probably tons of good stuff in there.",

       	CAVE_ENTRANCE_OPEN =
        {
            GENERIC = "Why can't we go in?",
            OPEN = "Come on Woby! Let's take a look around!",
            FULL = "There's too many people in there... I'll just wait.",
        },
        CAVE_EXIT =
        {
            GENERIC = "Guess we're stuck here Woby.",
            OPEN = "Alright, let's go!",
            FULL = "There's too many people outside... let's just wait here.",
        },

		MAXWELLPHONOGRAPH = "It's like a radio, but not as good.",--single player
		BOOMERANG = "Fetch, Woby!",
		PIGGUARD = "I think we're already hitting it off!",
		ABIGAIL =
		{
            LEVEL1 =
            {
                "Your sister kind of creeps me out, but you're alright!",
                "Your sister kind of creeps me out, but you're alright!",
            },
            LEVEL2 =
            {
                "Your sister kind of creeps me out, but you're alright!",
                "Your sister kind of creeps me out, but you're alright!",
            },
            LEVEL3 =
            {
                "Your sister kind of creeps me out, but you're alright!",
                "Your sister kind of creeps me out, but you're alright!",
            },
		},
		ADVENTURE_PORTAL = "Don't be scared Woby, we'll do this together!",
		AMULET = "I'm invincible!!",
		ANIMAL_TRACK = "Tracks! They go this way!",
		ARMORGRASS = "Smells like a freshly mowed lawn.",
		ARMORMARBLE = "Will I be able to walk in that?",
		ARMORWOOD = "Trees are pretty useful.",
		ARMOR_SANITY = "Wait... is this dangerous?",
		ASH =
		{
			GENERIC = "Did someone have a campfire without me?",
			REMAINS_GLOMMERFLOWER = "Too bad.",
			REMAINS_EYE_BONE = "Aw, I liked that thing!",
			REMAINS_THINGIE = "Now I'll never know what it was...",
		},
		AXE = "The favoured tool of axe murderers and loggers.",
		BABYBEEFALO =
		{
			GENERIC = "Hey little guy!",
		    SLEEPING = "Shhh! Woby, they're sleeping!",
        },
        BUNDLE = "It's packed full of provisions.",
        BUNDLEWRAP = "Efficient packing is truly an overlooked art in camping.",
		BACKPACK = "Perfect for carrying supplies! And bugs!",
		BACONEGGS = "A good camping breakfast.",
		BANDAGE = "You can never be too prepared when you're out in the wilderness.",
		BASALT = "I don't think we'll be able to break through that.", --removed
		BEARDHAIR = "Aw, I thought it was yeti fur...",
		BEARGER = "Look at those razor sharp claws! I need to get a closer view!",
		BEARGERVEST = "Hey Woby, we match!",
		ICEPACK = "Now my snacks won't get stale!",
		BEARGER_FUR = "It's so soft!",
		BEDROLL_STRAW = "You make due with what you have out in the wilderness.",
		BEEQUEEN = "If I make friends with their queen, maybe the bees won't sting me!",
		BEEQUEENHIVE =
		{
			GENERIC = "I shouldn't walk on that, I'll get my shoes sticky.",
			GROWING = "It looks bigger than it did yesterday...",
		},
        BEEQUEENHIVEGROWN = "Woah, it's huge!",
        BEEGUARD = "They're just trying to protect their queen.",
        HIVEHAT = "I guess I'm the bee king now!",
        MINISIGN =
        {
            GENERIC = "Who drew this?",
            UNDRAWN = "Woby, sit still! I'll draw your portrait.",
        },
        MINISIGN_ITEM = "Where's the perfect spot to put this...",
		BEE =
		{
			GENERIC = "Heh... sure wish I wasn't deathly allergic to them!",
			HELD = "Ha ha... you wouldn't sting me... right little guy?",
		},
		BEEBOX =
		{
			READY = "Look at all that honey!",
			FULLHONEY = "Look at all that honey!",
			GENERIC = "Oh bees, why can't we be friends...",
			NOHONEY = "They need a bit more time.",
			SOMEHONEY = "They're still busy making honey.",
			BURNT = "What! Who burned the hive?",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "Mushrooms are kind of creepy when you think about them.",
			LOTS = "The mushrooms must love it there!",
			SOME = "There's a few mushrooms now, but there'll probably be more soon.",
			EMPTY = "It needs something to get started.",
			ROTTEN = "Not much left of this log for the mushrooms to feed on.",
			BURNT = "That wasn't firewood!",
			SNOWCOVERED = "My handbook says mushrooms need warmer weather to grow.",
		},
		BEEFALO =
		{
			FOLLOWER = "Look Woby, we made a new friend!",
			GENERIC = "He's almost as big as you are, Woby!",
			NAKED = "Don't worry Woby, I'd never do that to you... unless you had mats.",
			SLEEPING = "They're snoozing.",
            --Domesticated states:
            DOMESTICATED = "He's almost as friendly as Woby now.",
            ORNERY = "Hey, what's wrong?",
            RIDER = "Wanna go for a ride?",
            PUDGY = "We might need to cut back on the treats...",
            MYPARTNER = "I'm glad you and Woby get along so well. We're like a team!",
		},

		BEEFALOHAT = "It sure smells like beefalo...",
		BEEFALOWOOL = "Sorry, beefalo.",
		BEEHAT = "I can finally walk among the bees!",
        BEESWAX = "It's none of my beeswax. Heh...",
		BEEHIVE = "I reeaally shouldn't get closer...",
		BEEMINE = "W-what could go wrong?",
		BEEMINE_MAXWELL = "How do I get the mosquitoes out?",--removed
		BERRIES = "They're not in the poisonous section of my handbook, must be safe!",
		BERRIES_COOKED = "Well, now I have hot berries.",
        BERRIES_JUICY = "Yes! These are the best kind!",
        BERRIES_JUICY_COOKED = "I should eat these fast.",
		BERRYBUSH =
		{
			BARREN = "My handbook says some kind of fertilizer should help.",
			WITHERED = "It's way too hot out for anything to grow.",
			GENERIC = "Foraging is an important wilderness skill!",
			PICKED = "If I wait long enough, they'll grow back.",
			DISEASED = "Uh, something's definitely wrong with it.",--removed
			DISEASING = "Is something wrong with it?",--removed
			BURNING = "That's not a campfire...",
		},
		BERRYBUSH_JUICY =
		{
			BARREN = "It won't be making more berries anytime soon.",
			WITHERED = "I guess this isn't the season for berries.",
			GENERIC = "They look so tasty...",
			PICKED = "More will grow soon.",
			DISEASED = "Uh, something's definitely wrong with it.",--removed
			DISEASING = "Is something wrong with it?",--removed
			BURNING = "That's not a campfire...",
		},
		BIGFOOT = "I knew he was real!",--removed
		BIRDCAGE =
		{
			GENERIC = "Now we just need to catch a bird!",
			OCCUPIED = "Aw, you miss the trees don't you?",
			SLEEPING = "Are you sleeping?",
			HUNGRY = "We need some bird food!",
			STARVING = "Oh no! Did we forget to feed you?",
			DEAD = "I'm... a terrible pet owner...",
			SKELETON = "Someone should bury it.",
		},
		BIRDTRAP = "A bird trap! Classic survival stuff!",
		CAVE_BANANA_BURNT = "Whoops...",
		BIRD_EGG = "Egg-cellent! Get it? Because... egg...?",
		BIRD_EGG_COOKED = "Smells like breakfast is ready!",
		BISHOP = "It's a Martian!",
		BLOWDART_FIRE = "It's not as good as my slingshot, but it'll do the trick.",
		BLOWDART_SLEEP = "It's not as good as my slingshot, but it'll do the trick.",
		BLOWDART_PIPE = "It's not as good as my slingshot, but it'll do the trick.",
		BLOWDART_YELLOW = "It's not as good as my slingshot, but it'll do the trick.",
		BLUEAMULET = "Brr... how does it stay so cold?",
		BLUEGEM = "A magic blue gem!",
		BLUEPRINT =
		{
            COMMON = "I'm great at following directions!",
            RARE = "I think I found something interesting!",
        },
        SKETCH = "I think I could sculpt this! I'm pretty good at arts and crafts.",
		BLUE_CAP = "I'm preeetty sure this isn't the poisonous kind...",
		BLUE_CAP_COOKED = "Nothing ventured, nothing gained!",
		BLUE_MUSHROOM =
		{
			GENERIC = "Hm... there's no blue mushrooms in my handbook...",
			INGROUND = "Woby, do you think you could dig it up? Guess not.",
			PICKED = "Maybe it will grow back eventually.",
		},
		BOARDS = "Some boards.",
		BONESHARD = "It's a bone!",
		BONESTEW = "Tasty!",
		BUGNET = "I'm an expert at catching bugs.",
		BUSHHAT = "Camouflage!",
		BUTTER = "This makes far more sense, honestly.",
		BUTTERFLY =
		{
			GENERIC = "I wonder if I can catch it.",
			HELD = "Gotcha!",
		},
		BUTTERFLYMUFFIN = "I feel kind of bad about the butterfly.",
		BUTTERFLYWINGS = "Nature's pretty amazing, isn't it?",
		BUZZARD = "That seems like a bad sign.",

		SHADOWDIGGER = "I wish my shadow could help me with my chores.",

		CACTUS =
		{
			GENERIC = "That's one prickly plant.",
			PICKED = "You'd better be tasty.",
		},
		CACTUS_MEAT_COOKED = "At least it's safe to eat now.",
		CACTUS_MEAT = "Maybe I should take out the spines first.",
		CACTUS_FLOWER = "It looks nice, but getting it was a pain.",

		COLDFIRE =
		{
			EMBERS = "We need more fuel for the fire!",
			GENERIC = "Anyone want to hear a scary story?",
			HIGH = "Woah! I don't think that's safe...",
			LOW = "It might need some more fuel.",
			NORMAL = "It's the perfect temperature for... cold marshmallows?",
			OUT = "Over already?",
		},
		CAMPFIRE =
		{
			EMBERS = "We need more fuel for the fire!",
			GENERIC = "Anyone want to hear a scary story?",
			HIGH = "Woah! I don't think that's safe...",
			LOW = "It might need some more fuel.",
			NORMAL = "It's the perfect temperature for roasting marshmallows!",
			OUT = "Over already?",
		},
		CANE = "Nothing like a good walking stick! Just don't chew on it this time, Woby.",
		CATCOON = "You're a weird looking raccoon.",
		CATCOONDEN =
		{
			GENERIC = "I think something lives in there!",
			EMPTY = "Nobody's home.",
		},
		CATCOONHAT = "Now this is a hat made for the wilderness!",
		COONTAIL = "It's a tall tail! Or, I guess more of a bushy one... never mind.",
		CARROT = "I get kind of disappointed when it doesn't turn out to be a rat.",
		CARROT_COOKED = "Yup. It's a cooked carrot.",
		CARROT_PLANTED = "Now we'll have more carrots. Yay.",
		CARROT_SEEDS = "Yep, those are seeds!",
		CARTOGRAPHYDESK =
		{
			GENERIC = "We're mapping out the wilderness!",
			BURNING = "That's not a proper campfire!",
			BURNT = "Someone wasn't practicing fire safety.",
		},
		WATERMELON_SEEDS = "Yep, those are seeds!",
		CAVE_FERN = "There's some weird plants growing down here.",
		CHARCOAL = "You find a lot of these in fire pits.",
        CHESSPIECE_PAWN = "Pawns don't seem like statue material.",
        CHESSPIECE_ROOK =
        {
            GENERIC = "It's so lifelike!",
            STRUGGLE = "Hey, I think it's moving!",
        },
        CHESSPIECE_KNIGHT =
        {
            GENERIC = "What are you so worried about Woby? It's just a statue.",
            STRUGGLE = "Alright Woby, I stand corrected.",
        },
        CHESSPIECE_BISHOP =
        {
            GENERIC = "Woby doesn't seem to like it.",
            STRUGGLE = "It's coming to life!",
        },
        CHESSPIECE_MUSE = "It's just a statue.",
        CHESSPIECE_FORMAL = "Ugh. Who would want to be stuck wearing a suit forever?",
        CHESSPIECE_HORNUCOPIA = "I'm starting to get hungry just looking at it...",
        CHESSPIECE_PIPE = "It looks like one of those joke pipes you can mail in for.",
        CHESSPIECE_DEERCLOPS = "I like this one!",
        CHESSPIECE_BEARGER = "It looks just like him!",
        CHESSPIECE_MOOSEGOOSE =
        {
            "It's a shame things had to end the way they did.",
        },
        CHESSPIECE_DRAGONFLY = "If only we could've gotten along.",
		CHESSPIECE_MINOTAUR = "This statue is... a-maze-ing! Get it?",
        CHESSPIECE_BUTTERFLY = "It's not quite as good as a real bug collection, but close!",
        CHESSPIECE_ANCHOR = "Technically this could still work as a real anchor.",
        CHESSPIECE_MOON = "It tells folks to be-were! Get it?",
        CHESSPIECE_CARRAT = "I usually prefer badges to trophies, but I might make an exception.",
        CHESSPIECE_MALBATROSS = "She was pretty angry at us, wasn't she Woby?",
        CHESSPIECE_CRABKING = "The crabbiest sea monster I've ever met!",
        CHESSPIECE_TOADSTOOL = "At least this version doesn't smell like old mushrooms.",
        CHESSPIECE_STALKER = "Definitely on my top five list of skeletons.",
        CHESSPIECE_KLAUS = "Aw, it reminds me of the holidays.",
        CHESSPIECE_BEEQUEEN = "At least I'm not allergic to bees made out of stone.",
        CHESSPIECE_ANTLION = "She really shook you up, didn't she Woby?",
        CHESSPIECE_BEEFALO = "Aw don't be jealous Woby, you deserve a statue too!",
		CHESSPIECE_KITCOON = "They're pretty cute, but not as cute as you Woby.",
		CHESSPIECE_CATCOON = "It's not quite as exciting as a monster statue, is it?",
        CHESSPIECE_GUARDIANPHASE3 = "It's so lifelike, I feel like they're staring right at me!",
        CHESSPIECE_EYEOFTERROR = "Nothing to see here, folks! Ha ha, get it Woby?",
        CHESSPIECE_TWINSOFTERROR = "Is this one of those sculptures where the eyes follow you around the room?",

        CHESSJUNK1 = "I don't think they're going to get up anytime soon.",
        CHESSJUNK2 = "I don't think they're going to get up anytime soon.",
        CHESSJUNK3 = "I don't think they're going to get up anytime soon.",
		CHESTER = "Who's a good little monster? You are!",
		CHESTER_EYEBONE =
		{
			GENERIC = "No chewing on this bone, okay Woby?",
			WAITING = "Getting some well deserved shut-eye.",
		},
		COOKEDMANDRAKE = "Sorry little buddy.",
		COOKEDMEAT = "You can't beat cooking outdoors!",
		COOKEDMONSTERMEAT = "Is it supposed to have that weird aftertaste?",
		COOKEDSMALLMEAT = "A little meat is better than none.",
		COOKPOT =
		{
			COOKING_LONG = "This might take a while. Wanna see this cool bug I found in the meantime?",
			COOKING_SHORT = "Almost time to eat!",
			DONE = "Come and get it!",
			EMPTY = "Sure wish there was food in it.",
			BURNT = "It's uh... extra done!",
		},
		CORN = "Some corn on the cob sounds pretty good right about now.",
		CORN_COOKED = "I don't have anything to fund-raise for out here...",
		CORN_SEEDS = "We should plant these.",
        CANARY =
		{
			GENERIC = "Did you get lost too?",
			HELD = "Hey, no pecking!",
		},
        CANARY_POISONED = "This bird needs first aid!",

		CRITTERLAB = "What's wrong Woby? Is something in there?",
        CRITTER_GLOMLING = "It's small for a monster, but big for a bug.",
        CRITTER_DRAGONLING = "Play nice with Woby, okay?",
		CRITTER_LAMB = "Aww, you're like a dust bunny that came to life!",
        CRITTER_PUPPY = "You and Woby will get along great!",
        CRITTER_KITTEN = "I'm usually more of a dog person, but you're so cute!",
        CRITTER_PERDLING = "What a funny little turkey.",
		CRITTER_LUNARMOTHLING = "Mom would never let me keep a pet bug this big!",

		CROW =
		{
			GENERIC = "Finally, something I recognize from my bird guide!",
			HELD = "A pocket isn't really the best place for a bird.",
		},
		CUTGRASS = "Look, I can make a whistle with it! PHHWEEEE!",
		CUTREEDS = "Ms. Wickerbottom might need some more... reed-ing material.",
		CUTSTONE = "It wasn't too hard!",
		DEADLYFEAST = "Someone could get sick from eating that!", --unimplemented
		DEER =
		{
			GENERIC = "Hey Woby, do you guys go to the same barber?",
			ANTLER = "You could poke an eye out with those! Maybe he already did?",
		},
        DEER_ANTLER = "Hey, you dropped this!",
        DEER_GEMMED = "It can't be comfortable having a gem stuck in your forehead.",
		DEERCLOPS = "Woah! It's you!",
		DEERCLOPS_EYEBALL = "At least we got this souvenir.",
		EYEBRELLAHAT =	"It keeps an eye on me. Get it? Because it's a giant eyeball?",
		DEPLETED_GRASS =
		{
			GENERIC = "It hasn't grown back yet.",
		},
        GOGGLESHAT = "I feel more  adventurous already!",
        DESERTHAT = "It's important to dress appropriately for the environment.",
		DEVTOOL = "Weird! It looks like an axe, but...",
		DEVTOOL_NODEV = "Guess I haven't earned that badge yet.",
		DIRTPILE = "Woby, did you dig something up?",
		DIVININGROD =
		{
			COLD = "Getting colder... must've taken a wrong turn.", --singleplayer
			GENERIC = "Hey! This looks a lot like that radio!", --singleplayer
			HOT = "We're hot on the trail, Woby!", --singleplayer
			WARM = "Getting warm...", --singleplayer
			WARMER = "Warmer...", --singleplayer
		},
		DIVININGRODBASE =
		{
			GENERIC = "This looks important.", --singleplayer
			READY = "Maybe I can unlock it with something...", --singleplayer
			UNLOCKED = "It worked!", --singleplayer
		},
		DIVININGRODSTART = "Hey! This looks a lot like that radio!", --singleplayer
		DRAGONFLY = "Woah! It's a giant bug!",
		ARMORDRAGONFLY = "I still wish we could've been friends...",
		DRAGON_SCALES = "Was she a bug or a lizard?",
		DRAGONFLYCHEST = "We'll have to find something worthy of going in there.",
		DRAGONFLYFURNACE =
		{
			HAMMERED = "...That didn't fix it.",
			GENERIC = "Can I cook marshmallows over it though?", --no gems
			NORMAL = "Toasty!", --one gem
			HIGH = "Roasty!", --two gems
		},

        HUTCH = "Looks like we found another friend, Woby!",
        HUTCH_FISHBOWL =
        {
            GENERIC = "Aww, are you lost little guy?",
            WAITING = "Ah! I-I'm sure some peroxide and a bandage will fix him up.",
        },
		LAVASPIT =
		{
			HOT = "It's rude to spit at people!",
			COOL = "It's cool!",
		},
		LAVA_POND = "Probably not the best swimming hole.",
		LAVAE = "That's amazing!",
		LAVAE_COCOON = "I think it's resting.",
		LAVAE_PET =
		{
			STARVING = "This little guy needs some food!",
			HUNGRY = "Are you hungry, little guy?",
			CONTENT = "Aww, I think he's smiling!",
			GENERIC = "You're the best grub in the whole wide world!",
		},
		LAVAE_EGG =
		{
			GENERIC = "I can't wait for it to hatch!",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "It needs more warmth!",
			COMFY = "It looks pretty cozy.",
		},
		LAVAE_TOOTH = "Aw, they lost their first tooth!",

		DRAGONFRUIT = "Looks tasty.",
		DRAGONFRUIT_COOKED = "It makes sense that Dragon Fruit tastes better with fire.",
		DRAGONFRUIT_SEEDS = "Let's find some place to plant these.",
		DRAGONPIE = "Is it made from actual dragons?",
		DRUMSTICK = "Is it a good idea to eat raw meat...?",
		DRUMSTICK_COOKED = "That's better!",
		DUG_BERRYBUSH = "Come on berry bush, we're going on an adventure!",
		DUG_BERRYBUSH_JUICY = "Come on berry bush, we're going on an adventure!",
		DUG_GRASS = "Now I can plant it closer to camp.",
		DUG_MARSH_BUSH = "Hey Woby, do you see a good spot to plant this?",
		DUG_SAPLING = "Hey Woby, do you see a good spot to plant this?",
		DURIAN = "Yuck! What is that?",
		DURIAN_COOKED = "No thank you.",
		DURIAN_SEEDS = "Yep, those are seeds!",
		EARMUFFSHAT = "Some of us don't have ear fluff of our own, Woby.",
		EGGPLANT = "Even in the wilderness you have to eat your vegetables.",
		EGGPLANT_COOKED = "Oh, it's much better cooked!",
		EGGPLANT_SEEDS = "We should find a place to plant these.",

		ENDTABLE =
		{
			BURNT = "That's how forest fires get started!",
			GENERIC = "Is somebody decorating out here?",
			EMPTY = "Hey... I think I saw something move under there.",
			WILTED = "Those flowers are looking pretty sad.",
			FRESHLIGHT = "Ta-da! Light!",
			OLDLIGHT = "Looks like we need to replace a bulb.", -- will be wilted soon, light radius will be very small at this point
		},
		DECIDUOUSTREE =
		{
			BURNING = "You're supposed to chop the tree first, THEN build the fire!",
			BURNT = "That tree just couldn't wait to be a campfire...",
			CHOPPED = "This tree looks stumped. Heh, nice one Walter.",
			POISON = "Woah! I've never seen a tree with teeth before!",
			GENERIC = "Did you know the word deciduous means to \"fall off\"?",
		},
		ACORN = "I wonder if there's any squirrels around.",
        ACORN_SAPLING = "More firewood in the making!",
		ACORN_COOKED = "Nutty.",
		BIRCHNUTDRAKE = "Hey little guy! What's got you all worked up?",
		EVERGREEN =
		{
			BURNING = "You're supposed to chop the tree first, THEN build the fire!",
			BURNT = "That tree just couldn't wait to be a campfire...",
			CHOPPED = "This tree looks stumped. Heh, nice one Walter.",
			GENERIC = "They're called \"evergreen\" because... well you get the idea.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "You're supposed to chop the tree first, THEN build the fire!",
			BURNT = "That tree just couldn't wait to be a campfire...",
			CHOPPED = "This tree looks stumped. Heh, nice one Walter.",
			GENERIC = "What a scraggly tree.",
		},
		TWIGGYTREE =
		{
			BURNING = "You're supposed to chop the tree first, THEN build the fire!",
			BURNT = "That tree just couldn't wait to be a campfire...",
			CHOPPED = "This tree looks stumped. Heh, nice one Walter.",
			GENERIC = "It's more like a big stick than a tree.",
			DISEASED = "Maybe it's infested with beetles. I should check!", --unimplemented
		},
		TWIGGY_NUT_SAPLING = "It'll grow up into a big tree someday.",
        TWIGGY_OLD = "It's barely holding together.",
		TWIGGY_NUT = "Hey Woby, you dig a hole and I'll plant it.",
		EYEPLANT = "Eye bet it's friendly!",
		INSPECTSELF = "A Pinetree Pioneer through and through!",
		FARMPLOT =
		{
			GENERIC = "Mom never let me in her garden... not since the Slug Incident.",
			GROWING = "Hey! I'm pretty good at this!",
			NEEDSFERTILIZER = "It needs something to help it grow...",
			BURNT = "Darnit, now I have to start all over!",
		},
		FEATHERHAT = "And I thought my bird watching badge was a feather in my cap!",
		FEATHER_CROW = "Looks like a black bird feather.",
		FEATHER_ROBIN = "Looks like a redbird feather.",
		FEATHER_ROBIN_WINTER = "Looks like a snowbird feather.",
		FEATHER_CANARY = "Looks like a canary feather.",
		FEATHERPENCIL = "I feel like I should write something poetic with this...",
        COOKBOOK = "Looks like I've got a new guide to memorize!",
		FEM_PUPPET = "Don't worry, a Pinetree Pioneer always helps those in need!", --single player
		FIREFLIES =
		{
			GENERIC = "I wish I had a jar.",
			HELD = "Hope they get along with the other bugs in my pockets.",
		},
		FIREHOUND = "Who's a good boy?",
		FIREPIT =
		{
			EMBERS = "We need more fuel for the fire!",
			GENERIC = "Anyone want to hear a scary story?",
			HIGH = "Woah! I don't think that's safe...",
			LOW = "I might need to feed the fire a bit.",
			NORMAL = "It's the perfect temperature for roasting marshmallows!",
			OUT = "The fire pit's already built, all we need is more wood!",
		},
		COLDFIREPIT =
		{
			EMBERS = "We need more fuel for the fire!",
			GENERIC = "Anyone want to hear a scary story?",
			HIGH = "Woah! I don't think that's safe...",
			LOW = "I might need to feed the fire a bit",
			NORMAL = "It's the perfect temperature for... cold marshmallows?",
			OUT = "The fire pit's already built, all we need is more wood!",
		},
		FIRESTAFF = "I'd better keep this away from the younger kids... and Willow.",
		FIRESUPPRESSOR =
		{
			ON = "That should keep us from setting the camp on fire... hopefully.",
			OFF = "It's conserving its energy.",
			LOWFUEL = "We'd better give it some more fuel.",
		},

		FISH = "I'm great at catching fish! I got a badge and everything!",
		FISHINGROD = "It's a fishing rod, you use it for fishing.",
		FISHSTICKS = "Delicious, nutritious and full of fishes.",
		FISHTACOS = "The s'more of fish dishes!",
		FISH_COOKED = "Catching and cooking your own fish is what camping is all about!",
		FLINT = "This should come in handy!",
		FLOWER =
		{
            GENERIC = "Are there any bugs on it?",
            ROSE = "Funny, this isn't the type of rose you usually see in the wild.",
        },
        FLOWER_WITHERED = "Should I water it more? Or water it less?!",
		FLOWERHAT = "Hey, that looks swell!",
		FLOWER_EVIL = "Woby, what's wrong? It's just a flower.",
		FOLIAGE = "This would be great for starting a campfire.",
		FOOTBALLHAT = "Oh, football! Yeah I'm uh... great at football...",
        FOSSIL_PIECE = "The bones of an ancient creature!",
        FOSSIL_STALKER =
        {
			GENERIC = "It's still missing something.",
			FUNNY = "\"The arm bone's connected to the...\" which bone was it...",
			COMPLETE = "I think we figured it out Woby!",
        },
        STALKER = "A real living skeleton!",
        STALKER_ATRIUM = "Maybe he knows something about the bug people that lived here!",
        STALKER_MINION = "I wonder if I can catch one!",
        THURIBLE = "Oof, that's a strong smell.",
        ATRIUM_OVERGROWTH = "What does it mean?!",
		FROG =
		{
			DEAD = "Poor little guy.",
			GENERIC = "That doesn't look like the frogs in my handbook...",
			SLEEPING = "Have sweet, fly-filled dreams.",
		},
		FROGGLEBUNWICH = "You can make anything into a sandwich if you try hard enough.",
		FROGLEGS = "I don't think they're ripe yet, they're still green.",
		FROGLEGS_COOKED = "It doesn't look as fancy as I imagined.",
		FRUITMEDLEY = "It's good for you!",
		FURTUFT = "It's so soft!",
		GEARS = "These don't usually occur in nature.",
		GHOST = "Ha, and people tried to tell me ghosts aren't real.",
		GOLDENAXE = "I feel like you could use gold for better things.",
		GOLDENPICKAXE = "It makes sense if you don't think about it.",
		GOLDENPITCHFORK = "Now I can be part of a FANCY angry mob.",
		GOLDENSHOVEL = "Instead of digging up gold, I can dig with gold!",
		GOLDNUGGET = "Ow... I bit it, isn't that a thing people do?",
		GRASS =
		{
			BARREN = "This grass needs something to help it grow.",
			WITHERED = "It's too hot out for anything to grow.",
			BURNING = "Hey! Brush fires destroy forests!",
			GENERIC = "A patch of grass. With bugs in it, if we're lucky.",
			PICKED = "Can't take anymore from it.",
			DISEASED = "That's... not how it's supposed to look, is it?", --unimplemented
			DISEASING = "Something seems off.", --unimplemented
		},
		GRASSGEKKO =
		{
			GENERIC = "That patch of grass is alive!",
			DISEASED = "Oh no... I think it's sick.", --unimplemented
		},
		GREEN_CAP = "It's not usually smart to eat unfamiliar mushrooms.",
		GREEN_CAP_COOKED = "It's probably safe now that it's cooked, right?",
		GREEN_MUSHROOM =
		{
			GENERIC = "It doesn't look like any of the mushrooms in my handbook.",
			INGROUND = "There's a mushroom hiding in there!",
			PICKED = "Maybe it will grow back.",
		},
		GUNPOWDER = "I better make sure none of the younger kids play with this.",
		HAMBAT = "Don't get any ideas, Woby.",
		HAMMER = "Sometimes you need to break stuff to make stuff.",
		HEALINGSALVE = "Never hurts to be prepared!",
		HEATROCK =
		{
			FROZEN = "Almost as chilling as one of my campfire stories. Right?",
			COLD = "Ahh... nice and cold.",
			GENERIC = "That's a nice rock.",
			WARM = "Almost as good as cuddling up with Woby.",
			HOT = "Hot! Hot rock!",
		},
		HOME = "Knock, knock!",
		HOMESIGN =
		{
			GENERIC = "Someone has bad handwriting.",
            UNWRITTEN = "A blank sign... not very helpful.",
			BURNT = "Hopefully it didn't say anything important.",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "Someone has bad handwriting.",
            UNWRITTEN = "Well... I guess SOMETHING is in that direction.",
			BURNT = "Hopefully it didn't say anything important.",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "Someone has bad handwriting.",
            UNWRITTEN = "Well... I guess SOMETHING is in that direction.",
			BURNT = "Hopefully it didn't say anything important.",
		},
		HONEY = "Wish I had some toast.",
		HONEYCOMB = "Just don't use it to comb your hair.",
		HONEYHAM = "Sweet pig meat!",
		HONEYNUGGETS = "I loved these when I was little.",
		HORN = "That'll make a decent bugle.",
		HOUND = "Hey Woby, another dog for you to play with!",
		HOUNDCORPSE =
		{
			GENERIC = "It's a hound, of corpse!",
			BURNING = "Poor thing...",
			REVIVING = "Phew, looks like they're okay after all!",
		},
		HOUNDBONE = "You probably shouldn't chew on those, Woby.",
		HOUNDMOUND = "I bet there's something interesting hiding in there!",
		ICEBOX = "This should keep our food supplies fresh!",
		ICEHAT = "There's got to be a better way to stay cool...",
		ICEHOUND = "Friends of yours, Woby?",
		INSANITYROCK =
		{
			ACTIVE = "Woah! That was crazy!",
			INACTIVE = "That's definitely got a supernatural explanation.",
		},
		JAMMYPRESERVES = "Now we're really in a jam...",

		KABOBS = "Food is always better when it's on a stick.",
		KILLERBEE =
		{
			GENERIC = "(Sigh). All bees are killer bees when you're allergic.",
			HELD = "This is fine...",
		},
		KNIGHT = "Just horsing around...",
		KOALEFANT_SUMMER = "The trail led us right to it.",
		KOALEFANT_WINTER = "So you're the one who left those tracks!",
		KRAMPUS = "Hey! Did you rifle through my supplies?",
		KRAMPUS_SACK = "It smells... goat-y.",
		LEIF = "They've come to take their revenge!",
		LEIF_SPARSE = "They've come to take their revenge!",
		LIGHTER  = "Way easier than rubbing sticks together, but not as fun.",
		LIGHTNING_ROD =
		{
			CHARGED = "It's crackling with energy!",
			GENERIC = "That's where we keep the lightning.",
		},
		LIGHTNINGGOAT =
		{
			GENERIC = "That's a weird looking mountain goat.",
			CHARGED = "Did that goat just get struck by lightning?!",
		},
		LIGHTNINGGOATHORN = "The goat gave me a souvenir.",
		GOATMILK = "I don't think milk is supposed to crackle...",
		LITTLE_WALRUS = "I've never seen a real walrus up close!",
		LIVINGLOG = "Yep, this log's definitely haunted.",
		LOG =
		{
			BURNING = "Doing what logs do.",
			GENERIC = "Firewood!",
		},
		LUCY = "She seems nice.",
		LUREPLANT = "Hey, free meat!",
		LUREPLANTBULB = "I'll plant this somewhere far away from camp.",
		MALE_PUPPET = "Don't worry, a Pinetree Pioneer always helps those in need!", --single player

		MANDRAKE_ACTIVE = "Follow the leader!",
		MANDRAKE_PLANTED = "Hey, what's that hiding down there?",
		MANDRAKE = "It's got a little face!",

        MANDRAKESOUP = "Poor little guy.",
        MANDRAKE_COOKED = "It feels wrong...",
        MAPSCROLL = "A map! ...With nothing on it.",
        MARBLE = "Maybe I'll make a fancy fire pit.",
        MARBLEBEAN = "I'm pretty sure it's just a rock.",
        MARBLEBEAN_SAPLING = "...Okay, so I was wrong about it being \"just a rock\".",
        MARBLESHRUB = "This place is weird.",
        MARBLEPILLAR = "Feels like I'm in a museum.",
        MARBLETREE = "I don't think it'll make for good firewood.",
        MARSH_BUSH =
        {
			BURNT = "Guess it wasn't a bog monster after all.",
            BURNING = "If it's a bog monster, it's pretty committed to its disguise.",
            GENERIC = "It might be a bog monster in disguise.",
            PICKED = "Ow!! Does anyone have a bandage?!",
        },
        BURNT_MARSH_BUSH = "Guess it wasn't a bog monster after all.",
        MARSH_PLANT = "It's just a plant.",
        MARSH_TREE =
        {
            BURNING = "A swamp fire!",
            BURNT = "It won't bother us again.",
            CHOPPED = "Firewood is firewood.",
            GENERIC = "Not a good tree for climbing.",
        },
        MAXWELL = "Get him, Woby!",--single player
        MAXWELLHEAD = "He sure does have a big head.",--removed
        MAXWELLLIGHT = "That's a pretty neat trick.",--single player
        MAXWELLLOCK = "It looks like something should go in there.",--single player
        MAXWELLTHRONE = "That chair is just screaming \"cursed\".",--single player
        MEAT = "I hope I don't get sick from eating this...",
        MEATBALLS = "They're the best part of spaghetti anyway.",
        MEATRACK =
        {
            DONE = "Yes! The jerky's ready!",
            DRYING = "You have to be patient, Woby.",
            DRYINGINRAIN = "I don't think that's going to work.",
            GENERIC = "We should make some jerky!",
            BURNT = "Nooo the jerky!",
            DONE_NOTMEAT = "I think it's done!",
            DRYING_NOTMEAT = "While we're waiting, does anyone want to see this bug I found?",
            DRYINGINRAIN_NOTMEAT = "I probably should've planned ahead for this.",
        },
        MEAT_DRIED = "That's some tasty jerky!",
        MERM = "A bog monster! I knew they were real!",
        MERMHEAD =
        {
            GENERIC = "Woah, it's not made of rubber! I think it's real!",
            BURNT = "Darnit, there goes my evidence.",
        },
        MERMHOUSE =
        {
            GENERIC = "I bet that wood is full of termites.",
            BURNT = "Hopefully all the termites made it out safely.",
        },
        MINERHAT = "Being able to see makes exploring a lot easier.",
        MONKEY = "I've only ever seen them in zoos!",
        MONKEYBARREL = "I'm sure it's just an ordinary barrel.",
        MONSTERLASAGNA = "It looks kind of suspicious... maybe Woby will want it.",
        FLOWERSALAD = "Even scavenged leaves can be food in the wilderness!",
        ICECREAM = "Don't eat too much or you'll get a stomach ache.",
        WATERMELONICLE = "Further proof that all food is better on a stick!",
        TRAILMIX = "The snack of choice for all intrepid explorers!",
        HOTCHILI = "Nothing warms you up like a big bowl of chili.",
        GUACAMOLE = "Now all we need are some chips!",
        MONSTERMEAT = "Uhh Woby? Do you want this?",
        MONSTERMEAT_DRIED = "Hey Woby, it's your favourite!",
        MOOSE = "Woah! Now THAT should be Canada's national animal!",
        MOOSE_NESTING_GROUND = "Looks like we found its nest.",
        MOOSEEGG = "I can't wait for them to hatch!",
        MOSSLING = "Aw, they're kind of cute!",
        FEATHERFAN = "I'm a big fan of staying cool. Get it, because it's a fan?",
        MINIFAN = "Those are for little kids!'",
        GOOSE_FEATHER = "Goosey.",
        STAFF_TORNADO = "What a pane... heh.",
        MOSQUITO =
        {
            GENERIC = "Tiny vampires of the insect world.",
            HELD = "Now I'm all itchy, I hope you're happy.",
        },
        MOSQUITOSACK = "Good thing I'm not... squeamish...",
        MOUND =
        {
            DUG = "Well, my curiosity is satisfied.",
            GENERIC = "I wonder if I'll find a skeleton down there...",
        },
        NIGHTLIGHT = "It really adds to the atmosphere.",
        NIGHTMAREFUEL = "People always say my campfire stories are nightmare fuel.",
        NIGHTSWORD = "That deeeefinitely has a curse on it.",
        NITRE = "Nitre here nor there. Heh...",
        ONEMANBAND = "I've never played any of these instruments, but I'm sure I'll do great!",
        OASISLAKE =
		{
			GENERIC = "We're saved, Woby!",
			EMPTY = "An invisible lake?",
		},
        PANDORASCHEST = "There's got to be something good inside!",
        PANFLUTE = "It can't be too hard to play.",
        PAPYRUS = "Just some paper with nothing on it.",
        WAXPAPER = "Mom used to use something like this for baking.",
        PENGUIN = "I've never seen one up close before!",
        PERD = "Hey, come back! We just want to eat you!",
        PEROGIES = "The perfect size to pop in your mouth!",
        PETALS = "Hope the bees aren't too mad at me.",
        PETALS_EVIL = "I feel funny... did I accidentally pick some poison oak?",
        PHLEGM = "Looks like a big booger.",
        PICKAXE = "It's all mine!",
        PIGGYBACK = "This is giving me inspiration for a new campfire story...",
        PIGHEAD =
        {
            GENERIC = "Don't eat it Woby!",
            BURNT = "Smells like burnt bacon.",
        },
        PIGHOUSE =
        {
            FULL = "I can hear oinking coming from inside...",
            GENERIC = "Why have a house when you could just camp all the time?",
            LIGHTSOUT = "Did they go to sleep?",
            BURNT = "That's why you don't play with fire.",
        },
        PIGKING = "He looks like the Pioneer Leader of this troop.",
        PIGMAN =
        {
            DEAD = "His bacon couldn't be saved.",
            FOLLOWER = "See? We can all get along just fine.",
            GENERIC = "It's a walking, talking pig!",
            GUARD = "He looks pretty serious.",
            WEREPIG = "Double monster!",
        },
        PIGSKIN = "Is this what people are always tossing around?",
        PIGTENT = "It's a pretty decent tent.",
        PIGTORCH = "Handy for finding your way in the dark.",
        PINECONE = "I should find a good spot to plant this.",
        PINECONE_SAPLING = "One day you'll be a nice big tree.",
        LUMPY_SAPLING = "Natural selection hasn't gotten to this one yet.",
        PITCHFORK = "I'm more of a forager than a farmer.",
        PLANTMEAT = "Does this count as eating my vegetables?",
        PLANTMEAT_COOKED = "It has the weirdest flavour...",
        PLANT_NORMAL =
        {
            GENERIC = "Guessing what it's going to be is half the fun.",
            GROWING = "I wish plants could grow as fast as you do Woby.",
            READY = "Fresh supplies!",
            WITHERED = "Maybe it needs some water?",
        },
        POMEGRANATE = "Fruit guts!",
        POMEGRANATE_COOKED = "I thought it would taste better.",
        POMEGRANATE_SEEDS = "Where's a good spot to plant this?",
        POND = "That'll make a swell swimming hole!",
        POOP = "It's a natural part of nature!",
        FERTILIZER = "Plants love poop.",
        PUMPKIN = "Is it Fall already?",
        PUMPKINCOOKIE = "It's made from a vegetable, so it's healthy.",
        PUMPKIN_COOKED = "Hot, mushy pumpkin guts.",
        PUMPKIN_LANTERN = "I heard a radio show once about a horseman with a pumpkin for a head!",
        PUMPKIN_SEEDS = "Woby, do you see a good spot to plant these?",
        PURPLEAMULET = "Do you hear the whispering too, Woby?",
        PURPLEGEM = "Purple's usually a friendly colour.",
        RABBIT =
        {
            GENERIC = "A real jackalope! Come here little guy!",
            HELD = "Look, the antlers aren't held on with paste or anything!",
        },
        RABBITHOLE =
        {
            GENERIC = "We found its den!",
            SPRING = "Looks like a cave-in.",
        },
        RAINOMETER =
        {
            GENERIC = "A Pinetree Pioneer can smell rain coming a mile away.",
            BURNT = "It wasn't really that useful anyway.",
        },
        RAINCOAT = "Gotta be prepared for the elements!",
        RAINHAT = "I wonder if I could make one for Woby too.",
        RATATOUILLE = "Apparently there's no actual rats in it.",
        RAZOR = "I found a whisker on my chin, I'm sure my beard will come in any day now.",
        REDGEM = "I think this gem might be magic.",
        RED_CAP = "That definitely looks poisonous.",
        RED_CAP_COOKED = "Did cooking it make it less poisonous?",
        RED_MUSHROOM =
        {
            GENERIC = "Probably shouldn't pick that one.",
            INGROUND = "There's a mushroom hiding down there.",
            PICKED = "Maybe it will grow back?",
        },
        REEDS =
        {
            BURNING = "Uh oh, who wasn't practicing fire safety?",
            GENERIC = "A pretty normal thing to see in a swamp.",
            PICKED = "Nothing left to gather here.",
        },
        RELIC = "It's even older than the furniture at my grandpa's house.",
        RUINS_RUBBLE = "We can fix it up with some Pinetree Pioneer determination!",
        RUBBLE = "A bunch of really old rocks. I guess all rocks are old...",
        RESEARCHLAB =
        {
            GENERIC = "I never knew science was such an important part of survival.",
            BURNT = "Did that look like a campfire?!",
        },
        RESEARCHLAB2 =
        {
            GENERIC = "They never taught us about alchemy in school.",
            BURNT = "I wish things would stop catching fire.",
        },
        RESEARCHLAB3 =
        {
            GENERIC = "Is it really magic?",
            BURNT = "I guess the magic wasn't fireproof.",
        },
        RESEARCHLAB4 =
        {
            GENERIC = "I don't really understand how it's supposed to work.",
            BURNT = "I guess that's one way of putting an end to the mystery.",
        },
        RESURRECTIONSTATUE =
        {
            GENERIC = "I thought bringing back the dead involved more levers and electricity.",
            BURNT = "What a waste of supplies...",
        },
        RESURRECTIONSTONE = "It must've been used by an ancient civilization!",
        ROBIN =
        {
            GENERIC = "Wonder how they got here?",
            HELD = "Are you happy in my pocket?",
        },
        ROBIN_WINTER =
        {
            GENERIC = "My handbook doesn't show them in this colour...",
            HELD = "They're extra downy.",
        },
        ROBOT_PUPPET = "Don't worry, a Pinetree Pioneer always helps those in need!", --single player
        ROCK_LIGHT =
        {
            GENERIC = "A crusted over lava pit.",--removed
            OUT = "Looks fragile.",--removed
            LOW = "The lava's crusting over.",--removed
            NORMAL = "Nice and comfy.",--removed
        },
        CAVEIN_BOULDER =
        {
            GENERIC = "Come on Woby, give me a hand moving this!",
            RAISED = "I can't get to it!",
        },
        ROCK = "It would be more useful in smaller pieces.",
        PETRIFIED_TREE = "What could've turned it to stone?",
        ROCK_PETRIFIED_TREE = "What could've turned it to stone?",
        ROCK_PETRIFIED_TREE_OLD = "What could've turned it to stone?",
        ROCK_ICE =
        {
            GENERIC = "This will really give you the chills.",
            MELTED = "Ice sometimes does that.",
        },
        ROCK_ICE_MELTED = "Ice sometimes does that.",
        ICE = "This will really give you the chills.",
        ROCKS = "Maybe I could make a fire pit.",
        ROOK = "I wonder how it works?",
        ROPE = "An essential part of any adventuring kit.",
        ROTTENEGG = "That's definitely gone off.",
        ROYAL_JELLY = "It was a royal pain to get.",
        JELLYBEAN = "Jellybeans are for little kids...",
        SADDLE_BASIC = "Guess you need a saddle to ride some animals.",
        SADDLE_RACE = "See? Bugs are helpful in lots of ways!",
        SADDLE_WAR = "It's almost as comfy as sitting in Woby's fur.",
        SADDLEHORN = "It can't be comfortable wearing a saddle all the time.",
        SALTLICK = "Don't eat that Woby, it's for the beefalo!",
        BRUSH = "Woby loves getting her fur brushed.",
		SANITYROCK =
		{
			ACTIVE = "Hey, where did that come from?",
			INACTIVE = "I swear there was something here a second ago.",
		},
		SAPLING =
		{
			BURNING = "Someone grab some water!",
			WITHERED = "I guess it's too hot out.",
			GENERIC = "It's a baby tree.",
			PICKED = "Now it'll never grow into a tree.",
			DISEASED = "That doesn't look healthy.", --removed
			DISEASING = "Is it supposed to look like that?", --removed
		},
   		SCARECROW =
   		{
			GENERIC = "Who'd be scared of that?",
			BURNING = "I guess that makes it look a little scarier.",
			BURNT = "Not much use to us now.",
   		},
   		SCULPTINGTABLE=
   		{
			EMPTY = "Time for some arts and crafts.",
			BLOCK = "This doesn't look too hard! Or does it...",
			SCULPTURE = "Hey Woby, look! I'm getting good at this!",
			BURNT = "Don't we have a perfectly good fire pit?",
   		},
        SCULPTURE_KNIGHTHEAD = "That's one way to get a head. Get it?",
		SCULPTURE_KNIGHTBODY =
		{
			COVERED = "There's something weird about it.",
			UNCOVERED = "It's all broken up.",
			FINISHED = "That looks better.",
			READY = "Huh? I think I hear something moving in there.",
		},
        SCULPTURE_BISHOPHEAD = "What's that doing here?",
		SCULPTURE_BISHOPBODY =
		{
			COVERED = "One part of this statue looks older than the other.",
			UNCOVERED = "Can you sniff out the missing piece Woby?",
			FINISHED = "Finished!",
			READY = "Huh? I think I hear something moving in there.",
		},
        SCULPTURE_ROOKNOSE = "How did it get there?",
		SCULPTURE_ROOKBODY =
		{
			COVERED = "I think there's something else hiding in that marble.",
			UNCOVERED = "There's something missing...",
			FINISHED = "That was easy enough.",
			READY = "Huh? I think I hear something moving in there.",
		},
        GARGOYLE_HOUND = "Wouldn't it be funny if it came to life?",
        GARGOYLE_WEREPIG = "Don't worry Woby, it's just a statue.",
		SEEDS = "It's nice of the birds to share.",
		SEEDS_COOKED = "You make do with what you have when you're out in the wilderness.",
		SEWING_KIT = "Better make sure all my badges are secure!",
		SEWING_TAPE = "It's so handy!",
		SHOVEL = "You never know what you'll find if you do a little digging.",
		SILK = "Spiders are pretty useful.",
		SKELETON = "Is it a real skeleton?",
		SCORCHED_SKELETON = "I think the time for first aid has long passed.",
		SKULLCHEST = "There's got to be something good in there.", --removed
		SMALLBIRD =
		{
			GENERIC = "Hey little bird! Anything you want to tell me?",
			HUNGRY = "Feeling a bit... peckish? Heh... you know, because you're a bird?",
			STARVING = "Oh no! Did I forget to feed you?",
			SLEEPING = "Shhh, you have to be extra quiet Woby.",
		},
		SMALLMEAT = "Just a little meat.",
		SMALLMEAT_DRIED = "Barely a bite of jerky.",
		SPAT = "I bet you're really a big softie!",
		SPEAR = "It has a point... heh...",
		SPEAR_WATHGRITHR = "No Woby, that's not a stick! Well, I guess it IS a stick...",
		WATHGRITHRHAT = "Maybe Pinetree Pioneers should start wearing helmets instead.",
		SPIDER =
		{
			DEAD = "Aw, poor little guy.",
			GENERIC = "Woah, you're a big spider!",
			SLEEPING = "Don't mind me!",
		},
		SPIDERDEN = "Hey, that must be where the spiders live! It's huge!",
		SPIDEREGGSACK = "Aww, it's full of baby spiders!",
		SPIDERGLAND = "This would be a good addition to my first aid kit.",
		SPIDERHAT = "Woby keeps growling at me when I wear it...",
		SPIDERQUEEN = "I've never heard of spiders having a queen, that's so interesting!",
		SPIDER_WARRIOR =
		{
			DEAD = "Sorry, you started it!",
			GENERIC = "Look at the colouring on that one!",
			SLEEPING = "I should probably leave them alone...",
		},
		SPOILED_FOOD = "I probably shouldn't eat this...",
        STAGEHAND =
        {
			AWAKE = "Maybe it wants to roast marshmallows too?",
			HIDING = "Woby, what's wrong? It's just a table.",
        },
        STATUE_MARBLE =
        {
            GENERIC = "I wonder who made these?",
            TYPE1 = "It looks like something from a museum.",
            TYPE2 = "It's nice, I guess.",
            TYPE3 = "That one's just asking for birds to land on it.", --bird bath type statue
        },
		STATUEHARP = "I don't think it has an ear for music. Heh... good one, Walter.",
		STATUEMAXWELL = "I'm starting to think that Maxwell guy might be a bit full of himself.",
		STEELWOOL = "For making especially scratchy sweaters.",
		STINGER = "Aaaaah! Keep it away, please!",
		STRAWHAT = "That hat would never pass uniform inspection.",
		STUFFEDEGGPLANT = "A vegetable stuffed with more vegetable.",
		SWEATERVEST = "This doesn't look like good adventuring wear.",
		REFLECTIVEVEST = "Do I look as cool as I feel?",
		HAWAIIANSHIRT = "This DEFINITELY wouldn't pass uniform inspection.",
		TAFFY = "Don't eat too much or you'll get a stomach ache.",
		TALLBIRD = "Woah! Do you fly? Or are you more like an ostrich?",
		TALLBIRDEGG = "What a huge egg!",
		TALLBIRDEGG_COOKED = "That's just how nature goes sometimes.",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Come on Woby, help me warm it up.",
			GENERIC = "It's hatching! It's really hatching!",
			HOT = "Uh oh, it's going to be a fried egg if we don't cool it down.",
			LONG = "How long does it take for these to hatch?",
			SHORT = "It'll hatch any day now, I'm positive!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "She was protecting her nest...",
			PICKED = "Invisible eggs? Oh, no it's just empty.",
		},
		TEENBIRD =
		{
			GENERIC = "Nobody understands us, do they?",
			HUNGRY = "Hungry? I'll see what I have.",
			STARVING = "They're just grouchy because they're hungry.",
			SLEEPING = "Sleep well!",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Come on Woby, we've got some exploring to do!", --single player
			GENERIC = "That definitely looks like a magical... something.", --single player
			LOCKED = "Hm, it still needs something...", --single player
			PARTIAL = "I think I've almost got it, Woby!", --single player
		},
		TELEPORTATO_BOX = "I wonder what's inside?", --single player
		TELEPORTATO_CRANK = "This looks complicated...", --single player
		TELEPORTATO_POTATO = "What is this supposed to be, exactly?", --single player
		TELEPORTATO_RING = "This looks important.", --single player
		TELESTAFF = "But getting there is half the fun!",
		TENT =
		{
			GENERIC = "I always sleep better in a tent.",
			BURNT = "I guess I set it up too close to the campfire.",
		},
		SIESTAHUT =
		{
			GENERIC = "A shady spot for a quick nap.",
			BURNT = "What a waste of supplies...",
		},
		TENTACLE = "I want to see the creature it's attached to!",
		TENTACLESPIKE = "A souvenir from the swamp creature.",
		TENTACLESPOTS = "You can find a use for almost anything in nature.",
		TENTACLE_PILLAR = "I kind of want to poke it.",
        TENTACLE_PILLAR_HOLE = "Hey, there's a tunnel! Let's go Woby!",
		TENTACLE_PILLAR_ARM = "Are these all from the same creature?",
		TENTACLE_GARDEN = "That's a weird looking pillar.",
		TOPHAT = "Seems a bit out of place out here in the wilderness.",
		TORCH = "Is this what they use in England instead of flashlights?",
		TRANSISTOR = "Of course I know what it is! It's uh... um...",
		TRAP = "We learned how to make them in the Pinetree Pioneers.",
		TRAP_TEETH = "We didn't make traps like these in the Pinetree Pioneers...",
		TRAP_TEETH_MAXWELL = "That could hurt someone!", --single player
		TREASURECHEST =
		{
			GENERIC = "It isn't a toy chest, it's a very grownup SUPPLY chest.",
			BURNT = "My stuff!!",
		},
		TREASURECHEST_TRAP = "There might be cursed pirate gold inside!",
		SACRED_CHEST =
		{
			GENERIC = "There HAS to be something good in there, just look at it!",
			LOCKED = "How do we get it open? Any ideas, Woby?",
		},
		TREECLUMP = "Come on, trees! I just want to see what's over there!", --removed

		TRINKET_1 = "These will make perfect slingshot ammo.", --Melted Marbles
		TRINKET_2 = "I'd rather have a bugle.", --Fake Kazoo
		TRINKET_3 = "That's easy, I know how to tie lots of knots!", --Gord's Knot
		TRINKET_4 = "Is it just me, or do his eyes follow me around?", --Gnome
		TRINKET_5 = "I wonder if we'll ever explore outer space.", --Toy Rocketship
		TRINKET_6 = "Uh oh, did the robot drop these?", --Frazzled Wires
		TRINKET_7 = "That's kid stuff.", --Ball and Cup
		TRINKET_8 = "I'm sure I'll find a use for it.", --Rubber Bung
		TRINKET_9 = "Never know when you'll need a spare button.", --Mismatched Buttons
		TRINKET_10 = "I'm sure these will bring a smile to someone's face. Get it?", --Dentures
		TRINKET_11 = "He said he loves when I talk about my bug collection!", --Lying Robot
		TRINKET_12 = "Still wriggling.", --Dessicated Tentacle
		TRINKET_13 = "I thought she was looking the other way a second ago...", --Gnomette
		TRINKET_14 = "My mom would kill me if I cracked her fine china.", --Leaky Teacup
		TRINKET_15 = "I'm not really interested in board games.", --Pawn
		TRINKET_16 = "I'm not really interested in board games.", --Pawn
		TRINKET_17 = "One less utensil to pack with your camping gear!", --Bent Spork
		TRINKET_18 = "Seems like a normal wooden horse.", --Trojan Horse
		TRINKET_19 = "I'm too mature for toys.", --Unbalanced Top
		TRINKET_20 = "Woby likes it.", --Backscratcher
		TRINKET_21 = "Whoops, it got kind of bent.", --Egg Beater
		TRINKET_22 = "I like a good yarn. Heh...", --Frayed Yarn
		TRINKET_23 = "Protect your heels!", --Shoehorn
		TRINKET_24 = "Woby doesn't seem to like it very much.", --Lucky Cat Jar
		TRINKET_25 = "It doesn't even smell like a real pine tree!", --Air Unfreshener
		TRINKET_26 = "One less dish to wash!", --Potato Cup
		TRINKET_27 = "I wonder if I can use it to pick up radio signals...", --Coat Hanger
		TRINKET_28 = "I'm not really interested in board games.", --Rook
        TRINKET_29 = "I'm not really interested in board games.", --Rook
        TRINKET_30 = "They're kind of boring once you've seen the bigger version.", --Knight
        TRINKET_31 = "They're kind of boring once you've seen the bigger version.", --Knight
        TRINKET_32 = "Will it tell me my future?", --Cubic Zirconia Ball
        TRINKET_33 = "Aw, I thought it was a real spider...", --Spider Ring
        TRINKET_34 = "Nothing bad ever happened from wishing on a monkey's paw!", --Monkey Paw
        TRINKET_35 = "Looks like someone already drank it.", --Empty Elixir
        TRINKET_36 = "Those are just fakes, I want to see real vampire teeth!", --Faux fangs
        TRINKET_37 = "I hope the vampire's okay.", --Broken Stake
        TRINKET_38 = "I can almost see into space with these!", -- Binoculars Griftlands trinket
        TRINKET_39 = "I guess my hands can take turns.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "I don't know what we'd be measuring out here.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "Looks like a slime monster escaped.", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "It looks like someone mashed two toys together.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "Another toy that I'm way too mature for.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "Huh. I can't find that plant in my handbook.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "It doesn't pick up any of my favourite stations...", -- Odd Radio ONI trinket
        TRINKET_46 = "It looks like something from outer space.", -- Hairdryer ONI trinket

        -- The numbers align with the trinket numbers above.
        LOST_TOY_1  = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_2  = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_7  = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_10 = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_11 = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_14 = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_18 = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_19 = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_42 = "Hey! I could've sworn I didn't see anything there a second ago!",
        LOST_TOY_43 = "Hey! I could've sworn I didn't see anything there a second ago!",

        HALLOWEENCANDY_1 = "Even candy's better when it's on a stick.",
        HALLOWEENCANDY_2 = "A handful of candy kernels.",
        HALLOWEENCANDY_3 = "Not very spooky, but it is tasty.",
        HALLOWEENCANDY_4 = "Maybe that spider kid would like this. Or maybe not...",
        HALLOWEENCANDY_5 = "It's wearing a little mask!",
        HALLOWEENCANDY_6 = "Those look suspicious.",
        HALLOWEENCANDY_7 = "I don't know what some people's problem is, raisins are good!",
        HALLOWEENCANDY_8 = "Maybe I'll give it to the twins.",
        HALLOWEENCANDY_9 = "Gummy.",
        HALLOWEENCANDY_10 = "Is it made with real tentacles?",
        HALLOWEENCANDY_11 = "I'm far too mature for trick or treating.",
        HALLOWEENCANDY_12 = "I think these might be real bugs!", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Huh. It's sour.", --Griftlands themed candy
        HALLOWEENCANDY_14 = "Oh! I wasn't expecting it to actually be spicy!", --Hot Lava pepper candy
        CANDYBAG = "I'm too old for that stuff. But maybe I'll help out the younger kids...",

		HALLOWEEN_ORNAMENT_1 = "Spooooky!",
		HALLOWEEN_ORNAMENT_2 = "This is my favourite time of year.",
		HALLOWEEN_ORNAMENT_3 = "It's pretty good, I thought it was a real spider!",
		HALLOWEEN_ORNAMENT_4 = "This looks really authentic!",
		HALLOWEEN_ORNAMENT_5 = "Weird how the spiders around here only have six legs.",
		HALLOWEEN_ORNAMENT_6 = "This decoration needs a tree to perch in.",

		HALLOWEENPOTION_DRINKS_WEAK = "It didn't turn out quite as well as I thought it would.",
		HALLOWEENPOTION_DRINKS_POTENT = "Dabbling in witchcraft is fun!",
        HALLOWEENPOTION_BRAVERY = "So that's what \"liquid courage\" is!",
		HALLOWEENPOTION_MOON = "What should we mutate first?",
		HALLOWEENPOTION_FIRE_FX = "It should only be handled by someone who knows fire safety. Like me!",
		MADSCIENCE_LAB = "Mad science is the best kind!",
		LIVINGTREE_ROOT = "There's a tree inside just waiting to come out!",
		LIVINGTREE_SAPLING = "Who couldn't love that face?",

        DRAGONHEADHAT = "I'll be the leader!",
        DRAGONBODYHAT = "I think I'd be better in the lead.",
        DRAGONTAILHAT = "I don't want the back end...",
        PERDSHRINE =
        {
            GENERIC = "This gobbler likes gold.",
            EMPTY = "It looks like something should go there.",
            BURNT = "Now nobody can use it.",
        },
        REDLANTERN = "I like this dramatic lighting!",
        LUCKY_GOLDNUGGET = "Woby, we struck gold!",
        FIRECRACKERS = "You're not supposed to set those off in the woods.",
        PERDFAN = "Hey Woby, it's our biggest fan! Heh... good one, Walter.",
        REDPOUCH = "It's jingling.",
        WARGSHRINE =
        {
            GENERIC = "What should we make, Woby?",
            EMPTY = "It seems to respond to torchlight.",
            BURNING = "Who left the torch unattended?!", --for willow to override
            BURNT = "Well... that's that I guess.",
        },
        CLAYWARG =
        {
        	GENERIC = "Don't worry, I'm good with dogs!",
        	STATUE = "Woby's sure sniffing around this statue a lot.",
        },
        CLAYHOUND =
        {
        	GENERIC = "Who's a good boy?",
        	STATUE = "I wonder who made these statues? They look so real!",
        },
        HOUNDWHISTLE = "Woby doesn't like the sound of it.",
        CHESSPIECE_CLAYHOUND = "He wasn't a very good dog.",
        CHESSPIECE_CLAYWARG = "Poor Woby. She never seems to get along with the other dogs.",

		PIGSHRINE =
		{
            GENERIC = "What should we make, Woby?",
            EMPTY = "I think we're supposed to offer it meat.",
            BURNT = "This little piggy burnt down.",
		},
		PIG_TOKEN = "I've already got a belt.",
		PIG_COIN = "It looks like a pig's snout! I wonder if that's on purpose.",
		YOTP_FOOD1 = "We'll have his head on a platter!",
		YOTP_FOOD2 = "Well, at least the worms are enjoying it.",
		YOTP_FOOD3 = "Who ate all the good parts?",

		PIGELITE1 = "He's looking blue... because he's got blue tattoos, get it?", --BLUE
		PIGELITE2 = "Are you reddy? Heh, good one Walter.", --RED
		PIGELITE3 = "He's not afraid to get his hands... or anything else dirty.", --WHITE
		PIGELITE4 = "He's probably really nice once you get to know him.", --GREEN

		PIGELITEFIGHTER1 = "He's looking blue... because he's got blue tattoos, get it?", --BLUE
		PIGELITEFIGHTER2 = "Are you reddy? Heh, good one Walter.", --RED
		PIGELITEFIGHTER3 = "He's not afraid to get his hands... or anything else dirty.", --WHITE
		PIGELITEFIGHTER4 = "He's probably really nice once you get to know him.", --GREEN

		CARRAT_GHOSTRACER = "Where can I get a shadow carrat?",

        YOTC_CARRAT_RACE_START = "Let's start this race!",
        YOTC_CARRAT_RACE_CHECKPOINT = "A good race needs some planning.",
        YOTC_CARRAT_RACE_FINISH =
        {
            GENERIC = "First one here wins!",
            BURNT = "Someone sabotaged the race!",
            I_WON = "Yes!! Good job little guy!",
            SOMEONE_ELSE_WON = "We'll be back for a rematch, {winner}!",
        },

		YOTC_CARRAT_RACE_START_ITEM = "Woby, help me look for a good place to set this up!",
        YOTC_CARRAT_RACE_CHECKPOINT_ITEM = "Should it go there... no, no, maybe over there...",
		YOTC_CARRAT_RACE_FINISH_ITEM = "What if the race just went on forever?",

		YOTC_SEEDPACKET = "Mystery seeds!",
		YOTC_SEEDPACKET_RARE = "Not knowing what they are is half the fun!",

		MINIBOATLANTERN = "It'll help us find the sea monsters. I know they're out there!",

        YOTC_CARRATSHRINE =
        {
            GENERIC = "What should we get, Woby?",
            EMPTY = "I think I need to offer it something for it to work.",
            BURNT = "What a waste of supplies...",
        },

        YOTC_CARRAT_GYM_DIRECTION =
        {
            GENERIC = "A good sense of direction is important for survival!",
            RAT = "You'll never be a Pinetree Pioneer if you can't follow directions!",
            BURNT = "Hey! I was going to use that!",
        },
        YOTC_CARRAT_GYM_SPEED =
        {
            GENERIC = "I've never been a coach before!",
            RAT = "Hustle, hustle! Coaches say that, right?",
            BURNT = "Does that look like a fire pit?!",
        },
        YOTC_CARRAT_GYM_REACTION =
        {
            GENERIC = "By the time we're done, my carrat will be ready for anything!",
            RAT = "These reflexes could save your life in the wilderness!",
            BURNT = "I... reacted too slow... to put the fire out...",
        },
        YOTC_CARRAT_GYM_STAMINA =
        {
            GENERIC = "This is very serious training equipment.",
            RAT = "Aww look at him jump!",
            BURNT = "Oh no!!",
        },

        YOTC_CARRAT_GYM_DIRECTION_ITEM = "I'd better start training my carrat.",
        YOTC_CARRAT_GYM_SPEED_ITEM = "Do you think we should put it over there, Woby?",
        YOTC_CARRAT_GYM_STAMINA_ITEM = "I'm great at putting things together!",
        YOTC_CARRAT_GYM_REACTION_ITEM = "Maybe I'll put it over here... no, over there!",

        YOTC_CARRAT_SCALE_ITEM = "I never knew skills could be measured by weight.",
        YOTC_CARRAT_SCALE =
        {
            GENERIC = "Do I get a badge for having the best carrat?",
            CARRAT = "He just needs some more training. We'll get there!",
            CARRAT_GOOD = "Woah, all our training paid off!",
            BURNT = "Why won't everyone just use the fire pit?!",
        },

        YOTB_BEEFALOSHRINE =
        {
            GENERIC = "What should we make, Woby?",
            EMPTY = "I should offer it something, but what should it be...",
            BURNT = "That's not good...",
        },

        BEEFALO_GROOMER =
        {
            GENERIC = "Woby doesn't like getting dressed up, but beefalo seem to!",
            OCCUPIED = "You're going to look great when we're done, just you wait!",
            BURNT = "We all need to be much more careful with fire.",
        },
        BEEFALO_GROOMER_ITEM = "Better get this all set up.",

		BISHOP_CHARGE_HIT = "Ah!! Why?!",
		TRUNKVEST_SUMMER = "Now we're both fuzzy, Woby!",
		TRUNKVEST_WINTER = "A warm nose cozy.",
		TRUNK_COOKED = "Thankfully booger-free. I think...",
		TRUNK_SUMMER = "The fur's a little patchy.",
		TRUNK_WINTER = "It's full of nose hair.",
		TUMBLEWEED = "It's just minding its own business.",
		TURKEYDINNER = "If you're good I'll give you a drumstick, Woby.",
		TWIGS = "A handful of useful twigs.",
		UMBRELLA = "It'll stop the raindrops from falling on my head.",
		GRASS_UMBRELLA = "Flowers actually have lots of practical uses.",
		UNIMPLEMENTED = "It's so mysterious!",
		WAFFLES = "Breakfast!",
		WALL_HAY =
		{
			GENERIC = "You make do with what you have when you're in the wilderness.",
			BURNT = "That's what I get for making a wall out of kindling...",
		},
		WALL_HAY_ITEM = "It's better than nothing!",
		WALL_STONE = "Looks pretty sturdy.",
		WALL_STONE_ITEM = "This will make a swell wall for our camp.",
		WALL_RUINS = "I like the spooky atmosphere.",
		WALL_RUINS_ITEM = "Want to give me a hand with these, Woby?",
		WALL_WOOD =
		{
			GENERIC = "Hope nobody hurts themselves if they try to climb over.",
			BURNT = "Our camp!!",
		},
		WALL_WOOD_ITEM = "Looks sharp.",
		WALL_MOONROCK = "It came from another world!",
		WALL_MOONROCK_ITEM = "I can't believe we're making walls out of real moon rock!",
		FENCE = "Why do we need fences? It's the great outdoors!",
        FENCE_ITEM = "Why fence in nature?",
        FENCE_GATE = "It's open-and-shut.",
        FENCE_GATE_ITEM = "I guess I should find someplace to put that.",
		WALRUS = "I need a closer look at those tusks!",
		WALRUSHAT = "It's very... plaid?",
		WALRUS_CAMP =
		{
			EMPTY = "An abandoned campsite... I wonder who was here?",
			GENERIC = "I've heard of houses like this, but I've never seen one!",
		},
		WALRUS_TUSK = "Oof... I don't think he brushed.",
		WARDROBE =
		{
			GENERIC = "I've been keeping my bugs in there when I run out of room in my pockets.",
            BURNING = "My bugs!!",
			BURNT = "Poor little guys...",
		},
		WARG = "Are they a friend of yours, Woby?",
        WARGLET = "Look Woby, another dog for you to play with!",
        
		WASPHIVE = "E-everyone stay calm... we'll be on our way...",
		WATERBALLOON = "Don't worry, I have great aim! Or maybe you should be worried...",
		WATERMELON = "A sweet, refreshing snack!",
		WATERMELON_COOKED = "It's still sweet, but not as refreshing...",
		WATERMELONHAT = "This feels silly...",
		WAXWELLJOURNAL = "Maybe you could teach me some magic tricks? I'm a quick learner!",
		WETGOOP = "Er... maybe Woby will want it...",
        WHIP = "I know how you feel about cats Woby, but it still seems pretty mean.",
		WINTERHAT = "Better bundle up.",
		WINTEROMETER =
		{
			GENERIC = "I guess some people like to be more precise than \"hot\" and \"cold\".",
			BURNT = "We all need to be much more careful with fire.",
		},

        WINTER_TREE =
        {
            BURNT = "Maybe... we can make another one?",
            BURNING = "Quick, put it out! Put it out!",
            CANDECORATE = "I'm glad I've got you to spend the holiday with, Woby.",
            YOUNG = "It'll be fully grown soon.",
        },
		WINTER_TREESTAND =
		{
			GENERIC = "All set up and ready for a tree.",
            BURNT = "Maybe... we can make another one?",
		},
        WINTER_ORNAMENT = "Careful Woby, they're really delicate.",
        WINTER_ORNAMENTLIGHT = "I wonder what powers it? Oh well!",
        WINTER_ORNAMENTBOSS = "This one should go someplace special.",
		WINTER_ORNAMENTFORGE = "These ones are my favourite.",
		WINTER_ORNAMENTGORGE = "Looks like... a goat person?",

        WINTER_FOOD1 = "Mom made these every year.", --gingerbread cookie
        WINTER_FOOD2 = "I'll make sure the younger kids don't eat too many.", --sugar cookie
        WINTER_FOOD3 = "Don't eat too many, you'll get sick!", --candy cane
        WINTER_FOOD4 = "I'm... good.", --fruitcake
        WINTER_FOOD5 = "It's soooo good!", --yule log cake
        WINTER_FOOD6 = "There's fruit in it, so it's healthy right?", --plum pudding
        WINTER_FOOD7 = "Mmm, so warm and cinnamon-y!", --apple cider
        WINTER_FOOD8 = "It really warms you up!", --hot cocoa
        WINTER_FOOD9 = "It's so sweet!", --eggnog

		WINTERSFEASTOVEN =
		{
			GENERIC = "What a huge oven! We could feed a whole Pioneer troop!",
			COOKING = "Food is on the way!",
			ALMOST_DONE_COOKING = "So close... it smells so good!",
			DISH_READY = "Come and get it!",
		},
		BERRYSAUCE = "It somehow tastes even better than regular berries!",
		BIBINGKA = "Woah... where did we get the shaved coconut from?",
		CABBAGEROLLS = "This would make great camping food!",
		FESTIVEFISH = "Fish with some special seasonal seasonings.",
		GRAVY = "Pass it over here!",
		LATKES = "I've never tried potatoes cooked like this before.",
		LUTEFISK = "Once you get past the smell, it's not bad!",
		MULLEDDRINK = "I like to use the cinnamon stick as a straw.",
		PANETTONE = "I could eat this forever.",
		PAVLOVA = "Mmmm, it almost reminds me of a perfectly roasted marshmallow.",
		PICKLEDHERRING = "Pickling is a really practical way to store food supplies.",
		POLISHCOOKIE = "There's fruit inside, it has to be at least a little healthy.",
		PUMPKINPIE = "Mmmm, cut me a big slice!",
		ROASTTURKEY = "Woby wants some too!",
		STUFFING = "I could stuff a bit more in my mouth.",
		SWEETPOTATO = "It just isn't the holidays without it!",
		TAMALES = "Woah, these are tasty!",
		TOURTIERE = "My cousin from the East Coast made these for us once, they're the best!",

		TABLE_WINTERS_FEAST =
		{
			GENERIC = "The table's all set and ready for food!",
			HAS_FOOD = "Dig in, everybody!",
			WRONG_TYPE = "We can eat that anytime, Winter's Feast should be special!",
			BURNT = "Who's the Scrooge that ruined the feast?",
		},

		GINGERBREADWARG = "Who's a sweet Varg? Yes you are!",
		GINGERBREADHOUSE = "What do they do when it rains?",
		GINGERBREADPIG = "Is that cookie alive?!",
		CRUMBS = "Maybe they dropped them to find their way home?",
		WINTERSFEASTFUEL = "It looks like magic!",

        KLAUS = "Woah! Who are you?",
        KLAUS_SACK = "Hey, he brought presents!",
		KLAUSSACKKEY = "There's something weird about this antler.",
		WORMHOLE =
		{
			GENERIC = "It kind of looks like a mouth.",
			OPEN = "It IS a mouth!! Come on Woby, let's get a closer look.",
		},
		WORMHOLE_LIMITED = "Is it sick?",
		ACCOMPLISHMENT_SHRINE = "I love checking tasks off a list!", --single player
		LIVINGTREE = "Can you talk? What's it like being a tree?",
		ICESTAFF = "Ice magic!",
		REVIVER = "Did you ever hear the story about the beating heart hidden under the floorboards?",
		SHADOWHEART = "Look at that! I wonder what's keeping it alive?",
        ATRIUM_RUBBLE =
        {
			LINE_1 = "It looks like things weren't going so well for the people here.",
			LINE_2 = "I can't tell what's happening in this one, the picture's worn off.",
			LINE_3 = "There's... a shadow? Or something... they took some artistic liberties.",
			LINE_4 = "Woah, looks like they all started changing.",
			LINE_5 = "That must be what the city looked like a long time ago.",
		},
        ATRIUM_STATUE = "If it could speak, I wonder what it would tell us.",
        ATRIUM_LIGHT =
        {
			ON = "Well, we got the lights working!",
			OFF = "There's got to be a way to turn it on.",
		},
        ATRIUM_GATE =
        {
			ON = "It's working!",
			OFF = "It looks like it's missing a piece.",
			CHARGING = "I guess we'll have to wait for it to power up.",
			DESTABILIZING = "Is it supposed to be making that sound?",
			COOLDOWN = "I guess I should give it a rest for now.",
        },
        ATRIUM_KEY = "It's the key to this whole mystery!",
		LIFEINJECTOR = "This is supposed to make me healthier?",
		SKELETON_PLAYER =
		{
			MALE = "Poor %s. I guess %s might be more dangerous than I thought...",
			FEMALE = "Poor %s. I guess %s might be more dangerous than I thought...",
			ROBOT = "Poor %s. I guess %s might be more dangerous than I thought...",
			DEFAULT = "Poor %s. I guess %s might be more dangerous than I thought...",
		},
		HUMANMEAT = "Flesh is flesh. Where do I draw the line?",
		HUMANMEAT_COOKED = "Cooked nice and pink, but still morally gray.",
		HUMANMEAT_DRIED = "Letting it dry makes it not come from a human, right?",
		ROCK_MOON = "I wonder how it affects were-people. I should ask Mr. Woodie.",
		MOONROCKNUGGET = "It came from outer space!",
		MOONROCKCRATER = "I feel like it's looking at me.",
		MOONROCKSEED = "Is the moon... haunted?",

        REDMOONEYE = "This eye looks bloodshot!",
        PURPLEMOONEYE = "Purple! The friendliest colour!.",
        GREENMOONEYE = "They never taught us how to use these in the Pinetree Pioneers.",
        ORANGEMOONEYE = "It's a pretty good landmark, you can't miss it!",
        YELLOWMOONEYE = "Y'ello to you too! Okay, that was bad.",
        BLUEMOONEYE = "You don't come across one of these very often.",

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
        QUAGMIRE_CRATE = "Kitchen stuff.",

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
        	GENERIC = "To defend our camp!",
        	OFF = "It doesn't look like it's working.",
        	BURNING = "Ah!! That's how forest fires start!",
        	BURNT = "There go our defenses...",
        },
        WINONA_SPOTLIGHT =
        {
        	GENERIC = "You never know what's out there, lurking in the dark.",
        	OFF = "Is it out of power?",
        	BURNING = "Ah!! That's how forest fires start!",
        	BURNT = "Well... I guess Winona'll have to build a new one.",
        },
        WINONA_BATTERY_LOW =
        {
        	GENERIC = "A generator! Do you think she could make a radio too...?",
        	LOWPOWER = "I think we need to hook up a another generator to this generator.",
        	OFF = "It stopped working.",
        	BURNING = "Ah!! That's how forest fires start!",
        	BURNT = "Well... I guess Winona'll have to build a new one.",
        },
        WINONA_BATTERY_HIGH =
        {
        	GENERIC = "How does it work?",
        	LOWPOWER = "I think we need to hook up a another generator to this generator.",
        	OFF = "It ran out of gem power.",
        	BURNING = "Ah!! That's how forest fires start!",
        	BURNT = "Well... I guess Winona'll have to build a new one.",
        },

        --Wormwood
        COMPOSTWRAP = "Oh, uh... that's alright, I'm not hungry.",
        ARMOR_BRAMBLE = "No hugging while you're wearing that.",
        TRAP_BRAMBLE = "He's pretty good at this!",

        BOATFRAGMENT03 = "Looks like a sea monster got them.",
        BOATFRAGMENT04 = "Looks like a sea monster got them.",
        BOATFRAGMENT05 = "Looks like a sea monster got them.",
		BOAT_LEAK = "Don't worry! I have a badge in sailing, I know what to do!",
        MAST = "That's an important boat part.",
        SEASTACK = "Rocks off the port bow!",
        FISHINGNET = "Hey Woby, want to go fishing?", --unimplemented
        ANTCHOVIES = "I have mixed feelings.", --unimplemented
        STEERINGWHEEL = "Come on First Mate Woby, we're going sailing!",
        ANCHOR = "That's another important boat part.",
        BOATPATCH = "Better to be prepared.",
        DRIFTWOOD_TREE =
        {
            BURNING = "You're supposed to make a pit, gather the firewood and THEN make a fire!",
            BURNT = "That could've been bad.",
            CHOPPED = "Thanks for the firewood, tree!",
            GENERIC = "Looks kind of eerie, doesn't it?",
        },

        DRIFTWOOD_LOG = "You'll float too, if you hold onto it!",

        MOON_TREE =
        {
            BURNING = "This is why we should always practice fire safety!",
            BURNT = "I guess it could've been worse.",
            CHOPPED = "This one's already been chopped down.",
            GENERIC = "That one definitely isn't in my handbook.",
        },
		MOON_TREE_BLOSSOM = "Who knew there were flowers on the moon?",

        MOONBUTTERFLY =
        {
        	GENERIC = "I've never seen a moth like this before!",
        	HELD = "In my pocket you go!",
        },
		MOONBUTTERFLYWINGS = "They're very fragile.",
        MOONBUTTERFLY_SAPLING = "Poor moth.",
        ROCK_AVOCADO_FRUIT = "It's hard as a rock!",
        ROCK_AVOCADO_FRUIT_RIPE = "It's finally ripe! ...I think.",
        ROCK_AVOCADO_FRUIT_RIPE_COOKED = "That's better.",
        ROCK_AVOCADO_FRUIT_SPROUT = "Oh, it's growing!",
        ROCK_AVOCADO_BUSH =
        {
        	BARREN = "I don't think it'll be making fruit anytime soon.",
			WITHERED = "I don't think it likes the heat.",
			GENERIC = "Is that tree growing... rocks?",
			PICKED = "We already gathered all the fruit.",
			DISEASED = "Maybe that's how a moon bush is supposed to look?", --unimplemented
            DISEASING = "Is something wrong with it?", --unimplemented
			BURNING = "It's on fire!",
		},
        DEAD_SEA_BONES = "These are definitely sea monster bones!",
        HOTSPRING =
        {
        	GENERIC = "This would make a great swimming hole! It's even heated!",
        	BOMBED = "I'm sure that's safe.",
        	GLASS = "It's like it's frozen in time.",
			EMPTY = "It's a crater, I guess that's pretty common on the moon.",
        },
        MOONGLASS = "Wow... it's so light!",
        MOONGLASS_CHARGED = "It's light and glowy.",
        MOONGLASS_ROCK = "I've never seen a rock like this before.",
        BATHBOMB = "It smells pretty good.",
        TRAP_STARFISH =
        {
            GENERIC = "I love starfish!",
            CLOSED = "H-hey, be careful!",
        },
        DUG_TRAP_STARFISH = "I'm putting them in time out.",
        SPIDER_MOON =
        {
        	GENERIC = "Woah, how did they get like that? I need to get a closer look!",
        	SLEEPING = "I could probably get close while they're sleeping.",
        	DEAD = "Aw, it's dead.",
        },
        MOONSPIDERDEN = "Look at that, Woby! It's a home for moon creatures!",
		FRUITDRAGON =
		{
			GENERIC = "It's a little lizard thing!",
			RIPE = "I could've sworn it was green a second ago.",
			SLEEPING = "They're even cuter when they're sleeping.",
		},
        PUFFIN =
        {
            GENERIC = "Hey, that one IS in my handbook!",
            HELD = "I hope it doesn't eat the bugs in my pocket.",
            SLEEPING = "Don't wake them up, Woby.",
        },

		MOONGLASSAXE = "Hey... it just occurred to me that this might be dangerous.",
		GLASSCUTTER = "Moon sword!!",

        ICEBERG =
        {
            GENERIC = "Iceberg ahead!", --unimplemented
            MELTED = "Woby likes to roll in puddles.", --unimplemented
        },
        ICEBERG_MELTED = "Woby likes to roll in puddles.", --unimplemented

        MINIFLARE = "It's a signal, only to be used in an emergency.",

		MOON_FISSURE =
		{
			GENERIC = "Do you hear that whispering, Woby?",
			NOLIGHT = "Any monsters down there?",
		},
        MOON_ALTAR =
        {
            MOON_ALTAR_WIP = "Don't worry, a Pinetree Pioneer finishes what they start!",
            GENERIC = "You're right, people SHOULD listen to me more often.",
        },

        MOON_ALTAR_IDOL = "Do you need some assistance?",
        MOON_ALTAR_GLASS = "Don't worry, I'll help you get where you need to go.",
        MOON_ALTAR_SEED = "We have to help it, Woby!",

        MOON_ALTAR_ROCK_IDOL = "I think there's something in there...",
        MOON_ALTAR_ROCK_GLASS = "I think there's something in there...",
        MOON_ALTAR_ROCK_SEED = "I think there's something in there...",

        MOON_ALTAR_CROWN = "Don't worry, we'll get you home!",
        MOON_ALTAR_COSMIC = "\"It's almost time\"? Time for what?",

        MOON_ALTAR_ASTRAL = "I think it's ready.",
        MOON_ALTAR_ICON = "Woby and I will get you back together!",
        MOON_ALTAR_WARD = "It's okay, we'll have you home in no time.",

        SEAFARING_PROTOTYPER =
        {
            GENERIC = "We're going to need a better boat.",
            BURNT = "We should really be more careful with our resources.",
        },
        BOAT_ITEM = "Let's get building, Woby!",
        STEERINGWHEEL_ITEM = "It's probably a good idea to add a steering wheel.",
        ANCHOR_ITEM = "I've got all the supplies ready to build an anchor.",
        MAST_ITEM = "A mast would be useful.",
        MUTATEDHOUND =
        {
        	DEAD = "Oh no... don't look, Woby.",
        	GENERIC = "Is that an undead dog?",
        	SLEEPING = "See, they're harmless!",
        },

        MUTATED_PENGUIN =
        {
			DEAD = "I guess it's properly dead now.",
			GENERIC = "It's a penguin, risen from the grave!",
			SLEEPING = "I think it's sleeping, but it's hard to tell.",
		},
        CARRAT =
        {
        	DEAD = "Poor little thing.",
        	GENERIC = "Vegetables are much more interesting here than back home.",
        	HELD = "Please don't nibble a hole in my pocket.",
        	SLEEPING = "What do carrots dream about?",
        },

		BULLKELP_PLANT =
        {
            GENERIC = "It's kelp... or a sea monster DISGUISING themselves as kelp.",
            PICKED = "I guess it's just kelp.",
        },
		BULLKELP_ROOT = "I could plant this back in the ocean.",
        KELPHAT = "Maybe if I look like a sea monster the real ones will come out.",
		KELP = "Sea monster hair. Obviously.",
		KELP_COOKED = "It's... slimy.",
		KELP_DRIED = "Crunchy and salty. It's not bad.",

		GESTALT = "Are you a ghost... from the moon?",
        GESTALT_GUARD = "Wow, they reeaally don't like those shadow creatures.",

		COOKIECUTTER = "They're smiling! Wait, I think I was looking at them upside-down.",
		COOKIECUTTERSHELL = "These guys have tough armor!",
		COOKIECUTTERHAT = "It's a shellmet! Because it's a helmet, but a shell-- you get it.",
		SALTSTACK =
		{
			GENERIC = "Maybe there's a Medusa nearby... a salt Medusa...",
			MINED_OUT = "Nothing left to gather.",
			GROWING = "I'm glad they grow back!",
		},
		SALTROCK = "Hey, I think that's salt!",
		SALTBOX = "Salt is great for preserving your supplies.",

		TACKLESTATION = "Not to brag, but I do have my fishing badge.",
		TACKLESKETCH = "This looks pretty easy to make.",

        MALBATROSS = "Woah, look at that wingspan!",
        MALBATROSS_FEATHER = "I think we ruffled her feathers.",
        MALBATROSS_BEAK = "She left us a souvenir.",
        MAST_MALBATROSS_ITEM = "We'd better get this set up, Woby.",
        MAST_MALBATROSS = "I feel kind of bad, but it does look great on the boat.",
		MALBATROSS_FEATHERED_WEAVE = "I didn't know you could make fabric out of feathers!",

        GNARWAIL =
        {
            GENERIC = "Unicorns of the sea.",
            BROKENHORN = "Oh no! You lost your horn!",
            FOLLOWER = "See? We can all get along!",
            BROKENHORN_FOLLOWER = "I sure hope your horn grows back.",
        },
        GNARWAIL_HORN = "If they're not using it anymore, might as well keep it.",

        WALKINGPLANK = "Oh, I'm good at diving! I got a badge for it!",
        OAR = "I used to go canoing with my Pinetree Pioneer troop.",
		OAR_DRIFTWOOD = "I used to go canoing with my Pinetree Pioneer troop.",

		OCEANFISHINGROD = "This fishing rod's really sturdy!",
		OCEANFISHINGBOBBER_NONE = "The diagram in my handbook shows a bobber, that might help.",
        OCEANFISHINGBOBBER_BALL = "Just a simple bobber.",
        OCEANFISHINGBOBBER_OVAL = "A slightly less simple bobber.",
		OCEANFISHINGBOBBER_CROW = "I followed the instructions perfectly.",
		OCEANFISHINGBOBBER_ROBIN = "I followed the instructions perfectly.",
		OCEANFISHINGBOBBER_ROBIN_WINTER = "I followed the instructions perfectly.",
		OCEANFISHINGBOBBER_CANARY = "I followed the instructions perfectly.",
		OCEANFISHINGBOBBER_GOOSE = "It floats... like a feather, in fact.",
		OCEANFISHINGBOBBER_MALBATROSS = "Thanks Malbatross!",

		OCEANFISHINGLURE_SPINNER_RED = "Careful Woby, these aren't real food!",
		OCEANFISHINGLURE_SPINNER_GREEN = "Careful Woby, these aren't real food!",
		OCEANFISHINGLURE_SPINNER_BLUE = "Careful Woby, these aren't real food!",
		OCEANFISHINGLURE_SPOON_RED = "Careful Woby, these aren't real food!",
		OCEANFISHINGLURE_SPOON_GREEN = "Careful Woby, these aren't real food!",
		OCEANFISHINGLURE_SPOON_BLUE = "Careful Woby, these aren't real food!",
		OCEANFISHINGLURE_HERMIT_RAIN = "I wonder how that works.",
		OCEANFISHINGLURE_HERMIT_SNOW = "Snow fishing? Hmm, a new technique to master...",
		OCEANFISHINGLURE_HERMIT_DROWSY = "Okay... just hold it carefully...",
		OCEANFISHINGLURE_HERMIT_HEAVY = "Just watch Woby, I'll catch the biggest fish you've ever seen!",

		OCEANFISH_SMALL_1 = "It's barely big enough to call a guppy.",
		OCEANFISH_SMALL_2 = "I caught it on purpose. For practice.",
		OCEANFISH_SMALL_3 = "I usually catch much bigger fish, you know.",
		OCEANFISH_SMALL_4 = "You know, sometimes catching smaller fish is the real challenge.",
		OCEANFISH_SMALL_5 = "Careful the fins don't get stuck in your teeth.",
		OCEANFISH_SMALL_6 = "It smells like dead leaves.",
		OCEANFISH_SMALL_7 = "Hey little buddy! Get it, because it's got a bud on its head?",
		OCEANFISH_SMALL_8 = "Keep it away from anything flammable!",
        OCEANFISH_SMALL_9 = "Hey! It's rude to spit at people!",

		OCEANFISH_MEDIUM_1 = "SEA MONST-- oh wait, it's just a really ugly fish.",
		OCEANFISH_MEDIUM_2 = "It's like it's staring into my soul...",
		OCEANFISH_MEDIUM_3 = "None of these fish look anything like the ones in my handbook...",
		OCEANFISH_MEDIUM_4 = "You're the unlucky fish who'll be my dinner.",
		OCEANFISH_MEDIUM_5 = "Is it corn that mutated into a fish, or a fish that mutated into corn?",
		OCEANFISH_MEDIUM_6 = "Don't you usually live in ponds?",
		OCEANFISH_MEDIUM_7 = "Don't you usually live in ponds?",
		OCEANFISH_MEDIUM_8 = "Will it melt if I try to cook it?",
        OCEANFISH_MEDIUM_9 = "Aww, it's got cute little ear fins!",

		PONDFISH = "Sorry, but someone has to be dinner.",
		PONDEEL = "It has sharp little teeth.",

        FISHMEAT = "Is it okay to eat it raw?",
        FISHMEAT_COOKED = "Catching your own fish and eating it, real survivor stuff!",
        FISHMEAT_SMALL = "Maybe I could use it as bait for a bigger fish.",
        FISHMEAT_SMALL_COOKED = "It smells good!",
		SPOILED_FISH = "Ugh, rotten fish!",

		FISH_BOX = "That'll keep our fish fresh!",
        POCKET_SCALE = "Do you think there's a badge for catching the biggest fish?",

		TACKLECONTAINER = "It's got room for all my tackle.",
		SUPERTACKLECONTAINER = "So organized!",

		TROPHYSCALE_FISH =
		{
			GENERIC = "Just wait, that biggest fish badge will be mine!",
			HAS_ITEM = "Weight: {weight}\nCaught by: {owner}",
			HAS_ITEM_HEAVY = "Weight: {weight}\nCaught by: {owner}\nIt's almost as heavy as you, Woby!",
			BURNING = "The fire is off the-- well actually it's ON the scale, that's the problem!",
			BURNT = "What a waste of supplies.",
			OWNER = "I win! Where's my badge?\nWeight: {weight}\nCaught by: {owner}",
			OWNER_HEAVY = "Weight: {weight}\nCaught by: {owner}\nPretty impressive, huh Woby?",
		},

		OCEANFISHABLEFLOTSAM = "Now that HAS to be a sea mons-- (sigh) no, just a muddy clump.",

		CALIFORNIAROLL = "Is that raw fish?",
		SEAFOODGUMBO = "Packed full of flavour!",
		SURFNTURF = "So filling!",

        WOBSTER_SHELLER = "Shellfish are basically bugs of the sea.",
        WOBSTER_DEN = "That's where the Wobsters make camp.",
        WOBSTER_SHELLER_DEAD = "Well, at least they'll make a good dinner.",
        WOBSTER_SHELLER_DEAD_COOKED = "Mmm, smells good!",

        LOBSTERBISQUE = "It's tasty, I like it!",
        LOBSTERDINNER = "This seems pretty fancy for camping food.",

        WOBSTER_MOONGLASS = "There's something different about their shell.",
        MOONGLASS_WOBSTER_DEN = "That's where the Wobsters make camp.",

		TRIDENT = "This looks like it could cause some damage.",

		WINCH =
		{
			GENERIC = "This is how we'll catch a sea monster!",
			RETRIEVING_ITEM = "Please be a sea monster, please be a sea monster...",
			HOLDING_ITEM = "Well... it's not a sea monster.",
		},

        HERMITHOUSE = {
            GENERIC = "This house could use some fixing up.",
            BUILTUP = "A Pinetree Pioneer is always happy to help the elderly!",
        },

        SHELL_CLUSTER = "Let's break it apart and see what's inside.",
        --
		SINGINGSHELL_OCTAVE3 =
		{
			GENERIC = "There's something inside it!",
		},
		SINGINGSHELL_OCTAVE4 =
		{
			GENERIC = "Maybe I could teach it to play some songs I learned in the Pioneers.",
		},
		SINGINGSHELL_OCTAVE5 =
		{
			GENERIC = "Is that hard on your ears, Woby?",
        },

        CHUM = "You use it to lure the fish in.",

        SUNKENCHEST =
        {
            GENERIC = "How did this clam get so big?",
            LOCKED = "I can't get it open.",
        },

        HERMIT_BUNDLE = "I think she's really warming up to us, Woby!",
        HERMIT_BUNDLE_SHELLS = "More for the shell collection!",

        RESKIN_TOOL = "It changes how things look, but they're still the same deep down.",
        MOON_FISSURE_PLUGGED = "She trapped all the moon ghosts in their holes.",


		----------------------- ROT STRINGS GO ABOVE HERE ------------------

		-- Walter
        WOBYBIG =
        {
            "Good girl, Woby!",
            "How could anyone be scared of that face?",
        },
        WOBYSMALL =
        {
            "Good girl, Woby!",
            "What's the matter, girl? Did someone fall down a well?",
        },
		WALTERHAT = "A Pinetree Pioneer should always wear appropriate headgear.",
		SLINGSHOT = "You never know what you'll run into out in the wilderness.",
		SLINGSHOTAMMO_ROCK = "They're not the best, but they'll work.",
		SLINGSHOTAMMO_MARBLE = "I wish they weren't so hard to find!",
		SLINGSHOTAMMO_THULECITE = "Shadow magic is pretty handy, I see why the Ancients liked it!",
        SLINGSHOTAMMO_GOLD = "These rounds are golden! Literally!",
        SLINGSHOTAMMO_SLOW = "That should slow them down!",
        SLINGSHOTAMMO_FREEZE = "Almost as chilling as my favourite radio shows!",
		SLINGSHOTAMMO_POOP = "Gross... but a distraction is a distraction.",
        PORTABLETENT = "Nice and sturdy!",
        PORTABLETENT_ITEM = "I'll have this set up lickety-split!",

        -- Wigfrid
        BATTLESONG_DURABILITY = "This seems a bit more complicated than the songs I learned in the Pioneers.",
        BATTLESONG_HEALTHGAIN = "This seems a bit more complicated than the songs I learned in the Pioneers.",
        BATTLESONG_SANITYGAIN = "This seems a bit more complicated than the songs I learned in the Pioneers.",
        BATTLESONG_SANITYAURA = "This seems a bit more complicated than the songs I learned in the Pioneers.",
        BATTLESONG_FIRERESISTANCE = "This seems a bit more complicated than the songs I learned in the Pioneers.",
        BATTLESONG_INSTANT_TAUNT = "This story could use a few more monsters.",
        BATTLESONG_INSTANT_PANIC = "This story could use a few more monsters.",

        -- Webber
        MUTATOR_WARRIOR = "Hey, cookies! Um... what are these made of, exactly?",
        MUTATOR_DROPPER = "Neat! There aren't any actual spider bits in these though, right?",
        MUTATOR_HIDER = "Hey, cookies! Um... what are these made of, exactly?",
        MUTATOR_SPITTER = "Neat! There aren't any actual spider bits in these though, right?",
        MUTATOR_MOON = "Hey, cookies! Um... what are these made of, exactly?",
        MUTATOR_HEALER = "Neat! There aren't any actual spider bits in these though, right?",
        SPIDER_WHISTLE = "Hey Webber, let's call some spiders!",
        SPIDERDEN_BEDAZZLER = "He's well on his way to getting his Arts and Crafts badge.",
        SPIDER_HEALER = "Aw, what a helpful little guy!",
        SPIDER_REPELLENT = "Aw, why would I want the spiders to go away?",
        SPIDER_HEALER_ITEM = "It's like a first aid kit for spiders!",

		-- Wendy
		GHOSTLYELIXIR_SLOWREGEN = "Ghosts can drink potions? Uh, of course I knew that!",
		GHOSTLYELIXIR_FASTREGEN = "Ghosts can drink potions? Uh, of course I knew that!",
		GHOSTLYELIXIR_SHIELD = "Ghosts can drink potions? Uh, of course I knew that!",
		GHOSTLYELIXIR_ATTACK = "Ghosts can drink potions? Uh, of course I knew that!",
		GHOSTLYELIXIR_SPEED = "Ghosts can drink potions? Uh, of course I knew that!",
		GHOSTLYELIXIR_RETALIATION = "Ghosts can drink potions? Uh, of course I knew that!",
		SISTURN =
		{
			GENERIC = "Yeah, that looks haunted.",
			SOME_FLOWERS = "If I find some flowers I'll bring them back here.",
			LOTS_OF_FLOWERS = "That looks pretty nice.",
		},

        --Wortox
--fallback to speech_wilson.lua         WORTOX_SOUL = "only_used_by_wortox", --only wortox can inspect souls

        PORTABLECOOKPOT_ITEM =
        {
            GENERIC = "It still doesn't beat roasting things over a campfire.",
            DONE = "Mmmm, meal time!",

			COOKING_LONG = "Maybe I'll organize my bug collection while I'm waiting.",
			COOKING_SHORT = "It's almost done!",
			EMPTY = "I'll have to gather some food to start cooking.",
        },

        PORTABLEBLENDER_ITEM = "It mixes all the food together.",
        PORTABLESPICER_ITEM =
        {
            GENERIC = "A little extra flavour never hurt anyone.",
            DONE = "Mmm, looks good!",
        },
        SPICEPACK = "Specialized spice traveling gear.",
        SPICE_GARLIC = "It's good for you!",
        SPICE_SUGAR = "Too much will make you sick.",
        SPICE_CHILI = "A little bit of spice never hurt anyone.",
        SPICE_SALT = "It helps makes camp food a bit less bland.",
        MONSTERTARTARE = "Fancy and gross overlaps a lot.",
        FRESHFRUITCREPES = "With fresh-picked wild fruits.",
        FROGFISHBOWL = "Er... maybe Woby wants some.",
        POTATOTORNADO = "I usually mash my potatoes.",
        DRAGONCHILISALAD = "Is it made from real dragons?",
        GLOWBERRYMOUSSE = "Will my insides light up if I eat it?",
        VOLTGOATJELLY = "It definitely has a zing to it.",
        NIGHTMAREPIE = "Looks good!",
        BONESOUP = "It really fills you up.",
        MASHEDPOTATOES = "Yeah, mashed potatoes!",
        POTATOSOUFFLE = "This is really good, Mr. Warly!",
        MOQUECA = "Wow, having a real chef around when you're camping is great!",
        GAZPACHO = "(Sigh) I know it's probably good for me...",
        ASPARAGUSSOUP = "Asparagus again? Er, not that I'm complaining...",
        VEGSTINGER = "I've never had a spicy drink before.",
        BANANAPOP = "Those are for little kids. But bananas are healthy so I guess it's alright.",
        CEVICHE = "Mushy, but tasty.",
        SALSA = "It only comes with one chip?!",
        PEPPERPOPPER = "Why does this taste minty...?",

        TURNIP = "Huh... Turnip would be a good name for a dog.",
        TURNIP_COOKED = "Tasty turnips.",
        TURNIP_SEEDS = "Where should we plant them, Woby?",

        GARLIC = "Wards off the vampires.",
        GARLIC_COOKED = "Too bad vampires never get to enjoy it.",
        GARLIC_SEEDS = "Where should we plant them, Woby?",

        ONION = "I hate chopping them.",
        ONION_COOKED = "A juicy cooked onion.",
        ONION_SEEDS = "Where should we plant them, Woby?",

        POTATO = "Should we mash them?",
        POTATO_COOKED = "I love a campfire-roasted potato.",
        POTATO_SEEDS = "Where should we plant them, Woby?",

        TOMATO = "Mom had some tomato plants in our backyard.",
        TOMATO_COOKED = "That just made it squishier...",
        TOMATO_SEEDS = "Where should we plant them, Woby?",

        ASPARAGUS = "It's not my favourite.",
        ASPARAGUS_COOKED = "I'll eat my vegetables.",
        ASPARAGUS_SEEDS = "Where should we plant them, Woby?",

        PEPPER = "Nice and red and ripe!",
        PEPPER_COOKED = "It's hot!",
        PEPPER_SEEDS = "Where should we plant them, Woby?",

        WEREITEM_BEAVER = "I knew the Werebeaver was real! Nobody believed me!",
        WEREITEM_GOOSE = "Yeah that... definitely looks cursed.",
        WEREITEM_MOOSE = "So how does the curse work? When did it start?",

        MERMHAT = "Now I can disguise myself as a bog monster! The tables have turned!",
        MERMTHRONE =
        {
            GENERIC = "Wow, there's a whole bog monster civilization!",
            BURNT = "I'm so sorry about that!",
        },
        MERMTHRONE_CONSTRUCTION =
        {
            GENERIC = "It looks like they're building something, but what?",
            BURNT = "Darnit! Now I'll never know what it was!",
        },
        MERMHOUSE_CRAFTED =
        {
            GENERIC = "Bog monsters live in houses?",
            BURNT = "That's horrible!",
        },

        MERMWATCHTOWER_REGULAR = "They're friendly!",
        MERMWATCHTOWER_NOKING = "Wow, it's like a tree fort!",
        MERMKING = "The king of the bog monsters!",
        MERMGUARD = "Are they a different type of bog monster?",
        MERM_PRINCE = "I wonder how they pick their king?",

        SQUID = "I wonder if that's their full size, or if these are just babies...",

		GHOSTFLOWER = "Spooky!",
        SMALLGHOST = "Maybe I should come back with someone who speaks ghost...",

        CRABKING =
        {
            GENERIC = "YES!! Now that's a proper sea monster!",
            INERT = "Who built this giant sand castle in the middle of the ocean?",
        },
		CRABKING_CLAW = "Woah! Look at the size of those claws!",

		MESSAGEBOTTLE = "There's a note inside.",
		MESSAGEBOTTLEEMPTY = "Maybe I'll use it for my bug collection, my pockets are getting full.",

        MEATRACK_HERMIT =
        {
            DONE = "Your jerky's ready, ma'am!",
            DRYING = "It should be ready soon.",
            DRYINGINRAIN = "Oh no, it's never going to dry in this rain!",
            GENERIC = "Those are some pretty swell looking drying racks.",
            BURNT = "It burned up!",
            DONE_NOTMEAT = "Your jerky's ready, ma'am!",
            DRYING_NOTMEAT = "It should be ready soon.",
            DRYINGINRAIN_NOTMEAT = "Oh no, it's never going to dry in this rain!",
        },
        BEEBOX_HERMIT =
        {
            READY = "M-ma'am, I think your honey is ready.",
            FULLHONEY = "M-ma'am, I think your honey is ready.",
            GENERIC = "Don't panic Walter, the bees smell your fear...",
            NOHONEY = "It doesn't look like they've made any honey.",
            SOMEHONEY = "There's some honey, but not enough to be worth the stings.",
            BURNT = "It burned up!",
        },

        HERMITCRAB = "Hello ma'am! Can I help you with anything?",

        HERMIT_PEARL = "I gave my Pinetree Pioneer's oath to protect it with my life!",
        HERMIT_CRACKED_PEARL = "Oh no, oh no no no no...",

        -- DSEAS
        WATERPLANT = "Woah! That flower is huge!",
        WATERPLANT_BOMB = "Hey! Careful with those!",
        WATERPLANT_BABY = "I think I'm getting better at gardening!",
        WATERPLANT_PLANTER = "Don't worry, we'll find a nice rock to plant you on.",

        SHARK = "Just look at the size of those teeth!",

        MASTUPGRADE_LAMP_ITEM = "I guess it's safer than having a campfire on the deck...",
        MASTUPGRADE_LIGHTNINGROD_ITEM = "The static makes Woby's fur all poofy.",

        WATERPUMP = "It's always good to have proper safety precautions in place.",

        BARNACLE = "Foraged from the sea!",
        BARNACLE_COOKED = "Hmm, it's not bad!",

        BARNACLEPITA = "Further proof that anything can be a sandwich.",
        BARNACLESUSHI = "It's... interesting.",
        BARNACLINGUINE = "Just about anything tastes good with pasta.",
        BARNACLESTUFFEDFISHHEAD = "Uhh Woby? Do you want this one?",

        LEAFLOAF = "I guess it's one way to eat your vegetables.",
        LEAFYMEATBURGER = "It's not quite the same.",
        LEAFYMEATSOUFFLE = "I don't think we needed to get that fancy with it...",
        MEATYSALAD = "What are those chunks in it?",

        -- GROTTO

		MOLEBAT = "They must have terrible allergies.",
        MOLEBATHILL = "There might be something interesting in there.",

        BATNOSE = "Looks like someone got a bit nosy. Get it? Because it's a nose?",
        BATNOSE_COOKED = "It sure doesn't smell so good now...",
        BATNOSEHAT = "Milk is good for your skeleton!",

        MUSHGNOME = "A living mushroom! Well, I guess all mushrooms are technically living...",

        SPORE_MOON = "I probably shouldn't touch that.",

        MOON_CAP = "Another mushroom that isn't in my handbook...",
        MOON_CAP_COOKED = "This doesn't seem like the smartest idea.",

        MUSHTREE_MOON = "It's actually kind of pretty!",

        LIGHTFLIER = "I think I have a new favourite kind of bug!",

        GROTTO_POOL_BIG = "Sorry Woby, I don't think it'll be any good for swimming.",
        GROTTO_POOL_SMALL = "Sorry Woby, I don't think it'll be any good for swimming.",

        DUSTMOTH = "Can I keep them? Pleeeaaaase?",

        DUSTMOTHDEN = "Woah, so that's where that weird material comes from!",

        ARCHIVE_LOCKBOX = "I wish it came with instructions...",
        ARCHIVE_CENTIPEDE = "Maybe it's friendly?",
        ARCHIVE_CENTIPEDE_HUSK = "I don't think it's worked in a long time.",

        ARCHIVE_COOKPOT =
        {
            COOKING_LONG = "This might take a while. Wanna see this cool bug I found in the meantime?",
            COOKING_SHORT = "Almost time to eat!",
            DONE = "Come and get it!",
            EMPTY = "They weren't so different from us, were they?",
            BURNT = "It's uh... extra done!",
        },

        ARCHIVE_MOON_STATUE = "Well, they look happier than the statues outside... I think.",
        ARCHIVE_RUNE_STATUE =
        {
            LINE_1 = "I sure wish I could read it.",
            LINE_2 = "I wonder what it says.",
            LINE_3 = "I sure wish I could read it.",
            LINE_4 = "I wonder what it says.",
            LINE_5 = "I sure wish I could read it.",
        },

        ARCHIVE_RESONATOR = {
            GENERIC = "I guess it's kind of like a compass.",
            IDLE = "We must've found them all!",
        },

        ARCHIVE_RESONATOR_ITEM = "It must do something important.",

        ARCHIVE_LOCKBOX_DISPENCER = {
          POWEROFF = "I wonder what they used it for.",
          GENERIC =  "That glass part looks kind of familiar.",
        },

        ARCHIVE_SECURITY_DESK = {
            POWEROFF = "It doesn't seem to work anymore.",
            GENERIC = "Any respectable ancient ruin should have some kind of traps.",
        },

        ARCHIVE_SECURITY_PULSE = "Come on Woby, let's see where it goes!",

        ARCHIVE_SWITCH = {
            VALID = "I think these gems might be important, Woby!",
            GEMS = "There's something missing...",
        },

        ARCHIVE_PORTAL = {
            POWEROFF = "I wonder what this did?",
            GENERIC = "Weird, this is the only thing that didn't turn back on.",
        },

        WALL_STONE_2 = "Looks pretty sturdy.",
        WALL_RUINS_2 = "I like the spooky atmosphere.",

        REFINED_DUST = "It took a long time to collect all that dust.",
        DUSTMERINGUE = "Uh... no thanks. Maybe the moths will like it?",

        SHROOMCAKE = "Is that really a cake?",

        NIGHTMAREGROWTH = "We should probably stay away from those, Woby.",

        TURFCRAFTINGSTATION = "I think we might be tampering with something we don't understand.",

        MOON_ALTAR_LINK = "What is it? Aaah, the suspense!",

        -- FARMING
        COMPOSTINGBIN =
        {
            GENERIC = "Oooh, compost bins usually have all kinds of interesting bugs in them!",
            WET = "This might be a bit too wet.",
            DRY = "Hm... does that look a bit too dry, Woby?",
            BALANCED = "That looks pretty good!",
            BURNT = "We should all really be more careful with fire!",
        },
        COMPOST = "Nothing goes to waste!",
        SOIL_AMENDER =
		{
			GENERIC = "I think I'm supposed to let it sit for a while.",
			STALE = "Well, it sure looks like it's doing something.",
			SPOILED = "I'd guess it's just about done.",
		},

		SOIL_AMENDER_FERMENTED = "That's gotta be done!",

        WATERINGCAN =
        {
            GENERIC = "Come on Woby, let's see if the plants need some water.",
            EMPTY = "Maybe I can find a pond around here somewhere...",
        },
        PREMIUMWATERINGCAN =
        {
            GENERIC = "Wow, fancy!",
            EMPTY = "Whoops, looks like I'll have to find some water.",
        },

		FARM_PLOW = "Hey, farming doesn't seem too hard!",
		FARM_PLOW_ITEM = "Want to help me find a good place for the garden, Woby?",
		FARM_HOE = "We'll need that to plant seeds.",
		GOLDEN_FARM_HOE = "My tilling skills deserve a gold metal! Get it?",
		NUTRIENTSGOGGLESHAT = "Woah, I can see right through the dirt!",
		PLANTREGISTRYHAT = "It's like a handbook you wear on your head! A headbook?",

        FARM_SOIL_DEBRIS = "We'd better clean that up.",

		FIRENETTLES = "They're even worse than poison oak!",
		FORGETMELOTS = "I keep forgetting to look them up in my handbook.",
		SWEETTEA = "It makes my head feel a bit fuzzy... but I'm sure that's fine!",
		TILLWEED = "Hey! No weeds allowed in the garden!",
		TILLWEEDSALVE = "Even weeds can be helpful in the wilderness!",
        WEED_IVY = "It looks like it has a little monster claw, ready to grab you!",
        IVY_SNARE = "Ah! It really is trying to grab me!",

		TROPHYSCALE_OVERSIZEDVEGGIES =
		{
			GENERIC = "Is there a badge for growing the biggest vegetable?",
			HAS_ITEM = "Weight: {weight}\nHarvested on day: {day}\nPretty good!",
			HAS_ITEM_HEAVY = "Weight: {weight}\nHarvested on day: {day}\nWow, it's huge!",
            HAS_ITEM_LIGHT = "Er... it's not even registering on the scale...",
			BURNING = "Hey! That's not a fire pit!",
			BURNT = "That's what happens when you don't practice fire safety.",
        },

        CARROT_OVERSIZED = "I was hoping it would sprout ears and whiskers too... oh well.",
        CORN_OVERSIZED = "Imagine all the popcorn we could make with that!",
        PUMPKIN_OVERSIZED = "It's the great pumpkin!",
        EGGPLANT_OVERSIZED = "Oh... great! I guess we're eating eggplant for the next week...",
        DURIAN_OVERSIZED = "Why did this one have to grow so big?",
        POMEGRANATE_OVERSIZED = "Do pomegranates usually get that big?",
        DRAGONFRUIT_OVERSIZED = "Unfortunately, not a real dragon.",
        WATERMELON_OVERSIZED = "We'll have watermelon slices for days!",
        TOMATO_OVERSIZED = "It's bigger than you Woby! Well, one version of you at least.",
        POTATO_OVERSIZED = "That's going to need a lot of mashing.",
        ASPARAGUS_OVERSIZED = "Oh... that's a lot of asparagus...",
        ONION_OVERSIZED = "I don't want to be the one who has to chop it.",
        GARLIC_OVERSIZED = "Well, we'll be safe from giant vampires now.",
        PEPPER_OVERSIZED = "Fire! Oh wait, it's just a hot pepper.",

        VEGGIE_OVERSIZED_ROTTEN = "It's all rotten!",

		FARM_PLANT =
		{
			GENERIC = "That's one of our plants.",
			SEED = "Look Woby, it's growing!",
			GROWING = "I'll take good care of you, don't you worry.",
			FULL = "I think it's ready to pick!",
			ROTTEN = "Whoops... I probably should've picked that sooner.",
			FULL_OVERSIZED = "Woah, what a monster!",
			ROTTEN_OVERSIZED = "It's all rotten!",
			FULL_WEED = "Hey, you're not a vegetable!",

			BURNING = "They uh... might need some water.",
		},

        FRUITFLY = "They're just doing what bugs do! I wish they wouldn't do it to my plants though...",
        LORDFRUITFLY = "Neat! I mean, uh... I should probably get him out of the garden.",
        FRIENDLYFRUITFLY = "I'm going to call you Buzzy!",
        FRUITFLYFRUIT = "The Fruit Flies seem to like following it around.",

        SEEDPOUCH = "You can never have too many pockets!",

		-- Crow Carnival
		CARNIVAL_HOST = "Woah! A real bird man!",
		CARNIVAL_CROWKID = "Tiny bird men! Bird kids?",
		CARNIVAL_GAMETOKEN = "What game should I play first? It's so hard to decide!",
		CARNIVAL_PRIZETICKET =
		{
			GENERIC = "We're off to a good start Woby, but we can do better!",
			GENERIC_SMALLSTACK = "Should I go get a prize now? Or save up for something really good...",
			GENERIC_LARGESTACK = "That's got to be worth a really good prize!",
		},

		CARNIVALGAME_FEEDCHICKS_NEST = "I'd sure love to see what's down there.",
		CARNIVALGAME_FEEDCHICKS_STATION =
		{
			GENERIC = "I think it wants me to give it a token.",
			PLAYING = "This doesn't look too hard!",
		},
		CARNIVALGAME_FEEDCHICKS_KIT = "It can't be much harder than setting up a tent.",
		CARNIVALGAME_FEEDCHICKS_FOOD = "Aww, they're not real worms!",

		CARNIVALGAME_MEMORY_KIT = "This doesn't look hard to set up.",
		CARNIVALGAME_MEMORY_STATION =
		{
			GENERIC = "I think it wants me to give it a token.",
			PLAYING = "I bet I'd be pretty good at that!",
		},
		CARNIVALGAME_MEMORY_CARD =
		{
			GENERIC = "I'd sure love to see what's down there.",
			PLAYING = "I'm pretty sure it was this one...",
		},

		CARNIVALGAME_HERDING_KIT = "I'll have that up in a jiffy!",
		CARNIVALGAME_HERDING_STATION =
		{
			GENERIC = "I think it wants me to give it a token.",
			PLAYING = "I wonder if Woby's part sheepdog...",
		},
		CARNIVALGAME_HERDING_CHICK = "Go to the center, please!",

		CARNIVAL_PRIZEBOOTH_KIT = "I'll have this set up right away!",
		CARNIVAL_PRIZEBOOTH =
		{
			GENERIC = "Is there a badge for winning all the prizes?",
		},

		CARNIVALCANNON_KIT = "I just hope it doesn't startle Woby.",
		CARNIVALCANNON =
		{
			GENERIC = "We should probably test it out. You know, for safety.",
			COOLDOWN = "Don't worry Ms. Wickerbottom, I'll clean this all up later!",
		},

		CARNIVAL_PLAZA_KIT = "I'm good at planting trees, we did it all the time in the Pioneers!",
		CARNIVAL_PLAZA =
		{
			GENERIC = "Maybe if we decorate around it, more birds will come!",
			LEVEL_2 = "It's looking good, but I think we can do even better.",
			LEVEL_3 = "I've got a real talon for decorating! Get it? Because crows have talons?",
		},

		CARNIVALDECOR_EGGRIDE_KIT = "I'll have that up in a jiffy!",
		CARNIVALDECOR_EGGRIDE = "I kind of wish they had a bigger one.",

		CARNIVALDECOR_LAMP_KIT = "I'll have that up in a jiffy!",
		CARNIVALDECOR_LAMP = "Do you think it's powered by magic?",
		CARNIVALDECOR_PLANT_KIT = "I'll have that up in a jiffy!",
		CARNIVALDECOR_PLANT = "I'm going to take good care of it!",

		CARNIVALDECOR_FIGURE =
		{
			RARE = "Oooh, I got an extra rare one!",
			UNCOMMON = "I'm adding it to my collection!",
			GENERIC = "Neat! I love collecting things!",
		},
		CARNIVALDECOR_FIGURE_KIT = "The suspense is killing me!",

        CARNIVAL_BALL = "Get the ball Woby! Uh... I guess we'll work on that later.", --unimplemented
		CARNIVAL_SEEDPACKET = "I guess it's sort of like trail mix. Sort of.",
		CARNIVALFOOD_CORNTEA = "Yum...?",

        CARNIVAL_VEST_A = "I wonder if those bird kids would want to join my Pioneer troop...",
        CARNIVAL_VEST_B = "I can blend in with the trees!",
        CARNIVAL_VEST_C = "It really helps in hot weather!",

        -- YOTB
        YOTB_SEWINGMACHINE = "My mom has one of those! It looks a bit different, though.",
        YOTB_SEWINGMACHINE_ITEM = "Now to put it together!",
        YOTB_STAGE = "Let's win some prizes, Woby!",
        YOTB_POST =  "It's pretty hard to teach a beefalo \"sit\" and \"stay\".",
        YOTB_STAGE_ITEM = "It can't be that much harder than pitching a tent.",
        YOTB_POST_ITEM =  "This looks easy enough to put together.",


        YOTB_PATTERN_FRAGMENT_1 = "This looks like instructions for a beefalo costume! Only part of one, though...",
        YOTB_PATTERN_FRAGMENT_2 = "This looks like instructions for a beefalo costume! Only part of one, though...",
        YOTB_PATTERN_FRAGMENT_3 = "This looks like instructions for a beefalo costume! Only part of one, though...",

        YOTB_BEEFALO_DOLL_WAR = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_DOLL = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_FESTIVE = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_NATURE = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_ROBOT = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_ICE = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_FORMAL = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_VICTORIAN = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },
        YOTB_BEEFALO_DOLL_BEAST = {
            GENERIC = "I hope Woby doesn't think it's a chew toy...",
            YOTB = "What do you think, Woby? Should I show it to the judge?",
        },

        WAR_BLUEPRINT = "I wonder if the beefalo actually like wearing these.",
        DOLL_BLUEPRINT = "Aww, it's cute!",
        FESTIVE_BLUEPRINT = "I wish I could make one for Woby, but her measurements keep changing...",
        ROBOT_BLUEPRINT = "Is this really for sewing?",
        NATURE_BLUEPRINT = "I hope it doesn't attract too many bees.",
        FORMAL_BLUEPRINT = "This doesn't seem very practical for the outdoors.",
        VICTORIAN_BLUEPRINT = "This seems unnecessarily fancy.",
        ICE_BLUEPRINT = "I guess a beefalo's own fuzzy coat isn't enough to keep warm.",
        BEAST_BLUEPRINT = "I wonder what kind of animal this costume is based off of?",

        BEEF_BELL = "The beefalo seem to really like the sound it makes!",

		-- YOT Catcoon
		KITCOONDEN = 
		{
			GENERIC = "Aww, it's like a dog house for cats!",
            BURNT = "I'm glad I taught those little guys how to stop, drop and roll!",
			PLAYING_HIDEANDSEEK = "Don't give me any hints, Woby!",
			PLAYING_HIDEANDSEEK_TIME_ALMOST_UP = "I need to hurry up and find them all!",
		},

		KITCOONDEN_KIT = "I built a bird house once, a cat house should be easy!",

		TICOON = 
		{
			GENERIC = "Is that a real man-eating tiger? I thought they'd be bigger.",
			ABANDONED = "I hope he's not too upset at me...",
			SUCCESS = "Look, he found one!",
			LOST_TRACK = "Maybe he doesn't know where he's going after all.",
			NEARBY = "I think he smells something nearby!",
			TRACKING = "Come on Woby, let's follow him!",
			TRACKING_NOT_MINE = "Whoops, sorry! All man-eating tigers look so alike...",
			NOTHING_TO_TRACK = "It doesn't look like he's picking up any scents.",
			TARGET_TOO_FAR_AWAY = "Maybe we should try looking somewhere else.",
		},
		
		YOT_CATCOONSHRINE =
        {
            GENERIC = "Come on Woby, let's make something!",
            EMPTY = "I know a lot about dogs, but what do cats like?",
            BURNT = "This is exactly why learning fire safety is so important!",
        },

		KITCOON_FOREST = "Aww, they're so cute even Woby likes them!",
		KITCOON_SAVANNA = "Aww, they're so cute even Woby likes them!",
		KITCOON_MARSH = "I wonder if there's a badge for kitten wrangling...",
		KITCOON_DECIDUOUS = "I wonder if there's a badge for kitten wrangling...",
		KITCOON_GRASS = "Hey little guy!",
		KITCOON_ROCKY = "Hey little guy!",
		KITCOON_DESERT = "Hmm, do you think they'd eat granola?",
		KITCOON_MOON = "Hmm, do you think they'd eat granola?",
		KITCOON_YOT = "Hmm, do you think they'd eat granola?",

        -- Moon Storm
        ALTERGUARDIAN_PHASE1 = {
            GENERIC = "Woah, is that a space creature?!",
            DEAD = "Aww, I wanted to ask them what it's like up in space...",
        },
        ALTERGUARDIAN_PHASE2 = {
            GENERIC = "I'm starting to think they might be mad at us, Woby.",
            DEAD = "At least now I can get a better look at it!",
        },
        ALTERGUARDIAN_PHASE2SPIKE = "I think they're trying to keep us from getting away!",
        ALTERGUARDIAN_PHASE3 = "If I just get a bit closer... I'm sure I can convince them we just want to be friends!",
        ALTERGUARDIAN_PHASE3TRAP = "We should probably stay away from those, Woby.",
        ALTERGUARDIAN_PHASE3DEADORB = "Do you think they're going to get up again, Woby?",
        ALTERGUARDIAN_PHASE3DEAD = "Well... I guess that's that.",

        ALTERGUARDIANHAT = "It tells me all kinds of stories.",
        ALTERGUARDIANHATSHARD = "I'm sure we can still find a use for it!",

        MOONSTORM_GLASS = {
            GENERIC = "I've never seen glass made by lightning before!",
            INFUSED = "Look at that, Woby! It's glowing!"
        },

        MOONSTORM_STATIC = "I wonder what he's working on?",
        MOONSTORM_STATIC_ITEM = "You'll be shocked to see what's inside! Get it? Because there's static inside?",
        MOONSTORM_SPARK = "It's literally spine-tingling!",

        BIRD_MUTANT = "Woah! That doesn't look like any of the birds in my handbook!",
        BIRD_MUTANT_SPITTER = "Maybe it's a cardinal? A... really sick cardinal?",

        WAGSTAFF_NPC = "Hey Mister, are you okay? You're uh... flickering...?",
        ALTERGUARDIAN_CONTAINED = "Wow, we sure are lucky he happened to have that with him!",

        WAGSTAFF_TOOL_1 = "Maybe this is what he's looking for?",
        WAGSTAFF_TOOL_2 = "Um... yeah, this one looks right!",
        WAGSTAFF_TOOL_3 = "What do you think, Woby? Is this the tool we're looking for?",
        WAGSTAFF_TOOL_4 = "It's definitely a tool of some kind... hope it's the right one!",
        WAGSTAFF_TOOL_5 = "That one looks about right... I think?",

        MOONSTORM_GOGGLESHAT = "It's important to have the proper equipment in a storm.",

        MOON_DEVICE = {
            GENERIC = "Wow! I wonder what it's for?",
            CONSTRUCTION1 = "We've still got a ways to go.",
            CONSTRUCTION2 = "It's almost set up!",
        },

		-- Wanda
        POCKETWATCH_HEAL = {
			GENERIC = "Ms. Wanda sure has a lot of clocks!",
			RECHARGING = "Is that clock ticking backwards?",
		},

        POCKETWATCH_REVIVE = {
			GENERIC = "Ms. Wanda sure has a lot of clocks!",
			RECHARGING = "Is that clock ticking backwards?",
		},

        POCKETWATCH_WARP = {
			GENERIC = "Ms. Wanda sure has a lot of clocks!",
			RECHARGING = "Is that clock ticking backwards?",
		},

        POCKETWATCH_RECALL = {
			GENERIC = "Ms. Wanda sure has a lot of clocks!",
			RECHARGING = "Is that clock ticking backwards?",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda",
		},

        POCKETWATCH_PORTAL = {
			GENERIC = "Ms. Wanda sure has a lot of clocks!",
			RECHARGING = "Is that clock ticking backwards?",
--fallback to speech_wilson.lua 			UNMARKED = "only_used_by_wanda unmarked",
--fallback to speech_wilson.lua 			MARKED_SAMESHARD = "only_used_by_wanda same shard",
--fallback to speech_wilson.lua 			MARKED_DIFFERENTSHARD = "only_used_by_wanda other shard",
		},

        POCKETWATCH_WEAPON = {
			GENERIC = "Um, Ms. Wanda... do you make all these clocks out in the woods?",
--fallback to speech_wilson.lua 			DEPLETED = "only_used_by_wanda",
		},

        POCKETWATCH_PARTS = "Woah, these gears are kind of spooky!",
        POCKETWATCH_DISMANTLER = "Making clocks looks pretty complicated.",

        POCKETWATCH_PORTAL_ENTRANCE = 
		{
			GENERIC = "Come on Woby, this is going to be fun!",
			DIFFERENTSHARD = "Come on Woby, this is going to be fun!",
		},
        POCKETWATCH_PORTAL_EXIT = "Time travel sure is amazing!",

        -- Waterlog
        WATERTREE_PILLAR = "Woah, would you look at the size of that tree!",
        OCEANTREE = "I guess they don't have to worry about getting enough water.",
        OCEANTREENUT = "That's one big seed!",
        WATERTREE_ROOT = "Watch out for water hazards!",

        OCEANTREE_PILLAR = "It's a pretty swell shade tree!",
        
        OCEANVINE = "Maybe one of them will turn out to be a snake!",
        FIG = "I don't really like figs...",
        FIG_COOKED = "I don't really like cooked figs any better...",

        SPIDER_WATER = "Woah, look how fast they are on the water, Woby!",
        MUTATOR_WATER = "Hey, cookies! Um... what are these made of, exactly?",
        OCEANVINE_COCOON = "That must be their nest! If I could just get a closer look...",
        OCEANVINE_COCOON_BURNT = "The poor spiders...",

        GRASSGATOR = "He seems pretty shy.",

        TREEGROWTHSOLUTION = "I'm glad we found a use for those figs other than eating them...",

        FIGATONI = "At least the fig's hidden inside.",
        FIGKABAB = "Aw, did it have to be figs?",
        KOALEFIG_TRUNK = "How many figs are in there?!",
        FROGNEWTON = "Hey, that's pretty good! What's in it?",

        -- The Terrorarium
        TERRARIUM = {
            GENERIC = "Woah! That's not normal!",
            CRIMSON = "Oh no, I think that shadow stuff made the tree sick...",
            ENABLED = "WOAH! That's REALLY not normal!",
			WAITING_FOR_DARK = "Spooky!",
			COOLDOWN = "I guess it can't stay lit up all the time.",
			SPAWN_DISABLED = "Aww, can't we turn it on for a little bit?",
        },

        -- Wolfgang
        MIGHTY_GYM = 
        {
            GENERIC = "Wow! I wonder if I could be as strong as Mr. Wolfgang one day...",
            BURNT = "Aww, I never even got to try it...",
        },

        DUMBBELL = "I can do it! I just... need to get a good grip on it!",
        DUMBBELL_GOLDEN = "Uh, m-maybe I should start with something a bit lighter.",
		DUMBBELL_MARBLE = "Oh... when he said it was made of marble, I kind of hoped he meant the tiny ones.",
        DUMBBELL_GEM = "Time to hit the gem! Get it? Because gem sounds like gym?",
        POTATOSACK = "Do you think I'd get muscles if I ate more potatoes, Woby?",


        TERRARIUMCHEST = 
		{
			GENERIC = "I wonder how it got here?",
			BURNT = "Aww, and it was such a neat looking chest too...",
			SHIMMER = "What do you say, Woby? Should we take a look inside?",
		},

		EYEMASKHAT = "Don't worry Woby. It's just a hat, see?",

        EYEOFTERROR = "Wow! Do you think it escaped from a giant head?",
        EYEOFTERROR_MINI = "Would you say they're... multipl-eying? Heh. Good one, Walter.",
        EYEOFTERROR_MINI_GROUNDED = "Ohh, so that's how baby eyeballs are made.",

        FROZENBANANADAIQUIRI = "Don't drink it too fast or you'll get a headache.",
        BUNNYSTEW = "There's no Pioneer that could say no to this!",
        MILKYWHITES = "Woby, can you find me a stick? I want to poke it.",

        CRITTER_EYEOFTERROR = "What is it, boy? Do you see something?",

        SHIELDOFTERROR ="I like to think it's smiling.",
        TWINOFTERROR1 = "Somewhere, some poor giant robot is walking around completely blind...",
        TWINOFTERROR2 = "Somewhere, some poor giant robot is walking around completely blind...",

        -- Year of the Catcoon
        CATTOY_MOUSE = "Sorry Woby, that's for the kits to play with.",
        KITCOON_NAMETAG = "It looks almost like yours, Woby!",

		KITCOONDECOR1 =
        {
            GENERIC = "I wonder if the kits think it's a real bird?",
            BURNT = "I guess it was too convincing, someone tried to cook it!",
        },
		KITCOONDECOR2 =
        {
            GENERIC = "It's fishing for kits!",
            BURNT = "That wasn't kindling!",
        },

		KITCOONDECOR1_KIT = "Don't worry kitties, I'll put this together lickety-split!",
		KITCOONDECOR2_KIT = "Don't worry kitties, I'll put this together lickety-split!",

        -- WX78
        WX78MODULE_MAXHEALTH = "Robot guts! Neat!",
        WX78MODULE_MAXSANITY1 = "Robot guts! Neat!",
        WX78MODULE_MAXSANITY = "Robot guts! Neat!",
        WX78MODULE_MOVESPEED = "Robot guts! Neat!",
        WX78MODULE_MOVESPEED2 = "Robot guts! Neat!",
        WX78MODULE_HEAT = "Robot guts! Neat!",
        WX78MODULE_NIGHTVISION = "Robot guts! Neat!",
        WX78MODULE_COLD = "Robot guts! Neat!",
        WX78MODULE_TASER = "Robot guts! Neat!",
        WX78MODULE_LIGHT = "Robot guts! Neat!",
        WX78MODULE_MAXHUNGER1 = "Robot guts! Neat!",
        WX78MODULE_MAXHUNGER = "Robot guts! Neat!",
        WX78MODULE_MUSIC = "Robot guts! Neat!",
        WX78MODULE_BEE = "Robot guts! Neat!",
        WX78MODULE_MAXHEALTH2 = "Robot guts! Neat!",

        WX78_SCANNER = 
        {
            GENERIC ="Aww, who's a good little robot?",
            HUNTING = "Aww, who's a good little robot?",
            SCANNING = "Aww, who's a good little robot?",
        },

        WX78_SCANNER_ITEM = "I guess it's taking a nap.",
        WX78_SCANNER_SUCCEEDED = "What is it boy? Do you have something to show WX?",

        WX78_MODULEREMOVER = "Should I start carrying something like this in my first aid kit?",

        SCANDATA = "Neat! Wanna scan me next?",
    },

    DESCRIBE_GENERIC = "That sure is a mystery!",
    DESCRIBE_TOODARK = "I sure wish I had a flashlight.",
    DESCRIBE_SMOLDERING = "Hurry, stomp it out before it catches fire!",

    DESCRIBE_PLANTHAPPY = "I think I'm doing a good job!",
    DESCRIBE_PLANTVERYSTRESSED = "It's not looking so good...",
    DESCRIBE_PLANTSTRESSED = "Something must be bothering it.",
    DESCRIBE_PLANTSTRESSORKILLJOYS = "I should probably do some weeding.",
    DESCRIBE_PLANTSTRESSORFAMILY = "Maybe it would be happier if it wasn't all alone?",
    DESCRIBE_PLANTSTRESSOROVERCROWDING = "I think we might've planted these too close together, Woby.",
    DESCRIBE_PLANTSTRESSORSEASON = "I don't think it likes this weather.",
    DESCRIBE_PLANTSTRESSORMOISTURE = "Do you think it needs some water, Woby?",
    DESCRIBE_PLANTSTRESSORNUTRIENTS = "Maybe it needs some better soil...",
    DESCRIBE_PLANTSTRESSORHAPPINESS = "I think it needs a story or two to cheer it up!",

    EAT_FOOD =
    {
        TALLBIRDEGG_CRACKED = "If I'm the first one they see, they might think I'm their mom.",
		WINTERSFEASTFUEL = "Mmmm, tastes like a perfectly toasted s'more.",
    },
}
