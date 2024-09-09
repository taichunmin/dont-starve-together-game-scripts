--------------------------------------------------------------------------
--[[ shadowthrallmanager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)
local _world = TheWorld
local _map = _world.Map

assert(_world.ismastersim, "ShadowThrallManager should not exist on client")


local CHECK_FISSURE_INTERVAL = 1.13
local MIASMA_RADIUS = 4.0
local MIASMAS = 8
local CLOSEST_FISSURE_MAXDIST_SQ = 40 * 40
local SPAWN_THRALL_DIST = 14
local LOADING_GRACE_TIME = 5


self.inst = inst


local _fissure = nil
local _fissure_animating = nil
local _potential_fissures = {}

local _miasmas = nil

local _thrall_hands = nil
local _thrall_horns = nil
local _thrall_wings = nil
local _thrall_count = 0

local _thrall_combatcheck_task = nil
local _find_fissure_task = nil

local _internal_cooldown = 0 -- Future timestamp for when things can spawn again.
local _dreadstone_regen_task = nil
local _spawn_thralls_task = nil
local _loading = nil

local BADFISSURE_ONEOF_TAGS = {"structure", "blocker", "antlion_sinkhole_blocker"}
local BADFISSURE_RADIUS = 4
function self:IsGoodFissureLocation(pt)
    if not _map:IsAboveGroundInSquare(pt.x, pt.y, pt.z, TILE_SCALE) then
        return false
    end

    if TheSim:FindEntities(pt.x, pt.y, pt.z, BADFISSURE_RADIUS, nil, nil, BADFISSURE_ONEOF_TAGS)[1] then
        return false
    end

    return true
end
local function IsGoodFissureLocation_Bridge(pt)
    return self:IsGoodFissureLocation(pt)
end
local GOODFISSURE_DISTANCE = 30
function self:FindGoodFissureLocation()
    local potentials = nil
    for _, player in ipairs(AllPlayers) do
        local areaaware = player.components.areaaware
        if areaaware and areaaware:CurrentlyInTag("Nightmare") then
            local x, y, z = player.Transform:GetWorldPosition()
            if not potentials then
                potentials = {Vector3(x, y, z)}
            else
                table.insert(potentials, Vector3(x, y, z))
            end
        end
    end

    if potentials then
        while #potentials > 0 do
            local r = math.random(#potentials)
            local pt = table.remove(potentials, r)
            local offset = FindWalkableOffset(pt, math.random() * PI2, GOODFISSURE_DISTANCE, 16, nil, nil, IsGoodFissureLocation_Bridge)
            if offset then
                return pt.x + offset.x, pt.y + offset.y, pt.z + offset.z
            end
        end
    end

    return nil, nil, nil
end

function self:TickFindingGoodFissures()
    if GetTime() < _internal_cooldown then
        --print("TickFindingGoodFissures cooldown:", _internal_cooldown - GetTime())
        return
    end

    if _fissure == nil then -- Just in case.
        local closestdist = 99999
        local closestfissure = nil
        if _world.topology.overrides == nil or _world.topology.overrides.fissure ~= "never" then
            -- Assume some fissures are generated in the world use them instead.
            for _, player in ipairs(AllPlayers) do
                for somefissure, _ in pairs(_potential_fissures) do
                    local dsq = player:GetDistanceSqToInst(somefissure)
                    if dsq < closestdist and dsq < CLOSEST_FISSURE_MAXDIST_SQ then
                        closestdist = dsq
                        closestfissure = somefissure
                    end
                end
            end
        else
            -- Assume no fissures are in the world so try to find a good spot to place one.
            local x, y, z = self:FindGoodFissureLocation()
            if x then
                closestfissure = SpawnPrefab("fissure")
                closestfissure.Transform:SetPosition(x, y, z)
                closestfissure:MakeTempFissure()
            end
        end
        if closestfissure then
            self:ControlFissure(closestfissure)
        end
    end

    if _fissure ~= nil then
        self:StopFindingGoodFissures()
    end
end

local function TickFindingGoodFissures_Bridge()
    self:TickFindingGoodFissures()
end

function self:StopFindingGoodFissures()
    if _find_fissure_task ~= nil then
        _find_fissure_task:Cancel()
        _find_fissure_task = nil
    end
end

function self:StartFindingGoodFissures()
    self:StopFindingGoodFissures()

    _find_fissure_task = self.inst:DoPeriodicTask(CHECK_FISSURE_INTERVAL, TickFindingGoodFissures_Bridge)
end

local function StartOrStopFindingGoodFissures()
    local riftspawner = _world.components.riftspawner
    if riftspawner and riftspawner:IsShadowPortalActive() then
        if _fissure == nil then
            self:StartFindingGoodFissures()
        else
            self:StopFindingGoodFissures()
        end
    else
        self:StopFindingGoodFissures()
        if _spawn_thralls_task ~= nil then
            _spawn_thralls_task:Cancel()
            _spawn_thralls_task = nil
        end
    end
end

function self:RegisterFissure(inst)
    _potential_fissures[inst] = true

    if inst == _fissure then
        if _thrall_combatcheck_task ~= nil then
            _thrall_combatcheck_task:Cancel()
            _thrall_combatcheck_task = nil
        end
    end
end

function self:OnSpawnThralls()
    if _fissure then
        local player = FindClosestPlayerToInst(_fissure, SPAWN_THRALL_DIST, true)
        if player then
			local x, y, z = _fissure.Transform:GetWorldPosition()
			local angle = player:GetAngleToPoint(x, y, z) + 180
			local angles = { angle - 50 - math.random() * 10, angle - 5 + math.random() * 10, angle + 50 + math.random() * 10 }
			local delays = { 0, .6, 1.2 }
			_thrall_hands = self:SpawnThrallFromPoint("shadowthrall_hands", x, z, table.remove(angles, math.random(#angles)), table.remove(delays, math.random(#delays)))
			_thrall_horns = self:SpawnThrallFromPoint("shadowthrall_horns", x, z, table.remove(angles, math.random(#angles)), table.remove(delays, math.random(#delays)))
			_thrall_wings = self:SpawnThrallFromPoint("shadowthrall_wings", x, z, table.remove(angles, math.random(#angles)), table.remove(delays, math.random(#delays)))
			if _thrall_hands.components.entitytracker ~= nil then
				_thrall_hands.components.entitytracker:TrackEntity("horns", _thrall_horns)
				_thrall_hands.components.entitytracker:TrackEntity("wings", _thrall_wings)
			end
			if _thrall_horns.components.entitytracker ~= nil then
				_thrall_horns.components.entitytracker:TrackEntity("hands", _thrall_hands)
				_thrall_horns.components.entitytracker:TrackEntity("wings", _thrall_wings)
			end
			if _thrall_wings.components.entitytracker ~= nil then
				_thrall_wings.components.entitytracker:TrackEntity("hands", _thrall_hands)
				_thrall_wings.components.entitytracker:TrackEntity("horns", _thrall_horns)
			end
			--Search strings:
			-- SpawnPrefab("shadowthrall_hands")
			-- SpawnPrefab("shadowthrall_horns")
			-- SpawnPrefab("shadowthrall_wings")
			self:StartEventListeners()
            if _spawn_thralls_task ~= nil then
                _spawn_thralls_task:Cancel()
                _spawn_thralls_task = nil
            end
        end
    end
end

local function OnSpawnThralls_Bridge()
    self:OnSpawnThralls()
end

function self:IsThrallInCombat(thrall)
    local combat = thrall.components.combat
    if combat == nil then
        return false
    end

    if combat:HasTarget() then
        return true
    end

    local t = GetTime()
    return t < combat:GetLastAttackedTime() + TUNING.FISSURE_TIME_THRALLS_OUT_OF_COMBAT
end

function self:SafeToReleaseFissure()
    if _loading then -- Give players some time to load in.
        return false
    end

    if _thrall_hands ~= nil then
        if self:IsThrallInCombat(_thrall_hands) then
            return false
        end
    end
    if _thrall_horns ~= nil then
        if self:IsThrallInCombat(_thrall_horns) then
            return false
        end
    end
    if _thrall_wings ~= nil then
        if self:IsThrallInCombat(_thrall_wings) then
            return false
        end
    end

    return true
end

local function CheckIfSafeToReleaseFissure()
    if self:SafeToReleaseFissure() then
        self:ReleaseFissure(TUNING.FISSURE_COOLDOWN_WALKED_AWAY) -- This was during combat.
        if _thrall_combatcheck_task ~= nil then
            _thrall_combatcheck_task:Cancel()
            _thrall_combatcheck_task = nil
        end
    end
end

function self:UnregisterFissure(inst)
    if _fissure == inst then
        -- All players ran away from the target fissure, try releasing it if possible.
        if self:SafeToReleaseFissure() then
            if _spawn_thralls_task == nil and (_thrall_hands == nil or _thrall_horns == nil or _thrall_wings == nil) then
                -- One of the trio is dead combat must have happened.
                self:ReleaseFissure(TUNING.FISSURE_COOLDOWN_DEFEATED_ANY_THRALLS)
            else
                self:ReleaseFissure(TUNING.FISSURE_COOLDOWN_WALKED_AWAY)
            end
        else
            _thrall_combatcheck_task = self.inst:DoPeriodicTask(CHECK_FISSURE_INTERVAL, CheckIfSafeToReleaseFissure)
        end
    end
    _potential_fissures[inst] = nil
end

----------
-- Events.
----------


local function OnIsNightmareWild(inst, isnightmarewild)
    --print("OnIsNightmareWild", isnightmarewild)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:WatchWorldState("isnightmarewild", OnIsNightmareWild)
OnIsNightmareWild(inst, _world.state.isnightmarewild)
inst:ListenForEvent("ms_riftaddedtopool", StartOrStopFindingGoodFissures, _world)
inst:ListenForEvent("ms_riftremovedfrompool", StartOrStopFindingGoodFissures, _world)

function self:CheckForNoThralls()
    if _thrall_count <= 0 then
        self:ReleaseFissure(TUNING.FISSURE_COOLDOWN_DEFEATED_ANY_THRALLS)
    end
end

local function OnRemove_Hands(inst, data)
    _thrall_count = _thrall_count - 1
    _thrall_hands = nil
    self:CheckForNoThralls()
end
local function OnRemove_Horns(inst, data)
    _thrall_count = _thrall_count - 1
    _thrall_horns = nil
    self:CheckForNoThralls()
end
local function OnRemove_Wings(inst, data)
    _thrall_count = _thrall_count - 1
    _thrall_wings = nil
    self:CheckForNoThralls()
end

function self:StartEventListeners()
    if _thrall_hands then
        _thrall_count = _thrall_count + 1
        self.inst:ListenForEvent("onremove", OnRemove_Hands, _thrall_hands)
    end
    if _thrall_horns then
        _thrall_count = _thrall_count + 1
        self.inst:ListenForEvent("onremove", OnRemove_Horns, _thrall_horns)
    end
    if _thrall_wings then
        _thrall_count = _thrall_count + 1
        self.inst:ListenForEvent("onremove", OnRemove_Wings, _thrall_wings)
    end
end

function self:KillThrall(thrall)
    if thrall.components.lootdropper then
        thrall.components.lootdropper:SetLoot({})
        thrall.components.lootdropper:SetChanceLootTable(nil)
    end

    if thrall.components.health then
        thrall.components.health:SetPercent(0)
    end
end

function self:ReleaseFissure(cooldown)
    if _fissure then
        if _spawn_thralls_task ~= nil then
            _spawn_thralls_task:Cancel()
            _spawn_thralls_task = nil
        end

        _internal_cooldown = GetTime() + math.max(cooldown or 0, 5)

        local fissure = _fissure -- Local copy which stops GetControlledFissure from returning things during shutdown sequence.
        _fissure = nil
        --print("ReleaseFissure", _fissure)
        fissure:OnReleasedFromControl()

        if _miasmas then
            for miasma, _ in pairs(_miasmas) do
                miasma:Remove()
            end
            _miasmas = nil
        end

        if _thrall_hands then
            self:KillThrall(_thrall_hands)
            _thrall_hands = nil
        end
        if _thrall_horns then
            self:KillThrall(_thrall_horns)
            _thrall_horns = nil
        end
        if _thrall_wings then
            self:KillThrall(_thrall_wings)
            _thrall_wings = nil
        end

        StartOrStopFindingGoodFissures()
    end
end

local function NoHoles(pt)
    return not _map:IsPointNearHole(pt)
end

function self:SpawnThrallFromPoint(prefabname, x, z, angle, delay)
    -- Do not edit origin in here it is used repeatedly.
    local thrall = SpawnPrefab(prefabname)

	local origin = Vector3(x, 0, z)
	local offset = FindWalkableOffset(origin, angle * DEGREES, MIASMA_RADIUS - math.random() * .5, 8, false, true, NoHoles, false, false)
    if offset then
		thrall.Transform:SetPosition(x + offset.x, 0, z + offset.z)
    else
		thrall.Transform:SetPosition(x, 0, z)
    end

	if thrall.components.knownlocations ~= nil then
		thrall.components.knownlocations:RememberLocation("spawnpoint", origin)
	end

	thrall.sg:GoToState("spawndelay", delay)

    return thrall
end

function self:OnDreadstoneMineCooldown(fromload)
    _dreadstone_regen_task = nil
    if _fissure then
        _fissure:OnDreadstoneMineCooldown(fromload)
    end
end

local function OnMineCooldown(inst)
    self:OnDreadstoneMineCooldown()
end

function self:OnFissureMinedFinished(fissure)
    if _dreadstone_regen_task ~= nil then
        _dreadstone_regen_task:Cancel()
        _dreadstone_regen_task = nil
    end
    _dreadstone_regen_task = self.inst:DoTaskInTime(TUNING.FISSURE_DREADSTONE_COOLDOWN, OnMineCooldown)
end

local function OnRemove_Miasma(inst)
    if _miasmas then
        _miasmas[inst] = nil
    end
end

function self:OnFissureAnimationsFinished(fissure)
    if fissure == _fissure then
        _fissure_animating = nil
        --print("Fissure animations finished, spawn things.")
        local workable = _fissure.components.workable
        if workable then
            if _dreadstone_regen_task == nil then
                OnMineCooldown()
            end
        end

        local x, y, z = _fissure.Transform:GetWorldPosition()

        local theta = math.random() * PI2
        for i = 1, MIASMAS do
            theta = theta + (PI2 / MIASMAS)
            local ox, oz = x + math.cos(theta) * MIASMA_RADIUS, z + math.sin(theta) * MIASMA_RADIUS
            if _map:IsVisualGroundAtPoint(ox, y, oz) then
                local miasma = SpawnPrefab("miasma_cloud")
                _miasmas = _miasmas or {}
                _miasmas[miasma] = true
                miasma:ListenForEvent("onremove", OnRemove_Miasma)
                miasma.Transform:SetPosition(ox, y, oz)
            end
        end

        if _spawn_thralls_task ~= nil then
            _spawn_thralls_task:Cancel()
            _spawn_thralls_task = nil
        end

        _spawn_thralls_task = self.inst:DoPeriodicTask(CHECK_FISSURE_INTERVAL, OnSpawnThralls_Bridge)
    end
end

function self:ControlFissure(fissure)
    if not _fissure then
        fissure:OnNightmarePhaseChanged("controlled", false)
        _fissure = fissure -- After OnNightmarePhaseChanged.
        _fissure_animating = true
        --print("ControlFissure", _fissure)
    end
end

function self:GetControlledFissure()
    return _fissure
end

function self:GetThrallCount()
    return _thrall_count
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}
    local timeleft = _internal_cooldown - GetTime()
    if timeleft > 0 then
        data.cooldown = timeleft
    end
    if _dreadstone_regen_task ~= nil then
        timeleft = GetTaskRemaining(_dreadstone_regen_task)
        if timeleft > 0 then
            data.dreadstonecooldown = timeleft
        end
    end
    if _spawn_thralls_task ~= nil then
        timeleft = GetTaskRemaining(_spawn_thralls_task)
        if timeleft > 0 then
            data.spawnthrallstime = timeleft
        end
    end
    local ents = {}

    if _fissure ~= nil and _fissure_animating == nil then -- If it is animating it has not spawned the arena yet.
        data.fissure = _fissure.GUID
        table.insert(ents, _fissure.GUID)
    end

    if _miasmas ~= nil then
        local miasmas = {}
        data.miasmas = miasmas
        for miasma, _ in pairs(_miasmas) do
            table.insert(miasmas, miasma.GUID)
            table.insert(ents, miasma.GUID)
        end
    end

    if _thrall_hands ~= nil then
        data.thrall_hands = _thrall_hands.GUID
        table.insert(ents, _thrall_hands.GUID)
    end
    if _thrall_horns ~= nil then
        data.thrall_horns = _thrall_horns.GUID
        table.insert(ents, _thrall_horns.GUID)
    end
    if _thrall_wings ~= nil then
        data.thrall_wings = _thrall_wings.GUID
        table.insert(ents, _thrall_wings.GUID)
    end

    return data, ents
end

local function OnLoadingGraceTime()
    _loading = nil
end

function self:OnLoad(data)
    if data then
        _internal_cooldown = GetTime() + (data.cooldown or _internal_cooldown)
        if data.dreadstonecooldown then
            _dreadstone_regen_task = self.inst:DoTaskInTime(data.dreadstonecooldown, OnMineCooldown)
        end
        if data.spawnthrallstime then
            _spawn_thralls_task = self.inst:DoPeriodicTask(CHECK_FISSURE_INTERVAL, OnSpawnThralls_Bridge, data.spawnthrallstime)
        end
        _loading = true
        self.inst:DoTaskInTime(LOADING_GRACE_TIME, OnLoadingGraceTime)
    end
end

function self:LoadPostPass(newents, savedata)
    if newents[savedata.fissure] then
        _fissure = newents[savedata.fissure].entity
        _fissure:OnNightmarePhaseChanged("controlled", true)
    end

    if savedata.miasmas ~= nil then
        for _, miasma in ipairs(savedata.miasmas) do
            if newents[miasma] then
                _miasmas = _miasmas or {}
                local newmiasma = newents[miasma].entity
                _miasmas[newmiasma] = true
                newmiasma:ListenForEvent("onremove", OnRemove_Miasma)
            end
        end
    end

    if newents[savedata.thrall_hands] then
        _thrall_hands = newents[savedata.thrall_hands].entity
    end
    if newents[savedata.thrall_horns] then
        _thrall_horns = newents[savedata.thrall_horns].entity
    end
    if newents[savedata.thrall_wings] then
        _thrall_wings = newents[savedata.thrall_wings].entity
    end
    self:StartEventListeners()
    if _fissure and _spawn_thralls_task == nil then
        self:CheckForNoThralls() -- Has a fissure and the thralls were spawned.
    end
    self.inst:DoTaskInTime(0, StartOrStopFindingGoodFissures)
    if _dreadstone_regen_task == nil then
        self:OnDreadstoneMineCooldown(true)
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local t = GetTime()
    return string.format("Has Fissure: %s, Hands: %s, Horns: %s, Wings: %s, Spawn CD: %.1f, Dread CD: %.1f, SpawnThralls: %.1f, CombatTask: %.1f, Loading: %s",
        tostring(self:GetControlledFissure() ~= nil),
        tostring(_thrall_hands ~= nil),
        tostring(_thrall_horns ~= nil),
        tostring(_thrall_wings ~= nil),
        math.max(_internal_cooldown - t, 0),
        _dreadstone_regen_task == nil and 0 or GetTaskRemaining(_dreadstone_regen_task),
        _spawn_thralls_task == nil and 0 or GetTaskRemaining(_spawn_thralls_task),
        _thrall_combatcheck_task == nil and 0 or GetTaskRemaining(_thrall_combatcheck_task),
        tostring(_loading ~= nil))
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)