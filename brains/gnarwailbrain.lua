require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/leash"
require "behaviours/panicandavoid"
require "behaviours/wander"

local MAX_BOAT_FOLLOW_DIST = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 13
local MIN_BOAT_FOLLOW_DIST = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 2
local BOAT_TARGET_DISTANCE = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4
local MAX_CHASE_TIME = 15
local TRADE_DISTANCE = MAX_BOAT_FOLLOW_DIST + 3

local function HasValidWaterTarget(inst)
    -- We pass if we have a target, it's not on valid ground (it's on a boat or the water), and we're not in cooldown.
    local combat = inst.components.combat
    return combat.target ~= nil and not combat.target:IsOnValidGround()
end

local SEE_ITEM_DISTANCE = 15
local NOT_TOSSABLE_TAGS = {"INLIMBO", "outofreach", "FX", "fishmeat"} -- NOTE: The gnarwail doesn't want to toss fish meat; it would rather eat it. But fish need to be tossed to become meat.
local ONE_OF_TOSSABLE_TAGS = {"oceanfish", "_inventoryitem"}
local function GetNearbyTossTarget(inst)
    if inst.ready_to_toss then
        return FindEntity(inst, SEE_ITEM_DISTANCE,
            function(item)
                return inst:WantsToToss(item) and not item:IsOnPassablePoint()
            end,
            nil,
            NOT_TOSSABLE_TAGS,
            ONE_OF_TOSSABLE_TAGS
        )
    end
end

local function TryToTossNearestItem(inst)
    local nearest_item = GetNearbyTossTarget(inst)
    if nearest_item == nil then
        return
    end

    local toss_data = {target = nearest_item}

    -- The gnarwail is greedy about fish, because fish is its favourite food.
    local leader = inst.components.follower:GetLeader()
    if leader and not nearest_item:HasTag("oceanfish") then
        toss_data.toss_target = leader
    end

    inst.sg:GoToState("toss_pre", toss_data)
end

local UP_VECTOR = Vector3(0, 1, 0)
local ZERO_VECTOR = Vector3(0, 0, 0)
local function GetLeaderFollowPosition(inst)
    local leader = inst.components.follower:GetLeader()
    if not leader then
        return nil
    end

    local leader_platform = leader:GetCurrentPlatform()
    if not leader_platform then
        local lx, ly, lz = leader.Transform:GetWorldPosition()
        local leader_position = Vector3(lx, ly, lz)
        if TheWorld.Map:IsOceanAtPoint(lx, ly, lz) then
            local offet_distance = leader:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0) + 0.1
            local offset_direction = (inst:GetPosition() - leader_position):GetNormalized()
            return leader_position + (offset_direction * offet_distance)
        else
            local swim_offset = FindSwimmableOffset(leader_position, 0, BOAT_TARGET_DISTANCE)
            if swim_offset then
                return leader_position + swim_offset
            else
                return inst:GetPosition()
            end
        end
    end

    -- From here on, our leader has a platform!
    local platform_velocity = Vector3(leader_platform.components.boatphysics.velocity_x or 0, 0, leader_platform.components.boatphysics.velocity_z or 0)
    local platform_speed_sq = platform_velocity:LengthSq()
    if platform_speed_sq > 1 then
        local offset = inst:GetFormationOffsetNormal(leader, leader_platform, platform_velocity)

        return inst:GetPosition() + offset
    else
        local myx, myy, myz = inst.Transform:GetWorldPosition()
        local px, py, pz = leader_platform.Transform:GetWorldPosition()
        local direction_to_inst = Vector3(myx - px, myy - py, myz - pz):Normalize()

        return leader_platform:GetPosition() + (direction_to_inst * BOAT_TARGET_DISTANCE)
    end
end

local function GetLeaderFollowDistance(inst)
    local leader = inst.components.follower:GetLeader()
    if not leader then
        return MAX_BOAT_FOLLOW_DIST
    end

    local leader_platform = leader:GetCurrentPlatform()
    if not leader_platform then
        return MAX_BOAT_FOLLOW_DIST
    end

    local platform_speed_sq = (leader_platform.components.boatphysics.velocity_x or 0)^2 + (leader_platform.components.boatphysics.velocity_z or 0)^2
    if platform_speed_sq > TUNING.GNARWAIL.WALK_SPEED^2 then
        return 0.5
    else
        return MAX_BOAT_FOLLOW_DIST
    end
end

local GNARWAIL_WALK_SQ = TUNING.GNARWAIL.WALK_SPEED * TUNING.GNARWAIL.WALK_SPEED
local function ShouldLeashRun(inst)
    local leader = inst.components.follower:GetLeader()
    local leader_platform = leader:GetCurrentPlatform()
    if not leader_platform then
        return false
    end

    local pvx = leader_platform.components.boatphysics.velocity_x or 0
    local pvz = leader_platform.components.boatphysics.velocity_z or 0
    return ((pvx * pvx) + (pvz * pvz)) >= GNARWAIL_WALK_SQ
end

local function GetTrader(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DISTANCE, true)
    for _, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then
            return v
        end
    end
    return nil
end

local FINDFOOD_CANT_TAGS = {"outofreach"}

local function FindFoodAction(inst)
    -- Don't go looking for random ocean food if we're busy.
    if inst.sg:HasStateTag("busy") then
        return
    end

    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    if time_since_eat ~= nil and time_since_eat < TUNING.GNARWAIL.EAT_DELAY then
        return
    end

    local target = FindEntity(inst, SEE_ITEM_DISTANCE,
        function(item)
            return item:GetTimeAlive() >= 3 and
                    inst.components.eater:CanEat(item) and
                    not item:IsOnPassablePoint()
        end,
        nil,
        FINDFOOD_CANT_TAGS
    )
    if target ~= nil then
        local bact = BufferedAction(inst, target, ACTIONS.EAT)
        bact.validfn = function() return target.components.inventoryitem == nil or (target.components.inventoryitem.is_landed and not target.components.inventoryitem:IsHeld()) end
        return bact
    end
end

local BOAT_TAGS = {"walkableplatform"}
local WANDER_DISTANCE = 8
local BOAT_CLOSE_ENOUGH_TO_WANDER_AWAY_DISTANCE = WANDER_DISTANCE + TUNING.MAX_WALKABLE_PLATFORM_RADIUS
local function GetWanderDirection(inst)
    local closest_boat = FindEntity(inst, BOAT_CLOSE_ENOUGH_TO_WANDER_AWAY_DISTANCE, nil, BOAT_TAGS)
    if closest_boat == nil then
        return nil
    end

    local cbx, cby, cbz = closest_boat.Transform:GetWorldPosition()
    local approximate_opposite_angle = (inst:GetAngleToPoint(cbx, cby, cbz) + math.random(110, 250)) % 360
    return approximate_opposite_angle * DEGREES
end

local GnarwailBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMES = {randwaittime = 2}
local WANDER_DATA = {wander_dist = WANDER_DISTANCE}
function GnarwailBrain:OnStart()
    local is_valid_turf_at_point = function(position)
        local tile_at_position = TheWorld.Map:GetTileAtPoint(position:Get())
        if tile_at_position == GROUND.OCEAN_ROUGH or tile_at_position == GROUND.OCEAN_SWELL then
            return true
        else
            local tile_at_gnarwail = TheWorld.Map:GetTileAtPoint(self.inst.Transform:GetWorldPosition())
            if tile_at_gnarwail ~= GROUND.OCEAN_ROUGH and tile_at_gnarwail ~= GROUND.OCEAN_SWELL then
                return (tile_at_position >= GROUND.OCEAN_START and tile_at_position <= GROUND.OCEAN_END) and
                    (tile_at_position ~= GROUND.IMPASSABLE and tile_at_position ~= GROUND.INVALID)
            end
        end
        return false
    end

    local get_runaway_target = function()
        if self.inst.components.combat.target and not self.inst.components.combat.target:HasTag("smallcreature") then
            return self.inst.components.combat.target
        else
            return nil
        end
    end

    local root = PriorityNode(
    {
        WhileNode( function() return self.inst:HornIsBroken() and
                    (self.inst.components.combat.target and
                    self.inst.components.combat.target:GetDistanceSqToInst(self.inst) < (MIN_BOAT_FOLLOW_DIST * MIN_BOAT_FOLLOW_DIST) and
                    not self.inst.components.combat.target:IsOnOcean(false))
                end,
            "HornBrokenPanicAndAvoid",
            PanicAndAvoid(self.inst, function(i) return i.components.combat.target end, MIN_BOAT_FOLLOW_DIST)
        ),
        WhileNode( function() return HasValidWaterTarget(self.inst) end,
            "AttackMomentarily",
            PriorityNode({
                WhileNode( function()
                        return self.inst.components.combat.target:GetCurrentPlatform() ~= nil or
                                not self.inst.components.combat:InCooldown()
                    end,
                    "AttackIfNotInCooldown",
                    ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_BOAT_FOLLOW_DIST), 2)
                ),
                RunAway(self.inst, get_runaway_target, 4, 6, nil, nil, nil, true),
            }, 0.30)
        ),
        Leash(self.inst, GetLeaderFollowPosition, GetLeaderFollowDistance, 0.5, ShouldLeashRun),
        WhileNode( function() return GetTrader(self.inst) ~= nil end,
            "MoveTowardsTrader",
            Follow(self.inst, GetTrader, 0, 2, TUNING.MAX_WALKABLE_PLATFORM_RADIUS, false)
        ),
        WhileNode( function() return GetTrader(self.inst) == nil and not self.inst.sg:HasStateTag("busy") end,
            "ActionsWhenNotEating",
            PriorityNode({
                RunAway(self.inst, {tags=BOAT_TAGS}, MIN_BOAT_FOLLOW_DIST, BOAT_TARGET_DISTANCE, nil, nil, nil, true),
                IfNode( function() return not self.inst.components.combat:HasTarget() end,
                    "FindFoodIfNotInCombat",
                    DoAction(self.inst, FindFoodAction)
                ),
                IfNode( function() return not self.inst:HornIsBroken() and
                        (not self.inst.components.combat:HasTarget() or self.inst.components.follower:GetLeader() ~= nil) and
                        GetNearbyTossTarget(self.inst) ~= nil end,
                    "ShouldToss",
                    ActionNode( function() TryToTossNearestItem(self.inst) end )
                ),
                Wander(self.inst, nil, nil, WANDER_TIMES, GetWanderDirection, nil, is_valid_turf_at_point, WANDER_DATA),
            }, 0.30)
        ),
    }, 0.30)

    self.bt = BT(self.inst, root)
end

return GnarwailBrain
