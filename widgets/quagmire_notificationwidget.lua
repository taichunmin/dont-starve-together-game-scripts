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

local TINT_GOOD = {239/255, 224/255, 196/255, 1}
local TINT_FAIL = {255/255, 155/255, 155/255, 1}

local NotificationWidget = Class(Widget, function(self, owner, centered_layout)
    Widget._ctor(self, "NotificationWidget")
	self:UpdateWhilePaused(false)
	self.owner = owner

	self.NUM_SLOTS = centered_layout and 1 or 5
	self.centered_layout = centered_layout

	self.slots = {}
	self.queue = {}

	if TheWorld ~= nil then
		self.inst:ListenForEvent("quagmire_notifyrecipeupdated", function(w, data) self:OnRecipeMade(data) end, TheWorld)
		self.inst:ListenForEvent("quagmire_recipeappraised", function(w, data) self:OnRecipeAppraised(data) end, TheWorld)
	end
end)

function NotificationWidget:OnRecipeMade(data)
	local is_new = true
	local params = {string = data.new_recipe and STRINGS.UI.HUD.QUAGMIRE_NOTFICATIONS.DISCOVERED or STRINGS.UI.HUD.QUAGMIRE_NOTFICATIONS.MADE}
	params.sfx = data.new_recipe and "dontstarve/quagmire/HUD/new_recipe" or "dontstarve/quagmire/HUD/meal_cooked"
	if data.dish ~= nil then

        local is_image_loaded = true
        if QUAGMIRE_USE_KLUMP then
            is_image_loaded = IsKlumpLoaded("images/quagmire_food_inv_images_hires_"..data.product..".tex")
        end

        if is_image_loaded and #data.ingredients > 0 then
			params.tint = TINT_GOOD
			params.icons = {
				{atlas = "images/quagmire_food_common_inv_images_hires.xml", texture = data.dish..".tex"},
				{atlas = "images/quagmire_food_inv_images_hires_"..data.product..".xml", texture = data.product..".tex"}
			}
		else
			params.sfx = "dontstarve/quagmire/HUD/failed_recipe"
			params.string = data.overcooked and STRINGS.UI.HUD.QUAGMIRE_NOTFICATIONS.OVERCOOKED or STRINGS.UI.HUD.QUAGMIRE_NOTFICATIONS.FAILED
			params.tint = TINT_FAIL
			params.icons = {
				{atlas = "images/quagmire_food_common_inv_images_hires.xml", texture = data.dish..".tex"},
				{atlas = "images/quagmire_food_common_inv_images_hires.xml", texture = (data.station=="pot" and "goop_" or "burnt_") .. data.dish .. ".tex"}
			}
		end
	else
		if not data.new_recipe then
			params.string = STRINGS.UI.HUD.QUAGMIRE_NOTFICATIONS.INGREDIENT_MADE
		end
		params.tint = TINT_GOOD
		params.icons = {
			{atlas = GetInventoryItemAtlas(data.product..".tex"), texture = data.product..".tex"},
		}
	end

    self:AddChild(self:BuildPopupWidget(params))
end

function NotificationWidget:OnRecipeAppraised(data)
	local params = {string = STRINGS.UI.HUD.QUAGMIRE_NOTFICATIONS.SENT}
	params.tint = TINT_GOOD
	params.sfx = "dontstarve/quagmire/HUD/recipe_sent"

	params.icons = {
		{atlas = "images/quagmire_food_common_inv_images_hires.xml", texture = data.dish..(data.silverdish and "_silver" or "")..".tex"},
		{atlas = "images/quagmire_food_inv_images_hires_"..data.product..".xml", texture = data.product..".tex"}
	}
	params.coins = data.coins

    self.inst:DoTaskInTime(2, function() self:AddChild(self:BuildPopupWidget(params)) end)
end

local function SetupCoins(coins, size, tint)
	local text_w = size
	local total_coin_size = size + text_w

	-- text, coin, ##, coin, ##, coin, ##, coin, ##
	local root = Widget("value_root")
	local width = 0
	local found_first = false
	for i = 1, 4 do
		local coin_num = 5 - i
		local coin_value = coins[coin_num]
		if coin_value ~= nil and (found_first or coin_value > 0) then
			--found_first = true
			local value = root:AddChild(Text(CHATFONT, size - 3, tostring(coin_value), tint))
			value:SetRegionSize(text_w, 28)
			value:SetHAlign(ANCHOR_RIGHT)
			value:SetPosition(width + text_w/2 , 0)

			local img_name =  "quagmire_coin"..tostring(coin_num)..".tex"
			local coin = root:AddChild(Image( GetInventoryItemAtlas(img_name), img_name))
			coin:ScaleToSize(size, size)
			coin:SetPosition(width + text_w + size/2, 1)
			coin:SetEffect("shaders/ui_cc.ksh")
			coin:SetClickable(false)

			width = width + total_coin_size
		end
	end

	return root, width
end

local function ShowPopup(self, root)
	local side_y_offset = 80
	local start_position = self.centered_layout and Vector3(root._dest_x, -50, 0) or Vector3(0, -side_y_offset*(root._slot_num - 1), 0)
	local dest_position = self.centered_layout and Vector3(root._dest_x, 100, 0) or Vector3(root._dest_x, -side_y_offset*(root._slot_num - 1), 0)
	root:SetPosition(start_position:Get())

	local function on_slideoutfn()
		local slot_num = root._slot_num
		self.slots[slot_num] = nil
		root:Kill()

		if #self.queue > 0 then
			local next = table.remove(self.queue, 1)
			next._slot_num = slot_num
			self.slots[slot_num] = next
			ShowPopup(self, next)
		end
	end

	local function on_slideinfn()
		if root._sfx ~= nil then
			TheFrontEnd:GetSound():PlaySound(root._sfx)
		end
		root.inst:DoTaskInTime(4,
			function()
				TheFrontEnd:GetSound():PlaySound("dontstarve/quagmire/HUD/slide_out")
				root:MoveTo(root:GetPosition(), start_position, .25, on_slideoutfn)
				end)
	end

	TheFrontEnd:GetSound():PlaySound("dontstarve/quagmire/HUD/slide_in")
	root:MoveTo(root:GetPosition(), dest_position, .5, on_slideinfn)
	root:Show()
end

local function AddIcons(root, data, x)
	local icon_size = data.icons ~= nil and 50 or 0
	local icon_padding = 5

	x = x + icon_size/2
	for _, icon in ipairs(data.icons or {}) do
		local icon = root:AddChild(Image(icon.atlas, icon.texture))
		icon:ScaleToSize(icon_size, icon_size)
		icon:SetPosition(x, 0)
		icon:SetEffect("shaders/ui_cc.ksh")
		icon:SetClickable(false)
	end
	x = x + icon_size/2
	x = x + icon_padding * 2

	return x
end

function NotificationWidget:BuildPopupWidget(data)
	local root = Widget("Notification Popup")
	local scale = 1.2
	root:SetScale(scale)

	root._sfx = data.sfx

	local x = 0


	local bg = nil
	if not self.centered_layout then
		x = 22 -- initial offset for the alpha portion of the image

		bg = root:AddChild(Image("images/quagmire_hud.xml", "quagmire_announcement_bg.tex"))
		local bg_w = bg:GetSize()
		bg:SetPosition(bg_w/2 - x, 0)
		bg:SetClickable(false)
	else
		x = -5

		bg = root:AddChild(Image("images/quagmire_hud.xml", "quagmire_announcement_bg_centered.tex"))
		bg:SetClickable(false)
		x = AddIcons(root, data,
		x)
	end

    local str = root:AddChild(Text(UIFONT, 21, nil, data.tint))
    str:SetTruncatedString(data.string, 200, nil, true)
	local str_w = str:GetRegionSize()

	if data.coins == nil then
		local underline = root:AddChild(Image("images/quagmire_hud.xml", "quagmire_announcement_linebreak.tex"))
		underline:SetClickable(false)
		underline:SetTint(unpack(data.tint))

		local line_w = underline:GetSize()
		local line_past = 4
		if str_w > (line_w - line_past) then
			str:SetPosition(x + str_w/2, 2)
			x = x + str_w
			underline:SetPosition(x -line_w/2 + line_past, -12)
			x = x + line_past
		else
			x = x + line_w/2
			underline:SetPosition(x, -12)
			str:SetPosition(x , 2)
			x = x + line_w/2 + line_past
		end
	else
		local coin, coin_w = SetupCoins(data.coins, 18, data.tint)
		coin = root:AddChild(coin)
		local max_w = math.max(str_w/2, coin_w/2)
		x = x + max_w
		str:SetPosition(x, 5)
		coin:SetPosition(x - coin_w/2 - 5, -15)
		x = x + max_w
	end

	if not self.centered_layout then
		x = AddIcons(root, data, x)
		root._dest_x = -x * scale
	else
		root._dest_x = (-x * scale) / 2
		bg:SetPosition(-root._dest_x, 0)
	end

	root:Hide()

	for i = 1, self.NUM_SLOTS do
		if self.slots[i] == nil then
			root._slot_num = i
			self.slots[i] = root

			ShowPopup(self, root)
			break
		end
	end

	if root._slot_num == nil then
		table.insert(self.queue, root)
	end

	return root
end

function NotificationWidget:OnControl(control, down)
    if NotificationWidget._base.OnControl(self, control, down) then return true end
end

return NotificationWidget
