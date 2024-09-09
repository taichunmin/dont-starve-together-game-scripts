chestfunctions = require("scenarios/chestfunctions")
local loot =
{
    {
        item = "green_cap",
        count = 7,
    },
    {
        item = "nightsword",
        --initfn = function(inst) inst.components.finiteuses:SetUses(TUNING.NIGHTSWORD_USES*math.random()) end,
        count = 1,
    },
    {
        item = "nightmarefuel",
        count = 3,
    },
}

local function triggertrap(inst, scenariorunner, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local theta = math.random() * TWOPI
    local radius = 10
    local steps = 32
    local ground = TheWorld
    local player = data.player

    chestfunctions.AddChestItems(inst, loot)

    local function spawnrock(rock)
        rock:Show()
        if player ~= nil and player.components.sanity ~= nil and player.components.sanity:IsSane() then
            rock.AnimState:PlayAnimation("raise")
            rock.AnimState:PushAnimation("idle_active", true)
        else
            rock.AnimState:PlayAnimation("lower")
            rock.AnimState:PushAnimation("idle_inactive", true)

        end
        SpawnPrefab("sanity_raise").Transform:SetPosition(rock.Transform:GetWorldPosition())
    end

    -- Walk the circle trying to find a valid spawn point
    local step_decrement = (TWOPI / steps)
    for i = 1, steps do
        local x1 = x + radius * math.cos(theta)
        local z1 = z - radius * math.sin(theta)

        if ground.Map and not TileGroupManager:IsImpassableTile(ground.Map:GetTileAtPoint(x1, 0, z1)) then
            local rock = SpawnPrefab("sanityrock")
            rock.Transform:SetPosition(x1, 0, z1)
            rock:Hide()
            rock:DoTaskInTime(.05 * i, spawnrock)
        end
        theta = theta - step_decrement
    end
end

local function OnCreate(inst, scenariorunner)
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
