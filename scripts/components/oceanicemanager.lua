--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ OceanIceManager class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "OceanIceManager should not exist on client")

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _world = TheWorld
local _map = _world.Map

-- a data grid that stores tiles marked for delete.
local _marked_for_delete_grid = nil

-- a data grid storing a "health" value for each ice tile
local _ice_health_grid = nil

-- a data grid storing the damage prefabs
local _ice_damage_prefabs_grid = nil

local WIDTH = nil
local HEIGHT = nil

local CRACK_MUST_TAGS = {"ice_crack_fx"}
local IGNORE_ICE_DROWNING_ONREMOVE_TAGS = { "ignorewalkableplatforms", "ignorewalkableplatformdrowning", "activeprojectile", "flying", "FX", "DECOR", "INLIMBO" }

--------------------------------------------------------------------------
--[[ Private functions ]]
--------------------------------------------------------------------------
local function initialize_grids()
    if _marked_for_delete_grid ~= nil and _ice_health_grid ~= nil then
        return
    end

    WIDTH, HEIGHT = _map:GetSize()

    _marked_for_delete_grid = DataGrid(WIDTH, HEIGHT)
    _ice_health_grid = DataGrid(WIDTH, HEIGHT)
    _ice_damage_prefabs_grid = DataGrid(WIDTH, HEIGHT)
end
inst:ListenForEvent("worldmapsetsize", initialize_grids, _world)

local function toss_debris(debris_prefab, dx, dz)
    local ice_debris = SpawnPrefab(debris_prefab)
    ice_debris.Physics:Teleport(dx, 0.1, dz)

    local debris_angle = TWOPI*math.random()
    local debris_speed = 2.5 + 2*math.random()
    ice_debris.Physics:SetVel(debris_speed * math.cos(debris_angle), 10, debris_speed * math.sin(debris_angle))
end

local function spawn_degrade_piece(center_x, center_z, spawn_angle)
    local ice_degrade_fx = SpawnPrefab("degrade_fx_ice")
    spawn_angle = spawn_angle or TWOPI*math.random()
    local spawn_offset = TUNING.OCEAN_ICE_RADIUS * (0.4 + 0.65 * math.sqrt(math.random()))

    center_x = center_x + (spawn_offset * math.cos(spawn_angle))
    center_z = center_z + (spawn_offset * math.sin(spawn_angle))
    ice_degrade_fx.Transform:SetPosition(center_x, 0, center_z)
end

local function destroy_ice_at_point(world, dx, dz, oceanicemanager, data)
    -- HACK for stopping the ice breaking until better plan is implimented
    local sharkboimanager = world.components.sharkboimanager
    if sharkboimanager ~= nil and sharkboimanager.arena ~= nil then
        local sharkboi = sharkboimanager.arena.sharkboi
        if sharkboi ~= nil then
            if sharkboi:GetDistanceSqToPoint(dx, 0, dz) < 4 * 4 then
                sharkboimanager:PauseArenaShrinking_Hack()
                world:DoTaskInTime((70 + math.random(0, 10))*FRAMES, destroy_ice_at_point, dx, dz, oceanicemanager, data)
                return
            end
        end
    end
    -- END HACK
    oceanicemanager:DestroyIceAtPoint(dx, 0, dz, data)
end

local function create_ice_at_point(world, dx, dz, oceanicemanager)
    oceanicemanager:CreateIceAtPoint(dx, 0, dz)
end

local function start_destroy_for_tile(_, txy, wid, oceanicemanager)
    local center_x, center_y, center_z = _map:GetTileCenterPoint(txy % wid, math.floor(txy / wid))

    oceanicemanager:QueueDestroyForIceAtPoint(center_x, center_y, center_z)
end

local function removecrackedicefx(dx, dz)
    local cracks = TheSim:FindEntities(dx, 0, dz, 4.5, CRACK_MUST_TAGS)
    for i=#cracks, 1, -1 do
        cracks[i]:Remove()
    end
end

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:CreateIceAtPoint(x, y, z)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    return self:CreateIceAtTile(tile_x, tile_y, x, z)
end

local INITIAL_LAUNCH_HEIGHT = 0.1
local SPEED = 6
local function launch_away(item, position)
    local ix, iy, iz = item.Transform:GetWorldPosition()
    item.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

    local cosa, sina = 0, 0
    if position then
        local px, py, pz = position:Get()
        local angle = (180 - item:GetAngleToPoint(px, py, pz)) * DEGREES
        sina, cosa = math.sin(angle), math.cos(angle)
    end
    item.Physics:SetVel(SPEED * cosa, 2 + SPEED, SPEED * sina)
end

local FLOATEROBJECT_TAGS = {"floaterobject"}
function self:FixupFloaterObjects(x, z, tile_radius_plus_overhang, is_ocean_tile)
    local floaterobjects = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, FLOATEROBJECT_TAGS)
    for _, floaterobject in ipairs(floaterobjects) do
        if floaterobject.components.floater then
            local fx, fy, fz = floaterobject.Transform:GetWorldPosition()
            if is_ocean_tile or _map:IsOceanTileAtPoint(fx, fy, fz) then
                floaterobject:PushEvent("on_landed")
            else
                floaterobject:PushEvent("on_no_longer_landed")
            end
        end
    end
end
function self:CreateIceAtTile(tile_x, tile_y, x, z)
    local current_tile = nil
    local undertile = _world.components.undertile
    if undertile then
        current_tile = _map:GetTile(tile_x, tile_y)
    end

    _map:SetTile(tile_x, tile_y, WORLD_TILES.OCEAN_ICE)

    -- V2C: Because of a terraforming callback in farming_manager.lua, the undertile gets cleared during SetTile.
    --      We can circumvent this for now by setting the undertile after SetTile.
    if undertile and current_tile then
        undertile:SetTileUnderneath(tile_x, tile_y, current_tile)
    end

    _ice_health_grid:SetDataAtPoint(tile_x, tile_y, TUNING.OCEAN_ICE_HEALTH)

    if not x or not z then
        local tx, _, tz = _map:GetTileCenterPoint(tile_x, tile_y)
        x = tx
        z = tz
    end
    local center_position = Vector3(x, 0, z)

    local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
    local entities_near_ice = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_ICE_DROWNING_ONREMOVE_TAGS)
    for _, ent in ipairs(entities_near_ice) do
        if ent.components.oceanfishable then
            local projectile = ent.components.oceanfishable:MakeProjectile()
            local projectile_complexprojectile = projectile.components.complexprojectile
            if projectile_complexprojectile then
                projectile_complexprojectile:SetHorizontalSpeed(16)
                projectile_complexprojectile:SetGravity(-30)
                projectile_complexprojectile:SetLaunchOffset(Vector3(0, 0.5, 0))
                projectile_complexprojectile:SetTargetOffset(Vector3(0, 0.5, 0))

                local v_position = ent:GetPosition()
                local launch_position = v_position + (v_position - center_position):Normalize() * SPEED
                projectile_complexprojectile:Launch(launch_position, projectile, projectile_complexprojectile.owningweapon)
            else
                launch_away(projectile, center_position)
            end
        elseif ent.prefab == "bullkelp_plant" then
            local entx, enty, entz = ent.Transform:GetWorldPosition()

            if ent.components.pickable and ent.components.pickable:CanBePicked() then
                local product = ent.components.pickable.product
                local loot = SpawnPrefab(product)
                if loot then
                    loot.Transform:SetPosition(entx, enty, entz)
                    if loot.components.inventoryitem then
                        loot.components.inventoryitem:InheritWorldWetnessAtTarget(ent)
                    end
                    if loot.components.stackable and ent.components.pickable.numtoharvest > 1 then
                        loot.components.stackable:SetStackSize(ent.components.pickable.numtoharvest)
                    end
                    launch_away(loot, center_position)
                end
            end

            local uprooted_kelp_plant = SpawnPrefab("bullkelp_root")
            if uprooted_kelp_plant then
                uprooted_kelp_plant.Transform:SetPosition(entx, enty, entz)
                launch_away(uprooted_kelp_plant, center_position + Vector3(0.5*math.random(), 0, 0.5*math.random()))
            end

            ent:Remove()
        elseif ent.components.inventoryitem and ent.Physics then
            launch_away(ent)
            ent.components.inventoryitem:SetLanded(false, true)
        end
    end
    self:FixupFloaterObjects(x, z, tile_radius_plus_overhang)

    return true
end

function self:QueueCreateIceAtPoint(x, y, z, data)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local ice_data_at_point = _ice_health_grid:GetDataAtPoint(tile_x, tile_y)
    if not ice_data_at_point then
        _ice_health_grid:SetDataAtPoint(tile_x, tile_y, TUNING.OCEAN_ICE_TILE_HEALTH)

        --SpawnPrefab().Transform:SetPosition(x, 0, z)

        local base_time, random_time = 2.1, 0.3
        if data then
            base_time = data.base_time or base_time
            random_time = data.random_time or random_time
        end
        _world:DoTaskInTime(base_time + (random_time * math.random()), create_ice_at_point, x, z, self)
    end
end

function self:DestroyIceAtPoint(x, y, z, data)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local tile = _map:GetTile(tile_x, tile_y)
    if tile ~= WORLD_TILES.OCEAN_ICE then
        return false
    end

    local index = _ice_damage_prefabs_grid:GetIndex(tile_x, tile_y)
    local ice_damage = _ice_damage_prefabs_grid:GetDataAtIndex(index)
    if ice_damage then
        _ice_damage_prefabs_grid:SetDataAtIndex(index,nil)
        ice_damage:Remove()
    end

    local old_tile = WORLD_TILES.OCEAN_SWELL
    local undertile = _world.components.undertile

    if undertile then
        old_tile = undertile:GetTileUnderneath(tile_x, tile_y)
        if old_tile then
            undertile:ClearTileUnderneath(tile_x, tile_y)
        else
            old_tile = WORLD_TILES.OCEAN_SWELL
        end
    end

    local dx, dy, dz = _map:GetTileCenterPoint(tile_x, tile_y)

                -- THIS IS HACKED IN TO SAVE THE PLAYER FOR NOW!
                local hypotenuseSq = 8 + 1-- buffer.
                local players = FindPlayersInRangeSq(dx, 0, dz, hypotenuseSq, true)
                if players and #players >0 then
                    for i, player in ipairs(players)do
                        local px,py,pz = player.Transform:GetWorldPosition()
                        local ptile_x, ptile_y = _map:GetTileCoordsAtPoint(px, py, pz)
                        local ptile = _map:GetTile(ptile_x, ptile_y)
                        if ptile == tile then
                            player.Physics:Teleport(dx, dy, dz)
                        end
                    end
                end

    removecrackedicefx(dx, dz)

    _map:SetTile(tile_x, tile_y, old_tile)

    local grid_index = _marked_for_delete_grid:GetIndex(tile_x, tile_y)
    _marked_for_delete_grid:SetDataAtIndex(grid_index, nil)
    _ice_health_grid:SetDataAtIndex(grid_index, nil)

    local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
    local is_ocean_tile = IsOceanTile(old_tile)

    if is_ocean_tile then
        local icefloe = nil

        if data == nil or not data.silent then
            local floe_vector_x, floe_vector_y = 0, 0
            local floe_count_x, floe_count_y = 0, 0
            for x_offset = -1, 1, 1 do
                for y_offset = -1, 1, 1 do
                    if ((x_offset == 0 and y_offset ~= 0) or (y_offset == 0 and x_offset ~= 0))
                            and IsLandTile(_map:GetTile(tile_x + x_offset, tile_y + y_offset)) then
                        floe_vector_x = floe_vector_x + x_offset
                        floe_count_x = floe_count_x + math.abs(x_offset)
                        floe_vector_y = floe_vector_y + y_offset
                        floe_count_y = floe_count_y + math.abs(y_offset)
                    end
                end
            end

            if floe_count_x < 2 and floe_count_y < 2 then
                local offset_tile_x, offset_tile_y, offset_tile_z = _map:GetTileCenterPoint(tile_x + floe_vector_x, tile_y + floe_vector_y)
                local push_x, push_z = x - offset_tile_x, z - offset_tile_z
                local pushnormal_x, pushnormal_z = VecUtil_NormalizeNoNaN(push_x, push_z)

                local bx, bz = dx + (TUNING.OCEAN_ICE_RADIUS * pushnormal_x), dz + (TUNING.OCEAN_ICE_RADIUS * pushnormal_z)
                if TheSim:FindEntities(bx, 0, bz, MAX_PHYSICS_RADIUS, FLOATEROBJECT_TAGS)[1] == nil then
                    icefloe = SpawnPrefab(data ~= nil and data.icefloe_prefab or "boat_ice")
                    icefloe.Transform:SetPosition(bx, 0, bz)
                    icefloe.components.boatphysics:ApplyRowForce(pushnormal_x, pushnormal_z, TUNING.OCEAN_ICE_BREAK_FORCE, 10.0)

                    TheWorld:PushEvent("icefloebreak", icefloe)
                end
            end
        end

        -- Behaviour pulled from walkableplatform's onremove/DestroyObjectsOnPlatform response.
        local entities_near_ice = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_ICE_DROWNING_ONREMOVE_TAGS)
        for _, ent in ipairs(entities_near_ice) do
            if ent ~= icefloe and ent:IsValid() then
                if icefloe and icefloe:GetDistanceSqToInst(ent) < (icefloe.components.walkableplatform.platform_radius)^2 then

                else
                    local has_drownable = (ent.components.drownable ~= nil)
                    local shore_point = (has_drownable and Vector3(FindRandomPointOnShoreFromOcean(x, y, z)))
                        or nil
                    ent:PushEvent("onsink", {boat = nil, shore_pt = shore_point})

                    -- We're testing the overhang, so we need to verify that anything we find isn't
                    -- still on some adjacent dock or land tile or other platform after we remove ourself.
                    if ent:IsValid() and not has_drownable and not ent.entity:GetParent()
                        and not ent.components.amphibiouscreature
                        and not _map:IsVisualGroundAtPoint(ent.Transform:GetWorldPosition()) and not ent:GetCurrentPlatform() then

                        if ent.components.inventoryitem then
                            ent.components.inventoryitem:SetLanded(false, true)
                        else
                            DestroyEntity(ent, _world, true, true)
                        end
                    end
                end
            end
        end
    end

    self:FixupFloaterObjects(x, z, tile_radius_plus_overhang, is_ocean_tile)

    if data == nil or not data.silent then
        -- Throw out some loot for presentation.
        SpawnPrefab("fx_ice_pop").Transform:SetPosition(dx, 0, dz)

        toss_debris("ice", dx, dz)

        if math.random() > 0.40 then
            toss_debris("ice", dx, dz)
        end

        local half_num_debris = 4
        local angle_per_debris = TWOPI/half_num_debris
        for i = 1, half_num_debris do
            spawn_degrade_piece(dx, dz, (i + GetRandomWithVariance(0.50, 0.25)) * angle_per_debris)
            spawn_degrade_piece(dx, dz, (i + GetRandomWithVariance(0.50, 0.25)) * angle_per_debris)
        end
    end

    return true
end

local function spawncracks(x,z)
    local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, 0, z)
    local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(tx, ty)

    local S = TheWorld.Map:IsLandTileAtPoint(cx+4,cy,cz)
    local N = TheWorld.Map:IsLandTileAtPoint(cx-4,cy,cz)
    local E = TheWorld.Map:IsLandTileAtPoint(cx,cy,cz+4)
    local W = TheWorld.Map:IsLandTileAtPoint(cx,cy,cz-4)

    local function spawnfx(lx,lz, rot)  
        if #TheSim:FindEntities(lx, 0, lz, 1, CRACK_MUST_TAGS)  < 1 then
            local fx = SpawnPrefab("ice_crack_grid_fx")
            fx.Transform:SetPosition(lx, 0, lz)
            fx.Transform:SetRotation(rot)        
        end
    end

    if N then
        spawnfx(cx-2, cz,0)
    end
    if S then
        spawnfx(cx+2, cz,180)
    end
    if E then
        spawnfx(cx, cz+2,90)
    end
    if W then
        spawnfx(cx, cz-2,270)
    end
end

function self:QueueDestroyForIceAtPoint(x, y, z, data)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local ice_data_at_point = _ice_health_grid:GetDataAtPoint(tile_x, tile_y)
    if ice_data_at_point then
        -- We assign this here because an external force could have manually queued this destroy.
        _marked_for_delete_grid:SetDataAtPoint(tile_x, tile_y, true)

        SpawnPrefab("fx_ice_crackle").Transform:SetPosition(x, 0, z)
        
        local time = data and data.destroytime or (70 + math.random(0, 10))*FRAMES

        spawncracks(x,z)

        _world:DoTaskInTime(time, destroy_ice_at_point, x, z, self, data)

        -- Send a breaking message to all of the prefabs on this point.
        local tile_at_point = (_world.components.undertile and _world.components.undertile:GetTileUnderneath(tile_x, tile_y))
            or WORLD_TILES.OCEAN_SWELL
        if IsOceanTile(tile_at_point) then
            -- Behaviour pulled from walkableplatform's onremove/DestroyObjectsOnPlatform response.
            local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
            local entities_near_ice = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_ICE_DROWNING_ONREMOVE_TAGS)

            for _, ent in ipairs(entities_near_ice) do
                -- Only push these events on prefabs that are actually standing on ice.
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

function self:DamageIceAtPoint(x, y, z, damage)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    return self:DamageIceAtTile(tile_x, tile_y, damage)
end

function self:DamageIceAtTile(tx, ty, damage)
    local tile_index = _ice_health_grid:GetIndex(tx, ty)
    local current_tile_health = _ice_health_grid:GetDataAtIndex(tile_index)
    local dx, dy, dz = _map:GetTileCenterPoint(tx,ty)
    if not current_tile_health or current_tile_health == 0 then
        -- Exit early if there's no data (meaning no ice), or the tile was
        -- already damaged to its breaking point before this.
        return nil
    else
        -- We don't technically need this set here, but if somebody wants to inspect
        -- health and test for 0 elsewhere, it's useful to have an accurate representation.
        local new_health = math.min(math.max(0, current_tile_health - damage), TUNING.OCEAN_ICE_HEALTH)
        _ice_health_grid:SetDataAtIndex(tile_index, new_health)

        self:SpawnDamagePrefab(tile_index, new_health)

        if new_health == 0 then
            self:QueueDestroyForIceAtPoint(dx, dy, dz)
        end

        return new_health
    end
end

function self:SpawnDamagePrefab(tile_index, health)
    local x, z = _ice_health_grid:GetXYFromIndex(tile_index)
    local dx, dy, dz = _map:GetTileCenterPoint(x,z)
    local ice_damage = _ice_damage_prefabs_grid:GetDataAtIndex(tile_index)

    if health < TUNING.OCEAN_ICE_HEALTH then
        if not ice_damage then
            ice_damage = SpawnPrefab("oceanice_damage")
            ice_damage.Transform:SetPosition(dx, dy, dz)
            _ice_damage_prefabs_grid:SetDataAtIndex(tile_index, ice_damage)
        end
        ice_damage:setdamagepecent( 1 - (health/TUNING.OCEAN_ICE_HEALTH) )
    else
        if ice_damage then
            _ice_damage_prefabs_grid:SetDataAtIndex(tile_index, nil)
            ice_damage:Remove()
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}

    data.marked_for_delete = _marked_for_delete_grid:Save()
    data.ice_health = _ice_health_grid:Save()

    return ZipAndEncodeSaveData(data)
end

function self:OnLoad(data)
    data = DecodeAndUnzipSaveData(data)
    if data == nil then
        return
    end

    if data.marked_for_delete ~= nil then
        _marked_for_delete_grid:Load(data.marked_for_delete)

        local dg_width = _marked_for_delete_grid:Width()
        for tile_xy, is_marked in pairs(data.marked_for_delete) do
            -- If we loaded tile data that's marked_for_delete, it must have been mid-destructions,
            -- because destruction should nil out the data for that tile.
            -- So, let's restart the destruction task!
            if is_marked then
                _world:DoTaskInTime(math.random(1, 10)*FRAMES, start_destroy_for_tile, tile_xy, dg_width, self)
            end
        end
    end

    if data.ice_health ~= nil then
        -- We shouldn't need to test for any 0 health values; anything that started
        -- being destroyed should have ended up in marked_for_delete above, and the
        -- health grid should get cleaned up when that destroy resolves.
        _ice_health_grid:Load(data.ice_health)
        for i, health in pairs(_ice_health_grid.grid)do
            if health then
                self:SpawnDamagePrefab(i,health)
            end
        end
    end
end

end)