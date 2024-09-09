local assets =
{
    Asset("ANIM", "anim/ice_boulder.zip"),
    Asset("MINIMAP_IMAGE", "iceboulder"),
}

local prefabs =
{
    "ice",
    "ice_splash",
}

local UPDATE_STAGE_TIMERNAME = "updatestage"

local STAGES = {
    {
        name = "dryup",
        animation = "dryup",
        showrock = false,
        work = -1,
        isdriedup = true,
    },
    {
        name = "empty",
        animation = "melted",
        showrock = false,
        work = -1,
    },
    {
        name = "short",
        animation = "low",
        showrock = true,
        work = TUNING.ICE_MINE,
        icecount = 2,
    },
    {
        name = "medium",
        animation = "med",
        showrock = true,
        work = TUNING.ICE_MINE*0.67,
        icecount = 2,
    },
    {
        name = "tall",
        animation = "full",
        showrock = true,
        work = TUNING.ICE_MINE*0.67,
        icecount = 3,
    },
}

local STAGE_INDICES = {}
for i, v in ipairs(STAGES) do
    STAGE_INDICES[v.name] = i
end

local function DeserializeStage(inst)
    return inst._stage:value() + 1 -- Back to 1-based index.
end

local function OnStageDirty(inst)
    local ismelt = inst._ismelt:value()
    local stagedata = STAGES[DeserializeStage(inst)]
    if stagedata ~= nil then
        if stagedata.showrock then
            inst.name = STRINGS.NAMES.ROCK_ICE
            inst.no_wet_prefix = false
        else
            inst.name = STRINGS.NAMES.ROCK_ICE_MELTED
            inst.no_wet_prefix = true
        end
    end

    if inst._shouldlocalfx then
        if ismelt and not inst:IsAsleep() and not stagedata.isdriedup then
            local fx = SpawnPrefab("ice_splash")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx.AnimState:PlayAnimation(stagedata.animation)
        end
    end
end

local function SerializeStage(inst, stageindex, source)
    inst._ismelt:set(source == "melt")
    inst._stage:set(stageindex - 1) -- Convert to 0-based index.
    inst:OnStageDirty()
end

local DRYUP_CANT_FLAGS = {"locomotor", "FX"}
local function SetStage(inst, stage, source, snap_to_stage)
    if stage == inst.stage then
        return
    end

    local currentstage = STAGE_INDICES[inst.stage]
    local targetstage = STAGE_INDICES[stage]
    if (source == "melt" or source == "work") then
        if currentstage and currentstage > targetstage then
            if not snap_to_stage then
                targetstage = currentstage - 1
            end
        else
            return
        end
    elseif source == "grow" then
        if currentstage and currentstage < targetstage then
            if not snap_to_stage then
                targetstage = currentstage + 1
            end
        else
            return
        end

        if inst.stage == "dryup" then
            local x, y, z = inst.Transform:GetWorldPosition()
            if #(TheSim:FindEntities(x, y, z, 1.1, nil, DRYUP_CANT_FLAGS)) > 0 then
                return
            end
        end
    end

    inst.stage = STAGES[targetstage].name

    if inst.components.workable ~= nil then
        if source == "work" then
            for i = currentstage, targetstage+1, -1 do
                local pt = inst:GetPosition()
                for i = 1, math.random(STAGES[i].icecount) do
                    inst.components.lootdropper:SpawnLootPrefab("ice", pt)
                end
            end
        end
        if STAGES[targetstage].work < 0 then
            inst.components.workable:SetWorkable(false)
        else
            inst.components.workable:SetWorkLeft(STAGES[targetstage].work)
        end
    end

    if not STAGES[targetstage].showrock then
        inst:Remove()
        return
    end
    SerializeStage(inst, targetstage, source)

    if STAGES[targetstage].isdriedup then
        inst:AddTag("CLASSIFIED")

        inst.persists = false
        if inst:IsAsleep() then
            inst:Remove()
        else
            inst:DoTaskInTime(2, inst.Remove)
        end

    elseif currentstage ~= nil and STAGES[currentstage].isdriedup then
        inst:RemoveTag("CLASSIFIED")
    end

    if STAGES[targetstage].showrock then
        inst.AnimState:PlayAnimation(STAGES[targetstage].animation)

        inst.AnimState:Show("rock")
        if TheWorld.state.snowlevel >= SNOW_THRESH then
            inst.AnimState:Show("snow")
        end
        inst.MiniMapEntity:SetEnabled(true)
        ChangeToWaterObstaclePhysics(inst)
        inst:PushEvent("on_landed")
    else
        -- This will not get hit from early remove above.
        inst.AnimState:Hide("rock")
        inst.AnimState:Hide("snow")
        inst.MiniMapEntity:SetEnabled(false)
        RemovePhysicsColliders(inst)
        inst:PushEvent("on_no_longer_landed")
    end
end

local function OnWorked(inst, worker, workleft, numworks)
    if workleft <= 0 then
        local crit = numworks >= 1000
        local snap_to_stage = crit or not (worker:HasTag("character") or worker:HasTag("shadowminion") or worker:HasTag("boat"))
        inst:SetStage("empty", "work", snap_to_stage)
        if inst.stage == "empty" then
            if inst:IsValid() then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash")
            elseif worker:IsValid() and worker.SoundEmitter ~= nil then
                worker.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash")
            end
        end
    end
end

local function _OnFireMelt(inst)
    inst.firemelttask = nil
    inst:SetStage("dryup", "melt")
end

local function StartFireMelt(inst)
    if inst.firemelttask == nil then
        inst.firemelttask = inst:DoTaskInTime(4, _OnFireMelt)
    end
end

local function StopFireMelt(inst)
    if inst.firemelttask ~= nil then
        inst.firemelttask:Cancel()
        inst.firemelttask = nil
    end
end

local function OnSave(inst, data)
    data.stage = inst.stage
end

local function OnLoad(inst, data)
    if data ~= nil and data.stage ~= nil then
        while inst.stage ~= data.stage do
            inst:SetStage(data.stage)
        end
    end
end

local function GetStatus(inst)
    return inst.stage == "empty" and "MELTED" or nil
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == UPDATE_STAGE_TIMERNAME then
        local shouldgrow = inst._shouldgrow
        local offset = shouldgrow and 1 or -1

        local currentindex = STAGE_INDICES[inst.stage]

        if currentindex ~= nil then
            local targetindex = currentindex + offset

            if targetindex >= 1 and targetindex <= #STAGES then
                local targetstage = STAGES[targetindex].name
                local source = shouldgrow and "grow" or "melt"

                inst:SetStage(targetstage, source)
            end
        end

        if shouldgrow then
            inst.components.timer:StartTimer(UPDATE_STAGE_TIMERNAME, TUNING.SHARKBOI_ROCK_ICE_GROW_TIME)
        else
            inst.components.timer:StartTimer(UPDATE_STAGE_TIMERNAME, TUNING.SHARKBOI_ROCK_ICE_MELT_TIME)
        end
    end
end

local function CleanupTick(inst)
    inst:RemoveEventCallback("ms_cleanupticksharkboiarena", inst._cleanupevent, TheWorld)
    inst._cleanupevent = nil
    inst._shouldgrow = false
    if inst.components.timer:TimerExists(UPDATE_STAGE_TIMERNAME) then
        inst.components.timer:StopTimer(UPDATE_STAGE_TIMERNAME)
    end
    inst.components.timer:StartTimer(UPDATE_STAGE_TIMERNAME, TUNING.SHARKBOI_ROCK_ICE_MELT_TIME)
end
local function CleanupForced(inst)
    if not inst:IsAsleep() then
        local currentstage = STAGE_INDICES[inst.stage]
        local fx = SpawnPrefab("ice_splash")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:PlayAnimation(STAGES[currentstage].animation)
    end
    inst:Remove()
end

local function DoWorkedBy_GameThread(inst, worker, numworks)
    inst.components.workable:WorkedBy(worker, numworks)
end
local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local damage_scale = 0.5
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * damage_scale / boat_physics.max_velocity + 0.5)
        if hit_velocity > 0 then
            inst:DoTaskInTime(0, DoWorkedBy_GameThread, data.other, hit_velocity * TUNING.ICE_MINE) -- Get off of physics thread.
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("ice_boulder")
    inst.AnimState:SetBuild("ice_boulder")

    MakeWaterObstaclePhysics(inst, 1, 2, 0.75)

    inst.MiniMapEntity:SetIcon("iceboulder.png")

    inst:AddTag("frozen")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("floaterobject") -- Not an inventory item that can state change floating.

    MakeSnowCoveredPristine(inst)
    MakeInventoryFloatable(inst, "large", nil, 0.85)
    inst.components.floater.bob_percent = 0

    inst.name = STRINGS.NAMES.ROCK_ICE
    inst.no_wet_prefix = false

    inst.OnStageDirty = OnStageDirty

    inst._ismelt = net_bool(inst.GUID, "rock_ice.ismelt", "stagedirty")
    inst._stage = net_tinybyte(inst.GUID, "rock_ice.stage", "stagedirty")
    inst._stage:set(STAGE_INDICES["tall"])

    inst:SetPrefabNameOverride("rock_ice")

    inst.scrapbook_proxy = "rock_ice"

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        inst._shouldlocalfx = true
        if not TheWorld.ismastersim then
            inst:ListenForEvent("stagedirty", inst.OnStageDirty)
        end
    end

    inst:OnStageDirty()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._shouldgrow = true

    inst.SetStage = SetStage
    inst.OnTimerDone = OnTimerDone

    inst.StartFireMelt = StartFireMelt
    inst.StopFireMelt = StopFireMelt

    inst.CleanupTick = CleanupTick
    inst.CleanupForced = CleanupForced

    inst:AddComponent("lootdropper")
    inst:AddComponent("savedscale")

    inst:AddComponent("timer")
    inst.components.timer:StartTimer(UPDATE_STAGE_TIMERNAME, TUNING.SHARKBOI_ROCK_ICE_GROW_TIME)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ICE_MINE)
    inst.components.workable:SetOnWorkCallback(OnWorked)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:ListenForEvent("firemelt", inst.StartFireMelt)
    inst:ListenForEvent("stopfiremelt", inst.StopFireMelt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    inst:ListenForEvent("timerdone", inst.OnTimerDone)
    inst._cleanupevent = function() inst:CleanupTick() end
    inst:ListenForEvent("ms_cleanupticksharkboiarena", inst._cleanupevent, TheWorld)
    inst:ListenForEvent("ms_cleanedupsharkboiarena", function() inst:CleanupForced() end, TheWorld)

    inst:ListenForEvent("on_collide", OnCollide)

    -- Make sure we start at a good height for starting in a season when it shouldn't start as full
    inst:DoTaskInTime(0, function()
        if inst.stage then
            inst:SetStage(inst.stage)
        elseif TheWorld.state.isspring or TheWorld.state.iswinter then
            inst:SetStage("tall")
        else
            inst:SetStage(math.random() < 0.5 and "medium" or "short")
        end
    end)

    return inst
end

return Prefab("sharkboi_ice_hazard", fn, assets, prefabs)
