
function CalculateFiveRadius(density)
    -- we don't want even density, clumping is allowed. For that reason, we
    -- want to do density per 5 entities, rather than per 1 -- hence fiveradius
    local searcharea = 2* 16 * 5 / density -- 16, because each tile from worldgen is 4x4 game units. 2* because it seems to look correct in the end but I don't know why! ~gjans
    return math.sqrt(searcharea/math.pi)
end

function GetFiveRadius(x, z, prefab)
    local area = nil
    for i, node in ipairs(TheWorld.topology.nodes) do
        if TheSim:WorldPointInPoly(x, z, node.poly) then
            area = i
            break
        end
    end

    if
        --print("ACK! We couldn't figure out what area we're in!")
        area == nil
        -- Old save game, doesn't have original generation data. Abort!
        or TheWorld.generated == nil
        -- Probably some kind of special node like a blocker, doesn't have generated contents anyways.
        or TheWorld.topology.ids[area] == nil or TheWorld.generated.densities[TheWorld.topology.ids[area]] == nil
        then

        return
    end

    local density = TheWorld.generated.densities[TheWorld.topology.ids[area]][prefab]
    if density == nil then
        -- we can't even regrow in this area! stop trying.
        return
    end
    return CalculateFiveRadius(density)
end
