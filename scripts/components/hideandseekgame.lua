

local HideAndSeekGame = Class(function(self, inst)
    self.inst = inst

	self.seekers = {}

	self.hiding_spots = {}
	self.hiding_range = 10
	self.hiding_range_toofar = 10
	self.num_hiders_found = 0		-- how many the players found, use this to calculate rewards, not track game progress

	--self.seeker_too_far_return_announce = nil
	--self.seeker_return_announce = nil
	--self.gameaborted_announce = nil

	--self.OnAddSeeker = nil
	--self.OnHidingSpotFound == nil
	--self.OnHideAndSeekOver == nil

	self.onremove_hiding_spot = function(hiding_spot) 
		if self.hiding_spots[hiding_spot] ~= nil then
			self.hiding_spots[hiding_spot] = nil 

			if next(self.hiding_spots) == nil then
				self:_HideAndSeekOver()
			end
		end
	end

	self.onremove_seeker = function(seeker) 
		self.seekers[seeker] = nil 
	end
	
	self.dounregisterhidingspot = function(hiding_spot, data) -- Note: was found by a player if if data.finder ~= nil
		if data ~= nil and data.finder ~= nil and data.finder.isplayer then
			self.num_hiders_found = self.num_hiders_found + 1

			self:UnregisterHidingSpot(hiding_spot)

			if self.OnHidingSpotFound ~= nil then
				self.OnHidingSpotFound(self.inst, data.finder, hiding_spot)
			end
		else
			self:UnregisterHidingSpot(hiding_spot)
		end
	end
end)

function HideAndSeekGame:OnRemoveEntity()
	for hiding_spot, _ in pairs(self.hiding_spots) do
		hiding_spot.components.hideandseekhidingspot:Abort()
	end
end

function HideAndSeekGame:IsActive()
	return next(self.hiding_spots) ~= nil
end

function HideAndSeekGame:Abort()
	for hiding_spot, _ in pairs(self.hiding_spots) do
		self:UnregisterHidingSpot(hiding_spot)
		hiding_spot.components.hideandseekhidingspot:Abort()
	end
end

function HideAndSeekGame:_HideAndSeekOver()
	if self.pulse_task ~= nil then
		self.pulse_task:Cancel()
		self.pulse_task = nil
	end
	if self.OnHideAndSeekOver ~= nil then
		self.OnHideAndSeekOver(self.inst)
	end
	for seeker, _ in pairs(self.seekers) do
		self.inst:RemoveEventCallback("onremove", self.onremove_seeker, seeker)
	end
	self.seekers = {}

	self.num_hiders_found = 0
end

function HideAndSeekGame:AddSeeker(seeker, started_game)
	if seeker.components.hideandseeker == nil then
		seeker:AddComponent("hideandseeker")
		seeker.components.hideandseeker:SetGame(self.inst)

		self.seekers[seeker] = true
		self.inst:ListenForEvent("onremove", self.onremove_seeker, seeker)

		if self.OnAddSeeker ~= nil then
			self.OnAddSeeker(self.inst, seeker, started_game)
		end
	end
end

HideAndSeekGame.pulse = function(inst)
	local self = inst.components.hideandseekgame
	if self.OnHideAndSeekPulse ~= nil then
		self.OnHideAndSeekPulse(inst)

	end

	local x, y, z = inst.Transform:GetWorldPosition()
	for i, player in ipairs(AllPlayers) do
		if player.components.hideandseeker == nil and not IsEntityDeadOrGhost(player) and player.entity:IsVisible() and player:GetDistanceSqToPoint(x, y, z) < self.hiding_range*self.hiding_range then
			self:AddSeeker(player, false)
		end
	end
end

function HideAndSeekGame:RegisterHidingSpot(hiding_spot)
	self.num_hiders_found = 0

	if self.hiding_spots[hiding_spot] == nil then
		self.hiding_spots[hiding_spot] = true
		self.inst:ListenForEvent("onremove", self.onremove_hiding_spot, hiding_spot)
		self.inst:ListenForEvent("onhidingspotremoved", self.dounregisterhidingspot, hiding_spot)
	end

	if self.pulse_task == nil then
		self.pulse_task = self.inst:DoPeriodicTask(1, self.pulse)
	end
end

function HideAndSeekGame:UnregisterHidingSpot(hiding_spot)
	if self.hiding_spots[hiding_spot] ~= nil then
		self.hiding_spots[hiding_spot] = nil 
		self.inst:RemoveEventCallback("onremove", self.onremove_hiding_spot, hiding_spot) 
		self.inst:RemoveEventCallback("onhidingspotremoved", self.dounregisterhidingspot, hiding_spot)

		if next(self.hiding_spots) == nil then
			self:_HideAndSeekOver()
		end
	end
end

function HideAndSeekGame:GetNumHiding()
	return GetTableSize(self.hiding_spots)
end

function HideAndSeekGame:GetNumSeekers()
	return GetTableSize(self.seekers)
end

function HideAndSeekGame:GetNumFound()
	return self.num_hiders_found
end

function HideAndSeekGame:OnSave()
    if next(self.hiding_spots) == nil then
        return
    end

    local refs = {}
    for v, _ in pairs(self.hiding_spots) do
        table.insert(refs, v.GUID)
    end

    return { hiding_spots = refs, num_hiders_found = self.num_hiders_found }, refs
end

function HideAndSeekGame:LoadPostPass(newents, data)
    if data.hiding_spots ~= nil then
		self.num_hiders_found = data.num_hiders_found or 0

        for i, v in ipairs(data.hiding_spots) do
            local ent = newents[v]
            if ent ~= nil then
                self:RegisterHidingSpot(ent.entity)
            end
        end
    end
end

function HideAndSeekGame:GetDebugString()
    return "Hiders: " .. tostring(GetTableSize(self.hiding_spots)) .. ", Found: " .. tostring(self.num_hiders_found)
end

return HideAndSeekGame
