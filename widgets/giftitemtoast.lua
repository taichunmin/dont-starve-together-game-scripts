local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local UIAnimButton = require "widgets/uianimbutton"

-- Where the toast is supposed to be when it's active
local down_pos = -200
local last_click_time = 0 -- V2C: s'ok to be static
local TIMEOUT = 1

local GiftItemToast = Class(Widget, function(self, owner)
    Widget._ctor(self, "GiftItemToast")

    self.owner = owner
    self.root = self:AddChild(Widget("ROOT"))

    self.tab_gift = self.root:AddChild(UIAnimButton("tab_gift", "tab_gift", nil, nil, "off", nil, nil))
    self.tab_gift:Disable()

    self.tab_gift:SetTooltip(STRINGS.UI.ITEM_SCREEN.DISABLED_TOAST_TOOLTIP)
    self.tab_gift:SetTooltipPos(0, -40, 0)

    self.inst:ListenForEvent("giftreceiverupdate", function(player, data)
        self:OnToast(data.numitems)
        if data.active then
            self:EnableClick()
        else
            self:DisableClick()
        end
    end, ThePlayer)

    self.inst:ListenForEvent("continuefrompause", function() self:UpdateControllerHelp() end, TheWorld)

    self.tab_gift:SetOnClick(function() self:DoOpenGift() end)
    self.tab_gift:SetOnFocus( -- Play the active animation
        function()
            self.tab_gift.animstate:PlayAnimation("active_pre", false)
            self.tab_gift:SetLoop("active_loop", true)
            self.tab_gift.animstate:PushAnimation("active_loop", true)
        end
    )

    self.numitems = 0
    self.controller_hide = false
    self.craft_hide = false
    self.opened = false
    self.enabled = false
    last_click_time = 0

    self.hud_focus = owner.HUD.focus
end)

-- Moves the toast up or down
function GiftItemToast:UpdateElements()
    local from = self.root:GetPosition()
    if not self.controller_hide and not self.craft_hide and self.numitems > 0 then
        if not self.opened then
            self.opened = true
            last_click_time = 0

            local to = Vector3(0, down_pos, 0)

            -- We don't need to move if we're already in position
            if from ~= to then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_DOWN")
                self.root:MoveTo(from, to, 1.0,
                    function()
                        --check we're still opened, cuz we don't cancel MoveTo
                        if self.opened then
                            --[[
                            --V2C: sounds bad...
                            if self:IsVisible() then
                                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_BOTTOM_HIT")
                            end]]
                            -- Not checking :IsEnabled(), because that inherits parent properties
                            -- whereas we want to know if the immediate widget is enabled or not.
                            if self.tab_gift.enabled then
                                self:OnClickEnabled()
                            end
                        end
                    end
                )
            end
        end
    elseif self.opened then
        self.opened = false
        local to = Vector3(0, 0, 0)
        if from ~= to then
            if self:IsVisible() then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_UP")
            end
            self.root:MoveTo(from, to, 0.5, nil)
        end
        self:UpdateControllerHelp()
    end
end

function GiftItemToast:ToggleHUDFocus(focus)
    self.hud_focus = focus
    self:UpdateControllerHelp()
end

function GiftItemToast:ToggleController(hide)
    self.controller_hide = hide
    self:UpdateElements()
end

function GiftItemToast:ToggleCrafting(hide)
    self.craft_hide = hide
    self:UpdateElements()
end

function GiftItemToast:OnToast(num)
    if num == 0 then
        self.tab_gift:Disable()
    end

    self.numitems = num

    self:UpdateElements()
end

--Called from PlayerHud:OnControl
function GiftItemToast:CheckControl(control, down)
    if self.shown and down and self.enabled and control == CONTROL_CONTROLLER_ATTACK and
        self.owner.components.playercontroller:GetControllerAttackTarget() == nil then
        self:DoOpenGift()
        return true
    end
end

function GiftItemToast:DoOpenGift()
    if not self.owner:HasTag("busy") then
        local time = GetTime()
        if time - last_click_time > TIMEOUT then
            last_click_time = time
            if not TheWorld.ismastersim then
                SendRPCToServer(RPC.OpenGift)
            elseif self.owner.components.giftreceiver ~= nil then
                self.owner.components.giftreceiver:OpenNextGift()
            end
        end
    end
end

function GiftItemToast:EnableClick()
    if self.numitems > 0 then
        self.tab_gift:Enable()
        last_click_time = 0

        local current_pos = self.root:GetPosition()
        if current_pos.y == down_pos then
            self:OnClickEnabled()
        end
    end
end

-- Handles animation stuff and such
function GiftItemToast:OnClickEnabled()
    if not self.tab_gift.animstate:IsCurrentAnimation("active_pre") then
        self.tab_gift.animstate:PlayAnimation("active_pre", false)
        self.tab_gift:SetLoop("active_loop", true)
        self.tab_gift.animstate:PushAnimation("active_loop", true)
    end

    self.tab_gift:SetTooltip(STRINGS.UI.ITEM_SCREEN.ENABLED_TOAST_TOOLTIP)

    if self:IsVisible() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_tab_active")
    end
    self.enabled = true
    self:UpdateControllerHelp()
end

function GiftItemToast:DisableClick()
    self.tab_gift:Disable()
    self.tab_gift:SetTooltip(STRINGS.UI.ITEM_SCREEN.DISABLED_TOAST_TOOLTIP)
    self.enabled = false
    self:UpdateControllerHelp()
end

function GiftItemToast:UpdateControllerHelp()
    if TheInput:ControllerAttached() then
        if self.enabled and self.opened and self.hud_focus then
            if self.controller_help == nil then
                self.controller_help = self.tab_gift:AddChild(Text(UIFONT, 30))
                self.controller_help:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_CONTROLLER_ATTACK).." "..STRINGS.UI.HUD.OPENGIFT)
                self.controller_help:SetPosition(0, -70, 0)
                self.controller_help:Hide()
            end
            self:StartUpdating()
        elseif self.controller_help ~= nil then
            self.controller_help:Hide()
            self:StopUpdating()
        end
    elseif self.controller_help ~= nil then
        self.controller_help:Kill()
        self.controller_help = nil
        self:StopUpdating()
    end
end

function GiftItemToast:OnUpdate()
    if self.owner.components.playercontroller:GetControllerAttackTarget() == nil then
        self.controller_help:Show()
    else
        self.controller_help:Hide()
    end
end

return GiftItemToast
