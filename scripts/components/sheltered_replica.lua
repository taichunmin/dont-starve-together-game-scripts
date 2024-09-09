local SHELTERED_SHADE = .6
local EXPOSED_SHADE = 1
local TIME_TO_SHELTER = .2
local TIME_TO_EXPOSE = .1

local function Initialize(inst, self)
    self._task = nil
    if self._issheltered:value() then
        self._targetshade = SHELTERED_SHADE
        self._shade = SHELTERED_SHADE
        self.inst.AnimState:OverrideShade(SHELTERED_SHADE)
    end
    if not TheWorld.ismastersim then
        self.inst:ListenForEvent("issheltereddirty", function() self:CheckShade() end)
    end
end

local Sheltered = Class(function(self, inst)
    self.inst = inst

    self._updating = false
    self._shade = EXPOSED_SHADE
    self._targetshade = EXPOSED_SHADE
    self._shelterspeed = (EXPOSED_SHADE - SHELTERED_SHADE) / TIME_TO_SHELTER
    self._exposespeed = (EXPOSED_SHADE - SHELTERED_SHADE) / TIME_TO_EXPOSE
    self._issheltered = net_bool(inst.GUID, "sheltered._issheltered", "issheltereddirty")

    self._task = inst:DoTaskInTime(0, Initialize, self)
end)

--V2C: OnRemoveFromEntity not supported
--[[function Sheltered:OnRemoveFromEntity()
    if self._task ~= nil then
        self._task:Cancel()
    end
    self.inst.AnimState:OverrideShade(1)
end]]

function Sheltered:StartSheltered(level)
    self._issheltered:set(true)
    self:CheckShade()
end

function Sheltered:StopSheltered()
    self._issheltered:set(false)
    self:CheckShade()
end

function Sheltered:IsSheltered()
    return self._issheltered:value() and self._shade <= SHELTERED_SHADE
end

function Sheltered:CheckShade()
    self._targetshade = self._issheltered:value() and SHELTERED_SHADE or EXPOSED_SHADE
    if self._updating then
        if self.shade == self._targetshade then
            self.inst:StopUpdatingComponent(self)
            self._updating = false
        end
    elseif self.shade ~= self._targetshade then
        self.inst:StartUpdatingComponent(self)
        self._updating = true
    end
end

function Sheltered:OnUpdate(dt)
    if self._shade ~= self._targetshade then
        self._shade =
            self._shade > self._targetshade and
            math.max(SHELTERED_SHADE, self._shade - dt * self._shelterspeed) or
            math.min(EXPOSED_SHADE, self._shade + dt * self._exposespeed)
        self.inst.AnimState:OverrideShade(self._shade)
    end
    if self._updating and self._shade == self._targetshade then
        self.inst:StopUpdatingComponent(self)
        self._updating = false
    end
end

return Sheltered