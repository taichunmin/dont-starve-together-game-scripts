require "behaviours/wander"

local WobsterLandBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MAX_WANDER_DISTANCE = 5
local OCEAN_SEARCH_DISTANCE = MAX_WANDER_DISTANCE * 2.
local HOP_DISTANCE = 1.5
local WANDER_TIMES =
{
    minwalktime = 3,
    randwalktime = 1,
    minwaittime = 0,
    randwaittime = 0.1,
}

local function not_land(position)
    local px, py, pz = position:Get()
    return TheWorld.Map:IsOceanAtPoint(px, py, pz, false)
end

local function find_ocean_position(inst)
    if inst._ocean_escape_position == nil then
        local ip = inst:GetPosition()
        local offset, c_angle, deflected = FindWalkableOffset(ip, math.random()*2*PI, OCEAN_SEARCH_DISTANCE, nil, true, false, not_land, true, false)
        if offset then
            inst._ocean_escape_position = ip + offset
        end
    end

    return false
end

local function get_ocean_position(inst)
    return (inst._ocean_escape_position ~= nil and inst._ocean_escape_position) or nil
end

local function is_ocean_in_direction(position)
    return TheWorld.Map:IsOceanTileAtPoint(position:Get())
end

local function find_nearby_hop_point(inst)
    if inst._ocean_hop_position ~= nil then
        return true
    end

    local ip = inst:GetPosition()
    local ia = inst.Transform:GetRotation() * DEGREES
    local swim_point_offset, ca, deflected = FindWalkableOffset(ip, ia, HOP_DISTANCE, nil, true, false, not_land, true, false)
    if swim_point_offset then
        inst._ocean_hop_position = ip + swim_point_offset
        return true
    else
        return false
    end
end

local function hop_into_the_ocean(inst)
    inst:PushEvent("onhop", {hop_pos = inst._ocean_hop_position})
    inst._ocean_hop_position = nil
end

function WobsterLandBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(
            function()
                return not self.inst.sg:HasStateTag("jumping")
            end,
            "<Jump Guard>",
            PriorityNode({
                IfNode(
                    function()
                        return find_nearby_hop_point(self.inst)
                    end,
                    "Close Enough To Hop Into The Ocean!",
                    ActionNode(function() hop_into_the_ocean(self.inst) end)
                ),
                NotDecorator(
                    ActionNode(function() find_ocean_position(self.inst) end)
                ),
                WhileNode(
                    function()
                        return get_ocean_position(self.inst) ~= nil
                    end,
                    "Escaping To The Ocean",
                    Leash(self.inst, get_ocean_position, 0.5, 0.5)
                ),
                Wander(self.inst, nil, MAX_WANDER_DISTANCE, WANDER_TIMES),
            })
        ),
    })

    self.bt = BT(self.inst, root)
end

return WobsterLandBrain
