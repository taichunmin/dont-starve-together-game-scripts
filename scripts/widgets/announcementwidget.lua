local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"

local function GetIconX(w)
    return w ~= nil and -.5 * w - 25 or -25
end

--base class for imagebuttons and animbuttons.
local AnnouncementWidget = Class(Widget, function(self, font, size, colour)
    Widget._ctor(self, "AnnouncementWidget")

    self.root = self:AddChild(Widget("Root"))
    self.text = self.root:AddChild(Text(font or UIFONT, size or 30))
    self.text:SetPosition(0, 2)

    self.icon = self:AddChild(Image("images/button_icons.xml", "announcement.tex"))
    self.icon:SetScale(.85)
    self.icon:SetPosition(-5, 5)

    self.icon.bg = self.icon:AddChild(Image("images/button_icons.xml", "circle.tex"))
    self.icon.bg:SetScale(1.1)
    self.icon.bg:SetPosition(0,-4)
    self.icon.bg:MoveToBack()

    self.font = font or UIFONT
    self.size = size or 30
    self.colour = colour or {1,1,1,1}

    self.announce_type = ""
    self.lifetime = 0
    self.fadetime = 0

end)

function AnnouncementWidget:OnUpdate(dt)
    self.lifetime = self.lifetime - dt
    if self.lifetime < 0 then
        local time_past_expiring = math.abs(self.lifetime)
        local alpha_fade = (self.fadetime - time_past_expiring) / self.fadetime
        self:SetAlpha(alpha_fade)
        if (alpha_fade <= 0) then
            self:StopUpdating()
            self:Hide()
        end
    end
end

function AnnouncementWidget:UpdateIconPosition()
    local w = self.text:GetRegionSize()
    self.icon:SetPosition(w * -.5 - 25, self.icon:GetPosition().y)
end

function AnnouncementWidget:SetFont(font)
    if not font then return end
    self.font = font
    self.text:SetFont(font)
    self:UpdateIconPosition()
end

function AnnouncementWidget:SetSize(size)
    if not size then return end
    self.size = size
    self.text:SetSize(size)
    self:UpdateIconPosition()
end

function AnnouncementWidget:SetTextColour(r,g,b,a)
    local colour = {}
    if type(r) == "number" then
        colour = {r,g,b,a}
    else
        colour = r
    end

    self.colour = colour

    self.text:SetColour(colour)
end

function AnnouncementWidget:ClearText()
    self.text:SetString("")
    self:UpdateIconPosition()
end

function AnnouncementWidget:SetText(string)
    if not string then return end
    self.text:SetString(string)
    self:UpdateIconPosition()
end

function AnnouncementWidget:GetText()
    return self.text:GetString() or ""
end

function AnnouncementWidget:SetIcon(announce_type)
    if announce_type then
        local icon_info = ANNOUNCEMENT_ICONS[announce_type]
        self.icon:SetTexture(icon_info.atlas or "images/button_icons.xml", icon_info.texture or "announcement.tex")
        self.announce_type = announce_type
    end
end

function AnnouncementWidget:SetAlpha(alpha)
    if not alpha then return end
    local current_colour = self.colour
    current_colour[4] = alpha
    self.text:SetColour(current_colour)

    self.colour = current_colour

    self.icon:SetTint(1, 1, 1, alpha)
    self.icon.bg:SetTint(1, 1, 1, alpha)
end

function AnnouncementWidget:GetAlpha()
    local current_colour = self.colour
    return current_colour[4] or 0
end

function AnnouncementWidget:CopyInfo(announcement_info)
    if not announcement_info then return end

    local announcement = announcement_info:GetText()
    local announce_type = announcement_info.announce_type
    local colour = announcement_info.colour
    local lifetime = announcement_info.lifetime
    local fadetime = announcement_info.fadetime

    self:SetAnnouncement(announcement, announce_type, colour, lifetime, fadetime)
    self:SetSize(announcement_info.size)
    self:SetFont(announcement_info.font)
end

function AnnouncementWidget:SetAnnouncement(announcement, announce_type, colour, lifetime, fadetime)
    if not announcement then return end

    self:SetText(announcement)
    self:SetIcon(announce_type or "default")

    self:SetTextColour(colour or {1,1,1,1})
    self:SetAlpha(colour[4] or 1)

    self.lifetime = lifetime or 7
    self.fadetime = fadetime or 2

    self:Show()

    self:StartUpdating()

end

return AnnouncementWidget