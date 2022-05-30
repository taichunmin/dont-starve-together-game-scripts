chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "ice",
        count = 15,
        chance = 0.4
    },
    {
        item = "petals",
        count = 20,
        chance = 0.66
    },
    {
        item = "watermelon",
        count = 1,
        chance = 0.8
    },
}

local function triggertrap(inst, scenariorunner)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/distant")
    TheWorld:PushEvent("ms_setseason", "summer")
    TheWorld:PushEvent("ms_advanceseason")
    TheWorld:PushEvent("ms_advanceseason")
end

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end


local function OnLoad(inst, scenariorunner)
    chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap)
end


local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end


return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}
