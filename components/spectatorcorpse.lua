--This component runs on client as well

local function OnIsSpectatingDirty(inst)
    local self = inst.components.spectatorcorpse
    if self._isspectating:value() then
        if not self.updating then
            self.updating = true
            self.lasttarget = nil
            self.str = 0
            self.inst:StartUpdatingComponent(self)
        end
    elseif self.updating then
        self.updating = false
        self.lasttarget = nil
        self.str = nil
        self.inst:StopUpdatingComponent(self)
		TheFocalPoint.components.focalpoint:StopFocusSource(self.inst, "CorpseCam")
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
        if self.updating then
            self.updating = false
            self.lasttarget = nil
            self.str = nil
            self.inst:StopUpdatingComponent(self)
        end
        if not TheWorld.ismastersim then
            inst:RemoveEventCallback("isspectatingdirty", OnIsSpectatingDirty)
        end
    end
end

local SpectatorCorpse = Class(function(self, inst)
    self.inst = inst
    self.lasttarget = nil
    self.str = nil
    self.maxrange = 40
    self.startspeed = .5
    self.priority = 1
    self.active = false
    self.updating = false

    --Networking
    self._isspectating = net_bool(inst.GUID, "spectatorcorpse._isspectating", "isspectatingdirty")

    if TheWorld.ismastersim then
        inst:ListenForEvent("ms_becameghost", OnBecameCorpse)
        inst:ListenForEvent("ms_respawnedfromghost", OnRezFromCorpse)
    end

    inst:ListenForEvent("playeractivated", OnPlayerActivated)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
end)

function SpectatorCorpse:OnUpdate()
    if TheFocalPoint.entity:GetParent() == self.inst then
        if self.str < self.maxrange then
            self.str = math.min(self.maxrange, self.str + self.startspeed)
        end
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local rangesq = self.maxrange * self.maxrange
        local target = nil
        for i, v in ipairs(AllPlayers) do
            if v ~= self.inst and not IsEntityDeadOrGhost(v) and v.entity:IsVisible() then
                local distsq = v:GetDistanceSqToPoint(x, y, z)
                if v == self.lasttarget then
                    distsq = math.sqrt(distsq) - 4 -- priority for last target
                    distsq = distsq > 0 and distsq * distsq or 0
                end
                if distsq < rangesq then
                    rangesq = distsq
                    target = v
                end
            end
        end
        if target ~= nil then
			TheFocalPoint.components.focalpoint:StartFocusSource(self.inst, "CorpseCam", target, 0, self.str, self.priority)
		else
			TheFocalPoint.components.focalpoint:StopFocusSource(self.inst, "CorpseCam")
        end
        self.lasttarget = target
    end
end

return SpectatorCorpse
