local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/templates"

local NetworkLoginPopup = Class(Screen, function(self, onLogin, onCancel, hideOfflineButton)
	Screen._ctor(self, "NetworkLoginPopup")

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
	self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(30, 100, .7, .7, 47, -28))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
	self.bg.fill:SetScale(.54, .45)
	self.bg.fill:SetPosition(6, 8)

	--title
	local title = ""
    self.title = self.proot:AddChild(Text(TITLEFONT, 50))
    self.title:SetPosition(0, 70, 0)
    self.title:SetString(title)

	--text
    self.text = self.proot:AddChild(Text(BUTTONFONT, 55))
    local text = STRINGS.UI.NOTIFICATION.LOGIN
    self.text:SetPosition(0, 5, 0)
    self.text:SetSize(35)
    self.text:SetString(text)
    -- self.text:SetRegionSize(140, 100)
	self.text:SetHAlign(ANCHOR_LEFT)
	self.text:SetColour(0,0,0,1)

    local spacing = 165
    local buttons = {}

	if hideOfflineButton == nil or not hideOfflineButton then
		buttons[#buttons+1] =
			{text=STRINGS.UI.MAINSCREEN.PLAYOFFLINE, cb = function()
				self:OnLogin(true)
			end}
	end

	buttons[#buttons+1] =
		{text=STRINGS.UI.LOBBYSCREEN.CANCEL, cb = function()
            self:OnCancel()
        end}

	self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
	self.menu:SetPosition(-(spacing*(#buttons-1))/2 + 5, -93, 0)
	for i,v in pairs(self.menu.items) do
		v:SetScale(.7)
		v.image:SetScale(.6, .8)
	end
	self.buttons = buttons
	self.default_focus = self.menu

	self.time = 0
	self.progress = 0
	self.onLogin = onLogin
	self.onCancel = onCancel
end)

function NetworkLoginPopup:OnUpdate( dt )
	local account_manager = TheFrontEnd:GetAccountManager()
	local isWaiting = account_manager:IsWaitingForResponse()
	local isDownloadingInventory = TheInventory:IsDownloadingInventory()

	if not isWaiting and not isDownloadingInventory then
	    self:OnLogin()
	end

	self.time = self.time + dt
	if self.time > 0.75 then
	    self.progress = self.progress + 1
	    if self.progress > 3 then
	        self.progress = 1
	    end

	    local text = STRINGS.UI.NOTIFICATION.LOGIN
	    for k = 1, self.progress, 1 do
	        text = text .. "."
	    end
        self.text:SetString(text)
	    self.time = 0
	end
end

function NetworkLoginPopup:OnControl(control, down)
    if NetworkLoginPopup._base.OnControl(self,control, down) then
        return true
    end

    if control == CONTROL_CANCEL and not down then
        self:OnCancel()
    end
end

function NetworkLoginPopup:OnLogin(forceOffline)
	if forceOffline or not self.logged then
		self.logged = true
	    self:Disable()
	    self:StopUpdating()
	    if forceOffline then TheFrontEnd:GetAccountManager():CancelLogin() end
	    self.onLogin(forceOffline)
	end
end

function NetworkLoginPopup:OnCancel()
    self:Disable()
	TheFrontEnd:GetAccountManager():CancelLogin()
	TheFrontEnd:PopScreen()
	self.onCancel()
end

return NetworkLoginPopup
