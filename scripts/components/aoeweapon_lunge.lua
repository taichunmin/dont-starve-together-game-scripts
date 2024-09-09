local AOEWeapon_Base = require("components/aoeweapon_base")

local AOEWeapon_Lunge = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self.siderange = 1
    self.physicspadding = 3

    --self.fxprefab = nil
    --self.fxspacing = nil

    --self.onprelungefn = nil
    --self.onlungedfn = nil

    --self.sound = nil
    
    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("aoeweapon_lunge")
end)

function AOEWeapon_Lunge:SetSideRange(range)
    self.siderange = range
end

function AOEWeapon_Lunge:SetOnPreLungeFn(fn)
    self.onprelungefn = fn
end

function AOEWeapon_Lunge:SetOnLungedFn(fn)
    self.onlungedfn = fn
end

function AOEWeapon_Lunge:SetTrailFX(prefab, spacing)
    self.fxprefab = prefab
    self.fxspacing = spacing
end

function AOEWeapon_Lunge:SetSound(path)
    self.sound = path
end

local TOSS_MUSTTAGS = { "_inventoryitem" }
local TOSS_CANTTAGS = { "locomotor", "INLIMBO" }
function AOEWeapon_Lunge:DoLunge(doer, startingpos, targetpos)
    if not startingpos or not targetpos or not doer or not doer.components.combat then
        return false
    end

    if self.onprelungefn ~= nil then
        self.onprelungefn(self.inst, doer, startingpos, targetpos)
    end

    -- Hitting -----------------------------------------------------------------
    local doer_combat = doer.components.combat
    doer_combat:EnableAreaDamage(false)

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

    local p1 = { x = startingpos.x, y = startingpos.z }
    local p2 = { x = targetpos.x, y = targetpos.z }
    local dx, dy = p2.x - p1.x, p2.y - p1.y
    local dist = dx * dx + dy * dy
    local toskip = {}
    local pv = {}
    local r, cx, cy
    if dist > 0 then
        dist = math.sqrt(dist)
        r = (dist + doer_combat.hitrange * 0.5 + self.physicspadding) * 0.5
        dx, dy = dx / dist, dy / dist
        cx, cy = p1.x + dx * r, p1.y + dy * r

        doer_combat.ignorehitrange = true

        local c_hit_targets = TheSim:FindEntities(cx, 0, cy, r, nil, self.notags, self.combinedtags)
        for _, hit_target in ipairs(c_hit_targets) do
            toskip[hit_target] = true
            if hit_target ~= doer and hit_target:IsValid() and not hit_target:IsInLimbo()
                    and not (hit_target.components.health and hit_target.components.health:IsDead()) then
                pv.x, pv._, pv.y = hit_target.Transform:GetWorldPosition()
                local vrange = self.siderange + hit_target:GetPhysicsRadius(0.5)
                if DistPointToSegmentXYSq(pv, p1, p2) < vrange * vrange then
                    self:OnHit(doer, hit_target)
                end
            end
        end

        doer_combat.ignorehitrange = false
    end

    local angle = (doer.Transform:GetRotation() + 90) * DEGREES
    local p3 = { x = p2.x + doer_combat.hitrange * math.sin(angle), y = p2.y + doer_combat.hitrange * math.cos(angle) }
    local p2_hit_targets = TheSim:FindEntities(p2.x, 0, p2.y, doer_combat.hitrange + self.physicspadding, nil, self.notags, self.combinedtags)
    for _, hit_target in ipairs(p2_hit_targets) do
        if not toskip[hit_target] and hit_target:IsValid() and not hit_target:IsInLimbo()
                and not (hit_target.components.health and hit_target.components.health:IsDead()) then
            pv.x, pv._, pv.y = hit_target.Transform:GetWorldPosition()
            local vradius = hit_target:GetPhysicsRadius(0.5)
            local vrange = doer_combat.hitrange + vradius
            if distsq(pv.x, pv.y, p2.x, p2.y) < vrange * vrange then
                vrange = self.siderange + vradius
                if DistPointToSegmentXYSq(pv, p2, p3) < vrange * vrange then
                    self:OnHit(doer, hit_target)
                end
            end
        end
    end

    doer_combat:EnableAreaDamage(true)
    if weapon then
        if attackwear ~= 0 then
            weapon.attackwear = attackwear
        end
        if damage ~= self.damage then
            weapon:SetDamage(damage)
        end
    end

    -- Tossing -----------------------------------------------------------------
    toskip = {}
    local srcpos = Vector3()
    if dist > 0 then
        local c_toss_targets = TheSim:FindEntities(cx, 0, cy, r, TOSS_MUSTTAGS, TOSS_CANTTAGS)
        for _, toss_target in ipairs(c_toss_targets) do
            toskip[toss_target] = true
            pv.x, pv._, pv.y = toss_target.Transform:GetWorldPosition()
            local lensq = DistPointToSegmentXYSq(pv, p1, p2)

            local vrangesq = self.siderange + toss_target:GetPhysicsRadius(0.5)
            vrangesq = vrangesq * vrangesq

            if lensq < vrangesq and pv._ < 0.2 then
                local dxv, dyv = pv.x - p1.x, pv.y - p1.y

                local proj = math.sqrt(dxv * dxv + dyv * dyv - lensq)
                srcpos.x = p1.x + dx * proj
                srcpos.z = p1.y + dy * proj
                if lensq <= 0 then
                    proj = (math.random(2) - 1.5) * .1
                    srcpos.x = srcpos.x + dy * proj
                    srcpos.z = srcpos.z + dx * proj
                end

                self:OnToss(doer, toss_target, srcpos, 1 - lensq / vrangesq, math.sqrt(lensq))
            end
        end
    end

    local p2_toss_targets = TheSim:FindEntities(p2.x, 0, p2.y, doer_combat.hitrange + self.physicspadding, TOSS_MUSTTAGS, TOSS_CANTTAGS)
    for _, toss_target in ipairs(p2_toss_targets) do
        if not toskip[toss_target] then
            pv.x, pv._, pv.y = toss_target.Transform:GetWorldPosition()
            local lensq = distsq(pv.x, pv.y, p2.x, p2.y)

            local vradius = toss_target:GetPhysicsRadius(0)
            local vrangesq = doer_combat.hitrange + vradius
            if lensq < vrangesq * vrangesq and pv._ < 0.2 then
                vrangesq = self.siderange + vradius
                vrangesq = vrangesq * vrangesq
                if DistPointToSegmentXYSq(pv, p2, p3) < vrangesq then
                    local dxv, dyv = pv.x - p2.x, pv.y - p2.y
                    local proj = math.sqrt(dxv * dxv + dyv * dyv - lensq)
                    srcpos.x = p1.x + dx * proj
                    srcpos.z = p1.y + dy * proj
                    if lensq <= 0 then
                        proj = (math.random(2) - 1.5) * 0.1
                        srcpos.x = srcpos.x + dy * proj
                        srcpos.z = srcpos.z + dx * proj
                    end
                    self:OnToss(doer, toss_target, srcpos, 1.5 - lensq / vrangesq, math.sqrt(lensq))
                end
            end
        end
    end

    -- FX trail ----------------------------------------------------------------
    if self.fxprefab and (self.fxspacing or 0) > 0 then
        if dist <= 0 then
            local fx = SpawnPrefab(self.fxprefab)
            fx.Transform:SetPosition(p2.x, 0, p2.y)
        else
            dist = math.floor(dist / self.fxspacing)
            dx = dx * self.fxspacing
            dy = dy * self.fxspacing

            local flip = math.random() < 0.5
            for i = 0, dist do
                if i == 0 then
                    p2.x = p2.x - dx * 0.25
                    p2.y = p2.y - dy * 0.25
                elseif i == 1 then
                    p2.x = p2.x - dx * 0.75
                    p2.y = p2.y - dy * 0.75
                else
                    p2.x = p2.x - dx
                    p2.y = p2.y - dy
                end

                local fx = SpawnPrefab(self.fxprefab)
                fx.Transform:SetPosition(p2.x, 0, p2.y)
                local k = (dist > 0 and math.max(0, 1 - i / dist)) or 0
                k = 1 - k * k
                if fx.FastForward then
                    fx:FastForward(0.4 * k)
                end
                if fx.SetMotion then
                    k = 1 + k * 2
                    fx:SetMotion(k * dx, 0, k * dy)
                end
                if flip then
                    fx.AnimState:SetScale(-1, 1)
                end
                flip = not flip
            end
        end
    end

    if self.onlungedfn ~= nil then
        self.onlungedfn(self.inst, doer, startingpos, targetpos)
    end

    return true
end

return AOEWeapon_Lunge
