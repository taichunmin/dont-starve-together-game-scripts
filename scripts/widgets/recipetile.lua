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
		self:SetRecipe(recipe)
        --self:MakeNonClickable()
    end
end)

function RecipeTile:SetRecipe(recipe)
    self.recipe = recipe
    local image = recipe.imagefn ~= nil and recipe.imagefn() or recipe.image
    self.img:SetTexture(recipe:GetAtlas(), image, image ~= recipe.image and recipe.image or nil)

	if recipe.fxover ~= nil then
		if self.fxover == nil then
			self.fxover = self.img:AddChild(UIAnim())
			self.fxover:SetClickable(false)
			self.fxover:SetScale(.25)
			self.fxover:GetAnimState():AnimateWhilePaused(false)
		end
		self.fxover:GetAnimState():SetBank(recipe.fxover.bank)
		self.fxover:GetAnimState():SetBuild(recipe.fxover.build)
		self.fxover:GetAnimState():PlayAnimation(recipe.fxover.anim, true)
	elseif self.fxover ~= nil then
		self.fxover:Kill()
		self.fxover = nil
	end
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
