local prefabs =
{
    "dragonfly",
}

local function OnKilled(inst)
    inst.components.timer:StartTimer("regen_dragonfly", TUNING.DRAGONFLY_RESPAWN_TIME)
end

local function GenerateNewDragon(inst)
    inst.components.childspawner:AddChildrenInside(1)
    inst.components.childspawner:StartSpawning()
end

local function ontimerdone(inst, data)
    if data.name == "regen_dragonfly" then
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "dragonfly"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(TUNING.DRAGONFLY_SPAWN_TIME, 0)
    inst.components.childspawner.onchildkilledfn = OnKilled
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(onspawned)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst.ponds = {}
    inst.engageddfly = nil

    inst:ListenForEvent("dragonflyengaged", OnDragonflyEngaged)
    inst._onremovedragonfly = function(dragonfly) Disengage(inst, dragonfly) end

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
