local function OnDayComplete(self)
    if self.worldsettingsenabled and self.daystomoodchange then
        self.daystomoodchange = self.daystomoodchange - 1
        self:CheckForMoodChange()
    end
end

local Mood = Class(function(self, inst)
    self.inst = inst

    self.enabled = true

    self.moodtimeindays = {length = nil, wait = nil}
    self.forcemood = false
    self.isinmood = false
    self.daystomoodchange = nil
    self.onentermood = nil
    self.onleavemood = nil
    self.moodseasons = {}
    self.firstseasonadded = false

    self.worldsettingsmultiplier_inmood = 1
    self.worldsettingsmultiplier_outmood = 1
    self.worldsettingsenabled = true

    self:WatchWorldState("cycles", OnDayComplete)
end)

function Mood:GetDebugString()
    return string.format("inmood:%s, days till change:%s %s", self.enabled and tostring(self.isinmood) or "DISABLED", tostring(self.daystomoodchange), self.seasonmood and "SEASONMOOD" or "" )
end

function Mood:Enable(enabled)
    self.enabled = enabled
    self:SetIsInMood(false, false)
end

function Mood:SetMoodTimeInDays(length, wait, forcemood, worldsettingsmultiplier_inmood, worldsettingsmultiplier_outmood, worldsettingsenabled)
    self.moodtimeindays.length = length
    self.moodtimeindays.wait = wait
    self.daystomoodchange = wait
    self.forcemood = forcemood

    self.worldsettingsmultiplier_inmood = worldsettingsmultiplier_inmood or 1
    self.worldsettingsmultiplier_outmood = worldsettingsmultiplier_outmood or 1
    self.worldsettingsenabled = worldsettingsenabled ~= false

    self.isinmood = false
end

local function OnSeasonChange(inst, season)
    if not inst.components.mood.enabled then
        return
    end

	local active = false
	if inst.components.mood.moodseasons then
	    for i, s in pairs(inst.components.mood.moodseasons) do
	        if s == season then
	            active = true
	            break
	        end
	    end
	end
    if active then
        inst.components.mood:SetIsInMood(true, true)
    else
        inst.components.mood:ResetMood()
    end
end

-- Use this to set the mood correctly (used for making sure the beefalo are mating when the start season is spring)
function Mood:ValidateMood()
    OnSeasonChange(self.inst, TheWorld.state.season)
end

function Mood:SetMoodSeason(activeseason)
    table.insert(self.moodseasons, activeseason)
    if not self.firstseasonadded then
        self.inst:WatchWorldState("season", OnSeasonChange)
        self.firstseasonadded = true
    end
end

function Mood:CheckForMoodChange()
    if self.daystomoodchange <= 0 then
        self:SetIsInMood(not self:IsInMood() or self.forcemood)
    end
end

function Mood:SetInMoodFn(fn)
    self.onentermood = fn
end

function Mood:SetLeaveMoodFn(fn)
    self.onleavemood = fn
end

function Mood:ResetMood()
    if self.seasonmood then
        self.seasonmood = false
        self.isinmood = false
        self.daystomoodchange = self.moodtimeindays.wait
        if self.onleavemood then
            self.onleavemood(self.inst)
        end
    end
end

local function GetSeasonLength()
    return TheWorld.state[TheWorld.state.season.."length"]
end

function Mood:SetIsInMood(inmood, entireseason)
    if inmood and not (self.enabled and self.worldsettingsenabled) then
        return
    end

    if self.isinmood ~= inmood or entireseason then

        self.isinmood = inmood
        if self.isinmood then
            if entireseason then
                self.seasonmood = true
                self.daystomoodchange = GetSeasonLength() or self.moodtimeindays.length
            else
                self.seasonmood = false
                self.daystomoodchange = self.moodtimeindays.length
            end
            if self.onentermood then
                self.onentermood(self.inst)
            end
        else
            if not entireseason then
                self.seasonmood = false
                self.daystomoodchange = self.moodtimeindays.wait
            end
            if self.onleavemood then
                self.onleavemood(self.inst)
            end
        end
    end
end

function Mood:IsInMood()
    return self.isinmood
end

function Mood:OnSave()
    local multiplier = self.isinmood and self.worldsettingsmultiplier_inmood or self.worldsettingsmultiplier_outmood
    return {inmood = self.isinmood, daysleft = self.daystomoodchange ~= 0 and self.daystomoodchange / multiplier or 0, moodseasons = self.moodseasons, version = 2}
end

function Mood:OnLoad(data)
	self.moodseasons = data.moodseasons or self.moodseasons
    self.isinmood = not data.inmood
    local active = false
    local season = TheWorld.state.season
    if self.moodseasons then
	    for i, s in pairs(self.moodseasons) do
	        if season and s == season then
	            active = true
	            break
	        end
	    end
	end
    self:SetIsInMood(data.inmood, active)
    if not data.version then
        local max = self.isinmood and self.worldsettingsmultiplier_inmood or self.worldsettingsmultiplier_outmood
        self.daystomoodchange = math.min(data.daysleft, max)
    elseif data.version == 2 then
        local multiplier = self.isinmood and self.worldsettingsmultiplier_inmood or self.worldsettingsmultiplier_outmood
        self.daystomoodchange = RoundBiasedUp(data.daysleft * multiplier)
    end
end

return Mood
