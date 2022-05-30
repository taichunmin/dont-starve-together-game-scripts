local TechTree = {}

local AVAILABLE_TECH =
{
    "SCIENCE",
    "MAGIC",
    "ANCIENT",
    "CELESTIAL",
	"MOON_ALTAR", -- deprecated, all recipes have been moved into CELESTIAL
    "SHADOW",
    "CARTOGRAPHY",
	"SEAFARING",
    "SCULPTING",
    "ORPHANAGE", --teehee
    "PERDOFFERING",
    "WARGOFFERING",
    "PIGOFFERING",
    "CARRATOFFERING",
    "BEEFOFFERING",
	"CATCOONOFFERING",
	"MADSCIENCE",
	"CARNIVAL_PRIZESHOP",
	"CARNIVAL_HOSTSHOP",
    "FOODPROCESSING",
	"FISHING",
	"WINTERSFEASTCOOKING",
    "HERMITCRABSHOP",
    "TURFCRAFTING",
	"MASHTURFCRAFTING",
    "SPIDERCRAFT",
    "ROBOTMODULECRAFT",
}

-- only these tech trees can have tech bonuses added to them
local BONUS_TECH =
{
    "SCIENCE",
    "MAGIC",
	"SEAFARING",
    "ANCIENT",
	"MASHTURFCRAFTING",
}

local function Create(t)
    t = t or {}
    for i, v in ipairs(AVAILABLE_TECH) do
        t[v] = t[v] or 0
    end
    return t
end

return
{
    AVAILABLE_TECH = AVAILABLE_TECH,
	BONUS_TECH = BONUS_TECH,
    Create = Create,
}
