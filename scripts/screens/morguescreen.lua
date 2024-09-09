local Screen = require "widgets/screen"
local ImageButton = require "widgets/imagebutton"

local Text = require "widgets/text"
local Image = require "widgets/image"

local Widget = require "widgets/widget"

local OnlineStatus = require "widgets/onlinestatus"
local ScrollableList = require "widgets/scrollablelist"
local TEMPLATES = require "widgets/templates"

require("constants")

-- Note: values are the position of the line at the right side of the named column
local column_offsets
if JapaneseOnPS4() then --NB: JP PS4 values have NOT been updated for the new screen (6/14/2015)
     column_offsets ={
        DAYS_LIVED = -35,
        DECEASED = 100,
        CAUSE = 290,
        MODE = 500,
        PLAYER_NAME = 50,
        PLAYER_CHAR = 160,
        SERVER_NAME = 285,
        SUBMENU = 530,
    }
else
    column_offsets ={
        DAYS_LIVED = -200,
        DECEASED = -50,
        CAUSE = 150,
        MODE = 530,
        PLAYER_NAME = -160,
        PLAYER_CHAR = -90,
        SERVER_NAME = 220,
        SEEN_DATE = 340,
        PLAYER_AGE = 450,
        SUBMENU = 530,
    }
end

local header_height = 210
local row_height = 30
local num_rows = 14

local portrait_scale = 0.25

local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

local function get_killed_by(data)
    if data.killed_by == nil then
        return ""
    elseif data.pk then
        --If it's a PK, then don't do any remapping or reformatting on the player's name
        return data.killed_by
    end

    local killed_by =
        (data.killed_by == "nil" and ((data.character == "waxwell" or data.character == "winona") and "charlie" or "darkness")) or
        (data.killed_by == "unknown" and "shenanigans") or
        (data.killed_by == "moose" and (math.random() < .5 and "moose1" or "moose2")) or
        data.killed_by

    killed_by = STRINGS.NAMES[string.upper(killed_by)] or STRINGS.NAMES.SHENANIGANS

    return killed_by:gsub("(%a)([%w_']*)", tchelper)
end

local function get_character_icon(character)
    local atlas = "images/saveslot_portraits"
    if not table.contains(DST_CHARACTERLIST, character) then
        if table.contains(MODCHARACTERLIST, character) then
            atlas = atlas.."/"..character
        else
            character = #character > 0 and "mod" or "unknown"
        end
    end
    return atlas..".xml", character..".tex"
end

local function obit_widget_constructor(data, parent, obit_button)
    if not data and data.character and data.days_survived and data.location and data.killed_by and (data.world or data.server) then return end

     -- obits scroll list
    local font_size = JapaneseOnPS4() and 28 * .75 or 28

    local group = parent:AddChild(Widget("control-morgue"))
    group.bg = group:AddChild(Image("images/serverbrowser.xml", "textwidget_over.tex"))
    group.bg:SetPosition(355,0)
    group.bg:SetSize(880,37)
    group.bg:Hide()
    group.OnGainFocus = function()
        group.bg:Show()
    end
    group.OnLoseFocus = function()
        group.bg:Hide()
    end

    local slide_factor = 185

    group.DAYS_LIVED = group:AddChild(Text(NEWFONT, font_size))
    group.DAYS_LIVED:SetHAlign(ANCHOR_MIDDLE)
    group.DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED+slide_factor, 0, 0)
    group.DAYS_LIVED._align =
    {
        maxwidth = 120,
        maxchars = 30,
    }
    group.DAYS_LIVED:SetTruncatedString((data.days_survived or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS).." "..(data.days_survived == 1 and STRINGS.UI.MORGUESCREEN.DAY or STRINGS.UI.MORGUESCREEN.DAYS), group.DAYS_LIVED._align.maxwidth, group.DAYS_LIVED._align.maxchars, true)
    group.DAYS_LIVED:SetColour(0,0,0,1)

    group.DECEASED = group:AddChild(Widget("DECEASED"))
    group.DECEASED:SetPosition(column_offsets.DECEASED+slide_factor-10, 0, 0)

    group.DECEASED.portraitbg = group.DECEASED:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    group.DECEASED.portraitbg:SetScale(portrait_scale, portrait_scale, 1)
    group.DECEASED.portraitbg:SetClickable(false)
    group.DECEASED.base = group.DECEASED:AddChild(Widget("base"))

    group.DECEASED.portrait = group.DECEASED.base:AddChild(Image())
    group.DECEASED.portrait:SetClickable(false)
    group.DECEASED.portrait:SetScale(portrait_scale, portrait_scale, 1)
    if data.character ~= nil then
        group.DECEASED.portrait:SetTexture(get_character_icon(data.character))
    else
        group.DECEASED:Hide()
    end

    group.CAUSE = group:AddChild(Text(NEWFONT, font_size))
    group.CAUSE:SetHAlign(ANCHOR_MIDDLE)
    group.CAUSE:SetPosition(column_offsets.CAUSE + slide_factor - 35, 0, 0)
    group.CAUSE._align =
    {
        maxwidth = 190,
        maxchars = 45,
    }
    group.CAUSE:SetTruncatedString(get_killed_by(data), group.CAUSE._align.maxwidth, group.CAUSE._align.maxchars, true)
    group.CAUSE:SetColour(0,0,0,1)

    group.MODE = group:AddChild(Text(NEWFONT, font_size))
    group.MODE:SetHAlign(ANCHOR_MIDDLE)
    group.MODE:SetPosition(column_offsets.MODE + slide_factor - 125, 0, 0)
    group.MODE:SetColour(0,0,0,1)
    group.MODE._align =
    {
        maxwidth = 370,
        maxchars = 85,
    }
    group.MODE:SetTruncatedString(data.server or "", group.MODE._align.maxwidth, group.MODE._align.maxchars, true)

    group:SetFocusChangeDir(MOVE_LEFT, obit_button)

    return group
end

local function obit_widget_update(widget, data, index)
    if widget == nil then
        return
    end

    widget.DAYS_LIVED:SetTruncatedString((data.days_survived or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS).." "..(data.days_survived == 1 and STRINGS.UI.MORGUESCREEN.DAY or STRINGS.UI.MORGUESCREEN.DAYS), widget.DAYS_LIVED._align.maxwidth, widget.DAYS_LIVED._align.maxchars, true)

    if data.character ~= nil then
        widget.DECEASED.portrait:SetTexture(get_character_icon(data.character))
        widget.DECEASED:Show()
    else
        widget.DECEASED:Hide()
    end

    widget.CAUSE:SetTruncatedString(get_killed_by(data), widget.CAUSE._align.maxwidth, widget.CAUSE._align.maxchars, true)
    widget.MODE:SetTruncatedString(data.server or "", widget.MODE._align.maxwidth, widget.MODE._align.maxchars, true)
end

local function encounter_widget_update(widget, data, index)
    if not widget then return end

    widget.PLAYER_NAME:SetTruncatedString(data.name or "", widget.PLAYER_NAME._align.maxwidth, widget.PLAYER_NAME._align.maxchars, true)
    widget.SERVER_NAME:SetTruncatedString(data.server_name or "", widget.SERVER_NAME._align.maxwidth, widget.SERVER_NAME._align.maxchars, true)

    if data.prefab ~= nil then
        widget.PLAYER_CHAR.portrait:SetTexture(get_character_icon(data.prefab))
        widget.PLAYER_CHAR:Show()
    else
        widget.PLAYER_CHAR:Hide()
    end

    widget.SEEN_DATE:SetTruncatedString(data.date or "", widget.SEEN_DATE._align.maxwidth, widget.SEEN_DATE._align.maxchars, true)

    local age_str = (data.playerage or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS).." "..(tonumber(data.playerage) == 1 and STRINGS.UI.MORGUESCREEN.DAY or STRINGS.UI.MORGUESCREEN.DAYS)
    widget.PLAYER_AGE:SetTruncatedString(age_str, widget.PLAYER_AGE._align.maxwidth, widget.PLAYER_AGE._align.maxchars, true)

    widget.NET_ID._netid = data.netid
    if TheNet:IsNetIDPlatformValid(data.netid) then
        widget.NET_ID:Unselect()
    else
        widget.NET_ID:Select()
    end
    widget.CLEAR._userid = data.userid
end

local MorgueScreen = Class(Screen, function(self, prev_screen)
    Widget._ctor(self, "MorgueScreen")

    self.prev_screen = prev_screen
    prev_screen:TransferPortalOwnership(prev_screen, self)

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.menu_bg = self.root:AddChild(TEMPLATES.LeftGradient())

    self.onlinestatus = self.root:AddChild(OnlineStatus())
    self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:OK() end))

    self.center_panel = self.root:AddChild(TEMPLATES.CenterPanel())
    -- self.center_panel:SetPosition(75, 0)

    self.nav_bar = self.root:AddChild(TEMPLATES.NavBarWithScreenTitle(STRINGS.UI.MORGUESCREEN.HISTORY, "short"))
    self.obituary_button = self.nav_bar:AddChild(TEMPLATES.NavBarButton(25, STRINGS.UI.MORGUESCREEN.TITLE, function() self:SetTab("obituary") end))
    self.encounters_button = self.nav_bar:AddChild(TEMPLATES.NavBarButton(-25, STRINGS.UI.MORGUESCREEN.ENCOUNTERSTITLE, function() self:SetTab("encounters") end))

    self.list_widgets = {}
    self.morgue = Morgue:GetRows()

    PlayerHistory:SortBackwards("sort_date")
    self.player_history = PlayerHistory:GetRows()

    self:BuildObituariesTab()
    self:BuildEncountersTab()

    self:RefreshControls()

    self:SetTab("obituary")
    self.default_focus = self.obituary_button
end)

function MorgueScreen:EncounterWidgetConstructor(data, parent, obit_button)
    local font_size = JapaneseOnPS4() and 28 * .75 or 28

    local slide_factor = 200

    local group = parent:AddChild(Widget("control-encounter"))

    group.bg = group:AddChild(Image("images/serverbrowser.xml", "textwidget_over.tex"))
    group.bg:SetPosition(355,0)
    group.bg:SetSize(880,37)
    group.bg:Hide()
    group.OnGainFocus = function()
        group.bg:Show()
    end
    group.OnLoseFocus = function()
        group.bg:Hide()
    end

    group.PLAYER_NAME = group:AddChild(Text(NEWFONT, font_size))
    group.PLAYER_NAME:SetHAlign(ANCHOR_MIDDLE)
    group.PLAYER_NAME:SetPosition(column_offsets.PLAYER_NAME-35+slide_factor, 0, 0)
    group.PLAYER_NAME:SetColour(0,0,0,1)
    group.PLAYER_NAME._align =
    {
        maxwidth = 160,
        maxchars = 40,
    }
    group.PLAYER_NAME:SetTruncatedString(data.name or "", group.PLAYER_NAME._align.maxwidth, group.PLAYER_NAME._align.maxchars, true)

    group.PLAYER_CHAR = group:AddChild(Widget("PLAYER_CHAR"))
    group.PLAYER_CHAR:SetPosition(column_offsets.PLAYER_CHAR + 15 + slide_factor, 0, 0)

    group.SERVER_NAME = group:AddChild(Text(NEWFONT, font_size))
    group.SERVER_NAME:SetHAlign(ANCHOR_MIDDLE)
    group.SERVER_NAME:SetPosition(column_offsets.SERVER_NAME - 105 + slide_factor, 0, 0)
    group.SERVER_NAME:SetColour(0,0,0,1)
    group.SERVER_NAME._align =
    {
        maxwidth = 300,
        maxchars = 70,
    }
    group.SERVER_NAME:SetTruncatedString(data.server_name or "", group.SERVER_NAME._align.maxwidth, group.SERVER_NAME._align.maxchars, true)

    group.PLAYER_CHAR.base = group.PLAYER_CHAR:AddChild(Widget("base"))
    group.PLAYER_CHAR.base:SetPosition(1,0)
    group.PLAYER_CHAR.portraitbg = group.PLAYER_CHAR.base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    group.PLAYER_CHAR.portraitbg:SetScale(portrait_scale, portrait_scale, 1)
    group.PLAYER_CHAR.portraitbg:SetClickable(false)
    group.PLAYER_CHAR.portrait = group.PLAYER_CHAR.base:AddChild(Image())
    group.PLAYER_CHAR.portrait:SetClickable(false)
    group.PLAYER_CHAR.portrait:SetScale(portrait_scale, portrait_scale, 1)
    if data.prefab ~= nil then
        group.PLAYER_CHAR.portrait:SetTexture(get_character_icon(data.prefab))
    else
        group.PLAYER_CHAR:Hide()
    end

    group.SEEN_DATE = group:AddChild(Text(NEWFONT, font_size))
    group.SEEN_DATE:SetHAlign(ANCHOR_MIDDLE)
    group.SEEN_DATE:SetPosition(column_offsets.SEEN_DATE - 10 + slide_factor, 0, 0)
    group.SEEN_DATE._align =
    {
        maxwidth = 110,
        maxchars = 28,
    }
    group.SEEN_DATE:SetTruncatedString(data.date or "", group.SEEN_DATE._align.maxwidth, group.SEEN_DATE._align.maxchars, true)
    group.SEEN_DATE:SetColour(0,0,0,1)

    group.PLAYER_AGE = group:AddChild(Text(NEWFONT, font_size))
    group.PLAYER_AGE:SetHAlign(ANCHOR_MIDDLE)
    group.PLAYER_AGE:SetPosition(column_offsets.PLAYER_AGE - 25 + slide_factor+20, 0, 0)
    group.PLAYER_AGE._align =
    {
        maxwidth = 100,
        maxchars = 25,
    }
    local age_str = (data.playerage or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS).." "..(tonumber(data.playerage) == 1 and STRINGS.UI.MORGUESCREEN.DAY or STRINGS.UI.MORGUESCREEN.DAYS)
    group.PLAYER_AGE:SetTruncatedString(age_str, group.PLAYER_AGE._align.maxwidth, group.PLAYER_AGE._align.maxchars, true)
    group.PLAYER_AGE:SetColour(0,0,0,1)

    group.NET_ID = group:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, false, false,
        function()
            if group.NET_ID._netid ~= nil then
                TheNet:ViewNetProfile(group.NET_ID._netid)
            end
        end,
        { offset_y = 65 }))
    group.NET_ID:SetPosition(column_offsets.SUBMENU + 12 - 15 + slide_factor, -1, 0)
    group.NET_ID:SetScale(.45)
    group.NET_ID:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE)
    group.NET_ID._netid = data.netid
    if not TheNet:IsNetIDPlatformValid(data.netid) then
        group.NET_ID:Select()
    end

    group.CLEAR = group:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "delete.tex", STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR, false, false,
        function()
            PlayerHistory:RemoveUser(group.CLEAR._userid)
            self:UpdatePlayerHistory()
        end,
        { offset_y = 65 }))
    group.CLEAR:SetPosition(column_offsets.SUBMENU + 12 + 15 + slide_factor, -1, 0)
    group.CLEAR:SetScale(.45)
    group.CLEAR:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR)
    group.CLEAR._userid = data.userid

	--MAINTAIN COLUMN FOCUS IN THE SCROLLLLLIST
	self.column_focus = 1
	local screen = self
	local old_netid_focus = group.NET_ID.OnGainFocus
	group.NET_ID.OnGainFocus = function(self)
		old_netid_focus(self)
		screen.column_focus = 1
	end

	local old_clear_focus = group.CLEAR.OnGainFocus
	group.CLEAR.OnGainFocus = function(self)
		old_clear_focus(self)
		screen.column_focus = 2
	end

	local old_set_focus = group.SetFocus
	group.SetFocus = function(self)
		old_set_focus(self)
        if screen.column_focus == 1 then
			group.NET_ID:SetFocus()
		else
			group.CLEAR:SetFocus()
		end
    end

    group.NET_ID:SetFocusChangeDir(MOVE_LEFT, obit_button)
    group.NET_ID:SetFocusChangeDir(MOVE_RIGHT, group.CLEAR)

    group.CLEAR:SetFocusChangeDir(MOVE_LEFT, group.NET_ID)

    return group
end

function MorgueScreen:AddWhiteStripes(parent)
    local y_height = header_height-.5*row_height

    for i = 1, num_rows+1 do
        if i % 2 ~= 0 then
            local line = parent:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
            line:SetPosition(105, y_height)
            line:SetScale(1.66, .68)
            line:MoveToBack()
        end

        y_height = y_height - row_height
    end
end

function MorgueScreen:BuildObituariesTab()
    self.obituaryroot = self.center_panel:AddChild(Widget("ROOT"))

    self.obituaryroot:SetPosition(-110,0,0)

    self.obituary_title = self.obituaryroot:AddChild(Text(BUTTONFONT, 45, STRINGS.UI.MORGUESCREEN.TITLE))
    self.obituary_title:SetPosition(115,245)
    self.obituary_title:SetColour(0,0,0,1)

    self.obituary_lines = self.obituaryroot:AddChild(Widget("lines"))
    local vertical_line_y_offset = -20

    self.upper_horizontal_line = self.obituary_lines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.upper_horizontal_line:SetScale(.7, .66)
    self.upper_horizontal_line:SetPosition(100, header_height, 0)

    self.lower_horizontal_line = self.obituary_lines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.lower_horizontal_line:SetScale(.7, .66)
    self.lower_horizontal_line:SetPosition(100, header_height-row_height, 0)

    self.first_column_end = self.obituary_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.first_column_end:SetScale(.66, .68)
    self.first_column_end:SetPosition(column_offsets.DAYS_LIVED,vertical_line_y_offset, 0)

    self.second_column_end = self.obituary_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.second_column_end:SetScale(.66, .68)
    self.second_column_end:SetPosition(column_offsets.DECEASED, vertical_line_y_offset, 0)

    self.third_column_end = self.obituary_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.third_column_end:SetScale(.66, .68)
    self.third_column_end:SetPosition(column_offsets.CAUSE, vertical_line_y_offset, 0)

    local font_size = 30
    if JapaneseOnPS4() then
        font_size = 30 * 0.75
    end

    self.obits_titles = self.obituaryroot:AddChild(Widget("obits_titles"))
    self.obits_titles:SetPosition(0, header_height-.5*row_height, 0)

    if JapaneseOnPS4() then
        self.DAYS_LIVED = self.obits_titles:AddChild(Text(NEWFONT, font_size * 0.8))
    else
        self.DAYS_LIVED = self.obits_titles:AddChild(Text(NEWFONT, font_size))
    end
    self.DAYS_LIVED:SetHAlign(ANCHOR_MIDDLE)
    self.DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED - 65, 0, 0)
    self.DAYS_LIVED:SetRegionSize(120, 30)
    self.DAYS_LIVED:SetString(STRINGS.UI.MORGUESCREEN.PLAYER_AGE)
    self.DAYS_LIVED:SetColour(0, 0, 0, 1)
    self.DAYS_LIVED:SetClickable(false)

    self.DECEASED = self.obits_titles:AddChild(Text(NEWFONT, font_size))
    self.DECEASED:SetHAlign(ANCHOR_MIDDLE)
    self.DECEASED:SetPosition(column_offsets.DECEASED - 75, 0, 0)
    self.DECEASED:SetRegionSize(140, 30)
    self.DECEASED:SetString(STRINGS.UI.MORGUESCREEN.DECEASED)
    self.DECEASED:SetColour(0, 0, 0, 1)
    self.DECEASED:SetClickable(false)

    self.CAUSE = self.obits_titles:AddChild(Text(NEWFONT, font_size))
    self.CAUSE:SetHAlign(ANCHOR_MIDDLE)
    self.CAUSE:SetPosition(column_offsets.CAUSE - 100, 0, 0)
    self.CAUSE:SetRegionSize(190, 30)
    self.CAUSE:SetString(STRINGS.UI.MORGUESCREEN.CAUSE)
    self.CAUSE:SetColour(0, 0, 0, 1)
    self.CAUSE:SetClickable(false)

    self.MODE = self.obits_titles:AddChild(Text(NEWFONT, font_size))
    self.MODE:SetHAlign(ANCHOR_MIDDLE)
    self.MODE:SetPosition(column_offsets.MODE - 190, 0, 0)
    self.MODE:SetRegionSize(370, 30)
    self.MODE:SetString(STRINGS.UI.MORGUESCREEN.MODE)
    self.MODE:SetColour(0, 0, 0, 1)
    self.MODE:SetClickable(false)

    self.obits_rows = self.obituaryroot:AddChild(Widget("obits_rows"))
    self:AddWhiteStripes(self.obits_rows)
    self.obits_rows:MoveToBack()

    self.obitslistroot = self.obituaryroot:AddChild(Widget("obitsroot"))
    self.obitslistroot:SetPosition(200,0)

    self.obitsrowsroot = self.obituaryroot:AddChild(Widget("obitsroot"))
    self.obitsrowsroot:SetPosition(200,0)

    self.obit_widgets = {}
    for i=1,num_rows do
        table.insert(self.obit_widgets, obit_widget_constructor(self.morgue[i] or {}, self.obitsrowsroot, self.obituary_button))
    end

    self.obits_scroll_list = self.obitslistroot:AddChild(ScrollableList(self.morgue, 900, 420, row_height, 0, obit_widget_update, self.obit_widgets, nil, nil, nil, 30))
    self.obits_scroll_list:LayOutStaticWidgets(-25)
    self.obits_scroll_list:SetPosition(-95, -35)
end

function MorgueScreen:BuildEncountersTab()
    self.encountersroot = self.center_panel:AddChild(Widget("ROOT"))

    self.encountersroot:SetPosition(-110,0,0)

    self.encounters_title = self.encountersroot:AddChild(Text(BUTTONFONT, 45, STRINGS.UI.MORGUESCREEN.LONGENCOUNTERSTITLE))
    self.encounters_title:SetPosition(115,245)
    self.encounters_title:SetColour(0,0,0,1)

    self.encounters_lines = self.encountersroot:AddChild(Widget("lines"))
    local vertical_line_y_offset = -20

    self.upper_horizontal_line = self.encounters_lines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.upper_horizontal_line:SetScale(.7, .66)
    self.upper_horizontal_line:SetPosition(100, header_height, 0)

    self.lower_horizontal_line = self.encounters_lines:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
    self.lower_horizontal_line:SetScale(.7, .66)
    self.lower_horizontal_line:SetPosition(100, header_height-row_height, 0)

    self.first_column_end = self.encounters_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.first_column_end:SetScale(.66, .68)
    self.first_column_end:SetPosition(column_offsets.PLAYER_NAME,vertical_line_y_offset, 0)

    self.second_column_end = self.encounters_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.second_column_end:SetScale(.66, .68)
    self.second_column_end:SetPosition(column_offsets.PLAYER_CHAR, vertical_line_y_offset, 0)

    self.third_column_end = self.encounters_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.third_column_end:SetScale(.66, .68)
    self.third_column_end:SetPosition(column_offsets.SERVER_NAME, vertical_line_y_offset, 0)

    if not JapaneseOnPS4() then
        self.fourth_column_end = self.encounters_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
        self.fourth_column_end:SetScale(.66, .68)
        self.fourth_column_end:SetPosition(column_offsets.SEEN_DATE, vertical_line_y_offset, 0)

        self.fifth_column_end = self.encounters_lines:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
        self.fifth_column_end:SetScale(.66, .68)
        self.fifth_column_end:SetPosition(column_offsets.PLAYER_AGE, vertical_line_y_offset, 0)
    end

    self.encounters_rows = self.encountersroot:AddChild(Widget("encounters_rows"))
    self:AddWhiteStripes(self.encounters_rows)
    self.encounters_rows:MoveToBack()

    local font_size = 30
    if JapaneseOnPS4() then
        font_size = 30 * 0.75;
    end
    self.encounters_titles = self.encountersroot:AddChild(Widget("encounters_titles"))
    self.encounters_titles:SetPosition(-75, -.5*row_height, 0)

    if JapaneseOnPS4() then
        self.PLAYER_NAME = self.encounters_titles:AddChild(Text(NEWFONT, font_size * 0.8))
    else
        self.PLAYER_NAME = self.encounters_titles:AddChild(Text(NEWFONT, font_size))
    end
    self.PLAYER_NAME:SetHAlign(ANCHOR_MIDDLE)
    self.PLAYER_NAME:SetPosition(column_offsets.PLAYER_NAME - 10, header_height, 0)
    self.PLAYER_NAME:SetRegionSize(160, 30)
    self.PLAYER_NAME:SetString(STRINGS.UI.MORGUESCREEN.PLAYER_NAME)
    self.PLAYER_NAME:SetColour(0, 0, 0, 1)
    self.PLAYER_NAME:SetClickable(false)

    self.PLAYER_CHAR = self.encounters_titles:AddChild(Text(NEWFONT, font_size))
    self.PLAYER_CHAR:SetHAlign(ANCHOR_MIDDLE)
    self.PLAYER_CHAR:SetPosition(column_offsets.PLAYER_CHAR + 40, header_height, 0)
    self.PLAYER_CHAR:SetRegionSize(60, 30)
    self.PLAYER_CHAR:SetString(STRINGS.UI.MORGUESCREEN.PLAYER_CHAR)
    self.PLAYER_CHAR:SetColour(0, 0, 0, 1)
    self.PLAYER_CHAR:SetClickable(false)

    self.SERVER_NAME = self.encounters_titles:AddChild(Text(NEWFONT, font_size))
    self.SERVER_NAME:SetHAlign(ANCHOR_MIDDLE)
    self.SERVER_NAME:SetPosition(column_offsets.SERVER_NAME - 80, header_height, 0)
    self.SERVER_NAME:SetRegionSize(300, 30)
    self.SERVER_NAME:SetString(STRINGS.UI.MORGUESCREEN.SERVER_NAME)
    self.SERVER_NAME:SetColour(0, 0, 0, 1)
    self.SERVER_NAME:SetClickable(false)

    if not JapaneseOnPS4() then
        self.SEEN_DATE = self.encounters_titles:AddChild(Text(NEWFONT, font_size))
        self.SEEN_DATE:SetHAlign(ANCHOR_MIDDLE)
        self.SEEN_DATE:SetPosition(column_offsets.SEEN_DATE + 15, header_height, 0)
        self.SEEN_DATE:SetRegionSize(110, 30)
        self.SEEN_DATE:SetString(STRINGS.UI.MORGUESCREEN.SEEN_DATE)
        self.SEEN_DATE:SetColour(0, 0, 0, 1)
        self.SEEN_DATE:SetClickable(false)

        self.PLAYER_AGE = self.encounters_titles:AddChild(Text(NEWFONT, font_size))
        self.PLAYER_AGE:SetHAlign(ANCHOR_MIDDLE)
        self.PLAYER_AGE:SetPosition(column_offsets.PLAYER_AGE + 20, header_height, 0)
        self.PLAYER_AGE:SetRegionSize(100, 30)
        self.PLAYER_AGE:SetString(STRINGS.UI.MORGUESCREEN.PLAYER_AGE)
        self.PLAYER_AGE:SetColour(0, 0, 0, 1)
        self.PLAYER_AGE:SetClickable(false)

        self.SUBMENU = self.encounters_titles:AddChild(Text(NEWFONT, font_size))
        self.SUBMENU:SetHAlign(ANCHOR_MIDDLE)
        self.SUBMENU:SetPosition(column_offsets.SUBMENU + 35, header_height, 0)
        self.SUBMENU:SetRegionSize(70, 30)
        self.SUBMENU:SetString(" ")
        self.SUBMENU:SetColour(0, 0, 0, 1)
        self.SUBMENU:SetClickable(false)
    end

    self.encounterslistroot = self.encountersroot:AddChild(Widget("encounterslistroot"))
    self.encounterslistroot:SetPosition(200,0)

    self.encountersrowsroot = self.encountersroot:AddChild(Widget("encountersrowsroot"))
    self.encountersrowsroot:SetPosition(200,0)

    self.encounter_widgets = {}
    for i = 1, num_rows do
        table.insert(self.encounter_widgets, self:EncounterWidgetConstructor(self.player_history[i] or {}, self.encountersrowsroot, self.obituary_button))
    end

    self.encounters_scroll_list = self.encounterslistroot:AddChild(ScrollableList(self.player_history, 900, row_height * num_rows, row_height - 1, 1, encounter_widget_update, self.encounter_widgets, nil, nil, nil, 30))
    self.encounters_scroll_list:LayOutStaticWidgets(-25)
    self.encounters_scroll_list:SetPosition(-95, -35)
end

function MorgueScreen:UpdatePlayerHistory()
    self.player_history = PlayerHistory:GetRows()
    self.encounters_scroll_list:SetList( self.player_history )
end

function MorgueScreen:SetTab(tab)
    if tab == "obituary" then
        self.selected_tab = "obituary"
        if self.obituary_button.shown then self.obituary_button:Select() end
        if self.encounters_button.shown then self.encounters_button:Unselect() end
        self.obituaryroot:Show()
        self.encountersroot:Hide()
    elseif tab == "encounters" then
        self.selected_tab = "encounters"
        if self.obituary_button.shown then self.obituary_button:Unselect() end
        if self.encounters_button.shown then self.encounters_button:Select() end
        self.obituaryroot:Hide()
        self.encountersroot:Show()
    end
    --self:UpdateMenu()
end

--[[
function MorgueScreen:OnBecomeActive()
    MorgueScreen._base.OnBecomeActive(self)
    TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:GetSound():KillSound("FEPortalSFX")
end

function MorgueScreen:OnBecomeInactive()
    MorgueScreen._base.OnBecomeInactive(self)
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
end
]]

function MorgueScreen:OnDestroy()
    self.prev_screen:TransferPortalOwnership(self, self.prev_screen)
    self._base.OnDestroy(self)
end

function MorgueScreen:RefreshControls()
    self:RefreshNav()
end

function MorgueScreen:RefreshNav()

    local function torightcol()
        if self.selected_tab == "obituary" then
            return self.obits_scroll_list
        else
            return self.encounters_scroll_list
        end
    end

    self.obits_scroll_list:SetFocusChangeDir(MOVE_LEFT, self.obituary_button)
    self.encounters_scroll_list:SetFocusChangeDir(MOVE_LEFT, self.obituary_button)

    self.cancel_button:SetFocusChangeDir(MOVE_UP, self.obituary_button)

    self.cancel_button:SetFocusChangeDir(MOVE_RIGHT, torightcol)
    self.obituary_button:SetFocusChangeDir(MOVE_RIGHT, torightcol)
    self.encounters_button:SetFocusChangeDir(MOVE_RIGHT, torightcol)

    self.obituary_button:SetFocusChangeDir(MOVE_DOWN, self.encounters_button)
    self.encounters_button:SetFocusChangeDir(MOVE_UP, self.obituary_button)
    self.encounters_button:SetFocusChangeDir(MOVE_DOWN, self.cancel_button)

    if TheInput:ControllerAttached() then
        self.cancel_button:Hide()
    else
        self.cancel_button:Show()
    end
end


function MorgueScreen:OnControl(control, down)
    if MorgueScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_CANCEL then
            self:OK()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
    end
end

function MorgueScreen:OK()
    self:Disable()
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        TheFrontEnd:PopScreen()
        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
    end)
end

function MorgueScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return MorgueScreen
