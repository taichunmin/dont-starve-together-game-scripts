local AccountItemFrame = require "widgets/redux/accountitemframe"
local Image = require "widgets/image"
local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local TEMPLATES = require("widgets/redux/templates")

require("skinsutils")


local BarterScreen = Class(Screen, function(self, user_profile, prev_screen, item_key, is_buying, owned_count, barter_success_cb)
	Screen._ctor(self, "BarterScreen")
    self.user_profile = user_profile
    self.prev_screen = prev_screen

    assert(item_key)
    self.item_key = item_key
    self.is_buying = is_buying
    self.owned_count = owned_count
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
    local commerce_popup = GenericWaitingPopup("ItemServerContactPopup", STRINGS.UI.ITEM_SERVER.CONNECT, nil, true)
    TheFrontEnd:PushScreen(commerce_popup)
    return commerce_popup
end

local function ShowGenericError(...)
    print(...)
    local server_error = PopupDialogScreen(
        STRINGS.UI.TRADESCREEN.SERVER_ERROR_TITLE,
        STRINGS.UI.TRADESCREEN.SERVER_ERROR_BODY,
        {
            {
                text = STRINGS.UI.TRADESCREEN.OK,
                cb = function()
                    SimReset()
                end
            }
        }
    )
    TheFrontEnd:PushScreen(server_error)
end

function BarterScreen:_BuildDialog()
    local current_doodads = TheInventory:GetCurrencyAmount()
    local doodad_sign = nil
    local go_btn = nil
    local go_btn_STOP = nil -- NOTES(JBK): There is an unknown race condition here that this is working around to help prevent players accidentally doing an action more than once in a single dialogue.
    local go_dupe_btn = nil
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
                if go_btn_STOP then
                    ShowGenericError("ERR: Tried to weave an item twice with one dialogue?", self.item_key)
                    return
                end
                go_btn_STOP = true
                local commerce_popup = PushWaitingPopup()
                TheItems:BarterGainItem(self.item_key, self.doodad_value, function(success, status, item_type)
                    self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                        commerce_popup:Close()
                        self:_BarterComplete(success, status,{"dontstarve/HUD/Together_HUD/collectionscreen/weave","dontstarve/HUD/Together_HUD/collectionscreen/unlock"})
                    end, self)
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
                if go_btn_STOP then
                    ShowGenericError("ERR: Tried to unravel an item twice with one dialogue?", self.item_key)
                    return
                end
                go_btn_STOP = true
                local item_id = GetFirstOwnedItemId(self.item_key)
                if item_id then
                    local commerce_popup = PushWaitingPopup()
                    TheItems:BarterLoseItem(item_id, self.doodad_value, function(success, status)
                        self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                            commerce_popup:Close()
                            self:_BarterComplete(success, status, {"dontstarve/HUD/Together_HUD/collectionscreen/unweave"})
                        end, self)
                    end)
                else
                    ShowGenericError("ERR: Bartering away unowned item.")
                    return
                end
            end
        }

        if self.owned_count > 1 then
            go_dupe_btn = {
                text = STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND_DUPES,
                cb = function()
                    local grind_count = self.owned_count - 1
                    local spool_gained = grind_count * self.doodad_value

                    local PopupDialogScreen = require "screens/redux/popupdialog"
                    local body_str = ""
                    if grind_count == 1 then
                        body_str = subfmt(STRINGS.UI.BARTERSCREEN.CONFIRM_GRIND_DUPE_FMT, {
                            doodad_count = spool_gained,
                            doodad_net = current_doodads + spool_gained }
                        )
                    else
                        body_str = subfmt(STRINGS.UI.BARTERSCREEN.CONFIRM_GRIND_DUPES_FMT, {
                            doodad_count = spool_gained,
                            count = grind_count,
                            doodad_net = current_doodads + spool_gained }
                        )
                    end
                    local dupes_popup = PopupDialogScreen(STRINGS.UI.BARTERSCREEN.COMMERCE_GRIND_DUPES, body_str,
                    {
                        {
                            text=STRINGS.UI.POPUPDIALOG.OK,
                            cb = function()
                                TheFrontEnd:PopScreen()

                                local commerce_popup = PushWaitingPopup()
                                TheItems:BarterLoseDuplicateItems(self.item_key, self.doodad_value, function(success, status)
                                    self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                                        commerce_popup:Close()
                                        self:_BarterComplete(success, status, {"dontstarve/HUD/Together_HUD/collectionscreen/unweave"})
                                    end, self)
                                end)
                            end
                        },
                        {
                            text=STRINGS.UI.BARTERSCREEN.CANCEL,
                            cb = function()
                                TheFrontEnd:PopScreen()
                            end
                        },
                    })
                    TheFrontEnd:PushScreen(dupes_popup)
                end
            }
        end
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
    if go_dupe_btn ~= nil then
        buttons[3] = buttons[2]
        buttons[2] = go_dupe_btn
    end

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
    self.prev_screen.launched_commerce = nil
    TheFrontEnd:PopScreen()
end

function BarterScreen:_BarterComplete(success, status, sounds)
    self.prev_screen.launched_commerce = nil
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

function BarterScreen:OnControl(control, down)
    if BarterScreen._base.OnControl(self,control, down) then
        return true
    end

    if TheInput:ControllerAttached() and control == CONTROL_CANCEL and not down then
        self:_OnCancel()
    end
end

function BarterScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if TheInput:ControllerAttached() then
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end

    return table.concat(t, "  ")
end

return BarterScreen
