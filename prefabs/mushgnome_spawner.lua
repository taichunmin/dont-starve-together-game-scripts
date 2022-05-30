require("worldsettingsutil")

local assets = nil

local prefabs =
{
    "mushgnome",
}

local ZERO = Vector3(0,0,0)
local function zero_spawn_offset(inst)
    return ZERO
end

local function on_gnome_spawned(inst, gnome)
    gnome:PushEvent("spawn")
end

local function do_spawn_test(inst)
    if not inst.components.childspawner:CanSpawn() then
        if inst._PeriodicSpawnTesting ~= nil then
            inst._PeriodicSpawnTesting:Cancel()
            inst._PeriodicSpawnTesting = nil
        end
        return
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local close_players = nil
    for _, player in ipairs(AllPlayers) do
        if player.components.areaaware ~= nil
                and player.components.areaaware:CurrentlyInTag("MushGnomeSpawnArea") then
            local dsq_to_player = player:GetDistanceSqToPoint(ix, iy, iz)
            if dsq_to_player <= TUNING.MUSHGNOME_SPAWN_RADIUSSQ then
                if close_players == nil then
                    close_players = {}
                end
                table.insert(close_players, player)
            end
        end
    end

    if close_players == nil or #close_players == 0 then
        return
    end

    local gnome = inst.components.childspawner:SpawnChild()
    if gnome == nil then
        return
    end

    local random_player_in_range = close_players[math.random(#close_players)]
    local spawn_distance = Lerp(2, 20, math.sqrt(math.random()))
    local player_position = random_player_in_range:GetPosition()

    local offset = FindWalkableOffset(
        player_position,
        math.random() * PI * 2,
        spawn_distance,
        nil,
        false,
        true
    )
    if offset == nil then
        return
    end

    gnome.Transform:SetPosition((player_position + offset):Get())
end

local TEST_FREQUENCY = 10
local function StartTesting(inst)
    inst._PeriodicSpawnTesting = inst:DoPeriodicTask(TEST_FREQUENCY, do_spawn_test)
end


local function on_entity_wake(inst)
    StartTesting(inst)
end

local function on_entity_sleep(inst)
    if inst._PeriodicSpawnTesting ~= nil then
        inst._PeriodicSpawnTesting:Cancel()
        inst._PeriodicSpawnTesting = nil
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MUSHGNOME_RELEASE_TIME, TUNING.MUSHGNOME_REGEN_TIME)
end

local function spawner()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetSpawnPeriod(TUNING.MUSHGNOME_RELEASE_TIME)
    inst.components.childspawner:SetRegenPeriod(TUNING.MUSHGNOME_REGEN_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.MUSHGNOME_MAX_CHILDREN)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MUSHGNOME_RELEASE_TIME, TUNING.MUSHGNOME_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MUSHGNOME_REGEN_TIME, TUNING.MUSHGNOME_ENABLED)
    if not TUNING.MUSHGNOME_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst.components.childspawner:SetSpawnedFn(on_gnome_spawned)
    inst.components.childspawner:SetOccupiedFn(StartTesting)

    inst.components.childspawner.childname = "mushgnome"
    inst.components.childspawner.overridespawnlocation = zero_spawn_offset

    inst.components.childspawner:StartRegen()

    inst.OnEntityWake = on_entity_wake
    inst.OnEntitySleep = on_entity_sleep

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("mushgnome_spawner", spawner, assets, prefabs)
