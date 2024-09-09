local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-------------------------------------------------------------------------------------------------------

local PetHealthBadge = Class(Badge, function(self, owner, colour, iconbuild)
    Badge._ctor(self, nil, owner, colour, iconbuild, nil, nil, true)

	self.OVERRIDE_SYMBOL_BUILD = {} -- modders can add symbols-build pairs to this table by calling SetBuildForSymbol
	self.default_symbol_build = iconbuild

    self.arrow = self.underNumber:AddChild(UIAnim())
    self.arrow:GetAnimState():SetBank("sanity_arrow")
    self.arrow:GetAnimState():SetBuild("sanity_arrow")
    self.arrow:GetAnimState():PlayAnimation("neutral", true)
	self.arrow:GetAnimState():AnimateWhilePaused(false)
    self.arrow:SetClickable(false)

    self.bufficon = self.underNumber:AddChild(UIAnim())
    self.bufficon:GetAnimState():SetBank("status_abigail")
    self.bufficon:GetAnimState():SetBuild("status_abigail")
    self.bufficon:GetAnimState():PlayAnimation("buff_none")
	self.bufficon:GetAnimState():AnimateWhilePaused(false)
    self.bufficon:SetClickable(false)
	self.buffsymbol = 0

    self:StartUpdating()
end)

function PetHealthBadge:SetBuildForSymbol(build, symbol)
	self.OVERRIDE_SYMBOL_BUILD[symbol] = build
end

function PetHealthBadge:ShowBuff(symbol)
	if symbol == 0 then
		if self.buffsymbol ~= 0 then
			self.bufficon:GetAnimState():PlayAnimation("buff_deactivate")
			self.bufficon:GetAnimState():PushAnimation("buff_none", false)
		end
	elseif symbol ~= self.buffsymbol then
        self.bufficon:GetAnimState():OverrideSymbol("buff_icon", self.OVERRIDE_SYMBOL_BUILD[symbol] or self.default_symbol_build, symbol)

        self.bufficon:GetAnimState():PlayAnimation("buff_activate")
        self.bufficon:GetAnimState():PushAnimation("buff_idle", false)
    end

	self.buffsymbol = symbol
end

function PetHealthBadge:SetValues(symbol, percent, arrowdir, max_health, pulse)
	self:ShowBuff(symbol)

    if self.arrowdir ~= arrowdir then
        self.arrowdir = arrowdir
        self.arrow:GetAnimState():PlayAnimation((arrowdir >= 2  and "arrow_loop_increase_most") or
												(arrowdir == 1  and "arrow_loop_increase") or
												(arrowdir == -1 and "arrow_loop_decrease") or
												(arrowdir <= -2 and "arrow_loop_decrease_most") or
												"neutral",
												true)
    end

	percent = percent == 0 and 0 or math.max(percent, 1/max_health)
    local health = percent * max_health

	if pulse == 1 then
		self:PulseGreen()
	elseif pulse == 2 then
		self:PulseRed()
	end

    self:SetPercent(percent, max_health)
end

function PetHealthBadge:OnUpdate(dt)
end

return PetHealthBadge
