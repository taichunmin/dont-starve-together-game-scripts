local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local TextEditLinked = require "widgets/texteditlinked"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local ThankYouPopup = require "screens/thankyoupopup"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local NUM_CODE_GROUPS = 5
local DIGITS_PER_GROUP = 4
local DIGIT_WIDTH = 21
local CODE_LENGTH = 24
-- Codes are 5 groups of 4 characters (letters and numbers) separated by hyphens
-- i and o are not allowed
local VALID_CHARS = [[abcdefghjklmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ1234567890]]



local RedeemDialog = Class(Screen, function(self)
	Screen._ctor(self, "RedeemDialog")

    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    local buttons =
    {
        {text=STRINGS.UI.REDEEMDIALOG.SUBMIT, cb = function() self:DoSubmitCode() end },
        {text=STRINGS.UI.REDEEMDIALOG.CANCEL, cb = function() self:Close() end }
    }
	if IsConsole() then
        VALID_CHARS = [[abcdefghjklmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ1234567890-]]
		buttons = nil
		NUM_CODE_GROUPS = 1
		DIGITS_PER_GROUP = CODE_LENGTH --allow the users to include the hyphens or spaces when they enter text
	end

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BrightMenuBackground())

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        { x = -80, y = 180, scale = 0.75 },
        { x = 180, y = 176, scale = 0.75 },
    } ))

	self.dialog = self.root:AddChild(TEMPLATES.CurlyWindow(480, 220, STRINGS.UI.REDEEMDIALOG.TITLE, buttons, nil, ""))

    self.proot = self.root:AddChild(Widget("proot"))
    self.proot:SetPosition(0, 50)

    self.title = self.dialog.title

    self:MakeTextEntryBox(self.proot)

	-- server response text
    self.text = self.dialog.body
	if IsConsole() then
        self.text:SetPosition(0, 45)
    else
        self.text:SetPosition(0, 60)
    end
    self.text:SetVAlign(ANCHOR_TOP)
    self.text:SetHAlign(ANCHOR_MIDDLE)
    self.text:Hide()

    self.fineprint = self.proot:AddChild(Text(CHATFONT, 17))
    self.fineprint:SetString(STRINGS.UI.REDEEMDIALOG.LEGALESE)
    self.fineprint:SetPosition(0, -75)
    self.fineprint:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
    self.fineprint:EnableWordWrap(true)
    self.fineprint:SetRegionSize(520, 160)
    self.fineprint:SetVAlign(ANCHOR_MIDDLE)

	self.redeem_in_progress = false

	if IsNotConsole() then
		self.buttons = buttons
	    self.submit_btn = self.dialog.actions.items[1]
	    self.submit_btn:Select()

	    local function SequenceFocusVertical(up, down)
	        up:SetFocusChangeDir(MOVE_DOWN, down)
	        down:SetFocusChangeDir(MOVE_UP, up)
	    end
	    SequenceFocusVertical(self.entrybox, self.dialog.actions)
	end

	self.default_focus = self.dialog
	self.firsttime = true
end)

function RedeemDialog:OnBecomeActive()
    self._base.OnBecomeActive(self)
    self.entrybox.textboxes[1]:SetFocus()
    if IsNotConsole() or self.firsttime then
    	self.entrybox.textboxes[1]:SetEditing(true)
    	self.firsttime = false
    end

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end
end

function RedeemDialog:OnBecomeInactive()
    self._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function RedeemDialog:MakeTextEntryBox(parent)
    local entrybox = parent:AddChild(Widget("entrybox"))
    local box_size = DIGIT_WIDTH * DIGITS_PER_GROUP
    local box_y = 40

   	entrybox.bgs = {}
    entrybox.textboxes = {}

    for i = 1, NUM_CODE_GROUPS do
		entrybox.textboxes[i] = parent:AddChild(TextEditLinked( CODEFONT, 26, nil, UICOLOURS.BLACK ) )
		entrybox.textboxes[i]:SetForceEdit(true)
		entrybox.textboxes[i]:SetRegionSize( box_size, box_y )
		entrybox.textboxes[i]:SetHAlign(ANCHOR_MIDDLE)
		entrybox.textboxes[i]:SetVAlign(ANCHOR_MIDDLE)
		entrybox.textboxes[i]:SetTextLengthLimit(DIGITS_PER_GROUP)
		entrybox.textboxes[i]:SetCharacterFilter( VALID_CHARS )
		entrybox.textboxes[i]:SetTextConversion( "i", "1" )
		entrybox.textboxes[i]:SetTextConversion( "I", "1" )
		entrybox.textboxes[i]:SetTextConversion( "o", "0" )
		entrybox.textboxes[i]:SetTextConversion( "O", "0" )
		entrybox.textboxes[i]:EnableWordWrap(false)
		entrybox.textboxes[i]:EnableScrollEditWindow(false)
		entrybox.textboxes[i]:SetForceUpperCase(true)
		entrybox.textboxes[i]:SetPosition(i*102 - (NUM_CODE_GROUPS/2+0.5)*102, 2, 0)

		if IsConsole() then
			entrybox.textboxes[i].bg = entrybox.textboxes[i]:AddChild( Image("images/global_redux.xml", "textbox3_gold_normal.tex") )
		else
			entrybox.textboxes[i].bg = entrybox.textboxes[i]:AddChild( Image("images/global_redux.xml", "textbox3_gold_tiny_normal.tex") )
		end
		entrybox.textboxes[i].bg:ScaleToSize( box_size + 23, box_y + 10 )
		entrybox.textboxes[i].bg:SetPosition(-1, 2)
		entrybox.textboxes[i].bg:MoveToBack()

		if IsConsole() then
			entrybox.textboxes[i]:SetFocusedImage( entrybox.textboxes[i].bg, "images/global_redux.xml", "textbox3_gold_normal.tex", "textbox3_gold_hover.tex", "textbox3_gold_focus.tex" )
		else
			entrybox.textboxes[i]:SetFocusedImage( entrybox.textboxes[i].bg, "images/global_redux.xml", "textbox3_gold_tiny_normal.tex", "textbox3_gold_tiny_hover.tex", "textbox3_gold_tiny_focus.tex" )
		end

		entrybox.textboxes[i].OnTextInputted = function()
			for i = 1, NUM_CODE_GROUPS do
				if string.len(entrybox.textboxes[i]:GetString()) ~= entrybox.textboxes[i].limit then
					-- if any box is full, we're not ready yet
					if IsConsole() then
						self.entrybox.textboxes[1]:SetFocus()
					else
						self.submit_btn:Select()
					end
					return
				end
			end
			if IsNotConsole() then
				self.submit_btn:Unselect()
			end
		end

		entrybox.textboxes[i].OnTextEntered = function()
			if not self.redeem_in_progress then
				local redeem_code = ""
                if IsConsole() then
                    redeem_code = entrybox.textboxes[1]:GetString()
                    redeem_code = redeem_code:gsub("-", "")
                    redeem_code = redeem_code:sub(1,4) .. "-" .. redeem_code:sub(5,8) .. "-" .. redeem_code:sub(9,12) .. "-" .. redeem_code:sub(13,16) .. "-" .. redeem_code:sub(17,20)
                    entrybox.textboxes[1]:SetString(redeem_code)
                else
                    for i = 1, NUM_CODE_GROUPS do
					    if i ~= 1 then
						    redeem_code	= redeem_code .. "-"
					    end
					    redeem_code	= redeem_code .. entrybox.textboxes[i]:GetString()
				    end
                end

				if string.len(redeem_code) == CODE_LENGTH then
					self.text:SetString("")
					if IsConsole() then
						self.entrybox.textboxes[1]:SetFocus()
					else
						self.submit_btn:Select()
					end
					self.redeem_in_progress = true
					TheItems:RedeemCode(redeem_code, function(success, status, item_type, currency, currency_amt, category, message)
						self:DisplayResult(success, status, item_type, currency, currency_amt, category, message)
					end)
				end
			end
		end

		entrybox.textboxes[i].OnLargePaste = function()
			local clipboard = TheSim:GetClipboardData()

			--clear invalid characters
			local res = ""
			for i=1,#clipboard do
				local char = clipboard:sub(i,i)
				if string.find(VALID_CHARS, char, 1, true) then
					res = res .. char
				end
			end
			clipboard = res

			local i = 1
			while #clipboard > 0 and i <= NUM_CODE_GROUPS do
				local seg = clipboard:sub(1,DIGITS_PER_GROUP)
				clipboard = clipboard:sub(DIGITS_PER_GROUP+1)
				entrybox.textboxes[i]:SetString(seg)
				entrybox.textboxes[i]:SetEditing(true)
				i = i + 1
			end

			return true
		end

		if i > 1 then
			entrybox.textboxes[i-1]:SetNextTextEdit(entrybox.textboxes[i])
			entrybox.textboxes[i]:SetLastTextEdit(entrybox.textboxes[i-1])
		end
   	end

    self.entrybox = entrybox
end

function RedeemDialog:DisplayResult(success, status, item_type, currency, currency_amt, category, message)
	-- Possible responses when attempting to query server:
	--success=true, status="ACCEPTED"
	--success=false, status="INVALID_CODE"
	--success=false, status="ALREADY_REDEEMED"
	--success=false, status="FAILED_TO_CONTACT"

	if IsNotConsole() then
    	self.submit_btn:Unselect()
    end
    self.redeem_in_progress = false

	--DO WE DEAL WITH item_type = FROMNUM???
	print( "RedeemDialog:DisplayResult", success, status, item_type, currency, currency_amt, category, message )
	if success then
		local items = {} -- early access thank you gifts
		table.insert(items, {item=item_type, item_id=0, currency=currency, currency_amt=currency_amt, gifttype=category, message=message})

		for i = 1, NUM_CODE_GROUPS do
			self.entrybox.textboxes[i]:SetString("")
		end

		self.title:Show()
		self.text:Hide()

        local thankyou_popup = ThankYouPopup(items)
        TheFrontEnd:PushScreen(thankyou_popup)
	else
		self.title:Hide()

		self.text:SetString(STRINGS.UI.REDEEMDIALOG[status] or STRINGS.UI.REDEEMDIALOG["FAILED_TO_CONTACT"])
		self.text:Show()
	end
end

function RedeemDialog:OnRawKey(key, down)
    if RedeemDialog._base.OnRawKey(self, key, down) then return true end

	if down and TheInput:IsPasteKey(key) then
		local clipboard = TheSim:GetClipboardData()
		if #clipboard > DIGITS_PER_GROUP then
			self.entrybox.textboxes[1]:OnLargePaste()
			return true
		else
			for i = 1, NUM_CODE_GROUPS do
				if #self.entrybox.textboxes[i]:GetString() < DIGITS_PER_GROUP then
					self.entrybox.textboxes[i]:SetEditing(true)
					self.entrybox.textboxes[i]:OnRawKey(key, down)
					return true
				end
			end
		end
	end
	return false
end

function RedeemDialog:OnControl(control, down)
    if RedeemDialog._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        if self.buttons and #self.buttons > 1 and self.buttons[#self.buttons] then
            self.buttons[#self.buttons].cb()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        end
    end

    if IsConsole() and control == CONTROL_CANCEL and not down then
    	self:Close()
    end
end

function RedeemDialog:DoSubmitCode()
	self.entrybox.textboxes[1]:OnTextEntered()
end

function RedeemDialog:Close()
    TheFrontEnd:FadeBack()
end

function RedeemDialog:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
	if self.buttons and #self.buttons > 1 and self.buttons[#self.buttons] then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end

    if IsConsole() then
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    end
	return table.concat(t, "  ")
end

return RedeemDialog
