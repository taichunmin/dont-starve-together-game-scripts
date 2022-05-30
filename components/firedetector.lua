local NOTAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "player", "monster" }
local EMERGENCYTAGS = { "structure", "wall", "tree", "pickable", "witherable", "readyforharvest", "notreadyforharvest" }
local NONEMERGENCYTAGS = {"witherable", "fire", "smolder"}
local NONEMERGENCY_FIREONLY_TAGS = {"fire", "smolder"}
local TURN_ON_DELAY = 13 * FRAMES

local function onemergency(self, emergency)
    if emergency then
        self.inst:AddTag("emergency")
    else
        self.inst:RemoveTag("emergency")
    end
end

local FireDetector = Class(function(self, inst)
    self.inst = inst

    self.range = TUNING.FIRE_DETECTOR_RANGE
    self.detectPeriod = TUNING.FIRE_DETECTOR_PERIOD

    self.onfindfire = nil
    self.onbeginemergency = nil
    self.onendemergency = nil
    self.onbeginwarning = nil
    self.onupdatewarning = nil
    self.onendwarning = nil

    self.detectedItems = {}
    self.detectTask = nil

    --self.fireOnly = nil

    self.emergencyResponsePeriod = TUNING.EMERGENCY_RESPONSE_TIME
    self.emergencyShutdownPeriod = TUNING.EMERGENCY_SHUT_OFF_TIME
    self.emergencyLevelMax = TUNING.EMERGENCY_BURNT_NUMBER
    self.emergencyLevelFireThreshold = TUNING.EMERGENCY_BURNING_NUMBER
    self.emergencyLevel = 0
    self.emergency = false
    self.emergencyWatched = nil
    self.emergencyBurnt = nil
    self.emergencyShutdownTask = nil
    self.emergencyShutdownTime = nil
    self.warningStartTime = nil
end,
nil,
{
    emergency = onemergency,
})

--------------------------------------------------------------------------

function FireDetector:SetOnFindFireFn(fn)
    self.onfindfire = fn
end

function FireDetector:SetOnBeginEmergencyFn(fn)
    self.onbeginemergency = fn
end

function FireDetector:SetOnEndEmergencyFn(fn)
    self.onendemergency = fn
end

function FireDetector:SetOnBeginWarningFn(fn)
    self.onbeginwarning = fn
end

function FireDetector:SetOnUpdateWarningFn(fn)
    self.onupdatewarning = fn
end

function FireDetector:SetOnEndWarningFn(fn)
    self.onendwarning = fn
end

--------------------------------------------------------------------------

local function Cancel(inst, self)
    if self.detectTask ~= nil then
        self.detectTask:Cancel()
        self.detectTask = nil
    end
    if self.emergencyShutdownTask ~= nil then
        self.emergencyShutdownTask:Cancel()
        self.emergencyShutdownTask = nil
        self.emergencyShutdownTime = nil
    end
    if self.emergencyWatched ~= nil then
        for k, v in pairs(self.emergencyWatched) do
            inst:RemoveEventCallback("onburnt", v.onburnt, k)
            inst:RemoveEventCallback("onremove", v.onremove, k)
        end
        self.emergencyWatched = nil
    end
    self.emergencyBurnt = nil
    self.emergencyLevel = 0
    self.emergency = false
    self.warningStartTime = nil
end

function FireDetector:OnRemoveFromEntity()
    Cancel(self.inst, self)
    for k, v in pairs(self.detectedItems) do
        v:Cancel()
    end
end

local function OnDetectedItemTimeOut(inst, self, target)
    self.detectedItems[target] = nil
end

local function RegisterDetectedItem(inst, self, target)
    self.detectedItems[target] = inst:DoTaskInTime(2, OnDetectedItemTimeOut, self, target)
end

--------------------------------------------------------------------------
-- Active mode

local function CheckTargetScore(target)
    if not target:IsValid() then
        return 0
    elseif target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            return 10, true --Burning, highest priority so no need to keep testing others
        elseif target.components.burnable:IsSmoldering() then
            return 9 --Smoldering
        end
    end
    if target.components.witherable == nil or target.components.witherable:IsProtected() then
        return 0
    elseif target.components.witherable:CanWither() then
        return 8 --Withering
    elseif target.components.witherable:CanRejuvenate() then
        return 7 --Withered but can be rejuvenated
    end
    return 0
end

local function LookForFiresAndFirestarters(inst, self, force)
    if not force and inst.sg ~= nil and inst.sg:HasStateTag("busy") then
        return
    end
	local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.range, nil, NOTAGS, (self.fireOnly and NONEMERGENCY_FIREONLY_TAGS) or NONEMERGENCYTAGS)
	local target = nil
	local targetscore = 0
	for i, v in ipairs(ents) do
		if not self.detectedItems[v] then
            local score, force = CheckTargetScore(v)
            if force then
                target = v
                break
            elseif score > targetscore then
				targetscore = score
				target = v
			end
		end
	end
    if target ~= nil then
        RegisterDetectedItem(inst, self, target)
        if self.onfindfire ~= nil then
            self.onfindfire(inst, target:GetPosition())
        end
    end
end

function FireDetector:Activate(randomizedStartTime)
    Cancel(self.inst, self)
    self.detectTask = self.inst:DoPeriodicTask(self.detectPeriod, LookForFiresAndFirestarters, randomizedStartTime and TURN_ON_DELAY + math.random() * self.detectPeriod or TURN_ON_DELAY, self)
end

--------------------------------------------------------------------------
-- Emergency mode

local function OnEndEmergency(inst, self)
    Cancel(inst, self)
    if self.onendemergency ~= nil then
        self.onendemergency(inst, self.emergencyLevel)
    end
end

local FIRE_TAGS = { "fire" }
local function DetectFireEmergency(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.range, FIRE_TAGS, NOTAGS)
    for i, v in ipairs(ents) do
        if not self.detectedItems[v] and v:IsValid() then
            return v
        end
    end
end

local function LookForFireEmergencies(inst, self, force)
    if not force and inst.sg ~= nil and inst.sg:HasStateTag("busy") then
        return
    end
    local target = DetectFireEmergency(inst, self)
    if target ~= nil then
        RegisterDetectedItem(inst, self, target)
        if self.emergencyShutdownTask ~= nil then
            self.emergencyShutdownTask:Cancel()
            self.emergencyShutdownTask = nil
            self.emergencyShutdownTime = nil
        end
        if self.onfindfire ~= nil then
            self.onfindfire(inst, target:GetPosition())
        end
    elseif self.emergencyShutdownTask == nil then
        self.emergencyShutdownTask = inst:DoTaskInTime(self.emergencyShutdownPeriod, OnEndEmergency, self)
        self.emergencyShutdownTime = GetTime() + self.emergencyShutdownPeriod
    end
end


local function EmergencyResponse(inst, self, target)
    if target ~= nil then
        inst:RemoveEventCallback("onburnt", self.emergencyWatched[target].onburnt, target)
        inst:RemoveEventCallback("onremove", self.emergencyWatched[target].onremove, target)
        self.emergencyWatched[target] = nil
    end
    if self.emergencyBurnt ~= nil then
        if target ~= nil then
            if #self.emergencyBurnt < self.emergencyLevelMax then
                table.insert(self.emergencyBurnt, 0)
            end
            self:ResetEmergencyCooldown()
        else
            local t = GetTime() - self.emergencyResponsePeriod
            while #self.emergencyBurnt > 0 and self.emergencyBurnt[1] <= t do
                table.remove(self.emergencyBurnt, 1)
            end
        end

        if self.warningStartTime ~= nil and
            #self.emergencyBurnt >= self.emergencyLevelMax and
            GetTime() - self.warningStartTime > TUNING.EMERGENCY_WARNING_TIME and
            DetectFireEmergency(inst, self) ~= nil then
            Cancel(inst, self)
            self.emergencyLevel = self.emergencyLevelMax
            self.emergency = true
            self.detectTask = inst:DoPeriodicTask(self.detectPeriod, LookForFireEmergencies, TURN_ON_DELAY, self)
            if self.onbeginemergency ~= nil then
                self.onbeginemergency(inst, self.emergencyLevel)
            end
        elseif #self.emergencyBurnt > 0 then
            if self.emergencyLevel <= 0 then
                self.emergencyLevel = #self.emergencyBurnt
                self.warningStartTime = GetTime()
                if self.onbeginwarning ~= nil then
                    self.onbeginwarning(inst, self.emergencyLevel)
                end
            elseif self.emergencyLevel ~= #self.emergencyBurnt then
                self.emergencyLevel = #self.emergencyBurnt
                if self.onupdatewarning ~= nil then
                    self.onupdatewarning(inst, self.emergencyLevel)
                end
            end
        elseif self.emergencyLevel > 0 then
            self.emergencyLevel = 0
            self.warningStartTime = nil
            if self.onendwarning ~= nil then
                self.onendwarning(inst, self.emergencyLevel)
            end
        end
    end
end

local function OnDetectEmergencyTargets(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.range, nil, NOTAGS, EMERGENCYTAGS)
    local firecount = 0
    for i, v in ipairs(ents) do
        if not v:IsValid() then
            --Just in case didn't clean up properly
            if self.emergencyWatched[v] ~= nil then
                inst:RemoveEventCallback("onburnt", self.emergencyWatched[v].onburnt, v)
                inst:RemoveEventCallback("onremove", self.emergencyWatched[v].onremove, v)
                self.emergencyWatched[v] = nil
            end
        elseif v.components.burnable ~= nil then
            if self.emergencyWatched[v] == nil then
                self.emergencyWatched[v] =
                {
                    onburnt = function()
                        EmergencyResponse(inst, self, v)
                    end,
                    onremove = function()
                        self.emergencyWatched[v] = nil
                    end,
                }
                inst:ListenForEvent("onburnt", self.emergencyWatched[v].onburnt, v)
                inst:ListenForEvent("onremove", self.emergencyWatched[v].onremove, v)
            end
            if v.components.burnable:IsBurning() then
                firecount = firecount + 1
            end
        end
    end
    if firecount >= self.emergencyLevelFireThreshold and self.emergencyBurnt ~= nil then
        if self.emergencyLevel < math.min(1, self.emergencyLevelMax) then
            table.insert(self.emergencyBurnt, 0)
            self:ResetEmergencyCooldown()
        elseif self.emergencyLevel == 1 then
            self:ResetEmergencyCooldown()
        end
    end
    EmergencyResponse(inst, self)
end

function FireDetector:ActivateEmergencyMode(randomizedStartTime)
    Cancel(self.inst, self)
    self.emergencyBurnt = {}
    self.emergencyWatched = {}
    self.detectTask = self.inst:DoPeriodicTask(self.detectPeriod, OnDetectEmergencyTargets, randomizedStartTime and math.random() * self.detectPeriod or 0, self)
end

function FireDetector:IsEmergency()
    return self.emergency
end

function FireDetector:GetEmergencyLevel()
    return self.emergencyLevel
end

function FireDetector:GetMaxEmergencyLevel()
    return self.emergencyLevelMax
end

function FireDetector:ResetEmergencyCooldown()
    if self.emergencyBurnt ~= nil then
        local t = GetTime()
        for i = 1, #self.emergencyBurnt do
            self.emergencyBurnt[i] = t
            t = t + self.emergencyResponsePeriod
        end
    elseif self.emergencyShutdownTask ~= nil then
        self.emergencyShutdownTask:Cancel()
        self.emergencyShutdownTask = self.inst:DoTaskInTime(self.emergencyShutdownPeriod, OnEndEmergency, self)
        self.emergencyShutdownTime = GetTime() + self.emergencyShutdownPeriod
    end
end

function FireDetector:RaiseEmergencyLevel(numlevels)
    if self.emergencyBurnt ~= nil then
        for i = 1, math.min(numlevels or 1, self.emergencyLevelMax - #self.emergencyBurnt) do
            table.insert(self.emergencyBurnt, 0)
        end
        self:ResetEmergencyCooldown()
        EmergencyResponse(self.inst, self)
    end
end

function FireDetector:LowerEmergencyLevel(numlevels)
    if self.emergencyBurnt ~= nil then
        for i = math.min(#self.emergencyBurnt, numlevels or 1), 1, -1 do
            table.remove(self.emergencyBurnt)
        end
        self:ResetEmergencyCooldown()
        EmergencyResponse(self.inst, self)
    end
end

--------------------------------------------------------------------------

function FireDetector:Deactivate()
    if self.emergency then
        Cancel(self.inst, self)
        if self.onendemergency ~= nil then
            self.onendemergency(self.inst, self.emergencyLevel)
        end
    elseif self.emergencyBurnt == nil then
        Cancel(self.inst, self)
    elseif #self.emergencyBurnt > 0 then
        self.emergencyBurnt = {}
        EmergencyResponse(self.inst, self)
    end
end

--------------------------------------------------------------------------
-- Exposed for stategraph to trigger shooting at its own rate

function FireDetector:DetectFire()
    if self.detectTask ~= nil then
        if self.emergency then
            LookForFireEmergencies(self.inst, self, true)
        elseif self.emergencyBurnt == nil then
            LookForFiresAndFirestarters(self.inst, self, true)
        end
    end
end

--------------------------------------------------------------------------
-- Debug

function FireDetector:GetDebugString()
    return ((self.detectTask == nil and "OFF") or
            (self.emergency and "EMERGENCY") or
            (self.emergencyBurnt ~= nil and "ARMED") or
            "ON")
        .." level: "..tostring(self.emergencyLevel)
        .." watching: "..tostring(GetTableSize(self.emergencyWatched))
        .." recent: "..tostring(GetTableSize(self.detectedItems))
        ..string.format(" warningdelay: %2.2f",
            (self.warningStartTime ~= nil and math.max(0, self.warningStartTime + TUNING.EMERGENCY_WARNING_TIME - GetTime())) or
            0)
        ..string.format(" cooldown: %2.2f",
            (self.emergencyShutdownTime ~= nil and self.emergencyShutdownTime - GetTime()) or
            (self.emergencyBurnt ~= nil and #self.emergencyBurnt > 0 and self.emergencyBurnt[1] + self.emergencyResponsePeriod - GetTime()) or
            0)
end

--------------------------------------------------------------------------

return FireDetector
