local rift_portal_defs = require("prefabs/rift_portal_defs")
local RIFTPORTAL_CONST = rift_portal_defs.RIFTPORTAL_CONST
rift_portal_defs = nil

local MiasmaManager = Class(function(self, inst)
    local _world = TheWorld
    assert(_world.ismastersim, "Component MiasmaManager should not exist on the client.")

    self.inst = inst

    local _map = _world.Map
    local _cached_miasma_indexes = {}
    local _cached_miasma_indexes_count = 0
    local _diminishing_datas = {}
    local _miasma_grid = nil
    local WIDTH = nil
    local HEIGHT = nil
    local _lastupdate_spread = 0
    local _lastupdate_diminish = 0
    local enabled = false
    local KILL_MIASMA_RADIUS = SQRT2 * TUNING.MIASMA_SPACING * TILE_SCALE / 2 -- Half to have no overlap on adjacent miasma grid squares.

    local function initialize_grids()
        if _miasma_grid ~= nil then
            return
        end

        WIDTH, HEIGHT = _map:GetSize()
        _miasma_grid = DataGrid(WIDTH, HEIGHT)
    end
    inst:ListenForEvent("worldmapsetsize", initialize_grids, _world)


    ----------------------
    -- Internal functions.
    ----------------------


    function self:_GenerateMiasmaDataForMiasmaTileCoords(mtx, mty)
        local data = {
            strength = 1,
        }
        local index = _miasma_grid:GetIndex(mtx, mty)
        _cached_miasma_indexes_count = _cached_miasma_indexes_count + 1
        _cached_miasma_indexes[_cached_miasma_indexes_count] = index
        _miasma_grid:SetDataAtIndex(index, data)
    end
    function self:_GetMiasmaDataForMiasmaTileCoords(mtx, mty)
        return _miasma_grid:GetDataAtPoint(mtx, mty)
    end

    -- Return true if the field was not capped by max.
    function self:_Enhance(mtx, mty, data)
        local strength = math.min(data.strength + 1, TUNING.MIASMA_MAXSTRENGTH)
        local increased = strength ~= data.strength
        data.strength = strength
        return increased
    end

    -- Return true if the field was destroyed.
    local _Diminish_MUSTTAGS = {"miasma",}
    function self:_Diminish(mtx, mty, data)
        data.strength = data.strength - 1
        if data.strength <= 0 then
            local index = _miasma_grid:GetIndex(mtx, mty)
            table.removearrayvalue(_cached_miasma_indexes, index)
            _cached_miasma_indexes_count = _cached_miasma_indexes_count - 1
            _miasma_grid:SetDataAtIndex(index, nil)
            local x, y, z = _map:GetTileCenterPoint(mtx, mty)
            local ents = TheSim:FindEntities(x, y, z, KILL_MIASMA_RADIUS, _Diminish_MUSTTAGS)
            for _, v in ipairs(ents) do
                v:Remove()
            end
            _diminishing_datas[data] = nil
            return true
        end
        return false
    end

    function self:_SetMiasmaDiminishingForMiasmaTileCoords(mtx, mty, isdiminishing)
        local miasmadata = self:_GetMiasmaDataForMiasmaTileCoords(mtx, mty)
        if not miasmadata then
            return
        end

        miasmadata.diminishing = isdiminishing and true or nil
        if isdiminishing then
            if _diminishing_datas[miasmadata] == nil then
                _diminishing_datas[miasmadata] = {mtx = mtx, mty = mty,}
            end
        else
            _diminishing_datas[miasmadata] = nil
        end
    end


    --------------------
    -- Public functions.
    --------------------


    -- Save / Load.
    function self:OnSave()
        local data = {
            miasmagrid = _miasma_grid:Save(),
            enabled = enabled,
        }
        return ZipAndEncodeSaveData(data)
    end
    function self:OnLoad(data)
        if data then
            data = DecodeAndUnzipSaveData(data)
        end
        if data == nil then
            return
        end

        if data.miasmagrid then
            _miasma_grid:Load(data.miasmagrid)
            for index = 0, WIDTH * HEIGHT - 1 do -- Initial loading pass cache.
                local miasmadata = _miasma_grid:GetDataAtIndex(index)
                if miasmadata then
                    _cached_miasma_indexes_count = _cached_miasma_indexes_count + 1
                    _cached_miasma_indexes[_cached_miasma_indexes_count] = index
                    if miasmadata.diminishing then
                        local mtx, mty = _miasma_grid:GetXYFromIndex(index)
                        self:_SetMiasmaDiminishingForMiasmaTileCoords(mtx, mty, true)
                    end
                end
            end
        end
        self:SetMiasmaActive(data.enabled or enabled)
    end


    -- Getters.
    -- Positions.
    function self:GetMiasmaTileCoords(tx, ty)
        -- Forces gaps between world tiles to make miasma tile coordinates.
        return math.floor(tx / TUNING.MIASMA_SPACING) * TUNING.MIASMA_SPACING,
               math.floor(ty / TUNING.MIASMA_SPACING) * TUNING.MIASMA_SPACING
    end
    function self:GetMiasmaAtPoint(x, y, z)
        local tx, ty = _map:GetTileCoordsAtPoint(x, y, z)
        return self:GetMiasmaAtTile(tx, ty)
    end
    function self:GetMiasmaAtTile(tx, ty)
        local mtx, mty = self:GetMiasmaTileCoords(tx, ty)
        return self:_GetMiasmaDataForMiasmaTileCoords(mtx, mty)
    end

    -- Status.
    function self:IsMiasmaActive()
        return enabled
    end
    function self:SetMiasmaActive(active)
        if active ~= enabled then
            enabled = active
            if enabled then
                self.inst:StartUpdatingComponent(self)
            else
                self.inst:StopUpdatingComponent(self)
            end
            _world:PushEvent("miasma_setactive", enabled)
        end
    end

    function self:SetMiasmaDiminishingAtPoint(x, y, z, isdiminishing)
        local tx, ty = _map:GetTileCoordsAtPoint(x, y, z)
        return self:SetMiasmaDiminishingAtTile(tx, ty, isdiminishing)
    end
    function self:SetMiasmaDiminishingAtTile(tx, ty, isdiminishing)
        local mtx, mty = self:GetMiasmaTileCoords(tx, ty)
        return self:_SetMiasmaDiminishingForMiasmaTileCoords(mtx, mty, isdiminishing)
    end

    
    -- Creation.
    function self:CreateMiasmaAtPoint(x, y, z)
        local tx, ty = _map:GetTileCoordsAtPoint(x, y, z)
        return self:CreateMiasmaAtTile(tx, ty)
    end
    function self:CreateMiasmaAtTile(tx, ty)
        local tileid = _map:GetTile(tx, ty)
        if tileid == nil then
            return
        end

        if not IsLandTile(tileid) then
            return
        end

        local tileinfo = GetTileInfo(tileid)
        if tileinfo == nil then
            return
        end

        local mtx, mty = self:GetMiasmaTileCoords(tx, ty)
        local miasmadata = self:_GetMiasmaDataForMiasmaTileCoords(mtx, mty)
        if miasmadata ~= nil then
            return
        end

        self:_GenerateMiasmaDataForMiasmaTileCoords(mtx, mty)
        
        local x, y, z = _map:GetTileCenterPoint(mtx, mty)
        local ent = SpawnPrefab("miasma_cloud")
        ent.Transform:SetPosition(x, y, z)

        self:SetMiasmaActive(true)
    end


    -- Actions are all in miasma tile space.
    -- Create a new miasma location.
    function self:MiasmaAction_Create(mtx, mty)
        local riftspawner = _world.components.riftspawner
        if not riftspawner then
            -- Do not create more miasma if there are no potentials for rifts.
            return
        end

        local rifts = riftspawner:GetRiftsOfAffinity(RIFTPORTAL_CONST.AFFINITY.SHADOW)
        if rifts == nil then
            -- No shadow affinity rifts do not spread.
            return
        end

        local mindistsq = TUNING.MIASMA_MIN_DISTSQ_FROM_RIFT
        local maxdistsq = TUNING.MIASMA_MAX_DISTSQ_FROM_RIFT
        for _, rift in ipairs(rifts) do
            local rx, ry, rz = rift.Transform:GetWorldPosition()
            local x, y, z = _map:GetTileCenterPoint(mtx, mty)
            local dx, dz = x - rx, z - rz
            local dsq = dx * dx + dz * dz
            if dsq < mindistsq then
                -- Too close to a nearby portal do not spawn one.
                return
            end
            if dsq > maxdistsq then
                -- Too far away from a nearby portal do not spawn one.
                return
            end
        end

        self:CreateMiasmaAtTile(mtx, mty)
    end
    -- Try to spread to adjacent tiles.
    function self:MiasmaAction_Spread(mtx, mty, miasmadata)
        -- Do not allow spreading when the action itself is spreading to stop a cascade.
        self:RollForMiasmaActionAt(mtx + TUNING.MIASMA_SPACING, mty, false)
        self:RollForMiasmaActionAt(mtx - TUNING.MIASMA_SPACING, mty, false)
        self:RollForMiasmaActionAt(mtx, mty + TUNING.MIASMA_SPACING, false)
        self:RollForMiasmaActionAt(mtx, mty - TUNING.MIASMA_SPACING, false)
    end
    -- Boost strength of miasma in this tile.
    function self:MiasmaAction_Enhance(mtx, mty, miasmadata)
        if self:_Enhance(mtx, mty, miasmadata) then
        end
    end
    -- Decrease strength of miasma in this tile and delete it if it is not strong enough.
    function self:MiasmaAction_Diminish(mtx, mty, miasmadata)
        self:_Diminish(mtx, mty, miasmadata)
    end

    -- Handle the odds and rules for miasma creation and spread.
    function self:RollForMiasmaActionAt(mtx, mty, allowspread)
        local miasmadata = self:GetMiasmaAtTile(mtx, mty)

        local riftspawner = _world.components.riftspawner
        if riftspawner and not riftspawner:IsShadowPortalActive() then
            -- No shadow affinity rifts deteriorate old miasma clouds over time.
            if miasmadata then
                self:MiasmaAction_Diminish(mtx, mty, miasmadata)
                return "Diminish"
            else
                return
            end
        end

        if miasmadata == nil then
            if math.random() > TUNING.MIASMA_ODDS_CREATE then
                return
            end
            self:MiasmaAction_Create(mtx, mty)
            return "Create"
        end

        if miasmadata.diminishing then
            -- Bonus diminish effect during spread propagation.
            self:MiasmaAction_Diminish(mtx, mty, miasmadata)
            return "Diminish"
        end

        if allowspread then
            if math.random() > TUNING.MIASMA_ODDS_SPREAD then
                return
            end
            self:MiasmaAction_Spread(mtx, mty, miasmadata)
            return "Spread"
        end
    
        self:MiasmaAction_Enhance(mtx, mty, miasmadata)
        return "Enhance"
    end


    -- Showtime!
    function self:DoDiminishes()
        for miasmadata, packed_data in pairs(_diminishing_datas) do
            self:MiasmaAction_Diminish(packed_data.mtx, packed_data.mty, miasmadata)
        end
    end
    function self:DoRolls()
        -- Pick a random miasma fog already existing in the world to try to update it.
        if _cached_miasma_indexes_count > 0 then
            local rindex = math.random(_cached_miasma_indexes_count)
            local mtx, mty = _miasma_grid:GetXYFromIndex(_cached_miasma_indexes[rindex])
            return self:RollForMiasmaActionAt(mtx, mty, _cached_miasma_indexes_count < TUNING.MIASMA_MAX_CLOUDS)
        end
    end


    -- Logic related to the miasma fog itself.
    function self:OnUpdate(dt)
        if _cached_miasma_indexes_count <= 0 then
            -- Turn the component off.
            self:SetMiasmaActive(false)
            return
        end

        -- Rate controllers.
        local curtime = GetTime()

        local limit = TUNING.MIASMA_DIMINISH_INTERVAL_SECONDS
        while curtime - _lastupdate_diminish >= limit do
            _lastupdate_diminish = _lastupdate_diminish + limit
            self:DoDiminishes()
        end

        limit = TUNING.MIASMA_SPREAD_INTERVAL_SECONDS
        while curtime - _lastupdate_spread >= limit do
            _lastupdate_spread = _lastupdate_spread + limit
            self:DoRolls()
        end
    end


    -- Debug.
    function self:GetDebugString()
        return string.format("Miasma enabled: %s || grid nodes: %d",
            enabled and "ON" or "OFF",
            _cached_miasma_indexes_count
        )
    end
    function self:DebugRoll()
        print("Miasma rolled action:", self:DoRolls() or "NONE")
    end
    function self:DebugSpawn()
        if ThePlayer then
            local x, y, z = ThePlayer.Transform:GetWorldPosition()
            self:CreateMiasmaAtPoint(x, y, z)
        end
    end
end)

return MiasmaManager
