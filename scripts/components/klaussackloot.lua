local giant_loot1 =
{
    "deerclops_eyeball",
    "dragon_scales",
    "hivehat",
    "shroom_skin",
    "mandrake",
}

local giant_loot2 =
{
    "dragonflyfurnace_blueprint",
    "red_mushroomhat_blueprint",
    "green_mushroomhat_blueprint",
    "blue_mushroomhat_blueprint",
    "mushroom_light2_blueprint",
    "mushroom_light_blueprint",
    "townportal_blueprint",
    "bundlewrap_blueprint",
	"trident_blueprint",
}

local giant_loot3 =
{
    "bearger_fur",
    "royal_jelly",
    "goose_feather",
    "lavae_egg",
    "spiderhat",
    "steelwool",
    "townportaltalisman",
	"malbatross_beak",
	"tallbirdegg",
}

function AddGiantLootPrefabs(prefabs)
    for i, v in ipairs(giant_loot1) do
        table.insert(prefabs, v)
    end

    for i, v in ipairs(giant_loot2) do
        table.insert(prefabs, v)
    end

    for i, v in ipairs(giant_loot3) do
        table.insert(prefabs, v)
    end
end

local KlausSackLoot = Class(function(self, inst)
    self.inst = inst

    self:RollKlausLoot()
end)

local boss_ornaments =
{
    "winter_ornament_boss_klaus",
    "winter_ornament_boss_noeyeblue",
    "winter_ornament_boss_noeyered",
    "winter_ornament_boss_krampus",
}

local function FillItems(items, prefab)
    for i = 1 + #items, math.random(3, 4) do
        table.insert(items, prefab)
    end
end

function KlausSackLoot:RollKlausLoot()
    --WINTERS FEAST--
    self.wintersfeast_loot = {}

    local rnd = math.random(3)
    local items = {
        boss_ornaments[math.random(#boss_ornaments)],
        GetRandomFancyWinterOrnament(),
        GetRandomLightWinterOrnament(),
        ((rnd == 1 and GetRandomLightWinterOrnament()) or (rnd == 2 and GetRandomFancyWinterOrnament()) or GetRandomBasicWinterOrnament()),
    }
    table.insert(self.wintersfeast_loot, items)

    items = {
        "goatmilk",
        "goatmilk",
        {"winter_food"..tostring(math.random(2)), 4},
    }
    table.insert(self.wintersfeast_loot, items)

    --WINTERS FEAST--
    self.loot = {}

    items = {}
    table.insert(items, "amulet")
    table.insert(items, "goldnugget")
    FillItems(items, "charcoal")
    table.insert(self.loot, items)

    items = {}
    if math.random() < .5 then
        table.insert(items, "amulet")
    end
    table.insert(items, "goldnugget")
    FillItems(items, "charcoal")
    table.insert(self.loot, items)

    items = {}
    if math.random() < .1 then
        table.insert(items, "krampus_sack")
    end
    table.insert(items, "goldnugget")
    FillItems(items, "charcoal")
    table.insert(self.loot, items)

    items = {}
    local i1 = math.random(#giant_loot3)
    local i2 = math.random(#giant_loot3 - 1)
    table.insert(items, giant_loot1[math.random(#giant_loot1)])
    if math.random() < .5 then
        table.insert(items, giant_loot2[math.random(#giant_loot2)])
    end
    table.insert(items, giant_loot3[i1])
    table.insert(items, giant_loot3[i2 == i1 and #giant_loot3 or i2])
    table.insert(self.loot, items)
end

function KlausSackLoot:GetLoot()
    local loot = {}
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        for i, v in ipairs(self.wintersfeast_loot) do
            table.insert(loot, v)
        end
    end

    for i, v in ipairs(self.loot) do
        table.insert(loot, v)
    end

    self:RollKlausLoot()

    return loot
end

function KlausSackLoot:OnSave()
    return
    {
        wintersfeast_loot = self.wintersfeast_loot,
        loot = self.loot,
    }
end

function KlausSackLoot:OnLoad(data)
	if data ~= nil then
        self.wintersfeast_loot = data.wintersfeast_loot
        self.loot = data.loot
	end
end

return KlausSackLoot