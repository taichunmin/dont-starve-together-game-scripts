local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Button = require "widgets/button"
local SkinsItemPopUp = require "screens/skinsitempopup"

local function GetIconX(w)
    return w ~= nil and -.5 * w - 25 or -25
end

--base class for imagebuttons and animbuttons.
local SkinAnnouncement = Class(Widget, function(self, font, size)
    Widget._ctor(self, "SkinAnnouncement")

    self.root = self:AddChild(Widget("Root"))

    self.img_btn = self.root:AddChild(ImageButton())
    self.img_btn.text:SetHAlign(ANCHOR_LEFT)

    self.skin_txt = self.img_btn:AddChild(Text(font or UIFONT, size or 30))
    self.skin_txt:SetPosition(0, 2)

    self.icon = self:AddChild(Image("images/button_icons.xml", "item_drop.tex"))
    self.icon:SetScale(.85)
    self.icon:SetPosition(-5, 5)

    self.icon.bg = self.icon:AddChild(Image("images/button_icons.xml", "circle.tex"))
    self.icon.bg:SetScale(1.1)
    self.icon.bg:SetPosition(0,-4)
    self.icon.bg:MoveToBack()

    self.font = font or UIFONT
    self:SetGeneralFont(font or UIFONT)

    self.size = size or 30
    self:SetGeneralSize(self.size)

    self.focus_size = 35

    self.img_btn:SetImageNormalColour(0, 0, 0, 0)
    self:ClearText()

    self.img_btn:SetTextColour(1, 1, 1, 1)
    self.img_btn:SetTextFocusColour(1, 1, 1, 1)

    self:SetSkinTextColour(1, 0, 0, 1)

    self:UpdateSkinTextPosition()
    self.lifetime = 0
    self.fadetime = 0

    self.general_alpha = 1

    self.img_btn:SetOnClick(function()
        if self.skin_name == nil then
            return
        end
        TheFrontEnd:PushScreen(SkinsItemPopUp(self.skin_name, self.user_name, self.user_colour))
        self:Hide()
    end)

    -- Literally only used to identify skin announcements on the eventannouncer.lua
    self.skin_announcement = true
end)

function SkinAnnouncement:OnUpdate(dt)
    self.lifetime = self.lifetime - dt
    if self.lifetime < 0 then
        local time_past_expiring = math.abs(self.lifetime)
        local alpha_fade = (self.fadetime - time_past_expiring) / self.fadetime
        self:SetGeneralAlpha(alpha_fade)

        if (alpha_fade <= 0) then
            self:StopUpdating()
            self:Hide()
        end
    end
end

function SkinAnnouncement:OnGainFocus()
    SkinAnnouncement._base.OnGainFocus(self)
    self:SetGeneralSize(self.focus_size)
end

function SkinAnnouncement:OnLoseFocus()
    SkinAnnouncement._base.OnLoseFocus(self)
    self:SetGeneralSize(self.size)
end

-- Do we need those?
function SkinAnnouncement:OnEnable()
    self.img_btn:Enable()
    self.skin_txt:Enable()
end

function SkinAnnouncement:OnDisable()
    self.img_btn:Disable()
    self.skin_txt:Disable()
end

function SkinAnnouncement:UpdateSkinTextPosition()
    local w1, h1 = self.img_btn.text:GetRegionSize()
    local w2, h2 = self.skin_txt:GetRegionSize()

    self.skin_txt:SetPosition(w1/2 + w2/2, 0)

    self.img_btn.image:SetPosition(w2/2, 0, 0)
    self.img_btn:ForceImageSize(w1 + w2, h1 + h2)

    local pos = self.img_btn:GetPosition()
    --local pos = self.img_btn.image:GetPosition()
    self.img_btn:SetPosition(-(w2/2), pos.y, pos.z)

    local w = self:GetTotalRegionSize()
    self.icon:SetPosition(GetIconX(w), self.icon:GetPosition().y)
end

function SkinAnnouncement:SetGeneralFont(font)
    if not font then return end

    self.img_btn:SetFont(font)
    self.skin_txt:SetFont(font)

    self:UpdateSkinTextPosition()
end

function SkinAnnouncement:SetGeneralSize(size)
    if not size then return end

    self.img_btn:SetTextSize(size)
    self.skin_txt:SetSize(size)

    self:UpdateSkinTextPosition()
end

function SkinAnnouncement:ClearText()
    self.img_btn:SetText("")
    self.skin_txt:SetString("")

    self:UpdateSkinTextPosition()
end

function SkinAnnouncement:GetText()
    local msg_txt = self.img_btn.text:GetString() or "NO MESSAGE TEXT"
    local skin_txt = self.skin_txt:GetString() or " NO SKIN TEXT"
    return msg_txt .. skin_txt
end

function SkinAnnouncement:SetSkinTextColour(r, g, b, a)
    self.skin_txt:SetColour(r, g, b, a)
end

function SkinAnnouncement:SetSkinText(text)
    if not text then return end
    self.skin_txt:SetString(text)
    self:UpdateSkinTextPosition()
end

function SkinAnnouncement:SetMessageText(text)
    if not text then return end
    self.img_btn:SetText(text)
    self:UpdateSkinTextPosition()
end

function SkinAnnouncement:SetSkinAnnouncementInfo(user_name, user_colour, skin_name, alpha, lifetime, fadetime)
    if not skin_name or not user_name then return end

    self.skin_name = skin_name
    self.user_colour = user_colour
    self.user_name = user_name
    self:SetMessageText(string.format(STRINGS.UI.NOTIFICATION.NEW_SKIN_ANNOUNCEMENT, user_name))

    self:SetSkinTextColour(GetColorForItem(skin_name))
    self:SetSkinText(GetSkinName(skin_name))

    self.lifetime = lifetime or 7
    self.fadetime = fadetime or 2

    self:SetGeneralAlpha(alpha or 1)
    self:Show()
    self:StartUpdating()
end

function SkinAnnouncement:CopyInfo(source)
    if source == nil then
        return
    end
    self:SetSkinAnnouncementInfo(source.user_name, source.user_colour, source.skin_name, source.general_alpha, source.lifetime, source.fadetime)
end

function SkinAnnouncement:SetGeneralAlpha(alpha)
    local skin_colour = self.skin_txt:GetColour()
    skin_colour[4] = alpha
    self:SetSkinTextColour(skin_colour)

    local msg_colour = self.img_btn.text:GetColour()
    msg_colour[4] = alpha
    self.img_btn.text:SetColour(msg_colour)

    self.icon:SetTint(1,1,1, alpha)
    self.icon.bg:SetTint(1,1,1, alpha)

    self.general_alpha = alpha
end

function SkinAnnouncement:GetTotalRegionSize()
    local w1, h1 = self.img_btn.text:GetRegionSize()
    local w2, h2 = self.skin_txt:GetRegionSize()

    return w1 + w2, h1 + h2
end

return SkinAnnouncement
