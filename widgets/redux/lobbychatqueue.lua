local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ScrollableList = require "widgets/scrollablelist"
local LobbyChatLine = require "widgets/redux/lobbychatline"

require("constants")

local MAX_MESSAGES = 20


local LobbyChatQueue = Class(Widget, function(self, chatbox, onReceiveNewMessage, nextWidget)
    Widget._ctor(self, "LobbyChatQueue")

    self.chatbox = chatbox
    self.new_message_fn = onReceiveNewMessage
    self.nextWidget = nextWidget

    self.list_widgets = {}

    self.message_count = 0

    self.chat_font = CHATFONT
    self.chat_size = 20

    self.chat_listener = function(chat_message)
        self:PushMessage(chat_message)
    end

    ChatHistory:AddChatHistoryListener(self.chat_listener)

    self:Rebuild()
end)

function LobbyChatQueue:Rebuild()
    for i, v in ipairs(self.list_widgets) do
        v:Kill()
    end

    self.list_widgets = {}

    for i = ChatHistory.MAX_CHAT_HISTORY, 1, -1 do
        local chat_message = ChatHistory:GetChatMessageAtIndex(i)
        if chat_message then
            self:PushMessage(chat_message, true)
        end
    end
end

function LobbyChatQueue:Kill()
    LobbyChatQueue._base.Kill(self)
    ChatHistory:RemoveChatHistoryListener(self.chat_listener)
	self.chat_listener = nil
end

--[[
--leaving for posterity, would be broken with the changes to the UI.
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
--]]

function LobbyChatQueue:PushMessage(chat_message, silent)
    if not self.scroll_list then
        self.scroll_list = self:AddChild(ScrollableList(self.list_widgets, -- items
                175,                                                  -- listwidth
                280,                                                  -- listheight
                20,                                                   -- itemheight
                0,                                                   -- itempadding
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

        self.scroll_list:SetScissor(-180, -147.5, 360, 295)
        self.scroll_list:SetPosition(100, -45)

        self:DoFocusHookups()
    end

    local lobby_chat_line = self.scroll_list:AddChild(LobbyChatLine(self.chat_font, chat_message.type, chat_message.message, chat_message.m_colour, chat_message.sender, chat_message.s_colour, chat_message.icondata))
    table.insert(self.list_widgets, lobby_chat_line)

    for i = 1, lobby_chat_line:GetExtraLineCount() do
        lobby_chat_line:IncrementShowCount()
        local continuation = self.scroll_list:AddChild(Widget("LobbyChatLine-continuation"))
        continuation.fake_message = true
        continuation.OnShow = function(_, was_hidden)
            if was_hidden then
                lobby_chat_line:IncrementShowCount()
            end
        end
        continuation.OnHide = function(_, was_visible)
            if was_visible then
                lobby_chat_line:DecrementShowCount()
            end
        end
        table.insert(self.list_widgets, continuation)
    end

    self.message_count = self.message_count + 1

    while self.message_count > ChatHistory.MAX_CHAT_HISTORY do
        table.remove(self.list_widgets, 1):Kill()
        while self.list_widgets[1].fake_message do
            table.remove(self.list_widgets, 1):Kill()
        end

        self.message_count = self.message_count - 1
    end

    local is_at_end = self.scroll_list:IsAtEnd()

    self.scroll_list:SetList(self.list_widgets, true, nil, true)

    if is_at_end then
        self.scroll_list:ScrollToEnd()
    end

    if not silent and self.new_message_fn then
        self.new_message_fn()
    end
end

function LobbyChatQueue:DoFocusHookups()
    if self.scroll_list then
        self.default_focus = self.scroll_list
        self.scroll_list:SetFocusChangeDir(MOVE_RIGHT, self.nextWidget)
    else
        self:SetFocusChangeDir(MOVE_RIGHT, self.nextWidget)
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
