local function onstormlevel(self, stormlevel)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.stormlevel:set(math.floor(stormlevel * 7 + .5))
    end
end

local function onstormtype(self, stormtype)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.stormtype:set(stormtype)
    end
end

local StormWatcher = Class(function(self, inst)
    self.inst = inst

    self.stormlevel = 0
    self.delay = nil
    self.currentstorm = STORM_TYPES.NONE
    self.currentstorms = {}

    inst:ListenForEvent("ms_stormchanged", function(src, data)
        self:UpdateStorms(data)
    end, TheWorld)

    if TheWorld.net.components.moonstorms ~= nil and
            next(TheWorld.net.components.moonstorms:GetMoonstormNodes()) then
        self:UpdateStorms({stormtype= STORM_TYPES.MOONSTORM, setting = true})
    end

    if TheWorld.components.sandstorms ~= nil and
            TheWorld.components.sandstorms:IsSandstormActive() then
        self:UpdateStorms({stormtype= STORM_TYPES.SANDSTORM, setting = true})
    end

end,
nil,
{
    stormlevel = onstormlevel,
    currentstorm = onstormtype,
})

local function OnChangeArea(inst)
    local self = inst.components.stormwatcher
    self:UpdateStormLevel()
    self.delay = self.stormlevel > 0 and self.stormlevel < 1 and .5 or 1
end

function StormWatcher:GetStormLevel(stormtype)
    return (stormtype == nil or self.currentstorm == stormtype) and self.stormlevel or 0
end

function StormWatcher:GetCurrentStorm(inst)
    local currentstorm = STORM_TYPES.NONE
    if TheWorld.components.sandstorms ~= nil then
        if TheWorld.components.sandstorms:IsInSandstorm(self.inst) then
            currentstorm = STORM_TYPES.SANDSTORM
        end
    end
    if TheWorld.net.components.moonstorms ~= nil then
        if TheWorld.net.components.moonstorms:IsInMoonstorm(self.inst) then
            assert(currentstorm == STORM_TYPES.NONE,"CAN'T BE IN TWO STORMS AT ONCE")
            currentstorm = STORM_TYPES.MOONSTORM
        end
    end
    return currentstorm
end

function StormWatcher:CheckStorms(data)

    local checkstorm = self:GetCurrentStorm(self.inst)
    if self.currentstorm ~= checkstorm then
        self.currentstorm = checkstorm
        if self.currentstorm then
            self:UpdateStormLevel()
        else
            self.stormlevel = 0
        end
    end
end

function StormWatcher:UpdateStorms(data)

    if data and data.stormtype then
        self.currentstorms[data.stormtype] = data.setting
    end

    local storms = false
    for storm,setting in pairs(self.currentstorms)do
        if setting == true then
            self.inst:StartUpdatingComponent(self)
            self.inst:ListenForEvent("changearea", OnChangeArea)
            storms = true
            if self.delay == nil then
                self.delay = math.random()
            end
            break
        end
    end

    if not storms then
        self.inst:StopUpdatingComponent(self)
        self.inst:RemoveEventCallback("changearea", OnChangeArea)
        self.delay = nil
        self:UpdateStormLevel()
    end
end

function StormWatcher:UpdateStormLevel()
    self:CheckStorms()
    if self.currentstorm ~= STORM_TYPES.NONE then
        if self.currentstorm == STORM_TYPES.SANDSTORM then
			self.stormlevel = math.floor(TheWorld.components.sandstorms:GetSandstormLevel(self.inst) * 7 + .5) / 7
            self.inst.components.sandstormwatcher:UpdateSandstormLevel()
        elseif self.currentstorm == STORM_TYPES.MOONSTORM then
			self.stormlevel = math.floor(TheWorld.net.components.moonstorms:GetMoonstormLevel(self.inst) * 7 + .5) / 7
            self.inst.components.moonstormwatcher:UpdateMoonstormLevel()
        end
    else
        if self.laststorm ~= STORM_TYPES.NONE then
            if self.laststorm == STORM_TYPES.SANDSTORM then
                self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "sandstorm")
            elseif self.laststorm == STORM_TYPES.MOONSTORM then
                self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "moonstorm")
            end
        end
        self.stormlevel = 0
    end
    self.laststorm = self.currentstorm
end

function StormWatcher:OnUpdate(dt)
    if self.delay > dt then
        self.delay = self.delay - dt
    else
        self:UpdateStormLevel()
        self.delay = self.stormlevel > 0 and self.stormlevel < 1 and .5 or 1
    end
end

return StormWatcher