local SourceModifierList = require("util/sourcemodifierlist")

local function PercentChanged(inst, data)
	if inst.components.armor ~= nil and data.percent ~= nil then
		if inst.components.forgerepairable ~= nil then
			inst.components.forgerepairable:SetRepairable(data.percent < 1)
		end
		if data.percent <= 0 and
			inst.components.inventoryitem ~= nil and
			inst.components.inventoryitem.owner ~= nil then
			inst.components.inventoryitem.owner:PushEvent("armorbroke", { armor = inst })
			--ProfileStatsSet("armor_broke_"..inst.prefab, true)
		end
	end
end

local Armor = Class(function(self, inst)
    self.inst = inst
    self.condition = 100
    self.maxcondition = 100
    self.tags = nil
    self.weakness = nil

    self.conditionlossmultipliers = SourceModifierList(self.inst)

	--self.onfinished = nil
	--self.keeponfinished = nil
    self.inst:ListenForEvent("percentusedchange", PercentChanged)
end)

function Armor:SetOnFinished(fn)
	self.onfinished = fn
end

function Armor:SetKeepOnFinished(keep)
	self.keeponfinished = keep ~= false
end

function Armor:InitCondition(amount, absorb_percent)
    self.condition = amount
    self.absorb_percent = absorb_percent
    self.maxcondition = amount
end

function Armor:InitIndestructible(absorb_percent)
    self.absorb_percent = absorb_percent
    self.indestructible = true
end

function Armor:IsIndestructible()
	return self.indestructible == true
end

function Armor:IsDamaged()
	return self.condition < self.maxcondition
end

function Armor:GetPercent()
    return self.condition / self.maxcondition
end

function Armor:SetTags(tags)
    self.tags = tags
end

function Armor:AddWeakness(tag, bonus_damage)
    if bonus_damage <= 0 then
        self:RemoveWeakness(tag)
    elseif self.weakness == nil then
        self.weakness = { [tag] = bonus_damage }
    else
        self.weakness[tag] = bonus_damage
    end
end

function Armor:RemoveWeakness(tag)
    if self.weakness ~= nil then
        self.weakness[tag] = nil
        if next(self.weakness) == nil then
            self.weakness = nil
        end
    end
end

function Armor:SetAbsorption(absorb_percent)
    self.absorb_percent = absorb_percent
end

function Armor:SetPercent(amount)
    self:SetCondition(self.maxcondition * amount)
end

function Armor:SetCondition(amount)
	if self.indestructible then
		return
	end

    self.condition = math.min(amount, self.maxcondition)
    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })

    if self.condition <= 0 then
        self.condition = 0
        ProfileStatsSet("armor_broke_"..self.inst.prefab, true)
        ProfileStatsSet("armor", self.inst.prefab)

        if self.onfinished ~= nil then
			self.onfinished(self.inst)
        end

		if not self.keeponfinished then
			self.inst:Remove()
		end
    end
end

function Armor:OnSave()
    return self.condition ~= self.maxcondition and { condition = self.condition } or nil
end

function Armor:OnLoad(data)
    if data.condition ~= nil then
        self:SetCondition(data.condition)
    end
end

function Armor:CanResist(attacker, weapon)
    if self.tags == nil then
        return true
    elseif attacker ~= nil then
        for i, v in ipairs(self.tags) do
            if attacker:HasTag(v) or (weapon ~= nil and weapon:HasTag(v)) then
                return true
            end
        end
    end
    return false
end

function Armor:GetAbsorption(attacker, weapon)
    return self:CanResist(attacker, weapon) and self.absorb_percent or nil
end

function Armor:GetBonusDamage(attacker, weapon)
    if self.weakness == nil or attacker == nil then
        return 0
    end
    local damage = 0
    for k, v in pairs(self.weakness) do
        if (attacker:HasTag(k) or (weapon ~= nil and weapon:HasTag(k))) and v > damage then
            damage = v
        end
    end
    return damage
end

function Armor:TakeDamage(damage_amount)
    damage_amount = damage_amount * self.conditionlossmultipliers:Get()

    self:SetCondition(self.condition - damage_amount)
    if self.ontakedamage ~= nil then
        self.ontakedamage(self.inst, damage_amount)
    end
    self.inst:PushEvent("armordamaged", damage_amount)
end

function Armor:Repair(amount)
    self:SetCondition(self.condition + amount)
    if self.onrepair ~= nil then
        self.onrepair(self.inst, amount)
    end
end

function Armor:GetDebugString()
	return self.condition .. "/" .. self.maxcondition
end

return Armor
