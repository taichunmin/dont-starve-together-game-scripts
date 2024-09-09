local rift_portal_defs = require("prefabs/rift_portal_defs")
local RIFTPORTAL_DEFS = rift_portal_defs.RIFTPORTAL_DEFS
local RIFTPORTAL_CONST = rift_portal_defs.RIFTPORTAL_CONST
rift_portal_defs = nil


local RIFTSPAWN_TIMERNAME = "rift_spawn_timer"

local RiftSpawner = Class(function(self, inst)
    assert(TheWorld.ismastersim, "RiftSpawner should not exist on the client")
    self.inst = inst

    -- Cache
    self._worldsettingstimer = TheWorld.components.worldsettingstimer
    self._map = TheWorld.Map


    -- SPAWN MODES
    --  1: never
    --  2: rare
    --  3: default
    --  4: often
    --  5: always
    self.spawnmode = 3

    self.lunar_rifts_enabled = false
    self.shadow_rifts_enabled = false
    --self.X_rifts_enabled = false

    self.rifts = {}
    self.rifts_count = 0

    self.inst:ListenForEvent("rifts_setdifficulty", function(...) self:SetDifficulty(...) end)
    self.inst:ListenForEvent("rifts_settingsenabled", function(...) self:SetEnabledSetting(...) end)
    self.inst:ListenForEvent("rifts_settingsenabled_cave", function(...) self:SetEnabledSettingCave(...) end)
    self.inst:ListenForEvent("lunarrift_opened", function(...) self:EnableLunarRifts(...) end)
    self.inst:ListenForEvent("shadowrift_opened", function(...) self:EnableShadowRifts(...) end)
    self.inst:ListenForEvent("ms_lunarrift_maxsize", function(...) self:OnLunarRiftMaxSize(...) end)
    self.inst:ListenForEvent("ms_shadowrift_maxsize", function(...) self:OnShadowRiftMaxSize(...) end)
    
    self._worldsettingstimer:AddTimer(
        RIFTSPAWN_TIMERNAME,
        TUNING.RIFTS_SPAWNDELAY + 1,
        TUNING.SPAWN_RIFTS ~= 0,
        function() self:OnRiftTimerDone() end
    )
end)

--------------------------------------------------------------------------------

local MINIMUM_DSQ_FROM_PREVIOUS_RIFT = 15 * TILE_SCALE
MINIMUM_DSQ_FROM_PREVIOUS_RIFT = MINIMUM_DSQ_FROM_PREVIOUS_RIFT * MINIMUM_DSQ_FROM_PREVIOUS_RIFT
function RiftSpawner:IsPointNearPreviousSpawn(x, z)
    for rift, rift_prefab in pairs(self.rifts) do
        local rx, _, rz = rift.Transform:GetWorldPosition()
        if distsq(x, z, rx, rz) < MINIMUM_DSQ_FROM_PREVIOUS_RIFT then
            return true
        end
    end
    return false
end


function RiftSpawner:OnRiftRemoved(rift)
    if self.rifts[rift] then
        self.rifts[rift] = nil
        self.rifts_count = self.rifts_count - 1
        TheWorld:PushEvent("ms_riftremovedfrompool", {rift = rift})

        -- If we can spawn rifts, and a timer isn't already counting down...
        if self.spawnmode ~= 1 and not self._worldsettingstimer:ActiveTimerExists(RIFTSPAWN_TIMERNAME) then
            -- AND our max rift count can support another rift, start the timer to spawn a new one!
            if self.rifts_count < TUNING.MAXIMUM_RIFTS_COUNT then
                self._worldsettingstimer:StartTimer(RIFTSPAWN_TIMERNAME, TUNING.RIFTS_SPAWNDELAY)
            end
        end
    end
end

function RiftSpawner:AddRiftToPool(rift, rift_prefab)
    if self.rifts[rift] == nil then
        self.rifts[rift] = rift_prefab
        self.rifts_count = self.rifts_count + 1
        self.inst:ListenForEvent("onremove", function() self:OnRiftRemoved(rift) end, rift)
        TheWorld:PushEvent("ms_riftaddedtopool", {rift = rift})
    end
end


function RiftSpawner:SpawnRift(forced_pos)
    local rift_prefab = self:GetNextRiftPrefab()
    local rift_def = RIFTPORTAL_DEFS[rift_prefab]
    if rift_def == nil then
        return nil
    end

    local x, z
    if forced_pos then
        x, z = forced_pos.x, forced_pos.z
    else
        x, z = rift_def.GetNextRiftSpawnLocation(self._map, rift_def)
    end
    if not x then
        return nil
    end

    if self:IsPointNearPreviousSpawn(x, z) then
        return nil
    end

    local rift = SpawnPrefab(rift_prefab)
    rift.Transform:SetPosition(x, 0, z)

    self:AddRiftToPool(rift, rift_prefab)

    return rift
end

function RiftSpawner:TryToSpawnRift(forced_pos)
    local rift
    if self.rifts_count < TUNING.MAXIMUM_RIFTS_COUNT then
        rift = self:SpawnRift(forced_pos)
    end
    return rift
end



function RiftSpawner:OnRiftTimerDone()
    if self.spawnmode == 1 then
        return
    end

    if self.rifts_count < TUNING.MAXIMUM_RIFTS_COUNT then
        local spawned_rift = self:SpawnRift()

        -- If we failed to spawn a rift, but know we can support more,
        -- try again in a relatively short time period.
        if not spawned_rift then
            self._worldsettingstimer:StartTimer(RIFTSPAWN_TIMERNAME, TUNING.TOTAL_DAY_TIME)
        elseif (self.rifts_count + 1) < TUNING.MAXIMUM_RIFTS_COUNT then
            self._worldsettingstimer:StartTimer(RIFTSPAWN_TIMERNAME, TUNING.RIFTS_SPAWNDELAY)
        end
    end
end

function RiftSpawner:SetDifficulty(src, difficulty)
	if difficulty == "never" then
		self.spawnmode = 1
        self._worldsettingstimer:StopTimer(RIFTSPAWN_TIMERNAME)
	else
        if difficulty == "rare" then
		    self.spawnmode = 2
        elseif difficulty == "default" then
            self.spawnmode = 3
        elseif difficulty == "often" then
            self.spawnmode = 4
        elseif difficulty == "always" then
            self.spawnmode = 5
        end

        if self._worldsettingstimer:ActiveTimerExists(RIFTSPAWN_TIMERNAME) then
            local time_left = self._worldsettingstimer:GetTimeLeft(RIFTSPAWN_TIMERNAME)
            local new_time = math.min(time_left, TUNING.RIFTS_SPAWNDELAY)
            self._worldsettingstimer:SetTimeLeft(RIFTSPAWN_TIMERNAME, new_time)
        end
	end
end

function RiftSpawner:TryToStartTimer(src)
    if self.spawnmode ~= 1 and not self._worldsettingstimer:ActiveTimerExists(RIFTSPAWN_TIMERNAME) then
        self._worldsettingstimer:StartTimer(RIFTSPAWN_TIMERNAME, TUNING.RIFTS_SPAWNDELAY)
        self._map:StartFindingGoodArenaPoints()
    end
end

function RiftSpawner:EnableLunarRifts(src)
    self.lunar_rifts_enabled = true
    self:TryToStartTimer(src)

    if self.inst.components.wagpunk_manager ~= nil then
        self.inst.components.wagpunk_manager:Enable()
    end
end

function RiftSpawner:EnableShadowRifts(src)
    self.shadow_rifts_enabled = true
    self:TryToStartTimer(src)
end
--function RiftSpawner:EnableXRifts(src)
--    self.X_rifts_enabled = true
--    self:TryToStartTimer(src)
--end

function RiftSpawner:OnLunarRiftMaxSize(src, rift)
    local fx, _, fz = rift.Transform:GetWorldPosition()
    for _, player in ipairs(AllPlayers) do
        local px, _, pz = player.Transform:GetWorldPosition()
        local sq_dist = distsq(fx, fz, px, pz)

        if sq_dist > 900 then --30*30
            player._lunarportalmax:push()
        end
    end
end

function RiftSpawner:OnShadowRiftMaxSize(src, rift)
    local fx, _, fz = rift.Transform:GetWorldPosition()
    for _, player in ipairs(AllPlayers) do
        local px, _, pz = player.Transform:GetWorldPosition()
        local sq_dist = distsq(fx, fz, px, pz)

        if sq_dist > 900 then --30*30
            player._shadowportalmax:push()
        end
    end
end

function RiftSpawner:SetEnabledSetting(src, enabled_difficulty)
    if enabled_difficulty == "never" then
        self.lunar_rifts_enabled = false
        self._worldsettingstimer:StopTimer(RIFTSPAWN_TIMERNAME)

        if self.inst.components.wagpunk_manager ~= nil then
            self.inst.components.wagpunk_manager:Disable()
        end

    elseif enabled_difficulty == "always" then
        self:EnableLunarRifts(src)
    end
end

function RiftSpawner:SetEnabledSettingCave(src, enabled_difficulty)
    if enabled_difficulty == "never" then
        self.shadow_rifts_enabled = false
        self._worldsettingstimer:StopTimer(RIFTSPAWN_TIMERNAME)
    elseif enabled_difficulty == "always" then
        self:EnableShadowRifts(src)
    end
end

--------------------------------------------------------------------------------
-- Getters
--------------------------------------------------------------------------------


function RiftSpawner:GetRifts()
    return self.rifts
end

function RiftSpawner:GetRiftsOfPrefab(prefab)
    local return_rifts = nil
    for rift, rift_prefab in pairs(self.rifts) do
        if rift_prefab == prefab then
            if return_rifts then
                table.insert(return_rifts, rift)
            else
                return_rifts = { rift }
            end
        end
    end
    return return_rifts
end
RiftSpawner.GetRiftsOfType = RiftSpawner.GetRiftsOfPrefab -- Deprecated function stub kept for mods.

function RiftSpawner:GetRiftsOfAffinity(affinity)
    local return_rifts = nil
    for rift, rift_prefab in pairs(self.rifts) do
        if RIFTPORTAL_DEFS[rift_prefab].Affinity == affinity then
            if return_rifts then
                table.insert(return_rifts, rift)
            else
                return_rifts = { rift }
            end
        end
    end
    return return_rifts
end


function RiftSpawner:GetEnabled() -- Any type update accordingly.
    return self.lunar_rifts_enabled or self.shadow_rifts_enabled -- or self.X_rifts_enabled
end

function RiftSpawner:GetLunarRiftsEnabled()
    return self.lunar_rifts_enabled
end

function RiftSpawner:GetShadowRiftsEnabled()
    return self.shadow_rifts_enabled
end

--function RiftSpawner:GetXRiftsEnabled()
--    return self.X_rifts_enabled
--end

function RiftSpawner:IsLunarPortalActive()
    for rift, rift_prefab in pairs(self.rifts) do
        if RIFTPORTAL_DEFS[rift_prefab].Affinity == RIFTPORTAL_CONST.AFFINITY.LUNAR then
            return true
        end
    end
    return false
end

function RiftSpawner:IsShadowPortalActive()
    for rift, rift_prefab in pairs(self.rifts) do
        if RIFTPORTAL_DEFS[rift_prefab].Affinity == RIFTPORTAL_CONST.AFFINITY.SHADOW then
            return true
        end
    end
    return false
end

--function RiftSpawner:IsXPortalActive()
--    for rift, rift_prefab in pairs(self.rifts) do
--        if RIFTPORTAL_DEFS[rift_prefab].Affinity == RIFTPORTAL_CONST.AFFINITY.X then
--            return true
--        end
--    end
--    return false
--end

function RiftSpawner:GetNextRiftPrefab()
    local potentials = {}
    local isLunarEnabled = self:GetLunarRiftsEnabled()
    local isShadowEnabled = self:GetShadowRiftsEnabled()
    --local isXEnabled = self:GetXRiftsEnabled()
    for rift_prefab, rift_def in pairs(RIFTPORTAL_DEFS) do
        if isLunarEnabled and rift_def.Affinity == RIFTPORTAL_CONST.AFFINITY.LUNAR then
            table.insert(potentials, rift_prefab)
        end
        if isShadowEnabled and rift_def.Affinity == RIFTPORTAL_CONST.AFFINITY.SHADOW then
            table.insert(potentials, rift_prefab)
        end
        --if isXEnabled and rift_def.Affinity == RIFTPORTAL_CONST.AFFINITY.X then
        --    table.insert(potentials, rift_prefab)
        --end
    end

    if potentials[1] == nil then
        return nil
    end

    return potentials[math.random(#potentials)]
end


--------------------------------------------------------------------------------
-- Save / Load
--------------------------------------------------------------------------------


function RiftSpawner:OnSave()
    local data = {
        timerfinished = (not self._worldsettingstimer:ActiveTimerExists(RIFTSPAWN_TIMERNAME)) or nil,
        rift_guids = {},
        _lunar_enabled = self.lunar_rifts_enabled,
        _shadow_enabled = self.shadow_rifts_enabled,
        --_X_enabled = self.X_rifts_enabled,
    }
    local ents = {}
    for rift, rift_prefab in pairs(self.rifts) do
        if rift_prefab then
            table.insert(data.rift_guids, rift.GUID)
            table.insert(ents, rift.GUID)
        end
    end

    return data, ents
end

function RiftSpawner:OnLoad(data)
    if data.timerfinished then
        self._worldsettingstimer:StopTimer(RIFTSPAWN_TIMERNAME)
    end

    self.lunar_rifts_enabled = data._lunar_enabled or self.lunar_rifts_enabled
    self.shadow_rifts_enabled = data._shadow_enabled or self.shadow_rifts_enabled
    --self.X_rifts_enabled = data._X_enabled or self.X_rifts_enabled
end

function RiftSpawner:LoadPostPass(newents, data)
    if data then
        if data.rift_guids then
            for _, rift_guid in ipairs(data.rift_guids) do
                local new_ent = newents[rift_guid]
                if new_ent and new_ent.entity then
                    self:AddRiftToPool(new_ent.entity, new_ent.entity.prefab)
                end
            end
        end
    end

    if self.lunar_rifts_enabled then
        self:EnableLunarRifts()
    end
    if self.shadow_rifts_enabled then
        self:EnableShadowRifts()
    end
    --if self.X_rifts_enabled then
    --    self:EnableXRifts()
    --end

    if self._worldsettingstimer:ActiveTimerExists(RIFTSPAWN_TIMERNAME) then
        self._map:StartFindingGoodArenaPoints()
    end
end


--------------------------------------------------------------------------------
-- Debug
--------------------------------------------------------------------------------


function RiftSpawner:GetDebugString()
    return string.format("Lunar Rifts: %s || Shadow Rifts: %s || Rifts Count: %d || Rift Spawn Time: %s",
        self.lunar_rifts_enabled and "ON" or "OFF",
        self.shadow_rifts_enabled and "ON" or "OFF",
        self.rifts_count,
        self._worldsettingstimer:GetTimeLeft(RIFTSPAWN_TIMERNAME) or "-"
    )
end

function RiftSpawner:GetDebugRiftString()
    local out = {}
    for rift, rift_prefab in pairs(self.rifts) do
        table.insert(out, string.format("Rift %s : %s",
            rift_prefab, RIFTPORTAL_DEFS[rift_prefab].Affinity
        ))
    end

    if out[1] == nil then
        return "NO RIFTS"
    end

    return table.concat(out, "\n")
end

function RiftSpawner:DebugHighlightRifts()
    for rift, rift_prefab in pairs(self.rifts) do
        local x, y, z = rift.Transform:GetWorldPosition()
        local eye
        if RIFTPORTAL_DEFS[rift_prefab].Affinity == RIFTPORTAL_CONST.AFFINITY.LUNAR then
            eye = SpawnPrefab("bluemooneye")
        elseif RIFTPORTAL_DEFS[rift_prefab].Affinity == RIFTPORTAL_CONST.AFFINITY.SHADOW then
            eye = SpawnPrefab("redmooneye")
        else
            eye = SpawnPrefab("greenmooneye") -- No affinity maybe mods?
        end
        eye.Transform:SetPosition(x, y, z)
    end
end

return RiftSpawner
