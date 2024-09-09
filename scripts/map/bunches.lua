

local BunchBlockers =
{

}

local Bunches =
{
    seastack_spawner_swell = {
        prefab = "seastack",
        range = 50,
        min = 30,
        max = 50,
        min_spacing = 8,
        valid_tile_types = {
            WORLD_TILES.OCEAN_SWELL,
        },
    },
    seastack_spawner_rough = {
        prefab = "seastack",
        range = 30,
        min = 15,
        max = 25,
        min_spacing = 4,
        valid_tile_types = {
            WORLD_TILES.OCEAN_ROUGH,
        },
    },
    saltstack_spawner_rough = {
        prefab = "saltstack",
        range = 12,
        min = 6,
        max = 9,
        min_spacing = 5,
        valid_tile_types = {
            WORLD_TILES.OCEAN_ROUGH,
        },
    },
    wobster_den_spawner_shore = {
        prefab = function(world, spawnerx, spawnerz)
            for _z = 1, -1, -1 do
                for _x = -1, 1 do
                    local x = spawnerx + (_x * 4)
                    local z = spawnerz + (_z * 4)
                    local tile = world:GetTile(x, z)

                    -- We reject INVALID and IMPASSABLE out of hand.
                    -- ROCKY can appear on the mainland or moon island, so we have to look for something else.
                    if not TileGroupManager:IsInvalidTile(tile) and tile ~= WORLD_TILES.ROCKY then
                        if tile == WORLD_TILES.PEBBLEBEACH or tile == WORLD_TILES.METEOR or tile == WORLD_TILES.SHELLBEACH then
                            return "moonglass_wobster_den"
                        elseif not IsOceanTile(tile) then
                            return "wobster_den"
                        end
                    end
                end
            end

            return nil
        end,
        range = 12,
        min = 4,
        max = 5,
        min_spacing = 3,
        valid_tile_types = {
            WORLD_TILES.OCEAN_COASTAL,
        },
    },
    waterplant_spawner_rough =
    {
        prefab = "waterplant",
        range = 30,
        min = 8,
        max = 15,
        min_spacing = 7,
        valid_tile_types = {
            WORLD_TILES.OCEAN_ROUGH,
            WORLD_TILES.OCEAN_SWELL, -- Plants can "spill over" to swell waters.
        },
    },

    rubble1 = {
        prefab = "rock1",
        range = 25,
        min = 1000,
        max = 1000,
        min_spacing = 3,
        valid_tile_types = {
            WORLD_TILES.DIRT,
        },
    },

    rubble2 = {
        prefab = "cavein_boulder",
        range = 25,
        min = 500,
        max = 500,
        min_spacing = 2,
        valid_tile_types = {
            WORLD_TILES.DIRT,
        },
    },
}

return
{
    Bunches = Bunches,
    BunchBlockers = BunchBlockers,
}