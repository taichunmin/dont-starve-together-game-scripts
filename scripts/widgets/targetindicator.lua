local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local ARROW_OFFSET = 65

local MIN_SCALE = .5
local MIN_ALPHA = .35

local DEFAULT_ATLAS = "images/avatars.xml"
local DEFAULT_AVATAR = "avatar_unknown.tex"

local function CancelIndicator(inst)
    inst.startindicatortask:Cancel()
    inst.startindicatortask = nil
    inst.OnRemoveEntity = nil
end

local function StartIndicator(target, self)
    self.inst.startindicatortask = nil
    self.inst.OnRemoveEntity = nil
    self.colour = target.playercolour or PORTAL_TEXT_COLOUR
    self:StartUpdating()
    self:OnUpdate()
    self:Show()
end

local TargetIndicator = Class(Widget, function(self, owner, target, data)
    Widget._ctor(self, "TargetIndicator")
    self:UpdateWhilePaused(false)
    self.owner = owner
    self.isFE = false
    self:SetClickable(true)

    self.root = self:AddChild(Widget("root"))
    -- self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.icon = self.root:AddChild(Widget("target"))

    self.userflags = target.Network ~= nil and target.Network:GetUserFlags() or 0
    self.isGhost = checkbit(self.userflags, USERFLAGS.IS_GHOST)
    self.isCharacterState1 = checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_1)
    self.isCharacterState2 = checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_2)
    self.isCharacterState3 = checkbit(self.userflags, USERFLAGS.CHARACTER_STATE_3)

    self.is_mod_character = target ~= nil and target.prefab ~= nil and table.contains(MODCHARACTERLIST, target.prefab)
	self.config_data = data or {}
    self.target = target
    self.colour = nil

    self.headbg = self.icon:AddChild(Image(DEFAULT_ATLAS, self.isGhost and "avatar_ghost_bg.tex" or "avatar_bg.tex"))
    self.head = self.icon:AddChild(Image(self:GetAvatarAtlas(), self:GetAvatar(), DEFAULT_AVATAR))
    self.headframe = self.icon:AddChild(Image(DEFAULT_ATLAS, "avatar_frame_white.tex"))

    self.icon:SetScale(.8)

    self.arrow = self.root:AddChild(Image("images/ui.xml", "scroll_arrow.tex"))
    self.arrow:SetScale(.5)

    self.name = target:GetDisplayName()
    self.name_label = self.icon:AddChild(Text(UIFONT, 45, self.name))
    self.name_label:SetPosition(0, 80, 0)
    self.name_label:Hide()

    self:Hide()
    self.inst.startindicatortask = target:DoTaskInTime(0, StartIndicator, self)
    self.inst.OnRemoveEntity = CancelIndicator
end)

function TargetIndicator:OnGainFocus()
    TargetIndicator._base.OnGainFocus(self)
    self.name_label:Show()
end

function TargetIndicator:OnLoseFocus()
    TargetIndicator._base.OnLoseFocus(self)
    self.name_label:Hide()
end

function TargetIndicator:GetTarget()
    return self.target
end

function TargetIndicator:GetTargetIndicatorAlpha(dist)
    if dist > TUNING.MAX_INDICATOR_RANGE*2 then
        dist = TUNING.MAX_INDICATOR_RANGE*2
    end
    local alpha = Remap(dist, TUNING.MAX_INDICATOR_RANGE, TUNING.MAX_INDICATOR_RANGE*2, 1, MIN_ALPHA)
    if dist <= TUNING.MAX_INDICATOR_RANGE then
        alpha = 1
    end
    return alpha
end

function TargetIndicator:OnUpdate()
    if TheNet:IsServerPaused() then return end
    -- figure out how far away they are and scale accordingly
    -- then grab the new position of the target and update the HUD elt's pos accordingly
    -- kill on this is rough: it just pops in/out. would be nice if it faded in/out...

    local userflags = self.target.Network ~= nil and self.target.Network:GetUserFlags() or 0
    if self.userflags ~= userflags then
        self.userflags = userflags
        self.isGhost = checkbit(userflags, USERFLAGS.IS_GHOST)
        self.isCharacterState1 = checkbit(userflags, USERFLAGS.CHARACTER_STATE_1)
        self.isCharacterState2 = checkbit(userflags, USERFLAGS.CHARACTER_STATE_2)
        self.isCharacterState3 = checkbit(userflags, USERFLAGS.CHARACTER_STATE_3)
        self.headbg:SetTexture(DEFAULT_ATLAS, self.isGhost and "avatar_ghost_bg.tex" or "avatar_bg.tex")
        self.head:SetTexture(self:GetAvatarAtlas(), self:GetAvatar(), DEFAULT_AVATAR)
    end

    if not self.target:IsValid() then
        return
    end

    local dist = self.owner:GetDistanceSqToInst(self.target)
    dist = math.sqrt(dist)

    local alpha = self:GetTargetIndicatorAlpha(dist)
    self.headbg:SetTint(1, 1, 1, alpha)
    self.head:SetTint(1, 1, 1, alpha)
    self.headframe:SetTint(self.colour[1], self.colour[2], self.colour[3], alpha)
    self.arrow:SetTint(self.colour[1], self.colour[2], self.colour[3], alpha)
    self.name_label:SetColour(self.colour[1], self.colour[2], self.colour[3], alpha)

    if dist < TUNING.MIN_INDICATOR_RANGE then
        dist = TUNING.MIN_INDICATOR_RANGE
    elseif dist > TUNING.MAX_INDICATOR_RANGE then
        dist = TUNING.MAX_INDICATOR_RANGE
    end
    local scale = Remap(dist, TUNING.MIN_INDICATOR_RANGE, TUNING.MAX_INDICATOR_RANGE, 1, MIN_SCALE)
    self:SetScale(scale)

    local x, y, z = self.target.Transform:GetWorldPosition()
    self:UpdatePosition(x, z)
end

function TargetIndicator:UpdatePosition(targX, targZ)
    local w0, h0 = self.head:GetSize()
    local w1, h1 = self.arrow:GetSize()
    local scale = self:GetScale()
    local w = ((w0 or 0) + (w1 or 0)) * 0.5 * scale.x
    local h = ((h0 or 0) + (h1 or 0)) * 0.5 * scale.y
    local x, y, angle = GetIndicatorLocationAndAngle(self.owner, targX, targZ, w, h)

    self:SetPosition(x, y, 0)
    self.x = x
    self.y = y
    self.angle = angle
    self:PositionArrow()
    self:PositionLabel()
end

function TargetIndicator:PositionArrow()
    if not self.x and self.y and self.angle then return end

    local angle = self.angle + 45
    self.arrow:SetRotation(angle)
    local x = math.cos(angle*DEGREES) * ARROW_OFFSET
    local y = -(math.sin(angle*DEGREES) * ARROW_OFFSET)
    self.arrow:SetPosition(x, y, 0)
end

function TargetIndicator:PositionLabel()
    if not self.x and self.y and self.angle then return end

    local angle = self.angle + 45 - 180
    local x = math.cos(angle*DEGREES) * ARROW_OFFSET * 1.75
    local y = -(math.sin(angle*DEGREES) * ARROW_OFFSET  * 1.25)
    self.name_label:SetPosition(x, y, 0)
end

function TargetIndicator:GetAvatarAtlas()
    if self.is_mod_character then
        local location = MOD_AVATAR_LOCATIONS["Default"]
        if MOD_AVATAR_LOCATIONS[self.target.prefab] ~= nil then
            location = MOD_AVATAR_LOCATIONS[self.target.prefab]
        end

        local starting = self.isGhost and "avatar_ghost_" or "avatar_"
        local ending =
            (self.isCharacterState1 and "_1" or "")..
            (self.isCharacterState2 and "_2" or "")..
            (self.isCharacterState3 and "_3" or "")

        return location..starting..self.target.prefab..ending..".xml"
    end
    return self.config_data.atlas or DEFAULT_ATLAS
end

function TargetIndicator:GetAvatar()
	if self.config_data.image ~= nil then
		return self.config_data.image
	end

    local starting = self.isGhost and "avatar_ghost_" or "avatar_"
    local ending =
        (self.isCharacterState1 and "_1" or "")..
        (self.isCharacterState2 and "_2" or "")..
        (self.isCharacterState3 and "_3" or "")

    return self.target.prefab ~= nil
        and self.target.prefab ~= ""
        and (starting..self.target.prefab..ending..".tex")
        or (starting.."unknown.tex")
end

return TargetIndicator
