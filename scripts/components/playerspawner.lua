--------------------------------------------------------------------------
--[[ PlayerSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "PlayerSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MODES =
{
    fixed = "Fixed",
    scatter = "Scatter",
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _mode = "fixed"
local _masterpt = nil
local _openpts = {}
local _usedpts = {}

local _players_spawned = {} -- tracks if a player has spawned in before or not

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetNextSpawnPosition()
    if next(_openpts) == nil then
        print("No registered spawn points")
        return 0, 0, 0
    end

    local nextpoint
    if _mode == "scatter" then
        local nexti = math.min(math.floor(easing.inQuart(math.random(), 1, #_openpts, 1)), #_openpts)
        nextpoint = _openpts[nexti]
        table.remove(_openpts, nexti)
        table.insert(_usedpts, nextpoint)
    else --default to "fixed"
        if _masterpt == nil then
            print("No master spawn point")
            _masterpt = _openpts[1]
        end
        nextpoint = _masterpt
        for i, v in ipairs(_openpts) do
            if v == nextpoint then
                table.remove(_openpts, i)
                table.insert(_usedpts, nextpoint)
                break
            end
        end
    end

    if next(_openpts) == nil then
        local swap = _openpts
        _openpts = _usedpts
        _usedpts = swap
    end

    local x, y, z = nextpoint.Transform:GetWorldPosition()
    return x, 0, z
end

local function PlayerRemove(player, deletesession, migrationdata, readytoremove)
    if readytoremove then
        player:OnDespawn(migrationdata)
        if deletesession then
            DeleteUserSession(player)
        else
            player.migration = migrationdata ~= nil and {
                worldid = TheShard:GetShardId(),
                portalid = migrationdata.portalid,
                sessionid = TheWorld.meta.session_identifier,
				dest_x = migrationdata.x,
				dest_y = migrationdata.y,
				dest_z = migrationdata.z,
            } or nil
            SerializeUserSession(player)
        end
        player:Remove()
        if migrationdata ~= nil then
            TheShard:StartMigration(migrationdata.player.userid, migrationdata.worldid)
        end
    else
        player:DoStaticTaskInTime(0, PlayerRemove, deletesession, migrationdata, true)
    end
end

local SPAWN_PROTECTION_DANGER_TAGS = {"hostile", "_combat", "trapdamage", "cursed"}
local SPAWN_PROTECTION_BLOCKED_TAGS = {"blocker", "structure"}

function self:_ShouldEnableSpawnProtection(inst, player, x, y, z, isloading)
    if BRANCH == "dev" then -- NOTES(JBK): Turning this off for faster local tests.
        return false
    end
    if TheWorld.topology.overrides ~= nil and not isloading then
        if TheWorld.topology.overrides.spawnprotection == "always" then
            return true
        elseif TheWorld.topology.overrides.spawnprotection == "never" then
            return false
        else
            if TheWorld.state.cycles <= 1 then return false end
            return TheSim:CountEntities(x, y, z, 16, nil, nil, SPAWN_PROTECTION_DANGER_TAGS) > 1 or
                TheSim:CountEntities(x, y, z, 12, nil, nil, SPAWN_PROTECTION_BLOCKED_TAGS) >= 4 or
                TheSim:CountEntities(x, y, z, 18, nil, nil, SPAWN_PROTECTION_BLOCKED_TAGS) >= 10 or
                TheSim:CountEntities(x, y, z, 24, nil, nil, SPAWN_PROTECTION_BLOCKED_TAGS) >= 15 or
                TheSim:CountEntities(x, y, z, 32, nil, nil, SPAWN_PROTECTION_BLOCKED_TAGS) >= 20
        end
    end
    return false
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerDespawn(inst, player, cb)
    player.components.playercontroller:Enable(false)
    player.components.locomotor:StopMoving()
    player.components.locomotor:Clear()

    --Portal FX
    local fx = SpawnPrefab("spawn_fx_medium_static")
    if fx ~= nil then
        fx.Transform:SetPosition(player.Transform:GetWorldPosition())
    end

    --After colour tween, remove player via task, because
    --we don't want to remove during component update loop
    player.components.colourtweener:StartTween({ 0, 0, 0, 1 }, 13 * FRAMES, cb or PlayerRemove, true)
end

local function OnPlayerDespawnAndDelete(inst, player)
    OnPlayerDespawn(inst, player, function(player) PlayerRemove(player, true) end)
end

local function OnPlayerDespawnAndMigrate(inst, data)
    OnPlayerDespawn(inst, data.player, function(player) PlayerRemove(player, false, data) end)
end

local function OnSetSpawnMode(inst, mode)
    if mode ~= nil or MODES[mode] ~= nil then
        _mode = mode
    else
        _mode = "fixed"
        print('Set spawn mode "'..tostring(mode)..'" -> defaulting to Fixed mode')
    end
end

local function UnregisterSpawnPoint(spawnpt)
    if spawnpt == nil then
        return
    elseif _masterpt == spawnpt then
        _masterpt = nil
    end
    table.removearrayvalue(_openpts, spawnpt)
    table.removearrayvalue(_usedpts, spawnpt)
end

local function OnRegisterSpawnPoint(inst, spawnpt)
    if spawnpt == nil or
        _masterpt == spawnpt or
        table.contains(_openpts, spawnpt) or
        table.contains(_usedpts, spawnpt) then
        return
    elseif _masterpt == nil and spawnpt.master then
        _masterpt = spawnpt
    end
    table.insert(_openpts, spawnpt)
    inst:ListenForEvent("onremove", UnregisterSpawnPoint, spawnpt)
end

local function UnregisterMigrationPortal(portal)
    if portal == nil then return end
    --print("Unregistering portal["..tostring(portal.components.worldmigrator.id).."]")
    table.removearrayvalue(ShardPortals, portal)
end

local function OnRegisterMigrationPortal(inst, portal)
    assert(portal.components.worldmigrator ~= nil, "Tried registering a migration prefab that wasn't a migrator!")
    --print("Registering portal["..tostring(portal.components.worldmigrator.id).."]")

    if portal == nil or table.contains(ShardPortals, portal) then return end

    table.insert(ShardPortals, portal)
    inst:ListenForEvent("onremove", UnregisterMigrationPortal, portal)
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetDestinationPortalLocation(player)
    local portal = nil
    if player.migration.worldid ~= nil and player.migration.portalid ~= nil then
        for i, v in ipairs(ShardPortals) do
            local worldmigrator = v.components.worldmigrator
            if worldmigrator ~= nil and worldmigrator:IsDestinationForPortal(player.migration.worldid, player.migration.portalid) then
                portal = v
                break
            end
        end
    end

    if portal ~= nil then
        print("Player will spawn close to portal #"..tostring(portal.components.worldmigrator.id))
        local x, y, z = portal.Transform:GetWorldPosition()
        local offset = FindWalkableOffset(Vector3(x, 0, z), math.random() * TWOPI, portal:GetPhysicsRadius(0) + .5, 8, false, true, NoHoles)

        --V2C: Do this after caching physical values, since it might remove itself
        --     and spawn in a new "opened" version, making "portal" invalid.
        portal.components.worldmigrator:ActivatedByOther()

        if offset ~= nil then
            return x + offset.x, 0, z + offset.z
        end
        return x, 0, z
    elseif player.migration.dest_x ~= nil and player.migration.dest_y ~= nil and player.migration.dest_z ~= nil then
		local pt = Vector3(player.migration.dest_x, player.migration.dest_y, player.migration.dest_z)
        print("Player will spawn near ".. tostring(pt))
        pt = pt + (FindWalkableOffset(pt, math.random() * TWOPI, 2, 8, false, true, NoHoles) or Vector3(0,0,0))
        return pt:Get()
	else
        print("Player will spawn at default location")
        return GetNextSpawnPosition()
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

inst:ListenForEvent("ms_playerdespawn", OnPlayerDespawn)
inst:ListenForEvent("ms_playerdespawnanddelete", OnPlayerDespawnAndDelete)
inst:ListenForEvent("ms_playerdespawnandmigrate", OnPlayerDespawnAndMigrate)
inst:ListenForEvent("ms_setspawnmode", OnSetSpawnMode)
inst:ListenForEvent("ms_registerspawnpoint", OnRegisterSpawnPoint)
inst:ListenForEvent("ms_registermigrationportal", OnRegisterMigrationPortal)

--------------------------------------------------------------------------
--[[ Deinitialization ]]
--------------------------------------------------------------------------

function self:OnRemoveEntity()
    while #ShardPortals > 0 do
        table.remove(ShardPortals)
    end
end

--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
function self:SpawnAtNextLocation(inst, player)
    local x, y, z = GetNextSpawnPosition()
    self:SpawnAtLocation(inst, player, x, y, z)
end

local SPAWNLIGHT_TAGS = { "spawnlight" }
function self:SpawnAtLocation(inst, player, x, y, z, isloading)
    -- if migrating, resolve map location
    if player.migration ~= nil then
        -- make sure we're not just back in our
        -- origin world from a failed migration
        if player.migration.worldid ~= TheShard:GetShardId() then
            x, y, z = GetDestinationPortalLocation(player)
            for i, v in ipairs(player.migrationpets) do
                if v:IsValid() then
                    if v.Physics ~= nil then
                        v.Physics:Teleport(x, y, z)
                    elseif v.Transform ~= nil then
                        v.Transform:SetPosition(x, y, z)
                    end
                end
            end
        end
        player.migration = nil
        player.migrationpets = nil
    end

	_players_spawned[player.userid] = true

    print(string.format("Spawning player at: [%s] (%2.2f, %2.2f, %2.2f)", isloading and "Load" or MODES[_mode] or _mode, x, y, z))
    player.Physics:Teleport(x, y, z)
    if player.components.areaaware ~= nil then
        player.components.areaaware:UpdatePosition(x, y, z)
    end

    -- Spawn a light if it's dark
    if not inst.state.isday and #TheSim:FindEntities(x, y, z, 4, SPAWNLIGHT_TAGS) <= 0 then
        SpawnPrefab("spawnlight_multiplayer").Transform:SetPosition(x, y, z)
    end

	if self:_ShouldEnableSpawnProtection(inst, player, x, y, z, isloading) then
		print("Enabling Spawn Protection for", player)
        player:AddDebuff("spawnprotectionbuff", "spawnprotectionbuff")
	end

    -- Portal FX, disable/give control to player if they're loading in
    if isloading or _mode ~= "fixed" then
        player.AnimState:SetMultColour(0,0,0,1)
        player:Hide()
        player.components.playercontroller:Enable(false)
        local fx = SpawnPrefab("spawn_fx_medium_static")
        if fx ~= nil then
            fx.entity:SetParent(player.entity)
        end
        player:DoStaticTaskInTime(6*FRAMES, function(inst)
            player:Show()
            player.components.colourtweener:StartTween({1,1,1,1}, 19*FRAMES, function(player)
                player.components.playercontroller:Enable(true)
            end, true)
        end)
    else
        TheWorld:PushEvent("ms_newplayercharacterspawned", { player = player, mode = isloading and "Load" or MODES[_mode] })
    end
end

self.GetAnySpawnPoint = GetNextSpawnPosition

function self:IsPlayersInitialSpawn(player)
	return _players_spawned[player.userid] == nil
end

--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Save/Load functions ]]

function self:OnSave()
	return next(_players_spawned) ~= nil and {_players_spawned = _players_spawned} or nil
end

function self:OnLoad(data)
	if data ~= nil and data._players_spawned ~= nil then
		_players_spawned = data._players_spawned
	end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
