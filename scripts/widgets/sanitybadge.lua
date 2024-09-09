local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local SANITY_TINT = { 232 / 255, 123 / 255, 15 / 255, 1 }
local LUNACY_TINT = { 191 / 255, 232 / 255, 240 / 255, 1 }

local function OnGhostDeactivated(inst)
    if inst.AnimState:IsCurrentAnimation("ghost_deactivate") then
        inst.widget:Hide()
    end
end

local SanityBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, SANITY_TINT, "status_sanity", nil, nil, true)

    self.sanitymode = SANITY_MODE_INSANITY

    self.topperanim = self.underNumber:AddChild(UIAnim())
    self.topperanim:GetAnimState():SetBank("status_meter")
    self.topperanim:GetAnimState():SetBuild("status_meter")
    self.topperanim:GetAnimState():PlayAnimation("anim")
    self.topperanim:GetAnimState():AnimateWhilePaused(false)
    self.topperanim:GetAnimState():SetMultColour(0, 0, 0, 1)
    self.topperanim:SetScale(1, -1, 1)
    self.topperanim:SetClickable(false)
    self.topperanim:GetAnimState():SetPercent("anim", 1)

    self.circleframe:GetAnimState():Hide("frame")
    self.circleframe2 = self.underNumber:AddChild(UIAnim())
    self.circleframe2:GetAnimState():SetBank("status_sanity")
    self.circleframe2:GetAnimState():SetBuild("status_sanity")
    self.circleframe2:GetAnimState():OverrideSymbol("frame_circle", "status_meter", "frame_circle")
    self.circleframe2:GetAnimState():Hide("FX")
    self.circleframe2:GetAnimState():PlayAnimation("frame")
    self.circleframe2:GetAnimState():AnimateWhilePaused(false)

    self.sanityarrow = self.underNumber:AddChild(UIAnim())
    self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
    self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
    self.sanityarrow:GetAnimState():PlayAnimation("neutral")
    self.sanityarrow:GetAnimState():AnimateWhilePaused(false)
    self.sanityarrow:SetClickable(false)

    self.ghostanim = self.underNumber:AddChild(UIAnim())
    self.ghostanim:GetAnimState():SetBank("status_sanity")
    self.ghostanim:GetAnimState():SetBuild("status_sanity")
    self.ghostanim:GetAnimState():PlayAnimation("ghost_deactivate")
    self.ghostanim:GetAnimState():AnimateWhilePaused(false)
    self.ghostanim:Hide()
    self.ghostanim:SetClickable(false)
    self.ghostanim.inst:ListenForEvent("animover", OnGhostDeactivated)

    self.val = 100
    self.max = 100
    self.penaltypercent = 0
    self.ghost = false

    self:StartUpdating()
end)

function SanityBadge:DoTransition()
	local new_sanity_mode = self.owner.replica.sanity:GetSanityMode()
	if self.sanitymode ~= new_sanity_mode then
		self.sanitymode = new_sanity_mode
        if self.sanitymode == SANITY_MODE_INSANITY then
            self.backing:GetAnimState():ClearOverrideSymbol("bg")
            self.anim:GetAnimState():SetMultColour(unpack(SANITY_TINT))
            self.circleframe:GetAnimState():OverrideSymbol("icon", "status_sanity", "icon")
        else
            self.backing:GetAnimState():OverrideSymbol("bg", "status_sanity", "lunacy_bg")
            self.anim:GetAnimState():SetMultColour(unpack(LUNACY_TINT))
            self.circleframe:GetAnimState():OverrideSymbol("icon", "status_sanity", "lunacy_icon")
        end
	    Badge.SetPercent(self, self.val, self.max) -- refresh the animation
	end
	self.transition_task = nil
end

local function RemoveFX(fxinst)
    fxinst.widget:Kill()
end

function SanityBadge:SpawnTransitionFX(anim)
    if self.parent ~= nil then
        local fx = self.parent:AddChild(UIAnim())
        fx:SetPosition(self:GetPosition())
        fx:SetClickable(false)
        fx.inst:ListenForEvent("animover", RemoveFX)
        fx:GetAnimState():SetBank("status_sanity")
        fx:GetAnimState():SetBuild("status_sanity")
        fx:GetAnimState():Hide("frame")
        fx:GetAnimState():PlayAnimation(anim)
    end
end

function SanityBadge:SetPercent(val, max, penaltypercent)
    self.val = val
    self.max = max
    Badge.SetPercent(self, self.val, self.max)

    self.penaltypercent = penaltypercent or 0
    self.topperanim:GetAnimState():SetPercent("anim", 1 - self.penaltypercent)

	local sanity = self.owner.replica.sanity

	if sanity:GetSanityMode() ~= self.sanitymode then
		if self.transition_task ~= nil then
			self.transition_task:Cancel()
			self.transition_task = nil
			self:DoTransition()
		end
		if self:IsVisible() then
            if self.sanitymode ~= SANITY_MODE_INSANITY then
                self.circleframe2:GetAnimState():PlayAnimation("transition_sanity")
                self:SpawnTransitionFX("transition_sanity")
            else
                self.circleframe2:GetAnimState():PlayAnimation("transition_lunacy")
                self:SpawnTransitionFX("transition_lunacy")
            end
			self.circleframe2:GetAnimState():PushAnimation("frame", false)
			self.transition_task = self.owner:DoTaskInTime(6 * FRAMES, function() self:DoTransition() end)
		else
			self:DoTransition()
		end
    end
end

function SanityBadge:PulseGreen()
	if self.sanitymode == SANITY_MODE_LUNACY then
		Badge.PulseRed(self)
	else
		Badge.PulseGreen(self)
	end
end

function SanityBadge:PulseRed()
	if self.sanitymode == SANITY_MODE_LUNACY then
		Badge.PulseGreen(self)
	else
		Badge.PulseRed(self)
	end
end

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function SanityBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    local sanity = self.owner.replica.sanity
    local anim = "neutral"
    local ghost = false

    if sanity ~= nil then
        if self.owner:HasTag("sleeping") then
            --Special case for sleeping: at night, sanity will ping between .9999 and 1 of max, so make an exception for the arrow
            if sanity:GetPercentWithPenalty() < 1 then
                anim = "arrow_loop_increase"
            end
        else
            local ratescale = sanity:GetRateScale()
            if ratescale == RATE_SCALE.INCREASE_LOW or
                ratescale == RATE_SCALE.INCREASE_MED or
                ratescale == RATE_SCALE.INCREASE_HIGH then
                if sanity:GetPercentWithPenalty() < 1 then
                    anim = RATE_SCALE_ANIM[ratescale]
                end
            elseif ratescale == RATE_SCALE.DECREASE_LOW or
                ratescale == RATE_SCALE.DECREASE_MED or
                ratescale == RATE_SCALE.DECREASE_HIGH then
                if sanity:GetPercentWithPenalty() > 0 then
                    anim = RATE_SCALE_ANIM[ratescale]
                end
            end
        end
        ghost = sanity:IsGhostDrain()
    end

    if self.arrowdir ~= anim then
        self.arrowdir = anim
        self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
    end

    if self.ghost ~= ghost then
        self.ghost = ghost
        if ghost then
            self.ghostanim:GetAnimState():PlayAnimation("ghost_activate")
            self.ghostanim:GetAnimState():PushAnimation("ghost_idle", true)
            self.ghostanim:Show()
        else
            self.ghostanim:GetAnimState():PlayAnimation("ghost_deactivate")
        end
    end
end

return SanityBadge
