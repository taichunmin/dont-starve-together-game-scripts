local function SpawnLightrays(inst)
    local self = inst.components.canopylightrays
    if self == nil then
        return
    end
    self:SpawnLightrays()
end

local CanopyLightrays = Class(function(self, inst)
    self.inst = inst

    self.range = math.floor(TUNING.SHADE_CANOPY_RANGE/4)
    self.lightray_prefab = "lightrays_canopy"

    self.lightray_positions = {}

    inst:DoTaskInTime(0, SpawnLightrays)
end)

function CanopyLightrays:OnRemoveEntity()
    self:DespawnLightrays()
end
CanopyLightrays.OnRemoveFromEntity = CanopyLightrays.OnRemoveEntity

Global_Lightrays = {}
local Lightrays = Global_Lightrays

function CanopyLightrays:SpawnLightrays()
    local x,y,z = self.inst.Transform:GetWorldPosition()
    for i = -self.range, self.range do
        for t = -self.range, self.range do
            if math.random() < 0.1 and ((t*t) + (i*i)) <= self.range*self.range then
                local newx = math.floor((x + i * 4) / 4) * 4 + 2
                local newz = math.floor((z + t * 4) / 4) * 4 + 2

                local lightray_key = newx.."-"..newz
                local lightray = Lightrays[lightray_key]
                if not lightray then
                    table.insert(self.lightray_positions, {newx, newz})
                    local ray = SpawnPrefab(self.lightray_prefab)
                    ray.Transform:SetPosition(newx, 0, newz)
                    ray.refs = 1
                    Lightrays[lightray_key] = ray
                else
                    lightray.refs = lightray.refs + 1
                end
            end
        end
    end
end

function CanopyLightrays:DespawnLightrays()
    for i, v in ipairs(self.lightray_positions) do
        local x, z = v[1], v[2]
        local lightray_key = x.."-"..z
        local lightray = Lightrays[lightray_key]
        lightray.refs = lightray.refs - 1
        if lightray.refs == 0 then
            lightray:Remove()
            Lightrays[lightray_key] = nil
        end
    end
end

return CanopyLightrays