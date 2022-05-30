chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)
    local loot =
    {
        {
            item = "cutgrass",
            count = math.random(20, 25),
            chance = 0.33,
        },
        {
            item = "log",
            count = math.random(10, 14),
            chance = 0.5,
        },
        {
            item = "heatrock",
        },
    }

    local chanceloot =
    {
        --set1
        {
            {
                item = "flint",
                count = math.random(4, 10),
                chance = 0.66,
            },
            {
                item = "blueprint",
            },
        },

        --set2
        {
            {
                item = "torch",
            },
            {
                item = "twigs",
                count = math.random(20, 25),
                chance = 0.5,
            },
        },

        --set3
        {
            {
                item = "nightmarefuel",
                count = math.random(3, 5),
            },
            {
                item = "redgem",
            },
            {
                item = "blueprint",
            },
        },

        --set4
        {
            {
                item = "nightmarefuel",
                count = math.random(3, 5),
            },
            {
                item = "bluegem",
            },
            {
                item = "blueprint",
            },
        },

        --set5
        {
            {
                item = "livinglog",
                count = math.random(3, 5),
            },
            {
                item = "blueprint",
            },
        },

        --set6
        {
            {
                item = "cutstone",
                count = math.random(4, 8),
            },
            {
                item = "boards",
                count = math.random(4, 8),
            },
            {
                item = "blueprint",
            },
        },

        --set7
        {
            {
                item = "silk",
                count = math.random(5, 10),
            },
            {
                item = "beefalowool",
                count = math.random(5, 10)
            },
            {
                item = "blueprint",
            },
        },

        --set8
        {
            {
                item = "blueprint",
                count = 2,
            },
            {
                item = "blueprint",
                count = 2,
            },
        },
    }

    chestfunctions.AddChestItems(inst, loot)
    chestfunctions.AddChestItems(inst, chanceloot[math.random(#chanceloot)])
end

return
{
    OnCreate = OnCreate,
}
