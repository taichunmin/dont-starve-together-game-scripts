require "behaviours/standstill"
require "behaviours/wander"

local WobsterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MAX_WANDER_DISTANCE = 10

local function get_home(inst)
    return inst.components.knownlocations:GetLocation("home")
end

local WANDER_TIMES =
{
    minwalktime = 3,
    randwalktime = 2,
    minwaittime = 4,
    randwaittime = 4,
}

local STRUGGLE_WANDER_TIMES = {minwalktime=0.3, randwalktime=0.2, minwaittime=0.0, randwaittime=0.0}
local STRUGGLE_WANDER_DATA = {wander_dist = 1, should_run = true}

local TIREDOUT_WANDER_TIMES = {minwalktime=0.5, randwalktime=0.5, minwaittime=0.0, randwaittime=0.0}
local TIREDOUT_WANDER_DATA = {wander_dist = 3, should_run = false}

local LURE_WANDER_DIST = 4
local LURE_WANDER_TIMES = {minwalktime=0.6, randwalktime=0.2, minwaittime=0.0, randwaittime=0.0}
local LURE_WANDER_DATA = {wander_dist = 2}

local function get_fisher_position(inst)
    local rod = inst.components.oceanfishable:GetRod()
    return (rod ~= nil and rod:GetPosition()) or nil
end

local function go_home_action(inst)
    if inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local HALF_STRUGGLE_ANGLE_RANGE = 25
local STRUGGLE_ANGLE_RANGE = HALF_STRUGGLE_ANGLE_RANGE * 2
local function get_struggle_direction(inst)
    local rod = inst.components.oceanfishable:GetRod()
    local angle = math.random(STRUGGLE_ANGLE_RANGE) - HALF_STRUGGLE_ANGLE_RANGE + inst:GetAngleToPoint(rod:GetPosition():Get())
    return angle * DEGREES
end

local function get_tired_out_direction(inst)
    local rod = inst.components.oceanfishable:GetRod()
    local angle = inst:GetAngleToPoint(rod.Transform:GetWorldPosition())

    local r = math.random() * 2 - 1
    return (angle + r * r * r * 120) * DEGREES
end

local function get_instance_lure_target(inst)
    return (inst._lure_target ~= nil and inst._lure_target:IsValid() and inst._lure_target)
            or nil
end

local function get_instance_lure_target_position(inst)
    return (inst._lure_target ~= nil and inst._lure_target:IsValid() and inst._lure_target:GetPosition())
            or nil
end

local SEE_LURE_DISTANCE = 5
local LURE_MUST_NOT_TAGS = {"planted"}
local LURE_MUST_TAGS = {"fishinghook"}
local function find_lure_target(inst)
    if get_instance_lure_target(inst) == nil then
        inst._lure_target = FindEntity(
            inst,
            SEE_LURE_DISTANCE,
            function(item)
                return item.components.oceanfishinghook ~= nil
                        and TheWorld.Map:IsOceanAtPoint(item.Transform:GetWorldPosition())
                        --and not item.components.oceanfishinghook:HasLostInterest(inst)
                        --and item.components.oceanfishinghook:TestInterest(inst)
            end,
            LURE_MUST_TAGS,
            LURE_MUST_NOT_TAGS
        )

        inst._num_lure_nibbles = 1
    end

    return false
end

local GUARANTEED_CATCH_INTEREST_LEVEL = 0.85
local MINIMUM_BITE_INTEREST_LEVEL = GUARANTEED_CATCH_INTEREST_LEVEL - 0.70
local MAX_NIBBLES_PER_LURE = 20
local function nibble_lure(inst)
    local action_to_perform = nil
    local lure = get_instance_lure_target(inst)

    if lure ~= nil then
        local interest = lure.components.oceanfishinghook:UpdateInterestForFishable(inst)
        local random_interest_test = math.random()

        if interest <= 0 then
            inst._lure_target = nil
        elseif inst._num_lure_nibbles >= MAX_NIBBLES_PER_LURE then
            lure.components.oceanfishinghook:SetLostInterest(inst)
            inst._lure_target = nil
        elseif interest > GUARANTEED_CATCH_INTEREST_LEVEL or
                ((interest > MINIMUM_BITE_INTEREST_LEVEL or inst._num_lure_nibbles > 2) and interest > random_interest_test) then
            action_to_perform = BufferedAction(inst, lure, ACTIONS.EAT)
        else
            action_to_perform = BufferedAction(inst, lure, ACTIONS.WALKTO)
        end

        inst._num_lure_nibbles = inst._num_lure_nibbles + 1
    end

    return action_to_perform
end

function WobsterBrain:OnStart()
    local is_jumping = function()
        return not self.inst.sg:HasStateTag("jumping")
    end

    local has_fishing_rod = function()
        return self.inst.components.oceanfishable ~= nil
            and self.inst.components.oceanfishable:GetRod() ~= nil
    end

    local is_partially_hooked = function()
        return self.inst:HasTag("partiallyhooked")
    end

    local struggle_update = function()
        self.inst.components.oceanfishable:UpdateStruggleState()
        return self.inst.components.oceanfishable:IsStruggling()
    end

    local should_go_home = function()
        return TheWorld.state.isday or TheWorld.state.iscaveday
    end

    local root = PriorityNode(
    {
        WhileNode( is_jumping, "<Jump Guard>",
            PriorityNode({
                WhileNode( has_fishing_rod, "Hooked",
                    PriorityNode({
                        WhileNode( is_partially_hooked, "Partially Hooked",
                            StandStill(self.inst)
                        ),
                        PriorityNode({
                            WhileNode( struggle_update, "Struggling",
                                Wander(self.inst, get_fisher_position, TUNING.OCEAN_FISHING.MAX_HOOK_DIST, STRUGGLE_WANDER_TIMES, get_struggle_direction, nil, nil, STRUGGLE_WANDER_DATA)
                            ),
                            Wander(self.inst, get_fisher_position, TUNING.OCEAN_FISHING.MAX_HOOK_DIST, TIREDOUT_WANDER_TIMES, get_tired_out_direction, nil, nil, TIREDOUT_WANDER_DATA),
                        }),
                    })
                ),

                WhileNode( should_go_home, "Should Go Home",
                    DoAction(self.inst, go_home_action, "Going Home")
                ),

                NotDecorator(
                    ActionNode(function() find_lure_target(self.inst) end)
                ),
                WhileNode(
                    function()
                        return get_instance_lure_target(self.inst) ~= nil
                    end,
                    "Lure Nibbling",
                    LoopNode {
                        ParallelNodeAny {
                            WaitNode(function() return 2 + math.random() end),
                            Wander(self.inst, get_instance_lure_target_position, LURE_WANDER_DIST, LURE_WANDER_TIMES, nil, nil, nil, LURE_WANDER_DATA),
                        },
                        DoAction(self.inst, nibble_lure),
                        ConditionWaitNode(function() return self.inst:GetBufferedAction() == nil end),
                    }
                ),

                Wander(self.inst, get_home, MAX_WANDER_DISTANCE, WANDER_TIMES),
            }, 0.30)
        ),
    }, 0.30)

    self.bt = BT(self.inst, root)
end

return WobsterBrain
