require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/spider_mound_mutated.zip"),
    Asset("MINIMAP_IMAGE", "spidermoonden"),
}

local prefabs =
{
    "spider_moon",

    --loot
    "rocks",
    "moonglass",
    "silk",
    "spidergland",
    "silk",
    "moonrocknugget",

    --fx
    "rock_break_fx",
}

SetSharedLootTable('moon_spider_hole',
{
    {"rocks",           1.00},
    {"moonglass",       1.00},
    {"silk",            1.00},
    {"moonrocknugget",  1.00},
    {"moonrocknugget",  0.50},
    {"spidergland",     0.25},
    {"silk",            0.50},
})

local SMALL = 1
local MEDIUM = 2
local LARGE = 3

local function set_stage(inst, workleft, play_grow_sound)
    local new_stage = (workleft * 4 <= TUNING.MOONSPIDERDEN_WORK and SMALL)
            or (workleft * 2 <= TUNING.MOONSPIDERDEN_WORK and MEDIUM)
            or LARGE

    inst.components.childspawner:SetMaxChildren(TUNING.MOONSPIDERDEN_SPIDERS[new_stage])
    inst.components.childspawner:SetMaxEmergencyChildren(TUNING.MOONSPIDERDEN_EMERGENCY_WARRIORS[new_stage])
    inst.components.childspawner:SetEmergencyRadius(TUNING.MOONSPIDERDEN_EMERGENCY_RADIUS[new_stage])

    if inst._stage ~= nil and inst._stage == (new_stage - 1) then
        if inst._stage == SMALL and new_stage == MEDIUM then
            inst.AnimState:PlayAnimation("grow_low_to_med")
            inst.AnimState:PushAnimation("med")
        elseif inst._stage == MEDIUM and new_stage == LARGE then
            inst.AnimState:PlayAnimation("grow_med_to_full")
            inst.AnimState:PushAnimation("full")
        end

        if play_grow_sound then
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_grow")
        end
    else
        inst.AnimState:PlayAnimation((new_stage == SMALL and "low") or (new_stage == MEDIUM and "med") or "full")
    end

    inst.GroundCreepEntity:SetRadius(TUNING.MOONSPIDERDEN_CREEPRADIUS[new_stage])
    inst._num_investigators = TUNING.MOONSPIDERDEN_MAX_INVESTIGATORS[new_stage]

    inst._stage = new_stage
end

---------------------------------------------------------------------------
---- WORKABLE REGENERATION TASK MANAGEMENT ----
---------------------------------------------------------------------------

local function stop_regen_task(inst)
    if inst._regen_task ~= nil then
        inst._regen_task:Cancel()
        inst._regen_task = nil
    end
end

local function try_work_regen(inst)
    if inst.components.workable ~= nil and inst.components.workable.workleft < TUNING.MOONSPIDERDEN_WORK then
        local new_work_amount = inst.components.workable.workleft + 1
        set_stage(inst, new_work_amount, true)
        inst.components.workable:SetWorkLeft(new_work_amount)

        -- If we've regenerated back to our max work amount, end the task. We'll start it up again the next time we get worked on.
        if new_work_amount == TUNING.MOONSPIDERDEN_WORK then
            stop_regen_task(inst)
        end
    end
end

local function start_regen_task(inst)
    if inst._regen_task == nil then
        inst._regen_task = inst:DoPeriodicTask(TUNING.MOONSPIDERDEN_WORK_REGENTIME, try_work_regen)
    end
end

---------------------------------------------------------------------------

local function push_twitch_idle(inst)
    if inst.components.workable ~= nil and (inst.components.workable.workleft * 2) > TUNING.MOONSPIDERDEN_WORK then
        inst.AnimState:PlayAnimation("twitch")
        inst.AnimState:PushAnimation("full")
    end
end

local function start_twitch_idle(inst)
    if inst._idle_task == nil then
        inst._idle_task = inst:DoPeriodicTask(15 + math.random() * 5, push_twitch_idle)
    end
end

local function stop_twitch_idle(inst)
    if inst._idle_task ~= nil then
        inst._idle_task:Cancel()
        inst._idle_task = nil
    end
end

---------------------------------------------------------------------------

local function IsInvestigator(child)
    return child.components.knownlocations:GetLocation("investigate") ~= nil
end

local function SpawnInvestigators(inst, data)
    if inst.components.childspawner ~= nil then
        local num_to_release = math.min(inst._num_investigators or 2, inst.components.childspawner.childreninside)
        local num_investigators = inst.components.childspawner:CountChildrenOutside(IsInvestigator)
        num_to_release = num_to_release - num_investigators
        local targetpos = data ~= nil and data.target ~= nil and data.target:GetPosition() or nil
        for k = 1, num_to_release do
            local spider = inst.components.childspawner:SpawnChild()
            if spider ~= nil and targetpos ~= nil then
                spider.components.knownlocations:RememberLocation("investigate", targetpos)
            end
        end

        push_twitch_idle(inst)
    end
end

local function SummonChildren(inst, data)
    if inst.components.childspawner ~= nil then
        local children_released = inst.components.childspawner:ReleaseAllChildren()

        for i,v in ipairs(children_released) do
            v:AddDebuff("spider_summoned_buff", "spider_summoned_buff")
        end
    end

    push_twitch_idle(inst)
end

---------------------------------------------------------------------------

local function OnQuakeBegin(inst)
    if inst.components.childspawner ~= nil then
        for _, child in pairs(inst.components.childspawner.childrenoutside) do
            child._quaking = true
            if child.components.sleeper ~= nil then
                child.components.sleeper:WakeUp()
            end
        end
    end
end

local function OnQuakeEnd(inst)
    if inst.components.childspawner ~= nil then
        for _, child in pairs(inst.components.childspawner.childrenoutside) do
            child._quaking = nil
        end
    end
end

---------------------------------------------------------------------------

local function spawner_onworked(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
        inst.components.lootdropper:DropLoot(pos)

        stop_regen_task(inst)
        inst:Remove()
    else
        set_stage(inst, workleft, false)
        start_regen_task(inst)
    end

    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren(worker)
    end
end

local function on_workable_load(inst)
    set_stage(inst, inst.components.workable.workleft, false)

    if inst.components.workable.workleft < TUNING.MOONSPIDERDEN_WORK then
        start_regen_task(inst)
    end
end

---------------------------------------------------------------------------

local function on_save(inst, data)
    if inst._sleep_start_time ~= nil and (inst.components.workable.workleft < inst.components.workable.maxwork) then
        local time_since_sleep = GetTime() - inst._sleep_start_time

        -- Do 'proper' rounding, so that we're closer to the correct amount of work than we would be
        -- just from a floor or ceiling.
        local work_regen_during_sleep = math.floor((time_since_sleep / TUNING.MOONSPIDERDEN_WORK_REGENTIME) + 0.5)

        if work_regen_during_sleep > 0 then
            data.sleeping_work_regen = work_regen_during_sleep
        end
    end
end

local function on_load(inst, data)
    if data ~= nil and data.sleeping_work_regen ~= nil then
        local new_work_amount = math.min(inst.components.workable.maxwork, inst.components.workable.workleft + data.sleeping_work_regen)
        inst.components.workable:SetWorkLeft(new_work_amount)
        set_stage(inst, new_work_amount, true)

        -- If we've regenerated back to our max work amount, end the regeneration task (we may have started it in on_workable_load)
        -- We'll start it up again the next time we get worked on.
        if new_work_amount == TUNING.MOONSPIDERDEN_WORK then
            stop_regen_task(inst)
        end
    end
end

local function on_sleep(inst)
    stop_twitch_idle(inst)

    inst._sleep_start_time = GetTime()
    stop_regen_task(inst)
end

local function on_wake(inst)
    start_twitch_idle(inst)

    if inst._sleep_start_time ~= nil and inst.components.workable ~= nil and (inst.components.workable.workleft < inst.components.workable.maxwork) then
        local time_since_sleep = GetTime() - inst._sleep_start_time

        -- Do 'proper' rounding, so that we're closer to the correct amount of work than we would be
        -- just from a floor or ceiling.
        local work_regen_during_sleep = math.floor((time_since_sleep / TUNING.MOONSPIDERDEN_WORK_REGENTIME) + 0.5)

        if work_regen_during_sleep > 0 then
            local new_work_amount = math.min(inst.components.workable.maxwork, inst.components.workable.workleft + work_regen_during_sleep)
            inst.components.workable:SetWorkLeft(new_work_amount)

            set_stage(inst, new_work_amount, true)
        end

        -- If we still haven't hit our maxwork, we need to restart the regen task.
        if inst.components.workable.workleft < inst.components.workable.maxwork then
            start_regen_task(inst)
        end
    end

    inst._sleep_start_time = nil
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MOONSPIDERDEN_RELEASE_TIME, TUNING.MOONSPIDERDEN_SPIDER_REGENTIME)
end

local function OnGoHome(inst, child)
    -- Drops the hat before it goes home if it has any
    local hat = child.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if hat ~= nil then
        child.components.inventory:DropItem(hat)
    end
end

local function moonspiderden_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.entity:AddGroundCreepEntity()
    inst.GroundCreepEntity:SetRadius(TUNING.MOONSPIDERDEN_CREEPRADIUS[LARGE])

    MakeObstaclePhysics(inst, 2)

    inst.AnimState:SetBank("spider_mound_mutated")
    inst.AnimState:SetBuild("spider_mound_mutated")
    inst.AnimState:PlayAnimation("full")

    inst.scrapbook_anim = "full"

    inst.MiniMapEntity:SetIcon("spidermoonden.png")

    inst:AddTag("spiderden")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetMaxWork(TUNING.MOONSPIDERDEN_WORK)
    inst.components.workable:SetWorkLeft(TUNING.MOONSPIDERDEN_WORK)
    inst.components.workable:SetOnWorkCallback(spawner_onworked)
    inst.components.workable.savestate = true
    inst.components.workable:SetOnLoadFn(on_workable_load)

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(TUNING.MOONSPIDERDEN_SPIDER_REGENTIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.MOONSPIDERDEN_RELEASE_TIME)
    inst.components.childspawner:SetGoHomeFn(OnGoHome)

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MOONSPIDERDEN_RELEASE_TIME, TUNING.MOONSPIDERDEN_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MOONSPIDERDEN_SPIDER_REGENTIME, TUNING.MOONSPIDERDEN_ENABLED)
    if not TUNING.MOONSPIDERDEN_ENABLED then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "spider_moon"
    inst.components.childspawner.emergencychildname = "spider_moon"
    inst.components.childspawner.emergencychildrenperplayer = TUNING.MOONSPIDERDEN_EMERGENCY_WARRIORS[LARGE]
    inst.components.childspawner.canemergencyspawn = TUNING.MOONSPIDERDEN_ENABLED

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('moon_spider_hole')

    inst:ListenForEvent("creepactivate", SpawnInvestigators)
    inst:ListenForEvent("startquake", function() OnQuakeBegin(inst) end, TheWorld.net)
    inst:ListenForEvent("endquake", function() OnQuakeEnd(inst) end, TheWorld.net)

    MakeHauntableWork(inst)

    start_twitch_idle(inst)

    set_stage(inst, TUNING.MOONSPIDERDEN_WORK, false)

    inst.components.childspawner:StartSpawning()

    inst.OnEntitySleep = on_sleep
    inst.OnEntityWake = on_wake

    inst.OnSave = on_save
    inst.OnLoad = on_load
    inst.OnPreLoad = OnPreLoad

    inst.SummonChildren = SummonChildren

    MakeSnowCovered(inst)

    return inst
end

return Prefab("moonspiderden", moonspiderden_fn, assets, prefabs)