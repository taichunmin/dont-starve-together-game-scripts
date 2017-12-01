local DOZE_OFF_TIME = 2

local function oncatchable(self)
    if self.cancatch and self.target ~= nil then
        self.inst:AddTag("catchable")
    else
        self.inst:RemoveTag("catchable")
    end
end

local Projectile = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.target = nil
    self.start = nil
    self.dest = nil
    self.cancatch = false

    self.speed = nil
    self.hitdist = 1
    self.homing = true
    self.range = nil
    self.onthrown = nil
    self.onhit = nil
    self.onmiss = nil
    self.oncaught = nil

    self.stimuli = nil

    --self.delaytask = nil

    --NOTE: projectile and complexprojectile components are mutually
    --      exclusive because they share this tag!
    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("projectile")
end,
nil,
{
    cancatch = oncatchable,
    target = oncatchable,
})

function Projectile:OnRemoveFromEntity()
    self.inst:RemoveTag("projectile")
    self.inst:RemoveTag("catchable")
    if self.dozeOffTask ~= nil then
        self.dozeOffTask:Cancel()
        self.dozeOffTask = nil
    end
    if self.delaytask ~= nil then
        self.delaytask:Cancel()
        self.delaytask = nil
    end
end

function Projectile:GetDebugString()
    return string.format("target: %s, owner %s", tostring(self.target), tostring(self.owner))
end

function Projectile:SetSpeed(speed)
    self.speed = speed
end

function Projectile:SetStimuli(stimuli)
    self.stimuli = stimuli
end

function Projectile:SetRange(range)
    self.range = range
end

function Projectile:SetHitDist(dist)
    self.hitdist = dist
end

function Projectile:SetOnThrownFn(fn)
    self.onthrown = fn
end

function Projectile:SetOnHitFn(fn)
    self.onhit = fn
end

function Projectile:SetOnCaughtFn(fn)
    self.oncaught = fn
end

function Projectile:SetOnMissFn(fn)
    self.onmiss = fn
end

function Projectile:SetCanCatch(cancatch)
    self.cancatch = cancatch
end

function Projectile:SetHoming(homing)
    self.homing = homing
end

function Projectile:SetLaunchOffset(offset)
    self.launchoffset = offset -- x is radius, y is height, z is ignored
end

function Projectile:IsThrown()
    return self.target ~= nil
end

function Projectile:Throw(owner, target, attacker)
    self.owner = owner
    self.target = target
    self.start = owner:GetPosition()
    self.dest = target:GetPosition()

    if attacker ~= nil and self.launchoffset ~= nil then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local facing_angle = attacker.Transform:GetRotation() * DEGREES
        self.inst.Transform:SetPosition(x + self.launchoffset.x * math.cos(facing_angle), y + self.launchoffset.y, z - self.launchoffset.x * math.sin(facing_angle))
    end

    self:RotateToTarget(self.dest)
    self.inst.Physics:SetMotorVel(self.speed, 0, 0)
    self.inst:StartUpdatingComponent(self)
    self.inst:PushEvent("onthrown", { thrower = owner, target = target })
    target:PushEvent("hostileprojectile", { thrower = owner, attacker = attacker, target = target })
    if self.onthrown ~= nil then
        self.onthrown(self.inst, owner, target, attacker)
    end
    if self.cancatch and target.components.catcher ~= nil then
        target.components.catcher:StartWatching(self.inst)
    end
end

function Projectile:Catch(catcher)
    if self.cancatch then
        self:Stop()
        self.inst.Physics:Stop()
        if self.oncaught ~= nil then
            self.oncaught(self.inst, catcher)
        end
    end
end

function Projectile:Miss(target)
    local attacker = self.owner
    if self.owner.components.combat == nil and self.owner.components.weapon ~= nil and self.owner.components.inventoryitem ~= nil then
        attacker = self.owner.components.inventoryitem.owner
    end
    self:Stop()
    if self.onmiss ~= nil then
        self.onmiss(self.inst, attacker, target)
    end
end

function Projectile:Stop()
    self.inst:StopUpdatingComponent(self)
    self.target = nil
    self.owner = nil
end

function Projectile:Hit(target)
    local attacker = self.owner
    local weapon = self.inst
    self:Stop()
    self.inst.Physics:Stop()
    if attacker.components.combat == nil and attacker.components.weapon ~= nil and attacker.components.inventoryitem ~= nil then
        weapon = attacker
        attacker = weapon.components.inventoryitem.owner
    end
    if attacker ~= nil and attacker.components.combat ~= nil then
        attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
    end
    if self.onhit ~= nil then
        self.onhit(self.inst, attacker, target)
    end
end

local function DozeOff(inst, self)
    self.dozeOffTask = nil
    self:Stop()
end

function Projectile:OnEntitySleep()
    if self.dozeOffTask == nil then
   	    self.dozeOffTask = self.inst:DoTaskInTime(DOZE_OFF_TIME, DozeOff, self)
    end
end

function Projectile:OnEntityWake()
    if self.dozeOffTask ~= nil then
        self.dozeOffTask:Cancel()
        self.dozeOffTask = nil
    end
end

function Projectile:OnUpdate(dt)
    local target = self.target
    if self.homing and target ~= nil and target:IsValid() and not target:IsInLimbo() then
        self.dest = target:GetPosition()
    end
    local current = self.inst:GetPosition()
    if self.range ~= nil and distsq(self.start, current) > self.range * self.range then
        self:Miss(target)
    elseif not self.homing then
        if target ~= nil and target:IsValid() and not target:IsInLimbo() then
            local range = target:GetPhysicsRadius(0) + self.hitdist
            -- V2C: this is 3D distsq (since combat range checks use 3D distsq as well)
            -- NOTE: used < here, whereas combat uses <=, just to give us tiny bit of room for error =)
            if distsq(current, target:GetPosition()) < range * range then
                self:Hit(target)
            end
        end
    elseif target ~= nil
        and target:IsValid()
        and not target:IsInLimbo()
        and target.entity:IsVisible()
        and (target.sg == nil or
            not (target.sg:HasStateTag("flight") or
                target.sg:HasStateTag("invisible"))) then
        local range = target:GetPhysicsRadius(0) + self.hitdist
        -- V2C: this is 3D distsq (since combat range checks use 3D distsq as well)
        -- NOTE: used < here, whereas combat uses <=, just to give us tiny bit of room for error =)
        if distsq(current, target:GetPosition()) < range * range then
            self:Hit(target)
        else
            local direction = (self.dest - current):GetNormalized()
            local projectedSpeed = self.speed * TheSim:GetTickTime() * TheSim:GetTimeScale()
            local projected = current + direction * projectedSpeed
            if direction:Dot(self.dest - projected) >= 0 then
                self:RotateToTarget(self.dest)
            else
                self:Hit(target)
            end
        end
    elseif self.owner == nil or
        not self.owner:IsValid() or
        self.owner.components.combat == nil or
        self.inst.components.weapon == nil or
        self.inst.components.weapon.attackrange == nil then
        -- Lost our target, e.g. bird flew away
        self:Miss(target)
    else
        -- We have enough info to make our weapon fly to max distance before "missing"
        local range = self.owner.components.combat.attackrange + self.inst.components.weapon.attackrange
        if distsq(self.owner:GetPosition(), current) > range * range then
            self:Miss(target)
        end
    end
end

function Projectile:OnSave()
    if self:IsThrown() and
        self.owner ~= nil and self.target ~= nil and
        self.owner:IsValid() and self.target:IsValid() and
        self.owner.persists and self.target.persist and --Pets and such don't save normally, so references would not work on them
        not (self.owner:HasTag("player") or self.target:HasTag("player")) then
        return { target = self.target.GUID, owner = self.owner.GUID }, { self.target.GUID, self.owner.GUID }
    end
end

function Projectile:RotateToTarget(dest)
    local direction = (dest - self.inst:GetPosition()):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0))) / DEGREES
    self.inst.Transform:SetRotation(angle)
    self.inst:FacePoint(dest)
end

function Projectile:LoadPostPass(newents, savedata)
    if savedata.target ~= nil and savedata.owner ~= nil then
        local target = newents[savedata.target]
        local owner = newents[savedata.owner]
        if target ~= nil and owner ~= nil then
            self:Throw(owner.entity, target.entity)
        end
    end
end

local function OnShow(inst, self)
    self.delaytask = nil
    inst:Show()
end

function Projectile:DelayVisibility(duration)
    if self.delaytask ~= nil then
        self.delaytask:Cancel()
    end
    self.inst:Hide()
    self.delaytask = self.inst:DoTaskInTime(duration, OnShow, self)
end

return Projectile
