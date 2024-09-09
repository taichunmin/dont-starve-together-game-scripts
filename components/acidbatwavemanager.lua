--------------------------------------------------------------------------
--[[ acidbatwavemanager class definition ]]
--------------------------------------------------------------------------
local easing = require("easing")
local SourceModifierList = require("util/sourcemodifierlist")

return Class(function(self, inst)
local _world = TheWorld
local _map = _world.Map
assert(_world.ismastersim, "acidbatwavemanager should not exist on client")
self.inst = inst


-- Constants.
self.spawn_dist = TUNING.ACIDBATWAVE_SPAWN_DISTANCE
self.spawn_count = TUNING.ACIDBATWAVE_SPAWN_COUNT
self.max_target_prefab = TUNING.ACIDBATWAVE_NUMBER_OF_ITEMS_TO_GUARANTEE_WAVE_SPAWN
self.cooldown_between_waves = TUNING.ACIDBATWAVE_COOLDOWN_BETWEEN_WAVES
self.time_for_warning = TUNING.ACIDBATWAVE_TIME_FOR_WARNING

self.target_prefab = "nitre"
self.update_time_seconds = 10

-- Variables.
self.update_time_accumulator = 0
self.pausesources = SourceModifierList(inst, false, SourceModifierList.boolean)


-- Acidbat tracking.
self.acidbats = {}
self.OnRemove_Bat = function(bat, data)
    self.acidbats[bat] = nil
end
function self:TrackAcidBat(bat)
    self.acidbats[bat] = true
    bat:ListenForEvent("onremove", self.OnRemove_Bat)
end
self.NoHoles = function(pt)
    return not _world.Map:IsPointNearHole(pt)
end
function self:GetAcidBatSpawnPoint(pt)
    local offset = FindWalkableOffset(pt, math.random() * TWOPI, self.spawn_dist, 12, true, true, self.NoHoles)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end

    return nil
end
self.OnBatReturnToScene = function(bat, player)
    bat:ReturnToScene()
    bat:PushEvent("fly_back")
    if player:IsValid() then
        -- NOTES(JBK): The bats are spawned and the player is still there so the player should be a target for stealing nitre if they have it.
    end
end
function self:SpawnAcidBatForPlayerAt(player, pt)
    local bat = SpawnPrefab("bat")
    bat:RemoveFromScene()
    bat.Transform:SetPosition(pt.x, 0, pt.z)
    bat:DoTaskInTime(math.random()*2, self.OnBatReturnToScene, player)
    return bat
end
function self:CreateAcidBatsForPlayer(player, playermetadata)
    local items_percent = playermetadata.target_prefab_count / self.max_target_prefab
    local bats_count = math.floor(items_percent * (TUNING.ACIDBATWAVE_SPAWN_COUNT_MAX - TUNING.ACIDBATWAVE_SPAWN_COUNT_MIN) + TUNING.ACIDBATWAVE_SPAWN_COUNT_MIN)
    local origin = player:GetPosition()
    for i = 1, bats_count do
        local pt = self:GetAcidBatSpawnPoint(origin)
        -- Failed to spawn is not a huge issue.
        if pt ~= nil then
            local bat = self:SpawnAcidBatForPlayerAt(player, pt)
            if bat then
                self:TrackAcidBat(bat)
            end
        end
    end
end


-- Item tracking.
function self:CountTargetPrefabForPlayer(player)
    if player.components.inventory == nil then
        return 0
    end

    -- FIXME(JBK): Is there a more efficient way?
    local items = player.components.inventory:GetItemByName(self.target_prefab, self.max_target_prefab, true)
    local items_count = 0
    for item, _ in pairs(items) do
        if item.components.stackable then
            items_count = items_count + item.components.stackable:StackSize()
        else
            items_count = items_count + 1
        end
    end

    return math.min(items_count, self.max_target_prefab)
end
self.OnInventoryStateChanged = function(player, data)
    local playermetadata = self.watching[player]
    if playermetadata.spawn_wave_time == nil then -- Only update this when the player has not started a wave spawn.
        playermetadata.target_prefab_count = self:CountTargetPrefabForPlayer(player)
    end
end
function self:CreateMetaDataForPlayer(player)
    local metadata = {
        target_prefab_count = self:CountTargetPrefabForPlayer(player),
        odds_to_spawn_wave = 0,
    }

    local saved = self.savedplayermetadata[player.userid]
    if saved ~= nil then
        local t = GetTime()
        if saved.spawn_wave_time ~= nil then
            metadata.spawn_wave_time = saved.spawn_wave_time + t
            metadata.target_prefab_count = saved.target_prefab_count or metadata.target_prefab_count
        end
        if saved.next_wave_time ~= nil then
            metadata.next_wave_time = saved.next_wave_time + t
        end
        self.savedplayermetadata[player.userid] = nil
    end

    return metadata
end


-- Player tracking.
self.players = {} -- Cache of AllPlayers.
self.watching = {} -- Players who have event listeners and their stored metadata.
self.savedplayermetadata = {} -- Saved meta data for players who left while having wave data associated.
self.OnPlayerJoined = function(inst, player)
    if self.players[player] ~= nil then
        return
    end

    self.players[player] = true
    if _world.state.isacidraining then
        self:StartWatchingPlayer(player)
    end
end

self.OnPlayerLeft = function(inst, player)
    if self.players[player] == nil then
        return
    end

    self.players[player] = nil
    self:StopWatchingPlayer(player)
end

for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(inst, v)
end
inst:ListenForEvent("ms_playerjoined", self.OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", self.OnPlayerLeft)

function self:StartWatchingPlayer(player)
    if self.watching[player] ~= nil then
        return
    end

    if next(self.watching) == nil then
        self.inst:StartUpdatingComponent(self)
    end

    self.watching[player] = self:CreateMetaDataForPlayer(player)
    player:ListenForEvent("itemget", self.OnInventoryStateChanged)
    player:ListenForEvent("itemlose", self.OnInventoryStateChanged)
    player:ListenForEvent("newactiveitem", self.OnInventoryStateChanged)
    player:ListenForEvent("stacksizechange", self.OnInventoryStateChanged)


end
function self:StopWatchingPlayer(player)
    if self.watching[player] == nil then
        return
    end

    if _world.state.isacidraining then
        self.savedplayermetadata[player.userid] = self.watching[player]
    end
    self.watching[player] = nil
    player:RemoveEventCallback("itemget", self.OnInventoryStateChanged)
    player:RemoveEventCallback("itemlose", self.OnInventoryStateChanged)
    player:RemoveEventCallback("newactiveitem", self.OnInventoryStateChanged)
    player:RemoveEventCallback("stacksizechange", self.OnInventoryStateChanged)

    if next(self.watching) == nil then
        self.inst:StopUpdatingComponent(self)
    end
end
function self:StartWatchingPlayers()
    for player, _ in pairs(self.players) do
        self:StartWatchingPlayer(player)
    end
end
function self:StopWatchingPlayers()
    for player, _ in pairs(self.players) do
        self:StopWatchingPlayer(player)
    end

    -- NOTES(JBK): We do not want to have this data retained if the acid rain for the waves has stopped.
    -- Reuse the table instead of allocating a new one.
    for userid, _ in pairs(self.savedplayermetadata) do
        self.savedplayermetadata[userid] = nil
    end
end


-- Acid rain tracking.
function self:OnIsAcidRaining(isacidraining)
    if isacidraining then
        self:StartWatchingPlayers()
    else
        self:StopWatchingPlayers()
    end
end

self:WatchWorldState("isacidraining", self.OnIsAcidRaining)
function self:OnPostInit()
    self:OnIsAcidRaining(_world.state.isacidraining)
end


-- Periodic tasks.
function self:UpdateOddsForPlayer(player, playermetadata)
    if IsEntityDeadOrGhost(player) then
        playermetadata.odds_to_spawn_wave = 0
        return
    end

    local x, y, z = player.Transform:GetWorldPosition()
    if not _map:CanPointHaveAcidRain(x, y, z) then
        playermetadata.odds_to_spawn_wave = 0
        return
    end

    playermetadata.odds_to_spawn_wave = easing.inQuad(playermetadata.target_prefab_count, 0, 1, self.max_target_prefab)
end
function self:TryToSpawnWaveForPlayer(player, playermetadata, t)
    -- Paused.
    if playermetadata.spawn_wave_time == nil and self.pausesources:Get() then
        return
    end

    -- Warned, waiting to spawn.
    if playermetadata.spawn_wave_time ~= nil then
        if playermetadata.spawn_wave_time > t then
            return
        end

        playermetadata.spawn_wave_time = nil
        playermetadata.next_wave_time = t + self.cooldown_between_waves
        self:SpawnWaveForPlayer(player, playermetadata)
        self.OnInventoryStateChanged(player) -- Update prefab count only after the wave spawns.
        return
    end

    -- Spawned, waiting for cooldown.
    if playermetadata.next_wave_time ~= nil then
        if playermetadata.next_wave_time > t then
            return
        end

        playermetadata.next_wave_time = nil
    end

    -- Dice roll.
    if math.random() >= playermetadata.odds_to_spawn_wave then
        return
    end

    -- Warn player of incoming spawn.
    playermetadata.spawn_wave_time = t + self.time_for_warning
    self:IssueWarningForPlayer(player, playermetadata, t)
    player:DoTaskInTime(self.time_for_warning * 0.1 + math.random(), self.DoWarningSpeech)
end
function self:SpawnWaveForPlayer(player, playermetadata)
    playermetadata.last_warn_time = nil
    self:CreateAcidBatsForPlayer(player, playermetadata)
end
self.DoWarningSpeech = function(player)
    player.components.talker:Say(GetString(player, "ANNOUNCE_ACIDBATS"))
end
function self:IssueWarningForPlayer(player, playermetadata, t)
    if playermetadata.last_warn_time == nil or playermetadata.last_warn_time < t then
        local sfx = SpawnPrefab("acidbatwavewarning_lvl1")
        sfx.Transform:SetPosition(player.Transform:GetWorldPosition())
        local timeleft = playermetadata.spawn_wave_time - t
        playermetadata.last_warn_time = t + ((timeleft < self.time_for_warning * 0.25 and 0.8 + math.random() * 0.3) or (timeleft < self.time_for_warning * 0.5 and 3 + math.random()) or (timeleft < self.time_for_warning * 0.75 and 4 + math.random(2)) or (5 + math.random(4)))
    end
end
function self:OnUpdate(dt)
    -- Ignore the counter here for sfx checks.
    local t = GetTime()
    for player, _ in pairs(self.players) do
        local playermetadata = self.watching[player]
        if playermetadata ~= nil and playermetadata.spawn_wave_time then
            self:IssueWarningForPlayer(player, playermetadata, t)
        end
    end

    self.update_time_accumulator = self.update_time_accumulator + dt
    if self.update_time_accumulator < self.update_time_seconds then
        return
    end

    self.update_time_accumulator = math.random() * 0.1 -- NOTES(JBK): Add a small amount of jitter to reduce timer sync across multiple systems and defer process load.
    for player, _ in pairs(self.players) do
        local playermetadata = self.watching[player]
        if playermetadata ~= nil then
            self:UpdateOddsForPlayer(player, playermetadata)
            self:TryToSpawnWaveForPlayer(player, playermetadata, t)
        end
    end
end


-- Pause/Unpause.
-- NOTES(JBK): The hounded component already has hookups for special events where periodic spawning of things should stop let us reuse the event here.
-- Both systems are similar in what they produce out but I want both systems to be able to happen at the same time independent of each other.
self.OnPauseHounded = function(src, data)
    if data == nil or data.source == nil then
        return
    end

    self.pausesources:SetModifier(data.source, true, data.reason)
end
self.OnUnpauseHounded = function(src, data)
    if data == nil or data.source == nil then
        return
    end

    self.pausesources:RemoveModifier(data.source, data.reason)
end
inst:ListenForEvent("pausehounded", self.OnPauseHounded)
inst:ListenForEvent("unpausehounded", self.OnUnpauseHounded)


-- Save/Load.
function self:SetSaveDataForMetaData(savedata, playermetadata, t)
    local should_save = false

    if playermetadata.next_wave_time ~= nil then
        savedata.next_wave_time = playermetadata.next_wave_time - t
        should_save = true
    end

    if playermetadata.spawn_wave_time ~= nil then
        savedata.spawn_wave_time = playermetadata.spawn_wave_time - t
        savedata.target_prefab_count = playermetadata.target_prefab_count
        should_save = true
    end

    return should_save
end
function self:OnSave()
    local data, ents = {}, {}

    local t = GetTime()

    local userids = {}
    for player, playermetadata in pairs(self.watching) do
        local savedata = {}
        if self:SetSaveDataForMetaData(savedata, playermetadata, t) then
            userids[player.userid] = savedata
        end
    end
    for userid, playermetadata in pairs(self.savedplayermetadata) do
        local savedata = {}
        if self:SetSaveDataForMetaData(savedata, playermetadata, t) then
            userids[userid] = savedata
        end
    end
    if next(userids) then
        data.userids = userids
    end

    if next(self.acidbats) then
        data.bats = {}
        for bat, _ in pairs(self.acidbats) do
            table.insert(data.bats, bat.GUID)
            table.insert(ents, bat.GUID)
        end
    end

    if next(data) == nil then
        return nil, nil
    end

    return data, ents
end
function self:OnLoad(data)
    if data == nil then
        return
    end

    if data.userids then
        for userid, playermetadata in pairs(data.userids) do
            self.savedplayermetadata[userid] = playermetadata
        end
    end
end
function self:LoadPostPass(newents, savedata)
    if savedata.bats then
        for _, batguid in ipairs(savedata.bats) do
            if newents[batguid] then
                local bat = newents[batguid].entity
                self:TrackAcidBat(bat)
            end
        end
    end
end


end)
