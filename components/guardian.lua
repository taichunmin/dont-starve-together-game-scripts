--Guardians are summoned by other creatures (see mossling & moose)

local Guardian = Class(function(self, inst)
    self.inst = inst
    self.prefab = nil
    self.guardian = nil
    self.onsummonfn = nil
    self.onguardiandeathfn = nil

    --When summons >= threshold, spawn prefab
    self.threshold = 20
    self.summons = 0

    self.decaytime = 20
    self.decaytask = nil

    self._onguardiandeath = function(guardian, data) self:OnGuardianDeath(data) end
    self._onguardianremove = function() self:SetGuardian(nil) end
end)

function Guardian:OnRemoveFromEntity()
    if self.decaytask ~= nil then
        self.decaytask:Cancel()
        self.decaytask = nil
    end
    self:SetGuardian(nil)
end

function Guardian:SetGuardian(guardian)
    if self.guardian ~= guardian then
        if self.guardian ~= nil then
            self.inst:RemoveEventCallback("death", self._onguardiandeath, self.guardian)
            self.inst:RemoveEventCallback("onremove", self._onguardianremove, self.guardian)
        end
        if guardian ~= nil then
            self.inst:ListenForEvent("death", self._onguardiandeath, guardian)
            self.inst:ListenForEvent("onremove", self._onguardianremove, guardian)
        end
        self.guardian = guardian
    end
end

function Guardian:DoDelta(d)
    local old = self.summons

    self.summons = self.summons + d
    self.summons = math.clamp(self.summons, 0, self.threshold)

    self.inst:PushEvent("summonsdelta", { old = old, new = self.summons })

    self:StartDecay()

    if self.guardian == nil then
        if self:SummonsAtMax() then
            self:SummonGuardian()
        end
    elseif self:SummonsAtMin() then
        self:DismissGuardian()
    end
end

function Guardian:SummonsAtMax()
    return self.summons >= self.threshold
end

function Guardian:SummonsAtMin()
    return self.summons <= 0
end

function Guardian:Call(d)
    self:DoDelta(d or 1)
end

function Guardian:Decay(d)
    self:DoDelta(d or -1)
end

local function OnDecay(inst, self)
    self.decaytask = nil
    self:DoDelta(-1)
end

function Guardian:StartDecay()
    if self.decaytask ~= nil then
        self.decaytask:Cancel()
    end
    self.decaytask =
        self.summons > 0 and
        self.inst:DoTaskInTime(self.decaytime, OnDecay, self) or
        nil
end

function Guardian:SummonGuardian(override)
    if self.prefab == nil then
        print("No prefab set in Guardian component!")
        return
    end

    if override ~= nil then
        self:SetGuardian(override)
    elseif self.guardian == nil then
        --Look for a prefab of this type already in the world.
        local guard = FindEntity(self.inst, 30, function(ent) return ent.prefab == self.prefab end)
        if guard ~= nil then
            --print("Found Guardian")
            self:SetGuardian(guard)
        else
            self:SetGuardian(SpawnPrefab(self.prefab))
            self.guardian.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

            if self.onsummonfn ~= nil and self.guardian then
                self.onsummonfn(self.inst, self.guardian)
            end
        end
    end
end

function Guardian:OnGuardianDeath(data)
    if self.onguardiandeathfn ~= nil then
        local cause = data ~= nil and data.cause or nil
        self.onguardiandeathfn(self.inst, self.guardian, cause)
    end
    self:SetGuardian(nil)
end

function Guardian:DismissGuardian()
    if self.guardian == nil then
        return
    end
    --print("dismiss guardian")
    if self.ondismissfn ~= nil then
        self.ondismissfn(self.inst, self.guardian)
        self:SetGuardian(nil)
    else
        self.guardian:Remove()
    end
end

function Guardian:HasGuardian()
    return self.guardian ~= nil
end

function Guardian:OnSave()
    local data = {}
    local refs = {}

    data.summons = self.summons

    if self.guardian ~= nil then
        data.guardian = self.guardian.GUID
        table.insert(refs, self.guardian.GUID)
    end

    return data, refs
end

function Guardian:OnLoad(data)
    if data ~= nil and data.summons ~= nil then
        self.summons = data.summons
        self:StartDecay()
    end
end

function Guardian:LoadPostPass(ents, data)
    if data.guardian ~= nil then
        local guard = ents[data.guardian]
        if guard ~= nil then
            guard = guard.entity
            self:SummonGuardian(guard)
        end
    end
end

return Guardian
