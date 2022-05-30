--------------------------------------------------------------------------
--[[ DesolationSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "DesolationSpawner should not exist on client")

require "map/terrain"

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local UPDATE_PERIOD = 11 -- less likely to update on the same frame as others
local SEARCH_RADIUS = 50
local BASE_RADIUS = 20
local EXCLUDE_RADIUS = 3
local MIN_PLAYER_DISTANCE = 64 * 1.2 -- this is our "outer" sleep radius

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _worldstate = TheWorld.state
local _map = TheWorld.Map
local _world = TheWorld

local _internaltimes = {}

local _replacementdata = {} -- this components is "externally configured" e.g. from mods
local _areadata = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local TEST_ONEOF_TAGS = { "structure", "wall" }
local function TestForRegrow(x, y, z, prefab, searchtags)

    local ents = TheSim:FindEntities(x,y,z, EXCLUDE_RADIUS)
    if #ents > 0 then
        -- Too dense
        return false
    end

    local ents = TheSim:FindEntities(x,y,z, BASE_RADIUS, nil, nil, TEST_ONEOF_TAGS)
    if #ents > 0 then
        -- Don't spawn inside bases
        return false
    end

    local ents = TheSim:FindEntities(x,y,z, SEARCH_RADIUS, searchtags)
    if #ents > 0 then
        -- This ent is already "seeded", no need to desolation-spawn one.
        return false
    end

    if not (_map:CanPlantAtPoint(x, y, z) and
            _map:CanPlacePrefabFilteredAtPoint(x, y, z, prefab))
        or (RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z)) then
        -- Not ground we can grow on
        return false
    end
    return true
end

local function DoRegrowth(area, prefab, product, searchtags)
    local points_x, points_y = _map:GetRandomPointsForSite(_world.topology.nodes[area].x, _world.topology.nodes[area].y, _world.topology.nodes[area].poly, 1)
    if #points_x < 1 or #points_y < 1 then
        return
    end
    local x = points_x[1]
    local z = points_y[1]
    --local x = _world.topology.nodes[area].x
    --local z = _world.topology.nodes[area].y

    --if not IsAnyPlayerInRange(x,0,z, MIN_PLAYER_DISTANCE, nil) then
        if TestForRegrow(x,0,z, product, searchtags) then
            local instance = SpawnPrefab(product)
            --print("Making a",product," from ",prefab," for ",area)
            if instance ~= nil then
                instance.Transform:SetPosition(x,0,z)
            end
            --print(string.format("Making %s for site %d\nSite: %f,%f\nPoint: %f,%f", prefab, area,
                    --_world.topology.nodes[area].x, _world.topology.nodes[area].y,
                    --x, z))
            --c_teleport(x,0,z)
            --TheCamera:Snap()
            return true
        else
            --print(string.format("FAILED Making %s for site %d\nSite: %f,%f\nPoint: %f,%f", prefab, area,
                    --_world.topology.nodes[area].x, _world.topology.nodes[area].y,
                    --x, z))
            return false
        end
    --else
        --return false
    --end
end

local function PopulateAreaData(prefab)
    if _world.generated == nil then
        -- Still starting up, not ready yet.
        return
    end

    for area, densities in pairs(_world.generated.densities) do
        if densities[prefab] ~= nil then
            for i, v in ipairs(_world.topology.ids) do
                if v == area then
                    if _areadata[i] == nil then
                        _areadata[i] = {}
                    end
                    if _areadata[i][prefab] == nil then
                        _areadata[i][prefab] =
                        {
                            denstiy = densities[prefab],
                            regrowtime = _internaltimes[prefab] + math.random() * _replacementdata[prefab].regrowtime, -- initial offset is randomized
                        }
                    -- else this was already populated by Load
                    end
                    break
                end
            end
        end
    end
end

local function PopulateAreaDataFromReplacements()
    -- This has to be run after 1 frame from startup
    for prefab, _ in pairs(_replacementdata) do
        PopulateAreaData(prefab)
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetSpawningForType(prefab, product, regrowtime, searchtags, timemult)
    _replacementdata[prefab] = {product=product, regrowtime=regrowtime, searchtags=searchtags, timemult=timemult}
    _internaltimes[prefab] = 0
    PopulateAreaData(prefab)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables

--Register events

inst:DoPeriodicTask(UPDATE_PERIOD, function() self:LongUpdate(UPDATE_PERIOD) end)

self:SetSpawningForType("evergreen", "pinecone_sapling", TUNING.EVERGREEN_REGROWTH.DESOLATION_RESPAWN_TIME, {"evergreen"}, function()
    return (_worldstate.issummer and TUNING.EVERGREEN_REGROWTH_TIME_MULT * 2) or (_worldstate.iswinter and 0) or TUNING.EVERGREEN_REGROWTH_TIME_MULT
end)
self:SetSpawningForType("evergreen_sparse", "lumpy_sapling", TUNING.EVERGREEN_SPARSE_REGROWTH.DESOLATION_RESPAWN_TIME, {"evergreen_sparse"}, function()
    return TUNING.EVERGREEN_REGROWTH_TIME_MULT
end)
self:SetSpawningForType("twiggytree", "twiggy_nut_sapling", TUNING.TWIGGY_TREE_REGROWTH.DESOLATION_RESPAWN_TIME, {"twiggytree"}, function()
    return TUNING.TWIGGYTREE_REGROWTH_TIME_MULT
end)
self:SetSpawningForType("deciduoustree", "acorn_sapling", TUNING.DECIDUOUS_REGROWTH.DESOLATION_RESPAWN_TIME, {"deciduoustree"}, function()
    return (not _worldstate.isspring and 0) or TUNING.DECIDIOUS_REGROWTH_TIME_MULT
end)
self:SetSpawningForType("mushtree_tall", "mushtree_tall", TUNING.MUSHTREE_REGROWTH.DESOLATION_RESPAWN_TIME, {"mushtree"}, function()
    return (not _worldstate.iswinter and 0) or TUNING.MUSHTREE_REGROWTH_TIME_MULT
end)
self:SetSpawningForType("mushtree_medium", "mushtree_medium", TUNING.MUSHTREE_REGROWTH.DESOLATION_RESPAWN_TIME, {"mushtree"}, function()
    return (not _worldstate.issummer and 0) or TUNING.MUSHTREE_REGROWTH_TIME_MULT
end)
self:SetSpawningForType("mushtree_small", "mushtree_small", TUNING.MUSHTREE_REGROWTH.DESOLATION_RESPAWN_TIME, {"mushtree"}, function()
    return (not _worldstate.isspring and 0) or TUNING.MUSHTREE_REGROWTH_TIME_MULT
end)

local moon_tree_mult =
{
    new = 0,
    quarter = 0.5,
    half = 1.0,
    threequarter = 1.5,
    full = 2.0,
}
self:SetSpawningForType("moon_tree", "moonbutterfly_sapling", TUNING.EVERGREEN_REGROWTH.DESOLATION_RESPAWN_TIME, {"moon_tree"}, function()
    return (TUNING.MOONTREE_REGROWTH_TIME_MULT * moon_tree_mult[_worldstate.moonphase]) or 0
end)

inst:DoTaskInTime(0, PopulateAreaDataFromReplacements)

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------


function self:LongUpdate(dt)
    for k, data in pairs(_replacementdata) do
        local prefabtimemult = _replacementdata[k].timemult and _replacementdata[k].timemult() or 1
        _internaltimes[k] = _internaltimes[k] + dt * TUNING.REGROWTH_TIME_MULTIPLIER * prefabtimemult
    end

    for area,data in pairs(_areadata) do
        for prefab, prefabdata in pairs(data) do
            if prefabdata.regrowtime <= _internaltimes[prefab] then
                --print("time for",prefab,"in",area)
                prefabdata.regrowtime = _internaltimes[prefab] + _replacementdata[prefab].regrowtime
                DoRegrowth(area, prefab, _replacementdata[prefab].product, _replacementdata[prefab].searchtags)
                --for performance, only DoRegrowth once per update
                return
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {
        areas = {}
    }
    for area, areadata in pairs(_areadata) do
        data.areas[area] = { }
        for prefab, prefabdata in pairs(areadata) do
            data.areas[area][prefab] = {
                density = prefabdata.density,
                regrowtime = prefabdata.regrowtime - _internaltimes[prefab],
            }
        end
    end
    return data
end

function self:OnLoad(data)
    for area, areadata in pairs(data.areas) do
        for prefab, prefabdata in pairs(areadata) do
            if _areadata[area] == nil then
                _areadata[area] = {}
            end
            _areadata[area][prefab] = {
                density = prefabdata.density,
                regrowtime = prefabdata.regrowtime + _internaltimes[prefab],
            }
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local s = ""
    local nextdata = {}
    for area, data in pairs(_areadata) do
        for prefab, prefabdata in pairs(data) do
            if nextdata[prefab] == nil or nextdata[prefab] > prefabdata.regrowtime then
                nextdata[prefab] = prefabdata.regrowtime
            end
        end
    end
    for prefab, time in pairs(nextdata) do
        s = s..string.format("%s: %.1f/%.1f ", prefab, _internaltimes[prefab], time)
    end
    return s
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
