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

Recipe = Class(function(self, name, ingredients, tab, level, placer_or_more_data, min_spacing, nounlock, numtogive, builder_tag, atlas, image, testfn, product, build_mode, build_distance) -- do not add more params here, add them to "placer_or_more_data"
    if mod_protect_Recipe then
        print("Warning: Calling Recipe from a mod is now deprecated. Please call AddRecipe from your modmain.lua file.")
    end

	local placer = nil
	local more_data = {}
	if type(placer_or_more_data) == "table" then
		placer = placer_or_more_data.placer
		more_data = placer_or_more_data
	else
		placer = placer_or_more_data
	end

    self.name          = name

    self.ingredients   = {}
    self.character_ingredients = {}
    self.tech_ingredients = {}
	self.filter = more_data.filter

    for k,v in pairs(ingredients) do
        table.insert(
            (IsCharacterIngredient(v.type) and self.character_ingredients) or
            (IsTechIngredient(v.type) and self.tech_ingredients) or
            self.ingredients,
            v
        )
    end

    self.product       = product or name
    self.tab           = tab					-- DEPRECATED

	self.description   = more_data.description -- override the description string in the crafting menu

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

    
    self.testfn        = testfn					-- custom placer test function if default test isn't enough
	self.canbuild      = more_data.canbuild		-- custom test function to see if we should be allowed to craft this recipe, return a build action fail message if false

    self.nounlock      = nounlock or false

    self.numtogive     = numtogive or 1

    self.builder_tag   = builder_tag or nil
	self.sg_state      = more_data.sg_state or more_data.buildingstate or nil -- overrides the SG state to use when crafting the item (buildingstate is the old variable name)

    self.build_mode    = build_mode or BUILDMODE.LAND
    self.build_distance= build_distance or 1

    self.no_deconstruction = more_data.no_deconstruction -- function or bool
    self.require_special_event = more_data.require_special_event

	self.dropitem      = more_data.dropitem

	self.actionstr     = more_data.actionstr
	self.hint_msg      = more_data.hint_msg

	self.manufactured = more_data.manufactured -- if true, then it is up to the crafting station to handle creating the item, not the builder component

	self.is_deconstruction_recipe = tab == nil

    num                = num + 1
    AllRecipes[name]   = self

    if ModManager then
        for k,recipepostinit in pairs(ModManager:GetPostInitFns("RecipePostInit")) do
            recipepostinit(self)
        end

        for k,recipepostinitany in pairs(ModManager:GetPostInitFns("RecipePostInitAny")) do
            recipepostinitany(self)
        end
    end
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
    return rec ~= nil and not rec.is_deconstruction_recipe and (rec.require_special_event == nil or IsSpecialEventActive(rec.require_special_event)) and rec or nil
end

function IsRecipeValid(recname)
    return GetValidRecipe(recname) ~= nil
end

function RemoveAllRecipes()
    AllRecipes = {}
    num = 0
end

Recipe2 = Class(Recipe, function(self, name, ingredients, tech, config) -- add new optional params to config
	if config ~= nil then
		Recipe._ctor(self, name, ingredients, nil, tech, config, config.min_spacing, config.nounlock, config.numtogive, config.builder_tag, config.atlas, config.image, config.testfn, config.product, config.build_mode, config.build_distance)
	else
		Recipe._ctor(self, name, ingredients, nil, tech)
	end

	self.is_deconstruction_recipe = false
end)

DeconstructRecipe = Class(Recipe, function(self, name, return_ingredients)
	Recipe._ctor(self, name, return_ingredients, nil, TECH.NONE)
	self.is_deconstruction_recipe = true
	self.nounlock = true
end)
