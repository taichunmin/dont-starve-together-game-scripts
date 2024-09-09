local prefabs =
{
    "crabking",
}

local CRABKING_SPAWNTIMER = "regen_crabking"

local ZERO = Vector3(0,0,0)
local function zero_spawn_offset(inst)
    if TheWorld.Map:GetPlatformAtPoint(inst.Transform:GetWorldPosition()) then return end
    return ZERO
end

local function StartSpawning(inst)
    inst.components.worldsettingstimer:StartTimer(CRABKING_SPAWNTIMER, TUNING.CRABKING_RESPAWN_TIME)
end

local function GenerateNewKing(inst)
    inst.components.childspawner:AddChildrenInside(1)
    inst.components.childspawner:StartSpawning()
end

local function ontimerdone(inst, data)
    if data.name == CRABKING_SPAWNTIMER then
        GenerateNewKing(inst)
    end
end

local function OnPreLoad(inst, data)
    if data and data.childspawner then
        data.childspawner.spawning = true
    end
end

local function OnLoadPostPass(inst, newents, data)
    if inst.components.childspawner:CountChildrenOutside() + inst.components.childspawner.childreninside == 0 and
    not inst.components.worldsettingstimer:ActiveTimerExists(CRABKING_SPAWNTIMER) then
        StartSpawning(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")
    inst:AddTag("crabking_spawner")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "crabking"
    inst.components.childspawner.spawnoffscreen = true
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(TUNING.CRABKING_SPAWN_TIME, 0)
    inst.components.childspawner.onchildkilledfn = StartSpawning
    if not TUNING.SPAWN_CRABKING then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner.overridespawnlocation = zero_spawn_offset

    inst:AddComponent("worldsettingstimer")
    inst.components.worldsettingstimer:AddTimer(CRABKING_SPAWNTIMER, TUNING.CRABKING_RESPAWN_TIME, TUNING.SPAWN_CRABKING)
    inst:ListenForEvent("timerdone", ontimerdone)

    inst.OnPreLoad = OnPreLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("crabking_spawner", fn, nil, prefabs)
