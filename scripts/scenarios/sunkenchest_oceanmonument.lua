local chestfunctions = require("scenarios/chestfunctions")

---------------------------------------------------------------------------------------------------------

local function GetRandomAmount5to8()
    return math.random(5, 8)
end

local function GetRandomAmount2to3()
    return math.random(2, 3)
end

local function InitFn(item)
    if item.components.fueled ~= nil then
        item.components.fueled:SetPercent(GetRandomMinMax(.9, 1))

    elseif item.components.finiteuses ~= nil then
        item.components.finiteuses:SetUses(math.ceil(GetRandomMinMax(.8, 1) * item.components.finiteuses.total))
    end
end

local GEMS = {
    "purplegem",
    "bluegem",
    "redgem",
    "orangegem",
    "yellowgem",
    "greengem",
}

local LOOT =
{
    {
        item = { "thulecite", "wall_ruins_item" },
        count = GetRandomAmount5to8,
    },
    {
        item = { "orangeamulet", "yellowamulet", "greenamulet" },
        count = 1,
        chance = 0.85,
        initfn = InitFn,
    },
    {
        item = { "orangestaff", "yellowstaff", "greenstaff" },
        count = 1,
        chance = 0.85,
        initfn = InitFn,
    },
    {
        item = { "multitool_axe_pickaxe", "nutrientsgoggleshat", "eyeturret_item" },
        count = 1,
        chance = 0.85,
        initfn = InitFn,
    },
    {
        item = { "ruinshat", "armorruins", "ruins_bat" },
        count = 1,
        chance = 0.85,
        initfn = InitFn,
    },
    {
        item = GEMS,
        count = GetRandomAmount2to3,
    },
    {
        item = GEMS,
        count = GetRandomAmount2to3,
    },
    {
        item = GEMS,
        count = GetRandomAmount2to3,
        chance = .66,
    },
    {
        item = "ancienttree_seed",
        count = 1,
        chance = .1,
    },
    {
        item = "trinket_4",
        count = 1,
        chance = .5,
    },
}

---------------------------------------------------------------------------------------------------------

local function OnCreate(inst, scenariorunner)
    chestfunctions.AddChestItems(inst, LOOT)
end

---------------------------------------------------------------------------------------------------------

return
{
    OnCreate  = OnCreate,
}
