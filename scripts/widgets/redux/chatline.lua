local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local SkinsItemPopUp = require "screens/skinsitempopup"

local chat_size = 30
local focus_chat_size = chat_size * 1.167

local ChatLine = Class(Widget, function(self, chat_font, user_width, user_max_chars, message_width, message_max_chars)
    Widget._ctor(self, "ChatLine")

    self.root = self:AddChild(Widget("root"))

    self.type = ChatTypes.Message

    self.user_width = user_width
    self.user_max_chars = user_max_chars
    self.message_width = message_width
    self.message_max_chars = message_max_chars

    --MESSAGES--

    self.message = self.root:AddChild(Text(chat_font, chat_size))
    self.message:SetHAlign(ANCHOR_LEFT)

    self.user = self.root:AddChild(Text(chat_font, chat_size))
    self.user:SetHAlign(ANCHOR_RIGHT)

    --SKINS--

    self.skin_btn = self.root:AddChild(ImageButton())
    self.skin_btn.text:SetHAlign(ANCHOR_LEFT)
    self.skin_btn:SetFont(chat_font)
    self.skin_btn:SetTextSize(chat_size)
    self.skin_btn:SetImageNormalColour(0, 0, 0, 0)
    self.skin_btn:SetTextColour(1, 1, 1, 1)
    self.skin_btn:SetTextFocusColour(1, 1, 1, 1)
    self.skin_btn:SetOnClick(function()
        if self.skin_data == nil then
            print("### NO skin data received")
            return
        end
        TheFrontEnd:PushScreen(SkinsItemPopUp(unpack(self.skin_data)))
    end)
    self.skin_btn:SetControl(CONTROL_PRIMARY) --mouse left click only!

    self.skin_txt = self.skin_btn:AddChild(Text(chat_font, chat_size))
    self.skin_txt:SetPosition(0, 2)
    self.skin_txt:SetColour(1, 0, 0, 1)

    --ICONS--

    self.flair = self.root:AddChild(TEMPLATES.ChatFlairBadge())
    self.flair:SetPosition(-315, -12.5)

    self.announcement = self.root:AddChild(TEMPLATES.AnnouncementBadge())
    self.announcement:SetPosition(-315, -12.5)

    self.systemmessage = self.root:AddChild(TEMPLATES.SystemMessageBadge())
    self.systemmessage:SetPosition(-315, -12.5)

    self.chattermessage = self.root:AddChild(TEMPLATES.ChatterMessageBadge())
    self.chattermessage:SetPosition(-315, -12.5)
end)

function ChatLine:UpdateSkinAnnouncementPosition()
    local w1, h1 = self.skin_btn.text:GetRegionSize()
    self.skin_btn:SetPosition(w1 * 0.5 - 290, 0)

    local w2, h2 = self.skin_txt:GetRegionSize()
    self.skin_txt:SetPosition(((w1 + w2) * 0.5), 0)

    self.skin_btn.image:SetPosition(w2 * 0.5, 0, 0)
    self.skin_btn:ForceImageSize(w1 + w2, math.max(h1, h2))
end

function ChatLine:UpdateSkinAnnouncementSize(size)
    self.skin_btn:SetTextSize(size)
    self.skin_txt:SetSize(size)
    self:UpdateSkinAnnouncementPosition()
end

function ChatLine:OnGainFocus()
    ChatLine._base.OnGainFocus(self)
    self:UpdateSkinAnnouncementSize(focus_chat_size)
end

function ChatLine:OnLoseFocus()
    ChatLine._base.OnLoseFocus(self)
    self:UpdateSkinAnnouncementSize(chat_size)
end

function ChatLine:UpdateAlpha(alpha)
    if alpha > 0 then
        self.root:Show()
        if self.type == ChatTypes.SkinAnnouncement then
            self.message:UpdateAlpha(0)
            self.user:UpdateAlpha(0)

            self.skin_btn.text:UpdateAlpha(alpha)
            self.skin_txt:UpdateAlpha(alpha)
        else
            self.skin_btn.text:UpdateAlpha(0)
            self.skin_txt:UpdateAlpha(0)

            self.message:UpdateAlpha(alpha)
            self.user:UpdateAlpha(alpha)
        end


        if self.type == ChatTypes.SystemMessage then
            self.systemmessage:SetAlpha(alpha)
        elseif self.type == ChatTypes.Announcement or self.type == ChatTypes.SkinAnnouncement then
            self.announcement:SetAlpha(alpha)
        elseif self.type == ChatTypes.Message then
            self.flair:SetAlpha(alpha)
        elseif self.type == ChatTypes.ChatterMessage then
            self.chattermessage:SetAlpha(alpha)
        end
    else
        self.root:Hide()
    end
end

function ChatLine:SetChatData(type, alpha, message, m_colour, sender, s_colour, icondata, icondatabg)
    self.type = type
    self.skin_data = nil

    if alpha > 0 then
        self.root:Show()
        if self.type == ChatTypes.SkinAnnouncement then
            self.message:Hide()
            self.user:Hide()

            self.skin_btn:Show()
            self.skin_txt:Show()

            local skin_name = message
            local user_colour = s_colour
            local user_name = sender

            self.skin_data = {skin_name, user_name, user_colour}

            self.skin_btn:SetText(string.format(STRINGS.UI.NOTIFICATION.NEW_SKIN_ANNOUNCEMENT, user_name))
            self.skin_btn.text:UpdateAlpha(alpha)

            local r, g, b = unpack(GetColorForItem(skin_name))
            self.skin_txt:SetColour(r, g, b, alpha)
            self.skin_txt:SetString(GetSkinName(skin_name))

            self:UpdateSkinAnnouncementPosition()
        else
            self.skin_btn:Hide()
            self.skin_txt:Hide()

            self.message:Show()
            self.user:Show()

            self.message:SetTruncatedString(message, self.message_width, self.message_max_chars, true)
            self.message:SetPosition(self.message:GetRegionSize() * 0.5 - 290, 0)
            local r,g,b = unpack(m_colour)
            self.message:SetColour(r, g, b, alpha)

            if sender then
                self.user:Show()
                self.user:SetTruncatedString(sender, self.user_width, self.user_max_chars, true)
                self.user:SetPosition(self.user:GetRegionSize() * -0.5 - 330, 0)

                r,g,b = unpack(s_colour)
                self.user:SetColour(r, g, b, alpha)
            else
                self.user:Hide()
            end
        end



        self.flair:Hide()
        self.announcement:Hide()
        self.systemmessage:Hide()
        self.chattermessage:Hide()
        if self.type == ChatTypes.SystemMessage then
            self.systemmessage:SetAlpha(alpha)
        elseif self.type == ChatTypes.Announcement then
            self.announcement:SetAnnouncement(icondata)
            self.announcement:SetAlpha(alpha)
        elseif self.type == ChatTypes.SkinAnnouncement then
            self.announcement:SetAnnouncement("item_drop")
            self.announcement:SetAlpha(alpha)
        elseif self.type == ChatTypes.Message then
            self.flair:SetFlair(icondata)
            self.flair:SetAlpha(alpha)
        elseif self.type == ChatTypes.ChatterMessage then
            self.chattermessage:SetFlair(icondata)
            self.chattermessage:SetBGIcon(icondatabg)
            self.chattermessage:SetAlpha(alpha)
        --elseif message_data.type == ChatTypes.Emote then --emotes don't have an icon.
        end
    else
        self.root:Hide()
    end
end

return ChatLine