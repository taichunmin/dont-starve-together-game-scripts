local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/redux/popupdialog"
local TEMPLATES = require "widgets/redux/templates"
local OptionsScreen = require "screens/redux/optionsscreen"
local ScrapbookScreen = require "screens/redux/scrapbookscreen"
local UserCommandPickerScreen = require "screens/redux/usercommandpickerscreen"

local UserCommands = require "usercommands"

local PauseScreen = Class(Screen, function(self)
    Screen._ctor(self, "PauseScreen")

    TheInput:ClearCachedController()

    self.active = true
	self.owner = ThePlayer

    SetPause(true,"pause")

    --darken everything behind the dialog
    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0,0,0,0) -- invisible, but clickable!
    self.black:SetOnClick(function() self:unpause() end)
    self.black:SetHelpTextMessage("")

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    TheInputProxy:SetCursorVisible(true)

    self.inst:ListenForEvent("serverpauseddirty", function() self:UpdateText() end, TheWorld)

    SetAutopaused(true)

    self.will_autopause = Profile:GetAutopauseEnabled() and #GetPlayerClientTable() == 1
    self:BuildMenu()
    self.will_autopause = nil
    
    self.inst:DoTaskInTime(1, function() self:UpdateText() end)
end)

function PauseScreen:BuildMenu()
    local rebuild = false
    if self.menu then
        self.menu:Kill()
        self.menu = nil
        rebuild = true
    end
    if self.bg then
        self.bg:Kill()
        self.bg = nil
    end
    self.pause_button_index = nil
    self.options_button_index = nil

    --create the menu itself
    local button_h = 50

    local buttons = {}
	table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.PLAYERSTATUSSCREEN, cb=function()
		self:unpause()
		self.owner.HUD:ShowPlayerStatusScreen(true)
	end })

    if TheNet:GetIsServerAdmin() and (#GetPlayerClientTable() > 1 or not Profile:GetAutopauseEnabled() or TheNet:IsServerPaused(true)) then
        table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.PAUSE_SERVER, cb=function()
            self:ToggleServerPause()
        end })
        self.pause_button_index = #buttons
    end

	if #UserCommands.GetServerActions(self.owner) > 0 then
		table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.SERVERACTIONS, cb=function()
			self:Hide()
			TheFrontEnd:PushScreen(UserCommandPickerScreen(self.owner, nil, function() self:Show() end))
		end })
	end

    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.OPTIONS, cb=function()
        TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
            TheFrontEnd:PushScreen(OptionsScreen())
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            --Ensure last_focus is the options button since mouse can
            --unfocus this button during the screen change, resulting
            --in controllers having no focus when toggled on from the
            --options screen
            self.last_focus = self.menu.items[self.options_button_index]
        end)
    end })
    self.options_button_index = #buttons

    if IsRail() then
        table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.ISSUE, cb = function() VisitURL("http://plat.tgp.qq.com/forum/index.html#/2000004?type=11") end })
	elseif IsNotConsole() then
		if BRANCH == "staging" then
		    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.ISSUE, cb = function() VisitURL("https://forums.kleientertainment.com/klei-bug-tracker/dont-starve-together-beta-branch/") end })
		else
			table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.ISSUE, cb = function() VisitURL("http://forums.kleientertainment.com/klei-bug-tracker/dont-starve-together/") end })
		end
	end

    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.SCRAPBOOK, cb=function()
        TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
            TheFrontEnd:PushScreen(ScrapbookScreen())
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            --Ensure last_focus is the options button since mouse can
            --unfocus this button during the screen change, resulting
            --in controllers having no focus when toggled on from the
            --options screen
            self.last_focus = self.menu.items[self.scrapbook_button_index]
        end)
    end })
    self.scrapbook_button_index = #buttons

    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.DISCONNECT, cb=function() self:doconfirmquit()	end})
    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.CLOSE, cb=function() self:unpause() end })

    --throw up the background
	local height = button_h * #buttons + 30	-- consoles are shorter since they don't have the '
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(0, height, STRINGS.UI.PAUSEMENU.DST_TITLE, nil, nil, STRINGS.UI.PAUSEMENU.DST_SUBTITLE))
    self.bg.body:SetVAlign(ANCHOR_TOP)
    self.bg.body:SetSize(20)

    --create the menu itself
    self.menu = self.proot:AddChild(Menu(buttons, -button_h, false, "carny_xlong", nil, 30))
	local y_pos = (button_h * (#buttons - 1) / 2)
    self.menu:SetPosition(0, y_pos, 0)
    for i,v in pairs(self.menu.items) do
        v:SetScale(.7)
    end
    self.default_focus = self.menu

    if rebuild then
        self.last_focus = self.menu.items[self.options_button_index]
    end

    self:UpdateText()
end

function PauseScreen:UpdateText()
    if TheNet:IsServerPaused() or self.will_autopause then
        self:PauseText()
    else
        self:UnpauseText()
    end
end

function PauseScreen:PauseText()
    self.bg.title:SetString(TheNet:IsServerPaused(true) and STRINGS.UI.PAUSEMENU.PAUSED_DST_TITLE or STRINGS.UI.PAUSEMENU.AUTOPAUSED_DST_TITLE)
    self.bg.body:SetString(STRINGS.UI.PAUSEMENU.PAUSED_DST_SUBTITLE)
    if self.pause_button_index then
        self.menu:EditItem(self.pause_button_index, TheNet:IsServerPaused(true) and STRINGS.UI.PAUSEMENU.UNPAUSE_SERVER or STRINGS.UI.PAUSEMENU.PAUSE_SERVER)
    end
end

function PauseScreen:UnpauseText()
    self.bg.title:SetString(STRINGS.UI.PAUSEMENU.DST_TITLE)
    self.bg.body:SetString(STRINGS.UI.PAUSEMENU.DST_SUBTITLE)
    if self.pause_button_index then
        self.menu:EditItem(self.pause_button_index, STRINGS.UI.PAUSEMENU.PAUSE_SERVER)
    end
end

function PauseScreen:ToggleServerPause()
    SetServerPaused()
end

function PauseScreen:unpause()
    TheInput:CacheController()
    self.active = false
    TheFrontEnd:PopScreen(self)
    SetPause(false)
    TheWorld:PushEvent("continuefrompause")
end

function PauseScreen:doconfirmquit()
 	self.active = false

	local function doquit()
        if not self.popped_autopause then
            SetAutopaused(false)
            self.popped_autopause = true
        end
		self.parent:Disable()
		self.menu:Disable()
		--self.afk_menu:Disable()
		DoRestart(true)
	end

	if TheNet:GetIsHosting() then
		local confirm = PopupDialogScreen(STRINGS.UI.PAUSEMENU.HOSTQUITTITLE, STRINGS.UI.PAUSEMENU.HOSTQUITBODY, {{text=STRINGS.UI.PAUSEMENU.YES, cb = doquit},{text=STRINGS.UI.PAUSEMENU.NO, cb = function()
			TheFrontEnd:PopScreen()
		end}  })
		if JapaneseOnPS4() then
			confirm:SetTitleTextSize(40)
			confirm:SetButtonTextSize(30)
		end
		TheFrontEnd:PushScreen(confirm)
	else
		local confirm = PopupDialogScreen(STRINGS.UI.PAUSEMENU.CLIENTQUITTITLE, STRINGS.UI.PAUSEMENU.CLIENTQUITBODY, {{text=STRINGS.UI.PAUSEMENU.YES, cb = doquit},{text=STRINGS.UI.PAUSEMENU.NO, cb = function() TheFrontEnd:PopScreen() end}  })
		if JapaneseOnPS4() then
			confirm:SetTitleTextSize(40)
			confirm:SetButtonTextSize(30)
		end
		TheFrontEnd:PushScreen(confirm)
	end
end

function PauseScreen:OnControl(control, down)
    if PauseScreen._base.OnControl(self,control, down) then
        return true
    elseif not down and (control == CONTROL_PAUSE or control == CONTROL_CANCEL) then
        self:unpause()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function PauseScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function PauseScreen:OnBecomeActive()
	PauseScreen._base.OnBecomeActive(self)
	-- Hide the topfade, it'll obscure the pause menu if paused during fade. Fade-out will re-enable it
	TheFrontEnd:HideTopFade()
end

function PauseScreen:OnDestroy()
    if not self.popped_autopause then
        SetAutopaused(false)
        self.popped_autopause = true
    end

	PauseScreen._base.OnDestroy(self)
end

function PauseScreen:GetHelpText()
	local t = {}
	local controller_id = TheInput:GetControllerID()

	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.PAUSEMENU.CLOSE)

	return table.concat(t, "  ")
end

return PauseScreen
