local TileBG = require "widgets/tilebg"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"

local CraftingMenuWidget = require "widgets/redux/craftingmenu_widget"
local CraftingMenuPinBar = require "widgets/redux/craftingmenu_pinbar"

local HEIGHT = 600

-- is_left_aligned is primarily: true = normal layout, false = player2 split screen on consoles

local CraftingMenuHUD = Class(Widget, function(self, owner, is_left_aligned)
    Widget._ctor(self, "CraftingMenuHUD")
    self.owner = owner
	self.is_left_aligned = is_left_aligned

	self.valid_recipes = {}
	self:RebuildRecipes()

	local y_offset = IsSplitScreen() and -50 or 0
	    if is_left_aligned then
		self.closed_pos = Vector3(0, y_offset, 0)
		self.opened_pos = Vector3(530, y_offset, 0)
	else
		self.closed_pos = Vector3(0, y_offset, 0)
		self.opened_pos = Vector3(-530, y_offset, 0)
	end

	self.ui_root = self:AddChild(Widget("craftingmenu_root"))
	self.ui_root:SetPosition(self.closed_pos:Get())

	self.craftingmenu = self.ui_root:AddChild(CraftingMenuWidget(owner, self, HEIGHT))
	self.craftingmenu:SetPosition(is_left_aligned and -255 or 255, 0)
	self.craftingmenu:Disable()

	self.nav_hint = self.craftingmenu.nav_hint

	self.pinbar = self.ui_root:AddChild(CraftingMenuPinBar(owner, self, HEIGHT))
	self.pinbar:SetPosition(0, 0)
	self.pinbar:MoveToBack()

	self.openhint = self:AddChild(Text(UIFONT, 30))
	self.openhint:SetPosition(is_left_aligned and 28 or -28, 34 + HEIGHT/2 + y_offset)

	self:RefreshControllers(TheInput:ControllerAttached())

	self.craftingmenu:DoFocusHookups()

    self:StartUpdating()

    local function event_UpdateRecipes()
        self:UpdateRecipes()
    end

	local function UpdateRecipesForTechTreeChange()
		self.tech_tree_changed = true
        self:UpdateRecipes()
	end

    local last_health_seg = nil
    local last_health_penalty_seg = nil
    local last_sanity_seg = nil
    local last_sanity_penalty_seg = nil

    local function UpdateRecipesForHealthIngredients(owner, data)
        local health = owner.replica.health
        if health ~= nil then
            local current_seg = math.floor(math.ceil(data.newpercent * health:Max()) / CHARACTER_INGREDIENT_SEG)
            local penalty_seg = health:GetPenaltyPercent()
            if current_seg ~= last_health_seg or
                penalty_seg ~= last_health_penalty_seg then
                last_health_seg = current_seg
                last_health_penalty_seg = penalty_seg
                self:UpdateRecipes()
            end
        end
    end

    local function UpdateRecipesForSanityIngredients(owner, data)
        local sanity = owner.replica.sanity
        if sanity ~= nil then
            local current_seg = math.floor(math.ceil(data.newpercent * sanity:Max()) / CHARACTER_INGREDIENT_SEG)
            local penalty_seg = sanity:GetPenaltyPercent()
            if current_seg ~= last_sanity_seg or
                penalty_seg ~= last_sanity_penalty_seg then
                last_sanity_seg = current_seg
                last_sanity_penalty_seg = penalty_seg
                self:UpdateRecipes()
            end
        end
    end

    local function OnLearnNewRecipe(owner,data)
    	local pos = Vector3(ThePlayer.Transform:GetWorldPosition())
    	local recipename = data.recipe
        if pos ~= nil and AllRecipes[recipename] then
        	local recipe = AllRecipes[recipename]
        	local slot = self.craftingmenu  -- TEMP FOR NOW.. JUST FOR A POSITION 
            local dest_pos = self.pinbar.open_menu_button:GetWorldPosition()
						
            local im = Image(recipe:GetAtlas(), recipe.image)
            im:MoveTo(Vector3(TheSim:GetScreenPos(pos:Get())), dest_pos, 1, function() 
					im:MoveTo(dest_pos, slot:GetWorldPosition(), 1, function()
            			im:Kill()
            		end)
            	end)
        end	
	end

	local function InitializeCraftingMenu()
		self:Initialize()
	end

    self.inst:ListenForEvent("playeractivated", InitializeCraftingMenu, self.owner)
    self.inst:ListenForEvent("healthdelta", UpdateRecipesForHealthIngredients, self.owner)
    self.inst:ListenForEvent("sanitydelta", UpdateRecipesForSanityIngredients, self.owner)
    self.inst:ListenForEvent("techtreechange", UpdateRecipesForTechTreeChange, self.owner)
    self.inst:ListenForEvent("onactivateskill_client", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("localplayer._skilltreeactivatedany", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("itemget", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("itemlose", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("newactiveitem", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("stacksizechange", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("unlockrecipe", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("refreshcrafting", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("refreshinventory", event_UpdateRecipes, self.owner)
    self.inst:ListenForEvent("LearnBuilderRecipe", OnLearnNewRecipe, self.owner)

    if TheWorld then
        self.inst:ListenForEvent("serverpauseddirty", event_UpdateRecipes, TheWorld)
    end
	self.inst:ListenForEvent("cancelrefreshcrafting", function() self.needtoupdate = false end, self.owner)

    self:Hide()
end)

function CraftingMenuHUD:IsCraftingOpen()
    return self.is_open
end

function CraftingMenuHUD:Open(search)
	if self:IsCraftingOpen() then
		return 
	end

	TheFrontEnd.crafting_navigation_mode = true

	self.ui_root:Enable() 
	self.craftingmenu:Enable()
	self.pinbar:Enable()

	self:RefreshCraftingHelpText()

	if search then
		self.open_focus = self.craftingmenu.search_box
		self.craftingmenu:StartSearching(true)
	else
		self.open_focus = nil
		if TheInput:ControllerAttached() then
			if self.pinbar.focus then
				self.open_focus = self.pinbar:GetFocusSlot()
			end
		end
	end

	if self.open_focus ~= nil then
		self:ClearFocus()
		self.open_focus:SetFocus() -- Note: this ends up calling PopulateRecipeDetailPanel
	end

	self.craftingmenu:OnCraftingMenuOpen(self.open_focus == nil)
	self.pinbar:OnCraftingMenuOpen()

	if not self.focus and not TheFrontEnd.tracking_mouse then
		self.craftingmenu:SetFocus()
	end

    TheFrontEnd:StopTrackingMouse()


	self.ui_root:SetPosition(self.closed_pos.x, self.closed_pos.y, self.closed_pos.z)
	self.ui_root:MoveTo(self.closed_pos, self.opened_pos, .25)

	TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/craft_open")

	self.is_open = true
    SetCraftingAutopaused(true)
end

function CraftingMenuHUD:Close()
	if not self.is_open then
		return 
	end

	self:ClearFocus()

	self.is_open = false
	TheFrontEnd.crafting_navigation_mode = false
	self.nav_hint:Hide()

    SetCraftingAutopaused(false)

	self.ui_root:Disable()
	self.craftingmenu:Disable()
	self.pinbar:OnCraftingMenuClose()
	self.pinbar:Disable()

	TheCraftingMenuProfile:Save()

	self.ui_root:MoveTo(self.ui_root:GetPosition(), self.closed_pos, .25, function()
		self.ui_root:Enable() 
		self.pinbar:Enable()
	end)

	TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/craft_close")
end

function CraftingMenuHUD:GetRecipeState(recipe_name)
	return self.valid_recipes[recipe_name]
end

function CraftingMenuHUD:GetCurrentRecipeState()
	return self.craftingmenu.details_root.data
end

function CraftingMenuHUD:GetCurrentRecipeName()
	return self.craftingmenu.details_root.data ~= nil and self.craftingmenu.details_root.data.recipe.name or nil,
			self.craftingmenu.details_root.skins_spinner ~= nil and self.craftingmenu.details_root.skins_spinner:GetItem() or nil
end

function CraftingMenuHUD:PopulateRecipeDetailPanel(recipe_name, skin_name)
	self.craftingmenu:PopulateRecipeDetailPanel(self.valid_recipes[recipe_name], skin_name)
end

function CraftingMenuHUD:Initialize()
	self:RebuildRecipes()

	self.craftingmenu:Initialize()

	self.pinbar:Refresh()

	self.needtoupdate = false
	self.tech_tree_changed = false
end

function CraftingMenuHUD:NeedsToUpdate()
	return self.needtoupdate
end

function CraftingMenuHUD:UpdateRecipes()
    self.needtoupdate = true
end

function CraftingMenuHUD:RebuildRecipes()
    if self.owner ~= nil and self.owner.replica.builder ~= nil then

		local builder = self.owner.replica.builder
		local freecrafting = builder:IsFreeBuildMode()

		local tech_trees = builder:GetTechTrees()
		local tech_trees_no_temp = builder:GetTechTreesNoTemp()
        for k, recipe in pairs(AllRecipes) do
            if IsRecipeValid(recipe.name) then
				local knows_recipe = builder:KnowsRecipe(recipe)
				local should_hint_recipe = ShouldHintRecipe(recipe.level, tech_trees)

				if self.valid_recipes[recipe.name] == nil then
					self.valid_recipes[recipe.name] = {recipe = recipe, meta = {}}
				end

				local meta = self.valid_recipes[recipe.name].meta
				--meta.can_build = true/false
				--meta.build_state = string

				local is_build_tag_restricted = not builder:CanLearn(recipe.name) -- canlearn is "not build tag restricted"

				if knows_recipe or should_hint_recipe or freecrafting then --Knows enough to see it
				--and (self.filter == nil or self.filter(recipe.name, builder, nil)) -- Has no filter or passes the filter in place

					if builder:IsBuildBuffered(recipe.name) and not is_build_tag_restricted then
						meta.can_build = true
						meta.build_state = "buffered"
					elseif freecrafting then
						meta.can_build = true
						meta.build_state = "freecrafting"
					elseif is_build_tag_restricted then
						meta.can_build = false
						meta.build_state = "hide"
					elseif knows_recipe then
						meta.can_build = builder:HasIngredients(recipe)
						if not recipe.nounlock and not builder:KnowsRecipe(recipe, true) and CanPrototypeRecipe(recipe.level, tech_trees_no_temp) then
							--V2C: for recipes known through temp bonus buff,
							--     but can be prototyped without consuming it
							meta.build_state = "prototype"
						else
							meta.build_state = meta.can_build and "has_ingredients" or "no_ingredients"
						end
					elseif CanPrototypeRecipe(recipe.level, tech_trees) then
						meta.can_build = builder:HasIngredients(recipe)
						meta.build_state = recipe.nounlock and (meta.can_build and "has_ingredients" or "no_ingredients") or "prototype"
					elseif recipe.nounlock then
						meta.can_build = false
						meta.build_state = "hide"
					elseif should_hint_recipe then
						meta.can_build = false
						meta.build_state = "hint"
					else
						meta.can_build = false
						meta.build_state = "hide"
					end
				else
					meta.can_build = false
					meta.build_state = "hide"
				end
            end

        end
	end
end

function CraftingMenuHUD:RefreshControllers(controller_mode)
    if controller_mode then
        self.openhint:Show()
        self.openhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING))
    else
        self.openhint:Hide()
	end

	self.craftingmenu:RefreshControllers(controller_mode)
	self.pinbar:RefreshControllers(controller_mode)
end

function CraftingMenuHUD:OnUpdate(dt)
    if self.needtoupdate then
		self:RebuildRecipes()

		self.craftingmenu:Refresh(self.tech_tree_changed) 
		self.pinbar:Refresh()

		self.needtoupdate = false
		self.tech_tree_changed = false
    end
	
	self:RefreshCraftingHelpText()
end

function CraftingMenuHUD:RefreshCraftingHelpText()
	if self.is_open then
		if TheInput:ControllerAttached() then
			local controller_id = TheInput:GetControllerID()

			local hint_text = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_UP).." "..TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_RIGHT).." "..TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DOWN).." "..TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_LEFT).." "..STRINGS.UI.CRAFTING_MENU.NAVIGATION
			if self.craftingmenu.focus then
				hint_text = hint_text .. "  " .. self.craftingmenu:RefreshCraftingHelpText(TheInput:GetControllerID())
			elseif self.pinbar.focus then
				hint_text = hint_text .. "  " .. self.pinbar:RefreshCraftingHelpText(TheInput:GetControllerID())
			end

			self.nav_hint:SetString(hint_text)
			self.nav_hint:Show()
		else
			self.nav_hint:Hide()
		end
	end
end

function CraftingMenuHUD:OnControl(control, down)
	if CraftingMenuHUD._base.OnControl(self, control, down) then return true end

	return false
end

local function GetClosestWidget(list, active_widget, dir_x, dir_y)
    local closest = nil
    local closest_score = nil

	if active_widget ~= nil then
		local x, y = active_widget.inst.UITransform:GetWorldPosition()
		for k,v in pairs(list) do
			if v ~= active_widget and v:IsVisible() then
				local vx, vy = v.inst.UITransform:GetWorldPosition()
				local local_dir_x, local_dir_y = vx-x, vy-y
				if VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y) > 0 then
					local score = local_dir_x * local_dir_x + local_dir_y * local_dir_y
					if not closest or score < closest_score then
						closest = v
						closest_score = score
					end
				end
			end
		end
	end

    return closest, closest_score
end

function CraftingMenuHUD:InvNavToPin(inv_widget, dir_x, dir_y)
	return GetClosestWidget(self.pinbar.pin_slots, inv_widget, dir_x, dir_y) or self.pinbar.page_spinner
end

function CraftingMenuHUD:SelectPin(pin_slot)
	if pin_slot ~= nil and not self.is_open then
		local pin_button = self.pinbar.pin_slots[pin_slot]
		if pin_button ~= nil and pin_button:HasRecipe() then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			pin_button.craft_button.onclick()
		end
	end
end

return CraftingMenuHUD
