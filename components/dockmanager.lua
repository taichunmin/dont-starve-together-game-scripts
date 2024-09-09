--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ DockManager class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "DockManager should not exist on client")

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _world = TheWorld
local _map = _world.Map

-- a data grid that identifies whether a tile is a root tile or not.
local _is_root_grid = nil

-- a data grid that stores tiles marked for delete.
local _marked_for_delete_grid = nil

-- a data grid storing a "health" value for each dock tile
local _dock_health_grid = nil

-- a data grid storing the damage prefabs
local _dock_damage_prefabs_grid = nil

local WIDTH = nil
local HEIGHT = nil

--------------------------------------------------------------------------
--[[ Private functions ]]
--------------------------------------------------------------------------
local function land_test(tile)
    return (tile ~= WORLD_TILES.MONKEY_DOCK) and (TileGroupManager:IsLandTile(tile))
end

local function tile_is_a_root(x, y)
    local tile_to_test = _map:GetTile(x, y)
    return TileGroupManager:IsLandTile(tile_to_test) and tile_to_test ~= WORLD_TILES.MONKEY_DOCK
end

local function generate_dock_data(tile_x, tile_y)
    local dock_is_root = false

    for xoffset = -1, 1, 1 do
        for yoffset = -1, 1, 1 do
            if xoffset ~= 0 or yoffset ~= 0 then
                if tile_is_a_root(tile_x + xoffset, tile_y + yoffset) then
                    dock_is_root = true
                end
            end
        end
    end

    return dock_is_root
end

local function initialize_grids()
    if _is_root_grid ~= nil and _marked_for_delete_grid ~= nil and _dock_health_grid ~= nil then
        return
    end

    WIDTH, HEIGHT = _map:GetSize()

    _is_root_grid = DataGrid(WIDTH, HEIGHT)
    _marked_for_delete_grid = DataGrid(WIDTH, HEIGHT)
    _dock_health_grid = DataGrid(WIDTH, HEIGHT)
    _dock_damage_prefabs_grid = DataGrid(WIDTH, HEIGHT)
end
inst:ListenForEvent("worldmapsetsize", initialize_grids, _world)

local function toss_debris(debris_prefab, dx, dz)
    local dock_debris = SpawnPrefab(debris_prefab)
    dock_debris.Physics:Teleport(dx, 0.1, dz)

    local debris_angle = TWOPI*math.random()
    local debris_speed = 2.5 + 2*math.random()
    dock_debris.Physics:SetVel(debris_speed * math.cos(debris_angle), 10, debris_speed * math.sin(debris_angle))
end

-- A breadth-first search that looks for a root node (a dock adjacent to land).
local function bfs_for_root(start_xy, visited)
    local found_root = false

    local to_visit_queue = {start_xy}
    local queue_index = 1
    while queue_index <= #to_visit_queue do
        local next_xy = to_visit_queue[queue_index]
        queue_index = queue_index + 1

        -- If this point has already been visited, we can cut this branch of the search.
        local next_visiteddata = visited:GetDataAtIndex(next_xy)
        if next_visiteddata == nil then
            local next_isroot = _is_root_grid:GetDataAtIndex(next_xy)

            visited:SetDataAtIndex(next_xy, false)

            if next_isroot then
                found_root = true
                break
            end

            local nx, ny = visited:GetXYFromIndex(next_xy)
            for off_x = -1, 1, 1 do
                for off_y = -1, 1, 1 do
                    if off_x ~= 0 or off_y ~= 0 then
                        local adjacent = visited:GetIndex(nx + off_x, ny + off_y)

                        -- We would test this in the next loop, but this keeps our visited queue minimal.
                        local adjacent_visited_data = visited:GetDataAtIndex(adjacent)
                        if adjacent_visited_data == nil
                                and _is_root_grid:GetDataAtIndex(adjacent) ~= nil then
                            table.insert(to_visit_queue, adjacent)
                        elseif adjacent_visited_data == true then
                            found_root = true
                            break
                        end
                    end
                end

                if found_root then break end
            end
        end
    end

    if found_root then
        for i = 1, queue_index - 1 do
            visited:SetDataAtIndex(to_visit_queue[i], true)
        end
    end

    return found_root
end

local function destroy_dock_at_point(world, dx, dz, dockmanager, dont_toss_loot)
    dockmanager:DestroyDockAtPoint(dx, 0, dz, dont_toss_loot)
end

local function start_destroy_for_tile(_, txy, wid, dockmanager)
    local center_x, center_y, center_z = _map:GetTileCenterPoint(txy % wid, math.floor(txy / wid))

    dockmanager:QueueDestroyForDockAtPoint(center_x, center_y, center_z)
end

local function test_for_destroy_at_point(txy, visited, dockmanager)
    local should_delete = false

    -- If this got a visited value of true, it touches a root and shouldn't break.
    if visited:GetDataAtIndex(txy) ~= true then
        -- The BFS returns whether a root is connected to this node.
        -- So, we delete when there is NOT a root.
        should_delete = not bfs_for_root(txy, visited)
    end

    if should_delete and not _marked_for_delete_grid:GetDataAtIndex(txy) then
        _marked_for_delete_grid:SetDataAtIndex(txy, true)

        _world:DoTaskInTime(math.random(1, 10)*FRAMES, start_destroy_for_tile, txy, WIDTH, dockmanager)

        return true
    end

    return false
end

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

function self:_TestForBreaking(test_tiles)
    -- Grid of tile_xy : marked-for-delete
    local visited = DataGrid(WIDTH, HEIGHT)

    local any_destroyed = false

    for _, tile_xy in ipairs(test_tiles) do
        if test_for_destroy_at_point(tile_xy, visited, self) then
            any_destroyed = true
        end
    end

    return any_destroyed
end

function self:_GenerateDockDataForPoint(x, y, z)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    self:_GenerateDockDataForTile(tile_x, tile_y)
end

function self:_GenerateDockDataForTile(tile_x, tile_y)
    _is_root_grid:SetDataAtPoint(tile_x, tile_y, generate_dock_data(tile_x, tile_y))
    _dock_health_grid:SetDataAtPoint(tile_x, tile_y, TUNING.MONKEYISLANDDOCK_HEALTH)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:CreateDockAtPoint(x, y, z, dock_tile_type)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    return self:CreateDockAtTile(tile_x, tile_y, dock_tile_type)
end

function self:CreateDockAtTile(tile_x, tile_y, dock_tile_type)
    local current_tile = nil
    local undertile = _world.components.undertile
    if undertile ~= nil then
        current_tile = _map:GetTile(tile_x, tile_y)
    end

    _map:SetTile(tile_x, tile_y, dock_tile_type)

    -- V2C: Because of a terraforming callback in farming_manager.lua, the undertile gets cleared during SetTile.
    --      We can circumvent this for now by setting the undertile after SetTile.
    if undertile ~= nil and current_tile ~= nil then
        undertile:SetTileUnderneath(tile_x, tile_y, current_tile)
    end

    self:_GenerateDockDataForTile(tile_x, tile_y)

    return true
end

local IGNORE_DOCK_DROWNING_ONREMOVE_TAGS = { "ignorewalkableplatforms", "ignorewalkableplatformdrowning", "activeprojectile", "flying", "FX", "DECOR", "INLIMBO" }
function self:DestroyDockAtPoint(x, y, z, dont_toss_loot)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local tile = _map:GetTile(tile_x, tile_y)
    if tile ~= WORLD_TILES.MONKEY_DOCK then
        return false
    end

    local index = _dock_damage_prefabs_grid:GetIndex(tile_x, tile_y)
    local dock_damage = _dock_damage_prefabs_grid:GetDataAtIndex(index)
    if dock_damage then
        _dock_damage_prefabs_grid:SetDataAtIndex(index,nil)
        dock_damage:Remove()
    end

    local old_tile = WORLD_TILES.OCEAN_COASTAL

    if _world.components.undertile ~= nil then
        old_tile = _world.components.undertile:GetTileUnderneath(tile_x, tile_y)
        if old_tile ~= nil then
            _world.components.undertile:ClearTileUnderneath(tile_x, tile_y)
        else
            old_tile = WORLD_TILES.OCEAN_COASTAL
        end
    end

    _map:SetTile(tile_x, tile_y, old_tile)

    local grid_index = _is_root_grid:GetIndex(tile_x, tile_y)
    _is_root_grid:SetDataAtIndex(grid_index, nil)
    _marked_for_delete_grid:SetDataAtIndex(grid_index, nil)
    _dock_health_grid:SetDataAtIndex(grid_index, nil)

    -- If we're swapping to an ocean tile, do like a broken boat would do and deal with everything in our tile bounds
    if IsOceanTile(old_tile) then
        -- Behaviour pulled from walkableplatform's onremove/DestroyObjectsOnPlatform response.
        local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
        local entities_near_dock = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_DOCK_DROWNING_ONREMOVE_TAGS)

        local shore_point = nil
        for _, ent in ipairs(entities_near_dock) do
            local has_drownable = (ent.components.drownable ~= nil)
            if has_drownable and shore_point == nil then
                shore_point = Vector3(FindRandomPointOnShoreFromOcean(x, y, z))
            end
            ent:PushEvent("onsink", {boat = nil, shore_pt = shore_point})

            -- We're testing the overhang, so we need to verify that anything we find isn't
            -- still on some adjacent dock or land tile after we remove ourself.
            if ent ~= inst and ent:IsValid() and not has_drownable and ent.entity:GetParent() == nil
                and ent.components.amphibiouscreature == nil
                and not _map:IsVisualGroundAtPoint(ent.Transform:GetWorldPosition()) then

                if ent.components.inventoryitem ~= nil then
                    ent.components.inventoryitem:SetLanded(false, true)
                else
                    DestroyEntity(ent, _world, true, true)
                end
            end
        end
    end

    -- Now collect all of the adjacent tiles (that have graph data) and check if
    -- they've been disconnected and need to break too.
    local adjacent_docks_to_removed_tile = {}
    for off_x = -1, 1, 1 do
        for off_y = -1, 1, 1 do
            if (off_x ~= 0 or off_y ~= 0) then
                local adj_x, adj_y = tile_x + off_x, tile_y + off_y
                if _is_root_grid:GetDataAtPoint(adj_x, adj_y) ~= nil then
                    table.insert(adjacent_docks_to_removed_tile, _is_root_grid:GetIndex(adj_x, adj_y))
                end
            end
        end
    end
    self:_TestForBreaking(adjacent_docks_to_removed_tile)

    -- Throw out some loot for presentation.
    if not dont_toss_loot then
        SpawnPrefab("fx_dock_pop").Transform:SetPosition(x, 0, z)
        if math.random() > 0.20 then
            toss_debris("boards", x, z)
        end
        toss_debris("log", x, z)
        if math.random() > 0.40 then
            toss_debris("log", x, z)
        end
    end

    return true
end

function self:QueueDestroyForDockAtPoint(x, y, z, dont_toss_loot)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local dock_data_at_point = _is_root_grid:GetDataAtPoint(tile_x, tile_y)
    if dock_data_at_point ~= nil then
        -- We assign this here because an external force could have manually queued this destroy.
        _marked_for_delete_grid:SetDataAtPoint(tile_x, tile_y, true)

        SpawnPrefab("fx_dock_crackle").Transform:SetPosition(x, 0, z)

        _world:DoTaskInTime((70 + math.random(0, 10))*FRAMES, destroy_dock_at_point, x, z, self, dont_toss_loot)

        -- Send a breaking message to all of the prefabs on this point.
        local tile_at_point = (_world.components.undertile ~= nil and _world.components.undertile:GetTileUnderneath(tile_x, tile_y))
            or WORLD_TILES.OCEAN_COASTAL
        if IsOceanTile(tile_at_point) then
            -- Behaviour pulled from walkableplatform's onremove/DestroyObjectsOnPlatform response.
            local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
            local entities_near_dock = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_DOCK_DROWNING_ONREMOVE_TAGS)

            for _, ent in ipairs(entities_near_dock) do
                -- Only push these events on prefabs that are actually standing on docks.
                -- We use the VisualGround test because we're accounting for tile overhang.
                if _map:IsVisualGroundAtPoint(ent.Transform:GetWorldPosition()) then
                    ent:PushEvent("abandon_ship")
                    if ent:HasTag("player") then
                        ent:PushEvent("onpresink")
                    end
                end
            end
        end
    end
end

function self:ResolveDockSafetyAtPoint(x, y, z)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local tile_xy = _is_root_grid:GetIndex(tile_x, tile_y)
    return self:_TestForBreaking({tile_xy})
end

function self:DamageDockAtPoint(x, y, z, damage)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    return self:DamageDockAtTile(tile_x, tile_y, damage)
end

function self:DamageDockAtTile(tx, ty, damage)
    local tile_index = _dock_health_grid:GetIndex(tx, ty)
    local current_tile_health = _dock_health_grid:GetDataAtIndex(tile_index)
    local dx, dy, dz = _map:GetTileCenterPoint(tx,ty)
    if current_tile_health == nil or current_tile_health == 0 then
        -- Exit early if there's no data (meaning no dock), or the tile was
        -- already damaged to its breaking point before this.
        return nil
    else
        -- We don't technically need this set here, but if somebody wants to inspect
        -- health and test for 0 elsewhere, it's useful to have an accurate representation.
        local new_health = math.min(math.max(0, current_tile_health - damage), TUNING.MONKEYISLANDDOCK_HEALTH)
        _dock_health_grid:SetDataAtIndex(tile_index, new_health)

        self:SpawnDamagePrefab(tile_index,new_health)

        if new_health <= 0 then
            self:QueueDestroyForDockAtPoint(dx, dy, dz)
        end

        return new_health
    end
end

function self:GetCoordsFromIndex(index)
    local z = math.modf(index/WIDTH)
    local x = index - (z*WIDTH)
    return x,z
end

function self:SpawnDamagePrefab(tile_index,health)
    local x, z = _dock_health_grid:GetXYFromIndex(tile_index)
    local dx, dy, dz = _map:GetTileCenterPoint(x,z)
    
    if health < TUNING.MONKEYISLANDDOCK_HEALTH then
        local dock_damage = _dock_damage_prefabs_grid:GetDataAtIndex(tile_index)
        if not dock_damage then
            dock_damage = SpawnPrefab("dock_damage")
            dock_damage.Transform:SetPosition(dx, dy, dz)
            _dock_damage_prefabs_grid:SetDataAtIndex(tile_index,dock_damage)
        end
        dock_damage:setdamagepecent( 1- (health/TUNING.MONKEYISLANDDOCK_HEALTH) )
    else
        local dock_damage = _dock_damage_prefabs_grid:GetDataAtIndex(tile_index)
        if dock_damage then
            _dock_damage_prefabs_grid:SetDataAtIndex(tile_index,nil)
            dock_damage:Remove()
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}

    data.dock_tiles = _is_root_grid:Save()
    data.marked_for_delete = _marked_for_delete_grid:Save()
    data.dock_health = _dock_health_grid:Save()

    return ZipAndEncodeSaveData(data)
end

function self:OnLoad(data)
    data = DecodeAndUnzipSaveData(data)
    if data == nil then
        return
    end

    if data.dock_tiles ~= nil then
        _is_root_grid:Load(data.dock_tiles)
    end

    if data.marked_for_delete ~= nil then
        _marked_for_delete_grid:Load(data.marked_for_delete)

        local dg_width = _is_root_grid:Width()
        for tile_xy, is_marked in pairs(data.marked_for_delete) do
            -- If we loaded tile data that's marked_for_delete, it must have been mid-destructions,
            -- because destruction should nil out the data for that tile.
            -- So, let's restart the destruction task!
            if is_marked then
                _world:DoTaskInTime(math.random(1, 10)*FRAMES, start_destroy_for_tile, tile_xy, dg_width, self)
            end
        end
    end

    if data.dock_health ~= nil then
        -- We shouldn't need to test for any 0 health values; anything that started
        -- being destroyed should have ended up in marked_for_delete above, and the
        -- health grid should get cleaned up when that destroy resolves.
        _dock_health_grid:Load(data.dock_health)
        for i, health in pairs(_dock_health_grid.grid)do
            if health then
                self:SpawnDamagePrefab(i,health)
            end
        end
    end
end
 
end)