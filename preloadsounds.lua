require "dlcsupport"

local DLCSounds =
{
	"amb_stream.fsb",
	"bearger.fsb",
	"buzzard.fsb",
	"catcoon.fsb",
	"deciduous.fsb",
	"DLC_music.fsb",
	"dontstarve_DLC001.fev",
	"dragonfly.fsb",
	"glommer.fsb",
	"goosemoose.fsb",
	"lightninggoat.fsb",
	"mole.fsb",
	"stuff.fsb",
	"vargr.fsb",
	"wathgrithr.fsb",
	"webber.fsb",
}

local MainSounds =
{
	"bat.fsb",
	"bee.fsb",
	"beefalo.fsb",
	"birds.fsb",
	"bunnyman.fsb",
	"cave_AMB.fsb",
	"cave_mem.fsb",
	"chess.fsb",
	"chester.fsb",
	"common.fsb",
	"deerclops.fsb",
	"dontstarve.fev",
	"forest.fsb",
	"forest_stream.fsb",
    "forge2.fsb",
	"frog.fsb",
	"ghost.fsb",
	"gramaphone.fsb",
	"hound.fsb",
	"koalefant.fsb",
	"krampus.fsb",
    "lava_arena.fsb",
	"leif.fsb",
	"mandrake.fsb",
	"maxwell.fsb",
	"mctusky.fsb",
	"merm.fsb",
	"monkey.fsb",
	"music.fsb",
	"pengull.fsb",
	"perd.fsb",
	"pig.fsb",
	"plant.fsb",
    "quagmire.fsb",
	"rabbit.fsb",
	"rocklobster.fsb",
	"sanity.fsb",
	"sfx.fsb",
	"slurper.fsb",
	"slurtle.fsb",
	"spider.fsb",
	"tallbird.fsb",
	"tentacle.fsb",
    "together.fsb",
	"wallace.fsb",
	"turnoftides.fev",
	"turnoftides.fsb",
	"turnoftides_music.fsb",
	"turnoftides_amb.fsb",
	"saltydog.fev",
	"saltydog.fsb",
    "hookline.fev",
    "hookline.fsb",

    "yotc_2020.fev",
    "yotc_2020.fsb",

    "yotb_2021.fev",
    "yotb_2021.fsb",

    "hookline_2.fev",
    "hookline_2.fsb",

    "farming.fev",
    "farming.fsb",

    "dangerous_sea.fev",
    "dangerous_sea.fsb",

    "grotto.fev",
    "grotto_sfx.fsb",
    "grotto_amb.fsb",

    "moonstorm.fev",
    "moonstorm.fsb",

    "warly.fsb",
	"wendy.fsb",
	"wickerbottom.fsb",
	"willow.fsb",
	"wilson.fsb",
	"wilton.fsb",
	"winnie.fsb",
	"winona.fsb",
	"wolfgang.fsb",
    "wortox.fsb",
	"woodie.fsb",
	"woodrow.fsb",
	"worm.fsb",
    "wormwood.fsb",
	"wx78.fsb",
	"wurt.fsb",
	"walter.fsb",
	--"wanda.fsb",

	"wes.fev",
    "wes.fsb",

	"wintersfeast2019.fev",
	"wintersfeast2019.fsb",

	"summerevent.fev",
	"summerevent.fsb",
	"summerevent_music.fsb",

	"webber2.fev",
    "webber2.fsb",

    "webber1.fev",
    "webber1.fsb",	
	
    "waterlogged2.fev",
    "waterlogged2.fsb",
	"waterlogged2_amb.fsb",

	"waterlogged1.fev",
    "waterlogged1.fsb",
	"waterlogged1_amb.fsb",

	"wanda2.fev",
    "wanda2.fsb",	

    "wanda1.fev",
    "wanda1.fsb",

    "terraria1.fev",
    "terraria1.fsb",

    "wolfgang2.fev",
	"wolfgang2.fsb",

	"wolfgang1.fev",
	"wolfgang1.fsb",

	"yotc_2022_2.fev",
    "yotc_2022_2.fsb",

    "ancientguardian_rework.fev",
    "ancientguardian_rework.fsb",

    "WX_rework.fev",
    "WX_rework.fsb",
}

function PreloadSoundList(list)
	for i,v in pairs(list) do
		TheSim:PreloadFile("sound/"..v)
	end
end

function PreloadSounds()
	-- preload DLC sounds
	if IsDLCInstalled(REIGN_OF_GIANTS) then
		PreloadSoundList(DLCSounds)
	end
	PreloadSoundList(MainSounds)

    --NOTE: special event music is specified in constants.lua
    --      but preloadsounds.lua is loaded first, so we only
    --      access the constants within function calls.
    PreloadSoundList({
        (FESTIVAL_EVENT_MUSIC[WORLD_FESTIVAL_EVENT] ~= nil and FESTIVAL_EVENT_MUSIC[WORLD_FESTIVAL_EVENT].bank) or
        (SPECIAL_EVENT_MUSIC[WORLD_SPECIAL_EVENT] ~= nil and SPECIAL_EVENT_MUSIC[WORLD_SPECIAL_EVENT].bank) or
        "music_frontend.fsb",
    })
end
