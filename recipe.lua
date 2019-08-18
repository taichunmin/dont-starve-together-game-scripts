require "class"
require "util"
local TechTree = require("techtree")

Ingredient = Class(function(self, ingredienttype, amount, atlas, deconstruct, imageoverride)
    --Character ingredient multiples of 5 check only applies to
    --health and sanity cost, not max health or max sanity
    if ingredienttype == CHARACTER_INGREDIENT.HEALTH or
        ingredienttype == CHARACTER_INGREDIENT.SANITY then
        --V2C: string solution due to inconsistent precision errors with math.floor
        --local x = math.floor(amount)
        local x = tostring(amount)
        x = x:sub(x:find("^%-?%d+"))
        x = tonumber(x:sub(x:len()))
        --NOTE: if you changed CHARACTER_INGREDIENT_SEG, then update this assert
        assert(x == 0 or x == 5, "Character ingredients must be multiples of "..tostring(CHARACTER_INGREDIENT_SEG))
    end
    self.type = ingredienttype
    self.amount = amount
    self.atlas = atlas and resolvefilepath(atlas) or nil
    self.image = imageoverride
    self.deconstruct = deconstruct
end)

function Ingredient:GetAtlas()
    if self.atlas == nil then
       self.atlas = resolvefilepath(GetInventoryItemAtlas(self:GetImage()))
    end
    return self.atlas
end

function Ingredient:GetImage()
    if self.image == nil then
        self.image = self.type..".tex"
    end
    return self.image
end

local num = 0
AllRecipes = {}

local is_character_ingredient = nil
function IsCharacterIngredient(ingredienttype)
    if is_character_ingredient == nil then
        is_character_ingredient = {}
        for k, v in pairs(CHARACTER_INGREDIENT) do
            is_character_ingredient[v] = true
        end
    end
    return ingredienttype ~= nil and is_character_ingredient[ingredienttype] == true
end

local is_tech_ingredient = nil
function IsTechIngredient(ingredienttype)
    if is_tech_ingredient == nil then
        is_tech_ingredient = {}
        for k, v in pairs(TECH_INGREDIENT) do
            is_tech_ingredient[v] = true
        end
    end
    return ingredienttype ~= nil and is_tech_ingredient[ingredienttype] == true
end

mod_protect_Recipe = false

Recipe = Class(function(self, name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image, testfn, product, build_mode, build_distance)
    if mod_protect_Recipe then
        print("Warning: Calling Recipe from a mod is now deprecated. Please call AddRecipe from your modmain.lua file.")
    end

    self.name          = name

    self.ingredients   = {}
    self.character_ingredients = {}
    self.tech_ingredients = {}

    for k,v in pairs(ingredients) do
        table.insert(
            (IsCharacterIngredient(v.type) and self.character_ingredients) or
            (IsTechIngredient(v.type) and self.tech_ingredients) or
            self.ingredients,
            v
        )
    end

    self.product       = product or name
    self.tab           = tab

    self.imagefn       = type(image) == "function" and image or nil
    self.image         = self.imagefn == nil and image or (self.product .. ".tex")
    self.atlas         = (atlas and resolvefilepath(atlas))-- or resolvefilepath(GetInventoryItemAtlas(self.image))

    --self.lockedatlas   = (lockedatlas and resolvefilepath(lockedatlas)) or (atlas == nil and resolvefilepath("images/inventoryimages_inverse.xml")) or nil
    --self.lockedimage   = lockedimage or (self.product ..".tex")

    self.sortkey       = num
    self.rpc_id        = num --mods will set the rpc_id in SetModRPCID when called by AddRecipe()
    self.level         = TechTree.Create(level)
    self.placer        = placer
    self.min_spacing   = min_spacing or 3.2

    --V2C: custom test function if default test isn't enough
    self.testfn        = testfn

    self.nounlock      = nounlock or false

    self.numtogive     = numtogive or 1

    self.builder_tag   = builder_tag or nil

    self.build_mode    = build_mode or BUILDMODE.LAND
    self.build_distance= build_distance or 1

    num                = num + 1
    AllRecipes[name]   = self
end)

function Recipe:GetAtlas()
	self.atlas = self.atlas or resolvefilepath(GetInventoryItemAtlas(self.image))
	return self.atlas
end

function Recipe:SetModRPCID()
    local rpc_id = smallhash(self.name)

    for _,v in pairs(AllRecipes) do
        if v.rpc_id == rpc_id then
            print("ERROR:hash collision between recipe names ", self.name, " and ", v.name )
        end
    end
    self.rpc_id = rpc_id
end

function GetValidRecipe(recname)
    if not IsRecipeValidInGameMode(TheNet:GetServerGameMode(), recname) then
        return
    end
    local rec = AllRecipes[recname]
    return rec ~= nil and rec.tab ~= nil and rec or nil
end

function IsRecipeValid(recname)
    return GetValidRecipe(recname) ~= nil
end

function RemoveAllRecipes()
    AllRecipes = {}
    num = 0
end
