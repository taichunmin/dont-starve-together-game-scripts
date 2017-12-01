local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
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

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.clickroot = self:AddChild(Widget("clickroot"))
    self.clickroot:SetVAnchor(ANCHOR_MIDDLE)
    self.clickroot:SetHAnchor(ANCHOR_MIDDLE)
    self.clickroot:SetPosition(0,0,0)
    self.clickroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    local left_col =-RESOLUTION_X*.25 - 50
    local right_col = RESOLUTION_X*.25 - 75

    --menu buttons
    self.panel_root = self.clickroot:AddChild(Widget("panel_root"))
    self.panel_root:SetPosition(0,20,0)

    self.bg = self.root:AddChild(TEMPLATES.old.CurlyWindow(1, 325, .85, .8, 53, -32))
    self.bg.fill = self.root:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.bg.fill:SetScale(.5, -.5)
    self.bg.fill:SetPosition(8, 10)
    self.bg:SetPosition(0,0,0)

    if not TheInput:ControllerAttached() then
        self.button = self.panel_root:AddChild(ImageButton())
        self.button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.OK)
        self.button:SetOnClick(function() self:Cancel() end)
        self.button:SetPosition(0,-225)
        self.button:SetScale(.8)
    end

    self.title = self.panel_root:AddChild(Text(BUTTONFONT, 45, STRINGS.UI.SERVERLISTINGSCREEN.PLAYERS, {0,0,0,1}))
    self.title:SetPosition(5,150)

    self.upper_horizontal_line = self.panel_root:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.upper_horizontal_line:SetScale(1)
    self.upper_horizontal_line:SetPosition(7,129)

    self.players_number = self.panel_root:AddChild(Text(NEWFONT, 25, "x/y"))
    self.players_number:SetPosition(90,145) 
    self.players_number:SetRegionSize(100,30)
    self.players_number:SetHAlign(ANCHOR_RIGHT)
    self.players_number:SetColour(0, 0, 0, 1)

    self.numPlayers = #self.players
    self.players_number:SetString(self.numPlayers.."/"..self.max_players)

    local function listingConstructor(v, i)
        local playerListing =  Widget("playerListing")

        local displayName = v.name or ""

        playerListing.bg = playerListing:AddChild(Image("images/scoreboard.xml", "row_short.tex"))
        playerListing.bg:SetPosition(27, 0)
        playerListing.bg:ScaleToSize(305,51)
        playerListing.bg:SetTint(1, 1, 1, (i % 2) == 0 and .85 or .5)

        playerListing.highlight = playerListing:AddChild(Image("images/scoreboard.xml", "row_short_goldoutline.tex"))
        playerListing.highlight:SetPosition(27, 0)
        playerListing.highlight:ScaleToSize(307,53)
        playerListing.highlight:Hide()

        local badge_x = -110
        playerListing.characterBadge = playerListing:AddChild(PlayerBadge(v.prefab or "", v.colour or DEFAULT_PLAYER_COLOUR, v.performance ~= nil, v.userflags or 0))
        playerListing.characterBadge:SetScale(.45)
        playerListing.characterBadge:SetPosition(badge_x,0,0)

        --[[playerListing.adminBadge = playerListing:AddChild(ImageButton("images/avatars.xml", "avatar_admin.tex", "avatar_admin.tex", "avatar_admin.tex", nil, nil, {1,1}, {0,0}))
        playerListing.adminBadge:Disable()
        playerListing.adminBadge:SetPosition(badge_x-13,-10,0) 
        playerListing.adminBadge.image:SetScale(.175)
        playerListing.adminBadge.scale_on_focus = false
        playerListing.adminBadge:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.ADMIN, { font = NEWFONT_OUTLINE, size = 24, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        if not v.admin then
            playerListing.adminBadge:Hide()
        end]]

        if IsAnyFestivalEventActive() then
            playerListing.rank = playerListing:AddChild(TEMPLATES.FestivalNumberBadge())
            playerListing.rank:SetPosition(badge_x-13- 20, -4)  
            playerListing.rank:SetScale(.5)
            playerListing.rank:SetRank(v.eventlevel or 0)
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

        playerListing.viewprofile = playerListing:AddChild(TEMPLATES.old.IconButton("images/button_icons.xml", "steam.tex" ))
        playerListing.viewprofile:SetPosition(137,-2,0)
        playerListing.viewprofile:SetScale(scale)
        --playerListing.viewprofile:SetNormalScale(scale)
        --playerListing.viewprofile:SetFocusScale(scale+.1)
        --playerListing.viewprofile:SetFocusSound("dontstarve/HUD/click_mouseover")
        --playerListing.viewprofile:SetHoverText(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, { font = NEWFONT_OUTLINE, size = 24, offset_x = 0, offset_y = 30, colour = {1,1,1,1}})
        playerListing.viewprofile:SetOnClick(
            function()
                --TheFrontEnd:PushScreen(PlayerAvatarPopupScreen(v.name, v))
                if v.netid ~= nil then
                    TheNet:ViewNetProfile(v.netid)
                end
            end)

        -- Skipping check for hiding my own profile button
        -- Shouldn't see this screen if i'm in game unless I just D/C and listings haven't updated
        -- Also, my offline ID won't match my online ID as well
        if TheNet:IsNetIDPlatformValid(v.netid) then
            playerListing.focus_forward = playerListing.viewprofile
        else
            playerListing.viewprofile:Hide()
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

    self.list_root = self.panel_root:AddChild(Widget("list_root"))
    self.list_root:SetPosition(90, -27)

    self.player_widgets = {}
    for i,v in ipairs(self.players) do
        table.insert(self.player_widgets, listingConstructor(v, i))
    end

    self.scroll_list = self.list_root:AddChild(ScrollableList(self.player_widgets, 180, 300, 30, 10, nil, nil, nil, nil, nil, 10))
    self.scroll_list:SetPosition(-10,-10)

    if #self.players == 0 then
        self.scroll_list:Hide()
        self.empty_server_text = self.panel_root:AddChild(Text(NEWFONT, 30, STRINGS.UI.PLAYERSTATUSSCREEN.EMPTY_SERVER))     
        self.empty_server_text:SetColour(0,0,0,1)
    end

    self.default_focus = self.scroll_list
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
    return table.concat(t, "  ")
end

return ViewPlayersModalScreen
