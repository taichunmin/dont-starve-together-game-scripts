chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)
    local loot =
    {
        {
            item = "cutgrass",
            count = math.random(20, 25),
        },
        {
            item = "log",
            count = math.random(10, 14),
        },
        {
            item = "rocks",
            count = math.random(9, 13),
        }
    }

    chestfunctions.AddChestItems(inst, loot)
end

return
{
    OnCreate = OnCreate,
}
