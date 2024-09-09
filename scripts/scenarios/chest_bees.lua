chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "honey",
        count = 6
    },
    {
        item = "honeycomb",
        count = 6
    },
    {
        item = "stinger",
        count = 5
    },
}

local function triggertrap(inst, scenariorunner)
    --spawn in loot
    chestfunctions.AddChestItems(inst, loot)
    --release all bees
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
end

local function OnIsDay(inst, isday)
    if inst.components.childspawner then
        if not isday then
            inst.components.childspawner:StopSpawning()
        elseif not TheWorld.state.iswinter then
            inst.components.childspawner:StartSpawning()
        end
    end
end

local function OnLoad(inst, scenariorunner)
    --listen for on open.
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "bee"
    inst.components.childspawner:SetRegenPeriod(TUNING.BEEHIVE_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.BEEHIVE_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.BEEHIVE_BEES)
    if not TheWorld.state.iswinter then
        inst.components.childspawner:StartSpawning()
    end

    inst:WatchWorldState("isday", OnIsDay)

    chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap)
end

local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end

return
{
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}
