-- {
-- 	name = "achievement_name"   -- name used in code to refer to this achievement
--	id = id for each particular game service, string name for Steam, integer id specified in .trp file for PSN, etc.
--}

local function ACHIEVEMENT(id, name)
	return { name=name, id={steam = tostring(id).."_"..name, psn = id } }
end

Achievements =
{
	ACHIEVEMENT("1", "survive_20"),
	ACHIEVEMENT("2", "survive_35"),
	ACHIEVEMENT("3", "survive_55"),
	ACHIEVEMENT("4", "survive_70"),
	ACHIEVEMENT("5", "build_researchlab"),
	ACHIEVEMENT("6", "build_researchlab2"),
	ACHIEVEMENT("7", "build_researchlab3"),
	ACHIEVEMENT("8", "build_researchlab4"),
	ACHIEVEMENT("9", "wormhole_used"),
	ACHIEVEMENT("10", "pigking_trader"),
	ACHIEVEMENT("11", "growfrombutterfly"),
	ACHIEVEMENT("12", "honey_harvester"),
	ACHIEVEMENT("13", "sewing_kit"),
	ACHIEVEMENT("14", "pigman_posse"),
	ACHIEVEMENT("15", "rocky_posse"),
	ACHIEVEMENT("16", "hatch_tallbirdegg"),
	ACHIEVEMENT("17", "pacify_forest"),
	ACHIEVEMENT("18", "cave_entrance_opened"),
	ACHIEVEMENT("19", "survive_earthquake"),
	ACHIEVEMENT("20", "tentacle_pillar_hole_used"),
	ACHIEVEMENT("21", "snail_armour_set"),
	ACHIEVEMENT("22", "join_game"),
	ACHIEVEMENT("23", "host_for_days"),
	ACHIEVEMENT("24", "hasrevivedplayer"),
	ACHIEVEMENT("25", "helping_hand"),
	ACHIEVEMENT("26", "party_time"),
	ACHIEVEMENT("27", "equip_skin_clothing"),
	ACHIEVEMENT("28", "trade_inn"),
	ACHIEVEMENT("29", "deerclops_killed"),
	ACHIEVEMENT("30", "spiderqueen_killed"),
	ACHIEVEMENT("31", "minotaur_killed"),
	ACHIEVEMENT("32", "moosegoose_killed"),
	ACHIEVEMENT("33", "bearger_killed"),
	ACHIEVEMENT("34", "dragonfly_killed"),
	ACHIEVEMENT("35", "domesticated_beefalo"),
}

return Achievements

