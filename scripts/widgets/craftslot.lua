local Image = require "widgets/image"
local Widget = require "widgets/widget"
local RecipeTile = require "widgets/recipetile"
local RecipePopup = require "widgets/recipepopup"
local QuagmireRecipePopup = require "widgets/quagmire_recipepopup"

require "widgets/widgetutil"

local CraftSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "Craftslot")
    self.owner = owner

    self.atlas = atlas
    self.bgimage = self:AddChild(Image(atlas, bgim))

    self.tile = self:AddChild(RecipeTile(nil))
    self.fgimage = self:AddChild(Image("images/hud.xml", "craft_slot_locked.tex"))
    self.fgimage:Hide()
    self.lightbulbimage = self:AddChild(Image(self.atlas, "craft_slot_prototype.tex"))
    self.lightbulbimage:Hide()

    self.isquagmireshop = TheNet:GetServerGameMode() == "quagmire" or nil
end)

function CraftSlot:GetSize()
	return self.bgimage:GetSize()
end

function CraftSlot:EnablePopup()
    if not self.recipepopup then
        self.recipepopup = self:AddChild(self.isquagmireshop and QuagmireRecipePopup() or RecipePopup())
        self.recipepopup:SetPosition(0,-20,0)
        self.recipepopup:Hide()
        local s = 1.25
        self.recipepopup:SetScale(s,s,s)
    end
end

function CraftSlot:OnGainFocus()
    CraftSlot._base.OnGainFocus(self)
    self:Open()
end

function CraftSlot:OnControl(control, down)
    if CraftSlot._base.OnControl(self, control, down) then return true end

    if control == CONTROL_ACCEPT then
        if down then
            if not self.down then
                self.down = true

                if self.last_recipe_click and (GetStaticTime() - self.last_recipe_click) < 1 then
                    self.recipe_held = true
                    self.last_recipe_click = nil
                    self:StartUpdating()
                end
            end
        else
            if self.down then
				self.down = false
                if self.owner and self.recipe and self.recipepopup and not self.recipepopup.focus then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

                    local skin = (self.recipepopup.skins_spinner and self.recipepopup.skins_spinner.GetItem()) or nil

                    if skin ~= nil then
                        Profile:SetLastUsedSkinForItem(self.recipe.name, skin)
                        Profile:SetRecipeTimestamp(self.recipe.name, self.recipepopup.timestamp)
                    end

                    self:StartUpdating()
                    self.last_recipe_click = GetStaticTime()
                    self.recipe_held = false
                    if not DoRecipeClick(self.owner, self.recipe, skin ) then
                        self:Close()
                    end

                    return true
                end
                self:StopUpdating()
            end
        end
    end
end

function CraftSlot:OnUpdate(dt)
    if self.down and self.recipe_held then
        DoRecipeClick(self.owner, self.recipe, self.recipepopup.skins_spinner and self.recipepopup.skins_spinner.GetItem() or nil)
    end
end

function CraftSlot:OnLoseFocus()
    CraftSlot._base.OnLoseFocus(self)
    self.recipe_held = false
    self:StopUpdating()
    self:Close()
end

function CraftSlot:Clear()
    self.recipename = nil
    self.recipe = nil
    self.recipe_skins = {}
    self.canbuild = false

    if self.tile then
        self.tile:Hide()
    end

    self.fgimage:Hide()
    self.lightbulbimage:Hide()
    self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
    --self:HideRecipe()
end

function CraftSlot:LockOpen()
	self:Open()
	self.locked = true
end

function CraftSlot:Open()
    if self.recipepopup then
        self.recipepopup:SetPosition(0,-20,0)
    end
    self.open = true
    self:ShowRecipe()
    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
end

function CraftSlot:Close()
    self.open = false
    self.locked = false
    self:HideRecipe()
end

function CraftSlot:ShowRecipe()
    if self.recipe and self.recipepopup then
        self.recipepopup:Show()
        self.recipepopup:SetRecipe(self.recipe, self.owner)
    end
end

function CraftSlot:HideRecipe()
    if self.recipepopup then
        self.recipepopup:Hide()
    end
end

function CraftSlot:Refresh(recipename)
	recipename = recipename or self.recipename
    local recipe = GetValidRecipe(recipename)

    self.recipename = recipename
    self.recipe = recipe
    self.recipe_skins = {}

    if self.recipe then
		local canbuild = self.owner.replica.builder:HasIngredients(recipe)
		local knows = self.owner.replica.builder:KnowsRecipe(recipe)
		local buffered = self.owner.replica.builder:IsBuildBuffered(recipename)

		self.recipe_skins = Profile:GetSkinsForPrefab(self.recipe.name)

        self.canbuild = canbuild
        self.tile:SetRecipe(self.recipe)
        self.tile:Show()

        --#srosen erroneously showing inverted sometimes
        local right_level = CanPrototypeRecipe(self.recipe.level, self.owner.replica.builder:GetTechTrees())

        if self.fgimage then
            if knows or recipe.nounlock then
                if self.isquagmireshop then
                    if canbuild or buffered then
                        self.bgimage:SetTexture(self.atlas, "craft_slot_locked_highlight.tex")
                    else
                        self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
                    end
                    self.lightbulbimage:Hide()
                    self.fgimage:Hide()
                else
                    if buffered then
                        self.bgimage:SetTexture(self.atlas, "craft_slot_place.tex")
                    else
                        self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
                    end
                    if canbuild or buffered then
                        self.fgimage:Hide()
                    else
                        self.fgimage:Show()
                        self.fgimage:SetTexture(self.atlas, "craft_slot_missing_mats.tex")
                    end
                    self.lightbulbimage:Hide()
                    self.fgimage:SetTint(1, 1, 1, 1)
                end
            else
                --print("Right_Level for: ", recipename, " ", right_level)
                local show_highlight = false

                show_highlight = canbuild and right_level

                local hud_atlas = resolvefilepath( "images/hud.xml" )

                if not right_level then
                    self.fgimage:SetTexture(hud_atlas, "craft_slot_locked_nextlevel.tex")
                    self.lightbulbimage:Hide()
                    self.fgimage:Show()
                    if buffered then
                        self.bgimage:SetTexture(self.atlas, "craft_slot_place.tex")
                    else
                        self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
                    end
                    self.fgimage:SetTint(.7,.7,.7,1)
                elseif show_highlight then
                    self.bgimage:SetTexture(hud_atlas, "craft_slot_locked_highlight.tex")
                    self.lightbulbimage:Show()
                    self.fgimage:Hide()
                    self.fgimage:SetTint(1,1,1,1)
                else
                    self.fgimage:SetTexture(hud_atlas, "craft_slot_missing_mats.tex")
                    self.lightbulbimage:Hide()
                    self.fgimage:Show()
                    if buffered then
                        self.bgimage:SetTexture(self.atlas, "craft_slot_place.tex")
                    else
                        self.bgimage:SetTexture(self.atlas, "craft_slot.tex")
                    end
                    self.fgimage:SetTint(1,1,1,1)
                end
            end
        end

        self.tile:SetCanBuild((buffered or canbuild )and (knows or recipe.nounlock or right_level))

        if self.recipepopup then
            self.recipepopup:SetRecipe(self.recipe, self.owner)
			if self.focus and not self.open then
				self:Open()
			end
		end

        --self:HideRecipe()
    end
end

function CraftSlot:SetRecipe(recipename)
    self:Show()
	self:Refresh(recipename)

end

return CraftSlot