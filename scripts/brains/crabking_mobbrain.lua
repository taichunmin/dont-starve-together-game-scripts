require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/doaction"

local BrainCommon = require "brains/braincommon"

------------------------------------------------------------------------------------------------------------------------------------

local MAX_WANDER_DIST = 32

local ABANDON_PLATFORM_HEALTH_THRESHOLD = 2

local function DoAbandonPlatform(inst)
    local platform = inst:GetCurrentPlatform()

    if platform ~= nil and platform.components.health.currenthealth <= ABANDON_PLATFORM_HEALTH_THRESHOLD then
        local x, y, z = platform.Transform:GetWorldPosition()

        local angle = platform:GetAngleToPoint(inst.Transform:GetWorldPosition()) * DEGREES
        local radius = platform:GetSafePhysicsRadius() - inst:GetPhysicsRadius(0) - .3

        radius = math.max(1, radius - .5)

        local theta, offset, jump_pos, test_pos

        local count = 0
        while count < 16 do
            count = count + 1

            theta = angle + (count * PI/8)

            offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))

            jump_pos = Vector3(x + offset.x, 0, z + offset.z)
            test_pos = jump_pos + offset

            if not TheWorld.Map:GetPlatformAtPoint(test_pos:Get()) then
                return BufferedAction(inst, nil, ACTIONS.ABANDON, nil, jump_pos)
            end
        end
    end
end

local function GetWanderPoint(inst)
    return inst.components.knownlocations:GetLocation("home")
end

------------------------------------------------------------------------------------------------------------------------------------

local CrabkingMobBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CrabkingMobBrain:OnStart()
    local root =
        PriorityNode(
        {
            BrainCommon.PanicTrigger(self.inst),
            DoAction(self.inst, DoAbandonPlatform, "Abandoning Platform", true),
            ChaseAndAttack(self.inst, TUNING.CRABKING_MOB_CHASE_TIME),
            Wander(self.inst, GetWanderPoint, MAX_WANDER_DIST)
        }, 1)

    self.bt = BT(self.inst, root)
end

function CrabkingMobBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition())
end

return CrabkingMobBrain