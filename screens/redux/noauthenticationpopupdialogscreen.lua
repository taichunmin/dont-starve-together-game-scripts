local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/redux/templates"

local ServerListingScreen = require "screens/serverlistingscreen"

local NoAuthenticationPopupDialogScreen = Class(Screen, function(self, legitCopy, failedEmail)
	Screen._ctor(self, "NoAuthenticationPopupDialogScreen")

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
	self.proot = self:AddChild(TEMPLATES.ScreenRoot())

	local title_str = STRINGS.UI.NOAUTHENTICATIONSCREEN.BAD_TITLE
	local body_str = STRINGS.UI.NOAUTHENTICATIONSCREEN.BAD_BODY
	if legitCopy then
        if failedEmail then
            title_str = STRINGS.UI.NOAUTHENTICATIONSCREEN.TITLE_FAILEDEMAIL
            body_str = STRINGS.UI.NOAUTHENTICATIONSCREEN.BODY_FAILEDEMAIL
            body_str = body_str .. "\n\n" .. STRINGS.UI.NOAUTHENTICATIONSCREEN.BODY2_FAILEDEMAIL
        else
            title_str = STRINGS.UI.NOAUTHENTICATIONSCREEN.TITLE
            body_str = STRINGS.UI.NOAUTHENTICATIONSCREEN.BODY
            body_str = body_str .. "\n\n" .. STRINGS.UI.NOAUTHENTICATIONSCREEN.BODY2
        end
    end

    local go_button_text = STRINGS.UI.NOAUTHENTICATIONSCREEN.CREATEBUTTON
    if failedEmail then
        go_button_text = STRINGS.UI.NOAUTHENTICATIONSCREEN.FAILEDEMAILBUTTON
    end
    local buttons = 
    {
        {text=go_button_text, cb = function() 
            local prefer_to_embed = true
            VisitURL(TheFrontEnd:GetAccountManager():GetSteamLoginURL(failedEmail), prefer_to_embed )
            TheFrontEnd:PopScreen()
        end},
        {text=STRINGS.UI.NOAUTHENTICATIONSCREEN.CANCELBUTTON, cb = function() 
            self:Disable()
            TheFrontEnd:PopScreen()             
        end}
    }
    if not legitCopy then
        buttons = 
        {
            {text=STRINGS.UI.NOAUTHENTICATIONSCREEN.BAD_BUTTON, cb = function() 
                self:Disable()
                TheFrontEnd:PopScreen() 
            end}
        }
    end
    	
    self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(800, 260, title_str, buttons, nil, body_str))

	self.default_focus = self.dialog
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
