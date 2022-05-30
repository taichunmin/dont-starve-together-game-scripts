
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local TEMPLATES = require "widgets/redux/templates"
local TrueScrollArea = require "widgets/truescrollarea"

require("characterutil")
require("stringutil")

local CharacterBio = Class(Widget, function(self, character)
	Widget._ctor(self, "OvalPortrait")

    self.portrait_root = self:AddChild(self:_BuildPortraitWidgets(character))
	self.portrait_root:SetPosition(-235, 70)

    self.text_root = self:AddChild(self:_BuildBioText(character))
	self.text_root:SetPosition(-5, 10)

	self.focus_forward = self.scroll_area
end)

function CharacterBio:_BuildPortraitWidgets(character)
    local root = Widget("portrait_root")

    self.portrait = root:AddChild(Image())
    self.portrait:SetPosition(-1, 0)
    self.portrait:SetScale(.60)
    SetOvalPortraitTexture(self.portrait, character)

	self.charactername = root:AddChild(Image())
	self.charactername:SetScale(.4)
	self.charactername:SetPosition(0, 180)
    local success = SetHeroNameTexture_Gold(self.charactername, character)
	if not success then
		self.charactername:Hide()
	end

	local status_y = -230
	self.health_status = root:AddChild(TEMPLATES.MakeUIStatusBadge("health", character))
	self.health_status:SetPosition(-80, status_y)

	self.hunger_status = root:AddChild(TEMPLATES.MakeUIStatusBadge("hunger", character))
	self.hunger_status:SetPosition(0, status_y)

	self.sanity_status = root:AddChild(TEMPLATES.MakeUIStatusBadge("sanity", character))
	self.sanity_status:SetPosition(80, status_y)

	self.inv = root:AddChild(TEMPLATES.MakeStartingInventoryWidget(character))
	self.inv:SetPosition(0, status_y - 65)

    return root
end

function CharacterBio:_BuildBioText(character)
    local root = Widget("bio_root")

    local sub_root = Widget("text_root")

	local width = 520

	local bio = JoinArrays({
						{ title = STRINGS.CHARACTER_TITLES[character], desc = STRINGS.CHARACTER_ABOUTME[character] },
						{ title = STRINGS.CHARACTER_DETAILS.CHARACTER_DESCRIPTION_TITLE, desc = GetCharacterDescription(character) },
						{ title = STRINGS.CHARACTER_DETAILS.CHARACTER_QUOTE_TITLE, desc = STRINGS.CHARACTER_QUOTES[character] },
					},
					STRINGS.CHARACTER_BIOS[character])

	local left = 0
	local height = 0
	local title_space = 5
	local section_space = 22

	for i, section in ipairs(bio) do
	    local title = sub_root:AddChild(Text(HEADERFONT, 25, section.title, UICOLOURS.GOLD_UNIMPORTANT))
		title:SetHAlign(ANCHOR_LEFT)

        local x, y = title:GetRegionSize()
        title:SetPosition(left + 0.5 * x, height - 0.5 * y)
		height = height - y - title_space

		local desc = sub_root:AddChild(Text(CHATFONT, 21, nil, UICOLOURS.GREY))
		desc:SetHAlign(ANCHOR_LEFT)
		desc:SetVAlign(ANCHOR_TOP)
		desc:SetMultilineTruncatedString(section.desc, 20, width)

        x, y = desc:GetRegionSize()
        desc:SetPosition(left + 0.5 * x, height - 0.5 * y)
		height = height - y - section_space
	end

	height = math.abs(height)

	local max_visible_height = 580
	local padding = 5

	local top = math.min(height, max_visible_height)/2 - padding

	local scissor_data = {x = 0, y = -max_visible_height/2, width = width, height = max_visible_height}
	local context = {widget = sub_root, offset = {x = 0, y = top}, size = {w = width, height = height + padding} }
	local scrollbar = { scroll_per_click = 20*3 }
	self.scroll_area = root:AddChild(TrueScrollArea(context, scissor_data, scrollbar))

    return root
end

return CharacterBio
