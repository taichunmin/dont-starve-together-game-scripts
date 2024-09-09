local WORLDOVERSEER_HEARTBEAT = 5 * 60
local WORLDOVERSEER_HEARTBEAT_POLL = 5

local Stats = require("stats")

local function GetOverseerTime()
    if IsConsole() then
        return GetTime() -- Don't use real time as PS4 can't FF time but can be suspended
    else
        return GetTimeReal() / 1000
    end
end

local WorldOverseer = Class(function(self, inst)
	self.inst = inst
    self.data = {}
	self._seenplayers = {}
	self._cycles = nil
    self._daytime = nil

	self.inst:DoPeriodicTask(WORLDOVERSEER_HEARTBEAT, function() self:Heartbeat() end )
	self.inst:DoPeriodicTask(WORLDOVERSEER_HEARTBEAT_POLL, function() self:HeartbeatPoll() end )
	self.inst:ListenForEvent("ms_playerjoined", function(src, player) self:OnPlayerJoined(src, player) end , TheWorld)
	self.inst:ListenForEvent("ms_playerleft", function(src, player) self:OnPlayerLeft(src, player) end, TheWorld)
    self.inst:ListenForEvent("cycleschanged", function(inst, data) self:OnCyclesChanged(data) end, TheWorld)
    self.inst:ListenForEvent("clocktick", function(inst, data) self:OnClockTick(data) end, TheWorld)

	for i, v in ipairs(AllPlayers) do
		self:OnPlayerJoined(self.inst, v)
    end

    self._v2_seenplayers = {}
    self.last_heartbeat_poll_time = os.time()
    self.heartbeat_poll_counter = 0
end)

function WorldOverseer:OnCyclesChanged(cycles)
    self._cycles = cycles
end

function WorldOverseer:OnClockTick(data)
    self._daytime = data.time
end

function WorldOverseer:RecordPlayerJoined(player)
	local playerstats = self._seenplayers[player]
	local time = GetOverseerTime()

	local current_skins = player.components.skinner:GetClothing()
	local items = {}
	for k,v in pairs(current_skins) do
		local item = {}
		item.item_name = v
		item.starttime = time
		item.endtime = nil
		table.insert(items, item)
	end

	if not playerstats then
		self._seenplayers[player] = {
									starttime = time,
									secondsplayed = 0,
									endtime = nil,
									worn_items = items,
									crafted_items = {},
								}
	else
        -- player was here before this timeframe
		playerstats.secondsplayed = playerstats.endtime - playerstats.starttime
		playerstats.starttime = time
		playerstats.endtime = nil
		playerstats.worn_items = items
	end
end

function WorldOverseer:RecordPlayerLeft(player)
	local playerstats = self._seenplayers[player]
	local time = GetOverseerTime()
	if playerstats then
		playerstats.endtime = time

		for k,v in pairs(playerstats.worn_items) do
			if v.endtime == nil then
				v.endtime = time
			end
		end

	end

    -- GJANS TODO: Enable the join_world and leave_world metrics
    --local stat = self:CalcIndividualPlayerStats(player)
    ----print("PLAYER LEFT")
    ----dumptable(stat)
    --self:DumpIndividualPlayerStats(stat, "player.leave_world")
    --self._seenplayers[player] = nil
end

function WorldOverseer:CalcIndividualPlayerStats(player)
    local playerstats = self._seenplayers[player]

    local toremove = false

    local time = GetOverseerTime()
    local secondsplayed = 0
    if playerstats.endtime then
        -- player left
        secondsplayed = playerstats.endtime - playerstats.starttime + playerstats.secondsplayed
        toremove = true
    else
        -- still there
        secondsplayed = time - playerstats.starttime + playerstats.secondsplayed
        playerstats.starttime = time
        playerstats.secondsplayed = 0
    end

    -- Calculates the time for each individual skin, check if it's already contained on the list
    -- if not, insert it, if so, append the time
    local total_worn_items = {}
    local totaltime = 0
    for index, worn_item in pairs(playerstats.worn_items) do
        if worn_item.endtime then
            totaltime = worn_item.endtime - worn_item.starttime
        else
            totaltime = time - worn_item.starttime
        end

        if not table.containskey(total_worn_items, worn_item.item_name) then
            total_worn_items[worn_item.item_name] = totaltime
        else
            total_worn_items[worn_item.item_name] = total_worn_items[worn_item.item_name] + totaltime
        end
    end

    local total_crafted_items = {}
    for index,crafted_item in pairs(playerstats.crafted_items) do
        if not table.containskey(total_crafted_items, crafted_item) then
            total_crafted_items[crafted_item] = 1
        else
            total_crafted_items[crafted_item] = total_crafted_items[crafted_item] + 1
        end
        playerstats.crafted_items[index] = nil
    end

    return {
        player = player,
        secondsplayed = secondsplayed,
        worn_items = total_worn_items,
        crafted_items = total_crafted_items
    }, toremove
end

function WorldOverseer:CalcPlayerStats()
    -- Gather player playtimes for this segment
    local results = {}
    local toRemove = {}
    for player, playerstats in pairs(self._seenplayers) do
        local result, shouldremove = self:CalcIndividualPlayerStats(player)
        results[#results+1] = result
        if shouldremove then
            table.insert(toRemove, player)
        end
    end
    -- cleanup
    for i,v in ipairs(toRemove) do
        self._seenplayers[v] = nil
    end
    return results
end

function WorldOverseer:DumpIndividualPlayerStats(stat, event)
    local sendstats = Stats.BuildContextTable(stat.player)
    sendstats.event = event
    sendstats.play_t = RoundBiasedUp(stat.secondsplayed,2)
    sendstats.character = stat.player and stat.player.prefab or nil
    sendstats.save_id = self.inst.meta.session_identifier
    sendstats.worn_items = stat.worn_items
    sendstats.crafted_items = stat.crafted_items
    if stat.player ~= nil and stat.player.components.inventory ~= nil then
        sendstats.current_inventory = Stats.PrefabListToMetrics(stat.player.components.inventory:ReferenceAllItems())
    end

    --print("DUMP PLAYER STATS")
    --dumptable(sendstats)
    local jsonstats = json.encode_compliant(sendstats)
    TheSim:SendProfileStats(jsonstats)
end

function WorldOverseer:DumpPlayerStats()
    local playerstats = self:CalcPlayerStats()
    for i,stat in ipairs(playerstats) do
        self:DumpIndividualPlayerStats(stat, "heartbeat.player")
    end
end

function WorldOverseer:OnPlayerDeath(player, data)
	local age = player.components.age:GetAgeInDays()
	local worldAge = self._cycles
	local sendstats = Stats.BuildContextTable(player)
    sendstats.event = "player.death"
	sendstats.playerdeath = {
                                save_id = self.inst.meta.session_identifier,
								playerage = RoundBiasedUp(age,2),
								worldage = worldAge,
								cause = data and data.cause or ""
                                -- note: 'cause' is the character prefab for player kills. probably need another field which is the player ID.
							}
    -- ~gjans: Trying to catch a metrics bug, added 2016-08-29
    if BRANCH == "dev" and sendstats.playerdeath.cause == 0 then
        assert(false, "Ack! We got killed by '0', please let Graham know what killed you!")
    end
	local jsonstats = json.encode_compliant(sendstats)
	TheSim:SendProfileStats(jsonstats)
end

function WorldOverseer:OnPlayerChangedSkin(player, data)
	if not data then return end
	if not data.new_skin then return end
	if data.new_skin == data.old_skin then return end

	local playerstats = self._seenplayers[player]
	local time = GetOverseerTime()

	for k,v in pairs(playerstats.worn_items) do
		if v.item_name == data.old_skin and v.endtime == nil then
			v.endtime = time
			break
		end
	end

	local item = {}
	item.item_name = data.new_skin
	item.starttime = time
	item.endtime = nil
	table.insert(playerstats.worn_items, item)
end

function WorldOverseer:OnItemCrafted(player, data)
	if not data then return end
	if not data.skin then return end

	local playerstats = self._seenplayers[player]
	table.insert (playerstats.crafted_items, data.skin)
end

function WorldOverseer:OnEquipSkinnedItem(player, data)
	if not data then return end

	local playerstats = self._seenplayers[player]
	local time = GetOverseerTime()

	local item ={}
	item.item_name = data
	item.starttime = time
	item.endtime = nil

	table.insert(playerstats.worn_items, item)
end

function WorldOverseer:OnUnequipSkinnedItem(player, data)
	if not data then return end

	local playerstats = self._seenplayers[player]
	local time = GetOverseerTime()

	for k,v in pairs(playerstats.worn_items) do
		if v.item_name == data and v.endtime == nil then
			v.endtime = time
			break
		end
	end
end

function WorldOverseer:GetWorldRecipeItems()
    if TheWorld == nil then return nil end
    if Ents == nil or not next(Ents) then return nil end

    local found = {}
    for k,ent in pairs(Ents) do
        if ent.prefab ~= nil and (AllRecipes[ent.prefab] ~= nil or ent:HasTag("preparedfood")) then
            table.insert(found, ent)
        end
    end

    return Stats.PrefabListToMetrics(found)
end

function WorldOverseer:DumpSessionStats()
	local hosting = TheNet:GetUserID()
	local sendstats = Stats.BuildContextTable(hosting)
    sendstats.event = "heartbeat.session"
	-- we don't have to send the host, as the sending user will be the host

    local clients = TheNet:GetClientTable() or {}

    sendstats.mpsession = {
                            save_id = self.inst.meta.session_identifier,
                            worldage = self._cycles,
                            num_players = #clients,
                            max_players = TheNet:GetServerMaxPlayers(),
                            password = TheNet:GetServerHasPassword(),
                            gamemode = TheNet:GetServerGameMode(),
                            dedicated = not TheNet:GetServerIsClientHosted(),
                            administrated = TheNet:GetServerHasPresentAdmin(),
                            modded = TheNet:GetServerModsEnabled(),
                            privacy = (TheNet:GetServerClanID() ~= "" and "CLAN")
                                    or (TheNet:GetServerLANOnly() and "LAN")
                                    or (TheNet:GetServerFriendsOnly() and "FRIENDS")
                                    or "PUBLIC",
                            offline = not TheNet:IsOnlineMode(),
                            --intention = TheNet:GetServerIntention(), -- deprecated
                            pvp = TheNet:GetServerPVP()
                        }
    local clanid = TheNet:GetServerClanID()
    if clanid ~= "" then
        sendstats.mpsession.clan_id = clanid
        sendstats.mpsession.clan_only = TheNet:GetServerClanOnly()
        --sendstats.clan_admins = TheNet:GetServerClanAdmins() -- not available in the handshake!
    end
    sendstats.recipe_items = self:GetWorldRecipeItems()

    --print("SENDING SESSION STATS VVVVVVVVVVVV")
    --dumptable(sendstats)
    --print("SENDING SESSION STATS ^^^^^^^^^^^^")
	local jsonstats = json.encode_compliant(sendstats)
	TheSim:SendProfileStats(jsonstats)
end

function WorldOverseer:OnPlayerJoined(src,player)

	self:RecordPlayerJoined(player)
	self.inst:ListenForEvent("death", function(inst, data) self:OnPlayerDeath(inst, data) end, player)
	self.inst:ListenForEvent("changeclothes", function (inst, data) self:OnPlayerChangedSkin(inst, data) end, player)
	self.inst:ListenForEvent("buildstructure", function (inst, data) self:OnItemCrafted(inst, data) end, player)
	self.inst:ListenForEvent("builditem", function (inst, data) self:OnItemCrafted(inst, data) end, player)
	self.inst:ListenForEvent("equipskinneditem", function(inst, data) self:OnEquipSkinnedItem(inst, data) end, player)
	self.inst:ListenForEvent("unequipskinneditem", function(inst, data) self:OnUnequipSkinnedItem(inst, data) end, player)

	-- The initial clothing is set before the Overseer starts listening to the events
	-- so we have to manually grab the items for the analytics
	if player.components.skinner then
		local initial_clothing = player.components.skinner:GetClothing()
		for k,v in pairs(initial_clothing) do
			if v and v ~= "" then
				self:OnEquipSkinnedItem(player, v)
			end
		end
	end

end

function WorldOverseer:OnPlayerLeft(src,player)
	self:RecordPlayerLeft(player)
end

function WorldOverseer:Heartbeat()
	self:DumpPlayerStats()
	self:DumpSessionStats()
end


--Note: Peter is only responsible for code below this comment :)
function WorldOverseer:HeartbeatPoll()
    if not TheWorld.ismastershard then
        return
    end

    local time_now = os.time()

    local client_table = TheNet:GetClientTable() or {}
    local current_players = {}
    for _,v in ipairs(client_table) do
        current_players[v.userid] = { prefab = v.prefab }
    end

    local resumed_from_suspend = (time_now - self.last_heartbeat_poll_time) > 15 * 60
    self.last_heartbeat_poll_time = time_now

    if resumed_from_suspend then
        --start a new session for everyone
        for k,_ in pairs(self._v2_seenplayers) do
            print("New time stamps for everyone at", time_now)
            self._v2_seenplayers[k].gameplay_session_id = time_now
        end
    end

    for k,v in pairs(current_players) do
        if self._v2_seenplayers[k] == nil then
            --New player joined

            self._v2_seenplayers[k] = {
                gameplay_session_id = time_now,
                prefab = v.prefab
            }
            self:SendClientJoin(k, self._v2_seenplayers[k])
        end
    end

    for k,v in pairs(self._v2_seenplayers) do
        if current_players[k] == nil then
            --Player quit

            if not resumed_from_suspend then
                self:SendClientQuit(k, v)
            end
            self._v2_seenplayers[k] = nil
        end
    end

    --Send heartbeat after some time. We want this to come after the rest of this update, so that coming back from a resume will
    self.heartbeat_poll_counter = self.heartbeat_poll_counter + WORLDOVERSEER_HEARTBEAT_POLL
    if self.heartbeat_poll_counter > WORLDOVERSEER_HEARTBEAT then
        self.heartbeat_poll_counter = 0
        for k,v in pairs(self._v2_seenplayers) do
            self:SendClientHeartBeat(k, v)
        end
    end
end


function WorldOverseer:QuitAll()
    for k,v in pairs(self._v2_seenplayers) do
        self:SendClientQuit(k, v)
    end
end



function WorldOverseer:SendClientJoin(userid, data)
    local sendstats = Stats.BuildContextTable(userid)
    sendstats.event = "SESSION_BEGIN"
    sendstats.GameplaySessionID = tostring(data.gameplay_session_id)
    sendstats.character = data.prefab

    --print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Send Join event")
    --dumptable(sendstats)
    local jsonstats = json.encode_compliant(sendstats)
    TheSim:SendProfileStats(jsonstats)
end

function WorldOverseer:SendClientHeartBeat(userid, data)
    local sendstats = Stats.BuildContextTable(userid)
    sendstats.event = "HEARTBEAT"
    sendstats.GameplaySessionID = tostring(data.gameplay_session_id)
    sendstats.character = data.prefab

    --print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Send Heartbeat event")
    --dumptable(sendstats)
    local jsonstats = json.encode_compliant(sendstats)
    TheSim:SendProfileStats(jsonstats)
end

function WorldOverseer:SendClientQuit(userid, data)
    local sendstats = Stats.BuildContextTable(userid)
    sendstats.event = "SESSION_END"
    sendstats.GameplaySessionID = tostring(data.gameplay_session_id)
    sendstats.character = data.prefab

    --print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Send Quit event")
    --dumptable(sendstats)
    local jsonstats = json.encode_compliant(sendstats)
    TheSim:SendProfileStats(jsonstats)
end



return WorldOverseer