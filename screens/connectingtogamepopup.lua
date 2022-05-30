local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/templates"

local ConnectingToGamePopup = Class(Screen, function(self)
	Screen._ctor(self, "ConnectingToGamePopup")

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
    local text = STRINGS.UI.NOTIFICATION.CONNECTING
    self.text:SetPosition(0, 5, 0)
    self.text:SetSize(35)
    self.text:SetString(text)
    -- self.text:SetRegionSize(140, 100)
	self.text:SetHAlign(ANCHOR_LEFT)
	self.text:SetColour(0,0,0,1)

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

	self.time = 0
	self.progress = 0
end)

function ConnectingToGamePopup:OnUpdate( dt )
	self.time = self.time + dt
	if self.time > 0.75 then
	    self.progress = self.progress + 1
	    if self.progress > 3 then
	        self.progress = 1
	    end

	    local text = STRINGS.UI.NOTIFICATION.CONNECTING
	    for k = 1, self.progress, 1 do
	        text = text .. "."
	    end
        self.text:SetString(text)
	    self.time = 0
	end
end

function ConnectingToGamePopup:OnControl(control, down)
    if ConnectingToGamePopup._base.OnControl(self,control, down) then
        return true
    end

    if control == CONTROL_CANCEL and not down then
        self:OnCancel()
    end
end

function ConnectingToGamePopup:OnCancel()
    self:Disable()

    -- V2C: what was the following comment for??
    -- "This might be problematic for when in-game?"
    -- V2C: Oh i see. =) this comment must have been
    --      for shard migration.
    TheNet:JoinServerResponse(true) -- cancel join
    TheNet:Disconnect(false)
    TheFrontEnd:PopScreen()

    TheSystemService:StopDedicatedServers() -- just in case, we need to closes the server if the player cancel the connection

    if IsMigrating() then
        -- Still does not handle in-game, but
        -- this one's for canceling migration
        DoRestart(false)
    end
end

return ConnectingToGamePopup
