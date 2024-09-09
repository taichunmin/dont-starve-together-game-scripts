require "prefabutil"
require "maputil"
require "vecutil"
require "datagrid"

local WIDTH = 0
local HEIGHT = 0
local WORLDSIM = nil
local ENTITIES = nil
local DOCK_POST_CHANCE = nil
local RANDOM_DOCK_PREFABS = nil
local RANDOM_ENDPOINT_PREFABS = nil
local GENERATED_DOCK_LIST = nil

local DOCK_SAFETY_MINX = 0
local DOCK_SAFETY_MAXX = 0
local DOCK_SAFETY_MINZ = 0
local DOCK_SAFETY_MAXZ = 0

local TESTED_TILES = nil
local function assign_and_test_tile(x, z)
    TESTED_TILES[x][z] = TESTED_TILES[x][z] or WORLDSIM:GetTile(x, z)

    return TESTED_TILES[x][z] ~= WORLD_TILES.MONKEY_DOCK and not IsOceanTile(TESTED_TILES[x][z])
end

--Checks if we're not accidentally creating a land bridge
local function ValidateSurroundingTiles(x, z)
    if TESTED_TILES[x+1] == nil then
        TESTED_TILES[x+1] = {}
    end
    if assign_and_test_tile(x+1, z-1) then return false end
    if assign_and_test_tile(x+1, z)   then return false end
    if assign_and_test_tile(x+1, z+1) then return false end

    if TESTED_TILES[x] == nil then
        TESTED_TILES[x] = {}
    end
    if assign_and_test_tile(x, z-1) then return false end
    if assign_and_test_tile(x, z+1) then return false end

    if TESTED_TILES[x-1] == nil then
        TESTED_TILES[x-1] = {}
    end
    if assign_and_test_tile(x-1, z-1) then return false end
    if assign_and_test_tile(x-1, z)   then return false end
    if assign_and_test_tile(x-1, z+1) then return false end

    return true
end

local function IsPointInSafeDockRange(x, z)
    return (x > DOCK_SAFETY_MINX and x < DOCK_SAFETY_MAXX)
        and (z > DOCK_SAFETY_MINZ and z < DOCK_SAFETY_MAXZ)
end

local function GenBranch(orientation, start_x, start_z, is_on_x, dir, min_length, max_length, branch_chance_r, branch_chance_l)
    -- Breaks the recursion
    if min_length < 1 then
        return
    end

    local dock_length = math.random(min_length, max_length)
    local x = start_x
    local z = start_z

    branch_chance_r = branch_chance_r or 0.25
    branch_chance_l = branch_chance_l or 0.25

    for i = 1, dock_length do
        if is_on_x then
            if orientation == "right" and dir == -1 then
                -- We can either flip the direction here, or cancel the branch
                -- Currently canceling the branch yields better results
                --dir = 1
                return
            elseif orientation == "left" and dir == 1 then
                --dir = -1
                return
            end

            x = x + dir
        else
            if orientation == "up" and dir == -1 then
                --dir = 1
                return
            elseif orientation == "down" and dir == 1 then
                --dir = -1
                return
            end

            z = z + dir
        end

        -- The dock should not go back inland
        local tile = WORLDSIM:GetTile(x, z)
        if not IsPointInSafeDockRange(x, z)
                or not IsOceanTile(tile)
                or not ValidateSurroundingTiles(x, z) then
            return
        else
            WORLDSIM:SetTile(x, z, WORLD_TILES.MONKEY_DOCK)

            GENERATED_DOCK_LIST:SetDataAtPoint(x, z, false)

            local mid_x = TILE_SCALE * (x - WIDTH/2)
            local mid_z = TILE_SCALE * (z - HEIGHT/2)
            ENTITIES["dock_tile_registrator"] = ENTITIES["dock_tile_registrator"] or {}
            table.insert(ENTITIES["dock_tile_registrator"], {
                x = mid_x, z = mid_z,
                data = { undertile = "OCEAN_COASTAL", },
            })

            if RANDOM_DOCK_PREFABS ~= nil then
                local prefab_rand = math.random()
                local dock_prefab = nil
                for prefab_type, chance in pairs(RANDOM_DOCK_PREFABS) do
                    prefab_rand = prefab_rand - chance
                    if prefab_rand <= 0 then
                        dock_prefab = prefab_type
                        break
                    end
                end

                if dock_prefab ~= nil then
                    if ENTITIES[dock_prefab] == nil then
                        ENTITIES[dock_prefab] = {}
                    end
                    table.insert(ENTITIES[dock_prefab], {
                        x = GetRandomWithVariance(mid_x, 1.8),
                        z = GetRandomWithVariance(mid_z, 1.8)
                    })
                end
            end
        end

        -- See if we should recursively generate branches
        local twothird_minlength = min_length-(min_length/3)
        local twothird_maxlength = max_length-(max_length/3)
        if math.random() < branch_chance_r then
            GenBranch(orientation, x, z, not is_on_x, 1, twothird_minlength, twothird_maxlength, branch_chance_r/2, branch_chance_l/2)
            branch_chance_r = branch_chance_r - 0.05
        end
        if math.random() < branch_chance_l then
            GenBranch(orientation, x, z, not is_on_x, -1, twothird_minlength, twothird_maxlength, branch_chance_r/2, branch_chance_l/2)
            branch_chance_l = branch_chance_l - 0.05
        end
    end

    -- Data marked "true" is the endpoint of a branch.
    GENERATED_DOCK_LIST:SetDataAtPoint(x, z, true)
end

local function NewGen(starting_positions)
    for _, start in ipairs(starting_positions) do
        GenBranch(start.orientation, start.x, start.z, start.is_on_x, start.dir, TUNING.MONKEYISLANDGEN_DOCKMINLENGTH, TUNING.MONKEYISLANDGEN_DOCKMAXLENGTH)
    end
end

local function generate_starting_points(center_x, center_z, direction_entity)
    local starting_positions = {}

    local bottom_x, bottom_z = direction_entity.x, direction_entity.z

    -- Figures out which way the island is rotated on the map so we can make sure the docks only grow in the right direction
    local orientation = (center_x > bottom_x and "right") or "left"
    if math.floor(center_x) == math.floor(bottom_x) then
        orientation = (center_z > bottom_z and "up") or "down"
    end

    -- Convert the center values from world to grid position, for tile operations.
    center_x = math.floor(math.abs( ( ( center_x + TILE_SCALE / 2 ) + ( TILE_SCALE * WIDTH ) / 2 ) / TILE_SCALE ))
    center_z = math.floor(math.abs( ( ( center_z + TILE_SCALE / 2 ) + ( TILE_SCALE * HEIGHT) / 2 ) / TILE_SCALE ))

    for i=1, TUNING.MONKEYISLANDGEN_DOCKAMOUNT do
        -- Generate x and z as offsets from the center position
        local x = center_x + math.random(-4, 4)
        local z = center_z + math.random(-4, 4)

        -- Pick random direction and axis
        local is_on_x = math.random() > 0.5
        local dir = (math.random() > 0.5 and 1) or -1

        local tile = WORLDSIM:GetTile(x, z)

        -- Keep moving until we find the ocean
        while not IsOceanTile(tile) do
            if is_on_x then
                x = x + dir
            else
                z = z + dir
            end

            tile = WORLDSIM:GetTile(x, z)
        end

        -- Checks if our starting point is next to an already placed dock
        local dock_adjacent = ( WORLDSIM:GetTile(x + 1, z) == WORLD_TILES.MONKEY_DOCK or
                                WORLDSIM:GetTile(x - 1, z) == WORLD_TILES.MONKEY_DOCK or
                                WORLDSIM:GetTile(x, z + 1) == WORLD_TILES.MONKEY_DOCK or
                                WORLDSIM:GetTile(x, z - 1) == WORLD_TILES.MONKEY_DOCK )

        -- If so, retry generation
        if dock_adjacent then
            i = i - 1
        else
            table.insert(starting_positions, {x=x, z=z, is_on_x = is_on_x, dir = dir, orientation = orientation})

            WORLDSIM:SetTile(x, z, WORLD_TILES.MONKEY_DOCK)

            local world_x = TILE_SCALE * (x - WIDTH/2)
            local world_z = TILE_SCALE * (z - HEIGHT/2)

            ENTITIES["dock_tile_registrator"] = ENTITIES["dock_tile_registrator"] or {}
            table.insert(ENTITIES["dock_tile_registrator"], {
                x = world_x, z = world_z,
                data = { undertile = "OCEAN_COASTAL_SHORE", },
            })
        end
    end

    return starting_positions
end

local function try_make_post(tile_x, tile_z, offx, offz, chance)
    if math.random() < chance and IsOceanTile(WORLDSIM:GetTile(tile_x + offx, tile_z + offz)) then
        local mid_x = TILE_SCALE * (tile_x - WIDTH/2)
        local mid_z = TILE_SCALE * (tile_z - HEIGHT/2)

        -- Pull the posts slightly inward so they get picked up properly by GetEntitiesOnTileAtPoint in dockmanager.
        local post_x = mid_x + offx * (TILE_SCALE/2 - 0.2)
        local post_z = mid_z + offz * (TILE_SCALE/2 - 0.2)

        table.insert(ENTITIES["dock_woodposts"], {x = post_x, z = post_z, })
    end
end

-- prefabs_data is:
--      center_prefab                   -- A prefab indicating the center of the island, for orientation
--      direction_prefab                -- A prefab that determines which direction from the center. Should be paired with center_prefabs 1-to-1.
--      safety_prefab                   -- A prefab with x, z, .width and .height indicating the safe area for docks to generate to stay within the setpiece bounds.
--      dock_post_chance                -- The chance of a dock getting posts spawned on it.
--      dock_prefabs_withchance         -- Prefabs to spawn on the dock. Can be nil, or a key-value table of prefab name : chance out of 1.00 (keep total at-or-below 1.00)
--      endpoint_prefabs_with_chance    -- Prefabs to spawn on endpoint tiles when they're mostly surrounded by water.
--                                      -- The spawned prefab gets passed save data with "data.autogenerated = true"
function GenerateDocks(world, entities, map_width, map_height, prefabs_data)
    WIDTH = map_width
    HEIGHT = map_height
    WORLDSIM = world
    ENTITIES = entities
    DOCK_POST_CHANCE = prefabs_data.dock_post_chance
    RANDOM_DOCK_PREFABS = prefabs_data.dock_prefabs_withchance
    RANDOM_ENDPOINT_PREFABS = prefabs_data.endpoint_prefabs_with_chance

    TESTED_TILES = {}

    local center_prefab = prefabs_data.center_prefab
    
    local center_entities = ENTITIES[center_prefab]
    if center_entities ~= nil then
        local direction_prefab = prefabs_data.direction_prefab

        for center_ent_index, center_entity in ipairs(center_entities) do
            GENERATED_DOCK_LIST = DataGrid(WIDTH, HEIGHT)

            local center_x, center_z = center_entity.x, center_entity.z

            -- Assume our center and direction prefabs are paired 1-to-1
            local direction_entity = ENTITIES[direction_prefab][center_ent_index]

            local safety_prefab_savedata = ENTITIES[prefabs_data.safety_prefab][center_ent_index]
            if safety_prefab_savedata ~= nil then
                local safety_tile_x = math.floor(math.abs( ( ( safety_prefab_savedata.x + TILE_SCALE / 2 ) + ( TILE_SCALE * WIDTH ) / 2 ) / TILE_SCALE ))
                local safety_tile_z = math.floor(math.abs( ( ( safety_prefab_savedata.z + TILE_SCALE / 2 ) + ( TILE_SCALE * HEIGHT) / 2 ) / TILE_SCALE ))
                DOCK_SAFETY_MINX = safety_tile_x - (safety_prefab_savedata.data.width / 2)
                DOCK_SAFETY_MAXX = safety_tile_x + (safety_prefab_savedata.data.width / 2)
                DOCK_SAFETY_MINZ = safety_tile_z - (safety_prefab_savedata.data.height / 2)
                DOCK_SAFETY_MAXZ = safety_tile_z + (safety_prefab_savedata.data.height / 2)
            end

            local starting_positions = generate_starting_points(center_x, center_z, direction_entity)

            NewGen(starting_positions)

            -- Need to do pairs b/c this is a non-contiguous array, despite the index : data layout.
            for tile_index, is_endpoint in pairs(GENERATED_DOCK_LIST.grid) do
                local ex, ez = tile_index % WIDTH, math.floor(tile_index / WIDTH)

                if DOCK_POST_CHANCE and DOCK_POST_CHANCE > 0 then
                    ENTITIES["dock_woodposts"] = ENTITIES["dock_woodposts"] or {}
                    try_make_post(ex, ez, 1, 0, DOCK_POST_CHANCE)
                    try_make_post(ex, ez, -1, 0, DOCK_POST_CHANCE)
                    try_make_post(ex, ez, 0, 1, DOCK_POST_CHANCE)
                    try_make_post(ex, ez, 0, -1, DOCK_POST_CHANCE)
                end

                if is_endpoint and RANDOM_ENDPOINT_PREFABS ~= nil then
                    local endpoint_prefab_rand = math.random()
                    local endpoint_prefab = nil
                    for prefab_type, chance in pairs(RANDOM_ENDPOINT_PREFABS) do
                        endpoint_prefab_rand = endpoint_prefab_rand - chance
                        if endpoint_prefab_rand <= 0 then
                            endpoint_prefab = prefab_type
                            break
                        end
                    end

                    if endpoint_prefab ~= nil then
                        local nearby_water = 0
                        for xo = -1, 1, 1 do
                            for zo = -1, 1, 1 do
                                if (xo ~= 0 or zo ~= 0)
                                        and IsOceanTile(WORLDSIM:GetTile(ex + xo, ez + zo)) then
                                    nearby_water = nearby_water + 1
                                end
                            end
                        end

                        if nearby_water >= 7 then
                            local mid_x = TILE_SCALE * (ex - WIDTH/2)
                            local mid_z = TILE_SCALE * (ez - HEIGHT/2)
        
                            ENTITIES[endpoint_prefab] = ENTITIES[endpoint_prefab] or {}

                            table.insert(ENTITIES[endpoint_prefab], {
                                x = mid_x, z = mid_z,
                                data = {
                                    autogenerated = true,
                                },
                            })
                        end
                    end
                end
            end

            GENERATED_DOCK_LIST = nil
        end
    end

    TESTED_TILES = nil

    DOCK_SAFETY_MINX = 0
    DOCK_SAFETY_MAXX = 0
    DOCK_SAFETY_MINZ = 0
    DOCK_SAFETY_MAXZ = 0

    WIDTH = nil
    HEIGHT = nil
    ENTITIES = nil
    WORLDSIM = nil
    DOCK_POST_CHANCE = nil
    RANDOM_DOCK_PREFABS = nil
    RANDOM_ENDPOINT_PREFABS = nil
end

local MONKEYISLAND_PREFABSDATA =
{
    center_prefab = "monkeyisland_center",
    direction_prefab = "monkeyisland_direction",
    safety_prefab = "monkeyisland_dockgen_safeareacenter",
    dock_post_chance = 0.40,
    dock_prefabs_withchance = {
        monkeyhut           = 0.06,
        pirate_flag_pole    = 0.03,
    },
    endpoint_prefabs_with_chance = {
        boat_cannon = TUNING.MONKEYISLANDGEN_CANNONCHANCE,
    },
}
function MonkeyIsland_GenerateDocks(world, entities, map_width, map_height)
    GenerateDocks(world, entities, map_width, map_height, MONKEYISLAND_PREFABSDATA)
end