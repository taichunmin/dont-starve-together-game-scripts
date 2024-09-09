--------------------------------------------------------------------------
--[[ ForestPetrification class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ForestPetrification should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_SPAN_SQ = 36 * 36
local SECTOR_RADIUS = 4
local SECTOR_DIST = SECTOR_RADIUS * 1.41421 --math.sqrt(2) --NOT being bigger is more important than precision
local SECTOR_DIST_SQ = SECTOR_DIST * SECTOR_DIST
local PETRIFICATION_THRESHOLD = .2 --20% of remaining trees at most
local MAX_WORK = 10 --budget for update
local MAX_RETRIES = 5

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _tracked = {}
local _cooldowndays = nil

--Searching for forest
local _tovisit = nil
local _visited = nil
local _found = nil
local _numfound = nil
local _x0 = nil
local _z0 = nil
local _retries = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function RandomizeYearPart(minyears, maxyears)
    if minyears == nil or maxyears == nil or maxyears <= 0 then
        return -1
    end
    local year =
        TheWorld.state.autumnlength +
        TheWorld.state.winterlength +
        TheWorld.state.springlength +
        TheWorld.state.summerlength
    return math.random(math.ceil(year * minyears), math.ceil(year * maxyears))
end

local OnCycleComplete

local function StopCooldown()
    if _cooldowndays ~= nil then
        _cooldowndays = nil
        inst:RemoveEventCallback("ms_cyclecomplete", OnCycleComplete)
    end
end

local function StartCooldown(days)
    if days < 0 then
        StopCooldown()
    else
        if _cooldowndays == nil then
            inst:ListenForEvent("ms_cyclecomplete", OnCycleComplete)
        end
        _cooldowndays = days
        if days == 0 then
            OnCycleComplete()
        end
    end
end

local PETRIFIABLE_TAGS = { "petrifiable" }
local function CheckSector(row, col)
    --return value of work done, used to limit our update cost

    if _visited[row] == nil then
        _visited[row] = { [col] = true }
    elseif _visited[row][col] then
        return 0
    else
        _visited[row][col] = true
    end

    local ents = TheSim:FindEntities(_x0 + row * SECTOR_DIST, 0, _z0 + col * SECTOR_DIST, SECTOR_RADIUS, PETRIFIABLE_TAGS)
    if #ents <= 0 then
        return 1
    end

    for i, v in ipairs(ents) do
        if not _found[v] then
            _found[v] = true
            _numfound = _numfound + 1
        end
    end

    if (row * row + col * col) * SECTOR_DIST_SQ < MAX_SPAN_SQ then
        table.insert(_tovisit, { row + 1, col })
        table.insert(_tovisit, { row - 1, col })
        table.insert(_tovisit, { row, col + 1 })
        table.insert(_tovisit, { row, col - 1 })
    end
    return 2
end

local function StartFindingForest(retries)
    if _tovisit == nil and #_tracked > 0 then
        local y
        _x0, y, _z0 = _tracked[math.random(#_tracked)].Transform:GetWorldPosition()
        _tovisit = { { 0, 0 } }
        _visited = {}
        _found = {}
        _numfound = 0
        _retries = retries or MAX_RETRIES
        inst:StartUpdatingComponent(self)
    end
end

local function StopFindingForest()
    if _tovisit ~= nil then
        _tovisit = nil
        _visited = nil
        _found = nil
        _numfound = nil
        _x0 = nil
        _z0 = nil
        _retries = nil
        inst:StopUpdatingComponent(self)
    end
end

OnCycleComplete = function()
    if _cooldowndays > 1 then
        _cooldowndays = _cooldowndays - 1
    else
        StopCooldown()
        StartFindingForest()
    end
end

local function PetrifyForest()
    local xsum, zsum, count = 0, 0, 0
    for k, v in pairs(_found) do
        if k._petrification_index ~= nil then
            local x, y, z = k.Transform:GetWorldPosition()
            xsum = xsum + x
            zsum = zsum + z
            count = count + 1
            k.components.petrifiable:Petrify(false)
        end
    end
    if count > 0 then
        SpawnPrefab("petrify_announce").Transform:SetPosition(xsum / count, 0, zsum / count)
    end
end

local function StopTracking(target)
    if target._petrification_index == #_tracked then
        table.remove(_tracked)
        target._petrification_index = nil
    elseif target._petrification_index ~= nil then
        _tracked[#_tracked]._petrification_index = target._petrification_index
        _tracked[target._petrification_index] = table.remove(_tracked)
        target._petrification_index = nil
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnUnregisterPetrifiable(inst, target)
    inst:RemoveEventCallback("onremove", StopTracking, target)
    StopTracking(target)
end

local function OnRegisterPetrifiable(inst, target)
    if target._petrification_index == nil then
        table.insert(_tracked, target)
        target._petrification_index = #_tracked
        inst:ListenForEvent("onremove", StopTracking, target)
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

inst:ListenForEvent("ms_registerpetrifiable", OnRegisterPetrifiable)
inst:ListenForEvent("ms_unregisterpetrifiable", OnUnregisterPetrifiable)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    if _cooldowndays == nil and _tovisit == nil then
        StartCooldown(RandomizeYearPart(TUNING.PETRIFICATION_CYCLE.MIN_YEARS, TUNING.PETRIFICATION_CYCLE.MAX_YEARS))
    end
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate()--dt)
    if _tovisit ~= nil then
        local workleft = MAX_WORK
        while workleft > 0 do
            workleft = workleft - CheckSector(unpack(table.remove(_tovisit, 1)))

            if #_tovisit <= 0 then
                if _numfound > 0 and _numfound < PETRIFICATION_THRESHOLD * #_tracked then
                    PetrifyForest()
                    StopFindingForest()
                    StartCooldown(RandomizeYearPart(TUNING.PETRIFICATION_CYCLE.MIN_YEARS * .5, TUNING.PETRIFICATION_CYCLE.MAX_YEARS * .5))
                elseif _retries > 0 then
                    local retries = _retries
                    StopFindingForest()
                    StartFindingForest(retries - 1)
                else
                    StopFindingForest()
                    StartCooldown(RandomizeYearPart(TUNING.PETRIFICATION_CYCLE.MIN_YEARS * .5, TUNING.PETRIFICATION_CYCLE.MAX_YEARS * .5))
                end
                return
            end
        end
    else
        inst:StopUpdatingComponent(self)
    end
end

function self:LongUpdate(dt)
    while true do
        while _tovisit ~= nil do
            self:OnUpdate()
        end

        if dt <= 0 or _cooldowndays == nil then
            return
        end

        local days = math.floor(dt / TUNING.TOTAL_DAY_TIME)
        if _cooldowndays > days then
            _cooldowndays = _cooldowndays - days
            return
        end

        days = _cooldowndays
        StopCooldown()
        StartFindingForest()
        dt = dt - days * TUNING.TOTAL_DAY_TIME
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:FindForest()
    StopCooldown()
    StartFindingForest()
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data =
    {
        cooldown = _cooldowndays or (_tovisit ~= nil and 0 or nil),
    }
    return next(data) ~= nil and data or nil
end

function self:OnLoad(data)
    if data ~= nil and data.cooldown ~= nil and data.cooldown >= 1 then
        StopFindingForest()
        StartCooldown(math.floor(data.cooldown))
    end
end

function self:LoadPostPass(newents, data)
    if data ~= nil and data.cooldown == 0 and _tovisit == nil then
        StopCooldown()
        StartFindingForest()
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return (_tovisit ~= nil and "Finding forest..."..tostring(_numfound))
        or (_cooldowndays ~= nil and "Cooldown in "..tostring(_cooldowndays).." day(s)")
        or "Idle"
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
