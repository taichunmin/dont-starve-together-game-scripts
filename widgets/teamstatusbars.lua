local Widget = require "widgets/widget"
local TeammateHealthBadge = require "widgets/teammatehealthbadge"

local TeamStatusBars = Class(Widget, function(self, owner)
    Widget._ctor(self, "TeamStatusBars", owner)

	self:SetScale(.6)

	self.healthbars = {}

	self:OnUpdate(0)
	self:StartUpdating()
end)

function TeamStatusBars:SetPercent(val, max, penaltypercent)
    Badge.SetPercent(self, val, max)
end

function TeamStatusBars:OnUpdate(dt)
	local prev_num_bars = #self.healthbars

	local player_listing = {}
	for _, player in ipairs(AllPlayers) do
		if player.userid ~= ThePlayer.userid then
			table.insert(player_listing, player)
		end
	end

	while #self.healthbars > #player_listing do
		self.healthbars[#self.healthbars]:Kill()
		table.remove(self.healthbars, #self.healthbars)
	end

	while #self.healthbars < #player_listing do
		table.insert(self.healthbars, self:AddChild(TeammateHealthBadge(self.owner)))
	end

	local respositioning = false
	for i, bar in ipairs(self.healthbars) do
		if bar.userid ~= player_listing[i].userid then
			bar:SetPlayer(player_listing[i])
			respositioning = true
		end
		if bar._cached_isshowingpet ~= bar:IsShowingPet() then
			bar._cached_isshowingpet = bar:IsShowingPet()
			respositioning = true
		end
	end

	if respositioning == true then
		self:RespostionBars()
	end

	if prev_num_bars ~= #self.healthbars and #self.healthbars > 0 then
		if #self.healthbars - 1 > 0 then
			self.healthbars[#self.healthbars - 1].anim:GetAnimState():Show("stick")
		end
		self.healthbars[#self.healthbars].anim:GetAnimState():Hide("stick")
	end

end

function TeamStatusBars:ShowStatusNumbers()
	for i, bar in ipairs(self.healthbars) do
	    bar.num:Show()

	    if bar:IsShowingPet() then
			bar.pet_heart.num:Show()
		end
	end
end

function TeamStatusBars:HideStatusNumbers()
	for i, v in ipairs(self.healthbars) do
	    v.num:Hide()
	end
end

function TeamStatusBars:RespostionBars()
	local x, y = 60, -60
	local spacing = -75
	local pet_spacing = -16
	local num_pets = 0

	for i, bar in ipairs(self.healthbars) do
		bar:SetPosition(x, y + spacing*(i-1) + num_pets*pet_spacing)
		if bar:IsShowingPet() then
			num_pets = num_pets + 1
		end
	end
end

return TeamStatusBars
