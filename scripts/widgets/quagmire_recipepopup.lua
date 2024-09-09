local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local IngredientUI = require "widgets/ingredientui"
local Spinner = require "widgets/spinner"

require "widgets/widgetutil"

local TEASER_SCALE_TEXT = 0.9
local TEASER_SCALE_BTN = 1.1
local TEASER_TEXT_WIDTH = 190 --216
local TEASER_BTN_WIDTH = 150
local TITLE_TEXT_WIDTH = 280
local TEXT_WIDTH = 240

local testNewTag = false

local recipe_name_fontSize = 40
local recipe_desc_fontSize = PLATFORM ~= "WIN32_RAIL" and 33 or 30

local RecipePopup = Class(Widget, function(self)
    Widget._ctor(self, "Recipe Popup")

    self.smallfonts = JapaneseOnPS4()
    if self.smallfonts then
		recipe_name_fontSize = recipe_name_fontSize * 0.8
		recipe_desc_fontSize = recipe_desc_fontSize * 0.8
    end

    self:BuildNoSpinner()
end)

function RecipePopup:BuildNoSpinner()
    self:KillAllChildren()

    self.hud_atlas = GetGameModeProperty("hud_atlas") or resolvefilepath(HUD_ATLAS)

    self.bg = self:AddChild(Image(self.hud_atlas, "craftingsubmenu_fullhorizontal.tex"))
	self.bg:SetScale(0.7)
    self.bg:SetPosition(210, 16)

    --

    self.contents = self:AddChild(Widget(""))
    self.contents:SetPosition(210 + 22, 16)

    self.name = self.contents:AddChild(Text(UIFONT, recipe_name_fontSize))
	self.name:SetPosition(0, 55)

    local desc_backing = self.bg:AddChild(Image(self.hud_atlas, "craftingsubmenu_litevertical.tex"))
    desc_backing:SetPosition(30, 0)
    desc_backing:SetSize(410, 90)
    self.desc = desc_backing:AddChild(Text(BODYTEXTFONT, recipe_desc_fontSize))
    self.desc:SetPosition(0, 0)
	self.desc:SetScale(1.2)

    self.button = self.contents:AddChild(ImageButton())
    self.button:SetScale(0.8)
    self.button.image:SetScale(.45, .7)
    self.button:SetPosition(40, -58)
    self.button:SetWhileDown(function()
        if self.recipe_held then
            DoRecipeClick(self.owner, self.recipe)
        end
    end)
    self.button:SetOnDown(function()
        if self.last_recipe_click and (GetStaticTime() - self.last_recipe_click) < 1 then
            self.recipe_held = true
            self.last_recipe_click = nil
        end
    end)
    self.button:SetOnClick(function()
        self.last_recipe_click = GetStaticTime()
        if not self.recipe_held then
            if not DoRecipeClick(self.owner, self.recipe) then
                self.owner.HUD.controls.crafttabs:Close()
            end
        end
        self.recipe_held = false
    end)

    self.ingredient_backing = self.contents:AddChild(Image(self.hud_atlas, "inv_slot.tex"))
	self.ingredient_backing:SetScale(.5)
	self.ingredient_backing:SetPosition(-80, -58)

    self.ingredient = nil

    self.teaser = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.teaser:SetPosition(50, -58)
    self.teaser:Hide()
end

function RecipePopup:Refresh()
    local owner = self.owner
    if owner == nil then
        return false
    end

    local recipe = self.recipe
    local builder = owner.replica.builder
    local inventory = owner.replica.inventory

    local knows = builder:KnowsRecipe(recipe)
    local buffered = builder:IsBuildBuffered(recipe.name)
    local can_build = buffered or builder:HasIngredients(recipe)

    self:BuildNoSpinner()

    self.name:SetTruncatedString(STRINGS.NAMES[string.upper(self.recipe.product)], TITLE_TEXT_WIDTH, nil, true)
    self.desc:SetMultilineTruncatedString(STRINGS.RECIPE_DESC[string.upper(self.recipe.product)], 2, TEXT_WIDTH, nil, true)

	if self.ingredient ~= nil then
		self.ingredient:Kill()
		self.ingredient = nil
	end

    local num = 1
    local w = 64
    local div = 10
    local half_div = div * .5

    local hint_tech_ingredient = nil

	local ingredient = recipe.ingredients[1]
    local has_enough, num_found = inventory:Has(ingredient.type, RoundBiasedUp(ingredient.amount * builder:IngredientMod()), true)
	local name = STRINGS.NAMES[string.upper(ingredient.type)]

    self.ingredient = self.ingredient_backing:AddChild(Image(ingredient:GetAtlas(), ingredient:GetImage()))
	self.ingredient:SetEffect("shaders/ui_cc.ksh")
    self.num_ingredients = self.ingredient:AddChild(Text(BODYTEXTFONT, 65, tostring(ingredient.amount)))
    if not has_enough then
        self.num_ingredients:SetColour(255/255, 155/255, 155/255, 1)
    end
	self.num_ingredients:SetPosition(65, 0)

    self.ingredient_backing:SetTexture(self.hud_atlas, has_enough and "inv_slot.tex" or "resource_needed.tex")
--	self.ingredient_backing:SetHoverText(name, {bg_atlas = self.hud_atlas, bg_texture = "craftingsubmenu_litevertical.tex", font = BODYTEXTFONT})
	self.ingredient_backing:SetHoverText(name, {bg = false, font = BODYTEXTFONT})

--   local ing = self.contents:AddChild(IngredientUI(v.atlas, v.type..".tex", v.amount, num_found, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type))

    local buttonstr =
        (not (knows or recipe.nounlock) and STRINGS.UI.CRAFTING.PROTOTYPE) or
        (buffered and STRINGS.UI.CRAFTING.PLACE) or
        STRINGS.UI.CRAFTING.TABACTION[recipe.tab.str] or
        STRINGS.UI.CRAFTING.BUILD

    if TheInput:ControllerAttached() then
        self.button:Hide()
        self.teaser:Show()

        if can_build then
            self.teaser:SetScale(TEASER_SCALE_BTN)
            self.teaser:SetTruncatedString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_ACCEPT).." "..buttonstr, TEASER_BTN_WIDTH, 26, true)
        else
            self.teaser:SetScale(TEASER_SCALE_TEXT)
            self.teaser:SetMultilineTruncatedString((STRINGS.UI.CRAFTING.TABNEEDSTUFF or {})[recipe.tab.str] or STRINGS.UI.CRAFTING.NEEDSTUFF, 3, TEASER_TEXT_WIDTH, 38, true)
        end
    else
        self.button:Show()
	    self.teaser:Hide()

        self.button:SetText(buttonstr)
        if can_build then
            self.button:Enable()
        else
            self.button:Disable()
        end
    end
end

function RecipePopup:SetRecipe(recipe, owner)
    self.recipe = recipe
    self.owner = owner
    self:Refresh()
end

function RecipePopup:OnControl(control, down)
    if RecipePopup._base.OnControl(self, control, down) then return true end
end

return RecipePopup
