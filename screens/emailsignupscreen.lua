require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"

local PopupDialogScreen = require "screens/popupdialog"

local UI_ATLAS = "images/ui.xml"
local EMAIL_VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@!#$%&'*+-/=?^_`{|}~"
local EMAIL_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local MIN_AGE = 3 -- ages less than this prompt error message, eg. if they didn't change the date at all

local EmailSignupScreen = Class(Screen, function(self)
	Screen._ctor(self, "EmailSignupScreen")

	self:DoInit()

end)

function EmailSignupScreen:OnControl(control, down)
	if EmailSignupScreen._base.OnControl(self, control, down) then return true end

	-- Force these damn things to gobble controls if they're editing (stupid missing focus/hover distinction)
    if (self.email_edit and self.email_edit.editing) or (TheInput:ControllerAttached() and self.email_edit.focus and control == CONTROL_ACCEPT) then
        self.email_edit:OnControl(control, down)
        return true
    end

	if not down and control == CONTROL_CANCEL then
		self:Close()
		return true
	end
end

function EmailSignupScreen:Accept()
	if self:Save() then
		-- wait for callback
	end
end

function EmailSignupScreen:OnSubmitCancel()
	print('EmailSignupScreen:OnSubmitCancel()')
	if self.submitscreen then
		print('...closing submit screen')
		self.submitscreen:Close()
		self.submitscreen = nil
	end
end

function EmailSignupScreen:OnPostComplete( result, isSuccessful, resultCode )
	print('EmailSignupScreen:OnPostComplete()', isSuccessful, resultCode, result)

	-- if we don't have a submitscreen then the user cancelled before we got the callback
	if self.submitscreen then
		print('...closing submit screen')
		self.submitscreen:Close()
		self.submitscreen = nil

		-- isSuccessful only tells us that the server successfully returned some result
		-- we still need to check if that result was an error or not
		if isSuccessful and (resultCode == 200) then
			self:Close()

			TheFrontEnd:PushScreen(
				PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPSUCCESSTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPSUCCESS,
				  { { text = STRINGS.UI.EMAILSCREEN.OK, cb =
						function()
							TheFrontEnd:PopScreen()
						end
					} }
				  )
			)
		else
			TheFrontEnd:PushScreen(
				PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPFAILTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPFAIL,
				  { { text = STRINGS.UI.EMAILSCREEN.OK, cb =
						function()
							TheFrontEnd:PopScreen()
						end
					} }
				  )
			)
		end
	else
		print('...no submit screen, user cancelled?')
	end
end

function EmailSignupScreen:Save()
	local email = self.email_edit:GetString()
	print ("EmailSignupScreen:Save()", email)
	
	local bmonth = self.monthSpinner:GetSelectedIndex()
	local bday = self.daySpinner:GetSelectedIndex()
	local byear = self.yearSpinner:GetSelectedIndex()
	
	if not self:IsValidEmail(email) then
		TheFrontEnd:PushScreen(
			
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.INVALIDEMAILTITLE, STRINGS.UI.EMAILSCREEN.INVALIDEMAIL,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end } }
			  )
		)
		return false
	end
	
	if not self:IsValidBirthdate(bday, bmonth, byear) then
		TheFrontEnd:PushScreen(
			PopupDialogScreen( STRINGS.UI.EMAILSCREEN.INVALIDDATETITLE, STRINGS.UI.EMAILSCREEN.INVALIDDATE,
			  { { text = STRINGS.UI.EMAILSCREEN.OK, cb = function() TheFrontEnd:PopScreen() end } }
			  )
		)
		return false
	end
	

	self.submitscreen = PopupDialogScreen( STRINGS.UI.EMAILSCREEN.SIGNUPSUBMITTITLE, STRINGS.UI.EMAILSCREEN.SIGNUPSUBMIT,
		  { { text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function(...) self:OnSubmitCancel(...) end } } )
	TheFrontEnd:PushScreen(self.submitscreen)

	local birth_date = byear .. "-" .. bmonth .. "-" .. bday
	print ("Birthday:", birth_date)
	
	local query = GAME_SERVER.."/email/subscribe/" .. email

	TheSim:QueryServer(
		query,
		function(...) self:OnPostComplete(...) end,
		"POST",
		json.encode({
			birthday = birth_date,
		}) 
	)
	return true
end

function EmailSignupScreen:IsValidBirthdate(day, month, year)
	print("EmailSignupScreen:IsValidBirthdate", day, month, year, self.minYear, self.maxYear)
	if day < 1 or day > 31 then
		return false
	end
	if month < 1 or month > 12 then
		return false
	end
	if year < self.minYear or year > self.maxYear - MIN_AGE then
		return false
	end
	return true
end

-- allow (anything)@(anything).(anything)
-- unless you want to write whatever unnecessarily complex expression would be required to be more accurate without excluding valid addresses
-- http://en.wikipedia.org/wiki/Email_address#Syntax

function EmailSignupScreen:IsValidEmail(email)
	local matchPattern = "^[%w%p]+@[%w%p]+%.[%w%p]+$"
	return string.match(email, matchPattern)
end

function EmailSignupScreen:Close()
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen(self)
end

function EmailSignupScreen:DoInit()

	TheInput:EnableDebugToggle(false)

	self.maxYear = tonumber(os.date("%Y"))
	self.minYear = self.maxYear - 130

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
	
	self.root = self.proot:AddChild(Widget("ROOT"))
    --self.root:SetPosition(-RESOLUTION_X/2,-RESOLUTION_Y/2,0)
    

	--throw up the background
    self.bg = self.root:AddChild(TEMPLATES.CurlyWindow(130, 150, 1, 1, 68, -40))
    self.bg.fill = self.root:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
	self.bg.fill:SetScale(.92, .68)
	self.bg.fill:SetPosition(8, 12)

	local nudgeY = -10

    local title_size = 300
    local title_offset = 100

    self.title = self.root:AddChild(Text(BUTTONFONT, 45))
    self.title:SetColour(0,0,0,1)
    self.title:SetString(STRINGS.UI.EMAILSCREEN.TITLE)
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)
	--self.title:SetRegionSize( title_size, 50 )
    self.title:SetPosition(5, title_offset+nudgeY, 0)


	local label_width = 200
	local label_height = 40
	local label_offset = 155

	local space_between = 30
	local height_offset = 48

	local email_fontsize = 30

	local edit_width = 315
	local edit_bg_padding = 60
	
	self.bday_message = self.root:AddChild( Text( NEWFONT, 24,  STRINGS.UI.EMAILSCREEN.BIRTHDAYREASON ) )
	self.bday_message:SetColour(0,0,0,1)
	self.bday_message:SetPosition( 5, -height_offset-10+nudgeY, 0 )
	self.bday_message:SetRegionSize( 700, label_height * 2 )
	self.bday_message:EnableWordWrap(true)
	--self.bday_message:SetHAlign(ANCHOR_LEFT)

	local whitebar1 = self.root:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
	local whitebar2 = self.root:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
    whitebar1:SetSize(edit_width + edit_bg_padding * 3 + 20, label_height * 1.2)
    whitebar2:SetSize(edit_width + edit_bg_padding * 3 + 20, label_height * 1.2)
    whitebar1:SetPosition(5, height_offset+2+nudgeY, 0)
    whitebar2:SetPosition(5, -3+nudgeY, 0)

    self.email_label = self.root:AddChild( Text( NEWFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.EMAIL ) )
    self.email_label:SetColour(0,0,0,1)
	self.email_label:SetPosition( -(label_width * .5 + label_offset), height_offset+nudgeY, 0 )
	self.email_label:SetRegionSize( label_width, label_height )
	self.email_label:SetHAlign(ANCHOR_RIGHT)

	self.bday_label = self.root:AddChild( Text( NEWFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.BIRTHDAY ) )
	self.bday_label:SetColour(0,0,0,1)
	self.bday_label:SetPosition( -(label_width * .5 + label_offset), -5+nudgeY, 0 )
	self.bday_label:SetRegionSize( label_width, label_height )
	self.bday_label:SetHAlign(ANCHOR_RIGHT)

	self.email_edit_widg = self.proot:AddChild(Widget("emailedit"))
	self.email_edit_widg:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset+nudgeY )

	self.email_edit_bg = self.email_edit_widg:AddChild( Image() )
    self.email_edit_bg:SetTexture( "images/textboxes.xml", "textbox2_grey.tex" )
    self.email_edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )
	
	self.email_edit = self.email_edit_widg:AddChild( TextEdit( NEWFONT, 25, "" ) )
	self.email_edit:SetRegionSize( edit_width, label_height )
	self.email_edit:SetHAlign(ANCHOR_LEFT)
	self.email_edit:SetFocusedImage( self.email_edit_bg, "images/textboxes.xml", "textbox2_grey.tex", "textbox2_gold.tex", "textbox2_gold_greyfill.tex" )
	self.email_edit:SetTextLengthLimit( EMAIL_MAX_LENGTH )
	self.email_edit:SetCharacterFilter( EMAIL_VALID_CHARS )
	self.email_edit:SetForceEdit(true)

	self.email_edit_widg.focus_forward = self.email_edit

	local months = {
		{ text = STRINGS.UI.EMAILSCREEN.JAN, days = 31},
		{ text = STRINGS.UI.EMAILSCREEN.FEB, days = 29},
		{ text = STRINGS.UI.EMAILSCREEN.MAR, days = 31},
		{ text = STRINGS.UI.EMAILSCREEN.APR, days = 30},
		{ text = STRINGS.UI.EMAILSCREEN.MAY, days = 31},
		{ text = STRINGS.UI.EMAILSCREEN.JUN, days = 30},
		{ text = STRINGS.UI.EMAILSCREEN.JUL, days = 31},
		{ text = STRINGS.UI.EMAILSCREEN.AUG, days = 31},
		{ text = STRINGS.UI.EMAILSCREEN.SEP, days = 30},
		{ text = STRINGS.UI.EMAILSCREEN.OCT, days = 31},
		{ text = STRINGS.UI.EMAILSCREEN.NOV, days = 30},
		{ text = STRINGS.UI.EMAILSCREEN.DEC, days = 31},
	}	

	self.spinners = self.root:AddChild(Widget("spinners"))
	
	self.monthSpinner = self.spinners:AddChild(Spinner( months, 130, nil, nil, nil, nil, nil, true, nil, nil, .7, .7 ))
	self.monthSpinner.OnChanged = 
		function( _, data )
			local monthName = self.monthSpinner:GetSelectedText()
			local maxDay = 31
			for i,v in pairs(months) do
				if monthName == v.text then
					maxDay = v.days
				end
			end
			self.daySpinner.max = maxDay
			if self.daySpinner:GetSelectedIndex() > self.daySpinner.max then
				self.daySpinner:SetSelectedIndex(self.daySpinner.max)
			end
		end
	self.daySpinner = self.spinners:AddChild(NumericSpinner( 1, 31, 130, nil, nil, nil, nil, nil, true, nil, nil, .7, .7 ))
	self.yearSpinner = self.spinners:AddChild(NumericSpinner( self.minYear, self.maxYear, 130, nil, nil, nil, nil, nil, true, nil, nil, .7, .7 ))

	self.spinners:SetPosition(48,-5+nudgeY,0)
	self.monthSpinner:SetPosition(-140, 0, 0)
	self.yearSpinner:SetPosition(140, 0, 0)

	self.monthSpinner:SetTextColour(0,0,0,1)
	self.daySpinner:SetTextColour(0,0,0,1)
	self.yearSpinner:SetTextColour(0,0,0,1)

	self.daySpinner:SetSelectedIndex(tonumber(os.date("%d")))
	self.monthSpinner:SetSelectedIndex(tonumber(os.date("%m")))
	self.yearSpinner:SetSelectedIndex(tonumber(os.date("%Y")))

--[[	local spinners = {}

	table.insert( spinners, { 160, self.monthSpinner, tonumber(os.date("%m")), 2 } )
	table.insert( spinners, { 110, self.daySpinner, tonumber(os.date("%d")), 2 } )
	table.insert( spinners, { 110, self.yearSpinner, tonumber(os.date("%Y")), 4 } )

	self:AddSpinners( spinners )
-]]	
	
	self.monthSpinner:SetWrapEnabled(true)
	self.daySpinner:SetWrapEnabled(true)
	self.yearSpinner:SetWrapEnabled(false)
	
	--[[
	local month_edit_w = 20 + edit_bg_padding
	local day_edit_w = 20 + edit_bg_padding
	local year_edit_w = 50 + edit_bg_padding
	

	local bday_fields = { 
		{ name=STRINGS.UI.EMAILSCREEN.MONTH, width=30 },
		{ name=STRINGS.UI.EMAILSCREEN.DAY, width=30 },
		{ name=STRINGS.UI.EMAILSCREEN.YEAR, width=50 },
	}
	--]]
	
	local menu_items = {
		{ text = STRINGS.UI.EMAILSCREEN.SUBSCRIBE, cb = function() self:Accept() end },
		{ text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function() self:Close() end },
	}

	self.menu = self.root:AddChild(Menu(menu_items, 250, true))
	self.menu:SetPosition(-100, -132)
	self.menu:SetScale(.85)

	self.menu:SetFocusChangeDir(MOVE_UP, self.monthSpinner)
	self.monthSpinner:SetFocusChangeDir(MOVE_RIGHT, self.daySpinner)
	self.daySpinner:SetFocusChangeDir(MOVE_RIGHT, self.yearSpinner)
	self.yearSpinner:SetFocusChangeDir(MOVE_LEFT, self.daySpinner)
	self.daySpinner:SetFocusChangeDir(MOVE_LEFT, self.monthSpinner)
	self.monthSpinner:SetFocusChangeDir(MOVE_UP, self.email_edit_widg)
	self.daySpinner:SetFocusChangeDir(MOVE_UP, self.email_edit_widg)
	self.yearSpinner:SetFocusChangeDir(MOVE_UP, self.email_edit_widg)
	self.monthSpinner:SetFocusChangeDir(MOVE_DOWN, self.menu)
	self.daySpinner:SetFocusChangeDir(MOVE_DOWN, self.menu)
	self.yearSpinner:SetFocusChangeDir(MOVE_DOWN, self.menu)
	self.email_edit_widg:SetFocusChangeDir(MOVE_DOWN, self.monthSpinner)	

	self.default_focus = self.menu

end

return EmailSignupScreen
