--------------------------------------------------------------------------
--[[ QuagmireRecipeBook class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local INGREDIENT_NAMES =
{
    "quagmire_turnip_cooked",
    "quagmire_onion_cooked",
    "quagmire_carrot_cooked",
    "quagmire_potato_cooked",
    "quagmire_tomato_cooked",

    "quagmire_garlic_cooked",
    "quagmire_spotspice_ground",
    "quagmire_flour",

    "quagmire_foliage_cooked",
    "quagmire_mushrooms_cooked",
    "berries_cooked",

    "quagmire_cookedsmallmeat",
    "cookedmeat",
    "quagmire_salmon_cooked",
    "quagmire_crabmeat_cooked",

    "quagmire_goatmilk",
    "quagmire_syrup",
    "quagmire_sap",

    "rocks",
    "twigs",
}
local INGREDIENT_IDS = table.invert(INGREDIENT_NAMES)

local DISH_NAMES =
{
    "plate",
    "bowl",
}
local DISH_IDS = table.invert(DISH_NAMES)

local STATION_NAMES =
{
    "pot",
    "oven",
    "grill",
}
local STATION_IDS = table.invert(STATION_NAMES)

local MAX_INGREDIENTS = 4
local QUEUE_DELAY = 3

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _task = nil

--Master simulation
local _queue
local _secrets

--Network
local _recipename = net_string(inst.GUID, "quagmire_recipebook._recipename", "recipedirty")
local _klumpkey = net_string(inst.GUID, "quagmire_recipebook._klumpkey")
local _dish = net_tinybyte(inst.GUID, "quagmire_recipebook._dish")
local _station = net_tinybyte(inst.GUID, "quagmire_recipebook._station")
local _overcooked = net_bool(inst.GUID, "quagmire_recipebook._overcooked")
local _ingredients = {}
for i = 1, MAX_INGREDIENTS do
    table.insert(_ingredients, net_smallbyte(inst.GUID, "quagmire_recipebook._ingredients["..tostring(i).."]"))
end

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local ClearRecipe = not _ismastersim and function()
    _task = nil
    _recipename:set_local("")
end or nil

local function OnRecipeDirty()
    if not _ismastersim and _task ~= nil then
        _task:Cancel()
        _task = nil
    end
    if _recipename:value():len() > 0 then
        local station = STATION_NAMES[_station:value()]
        print("Discovered "..station.." recipe: ".._recipename:value())

        if QUAGMIRE_USE_KLUMP then
            if _klumpkey:value():len() > 0 then
                LoadKlumpFile("images/quagmire_food_inv_images_".._recipename:value()..".tex", _klumpkey:value())
                LoadKlumpFile("images/quagmire_food_inv_images_hires_".._recipename:value()..".tex", _klumpkey:value())
                LoadKlumpFile("anim/dynamic/".._recipename:value()..".dyn", _klumpkey:value())
                LoadKlumpString("STRINGS.NAMES."..string.upper(_recipename:value()), _klumpkey:value())
            end
        end

        local ingredients = {}
        for i, v in ipairs(_ingredients) do
            local ingredient = INGREDIENT_NAMES[v:value()]
            if ingredient ~= nil then
                print((i == 1 and "      Ingredients: " or "                   ")..ingredient)
                table.insert(ingredients, ingredient)
            end
        end
        if not _ismastersim then
            _task = inst:DoTaskInTime(QUEUE_DELAY, ClearRecipe)
        end
        TheWorld:PushEvent("quagmire_recipediscovered", {
            product = _recipename:value(),
            dish = DISH_NAMES[_dish:value()],
            station = station,
            overcooked = _overcooked:value(),
            ingredients = ingredients,
        })
    end
end

local ProcessQueue
if _ismastersim then ProcessQueue = function()
    if #_queue > 0 then
        local record = table.remove(_queue, 1)
        _recipename:set_local(record.product)
        _recipename:set(record.product)
        _klumpkey:set((_secrets[record.product] or {}).cipher or "")
        _dish:set(record.dish or 0)
        _station:set(record.station or 0)
        _overcooked:set(record.overcooked == true)
        for i, v in ipairs(_ingredients) do
            v:set(record.ingredients[i] or 0)
        end
        _task = inst:DoTaskInTime(QUEUE_DELAY, ProcessQueue)
        OnRecipeDirty()
    else
        _recipename:set_local("")
        _task = nil
    end
end end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local OnRecipeDiscovered = _ismastersim and function(src, data)
    local ingredientids = {}
    if data.recipe.ingredients ~= nil then
        for i, v in ipairs(data.recipe.ingredients) do
            table.insert(ingredientids, INGREDIENT_IDS[v])
        end
    end
    table.insert(_queue, {
        product = tostring(data.recipe.product),
        dish = DISH_IDS[data.recipe.dish or ""],
        station = STATION_IDS[data.recipe.station],
        overcooked = data.recipe.overcooked,
        ingredients = ingredientids,
    })
    if _task == nil then
        ProcessQueue()
    end
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_recipename:set("")
_klumpkey:set("")
_dish:set(0)
_station:set(0)
_overcooked:set(false)
for i, v in ipairs(_ingredients) do
    v:set(0)
end

if _ismastersim then
    --Initialize master simulation variables
    _queue = {}
    _secrets = event_server_data("quagmire", "klump_secrets")

    --Register master simulation events
    inst:ListenForEvent("ms_quagmirerecipediscovered", OnRecipeDiscovered, TheWorld)
else
    --Register network variable sync events
    inst:ListenForEvent("recipedirty", OnRecipeDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
