require "util"
local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local PopupDialogScreen = require "screens/redux/popupdialog"

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

    local dialog_width = 640
	local menu_items = {
		{ text = STRINGS.UI.EMAILSCREEN.SUBSCRIBE, cb = function() self:Accept() end },
		{ text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function() self:Close() end },
	}

    self.top_root = self:AddChild(TEMPLATES.ScreenRoot())
    self.black = self.top_root:AddChild(TEMPLATES.BackgroundTint())
	self.dialog = self.top_root:AddChild(TEMPLATES.CurlyWindow(dialog_width, 225, STRINGS.UI.EMAILSCREEN.TITLE, menu_items))
	self.dialog.title:SetRegionSize(dialog_width, 50)

    self.root = self.top_root:AddChild(Widget("content-root"))
    self.root:SetPosition(0, 50)

	local nudgeY = -10

	local label_width = 200
	local label_height = 40
	local label_offset = 155

	local height_offset = 48

	local email_fontsize = 30

	local edit_width = 315
	local edit_bg_padding = 60

	self.bday_message = self.root:AddChild( Text( CHATFONT, 24,  STRINGS.UI.EMAILSCREEN.BIRTHDAYREASON ) )
	self.bday_message:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
	self.bday_message:SetPosition(0, -80)
	self.bday_message:SetRegionSize( dialog_width, label_height * 2 )
	self.bday_message:EnableWordWrap(true)

	local whitebar1 = self.root:AddChild(Image("images/frontend_redux.xml", "serverlist_listitem_normal.tex"))
	local whitebar2 = self.root:AddChild(Image("images/frontend_redux.xml", "serverlist_listitem_normal.tex"))
    whitebar1:SetSize(edit_width + edit_bg_padding * 3 + 20, label_height * 1.2)
    whitebar2:SetSize(edit_width + edit_bg_padding * 3 + 20, label_height * 1.2)
    whitebar1:SetPosition(5, height_offset+2+nudgeY, 0)
    whitebar2:SetPosition(5, -3+nudgeY, 0)

	self.bday_label = self.root:AddChild( Text( NEWFONT, email_fontsize, STRINGS.UI.EMAILSCREEN.BIRTHDAY ) )
	self.bday_label:SetColour(UICOLOURS.GOLD)
	self.bday_label:SetPosition( -(label_width * .5 + label_offset), -5+nudgeY, 0 )
	self.bday_label:SetRegionSize( label_width, label_height )
	self.bday_label:SetHAlign(ANCHOR_RIGHT)

	self.email_edit_widg = self.root:AddChild(TEMPLATES.LabelTextbox(STRINGS.UI.EMAILSCREEN.EMAIL, nil, label_width, edit_width, label_height, edit_bg_padding, NEWFONT, email_fontsize))
	self.email_edit_widg:SetPosition( -67, height_offset+nudgeY )

	self.email_edit = self.email_edit_widg.textbox
	self.email_edit:SetTextLengthLimit( EMAIL_MAX_LENGTH )
	self.email_edit:SetCharacterFilter( EMAIL_VALID_CHARS )

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

	self.monthSpinner = self.spinners:AddChild(TEMPLATES.StandardSpinner( months, 130, nil, nil, nil, nil, nil, true, nil, nil, .7, .7 ))
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
	self.daySpinner = self.spinners:AddChild(TEMPLATES.StandardNumericSpinner( 1, 31, 130, nil, nil, nil, nil, nil, true, nil, nil, .7, .7 ))
	self.yearSpinner = self.spinners:AddChild(TEMPLATES.StandardNumericSpinner( self.minYear, self.maxYear, 130, nil, nil, nil, nil, nil, true, nil, nil, .7, .7 ))

	self.spinners:SetPosition(48,-5+nudgeY,0)
	self.monthSpinner:SetPosition(-140, 0, 0)
	self.yearSpinner:SetPosition(140, 0, 0)

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

	self.dialog:SetFocusChangeDir(MOVE_UP, self.monthSpinner)
	self.monthSpinner:SetFocusChangeDir(MOVE_RIGHT, self.daySpinner)
	self.daySpinner:SetFocusChangeDir(MOVE_RIGHT, self.yearSpinner)
	self.yearSpinner:SetFocusChangeDir(MOVE_LEFT, self.daySpinner)
	self.daySpinner:SetFocusChangeDir(MOVE_LEFT, self.monthSpinner)
	self.monthSpinner:SetFocusChangeDir(MOVE_UP, self.email_edit_widg)
	self.daySpinner:SetFocusChangeDir(MOVE_UP, self.email_edit_widg)
	self.yearSpinner:SetFocusChangeDir(MOVE_UP, self.email_edit_widg)
	self.monthSpinner:SetFocusChangeDir(MOVE_DOWN, self.dialog)
	self.daySpinner:SetFocusChangeDir(MOVE_DOWN, self.dialog)
	self.yearSpinner:SetFocusChangeDir(MOVE_DOWN, self.dialog)
	self.email_edit_widg:SetFocusChangeDir(MOVE_DOWN, self.monthSpinner)

	self.default_focus = self.dialog

end

return EmailSignupScreen
