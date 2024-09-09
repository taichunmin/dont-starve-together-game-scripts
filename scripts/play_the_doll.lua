local costumes = {}
local scripts = {}

local fn = require("play_commonfn")

costumes["DOLL"]=			{ body = "costume_doll_body",		head ="mask_dollhat",			name= STRINGS.CAST.DOLL}
costumes["DOLL_BROKEN"]=	{ body = "costume_doll_body",		head ="mask_dollbrokenhat",		name= STRINGS.CAST.DOLL_BROKEN }
costumes["DOLL_REPAIRED"]=	{ body = "costume_doll_body",		head ="mask_dollrepairedhat",	name= STRINGS.CAST.DOLL_REPAIRED }
costumes["KING"]=			{ body = "costume_king_body",		head ="mask_kinghat",			name= STRINGS.CAST.KING }
costumes["BLACKSMITH"]=		{ body = "costume_blacksmith_body",	head ="mask_blacksmithhat",		name= STRINGS.CAST.BLACKSMITH }
costumes["QUEEN"]=			{ body = "costume_queen_body", 		head ="mask_queenhat",			name= STRINGS.CAST.QUEEN }
costumes["TREE"]=			{ body = "costume_tree_body",		head ="mask_treehat",			name= STRINGS.CAST.TREE }
costumes["MIRROR"]=			{ body = "costume_mirror_body",		head ="mask_mirrorhat",			name= STRINGS.CAST.MIRROR }
costumes["FOOL"]=			{ body = "costume_fool_body",		head ="mask_foolhat",			name= STRINGS.CAST.FOOL }	

local starting_act = "ACT1_SCENE1"
-----------------------------------------------------------------------------------------------------------------
    -- COSTUME PLAYS
	scripts["BLACKSMITH_SOLILOQUY"]= {
		cast = { "BLACKSMITH" },
		lines = {
			{actionfn = fn.findpositions,	duration = 1, positions={["BLACKSMITH"] = 1,}},
            {actionfn = fn.marionetteon,    duration = 0.1, },
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 1.3, },

			{roles = {"BIRD2"},				duration = 1.5,		line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[1]},
			{roles = {"BIRD1"},				duration = 1.5,		line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[2]},

			{roles = {"BLACKSMITH"},		duration = 2.5, 	line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[3]},
			{roles = {"BLACKSMITH"},		duration = 2.5, 	line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[4]},
			{roles = {"BLACKSMITH"},		duration = 2.5, 	line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[5]},
			{roles = {"BLACKSMITH"},		duration = 2.5, 	line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[6]},

			{roles = {"BIRD2"},				duration = 1.5, 	line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[7]},
			{roles = {"BIRD1"},				duration = 2,		line = STRINGS.STAGEACTOR.BLACKSMITH_SOLILOQUY[8]},

			{actionfn = fn.actorsbow,		duration = 0.2, },
            {actionfn = fn.marionetteoff,   duration = 0.1, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["KING_SOLILOQUY"]= {
		cast = { "KING" },
		lines = {
			{actionfn = fn.findpositions,	duration = 1, positions={["KING"] = 1,}},
            {actionfn = fn.marionetteon,    duration = 0.1, },
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 1.3, },	

			{roles = {"BIRD2"},				duration = 1.5,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[1]},
			{roles = {"BIRD1"},				duration = 1.5,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[2]},

			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[3]},
			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[4]},
			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[5]},
			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[6]},

			{roles = {"BIRD2"},				duration = 2,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[7]},
			{roles = {"BIRD1"},				duration = 2,		line = STRINGS.STAGEACTOR.KING_SOLILOQUY[8]},

			{actionfn = fn.actorsbow,		duration = 0.2, },
            {actionfn = fn.marionetteoff,   duration = 0.1, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["FOOL_SOLILOQUY"]= {
		cast = { "FOOL" },
		lines = {
			{actionfn = fn.findpositions,	duration = 1, positions={["FOOL"] = 1,}},
            {actionfn = fn.marionetteon,    duration = 0.1, },
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 1.3, },

			{roles = {"BIRD2"},				duration = 1.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[1]},
			{roles = {"BIRD1"},				duration = 1.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[2], sgparam="disappointed"},

			{roles = {"FOOL"},				duration = 2.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[3]},
			{roles = {"FOOL"},				duration = 2.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[4]},
			{roles = {"FOOL"},				duration = 2.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[5]},
			{roles = {"FOOL"},				duration = 2.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[6]},

			{roles = {"BIRD2"},				duration = 1.5,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[7]},
			{roles = {"BIRD1"},				duration = 2,		line = STRINGS.STAGEACTOR.FOOL_SOLILOQUY[8]},

			{actionfn = fn.actorsbow,		duration = 0.2, },
            {actionfn = fn.marionetteoff,   duration = 0.1, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

    scripts["TREE_SOLILOQUY"]= {
		cast = { "TREE" },
		lines = {
			{actionfn = fn.findpositions,	duration = 1, positions={["TREE"] = 1,}},
            {actionfn = fn.marionetteon,    duration = 0.1, },
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 1.3, },	

			{roles = {"BIRD2"},				duration = 1.5,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[1]},
			{roles = {"BIRD1"},				duration = 1.5,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[2], sgparam="excited"},

			{roles = {"NARRATOR"},			duration = 3,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[3]},
			{roles = {"NARRATOR"},			duration = 3,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[4]},
			{roles = {"NARRATOR"},			duration = 3,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[5]},

			{roles = {"BIRD2"},				duration = 2,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[6], sgparam="excited"},
			{roles = {"BIRD1"},				duration = 2,		line = STRINGS.STAGEACTOR.TREE_SOLILOQUY[7], sgparam="excited"},

			{actionfn = fn.actorsbow,		duration = 0.2, },
            {actionfn = fn.marionetteoff,   duration = 0.1, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}
	
	scripts["REUNION"]= {
		cast = { "QUEEN", "BLACKSMITH" },
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["QUEEN"] = 2,["BLACKSMITH"] = 3,}},
            {actionfn = fn.marionetteon,    duration = 0.1, },
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 1.3, },
		
			{roles = {"BIRD2"},				duration = 1.5,		line = STRINGS.STAGEACTOR.REUNION[1]},
			{roles = {"BIRD1"},				duration = 1.5,		line = STRINGS.STAGEACTOR.REUNION[2] ,sgparam="excited"},

			{roles = {"NARRATOR"},			duration = 3,		line = STRINGS.STAGEACTOR.REUNION[3]},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.REUNION[4]},

			{roles = {"BLACKSMITH"},		duration = 2,		line = STRINGS.STAGEACTOR.REUNION[5], anim="spooked"},
			{roles = {"BLACKSMITH"},		duration = 2,		line = STRINGS.STAGEACTOR.REUNION[6]},

			{roles = {"QUEEN"},				duration = 1.5,		line = STRINGS.STAGEACTOR.REUNION[7]},
			{roles = {"QUEEN"},				duration = 2.5,		line = STRINGS.STAGEACTOR.REUNION[8]},
			{roles = {"QUEEN"},				duration = 2.5,		line = STRINGS.STAGEACTOR.REUNION[9]},
			{roles = {"QUEEN"},				duration = 3,		line = STRINGS.STAGEACTOR.REUNION[10]},
			{roles = {"QUEEN"},				duration = 3,		line = STRINGS.STAGEACTOR.REUNION[11]},
			{roles = {"QUEEN"},				duration = 3,		line = STRINGS.STAGEACTOR.REUNION[12]},

			{roles = {"BIRD2"},				duration = 3,		line = STRINGS.STAGEACTOR.REUNION[13]},
			{roles = {"BIRD1"},				duration = 2,		line = STRINGS.STAGEACTOR.REUNION[14]},

			{actionfn = fn.crowdcomment,	duration = 3,		line = STRINGS.STAGEACTOR.REUNION[15], prefabs = {"winona"},},

			{actionfn = fn.actorsbow,		duration = 1, },
            {actionfn = fn.marionetteoff,   duration = 0.1, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}} 
------------------------------------------------------------------------------------------------------------------
local MARIONETTE_TIME = 1.1

	-- THE PLAY
	scripts["ACT1_SCENE1"]= {
		cast = { "DOLL" },
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[1],
		next = "ACT1_SCENE2",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL"] = 1,}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act1" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "happy"}, --bgm_mood: stageplay_set/bgm_moods/music_happy

			{roles = {"BIRD2"},				duration = 1.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE1},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE2, sgparam="excited"},

			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE3, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE4, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE5, sgparam="mysterious"},

			{roles = {"DOLL"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE6, anim ="emote_yawn"},
			{roles = {"DOLL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE7},
			{roles = {"DOLL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE8},
			{roles = {"DOLL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE9},
			{roles = {"DOLL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE10},
			{roles = {"DOLL"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE11},
			{roles = {"DOLL"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE12},

			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE13, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 1.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE14},
			{roles = {"DOLL"},				duration = 2,		anim ="emote_swoon"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE15, sgparam="mysterious"},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE16},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE17},
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE18, sgparam="excited",	treetest = true},
			{actionfn = fn.stopbgmusic,		duration = 0.1, },
			{roles = {"BIRD1","BIRD2"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE1.LINE19, sgparam="laugh"},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, }, 
		}}

	scripts["ACT1_SCENE2"]= {
		cast = { "DOLL", "BLACKSMITH" },
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[2],
		next = "ACT1_SCENE3",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL"] = 2,["BLACKSMITH"] = 3,}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act1" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "happy"}, --bgm_mood: stageplay_set/bgm_moods/music_happy

			{roles = {"BIRD2"},				duration = 1.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE1, sgparam="excited"},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE2},

			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE3},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE4},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE5},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE6, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE7, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE8, sgparam="mysterious"},

			{roles = {"BLACKSMITH"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE9, anim="spooked"},
			{roles = {"BLACKSMITH"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE10},
			{roles = {"BLACKSMITH"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE11},
			{roles = {"BLACKSMITH"},		duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE12},
			{roles = {"BLACKSMITH"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE13},
			{roles = {"BLACKSMITH"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE14},
			{roles = {"BLACKSMITH"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE15},
			
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE16},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE17},
			{roles = {"BLACKSMITH"},		duration = 2.0,		anim = {"build_pre","build_loop","build_loop","build_loop","build_loop","build_pst"}},

			{roles = {"DOLL"},				duration = 0.01,	anim = "emote_pants"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE18},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE19, sgparam="mysterious"},

			{roles = {"DOLL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE20, anim="emote_sleepy"},
			{roles = {"DOLL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE21, anim="emote_sleepy"},

			{roles = {"DOLL"},				duration = 0.01,	anim={"emote_dab_pre","emote_dab_pst"}},
			{actionfn = fn.stinger,			duration = 0.01,	sound="stageplay_set/statue_lyre/stinger_dramatic" },
			{actionfn = fn.swapmask,		duration = 1,		roles = {"DOLL"}, mask = "mask_dollbrokenhat"},

			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE22},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE23},
			{roles = {"BLACKSMITH"},		duration = 3.0,		anim ="yawn"},
			{actionfn = fn.findpositions,	duration = 1.0,		positions={["BLACKSMITH"] = 8,}},

			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE24},
			{roles = {"DOLL"},				duration = 1.0,		anim = "emote_pants"},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE25},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE26, sgparam="mysterious"},
			{actionfn = fn.crowdcomment,	duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE27, prefabs = {"winona"},},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE28},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE29, sgparam="disappointed"},
			{roles = {"BIRD1","BIRD2"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE30, sgparam="laugh"},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE31, sgparam="excited",	treetest=true},			
			{actionfn = fn.stopbgmusic,		duration = 0.2, },
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE2.LINE32, sgparam="excited",	treetest=true},


			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["ACT1_SCENE3"]= {
		cast = { "DOLL_BROKEN", "KING" },
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[3],
		next = "ACT2_SCENE4",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_BROKEN"] = 2,["KING"] = 3,}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act1" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "happy"}, --bgm_mood: stageplay_set/bgm_moods/music_happy
		
			{roles = {"BIRD2"},				duration = 1.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE1},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE2, sgparam="excited"},
			{roles = {"BIRD2"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE3},

			{roles = {"NARRATOR"},			duration = 4.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE4},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE5},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE6},
			{roles = {"NARRATOR"},			duration = 4.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE7, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE8},

			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE9, sgparam="upbeat"},
			{roles = {"KING"},				duration = 2.5,		anim = "emote_waving"},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE10, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE11},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE12},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE13},

			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE14, anim="emote_shrug"},
			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE15},

			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE16, anim="emote_laugh"},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE17},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE18},

			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE19},
			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE20},
			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE21},

			{roles = {"KING"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE22, anim="emote_laugh"},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE23},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE24},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE25},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE26},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE27},

			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE28, anim="emote_happycheer"},
			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE29},

			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE30},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE31},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE32},			
			{actionfn = fn.stopbgmusic,		duration = 0.2, },
			{roles = {"BIRD1","BIRD2"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT1_SCENE3.LINE33, sgparam="laugh"},


			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["ACT2_SCENE4"]= {
		cast = { "DOLL_BROKEN", "KING", "MIRROR"},
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[4],
		next = "ACT2_SCENE5",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_BROKEN"] = 2,["KING"] = 3,["MIRROR"] = 8,}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act2" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "mysterious"}, --bgm_mood: stageplay_set/bgm_moods/music_mysterious
		
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE1},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE2},
			{roles = {"BIRD2"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE3},

			{roles = {"NARRATOR"},			duration = 4.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE4},
			{roles = {"NARRATOR"},			duration = 4.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE5},
			{roles = {"NARRATOR"},			duration = 4.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE6},
			{roles = {"NARRATOR"},			duration = 4.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE7},
			{roles = {"NARRATOR"},			duration = 4.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE8, sgparam="mysterious"},

			--{roles = {"KING"},			duration = 2,		anim = {"build_pre","build_loop","build_loop","build_loop","build_loop","build_pst"}},
			{roles = {"KING"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE9},
			{roles = {"KING"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE10, anim="emote_sleepy"},
			{roles = {"KING"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE11},
			{roles = {"KING"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE12, anim="emote_shrug"},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE13, anim="emoteXL_annoyed"},
			{roles = {"KING"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE14},

			{roles = {"DOLL_BROKEN"},		duration = 1.5,		anim="emote_impatient"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE15},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE16, sgparam="mysterious"},

			{actionfn = fn.findpositions,	duration = 1,		positions={["KING"] = 5}},

			{roles = {"DOLL_BROKEN"},		duration = 1,		anim="look"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE17},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE18, sgparam="mysterious"},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE19, sgparam="upbeat"},

			{actionfn = fn.findpositions,	duration = 1,		positions={["MIRROR"] = 3}},
			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE20, anim="emoteXL_waving1"},

			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE21},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE22},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE23},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE24},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE25},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE26},

			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE27, sgparam="disappointed"},
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE28, sgparam="disappointed"},

			{roles = {"DOLL_BROKEN"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE29, anim="emoteXL_annoyed"},
			{roles = {"DOLL_BROKEN"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE30},
			{roles = {"DOLL_BROKEN"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE31},
			{actionfn = fn.findpositions,	duration = 0.5,		positions={["DOLL_BROKEN"] = 6}},
			{actionfn = fn.findpositions,	duration = 1,		positions={["KING"] = 2}},
			
			{roles = {"KING"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE32, anim="emoteXL_angry"},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE33},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE34},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE35},
			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE36},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE37},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE38},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE39, anim={"channel_loop","channel_loop","channel_loop","channel_loop","channel_loop"}},

			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_BROKEN"] = 7}},
			{actionfn = fn.stinger,			duration = 0.1,		sound="stageplay_set/statue_lyre/stinger_magicblast"},
			{actionfn = fn.swapmask,		duration = 0.1,		roles = {"DOLL_BROKEN"}, mask = "mask_dollrepairedhat"},
			{roles = {"DOLL_BROKEN"},		duration = 2.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE40, anim="death2", animtype="hold"},
			
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE41},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE42},
			{actionfn = fn.findpositions,	duration = 1,		positions={["KING"] = 8}},

			{actionfn = fn.crowdcomment,	duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE43, prefabs = {"waxwell"},},

			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE44, treetest = true},
			{actionfn = fn.stopbgmusic,		duration = 0.2, },
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE4.LINE45, sgparam="excited",	treetest= true},

			{roles = {"DOLL_BROKEN"},		duration = 1.5,		anim="corpse_revive"},
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_BROKEN"] = 2}},

			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },

		}}

	scripts["ACT2_SCENE5"]= {
		cast = { "DOLL_REPAIRED", "MIRROR"},
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[5],
		next = "ACT2_SCENE6",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_REPAIRED"] = 2,["MIRROR"] = 3}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act2" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "mysterious"}, --bgm_mood: stageplay_set/bgm_moods/music_mysterious

			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE1, sgparam="excited",	treetest= true},
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE2,					treetest= true},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE3},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE4},

			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE5},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE6},
			
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE7},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE8},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE9},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE10},

			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE11},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE12},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE13},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE14},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE15},

			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE16},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE17, anim="emote_fistshake" },
			{actionfn = fn.stopbgmusic,		duration = 0.1, },
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE5.LINE18, anim="emote_fistshake" },


			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["ACT2_SCENE6"]= {
		cast = { "DOLL_REPAIRED", "KING"},
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[6],
		next = "ACT3_SCENE7",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_REPAIRED"] = 2,["KING"] = 5}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act2" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "drama"}, --bgm_mood: stageplay_set/bgm_moods/music_drama

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE1},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE2},

			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE3},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE4, sgparam="mysterious"},

			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE5},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE6},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE7},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE8},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE9},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE10},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE11},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE12},

			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE13},

			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE14, anim="emoteXL_annoyed"},

			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE15},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE16},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE17},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE18},

			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE19, anim="emote_fistshake"},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE20, anim={"channel_loop","channel_loop","channel_loop","channel_loop","channel_loop"}},
			{actionfn = fn.stinger,			duration = 0.01,	sound="stageplay_set/statue_lyre/stinger_magicblast" },
			{actionfn = fn.findpositions,	duration = 0.1,		positions={["KING"] = 8}},
			
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE21, anim="emoteXL_angry"},
									
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE22},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE23},			
			{actionfn = fn.stopbgmusic,		duration = 0.1, },
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT2_SCENE6.LINE24, sgparam="mysterious"},


			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["ACT3_SCENE7"]= {
		cast = { "FOOL", "DOLL_REPAIRED"},
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[7],
		next = "ACT3_SCENE8",
		lines = {			
			{actionfn = fn.findpositions,	duration = 1,		positions={["FOOL"] = 1,["DOLL_REPAIRED"] = 4}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act3" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "mysterious"}, --bgm_mood: stageplay_set/bgm_moods/music_mysterious

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE1},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE2},
			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE3},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE4},

			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE5},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE6},
			{roles = {"NARRATOR"},			duration = 3.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE7, sgparam="mysterious"},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE8, sgparam="upbeat"},

			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE9, anim="emote_happycheer"},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE10},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE11},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE12},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE13},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE14},

			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE15},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE16},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE17},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE18},

			{roles = {"FOOL"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE19},
			{actionfn = fn.stopbgmusic,		duration = 0.1, },
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE7.LINE20, anim="emote_shrug" },

			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["ACT3_SCENE8"]= {
		cast = { "KING", "FOOL", "DOLL_REPAIRED"},
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[8],
		next = "ACT3_SCENE9",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["KING"] = 2,["FOOL"] = 3,["DOLL_REPAIRED"] = 4}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act3" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "mysterious"}, --bgm_mood: stageplay_set/bgm_moods/music_mysterious

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE1},
			{roles = {"BIRD1"},				duration = 2.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE2},

			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE3},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE4},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE5},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE6, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE7, sgparam="mysterious"},

			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE29},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE8},
			{roles = {"KING"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE9},

			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE10},
			{roles = {"FOOL"},				duration = 5.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE11, anim="emoteXL_loop_dance8"},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE12, anim="emote_hands"},

			{roles = {"KING"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE19, anim="death2", animtype="hold"},

			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE13, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE14},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE15},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE16},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE17},
			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE18, sgparam="mysterious"},

			{actionfn = fn.findpositions,	duration = 0.1,		positions={["FOOL"] = 1}},
			{roles = {"FOOL"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE20},

			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE21},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE22},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE23},

			{actionfn = fn.findpositions,	duration = 0.5,		positions={["FOOL"] = 3}},
			{actionfn = fn.findpositions,	duration = 1,		positions={["DOLL_REPAIRED"] = 6}},

			{actionfn = fn.stinger,			duration = 0.1,		sound="stageplay_set/statue_lyre/stinger_dramatic" },
			{actionfn = fn.swapmask,		duration = 0.1,		roles = {"DOLL_REPAIRED"}, mask = "mask_queenhat", body = "costume_queen_body"},
			{roles = {"DOLL_REPAIRED"},		duration = 3.0,		anim ="emote_happycheer"},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE24},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE25, sgparam="disappointed"},
			{roles = {"BIRD1","BIRD2"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE26, sgparam="laugh"},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE27, sgparam="excited",	treetest= true},
			{actionfn = fn.stopbgmusic,		duration = 0.1, },
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE8.LINE28, treetest= true},
			{roles = {"KING"},				duration = 1.5,		anim="corpse_revive"},

			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}

	scripts["ACT3_SCENE9"]= {
		cast = { "MIRROR", "QUEEN"},
		playbill = STRINGS.PLAYS.THE_ENCHANTED_DOLL[9],
		next = "ACT1_SCENE1",
		lines = {
			{actionfn = fn.findpositions,	duration = 1,		positions={["MIRROR"] = 2,["QUEEN"] = 3}},
			{actionfn = fn.stageon,			duration = 1.5, },
			{actionfn = fn.stinger,			duration = 0.01,	sound = "stageplay_set/statue_lyre/stinger_intro_act3" },
			{actionfn = fn.marionetteon,	duration = 0.2,		time = MARIONETTE_TIME},
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.callbirds,		duration = 2, },
			{actionfn = fn.startbgmusic,	duration = 0.2,		musictype = "drama"}, --bgm_mood: stageplay_set/bgm_moods/music_drama

			{roles = {"BIRD2"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE1},
			{roles = {"BIRD1"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE2},
			{roles = {"BIRD1","BIRD2"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE3},

			{roles = {"QUEEN"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE4},
			{roles = {"QUEEN"},				duration = 3.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE5},
			{roles = {"QUEEN"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE6},

			{roles = {"MIRROR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE7},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE8},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE9},
			{roles = {"MIRROR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE10},

			{roles = {"QUEEN"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE11},
			{roles = {"QUEEN"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE12},
			{roles = {"QUEEN"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE13},
			{roles = {"QUEEN"},				duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE14},

			{roles = {"NARRATOR"},			duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE15},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE16},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE17},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE18, sgparam="upbeat"},
			{roles = {"NARRATOR"},			duration = 3.0,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE19, sgparam="mysterious"},
			{roles = {"NARRATOR"},			duration = 4.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE20, sgparam="upbeat"},

			{roles = {"MIRROR"},			duration = 0.3,		anim={"bow_pre","bow_pst"}},
			{roles = {"QUEEN"},				duration = 2.5,		anim="emoteXL_kiss"},

			{roles = {"BIRD2"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE21},
			{roles = {"BIRD1"},				duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE22,sgparam="disappointed"},
			{actionfn = fn.stopbgmusic,		duration = 0.1, },
			{roles = {"BIRD1","BIRD2"},		duration = 2.5,		line = STRINGS.STAGEACTOR.ACT3_SCENE9.LINE23,sgparam="laugh"},
							
			{actionfn = fn.actorsbow,		duration = 1, },
			{actionfn = fn.stinger,			duration = 2.5,		sound = "stageplay_set/statue_lyre/stinger_outro" },
			{actionfn = fn.marionetteoff,	duration = 1,		time = MARIONETTE_TIME},
			{actionfn = fn.stageoff,		duration = 0.3, },
			{actionfn = fn.exitbirds,		duration = 0.3, },
		}}
 

return {costumes=costumes, scripts=scripts, starting_act=starting_act}