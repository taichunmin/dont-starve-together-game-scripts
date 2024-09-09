local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local CraftSlot = require "widgets/craftslot"
local Crafting = require "widgets/crafting"

require "widgets/widgetutil"

local REPEAT_TIME = .15

local ControllerCrafting = Class(Crafting, function(self, owner, num_tabs)
    Crafting._ctor(self, owner, num_tabs or 10)
	self:SetOrientation(false)
	self.craftslots:EnablePopups()

	self.tabidx = 1
	self.selected_recipe = nil
	self.selected_slot = 1
	self.repeat_time = REPEAT_TIME
end)

function ControllerCrafting:Resize(num_recipes)
    ControllerCrafting._base.Resize(self, num_recipes)
end

function ControllerCrafting:UpdateIdx()
    ControllerCrafting._base.UpdateIdx(self)
end

function ControllerCrafting:CanScroll()
    return ControllerCrafting._base.CanScroll(self)
end

function ControllerCrafting:GetTabs()
    return self.parent ~= nil and self.parent.name == "CraftTabs" and self.parent or nil
end

function ControllerCrafting:Close(fn)
    ControllerCrafting._base.Close(self, fn)
    self.recipe_held = false
    self:StopUpdating()
    --V2C: focus hacks because this is not a proper screen
    TheFrontEnd:LockFocus(false)
    TheFrontEnd:ClearFocus()
end

function ControllerCrafting:Open(fn)
	ControllerCrafting._base.Open(self, fn)
	self:StartUpdating()

	self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
	self.control_held_time = 0
	self.accept_down = TheInput:IsControlPressed(CONTROL_PRIMARY)

	local tab_index = self:GetTabs():GetFirstIdx()
	if tab_index ~= self.tabidx then
		self.tabidx = tab_index
		self.selected_recipe = nil
	end

	self:OpenRecipeTab()
	self:SetFocus()
	TheFrontEnd:LockFocus(true)
end

local function FindRecipeIndex(self, recipe)
    if recipe ~= nil then
        for i, v in ipairs(self.valid_recipes) do
            if recipe == v then
                return i
            end
        end
	end
	return 1
end

function ControllerCrafting:SelectRecipe(recipe)
	local slot = FindRecipeIndex(self, recipe)
    recipe = self.valid_recipes[slot]

    --scroll the list to get our item into view
	if self:CanScroll() then
		local slot_idx = slot - self.idx
		if slot_idx <= 1 then
			self.idx = slot - 2
		elseif slot_idx >= self.max_slots then
			self.idx = self.idx + slot_idx - self.max_slots + 1
		end
		slot = slot - self.idx
	end

    self.selected_recipe = recipe
	self.selected_slot = slot

    self:UpdateRecipes()
    self.craftslots:CloseAll()

    self.craftslots:LockOpen(slot)

    return true
end

function ControllerCrafting:SelectNextRecipe()
	local slot = FindRecipeIndex(self, self.selected_recipe) + 1
	if slot <= #self.valid_recipes then
		self:SelectRecipe(self.valid_recipes[slot])
		return true
	end
	return false
end

function ControllerCrafting:SelectPrevRecipe()
	local slot = FindRecipeIndex(self, self.selected_recipe) - 1
	if slot >= 1 then
		self:SelectRecipe(self.valid_recipes[slot])
		return true
	end
	return false
end

function ControllerCrafting:OpenRecipeTab()
	local tab = self:GetTabs():OpenTab(self.tabidx)
	if tab ~= nil then
		self:SetFilter(
			function(recname)
				local recipe = GetValidRecipe(recname)
				return recipe ~= nil
                    and recipe.tab == tab.filter
                    and (self.owner.replica.builder == nil or
                        self.owner.replica.builder:CanLearn(recname))
			end)

		self:UpdateRecipes()
		self.craftslots:CloseAll()
		self:SelectRecipe(self.selected_recipe)
		return tab
	end
end

function ControllerCrafting:OnControl(control, down)
    if not self.open then return end

    if down then
        if control == CONTROL_ACCEPT or control == CONTROL_ACTION then
            if self.last_recipe_click and (GetStaticTime() - self.last_recipe_click) < 1 then
                self.recipe_held = true
                self.last_recipe_click = nil
            end
        end
        return
    elseif control == CONTROL_ACCEPT or control == CONTROL_ACTION then
        if self.accept_down then
            self.accept_down = false --this was held down when we were opened, so we want to ignore it
        else
        	local skin = (self.recipepopup.skins_spinner and self.recipepopup.skins_spinner.GetItem()) or nil
            if skin ~= nil then
				Profile:SetLastUsedSkinForItem(self.selected_recipe_by_tab_idx[self.tabidx].name, skin)
				Profile:SetRecipeTimestamp(self.selected_recipe_by_tab_idx[self.tabidx].name, self.recipepopup.timestamp)
            end
            self.last_recipe_click = GetStaticTime()
            if not self.recipe_held then
                if not DoRecipeClick(self.owner, self.selected_recipe_by_tab_idx[self.tabidx], skin) then
                    self.owner.HUD:CloseControllerCrafting()
                end
            else
                self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
            end
            self.recipe_held = false
            if not self.control_held then
                self.owner.HUD:CloseControllerCrafting()
            end
        end
        return true
    elseif control == CONTROL_OPEN_CRAFTING and self.control_held and self.control_held_time > 1 and not self.recipe_held then
        self.owner.HUD:CloseControllerCrafting()
        return true
    end
end

function ControllerCrafting:OnUpdate(dt)
    if not self.open or not self.owner.HUD.shown or TheFrontEnd:GetActiveScreen() ~= self.owner.HUD then
        return
    end

    if self.recipe_held then
        DoRecipeClick(self.owner, self.selected_recipe_by_tab_idx[self.tabidx], self.recipepopup.skins_spinner and self.recipepopup.skins_spinner.GetItem() or nil)
    end

    if self.control_held then
        self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
        self.control_held_time = self.control_held_time + dt
    end

    if self.repeat_time > dt then
        self.repeat_time = self.repeat_time - dt
    else
		if TheInput:IsControlPressed(CONTROL_MOVE_UP) then
			if self:SelectPrevRecipe() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) then
			if self:SelectNextRecipe() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		else
			self.repeat_time = 0
			return
		end
        self.repeat_time = REPEAT_TIME
    end
end

return ControllerCrafting