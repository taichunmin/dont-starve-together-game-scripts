
-- these functions have moved into map.lua

function Map:IsFarmableSoilAtPoint(x, y, z)
    return self:GetTileAtPoint(x, y, z) == WORLD_TILES.QUAGMIRE_SOIL
end

local TILLSOILBLOCKED_MUST_TAGS = { "plantedsoil" }
function Map:CanTillSoilAtPoint(pt)
    return TheWorld.Map:IsFarmableSoilAtPoint(pt:Get())
        and #TheSim:FindEntities(pt.x, 0, pt.z, 1, TILLSOILBLOCKED_MUST_TAGS) <= 0
end
