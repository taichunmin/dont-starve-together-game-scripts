local MermKingManager = Class(function(self, inst)
    self.inst = inst
    self.main_throne = nil
    self.thrones = {}

    self.king = nil
    self.king_dying = false

    self.candidates = {}
    self.candidate_transforming = nil

    self.inst:ListenForEvent("oncandidatekingarrived", function(inst, data)
    	if data then
    		if not self:IsCandidate(data.candidate) then
    			print ("ERROR: WRONG CANDIDATE")
    			return
    		end

    		local throne = self:GetThrone(data.candidate)
    		if not throne then
    			print ("ERROR: NO THRONE IN PLACE")
    			return
    		end

    		self:CreateMermKing(data.candidate, throne)
    	end
	end)

    self.inst:ListenForEvent("onthronebuilt", function(inst, data)
    	if data and data.throne then
			table.insert(self.thrones, data.throne)
			self:FindMermCandidate(data.throne)
    	end
	end)

    self.inst:ListenForEvent("onthronedestroyed", function(inst, data)
    	if data and data.throne then
    		self:OnThroneDestroyed(data.throne)
    	end
	end)
end)

local function OnKingDeath(inst, data)
	local manager = TheWorld.components.mermkingmanager
	manager.king.persists = false

	manager.king_dying = true
end

local function OnKingRemoval(inst, data)
	local manager = TheWorld.components.mermkingmanager

	manager.inst:RemoveEventCallback("onremove", OnKingRemoval, manager.king)
	manager.inst:RemoveEventCallback("death", OnKingDeath, manager.king)

	TheWorld:PushEvent("onmermkingdestroyed", {throne = manager.main_throne})

	table.insert(manager.thrones, manager.main_throne)

	manager.main_throne = nil
	manager.king = nil
	manager.king_dying = false

	for i,throne in pairs(manager.thrones) do
		if manager:IsThroneValid(throne) then
			manager:FindMermCandidate(throne)
		end
	end
end

local function OnCandidateRemoved(inst, data)
	local manager = TheWorld.components.mermkingmanager
	local throne = manager:GetThrone(inst)

	if manager.candidate_transforming == inst then
		manager.candidate_transforming = nil
	end

	manager.inst:RemoveEventCallback("death", OnCandidateRemoved, inst)
	manager.inst:RemoveEventCallback("onremove", OnCandidateRemoved, inst)

	manager.candidates[throne] = nil

	if manager:IsThroneValid(throne) then
		manager:FindMermCandidate(throne)
	end
end

function MermKingManager:OnThroneDestroyed(throne)

	local removal_index = nil
	for index, throne_instance in ipairs(self.thrones) do
		if throne == throne_instance then
			removal_index = index
			break
		end
	end

	if removal_index ~= nil then
		table.remove(self.thrones, removal_index)
	end

	local candidate = self.candidates[throne]

	if candidate ~= nil then
		if self:IsCandidateAtThrone(candidate, throne) then
			candidate:PushEvent("getup")
		end

		candidate.components.inspectable.nameoverride = nil
        candidate:RemoveTag("mermprince")
		self.inst:RemoveEventCallback("death", OnCandidateRemoved, candidate)
        self.inst:RemoveEventCallback("onremove", OnCandidateRemoved, candidate)
		self.candidates[throne] = nil
	end

	if throne == self:GetMainThrone() then
		self.main_throne = nil
		-- This wil only happen with the deconstruction staff
		if self.king ~= nil and self.king:IsValid() and self.king.components.health and not self.king.components.health:IsDead() then
			self.king.components.health:Kill()
		end
	end

end

function MermKingManager:CreateMermKing(candidate, throne)

	candidate.components.inventory:DropEverything()
    self.inst:RemoveEventCallback("onremove", OnCandidateRemoved, candidate)
	self.inst:RemoveEventCallback("death", OnCandidateRemoved, candidate)

	self.king = ReplacePrefab(candidate, "mermking")
	self.king:PushEvent("oncreated")

	self.inst:ListenForEvent("onremove", OnKingRemoval, self.king)
	self.inst:ListenForEvent("death", OnKingDeath, self.king)

	self.main_throne = throne
	for i,v in ipairs(self.thrones) do
		if v == throne then
			table.remove(self.thrones, i)
			break
		end
	end

	for k,v in pairs(self.candidates) do
		if v.components.mermcandidate then
			v.components.mermcandidate:ResetCalories()
            self.inst:RemoveEventCallback("onremove", OnCandidateRemoved, v)
			self.inst:RemoveEventCallback("death", OnCandidateRemoved, v)
		end
	end
	self.candidates = {}
	self.candidate_transforming = nil

    TheWorld:PushEvent("onmermkingcreated", {king = self.king, throne = self:GetMainThrone()})
end

local MERMCANDIDATE_MUST_TAGS = {"merm"}
local MERMCANDIDATE_CANT_TAGS = {"player", "mermking", "mermguard"}
function MermKingManager:FindMermCandidate(throne)
	-- Why are we finding a candidate if we already have a king?
	if self:HasKing() then
		print ("ERROR? Trying to find candidate when we already have a king")
		return
	end

	if throne then
		local merm_candidate = FindEntity(throne, 50,
			function(ent)
				return ent:IsValid() and ent.components.health and not ent.components.health:IsDead() and not self:IsCandidate(ent)
			end,
		MERMCANDIDATE_MUST_TAGS, MERMCANDIDATE_CANT_TAGS)

	    if merm_candidate then
	        self:ShouldGoToThrone(merm_candidate, throne)
	    end
	end
end

function MermKingManager:ShouldGoToThrone(merm, throne)
	if throne ~= nil and self:IsThroneValid(throne) then
		if self:GetKing() == nil and (self:GetCandidate(throne) == nil or self:IsThroneCandidate(merm, throne)) then
			if self:GetCandidate(throne) == nil then
				self.candidates[throne] = merm
				merm.components.inspectable.nameoverride = "MERM_PRINCE"
                merm:AddTag("mermprince")
                self.inst:ListenForEvent("onremove", OnCandidateRemoved, merm)
				self.inst:ListenForEvent("death", OnCandidateRemoved, merm)
			end
			return true
		end
	end

	return false
end

function MermKingManager:IsCandidateAtThrone(candidate, throne)
	return throne and candidate and throne:IsNear(candidate, 0.5)
end

function MermKingManager:ShouldTransform(merm)
	local throne = self:GetThrone(merm)

	local should_transform = merm and throne and self:IsCandidateAtThrone(merm, throne) and
		  merm.components.mermcandidate:ShouldTransform() and (self.candidate_transforming == nil or self.candidate_transforming == merm)

	if should_transform and self.candidate_transforming == nil then
		self.candidate_transforming = merm
	end

	return should_transform
end


function MermKingManager:IsThroneValid(throne)
    return throne ~= nil
        and throne:IsValid()
        and not (throne.components.burnable ~= nil and throne.components.burnable:IsBurning())
        and not throne:HasTag("burnt")
end

function MermKingManager:GetKing()
	return self.king
end

function MermKingManager:GetCandidate(throne)
	return self.candidates[throne]
end

function MermKingManager:IsThroneCandidate(merm, throne)
	return self.candidates[throne] == merm
end

function MermKingManager:IsCandidate(merm)
	for k,v in pairs(self.candidates) do
		if v == merm then
			return true
		end
	end

	return false
end

function MermKingManager:GetThrone(merm)
	for k,v in pairs(self.candidates) do
		if v == merm then
			return k
		end
	end

	return nil
end

function MermKingManager:GetMainThrone()
	return self.main_throne
end

function MermKingManager:IsThrone(throne)
	if self:GetMainThrone() and self:GetMainThrone() == throne then
		return true
	end

	for i,v in ipairs(self.thrones) do
		if v == throne then
			return true
		end
	end

	return false
end

function MermKingManager:HasKing()
	return self.king ~= nil and self.king:IsValid() and self.king.components.health and not self.king.components.health:IsDead()
end

function MermKingManager:OnSave()
	local data = {}
	local ents = {}

	if next(self.candidates) ~= nil then
		local candidates = {}
		for k,v in pairs(self.candidates) do
			candidates[k.GUID] = v.GUID
			table.insert(ents, k.GUID)
			table.insert(ents, v.GUID)
		end
	end

	if self.king and not self.king_dying then
		data.king = self.king.GUID
		table.insert(ents, self.king.GUID)
	end

	if self.candidate_transforming then
		data.candidate_transforming = self.candidate_transforming.GUID
		table.insert(ents, self.candidate_transforming.GUID)
	end

	local main_throne = self:GetMainThrone()
	if #self.thrones > 0 then
		data.thrones = {}

		for i,v in ipairs(self.thrones) do
			table.insert(data.thrones, v.GUID)
			table.insert(ents, v.GUID)
		end

		if self.king_dying then
			table.insert(data.thrones, main_throne.GUID)
			table.insert(ents, main_throne.GUID)
		end
	end

	if main_throne and not self.king_dying then
		data.throne = main_throne.GUID
		table.insert(ents, main_throne.GUID)
	end

	return data, ents
end

function MermKingManager:LoadPostPass(newents, savedata)
	if savedata.throne and newents[savedata.throne] ~= nil then
		self.main_throne = newents[savedata.throne].entity
	end

	if savedata.candidates then
		for k,v in pairs(savedata.candidates) do
			local throne = newents[k].entity
			local candidate = newents[v].entity

			self.candidates[throne] = candidate

			candidate.components.inspectable.nameoverride = "MERM_PRINCE"
            candidate:AddTag("mermprince")
            self.inst:ListenForEvent("onremove", OnCandidateRemoved, candidate)
			self.inst:ListenForEvent("death", OnCandidateRemoved, candidate)
		end
	end

	if savedata.king and newents[savedata.king] ~= nil then
		self.king = newents[savedata.king].entity
		self.inst:ListenForEvent("onremove", OnKingRemoval, self.king)
		self.inst:ListenForEvent("death", OnKingDeath, self.king)
		TheWorld:PushEvent("onmermkingcreated", {king = self.king, throne = self:GetMainThrone()})
	end

	if savedata.candidate_transforming then
		self.candidate_transforming = newents[savedata.candidate_transforming].entity
	end

	if savedata.thrones then
		for i,v in ipairs(savedata.thrones) do
			table.insert(self.thrones, newents[v].entity)
		end
	end

end

return MermKingManager