--------------------------------------------------------------------------
--[[ Moonstorms class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--assert(TheWorld.ismastersim, "Moonstorms should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private

local _active_moonstorm_nodes = {}
local _mapmarkers = {}

self._moonstorm_nodes = net_ushortarray(inst.GUID, "moonstorm.moonstorm_nodes", "moonstorm_nodes_dirty")

self.inst:ListenForEvent("moonstorm_nodes_dirty", function(w,data)
    TheWorld:PushEvent("moonstorm_nodes_dirty_relay",data)
end)

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
local function convertlist(data)
    local newdat = {}
    for i,entry in pairs(data)do
        if entry== true then
            table.insert(newdat,i)
        end
    end
    return newdat
end
self.convertlist = convertlist
--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

-- assumes pos is within node_index. The caller must ensure this!
local function CalcTaggedNodeDepthSq(pos, node_index)
    pos = { x = pos.x, y = pos.z }

    local depth = math.huge
    local node_edges = TheWorld.topology.nodes[node_index].validedges
    for _, edge_index in ipairs(node_edges) do
        local edge_nodes = TheWorld.topology.edgeToNodes[edge_index]
        local other_node_index = edge_nodes[1] ~= node_index and edge_nodes[1] or edge_nodes[2]
        if not _active_moonstorm_nodes[other_node_index] then
            local point_indices = TheWorld.topology.flattenedEdges[edge_index]
            local node1 = { x = TheWorld.topology.flattenedPoints[point_indices[1]][1], y = TheWorld.topology.flattenedPoints[point_indices[1]][2] }
            local node2 = { x = TheWorld.topology.flattenedPoints[point_indices[2]][1], y = TheWorld.topology.flattenedPoints[point_indices[2]][2] }

            depth = math.min(depth, DistPointToSegmentXYSq(pos, node1, node2))
        end
    end

    return depth
end

-- TheWorld.components.moonstorms:CalcMoonstormLevel(ThePlayer)
function self:CalcMoonstormLevel(ent)
    return ent ~= nil
        and not TheWorld.Map:IsOceanAtPoint(ent:GetPosition():Get())
        and ent.components.areaaware ~= nil
        and math.min(math.sqrt(CalcTaggedNodeDepthSq(ent.components.areaaware.lastpt, ent.components.areaaware.current_area)), TUNING.SANDSTORM_FULLY_ENTERED_DEPTH) / TUNING.SANDSTORM_FULLY_ENTERED_DEPTH
        or 0
end

function self:IsInMoonstorm(ent)
    return next(_active_moonstorm_nodes) ~= nil
        and ent.components.areaaware ~= nil
        and _active_moonstorm_nodes[ent.components.areaaware.current_area]
end

function self:IsPointInMoonstorm(pt)
	local node_index = TheWorld.Map:GetNodeIdAtPoint(pt.x, 0, pt.z)
    return node_index ~= nil
        and _active_moonstorm_nodes[node_index]
        or false
end

function self:GetMoonstormLevel(ent)
    if self:IsInMoonstorm(ent) then
        return math.clamp(self:CalcMoonstormLevel(ent), 0, 1)
    end
    return 0
end

function self:AddMoonstormNodes(node_indices, firstnode)
    if type(node_indices) ~= "table" then
        node_indice = { node_indices }
    end

    for _, v in ipairs(node_indices) do
        _active_moonstorm_nodes[v] = true

        local marker = SpawnPrefab("moonstormmarker_big")
     --   local center = TheWorld.topology.nodes[firstnode].cent
        local center = TheWorld.topology.nodes[v].cent
        marker.Transform:SetPosition(center[1], 0, center[2])
        table.insert(_mapmarkers, marker)

    end

    self._moonstorm_nodes:set(convertlist(_active_moonstorm_nodes))
    TheWorld:PushEvent("ms_stormchanged",{stormtype=STORM_TYPES.MOONSTORM, setting=true})
    TheWorld:PushEvent("ms_moonstormwindowover")
end

function self:StopMoonstorm(is_relocating)
    self:ClearMoonstormNodes()
    TheWorld:PushEvent("ms_stormchanged",{stormtype=STORM_TYPES.MOONSTORM, setting=is_relocating == true})
end

function self:ClearMoonstormNodes()
    _active_moonstorm_nodes = {}
    self._moonstorm_nodes:set(convertlist(_active_moonstorm_nodes))
    for i = #_mapmarkers, 1, -1 do
        _mapmarkers[i]:Remove()
    end
    _mapmarkers = {}
end

function self:GetMoonstormNodes()
    return _active_moonstorm_nodes
end

function self:GetMoonstormCenter()
    local num_nodes = 0
    local x, y = 0, 0
    for k, v in pairs(_active_moonstorm_nodes) do
        local center = TheWorld.topology.nodes[k].cent

        x, y = x + center[1], y + center[2]
        num_nodes = num_nodes + 1
    end

    return num_nodes > 0 and Point(x / num_nodes, 0, y / num_nodes) or nil
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
