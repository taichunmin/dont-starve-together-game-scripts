local CharacterButton = require "widgets/redux/characterbutton"
local Image = require "widgets/image"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

require("characterutil")
require("skinsutils")

local CharacterProgress = Class(Widget, function(self, character, cbPortraitFocused, cbPortraitClicked)
	Widget._ctor(self, "CharacterProgress")
    assert(character)

    self.herocharacter = character

	self.icon = self:AddChild(CharacterButton(character, cbPortraitFocused, cbPortraitClicked))
	self.progress_root = self:AddChild(self:_BuildProgressBanner(character))
	self.progress_root:SetPosition(0,-14)
    self:RefreshInventory()

    self.focus_forward = self.icon
end)

function CharacterProgress:_BuildProgressBanner(herocharacter)
    local progress_root = Widget("progress root")

    self.progressbar = progress_root:AddChild(UIAnim())
    self.progressbar:GetAnimState():SetBank("skin_progressbar")
    self.progressbar:GetAnimState():SetBuild("skin_progressbar")
    self.progressbar:GetAnimState():PlayAnimation("fill_progress", true)
    self.progressbar:GetAnimState():SetPercent("fill_progress", 0)
    self.progressbar:SetPosition(0, -40) 
    self.progressbar:SetScale(0.7)

    self.characterprogress = progress_root:AddChild(Text(HEADERFONT, 20, nil, UICOLOURS.BLACK))
    self.characterprogress:SetPosition(2, -45)

    return progress_root
end

function CharacterProgress:_GetUnlockPercent(num_owned, num_need)
    local total = num_owned + num_need
    if total > 0 then
        return num_owned / total
    else
        return 0
    end
end

function CharacterProgress:RefreshInventory()
    local num_owned, num_need = GetSkinCollectionCompletionForHero(self.herocharacter)
    local percent = self:_GetUnlockPercent(num_owned, num_need)

    self.characterprogress:SetString(string.format("%0.0f%%", percent*100))
    self.progressbar:GetAnimState():SetPercent("fill_progress", percent)
end

function CharacterProgress:SetCharacter(hero)
    self.herocharacter = hero
	self.icon:SetCharacter(hero)
    self:RefreshInventory()
    --local colour = CHARACTER_COLOURS[hero] or CHARACTER_COLOURS.default
    --self.characterprogress:SetColour(colour)
    --self.progressbar:GetAnimState():SetMultColour(unpack(colour))
end

return CharacterProgress
