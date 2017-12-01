local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Image = require "widgets/image"
local OnlineStatus = require "widgets/onlinestatus"
local PopupDialogScreen = require "screens/redux/popupdialog"
local ItemServerContactPopup = require "screens/redux/itemservercontactpopup"
local ItemBoxOpenerPopup = require "screens/redux/itemboxopenerpopup"

local TEMPLATES = require("widgets/redux/templates")
local PURCHASE_INFO = require("skin_purchase_packs")
require("misc_items")


local PurchasePackScreen = Class(Screen, function(self, prev_screen, user_profile)
	Screen._ctor(self, "PurchasePackScreen")
    self.user_profile = user_profile
	self:DoInit()

	self.default_focus = self.purchase_root
end)

function PurchasePackScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())

    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())

    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.PURCHASEPACKSCREEN.TITLE, ""))
    self.onlinestatus = self.root:AddChild(OnlineStatus(true))

    self.purchase_root = self:_BuildPurchasePanel()
    
    if not TheInput:ControllerAttached() then 
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    TheFrontEnd:FadeBack()
                end
            ))
    end
end

local function IsEverythingPack(item_key)
    return item_key == "pack_gladiator_all"
end

local build_price = function( currency_code, cents )
	local whole = tostring(cents / 100)
	return currency_code .. " " .. whole
end
local PurchaseWidget = Class(Widget, function(self, screen_self)
	Widget._ctor(self, "PurchaseWidget")

	self.root  = self:AddChild(Widget("purchase_item_root"))
    self.root:SetScale(0.90)
    self.item_type = nil
        
    self.frame = self.root:AddChild(Image("images/fepanels_redux_shop_panel.xml", "shop_panel.tex"))
    self.frame:SetScale(0.55)
    self.frame:SetPosition(-10,-7)
    
    self.icon_root = self.root:AddChild(Widget("icon_root"))
	self.icon_root:SetPosition(-150, 0)

	self.icon_anim = self.icon_root:AddChild(UIAnim())
	self.icon_anim:GetAnimState():SetBuild("frames_comp")
	self.icon_anim:GetAnimState():SetBank("fr")
	self.icon_anim:GetAnimState():Hide("frame")
	self.icon_anim:GetAnimState():Hide("NEW")
	self.icon_anim:GetAnimState():PlayAnimation("icon")
	self.icon_anim:SetScale(1.75)

    self.icon_image = self.icon_root:AddChild(Image())
    self.icon_image:SetScale(0.35)
	
    self.text_root = self.root:AddChild(Widget("text_root"))
	self.text_root:SetPosition(60, 50)
	self.title = self.text_root:AddChild(Text(HEADERFONT, 25, nil, UICOLOURS.GOLD_SELECTED))
	self.text = self.text_root:AddChild(Text(CHATFONT, 22, nil, UICOLOURS.GREY))
	self.text:SetPosition(0, -55)
	self.text:SetRegionSize(245, 60)
	self.text:EnableWordWrap(true)

    local purchasefn = 
        function()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/purchase")

            local popup = ItemServerContactPopup()
            TheFrontEnd:PushScreen(popup)

            TheItems:StartPurchase(self.item_type, function(success, message)
                popup:Close()
                if success then
                    local display_items = PURCHASE_INFO.PACKS[self.item_type]
                    local options = {
                        allow_cancel = false,
                        box_build = "skinevent_set_popup",
                        use_bigportraits = IsEverythingPack(self.item_type),
                    }
                    if options.use_bigportraits then
                        options.box_build = "skinevent_all_popup"
                    end
                    -- Only show open celebration if we have items to show.
                    if display_items and #display_items > 1 then
                        local box_popup = ItemBoxOpenerPopup(screen_self, options, function(success_cb)
                            success_cb(display_items)
                        end)
                        TheFrontEnd:PushScreen(box_popup)
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
            end)
        end

    local onPurchaseClickFn = 
        function()
            if OwnsSkinPack(self.item_type) then
                local warning = PopupDialogScreen(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_TITLE, STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_DESC, 
                            {
                                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_OK, cb = function() 
                                    TheFrontEnd:PopScreen()
                                    purchasefn() 
                                end },
                                {text=STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_WARNING_CANCEL, cb = function() 
                                    TheFrontEnd:PopScreen()
                                end },
                            })
                TheFrontEnd:PushScreen( warning )    
            else
                purchasefn()
            end
        end

    self.button = self.text_root:AddChild(TEMPLATES.StandardButton(
            onPurchaseClickFn,
            nil,
            {250, 50}
        ))
    self.button:SetPosition(0, -120)

    self.OnGainFocus = function()
        PurchasePackScreen._base.OnGainFocus(self)
        screen_self.purchase_root.scroll_list:OnWidgetFocus(self)
    end
    
    self.focus_forward = self.button
end)

function PurchaseWidget:ApplyDataToWidget(iap_def)
    if iap_def and not iap_def.is_blank then
        self.item_type = iap_def.item_type

        local title = GetSkinName(self.item_type)
        local text = GetSkinDescription(self.item_type)
        local price = ""
        if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
            price = build_price( iap_def.currency_code, iap_def.cents )
        elseif PLATFORM == "WIN32_RAIL" then
            price = iap_def.rail_price .. " RMB"
        end
        self.button:SetText(subfmt(STRINGS.UI.PURCHASEPACKSCREEN.PURCHASE_BTN, {price = price}))

        -- TODO(dbriscoe): Pull this data from PURCHASE_INFO?
        local pack_images = {
            pack_gladiator_all          = { "images/frontend_redux.xml",               "all_gladiator_oval.tex" },
            pack_gladiator_wathgrithr   = { "bigportraits/wathgrithr_gladiator.xml",   "wathgrithr_gladiator_oval.tex" },
            pack_gladiator_waxwell      = { "bigportraits/waxwell_gladiator.xml",      "waxwell_gladiator_oval.tex" },
            pack_gladiator_webber       = { "bigportraits/webber_gladiator.xml",       "webber_gladiator_oval.tex" },
            pack_gladiator_wendy        = { "bigportraits/wendy_gladiator.xml",        "wendy_gladiator_oval.tex" },
            pack_gladiator_wes          = { "bigportraits/wes_gladiator.xml",          "wes_gladiator_oval.tex" },
            pack_gladiator_wickerbottom = { "bigportraits/wickerbottom_gladiator.xml", "wickerbottom_gladiator_oval.tex" },
            pack_gladiator_willow       = { "bigportraits/willow_gladiator.xml",       "willow_gladiator_oval.tex" },
            pack_gladiator_wilson       = { "bigportraits/wilson_gladiator.xml",       "wilson_gladiator_oval.tex" },
            pack_gladiator_winona       = { "bigportraits/winona_gladiator.xml",       "winona_gladiator_oval.tex" },
            pack_gladiator_wolfgang     = { "bigportraits/wolfgang_gladiator.xml",     "wolfgang_gladiator_oval.tex" },
            pack_gladiator_woodie       = { "bigportraits/woodie_gladiator.xml",       "woodie_gladiator_oval.tex" },
            pack_gladiator_wx78         = { "bigportraits/wx78_gladiator.xml",         "wx78_gladiator_oval.tex" },
        }

        self.icon_image:Hide()
        self.icon_anim:Hide()
        local image = pack_images[self.item_type]
        if image then
            self.icon_image:SetTexture(unpack(image))
            self.icon_image:Show()
        else
            self.icon_anim:GetAnimState():OverrideSkinSymbol("SWAP_ICON", GetBuildForItem(self.item_type), "SWAP_ICON")
            self.icon_anim:Show()
        end


        self.title:SetString(title)
        self.text:SetString(text)

        if IsEverythingPack(self.item_type) then
            self.frame:SetTexture("images/fepanels_redux_shop_panel_wide.xml", "shop_panel_wide.tex")
            self.frame:SetScale(0.542)
            self.frame:SetPosition(235, -7)
            self.icon_root:SetPosition(-35, 0)
            self.icon_image:SetScale(0.30)
            self.text_root:SetScale(1.2)
            self.text_root:SetPosition(390, 60)
            self.title:SetHAlign(ANCHOR_LEFT)
            self.title:SetRegionSize(500,25)
            self.text:SetHAlign(ANCHOR_LEFT)
            self.text:SetRegionSize(500,75)
            self.button:SetPosition(-128,-115)
        else
            self.frame:SetTexture("images/fepanels_redux_shop_panel.xml", "shop_panel.tex")
            self.frame:SetScale(0.55)
            self.frame:SetPosition(-10,-7)
            self.icon_root:SetPosition(-150, 0)
            self.icon_image:SetScale(0.35)
            self.text_root:SetScale(1)
            self.text_root:SetPosition(60, 50)
            self.title:SetHAlign(ANCHOR_MIDDLE)
            self.title:SetRegionSize(245, 60)
            self.text:SetHAlign(ANCHOR_MIDDLE)
            self.text:SetRegionSize(245, 60)
            self.button:SetPosition(0,-120)
        end

        self.root:Show()
    else
        -- Important that we hide a subelement and not self because
        -- TrueScrollList manages our visiblity!
        self.root:Hide()
    end
end

function PurchasePackScreen:_BuildPurchasePanel()
    local purchase_ss = self.root:AddChild(Widget("purchase_ss"))

    -- Overlay is how we display purchasing.
    if PLATFORM == "WIN32_RAIL" or TheNet:IsNetOverlayEnabled() then
        local unvalidated_iap_defs = TheItems:GetIAPDefs()
        local iap_defs = {}
        for i,iap in ipairs(unvalidated_iap_defs) do
            -- Don't show items unless we have data/strings to describe them.
            if MISC_ITEMS[iap.item_type] then
                table.insert(iap_defs, iap)
            end
        end
        if #iap_defs == 0 then
            local msg = STRINGS.UI.PURCHASEPACKSCREEN.NO_PACKS_FOR_SALE
            if IsAnyFestivalEventActive() then
                msg = STRINGS.UI.PURCHASEPACKSCREEN.FAILED_TO_LOAD
            end
            local dialog = purchase_ss:AddChild(TEMPLATES.CurlyWindow(400, 200, "", nil, nil, msg))
            purchase_ss.focus_forward = dialog
        else
            local function DisplayOrderSort(a,b)
                return MISC_ITEMS[a.item_type].display_order < MISC_ITEMS[b.item_type].display_order
            end
            table.sort(iap_defs, DisplayOrderSort)

            if IsEverythingPack(iap_defs[1].item_type) then
                -- Make space for the everything pack's double-wide widget.
                table.insert(iap_defs, 2, { is_blank = true })
            end

            local function ScrollWidgetsCtor(context, index)
                return PurchaseWidget( self )
            end
            local function ScrollWidgetApply(context, widget, data, index)
                widget:ApplyDataToWidget(data)
            end 
            purchase_ss.scroll_list = purchase_ss:AddChild(TEMPLATES.ScrollingGrid(
                    iap_defs,
                    {
                        context = {},
                        widget_width  = 440,
                        widget_height = 250,
                        num_visible_rows = 2.05,
                        num_columns      = 2,
                        item_ctor_fn = ScrollWidgetsCtor,
                        apply_fn     = ScrollWidgetApply,
                        scrollbar_offset = 20,
                    }
                ))

            purchase_ss.scroll_list:SetPosition(50,0)
            purchase_ss.focus_forward = purchase_ss.scroll_list
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





function PurchasePackScreen:OnBecomeActive()
    PurchasePackScreen._base.OnBecomeActive(self)

    if not self.shown then
        self:Show()
    end

    self.leaving = nil
end

function PurchasePackScreen:OnControl(control, down)
    if PurchasePackScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:FadeBack()
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
end


return PurchasePackScreen
