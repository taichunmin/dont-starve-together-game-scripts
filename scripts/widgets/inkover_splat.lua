local UIAnim = require "widgets/uianim"
--local Widget = require "widgets/widget"
--local Image = require "widgets/image"

local PRE = 1
local LOOP = 2
local PST = 3

local PRE_SPEED = 5 -- units per second.
local PST_SPEED = 0.5
local LOOPTIME = 2

local InkOver_splat =  Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self, "InkOver_splat")

    self.time = GetTime()

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self:GetAnimState():SetBank("ink_over")
    self:GetAnimState():SetBuild("ink_over")
    self:GetAnimState():PlayAnimation("ink")
    self:GetAnimState():AnimateWhilePaused(false)

    self:Hide()

end)

function InkOver_splat:Flash(anim)
    self.time = GetTime()
    self:Show()
    print(anim)
    anim = anim or "ink"

    --[[
    if math.random() > 0.5 then
        anim = anim .."2"
    end
    ]]
    self:GetAnimState():PlayAnimation(anim)
end

return InkOver_splat
