require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local IngredientUI = Class(Widget, function(self, atlas, image, quantity, on_hand, has_enough, name, owner, recipe_type)
    Widget._ctor(self, "IngredientUI")

    --self:SetClickable(false)

    local hud_atlas = resolvefilepath("images/hud.xml")

    self.bg = self:AddChild(Image(hud_atlas, has_enough and "inv_slot.tex" or "resource_needed.tex"))

    self:SetTooltip(name)

    self.ing = self:AddChild(Image(atlas, image))

    if quantity ~= nil then
        self.quant = self:AddChild(Text(SMALLNUMBERFONT, JapaneseOnPS4() and 30 or 24))
        self.quant:SetPosition(7, -32, 0)
        if not IsCharacterIngredient(recipe_type) then
            local builder = owner ~= nil and owner.replica.builder or nil
            if builder ~= nil then
                quantity = RoundBiasedUp(quantity * builder:IngredientMod())
            end
            self.quant:SetString(string.format("%d/%d", on_hand, quantity))
        elseif recipe_type == CHARACTER_INGREDIENT.MAX_HEALTH
            or recipe_type == CHARACTER_INGREDIENT.MAX_SANITY then
            self.quant:SetString(string.format("-%2.0f%%", quantity * 100))
        else
            self.quant:SetString(string.format("-%d", quantity))
        end
        if not has_enough then
            self.quant:SetColour(255/255, 155/255, 155/255, 1)
        end
    end
end)

return IngredientUI
