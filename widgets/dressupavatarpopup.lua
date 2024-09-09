local Text = require "widgets/text"
local TEMPLATES = require "widgets/templates"
local PlayerAvatarPopup = require "widgets/playeravatarpopup"

local DressupAvatarPopup = Class(PlayerAvatarPopup, function(self, owner, player_name, data)
    PlayerAvatarPopup._ctor(self, owner, player_name, data, false)
end)

local BG_OFFSET = 4
local TITLE_WIDTH = 180
local REFRESH_INTERVAL = .5

function DressupAvatarPopup:UpdateDisplayName()
    local name = self:GetDisplayName(self.player_name, self.currentcharacter)
    if name ~= "" then
        self.title:SetPosition(BG_OFFSET, 191, 0)
        self.title2:SetTruncatedString(subfmt(STRINGS.UI.DRESSUP_AVATAR[self.dressed and "DRESSED_BY_FMT" or "UNDRESSED_BY_FMT"], { name = name }), TITLE_WIDTH, 56, true)
    else
        self.title:SetPosition(BG_OFFSET, 176, 0)
        self.title2:SetString("")
    end
end

function DressupAvatarPopup:Layout(data)--, show_net_profile)
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(0, 340, .5, .6, 39, -25))
    self.frame:SetPosition(0, 20)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(.29, .5)
    self.frame_bg:SetPosition(BG_OFFSET, 8)

    self.title = self.proot:AddChild(Text(BUTTONFONT, 32))
    self.title:SetColour(0, 0, 0, 1)
    if self.target ~= nil then
        self.title:SetTruncatedString(self.target:GetDisplayName(), TITLE_WIDTH, 43, true)
    end
    self.title2 = self.proot:AddChild(Text(BUTTONFONT, 24))
    self.title2:SetPosition(BG_OFFSET, 158, 0)
    self.title2:SetColour(0, 0, 0, 1)

    local widget_height = 75
    local body_offset = 95
    local line_offset = body_offset + 37
    local line_scale = 0.55
    local line_x_offset = 2

    self.horizontal_line1 = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.horizontal_line1:SetScale(line_scale, .25)
    self.horizontal_line1:SetPosition(line_x_offset, line_offset)

    self.body_image = self.proot:AddChild(self:CreateSkinWidgetForSlot())
    self.body_image:SetPosition(0, body_offset)
    self:UpdateSkinWidgetForSlot(self.body_image, "body", data.body_skin or "none")

    self.horizontal_line2 = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.horizontal_line2:SetScale(line_scale, .25)
    self.horizontal_line2:SetPosition(line_x_offset, line_offset - widget_height)

    self.hand_image = self.proot:AddChild(self:CreateSkinWidgetForSlot())
    self.hand_image:SetPosition(0, body_offset - widget_height)
    self:UpdateSkinWidgetForSlot(self.hand_image, "hand", data.hand_skin or "none")

    self.horizontal_line3 = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.horizontal_line3:SetScale(line_scale, .25)
    self.horizontal_line3:SetPosition(line_x_offset, line_offset - 2 * widget_height)

    self.legs_image = self.proot:AddChild(self:CreateSkinWidgetForSlot())
    self.legs_image:SetPosition(0, body_offset - 2 * widget_height)
    self:UpdateSkinWidgetForSlot(self.legs_image, "legs", data.legs_skin or "none")

    self.horizontal_line4 = self.proot:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.horizontal_line4:SetScale(line_scale, .25)
    self.horizontal_line4:SetPosition(line_x_offset, line_offset - 3 * widget_height)

    self.feet_image = self.proot:AddChild(self:CreateSkinWidgetForSlot())
    self.feet_image:SetPosition(0, body_offset - 3 * widget_height)
    self:UpdateSkinWidgetForSlot(self.feet_image, "feet", data.feet_skin or "none")

    if not TheInput:ControllerAttached() then
        self.close_button = self.proot:AddChild(TEMPLATES.SmallButton(STRINGS.UI.PLAYER_AVATAR.CLOSE, 26, .5, function() self:Close() end))
        self.close_button:SetPosition(0, -180)
    end
end

function DressupAvatarPopup:Start()
    if not self.started then
        self.started = true
        self:StartUpdating()

        local w, h = self.frame_bg:GetSize()

        self.out_pos = Vector3(.5 * w, 0, 0)
        self.in_pos = Vector3(-.95 * w, 0, 0)

        self:MoveTo(self.out_pos, self.in_pos, .33, function() self.settled = true end)
        
    end
end

function DressupAvatarPopup:Close()
    if self.started then
        self.started = false
        self.current_speed = 0

        self:StopUpdating()
        self:MoveTo(self.in_pos, self.out_pos, .33, function() ThePlayer.HUD:RemoveDressupWidget() end)
    end
end

function DressupAvatarPopup:UpdateData(data)
    self._base.UpdateData(self, data)

    self.currentcharacter = self:ResolveCharacter(data)
    self.player_name = data.name
    self.dressed = (data.body_skin or data.hand_skin or data.legs_skin or data.feet_skin) ~= nil

    self:UpdateDisplayName()
end

function DressupAvatarPopup:OnUpdate(dt)
    self._base.OnUpdate(self, dt)

    if self.started and self.target ~= nil and self.time_to_refresh <= dt then
        local avatardata = self.target.components.playeravatardata ~= nil and self.target.components.playeravatardata:GetData() or nil
        if avatardata ~= nil then
            self:UpdateData(avatardata)
        else
            self:Close()
        end
    end
end

return DressupAvatarPopup
