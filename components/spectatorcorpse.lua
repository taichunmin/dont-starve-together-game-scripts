--This component runs on client as well

local function OnUpdateFocus(inst, self)
    if TheFocalPoint.entity:GetParent() == inst then
        if self.str < self.maxrange then
            self.str = math.min(self.maxrange, self.str + self.startspeed)
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local rangesq = self.maxrange * self.maxrange
        local target = nil
        for i, v in ipairs(AllPlayers) do
            if v ~= inst and not (v.replica.health:IsDead() or v:HasTag("playerghost")) and v.entity:IsVisible() then
                local distsq = v:GetDistanceSqToPoint(x, y, z)
                if v == self.lasttarget then
                    distsq = math.sqrt(distsq) - 4
                    distsq = distsq > 0 and distsq * distsq or 0
                end
                if distsq < rangesq then
                    rangesq = distsq
                    target = v
                end
            end
        end
        if target ~= nil then
            TheFocalPoint:PushTempFocus(target, 0, self.str, self.priority)
        end
        self.lasttarget = target
    end
end

local function OnIsSpectatingDirty(inst)
    local self = inst.components.spectatorcorpse
    if self._isspectating:value() then
        if self.task == nil then
            self.task = inst:DoPeriodicTask(0, OnUpdateFocus, nil, self)
            self.lasttarget = nil
            self.str = 0
        end
    elseif self.task ~= nil then
        self.task:Cancel()
        self.task = nil
        self.lasttarget = nil
        self.str = nil
    end
end

local function OnBecameCorpse(inst, data)
    if data ~= nil and data.corpse then
        local self = inst.components.spectatorcorpse
        self._isspectating:set(true)
        if self.active then
            OnIsSpectatingDirty(inst)
        end
    end
end

local function OnRezFromCorpse(inst, data)
    if data ~= nil and data.corpse then
        local self = inst.components.spectatorcorpse
        self._isspectating:set(false)
        if self.active then
            OnIsSpectatingDirty(inst)
        end
    end
end

local function OnPlayerActivated(inst)
    local self = inst.components.spectatorcorpse
    if not self.active then
        self.active = true
        if not TheWorld.ismastersim then
            inst:ListenForEvent("isspectatingdirty", OnIsSpectatingDirty)
        end
        OnIsSpectatingDirty(inst)
    end
end

local function OnPlayerDeactivated(inst)
    local self = inst.components.spectatorcorpse
    if self.active then
        self.active = false
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
            self.lasttarget = nil
            self.str = nil
        end
        if not TheWorld.ismastersim then
            inst:RemoveEventCallback("isspectatingdirty", OnIsSpectatingDirty)
        end
    end
end

local SpectatorCorpse = Class(function(self, inst)
    self.inst = inst
    self.task = nil
    self.lasttarget = nil
    self.str = nil
    self.maxrange = 40
    self.startspeed = .5
    self.priority = 1
    self.active = false

    --Networking
    self._isspectating = net_bool(inst.GUID, "spectatorcorpse._isspectating", "isspectatingdirty")

    if TheWorld.ismastersim then
        inst:ListenForEvent("ms_becameghost", OnBecameCorpse)
        inst:ListenForEvent("ms_respawnedfromghost", OnRezFromCorpse)
    end

    inst:ListenForEvent("playeractivated", OnPlayerActivated)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
end)

return SpectatorCorpse
