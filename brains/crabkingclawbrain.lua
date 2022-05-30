require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "behaviours/leash"

local WAMDER_DIST = 2
local LEASH_DIST = 6

local BOAT_TAGS = {"boat"}

local function ShouldClamp(inst)
    if inst:IsValid() and not inst.sg:HasStateTag("busy") then
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 4.5, BOAT_TAGS)
        if #ents > 0 then
            for i=#ents, 1, -1 do
                if not ents[i]:IsValid() or ents[i].components.health:IsDead() then
                    table.remove(ents,i)
                end
            end
        end
        if #ents > 0 then
            inst:PushEvent("clamp",{target = ents[1]})
        end
    end
    return nil
end

local function findboattoclamp(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 10, BOAT_TAGS)
    if #ents>0 then
        return Vector3(ents[1].Transform:GetWorldPosition())
    end
end


local CrabkingClawBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CrabkingClawBrain:OnStart()
    local root = PriorityNode(
    {
       WhileNode(function() return not self.inst.sg:HasStateTag("clampped") end, "not clamping",
        PriorityNode({

            Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("spawnpoint") end, LEASH_DIST, 5, false),

            DoAction(self.inst, ShouldClamp, "clamp!"),
            Leash(self.inst, function() return findboattoclamp(self.inst) end, 0, 0, false),

            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("spawnpoint") end, WAMDER_DIST,
                {
                    minwalktime=0.5,
                    randwalktime=0.5,
                    minwaittime=1,
                    randwaittime=5,
                }
            )
        }, 0.2)),
    }, 0.2)

    self.bt = BT(self.inst, root)
end

function CrabkingClawBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return CrabkingClawBrain
