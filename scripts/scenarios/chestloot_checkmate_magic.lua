chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)
    local loot =
    {
        {
            item = "livinglog",
            count = math.random(5, 10),
        },
        {
            item = "nightmarefuel",
            count = math.random(5, 10),
        },
        {
            item = "redgem",
            count = math.random(5, 10),
        },
        {
            item = "bluegem",
            count = math.random(5, 10),
        },
        {
            item = "purplegem",
            count = math.random(5, 10),
        },
    }

    chestfunctions.AddChestItems(inst, loot)
end

return
{
    OnCreate = OnCreate,
}
