local Screen = require "widgets/screen"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/redux/templates"

require("constants")

local font_size = 35
if JapaneseOnPS4() then
    font_size = 35 * 0.75;
end

local item_width = 800
local item_height = 64
local end_spacing = 30

local DEFAULT_ATLAS = "images/avatars.xml"
local DEFAULT_AVATAR = "avatar_unknown.tex"

local function GetAvatar(character, is_mod_character)
    return character ~= "" and ("avatar_"..character..".tex")
        or (is_mod_character and "avatar_mod.tex" or DEFAULT_AVATAR)
end

local function GetAvatarAtlas(character, is_mod_character)
    if is_mod_character and character ~= "" then
        local location = MOD_AVATAR_LOCATIONS["Default"]
        if MOD_AVATAR_LOCATIONS[character] ~= nil then
            location = MOD_AVATAR_LOCATIONS[character]
        end
        
        return location .. "avatar_" .. character .. ".xml"
    end
    return DEFAULT_ATLAS
end

local PlayerDetailsPopup = Class(Screen, function(self, entry, buttons)
	Screen._ctor(self, "PlayerDetailsPopup")

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.root = self:AddChild(TEMPLATES.ScreenRoot("ROOT"))

    self.details_panel = self.root:AddChild(Widget("player_detail_panel"))
    self.details_panel:SetPosition(0,30) -- account for weirdness below
    local spacing = 200
    self.dialog = self.details_panel:AddChild(TEMPLATES.CurlyWindow(530, 240, nil, buttons, spacing))
    self.dialog:SetPosition(0,-30)

    local title_height = 75

    self.details_playername = self.details_panel:AddChild(Text(CHATFONT, 44))
    self.details_playername:SetColour(UICOLOURS.GOLD)

    self.details_playername:SetTruncatedString(
        (entry.netprofilename ~= "" and entry.netprofilename) or
        (entry.userid ~= "" and entry.userid) or
        (entry.netid ~= "" and entry.netid) or
        STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_USER_NAME,
        420,
        64,
        true
    )

    self.details_icon = self.details_panel:AddChild(Widget("target"))
    self.details_icon:SetScale(.8)
    local w = self.details_playername:GetRegionSize()
    self.details_icon:SetPosition(-.5 * w - 3, title_height)

    local character = entry.character or ""
    local is_mod_character = false
    if not table.contains(DST_CHARACTERLIST, character) then
        if table.contains(MODCHARACTERLIST, character) then
            is_mod_character = true
        elseif #character > 0 then
            is_mod_character = true
            character = ""
        end
    end

    self.details_headbg = self.details_icon:AddChild(Image("images/avatars.xml", "avatar_bg.tex"))

    self.details_headicon = self.details_icon:AddChild(Image(GetAvatarAtlas(character, is_mod_character), GetAvatar(character, is_mod_character), DEFAULT_AVATAR))

    self.details_headframe = self.details_icon:AddChild(Image("images/avatars.xml", "avatar_frame_white.tex"))
    self.details_headframe:SetTint(.5,.5,.5,1)
    
    w = self.details_headframe:GetSize() * self.details_icon:GetScale().x
    self.details_playername:SetPosition(.5 * w + 17, title_height, 0)

    self.details_date_label = self.details_panel:AddChild(Text(CHATFONT, 25))
    -- self.details_date_label:SetHAlign(ANCHOR_RIGHT)
    self.details_date_label:SetPosition(0, 10, 0)
    self.details_date_label:SetString(STRINGS.UI.SERVERADMINSCREEN.BANNED..(entry.date or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_DATE))
    self.details_date_label:SetColour(UICOLOURS.GOLD)
    
    self.details_servername_label = self.details_panel:AddChild(Text(CHATFONT, 27))
    self.details_servername_label:SetHAlign(ANCHOR_RIGHT)
    self.details_servername_label:SetPosition(-193, -25, 0)
    self.details_servername_label:SetRegionSize( 200, 40 )
    self.details_servername_label:SetString(STRINGS.UI.SERVERADMINSCREEN.SERVER_NAME)
    self.details_servername_label:SetColour(UICOLOURS.GOLD)
    
    self.details_servername = self.details_panel:AddChild(Text(CHATFONT, 27))
    self.details_servername:SetColour(UICOLOURS.GOLD)
    self.details_servername:SetTruncatedString(
        entry.servername or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN,
        360,
        128,
        true
    )
    w = self.details_servername:GetRegionSize()
    self.details_servername:SetPosition(.5 * w - 83, -25, 0)
    
    self.details_serverdescription_label = self.details_panel:AddChild(Text(CHATFONT, 27))
    self.details_serverdescription_label:SetHAlign(ANCHOR_RIGHT)
    self.details_serverdescription_label:SetPosition(-193, -60, 0)
    self.details_serverdescription_label:SetRegionSize( 200, 40 )
    self.details_serverdescription_label:SetString(STRINGS.UI.SERVERADMINSCREEN.SERVER_DESCRIPTION)
    self.details_serverdescription_label:SetColour(UICOLOURS.GOLD)
        
    self.details_serverdescription = self.details_panel:AddChild(Text(CHATFONT, 27))
    self.details_serverdescription:SetPosition(97, -60, 0)
    self.details_serverdescription:SetColour(UICOLOURS.GOLD)
    self.details_serverdescription:SetTruncatedString(
        entry.serverdescription or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN,
        360,
        128,
        true
    )
    w = self.details_serverdescription:GetRegionSize()
    self.details_serverdescription:SetPosition(.5 * w - 83, -60, 0)
      
	self.buttons = buttons
	self.default_focus = self.dialog
end)

function PlayerDetailsPopup:OnControl(control, down)
    if PlayerDetailsPopup._base.OnControl(self,control, down) then return true end
    
    if control == CONTROL_CANCEL and not down then    
        if self.buttons then
            self.buttons[#self.buttons].cb()
            return true
        end
    end
end

function PlayerDetailsPopup:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	if #self.buttons > 1 and self.buttons[#self.buttons] then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)	
    end
	return table.concat(t, "  ")
end

local BanTab = Class(Screen, function(self, servercreationscreen)
    Widget._ctor(self, "BanTab")

    self.servercreationscreen = servercreationscreen
    
    self.ban_page = self:AddChild(Widget("ban_page"))

    self.blacklist = TheNet:GetBlacklist()

    self:MakeMenuButtons()

    self:MakePlayerPanel()

    self.default_focus = self.player_scroll_list
    self.focus_forward = self.player_scroll_list
end)

function BanTab:MakePlayerPanel()
    self.player_list_rows = self.ban_page:AddChild(Widget("player_list_rows"))
    self.player_list_rows:SetPosition(0, -8, 0) 

    self:MakePlayerList()
end

function BanTab:MakePlayerList()
    local function bannedPlayerRowConstructor(context, index)
        local widget = Widget("option")
        widget:SetOnGainFocus(function() self.player_scroll_list:OnWidgetFocus(widget) end)

        widget.bg = widget:AddChild(TEMPLATES.ListItemBackground(item_width, item_height))

        widget.index = index

        widget.NAME = widget:AddChild(Text(CHATFONT, font_size))
        widget.NAME:SetColour(UICOLOURS.GOLD)
        widget.NAME._align =
        {
            maxwidth = 550,
            maxchars = 44,
        }

        widget.EMPTY = widget:AddChild(Text(CHATFONT, font_size, STRINGS.UI.SERVERADMINSCREEN.EMPTY_SLOT))
        widget.EMPTY:SetHAlign( ANCHOR_LEFT )
        widget.EMPTY:SetColour(UICOLOURS.GOLD)
        widget.EMPTY:Hide()

        local buttons = 
        {
            {widget=TEMPLATES.IconButton("images/button_icons.xml", "view_ban.tex", STRINGS.UI.SERVERADMINSCREEN.PLAYER_DETAILS, false, false, function() self:ShowPlayerDetails(index) end, {size=22/.85})},
            {widget=TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, false, false, function() self:ShowNetProfile(index) end, {size=22/.85})},
            {widget=TEMPLATES.IconButton("images/button_icons.xml", "unban.tex", STRINGS.UI.SERVERADMINSCREEN.PLAYER_DELETE, false, false, function() self:PromptDeletePlayer(index) end, {size=22/.85})},
        }
        for i,v in pairs(buttons) do
            v.widget:SetScale(.85)
        end

        local menu_item_width = 55
        local menu_width = menu_item_width * #buttons
        widget.MENU = widget:AddChild(Menu(buttons, menu_item_width, true))
        widget.MENU:SetPosition(-(menu_item_width*(#buttons-1))/2 + item_width/2 - menu_width/2 - end_spacing, 0) 

        return widget
    end

    local function bannedPlayerRowUpdate(context, widget, data, index)
        if data and not data.empty then 
            widget.index = index
                    
            widget.NAME:SetTruncatedString(
                (data.netprofilename ~= "" and data.netprofilename) or
                (data.userid ~= "" and data.userid) or
                (data.netid ~= "" and data.netid) or
                STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_USER_NAME,
                widget.NAME._align.maxwidth,
                widget.NAME._align.maxchars,
                true
            )
            widget.NAME:SetPosition(-item_width/2 + widget.NAME:GetRegionSize()/2 + end_spacing, 0)
            widget.NAME:Show()
            widget.EMPTY:Hide()
            
            widget.MENU.items[1]:SetOnClick(function() self:ShowPlayerDetails(index) end)
            widget.MENU.items[2]:SetOnClick(function() self:ShowNetProfile(index) end)
            widget.MENU.items[3]:SetOnClick(function() self:PromptDeletePlayer(index) end)

            if "" == data.character and "" == data.servername and "" == data.serverdescription then
                widget.MENU.items[1]:Select()
            else
                widget.MENU.items[1]:Unselect()
            end
            -- no net id means we can't show the profile
            if not TheNet:IsNetIDPlatformValid(data.netid) then
                widget.MENU.items[2]:Select()
            else
                widget.MENU.items[2]:Unselect()
            end

            widget.MENU:Show()
            widget:Enable()
            widget.focus_forward = widget.MENU
        else
            widget.index = index
                       
            widget.NAME:Hide()
            widget.EMPTY:Show()
            
            widget.MENU:Hide()
            widget.focus_forward = widget.bg
        end
    end

    self.ban_page_scroll_root = self.ban_page:AddChild(Widget("scroll_root"))

    self.ban_page_row_root = self.ban_page:AddChild(Widget("row_root"))
    self.ban_page_row_root:SetPosition(80,0)

    local num_visible_rows = math.floor(self.servercreationscreen:GetContentHeight() / item_height)
    self.player_scroll_list = self.ban_page_scroll_root:AddChild(TEMPLATES.ScrollingGrid(
            self.blacklist, 
            {
                scroll_context = {
                },
                widget_width  = item_width,
                widget_height = item_height,
                num_visible_rows = num_visible_rows,
                num_columns = 1,
                item_ctor_fn = bannedPlayerRowConstructor,
                apply_fn = bannedPlayerRowUpdate,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60,
                -- Don't need peek_percent since the list should never grow within this screen.
            }
        ))
    self.player_scroll_list:SetPosition(-110, 0)

    self:RefreshPlayers()
    
    if self.clear_button ~= nil then
        self.ban_page_row_root:SetFocusChangeDir(MOVE_RIGHT, function() return self.clear_button:IsVisible() and self.clear_button:IsEnabled() and self.clear_button or nil end)
        self.clear_button:SetFocusChangeDir(MOVE_LEFT, self.player_scroll_list)
    end
end

function BanTab:RefreshPlayers()
    if self.blacklist then
        while #self.blacklist < self.player_scroll_list.visible_rows do
            table.insert(self.blacklist, {empty=true})
        end
    end
    self.player_scroll_list:SetItemsData(self.blacklist)
    if #self.blacklist == 0 then
        self.clear_button:Disable()
    else
        self.allEmpties = true
        for i,v in pairs(self.blacklist) do
            if v and v.empty == nil or v.empty == false then
                self.allEmpties = false
                break
            end
        end
        if self.allEmpties then
            self.clear_button:Disable()
        else
            self.clear_button:Enable()
        end
    end

    if self.allEmpties then
        self.player_scroll_list:Disable()
    else
        self.player_scroll_list:Enable()
    end
end

function BanTab:ShowPlayerDetails(selected_player)
    if selected_player and self.blacklist[selected_player] then
	    local popup = PlayerDetailsPopup(
	            self.blacklist[selected_player],
			    {{text=STRINGS.UI.SERVERADMINSCREEN.BACK, cb = function() TheFrontEnd:PopScreen() end}}
			)
		TheFrontEnd:PushScreen(popup)
    end
end

function BanTab:ShowNetProfile(selected_player)
    if selected_player and self.blacklist[selected_player] then
        --TheFrontEnd:PushScreen(PlayerAvatarPopupScreen(self.blacklist[selected_player].name, self.blacklist[selected_player]))
        TheNet:ViewNetProfile(self.blacklist[selected_player].netid)
    end
end

function BanTab:PromptDeletePlayer(selected_player)
    if selected_player then
        local entry = self.blacklist[selected_player]
        local name =
            (entry.netprofilename ~= "" and entry.netprofilename) or
            (entry.userid ~= "" and entry.userid) or
            (entry.netid ~= "" and entry.netid) or
            STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_USER_NAME
        local popup = PopupDialogScreen(STRINGS.UI.SERVERADMINSCREEN.DELETE_ENTRY_TITLE, STRINGS.UI.SERVERADMINSCREEN.DELETE_ENTRY_BODY..name..STRINGS.UI.SERVERADMINSCREEN.DELETE_ENTRY_BODY_2,
		    {{text=STRINGS.UI.SERVERADMINSCREEN.YES, cb = function()
                self:DeletePlayer(selected_player)
                TheFrontEnd:PopScreen()
		    end},
		    {text=STRINGS.UI.SERVERADMINSCREEN.NO, cb = function()
                TheFrontEnd:PopScreen()
            end}})
	    TheFrontEnd:PushScreen(popup)
    end
end

function BanTab:DeletePlayer(selected_player)
    if selected_player then
        table.remove(self.blacklist, selected_player)

        local list = {}
        for i,v in pairs(self.blacklist) do
            if v and not v.empty then
                table.insert(list, v)
            end
        end
        TheNet:SetBlacklist(list)

        self:RefreshPlayers()
    end
end

function BanTab:ClearPlayers()
    local popup = PopupDialogScreen(STRINGS.UI.SERVERADMINSCREEN.CLEAR_LIST_TITLE, STRINGS.UI.SERVERADMINSCREEN.CLEAR_LIST_BODY, 
		{{text=STRINGS.UI.SERVERADMINSCREEN.YES, cb = function()
            self.blacklist = {}
            TheNet:SetBlacklist(self.blacklist)
            self:RefreshPlayers()
		    TheFrontEnd:PopScreen()
		end},
		{text=STRINGS.UI.SERVERADMINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  })
	TheFrontEnd:PushScreen(popup)
end

function BanTab:MakeMenuButtons()
    local bottom_button_y = -310
    self.clear_button = self.ban_page:AddChild(TEMPLATES.StandardButton(
            function() self:ClearPlayers() end,
            STRINGS.UI.SERVERADMINSCREEN.CLEAR_PLAYERS,
            nil,
            {"images/button_icons.xml", "unbanall.tex"}
        ))
    -- Would be better if we could align to same x as Create Server.
    self.clear_button:SetPosition(215, bottom_button_y)
    self.clear_button:SetScale(0.7)

    if #self.blacklist == 0 then
        self.clear_button:Disable()
    else
        self.allEmpties = true
        for i,v in pairs(self.blacklist) do
            if v and v.empty == nil or v.empty == false then
                self.allEmpties = false
                break
            end
        end
        if self.allEmpties then
            self.clear_button:Disable()
        else
            self.clear_button:Enable()
        end
    end

    if TheInput:ControllerAttached() then
        self.clear_button:Hide()
    end

    local tocreate = self.servercreationscreen ~= nil and self.servercreationscreen.getfocuscreate or nil
    self.clear_button:SetFocusChangeDir(MOVE_DOWN, tocreate)
end

function BanTab:OnControl(control, down)
    if BanTab._base.OnControl(self, control, down) then return true end
    
    if not down then 
        if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then 
            if control == CONTROL_INSPECT then 
                self:ClearPlayers()
                return true
            end
        end
    end

end

function BanTab:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if not self.allEmpties then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.SERVERADMINSCREEN.CLEAR_PLAYERS)
    end

    return table.concat(t, "  ")
end

return BanTab
