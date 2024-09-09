local function GenerateAndSpawnCanopyShadowPositions(inst)
    local self = inst.components.canopyshadows
    if self == nil then
        return
    end
    self:GenerateCanopyShadowPositions()
    self:SpawnShadows()
end

local CanopyShadows = Class(function(self, inst)
    self.inst = inst

    self.range = math.floor(TUNING.SHADE_CANOPY_RANGE/4)

    self.canopy_positions = {}
    self.spawned = false

    inst:DoTaskInTime(0, GenerateAndSpawnCanopyShadowPositions)
end)

function CanopyShadows:OnRemoveEntity()
    self:DespawnShadows(true)
    self:RemoveCanopyShadowPositions()
end
CanopyShadows.OnRemoveFromEntity = CanopyShadows.OnRemoveEntity

Global_Canopyshadows = {}
local Canopyshadows = Global_Canopyshadows

function CanopyShadows:GenerateCanopyShadowPositions()
    local x,y,z = self.inst.Transform:GetWorldPosition()
    for i = -self.range, self.range do
        for t = -self.range, self.range do
            if math.random() < 0.8 and ((t*t) + (i*i)) <= self.range*self.range then
                local newx = math.floor((x + i * 4) / 4) * 4 + 2
                local newz = math.floor((z + t * 4) / 4) * 4 + 2

                table.insert(self.canopy_positions, { newx, newz })

                local shadetile_key = newx.."-"..newz
                local shadetile = Canopyshadows[shadetile_key]

                if not shadetile then
                    Canopyshadows[shadetile_key] = {refs = 1, spawnrefs = 0}
                else
                    shadetile.refs = shadetile.refs + 1
                end
            end
        end
    end
end

function CanopyShadows:RemoveCanopyShadowPositions()
    for i, v in ipairs(self.canopy_positions) do
        local x, z = v[1], v[2]
        local shadetile_key = x.."-"..z
        local shadetile = Canopyshadows[shadetile_key]
        shadetile.refs = shadetile.refs - 1
        if shadetile.refs == 0 then
            Canopyshadows[shadetile_key] = nil
        end
    end
end

function CanopyShadows:OnEntitySleep()
    if not IsTableEmpty(self.canopy_positions) then
        self:DespawnShadows()
    end
end

function CanopyShadows:OnEntityWake()
    if not IsTableEmpty(self.canopy_positions) then
        self:SpawnShadows()
    end
end

function CanopyShadows:SpawnShadows()
    if self.spawned or not self.inst.entity:IsAwake() then return end

    for i, v in ipairs(self.canopy_positions) do
        local x, z = v[1], v[2]
        local shadetile = Canopyshadows[x.."-"..z]
        shadetile.spawnrefs = shadetile.spawnrefs + 1
        if shadetile.spawnrefs == 1 then
            shadetile.id = SpawnLeafCanopy(x, z)
        end
    end

    self.spawned = true
end

function CanopyShadows:DespawnShadows(ignore_entity_sleep)
    if not self.spawned or (not ignore_entity_sleep and self.inst.entity:IsAwake()) then return end

    for i, v in ipairs(self.canopy_positions) do
        local x, z = v[1], v[2]
        local shadetile = Canopyshadows[x.."-"..z]
        shadetile.spawnrefs = shadetile.spawnrefs - 1
        if shadetile.spawnrefs == 0 then
            DespawnLeafCanopy(shadetile.id)
            shadetile.id = nil
        end
    end

    self.spawned = false
end

return CanopyShadows