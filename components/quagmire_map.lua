function Map:IsFarmableSoilAtPoint(x, y, z)
    return self:GetTileAtPoint(x, y, z) == GROUND.QUAGMIRE_SOIL
end

function Map:CanTillSoilAtPoint(pt)
    return TheWorld.Map:IsFarmableSoilAtPoint(pt:Get())
        and #TheSim:FindEntities(pt.x, 0, pt.z, 1, { "plantedsoil" }) <= 0
end
