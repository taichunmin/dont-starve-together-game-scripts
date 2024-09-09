local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"
local TEMPLATES = require "widgets/templates"
local OptionsScreen = nil
if PLATFORM == "PS4" then
    OptionsScreen = require "screens/optionsscreen_ps4"
else
    OptionsScreen = require "screens/optionsscreen"
end

local PauseScreen = Class(Screen, function(self)
    Screen._ctor(self, "PauseScreen")

    TheInput:ClearCachedController()

    self.active = true
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

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --throw up the background
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(-40, 236, 0.75, 0.75, 50, -31))
    self.bg:SetPosition(-5,0)
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetSize(295, 307)
    self.bg.fill:SetPosition(2, 10)

    --title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(0, 105, 0)
    self.title:SetString(STRINGS.UI.PAUSEMENU.DST_TITLE)
    self.title:SetColour(0,0,0,1)

    --subtitle
    self.subtitle = self.proot:AddChild(Text(NEWFONT_SMALL, 16))
    self.subtitle:SetPosition(0, 75, 0)
    self.subtitle:SetString(STRINGS.UI.PAUSEMENU.DST_SUBTITLE)
    self.subtitle:SetColour(0,0,0,1)

    --create the menu itself
    local player = ThePlayer
    local can_save = player and player:IsValid() and player.components.health and not player.components.health:IsDead() and IsGamePurchased()
    local button_w = 160
    local button_h = 45


    local buttons = {}
    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.CONTINUE, cb=function() self:unpause() end })
    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.OPTIONS, cb=function()
        TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
            TheFrontEnd:PushScreen(OptionsScreen())
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            --Ensure last_focus is the options button since mouse can
            --unfocus this button during the screen change, resulting
            --in controllers having no focus when toggled on from the
            --options screen
            self.last_focus = self.menu.items[2]
        end)
    end })
    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.DISCONNECT, cb=function() self:doconfirmquit()	end})
    if IsRail() then
	    table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.ISSUE, cb = function() VisitURL("http://plat.tgp.qq.com/forum/index.html#!/2000004/detail/115888") end })
	else
		table.insert(buttons, {text=STRINGS.UI.PAUSEMENU.ISSUE, cb = function() VisitURL("http://forums.kleientertainment.com/klei-bug-tracker/dont-starve-together/") end })
	end

    self.menu = self.proot:AddChild(Menu(buttons, -button_h, false))
    self.menu:SetPosition(0, 35, 0)
    for i,v in pairs(self.menu.items) do
		if IsRail() then
			if v:GetText() == STRINGS.UI.PAUSEMENU.ISSUE then
				v:Select()
				v:SetHoverText(STRINGS.UI.PAUSEMENU.NOT_YET_OPEN)
			end
		end
        v:SetScale(.7)
    end

    TheInputProxy:SetCursorVisible(true)
    self.default_focus = self.menu
end)

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

return PauseScreen
