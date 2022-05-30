local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local DressupPanel = require "widgets/dressuppanel"
local TEMPLATES = require "widgets/templates"

local SCREEN_OFFSET = -.285 * RESOLUTION_X

local CharacterLoadoutPopupScreen = Class(Screen, function(self, profile, character)
	Screen._ctor(self, "CharacterLoadoutPopupScreen")

	self.profile = profile

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
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.heroportrait = self.proot:AddChild(Image())
    self.heroportrait:SetScale(.8)
    self.heroportrait:SetPosition(-180, 30)

    self.dressup = self.proot:AddChild(DressupPanel(self, profile, nil, function() self:SetPortrait() end, nil, nil, false))
    self.dressup:SetPosition(140, 35)
    self.dressup:SetCurrentCharacter(character)

    self:SetPortrait()

    local spacing = 225
    local buttons = {{text = STRINGS.UI.WARDROBE_POPUP.CANCEL, cb = function() self:Cancel() end},
                     {text = STRINGS.UI.WARDROBE_POPUP.RESET, cb = function() self:Reset() end},
                     {text = STRINGS.UI.WARDROBE_POPUP.SET, cb = function() self:Close() end},
                  }

    self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
    self.menu:SetPosition(-230, -280, 0)


	self.default_focus = self.menu

	self.dressup:ReverseFocus()
	self.menu.reverse = true

    self:DoFocusHookups()
end)

function CharacterLoadoutPopupScreen:OnDestroy()
    self._base.OnDestroy(self)
end

function CharacterLoadoutPopupScreen:OnBecomeActive()
    self._base.OnBecomeActive(self)
    if TheInput:ControllerAttached() then
        self.default_focus:SetFocus()
    end
end

function CharacterLoadoutPopupScreen:DoFocusHookups()
	self.menu:SetFocusChangeDir(MOVE_UP, self.dressup)
    self.dressup:SetFocusChangeDir(MOVE_DOWN, self.menu)
end

function CharacterLoadoutPopupScreen:Cancel()
	self:Reset()
	self:Close()
end

function CharacterLoadoutPopupScreen:Reset()
	self.dressup:Reset()
	self:SetPortrait()
end

function CharacterLoadoutPopupScreen:Close()
	-- Gets the current skin names (and sets them as the character default)
	local skins = self.dressup:GetSkinsForGameStart()

    self.dressup:OnClose()
    TheFrontEnd:PopScreen(self)
end

function CharacterLoadoutPopupScreen:SetPortrait()
	local herocharacter = self.dressup.currentcharacter
	local name = self.dressup:GetBaseSkin()

	if name and name ~= "" then
		self.heroportrait:SetTexture("bigportraits/"..name..".xml", name.."_oval.tex", herocharacter.."_none.tex")
	else
		if softresolvefilepath("bigportraits/"..herocharacter.."_none.xml") then
			self.heroportrait:SetTexture("bigportraits/"..herocharacter.."_none.xml", herocharacter.."_none_oval.tex")
		else
			--Note(Peter): this isn't used in the FE anymore. Legacy from shared in-game code.
			-- mod characters
			self.heroportrait:SetTexture("bigportraits/"..herocharacter..".xml", herocharacter..".tex")
		end
	end
end

function CharacterLoadoutPopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	return table.concat(t, "  ")
end

function CharacterLoadoutPopupScreen:OnControl(control, down)
	if CharacterLoadoutPopupScreen._base.OnControl(self, control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        self:Cancel()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end

   	if down then
	 	if control == CONTROL_PREVVALUE then  -- r-stick left
	    	self.dressup:ScrollBack(control)
			return true
		elseif control == CONTROL_NEXTVALUE then -- r-stick right
			self.dressup:ScrollFwd(control)
			return true
		elseif control == CONTROL_SCROLLBACK then
            self.dressup:ScrollBack(control)
            return true
        elseif control == CONTROL_SCROLLFWD then
        	self.dressup:ScrollFwd(control)
            return true
        end
	end
end

return CharacterLoadoutPopupScreen