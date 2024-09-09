local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local UIAnimButton = require "widgets/uianimbutton"

-- Where the toast is supposed to be when it's active
local down_pos = -200

local TIMEOUT = 1

local SkillTreeToast = Class(Widget, function(self, owner, controls)
    Widget._ctor(self, "SkillTreeToast")
    self.controls = controls
    self.owner = owner
    self.root = self:AddChild(Widget("ROOT"))

    self.tab_gift = self.root:AddChild(UIAnimButton("tab_skills", "tab_skills", nil, nil, "off", nil, nil))
    self.tab_gift:Disable()

    self.tab_gift:SetLoop("active_loop", true)

    self.tab_gift:SetTooltip(STRINGS.SKILLTREE.NEW_SKILL_POINT)
    self.tab_gift:SetTooltipPos(0, -40, 0)

    self.inst:ListenForEvent("newskillpointupdated", function(player, data)
       self:UpdateElements()
    end, ThePlayer)

    self.inst:ListenForEvent("continuefrompause", function() self:UpdateControllerHelp() end, TheWorld)

    self.tab_gift:SetOnFocus( -- Play the active animation
        function()
            self.tab_gift:SetLoop("active_loop", true)
            self.tab_gift.animstate:PlayAnimation("active_loop", true)
        end
    )

    self.tab_gift:SetOnClick(function()
        ThePlayer.HUD:OpenPlayerInfoScreen()
    end)

    self.controller_hide = false
    self.craft_hide = false
    self.opened = false

    self.hud_focus = owner.HUD.focus
end)

function SkillTreeToast:EnableClick()
    --self.tab_gift:Enable()
   -- last_click_time = 0
    self.tab_gift:Enable()

    local current_pos = self.root:GetPosition()
    if current_pos.y == down_pos then
        self:OnClickEnabled()
    end
end

-- Handles animation stuff and such
function SkillTreeToast:OnClickEnabled()
    if not self.tab_gift.animstate:IsCurrentAnimation("active_pre") then        
        self.tab_gift.animstate:PlayAnimation("active_loop", true)
        self.tab_gift:SetLoop("active_loop", true)
    end
    --self.tab_gift:SetTooltip(STRINGS.UI.ITEM_SCREEN.ENABLED_TOAST_TOOLTIP)
    --[[
    if self:IsVisible() then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_tab_active")
    end
    ]]
    self.enabled = true
    self:UpdateControllerHelp()
end

function SkillTreeToast:DisableClick()
    self.tab_gift:Disable()
    --self.tab_gift:SetTooltip(STRINGS.UI.ITEM_SCREEN.DISABLED_TOAST_TOOLTIP)
    self.enabled = false
    self:UpdateControllerHelp()
end

-- Moves the toast up or down
function SkillTreeToast:UpdateElements()
    local from = self.root:GetPosition()

    if not self.controller_hide and not self.craft_hide and self.owner.player_classified and ThePlayer.new_skill_available_popup then 
        if not self.opened then
            self.controls:ManageToast(self)
            TheFrontEnd:GetSound():PlaySound("wilson_rework/ui/skillpoint_dropdown")
            self.opened = true
            local to = Vector3(0, down_pos, 0)

            -- We don't need to move if we're already in position
            if from ~= to then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_DOWN")
                self.root:MoveTo(from, to, 1.0,  function() self:EnableClick() end)
            end
        end
    elseif self.opened then
        self.opened = false
        local to = Vector3(0, 0, 0)
        self:DisableClick()
        if from ~= to then
            if self:IsVisible() then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/skin_drop_slide_gift_UP")
            end

            self.root:MoveTo(from, to, 0.5, function() self.controls:ManageToast(self,true) end)
        end
    end
    self:UpdateControllerHelp()
end

function SkillTreeToast:ToggleHUDFocus(focus)
    self.hud_focus = focus
    self:UpdateControllerHelp()
end

function SkillTreeToast:ToggleController(hide)
    self.controller_hide = hide
    self:UpdateElements()
end

function SkillTreeToast:ToggleCrafting(hide)
    self.craft_hide = hide
    self:UpdateElements()
end

--Called from PlayerHud:OnControl
function SkillTreeToast:CheckControl(control, down)
    if self.shown and down and control == CONTROL_INSPECT_SELF then
        return true
    end
end

function SkillTreeToast:UpdateControllerHelp()
    if TheInput:ControllerAttached() then
        if self.opened and self.hud_focus then
            if self.controller_help == nil then
                self.controller_help = self.tab_gift:AddChild(Text(UIFONT, 30))
                self.controller_help:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INSPECT).." "..STRINGS.UI.HUD.INSPECT_SELF)
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

function SkillTreeToast:OnUpdate()
    local playercontroller = ThePlayer.components.playercontroller
    local buffaction = TheInput:ControllerAttached() and playercontroller:GetInspectButtonAction(playercontroller:GetControllerTarget()) or nil
    if buffaction == nil then

        if TheInput:ControllerAttached() then
            if not self.tab_gift.animstate:IsCurrentAnimation("active_loop") then
                self.tab_gift:SetIdleAnim("active_loop",true)
                self.tab_gift:SetFocusAnim("active_loop",true)
                self.tab_gift.animstate:PlayAnimation("active_loop",true)
            end
        end
        self.controller_help:Show()
        return
    end

    if TheInput:ControllerAttached() then        
        if not self.tab_gift.animstate:IsCurrentAnimation("off") then
            self.tab_gift:SetIdleAnim("off",true)
            self.tab_gift:SetFocusAnim("off",true)
            self.tab_gift.animstate:PlayAnimation("off",true)
        end
    end
    self.controller_help:Hide()
end

return SkillTreeToast
