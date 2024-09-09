local assets =
{
    Asset("ANIM", "anim/boatrace_checkpoint_indicator.zip"),
}

-- Music functions
local function UpdateBoatraceMusic(inst)
    -- We should only really need the largest boat radius,
    -- but might as well give a bit of leeway.
    if ThePlayer ~= nil and ThePlayer:IsNear(inst, 1.5 * TUNING.BOAT.RADIUS) then
        ThePlayer:PushEvent("playboatracemusic")
    end
end

local function OnMusicDirty(inst)
    if TheNet:IsDedicated() then return end

    if not inst._boatrace_active:value() then
        if inst._music_task then
            inst._music_task:Cancel()
            inst._music_task = nil
        end
    elseif not inst._music_task then
        inst._music_task = inst:DoPeriodicTask(1, UpdateBoatraceMusic)
        UpdateBoatraceMusic(inst)
    end
end

--
local function DoUpdate(inst, racestart)
    if not racestart then return end

    if inst.parent and inst.parent.finished then
        if not inst._finished
                and not inst.AnimState:IsCurrentAnimation("idle_race_appear")
                and not inst.AnimState:IsCurrentAnimation("disappear") then
            inst.AnimState:PlayAnimation("disappear",false)
            inst.AnimState:PushAnimation("idle_race_appear",false)

            inst._finished = true
        end
        return
    end

    local checkpoints = racestart:GetCheckpoints()
    if not checkpoints or GetTableSize(checkpoints) == 0 then
        return
    end

    local mindsq = math.huge
    local closest_checkpoint = nil

    local beacons = racestart:GetBeacons()
    if beacons then
        local x, _, z = inst.Transform:GetWorldPosition()
        for checkpoint in pairs(checkpoints) do
            if not beacons[inst] or not beacons[inst][checkpoint] then
                local dsq = checkpoint:GetDistanceSqToPoint(x, 0, z)

                if dsq < mindsq then
                    mindsq = dsq
                    closest_checkpoint = checkpoint
                end
            end
        end

        -- If we're out of checkpoints, we should probably go back to the start
        closest_checkpoint = closest_checkpoint or racestart
    end

    if closest_checkpoint then
        if closest_checkpoint ~= inst._current_checkpoint then
            inst._current_checkpoint = closest_checkpoint
        end

        inst.Transform:SetRotation(inst:GetAngleToPoint(inst._current_checkpoint.Transform:GetWorldPosition()) - 90)
    end
end

--
local function OnRaceStart(inst, start)
    inst._start = start
    inst:ListenForEvent("onremove", inst._on_start_removed, start)

    inst.AnimState:PlayAnimation("idle_race_disappear")
    inst.AnimState:PushAnimation("appear", false)
    inst.AnimState:PushAnimation("idle_marker", true)

    inst.components.timer:StartTimer("doupdate", 0)

    if inst._boatrace_active:value() ~= true then
        inst._boatrace_active:set(true)
        OnMusicDirty(inst)
    end
end

local function OnRaceEnd(inst)
    inst.components.timer:StopTimer("doupdate")

    -- If the start point isn't nil, it didn't die! Great. Remove our listener.
    if inst._start then
        inst:RemoveEventCallback("onremove", inst._on_start_removed, inst._start)
        inst._start = nil
    end

    inst:DoTaskInTime(5, inst.Remove)
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("disappear")

    if inst._boatrace_active:value() ~= false then
        inst._boatrace_active:set(false)
        OnMusicDirty(inst)
    end
end

local function OnCheckpointFound(inst)
    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:PushAnimation("idle_closed")
    inst.components.timer:PauseTimer("doupdate")
    inst.components.timer:StartTimer("unpauseupdate", 2.8)
end

local function OnTimerDone(inst, data)
    if data.name == "doupdate" then
        DoUpdate(inst, inst._start)
        inst.components.timer:StartTimer("doupdate", 0.5)
    elseif data.name == "unpauseupdate" then

        -- Do an update here to avoid popping after re-appearing.
        DoUpdate(inst, inst._start)
        inst.AnimState:PlayAnimation("appear")
        inst.AnimState:PushAnimation("idle_marker", true)
        inst.components.timer:ResumeTimer("doupdate")
    end
end

local function SetBoatRaceIndex(inst, index)
    inst.AnimState:OverrideSymbol("pointer_tail_art", "boatrace_checkpoint_indicator", "pointer_tail"..index)
    inst.AnimState:PlayAnimation("idle_race_appear")
    inst._index = index
end

local function OnBoatRaceIdleDisappear(inst)
    if not inst.AnimState:IsCurrentAnimation("idle_race_disappear") then
        inst.AnimState:PlayAnimation("idle_race_disappear")
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function GetCheckpoints(inst)
    if not inst._start or not inst._start.GetCheckpoints then
        return nil
    else
        return inst._start:GetCheckpoints()
    end
end

--
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("boatrace_checkpoint_indicator")
    inst.AnimState:SetBank("boatrace_checkpoint_indicator")
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:PushAnimation("idle_marker", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
    inst.AnimState:SetFinalOffset(2)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst:AddTag("boatrace_proximitybeacon") -- From boatrace_proximitybeacon component

    inst._boatrace_active = net_bool(inst.GUID, "boatrace_checkpoint_indicator._boatrace_active", "musicdirty")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("musicdirty", OnMusicDirty)

        return inst
    end

    --inst._current_checkpoint = nil
    --inst._start = nil
    inst._on_start_removed = function()
        inst._start = nil
    end

    inst.GetCheckpoints = GetCheckpoints

    inst.persists = false

    local boatrace_proximitybeacon = inst:AddComponent("boatrace_proximitybeacon")
    boatrace_proximitybeacon:SetBoatraceStartedFn(OnRaceStart)
    boatrace_proximitybeacon:SetBoatraceFinishedFn(OnRaceEnd)

    inst:AddComponent("timer")

    inst:ListenForEvent("checkpoint_found", OnCheckpointFound)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("boatrace_setindex", SetBoatRaceIndex)
    inst:ListenForEvent("boatrace_idle_disappear", OnBoatRaceIdleDisappear)

    return inst
end

return Prefab("boatrace_checkpoint_indicator", fn, assets)
