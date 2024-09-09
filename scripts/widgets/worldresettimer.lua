local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local PlayerBadge = require "widgets/playerbadge"
local TEMPLATES = require "widgets/templates"

local openY = -30
local closedY = -250
local row2height = 75

local WorldResetTimer = Class(Widget, function(self, owner)
    Widget._ctor(self, "WorldResetTimer")

    self.root = self:AddChild(Widget("root"))
    self.y_pos = closedY
    self.started = false
    self.root:SetPosition(0, self.y_pos)

    self.owner = owner

    self.bg = self.root:AddChild(TEMPLATES.CurlyWindow(245, 240, 1, 1, 68, -40))
    self.bg.fill = self.root:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetScale(1.1, .9)
    self.bg.fill:SetPosition(8, 12)

    self.title = self.root:AddChild(Text(BUTTONFONT, 50))
    self.title:SetColour(0, 0, 0, 1)
    self.title:SetPosition(0, 130, 0)

    self.countdown_message = self.root:AddChild(Text(BUTTONFONT, 35))
    self.countdown_message:SetColour(0,0,0,1)
    self.countdown_message:SetPosition(120, row2height, 0)

    self.leftroot = self.root:AddChild(Widget("leftroot"))
    self.leftroot:SetPosition(-200, row2height)
    self.avatar = self.leftroot:AddChild(PlayerBadge(owner.prefab or "", owner.playercolour or DEFAULT_PLAYER_COLOUR, TheWorld.ismastersim, 0))
    self.avatar:SetScale(.8)

    self.survived_message = self.leftroot:AddChild(Text(BUTTONFONT, 35))
    self.survived_message:SetColour(0, 0, 0, 1)
    self.survived_message:SetPosition(105, 0, 0)

    self.reset_hold_time = 0

    self._oncontinuefrompause = nil
    self._oncycleschanged = nil
    self._onworldresettick = nil
    self._lastshowntime = nil

    self:Hide()

    self.inst:ListenForEvent("showworldreset", function() self:StartTimer() end, TheWorld)
    self.inst:ListenForEvent("hideworldreset", function() self:StopTimer() end, TheWorld)
end)

function WorldResetTimer:RefreshLayout()
    --for controller, don't show button, isntead show "Hold Start to Reset" string, if held for 1-2s, reset
    if TheInput:ControllerAttached() then
        if self.reset_button ~= nil then
            self.default_focus = nil
            self.reset_button:Kill()
            self.reset_button = nil
        end

        if self.reset_text == nil then
            self.reset_text = self.root:AddChild(Text(UIFONT, 35))
            self.reset_text:SetPosition(260, row2height, 0)
            self.reset_text:SetColour(1, 1, 1, 1)

            self.leftroot:SetPosition(-250, row2height)
            self.countdown_message:SetPosition(60, row2height)
        end

        local controller_id = TheInput:GetControllerID()
        self.reset_text:SetString(STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT1..TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE).."\n"..STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT2)
    else
        if self.reset_text ~= nil then
            self.reset_text:Kill()
            self.reset_text = nil
        end

        if self.reset_button == nil then
            self.reset_button = self.root:AddChild(ImageButton())
            self.reset_button:SetOnClick(function() self:Reset() end)
            self.reset_button:SetText(STRINGS.UI.WORLDRESETDIALOG.RESET_BUTTON)
            self.reset_button:SetPosition(250, row2height, 0)
            self.reset_button:SetScale(.75)

            self.leftroot:SetPosition(-270, row2height)
            self.countdown_message:SetPosition(35, row2height)

            self.default_focus = self.reset_button
        end
    end

    self:RefreshButtons()
end

function WorldResetTimer:RefreshButtons()
    if self.reset_button ~= nil then
        if not self.started or self.owner.HUD:HasInputFocus() then
            if self.reset_button.enabled then
                self.reset_button:Disable()
            end
        elseif not self.reset_button.enabled then
            self.reset_button:Enable()
        end
    end

    if self.reset_text ~= nil then
        if self.owner.HUD:HasInputFocus() then
            if self.reset_text.shown then
                self.reset_text:Hide()
            end
        elseif not self.reset_text.shown then
            self.reset_text:Show()
        end
    end
end

function WorldResetTimer:OnUpdate(dt)
    self:RefreshButtons()

    if self.started then
        if self.y_pos < openY then
            self.y_pos = self.y_pos + 3
            self.root:SetPosition(0, self.y_pos)
        elseif self.reset_text ~= nil
            and self.reset_text:IsVisible()
            and TheInput:IsControlPressed(CONTROL_PAUSE) then
            self.reset_hold_time = self.reset_hold_time + dt
            if self.reset_hold_time > 2 then
                self:Reset()
            end
        else
            self.reset_hold_time = 0
        end
    elseif self.y_pos > closedY then
        self.y_pos = self.y_pos - 3
        self.root:SetPosition(0, self.y_pos)
    else
        self:Hide()
        self:StopUpdating()
    end
end

function WorldResetTimer:OnShow()
    self._base.OnShow(self)

    if self._oncontinuefrompause == nil and self.owner.Network:IsServerAdmin() then
        self._oncontinuefrompause = function() self:RefreshLayout() end
        self.inst:ListenForEvent("continuefrompause", self._oncontinuefrompause, TheWorld)
        self:RefreshLayout()
    end
end

function WorldResetTimer:OnHide()
    self._base.OnHide(self)

    if self._oncontinuefrompause ~= nil then
        self.inst:RemoveEventCallback("continuefrompause", self._oncontinuefrompause, TheWorld)
        self._oncontinuefrompause = nil
    end
end

function WorldResetTimer:StartTimer()
    local age = self.owner.Network:GetPlayerAge()
    self.survived_message:SetString(
        age > 1 and
        string.format(STRINGS.UI.WORLDRESETDIALOG.SURVIVED_MSG, age) or
        string.format(STRINGS.UI.WORLDRESETDIALOG.SURVIVED_MSG_1_DAY, 1)
    )

    if self.started then
        return
    end

    self.started = true
    self.reset_hold_time = 0
    self:RefreshButtons()
    self:StartUpdating()
    self:Show()

    if self._oncycleschanged == nil then
        self._oncycleschanged = function(world, cycles) self:UpdateCycles(cycles) end
        self.inst:ListenForEvent("cycleschanged", self._oncycleschanged, TheWorld)
        self:UpdateCycles(TheWorld.state.cycles)
    end
    if self._onworldresettick == nil then
        self._onworldresettick = function(world, data) self:UpdateCountdown(data.time) end
        self.inst:ListenForEvent("worldresettick", self._onworldresettick, TheWorld)
        self:UpdateCountdown()
    end
end

function WorldResetTimer:StopTimer()
    if not self.started then
        return
    end

    self.started = false
    self:RefreshButtons()
    self:StartUpdating()

    if self._oncycleschanged ~= nil then
        self.inst:RemoveEventCallback("cycleschanged", self._oncycleschanged, TheWorld)
        self._oncycleschanged = nil
    end
    if self._onworldresettick ~= nil then
        self.inst:RemoveEventCallback("worldresettick", self._onworldresettick, TheWorld)
        self._onworldresettick = nil
    end
end

function WorldResetTimer:Reset()
    if self.started and self.owner.Network:IsServerAdmin() then
        TheNet:SendWorldResetRequestToServer()
    end
end

function WorldResetTimer:UpdateCycles(cycles)
    if self.owner:HasTag("playerghost") then
        self.title:SetString(string.format(STRINGS.UI.WORLDRESETDIALOG.TITLE, cycles + 1))
    else
        self.title:SetString(string.format(STRINGS.UI.WORLDRESETDIALOG.TITLE_LATEJOIN, cycles + 1))
    end
end

function WorldResetTimer:UpdateCountdown(time)
    if time == self._lastshowntime then
        return
    end

    if time ~= nil then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/WorldDeathTick")
        self.countdown_message:SetString(string.format(STRINGS.UI.WORLDRESETDIALOG.RESET_MSG, time))
    else
        self.countdown_message:SetString(STRINGS.UI.WORLDRESETDIALOG.RESET_MSG)
    end

    self._lastshowntime = time
end

return WorldResetTimer
