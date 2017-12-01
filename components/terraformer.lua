local GroundTiles = require("worldtiledefs")

local Terraformer = Class(function(self, inst)
    self.inst = inst
end)

function Terraformer:Terraform(pt, spawnturf)
    local world = TheWorld
    local map = world.Map
    if not world.Map:CanTerraformAtPoint(pt:Get()) then
        return false
    end

    local original_tile_type = map:GetTileAtPoint(pt:Get())
    local x, y = map:GetTileCoordsAtPoint(pt:Get())

    map:SetTile(x, y, GROUND.DIRT)
    map:RebuildLayer(original_tile_type, x, y)
    map:RebuildLayer(GROUND.DIRT, x, y)

    world.minimap.MiniMap:RebuildLayer(original_tile_type, x, y)
    world.minimap.MiniMap:RebuildLayer(GROUND.DIRT, x, y)

    spawnturf = spawnturf and GroundTiles.turf[original_tile_type] or nil
    if spawnturf ~= nil then
        local loot = SpawnPrefab("turf_"..spawnturf.name)
        if loot.components.inventoryitem ~= nil then
            loot.components.inventoryitem:InheritMoisture(world.state.wetness, world.state.iswet)
        end
        loot.Transform:SetPosition(pt:Get())
        if loot.Physics ~= nil then
            local angle = math.random() * 2 * PI
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
        end
    else
        SpawnPrefab("sinkhole_spawn_fx_"..tostring(math.random(3))).Transform:SetPosition(pt:Get())
    end

    return true
end

return Terraformer
