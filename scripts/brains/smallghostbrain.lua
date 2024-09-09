require "behaviours/follow"
require "behaviours/wander"

local SmallGhostBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function get_follow_target(ghost)
    return ghost.components.follower.leader
end

local function get_closest_toy(toy_owner, dist_inst, dsq_gate)
    if toy_owner._toys == nil or next(toy_owner._toys) == nil or dist_inst == nil then
        return nil
    end

    local closest_toy = nil

    local closest_toy_dsq = dsq_gate or math.huge
    for toy, _ in pairs(toy_owner._toys) do
        local dsq = dist_inst:GetDistanceSqToInst(toy)
        if dsq < closest_toy_dsq then
            closest_toy = toy
            closest_toy_dsq = dsq
        end
    end

    return closest_toy
end

local function pickup_lost_toy(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    local closest_toy = get_closest_toy(inst, get_follow_target(inst), TUNING.GHOST_HUNT.PICKUP_DSQ)
    if closest_toy ~= nil then
        return BufferedAction(inst, closest_toy, ACTIONS.PICKUP)
    end
end

local MIN_HINT_DSQ = TUNING.GHOST_HUNT.MINIMUM_HINT_DIST * TUNING.GHOST_HUNT.MINIMUM_HINT_DIST
local MAX_HINT_DSQ = TUNING.GHOST_HUNT.MAXIMUM_HINT_DIST * TUNING.GHOST_HUNT.MAXIMUM_HINT_DIST
local function get_hint_location(inst)
    local leader = (inst.components.follower ~= nil and inst.components.follower:GetLeader()) or nil
    if leader == nil then
        return nil
    end

    local closest_toy = get_closest_toy(inst, leader)
    if closest_toy == nil then
        return nil
    end

    local dsq_to_closest_toy = leader:GetDistanceSqToInst(closest_toy)
    if dsq_to_closest_toy < MIN_HINT_DSQ or dsq_to_closest_toy > MAX_HINT_DSQ then
        -- If we're this close, we don't want to hint. We'll do searching instead.
        return nil
    end

    local position = closest_toy:GetPositionAdjacentTo(leader, TUNING.GHOST_HUNT.HINT_OFFSET)
    if position ~= nil then
        -- Add a little bit of fuzziness so the offset isn't a perfect line to the target.
        local random_fuzziness_angle = math.random() * TWOPI
        position = position + Vector3(math.sin(random_fuzziness_angle), 0, math.cos(random_fuzziness_angle))

        inst.sg.mem.is_hinting = true
        return BufferedAction(inst, nil, ACTIONS.JUMPIN, nil, position)
    end
end

local function test_for_finished_hinting(inst)
    local leader = (inst.components.follower ~= nil and inst.components.follower:GetLeader()) or nil
    if leader == nil then
        inst.sg.mem.is_hinting = false
        return
    end

    if inst.sg.mem.is_hinting then
        if inst:GetDistanceSqToInst(leader) > (TUNING.GHOST_RADIUS*TUNING.GHOST_RADIUS*16 + 0.5) then
            inst.sg.mem.is_hinting = false
            return
        end

        -- If we get close enough, our behaviour will change, so that's acceptable. However, if we get too far away,
        -- we need to call it out and explicitly end the hinting. Having the ghost hint/hop around all the time can be annoying.
        local closest_toy = get_closest_toy(inst, leader)
        if closest_toy == nil or leader:GetDistanceSqToInst(closest_toy) > MAX_HINT_DSQ then
            inst.sg.mem.is_hinting = false
            return
        end
    end
end

local function test_for_toy_in_search_range(inst)
    local leader = (inst.components.follower ~= nil and inst.components.follower:GetLeader()) or nil
    if leader == nil then
        return false
    end

    -- If there is a toy within min hunt distance of our leader, we should do searching behaviour.
    local closest_toy = get_closest_toy(inst, leader, MIN_HINT_DSQ)
    return closest_toy ~= nil
end

-------------------------------------------------------------------------------
--  Combat Avoidance

local COMBAT_TOO_CLOSE_DIST = 5                 -- distance for find enitities check
local COMBAT_TOO_CLOSE_DIST_SQ = COMBAT_TOO_CLOSE_DIST * COMBAT_TOO_CLOSE_DIST
local COMBAT_SAFE_TO_WATCH_FROM_DIST = 8        -- will run to this distance and watch if was too close
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST = 12   -- combat is quite far away now, better catch up
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ = COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST * COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST
local COMBAT_TIMEOUT = 6

local function _avoidtargetfn(self, target)
    if target == nil or not target:IsValid() then
        return false
    end

    local owner = self.inst.components.follower.leader
    local owner_combat = owner ~= nil and owner.components.combat or nil
    local target_combat = target.components.combat
    if owner_combat == nil or target_combat == nil then
        return false
    elseif target_combat:TargetIs(owner)
        or (target.components.grouptargeter ~= nil and target.components.grouptargeter:IsTargeting(owner)) then
        return true
    end

    local distsq = owner:GetDistanceSqToInst(target)
    if distsq >= COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ then
        -- Too far
        return false
    elseif distsq < COMBAT_TOO_CLOSE_DIST_SQ and target_combat:HasTarget() then
        -- Too close to any combat
        return true
    end

    -- Is owner in combat with target?
    -- Are owner and target both in any combat?
    local t = GetTime()
    return  (   (owner_combat:IsRecentTarget(target) or target_combat:HasTarget()) and
                math.max(owner_combat.laststartattacktime or 0, owner_combat.lastdoattacktime or 0) + COMBAT_TIMEOUT > t
            ) or
            (   owner_combat.lastattacker == target and
                owner_combat:GetLastAttackedTime() + COMBAT_TIMEOUT > t
            )
end

local function validate_combat_avoidance(self)
    if self.runawayfrom == nil then
        return false
    end

    if not self.runawayfrom:IsValid() then
        self.runawayfrom = nil
        return false
    end

    if not self.inst:IsNear(self.runawayfrom, COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST) then
        return false
    end

    if not _avoidtargetfn(self, self.runawayfrom) then
        self.runawayfrom = nil
        return false
    end

    return true
end

local function KeepFacingTarget(inst, target)
    return inst.components.follower.leader == target
end

local COMBAT_YES_TAGS = {"_combat", "_health"}
local COMBAT_NO_TAGS = {"wall", "INLIMBO"}

-------------------------------------------------------------------------------

local function leader_toy_near_speech(leader)
    leader.components.talker:Say(GetString(leader, "ANNOUNCE_GHOST_TOY_NEAR"))
end

local function try_toy_search_speech(inst)
    local leader = get_follow_target(inst)
    if leader ~= nil and leader.components.talker ~= nil and not inst._has_done_speech then
        local current_time = GetTime()
        if inst._next_leader_toy_search_speech_time == nil or inst._next_leader_toy_search_speech_time < current_time then
            inst._next_leader_toy_search_speech_time = current_time + 20

            inst.components.talker:Say(STRINGS.SMALLGHOST_TALK[math.random(#STRINGS.SMALLGHOST_TALK)])

            leader:DoTaskInTime(24*FRAMES, leader_toy_near_speech)

            inst._has_done_speech = true
        end
    end
end

local function toy_nearby_wander_home(inst)
    local leader = get_follow_target(inst)
    return (leader and leader:GetPosition()) or nil
end

local function toy_nearby_wander_angle(inst)
    local leader = get_follow_target(inst)
    local closest_toy = get_closest_toy(inst, leader, MIN_HINT_DSQ)
    return (closest_toy ~= nil and GetRandomWithVariance(closest_toy:GetAngleToPoint(leader.Transform:GetWorldPosition()), 10))
        or (TWOPI * math.random())
end

local GRAVESTONE_WANDER_TIMES =
{
    minwalktime = 1.0,
    randwalktime = 1.5,
    minwaittime = 1.0,
    randwaittime = 1.5,
}

function SmallGhostBrain:OnStart()
    local combatavoidance_data =
    {
        tags = COMBAT_YES_TAGS,
        notags = COMBAT_NO_TAGS,
        fn = function(ent)
            if _avoidtargetfn(self, ent) then
                self.runawayfrom = ent
                return true
            else
                return false
            end
        end
    }

    local root = PriorityNode(
    {
        DoAction(self.inst, pickup_lost_toy, "Find Nearby Lost Toys", true),

        -- Combat Avoidance
        PriorityNode{
            RunAway(self.inst, combatavoidance_data, COMBAT_TOO_CLOSE_DIST, COMBAT_SAFE_TO_WATCH_FROM_DIST),
            WhileNode(
                function() return validate_combat_avoidance(self) end,
                "Is Near Combat",
                FaceEntity(self.inst, get_follow_target, KeepFacingTarget)
            ),
        },

        FailIfSuccessDecorator(
            ActionNode(function() test_for_finished_hinting(self.inst) end, "Finish Hinting Test")
        ),

        WhileNode(
            function() return test_for_toy_in_search_range(self.inst) end,
            "Is A Toy Nearby?",
            PriorityNode {
                FailIfSuccessDecorator(
                    ActionNode(function() try_toy_search_speech(self.inst) end, "Start Searching Leader Speech")
                ),
                Follow(self.inst, get_follow_target, 0.5, 1.5, 3.0),
                Wander(self.inst, toy_nearby_wander_home, 10.0, GRAVESTONE_WANDER_TIMES, toy_nearby_wander_angle),
            }
        ),

        -- If we got here, we're not in search range anymore (else we'd be in the WhileNode above),
        -- so we can clear the speech flag so we do a speech the next time we get near a toy.
        FailIfSuccessDecorator(
            ActionNode(function() self.inst._has_done_speech = false end, "Clear Speech Flag")
        ),

        Follow(self.inst, get_follow_target, 0.0, 1.0, 6.0, true),
        DoAction(self.inst, get_hint_location, "Give a Hint"),
        SequenceNode{
            ParallelNodeAny{
                WaitNode(10),
                Wander(self.inst,
                    function(i)
                        local lead = get_follow_target(i)
                        return (lead and lead:GetPosition()) or i.components.knownlocations:GetLocation("home")
                    end,
                    6.0,
                    GRAVESTONE_WANDER_TIMES
                ),
            },
            ActionNode(function()
                if self.inst.components.knownlocations:GetLocation("home") == nil
                        and get_follow_target(self.inst) == nil then
                    self.inst.sg:GoToState("dissipate")
                end
            end),
        }
    }, 1)

    self.bt = BT(self.inst, root)
end

return SmallGhostBrain