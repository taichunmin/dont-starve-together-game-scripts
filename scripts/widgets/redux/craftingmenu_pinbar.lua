
local Widget = require "widgets/widget"
local TileBG = require "widgets/tilebg"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Grid = require "widgets/grid"

local PinSlot = require "widgets/redux/craftingmenu_pinslot"
local CraftingMenuIngredients = require "widgets/redux/craftingmenu_ingredients"

local CraftingMenuPinBar = Class(Widget, function(self, owner, crafting_hud, height)
    Widget._ctor(self, "Crafting Menu Pin Bar")

	self.owner = owner
	self.crafting_hud = crafting_hud

	local is_left = crafting_hud.is_left_aligned

	local atlas = resolvefilepath(CRAFTING_ATLAS)

	self.root = self:AddChild(Widget("slot_root"))
	self.root:SetScale(0.73)
	self.root:SetPosition(is_left and 30 or -30, 0)

	local y = 378
	local buttonsize = 64


	-- OPEN BUTTON
	self.open_menu_button = self.root:AddChild(ImageButton(atlas, "crafting_tab.tex", "crafting_tab.tex", nil, nil, nil, {1,1}, {0,0}))
	self.pin_open = self.open_menu_button -- self.pin_open is now depercated and has been renamed to open_menu_button
	self.open_menu_button:SetPosition(is_left and 9 or -9, y)
	self.open_menu_button:SetNormalScale(is_left and 0.4 or -.4, .4)
	self.open_menu_button:SetFocusScale(is_left and 0.45 or -.45, .45)

	self.open_menu_button.glow = self.open_menu_button.image:AddChild(Image("images/global_redux.xml", "shop_glow.tex"))
	self.open_menu_button.glow:SetTint(.8, .8, .8, 0.4)
	self.open_menu_button.glow:SetPosition(2, 0)
	self.open_menu_button.glow:Hide()
	self.open_menu_button.icon = self.open_menu_button.image:AddChild(Image(PROTOTYPER_DEFS.none.icon_atlas, PROTOTYPER_DEFS.none.icon_image))
	self.open_menu_button.icon:SetPosition(2, 0)
	self.open_menu_button.icon:SetScale(is_left and 0.75 or -0.75, 0.75)
	self.open_menu_button.prototype = self.open_menu_button.image:AddChild(Image(atlas, "pinslot_fg_prototype.tex"))
	self.open_menu_button.prototype:SetPosition(-6, 0)
	self.open_menu_button.prototype:SetScale(1.5)
	self.open_menu_button.prototype:Hide()

	local function animate_glow(initial) 
		local len = 1
		if initial then 
			self.open_menu_button.glow:CancelTintTo()
			self.open_menu_button.glow:CancelRotateTo()
			self.open_menu_button.glow:CancelScaleTo()

			self.open_menu_button.glow:Show() 
			self.open_menu_button.glow:SetTint(.8, .8, .8, 0.4)

			self.open_menu_button.glow:SetScale(0)
			self.open_menu_button.glow:ScaleTo(0, 1.5, len/2, animate_glow) 

			local t = math.random() * 360
			self.open_menu_button.glow:RotateTo(t, t-360, len + 0.5)
		else 
			self.open_menu_button.glow:TintTo({ r=0.8, g=0.8, b=0.8, a=.4 }, { r=0.8, g=0.8, b=0.8, a=0 }, len/2, function() self.open_menu_button.glow:Hide() end)
		end
	end

	self.open_menu_button:SetOnClick(function()
		if self.owner.HUD:IsCraftingOpen() then
			self.owner.HUD:CloseCrafting()
		else
			self.owner.HUD:OpenCrafting()
		end
    end)
	self.open_menu_button.SetCraftingState = function(s, can_prototype, new_recipe_available)
		local animate = false
		if s.can_prototype ~= can_prototype then
			if can_prototype then
				s.prototype:Show()
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/research_available")
				animate = true
			else
				s.prototype:Hide()
			end
			s.can_prototype = can_prototype
		elseif new_recipe_available then
			TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/recipe_ready")
			animate = true
		end	

		if animate then
			animate_glow(true)
		end
	end

	self.open_menu_button.OnControl = function(s, control, down)
		if ImageButton._base.OnControl(s, control, down) then return true end

		if down then
			if control == CONTROL_SCROLLBACK and not TheInput:ControllerAttached() then
				self:GoToPrevPage()
				return true
			elseif control == CONTROL_SCROLLFWD and not TheInput:ControllerAttached() then
				self:GoToNextPage()
				return true
			end
		end
		
		return false
	end

	y = y - 76

	-- PAGE SPINNER
	self.page_spinner = self.root:AddChild(self:MakePageSpinner())
	self.page_spinner:SetPosition(0, y)

	y = y - 61

	-- PIN SLOTS

	self.pin_slots = {}

	local pinned_recipes = TheCraftingMenuProfile:GetPinnedRecipes()

	local function FindPinUp(_pin)
		for i = _pin.slot_num - 1, 1, -1 do
			if self.pin_slots[i]:IsVisible() then
				return self.pin_slots[i]
			end
		end

		if self.crafting_hud:IsCraftingOpen() and TheInput:ControllerAttached() then
			return self.page_spinner
		end
	end

	local function FindPinDown(_pin)
		for i = (_pin.slot_num or 0) + 1, TUNING.MAX_PINNED_RECIPES do
			if self.pin_slots[i]:IsVisible() then
				return self.pin_slots[i]
			end
		end
	end
	
	for i = 1, TUNING.MAX_PINNED_RECIPES do
		local pin_slot = self.root:AddChild(PinSlot(self.owner, crafting_hud, i, pinned_recipes[i]))
		pin_slot:SetPosition(0, y)
		pin_slot.FindPinUp = FindPinUp
		pin_slot.FindPinDown = FindPinDown
		pin_slot.hide_cursor = true
		pin_slot.in_pinbar = true
		table.insert(self.pin_slots, pin_slot)

		y = y - buttonsize - 13
	end
	
	self.page_spinner.FindPinUp = function() return self.page_spinner end
	self.page_spinner.FindPinDown = FindPinDown
	self.page_spinner.hide_cursor = true
	self.page_spinner.in_pinbar = true

	self.focus_forward = self.pin_slots[1]
end)

function CraftingMenuPinBar:DoFocusHookups()
	self.open_menu_button:SetFocusChangeDir(MOVE_DOWN, self.page_spinner)
	self.page_spinner:SetFocusChangeDir(MOVE_DOWN, self.page_spinner.FindPinDown)

	for _, pin_slot in pairs(self.pin_slots) do
		pin_slot:SetFocusChangeDir(MOVE_UP, pin_slot.FindPinUp)
		pin_slot:SetFocusChangeDir(MOVE_DOWN, pin_slot.FindPinDown)
	end
end

function CraftingMenuPinBar:ClearFocusHookups()
	self.open_menu_button:ClearFocusDirs()
	self.page_spinner:ClearFocusDirs()

	for _, pin_slot in pairs(self.pin_slots) do
		pin_slot:ClearFocusDirs()
	end
end

function CraftingMenuPinBar:MakePageSpinner()
	local atlas = resolvefilepath(CRAFTING_ATLAS)

	local page_x = 3
	local arrow_scale = .5
	local is_left = self.crafting_hud.is_left_aligned

	local w = Widget("page_spinner_root")

	w.bg = w:AddChild(Image(atlas, "page_bg.tex"))
	w.bg:SetScale(is_left and 0.65 or -0.65, 0.65)
	w.bg:SetPosition(is_left and -1 or 1, 1)

    w.page_left = w:AddChild(ImageButton(atlas, "page_arrow.tex", "page_arrow_hl.tex",  nil, nil, nil, {1,1}, {0,0}))
	w.page_left:SetPosition(page_x-20, 1)
    w.page_left:SetScale(-arrow_scale, arrow_scale)
    w.page_left:SetOnClick(function() 
		self:GoToPrevPage(true)
	end)

    w.page_right = w:AddChild(ImageButton(atlas, "page_arrow.tex", "page_arrow_hl.tex", nil, nil, nil, {1,1}, {0,0}))
	w.page_right:SetPosition(page_x + 15, 1)
    w.page_right:SetScale(arrow_scale, arrow_scale)
    w.page_right:SetOnClick(function() 
		self:GoToNextPage(true)
	end)

	w.page_left_control = w:AddChild(Text(DEFAULTFONT, 22, TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_USEONSCENE)))
	w.page_left_control:Hide()
	w.page_left_control:SetPosition(page_x-20, 1)
	w.page_right_control = w:AddChild(Text(DEFAULTFONT, 22, TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_USEONSELF)))
	w.page_right_control:Hide()
	w.page_right_control:SetPosition(page_x + 15, 1)

	w.page_text = w:AddChild(Text(NUMBERFONT, 32, "1"))
	w.page_text:SetPosition(page_x, 1)

	w.ongainfocusfn = function()
		w:SetScale(1.2)
	end

	w.onlosefocusfn = function()
		w:SetScale(1)
	end

	w.Highlight = function(s) -- called from inventorybar
		if not s.focus then
			s:SetFocus()
		end
	end

	w.DeHighlight = function(s) -- called from inventorybar
		s:ClearFocus()
	end

	w.OnControl = function(s, control, down)
		if Image._base.OnControl(s, control, down) then return true end

		if down then
			if control == CONTROL_INVENTORY_USEONSCENE or (control == CONTROL_SCROLLBACK and not TheInput:ControllerAttached()) then
				self:GoToPrevPage()
				return true
			elseif control == CONTROL_INVENTORY_USEONSELF or (control == CONTROL_SCROLLFWD and not TheInput:ControllerAttached()) then
				self:GoToNextPage()
				return true
			end
		end
		
		return false
	end

	w.OnGainFocus = function(s)
		if self.crafting_hud:IsCraftingOpen() and TheInput:ControllerAttached() then
			s.page_left:Hide()
			s.page_right:Hide()

			s.page_left_control:Show()
			s.page_right_control:Show()
		end
	end

	w.OnLoseFocus = function(s)
		if self.crafting_hud:IsCraftingOpen() then
			s.page_left:Show()
			s.page_right:Show()

			s.page_left_control:Hide()
			s.page_right_control:Hide()
		end
	end

	return w
end

function CraftingMenuPinBar:RefreshPinnedRecipes()
	self.page_spinner.page_text:SetString(tostring(TheCraftingMenuProfile:GetCurrentPage()))

	local pinned_recipes = TheCraftingMenuProfile:GetPinnedRecipes()
	for i, pin in ipairs(self.pin_slots) do
		pin:OnPageChanged(pinned_recipes[i])
	end
end

function CraftingMenuPinBar:RefreshControllers(controller_mode)
	self.page_spinner.page_left_control:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_USEONSCENE))
	self.page_spinner.page_right_control:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_USEONSELF))

	if TheCraftingMenuProfile:GetCurrentPage() > Profile:GetCraftingNumPinnedPages() then
		if self.page_spinner ~= nil then
			self:GoToNextPage(true)
		end
	end

	for i = 1, #self.pin_slots do
		self.pin_slots[i]:RefreshControllers(controller_mode)
	end
end

function CraftingMenuPinBar:GoToNextPage(silent)
	TheCraftingMenuProfile:NextPage()
	self:RefreshPinnedRecipes()

	if TheInput:ControllerAttached() then
		if self.page_spinner.focus then
			self.owner.HUD.controls.inv:PinBarNav(self.page_spinner:FindPinDown())
		else
			local cur_slot = self:GetFocusSlot()
			if cur_slot ~= nil and not cur_slot:IsVisible() then
				self.owner.HUD.controls.inv:PinBarNav(cur_slot:FindPinDown() or cur_slot:FindPinUp() or self.page_spinner)
			end
		end
	end

	if not silent then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	end

	if not self.crafting_hud:IsCraftingOpen() then
		TheCraftingMenuProfile:Save()
	end
end

function CraftingMenuPinBar:GoToPrevPage(silent)
	TheCraftingMenuProfile:PrevPage()
	self:RefreshPinnedRecipes()

	if TheInput:ControllerAttached() then
		if self.page_spinner.focus then
			self.owner.HUD.controls.inv:PinBarNav(self.page_spinner:FindPinDown())
		else
			local cur_slot = self:GetFocusSlot()
			if cur_slot ~= nil and not cur_slot:IsVisible() then
				self.owner.HUD.controls.inv:PinBarNav(cur_slot:FindPinDown() or cur_slot:FindPinUp() or self.page_spinner)
			end
		end
	end

	if not silent then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	end

	if not self.crafting_hud:IsCraftingOpen() then
		TheCraftingMenuProfile:Save()
	end
end

function CraftingMenuPinBar:StartControllerNav() -- GetBottomMostButton
	local target_pin = nil
	for i = #self.pin_slots, 1, -1 do
		if self.pin_slots[i]:IsVisible() then
			target_pin = self.pin_slots[i]
			break
		end
	end

	if target_pin ~= nil then
		return target_pin
	end
end

function CraftingMenuPinBar:GetFirstButton()
	for i = 1, TUNING.MAX_PINNED_RECIPES do
		if self.pin_slots[i]:IsVisible() then
			return self.pin_slots[i]
		end
	end
end

function CraftingMenuPinBar:FindFirstUnpinnedSlot()
	for i = 1, TUNING.MAX_PINNED_RECIPES do
		if not self.pin_slots[i]:HasRecipe() then
			return self.pin_slots[i]
		end
	end
end

function CraftingMenuPinBar:GetFocusSlot()
	for i = 1, TUNING.MAX_PINNED_RECIPES do
		if self.pin_slots[i].focus then
			return self.pin_slots[i], i
		end
	end
end

function CraftingMenuPinBar:Refresh()
	local atlas = resolvefilepath(CRAFTING_ATLAS)

	local builder = self.owner ~= nil and self.owner.replica.builder or nil
	local prototyper = builder ~= nil and builder:GetCurrentPrototyper() or nil
	local prototyper_def = prototyper ~= nil and PROTOTYPER_DEFS[prototyper.prefab] or PROTOTYPER_DEFS.none
	self.open_menu_button.icon:SetTexture(prototyper_def.icon_atlas, prototyper_def.icon_image)

	self.page_spinner.page_text:SetString(tostring(TheCraftingMenuProfile:GetCurrentPage()))

	for i, pin in ipairs(self.pin_slots) do
		pin:Refresh()
	end
end

function CraftingMenuPinBar:OnControl(control, down)
    if CraftingMenuPinBar._base.OnControl(self, control, down) then return true end

	if down and not self.crafting_hud:IsCraftingOpen() then
		if control == CONTROL_INVENTORY_USEONSCENE then
			self:GoToPrevPage()
			return true
		elseif control == CONTROL_INVENTORY_USEONSELF then
			self:GoToNextPage()
			return true
		end

	end

	return false
end

function CraftingMenuPinBar:OnCraftingMenuOpen()
	for i, pin in ipairs(self.pin_slots) do
		pin:OnCraftingMenuOpen()
	end

	self:DoFocusHookups()
end

function CraftingMenuPinBar:OnCraftingMenuClose()
	for i, pin in ipairs(self.pin_slots) do
		pin:OnCraftingMenuClose()
	end

	self:ClearFocusHookups()
end

function CraftingMenuPinBar:RefreshCraftingHelpText(controller_id)
	local slot = self:GetFocusSlot()
	if slot ~= nil then
		return slot:RefreshCraftingHelpText(controller_id)
	end
	return ""
end

function CraftingMenuPinBar:OnGainFocus()
	if self.page_spinner ~= nil then
		if not self.crafting_hud:IsCraftingOpen() and TheInput:ControllerAttached() then
			self.page_spinner.page_left:Hide()
			self.page_spinner.page_right:Hide()

			self.page_spinner.page_left_control:Show()
			self.page_spinner.page_right_control:Show()
		else
			self.page_spinner.page_left:Show()
			self.page_spinner.page_right:Show()

			self.page_spinner.page_left_control:Hide()
			self.page_spinner.page_right_control:Hide()
		end
	end
end

function CraftingMenuPinBar:OnLoseFocus()
	if self.page_spinner ~= nil then
		if not self.crafting_hud:IsCraftingOpen() then
			self.page_spinner.page_left:Show()
			self.page_spinner.page_right:Show()

			self.page_spinner.page_left_control:Hide()
			self.page_spinner.page_right_control:Hide()
		end
	end
end

return CraftingMenuPinBar
