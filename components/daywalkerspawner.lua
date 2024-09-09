local function OnRegisterDayWalkerSpawningPoint(inst, spawnpoint)
    -- Assume the component still exists.
    inst.components.daywalkerspawner:TryToRegisterSpawningPoint(spawnpoint)
end

local DayWalkerSpawner = Class(function(self, inst)
    assert(TheWorld.ismastersim, "DayWalkerSpawner should not exist on the client")

    self.inst = inst

    self.days_to_spawn = 0
    self.power_level = 1
    --self.daywalker = nil
    self.spawnpoints = {}

    inst:ListenForEvent("ms_registerdaywalkerspawningground", OnRegisterDayWalkerSpawningPoint)
end)


function DayWalkerSpawner:UnregisterDayWalkerSpawningPoint(spawnpoint)
    table.removearrayvalue(self.spawnpoints, spawnpoint)
end

function DayWalkerSpawner:RegisterDayWalkerSpawningPoint(spawnpoint)
    -- NOTES(JBK): This should not be called directly it exists for mods to get access to it.
    table.insert(self.spawnpoints, spawnpoint)
    self.inst:ListenForEvent("onremove", function() self:UnregisterDayWalkerSpawningPoint(spawnpoint) end, spawnpoint)
end

function DayWalkerSpawner:TryToRegisterSpawningPoint(spawnpoint)
    if table.contains(self.spawnpoints, spawnpoint) then
        return false
    end

    self:RegisterDayWalkerSpawningPoint(spawnpoint)
    return true
end

local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "NPC_workable", "structure", "plant", "tree" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "locomotor", "FX", --[["NOCLICK",]] "DECOR", "INLIMBO" }
local STRUCTURES_TAGS = {"structure", "blocker"}
local CANT_SPAWN_NEAR_TAGS = {"antlion_sinkhole_blocker"}
local IS_CLEAR_AREA_RADIUS = TILE_SCALE * 2.5
local DESTROY_AREA_RADIUS = TILE_SCALE * 2.5
local NO_PLAYER_RADIUS = 35

local ARENA_RADIUS = TILE_SCALE * 1.5 -- Must be <= IS_CLEAR_AREA_RADIUS!
local ARENA_PILLARS = 3

function DayWalkerSpawner:IncrementPowerLevel()
    self.power_level = math.min(self.power_level + 1, 2)
end

function DayWalkerSpawner:GetPowerLevel()
    return self.power_level
end

function DayWalkerSpawner:IsValidSpawningPoint(x, y, z)
    for dx = -1, 1 do
        for dz = -1, 1 do
            if not TheWorld.Map:IsAboveGroundAtPoint(x + dx * TILE_SCALE, 0, z + dz * TILE_SCALE, false) then
                return false
            end
        end
    end
    return true
end

function DayWalkerSpawner:SpawnDayWalkerArena(x, y, z) -- NOTES(JBK): This should not be called directly it exists for mods to get access to it.
	local daywalker = SpawnPrefab("daywalker")
	daywalker.Transform:SetPosition(x, y, z)

	local todestroy = TheSim:FindEntities(x, y, z, DESTROY_AREA_RADIUS, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
	for i, v in ipairs(todestroy) do
		if v:IsValid() then
			local isworkable = false
			if v:HasTag("structure") then
				if v.components.workable ~= nil then
					isworkable = true
				else
					v:Remove()
				end
			elseif v:HasTag("plant") or v:HasTag("tree") then
				v:Remove()
			elseif v.components.workable ~= nil then
				local work_action = v.components.workable:GetWorkAction()
				--V2C: nil action for NPC_workable (e.g. campfires)
				--     allow digging spawners (e.g. rabbithole)
				isworkable = (
					(work_action == nil and v:HasTag("NPC_workable")) or
					(v.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
				)
			end

			if isworkable then
				v.components.workable:Destroy(daywalker)
				if v:IsValid() and v:HasTag("stump") then
					v:Remove()
				end
			end
		end
    end

    for i = 1, ARENA_PILLARS do
		local theta = i * TWOPI / ARENA_PILLARS + PI * 3 / 4
		local px, pz = x + math.cos(theta) * ARENA_RADIUS,  z - math.sin(theta) * ARENA_RADIUS
        local pillar = SpawnPrefab("daywalker_pillar")
        pillar.Transform:SetPosition(px, 0, pz)
		pillar:SetPrisoner(daywalker)
    end

    return daywalker
end

function DayWalkerSpawner:FindBestSpawningPoint()
    local structuresatspawnpoints = {}
    local x, y, z
    local valid = false
    local spawnpointscount = #self.spawnpoints
    if spawnpointscount == 0 then
        return nil, nil, nil -- No point.
    end

    for i, v in ipairs(self.spawnpoints) do
        x, y, z = v.Transform:GetWorldPosition()
        if self:IsValidSpawningPoint(x, y, z) and not IsAnyPlayerInRange(x, y, z, NO_PLAYER_RADIUS) then
            if TheSim:FindEntities(x, y, z, IS_CLEAR_AREA_RADIUS, CANT_SPAWN_NEAR_TAGS)[1] == nil then
                local structures = #TheSim:FindEntities(x, y, z, IS_CLEAR_AREA_RADIUS, nil, nil, STRUCTURES_TAGS)
                if structures == 0 then
                    valid = true -- No structures nearby and roomy for tiles.
                    break
                end
                structuresatspawnpoints[v] = structures
            end
        end
    end

    if not valid then
        local best_count = 12345
        for spawner, structs in pairs(structuresatspawnpoints) do
            if structs < best_count then
                best_count = structs
                x, y, z = spawner.Transform:GetWorldPosition()
                valid = true -- Lowest amount of structures and roomy for tiles.
            end
        end
    end

    if not valid then
        local spawner = self.spawnpoints[math.random(spawnpointscount)]
        local pos = spawner:GetPosition()
        x, y, z = pos:Get()

        local function IsValidSpawningPoint_Bridge(pt)
            return self:IsValidSpawningPoint(pt.x, pt.y, pt.z)
        end
        
        for r = 5, 15, 5 do
            local offset = FindWalkableOffset(pos, math.random() * TWOPI, r, 8, false, false, IsValidSpawningPoint_Bridge)
            if offset ~= nil then
                x = x + offset.x
                z = z + offset.z
                valid = true -- Do not care for amount of structures but it is roomy for tiles.
                break
            end
        end
    end

    return x, y, z
end

function DayWalkerSpawner:TryToSpawnDayWalkerArena()
    self.spawnpoints = shuffleArray(self.spawnpoints) -- Randomize outside of trying to find a good spawning point.

    local x, y, z = self:FindBestSpawningPoint()

    if x ~= nil then
        x, y, z = TheWorld.Map:GetTileCenterPoint(x, y, z)
        return self:SpawnDayWalkerArena(x, y, z)
    end
    return nil
end

function DayWalkerSpawner:OnDayChange()
    if self.daywalker ~= nil then
        return
    end

    local shard_daywalkerspawner = TheWorld.shard.components.shard_daywalkerspawner
    if shard_daywalkerspawner ~= nil and shard_daywalkerspawner:GetLocationName() ~= "cavejail" then
        return
    end

    --print("OnDayChange", self.days_to_spawn)
    local days_to_spawn = self.days_to_spawn
    if days_to_spawn > 0 then
        self.days_to_spawn = days_to_spawn - 1
        return
    end

    local daywalker = self:TryToSpawnDayWalkerArena()
    if daywalker == nil then
        return
    end

    self:WatchDaywalker(daywalker)
    self.days_to_spawn = TUNING.DAYWALKER_RESPAWN_DAYS_COUNT
end

function DayWalkerSpawner:WatchDaywalker(daywalker)
    self.daywalker = daywalker
    self.inst:ListenForEvent("onremove", function()
		if self.daywalker.defeated then
			self:IncrementPowerLevel()
            Shard_SyncBossDefeated("daywalker")
		end
        self.daywalker = nil
    end, self.daywalker)
end

function DayWalkerSpawner:OnPostInit()
    if TUNING.SPAWN_DAYWALKER then
        self:WatchWorldState("cycles", self.OnDayChange)
        if self.days_to_spawn <= 0 then
            -- NOTES(JBK): Try to do a spawn in this case it means the component has yet to try to spawn one or failed to spawn one in an attempt.
            self:OnDayChange()
        end
    end
end

function DayWalkerSpawner:OnSave()
    local data = {
        days_to_spawn = self.days_to_spawn,
        power_level = self.power_level,
    }
    local refs = nil

    if self.daywalker ~= nil then
        local daywalker_GUID = self.daywalker.GUID
        data.daywalker_GUID = daywalker_GUID
        refs = {daywalker_GUID}
    end

    return data, refs
end

function DayWalkerSpawner:OnLoad(data)
    if not data then
        return
    end

    if data.days_to_spawn then
        self.days_to_spawn = math.min(TUNING.DAYWALKER_RESPAWN_DAYS_COUNT, data.days_to_spawn)
    end
    self.power_level = data.power_level or self.power_level
end

function DayWalkerSpawner:LoadPostPass(ents, data)
    local daywalker_GUID = data.daywalker_GUID
    if daywalker_GUID ~= nil then
        local daywalker = ents[daywalker_GUID]
        if daywalker ~= nil and daywalker.entity ~= nil then
            self:WatchDaywalker(daywalker.entity)
        end
    end
end

return DayWalkerSpawner
