local Grid = require "widgets/grid"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local UserCommands = require "usercommands"
local Text = require "widgets/text"
local PopupDialogScreen = require "screens/redux/popupdialog"

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
	    portrait._nowaiting = portrait:AddChild(Text(CHATFONT_OUTLINE, 20, STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.PLATER_VOTED_TO_FORCE_START, UICOLOURS.GOLD))
		portrait._nowaiting:SetPosition(0, -143)
		portrait._nowaiting:SetHAlign(ANCHOR_MIDDLE)

        table.insert(self.player_listing, portrait)
	end

    self.list_root = self.proot:AddChild(Grid())
    self.list_root:FillGrid(3, 250, 280, self.player_listing)
    self.list_root:SetPosition(-250, 280/2 + 20)

    local nowaiting_checkbox = self:AddChild(ImageButton())
    nowaiting_checkbox:SetTextColour(UICOLOURS.GOLD)
    nowaiting_checkbox:SetTextFocusColour(UICOLOURS.HIGHLIGHT_GOLD)
    nowaiting_checkbox:SetFont(CHATFONT_OUTLINE)
    nowaiting_checkbox:SetDisabledFont(CHATFONT_OUTLINE)
    nowaiting_checkbox:SetTextDisabledColour(UICOLOURS.GOLD)
    nowaiting_checkbox:SetText(subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.ENABLE_NO_WAITING_HELPTEXT, {num=#self.players, max=TheNet:GetServerMaxPlayers()}))
    nowaiting_checkbox:SetTextSize(25)
    nowaiting_checkbox.text:SetRegionSize(300,30)
    nowaiting_checkbox.text:SetHAlign(ANCHOR_LEFT)
    nowaiting_checkbox.text:SetPosition(150 + 20, 0)
    nowaiting_checkbox.local_nowaiting = false
    nowaiting_checkbox:SetPosition(-150, -314)
    nowaiting_checkbox.clickoffset = Vector3(0,0,0)

    local nowaiting_warned = false --shown once everytime we enter/return to lobby

    nowaiting_checkbox:SetOnClick(function()
		if not nowaiting_warned then
			TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_TITLE, subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_BODY, {num=#self.players, max=TheNet:GetServerMaxPlayers()}),
				{
					{text=STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_CONTINUE, cb = function() nowaiting_warned = true TheFrontEnd:PopScreen() nowaiting_checkbox.onclick() end },
					{text=STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.VOTE_POPUP_CANCEL, cb = function() TheFrontEnd:PopScreen() end}
				}))
		else
			nowaiting_checkbox:Disable()
			nowaiting_checkbox.local_nowaiting = not nowaiting_checkbox.local_nowaiting
			UserCommands.RunUserCommand("nowaitingforplayers", {no_waiting="true"}, TheNet:GetClientTableForUser(TheNet:GetUserID()))
			nowaiting_checkbox.timeout_task = nowaiting_checkbox.inst:DoTaskInTime(5, function() 
				nowaiting_checkbox.local_nowaiting = TheWorld.net ~= nil and TheWorld.net.components.worldcharacterselectlobby:GetNoWaitingVote(TheNet:GetUserID()) or false
				nowaiting_checkbox:Enable()
				nowaiting_checkbox:Refresh()
			end)
		end
	end)
    self.inst:ListenForEvent("nowaiting_vote_dirty", function(net)
		if net.components.worldcharacterselectlobby:GetNoWaitingVote(TheNet:GetUserID()) == nowaiting_checkbox.local_nowaiting then
			if nowaiting_checkbox.timeout_task ~= nil then
				nowaiting_checkbox.timeout_task:Cancel()
				nowaiting_checkbox.timeout_task = nil
			end
			nowaiting_checkbox:Enable()
			nowaiting_checkbox:Refresh()
		elseif nowaiting_checkbox.timeout_task == nil then
			nowaiting_checkbox.local_nowaiting = net.components.worldcharacterselectlobby:GetNoWaitingVote(TheNet:GetUserID())
			nowaiting_checkbox:Enable()
			nowaiting_checkbox:Refresh()
		end
	end, TheWorld.net)
	nowaiting_checkbox.Refresh = function()
		if nowaiting_checkbox.local_nowaiting then
			nowaiting_checkbox:SetTextures("images/global_redux.xml", "checkbox_normal_check.tex", "checkbox_focus_check.tex", "checkbox_normal.tex", nil, nil, {1,1}, {0,0})
		else
			nowaiting_checkbox:SetTextures("images/global_redux.xml", "checkbox_normal.tex", "checkbox_focus.tex", "checkbox_normal_check.tex", nil, nil, {1,1}, {0,0})
		end
	end

    self.nowaiting_checkbox = nowaiting_checkbox
    self.nowaiting_checkbox:Hide()
    self.nowaiting_checkbox:Refresh()

    local spawndelaytext = self:AddChild(Text(CHATFONT, 50))
    spawndelaytext:SetPosition(0, -290)
    spawndelaytext:SetColour(UICOLOURS.GOLD)
    spawndelaytext:Hide()
	
	self:RefreshNoWaitingDisplay()
	
	self.inst:ListenForEvent("nowaiting_vote_dirty", function() self:RefreshNoWaitingDisplay() end, TheWorld.net)

	self.inst:ListenForEvent("lobbyplayerspawndelay", function(world, data)
		if data and data.active then
			self.spawn_countdown_active = true
			self:RefreshNoWaitingDisplay()

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

function WaitingForPlayers:GetPlayerTable()
    local ClientObjs = TheNet:GetClientTable()
    if ClientObjs == nil then
        return {}
    elseif TheNet:GetServerIsClientHosted() then
        return ClientObjs
    end

    --remove dedicate host from player list
    for i, v in ipairs(ClientObjs) do
        if v.performance ~= nil then
            table.remove(ClientObjs, i)
            break
        end
    end
    return ClientObjs 
end

local function UpdatePlayerListing(widget, data)
    local empty = data == nil or next(data) == nil

    widget.userid = not empty and data.userid or nil
    widget.performance = not empty and data.performance or nil

    if empty then
        widget:SetEmpty()
     	widget._nowaiting:Hide()
    else
        local prefab = data.lobbycharacter or data.prefab or ""
        widget:UpdatePlayerListing(data.name, data.colour, prefab, GetSkinsDataFromClientTableData(data))

		if prefab ~= "" and prefab ~= "random" then
			local weapon =  TUNING.LAVAARENA_STARTING_ITEMS[string.upper(prefab)][1]
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

			local armour =  TUNING.LAVAARENA_STARTING_ITEMS[string.upper(prefab)][2]
			armour = item_swap_overrides[armour] or armour
			if armour ~= nil and armour ~= "" then
				widget.puppet.animstate:OverrideSymbol("swap_body", armour, "swap_body")
			else
				widget.puppet.animstate:ClearOverrideSymbol("swap_body")
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

    self:RefreshNoWaitingDisplay()

    if prev_num_players ~= #self.players then
        self.nowaiting_checkbox:SetText(subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.ENABLE_NO_WAITING_HELPTEXT, {num=#self.players, max=TheNet:GetServerMaxPlayers()}))
    end
end

function WaitingForPlayers:RefreshNoWaitingDisplay()
	local prev_allow_vote = self.allow_no_waiting_vote
	self.allow_no_waiting_vote = #self.players ~= TheNet:GetServerMaxPlayers() and not self.spawn_countdown_active

	if TheWorld.net ~= nil and TheWorld.net.components.worldcharacterselectlobby ~= nil then
		for i, widget in ipairs(self.player_listing) do
			if self.allow_no_waiting_vote and widget.userid ~= nil and TheWorld.net.components.worldcharacterselectlobby:GetNoWaitingVote(widget.userid) then
     			widget._nowaiting:Show()
			else
     			widget._nowaiting:Hide()
			end
		end
	end

	if prev_allow_vote and not self.allow_no_waiting_vote then
		if self.nowaiting_checkbox.timeout_task ~= nil then
			self.nowaiting_checkbox.timeout_task:Cancel()
			self.nowaiting_checkbox.timeout_task = nil
		end
		self.nowaiting_checkbox:Disable()
		self.nowaiting_checkbox:Hide()
		self.nowaiting_checkbox.local_nowaiting = false
		self.nowaiting_checkbox:Refresh()
	elseif self.allow_no_waiting_vote and not prev_allow_vote then
		self.nowaiting_checkbox:Enable()
		if not TheInput:ControllerAttached() then
			self.nowaiting_checkbox:Show()
		end
		self.nowaiting_checkbox:Refresh()
	end
	
end

function WaitingForPlayers:OnControl(control, down)
	if Widget.OnControl(self, control, down) then return true end

	if (not down) and control == CONTROL_PAUSE then
		if self.nowaiting_checkbox:IsEnabled() then
			self.nowaiting_checkbox.onclick()
		end
		return true
	end
end

function WaitingForPlayers:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if self.allow_no_waiting_vote and self.nowaiting_checkbox:IsEnabled() then
		local str = STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.DISABLE_NO_WAITING_HELPTEXT
		if not self.nowaiting_checkbox.local_nowaiting then
			str = subfmt(STRINGS.UI.LOBBY_WAITING_FOR_PLAYERS_SCREEN.ENABLE_NO_WAITING_HELPTEXT, {num=#self.players, max=TheNet:GetServerMaxPlayers()})
		end
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. " " .. str)
	end
	
    return table.concat(t, "  ")
end


return WaitingForPlayers
