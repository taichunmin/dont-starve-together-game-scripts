local Widget = require "widgets/widget"
local ChatScrollList = require "widgets/redux/chatscrolllist"
local ChatLine = require "widgets/redux/chatline"

local CHAT_QUEUE_VISUAL_SIZE = 14
local CHAT_QUEUE_SIZE = CHAT_QUEUE_VISUAL_SIZE + 1

local function SplitMultilineString(self, message)
    -- HACK HACK HACK! Since the chat window is single-line only, we break this into multiple lines... by using
    -- an invisible text box that wraps the text for us!
    local textbox = require("widgets/text")(self.chat_font, self.chat_size)
    textbox:SetMultilineTruncatedString(message, 100, self.message_width, self.message_max_chars, false)
    local messages = string.split(textbox:GetString(), "\n")
    textbox:Kill()

    return messages
end

local ScrollableChatQueue = Class(Widget, function(self)
    Widget._ctor(self, "ScrollableChatQueue")

    self.widget_rows = {}

    self.chat_font = TALKINGFONT--DEFAULTFONT --UIFONT
    self.chat_size = 30 --22
    self.user_width = 160
    self.user_max_chars = 28
    self.message_width = 850
    self.message_max_chars = 150

    self:MakeChatScrollList()

    self.chat_listener = function(chat_message)
        self:PushMessage()
    end

    ChatHistory:AddChatHistoryListener(self.chat_listener)
end)

function ScrollableChatQueue:GetChatLinesForMessage(history_index)
    local message_data
    if history_index == ChatHistory.MAX_CHAT_HISTORY + 1 then
        message_data = ChatHistory:GetLastDeletedChatMessage()
    else
        message_data = ChatHistory:GetChatMessageAtIndex(history_index)
    end

    if not message_data then
        return nil
    end

    if not message_data.chatqueue_chatlines then
        message_data.chatqueue_chatlines = #SplitMultilineString(self, message_data.message)
    end

    return message_data.chatqueue_chatlines
end

function ScrollableChatQueue:MakeChatScrollList()
    if self.chat_scroll_list then
        return
    end

    local row_height = self.chat_size + 2
    local chat_queue_offset = (CHAT_QUEUE_VISUAL_SIZE * row_height)/2
    local chat_line_offset = -chat_queue_offset

    self.chat_scroll_list = self:AddChild(ChatScrollList(
        function(parent)
            for i = 1, CHAT_QUEUE_SIZE do
                local chatline = parent:AddChild(ChatLine(self.chat_font, self.user_width, self.user_max_chars, self.message_width, self.message_max_char))
                chatline:SetPosition(-35, chat_line_offset + (i - 1) * row_height)
                self.widget_rows[i] = chatline
            end

            return self.widget_rows, row_height
        end,
        function(chatline, index, current_scroll_pos, row_offset, data)
            if index == CHAT_QUEUE_SIZE then
                if row_offset == 0 then
                    chatline:Hide()
                else
                    chatline:Show()
                end
            end

            if chatline.last_scroll_pos == current_scroll_pos and not self.history_updated then
                chatline:UpdateAlpha(self:CalculateChatAlpha(chatline.history_index))
                return
            end
            chatline.last_scroll_pos = current_scroll_pos

            local message = data[index]
            if message then
                chatline.history_index = message.history_index
                chatline:SetChatData(
                    message.type,
                    self:CalculateChatAlpha(chatline.history_index),
                    message.message,
                    message.m_colour,
                    message.sender,
                    message.s_colour,
                    message.icondata,
                    message.icondatabg
                )
            else
                chatline.history_index = nil
                chatline:SetChatData(ChatTypes.Message, 0)
            end
        end,
        function(test_scroll_pos, current_scroll_pos)
            self.min_scroll = true
            self.max_scroll = false

            if test_scroll_pos > 0 then
                return false
            end

            self.min_scroll = false

            if test_scroll_pos > current_scroll_pos then
                --we only need to verify when scrolling up, scrolling down is always fine.
                return true
            end

            local minimum_line = math.abs(test_scroll_pos) + 1
            local current_line = 1
            local history_index = 1

            self.max_scroll = true

            while current_line < minimum_line + CHAT_QUEUE_VISUAL_SIZE do
                local next_message = self:GetChatLinesForMessage(history_index)
                if not next_message then return false end
                current_line = current_line + next_message
                history_index = history_index + 1
            end

            self.max_scroll = not self:GetChatLinesForMessage(history_index)
            return true
        end,
        -1050/2,
        -(row_height * CHAT_QUEUE_VISUAL_SIZE + 6)/2 - row_height * 0.5,
        1050,
        row_height * CHAT_QUEUE_VISUAL_SIZE + 6
    ))
    self.chat_scroll_list:SetPosition(35, -624 + chat_queue_offset)

    self.chat_scroll_list.generate_data_fn = function(current_scroll_pos)
        if self.last_scroll_pos == current_scroll_pos and not self.history_updated then
            return
        end
        self.last_scroll_pos = current_scroll_pos

        local current_chat_data = {}

        local minimum_line = math.abs(current_scroll_pos) + 1
        local current_line = 1
        local history_index = 1

        local chatlines_to_skip = 0

        while current_line < minimum_line do
            local next_message = self:GetChatLinesForMessage(history_index)
            if not next_message then break end

            chatlines_to_skip = current_line - minimum_line
            current_line = current_line + next_message

            if current_line <= minimum_line then
                history_index = history_index + 1
            end
        end

        if current_line < minimum_line then
            return current_chat_data
        elseif current_line == minimum_line then
            chatlines_to_skip = 0
        end

        local i = 1
        while i <= CHAT_QUEUE_SIZE do
            local message_data = ChatHistory:GetChatMessageAtIndex(history_index)

            if message_data then
                local messages = SplitMultilineString(self, message_data.message)

                for j = #messages + chatlines_to_skip, 1, -1 do
                    local first = j == 1
                    if i <= CHAT_QUEUE_SIZE then
                        current_chat_data[i] =
                        {
                            history_index = history_index,
                            type = message_data.type,
                            message = messages[j],
                            m_colour = message_data.m_colour,
                            sender = first and message_data.sender or nil,
                            s_colour = first and message_data.s_colour or nil,
                            icondata = first and message_data.icondata or nil,
                            icondatabg = first and message_data.icondatabg or nil
                        }
                    end
                    i = i + 1
                end
            else
                i = i + 1
            end

            chatlines_to_skip = 0
            history_index = history_index + 1
        end
        return current_chat_data
    end

    self.chat_scroll_list:Scroll(1, true)

    self:RefreshWidgets(true)
end

function ScrollableChatQueue:IsChatOpen()
    return self.chat_open
end

function ScrollableChatQueue:Kill()
    ScrollableChatQueue._base.Kill(self)
    ChatHistory:RemoveChatHistoryListener(self.chat_listener)
	self.chat_listener = nil
end

function ScrollableChatQueue:PushMessage()
    local lines = self:GetChatLinesForMessage(1)
    local deleted_message_lines = self:GetChatLinesForMessage(ChatHistory.MAX_CHAT_HISTORY + 1)
    if self.max_scroll and deleted_message_lines then
        self.chat_scroll_list:Scroll(deleted_message_lines - lines, true)
    elseif not self.min_scroll then
        self.chat_scroll_list:Scroll(-lines, true)
    end

    self:RefreshWidgets(true)
end

function ScrollableChatQueue:CalculateChatAlpha(history_index)
    return history_index and 1.0 or 0.0
end

function ScrollableChatQueue:RefreshWidgets(force_update)
    self.history_updated = force_update
    self.chat_scroll_list:RefreshView()
    self.history_updated = nil
end

function ScrollableChatQueue:OnChatControl(control, down)
    return self.chat_scroll_list:OnChatControl(control, down)
end

return ScrollableChatQueue
