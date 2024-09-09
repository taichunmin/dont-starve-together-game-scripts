local Grid = require "widgets/grid"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local UserCommands = require "usercommands"
local Text = require "widgets/text"
local PopupDialogScreen = require "screens/redux/popupdialog"

local TEMPLATES = require "widgets/redux/templates"

local item_swap_overrides =
{
	lavaarena_lucy = "swap_lucy_axe",
	book_fossil = "", -- books are not heald in hands
	lavaarena_armorlight = "armor_light",
    lavaarena_armorlightspeed = "armor_lightspeed",
    lavaarena_armormedium = "armor_medium",
}

--------------------------------------------------------------------------
--  A grid of player puppets for the lobby screen "player ready, waiting for other players" screen
--
local WaitingForPlayers = Class(Widget, function(self, owner, max_players)
    self.owner = owner
    Widget._ctor(self, "WaitingForPlayers")

    self.players = self:GetPlayerTable()

    self.proot = self:AddChild(Widget("ROOT"))

	self.player_listing = {}
	for i = 1, max_players do
		local portrait = PlayerAvatarPortrait()
		portrait.frame:SetScale(.43)
	    portrait._playerreadytext = portrait:AddChild(Text(CHATFONT_OUTLINE, 20, STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.PLAYER_VOTED_TO_FORCE_START, UICOLOURS.GOLD))
		portrait._playerreadytext:SetPosition(0, -143)
		portrait._playerreadytext:SetHAlign(ANCHOR_MIDDLE)

        table.insert(self.player_listing, portrait)
	end

    self.list_root = self.proot:AddChild(Grid())
    self.list_root:FillGrid(3, 250, 280, self.player_listing)
    self.list_root:SetPosition(-250, (max_players > 3 and (280/2) or 0) + 20)

	local function playerready_checkbox_onclicked(widget)
		if (#self.players < TheNet:GetServerMaxPlayers()) and not widget.votestart_warned then
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_TITLE, STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_BODY,
				{
					{text=STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_CONTINUE, cb = function() widget.votestart_warned = true TheFrontEnd:PopScreen() widget:onclick() end },
					{text=STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_CANCEL, cb = function() TheFrontEnd:PopScreen() end}
				}, nil, "medium", "dark_wide" ))
		else
			widget.checked = not widget.checked
			widget:Disable()
			widget:Refresh()

			UserCommands.RunUserCommand("playerreadytostart", {ready="true"}, TheNet:GetClientTableForUser(TheNet:GetUserID()))
			widget.timeout_task = widget.inst:DoTaskInTime(5, function()
				widget.checked = TheWorld.net ~= nil and TheWorld.net.components.worldcharacterselectlobby:IsPlayerReadyToStart(TheNet:GetUserID()) or false
				widget:Enable()
				widget:Refresh()
			end)
		end
	end

	local playerready_checkbox = self:AddChild(TEMPLATES.LabelCheckbox(playerready_checkbox_onclicked, false, ""))
	playerready_checkbox.votestart_warned = false
	playerready_checkbox.RecenterCheckbox = function()
		local text_width = playerready_checkbox.text:GetRegionSize()
	    playerready_checkbox.text:SetPosition(playerready_checkbox._text_offset + text_width/2, 0)
		playerready_checkbox:SetPosition(-text_width/2, -314)
	end

    self.inst:ListenForEvent("player_ready_to_start_dirty", function(net)
		if net.components.worldcharacterselectlobby:IsPlayerReadyToStart(TheNet:GetUserID()) == playerready_checkbox.checked then
			if playerready_checkbox.timeout_task ~= nil then
				playerready_checkbox.timeout_task:Cancel()
				playerready_checkbox.timeout_task = nil
			end
			playerready_checkbox:Enable()
		elseif playerready_checkbox.timeout_task == nil then
			playerready_checkbox.checked = net.components.worldcharacterselectlobby:IsPlayerReadyToStart(TheNet:GetUserID())
			playerready_checkbox:Enable()
			playerready_checkbox:Refresh()
		end
	end, TheWorld.net)

    self.playerready_checkbox = playerready_checkbox
    self.playerready_checkbox:Hide()

    local spawndelaytext = self:AddChild(Text(CHATFONT, 50))
    spawndelaytext:SetPosition(0, -290)
    spawndelaytext:SetColour(UICOLOURS.GOLD)
    spawndelaytext:Hide()

	self:RefreshPlayersReady()

	self.inst:ListenForEvent("player_ready_to_start_dirty", function() self:RefreshPlayersReady() end, TheWorld.net)

	self.inst:ListenForEvent("lobbyplayerspawndelay", function(world, data)
		if data and data.active then
			self.spawn_countdown_active = true
			self:RefreshPlayersReady()

            --subtract one so we hang on 0 for a second
            local str = subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.SPAWN_DELAY, { time = math.max(0, data.time - 1) })
            if str ~= spawndelaytext:GetString() or not spawndelaytext.shown then
                spawndelaytext:SetString(str)
                spawndelaytext:Show()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/WorldDeathTick")
            end
		end

	end, TheWorld)

end)

function WaitingForPlayers:IsServerFull()
	return #self.players == TheNet:GetServerMaxPlayers()
end

function WaitingForPlayers:GetPlayerTable()
	local ClientObjs = TheNet:GetClientTable()
	if ClientObjs == nil then
		return {}
	end

	if not TheNet:GetServerIsClientHosted() then
		--remove dedicate host from player list
		for i, v in ipairs(ClientObjs) do
			if v.performance ~= nil then
				table.remove(ClientObjs, i)
				break
			end
		end
	end

	if self.show_local_player_first then
		local local_user_id = TheNet:GetUserID()
		table.sort(ClientObjs, function(a, b) return (a.userid == local_user_id) and (b.userid ~= local_user_id) end)
	end

    return ClientObjs
end

local function UpdatePlayerListing(widget, data)
    local empty = data == nil or next(data) == nil

    widget.userid = not empty and data.userid or nil
    widget.performance = not empty and data.performance or nil

    if empty then
        widget:SetEmpty()
     	widget._playerreadytext:Hide()
    else
        local prefab = data.lobbycharacter or data.prefab or ""
        widget:UpdatePlayerListing(data.name, data.colour, prefab, GetSkinsDataFromClientTableData(data))

		if prefab ~= "" and prefab ~= "random" then
			local starting_items = TUNING.GAMEMODE_STARTING_ITEMS[TheNet:GetServerGameMode()]
			if starting_items ~= nil then
				local weapon = starting_items[string.upper(prefab)][1]
				weapon = item_swap_overrides[weapon] or ("swap_"..weapon)
				if weapon ~= nil and weapon ~= "" then
					widget.puppet.animstate:OverrideSymbol("swap_object", weapon, weapon)
					widget.puppet.animstate:Show("ARM_carry")
					widget.puppet.animstate:Hide("ARM_normal")
				else
					widget.puppet.animstate:ClearOverrideSymbol("swap_object")
					widget.puppet.animstate:Hide("ARM_carry")
					widget.puppet.animstate:Show("ARM_normal")
				end

				local armour = starting_items[string.upper(prefab)][2]
				armour = item_swap_overrides[armour] or armour
				if armour ~= nil and armour ~= "" then
					widget.puppet.animstate:OverrideSymbol("swap_body", armour, "swap_body")
				else
					widget.puppet.animstate:ClearOverrideSymbol("swap_body")
				end
			end
		end
    end
end

function WaitingForPlayers:Refresh(force)
    local prev_num_players = self.players ~= nil and #self.players or 0
    self.players = self:GetPlayerTable()

    for i, widget in ipairs(self.player_listing) do
        local player = self.players[i]
        if force or player == nil or
            player.userid ~= widget.userid or
            player.lobbycharacter ~= widget.lobbycharacter or
            (player.performance ~= nil) ~= (widget.performance ~= nil)
            then
            UpdatePlayerListing(widget, player)
        end
    end

    self:RefreshPlayersReady()
end

function WaitingForPlayers:RefreshPlayersReady()
	if TheWorld.net ~= nil and TheWorld.net.components.worldcharacterselectlobby ~= nil then
		for i, widget in ipairs(self.player_listing) do
			if widget.userid ~= nil and TheWorld.net.components.worldcharacterselectlobby:IsPlayerReadyToStart(widget.userid) then
				widget._playerreadytext:SetString( self:IsServerFull() and STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.PLAYER_READY_TO_START or STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.PLAYER_VOTED_TO_FORCE_START)
     			widget._playerreadytext:Show()
			else
     			widget._playerreadytext:Hide()
			end
		end
	end

	if self.spawn_countdown_active then
		if self.playerready_checkbox.timeout_task ~= nil then
			self.playerready_checkbox.timeout_task:Cancel()
			self.playerready_checkbox.timeout_task = nil
		end
		self.playerready_checkbox:Disable()
		self.playerready_checkbox:Hide()
	else
        self.playerready_checkbox:SetText(self:IsServerFull() and STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.LOCAL_PLAYER_READY_TO_START or subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.LOCAL_PLAYER_VOTE_TO_START, {num=#self.players, max=TheNet:GetServerMaxPlayers()}))
		if not TheInput:ControllerAttached() then
			self.playerready_checkbox:RecenterCheckbox()
			self.playerready_checkbox:Show()
		end
	end
end

function WaitingForPlayers:OnControl(control, down)
	if Widget.OnControl(self, control, down) then return true end

	if (not down) and control == CONTROL_PAUSE then
		if self.playerready_checkbox:IsEnabled() then
			self.playerready_checkbox.onclick()
		end
		return true
	end
end

function WaitingForPlayers:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if self.playerready_checkbox:IsEnabled() then
		local str = STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.LOCAL_PLAYER_READY_CANCEL_HELPTEXT
		if not self.playerready_checkbox.checked then
			str = self:IsServerFull() and STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.LOCAL_PLAYER_READY_TO_START or subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.LOCAL_PLAYER_VOTE_TO_START, {num=#self.players, max=TheNet:GetServerMaxPlayers()})
		end
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. str)
	end

    return table.concat(t, "  ")
end


return WaitingForPlayers
