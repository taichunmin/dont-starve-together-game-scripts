require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/doaction"
require "behaviours/minperiod"
require "behaviours/panic"
require "behaviours/runaway"

local SEE_DIST = 30
local TOOCLOSE = 6

local function CanSteal(item)
    return item.components.inventoryitem ~= nil
        and item.components.inventoryitem.canbepickedup
        and item:IsOnValidGround()      -- NOTE: If Krampus learns to hop on boats or travel over water, this should change to include water.
        and not item:IsNearPlayer(TOOCLOSE)
end

local STEAL_MUST_TAGS = { "_inventoryitem" }
local STEAL_CANT_TAGS = { "INLIMBO", "catchable", "fire", "irreplaceable", "heavy", "prey", "bird", "outofreach", "_container" }

local function StealAction(inst)
    if not inst.components.inventory:IsFull() then
        local target = FindEntity(inst, SEE_DIST,
            CanSteal,
            STEAL_MUST_TAGS, --see entityreplica.lua
            STEAL_CANT_TAGS)
        return target ~= nil
            and BufferedAction(inst, target, ACTIONS.PICKUP)
            or nil
    end
end

local function CanHammer(item)
    return item.prefab == "treasurechest"
        and item.components.container ~= nil
        and not item.components.container:IsEmpty()
        and not item:IsNearPlayer(TOOCLOSE)
        and item:IsOnValidGround()      -- NOTE: If Krampus learns to hop on boats or travel over water, this should change to include water.
end

local EMPTYCHEST_MUST_TAGS = { "structure", "_container", "HAMMER_workable" }
local function EmptyChest(inst)
    if not inst.components.inventory:IsFull() then
        local target = FindEntity(inst, SEE_DIST, CanHammer, EMPTYCHEST_MUST_TAGS)
        return target ~= nil
            and BufferedAction(inst, target, ACTIONS.HAMMER)
            or nil
    end
end

local MIN_FOLLOW = 10
local MAX_FOLLOW = 20
local MED_FOLLOW = 15

local MIN_RUNAWAY = 8
local MAX_RUNAWAY = MED_FOLLOW

local KrampusBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.mytarget = nil
    self.greed = 2 + math.random(4)
end)

function KrampusBrain:SetTarget(target)
    if target ~= nil then
        if not target:IsValid() then
            target = nil
        elseif self.listenerfunc == nil then
            self.listenerfunc = function() self.mytarget = nil end
        end
    end
    if target ~= self.mytarget then
        if self.mytarget ~= nil then
            self.inst:RemoveEventCallback("onremove", self.listenerfunc, self.mytarget)
        end
        if target ~= nil then
            self.inst:ListenForEvent("onremove", self.listenerfunc, target)
        end
        self.mytarget = target
    end
end

function KrampusBrain:OnStop()
    self:SetTarget(nil)
end

function KrampusBrain:OnStart()
    self:SetTarget(self.inst.spawnedforplayer)

    local stealnode = PriorityNode(
    {
        DoAction(self.inst, function() return StealAction(self.inst) end, "steal", true ),
        DoAction(self.inst, function() return EmptyChest(self.inst) end, "emptychest", true )
    }, 2)

    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic or self.inst.components.health.takingfiredamage end, "Panic", Panic(self.inst)),
        ChaseAndAttack(self.inst, 100),
        IfNode( function() return self.inst.components.inventory:NumItems() >= self.greed and not self.inst.sg:HasStateTag("busy") end, "donestealing",
            ActionNode(function() self.inst.sg:GoToState("exit") return SUCCESS end, "leave" )),
        MinPeriod(self.inst, 10, true,
            stealnode),

        RunAway(self.inst, "player", MIN_RUNAWAY, MAX_RUNAWAY),
        Follow(self.inst, function() return self.mytarget end, MIN_FOLLOW, MED_FOLLOW, MAX_FOLLOW),
        Wander(self.inst, function() local player = self.mytarget if player then return Vector3(player.Transform:GetWorldPosition()) end end, 20)
    }, 2)

    self.bt = BT(self.inst, root)
end

return KrampusBrain
