local Hatchable = Class(function(self, inst)
    self.inst = inst

    self.progress = 0
    self.discomfort = 0

    self.state = "unhatched"

    self.cracktime = 10
    self.hatchtime = 600
    self.hatchfailtime = 60

    self.heater_prefs =
    {
        day = false,
        dusk = nil,
        night = true,
    }

    self.chiller_prefs =
    {
        day = false,
        dusk = false,
        night = false,
    }

    self.delay = false
end)

function Hatchable:GetDebugString()
    return string.format("state: %s, progress: %2.2f/%2.2f, discomfort: %2.2f/%2.2f", self.state, self.progress, self.state == "unhatched" and self.cracktime or self.hatchtime, self.discomfort, self.hatchfailtime)
end

function Hatchable:SetOnState(fn)
    self.onstatefn = fn
end

function Hatchable:SetCrackTime(t)
--    print("Hatchable:SetCrackTime", t)
    self.cracktime = t
end

function Hatchable:SetHatchTime(t)
--    print("Hatchable:SetHatchTime", t)
    self.hatchtime = t
end

function Hatchable:SetHatchFailTime(t)
--    print("Hatchable:SetHatchFailTime", t)
    self.hatchfailtime = t
end

function Hatchable:OnState(state, forcestateupdate)
    --print("Hatchable:OnState", state)
    if self.state ~= state or forcestateupdate then
        self.state = state
        if self.onstatefn then
            self.onstatefn(self.inst, self.state)
        end
    end
end

function Hatchable:Delay(time)
    self.delay = true
    self.inst:DoTaskInTime(time, function() self.delay = false end)
end

function Hatchable:StopUpdating()
    --print("Hatchable:StopUpdating")
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Hatchable:StartUpdating()
    --print("Hatchable:StartUpdating", self.state)
    if not (self.state == "dead" or self.state == "hatch") and not self.task then
        local dt = TUNING.HATCH_UPDATE_PERIOD
        self.task = self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end, 0)
    end
end

function Hatchable:SetHeaterPrefs(day, dusk, night)
    --If this is "nil" then the egg does not care either way.
    self.heater_prefs["day"] = day
    self.heater_prefs["dusk"] = dusk
    self.heater_prefs["night"] = night
end

function Hatchable:SetChillerPrefs(day, dusk, night)
    --If this is "nil" then the egg does not care either way.
    self.chiller_prefs["day"] = day
    self.chiller_prefs["dusk"] = dusk
    self.chiller_prefs["night"] = night
end

function Hatchable:GetHeaterPref(phase)
    return self.heater_prefs[TheWorld.state.phase]
end

function Hatchable:GetChillerPref(phase)
    return self.chiller_prefs[TheWorld.state.phase]
end

local FIRE_MUST_TAGS = { "HASHEATER" }
local FIRE_MUST_NOT_TAGS = { "INLIMBO" }
function Hatchable:OnUpdate(dt)
    if self.delay then
        return
    end

    -- NOTES(JBK): The heater component allows many sources be able to act as heating or cooling elements.
    -- This hatchable component assumed only fire structures and wild fires could heat so this needs to change to take it into account.
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.HATCH_CAMPFIRE_RADIUS, FIRE_MUST_TAGS, FIRE_MUST_NOT_TAGS)
    local heatindex = 0
    for _, ent in ipairs(ents) do
        if ent.components.heater ~= nil and (ent.components.heater:IsExothermic() or ent.components.heater:IsEndothermic()) then -- Make sure they emit temperature.
            heatindex = heatindex + (ent.components.heater:GetHeat(self.inst) or 0) -- Cold fires produce negative heat.
        end
    end

    local wants_heater = self:GetHeaterPref()
    local has_heater = heatindex > 0

    local wants_chiller = self:GetChillerPref()
    local has_chiller = heatindex < 0

    local old_toohot, old_toocold = self.toohot, self.toocold
    self.toohot = false
    self.toocold = false

    if wants_heater ~= nil then
        if has_heater and not wants_heater then
            self.toohot = true
        elseif not has_heater and wants_heater then
            self.toocold = true
        end
    end

    if wants_chiller ~= nil then
        if has_chiller and not wants_chiller then
            self.toocold = true
        elseif not has_chiller and wants_chiller then
            self.toohot = true
        end
    end

    if self.state == "unhatched" then
        if has_heater and wants_heater or has_chiller and wants_chiller then
            self.progress = self.progress + dt
            if self.progress >= self.cracktime then
                self.progress = 0
                self:OnState("crack")
            end
        else
            self.progress = 0
        end
        return
    end

    if self.toohot or self.toocold then
        self:OnState("uncomfy", old_toohot ~= self.toohot or old_toocold ~= self.toocold)
    else
        self:OnState("comfy")
    end

    if self.state == "comfy" then
        self.discomfort = math.max(self.discomfort - dt, 0)
        if self.discomfort <= 0 then
            self.progress = self.progress + dt
        end

        if self.progress >= self.hatchtime then
            self:StopUpdating()
            self:OnState("hatch")
        end
    else
        self.discomfort = self.discomfort + dt
        if self.discomfort >= self.hatchfailtime then
            self:StopUpdating()
            self:OnState("dead")
        end
    end
end

function Hatchable:OnSave()
    --print("Hatchable:OnSave")
    local data =
    {
        state = self.state,
        progress = self.progress,
        discomfort = self.discomfort,
        toohot = self.toohot,
        toocold = self.toocold
    }
    --print("   state,progress,discomfort", data.state, data.progress, data.discomfort)
    return data
end

function Hatchable:OnLoad(data)
    --print("Hatchable:OnLoad")
    if data then
        self.state = data.state or "comfy"
        self.progress = data.progress or 0
        self.discomfort = data.discomfort or 0
        self.toohot = data.toohot or false
        self.toocold = data.toocold or false
    end
    --print("   state,progress,discomfort", self.state, self.progress, data.discomfort)

    if (self.state ~= "unhatched") and self.onstatefn then
        self.onstatefn(self.inst, self.state)
    end

    self:StartUpdating()
end

return Hatchable
