require("worldsettingsutil")

local prefabs =
{
    "dragonfly",
}

local DRAGONFLY_SPAWNTIMER = "regen_dragonfly"

local function StartSpawning(inst)
    inst.components.worldsettingstimer:StartTimer(DRAGONFLY_SPAWNTIMER, TUNING.DRAGONFLY_RESPAWN_TIME)
end

local function GenerateNewDragon(inst)
    inst.components.childspawner:AddChildrenInside(1)
    inst.components.childspawner:StartSpawning()
end

local function ontimerdone(inst, data)
    if data.name == DRAGONFLY_SPAWNTIMER then
        GenerateNewDragon(inst)
    end
end

local function onspawned(inst, child)
    local x, y, z = child.Transform:GetWorldPosition()
    child.Transform:SetPosition(x, 20, z)
    child.sg:GoToState("land")
end

local function Disengage(inst, dfly)
    if dfly ~= nil and inst.engageddfly == dfly then
        inst.engageddfly = nil
        inst:RemoveEventCallback("onremove", inst._onremovedragonfly, dfly)

        local data = { engaged = false, dragonfly = dfly }
        for k, v in pairs(inst.ponds) do
            k:PushEvent("dragonflyengaged", data)
        end
    end
end

local function Engage(inst, dfly)
    if inst.engageddfly ~= dfly then
        Disengage(inst, inst.engageddfly)

        if dfly ~= nil then
            inst.engageddfly = dfly
            inst:ListenForEvent("onremove", inst._onremovedragonfly, dfly)
            local data = { engaged = true, dragonfly = dfly }
            for k, v in pairs(inst.ponds) do
                k:PushEvent("dragonflyengaged", data)
            end
        end
    end
end

local function OnDragonflyEngaged(inst, data)
    if data.engaged then
        Engage(inst, data.dragonfly)
    else
        Disengage(inst, data.dragonfly)
    end
end

--retrofit old timers
local function OnPreLoad(inst, data)
    WorldSettings_Timer_PreLoad(inst, data, DRAGONFLY_SPAWNTIMER, TUNING.DRAGONFLY_RESPAWN_TIME)
    WorldSettings_Timer_PreLoad_Fix(inst, data, DRAGONFLY_SPAWNTIMER, 1)
    if data and data.childspawner and data.childspawner.timetonextspawn then
        data.childspawner.timetonextspawn = math.min(data.childspawner.timetonextspawn, TUNING.DRAGONFLY_SPAWN_TIME)
    end
end

local function OnLoadPostPass(inst, newents, data)
    if inst.components.childspawner:CountChildrenOutside() + inst.components.childspawner.childreninside == 0 and
    not inst.components.worldsettingstimer:ActiveTimerExists(DRAGONFLY_SPAWNTIMER) then
        StartSpawning(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "dragonfly"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(TUNING.DRAGONFLY_SPAWN_TIME, 0)
    inst.components.childspawner.onchildkilledfn = StartSpawning
    if not TUNING.SPAWN_DRAGONFLY then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(onspawned)

    inst:AddComponent("worldsettingstimer")
    inst.components.worldsettingstimer:AddTimer(DRAGONFLY_SPAWNTIMER, TUNING.DRAGONFLY_RESPAWN_TIME, TUNING.SPAWN_DRAGONFLY)
    inst:ListenForEvent("timerdone", ontimerdone)

    inst.ponds = {}
    inst.engageddfly = nil

    inst:ListenForEvent("dragonflyengaged", OnDragonflyEngaged)
    inst._onremovedragonfly = function(dragonfly) Disengage(inst, dragonfly) end

    inst.OnPreLoad = OnPreLoad
    inst.OnLoadPostPass = OnLoadPostPass

    local function onremovepond(pond)
        inst.ponds[pond] = nil
    end

    inst:ListenForEvent("ms_registerlavapond", function(src, pond)
        if not inst.ponds[pond] and inst:IsNear(pond, 40) then
            inst.ponds[pond] = true
            inst:ListenForEvent("onremove", onremovepond, pond)
            if inst.engageddfly ~= nil then
                pond:PushEvent("dragonflyengaged", { engaged = true, dragonfly = inst.engageddfly })
            end
        end
    end, TheWorld)

    return inst
end

return Prefab("dragonfly_spawner", fn, nil, prefabs)
