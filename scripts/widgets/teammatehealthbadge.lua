local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"

local TeammateHealthBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "lavaarena_partyhealth", owner, nil, nil, nil, nil, true)

    self:SetClickable(false)

    self.name_root = self:AddChild(Widget("nameroot"))
    self.name_root:MoveToBack()
    self.name_root:SetScale(1.1)

    self.arrow = self.underNumber:AddChild(UIAnim())
    self.arrow:GetAnimState():SetBank("sanity_arrow")
    self.arrow:GetAnimState():SetBuild("sanity_arrow")
    self.arrow:GetAnimState():PlayAnimation("neutral")
	self.arrow:GetAnimState():AnimateWhilePaused(false)
	self.arrow:SetScale(0.85)

    self.name_banner_center = self.name_root:AddChild(Image("images/lavaarena_hud.xml", "username_banner_filler.tex"))
    self.name_banner_center:SetHRegPoint(ANCHOR_LEFT)
    self.name_banner_center_width = self.name_banner_center:GetSize()
    self.name_banner_left = self.name_root:AddChild(Image("images/lavaarena_hud.xml", "username_banner_start.tex"))
    self.name_banner_left:SetHRegPoint(ANCHOR_LEFT)
    self.name_banner_left_width = self.name_banner_left:GetSize()
    self.name_banner_right = self.name_root:AddChild(Image("images/lavaarena_hud.xml", "username_banner_end.tex"))
    self.name_banner_right:SetHRegPoint(ANCHOR_LEFT)
    self.name_banner_right_width = self.name_banner_right:GetSize()

    self.playername = self.name_root:AddChild(Text(CHATFONT_OUTLINE, 30))

	self._onclienthealthdirty = function(src, data) self:SetPercent(data.percent) end
	self._onclienthealthstatusdirty = function() self:RefreshStatus() end
    self._onpethealthdirty = function() self:RefreshPetHealth() end
end)

function SetPlayerName(self, player)
	self.name_root:SetPosition(12, 0)

	local name = (player.name ~= nil and #player.name > 0) and player.name or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_USER_NAME

    self.playername:SetTruncatedString(name, 300, 35, "...")

	local name_left = self.name_banner_left_width - 45

	local text_w = math.max(self.name_banner_center_width, self.playername:GetRegionSize())
    self.playername:SetPosition(text_w/2 + name_left, 0)
    self.playername:SetColour(player.playercolour)

	local banner_right_offset = -10

	self.name_banner_center:SetPosition(name_left, 0)
	self.name_banner_center:SetScale((text_w + banner_right_offset) / self.name_banner_center_width, 1)

	self.name_banner_right:SetPosition(name_left + text_w + banner_right_offset - 3, 0)
end

function TeammateHealthBadge:SetPlayer(player)
	if self.player ~= nil and self.player ~= player then
		self.inst:RemoveEventCallback("clienthealthdirty", self._onclienthealthdirty, self.player)
		self.inst:RemoveEventCallback("clienthealthstatusdirty", self._onclienthealthstatusdirty, self.player)
		self:RemovePetHealth()
	end

	self.player = player
	self.userid = player.userid
    self.inst:ListenForEvent("clienthealthdirty", self._onclienthealthdirty, player)
	self.inst:ListenForEvent("clienthealthstatusdirty", self._onclienthealthstatusdirty, player)

	self.arrowdir = 0

    SetPlayerName(self, player)

    self.anim:GetAnimState():OverrideSymbol("character_wilson", "lavaarena_partyhealth", "character_"..player.prefab)

	if player.components.healthsyncer ~= nil then
		self.percent = player.components.healthsyncer:GetPercent()
	    self:SetPercent(self.percent)
	end

    if player.components.pethealthbar ~= nil then
		self:AddPet()
	    self.name_root:MoveToBack()
	end
end

function TeammateHealthBadge:SetPercent(val)
	val = val == 0 and 0 or math.max(val, 0.001)

    if self.percent < val then
		if self.arrowdir <= 0 then
		    self:PulseGreen()
		end
	elseif self.percent > val then
		if self.arrowdir >= 0 then
		    self:PulseRed()
		end
	end

    Badge.SetPercent(self, val)

	self:RefreshStatus()
end

function TeammateHealthBadge:RefreshStatus()
    local arrowdir = self.player.components.healthsyncer ~= nil and self.player.components.healthsyncer:GetOverTime() or 0

    if self.arrowdir ~= arrowdir then
        self.arrowdir = arrowdir

        self.arrow:GetAnimState():PlayAnimation((arrowdir > 1 and "arrow_loop_increase_most") or
													(arrowdir < 0 and "arrow_loop_decrease_most") or
													"neutral", true)
    end

	local warning = (arrowdir > 1 and {0,1,0,1}) or
					((arrowdir < 0 or (self.percent <= .33 and self.percent > 0)) and {1,0,0,1}) or
					nil

	if warning ~= nil then
		self:StartWarning(unpack(warning))
	else
		self:StopWarning()
	end

end

function TeammateHealthBadge:AddPet()
    self.pet_heart = self:AddChild(Badge("lavaarena_pethealth", self.owner))
    self.pet_heart:SetPosition(35, -35)
    self.pet_heart.anim:SetScale(.75)
	self.pet_heart.anim:GetAnimState():Hide("stick")
	self.pet_heart:Hide()
	self.pet_heart:MoveToBack()

    self.inst:ListenForEvent("clientpethealthdirty", self._onpethealthdirty, self.player)
    self.inst:ListenForEvent("clientpethealthsymboldirty", self._onpethealthdirty, self.player)
    if self.player.components.pethealthbar ~= nil then
        self:RefreshPetHealth()
    end
end

function TeammateHealthBadge:RemovePetHealth()
	if self.pet_heart ~= nil then
		self.inst:RemoveEventCallback("clientpethealthdirty", self._onpethealthdirty, self.player)
		self.inst:RemoveEventCallback("clientpethealthsymboldirty", self._onpethealthdirty, self.player)
		self.pet_heart:Kill()
		self.pet_heart = nil
	end
end

function TeammateHealthBadge:RefreshPetHealth()
	local pethealthbar = self.player ~= nil and self.player:IsValid() and self.player.components.pethealthbar or nil
	if pethealthbar == nil then
		return
	end

	local symbol = pethealthbar:GetSymbol()
	if symbol == 0 then
		self.pet_heart:Hide()
	else
		self.pet_heart:Show()
		self.pet_heart.anim:GetAnimState():OverrideSymbol("pet_abigail", "lavaarena_pethealth", symbol)
	end

	local percent = pethealthbar:GetPercent()
	if percent ~= nil then
		percent = percent == 0 and 0 or math.max(percent, 0.001)
		self.pet_heart:SetPercent(percent)
	end
end

function TeammateHealthBadge:IsShowingPet()
	return self.pet_heart ~= nil and self.pet_heart:IsVisible()
end

return TeammateHealthBadge
