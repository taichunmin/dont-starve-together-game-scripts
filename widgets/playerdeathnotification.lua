local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local PlayerBadge = require "widgets/playerbadge"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/templates"

local openY_countdown = -75
local openY = -122
local closedY = -250
local row2Y = -50

local portal = "\243\176\128\176"
local touch_stone = "\243\176\128\177"


local PlayerDeathNotification = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerDeathNotification")

    self.owner = owner
	self.closing = true

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(0, closedY)

    self.bg = self.root:AddChild(TEMPLATES.CurlyWindow(180, 240, 1, 1, 68, -40))
    self.bg.fill = self.root:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetScale(-1.02, 1)
    self.bg.fill:SetPosition(8, 2)

	self.close_button_root = self.root:AddChild(Widget("close_root"))
    self.close_button = self.close_button_root:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
	self.close_button:SetPosition(306, 162)
	self.close_button:SetScale(0.6)
	self.close_button:SetImageNormalColour(.9, .9, .9, 1)
	self.close_button:SetHoverText(STRINGS.UI.HELP.CLOSE)
    self.close_button:SetOnClick(function() self.closing = true self:RefreshLayout() end)
	self.close_button:Hide()

    self.msgroot = self.root:AddChild(Widget("msgroot"))
    self.msgroot:SetPosition(0, 150)

    self.avatar = self.msgroot:AddChild(PlayerBadge(owner.prefab or "", owner.playercolour or DEFAULT_PLAYER_COLOUR, TheWorld.ismastersim, 0))
    self.avatar:SetScale(.6)
    self.avatar:SetPosition(-250, 0)

    self.avatar_message = self.msgroot:AddChild(Text(BUTTONFONT, 28))
    self.avatar_message:SetColour(0, 0, 0, 1)
    self.avatar_message:SetPosition(-175, 0)


	local revive_params = {}
	if true --[[ TODO: test world gen settings for touch stones ~= none]] then
		table.insert(revive_params, touch_stone)
	end
	if GetPortalRez() then
		table.insert(revive_params, portal)
	end

	local revive_str = #revive_params == 0 and STRINGS.UI.WORLDRESETDIALOG.REVIVE_0
						or #revive_params == 1 and subfmt(STRINGS.UI.WORLDRESETDIALOG.REVIVE_1, {item1 = revive_params[1]})
						or subfmt(STRINGS.UI.WORLDRESETDIALOG.REVIVE_2, {item1 = revive_params[1], item2 = revive_params[2]})

    self.revive_message = self.msgroot:AddChild(Text(BUTTONFONT, 28, revive_str,  UICOLOURS.BLACK))
    self.revive_message:SetPosition(105, 0)

    self.regen_countdown_message = self.msgroot:AddChild(Text(BUTTONFONT, 35))
    self.regen_countdown_message:SetColour(0,0,0,1)
	self.regen_countdown_message:SetPosition(-85, row2Y)
    self.regen_countdown_message:SetHAlign(ANCHOR_LEFT)
    self.regen_countdown_message:SetVAlign(ANCHOR_MIDDLE)
    self.regen_countdown_message:SetRegionSize(370, 40)
	self.regen_countdown_message:Hide()

	self.regen_root = self.msgroot:AddChild(Widget("regen_root"))

    self.regen_button = self.regen_root:AddChild(ImageButton())
    self.regen_button:SetOnClick(function() self:Reset() end)
    self.regen_button:SetText(STRINGS.UI.WORLDRESETDIALOG.RESET_BUTTON)
	self.regen_button:SetPosition(210, row2Y + 3)
    self.regen_button:SetScale(.75)

	self.default_focus = self.reset_button

    self.regen_text = self.regen_root:AddChild(Text(UIFONT, 25))
    self.regen_text:SetPosition(210, row2Y)

    self.seperator = self.msgroot:AddChild(Image("images/ui.xml", "line_horizontal_5.tex"))
	self.seperator:SetPosition(0, row2Y + 26)
	self.seperator:SetScale(0.35, 0.5)

    self:Hide()

    self.inst:ListenForEvent("showworldreset", function() self:StartRegenTimer() end, TheWorld)
    self.inst:ListenForEvent("hideworldreset", function() self:StopRegenTimer() end, TheWorld)

end)

function PlayerDeathNotification:RefreshLayout()
	if TheInput:ControllerAttached() then
		self.close_button_root:Hide()
	    self.regen_text:SetString(STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT1..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PAUSE)..STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT2)
		self.regen_text:Show()
		self.regen_button:Hide()
	else
		self.close_button_root:Show()
		self.regen_text:Hide()
		self.regen_button:Show()
	end

	if self.closing then
		if self.target_y ~= closedY then
			self.target_y = closedY

			local pt = self.root:GetPosition()
			self.root:MoveTo(pt, Vector3(0, closedY, 0), .5, function() self:Hide() end)

			self.close_button:Hide()
		end
	elseif self.started then
		if self.target_y ~= openY_countdown then
			self.target_y = openY_countdown

			local pt = self.root:GetPosition()
			self.root:MoveTo(pt, Vector3(0, openY_countdown, 0), .5)

			self:Show()
			self.regen_root:Show()
			self.regen_countdown_message:Show()
			self.close_button:Hide()
		end
	else 
		if self.target_y ~= openY then
			self.target_y = openY
			local pt = self.root:GetPosition()
			self.root:MoveTo(pt, Vector3(0, openY, 0), .5, function() self.regen_countdown_message:Hide() self.regen_root:Hide() end)

			self:Show()
			self.close_button:Show()
		end
	end

	if self.owner.Network:IsServerAdmin() then
		self.regen_countdown_message:SetPosition(-85, row2Y)
	else
		self.regen_countdown_message:SetPosition(0, row2Y)
		self.regen_text:Hide()
		self.regen_button:Hide()
	end

end

function PlayerDeathNotification:SetGhostMode(isghost)
	if isghost then
		local age = self.owner.Network:GetPlayerAge()
		self.avatar_message:SetString(
			age > 1 and
			string.format(STRINGS.UI.WORLDRESETDIALOG.SURVIVED_MSG, age) or
			string.format(STRINGS.UI.WORLDRESETDIALOG.SURVIVED_MSG_1_DAY, 1)
		)
		
		self.closing = false
		self:RefreshLayout()
	else
		if not self.closing then
			self.closing = true
			self:RefreshLayout()
		end
	end
end

function PlayerDeathNotification:OnShow()
    self._base.OnShow(self)

	if self._oncontinuefrompause == nil then
		self._oncontinuefrompause = function() self:RefreshLayout() end
		self.inst:ListenForEvent("continuefrompause", self._oncontinuefrompause, TheWorld)
	end
end

function PlayerDeathNotification:OnHide()
    self._base.OnHide(self)

    if self._oncontinuefrompause ~= nil then
        self.inst:RemoveEventCallback("continuefrompause", self._oncontinuefrompause, TheWorld)
		self._oncontinuefrompause = nil
    end
end

function PlayerDeathNotification:OnUpdate(dt)
    if self.started then
        if TheInput:IsControlPressed(CONTROL_PAUSE) then
            self.reset_hold_time = self.reset_hold_time + dt
            if self.reset_hold_time > 2 then
                self:DoRegenWorld()
            end
        else
            self.reset_hold_time = 0
        end
    end
end

function PlayerDeathNotification:DoRegenWorld()
    if self.started and self.owner.Network:IsServerAdmin() then
		TheNet:SendWorldResetRequestToServer()
	end
end

function PlayerDeathNotification:Reset()
    if self.started and self.owner.Network:IsServerAdmin() then
		self.regen_confirm = PopupDialogScreen(STRINGS.UI.WORLDRESETDIALOG.REGEN_CONFIRM_TITLE, STRINGS.UI.WORLDRESETDIALOG.REGEN_CONFIRM_BODY, {{text=STRINGS.UI.PAUSEMENU.YES, cb = function() self.regen_confirm = nil self:DoRegenWorld() end},{text=STRINGS.UI.PAUSEMENU.NO, cb = function() self.regen_confirm = nil TheFrontEnd:PopScreen() end}  })
		TheFrontEnd:PushScreen(self.regen_confirm)
    end
end

function PlayerDeathNotification:StartRegenTimer()
    if self.started then
        return
    end

    self.started = true
	self.closing = false
    self.reset_hold_time = 0
	self.time_sound_count = 0
	self:RefreshLayout()
    self:StartUpdating()

    if self._onworldresettick == nil then
        self._onworldresettick = function(world, data) self:UpdateRegenCountdown(data.time) end
        self.inst:ListenForEvent("worldresettick", self._onworldresettick, TheWorld)
        self:UpdateRegenCountdown()
    end
end

function PlayerDeathNotification:StopRegenTimer()
    if not self.started then
        return
    end

	if self.regen_confirm ~= nil then
		TheFrontEnd:PopScreen(self.regen_confirm)
		self.regen_confirm = nil
	end

    self.started = false
	self:RefreshLayout()
    self:StartUpdating()

    if self._onworldresettick ~= nil then
        self.inst:RemoveEventCallback("worldresettick", self._onworldresettick, TheWorld)
        self._onworldresettick = nil
    end
end

function PlayerDeathNotification:UpdateRegenCountdown(time)
    if time == self._lastshowntime then
        return
    end

    if time ~= nil then
		local volume = 0
		if time <= 30 then
			volume = 1
		elseif self.time_sound_count < 20 then
			volume = (20 - self.time_sound_count)/20
		end
		if volume > 0 then
	        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/WorldDeathTick", nil, volume)
			self.time_sound_count = self.time_sound_count + 1
		end
	else
		time = 0
	end

	self.regen_countdown_message:SetMultilineTruncatedString(string.format(STRINGS.UI.WORLDRESETDIALOG.REGEN_MSG, time), 1, 390)

    self._lastshowntime = time

end

return PlayerDeathNotification
