local Widget = require "widgets/widget"
local ChatLine = require "widgets/redux/chatline"

local CHAT_QUEUE_SIZE = 7
local CHAT_EXPIRE_TIME = 10.0
local CHAT_FADE_TIME = 2.0

local function SplitMultilineString(self, message)
    -- HACK HACK HACK! Since the chat window is single-line only, we break this into multiple lines... by using
    -- an invisible text box that wraps the text for us!
    local textbox = require("widgets/text")(self.chat_font, self.chat_size)
    textbox:SetMultilineTruncatedString(message, 100, self.message_width, self.message_max_chars, false)
    local messages = string.split(textbox:GetString(), "\n")
    textbox:Kill()

    return messages
end

local ChatQueue = Class(Widget, function(self)
    Widget._ctor(self, "ChatQueue")

    self.message_alpha_time = {}
    self.widget_rows = {}

    self.chat_font = TALKINGFONT--DEFAULTFONT --UIFONT
    self.chat_size = 30 --22
    self.user_width = 160
    self.user_max_chars = 28
    self.message_width = 850
    self.message_max_chars = 150

    local row_height = self.chat_size + 2
    for i = 1, CHAT_QUEUE_SIZE do
        local chatline = self:AddChild(ChatLine(self.chat_font, self.user_width, self.user_max_chars, self.message_width, self.message_max_char))
        chatline:SetPosition(0, -624 + (i - 1) * row_height)
        self.widget_rows[i] = chatline
    end

    self:StartUpdating()

    self.chat_listener = function(chat_message)
        self:PushMessage()
    end

    ChatHistory:AddChatHistoryListener(self.chat_listener)
end)

function ChatQueue:OnHide()
    self:StopUpdating()
end

function ChatQueue:OnShow()
    self:StartUpdating()
end

function ChatQueue:Kill()
    ChatQueue._base.Kill(self)
    ChatHistory:RemoveChatHistoryListener(self.chat_listener)
	self.chat_listener = nil
end

function ChatQueue:OnUpdate()
    self:RefreshWidgets()
end

function ChatQueue:PushMessage()
    for i = CHAT_QUEUE_SIZE, 2, -1 do
        self.message_alpha_time[i] = self.message_alpha_time[i-1]
    end
    self.message_alpha_time[1] = GetStaticTime() + CHAT_EXPIRE_TIME

    self:RefreshWidgets(true)
end

function ChatQueue:CalculateChatAlpha(history_index)
    if history_index == nil then
        return 0.0
    end

    local expire_time = self.message_alpha_time[history_index]
    if not expire_time then
        return 0.0
    end

    local current_time = GetStaticTime()

    local time_past_expiring = current_time - expire_time
    if time_past_expiring < 0 then
        return 1.0
    elseif time_past_expiring < CHAT_FADE_TIME then
        local alpha_fade = ( CHAT_FADE_TIME - time_past_expiring ) / CHAT_FADE_TIME
        return alpha_fade
    end
    return 0.0
end

function ChatQueue:RefreshWidgets(full_update)
    if full_update then
        local history_index = 1

        local i = 1
        while i <= CHAT_QUEUE_SIZE do
            local message_data = ChatHistory:GetChatMessageAtIndex(history_index)

            if message_data then
                local messages = SplitMultilineString(self, message_data.message)

                for j = #messages, 1, -1 do
                    local first = j == 1
                    local chatline = self.widget_rows[i]
                    chatline.history_index = history_index
                    chatline:SetChatData(
                        message_data.type,
                        self:CalculateChatAlpha(chatline.history_index),
                        messages[j],
                        message_data.m_colour,
                        first and message_data.sender or nil,
                        first and message_data.s_colour or nil,
                        first and message_data.icondata or nil
                    )
                    i = i + 1
                    if i > CHAT_QUEUE_SIZE then
                        return
                    end
                end
            else
                self.widget_rows[i]:SetChatData(ChatTypes.Message, 0)
                i = i + 1
            end

            history_index = history_index + 1
        end
    else
        for i, chatline in ipairs(self.widget_rows) do
            chatline:UpdateAlpha(self:CalculateChatAlpha(chatline.history_index))
        end
    end

end

return ChatQueue
