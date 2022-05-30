local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"

local Stats = require("stats")

local MAX_INITIAL_SEARCH_TIME = 7
local MAX_SEARCH_TIME = 15
local MAX_JOIN_ATTEMPTS = 40

if PLATFORM == "WIN32_RAIL" then
	MAX_INITIAL_SEARCH_TIME = 10
	MAX_SEARCH_TIME = 45
end

local QuickJoinScreen = Class(GenericWaitingPopup, function(self, prev_screen, offline, session_mapping, event_id, scorefn, tohostscreencb, tobrowsescreencb)
	GenericWaitingPopup._ctor(self, "QuickJoinScreen", (event_id == "" and STRINGS.UI.QUICKJOINSCREEN or STRINGS.UI.EVENT_QUICKJOINSCREEN).TITLE)

	self.event_id = event_id or ""
	self.string_table = self.event_id == "" and STRINGS.UI.QUICKJOINSCREEN or STRINGS.UI.EVENT_QUICKJOINSCREEN

    self.offline = offline

	self.log = true
    self.prev_screen = prev_screen
    self.scorefn = scorefn
    self.tohostscreencb = tohostscreencb
    self.tobrowsescreencb = tobrowsescreencb

    self.status_msg = self.dialog:AddChild(Text(CHATFONT, 28, self.string_table.BODY))
    self.status_msg:SetRegionSize(530, 28)
    self.status_msg:SetPosition(0,50)

    if BRANCH ~= "dev" then
        TheNet:SetCheckVersionOnQuery( true )
    end

    self.sessions = {}

    -- Query all data related to user sessions
    self.session_mapping = session_mapping

    TheNet:SearchServers(self.event_id)
    self.startsearchtime = GetStaticTime()

    self.keepsearchingtimer = 0
    self:KeepSearching(5)
end)

function QuickJoinScreen:ProcessPlayerData(session)
    if self.sessions[session] == nil and self.session_mapping ~= nil then
        local data = self.session_mapping[session]
        if data ~= nil then
            if type(data) == "table" and data.session_data_processed then
                self.sessions[session] = data.data
            else
                local success, playerdata = RunInSandboxSafe(data)
                self.sessions[session] = success and playerdata or false
                self.session_mapping[session] =
                {
                    session_data_processed = true,
                    data = self.sessions[session],
                }
            end
        end
    end

    return self.sessions[session] ~= nil and self.sessions[session] ~= false
end

function QuickJoinScreen:KeepSearching(searchtime)
	self.keepsearchingtimer = searchtime
end

function QuickJoinScreen:IsValidWithFilters(server)

    -- Filter our friends only servers that are not our friend
    if server.friends_only and not server.friend then
        return false
    end

    -- Filter servers that we aren't allowed to join.
    if server.clan_only and not server.belongs_to_clan then
        return false
    end

    -- Filter out unjoinable servers, if we are online
    -- NOTE: steamroom is not available for dedicated servers
    -- NOTE: Any server with a steam id can be joinable via punchthrough even if you can't ping it directly
    -- NOTE: steamnat is now the flag to check
    if self.view_online and not server.steamnat and server.ping < 0 then
        return false
    end

    -- If we are in offline mode, don't show online mode servers
    if TheFrontEnd:GetIsOfflineMode() and not server.offline then
        return false
    end

    -- Hide version mismatched servers (except beta) on live builds
    -- We don't count this towards unjoinable because you probably could
    -- have joined them previously, and this keeps the count consistent.
    local ignore_version = false
    if BRANCH == "dev" then
        if true then
            ignore_version = true
        else
            print("~~~### Quick Match Disabled On Dev Build ###~~~")
            print("This is so that dev builds don't connect to live servers and cause issues.")
            print("Turn it on only if you know what you're doing.")
        end
    end
    local version_mismatch = APP_VERSION ~= tostring(server.version)
    if not ignore_version and version_mismatch then
        return false
    end

	-- Filter servers that are only accepting players with existing characters in the world
	if not server.allow_new_players and not self:ProcessPlayerData(server.session) then
		return false
	end

	return true
end

function QuickJoinScreen:OnUpdate(dt)
    self._base.OnUpdate(self, dt)

	if self.keepsearchingtimer > 0 then
		self.keepsearchingtimer = self.keepsearchingtimer - dt
		if self.keepsearchingtimer <= 0 then
		    self:TryPickServer()
		end
	end

	if self.queuejoingame then
		self.queuejoingame = false
	    self:JoinGame()
	end
end

function QuickJoinScreen:ShouldKeepSearching()
	return TheNet:GetServerListingReadDirty() and TheNet:IsSearchingServers() and (GetStaticTime() - self.startsearchtime) < MAX_INITIAL_SEARCH_TIME
end

local function PickBestServers(servers)
	if servers == nil or #servers <= 1 then
		return servers
	end

	local all_servers = servers
	servers = {}

	table.sort(all_servers, function(a,b)
		if a.score > b.score then
			return true
		elseif a.score == b.score then
			return a.ping < b.ping
		else
			return false
		end
	end)

	-- take best rated servers
	for i = 1, MAX_JOIN_ATTEMPTS do
		table.insert(servers, all_servers[i])
	end

	-- shuffle best rated servers then sort on priorty (without sorting on ping)
	shuffleArray(servers)
	table.sort(servers, function(a,b)
		if a.score > b.score then
			return true
		else
			return false
		end
	end)

	return servers
end

function QuickJoinScreen:TryPickServer()
    if self:ShouldKeepSearching() then
	    self:KeepSearching(1)

	    --print("[QuickJoin]: Still Searching", (GetStaticTime() - self.startsearchtime))
	    return
	end

	self.servertojoin = nil
    self.filtered_servers = {}

    local servers = TheNet:GetServerListings()
    if servers ~= nil then
		for i, v in ipairs(servers) do
			if self:IsValidWithFilters(v) then
				v._has_character_on_server = self:ProcessPlayerData(v.session)
				local score = self.scorefn ~= nil and self.scorefn(v) or 0
				if score >= 0 then
					table.insert(self.filtered_servers,
						{
                    		score = score,
							actualindex = i,
							name=v.name,
							ping=v.ping > 0 and v.ping or 9999,
							ip=v.ip,
						})
				end
			end
		end

    end

	if #self.filtered_servers == 0 then
	    if (GetStaticTime() - self.startsearchtime) < MAX_SEARCH_TIME then
		    self:KeepSearching(2)
		else
			print("[QuickJoin]: no servers passed the filters.")
			self:KeepSearching(0)
		    TheNet:StopSearchingServers()

		    -- throws up the error dialog
			self.servertojoin = MAX_JOIN_ATTEMPTS
			self:TryNextServer()
		end
	else
	    print("[QuickJoin]: Done Searching. " .. string.format("Searched for %.2fs. %d of %d servers passed the filter", (GetStaticTime() - self.startsearchtime), #self.filtered_servers, #servers))

		self:KeepSearching(0)
	    TheNet:StopSearchingServers()

		self.filtered_servers = PickBestServers(self.filtered_servers)

		if BRANCH == "dev" then
			for k,v in ipairs(self.filtered_servers) do print(" " .. k .. ": " .. v.score .. ", " .. v.ping .. " - " .. v.name) end
	    end

		self.servertojoin = 1
	    self.queuejoingame = true
	end

end

function QuickJoinScreen:TryNextServer(error, reason)
	local server = self.filtered_servers ~= nil and self.filtered_servers[self.servertojoin or MAX_JOIN_ATTEMPTS] or nil
	if server ~= nil and error ~= nil and reason ~= nil then
	    print(string.format("[QuickJoin]: Failed to join: %s, %s - %s: %s", server.name, tostring(server.ip), tostring(error), tostring(reason)))
	end

	if self.servertojoin ~= nil and self.servertojoin < math.min(self.filtered_servers ~= nil and #self.filtered_servers or 0, MAX_JOIN_ATTEMPTS) then
		self.servertojoin = self.servertojoin + 1
		self.queuejoingame = true
	else
		local values = {}
		values.numservers = self.filtered_servers ~= nil and #self.filtered_servers or 0
		values.special_event = (self.event_id and #self.event_id > 0) and self.event_id or nil
		Stats.PushMetricsEvent("quickjoin.failed", TheNet:GetUserID(), values)

		TheFrontEnd:PushScreen(PopupDialogScreen(self.string_table.NO_SERVERS_TITLE, self.string_table.NO_SERVERS_MSG,
			{
				{text=self.string_table.NO_SERVERS_BROWSE, cb = function()
						TheFrontEnd:PopScreen()
						self.tobrowsescreencb()
					end},

				{text=self.string_table.NO_SERVERS_HOST, cb = function()
						TheFrontEnd:PopScreen()
						self.tohostscreencb()
					end},

				{text=self.string_table.NO_SERVERS_CLOSE, cb = function()
						TheFrontEnd:PopScreen()
					end},
			}))


		self:Close()
	end
end

function QuickJoinScreen:JoinGame()
	if self.servertojoin and self.filtered_servers ~= nil then
		local server = self.filtered_servers[self.servertojoin]
	    self.status_msg:SetString(subfmt(self.string_table.CONNECTING_TO_SERVER, { server = server.name }))
	    TheFrontEnd:GetSound():PlaySound("dontstarve/common/lava_arena/player_joined")

		local sel_serv = TheNet:GetServerListingFromActualIndex(server.actualindex)
	    if sel_serv then
		    print(string.format("[QuickJoin]: %d - Trying to join: %s, %s", self.servertojoin, server.name, tostring(server.ip)))

		    local passworld = ""
			local start_worked = TheNet:JoinServerResponse( false, sel_serv.guid, passworld )
			if start_worked then
				DisableAllDLC()
			end
		end
	end

end

function QuickJoinScreen:OnControl(control, down)
    if QuickJoinScreen._base.OnControl(self,control, down) then return true end
end

-- base calls OnCancel
function QuickJoinScreen:OnCancel()
	local values = {}
	values.numservers = self.filtered_servers and #self.filtered_servers or nil
	values.special_event = (self.event_id and #self.event_id > 0) and self.event_id or nil
	values.user_aborted = true
	Stats.PushMetricsEvent("quickjoin.failed", TheNet:GetUserID(), values)

    self:Close()
end

function QuickJoinScreen:Close()
    TheNet:StopSearchingServers()
    TheNet:JoinServerResponse( true ) -- cancel join
	TheFrontEnd:PopScreen(self)
end

function QuickJoinScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

	return table.concat(t, "  ")
end

return QuickJoinScreen
