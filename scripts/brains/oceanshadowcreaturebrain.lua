require "behaviours/wander"
require "behaviours/standstill"
require "behaviours/standandattack"

local TELEPORT_FREQUENCY = 3

local HARASS_MIN = 0
local HARASS_MED = 4
local HARASS_MAX = 5

local OceanShadowCreatureBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.mytarget = nil
end)

function OceanShadowCreatureBrain:SetTarget(target)
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

function OceanShadowCreatureBrain:OnStop()
    self:SetTarget(nil)
end

local function ShouldAttack(self)
    local target = self.inst.components.combat.target

    if target == nil or self.inst.components.shadowsubmissive:ShouldSubmitToTarget(target) then
        self._harasstarget = target
        return false
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local range = self.inst.components.combat.attackrange
    if VecUtil_LengthSq(x - tx, tz - tz) > range * range then
        return false
    end

    self._harasstarget = nil

    return true
end

local function ShouldHarass(self)
    return self._harasstarget ~= nil
        and self._harasstarget:IsValid()
        and (self.inst.components.combat.nextbattlecrytime == nil or
            self.inst.components.combat.nextbattlecrytime < GetTime())
end

local function GetHarassWanderDir(self)
    return (self._harasstarget:GetAngleToPoint(self.inst.Transform:GetWorldPosition()) - 60 + math.random() * 120) * DEGREES
end

local function targetonland(inst)
    if inst.components.combat.target then
        local target = inst.components.combat.target
        local x,y,z = target.Transform:GetWorldPosition()
        if TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
           return true
        end
    end
end

local function teleport(inst)
     inst:PushEvent("teleport_to_land")
end

function OceanShadowCreatureBrain:OnStart()
    -- The brain is restarted when we wake up. The player may be gone by then
    self:SetTarget(self.inst.spawnedforplayer)

    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("teleporting") end, "TeleportBlock",
            PriorityNode({
            IfNode(function() return targetonland(self.inst) end, "target on land",
                DoAction(self.inst, teleport)),

            WhileNode(function()
                    return self.inst.entity:GetParent() ~= nil end, "OnBoat",
                    PriorityNode({
                        WhileNode(function() return ShouldHarass(self) end, "Harass",
                            ActionNode(function()
                                self.inst.components.combat:BattleCry()
                                if self.inst.sg.currentstate.name == "taunt" then
                                    self.inst:ForceFacePoint(self._harasstarget.Transform:GetWorldPosition())
                                end
                            end)),
                        WhileNode(function() return ShouldAttack(self) end, nil, StandAndAttack(self.inst)),
                        WhileNode(function() return GetTime() - self.inst._should_teleport_time >= TELEPORT_FREQUENCY end, "Teleport",
                            ActionNode(function()
                                self.inst._should_teleport_time = GetTime()
                                self.inst:PushEvent("boatteleport")
                            end)),
                        StandStill(self.inst),
                    }, .25)
                ),

            Wander(self.inst, function()
                if self.mytarget ~= nil then
                    return self.mytarget:GetCurrentPlatform() ~= nil and self.mytarget:GetPosition() or nil
                else
                    return nil
                end
            end, 0),
            }, .25)),
    }, .25)

    self.bt = BT(self.inst, root)
end

return OceanShadowCreatureBrain
