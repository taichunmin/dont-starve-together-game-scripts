local ForestDayWalkerSpawner = Class(function(self, inst)
    assert(TheWorld.ismastersim, "ForestDayWalkerSpawner should not exist on the client")
    self.inst = inst

    self.days_to_spawn = TUNING.DAYWALKER_RESPAWN_DAYS_COUNT -- NOTES(JBK): By default the forest will be the second place daywalker arrives so have a delay here.
    self.power_level = 1
end)

function ForestDayWalkerSpawner:IncrementPowerLevel()
    self.power_level = math.min(self.power_level + 1, 2)
end

function ForestDayWalkerSpawner:GetPowerLevel()
    return self.power_level
end

function ForestDayWalkerSpawner:TryToSetDayWalkerJunkPile()
    local wagpunk_manager = TheWorld.components.wagpunk_manager
    if wagpunk_manager == nil then
        return false
    end

    if self.bigjunk == nil then
        local bigjunk = wagpunk_manager:GetBigJunk()
        if bigjunk == nil then
            return false
        end
        self.bigjunk = bigjunk
    end

    return true
end

function ForestDayWalkerSpawner:ShouldShakeJunk()
    return self.bigjunk ~= nil
end

function ForestDayWalkerSpawner:CanSpawnFromJunk()
    if self:ShouldShakeJunk() then
        -- NOTES(JBK): We are watching the junk pile for it to spawn one.
        return true
    end

    if self.daywalker ~= nil then
        return false
    end

    local shard_daywalkerspawner = TheWorld.shard.components.shard_daywalkerspawner
    if shard_daywalkerspawner == nil or shard_daywalkerspawner:GetLocationName() ~= "forestjunkpile" then
        return false
    end

    return self.days_to_spawn <= 0
end

function ForestDayWalkerSpawner:OnDayChange()
    if self.daywalker ~= nil or self.bigjunk ~= nil then
        return
    end

    local shard_daywalkerspawner = TheWorld.shard.components.shard_daywalkerspawner
    if shard_daywalkerspawner ~= nil and shard_daywalkerspawner:GetLocationName() ~= "forestjunkpile" then
        return
    end

    --print("OnDayChange", self.days_to_spawn)
    local days_to_spawn = self.days_to_spawn
    if days_to_spawn > 0 then
        self.days_to_spawn = days_to_spawn - 1
        return
    end

    if not self:TryToSetDayWalkerJunkPile() then
        return
    end

    self.bigjunk:StartDaywalkerBuried()
    self.days_to_spawn = TUNING.DAYWALKER_RESPAWN_DAYS_COUNT
end

function ForestDayWalkerSpawner:WatchDaywalker(daywalker)
    self.bigjunk = nil
    self.daywalker = daywalker
    self.inst:ListenForEvent("onremove", function()
		if self.daywalker.defeated then
			self:IncrementPowerLevel()
            Shard_SyncBossDefeated("daywalker")
		end
        self.daywalker = nil
    end, self.daywalker)
end

function ForestDayWalkerSpawner:HasDaywalker()
    return self.daywalker ~= nil
end

function ForestDayWalkerSpawner:OnPostInit()
    if TUNING.SPAWN_DAYWALKER then
        self:WatchWorldState("cycles", self.OnDayChange)
        if self.days_to_spawn <= 0 then
            -- NOTES(JBK): Try to do a spawn in this case it means the component has yet to try to spawn one or failed to spawn one in an attempt.
            self:OnDayChange()
        end
    end
end

function ForestDayWalkerSpawner:OnSave()
    local data = {
        days_to_spawn = self.days_to_spawn,
        power_level = self.power_level,
    }
    local refs = nil

    if self.daywalker ~= nil then
        local daywalker_GUID = self.daywalker.GUID
        data.daywalker_GUID = daywalker_GUID
        refs = {daywalker_GUID}
    end

    if self.bigjunk ~= nil then
        local bigjunk_GUID = self.bigjunk.GUID
        data.bigjunk_GUID = bigjunk_GUID
        refs = refs or {}
        table.insert(refs, bigjunk_GUID)
    end

    return data, refs
end

function ForestDayWalkerSpawner:OnLoad(data)
    if not data then
        return
    end

    if data.days_to_spawn then
        self.days_to_spawn = math.min(TUNING.DAYWALKER_RESPAWN_DAYS_COUNT, data.days_to_spawn)
    end
    self.power_level = data.power_level or self.power_level
end

function ForestDayWalkerSpawner:LoadPostPass(ents, data)
    local daywalker_GUID = data.daywalker_GUID
    if daywalker_GUID ~= nil then
        local daywalker = ents[daywalker_GUID]
        if daywalker ~= nil and daywalker.entity ~= nil then
            self:WatchDaywalker(daywalker.entity)
        end
    end
    local bigjunk_GUID = data.bigjunk_GUID
    if bigjunk_GUID ~= nil then
        local bigjunk = ents[bigjunk_GUID]
        if bigjunk ~= nil and bigjunk.entity ~= nil then
            self.bigjunk = bigjunk.entity
        end
    end
end

return ForestDayWalkerSpawner
