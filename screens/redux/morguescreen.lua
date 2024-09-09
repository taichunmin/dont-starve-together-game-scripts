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
local column_offsets = {
    DECEASED = -170,
    DAYS_LIVED = -40,
    CAUSE = 190,
    MODE = 610,
}

local font_face = CHATFONT
local font_size = 28
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

    widget.MODE:SetTruncatedString(ServerPreferences:IsNameAndDescriptionHidden(data.server) and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or data.server or "", widget.MODE._align.maxwidth, widget.MODE._align.maxchars, true)
    LeftAlignText(widget.MODE, "MODE")
end

local function ecounter_widget_constructor(context, i)
	local top_y = -12

	local w = Widget("control-encounter")
	w.root = w:AddChild(Widget("encounter-hideable_root"))

	local bg = w.root:AddChild(TEMPLATES.ListItemBackground(row_width, row_height))
	bg:SetOnGainFocus(function() context.screen.encounters_scroll_list:OnWidgetFocus(w) end)

	w.widgets = w.root:AddChild(Widget("encounter-data_root"))
	w.widgets:SetPosition(-row_width/2, 0)

	local spacing = 15
	local x = spacing

    w.widgets.character = w.widgets:AddChild(BuildCharacterPortrait("character"))
	x = x + row_height/2
    w.widgets.character:SetPosition(x , 0)
	x = x + row_height/2 + spacing

	w.widgets.playername = w.widgets:AddChild(Text(HEADERFONT, 26))
	w.widgets.playername:SetColour(UICOLOURS.GOLD)
	w.widgets.playername._position = { x = x, y = 10, w = 400 }

    w.widgets.desc = w.widgets:AddChild(Text(CHATFONT, 22))
    w.widgets.desc:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	w.widgets.desc._position = { x = x, y = -13, w = 570 }

	local button_x = row_width - spacing - 20
    w.widgets.playerinfo_btn = w.widgets:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "player_info.tex", STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE, false, false,
        function()
            if w.widgets.playerinfo_btn._netid ~= nil then
                TheNet:ViewNetProfile(w.widgets.playerinfo_btn._netid)
            end
        end,
        {
            offset_x = 0,
            offset_y = 20,
	    }))
    w.widgets.playerinfo_btn:SetPosition(button_x, 14)
    w.widgets.playerinfo_btn:SetScale(.5)
    w.widgets.playerinfo_btn:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE)

    w.widgets.delete_btn = w.widgets:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "delete.tex", STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR, false, false,
        function()
            PlayerHistory:RemoveUser(w.widgets.delete_btn._userid)
            context.screen:UpdatePlayerHistory()
        end,
        {
            offset_x = 0,
            offset_y = 20,
		}))
    w.widgets.delete_btn:SetPosition(button_x, -14)
    w.widgets.delete_btn:SetScale(.5)
    w.widgets.delete_btn:SetHelpTextMessage(STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR)

	if TheInput:ControllerAttached() then
		-- force an overlay so we can actually tell shat's selected'
		bg:UseFocusOverlay("serverlist_listitem_hover.tex")

		-- hide the buttons since we're not mousing'
		w.widgets.delete_btn:Hide()
		w.widgets.playerinfo_btn:Hide()

		-- add help text for controller button commands
		w.GetHelpText = function()
			local controller_id = TheInput:GetControllerID()
			local t = {}
			if TheInput:ControllerAttached() then
				if context.screen.can_view_profile and w.widgets.playerinfo_btn._netid ~= nil then
					table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_BACK) .. " " .. STRINGS.UI.PLAYERSTATUSSCREEN.VIEWPROFILE)
				end

                if w.widgets.delete_btn._userid ~= nil then
                    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.PLAYERSTATUSSCREEN.CLEAR)
                end
			end

			return table.concat(t, "  ")
		end

		-- add controller button handlers
		w.OnControl = function(self, control, down)
			if context.screen._base.OnControl(self, control, down) then return true end

			if TheInput:ControllerAttached() and not down then
				if control == CONTROL_MENU_BACK and context.screen.can_view_profile and w.widgets.playerinfo_btn._netid ~= nil then
					TheNet:ViewNetProfile(w.widgets.playerinfo_btn._netid)
					return true
				end

                if control == CONTROL_MENU_MISC_2 then
                    if w.widgets.delete_btn._userid ~= nil then
                        PlayerHistory:RemoveUser(w.widgets.delete_btn._userid)
                    end
					context.screen:UpdatePlayerHistory()
					return true
				end
			end
		end

		button_x = button_x + 20
	else
		if context.screen.can_view_profile then
			bg:SetFocusChangeDir(MOVE_RIGHT, w.widgets.playerinfo_btn)

			w.widgets.playerinfo_btn:SetFocusChangeDir(MOVE_LEFT, bg)
			w.widgets.playerinfo_btn:SetFocusChangeDir(MOVE_DOWN, w.widgets.delete_btn)

			w.widgets.delete_btn:SetFocusChangeDir(MOVE_LEFT, bg)
			w.widgets.delete_btn:SetFocusChangeDir(MOVE_UP, w.widgets.playerinfo_btn)
		else
			bg:SetFocusChangeDir(MOVE_RIGHT, w.widgets.playerinfo_btn)
			w.widgets.delete_btn:SetFocusChangeDir(MOVE_LEFT, bg)

			w.widgets.playerinfo_btn:Hide()
		end

		button_x = button_x - spacing - 20
	end

    w.widgets.playtime_label = w.widgets:AddChild(Text(CHATFONT, 22))
    w.widgets.playtime_label:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	w.widgets.playtime_label._position = { x = button_x, y = 12, w = 300 }

    w.widgets.playtime = w.widgets:AddChild(Text(CHATFONT, 22))
    w.widgets.playtime:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	w.widgets.playtime._position = { x = button_x, y = -13, w = 125 }

    local function SequenceFocusHorizontal(left, right)
        left:SetFocusChangeDir(MOVE_RIGHT, right)
        right:SetFocusChangeDir(MOVE_LEFT, left)
    end

	w.focus_forward = bg

	return w
end

local function SetTruncatedLeftJustifiedString(txt, str)
	txt:SetTruncatedString(str or "", txt._position.w, nil, true)
	local width, height = txt:GetRegionSize()
	txt:SetPosition(txt._position.x + width/2, txt._position.y)
end

local function SetTruncatedRightJustifiedString(txt, str)
	txt:SetTruncatedString(str or "", txt._position.w, nil, true)
	local width, height = txt:GetRegionSize()
	txt:SetPosition(txt._position.x - width/2, txt._position.y)
end

local function encounter_widget_update(context, w, data, index)
    if w == nil then
        return
    elseif data == nil then
        w.root:Hide()
        return
    else
        w.root:Show()

		w.widgets.character:SetCharacter(data.prefab)

		SetTruncatedLeftJustifiedString(w.widgets.playername, data.name or "")

		local data_str = data.last_seen_date ~= nil and str_date(data.last_seen_date) or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS -- todo: make this localization friendly
		SetTruncatedLeftJustifiedString(w.widgets.desc, subfmt(STRINGS.UI.MORGUESCREEN.ENCOUNTERS.DESC, {date = data_str, server_name = ServerPreferences:IsNameAndDescriptionHidden(data.server_name) and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or data.server_name or STRINGS.UI.MORGUESCREEN.UNKNOWN_DAYS}))

		if data.time_played_with > 0 then
			w.widgets.playtime_label:Show()
			w.widgets.playtime:Show()
			SetTruncatedRightJustifiedString(w.widgets.playtime_label, STRINGS.UI.MORGUESCREEN.ENCOUNTERS.PLAYTIME_LABEL)
			SetTruncatedRightJustifiedString(w.widgets.playtime, str_play_time(math.max(data.time_played_with, 60)))
		else
			w.widgets.playtime_label:Hide()
			w.widgets.playtime:Hide()
		end

		w.widgets.playerinfo_btn._netid = data.netid
		if TheNet:IsNetIDPlatformValid(data.netid) then
			w.widgets.playerinfo_btn:Unselect()
		else
			w.widgets.playerinfo_btn:Select()
		end
		w.widgets.delete_btn._userid = data.userid
    end
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
    self.subscreener:OnMenuButtonSelected("encounters")
end)

function MorgueScreen:_BuildMenu(subscreener)
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())

	local obituary_button   = subscreener:MenuButton(STRINGS.UI.MORGUESCREEN.TITLE,           "obituary",   STRINGS.UI.OPTIONS.TOOLTIP_OBITUARY,   self.tooltip)
	local encounters_button = subscreener:MenuButton(STRINGS.UI.MORGUESCREEN.ENCOUNTERSTITLE, "encounters", STRINGS.UI.OPTIONS.TOOLTIP_ENCOUNTERS, self.tooltip)

    local menu_items = {
        {widget = obituary_button},
        {widget = encounters_button},
    }

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
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
                scrollbar_height_offset = -60
            }))
    self.obits_scroll_list:SetPosition(105, 20 * units_per_row)

    self.obituaryroot.focus_forward = self.obits_scroll_list

    return self.obituaryroot
end

function MorgueScreen:BuildEncountersTab()
    self.encountersroot = Widget("encountersroot")

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
                item_ctor_fn = ecounter_widget_constructor,
                apply_fn = encounter_widget_update,
                scrollbar_offset = 20,
                scrollbar_height_offset = -60
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
