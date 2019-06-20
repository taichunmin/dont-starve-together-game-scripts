require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local RecipeTile = Class(Widget, function(self, recipe)
    Widget._ctor(self, "RecipeTile")
    self.img = self:AddChild(Image())
    if GetGameModeProperty("icons_use_cc") then
        self.img:SetEffect("shaders/ui_cc.ksh")
    end
    self:SetClickable(false)
    if recipe ~= nil then
        self.recipe = recipe
        local image = recipe.imagefn ~= nil and recipe.imagefn() or recipe.image
        self.img:SetTexture(recipe:GetAtlas(), image, image ~= recipe.image and recipe.image or nil)
        --self:MakeNonClickable()
    end
end)

function RecipeTile:SetRecipe(recipe)
    self.recipe = recipe
    local image = recipe.imagefn ~= nil and recipe.imagefn() or recipe.image
    self.img:SetTexture(recipe:GetAtlas(), image, image ~= recipe.image and recipe.image or nil)
end

function RecipeTile:SetCanBuild(canbuild)
    --[[if canbuild then
        local image = recipe.imagefn ~= nil and recipe.imagefn() or recipe.image
        self.img:SetTexture(self.recipe:GetAtlas(), image, image ~= recipe.image and recipe.image or nil)
        self.img:SetTint(1,1,1,1)
    elseif self.recipe ~= nil and self.recipe.lockedatlas ~= nil then
        self.img:SetTexture(self.recipe.lockedatlas, self.recipe.lockedimage)
    else
        self.img:SetTint(0,0,0,1)
    end]]
end

return RecipeTile
