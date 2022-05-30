local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/templates"

local WorldGenScreen = require "screens/worldgenscreen"

local ENABLE_CANCEL_BUTTON = IsNotConsole()

local LaunchingServerPopup = Class(Screen, function(self, serverinfo, successCallback, errorCallback)
    Screen._ctor(self, "LaunchingServerPopup")

    self.serverinfo = serverinfo
    self.successCallback = successCallback
    self.errorCallback = errorCallback
    self.launchtime = GetStaticTime()
	self.errorStartingServers = false

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
    local text = STRINGS.UI.NOTIFICATION.LAUNCHING_SERVER
    self.text:SetPosition(0, 5, 0)
    self.text:SetSize(35)
    self.text:SetString(text)
	self.text:EnableWordWrap(true)
    self.text:SetRegionSize(260, 100)
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:SetColour(0,0,0,1)

	if ENABLE_CANCEL_BUTTON then
		local spacing = 165
		local buttons =
		{
			{text=STRINGS.UI.LOBBYSCREEN.CANCEL, cb = function()
				self:OnCancel()
			end},
		}
		self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
		self.menu:SetPosition(-(spacing*(#buttons-1))/2 + 5, -92, 0)
		for i,v in pairs(self.menu.items) do
			v:SetScale(.7)
			v.image:SetScale(.6, .8)
		end
		self.buttons = buttons
		self.default_focus = self.menu
	end

    self.time = 0
    self.progress = 0
end)

function LaunchingServerPopup:OnUpdate( dt )
    local status = TheNet:GetChildProcessStatus()
	local hasError = TheNet:GetChildProcessError() or self.errorStartingServers
    -- 0 : not starting, not existing
    -- 1 : process is starting
    -- 2 : worldgen
    -- 3 : ready to accept connection
    --print("STATUS IS ", status);

	if hasError then
        if self.worldgenscreen and TheFrontEnd:GetActiveScreen() == self.worldgenscreen then
            TheFrontEnd:PopScreen()
        end

        if TheFrontEnd:GetActiveScreen() == self then
            TheFrontEnd:PopScreen()
        end

		self.errorCallback()

	elseif status == 0 or status == 1 or status == 2 then
        self.time = self.time + dt
        if self.time > 0.75 then
            self.progress = self.progress + 1
            if self.progress > 3 then
                self.progress = 1
            end

            local text = status == 2 and STRINGS.UI.NOTIFICATION.SERVER_WORLDGEN or STRINGS.UI.NOTIFICATION.LAUNCHING_SERVER
            for k = 1, self.progress, 1 do
                text = text .. "."
            end
            self.text:SetString(text)
            self.time = 0
        end
    --elseif status == 2 then
        --if self.worldgenscreen == nil then
            --self.worldgenscreen = TheFrontEnd:PushScreen(WorldGenScreen())
        --end
    elseif status == 3 then
        --if self.worldgenscreen and TheFrontEnd:GetActiveScreen() == self.worldgenscreen then
            --TheFrontEnd:PopScreen()
        --end
        if TheFrontEnd:GetActiveScreen() == self then
            TheFrontEnd:PopScreen()
        end
        self.successCallback(self.serverinfo)
    end
end

function LaunchingServerPopup:OnControl(control, down)
    if LaunchingServerPopup._base.OnControl(self,control, down) then
        return true
    end

    if ENABLE_CANCEL_BUTTON and control == CONTROL_CANCEL and not down then
        self:OnCancel()
    end
end

function LaunchingServerPopup:OnCancel()
    self:Disable()

    TheSystemService:StopDedicatedServers()
    TheFrontEnd:PopScreen()
end

function LaunchingServerPopup:SetErrorStartingServers()
    self.errorStartingServers = true
end

return LaunchingServerPopup
