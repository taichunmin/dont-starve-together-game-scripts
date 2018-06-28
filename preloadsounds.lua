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
	"frog.fsb",
	"ghost.fsb",
	"gramaphone.fsb",
	"hound.fsb",
	"koalefant.fsb",
	"krampus.fsb",
    "lava_arena.fsb",
    "quagmire.fsb",
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
	"wendy.fsb",
	"wickerbottom.fsb",
	"willow.fsb",
	"wilson.fsb",
	"wilton.fsb",
	"winnie.fsb",
	"winona.fsb",
	"wolfgang.fsb",
	"woodie.fsb",
	"woodrow.fsb",
	"worm.fsb",
	"wx78.fsb",
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
