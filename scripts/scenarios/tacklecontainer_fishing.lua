local chestfunctions = require("scenarios/chestfunctions")

---------------------------------------------------------------------------------------------------------

local function GetRandomAmount1to2()
    return math.random(1, 2)
end

local function GetRandomAmount0to4()
    return math.random(0, 4)
end

local BOBBERS = {
    "oceanfishingbobber_ball",
    "oceanfishingbobber_oval",
    "oceanfishingbobber_crow",
    "oceanfishingbobber_robin",
    "oceanfishingbobber_robin_winter",
    "oceanfishingbobber_canary",
    "oceanfishingbobber_goose",
    "oceanfishingbobber_malbatross",
}

local LURES = {
    "oceanfishinglure_spoon_red",
    "oceanfishinglure_spoon_green",
    "oceanfishinglure_spoon_blue",
    "oceanfishinglure_spinner_red",
    "oceanfishinglure_spinner_green",
    "oceanfishinglure_spinner_blue",
    "oceanfishinglure_hermit_rain",
    "oceanfishinglure_hermit_snow",
    "oceanfishinglure_hermit_drowsy",
    "oceanfishinglure_hermit_heavy",
}

local LOOT =
{
    {
        item = BOBBERS,
        count = GetRandomAmount0to4,
    },
    {
        item = LURES,
        count = GetRandomAmount1to2,
    },
    {
        item = BOBBERS,
        count = GetRandomAmount1to2,
    },
    {
        item = LURES,
        count = GetRandomAmount0to4,
    },
    {
        item = BOBBERS,
        count = GetRandomAmount1to2,
    },
}

---------------------------------------------------------------------------------------------------------

local function OnCreate(inst, scenariorunner)
    chestfunctions.AddChestItems(inst, LOOT)
end

---------------------------------------------------------------------------------------------------------

return
{
    OnCreate  = OnCreate,
}
