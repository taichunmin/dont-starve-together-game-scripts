local function OnNewCombatTarget(inst, data)
    inst.components.leader:OnNewTarget(data.target)
end

local function OnAttacked(inst, data)
    inst.components.leader:OnAttacked(data.attacker)
end

local function OnDeath(inst)
    inst.components.leader:RemoveAllFollowersOnDeath()
end

local Leader = Class(function(self, inst)
    self.inst = inst
    self.followers = {}
    self.numfollowers = 0

	--self.loyaltyeffectiveness = nil

    inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    self._onfollowerdied = function(follower) self:RemoveFollower(follower) end
    self._onfollowerremoved = function(follower) self:RemoveFollower(follower, true) end
end)

function Leader:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("newcombattarget", OnNewCombatTarget)
    self.inst:RemoveEventCallback("attacked", OnAttacked)
    self.inst:RemoveEventCallback("death", OnDeath)
    self:RemoveAllFollowers()
end

function Leader:IsFollower(guy)
    return self.followers[guy] ~= nil
end

function Leader:OnAttacked(attacker)
    if attacker ~= nil and not self:IsFollower(attacker) and self.inst ~= attacker and (attacker.components.minigame_participator == nil or (attacker:HasTag("player") and TheNet:GetPVPEnabled())) then
        for k,v in pairs(self.followers) do
            if k.components.combat ~= nil and k.components.follower ~= nil and k.components.follower.canaccepttarget then
                k.components.combat:SuggestTarget(attacker)
            end
        end
    end
end

function Leader:CountFollowers(tag)
    if tag == nil then
        return self.numfollowers
    end

    local count = 0
    for k,v in pairs(self.followers) do
        if k:HasTag(tag) then
            count = count + 1
		end
	end
	return count
end

function Leader:IsTargetedByFollowers(target)
    for follower, v in pairs(self.followers) do
        if follower.combat ~= nil and follower.combat:TargetIs(target) then
            return true
        end
    end
end

function Leader:OnNewTarget(target)
	if target == nil or (target.components.minigame_participator == nil or (target:HasTag("player") and TheNet:GetPVPEnabled())) then
		for k,v in pairs(self.followers) do
			if k.components.combat ~= nil and k.components.follower ~= nil and k.components.follower.canaccepttarget then
				k.components.combat:SuggestTarget(target)
			end
		end
	end
end

function Leader:RemoveFollower(follower, invalid)
    if follower ~= nil and self.followers[follower] then
        self.followers[follower] = nil
        self.numfollowers = self.numfollowers - 1

        self.inst:RemoveEventCallback("death", self._onfollowerdied, follower)
        self.inst:RemoveEventCallback("onremove", self._onfollowerremoved, follower)

        if self.onremovefollower ~= nil then
            self.onremovefollower(self.inst, follower)
        end

		if not invalid then
            follower:PushEvent("stopfollowing", { leader = self.inst })
	        follower.components.follower:SetLeader(nil)
		end
    end
end

function Leader:AddFollower(follower)
    if self.followers[follower] == nil and follower.components.follower ~= nil then
        self.followers[follower] = true
        self.numfollowers = self.numfollowers + 1
        follower.components.follower:SetLeader(self.inst)
        follower:PushEvent("startfollowing", { leader = self.inst })
		NotifyPlayerProgress("TotalFollowersAcquired", 1, self.inst);

        if not follower.components.follower.keepdeadleader then
            self.inst:ListenForEvent("death", self._onfollowerdied, follower)
        end

        self.inst:ListenForEvent("onremove", self._onfollowerremoved, follower)

	    if self.inst:HasTag("player") and follower.prefab ~= nil then
			if self:CountFollowers("pig") == TUNING.ACHIEVEMENT_PIG_POSSE_SIZE then
				AwardPlayerAchievement("pigman_posse", self.inst)
			elseif self:CountFollowers("rocky") == TUNING.ACHIEVEMENT_ROCKY_POSSE_SIZE then
				AwardPlayerAchievement("rocky_posse", self.inst)
			end
		    ProfileStatsAdd("befriend_"..follower.prefab)
	    end
	end
end

function Leader:RemoveFollowersByTag(tag, validateremovefn)
    for k,v in pairs(self.followers) do
        if k:HasTag(tag) and (validateremovefn == nil or validateremovefn(k)) then
            self:RemoveFollower(k)
        end
    end
end

function Leader:RemoveAllFollowers()
    for k,v in pairs(self.followers) do
        self:RemoveFollower(k)
    end
end

function Leader:RemoveAllFollowersOnDeath()
    for k, v in pairs(self.followers) do
        if not (k.components.follower ~= nil and k.components.follower.keepdeadleader) then
            self:RemoveFollower(k)
        end
    end
end

function Leader:HaveFollowersCachePlayerLeader()
    for k,v in pairs(self.followers) do
        if k.components.follower then
            k.components.follower:CachePlayerLeader()
        end
    end
end

function Leader:IsBeingFollowedBy(prefabName)
    for k,v in pairs(self.followers) do
        if k.prefab == prefabName then
            return true
        end
    end
    return false
end

function Leader:OnSave()
    if self.inst:HasTag("player") then
        return
    end

    local followers = {}
    for k, v in pairs(self.followers) do
        table.insert(followers, k.GUID)
    end

    if #followers > 0 then
        return { followers = followers }, followers
    end
end

function Leader:LoadPostPass(newents, savedata)
    if self.inst:HasTag("player") then
        return
    end

    if savedata ~= nil and savedata.followers ~= nil then
        for k,v in pairs(savedata.followers) do
            local targ = newents[v]
            if targ ~= nil and targ.entity.components.follower ~= nil then
                self:AddFollower(targ.entity)
            end
        end
    end
end

Leader.OnRemoveEntity = Leader.RemoveAllFollowers

function Leader:GetDebugString()
    return "followers:"..self.numfollowers
end

return Leader
