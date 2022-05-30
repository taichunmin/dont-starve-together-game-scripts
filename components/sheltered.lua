local Sheltered = Class(function(self, inst)
    self.inst = inst

    self.stoptime = GetTime()
    self.presheltered = false
    self.sheltered = false
    self.announcecooldown = 0
    self.sheltered_level = 1
    self.mounted = false
    self.waterproofness = TUNING.WATERPROOFNESS_SMALLMED

    self:Start()
end)

function Sheltered:OnRemoveFromEntity()
    self:SetSheltered(false)
end

function Sheltered:Start()
    if self.stoptime ~= nil then
        self.announcecooldown = math.max(0, self.announcecooldown + self.stoptime - GetTime())
        self.stoptime = nil
        self.inst:StartUpdatingComponent(self)
    end
end

function Sheltered:Stop()
    if self.stoptime == nil then
        self.stoptime = GetTime()
        self.inst:StopUpdatingComponent(self)
        self:SetSheltered(false)
    end
end

function Sheltered:SetSheltered(issheltered, level)
    if self.mounted and level < 2 then
        issheltered = false
    end
    self.sheltered_level = level
    if not issheltered then
        if self.presheltered then
            self.presheltered = false
            self.inst.replica.sheltered:StopSheltered()
        end
        if self.sheltered then
            self.sheltered = false
            self.inst:PushEvent("sheltered", { sheltered=false, level=self.sheltered_level })
        end
    elseif not self.presheltered then
        self.presheltered = true
        self.inst.replica.sheltered:StartSheltered()
    elseif not self.sheltered and self.inst.replica.sheltered:IsSheltered() then
        self.sheltered = true
        self.inst:PushEvent("sheltered", { sheltered=true, level=self.sheltered_level })
        if self.announcecooldown <= 0 and (TheWorld.state.israining or TheWorld.state.temperature >= TUNING.OVERHEAT_TEMP - 5) then
            self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_SHELTER"))
            self.announcecooldown = TUNING.TOTAL_DAY_TIME
        end
    end
end

local SHELTERED_MUST_TAGS = { "shelter" }
local SHELTERED_CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "stump", "burnt" }
local SHADECANOPY_MUST_TAGS = {"shadecanopy"}
local SHADECANOPY_SMALL_MUST_TAGS = {"shadecanopysmall"}
function Sheltered:OnUpdate(dt)
    local sheltered = false
    local level = 1    
    self.announcecooldown = math.max(0, self.announcecooldown - dt)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 2, SHELTERED_MUST_TAGS, SHELTERED_CANT_TAGS)
    if #ents > 0 then        
        sheltered = true
    end

    local canopy = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, SHADECANOPY_MUST_TAGS)
    local canopy_small = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE_SMALL, SHADECANOPY_SMALL_MUST_TAGS)
    if #canopy > 0 or #canopy_small > 0 then
        sheltered = true
        level = 2
    end

    self:SetSheltered(sheltered, level)
end

function Sheltered:GetDebugString()
    return string.format("%s, shletered: %s, presheltered: %s", self.stoptime == nil and "STARTED" or "STOPPED", tostring(self.sheltered), tostring(self.presheltered))
end

return Sheltered