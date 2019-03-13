local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ScrollableList = require "widgets/scrollablelist"

require("constants")

local MAX_MESSAGES = 20


local LobbyChatQueue = Class(Widget, function(self, owner, chatbox, onReceiveNewMessage, nextWidget)
    Widget._ctor(self, "LobbyChatQueue")

    self.owner = owner

    self.list_items = {}

    self.chat_name_font = CHATFONT
    self.chat_name_size = 20
    self.chat_msg_font = CHATFONT
    self.chat_msg_size = 20

    self.chatbox = chatbox

    self.new_message_fn = onReceiveNewMessage

    self.nextWidget = nextWidget

    -- MessageConstructor
    self.line_xpos = -85
    self.username_maxwidth = 120
    self.username_padding = 3
    self.line_maxwidth = 235
    self.line_maxchars = 50
    self.multiline_maxrows = 8
    self.multiline_indent = 10

    self:StartUpdating()
end)

function LobbyChatQueue:DebugDraw_AddSection(dbui, panel)
    LobbyChatQueue._base.DebugDraw_AddSection(self, dbui, panel)
    local DebugPickers = require("dbui_no_package/debug_pickers")

    dbui.Spacing()
    dbui.Text("LobbyChatQueue")
    dbui.Indent() do
        local face, size = DebugPickers.Font(dbui, "", self.chat_name_font, self.chat_name_size)
        if face then
            self.chat_name_font = face
            self.chat_name_size = size
        end
        local changed, new_val
        changed, new_val = dbui.DragInt("line_xpos",         self.line_xpos)
        if changed then
            self.line_xpos = new_val
        end
        changed, new_val = dbui.DragInt("username_maxwidth", self.username_maxwidth)
        if changed then
            self.username_maxwidth = new_val
        end
        changed, new_val = dbui.DragInt("username_padding",  self.username_padding)
        if changed then
            self.username_padding = new_val
        end
        changed, new_val = dbui.DragInt("line_maxwidth",     self.line_maxwidth)
        if changed then
            self.line_maxwidth = new_val
        end
        changed, new_val = dbui.DragInt("line_maxchars",     self.line_maxchars)
        if changed then
            self.line_maxchars = new_val
        end
        changed, new_val = dbui.DragInt("multiline_maxrows", self.multiline_maxrows)
        if changed then
            self.multiline_maxrows = new_val
        end
        changed, new_val = dbui.DragInt("multiline_indent",  self.multiline_indent)
        if changed then
            self.multiline_indent = new_val
        end

        if dbui.Button("Refresh") then
            local name, prefab, colour = TheNet:GetLocalUserName(), nil, GOLD
            self:OnMessageReceived(name, prefab, "Dummy message to force refresh.", colour)
        end
    end
    dbui.Unindent()
end

function LobbyChatQueue:GetChatAlpha( current_time, chat_time )
    return 1
end

function LobbyChatQueue:OnUpdate()
end

--For ease of overriding in mods
function LobbyChatQueue:GetDisplayName(name, prefab)
    return name ~= "" and name or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_USER_NAME
end

function LobbyChatQueue:_MessageConstructor(data)
    local group = Widget("lobbychat-group")
    local username = data.username:match("^[^\n\v\f\r]*") or ""
    group.user_widget = group:AddChild(Text(self.chat_name_font, self.chat_name_size, nil, data.colour))
    group.user_widget:SetTruncatedString(username..":", self.username_maxwidth, 30, "..:")

    local username_width = group.user_widget:GetRegionSize()
    group.user_widget:SetPosition(self.line_xpos + username_width * .5, 0)

    group.message = group:AddChild(Text(self.chat_msg_font, self.chat_msg_size, nil, UICOLOURS.EGGSHELL))
    group.message:SetMultilineTruncatedString(data.message, self.multiline_maxrows, { self.line_maxwidth - username_width - self.username_padding, self.line_maxwidth - self.multiline_indent }, self.line_maxchars, true)

    local lines = group.message:GetString():split("\n")
    group.message:SetString(lines[1])

    local message_width = group.message:GetRegionSize()
    group.message:SetPosition(self.line_xpos + username_width + self.username_padding + message_width * .5, 0)

    local list = { group }

    for i = 2, #lines do
        group = Widget("lobbychat-continuation")

        group.message = group:AddChild(Text(self.chat_msg_font, self.chat_msg_size, nil, UICOLOURS.EGGSHELL))
        group.message:SetString(lines[i])

        message_width = group.message:GetRegionSize()
        group.message:SetPosition(self.line_xpos + self.multiline_indent + message_width * .5, 0)

        table.insert(list, group)
    end

    return list
end

function LobbyChatQueue:OnMessageReceived(name, prefab, message, colour)
    self.list_items[#self.list_items + 1] =
    {
        message = message,
        colour = colour,
        username = self:GetDisplayName(name, prefab),
    }

    local startidx = math.max(1, (#self.list_items - MAX_MESSAGES) + 1) -- older messages are dropped
    local list_widgets = {}
    for k,v in pairs(self.list_items) do 
        if k >= startidx then 
            local list = self:_MessageConstructor(v)
            for k2,v2 in pairs(list) do 
                table.insert(list_widgets, v2)
            end
        end
    end

    if not self.scroll_list then
        self.scroll_list = self:AddChild(ScrollableList(list_widgets, -- items
                175,                                                  -- listwidth
                280,                                                  -- listheight
                20,                                                   -- itemheight
                10,                                                   -- itempadding
                nil,                                                  -- updatefn
                nil,                                                  -- widgetstoupdate
                nil,                                                  -- widgetXOffset
                nil,                                                  -- always_show_static
                nil,                                                  -- starting_offset
                15,                                                   -- yInit
                nil,                                                  -- bar_width_scale_factor
                nil,                                                  -- bar_height_scale_factor
                "GOLD"                                                -- scrollbar_style
            ))

        self.scroll_list:SetPosition(100, -45)
    else
        self.scroll_list:SetList(list_widgets)
        self.scroll_list:ScrollToEnd()
    end

    if self.new_message_fn then
        self.new_message_fn()
    end

    self:DoFocusHookups()
end

function LobbyChatQueue:DoFocusHookups()
    if self.scroll_list then 
        self.default_focus = self.scroll_list
        self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.nextWidget)
    else
        self:SetFocusChangeDir(MOVE_RIGHT, self.nextWidget)
    end

end

function LobbyChatQueue:ScrollToEnd()
    if self.scroll_list then
        self.scroll_list:ScrollToEnd()
    end
end

function LobbyChatQueue:OnControl(control, down)
    if not self:IsEnabled() or not self.focus then return false end

    if self.chatbox and control == CONTROL_ACCEPT and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
        return self.chatbox:OnControl(control, down)
    end

    if self.scroll_list and (control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD) then
        return self.scroll_list:OnControl(control, down, true)
    elseif self.scroll_list and self.scroll_list.focus then
        return self.scroll_list:OnControl(control, down)
    end

    return false
end

function LobbyChatQueue:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if self.scroll_list and self.scroll_list.scroll_bar and self.scroll_list.scroll_bar:IsVisible() then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false).. " " .. STRINGS.UI.HELP.SCROLL)   
    end

    if self.chatbox then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. STRINGS.UI.LOBBYSCREEN.CHAT)   
    end

    return table.concat(t, "  ")
end

return LobbyChatQueue
