--------------------------------------------------------------------------
--[[ VineBridgeManager class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)
assert(TheWorld.ismastersim, "VineBridgeManager should not exist on client")

self.inst = inst

--self.WIDTH, self.HEIGHT = nil, nil
--self.marked_for_delete_grid = nil
--self.duration_grid = nil
--self.damage_prefabs_grid = nil
--self.bridge_anims_grid = nil

-- Cache for speed.
local _world = TheWorld
local _map = _world.Map

local IGNORE_DROWNING_ONREMOVE_TAGS = { "ignorewalkableplatforms", "ignorewalkableplatformdrowning", "activeprojectile", "flying", "FX", "DECOR", "INLIMBO" }


local function initialize_grids()
    if self.marked_for_delete_grid ~= nil and self.duration_grid ~= nil then
        return
    end

    self.WIDTH, self.HEIGHT = _map:GetSize()

    self.marked_for_delete_grid = DataGrid(self.WIDTH, self.HEIGHT)
    self.duration_grid = DataGrid(self.WIDTH, self.HEIGHT)
    self.damage_prefabs_grid = DataGrid(self.WIDTH, self.HEIGHT)
	self.bridge_anims_grid = DataGrid(self.WIDTH, self.HEIGHT)
end
inst:ListenForEvent("worldmapsetsize", initialize_grids, _world)



local function destroy_vinebridge_at_point(world, dx, dz, vinebridgemanager, data)
    vinebridgemanager:DestroyVineBridgeAtPoint(dx, 0, dz, data)
end

local function create_vinebridge_at_point(world, dx, dz, vinebridgemanager, direction)
    vinebridgemanager:CreateVineBridgeAtPoint(dx, 0, dz, direction)
end

local function start_destroy_for_tile(_, txy, wid, vinebridgemanager)
    local center_x, center_y, center_z = _map:GetTileCenterPoint(txy % wid, math.floor(txy / wid))
    vinebridgemanager:QueueDestroyForVineBridgeAtPoint(center_x, center_y, center_z)
end

function self:CreateVineBridgeAtPoint(x, y, z, direction)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    return self:CreateVineBridgeAtTile(tile_x, tile_y, x, z, direction)
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
function self:CreateVineBridgeAtTile(tile_x, tile_y, x, z, direction)
    local current_tile = nil
    local undertile = _world.components.undertile
    if undertile then
        current_tile = _map:GetTile(tile_x, tile_y)
    end

    _map:SetTile(tile_x, tile_y, WORLD_TILES.CHARLIE_VINE)

    -- V2C: Because of a terraforming callback in farming_manager.lua, the undertile gets cleared during SetTile.
    --      We can circumvent this for now by setting the undertile after SetTile.
    if undertile and current_tile then
        undertile:SetTileUnderneath(tile_x, tile_y, current_tile)
    end

	local tile_index = self.duration_grid:GetIndex(tile_x, tile_y)
	local tile_data = self.duration_grid:GetDataAtIndex(tile_index)
	if tile_data then
		tile_data[1] = TUNING.VINEBRIDGE_HEALTH
		tile_data[2] = direction
	else
		self.duration_grid:SetDataAtIndex(tile_index, { TUNING.VINEBRIDGE_HEALTH, direction })
	end

    if not x or not z then
        local tx, _, tz = _map:GetTileCenterPoint(tile_x, tile_y)
        x = tx
        z = tz
    end

    local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
    self:FixupFloaterObjects(x, z, tile_radius_plus_overhang)

	self:SpawnBridgeAnim(tile_index, x, z, direction)

    return true
end

function self:QueueCreateVineBridgeAtPoint(x, y, z, data)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local data_at_point = self.duration_grid:GetDataAtPoint(tile_x, tile_y)
    if not data_at_point then
        local base_time, random_time = 0.5, 0.3
        local direction
        if data then
            base_time = data.base_time or base_time
            random_time = data.random_time or random_time
            direction = data.direction
        end
		self.duration_grid:SetDataAtPoint(tile_x, tile_y, { TUNING.VINEBRIDGE_HEALTH, direction })
        _world:DoTaskInTime(base_time + (random_time * math.random()), create_vinebridge_at_point, x, z, self, direction)
    end
end

function self:DestroyVineBridgeAtPoint(x, y, z, data)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local tile = _map:GetTile(tile_x, tile_y)
    if tile ~= WORLD_TILES.CHARLIE_VINE then
        return false
    end

    local index = self.damage_prefabs_grid:GetIndex(tile_x, tile_y)
    local damage_prefab = self.damage_prefabs_grid:GetDataAtIndex(index)
    if damage_prefab then
        self.damage_prefabs_grid:SetDataAtIndex(index, nil)
        damage_prefab:Remove()
    end

    local old_tile = WORLD_TILES.OCEAN_COASTAL -- FIXME(JBK): Determine default fallback for forest vs caves.
    local undertile = _world.components.undertile

    if undertile then
        old_tile = undertile:GetTileUnderneath(tile_x, tile_y)
        if old_tile then
            undertile:ClearTileUnderneath(tile_x, tile_y)
        else
            old_tile = WORLD_TILES.OCEAN_COASTAL
        end
    end

    _map:SetTile(tile_x, tile_y, old_tile)

    local grid_index = self.marked_for_delete_grid:GetIndex(tile_x, tile_y)
    self.marked_for_delete_grid:SetDataAtIndex(grid_index, nil)
    self.duration_grid:SetDataAtIndex(grid_index, nil)

	local fx = self.bridge_anims_grid:GetDataAtIndex(grid_index)
	if fx then
		fx:KillFX()
	end
	self.bridge_anims_grid:SetDataAtIndex(grid_index, nil)

    -- If we're swapping to an ocean tile, do like a broken boat would do and deal with everything in our tile bounds
    if IsOceanTile(old_tile) then
        -- Behaviour pulled from walkableplatform's onremove/DestroyObjectsOnPlatform response.
        local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
        local entities_near_tile = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_DROWNING_ONREMOVE_TAGS)

        local shore_point = nil
        for _, ent in ipairs(entities_near_tile) do
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

    -- Throw out some loot for presentation.
    --SpawnPrefab("fx_ice_pop").Transform:SetPosition(dx, 0, dz)
    --toss_debris("ice", dx, dz)
    --if math.random() > 0.40 then
    --    toss_debris("ice", dx, dz)
    --end

    --local half_num_debris = 4
    --local angle_per_debris = TWOPI/half_num_debris
    --for i = 1, half_num_debris do
    --    spawn_degrade_piece(dx, dz, (i + GetRandomWithVariance(0.50, 0.25)) * angle_per_debris)
    --    spawn_degrade_piece(dx, dz, (i + GetRandomWithVariance(0.50, 0.25)) * angle_per_debris)
    --end

    return true
end

function self:QueueDestroyForVineBridgeAtPoint(x, y, z, data)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    local data_at_point = self.duration_grid:GetDataAtPoint(tile_x, tile_y)
    if data_at_point then
        -- We assign this here because an external force could have manually queued this destroy.
        self.marked_for_delete_grid:SetDataAtPoint(tile_x, tile_y, true)

        local time = data and data.destroytime or (70 + math.random(0, 10)) * FRAMES
        _world:DoTaskInTime(time, destroy_vinebridge_at_point, x, z, self, data)

        local function DoWarn()
            -- Send a breaking message to all of the prefabs on this point.
            local tile_at_point = (_world.components.undertile and _world.components.undertile:GetTileUnderneath(tile_x, tile_y)) or WORLD_TILES.OCEAN_COASTAL
            if IsOceanTile(tile_at_point) then
                -- Behaviour pulled from walkableplatform's onremove/DestroyObjectsOnPlatform response.
                local tile_radius_plus_overhang = ((TILE_SCALE / 2) + 1.0) * 1.4142
                local entities_near_tile = TheSim:FindEntities(x, 0, z, tile_radius_plus_overhang, nil, IGNORE_DROWNING_ONREMOVE_TAGS)

                for _, ent in ipairs(entities_near_tile) do
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

        local fxtime = data and data.fxtime
        if fxtime then
            local shaketime = math.max(data.shaketime or 0, 0)
            _world:DoTaskInTime(shaketime, function()
                local fx = self.bridge_anims_grid:GetDataAtPoint(tile_x, tile_y)
                if fx and fx.ShakeIt then
                    fx:ShakeIt()
                end
            end)
            _world:DoTaskInTime(data.fxtime, function()
                DoWarn()
            end)
        else
            DoWarn()
        end
    end
end

function self:DamageVineBridgeAtPoint(x, y, z, damage)
    local tile_x, tile_y = _map:GetTileCoordsAtPoint(x, y, z)
    return self:DamageVineBridgeAtTile(tile_x, tile_y, damage)
end

function self:DamageVineBridgeAtTile(tx, ty, damage)
    local tile_index = self.duration_grid:GetIndex(tx, ty)
	local tile_data = self.duration_grid:GetDataAtIndex(tile_index)
    local dx, dy, dz = _map:GetTileCenterPoint(tx,ty)
	if not tile_data or (tile_data[1] or 0) == 0 then
        -- Exit early if there's no data, or the tile was
        -- already damaged to its breaking point before this.
        return nil
    else
        -- We don't technically need this set here, but if somebody wants to inspect
        -- health and test for 0 elsewhere, it's useful to have an accurate representation.
        local new_health = math.min(math.max(0, current_tile_health - damage), TUNING.VINEBRIDGE_HEALTH)
		tile_data[1] = new_health

        self:SpawnDamagePrefab(tile_index, new_health)

        if new_health == 0 then
            self:QueueDestroyForVineBridgeAtPoint(dx, dy, dz)
        end

        return new_health
    end
end

function self:SpawnDamagePrefab(tile_index, health)
    local x, z = self.duration_grid:GetXYFromIndex(tile_index)
    local dx, dy, dz = _map:GetTileCenterPoint(x,z)
    local damage_prefab = self.damage_prefabs_grid:GetDataAtIndex(tile_index)

    if health < TUNING.VINEBRIDGE_HEALTH then
        --if not damage_prefab then
        --    damage_prefab = SpawnPrefab("oceanice_damage")
        --    damage_prefab.Transform:SetPosition(dx, dy, dz)
        --    self.damage_prefabs_grid:SetDataAtIndex(tile_index, damage_prefab)
        --end
        --damage_prefab:setdamagepecent( 1 - (health/TUNING.VINEBRIDGE_HEALTH) )
    else
        if damage_prefab then
            self.damage_prefabs_grid:SetDataAtIndex(tile_index, nil)
            damage_prefab:Remove()
        end
    end
end

function self:SpawnBridgeAnim(tile_index, x, z, direction)
	local fx = self.bridge_anims_grid:GetDataAtIndex(tile_index)
	if fx == nil then
		fx = SpawnPrefab("vine_bridge_fx")
		fx.Transform:SetPosition(x, 0, z)
		fx.Transform:SetRotation(
			(direction.x > 0 and -90) or
			(direction.x < 0 and 90) or
			(direction.z > 0 and 180) or
			0
		)
		self.bridge_anims_grid:SetDataAtIndex(tile_index, fx)

		if POPULATING then
			fx:SkipPre()
		end
	end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}

    data.marked_for_delete = self.marked_for_delete_grid:Save()
    data.duration = self.duration_grid:Save()

    return ZipAndEncodeSaveData(data)
end

function self:OnLoad(data)
    data = DecodeAndUnzipSaveData(data)
    if data == nil then
        return
    end

    if data.marked_for_delete ~= nil then
        self.marked_for_delete_grid:Load(data.marked_for_delete)

        local dg_width = self.marked_for_delete_grid:Width()
        for tile_xy, is_marked in pairs(data.marked_for_delete) do
            -- If we loaded tile data that's marked_for_delete, it must have been mid-destructions,
            -- because destruction should nil out the data for that tile.
            -- So, let's restart the destruction task!
            if is_marked then
                _world:DoTaskInTime(math.random(1, 10) * FRAMES, start_destroy_for_tile, tile_xy, dg_width, self)
            end
        end
    end

    if data.duration ~= nil then
        -- We shouldn't need to test for any 0 health values; anything that started
        -- being destroyed should have ended up in marked_for_delete above, and the
        -- health grid should get cleaned up when that destroy resolves.
        self.duration_grid:Load(data.duration)
        for i, health in pairs(self.duration_grid.grid) do
			if type(health) == "table" then
				local tile_x, tile_y = self.duration_grid:GetXYFromIndex(i)
				local x, y, z = _map:GetTileCenterPoint(tile_x, tile_y)
				self:SpawnBridgeAnim(i, x, z, health[2])
				self:SpawnDamagePrefab(i, health[1])
			else
				--backward compatibility: duration_grid used to be just health value, now is an array { health, duration }
				self:SpawnDamagePrefab(i, health)
			end
        end
    end
end

end)