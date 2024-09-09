local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local SkinAnnouncement = require "widgets/skinannouncement"
local AnnouncementWidget = require "widgets/announcementwidget"

ANNOUNCEMENT_LIFETIME = 7
ANNOUNCEMENT_FADE_TIME = 2
ANNOUNCEMENT_QUEUE_SIZE = 10

-- TODO: refactor this thing, it's kinda messy since we added clickable announcements.
local EventAnnouncer = Class(Widget, function(self, owner)
    Widget._ctor(self, "EventAnnouncer")
    self.regular_announcements = {}
    self.skin_announcements = {}
    self.active_announcements = {}

    self.message_font = UIFONT
    self.message_size = 30

    for i = 1,ANNOUNCEMENT_QUEUE_SIZE do
        -- Normal announcements
        local message_widget = self:AddChild(AnnouncementWidget(self.message_font, self.message_size))

        message_widget.text:SetVAlign(ANCHOR_MIDDLE)
        message_widget.text:SetHAlign(ANCHOR_MIDDLE)
        message_widget:SetPosition(0, -15 - (i * (self.message_size+2)))

        message_widget:ClearText()
        message_widget:Hide()
        self.regular_announcements[i] = message_widget

        -- Clickable skin announcements
        local skin_announcement = self:AddChild(SkinAnnouncement(self.message_font, self.message_size))

        skin_announcement.skin_txt:SetVAlign(ANCHOR_MIDDLE)
        skin_announcement.skin_txt:SetHAlign(ANCHOR_MIDDLE)
        skin_announcement:SetPosition(0, -15 - (i * (self.message_size+2)))

        skin_announcement:ClearText()
        skin_announcement:Hide()
        self.skin_announcements[i] = skin_announcement
    end
end)

-- Move things up here
function EventAnnouncer:DoShuffleUp(i)
    if i > ANNOUNCEMENT_QUEUE_SIZE or not self.active_announcements[i] then
        return
    end

    if not self.active_announcements[i +1] then
        self.active_announcements[i]:Hide()
        self.active_announcements[i] = nil
        if #self.active_announcements <= 0 then
            self:StopUpdating()
        end
        return
    end

    if self.active_announcements[i].skin_announcement and not self.active_announcements[i+1].skin_announcement then
        self.active_announcements[i]:Hide()
        self.active_announcements[i] = self.regular_announcements[i]
    elseif not self.active_announcements[i].skin_announcement and self.active_announcements[i+1].skin_announcement then
        self.active_announcements[i]:Hide()
        self.active_announcements[i] = self.skin_announcements[i]
    end

    self.active_announcements[i]:CopyInfo(self.active_announcements[i+1])
    self:DoShuffleUp(i+1)

end

-- Only called when #self.active_announcements > 0
function EventAnnouncer:OnUpdate()
    for i=1,#self.active_announcements do
        --.shown for immediate visibility instead of inherited
        if not self.active_announcements[i].shown then
            self:DoShuffleUp(i)
            break
        end
    end
end


local function GetIndex( self )
    -- Find the next spot
    local index = -1
    while index == -1 do
        for i = 1,ANNOUNCEMENT_QUEUE_SIZE do
            if not self.active_announcements[i] then
                index = i
                break
            end
        end
        -- If we have no more empty spots we force things to move up
        if index == -1 then
            self:DoShuffleUp(1)
        end
    end
    return index
end

-- Shows a regular non clickable announcement
function EventAnnouncer:ShowNewAnnouncement(announcement, colour, announce_type)
    if not announcement then return end

    if not announce_type or announce_type == "" then
        announce_type = "default"
    end

    local index = GetIndex( self )

    if not colour then
        colour = {1,1,1,1}
    end

    -- Add our new entry
    self.regular_announcements[index]:SetAnnouncement(announcement, announce_type, colour, ANNOUNCEMENT_LIFETIME, ANNOUNCEMENT_FADE_TIME)
    self.active_announcements[index] = self.regular_announcements[index]
    self:StartUpdating()
end

-- Shows a clickable skin announcement
function EventAnnouncer:ShowSkinAnnouncement(user_name, user_colour, skin_name)
    if user_name == nil or user_colour == nil or user_name == nil then
        return
    end

    local index = GetIndex(self)

    self.skin_announcements[index]:SetSkinAnnouncementInfo(user_name, user_colour, skin_name, 1, ANNOUNCEMENT_LIFETIME, ANNOUNCEMENT_FADE_TIME)
    self.active_announcements[index] = self.skin_announcements[index]

    self:StartUpdating()
end

-- If source param is provided, then death announcement will be for living > ghost. If not, it will be for ghost/final death.
function GetNewDeathAnnouncementString(theDead, source, pkname, sourceispet)
    if not theDead or not source then return "" end

    local message = ""
    if source and not theDead:HasTag("playerghost") then
        if pkname ~= nil then
            local petname = sourceispet and STRINGS.NAMES[string.upper(source)] or nil
            if petname ~= nil then
                message = theDead:GetDisplayName().." "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." "..string.format(STRINGS.UI.HUD.DEATH_PET_NAME, pkname, petname)
            else
                message = theDead:GetDisplayName().." "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." "..pkname
            end
        elseif table.contains(GetActiveCharacterList(), source) then
            message = theDead:GetDisplayName().." "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." "..FirstToUpper(source)
        else
            source = string.upper(source)
            if source == "NIL" then
                if theDead == "WAXWELL" then
                    source = "CHARLIE"
                else
                    source = "DARKNESS"
                end
            elseif source == "UNKNOWN" then
                source = "SHENANIGANS"
            elseif source == "MOOSE" then
                if math.random() < .5 then
                    source = "MOOSE1"
                else
                    source = "MOOSE2"
                end
            end
            source = STRINGS.NAMES[source] or STRINGS.NAMES.SHENANIGANS
            message = theDead:GetDisplayName().." "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." "..source
        end

		if not theDead.ghostenabled or theDead.charlie_vinesave then
            message = message.."."
        else
            local gender = GetGenderStrings(theDead.prefab)
            if STRINGS.UI.HUD["DEATH_ANNOUNCEMENT_2_"..gender] then
                message = message..STRINGS.UI.HUD["DEATH_ANNOUNCEMENT_2_"..gender]
            else
                message = message..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT
            end
        end
    else
        local gender = GetGenderStrings(theDead.prefab)
        if STRINGS.UI.HUD["GHOST_DEATH_ANNOUNCEMENT_"..gender] then
            message = theDead:GetDisplayName().." "..STRINGS.UI.HUD["GHOST_DEATH_ANNOUNCEMENT_"..gender]
        else
            message = theDead:GetDisplayName().." "..STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_DEFAULT
        end
    end

    return message
end

function GetNewRezAnnouncementString(theRezzed, source)
    if not theRezzed or not source then return "" end
    local message = theRezzed:GetDisplayName().." "..STRINGS.UI.HUD.REZ_ANNOUNCEMENT.." "..source.."."
    return message
end

return EventAnnouncer