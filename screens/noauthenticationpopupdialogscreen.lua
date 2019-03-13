local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/templates"

local ServerListingScreen = require "screens/serverlistingscreen"

local NoAuthenticationPopupDialogScreen = Class(Screen, function(self)
	Screen._ctor(self, "NoAuthenticationPopupDialogScreen")

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
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(55, 150, 1, 1, 67, -40))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetScale(.8, .68)
    self.bg.fill:SetPosition(8, 12)
	
	--title	
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(8, 90, 0)
    
    self.title:SetString(STRINGS.UI.NOAUTHENTICATIONSCREEN.TITLE)
    self.title:SetColour(0,0,0,1)

	--text
    if JapaneseOnPS4() then
       self.text = self.proot:AddChild(Text(BUTTONFONT, 28))
    else
       self.text = self.proot:AddChild(Text(BUTTONFONT, 30))
    end

    self.text:SetPosition(8, 15, 0)
    
    if JapaneseOnPS4() then
        self.text:SetRegionSize(500, 100)
    else
        self.text:SetRegionSize(500, 100)
    end

    self.text:SetString(STRINGS.UI.NOAUTHENTICATIONSCREEN.BODY)
    self.text:SetColour(0,0,0,1)
    self.text:EnableWordWrap(true)

    --text2
    if JapaneseOnPS4() then
       self.text2 = self.proot:AddChild(Text(BUTTONFONT, 21))
    else
       self.text2 = self.proot:AddChild(Text(BUTTONFONT, 23))
    end

    self.text2:SetPosition(8, -55, 0)
    self.text2:SetString(STRINGS.UI.NOAUTHENTICATIONSCREEN.BODY2)
    self.text2:EnableWordWrap(true)
    if JapaneseOnPS4() then
        self.text2:SetRegionSize(500, 100)
    else
        self.text2:SetRegionSize(500, 100)
    end
    self.text2:SetColour(0,0,0,1)
	
	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between
	
	
    local spacing = 250

    local go_button_text = STRINGS.UI.NOAUTHENTICATIONSCREEN.CREATEBUTTON
    local buttons = 
    {
        {text=go_button_text, cb = function() 
            local prefer_to_embed = true
            VisitURL(TheFrontEnd:GetAccountManager():GetAccountURL(), prefer_to_embed )
            TheFrontEnd:PopScreen()
        end},
        {text=STRINGS.UI.NOAUTHENTICATIONSCREEN.CANCELBUTTON, cb = function() 
            self:Disable()
            TheFrontEnd:PopScreen()             
        end}
    }
	self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
	self.menu:SetPosition(-(spacing*(#buttons-1))/2 + 30, -130, 0) 
    self.menu:SetScale(.8)
	self.buttons = buttons
    if not failedEmail then
        self.menu.items[1]:SetTextSize(36)
    end
	self.default_focus = self.menu

    self.time = GetTime()
end)



function NoAuthenticationPopupDialogScreen:OnUpdate( dt )
	local account_manager = TheFrontEnd:GetAccountManager()
	local hasloggedin = account_manager:HasAuthToken() 
	if hasloggedin then
        self:Disable()
		TheFrontEnd:PopScreen()
	end
end

function NoAuthenticationPopupDialogScreen:OnControl(control, down)
    if NoAuthenticationPopupDialogScreen._base.OnControl(self,control, down) then 
        return true 
    end

    if control == CONTROL_CANCEL and not down then    
        self:Disable()
        TheFrontEnd:PopScreen()
        return true
    end
end

return NoAuthenticationPopupDialogScreen
