local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local OnlineStatus = require "widgets/onlinestatus"
local PopupDialogScreen = require "screens/redux/popupdialog"
local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local ItemBoxOpenerPopup = require "screens/redux/itemboxopenerpopup"
local ItemBoxPreviewer = require "screens/redux/itemboxpreviewer"
local Stats = require("stats")
local ImageButton = require "widgets/imagebutton"

local TEMPLATES = require("widgets/redux/templates")
require("misc_items")

-------------------------------------------------------------------

local FILTER_OWNED_INDEX = 1
local FILTER_TYPE_INDEX = 2
local FILTER_DISCOUNT_INDEX = 3

local SUPPORT_VIRTUAL_IAP = false --IsConsole()

--view modes
MODE_REGULAR = 0
MODE_CURRENCY_PACKS = 1



local PurchasePackScreen = nil

local function itemKeyIsCharacter(initial_item_key)
    return table.contains(DST_CHARACTERLIST, initial_item_key)
end

local add_details = function ( self, proot, fontsize )

    self.root = proot:AddChild(Widget("purchase_dialog_root"))

    self.icon_root = self.root:AddChild(Widget("icon_root"))
	self.icon_root:SetPosition(-150, 0)

	self.icon_anim = self.icon_root:AddChild(UIAnim())
	self.icon_anim:GetAnimState():SetBuild("frames_comp")
	self.icon_anim:GetAnimState():SetBank("frames_comp")
	self.icon_anim:GetAnimState():Hide("frame")
	self.icon_anim:GetAnimState():Hide("NEW")
	self.icon_anim:GetAnimState():PlayAnimation("idle_on")
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

local purchasefn = nil
purchasefn = function( screen, iap_def, sale_percent_purchased, accept_virtual_iap )
        local item_type_purchased = iap_def.item_type

        local value = GetPriceFromIAPDef( iap_def, sale_percent_purchased > 0 )

        local currency_needed = 0
        if iap_def.iap_type == IAP_TYPE_VIRTUAL then
            currency_needed = value - TheInventory:GetVirtualIAPCurrencyAmount()
        end
        if currency_needed > 0 then
            local warning = PopupDialogScreen(STRINGS.UI.PURCHASEPACKSCREEN.NOT_ENOUGH_TITLE, subfmt(STRINGS.UI.PURCHASEPACKSCREEN.NOT_ENOUGH_BODY, { currency_needed = currency_needed, chest_name = GetSkinName(item_type_purchased) }),
            {
                {text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function()
                    screen.screen_self.view_mode = MODE_CURRENCY_PACKS
                    screen.refresh_bolt_count = true
                    screen.view_currency_for_def = iap_def
                    TheFrontEnd:PopScreen()
                end },
                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_CANCEL, cb = function()
                    TheFrontEnd:PopScreen()
                end },
            }, nil, "big", "dark_wide" )
            warning.owned_by_wardrobe = true
            TheFrontEnd:PushScreen( warning )
        else

            if not accept_virtual_iap and iap_def.iap_type == IAP_TYPE_VIRTUAL then
                local warning = PopupDialogScreen( STRINGS.UI.PURCHASEPACKSCREEN.VIRTUAL_IAP_CONFIRM_TITLE, subfmt(STRINGS.UI.PURCHASEPACKSCREEN.VIRTUAL_IAP_CONFIRM_BODY, { cost = value, chest_name = GetSkinName(item_type_purchased) }),
                {
                    {text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function()
                        TheFrontEnd:PopScreen()
                        purchasefn( screen, iap_def, sale_percent_purchased, true )
                    end },
                    {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_CANCEL, cb = function()
                        screen.view_mode = MODE_REGULAR
                        screen.view_currency_for_def = nil
                        TheFrontEnd:PopScreen()
                    end },
                })
            	warning.owned_by_wardrobe = true
                TheFrontEnd:PushScreen( warning )
            else
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/purchase")

                local commerce_popup = GenericWaitingPopup("ItemServerContactPopup", STRINGS.UI.ITEM_SERVER.CONNECT, nil, true)
                TheFrontEnd:PushScreen(commerce_popup)

                TheItems:StartPurchase(item_type_purchased, sale_percent_purchased, function(success, message)
                    screen.inst:DoTaskInTime(0, function()  --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                        commerce_popup:Close()
                        if success then
                            local currency = GetPurchasePackCurrencyOutput(item_type_purchased)
                            if currency == nil then
                                local display_items = GetPurchasePackDisplayItems(item_type_purchased)
                                local options = {
                                    allow_cancel = false,
                                    box_build = GetBoxBuildForItem(item_type_purchased),
                                }

                                local box_popup = ItemBoxOpenerPopup(options, function(success_cb)
                                    success_cb(display_items)
                                end)
            					box_popup.owned_by_wardrobe = true
                                TheFrontEnd:PushScreen(box_popup)

                                screen.view_mode = MODE_REGULAR
                                screen.view_currency_for_def = nil
                                screen.refresh_bolt_count = true
                            else
                                local options = {
                                    allow_cancel = false,
                                    bolts_source = item_type_purchased,
                                }

                                local box_popup = ItemBoxOpenerPopup(options, function(success_cb)
                                    success_cb()
                                end)
            					box_popup.owned_by_wardrobe = true
                                TheFrontEnd:PushScreen(box_popup)

                                screen.refresh_bolt_count = true
                            end
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


                    end, screen)
                end)
            end
        end
    end

local onPurchaseClickFn2 = function( self, sale_percent_purchased, iap_def )
    if not IsPurchasePackCurrency(iap_def.item_type) and OwnsSkinPack(iap_def.item_type) then
        local warning = PopupDialogScreen(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_TITLE, STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_DESC,
                    {
                        {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_OK, cb = function()
                            TheFrontEnd:PopScreen()
                            purchasefn( self.screen_self, iap_def, sale_percent_purchased, false )
                        end },
                        {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_CANCEL, cb = function()
                            TheFrontEnd:PopScreen()
                        end },
                    })
        warning.owned_by_wardrobe = true
        TheFrontEnd:PushScreen( warning )
    else
        purchasefn( self.screen_self, iap_def, sale_percent_purchased, false )
    end
end

local onPurchaseClickFn =
    function( self )
         --need to save a copy of these for the callback function because the UI could update on us, and sale_percent could change.
        local sale_percent_purchased = self.sale_percent
        local iap_def = self.iap_def

        local restricted_pack, missing_character = IsPackRestrictedDueToOwnership(self.iap_def.item_type)

        if restricted_pack == "error" or restricted_pack == "warning" then
            local body_str = subfmt(STRINGS.UI.PURCHASEPACKSCREEN.UNOWNED_CHARACTER_BODY, {character = STRINGS.CHARACTER_NAMES[missing_character] })
            local button_txt = subfmt(STRINGS.UI.PURCHASEPACKSCREEN.VIEW_REQUIRED, {character = STRINGS.CHARACTER_NAMES[missing_character] })

            local warning = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.UNOWNED_CHARACTER_TITLE, body_str,
            {
                {text=button_txt, cb = function()
                    self.screen_self:UpdateFilterToItem(missing_character.."_none")
                    TheFrontEnd:PopScreen()
                end},
                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_OK, cb = function()
                    TheFrontEnd:PopScreen()
                    onPurchaseClickFn2( self, sale_percent_purchased, iap_def )
                end },
                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_CANCEL, cb = function()
                    TheFrontEnd:PopScreen()
                end },
            }, nil, nil, "dark_wide")
            warning.owned_by_wardrobe = true
            TheFrontEnd:PushScreen( warning )

        else
            onPurchaseClickFn2( self, sale_percent_purchased, iap_def )
        end
    end

local set_data =
    function ( self, iap_def )
        self.iap_def = iap_def

        local title = GetSkinName(self.iap_def.item_type)
        self.title:SetString(title)

        local collection = GetPackCollection(self.iap_def.item_type)
        self.collection:SetString(collection)

        local sale_active, sale_duration = IsSaleActive(iap_def)

        local savings = 0
        local is_pack_bundle, total_value = IsPackABundle(self.iap_def.item_type)
        if is_pack_bundle then
            local total_value_str = BuildPriceStr( total_value, iap_def )
            self.oldprice:SetString( total_value_str )
            savings = GetPackSavings(iap_def, total_value, sale_active)
        else
            local original_price_str = BuildPriceStr( iap_def, iap_def, false )
            self.oldprice:SetString( original_price_str )
        end


        if sale_active then
            self.price:SetString( BuildPriceStr( iap_def, iap_def, true ) )

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
            self.price:SetString( BuildPriceStr( iap_def, iap_def, false ) )

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



        local currency = GetPurchasePackCurrencyOutput(self.iap_def.item_type)
        if currency == nil then
            local total_items = GetPackTotalItems(self.iap_def.item_type)
            local total_sets = GetPackTotalSets(self.iap_def.item_type)
            if total_sets > 1 then
                -- megapack!
                self.text:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.MEGAPACK_SHORT_DESC, { total_items = total_items, total_sets = total_sets }) )
            else
                local is_clothing_pack = IsPackClothingOnly(self.iap_def.item_type)
                local is_belongings_pack = IsPackBelongingsOnly(self.iap_def.item_type)
                local src = STRINGS.UI.PURCHASEPACKSCREEN.PACK_SHORT_DESC
                if is_clothing_pack then
                    src = STRINGS.UI.PURCHASEPACKSCREEN.PACK_SHORT_DESC_CHAR
                elseif is_belongings_pack then
                    src = STRINGS.UI.PURCHASEPACKSCREEN.PACK_SHORT_DESC_ITEMS
                end
                self.text:SetString( subfmt( src, { total_items = total_items }) )
            end
        else
            self.text:SetString( subfmt( STRINGS.UI.PURCHASEPACKSCREEN.CURRENCY_SHORT_DESC, { currency = currency }) )
        end

        self.icon_image:Hide()
        self.icon_anim:Hide()
        local image = GetPurchaseDisplayForItem(self.iap_def.item_type)
        if image then
            self.icon_image:SetTexture(unpack(image))
            self.icon_image:Show()
        else
            self.icon_anim:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(self.iap_def.item_type), "SWAP_ICON")
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
            function()
                TheFrontEnd:PopScreen()
                onPurchaseClickFn( self )
            end,
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
    if not IsPurchasePackCurrency( iap_def.item_type ) then
        self.contents_button = self.root:AddChild(TEMPLATES.StandardButton(
                function()
                    local display_items = GetPurchasePackDisplayItems(iap_def.item_type)
                    local box_popup = ItemBoxPreviewer(display_items)
                    TheFrontEnd:PushScreen( box_popup )
                end,
                STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_VIEW_CONTENTS,
                {250, 60}
            )
        )
    end

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
            instructions.owned_by_wardrobe = true
            TheFrontEnd:PopScreen()
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
    if self.contents_button ~= nil then
        self.close_button:SetFocusChangeDir(MOVE_LEFT, self.contents_button)
        self.contents_button:SetFocusChangeDir(MOVE_UP, self.buy_button)
        self.contents_button:SetFocusChangeDir(MOVE_RIGHT, self.close_button)
    end
    self.buy_button:SetFocusChangeDir(MOVE_DOWN, self.close_button)
    self.buy_button:SetFocusChangeDir(MOVE_LEFT, self.close_button)

    self:SetData( iap_def )
end)

function PurchasePackPopup:SetData( iap_def )

    set_data( self, iap_def )

    self.expire_txt:Hide() --don't want this on the pack popup

    self.desc:SetString( GetSkinDescription( self.iap_def.item_type ) )

    self.buy_button:SetText(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_BTN)
    self.savings_frame:SetScale(0.85)
    self.oldprice_line:SetScale(1.3)
    self.text_root:SetPosition(250, 10)

    local contentw = 520

    self.title:SetHAlign(ANCHOR_LEFT)
    self.title:SetVAlign(ANCHOR_MIDDLE)
    self.desc:SetHAlign(ANCHOR_LEFT)
    self.desc:SetVAlign(ANCHOR_MIDDLE)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAlign(ANCHOR_TOP)

    self.title:SetRegionSize(contentw, 90 )
    self.desc:SetRegionSize(contentw,200)
    self.text:SetRegionSize(contentw,80)
    self.collection:SetRegionSize(contentw,40)
    self.price:SetRegionSize(contentw,80)
    self.oldprice:SetRegionSize(contentw,40)
    self.savings:SetRegionSize(60,50)

    self.title:EnableWordWrap( true )
    self.desc:EnableWordWrap( true )
    self.text:EnableWordWrap( true )

    self.collection:SetPosition(0,250)
    self.title:SetPosition(0, 200)
    self.desc:SetPosition(0, 70 )
    self.text:SetPosition(0, -60 )
    self.price:SetPosition( 0, -120)
    self.oldprice:SetPosition( 0, -80)
    self.oldprice_line:SetPosition( -200, -85)
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

    if self.contents_button ~= nil then
        self.close_button:SetPosition(130, -232)
        self.contents_button:SetPosition(-130, -232)
    else
        self.close_button:SetPosition(0, -232)
    end

    if IsPackFeatured(self.iap_def.item_type) then
        self.icon_root:SetPosition(-270, 80)
        self.icon_glow:Show()
        self.icon_glow2:Show()
    else
        self.icon_root:SetPosition(-270, 80)
        self.icon_glow:Hide()
        self.icon_glow2:Hide()
    end

    if IsSteam() and IsPackGiftable(self.iap_def.item_type) then
		self.button_dlc:Show()
		self.buy_button:SetPosition(130, -145)
		self.button_dlc.item_type = self.iap_def.item_type
		self.button_dlc.steam_dlc_id = GetPackGiftDLCID(self.iap_def.item_type)

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


PurchasePackScreen = Class(Screen, function(self, prev_screen, profile, filter_info)
    
    TheSim:QueryServer( "https://items.kleientertainment.com/iap/dst/GetShopEpoch",
		function(result, isSuccessful, resultCode)
			if isSuccessful and resultCode == 200 then
                local res = json.decode(result)
                if res.Time ~= nil then
                    if math.abs(res.Time - os.time()) > 60 then
                        print("Shop epoch time is offset!!!", res.Time - os.time())

                        local warning = PopupDialogScreen(STRINGS.UI.PURCHASEPACKSCREEN.SHOP_EPOCH_WRONG_TITLE, STRINGS.UI.PURCHASEPACKSCREEN.SHOP_EPOCH_WRONG_BODY,
                        {
                            {text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function()
                                TheFrontEnd:PopScreen()
                            end },
                        }, nil, "big" )
                        TheFrontEnd:PushScreen( warning )
                    end
                end
            end
		end,
		"POST")


    self.prev_screen = prev_screen

    --track where in the UI we came from
    local screen_flow_path = "ScreenFlow"
    for i,screen_in_stack in pairs(TheFrontEnd.screenstack) do
        screen_flow_path = screen_flow_path .. "_" .. screen_in_stack.name
    end
    Stats.PushMetricsEvent("PurchasePackScreen.entered", TheNet:GetUserID(), { url = screen_flow_path }, "is_only_local_users_data")

    Screen._ctor(self, "PurchasePackScreen")

    if filter_info == nil then filter_info = {} end --in-case we get given a nil filter_info

    self.view_mode = MODE_REGULAR

    self.initial_item_key = filter_info.initial_item_key
    self.initial_discount_key = filter_info.initial_discount_key
    self.refresh_bolt_count = false
    self.screen_self = self --so screens itself can pretend to be a sub-widget with a ref to the screen

    self:DoInit()

	Profile:SetShopHash( CalculateShopHash() )

	self.default_focus = self.purchase_root
end)

function PurchasePackScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())

    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.PURCHASEPACKSCREEN.TITLE, ""))
    self.onlinestatus = self.root:AddChild(OnlineStatus(true))

	self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.purchase_root = self:_BuildPurchasePanel()

    --use the initial item key to set the filters
    if self.initial_item_key ~= nil and self.filters[FILTER_TYPE_INDEX] ~= nil then
        self.filters[FILTER_TYPE_INDEX].spinner:SetSelected(self.initial_item_key)
    end

    if IsNotConsole() and self.initial_discount_key ~= nil and self.filters[FILTER_DISCOUNT_INDEX] ~= nil then
        self.filters[FILTER_DISCOUNT_INDEX].spinner:SetSelected(self.initial_discount_key)
    end

    self:RefreshScreen()

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
    self.iap_def = nil
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

        self.info_button:SetOnClick( function()
			local scr = PurchasePackPopup( iap_def, self.screen_self )
			scr.owned_by_wardrobe = true
			TheFrontEnd:PushScreen(scr)
			end )
        self.button:SetOnClick( function() onPurchaseClickFn( self ) end )
        self.button:SetText(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_BTN)

        self.frame:SetScale(0.7)
        self.frame:SetPosition(0,0)
        self.savings_frame:SetScale(0.55)
        self.sale_frame:SetScale(0.75)
        self.oldprice_line:SetScale(0.65)
        self.text_root:SetPosition(0, 0)

        local contentw = 285
        if IsPackFeatured(self.iap_def.item_type) then
            self.title:EnableWordWrap( true )
            self.title:SetPosition( 0, 40 )
            self.title:SetRegionSize( contentw, 50 )
        else
            self.title:ResetRegionSize()
            self.title:EnableWordWrap( false )
            self.title:SetTruncatedString(GetSkinName(self.iap_def.item_type), contentw, 80, true)
            local w,_ = self.title:GetRegionSize()
            self.title:SetPosition(w/2-285/2, 55)
        end
        self.text:SetPosition(0, IsPackFeatured(self.iap_def.item_type) and -5 or -5 )
        self.text:SetRegionSize(contentw,40)
        self.text:EnableWordWrap( true )
        self.collection:SetPosition(0,32)
        self.collection:SetRegionSize(contentw,20)
        self.price:SetRegionSize( 200,30 )
        self.price:SetPosition( -45, -58 )

        self.oldprice:SetRegionSize(130,16)
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

        if OwnsSkinPack(self.iap_def.item_type) then
            self.purchased:Show()
		else
            self.purchased:Hide()
		end


        local panel_tex = ""
        if IsPackFeatured(self.iap_def.item_type) then
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
    local latest_release_pack = 0
    for _,iap in ipairs(unvalidated_iap_defs) do
        -- Don't show items unless we have data/strings to describe them.
        if MISC_ITEMS[iap.item_type] then
            latest_release_pack = math.max(latest_release_pack, GetReleaseGroup(iap.item_type))

            if SUPPORT_VIRTUAL_IAP then
                if self.view_mode == MODE_REGULAR and iap.iap_type == IAP_TYPE_VIRTUAL then
                    table.insert(all_iap_defs, iap)
                end
                if self.view_mode == MODE_CURRENCY_PACKS and iap.iap_type == IAP_TYPE_REAL then
                    table.insert(all_iap_defs, iap)
                end
            else
                table.insert(all_iap_defs, iap)
            end
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

        if self.view_mode == MODE_REGULAR then
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
                    elseif filter_data == "NEW" then
                        --Only the most recent release
                        if GetReleaseGroup(iap.item_type) ~= latest_release_pack  then
                            is_valid_with_filters = false
                        end
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

local label_width = 72
local widget_width = 190
local height = 30
local spacing = 3
local total_width = label_width + widget_width + spacing
local bg_width = spacing + total_width + spacing + 10
local bg_height = height + 2


function PurchasePackScreen:_CreateSpinnerFilter( name, text, spinnerOptions )

    local group = TEMPLATES.LabelSpinner(text, spinnerOptions, label_width, widget_width, height, spacing, CHATFONT, 20)
    self.filter_container:AddChild(group)
    group.bg = group:AddChild(TEMPLATES.ListItemBackground(bg_width, bg_height))
    group.bg:MoveToBack()

    group.label:SetHAlign(ANCHOR_LEFT)
    group.spinner:EnablePendingModificationBackground()
    group.spinner:SetOnChangedFn(
        function(...)
            self:RefreshScreen()
        end)

    group.name = name

    return group
end

local function build_type_options(initial_item_key)
    local type_options = { { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL, data = "ALL" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ITEMS, data = "ITEMS" }  }
    for _,character in pairs(DST_CHARACTERLIST) do
        if character ~= "wonkey" then --no wonkey skins in packs... yet??? maybe one day???
            table.insert( type_options, { text = STRINGS.NAMES[string.upper(character)], data = character } )
        end
    end

    if initial_item_key ~= nil then
        if initial_item_key == "NEW" then
            table.insert(type_options, 1, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_NEW, data = "NEW" })
        elseif not itemKeyIsCharacter(initial_item_key) then
            table.insert(type_options, 1, { text = GetSkinName(initial_item_key), data = initial_item_key })
        end
    end

    return type_options
end

function PurchasePackScreen:_BuildPurchasePanel()
    local purchase_ss = self.root:AddChild(Widget("purchase_ss"))

    self.filters = {}

    -- Overlay is how we display purchasing.
    if PLATFORM == "WIN32_RAIL" or TheNet:IsNetOverlayEnabled() then
        local iap_defs = self:GetIAPDefs(true)

        if #iap_defs == 0 then
            local msg = TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and STRINGS.UI.MAINSCREEN.STORE_DISABLE or STRINGS.UI.PURCHASEPACKSCREEN.FAILED_TO_LOAD
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
                        scroll_per_click = 0.5
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

            self.panel_built = true

            self.side_panel = self.root:AddChild(Widget("side_panel"))
            self.side_panel:SetPosition(-480,0)

            self.filter_container = self.side_panel:AddChild(Widget("filters"))

            self.filters_label = self.filter_container:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PURCHASEPACKSCREEN.FILTERS, UICOLOURS.GOLD_SELECTED))
            self.filters_label:SetPosition(0,15)
            self.filters_label:SetRegionSize(100,30)
            self.filters_divider = self.filter_container:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
            self.filters_divider:SetScale(0.4)

            local owned_options = { { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL, data = "ALL" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_UNOWNED, data = "UNOWNED" } }
            self.filters[FILTER_OWNED_INDEX] = self:_CreateSpinnerFilter( "OWNED", STRINGS.UI.PURCHASEPACKSCREEN.OWNED_FILTER, owned_options )

            local type_options = build_type_options( self.initial_item_key )
            self.filters[FILTER_TYPE_INDEX] = self:_CreateSpinnerFilter( "TYPE", STRINGS.UI.PURCHASEPACKSCREEN.TYPE_FILTER, type_options )

            local discount_options = { { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_ALL, data = "ALL" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_SALE, data = "SALE" }, { text = STRINGS.UI.PURCHASEPACKSCREEN.FILTER_BUNDLE, data = "BUNDLE" } }
            self.filters[FILTER_DISCOUNT_INDEX] = self:_CreateSpinnerFilter( "DISCOUNT", STRINGS.UI.PURCHASEPACKSCREEN.DISCOUNT_FILTER, discount_options )

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
			if not SUPPORT_VIRTUAL_IAP then
				-- if virtual IAP is supported then the MOVE_LEFT focus is set to the view_currency_button/hide_currency_button in the refresh
				purchase_ss:SetFocusChangeDir(MOVE_LEFT, self.side_panel)
			end
            self.side_panel:SetFocusChangeDir(MOVE_RIGHT, purchase_ss)

            self.empty_txt = purchase_ss.scroll_window:AddChild(Text(CHATFONT, 26, STRINGS.UI.PURCHASEPACKSCREEN.EMPTY_AFTER_FILTER))
            self.empty_txt:Hide()

            if SUPPORT_VIRTUAL_IAP then
                self.virutal_currency_label = self.side_panel:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PURCHASEPACKSCREEN.VIRTUAL_CURRENCY, UICOLOURS.GOLD_SELECTED))
                self.virutal_currency_label:SetPosition(0,250)
                self.virutal_currency_label:SetRegionSize(300,30)
                self.virutal_currency_count = self.side_panel:AddChild(TEMPLATES.BoltCounter(TheInventory:GetVirtualIAPCurrencyAmount()))
                self.virutal_currency_count:SetScale(0.5)
                self.virutal_currency_count:SetPosition(0,170)

                self.bolts = TheInventory:GetVirtualIAPCurrencyAmount()

                self.view_modes = self.side_panel:AddChild( Widget("side_panel"))
                self.view_modes:SetScale(0.75)
                self.view_modes:SetPosition( 0, 60 )

                self.hide_currency_button = nil
                self.view_currency_button = self.view_modes:AddChild( TEMPLATES.StandardButton(
                    function()
                        self.view_mode = MODE_CURRENCY_PACKS
                        self:RefreshScreen()
                        self.hide_currency_button:SetFocus()
                    end,
                    STRINGS.UI.PURCHASEPACKSCREEN.VIEW_CURRENCY,
                    {250, 60}
                ))
                self.hide_currency_button = self.view_modes:AddChild( TEMPLATES.StandardButton(
                    function()
                        self.view_mode = MODE_REGULAR
                        self:RefreshScreen()
                        self.view_currency_button:SetFocus()
                    end,
                    STRINGS.UI.PURCHASEPACKSCREEN.VIEW_REGULAR,
                    {250, 60}
                ))
                self.view_currency_button:SetFocusChangeDir(MOVE_DOWN, self.side_panel)

                self.currency_needed_txt = self.side_panel:AddChild(Text(CHATFONT, 26))
                self.currency_needed_txt:EnableWordWrap(true)
                self.currency_needed_txt:SetRegionSize(250, 200)
            end

            local sales_active = false
            for _,iap in pairs(iap_defs) do
                if IsSaleActive(iap) then
                    sales_active = true
                    break
                end
            end

            if sales_active then
                self.sales_btn = self.side_panel:AddChild(ImageButton("images/global_redux.xml", "button_view_sales_normal.tex", "button_view_sales_hover.tex", nil, "button_view_sales_down.tex"))
                self.sales_btn:SetFont(CHATFONT)
                self.sales_btn:SetTextSize(30)
                self.sales_btn:SetText(STRINGS.UI.PURCHASEPACKSCREEN.GO_TO_SALES)
                self.sales_btn:SetScale(0.80)
                self.sales_btn:SetPosition(0, -170)
                self.sales_btn:SetOnClick(function() self.filters[FILTER_DISCOUNT_INDEX].spinner:SetSelected("SALE") end)

                self.filters[FILTER_DISCOUNT_INDEX]:SetFocusChangeDir(MOVE_DOWN, self.sales_btn)
                self.sales_btn:SetFocusChangeDir(MOVE_UP, self.filters[FILTER_DISCOUNT_INDEX])
            end
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
        local title = STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_TITLE
        local body = STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_BODY
        if IsRail() then
            title = STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_TITLE_RAIL
            body = STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_OVERLAY_REQUIRED_BODY_RAIL
        end
        local dialog = purchase_ss:AddChild(TEMPLATES.CurlyWindow(400, 200, title, buttons, nil, body ))
        purchase_ss.focus_forward = dialog
    end

    return purchase_ss
end


function PurchasePackScreen:RefreshScreen()
    local iap_defs = self:GetIAPDefs()
    if self.purchase_root.scroll_window ~= nil then
        if #iap_defs == 0 then
            self.empty_txt:Show()
        else
            self.empty_txt:Hide()
        end
        self.purchase_root.scroll_window.grid:SetItemsData(iap_defs)
    end

    if SUPPORT_VIRTUAL_IAP and self.panel_built then
        if self.view_mode == MODE_REGULAR then
            self.view_currency_button:Show()
            self.hide_currency_button:Hide()
            self.filter_container:Show()
            self.currency_needed_txt:Hide()

            self.side_panel:SetFocusChangeDir(MOVE_UP, self.view_currency_button)
            self.purchase_root:SetFocusChangeDir(MOVE_LEFT, self.side_panel)

        else
            self.view_currency_button:Hide()
            self.hide_currency_button:Show()
            self.filter_container:Hide()

            self.purchase_root:SetFocusChangeDir(MOVE_LEFT, self.hide_currency_button)
        end


        if self.refresh_bolt_count then --don't refresh until we're explicitely asked to, to ensure we see the animation
            self.refresh_bolt_count = false

            if self.view_currency_for_def ~= nil then
                self.currency_needed_txt:Show()

				local sale_active, sale_duration = IsSaleActive(self.view_currency_for_def)
                local value = GetPriceFromIAPDef( self.view_currency_for_def, sale_active )
                local currency_needed = value - TheInventory:GetVirtualIAPCurrencyAmount()

                if currency_needed > 0 then
                    self.currency_needed_txt:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.CURRENCY_NEEDED, { currency_needed = currency_needed, chest_name = GetSkinName(self.view_currency_for_def.item_type) }) )
                else
                    self.currency_needed_txt:SetString( subfmt(STRINGS.UI.PURCHASEPACKSCREEN.CURRENCY_OK, { chest_name = GetSkinName(self.view_currency_for_def.item_type) }) )
                    purchasefn( self, self.view_currency_for_def, sale_active and self.view_currency_for_def.sale_percent or 0)
                end
            end

            local new_bolts = TheInventory:GetVirtualIAPCurrencyAmount()
            if new_bolts ~= self.bolts then
                self.virutal_currency_count:SetCount(new_bolts, true)
                self.bolts = new_bolts
            end
        end
    end
end

function PurchasePackScreen:UpdateFilterToItem(item_key)
    self.initial_item_key = item_key

    local type_options = build_type_options( self.initial_item_key )

    self.filters[FILTER_TYPE_INDEX].spinner:SetOptions(type_options)
    self.filters[FILTER_TYPE_INDEX].spinner:SetSelected(self.initial_item_key)
end


function PurchasePackScreen:OnBecomeActive()
    PurchasePackScreen._base.OnBecomeActive(self)

    if not self.shown then
        self:Show()
    end

    self:RefreshScreen()

    self.leaving = nil

    --Just in-case we came direct from the main menu, the music might not be playing
    if not TheFrontEnd:GetSound():PlayingSound("FEMusic") and (self.prev_screen == nil or self.prev_screen.musictask == nil) then
        self.started_sound = true
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/music/jukebox", "FEMusic")
    end

    DisplayInventoryFailedPopup( self )
end

function PurchasePackScreen:Close()
    if self.started_sound then
        TheFrontEnd:GetSound():KillSound("FEMusic")
    end
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
--TheSim:ProfilerPush("PurchasePackScreen:OnUpdate")

    self.update_timer = self.update_timer + dt
    if self.update_timer > 1.0 then
        self.update_timer = 0
		if self.purchase_root.scroll_window then
			self.purchase_root.scroll_window.grid:RefreshView()
		end
    end

--TheSim:ProfilerPop()
end


return PurchasePackScreen

