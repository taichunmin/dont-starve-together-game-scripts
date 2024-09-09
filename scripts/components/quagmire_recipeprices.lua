--------------------------------------------------------------------------
--[[ QuagmireRecipePrices class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local CRAVING_NAMES =
{
    "snack",
    "soup",
    "veggie",
    "fish",
    "bread",
    "meat",
    "cheese",
    "pasta",
    "sweet",
}
local CRAVING_IDS = table.invert(CRAVING_NAMES)

local DISH_NAMES =
{
    "plate",
    "bowl",
}
local DISH_IDS = table.invert(DISH_NAMES)

local NUM_COIN_TYPES = 4
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
local _recipename = net_string(inst.GUID, "quagmire_recipeprices._recipename", "recipedirty")
local _klumpkey = net_string(inst.GUID, "quagmire_recipeprices._klumpkey")
local _dish = net_tinybyte(inst.GUID, "quagmire_recipeprices._dish")
local _silverdish = net_bool(inst.GUID, "quagmire_recipeprices._silverdish")
local _maxvalue = net_bool(inst.GUID, "quagmire_recipeprices._maxvalue")
local _matchedcraving = net_smallbyte(inst.GUID, "quagmire_recipeprices._matchedcraving")
local _snackpenalty = net_bool(inst.GUID, "quagmire_recipeprices._snackpenalty")
local _coins = {}
for i = 1, NUM_COIN_TYPES do
    table.insert(_coins, net_smallbyte(inst.GUID, "quagmire_recipeprices._coins["..tostring(i).."]"))
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
        print("Appraised: ".._recipename:value()..(_snackpenalty:value() and " (snack penalty)" or ""))

        if QUAGMIRE_USE_KLUMP then
            if _klumpkey:value():len() > 0 then
                LoadKlumpFile("images/quagmire_food_inv_images_".._recipename:value()..".tex", _klumpkey:value())
                LoadKlumpFile("images/quagmire_food_inv_images_hires_".._recipename:value()..".tex", _klumpkey:value())
                LoadKlumpFile("anim/dynamic/".._recipename:value()..".dyn", _klumpkey:value())
                LoadKlumpString("STRINGS.NAMES."..string.upper(_recipename:value()), _klumpkey:value())
            end
        end

        local matchedcraving = CRAVING_NAMES[_matchedcraving:value()]
        if matchedcraving ~= nil then
            print("Satisfied: "..matchedcraving.." craving")
        end
        local str = "    Value: "
        local coins = {}
        for i, v in ipairs(_coins) do
            if i > 1 then
                str = str..", "
            end
            str = str..tostring(v:value())
            table.insert(coins, v:value())
        end
        if not _ismastersim then
            _task = inst:DoTaskInTime(QUEUE_DELAY, ClearRecipe)
        end
        str = str.." (silver="..tostring(_silverdish:value()).." max="..tostring(_maxvalue:value())..")"
        print(str)
        TheWorld:PushEvent("quagmire_recipeappraised", {
            product = _recipename:value(),
            dish = DISH_NAMES[_dish:value()],
            silverdish = _silverdish:value(),
            maxvalue = _maxvalue:value(),
            matchedcraving = matchedcraving,
            snackpenalty = _snackpenalty:value(),
            coins = coins,
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
        _silverdish:set(record.silverdish == true)
        _maxvalue:set(record.maxvalue == true)
        _matchedcraving:set(record.matchedcraving or 0)
        _snackpenalty:set(record.snackpenalty == true)
        for i, v in ipairs(_coins) do
            v:set(record.coins[i] or 0)
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

local OnRecipeAppraised = _ismastersim and function(src, data)
    local coins = {}
    for i = 1, NUM_COIN_TYPES do
        table.insert(coins, data.coins[i] or 0)
    end
    table.insert(_queue, {
        product = data.product,
        dish = DISH_IDS[data.dish or ""],
        silverdish = data.silverdish,
        maxvalue = data.maxvalue,
        matchedcraving = CRAVING_IDS[data.matchedcraving or ""],
        snackpenalty = data.snackpenalty,
        coins = coins,
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
_silverdish:set(false)
_maxvalue:set(true)
_matchedcraving:set(0)
_snackpenalty:set(false)
for i, v in ipairs(_coins) do
    v:set(0)
end

if _ismastersim then
    --Initialize master simulation variables
    _queue = {}
    _secrets = event_server_data("quagmire", "klump_secrets")

    --Register master simulation events
    inst:ListenForEvent("ms_quagmirerecipeappraised", OnRecipeAppraised, TheWorld)
else
    --Register network variable sync events
    inst:ListenForEvent("recipedirty", OnRecipeDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
