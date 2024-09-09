local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local DressupPanel = require "widgets/dressuppanel"
local TEMPLATES = require "widgets/templates"

local SCREEN_OFFSET = -.285 * RESOLUTION_X

local ScarecrowClothingPopupScreen = Class(Screen, function(self, owner_scarecrow, doer, profile)
	Screen._ctor(self, "ScarecrowClothingPopupScreen")

    self.owner_scarecrow = owner_scarecrow
    self.doer = doer

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.root = self.proot:AddChild(Widget("root"))
    self.root:SetPosition(RESOLUTION_X/2, RESOLUTION_Y/2, 0)

    local skeleton_data = {}
	skeleton_data.base_skin = ""
	skeleton_data.body_skin = ""
	skeleton_data.hand_skin = ""
	skeleton_data.legs_skin = ""
	skeleton_data.feet_skin = ""


    self.dressup = self.proot:AddChild(DressupPanel(self, profile, skeleton_data))
    self.dressup:SetPosition(0, 30)
    self.dressup:SetCurrentCharacter(self.owner_scarecrow.prefab)

    local spacing = 225
    local buttons = {}

    local offline = not TheInventory:HasSupportForOfflineSkins() and not TheNet:IsOnlineMode()

    if offline then
    	buttons = {{text = STRINGS.UI.POPUPDIALOG.OK, cb = function() self:Close(false) end}}
    else
    	buttons = {	{text = STRINGS.UI.WARDROBE_POPUP.CANCEL, cb = function() self:Cancel() end},
					{text = STRINGS.UI.WARDROBE_POPUP.SET,    cb = function() self:Close(true) end},
                  }
    end

    self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
    self.menu:SetPosition(-104, -280, 0)

    if offline then
		self.menu:SetPosition(0, -280, 0)
    end

	self.default_focus = self.menu

	self.dressup:ReverseFocus()
	self.menu.reverse = true

	TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)

    self:DoFocusHookups()

    SetAutopaused(true)
end)

function ScarecrowClothingPopupScreen:OnDestroy()
    SetAutopaused(false)
	TheCamera:PopScreenHOffset(self)
    self._base.OnDestroy(self)
end

function ScarecrowClothingPopupScreen:OnBecomeActive()
    self._base.OnBecomeActive(self)
    if TheInput:ControllerAttached() then
        self.default_focus:SetFocus()
    end
end

function ScarecrowClothingPopupScreen:DoFocusHookups()
	self.menu:SetFocusChangeDir(MOVE_UP, self.dressup)
    self.dressup:SetFocusChangeDir(MOVE_DOWN, self.menu)
end

function ScarecrowClothingPopupScreen:OnControl(control, down)
    if ScarecrowClothingPopupScreen._base.OnControl(self,control, down) then return true end

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

function ScarecrowClothingPopupScreen:Cancel()
	--self:Reset()
	self:Close(false)
end

--function ScarecrowClothingPopupScreen:Reset()
	--self.dressup:Reset()
--end

function ScarecrowClothingPopupScreen:Close(apply_skins)
	-- Gets the current skin names (and sets them as the character default)
	local skins = self.dressup:GetSkinsForGameStart()

    local data = {}
    if apply_skins and (TheInventory:HasSupportForOfflineSkins() or TheNet:IsOnlineMode()) then
		data = skins
    end

    POPUPS.WARDROBE:Close(self.doer, data.base, data.body, data.hand, data.legs, data.feet)

    self.dressup:OnClose()
    TheFrontEnd:PopScreen(self)
end

function ScarecrowClothingPopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	return table.concat(t, "  ")

end

return ScarecrowClothingPopupScreen