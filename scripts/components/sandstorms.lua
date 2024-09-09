--------------------------------------------------------------------------
--[[ Sandstorms class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Sandstorms should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _sandstormactive = false
local _issummer = false
local _iswet = false
local _oases = {} -- the oases are repireves from the sandstorm

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function ShouldActivateSandstorm()
    return _issummer and not _iswet
end

local function ToggleSandstorm()
    if _sandstormactive ~= ShouldActivateSandstorm() then
        _sandstormactive = not _sandstormactive
        inst:PushEvent("ms_stormchanged", {stormtype=STORM_TYPES.SANDSTORM,setting=_sandstormactive})
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSeasonTick(src, data)
    _issummer = data.season == SEASONS.SUMMER
    ToggleSandstorm()
end

local function OnWeatherTick(src, data)
    _iswet = data.wetness > 0 or data.snowlevel > 0
    ToggleSandstorm()
end

local function OnRemoveOasis(oasis)
    _oases[oasis] = nil
end

local function OnRegisterOasis(inst, oasis)
    if _oases[oasis] == nil then
        _oases[oasis] = true
        inst:ListenForEvent("onremove", OnRemoveOasis, oasis)
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("weathertick", OnWeatherTick)
inst:ListenForEvent("seasontick", OnSeasonTick)
inst:ListenForEvent("ms_registeroasis", OnRegisterOasis)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

-- assumes pos is within node_index and the node at node_index is a node_tag node. The caller must ensure this!
local function CalcTaggedNodeDepthSq(pos, node_index, node_tag)
    pos = { x = pos.x, y = pos.z }

    local depth = math.huge
    local node_edges = TheWorld.topology.nodes[node_index].validedges
    for _, edge_index in ipairs(node_edges) do
        local edge_nodes = TheWorld.topology.edgeToNodes[edge_index]
        local other_node_index = edge_nodes[1] ~= node_index and edge_nodes[1] or edge_nodes[2]
        if not table.contains(TheWorld.topology.nodes[other_node_index].tags, node_tag) then
            local point_indices = TheWorld.topology.flattenedEdges[edge_index]
            local node1 = { x = TheWorld.topology.flattenedPoints[point_indices[1]][1], y = TheWorld.topology.flattenedPoints[point_indices[1]][2] }
            local node2 = { x = TheWorld.topology.flattenedPoints[point_indices[2]][1], y = TheWorld.topology.flattenedPoints[point_indices[2]][2] }

            depth = math.min(depth, DistPointToSegmentXYSq(pos, node1, node2))
        end
    end

    return depth
end

-- TheWorld.components.sandstorms:CalcSandstormLevel(ThePlayer)
function self:CalcSandstormLevel(ent)
    return ent ~= nil
        and ent.components.areaaware ~= nil
        and math.min(math.sqrt(CalcTaggedNodeDepthSq(ent.components.areaaware.lastpt, ent.components.areaaware.current_area, "sandstorm")), TUNING.SANDSTORM_FULLY_ENTERED_DEPTH) / TUNING.SANDSTORM_FULLY_ENTERED_DEPTH
        or 0
end

function self:IsInOasis(ent)
    for oasis, _ in pairs(_oases) do
        if oasis.components.oasis ~= nil and oasis.components.oasis:IsEntityInOasis(ent) then
            return true
        end
    end
    return false
end

function self:CalcOasisLevel(ent)
    local maxlevel = 0
    for oasis, _ in pairs(_oases) do
        if oasis.components.oasis ~= nil then
            maxlevel = math.max(maxlevel, oasis.components.oasis:GetProximityLevel(ent, TUNING.SANDSTORM_FULLY_ENTERED_DEPTH))
            if maxlevel >= 1 then
                return 1
            end
        end
    end
    return maxlevel
end

function self:IsInSandstorm(ent)
    return _sandstormactive
        and ent.components.areaaware ~= nil
        and ent.components.areaaware:CurrentlyInTag("sandstorm")
end

function self:GetSandstormLevel(ent)
    if _sandstormactive and
        ent.components.areaaware ~= nil and
        ent.components.areaaware:CurrentlyInTag("sandstorm") then
        local oasislevel = self:CalcOasisLevel(ent)
        return oasislevel < 1
            and math.clamp(self:CalcSandstormLevel(ent) - oasislevel, 0, 1)
            or 0
    end
    --TODO: entities without areaaware need to know if they're inside the sandstorm
    return 0
end

function self:IsSandstormActive()
    return _sandstormactive
end

function self:RetrofitCheckIfWorldContainsOasis()
    return next(_oases) ~= nil
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
