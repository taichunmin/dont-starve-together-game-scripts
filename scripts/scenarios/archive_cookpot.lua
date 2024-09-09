chestfunctions = require("scenarios/chestfunctions")
chest_openfunctions = require("scenarios/chest_openfunctions")

local function OnCreate(inst, scenariorunner)

	local items =
	{
		{
			item = "refined_dust",
			chance = 1,
		},
	}

	chestfunctions.AddChestItems(inst, items)
end

return
{
    OnCreate = OnCreate,

}
