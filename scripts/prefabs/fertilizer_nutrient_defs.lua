local FERTILIZER_DEFS = {}

FERTILIZER_DEFS.poop = {nutrients = TUNING.POOP_NUTRIENTS}
FERTILIZER_DEFS.fertilizer = {nutrients = TUNING.FERTILIZER_NUTRIENTS, uses = TUNING.FERTILIZER_USES}
FERTILIZER_DEFS.guano = {nutrients = TUNING.GUANO_NUTRIENTS}
FERTILIZER_DEFS.compost = {nutrients = TUNING.COMPOST_NUTRIENTS}
FERTILIZER_DEFS.soil_amender_low = {nutrients = TUNING.SOILAMENDER_NUTRIENTS_LOW}
FERTILIZER_DEFS.soil_amender_med = {nutrients = TUNING.SOILAMENDER_NUTRIENTS_MED}
FERTILIZER_DEFS.soil_amender_high = {nutrients = TUNING.SOILAMENDER_NUTRIENTS_HIGH}
FERTILIZER_DEFS.soil_amender_fermented = {nutrients = TUNING.SOILAMENDER_NUTRIENTS_HIGH, uses = TUNING.SOILAMENDER_FERMENTED_USES}
FERTILIZER_DEFS.spoiled_food = {nutrients = TUNING.SPOILED_FOOD_NUTRIENTS}
FERTILIZER_DEFS.spoiled_fish = {nutrients = TUNING.SPOILED_FISH_NUTRIENTS}
FERTILIZER_DEFS.spoiled_fish_small = {nutrients = TUNING.SPOILED_FISH_SMALL_NUTRIENTS}
FERTILIZER_DEFS.rottenegg = {nutrients = TUNING.ROTTENEGG_NUTRIENTS}

FERTILIZER_DEFS.compostwrap = {nutrients = TUNING.COMPOSTWRAP_NUTRIENTS}
FERTILIZER_DEFS.glommerfuel = {nutrients = TUNING.GLOMMERFUEL_NUTRIENTS}
FERTILIZER_DEFS.treegrowthsolution = {nutrients = TUNING.TREEGROWTH_NUTRIENTS}

FERTILIZER_DEFS.mosquitofertilizer = {nutrients = TUNING.MOSQUITOFERTILIZER_NUTRIENTS}

FERTILIZER_DEFS.soil_amender_low.inventoryimage = "soil_amender.tex"
FERTILIZER_DEFS.soil_amender_med.inventoryimage = "soil_amender_stale.tex"
FERTILIZER_DEFS.soil_amender_high.inventoryimage = "soil_amender_spoiled.tex"

FERTILIZER_DEFS.soil_amender_low.name = "SOIL_AMENDER_FRESH"
FERTILIZER_DEFS.soil_amender_med.name = "SOIL_AMENDER_STALE"
FERTILIZER_DEFS.soil_amender_high.name = "SOIL_AMENDER_SPOILED"

for fertilizer, data in pairs(FERTILIZER_DEFS) do
    if data.inventoryimage == nil then
        data.inventoryimage = fertilizer..".tex"
    end

    if data.name == nil then
        data.name = string.upper(fertilizer)
    end

    if data.uses == nil then
        data.uses  = 1
    end
end

setmetatable(FERTILIZER_DEFS, {
	__newindex = function(t, k, v)
		v.modded = true
		rawset(t, k, v)
	end,
})

local sort_order =
{
	"spoiled_fish_small",
	"spoiled_fish",
	"soil_amender_low",
	"soil_amender_med",
	"soil_amender_high",
	"soil_amender_fermented",

	"spoiled_food",
	"rottenegg",
	"compost",
	"compostwrap",

	"poop",
	"guano",
	"fertilizer",

	"glommerfuel",
	"treegrowthsolution",

	"mosquitofertilizer",
}


return {FERTILIZER_DEFS = FERTILIZER_DEFS, SORTED_FERTILIZERS = sort_order}