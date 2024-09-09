local AOEWeapon_Base = require("components/aoeweapon_base")

local AOEWeapon_Leap = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self.aoeradius = 4
    self.physicspadding = 3

    --self.onpreleapfn = nil
    --self.onleaptfn = nil

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("aoeweapon_leap")
end)

function AOEWeapon_Leap:SetAOERadius(radius)
    self.aoeradius = radius
end

function AOEWeapon_Leap:SetOnPreLeapFn(fn)
    self.onpreleapfn = fn
end

function AOEWeapon_Leap:SetOnLeaptFn(fn)
    self.onleaptfn = fn
end

local TOSS_MUSTTAGS = { "_inventoryitem" }
local TOSS_CANTTAGS = { "locomotor", "INLIMBO" }
function AOEWeapon_Leap:DoLeap(doer, startingpos, targetpos)
    if not startingpos or not targetpos or not doer or not doer.components.combat then
        return false
    end

    if self.onpreleapfn ~= nil then
        self.onpreleapfn(self.inst, doer, startingpos, targetpos)
    end

    doer.components.combat:EnableAreaDamage(false)
    doer.components.combat.ignorehitrange = true

    local weapon = self.inst.components.weapon
    local attackwear, damage = 0, 0
    if weapon then
        attackwear = weapon.attackwear
        damage = weapon.damage
        if attackwear ~= 0 then
            weapon.attackwear = 0
        end
        if damage ~= self.damage then
            weapon:SetDamage(self.damage)
        end
    end

    local leap_targets = TheSim:FindEntities(targetpos.x, 0, targetpos.z, self.aoeradius + self.physicspadding, nil, self.notags, self.combinedtags)
    for _, leap_target in ipairs(leap_targets) do
        if leap_target ~= doer and leap_target:IsValid() and not leap_target:IsInLimbo()
                and not (leap_target.components.health and leap_target.components.health:IsDead()) then
            local targetrange = self.aoeradius + leap_target:GetPhysicsRadius(0.5)
            if leap_target:GetDistanceSqToPoint(targetpos) < targetrange * targetrange then
                self:OnHit(doer, leap_target)
            end
        end
    end

    doer.components.combat:EnableAreaDamage(true)
    doer.components.combat.ignorehitrange = false
    if weapon then
        if attackwear ~= 0 then
            weapon.attackwear = attackwear
        end
        if damage ~= self.damage then
            weapon:SetDamage(damage)
        end
    end

    --Tossing
    local toss_targets = TheSim:FindEntities(targetpos.x, 0, targetpos.z, self.aoeradius + self.physicspadding, TOSS_MUSTTAGS, TOSS_CANTTAGS)
    for _, toss_target in ipairs(toss_targets) do
        local toss_targetrangesq = self.aoeradius + toss_target:GetPhysicsRadius(0.5)
        toss_targetrangesq = toss_targetrangesq * toss_targetrangesq

        local vx, vy, vz = toss_target.Transform:GetWorldPosition()
        local lensq = distsq(vx, vz, targetpos.x, targetpos.z)
        if lensq < toss_targetrangesq and vy < 0.2 then
            self:OnToss(doer, toss_target, nil, 1.5 - lensq / toss_targetrangesq, math.sqrt(lensq))
        end
    end

    if self.onleaptfn then
        self.onleaptfn(self.inst, doer, startingpos, targetpos)
    end
    return true
end

return AOEWeapon_Leap
