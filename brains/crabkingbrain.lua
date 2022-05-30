require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "giantutils"

local function ShouldHaveClaws(inst)
    if inst.components.health:GetPercent() < TUNING.CRABKING_CLAW_THRESHOLD and not inst.arms then
        inst.wantstosummonclaws = true
    end
    return nil
end

local function ShouldHeal(inst)
    if inst.components.health:GetPercent() < TUNING.CRABKING_HEAL_THRESHOLD and not inst.components.timer:TimerExists("heal_cooldown") then
        inst.components.timer:StopTimer("clawsummon_cooldown")
        inst.wantstoheal = true
    end
    return nil
end

local BOAT_TAG = {"boat"}
local TARGET_ONEOF_TAGS = {"character","animal","monster","smallcreature"}
local function ShouldDoAttackSpell(inst)
    if not inst.components.timer:TimerExists("spell_cooldown") then
        local x,y,z = inst.Transform:GetWorldPosition()
        local boatents = TheSim:FindEntities(x,y,z, 25, BOAT_TAG)
        local range = inst.getfreezerange(inst)
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
            if #ents > 0 and #boatents < 1 then
                inst.dofreezecast = true
            end
            inst.wantstocast = true
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
        WhileNode(function() return not self.inst.sg:HasStateTag("inert") and not self.inst.sg:HasStateTag("casting")  and not self.inst.sg:HasStateTag("fixing") and not self.inst.sg:HasStateTag("spawning") end, "doing",
            PriorityNode({

                DoAction(self.inst, ShouldHaveClaws, "claws?"),
                DoAction(self.inst, ShouldHeal, "Heal?"),
                DoAction(self.inst, ShouldDoAttackSpell, "casting"),

            }, 1)),
    }, 1)

    self.bt = BT(self.inst, root)
end

function CrabkingBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return CrabkingBrain

