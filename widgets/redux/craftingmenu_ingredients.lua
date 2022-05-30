
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local TEMPLATES = require "widgets/redux/templates"

local IngredientUI = require "widgets/ingredientui"

require("util")

local INGREDIENTS_SCALE = 0.75

-------------------------------------------------------------------------------------------------------
local CraftingMenuIngredients = Class(Widget, function(self, owner, max_ingredients_wide, recipe, extra_quantity_scale)
    Widget._ctor(self, "CraftingMenuIngredients")

	self.owner = owner
	self.max_ingredients_wide = max_ingredients_wide
	self.extra_quantity_scale = extra_quantity_scale

	self.ingredient_widgets = {}
	if recipe ~= nil then
		self:SetRecipe(recipe)
	end
end)

function CraftingMenuIngredients:SetRecipe(recipe)
	if self.recipe ~= recipe then
		self.recipe = recipe
	end

	self:KillAllChildren()

	local atlas = resolvefilepath(CRAFTING_ATLAS)

	local owner = self.owner
    local builder = owner.replica.builder
    local inventory = owner.replica.inventory

    self.ingredient_widgets = {}
	local root = self:AddChild(Widget("root"))

	local equippedBody = inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local showamulet = equippedBody and equippedBody.prefab == "greenamulet"

    local num = (recipe.ingredients ~= nil and #recipe.ingredients or 0)
			    + (recipe.character_ingredients ~= nil and #recipe.character_ingredients or 0)
				+ (recipe.tech_ingredients ~= nil and #recipe.tech_ingredients or 0)
				+ (showamulet and 1 or 0)


    local w = 64
    local div = 10
    local half_div = div * .5
    local offset = 0 --center
    if num > 1 then
        offset = offset - (w *.5 + half_div) * (num - 1)
    end

	self.num_items = num

	local scale = math.min(1, self.max_ingredients_wide / num)
	root:SetScale(scale * INGREDIENTS_SCALE)

	local quant_text_scale = math.max(1, 1/(scale*1.125))
	if self.extra_quantity_scale ~= nil then
		quant_text_scale = quant_text_scale * self.extra_quantity_scale
	end

    self.hint_tech_ingredient = nil

    for i, v in ipairs(recipe.tech_ingredients) do
        if v.type:sub(-9) == "_material" then
            local has, level = builder:HasTechIngredient(v)
            local ing = root:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), nil, nil, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type, quant_text_scale))

            if GetGameModeProperty("icons_use_cc") then
                ing.ing:SetEffect("shaders/ui_cc.ksh")
            end
            if num > 1 and #self.ingredient_widgets > 0 then
                offset = offset + half_div
            end
            ing:SetPosition(offset, 0)
            offset = offset + w + half_div
            table.insert(self.ingredient_widgets, ing)
            if not has and self.hint_tech_ingredient == nil and not builder:IsFreeBuildMode() then
                self.hint_tech_ingredient = v.type:sub(1, -10):upper()
            end
        end
    end

	local recipe_data = (self.owner.HUD.controls ~= nil and self.owner.HUD.controls.craftingmenu ~= nil) and owner.HUD.controls.craftingmenu:GetRecipeState(recipe.name) or nil
	local allow_ingredient_crafting = self.hint_tech_ingredient == nil and recipe_data ~= nil and recipe_data.meta.build_state ~= "hint" and recipe_data.meta.build_state ~= "hide"

    for i, v in ipairs(recipe.ingredients) do
        local has, num_found = inventory:Has(v.type, math.max(1, RoundBiasedUp(v.amount * builder:IngredientMod())), true)
		local ingredient_recipe_data = allow_ingredient_crafting and owner.HUD.controls.craftingmenu:GetRecipeState(v.type) or nil

        local ing = root:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), v.amount ~= 0 and v.amount or nil, num_found, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type, quant_text_scale, ingredient_recipe_data))
        if GetGameModeProperty("icons_use_cc") then
            ing.ing:SetEffect("shaders/ui_cc.ksh")
        end
        if num > 1 and #self.ingredient_widgets > 0 then
            offset = offset + half_div
        end
        ing:SetPosition(offset, 0)
        offset = offset + w + half_div
        table.insert(self.ingredient_widgets, ing)
    end

    for i, v in ipairs(recipe.character_ingredients) do
        --#BDOIG - does this need to listen for deltas and change while menu is open?
        --V2C: yes, but the entire craft tabs does. (will be added there)
        local has, amount = builder:HasCharacterIngredient(v)

		if v.type == CHARACTER_INGREDIENT.HEALTH and owner:HasTag("health_as_oldage") then
			v = Ingredient(CHARACTER_INGREDIENT.OLDAGE, math.ceil(v.amount * TUNING.OLDAGE_HEALTH_SCALE))
		end
        local ing = root:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), v.amount, amount, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type, quant_text_scale))
        if GetGameModeProperty("icons_use_cc") then
            ing.ing:SetEffect("shaders/ui_cc.ksh")
        end
        if num > 1 and #self.ingredient_widgets > 0 then
            offset = offset + half_div
        end
        ing:SetPosition(offset, 0)
        offset = offset + w + half_div
        table.insert(self.ingredient_widgets, ing)
    end

	if showamulet then
		local amulet_atlas, amulet_img = equippedBody.replica.inventoryitem:GetAtlas(), equippedBody.replica.inventoryitem:GetImage()
		
		local amulet = root:AddChild(IngredientUI(amulet_atlas, amulet_img, 0.2, 0.2, true, STRINGS.GREENAMULET_TOOLTIP, owner, CHARACTER_INGREDIENT.MAX_HEALTH, quant_text_scale))
		amulet:SetPosition(offset + half_div, 0)
		table.insert(self.ingredient_widgets, amulet)

        for _, ing in ipairs(self.ingredient_widgets) do
			local glow = ing:AddChild(Image("images/global_redux.xml", "shop_glow.tex"))
			glow:SetTint(.8, .8, .8, 0.4)
			local len = 3
			local function doscale(start) if start then glow:SetScale(0) glow:ScaleTo(0, 0.5, len/2, doscale) else glow:ScaleTo(.5, 0, len/2) end end
			local function animate_glow() 
				local t = math.random() * 360
				glow:RotateTo(t, t-360, 3, animate_glow) 
				doscale(true)
			end
			animate_glow()
		end

	end
end


return CraftingMenuIngredients

