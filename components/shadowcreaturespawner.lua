--------------------------------------------------------------------------
--[[ ShadowCreatureSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shadow creature spawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local POP_CHANGE_INTERVAL = 10
local POP_CHANGE_VARIANCE = 10
local SPAWN_INTERVAL = 5
local SPAWN_VARIANCE = 10
local NON_INSANITY_MODE_DESPAWN_INTERVAL = 0.1
local NON_INSANITY_MODE_DESPAWN_VARIANCE = 0.1

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _map = TheWorld.Map
local _players = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local UpdateSpawn

local function StopTracking(player, params, ent)
    table.removearrayvalue(params.ents, ent)

    if params.targetpop ~= #params.ents then
        if params.spawntask == nil then
            params.spawntask = player:DoTaskInTime(SPAWN_INTERVAL + SPAWN_VARIANCE * math.random(), UpdateSpawn, params)
        end
    elseif params.spawntask ~= nil then
        params.spawntask:Cancel()
        params.spawntask = nil
    end
end

local function StartTracking(player, params, ent)
    table.insert(params.ents, ent)
    ent.spawnedforplayer = player

    inst:ListenForEvent("onremove", function()
        if _players[player] == params then
            StopTracking(player, params, ent)
        end
    end, ent)

    ent:ListenForEvent("onremove", function()
        ent.spawnedforplayer = nil
        ent.persists = false
        ent.wantstodespawn = true
    end, player)
end

UpdateSpawn = function(player, params)
    if params.targetpop > #params.ents then
        local angle = math.random() * 2 * PI
        local x, y, z = player.Transform:GetWorldPosition()
        x = x + 15 * math.cos(angle)
        z = z - 15 * math.sin(angle)
        if _map:IsPassableAtPoint(x, 0, z) then
            local ent = SpawnPrefab(
                player.components.sanity:GetPercent() < .1 and
                math.random() < .5 and
                "terrorbeak" or
                "crawlinghorror"
            )
            ent.Transform:SetPosition(x, 0, z)
            StartTracking(player, params, ent)
        end

        --Reschedule spawning if we haven't reached our target population
        params.spawntask =
            params.targetpop ~= #params.ents
            and player:DoTaskInTime(SPAWN_INTERVAL + SPAWN_VARIANCE * math.random(), UpdateSpawn, params)
            or nil
    elseif params.targetpop < #params.ents then
        --Remove random monsters until we reach our target population
        local toremove = {}
        for i, v in ipairs(params.ents) do
            if not v.wantstodespawn then
                table.insert(toremove, v)
            end
        end
        for i = #toremove, params.targetpop + 1, -1 do
            local ent = table.remove(toremove, math.random(i))
            ent.persists = false
            ent.wantstodespawn = true
        end

        --Don't reschedule spawning
        params.spawntask = nil
    else
        --Don't reschedule spawning
        params.spawntask = nil
    end
end

local function StartSpawn(player, params)
    if params.spawntask == nil then
        params.spawntask = player:DoTaskInTime(0, UpdateSpawn, params)
    end
end

local function StopSpawn(player, params)
    if params.spawntask ~= nil then
        params.spawntask:Cancel()
        params.spawntask = nil
    end
end

local function UpdatePopulation(player, params)
	local is_inasnity_mode = player.components.sanity:IsInsanityMode()

    if is_inasnity_mode and player.components.sanity.inducedinsanity then
        local maxpop = 5
        local inc_chance = .7
        local dec_chance = .4
        local targetpop = params.targetpop

        --Figure out our new target
        if targetpop > maxpop then
            targetpop = targetpop - 1
        elseif math.random() < inc_chance then
            if targetpop < maxpop then
                targetpop = targetpop + 1
            end
        elseif targetpop > 0 and math.random() < dec_chance then
            targetpop = targetpop - 1
        end

        --Start spawner if target population has changed
        if params.targetpop ~= targetpop then
            params.targetpop = targetpop
            StartSpawn(player, params)
        end

        --Shorter reschedule for population update due to induced insanity
        params.poptask = player:DoTaskInTime(5 + math.random(), UpdatePopulation, params)
    else
        local maxpop = 0
        local inc_chance = 0
        local dec_chance = 0
        local targetpop = params.targetpop
        local sanity = is_inasnity_mode and player.components.sanity:GetPercent() or 1

        if sanity > .5 then
            --We're pretty sane. Clean up the monsters
            maxpop = 0
        elseif sanity > .1 then
            --Have at most one monster, sometimes
            maxpop = 1
            if targetpop >= maxpop then
                dec_chance = .1
            else
                inc_chance = .3
            end
        else
            --Have at most one or two monsters, usually 1
            maxpop = 2
            if targetpop >= maxpop then
                dec_chance = .2
            elseif targetpop <= 0 then
                inc_chance = .3
            else
                inc_chance = .2
                dec_chance = .2
            end
        end

        --Figure out our new target
        if targetpop > maxpop then
            targetpop = targetpop - 1
        elseif inc_chance > 0 and math.random() < inc_chance then
            if targetpop < maxpop then
                targetpop = targetpop + 1
            end
        elseif dec_chance > 0 and math.random() < dec_chance then
            targetpop = targetpop - 1
        end

        --Start spawner if target population has changed
        if params.targetpop ~= targetpop then
            params.targetpop = targetpop
            StartSpawn(player, params)
        end

        --Reschedule population update
        params.poptask = player:DoTaskInTime(is_inasnity_mode and (POP_CHANGE_INTERVAL + POP_CHANGE_VARIANCE * math.random()) 
												or (NON_INSANITY_MODE_DESPAWN_INTERVAL + NON_INSANITY_MODE_DESPAWN_VARIANCE * math.random())
											, UpdatePopulation, params)
    end
end

local function Start(player, params)
    if params.poptask == nil then
        params.poptask = player:DoTaskInTime(0, UpdatePopulation, params)
    end
end

local function Stop(player, params)
    StopSpawn(player, params)
    if params.poptask ~= nil then
        params.poptask:Cancel()
        params.poptask = nil
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnInducedInsanity(player)
    local params = _players[player]
    if params ~= nil then
        --Reset the update timers to 0 for this player
        Stop(player, params)
        Start(player, params)
    end
end

local function OnPlayerJoined(inst, player)
    if _players[player] ~= nil then
        return
    end
    _players[player] = { ents = {}, targetpop = 0 }
    Start(player, _players[player])
    inst:ListenForEvent("inducedinsanity", OnInducedInsanity, player)
    inst:ListenForEvent("sanitymodechanged", OnInducedInsanity, player)
end

local function OnPlayerLeft(inst, player)
    if _players[player] == nil then
        return
    end
    inst:RemoveEventCallback("inducedinsanity", OnInducedInsanity, player)
    inst:RemoveEventCallback("sanitymodechanged", OnInducedInsanity, player)
    Stop(player, _players[player])
    _players[player] = nil
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(inst, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local count = 0
    for k, v in pairs(_players) do
        count = count + #v.ents
    end
    if count > 0 then
        return count == 1 and "1 shadowcreature" or (tostring(count).." shadowcreatures")
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)