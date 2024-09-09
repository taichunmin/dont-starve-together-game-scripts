local chestfunctions = require("scenarios/chestfunctions")

---------------------------------------------------------------------------------------------------------

local function GetRandomAmount2to5()
    return math.random(2, 5)
end

local function GetRandomAmount1to3()
    return math.random(1, 3)
end

local function RandomFueledPercent(item)
    item.components.fueled:SetPercent(GetRandomMinMax(.43, .82))
end

local function RandomFiniteusesPercent(item)
    item.components.finiteuses:SetUses(math.ceil(GetRandomMinMax(.4, .8) * item.components.finiteuses.total))
end

local LOOT =
{
    {
        item = "raincoat",
        count = 1,
        chance = 0.33,
        initfn = RandomFueledPercent,
    },
    {
        item = {"goose_feather", "malbatross_feather"},
        count = GetRandomAmount2to5,
        chance = 0.33,
    },
    {
        item = {"driftwood_log", "log"},
        count = GetRandomAmount2to5,
        chance = 0.66,
    },
    {
        item = {"messagebottleempty", "boatpatch"},
        count = GetRandomAmount1to3,
        chance = 0.66,
    },
    {
        item = "messagebottle",
        count = 1,
        chance = 0.33,
    },
    {
        item = {"monkey_mediumhat", "monkey_smallhat"},
        count = 1,
        chance = 0.66,
        initfn = RandomFueledPercent,
    },
    {
        item = "scrapbook_page",
        count = GetRandomAmount1to3,
        chance = 0.66,
    },
    {
        item = {"sewing_kit", "panflute"},
        count = 1,
        chance = 0.66,
        initfn = RandomFiniteusesPercent,
    },
    {
        item = "yellowstaff",
        count = 1,
        chance = 0.66,
        initfn = RandomFiniteusesPercent,
    },
}

---------------------------------------------------------------------------------------------------------

local function SetGhostTarget(inst, player)
    if inst ~= nil and inst.brain ~= nil then
        inst.brain.followtarget = player
    end
end

local function FindNearbySkeleton(platform)
    if platform == nil or not platform:IsValid() then
        return
    end

    local ents = platform.components.walkableplatform:GetEntitiesOnPlatform()

    for ent in pairs(ents) do
        if ent.prefab == "skeleton" then
            return ent
        end
    end
end

local function TriggerTrap(inst, scenariorunner, data)
    local platform = inst:GetCurrentPlatform()
    local skeleton = FindNearbySkeleton(platform)
    local roll = math.random()

    if roll <= 0.33 and data.player ~= nil and TheWorld.components.piratespawner ~= nil then
        TheWorld.components.piratespawner:SpawnPiratesForPlayer(data.player)

    elseif roll <= 0.66 and data.player ~= nil and skeleton ~= nil then
        local x, y, z = skeleton.Transform:GetWorldPosition()

        local ghost = SpawnPrefab("ghost")
        ghost.Transform:SetPosition(x, 0, z)
        ghost:DoTaskInTime(1, SetGhostTarget, data.player)

        if data.player.components.sanity ~= nil then
            data.player.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
        end

        inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")

    else
        if platform ~= nil and platform.components.health ~= nil then
            platform.components.health:Kill()
        end
    end
end

local TRIGGER_TRAP_CHANCE = 0.9

---------------------------------------------------------------------------------------------------------

local function OnCreate(inst, scenariorunner)
    chestfunctions.AddChestItems(inst, LOOT)
end

local function OnLoad(inst, scenariorunner)
    chestfunctions.InitializeChestTrap(inst, scenariorunner, TriggerTrap, TRIGGER_TRAP_CHANCE)
end

---------------------------------------------------------------------------------------------------------

return
{
    OnCreate  = OnCreate,
    OnLoad    = OnLoad,
    OnDestroy = chestfunctions.OnDestroy,
}
