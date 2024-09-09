local COLORS =
{
    default =   { color={TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR[1] / 255,        TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR[2] / 255,         TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR[3] / 255,         TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR[4] / 255},        blend_delay=0, blend_speed=1.0, ocean_texture_blend = 0 },
    dusk =      { color={TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR_DUSK[1] / 255,   TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR_DUSK[2] / 255,    TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR_DUSK[3] / 255,    TUNING.OCEAN_SHADER.OCEAN_FLOOR_COLOR_DUSK[4] / 255},   blend_delay=0, blend_speed=0.1, ocean_texture_blend = 1 },
    night =     { color={0.0, 0.0, 0.0, 1.0}, blend_delay=6, blend_speed=0.1, ocean_texture_blend = 1 },
    no_ocean =  { color={0.0, 0.0, 0.0, 1.0}, blend_delay=6, blend_speed=0.1, ocean_texture_blend = 0 }
}

local OceanColor = Class(function(self, inst)
	self.inst = inst

    self.inst:ListenForEvent("phasechanged", function(src, phase) self:OnPhaseChanged(src, phase) end)

	self.inst:StartUpdatingComponent(self)
    self.start_color = shallowcopy(COLORS.default.color)
    self.current_color = shallowcopy(COLORS.default.color)
    self.end_color = shallowcopy(COLORS.default.color)
    self.start_ocean_texture_blend = COLORS.default.ocean_texture_blend
    self.current_ocean_texture_blend = COLORS.default.ocean_texture_blend
    self.end_ocean_texture_blend = COLORS.default.ocean_texture_blend
    self.lerp = 1
    self.lerp_delay = 0

    self.blend_delay = COLORS.default.blend_delay
    self.blend_speed = COLORS.default.blend_speed
end)

function OceanColor:Initialize(has_ocean)
    if has_ocean then
        self.inst:StartWallUpdatingComponent(self)
        TheWorld.Map:SetClearColor(COLORS.default.color[1], COLORS.default.color[2], COLORS.default.color[3], COLORS.default.color[4])
    else
        TheWorld.Map:SetClearColor(COLORS.no_ocean.color[1], COLORS.no_ocean.color[2], COLORS.no_ocean.color[3], COLORS.no_ocean.color[4])
    end
end

function OceanColor:OnPostInit()
	--V2C: Hack to force it dirty
	--     Was bugged on Clients when loading into daytime (blend = 0),
	--     which means it won't be dirty and correct itself until dusk.
	TheWorld.Map:SetOceanTextureBlendAmount(1)
	TheWorld.Map:SetOceanTextureBlendAmount(self.current_ocean_texture_blend)
end

function OceanColor:OnWallUpdate(dt)
    if self.lerp >= 1 then return end

    if self.lerp_delay < self.blend_delay then
        self.lerp_delay = math.min(self.lerp_delay + dt)
        if self.lerp_delay < self.blend_delay then
            return
        end
    end

    self.lerp = math.min(self.lerp + dt * self.blend_speed, 1)


    for i = 1,4 do
        self.current_color[i] = Lerp(self.start_color[i], self.end_color[i], self.lerp)
    end

    self.current_ocean_texture_blend = Lerp(self.start_ocean_texture_blend, self.end_ocean_texture_blend, self.lerp)

    local map = TheWorld.Map
    map:SetClearColor(self.current_color[1], self.current_color[2], self.current_color[3], self.current_color[4])
    map:SetOceanTextureBlendAmount(self.current_ocean_texture_blend)
end

function OceanColor:OnPhaseChanged(src, phase)
    local target_color = COLORS.default
    if COLORS[phase] ~= nil then
        target_color = COLORS[phase]
    end
    self.start_color[0] = self.current_color[0]
    self.start_color[1] = self.current_color[1]
    self.start_color[2] = self.current_color[2]
    self.start_color[3] = self.current_color[3]
    self.start_ocean_texture_blend = self.current_ocean_texture_blend
    self.end_ocean_texture_blend = target_color.ocean_texture_blend
    self.end_color = target_color.color
    self.lerp = 0
    self.lerp_delay = 0

    self.blend_delay = target_color.blend_delay
    self.blend_speed = target_color.blend_speed
end

return OceanColor
