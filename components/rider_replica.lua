local Rider = Class(function(self, inst)
    self.inst = inst

    self._isriding = net_bool(inst.GUID, "rider._isriding", "isridingdirty")

    if TheWorld.ismastersim then
        self.classified = inst.player_classified
        self._onmounthealthdelta = function(mount, data) self:OnMountHealth(data.newpercent) end
    else
        self._onisriding = function() self:OnIsRiding(self._isriding:value()) end
        inst:ListenForEvent("isridingdirty", self._onisriding)

        if self.classified == nil and inst.player_classified ~= nil then
            self:AttachClassified(inst.player_classified)
        end
    end
end)

--------------------------------------------------------------------------

function Rider:OnRemoveFromEntity()
    if TheWorld.ismastersim then
        self.classified = nil
    else
        self.inst:RemoveEventCallback("isridingdirty", self._onisriding)

        if self.classified ~= nil then
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

Rider.OnRemoveEntity = Rider.OnRemoveFromEntity

function Rider:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
    if self._isriding:value() then
        self:SetActionFilter(true)
    end
end

function Rider:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------

local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local function ActionButtonOverride(inst, force_target)
    --catching
    if inst:HasTag("cancatch") and not inst.components.playercontroller:IsDoingOrWorking() then
        if force_target == nil then
            local target = FindEntity(inst, 10, nil, { "catchable" }, TARGET_EXCLUDE_TAGS)
            if CanEntitySeeTarget(inst, target) then
                return BufferedAction(inst, target, ACTIONS.CATCH)
            end
        elseif inst:GetDistanceSqToInst(force_target) <= 100 and
            force_target:HasTag("catchable") then
            return BufferedAction(inst, force_target, ACTIONS.CATCH)
        end
    end
end

local function MountedActionFilter(inst, action)
    return action.mount_valid == true
end

function Rider:SetActionFilter(riding)
    if self.inst.components.playercontroller ~= nil then
        if riding then
            self.inst.components.playercontroller.actionbuttonoverride = ActionButtonOverride
            self.inst.components.playeractionpicker:PushActionFilter(MountedActionFilter, 20)
        else
            self.inst.components.playercontroller.actionbuttonoverride = nil
            self.inst.components.playeractionpicker:PopActionFilter(MountedActionFilter)
        end
    end
end

--------------------------------------------------------------------------

function Rider:OnIsRiding(riding)
    if self.classified ~= nil then
        self:SetActionFilter(riding)
    end
end

--------------------------------------------------------------------------

function Rider:SetRiding(riding)
    if riding ~= self._isriding:value() then
        self._isriding:set(riding)
        self:OnIsRiding(riding)
    end
end

function Rider:IsRiding()
    return self._isriding:value()
end

function Rider:OnMountHealth(pct)
    if self.classified ~= nil then
        self.classified.isridermounthurt:set(pct < .2)
    end
end

function Rider:IsMountHurt()
    return self.classified ~= nil and self.classified.isridermounthurt:value()
end

function Rider:SetMount(mount)
    if self.classified ~= nil and mount ~= self.classified.ridermount:value() then
        local old = self.classified.ridermount:value()
        if old ~= nil then
            old.Network:SetClassifiedTarget(nil)
            self.inst:RemoveEventCallback("healthdelta", self._onmounthealthdelta, old)
        end
        if mount ~= nil then
            mount.Network:SetClassifiedTarget(self.inst)
            self.classified.riderrunspeed:set(mount.components.locomotor.runspeed)
            self.classified.riderfasteronroad:set(mount.components.locomotor.fasteronroad == true)
            self.inst:ListenForEvent("healthdelta", self._onmounthealthdelta, mount)
        end
        self:OnMountHealth(mount ~= nil and mount.components.health ~= nil and mount.components.health:GetPercent() or 1)
        self.classified.ridermount:set(mount)
    end
end

function Rider:GetMount()
    if self.inst.components.rider ~= nil then
        return self.inst.components.rider:GetMount()
    elseif self.classified ~= nil then
        return self.classified.ridermount:value()
    else
        return nil
    end
end

function Rider:GetMountRunSpeed()
    local mount = self:GetMount()
    if mount == nil then
        return 0
    elseif mount.components.locomotor ~= nil then
        return mount.components.locomotor.runspeed
    elseif self.classified ~= nil then
        return self.classified.riderrunspeed:value()
    else
        return 0
    end
end

function Rider:GetMountFasterOnRoad()
    local mount = self:GetMount()
    if mount == nil then
        return false
    elseif mount.components.locomotor ~= nil then
        return mount.components.locomotor.fasteronroad
    elseif self.classified ~= nil then
        return self.classified.riderfasteronroad:value()
    else
        return false
    end
end

function Rider:SetSaddle(saddle)
    if self.classified ~= nil and saddle ~= self.classified.ridersaddle:value() then
        local old = self.classified.ridersaddle:value()
        if old ~= nil then
            assert(not old.components.inventoryitem:IsHeld())
            if old.components.inventoryitem ~= nil then
                old.replica.inventoryitem:SetOwner(nil)
            else
                old.Network:SetClassifiedTarget(nil)
            end
        end
        if saddle ~= nil then
            assert(not saddle.components.inventoryitem:IsHeld())
            if saddle.components.inventoryitem ~= nil then
                saddle.replica.inventoryitem:SetOwner(self.inst)
            else
                saddle.Network:SetClassifiedTarget(self.inst)
            end
        end
        self.classified.ridersaddle:set(saddle)
    end
end

function Rider:GetSaddle()
    if self.inst.components.rider ~= nil then
        return self.inst.components.rider:GetSaddle()
    elseif self.classified ~= nil then
        return self.classified.ridersaddle:value()
    else
        return nil
    end
end

return Rider
