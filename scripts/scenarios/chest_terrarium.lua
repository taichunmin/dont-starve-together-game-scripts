chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)

	local items =
	{
		{
			item = "terrarium",
		},
		{
			--Weapon Items
			item = {"spear", "blowdart_pipe", "boomerang", "fireflies", "razor", "grass_umbrella", "papyrus", },
		},
		{
			item = "gunpowder",
			count = math.random(1, 3),
			chance = 1/3,
		},
		{
			item = {"cutstone", "marble" },
			count = math.random(3, 5),
			chance = 1/3,
		},
		{
			item = "rope",
			count = math.random(1, 2),
			chance = 1/2,
		},
		{
			item = "healingsalve",
			count = math.random(2, 4),
			chance = 1/2,
		},
		{
			item = {"torch", "messagebottleempty" },
			chance = 1/2,
		},
		{
			item = "goldnugget",
			count = math.random(2, 5),
			chance = 1/2,
		},
		{
			item = "log",
			count = math.random(6, 15),
			chance = 1/2,
		},

	}
	chestfunctions.AddChestItems(inst, items)

end

local function OnLoad(inst, scenariorunner)
	-- dummy function so the component doesnt get removed right away so that the terrariumchest_fx can test if they should be created or not
    chestfunctions.InitializeChestTrap(inst, scenariorunner, function() end, 0.0)
end

return
{
	OnLoad = OnLoad,
	OnCreate = OnCreate,
}
