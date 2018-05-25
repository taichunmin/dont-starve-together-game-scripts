-- Display a grid of account items for user to explore.
--
-- User can click on items to select them and make them usable in game (adds to user profile).
-- User can click on items to interact with them: buy or grind.

local BarterScreen = require "screens/redux/barterscreen"
local PurchasePackScreen = require "screens/redux/purchasepackscreen"
local ItemImage = require "widgets/redux/itemimage"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local SetPopupDialog = require "screens/redux/setpopupdialog"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/redux/popupdialog"

local TEMPLATES = require "widgets/redux/templates"

require("skinsutils")


local COMMERCE_WIDTH = 130
local COMMERCE_HEIGHT = 45

local ItemExplorer = Class(Widget, function(self, title_text, primary_item_type, item_table_getter, list_options)
    Widget._ctor(self, "ItemExplorer")

    assert(primary_item_type and primary_item_type ~= "")
    self.primary_item_type = primary_item_type
    self.item_table = item_table_getter
    if type(item_table_getter) == "function" then
        self.item_table = item_table_getter()
    end

    assert((list_options.activity_checker_fn==nil) == (list_options.activity_writer_fn==nil), "Set both or neither activity functions.")
    self.activity_checker_fn = list_options.activity_checker_fn
    self.activity_writer_fn = list_options.activity_writer_fn
    if not self.activity_checker_fn then
        -- By default, use the user profile.
        self.activity_checker_fn = function(item_key)
            return list_options.scroll_context.user_profile:GetCustomizationItemState(self.primary_item_type, item_key)
        end
        self.activity_writer_fn = function(item_data)
            list_options.scroll_context.user_profile:SetCustomizationItemState(item_data.item_blob.type, item_data.item_key, item_data.is_active)

            -- Once any item selection has changed, recache the selection.
            CacheCurrentVanityItems(list_options.scroll_context.user_profile)
        end
    end

	local contained_items = self:_CreateWidgetDataListForItems(self.item_table, self.primary_item_type, self.activity_checker_fn)

    -- Validate the first item and assume others have same setup.
    assert(contained_items)
    -- Empty input lists are handled with a dialog.
    if contained_items[1] then
        assert(contained_items[1].item_key ~= nil)
        assert(contained_items[1].is_active ~= nil or list_options.scroll_context.selection_type == nil)
    end

    self.selected_items = {}

    if #contained_items == 0 then
        -- We show all items even if the player hasn't unlocked them, so we
        -- should never show nothing.
        self.fail = self:AddChild(TEMPLATES.CurlyWindow(400, 200, title_text, nil, nil, STRINGS.UI.COLLECTIONSCREEN.FAILED_TO_LOAD))

        self.focus_forward = self.fail
    else
        self:_DoInit(title_text, contained_items, list_options)

        -- Ensure that anything passed in as active is setup correctly and a
        -- current item is selected (if possible).
        local last_item_key = GetMostRecentlySelectedItem(self.scroll_list.context.user_profile, self.primary_item_type)
        for i,w in ipairs(self.scroll_list:GetListWidgets()) do
            -- Don't call IsDataSelected here to avoid "clicking" on everything for
            -- no selection type.
            if w.data.is_active then
                -- Call directly through to click results to avoid toggling the
                -- item.
                self.selected_items[w.data.item_key] = true
                self:_UpdateClickedWidget(w)
                if w.data.item_key == last_item_key then
                    for j,receiver in ipairs(self.scroll_list.context.input_receivers) do
                        if receiver.OnClickedItem then
                            receiver:OnClickedItem(w.data, true)
                        end
                    end
                end
            end
        end

        self.header:SetFocusChangeDir(MOVE_DOWN, self.scroll_list)
        self.scroll_list:SetFocusChangeDir(MOVE_UP, self.header)
        self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.footer)
        self.footer:SetFocusChangeDir(MOVE_UP, self.scroll_list)

        self.focus_forward = self.scroll_list
    end
end)

local function IsDataSelected(context, item_data)
    return item_data.is_active or context.selection_type == nil
end


local function CountOwnedItems(item_list)
    local count = 0
    for i,item in ipairs(item_list) do
        if TheInventory:CheckOwnership(item.item_key) then
            count = count + 1
        end
    end
    return count
end

function ItemExplorer:_DoInit(title_text, contained_items, list_options)
    -- Add ourself to input receivers.
    list_options.scroll_context = list_options.scroll_context or {}
    list_options.scroll_context.input_receivers = list_options.scroll_context.input_receivers or {}

    if list_options.scroll_context.selection_type == nil then
        for i,item in ipairs(contained_items) do
            -- If no selection type, then everything is always active.
            item.is_active = true
        end
    end
    table.insert(list_options.scroll_context.input_receivers, self)

    -- Most cases should use our default implementation.
    if list_options.item_ctor_fn == nil then
        list_options.item_ctor_fn = function(context, index)
            return self:_CreateScrollingGridItem(
                context,
                index,
                list_options.widget_width,
                list_options.widget_height)
        end
    end

    -- Most cases should use our default implementation -- especially if using
    -- CreateScrollingGridItem.
    if list_options.apply_fn == nil then
        list_options.apply_fn = ItemExplorer._ApplyDataToWidget
    end

    -- Pad the scissor region to ensure embiggened items don't have ugly
    -- clipping.
    list_options.scissor_pad = list_options.scissor_pad or list_options.widget_width * 0.15

    -- Ensure full and empty screens look the same by always applying peek.
    list_options.peek_percent = 0.25

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(contained_items, list_options))

    local width,height = self.scroll_list:GetScrollRegionSize()
    local nudge_y = 25

    self.header = self:AddChild(Widget("header"))
    self.header:SetPosition(0, height/2 + nudge_y)

    -- Title is redundant, so omit it.
    --~ self.title = self.header:AddChild(Text(TITLEFONT, 35, title_text))
    --~ self.title:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
    --~ self.title:SetRegionSize(width, 50)
    --~ self.title:SetHAlign(ANCHOR_LEFT)

    self.progress = self.header:AddChild(Text(HEADERFONT, 25))
    self.progress:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.progress:SetRegionSize(width, 50)
    self.progress:SetHAlign(ANCHOR_RIGHT)
	self.progress:SetPosition(-10,0)
    self.progress:SetString(string.format("%d/%d", CountOwnedItems(contained_items), #contained_items))

    self.footer = self:AddChild(Widget("footer"))
    self.footer:SetPosition(10, -height/2 + 45)

    self.focus_label = self.footer:AddChild(Text(HEADERFONT, 25))
    self.focus_label:SetColour(UICOLOURS.GOLD_SELECTED)
    self.focus_label:SetHAlign(ANCHOR_LEFT)

    self.focus_rarity = self.footer:AddChild(Text(HEADERFONT, 20))
    self.focus_rarity:SetPosition(0,-25)
    self.focus_rarity:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
    self.focus_rarity:SetHAlign(ANCHOR_LEFT)

	self.ensemble_title = self.footer:AddChild(Text(HEADERFONT, 20))
    self.ensemble_title:SetPosition(0,-25)
    self.ensemble_title:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
    self.ensemble_title:SetHAlign(ANCHOR_RIGHT)

	self.collection_title = self.footer:AddChild(Text(HEADERFONT, 20))
    self.collection_title:SetPosition(0,-68)
    self.collection_title:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
    self.collection_title:SetHAlign(ANCHOR_LEFT)
    
    self.store_btn = self.footer:AddChild(ImageButton("images/frontend_redux.xml", "button_shop_vshort_normal.tex", "button_shop_vshort_hover.tex", "button_shop_vshort_disabled.tex", "button_shop_vshort_down.tex"))
    self.store_btn:SetOnClick( function() TheFrontEnd:FadeToScreen( TheFrontEnd:GetActiveScreen(), function() return PurchasePackScreen() end, nil ) end )
    self.store_btn:SetScale(0.5)
    self.store_btn:SetPosition(205,-23)
    
    self.divider_top = self.footer:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.divider_top:SetPosition(0,-50)
    self.divider_top:Hide()

    self.description = self.footer:AddChild(Text(CHATFONT, 20))
    self.description:SetPosition(0,-125)
    self.description:SetColour(UICOLOURS.WHITE)
    self.description:SetHAlign(ANCHOR_LEFT)
    self.description:SetVAlign(ANCHOR_TOP)
    self.description:EnableWordWrap(true)
    
    self.action_info = self.footer:AddChild(Text(CHATFONT, 16))
    self.action_info:SetPosition(0,-190)
    self.action_info:SetColour(UICOLOURS.HIGHLIGHT_GOLD)
    self.action_info:SetHAlign(ANCHOR_LEFT)
    self.action_info:SetVAlign(ANCHOR_BOTTOM)
    self.action_info:EnableWordWrap(true)
    
    self.divider_bottom = self.footer:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
    self.divider_bottom:SetPosition(0,-230)
    self.divider_bottom:Hide()
    
    if TheInput:ControllerAttached() then
        self.set_info_btn = { should_show_set_info = false }
        self.can_show_steam = false
    else
        self.interact_root = self.footer:AddChild(Widget("interact_root"))
        self.commerce = self.interact_root:AddChild(TEMPLATES.StandardButton(
                function()
                    self:_LaunchCommerce()
                end,
                "",
                {COMMERCE_WIDTH, COMMERCE_HEIGHT}
            ))
        self.commerce:SetTextSize(25)
        self.commerce:SetPosition(-width/2+COMMERCE_WIDTH/2,0)

		if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
			self.market_button = self.interact_root:AddChild(TEMPLATES.StandardButton(
					function()
						self:_ShowMarketplaceForInteractTarget()
					end,
                    nil,
                    {COMMERCE_WIDTH, COMMERCE_HEIGHT},
                    {"images/button_icons.xml", "steam.tex"}
				))
			self.market_button:SetPosition(width/2-COMMERCE_WIDTH/2,0)
		end

        self.set_info_btn = self.interact_root:AddChild(TEMPLATES.StandardButton(
                function()
                    self:_ShowItemSetInfo()
                end,
                STRINGS.UI.COLLECTIONSCREEN.SET_INFO,
                {COMMERCE_WIDTH, COMMERCE_HEIGHT}
            ))
        self.set_info_btn:SetPosition(0,0)
        self.set_info_btn:Hide()

        self.interact_root:Hide()
    end

    
    self:RepositionFooter(self, -height/2 - 30, width)
end

function ItemExplorer:_ShowMarketplaceForInteractTarget()
	if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then --just in-case another platform calls this somehow.
	    local item_key = self.last_interaction_target.item_key
	    VisitURL("https://steamcommunity.com/market/listings/322330/".. string.upper(item_key))
	end
end

function ItemExplorer:RepositionFooter(new_parent, y, footer_width)
    if self.footer then
        new_parent:AddChild(self.footer)
        self.footer:SetPosition(0, y)

        self.focus_label:SetRegionSize(footer_width, 40)
        self.focus_rarity:SetRegionSize(footer_width, 30)
        self.ensemble_title:SetRegionSize(footer_width, 30)
        self.collection_title:SetRegionSize(footer_width, 30)
        self.description:SetRegionSize(footer_width, 130)
        self.action_info:SetRegionSize(footer_width, 60)
        self.divider_top:ScaleToSize(footer_width, 5)
        self.divider_bottom:ScaleToSize(footer_width, 5)

        if self.interact_root then
            self.interact_root:SetPosition(0, -260)
            self.commerce:ForceImageSize(COMMERCE_WIDTH, COMMERCE_HEIGHT)
            if self.market_button then
				self.market_button:ForceImageSize(COMMERCE_WIDTH, COMMERCE_HEIGHT)
			end
            self.set_info_btn:ForceImageSize(COMMERCE_WIDTH, COMMERCE_HEIGHT)
            
            self.commerce:SetPosition(-footer_width/2+COMMERCE_WIDTH/2,0)
            if self.market_button then
	            self.market_button:SetPosition(footer_width/2-COMMERCE_WIDTH/2,0)
			end
            self.set_info_btn:SetPosition(0,0)
        end
    end
end

function ItemExplorer:OnGainGridItemFocus(item_data)
end

function ItemExplorer:_ApplyDataToDescription(item_data)
    if item_data and item_data.item_key then
        local item_key = item_data.item_key
        -- Could use SetTruncatedString. SkinsScreen used:
        --~     self.details_panel.name:SetTruncatedString(nameStr, 220, 50, true)
        --~     self.details_panel.description:SetMultilineTruncatedString(GetSkinDescription(item_type), 7, 180, 60, true)
        self.focus_label:SetString(GetSkinName(item_key))
        self.focus_rarity:SetString(GetModifiedRarityStringForItem(item_key))
        self.focus_rarity:SetColour(GetColorForItem(item_key))
        
        local sd = GetSkinDescription(item_key)
        self.description:SetString(sd)
        local _, line_count = sd:gsub('\n', '\n')
        if line_count < 5 then
			self.description:SetSize(20)
        elseif line_count == 5 then
			self.description:SetSize(18)
		else
			print("Whoa! Why so much text?")
			self.description:SetSize(14)
		end
        self.action_info:SetString(self:_GetActionInfoText(item_data))
        self.divider_top:Show()
        self.divider_bottom:Show()
    else
        self.focus_label:SetString()
        self.focus_rarity:SetString()
        self.description:SetString()
        self.action_info:SetString()
        self.divider_top:Hide()
        self.divider_bottom:Hide()
    end
end

function ItemExplorer:OnLoseGridItemFocus(item_data)
end

function ItemExplorer:_SetItemActiveFlag(item_data, is_active)
    item_data.is_active = is_active
    assert(self.scroll_list.context.selection_type, "Why save data if we'll never use it?")
    self.activity_writer_fn(item_data)

    self.selected_items[item_data.item_key] = is_active or nil
end

local function GetCommerceText(item_data)
    if item_data.is_owned then
        return STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND
    else
        return STRINGS.UI.BARTERSCREEN.COMMERCE_BUY
    end
end

function ItemExplorer:_GetActionInfoText(item_data)

    local text = ""

    if item_data.is_owned then
        if IsUserCommerceAllowedOnItem(item_data.item_key) then
            local doodad_value = TheItems:GetBarterSellPrice(item_data.item_key)
            text = subfmt(STRINGS.UI.BARTERSCREEN.COMMERCE_INFO_GRIND, {doodad_value=doodad_value})
        else
            text = STRINGS.UI.BARTERSCREEN.COMMERCE_INFO_NOGRIND
        end
    else 
        if IsUserCommerceAllowedOnItem(item_data.item_key) then
            local doodad_value = TheItems:GetBarterBuyPrice(item_data.item_key)
            text = subfmt(STRINGS.UI.BARTERSCREEN.COMMERCE_INFO_BUY, {doodad_value=doodad_value})
        else
            text = STRINGS.UI.BARTERSCREEN.COMMERCE_INFO_NOBUY
        end
    end
    
    if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
		if not IsItemMarketable(item_data.item_key) then
			text = text.."\n"..STRINGS.UI.BARTERSCREEN.NO_MARKET
		end
	end

    return text
end

function ItemExplorer:_ApplyItemToCommerce(item_data)
    self.can_do_commerce = IsUserCommerceAllowedOnItem(item_data.item_key)
    if not self.interact_root then
        return
    end

    self.interact_root:Show()
    self.commerce:SetText(GetCommerceText(item_data))

    if self.can_do_commerce then
        self.commerce:Enable()
    else
        self.commerce:Disable()
    end
end

function ItemExplorer:_ApplyItemToMarket(item_data)
    self.can_do_market = IsItemMarketable(item_data.item_key)
    if not self.interact_root or self.market_button == nil then
        return
    end

    self.interact_root:Show()

    if self.can_do_market then
        self.market_button:Show()
    else
        self.market_button:Hide()
    end
end

function ItemExplorer:_LaunchCommerce()
    local item_key = self.last_interaction_target.item_key
	if WillUnravelBreakEnsemble( item_key ) then
        local _, reward_item = IsItemInCollection(item_key)
        local body = subfmt(STRINGS.UI.BARTERSCREEN.UNRAVEL_WARNING_BODY, {ensemble_name=STRINGS.SET_NAMES[reward_item], reward_name=GetSkinName(reward_item)})
        
		TheFrontEnd:PushScreen(PopupDialogScreen(
			STRINGS.UI.BARTERSCREEN.UNRAVEL_WARNING_TITLE,
			body,
			{{ text = STRINGS.UI.BARTERSCREEN.OK, cb = function() TheFrontEnd:PopScreen() self:_DoCommerce(item_key) end },
			 { text = STRINGS.UI.BARTERSCREEN.CANCEL, cb = function() TheFrontEnd:PopScreen() end }}))
		return
	else
		self:_DoCommerce(item_key)
	end
end

function ItemExplorer:_DoCommerce(item_key)
	local is_buying = not self.last_interaction_target.is_owned
    local barter_screen = BarterScreen(self.scroll_list.context.user_profile, self, item_key, is_buying, function()
        -- We completed a barter and now our screens contain old inventory data.

        if not is_buying and self.last_interaction_target.owned_count <= 1 then
            -- Selling our last one. Fake a click to turn it off. We can't
            -- click the widget because the interaction target may not be on
            -- screen (and thus not in a widget).
            local is_active = false
            local data = self.last_interaction_target

            -- Ensures other collection screens don't think this item is
            -- active.
            if self.scroll_list.context.selection_type then
                self:_SetItemActiveFlag(data, is_active)
            end

            -- Copied from SetOnClick. Removes item from preview on single
            -- selection screens.
            for i,receiver in ipairs(self.scroll_list.context.input_receivers) do
                if receiver.OnClickedItem then
                    receiver:OnClickedItem(data, is_active)
                end
            end
        end

        -- Cache because last_ will be cleared.
        local purchased_widget = self.last_interaction_target and self.last_interaction_target.widget or nil --guarded because we could have refreshed and lost the last_interaction_target if a refresh happened on the same frame as creating the screen.
        -- Tell parent to update as needed.
        self.scroll_list.context.owner:RefreshInventory(true)
        -- Take care of our own update.
        self:RefreshItems()
        if is_buying
			and purchased_widget ~= nil
            and purchased_widget.data.is_owned
            and purchased_widget.PlayUnlock
            then
            purchased_widget:PlayUnlock()
        end
    end)
    TheFrontEnd:PushScreen(barter_screen)
end

function ItemExplorer:_ShowItemSetInfo()
    self.set_info_screen = SetPopupDialog(self.set_info_btn.set_item_type)
    TheFrontEnd:PushScreen(self.set_info_screen)
end

function ItemExplorer:RefreshItems(new_item_filter_fn)
    if not self.scroll_list then
        -- Failed initial load, so don't try to refresh.
        return
    end

    -- Clear old selections.
    --
    local prev_target_key = nil
    if self.last_interaction_target then
        prev_target_key = self.last_interaction_target.item_key
    end
    self.last_interaction_target = nil
    self.selected_items = {}
    self:_UpdateItemSetInfo(nil)
    self:_ApplyDataToDescription()
    if self.interact_root then
        self.interact_root:Hide()
    end

    local contained_items = self:_CreateWidgetDataListForItems(self.item_table, self.primary_item_type, self.activity_checker_fn)
    self.item_filter_fn = new_item_filter_fn or self.item_filter_fn
    if self.item_filter_fn then
        local filtered_items = {}
        for i,item_data in ipairs(contained_items) do
            if self.item_filter_fn(item_data.item_key) then
                table.insert(filtered_items, item_data)
            end
        end
        contained_items = filtered_items
    end
    for i,item_data in ipairs(contained_items) do
        if item_data.is_active then
            self.selected_items[item_data.item_key] = true
        end
    end
    self.progress:SetString(string.format("%d/%d", CountOwnedItems(contained_items), #contained_items))
    self.scroll_list:SetItemsData(contained_items)


    -- Restore previous selection (good to show nice text when first loading
    -- the screen). We don't scroll to the item and only select items that are
    -- currently in a widget (visible-ish), so it's quite possible we click
    -- nothing.

    -- Be conservative: avoid clearing unowned preview side effect when
    -- changing filters. Not strictly necessary, but avoids user surprises.
    local can_click_without_side_effects = self.scroll_list.context.selection_type == nil

    if prev_target_key then
        prev_target_key = {[prev_target_key] = true}

    elseif can_click_without_side_effects and GetTableSize(self.selected_items) > 0 then
        prev_target_key = self.selected_items

    elseif can_click_without_side_effects and #contained_items > 0 then
        prev_target_key = {[contained_items[1].item_key] = true}

    end
    if prev_target_key then
        for i,w in ipairs(self.scroll_list:GetListWidgets()) do
            if w.data.item_key then
                if prev_target_key[w.data.item_key] then
                    -- Double click to preserve selection state.
                    w:onclick()
                    w:onclick()
                    break
                end
            end
        end
    end
end

function ItemExplorer:_OnClickWidget(item_widget)
    local item_data = item_widget.data
	
	--print("ItemExplorer:_OnClickWidget", item_data.item_key, item_data.is_owned, item_data.is_active)
	
    -- if no selection type, then ignore is_active.
    if self.scroll_list.context.selection_type and item_data.is_owned then
        self:_SetItemActiveFlag(item_data, not item_data.is_active)
    end

    if self.last_interaction_target then
        self.last_interaction_target.is_interaction_target = false

        -- Having a last_interaction_target doesn't mean there's an associated
        -- widget! The widget could have scrolled off the screen. We don't care
        -- because this update won't change its state.
        self.last_interaction_target.widget:UpdateSelectionState()
    end
    self.last_interaction_target = item_data
    assert(self.last_interaction_target.widget == item_widget)
    self.last_interaction_target.is_interaction_target = true
    self:_ApplyItemToCommerce(self.last_interaction_target)
    self:_ApplyItemToMarket(self.last_interaction_target)
    self:_ApplyDataToDescription(item_data)

    self:_UpdateClickedWidget(item_widget)
end
    
function ItemExplorer:_UpdateClickedWidget(item_widget)
	--print("ItemExplorer:_UpdateClickedWidget(item_widget)", item_widget.data.item_key)
    if item_widget.data.item_key == nil then
        -- Ignore empty widgets.
        return
    end
    if self.scroll_list.context.selection_type == "single"              -- only want one
        and IsDataSelected(self.scroll_list.context, item_widget.data)  -- selected new one
        and item_widget.data.is_owned -- previewing unowned items doesn't invalidate old selection
        then                                                            -- must unselect old one
        local prev_key = nil
        -- Both keys are in selected_items, so search for the old one.
        for item_key,_ in pairs(self.selected_items) do
            if item_key ~= item_widget.data.item_key then
                prev_key = item_key
                break
            end
        end
        if prev_key then
            -- We have the key so find the corresponding data.
            local prev_data = nil
            for i,item_data in ipairs(self.scroll_list.items) do
                if item_data.item_key == prev_key then
                    prev_data = item_data
                    break
                end
            end
            if prev_data and prev_data ~= item_widget.data then
                self:_SetItemActiveFlag(prev_data, false)
                if prev_data.widget then -- could have scrolled off screen?
					prev_data.widget:UpdateSelectionState()
				end
            end
        end
    end
    item_widget:UpdateSelectionState()
end

function ItemExplorer:OnClickedItem(item_data, is_selected)
    self:_UpdateItemSetInfo(item_data.item_key)

    if item_data.item_key then
        if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
            self.can_show_steam = IsItemMarketable(item_data.item_key)
        else
            self.can_show_steam = false
        end

        -- Assumes purchaseable items are not marketable!
        self.can_show_pack = GetPackForItem(item_data.item_key)

    else
        self.can_show_steam = false
        self.can_show_pack = false
    end
end

function ItemExplorer:_UpdateItemSetInfo(item_key)
    local item_type = item_key
    local pack = item_key and GetPackForItem(item_key) or nil
    
    local collection = GetItemCollectionName(item_key)
    if collection then
        self.collection_title:SetString(collection)
        self.collection_title:Show()
        self.description:SetPosition(0,-145)
    else
        self.collection_title:Hide()
        self.description:SetPosition(0,-125)
    end
    
    local in_ensemble = false
    local set_reward_type = ""
    in_ensemble, set_reward_type = IsItemInCollection(item_type)
	if in_ensemble then
        self.set_info_btn.should_show_set_info = true
		self.ensemble_title:Show()
        if GetPackForItem(item_key) then
            self.ensemble_title:SetPosition(-60,-25)
            self.store_btn:Show()
        else
            self.ensemble_title:SetPosition(0,-25)
            self.store_btn:Hide()
        end
		
		if IsItemIsReward(item_type) then
			self.ensemble_title:SetString(STRINGS.SET_NAMES[item_type] .. " " .. STRINGS.UI.SKINSSCREEN.BONUS)
			
			self.set_info_btn.set_item_type = item_type --save it for the click press
		else
			self.ensemble_title:SetString(STRINGS.SET_NAMES[set_reward_type] .. " " .. STRINGS.UI.SKINSSCREEN.SET_PROGRESS)
			self.set_info_btn.set_item_type = set_reward_type --save it for the click press
		end
    elseif pack then
        -- Don't show the more info button. They should go to the store to find
        -- it.
        self.set_info_btn.should_show_set_info = false

        if GetPackForItem(item_type) then
            self.ensemble_title:SetPosition(-60,-25)
            self.store_btn:Show()
        else
            self.ensemble_title:SetPosition(0,-25)
            self.store_btn:Hide()
        end
        self.ensemble_title:Show()
        self.ensemble_title:SetString(STRINGS.SKIN_NAMES[pack])
        self.set_info_btn.set_item_type = pack
    else
        self.set_info_btn.should_show_set_info = false
        self.ensemble_title:Hide()
        self.ensemble_title:SetPosition(0,-25)
        self.store_btn:Hide()
    end

    if self.interact_root then
        if self.set_info_btn.should_show_set_info then
            self.set_info_btn:Show()
        else
            self.set_info_btn:Hide()
        end
    end
end

-- Returns a table of item_key -> true/nil
-- (Using nil so you can iterate the table for all selected items.)
function ItemExplorer:GetSelectedItems()
    assert(not self.scroll_list or self.scroll_list.context.selection_type, "Selection is ignored unless we have a selection_type.")
    return self.selected_items
end


function ItemExplorer:_CreateScrollingGridItem(context, scroll_index, width, height)
    local w = ItemImage(context.user_profile, context.screen)
    w.data = {}
    w.scroll_index = scroll_index

    local spacing = 10
    local x = width - spacing
    local y = height - spacing

    w:ScaleToSize(x,y)
    w.ongainfocusfn = function()
        self.scroll_list:OnWidgetFocus(w)
        for i,receiver in ipairs(context.input_receivers) do
            if receiver.OnGainGridItemFocus then
                receiver:OnGainGridItemFocus(w.data)
            end
        end
    end
    w.onlosefocusfn = function()
        for i,receiver in ipairs(context.input_receivers) do
            if receiver.OnLoseGridItemFocus then
                receiver:OnLoseGridItemFocus(w.data)
            end
        end
    end
    w:SetOnClick(function()
        -- Only act on widgets containing valid data.
        if w.data.item_key then
            for i,receiver in ipairs(context.input_receivers) do
                -- Most users shouldn't implement this.
                if receiver._OnClickWidget then
                    receiver:_OnClickWidget(w)
                end
            end
            for i,receiver in ipairs(context.input_receivers) do
                -- Most users will want this instead.
                if receiver.OnClickedItem then
                    receiver:OnClickedItem(w.data, IsDataSelected(context, w.data))
                end
            end
        end
    end)

    w.UpdateSelectionState = function(w_self)
        local item_data = w_self.data
        w_self:SetInteractionState(IsDataSelected(context, item_data), item_data.is_owned, item_data.is_interaction_target, IsUserCommerceBuyAllowedOnItem(item_data.item_key), item_data.is_perm_owned)
    end

    return w
end

-- static!
function ItemExplorer._ApplyDataToWidget(context, widget, data, index)
    -- data will sometimes be nil!
    if data then
        widget.data = data
        widget.data.widget = widget
    else
        -- A lot of code doesn't check if there is a data, it just assumes it
        -- exists. Instead, check for item_key for validity.
        widget.data = {}
    end
    if widget.bg then
        -- Composite button-based widget
        widget.bg:ApplyDataToWidget(context, data, index)
    else
        -- ItemImage
        widget:ApplyDataToWidget(context, data, index)
    end
    if data then
        widget:UpdateSelectionState()
    end
end

function ItemExplorer:_CreateWidgetDataListForItems(item_table, item_type, activity_checker_fn)
    local contained_items = {}
    for item_key,item_blob in pairs(item_table) do
        if item_blob.type == item_type and ShouldDisplayItemInCollection(item_key) then
            local is_owned,timestamp = TheInventory:CheckOwnershipGetLatest(item_key)
            local data = {
                item_key = item_key,
                is_active = is_owned and activity_checker_fn(item_key) or false,
                acquire_timestamp = timestamp,
                is_owned = is_owned,
                owned_count = TheInventory:GetOwnedItemCount(item_key),
                item_blob = item_blob,
                is_perm_owned = GetIsPermOwned(item_key),
            }
            table.insert(contained_items, data)
        end
    end
    table.sort(contained_items, function(a,b)
        return CompareItemDataForSort(a.item_key, b.item_key, item_table)
    end)
    return contained_items
end

function ItemExplorer:OnControl(control, down)
	if ItemExplorer._base.OnControl(self, control, down) then return true end

    if self.last_interaction_target then
        if not down and control == CONTROL_INSPECT then 
            -- A bit confusing because interaction target doesn't move with
            -- focus! Could click focused widget automatically, but that's
            -- inconsistent with mouse controls.
            if self.can_do_commerce then
                self:_LaunchCommerce()
                return true
            end
        elseif not down and control == CONTROL_PAUSE and TheInput:ControllerAttached() then
            -- Hitting Esc fires both Pause and Cancel, so keyboard users will
            -- need to click buttons instead.
			if self.can_show_steam then
                self:_ShowMarketplaceForInteractTarget()
                return true
            elseif self.can_show_pack then
                TheFrontEnd:FadeToScreen( TheFrontEnd:GetActiveScreen(), function() return PurchasePackScreen() end, nil )
                return true
			end
        elseif not down and control == CONTROL_MAP then
            if self.set_info_btn.should_show_set_info then
                self:_ShowItemSetInfo()
            end
        end
    end
end

function ItemExplorer:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if self.last_interaction_target then
        if self.can_do_commerce then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. GetCommerceText(self.last_interaction_target))
        end

        if self.set_info_btn.should_show_set_info then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP) .. " " .. STRINGS.UI.COLLECTIONSCREEN.SET_INFO)
        end

		if self.can_show_steam then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.COLLECTIONSCREEN.VIEW_MARKET)
        elseif self.can_show_pack then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE)
		end
    end

    return table.concat(t, "  ")
end

return ItemExplorer
