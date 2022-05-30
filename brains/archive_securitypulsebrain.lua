require "behaviours/standstill"
require "behaviours/follow"
require "behaviours/doaction"

local MIN_FOLLOW = 1
local MAX_FOLLOW = 2
local TARGET_FOLLOW = 1
local WAYPOINT_RANGE = 34



local Archive_SecurityPulseBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function testbetweenpoints(pt1,pt2)
    local x1,y1,z1 = pt1.Transform:GetWorldPosition()
    local x2,y2,z2 = pt2.Transform:GetWorldPosition()

    local xdiff = (x2 - x1)/2
    local zdiff = (z2 - z1)/2

    local x = x1 + xdiff
    local z = z1 + zdiff

    return TheWorld.Map:IsVisualGroundAtPoint(x,0,z)
end

local WAYPOINT_MUST_TAGS = {"archive_waypoint"}
local function findwaypoint(inst)

    local target = nil
    local x,y,z = 0,0,0
    local wp = inst.lastwaypointGUID and Ents[inst.lastwaypointGUID] or nil
    if not wp then
        -- find nearest instead.. using the inst doesnt work well.
        x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, WAYPOINT_RANGE,WAYPOINT_MUST_TAGS)
        local dist = 9999*9999
        for i,ent in ipairs(ents) do
            local testdist = inst:GetDistanceSqToInst(ent)
            if testdist < dist then
                dist = testdist
                wp = ent
            end
        end
    end
    if wp then
        x,y,z = wp.Transform:GetWorldPosition()

        local ents = TheSim:FindEntities(x,y,z, WAYPOINT_RANGE,WAYPOINT_MUST_TAGS)
        for i=#ents,1,-1 do
            if ents[i] == wp or not testbetweenpoints(wp,ents[i]) then
                table.remove(ents,i)
            end
        end

        if #ents == 1 then
            target = ents[1]
        elseif #ents > 1 then
            for i=#ents,1,-1 do
                if inst.secondlastwaypointGUID and ents[i] == Ents[inst.secondlastwaypointGUID] then
                    table.remove(ents,i)
                end
            end
            if #ents > 0 then
                target = ents[math.random(1,#ents)]
            end
        end
    end

    if target then
        inst.secondlastwaypointGUID = inst.lastwaypointGUID
        inst.lastwaypointGUID = target.GUID
    end
    return target
end

local CENTIPEDE_MUST_TAGS= {"security_powerpoint"}
local function findcentipede(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 20,CENTIPEDE_MUST_TAGS)
    for i=#ents,1,-1 do
        if not ents[i].MED_THRESHOLD_DOWN or ents[i].components.health:GetPercent() < ents[i].MED_THRESHOLD_DOWN then
            table.remove(ents,i)
        end
    end
    if #ents > 0 then
        return ents[1]
    end
end

function Archive_SecurityPulseBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.patrol == true end, "find centipedes",
            Follow(self.inst, findcentipede, MIN_FOLLOW, TARGET_FOLLOW, MAX_FOLLOW, false)),
        WhileNode(function() return self.inst.patrol == true end, "find waypoints",
            Follow(self.inst, findwaypoint, MIN_FOLLOW, TARGET_FOLLOW, MAX_FOLLOW, false)),
        StandStill(self.inst),
    }, .25)
    self.bt = BT(self.inst, root)
end

return Archive_SecurityPulseBrain
