local SpDamageUtil = require("components/spdamageutil")

--Update inventoryitem_replica constructor if any more properties are added

local function onspeedmult(self, speedmult)
    if self.inst.replica.inventoryitem ~= nil then
        --This network optimization hack is shared by equippable component,
        --so a prefab must not have both components at the same time.
        self.inst.replica.inventoryitem:SetWalkSpeedMult(speedmult)
    end
end

local Saddler = Class(function(self, inst)
    self.inst = inst
    self.swapsymbol = nil
    self.swapbuild = nil

    self.bonusdamage = nil
    self.speedmult = nil
    self.absorbpercent = nil
end,
nil,
{
    speedmult = onspeedmult,
})

function Saddler:SetSwaps(build, symbol, skin_guid)
    self.swapbuild = build
    self.swapsymbol = symbol
    self.skin_guid = skin_guid
end

function Saddler:SetBonusDamage(damage)
    self.bonusdamage = damage
end

function Saddler:SetBonusSpeedMult(mult)
    self.speedmult = mult
end

function Saddler:SetAbsorption(percent)
    self.absorbpercent = percent
end

function Saddler:GetBonusDamage(target)
    return self.bonusdamage or 0
end

function Saddler:GetBonusSpeedMult()
    return self.speedmult or 1
end

function Saddler:GetAbsorption()
    return self.absorbpercent or 0
end

function Saddler:SetDiscardedCallback(cb)
    self.discardedcb = cb
end

function Saddler:ApplyDamage(damage, attacker, weapon, spdamage)
    local damagetypemult = 1
    local absorbed_damage = 0

    absorbed_damage = damage * self:GetAbsorption()

    if self.inst.components.damagetyperesist ~= nil then
        damagetypemult = damagetypemult * self.inst.components.damagetyperesist:GetResist(attacker, weapon)
    end

    damage = damage * damagetypemult

    local leftover_damage = damage - absorbed_damage

    -- Apply special damage.
    if spdamage ~= nil then
        for sptype, dmg in pairs(spdamage) do
            dmg = dmg * damagetypemult

            local defended = SpDamageUtil.GetSpDefenseForType(self.inst, sptype)

            dmg = dmg - defended

            spdamage[sptype] = dmg > 0 and dmg or nil
        end

        if next(spdamage) == nil then
            spdamage = nil
        end
    end

    return leftover_damage, spdamage
end

return Saddler
