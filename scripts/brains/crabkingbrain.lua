require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "giantutils"

local function ShouldHaveClaws(inst)
    if not inst:HasTag("icewall") and not inst.arms and not inst.components.timer:TimerExists("taunt") and not inst.sg:HasStateTag("casting") then
        inst.wantstosummonclaws = true
    end
    return nil
end

local function ShouldHeal(inst)
    if inst.components.health:GetPercent() < 1 and inst:HasTag("icewall") and not inst.components.timer:TimerExists("taunt") then
        inst.wantstoheal = true
    else
        inst.wantstoheal = nil
    end
    return nil
end

local function ShouldTaunt(inst)
    if inst.components.timer:TimerExists("taunt") then
        inst.wantstotaunt = true
    else
        inst.wantstotaunt = nil
    end
    return nil
end

local BOAT_TAG = {"boat"}
local TARGET_ONEOF_TAGS = {"character","animal","monster","smallcreature"}

local function ShouldFreeze(inst)

    if not inst:HasTag("icewall") and inst.damagetotal and inst.damagetotal <= -TUNING.CRABKING_FREEZE_THRESHOLD and inst.components.health:GetPercent() <= TUNING.CRABKING_STAGE1_THRESHOLD  then
        local x,y,z = inst.Transform:GetWorldPosition()
        local boatents = TheSim:FindEntities(x,y,z, 25, BOAT_TAG)

        for i, ent in ipairs(boatents) do
            if ent.prefab == "boat_ice" then
                return nil
            end
        end
        local range = 20
        local ents = TheSim:FindEntities(x,y,z, range, nil,nil, TARGET_ONEOF_TAGS)
        if #ents > 0 then
            for i=#ents,1,-1 do
                local ent = ents[i]
                if (not ent:HasTag("character") and (not ent.components.combat or ent.components.combat.target ~= inst) ) then
                    table.remove(ents,i)
                end
            end
        end
        if #boatents > 0 or #ents > 0 then
            inst.wantstofreeze = true
        end
    end
    return nil
end

local function ShouldCannon(inst)
    if not inst.components.timer:TimerExists("cannon_timer") and not inst:HasTag("icewall") then
        local x,y,z = inst.Transform:GetWorldPosition()
        local boatents = TheSim:FindEntities(x,y,z, 25, BOAT_TAG)
        local range = 20
        local ents = TheSim:FindEntities(x,y,z, range, nil,nil, TARGET_ONEOF_TAGS)
        if #ents > 0 then
            for i=#ents,1,-1 do
                local ent = ents[i]
                if (not ent:HasTag("character") and (not ent.components.combat or ent.components.combat.target ~= inst) ) or not ent.components.freezable or ent.components.freezable:IsFrozen() then
                    table.remove(ents,i)
                end
            end
        end
        if #boatents > 0 or #ents > 0 then
            inst.wantstocannon = true
        end
    end
    return nil
end

local CrabkingBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CrabkingBrain:OnStart()
    local root = PriorityNode(
    {
        IfNode(function() return not self.inst.sg:HasStateTag("inert") and not self.inst.sg:HasStateTag("casting")  and not self.inst.sg:HasStateTag("fixing") and not self.inst.sg:HasStateTag("spawning") end, "doing",
            PriorityNode({

                DoAction(self.inst, ShouldHeal, "heal"),                
                DoAction(self.inst, ShouldFreeze, "freeze"),
                DoAction(self.inst, ShouldHaveClaws, "claws?"),

            }, 1)),
    }, 1)

    self.bt = BT(self.inst, root)
end

function CrabkingBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return CrabkingBrain

