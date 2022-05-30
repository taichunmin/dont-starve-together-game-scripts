require "behaviours/attackwall"
require "behaviours/chaseandattack"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/wander"

local EyeOfTerrorMiniBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local FOOD_DISTANCE = 20
local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local food = FindEntity(inst, FOOD_DISTANCE, function(item)
        return inst.components.eater:CanEat(item)
            and item:IsOnPassablePoint(true)
    end)

    return (food ~= nil and BufferedAction(inst, food, ACTIONS.EAT))
        or nil
end

local function GetSpawnPoint(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

function EyeOfTerrorMiniBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("charge") end, "Not Attacking",
            PriorityNode({
                WhileNode(function()
                        return self.inst.components.hauntable
                            and self.inst.components.hauntable.panic
                    end, "PanicHaunted", Panic(self.inst)
                ),
                WhileNode(function()
                        return self.inst.components.health.takingfiredamage
                    end, "OnFire", Panic(self.inst)
                ),

                AttackWall(self.inst),
                ChaseAndAttack(self.inst),
                DoAction(self.inst, EatFoodAction, "Find And Eat Food"),
                Wander(self.inst, GetSpawnPoint, 25),
            }, 0.5)
        ),
    }, 0.5)

    self.bt = BT(self.inst, root)
end

function EyeOfTerrorMiniBrain:OnInitializationComplete()
    local pos = self.inst:GetPosition()
    pos.y = 0

    self.inst.components.knownlocations:RememberLocation("spawnpoint", pos, true)
end

return EyeOfTerrorMiniBrain
