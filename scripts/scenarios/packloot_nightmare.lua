chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)
    local loot =
    {
        {
            item = "cutgrass",
            count = math.random(3, 30),
        },
        {
            item = "log",
            count = math.random(3, 30),
        },
        {
            item = "minerhat_blueprint",
        },
    }

    local chanceloot =
    {
        --set1
        {
            {
                item = "gunpowder",
                count = math.random(3, 5),
            },
            {
                item = "firestaff",
            },
        },

        --set2
        {
            item = "fishingrod_blueprint",
        },
    }

    chestfunctions.AddChestItems(inst, loot)
    chestfunctions.AddChestItems(inst, chanceloot[math.random(#chanceloot)])
end

return
{
    OnCreate = OnCreate,
}
