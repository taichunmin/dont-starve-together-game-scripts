--------------------------------------------------------------------------
--[[ ButterflySpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ButterflySpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}
local _scheduledtasks = {}
local _worldstate = TheWorld.state
local _updating = false
local _butterflies = {}
local _maxbutterflies = TUNING.MAX_BUTTERFLIES

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local FLOWER_TAGS = { "flower" }
local BUTTERFLY_TAGS = { "butterfly" }

local function GetSpawnPoint(player)
    local rad = 25
    local mindistance = 36
    local x, y, z = player.Transform:GetWorldPosition()
    local flowers = TheSim:FindEntities(x, y, z, rad, FLOWER_TAGS)

    for i, v in ipairs(flowers) do
        while v ~= nil and player:GetDistanceSqToInst(v) <= mindistance do
            table.remove(flowers, i)
            v = flowers[i]
        end
    end

    return next(flowers) ~= nil and flowers[math.random(1, #flowers)] or nil
end

local function SpawnButterflyForPlayer(player, reschedule)
    local pt = player:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 64, BUTTERFLY_TAGS)
    if #ents < _maxbutterflies then
        local spawnflower = GetSpawnPoint(player)
        if spawnflower ~= nil then
            local butterfly = SpawnPrefab("butterfly")
            if butterfly.components.pollinator ~= nil then
                butterfly.components.pollinator:Pollinate(spawnflower)
            end
            butterfly.components.homeseeker:SetHome(spawnflower)
			-- KAJ: TODO: Butterflies can be despawned before getting to the rest of the logic if this is above the homeseeker
            butterfly.Physics:Teleport(spawnflower.Transform:GetWorldPosition())
        end
    end
    _scheduledtasks[player] = nil
    reschedule(player)
end

local function ScheduleSpawn(player, initialspawn)
    if _scheduledtasks[player] == nil then
        local basedelay = initialspawn and 0.3 or 10
        _scheduledtasks[player] = player:DoTaskInTime(basedelay + math.random() * 10, SpawnButterflyForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function ToggleUpdate(force)
    if _worldstate.isday and not _worldstate.iswinter and _maxbutterflies > 0 then
        if not _updating then
            _updating = true
            for i, v in ipairs(_activeplayers) do
                ScheduleSpawn(v, true)
            end
        elseif force then
            for i, v in ipairs(_activeplayers) do
                CancelSpawn(v)
                ScheduleSpawn(v, true)
            end
        end
    elseif _updating then
        _updating = false
        for i, v in ipairs(_activeplayers) do
            CancelSpawn(v)
        end
    end
end

local function AutoRemoveTarget(inst, target)
    if _butterflies[target] ~= nil and target:IsAsleep() then
        target:Remove()
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTargetSleep(target)
    inst:DoTaskInTime(0, AutoRemoveTarget, target)
end

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
    if _updating then
        ScheduleSpawn(player, true)
    end
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            CancelSpawn(player)
            table.remove(_activeplayers, i)
            return
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:WatchWorldState("isday", ToggleUpdate)
inst:WatchWorldState("iswinter", ToggleUpdate)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SpawnModeNever()
    --depreciated
end

function self:SpawnModeLight()
    --depreciated
end

function self:SpawnModeMed()
    --depreciated
end

function self:SpawnModeHeavy()
    --depreciated
end

function self.StartTrackingFn(target)
    if _butterflies[target] == nil then
        local restore = target.persists and 1 or 0
        target.persists = false
        if target.components.homeseeker == nil then
            target:AddComponent("homeseeker")
        else
            restore = restore + 2
        end
        _butterflies[target] = restore
        inst:ListenForEvent("entitysleep", OnTargetSleep, target)
    end
end

function self:StartTracking(target)
    self.StartTrackingFn(target)
end

function self.StopTrackingFn(target)
    local restore = _butterflies[target]
    if restore ~= nil then
        target.persists = restore == 1 or restore == 3
        if restore < 2 then
            target:RemoveComponent("homeseeker")
        end
        _butterflies[target] = nil
        inst:RemoveEventCallback("entitysleep", OnTargetSleep, target)
    end
end

function self:StopTracking(target)
    self.StopTrackingFn(target)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local numbutterflies = 0
    for k, v in pairs(_butterflies) do
        numbutterflies = numbutterflies + 1
    end
    return string.format("updating:%s butterflies:%d/%d", tostring(_updating), numbutterflies, _maxbutterflies)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
