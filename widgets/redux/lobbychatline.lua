local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local SkinsItemPopUp = require "screens/skinsitempopup"

local chat_size = 20
local focus_chat_size = chat_size * 1.167

local line_xpos = -85
local icon_yoffset = -8.166
local username_maxwidth = 120
local username_maxchars = 30
local username_padding = 3
local icon_padding = 6.67
local line_maxwidth = 235
local line_maxchars = 50
local multiline_indent = 10

local function GetSpaceAndTabWidth(font, size)
    local textbox = require("widgets/text")(font, size)
    textbox:SetString(" ")
    local space_width = textbox:GetRegionSize()
    textbox:SetString("\t ")
    local first_tab_width = textbox:GetRegionSize() - space_width
    textbox:SetString(" \t ")
    local tab_width = textbox:GetRegionSize() - space_width * 2
    textbox:Kill()

    return space_width, first_tab_width, tab_width
end

local function CalculateClosestSpacesAndTabs(desired_width, space_width, first_tab_width, tab_width)
    local first_tab_diff = first_tab_width - tab_width
    local max_tabs = math.ceil((desired_width - first_tab_diff) / tab_width)

    local best_diff = math.diff(max_tabs * tab_width + first_tab_diff, desired_width)
    local best_space_count, best_tab_count = 0, max_tabs
    local best_use_first_tab = true

    local current_tab_count = max_tabs
    while current_tab_count > 0 and best_diff ~= 0 do
        current_tab_count = current_tab_count - 1

        if current_tab_count > 0 then
            local remaining_width = desired_width - (current_tab_count * tab_width)
            local min_spaces = math.floor(remaining_width / space_width) * space_width
            local max_spaces = min_spaces + space_width

            local remaining_width_first_tab = desired_width - (current_tab_count * tab_width + first_tab_diff)
            local min_spaces_first_tab = math.floor(remaining_width_first_tab / space_width) * space_width
            local max_spaces_first_tab = min_spaces_first_tab + space_width

            local min_diff = math.diff(min_spaces, remaining_width)
            local max_diff = math.diff(max_spaces, remaining_width)

            local min_diff_first_tab = math.diff(min_spaces_first_tab, remaining_width_first_tab)
            local max_diff_first_tab = math.diff(max_spaces_first_tab, remaining_width_first_tab)

            local best = math.min(min_diff, max_diff, min_diff_first_tab, max_diff_first_tab, best_diff)

            if best == min_diff then
                best_diff = min_diff
                best_space_count, best_tab_count = min_spaces / space_width, current_tab_count
                best_use_first_tab = false
            elseif best == max_diff then
                best_diff = max_diff
                best_space_count, best_tab_count = max_spaces / space_width, current_tab_count
                best_use_first_tab = false
            elseif best == min_diff_first_tab then
                best_diff = min_diff_first_tab
                best_space_count, best_tab_count = min_spaces_first_tab / space_width, current_tab_count
                best_use_first_tab = true
            elseif best == max_diff_first_tab then
                best_diff = max_diff_first_tab
                best_space_count, best_tab_count = max_spaces_first_tab / space_width, current_tab_count
                best_use_first_tab = true
            end
        else
            local min_spaces = math.floor(desired_width / space_width) * space_width
            local max_spaces = min_spaces + space_width

            local min_diff = math.diff(min_spaces, desired_width)
            local max_diff = math.diff(max_spaces, desired_width)

            local best = math.min(min_diff, max_diff, best_diff)

            if best == min_diff then
                best_diff = min_diff
                best_space_count, best_tab_count = min_spaces / space_width, 0
                best_use_first_tab = false
            elseif best == max_diff then
                best_diff = max_diff
                best_space_count, best_tab_count = max_spaces / space_width, 0
                best_use_first_tab = false
            end
        end
    end

    assert(not best_use_first_tab or best_tab_count > 0)

    local str = ""

    for i = 1, best_space_count do
        str = str.." "
    end

    for i = 1, best_tab_count do
        if best_use_first_tab then
            str = "\t"..str
        else
            str = str.."\t"
        end
    end

    return str
end

local LobbyChatLine = Class(Widget, function(self, chat_font, type, message, m_colour, sender, s_colour, icondata)
    Widget._ctor(self, "LobbyChatLine")

    self.show_count = 0

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(line_xpos, 0)

    self.space_width, self.first_tab_width, self.tab_width = GetSpaceAndTabWidth(chat_font, chat_size)

    self.multiline_indent_str = CalculateClosestSpacesAndTabs(multiline_indent, self.space_width, self.first_tab_width, self.tab_width)

    self.type = type

    local is_skin_announcement = self.type == ChatTypes.SkinAnnouncement

    if self.type == ChatTypes.Message then
            self.icon = self.root:AddChild(TEMPLATES.ChatFlairBadge())
        self.icon:SetFlair(icondata)
    elseif self.type == ChatTypes.SystemMessage then
        self.icon = self.root:AddChild(TEMPLATES.SystemMessageBadge())
    elseif self.type == ChatTypes.Announcement or is_skin_announcement then
        self.icon = self.root:AddChild(TEMPLATES.AnnouncementBadge())
        self.icon:SetAnnouncement(is_skin_announcement and "item_drop" or icondata)
    end

    if is_skin_announcement then

        local skin_name = message
        local user_colour = s_colour
        local user_name = sender

        self.skin_btn = self.root:AddChild(ImageButton())
        self.skin_btn.text:SetHAlign(ANCHOR_LEFT)
        self.skin_btn:SetFont(chat_font)
        self.skin_btn:SetTextSize(chat_size)
        self.skin_btn:SetImageNormalColour(0, 0, 0, 0)
        self.skin_btn:SetTextColour(1, 1, 1, 1)
        self.skin_btn:SetTextFocusColour(1, 1, 1, 1)
        self.skin_btn:SetOnClick(function()
            if not skin_name or not user_name or not user_colour then
                return
            end
            TheFrontEnd:PushScreen(SkinsItemPopUp(skin_name, user_name, user_colour))
        end)

        self.skin_btn:SetText(string.format(STRINGS.UI.NOTIFICATION.NEW_SKIN_ANNOUNCEMENT, user_name))

        self.skin_txt = self.skin_btn:AddChild(Text(chat_font, chat_size))
        self.skin_txt:SetHAlign(ANCHOR_LEFT)
        self.skin_txt:SetPosition(0, 2)

        self.skin_txt:SetColour(GetColorForItem(skin_name))
        self.skin_txt:SetString(GetSkinName(skin_name))
    else
        self.message = self.root:AddChild(Text(chat_font, chat_size))
        self.message:SetHAlign(ANCHOR_LEFT)

        self.message:SetString(message)
        self.message:SetColour(m_colour)

        if sender then
            self.user = self.root:AddChild(Text(chat_font, chat_size))
            self.user:SetHAlign(ANCHOR_RIGHT)

            self.user:SetTruncatedString(sender, username_maxwidth, username_maxchars, true)
            self.user:SetColour(s_colour)
        end
    end

    self:UpdatePositions()
end)

local function GetLastLineLength(textwidget)
    local lines = textwidget:GetString():split("\n")
    local textbox = require("widgets/text")(textwidget.font, textwidget.size)
    textbox:SetString(lines[#lines])
    local line_length = textbox:GetRegionSize()
    textbox:Kill()
    return line_length
end

local function AddLinePrefixes(textwidget, prefix, multiline_indent_str)
    local lines = textwidget:GetString():split("\n")
    for i, line in ipairs(lines) do
        lines[i] = (i == 1 and prefix or multiline_indent_str)..line
    end
    textwidget:SetString(table.concat(lines, "\n"))
end

local function UpdateTextWidget(self, textwidget, minimum_offset, extra_y_offset)
    if not self.inital_update then
        local first_line_offset = math.max(minimum_offset, multiline_indent)

        textwidget:SetMultilineTruncatedString(textwidget:GetString(), 100, {line_maxwidth - first_line_offset, line_maxwidth - multiline_indent}, line_maxchars, false)

        AddLinePrefixes(textwidget, CalculateClosestSpacesAndTabs(first_line_offset, self.space_width, self.first_tab_width, self.tab_width), self.multiline_indent_str)
    end

    local message_width, message_height = textwidget:GetRegionSize()
    local extra_line_message_offset = message_height - chat_size

    local y = not self.inital_update and ((extra_y_offset or 0) + extra_line_message_offset * -0.5) or textwidget:GetPosition().y
    textwidget:SetPosition(message_width * 0.5, y)
    return extra_line_message_offset
end

function LobbyChatLine:UpdatePositions()
    local next_offset = 0
    if self.icon then
        if self.user then
            local username_width = self.user:GetRegionSize()
            self.user:SetPosition(next_offset + username_width * 0.5, 0)
            next_offset = next_offset + username_width + username_padding
        end

        if not self.inital_update then
            self.icon:SetScale(self.icon:GetScale() * 0.667)
            self.icon:Show()
        end
        local bg_width = self.icon:GetSize()
        self.icon:SetPosition(next_offset + bg_width * 0.5, icon_yoffset)
        next_offset = next_offset + bg_width + icon_padding
    end

    if self.message then
        UpdateTextWidget(self, self.message, next_offset)

        self.extra_line_count = #self.message:GetString():split("\n") - 1
    else
        local extra_line_height = UpdateTextWidget(self, self.skin_btn.text, next_offset)

        local extra_skin_line_height = UpdateTextWidget(self, self.skin_txt, GetLastLineLength(self.skin_btn.text), extra_line_height * -0.5)

        self.extra_line_count = (#self.skin_btn.text:GetString():split("\n") - 1) + (#self.skin_txt:GetString():split("\n") - 1)

        self.skin_btn:SetPosition(self.skin_btn.text:GetPosition())
        self.skin_btn.text:SetPosition(0, 0, 0)

        local prev_pos = self.skin_txt:GetPosition()
        self.skin_txt:SetPosition(-self.skin_btn:GetPosition().x + prev_pos.x, prev_pos.y, prev_pos.z)

        local image_btn_width, image_btn_height = self.skin_btn.text:GetRegionSize()
        local image_width = math.max(self.skin_txt:GetRegionSize(), image_btn_width)

        self.skin_btn:ForceImageSize(image_width, image_btn_height + extra_skin_line_height)
    end

    self.inital_update = true
end

function LobbyChatLine:GetExtraLineCount()
    return self.extra_line_count
end

function LobbyChatLine:UpdateSkinAnnouncementSize(size)
    if self.skin_btn then
        self.skin_btn:SetTextSize(size)
        self.skin_txt:SetSize(size)
        self:UpdatePositions()
    end
end

function LobbyChatLine:OnGainFocus()
    LobbyChatLine._base.OnGainFocus(self)
    if self.skin_btn then
        self:MoveToFront()
        self:UpdateSkinAnnouncementSize(focus_chat_size)
    end
end

function LobbyChatLine:OnLoseFocus()
    LobbyChatLine._base.OnLoseFocus(self)
    if self.skin_btn then
        self:UpdateSkinAnnouncementSize(chat_size)
    end
end

function LobbyChatLine:OnHide()
    if self.show_count > 0 then
        self:Show()
    end
end

function LobbyChatLine:IncrementShowCount()
    self.show_count = self.show_count + 1
    if self.show_count > 0 then
        self:Show()
    end
end

function LobbyChatLine:DecrementShowCount()
    self.show_count = self.show_count - 1
    if self.show_count == 0 then
        self:Hide()
    end
end

return LobbyChatLine