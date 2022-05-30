local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local OnlineStatus = require "widgets/onlinestatus"
local WardrobeScreen = require "screens/redux/wardrobescreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

local CharacterBio = require "widgets/redux/characterbio"

local CharacterBioScreen = Class(Screen, function(self, character)
	Screen._ctor(self, "CharacterBioScreen")

	self.character = character

    self:AddChild(TEMPLATES.old.ForegroundLetterbox())

	self.root = self:AddChild(TEMPLATES.ScreenRoot("CharacterBioScreen"))

	self.bio = self.root:AddChild(CharacterBio(character))
	self.bio:SetPosition(0, 0)

    self.bg = self.bio:AddChild(TEMPLATES.PlainBackground())
	self.bg:MoveToBack()
    --self.title = self.root:AddChild(TEMPLATES.ScreenTitle("CharacterBioScreen", character))

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        {x = -425, y = -110, scale=0.75},
        {x = -475, y = -110, scale=0.75},
        {x = -390, y = -110, scale=0.75},
        {x = -80, y = -110, scale=0.75},
    } ))

	self.onlinestatus = self.root:AddChild(OnlineStatus())

	self.cancel_button = self.root:AddChild(TEMPLATES.BackButton(function() self:Close() end))
    if TheInput:ControllerAttached() then
        self.cancel_button:Hide()
	end

	self.videos = IsSteam() and CHARACTER_VIDEOS[character] or nil
	if self.videos then
		if not TheInput:ControllerAttached() then
			self.video_button = self.root:AddChild(TEMPLATES.StandardButton(function() VisitURL(self.videos[1]) end, STRINGS.CHARACTER_DETAILS.VIDEO_BUTTON, {260, 54}))
			self.video_button:SetPosition(150, -320)
		end
	end

	if not TheInput:ControllerAttached() then
		self.wardrobe_button = self.root:AddChild(TEMPLATES.StandardButton(function() self:OnWardrobe()  end, STRINGS.UI.COLLECTIONSCREEN.SKINS, {200, 54}))
		self.wardrobe_button:SetPosition(400, -320)
	end

	self.focus_forward = self.bio
	self:SetFocus(self.bio)
end)

function CharacterBioScreen:OnWardrobe()
	TheFrontEnd:FadeToScreen( self, function() return WardrobeScreen(Profile, self.character) end, nil )
end

function CharacterBioScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_CANCEL then
		TheFrontEnd:FadeBack()
	    return true
	elseif self.videos and not down and control == CONTROL_PAUSE and TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
		VisitURL(self.videos[1])
		return true
	elseif not down and control == CONTROL_MENU_MISC_1 then
		self:OnWardrobe()
		return true
    end
end

function CharacterBioScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()

	local t = {}
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
	if self.videos then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PAUSE) .. "  " .. STRINGS.CHARACTER_DETAILS.VIDEO_BUTTON)
	end
	table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1) .. "  " .. STRINGS.UI.COLLECTIONSCREEN.SKINS)

	return table.concat(t, "  ")

end

function CharacterBioScreen:OnBecomeActive()
    CharacterBioScreen._base.OnBecomeActive(self)

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end
end

function CharacterBioScreen:OnBecomeInactive()
    CharacterBioScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
end

function CharacterBioScreen:Close(fn)
    TheFrontEnd:FadeBack(nil, nil, fn)
end

return CharacterBioScreen
