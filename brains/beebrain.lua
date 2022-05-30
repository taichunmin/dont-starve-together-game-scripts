require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/findflower"
require "behaviours/panic"
local beecommon = require "brains/beecommon"

local MAX_CHASE_DIST = 15
local MAX_CHASE_TIME = 8

local RUN_AWAY_DIST = 6
local STOP_RUN_AWAY_DIST = 10

local MAX_WANDER_DIST_BEE_BEACON = 6

local BeeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.lastbeebeacon = nil
    self.beebeacontime = GetTime() + math.random()
end)

local function IsHomeOnFire(inst)
    return inst.components.homeseeker
        and inst.components.homeseeker.home
        and inst.components.homeseeker.home.components.burnable
        and inst.components.homeseeker.home.components.burnable:IsBurning()
end

local FINDBEEBEACON_MUST_TAGS = { "beebeacon" }
local FINDBEEBEACON_CANT_TAGS = { "INLIMBO" }

local function FindBeeBeacon(self)
    local t = GetTime()
    if t >= self.beebeacontime then
        self.lastbeebeacon = FindEntity(self.inst, 30, nil, FINDBEEBEACON_MUST_TAGS, FINDBEEBEACON_CANT_TAGS)
        self.beebeacontime = t + 2 + math.random()
    elseif self.lastbeebeacon ~= nil
        and not (self.lastbeebeacon:IsValid() and
                self.lastbeebeacon:HasTag("beebeacon") and
                self.inst:IsNear(self.lastbeebeacon, 30)) then
        self.lastbeebeacon = nil
    end
    return self.lastbeebeacon
end

local function GetBeeBeaconPos(self)
    local target = FindBeeBeacon(self)
    return target ~= nil and target:GetPosition() or nil
end

function BeeBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily", ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST)) ),
        WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge", RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),

        --ChaseAndAttack(self.inst, beecommon.MAX_CHASE_TIME),
        WhileNode( function() return IsHomeOnFire(self.inst) end, "HomeOnFire", Panic(self.inst)),
        IfNode(function() return not TheWorld.state.iscaveday or not self.inst:IsInLight() end, "IsNight",
            DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),
        IfNode(function() return self.inst.components.pollinator:HasCollectedEnough() end, "IsFullOfPollen",
            DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),
        IfNode(function() return TheWorld.state.iswinter end, "IsWinter",
            DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),

        IfNode(function() return FindBeeBeacon(self) ~= nil end, "bee beacon",
            Wander(self.inst, function() return GetBeeBeaconPos(self) end, MAX_WANDER_DIST_BEE_BEACON)),

        FindFlower(self.inst),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, beecommon.MAX_WANDER_DIST)
    }, 1)

    self.bt = BT(self.inst, root)
end

function BeeBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition())
end

return BeeBrain
