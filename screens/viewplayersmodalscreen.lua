local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local PlayerBadge = require "widgets/playerbadge"
local TEMPLATES = require "widgets/redux/templates"
local ScrollableList = require "widgets/scrollablelist"

local ViewPlayersModalScreen = Class(Screen, function(self, players, maxPlayers)
    Widget._ctor(self, "ViewPlayersModalScreen")

    --Note: assumes players data excludes dedicated host

    self.players = players or {}
    self.max_players = maxPlayers or "?"

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.root = self:AddChild(TEMPLATES.ScreenRoot())

    local buttons = nil
    if TheInput:ControllerAttached() then
        -- Button is awkward to navigate to, so rely on CONTROL_CANCEL instead.
        buttons = {}
    else
        buttons = {
            {
                text = STRINGS.UI.SERVERLISTINGSCREEN.OK,
                cb = function() self:Cancel() end,
            },
        }
    end
    self.dialog = self.root:AddChild(TEMPLATES.CurlyWindow(325, 400, STRINGS.UI.SERVERLISTINGSCREEN.PLAYERS, buttons, nil, "x/y"))

    self.players_number = self.dialog.body
    self.players_number:SetHAlign(ANCHOR_RIGHT)
    self.players_number:SetVAlign(ANCHOR_TOP)
    self.players_number:SetPosition(0,50)

    self.numPlayers = #self.players
    self.players_number:SetString(self.numPlayers.."/"..self.max_players)

    local function listingConstructor(v, i)
        local playerListing =  Widget("playerListing")

        local displayName = ApplyLocalWordFilter(table.typecheckedgetfield(v, "string", "name") or "", TEXT_FILTER_CTX_NAME)
        playerListing.highlight = playerListing:AddChild(Image("images/scoreboard.xml", "row_short_goldoutline.tex"))
        playerListing.highlight:SetPosition(27, 0)
        playerListing.highlight:ScaleToSize(307,53)
        playerListing.highlight:Hide()

        local badge_x = -110
        local colour = table.typecheckedgetfield(v, "table", "colour")
        if type(colour.r) ~= "number" or type(colour.g) ~= "number" or type(colour.b) ~= "number" or type(colour.a) ~= "number" then
            colour = nil
        end
        playerListing.characterBadge = playerListing:AddChild(PlayerBadge(table.typecheckedgetfield(v, "string", "prefab"), colour or DEFAULT_PLAYER_COLOUR, table.typecheckedgetfield(v, nil, "performance") ~= nil, table.typecheckedgetfield(v, "number", "userflags") or 0))
        playerListing.characterBadge:SetScale(.45)
        playerListing.characterBadge:SetPosition(badge_x,0,0)

        --[[playerListing.adminBadge = playerListing:AddChild(ImageButton("images/avatars.xml", "avatar_admin.tex", "avatar_admin.tex", "avatar_admin.tex", nil, nil, {1,1}, {0,0}))
        playerListing.adminBadge:Disable()
        playerListing.adminBadge:SetPosition(badge_x-13,-10,0)
        playerListing.adminBadge.image:SetScale(.175)
        playerListing.adminBadge.scale_on_focus = false
        playerListing.adminBadge:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.ADMIN, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        if not v.admin then
            playerListing.adminBadge:Hide()
        end]]

        if IsAnyFestivalEventActive() then
            playerListing.rank = playerListing:AddChild(TEMPLATES.FestivalNumberBadge())
            playerListing.rank:SetPosition(badge_x-13- 20, -4)
            playerListing.rank:SetScale(.5)
            playerListing.rank:SetRank(table.typecheckedgetfield(v, "number", "eventlevel") or 0)
        end

        playerListing.name = playerListing:AddChild(Text(TALKINGFONT, 26))
        playerListing.name:SetColour(unpack(v.colour or DEFAULT_PLAYER_COLOUR))
        playerListing.name:SetTruncatedString(displayName, 210, 44, true)
        local w, h = playerListing.name:GetRegionSize()
        playerListing.name:SetPosition(w * .5 - 85, -3, 0)

        --[[local agestring = v.playerage ~= nil and v.playerage > 0 and (STRINGS.UI.PLAYERSTATUSSCREEN.AGE_PREFIX..tostring(v.playerage)) or ""
        playerListing.age = playerListing:AddChild(Text(NEWFONT_OUTLINE, 25, agestring))
        playerListing.age:SetPosition(80,0,0)
        playerListing.age:SetHAlign(ANCHOR_MIDDLE)]]

        local scale = .5

        playerListing.viewprofile = playerListing:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "steam.tex" ))
        playerListing.viewprofile:SetPosition(137,-2,0)
        playerListing.viewprofile:SetScale(scale)
        --playerListing.viewprofile:SetNormalScale(scale)
        --playerListing.viewprofile:SetFocusScale(scale+.1)
        --playerListing.viewprofile:SetFocusSound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
        --playerListing.viewprofile:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, { font = NEWFONT_OUTLINE, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.viewprofile:SetOnClick(
            function()
                --TheFrontEnd:PushScreen(PlayerAvatarPopupScreen(v.name, v))
                local netid = table.typecheckedgetfield(v, "string", "netid")
                if netid then
                    TheNet:ViewNetProfile(netid)
                end
            end)

        -- Skipping check for hiding my own profile button
        -- Shouldn't see this screen if i'm in game unless I just D/C and listings haven't updated
        -- Also, my offline ID won't match my online ID as well
        if TheNet:IsNetIDPlatformValid(table.typecheckedgetfield(v, "string", "netid")) then
            playerListing.focus_forward = playerListing.viewprofile
        else
            playerListing.viewprofile:Hide()
        end

        if IsPS4() then
            playerListing.viewprofile:Hide()
        end

		if IsXB1() then
	        playerListing.OnControl = function(self, control, down)
	            if Widget.OnControl(playerListing, control, down) then return true end

	            if not down then
	                if control == CONTROL_MAP then
	                    TheNet:ViewNetProfile(table.typecheckedgetfield(v, "string", "netid"))
	                end
	            end
	        end
		end

        playerListing.OnGainFocus = function()
            -- playerListing.name:SetSize(43)
            playerListing.highlight:Show()
        end
        playerListing.OnLoseFocus = function()
            -- playerListing.name:SetSize(35)
            playerListing.highlight:Hide()
        end

        return playerListing
    end

    self.list_root = self.dialog:AddChild(Widget("list_root"))
    self.list_root:SetPosition(70, 30)

    self.player_widgets = {}
    for i,v in ipairs(self.players) do
        table.insert(self.player_widgets, listingConstructor(v, i))
    end

    self.scroll_list = self.list_root:AddChild(ScrollableList(
            self.player_widgets, -- items
            180,                 -- listwidth
            300,                 -- listheight
            30,                  -- itemheight
            10,                  -- itempadding
            nil,                 -- updatefn
            nil,                 -- widgetstoupdate
            nil,                 -- widgetXOffset
            nil,                 -- always_show_static
            nil,                 -- starting_offset
            10,                  -- yInit
            nil,                 -- bar_width_scale_factor
            nil,                 -- bar_height_scale_factor
            "GOLD"               -- scrollbar_style
        ))

    self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.dialog.actions)
    self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.dialog.actions)
    self.dialog.actions:SetFocusChangeDir(MOVE_UP, self.scroll_list)

	if IsPS4() then
		-- ps4 can't do anything with the players/list (no view profile) so there's no point in focusing on it
		self.default_focus = nil
	else
		self.default_focus = self.scroll_list
	end

    if #self.players == 0 then
        self.scroll_list:Hide()
        self.empty_server_text = self.dialog:AddChild(Text(CHATFONT, 30, STRINGS.UI.PLAYERSTATUSSCREEN.EMPTY_SERVER))
        self.empty_server_text:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
        self.default_focus = self.dialog.actions
    end
end)

function ViewPlayersModalScreen:Cancel()
    TheFrontEnd:PopScreen()
end

function ViewPlayersModalScreen:OnControl(control, down)
    if ViewPlayersModalScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        self:Cancel()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function ViewPlayersModalScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	if IsXB1() then
    	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP) .. " " .. STRINGS.UI.PLAYERSTATUSSCREEN.VIEWGAMERCARD)
	end
    return table.concat(t, "  ")
end

return ViewPlayersModalScreen
