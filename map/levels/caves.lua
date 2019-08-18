require("map/level")

----------------------------------
-- Cave levels
----------------------------------
local dst_cave = {
	id="DST_CAVE",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE,
	location = "cave",
	version = 4,
	overrides={
	},
	background_node_range = {0,1},
}
if IsConsole() then
	dst_cave.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PS4
end
AddLevel(LEVELTYPE.SURVIVAL, dst_cave)

AddLevel(LEVELTYPE.SURVIVAL, {
        id="DST_CAVE_PLUS",
        name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PLUS,
        desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE_PLUS,
        location = "cave",
        version = 4,

        overrides={
            boons = "often",

            cave_spiders = "often",

            rabbits = "rare",

            berrybush = "rare",
            carrot = "rare",

            flower_cave = "rare",
            wormlights = "rare",
        },
        background_node_range = {0,1},
    })
