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

	--self.has_damage_set = nil -- set to true if the projectile has its own damage set, instead of needed to get it from the launching weapon

    --self.delaytask = nil
    --self.delayowner = nil
    --self.delaypos = nil
    self._ondelaycancel = function() inst:Remove() end

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

local function StopTrackingDelayOwner(self)
    if self.delayowner ~= nil then
        self.inst:RemoveEventCallback("onremove", self._ondelaycancel, self.delayowner)
        self.inst:RemoveEventCallback("newstate", self._ondelaycancel, self.delayowner)
        self.delayowner = nil
    end
end

local function StartTrackingDelayOwner(self, owner)
    if owner ~= self.delayowner then
        StopTrackingDelayOwner(self)
        if owner ~= nil then
            self.inst:ListenForEvent("onremove", self._ondelaycancel, owner)
            self.inst:ListenForEvent("newstate", self._ondelaycancel, owner)
            self.delayowner = owner
        end
    end
end

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
    StopTrackingDelayOwner(self)
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

function Projectile:SetOnPreHitFn(fn)
    self.onprehit = fn
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
    self.inst.Physics:ClearCollidesWith(COLLISION.LIMITS)

    if attacker ~= nil and self.launchoffset ~= nil then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local facing_angle = attacker.Transform:GetRotation() * DEGREES
        self.inst.Transform:SetPosition(x + self.launchoffset.x * math.cos(facing_angle), y + self.launchoffset.y, z - self.launchoffset.x * math.sin(facing_angle))
    end

    self:RotateToTarget(self.dest)
    self.inst.Physics:SetMotorVel(self.speed, 0, 0)
    self.inst:StartUpdatingComponent(self)
    self.inst:AddTag("activeprojectile")
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
        StopTrackingDelayOwner(self)
        self:Stop()
        self.inst.Physics:Stop()
        if self.oncaught ~= nil then
            self.oncaught(self.inst, catcher)
        end
    end
end

function Projectile:Miss(target)
    local attacker = self.owner
    if attacker ~= nil and attacker.components.combat == nil and attacker.components.weapon ~= nil and attacker.components.inventoryitem ~= nil then
        attacker = attacker.components.inventoryitem.owner
    end
    StopTrackingDelayOwner(self)
    self:Stop()
    if self.onmiss ~= nil then
        self.onmiss(self.inst, attacker, target)
    end
end

function Projectile:Stop()
    self.inst.Physics:CollidesWith(COLLISION.LIMITS)

    self.inst:RemoveTag("activeprojectile")
    self.inst:StopUpdatingComponent(self)
    self.target = nil
    self.owner = nil
    self.delaypos = nil
end

function Projectile:Hit(target)
    local attacker = self.owner
    local weapon = self.inst
    StopTrackingDelayOwner(self)
    self:Stop()
    self.inst.Physics:Stop()

    if attacker.components.combat == nil and attacker.components.weapon ~= nil and attacker.components.inventoryitem ~= nil then
        weapon = (self.has_damage_set and weapon.components.weapon ~= nil) and weapon or attacker
        attacker = attacker.components.inventoryitem.owner
    end

    if self.onprehit ~= nil then
        self.onprehit(self.inst, attacker, target)
    end
    if attacker ~= nil and attacker.components.combat ~= nil then
		if attacker.components.combat.ignorehitrange then
	        attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
		else
			attacker.components.combat.ignorehitrange = true
			attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
			attacker.components.combat.ignorehitrange = false
		end
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

local function CheckTarget(target)
    return target ~= nil
        and target:IsValid()
        and not target:IsInLimbo()
        and target.entity:IsVisible()
        and (target.sg == nil or
            not (target.sg:HasStateTag("flight") or
                target.sg:HasStateTag("invisible")))
end

local function RestoreDelayPos(inst, pos, rot)
    if inst.Physics ~= nil then
        inst.Physics:Teleport(pos:Get())
    else
        inst.Transform:SetPosition(pos:Get())
    end
    inst.Transform:SetRotation(rot)
end

local function DoUpdate(self, target, pos, rot, force)
    if self.range ~= nil and distsq(self.start, pos) > self.range * self.range then
        if force then
            RestoreDelayPos(self.inst, pos, rot)
        end
        self:Miss(target)
        return true
    elseif not self.homing then
        if target ~= nil and target:IsValid() and not target:IsInLimbo() then
            local range = target:GetPhysicsRadius(0) + self.hitdist
            -- V2C: this is 3D distsq (since combat range checks use 3D distsq as well)
            -- NOTE: used < here, whereas combat uses <=, just to give us tiny bit of room for error =)
            if distsq(pos, target:GetPosition()) < range * range then
                if force then
                    RestoreDelayPos(self.inst, pos, rot)
                end
                self:Hit(target)
                return true
            end
        end
    elseif CheckTarget(target) then
        local range = target:GetPhysicsRadius(0) + self.hitdist
        -- V2C: this is 3D distsq (since combat range checks use 3D distsq as well)
        -- NOTE: used < here, whereas combat uses <=, just to give us tiny bit of room for error =)
        if distsq(pos, target:GetPosition()) < range * range then
            if force then
                RestoreDelayPos(self.inst, pos, rot)
            end
            self:Hit(target)
            return true
        else
            local direction = (self.dest - pos):GetNormalized()
            local projectedSpeed = self.speed * TheSim:GetTickTime() * TheSim:GetTimeScale()
            local projected = pos + direction * projectedSpeed
            if direction:Dot(self.dest - projected) < 0 then
                if force then
                    RestoreDelayPos(self.inst, pos, rot)
                end
                self:Hit(target)
                return true
            elseif not force then
                self:RotateToTarget(self.dest)
            end
        end
    elseif self.owner == nil or
        not self.owner:IsValid() or
        self.owner.components.combat == nil or
        self.inst.components.weapon == nil or
        self.inst.components.weapon.attackrange == nil then
        -- Lost our target, e.g. bird flew away
        if force then
            RestoreDelayPos(self.inst, pos, rot)
        end
        self:Miss(target)
        return true
    else
        -- We have enough info to make our weapon fly to max distance before "missing"
        local range = self.owner.components.combat.attackrange + self.inst.components.weapon.attackrange
        if distsq(self.owner:GetPosition(), pos) > range * range then
            if force then
                RestoreDelayPos(self.inst, pos, rot)
            end
            self:Miss(target)
            return true
        end
    end
    return false
end

function Projectile:OnUpdate(dt)
    local target = self.target
    if self.homing and target ~= nil and target:IsValid() and not target:IsInLimbo() then
        self.dest = target:GetPosition()
    end

    local pos = self.inst:GetPosition()
    if self.delaypos ~= nil then
        if not self.inst.entity:IsVisible() then
            table.insert(self.delaypos, { pos = pos, rot = self.inst.Transform:GetRotation() })
            if self.homing and CheckTarget(target) then
                self:RotateToTarget(self.dest)
            end
            return
        end

        local rot = self.inst.Transform:GetRotation()
        for i, v in ipairs(self.delaypos) do
            if DoUpdate(self, target, v.pos, v.rot, true) then
                return
            end
        end
        self.delaypos = nil
        RestoreDelayPos(self.inst, pos, rot)
    end

    DoUpdate(self, target, pos)
end

function Projectile:RotateToTarget(dest)
    local direction = (dest - self.inst:GetPosition()):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0))) / DEGREES
    self.inst.Transform:SetRotation(angle)
    self.inst:FacePoint(dest)
end

local function OnShow(inst, self)
    self.delaytask = nil
    inst:Show()
    StopTrackingDelayOwner(self)
end

function Projectile:DelayVisibility(duration)
    if self.delaytask ~= nil then
        self.delaytask:Cancel()
    end
    self.inst:Hide()
    StartTrackingDelayOwner(self,
        not self.cancatch and
        self.inst.components.inventoryitem == nil and
        self.owner ~= nil and
        self.owner:IsValid() and
        (   self.owner.components.inventoryitem ~= nil and
            self.owner.components.inventoryitem:GetGrandOwner() or
            self.owner
        ) or nil
    )
    self.delaypos = {}
    self.delaytask = self.inst:DoTaskInTime(duration, OnShow, self)
end

return Projectile
