local Customize = require("map/customize")

--------------------------------------------------------------------------
--[[ Shard Networking ]]
--------------------------------------------------------------------------

ShardPortals = {}

ShardList = {}
local ShardConnected = {}

function Shard_IsMaster()
    return TheShard:IsMaster() or TheNet:GetIsMasterSimulation() and not TheShard:IsSecondary()
end

function Shard_IsWorldAvailable(world_id)
    return world_id ~= nil and (ShardConnected[world_id or SHARDID.MASTER] ~= nil or world_id == TheShard:GetShardId())
end

function Shard_IsWorldFull(world_id)
    -- TODO
end

function Shard_SyncWorldSettings(world_id, is_resync)
    local sync_options = Customize.GetSyncOptions()
    local worldoptions = ShardGameIndex:GetGenOptions()

    local sync_settings = {}
    if worldoptions.overrides then
        for option, value in pairs(worldoptions.overrides) do
            if sync_options[option] then
                sync_settings[option] = value
                print("[SyncWorldSettings] " .. (is_resync and "Resyncing" or "Sending") .. " master world option " .. option .. " = " .. value .. " to secondary shards.")
            end
        end
    end

    if not IsTableEmpty(sync_settings) then
        SendRPCToShard(SHARD_RPC.SyncWorldSettings, world_id, DataDumper(sync_settings, nil, true))
    end
end

function Shard_OnShardConnected(world_id, tags, world_data)
    -- NOTES(JBK): Only should be called when the shard state is REMOTESHARDSTATE.READY.
    if Shard_IsMaster() then
        Shard_SyncWorldSettings(world_id)
    else
        SendRPCToShard(SHARD_RPC.ResyncWorldSettings, SHARDID.MASTER)
    end
    if Shard_IsMaster() then
        if TheWorld then
            local shard_mermkingwatcher = TheWorld.shard.components.shard_mermkingwatcher
            if shard_mermkingwatcher then
                shard_mermkingwatcher:ResyncNetVars()
            end
        end
    end
end
--Called from ShardManager whenever a shard is connected or
--disconnected, to automatically update known portal states
--On master server, secondary tags and worldgen options are also passed through here
--NOTE: should never be called with for our own world_id
function Shard_UpdateWorldState(world_id, state, tags, world_data)
    local ready = state == REMOTESHARDSTATE.READY
    print("World "..world_id.." is now "..(ready and 'connected' or 'disconnected'))

    if ready then
        if world_data ~= nil and #world_data > 0 then
            local success, data = RunInSandboxSafe(world_data)

            if success and type(data) == "table" and type(data.str) == "string" then
                local count = 0
                for _ in pairs(data) do
                    count = count + 1
                    if count > 1 then break end
                end
                --make sure data.str is the only entry in the table
                if count == 1 then
                    success, data = RunInSandboxSafe(TheSim:DecodeAndUnzipString(data.str))
                end
            end

            world_data = success and data or {}
        else
            world_data = {}
        end
        ShardConnected[world_id] = { ready = true, tags = tags, world = world_data }
        ShardList[world_id] = true

        Shard_OnShardConnected(world_id, tags, world_data)
    else
        ShardConnected[world_id] = nil
        ShardList[world_id] = nil
    end

    for k, v in pairs(ShardPortals) do
        if ready and (v.components.worldmigrator.linkedWorld == nil
                    or v.components.worldmigrator.auto == true) then
            -- Bind unused portals to this new server, mm-mm!
            v.components.worldmigrator:SetDestinationWorld(world_id)
        elseif v.components.worldmigrator.linkedWorld == world_id then
            v.components.worldmigrator:ValidateAndPushEvents()
        else
            print(string.format("Skipping portal[%d] (different permanent world)", v.components.worldmigrator.id))
        end
    end

    UpdateServerTagsString()
    UpdateServerWorldGenDataString()
end

--Called from worldmigrator whenever a new portal is
--spawned to automatically link it with known shards
function Shard_UpdatePortalState(inst)
    if inst.components.worldmigrator.linkedWorld == nil then
        for k, v in pairs(ShardConnected) do
            -- Bind to first available shard
            inst.components.worldmigrator:SetDestinationWorld(k)
            return
        end
    end
    inst.components.worldmigrator:ValidateAndPushEvents()
end

function Shard_GetConnectedShards() -- useful for debugging
    return deepcopy(ShardConnected)
end

--------------------------------------------------------------------------

function Shard_UpdateMasterSessionId(session_id)
    if TheWorld ~= nil then -- this will be nil if the connection happens during worldgen; it will be resent on game start
        TheWorld:PushEvent("ms_newmastersessionid", session_id)
    end
end

function Shard_WorldSave()
    if TheWorld ~= nil and TheWorld.ismastershard then
        TheWorld:PushEvent("ms_save")
    end
end

--------------------------------------------------------------------------

function Shard_StartVote(command_id, starter_id, target_id)
    if TheWorld ~= nil and TheWorld.ismastershard then
        TheWorld:PushEvent("ms_startvote", {
            commandhash = command_id,
            starteruserid = starter_id,
            targetuserid = target_id,
        })
    end
end

function Shard_StopVote()
    if TheWorld ~= nil and TheWorld.ismastershard then
        TheWorld:PushEvent("ms_stopvote")
    end
end

function Shard_ReceiveVote(selection, user_id)
    if TheWorld ~= nil and TheWorld.ismastershard then
        TheWorld:PushEvent("ms_receivevote", {
            selection = selection,
            userid = user_id,
        })
    end
end

--------------------------------------------------------------------------

local RecentDiceRolls = {}

function Shard_OnDiceRollRequest(user_id)
    if TheWorld == nil or not TheWorld.ismastershard then
        return false
    end

    --Clear out old rolls
    local curt = GetTime()
    local toremove = {}
    for id, endt in pairs(RecentDiceRolls) do
        if curt > endt then
            table.insert(toremove, id)
        end
    end
    for _, id in ipairs(toremove) do
        RecentDiceRolls[id] = nil
    end

    --Check that user is not still on cooldown
    if RecentDiceRolls[user_id] ~= nil then
        return false
    end

    RecentDiceRolls[user_id] = curt + TUNING.DICE_ROLL_COOLDOWN
    return true
end

---------------------------------------------

function Shard_SyncBossDefeated(bossprefab, shardid) -- NOTES(JBK): Flipped shardid argument order to make calling this easier elsewhere.
    if Shard_IsMaster() then
        if TheWorld then
            TheWorld:PushEvent("master_shardbossdefeated", {bossprefab = bossprefab, shardid = shardid or TheShard:GetShardId(),})
        end
    else
        SendRPCToShard(SHARD_RPC.SyncBossDefeated, SHARDID.MASTER, bossprefab)
    end
end

---------------------------------------------

function Shard_SyncMermKingExists(exists, shardid) -- NOTES(JBK): Flipped shardid argument order to make calling this easier elsewhere.
    if Shard_IsMaster() then
        if TheWorld then
            TheWorld:PushEvent("master_shardmermkingexists", {exists = exists, shardid = shardid or TheShard:GetShardId(),})
        end
    else
        TheWorld:DoTaskInTime(0, function() -- NOTES(JBK): This should be delayed a frame to let loading correctly handle the RPC message.
            SendRPCToShard(SHARD_RPC.SyncMermKingExists, SHARDID.MASTER, exists)
        end)
    end
end

-- Merm King buffs --------------------------

function Shard_SyncMermKingTrident(exists, shardid) -- Flipped shardid argument order to make calling this easier elsewhere.
    if Shard_IsMaster() then
        if TheWorld then
            TheWorld:PushEvent("master_shardmermkingtrident", {
                pickedup = exists,
                shardid = shardid or TheShard:GetShardId(),
            })
        end
    else
        TheWorld:DoTaskInTime(0, function() -- This should be delayed a frame to let loading correctly handle the RPC message.
            SendRPCToShard(SHARD_RPC.SyncMermKingTrident, SHARDID.MASTER, exists)
        end)
    end
end

function Shard_SyncMermKingCrown(exists, shardid)
    if Shard_IsMaster() then
        if TheWorld then
            TheWorld:PushEvent("master_shardmermkingcrown", {
                pickedup = exists,
                shardid = shardid or TheShard:GetShardId(),
            })
        end
    else
        TheWorld:DoTaskInTime(0, function() -- This should be delayed a frame to let loading correctly handle the RPC message.
            SendRPCToShard(SHARD_RPC.SyncMermKingCrown, SHARDID.MASTER, exists)
        end)
    end
end

function Shard_SyncMermKingPauldron(exists, shardid)
    if Shard_IsMaster() then
        if TheWorld then
            TheWorld:PushEvent("master_shardmermkingpauldron", {
                pickedup = exists,
                shardid = shardid or TheShard:GetShardId(),
            })
        end
    else
        TheWorld:DoTaskInTime(0, function() -- This should be delayed a frame to let loading correctly handle the RPC message.
            SendRPCToShard(SHARD_RPC.SyncMermKingPauldron, SHARDID.MASTER, exists)
        end)
    end
end
