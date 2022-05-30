local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local UIAnimButton = require "widgets/uianimbutton"

-- Where the toast is supposed to be when it's active
local down_pos = -200

local TIMEOUT = 1

local YotbToast = Class(Widget, function(self, owner)
    Widget._ctor(self, "YotbToast")

    self.owner = owner
    self.root = self:AddChild(Widget("ROOT"))

    self.tab_gift = self.root:AddChild(UIAnimButton("tab_yotb", "tab_yotb", nil, nil, "off", nil, nil))
    self.tab_gift:Disable()

    self.tab_gift:SetTooltip(STRINGS.UI.ITEM_SCREEN.DISABLED_YOTB_TOOLTIP)
    self.tab_gift:SetTooltipPos(0, -40, 0)

    self.inst:ListenForEvent("yotbskinupdate", function(player, data)
       self:UpdateElements()
    end, ThePlayer)

    self.inst:ListenForEvent("continuefrompause", function() self:UpdateControllerHelp() end, TheWorld)

    self.tab_gift:SetOnFocus( -- Play the active animation
        function()
            self.tab_gift.animstate:PlayAnimation("active_pre", false)
            self.tab_gift:SetLoop("active_loop", true)
            self.tab_gift.animstate:PushAnimation("active_loop", true)
        end
    )

    self.controller_hide = false
    self.craft_hide = false
    self.opened = false

    self.hud_focus = owner.HUD.focus
end)

-- Moves the toast up or down
function YotbToast:UpdateElements()
    local from = self.root:GetPosition()

    if not self.controller_hide and not self.craft_hide and self.owner.player_classified and self.owner.player_classified.hasyotbskin and self.owner.player_classified.hasyotbskin:value() then
        if not self.opened then
            self.opened = true
            local to = Vector3(0, down_pos, 0)

            -- We don't need to move if we're already in position
            if from ~= to then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_DOWN")
                self.root:MoveTo(from, to, 1.0, nil)
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

function YotbToast:ToggleHUDFocus(focus)
    self.hud_focus = focus
    self:UpdateControllerHelp()
end

function YotbToast:ToggleController(hide)
    self.controller_hide = hide
    self:UpdateElements()
end

function YotbToast:ToggleCrafting(hide)
    self.craft_hide = hide
    self:UpdateElements()
end

--Called from PlayerHud:OnControl
function YotbToast:CheckControl(control, down)
    if self.shown and down and control == CONTROL_CONTROLLER_ATTACK and
        self.owner.components.playercontroller:GetControllerAttackTarget() == nil then
        return true
    end
end

function YotbToast:UpdateControllerHelp()
    if TheInput:ControllerAttached() then
        if self.opened and self.hud_focus then
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

function YotbToast:OnUpdate()
    if self.owner.components.playercontroller:GetControllerAttackTarget() == nil then
        self.controller_help:Show()
    else
        self.controller_help:Hide()
    end
end

return YotbToast
