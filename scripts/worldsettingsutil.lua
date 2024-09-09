--we don't need inst.components.whatever checks for any of this because all the global functions will have asserts for the required components.
--unless the component could get removed from something like burnable
local function MakePauseTimerFunction(timername)
    return function(inst)
        inst.components.worldsettingstimer:PauseTimer(timername)
    end
end

local function MakeResumeTimerFunction(timername)
    return function(inst)
        inst.components.worldsettingstimer:ResumeTimer(timername)
    end
end

local function MakeStartTimerFunction(timername)
    return function(inst, delay)
        inst.components.worldsettingstimer:StopTimer(timername)
        inst.components.worldsettingstimer:StartTimer(timername, delay)
    end
end

local function MakeStopTimerFunction(timername)
    return function(inst)
        inst.components.worldsettingstimer:StopTimer(timername)
    end
end

----------------------------------------------------------------------
--------------------------CHILDSPAWNER--------------------------------
----------------------------------------------------------------------
local CHILDSPAWNER_SPAWNPERIOD_TIMERNAME = "ChildSpawner_SpawnPeriod"
local CHILDSPAWNER_REGENPERIOD_TIMERNAME = "ChildSpawner_RegenPeriod"

local function On_ChildSpawner_SpawnPeriod_TimerFinished(inst)
    local childspawner = inst.components.childspawner

    if childspawner then
        local dospawn = childspawner.spawning and not childspawner.queued_spawn and childspawner.childreninside > 0
        inst.components.worldsettingstimer:StartTimer(CHILDSPAWNER_SPAWNPERIOD_TIMERNAME, childspawner:GetTimeToNextSpawn(), not dospawn)
        if dospawn then
            if childspawner:CanSpawnOffscreenOrAwake() then
                childspawner:SpawnChild()
            else
                childspawner:QueueSpawnChild()
            end
        end
    end
end

local function On_ChildSpawner_RegenPeriod_TimerFinished(inst)
    local childspawner = inst.components.childspawner

    if childspawner then
        local doregen = childspawner.regening and not (childspawner:IsFull() and childspawner:IsEmergencyFull())
        inst.components.worldsettingstimer:StartTimer(CHILDSPAWNER_REGENPERIOD_TIMERNAME, childspawner:GetTimeToNextRegen(), not doregen)
        if doregen then
            childspawner:DoRegen()
        end
    end
end

local Start_ChildSpawner_SpawnPeriod_Timer = MakeResumeTimerFunction(CHILDSPAWNER_SPAWNPERIOD_TIMERNAME)
local Stop_ChildSpawner_SpawnPeriod_Timer = MakePauseTimerFunction(CHILDSPAWNER_SPAWNPERIOD_TIMERNAME)
local function Set_ChildSpawner_SpawnPeriod_Timer_Time(inst, time)
    inst.components.worldsettingstimer:SetTimeLeft(CHILDSPAWNER_SPAWNPERIOD_TIMERNAME, time)
end

local Start_ChildSpawner_RegenPeriod_Timer = MakeResumeTimerFunction(CHILDSPAWNER_REGENPERIOD_TIMERNAME)
local Stop_ChildSpawner_RegenPeriod_Timer = MakePauseTimerFunction(CHILDSPAWNER_REGENPERIOD_TIMERNAME)

function WorldSettings_ChildSpawner_PreLoad(inst, data, spawnperiod_max, regenperiod_max)
    if data and data.childspawner and not data.worldsettingstimer then
        data.worldsettingstimer = { timers = {} }
        data.worldsettingstimer.timers[CHILDSPAWNER_SPAWNPERIOD_TIMERNAME] = {
            timeleft = math.min(data.childspawner.timetonextspawn, spawnperiod_max) / spawnperiod_max,
            paused = data.childspawner.spawning,
            initial_time = 0,
        }
        data.worldsettingstimer.timers[CHILDSPAWNER_REGENPERIOD_TIMERNAME] = {
            timeleft = math.min(data.childspawner.timetonextregen, regenperiod_max) / regenperiod_max,
            paused = data.childspawner.regening,
            initial_time = 0,
        }
    end
end

function WorldSettings_ChildSpawner_SpawnPeriod(inst, spawnperiod, enabled)
    local childspawner = inst.components.childspawner
    local worldsettingstimer = inst.components.worldsettingstimer
    if not worldsettingstimer then
        inst:AddComponent("worldsettingstimer")
        worldsettingstimer = inst.components.worldsettingstimer
    end

    assert(childspawner, "WorldSettings_ChildSpawner_SpawnPeriod was called without a childspawner component")

    childspawner.useexternaltimer = true
    childspawner.spawntimerstart = Start_ChildSpawner_SpawnPeriod_Timer
    childspawner.spawntimerstop = Stop_ChildSpawner_SpawnPeriod_Timer
    childspawner.spawntimerset = Set_ChildSpawner_SpawnPeriod_Timer_Time

    worldsettingstimer:AddTimer(CHILDSPAWNER_SPAWNPERIOD_TIMERNAME, spawnperiod, enabled, On_ChildSpawner_SpawnPeriod_TimerFinished)
    worldsettingstimer:StartTimer(CHILDSPAWNER_SPAWNPERIOD_TIMERNAME, childspawner:GetTimeToNextSpawn(), not (childspawner.spawning and not childspawner.queued_spawn and childspawner.childreninside > 0))
end

function WorldSettings_ChildSpawner_RegenPeriod(inst, regenperiod, enabled)
    local childspawner = inst.components.childspawner
    local worldsettingstimer = inst.components.worldsettingstimer
    if not worldsettingstimer then
        inst:AddComponent("worldsettingstimer")
        worldsettingstimer = inst.components.worldsettingstimer
    end

    assert(childspawner, "WorldSettings_ChildSpawner_RegenPeriod was called without a childspawner component")

    childspawner.useexternaltimer = true
    childspawner.regentimerstart = Start_ChildSpawner_RegenPeriod_Timer
    childspawner.regentimerstop = Stop_ChildSpawner_RegenPeriod_Timer

    worldsettingstimer:AddTimer(CHILDSPAWNER_REGENPERIOD_TIMERNAME, regenperiod, enabled, On_ChildSpawner_RegenPeriod_TimerFinished)
    worldsettingstimer:StartTimer(CHILDSPAWNER_REGENPERIOD_TIMERNAME, childspawner:GetTimeToNextRegen(), not (childspawner.regening and not (childspawner:IsFull() and childspawner:IsEmergencyFull())))
end

----------------------------------------------------------------------
--------------------------CHILDSPAWNER--------------------------------
----------------------------------------------------------------------

----------------------------------------------------------------------
-----------------------------TIMER------------------------------------
----------------------------------------------------------------------

function WorldSettings_Timer_PreLoad(inst, data, timername, maxtimeleft)
    if data and data.timer and data.timer.timers[timername] then
        if not data.worldsettingstimer then
            data.worldsettingstimer = {timers = {}}
        end
        data.worldsettingstimer.timers[timername] = data.timer.timers[timername]
        if maxtimeleft then
            data.worldsettingstimer.timers[timername].timeleft = math.min(data.worldsettingstimer.timers[timername].timeleft / maxtimeleft, 1)
        end
    end
end
function WorldSettings_Timer_PreLoad_Fix(inst, data, timername, maxmultiplier)
    if data and data.worldsettingstimer and data.worldsettingstimer.timers[timername] then
        data.worldsettingstimer.timers[timername].timeleft = math.min(data.worldsettingstimer.timers[timername].timeleft, maxmultiplier)
    end
end

----------------------------------------------------------------------
-----------------------------TIMER------------------------------------
----------------------------------------------------------------------

----------------------------------------------------------------------
----------------------------SPAWNER-----------------------------------
----------------------------------------------------------------------
local SPAWNER_STARTDELAY_TIMERNAME = "Spawner_SpawnDelay"

local function Start_Spawner_StartDelay_Timer(inst, delay)
    inst.components.spawner.externaltimerfinished = false
    inst.components.worldsettingstimer:StopTimer(SPAWNER_STARTDELAY_TIMERNAME)
    inst.components.worldsettingstimer:StartTimer(SPAWNER_STARTDELAY_TIMERNAME, delay)
end
local function Stop_Spawner_StartDelay_Timer(inst)
    inst.components.spawner.externaltimerfinished = false
    inst.components.worldsettingstimer:StopTimer(SPAWNER_STARTDELAY_TIMERNAME)
end
local function Spawner_StartDelay_Timer_Exists(inst)
    return inst.components.worldsettingstimer:ActiveTimerExists(SPAWNER_STARTDELAY_TIMERNAME)
end

local function On_Spawner_StartDelay_TimerFinished(inst)
    local spawner = inst.components.spawner

    if spawner then
        spawner.externaltimerfinished = true
        if not spawner.spawnoffscreen or inst:IsAsleep() then
            spawner:ReleaseChild()
        end
    end
end

function WorldSettings_Spawner_PreLoad(inst, data, maxstartdelay)
    if data and data.spawner and data.spawner.nextspawntime and not data.worldsettingstimer then
        data.worldsettingstimer = { timers = {} }
        data.worldsettingstimer.timers[SPAWNER_STARTDELAY_TIMERNAME] = {
            timeleft = math.min(data.spawner.nextspawntime, maxstartdelay) / maxstartdelay,
            paused = false,
            initial_time = 0,
        }
    end
end

function WorldSettings_Spawner_SpawnDelay(inst, startdelay, enabled)
    local spawner = inst.components.spawner
    local worldsettingstimer = inst.components.worldsettingstimer
    if not worldsettingstimer then
        inst:AddComponent("worldsettingstimer")
        worldsettingstimer = inst.components.worldsettingstimer
    end

    assert(spawner, "WorldSettings_Spawner_SpawnDelay was called without a spawner component")

    spawner.useexternaltimer = true
    spawner.starttimerfn = Start_Spawner_StartDelay_Timer
    spawner.stoptimerfn = Stop_Spawner_StartDelay_Timer
    spawner.timertestfn = Spawner_StartDelay_Timer_Exists

    worldsettingstimer:AddTimer(SPAWNER_STARTDELAY_TIMERNAME, startdelay, enabled, On_Spawner_StartDelay_TimerFinished)
end

----------------------------------------------------------------------
----------------------------SPAWNER-----------------------------------
----------------------------------------------------------------------

----------------------------------------------------------------------
----------------------------PICKABLE----------------------------------
----------------------------------------------------------------------
local PICKABLE_REGENTIME_TIMERNAME = "Pickable_RegenTime"

local function On_Pickable_RegenTime_TimerFinished(inst)
    local pickable = inst.components.pickable
    if pickable then
        pickable:Regen()
    end
end

local Start_Pickable_RegenTime_Timer = MakeStartTimerFunction(PICKABLE_REGENTIME_TIMERNAME)
local Stop_Pickable_RegenTime_Timer = MakeStopTimerFunction(PICKABLE_REGENTIME_TIMERNAME)
local Pause_Pickable_RegenTime_Timer = MakePauseTimerFunction(PICKABLE_REGENTIME_TIMERNAME)
local Resume_Pickable_RegenTime_Timer = MakeResumeTimerFunction(PICKABLE_REGENTIME_TIMERNAME)
local function Get_Pickable_RegenTime_Timer_Time(inst)
    return inst.components.worldsettingstimer:GetTimeLeft(PICKABLE_REGENTIME_TIMERNAME)
end
local function Set_Pickable_RegenTime_Timer_Time(inst, time)
    inst.components.worldsettingstimer:SetTimeLeft(PICKABLE_REGENTIME_TIMERNAME, time)
end
local function Pickable_RegenTime_Timer_Exists(inst)
    return inst.components.worldsettingstimer:ActiveTimerExists(PICKABLE_REGENTIME_TIMERNAME)
end

function WorldSettings_Pickable_PreLoad(inst, data, maxregentime)
    if data and data.pickable and (data.pickable.pause_time ~= nil or data.pickable.time ~= nil) and not data.worldsettingstimer then
        data.worldsettingstimer = { timers = {} }
        data.worldsettingstimer.timers[PICKABLE_REGENTIME_TIMERNAME] = {
            timeleft = math.min(data.pickable.pause_time or data.pickable.time, maxregentime) / maxregentime,
            paused = data.pickable.paused,
            initial_time = 0,
        }
    end
end

function WorldSettings_Pickable_RegenTime(inst, regentime, enabled)
    local pickable = inst.components.pickable
    local worldsettingstimer = inst.components.worldsettingstimer
    if not worldsettingstimer then
        inst:AddComponent("worldsettingstimer")
        worldsettingstimer = inst.components.worldsettingstimer
    end

    assert(pickable, "WorldSettings_Spawner_SpawnDelay was called without a pickable component")

    pickable.useexternaltimer = true
    pickable.startregentimer = Start_Pickable_RegenTime_Timer
    pickable.stopregentimer = Stop_Pickable_RegenTime_Timer
    pickable.pauseregentimer = Pause_Pickable_RegenTime_Timer
    pickable.resumeregentimer = Resume_Pickable_RegenTime_Timer
    pickable.getregentimertime = Get_Pickable_RegenTime_Timer_Time
    pickable.setregentimertime = Set_Pickable_RegenTime_Timer_Time
    pickable.regentimerexists = Pickable_RegenTime_Timer_Exists

    worldsettingstimer:AddTimer(PICKABLE_REGENTIME_TIMERNAME, regentime, enabled, On_Pickable_RegenTime_TimerFinished)
end

----------------------------------------------------------------------
----------------------------PICKABLE----------------------------------
----------------------------------------------------------------------