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
local RecipePopup = require "widgets/recipepopup"

require "widgets/widgetutil"

local REPEAT_TIME = .15
local POPUPOFFSET = Vector3(-300,-360,0)

local selected_scale = .9

local ControllerCrafting = Class(Crafting, function(self, owner)
    Crafting._ctor(self, owner, 10)
	self:SetOrientation(true)

	self.tabidx = 1
	self.selected_recipe_by_tab_idx = {}
	self.repeat_time = REPEAT_TIME

	local sc = .75
	self:SetScale(sc,sc,sc)
	self.in_pos = Vector3(550, 250, 0)
	self.out_pos = Vector3(-2000, 250, 0)
	--[[self.in_pos = Vector3(-200, -160, 0)
	self.out_pos = Vector3(-2000, -160, 0)
	--]]

	self.groupname = self:AddChild(Text(TITLEFONT, 100))
	--self.groupname:SetPosition(-400, 90, 0)
	self.groupname:SetPosition(-210, 115, 0)
	self.groupname:SetHAlign(ANCHOR_LEFT)
	self.groupname:SetRegionSize(800, 120)

	--self.groupimg1 = self:AddChild(Image())
	--self.groupimg1:SetPosition(-200, 90, 0)
	--self.groupimg2 = self:AddChild(Image())
	--self.groupimg2:SetPosition(200, 90, 0)

	self.recipepopup = self:AddChild(RecipePopup(true))
	self.recipepopup:Hide()

	self.recipepopup:SetScale(1.25, 1.25, 1.25)

	self.inst:ListenForEvent("buildsuccess", function() self:Refresh() end, self.owner)
	self.inst:ListenForEvent("unlockrecipe", function() self:Refresh() end, self.owner)
end)

--We don't want this to happen in ControllerCrafting so override it to do nothing.
function ControllerCrafting:Resize(num_recipes)
end

--We don't want this to happen in ControllerCrafting so override it to do nothing.
function ControllerCrafting:UpdateIdx()
    self.use_idx = true
end

--Override for ControllerCrafting, which always shows scroll buttons.
function ControllerCrafting:CanScroll()
    return self.valid_recipes ~= nil and #self.valid_recipes > self.max_slots - 2
end

function ControllerCrafting:GetTabs()
    return self.parent ~= nil and self.parent.name == "CraftTabs" and self.parent or nil
end

function ControllerCrafting:Close(fn)
    ControllerCrafting._base.Close(self, fn)
    self:GetTabs():ScaleTo(selected_scale, self:GetTabs().base_scale, .15)
    self.recipe_held = false
    self:StopUpdating()
    --V2C: focus hacks because this is not a proper screen
    TheFrontEnd:LockFocus(false)
    TheFrontEnd:ClearFocus()
end

function ControllerCrafting:Open(fn)
	ControllerCrafting._base.Open(self, fn)
	self:GetTabs():ScaleTo(self:GetTabs().base_scale, selected_scale, .15)
	self:StartUpdating()

	self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
	self.control_held_time = 0
	self.accept_down = TheInput:IsControlPressed(CONTROL_PRIMARY)

	if self.oldslot ~= nil then
		self.oldslot:SetScale(1,1,1)
		self.oldslot = nil
	end

	if not self:OpenRecipeTab(self.tabidx) then
		self:OpenRecipeTab(1)
	end
	self.craftslots:Open(1)
	if not self:SelectRecipe(self.selected_recipe_by_tab_idx[self.tabidx]) then
		self:SelectRecipe()
	end
	self:SetFocus()
	TheFrontEnd:LockFocus(true)
end

function ControllerCrafting:SelectRecipe(recipe)
    local k = nil
    if recipe ~= nil then
        for i, v in ipairs(self.valid_recipes) do
            if recipe == v then
                k = i
                break
            end
        end
    elseif #self.valid_recipes > 0 then
        recipe = self.valid_recipes[1]
        k = 1
    end

    if k == nil then
        return
    end

    --scroll the list to get our item into view
    local slot_idx = k - self.idx
    if slot_idx <= 1 then
        self.idx = k - 2
    elseif slot_idx >= self.max_slots then
        self.idx = self.idx + slot_idx - self.max_slots + 1
    end

    self.selected_recipe_by_tab_idx[self.tabidx] = recipe
    self:UpdateRecipes()
    self.craftslots:CloseAll()

    self.craftslots:LockOpen(k - self.idx)

    local slot = self.craftslots.slots[k - self.idx]
    if slot ~= nil then
        if self.recipepopup.shown then
            self.recipepopup:SetRecipe(recipe, self.owner)
            self.recipepopup:MoveTo(self.recipepopup:GetPosition(), slot:GetPosition() + POPUPOFFSET, .2)
        else
            self.recipepopup:Show()
            self.recipepopup:SetPosition(slot:GetPosition() + POPUPOFFSET)
        end

        if slot ~= self.oldslot then
            if self.oldslot ~= nil then
                self.oldslot:ScaleTo(1.4, 1, .1)
            end
            slot:ScaleTo(1, 1.4, .2)
            self.oldslot = slot
        end
    end
    return true
end

function ControllerCrafting:SelectNextRecipe()
	local old_recipe = self.selected_recipe_by_tab_idx[self.tabidx]

	local last_recipe = nil
	for k,v in ipairs(self.valid_recipes) do
		if last_recipe == self.selected_recipe_by_tab_idx[self.tabidx] then
			self:SelectRecipe(v)
			return old_recipe ~= v
		end
		last_recipe = v
	end
end

function ControllerCrafting:SelectPrevRecipe()
	local old_recipe = self.selected_recipe_by_tab_idx[self.tabidx]

	local last_recipe = self.valid_recipes[1]
	for k,v in ipairs(self.valid_recipes) do
		if self.selected_recipe_by_tab_idx[self.tabidx] == v then
			self:SelectRecipe(last_recipe)
			return last_recipe ~= old_recipe
		end
		last_recipe = v
	end
end

function ControllerCrafting:OpenRecipeTab(idx)
	--self.slot_idx_by_tab_idx[self.tabidx] = self.idx
	local tab = self:GetTabs():OpenTab(idx)
	if tab ~= nil then
		self.tabidx = idx

		self.groupname:SetString(tab.tabname)

		--self.groupimg1:SetTexture(tab.icon_atlas, tab.icon)
		--self.groupimg2:SetTexture(tab.icon_atlas, tab.icon)

		--self.idx = self.slot_idx_by_tab_idx[self.tabidx] or 1
		self:SetFilter(
			function(recname)
				local recipe = GetValidRecipe(recname)
				return recipe ~= nil
                    and recipe.tab == tab.filter
                    and (self.owner.replica.builder == nil or
                        self.owner.replica.builder:CanLearn(recname))
			end)
		if not self:SelectRecipe(self.selected_recipe_by_tab_idx[self.tabidx]) then
			self:SelectRecipe()
		end
		return tab
	end
end

function ControllerCrafting:Refresh()
    self.recipepopup:Refresh()
    self.craftslots:Refresh()
end

function ControllerCrafting:OnControl(control, down)

  	if control == CONTROL_NEXTVALUE or control == CONTROL_PREVVALUE then
    	if self.recipepopup then
    		self.recipepopup:OnControl(control, down)
    	end
    end

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
        if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) then
            if self:SelectPrevRecipe() then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            end
        elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) then
            if self:SelectNextRecipe() then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            end
        elseif TheInput:IsControlPressed(CONTROL_MOVE_UP) then
            local idx = self:GetTabs():GetPrevIdx()
            if self.tabidx ~= idx and self:OpenRecipeTab(idx) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_up")
            end
        elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) then
            local idx = self:GetTabs():GetNextIdx()
            if self.tabidx ~= idx and self:OpenRecipeTab(idx) then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_down")
            end
        else
            self.repeat_time = 0
            return
        end
        self.repeat_time = REPEAT_TIME
    end
end

return ControllerCrafting