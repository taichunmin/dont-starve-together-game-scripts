chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "cutstone",
        count = 3,
    },
    {
        item = "goldenshovel",
        count = 1,
    },
    {
        item = "froglegs",
        count = 3,
    },
}

local function settarget(inst, player)
    if inst and inst.brain then
        inst.brain.followtarget = player
    end
end

local function triggertrap(inst, scenariorunner, data)
    --spawn ghosts in a circle around you
    local x, y, z = inst.Transform:GetWorldPosition()
    local theta = math.random() * 2 * PI
    local radius = 10
    local steps = 12
    local map = TheWorld.Map
    local player = data.player

    -- Walk the circle trying to find a valid spawn point
    for i = 1, steps do
        local x1 = x + radius * math.cos(theta)
        local z1 = z - radius * math.sin(theta)

        if map:IsPassableAtPoint(x1, 0, z1) then
            local ghost = SpawnPrefab("ghost")
            ghost.Transform:SetPosition(x1, 0, z1)
            ghost:DoTaskInTime(1, settarget, player)
        end
        theta = theta - (2 * PI / steps)
    end

    if player ~= nil and player.components.sanity ~= nil then
        player.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    end
    TheWorld:PushEvent("ms_forceprecipitation", true)
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
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
    OnDestroy = OnDestroy,
}
