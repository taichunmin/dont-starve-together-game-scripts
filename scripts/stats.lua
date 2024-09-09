-- require "stats_schema"    -- for when we actually organize

STATS_ENABLE = METRICS_ENABLED
-- NOTE: There is also a call to 'anon/start' in dontstarve/main.cpp which has to be un/commented

--- non-user-facing Tracking stats  ---
TrackingEventsStats = {}
TrackingTimingStats = {}
local GameStats = {}
local OnLoadGameInfo = {}

-- GLOBAL FOR C++
function GetClientMetricsData()
    if Profile == nil then
        return nil
    end

    local data = {}
    data.play_instance = Profile:GetPlayInstance()
    data.install_id = Profile:GetInstallID()

    return data
end

local function IncTrackingStat(stat, subtable)

	if not STATS_ENABLE then
		return
	end

    local t = TrackingEventsStats
    if subtable then
        t = TrackingEventsStats[subtable]

        if not t then
            t = {}
            TrackingEventsStats[subtable] = t
        end
    end

    t[stat] = 1 + (t[stat] or 0)
end

local function SetTimingStat(subtable, stat, value)

	if not STATS_ENABLE then
		return
	end

    local t = TrackingTimingStats
    if subtable then
        t = TrackingTimingStats[subtable]

        if not t then
            t = {}
            TrackingTimingStats[subtable] = t
        end
    end

    t[stat] = math.floor(value/1000)
end

local function SendTrackingStats()

	if not STATS_ENABLE then
		return
	end

	if GetTableSize(TrackingEventsStats) then
    	local stats = json.encode({events=TrackingEventsStats, timings=TrackingTimingStats})
    	TheSim:LogBulkMetric(stats)
    end
end

local function PrefabListToMetrics(list)
    local metrics = {}
    for i,item in ipairs(list) do
        if item.prefab then
            if metrics[item.prefab] == nil then
                metrics[item.prefab] = 0
            end
            if item.components.stackable ~= nil then
                metrics[item.prefab] = metrics[item.prefab] + item.components.stackable:StackSize()
            else
                metrics[item.prefab] = metrics[item.prefab] + 1
            end
        end
    end
    -- format for storage
    local metrics_kvp = {}
    for name,count in pairs(metrics) do
        table.insert(metrics_kvp, {prefab=name, count=count})
    end
    return metrics_kvp
end

local function BuildContextTable(player)
    local sendstats = {}

    -- can be called with a player or a userid
    if type(player) == "table" then
        sendstats.user = player.userid
        sendstats.user_age = player.components.age ~= nil and player.components.age:GetAgeInDays() or nil
    else
        sendstats.user = player
    end
    -- GJANS TODO: Send the host wherever we can!
    --if type(host) == "table" then
        --sendstats.host = host.userid
    --else
        --sendstats.host = host
    --end

    local client_metrics = nil
    if sendstats.user ~= nil then
        if sendstats.user == TheNet:GetUserID() then
            client_metrics = GetClientMetricsData()
        elseif TheNet:GetIsServer() then
            client_metrics = TheNet:GetClientMetricsForUser(sendstats.user)
        end
    end

    sendstats.build = APP_VERSION
    if client_metrics ~= nil then
        sendstats.install_id = client_metrics.install_id
        sendstats.session_id = client_metrics.play_instance
    end
    if TheWorld ~= nil then
        sendstats.save_id = TheWorld.meta.session_identifier
        sendstats.master_save_id = TheWorld.net ~= nil and TheWorld.net.components.shardstate ~= nil and TheWorld.net.components.shardstate:GetMasterSessionId() or nil

        if TheWorld.state ~= nil then
            sendstats.world_time = TheWorld.state.cycles + TheWorld.state.time
        end
    end

	--sendstats.special_event = TheNet:GetServerEvent() and TheNet:GetServerGameMode() or nil

    sendstats.user =
        (sendstats.user ~= nil and (sendstats.user.."@chester")) or
        (BRANCH == "dev" and "testing") or
        "unknown"

    return sendstats
end


local function BuildStartupContextTable() -- includes a bit more metadata about the user, should probably only be on startup
    local sendstats = BuildContextTable(TheNet:GetUserID())

    sendstats.platform = PLATFORM
    sendstats.branch = BRANCH

    local modnames = KnownModIndex:GetModNames()
    for i, name in ipairs(modnames) do
        if KnownModIndex:IsModEnabled(name) then
            sendstats.branch = sendstats.branch .. "_modded"
            break
        end
    end

    return sendstats
end

local function ClearProfileStats()
    ProfileStats = {}
end

--[[local function GetProfileStats(wipe)
	if GetTableSize(ProfileStats) == 0 then
		return json.encode( {} )
	end

	wipe = wipe or false
	local jsonstats = ''
	local sendstats = BuildContextTable() -- Ack! This should be passing in a user or something...

	sendstats.stats = ProfileStats
	--print("_________________++++++ Sending Accumulated profile stats...\n")
	--ddump(sendstats)

	jsonstats = json.encode(sendstats)

	if wipe then
		ClearProfileStats()
    end
    return jsonstats
end]]


local function RecordSessionStartStats()
	if not STATS_ENABLE then
		return
	end

	-- TODO: This should actually just write the specific start stats, and it will eventually
	-- be rolled into the "quit" stats and sent off all at once.
	local sendstats = BuildStartupContextTable()
    sendstats.event = "sessionstart"
	sendstats.Session = {
		Loads = {
			Mods = {
				mod = false,
				list = {},

			},
		}
	}

	for i,name in ipairs(ModManager:GetEnabledModNames()) do
		sendstats.Session.Loads.Mods.mod = true
		table.insert(sendstats.Session.Loads.Mods.list, name)
	end


	--print("_________________++++++ Sending sessions start stats...\n")
	--dumptable(sendstats)
	local jsonstats = json.encode_compliant( sendstats )
	TheSim:SendProfileStats( jsonstats )
end

local function RecordeSessionStopStats()
end

local function RecordGameStartStats()
	if not STATS_ENABLE then
		return
	end

	-- TODO: This should actually just write the specific start stats, and it will eventually
	-- be rolled into the "quit" stats and sent off all at once.
	local sendstats = BuildStartupContextTable()
    sendstats.event = "startup.gamestart"
    sendstats.startup = {}

	if PLATFORM == "WIN32_RAIL" then
		sendstats.appdataWritable = TheSim:IsAppDataWritable()
		sendstats.documentsWritable = TheSim:IsDocumentsWritable()
	end

	--print("_________________++++++ Sending game start stats...\n")
	--dumptable(sendstats)
	local jsonstats = json.encode_compliant( sendstats )
	TheSim:SendProfileStats( jsonstats, "is_only_local_users_data" )
end

--[[local function SendAccumulatedProfileStats()
	if not STATS_ENABLE then
		return
	end

	--local sendstats = GetProfileStats(true)
    --sendstats.event = "accumulatedprofile"
	-- TODO:STATS TheSim:SendProfileStats(sendstats)
end]]


local function GetTestGroup()
	local id = TheSim:GetSteamIDNumber()

	local groupid = id%2 -- group 0 must always be default, because GetSteamIDNumber returns 0 for non-steam users
	return groupid
end


local function OnLaunchComplete()
	if STATS_ENABLE then
		local sendstats = BuildStartupContextTable()
        sendstats.event = "startup.launchcomplete"
		sendstats.ownsds = TheSim:GetUserHasLicenseForApp(DONT_STARVE_APPID)
		sendstats.ownsrog = TheSim:GetUserHasLicenseForApp(REIGN_OF_GIANTS_APPID)
		sendstats.betabranch = TheSim:GetSteamBetaBranchName()
		local jsonstats = json.encode_compliant( sendstats )
	   	TheSim:SendProfileStats( jsonstats )
	end
end

local statsEventListener
local sessionStatsSent = false

local function SuccesfulConnect(account_event, success, event_code, custom_message )
	if event_code == 3 and success == true or
           event_code == 6 and success == true and
           not sessionStatsSent then
                sessionStatsSent = true
		OnLaunchComplete()
	end
end

local function InitStats()
	statsEventListener = CreateEntity("StatsEventListener")
	statsEventListener.OnAccountEvent = SuccesfulConnect
	RegisterOnAccountEventListener(statsEventListener)
end

local function PushMetricsEvent(event_id, player, values, is_only_local_users_data)

    local sendstats = BuildContextTable(player)
    sendstats.event = event_id

    if values then
        for k,v in pairs(values) do
            sendstats[k] = v
        end
    end

    --print("PUSH METRICS EVENT")
    --dumptable(sendstats)
    --print("^^^^^^^^^^^^^^^^^^")
    local jsonstats = json.encode_compliant(sendstats)
    TheSim:SendProfileStats(jsonstats, is_only_local_users_data)
end

------------------------------------------------------------------------------------------------
-- GLOBAL functions
------------------------------------------------------------------------------------------------

--- GAME Stats and details to be sent to server on game complete ---
ProfileStats = {}
MainMenuStats = {}


-- value is optional, 1 if nil
function ProfileStatsAdd(item, value)
    --print ("ProfileStatsAdd", item)
    if value == nil then
        value = 1
    end

    if ProfileStats[item] then
    	ProfileStats[item] = ProfileStats[item] + value
    else
    	ProfileStats[item] = value
    end
end

function ProfileStatsAddItemChunk(item, chunk)
    if ProfileStats[item] == nil then
    	ProfileStats[item] = {}
    end

    if ProfileStats[item][chunk] then
    	ProfileStats[item][chunk] =ProfileStats[item][chunk] +1
    else
    	ProfileStats[item][chunk] = 1
    end
end

function ProfileStatsSet(item, value)
	ProfileStats[item] = value
end

function ProfileStatsGet(item)
	return ProfileStats[item]
end

-- The following takes advantage of table.setfield (util.lua) which
-- takes a string representation of a table field (e.g. "foo.bar.bleah.eeek")
-- and creates all the intermediary tables if they do not exist

function ProfileStatsAddToField(field, value)
    --print ("ProfileStatsAdd", item)
    if value == nil then
        value = 1
    end

    local oldvalue = table.getfield(ProfileStats,field)
    if oldvalue then
    	table.setfield(ProfileStats,field, oldvalue + value)
    else
    	table.setfield(ProfileStats,field, value)
    end
end

function ProfileStatsSetField(field, value)
    if type(field) ~= "string" then
        return nil
    end
    table.setfield(ProfileStats, field, value)
    return value
end

function ProfileStatsAppendToField(field, value)
    if type(field) ~= "string" then
        return nil
    end
    -- If the field name ends with ".", setfield adds the value to the end of the array
    table.setfield(ProfileStats, field .. ".", value)
end

function SuUsed(item,value)
    GameStats.super = true
    ProfileStatsSet(item, value)
end

function SetSuper(value)
    --print("Setting SUPER",value)
    OnLoadGameInfo.super = value
end

function SuUsedAdd(item,value)
    GameStats.super = true
    ProfileStatsAdd(item, value)
end

function WasSuUsed()
    return GameStats.super
end


------------------------------------------------------------------------------------------------
-- Export public methods
------------------------------------------------------------------------------------------------

return {
    BuildContextTable = BuildContextTable,
    InitStats = InitStats,
    GetTestGroup = GetTestGroup,
    PushMetricsEvent = PushMetricsEvent,
    ClearProfileStats = ClearProfileStats,
    RecordSessionStartStats = RecordSessionStartStats,
    RecordGameStartStats = RecordGameStartStats,
    PrefabListToMetrics = PrefabListToMetrics,
}
