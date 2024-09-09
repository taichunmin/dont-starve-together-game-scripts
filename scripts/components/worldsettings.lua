local function OnSetWorldSetting(world, data)
    local worldsettings = world.components.worldsettings
    if worldsettings then
        worldsettings:SetSetting(data.setting, data.value)
    end
end

local WorldSettings = Class(function(self, inst)
    self.inst = inst

    self.settings = {}

    inst:ListenForEvent("ms_setworldsetting", OnSetWorldSetting)
end)

function WorldSettings:GetSetting(setting)
    return self.settings[setting]
end

function WorldSettings:SetSetting(setting, value)
    self.settings[setting] = value
end

return WorldSettings