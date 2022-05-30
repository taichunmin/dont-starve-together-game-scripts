local prefabs =
{
    "antlion",
}

local function OnTimerDone(inst, data)
    if data.name == "spawndelay" then
        inst:RemoveEventCallback("timerdone", OnTimerDone)
        local antlion = SpawnPrefab("antlion")
        inst.components.entitytracker:TrackEntity("antlion", antlion)
        inst:ListenForEvent("death", inst._onantliondeath, antlion)
        antlion.Transform:SetPosition(inst.Transform:GetWorldPosition())
        antlion.sg:GoToState("enterworld")
    end
end

local function OnSandstormChanged(inst, active)
    if active then
        if not (inst.spawned or inst.killed) then
            inst.spawned = true
            inst.components.timer:StopTimer("spawndelay")
            if inst.components.entitytracker:GetEntity("antlion") == nil then
                inst:ListenForEvent("timerdone", OnTimerDone)
                inst.components.timer:StartTimer("spawndelay", GetRandomMinMax(10, 20))
            end
        end
    elseif inst.spawned then
        inst.spawned = nil
        inst:RemoveEventCallback("timerdone", OnTimerDone)
        inst.components.timer:StopTimer("spawndelay")
    end
end

local function OnStopSummer(inst)
    inst.killed = nil
end

local function OnInit(inst)
    inst:WatchWorldState("stopsummer", OnStopSummer)
    inst:ListenForEvent("ms_stormchanged", function(src, data)
            if data.stormtype == STORM_TYPES.SANDSTORM then
                OnSandstormChanged(inst, data.setting)
            end
        end, TheWorld)
    if not TheWorld.state.issummer then
        OnStopSummer(inst)
    end
    OnSandstormChanged(inst, TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive())
end

local function OnSave(inst, data)
    data.spawned = inst.spawned or nil
    data.killed = inst.killed or nil
end

local function OnLoad(inst, data)
    inst.killed = data ~= nil and data.killed or nil

    if data ~= nil and data.spawned then
        if not inst.spawned then
            inst.spawned = true
            if inst.components.timer:TimerExists("spawndelay") then
                inst:ListenForEvent("timerdone", OnTimerDone)
            end
        end
    else
        if inst.spawned then
            inst.spawned = nil
            inst:RemoveEventCallback("timerdone", OnTimerDone)
        end
        inst.components.timer:StopTimer("spawndelay")
    end
end

local function OnLoadPostPass(inst)--, ents, data)
    local antlion = inst.components.entitytracker:GetEntity("antlion")
    if antlion ~= nil then
        inst:ListenForEvent("death", inst._onantliondeath, antlion)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("timer")
    inst:AddComponent("entitytracker")

    inst:DoTaskInTime(0, OnInit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst._onantliondeath = function(antlion)
        if inst.components.entitytracker:GetEntity("antlion") == antlion then
            inst.killed = true
            inst.components.entitytracker:ForgetEntity("antlion")
        end
    end

    return inst
end

return Prefab("antlion_spawner", fn, nil, prefabs)
