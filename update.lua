--[[
local function DoSpawnMeteor(target, n)
    local pt = target:GetPosition()
    local theta = math.random() * 2 * PI
    --spread the meteors more once the player is a ghost
    local radius = target:HasTag("playerghost") and math.random(n + 1, 10 + n * 2) or math.random(n - 1, 5 + n * 2)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    if offset ~= nil then
        pt.x = pt.x + offset.x
        pt.z = pt.z + offset.z
    end
    SpawnPrefab("shadowmeteor").Transform:SetPosition(pt.x, 0, pt.z)
end

local function SpawnEndMeteors(maxmeteors)
    for n = 1, math.random(maxmeteors or 7) do
        for i, v in ipairs(AllPlayers) do
            v:DoTaskInTime((math.random() + .33) * n * .5, DoSpawnMeteor, n)
        end
    end
end

local function SpawnEndHounds()
    for n = 1, math.random(3) do
        for i, v in ipairs(AllPlayers) do
            TheWorld.components.hounded:ForceReleaseSpawn(v)
        end
    end
end
]]

--this is an update that always runs on wall time (not sim time)
function WallUpdate(dt)
    if AUTOSPAWN_MASTER_SLAVE then 
        SpawnSecondInstance()
    end

    --TheSim:ProfilerPush("LuaWallUpdate")

    TheSim:ProfilerPush("RPC queue")
    HandleRPCQueue()
    TheSim:ProfilerPop()

    HandleUserCmdQueue()

    if TheFocalPoint ~= nil then
        TheSim:SetActiveAreaCenterpoint(TheFocalPoint.Transform:GetWorldPosition())
    else
        TheSim:SetActiveAreaCenterpoint(0, 0, 0)
    end

    TheSim:ProfilerPush("updating wall components")
    for k, v in pairs(WallUpdatingEnts) do
        if v.wallupdatecomponents then
            for cmp in pairs(v.wallupdatecomponents) do
                if cmp.OnWallUpdate then
                    cmp:OnWallUpdate(dt)
                end
            end
        end
    end
    if next(NewWallUpdatingEnts) ~= nil then
        for k, v in pairs(NewWallUpdatingEnts) do
            WallUpdatingEnts[k] = v
        end
        NewWallUpdatingEnts = {}
    end
    TheSim:ProfilerPop()

    TheSim:ProfilerPush("mixer")
    TheMixer:Update(dt)
    TheSim:ProfilerPop()

    if not IsSimPaused() then
        TheSim:ProfilerPush("camera")
        TheCamera:Update(dt)
        TheSim:ProfilerPop()
    end

    CheckForUpsellTimeout(dt)

    TheSim:ProfilerPush("input")
    if not SimTearingDown then
        TheInput:OnUpdate()
    end
    TheSim:ProfilerPop()

    TheSim:ProfilerPush("fe")
    if global_error_widget then
        global_error_widget:OnUpdate(dt)
    else
        TheFrontEnd:Update(dt)
    end
    TheSim:ProfilerPop()

    --TheSim:ProfilerPop()

    -- Server termination script
    -- Only runs if the SERVER_TERMINATION_TIMER constant has been overriden (which we do with the pax demo)
    --[[
    if SERVER_TERMINATION_TIMER > 0 and TheNet:GetIsServer() then
        if SERVER_TERMINATION_TIMER <= dt then
            SERVER_TERMINATION_TIMER = 0
            TheSim:Quit()
            return
        end

        local original_time = SERVER_TERMINATION_TIMER
        SERVER_TERMINATION_TIMER = SERVER_TERMINATION_TIMER - dt

        if SERVER_TERMINATION_TIMER <= 60 and original_time % 5 <= .02 then
            SpawnEndHounds()
        end
        if SERVER_TERMINATION_TIMER <= 30 and original_time % 2 <= .02 then
            SpawnEndMeteors()
        end

        if SERVER_TERMINATION_TIMER <= 30 and original_time > 30 then
            TheNet:Announce("The sky is falling!")
        elseif SERVER_TERMINATION_TIMER <= 60 and original_time > 60 then
            TheNet:Announce("Let slip the dogs of war!")
        elseif SERVER_TERMINATION_TIMER <= 120 and original_time > 120 then
            TheNet:Announce("End times are almost here.")
        elseif SERVER_TERMINATION_TIMER <= 180 and original_time > 180 then
            TheNet:Announce("End times are coming.")
        end
    end
    ]]
end

function PostUpdate(dt)
    --TheSim:ProfilerPush("LuaPostUpdate")
    EmitterManager:PostUpdate()

    --TheSim:ProfilerPop()
end

function PostPhysicsWallUpdate(dt)
    if TheWorld ~= nil then
        local walkable_platform_manager = TheWorld.components.walkableplatformmanager
        if walkable_platform_manager ~= nil then
            walkable_platform_manager:PostUpdate(dt)
        end
    end    
end

local StaticComponentLongUpdates = {}
function RegisterStaticComponentLongUpdate(classname, fn)
    StaticComponentLongUpdates[classname] = fn
end

local StaticComponentUpdates = {}
function RegisterStaticComponentUpdate(classname, fn)
    StaticComponentUpdates[classname] = fn
end

local last_tick_seen = -1
--This is where the magic happens
function Update(dt)
    HandleClassInstanceTracking()
    --TheSim:ProfilerPush("LuaUpdate")
    CheckDemoTimeout()

    if IsSimPaused() then
        --TheSim:ProfilerPop()
        return
    end

    local tick = TheSim:GetTick()
    if tick <= last_tick_seen then
        print("Saw this before")
        --TheSim:ProfilerPop()
        return
    end

    TickRPCQueue()

    TheSim:ProfilerPush("scheduler")
    for i = last_tick_seen + 1, tick do
        RunScheduler(i)
    end
    TheSim:ProfilerPop()

    if SimShuttingDown then
        --TheSim:ProfilerPop()
        return
    end

    TheSim:ProfilerPush("static components")
    for k, v in pairs(StaticComponentUpdates) do
        v(dt)
    end
    TheSim:ProfilerPop()

    TheSim:ProfilerPush("updating components")
    for k, v in pairs(UpdatingEnts) do
        if v.updatecomponents then
            --TheSim:ProfilerPush(v.prefab or "unknown")
            for cmp in pairs(v.updatecomponents) do
                --TheSim:ProfilerPush(v:GetComponentName(cmp))
                if cmp.OnUpdate and not StopUpdatingComponents[cmp] then
                    cmp:OnUpdate(dt)
                end
                --TheSim:ProfilerPop()
            end
            --TheSim:ProfilerPop()
        end
    end

    if next(NewUpdatingEnts) ~= nil then
        for k, v in pairs(NewUpdatingEnts) do
            UpdatingEnts[k] = v
        end
        NewUpdatingEnts = {}
    end

    if next(StopUpdatingComponents) ~= nil then
        for k, v in pairs(StopUpdatingComponents) do
            v:StopUpdatingComponent_Deferred(k)
        end
        StopUpdatingComponents = {}
    end

    TheSim:ProfilerPop()

    for i = last_tick_seen + 1, tick do
        TheSim:ProfilerPush("LuaSG")
        SGManager:Update(i)
        TheSim:ProfilerPop()

        TheSim:ProfilerPush("LuaBrain")
        BrainManager:Update(i)
        TheSim:ProfilerPop()
    end

    last_tick_seen = tick
    --TheSim:ProfilerPop()
end

--this is for advancing the sim long periods of time (to skip nights, come back from caves, etc)
function LongUpdate(dt, ignore_player)
    --print("LONG UPDATE", dt, ignore_player)

    for k, v in pairs(StaticComponentLongUpdates) do
        v(dt)
    end

    if ignore_player then
        for i, v in ipairs(AllPlayers) do
            if v.components.beard then
                v.components.beard.pause = true
            end
        end

        for k, v in pairs(Ents) do
            local should_ignore = false

            if v.components.inventoryitem ~= nil then
                local grand_owner = v.components.inventoryitem:GetGrandOwner()
                if grand_owner ~= nil and
                    (   grand_owner:HasTag("player") or
                        (   grand_owner.components.container and
                            grand_owner.components.follower and
                            grand_owner.components.follower:GetLeader() and
                            grand_owner.components.follower:GetLeader():HasTag("player")
                        )
                    ) then
                    should_ignore = true
                end
            end

            if not (    should_ignore or
                        v:HasTag("player") or
                        (   v.components.follower and
                            v.components.follower:GetLeader() and
                            v.components.follower:GetLeader():HasTag("player")
                        )
                    ) then
                v:LongUpdate(dt)
            end
        end

        for i, v in ipairs(AllPlayers) do
            if v.components.beard then
                v.components.beard.pause = nil
            end
        end
    else
        for k, v in pairs(Ents) do
            v:LongUpdate(dt)
        end
    end
end
