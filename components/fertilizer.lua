local function onplanthealth(self, planthealth)
    if planthealth ~= nil then
        self.inst:AddTag("heal_fertilize")
    else
        self.inst:RemoveTag("heal_fertilize")
    end
end

local Fertilizer = Class(function(self, inst)
    self.inst = inst
    self.fertilizervalue = 1
    self.soil_cycles = 1
    self.withered_cycles = 1
    self.fertilize_sound = "dontstarve/common/fertilize"

    --For healing plant characters (e.g. Wormwood)
    --self.planthealth = nil
end,
nil,
{
    planthealth = onplanthealth,
})

function Fertilizer:OnRemoveFromEntity()
    self.inst:RemoveTag("heal_fertilize")
end

function Fertilizer:SetHealingAmount(health)
    self.planthealth = health
end

function Fertilizer:Heal(target)
    if self.planthealth ~= nil and target.components.health ~= nil and target.components.health.canheal and target:HasTag("healonfertilize") then
        if self.inst.components.finiteuses ~= nil then
            local cost = 2
            target.components.health:DoDelta(math.min(self.planthealth, self.planthealth * self.inst.components.finiteuses:GetUses() / cost), false, self.inst.prefab)
            self.inst.components.finiteuses:Use(cost)
        else
            target.components.health:DoDelta(self.planthealth, false, self.inst.prefab)
            if self.inst.components.stackable ~= nil and self.inst.components.stackable:IsStack() then
                self.inst.components.stackable:Get():Remove()
            else
                self.inst:Remove()
            end
        end
        return true
    end
end

return Fertilizer
