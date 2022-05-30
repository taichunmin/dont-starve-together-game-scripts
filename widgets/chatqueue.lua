local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TEMPLATES = require("widgets/redux/templates")

local CHAT_QUEUE_SIZE = 7
local CHAT_EXPIRE_TIME = 10.0
local CHAT_FADE_TIME = 2.0
local CHAT_LINGER_TIME = 1.0

function calcChatAlpha( current_time, expire_time )
    local time_past_expiring = current_time - expire_time
    if time_past_expiring > 0.0 then
        if time_past_expiring < CHAT_FADE_TIME then
            local alpha_fade = ( CHAT_FADE_TIME - time_past_expiring ) / CHAT_FADE_TIME
            return alpha_fade
        end
        return 0.0
    end
    return 1.0
end


local ChatQueue = Class(Widget, function(self, owner)
    Widget._ctor(self, "ChatQueue")

    self.owner = owner

    self.chat_queue_data = {}

    self.widget_rows = {}

    self.chat_font = TALKINGFONT--DEFAULTFONT --UIFONT
    self.chat_size = 30 --22
    self.chat_height = 50
    self.user_width = 160
    self.user_max_chars = 28
    self.message_width = 850
    self.message_max_chars = 150

    for i = 1, CHAT_QUEUE_SIZE do
        --setup widgets and put in a row
        self.widget_rows[i] = {}

        local message_widget = self:AddChild(Text(self.chat_font, self.chat_size))
        message_widget:SetHAlign(ANCHOR_LEFT)
        self.widget_rows[i].message = message_widget

        local user_widget = self:AddChild(Text(self.chat_font, self.chat_size))
        user_widget:SetHAlign(ANCHOR_RIGHT)
        self.widget_rows[i].user = user_widget

        local y = -400 - i * (self.chat_size + 2)
        local flair_widget = self:AddChild(TEMPLATES.ChatFlairBadge())
        flair_widget:SetPosition(-315, y-12.5)
        self.widget_rows[i].flair = flair_widget

        --setup initial chat queue data
        self.chat_queue_data[i] = {}
        self.chat_queue_data[i].expire_time = 0
        self.chat_queue_data[i].username = ""
        self.chat_queue_data[i].message = ""
        self.chat_queue_data[i].colour = {1,1,1,1}
        self.chat_queue_data[i].whisper = false
        self.chat_queue_data[i].nolabel = false
        self.chat_queue_data[i].profileflair = nil
    end

    self:RefreshWidgets()

    self:StartUpdating()
end)

function ChatQueue:OnUpdate()
    local current_time = GetTime()
    local is_chat_open = ThePlayer ~= nil and ThePlayer.HUD ~= nil and ThePlayer.HUD:IsChatInputScreenOpen() -- If the chat input screen is open, reset the timer to fade out soon

    for i = 1, CHAT_QUEUE_SIZE do
        local row_data = self.chat_queue_data[i]

        if is_chat_open then
            if row_data.expire_time < current_time then
                row_data.expire_time = current_time
            end
        end

        if row_data.expire_time > 0 then
            local time_past_expiring = current_time - row_data.expire_time
            if time_past_expiring > CHAT_FADE_TIME then
                row_data.expire_time = 0
            end
        end
    end

    self:RefreshWidgets()
end

--For ease of overriding in mods
function ChatQueue:GetDisplayName(name, prefab)
    return name ~= "" and name or STRINGS.UI.SERVERADMINSCREEN.UNKNOWN_USER_NAME
end

function ChatQueue:DisplaySystemMessage(message)
    if type(message) == "string" then
        message = {message}
    end

    for i,line in ipairs(message) do
        -- HACK HACK HACK! Since the chat window is single-line only, we break this into multiple lines... by using
        -- an invisible text box that wraps the text for us!
        local textbox = require("widgets/text")(self.chat_font, self.chat_size)
        textbox:SetMultilineTruncatedString(line, 100, self.message_width, self.message_max_chars, false)
        local splitlines = string.split(textbox:GetString(), "\n")
        textbox:Kill()

        for i,splitline in ipairs(splitlines) do
            self:PushMessage("", splitline, WHITE, false, false, nil) --nil for profileflair
        end
    end
end

function ChatQueue:DisplayEmoteMessage(name, prefab, message, colour, whisper)
    message = self:GetDisplayName(name, prefab).." "..message
    self:PushMessage("", message, colour, whisper, true, nil) --nil for profileflair
end

function ChatQueue:OnMessageReceived(name, prefab, message, colour, whisper, profileflair)
    --Make sure that we use the default profile flair is the user hasn't set one.
    if profileflair == nil then
        profileflair = "default"
    end

    -- Process Chat username
    self:PushMessage(self:GetDisplayName(name, prefab), message, colour, whisper, false, profileflair)
end

function ChatQueue:PushMessage(username, message, colour, whisper, nolabel, profileflair)
    -- Shuffle upwards
    for i = 1, CHAT_QUEUE_SIZE - 1 do
        self.chat_queue_data[i] = shallowcopy( self.chat_queue_data[i+1] )
    end

    --Set this new message into the chat queue data
    self.chat_queue_data[CHAT_QUEUE_SIZE].expire_time = GetTime() + CHAT_EXPIRE_TIME
    self.chat_queue_data[CHAT_QUEUE_SIZE].username = username
    self.chat_queue_data[CHAT_QUEUE_SIZE].message = message
    self.chat_queue_data[CHAT_QUEUE_SIZE].colour = colour
    self.chat_queue_data[CHAT_QUEUE_SIZE].whisper = whisper
    self.chat_queue_data[CHAT_QUEUE_SIZE].nolabel = nolabel
    self.chat_queue_data[CHAT_QUEUE_SIZE].profileflair = profileflair

    self:RefreshWidgets()
end

function ChatQueue:RefreshWidgets()
    local current_time = GetTime()

    --apply the chat data to the widgets
    for i = 1, CHAT_QUEUE_SIZE do
        local row_data = self.chat_queue_data[i]

        local y = -400 - i * (self.chat_size + 2)
        local alpha_fade = calcChatAlpha(current_time, row_data.expire_time)

        if alpha_fade > 0 then
            local c = { row_data.colour[1], row_data.colour[2], row_data.colour[3], alpha_fade }

            local msg = self.widget_rows[i].message
            msg:Show()
            msg:SetTruncatedString(row_data.message, self.message_width, self.message_max_chars, true)
            local msg_width = msg:GetRegionSize()
            msg:SetPosition(msg_width * 0.5 - 290, y)
            if row_data.nolabel then
                msg:SetColour(c)
            else
                if row_data.whisper then
                    local r,g,b = unpack(WHISPER_COLOR)
                    msg:SetColour(r,g,b, alpha_fade)
                else
                    local r,g,b = unpack(SAY_COLOR)
                    msg:SetColour(r,g,b, alpha_fade)
                end
            end

            local user = self.widget_rows[i].user
            local user_width = 0
            if row_data.nolabel then
                user:Hide()
            else
                user:Show()
                if row_data.whisper then
                    user:SetTruncatedString(STRINGS.UI.CHATINPUTSCREEN.WHISPER_DESIGNATOR.." "..row_data.username, self.user_width, self.user_max_chars, true)
                else
                    user:SetTruncatedString(row_data.username, self.user_width, self.user_max_chars, true)
                end
                user_width = user:GetRegionSize()
                user:SetPosition(user_width * -.5 - 330, y)
                user:SetColour(c)
            end

            local flair = self.widget_rows[i].flair
            if row_data.nolabel then
                flair:Hide()
            else
                flair:Show()
                flair:SetFlair(row_data.profileflair)
                flair:SetAlpha(alpha_fade)
            end
        else
            self.widget_rows[i].user:Hide()
            self.widget_rows[i].message:Hide()
            self.widget_rows[i].flair:Hide()
        end
    end
end


return ChatQueue
