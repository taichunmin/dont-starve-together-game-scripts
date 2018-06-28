local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local OnlineStatus = require "widgets/onlinestatus"
local Subscreener = require "screens/redux/subscreener"
local TEMPLATES = require "widgets/redux/templates"

require("characterutil")
require("constants")

-- Note: values are the position of the line at the right side of the named column
local column_offsets
if JapaneseOnPS4() then --NB: JP PS4 values have NOT been updated for the new screen (2017-12-08)
     column_offsets ={
        DECEASED = -170,
        DAYS_LIVED = -40,
        CAUSE = 190,
        MODE = 610,
        PLAYER_CHAR = -170,
        PLAYER_NAME = 60,
        SERVER_NAME = 430,
        SUBMENU = 580,
    }
else
    column_offsets ={
        DECEASED = -170,
        DAYS_LIVED = -40,
        CAUSE = 190,
        MODE = 610,
        PLAYER_CHAR = -170,
        PLAYER_NAME = 60,
        SERVER_NAME = 430,
        PLAYER_AGE = 550,
        SUBMENU = 580,
    }
end

local font_face = CHATFONT
local font_size = 28
if JapaneseOnPS4() then
    font_size = 28 * 0.75;
end
local title_font_size = font_size*.8
local title_font_face = HEADERFONT

local units_per_row = 2
local header_height = 330
local num_rows = math.ceil(19 / units_per_row)
local text_content_y = -12 * (units_per_row - 1)
local text_align = ANCHOR_LEFT
if units_per_row == 1 then
    text_align = ANCHOR_MIDDLE
end
local dialog_size_x = 830
local dialog_width = dialog_size_x + (60*2) -- nineslice sides are 60px each
local row_height = 30 * units_per_row
local row_width = dialog_width*0.9
local dialog_size_y = row_height*(num_rows + 0.25)

local column_widths = {
    DAYS_LIVED = 120,
    DECEASED = row_height,
    CAUSE = 230,
    MODE = 410,

    PLAYER_NAME = 220,
    PLAYER_CHAR = row_height,
    SERVER_NAME = 360,
    PLAYER_AGE = 100,
    SUBMENU = row_height*2,
}


local function CreateListItemBackground()
    return TEMPLATES.ListItemBackground(row_width,row_height)
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

local function BuildCharacterPortrait(name)
    local portrait_scale = 0.25 * units_per_row
    local base = Widget(name)
    base:SetScale(portrait_scale, portrait_scale, 1)

    base.portraitbg = base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    base.portraitbg:SetClickable(false)
    base.portrait = base:AddChild(Image())
    base.portrait:SetClickable(false)

    base.SetCharacter = function(self, character)
        if character ~= nil then
            self.portrait:SetTexture(get_character_icon(character))
            self:Show()
        else
            self:Hide()
        end
    end

    return base
end

local function LeftAlignText(text_widget, name)
    if text_align ~= ANCHOR_LEFT then
        return
    end
    local w,h = text_widget:GetRegionSize()
    -- alignment isn't precise so add more offset to look less weird
    local more_misalign = 7
    text_widget:SetPosition(more_misalign + column_offsets[name] - column_widths[name] + w/2, text_content_y)
end

local function BuildObituariesTitles()
    local font_face = title_font_face

    local obits_titles = Widget("obits_titles")

    local DAYS_LIVED = nil
    if JapaneseOnPS4() then
        DAYS_LIVED = obits_titles:AddChild(Text(font_face, font_size * 0.8))
    else
        DAYS_LIVED = obits_titles:AddChild(Text(font_face, font_size))
    end
    DAYS_LIVED:SetHAlign(text_align)
    DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED - column_widths.DAYS_LIVED/2, 0)
    DAYS_LIVED:SetRegionSize(column_widths.DAYS_LIVED, 30)
    DAYS_LIVED:SetString(STRINGS.UI.MORGUESCREEN.DIED_AGE)
    DAYS_LIVED:SetColour(UICOLOURS.GOLD_SELECTED)
    DAYS_LIVED:SetClickable(false)

    local DECEASED = obits_titles:AddChild(Text(font_face, font_size))
    DECEASED:SetHAlign(text_align)
    DECEASED:SetPosition(column_offsets.DECEASED - column_widths.DECEASED/2, 0, 0)
    DECEASED:SetRegionSize(column_widths.DECEASED, 30)
    DECEASED:SetString(STRINGS.UI.MORGUESCREEN.DECEASED)
    DECEASED:SetColour(UICOLOURS.GOLD_SELECTED)
    DECEASED:SetClickable(false)
    if units_per_row > 1 then
        DECEASED:Hide()
    end

    local CAUSE = obits_titles:AddChild(Text(font_face, font_size))
    CAUSE:SetHAlign(text_align)
    CAUSE:SetPosition(column_offsets.CAUSE - column_widths.CAUSE/2, 0, 0)
    CAUSE:SetRegionSize(column_widths.CAUSE, 30)
    CAUSE:SetString(STRINGS.UI.MORGUESCREEN.CAUSE)
    CAUSE:SetColour(UICOLOURS.GOLD_SELECTED)
    CAUSE:SetClickable(false)

    local MODE = obits_titles:AddChild(Text(font_face, font_size))
    MODE:SetHAlign(text_align)
    MODE:SetPosition(column_offsets.MODE - column_widths.MODE/2, 0, 0)
    MODE:SetRegionSize(column_widths.MODE, 30)
    MODE:SetString(STRINGS.UI.MORGUESCREEN.MODE)
    MODE:SetColour(UICOLOURS.GOLD_SELECTED)
    MODE:SetClickable(false)

    obits_titles.SetColour = function(_, colour)
        DAYS_LIVED:SetColour(colour)
        DECEASED:SetColour(colour)
        CAUSE:SetColour(colour)
        MODE:SetColour(colour)
    end

    obits_titles.SetTextSize = function(_, size)
        DAYS_LIVED:SetSize(size)
        DECEASED:SetSize(size)
        CAUSE:SetSize(size)
        MODE:SetSize(size)
    end

    return obits_titles
end

local function obit_widget_constructor(context, i)
    local slide_factor = 245
    local group = Widget("morgue-hideable_root")
    group.hideable_root = group:AddChild(Widget("control-morgue"))
    group.hideable_root:SetPosition(-row_width/2 + slide_factor,0)

    group.bg = group.hideable_root:AddChild(CreateListItemBackground())
    group.bg:SetOnGainFocus(function() context.screen.obits_scroll_list:OnWidgetFocus(group) end)
    group.bg:SetPosition(row_width/2 - slide_factor,0)
    group.focus_forward = group.bg

    if units_per_row > 1 then
        group.titles = group.hideable_root:AddChild(BuildObituariesTitles())
        group.titles:SetPosition(3, 10)
        group.titles:SetColour(UICOLOURS.GREY)
        group.titles:SetTextSize(title_font_size)
    end


    group.DAYS_LIVED = group.hideable_root:AddChild(Text(font_face, font_size))
    group.DAYS_LIVED:SetHAlign(text_align)
    group.DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED - column_widths.DAYS_LIVED/2, text_content_y)
    group.DAYS_LIVED._align =
    {
        maxwidth = column_widths.DAYS_LIVED,
        maxchars = 30,
    }
    group.DAYS_LIVED:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    group.DECEASED = group.hideable_root:AddChild(BuildCharacterPortrait("DECEASED"))
    group.DECEASED:SetPosition(column_offsets.DECEASED - row_height/2, 0)

    group.CAUSE = group.hideable_root:AddChild(Text(font_face, font_size))
    group.CAUSE:SetHAlign(text_align)
    group.CAUSE:SetPosition(column_offsets.CAUSE - column_widths.CAUSE/2, text_content_y)
    group.CAUSE._align =
    {
        maxwidth = column_widths.CAUSE,
        maxchars = 45,
    }
    group.CAUSE:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    group.MODE = group.hideable_root:AddChild(Text(font_face, font_size))
    group.MODE:SetHAlign(text_align)
    group.MODE:SetPosition(column_offsets.MODE - column_widths.MODE/2, text_content_y)
    group.MODE:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    group.MODE._align =
    {
        maxwidth = column_widths.MODE,
        maxchars = 85,
    }

    return group
end

local function obit_widget_update(context, widget, data, index)
    if widget == nil then
        return
    elseif data == nil then
        widget.hideable_root:Hide()
        return
    else
        widget.hideable_root:Show()
    end

    widget.DAYS_LIVED:SetTruncatedString((data.days_survived or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS).." "..(data.days_survived == 1 and STRINGS.UI.MORGUESCREEN.DAY or STRINGS.UI.MORGUESCREEN.DAYS), widget.DAYS_LIVED._align.maxwidth, widget.DAYS_LIVED._align.maxchars, true)
    LeftAlignText(widget.DAYS_LIVED, "DAYS_LIVED")

    widget.DECEASED:SetCharacter(data.character)

    widget.CAUSE:SetTruncatedString(GetKilledByFromMorgueRow(data), widget.CAUSE._align.maxwidth, widget.CAUSE._align.maxchars, true)
    LeftAlignText(widget.CAUSE, "CAUSE")

    widget.MODE:SetTruncatedString(data.server or "", widget.MODE._align.maxwidth, widget.MODE._align.maxchars, true)
    LeftAlignText(widget.MODE, "MODE")
end

local function BuildEncountersTitles()
    local font_face = title_font_face

    local encounters_titles = Widget("encounters_titles")

    local PLAYER_CHAR = encounters_titles:AddChild(Text(font_face, font_size))
    PLAYER_CHAR:SetHAlign(text_align)
    PLAYER_CHAR:SetPosition(column_offsets.PLAYER_CHAR - column_widths.PLAYER_CHAR/2, 0)
    PLAYER_CHAR:SetRegionSize(column_widths.PLAYER_CHAR, 30)
    PLAYER_CHAR:SetString(STRINGS.UI.MORGUESCREEN.PLAYER_CHAR)
    PLAYER_CHAR:SetColour(UICOLOURS.GOLD_SELECTED)
    PLAYER_CHAR:SetClickable(false)

    local SERVER_NAME = encounters_titles:AddChild(Text(font_face, font_size))
    SERVER_NAME:SetHAlign(text_align)
    SERVER_NAME:SetPosition(column_offsets.SERVER_NAME - column_widths.SERVER_NAME/2, 0)
    SERVER_NAME:SetRegionSize(column_widths.SERVER_NAME, 30)
    SERVER_NAME:SetString(STRINGS.UI.MORGUESCREEN.SERVER_NAME)
    SERVER_NAME:SetColour(UICOLOURS.GOLD_SELECTED)
    SERVER_NAME:SetClickable(false)

    local PLAYER_AGE = nil
    if not JapaneseOnPS4() then
        PLAYER_AGE = encounters_titles:AddChild(Text(font_face, font_size))
        PLAYER_AGE:SetHAlign(text_align)
        PLAYER_AGE:SetPosition(column_offsets.PLAYER_AGE - column_widths.PLAYER_AGE/2, 0)
        PLAYER_AGE:SetRegionSize(column_widths.PLAYER_AGE, 30)
        PLAYER_AGE:SetString(STRINGS.UI.MORGUESCREEN.PLAYER_AGE)
        PLAYER_AGE:SetColour(UICOLOURS.GOLD_SELECTED)
        PLAYER_AGE:SetClickable(false)
    end

    encounters_titles.SetColour = function(_, colour)
        PLAYER_CHAR:SetColour(colour)
        SERVER_NAME:SetColour(colour)
        if not JapaneseOnPS4() then
            PLAYER_AGE:SetColour(colour)
        end
    end

    encounters_titles.SetTextSize = function(_, size)
        PLAYER_CHAR:SetSize(size)
        SERVER_NAME:SetSize(size)
        if not JapaneseOnPS4() then
            PLAYER_AGE:SetSize(size)
        end
    end


    return encounters_titles
end

local function encounter_widget_update(context, widget, data, index)   
    if widget == nil then
        return
    elseif data == nil then
        widget.hideable_root:Hide()
        return
    else
        widget.hideable_root:Show()
    end

    widget.PLAYER_NAME:SetTruncatedString(data.name or "", widget.PLAYER_NAME._align.maxwidth, widget.PLAYER_NAME._align.maxchars, true)
    LeftAlignText(widget.PLAYER_NAME, "PLAYER_NAME")

    widget.SERVER_NAME:SetTruncatedString(data.server_name or "", widget.SERVER_NAME._align.maxwidth, widget.SERVER_NAME._align.maxchars, true)
    LeftAlignText(widget.SERVER_NAME, "SERVER_NAME")

    widget.PLAYER_CHAR:SetCharacter(data.prefab)

    -- TODO(JapaneseOnPS4): Is showing the date allowed/will it fit?
    widget.SEEN_DATE:SetString(data.date or "")

    local age_str = (data.playerage or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS).." "..(tonumber(data.playerage) == 1 and STRINGS.UI.MORGUESCREEN.DAY or STRINGS.UI.MORGUESCREEN.DAYS)
    widget.PLAYER_AGE:SetTruncatedString(age_str, widget.PLAYER_AGE._align.maxwidth, widget.PLAYER_AGE._align.maxchars, true)
    LeftAlignText(widget.PLAYER_AGE, "PLAYER_AGE")

    widget.NET_ID._netid = data.netid
    if TheNet:IsNetIDPlatformValid(data.netid) then
        widget.NET_ID:Unselect()
    else
        widget.NET_ID:Select()
    end
    widget.CLEAR._userid = data.userid
end

local MorgueScreen = Class(Screen, function(self, prev_screen, user_profile)
    Widget._ctor(self, "MorgueScreen")
	self.can_view_profile = not IsPS4()

    self.root = self:AddChild(TEMPLATES.ScreenRoot("ROOT"))
    self.bg = self.root:AddChild(TEMPLATES.PlainBackground())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.MORGUESCREEN.HISTORY, ""))

    self.onlinestatus = self.root:AddChild(OnlineStatus())
    self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:_Close() end))

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    self.dialog:SetPosition(140, 10)
    self.panel_root = self.dialog:InsertWidget(Widget("panel_root"))
    self.panel_root:SetPosition(-120, -41)


    self.morgue = Morgue:GetRows()

    PlayerHistory:SortBackwards("sort_date")
    self.player_history = PlayerHistory:GetRows()

    self.subscreener = Subscreener(self,
        self._BuildMenu,
        {
            -- Left menu items
            obituary = self.panel_root:AddChild(self:BuildObituariesTab()),
            encounters = self.panel_root:AddChild(self:BuildEncountersTab()),
        })

    -- More descriptive as subtitle
    self.subscreener.titles.encounters = STRINGS.UI.MORGUESCREEN.LONGENCOUNTERSTITLE

    self:_RefreshButtonVisibility()

    self.default_focus = self.subscreener.menu
    self.subscreener:OnMenuButtonSelected("obituary")
end)

function MorgueScreen:_BuildMenu(subscreener)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())
	
	local obituary_button   = subscreener:MenuButton(STRINGS.UI.MORGUESCREEN.TITLE,           "obituary",   STRINGS.UI.OPTIONS.TOOLTIP_OBITUARY,   self.tooltip)
	local encounters_button = subscreener:MenuButton(STRINGS.UI.MORGUESCREEN.ENCOUNTERSTITLE, "encounters", STRINGS.UI.OPTIONS.TOOLTIP_ENCOUNTERS, self.tooltip)

    local menu_items = {
        {widget = encounters_button},
        {widget = obituary_button},
    }

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

local function EncounterWidgetConstructor(context, i)
    local slide_factor = 245
    local group = Widget("encounter-hideable_root")
    group.hideable_root = group:AddChild(Widget("control-encounter"))
    group.hideable_root:SetPosition(-row_width/2 + slide_factor,0)

    group.bg = group.hideable_root:AddChild(CreateListItemBackground())
    group.bg:SetOnGainFocus(function() context.screen.encounters_scroll_list:OnWidgetFocus(group) end)
    group.bg:SetPosition(row_width/2 - slide_factor,0)
    group.focus_forward = group.bg

    if units_per_row > 1 then
        group.titles = group.hideable_root:AddChild(BuildEncountersTitles())
        group.titles:SetPosition(2, 10)
        group.titles:SetColour(UICOLOURS.GREY)
        group.titles:SetTextSize(title_font_size)
    end


    group.PLAYER_NAME = group.hideable_root:AddChild(Text(font_face, font_size))
    group.PLAYER_NAME:SetHAlign(text_align)
    group.PLAYER_NAME:SetPosition(column_offsets.PLAYER_NAME - column_widths.PLAYER_NAME/2, text_content_y)
    group.PLAYER_NAME:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    group.PLAYER_NAME._align =
    {
        maxwidth = column_widths.PLAYER_NAME,
        maxchars = 40,
    }

    group.PLAYER_CHAR = group.hideable_root:AddChild(BuildCharacterPortrait("PLAYER_CHAR"))
    group.PLAYER_CHAR:SetPosition(column_offsets.PLAYER_CHAR - row_height/2, 0)

    group.SERVER_NAME = group.hideable_root:AddChild(Text(font_face, font_size))
    group.SERVER_NAME:SetHAlign(text_align)
    group.SERVER_NAME:SetPosition(column_offsets.SERVER_NAME - column_widths.SERVER_NAME/2, text_content_y)
    group.SERVER_NAME:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    group.SERVER_NAME._align =
    {
        maxwidth = column_widths.SERVER_NAME,
        maxchars = 70,
    }

    -- Seen date looks like a header for name. This is a better use of space.
    group.SEEN_DATE = group.hideable_root:AddChild(Text(title_font_face, title_font_size))
    group.SEEN_DATE:SetHAlign(text_align)
    group.SEEN_DATE:SetPosition(column_offsets.PLAYER_NAME - column_widths.PLAYER_NAME/2, 10)
    group.SEEN_DATE:SetRegionSize(column_widths.PLAYER_NAME, 30)
    group.SEEN_DATE:SetColour(UICOLOURS.GREY)
    group.SEEN_DATE:SetClickable(false)

    group.PLAYER_AGE = group.hideable_root:AddChild(Text(font_face, font_size))
    group.PLAYER_AGE:SetHAlign(text_align)
    group.PLAYER_AGE:SetPosition(column_offsets.PLAYER_AGE - column_widths.PLAYER_AGE/2, text_content_y)
    group.PLAYER_AGE._align =
    {
        maxwidth = column_widths.PLAYER_AGE,
        maxchars = 25,
    }
    group.PLAYER_AGE:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    local extra_space = 2
    group.NET_ID = group.hideable_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, false, false,
        function()
            if group.NET_ID._netid ~= nil then
                TheNet:ViewNetProfile(group.NET_ID._netid)
            end
        end,
        {
            offset_x = -150,
            offset_y = 0,
    }))
    group.NET_ID:SetPosition(column_offsets.SUBMENU, row_height/4 - extra_space)
    group.NET_ID:SetScale(.5)
    group.NET_ID:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE)

    group.CLEAR = group.hideable_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "delete.tex", STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR, false, false,
        function()
            PlayerHistory:RemoveUser(group.CLEAR._userid)
            context.screen:UpdatePlayerHistory()
        end,
        {
            offset_x = -180,
            offset_y = 0,
    }))
    group.CLEAR:SetPosition(column_offsets.SUBMENU, -row_height/4 + extra_space)
    group.CLEAR:SetScale(.5)
    group.CLEAR:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR)

    local function SequenceFocusHorizontal(left, right)
        left:SetFocusChangeDir(MOVE_RIGHT, right)
        right:SetFocusChangeDir(MOVE_LEFT, left)
    end

	if context.screen.can_view_profile then
		SequenceFocusHorizontal(group.bg, group.NET_ID)
		SequenceFocusHorizontal(group.NET_ID, group.CLEAR)
		group.NET_ID:SetFocusChangeDir(MOVE_DOWN, group.CLEAR)
		group.CLEAR:SetFocusChangeDir(MOVE_UP, group.NET_ID)
	else	
		SequenceFocusHorizontal(group.bg, group.CLEAR)
		group.NET_ID:Hide()
	end

    return group
end

function MorgueScreen:BuildObituariesTab()
    self.obituaryroot = Widget("obituaryroot")

    self.obits_titles = self.obituaryroot:AddChild(BuildObituariesTitles())
    self.obits_titles:SetPosition(-77, header_height)
    if units_per_row > 1 then
        self.obits_titles:Hide()
    end

    self.obits_scroll_list = self.obituaryroot:AddChild(TEMPLATES.ScrollingGrid(
            self.morgue,
            {
                scroll_context = {
                    screen = self,
                },
                widget_width  = row_width,
                widget_height = row_height,
                num_visible_rows = num_rows,
                num_columns = 1,
                item_ctor_fn = obit_widget_constructor,
                apply_fn = obit_widget_update,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60,
            }))
    self.obits_scroll_list:SetPosition(105, 20 * units_per_row)
    
    self.obituaryroot.focus_forward = self.obits_scroll_list

    return self.obituaryroot
end

function MorgueScreen:BuildEncountersTab()
    self.encountersroot = Widget("encountersroot")

    self.encounters_titles = self.encountersroot:AddChild(BuildEncountersTitles())
    self.encounters_titles:SetPosition(-77, header_height)
    if units_per_row > 1 then
        self.encounters_titles:Hide()
    end

    self.encounters_scroll_list = self.encountersroot:AddChild(TEMPLATES.ScrollingGrid(
            self.player_history,
            {
                scroll_context = {
                    screen = self,
                },
                widget_width  = row_width,
                widget_height = row_height,
                num_visible_rows = num_rows,
                num_columns = 1,
                item_ctor_fn = EncounterWidgetConstructor,
                apply_fn = encounter_widget_update,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60,
            }))
    self.encounters_scroll_list:SetPosition(105, 20 * units_per_row)

    self.encountersroot.focus_forward = self.encounters_scroll_list

    return self.encountersroot 
end

function MorgueScreen:UpdatePlayerHistory()
    self.player_history = PlayerHistory:GetRows()
    self.encounters_scroll_list:SetItemsData( self.player_history )
end

function MorgueScreen:_RefreshButtonVisibility()
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
            self:_Close()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
    end
end

function MorgueScreen:_Close()
    self:Disable()
    TheFrontEnd:FadeBack()
end

function MorgueScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return MorgueScreen
