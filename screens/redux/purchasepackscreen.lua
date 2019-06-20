local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local OnlineStatus = require "widgets/onlinestatus"
local PopupDialogScreen = require "screens/redux/popupdialog"
local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local ItemBoxOpenerPopup = require "screens/redux/itemboxopenerpopup"

local TEMPLATES = require("widgets/redux/templates")
require("misc_items")

-------------------------------------------------------------------

local FILTER_OWNED_INDEX = 1
local FILTER_TYPE_INDEX = 2
local FILTER_DISCOUNT_INDEX = 3



local function itemKeyIsCharacter(initial_item_key)
    return table.contains(DST_CHARACTERLIST, initial_item_key)
end

local add_details = function ( self, proot, fontsize )
        
    self.root = proot:AddChild(Widget("purchase_dialog_root"))

    self.icon_root = self.root:AddChild(Widget("icon_root"))
	self.icon_root:SetPosition(-150, 0)

	self.icon_anim = self.icon_root:AddChild(UIAnim())
	self.icon_anim:GetAnimState():SetBuild("frames_comp")
	self.icon_anim:GetAnimState():SetBank("fr")
	self.icon_anim:GetAnimState():Hide("frame")
	self.icon_anim:GetAnimState():Hide("NEW")
	self.icon_anim:GetAnimState():PlayAnimation("icon")
	self.icon_anim:SetScale(1.75)

    self.icon_glow = self.icon_root:AddChild(Image("images/global_redux.xml", "shop_glow.tex"))
    self.icon_glow2 = self.icon_root:AddChild(Image("images/global_redux.xml", "shop_glow.tex"))

    self.icon_glow:RotateTo( 0, 0.8, 0.3, nil, true )
    self.icon_glow2:RotateTo( 0, -0.35, 0.3, nil, true )

    self.icon_image = self.icon_root:AddChild(Image())
    self.icon_image:SetScale(0.35)

    self.text_root = self.root:AddChild(Widget("text_root"))
    self.title = self.text_root:AddChild(Text(HEADERFONT, 25*fontsize, nil, UICOLOURS.GOLD_SELECTED))
    self.collection = self.text_root:AddChild(Text(CHATFONT, 17*fontsize, nil, UICOLOURS.BLUE))
    self.text = self.text_root:AddChild(Text(HEADERFONT, 16*fontsize, nil, UICOLOURS.GOLD_UNIMPORTANT))
    self.price = self.text_root:AddChild(Text(HEADERFONT, 28*fontsize, nil, UICOLOURS.GOLD_FOCUS))
    self.oldprice = self.text_root:AddChild(Text(HEADERFONT, 15*fontsize, nil, { 123 / 255, 105 / 255, 61 / 255, 1 } ))
    self.oldprice_line = self.text_root:AddChild(Image("images/global_redux.xml", "shop_crossed_price.tex"))
    self.expire_txt = self.text_root:AddChild(Text(HEADERFONT, 15*fontsize, nil, UICOLOURS.GOLD_UNIMPORTANT))
    self.savings_frame = self.text_root:AddChild(Image("images/global_redux.xml", "shop_discount.tex"))
    self.savings = self.text_root:AddChild(Text(HEADERFONT, 15*fontsize, nil, UICOLOURS.BLACK ))
    self.sale_frame = self.text_root:AddChild(Image("images/global_redux.xml", "shop_sale_tag.tex"))
    self.sale_txt = self.text_root:AddChild(Text(HEADERFONT, 19*fontsize, nil, UICOLOURS.BLACK ))

    return self.root
end

local purchasefn = 
    function( self, item_type_purchased, sale_percent_purchased )
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/purchase")

        local commerce_popup = GenericWaitingPopup("ItemServerContactPopup", STRINGS.UI.ITEM_SERVER.CONNECT, nil, true)
        TheFrontEnd:PushScreen(commerce_popup)

        TheItems:StartPurchase(item_type_purchased, sale_percent_purchased, function(success, message)
            self.inst:DoTaskInTime(0, function()  --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                commerce_popup:Close()
                if success then
                    local display_items = GetPurchasePackDisplayItems(item_type_purchased)
                    local options = {
                        allow_cancel = false,
                        box_build = GetBoxBuildForItem(item_type_purchased),
                    }
                        
                    local box_popup = ItemBoxOpenerPopup(options, function(success_cb)
                        success_cb(display_items)
                    end)
                    TheFrontEnd:PushScreen(box_popup)

                elseif message == "CANCELLED" then
                    -- If the user just cancelled, then everything's fine.

                else
                    local body_text = STRINGS.UI.ITEM_SERVER[message] or STRINGS.UI.ITEM_SERVER.FAILED_DEFAULT
                    local server_error = PopupDialogScreen(STRINGS.UI.ITEM_SERVER.FAILED_TITLE, body_text,
                        {
                            {
                                text=STRINGS.UI.TRADESCREEN.OK,
                                cb = function()
                                    print("ERROR: Failed to contact the item server.", message )
                                    TheFrontEnd:PopScreen()
                                    if message == "FAILED_DEFAULT" then
                                        SimReset()
                                    end
                                end
                            }
                        }
                        )
                    TheFrontEnd:PushScreen( server_error )
                end
            end, self)
        end)
    end

local onPurchaseClickFn =
    function( self )
        local restricted_pack, missing_character = IsPackRestrictedDueToOwnership(self.item_type)
        
        local item_type_purchased = self.item_type --need to save a copy of this for the callback function because the UI could update on us, and item_type could change.
        local sale_percent_purchased = self.sale_percent --need to save a copy of this for the callback function because the UI could update on us, and sale_percent could change.

        if restricted_pack then
            DisplayCharacterUnownedPopupPurchase(missing_character, self.screen_self)
        else
            if OwnsSkinPack(self.item_type) then
                local warning = PopupDialogScreen(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_TITLE, STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_DESC, 
                            {
                                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_OK, cb = function() 
                                    TheFrontEnd:PopScreen()
                                    purchasefn( self, item_type_purchased, sale_percent_purchased ) 
                                end },
                                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_CANCEL, cb = function() 
                                    TheFrontEnd:PopScreen()
                                end },
                            })
                TheFrontEnd:PushScreen( warning )    
            else
                purchasefn( self, item_type_purchased, sale_percent_purchased )
            end
        end
    end

local set_data =
    function ( self, iap_def )
        self.item_type = iap_def.item_type
        

        local title = GetSkinName(self.item_type)
        self.title:SetString(title)
        
        local collection = GetPackCollection(self.item_type)
        self.collection:SetString(collection)


        local sale_active, sale_duration = IsSaleActive(iap_def)

        local savings = 0 
        local is_pack_bundle, total_value = IsPackABundle(self.item_type)
        if is_pack_bundle then
            local total_value_str = BuildPriceStr( total_value, iap_def.currency_code )
            self.oldprice:SetString( total_value_str )
            savings = GetPackSavings(iap_def, total_value, sale_active)
        else
            local original_price_str = BuildPriceStr( iap_def, iap_def.currency_code, false )
            self.oldprice:SetString( original_price_str )
        end

        
        if sale_active then
            self.price:SetString( BuildPriceStr( iap_def, iap_def.currency_code, true ) )

            self.sale_frame:Show()
            self.sale_txt:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.SALE_TXT, { sale_percent = tostring(iap_def.sale_percent) }) )
            self.sale_txt:Show()

            self.sale_percent = iap_def.sale_percent
            
            local expire_str = ""
            local day_time   = 60 * 60 * 24 * 2
            local hours_time = 60 * 60 * 24
            local hour_time = 60 * 60 * 2
            local soon_time  = 60 * 60 * 1
            
            if sale_duration < soon_time then
                expire_str = STRINGS.UI.PURCHASEPACKSCREEN.EXPIRE_SOON_TXT

            elseif sale_duration < hour_time then
                expire_str = STRINGS.UI.PURCHASEPACKSCREEN.EXPIRE_HOUR_TXT

            elseif sale_duration < hours_time then
                local hours = math.floor( sale_duration / (60 * 60) )
                expire_str = subfmt(STRINGS.UI.PURCHASEPACKSCREEN.EXPIRE_HOURS_TXT, { hours = hours })

            elseif sale_duration < day_time then
                expire_str = STRINGS.UI.PURCHASEPACKSCREEN.EXPIRE_DAY_TXT

            else
                local days = math.floor( sale_duration / (60 * 60 * 24) )
                expire_str = subfmt(STRINGS.UI.PURCHASEPACKSCREEN.EXPIRE_DAYS_TXT, { days = days })
            end
            self.expire_txt:SetString( expire_str )
            self.expire_txt:Show()

            self.oldprice:Show()
            self.oldprice_line:Show()

            if savings > 0 then
                self.savings:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.PACK_SAVINGS, { savings = savings }) )
                self.savings:Show()
                self.savings_frame:Show()
            else
                self.savings:Hide()
                self.savings_frame:Hide()
            end
        else
            self.price:SetString( BuildPriceStr( iap_def, iap_def.currency_code, false ) )

            self.sale_percent = 0

            if savings > 0 then
                self.savings:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.PACK_SAVINGS, { savings = savings }) )
                self.savings:Show()
                self.savings_frame:Show()

                self.oldprice:Show()
                self.oldprice_line:Show()
            else
                self.savings:Hide()
                self.savings_frame:Hide()

                self.oldprice:Hide()
                self.oldprice_line:Hide()
            end

            self.sale_frame:Hide()
            self.sale_txt:Hide()
            self.expire_txt:Hide()
        end

        local total_items = GetPackTotalItems(self.item_type)
        local total_sets = GetPackTotalSets(self.item_type)
        if total_sets > 1 then
            -- megapack!
            self.text:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.MEGAPACK_SHORT_DESC, { total_items = total_items, total_sets = total_sets }) )
        else
            self.text:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.PACK_SHORT_DESC, { total_items = total_items }) )
        end

        self.icon_image:Hide()
        self.icon_anim:Hide()
        local image = GetPurchaseDisplayForItem(self.item_type)
        if image then
            self.icon_image:SetTexture(unpack(image))
            self.icon_image:Show()
        else
            self.icon_anim:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(self.item_type), "SWAP_ICON")
            self.icon_anim:Show()
        end

        self.title:SetHAlign(ANCHOR_LEFT)
        self.title:SetVAlign(ANCHOR_MIDDLE)
        self.text:SetHAlign(ANCHOR_LEFT)
        self.text:SetVAlign(ANCHOR_MIDDLE)
        self.collection:SetHAlign(ANCHOR_LEFT)
        self.collection:SetVAlign(ANCHOR_TOP)
        self.price:SetHAlign(ANCHOR_LEFT)
        self.price:SetVAlign(ANCHOR_BOTTOM)
        self.oldprice:SetHAlign(ANCHOR_LEFT)
        self.oldprice:SetVAlign(ANCHOR_BOTTOM)
        self.expire_txt:SetHAlign(ANCHOR_RIGHT)
        self.expire_txt:SetVAlign(ANCHOR_BOTTOM)
    end

-------------------------------------------------------------------

local PurchasePackPopup = Class(Screen, function(self, iap_def, screen_self)
    Screen._ctor(self, "PurchasePackPopup")
    
    self.screen_self = screen_self
    self.black = self:AddChild( TEMPLATES.BackgroundTint() )
    self.proot = self:AddChild( TEMPLATES.ScreenRoot() )

    add_details( self, self.proot, 1.8 )
    self.root:SetScale(0.75)

    self.dialog = self.root:AddChild( TEMPLATES.CurlyWindow( 1200, 800 ) )
    self.dialog:MoveToBack()

    self.default_focus = self.dialog

    self.desc = self.text_root:AddChild(Text(CHATFONT, 26, nil, UICOLOURS.GREY))
    
    self.collection:SetSize(22)

    self.divider = self.root:AddChild(Image("images/global_redux.xml", "shop_dialog_divider.tex"))
    self.divider:SetScale(1.315)

    self.buy_button = self.text_root:AddChild(TEMPLATES.StandardButton(
            nil,
            STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_BTN,
            {250, 80}
        )
    )
    self.close_button = self.root:AddChild(TEMPLATES.StandardButton(
            function() self:Close() end,
            STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_CLOSE,
            {250, 60}
        )
    )

	local onDLCGiftClickFn = 
        function()
			local body_text = subfmt(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_GIFT_INFO_BODY, {pack_name=GetSkinName(self.button_dlc.item_type) })
			local instructions = PopupDialogScreen(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_GIFT_INFO_TITLE, body_text, 
				{
					{text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function() 
							TheFrontEnd:PopScreen()
							VisitURL("http://store.steampowered.com/app/"..tostring(self.button_dlc.steam_dlc_id))
						end
					},
				}
			)
			TheFrontEnd:PushScreen( instructions )
		end
    self.button_dlc = self.text_root:AddChild(TEMPLATES.StandardButton(
			onDLCGiftClickFn,
			STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_GIFT,
			{250, 60}
		)
	)
    
    self.close_button:SetFocusChangeDir(MOVE_UP, self.buy_button)
    self.close_button:SetFocusChangeDir(MOVE_RIGHT, self.buy_button)
    self.buy_button:SetFocusChangeDir(MOVE_DOWN, self.close_button)
    self.buy_button:SetFocusChangeDir(MOVE_LEFT, self.close_button)

    self:SetData( iap_def )
end)

function PurchasePackPopup:SetData( iap_def )

    set_data( self, iap_def )

    self.desc:SetString( GetSkinDescription( self.item_type ) )

    self.buy_button:SetText(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_BTN)
    self.buy_button:SetOnClick( function() onPurchaseClickFn( self ) end )

    self.savings_frame:SetScale(0.85)
    self.oldprice_line:SetScale(1.3)
    self.text_root:SetPosition(250, 10)

    local contentw = 520

    self.title:SetHAlign(ANCHOR_LEFT)
    self.title:SetVAlign(ANCHOR_TOP)
    self.desc:SetHAlign(ANCHOR_LEFT)
    self.desc:SetVAlign(ANCHOR_TOP)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAlign(ANCHOR_TOP)

    self.title:SetRegionSize(contentw, 90 )
    self.desc:SetRegionSize(contentw,130)
    self.text:SetRegionSize(contentw,80)
    self.collection:SetRegionSize(contentw,40)
    self.price:SetRegionSize(contentw,80)
    self.oldprice:SetRegionSize(contentw,40)
    self.expire_txt:SetRegionSize( 275, 40 )
    self.savings:SetRegionSize(60,50)

    self.title:EnableWordWrap( true )
    self.desc:EnableWordWrap( true )
    self.text:EnableWordWrap( true )

    self.collection:SetPosition(0,240)
    self.title:SetPosition(0, 190)
    self.desc:SetPosition(0, 70 )
    self.text:SetPosition(0, -50 )
    self.price:SetPosition( 0, -120)
    self.oldprice:SetPosition( 0, -80)
    self.oldprice_line:SetPosition( -200, -85)
    self.expire_txt:SetPosition( 112, -75)
    self.savings_frame:SetPosition(-300,-128)

    self.sale_frame:SetPosition( 238, 233 )
    self.sale_frame:SetRotation(1.5)
    self.sale_txt:SetScale(0.85)
    self.sale_txt:SetRegionSize(80, 80)
    self.sale_txt:SetPosition(256, 261)
    self.sale_txt:SetRotation(47)

    self.savings:SetPosition(-300,-128)
    self.button_dlc:SetPosition(130, -85)

    self.icon_image:SetScale(0.7)
    self.icon_glow:SetScale(2.2)
    self.icon_glow2:SetScale(2.5)

    self.divider:SetPosition(-1,-190)
    self.close_button:SetPosition(0, -232)

    if IsPackFeatured(self.item_type) then
        self.icon_root:SetPosition(-270, 80)
        self.icon_glow:Show()
        self.icon_glow2:Show()
    else
        self.icon_root:SetPosition(-270, 80)
        self.icon_glow:Hide()
        self.icon_glow2:Hide()
    end

    if IsSteam() and IsPackGiftable(self.item_type) then
		self.button_dlc:Show()
		self.buy_button:SetPosition(130, -145)
		self.button_dlc.item_type = self.item_type
		self.button_dlc.steam_dlc_id = GetPackGiftDLCID(self.item_type)

        self.buy_button:SetFocusChangeDir(MOVE_UP, self.button_dlc)
        self.button_dlc:SetFocusChangeDir(MOVE_DOWN, self.buy_button)
	else
		self.button_dlc:Hide()
        self.buy_button:SetPosition(130, -130)
		self.button_dlc.item_type = nil
		self.button_dlc.steam_dlc_id = nil
        
        self.buy_button:SetFocusChangeDir(MOVE_UP, nil)
	end

    self.default_focus = self.buy_button
end

function PurchasePackPopup:Close()
    TheFrontEnd:PopScreen(self)
end

function PurchasePackPopup:OnControl(control, down)
    if PurchasePackPopup._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

-------------------------------------------------------------------


local PurchasePackScreen = Class(Screen, function(self, prev_screen, profile, filter_info)
    Screen._ctor(self, "PurchasePackScreen")

    if filter_info == nil then filter_info = {} end --in-case we get given a nil filter_info
    self.initial_item_key = filter_info.initial_item_key
    self.initial_discount_key = filter_info.initial_discount_key

    self:DoInit()

	Profile:SetShopHash( CalculateShopHash() )

	self.default_focus = self.purchase_root
end)

function PurchasePackScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())

    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.PURCHASEPACKSCREEN.TITLE, ""))
    self.onlinestatus = self.root:AddChild(OnlineStatus(true))

    self.purchase_root = self:_BuildPurchasePanel()
    
    --use the initial item key to set the filters
    if self.initial_item_key ~= nil and self.filters ~= nil then
        self.filters[FILTER_TYPE_INDEX].spinner:SetSelected(self.initial_item_key)
    end
    
    if IsNotConsole() and self.initial_discount_key ~= nil and self.filters ~= nil then
        self.filters[FILTER_DISCOUNT_INDEX].spinner:SetSelected(self.initial_discount_key)
    end
    

    self:UpdatePurchasePanel()
            
    if not TheInput:ControllerAttached() then 
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:Close()
                end
            ))
    end

    self.update_timer = 0
end


-------------------------------------------------------------------


local PurchaseWidget = Class(Widget, function(self, screen_self)
	Widget._ctor(self, "PurchaseWidget")

    self.screen_self = screen_self
	self.root = add_details( self, self, 1 )
    self.root:SetScale(0.90)
    self.item_type = nil
    self.sale_percent = 0
        
    self.frame = self.root:AddChild(Image("images/fepanels_redux.xml", "shop_panel.tex"))
    self.frame:SetScale(0.55)
    self.frame:SetPosition(-10,-7)
    self.frame:MoveToBack()

    self.purchased = self.root:AddChild(Image("images/global_redux.xml", "shop_checkmark.tex"))
    self.purchased:SetScale(0.65)
    self.purchased:SetPosition(-213,55)

    self.button = self.root:AddChild(TEMPLATES.StandardButton(
			nil,
			nil,
			{150, 45}
		)
	)
    
    self.info_button = self.root:AddChild(TEMPLATES.StandardButton(
            nil,
            STRINGS.UI.PURCHASEPACKSCREEN.INFO_BTN,
            {45, 45}
        )
    )

    self.OnGainFocus = function()
        PurchasePackScreen._base.OnGainFocus(self)
        screen_self.purchase_root.scroll_window.grid:OnWidgetFocus(self)
    end
    
    self.focus_forward = self.button
end)

function PurchaseWidget:ApplyDataToWidget(iap_def)
    if iap_def and not iap_def.is_blank then

        set_data( self, iap_def )

        self.info_button:SetOnClick( function() TheFrontEnd:PushScreen( PurchasePackPopup( iap_def, self.screen_self ) ) end )
        self.button:SetOnClick( function() onPurchaseClickFn( self ) end )
        self.button:SetText(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_BTN)

        self.frame:SetScale(0.7)
        self.frame:SetPosition(0,0)
        self.savings_frame:SetScale(0.55)
        self.sale_frame:SetScale(0.75)
        self.oldprice_line:SetScale(0.65)
        self.text_root:SetPosition(0, 0)

        local contentw = 285
        if IsPackFeatured(self.item_type) then
            self.title:EnableWordWrap( true )
            self.title:SetPosition( 0, 40 )
            self.title:SetRegionSize( contentw, 50 )
        else
            self.title:ResetRegionSize()
            self.title:EnableWordWrap( false )
            self.title:SetTruncatedString(GetSkinName(self.item_type), contentw, 80, true)
            local w,_ = self.title:GetRegionSize()
            self.title:SetPosition(w/2-285/2, 55)
        end
        self.text:SetPosition(0, IsPackFeatured(self.item_type) and -5 or -5 )
        self.text:SetRegionSize(contentw,40)
        self.text:EnableWordWrap( true )
        self.collection:SetPosition(0,32)
        self.collection:SetRegionSize(contentw,20)
        self.price:SetRegionSize(130,30)
        self.oldprice:SetRegionSize(130,16)
        self.price:SetPosition( -80, -58)

        self.oldprice:SetPosition(-78, -36)
        self.oldprice_line:SetPosition(-113, -36)

        self.expire_txt:SetRegionSize( 275, 16)
        self.expire_txt:SetPosition( 0, -30)

        self.savings_frame:SetPosition(-170, -57)
        self.savings:SetRegionSize(50, 30)
        self.savings:SetPosition(-168, -58)
        self.sale_frame:SetPosition(100, 26.5)
        self.sale_txt:SetRegionSize(50, 40)
        self.sale_txt:SetPosition(112, 48)
        self.sale_txt:SetRotation(45)
        self.button:SetPosition(157, -57)
        self.info_button:SetPosition(-212, -57)
        self.text_root:SetPosition(90, 0)

        if OwnsSkinPack(self.item_type) then
            self.purchased:Show()
		else
            self.purchased:Hide()
		end
        

        local panel_tex = ""
        if IsPackFeatured(self.item_type) then
            panel_tex = "shop_panel_feat.tex"

            self.icon_root:SetPosition(-145, 5)
            self.icon_image:SetScale(0.24)
            self.icon_glow:SetScale(1.0)
            self.icon_glow:Show()
            self.icon_glow2:SetScale(1.1)
            self.icon_glow2:Show()

            self.collection:Hide()
		
			
		else
            panel_tex = "shop_panel.tex"
            
            self.icon_root:SetPosition(-145, 10)
            self.icon_image:SetScale(0.25)
            self.icon_glow:Hide()
            self.icon_glow2:Hide()

            self.collection:Show()
        end

        if IsSaleActive( iap_def ) then
            panel_tex = "shop_panel_sale.tex"
        end

        self.frame:SetTexture("images/fepanels_redux.xml", panel_tex)

        --Deal with focus hacks for widget with multiple buttons
        self.info_button:SetFocusChangeDir(MOVE_RIGHT, self.button)
        self.button:SetFocusChangeDir(MOVE_LEFT, self.info_button)
            
        self.root:Show()
        
        self.ongainfocusfn = nil
    else
        -- Important that we hide a sub-element and not self because TrueScrollList manages our visiblity!
        self.root:Hide()
        
        if iap_def and iap_def.is_blank then
			--rather than focus forward, we don't know the widget from here, so manually do a FocusMove next frame.
			self.ongainfocusfn = function()
				self.inst:DoTaskInTime(0, function() TheFrontEnd:OnFocusMove(MOVE_LEFT, true) end )
			end
		end
    end
end


-------------------------------------------------------------------

function PurchasePackScreen:GetIAPDefs( no_filter_or_sort )
    local unvalidated_iap_defs = TheItems:GetIAPDefs()
    local all_iap_defs = {}
    for _,iap in ipairs(unvalidated_iap_defs) do
        -- Don't show items unless we have data/strings to describe them.
        if MISC_ITEMS[iap.item_type] then
            table.insert(all_iap_defs, iap)
        else
            print("Missing def for IAP", iap.item_type)                
        end
    end
    
    if no_filter_or_sort then
        return all_iap_defs
    end

    --Filter here!!!
    local iap_defs = {}    
    for _,iap in ipairs(all_iap_defs) do
        local is_valid_with_filters = true
        for _,filter in ipairs(self.filters) do
            if filter.name == "OWNED" then
                local filter_data = filter.spinner:GetSelectedData()
                if filter_data == "UNOWNED" then
                    if OwnsSkinPack(iap.item_type) then
                        is_valid_with_filters = false
                    end
                end
            
            elseif filter.name == "TYPE" then
                local filter_data = filter.spinner:GetSelectedData()
                if filter_data == "ALL" then
                    --all good
                elseif filter_data == "ITEMS" then
                    if not DoesPackHaveBelongings(iap.item_type) then
                        is_valid_with_filters = false
                    end
                elseif filter_data == self.initial_item_key and not itemKeyIsCharacter(self.initial_item_key) then
                    --specific item passed in
                    if not DoesPackHaveItem( iap.item_type, self.initial_item_key ) then
                        is_valid_with_filters = false
                    end
                else
                    --character skins
                    if not DoesPackHaveSkinsForCharacter( iap.item_type, filter_data ) then
                        is_valid_with_filters = false
                    end
                end
            elseif filter.name == "DISCOUNT" then
                local filter_data = filter.spinner:GetSelectedData()
                if filter_data == "ALL" then
                    --all good
                elseif filter_data == "SALE" then
                    if not IsSaleActive(iap) then
                        is_valid_with_filters = false
                    end
                elseif filter_data == "BUNDLE" then
                    if not IsPackABundle( iap.item_type ) then
                        is_valid_with_filters = false
                    end
                end
            end
        end

        if is_valid_with_filters then
            table.insert(iap_defs, iap)
        end
    end


    local function DisplayOrderSort(a,b)
        if MISC_ITEMS[a.item_type].release_group == MISC_ITEMS[b.item_type].release_group then
            return MISC_ITEMS[a.item_type].display_order < MISC_ITEMS[b.item_type].display_order
        else
            return MISC_ITEMS[a.item_type].release_group > MISC_ITEMS[b.item_type].release_group
        end
    end
    table.sort(iap_defs, DisplayOrderSort)
    return iap_defs        
end

local label_width = 70
local widget_width = 190
local height = 30
local spacing = 3
local total_width = label_width + widget_width + spacing
local bg_width = spacing + total_width + spacing + 10
local bg_height = height + 2


function PurchasePackScreen:_CreateSpinnerFilter( name, text, spinnerOptions )

    local group = TEMPLATES.LabelSpinner(text, spinnerOptions, label_width, widget_width, height, spacing, CHATFONT, 20)
    self.side_panel:AddChild(group)
    group.bg = group:AddChild(TEMPLATES.ListItemBackground(bg_width, bg_height))
    group.bg:MoveToBack()

    group.label:SetHAlign(ANCHOR_LEFT)
    group.spinner:EnablePendingModificationBackground()
    group.spinner:SetOnChangedFn(
        function(...)
            self:UpdatePurchasePanel()
        end)

    group.name = name

    return group
end

local function build_type_options(initial_item_key)
    local type_options = { { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL, data = "ALL" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ITEMS, data = "ITEMS" }  }
    for _,character in pairs(DST_CHARACTERLIST) do
        table.insert( type_options, { text = STRINGS.NAMES[string.upper(character)], data = character } )
    end

    if initial_item_key ~= nil and not itemKeyIsCharacter(initial_item_key) then
        table.insert(type_options, 1, { text = GetSkinName(initial_item_key), data = initial_item_key });
    end

    return type_options
end

function PurchasePackScreen:_BuildPurchasePanel()
    local purchase_ss = self.root:AddChild(Widget("purchase_ss"))

    -- Overlay is how we display purchasing.
    if PLATFORM == "WIN32_RAIL" or TheNet:IsNetOverlayEnabled() then
        local iap_defs = self:GetIAPDefs(true)

        if #iap_defs == 0 then
            local msg = STRINGS.UI.PURCHASEPACKSCREEN.FAILED_TO_LOAD
            local dialog = purchase_ss:AddChild(TEMPLATES.CurlyWindow(400, 200, "", nil, nil, msg))
            purchase_ss.focus_forward = dialog
        else
            purchase_ss:SetPosition(40,0)

            local function ScrollWidgetsCtor(context, index)
                return PurchaseWidget( self )
            end
            local function ScrollWidgetApply(context, widget, data, index)
                widget:ApplyDataToWidget(data)
            end
            
            purchase_ss.scroll_window = purchase_ss:AddChild(TEMPLATES.RectangleWindow(915, 620))
			purchase_ss.scroll_window:SetBackgroundTint(0,0,0,0) -- transparent
    
			purchase_ss.scroll_window.grid = purchase_ss.scroll_window:InsertWidget(
				TEMPLATES.ScrollingGrid(
                    iap_defs,
                    {
                        context = {},
                        widget_width  = 440,
                        widget_height = 160,
                        num_visible_rows = 3.65,
                        num_columns      = 2,
                        item_ctor_fn = ScrollWidgetsCtor,
                        apply_fn     = ScrollWidgetApply,
                        scrollbar_offset = 20,
						scrollbar_height_offset = -60,
                        scissor_pad = 35,
                    }
                )
			)
            purchase_ss.scroll_window:SetPosition(60,-3)
            purchase_ss.focus_forward = purchase_ss.scroll_window.grid
            
            --We need to inject this call to DoFocusHookups because the widgets are going to muck with the SetFocusChangedDir
            local oldRefreshView = purchase_ss.scroll_window.grid.RefreshView
            purchase_ss.scroll_window.grid.RefreshView = function(self)
				purchase_ss.scroll_window.grid.list_root.grid:DoFocusHookups()
				oldRefreshView(self)
            end
            

            self.side_panel = self.root:AddChild(Widget("side_panel"))
            self.side_panel:SetPosition(-480,0)

            self.filters_label = self.side_panel:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PURCHASEPACKSCREEN.FILTERS, UICOLOURS.GOLD_SELECTED))
            self.filters_label:SetPosition(0,15)
            self.filters_label:SetRegionSize(100,30)
            self.filters_divider = self.side_panel:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
            self.filters_divider:SetScale(0.4)


            self.filters = {}
            
            local owned_options = { { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL, data = "ALL" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_UNOWNED, data = "UNOWNED" } }
            self.filters[FILTER_OWNED_INDEX] = self:_CreateSpinnerFilter( "OWNED", STRINGS.UI.PURCHASEPACKSCREEN.OWNED_FILTER, owned_options )
            
            local type_options = build_type_options( self.initial_item_key )
            self.filters[FILTER_TYPE_INDEX] = self:_CreateSpinnerFilter( "TYPE", STRINGS.UI.PURCHASEPACKSCREEN.TYPE_FILTER, type_options )

            if IsNotConsole() then
                local discount_options = { { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL, data = "ALL" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_SALE, data = "SALE" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_BUNDLE, data = "BUNDLE" } }
                self.filters[FILTER_DISCOUNT_INDEX] = self:_CreateSpinnerFilter( "DISCOUNT", STRINGS.UI.PURCHASEPACKSCREEN.DISCOUNT_FILTER, discount_options )
            end

            for i,spinner in pairs(self.filters) do
                spinner:SetPosition( 0, i * -(height + spacing) )
                
                if i > 1 then
                    spinner:SetFocusChangeDir(MOVE_UP, self.filters[i-1])
                end
                if i < #self.filters then
                    spinner:SetFocusChangeDir(MOVE_DOWN, self.filters[i+1])
                end
            end

            self.side_panel.focus_forward = self.filters[1]

            
            purchase_ss:SetFocusChangeDir(MOVE_LEFT, self.side_panel)
            self.side_panel:SetFocusChangeDir(MOVE_RIGHT, purchase_ss)

            self.empty_txt = purchase_ss.scroll_window:AddChild(Text(CHATFONT, 26, STRINGS.UI.PURCHASEPACKSCREEN.EMPTY_AFTER_FILTER))
            self.empty_txt:Hide()
        end
    else
        local buttons = {
            {
                text = STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_HELP,
                cb = function() 
                    VisitURL("https://support.steampowered.com/kb_article.php?ref=9394-yofv-0014")
                end
            },
        }
        local dialog = purchase_ss:AddChild(TEMPLATES.CurlyWindow(400, 200,
                STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_TITLE,
                buttons, nil,
                STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_BODY
            ))
        purchase_ss.focus_forward = dialog
    end

    return purchase_ss
end


function PurchasePackScreen:UpdateFilterToItem(item_key)
    self.initial_item_key = item_key
    
    local type_options = build_type_options( self.initial_item_key )

    self.filters[FILTER_TYPE_INDEX].spinner:SetOptions(type_options)
    self.filters[FILTER_TYPE_INDEX].spinner:SetSelected(self.initial_item_key)
end


function PurchasePackScreen:UpdatePurchasePanel()
    if self.purchase_root.scroll_window ~= nil then
        local iap_defs = self:GetIAPDefs()
        if table.getn(iap_defs) == 0 then
            self.empty_txt:Show()
        else
            self.empty_txt:Hide()
        end
        self.purchase_root.scroll_window.grid:SetItemsData(iap_defs)
    end
end


function PurchasePackScreen:OnBecomeActive()
    PurchasePackScreen._base.OnBecomeActive(self)

    if not self.shown then
        self:Show()
    end

    self:UpdatePurchasePanel()

    self.leaving = nil
    
    DisplayInventoryFailedPopup( self )
end

function PurchasePackScreen:Close()
    TheFrontEnd:FadeBack()
end

function PurchasePackScreen:OnControl(control, down)
    if PurchasePackScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

function PurchasePackScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.BACK)
    return table.concat(t, "  ")
end


function PurchasePackScreen:OnUpdate(dt)
    self.update_timer = self.update_timer + dt
    if self.update_timer > 1.0 then
        self.update_timer = 0
		if self.purchase_root.scroll_window then
			self.purchase_root.scroll_window.grid:RefreshView()
		end
    end
end


return PurchasePackScreen

