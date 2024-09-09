

local Widget = require "widgets/widget"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Image = require "widgets/image"

local TEMPLATES = require "widgets/redux/templates"

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
local num_rows = math.ceil(19 / units_per_row)
local text_content_y = -12
local dialog_size_x = 830
local dialog_width = dialog_size_x + (60*2) -- nineslice sides are 60px each
local row_height = 60
local row_width = dialog_width*0.9
local dialog_size_y = row_height*(num_rows + 0.25)

local column_widths = {
    DAYS_LIVED = 120,
    DECEASED = row_height,
    CAUSE = 230,
    MODE = 410,
}

local ObituariesPanel = Class(Widget, function(self, parent_screen)
    Widget._ctor(self, "ObituariesPanel")

	self.parent_screen = parent_screen

    self.morgue = Morgue:GetRows()

	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0,0)

	self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y))
    self.dialog:SetPosition(0, 10)


	self:DoInit()
    self.obits_scroll_list:SetPosition(-15, 0)

    self.focus_forward = self.obits_scroll_list
end)

local function BuildObituariesTitles()
    local font_face = title_font_face

    local obits_titles = Widget("obits_titles")

    local DAYS_LIVED = nil
    if JapaneseOnPS4() then
        DAYS_LIVED = obits_titles:AddChild(Text(font_face, font_size * 0.8))
    else
        DAYS_LIVED = obits_titles:AddChild(Text(font_face, font_size))
    end
    DAYS_LIVED:SetHAlign(ANCHOR_LEFT)
    DAYS_LIVED:SetPosition(column_offsets.DAYS_LIVED - column_widths.DAYS_LIVED/2, 0)
    DAYS_LIVED:SetRegionSize(column_widths.DAYS_LIVED, 30)
    DAYS_LIVED:SetString(STRINGS.UI.MORGUESCREEN.DIED_AGE)
    DAYS_LIVED:SetColour(UICOLOURS.GOLD_SELECTED)
    DAYS_LIVED:SetClickable(false)

    local DECEASED = obits_titles:AddChild(Text(font_face, font_size))
    DECEASED:SetHAlign(ANCHOR_LEFT)
    DECEASED:SetPosition(column_offsets.DECEASED - column_widths.DECEASED/2, 0, 0)
    DECEASED:SetRegionSize(column_widths.DECEASED, 30)
    DECEASED:SetString(STRINGS.UI.MORGUESCREEN.DECEASED)
    DECEASED:SetColour(UICOLOURS.GOLD_SELECTED)
    DECEASED:SetClickable(false)
    if units_per_row > 1 then
        DECEASED:Hide()
    end

    local CAUSE = obits_titles:AddChild(Text(font_face, font_size))
    CAUSE:SetHAlign(ANCHOR_LEFT)
    CAUSE:SetPosition(column_offsets.CAUSE - column_widths.CAUSE/2, 0, 0)
    CAUSE:SetRegionSize(column_widths.CAUSE, 30)
    CAUSE:SetString(STRINGS.UI.MORGUESCREEN.CAUSE)
    CAUSE:SetColour(UICOLOURS.GOLD_SELECTED)
    CAUSE:SetClickable(false)

    local MODE = obits_titles:AddChild(Text(font_face, font_size))
    MODE:SetHAlign(ANCHOR_LEFT)
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
    local w,h = text_widget:GetRegionSize()
    -- alignment isn't precise so add more offset to look less weird
    local more_misalign = 7
    text_widget:SetPosition(more_misalign + column_offsets[name] - column_widths[name] + w/2, text_content_y)
end

local function obit_widget_constructor(context, i)
    local slide_factor = 245
    local group = Widget("morgue-hideable_root")
    group.hideable_root = group:AddChild(Widget("control-morgue"))
    group.hideable_root:SetPosition(-row_width/2 + slide_factor,0)

    group.bg = group.hideable_root:AddChild(TEMPLATES.ListItemBackground(row_width,row_height))
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
    group.DAYS_LIVED:SetHAlign(ANCHOR_LEFT)
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
    group.CAUSE:SetHAlign(ANCHOR_LEFT)
    group.CAUSE:SetPosition(column_offsets.CAUSE - column_widths.CAUSE/2, text_content_y)
    group.CAUSE._align =
    {
        maxwidth = column_widths.CAUSE,
        maxchars = 45,
    }
    group.CAUSE:SetColour(UICOLOURS.GOLD_UNIMPORTANT)

    group.MODE = group.hideable_root:AddChild(Text(font_face, font_size))
    group.MODE:SetHAlign(ANCHOR_LEFT)
    group.MODE:SetPosition(column_offsets.MODE - column_widths.MODE/2, text_content_y)
    group.MODE:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    group.MODE._align =
    {
        maxwidth = column_widths.MODE,
        maxchars = 85,
    }

	if TheInput:ControllerAttached() then
		-- force an overlay so we can actually tell what's selected'
		group.bg:UseFocusOverlay("serverlist_listitem_hover.tex")
	end

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

    local t = GetTime()
    if (data.morgue_random_updatetime or 0) < t then
        data.morgue_random_updatetime = t + 10
        data.morgue_random = math.random()
    end
    widget.CAUSE:SetTruncatedString(GetKilledByFromMorgueRow(data), widget.CAUSE._align.maxwidth, widget.CAUSE._align.maxchars, true)
    LeftAlignText(widget.CAUSE, "CAUSE")

    local filtered_text = ApplyLocalWordFilter(data.server, TEXT_FILTER_CTX_SERVERNAME)
    widget.MODE:SetTruncatedString(ServerPreferences:IsNameAndDescriptionHidden(data.server) and STRINGS.UI.SERVERLISTINGSCREEN.HIDDEN_NAME or filtered_text or "", widget.MODE._align.maxwidth, widget.MODE._align.maxchars, true)
    LeftAlignText(widget.MODE, "MODE")
end

function ObituariesPanel:DoInit()
    self.obits_scroll_list = self.dialog:AddChild(TEMPLATES.ScrollingGrid(
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

end


return ObituariesPanel







