require("constants")
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local YOFFSETUP = -80
local YOFFSETDOWN = -50
local XOFFSET = 10

local SHOW_DELAY = 0 --10

local HoverText = Class(Widget, function(self, owner)
    Widget._ctor(self, "HoverText")
    self.owner = owner
    self.isFE = false
    self:SetClickable(false)
    --self:MakeNonClickable()

    self.default_text_pos = Vector3(0, 40, 0)
    self.text = self:AddChild(Text(UIFONT, 30))
    self.text:SetPosition(self.default_text_pos)

    self.secondarytext = self:AddChild(Text(UIFONT, 30))
    self.secondarytext:SetPosition(0, -30, 0)
    self:FollowMouseConstrained()
    self:StartUpdating()
    self.lastStr = ""
    self.strFrames = 0
end)

function HoverText:OnUpdate()
    if self.owner.components.playercontroller == nil or not self.owner.components.playercontroller:UsingMouse() then
        if self.shown then
            self:Hide()
        end
        return
    elseif not self.shown then
        if not self.forcehide then
            self:Show()
        else
            return
        end
    end

    local str = nil
    local colour = nil
    if not self.isFE then
        str = self.owner.HUD.controls:GetTooltip() or self.owner.components.playercontroller:GetHoverTextOverride()
        self.text:SetPosition(self.owner.HUD.controls:GetTooltipPos() or self.default_text_pos)
        if self.owner.HUD.controls:GetTooltip() ~= nil then
            colour = self.owner.HUD.controls:GetTooltipColour()
        end
    else
        str = self.owner:GetTooltip()
        self.text:SetPosition(self.owner:GetTooltipPos() or self.default_text_pos)
    end

    local secondarystr = nil
    local lmb = nil
    if str == nil and not self.isFE and self.owner:IsActionsVisible() then
        lmb = self.owner.components.playercontroller:GetLeftMouseAction()
        if lmb ~= nil then
            local overriden
            str, overriden = lmb:GetActionString()

            if lmb.action.show_primary_input_left then
                str = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PRIMARY) .. " " .. str
            end

            if colour == nil then
                if lmb.target ~= nil then
                    if lmb.invobject ~= nil and not (lmb.invobject:HasTag("weapon") or lmb.invobject:HasTag("tool")) then
                        colour = lmb.invobject:GetIsWet() and WET_TEXT_COLOUR or NORMAL_TEXT_COLOUR
                    else
                        colour = lmb.target:GetIsWet() and WET_TEXT_COLOUR or NORMAL_TEXT_COLOUR
                    end
                elseif lmb.invobject ~= nil then
                    colour = lmb.invobject:GetIsWet() and WET_TEXT_COLOUR or NORMAL_TEXT_COLOUR
                end
            end

            if not overriden and lmb.target ~= nil and lmb.invobject == nil and lmb.target ~= lmb.doer then
                local name = lmb.target:GetDisplayName()
                if name ~= nil then
                    local adjective = lmb.target:GetAdjective()
                    str = str.." "..(adjective ~= nil and (adjective.." "..name) or name)

                    if lmb.target.replica.stackable ~= nil and lmb.target.replica.stackable:IsStack() then
                        str = str.." x"..tostring(lmb.target.replica.stackable:StackSize())
                    end

                    --NOTE: This won't work on clients. Leaving it here anyway.
                    if lmb.target.components.inspectable ~= nil and lmb.target.components.inspectable.recordview and lmb.target.prefab ~= nil then
                        ProfileStatsSet(lmb.target.prefab.."_seen", true)
                    end
                end
            end
        end
        local aoetargeting = self.owner.components.playercontroller:IsAOETargeting()
        local rmb = self.owner.components.playercontroller:GetRightMouseAction()
        if rmb ~= nil then
            if rmb.action.show_secondary_input_right then
                secondarystr = rmb:GetActionString() .. " " .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)
            elseif rmb.action ~= ACTIONS.CASTAOE then
                secondarystr = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)..": "..rmb:GetActionString()
            elseif aoetargeting and str == nil then
                str = rmb:GetActionString()
            end
        end
        if aoetargeting and secondarystr == nil then
            secondarystr = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SECONDARY)..": "..STRINGS.UI.HUD.CANCEL
        end
    end

    if str == nil then
        self.text:Hide()
    elseif self.str ~= self.lastStr then
        self.lastStr = self.str
        self.strFrames = SHOW_DELAY
    else
        self.strFrames = self.strFrames - 1
        if self.strFrames <= 0 then
            if lmb ~= nil and lmb.target ~= nil and lmb.target:HasTag("player") then
                self.text:SetColour(unpack(lmb.target.playercolour))
            else
                self.text:SetColour(unpack(colour or NORMAL_TEXT_COLOUR))
            end
            self.text:SetString(str)
            self.text:Show()
        end
    end

    if secondarystr ~= nil then
        self.secondarytext:SetString(secondarystr)
        self.secondarytext:Show()
    else
        self.secondarytext:Hide()
    end

    local changed = self.str ~= str or self.secondarystr ~= secondarystr
    self.str = str
    self.secondarystr = secondarystr
    if changed then
        local pos = TheInput:GetScreenPosition()
        self:UpdatePosition(pos.x, pos.y)
    end
end

function HoverText:UpdatePosition(x, y)
    local scale = self:GetScale()
    local scr_w, scr_h = TheSim:GetScreenSize()
    local w = 0
    local h = 0

    if self.text ~= nil and self.str ~= nil then
        local w0, h0 = self.text:GetRegionSize()
        w = math.max(w, w0)
        h = math.max(h, h0)
    end
    if self.secondarytext ~= nil and self.secondarystr ~= nil then
        local w1, h1 = self.secondarytext:GetRegionSize()
        w = math.max(w, w1)
        h = math.max(h, h1)
    end

    w = w * scale.x * .5
    h = h * scale.y * .5

    self:SetPosition(
        math.clamp(x, w + XOFFSET, scr_w - w - XOFFSET),
        math.clamp(y, h + YOFFSETDOWN * scale.y, scr_h - h - YOFFSETUP * scale.y),
        0)
end

function HoverText:FollowMouseConstrained()
    if self.followhandler == nil then
        self.followhandler = TheInput:AddMoveHandler(function(x, y) self:UpdatePosition(x, y) end)
        local pos = TheInput:GetScreenPosition()
        self:UpdatePosition(pos.x, pos.y)
    end
end

return HoverText
