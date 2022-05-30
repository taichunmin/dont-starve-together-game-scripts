local Widget = require "widgets/widget"
local Button = require "widgets/button"
local UIAnim = require "widgets/uianim"

local UIAnimButton = Class(Button, function(self, bank, build, idle_anim, focus_anim, disabled_anim, down_anim, selected_anim)
    Button._ctor(self, "UIAnimButton")

    self.uianim = self:AddChild(UIAnim())
    --self.uianim:MoveToBack()

    self.animstate = self.uianim:GetAnimState()
    self.animstate:SetBuild(build)
    self.animstate:SetBank(bank)

    self.loops = {}

    self:SetAnimations(idle_anim, focus_anim, disabled_anim, down_anim, selected_anim)

end)

function UIAnimButton:OnGainFocus()
    UIAnimButton._base.OnGainFocus(self)
    if self:IsSelected() then return end

    if self:IsEnabled() then
        if self.focusanimation and not self.animstate:IsCurrentAnimation(self.focusanimation) then
            self.animstate:PlayAnimation(self.focusanimation, self.loops[self.focusanimation])
        end
        if self.onfocus then
            self.onfocus()
        end
    end
end

function UIAnimButton:OnLoseFocus()
    UIAnimButton._base.OnLoseFocus(self)

    if self:IsSelected() then return end

    if self:IsEnabled() and self.idleanimation and not self.animstate:IsCurrentAnimation(self.idleanimation) then
        self.animstate:PlayAnimation(self.idleanimation, self.loops[self.idleanimation])
    end

end

function UIAnimButton:OnControl(control, down)
    --UIAnimButton._base.OnControl(self, control, down)
    if not self:IsEnabled() or not self.focus or self:IsSelected() then return end

    if control == self.control then
        if down then
            if self.downanimation and not self.animstate:IsCurrentAnimation(self.downanimation) then
                self.animstate:PlayAnimation(self.downanimation, self.loops[self.downanimation])
            end

            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")

            self.down = true
            if self.whiledown then
                self:StartUpdating()
            end
            if self.ondown then
                self.ondown()
            end
        else
            if self.downanimation and not self.animstate:IsCurrentAnimation(self.focusanimation) then
                self.animstate:PlayAnimation(self.focusanimation, self.loops[self.focusanimation])
            end
            self.down = false
            if self.onclick then
                self.onclick()
            end
            self:StopUpdating()
        end
        return true
    end
end

function UIAnimButton:OnEnable()
    UIAnimButton._base.OnEnable(self)
    if self.focus then
        self:OnGainFocus()
    else
        self:OnLoseFocus()
    end
end

function UIAnimButton:OnDisable()
    UIAnimButton._base.OnDisable(self)
    if not self.animstate:IsCurrentAnimation(self.disabledanimation) then
        self.animstate:PlayAnimation(self.disabledanimation, self.loops[self.disabledanimation])
    end
end

function UIAnimButton:OnSelect()
    UIAnimButton._base.OnSelect(self)
    if not self.animstate:IsCurrentAnimation(self.selectedanimation) then
        self.animstate:PlayAnimation(self.selectedanimation, self.loops[self.selectedanimation])
    end
end

function UIAnimButton:OnUnselect()
    UIAnimButton._base.OnUnselect(self)
    if self:IsEnabled() then
        self:OnEnable()
    else
        self:OnDisable()
    end
end

function UIAnimButton:SetOnFocus(fn)
    if fn then
        self.onfocus = fn
    end
end

function UIAnimButton:SetAnimations(idle_anim, focus_anim, disabled_anim, down_anim, selected_anim, loop)
    self:SetIdleAnim(idle_anim, false)
    self:SetFocusAnim(focus_anim, false)
    self:SetDisabledAnim(disabled_anim, false)
    self:SetDownAnim(down_anim, false)
    self:SetSelectedAnim(selected_anim, false)
end

function UIAnimButton:SetLoop(animation_name, loop)
    if animation_name and loop then
        self.loops[animation_name] = loop
    end

    if self.animstate:IsCurrentAnimation(animation_name) then
        self.animstate:PlayAnimation(animation_name, loop)
    end
end

-- This was made with a very specific reason in mind (check EnableClick on giftitemtoast.lua),
-- basically we want to replace an animation after it stopped playing. I didn't think writing
-- equivalent functions for the other states was worth the time, but be my guest
function UIAnimButton:PushIdleAnim(idle_anim)
     if idle_anim then
        self.idleanimation = idle_anim
    end

    if self:IsEnabled() and not self.focus and not self.selected then
        self.animstate:PushAnimation(self.idleanimation, self.loops[idle_anim])
    end
end

function UIAnimButton:SetIdleAnim(idle_anim, loop)

    if not idle_anim then return end

    self:SetLoop(idle_anim, loop)
    self.idleanimation = idle_anim

    if self:IsEnabled() and not self.focus and not self.selected and not self.animstate:IsCurrentAnimation(self.idleanimation) then
        self.animstate:PlayAnimation(self.idleanimation, self.loops[idle_anim])
    end
end

function UIAnimButton:SetFocusAnim(focus_anim, loop)

    if not focus_anim then return end

    self:SetLoop(focus_anim, loop)
    self.focusanimation = focus_anim

    if self.focus and not self.selected and not self.animstate:IsCurrentAnimation(self.focusanimation) then
        self.animstate:PlayAnimation(self.focusanimation, self.loops[focus_anim])
    end
end

function UIAnimButton:SetDisabledAnim(disabled_anim, loop)

    if not disabled_anim then return end

    self:SetLoop(disabled_anim, loop)
    self.disabledanimation = disabled_anim

    if not self:IsEnabled() and not self.animstate:IsCurrentAnimation(self.disabledanimation) then
       self.animstate:PlayAnimation(self.disabledanimation, self.loops[disabled_anim])
    end
end

function UIAnimButton:SetDownAnim(down_anim, loop)

    if not down_anim then return end

    self:SetLoop(down_anim, loop)
    self.downanimation = down_anim

    if self.down and self:IsEnabled() and not self.animstate:IsCurrentAnimation(self.downanimation) then
        self.animstate:PlayAnimation(self.downanimation, self.loops[down_anim])
    end
end

function UIAnimButton:SetSelectedAnim(selected_anim, loop)

    if not selected_anim then return end

    self:SetLoop(selected_anim, loop)
    self.selectedanimation = selected_anim

    if self.selected and not self.animstate:IsCurrentAnimation(self.selectedanimation) then
        self.animstate:PlayAnimation(self.selectedanimation, self.loops[selected_anim])
    end
end

return UIAnimButton