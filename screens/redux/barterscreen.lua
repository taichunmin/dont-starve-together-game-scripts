local AccountItemFrame = require "widgets/redux/accountitemframe"
local Image = require "widgets/image"
local ItemServerContactPopup = require "screens/redux/itemservercontactpopup"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local TEMPLATES = require("widgets/redux/templates")

require("skinsutils")


local BarterScreen = Class(Screen, function(self, user_profile, prev_screen, item_key, is_buying, barter_success_cb)
	Screen._ctor(self, "BarterScreen")
    self.user_profile = user_profile
    self.prev_screen = prev_screen

    assert(item_key)
    self.item_key = item_key
    self.is_buying = is_buying
    self.barter_success_cb = barter_success_cb

	self:DoInit()

	self.default_focus = self.dialog
end)

function BarterScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.black = self.root:AddChild(TEMPLATES.BackgroundTint())

	self.dialog = self.root:AddChild(self:_BuildDialog())
end

local function PushWaitingPopup()
    local commerce_popup = ItemServerContactPopup()
    TheFrontEnd:PushScreen(commerce_popup)
    return commerce_popup
end

function BarterScreen:_BuildDialog()
    local current_doodads = TheInventory:GetCurrencyAmount()
    local doodad_sign = nil
    local go_btn = nil
    local barter_text = nil
    if self.is_buying then
        doodad_sign = -1
        self.doodad_value = TheItems:GetBarterBuyPrice(self.item_key)
        self.doodad_net = current_doodads - self.doodad_value
        barter_text = subfmt(STRINGS.UI.BARTERSCREEN.CONFIRM_BUY_FMT, {
                doodad_count = self.doodad_value,
                item_name = GetSkinName(self.item_key),
                doodad_net = self.doodad_net,
            })
        go_btn = {
            text = STRINGS.UI.BARTERSCREEN.COMMERCE_BUY,
            cb = function() 
                local commerce_popup = PushWaitingPopup()
                TheItems:BarterGainItem(self.item_key, self.doodad_value, function(success, status, item_type)
                    commerce_popup:Close()
                    self:_BarterComplete(success, status,{"dontstarve/HUD/Together_HUD/collectionscreen/weave","dontstarve/HUD/Together_HUD/collectionscreen/unlock"})
                end)
            end
        }
    else
        doodad_sign = 1
        self.doodad_value = TheItems:GetBarterSellPrice(self.item_key)
        self.doodad_net = current_doodads + self.doodad_value
        barter_text = subfmt(STRINGS.UI.BARTERSCREEN.CONFIRM_GRIND_FMT, {
                doodad_count = self.doodad_value,
                item_name = GetSkinName(self.item_key),
                doodad_net = self.doodad_net,
            })
        go_btn = {
            text = STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND,
            cb = function() 
                local item_id = GetFirstOwnedItemId(self.item_key)
                if item_id then
                    local commerce_popup = PushWaitingPopup()
                    TheItems:BarterLoseItem(item_id, self.doodad_value, function(success, status)
                        commerce_popup:Close()
                        self:_BarterComplete(success, status, {"dontstarve/HUD/Together_HUD/collectionscreen/unweave"})
                    end)
                else
					local server_error = PopupDialogScreen(
                        STRINGS.UI.TRADESCREEN.SERVER_ERROR_TITLE,
                        STRINGS.UI.TRADESCREEN.SERVER_ERROR_BODY,
						{
							{
                                text = STRINGS.UI.TRADESCREEN.OK,
                                cb = function()
									print("ERROR: Bartering away unowned item.")
									SimReset()
								end
                            }
						}
					)
					TheFrontEnd:PushScreen(server_error)
                end
            end
        }
    end

    local buttons = {
        go_btn,
        {
            text=STRINGS.UI.BARTERSCREEN.CANCEL,
            cb = function() 
                self:_OnCancel()            
            end
        },
    }

    -- Not enough -- must be buying. Replace all options with cancel.
    if self.doodad_net < 0 then
        barter_text = subfmt(STRINGS.UI.BARTERSCREEN.FAIL_BUY_FMT, {
                doodad_count = self.doodad_value,
                item_name = GetSkinName(self.item_key),
                doodad_net = self.doodad_net * -1,
            })
        buttons = {
            {
                text = STRINGS.UI.BARTERSCREEN.OK,
                cb = function() 
                    self:_OnCancel()
                end
            },
        }
    end

	local dialog = TEMPLATES.CurlyWindow(600, 420, STRINGS.UI.BARTERSCREEN.TITLE, buttons, nil, barter_text)

    dialog.illustration = dialog:AddChild(Widget("illustration"))
	dialog.illustration:SetPosition(0, 130)
	dialog.body:SetPosition(0, -60) -- adjust body to fit illustration

    dialog.illustration.turnsinto = dialog.illustration:AddChild(Image("images/ui.xml", "crafting_inventory_arrow_r_hl.tex"))

    local illustration_spacing = 160

    dialog.illustration.doodad_image = dialog.illustration:AddChild(TEMPLATES.DoodadCounter(self.doodad_value))
	dialog.illustration.doodad_image:SetPosition(illustration_spacing * doodad_sign, 0)

	dialog.illustration.item_image = dialog.illustration:AddChild(AccountItemFrame()) 
	dialog.illustration.item_image:SetStyle_Normal()
	dialog.illustration.item_image:SetScale(1.65)
	dialog.illustration.item_image:SetItem(self.item_key)
	dialog.illustration.item_image:SetPosition(illustration_spacing * (-1 * doodad_sign), 0)

    return dialog
end

function BarterScreen:_OnCancel()
    TheFrontEnd:PopScreen()
end

function BarterScreen:_BarterComplete(success, status, sounds)
    if success then
        TheFrontEnd:PopScreen()

        for _,v in ipairs(sounds) do
            TheFrontEnd:GetSound():PlaySound(v)
        end

        if self.barter_success_cb then
            self.barter_success_cb()
        end
    else
        local server_error = PopupDialogScreen(STRINGS.UI.BARTERSCREEN.FAILED_TITLE, STRINGS.UI.BARTERSCREEN.FAILED_BODY, {
                {
                    text=STRINGS.UI.BARTERSCREEN.OK,
                    cb = function()
                        print("ERROR: Failed to contact the item server. status=", status )
                        TheFrontEnd:PopScreen()
                        SimReset()
                    end
                },
            })
        TheFrontEnd:PushScreen( server_error )
    end
end

return BarterScreen
