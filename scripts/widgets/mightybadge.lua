local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local TINT = { 12/255, 127/255, 86/255, 1 }
local OVERTINT = {113/255,47/255,128/255, 1}

local MightyBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, TINT, "status_wolfgang", nil, nil, true)

	self.cur_mighty_state = nil

    self.circleframe:GetAnimState():SetBank ("status_wolfgang")
    self.circleframe:GetAnimState():SetBuild("status_wolfgang")
	self.dont_animate_circleframe = true

    self.mightyarrow = self.underNumber:AddChild(UIAnim())
    self.mightyarrow:GetAnimState():SetBank("sanity_arrow")
    self.mightyarrow:GetAnimState():SetBuild("sanity_arrow")
    self.mightyarrow:GetAnimState():PlayAnimation("neutral")
    self.mightyarrow:SetClickable(false)
    self.mightyarrow:GetAnimState():AnimateWhilePaused(false)

    self:StartUpdating()
end)

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function MightyBadge:RefreshMightiness()
	local mighty_state = self.owner:GetCurrentMightinessState()

	if mighty_state ~= self.cur_mighty_state then
		if mighty_state == "mighty" then
			self.circleframe:GetAnimState():SetPercent("frame", 0)
		elseif mighty_state == "normal" then
			self.circleframe:GetAnimState():SetPercent("frame", 0.5)
		else
			self.circleframe:GetAnimState():SetPercent("frame", 1)
		end
		self.cur_mighty_state = mighty_state
	end
end

function MightyBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

	self:RefreshMightiness()

    if self.owner.GetMightinessRateScale then
        -- Update arrow
        local ratescale = self.owner:GetMightinessRateScale()
    
        local anim = "neutral"
        
        if ratescale == RATE_SCALE.INCREASE_LOW or
            ratescale == RATE_SCALE.INCREASE_MED or
            ratescale == RATE_SCALE.INCREASE_HIGH then
                anim = RATE_SCALE_ANIM[ratescale]
        elseif ratescale == RATE_SCALE.DECREASE_LOW or
            ratescale == RATE_SCALE.DECREASE_MED or
            ratescale == RATE_SCALE.DECREASE_HIGH then
                anim = RATE_SCALE_ANIM[ratescale]
        end

        if self.arrowdir ~= anim then
            self.arrowdir = anim
            self.mightyarrow:GetAnimState():PlayAnimation(anim, true)
        end
    end
end

function MightyBadge:SetPercent(val)

    local original_val = val
    local max = 100

    if val*100 > max then
        self.anim:GetAnimState():SetMultColour(unpack(OVERTINT))
        self.circleframe:GetAnimState():Hide("spikes")
        local newmax = 10
        if ThePlayer:HasTag("wolfgang_overbuff_5") then
           newmax = 50
        elseif ThePlayer:HasTag("wolfgang_overbuff_4") then
            newmax = 40
        elseif ThePlayer:HasTag("wolfgang_overbuff_3") then
            newmax = 30
        elseif ThePlayer:HasTag("wolfgang_overbuff_2") then
            newmax = 20
        end
        val = ((val * 100) -100) / newmax
    else
        self.anim:GetAnimState():SetMultColour(unpack(TINT))        
        self.circleframe:GetAnimState():Show("spikes")
    end        

    if self.circular_meter ~= nil then
        self.circular_meter:GetAnimState():SetPercent("meter", val)
    else
        self.anim:GetAnimState():SetPercent("anim", 1 - val)
        if self.circleframe ~= nil and not self.dont_animate_circleframe then
            self.circleframe:GetAnimState():SetPercent("frame", 1 - val)
        end
    end

    --print(val, max, val * max)
    self.num:SetString(tostring(math.ceil(original_val * max)))
    self.percent = val
end

return MightyBadge
