require "behaviours/runaway"
require "behaviours/panic"
require "behaviours/wander"
require "behaviours/follow"
local BrainCommon = require("brains/braincommon")

local SEE_THREAT_DIST = 3.5
local SEE_THREAT_DIST_ALERT = 8
local STOP_RUN_DIST = 5
local STOP_RUN_DIST_ALERT = 10

local MAX_WANDER_DIST = 10

local MIN_FOLLOW_DIST = 9
local MAX_FOLLOW_DIST = 12
local TARGET_FOLLOW_DIST = 10

local LightFlierBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local huntertags = { "scarytoprey" }
local hunterparams =
{
    tags = huntertags,
    notags = { "NOCLICK" },
    fn = function(hunter, inst)
        local follower = inst.components.formationfollower

        if follower.formationleader ~= nil and follower.formationleader.target == hunter then
            return false
        end

        return true
    end,
}
local hunterparams_alert =
{
    tags = huntertags,
    notags = { "NOCLICK" },
}

local NEW_HOME_TAGS = { "lightflier_home" }
local NEW_HOME_NOTAGS = { "burnt", "fire" }

local function GoHomeAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    local homeseeker = inst.components.homeseeker
    if homeseeker.home
        and homeseeker.home:IsValid()
        and homeseeker.home.components.childspawner
        and not homeseeker.home.components.burnable:IsBurning()
        and not homeseeker.home.components.pickable:CanBePicked() then

        return BufferedAction(inst, homeseeker.home, ACTIONS.GOHOME)
    end
end

local function FindHome(inst)
    if inst.components.homeseeker == nil then
        inst:AddComponent("homeseeker")
    end

    if inst.components.homeseeker.home == nil then
        local new_home = FindEntity(inst, MAX_WANDER_DIST, nil, NEW_HOME_TAGS, NEW_HOME_NOTAGS)
        if new_home ~= nil then
            new_home.components.childspawner:TakeOwnership(inst)
        end
    end
end

local function ShouldGoHome(inst)
    FindHome(inst)

    -- homeseeker is guaranteed to be valid after FindHome()
    local home = inst.components.homeseeker.home
    if home ~= nil and home:IsValid() and (home._lightflier_returning_home == inst
        or (inst:GetTimeAlive() > 60 and home.components.childspawner.numchildrenoutside > TUNING.LIGHTFLIER_FLOWER_TARGET_NUM_CHILDREN_OUTSIDE)) then

        return true
    end
end

function LightFlierBrain:OnStart()
    local root = PriorityNode({
        ParallelNode{
            ActionNode(function()
                self.inst.components.formationfollower.active = false
                self.inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
                self.inst.components.locomotor.directdrive = false
            end),

            PriorityNode({
                EventNode(self.inst, "panic",
                    ParallelNode{
                        Panic(self.inst),
                        WaitNode(6),
                    }),
				BrainCommon.PanicTrigger(self.inst),

                WhileNode(function() return GetTime() - self.inst._time_since_formation_attacked < TUNING.LIGHTFLIER.ON_ATTACKED_ALERT_DURATION end, "Recently Attacked",
                    RunAway(self.inst, hunterparams_alert, SEE_THREAT_DIST_ALERT, STOP_RUN_DIST_ALERT)),

                WhileNode(function() return self.inst.components.formationfollower.formationleader == nil end, "No Leader",
                    PriorityNode{
                        RunAway(self.inst, hunterparams, SEE_THREAT_DIST, STOP_RUN_DIST),
                        WhileNode(function()
                            return ShouldGoHome(self.inst)
                        end, "ShouldGoHome", DoAction(self.inst, GoHomeAction, "GoHome")),

                        Wander(self.inst, function()
                            local homepos = self.inst.components.homeseeker ~= nil and self.inst.components.homeseeker:GetHomePos() or nil
                            homepos = homepos or self.inst.components.knownlocations:GetLocation("home")
                            return homepos
                        end, MAX_WANDER_DIST),
                    }),

                -- Else no need to do anything from here, movement is handled on update from formationfollower component
                ActionNode(function()
                    self.inst.components.formationfollower.active = true
                    self.inst.components.locomotor.directdrive = true
                end),
            }, .25)
        }
    }, .25)

    self.bt = BT(self.inst, root)
end

return LightFlierBrain
